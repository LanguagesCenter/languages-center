#!/usr/bin/env node
// Regenerate lesson exercises for Spanish + French, A1–C1, using Claude.
//
// Every exercise is constrained to use ONLY the vocab from its own lesson
// (or, in later lessons, vocab from earlier lessons in the same section as
// review). Never cross-contaminates topics. Lesson 1 is the simplest form
// of the section topic; difficulty ramps to lesson 7; lesson 8 is a
// dialogue-heavy interaction. Content is generated per-lesson via a
// cached system prompt so the batch stays cheap.
//
// USAGE
//   node --env-file=.env.local scripts/regenerate-exercises.mjs [flags]
//
// Defaults to --dry-run. Live writes require --live AND
// SUPABASE_SERVICE_ROLE_KEY in the env.
//
// FLAGS
//   --dry-run                default: calls the API but does NOT write to DB
//   --live                   actually write; requires SUPABASE_SERVICE_ROLE_KEY
//   --language <slug>        limit to a language slug (spanish|french)
//   --level <A1..C1>         limit to a CEFR level
//   --section <needle>       limit to sections whose title contains this substring (case-insensitive)
//   --lesson-limit <N>       cap number of lessons regenerated this run
//   --resume                 skip lessons already in the progress log (on by default)
//   --no-resume              regenerate everything, ignoring progress
//   --reset                  wipe progress log and start fresh
//   --verbose                print full exercise JSON per lesson in dry-run
//   --sleep-ms <N>           delay between lessons (default 400ms — soft rate-limit)
//
// REQUIRED ENV VARS
//   NEXT_PUBLIC_SUPABASE_URL         (read + write)
//   NEXT_PUBLIC_SUPABASE_ANON_KEY    (dry-run reads; anon RLS must allow reading languages/courses/lessons)
//   SUPABASE_SERVICE_ROLE_KEY        (only needed for --live; bypasses RLS for writes)
//   ANTHROPIC_API_KEY

import { readFile, writeFile, mkdir } from "node:fs/promises";
import { dirname } from "node:path";
import { existsSync } from "node:fs";

// ---------- constants ----------

const MODEL = "claude-sonnet-4-6";
const ANTHROPIC_URL = "https://api.anthropic.com/v1/messages";
const PROGRESS_PATH = new URL("./.regeneration-progress.json", import.meta.url).pathname;

// Mix per lesson.type. Each entry:
//   type    — DB exercise type (multiple_choice | fill_blank | listening | speaking)
//   purpose — semantic hint sent to the model so it knows what to build
//   n       — how many exercises of this kind at the BASE (A1/A2) scale
//
// Higher CEFR levels get proportionally fewer items via CEFR_SCALE, so
// each lesson stays roughly the same time-on-task even as sentences
// grow longer. `unit_test` is exempt from scaling — the user asked for
// a fixed 10 questions across all levels.
const EXERCISE_MIX = {
  vocabulary:   [
    { type: "multiple_choice", purpose: "vocab_translation", n: 5 },
    { type: "fill_blank",      purpose: "vocab_in_sentence", n: 3 },
  ],
  grammar:      [
    { type: "multiple_choice", purpose: "grammar_pattern",   n: 4 },
    { type: "fill_blank",      purpose: "grammar_conjugation", n: 4 },
  ],
  phrases:      [
    { type: "multiple_choice", purpose: "phrase_usage",      n: 5 },
    { type: "fill_blank",      purpose: "phrase_completion", n: 3 },
  ],
  reading:      [
    { type: "multiple_choice", purpose: "reading_comprehension", n: 5 },
    { type: "fill_blank",      purpose: "vocab_in_sentence", n: 3 },
  ],
  listening:    [
    { type: "listening",       purpose: "listening",         n: 6 },
  ],
  speaking:     [
    { type: "speaking",        purpose: "speaking",          n: 4 },
  ],
  writing:      [
    { type: "speaking",        purpose: "writing_response",  n: 4 },
  ],
  // Conversation lessons: comprehension MC on the dialogue + spoken
  // response prompts. Uses the existing lesson.dialogue as source
  // material; no new dialogue is generated (yet — flagged separately).
  conversation: [
    { type: "multiple_choice", purpose: "dialogue_comprehension", n: 3 },
    { type: "speaking",        purpose: "dialogue_response", n: 2 },
  ],
  // Section test — 10 questions distributed across all four skills.
  // Fixed count regardless of CEFR (see EXEMPT_FROM_SCALE).
  unit_test:    [
    { type: "listening",       purpose: "listening",         n: 3 },
    { type: "speaking",        purpose: "speaking",          n: 3 },
    { type: "multiple_choice", purpose: "reading_comprehension", n: 2 },
    { type: "speaking",        purpose: "writing_response",  n: 2 },
  ],
};

// Lesson counts scale down at higher CEFR levels since sentences get
// longer — keeps total time-on-task roughly constant.
const CEFR_SCALE = { A1: 1.0, A2: 1.0, B1: 0.85, B2: 0.75, C1: 0.65 };
const EXEMPT_FROM_SCALE = new Set(["unit_test"]);

function scaleMix(mix, lessonType, cefrLevel) {
  if (EXEMPT_FROM_SCALE.has(lessonType)) return mix;
  const scale = CEFR_SCALE[cefrLevel] ?? 1.0;
  if (scale >= 1.0) return mix;
  return mix.map(m => ({ ...m, n: Math.max(1, Math.round(m.n * scale)) }));
}

// Lesson types the script skips entirely — currently only `podcast`,
// which uses metadata-only schema (audio URLs, transcripts) that this
// script has no path for. `conversation` used to live here but is now
// handled specially — see the conversation entry in EXERCISE_MIX.
const SKIP_LESSON_TYPES = new Set(["podcast"]);

// Per-language stoplists — high-frequency function + content words that
// don't have to appear in the lesson's allowed_vocab because they're
// language glue every learner meets in A1. Structural words (articles,
// pronouns, prepositions) + all common conjugations of the top 20 verbs
// + universal nouns/adjectives/adverbs + numbers. Deliberately excludes
// TOPICAL vocab (foods, jobs, places, etc.) so the topic-boundary rule
// still bites.
const STOPWORDS = {
  Spanish: new Set([
    // articles / determiners
    "el","la","los","las","un","una","unos","unas","lo",
    // pronouns
    "yo","tu","tú","él","ella","usted","nosotros","nosotras","vosotros","vosotras",
    "ellos","ellas","ustedes","me","te","se","nos","os","le","les","mi","mis","tú","tus",
    "su","sus","nuestro","nuestra","nuestros","nuestras","vuestro","vuestra","suyo","suya",
    "mío","mía","tuyo","tuya",
    // prepositions
    "a","al","ante","bajo","con","contra","de","del","desde","en","entre","hacia","hasta",
    "mediante","para","por","según","sin","so","sobre","tras","durante","excepto","salvo",
    // conjunctions / connectives
    "y","e","o","u","ni","pero","sino","aunque","si","que","como","porque","pues","así",
    "cuando","mientras","hasta","aunque","entonces","por","tanto","además","también",
    "sin embargo","por tanto",
    // question / demonstrative markers
    "qué","quién","quiénes","cuál","cuáles","cómo","dónde","cuándo","cuánto","cuánta",
    "cuántos","cuántas","este","esta","estos","estas","ese","esa","esos","esas",
    "aquel","aquella","aquellos","aquellas","eso","esto","aquello",
    // negation / affirmation
    "no","sí","nunca","jamás","ninguno","ningún","ninguna","nada","nadie","tampoco",
    // ser / estar / haber
    "ser","siendo","sido","soy","eres","es","somos","sois","son","fui","fuiste","fue",
    "fuimos","fuisteis","fueron","era","eras","éramos","erais","eran","sea","seas","sean",
    "seamos","seáis","seré","serás","será","seremos","serán","sería","serías","serían",
    "estar","estando","estado","estoy","estás","está","estamos","estáis","están",
    "estuve","estuviste","estuvo","estuvimos","estuvieron","estaba","estabas","estábamos",
    "estabais","estaban","esté","estés","estén","estemos","estaré","estará","estaría",
    "haber","habiendo","habido","he","has","ha","hemos","habéis","han","hay","hube",
    "hubo","hubimos","hubieron","había","habías","habíamos","habían","haya","hayan",
    "habré","habrá","habría",
    // tener
    "tener","teniendo","tenido","tengo","tienes","tiene","tenemos","tenéis","tienen",
    "tuve","tuviste","tuvo","tuvimos","tuvieron","tenía","tenías","teníamos","tenían",
    "tenga","tengas","tengan","tendré","tendrá","tendría",
    // hacer
    "hacer","haciendo","hecho","hago","haces","hace","hacemos","hacéis","hacen",
    "hice","hiciste","hizo","hicimos","hicieron","hacía","hacías","hacíamos","hacían",
    "haga","hagas","hagan","haré","harás","hará","haremos","haría","haz",
    // poder
    "poder","pudiendo","podido","puedo","puedes","puede","podemos","podéis","pueden",
    "pude","pudo","pudimos","pudieron","podía","podías","podíamos","podían",
    "pueda","puedas","puedan","podré","podrá","podría","podríamos","podríais","podrían",
    // decir
    "decir","diciendo","dicho","digo","dices","dice","decimos","decís","dicen",
    "dije","dijo","dijimos","dijeron","decía","decías","decíamos","decían",
    "diga","digas","digan","diré","dirá","diría","di",
    // ir
    "ir","yendo","ido","voy","vas","va","vamos","vais","van","iba","ibas","íbamos","iban",
    "vaya","vayas","vayan","iré","irá","iremos","irán","iría","ve",
    // ver
    "ver","viendo","visto","veo","ves","vemos","veis","ven","vi","viste","vio","vimos",
    "vieron","veía","veías","veíamos","veían","vea","veas","vean","veré","verá","vería",
    // saber
    "saber","sabiendo","sabido","sé","sabes","sabe","sabemos","sabéis","saben",
    "supe","supo","supimos","supieron","sabía","sabías","sabíamos","sabían",
    "sepa","sepas","sepan","sabré","sabrá","sabría",
    // querer
    "querer","queriendo","querido","quiero","quieres","quiere","queremos","queréis","quieren",
    "quise","quiso","quisimos","quisieron","quería","querías","queríamos","querían",
    "quiera","quieras","quieran","querré","querría",
    // dar / poner / venir
    "dar","dando","dado","doy","das","da","damos","dais","dan","dio","dieron","daba",
    "daban","dé","den","daré","dará","daría",
    "poner","poniendo","puesto","pongo","pones","pone","ponemos","ponen","puse","puso",
    "pusieron","ponía","poníamos","ponía","ponía","ponga","pongan","pondré","pondría",
    "venir","viniendo","venido","vengo","vienes","viene","venimos","vienen","vine","vino",
    "vinimos","vinieron","venía","venían","venga","vengan","vendré","vendrá","vendría","ven",
    // llegar / llevar / hablar / vivir / creer / pensar
    "llegar","llegando","llegado","llego","llegas","llega","llegamos","llegan","llegué",
    "llegó","llegaron","llegaba","llegaban","llegue","lleguen","llegará","llegaría",
    "llevar","llevando","llevado","llevo","llevas","lleva","llevamos","llevan","llevé",
    "llevó","llevaron","llevaba","llevaban","lleve","lleven","llevará","llevaría",
    "hablar","hablando","hablado","hablo","hablas","habla","hablamos","hablan","hablé",
    "habló","hablaron","hablaba","hablaban","hable","hablen","hablará","hablaría",
    "vivir","viviendo","vivido","vivo","vives","vive","vivimos","viven","viví","vivió",
    "vivieron","vivía","vivíamos","vivían","viva","vivan",
    "creer","creyendo","creído","creo","crees","cree","creemos","creen","creí","creyó",
    "creyeron","creía","creíamos","creían","crea","crean","creerá","creería",
    "pensar","pensando","pensado","pienso","piensas","piensa","pensamos","piensan","pensé",
    "pensó","pensaron","pensaba","pensaban","piense","piensen","pensará","pensaría",
    // seguir / encontrar / entender / usar / trabajar / esperar / recibir / mostrar / permitir / servir
    "seguir","siguiendo","seguido","sigo","sigues","sigue","seguimos","siguen","seguí",
    "siguió","siguieron","seguía","seguían","siga","sigan","seguirá",
    "encontrar","encontrando","encontrado","encuentro","encuentras","encuentra","encontramos",
    "encuentran","encontré","encontró","encontraron","encontraba","encontraban","encuentre",
    "encuentren","encontrará",
    "entender","entendiendo","entendido","entiendo","entiendes","entiende","entendemos",
    "entienden","entendí","entendió","entendieron","entendía","entendían","entienda","entiendan",
    "usar","usando","usado","uso","usas","usa","usamos","usan","usé","usó","usaron",
    "usaba","usaban","use","usen","usará",
    "trabajar","trabajando","trabajado","trabajo","trabajas","trabaja","trabajamos",
    "trabajan","trabajé","trabajó","trabajaron","trabajaba","trabajaban","trabaje","trabajen",
    "esperar","esperando","esperado","espero","esperas","espera","esperamos","esperan",
    "esperé","esperó","esperaron","esperaba","esperaban","espere","esperen",
    "recibir","recibiendo","recibido","recibo","recibes","recibe","recibimos","reciben",
    "recibí","recibió","recibieron","recibía","recibían","reciba","reciban",
    "mostrar","mostrando","mostrado","muestro","muestras","muestra","mostramos","muestran",
    "mostré","mostró","mostraron","mostraba","mostraban","muestre","muestren",
    "permitir","permitiendo","permitido","permito","permites","permite","permitimos",
    "permiten","permití","permitió","permitieron","permitía","permitían","permita","permitan",
    "servir","sirviendo","servido","sirvo","sirves","sirve","servimos","sirven","serví",
    "sirvió","sirvieron","servía","servían","sirva","sirvan",
    // presentar / analizar / explicar / describir / considerar / demostrar / suponer
    "presentar","presentando","presentado","presento","presentas","presenta","presentamos",
    "presentan","presenté","presentó","presentaron","presentaba","presentaban","presente",
    "presenten","presentada","presentados","presentadas",
    "analizar","analizando","analizado","analizo","analizas","analiza","analizamos","analizan",
    "analicé","analizó","analizaron","analizaba","analizaban","analice","analicen","analizada",
    "analizados","analizadas","analizará","analizaría",
    "explicar","explicando","explicado","explico","explicas","explica","explicamos","explican",
    "expliqué","explicó","explicaron","explicaba","explicaban","explique","expliquen",
    "describir","describiendo","descrito","describo","describes","describe","describimos",
    "describen","describí","describió","describieron","describía","describían","describa","describan",
    "considerar","considerando","considerado","considero","consideras","considera","consideramos",
    "consideran","consideré","consideró","consideraron","consideraba","consideraban","considere","consideren",
    "demostrar","demostrando","demostrado","demuestro","demuestras","demuestra","demostramos",
    "demuestran","demostré","demostró","demostraron","demostraba","demostraban","demuestre","demuestren",
    "suponer","suponiendo","supuesto","supongo","supones","supone","suponemos","suponen",
    "supuse","supuso","supusieron","suponía","suponían","suponga","supongan",
    // reflexive markers
    "me","te","se","nos","os",
    // ultra-common adverbs / adjectives / quantifiers
    "muy","más","menos","también","tampoco","ya","aún","aun","sólo","solo","todo",
    "toda","todos","todas","otro","otra","otros","otras","mucho","mucha","muchos","muchas",
    "poco","poca","pocos","pocas","tanto","tanta","tantos","tantas","cada","varios","varias",
    "cierto","cierta","ciertos","ciertas","alguno","algún","alguna","algunos","algunas",
    "ambos","ambas","medio","media","mejor","peor","mayor","menor",
    "bien","mal","mejor","peor","así","aquí","ahí","allí","acá","allá","ahora","entonces",
    "después","antes","luego","hoy","ayer","mañana","tarde","temprano","pronto","siempre",
    "nunca","todavía","apenas","casi","quizás","quizá","tal","vez","tal vez","sobre todo",
    // universal adjectives (non-topical)
    "grande","grandes","pequeño","pequeña","pequeños","pequeñas","bueno","buena","buenos",
    "buenas","malo","mala","malos","malas","nuevo","nueva","nuevos","nuevas","viejo","vieja",
    "viejos","viejas","joven","jóvenes","alto","alta","altos","altas","bajo","baja","bajos",
    "bajas","mismo","misma","mismos","mismas","propio","propia","propios","propias","primero",
    "primera","primeros","primeras","último","última","últimos","últimas","próximo","próxima",
    "actual","actuales","importante","importantes","posible","posibles","imposible","imposibles",
    "difícil","difíciles","fácil","fáciles","real","reales","claro","clara","claros","claras",
    "cierto","cierta","seguro","segura","principal","principales","general","generales",
    "especial","especiales","normal","normales","natural","naturales","personal","personales",
    "verdadero","verdadera","larga","largo","largos","largas","corto","corta","cortos","cortas",
    "profundo","profunda","ancho","ancha","completo","completa","exacto","exacta",
    // universal nouns (non-topical structural / relational)
    "cosa","cosas","forma","formas","manera","maneras","modo","modos","tipo","tipos",
    "clase","clases","parte","partes","punto","puntos","lugar","lugares","sitio","sitios",
    "momento","momentos","hora","horas","día","días","semana","semanas","mes","meses",
    "año","años","tiempo","tiempos","vez","veces","número","números","caso","casos",
    "razón","razones","idea","ideas","palabra","palabras","nombre","nombres","ejemplo","ejemplos",
    "vida","vidas","persona","personas","mundo","mundos","gente","hombre","hombres","mujer","mujeres",
    "grupo","grupos","fin","final","medio","medios","principio","principios","proceso","procesos",
    "resultado","resultados","efecto","efectos","causa","causas","situación","situaciones",
    // numbers
    "cero","uno","dos","tres","cuatro","cinco","seis","siete","ocho","nueve","diez",
    "once","doce","trece","catorce","quince","dieciséis","diecisiete","dieciocho","diecinueve",
    "veinte","veintiuno","veintidós","treinta","cuarenta","cincuenta","sesenta","setenta",
    "ochenta","noventa","cien","ciento","cientos","mil","miles","millón","millones",
    "primero","segundo","tercero","cuarto","quinto","sexto","séptimo","octavo","noveno","décimo",
    // === EXPANDED CONTENT VOCAB (assumed known at B1+) ===
    // Body (universal, non-topical)
    "cara","caras","ojo","ojos","mano","manos","pie","pies","cabeza","brazo","brazos","pierna",
    "piernas","corazón","boca","nariz","oreja","orejas","dedo","dedos","pelo","cuerpo","piel",
    "diente","dientes","cuello","hombro","espalda","estómago","sangre",
    // Family (universal)
    "padre","madre","papá","mamá","hermano","hermana","hermanos","hermanas","hijo","hija","hijos",
    "hijas","abuelo","abuela","abuelos","abuelas","tío","tía","tíos","tías","primo","prima",
    "primos","primas","sobrino","sobrina","marido","esposa","esposo","novio","novia","familia",
    "familiares","pareja",
    // Time (extended)
    "minuto","minutos","segundo","madrugada","mediodía","jornada","siglo","siglos","época",
    "década","décadas","fin","weekend","hoy","ayer","mañana","noche","tarde","anoche",
    // Places (universal)
    "casa","casas","escuela","escuelas","universidad","oficina","oficinas","tienda","tiendas",
    "mercado","mercados","restaurante","restaurantes","cafetería","bar","bares","banco","bancos",
    "hospital","hospitales","aeropuerto","estación","estaciones","parque","parques","ciudad",
    "ciudades","pueblo","pueblos","país","países","calle","calles","plaza","plazas","iglesia",
    "museo","biblioteca","gimnasio","playa","montaña","río","mar","campo","bosque","jardín",
    "edificio","edificios","hotel","hoteles","apartamento","habitación","habitaciones","cocina",
    "salón","baño","baños","terraza","garaje",
    // Work (universal at B1+)
    "trabajo","trabajos","empresa","empresas","jefe","jefa","jefes","colega","colegas","compañero",
    "compañera","compañeros","compañeras","empleado","empleada","empleados","reunión","reuniones",
    "proyecto","proyectos","cliente","clientes","servicio","servicios","negocio","negocios","tarea",
    "tareas","informe","informes","presupuesto","sueldo","salario","contrato","contratos",
    "entrevista","entrevistas","conferencia","conferencias","carrera","carreras","profesión",
    "profesiones","carrera","trabajador","trabajadora","trabajadores",
    // Money / commerce
    "dinero","euros","dólar","dólares","precio","precios","coste","costes","tarifa","tarifas",
    "factura","facturas","cuenta","cuentas","tarjeta","tarjetas","billete","billetes","moneda",
    "monedas","cambio","recibo","recibos","pago","pagos","ingreso","ingresos","ahorro","ahorros",
    "efectivo","descuento","descuentos","oferta","ofertas","compra","compras","venta","ventas",
    // Communication
    "teléfono","teléfonos","móvil","móviles","mensaje","mensajes","llamada","llamadas","correo",
    "correos","email","emails","carta","cartas","conversación","conversaciones","respuesta",
    "respuestas","pregunta","preguntas","palabra","palabras","frase","frases","discurso",
    "discursos","noticia","noticias","artículo","artículos","revista","revistas","periódico",
    "periódicos","libro","libros",
    // Common objects
    "silla","sillas","mesa","mesas","cama","camas","sofá","sofás","puerta","puertas","ventana",
    "ventanas","pared","paredes","techo","suelo","luz","luces","ropa","zapatos","gafas","reloj",
    "relojes","llave","llaves","bolsa","bolsas","maleta","maletas","coche","coches","autobús",
    "autobuses","tren","trenes","avión","aviones","bici","bicis","moto","motocicleta","bicicleta",
    "ordenador","ordenadores","computadora","tableta","cámara","cámaras","foto","fotos",
    "fotografía","fotografías",
    // Basic food/drink (universal daily)
    "agua","café","té","leche","pan","comida","comidas","cena","desayuno","almuerzo","plato",
    "platos","vaso","vasos","taza","tazas","copa","fruta","frutas","verdura","carne","pescado",
    // Feelings / states (universal)
    "contento","contenta","contentos","contentas","triste","tristes","alegre","alegres","feliz",
    "felices","infeliz","enfadado","enfadada","enfadados","enojado","enojada","molesto","molesta",
    "cansado","cansada","cansados","aburrido","aburrida","emocionado","emocionada","orgulloso",
    "orgullosa","avergonzado","celoso","celosa","nervioso","nerviosa","tranquilo","tranquila",
    "relajado","relajada","preocupado","preocupada","asustado","asustada","sorprendido","sorprendida",
    // Descriptive adjectives (non-topical)
    "bonito","bonita","bonitos","bonitas","feo","fea","agradable","desagradable","interesante",
    "aburrido","divertido","divertida","gracioso","graciosa","seria","serio","seguro","segura",
    "peligroso","peligrosa","tranquilo","ruidoso","ruidosa","ocupado","ocupada","libre",
    "disponible","cerrado","cerrada","abierto","abierta","lleno","llena","vacío","vacía","gordo",
    "gorda","delgado","delgada","guapo","guapa","atractivo","atractiva","fuerte","fuertes","débil",
    "débiles","sano","sana","enfermo","enferma","limpio","limpia","sucio","sucia","caro","cara",
    "barato","barata","rápido","rápida","lento","lenta","caliente","frío","fría","tibio","fresco",
    "fresca","dulce","dulces","salado","salada","amargo","amarga","ácido","ácida","picante",
    "moderno","moderna","tradicional","antiguo","antigua","increíble","fantástico","fantástica",
    "maravilloso","maravillosa","terrible","horrible","genial",
    // Common verbs — extended conjugations
    "llegar","llegando","llegado","llego","llegas","llega","llegamos","llegáis","llegan","llegué",
    "llegaste","llegó","llegaron","llegaba","llegaban","llegue","lleguen","llegará","llegarán",
    "llegaría","llegarían","llegado",
    "salir","saliendo","salido","salgo","sales","sale","salimos","salís","salen","salí","saliste",
    "salió","salieron","salía","salías","salíamos","salían","salga","salgas","salgan","saldré",
    "saldrás","saldrá","saldremos","saldrán","saldría",
    "entrar","entrando","entrado","entro","entras","entra","entramos","entráis","entran","entré",
    "entraste","entró","entraron","entraba","entraban","entre","entren","entrará","entraría",
    "subir","subiendo","subido","subo","subes","sube","subimos","subís","suben","subí","subiste",
    "subió","subieron","subía","subían","suba","suban","subirá","subirán","subiría",
    "bajar","bajando","bajado","bajo","bajas","baja","bajamos","bajáis","bajan","bajé","bajaste",
    "bajó","bajaron","bajaba","bajaban","baje","bajen","bajará","bajaría",
    "correr","corriendo","corrido","corro","corres","corre","corremos","corren","corrí","corriste",
    "corrió","corrieron","corría","corrían","corra","corran","correrá","correría",
    "andar","andando","andado","ando","andas","anda","andamos","andan","anduve","anduviste",
    "anduvo","anduvieron","andaba","andaban","ande","anden",
    "caminar","caminando","caminado","camino","caminas","camina","caminamos","caminan","caminé",
    "caminó","caminaron","caminaba","caminaban","camine","caminen",
    "volver","volviendo","vuelto","vuelvo","vuelves","vuelve","volvemos","vuelven","volví",
    "volvió","volvieron","volvía","volvían","vuelva","vuelvan","volverá","volvería",
    "comer","comiendo","comido","como","comes","come","comemos","coméis","comen","comí","comiste",
    "comió","comimos","comisteis","comieron","comía","comías","comíamos","comían","coma","comas",
    "coman","comeré","comerá","comerán","comería","comerías","comerían",
    "beber","bebiendo","bebido","bebo","bebes","bebe","bebemos","beben","bebí","bebiste","bebió",
    "bebieron","bebía","bebían","beba","beban","beberá","bebería",
    "cocinar","cocinando","cocinado","cocino","cocinas","cocina","cocinamos","cocinan","cociné",
    "cocinó","cocinaron","cocinaba","cocinaban","cocine","cocinen",
    "comprar","comprando","comprado","compro","compras","compra","compramos","compran","compré",
    "compraste","compró","compraron","compraba","comprabas","comprábamos","compraban","compre",
    "compres","compren","comprará","comprarán","compraría",
    "vender","vendiendo","vendido","vendo","vendes","vende","vendemos","venden","vendí","vendió",
    "vendieron","vendía","vendían","venda","vendan","venderá","vendería",
    "pagar","pagando","pagado","pago","pagas","paga","pagamos","pagan","pagué","pagó","pagaron",
    "pagaba","pagaban","pague","paguen","pagará","pagaría","pagarán",
    "pedir","pidiendo","pedido","pido","pides","pide","pedimos","piden","pedí","pediste","pidió",
    "pidieron","pedía","pedían","pida","pidan","pedirá","pediría",
    "ofrecer","ofreciendo","ofrecido","ofrezco","ofreces","ofrece","ofrecemos","ofrecen","ofrecí",
    "ofreció","ofrecieron","ofrecía","ofrecían","ofrezca","ofrezcan","ofrecerá","ofrecería",
    "aceptar","aceptando","aceptado","acepto","aceptas","acepta","aceptamos","aceptan","acepté",
    "aceptó","aceptaron","aceptaba","aceptaban","acepte","acepten","aceptará","aceptaría",
    "rechazar","rechazando","rechazado","rechazo","rechazas","rechaza","rechazamos","rechazan",
    "rechacé","rechazó","rechazaron","rechazaba","rechazaban","rechace","rechacen","rechazará",
    "estudiar","estudiando","estudiado","estudio","estudias","estudia","estudiamos","estudian",
    "estudié","estudiaste","estudió","estudiaron","estudiaba","estudiaban","estudie","estudien",
    "estudiará","estudiaría","estudiarán",
    "aprender","aprendiendo","aprendido","aprendo","aprendes","aprende","aprendemos","aprenden",
    "aprendí","aprendiste","aprendió","aprendieron","aprendía","aprendían","aprenda","aprendan",
    "aprenderá","aprendería","aprenderán",
    "enseñar","enseñando","enseñado","enseño","enseñas","enseña","enseñamos","enseñan","enseñé",
    "enseñaste","enseñó","enseñaron","enseñaba","enseñaban","enseñe","enseñen","enseñará",
    "viajar","viajando","viajado","viajo","viajas","viaja","viajamos","viajan","viajé","viajaste",
    "viajó","viajaron","viajaba","viajaban","viaje","viajes","viajen","viajará",
    "dormir","durmiendo","dormido","duermo","duermes","duerme","dormimos","duermen","dormí",
    "durmió","durmieron","dormía","dormían","duerma","duerman","dormirá","dormiría",
    "despertar","despertando","despertado","despierto","despiertas","despierta","despertamos",
    "despiertan","desperté","despertó","despertaron","despertaba","despertaban","despierte",
    "despierten","despertará",
    "olvidar","olvidando","olvidado","olvido","olvidas","olvida","olvidamos","olvidan","olvidé",
    "olvidó","olvidaron","olvidaba","olvidaban","olvide","olviden","olvidará","olvidaría",
    "recordar","recordando","recordado","recuerdo","recuerdas","recuerda","recordamos","recuerdan",
    "recordé","recordó","recordaron","recordaba","recordaban","recuerde","recuerden","recordará",
    "imaginar","imaginando","imaginado","imagino","imaginas","imagina","imaginamos","imaginan",
    "imaginé","imaginó","imaginaron","imaginaba","imaginaban","imagine","imaginen",
    "decidir","decidiendo","decidido","decido","decides","decide","decidimos","deciden","decidí",
    "decidió","decidieron","decidía","decidían","decida","decidan","decidirá","decidiría",
    "preferir","prefiriendo","preferido","prefiero","prefieres","prefiere","preferimos","prefieren",
    "preferí","prefirió","prefirieron","prefería","preferían","prefiera","prefieran","preferirá",
    "amar","amando","amado","amo","amas","ama","amamos","aman","amé","amó","amaron","amaba",
    "amaban","ame","amen","amará",
    "odiar","odiando","odiado","odio","odias","odia","odiamos","odian","odié","odió","odiaron",
    "odiaba","odiaban","odie","odien",
    "gustar","gustando","gustado","gusta","gustan","gustó","gustaron","gustaba","gustaban","guste",
    "gusten","gustará","gustaría",
    "interesar","interesando","interesado","interesa","interesan","interesó","interesaron",
    "interesaba","interesaban","interese","interesen","interesará",
    "ganar","ganando","ganado","gano","ganas","gana","ganamos","ganan","gané","ganó","ganaron",
    "ganaba","ganaban","gane","ganen","ganará","ganaría","ganarán",
    "perder","perdiendo","perdido","pierdo","pierdes","pierde","perdemos","pierden","perdí",
    "perdió","perdieron","perdía","perdían","pierda","pierdan","perderá","perdería",
    "traer","trayendo","traído","traigo","traes","trae","traemos","traen","traje","trajo",
    "trajimos","trajeron","traía","traían","traiga","traigan","traerá","traería",
    "llamar","llamando","llamado","llamo","llamas","llama","llamamos","llaman","llamé","llamaste",
    "llamó","llamaron","llamaba","llamaban","llame","llamen","llamará","llamaría","llamarán",
    "buscar","buscando","buscado","busco","buscas","busca","buscamos","buscan","busqué","buscaste",
    "buscó","buscaron","buscaba","buscaban","busque","busquen","buscará","buscaría",
    "cambiar","cambiando","cambiado","cambio","cambias","cambia","cambiamos","cambian","cambié",
    "cambió","cambiaron","cambiaba","cambiaban","cambie","cambien","cambiará","cambiaría",
    "ayudar","ayudando","ayudado","ayudo","ayudas","ayuda","ayudamos","ayudan","ayudé","ayudó",
    "ayudaron","ayudaba","ayudaban","ayude","ayuden","ayudará","ayudaría",
    "abrir","abriendo","abierto","abro","abres","abre","abrimos","abren","abrí","abrió","abrieron",
    "abría","abrían","abra","abran","abrirá","abriría",
    "cerrar","cerrando","cerrado","cierro","cierras","cierra","cerramos","cierran","cerré","cerró",
    "cerraron","cerraba","cerraban","cierre","cierren","cerrará","cerraría",
    "escribir","escribiendo","escrito","escribo","escribes","escribe","escribimos","escriben",
    "escribí","escribió","escribieron","escribía","escribían","escriba","escriban","escribirá",
    "leer","leyendo","leído","leo","lees","lee","leemos","leen","leí","leíste","leyó","leyeron",
    "leía","leíamos","leían","lea","leas","lean","leerá","leería",
    "escuchar","escuchando","escuchado","escucho","escuchas","escucha","escuchamos","escuchan",
    "escuché","escuchó","escucharon","escuchaba","escuchaban","escuche","escuchen","escuchará",
    "mirar","mirando","mirado","miro","miras","mira","miramos","miran","miré","miró","miraron",
    "miraba","miraban","mire","miren","mirará","miraría",
    "tocar","tocando","tocado","toco","tocas","toca","tocamos","tocan","toqué","tocó","tocaron",
    "tocaba","tocaban","toque","toquen","tocará","tocaría",
    "sentir","sintiendo","sentido","siento","sientes","siente","sentimos","sienten","sentí",
    "sintió","sintieron","sentía","sentían","sienta","sientan","sentirá","sentiría",
    "conocer","conociendo","conocido","conozco","conoces","conoce","conocemos","conocen","conocí",
    "conociste","conoció","conocieron","conocía","conocían","conozca","conozcan","conocerá",
    "cansar","cansando","cansado","canso","cansas","cansa","cansamos","cansan","cansé","cansó",
    "cansaron","cansaba","cansaban","canse","cansen",
    "necesitar","necesitando","necesitado","necesito","necesitas","necesita","necesitamos",
    "necesitan","necesité","necesitó","necesitaron","necesitaba","necesitaban","necesite",
    "necesiten","necesitará","necesitaría",
    "importar","importando","importado","importa","importan","importó","importaron","importaba",
    "importaban","importe","importen","importará",
    "significar","significando","significado","significa","significan","significó","significaron",
    "significaba","significaban","signifique","signifiquen","significará",
    "explicar","explicando","explicado","explico","explicas","explica","explicamos","explican",
    "expliqué","explicó","explicaron","explicaba","explicaban","explique","expliquen","explicará",
    "reunir","reuniendo","reunido","reúno","reúnes","reúne","reunimos","reúnen","reuní","reunió",
    "reunieron","reunía","reunían","reúna","reúnan","reunirá",
    "invitar","invitando","invitado","invito","invitas","invita","invitamos","invitan","invité",
    "invitó","invitaron","invitaba","invitaban","invite","inviten","invitará",
    "descubrir","descubriendo","descubierto","descubro","descubres","descubre","descubrimos",
    "descubren","descubrí","descubrió","descubrieron","descubría","descubrían","descubra",
    "descubran","descubrirá",
    "ocurrir","ocurriendo","ocurrido","ocurre","ocurren","ocurrió","ocurrieron","ocurría",
    "ocurrían","ocurra","ocurran","ocurrirá",
    "resultar","resultando","resultado","resulta","resultan","resultó","resultaron","resultaba",
    "resultaban","resulte","resulten","resultará","resultaría",
    "considerar","considerando","considerado","considero","consideras","considera","consideramos",
    "consideran","consideré","consideró","consideraron","consideraba","consideraban","considere",
    "consideren","considerará","consideraría",
    "sugerir","sugiriendo","sugerido","sugiero","sugieres","sugiere","sugerimos","sugieren",
    "sugerí","sugirió","sugirieron","sugería","sugerían","sugiera","sugieran","sugerirá",
    "reconocer","reconociendo","reconocido","reconozco","reconoces","reconoce","reconocemos",
    "reconocen","reconocí","reconoció","reconocieron","reconocía","reconocían","reconozca",
    "reconozcan","reconocerá",
    "publicar","publicando","publicado","publico","publicas","publica","publicamos","publican",
    "publiqué","publicó","publicaron","publicaba","publicaban","publique","publiquen","publicará",
    "utilizar","utilizando","utilizado","utilizo","utilizas","utiliza","utilizamos","utilizan",
    "utilicé","utilizó","utilizaron","utilizaba","utilizaban","utilice","utilicen","utilizará",
    "provocar","provocando","provocado","provoco","provocas","provoca","provocamos","provocan",
    "provoqué","provocó","provocaron","provocaba","provocaban","provoque","provoquen","provocará",
    // Common connectors + discourse markers
    "sobretodo","incluso","aparte","respecto","respecto a","cerca","lejos","dentro","fuera",
    "arriba","abajo","adelante","atrás","alrededor","junto","juntos","juntas","separado","separada",
    "según","conforme","excepto","salvo","mediante","respecto","tras","salvo","junto","tanto",
    "tanta","tantos","tantas","cuánto","cuánta","cuántos","cuántas","alguien","algo","cualquier",
    "cualquiera","varios","varias","demás","mismo","misma","mismos","mismas","misma","cual","cuales",
    // Adverbs of manner/frequency (extended)
    "rápidamente","lentamente","cuidadosamente","fácilmente","difícilmente","claramente",
    "obviamente","posiblemente","probablemente","seguramente","especialmente","generalmente",
    "normalmente","habitualmente","frecuentemente","regularmente","ocasionalmente","raramente",
    "prácticamente","perfectamente","aproximadamente","completamente","totalmente","absolutamente",
    "realmente","verdaderamente","efectivamente","evidentemente","precisamente",
    // Common state (adjective) — universal
    "importante","importantes","posible","posibles","imposible","imposibles","difícil","difíciles",
    "fácil","fáciles","real","reales","claro","clara","claros","claras","cierto","cierta","seguro",
    "segura","principal","principales","general","generales","especial","especiales","normal",
    "normales","natural","naturales","personal","personales","verdadero","verdadera","largos",
    "cortas","completo","completa","exacto","exacta","concreto","concreta","específico","específica",
    "único","única","únicos","únicas",
  ]),
  French: new Set([
    // articles / determiners
    "le","la","les","un","une","des","du","au","aux","l","d",
    // pronouns
    "je","j","tu","il","elle","on","nous","vous","ils","elles","me","te","se","lui",
    "leur","y","en","moi","toi","soi","eux","mon","ma","mes","ton","ta","tes","son","sa",
    "ses","notre","nos","votre","vos","leurs","ce","cet","cette","ces","celui","celle",
    "ceux","celles",
    // prepositions
    "à","de","chez","dans","sur","sous","avec","sans","pour","contre","par","vers",
    "entre","avant","après","depuis","pendant","malgré","selon","envers","parmi",
    // conjunctions / connectives
    "et","ou","mais","donc","ni","car","si","que","qui","comme","quand","parce","lorsque",
    "puisque","tandis","alors","ainsi","aussi","cependant","toutefois","néanmoins",
    // negation / affirmation / demonstratives
    "ne","pas","plus","point","jamais","rien","personne","aucun","aucune",
    "non","oui","si","très","aussi","encore","déjà","assez","trop","beaucoup","peu",
    "quoi","où","comment","pourquoi","combien","quel","quelle","quels","quelles",
    "ceci","cela","ça",
    // être
    "être","étant","été","suis","es","est","sommes","êtes","sont","étais","était","étaient",
    "étions","étiez","fus","fut","fûmes","fûtes","furent","serai","seras","sera","serons",
    "serez","seront","serais","serait","serions","seriez","seraient","sois","soit","soyons",
    "soyez","soient",
    // avoir
    "avoir","ayant","eu","ai","as","a","avons","avez","ont","avais","avait","avions","aviez",
    "avaient","eus","eut","eûmes","eûtes","eurent","aurai","auras","aura","aurons","aurez",
    "auront","aurais","aurait","aurions","auriez","auraient","aie","ait","ayons","ayez","aient",
    // faire
    "faire","faisant","fait","fais","fais","fait","faisons","faites","font","faisais","faisait",
    "faisions","faisaient","fis","fit","fîmes","fîtes","firent","ferai","feras","fera","ferons",
    "ferez","feront","ferais","ferait","ferions","feriez","feraient","fasse","fasses","fassions",
    "fassiez","fassent",
    // aller
    "aller","allant","allé","allée","allés","allées","vais","vas","va","allons","allez","vont",
    "allais","allait","allions","alliez","allaient","irai","iras","ira","irons","irez","iront",
    "irais","irait","irions","iriez","iraient","aille","ailles","allions","aillent",
    // pouvoir
    "pouvoir","pouvant","pu","peux","peut","pouvons","pouvez","peuvent","pouvais","pouvait",
    "pouvions","pouviez","pouvaient","pus","put","pûmes","pûtes","purent","pourrai","pourras",
    "pourra","pourrons","pourrez","pourront","pourrais","pourrait","pourrions","pourriez",
    "pourraient","puisse","puisses","puissions","puissent",
    // vouloir
    "vouloir","voulant","voulu","veux","veut","voulons","voulez","veulent","voulais","voulait",
    "voulions","voulaient","voulus","voulut","voulurent","voudrai","voudras","voudra","voudrons",
    "voudrez","voudront","voudrais","voudrait","voudrions","voudraient","veuille","veuilles",
    "veuillent",
    // savoir
    "savoir","sachant","su","sais","sait","savons","savez","savent","savais","savait","savions",
    "saviez","savaient","sus","sut","surent","saurai","sauras","saura","saurons","sauront",
    "saurais","saurait","sache","saches","sachions","sachent",
    // devoir
    "devoir","devant","dû","due","dus","dues","dois","doit","devons","devez","doivent",
    "devais","devait","devions","devaient","dus","dut","durent","devrai","devras","devra",
    "devrons","devront","devrais","devrait","doive","doives","doivent",
    // dire
    "dire","disant","dit","dis","dit","disons","dites","disent","disais","disait","disions",
    "disaient","dis","dit","dîmes","dîtes","dirent","dirai","diras","dira","dirons","direz",
    "diront","dirais","dirait","dise","dises","disions","disent",
    // voir
    "voir","voyant","vu","vois","voit","voyons","voyez","voient","voyais","voyait","voyions",
    "voyaient","vis","vit","virent","verrai","verras","verra","verrons","verront","verrais",
    "verrait","voie","voies","voient",
    // venir / prendre / mettre / donner / passer
    "venir","venant","venu","viens","vient","venons","venez","viennent","venais","venait",
    "venions","venaient","vins","vint","vinrent","viendrai","viendras","viendra","viendrons",
    "viendront","viendrais","viendrait","vienne","viennent",
    "prendre","prenant","pris","prends","prend","prenons","prenez","prennent","prenais",
    "prenait","prenions","prenaient","pris","prit","prirent","prendrai","prendras","prendra",
    "prendrons","prendront","prendrais","prendrait","prenne","prennent",
    "mettre","mettant","mis","mets","met","mettons","mettez","mettent","mettais","mettait",
    "mettions","mettaient","mis","mit","mirent","mettrai","mettras","mettra","mettrait","mettent","mette",
    "donner","donnant","donné","donne","donnes","donnons","donnez","donnent","donnais",
    "donnait","donnions","donnaient","donnai","donna","donnèrent","donnerai","donnerait","donnera",
    "passer","passant","passé","passe","passes","passons","passez","passent","passais",
    "passait","passions","passaient","passai","passa","passèrent","passerai","passera",
    // parler / penser / regarder / trouver / entendre / arriver / partir / rester
    "parler","parlant","parlé","parle","parles","parlons","parlez","parlent","parlais",
    "parlait","parlions","parlaient","parlai","parla","parlèrent","parlerai","parlera","parlerais",
    "penser","pensant","pensé","pense","penses","pensons","pensez","pensent","pensais",
    "pensait","pensions","pensaient","pensa","pensèrent","penserai","pensera",
    "regarder","regardant","regardé","regarde","regardes","regardons","regardez","regardent",
    "regardais","regardait","regardions","regardaient","regarderai","regardera",
    "trouver","trouvant","trouvé","trouve","trouves","trouvons","trouvez","trouvent","trouvais",
    "trouvait","trouvions","trouvaient","trouvai","trouva","trouvèrent","trouverai","trouvera",
    "entendre","entendant","entendu","entends","entend","entendons","entendez","entendent",
    "entendais","entendait","entendions","entendaient","entendrai","entendra",
    "arriver","arrivant","arrivé","arrive","arrives","arrivons","arrivez","arrivent","arrivais",
    "arrivait","arrivions","arrivaient","arrivai","arriva","arrivèrent","arriverai","arrivera",
    "partir","partant","parti","pars","part","partons","partez","partent","partais","partait",
    "partions","partaient","partis","partit","partirent","partirai","partira",
    "rester","restant","resté","reste","restes","restons","restez","restent","restais",
    "restait","restions","restaient","resta","restèrent","resterai","restera",
    // devenir / connaître / croire / comprendre / lire / écrire / suivre / vivre
    "devenir","devenant","devenu","deviens","devient","devenons","devenez","deviennent",
    "devenais","devenait","devenions","devenaient","devins","devint","devinrent","deviendrai",
    "deviendra","devienne","deviennent",
    "connaître","connaissant","connu","connais","connaît","connaissons","connaissez",
    "connaissent","connaissais","connaissait","connaissions","connaissaient","connus","connut",
    "connurent","connaîtrai","connaîtra",
    "croire","croyant","cru","crois","croit","croyons","croyez","croient","croyais","croyait",
    "croyions","croyaient","crus","crut","crurent","croirai","croira","croie","croient",
    "comprendre","comprenant","compris","comprends","comprend","comprenons","comprenez",
    "comprennent","comprenais","comprenait","comprenions","comprenaient","compris","comprit",
    "comprirent","comprendrai","comprendra","comprenne","comprennent",
    "lire","lisant","lu","lis","lit","lisons","lisez","lisent","lisais","lisait","lisions",
    "lisaient","lus","lut","lurent","lirai","lira",
    "écrire","écrivant","écrit","écris","écrit","écrivons","écrivez","écrivent","écrivais",
    "écrivait","écrivions","écrivaient","écrivis","écrivit","écrivirent","écrirai","écrira",
    "suivre","suivant","suivi","suis","suit","suivons","suivez","suivent","suivais","suivait",
    "suivions","suivaient","suivis","suivit","suivirent","suivrai","suivra",
    "vivre","vivant","vécu","vis","vit","vivons","vivez","vivent","vivais","vivait","vivions",
    "vivaient","vécus","vécut","vécurent","vivrai","vivra",
    // reflexive markers
    "me","te","se","nous","vous",
    // ultra-common adverbs / adjectives / quantifiers
    "tout","toute","tous","toutes","autre","autres","chaque","plusieurs","certain","certaine",
    "certains","certaines","quelques","quelque","même","mêmes","tel","telle","tels","telles",
    "bien","mal","mieux","pire","alors","ici","là","là-bas","maintenant","ensuite","puis",
    "avant","après","aujourd","hier","demain","tôt","tard","bientôt","toujours","jamais",
    "encore","déjà","presque","souvent","parfois","surtout","seulement","enfin","d'abord",
    // universal adjectives (non-topical)
    "grand","grande","grands","grandes","petit","petite","petits","petites","bon","bonne",
    "bons","bonnes","mauvais","mauvaise","mauvaises","nouveau","nouvelle","nouveaux","nouvelles",
    "vieux","vieille","vieilles","jeune","jeunes","haut","haute","hauts","hautes","bas","basse",
    "basses","premier","première","premiers","premières","dernier","dernière","derniers",
    "dernières","prochain","prochaine","actuel","actuelle","important","importante",
    "importants","importantes","possible","impossible","difficile","facile","réel","réelle",
    "clair","claire","sûr","sûre","principal","principale","général","générale","spécial",
    "spéciale","normal","normale","naturel","naturelle","personnel","personnelle","long",
    "longue","courts","courte","large","complet","complète","exact","exacte",
    // universal nouns (non-topical structural / relational)
    "chose","choses","façon","façons","manière","manières","sorte","sortes","type","types",
    "partie","parties","point","points","lieu","lieux","endroit","endroits","moment","moments",
    "heure","heures","jour","jours","semaine","semaines","mois","année","années","temps",
    "fois","nombre","nombres","cas","raison","raisons","idée","idées","mot","mots","nom","noms",
    "exemple","exemples","vie","vies","personne","personnes","monde","gens","homme","hommes",
    "femme","femmes","groupe","groupes","fin","milieu","début","processus","résultat","résultats",
    "effet","effets","cause","causes","situation","situations",
    // numbers
    "zéro","un","une","deux","trois","quatre","cinq","six","sept","huit","neuf","dix",
    "onze","douze","treize","quatorze","quinze","seize","vingt","trente","quarante",
    "cinquante","soixante","soixante-dix","quatre-vingts","quatre-vingt","quatre-vingt-dix",
    "cent","cents","mille","milliers","million","millions","milliard",
    "premier","première","deuxième","troisième","quatrième","cinquième","sixième","septième",
    "huitième","neuvième","dixième",
  ]),
};

// English basics — used by the audit to whitelist English strings that
// appear as ANSWER TEXT in comprehension MC (vocab_translation,
// reading_comprehension, dialogue_comprehension). Without this, the
// audit rejects legit English answers like "Hello", "Goodbye",
// "See you later" as "off-vocab target-language words". Kept broad
// enough to cover any A1/A2 comprehension gloss.
STOPWORDS.English = new Set([
  // articles / pronouns / possessives
  "a","an","the","i","me","my","mine","myself","you","your","yours","yourself","yourselves",
  "he","him","his","himself","she","her","hers","herself","it","its","itself","we","us","our",
  "ours","ourselves","they","them","their","theirs","themselves","this","that","these","those",
  "who","whom","whose","which","what","where","when","why","how",
  // be / have / do / modals (all common forms)
  "am","is","are","was","were","be","been","being","have","has","had","having","do","does","did",
  "done","doing","can","could","will","would","shall","should","may","might","must","ought",
  // basic verbs (base + common past)
  "go","goes","went","gone","going","come","comes","came","coming","take","takes","took","taken",
  "taking","get","gets","got","gotten","getting","give","gives","gave","given","giving","say","says",
  "said","saying","tell","tells","told","telling","make","makes","made","making","know","knows","knew",
  "known","knowing","think","thinks","thought","thinking","see","sees","saw","seen","seeing","want",
  "wants","wanted","wanting","need","needs","needed","like","likes","liked","liking","live","lives",
  "lived","living","work","works","worked","working","use","uses","used","using","find","finds","found",
  "look","looks","looked","looking","feel","feels","felt","feeling","ask","asks","asked","asking",
  "tell","try","tries","tried","trying","call","calls","called","calling","start","starts","started",
  "starting","stop","stops","stopped","hear","hears","heard","hearing","meet","meets","met","meeting",
  "greet","greets","greeted","greeting","greetings","introduce","introduces","introduced","introducing",
  "learn","learns","learned","learning","speak","speaks","spoke","spoken","speaking","talk","talks",
  "talked","talking","read","reads","reading","write","writes","wrote","written","writing","listen",
  "listens","listened","listening","help","helps","helped","helping","become","becomes","became",
  "becoming","let","lets","letting","seem","seems","seemed","understand","understands","understood",
  "understanding","reply","replies","replied","replying","respond","responds","responded","responding",
  "answer","answers","answered","answering","play","plays","played","playing","stay","stays","stayed",
  // basic connectors / conjunctions / prepositions / question words
  "and","or","but","so","if","because","while","when","as","then","than","also","too","not","no","yes",
  "for","to","from","of","in","on","at","by","with","without","about","over","under","up","down","out",
  "off","into","onto","between","among","around","near","before","after","during","through","across",
  "until","since","above","below","against","toward","towards","upon",
  // adverbs / adjectives / quantifiers (universal, non-topical)
  "very","just","only","still","already","again","almost","enough","even","ever","never","always",
  "sometimes","often","usually","rarely","seldom","really","quite","pretty","much","many","more","most",
  "less","least","few","several","all","any","some","every","each","both","either","neither","own",
  "same","different","other","another","new","old","first","last","next","previous","final","early",
  "late","good","bad","great","little","big","small","large","huge","tiny","long","short","high","low",
  "wide","narrow","deep","shallow","strong","weak","hard","easy","difficult","simple","complex","fast",
  "slow","hot","cold","warm","cool","clean","dirty","full","empty","open","closed","free","busy","right",
  "wrong","true","false","real","fake","important","special","basic","normal","strange","common","fine",
  "well","better","worse","best","worst","happy","sad","angry","tired","excited","sure","clear",
  // basic nouns (topical-neutral)
  "thing","things","way","ways","kind","kinds","type","types","part","parts","piece","pieces","name",
  "names","word","words","phrase","phrases","sentence","sentences","example","examples","question",
  "questions","answer","answers","form","forms","idea","ideas","reason","reasons","point","points",
  "case","cases","fact","facts","information","time","times","moment","moments","day","days","week",
  "weeks","month","months","year","years","hour","hours","minute","minutes","second","seconds","today",
  "yesterday","tomorrow","morning","afternoon","evening","night","noon","midnight","weekend","weekday",
  "person","people","man","men","woman","women","child","children","boy","boys","girl","girls","friend",
  "friends","stranger","group","groups","family","families","place","places","home","homes","house",
  "houses","world","worlds","life","lives","language","languages","country","countries","city","cities",
  "town","towns","street","streets","area","areas","situation","situations","conversation","conversations",
  "dialogue","dialogues","message","messages","response","responses","greeting","introduction",
  // meet/greet vocabulary (unavoidable in any Greetings lesson's English answers)
  "hello","hi","hey","goodbye","bye","farewell","welcome","please","sorry","thanks","thank","excuse",
  "pardon","cheers","regards","salutations","meet","meeting","pleased","pleasure","nice","glad","fine",
  "great","okay","alright","yes","no","maybe","perhaps","sure","definitely","absolutely",
  "sir","ma","madam","mister","miss","mrs","teacher","professor","student","neighbor","colleague",
  "acquaintance",
  // numbers
  "zero","one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve",
  "thirteen","fourteen","fifteen","sixteen","seventeen","eighteen","nineteen","twenty","thirty","forty",
  "fifty","sixty","seventy","eighty","ninety","hundred","thousand","million","billion","first","second",
  "third","fourth","fifth","sixth","seventh","eighth","ninth","tenth","last","half","quarter","dozen",
  // days / months
  "monday","tuesday","wednesday","thursday","friday","saturday","sunday",
  "january","february","march","april","may","june","july","august","september","october","november",
  "december","spring","summer","autumn","fall","winter",
  // formal / informal register (common in translation answers)
  "formal","informal","polite","casual","standard",
  // === EXPANDED CONTENT VOCAB — top-1500-ish English words ===
  // Body
  "body","head","hair","face","eye","eyes","ear","ears","nose","mouth","teeth","tooth","tongue",
  "lip","lips","neck","shoulder","shoulders","arm","arms","hand","hands","finger","fingers","leg",
  "legs","foot","feet","toe","toes","back","chest","stomach","heart","skin","blood","brain",
  // Family
  "father","mother","dad","mom","mum","parent","parents","brother","sister","brothers","sisters",
  "son","daughter","children","kid","kids","grandfather","grandmother","grandparents","uncle",
  "aunt","cousin","cousins","nephew","niece","husband","wife","boyfriend","girlfriend","partner",
  "family","families","relative","relatives",
  // Places
  "home","house","room","kitchen","bathroom","bedroom","garden","school","university","college",
  "office","shop","store","market","restaurant","cafe","cafeteria","bar","bank","hospital",
  "airport","station","park","city","town","village","country","street","road","square","church",
  "museum","library","gym","beach","mountain","river","sea","ocean","forest","building","hotel",
  "apartment","flat",
  // Work / studies
  "job","jobs","work","business","company","boss","colleague","colleagues","employee","employees",
  "meeting","meetings","project","projects","client","clients","customer","customers","service",
  "task","tasks","report","reports","budget","salary","contract","interview","conference",
  "conferences","career","careers","profession","professional","worker","workers",
  // Money
  "money","dollar","dollars","euro","euros","price","prices","cost","costs","fee","fees","bill",
  "bills","account","accounts","card","cards","credit","cash","currency","coin","coins","change",
  "receipt","payment","payments","income","savings","discount","offer","sale","sales","purchase",
  // Communication
  "phone","phones","mobile","cellphone","cell","message","messages","call","calls","email","emails",
  "letter","letters","conversation","conversations","talk","talks","reply","replies","response",
  "responses","question","questions","word","words","phrase","phrases","sentence","sentences",
  "speech","speeches","news","article","articles","magazine","newspaper","book","books","paper",
  "papers","story","stories","report","tale",
  // Objects
  "chair","chairs","table","tables","bed","beds","sofa","couch","door","doors","window","windows",
  "wall","walls","floor","ceiling","light","lights","clothes","clothing","shoe","shoes","glasses",
  "watch","watches","key","keys","bag","bags","suitcase","car","cars","bus","buses","train","trains",
  "plane","planes","bike","bicycle","motorcycle","computer","computers","laptop","tablet","camera",
  "cameras","photo","photos","photograph","picture","pictures",
  // Food / drink (universal daily)
  "water","coffee","tea","milk","bread","food","meal","meals","dinner","breakfast","lunch","plate",
  "plates","glass","cup","cups","wine","beer","juice","fruit","vegetable","vegetables","meat",
  "fish","cheese","butter","salt","sugar","chocolate",
  // Time (extended)
  "moment","moments","period","periods","stage","phase","era","decade","century","dawn","dusk",
  "sunset","sunrise","tonight","weekend","weekday","holiday","holidays","vacation",
  // Feelings
  "happy","sad","angry","tired","excited","proud","embarrassed","jealous","nervous","calm",
  "relaxed","worried","scared","surprised","content","upset","confused","frustrated","bored",
  "annoyed","satisfied","disappointed","confident","hopeful","hopeless","ashamed",
  // Descriptive adjectives (non-topical)
  "beautiful","ugly","pretty","handsome","attractive","cute","charming","boring","interesting",
  "funny","serious","strange","weird","normal","peculiar","exciting","amazing","incredible",
  "wonderful","fantastic","awful","terrible","horrible","great","excellent","brilliant","perfect",
  "smart","clever","intelligent","stupid","silly","wise","kind","mean","cruel","gentle","polite",
  "rude","friendly","shy","brave","cowardly","honest","dishonest","fair","unfair","lucky","unlucky",
  "safe","dangerous","clean","dirty","tidy","messy","full","empty","open","closed","locked","free",
  "busy","available","possible","impossible","difficult","easy","simple","complex","complicated",
  "hard","soft","strong","weak","fresh","stale","new","old","modern","ancient","traditional",
  "quick","fast","slow","early","late","punctual","cheap","expensive","valuable","worthless",
  "cold","hot","warm","cool","freezing","boiling","dry","wet","damp","humid","clear","cloudy",
  "sunny","rainy","stormy","windy","calm","gentle","rough","smooth","sharp","blunt","heavy","light",
  "hard","soft","thick","thin","narrow","wide","tall","short","tiny","huge","enormous","massive",
  "small","big","large","little",
  // States / positions
  "here","there","everywhere","nowhere","somewhere","inside","outside","above","below","upstairs",
  "downstairs","north","south","east","west","left","right","forward","backward","backwards","away",
  "close","far","near","apart","together","alone","separately",
  // Common verbs — extended
  "sleep","slept","sleeping","wake","waking","woke","woken","eat","eating","ate","eaten","drink",
  "drinking","drank","drunk","cook","cooked","cooking","buy","buying","bought","sell","selling",
  "sold","pay","paying","paid","spend","spent","spending","earn","earning","earned","save","saved",
  "saving","waste","wasted","wasting","open","opened","opening","close","closed","closing","start",
  "started","starting","stop","stopped","stopping","begin","began","begun","beginning","finish",
  "finished","finishing","continue","continued","continuing","end","ended","ending","enter","entered",
  "entering","leave","left","leaving","exit","exited","exiting","arrive","arrived","arriving",
  "depart","departed","departing","travel","traveled","travelled","traveling","travelling","visit",
  "visited","visiting","move","moved","moving","stay","stayed","staying","return","returned",
  "returning","walk","walked","walking","run","ran","running","drive","drove","driven","driving",
  "ride","rode","ridden","riding","fly","flew","flown","flying","swim","swam","swum","swimming",
  "dance","danced","dancing","sing","sang","sung","singing","play","played","playing","laugh",
  "laughed","laughing","cry","cried","crying","smile","smiled","smiling","yell","shout","shouted",
  "shouting","whisper","whispered","whispering","think","thought","thinking","believe","believed",
  "believing","doubt","doubted","doubting","remember","remembered","remembering","forget","forgot",
  "forgotten","forgetting","imagine","imagined","imagining","decide","decided","deciding","choose",
  "chose","chosen","choosing","prefer","preferred","preferring","hope","hoped","hoping","wish",
  "wished","wishing","expect","expected","expecting","need","needed","needing","want","wanted",
  "wanting","love","loved","loving","hate","hated","hating","enjoy","enjoyed","enjoying","suffer",
  "suffered","suffering","live","lived","living","die","died","dying","born","grow","grew","grown",
  "growing","raise","raised","raising","learn","learned","learnt","learning","teach","taught",
  "teaching","study","studied","studying","practice","practiced","practicing","train","trained",
  "training","understand","understood","understanding","explain","explained","explaining","show",
  "showed","shown","showing","describe","described","describing","introduce","introduced",
  "introducing","present","presented","presenting","offer","offered","offering","accept","accepted",
  "accepting","refuse","refused","refusing","reject","rejected","rejecting","invite","invited",
  "inviting","ask","asked","asking","answer","answered","answering","reply","replied","replying",
  "respond","responded","responding","suggest","suggested","suggesting","recommend","recommended",
  "recommending","promise","promised","promising","threaten","threatened","threatening","warn",
  "warned","warning","help","helped","helping","assist","assisted","assisting","serve","served",
  "serving","protect","protected","protecting","attack","attacked","attacking","defend","defended",
  "defending","fight","fought","fighting","win","won","winning","lose","losing","succeed",
  "succeeded","succeeding","fail","failed","failing","try","tried","trying","attempt","attempted",
  "attempting","manage","managed","managing","achieve","achieved","achieving","complete","completed",
  "completing","solve","solved","solving","fix","fixed","fixing","break","broke","broken","breaking",
  "build","built","building","create","created","creating","destroy","destroyed","destroying",
  "make","making","made","produce","produced","producing","develop","developed","developing",
  "improve","improved","improving","reduce","reduced","reducing","increase","increased","increasing",
  "raise","raised","raising","lower","lowered","lowering","change","changed","changing","adapt",
  "adapted","adapting","adjust","adjusted","adjusting","control","controlled","controlling","manage",
  "avoid","avoided","avoiding","allow","allowed","allowing","forbid","forbade","forbidden",
  "forbidding","prevent","prevented","preventing","cause","caused","causing","affect","affected",
  "affecting","influence","influenced","influencing","matter","mattered","mattering","depend",
  "depended","depending","involve","involved","involving","include","included","including","exclude",
  "excluded","excluding","contain","contained","containing","consist","consisted","consisting",
  "compare","compared","comparing","contrast","contrasted","contrasting","measure","measured",
  "measuring","count","counted","counting","calculate","calculated","calculating","estimate",
  "estimated","estimating","test","tested","testing","check","checked","checking","verify",
  "verified","verifying","confirm","confirmed","confirming","prove","proved","proven","proving",
  "publish","published","publishing","announce","announced","announcing","report","reported",
  "reporting","express","expressed","expressing","translate","translated","translating","mean",
  "meaning","meant","refer","referred","referring","note","noted","noting","point","pointed",
  "pointing","exist","existed","existing","occur","occurred","occurring","happen","happened",
  "happening","take place","result","resulted","resulting","seem","seemed","seeming","appear",
  "appeared","appearing","become","became","becoming","turn","turned","turning","remain","remained",
  "remaining","keep","kept","keeping","hold","held","holding","catch","caught","catching","throw",
  "threw","thrown","throwing","push","pushed","pushing","pull","pulled","pulling","carry","carried",
  "carrying","lift","lifted","lifting","drop","dropped","dropping","raise","reduce","fall","fell",
  "fallen","falling","rise","rose","risen","rising","climb","climbed","climbing","jump","jumped",
  "jumping","sit","sat","sitting","stand","stood","standing","lie","lay","laid","lying","lean",
  "leaned","leaning","turn","touch","touched","touching","hit","hitting","punch","kick","kicked",
  "kicking",
  // Discourse / connectors
  "although","though","however","therefore","thus","meanwhile","moreover","furthermore","besides",
  "although","otherwise","instead","rather","specifically","actually","basically","essentially",
  "generally","typically","specifically","particularly","especially","mainly","mostly","usually",
  "often","sometimes","rarely","seldom","hardly","barely","exactly","precisely","apparently",
  "obviously","clearly","perhaps","maybe","possibly","probably","definitely","certainly","surely",
  "absolutely","completely","totally","entirely","partly","partially","slightly","somewhat","fairly",
  "pretty","rather","quite",
]);

// Per-CEFR audit tuning. An exercise passes if EITHER limit is met —
// this way short exercises are held to an absolute count and long ones
// to a percentage. At C1 the vast majority of tokens in a natural
// sentence are ambient fluency vocab; only the specialty vocabulary
// (idioms, technical terms) is "taught," so percentage-based tolerance
// matters most there.
const AUDIT_TOLERANCE = {
  A1: 0,
  A2: 1,
  B1: 2,
  B2: 4,
  C1: 6,
};
const AUDIT_PCT_TOLERANCE = {
  A1: 0.00,
  A2: 0.15,
  B1: 0.25,
  B2: 0.40,
  C1: 0.55,
};
const DEFAULT_TOLERANCE = 2;
const DEFAULT_PCT_TOLERANCE = 0.20;

// Minimum survivor ratio before the safety valve refuses to write a
// lesson. A1 stays strict; at C1 the vocab list is tiny and a few
// natural sentences will always fall outside strict tolerance — accept
// thinner writes rather than losing the lesson entirely.
const SAFETY_VALVE_MIN_RATIO = {
  A1: 0.50,
  A2: 0.45,
  B1: 0.40,
  B2: 0.35,
  C1: 0.30,
};
const DEFAULT_SAFETY_VALVE_RATIO = 0.40;

// The system prompt is deliberately verbose and STABLE. Every request in
// the batch reuses the exact same bytes here so it stays cache-hit for
// the whole run. Do NOT interpolate anything per-lesson into this string.
const SYSTEM_PROMPT = `You are an expert language-curriculum author. You generate exercises for a structured language-learning course.

## The course structure

Every section has these 9 lessons in this order:
  1. Vocabulary — introduces the bulk of new vocab for the section
  2. Grammar — sentence patterns using lesson-1 vocab
  3. Phrases & Conversation — useful phrases built from lesson-1 vocab
  4. Listening — practice ONLY, uses vocab from lessons 1–3
  5. Speaking — practice ONLY, uses vocab from lessons 1–3
  6. Reading & Comprehension — practice ONLY, uses vocab from lessons 1–3
  7. Writing — practice ONLY, uses vocab from lessons 1–3
  8. Conversation Practice — dialogue-based, uses vocab from lessons 1–3
  9. Section Test — 10 mixed-skill questions covering the whole section

Lessons 4–8 introduce NO new vocabulary. Every word in an exercise for
lessons 4–9 must be in the "allowed_vocab" list you were given.

## Hard constraints

1. Return ONE JSON object with a single "exercises" field — an array of exercises.
2. Every exercise MUST use ONLY vocabulary from the provided "allowed_vocab" list, PLUS the language's basic function words (articles, pronouns, prepositions, common conjunctions, common conjugated forms of ser/estar/avoir/être/etc.). Basic function words don't need to be listed.
3. NEVER introduce vocabulary from a topic outside the given "section_topic". If topic=Greetings, no food/colors/family/jobs. If topic=Numbers, no colors or family.
4. NEVER use vocabulary from a higher CEFR level than the given "cefr_level". A1 must be reachable to a total beginner.
5. All strings are plain UTF-8. Use the target language's real diacritics (¿ á é í ó ú ñ ü ç à â é è ê î ï ô œ û etc.).

## Difficulty scaling across CEFR levels

- A1: 3–7 word sentences, present tense only. Instructions in ENGLISH.
- A2: 5–10 word sentences, present + basic past. Instructions in ENGLISH.
- B1: 8–14 words, past/future/conditional. Instructions MOSTLY in English; where a target-language instruction reads naturally at this level, use it.
- B2: 12–20 words, subjunctive and idiomatic phrasing allowed. Instructions in the TARGET LANGUAGE where they would be natural to a B2 learner; English fine for MC option prompts.
- C1: 15–30 words, native-level nuance, subordinate clauses, register variation. Instructions in the TARGET LANGUAGE throughout.

## Exercise types & purposes

Each entry in "exercise_mix" has a "type" (the DB shape) and a "purpose" (what it's testing). Interpret them together:

Types:
- multiple_choice — MC with 3 wrong answers. Choose type when the answer space is small.
- fill_blank — target-language sentence with "___" for the tested word. correct_answer is the missing word; wrong_answers are 3 plausible substitutes from allowed_vocab.
- listening — question is the TARGET-language phrase (played via TTS to the learner); correct_answer is the English translation; wrong_answers are 3 plausible English mistranslations.
- speaking — question is an English/target-language PROMPT telling the learner what to say/write; correct_answer is the target-language phrase they should produce; wrong_answers MUST be [].

Purposes (what to test):
- vocab_translation — MC: "What does X mean?" / "How do you say X?"
- vocab_in_sentence — fill_blank testing a single vocab word inside a natural sentence
- grammar_pattern — MC testing a specific grammatical choice (conjugation, agreement, tense)
- grammar_conjugation — fill_blank testing verb form / agreement / pronoun choice
- phrase_usage — MC testing which phrase fits a situation
- phrase_completion — fill_blank testing a missing word in a fixed phrase
- reading_comprehension — MC where the "question" contains a short target-language passage (2–4 sentences) plus an English or target-language question about it; options are answer choices
- listening — the TTS-played phrase should be a natural, complete sentence at the current CEFR level (NOT a bare vocab item)
- speaking — the learner is asked to say a real utterance (sentence, response, request) — not a single word
- writing_response — speaking-shaped exercise where the "question" is an English or target-language prompt asking for a WRITTEN response, and correct_answer is the full-sentence written response
- dialogue_comprehension — MC on the specific dialogue in the lesson (question refers to what someone said, what happened, or what would happen next)
- dialogue_response — speaking prompt asking the learner "How would you respond to X in this conversation?" — correct_answer is a natural target-language reply the character would give

## Object shape (every exercise)

{
  "type": "multiple_choice" | "fill_blank" | "listening" | "speaking",
  "question": "...",
  "correct_answer": "...",
  "wrong_answers": ["...", "...", "..."],   // or [] for speaking/writing_response
  "translation": "English translation of correct_answer, or null for listening"
}

Return exactly the requested exercise counts, in the order the mix specifies. No prose, no markdown, no commentary — just the JSON object.`;

// ---------- CLI + env ----------

function parseArgs(argv) {
  const out = {
    dryRun: true,
    live: false,
    language: null,
    level: null,
    section: null,
    lessonLimit: Infinity,
    resume: true,
    reset: false,
    verbose: false,
    sleepMs: 400,
  };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--dry-run") out.dryRun = true;
    else if (a === "--live") { out.live = true; out.dryRun = false; }
    else if (a === "--language") out.language = String(argv[++i] ?? "").toLowerCase();
    else if (a === "--level") out.level = String(argv[++i] ?? "").toUpperCase();
    else if (a === "--section") out.section = String(argv[++i] ?? "").toLowerCase();
    else if (a === "--lesson-limit") out.lessonLimit = Number(argv[++i]);
    else if (a === "--resume") out.resume = true;
    else if (a === "--no-resume") out.resume = false;
    else if (a === "--reset") out.reset = true;
    else if (a === "--verbose") out.verbose = true;
    else if (a === "--sleep-ms") out.sleepMs = Number(argv[++i]);
    else if (a === "--help" || a === "-h") { printUsage(); process.exit(0); }
    else { console.error(`unknown flag: ${a}`); printUsage(); process.exit(2); }
  }
  return out;
}

function printUsage() {
  console.error(`usage: node --env-file=.env.local scripts/regenerate-exercises.mjs [flags]
see the top of the script for the full flag list.`);
}

function requireEnv(name) {
  const v = process.env[name];
  if (!v) throw new Error(`missing required env var: ${name}`);
  return v;
}

// ---------- HTTP helpers (retry with backoff on 429/5xx) ----------

async function withRetry(label, fn, { maxAttempts = 5, baseDelayMs = 800 } = {}) {
  let lastErr;
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (err) {
      lastErr = err;
      const retryable = err?.retryable === true;
      if (!retryable || attempt === maxAttempts) throw err;
      const delay = baseDelayMs * Math.pow(2, attempt - 1);
      console.error(`[retry] ${label} attempt ${attempt} failed (${err.message}); waiting ${delay}ms`);
      await new Promise((r) => setTimeout(r, delay));
    }
  }
  throw lastErr;
}

function markRetryable(err) {
  err.retryable = true;
  return err;
}

// ---------- Supabase (raw REST — no client dep) ----------

function makeSupabase({ url, key }) {
  const base = url.replace(/\/$/, "");
  const headers = {
    apikey: key,
    Authorization: `Bearer ${key}`,
    "Content-Type": "application/json",
  };

  async function req(method, path, { body, prefer } = {}) {
    const res = await fetch(`${base}/rest/v1${path}`, {
      method,
      headers: { ...headers, ...(prefer ? { Prefer: prefer } : {}) },
      body: body ? JSON.stringify(body) : undefined,
    });
    if (!res.ok) {
      const text = await res.text().catch(() => "");
      const err = new Error(`supabase ${method} ${path} ${res.status}: ${text.slice(0, 300)}`);
      if (res.status === 429 || res.status >= 500) markRetryable(err);
      throw err;
    }
    if (res.status === 204) return null;
    return res.json();
  }

  return {
    get: (path) => withRetry(`GET ${path}`, () => req("GET", path)),
    post: (path, body) =>
      withRetry(`POST ${path}`, () => req("POST", path, { body, prefer: "return=representation" })),
    delete: (path) => withRetry(`DELETE ${path}`, () => req("DELETE", path)),
  };
}

// ---------- Anthropic ----------

async function generateExercises({
  apiKey,
  language,
  cefrLevel,
  sectionTopic,
  lessonNumber,
  totalLessons,
  lessonType,
  allowedVocab,
  exerciseMix,
  dialogue,
}) {
  // Only attach dialogue to the payload when it exists AND the lesson
  // type actually uses it (conversation lessons). Attaching it to
  // every lesson would bust the cache with per-lesson data in a place
  // where the model doesn't need it.
  const payload = {
    target_language: language,
    cefr_level: cefrLevel,
    section_topic: sectionTopic,
    lesson_number: lessonNumber,
    total_lessons_in_section: totalLessons,
    lesson_type: lessonType,
    allowed_vocab: allowedVocab,
    exercise_mix: exerciseMix,
  };
  if (lessonType === "conversation" && Array.isArray(dialogue) && dialogue.length > 0) {
    payload.dialogue = dialogue;
  }
  const userPrompt = JSON.stringify(payload, null, 2);

  const body = {
    model: MODEL,
    max_tokens: 8000,
    thinking: { type: "disabled" },
    // Structured output — the API returns a message whose text is
    // guaranteed-valid JSON matching this schema.
    output_config: {
      effort: "low",
      format: {
        type: "json_schema",
        schema: {
          type: "object",
          additionalProperties: false,
          properties: {
            exercises: {
              type: "array",
              items: {
                type: "object",
                additionalProperties: false,
                properties: {
                  type: { type: "string", enum: ["multiple_choice", "fill_blank", "listening", "speaking"] },
                  question: { type: "string" },
                  correct_answer: { type: "string" },
                  wrong_answers: { type: "array", items: { type: "string" } },
                  translation: { type: ["string", "null"] },
                },
                required: ["type", "question", "correct_answer", "wrong_answers", "translation"],
              },
            },
          },
          required: ["exercises"],
        },
      },
    },
    // System prompt is cached — the exact same bytes are reused for every
    // lesson in the batch, so the first request writes the cache and every
    // subsequent request reads it. Each cache read resets the 5-min TTL,
    // so as long as the pace stays under 5 min between calls it stays hot.
    system: [
      { type: "text", text: SYSTEM_PROMPT, cache_control: { type: "ephemeral" } },
    ],
    messages: [{ role: "user", content: userPrompt }],
  };

  return withRetry(`anthropic lesson=${lessonNumber} ${lessonType}`, async () => {
    const res = await fetch(ANTHROPIC_URL, {
      method: "POST",
      headers: {
        "x-api-key": apiKey,
        "anthropic-version": "2023-06-01",
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    });
    if (!res.ok) {
      const text = await res.text().catch(() => "");
      const err = new Error(`anthropic ${res.status}: ${text.slice(0, 400)}`);
      if (res.status === 429 || res.status >= 500 || res.status === 529) markRetryable(err);
      throw err;
    }
    const json = await res.json();

    const textBlock = (json.content ?? []).find((b) => b.type === "text");
    if (!textBlock) throw new Error(`no text block in response`);

    let parsed;
    try {
      parsed = JSON.parse(textBlock.text);
    } catch {
      throw new Error(`response is not valid JSON: ${textBlock.text.slice(0, 200)}`);
    }
    if (!parsed || !Array.isArray(parsed.exercises)) {
      throw new Error(`parsed response missing exercises[]`);
    }

    return {
      exercises: parsed.exercises,
      usage: json.usage ?? null,
    };
  });
}

// ---------- progress log ----------

async function loadProgress(reset) {
  if (reset) return { completed_lessons: {}, started_at: new Date().toISOString() };
  if (!existsSync(PROGRESS_PATH)) return { completed_lessons: {}, started_at: new Date().toISOString() };
  try {
    const raw = await readFile(PROGRESS_PATH, "utf8");
    const parsed = JSON.parse(raw);
    if (!parsed.completed_lessons) parsed.completed_lessons = {};
    return parsed;
  } catch {
    return { completed_lessons: {}, started_at: new Date().toISOString() };
  }
}

async function saveProgress(progress) {
  await mkdir(dirname(PROGRESS_PATH), { recursive: true });
  await writeFile(PROGRESS_PATH, JSON.stringify(progress, null, 2));
}

// ---------- vocab helpers ----------

// Split a target-language string into comparable tokens. Lowercases,
// strips punctuation, splits on whitespace + apostrophes + hyphens (so
// "s'il" becomes ["s","il"] and "avez-vous" becomes ["avez","vous"]).
// Diacritics are preserved — matching is case-insensitive but
// accent-sensitive, which matches how the app compares answers.
function tokenize(str) {
  if (!str) return [];
  return str
    .toLowerCase()
    .replace(/[.,!?¿¡"';:()\[\]{}…«»„“”‘’]/g, " ")
    .replace(/[/\\—–\-]/g, " ")
    .replace(/'/g, " ")
    .split(/\s+/)
    .filter(Boolean);
}

// Build the pool of "known" tokens from the allowed_vocab list. Each
// vocab.word may be a phrase ("Buenos días") — we split into tokens so
// individual words in exercises can match.
function buildAllowedTokens(allowedVocab) {
  const set = new Set();
  for (const v of allowedVocab) {
    for (const tok of tokenize(v.word ?? "")) set.add(tok);
  }
  return set;
}

// Which strings in an exercise are in the TARGET language and therefore
// subject to the vocab audit. English strings (MC/listening questions,
// speaking prompts, listening answers) are skipped.
function targetLangStrings(exercise) {
  switch (exercise.type) {
    case "multiple_choice":
      // question=English, answers=target
      return [exercise.correct_answer, ...(exercise.wrong_answers ?? [])];
    case "fill_blank":
      // Everything is target language. Replace the blank marker so it
      // doesn't tokenize as noise.
      return [
        String(exercise.question ?? "").replace(/_+/g, " "),
        exercise.correct_answer,
        ...(exercise.wrong_answers ?? []),
      ];
    case "listening":
      // question is the target-language phrase; answers are English translations.
      return [exercise.question];
    case "speaking":
      // question is English prompt; correct_answer is target-language phrase.
      return [exercise.correct_answer];
    default:
      return [];
  }
}

// Does `word` count as "known" for audit purposes?
//   1. Stopword (structural glue for the language)
//   2. Exact token match in allowed set
//   3. Stem-prefix match (≥3 chars either direction) — catches
//      inflections like "buenos"/"buenas", "tengo"/"tienes", or
//      "parle"/"parlez" without needing a real morphological analyzer.
//      This is intentionally loose so we don't reject valid conjugations
//      the model produces from a base form in the vocab.
function isKnownToken(word, allowed, stopwords) {
  if (!word) return true;
  if (stopwords.has(word)) return true;
  if (allowed.has(word)) return true;
  if (word.length < 3) return false;
  for (const t of allowed) {
    if (t.length < 3) continue;
    if (word.startsWith(t) || t.startsWith(word)) return true;
  }
  return false;
}

// Audit a batch of exercises against the lesson's allowed_vocab. Drops
// exercises where the count of unknown target-language tokens exceeds
// the CEFR-level tolerance. Returns both the survivors and a structured
// report on rejections so the caller can log exactly why each was dropped.
function auditExercises(exercises, allowedVocab, language, cefrLevel) {
  const allowed = buildAllowedTokens(allowedVocab);
  // Merge target-language stopwords + English stopwords. English words
  // legitimately appear as answer text in comprehension/translation MC;
  // the audit shouldn't flag them as off-vocab target-language drift.
  const stopwords = new Set([
    ...(STOPWORDS[language] ?? []),
    ...STOPWORDS.English,
  ]);
  const maxAbs = AUDIT_TOLERANCE[cefrLevel] ?? DEFAULT_TOLERANCE;
  const maxPct = AUDIT_PCT_TOLERANCE[cefrLevel] ?? DEFAULT_PCT_TOLERANCE;
  const kept = [];
  const rejected = [];
  for (const ex of exercises) {
    const offending = new Set();
    let totalTokens = 0;
    for (const str of targetLangStrings(ex)) {
      for (const tok of tokenize(str)) {
        totalTokens++;
        if (!isKnownToken(tok, allowed, stopwords)) offending.add(tok);
      }
    }
    // Keep the exercise if EITHER threshold is satisfied. This lets
    // long C1 sentences pass on the percentage bar even when their
    // absolute unknown count is high, and holds short A1 sentences to
    // the strict absolute bar.
    const passAbs = offending.size <= maxAbs;
    const passPct = totalTokens === 0 ? true : (offending.size / totalTokens) <= maxPct;
    if (passAbs || passPct) {
      kept.push(ex);
    } else {
      rejected.push({ exercise: ex, offending: Array.from(offending) });
    }
  }
  return { kept, rejected };
}

// Pull the target-language word from a vocab_items row. Prefers the
// canonical `word` field but falls back to language-specific keys
// (`spanish`, `french`) that show up in older or externally-seeded
// content. Keeps the script resilient to schema drift without requiring
// a DB migration for every new language.
function extractWord(v) {
  return ((v?.word ?? v?.spanish ?? v?.french ?? "") || "").toString().trim();
}

// Extract the target-language phrase from a dialogue line. Same
// language-key fallback logic as vocab.
function extractDialoguePhrase(d) {
  return ((d?.word ?? d?.spanish ?? d?.french ?? d?.text ?? "") || "").toString().trim();
}

// Which lesson types are ALLOWED to introduce new vocabulary. Only the
// first three lesson types in a section (Vocabulary, Grammar, Phrases)
// contribute their own vocab_items to the allowed pool. Practice
// lessons (listening/speaking/reading/writing/conversation/unit_test)
// only get access to the accumulated pool from lessons 1–3 — they
// can't introduce new words even if the DB has vocab_items on them.
const INTRODUCES_NEW_VOCAB = new Set(["vocabulary", "grammar", "phrases"]);

// Turn the lesson's stored vocab_items (and, for conversation lessons,
// the dialogue lines) into a flat list of {word, english} pairs that
// the model is allowed to use in generated exercises.
//
// Vocab-scope rule (from the course-design spec):
//   • Vocab lesson introduces the bulk of new vocab
//   • Grammar / Phrases may add a small number of essentials
//   • Listening / Speaking / Reading / Writing / Conversation / Section
//     Test introduce NO new words — they only practice what's above.
//
// So for practice lessons, we pool ONLY from prior lessons in the
// section that were themselves vocab-introducing (plus any dialogue
// lines those had, which are always safe to use).
function buildAllowedVocab(currentLesson, priorLessonsInSection) {
  const out = new Map();
  const addRow = (v, from) => {
    const key = extractWord(v);
    if (!key) return;
    if (!out.has(key)) out.set(key, { word: key, english: v.english ?? null, from });
  };
  const addDialogueLines = (lesson) => {
    for (const d of (lesson.dialogue ?? [])) {
      const phrase = extractDialoguePhrase(d);
      for (const word of tokenize(phrase)) {
        if (!out.has(word)) out.set(word, { word, english: d.english ?? null, from: "dialogue" });
      }
    }
  };
  for (const prior of priorLessonsInSection) {
    for (const v of (prior.vocab_items ?? [])) addRow(v, "prior");
    addDialogueLines(prior);
  }
  if (INTRODUCES_NEW_VOCAB.has(currentLesson.type)) {
    for (const v of (currentLesson.vocab_items ?? [])) addRow(v, "current");
  }
  addDialogueLines(currentLesson); // dialogue always allowed (conversation lessons)
  return Array.from(out.values());
}

// ---------- main loop ----------

async function main() {
  const args = parseArgs(process.argv.slice(2));

  const supabaseUrl = requireEnv("NEXT_PUBLIC_SUPABASE_URL");
  const anonKey = requireEnv("NEXT_PUBLIC_SUPABASE_ANON_KEY");
  const anthropicKey = requireEnv("ANTHROPIC_API_KEY");
  const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY ?? null;

  if (args.live && !serviceKey) {
    throw new Error("--live requires SUPABASE_SERVICE_ROLE_KEY in the env; refusing to write with anon key");
  }

  const readSupabase = makeSupabase({ url: supabaseUrl, key: anonKey });
  const writeSupabase = args.live ? makeSupabase({ url: supabaseUrl, key: serviceKey }) : null;

  console.log(`\n== regenerate-exercises ==`);
  console.log(`mode:      ${args.live ? "LIVE (writing to DB)" : "DRY-RUN (no writes)"}`);
  console.log(`model:     ${MODEL}`);
  console.log(`filter:    language=${args.language ?? "*"} level=${args.level ?? "*"} section=${args.section ?? "*"}`);
  console.log(`lesson cap: ${Number.isFinite(args.lessonLimit) ? args.lessonLimit : "none"}`);
  console.log(`progress:  ${PROGRESS_PATH}`);
  console.log(``);

  const progress = await loadProgress(args.reset);

  // Save progress on Ctrl+C so partial runs are resumable.
  let saving = false;
  process.on("SIGINT", async () => {
    if (saving) return;
    saving = true;
    console.error(`\n[SIGINT] saving progress and exiting…`);
    try { await saveProgress(progress); } catch (e) { console.error(`  progress save failed: ${e.message}`); }
    process.exit(130);
  });

  // Pull all target-language rows once. Filter to spanish+french unless
  // the user narrowed further via --language.
  const languageFilter = args.language
    ? `code=eq.${encodeURIComponent(args.language)}`
    : `code=in.(spanish,french)`;
  const languages = await readSupabase.get(`/languages?select=id,name,code&${languageFilter}&order=id`);
  if (languages.length === 0) { console.error(`no matching languages`); process.exit(1); }

  let totalRegen = 0;
  let totalSkipped = 0;
  let totalFailed = 0;
  const usageAgg = { input: 0, output: 0, cacheWrite: 0, cacheRead: 0 };

  outer: for (const lang of languages) {
    const levelFilter = args.level ? `cefr_level=eq.${args.level}&` : ``;
    const courses = await readSupabase.get(
      `/courses?select=id,title,cefr_level,order_index&language_id=eq.${lang.id}&${levelFilter}order=cefr_level,order_index`,
    );

    for (const course of courses) {
      if (args.section && !course.title.toLowerCase().includes(args.section)) continue;

      // Pull all lessons in the section, ordered by lesson number.
      const lessons = await readSupabase.get(
        `/lessons?select=id,title,type,order_index,vocab_items,dialogue&course_id=eq.${course.id}&order=order_index`,
      );
      if (lessons.length === 0) continue;

      console.log(`── ${lang.name} / ${course.cefr_level} / ${course.title} (${lessons.length} lessons)`);

      for (let idx = 0; idx < lessons.length; idx++) {
        if (totalRegen >= args.lessonLimit) break outer;

        const lesson = lessons[idx];
        const lessonKey = `${lang.code}:${course.cefr_level}:${course.title}:L${idx + 1}:${lesson.id}`;

        if (args.resume && progress.completed_lessons[lessonKey]) {
          console.log(`   L${idx + 1}. ${lesson.title.padEnd(40)} SKIP (already done ${progress.completed_lessons[lessonKey]})`);
          totalSkipped++;
          continue;
        }
        if (SKIP_LESSON_TYPES.has(lesson.type)) {
          console.log(`   L${idx + 1}. ${lesson.title.padEnd(40)} SKIP (type=${lesson.type} not regenerated by this script)`);
          totalSkipped++;
          continue;
        }
        const rawMix = EXERCISE_MIX[lesson.type];
        if (!rawMix) {
          console.log(`   L${idx + 1}. ${lesson.title.padEnd(40)} SKIP (no mix for type=${lesson.type})`);
          totalSkipped++;
          continue;
        }
        // Scale exercise counts down for higher CEFR levels (except
        // unit_test which is fixed at 10 regardless of level).
        const mix = scaleMix(rawMix, lesson.type, course.cefr_level);

        const priorLessons = lessons.slice(0, idx);
        const allowedVocab = buildAllowedVocab(lesson, priorLessons);
        if (allowedVocab.length === 0) {
          console.log(`   L${idx + 1}. ${lesson.title.padEnd(40)} SKIP (no vocab or dialogue to constrain against)`);
          totalSkipped++;
          continue;
        }

        const started = Date.now();
        let result;
        try {
          result = await generateExercises({
            apiKey: anthropicKey,
            language: lang.name,
            cefrLevel: course.cefr_level,
            sectionTopic: course.title,
            lessonNumber: idx + 1,
            totalLessons: lessons.length,
            lessonType: lesson.type,
            allowedVocab,
            exerciseMix: mix,
            dialogue: lesson.dialogue ?? null,
          });
        } catch (err) {
          console.error(`   L${idx + 1}. ${lesson.title.padEnd(40)} FAIL (${err.message})`);
          totalFailed++;
          continue;
        }
        const elapsedMs = Date.now() - started;

        // Track usage across the batch so the summary shows cache hit rate.
        const u = result.usage ?? {};
        usageAgg.input += u.input_tokens ?? 0;
        usageAgg.output += u.output_tokens ?? 0;
        usageAgg.cacheWrite += u.cache_creation_input_tokens ?? 0;
        usageAgg.cacheRead += u.cache_read_input_tokens ?? 0;

        // Strict vocab audit — drop any exercise that uses a
        // target-language token outside the lesson's allowed_vocab (plus
        // stopwords + stem-prefix match). Prevents the model from
        // "helpfully" adding topical vocab it wasn't taught.
        const { kept, rejected } = auditExercises(result.exercises, allowedVocab, lang.name, course.cefr_level);
        const cacheTag = (u.cache_read_input_tokens ?? 0) > 0 ? "HIT " : "MISS";
        const rejTag = rejected.length > 0 ? ` (${rejected.length} rejected by audit)` : "";
        console.log(
          `   L${idx + 1}. ${lesson.title.padEnd(40)} OK  ` +
          `${String(kept.length).padStart(2)}/${result.exercises.length} exercises kept, ` +
          `${elapsedMs}ms, cache=${cacheTag}${rejTag}` +
          (args.live ? ` [LIVE]` : ` [dry]`),
        );

        if (rejected.length > 0) {
          console.log(`     ─── rejected by vocab audit ───`);
          for (const r of rejected) {
            const q = r.exercise.question ?? "";
            const trimmed = q.length > 60 ? q.slice(0, 60) + "…" : q;
            console.log(`     ✗ [${r.exercise.type}] "${trimmed}"`);
            console.log(`       unknown tokens: ${JSON.stringify(r.offending)}`);
          }
        }

        if (args.verbose || (args.dryRun && totalRegen === 0)) {
          console.log(`\n     ─── kept exercises ───`);
          for (const [i, ex] of kept.entries()) {
            console.log(`     ${i + 1}. [${ex.type}] Q: ${ex.question}`);
            console.log(`        A: ${ex.correct_answer}` + (ex.translation ? `  (en: ${ex.translation})` : ""));
            if (ex.wrong_answers?.length) console.log(`        distractors: ${JSON.stringify(ex.wrong_answers)}`);
          }
          console.log();
        }

        // Safety valve: refuse to write a lesson with too few surviving
        // exercises. Ratio scales with CEFR level — A1 stays strict
        // (~50%), C1 accepts thinner writes (~30%) because natural C1
        // sentences will always fall outside strict tolerance sometimes.
        // Failures don't mark progress, so a re-run retries.
        const minKeepRatio = SAFETY_VALVE_MIN_RATIO[course.cefr_level] ?? DEFAULT_SAFETY_VALVE_RATIO;
        const minKeep = Math.max(2, Math.ceil(result.exercises.length * minKeepRatio));
        if (kept.length < minKeep) {
          console.error(
            `      ⚠ audit dropped ${rejected.length}/${result.exercises.length} exercises (kept ${kept.length}, threshold ${minKeep}) — skipping write for this lesson (re-run to retry)`,
          );
          totalFailed++;
          continue;
        }

        if (args.live) {
          try {
            // DELETE then INSERT the audit-survivors only. Small window
            // where the lesson has no exercises — acceptable for a bulk
            // migration but worth knowing about. A future version could
            // wrap this in an RPC for atomicity.
            await writeSupabase.delete(`/exercises?lesson_id=eq.${lesson.id}`);
            const rows = kept.map((ex, i) => ({
              lesson_id: lesson.id,
              type: ex.type,
              question: ex.question,
              correct_answer: ex.correct_answer,
              wrong_answers: ex.wrong_answers ?? [],
              translation: ex.translation ?? null,
              order_index: i + 1,
            }));
            await writeSupabase.post(`/exercises`, rows);
          } catch (err) {
            console.error(`      write FAILED for lesson ${lesson.id}: ${err.message}`);
            totalFailed++;
            continue;
          }
        }

        progress.completed_lessons[lessonKey] = new Date().toISOString();
        // Persist after every lesson so a crash mid-run doesn't cost work.
        await saveProgress(progress);
        totalRegen++;

        if (args.sleepMs > 0) await new Promise((r) => setTimeout(r, args.sleepMs));
      }
    }
  }

  console.log(`\n── summary ──`);
  console.log(`regenerated: ${totalRegen}`);
  console.log(`skipped:     ${totalSkipped}`);
  console.log(`failed:      ${totalFailed}`);
  console.log(`token usage: input=${usageAgg.input} output=${usageAgg.output} ` +
              `cache_write=${usageAgg.cacheWrite} cache_read=${usageAgg.cacheRead}`);
  const cacheable = usageAgg.cacheWrite + usageAgg.cacheRead;
  if (cacheable > 0) {
    console.log(`cache hit%:  ${Math.round((usageAgg.cacheRead / cacheable) * 100)}%`);
  }
  console.log(``);
  await saveProgress(progress);
}

main().catch((err) => {
  console.error(`\nFATAL: ${err.stack ?? err.message}`);
  process.exit(1);
});

-- 037_placement_exam_b1_b2_c1.sql
-- Spanish B1/B2/C1 placement exams, reusing the v2 A1/A2 schema and adding
-- roleplay scenarios in place of the listening/speaking sections.
--
-- Per attempt:
--   1 reading passage (3 MC), 5 vocabulary, 5 dialogue completions,
--   3 roleplay dialogues, 10 writing.
-- Pass mark: 75% (enforced in app code).
--
-- Idempotent.

-- ============== SCHEMA: roleplay scenario bank ==============
create table if not exists public.placement_exam_roleplays (
  id bigint generated always as identity primary key,
  language_id bigint not null references public.languages(id) on delete cascade,
  level text not null check (level in ('A1','A2','B1','B2','C1')),
  -- Short label shown in UI, e.g. "Restaurant complaint".
  topic_label text not null,
  -- Spanish setup paragraph describing the situation (shown to candidate).
  scenario text not null,
  -- Role the candidate plays (e.g. "Cliente").
  user_role text not null,
  -- Role the AI plays (e.g. "Camarero").
  ai_role text not null,
  -- AI's first line — seeds the conversation.
  ai_opener text not null,
  -- How many user turns we aim for before the AI winds the conversation down.
  target_exchanges int not null default 5 check (target_exchanges between 3 and 8),
  created_at timestamptz default now()
);
create index if not exists idx_placement_roleplays_lang_level
  on public.placement_exam_roleplays(language_id, level);

alter table public.placement_exam_roleplays enable row level security;
drop policy if exists "Roleplays are readable by authenticated users"
  on public.placement_exam_roleplays;
create policy "Roleplays are readable by authenticated users"
  on public.placement_exam_roleplays for select
  to authenticated
  using (true);

-- ============== SCHEMA: per-attempt roleplay transcripts ==============
create table if not exists public.placement_exam_attempt_roleplays (
  id bigint generated always as identity primary key,
  attempt_id uuid not null references public.placement_exam_attempts(id) on delete cascade,
  roleplay_id bigint references public.placement_exam_roleplays(id) on delete set null,
  -- jsonb array of {role: "user"|"ai", text: "..."}
  transcript jsonb not null default '[]'::jsonb,
  score int not null default 0 check (score between 0 and 10),
  feedback text,
  created_at timestamptz default now()
);
create index if not exists idx_attempt_roleplays_attempt
  on public.placement_exam_attempt_roleplays(attempt_id);

alter table public.placement_exam_attempt_roleplays enable row level security;
drop policy if exists "Users see their own roleplay transcripts"
  on public.placement_exam_attempt_roleplays;
create policy "Users see their own roleplay transcripts"
  on public.placement_exam_attempt_roleplays for select
  using (
    exists (
      select 1 from public.placement_exam_attempts a
      where a.id = attempt_id and a.user_id = auth.uid()
    )
  );
drop policy if exists "Users can insert their own roleplay transcripts"
  on public.placement_exam_attempt_roleplays;
create policy "Users can insert their own roleplay transcripts"
  on public.placement_exam_attempt_roleplays for insert
  with check (
    exists (
      select 1 from public.placement_exam_attempts a
      where a.id = attempt_id and a.user_id = auth.uid()
    )
  );

-- ============== SCHEMA: roleplay_score column ==============
alter table public.placement_exam_attempts
  add column if not exists roleplay_score int not null default 0;

-- ============== SEED ==============
do $$
declare
  v_lang_id bigint;
begin
  select id into v_lang_id from public.languages where code = 'spanish';
  if v_lang_id is null then raise exception 'Spanish language not found'; end if;

  delete from public.placement_exam_questions
    where language_id = v_lang_id and level in ('B1','B2','C1');
  delete from public.placement_exam_reading_passages
    where language_id = v_lang_id and level in ('B1','B2','C1');
  delete from public.placement_exam_roleplays
    where language_id = v_lang_id and level in ('B1','B2','C1');

  -- =========================================================
  -- B1 — READING PASSAGES (3, 150-200 words each)
  -- =========================================================
  insert into public.placement_exam_reading_passages (language_id, level, passage, comprehension_questions) values
  (v_lang_id,'B1',
   'El verano pasado decidí mudarme a Valencia para empezar un máster en arquitectura. Antes de viajar había vivido siempre con mis padres en un pueblo cerca de Toledo, así que el cambio fue importante para mí. Encontré un piso compartido en el centro con dos estudiantes italianos: al principio nos comunicábamos en inglés, pero después de unos meses ellos ya hablaban español sin problemas. Lo más difícil no fue el idioma sino acostumbrarme a vivir solo: cocinar, hacer la compra y organizar mi tiempo de estudio. Aun así, conocí a gente maravillosa y aprendí mucho sobre mí mismo. Si pudiera volver atrás, lo haría todo otra vez.',
   '[
     {"question":"¿Por qué se mudó a Valencia?","correct_answer":"Para estudiar un máster en arquitectura","wrong_answers":["Para encontrar trabajo","Para vivir con sus padres","Para enseñar inglés"]},
     {"question":"¿Cómo se comunicaba al principio con sus compañeros?","correct_answer":"En inglés","wrong_answers":["En italiano","Sólo en español","Por escrito"]},
     {"question":"¿Qué fue lo más difícil para él?","correct_answer":"Acostumbrarse a vivir solo","wrong_answers":["Aprender italiano","Encontrar un piso","Pagar el alquiler"]}
   ]'::jsonb),
  (v_lang_id,'B1',
   'Carmen trabaja como enfermera desde hace siete años en un hospital de Bilbao. Aunque le gusta su profesión, últimamente se siente bastante cansada porque los turnos de noche son cada vez más frecuentes y no tiene tiempo para sus aficiones. Hace tres meses empezó a aprender pintura los sábados por la mañana y, aunque suene extraño, dice que esa hora a la semana le cambia el resto de los días. Su sueño es ahorrar lo suficiente para hacer un viaje a Japón, un país que le interesa desde que vio un documental sobre Kioto en la universidad. Si todo va bien, viajará el próximo otoño con su mejor amiga.',
   '[
     {"question":"¿Qué problema tiene Carmen últimamente?","correct_answer":"Hace muchos turnos de noche","wrong_answers":["No le gusta su trabajo","No tiene compañeros","No gana suficiente dinero"]},
     {"question":"¿Qué hace los sábados?","correct_answer":"Clases de pintura","wrong_answers":["Trabaja extra","Estudia japonés","Visita a su familia"]},
     {"question":"¿Cuándo planea viajar a Japón?","correct_answer":"El próximo otoño","wrong_answers":["Este verano","En unos años","No tiene fecha"]}
   ]'::jsonb),
  (v_lang_id,'B1',
   'Hace tres años abrimos un pequeño café-librería en el barrio antiguo de Granada. La idea surgió una tarde, cuando mi pareja y yo nos dimos cuenta de que no había ningún sitio cómodo donde tomar un café y leer durante varias horas. Al principio fue muy complicado: los primeros meses casi no veníamos clientes y pensamos varias veces en cerrar. Sin embargo, decidimos invitar a autores locales a presentar sus libros los jueves por la noche y poco a poco la gente empezó a hablar de nosotros. Hoy en día tenemos clientes fieles que vienen cada semana y, lo más importante, hemos creado un espacio donde la gente se siente en casa.',
   '[
     {"question":"¿Por qué decidieron abrir el café-librería?","correct_answer":"Porque no había un sitio similar en el barrio","wrong_answers":["Porque les gustaba el barrio antiguo","Porque querían vender libros usados","Porque heredaron el local"]},
     {"question":"¿Qué hicieron para atraer a más gente?","correct_answer":"Organizar presentaciones de libros los jueves","wrong_answers":["Bajar los precios","Abrir más horas","Cerrar los fines de semana"]},
     {"question":"¿Cómo describen el café hoy en día?","correct_answer":"Un espacio donde la gente se siente en casa","wrong_answers":["Un negocio que pronto cerrará","Un local solo para autores","Un sitio sólo de fin de semana"]}
   ]'::jsonb);

  -- =========================================================
  -- B1 — VOCABULARY (10 in bank, pick 5)
  -- Full-sentence context with B1 grammar (preterite/imperfect, perfect, basic subjunctive).
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, order_index) values
  (v_lang_id,'B1','vocabulary','Cuando era niño, ____ los veranos en casa de mis abuelos en el pueblo.','pasaba',array['pasé','paso','pasaré'],1),
  (v_lang_id,'B1','vocabulary','Me alegro de que ____ a la fiesta el sábado por la noche.','vengas',array['vienes','venías','vendrás'],2),
  (v_lang_id,'B1','vocabulary','Si tuviera más tiempo libre, ____ aprender a tocar la guitarra.','me gustaría',array['me gusta','me gustó','me gusta'],3),
  (v_lang_id,'B1','vocabulary','Llevo dos años ____ español, pero todavía me cuesta entender los acentos.','estudiando',array['estudiado','estudio','estudiaba'],4),
  (v_lang_id,'B1','vocabulary','El médico me recomendó que ____ menos café y más agua.','bebiera',array['bebía','bebo','beberé'],5),
  (v_lang_id,'B1','vocabulary','Aunque estaba muy cansado, mi hermano ____ trabajando hasta tarde.','siguió',array['empezó','perdió','llamó'],6),
  (v_lang_id,'B1','vocabulary','No me di cuenta ____ que había perdido las llaves hasta llegar a casa.','de',array['en','con','por'],7),
  (v_lang_id,'B1','vocabulary','Después de discutir mucho, mis amigos por fin se ____ con la decisión.','pusieron de acuerdo',array['enojaron','despidieron','quitaron'],8),
  (v_lang_id,'B1','vocabulary','La empresa busca a un candidato que ____ inglés y francés perfectamente.','hable',array['habla','hablaba','hablará'],9),
  (v_lang_id,'B1','vocabulary','El año pasado mi familia ____ a Madrid porque mi padre cambió de trabajo.','se mudó',array['mudaba','muda','mudará'],10);

  -- =========================================================
  -- B1 — DIALOGUE COMPLETION (10 in bank, pick 5)
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, dialogue_lines, order_index) values
  (v_lang_id,'B1','dialogue','Complete the dialogue with an appropriate Spanish response (2-3 sentences if possible).','El fin de semana fui a Sevilla con mi pareja. Visitamos la catedral y comimos en un bar muy bueno cerca del río.',array[]::text[],
   '[{"speaker":"A","text":"Hace tiempo que no nos vemos. ¿Qué tal estás?"},{"speaker":"B","text":"___"}]'::jsonb,11),
  (v_lang_id,'B1','dialogue','Complete the dialogue with an appropriate Spanish response.','Me duele bastante la cabeza desde ayer y me gustaría que me recomendara algo. También me siento un poco cansada.',array[]::text[],
   '[{"speaker":"Médico","text":"Buenos días, ¿en qué puedo ayudarle?"},{"speaker":"Paciente","text":"___"}]'::jsonb,12),
  (v_lang_id,'B1','dialogue','Complete the dialogue with an appropriate Spanish response.','Lo siento mucho, pero ya tengo planes para el sábado. ¿Qué te parece si quedamos el domingo por la tarde?',array[]::text[],
   '[{"speaker":"A","text":"¿Quieres venir a una barbacoa en mi casa el sábado?"},{"speaker":"B","text":"___"}]'::jsonb,13),
  (v_lang_id,'B1','dialogue','Complete the dialogue with an appropriate Spanish response.','Quería pedir el menú del día, por favor. ¿Podría decirme qué tienen de primer plato hoy?',array[]::text[],
   '[{"speaker":"Camarero","text":"Buenas tardes, ¿ya saben lo que van a pedir?"},{"speaker":"Cliente","text":"___"}]'::jsonb,14),
  (v_lang_id,'B1','dialogue','Complete the dialogue with an appropriate Spanish response.','Sí, claro. Continúe recto durante dos calles y luego gire a la derecha. La farmacia está al lado del banco.',array[]::text[],
   '[{"speaker":"Turista","text":"Disculpe, ¿podría decirme cómo llegar a la farmacia más cercana?"},{"speaker":"Local","text":"___"}]'::jsonb,15),
  (v_lang_id,'B1','dialogue','Complete the dialogue with an appropriate Spanish response.','Llevo tres años trabajando en una empresa de marketing. Antes había estudiado periodismo en la universidad.',array[]::text[],
   '[{"speaker":"Entrevistador","text":"Cuénteme un poco sobre su experiencia profesional, por favor."},{"speaker":"Candidato","text":"___"}]'::jsonb,16),
  (v_lang_id,'B1','dialogue','Complete the dialogue with an appropriate Spanish response.','No, todavía no he terminado el informe. Lo siento, pero tuve que ayudar a otro compañero esta mañana.',array[]::text[],
   '[{"speaker":"Jefe","text":"¿Ya tienes listo el informe que te pedí ayer?"},{"speaker":"Empleado","text":"___"}]'::jsonb,17),
  (v_lang_id,'B1','dialogue','Complete the dialogue with an appropriate Spanish response.','Compré esta camisa el viernes pasado y, cuando llegué a casa, vi que estaba rota. ¿Podría cambiármela?',array[]::text[],
   '[{"speaker":"Cliente","text":"Buenas tardes, tengo un problema con un producto."},{"speaker":"Dependiente","text":"___"}]'::jsonb,18),
  (v_lang_id,'B1','dialogue','Complete the dialogue with an appropriate Spanish response.','Prefiero una habitación con vistas al mar, si es posible. ¿Cuánto costaría incluir el desayuno?',array[]::text[],
   '[{"speaker":"Recepcionista","text":"Tenemos disponible una habitación doble. ¿Qué prefiere?"},{"speaker":"Huésped","text":"___"}]'::jsonb,19),
  (v_lang_id,'B1','dialogue','Complete the dialogue with an appropriate Spanish response.','Estudié filología hispánica porque siempre me han fascinado los idiomas y la literatura. Después hice un curso de traducción.',array[]::text[],
   '[{"speaker":"A","text":"¿Por qué decidiste estudiar lo que estudias?"},{"speaker":"B","text":"___"}]'::jsonb,20);

  -- =========================================================
  -- B1 — WRITING (20 in bank, pick 10)
  -- 4-5 Spanish sentences. Progressive complexity within the bank.
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, order_index) values
  (v_lang_id,'B1','writing','Write 4-5 Spanish sentences about a trip you took recently.','Where, when, with whom, what you did, how you felt',array[]::text[],21),
  (v_lang_id,'B1','writing','Write 4-5 Spanish sentences about a problem you solved at work or in your studies.','The problem, what you did, the result',array[]::text[],22),
  (v_lang_id,'B1','writing','Write 4-5 Spanish sentences comparing life in a big city with life in a small town.','At least two contrasts and your preference',array[]::text[],23),
  (v_lang_id,'B1','writing','Write a 4-5 sentence email to a friend inviting them to your birthday celebration.','Date, time, place, what activity, polite close',array[]::text[],24),
  (v_lang_id,'B1','writing','Write 4-5 Spanish sentences about a goal you want to achieve in the next year.','The goal, why it matters, how you''ll work on it',array[]::text[],25),
  (v_lang_id,'B1','writing','Write 4-5 Spanish sentences about how technology has changed daily life.','At least two specific examples',array[]::text[],26),
  (v_lang_id,'B1','writing','Write 4-5 Spanish sentences describing a memorable meal.','When, where, with whom, what you ate, why it stood out',array[]::text[],27),
  (v_lang_id,'B1','writing','Write 4-5 Spanish sentences about what you would do if you won the lottery.','Use conditional forms',array[]::text[],28),
  (v_lang_id,'B1','writing','Write a 4-5 sentence complaint to a hotel about a problem during your stay.','Polite tone, specific issue, requested action',array[]::text[],29),
  (v_lang_id,'B1','writing','Write 4-5 Spanish sentences explaining advantages and disadvantages of working from home.','At least one pro and one con',array[]::text[],30),
  (v_lang_id,'B1','writing','Write 4-5 Spanish sentences describing a person who has influenced you.','Who they are, why, an example',array[]::text[],31),
  (v_lang_id,'B1','writing','Write 4-5 Spanish sentences about a tradition or festival in your country.','Name, when, what people do, your opinion',array[]::text[],32),
  (v_lang_id,'B1','writing','Write 4-5 Spanish sentences narrating a misunderstanding you had abroad.','Where, what happened, how you resolved it',array[]::text[],33),
  (v_lang_id,'B1','writing','Write 4-5 Spanish sentences about a book or film that made you think.','Title, brief description, what you took away',array[]::text[],34),
  (v_lang_id,'B1','writing','Write 4-5 Spanish sentences about the best advice you have received.','Who, when, what advice, how it helped',array[]::text[],35),
  (v_lang_id,'B1','writing','Write 4-5 Spanish sentences explaining how to prepare a simple dish from your country.','Ingredients, steps, tips',array[]::text[],36),
  (v_lang_id,'B1','writing','Write 4-5 Spanish sentences about a change you would like to see in your city.','The change, why, possible impact',array[]::text[],37),
  (v_lang_id,'B1','writing','Write 4-5 Spanish sentences about a habit you would like to improve.','The habit, why it matters, your plan',array[]::text[],38),
  (v_lang_id,'B1','writing','Write 4-5 Spanish sentences describing your ideal job.','Type of work, schedule, environment, why',array[]::text[],39),
  (v_lang_id,'B1','writing','Write 4-5 Spanish sentences explaining why learning another language is useful.','Personal, professional and cultural reasons',array[]::text[],40);

  -- =========================================================
  -- B1 — ROLEPLAY TOPICS (10, pick 3)
  -- =========================================================
  insert into public.placement_exam_roleplays (language_id, level, topic_label, scenario, user_role, ai_role, ai_opener, target_exchanges) values
  (v_lang_id,'B1','Restaurant',
   'Está cenando en un restaurante español. El plato que pidió ha llegado frío y la bebida no es la que pidió. Quiere resolver la situación de forma educada.',
   'Cliente','Camarero',
   'Buenas noches, ¿está todo bien con la comida? Veo que casi no ha probado el plato.', 5),
  (v_lang_id,'B1','Hotel check-in',
   'Llega a un hotel en Sevilla después de un vuelo largo. Tiene una reserva, pero el recepcionista no la encuentra en el sistema.',
   'Huésped','Recepcionista',
   'Buenas tardes, bienvenido al hotel. ¿Tiene una reserva a su nombre?', 5),
  (v_lang_id,'B1','Directions',
   'Está perdido en Madrid y quiere llegar al Museo del Prado. Pide ayuda a un local en la calle.',
   'Turista','Local',
   '¿En qué puedo ayudarle? Parece un poco perdido.', 4),
  (v_lang_id,'B1','Job interview',
   'Tiene una entrevista informal para un trabajo de media jornada en una librería. El entrevistador es bastante amable.',
   'Candidato','Entrevistador',
   'Hola, encantado de conocerle. Cuénteme un poco sobre usted y por qué le interesa este trabajo.', 6),
  (v_lang_id,'B1','Weekend plans',
   'Habla con un amigo español para organizar el plan del próximo fin de semana. Quieren hacer algo divertido pero sin gastar mucho dinero.',
   'Amigo','Amigo',
   '¡Por fin viernes! ¿Qué te apetece hacer este fin de semana?', 5),
  (v_lang_id,'B1','Complaint resolution',
   'Compró una lavadora hace un mes y se ha estropeado. Llama al servicio de atención al cliente para reclamar.',
   'Cliente','Agente',
   'Servicio de atención al cliente, ¿en qué puedo ayudarle?', 5),
  (v_lang_id,'B1','Doctor visit',
   'Va al médico porque desde hace varios días tiene tos y le duele la garganta.',
   'Paciente','Médica',
   'Buenos días, pase y siéntese, por favor. Cuénteme qué le ocurre.', 5),
  (v_lang_id,'B1','Shopping return',
   'Compró una camisa la semana pasada y se ha encogido al lavarla siguiendo las instrucciones. Va a la tienda a devolverla.',
   'Cliente','Dependienta',
   'Buenas tardes, ¿necesita ayuda con algo?', 4),
  (v_lang_id,'B1','Travel booking',
   'Llama a una agencia de viajes para reservar un vuelo a Barcelona. Tiene fechas flexibles y quiere ver opciones.',
   'Cliente','Agente de viajes',
   'Agencia Sol y Mar, buenas tardes. ¿En qué puedo ayudarle?', 5),
  (v_lang_id,'B1','Apartment viewing',
   'Está visitando un piso de alquiler en el centro de la ciudad. La dueña le enseña el apartamento.',
   'Inquilino potencial','Propietaria',
   'Bienvenido. Adelante, pase. ¿Qué le parece el piso a primera vista?', 5);

  -- =========================================================
  -- B2 — READING PASSAGES (3, 200-250 words)
  -- =========================================================
  insert into public.placement_exam_reading_passages (language_id, level, passage, comprehension_questions) values
  (v_lang_id,'B2',
   'Aunque se suele decir que las redes sociales han acercado a las personas, cada vez más estudios sugieren lo contrario. Un informe reciente de la Universidad de Salamanca, basado en entrevistas a más de dos mil adolescentes, concluye que los jóvenes que pasan más de cinco horas al día conectados muestran niveles significativamente más altos de ansiedad y soledad. La autora principal del estudio, la psicóloga Isabel Maroto, advierte sin embargo de que la culpa no es de la tecnología en sí misma, sino del uso pasivo que se hace de ella: pasar horas mirando vidas ajenas sin interactuar realmente con nadie. Cuando los adolescentes utilizan las redes para crear contenido propio, debatir o coordinar actividades fuera de internet, los efectos negativos prácticamente desaparecen. La propuesta del equipo de investigación es educar en un uso activo y crítico, en lugar de prohibir el acceso, una solución que, según ellos, sólo desplazaría el problema.',
   '[
     {"question":"¿Qué conclusión principal aporta el estudio?","correct_answer":"Más horas conectados se asocian a más ansiedad y soledad","wrong_answers":["Las redes acercan más a los jóvenes","No hay efectos medibles","La tecnología es la única culpable"]},
     {"question":"Según Maroto, ¿qué tipo de uso es el problemático?","correct_answer":"El uso pasivo, sin interacción real","wrong_answers":["Cualquier uso, en general","Sólo el uso nocturno","El uso para coordinar planes"]},
     {"question":"¿Qué propone el equipo de investigación?","correct_answer":"Educar en un uso activo y crítico","wrong_answers":["Prohibir el acceso a menores","Sólo permitir el uso académico","Limitar a una hora al día por ley"]}
   ]'::jsonb),
  (v_lang_id,'B2',
   'Hace tres años, después de más de una década trabajando como abogada en un despacho importante de Madrid, Marta López tomó una decisión que dejó sorprendidos a todos los que la conocían: dejó su puesto, vendió su piso y abrió una pequeña panadería en un pueblo de la sierra. "No es que estuviera quemada por las largas jornadas, aunque ayudaron a empujarme", explica hoy. "Lo que ocurrió fue más profundo: dejé de reconocerme en el espejo." A pesar de las dudas iniciales y de los comentarios de quienes pensaban que aquello no podía funcionar, hoy el negocio se mantiene gracias a una clientela fiel y a la venta por internet a pueblos vecinos. "Gano menos de la mitad que antes, pero por primera vez en muchos años duermo bien por las noches", añade. Marta reconoce que su historia no es replicable para cualquiera, pero anima a quienes se sientan atrapados a, al menos, plantearse seriamente las preguntas correctas.',
   '[
     {"question":"¿Por qué dejó Marta su trabajo de abogada?","correct_answer":"Porque dejó de reconocerse a sí misma","wrong_answers":["Porque la despidieron","Porque ganaba muy poco","Porque se mudó a otro país"]},
     {"question":"¿Cómo se sostiene económicamente la panadería?","correct_answer":"Con clientes fieles y ventas en línea","wrong_answers":["Sólo con turistas","Con ayudas del gobierno","Cerrando varios meses al año"]},
     {"question":"¿Qué consejo da Marta a otras personas?","correct_answer":"Que se planteen seriamente las preguntas correctas","wrong_answers":["Que dejen su trabajo de inmediato","Que se mudaran al campo","Que estudien repostería"]}
   ]'::jsonb),
  (v_lang_id,'B2',
   'En la última década, varias ciudades europeas han apostado por reducir drásticamente el tráfico en sus cascos antiguos. Pontevedra, en Galicia, es uno de los casos más citados: desde finales de los años noventa, el centro está prácticamente vetado a los coches. Las estadísticas son sorprendentes: el número de víctimas en accidentes de tráfico ha caído casi a cero y los niveles de contaminación atmosférica son los más bajos de la región. Sin embargo, no todo el mundo aplaude el modelo. Comerciantes de la periferia se quejan de que la peatonalización ha desplazado el consumo a centros comerciales fuera del núcleo urbano, y algunos vecinos mayores señalan que es más complicado recibir mercancías o atender emergencias domésticas. Los técnicos municipales reconocen estas tensiones y argumentan que el modelo necesita ajustes constantes, pero defienden que los beneficios colectivos superan ampliamente los inconvenientes individuales.',
   '[
     {"question":"¿Qué efecto positivo se destaca de la peatonalización en Pontevedra?","correct_answer":"Una caída casi total de víctimas en accidentes","wrong_answers":["Mayor número de coches eléctricos","Más turismo de masas","Más oficinas en el centro"]},
     {"question":"¿Quiénes se quejan del modelo?","correct_answer":"Comerciantes de la periferia y algunos vecinos mayores","wrong_answers":["Los técnicos municipales","Los conductores de taxis","Los visitantes extranjeros"]},
     {"question":"¿Qué postura mantienen los técnicos municipales?","correct_answer":"Que los beneficios colectivos superan los inconvenientes individuales","wrong_answers":["Que hay que revertir el modelo","Que sólo funciona en ciudades pequeñas","Que es un fracaso a largo plazo"]}
   ]'::jsonb);

  -- =========================================================
  -- B2 — VOCABULARY (10 in bank)
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, order_index) values
  (v_lang_id,'B2','vocabulary','Buscamos un candidato que ____ experiencia previa en gestión de equipos internacionales.','tenga',array['tiene','tendrá','tenía'],11),
  (v_lang_id,'B2','vocabulary','Si hubiera sabido lo que iba a pasar, no ____ aceptado el trabajo.','habría',array['había','hubiera','hubo'],12),
  (v_lang_id,'B2','vocabulary','Aunque ____ muy difícil, nunca renunció a su sueño de estudiar medicina.','fuera',array['era','será','sería'],13),
  (v_lang_id,'B2','vocabulary','La propuesta fue rechazada ____ la oposición de varios miembros del consejo.','debido a',array['a pesar de','para','con tal de'],14),
  (v_lang_id,'B2','vocabulary','Le agradezco que ____ tan amable conmigo durante mi visita.','haya sido',array['ha sido','fue','sería'],15),
  (v_lang_id,'B2','vocabulary','El director insistió en que todos los empleados ____ a la reunión del lunes.','asistieran',array['asisten','asistirán','asistieron'],16),
  (v_lang_id,'B2','vocabulary','Nadie esperaba que el resultado ____ tan ajustado al final del partido.','fuera',array['era','sería','será'],17),
  (v_lang_id,'B2','vocabulary','En cuanto ____ los resultados, te llamaré para decírtelo.','tenga',array['tengo','tenía','tendré'],18),
  (v_lang_id,'B2','vocabulary','No me extraña que su jefe ____ enfadado: llevan semanas con retraso.','esté',array['está','estaba','estará'],19),
  (v_lang_id,'B2','vocabulary','Es importante que ____ el contrato antes de firmar nada.','revises',array['revisas','revisabas','revisarás'],20);

  -- =========================================================
  -- B2 — DIALOGUE COMPLETION (10 in bank)
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, dialogue_lines, order_index) values
  (v_lang_id,'B2','dialogue','Complete the dialogue with an appropriate Spanish response (at least 2 full sentences).','Sinceramente, no estoy del todo de acuerdo. Aunque la propuesta tiene puntos interesantes, creo que deberíamos analizar mejor las consecuencias a largo plazo.',array[]::text[],
   '[{"speaker":"Compañera","text":"He revisado tu propuesta y me parece muy buena, ¿qué opinas tú?"},{"speaker":"Tú","text":"___"}]'::jsonb,21),
  (v_lang_id,'B2','dialogue','Complete the dialogue with an appropriate Spanish response.','Lo siento mucho, pero el ruido es realmente molesto y no podemos descansar. ¿Sería posible que bajaran la música después de las once?',array[]::text[],
   '[{"speaker":"Vecino","text":"Hola, perdón por la hora, ¿hay algún problema?"},{"speaker":"Tú","text":"___"}]'::jsonb,22),
  (v_lang_id,'B2','dialogue','Complete the dialogue with an appropriate Spanish response.','Llevo varios meses pensando en cambiar de departamento. Me gustaría asumir más responsabilidades y aprender áreas nuevas.',array[]::text[],
   '[{"speaker":"Jefa","text":"Quería hablar contigo sobre tu desarrollo profesional. ¿Cómo te ves dentro de un año?"},{"speaker":"Empleado","text":"___"}]'::jsonb,23),
  (v_lang_id,'B2','dialogue','Complete the dialogue with an appropriate Spanish response.','Entiendo que es una decisión difícil, pero por mi situación familiar no puedo trasladarme a otra ciudad ahora mismo. Quizás podríamos buscar otra solución.',array[]::text[],
   '[{"speaker":"Director","text":"La empresa necesita que alguien asuma la oficina de Bilbao. Te lo propusimos a ti."},{"speaker":"Tú","text":"___"}]'::jsonb,24),
  (v_lang_id,'B2','dialogue','Complete the dialogue with an appropriate Spanish response.','Pues a mí me parece que hoy en día se gasta demasiado en publicidad y muy poco en formación. Por eso muchos empleados se sienten estancados.',array[]::text[],
   '[{"speaker":"Amigo","text":"¿Cómo ves la situación de tu sector últimamente?"},{"speaker":"Tú","text":"___"}]'::jsonb,25),
  (v_lang_id,'B2','dialogue','Complete the dialogue with an appropriate Spanish response.','Le agradezco mucho su tiempo. Estoy muy interesado en el puesto y espero noticias suyas en los próximos días.',array[]::text[],
   '[{"speaker":"Entrevistador","text":"Bueno, creo que con esto terminamos. ¿Tiene alguna última pregunta?"},{"speaker":"Candidato","text":"___"}]'::jsonb,26),
  (v_lang_id,'B2','dialogue','Complete the dialogue with an appropriate Spanish response.','Lo entiendo, pero le recuerdo que firmamos un contrato concreto. Si no podemos llegar a un acuerdo razonable, tendré que consultar con mi abogado.',array[]::text[],
   '[{"speaker":"Propietario","text":"Lamento decirle que tengo que subirle el alquiler un quince por ciento."},{"speaker":"Inquilino","text":"___"}]'::jsonb,27),
  (v_lang_id,'B2','dialogue','Complete the dialogue with an appropriate Spanish response.','Sí, claro. He pensado bastante en su consejo y creo que tiene razón. Voy a apuntarme al máster aunque suponga un esfuerzo económico importante.',array[]::text[],
   '[{"speaker":"Profesora","text":"Hace tiempo te recomendé que continuaras tus estudios. ¿Has tomado alguna decisión?"},{"speaker":"Estudiante","text":"___"}]'::jsonb,28),
  (v_lang_id,'B2','dialogue','Complete the dialogue with an appropriate Spanish response.','La verdad es que no me esperaba esa noticia. Necesito un par de días para pensarlo y hablar con mi familia antes de decirte algo definitivo.',array[]::text[],
   '[{"speaker":"Amigo","text":"Nos han ofrecido montar el negocio juntos. ¿Qué te parece?"},{"speaker":"Tú","text":"___"}]'::jsonb,29),
  (v_lang_id,'B2','dialogue','Complete the dialogue with an appropriate Spanish response.','Si fuera por mí, me iría a vivir al extranjero unos años. Sin embargo, no es tan sencillo: hay que tener en cuenta el trabajo, la familia y los estudios.',array[]::text[],
   '[{"speaker":"A","text":"¿Te has planteado alguna vez vivir fuera de España?"},{"speaker":"B","text":"___"}]'::jsonb,30);

  -- =========================================================
  -- B2 — WRITING (20 in bank)
  -- 5-6 sentences. More abstract themes.
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, order_index) values
  (v_lang_id,'B2','writing','Write 5-6 Spanish sentences arguing for or against remote work for entry-level employees.','Take a clear position; at least two arguments and a counter-argument',array[]::text[],31),
  (v_lang_id,'B2','writing','Write 5-6 Spanish sentences describing a recent change in your country''s culture.','What changed, why, your opinion',array[]::text[],32),
  (v_lang_id,'B2','writing','Write a 5-6 sentence formal letter requesting a refund from an online store.','Polite tone, specific facts, requested resolution',array[]::text[],33),
  (v_lang_id,'B2','writing','Write 5-6 Spanish sentences explaining the pros and cons of a four-day work week.','Concrete arguments, your conclusion',array[]::text[],34),
  (v_lang_id,'B2','writing','Write 5-6 Spanish sentences narrating a moment when you had to make a difficult decision.','Context, the dilemma, what you chose, what you learned',array[]::text[],35),
  (v_lang_id,'B2','writing','Write 5-6 Spanish sentences about how social media affects friendships today.','Both sides, concrete examples, your view',array[]::text[],36),
  (v_lang_id,'B2','writing','Write 5-6 Spanish sentences explaining whether universities should be free for everyone.','Take a position, justify with at least two arguments',array[]::text[],37),
  (v_lang_id,'B2','writing','Write 5-6 Spanish sentences about a film or book that changed how you see the world.','Title, what it changed, why',array[]::text[],38),
  (v_lang_id,'B2','writing','Write 5-6 Spanish sentences describing a current problem in your city and proposing a solution.','Problem, who is affected, your proposal',array[]::text[],39),
  (v_lang_id,'B2','writing','Write 5-6 Spanish sentences about whether tourism benefits or harms local communities.','At least one of each side, your conclusion',array[]::text[],40),
  (v_lang_id,'B2','writing','Write 5-6 Spanish sentences about a generational difference you have noticed.','Concrete example, why it exists, what you think',array[]::text[],41),
  (v_lang_id,'B2','writing','Write 5-6 Spanish sentences explaining how you handle disagreements at work or in your studies.','Strategy, an example, the result',array[]::text[],42),
  (v_lang_id,'B2','writing','Write 5-6 Spanish sentences about whether learning a second language should be compulsory in schools.','Take a position; justify with at least two arguments',array[]::text[],43),
  (v_lang_id,'B2','writing','Write 5-6 Spanish sentences describing what success means to you, beyond money.','Define, contrast with common views, give an example',array[]::text[],44),
  (v_lang_id,'B2','writing','Write 5-6 Spanish sentences narrating a misunderstanding caused by cultural differences.','Where, what happened, how you resolved it',array[]::text[],45),
  (v_lang_id,'B2','writing','Write 5-6 Spanish sentences about whether artificial intelligence will help or hurt your profession.','Specific examples, your stance',array[]::text[],46),
  (v_lang_id,'B2','writing','Write 5-6 Spanish sentences about an unwritten rule in your country that visitors should know.','The rule, why it exists, consequences of breaking it',array[]::text[],47),
  (v_lang_id,'B2','writing','Write 5-6 Spanish sentences about the role of public libraries today.','Are they still useful, why or why not, your conclusion',array[]::text[],48),
  (v_lang_id,'B2','writing','Write 5-6 Spanish sentences about a piece of advice you would give your younger self.','The advice, why, the situation that taught you',array[]::text[],49),
  (v_lang_id,'B2','writing','Write 5-6 Spanish sentences arguing whether grades reflect a student''s real ability.','Take a position, justify with concrete examples',array[]::text[],50);

  -- =========================================================
  -- B2 — ROLEPLAY TOPICS (10, pick 3)
  -- =========================================================
  insert into public.placement_exam_roleplays (language_id, level, topic_label, scenario, user_role, ai_role, ai_opener, target_exchanges) values
  (v_lang_id,'B2','Restaurant',
   'Está en un restaurante con un cliente importante. La cuenta tiene un error visible y, además, le sirvieron un plato distinto al que pidió. Quiere resolver la situación sin generar tensión delante del cliente.',
   'Cliente','Encargado',
   'Buenas tardes, ¿está todo a su gusto? Quería pasar a saludarles personalmente.', 5),
  (v_lang_id,'B2','Hotel check-in',
   'Llega a un hotel para una conferencia internacional. La habitación que le asignaron no corresponde a la categoría que reservó y necesita una solución antes de empezar las reuniones.',
   'Huésped','Recepcionista',
   'Buenas tardes, bienvenido al hotel. Veo que tiene una reserva con nosotros. ¿Le importa repasar conmigo los detalles?', 6),
  (v_lang_id,'B2','Directions',
   'Está en Sevilla y debe llegar a una entrevista importante. Se le agota la batería del móvil y necesita preguntar a un local sobre el camino y la mejor manera de llegar a tiempo.',
   'Profesional','Local',
   'Disculpe, parece que necesita ayuda. ¿En qué puedo orientarle?', 4),
  (v_lang_id,'B2','Job interview',
   'Tiene una entrevista para un puesto de responsabilidad en una empresa internacional. El entrevistador hace preguntas relativamente exigentes sobre su carrera y su forma de gestionar conflictos.',
   'Candidato','Entrevistadora',
   'Gracias por venir. Para empezar, me gustaría que me contara qué le motivó a presentarse a esta oferta concreta.', 6),
  (v_lang_id,'B2','Weekend plans',
   'Habla con su pareja sobre el fin de semana. Usted tiene mucho trabajo pendiente, pero su pareja insiste en hacer una escapada. Quiere llegar a un acuerdo que funcione para ambos.',
   'Pareja','Pareja',
   'Llevamos semanas sin salir de la ciudad. ¿No te gustaría hacer una escapada este fin de semana?', 5),
  (v_lang_id,'B2','Complaint resolution',
   'Ha contratado un servicio de internet para su empresa, pero llevan más de una semana sin conexión estable. Necesita una solución inmediata porque está afectando al negocio.',
   'Cliente empresarial','Agente',
   'Servicio empresarial, le atiende Juan. ¿En qué puedo ayudarle hoy?', 6),
  (v_lang_id,'B2','Doctor visit',
   'Va al médico porque desde hace meses sufre dolores de cabeza recurrentes. Quiere asegurarse de que se le hagan las pruebas adecuadas y no quedarse con una respuesta vaga.',
   'Paciente','Médico',
   'Buenos días. Veo en su historial que está aquí por unos dolores de cabeza. Cuénteme con detalle, por favor.', 5),
  (v_lang_id,'B2','Shopping return',
   'Compró un electrodoméstico caro hace seis semanas y se ha estropeado. La tienda intenta no aceptar la devolución y ofrecerle una reparación que tardaría dos meses.',
   'Cliente','Encargada',
   'Buenas tardes. Veo que viene a devolver un producto. ¿Me puede explicar qué problema ha tenido?', 6),
  (v_lang_id,'B2','Travel booking',
   'Llama a una agencia de viajes para organizar un viaje de luna de miel. Quiere algo memorable pero dentro de un presupuesto razonable y prefiere evitar destinos masificados.',
   'Cliente','Agente de viajes',
   'Agencia Encantos del Mundo, buenos días. Me ha dicho mi compañera que está organizando un viaje especial. Cuénteme.', 5),
  (v_lang_id,'B2','Apartment viewing',
   'Visita un piso para alquilar con su pareja. Le interesa pero hay varios detalles importantes (humedades, cocina vieja, comunidad cara) que quiere aclarar antes de comprometerse.',
   'Inquilino potencial','Agente inmobiliario',
   'Pase, pase. Como verá, el piso es muy luminoso. ¿Qué impresión le da nada más entrar?', 5);

  -- =========================================================
  -- C1 — READING PASSAGES (3, 250-300 words)
  -- =========================================================
  insert into public.placement_exam_reading_passages (language_id, level, passage, comprehension_questions) values
  (v_lang_id,'C1',
   'El debate sobre la inteligencia artificial generativa ha llegado al mundo de la creación literaria con una virulencia inesperada. Editoriales, autores y traductores se ven obligados, casi de la noche a la mañana, a tomar partido en una discusión cuyas implicaciones todavía no acabamos de comprender. Para algunos, la IA no es más que una herramienta nueva, comparable al procesador de textos en su día: facilita tareas mecánicas y libera tiempo para lo verdaderamente creativo. Para otros, en cambio, su irrupción supone una amenaza estructural, pues abarata radicalmente la producción de textos y, en consecuencia, devalúa el oficio humano. Lo cierto es que el problema no es sólo económico. Cuando un texto generado por una máquina cumple los criterios de calidad de la prosa tradicional, se ven afectadas categorías tan fundamentales como la autoría, la originalidad o incluso la noción misma de literatura. Quienes minimizan el fenómeno suelen ignorar la velocidad a la que evoluciona la tecnología; quienes lo dramatizan, en cambio, tienden a olvidar que los lectores siguen buscando una voz reconocible. Es probable, en definitiva, que el equilibrio acabe estableciéndose en un espacio intermedio, todavía por delimitar, donde las máquinas asuman el grueso de las tareas repetitivas y los humanos se concentren en aquello que ninguna estadística sabe replicar: la intención, el riesgo y la mirada propia.',
   '[
     {"question":"¿Qué postura defienden quienes minimizan el impacto de la IA?","correct_answer":"Que es sólo una herramienta más, como el procesador de textos","wrong_answers":["Que sustituirá completamente a los autores","Que sólo afectará a las traducciones","Que destruirá el oficio editorial"]},
     {"question":"Según el texto, ¿por qué el problema no es exclusivamente económico?","correct_answer":"Porque pone en cuestión categorías como autoría y originalidad","wrong_answers":["Porque los lectores ya no leen","Porque las máquinas no escriben aún","Porque las editoriales son ricas"]},
     {"question":"¿Cuál es la previsión del autor?","correct_answer":"Que se llegará a un equilibrio intermedio aún por definir","wrong_answers":["Que las máquinas sustituirán a los humanos","Que la tecnología desaparecerá","Que las editoriales prohibirán la IA"]}
   ]'::jsonb),
  (v_lang_id,'C1',
   'La idea de que las ciudades deberían organizarse en torno a las personas, y no a los coches, lleva décadas formulándose, pero sólo en los últimos años ha encontrado un eco político serio. Modelos como el de la "ciudad de los quince minutos", popularizado en París, pretenden que la mayoría de los servicios cotidianos —escuelas, trabajo, comercios, ocio— se encuentren a un cuarto de hora andando o en bicicleta del domicilio. Sus defensores sostienen que un modelo así reduce drásticamente las emisiones, mejora la salud pública y, por extensión, devuelve a las calles una sociabilidad que la motorización masiva había arrinconado. Los detractores, sin embargo, han abierto un frente inesperado: parte de la oposición ha visto en estas medidas un intento velado de restringir la libertad de movimiento, e incluso ha vinculado el modelo con teorías conspirativas. El debate, por tanto, ya no es solamente técnico, sino profundamente cultural y simbólico. Pase lo que pase, queda claro que las decisiones urbanísticas que se tomen en los próximos años condicionarán no sólo el aire que respiremos, sino también la idea misma de comunidad que dejemos a las generaciones venideras.',
   '[
     {"question":"¿En qué consiste la ciudad de los quince minutos?","correct_answer":"Tener los servicios cotidianos a quince minutos a pie o en bici","wrong_answers":["Limitar el tráfico durante quince minutos al día","Cerrar las ciudades quince días al año","Prohibir los coches a partir de las quince horas"]},
     {"question":"¿Qué crítica inesperada ha recibido el modelo?","correct_answer":"Que sería una forma encubierta de restringir libertades","wrong_answers":["Que es demasiado caro","Que sólo funciona en pueblos","Que aumenta la contaminación"]},
     {"question":"¿Qué conclusión sugiere el autor?","correct_answer":"Las decisiones urbanísticas marcarán también la idea de comunidad futura","wrong_answers":["El modelo es indefendible","La oposición tiene siempre razón","El debate es puramente técnico"]}
   ]'::jsonb),
  (v_lang_id,'C1',
   'Llevo varios años trabajando como traductora literaria y, si tuviera que resumir la profesión en una sola idea, diría que consiste en perder con elegancia. Perdemos siempre algo —un juego de palabras, una rima, una textura sonora— y nuestro trabajo, paradójicamente, se mide en lo que logramos conservar a pesar de esas pérdidas. Cuando empecé, creía ingenuamente que existía una traducción óptima esperando ser descubierta. Hoy pienso lo contrario: cada traducción es una hipótesis que el lector valida o rechaza, casi sin saberlo, con sólo seguir leyendo. Sin embargo, sería un error pensar que este escepticismo me ha llevado a la indiferencia. Al contrario: justamente porque sé que ninguna versión es definitiva, me obsesionan los detalles. Una coma desplazada puede salvar o destruir un ritmo, una palabra demasiado culta puede romper una atmósfera popular cuidadosamente construida en el original. El oficio, en realidad, exige una mezcla de humildad y arrogancia: humildad para aceptar que perdemos, arrogancia para decidir, en nombre de un autor que no podrá rebatirnos, qué pérdidas son tolerables.',
   '[
     {"question":"¿Cómo resume la autora la traducción literaria?","correct_answer":"Como un oficio que consiste en perder con elegancia","wrong_answers":["Como una ciencia exacta","Como una pérdida de tiempo","Como una transcripción mecánica"]},
     {"question":"¿Qué evolución personal describe?","correct_answer":"De creer en una traducción óptima a verla como una hipótesis","wrong_answers":["De entusiasta a indiferente","De aficionada a profesional","De escritora a editora"]},
     {"question":"¿Qué dos cualidades exige el oficio, según la autora?","correct_answer":"Humildad y arrogancia, en justa medida","wrong_answers":["Sólo paciencia y disciplina","Erudición y rapidez","Memoria y oído musical"]}
   ]'::jsonb);

  -- =========================================================
  -- C1 — VOCABULARY (10 in bank)
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, order_index) values
  (v_lang_id,'C1','vocabulary','Cabe ____ que los datos disponibles distan aún de ser concluyentes.','destacar',array['destacarse','destacando','destacado'],51),
  (v_lang_id,'C1','vocabulary','Por más que ____, no conseguirás cambiar su opinión sobre el asunto.','insistas',array['insistes','insistirás','insistías'],52),
  (v_lang_id,'C1','vocabulary','En virtud ____ los acuerdos firmados, ambas partes se comprometen a cumplir el calendario.','de',array['a','en','por'],53),
  (v_lang_id,'C1','vocabulary','De ____ sabido antes, habría tomado una decisión muy distinta.','haberlo',array['haber','habiendo','habido'],54),
  (v_lang_id,'C1','vocabulary','El director, ____ trayectoria es ampliamente reconocida, se incorporará la próxima semana.','cuya',array['cuyo','cuyos','cuyas'],55),
  (v_lang_id,'C1','vocabulary','Lejos de ____ triviales, las consecuencias de la decisión han marcado todo el debate.','ser',array['siendo','sido','es'],56),
  (v_lang_id,'C1','vocabulary','Convendría ____ los riesgos con detalle antes de aprobar el proyecto.','analizar',array['analizamos','analizando','analizado'],57),
  (v_lang_id,'C1','vocabulary','No por ello ____ de ser una opción legítima, aunque a algunos no se lo parezca.','deja',array['dejaba','dejará','deje'],58),
  (v_lang_id,'C1','vocabulary','Aunque no me ____ del todo el plan, lo defenderé en la reunión.','convenza',array['convence','convenció','convencerá'],59),
  (v_lang_id,'C1','vocabulary','Su discurso fue tan contundente que ____ todas las dudas que quedaban.','disipó',array['dispuso','dispersó','distinguió'],60);

  -- =========================================================
  -- C1 — DIALOGUE COMPLETION (10 in bank)
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, dialogue_lines, order_index) values
  (v_lang_id,'C1','dialogue','Complete the dialogue with an appropriate Spanish response (at least 2 sentences, sophisticated register).','Permítame discrepar. Si bien los datos parecen claros a primera vista, conviene matizar varios supuestos antes de extraer conclusiones tan tajantes.',array[]::text[],
   '[{"speaker":"Colega","text":"Los resultados son evidentes: hay que ampliar la inversión en este área."},{"speaker":"Tú","text":"___"}]'::jsonb,61),
  (v_lang_id,'C1','dialogue','Complete the dialogue with an appropriate Spanish response.','Lo entiendo, pero me temo que esa decisión generará más problemas a medio plazo de los que pretende resolver. Quizás convendría replanteárnoslo.',array[]::text[],
   '[{"speaker":"Director","text":"La decisión está tomada. A partir del lunes aplicamos el recorte en todos los departamentos."},{"speaker":"Tú","text":"___"}]'::jsonb,62),
  (v_lang_id,'C1','dialogue','Complete the dialogue with an appropriate Spanish response.','Sin entrar en detalles, llevo tiempo replanteándome mi trayectoria profesional. Sentirme estancado me ha llevado a explorar opciones fuera del sector tradicional.',array[]::text[],
   '[{"speaker":"Amigo","text":"Llevas semanas con cara de preocupación. ¿Te pasa algo serio?"},{"speaker":"Tú","text":"___"}]'::jsonb,63),
  (v_lang_id,'C1','dialogue','Complete the dialogue with an appropriate Spanish response.','Por más que valoro tu trabajo, debo señalarte que la última propuesta no ha estado a la altura. Hablémoslo con calma cuando tengas un momento.',array[]::text[],
   '[{"speaker":"Empleada","text":"¿Estás contento con cómo va el proyecto últimamente?"},{"speaker":"Tú","text":"___"}]'::jsonb,64),
  (v_lang_id,'C1','dialogue','Complete the dialogue with an appropriate Spanish response.','Comprendo su postura, pero quisiera recordarles que el contrato establece claramente un plazo distinto. Espero que lleguemos a una solución sin necesidad de medidas drásticas.',array[]::text[],
   '[{"speaker":"Abogado","text":"La empresa argumenta que las circunstancias han cambiado y que el plazo debe revisarse."},{"speaker":"Tú","text":"___"}]'::jsonb,65),
  (v_lang_id,'C1','dialogue','Complete the dialogue with an appropriate Spanish response.','Es una propuesta interesante, aunque me genera dudas la viabilidad financiera. Si pudiéramos verla por escrito, podría comentárselo a mi socio antes del miércoles.',array[]::text[],
   '[{"speaker":"Inversor","text":"¿Le interesaría unirse al proyecto que le acabo de exponer?"},{"speaker":"Tú","text":"___"}]'::jsonb,66),
  (v_lang_id,'C1','dialogue','Complete the dialogue with an appropriate Spanish response.','Aprecio mucho la oferta, sin embargo en este momento de mi vida prefiero centrarme en proyectos personales. Quizás más adelante podamos retomar la conversación.',array[]::text[],
   '[{"speaker":"Reclutador","text":"Nos encantaría que se incorporara a nuestro equipo internacional. ¿Qué le parece?"},{"speaker":"Tú","text":"___"}]'::jsonb,67),
  (v_lang_id,'C1','dialogue','Complete the dialogue with an appropriate Spanish response.','Me cuesta creer que la solución pase por seguir ignorando el problema. Si me lo permites, opino que ya hemos pospuesto la conversación demasiado tiempo.',array[]::text[],
   '[{"speaker":"Pareja","text":"Quizás deberíamos dejar pasar unos meses antes de hablar de mudarnos."},{"speaker":"Tú","text":"___"}]'::jsonb,68),
  (v_lang_id,'C1','dialogue','Complete the dialogue with an appropriate Spanish response.','Aunque entiendo el argumento, me parece que el riesgo de no actuar supera con creces los inconvenientes de hacerlo ahora. Conviene tomar una decisión cuanto antes.',array[]::text[],
   '[{"speaker":"Compañero","text":"Tal vez deberíamos esperar al próximo trimestre antes de mover ficha."},{"speaker":"Tú","text":"___"}]'::jsonb,69),
  (v_lang_id,'C1','dialogue','Complete the dialogue with an appropriate Spanish response.','Le agradezco la franqueza. Es probable que la decisión final no me corresponda a mí, pero pondré sobre la mesa sus argumentos en la reunión del jueves.',array[]::text[],
   '[{"speaker":"Cliente","text":"Espero que tengan en cuenta nuestras necesidades antes de cerrar el contrato."},{"speaker":"Consultor","text":"___"}]'::jsonb,70);

  -- =========================================================
  -- C1 — WRITING (20 in bank)
  -- 6-8 sentences, more abstract/opinion-led.
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, order_index) values
  (v_lang_id,'C1','writing','Write 6-8 Spanish sentences taking a clear position on whether universities should be free at the point of use.','Thesis, two arguments, anticipate a counter-argument, conclusion',array[]::text[],71),
  (v_lang_id,'C1','writing','Write 6-8 Spanish sentences arguing for or against a wealth tax in your country.','Position, justifications, counter, conclusion',array[]::text[],72),
  (v_lang_id,'C1','writing','Write 6-8 Spanish sentences reflecting on what role artificial intelligence should play in education.','Concrete examples, balanced view',array[]::text[],73),
  (v_lang_id,'C1','writing','Write a 6-8 sentence opinion column on whether social media should be regulated as traditional media is.','Position, two arguments, counter, conclusion',array[]::text[],74),
  (v_lang_id,'C1','writing','Write 6-8 Spanish sentences analysing a generational divide that you have observed.','Thesis, contrast, examples, implications',array[]::text[],75),
  (v_lang_id,'C1','writing','Write 6-8 Spanish sentences analysing the impact of mass tourism on a city you know well.','Specific city, pros and cons, recommendation',array[]::text[],76),
  (v_lang_id,'C1','writing','Write 6-8 Spanish sentences explaining why you would or would not move abroad permanently.','Position, three factors, conclusion',array[]::text[],77),
  (v_lang_id,'C1','writing','Write 6-8 Spanish sentences on whether literary translation can ever be fully faithful.','Take a clear stance with at least one concrete example',array[]::text[],78),
  (v_lang_id,'C1','writing','Write 6-8 Spanish sentences about whether public art should be funded by taxes.','Position, two arguments, counter, conclusion',array[]::text[],79),
  (v_lang_id,'C1','writing','Write 6-8 Spanish sentences arguing whether voting should be compulsory.','Position, justifications, counter, conclusion',array[]::text[],80),
  (v_lang_id,'C1','writing','Write 6-8 Spanish sentences on what defines a good political leader today.','Thesis, three qualities with brief defence',array[]::text[],81),
  (v_lang_id,'C1','writing','Write 6-8 Spanish sentences reflecting on whether the concept of national identity still makes sense.','Thesis, historical context, examples, conclusion',array[]::text[],82),
  (v_lang_id,'C1','writing','Write 6-8 Spanish sentences explaining the role of failure in personal growth, using one of your own experiences.','Personal narrative + insight + general claim',array[]::text[],83),
  (v_lang_id,'C1','writing','Write 6-8 Spanish sentences about whether reading classic literature is still relevant.','Thesis, two arguments, counter, conclusion',array[]::text[],84),
  (v_lang_id,'C1','writing','Write 6-8 Spanish sentences proposing a concrete reform to improve your country''s healthcare or education system.','Diagnosis, proposal, expected effects',array[]::text[],85),
  (v_lang_id,'C1','writing','Write 6-8 Spanish sentences on whether economic growth and environmental protection can coexist.','Position, examples, conclusion',array[]::text[],86),
  (v_lang_id,'C1','writing','Write 6-8 Spanish sentences about the difference between freedom and autonomy.','Definitions, contrast, example',array[]::text[],87),
  (v_lang_id,'C1','writing','Write 6-8 Spanish sentences taking a position on whether companies should disclose pay scales publicly.','Thesis, two arguments, counter, conclusion',array[]::text[],88),
  (v_lang_id,'C1','writing','Write 6-8 Spanish sentences analysing the ethical limits of journalism in covering private lives.','Thesis, concrete examples, conclusion',array[]::text[],89),
  (v_lang_id,'C1','writing','Write 6-8 Spanish sentences about what your country could learn from another country''s public policies.','Specific policy, why it works there, transferability',array[]::text[],90);

  -- =========================================================
  -- C1 — ROLEPLAY TOPICS (10, pick 3)
  -- =========================================================
  insert into public.placement_exam_roleplays (language_id, level, topic_label, scenario, user_role, ai_role, ai_opener, target_exchanges) values
  (v_lang_id,'C1','Restaurant',
   'Está en un restaurante de alta cocina con un cliente extranjero al que quiere impresionar. La experiencia ha sido decepcionante: un plato estaba mal preparado y el servicio ha sido descuidado. Quiere expresar su queja con elegancia, sin perder la compostura.',
   'Cliente','Maître',
   'Buenas noches, soy el maître. Permítanme acercarme para asegurarme de que todo está siendo de su agrado.', 6),
  (v_lang_id,'C1','Hotel check-in',
   'Asiste a un congreso internacional y llega al hotel después de un vuelo retrasado. La habitación que le asignan no respeta los requisitos contractuales que negoció previamente con la organización.',
   'Huésped','Recepcionista',
   'Buenas noches, bienvenido. Veo que su reserva forma parte del bloque del congreso. ¿Me permite el pasaporte y le confirmo todos los detalles?', 6),
  (v_lang_id,'C1','Directions',
   'Tiene que llegar a una conferencia donde dará una ponencia. Las indicaciones que le dieron son confusas y queda muy poco tiempo. Pide ayuda a un transeúnte con prisa.',
   'Ponente','Transeúnte',
   'Disculpe, parece que tiene prisa, ¿en qué puedo ayudarle? No tengo mucho tiempo, pero le escucho.', 4),
  (v_lang_id,'C1','Job interview',
   'Tiene una última ronda de entrevista para un puesto directivo internacional. El entrevistador hace preguntas exigentes sobre su trayectoria, su manera de afrontar conflictos y su visión a cinco años.',
   'Candidato','Director general',
   'Encantado de conocerle finalmente en persona. Comencemos por algo concreto: cuénteme un fracaso profesional importante y qué aprendió de él.', 6),
  (v_lang_id,'C1','Weekend plans',
   'Habla con un viejo amigo con el que apenas tiene tiempo de verse. Tienen prioridades distintas para el fin de semana y deben llegar a un compromiso que satisfaga a ambos.',
   'Amigo','Amigo',
   'Por fin coincidimos un sábado. Pero te lo aviso desde ya: no estoy para nada complicado, vengo de una semana imposible.', 5),
  (v_lang_id,'C1','Complaint resolution',
   'Su empresa ha contratado un servicio crítico que está fallando reiteradamente. Tiene una reunión con el responsable comercial del proveedor para reclamar formalmente y negociar compensaciones.',
   'Cliente empresarial','Responsable comercial',
   'Le agradezco que haya aceptado reunirse en persona. Antes de empezar, ¿le importaría exponerme con detalle lo ocurrido las últimas semanas?', 6),
  (v_lang_id,'C1','Doctor visit',
   'Acude a una consulta de seguimiento después de varias pruebas. El médico le da una noticia inesperada y le propone un tratamiento sobre el que usted tiene dudas serias.',
   'Paciente','Especialista',
   'Buenos días. He revisado todas las pruebas y, antes de hablar del tratamiento, quería preguntarle cómo se siente y qué dudas le han ido surgiendo.', 6),
  (v_lang_id,'C1','Shopping return',
   'Adquirió hace meses un objeto de cierto valor. Ha aparecido un defecto que no es responsabilidad suya, y la tienda se niega a aceptar la devolución alegando que el plazo de garantía ha expirado.',
   'Cliente','Gerente',
   'Buenas tardes. Me han comentado que insiste en hablar con la gerencia. ¿Qué le ocurre exactamente?', 6),
  (v_lang_id,'C1','Travel booking',
   'Organiza un viaje de varias semanas por Sudamérica combinando trabajo y vacaciones. Necesita asesoramiento sobre destinos, logística y un presupuesto realista.',
   'Cliente','Agente especializado',
   'Buenos días. Si he entendido bien, busca algo más a medida que un paquete cerrado. Cuénteme con detalle qué tiene en mente.', 5),
  (v_lang_id,'C1','Apartment viewing',
   'Está visitando un piso de alto standing con vistas a alquilarlo. Hay aspectos prácticos y contractuales que quiere negociar antes de comprometerse.',
   'Inquilino potencial','Agente inmobiliario',
   'Adelante, pase. Es uno de los pisos más buscados de la zona, así que se imaginará que tenemos cierta lista de espera. ¿Qué desea ver primero?', 6);

end $$;

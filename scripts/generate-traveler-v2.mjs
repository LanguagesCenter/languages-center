#!/usr/bin/env node
// ============================================================
// generate-traveler-v2.mjs
//
// Traveler course generator — Adventure v2 format.
//
// Emits ONE JSONB row per lesson under content_type='v2_lesson' with
// the shape consumed by <PreviewLessonRunner> (see
// src/lib/traveler-preview.ts for the type definition).
//
// Six lesson types, rotating so no two consecutive lessons share type:
//   sign · menu · audio_announcement · overheard · document · advertisement
//
// IMAGES — all photos come from real stock sources, never generated:
//   - Google Street View Static API for lessons set at a named Madrid
//     street / plaza / exterior landmark (Gran Vía, Puerta del Sol,
//     Plaza Mayor, El Retiro, Atocha, Barajas, taxi lesson exterior,
//     navigation/directions lessons, departures lesson).
//   - Unsplash Search API for every other image lesson. The query is
//     hand-tuned per lesson to match the exact scenario (airport
//     arrivals hall, metro sign, menu, pharmacy green cross, etc.).
//   - Audio lessons MAY carry a "context" photo (location backdrop
//     shown behind the audio player) but do not require one.
//
// After fetch, each image is downloaded and uploaded to the
// `traveler-images` Supabase Storage bucket so the URL stored on the
// row is permanent (Unsplash URLs are stable but the Supabase copy
// insulates us from search API changes).
//
// USAGE
//   node scripts/generate-traveler-v2.mjs [flags]
//
// FLAGS
//   --dry-run              default; hits Anthropic + image APIs but
//                          no DB writes and no Supabase Storage upload
//   --live                 write to Supabase; requires SUPABASE_SERVICE_ROLE_KEY
//   --skip-images          skip image lookup entirely (text content only)
//   --with-images          default; fetch Unsplash / Street View URLs
//   --city <name>          limit (default Madrid)
//   --lesson <N>           only order_index N
//   --lessons <a,b,c>      only these order_index values
//   --limit <N>            cap total lessons processed
//   --resume               skip lessons in progress log (default on)
//   --no-resume            regenerate all
//   --reset                wipe progress log
//   --sleep-ms <N>         pause between lessons (default 400)
//   --verbose              print emitted JSON in dry-run
//
// REQUIRED ENV
//   NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY
//   ANTHROPIC_API_KEY
//   SUPABASE_SERVICE_ROLE_KEY   (only --live)
//   UNSPLASH_ACCESS_KEY         (any image lesson that is not Street View)
//   GOOGLE_MAPS_API_KEY         (any Street View lesson)
// ============================================================

import { readFile, writeFile, mkdir } from "node:fs/promises";
import { readFileSync, existsSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, "..");

// Load .env.local manually (this script is invoked with plain `node`,
// not `next dev`, so Next's env loader isn't in play).
{
  const envPath = resolve(ROOT, ".env.local");
  if (existsSync(envPath)) {
    for (const line of readFileSync(envPath, "utf8").split("\n")) {
      const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/);
      if (m && !process.env[m[1]]) process.env[m[1]] = m[2].replace(/^"|"$/g, "");
    }
  }
}

// ============================================================
// Constants
// ============================================================

const MODEL = "claude-sonnet-4-6";
const ANTHROPIC_URL = "https://api.anthropic.com/v1/messages";
const PROGRESS_PATH = resolve(__dirname, ".traveler-content-progress.json");
const STORAGE_BUCKET = "traveler-images";

// ============================================================
// Madrid 50-lesson plan.
//
// Each entry carries the lesson type + a precise image-source spec:
//   - streetview: real Madrid coordinates for Google Street View Static
//   - unsplash:   search query + a plain-English description of what
//                 the fetched photo depicts, so Claude can write vocab
//                 that matches the image
//   - audio:      no primary image (audio lessons). May optionally carry
//                 a `backdrop` Street View clip for ambience (e.g. the
//                 taxi lesson shows the Barajas exterior).
//
// `visibleText` lists the specific Spanish words/phrases Claude MUST
// teach — these are the words a traveler would literally see in that
// kind of image. Claude's prompt gets this verbatim so the lesson
// content aligns with the image.
// ============================================================

const MADRID_LESSON_PLAN = {
  1:  { type: "sign", image: { source: "unsplash", query: "airport arrivals hall sign terminal international spain", description: "The arrivals hall at Madrid-Barajas Airport Terminal 4, with overhead directional signs pointing travelers to passport control, baggage claim, and the exit.", visibleText: ["LLEGADAS", "LLEGADAS INTERNACIONALES", "CONTROL DE PASAPORTES", "RECOGIDA DE EQUIPAJES", "SALIDA"] } },
  2:  { type: "document", image: { source: "unsplash", query: "airline boarding pass paper ticket flight", description: "A paper airline boarding pass with passenger name, flight number, origin/destination, boarding gate, seat assignment, and boarding time printed on it.", visibleText: ["EMBARQUE", "PUERTA", "ASIENTO", "NOMBRE", "DESTINO", "ORIGEN", "VUELO", "FECHA"] } },
  3:  { type: "overheard", image: { source: "streetview", lat: 40.4983, lng: -3.5676, heading: 90, pitch: 5, description: "The street scene immediately outside the Madrid-Barajas Airport Terminal 4 taxi rank, with white-and-red Madrid taxis queueing by the curb.", visibleText: ["TAXI", "PARADA"] } },
  4:  { type: "document", image: { source: "unsplash", query: "hotel check in form registration paper reception", description: "A paper hotel registration card (ficha de policía) partially filled in with the guest's name, passport number, nationality, dates of stay, and signature line.", visibleText: ["NOMBRE", "APELLIDOS", "PASAPORTE", "NACIONALIDAD", "FECHA DE ENTRADA", "FECHA DE SALIDA", "FIRMA"] } },
  5:  { type: "advertisement", image: { source: "unsplash", query: "hotel brochure spa rooftop luxury room service card", description: "A tabletop in-room hotel brochure card advertising the rooftop spa and mini-bar, with prices in euros and opening hours.", visibleText: ["SPA", "TERRAZA", "MINIBAR", "HORARIO", "ABIERTO", "DESDE", "€", "RESERVAR"] } },
  6:  { type: "sign", image: { source: "unsplash", query: "madrid metro station entrance sign line directions", description: "A Madrid Metro wayfinding sign for Sol station showing Lines 1, 2, and 3 with correspondencia (transfer) arrows and the SALIDA exit arrow.", visibleText: ["METRO", "SOL", "LÍNEA 1", "LÍNEA 2", "LÍNEA 3", "CORRESPONDENCIA", "SALIDA", "ANDÉN", "DIRECCIÓN"] } },
  7:  { type: "advertisement", image: { source: "streetview", lat: 40.4200, lng: -3.7025, heading: 90, pitch: 10, description: "A view down Gran Vía in Madrid, Spain's famous theatre street — tall belle-époque buildings covered in illuminated billboards for musicals and shows.", visibleText: ["GRAN VÍA", "ENTRADAS", "FUNCIÓN", "ESTRENO", "TAQUILLA", "ESCENARIO"] } },
  8:  { type: "overheard", image: { source: "streetview", lat: 40.4229, lng: -3.7014, heading: 180, pitch: 5, description: "A view of Calle Fuencarral in Malasaña, Madrid — a bustling pedestrian shopping street a tourist might walk down while asking a stranger for directions.", visibleText: ["CALLE", "FUENCARRAL", "A LA DERECHA", "A LA IZQUIERDA", "TODO RECTO", "ESQUINA"] } },
  9:  { type: "document", image: { source: "unsplash", query: "madrid metro transport card ticket pass euro", description: "A Madrid Abono Turístico transport card with its paper sleeve showing zones, number of days of validity, and price in euros.", visibleText: ["ABONO TURÍSTICO", "ZONA", "DÍAS", "VALIDEZ", "PRECIO", "ADULTO", "INFANTIL"] } },
  10: { type: "audio_announcement", image: null },
  11: { type: "menu", image: { source: "unsplash", query: "spanish cafe breakfast chalkboard menu tostada coffee", description: "A chalkboard breakfast menu at a Madrid café listing tostadas, café con leche, zumo de naranja, and the daily desayuno combo with prices.", visibleText: ["DESAYUNO", "TOSTADA", "CAFÉ CON LECHE", "CAFÉ SOLO", "ZUMO", "NARANJA", "€"] } },
  12: { type: "overheard", image: { source: "unsplash", query: "spanish food market stall vendor", description: "A view inside Mercado de San Miguel in Madrid showing the fishmonger's stall with vendors calling out prices and fresh seafood on ice.", visibleText: ["MERCADO", "PESCADERÍA", "KILO", "FRESCO", "GAMBAS", "PULPO", "BOQUERONES"] } },
  13: { type: "menu", image: { source: "unsplash", query: "spanish restaurant menu board", description: "A printed paper menú del día from a traditional Madrid restaurant listing primeros, segundos, postres, and 'pan y bebida incluidos' at a fixed price.", visibleText: ["MENÚ DEL DÍA", "ENTRANTES", "PRIMERO", "SEGUNDO", "POSTRE", "PAN Y BEBIDA", "IVA INCLUIDO", "€"] } },
  14: { type: "overheard", image: { source: "unsplash", query: "madrid tapas bar interior counter beer caña spanish", description: "The crowded counter of a Malasaña tapas bar in Madrid — a bartender pouring a caña (small draft beer) and plates of tapas lined up on the bar.", visibleText: ["CAÑA", "TAPA", "RACIÓN", "LA CUENTA", "POR FAVOR", "GRACIAS"] } },
  15: { type: "menu", image: { source: "unsplash", query: "chocolate con churros menu spanish madrid cafe", description: "An interior tiled menu at Chocolatería San Ginés in Madrid listing chocolate con churros, porras, chocolate a la taza, and prices in euros.", visibleText: ["CHOCOLATE", "CHURROS", "PORRAS", "A LA TAZA", "DESDE", "RACIÓN", "€"] } },
  16: { type: "sign", image: { source: "streetview", lat: 40.4203, lng: -3.7050, heading: 220, pitch: 5, description: "A view of Gran Vía in Madrid with a Zara storefront visible, large REBAJAS (sale) signs with percentages in the window.", visibleText: ["REBAJAS", "DESCUENTO", "HASTA", "%", "LIQUIDACIÓN", "ÚLTIMAS UNIDADES"] } },
  17: { type: "document", image: { source: "unsplash", query: "pharmacy prescription receipt medication paper spanish", description: "A Spanish pharmacy prescription receipt (receta médica) listing medication name, dosage, patient name, and date.", visibleText: ["RECETA", "MEDICAMENTO", "DOSIS", "COMPRIMIDOS", "AL DÍA", "FARMACIA", "CADUCIDAD"] } },
  18: { type: "advertisement", image: { source: "streetview", lat: 40.4154, lng: -3.7074, heading: 90, pitch: 0, description: "Plaza Mayor in Madrid — the arcaded central square with souvenir shops along the arcades, flamenco fans and magnets visible in shop windows.", visibleText: ["PLAZA MAYOR", "SOUVENIRS", "RECUERDOS", "FLAMENCO", "ABANICOS", "DESDE", "€"] } },
  19: { type: "overheard", image: { source: "unsplash", query: "madrid rastro flea market vintage clothes stall sunday", description: "A stall at El Rastro Sunday flea market in Madrid with vintage jackets hanging and a vendor behind the counter — the scene of a classic Spanish haggling exchange.", visibleText: ["RASTRO", "¿CUÁNTO ES?", "DESCUENTO", "REGATEAR", "BARATO", "CARO", "TE LO DEJO EN"] } },
  20: { type: "document", image: { source: "unsplash", query: "department store return receipt barcode spanish", description: "A paper return slip from El Corte Inglés in Madrid with the item barcode, article numbers, date, and refund amount.", visibleText: ["DEVOLUCIÓN", "ARTÍCULO", "IMPORTE", "FECHA", "TICKET", "CÓDIGO DE BARRAS"] } },
  21: { type: "sign", image: { source: "unsplash", query: "madrid prado museum ticket entrance sign price", description: "The ticket-window information sign at Museo del Prado in Madrid listing entry prices in euros, opening hours, and the free-admission time slot.", visibleText: ["MUSEO DEL PRADO", "ENTRADA", "GENERAL", "REDUCIDA", "GRATUITA", "HORARIO", "LUNES A DOMINGO"] } },
  22: { type: "audio_announcement", image: null },
  23: { type: "sign", image: { source: "unsplash", query: "madrid reina sofia museum sign guernica picasso interpretive", description: "An interpretive wall sign next to Picasso's Guernica at Museo Reina Sofía in Madrid, with the painting's title, year, dimensions, and a short explanatory paragraph.", visibleText: ["GUERNICA", "PABLO PICASSO", "ÓLEO SOBRE LIENZO", "COLECCIÓN", "SALA", "NO TOCAR"] } },
  24: { type: "audio_announcement", image: null },
  25: { type: "advertisement", image: { source: "streetview", lat: 40.4153, lng: -3.6844, heading: 90, pitch: 0, description: "The entrance to El Retiro Park in Madrid near the lake, where visitors rent rowboats — the kiosk and the Monument to Alfonso XII visible across the water.", visibleText: ["EL RETIRO", "BARCAS", "ALQUILER", "MEDIA HORA", "POR PERSONA", "FIANZA", "€"] } },
  26: { type: "sign", image: { source: "unsplash", query: "spanish supermarket aisle sign mercadona grocery", description: "The aisle-marker signs inside a Mercadona supermarket in Madrid listing panadería, congelados, bebidas, and lácteos with arrow directions.", visibleText: ["PANADERÍA", "CONGELADOS", "BEBIDAS", "LÁCTEOS", "CARNICERÍA", "FRUTERÍA", "CAJA"] } },
  27: { type: "document", image: { source: "unsplash", query: "post office spanish parcel shipping form correos envelope", description: "A Correos parcel-sending form (impreso de envío) partially filled in with sender, recipient, weight, destination country, and declared value.", visibleText: ["CORREOS", "REMITENTE", "DESTINATARIO", "PESO", "DESTINO", "VALOR DECLARADO", "ORDINARIO", "CERTIFICADO"] } },
  28: { type: "sign", image: { source: "unsplash", query: "atm bank spanish screen cash withdrawal menu", description: "The touchscreen of a BBVA ATM in Madrid showing the Spanish-language language selection and cash-withdrawal menu with amount options.", visibleText: ["IDIOMA", "RETIRAR EFECTIVO", "SALDO", "IMPORTE", "CONTINUAR", "CANCELAR", "INTRODUZCA SU PIN"] } },
  29: { type: "document", image: { source: "unsplash", query: "laundromat printed ticket spanish self service receipt", description: "A printed self-service laundromat ticket from a Chamberí lavandería with machine number, cycle, estimated end time, and price.", visibleText: ["LAVANDERÍA", "MÁQUINA", "LAVADO", "SECADO", "FINALIZA", "IMPORTE", "€"] } },
  30: { type: "advertisement", image: { source: "unsplash", query: "spanish gym fitness flyer poster membership classes", description: "A printed gym membership flyer for a Chamberí gimnasio with monthly plans, included classes (yoga, spinning), and a sign-up CTA.", visibleText: ["GIMNASIO", "MATRÍCULA GRATIS", "CUOTA MENSUAL", "CLASES INCLUIDAS", "YOGA", "SPINNING", "APÚNTATE"] } },
  31: { type: "overheard", image: { source: "unsplash", query: "madrid malasaña bar interior friends drinks evening", description: "The crowded interior of a Malasaña bar in Madrid at night where two Madrileños in their 20s are chatting with a stranger over drinks.", visibleText: ["¿TE APETECE?", "RONDA", "INVITO YO", "CHAMPÚ", "SALUD"] } },
  32: { type: "audio_announcement", image: null },
  33: { type: "overheard", image: null },
  34: { type: "menu", image: { source: "unsplash", query: "la latina madrid tapas chalkboard menu specials", description: "A chalkboard tapas menu at a restaurant in La Latina, Madrid, listing the day's specials — croquetas, tortilla, patatas bravas — with prices.", visibleText: ["ESPECIALIDADES DEL DÍA", "CROQUETAS", "TORTILLA", "PATATAS BRAVAS", "RACIÓN", "MEDIA RACIÓN", "€"] } },
  35: { type: "overheard", image: { source: "unsplash", query: "madrid mercado cebada market vendor customer dispute order", description: "A vendor and customer at Mercado de la Cebada in Madrid trying to sort out a mistaken order at the vegetable stall.", visibleText: ["PERDONE", "NO ES LO QUE PEDÍ", "SE HA EQUIVOCADO", "LO SIENTO", "¿ME CAMBIA?"] } },
  36: { type: "menu", image: { source: "unsplash", query: "spanish sherry list wine bar fino manzanilla chalkboard", description: "The vertical chalkboard sherry list at La Venencia in La Latina, Madrid, listing fino, manzanilla, oloroso, amontillado, and palo cortado with prices per copa.", visibleText: ["FINO", "MANZANILLA", "OLOROSO", "AMONTILLADO", "PALO CORTADO", "COPA", "€"] } },
  37: { type: "advertisement", image: { source: "unsplash", query: "spanish nightclub flyer poster neon dj dance", description: "A Pachá Madrid nightclub flyer for the weekend's DJ line-up — neon type on a dark background with dates and door times.", visibleText: ["PACHÁ MADRID", "DJ", "VIERNES", "SÁBADO", "APERTURA", "ENTRADA", "LISTA"] } },
  38: { type: "sign", image: { source: "unsplash", query: "flamenco venue sign madrid exterior theatre spanish", description: "The exterior venue sign at Corral de la Morería, Madrid, advertising the evening flamenco cuadro — artists' names, show time, and ticket price.", visibleText: ["FLAMENCO", "CUADRO", "ARTISTAS", "FUNCIÓN", "RESERVA", "ENTRADA"] } },
  39: { type: "audio_announcement", image: null },
  40: { type: "sign", image: { source: "unsplash", query: "cinema marquee movie theater sign night", description: "The illuminated Cines Callao marquee in Madrid showing three movie titles, screening times, and ticket prices in Spanish.", visibleText: ["CINE", "SESIÓN", "ENTRADA", "SALA", "TAQUILLA", "V.O.S.E.", "APTA PARA TODOS LOS PÚBLICOS"] } },
  41: { type: "document", image: { source: "unsplash", query: "handwritten form paperwork pen desk", description: "A Metro Madrid lost-and-found (objetos perdidos) claim form filled in with the description of a lost wallet, date, line and station.", visibleText: ["OBJETOS PERDIDOS", "DESCRIPCIÓN", "FECHA DE PÉRDIDA", "LÍNEA", "ESTACIÓN", "DATOS PERSONALES"] } },
  42: { type: "overheard", image: { source: "unsplash", query: "spanish doctor patient clinic consultation office", description: "A general-practice doctor at a Chueca Centro de Salud in Madrid speaking to a foreign patient across a desk.", visibleText: ["¿QUÉ LE OCURRE?", "ME DUELE", "DESDE CUÁNDO", "RECETA", "FIEBRE", "CABEZA", "GARGANTA"] } },
  43: { type: "document", image: { source: "unsplash", query: "spanish police report form denuncia theft paper", description: "A Policía Nacional denuncia form in Madrid, partially completed in Spanish, for a stolen wallet with description, time, and place of the incident.", visibleText: ["DENUNCIA", "ROBO", "HURTO", "LUGAR DE LOS HECHOS", "FECHA", "DESCRIPCIÓN DE LO SUSTRAÍDO", "DNI/PASAPORTE"] } },
  44: { type: "sign", image: { source: "unsplash", query: "spanish phone store service ticket queue number sign", description: "The in-store service signage at Vodafone Gran Vía in Madrid — a 'Pídelo aquí' numbered-ticket dispenser with the current turno (turn) displayed.", visibleText: ["PÍDELO AQUÍ", "TURNO", "ESPERE SU TURNO", "ATENCIÓN AL CLIENTE", "CAJA"] } },
  45: { type: "document", image: { source: "unsplash", query: "bus stop schedule timetable printed", description: "An EMT Madrid night-bus (búho) printed timetable stuck to a Sol bus stop, listing route N1, intermediate stops, and arrival times.", visibleText: ["EMT", "BÚHO", "LÍNEA N1", "PARADA", "SALIDA", "LLEGADA", "FRECUENCIA", "LABORABLES", "FESTIVOS"] } },
  46: { type: "audio_announcement", image: null },
  47: { type: "overheard", image: null },
  48: { type: "sign", image: { source: "streetview", lat: 40.4983, lng: -3.5676, heading: 270, pitch: 10, description: "The exterior of Madrid-Barajas Airport Terminal 4 at the drop-off curb — travelers heading to departures with luggage trolleys.", visibleText: ["SALIDAS", "FACTURACIÓN", "EMBARQUE", "SEGURIDAD", "PUERTA", "T4"] } },
  49: { type: "advertisement", image: { source: "unsplash", query: "duty free airport perfume jamon display sign price promotion", description: "A duty-free promotional display at Barajas Terminal 4 for perfume and jamón ibérico, with 'Duty Free' and 'Promoción' signage and prices in euros.", visibleText: ["DUTY FREE", "PROMOCIÓN", "AHORRE", "DESDE", "PERFUMERÍA", "JAMÓN IBÉRICO", "€"] } },
  50: { type: "audio_announcement", image: null },
};

// ============================================================
// Recurring Madrid characters (context for overheard scripts)
// ============================================================

const MADRID_CHARACTERS = {
  Carlos: { role: "middle-aged Madrid taxi driver from Chueca; Real Madrid fan; warm, chatty, thick Madrileño accent", gender: "male", firstAppearance: 3 },
  Maria:  { role: "hotel receptionist in her 30s at your Chueca hotel; professional and warm", gender: "female", firstAppearance: 4 },
  Ana:    { role: "art history student in her 20s from Malasaña; becomes your local friend late in the trip; curious, patient", gender: "female", firstAppearance: 33 },
};

// ============================================================
// CLI
// ============================================================

function parseArgs(argv) {
  const flags = {
    dryRun: true, live: false, withImages: true,
    resume: true, reset: false, verbose: false,
    city: "Madrid", lesson: null, lessons: null, limit: null,
    sleepMs: 400,
  };
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--dry-run") { flags.dryRun = true; flags.live = false; }
    else if (a === "--live") { flags.live = true; flags.dryRun = false; }
    else if (a === "--skip-images") { flags.withImages = false; }
    else if (a === "--with-images") { flags.withImages = true; }
    else if (a === "--resume") { flags.resume = true; }
    else if (a === "--no-resume") { flags.resume = false; }
    else if (a === "--reset") { flags.reset = true; }
    else if (a === "--verbose") { flags.verbose = true; }
    else if (a === "--city") { flags.city = argv[++i]; }
    else if (a === "--lesson") { flags.lesson = parseInt(argv[++i], 10); }
    else if (a === "--lessons") { flags.lessons = argv[++i].split(",").map((n) => parseInt(n, 10)); }
    else if (a === "--limit") { flags.limit = parseInt(argv[++i], 10); }
    else if (a === "--sleep-ms") { flags.sleepMs = parseInt(argv[++i], 10); }
    else { console.error(`unknown flag: ${a}`); process.exit(1); }
  }
  return flags;
}

function requireEnv(name) {
  const v = process.env[name];
  if (!v) { console.error(`Missing env: ${name}`); process.exit(1); }
  return v;
}

// ============================================================
// Retry
// ============================================================

function markRetryable(err) { err.retryable = true; return err; }

async function withRetry(label, fn, { maxAttempts = 5, baseDelayMs = 800 } = {}) {
  let lastErr;
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try { return await fn(); }
    catch (err) {
      lastErr = err;
      if (err?.retryable !== true || attempt === maxAttempts) throw err;
      const delay = baseDelayMs * Math.pow(2, attempt - 1);
      console.error(`[retry] ${label} attempt ${attempt} failed (${err.message.slice(0, 200)}); waiting ${delay}ms`);
      await new Promise((r) => setTimeout(r, delay));
    }
  }
  throw lastErr;
}

// ============================================================
// Supabase REST
// ============================================================

function makeSupabase({ url, key }) {
  const base = url.replace(/\/$/, "");
  const headers = { apikey: key, Authorization: `Bearer ${key}`, "Content-Type": "application/json" };
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
    get:    (path)        => withRetry(`GET ${path}`,    () => req("GET",    path)),
    post:   (path, body)  => withRetry(`POST ${path}`,   () => req("POST",   path, { body, prefer: "return=representation" })),
    patch:  (path, body)  => withRetry(`PATCH ${path}`,  () => req("PATCH",  path, { body, prefer: "return=representation" })),
    delete: (path)        => withRetry(`DELETE ${path}`, () => req("DELETE", path)),
  };
}

// ============================================================
// Anthropic
// ============================================================

async function callClaude({ apiKey, systemPrompt, userPrompt, maxTokens = 4000 }) {
  return withRetry("anthropic", async () => {
    const res = await fetch(ANTHROPIC_URL, {
      method: "POST",
      headers: {
        "x-api-key": apiKey,
        "anthropic-version": "2023-06-01",
        "content-type": "application/json",
      },
      body: JSON.stringify({
        model: MODEL,
        max_tokens: maxTokens,
        system: systemPrompt,
        messages: [{ role: "user", content: userPrompt }],
      }),
    });
    if (!res.ok) {
      const text = await res.text().catch(() => "");
      const err = new Error(`anthropic ${res.status}: ${text.slice(0, 400)}`);
      if (res.status === 429 || res.status >= 500) markRetryable(err);
      throw err;
    }
    const json = await res.json();
    const text = json.content?.[0]?.text ?? "";
    return { text, usage: json.usage };
  });
}

function extractJson(text) {
  let s = text.trim();
  if (s.startsWith("```")) {
    s = s.replace(/^```(?:json)?\s*\n?/, "").replace(/\n?```\s*$/, "");
  }
  const first = s.indexOf("{");
  const last = s.lastIndexOf("}");
  if (first !== -1 && last !== -1 && last > first) s = s.slice(first, last + 1);
  return JSON.parse(s);
}

// ============================================================
// Image sources — Unsplash Search API + Google Street View Static
// ============================================================

// Fetch up to N Unsplash candidates for a query so the caller can walk
// the list and skip bad matches that vision flags as unsuitable.
async function fetchUnsplashCandidates({ query, accessKey, perPage = 8 }) {
  return withRetry(`unsplash:${query.slice(0, 40)}`, async () => {
    const u = new URL("https://api.unsplash.com/search/photos");
    u.searchParams.set("query", query);
    u.searchParams.set("per_page", String(perPage));
    u.searchParams.set("orientation", "landscape");
    u.searchParams.set("content_filter", "high");
    const res = await fetch(u, {
      headers: {
        Authorization: `Client-ID ${accessKey}`,
        "Accept-Version": "v1",
      },
    });
    if (!res.ok) {
      const text = await res.text().catch(() => "");
      const err = new Error(`unsplash ${res.status}: ${text.slice(0, 200)}`);
      if (res.status === 429 || res.status >= 500) markRetryable(err);
      throw err;
    }
    const json = await res.json();
    const results = Array.isArray(json.results) ? json.results : [];
    return results
      .map((r) => r.urls?.regular ?? r.urls?.full ?? r.urls?.small)
      .filter(Boolean);
  });
}

// Build a Google Street View Static API URL. The URL itself IS the
// image — we don't fetch it client-side, we download it in `fetchImage`
// below and upload the bytes to Supabase Storage.
function buildStreetViewUrl({ lat, lng, heading = 0, pitch = 0, apiKey }) {
  const u = new URL("https://maps.googleapis.com/maps/api/streetview");
  u.searchParams.set("size", "800x500");
  u.searchParams.set("location", `${lat},${lng}`);
  u.searchParams.set("heading", String(heading));
  u.searchParams.set("pitch", String(pitch));
  u.searchParams.set("fov", "90");
  u.searchParams.set("key", apiKey);
  return u.toString();
}

// Given a resolved external URL (Unsplash CDN or Street View endpoint),
// download its bytes.
async function fetchImageBytes(url) {
  return withRetry("download-image", async () => {
    const res = await fetch(url);
    if (!res.ok) {
      const err = new Error(`download ${url.slice(0, 80)} ${res.status}`);
      if (res.status === 429 || res.status >= 500) markRetryable(err);
      throw err;
    }
    const buf = new Uint8Array(await res.arrayBuffer());
    if (buf.byteLength < 1024) {
      throw new Error(`download too small (${buf.byteLength}B) — likely error response`);
    }
    return buf;
  });
}

// ============================================================
// Vision — have Claude look at the fetched image and extract the
// actual visible content before we write the lesson. This is what
// closes the loop between "image we got" and "lesson we author" so
// the content is grounded in the real photo rather than in a hint.
// ============================================================

function bytesToBase64(bytes) {
  let binary = "";
  for (let i = 0; i < bytes.byteLength; i++) binary += String.fromCharCode(bytes[i]);
  return Buffer.from(binary, "binary").toString("base64");
}

async function describeImageWithClaude({ apiKey, bytes, mediaType, planHint }) {
  const hintBlock = planHint
    ? `Planning hint (may or may not match the actual image you're looking at):
  Lesson scenario: ${planHint.description}
  Suggested Spanish words to look for (ignore if they aren't actually visible): ${(planHint.visibleText ?? []).join(", ") || "(none)"}`
    : "";
  const userText = `Look at this photo and describe exactly what is in it, for an immersive Spanish-learning lesson set in Madrid.

${hintBlock}

Respond with ONE JSON object:
{
  "sceneDescription": "A 1-2 sentence description of what the photo actually shows. Be literal — if the planning hint said 'metro sign' but the photo shows a street scene, describe the street scene.",
  "visibleText": ["<every piece of Spanish or multilingual text / signage / branding you can read in the image, verbatim>"],
  "visibleObjects": ["<up to 6 notable objects or elements a traveler would notice>"],
  "suitableForMadridLesson": true | false,
  "unsuitableReason": "<if false: 1 sentence why — e.g., 'photo is clearly not Spain / not Madrid / off-topic'. omit if true.>"
}

Return only JSON. No prose. No code fences.`;

  const res = await withRetry("anthropic-vision", async () => {
    const r = await fetch(ANTHROPIC_URL, {
      method: "POST",
      headers: {
        "x-api-key": apiKey,
        "anthropic-version": "2023-06-01",
        "content-type": "application/json",
      },
      body: JSON.stringify({
        model: MODEL,
        max_tokens: 800,
        messages: [{
          role: "user",
          content: [
            { type: "image", source: { type: "base64", media_type: mediaType, data: bytesToBase64(bytes) } },
            { type: "text", text: userText },
          ],
        }],
      }),
    });
    if (!r.ok) {
      const text = await r.text().catch(() => "");
      const err = new Error(`anthropic-vision ${r.status}: ${text.slice(0, 400)}`);
      if (r.status === 429 || r.status >= 500) markRetryable(err);
      throw err;
    }
    return r.json();
  });

  const text = res.content?.[0]?.text ?? "";
  return extractJson(text);
}

// ============================================================
// Supabase Storage upload
// ============================================================

function citySlug(city) {
  return city.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
}

function storagePathFor(city, orderIndex) {
  return `${citySlug(city)}/L${orderIndex}.jpg`;
}

function publicStorageUrl(supabaseUrl, path) {
  return `${supabaseUrl.replace(/\/$/, "")}/storage/v1/object/public/${STORAGE_BUCKET}/${path}`;
}

async function uploadToStorage({ supabaseUrl, serviceKey, path, bytes }) {
  return withRetry(`upload ${path}`, async () => {
    const res = await fetch(
      `${supabaseUrl.replace(/\/$/, "")}/storage/v1/object/${STORAGE_BUCKET}/${path}`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${serviceKey}`,
          apikey: serviceKey,
          "Content-Type": "image/jpeg",
          "x-upsert": "true",
        },
        body: bytes,
      },
    );
    if (!res.ok) {
      const text = await res.text().catch(() => "");
      const err = new Error(`storage upload ${res.status}: ${text.slice(0, 200)}`);
      if (res.status === 429 || res.status >= 500) markRetryable(err);
      throw err;
    }
    return await res.json().catch(() => ({}));
  });
}

// Resolve the lesson's image plan: fetch URL, download bytes, run
// Claude vision to describe what the photo actually shows, and (in
// live mode) upload to Supabase Storage.
//
// Returns { url, source, vision } where `vision` holds the ground-truth
// scene description + visible-text list extracted from the real photo.
// The content prompt uses `vision` (not the plan hint) so the generated
// lesson is grounded in what the learner will actually see.
async function resolveAndStashImage({
  plan, city, orderIndex,
  unsplashKey, mapsKey, anthropicKey,
  supabaseUrl, serviceKey,
  skipUpload,
}) {
  if (!plan.image) return null;
  const img = plan.image;

  // Build candidate URL list. Street View always has one candidate
  // (the pano for that lat/lng). Unsplash gives us up to 8 so we can
  // walk down the list if vision flags the top hit as unsuitable.
  let candidates;
  if (img.source === "streetview") {
    if (!mapsKey) throw new Error(`L${orderIndex}: Street View lesson requires GOOGLE_MAPS_API_KEY`);
    candidates = [buildStreetViewUrl({
      lat: img.lat, lng: img.lng,
      heading: img.heading ?? 0, pitch: img.pitch ?? 0,
      apiKey: mapsKey,
    })];
  } else if (img.source === "unsplash") {
    if (!unsplashKey) throw new Error(`L${orderIndex}: Unsplash lesson requires UNSPLASH_ACCESS_KEY`);
    candidates = await fetchUnsplashCandidates({ query: img.query, accessKey: unsplashKey });
    if (candidates.length === 0) throw new Error(`unsplash: no results for "${img.query}"`);
  } else {
    throw new Error(`L${orderIndex}: unknown image source "${img.source}"`);
  }

  // Walk candidates, keeping the first one vision rates as suitable.
  // If none pass, keep the first candidate anyway (so the lesson still
  // gets an image) and surface the warning in `vision.unsuitableReason`.
  let chosen = null;
  let fallback = null;
  for (let i = 0; i < candidates.length; i++) {
    const url = candidates[i];
    const bytes = await fetchImageBytes(url);
    const vision = await describeImageWithClaude({
      apiKey: anthropicKey, bytes, mediaType: "image/jpeg", planHint: img,
    });
    const attempt = { url, bytes, vision, candidateIndex: i };
    if (!fallback) fallback = attempt;
    if (vision.suitableForMadridLesson !== false) {
      chosen = attempt;
      break;
    }
    console.log(`         VISION-SKIP candidate ${i + 1}/${candidates.length}: ${vision.unsuitableReason ?? "unsuitable"}`);
  }
  const picked = chosen ?? fallback;

  if (skipUpload) {
    return { url: picked.url, source: img.source, vision: picked.vision, candidateIndex: picked.candidateIndex };
  }

  const path = storagePathFor(city, orderIndex);
  await uploadToStorage({ supabaseUrl, serviceKey, path, bytes: picked.bytes });
  return { url: publicStorageUrl(supabaseUrl, path), source: img.source, vision: picked.vision, candidateIndex: picked.candidateIndex };
}

// ============================================================
// Prompt templates
// ============================================================

const SYSTEM_PROMPT = `You are an expert Spanish-language lesson author for an immersive traveler's course app called Languages Center. You write authentic, culturally accurate lesson content set in Madrid, Spain. You are fluent in Madrileño Spanish (Castilian, ceceo, vosotros where natural).

You always respond with a single JSON object matching the schema the user gives you. Use the EXACT field names given — do not rename them. Never wrap the response in markdown code fences. Never add prose before or after the JSON.`;

const EXERCISE_SCHEMA = `Each gatedExercise MUST be one of these FOUR shapes, using the EXACT field names shown:
  Multiple choice:
    { "kind": "multiple_choice", "question": "<English question>", "correct": "<the right option>", "wrong": ["<distractor>", "<distractor>", "<distractor>"] }
  Tap the correct word:
    { "kind": "tap_word", "prompt": "<English prompt>", "correct": "<the right Spanish/English token>", "distractors": ["<other>", "<other>", "<other>"] }
  Speaking aloud:
    { "kind": "speaking", "prompt": "<English prompt e.g. 'Say it aloud'>", "expected": "<Spanish text the learner must say>", "translation": "<English of the expected Spanish>" }
  Fill in the blank:
    { "kind": "fill_blank", "prompt": "<English or Spanish sentence with ______ for the blank>", "correct": "<answer that fills the blank>", "hint": "<optional short hint>" }
Do not use any other kind values. Do not rename question/correct/wrong to prompt/options/answer.`;

const QUIZ_SCHEMA = `Each endQuiz item MUST be one of these four shapes, using the EXACT field names shown:
  { "kind": "multiple_choice", "question": "<English>", "correct": "<right option>", "wrong": ["<d>", "<d>", "<d>"] }
  { "kind": "fill_blank", "prompt": "<English sentence with ______ for the blank>", "correct": "<Spanish or English answer that fills the blank>", "hint": "<optional short hint>" }
  { "kind": "listening", "audio": "<Spanish text the learner will hear via TTS>", "question": "<English question about the audio>", "correct": "<right option>", "wrong": ["<d>", "<d>", "<d>"] }
  { "kind": "speaking", "prompt": "<English prompt>", "expected": "<Spanish to say>", "translation": "<English of expected>" }`;

function buildContextBlock(prior) {
  const chars = Object.entries(MADRID_CHARACTERS).map(([n, c]) => `  - ${n} (${c.role}) [first appears L${c.firstAppearance}]`).join("\n");
  const vocab = prior.recentVocab.length
    ? prior.recentVocab.map((v) => `  - ${v.word} = ${v.english} (introduced L${v.firstLesson})`).join("\n")
    : "  (none yet — this is early in the trip)";
  const recap = prior.priorRecap ?? "(no prior lesson — this is the trip's opening moment)";
  return `Trip so far — one-sentence recap of the previous lesson to open this one:
${recap}

Recurring locals available:
${chars}

Recent vocab introduced (recycle at least 2 items where natural):
${vocab}
`;
}

// Build an "IMAGE CONTEXT" block that pins Claude's content to what the
// learner will actually see. We feed in the vision analysis of the
// REAL fetched photo (not the planning hint) so the lesson can't drift
// from the image.
function imageContextBlock({ source, vision }) {
  if (!vision) return "";
  const sourceLabel = source === "streetview"
    ? "Google Street View photo (real Madrid location)"
    : "Stock photo";
  const visibleList = (vision.visibleText ?? []).map((w) => `  - ${w}`).join("\n");
  const objectList = (vision.visibleObjects ?? []).map((o) => `  - ${o}`).join("\n");
  return `
IMAGE CONTEXT — this is what the learner is literally looking at (extracted by analyzing the actual photo, not a plan):
  Source:      ${sourceLabel}
  Scene:       ${vision.sceneDescription}
  Visible objects / notable elements:
${objectList || "  (none noted)"}
  VERBATIM text visible in the image (Spanish or multilingual signage, menus, forms, etc.):
${visibleList || "  (no legible text visible — build the lesson around the visible objects / scene)"}

CRITICAL — the lesson MUST be built around THIS specific photo. Every decodeStep must be a word or phrase that is literally visible in the image above or that a traveler would need to understand the scene. buildup.fullEnglish must translate the visible text (not generic travel phrases). Do NOT invent Spanish vocabulary that isn't rooted in what's shown.
`;
}

function visualPrompt({ orderIndex, title, location, type, image, vision, priorCtx }) {
  return `You are writing Lesson ${orderIndex} of a 50-lesson Madrid traveler course.

LESSON META
- Title: "${title}"
- Location: "${location}"
- Type: ${type}  (image-based — the learner sees ONE real photo of this scene and decodes it)

${imageContextBlock({ source: image?.source, vision })}
${buildContextBlock(priorCtx)}

Write ONE JSON object with EXACTLY this shape:

{
  "scene": "A 1-2 sentence second-person scene-setter that references what the learner sees in the photo. E.g., 'You step off the escalator at Sol Metro. You see this wayfinding sign overhead.'",
  "storyRecap": "One sentence that will open the NEXT lesson, referring back to what happened here.",
  "opening": {
    "kind": "image",
    "fullSignText": "The Spanish text/words visible in the image, formatted for humans (· separators are fine for a sign; line breaks for a menu/document).",
    "imageAlt": "One sentence of accessibility alt text describing the image."
  },
  "decodeSteps": [
    {
      "wordOrPhrase": "Spanish word or short phrase visible in / implied by the image",
      "phonetic": "[phonetic guide in brackets, English speaker friendly]",
      "english": "English translation",
      "mnemonic": "A one-sentence memory hook — sound-alike or English cognate connection.",
      "culturalNote": "A one-sentence Madrid-specific tip. Optional — omit the field if not relevant.",
      "gatedExercise": { …see EXERCISE SCHEMA below… }
    }
  ],
  "buildup": {
    "fullEnglish": "The full English translation of the Spanish visible in the image.",
    "celebrationMessage": "One warm sentence celebrating that the learner just read authentic Spanish from a real photo."
  },
  "endQuiz": [ …see QUIZ SCHEMA below… ]
}

EXERCISE SCHEMA
${EXERCISE_SCHEMA}

QUIZ SCHEMA
${QUIZ_SCHEMA}

REQUIREMENTS:
- decodeSteps: 5 to 7 items drawn from the IMAGE CONTEXT visible-text list. Vary gatedExercise.kind across steps. NEVER put the same kind twice in a row. Include at least one "speaking" step.
- endQuiz: exactly 5 items covering ONLY vocab from THIS lesson's image. Include at least three different kinds.
- All Spanish text must be authentic Madrileño register.
- Return only the JSON. No prose, no code fences.`;
}

function audioPrompt({ orderIndex, title, location, type, subject, priorCtx }) {
  return `You are writing Lesson ${orderIndex} of a 50-lesson Madrid traveler course.

LESSON META
- Title: "${title}"
- Location: "${location}"
- Type: ${type}  (audio-based — the learner hears a Spanish clip with NO transcript, then decodes it word-by-word)
- Audio subject: ${subject}

${buildContextBlock(priorCtx)}

Write ONE JSON object with EXACTLY this shape:

{
  "scene": "A 1-2 sentence second-person scene-setter. E.g., 'You slide into a taxi at Barajas. Listen — no transcript.'",
  "storyRecap": "One sentence that will open the NEXT lesson.",
  "opening": {
    "kind": "audio",
    "durationHint": "~15 seconds",
    "script": [
      { "speaker": "Driver" | "Carlos" | "Announcer" | "Vendor" | ..., "gender": "male" | "female", "text": "<Spanish line>", "pauseAfterMs": 1200 }
    ]
  },
  "decodeSteps": [
    {
      "wordOrPhrase": "Spanish word or short phrase pulled from the script",
      "phonetic": "[phonetic guide]",
      "english": "English translation",
      "mnemonic": "One-sentence memory hook.",
      "culturalNote": "Optional one-sentence Madrid tip — omit if not relevant.",
      "audioSnippet": "The exact substring from opening.script[].text that this word/phrase appears in. Required for audio lessons — used to replay that portion.",
      "gatedExercise": { …see EXERCISE SCHEMA below… }
    }
  ],
  "buildup": {
    "fullEnglish": "Full English translation of the whole audio clip.",
    "celebrationMessage": "One warm sentence."
  },
  "endQuiz": [ …see QUIZ SCHEMA below… ]
}

EXERCISE SCHEMA
${EXERCISE_SCHEMA}

QUIZ SCHEMA
${QUIZ_SCHEMA}

REQUIREMENTS:
- opening.script: 2 to 5 lines totalling 12-25 seconds of speech.
- For overheard lessons where the location fits a recurring character (Carlos / María / Ana), USE that character as a speaker and keep the voice consistent with the profile.
- decodeSteps: 5 to 7 items, each with an audioSnippet drawn verbatim from opening.script[].text. Vary gatedExercise.kind; never same kind twice in a row; include at least one "speaking" step.
- endQuiz: exactly 5 items. Include at least one "listening" question and at least three different kinds overall.
- All Spanish must be authentic Madrileño register.
- Return only the JSON. No prose, no code fences.`;
}

// ============================================================
// Validation
// ============================================================

const EXERCISE_KINDS = new Set(["multiple_choice", "tap_word", "speaking", "fill_blank"]);
const QUIZ_KINDS = new Set(["multiple_choice", "fill_blank", "listening", "speaking"]);

function assertShape(v2, mediumExpected) {
  if (!v2 || typeof v2 !== "object") throw new Error("root is not an object");
  if (typeof v2.scene !== "string" || !v2.scene) throw new Error("scene missing");
  if (!v2.opening || typeof v2.opening !== "object") throw new Error("opening missing");
  const kind = v2.opening.kind;
  if (mediumExpected === "image" && kind !== "image") throw new Error(`expected opening.kind='image', got '${kind}'`);
  if (mediumExpected === "audio" && kind !== "audio") throw new Error(`expected opening.kind='audio', got '${kind}'`);
  if (kind === "image") {
    if (!v2.opening.fullSignText) throw new Error("opening.fullSignText missing");
  } else {
    if (!Array.isArray(v2.opening.script) || v2.opening.script.length < 1) throw new Error("opening.script missing");
  }
  if (!Array.isArray(v2.decodeSteps) || v2.decodeSteps.length < 3) throw new Error("decodeSteps missing / too few");
  for (const [i, s] of v2.decodeSteps.entries()) {
    if (!s.wordOrPhrase || !s.english || !s.mnemonic) throw new Error(`decodeSteps[${i}] missing fields`);
    if (!s.gatedExercise || !EXERCISE_KINDS.has(s.gatedExercise.kind)) throw new Error(`decodeSteps[${i}].gatedExercise invalid`);
    if (mediumExpected === "audio" && !s.audioSnippet) throw new Error(`decodeSteps[${i}].audioSnippet missing (required for audio)`);
  }
  for (let i = 1; i < v2.decodeSteps.length; i++) {
    if (v2.decodeSteps[i].gatedExercise.kind === v2.decodeSteps[i - 1].gatedExercise.kind) {
      throw new Error(`decodeSteps ${i - 1} and ${i} share exercise kind '${v2.decodeSteps[i].gatedExercise.kind}'`);
    }
  }
  if (!v2.buildup?.fullEnglish) throw new Error("buildup.fullEnglish missing");
  if (!Array.isArray(v2.endQuiz) || v2.endQuiz.length < 3) throw new Error("endQuiz missing / too few");
  for (const [i, q] of v2.endQuiz.entries()) {
    if (!QUIZ_KINDS.has(q.kind)) throw new Error(`endQuiz[${i}].kind invalid: ${q.kind}`);
  }
}

// ============================================================
// Progress log
// ============================================================

async function loadProgress(reset) {
  if (!existsSync(PROGRESS_PATH)) {
    return { started_at: new Date().toISOString(), completed_lessons_v2: {}, vocab_v2: [] };
  }
  let parsed;
  try { parsed = JSON.parse(await readFile(PROGRESS_PATH, "utf-8")); }
  catch { parsed = {}; }
  if (reset) {
    parsed.completed_lessons_v2 = {};
    parsed.vocab_v2 = [];
    parsed.v2_reset_at = new Date().toISOString();
  } else {
    parsed.completed_lessons_v2 = parsed.completed_lessons_v2 ?? {};
    parsed.vocab_v2 = parsed.vocab_v2 ?? [];
  }
  return parsed;
}

async function saveProgress(progress) {
  await mkdir(dirname(PROGRESS_PATH), { recursive: true });
  await writeFile(PROGRESS_PATH, JSON.stringify(progress, null, 2));
}

function priorContextFor(progress, city, orderIndex) {
  const prior = Object.values(progress.completed_lessons_v2)
    .filter((e) => e.city === city && e.order < orderIndex)
    .sort((a, b) => b.order - a.order);
  const priorRecap = prior[0]?.storyRecap ?? null;
  const recentVocab = (progress.vocab_v2 ?? [])
    .filter((v) => v.city === city && v.firstLesson < orderIndex)
    .sort((a, b) => b.firstLesson - a.firstLesson)
    .slice(0, 15);
  return { priorRecap, recentVocab };
}

// ============================================================
// Main
// ============================================================

async function main() {
  const flags = parseArgs(process.argv);
  const supabaseUrl = requireEnv("NEXT_PUBLIC_SUPABASE_URL");
  const anonKey = requireEnv("NEXT_PUBLIC_SUPABASE_ANON_KEY");
  const anthropicKey = requireEnv("ANTHROPIC_API_KEY");
  const serviceKey = flags.live ? requireEnv("SUPABASE_SERVICE_ROLE_KEY") : null;
  const unsplashKey = flags.withImages ? (process.env.UNSPLASH_ACCESS_KEY ?? null) : null;
  const mapsKey = flags.withImages ? (process.env.GOOGLE_MAPS_API_KEY ?? null) : null;

  const readClient = makeSupabase({ url: supabaseUrl, key: anonKey });
  const writeClient = flags.live ? makeSupabase({ url: supabaseUrl, key: serviceKey }) : null;

  console.log("Traveler generator v2 — Adventure format");
  console.log(`  mode:    ${flags.dryRun ? "DRY-RUN" : "LIVE"}`);
  console.log(`  images:  ${flags.withImages ? "Unsplash + Street View" : "off"}`);
  console.log(`  city:    ${flags.city}`);
  console.log(`  filter:  ${flags.lesson ? `lesson=${flags.lesson}` : flags.lessons ? `lessons=${flags.lessons.join(",")}` : "(all)"}`);
  console.log(`  resume:  ${flags.resume ? "on" : "off"}${flags.reset ? " (reset)" : ""}`);
  console.log(`  log:     ${PROGRESS_PATH}\n`);

  const courses = await readClient.get(`/traveler_courses?select=id,city,country&city=eq.${encodeURIComponent(flags.city)}`);
  if (!courses.length) { console.error(`City not found: ${flags.city}`); process.exit(1); }
  const course = courses[0];

  const lessons = await readClient.get(
    `/traveler_lessons?traveler_course_id=eq.${course.id}&select=id,title,location_name,lesson_type,order_index,is_premium,xp_reward&order=order_index.asc`,
  );
  const filtered = flags.lessons
    ? lessons.filter((l) => flags.lessons.includes(l.order_index))
    : flags.lesson
    ? lessons.filter((l) => l.order_index === flags.lesson)
    : lessons;

  if (course.city !== "Madrid") {
    console.error(`Only Madrid has a lesson plan defined in this script. Add ${course.city}_LESSON_PLAN before running.`);
    process.exit(1);
  }

  const progress = await loadProgress(flags.reset);
  let processed = 0, succeeded = 0, failed = 0;
  const failures = [];

  console.log(`Queued: ${filtered.length} lesson(s) in ${course.city}\n`);

  for (const lesson of filtered) {
    if (flags.limit && processed >= flags.limit) {
      console.log(`\nlimit ${flags.limit} reached, stopping`);
      break;
    }
    const plan = MADRID_LESSON_PLAN[lesson.order_index];
    if (!plan) { failed++; failures.push({ order: lesson.order_index, title: lesson.title, error: "no plan entry" }); continue; }

    const key = `${course.city}:${lesson.order_index}`;
    if (flags.resume && progress.completed_lessons_v2[key]?.hasContent) {
      console.log(`  skip L${lesson.order_index} ${lesson.title} (already done)`);
      continue;
    }
    processed++;

    const medium = ["audio_announcement", "overheard"].includes(plan.type) ? "audio" : "image";
    const priorCtx = priorContextFor(progress, course.city, lesson.order_index);

    const t0 = Date.now();
    const stamp = new Date().toTimeString().slice(0, 8);
    console.log(`[${stamp}] L${String(lesson.order_index).padStart(2)} ${plan.type.padEnd(19)} ${lesson.title}`);

    try {
      // Resolve the image URL FIRST (for image lessons). Download the
      // bytes and run Claude vision so content is written against the
      // ACTUAL photo, not against a plan hint.
      let imageInfo = null;
      if (flags.withImages && plan.image) {
        imageInfo = await resolveAndStashImage({
          plan, city: course.city, orderIndex: lesson.order_index,
          unsplashKey, mapsKey, anthropicKey,
          supabaseUrl, serviceKey,
          skipUpload: flags.dryRun,
        });
      }

      const userPrompt = medium === "image"
        ? visualPrompt({
            orderIndex: lesson.order_index, title: lesson.title, location: lesson.location_name,
            type: plan.type, image: plan.image, vision: imageInfo?.vision, priorCtx,
          })
        : audioPrompt({
            orderIndex: lesson.order_index, title: lesson.title, location: lesson.location_name,
            type: plan.type,
            subject: lesson.title, // audio lessons: title gives the setup; priorCtx carries recap
            priorCtx,
          });

      let v2, usage;
      {
        const r1 = await callClaude({ apiKey: anthropicKey, systemPrompt: SYSTEM_PROMPT, userPrompt, maxTokens: 5000 });
        usage = r1.usage;
        v2 = extractJson(r1.text);
        try {
          assertShape(v2, medium);
        } catch (validationErr) {
          console.log(`         RETRY    validation: ${validationErr.message.slice(0, 120)}`);
          const nudge = `${userPrompt}\n\nYour previous response failed validation with: "${validationErr.message}". Regenerate the WHOLE JSON object, fixing that specific issue. Keep the same lesson framing.`;
          const r2 = await callClaude({ apiKey: anthropicKey, systemPrompt: SYSTEM_PROMPT, userPrompt: nudge, maxTokens: 5000 });
          usage = r2.usage;
          v2 = extractJson(r2.text);
          try {
            assertShape(v2, medium);
          } catch (secondErr) {
            if (flags.verbose || flags.dryRun) {
              console.error("--- second validation failed, raw JSON: ---");
              console.error(JSON.stringify(v2, null, 2).slice(0, 8000));
              console.error("--- end raw ---");
            }
            throw secondErr;
          }
        }
      }

      v2.type = plan.type;
      v2.medium = medium;

      // Pin the image URL + provenance badge onto the lesson. The
      // runner reads `opening.imageSource === "streetview"` to toggle
      // the "📍 Real Madrid street view" badge.
      if (imageInfo) {
        if (medium === "image") {
          v2.opening.imageUrl = imageInfo.url;
          v2.opening.imageSource = imageInfo.source;
        }
      }

      const elapsed = ((Date.now() - t0) / 1000).toFixed(1);
      const shortSummary = medium === "image"
        ? `text="${(v2.opening.fullSignText ?? "").slice(0, 60)}..."  ${v2.decodeSteps.length} steps${imageInfo ? `  img=${imageInfo.source}` : ""}`
        : `${v2.opening.script.length} lines  ${v2.decodeSteps.length} decode`;

      if (flags.dryRun) {
        console.log(`         DRY-RUN  ${elapsed}s  ${shortSummary}${usage ? `  in=${usage.input_tokens} out=${usage.output_tokens}` : ""}`);
        if (imageInfo?.vision) {
          console.log(`         VISION   ${imageInfo.vision.sceneDescription}`);
          if (imageInfo.vision.visibleText?.length) {
            console.log(`         V-TEXT   ${imageInfo.vision.visibleText.join(" · ").slice(0, 200)}`);
          }
          if (imageInfo.vision.suitableForMadridLesson === false) {
            console.log(`         ⚠ UNSUITABLE: ${imageInfo.vision.unsuitableReason}`);
          }
        }
        if (flags.verbose) console.log(JSON.stringify(v2, null, 2));
      } else {
        const row = {
          traveler_lesson_id: lesson.id,
          content_type: "v2_lesson",
          content_order: 1,
          image_url: imageInfo?.url ?? null,
          image_alt: medium === "image" ? v2.opening.imageAlt : null,
          explanation_text: v2.storyRecap ?? null,
          dialogue_lines: medium === "audio" ? v2.opening.script : [],
          quiz_questions: v2.endQuiz,
          data: v2,
        };
        await writeClient.delete(`/traveler_lesson_content?traveler_lesson_id=eq.${lesson.id}`);
        await writeClient.post(`/traveler_lesson_content`, [row]);
        console.log(`         WROTE    ${elapsed}s  ${shortSummary}`);
      }

      progress.completed_lessons_v2[key] = {
        city: course.city,
        order: lesson.order_index,
        title: lesson.title,
        location: lesson.location_name,
        type: plan.type,
        medium,
        hasContent: !flags.dryRun,
        hasImage: !!imageInfo,
        imageSource: imageInfo?.source ?? null,
        storyRecap: v2.storyRecap,
        timestamp: new Date().toISOString(),
      };
      for (const s of v2.decodeSteps) {
        progress.vocab_v2.push({
          city: course.city,
          firstLesson: lesson.order_index,
          word: s.wordOrPhrase,
          english: s.english,
        });
      }
      await saveProgress(progress);
      succeeded++;
    } catch (err) {
      failed++;
      failures.push({ order: lesson.order_index, title: lesson.title, error: err.message });
      console.error(`         FAILED   ${err.message.slice(0, 300)}`);
    }

    if (flags.sleepMs > 0) await new Promise((r) => setTimeout(r, flags.sleepMs));
  }

  console.log("\n" + "=".repeat(60));
  console.log(`Done. processed=${processed} succeeded=${succeeded} failed=${failed}`);
  if (failures.length) {
    console.log("\nFailures:");
    for (const f of failures) console.log(`  L${f.order} ${f.title} — ${f.error.slice(0, 200)}`);
  }
  console.log(`Progress log: ${PROGRESS_PATH}`);
}

main().catch((err) => {
  console.error("Fatal:", err);
  process.exit(1);
});

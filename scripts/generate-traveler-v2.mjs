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
// Visual lessons get a Flux 1.1 Pro image (SDXL cannot render Spanish
// text). Audio lessons store a TTS-driven script rendered at runtime
// via browser SpeechSynthesis — no MP3 storage (upgradable later).
//
// USAGE
//   node scripts/generate-traveler-v2.mjs [flags]
//
// FLAGS
//   --dry-run              default; hits Anthropic but no DB writes
//   --live                 write to Supabase; requires SUPABASE_SERVICE_ROLE_KEY
//   --skip-images          default; no Replicate calls
//   --with-images          generate visual-lesson images via Flux 1.1 Pro
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
//   SUPABASE_SERVICE_ROLE_KEY (only --live)
//   ANTHROPIC_API_KEY
//   REPLICATE_API_TOKEN       (only --with-images)
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
const FLUX_ENDPOINT =
  "https://api.replicate.com/v1/models/black-forest-labs/flux-1.1-pro/predictions";
const PROGRESS_PATH = resolve(__dirname, ".traveler-content-progress.json");

// ============================================================
// Madrid 50-lesson type plan — hand-tuned so each lesson's type
// fits its location and no two consecutive lessons share a type.
// ============================================================

const MADRID_LESSON_PLAN = {
  1:  { type: "sign",               visualSubject: "airport arrivals directional sign inside Madrid-Barajas Terminal 4" },
  2:  { type: "document",           visualSubject: "an Iberia airline boarding pass" },
  3:  { type: "overheard",          audioSubject: "a Madrid taxi driver making small talk on the way from Barajas to Chueca" },
  4:  { type: "document",           visualSubject: "a Spanish hotel check-in form (ficha de policía) filled in halfway" },
  5:  { type: "advertisement",      visualSubject: "an in-room hotel brochure card advertising the rooftop spa and mini-bar" },
  6:  { type: "sign",               visualSubject: "Sol Metro station wayfinding sign for Línea 1, Línea 2 and Línea 3, correspondencia arrows" },
  7:  { type: "advertisement",      visualSubject: "a Gran Vía billboard advertising a Spanish musical theatre show" },
  8:  { type: "overheard",          audioSubject: "asking a stranger for directions on Calle Fuencarral in Malasaña" },
  9:  { type: "document",           visualSubject: "a Madrid Abono Turístico transport card and its cardboard sleeve" },
  10: { type: "audio_announcement", audioSubject: "a street pregón and bar barker overheard walking through Lavapiés at aperitivo hour" },
  11: { type: "menu",               visualSubject: "the breakfast chalkboard menu at Café Comercial in Bilbao, Madrid — tostadas, café con leche, zumo" },
  12: { type: "overheard",          audioSubject: "a fishmonger vendor calling out prices in Mercado de San Miguel" },
  13: { type: "menu",               visualSubject: "a paper Menú del Día from Casa Botín in Madrid, list of primeros, segundos, postres, pan y bebida included" },
  14: { type: "overheard",          audioSubject: "ordering a caña and a tapa at a crowded bar in Malasaña, bartender and patron" },
  15: { type: "menu",               visualSubject: "the tiled interior menu of Chocolatería San Ginés listing chocolate con churros, porras, chocolate a la taza" },
  16: { type: "sign",               visualSubject: "a large REBAJAS sale sign in the window of Zara Gran Vía, red on white with percentages" },
  17: { type: "document",           visualSubject: "a Spanish pharmacy prescription receipt (receta médica) with medication and dosage" },
  18: { type: "advertisement",      visualSubject: "a Plaza Mayor souvenir shop window covered in flamenco fans, magnets, bullfighter posters and prices in euros" },
  19: { type: "overheard",          audioSubject: "haggling with a vendor at El Rastro Sunday flea market over the price of a vintage jacket" },
  20: { type: "document",           visualSubject: "an El Corte Inglés paper return slip with barcode and article numbers" },
  21: { type: "sign",               visualSubject: "the ticket-window sign at Museo del Prado with entry prices, hours, and free-admission slots" },
  22: { type: "audio_announcement", audioSubject: "the opening lines of a Palacio Real audioguide, formal register" },
  23: { type: "sign",               visualSubject: "the interpretive room sign next to Picasso's Guernica at Museo Reina Sofía" },
  24: { type: "audio_announcement", audioSubject: "a Templo de Debod tourist information audio at sunset — the Egyptian temple's origin" },
  25: { type: "advertisement",      visualSubject: "the rowboat and paddle-boat rental kiosk sign at El Retiro lake, prices per half hour" },
  26: { type: "sign",               visualSubject: "aisle-marker signs inside a Mercadona supermarket in Malasaña — panadería, congelados, bebidas" },
  27: { type: "document",           visualSubject: "a Correos parcel-sending form (impreso de envío) for shipping abroad" },
  28: { type: "sign",               visualSubject: "the touchscreen of a BBVA ATM in Madrid showing the language and cash-withdrawal menu in Spanish" },
  29: { type: "document",           visualSubject: "a self-service laundromat printed ticket from a Chamberí lavandería with machine number and end time" },
  30: { type: "advertisement",      visualSubject: "a bright printed gym membership flyer for a Chamberí gimnasio with monthly plans and included classes" },
  31: { type: "overheard",          audioSubject: "two Madrileños in their 20s in a Malasaña bar inviting a tourist to join their round" },
  32: { type: "audio_announcement", audioSubject: "a Cadena SER radio traffic bulletin playing on the speakers inside a Madrid Uber" },
  33: { type: "overheard",          audioSubject: "a voice note invitation on WhatsApp from Ana asking you to come to a cena at her flat in Chueca" },
  34: { type: "menu",               visualSubject: "a chalkboard tapas menu at a La Latina restaurant with the day's specials" },
  35: { type: "overheard",          audioSubject: "a customer and vendor at Mercado de la Cebada trying to sort out a mistaken order" },
  36: { type: "menu",               visualSubject: "the vertical chalkboard sherry list at La Venencia in La Latina — fino, manzanilla, oloroso, amontillado, palo cortado, prices per copa" },
  37: { type: "advertisement",      visualSubject: "a Pachá Madrid nightclub flyer for the weekend's DJ line-up, neon on dark" },
  38: { type: "sign",               visualSubject: "the Corral de la Morería flamenco venue exterior sign advertising the evening's cuadro" },
  39: { type: "audio_announcement", audioSubject: "the pre-match PA at Santiago Bernabéu welcoming the crowd before Real Madrid kick-off" },
  40: { type: "sign",               visualSubject: "the illuminated Cines Callao marquee showing three movie titles and screening times in Spanish" },
  41: { type: "document",           visualSubject: "a Metro Madrid lost-and-found (objetos perdidos) claim form filled in for a lost wallet" },
  42: { type: "overheard",          audioSubject: "a general-practice doctor at Centro de Salud Chueca asking a foreign patient what's wrong" },
  43: { type: "document",           visualSubject: "a Policía Nacional denuncia form (theft report) partially completed in Spanish" },
  44: { type: "sign",               visualSubject: "the in-store service signage at Vodafone Gran Vía — 'Pídelo aquí' with a numbered ticket dispenser" },
  45: { type: "document",           visualSubject: "an EMT Madrid night-bus (búho) printed timetable stuck to a Sol bus stop with route and stop times" },
  46: { type: "audio_announcement", audioSubject: "a voicemail from Carlos the taxi driver saying he's fifteen minutes away and reminding you not to forget the passport" },
  47: { type: "overheard",          audioSubject: "a phone call to hotel reception asking politely for a late checkout in Chueca" },
  48: { type: "sign",               visualSubject: "the Barajas T4 departures board showing Iberia and Ryanair flights with statuses (Embarcando, Puerta, Retrasado)" },
  49: { type: "advertisement",      visualSubject: "a duty-free perfume and jamón ibérico promotional stand sign at Barajas Terminal 4" },
  50: { type: "audio_announcement", audioSubject: "the opening Iberia cabin welcome announcement on flight IB6250 to New York, from the captain and purser" },
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
    dryRun: true, live: false, withImages: false,
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
  // Strip code fences if the model added any, then parse.
  let s = text.trim();
  if (s.startsWith("```")) {
    s = s.replace(/^```(?:json)?\s*\n?/, "").replace(/\n?```\s*$/, "");
  }
  // Find the first { and last } to be tolerant of pre/post prose.
  const first = s.indexOf("{");
  const last = s.lastIndexOf("}");
  if (first !== -1 && last !== -1 && last > first) s = s.slice(first, last + 1);
  return JSON.parse(s);
}

// ============================================================
// Prompt templates
// ============================================================

const SYSTEM_PROMPT = `You are an expert Spanish-language lesson author for an immersive traveler's course app called Languages Center. You write authentic, culturally accurate lesson content set in Madrid, Spain. You are fluent in Madrileño Spanish (Castilian, ceceo, vosotros where natural).

You always respond with a single JSON object matching the schema the user gives you. Use the EXACT field names given — do not rename them. Never wrap the response in markdown code fences. Never add prose before or after the JSON.`;

// Shared schema fragments referenced by both prompts — inline them
// verbatim so Claude never invents field names.
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

function visualPrompt({ orderIndex, title, location, type, subject, priorCtx }) {
  return `You are writing Lesson ${orderIndex} of a 50-lesson Madrid traveler course.

LESSON META
- Title: "${title}"
- Location: "${location}"
- Type: ${type}  (image-based — the learner sees ONE realistic photo and decodes it)
- Visual subject: ${subject}

${buildContextBlock(priorCtx)}

Write ONE JSON object with EXACTLY this shape:

{
  "scene": "A 1-2 sentence second-person scene-setter. E.g., 'You step out of Sol Metro. You see this sign overhead.'",
  "storyRecap": "One sentence that will open the NEXT lesson, referring back to what happened here.",
  "opening": {
    "kind": "image",
    "fullSignText": "The literal Spanish text visible in the image, exactly as it should appear, formatted for humans.",
    "imagePrompt": "A Flux 1.1 Pro image-generation prompt. Photorealistic, editorial DSLR style. Spell out the exact Spanish text that must appear in the image. Include lighting, location detail, camera perspective. Aim for 60-120 words.",
    "imageAlt": "One sentence of accessibility alt text describing the image."
  },
  "decodeSteps": [
    {
      "wordOrPhrase": "Spanish word or short phrase from the sign/menu/document",
      "phonetic": "[phonetic guide in brackets, English speaker friendly]",
      "english": "English translation",
      "mnemonic": "A one-sentence memory hook — sound-alike or English cognate connection.",
      "culturalNote": "A one-sentence Madrid-specific tip. Optional — omit the field if not relevant.",
      "gatedExercise": { …see EXERCISE SCHEMA below… }
    }
  ],
  "buildup": {
    "fullEnglish": "The full English translation of the whole sign/menu/document.",
    "celebrationMessage": "One warm sentence celebrating that the learner just read authentic Spanish."
  },
  "endQuiz": [ …see QUIZ SCHEMA below… ]
}

EXERCISE SCHEMA
${EXERCISE_SCHEMA}

QUIZ SCHEMA
${QUIZ_SCHEMA}

REQUIREMENTS:
- decodeSteps: 5 to 7 items. Vary gatedExercise.kind across steps. NEVER put the same kind twice in a row. Include at least one "speaking" step.
- endQuiz: exactly 5 items covering ONLY vocab from THIS lesson. Include at least three different kinds.
- All Spanish text must be authentic Madrileño register.
- imagePrompt: Flux 1.1 Pro renders text well — spell the Spanish letters exactly, and quote each phrase that must appear.
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
// Flux 1.1 Pro image generation
// ============================================================

async function generateFluxImage({ token, prompt }) {
  return withRetry("flux", async () => {
    const createRes = await fetch(FLUX_ENDPOINT, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
        Prefer: "wait=60",
      },
      body: JSON.stringify({
        input: {
          prompt,
          aspect_ratio: "4:3",
          output_format: "jpg",
          output_quality: 88,
          // 5 (of 6 max) — the default 2 false-flagged e.g. boarding
          // passes as NSFW. Content is still safe-guarded but far less
          // trigger-happy on airport/document imagery.
          safety_tolerance: 5,
        },
      }),
    });
    if (!createRes.ok) {
      const text = await createRes.text().catch(() => "");
      const err = new Error(`flux create ${createRes.status}: ${text.slice(0, 400)}`);
      if (createRes.status === 429 || createRes.status >= 500) markRetryable(err);
      throw err;
    }
    let pred = await createRes.json();
    while (pred.status === "starting" || pred.status === "processing") {
      await new Promise((r) => setTimeout(r, 2500));
      const pollRes = await fetch(pred.urls.get, {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!pollRes.ok) {
        const text = await pollRes.text().catch(() => "");
        const err = new Error(`flux poll ${pollRes.status}: ${text.slice(0, 200)}`);
        if (pollRes.status === 429 || pollRes.status >= 500) markRetryable(err);
        throw err;
      }
      pred = await pollRes.json();
    }
    if (pred.status !== "succeeded") {
      throw new Error(`flux finished status=${pred.status} err=${JSON.stringify(pred.error).slice(0, 200)}`);
    }
    const url = Array.isArray(pred.output) ? pred.output[0] : pred.output;
    if (typeof url !== "string") throw new Error(`flux missing URL`);
    return url;
  });
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
    if (!v2.opening.imagePrompt) throw new Error("opening.imagePrompt missing");
  } else {
    if (!Array.isArray(v2.opening.script) || v2.opening.script.length < 1) throw new Error("opening.script missing");
  }
  if (!Array.isArray(v2.decodeSteps) || v2.decodeSteps.length < 3) throw new Error("decodeSteps missing / too few");
  for (const [i, s] of v2.decodeSteps.entries()) {
    if (!s.wordOrPhrase || !s.english || !s.mnemonic) throw new Error(`decodeSteps[${i}] missing fields`);
    if (!s.gatedExercise || !EXERCISE_KINDS.has(s.gatedExercise.kind)) throw new Error(`decodeSteps[${i}].gatedExercise invalid`);
    if (mediumExpected === "audio" && !s.audioSnippet) throw new Error(`decodeSteps[${i}].audioSnippet missing (required for audio)`);
  }
  // No two consecutive same-kind exercises.
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
  // Shared progress file with the v1 generator, but v2 keeps its own
  // `completed_lessons_v2` + `vocab_v2` buckets so v1 history isn't
  // clobbered and vice-versa.
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
  // Last ~15 vocab items introduced.
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
  const replicateToken = flags.withImages ? requireEnv("REPLICATE_API_TOKEN") : null;

  const readClient = makeSupabase({ url: supabaseUrl, key: anonKey });
  const writeClient = flags.live ? makeSupabase({ url: supabaseUrl, key: serviceKey }) : null;

  console.log("Traveler generator v2 — Adventure format");
  console.log(`  mode:    ${flags.dryRun ? "DRY-RUN" : "LIVE"}`);
  console.log(`  images:  ${flags.withImages ? "Flux 1.1 Pro" : "off"}`);
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
      const userPrompt = medium === "image"
        ? visualPrompt({ orderIndex: lesson.order_index, title: lesson.title, location: lesson.location_name, type: plan.type, subject: plan.visualSubject, priorCtx })
        : audioPrompt({ orderIndex: lesson.order_index, title: lesson.title, location: lesson.location_name, type: plan.type, subject: plan.audioSubject, priorCtx });

      // Two-shot: the first Claude call occasionally puts two same-kind
      // exercises back-to-back or drops a required field. Retry once
      // with a targeted "fix this" nudge before giving up.
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

      // Attach type + medium so the runner can branch without re-inferring.
      v2.type = plan.type;
      v2.medium = medium;

      // Image generation for visual lessons.
      let imageUrl = null;
      if (medium === "image" && flags.withImages) {
        imageUrl = await generateFluxImage({ token: replicateToken, prompt: v2.opening.imagePrompt });
        v2.opening.imageUrl = imageUrl;
      }

      const elapsed = ((Date.now() - t0) / 1000).toFixed(1);
      const shortSummary = medium === "image"
        ? `text="${(v2.opening.fullSignText ?? "").slice(0, 60)}..."  ${v2.decodeSteps.length} steps`
        : `${v2.opening.script.length} lines  ${v2.decodeSteps.length} decode`;

      if (flags.dryRun) {
        console.log(`         DRY-RUN  ${elapsed}s  ${shortSummary}${usage ? `  in=${usage.input_tokens} out=${usage.output_tokens}` : ""}`);
        if (flags.verbose) console.log(JSON.stringify(v2, null, 2));
      } else {
        const row = {
          traveler_lesson_id: lesson.id,
          content_type: "v2_lesson",
          content_order: 1,
          image_url: imageUrl,
          image_alt: medium === "image" ? v2.opening.imageAlt : null,
          explanation_text: v2.storyRecap ?? null,
          dialogue_lines: medium === "audio" ? v2.opening.script : [],
          quiz_questions: v2.endQuiz,
          data: v2,
        };
        await writeClient.delete(`/traveler_lesson_content?traveler_lesson_id=eq.${lesson.id}`);
        await writeClient.post(`/traveler_lesson_content`, [row]);
        console.log(`         WROTE    ${elapsed}s  ${shortSummary}${imageUrl ? "  +img" : ""}`);
      }

      // Record progress + vocab.
      progress.completed_lessons_v2[key] = {
        city: course.city,
        order: lesson.order_index,
        title: lesson.title,
        location: lesson.location_name,
        type: plan.type,
        medium,
        hasContent: !flags.dryRun,
        hasImage: !!imageUrl,
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

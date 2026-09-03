#!/usr/bin/env node
// Traveler's Course content generator — Adventure format.
//
// Each lesson is one of SEVEN lesson formats, chosen per-lesson per-city
// so the learner never sees two consecutive lessons that feel the same:
//
//   sign_decode    — Realistic Madrid sign; step-by-step decoding.
//   locals_help    — Branching dialogue with a named recurring local.
//   overheard      — Passive-listening dialogue with blur/reveal words.
//   menu_read      — Realistic menu / ticket / form walkthrough.
//   location       — Sensory walk through a real place (name origin,
//                    what you see/hear/say).
//   cultural       — Cultural-practice explainer (meal times, tú/usted,
//                    tipping, siesta…) tied to concrete phrases.
//   vocab_review   — Review lesson: recycles vocab from earlier lessons
//                    in NEW contexts. No new words introduced.
//
// The generator maintains three streams of context per city so lessons
// build on each other:
//
//   1. VOCAB registry — every word introduced with its definition and
//      first-appearance lesson; from L6 onwards each new lesson gets a
//      recycling target (at least 3 prior words in NEW contexts).
//   2. CHARACTER registry — recurring locals (Carlos the taxi driver,
//      María the receptionist, Ana the Malasaña friend). Locals-help
//      lessons preferentially reuse existing characters.
//   3. STORY THREAD — each lesson's own generated `story_recap` opens
//      the next lesson ("Yesterday you figured out the Metro. Today
//      Carlos texts you about a market…").
//
// USAGE
//   node --env-file=.env.local scripts/generate-traveler-content.mjs [flags]
//
// Defaults to --dry-run and --skip-images.
//
// FLAGS
//   --dry-run              default: calls Anthropic but doesn't write to DB
//   --live                 actually write; requires SUPABASE_SERVICE_ROLE_KEY
//   --skip-images          default: skip Replicate; text content only
//   --with-images          call Replicate to generate + save scene + sign images
//   --city <name>          limit to one city (Madrid, Paris, "Buenos Aires", …)
//   --lesson <N>           limit to lessons with this order_index
//   --lessons <a,b,c>      comma-separated order_index list
//   --limit <N>            cap the total number of lessons processed
//   --resume               skip lessons already in progress log (default on)
//   --no-resume            regenerate everything, ignoring progress
//   --reset                wipe progress log and start fresh
//   --sleep-ms <N>         delay between lessons (default 500ms)
//   --verbose              print full JSON per lesson in dry-run
//
// REQUIRED ENV
//   NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY (dry-run reads)
//   SUPABASE_SERVICE_ROLE_KEY (only for --live writes)
//   ANTHROPIC_API_KEY
//   REPLICATE_API_TOKEN (only for --with-images)

import { readFile, writeFile, mkdir } from "node:fs/promises";
import { dirname } from "node:path";
import { existsSync } from "node:fs";

// ============================================================
// Constants
// ============================================================

const MODEL = "claude-sonnet-4-6";
const ANTHROPIC_URL = "https://api.anthropic.com/v1/messages";
const REPLICATE_PREDICTIONS_URL = "https://api.replicate.com/v1/predictions";
const REPLICATE_MODEL_OWNER = "stability-ai";
const REPLICATE_MODEL_NAME = "sdxl";
const PROGRESS_PATH = new URL("./.traveler-content-progress.json", import.meta.url).pathname;

const IMAGE_WIDTH = 1152;
const IMAGE_HEIGHT = 896;

// ============================================================
// Per-city locale, format rotation, characters, dialect notes.
// Only Madrid is filled in today; add other cities when their
// content roll-out starts.
// ============================================================

const CITY_LOCALE = {
  Madrid:         { language: "spanish", region: "European Spanish (Castilian, Madrileño)",   speechLang: "es-ES", cultural: "peninsular Spain, ceceo (th sound for c/z), vosotros, 2pm lunch / 10pm dinner, tapas culture" },
  Barcelona:      { language: "spanish", region: "European Spanish (Castilian, with Catalan)",speechLang: "es-ES", cultural: "peninsular Spain, bilingual signage Catalan+Spanish, distinct Barcelona identity" },
  "Mexico City":  { language: "spanish", region: "Mexican Spanish",                            speechLang: "es-MX", cultural: "Mexican, no ceceo, uses ustedes for both formal/informal plural" },
  "Buenos Aires": { language: "spanish", region: "Rioplatense Spanish",                        speechLang: "es-AR", cultural: "Argentine, voseo (vos), sh-sound for ll/y, 'che' as filler" },
  Paris:          { language: "french",  region: "Metropolitan French",                        speechLang: "fr-FR", cultural: "Parisian formality, bonjour openers, tu/vous distinction" },
  Lyon:           { language: "french",  region: "Metropolitan French",                        speechLang: "fr-FR", cultural: "Lyonnais gastronomy references" },
  Montreal:       { language: "french",  region: "Québécois French",                           speechLang: "fr-CA", cultural: "Québec French, bonjour-hi, Canadianisms" },
};

// Madrid's 50-lesson trip arc, with format assigned per slot so no two
// consecutive lessons share a format and vocab-review lessons sit at
// natural pause points.
const MADRID_FORMATS = {
  1:  "sign_decode",   2:  "locals_help",   3:  "overheard",     4:  "menu_read",
  5:  "location",      6:  "cultural",      7:  "sign_decode",   8:  "locals_help",
  9:  "overheard",     10: "location",      11: "vocab_review",  12: "menu_read",
  13: "sign_decode",   14: "locals_help",   15: "overheard",     16: "cultural",
  17: "location",      18: "vocab_review",  19: "menu_read",     20: "sign_decode",
  21: "locals_help",   22: "overheard",     23: "cultural",      24: "location",
  25: "vocab_review",  26: "menu_read",     27: "sign_decode",   28: "locals_help",
  29: "overheard",     30: "location",      31: "cultural",      32: "vocab_review",
  33: "menu_read",     34: "sign_decode",   35: "locals_help",   36: "overheard",
  37: "cultural",      38: "location",      39: "vocab_review",  40: "menu_read",
  41: "locals_help",   42: "overheard",     43: "cultural",      44: "sign_decode",
  45: "location",      46: "vocab_review",  47: "menu_read",     48: "locals_help",
  49: "cultural",      50: "sign_decode",
};

// Recurring locals per city. Locals-help lessons preferentially cast
// existing characters so the learner sees familiar faces across the trip.
const CITY_CHARACTERS = {
  Madrid: {
    Carlos: {
      role: "middle-aged taxi driver from Chueca",
      personality: "chatty, opinionated about Real Madrid, warm-hearted",
      first_lesson: 3,
      physical: "gray-haired man in his 50s, wears a Real Madrid cap, thick Madrileño accent",
      avatar_palette: "orange",
    },
    "María": {
      role: "hotel receptionist at your Chueca hotel",
      personality: "professional, efficient, warm — occasionally slips into local slang",
      first_lesson: 4,
      physical: "woman in her 30s with dark hair, name badge visible",
      avatar_palette: "rose",
    },
    Ana: {
      role: "art history student, becomes your Malasaña bar friend",
      personality: "curious, patient, loves showing off Madrid to visitors",
      first_lesson: 41,
      physical: "woman in her 20s with short hair and colorful vintage clothing",
      avatar_palette: "purple",
    },
  },
};

// Madrid dialect notes — one per scheduled lesson. When Claude
// generates that lesson, this note is injected into the output as the
// `dialect_note` field so the runner surfaces it.
const MADRID_DIALECT_NOTES = {
  2: {
    title: "The Spanish 'th' sound",
    body:
      "In Madrid Spanish, the letters 'c' (before e/i) and 'z' are pronounced like the 'th' in English 'thanks'. So 'gracias' sounds like 'GRAH-thee-as' — not 'GRAH-see-as' as in Latin America. This is called ceceo. You'll hear it constantly.",
  },
  6: {
    title: "vosotros vs ustedes",
    body:
      "Spain uses 'vosotros' as the informal plural you (¿Cómo estáis?). Latin America drops it entirely and uses 'ustedes' for both formal and informal groups. If a Madrileño addresses your group with 'vosotros' verb endings (-áis, -éis), that's why.",
  },
  14: {
    title: "How Spaniards address strangers",
    body:
      "In Madrid, adults switch to informal 'tú' fast — the formal 'usted' is reserved for elderly people, doctors, and hotel checkouts. A waiter your age will 'tú' you within seconds. Don't take it as impolite; it's warmth.",
  },
  22: {
    title: "Coger — one verb, two continents",
    body:
      "In Spain 'coger' is totally normal for 'to take/grab' (coger el metro = take the metro). In Mexico and much of Latin America the same word is vulgar slang. Use 'coger' freely in Madrid — switch to 'tomar' if you travel west.",
  },
  28: {
    title: "Diminutives are affection",
    body:
      "Madrileños add '-ito/-ita' constantly: café → cafelito, poco → poquito, hasta luego → hasta lueguito. It's not baby-talk — it's warmth. Try it when ordering: 'un cafelito, por favor'.",
  },
  35: {
    title: "Madrid slang: guay, majo, currar",
    body:
      "Three words you'll hear every day in Madrid: guay = cool; majo/maja = nice/pleasant person; currar = to work (colloquial). 'El curro' = your job. These are all Spain-specific and won't fly in most of Latin America.",
  },
  47: {
    title: "Formal goodbyes at the front desk",
    body:
      "Even after 'tú'-ing you the whole trip, hotel staff often switch to 'usted' for the checkout formalities. 'Muchas gracias por su estancia' = 'Thank you very much for your stay' — usted form. It's a ritual, not a rebuke.",
  },
};

// ============================================================
// CLI
// ============================================================

function parseArgs(argv) {
  const flags = {
    dryRun: true, live: false, withImages: false,
    resume: true, reset: false, verbose: false,
    city: null, lesson: null, lessons: null, limit: null,
    sleepMs: 500,
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
// Retry helper
// ============================================================

async function withRetry(label, fn, { maxAttempts = 5, baseDelayMs = 800 } = {}) {
  let lastErr;
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try { return await fn(); }
    catch (err) {
      lastErr = err;
      if (err?.retryable !== true || attempt === maxAttempts) throw err;
      const delay = baseDelayMs * Math.pow(2, attempt - 1);
      console.error(`[retry] ${label} attempt ${attempt} failed (${err.message}); waiting ${delay}ms`);
      await new Promise((r) => setTimeout(r, delay));
    }
  }
  throw lastErr;
}
function markRetryable(err) { err.retryable = true; return err; }

// ============================================================
// Supabase (raw REST)
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
// Anthropic — shared preamble + per-format prompts + schemas
// ============================================================

const SHARED_PREAMBLE = `You are an expert language-content author for an immersive traveler's course app called Languages Center. You write realistic, culturally accurate lesson content for travelers on a two-week trip.

You always output a single JSON object matching the schema for the requested lesson format. Every field is required unless the schema marks it optional. No prose outside the JSON.

CROSS-LESSON RULES
- STORY RECAP: Every lesson opens with a 2-3 sentence \`story_recap\` in second-person present tense that references the PREVIOUS lesson if provided. Use real events ("Yesterday Carlos dropped you at your hotel; this morning you slept in past checkout"). If it's Lesson 1, open with the arrival itself.
- CHARACTERS: When the input includes a character registry, REUSE existing characters where the situation fits — don't invent a new taxi driver if Carlos already exists. Add new characters only when a genuinely new role appears.
- VOCABULARY RECYCLING: When the input includes previously_seen_vocabulary, for any lesson from L6 onward you MUST use at least 3 of those words in this lesson's target-language content (sign words / phrases / dialogue). Recycled words should appear in NEW contexts, not the same situation as before.
- DIALECT NOTES: When the input includes a scheduled_dialect_note, include it verbatim in the \`dialect_note\` field. Otherwise return \`{ title: "", body: "" }\` (empty strings mean "no note").
- NEW VOCABULARY: The \`new_vocabulary\` array lists ONLY words introduced by this lesson (not previously in previously_seen_vocabulary). Definition is a short English gloss; phonetic is plain-English respelling.

REGIONAL AUTHENTICITY
Match the region's variety exactly. For Madrid: European Spanish with vosotros for informal plural, ceceo (th sound for c/z), 2pm lunch and 10pm dinner conventions, warm quick switch to tú. Never introduce Latin American forms in Madrid content.

WRITING STYLE
- Vivid, sensory scene descriptions ("The air smells of frying churros.")
- Never mention that this is a lesson or app
- Cultural context always concrete ("At El Rastro the price on the tag is a starting bid, not the final price.")
- Phonetic respellings use plain English syllables, not IPA
`;

// One system prompt per lesson format. Each prompt appends its own
// specific instructions after the shared preamble.
const FORMAT_PROMPTS = {
  sign_decode: SHARED_PREAMBLE + `
FORMAT — SIGN DECODING
Show a realistic sign the traveler would actually see at this exact location and walk them through decoding it word by word.

REQUIRED fields:
- story_recap: 2-3 sentence lead-in
- scene: { image_prompt (SDXL prompt for atmospheric location photo, no readable text), stamp (2-6 char uppercase code like "MAD"), stamp_sublabel (short uppercase subtitle like "BARAJAS T4") }
- sign: {
    style: one of "airport_blue" | "menu_card" | "street" | "notice" | "neon"
    image_prompt: a detailed SDXL prompt for the SIGN ITSELF as it would appear in Madrid (correct fonts, colors, materials). Avoid asking for readable letters — the sign block re-renders the text in HTML.
    title: main line of the sign, verbatim in the target language, uppercase
    subtitle: optional secondary line or English translation (may be null)
    icon: single symbol like "→" or "✈" (may be null)
    context_note: one sentence in English describing WHERE this sign is at the location
    decode_steps: 4-6 items, each { text (word or phrase from the sign), english (translation), root_or_hook (etymology / cognate / memory hook — plain English, one sentence), connects_to (word in English or another language it connects to, or null) }
    sign_type_note: one sentence explaining that this type of sign appears throughout Madrid ("Blue overhead signs use this same layout at every airport and station in Spain.")
  }
- dialect_note: null OR the scheduled_dialect_note if provided
- final_moment: one sentence in second person that gives the "you can now read this" pay-off
- quiz: 3 items, each { type ("multiple_choice"|"fill_blank"|"listening"), question, correct_answer, wrong_answers (exactly 3), translation (null for multiple_choice, English translation of the target-language answer otherwise), audio_prompt (target-language phrase to play; null for non-listening) }
- new_vocabulary: array of { word, definition, phonetic } (may be empty if all sign words appear in previously_seen_vocabulary — unusual but allowed)
`,

  locals_help: SHARED_PREAMBLE + `
FORMAT — A LOCAL HELPS YOU
A named local (from the character registry when possible) helps the traveler navigate a specific situation. The interaction branches — at 2-3 points the traveler picks one of 3 responses and sees the consequence.

REQUIRED fields:
- story_recap
- scene: { image_prompt, stamp, stamp_sublabel }
- locals_help: {
    character: {
      name: (reuse from registry if fitting, otherwise invent a new Madrid-appropriate name)
      role: one line ("passport officer at Barajas T4 immigration")
      opener: what they say first in the target language, natural not scripted
      opener_english: translation
    },
    situation: one-sentence setup in English ("The officer scans your passport and asks about your visit.")
    turns: 2-3 items, each {
      character_says: { target, english }
      options: exactly 3 items, each { text (in target language, natural speech), english (translation), is_best (true for exactly one), feedback (one-sentence coach note explaining WHY this response is right/wrong/awkward), consequence (what the character does next — advances the story or requires backtracking) }
    }
    resolution: {
      character_says: { target, english }
      mood: "warm" | "neutral" | "cool"
      hand_off: one sentence in second person ending the encounter and setting up the next lesson
    }
  }
- dialect_note: null OR the scheduled_dialect_note
- quiz: 3 items (same shape as sign_decode.quiz)
- new_vocabulary
`,

  overheard: SHARED_PREAMBLE + `
FORMAT — OVERHEARD CONVERSATION
The traveler is standing near two locals (metro carriage, café tables, bar seats) and overhears them. Their conversation appears line by line as if heard live, with 1-3 focus words per turn blurred/unknown that the learner can tap to reveal.

REQUIRED fields:
- story_recap
- scene: { image_prompt, stamp, stamp_sublabel }
- overheard: {
    setup: one-sentence positioning ("Two women in their thirties sit at the next table over a plate of jamón.")
    speakers: 2 items, each { name (Madrid-appropriate first name), role (one line: "office worker on her lunch break"), avatar_palette ("rose"|"purple"|"orange"|"emerald"|"blue"|"amber") }
    turns: 6-8 items, each { speaker_index (0 or 1), target (natural spoken Madrid Spanish, may include contractions like "pa'" for "para"), english (translation), focus_words: 0-3 items each { word (must appear in target above), english_gloss } }
    outcome_summary: one sentence in English wrapping up what they were talking about
  }
- dialect_note: null OR the scheduled_dialect_note
- comprehension_questions: 3 items in English, each { question, correct_answer, wrong_answers (exactly 3), explanation (one sentence justifying the right answer with a target-language quote from the conversation) }
- new_vocabulary
`,

  menu_read: SHARED_PREAMBLE + `
FORMAT — MENU / DOCUMENT READING
Walk the traveler through a realistic document they'll encounter: a Spanish restaurant menu, a train ticket, a Metro map, a Farmacia prescription, a receipt, a form to fill.

REQUIRED fields:
- story_recap
- scene: { image_prompt, stamp, stamp_sublabel }
- menu_read: {
    document_type: "menu" | "ticket" | "receipt" | "schedule" | "form" | "notice"
    image_prompt: SDXL prompt for a realistic photo of this document as it would appear in Madrid. Prefer angles that avoid depicting readable body text — the actual text is re-rendered in HTML.
    document_title: what the document is called in Spanish, verbatim
    sections: 3-5 items, each { header (target-language section heading), lines (2-5 items, each { label (target-language line item), value (price, time, portion — nullable), note (one-line cultural / practical note in English, may be null) }) }
    walkthrough: 3-5 items in English, each { step_title, explanation (2-3 sentences that teach how to READ this type of document — Spanish menus are 3 courses, prices include VAT, tapas are shared, etc.) }
    action_task: {
      prompt: one sentence in English asking the traveler to accomplish something with this document ("Order the menú del día with a starter of gazpacho.")
      correct_answer: what they would actually say/write, in target language
      correct_english: translation
      wrong_answers: 2 plausible wrong things a foreigner might say instead, each in target language
      feedback: one sentence in English explaining why the correct answer works
    }
  }
- dialect_note
- quiz: 3 items
- new_vocabulary
`,

  location: SHARED_PREAMBLE + `
FORMAT — REAL LOCATION EXPLORATION
Deep-dive on a specific real Madrid place. Cover the origin of its name, what a visitor sees / hears / says there, and one signature moment they'll remember.

REQUIRED fields:
- story_recap
- scene: { image_prompt (a photo of THIS place specifically), stamp, stamp_sublabel }
- location: {
    place: { name (target-language name verbatim, e.g. "Puerta del Sol"), place_type ("plaza" | "market" | "park" | "avenue" | "monument" | "station" | "neighborhood" | "museum" | "restaurant"), name_meaning (English explanation of what the name literally means and, if interesting, why it got that name), one_line_history }
    sensory_beats: 4-6 items, each { what_you_see (English, one sentence), what_you_hear (English, one sentence — include one snippet of overheard target-language phrase if natural), what_you_say (target-language phrase you might use, with English translation) }
    signature_phrase: { phrase (target language), phonetic, english, why_here (one sentence explaining why THIS phrase is quintessentially Madrileño for this place) }
    remember_this: one sentence in second person capturing the one thing to take away from this place
  }
- dialect_note
- quiz: 3 items
- new_vocabulary
`,

  cultural: SHARED_PREAMBLE + `
FORMAT — CULTURAL MOMENT
Explain a cultural practice specific to Madrid / Spain, and tie it back to concrete phrases the traveler can use.

REQUIRED fields:
- story_recap
- scene: { image_prompt, stamp, stamp_sublabel }
- cultural: {
    topic: short English title ("Meal times in Spain")
    core_insight: one sentence takeaway
    body: 2-4 paragraphs (each 2-4 sentences) explaining the practice with concrete examples
    dos: 3 short lines starting with "Do…"
    donts: 3 short lines starting with "Don't…"
    key_phrases: 3-5 items, each { phrase (target language), phonetic, english, when_to_use (one sentence) }
  }
- dialect_note
- quiz: 3 items testing the practice + phrases
- new_vocabulary
`,

  vocab_review: SHARED_PREAMBLE + `
FORMAT — VOCABULARY IN CONTEXT REVIEW
NO new vocabulary. Recycle 5-8 words from previously_seen_vocabulary in fresh Madrid contexts so the learner sees them from new angles.

REQUIRED fields:
- story_recap
- scene: { image_prompt, stamp, stamp_sublabel }
- vocab_review: {
    recycled: 5-8 items, each { word (must appear in previously_seen_vocabulary), first_lesson (integer from the input), new_contexts: 2 items each { situation (one-line English scene), target_sentence, english } }
    micro_dialogues: 2 items, each { setup (one-line English), lines: 3-4 items each { speaker (short label like "You"|"Waiter"|"Passer-by"), target, english } — each dialogue must reuse at least 3 of the recycled words above }
    self_check: one sentence in second person congratulating the learner on how far they've come
  }
- dialect_note
- quiz: 4-5 items, ALL using only previously_seen_vocabulary
- new_vocabulary: [] (empty array — this format never introduces new words)
`,
};

// Per-format Anthropic JSON schemas. Structural fields required by
// the SDK; array sizes are validated in JS after parse because
// Anthropic's structured-output doesn't accept minItems > 1.
function quizSchema() {
  return {
    type: "array",
    items: {
      type: "object", additionalProperties: false,
      properties: {
        type:           { type: "string", enum: ["multiple_choice", "fill_blank", "listening"] },
        question:       { type: "string" },
        correct_answer: { type: "string" },
        wrong_answers:  { type: "array", items: { type: "string" } },
        translation:    { type: ["string", "null"] },
        audio_prompt:   { type: ["string", "null"] },
      },
      required: ["type", "question", "correct_answer", "wrong_answers", "translation", "audio_prompt"],
    },
  };
}
function newVocabSchema() {
  return {
    type: "array",
    items: {
      type: "object", additionalProperties: false,
      properties: {
        word:       { type: "string" },
        definition: { type: "string" },
        phonetic:   { type: "string" },
      },
      required: ["word", "definition", "phonetic"],
    },
  };
}
function dialectNoteSchema() {
  // Anthropic's structured-output doesn't accept oneOf or nullable
  // objects. Keep it always-present; empty title means "no note".
  return {
    type: "object", additionalProperties: false,
    properties: { title: { type: "string" }, body: { type: "string" } },
    required: ["title", "body"],
  };
}
function sceneSchema() {
  return {
    type: "object", additionalProperties: false,
    properties: {
      image_prompt:    { type: "string" },
      stamp:           { type: "string" },
      stamp_sublabel:  { type: "string" },
    },
    required: ["image_prompt", "stamp", "stamp_sublabel"],
  };
}

const FORMAT_SCHEMAS = {
  sign_decode: {
    type: "object", additionalProperties: false,
    properties: {
      story_recap: { type: "string" },
      scene: sceneSchema(),
      sign: {
        type: "object", additionalProperties: false,
        properties: {
          style:         { type: "string", enum: ["airport_blue","menu_card","street","notice","neon"] },
          image_prompt:  { type: "string" },
          title:         { type: "string" },
          subtitle:      { type: ["string", "null"] },
          icon:          { type: ["string", "null"] },
          context_note:  { type: "string" },
          decode_steps:  {
            type: "array",
            items: {
              type: "object", additionalProperties: false,
              properties: {
                text:         { type: "string" },
                english:      { type: "string" },
                root_or_hook: { type: "string" },
                connects_to:  { type: ["string", "null"] },
              },
              required: ["text", "english", "root_or_hook", "connects_to"],
            },
          },
          sign_type_note: { type: "string" },
        },
        required: ["style", "image_prompt", "title", "subtitle", "icon", "context_note", "decode_steps", "sign_type_note"],
      },
      dialect_note: dialectNoteSchema(),
      final_moment: { type: "string" },
      quiz: quizSchema(),
      new_vocabulary: newVocabSchema(),
    },
    required: ["story_recap", "scene", "sign", "dialect_note", "final_moment", "quiz", "new_vocabulary"],
  },

  locals_help: {
    type: "object", additionalProperties: false,
    properties: {
      story_recap: { type: "string" },
      scene: sceneSchema(),
      locals_help: {
        type: "object", additionalProperties: false,
        properties: {
          character: {
            type: "object", additionalProperties: false,
            properties: {
              name:           { type: "string" },
              role:           { type: "string" },
              opener:         { type: "string" },
              opener_english: { type: "string" },
            },
            required: ["name", "role", "opener", "opener_english"],
          },
          situation: { type: "string" },
          turns: {
            type: "array",
            items: {
              type: "object", additionalProperties: false,
              properties: {
                character_says: {
                  type: "object", additionalProperties: false,
                  properties: { target: { type: "string" }, english: { type: "string" } },
                  required: ["target", "english"],
                },
                options: {
                  type: "array",
                  items: {
                    type: "object", additionalProperties: false,
                    properties: {
                      text:        { type: "string" },
                      english:     { type: "string" },
                      is_best:     { type: "boolean" },
                      feedback:    { type: "string" },
                      consequence: { type: "string" },
                    },
                    required: ["text", "english", "is_best", "feedback", "consequence"],
                  },
                },
              },
              required: ["character_says", "options"],
            },
          },
          resolution: {
            type: "object", additionalProperties: false,
            properties: {
              character_says: {
                type: "object", additionalProperties: false,
                properties: { target: { type: "string" }, english: { type: "string" } },
                required: ["target", "english"],
              },
              mood:     { type: "string", enum: ["warm", "neutral", "cool"] },
              hand_off: { type: "string" },
            },
            required: ["character_says", "mood", "hand_off"],
          },
        },
        required: ["character", "situation", "turns", "resolution"],
      },
      dialect_note: dialectNoteSchema(),
      quiz: quizSchema(),
      new_vocabulary: newVocabSchema(),
    },
    required: ["story_recap", "scene", "locals_help", "dialect_note", "quiz", "new_vocabulary"],
  },

  overheard: {
    type: "object", additionalProperties: false,
    properties: {
      story_recap: { type: "string" },
      scene: sceneSchema(),
      overheard: {
        type: "object", additionalProperties: false,
        properties: {
          setup: { type: "string" },
          speakers: {
            type: "array",
            items: {
              type: "object", additionalProperties: false,
              properties: {
                name: { type: "string" }, role: { type: "string" },
                avatar_palette: { type: "string", enum: ["rose","purple","orange","emerald","blue","amber"] },
              },
              required: ["name", "role", "avatar_palette"],
            },
          },
          turns: {
            type: "array",
            items: {
              type: "object", additionalProperties: false,
              properties: {
                speaker_index: { type: "integer" },
                target: { type: "string" }, english: { type: "string" },
                focus_words: {
                  type: "array",
                  items: {
                    type: "object", additionalProperties: false,
                    properties: { word: { type: "string" }, english_gloss: { type: "string" } },
                    required: ["word", "english_gloss"],
                  },
                },
              },
              required: ["speaker_index", "target", "english", "focus_words"],
            },
          },
          outcome_summary: { type: "string" },
        },
        required: ["setup", "speakers", "turns", "outcome_summary"],
      },
      dialect_note: dialectNoteSchema(),
      comprehension_questions: {
        type: "array",
        items: {
          type: "object", additionalProperties: false,
          properties: {
            question:       { type: "string" },
            correct_answer: { type: "string" },
            wrong_answers:  { type: "array", items: { type: "string" } },
            explanation:    { type: "string" },
          },
          required: ["question", "correct_answer", "wrong_answers", "explanation"],
        },
      },
      new_vocabulary: newVocabSchema(),
    },
    required: ["story_recap", "scene", "overheard", "dialect_note", "comprehension_questions", "new_vocabulary"],
  },

  menu_read: {
    type: "object", additionalProperties: false,
    properties: {
      story_recap: { type: "string" },
      scene: sceneSchema(),
      menu_read: {
        type: "object", additionalProperties: false,
        properties: {
          document_type: { type: "string", enum: ["menu","ticket","receipt","schedule","form","notice"] },
          image_prompt:  { type: "string" },
          document_title:{ type: "string" },
          sections: {
            type: "array",
            items: {
              type: "object", additionalProperties: false,
              properties: {
                header: { type: "string" },
                lines: {
                  type: "array",
                  items: {
                    type: "object", additionalProperties: false,
                    properties: {
                      label: { type: "string" },
                      value: { type: ["string", "null"] },
                      note:  { type: ["string", "null"] },
                    },
                    required: ["label", "value", "note"],
                  },
                },
              },
              required: ["header", "lines"],
            },
          },
          walkthrough: {
            type: "array",
            items: {
              type: "object", additionalProperties: false,
              properties: { step_title: { type: "string" }, explanation: { type: "string" } },
              required: ["step_title", "explanation"],
            },
          },
          action_task: {
            type: "object", additionalProperties: false,
            properties: {
              prompt:          { type: "string" },
              correct_answer:  { type: "string" },
              correct_english: { type: "string" },
              wrong_answers:   { type: "array", items: { type: "string" } },
              feedback:        { type: "string" },
            },
            required: ["prompt", "correct_answer", "correct_english", "wrong_answers", "feedback"],
          },
        },
        required: ["document_type", "image_prompt", "document_title", "sections", "walkthrough", "action_task"],
      },
      dialect_note: dialectNoteSchema(),
      quiz: quizSchema(),
      new_vocabulary: newVocabSchema(),
    },
    required: ["story_recap", "scene", "menu_read", "dialect_note", "quiz", "new_vocabulary"],
  },

  location: {
    type: "object", additionalProperties: false,
    properties: {
      story_recap: { type: "string" },
      scene: sceneSchema(),
      location: {
        type: "object", additionalProperties: false,
        properties: {
          place: {
            type: "object", additionalProperties: false,
            properties: {
              name: { type: "string" }, place_type: { type: "string" },
              name_meaning: { type: "string" }, one_line_history: { type: "string" },
            },
            required: ["name", "place_type", "name_meaning", "one_line_history"],
          },
          sensory_beats: {
            type: "array",
            items: {
              type: "object", additionalProperties: false,
              properties: {
                what_you_see: { type: "string" },
                what_you_hear:{ type: "string" },
                what_you_say: {
                  type: "object", additionalProperties: false,
                  properties: { target: { type: "string" }, english: { type: "string" } },
                  required: ["target", "english"],
                },
              },
              required: ["what_you_see", "what_you_hear", "what_you_say"],
            },
          },
          signature_phrase: {
            type: "object", additionalProperties: false,
            properties: {
              phrase: { type: "string" }, phonetic: { type: "string" },
              english: { type: "string" }, why_here: { type: "string" },
            },
            required: ["phrase", "phonetic", "english", "why_here"],
          },
          remember_this: { type: "string" },
        },
        required: ["place", "sensory_beats", "signature_phrase", "remember_this"],
      },
      dialect_note: dialectNoteSchema(),
      quiz: quizSchema(),
      new_vocabulary: newVocabSchema(),
    },
    required: ["story_recap", "scene", "location", "dialect_note", "quiz", "new_vocabulary"],
  },

  cultural: {
    type: "object", additionalProperties: false,
    properties: {
      story_recap: { type: "string" },
      scene: sceneSchema(),
      cultural: {
        type: "object", additionalProperties: false,
        properties: {
          topic:         { type: "string" },
          core_insight:  { type: "string" },
          body:          { type: "array", items: { type: "string" } },
          dos:           { type: "array", items: { type: "string" } },
          donts:         { type: "array", items: { type: "string" } },
          key_phrases: {
            type: "array",
            items: {
              type: "object", additionalProperties: false,
              properties: {
                phrase: { type: "string" }, phonetic: { type: "string" },
                english: { type: "string" }, when_to_use: { type: "string" },
              },
              required: ["phrase", "phonetic", "english", "when_to_use"],
            },
          },
        },
        required: ["topic", "core_insight", "body", "dos", "donts", "key_phrases"],
      },
      dialect_note: dialectNoteSchema(),
      quiz: quizSchema(),
      new_vocabulary: newVocabSchema(),
    },
    required: ["story_recap", "scene", "cultural", "dialect_note", "quiz", "new_vocabulary"],
  },

  vocab_review: {
    type: "object", additionalProperties: false,
    properties: {
      story_recap: { type: "string" },
      scene: sceneSchema(),
      vocab_review: {
        type: "object", additionalProperties: false,
        properties: {
          recycled: {
            type: "array",
            items: {
              type: "object", additionalProperties: false,
              properties: {
                word: { type: "string" },
                first_lesson: { type: "integer" },
                new_contexts: {
                  type: "array",
                  items: {
                    type: "object", additionalProperties: false,
                    properties: {
                      situation: { type: "string" },
                      target_sentence: { type: "string" },
                      english: { type: "string" },
                    },
                    required: ["situation", "target_sentence", "english"],
                  },
                },
              },
              required: ["word", "first_lesson", "new_contexts"],
            },
          },
          micro_dialogues: {
            type: "array",
            items: {
              type: "object", additionalProperties: false,
              properties: {
                setup: { type: "string" },
                lines: {
                  type: "array",
                  items: {
                    type: "object", additionalProperties: false,
                    properties: {
                      speaker: { type: "string" },
                      target:  { type: "string" },
                      english: { type: "string" },
                    },
                    required: ["speaker", "target", "english"],
                  },
                },
              },
              required: ["setup", "lines"],
            },
          },
          self_check: { type: "string" },
        },
        required: ["recycled", "micro_dialogues", "self_check"],
      },
      dialect_note: dialectNoteSchema(),
      quiz: quizSchema(),
      new_vocabulary: newVocabSchema(),
    },
    required: ["story_recap", "scene", "vocab_review", "dialect_note", "quiz", "new_vocabulary"],
  },
};

// ============================================================
// Post-parse validators (Anthropic's schema doesn't do minItems > 1)
// ============================================================

function validate(format, ai) {
  const errs = [];
  const chk = (cond, msg) => { if (!cond) errs.push(msg); };
  chk(typeof ai?.story_recap === "string" && ai.story_recap.length > 20, "story_recap too short");
  const quiz = ai?.quiz ?? ai?.comprehension_questions ?? [];
  if (format === "overheard") {
    chk(quiz.length >= 2 && quiz.length <= 4, `comprehension_questions must be 2-4, got ${quiz.length}`);
    chk((ai?.overheard?.turns?.length ?? 0) >= 4, `overheard.turns must be ≥4, got ${ai?.overheard?.turns?.length ?? 0}`);
    chk((ai?.overheard?.speakers?.length ?? 0) === 2, `overheard.speakers must be 2, got ${ai?.overheard?.speakers?.length ?? 0}`);
  } else if (format === "vocab_review") {
    chk(quiz.length >= 3 && quiz.length <= 6, `quiz must be 3-6, got ${quiz.length}`);
    chk((ai?.vocab_review?.recycled?.length ?? 0) >= 5, `vocab_review.recycled must be ≥5, got ${ai?.vocab_review?.recycled?.length ?? 0}`);
    chk((ai?.new_vocabulary ?? []).length === 0, `vocab_review must not introduce new vocab, got ${(ai?.new_vocabulary ?? []).length}`);
  } else {
    chk(quiz.length >= 3 && quiz.length <= 5, `quiz must be 3-5, got ${quiz.length}`);
  }
  for (const [i, q] of quiz.entries()) {
    const nw = (q?.wrong_answers ?? []).length;
    if (nw !== 3) errs.push(`quiz[${i}].wrong_answers must be 3, got ${nw}`);
  }
  if (format === "sign_decode") {
    const steps = ai?.sign?.decode_steps?.length ?? 0;
    chk(steps >= 4 && steps <= 6, `sign.decode_steps must be 4-6, got ${steps}`);
  }
  if (format === "locals_help") {
    const turns = ai?.locals_help?.turns ?? [];
    chk(turns.length >= 2 && turns.length <= 3, `locals_help.turns must be 2-3, got ${turns.length}`);
    for (const [i, t] of turns.entries()) {
      chk((t.options ?? []).length === 3, `turn[${i}].options must be 3, got ${(t.options ?? []).length}`);
      const bestCount = (t.options ?? []).filter((o) => o.is_best).length;
      chk(bestCount === 1, `turn[${i}] must have exactly one is_best=true option, got ${bestCount}`);
    }
  }
  if (format === "menu_read") {
    chk((ai?.menu_read?.sections?.length ?? 0) >= 2, `menu_read.sections must be ≥2`);
    chk((ai?.menu_read?.walkthrough?.length ?? 0) >= 3, `menu_read.walkthrough must be ≥3`);
  }
  if (format === "location") {
    const b = ai?.location?.sensory_beats?.length ?? 0;
    chk(b >= 4 && b <= 6, `location.sensory_beats must be 4-6, got ${b}`);
  }
  if (format === "cultural") {
    chk((ai?.cultural?.body?.length ?? 0) >= 2, `cultural.body must be ≥2 paragraphs`);
    chk((ai?.cultural?.dos?.length ?? 0) >= 3, `cultural.dos must be ≥3`);
    chk((ai?.cultural?.donts?.length ?? 0) >= 3, `cultural.donts must be ≥3`);
    chk((ai?.cultural?.key_phrases?.length ?? 0) >= 3, `cultural.key_phrases must be ≥3`);
  }
  if (errs.length > 0) {
    const err = new Error(`validation failed: ${errs.join("; ")}`);
    markRetryable(err);
    throw err;
  }
}

// ============================================================
// Content generation call
// ============================================================

async function generateContent({ apiKey, format, city, country, lesson, locale, ctx }) {
  const system = FORMAT_PROMPTS[format];
  const schema = FORMAT_SCHEMAS[format];
  if (!system || !schema) throw new Error(`unknown format: ${format}`);

  const userPayload = {
    city, country,
    language: locale.language, region: locale.region, cultural_notes: locale.cultural,
    lesson: {
      title: lesson.title, location: lesson.location_name,
      order_index: lesson.order_index, is_premium: lesson.is_premium,
      format,
    },
    previous_lesson: ctx.previousLesson,       // {title, location, story_recap_used} or null
    character_registry: ctx.characters,        // { name: {role, personality, first_lesson_seen} }
    previously_seen_vocabulary: ctx.vocab,     // [{word, definition, first_lesson}]
    scheduled_dialect_note: ctx.dialectNote,   // {title, body} or null
    recycling_requirement:
      lesson.order_index >= 6
        ? "This lesson must reuse at least 3 previously_seen_vocabulary words in NEW contexts."
        : "Recycling is encouraged but not required for the first 5 lessons.",
  };

  const body = {
    model: MODEL, max_tokens: 8000,
    thinking: { type: "disabled" },
    output_config: { effort: "low", format: { type: "json_schema", schema } },
    system: [{ type: "text", text: system, cache_control: { type: "ephemeral" } }],
    messages: [{ role: "user", content: JSON.stringify(userPayload, null, 2) }],
  };

  return withRetry(`anthropic ${city}/L${lesson.order_index}/${format}`, async () => {
    const res = await fetch(ANTHROPIC_URL, {
      method: "POST",
      headers: { "x-api-key": apiKey, "anthropic-version": "2023-06-01", "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });
    if (!res.ok) {
      const text = await res.text().catch(() => "");
      const err = new Error(`anthropic ${res.status}: ${text.slice(0, 500)}`);
      if (res.status === 429 || res.status >= 500 || res.status === 529) markRetryable(err);
      throw err;
    }
    const json = await res.json();
    const textBlock = (json.content ?? []).find((b) => b.type === "text");
    if (!textBlock) throw new Error("no text block in anthropic response");
    let parsed;
    try { parsed = JSON.parse(textBlock.text); }
    catch { throw new Error(`response is not valid JSON: ${textBlock.text.slice(0, 200)}`); }
    validate(format, parsed);
    return { content: parsed, usage: json.usage ?? null };
  });
}

// ============================================================
// Replicate (SDXL) — same as before, unchanged
// ============================================================

let cachedReplicateVersion = null;

async function fetchReplicateVersion(token) {
  if (cachedReplicateVersion) return cachedReplicateVersion;
  return withRetry(`replicate model lookup`, async () => {
    const res = await fetch(
      `https://api.replicate.com/v1/models/${REPLICATE_MODEL_OWNER}/${REPLICATE_MODEL_NAME}`,
      { headers: { Authorization: `Bearer ${token}` } },
    );
    if (!res.ok) {
      const text = await res.text().catch(() => "");
      const err = new Error(`replicate model lookup ${res.status}: ${text.slice(0, 400)}`);
      if (res.status === 429 || res.status >= 500) markRetryable(err);
      throw err;
    }
    const model = await res.json();
    const version = model?.latest_version?.id;
    if (!version) throw new Error("replicate model response missing latest_version.id");
    cachedReplicateVersion = version;
    return version;
  });
}

async function generateImage({ token, prompt }) {
  const version = await fetchReplicateVersion(token);
  return withRetry(`replicate`, async () => {
    const createRes = await fetch(REPLICATE_PREDICTIONS_URL, {
      method: "POST",
      headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json", Prefer: "wait=60" },
      body: JSON.stringify({
        version,
        input: { prompt, width: IMAGE_WIDTH, height: IMAGE_HEIGHT, num_inference_steps: 30, guidance_scale: 7.5, num_outputs: 1 },
      }),
    });
    if (!createRes.ok) {
      const text = await createRes.text().catch(() => "");
      const err = new Error(`replicate create ${createRes.status}: ${text.slice(0, 400)}`);
      if (createRes.status === 429 || createRes.status >= 500) markRetryable(err);
      throw err;
    }
    let pred = await createRes.json();
    while (pred.status === "starting" || pred.status === "processing") {
      await new Promise((r) => setTimeout(r, 3000));
      const pollRes = await fetch(pred.urls?.get, { headers: { Authorization: `Bearer ${token}` } });
      if (!pollRes.ok) {
        const text = await pollRes.text().catch(() => "");
        const err = new Error(`replicate poll ${pollRes.status}: ${text.slice(0, 400)}`);
        if (pollRes.status === 429 || pollRes.status >= 500) markRetryable(err);
        throw err;
      }
      pred = await pollRes.json();
    }
    if (pred.status !== "succeeded") {
      throw new Error(`replicate finished with status=${pred.status} error=${JSON.stringify(pred.error)}`);
    }
    const url = Array.isArray(pred.output) ? pred.output[0] : pred.output;
    if (typeof url !== "string") throw new Error(`replicate output missing URL: ${JSON.stringify(pred.output).slice(0, 200)}`);
    return url;
  });
}

// ============================================================
// Content → DB rows.
//
// The DB schema still uses generic content_type values (scene, sign,
// dialogue, quiz, phrases, explanation) plus a per-row `data` JSONB.
// For the new formats we serialize the whole format-specific payload
// under content_type='scene' + data.format=<format> for a bespoke
// runner branch. This avoids a schema migration; if the runner rebuild
// wants a stricter shape we can add new content_types in migration 055.
// ============================================================

function toContentRows(lessonId, format, ai, sceneImageUrl, signImageUrl) {
  const base = {
    traveler_lesson_id: lessonId, content_type: null, content_order: 0,
    image_url: null, image_alt: null, explanation_text: null,
    dialogue_lines: [], quiz_questions: [], data: {},
  };
  return [
    {
      ...base,
      content_type: "scene", content_order: 1,
      image_url: sceneImageUrl,
      image_alt: `${ai.scene.stamp} scene`,
      explanation_text: ai.story_recap,
      data: {
        format,
        story_recap: ai.story_recap,
        scene: ai.scene,
        dialect_note: ai.dialect_note && ai.dialect_note.title ? ai.dialect_note : null,
        payload: extractPayload(format, ai, signImageUrl),
      },
    },
    {
      ...base,
      content_type: "quiz", content_order: 2,
      quiz_questions: format === "overheard" ? ai.comprehension_questions : ai.quiz,
      data: { format, isComprehension: format === "overheard" },
    },
  ];
}

function extractPayload(format, ai, signImageUrl) {
  switch (format) {
    case "sign_decode":  return { sign: { ...ai.sign, image_url: signImageUrl }, final_moment: ai.final_moment };
    case "locals_help":  return { locals_help: ai.locals_help };
    case "overheard":    return { overheard: ai.overheard };
    case "menu_read":    return { menu_read: { ...ai.menu_read, image_url: signImageUrl } };
    case "location":     return { location: ai.location };
    case "cultural":     return { cultural: ai.cultural };
    case "vocab_review": return { vocab_review: ai.vocab_review };
    default: return {};
  }
}

// ============================================================
// Context assembly (previous lesson, vocab, characters)
// ============================================================

function loadCityContext(progress, city) {
  const entries = Object.values(progress.completed_lessons ?? {})
    .filter((e) => e.city === city)
    .sort((a, b) => a.order - b.order);

  // Cumulative vocab (word, definition, first_lesson).
  const vocabMap = new Map();
  for (const e of entries) {
    for (const v of e.vocab ?? []) {
      const k = (typeof v === "string" ? v : v.word ?? "").toLowerCase().trim();
      if (!k) continue;
      if (!vocabMap.has(k)) {
        vocabMap.set(k, {
          word: typeof v === "string" ? v : v.word,
          definition: typeof v === "string" ? "" : (v.definition ?? ""),
          phonetic: typeof v === "string" ? "" : (v.phonetic ?? ""),
          first_lesson: typeof v === "string" ? e.order : (v.first_lesson ?? e.order),
        });
      }
    }
  }
  const vocab = Array.from(vocabMap.values());

  // Character appearances — hoist from progress log + seed with the
  // static registry for the city so first appearances still work.
  const seed = CITY_CHARACTERS[city] ?? {};
  const characters = {};
  for (const [name, meta] of Object.entries(seed)) {
    characters[name] = { ...meta, appearances: [] };
  }
  for (const e of entries) {
    for (const c of e.characters_used ?? []) {
      if (!characters[c]) {
        characters[c] = { role: "recurring local (unspecified)", first_lesson: e.order, appearances: [] };
      }
      if (!characters[c].appearances.includes(e.order)) characters[c].appearances.push(e.order);
    }
  }

  // Previous lesson (highest order_index completed).
  const previous = entries.length > 0 ? entries[entries.length - 1] : null;
  const previousLesson = previous
    ? {
        order: previous.order,
        title: previous.title ?? null,
        location: previous.location ?? null,
        story_recap: previous.story_recap ?? null,
        format: previous.format ?? null,
      }
    : null;

  return { vocab, characters, previousLesson };
}

function harvestVocabFromAI(ai) {
  return (ai.new_vocabulary ?? [])
    .filter((v) => v && v.word)
    .map((v) => ({
      word: v.word.trim(),
      definition: (v.definition ?? "").trim(),
      phonetic: (v.phonetic ?? "").trim(),
    }));
}

function harvestCharactersFromAI(format, ai) {
  const names = new Set();
  if (format === "locals_help" && ai.locals_help?.character?.name) {
    names.add(ai.locals_help.character.name);
  }
  if (format === "overheard") {
    for (const s of ai.overheard?.speakers ?? []) if (s.name) names.add(s.name);
  }
  return Array.from(names);
}

// ============================================================
// Progress log
// ============================================================

async function loadProgress(reset) {
  if (reset) return { completed_lessons: {}, started_at: new Date().toISOString() };
  if (!existsSync(PROGRESS_PATH)) return { completed_lessons: {}, started_at: new Date().toISOString() };
  try { return JSON.parse(await readFile(PROGRESS_PATH, "utf-8")); }
  catch { return { completed_lessons: {}, started_at: new Date().toISOString() }; }
}
async function saveProgress(progress) {
  await mkdir(dirname(PROGRESS_PATH), { recursive: true });
  await writeFile(PROGRESS_PATH, JSON.stringify(progress, null, 2));
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

  console.log(`🌍 Traveler content generator — Adventure format`);
  console.log(`   mode:    ${flags.dryRun ? "DRY-RUN" : "LIVE"}`);
  console.log(`   images:  ${flags.withImages ? "ON" : "OFF"}`);
  console.log(`   filters: ${flags.city ? `city=${flags.city} ` : ""}${flags.lesson ? `lesson=${flags.lesson}` : ""}${flags.lessons ? `lessons=${flags.lessons.join(",")}` : ""}${!flags.city && !flags.lesson && !flags.lessons ? "(none)" : ""}`);
  console.log(`   resume:  ${flags.resume ? "on" : "off"}${flags.reset ? " (reset)" : ""}\n`);

  const courses = await readClient.get(`/traveler_courses?select=id,city,country&order=order_index.asc`);
  const activeCourses = flags.city
    ? courses.filter((c) => c.city.toLowerCase() === flags.city.toLowerCase())
    : courses;
  if (activeCourses.length === 0) {
    console.error(`No matching city. Available: ${courses.map((c) => c.city).join(", ")}`);
    process.exit(1);
  }

  const progress = await loadProgress(flags.reset);
  let processed = 0, succeeded = 0, failed = 0;
  const failures = [];

  for (const course of activeCourses) {
    const locale = CITY_LOCALE[course.city];
    if (!locale) { console.warn(`⚠ no locale for ${course.city}`); continue; }

    const lessons = await readClient.get(
      `/traveler_lessons?traveler_course_id=eq.${course.id}&select=id,title,location_name,lesson_type,order_index,is_premium,xp_reward&order=order_index.asc`,
    );
    const filtered = flags.lessons
      ? lessons.filter((l) => flags.lessons.includes(l.order_index))
      : flags.lesson
      ? lessons.filter((l) => l.order_index === flags.lesson)
      : lessons;
    if (filtered.length === 0) continue;

    console.log(`\n📍 ${course.city}, ${course.country} — ${filtered.length} lesson(s) queued`);

    // Per-city rotation: Madrid uses MADRID_FORMATS; other cities fall
    // back to a simple round-robin until their own rotation is defined.
    const cityFormats = course.city === "Madrid" ? MADRID_FORMATS : null;
    const fallbackRoundRobin = [
      "sign_decode","locals_help","overheard","menu_read","location","cultural","vocab_review",
    ];
    const dialectNotes = course.city === "Madrid" ? MADRID_DIALECT_NOTES : {};

    for (const lesson of filtered) {
      if (flags.limit && processed >= flags.limit) {
        console.log(`\n⚑ limit ${flags.limit} reached, stopping`);
        break;
      }
      const key = `${course.city}:${lesson.order_index}`;
      if (flags.resume && progress.completed_lessons[key]?.hasContent) {
        console.log(`   ↷ skip L${lesson.order_index} ${lesson.title} (already done)`);
        continue;
      }
      processed++;

      const format = cityFormats
        ? cityFormats[lesson.order_index]
        : fallbackRoundRobin[(lesson.order_index - 1) % fallbackRoundRobin.length];
      if (!format) { failed++; failures.push({ city: course.city, lesson: lesson.order_index, title: lesson.title, error: "no format assigned" }); continue; }

      const ctx = loadCityContext(progress, course.city);
      ctx.dialectNote = dialectNotes[lesson.order_index] ?? null;

      const t0 = Date.now();
      try {
        const { content: ai, usage } = await generateContent({
          apiKey: anthropicKey, format, city: course.city, country: course.country,
          lesson, locale, ctx,
        });

        let sceneImageUrl = null, signImageUrl = null;
        if (flags.withImages) {
          sceneImageUrl = await generateImage({ token: replicateToken, prompt: ai.scene.image_prompt });
          // Sign-style formats also generate a dedicated image for the
          // sign/menu/document itself.
          if (format === "sign_decode" && ai.sign?.image_prompt) {
            signImageUrl = await generateImage({ token: replicateToken, prompt: ai.sign.image_prompt });
          } else if (format === "menu_read" && ai.menu_read?.image_prompt) {
            signImageUrl = await generateImage({ token: replicateToken, prompt: ai.menu_read.image_prompt });
          }
        }

        const rows = toContentRows(lesson.id, format, ai, sceneImageUrl, signImageUrl);
        const elapsed = ((Date.now() - t0) / 1000).toFixed(1);

        if (flags.dryRun) {
          console.log(`\n─── L${lesson.order_index} [${format}] ${lesson.title}  (${elapsed}s${usage ? `, in=${usage.input_tokens ?? "?"} out=${usage.output_tokens ?? "?"}` : ""}) ───`);
          if (flags.verbose) {
            console.log(JSON.stringify(ai, null, 2));
          } else {
            summarize(format, ai);
          }
        } else {
          await writeClient.delete(`/traveler_lesson_content?traveler_lesson_id=eq.${lesson.id}`);
          await writeClient.post(`/traveler_lesson_content`, rows);
          console.log(`   ✓ L${lesson.order_index} [${format}] ${lesson.title} (${elapsed}s${sceneImageUrl ? " + img" : ""}${signImageUrl ? "+sign-img" : ""})`);
        }

        progress.completed_lessons[key] = {
          city: course.city,
          order: lesson.order_index,
          title: lesson.title,
          location: lesson.location_name,
          format,
          hasContent: !flags.dryRun,
          hasImage: !!(sceneImageUrl || signImageUrl) && !flags.dryRun,
          vocab: harvestVocabFromAI(ai),
          characters_used: harvestCharactersFromAI(format, ai),
          story_recap: ai.story_recap,
          timestamp: new Date().toISOString(),
        };
        if (!flags.dryRun) await saveProgress(progress);
        succeeded++;
      } catch (err) {
        failed++;
        failures.push({ city: course.city, lesson: lesson.order_index, title: lesson.title, error: err.message });
        console.error(`   ✗ L${lesson.order_index} [${format}] ${lesson.title}: ${err.message}`);
      }
      if (flags.sleepMs > 0) await new Promise((r) => setTimeout(r, flags.sleepMs));
    }
    if (flags.limit && processed >= flags.limit) break;
  }

  console.log("\n═══════════════════════════════════════════");
  console.log(`Done. processed=${processed} succeeded=${succeeded} failed=${failed}`);
  if (failures.length > 0) {
    console.log("\nFailures:");
    for (const f of failures) console.log(`  ${f.city}/L${f.lesson} — ${f.title}: ${f.error}`);
  }
  if (!flags.dryRun) console.log(`Progress log: ${PROGRESS_PATH}`);
}

// ============================================================
// Dry-run summary printer
// ============================================================

function summarize(format, ai) {
  console.log(`  recap:   ${trunc(ai.story_recap, 120)}`);
  console.log(`  scene:   image_prompt="${trunc(ai.scene.image_prompt, 80)}"  stamp=${ai.scene.stamp} · ${ai.scene.stamp_sublabel}`);
  if (ai.dialect_note && ai.dialect_note.title) console.log(`  dialect: ${ai.dialect_note.title} — ${trunc(ai.dialect_note.body, 100)}`);
  switch (format) {
    case "sign_decode":
      console.log(`  sign:    [${ai.sign.style}] "${ai.sign.title}"  ${ai.sign.decode_steps.length} decode steps`);
      console.log(`           note: ${trunc(ai.sign.sign_type_note, 90)}`);
      console.log(`  final:   ${trunc(ai.final_moment, 100)}`);
      break;
    case "locals_help":
      console.log(`  local:   ${ai.locals_help.character.name} — ${ai.locals_help.character.role}`);
      console.log(`  turns:   ${ai.locals_help.turns.length} branching turns × 3 options`);
      console.log(`  end:     mood=${ai.locals_help.resolution.mood}  ${trunc(ai.locals_help.resolution.hand_off, 90)}`);
      break;
    case "overheard":
      console.log(`  setup:   ${trunc(ai.overheard.setup, 100)}`);
      console.log(`  cast:    ${ai.overheard.speakers.map((s) => `${s.name} (${s.role})`).join(" · ")}`);
      console.log(`  turns:   ${ai.overheard.turns.length}  focus_words: ${ai.overheard.turns.reduce((n, t) => n + t.focus_words.length, 0)}`);
      console.log(`  outcome: ${trunc(ai.overheard.outcome_summary, 100)}`);
      break;
    case "menu_read":
      console.log(`  doc:     ${ai.menu_read.document_type} "${ai.menu_read.document_title}"  ${ai.menu_read.sections.length} sections, ${ai.menu_read.walkthrough.length} walkthrough steps`);
      console.log(`  task:    ${trunc(ai.menu_read.action_task.prompt, 100)}`);
      break;
    case "location":
      console.log(`  place:   ${ai.location.place.name} (${ai.location.place.place_type})  meaning: ${trunc(ai.location.place.name_meaning, 60)}`);
      console.log(`  beats:   ${ai.location.sensory_beats.length} sensory moments  sig-phrase: "${ai.location.signature_phrase.phrase}"`);
      break;
    case "cultural":
      console.log(`  topic:   ${ai.cultural.topic}`);
      console.log(`  insight: ${trunc(ai.cultural.core_insight, 100)}`);
      console.log(`  body:    ${ai.cultural.body.length} paragraphs · ${ai.cultural.dos.length} dos · ${ai.cultural.donts.length} don'ts · ${ai.cultural.key_phrases.length} phrases`);
      break;
    case "vocab_review":
      console.log(`  recycle: ${ai.vocab_review.recycled.length} words × ${ai.vocab_review.recycled[0]?.new_contexts?.length ?? 0} contexts each`);
      console.log(`  micro:   ${ai.vocab_review.micro_dialogues.length} micro-dialogues`);
      console.log(`  self:    ${trunc(ai.vocab_review.self_check, 100)}`);
      break;
  }
  const q = ai.quiz ?? ai.comprehension_questions ?? [];
  console.log(`  quiz:    ${q.length} items [${q.map((x) => x.type ?? "comp").join(", ")}]`);
  console.log(`  vocab+:  ${ai.new_vocabulary.length} new words${ai.new_vocabulary.length > 0 ? ` (${ai.new_vocabulary.slice(0, 5).map((v) => v.word).join(", ")}${ai.new_vocabulary.length > 5 ? "…" : ""})` : ""}`);
}

function trunc(s, n) {
  if (typeof s !== "string") return "";
  return s.length > n ? s.slice(0, n) + "…" : s;
}

main().catch((err) => { console.error(err); process.exit(1); });

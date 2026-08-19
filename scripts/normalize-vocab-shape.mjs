#!/usr/bin/env node
// Normalize vocab_items shape on Spanish B2 + C1 lessons.
//
// Older Spanish sections (A1/A2/B1) store vocab as:
//   { word: "Hola", phonetic: "OH-lah", english: "Hello", ... }
// Newer B2/C1 sections use a different shape:
//   { english: "research", spanish: "la investigación" }
//
// This migration renames the language-specific key ("spanish") to "word"
// so every lesson conforms to the same shape and both the app's
// LessonVocabItem type and the regeneration script's buildAllowedVocab
// can read a single field.
//
// USAGE
//   node --env-file=.env.local scripts/normalize-vocab-shape.mjs           # dry-run
//   node --env-file=.env.local scripts/normalize-vocab-shape.mjs --live    # actually PATCH
//
// SAFETY
//   * Idempotent: rows that already have a non-empty `word` field pass
//     through unchanged; lessons where nothing needs updating are skipped.
//   * DB-side rollback lives in the lessons_backup_20260818 table
//     (see /GITHUB / this repo's docs).
//   * Live mode requires SUPABASE_SERVICE_ROLE_KEY.
//   * Targets Spanish B2 + C1 by default. Override with --language / --levels.

function requireEnv(name) {
  const v = process.env[name];
  if (!v) throw new Error(`missing required env var: ${name}`);
  return v;
}

// ----- args -----

const args = process.argv.slice(2);
const LIVE = args.includes("--live");
const LANG = argValue("--language", "spanish");
const LEVELS = argValue("--levels", "B2,C1").split(",").map(s => s.trim().toUpperCase());

function argValue(name, defaultValue) {
  const i = args.indexOf(name);
  if (i === -1) return defaultValue;
  return args[i + 1] ?? defaultValue;
}

// ----- env -----

const SUPABASE_URL = requireEnv("NEXT_PUBLIC_SUPABASE_URL");
const SERVICE_KEY = LIVE
  ? requireEnv("SUPABASE_SERVICE_ROLE_KEY")
  : (process.env.SUPABASE_SERVICE_ROLE_KEY ?? requireEnv("NEXT_PUBLIC_SUPABASE_ANON_KEY"));

const REST = `${SUPABASE_URL.replace(/\/$/, "")}/rest/v1`;
const HEADERS = {
  apikey: SERVICE_KEY,
  Authorization: `Bearer ${SERVICE_KEY}`,
  "Content-Type": "application/json",
};

// ----- transform -----

// Extract the target-language word from a vocab_items row, checking every
// key we've ever seen in the wild. Returns "" if none present.
function extractWord(v) {
  return ((v.word ?? v.spanish ?? v.french ?? "") || "").toString().trim();
}

// Rewrite a single vocab_items row to the canonical shape. Preserves
// every non-lang-key field (english, phonetic, example_*, etc.).
function normalizeRow(v) {
  const word = extractWord(v);
  if (!word) return null; // will be filtered out
  const { spanish: _s, french: _f, word: _w, ...rest } = v;
  return { word, ...rest };
}

// Does this whole vocab_items array need rewriting? (any row missing word)
function needsNormalization(arr) {
  if (!Array.isArray(arr)) return false;
  for (const v of arr) {
    if (!(v.word ?? "").toString().trim()) {
      // has language-key but no word → needs rewrite
      if ((v.spanish ?? v.french ?? "").toString().trim()) return true;
    }
  }
  return false;
}

// ----- main -----

async function main() {
  console.log(`== normalize-vocab-shape ==`);
  console.log(`mode:     ${LIVE ? "LIVE (writing to DB)" : "DRY-RUN (no writes)"}`);
  console.log(`language: ${LANG}`);
  console.log(`levels:   ${LEVELS.join(",")}`);
  console.log(``);

  // 1. Resolve language_id
  const langRow = await getJson(`${REST}/languages?select=id,name,code&code=eq.${LANG}`);
  if (langRow.length === 0) throw new Error(`no language with code=${LANG}`);
  const lang = langRow[0];

  // 2. Resolve course IDs in the requested CEFR levels
  const levelFilter = LEVELS.map(l => `cefr_level.eq.${l}`).join(",");
  const courses = await getJson(
    `${REST}/courses?select=id,cefr_level,title&language_id=eq.${lang.id}&or=(${levelFilter})&order=cefr_level,order_index`,
  );
  const courseIds = courses.map(c => c.id);
  console.log(`resolved ${courses.length} courses in ${lang.name} ${LEVELS.join("/")}`);

  if (courseIds.length === 0) {
    console.log(`nothing to do`);
    return;
  }

  // 3. Fetch all lessons in those courses
  const lessons = await getJson(
    `${REST}/lessons?select=id,course_id,title,vocab_items&course_id=in.(${courseIds.join(",")})`,
  );
  console.log(`fetched ${lessons.length} lessons\n`);

  // 4. Iterate, patch each lesson that needs it
  let touched = 0;
  let skippedAlreadyNormalized = 0;
  let skippedNoVocab = 0;
  let rowsRewritten = 0;

  for (const lesson of lessons) {
    const vi = lesson.vocab_items;
    if (!Array.isArray(vi) || vi.length === 0) {
      skippedNoVocab++;
      continue;
    }
    if (!needsNormalization(vi)) {
      skippedAlreadyNormalized++;
      continue;
    }

    const rewritten = vi.map(normalizeRow).filter(Boolean);
    const before = vi.length;
    const after = rewritten.length;
    console.log(`  patch lesson ${lesson.id}  "${lesson.title}"  ${before} rows → ${after} rows`);

    if (LIVE) {
      const res = await fetch(`${REST}/lessons?id=eq.${lesson.id}`, {
        method: "PATCH",
        headers: { ...HEADERS, Prefer: "return=minimal" },
        body: JSON.stringify({ vocab_items: rewritten }),
      });
      if (!res.ok) {
        const text = await res.text().catch(() => "");
        throw new Error(`PATCH lesson ${lesson.id} failed ${res.status}: ${text.slice(0, 200)}`);
      }
    }
    touched++;
    rowsRewritten += after;
  }

  console.log(``);
  console.log(`── summary ──`);
  console.log(`patched:                    ${touched}${LIVE ? "" : "  (would patch)"}`);
  console.log(`skipped (already normal):   ${skippedAlreadyNormalized}`);
  console.log(`skipped (no vocab_items):   ${skippedNoVocab}`);
  console.log(`total vocab rows rewritten: ${rowsRewritten}`);
  console.log(``);
}

async function getJson(url) {
  const res = await fetch(url, { headers: HEADERS });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`GET ${url} → ${res.status}: ${text.slice(0, 200)}`);
  }
  return res.json();
}

main().catch(err => {
  console.error(`FATAL: ${err.stack ?? err.message}`);
  process.exit(1);
});

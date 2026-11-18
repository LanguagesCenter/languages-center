#!/usr/bin/env node
// Backup every row in traveler_lesson_content that belongs to the
// Madrid traveler_course to a local JSON file. Run before any live
// regeneration so we can roll back if something goes sideways.
//
// Usage:
//   node scripts/backup-madrid-content.mjs [--out <path>]
//
// Defaults to writing a timestamped file into scripts/backups/.

import { readFileSync, existsSync, mkdirSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, "..");

// Load .env.local — same approach as the generator.
{
  const envPath = resolve(ROOT, ".env.local");
  if (existsSync(envPath)) {
    for (const line of readFileSync(envPath, "utf8").split("\n")) {
      const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/);
      if (m && !process.env[m[1]]) process.env[m[1]] = m[2].replace(/^"|"$/g, "");
    }
  }
}

function requireEnv(name) {
  const v = process.env[name];
  if (!v) {
    console.error(`Missing env: ${name}`);
    process.exit(1);
  }
  return v;
}

const supabaseUrl = requireEnv("NEXT_PUBLIC_SUPABASE_URL");
const anonKey = requireEnv("NEXT_PUBLIC_SUPABASE_ANON_KEY");

const outPath = (() => {
  const args = process.argv.slice(2);
  const i = args.indexOf("--out");
  if (i >= 0 && args[i + 1]) return resolve(ROOT, args[i + 1]);
  const stamp = new Date().toISOString().replace(/[:.]/g, "-");
  return resolve(__dirname, `backups/madrid-${stamp}.json`);
})();

async function supaGet(path) {
  const res = await fetch(`${supabaseUrl.replace(/\/$/, "")}/rest/v1${path}`, {
    headers: { apikey: anonKey, Authorization: `Bearer ${anonKey}` },
  });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`GET ${path} ${res.status}: ${text.slice(0, 300)}`);
  }
  return res.json();
}

async function main() {
  console.log(`Backing up Madrid lesson content…`);

  const courses = await supaGet("/traveler_courses?select=id,city,country&city=eq.Madrid");
  if (!courses.length) {
    console.error("No Madrid course found");
    process.exit(1);
  }
  const course = courses[0];
  console.log(`  course_id=${course.id}  ${course.city}, ${course.country}`);

  const lessons = await supaGet(
    `/traveler_lessons?traveler_course_id=eq.${course.id}&select=id,title,location_name,lesson_type,order_index,xp_reward,is_premium&order=order_index.asc`,
  );
  console.log(`  ${lessons.length} lessons`);

  const content = await supaGet(
    `/traveler_lesson_content?traveler_lesson_id=in.(${lessons.map((l) => l.id).join(",")})&select=*`,
  );
  console.log(`  ${content.length} content rows`);

  const payload = {
    backedUpAt: new Date().toISOString(),
    supabaseUrl,
    course,
    lessons,
    content,
  };
  mkdirSync(dirname(outPath), { recursive: true });
  writeFileSync(outPath, JSON.stringify(payload, null, 2));
  console.log(`\nWrote ${outPath}`);
  console.log(`  ${Buffer.byteLength(JSON.stringify(payload), "utf8").toLocaleString()} bytes`);
}

main().catch((err) => {
  console.error("Fatal:", err);
  process.exit(1);
});

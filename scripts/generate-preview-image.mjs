#!/usr/bin/env node
// ============================================================
// generate-preview-image.mjs
//
// One-off: generate the Madrid airport arrivals sign image for the
// /preview/madrid/1 dry-run. Reuses the same Replicate SDXL call
// as scripts/generate-traveler-content.mjs. Saves to
// public/preview/madrid-l1-arrivals.jpg.
// ============================================================

import { readFileSync, writeFileSync, mkdirSync, existsSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, "..");

// Load .env.local
const envPath = resolve(ROOT, ".env.local");
if (!existsSync(envPath)) {
  console.error(`Missing ${envPath}`);
  process.exit(1);
}
const envRaw = readFileSync(envPath, "utf8");
for (const line of envRaw.split("\n")) {
  const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/);
  if (m && !process.env[m[1]]) process.env[m[1]] = m[2].replace(/^"|"$/g, "");
}

const token = process.env.REPLICATE_API_TOKEN;
if (!token) {
  console.error("REPLICATE_API_TOKEN missing from .env.local");
  process.exit(1);
}

const REPLICATE_PREDICTIONS_URL = "https://api.replicate.com/v1/predictions";

// Flux Schnell handles typography well (SDXL cannot). Uses the
// model-scoped predictions endpoint so we don't need a version pin.
async function generate(prompt) {
  const createRes = await fetch(
    "https://api.replicate.com/v1/models/black-forest-labs/flux-1.1-pro/predictions",
    {
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
          output_quality: 90,
          safety_tolerance: 2,
        },
      }),
    },
  );
  if (!createRes.ok) throw new Error(`create ${createRes.status}: ${await createRes.text()}`);
  let pred = await createRes.json();
  while (pred.status === "starting" || pred.status === "processing") {
    await new Promise((r) => setTimeout(r, 3000));
    const pollRes = await fetch(pred.urls.get, {
      headers: { Authorization: `Bearer ${token}` },
    });
    if (!pollRes.ok) throw new Error(`poll ${pollRes.status}`);
    pred = await pollRes.json();
    process.stdout.write(".");
  }
  process.stdout.write("\n");
  if (pred.status !== "succeeded") {
    throw new Error(`finished with status=${pred.status} err=${JSON.stringify(pred.error)}`);
  }
  return Array.isArray(pred.output) ? pred.output[0] : pred.output;
}

const prompt =
  'Photorealistic wide-angle photo of an overhead airport wayfinding sign inside a modern Spanish airport terminal (Madrid-Barajas Terminal 4). The sign is a dark navy blue rectangular panel with clean white uppercase Helvetica typography. Top line reads "LLEGADAS INTERNACIONALES" in large bold white letters with a bold white right-pointing arrow. Underneath, three smaller stacked rows read "CONTROL DE PASAPORTES", "RECOGIDA DE EQUIPAJES", "SALIDA", each with a small white arrow icon on the right. The sign hangs from a curved white steel and wood terminal ceiling. Warm ambient terminal lighting. Slight motion blur of travelers walking below in soft focus. Sharp legible typography, editorial DSLR photograph, ultra realistic.';

console.log("Generating…");
console.log("prompt:", prompt.slice(0, 200) + "…");
const url = await generate(prompt);
console.log("done, url:", url);

const imgRes = await fetch(url);
if (!imgRes.ok) throw new Error(`download ${imgRes.status}`);
const buf = Buffer.from(await imgRes.arrayBuffer());

const outDir = resolve(ROOT, "public/preview");
mkdirSync(outDir, { recursive: true });
const outPath = resolve(outDir, "madrid-l1-arrivals.jpg");
writeFileSync(outPath, buf);
console.log(`saved: ${outPath} (${(buf.length / 1024).toFixed(1)}kB)`);

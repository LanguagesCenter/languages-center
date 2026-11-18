// Client-safe constants + runtime wrapper for the Web Speech API.
// Keep this file free of any server-only imports.

// ============================================================
// Runtime TTS engine
//
// Addresses the quirks that were breaking audio in the runner:
//   - Voices load asynchronously via the `voiceschanged` event; on
//     Safari/iOS they don't appear at all until user interaction.
//     The old hook returned `null` on first render and the first
//     click would speak with no voice set, which on some engines
//     produced no audible output at all.
//   - speak() MUST be called synchronously inside the click handler
//     on Safari/iOS. Deferring it to an effect dropped the utterance.
//   - cancel() is unreliable right before speak() on Safari — it
//     races with the new utterance. We only cancel when needed.
//   - If NO voices exist at all (headless browsers, locked-down
//     installs), isAudioAvailable() returns false so the UI can
//     render a clear message rather than failing silently.
// ============================================================

export type PlayHandle = {
  stop: () => void;
  finished: Promise<void>;
};

export type ScriptLine = {
  text: string;
  gender?: "male" | "female";
  pauseAfterMs?: number;
};

let cachedVoices: SpeechSynthesisVoice[] = [];
let voicesChangedListenerAttached = false;

function populateVoices(): SpeechSynthesisVoice[] {
  if (typeof window === "undefined" || !window.speechSynthesis) return [];
  const v = window.speechSynthesis.getVoices();
  if (v.length > 0) cachedVoices = v;
  return cachedVoices;
}

function ensureVoicesListener() {
  if (voicesChangedListenerAttached) return;
  if (typeof window === "undefined" || !window.speechSynthesis) return;
  window.speechSynthesis.addEventListener("voiceschanged", () => {
    populateVoices();
  });
  voicesChangedListenerAttached = true;
}

export function warmUpSpeech(): void {
  if (typeof window === "undefined" || !window.speechSynthesis) return;
  ensureVoicesListener();
  populateVoices();
}

export function isAudioAvailable(): boolean {
  if (typeof window === "undefined" || !window.speechSynthesis) return false;
  if (cachedVoices.length === 0) populateVoices();
  return cachedVoices.length > 0;
}

// ============================================================
// City → voice-selection spec
//
// Each city maps to an ordered list of acceptable locales + an
// optional wildcard prefix (used as the LAST fallback). The spec is
// strict: if no voice matches, the caller shows "Audio isn't
// available on this device" instead of playing with the wrong
// accent. We NEVER fall through to en-US — the whole point of the
// Traveler's Course is the regional accent.
// ============================================================

export type VoiceSpec = {
  preferred: string[];      // ordered BCP-47 locales to try
  wildcardPrefix?: string;  // e.g. "es-" accepts any Spanish voice as last resort
  utteranceLang: string;    // what to set utterance.lang to
};

export function voiceSpecForCity(city: string | null | undefined): VoiceSpec {
  const c = (city ?? "").toLowerCase().trim();
  switch (c) {
    case "madrid":
    case "barcelona":
      return { preferred: ["es-ES"], utteranceLang: "es-ES" };
    case "mexico city":
      return { preferred: ["es-MX"], utteranceLang: "es-MX" };
    case "buenos aires":
      return {
        preferred: ["es-AR", "es-419", "es-US"],
        wildcardPrefix: "es-",
        utteranceLang: "es-AR",
      };
    case "paris":
    case "lyon":
      return { preferred: ["fr-FR"], utteranceLang: "fr-FR" };
    case "montreal":
      return { preferred: ["fr-CA", "fr-FR"], utteranceLang: "fr-CA" };
    default:
      // Unknown city → strictest Spanish fallback.
      return { preferred: ["es-ES"], utteranceLang: "es-ES" };
  }
}

// Higher-quality voice names across platforms. We prefer these when
// multiple voices match the same locale — they're neural / cloud
// voices rather than the chunky default system voice.
const HIGH_QUALITY_NAME = /enhanced|premium|neural|natural|google|cloud|siri/i;

function pickVoice(
  voices: SpeechSynthesisVoice[],
  spec: VoiceSpec,
  gender?: "male" | "female",
): SpeechSynthesisVoice | null {
  if (voices.length === 0) return null;

  // Walk preferred locales in order. For each, score candidates by
  // (gender match ⟹ +2, high-quality name ⟹ +1) and return the
  // highest-scoring voice in the first locale that has any match.
  const genderRegex =
    gender === "male"
      ? /jorge|diego|carlos|paul|alex|male/i
      : gender === "female"
        ? /monica|paulina|marisol|female|helena|amelie|lucia/i
        : null;

  function score(v: SpeechSynthesisVoice): number {
    let s = 0;
    if (HIGH_QUALITY_NAME.test(v.name)) s += 1;
    if (genderRegex && genderRegex.test(v.name)) s += 2;
    return s;
  }

  for (const loc of spec.preferred) {
    const target = loc.toLowerCase();
    const matches = voices.filter((v) => v.lang.toLowerCase() === target);
    if (matches.length > 0) {
      matches.sort((a, b) => score(b) - score(a));
      return matches[0];
    }
  }

  // Wildcard fallback (e.g. any es-* voice for Buenos Aires).
  if (spec.wildcardPrefix) {
    const prefix = spec.wildcardPrefix.toLowerCase();
    const matches = voices.filter((v) =>
      v.lang.toLowerCase().startsWith(prefix),
    );
    if (matches.length > 0) {
      matches.sort((a, b) => score(b) - score(a));
      return matches[0];
    }
  }

  // No acceptable voice — DO NOT fall through to English.
  return null;
}

// True iff we have a voice that matches the city's required accent.
// Used by PlayWordButton to decide whether to render the normal play
// button or the "Audio isn't available" placeholder.
export function hasVoiceForCity(city: string | null | undefined): boolean {
  if (typeof window === "undefined" || !window.speechSynthesis) return false;
  const voices = populateVoices();
  if (voices.length === 0) return false;
  const spec = voiceSpecForCity(city);
  return pickVoice(voices, spec) !== null;
}

// Speak a single utterance. CALL SYNCHRONOUSLY FROM THE CLICK
// HANDLER — Safari/iOS enforce the user-gesture window strictly.
//
// `cityOrLang` can be either a city name (e.g. "Madrid", "Buenos
// Aires") OR a BCP-47 locale ("es-ES"). City names go through
// voiceSpecForCity(); raw locales are treated as a single-element
// preferred list. If no acceptable voice exists for the required
// accent we surface onerror("no-matching-voice") and DO NOT speak
// with a wrong-accent fallback.
export function speak(
  cityOrLang: string,
  text: string,
  opts?: {
    rate?: number;
    gender?: "male" | "female";
    onstart?: () => void;
    onend?: () => void;
    onerror?: (reason: string) => void;
  },
): PlayHandle;
export function speak(
  text: string,
  lang: string,
  opts?: {
    rate?: number;
    gender?: "male" | "female";
    onstart?: () => void;
    onend?: () => void;
    onerror?: (reason: string) => void;
  },
): PlayHandle;
export function speak(
  arg1: string,
  arg2: string,
  opts?: {
    rate?: number;
    gender?: "male" | "female";
    onstart?: () => void;
    onend?: () => void;
    onerror?: (reason: string) => void;
  },
): PlayHandle {
  // Backwards-compat: the old signature was speak(text, lang). The new
  // signature is speakForCity(text, city). We dispatch by looking at
  // the second arg: if it matches a city, interpret as new; else old.
  // Internally we build a VoiceSpec and delegate to speakWithSpec.
  const KNOWN_CITIES = new Set([
    "madrid", "barcelona", "mexico city", "buenos aires",
    "paris", "lyon", "montreal",
  ]);
  const secondIsCity = KNOWN_CITIES.has(arg2.toLowerCase().trim());
  const text = arg1;
  const spec = secondIsCity
    ? voiceSpecForCity(arg2)
    : { preferred: [arg2], utteranceLang: arg2 };
  return speakWithSpec(text, spec, opts);
}

// City-aware speak, used by the runner + Speaking Practice page.
export function speakForCity(
  text: string,
  city: string,
  opts?: {
    rate?: number;
    gender?: "male" | "female";
    onstart?: () => void;
    onend?: () => void;
    onerror?: (reason: string) => void;
  },
): PlayHandle {
  return speakWithSpec(text, voiceSpecForCity(city), opts);
}

function speakWithSpec(
  text: string,
  spec: VoiceSpec,
  opts?: {
    rate?: number;
    gender?: "male" | "female";
    onstart?: () => void;
    onend?: () => void;
    onerror?: (reason: string) => void;
  },
): PlayHandle {
  if (typeof window === "undefined" || !window.speechSynthesis) {
    opts?.onerror?.("speech-synthesis-unavailable");
    opts?.onend?.();
    return { stop: () => {}, finished: Promise.resolve() };
  }
  const synth = window.speechSynthesis;
  ensureVoicesListener();
  const voices = populateVoices();
  const voice = pickVoice(voices, spec, opts?.gender);

  // No matching voice — do NOT speak with an English fallback.
  if (!voice) {
    opts?.onerror?.("no-matching-voice");
    opts?.onend?.();
    return { stop: () => {}, finished: Promise.resolve() };
  }

  if (synth.speaking || synth.pending) {
    synth.cancel();
  }

  const u = new SpeechSynthesisUtterance(text);
  u.lang = voice.lang || spec.utteranceLang;
  u.rate = opts?.rate ?? 0.9;
  u.volume = 1;
  u.pitch = 1;
  u.voice = voice;

  let settled = false;
  const finished = new Promise<void>((resolve) => {
    u.onstart = () => opts?.onstart?.();
    u.onend = () => {
      if (settled) return;
      settled = true;
      opts?.onend?.();
      resolve();
    };
    u.onerror = (e) => {
      if (settled) return;
      settled = true;
      opts?.onerror?.(e.error ?? "unknown");
      opts?.onend?.();
      resolve();
    };
  });

  try {
    synth.speak(u);
  } catch (err) {
    settled = true;
    opts?.onerror?.(String(err));
    opts?.onend?.();
    return { stop: () => {}, finished: Promise.resolve() };
  }

  return {
    stop: () => {
      if (synth.speaking || synth.pending) synth.cancel();
    },
    finished,
  };
}

// Sequentially play a multi-line script with per-line voice selection
// and pauses between lines. Accepts a city name OR a BCP-47 locale.
// Same accent-strictness rule as speak(): if no matching voice is
// available for the required locale, skips the line rather than
// speaking in English.
export function playScript(
  script: ScriptLine[],
  cityOrLang: string,
  opts?: {
    onCursor?: (index: number) => void;
    onDone?: () => void;
    rate?: number;
  },
): PlayHandle {
  if (typeof window === "undefined" || !window.speechSynthesis) {
    opts?.onDone?.();
    return { stop: () => {}, finished: Promise.resolve() };
  }
  const synth = window.speechSynthesis;
  if (synth.speaking || synth.pending) synth.cancel();

  const KNOWN_CITIES = new Set([
    "madrid", "barcelona", "mexico city", "buenos aires",
    "paris", "lyon", "montreal",
  ]);
  const spec = KNOWN_CITIES.has(cityOrLang.toLowerCase().trim())
    ? voiceSpecForCity(cityOrLang)
    : { preferred: [cityOrLang], utteranceLang: cityOrLang };

  let cancelled = false;
  let resolveFinished: (() => void) | null = null;
  const finished = new Promise<void>((resolve) => {
    resolveFinished = resolve;
  });

  function runLine(i: number) {
    if (cancelled || i >= script.length) {
      opts?.onCursor?.(-1);
      opts?.onDone?.();
      resolveFinished?.();
      return;
    }
    const line = script[i];
    opts?.onCursor?.(i);
    const voices = populateVoices();
    const voice = pickVoice(voices, spec, line.gender);
    if (!voice) {
      // Skip the line rather than speaking in English.
      runLine(i + 1);
      return;
    }
    const u = new SpeechSynthesisUtterance(line.text);
    u.lang = voice.lang || spec.utteranceLang;
    u.rate = opts?.rate ?? 0.9;
    u.volume = 1;
    u.voice = voice;
    u.onend = () => {
      if (cancelled) return;
      const pause = line.pauseAfterMs ?? 300;
      setTimeout(() => runLine(i + 1), pause);
    };
    u.onerror = () => {
      if (cancelled) return;
      runLine(i + 1);
    };
    synth.speak(u);
  }

  runLine(0);

  return {
    stop: () => {
      cancelled = true;
      if (synth.speaking || synth.pending) synth.cancel();
      opts?.onCursor?.(-1);
      resolveFinished?.();
    },
    finished,
  };
}

// ============================================================
// Language → BCP-47 code map (used across TTS + speech recognition)
// ============================================================

export const SPEECH_LANG_CODES: Record<string, string> = {
  spanish:    "es-ES",
  french:     "fr-FR",
  german:     "de-DE",
  greek:      "el-GR",
  swedish:    "sv-SE",
  danish:     "da-DK",
  finnish:    "fi-FI",
  albanian:   "sq-AL",
  icelandic:  "is-IS",
  faroese:    "fo-FO",
  corsican:   "it-IT", // Corsican has limited browser support; fall back to Italian.
  english:    "en-US",
  chinese:    "zh-CN",
  hindi:      "hi-IN",
  portuguese: "pt-PT",
  bengali:    "bn-BD",
  urdu:       "ur-PK",
  russian:    "ru-RU",
  japanese:   "ja-JP",
  turkish:    "tr-TR",
  vietnamese: "vi-VN",
  arabic:     "ar-SA",
  korean:     "ko-KR",
  italian:    "it-IT",
  malay:      "ms-MY",
  indonesian: "id-ID",
};

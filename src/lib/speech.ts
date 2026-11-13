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

function pickVoice(
  voices: SpeechSynthesisVoice[],
  lang: string,
  gender?: "male" | "female",
): SpeechSynthesisVoice | null {
  if (voices.length === 0) return null;
  const target = lang.toLowerCase();
  const prefix = target.split("-")[0];
  const inLang = voices.filter(
    (v) =>
      v.lang.toLowerCase() === target ||
      v.lang.toLowerCase().startsWith(target) ||
      v.lang.toLowerCase().startsWith(prefix + "-"),
  );
  if (inLang.length === 0) return null;
  if (gender) {
    const genderHint =
      gender === "male"
        ? /jorge|diego|carlos|paul|alex|male/i
        : /monica|paulina|marisol|female|helena|amelie/i;
    const match = inLang.find((v) => genderHint.test(v.name));
    if (match) return match;
  }
  return inLang[0];
}

// Speak a single utterance. CALL SYNCHRONOUSLY FROM THE CLICK
// HANDLER — Safari/iOS enforce the user-gesture window strictly.
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
): PlayHandle {
  if (typeof window === "undefined" || !window.speechSynthesis) {
    opts?.onerror?.("speech-synthesis-unavailable");
    opts?.onend?.();
    return { stop: () => {}, finished: Promise.resolve() };
  }
  const synth = window.speechSynthesis;
  ensureVoicesListener();
  const voices = populateVoices();
  const voice = pickVoice(voices, lang, opts?.gender);

  // Only cancel when something is actually in-flight. Unconditional
  // cancel() races with the subsequent speak() on Safari.
  if (synth.speaking || synth.pending) {
    synth.cancel();
  }

  const u = new SpeechSynthesisUtterance(text);
  u.lang = lang;
  u.rate = opts?.rate ?? 0.9;
  u.volume = 1;
  u.pitch = 1;
  if (voice) u.voice = voice;

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
// and pauses between lines. The onCursor callback drives the waveform
// highlight in the runner.
export function playScript(
  script: ScriptLine[],
  lang: string,
  opts?: {
    onCursor?: (index: number) => void;
    onDone?: () => void;
  },
): PlayHandle {
  if (typeof window === "undefined" || !window.speechSynthesis) {
    opts?.onDone?.();
    return { stop: () => {}, finished: Promise.resolve() };
  }
  const synth = window.speechSynthesis;
  if (synth.speaking || synth.pending) synth.cancel();

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
    const voice = pickVoice(voices, lang, line.gender);
    const u = new SpeechSynthesisUtterance(line.text);
    u.lang = lang;
    u.rate = 0.9;
    u.volume = 1;
    if (voice) u.voice = voice;
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

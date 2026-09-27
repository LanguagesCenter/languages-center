"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import type {
  PreviewLesson,
  DecodeStep,
  GatedExercise,
  EndQuizQuestion,
  AudioLine,
} from "@/lib/traveler-preview";

// ============================================================
// Speech / TTS primitives
// ============================================================

function useSpeechVoice(lang: string, gender?: "male" | "female"): SpeechSynthesisVoice | null {
  const [voice, setVoice] = useState<SpeechSynthesisVoice | null>(null);

  useEffect(() => {
    if (typeof window === "undefined" || !window.speechSynthesis) return;

    function pick(): SpeechSynthesisVoice | null {
      const all = window.speechSynthesis.getVoices();
      if (all.length === 0) return null;
      const target = lang.toLowerCase();
      const prefix = target.split("-")[0];
      const inLang = all.filter(
        (v) =>
          v.lang.toLowerCase() === target ||
          v.lang.toLowerCase().startsWith(target) ||
          v.lang.toLowerCase().startsWith(prefix + "-"),
      );
      if (inLang.length === 0) return null;
      if (gender) {
        const genderHint = gender === "male"
          ? /jorge|diego|carlos|paul|alex|male/i
          : /monica|paulina|marisol|female|helena/i;
        const match = inLang.find((v) => genderHint.test(v.name));
        if (match) return match;
      }
      return inLang[0];
    }

    function refresh() {
      const v = pick();
      if (v) setVoice(v);
    }
    refresh();
    const handler = () => refresh();
    window.speechSynthesis.addEventListener("voiceschanged", handler);
    return () => {
      window.speechSynthesis.removeEventListener("voiceschanged", handler);
    };
  }, [lang, gender]);

  return voice;
}

// Play a single utterance. Returns a controller with stop().
function speakOnce(
  text: string,
  lang: string,
  voice: SpeechSynthesisVoice | null,
  rate = 0.9,
  onend?: () => void,
): () => void {
  if (typeof window === "undefined" || !window.speechSynthesis) {
    onend?.();
    return () => {};
  }
  window.speechSynthesis.cancel();
  const u = new SpeechSynthesisUtterance(text);
  u.lang = lang;
  if (voice) u.voice = voice;
  u.rate = rate;
  u.onend = () => onend?.();
  u.onerror = () => onend?.();
  window.speechSynthesis.speak(u);
  return () => {
    window.speechSynthesis.cancel();
  };
}

function PlayWordButton({
  text,
  lang,
  size = "md",
  onDark = false,
}: {
  text: string;
  lang: string;
  size?: "sm" | "md" | "lg";
  onDark?: boolean;
}) {
  const voice = useSpeechVoice(lang);
  const [playing, setPlaying] = useState(false);
  const stopRef = useRef<(() => void) | null>(null);

  const toggle = useCallback(() => {
    if (playing) {
      stopRef.current?.();
      setPlaying(false);
      return;
    }
    setPlaying(true);
    stopRef.current = speakOnce(text, lang, voice, 0.9, () => setPlaying(false));
  }, [playing, text, lang, voice]);

  useEffect(() => () => {
    if (stopRef.current) window.speechSynthesis?.cancel();
  }, []);

  const sizeClass =
    size === "sm" ? "w-9 h-9" : size === "lg" ? "w-16 h-16" : "w-12 h-12";
  const iconSize =
    size === "sm" ? "w-4 h-4" : size === "lg" ? "w-7 h-7" : "w-5 h-5";
  const toneClass = onDark
    ? "bg-white/20 text-white hover:bg-white/30 backdrop-blur"
    : "bg-teal text-white hover:bg-teal-dark";

  return (
    <button
      type="button"
      onClick={toggle}
      aria-label={playing ? "Stop" : "Play"}
      className={`inline-flex items-center justify-center rounded-full transition-colors shadow-md ${sizeClass} ${toneClass}`}
    >
      {playing ? (
        <svg className={iconSize} fill="currentColor" viewBox="0 0 24 24"><path d="M6 4h4v16H6zM14 4h4v16h-4z" /></svg>
      ) : (
        <svg className={iconSize} fill="currentColor" viewBox="0 0 24 24"><path d="M8 5v14l11-7z" /></svg>
      )}
    </button>
  );
}

// Sequential playback of an audio script (opening / buildup replay).
function useAudioScript(script: AudioLine[], lang: string) {
  const maleVoice = useSpeechVoice(lang, "male");
  const femaleVoice = useSpeechVoice(lang, "female");
  const defaultVoice = useSpeechVoice(lang);
  const [playing, setPlaying] = useState(false);
  const [cursor, setCursor] = useState(-1); // -1 = idle
  const cancelledRef = useRef(false);

  const stop = useCallback(() => {
    cancelledRef.current = true;
    if (typeof window !== "undefined") window.speechSynthesis?.cancel();
    setPlaying(false);
    setCursor(-1);
  }, []);

  const play = useCallback(() => {
    if (typeof window === "undefined" || !window.speechSynthesis) return;
    cancelledRef.current = false;
    setPlaying(true);

    const runLine = (i: number) => {
      if (cancelledRef.current || i >= script.length) {
        setPlaying(false);
        setCursor(-1);
        return;
      }
      const line = script[i];
      setCursor(i);
      const voice =
        line.gender === "male"
          ? maleVoice ?? defaultVoice
          : line.gender === "female"
            ? femaleVoice ?? defaultVoice
            : defaultVoice;
      const u = new SpeechSynthesisUtterance(line.text);
      u.lang = lang;
      if (voice) u.voice = voice;
      u.rate = 0.9;
      u.onend = () => {
        if (cancelledRef.current) return;
        const pause = line.pauseAfterMs ?? 300;
        setTimeout(() => runLine(i + 1), pause);
      };
      u.onerror = () => runLine(i + 1);
      window.speechSynthesis.cancel();
      window.speechSynthesis.speak(u);
    };

    runLine(0);
  }, [script, lang, maleVoice, femaleVoice, defaultVoice]);

  useEffect(() => () => stop(), [stop]);

  return { play, stop, playing, cursor };
}

// ============================================================
// Speech recognition (Web Speech API)
// ============================================================

interface ISpeechRecognition extends EventTarget {
  lang: string;
  interimResults: boolean;
  continuous: boolean;
  onresult: ((this: ISpeechRecognition, ev: SpeechRecognitionResultEvent) => void) | null;
  onerror: ((this: ISpeechRecognition, ev: SpeechRecognitionErrorEvent) => void) | null;
  onend: ((this: ISpeechRecognition, ev: Event) => void) | null;
  start: () => void;
  stop: () => void;
}
interface SpeechRecognitionResultEvent extends Event {
  results: ArrayLike<{ 0: { transcript: string }; isFinal: boolean; length: number }>;
  resultIndex: number;
}
interface SpeechRecognitionErrorEvent extends Event {
  error: string;
}
function getSpeechRecognition(): (new () => ISpeechRecognition) | null {
  if (typeof window === "undefined") return null;
  const w = window as unknown as {
    SpeechRecognition?: new () => ISpeechRecognition;
    webkitSpeechRecognition?: new () => ISpeechRecognition;
  };
  return w.SpeechRecognition ?? w.webkitSpeechRecognition ?? null;
}

function normalize(s: string): string {
  return s
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/[¿?¡!.,;:]/g, "")
    .replace(/\s+/g, " ")
    .trim();
}

function pronunciationMatches(heard: string, expected: string): boolean {
  const h = normalize(heard);
  const e = normalize(expected);
  if (h === e) return true;
  if (h.includes(e) || e.includes(h)) return true;
  // Loose: at least 70% of expected words present
  const expectedWords = e.split(" ");
  const heardWords = new Set(h.split(" "));
  const hit = expectedWords.filter((w) => heardWords.has(w)).length;
  return hit / expectedWords.length >= 0.7;
}

// ============================================================
// Exercises (gated — Continue is blocked until answered correctly)
// ============================================================

type ExerciseResult = { correct: boolean; heard?: string };

function shuffle<T>(arr: T[]): T[] {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

function MultipleChoiceExercise({
  ex,
  onResult,
  passed,
}: {
  ex: Extract<GatedExercise, { kind: "multiple_choice" }>;
  onResult: (r: ExerciseResult) => void;
  passed: boolean;
}) {
  const options = useMemo(() => shuffle([ex.correct, ...ex.wrong]), [ex]);
  const [picked, setPicked] = useState<string | null>(null);

  function pick(opt: string) {
    if (passed) return;
    setPicked(opt);
    const correct = opt === ex.correct;
    onResult({ correct });
  }

  return (
    <div className="space-y-3">
      <p className="text-base font-semibold text-navy">{ex.question}</p>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
        {options.map((opt) => {
          const isPicked = picked === opt;
          const isCorrect = opt === ex.correct;
          let cls = "border-border bg-white text-navy hover:border-teal hover:bg-teal-light";
          if (passed && isCorrect) cls = "border-teal bg-teal-light text-teal-dark";
          else if (isPicked && !isCorrect) cls = "border-red-300 bg-red-50 text-red-700";
          return (
            <button
              key={opt}
              type="button"
              onClick={() => pick(opt)}
              className={`w-full py-3 px-4 rounded-xl border-2 text-start text-sm font-medium transition-all ${cls}`}
            >
              {opt}
            </button>
          );
        })}
      </div>
      {picked && picked !== ex.correct && !passed && (
        <p className="text-xs text-red-600">Not quite — try again.</p>
      )}
    </div>
  );
}

function TapWordExercise({
  ex,
  onResult,
  passed,
}: {
  ex: Extract<GatedExercise, { kind: "tap_word" }>;
  onResult: (r: ExerciseResult) => void;
  passed: boolean;
}) {
  const options = useMemo(() => shuffle([ex.correct, ...ex.distractors]), [ex]);
  const [picked, setPicked] = useState<string | null>(null);

  function pick(opt: string) {
    if (passed) return;
    setPicked(opt);
    onResult({ correct: opt === ex.correct });
  }

  return (
    <div className="space-y-3">
      <p className="text-base font-semibold text-navy">{ex.prompt}</p>
      <div className="flex flex-wrap gap-2.5">
        {options.map((opt) => {
          const isPicked = picked === opt;
          const isCorrect = opt === ex.correct;
          let cls = "border-border bg-white text-navy hover:border-teal hover:bg-teal-light";
          if (passed && isCorrect) cls = "border-teal bg-teal-light text-teal-dark";
          else if (isPicked && !isCorrect) cls = "border-red-300 bg-red-50 text-red-700";
          return (
            <button
              key={opt}
              type="button"
              onClick={() => pick(opt)}
              className={`py-3 px-5 rounded-xl border-2 text-sm font-semibold tracking-wide transition-all ${cls}`}
            >
              {opt}
            </button>
          );
        })}
      </div>
      {picked && picked !== ex.correct && !passed && (
        <p className="text-xs text-red-600">Not that one — try again.</p>
      )}
    </div>
  );
}

function SpeakingExercise({
  ex,
  lang,
  onResult,
  passed,
}: {
  ex: Extract<GatedExercise, { kind: "speaking" }>;
  lang: string;
  onResult: (r: ExerciseResult) => void;
  passed: boolean;
}) {
  const [transcript, setTranscript] = useState("");
  const [listening, setListening] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [lastCorrect, setLastCorrect] = useState<boolean | null>(null);
  const recRef = useRef<ISpeechRecognition | null>(null);
  const SR = getSpeechRecognition();
  const supported = SR !== null;

  function start() {
    if (!SR || passed) return;
    setError(null);
    setTranscript("");
    setLastCorrect(null);
    const rec = new SR();
    rec.lang = lang;
    rec.interimResults = true;
    rec.continuous = false;
    rec.onresult = (ev) => {
      let text = "";
      for (let i = ev.resultIndex; i < ev.results.length; i++) {
        text += ev.results[i][0].transcript;
      }
      setTranscript(text);
    };
    rec.onerror = (ev) => {
      setError(ev.error === "not-allowed" ? "Microphone blocked — allow it in your browser." : `Error: ${ev.error}`);
      setListening(false);
    };
    rec.onend = () => {
      setListening(false);
      setTranscript((cur) => {
        if (cur.trim()) {
          const ok = pronunciationMatches(cur, ex.expected);
          setLastCorrect(ok);
          onResult({ correct: ok, heard: cur });
        }
        return cur;
      });
    };
    recRef.current = rec;
    setListening(true);
    rec.start();
  }

  function stop() {
    recRef.current?.stop();
    setListening(false);
  }

  function markManualPass() {
    setLastCorrect(true);
    onResult({ correct: true, heard: "(marked as said)" });
  }

  return (
    <div className="space-y-3">
      <p className="text-base font-semibold text-navy">{ex.prompt}</p>
      <div className="rounded-xl border-2 border-peach-dark/40 bg-peach-light p-4 flex items-center gap-3">
        <div className="flex-shrink-0 w-10 h-10 rounded-full bg-amber-100 text-amber-700 flex items-center justify-center">
          <svg className="w-5 h-5" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M12 18.75a6 6 0 0 0 6-6v-1.5m-6 7.5a6 6 0 0 1-6-6v-1.5m6 7.5v3.75m-3.75 0h7.5M12 15.75a3 3 0 0 1-3-3V4.5a3 3 0 1 1 6 0v8.25a3 3 0 0 1-3 3Z" /></svg>
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-lg font-semibold text-navy leading-tight">{ex.expected}</p>
          <p className="text-sm text-navy/70">{ex.translation}</p>
        </div>
        <PlayWordButton text={ex.expected} lang={lang} size="sm" />
      </div>
      <div className="rounded-xl border-2 border-border bg-white p-4 min-h-[64px]">
        <p className="text-[10px] font-semibold uppercase tracking-wider text-navy/50 mb-1">You said</p>
        <p className="text-sm text-navy min-h-[1.25rem]">
          {transcript || (listening ? <span className="text-navy/50">Listening…</span> : <span className="text-navy/30">Press the mic and say it aloud.</span>)}
        </p>
        {lastCorrect === false && (
          <p className="text-xs text-red-600 mt-1.5">Close, but not quite. Try again — press the mic.</p>
        )}
        {lastCorrect === true && (
          <p className="text-xs text-teal-dark font-semibold mt-1.5">✓ Nice — that's it.</p>
        )}
      </div>
      {error && <p className="text-xs text-red-600">{error}</p>}
      <div className="flex flex-wrap gap-2">
        {supported ? (
          listening ? (
            <button type="button" onClick={stop} className="flex-1 py-2.5 text-sm font-semibold text-white bg-red-500 rounded-xl hover:bg-red-600 transition-colors">
              Stop
            </button>
          ) : (
            <button type="button" onClick={start} className="flex-1 py-2.5 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors" disabled={passed}>
              {passed ? "✓ Passed" : "🎤 Speak"}
            </button>
          )
        ) : (
          <>
            <p className="text-xs text-amber-800 bg-amber-50 border border-amber-200 rounded-xl px-3 py-2 flex-1">
              Speech recognition not supported in this browser. Tap the button to advance after saying it.
            </p>
            <button type="button" onClick={markManualPass} className="py-2.5 px-4 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors">
              I said it
            </button>
          </>
        )}
      </div>
    </div>
  );
}

function FillBlankExercise({
  ex,
  onResult,
  passed,
}: {
  ex: Extract<GatedExercise, { kind: "fill_blank" }>;
  onResult: (r: ExerciseResult) => void;
  passed: boolean;
}) {
  const [value, setValue] = useState("");
  const [wrongAttempt, setWrongAttempt] = useState(false);

  function submit(e: React.FormEvent) {
    e.preventDefault();
    if (passed || !value.trim()) return;
    const ok = normalize(value) === normalize(ex.correct);
    setWrongAttempt(!ok);
    onResult({ correct: ok });
  }

  return (
    <form onSubmit={submit} className="space-y-3">
      <p className="text-base font-semibold text-navy">{ex.prompt}</p>
      {ex.hint && <p className="text-xs text-navy/60 italic">Hint: {ex.hint}</p>}
      <input
        type="text"
        value={value}
        onChange={(e) => { setValue(e.target.value); setWrongAttempt(false); }}
        disabled={passed}
        autoFocus
        placeholder="Type your answer"
        className={`w-full px-4 py-3 rounded-xl border-2 bg-white text-navy font-medium text-lg placeholder:text-navy/30 focus:outline-none transition-colors ${
          passed
            ? "border-teal bg-teal-light"
            : wrongAttempt
              ? "border-red-300 bg-red-50"
              : "border-border focus:border-teal focus:ring-2 focus:ring-teal/20"
        }`}
      />
      {!passed && (
        <button type="submit" disabled={!value.trim()} className="w-full py-2.5 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors disabled:opacity-50">
          Check
        </button>
      )}
      {wrongAttempt && !passed && (
        <p className="text-xs text-red-600">Not quite — try again.</p>
      )}
    </form>
  );
}

function GatedExerciseView({
  exercise,
  lang,
  onResult,
  passed,
}: {
  exercise: GatedExercise;
  lang: string;
  onResult: (r: ExerciseResult) => void;
  passed: boolean;
}) {
  if (exercise.kind === "multiple_choice")
    return <MultipleChoiceExercise ex={exercise} onResult={onResult} passed={passed} />;
  if (exercise.kind === "tap_word")
    return <TapWordExercise ex={exercise} onResult={onResult} passed={passed} />;
  if (exercise.kind === "fill_blank")
    return <FillBlankExercise ex={exercise} onResult={onResult} passed={passed} />;
  return <SpeakingExercise ex={exercise} lang={lang} onResult={onResult} passed={passed} />;
}

// ============================================================
// End-of-lesson quiz question view (one at a time)
// ============================================================

function EndQuizQuestionView({
  q,
  lang,
  onAnswered,
}: {
  q: EndQuizQuestion;
  lang: string;
  onAnswered: (correct: boolean) => void;
}) {
  const [answered, setAnswered] = useState(false);
  const [correct, setCorrect] = useState(false);
  const [value, setValue] = useState("");
  const options = useMemo(() => {
    if (q.kind === "multiple_choice" || q.kind === "listening")
      return shuffle([q.correct, ...q.wrong]);
    return [];
  }, [q]);

  function submitOption(opt: string) {
    if (answered) return;
    const ok = opt === (q as { correct: string }).correct;
    setAnswered(true);
    setCorrect(ok);
    onAnswered(ok);
  }

  function submitFill(e: React.FormEvent) {
    e.preventDefault();
    if (answered || !value.trim()) return;
    const ok = normalize(value) === normalize((q as { correct: string }).correct);
    setAnswered(true);
    setCorrect(ok);
    onAnswered(ok);
  }

  if (q.kind === "multiple_choice") {
    return (
      <div className="space-y-3">
        <p className="text-base font-semibold text-navy">{q.question}</p>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
          {options.map((opt) => {
            const isCorrectOpt = opt === q.correct;
            let cls = "border-border bg-white text-navy hover:border-teal";
            if (answered && isCorrectOpt) cls = "border-teal bg-teal-light text-teal-dark";
            else if (answered && !isCorrectOpt) cls = "border-border bg-white text-navy/40";
            return (
              <button
                key={opt}
                type="button"
                onClick={() => submitOption(opt)}
                disabled={answered}
                className={`py-3 px-4 rounded-xl border-2 text-start text-sm font-medium transition-all ${cls}`}
              >
                {opt}
              </button>
            );
          })}
        </div>
        {answered && (
          <p className={`text-xs font-semibold ${correct ? "text-teal-dark" : "text-red-600"}`}>
            {correct ? "✓ Correct" : `✗ Correct answer: ${q.correct}`}
          </p>
        )}
      </div>
    );
  }

  if (q.kind === "listening") {
    return (
      <div className="space-y-3">
        <p className="text-base font-semibold text-navy">{q.question}</p>
        <div className="flex items-center gap-3 rounded-xl bg-navy/5 p-4">
          <PlayWordButton text={q.audio} lang={lang} size="md" />
          <span className="text-sm text-navy/70">Listen carefully.</span>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
          {options.map((opt) => {
            const isCorrectOpt = opt === q.correct;
            let cls = "border-border bg-white text-navy hover:border-teal";
            if (answered && isCorrectOpt) cls = "border-teal bg-teal-light text-teal-dark";
            else if (answered && !isCorrectOpt) cls = "border-border bg-white text-navy/40";
            return (
              <button
                key={opt}
                type="button"
                onClick={() => submitOption(opt)}
                disabled={answered}
                className={`py-3 px-4 rounded-xl border-2 text-start text-sm font-medium transition-all ${cls}`}
              >
                {opt}
              </button>
            );
          })}
        </div>
        {answered && (
          <p className={`text-xs font-semibold ${correct ? "text-teal-dark" : "text-red-600"}`}>
            {correct ? "✓ Correct" : `✗ Correct answer: ${q.correct}`}
          </p>
        )}
      </div>
    );
  }

  if (q.kind === "fill_blank") {
    return (
      <form onSubmit={submitFill} className="space-y-3">
        <p className="text-base font-semibold text-navy">{q.prompt}</p>
        {q.hint && <p className="text-xs text-navy/60 italic">Hint: {q.hint}</p>}
        <input
          type="text"
          value={value}
          onChange={(e) => setValue(e.target.value)}
          disabled={answered}
          autoFocus
          placeholder="Type your answer"
          className={`w-full px-4 py-3 rounded-xl border-2 bg-white text-navy font-medium text-lg placeholder:text-navy/30 focus:outline-none transition-colors ${
            answered
              ? correct
                ? "border-teal bg-teal-light"
                : "border-red-300 bg-red-50"
              : "border-border focus:border-teal focus:ring-2 focus:ring-teal/20"
          }`}
        />
        {!answered && (
          <button type="submit" disabled={!value.trim()} className="w-full py-2.5 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors disabled:opacity-50">
            Check
          </button>
        )}
        {answered && (
          <p className={`text-xs font-semibold ${correct ? "text-teal-dark" : "text-red-600"}`}>
            {correct ? "✓ Correct" : `✗ Correct answer: ${q.correct}`}
          </p>
        )}
      </form>
    );
  }

  // speaking
  return (
    <SpeakingExercise
      ex={q}
      lang={lang}
      onResult={(r) => {
        if (answered) return;
        setAnswered(true);
        setCorrect(r.correct);
        onAnswered(r.correct);
      }}
      passed={answered}
    />
  );
}

// ============================================================
// LessonImage — shared opening/buildup image component.
// - Shows a shimmer placeholder while the image loads.
// - On load error (broken URL, network fail, expired CDN), swaps
//   in a per-city Unsplash fallback with a soft "image unavailable"
//   caption instead of the browser's default broken-image glyph.
// ============================================================

const CITY_FALLBACK_IMAGES: Record<string, string> = {
  Madrid:         "https://images.unsplash.com/photo-1543783207-ec64e4d95325?w=1600&h=1200&fit=crop&q=80",
  Barcelona:      "https://images.unsplash.com/photo-1583422409516-2895a77efded?w=1600&h=1200&fit=crop&q=80",
  "Mexico City":  "https://images.unsplash.com/photo-1518659526054-190340b32735?w=1600&h=1200&fit=crop&q=80",
  "Buenos Aires": "https://images.unsplash.com/photo-1589909202802-8f4aadce1849?w=1600&h=1200&fit=crop&q=80",
  Paris:          "https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=1600&h=1200&fit=crop&q=80",
  Lyon:           "https://images.unsplash.com/photo-1524484485831-a92ffc0de03f?w=1600&h=1200&fit=crop&q=80",
  Montreal:       "https://images.unsplash.com/photo-1519178614-68673b201f36?w=1600&h=1200&fit=crop&q=80",
};

function LessonImage({
  src,
  alt,
  city,
  priority = false,
}: {
  src: string | null | undefined;
  alt: string;
  city: string;
  priority?: boolean;
}) {
  const [loading, setLoading] = useState(true);
  const [errored, setErrored] = useState(false);
  const fallback = CITY_FALLBACK_IMAGES[city] ?? CITY_FALLBACK_IMAGES.Madrid;
  const showFallback = !src || errored;
  const url = showFallback ? fallback : src;

  return (
    <div className="relative w-full aspect-[4/3] rounded-3xl overflow-hidden bg-navy shadow-2xl">
      {loading && !showFallback && (
        <div className="absolute inset-0 animate-pulse bg-gradient-to-br from-navy/70 via-navy/60 to-navy/80" />
      )}
      <Image
        src={url}
        alt={alt}
        fill
        sizes="(max-width: 768px) 100vw, 768px"
        className={`object-cover transition-opacity duration-500 ${loading && !showFallback ? "opacity-0" : "opacity-100"}`}
        priority={priority}
        unoptimized
        onLoad={() => setLoading(false)}
        onError={() => {
          setErrored(true);
          setLoading(false);
        }}
      />
      {showFallback && (
        <div className="absolute inset-x-0 bottom-0 bg-gradient-to-t from-navy/90 via-navy/60 to-transparent px-5 pt-8 pb-4">
          <p className="text-[10px] uppercase tracking-[0.2em] font-bold text-white/70">
            {city} · reference photo
          </p>
          <p className="text-sm text-white/85 leading-snug mt-1">{alt}</p>
        </div>
      )}
    </div>
  );
}

// ============================================================
// Step components
// ============================================================

function OpeningImageStep({
  lesson,
  onContinue,
}: {
  lesson: PreviewLesson;
  onContinue: () => void;
}) {
  const opening = lesson.opening as Extract<PreviewLesson["opening"], { kind: "image" }>;
  return (
    <div className="max-w-3xl mx-auto px-4 sm:px-6 py-8 space-y-6">
      <p className="text-sm sm:text-base text-navy/80 leading-relaxed bg-peach-light border border-peach-dark/40 rounded-2xl px-5 py-4">
        <span className="text-xs uppercase tracking-wider font-bold text-peach-dark block mb-1">Scene</span>
        {lesson.scene}
      </p>
      <LessonImage
        src={opening.imageUrl}
        alt={opening.imageAlt}
        city={lesson.city}
        priority
      />
      <div className="text-center space-y-3">
        <p className="text-sm text-navy/60 italic">Look at it. Try to guess what it says before continuing.</p>
        <button
          type="button"
          onClick={onContinue}
          className="inline-flex items-center gap-2 px-8 py-3 bg-teal text-white text-sm font-semibold rounded-full hover:bg-teal-dark transition-colors shadow-lg"
        >
          Start decoding
          <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" /></svg>
        </button>
      </div>
    </div>
  );
}

function OpeningAudioStep({
  lesson,
  lang,
  onContinue,
}: {
  lesson: PreviewLesson;
  lang: string;
  onContinue: () => void;
}) {
  const opening = lesson.opening as Extract<PreviewLesson["opening"], { kind: "audio" }>;
  const { play, stop, playing, cursor } = useAudioScript(opening.script, lang);

  return (
    <div className="max-w-2xl mx-auto px-4 sm:px-6 py-8 space-y-6">
      <p className="text-sm sm:text-base text-navy/80 leading-relaxed bg-peach-light border border-peach-dark/40 rounded-2xl px-5 py-4">
        <span className="text-xs uppercase tracking-wider font-bold text-peach-dark block mb-1">Scene</span>
        {lesson.scene}
      </p>
      <div className="relative rounded-3xl bg-gradient-to-br from-navy to-navy/80 text-white p-8 sm:p-10 shadow-2xl">
        <div className="flex flex-col items-center text-center gap-5">
          <div className="text-[10px] uppercase tracking-[0.2em] text-white/60 font-bold">Recording</div>
          <p className="text-lg sm:text-xl font-medium text-white/90">
            Press play. No transcript — just listen and try to catch what you can.
          </p>
          <button
            type="button"
            onClick={playing ? stop : play}
            className="w-24 h-24 sm:w-28 sm:h-28 rounded-full bg-white text-navy shadow-2xl hover:scale-105 transition-transform flex items-center justify-center"
            aria-label={playing ? "Stop" : "Play"}
          >
            {playing ? (
              <svg className="w-10 h-10" fill="currentColor" viewBox="0 0 24 24"><path d="M6 4h4v16H6zM14 4h4v16h-4z" /></svg>
            ) : (
              <svg className="w-10 h-10 translate-x-0.5" fill="currentColor" viewBox="0 0 24 24"><path d="M8 5v14l11-7z" /></svg>
            )}
          </button>
          <p className="text-xs text-white/50">{opening.durationHint} · {opening.script.length} lines</p>
          {playing && (
            <div className="flex items-center gap-1.5">
              {opening.script.map((_, i) => (
                <div
                  key={i}
                  className={`h-1.5 w-6 rounded-full transition-colors ${
                    cursor > i ? "bg-teal" : cursor === i ? "bg-white animate-pulse" : "bg-white/20"
                  }`}
                />
              ))}
            </div>
          )}
        </div>
      </div>
      <div className="text-center">
        <button
          type="button"
          onClick={onContinue}
          className="inline-flex items-center gap-2 px-8 py-3 bg-teal text-white text-sm font-semibold rounded-full hover:bg-teal-dark transition-colors shadow-lg"
        >
          Start decoding
          <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" /></svg>
        </button>
      </div>
    </div>
  );
}

function DecodeStepView({
  step,
  index,
  total,
  lang,
  onContinue,
}: {
  step: DecodeStep;
  index: number;
  total: number;
  lang: string;
  onContinue: () => void;
}) {
  const [passed, setPassed] = useState(false);

  function handleResult(r: ExerciseResult) {
    if (r.correct) setPassed(true);
  }

  return (
    <div className="max-w-2xl mx-auto px-4 sm:px-6 py-6 space-y-5">
      <div className="text-[10px] uppercase tracking-[0.2em] font-bold text-teal-dark text-center">
        Decode · {index + 1} of {total}
      </div>

      <div className="rounded-3xl bg-white border-2 border-border shadow-lg p-6 sm:p-8 text-center space-y-3">
        <div className="text-2xl sm:text-4xl font-black text-navy tracking-tight leading-tight break-words">
          {step.wordOrPhrase}
        </div>
        <div className="text-sm text-navy/60 font-mono">{step.phonetic}</div>
        <div className="flex justify-center pt-1">
          <PlayWordButton text={step.wordOrPhrase} lang={lang} size="md" />
        </div>
        <div className="pt-2 text-lg font-semibold text-teal-dark">{step.english}</div>
      </div>

      <div className="rounded-2xl bg-teal-light border border-teal/30 p-4">
        <p className="text-[10px] uppercase tracking-wider font-bold text-teal-dark mb-1">Memory hook</p>
        <p className="text-sm text-navy/85 leading-relaxed">{step.mnemonic}</p>
      </div>

      {step.culturalNote && (
        <div className="rounded-2xl bg-peach-light border border-peach-dark/40 p-4">
          <p className="text-[10px] uppercase tracking-wider font-bold text-peach-dark mb-1">Local tip</p>
          <p className="text-sm text-navy/85 leading-relaxed">{step.culturalNote}</p>
        </div>
      )}

      {step.audioSnippet && (
        <div className="rounded-2xl bg-navy/5 border border-navy/10 p-4 flex items-center gap-3">
          <PlayWordButton text={step.audioSnippet} lang={lang} size="sm" />
          <p className="text-xs text-navy/70">Replay this part of the recording.</p>
        </div>
      )}

      <div className="rounded-2xl bg-white border-2 border-border p-5">
        <p className="text-[10px] uppercase tracking-wider font-bold text-navy/50 mb-3">Quick check</p>
        <GatedExerciseView exercise={step.gatedExercise} lang={lang} onResult={handleResult} passed={passed} />
      </div>

      <div className="pt-2">
        <button
          type="button"
          onClick={onContinue}
          disabled={!passed}
          className="w-full py-3.5 text-sm font-semibold text-white bg-teal rounded-full hover:bg-teal-dark transition-colors shadow-md disabled:opacity-40 disabled:cursor-not-allowed"
        >
          {passed ? "Continue →" : "Answer the check first"}
        </button>
      </div>
    </div>
  );
}

function BuildupStep({
  lesson,
  lang,
  onContinue,
}: {
  lesson: PreviewLesson;
  lang: string;
  onContinue: () => void;
}) {
  const opening = lesson.opening;
  const [revealed, setRevealed] = useState(false);
  const isAudio = opening.kind === "audio";
  const audioCtrl = useAudioScript(isAudio ? (opening as Extract<PreviewLesson["opening"], { kind: "audio" }>).script : [], lang);

  return (
    <div className="max-w-2xl mx-auto px-4 sm:px-6 py-8 space-y-6 text-center">
      <div className="text-[10px] uppercase tracking-[0.2em] font-bold text-teal-dark">You decoded it</div>
      <h2 className="text-2xl sm:text-3xl font-black text-navy leading-tight">
        Now hear/see the whole thing again — this time it'll make sense.
      </h2>

      {isAudio ? (
        <div className="rounded-3xl bg-gradient-to-br from-navy to-navy/80 text-white p-8 shadow-xl">
          <button
            type="button"
            onClick={audioCtrl.playing ? audioCtrl.stop : audioCtrl.play}
            className="w-20 h-20 rounded-full bg-white text-navy shadow-2xl hover:scale-105 transition-transform flex items-center justify-center mx-auto"
          >
            {audioCtrl.playing ? (
              <svg className="w-8 h-8" fill="currentColor" viewBox="0 0 24 24"><path d="M6 4h4v16H6zM14 4h4v16h-4z" /></svg>
            ) : (
              <svg className="w-8 h-8 translate-x-0.5" fill="currentColor" viewBox="0 0 24 24"><path d="M8 5v14l11-7z" /></svg>
            )}
          </button>
          <p className="text-xs text-white/60 mt-4">Replay the whole recording</p>
        </div>
      ) : (
        <LessonImage
          src={(opening as Extract<PreviewLesson["opening"], { kind: "image" }>).imageUrl}
          alt={(opening as Extract<PreviewLesson["opening"], { kind: "image" }>).imageAlt}
          city={lesson.city}
        />
      )}

      {!revealed ? (
        <button
          type="button"
          onClick={() => setRevealed(true)}
          className="inline-flex items-center gap-2 px-6 py-2.5 bg-white border-2 border-teal text-teal-dark text-sm font-semibold rounded-full hover:bg-teal-light transition-colors"
        >
          Reveal the full meaning
        </button>
      ) : (
        <div className="space-y-4 animate-in fade-in slide-in-from-bottom-2 duration-500">
          <div className="rounded-3xl bg-teal-light border-2 border-teal/40 p-6">
            <p className="text-[10px] uppercase tracking-wider font-bold text-teal-dark mb-2">In English</p>
            <p className="text-lg sm:text-xl font-semibold text-navy leading-relaxed">
              {lesson.buildup.fullEnglish}
            </p>
          </div>
          <p className="text-sm italic text-navy/70 leading-relaxed">
            {lesson.buildup.celebrationMessage}
          </p>
          <button
            type="button"
            onClick={onContinue}
            className="inline-flex items-center gap-2 px-8 py-3 bg-teal text-white text-sm font-semibold rounded-full hover:bg-teal-dark transition-colors shadow-lg"
          >
            Take the quiz →
          </button>
        </div>
      )}
    </div>
  );
}

function EndQuizStep({
  lesson,
  lang,
  onFinish,
}: {
  lesson: PreviewLesson;
  lang: string;
  onFinish: (score: { correct: number; total: number }) => void;
}) {
  const [cursor, setCursor] = useState(0);
  const [correctCount, setCorrectCount] = useState(0);
  const [lastAnswered, setLastAnswered] = useState(false);

  const total = lesson.endQuiz.length;
  const q = lesson.endQuiz[cursor];

  function handleAnswered(correct: boolean) {
    if (lastAnswered) return;
    setLastAnswered(true);
    if (correct) setCorrectCount((c) => c + 1);
  }

  function next() {
    if (!lastAnswered) return;
    const nextIdx = cursor + 1;
    if (nextIdx >= total) {
      onFinish({ correct: correctCount, total });
      return;
    }
    setCursor(nextIdx);
    setLastAnswered(false);
  }

  return (
    <div className="max-w-2xl mx-auto px-4 sm:px-6 py-6 space-y-5">
      <div className="text-[10px] uppercase tracking-[0.2em] font-bold text-peach-dark text-center">
        Quiz · {cursor + 1} of {total}
      </div>
      <div className="rounded-3xl bg-white border-2 border-border shadow-md p-6">
        <EndQuizQuestionView key={cursor} q={q} lang={lang} onAnswered={handleAnswered} />
      </div>
      <button
        type="button"
        onClick={next}
        disabled={!lastAnswered}
        className="w-full py-3.5 text-sm font-semibold text-white bg-teal rounded-full hover:bg-teal-dark transition-colors shadow-md disabled:opacity-40 disabled:cursor-not-allowed"
      >
        {cursor + 1 === total ? "Finish lesson" : "Next question →"}
      </button>
    </div>
  );
}

function CompleteStep({
  lesson,
  score,
  isPreview,
  isPremium,
  exitHref,
  nextLessonHref,
}: {
  lesson: PreviewLesson;
  score: { correct: number; total: number };
  isPreview: boolean;
  isPremium: boolean;
  exitHref: string;
  nextLessonHref?: string;
}) {
  const pct = Math.round((score.correct / score.total) * 100);
  const xpEarned = Math.round(lesson.xpReward * (pct / 100));
  const next = lesson.nextLesson;
  const nextLocked = !!(next && next.isPremium && !isPremium);

  return (
    <div className="max-w-lg mx-auto px-4 sm:px-6 py-10 text-center space-y-6">
      <div className="mx-auto w-24 h-24 rounded-full bg-teal-light border-4 border-teal flex items-center justify-center animate-in zoom-in duration-500">
        <svg className="w-12 h-12 text-teal-dark" fill="none" stroke="currentColor" strokeWidth={3} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" /></svg>
      </div>
      <div>
        <h2 className="text-3xl font-black text-navy">Lesson complete</h2>
        <p className="text-sm text-navy/60 mt-1">{lesson.location}, {lesson.city}</p>
      </div>
      <div className="grid grid-cols-2 gap-3">
        <div className="rounded-2xl bg-white border-2 border-border p-4">
          <p className="text-[10px] uppercase tracking-wider font-bold text-navy/50 mb-1">Score</p>
          <p className="text-2xl font-black text-navy">{score.correct}/{score.total}</p>
          <p className="text-xs text-navy/60">{pct}%</p>
        </div>
        <div className="rounded-2xl bg-peach-light border-2 border-peach-dark p-4">
          <p className="text-[10px] uppercase tracking-wider font-bold text-peach-dark mb-1">XP earned</p>
          <p className="text-2xl font-black text-navy">+{xpEarned}</p>
          <p className="text-xs text-navy/60">of {lesson.xpReward} possible</p>
        </div>
      </div>
      {isPreview && (
        <p className="text-xs italic text-navy/60">
          In the real lesson, this writes to <code className="bg-white px-1 rounded">traveler_progress</code>. This preview does not.
        </p>
      )}
      {next && (
        <div className="rounded-3xl bg-navy text-white p-6 text-start space-y-2 shadow-xl">
          <p className="text-[10px] uppercase tracking-[0.2em] text-white/60 font-bold">Next stop</p>
          <h3 className="text-xl font-bold">{next.title}</h3>
          <p className="text-sm text-white/70">{next.location}</p>
          {nextLocked ? (
            <Link
              href="/pricing"
              className="mt-2 block w-full text-center py-3 bg-peach text-peach-dark font-semibold text-sm rounded-full hover:bg-peach-dark hover:text-white transition-colors"
            >
              Unlock with Premium →
            </Link>
          ) : nextLessonHref ? (
            <Link
              href={nextLessonHref}
              className="mt-2 block w-full text-center py-3 bg-white text-navy font-semibold text-sm rounded-full hover:bg-teal-light transition-colors"
            >
              Continue journey →
            </Link>
          ) : (
            <button
              type="button"
              className="mt-2 w-full py-3 bg-white text-navy font-semibold text-sm rounded-full hover:bg-teal-light transition-colors"
            >
              Continue journey →
            </button>
          )}
        </div>
      )}
      <Link href={exitHref} className="inline-block text-sm text-teal-dark hover:underline">
        ← {isPreview ? "Back to preview index" : "Back to city timeline"}
      </Link>
    </div>
  );
}

// ============================================================
// Runner
// ============================================================

type Phase =
  | { kind: "opening" }
  | { kind: "decode"; index: number }
  | { kind: "buildup" }
  | { kind: "quiz" }
  | { kind: "complete"; score: { correct: number; total: number } };

export default function PreviewLessonRunner({
  lesson,
  lang,
  lessonId,
  markComplete,
  exitHref,
  nextLessonHref,
  isPremium,
}: {
  lesson: PreviewLesson;
  lang: string;
  // Real-lesson wiring. When lessonId + markComplete are provided the
  // runner reports the final score to Supabase via the server action;
  // otherwise it stays in preview mode (no writes).
  lessonId?: number;
  markComplete?: (lessonId: number) => Promise<number>;
  exitHref?: string;
  nextLessonHref?: string;
  isPremium?: boolean;
}) {
  const [phase, setPhase] = useState<Phase>({ kind: "opening" });
  const isPreview = !lessonId || !markComplete;
  const resolvedExitHref = exitHref ?? "/preview/madrid";

  const totalSteps = 1 + lesson.decodeSteps.length + 1 + 1; // opening + decodes + buildup + quiz
  const currentStep = useMemo(() => {
    if (phase.kind === "opening") return 1;
    if (phase.kind === "decode") return 1 + phase.index + 1;
    if (phase.kind === "buildup") return 1 + lesson.decodeSteps.length + 1;
    return totalSteps;
  }, [phase, lesson.decodeSteps.length, totalSteps]);

  function advance() {
    setPhase((p) => {
      if (p.kind === "opening") return { kind: "decode", index: 0 };
      if (p.kind === "decode") {
        const next = p.index + 1;
        if (next >= lesson.decodeSteps.length) return { kind: "buildup" };
        return { kind: "decode", index: next };
      }
      if (p.kind === "buildup") return { kind: "quiz" };
      return p;
    });
  }

  async function finish(score: { correct: number; total: number }) {
    setPhase({ kind: "complete", score });
    if (!isPreview && lessonId && markComplete) {
      // Fire-and-forget; the completion screen doesn't wait on the write.
      // Any error is logged but doesn't block the celebration.
      try { await markComplete(lessonId); }
      catch (err) { console.error("markLessonComplete failed:", err); }
    }
  }

  const progressPct = Math.min(100, Math.round((currentStep / totalSteps) * 100));

  return (
    <div className="min-h-screen bg-background pb-16">
      {/* Progress bar */}
      <div className="sticky top-16 z-10 bg-background/95 backdrop-blur border-b border-border">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 py-3 flex items-center gap-4">
          <Link href={resolvedExitHref} className="text-xs text-navy/60 hover:text-navy shrink-0">
            ← {isPreview ? "Exit preview" : "Exit lesson"}
          </Link>
          <div className="flex-1 h-2 rounded-full bg-border overflow-hidden">
            <div className="h-full bg-teal transition-all duration-500" style={{ width: `${progressPct}%` }} />
          </div>
          <p className="text-xs text-navy/60 font-medium tabular-nums shrink-0">
            {phase.kind === "complete" ? "Done" : `${currentStep}/${totalSteps}`}
          </p>
        </div>
      </div>

      {/* Header */}
      <div className="max-w-3xl mx-auto px-4 sm:px-6 pt-6 pb-2 text-center">
        <p className="text-[10px] uppercase tracking-[0.2em] font-bold text-navy/50">
          {lesson.city} · Lesson {lesson.orderIndex}
        </p>
        <h1 className="text-xl sm:text-2xl font-black text-navy mt-1">{lesson.title}</h1>
      </div>

      {phase.kind === "opening" && lesson.opening.kind === "image" && (
        <OpeningImageStep lesson={lesson} onContinue={advance} />
      )}
      {phase.kind === "opening" && lesson.opening.kind === "audio" && (
        <OpeningAudioStep lesson={lesson} lang={lang} onContinue={advance} />
      )}
      {phase.kind === "decode" && (
        <DecodeStepView
          key={phase.index}
          step={lesson.decodeSteps[phase.index]}
          index={phase.index}
          total={lesson.decodeSteps.length}
          lang={lang}
          onContinue={advance}
        />
      )}
      {phase.kind === "buildup" && <BuildupStep lesson={lesson} lang={lang} onContinue={advance} />}
      {phase.kind === "quiz" && (
        <EndQuizStep
          lesson={lesson}
          lang={lang}
          onFinish={finish}
        />
      )}
      {phase.kind === "complete" && (
        <CompleteStep
          lesson={lesson}
          score={phase.score}
          isPreview={isPreview}
          isPremium={!!isPremium}
          exitHref={resolvedExitHref}
          nextLessonHref={nextLessonHref}
        />
      )}
    </div>
  );
}

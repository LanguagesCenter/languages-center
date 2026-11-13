"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import type {
  PreviewLesson,
  DecodeStep,
  DecodeHighlight,
  GatedExercise,
  EndQuizQuestion,
  AudioLine,
  TranslationCheck,
} from "@/lib/traveler-preview";
import {
  speak,
  playScript,
  warmUpSpeech,
  isAudioAvailable,
  type PlayHandle,
} from "@/lib/speech";

// ============================================================
// Play buttons — thin wrappers over lib/speech.ts.
//
// Critical rule: speak() is called SYNCHRONOUSLY inside the click
// handler. Safari/iOS drop the utterance otherwise.
// ============================================================

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
  const [playing, setPlaying] = useState(false);
  const [unavailable, setUnavailable] = useState(false);
  const handleRef = useRef<PlayHandle | null>(null);

  // Warm up voices on first mount so the first click doesn't fire
  // before getVoices() has returned anything.
  useEffect(() => {
    warmUpSpeech();
  }, []);

  const toggle = useCallback(() => {
    if (playing) {
      handleRef.current?.stop();
      setPlaying(false);
      return;
    }
    // Synchronous speak() — do NOT wrap in setTimeout or await.
    const handle = speak(text, lang, {
      rate: 0.9,
      onstart: () => setPlaying(true),
      onend: () => setPlaying(false),
      onerror: (reason) => {
        setPlaying(false);
        if (reason === "speech-synthesis-unavailable") setUnavailable(true);
      },
    });
    handleRef.current = handle;
    // Fire the state update too, in case onstart never fires
    // (some engines go straight to onend without onstart).
    setPlaying(true);
    // Safety net: if nothing starts within 2s and no voices exist,
    // flip to the unavailable state so the UI can message the user.
    setTimeout(() => {
      if (!isAudioAvailable()) setUnavailable(true);
    }, 2000);
  }, [playing, text, lang]);

  useEffect(() => () => handleRef.current?.stop(), []);

  const sizeClass =
    size === "sm" ? "w-9 h-9" : size === "lg" ? "w-16 h-16" : "w-12 h-12";
  const iconSize =
    size === "sm" ? "w-4 h-4" : size === "lg" ? "w-7 h-7" : "w-5 h-5";
  const toneClass = onDark
    ? "bg-white/20 text-white hover:bg-white/30 backdrop-blur"
    : "bg-teal text-white hover:bg-teal-dark";

  if (unavailable) {
    return (
      <span
        title="Audio isn't available on this device"
        className={`inline-flex items-center justify-center rounded-full ${sizeClass} bg-navy/10 text-navy/40 cursor-not-allowed`}
      >
        <svg className={iconSize} fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" d="M12 6v12m6-6H6" />
        </svg>
      </span>
    );
  }

  return (
    <button
      type="button"
      onClick={toggle}
      aria-label={playing ? "Stop" : "Play"}
      className={`inline-flex items-center justify-center rounded-full transition-colors shadow-md ${sizeClass} ${toneClass} ${playing ? "animate-pulse" : ""}`}
    >
      {playing ? (
        <svg className={iconSize} fill="currentColor" viewBox="0 0 24 24"><path d="M6 4h4v16H6zM14 4h4v16h-4z" /></svg>
      ) : (
        <svg className={iconSize} fill="currentColor" viewBox="0 0 24 24"><path d="M8 5v14l11-7z" /></svg>
      )}
    </button>
  );
}

// Thin hook over playScript for the opening / buildup audio panel.
function useAudioScript(script: AudioLine[], lang: string) {
  const [playing, setPlaying] = useState(false);
  const [cursor, setCursor] = useState(-1);
  const handleRef = useRef<PlayHandle | null>(null);

  useEffect(() => {
    warmUpSpeech();
  }, []);

  const stop = useCallback(() => {
    handleRef.current?.stop();
    setPlaying(false);
    setCursor(-1);
  }, []);

  const play = useCallback(() => {
    setPlaying(true);
    // Synchronous call from the click handler.
    const handle = playScript(script, lang, {
      onCursor: (i) => setCursor(i),
      onDone: () => {
        setPlaying(false);
        setCursor(-1);
      },
    });
    handleRef.current = handle;
  }, [script, lang]);

  useEffect(() => () => stop(), [stop]);

  return { play, stop, playing, cursor };
}

// ============================================================
// prefers-reduced-motion & typing animation
// ============================================================

function usePrefersReducedMotion(): boolean {
  const [reduced, setReduced] = useState(false);
  useEffect(() => {
    if (typeof window === "undefined" || !window.matchMedia) return;
    const mq = window.matchMedia("(prefers-reduced-motion: reduce)");
    setReduced(mq.matches);
    const onChange = () => setReduced(mq.matches);
    mq.addEventListener("change", onChange);
    return () => mq.removeEventListener("change", onChange);
  }, []);
  return reduced;
}

// Types-out `text` one character at a time. Caller can call `finish()`
// to snap to the final string instantly. Respects reduced motion.
function useTypedText(text: string, msPerChar = 28): {
  shown: string;
  done: boolean;
  finish: () => void;
} {
  const reducedMotion = usePrefersReducedMotion();
  const [shown, setShown] = useState<string>(reducedMotion ? text : "");
  const [done, setDone] = useState<boolean>(reducedMotion);
  const timerRef = useRef<number | null>(null);
  const idxRef = useRef(0);

  useEffect(() => {
    if (reducedMotion) {
      setShown(text);
      setDone(true);
      return;
    }
    setShown("");
    setDone(false);
    idxRef.current = 0;
    const tick = () => {
      idxRef.current += 1;
      setShown(text.slice(0, idxRef.current));
      if (idxRef.current >= text.length) {
        setDone(true);
        return;
      }
      timerRef.current = window.setTimeout(tick, msPerChar);
    };
    timerRef.current = window.setTimeout(tick, msPerChar);
    return () => {
      if (timerRef.current != null) window.clearTimeout(timerRef.current);
    };
  }, [text, msPerChar, reducedMotion]);

  const finish = useCallback(() => {
    if (timerRef.current != null) window.clearTimeout(timerRef.current);
    setShown(text);
    setDone(true);
  }, [text]);

  return { shown, done, finish };
}

// ============================================================
// Speech recognition
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
  const expectedWords = e.split(" ");
  const heardWords = new Set(h.split(" "));
  const hit = expectedWords.filter((w) => heardWords.has(w)).length;
  return hit / expectedWords.length >= 0.7;
}

// ============================================================
// Backward-compat: derive hints[] and highlight when the lesson row
// only has the old schema (single `mnemonic` + optional `culturalNote`).
// ============================================================

function stepHints(step: DecodeStep): string[] {
  if (step.hints && step.hints.length > 0) return step.hints.slice(0, 3);
  const out: string[] = [];
  if (step.mnemonic) out.push(step.mnemonic);
  if (step.culturalNote) out.push(step.culturalNote);
  if (out.length === 0) {
    out.push("Say the word aloud and let the sound carry the meaning.");
  }
  return out.slice(0, 3);
}

// Fallback highlight when the generator didn't emit one. Caption strip
// always renders the full sign text and glows the current word if we
// can find it.
function stepHighlight(step: DecodeStep, opening: PreviewLesson["opening"]): DecodeHighlight | null {
  if (step.highlight) return step.highlight;
  if (opening.kind !== "image") return null;
  const fullText = opening.fullSignText ?? "";
  if (!fullText) return null;
  return {
    kind: "caption",
    fullText,
    highlightWord: step.wordOrPhrase,
  };
}

// ============================================================
// Correct / Incorrect feedback card
// ============================================================

function FeedbackCard({
  correct,
  expected,
  explanation,
  onContinue,
}: {
  correct: boolean;
  expected: string;
  explanation: string | null;
  onContinue: () => void;
}) {
  return (
    <div
      className={`mt-3 rounded-2xl border-2 p-5 animate-in fade-in slide-in-from-bottom-2 duration-300 ${
        correct
          ? "border-teal/40 bg-teal-light"
          : "border-red-300 bg-red-50"
      }`}
      role="status"
      aria-live="polite"
    >
      <div className="flex items-center gap-3 mb-2">
        <span
          className={`inline-flex items-center justify-center w-10 h-10 rounded-full ${
            correct ? "bg-teal text-white" : "bg-red-500 text-white"
          }`}
        >
          {correct ? (
            <svg className="w-5 h-5" fill="none" stroke="currentColor" strokeWidth={3} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
            </svg>
          ) : (
            <svg className="w-5 h-5" fill="none" stroke="currentColor" strokeWidth={3} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
            </svg>
          )}
        </span>
        <p
          className={`text-lg font-bold ${
            correct ? "text-teal-dark" : "text-red-700"
          }`}
        >
          {correct ? "Correct" : "Not quite"}
        </p>
      </div>
      {!correct && expected && (
        <p className="text-sm text-navy/80 mb-1">
          Correct answer: <span className="font-bold text-navy">{expected}</span>
        </p>
      )}
      {explanation && (
        <p className="text-sm text-navy/80 leading-relaxed">{explanation}</p>
      )}
      <button
        type="button"
        onClick={onContinue}
        className="mt-4 w-full py-3 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors"
      >
        Continue →
      </button>
    </div>
  );
}

// ============================================================
// Exercises (ungated — answers now reveal feedback inline)
// ============================================================

type AnswerResult = { correct: boolean; heard?: string; skipped?: boolean };

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
  onAnswered,
}: {
  ex: Extract<GatedExercise, { kind: "multiple_choice" }>;
  onAnswered: (r: AnswerResult) => void;
}) {
  const options = useMemo(() => shuffle([ex.correct, ...ex.wrong]), [ex]);
  const [picked, setPicked] = useState<string | null>(null);

  function pick(opt: string) {
    if (picked) return;
    setPicked(opt);
    onAnswered({ correct: opt === ex.correct });
  }

  return (
    <div className="space-y-3">
      <p className="text-base font-semibold text-navy">{ex.question}</p>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
        {options.map((opt) => {
          const isPicked = picked === opt;
          const isCorrect = opt === ex.correct;
          let cls = "border-border bg-white text-navy hover:border-teal hover:bg-teal-light";
          if (picked && isCorrect) cls = "border-teal bg-teal-light text-teal-dark";
          else if (isPicked && !isCorrect) cls = "border-red-300 bg-red-50 text-red-700";
          else if (picked && !isCorrect) cls = "border-border bg-white text-navy/40";
          return (
            <button
              key={opt}
              type="button"
              onClick={() => pick(opt)}
              disabled={!!picked}
              className={`w-full py-3 px-4 rounded-xl border-2 text-start text-sm font-medium transition-all ${cls}`}
            >
              {opt}
            </button>
          );
        })}
      </div>
    </div>
  );
}

function TapWordExercise({
  ex,
  onAnswered,
}: {
  ex: Extract<GatedExercise, { kind: "tap_word" }>;
  onAnswered: (r: AnswerResult) => void;
}) {
  const options = useMemo(() => shuffle([ex.correct, ...ex.distractors]), [ex]);
  const [picked, setPicked] = useState<string | null>(null);

  function pick(opt: string) {
    if (picked) return;
    setPicked(opt);
    onAnswered({ correct: opt === ex.correct });
  }

  return (
    <div className="space-y-3">
      <p className="text-base font-semibold text-navy">{ex.prompt}</p>
      <div className="flex flex-wrap gap-2.5">
        {options.map((opt) => {
          const isPicked = picked === opt;
          const isCorrect = opt === ex.correct;
          let cls = "border-border bg-white text-navy hover:border-teal hover:bg-teal-light";
          if (picked && isCorrect) cls = "border-teal bg-teal-light text-teal-dark";
          else if (isPicked && !isCorrect) cls = "border-red-300 bg-red-50 text-red-700";
          else if (picked && !isCorrect) cls = "border-border bg-white text-navy/40";
          return (
            <button
              key={opt}
              type="button"
              onClick={() => pick(opt)}
              disabled={!!picked}
              className={`py-3 px-5 rounded-xl border-2 text-sm font-semibold tracking-wide transition-all ${cls}`}
            >
              {opt}
            </button>
          );
        })}
      </div>
    </div>
  );
}

function SpeakingExercise({
  ex,
  lang,
  onAnswered,
  onSkip,
  skipLabel = "I can't speak now",
}: {
  ex: Extract<GatedExercise, { kind: "speaking" }>;
  lang: string;
  onAnswered: (r: AnswerResult) => void;
  // Called when the learner taps "I can't speak now". Parent is
  // responsible for recording the skip and moving on.
  onSkip?: () => void;
  skipLabel?: string;
}) {
  const [transcript, setTranscript] = useState("");
  const [listening, setListening] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [lastCorrect, setLastCorrect] = useState<boolean | null>(null);
  const [locked, setLocked] = useState(false);
  const recRef = useRef<ISpeechRecognition | null>(null);
  const SR = getSpeechRecognition();
  const supported = SR !== null;

  function start() {
    if (!SR || locked) return;
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
          setLocked(true);
          onAnswered({ correct: ok, heard: cur });
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
    setLocked(true);
    onAnswered({ correct: true, heard: "(marked as said)" });
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
          <p className="text-xs text-red-600 mt-1.5">Close, but not quite. Try again — or skip for now.</p>
        )}
        {lastCorrect === true && (
          <p className="text-xs text-teal-dark font-semibold mt-1.5">✓ Nice — that's it.</p>
        )}
      </div>
      {error && <p className="text-xs text-red-600">{error}</p>}
      <div className="flex flex-col sm:flex-row gap-2">
        {supported ? (
          listening ? (
            <button type="button" onClick={stop} className="flex-1 py-3 text-sm font-semibold text-white bg-red-500 rounded-xl hover:bg-red-600 transition-colors min-h-[44px]">
              Stop
            </button>
          ) : (
            <button
              type="button"
              onClick={start}
              className="flex-1 py-3 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors min-h-[44px] disabled:opacity-60"
              disabled={locked}
            >
              {locked && lastCorrect ? "✓ Nice work" : locked ? "Try again" : "🎤 Speak"}
            </button>
          )
        ) : (
          <>
            <p className="text-xs text-amber-800 bg-amber-50 border border-amber-200 rounded-xl px-3 py-2 flex-1">
              Speech recognition not supported in this browser. Tap “I said it” after saying it aloud.
            </p>
            <button type="button" onClick={markManualPass} className="py-3 px-4 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors min-h-[44px]">
              I said it
            </button>
          </>
        )}
        {onSkip && (
          <button
            type="button"
            onClick={onSkip}
            className="py-3 px-4 text-sm font-semibold text-navy/70 bg-white border-2 border-border rounded-xl hover:border-navy/30 hover:bg-navy/5 transition-colors min-h-[44px]"
          >
            {skipLabel}
          </button>
        )}
      </div>
    </div>
  );
}

function FillBlankExercise({
  ex,
  onAnswered,
}: {
  ex: Extract<GatedExercise, { kind: "fill_blank" }>;
  onAnswered: (r: AnswerResult) => void;
}) {
  const [value, setValue] = useState("");
  const [locked, setLocked] = useState(false);

  function submit(e: React.FormEvent) {
    e.preventDefault();
    if (locked || !value.trim()) return;
    const ok = normalize(value) === normalize(ex.correct);
    setLocked(true);
    onAnswered({ correct: ok });
  }

  return (
    <form onSubmit={submit} className="space-y-3">
      <p className="text-base font-semibold text-navy">{ex.prompt}</p>
      {ex.hint && <p className="text-xs text-navy/60 italic">Hint: {ex.hint}</p>}
      <input
        type="text"
        value={value}
        onChange={(e) => setValue(e.target.value)}
        disabled={locked}
        autoFocus
        placeholder="Type your answer"
        className="w-full px-4 py-3 rounded-xl border-2 bg-white text-navy font-medium text-lg placeholder:text-navy/30 focus:outline-none transition-colors border-border focus:border-teal focus:ring-2 focus:ring-teal/20 disabled:opacity-80"
      />
      {!locked && (
        <button type="submit" disabled={!value.trim()} className="w-full py-2.5 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors disabled:opacity-50">
          Check
        </button>
      )}
    </form>
  );
}

// Wraps a gated exercise with inline feedback (correct/incorrect
// state, explanation, Continue button). Fires `onPassed` once the
// learner has moved past the feedback. Misses are reported via
// `onMiss` so the runner can re-ask the item at the end of the
// lesson quiz.
function GatedExerciseView({
  exercise,
  lang,
  stepRef,
  onPassed,
  onMiss,
  onSkipSpeaking,
}: {
  exercise: GatedExercise;
  lang: string;
  // Stable identifier for logging the miss — keyed by phase + index
  // in the parent so the same item can be re-shown later.
  stepRef: string;
  onPassed: () => void;
  onMiss: (ref: string) => void;
  onSkipSpeaking?: () => void;
}) {
  // Three possible sub-states for a speaking exercise:
  //   1. idle — show the SpeakingExercise UI
  //   2. feedback — show FeedbackCard; then on Continue
  //   3. translation-check — only if exercise has translationCheck
  // Non-speaking exercises go idle → feedback → onPassed.
  const [answered, setAnswered] = useState<null | AnswerResult>(null);
  const [phase, setPhase] = useState<"primary" | "feedback" | "xcheck">("primary");

  const expectedLabel =
    exercise.kind === "multiple_choice"
      ? exercise.correct
      : exercise.kind === "tap_word"
        ? exercise.correct
        : exercise.kind === "fill_blank"
          ? exercise.correct
          : exercise.expected;
  const explanation = exercise.explanation ?? null;

  function handle(r: AnswerResult) {
    setAnswered(r);
    setPhase("feedback");
    if (!r.correct && !r.skipped) onMiss(stepRef);
  }

  function dismissFeedback() {
    // After feedback, if this is a speaking exercise with a
    // translationCheck, show it before advancing. Otherwise finish.
    if (
      exercise.kind === "speaking" &&
      exercise.translationCheck
    ) {
      setPhase("xcheck");
      return;
    }
    onPassed();
  }

  if (phase === "xcheck" && exercise.kind === "speaking" && exercise.translationCheck) {
    return (
      <TranslationCheckView
        check={exercise.translationCheck}
        phrase={exercise.expected}
        onDone={(correct) => {
          if (!correct) onMiss(`${stepRef}:xcheck`);
          onPassed();
        }}
      />
    );
  }

  if (phase === "feedback" && answered) {
    return (
      <FeedbackCard
        correct={answered.correct || !!answered.skipped}
        expected={expectedLabel}
        explanation={explanation}
        onContinue={dismissFeedback}
      />
    );
  }

  if (exercise.kind === "multiple_choice")
    return <MultipleChoiceExercise ex={exercise} onAnswered={handle} />;
  if (exercise.kind === "tap_word")
    return <TapWordExercise ex={exercise} onAnswered={handle} />;
  if (exercise.kind === "fill_blank")
    return <FillBlankExercise ex={exercise} onAnswered={handle} />;
  return (
    <SpeakingExercise
      ex={exercise}
      lang={lang}
      onAnswered={handle}
      onSkip={
        onSkipSpeaking
          ? () => {
              onSkipSpeaking();
              handle({ correct: true, skipped: true });
            }
          : undefined
      }
    />
  );
}

// Translation-check follow-up rendered after every speaking exercise.
// The learner picks one of 4 English options. We give correct/
// incorrect feedback with an explanation, same look as the other
// exercises, then call onDone so the runner advances.
function TranslationCheckView({
  check,
  phrase,
  onDone,
}: {
  check: TranslationCheck;
  phrase: string;
  onDone: (correct: boolean) => void;
}) {
  const [picked, setPicked] = useState<number | null>(null);
  const [showFeedback, setShowFeedback] = useState(false);
  const correctOption = check.options[check.correctIndex];

  function pick(i: number) {
    if (picked !== null) return;
    setPicked(i);
    setShowFeedback(true);
  }

  if (showFeedback && picked !== null) {
    const ok = picked === check.correctIndex;
    return (
      <FeedbackCard
        correct={ok}
        expected={correctOption}
        explanation={check.explanation}
        onContinue={() => onDone(ok)}
      />
    );
  }

  return (
    <div className="space-y-3">
      <p className="text-base font-semibold text-navy">
        You just said <span className="font-black text-teal-dark">“{phrase}”</span>. What does it mean?
      </p>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
        {check.options.map((opt, i) => {
          const isCorrectOpt = i === check.correctIndex;
          const isPicked = picked === i;
          let cls = "border-border bg-white text-navy hover:border-teal hover:bg-teal-light";
          if (picked !== null && isCorrectOpt) cls = "border-teal bg-teal-light text-teal-dark";
          else if (isPicked && !isCorrectOpt) cls = "border-red-300 bg-red-50 text-red-700";
          else if (picked !== null) cls = "border-border bg-white text-navy/40";
          return (
            <button
              key={i}
              type="button"
              onClick={() => pick(i)}
              disabled={picked !== null}
              className={`w-full py-3 px-4 rounded-xl border-2 text-start text-sm font-medium transition-all min-h-[44px] ${cls}`}
            >
              {opt}
            </button>
          );
        })}
      </div>
    </div>
  );
}

// ============================================================
// Image + highlight overlay
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

// Shared opening/decode image. `highlight` optionally overlays a
// glowing pulse box + renders a caption strip beneath the image. The
// caption strip is the primary way we tie the lesson's current word
// to the picture because Unsplash / Street View text pixel coords
// aren't reliable.
//
// `pinned` switches the image into the compact variant used by the
// sticky pinned-media region at the top of the runner during decode
// steps: a wider 16:10 aspect that caps at ~30vh on mobile so the
// exercise below stays visible.
function LessonImage({
  src,
  alt,
  city,
  priority = false,
  imageSource,
  highlight,
  pinned = false,
}: {
  src: string | null | undefined;
  alt: string;
  city: string;
  priority?: boolean;
  imageSource?: "streetview" | "unsplash";
  highlight?: DecodeHighlight | null;
  pinned?: boolean;
}) {
  const [loading, setLoading] = useState(true);
  const [errored, setErrored] = useState(false);
  const fallback = CITY_FALLBACK_IMAGES[city] ?? CITY_FALLBACK_IMAGES.Madrid;
  const showFallback = !src || errored;
  const url = showFallback ? fallback : src;

  const regionHighlight =
    highlight && highlight.kind === "region" ? highlight : null;
  const captionHighlight =
    highlight && highlight.kind === "caption" ? highlight : null;

  // Pinned mode: smaller aspect ratio (16:10), hard-cap the height via
  // max-h-[30vh] on mobile so a tall photo can't eat more than ~30%
  // of the screen. object-fit stays "cover" so no letterboxing.
  // Rounded only at the bottom because the sticky wrapper's top edge
  // butts against the header.
  const framing = pinned
    ? "relative w-full aspect-[16/10] max-h-[30vh] sm:max-h-[36vh] overflow-hidden bg-navy"
    : "relative w-full aspect-[4/3] rounded-3xl overflow-hidden bg-navy shadow-2xl";

  return (
    <div className={pinned ? "" : "space-y-2"}>
      <div className={framing}>
        {loading && !showFallback && (
          <div className="absolute inset-0 animate-pulse bg-gradient-to-br from-navy/70 via-navy/60 to-navy/80" />
        )}
        <Image
          src={url}
          alt={alt}
          fill
          sizes="(max-width: 768px) 100vw, 100vw"
          className={`object-cover transition-opacity duration-500 ${loading && !showFallback ? "opacity-0" : "opacity-100"}`}
          priority={priority}
          unoptimized
          onLoad={() => setLoading(false)}
          onError={() => {
            setErrored(true);
            setLoading(false);
          }}
        />
        {regionHighlight && !showFallback && (
          <div
            className="absolute pointer-events-none animate-pulse"
            style={{
              left: `${regionHighlight.x * 100}%`,
              top: `${regionHighlight.y * 100}%`,
              width: `${regionHighlight.width * 100}%`,
              height: `${regionHighlight.height * 100}%`,
            }}
          >
            <div className="w-full h-full rounded-xl ring-4 ring-amber-300/90 shadow-[0_0_30px_rgba(252,211,77,0.9)] bg-amber-200/10" />
          </div>
        )}
        {!showFallback && imageSource === "streetview" && (
          <div className="absolute top-3 right-3 inline-flex items-center gap-1 rounded-full bg-black/60 backdrop-blur px-2.5 py-1 text-[10px] font-semibold text-white shadow-md">
            <span aria-hidden>📍</span>
            <span>Real {city} street view</span>
          </div>
        )}
        {showFallback && (
          <div className="absolute inset-x-0 bottom-0 bg-gradient-to-t from-navy/90 via-navy/60 to-transparent px-5 pt-8 pb-4">
            <p className="text-[10px] uppercase tracking-[0.2em] font-bold text-white/70">
              {city} · reference photo
            </p>
            <p className="text-sm text-white/85 leading-snug mt-1">{alt}</p>
          </div>
        )}
      </div>
      {/* Caption strip — always renders when a highlight has fullText.
          For region highlights we still show it, because the overlay
          box isn't meaningful without seeing the word. */}
      {(captionHighlight || regionHighlight) && (
        <CaptionStrip
          fullText={
            captionHighlight?.fullText ??
            regionHighlight?.text ??
            ""
          }
          highlightWord={
            captionHighlight?.highlightWord ??
            regionHighlight?.text ??
            ""
          }
        />
      )}
    </div>
  );
}

function CaptionStrip({
  fullText,
  highlightWord,
}: {
  fullText: string;
  highlightWord: string;
}) {
  // Case-insensitive, accent-insensitive substring match for the
  // highlighted segment. Rendering uses the original casing from
  // fullText so the sign looks like itself.
  const normalizedFull = fullText.normalize("NFC");
  const normalizedTarget = highlightWord.normalize("NFC");
  const i = normalizedFull.toLowerCase().indexOf(normalizedTarget.toLowerCase());
  if (!fullText) return null;
  if (i === -1) {
    return (
      <div className="rounded-xl bg-navy/90 px-4 py-2.5 text-center">
        <span className="text-sm sm:text-base font-bold text-white/90 tracking-wide">
          {fullText}
        </span>
      </div>
    );
  }
  const before = fullText.slice(0, i);
  const match = fullText.slice(i, i + highlightWord.length);
  const after = fullText.slice(i + highlightWord.length);
  return (
    <div className="rounded-xl bg-navy/90 px-4 py-2.5 text-center">
      <span className="text-sm sm:text-base font-bold text-white/70 tracking-wide">
        {before}
        <span className="relative inline-block px-1 mx-0.5 rounded bg-amber-300 text-navy animate-pulse shadow-[0_0_18px_rgba(252,211,77,0.7)]">
          {match}
        </span>
        {after}
      </span>
    </div>
  );
}

// ============================================================
// Audio player with a stylized "waveform" that highlights the
// currently-replaying snippet for a decode step.
// ============================================================

function AudioPanel({
  script,
  lang,
  snippet,
  hintActiveIndex,
  compact,
}: {
  script: AudioLine[];
  lang: string;
  // When present, replaying this exercise step should play just the
  // snippet. We render it as the "highlighted segment" in the fake
  // waveform below the main player.
  snippet?: string;
  // Which hint step we're on (0-indexed). Null = at the exercise. The
  // waveform pulses on the snippet only while the hints are showing,
  // then calms once we're at the exercise.
  hintActiveIndex?: number | null;
  // Shorter height when rendered in the pinned-media region at the
  // top of a decode step — same controls, tighter padding.
  compact?: boolean;
}) {
  const fullScript = useAudioScript(script, lang);
  const [snippetPlaying, setSnippetPlaying] = useState(false);
  const handleRef = useRef<PlayHandle | null>(null);

  function replaySnippet() {
    if (!snippet) return;
    if (snippetPlaying) {
      handleRef.current?.stop();
      setSnippetPlaying(false);
      return;
    }
    setSnippetPlaying(true);
    handleRef.current = speak(snippet, lang, {
      rate: 0.85,
      onend: () => setSnippetPlaying(false),
    });
  }

  useEffect(() => () => handleRef.current?.stop(), []);

  const totalSegments = Math.max(script.length, 1);
  const activeSegment = snippet ? Math.max(0, script.findIndex((l) => l.text.includes(snippet))) : -1;

  return (
    <div
      className={`relative bg-gradient-to-br from-navy to-navy/80 text-white ${
        compact
          ? "rounded-2xl p-3 sm:p-4 space-y-3 shadow-md"
          : "rounded-3xl p-5 sm:p-7 shadow-2xl space-y-4"
      }`}
    >
      <div className="flex items-center gap-4">
        <button
          type="button"
          onClick={fullScript.playing ? fullScript.stop : fullScript.play}
          className={`shrink-0 rounded-full bg-white text-navy shadow-xl hover:scale-105 transition-transform flex items-center justify-center ${
            compact ? "w-11 h-11" : "w-14 h-14 sm:w-16 sm:h-16"
          }`}
          aria-label={fullScript.playing ? "Stop" : "Play full recording"}
        >
          {fullScript.playing ? (
            <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24"><path d="M6 4h4v16H6zM14 4h4v16h-4z" /></svg>
          ) : (
            <svg className="w-6 h-6 translate-x-0.5" fill="currentColor" viewBox="0 0 24 24"><path d="M8 5v14l11-7z" /></svg>
          )}
        </button>
        <div className="flex-1 min-w-0">
          <p className="text-[10px] uppercase tracking-[0.2em] text-white/60 font-bold">Recording</p>
          <p className="text-sm text-white/80 mt-0.5">Replay the whole clip, or just this moment.</p>
        </div>
        {snippet && (
          <button
            type="button"
            onClick={replaySnippet}
            className="shrink-0 inline-flex items-center gap-1.5 rounded-full bg-amber-300 text-navy px-4 py-2 text-xs font-bold shadow-md hover:bg-amber-200 transition-colors"
            aria-label={snippetPlaying ? "Stop snippet" : "Replay this bit"}
          >
            {snippetPlaying ? (
              <svg className="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 24 24"><path d="M6 4h4v16H6zM14 4h4v16h-4z" /></svg>
            ) : (
              <svg className="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 24 24"><path d="M8 5v14l11-7z" /></svg>
            )}
            Replay bit
          </button>
        )}
      </div>

      {/* Stylized waveform — purely decorative bars. The segment that
          contains the current decode snippet pulses in amber so the
          learner can see where in the clip they are. */}
      <div className={`flex items-end gap-[3px] justify-center ${compact ? "h-8" : "h-14"}`}>
        {Array.from({ length: 28 }).map((_, i) => {
          const segmentIndex = Math.floor((i / 28) * totalSegments);
          const isActiveSegment = activeSegment >= 0 && segmentIndex === activeSegment;
          const playing = fullScript.cursor === segmentIndex;
          const pulseThis =
            isActiveSegment && (snippetPlaying || hintActiveIndex !== null);
          const seeded =
            (Math.sin(i * 1.7) + 1) / 2 * 0.6 + 0.3; // 0.3..0.9
          return (
            <div
              key={i}
              className={`w-1.5 rounded-full transition-colors ${
                isActiveSegment
                  ? pulseThis
                    ? "bg-amber-300 animate-pulse"
                    : "bg-amber-300/70"
                  : playing
                    ? "bg-white"
                    : "bg-white/25"
              }`}
              style={{ height: `${seeded * 100}%` }}
            />
          );
        })}
      </div>
      <p className="text-[10px] text-center uppercase tracking-wider text-white/40">
        No transcript. Train your ear.
      </p>
    </div>
  );
}

// ============================================================
// Step views
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
        imageSource={opening.imageSource}
      />
      <div className="text-center space-y-3">
        <p className="text-sm text-navy/60 italic">Look at it. Try to guess what it says before continuing.</p>
        <button
          type="button"
          onClick={onContinue}
          className="inline-flex items-center gap-2 px-8 py-3 bg-teal text-white text-sm font-semibold rounded-full hover:bg-teal-dark transition-colors shadow-lg min-h-[44px]"
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
  return (
    <div className="max-w-2xl mx-auto px-4 sm:px-6 py-8 space-y-6">
      <p className="text-sm sm:text-base text-navy/80 leading-relaxed bg-peach-light border border-peach-dark/40 rounded-2xl px-5 py-4">
        <span className="text-xs uppercase tracking-wider font-bold text-peach-dark block mb-1">Scene</span>
        {lesson.scene}
      </p>
      <AudioPanel script={opening.script} lang={lang} />
      <p className="text-xs text-white/0 text-center">{opening.durationHint}</p>
      <div className="text-center">
        <button
          type="button"
          onClick={onContinue}
          className="inline-flex items-center gap-2 px-8 py-3 bg-teal text-white text-sm font-semibold rounded-full hover:bg-teal-dark transition-colors shadow-lg min-h-[44px]"
        >
          Start decoding
          <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" /></svg>
        </button>
      </div>
    </div>
  );
}

// Pinned media region — rendered at the runner level, sticky directly
// below the header during decode steps. The image/audio stays visible
// while the hints + exercise scroll underneath.
function PinnedDecodeMedia({
  step,
  lesson,
  lang,
  hintActiveIndex,
}: {
  step: DecodeStep;
  lesson: PreviewLesson;
  lang: string;
  hintActiveIndex: number | null;
}) {
  const highlight = useMemo(
    () => stepHighlight(step, lesson.opening),
    [step, lesson.opening],
  );
  const imageOpening =
    lesson.opening.kind === "image"
      ? (lesson.opening as Extract<PreviewLesson["opening"], { kind: "image" }>)
      : null;
  const audioOpening =
    lesson.opening.kind === "audio"
      ? (lesson.opening as Extract<PreviewLesson["opening"], { kind: "audio" }>)
      : null;

  return (
    <div className="bg-background border-b border-border">
      {imageOpening && (
        <LessonImage
          src={imageOpening.imageUrl}
          alt={imageOpening.imageAlt}
          city={lesson.city}
          imageSource={imageOpening.imageSource}
          highlight={highlight ?? undefined}
          pinned
        />
      )}
      {audioOpening && (
        <div className="px-4 sm:px-6 py-3 max-w-3xl mx-auto">
          <AudioPanel
            script={audioOpening.script}
            lang={lang}
            snippet={step.audioSnippet}
            hintActiveIndex={hintActiveIndex}
            compact
          />
        </div>
      )}
    </div>
  );
}

function DecodeStepView({
  step,
  index,
  total,
  lesson,
  lang,
  onContinue,
  onMiss,
  onSkipSpeaking,
  onHintChange,
}: {
  step: DecodeStep;
  index: number;
  total: number;
  lesson: PreviewLesson;
  lang: string;
  onContinue: () => void;
  onMiss: (ref: string) => void;
  onSkipSpeaking?: (stepIndex: number) => void;
  // Reports the current hint index (or null when the exercise is
  // showing) so the parent can pulse the pinned-media waveform.
  onHintChange: (idx: number | null) => void;
}) {
  // Phase: -1..hints.length-1 for hints; hints.length for exercise.
  // The last Continue advances from hints → exercise. Tapping
  // Continue while the hint is still typing snaps it to done.
  const hints = useMemo(() => stepHints(step), [step]);
  const [hintIdx, setHintIdx] = useState(0);
  const [showExercise, setShowExercise] = useState(false);
  const [typingBypassKey, setTypingBypassKey] = useState(0);
  const typingRef = useRef<{ finish: () => void; done: boolean } | null>(null);

  useEffect(() => {
    onHintChange(showExercise ? null : hintIdx);
  }, [showExercise, hintIdx, onHintChange]);

  function onContinueHints() {
    if (showExercise) return;
    if (typingRef.current && !typingRef.current.done) {
      typingRef.current.finish();
      return;
    }
    if (hintIdx + 1 < hints.length) {
      setHintIdx((h) => h + 1);
      setTypingBypassKey((k) => k + 1);
      return;
    }
    setShowExercise(true);
  }

  return (
    <div className="max-w-3xl mx-auto px-4 sm:px-6 py-6 space-y-5">
      <div className="text-[10px] uppercase tracking-[0.2em] font-bold text-teal-dark text-center">
        Decode · {index + 1} of {total}
      </div>

      {/* Word card — no translation shown. The image/audio stays
          pinned in the sticky region above this. */}
      <div className="rounded-2xl bg-white border-2 border-border shadow-md p-5 sm:p-6 text-center space-y-2">
        <div className="text-2xl sm:text-3xl font-black text-navy tracking-tight leading-tight break-words">
          {step.wordOrPhrase}
        </div>
        <div className="text-sm text-navy/60 font-mono">{step.phonetic}</div>
        <div className="flex justify-center pt-1">
          <PlayWordButton text={step.wordOrPhrase} lang={lang} size="md" />
        </div>
      </div>

      {/* Progressive hints — typed out, big text, one per Continue */}
      {!showExercise && (
        <div
          className="rounded-2xl bg-teal-light border border-teal/30 p-5 sm:p-6 space-y-4 min-h-[140px]"
          aria-live="polite"
        >
          <p className="text-[10px] uppercase tracking-wider font-bold text-teal-dark">
            Hint {hintIdx + 1} of {hints.length}
          </p>
          <TypedHint
            key={`${index}-${hintIdx}-${typingBypassKey}`}
            text={hints[hintIdx] ?? ""}
            onRefReady={(ref) => { typingRef.current = ref; }}
          />
        </div>
      )}

      {/* Exercise after the final Continue */}
      {showExercise && (
        <div className="rounded-2xl bg-white border-2 border-border p-5 sm:p-6 space-y-3">
          <p className="text-[10px] uppercase tracking-wider font-bold text-navy/50">Quick check</p>
          <GatedExerciseView
            exercise={step.gatedExercise}
            lang={lang}
            stepRef={`decode:${index}`}
            onPassed={onContinue}
            onMiss={onMiss}
            onSkipSpeaking={
              onSkipSpeaking ? () => onSkipSpeaking(index) : undefined
            }
          />
        </div>
      )}

      {/* The hint-advance Continue button — hidden once the exercise is live */}
      {!showExercise && (
        <div className="pt-1">
          <button
            type="button"
            onClick={onContinueHints}
            className="w-full py-4 text-base font-semibold text-white bg-teal rounded-full hover:bg-teal-dark transition-colors shadow-md min-h-[48px]"
          >
            {hintIdx + 1 < hints.length
              ? "Continue →"
              : "Show the check →"}
          </button>
        </div>
      )}
    </div>
  );
}

// Thin wrapper so the parent can hold onto the typed-text controller
// and finish the animation when the user taps Continue early.
function TypedHint({
  text,
  onRefReady,
}: {
  text: string;
  onRefReady: (ref: { finish: () => void; done: boolean }) => void;
}) {
  const typed = useTypedText(text, 30);
  useEffect(() => {
    onRefReady({ finish: typed.finish, done: typed.done });
  }, [typed.finish, typed.done, onRefReady]);
  return (
    <p className="text-xl sm:text-2xl text-navy leading-relaxed">
      {typed.shown}
      {!typed.done && <span className="inline-block w-[2px] h-5 bg-navy/70 ml-1 animate-pulse align-middle" />}
    </p>
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

  return (
    <div className="max-w-2xl mx-auto px-4 sm:px-6 py-8 space-y-6 text-center">
      <div className="text-[10px] uppercase tracking-[0.2em] font-bold text-teal-dark">You decoded it</div>
      <h2 className="text-2xl sm:text-3xl font-black text-navy leading-tight">
        Now hear/see the whole thing again — this time it&apos;ll make sense.
      </h2>

      {isAudio ? (
        <AudioPanel
          script={(opening as Extract<PreviewLesson["opening"], { kind: "audio" }>).script}
          lang={lang}
        />
      ) : (
        <LessonImage
          src={(opening as Extract<PreviewLesson["opening"], { kind: "image" }>).imageUrl}
          alt={(opening as Extract<PreviewLesson["opening"], { kind: "image" }>).imageAlt}
          city={lesson.city}
          imageSource={(opening as Extract<PreviewLesson["opening"], { kind: "image" }>).imageSource}
        />
      )}

      {!revealed ? (
        <button
          type="button"
          onClick={() => setRevealed(true)}
          className="inline-flex items-center gap-2 px-6 py-3 bg-white border-2 border-teal text-teal-dark text-sm font-semibold rounded-full hover:bg-teal-light transition-colors min-h-[44px]"
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
            className="inline-flex items-center gap-2 px-8 py-3 bg-teal text-white text-sm font-semibold rounded-full hover:bg-teal-dark transition-colors shadow-lg min-h-[44px]"
          >
            Take the quiz →
          </button>
        </div>
      )}
    </div>
  );
}

// ============================================================
// End-of-lesson quiz (now with missed items re-appended)
// ============================================================

function EndQuizQuestionView({
  q,
  lang,
  onAnswered,
  onSkipSpeaking,
}: {
  q: EndQuizQuestion;
  lang: string;
  onAnswered: (r: AnswerResult) => void;
  onSkipSpeaking?: () => void;
}) {
  const [picked, setPicked] = useState<string | null>(null);
  const [value, setValue] = useState("");
  const [answered, setAnswered] = useState<null | AnswerResult>(null);
  const options = useMemo(() => {
    if (q.kind === "multiple_choice" || q.kind === "listening")
      return shuffle([q.correct, ...q.wrong]);
    return [];
  }, [q]);

  function submitOption(opt: string) {
    if (answered) return;
    const ok = opt === (q as { correct: string }).correct;
    setPicked(opt);
    const r = { correct: ok };
    setAnswered(r);
    onAnswered(r);
  }

  function submitFill(e: React.FormEvent) {
    e.preventDefault();
    if (answered || !value.trim()) return;
    const ok = normalize(value) === normalize((q as { correct: string }).correct);
    const r = { correct: ok };
    setAnswered(r);
    onAnswered(r);
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
            else if (answered && picked === opt && !isCorrectOpt) cls = "border-red-300 bg-red-50 text-red-700";
            else if (answered) cls = "border-border bg-white text-navy/40";
            return (
              <button
                key={opt}
                type="button"
                onClick={() => submitOption(opt)}
                disabled={!!answered}
                className={`py-3 px-4 rounded-xl border-2 text-start text-sm font-medium transition-all min-h-[44px] ${cls}`}
              >
                {opt}
              </button>
            );
          })}
        </div>
        {answered && (
          <FeedbackCard
            correct={answered.correct}
            expected={q.correct}
            explanation={q.explanation ?? null}
            onContinue={() => onAnswered({ ...answered, skipped: true })}
          />
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
            else if (answered && picked === opt && !isCorrectOpt) cls = "border-red-300 bg-red-50 text-red-700";
            else if (answered) cls = "border-border bg-white text-navy/40";
            return (
              <button
                key={opt}
                type="button"
                onClick={() => submitOption(opt)}
                disabled={!!answered}
                className={`py-3 px-4 rounded-xl border-2 text-start text-sm font-medium transition-all min-h-[44px] ${cls}`}
              >
                {opt}
              </button>
            );
          })}
        </div>
        {answered && (
          <FeedbackCard
            correct={answered.correct}
            expected={q.correct}
            explanation={q.explanation ?? null}
            onContinue={() => onAnswered({ ...answered, skipped: true })}
          />
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
          disabled={!!answered}
          autoFocus
          placeholder="Type your answer"
          className="w-full px-4 py-3 rounded-xl border-2 bg-white text-navy font-medium text-lg placeholder:text-navy/30 focus:outline-none transition-colors border-border focus:border-teal focus:ring-2 focus:ring-teal/20 disabled:opacity-80"
        />
        {!answered && (
          <button type="submit" disabled={!value.trim()} className="w-full py-2.5 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors disabled:opacity-50 min-h-[44px]">
            Check
          </button>
        )}
        {answered && (
          <FeedbackCard
            correct={answered.correct}
            expected={q.correct}
            explanation={q.explanation ?? null}
            onContinue={() => onAnswered({ ...answered, skipped: true })}
          />
        )}
      </form>
    );
  }

  // speaking — after the mic result (or skip), route through the
  // FeedbackCard, then TranslationCheckView (if present), then
  // finally bubble the result up. Local phase tracker because the
  // EndQuizQuestionView doesn't share GatedExerciseView's state.
  if (q.kind === "speaking") {
    return (
      <SpeakingWithCheck
        q={q}
        lang={lang}
        onDone={(r) => onAnswered(r)}
        onSkipSpeaking={onSkipSpeaking}
      />
    );
  }

  return null;
}

// Wraps a speaking end-quiz question with its mandatory translation
// check follow-up. Mirrors the shape of GatedExerciseView's speaking
// path so behaviour is consistent across decode steps + end quiz.
function SpeakingWithCheck({
  q,
  lang,
  onDone,
  onSkipSpeaking,
}: {
  q: Extract<EndQuizQuestion, { kind: "speaking" }>;
  lang: string;
  onDone: (r: AnswerResult) => void;
  onSkipSpeaking?: () => void;
}) {
  const [primary, setPrimary] = useState<null | AnswerResult>(null);
  const [phase, setPhase] = useState<"ask" | "feedback" | "xcheck">("ask");

  function finishPrimary(r: AnswerResult) {
    setPrimary(r);
    setPhase("feedback");
  }

  // Terminal path for both xcheck + no-xcheck: fire onDone TWICE
  // back-to-back because the parent EndQuizStep uses a two-call
  // protocol (first call commits, second call advances). This
  // mirrors how MCQ/listening/fill render FeedbackCard inline and
  // then fire onAnswered again on Continue.
  function finishAll() {
    if (!primary) return;
    onDone(primary);
    // Second call defers so parent sees the "committed" state flip
    // first before we ask it to advance.
    setTimeout(() => onDone(primary), 0);
  }

  if (phase === "xcheck" && primary && q.translationCheck) {
    return (
      <TranslationCheckView
        check={q.translationCheck}
        phrase={q.expected}
        onDone={() => finishAll()}
      />
    );
  }

  if (phase === "feedback" && primary) {
    return (
      <FeedbackCard
        correct={primary.correct || !!primary.skipped}
        expected={q.expected}
        explanation={q.explanation ?? null}
        onContinue={() => {
          if (q.translationCheck) {
            setPhase("xcheck");
          } else {
            finishAll();
          }
        }}
      />
    );
  }

  return (
    <SpeakingExercise
      ex={q}
      lang={lang}
      onAnswered={finishPrimary}
      onSkip={
        onSkipSpeaking
          ? () => {
              onSkipSpeaking();
              finishPrimary({ correct: true, skipped: true });
            }
          : undefined
      }
    />
  );
}

function EndQuizStep({
  lesson,
  lang,
  missedRefs,
  onFinish,
  onSkipSpeaking,
}: {
  lesson: PreviewLesson;
  lang: string;
  // Step refs the learner missed during the decoding exercises. Any
  // decodeStep[i].gatedExercise matching one of these gets re-asked
  // after the regular endQuiz questions.
  missedRefs: Set<string>;
  onFinish: (score: { correct: number; total: number }) => void;
  onSkipSpeaking?: (ref: string) => void;
}) {
  // Build the full question queue: author-provided endQuiz + any
  // missed decode exercises (converted to quiz questions by re-use).
  const questions = useMemo<
    Array<{ ref: string; q: EndQuizQuestion }>
  >(() => {
    const base: Array<{ ref: string; q: EndQuizQuestion }> = lesson.endQuiz.map(
      (q, i) => ({ ref: `endquiz:${i}`, q }),
    );
    const makeups: Array<{ ref: string; q: EndQuizQuestion }> = [];
    lesson.decodeSteps.forEach((step, i) => {
      const ref = `decode:${i}`;
      if (!missedRefs.has(ref)) return;
      const ex = step.gatedExercise;
      // Convert the decode exercise into the matching EndQuizQuestion
      // shape. The runtime shapes are compatible (the only missing
      // field on decode exercises is `audio` for listening, which
      // doesn't apply here).
      if (ex.kind === "multiple_choice" || ex.kind === "fill_blank" || ex.kind === "speaking") {
        makeups.push({ ref: `makeup:${i}`, q: ex as EndQuizQuestion });
      } else {
        // tap_word has no EndQuizQuestion equivalent; convert it to a
        // multiple_choice question in place.
        makeups.push({
          ref: `makeup:${i}`,
          q: {
            kind: "multiple_choice",
            question: ex.prompt,
            correct: ex.correct,
            wrong: ex.distractors,
            explanation: ex.explanation,
          },
        });
      }
    });
    return [...base, ...makeups];
  }, [lesson.endQuiz, lesson.decodeSteps, missedRefs]);

  const [cursor, setCursor] = useState(0);
  const [correctCount, setCorrectCount] = useState(0);
  const [committed, setCommitted] = useState(false);
  const skippedOnThisQuestionRef = useRef(false);

  useEffect(() => {
    if (typeof window === "undefined") return;
    window.scrollTo({ top: 0, behavior: "smooth" });
  }, [cursor]);

  const total = questions.length;
  const entry = questions[cursor];

  function handleAnswered(r: AnswerResult) {
    // First call records the result + flips `committed` so the
    // Feedback card can render. Second call (from Feedback's
    // Continue) advances to the next question.
    if (!committed) {
      setCommitted(true);
      if (r.correct) setCorrectCount((c) => c + 1);
      skippedOnThisQuestionRef.current = !!r.skipped;
      return;
    }
    advance();
  }

  function advance() {
    const nextIdx = cursor + 1;
    if (nextIdx >= total) {
      onFinish({ correct: correctCount, total });
      return;
    }
    setCursor(nextIdx);
    setCommitted(false);
    skippedOnThisQuestionRef.current = false;
  }

  // Edge case: endQuiz empty AND no misses — finish immediately.
  // Fire from an effect so we don't call onFinish during render.
  useEffect(() => {
    if (!entry) onFinish({ correct: 0, total: 0 });
    // Intentionally only depends on entry — onFinish is stable enough.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [entry]);

  if (!entry) return null;

  return (
    <div className="max-w-2xl mx-auto px-4 sm:px-6 py-6 space-y-5">
      <div className="text-[10px] uppercase tracking-[0.2em] font-bold text-peach-dark text-center">
        Quiz · {cursor + 1} of {total}
        {entry.ref.startsWith("makeup:") && " · make-up"}
      </div>
      <div className="rounded-3xl bg-white border-2 border-border shadow-md p-5 sm:p-6">
        <EndQuizQuestionView
          key={cursor}
          q={entry.q}
          lang={lang}
          onAnswered={handleAnswered}
          onSkipSpeaking={
            onSkipSpeaking ? () => onSkipSpeaking(entry.ref) : undefined
          }
        />
      </div>
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
  const pct = score.total === 0 ? 100 : Math.round((score.correct / score.total) * 100);
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
          ) : null}
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
  // Called when the learner taps "I can't speak now". The parent
  // (route handler for /learn/[language]/travel/[city]/[lesson])
  // writes a row to traveler_skipped_speaking. In preview mode this
  // is a no-op.
  onSkipSpeaking,
}: {
  lesson: PreviewLesson;
  lang: string;
  lessonId?: number;
  markComplete?: (lessonId: number) => Promise<number>;
  exitHref?: string;
  nextLessonHref?: string;
  isPremium?: boolean;
  onSkipSpeaking?: (ref: {
    lessonId: number;
    exerciseRef: string;
    prompt: string;
    expected: string;
    translationCheck?: TranslationCheck | null;
  }) => Promise<void> | void;
}) {
  const [phase, setPhase] = useState<Phase>({ kind: "opening" });
  const [missedRefs, setMissedRefs] = useState<Set<string>>(new Set());
  const isPreview = !lessonId || !markComplete;
  const resolvedExitHref = exitHref ?? "/preview/madrid";

  const phaseKey = phase.kind === "decode" ? `decode:${phase.index}` : phase.kind;
  useEffect(() => {
    if (typeof window === "undefined") return;
    window.scrollTo({ top: 0, behavior: "smooth" });
  }, [phaseKey]);

  const totalSteps = 1 + lesson.decodeSteps.length + 1 + 1;
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

  function reportMiss(ref: string) {
    setMissedRefs((s) => new Set([...s, ref]));
  }

  function skipSpeakingAt(stepIndex: number) {
    const step = lesson.decodeSteps[stepIndex];
    if (!step || step.gatedExercise.kind !== "speaking") return;
    if (onSkipSpeaking && lessonId) {
      onSkipSpeaking({
        lessonId,
        exerciseRef: `decode:${stepIndex}`,
        prompt: step.gatedExercise.prompt,
        expected: step.gatedExercise.expected,
        translationCheck: step.gatedExercise.translationCheck ?? null,
      });
    }
  }

  async function finish(score: { correct: number; total: number }) {
    setPhase({ kind: "complete", score });
    if (!isPreview && lessonId && markComplete) {
      try { await markComplete(lessonId); }
      catch (err) { console.error("markLessonComplete failed:", err); }
    }
  }

  const progressPct = Math.min(100, Math.round((currentStep / totalSteps) * 100));

  // The pinned media region is only meaningful on decode steps (image
  // or audio stays visible while hints + exercise scroll underneath).
  // Opening + buildup + quiz + complete are standalone screens with
  // no pinned media.
  const isDecode = phase.kind === "decode";
  const activeDecodeStep = isDecode ? lesson.decodeSteps[phase.index] : null;
  // Hint cursor relayed up from DecodeStepView so the pinned audio
  // waveform knows when to pulse. Reset on step change via the
  // `decode-{index}` key.
  const [pinnedHintIdx, setPinnedHintIdx] = useState<number | null>(0);
  useEffect(() => {
    setPinnedHintIdx(0);
  }, [phase]);

  return (
    // 100dvh (NOT 100vh) so iOS Safari's collapsing address bar doesn't
    // leave a gap below the content. The flex column stacks the sticky
    // top region above the scrolling content.
    <div
      className="bg-background min-h-[100dvh]"
      style={{
        // Honour iOS/Android safe-area insets at the top so the
        // header never sits under the status bar / notch.
        paddingTop: "env(safe-area-inset-top, 0px)",
      }}
    >
      {/* HEADER — fully opaque, no blur, at the very top. z-50 so
          nothing from the lesson content can show above or behind it. */}
      <header className="sticky top-0 z-50 bg-background border-b border-border">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 py-3 flex items-center gap-4 h-14">
          <Link
            href={resolvedExitHref}
            className="text-xs font-medium text-navy/60 hover:text-navy shrink-0"
          >
            ← {isPreview ? "Exit preview" : "Exit lesson"}
          </Link>
          <div className="flex-1 h-2 rounded-full bg-border overflow-hidden">
            <div
              className="h-full bg-teal transition-all duration-500"
              style={{ width: `${progressPct}%` }}
            />
          </div>
          <p className="text-xs text-navy/60 font-medium tabular-nums shrink-0">
            {phase.kind === "complete" ? "Done" : `${currentStep}/${totalSteps}`}
          </p>
        </div>
      </header>

      {/* PINNED MEDIA — image/audio stays directly below the header on
          every decode step. The sticky `top-14` matches the header's
          `h-14` so there's never a gap or overlap. z-40 = below the
          header, above everything else in the scroll. */}
      {isDecode && activeDecodeStep && (
        <div className="sticky top-14 z-40">
          <PinnedDecodeMedia
            step={activeDecodeStep}
            lesson={lesson}
            lang={lang}
            hintActiveIndex={pinnedHintIdx}
          />
        </div>
      )}

      {/* LESSON-TITLE strip — only shown on the opening + complete
          screens. Hidden on decode steps so the pinned image
          dominates. */}
      {(phase.kind === "opening" || phase.kind === "complete") && (
        <div className="max-w-3xl mx-auto px-4 sm:px-6 pt-6 pb-2 text-center">
          <p className="text-[10px] uppercase tracking-[0.2em] font-bold text-navy/50">
            {lesson.city} · Lesson {lesson.orderIndex}
          </p>
          <h1 className="text-xl sm:text-2xl font-black text-navy mt-1">
            {lesson.title}
          </h1>
        </div>
      )}

      {/* SCROLLING CONTENT. scroll-pt gives focused form elements room
          to clear the sticky header + pinned media. */}
      <div
        className="pb-16"
        style={{
          scrollPaddingTop: isDecode ? "calc(3.5rem + 32vh)" : "3.5rem",
        }}
      >
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
            lesson={lesson}
            lang={lang}
            onContinue={advance}
            onMiss={reportMiss}
            onSkipSpeaking={skipSpeakingAt}
            onHintChange={setPinnedHintIdx}
          />
        )}
        {phase.kind === "buildup" && (
          <BuildupStep lesson={lesson} lang={lang} onContinue={advance} />
        )}
        {phase.kind === "quiz" && (
          <EndQuizStep
            lesson={lesson}
            lang={lang}
            missedRefs={missedRefs}
            onFinish={finish}
            onSkipSpeaking={(ref) => {
              if (!lessonId || !onSkipSpeaking) return;
              const parts = ref.split(":");
              const idx = parseInt(parts[1] ?? "0", 10);
              const q = parts[0] === "endquiz" ? lesson.endQuiz[idx] : null;
              if (q && q.kind === "speaking") {
                onSkipSpeaking({
                  lessonId,
                  exerciseRef: ref,
                  prompt: q.prompt,
                  expected: q.expected,
                  translationCheck: q.translationCheck ?? null,
                });
              }
            }}
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
    </div>
  );
}

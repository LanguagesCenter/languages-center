"use client";

import { useEffect, useMemo, useRef, useState, useTransition } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import type { DbExercise, DbLesson } from "@/lib/learn";
import { SPEECH_LANG_CODES } from "@/lib/speech";
import { completeLesson } from "@/lib/learn-actions";

interface Props {
  languageSlug: string;
  languageName: string;
  lesson: DbLesson;
  exercises: DbExercise[];
  sectionId: number;
}

const ENCOURAGEMENTS_RIGHT = ["Nice!", "Great job!", "You're on fire!", "Brilliant!"];
const ENCOURAGEMENTS_WRONG = [
  "Not quite, keep going!",
  "Close — try again next time.",
  "No worries, learning takes practice.",
];

function shuffle<T>(arr: T[]): T[] {
  const copy = [...arr];
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
}

function normalize(str: string): string {
  return str
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "") // strip diacritics
    .replace(/[^a-z0-9 ]/g, "")
    .trim();
}

// ---------------- TTS hook ----------------
// Tracks whether speechSynthesis is currently speaking so the UI can flip
// play/pause icons accordingly.
function useTts(text: string, lang: string) {
  const [isPlaying, setIsPlaying] = useState(false);
  const supported =
    typeof window !== "undefined" && "speechSynthesis" in window;

  const play = () => {
    if (!supported) return;
    try {
      window.speechSynthesis.cancel();
      const utterance = new SpeechSynthesisUtterance(text);
      utterance.lang = lang;
      utterance.rate = 0.9;
      utterance.onstart = () => setIsPlaying(true);
      utterance.onend = () => setIsPlaying(false);
      utterance.onerror = () => setIsPlaying(false);
      window.speechSynthesis.speak(utterance);
    } catch {
      setIsPlaying(false);
    }
  };

  const stop = () => {
    if (!supported) return;
    try {
      window.speechSynthesis.cancel();
    } catch {
      /* ignore */
    }
    setIsPlaying(false);
  };

  // Cancel any pending speech when the consumer unmounts.
  useEffect(() => {
    return () => {
      if (supported) {
        try {
          window.speechSynthesis.cancel();
        } catch {
          /* ignore */
        }
      }
    };
  }, [supported]);

  return { isPlaying, play, stop, supported };
}

// ---------------- Speech recognition type shim ----------------
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
  results: ArrayLike<{
    0: { transcript: string };
    isFinal: boolean;
    length: number;
  }>;
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

// ---------------- Exercise components ----------------

function MultipleChoice({
  exercise,
  onAnswer,
  disabled,
  pickedAnswer,
}: {
  exercise: DbExercise;
  onAnswer: (answer: string) => void;
  disabled: boolean;
  pickedAnswer: string | null;
}) {
  const options = useMemo(
    () => shuffle([exercise.correct_answer, ...exercise.wrong_answers].filter(Boolean)),
    [exercise.correct_answer, exercise.wrong_answers],
  );
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
      {options.map((opt) => {
        const isPicked = pickedAnswer === opt;
        const isCorrect = opt === exercise.correct_answer;
        let stateCls = "border-border bg-white text-navy hover:border-teal hover:bg-teal-light";
        if (disabled) {
          if (isCorrect) stateCls = "border-teal bg-teal-light text-teal-dark";
          else if (isPicked) stateCls = "border-red-300 bg-red-50 text-red-700";
          else stateCls = "border-border bg-white text-navy/40";
        }
        return (
          <button
            key={opt}
            type="button"
            disabled={disabled}
            onClick={() => onAnswer(opt)}
            className={`w-full py-4 px-5 rounded-xl border-2 text-start font-medium transition-all ${stateCls}`}
          >
            {opt}
          </button>
        );
      })}
    </div>
  );
}

function FillBlank({
  exercise,
  onAnswer,
  disabled,
  pickedAnswer,
}: {
  exercise: DbExercise;
  onAnswer: (answer: string) => void;
  disabled: boolean;
  pickedAnswer: string | null;
}) {
  const [value, setValue] = useState("");
  function submit(e: React.FormEvent) {
    e.preventDefault();
    if (!value.trim() || disabled) return;
    onAnswer(value.trim());
  }
  const showFeedback = disabled && pickedAnswer !== null;
  const wasCorrect =
    showFeedback &&
    normalize(pickedAnswer ?? "") === normalize(exercise.correct_answer);
  return (
    <form onSubmit={submit} className="space-y-4">
      <input
        type="text"
        value={value}
        onChange={(e) => setValue(e.target.value)}
        disabled={disabled}
        autoFocus
        placeholder="Type your answer"
        className={`w-full px-4 py-3.5 rounded-xl border-2 bg-white text-navy text-lg font-medium placeholder:text-navy/30 focus:outline-none transition-colors ${
          showFeedback
            ? wasCorrect
              ? "border-teal bg-teal-light"
              : "border-red-300 bg-red-50"
            : "border-border focus:border-teal focus:ring-2 focus:ring-teal/20"
        }`}
      />
      {showFeedback && !wasCorrect && (
        <p className="text-sm text-navy/70">
          Correct answer:{" "}
          <span className="font-semibold text-teal-dark">{exercise.correct_answer}</span>
        </p>
      )}
      {!disabled && (
        <button
          type="submit"
          disabled={!value.trim()}
          className="w-full py-3 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Check answer
        </button>
      )}
    </form>
  );
}

function Matching({
  exercise,
  onAnswer,
  disabled,
}: {
  exercise: DbExercise;
  onAnswer: (answer: string) => void;
  disabled: boolean;
}) {
  const pairs = useMemo(
    () =>
      exercise.correct_answer.split("|").map((entry) => {
        const [left, right] = entry.split(":");
        return { left: left ?? "", right: right ?? "" };
      }),
    [exercise.correct_answer],
  );
  const rightShuffled = useMemo(() => shuffle(pairs.map((p) => p.right)), [pairs]);
  const [selectedLeft, setSelectedLeft] = useState<string | null>(null);
  const [matches, setMatches] = useState<Record<string, string>>({});
  const [wrongFlash, setWrongFlash] = useState<string | null>(null);

  function pickLeft(left: string) {
    if (disabled || matches[left]) return;
    setSelectedLeft(left);
  }
  function pickRight(right: string) {
    if (disabled || !selectedLeft) return;
    if (Object.values(matches).includes(right)) return;
    const target = pairs.find((p) => p.left === selectedLeft);
    if (target && target.right === right) {
      const next = { ...matches, [selectedLeft]: right };
      setMatches(next);
      setSelectedLeft(null);
      if (Object.keys(next).length === pairs.length) onAnswer("matched");
    } else {
      setWrongFlash(right);
      setTimeout(() => setWrongFlash(null), 500);
      setSelectedLeft(null);
    }
  }

  return (
    <div className="grid grid-cols-2 gap-4">
      <div className="space-y-2">
        {pairs.map((p) => {
          const matched = !!matches[p.left];
          const selected = selectedLeft === p.left;
          return (
            <button
              key={p.left}
              type="button"
              onClick={() => pickLeft(p.left)}
              disabled={matched || disabled}
              className={`w-full py-3 px-4 rounded-xl border-2 font-medium transition-all ${
                matched
                  ? "border-teal bg-teal-light text-teal-dark"
                  : selected
                    ? "border-teal bg-teal text-white"
                    : "border-border bg-white text-navy hover:border-teal/60"
              }`}
            >
              {p.left}
            </button>
          );
        })}
      </div>
      <div className="space-y-2">
        {rightShuffled.map((r) => {
          const used = Object.values(matches).includes(r);
          const flashing = wrongFlash === r;
          return (
            <button
              key={r}
              type="button"
              onClick={() => pickRight(r)}
              disabled={used || disabled}
              className={`w-full py-3 px-4 rounded-xl border-2 font-medium transition-all ${
                used
                  ? "border-teal bg-teal-light text-teal-dark"
                  : flashing
                    ? "border-red-300 bg-red-50 text-red-700"
                    : "border-border bg-white text-navy hover:border-teal/60"
              }`}
            >
              {r}
            </button>
          );
        })}
      </div>
    </div>
  );
}

function ListeningExercise({
  exercise,
  onAnswer,
  disabled,
  pickedAnswer,
  speechLang,
}: {
  exercise: DbExercise;
  onAnswer: (answer: string) => void;
  disabled: boolean;
  pickedAnswer: string | null;
  speechLang: string;
}) {
  const options = useMemo(
    () => shuffle([exercise.correct_answer, ...exercise.wrong_answers].filter(Boolean)),
    [exercise.correct_answer, exercise.wrong_answers],
  );
  const { isPlaying, play, stop, supported: hasTts } = useTts(
    exercise.correct_answer,
    speechLang,
  );

  // Auto-play once on mount when supported
  useEffect(() => {
    if (hasTts) play();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <div className="space-y-5">
      <div className="rounded-2xl border-2 border-teal/30 bg-teal-light/50 p-6 flex items-center gap-4">
        <button
          type="button"
          onClick={() => (isPlaying ? stop() : play())}
          disabled={!hasTts}
          className="flex-shrink-0 w-14 h-14 rounded-full bg-teal text-white flex items-center justify-center shadow-md shadow-teal/30 hover:bg-teal-dark transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          aria-label={isPlaying ? "Pause audio" : "Play audio"}
        >
          {isPlaying ? (
            <svg className="w-7 h-7" fill="currentColor" viewBox="0 0 24 24">
              <path d="M6 5h4v14H6V5zm8 0h4v14h-4V5z" />
            </svg>
          ) : (
            <svg className="w-7 h-7" fill="currentColor" viewBox="0 0 24 24">
              <path d="M8 5v14l11-7z" />
            </svg>
          )}
        </button>
        <div className="flex-1 min-w-0">
          <p className="text-xs font-semibold uppercase tracking-wider text-teal-dark mb-1">
            Listen carefully
          </p>
          <p className="text-sm text-navy/70">
            {hasTts
              ? isPlaying
                ? "Playing… tap to pause."
                : "Tap play to hear the word again, then choose what you heard."
              : "Your browser does not support audio playback for this exercise."}
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        {options.map((opt) => {
          const isPicked = pickedAnswer === opt;
          const isCorrect = opt === exercise.correct_answer;
          let stateCls = "border-border bg-white text-navy hover:border-teal hover:bg-teal-light";
          if (disabled) {
            if (isCorrect) stateCls = "border-teal bg-teal-light text-teal-dark";
            else if (isPicked) stateCls = "border-red-300 bg-red-50 text-red-700";
            else stateCls = "border-border bg-white text-navy/40";
          }
          return (
            <button
              key={opt}
              type="button"
              disabled={disabled}
              onClick={() => onAnswer(opt)}
              className={`w-full py-4 px-5 rounded-xl border-2 text-start font-medium transition-all ${stateCls}`}
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
  exercise,
  onAnswer,
  disabled,
  speechLang,
}: {
  exercise: DbExercise;
  onAnswer: (answer: string) => void;
  disabled: boolean;
  speechLang: string;
}) {
  const [transcript, setTranscript] = useState("");
  const [listening, setListening] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const recRef = useRef<ISpeechRecognition | null>(null);

  const SpeechRec = getSpeechRecognition();
  const supported = SpeechRec !== null;

  function start() {
    if (!SpeechRec || disabled) return;
    setError(null);
    setTranscript("");
    const rec = new SpeechRec();
    rec.lang = speechLang;
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
      setError(ev.error === "not-allowed" ? "Microphone access blocked." : `Speech error: ${ev.error}`);
      setListening(false);
    };
    rec.onend = () => {
      setListening(false);
    };
    recRef.current = rec;
    setListening(true);
    rec.start();
  }

  function stop() {
    recRef.current?.stop();
    setListening(false);
  }

  function submit() {
    if (!transcript.trim() || disabled) return;
    onAnswer(transcript.trim());
  }

  return (
    <div className="space-y-5">
      <div className="rounded-2xl border-2 border-peach-dark/40 bg-peach-light p-6 flex items-center gap-4">
        <div className="flex-shrink-0 w-12 h-12 rounded-full bg-amber-100 text-amber-700 flex items-center justify-center">
          <svg className="w-6 h-6" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" d="M12 18.75a6 6 0 0 0 6-6v-1.5m-6 7.5a6 6 0 0 1-6-6v-1.5m6 7.5v3.75m-3.75 0h7.5M12 15.75a3 3 0 0 1-3-3V4.5a3 3 0 1 1 6 0v8.25a3 3 0 0 1-3 3Z" />
          </svg>
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-xs font-semibold uppercase tracking-wider text-amber-800 mb-1">
            Say it out loud
          </p>
          <p className="text-lg font-semibold text-navy">
            {exercise.correct_answer}
          </p>
          {exercise.translation && (
            <p className="text-xs text-navy/50 mt-0.5">{exercise.translation}</p>
          )}
        </div>
      </div>

      <div className="rounded-2xl border-2 border-border bg-white p-5 min-h-[100px]">
        <p className="text-xs font-semibold uppercase tracking-wider text-navy/50 mb-2">
          What we heard
        </p>
        <p className="text-base text-navy min-h-[1.5rem]">
          {transcript || (listening ? "Listening…" : <span className="text-navy/30">Press the mic and speak.</span>)}
        </p>
      </div>

      {error && (
        <div className="text-sm text-red-600 bg-red-50 border border-red-200 rounded-xl px-3.5 py-2.5">
          {error}
        </div>
      )}

      {!supported && (
        <div className="text-sm text-amber-800 bg-amber-50 border border-amber-200 rounded-xl px-3.5 py-2.5">
          Your browser does not support speech recognition. Try Chrome, Edge, or Safari to practice speaking — or skip
          this exercise.
        </div>
      )}

      <div className="flex flex-col sm:flex-row gap-3">
        {listening ? (
          <button
            type="button"
            onClick={stop}
            disabled={disabled}
            className="flex-1 py-3 text-sm font-semibold text-white bg-red-500 rounded-xl hover:bg-red-600 transition-colors disabled:opacity-50"
          >
            Stop recording
          </button>
        ) : (
          <button
            type="button"
            onClick={start}
            disabled={disabled || !supported}
            className="flex-1 py-3 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {transcript ? "Try again" : "Start recording"}
          </button>
        )}
        <button
          type="button"
          onClick={submit}
          disabled={disabled || !transcript.trim()}
          className="flex-1 py-3 text-sm font-semibold text-teal-dark bg-teal-light border border-teal/40 rounded-xl hover:bg-teal-light/70 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {supported ? "Submit" : "Skip (no mic)"}
        </button>
      </div>
    </div>
  );
}

// ---------------- Main component ----------------

type TeachingPhase = "intro" | "vocab" | "dialogue" | "grammar" | "exercises";

function TeachingCard({
  languageSlug,
  speechLang,
  phase,
  setPhase,
  lesson,
  hasExercises,
  onStartExercises,
}: {
  languageSlug: string;
  speechLang: string;
  phase: TeachingPhase;
  setPhase: (p: TeachingPhase) => void;
  lesson: DbLesson;
  hasExercises: boolean;
  onStartExercises: () => void;
}) {
  const hasVocab = (lesson.vocab_items?.length ?? 0) > 0;
  const hasDialogue = (lesson.dialogue?.length ?? 0) > 0;
  const hasGrammar = !!lesson.grammar_note?.trim();

  const phasesInOrder: TeachingPhase[] = ["intro"];
  if (hasVocab) phasesInOrder.push("vocab");
  if (hasDialogue) phasesInOrder.push("dialogue");
  if (hasGrammar) phasesInOrder.push("grammar");

  const idx = phasesInOrder.indexOf(phase);
  const isLastPhase = idx === phasesInOrder.length - 1;

  function next() {
    if (isLastPhase) {
      if (hasExercises) onStartExercises();
      else setPhase("exercises"); // shows the empty-state below
      return;
    }
    setPhase(phasesInOrder[idx + 1]);
  }

  function speak(text: string) {
    if (typeof window === "undefined" || !("speechSynthesis" in window)) return;
    window.speechSynthesis.cancel();
    const u = new SpeechSynthesisUtterance(text);
    u.lang = speechLang;
    u.rate = 0.85;
    window.speechSynthesis.speak(u);
  }

  return (
    <main className="min-h-screen bg-background px-4 py-10">
      <div className="max-w-3xl mx-auto">
        <div className="flex items-center justify-between mb-6 text-xs text-navy/50">
          <Link href={`/learn/${languageSlug}`} className="hover:text-teal transition-colors">
            ← Back to course
          </Link>
          <span>
            Step {idx + 1} of {phasesInOrder.length + (hasExercises ? 1 : 0)}
          </span>
        </div>

        <div className="bg-white border border-border rounded-2xl p-8 shadow-sm">
          {phase === "intro" && (
            <>
              <p className="text-xs font-semibold text-teal-dark uppercase tracking-wider mb-3">
                Introduction
              </p>
              <h1 className="text-2xl font-bold text-navy mb-4">{lesson.title}</h1>
              <p className="text-base text-navy/80 leading-relaxed">
                {lesson.intro ?? lesson.description}
              </p>
            </>
          )}

          {phase === "vocab" && hasVocab && (
            <>
              <p className="text-xs font-semibold text-teal-dark uppercase tracking-wider mb-3">
                Vocabulary
              </p>
              <h2 className="text-xl font-bold text-navy mb-5">Learn these words</h2>
              <div className="space-y-3">
                {lesson.vocab_items!.map((v, i) => (
                  <div key={i} className="border border-border rounded-xl p-4">
                    <div className="flex items-start justify-between gap-3 mb-1">
                      <div>
                        <div className="text-2xl font-bold text-navy">{v.word}</div>
                        <div className="text-xs text-navy/50 mt-0.5">{v.phonetic}</div>
                      </div>
                      <button
                        type="button"
                        onClick={() => speak(v.word)}
                        className="shrink-0 p-2 rounded-full bg-teal-light hover:bg-teal hover:text-white transition-colors text-teal-dark"
                        aria-label={`Play ${v.word}`}
                      >
                        <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                          <path d="M8 5v14l11-7z" />
                        </svg>
                      </button>
                    </div>
                    <div className="text-sm font-medium text-navy/70 mb-2">{v.english}</div>
                    <div className="text-sm text-navy/60 italic">
                      <span className="text-navy/80">{v.example_es}</span>
                      <span className="text-navy/40"> — {v.example_en}</span>
                    </div>
                  </div>
                ))}
              </div>
            </>
          )}

          {phase === "dialogue" && hasDialogue && (
            <>
              <p className="text-xs font-semibold text-teal-dark uppercase tracking-wider mb-3">
                Dialogue
              </p>
              <div className="flex items-center justify-between mb-5">
                <h2 className="text-xl font-bold text-navy">In context</h2>
                <button
                  type="button"
                  onClick={() =>
                    speak(lesson.dialogue!.map((d) => d.spanish).join(". "))
                  }
                  className="inline-flex items-center gap-2 px-3 py-1.5 text-xs font-semibold rounded-full bg-teal-light text-teal-dark hover:bg-teal hover:text-white transition-colors"
                >
                  <svg className="w-3 h-3" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M8 5v14l11-7z" />
                  </svg>
                  Listen to full dialogue
                </button>
              </div>
              <div className="space-y-3">
                {lesson.dialogue!.map((d, i) => (
                  <div key={i} className="grid grid-cols-[auto_1fr_1fr] gap-3 items-start text-sm">
                    <button
                      type="button"
                      onClick={() => speak(d.spanish)}
                      className="mt-0.5 p-1.5 rounded-full bg-teal-light hover:bg-teal hover:text-white transition-colors text-teal-dark"
                      aria-label={`Play line ${i + 1}`}
                    >
                      <svg className="w-3 h-3" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M8 5v14l11-7z" />
                      </svg>
                    </button>
                    <div>
                      {d.speaker && (
                        <div className="text-xs font-semibold text-navy/40 uppercase tracking-wide mb-0.5">
                          {d.speaker}
                        </div>
                      )}
                      <div className="text-navy">{d.spanish}</div>
                    </div>
                    <div className="text-navy/50 italic pt-4">{d.english}</div>
                  </div>
                ))}
              </div>
            </>
          )}

          {phase === "grammar" && hasGrammar && (
            <>
              <p className="text-xs font-semibold text-teal-dark uppercase tracking-wider mb-3">
                Grammar note
              </p>
              <h2 className="text-xl font-bold text-navy mb-4">Quick rule</h2>
              <div className="bg-peach-light border border-peach rounded-xl p-5">
                <p className="text-sm text-navy/80 leading-relaxed">{lesson.grammar_note}</p>
              </div>
            </>
          )}

          <div className="mt-8 flex items-center justify-between">
            <button
              type="button"
              onClick={() => {
                if (idx === 0) return;
                setPhase(phasesInOrder[idx - 1]);
              }}
              disabled={idx === 0}
              className="text-sm font-medium text-navy/60 hover:text-navy disabled:opacity-30 disabled:cursor-not-allowed"
            >
              ← Back
            </button>
            <button
              type="button"
              onClick={next}
              className="px-6 py-2.5 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors"
            >
              {isLastPhase ? (hasExercises ? "Start exercises →" : "Done") : "Next →"}
            </button>
          </div>
        </div>
      </div>
    </main>
  );
}

export default function LessonClient({
  languageSlug,
  languageName,
  lesson,
  exercises,
  sectionId,
}: Props) {
  const router = useRouter();
  const speechLang = SPEECH_LANG_CODES[languageSlug] ?? "en-US";
  const [pending, startTransition] = useTransition();
  const [phase, setPhase] = useState<TeachingPhase>("intro");
  const [step, setStep] = useState(0);
  const [pickedAnswer, setPickedAnswer] = useState<string | null>(null);
  const [showFeedback, setShowFeedback] = useState(false);
  const [wasCorrect, setWasCorrect] = useState(false);
  const [completion, setCompletion] = useState<{
    xp_earned: number;
    already_completed: boolean;
    current_streak?: number;
    saved: boolean;
    not_authenticated?: boolean;
    error?: string;
  } | null>(null);

  const sectionUrl = `/learn/${languageSlug}/sections/${sectionId}`;

  // Auto-redirect ONLY when the save actually succeeded. On error the user
  // stays on the completion card so they can read the message and retry —
  // we never silently navigate away from unsaved progress.
  useEffect(() => {
    if (!completion || !completion.saved) return;
    const t = setTimeout(() => {
      router.push(sectionUrl);
      router.refresh();
    }, 2500);
    return () => clearTimeout(t);
  }, [completion, router, sectionUrl]);

  // Stop any in-flight TTS when navigating between exercises
  useEffect(() => {
    return () => {
      if (typeof window !== "undefined" && "speechSynthesis" in window) {
        window.speechSynthesis.cancel();
      }
    };
  }, [step]);

  const hasTeaching =
    !!lesson.intro?.trim() ||
    (lesson.vocab_items?.length ?? 0) > 0 ||
    (lesson.dialogue?.length ?? 0) > 0 ||
    !!lesson.grammar_note?.trim();

  if (phase !== "exercises" && hasTeaching) {
    return (
      <TeachingCard
        languageSlug={languageSlug}
        speechLang={speechLang}
        phase={phase}
        setPhase={setPhase}
        lesson={lesson}
        hasExercises={exercises.length > 0}
        onStartExercises={() => setPhase("exercises")}
      />
    );
  }

  if (exercises.length === 0) {
    return (
      <main className="min-h-screen bg-background flex items-center justify-center p-6">
        <div className="bg-white rounded-2xl border border-border p-8 text-center max-w-md">
          <h1 className="text-xl font-bold text-navy mb-2">No exercises yet</h1>
          <p className="text-sm text-navy/60 mb-6">
            This lesson is still being prepared. Check back soon!
          </p>
          <Link
            href={`/learn/${languageSlug}`}
            className="inline-block px-5 py-2.5 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors"
          >
            Back to course
          </Link>
        </div>
      </main>
    );
  }

  const exercise = exercises[step];
  const isLast = step === exercises.length - 1;
  const xpPerExercise = Math.max(1, Math.floor(lesson.xp_reward / exercises.length));
  const progressPct = ((step + (showFeedback ? 1 : 0)) / exercises.length) * 100;

  function handleAnswer(answer: string) {
    if (showFeedback) return;
    let correct = false;
    if (exercise.type === "matching") {
      correct = true; // matching only fires when fully matched
    } else if (exercise.type === "speaking") {
      // Fuzzy match: normalize both sides and check if any one is contained in the other
      const target = normalize(exercise.correct_answer);
      const heard = normalize(answer);
      correct =
        target.length > 0 &&
        (heard === target || heard.includes(target) || target.includes(heard));
    } else {
      correct =
        normalize(answer) === normalize(exercise.correct_answer);
    }
    setPickedAnswer(answer);
    setWasCorrect(correct);
    setShowFeedback(true);
  }

  function handleContinue() {
    if (!isLast) {
      setStep((s) => s + 1);
      setPickedAnswer(null);
      setShowFeedback(false);
      setWasCorrect(false);
      return;
    }
    startTransition(async () => {
      try {
        const result = await completeLesson(lesson.id, languageSlug);
        // Always set completion so the user is never stranded — even if the
        // save failed, we show a clear message and only auto-redirect on
        // success.
        setCompletion({
          xp_earned: result.ok ? result.xp_earned : 0,
          already_completed: result.ok ? result.already_completed : false,
          current_streak: result.ok ? result.current_streak : undefined,
          saved: result.ok,
          not_authenticated: result.not_authenticated,
          error: result.ok ? undefined : (result.error ?? "Could not save progress"),
        });
      } catch (err) {
        setCompletion({
          xp_earned: 0,
          already_completed: false,
          saved: false,
          error: err instanceof Error ? err.message : "Unexpected error",
        });
      }
    });
  }

  if (completion) {
    const headerBgClass = completion.saved
      ? "from-teal to-teal-dark"
      : completion.not_authenticated
        ? "from-amber-400 to-amber-600"
        : "from-red-400 to-red-600";

    return (
      <main className="min-h-screen bg-gradient-to-b from-teal-light to-background flex items-center justify-center p-6">
        <div className="bg-white rounded-3xl border border-border p-8 sm:p-12 text-center max-w-md w-full shadow-xl">
          <div className={`w-20 h-20 mx-auto mb-6 rounded-full bg-gradient-to-br ${headerBgClass} flex items-center justify-center shadow-lg`}>
            <svg className="w-12 h-12 text-white" fill="none" stroke="currentColor" strokeWidth={3} viewBox="0 0 24 24">
              {completion.saved ? (
                <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
              ) : (
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v3.75m0 3.75h.008v.008H12v-.008zM2.25 12a9.75 9.75 0 1119.5 0 9.75 9.75 0 01-19.5 0z" />
              )}
            </svg>
          </div>

          {completion.saved ? (
            <>
              <h1 className="text-3xl font-bold text-navy mb-2">Lesson complete!</h1>
              <p className="text-sm text-navy/60 mb-6">
                {completion.already_completed
                  ? "You've already mastered this lesson — practice never hurts."
                  : `Great work on ${lesson.title} in ${languageName}.`}
              </p>

              <div className="grid grid-cols-2 gap-3 mb-8">
                <div className="bg-teal-light rounded-2xl p-4">
                  <p className="text-xs text-teal-dark font-semibold uppercase tracking-wide mb-1">
                    XP earned
                  </p>
                  <p className="text-2xl font-bold text-teal-dark">
                    {completion.already_completed ? 0 : completion.xp_earned}
                  </p>
                </div>
                <div className="bg-peach-light rounded-2xl p-4">
                  <p className="text-xs text-amber-700 font-semibold uppercase tracking-wide mb-1">
                    Streak
                  </p>
                  <p className="text-2xl font-bold text-amber-700">
                    🔥 {completion.current_streak ?? 0}
                  </p>
                </div>
              </div>

              <p className="text-xs text-navy/40 mb-3">Taking you back to the section…</p>
              <div className="flex flex-col gap-2">
                <Link
                  href={sectionUrl}
                  className="block py-3 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors"
                >
                  Back to the section
                </Link>
                <Link
                  href="/dashboard"
                  className="block py-3 text-sm font-medium text-navy/60 hover:text-teal transition-colors"
                >
                  View dashboard
                </Link>
              </div>
            </>
          ) : completion.not_authenticated ? (
            <>
              <h1 className="text-2xl font-bold text-navy mb-2">Sign in to save progress</h1>
              <p className="text-sm text-navy/60 mb-6">
                You completed {lesson.title}, but you need to be signed in for the XP and
                streak to stick.
              </p>
              <div className="flex flex-col gap-2">
                <Link
                  href={`/login?next=/learn/${languageSlug}/${lesson.id}`}
                  className="block py-3 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors"
                >
                  Sign in
                </Link>
                <button
                  type="button"
                  onClick={() => setCompletion(null)}
                  className="block py-3 text-sm font-medium text-navy/60 hover:text-teal transition-colors"
                >
                  Back to the lesson
                </button>
              </div>
            </>
          ) : (
            <>
              <h1 className="text-2xl font-bold text-navy mb-2">Couldn&apos;t save progress</h1>
              <p className="text-sm text-navy/60 mb-3">
                Your lesson was completed, but the save to Supabase failed.
              </p>
              {completion.error && (
                <p className="text-xs text-red-700 bg-red-50 border border-red-200 rounded-xl px-3 py-2 mb-6 text-start">
                  {completion.error}
                </p>
              )}
              <div className="flex flex-col gap-2">
                <button
                  type="button"
                  onClick={handleContinue}
                  disabled={pending}
                  className="block py-3 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors disabled:opacity-50"
                >
                  {pending ? "Retrying…" : "Try again"}
                </button>
                <Link
                  href={sectionUrl}
                  className="block py-3 text-sm font-medium text-navy/60 hover:text-teal transition-colors"
                >
                  Skip and return to the section
                </Link>
              </div>
            </>
          )}
        </div>
      </main>
    );
  }

  const encouragement = wasCorrect
    ? ENCOURAGEMENTS_RIGHT[step % ENCOURAGEMENTS_RIGHT.length]
    : ENCOURAGEMENTS_WRONG[step % ENCOURAGEMENTS_WRONG.length];

  return (
    <main className="min-h-screen bg-background flex flex-col">
      <header className="border-b border-border bg-white/60 backdrop-blur sticky top-0 z-10">
        <div className="max-w-2xl mx-auto px-4 sm:px-6 py-4 flex items-center gap-4">
          <Link
            href={`/learn/${languageSlug}`}
            aria-label="Quit lesson"
            className="text-navy/40 hover:text-navy/70 transition-colors"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </Link>
          <div className="flex-1 h-3 bg-navy/5 rounded-full overflow-hidden">
            <div
              className="h-full bg-gradient-to-r from-teal to-teal-dark rounded-full transition-all duration-300"
              style={{ width: `${progressPct}%` }}
            />
          </div>
          <span className="text-xs font-semibold text-navy/60 tabular-nums">
            {step + 1} / {exercises.length}
          </span>
        </div>
      </header>

      <section className="flex-1 max-w-2xl mx-auto w-full px-4 sm:px-6 py-10">
        <p className="text-xs font-semibold uppercase tracking-wider text-teal-dark mb-2">
          {exercise.type.replace("_", " ")}
        </p>
        <h1 className="text-2xl sm:text-3xl font-bold text-navy mb-2 leading-snug">
          {exercise.question}
        </h1>
        {exercise.translation && exercise.type !== "speaking" && (
          <p className="text-sm text-navy/50 mb-8">{exercise.translation}</p>
        )}
        <div className="mt-8">
          {exercise.type === "multiple_choice" && (
            <MultipleChoice
              exercise={exercise}
              onAnswer={handleAnswer}
              disabled={showFeedback}
              pickedAnswer={pickedAnswer}
            />
          )}
          {exercise.type === "fill_blank" && (
            <FillBlank
              exercise={exercise}
              onAnswer={handleAnswer}
              disabled={showFeedback}
              pickedAnswer={pickedAnswer}
            />
          )}
          {exercise.type === "matching" && (
            <Matching exercise={exercise} onAnswer={handleAnswer} disabled={showFeedback} />
          )}
          {exercise.type === "listening" && (
            <ListeningExercise
              exercise={exercise}
              onAnswer={handleAnswer}
              disabled={showFeedback}
              pickedAnswer={pickedAnswer}
              speechLang={speechLang}
            />
          )}
          {exercise.type === "speaking" && (
            <SpeakingExercise
              exercise={exercise}
              onAnswer={handleAnswer}
              disabled={showFeedback}
              speechLang={speechLang}
            />
          )}
        </div>
      </section>

      {showFeedback && (
        <footer
          className={`border-t-2 px-4 sm:px-6 py-6 ${
            wasCorrect ? "bg-teal-light border-teal/30" : "bg-red-50 border-red-200"
          }`}
        >
          <div className="max-w-2xl mx-auto flex flex-col sm:flex-row sm:items-center justify-between gap-4">
            <div>
              <p className={`text-lg font-bold ${wasCorrect ? "text-teal-dark" : "text-red-700"}`}>
                {encouragement}
              </p>
              {wasCorrect ? (
                <p className="text-sm text-teal-dark/80">+{xpPerExercise} XP</p>
              ) : (
                <p className="text-sm text-red-700/80">No XP this time</p>
              )}
            </div>
            <button
              type="button"
              onClick={handleContinue}
              disabled={pending}
              className={`px-8 py-3 text-sm font-semibold text-white rounded-xl transition-colors disabled:opacity-50 disabled:cursor-not-allowed ${
                wasCorrect ? "bg-teal hover:bg-teal-dark" : "bg-red-500 hover:bg-red-600"
              }`}
            >
              {pending ? "Saving..." : isLast ? "Finish lesson" : "Continue"}
            </button>
          </div>
        </footer>
      )}
    </main>
  );
}

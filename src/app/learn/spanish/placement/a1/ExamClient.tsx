"use client";

import { useEffect, useRef, useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import {
  EXAM_DURATION_SECONDS,
  type PlacementQuestion,
} from "@/lib/placement-exam";
import { submitPlacementExam, type ExamAnswer } from "@/lib/placement-exam-actions";

function formatTime(seconds: number): string {
  const m = Math.floor(seconds / 60);
  const s = seconds % 60;
  return `${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`;
}

function pickSpanishVoice(): SpeechSynthesisVoice | null {
  if (typeof window === "undefined" || !("speechSynthesis" in window)) return null;
  const voices = window.speechSynthesis.getVoices();
  return (
    voices.find((v) => v.lang.toLowerCase() === "es-es") ??
    voices.find((v) => v.lang.toLowerCase() === "es-mx") ??
    voices.find((v) => v.lang.toLowerCase().startsWith("es-")) ??
    voices.find((v) => v.lang.toLowerCase().startsWith("es")) ??
    null
  );
}

function speak(text: string) {
  if (typeof window === "undefined" || !("speechSynthesis" in window)) return;
  window.speechSynthesis.cancel();
  const u = new SpeechSynthesisUtterance(text);
  u.lang = "es-ES";
  const voice = pickSpanishVoice();
  if (voice) u.voice = voice;
  u.rate = 0.9;
  window.speechSynthesis.speak(u);
}

// Speech recognition type shim (same shape as LessonClient).
interface ISpeechRecognition extends EventTarget {
  lang: string;
  interimResults: boolean;
  continuous: boolean;
  onresult:
    | ((this: ISpeechRecognition, ev: { results: ArrayLike<{ 0: { transcript: string }; isFinal: boolean }> }) => void)
    | null;
  onerror: ((this: ISpeechRecognition, ev: { error: string }) => void) | null;
  onend: ((this: ISpeechRecognition, ev: Event) => void) | null;
  start: () => void;
  stop: () => void;
}
function getSpeechRecognition(): (new () => ISpeechRecognition) | null {
  if (typeof window === "undefined") return null;
  const w = window as unknown as {
    SpeechRecognition?: new () => ISpeechRecognition;
    webkitSpeechRecognition?: new () => ISpeechRecognition;
  };
  return w.SpeechRecognition ?? w.webkitSpeechRecognition ?? null;
}

export default function ExamClient({
  languageSlug,
  level,
  questions,
}: {
  languageSlug: string;
  level: string;
  questions: PlacementQuestion[];
}) {
  const router = useRouter();
  const [step, setStep] = useState(0);
  const [answers, setAnswers] = useState<Record<number, string>>({});
  const [remaining, setRemaining] = useState(EXAM_DURATION_SECONDS);
  const startedAt = useRef<number>(Date.now());
  const [pending, startTransition] = useTransition();
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Prime TTS voices once.
  useEffect(() => {
    if (typeof window !== "undefined" && "speechSynthesis" in window) {
      window.speechSynthesis.getVoices();
      const handler = () => window.speechSynthesis.getVoices();
      window.speechSynthesis.addEventListener?.("voiceschanged", handler);
      return () => {
        window.speechSynthesis.removeEventListener?.("voiceschanged", handler);
      };
    }
  }, []);

  // Countdown timer.
  useEffect(() => {
    if (submitted) return;
    const t = setInterval(() => {
      setRemaining((r) => {
        if (r <= 1) {
          clearInterval(t);
          handleSubmit(true);
          return 0;
        }
        return r - 1;
      });
    }, 1000);
    return () => clearInterval(t);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [submitted]);

  function setAnswer(questionId: number, value: string) {
    setAnswers((prev) => ({ ...prev, [questionId]: value }));
  }

  function handleSubmit(_isAutoSubmit: boolean) {
    if (submitted) return;
    setSubmitted(true);
    const elapsed = Math.round((Date.now() - startedAt.current) / 1000);
    const payload: ExamAnswer[] = questions.map((q) => ({
      question_id: q.id,
      answer: answers[q.id] ?? "",
    }));
    startTransition(async () => {
      const res = await submitPlacementExam(languageSlug, level, payload, elapsed);
      if (!res.ok) {
        setError(res.error ?? "Could not submit exam");
        setSubmitted(false);
        return;
      }
      router.refresh();
    });
  }

  const q = questions[step];
  const total = questions.length;
  const answered = Object.keys(answers).length;

  if (!q) {
    return (
      <section className="max-w-2xl mx-auto px-4 py-10 text-center">
        <p className="text-sm text-navy/60">No questions available for this exam yet.</p>
      </section>
    );
  }

  return (
    <section className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="flex items-center justify-between mb-5">
        <div>
          <p className="text-xs font-semibold text-teal-dark uppercase tracking-wider">
            Spanish {level} Placement Exam
          </p>
          <p className="text-sm text-navy/60">
            Question {step + 1} of {total} · {answered}/{total} answered
          </p>
        </div>
        <div
          className={`text-2xl font-bold tabular-nums ${
            remaining <= 60 ? "text-red-600" : "text-navy"
          }`}
        >
          ⏱ {formatTime(remaining)}
        </div>
      </div>

      {/* Progress bar */}
      <div className="h-1.5 w-full rounded-full bg-navy/5 overflow-hidden mb-6">
        <div
          className="h-full rounded-full bg-gradient-to-r from-teal to-teal-dark transition-all"
          style={{ width: `${((step + 1) / total) * 100}%` }}
        />
      </div>

      {/* Question */}
      <div className="bg-white border border-border rounded-2xl p-6 sm:p-8 mb-6 shadow-sm">
        <p className="text-xs font-semibold text-navy/40 uppercase tracking-wider mb-2">
          {q.category}
        </p>

        {q.category === "listening" ? (
          <ListeningQuestion
            spanish={q.question}
            options={q.options ?? []}
            value={answers[q.id] ?? ""}
            onChange={(v) => setAnswer(q.id, v)}
          />
        ) : q.category === "vocabulary" ? (
          <McQuestion
            prompt={q.question}
            options={q.options ?? []}
            value={answers[q.id] ?? ""}
            onChange={(v) => setAnswer(q.id, v)}
          />
        ) : q.category === "speaking" ? (
          <SpeakingQuestion
            prompt={q.question}
            value={answers[q.id] ?? ""}
            onChange={(v) => setAnswer(q.id, v)}
          />
        ) : (
          <WritingQuestion
            prompt={q.question}
            value={answers[q.id] ?? ""}
            onChange={(v) => setAnswer(q.id, v)}
          />
        )}

        {q.hint && (
          <p className="mt-3 text-xs text-navy/40 italic">Hint: {q.hint}</p>
        )}
      </div>

      {error && (
        <div className="mb-4 text-sm text-red-600 bg-red-50 border border-red-200 rounded-xl px-4 py-3">
          {error}
        </div>
      )}

      {/* Footer nav */}
      <div className="flex items-center justify-between">
        <button
          type="button"
          onClick={() => setStep((s) => Math.max(0, s - 1))}
          disabled={step === 0}
          className="px-4 py-2.5 text-sm font-medium text-navy/60 hover:text-navy disabled:opacity-30 disabled:cursor-not-allowed"
        >
          ← Previous
        </button>

        {step < total - 1 ? (
          <button
            type="button"
            onClick={() => setStep((s) => Math.min(total - 1, s + 1))}
            className="px-6 py-2.5 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors"
          >
            Next →
          </button>
        ) : (
          <button
            type="button"
            onClick={() => handleSubmit(false)}
            disabled={pending || submitted}
            className="px-6 py-2.5 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors disabled:opacity-50"
          >
            {submitted ? "Submitting…" : "Submit exam"}
          </button>
        )}
      </div>
    </section>
  );
}

function McQuestion({
  prompt,
  options,
  value,
  onChange,
}: {
  prompt: string;
  options: string[];
  value: string;
  onChange: (v: string) => void;
}) {
  return (
    <>
      <h2 className="text-lg sm:text-xl font-bold text-navy mb-4">{prompt}</h2>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
        {options.map((opt) => (
          <button
            key={opt}
            type="button"
            onClick={() => onChange(opt)}
            className={`text-start px-4 py-3 rounded-xl border-2 transition-colors text-navy ${
              value === opt
                ? "border-teal bg-teal-light"
                : "border-border bg-white hover:border-teal/40"
            }`}
          >
            {opt}
          </button>
        ))}
      </div>
    </>
  );
}

function ListeningQuestion({
  spanish,
  options,
  value,
  onChange,
}: {
  spanish: string;
  options: string[];
  value: string;
  onChange: (v: string) => void;
}) {
  return (
    <>
      <h2 className="text-lg sm:text-xl font-bold text-navy mb-2">
        Listen and pick the English meaning.
      </h2>
      <button
        type="button"
        onClick={() => speak(spanish)}
        className="inline-flex items-center gap-2 px-4 py-2 mb-4 text-sm font-semibold rounded-full bg-teal-light text-teal-dark hover:bg-teal hover:text-white transition-colors"
      >
        <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
          <path d="M8 5v14l11-7z" />
        </svg>
        Play audio
      </button>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
        {options.map((opt) => (
          <button
            key={opt}
            type="button"
            onClick={() => onChange(opt)}
            className={`text-start px-4 py-3 rounded-xl border-2 transition-colors text-navy ${
              value === opt
                ? "border-teal bg-teal-light"
                : "border-border bg-white hover:border-teal/40"
            }`}
          >
            {opt}
          </button>
        ))}
      </div>
    </>
  );
}

function SpeakingQuestion({
  prompt,
  value,
  onChange,
}: {
  prompt: string;
  value: string;
  onChange: (v: string) => void;
}) {
  const [listening, setListening] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const recRef = useRef<ISpeechRecognition | null>(null);

  function toggle() {
    setError(null);
    if (listening) {
      recRef.current?.stop();
      setListening(false);
      return;
    }
    const Ctor = getSpeechRecognition();
    if (!Ctor) {
      setError(
        "Speech recognition is not available in this browser. Type your answer below to mark it.",
      );
      return;
    }
    const rec = new Ctor();
    rec.lang = "es-ES";
    rec.interimResults = false;
    rec.continuous = false;
    rec.onresult = (e) => {
      const text = e.results[0]?.[0]?.transcript ?? "";
      if (text) onChange(text);
    };
    rec.onerror = (e) => {
      setError(`Microphone error: ${e.error}`);
    };
    rec.onend = () => setListening(false);
    recRef.current = rec;
    try {
      rec.start();
      setListening(true);
    } catch {
      setError("Could not start the microphone.");
    }
  }

  return (
    <>
      <h2 className="text-lg sm:text-xl font-bold text-navy mb-4">{prompt}</h2>
      <div className="flex flex-col sm:flex-row gap-3 items-stretch">
        <button
          type="button"
          onClick={toggle}
          className={`flex-1 py-3 text-sm font-semibold rounded-xl transition-colors ${
            listening
              ? "bg-red-600 text-white hover:bg-red-700"
              : "bg-teal text-white hover:bg-teal-dark"
          }`}
        >
          {listening ? "Stop recording" : "🎤 Start recording"}
        </button>
        <input
          type="text"
          value={value}
          onChange={(e) => onChange(e.target.value)}
          placeholder="Or type the phrase here"
          className="flex-1 px-4 py-3 rounded-xl border-2 border-border bg-white text-navy text-sm focus:border-teal focus:outline-none"
        />
      </div>
      {error && <p className="mt-3 text-xs text-red-600">{error}</p>}
      {value && (
        <p className="mt-3 text-xs text-navy/60">
          Captured: <span className="font-semibold text-navy">{value}</span>
        </p>
      )}
    </>
  );
}

function WritingQuestion({
  prompt,
  value,
  onChange,
}: {
  prompt: string;
  value: string;
  onChange: (v: string) => void;
}) {
  return (
    <>
      <h2 className="text-lg sm:text-xl font-bold text-navy mb-4">{prompt}</h2>
      <input
        type="text"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder="Type your Spanish translation here"
        className="w-full px-4 py-3.5 rounded-xl border-2 border-border bg-white text-navy text-lg font-medium placeholder:text-navy/30 focus:border-teal focus:outline-none"
      />
    </>
  );
}

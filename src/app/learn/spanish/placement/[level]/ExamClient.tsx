"use client";

import { useEffect, useRef, useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import {
  EXAM_DURATION_SECONDS,
  type PlacementQuestion,
  type ReadingPassage,
} from "@/lib/placement-exam-types";
import {
  submitPlacementExam,
  type ExamAnswer,
  type ReadingAnswer,
} from "@/lib/placement-exam-actions";

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

interface ISpeechRecognition extends EventTarget {
  lang: string;
  interimResults: boolean;
  continuous: boolean;
  onresult:
    | ((
        this: ISpeechRecognition,
        ev: { results: ArrayLike<{ 0: { transcript: string }; isFinal: boolean }> },
      ) => void)
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

// Exam progresses through three high-level phases:
//   notice -> reading (passage + 3 questions) -> questions (35 numbered)
// The reading phase counts internally as the first 3 of 40 question screens.
type Phase = "notice" | "reading" | "questions";

export default function ExamClient({
  languageSlug,
  level,
  passage,
  questions,
}: {
  languageSlug: string;
  level: string;
  passage: ReadingPassage;
  questions: PlacementQuestion[];
}) {
  const router = useRouter();
  const [phase, setPhase] = useState<Phase>("notice");
  const [readingStep, setReadingStep] = useState(0); // 0..2 within reading
  const [step, setStep] = useState(0); // 0..questions.length-1
  const [answers, setAnswers] = useState<Record<number, string>>({});
  // Reading answers indexed by passage question position 0..2.
  const [readingAnswers, setReadingAnswers] = useState<string[]>(
    () => new Array(passage.questions.length).fill(""),
  );
  const [remaining, setRemaining] = useState(EXAM_DURATION_SECONDS);
  const startedAt = useRef<number>(0);
  const [pending, startTransition] = useTransition();
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Prime TTS voices once they are available.
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

  // Countdown only runs after the user clicks "I am ready".
  useEffect(() => {
    if (phase === "notice") return;
    if (submitted) return;
    const t = setInterval(() => {
      setRemaining((r) => {
        if (r <= 1) {
          clearInterval(t);
          handleSubmit();
          return 0;
        }
        return r - 1;
      });
    }, 1000);
    return () => clearInterval(t);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [phase, submitted]);

  function setAnswer(questionId: number, value: string) {
    setAnswers((prev) => ({ ...prev, [questionId]: value }));
  }
  function setReadingAnswer(idx: number, value: string) {
    setReadingAnswers((prev) => {
      const next = [...prev];
      next[idx] = value;
      return next;
    });
  }

  function startExam() {
    startedAt.current = Date.now();
    setPhase("reading");
  }

  function handleSubmit() {
    if (submitted) return;
    setSubmitted(true);
    const elapsed = Math.round((Date.now() - startedAt.current) / 1000);
    const payload: ExamAnswer[] = questions.map((q) => ({
      question_id: q.id,
      answer: (answers[q.id] ?? "").trim(),
    }));
    const readingPayload: ReadingAnswer[] = readingAnswers.map((ans, i) => ({
      passage_id: passage.id,
      question_index: i,
      answer: ans.trim(),
    }));
    startTransition(async () => {
      const res = await submitPlacementExam(
        languageSlug,
        level,
        passage.id,
        readingPayload,
        payload,
        elapsed,
      );
      if (!res.ok) {
        setError(res.error ?? "Could not submit exam");
        setSubmitted(false);
        return;
      }
      router.refresh();
    });
  }

  if (phase === "notice") {
    return <NoticeScreen level={level} onReady={startExam} />;
  }

  // Common header (timer + progress)
  const totalReading = passage.questions.length;
  const totalQuestions = questions.length;
  const grandTotal = totalReading + totalQuestions;
  const currentIdx =
    phase === "reading" ? readingStep : totalReading + step;

  return (
    <section className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div className="flex items-center justify-between mb-5">
        <div>
          <p className="text-xs font-semibold text-teal-dark uppercase tracking-wider">
            Spanish {level} Placement Exam
          </p>
          <p className="text-sm text-navy/60">
            Question {currentIdx + 1} of {grandTotal}
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

      <div className="h-1.5 w-full rounded-full bg-navy/5 overflow-hidden mb-6">
        <div
          className="h-full rounded-full bg-gradient-to-r from-teal to-teal-dark transition-all"
          style={{ width: `${((currentIdx + 1) / grandTotal) * 100}%` }}
        />
      </div>

      {phase === "reading" ? (
        <ReadingScreen
          passage={passage}
          stepIdx={readingStep}
          value={readingAnswers[readingStep] ?? ""}
          onChange={(v) => setReadingAnswer(readingStep, v)}
          onPrev={
            readingStep === 0
              ? undefined
              : () => setReadingStep((s) => Math.max(0, s - 1))
          }
          onNext={() => {
            if (readingStep < totalReading - 1) {
              setReadingStep((s) => s + 1);
            } else {
              setPhase("questions");
            }
          }}
          isLast={readingStep === totalReading - 1}
        />
      ) : (
        <QuestionScreen
          q={questions[step]}
          value={answers[questions[step].id] ?? ""}
          onChange={(v) => setAnswer(questions[step].id, v)}
          onPrev={
            step === 0
              ? () => setPhase("reading")
              : () => setStep((s) => Math.max(0, s - 1))
          }
          onNext={
            step < totalQuestions - 1
              ? () => setStep((s) => Math.min(totalQuestions - 1, s + 1))
              : undefined
          }
          onSubmit={() => handleSubmit()}
          submitting={pending || submitted}
          isLast={step === totalQuestions - 1}
        />
      )}

      {error && (
        <div className="mt-4 text-sm text-red-600 bg-red-50 border border-red-200 rounded-xl px-4 py-3">
          {error}
        </div>
      )}
    </section>
  );
}

// ---------- Phase: NOTICE ----------
function NoticeScreen({
  level,
  onReady,
}: {
  level: string;
  onReady: () => void;
}) {
  return (
    <section className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
      <p className="text-xs font-semibold text-teal-dark uppercase tracking-wider mb-2">
        Spanish {level} Placement Exam
      </p>
      <h1 className="text-3xl sm:text-4xl font-bold text-navy tracking-tight mb-6">
        Before you begin
      </h1>
      <div className="space-y-4 text-navy/80 leading-relaxed mb-8">
        <p>
          Find a quiet spot. This exam includes listening and speaking
          sections — make sure your microphone and speakers are working.
        </p>
        <p>
          You will have <span className="font-semibold">45 minutes</span> to
          complete one reading passage, 5 vocabulary questions, 5 dialogue
          completions, 10 listening responses, 10 spoken topics and 10
          writing tasks.
        </p>
        <p>
          The pass mark is <span className="font-semibold">75%</span>. You
          cannot go back to a question once you submit, and you cannot
          refresh — closing this page will end your attempt.
        </p>
        <p>
          Speaking responses are recorded in your browser and transcribed
          for grading; writing and listening typed answers are graded by AI
          for grammar, vocabulary and relevance.
        </p>
      </div>
      <button
        type="button"
        onClick={onReady}
        className="w-full sm:w-auto px-8 py-3 text-base font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors"
      >
        I am ready
      </button>
    </section>
  );
}

// ---------- Phase: READING ----------
function ReadingScreen({
  passage,
  stepIdx,
  value,
  onChange,
  onPrev,
  onNext,
  isLast,
}: {
  passage: ReadingPassage;
  stepIdx: number;
  value: string;
  onChange: (v: string) => void;
  onPrev?: () => void;
  onNext: () => void;
  isLast: boolean;
}) {
  const q = passage.questions[stepIdx];
  // Deterministic shuffle per (passage.id, stepIdx) so the same screen always
  // shows options in the same order on this attempt.
  const options = stableShuffle(
    [q.correct_answer, ...q.wrong_answers],
    passage.id * 13 + stepIdx,
  );

  return (
    <>
      <div className="bg-white border border-border rounded-2xl p-6 sm:p-8 mb-4 shadow-sm">
        <p className="text-xs font-semibold text-navy/40 uppercase tracking-wider mb-2">
          Reading · Passage
        </p>
        <p className="text-navy text-base leading-relaxed whitespace-pre-line">
          {passage.passage}
        </p>
      </div>
      <div className="bg-white border border-border rounded-2xl p-6 sm:p-8 mb-6 shadow-sm">
        <p className="text-xs font-semibold text-navy/40 uppercase tracking-wider mb-2">
          Reading · Question {stepIdx + 1} of {passage.questions.length}
        </p>
        <h2 className="text-lg sm:text-xl font-bold text-navy mb-4">
          {q.question}
        </h2>
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
      </div>
      <NavFooter
        onPrev={onPrev}
        onNext={onNext}
        nextLabel={isLast ? "Start questions" : "Next"}
      />
    </>
  );
}

// ---------- Phase: QUESTIONS ----------
function QuestionScreen({
  q,
  value,
  onChange,
  onPrev,
  onNext,
  onSubmit,
  submitting,
  isLast,
}: {
  q: PlacementQuestion;
  value: string;
  onChange: (v: string) => void;
  onPrev: () => void;
  onNext?: () => void;
  onSubmit: () => void;
  submitting: boolean;
  isLast: boolean;
}) {
  return (
    <>
      <div className="bg-white border border-border rounded-2xl p-6 sm:p-8 mb-6 shadow-sm">
        <p className="text-xs font-semibold text-navy/40 uppercase tracking-wider mb-2">
          {q.category}
        </p>
        {q.category === "vocabulary" ? (
          <VocabularyQuestion
            prompt={q.question}
            options={q.options ?? []}
            value={value}
            onChange={onChange}
          />
        ) : q.category === "dialogue" ? (
          <DialogueQuestion
            prompt={q.question}
            lines={q.dialogue_lines ?? []}
            value={value}
            onChange={onChange}
          />
        ) : q.category === "listening" ? (
          <ListeningQuestion
            spanishPrompt={q.question}
            value={value}
            onChange={onChange}
          />
        ) : q.category === "speaking" ? (
          <SpeakingQuestion
            prompt={q.topic_prompt ?? q.question}
            value={value}
            onChange={onChange}
          />
        ) : (
          <WritingQuestion
            prompt={q.question}
            value={value}
            onChange={onChange}
          />
        )}
      </div>
      <NavFooter
        onPrev={onPrev}
        onNext={onNext}
        onSubmit={isLast ? onSubmit : undefined}
        submitting={submitting}
      />
    </>
  );
}

function NavFooter({
  onPrev,
  onNext,
  onSubmit,
  submitting,
  nextLabel,
}: {
  onPrev?: () => void;
  onNext?: () => void;
  onSubmit?: () => void;
  submitting?: boolean;
  nextLabel?: string;
}) {
  return (
    <div className="flex items-center justify-between">
      <button
        type="button"
        onClick={onPrev}
        disabled={!onPrev}
        className="px-4 py-2.5 text-sm font-medium text-navy/60 hover:text-navy disabled:opacity-30 disabled:cursor-not-allowed"
      >
        ← Previous
      </button>
      {onSubmit ? (
        <button
          type="button"
          onClick={onSubmit}
          disabled={submitting}
          className="px-6 py-2.5 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors disabled:opacity-50"
        >
          {submitting ? "Grading…" : "Submit exam"}
        </button>
      ) : (
        <button
          type="button"
          onClick={onNext}
          className="px-6 py-2.5 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors"
        >
          {nextLabel ?? "Next →"}
        </button>
      )}
    </div>
  );
}

// ---------- VOCABULARY (MC, full-sentence stem) ----------
function VocabularyQuestion({
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

// ---------- DIALOGUE COMPLETION ----------
function DialogueQuestion({
  prompt,
  lines,
  value,
  onChange,
}: {
  prompt: string;
  lines: Array<{ speaker: string; text: string }>;
  value: string;
  onChange: (v: string) => void;
}) {
  return (
    <>
      <h2 className="text-lg sm:text-xl font-bold text-navy mb-2">{prompt}</h2>
      <p className="text-xs text-navy/50 mb-4">
        Type one Spanish sentence to complete the dialogue.
      </p>
      <div className="space-y-2 mb-4">
        {lines.map((line, i) => {
          const isMissing = line.text === "___";
          return (
            <div
              key={`${line.speaker}-${i}`}
              className={`px-4 py-2.5 rounded-xl ${
                isMissing
                  ? "bg-teal-light border border-teal/40"
                  : "bg-navy/5"
              }`}
            >
              <span className="text-xs font-semibold text-navy/60 mr-2">
                {line.speaker}:
              </span>
              <span className="text-navy">{isMissing ? "________" : line.text}</span>
            </div>
          );
        })}
      </div>
      <input
        type="text"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder="Type your Spanish response…"
        className="w-full px-4 py-3.5 rounded-xl border-2 border-border bg-white text-navy text-base focus:border-teal focus:outline-none"
      />
    </>
  );
}

// ---------- LISTENING (audio → typed Spanish response) ----------
function ListeningQuestion({
  spanishPrompt,
  value,
  onChange,
}: {
  spanishPrompt: string;
  value: string;
  onChange: (v: string) => void;
}) {
  return (
    <>
      <h2 className="text-lg sm:text-xl font-bold text-navy mb-2">
        Listen, then type your response in Spanish.
      </h2>
      <p className="text-xs text-navy/50 mb-3">
        Press play to hear the question. You can replay as many times as you
        like.
      </p>
      <button
        type="button"
        onClick={() => speak(spanishPrompt)}
        className="inline-flex items-center gap-2 px-4 py-2 mb-4 text-sm font-semibold rounded-full bg-teal-light text-teal-dark hover:bg-teal hover:text-white transition-colors"
      >
        <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
          <path d="M8 5v14l11-7z" />
        </svg>
        Play audio
      </button>
      <textarea
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder="Write a Spanish reply to what you heard…"
        rows={3}
        className="w-full px-4 py-3 rounded-xl border-2 border-border bg-white text-navy text-base focus:border-teal focus:outline-none resize-none"
      />
    </>
  );
}

// ---------- SPEAKING (free monologue, transcript stored as answer) ----------
function SpeakingQuestion({
  prompt,
  value,
  onChange,
}: {
  prompt: string;
  value: string;
  onChange: (v: string) => void;
}) {
  const [recording, setRecording] = useState(false);
  const [interim, setInterim] = useState("");
  const [error, setError] = useState<string | null>(null);
  const recRef = useRef<ISpeechRecognition | null>(null);
  const finalRef = useRef<string>("");

  // Reset captured text when the prompt changes (i.e. user navigated).
  useEffect(() => {
    finalRef.current = value;
  }, [value]);

  function start() {
    setError(null);
    const Ctor = getSpeechRecognition();
    if (!Ctor) {
      setError(
        "Speech recognition is not available in this browser. Please use Chrome on desktop or Android.",
      );
      return;
    }
    const rec = new Ctor();
    rec.lang = "es-ES";
    rec.interimResults = true;
    rec.continuous = true;
    rec.onresult = (e) => {
      let interimStr = "";
      let finalStr = finalRef.current;
      for (let i = 0; i < e.results.length; i++) {
        const r = e.results[i];
        if (r.isFinal) {
          finalStr = (finalStr + " " + r[0].transcript).trim();
        } else {
          interimStr += r[0].transcript;
        }
      }
      finalRef.current = finalStr;
      onChange(finalStr);
      setInterim(interimStr);
    };
    rec.onerror = (e) => {
      setError(`Microphone error: ${e.error}`);
      setRecording(false);
    };
    rec.onend = () => {
      setRecording(false);
      setInterim("");
    };
    recRef.current = rec;
    try {
      rec.start();
      setRecording(true);
    } catch {
      setError("Could not start the microphone.");
    }
  }

  function stop() {
    recRef.current?.stop();
    setRecording(false);
  }

  return (
    <>
      <h2 className="text-lg sm:text-xl font-bold text-navy mb-3">{prompt}</h2>
      <p className="text-xs text-navy/50 mb-4">
        Press <strong>Start recording</strong>, speak freely in Spanish, then
        press <strong>Stop</strong> when you have finished. Use the
        Next button below to move on to the next prompt.
      </p>
      <div className="flex flex-col gap-3">
        {!recording ? (
          <button
            type="button"
            onClick={start}
            className="px-6 py-3 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors"
          >
            🎤 Start recording
          </button>
        ) : (
          <button
            type="button"
            onClick={stop}
            className="px-6 py-3 text-sm font-semibold text-white bg-red-600 rounded-xl hover:bg-red-700 transition-colors"
          >
            ■ Stop recording
          </button>
        )}
        <div className="rounded-xl border border-border bg-navy/5 p-3 min-h-[6rem]">
          <p className="text-xs text-navy/50 uppercase tracking-wider mb-1">
            Transcript
          </p>
          <p className="text-navy text-sm whitespace-pre-wrap">
            {value || (recording ? "Listening…" : "(nothing recorded yet)")}
            {interim && (
              <span className="text-navy/40 italic"> {interim}</span>
            )}
          </p>
        </div>
      </div>
      {error && <p className="mt-3 text-xs text-red-600">{error}</p>}
    </>
  );
}

// ---------- WRITING (English prompt → Spanish prose) ----------
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
      <h2 className="text-lg sm:text-xl font-bold text-navy mb-3">{prompt}</h2>
      <textarea
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder="Write your Spanish response…"
        rows={5}
        className="w-full px-4 py-3 rounded-xl border-2 border-border bg-white text-navy text-base focus:border-teal focus:outline-none resize-none"
      />
    </>
  );
}

function stableShuffle<T>(arr: T[], seed: number): T[] {
  const out = [...arr];
  let s = seed;
  for (let i = out.length - 1; i > 0; i--) {
    s = (s * 9301 + 49297) % 233280;
    const j = Math.floor((s / 233280) * (i + 1));
    [out[i], out[j]] = [out[j], out[i]];
  }
  return out;
}

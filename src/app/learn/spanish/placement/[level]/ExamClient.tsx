"use client";

import { useEffect, useRef, useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import {
  EXAM_DURATION_SECONDS,
  type PlacementQuestion,
  type ReadingPassage,
  type RoleplayScenario,
} from "@/lib/placement-exam-types";
import {
  submitPlacementExam,
  type ExamAnswer,
  type ReadingAnswer,
  type RoleplayTranscript,
} from "@/lib/placement-exam-actions";

function formatTime(seconds: number): string {
  const m = Math.floor(seconds / 60);
  const s = seconds % 60;
  return `${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`;
}

// Strictly prefer the requested locale (e.g. es-ES for Castilian Spanish,
// fr-FR for European French). Browsers often list es-MX, es-419 or fr-CA
// alongside the European variants; we always pick the exact locale first
// and fall back deterministically — Spain over Latin America for Spanish,
// France over Canada for French. Catalan ("ca") is never accepted as a
// Spanish fallback (it has its own ISO 639 code, not the "es" prefix).
function pickVoice(locale: string): SpeechSynthesisVoice | null {
  if (typeof window === "undefined" || !("speechSynthesis" in window)) return null;
  const voices = window.speechSynthesis.getVoices();
  if (voices.length === 0) return null;
  const target = locale.toLowerCase().replace("_", "-");
  const prefix = target.split("-")[0];
  const country = target.split("-")[1] ?? "";

  const norm = (l: string) => l.toLowerCase().replace("_", "-");

  // 1. Exact locale match.
  const exact = voices.find((v) => norm(v.lang) === target);
  if (exact) return exact;

  // 2. Any voice whose lang exactly matches the requested country variant
  //    even if formatted differently ("es-ES", "es_ES", "es-es-x-...").
  const exactCountry = voices.find((v) => {
    const l = norm(v.lang);
    return l === target || l.startsWith(`${prefix}-${country}`);
  });
  if (exactCountry) return exactCountry;

  // 3. Bare-language match (e.g. "es" without country) — typically the
  //    browser's default for that language, often Castilian / European.
  const bare = voices.find((v) => norm(v.lang) === prefix);
  if (bare) return bare;

  // 4. Same-language voices, preferring the European country (Spain for
  //    Spanish, France for French) over Latin American / Canadian variants.
  const sameLang = voices.filter((v) => norm(v.lang).startsWith(`${prefix}-`));
  if (sameLang.length === 0) return null;
  const preferredCountries: Record<string, string[]> = {
    es: ["es"], // Spain
    fr: ["fr"], // France
  };
  const preferred = preferredCountries[prefix] ?? [];
  for (const c of preferred) {
    const hit = sameLang.find((v) => norm(v.lang) === `${prefix}-${c}`);
    if (hit) return hit;
  }
  return sameLang[0];
}

function speak(text: string, locale: string, rate: number = 1.0) {
  if (typeof window === "undefined" || !("speechSynthesis" in window)) return;
  window.speechSynthesis.cancel();
  const u = new SpeechSynthesisUtterance(text);
  u.lang = locale;
  const voice = pickVoice(locale);
  if (voice) u.voice = voice;
  u.rate = rate;
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

// Exam progresses through up to four high-level phases:
//   notice -> reading -> roleplay (B1/B2/C1 only) -> questions (vocab + dialogue + writing)
// On A1/A2 there is no roleplay phase; questions include listening + speaking.
type Phase = "notice" | "reading" | "roleplay" | "questions";

export default function ExamClient({
  languageSlug,
  languageName,
  localeCode,
  level,
  passage,
  questions,
  roleplays,
}: {
  languageSlug: string;
  languageName: string;
  localeCode: string;
  level: string;
  passage: ReadingPassage;
  questions: PlacementQuestion[];
  roleplays: RoleplayScenario[];
}) {
  const router = useRouter();
  const hasRoleplay = roleplays.length > 0;
  const [phase, setPhase] = useState<Phase>("notice");
  const [readingStep, setReadingStep] = useState(0); // 0..2 within reading
  const [step, setStep] = useState(0); // 0..questions.length-1
  const [roleplayIdx, setRoleplayIdx] = useState(0); // 0..roleplays.length-1
  const [answers, setAnswers] = useState<Record<number, string>>({});
  // Reading answers indexed by passage question position 0..2.
  const [readingAnswers, setReadingAnswers] = useState<string[]>(
    () => new Array(passage.questions.length).fill(""),
  );
  // One transcript array per roleplay, seeded with the AI opener.
  const [roleplayTranscripts, setRoleplayTranscripts] = useState<
    RoleplayTranscript[]
  >(() =>
    roleplays.map((r) => ({
      roleplay_id: r.id,
      turns: [{ role: "ai" as const, text: r.ai_opener }],
    })),
  );
  const [remaining, setRemaining] = useState(EXAM_DURATION_SECONDS);
  const startedAt = useRef<number>(0);
  const [pending, startTransition] = useTransition();
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState<string | null>(null);

  function appendRoleplayTurn(
    rpIdx: number,
    turn: { role: "user" | "ai"; text: string },
  ) {
    setRoleplayTranscripts((prev) => {
      const next = prev.map((t, i) =>
        i === rpIdx ? { ...t, turns: [...t.turns, turn] } : t,
      );
      return next;
    });
  }

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
        hasRoleplay ? roleplayTranscripts : [],
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
    return (
      <NoticeScreen
        level={level}
        languageName={languageName}
        onReady={startExam}
        onExit={() => router.push(`/learn/${languageSlug}`)}
      />
    );
  }

  // Common header (timer + progress). For B1/B2/C1 the 3 roleplays count as
  // 3 extra screens between reading and the remaining questions.
  const totalReading = passage.questions.length;
  const totalQuestions = questions.length;
  const totalRoleplays = roleplays.length;
  const grandTotal = totalReading + totalRoleplays + totalQuestions;
  const currentIdx =
    phase === "reading"
      ? readingStep
      : phase === "roleplay"
        ? totalReading + roleplayIdx
        : totalReading + totalRoleplays + step;

  function handleExit() {
    if (submitted) return;
    const ok = window.confirm(
      "Exit the exam? Your progress will not be saved and this attempt will not count.",
    );
    if (!ok) return;
    router.push(`/learn/${languageSlug}`);
  }

  return (
    <section className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div className="flex items-center justify-between mb-5 gap-3">
        <div className="min-w-0">
          <p className="text-xs font-semibold text-teal-dark uppercase tracking-wider">
            {languageName} {level} Placement Exam
          </p>
          <p className="text-sm text-navy/60">
            Question {currentIdx + 1} of {grandTotal}
          </p>
        </div>
        <div className="flex items-center gap-3 shrink-0">
          <button
            type="button"
            onClick={handleExit}
            className="text-xs font-medium text-navy/50 hover:text-red-600 hover:underline"
          >
            Exit exam
          </button>
          <div
            className={`text-2xl font-bold tabular-nums ${
              remaining <= 60 ? "text-red-600" : "text-navy"
            }`}
          >
            ⏱ {formatTime(remaining)}
          </div>
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
            } else if (hasRoleplay) {
              setPhase("roleplay");
            } else {
              setPhase("questions");
            }
          }}
          isLast={readingStep === totalReading - 1}
        />
      ) : phase === "roleplay" ? (
        <RoleplayScreen
          key={roleplays[roleplayIdx].id}
          level={level}
          languageSlug={languageSlug}
          languageName={languageName}
          scenario={roleplays[roleplayIdx]}
          transcript={roleplayTranscripts[roleplayIdx]}
          onAppendUser={(text) =>
            appendRoleplayTurn(roleplayIdx, { role: "user", text })
          }
          onAppendAI={(text) =>
            appendRoleplayTurn(roleplayIdx, { role: "ai", text })
          }
          stepIdx={roleplayIdx}
          totalRoleplays={totalRoleplays}
          onPrev={
            roleplayIdx === 0
              ? () => setPhase("reading")
              : () => setRoleplayIdx((i) => Math.max(0, i - 1))
          }
          onNext={() => {
            if (roleplayIdx < totalRoleplays - 1) {
              setRoleplayIdx((i) => i + 1);
            } else {
              setPhase("questions");
            }
          }}
        />
      ) : (
        <QuestionScreen
          q={questions[step]}
          languageName={languageName}
          localeCode={localeCode}
          value={answers[questions[step].id] ?? ""}
          onChange={(v) => setAnswer(questions[step].id, v)}
          onPrev={
            step === 0
              ? () =>
                  hasRoleplay ? setPhase("roleplay") : setPhase("reading")
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
  languageName,
  onReady,
  onExit,
}: {
  level: string;
  languageName: string;
  onReady: () => void;
  onExit: () => void;
}) {
  const usesRoleplay = ["B1", "B2", "C1"].includes(level);
  return (
    <section className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
      <p className="text-xs font-semibold text-teal-dark uppercase tracking-wider mb-2">
        {languageName} {level} Placement Exam
      </p>
      <h1 className="text-3xl sm:text-4xl font-bold text-navy tracking-tight mb-6">
        Before you begin
      </h1>
      <div className="space-y-4 text-navy/80 leading-relaxed mb-8">
        <p>
          Find a quiet spot. This exam includes{" "}
          {usesRoleplay ? "roleplay and writing" : "listening and speaking"}{" "}
          sections — make sure your microphone and speakers are working.
        </p>
        <p>
          You will have <span className="font-semibold">45 minutes</span> to
          complete{" "}
          {usesRoleplay
            ? "one reading passage, 5 vocabulary questions, 5 dialogue completions, 3 roleplay dialogues and 5 writing tasks"
            : "one reading passage, 5 vocabulary questions, 5 dialogue completions, 10 listening responses, 4 spoken topics and 4 writing tasks"}
          .
        </p>
        <p>
          The pass mark is <span className="font-semibold">75%</span>. You
          cannot go back to a question once you submit, and you cannot
          refresh — closing this page will end your attempt.
        </p>
        <p>
          {usesRoleplay
            ? "Roleplay turns and writing answers are graded by AI for grammar, vocabulary, register and relevance."
            : "Speaking responses are recorded in your browser and transcribed for grading; writing and listening typed answers are graded by AI for grammar, vocabulary and relevance."}
        </p>
      </div>
      <div className="flex flex-col sm:flex-row gap-3 items-stretch sm:items-center">
        <button
          type="button"
          onClick={onReady}
          className="px-8 py-3 text-base font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors"
        >
          I am ready
        </button>
        <button
          type="button"
          onClick={onExit}
          className="px-6 py-3 text-sm font-medium text-navy/60 hover:text-navy"
        >
          Not now — back to course
        </button>
      </div>
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
        nextLabel="Next question"
      />
    </>
  );
}

// ---------- Phase: QUESTIONS ----------
function QuestionScreen({
  q,
  languageName,
  localeCode,
  value,
  onChange,
  onPrev,
  onNext,
  onSubmit,
  submitting,
  isLast,
}: {
  q: PlacementQuestion;
  languageName: string;
  localeCode: string;
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
            languageName={languageName}
            lines={q.dialogue_lines ?? []}
            value={value}
            onChange={onChange}
          />
        ) : q.category === "listening" ? (
          <ListeningQuestion
            audioPrompt={q.question}
            languageName={languageName}
            localeCode={localeCode}
            value={value}
            onChange={onChange}
          />
        ) : q.category === "speaking" ? (
          <SpeakingQuestion
            prompt={q.topic_prompt ?? q.question}
            languageName={languageName}
            localeCode={localeCode}
            value={value}
            onChange={onChange}
          />
        ) : (
          <WritingQuestion
            prompt={q.question}
            languageName={languageName}
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
  languageName,
  lines,
  value,
  onChange,
}: {
  prompt: string;
  languageName: string;
  lines: Array<{ speaker: string; text: string }>;
  value: string;
  onChange: (v: string) => void;
}) {
  return (
    <>
      <h2 className="text-lg sm:text-xl font-bold text-navy mb-2">{prompt}</h2>
      <p className="text-xs text-navy/50 mb-4">
        Type one {languageName} sentence to complete the dialogue.
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
        placeholder={`Type your ${languageName} response…`}
        className="w-full px-4 py-3.5 rounded-xl border-2 border-border bg-white text-navy text-base focus:border-teal focus:outline-none"
      />
    </>
  );
}

// ---------- LISTENING (audio → typed target-language response) ----------
function ListeningQuestion({
  audioPrompt,
  languageName,
  localeCode,
  value,
  onChange,
}: {
  audioPrompt: string;
  languageName: string;
  localeCode: string;
  value: string;
  onChange: (v: string) => void;
}) {
  return (
    <>
      <h2 className="text-lg sm:text-xl font-bold text-navy mb-2">
        Listen, then type your response in {languageName}.
      </h2>
      <p className="text-xs text-navy/50 mb-4">
        Press play to hear the question. You can replay as many times as you
        like.
      </p>
      <ListeningAudioPlayer text={audioPrompt} locale={localeCode} />
      <textarea
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={`Write a ${languageName} reply to what you heard…`}
        rows={3}
        className="w-full px-4 py-3 rounded-xl border-2 border-border bg-white text-navy text-base focus:border-teal focus:outline-none resize-none"
      />
    </>
  );
}

// ---------- AUDIO PLAYER (used by ListeningQuestion) ----------
// Drives `window.speechSynthesis` while exposing a real audio-player UX:
// play / pause, scrubbable progress bar, animated waveform, speed cycle,
// elapsed / total time. The Web Speech API has no native seek, so we
// implement scrubbing by cancelling the current utterance and starting a
// new one from substring(text * ratio). Duration is estimated from text
// length / playback rate (≈14 chars/sec at rate 1.0 — close enough for a
// progress display).
function ListeningAudioPlayer({
  text,
  locale,
}: {
  text: string;
  locale: string;
}) {
  const RATE_OPTIONS = [0.75, 1.0, 1.25, 1.5];
  const BAR_COUNT = 48;

  // Position is a 0..1 fraction of the source text we've spoken so far.
  // currentTime / duration derive from it; this keeps the UI consistent
  // when the rate changes (which would otherwise warp the clock).
  const [position, setPosition] = useState(0);
  const [isPlaying, setIsPlaying] = useState(false);
  const [rate, setRate] = useState(1.0);
  const [supported, setSupported] = useState(true);

  const startPosRef = useRef(0); // position when current utterance started
  const startTimeRef = useRef(0); // wall-clock ms when current utterance started
  const tickRef = useRef<number | null>(null);
  const utterRef = useRef<SpeechSynthesisUtterance | null>(null);

  // Bar heights are deterministic from text so re-renders don't shuffle.
  const heights = useRef<number[]>(
    Array.from({ length: BAR_COUNT }, (_, i) => {
      const seed = (text.charCodeAt(i % Math.max(1, text.length)) ?? 7) + i * 31;
      // 0.25 .. 0.95 range
      return 0.25 + ((seed * 9301 + 49297) % 233280) / 233280 * 0.7;
    }),
  ).current;

  // Estimated total duration in seconds at the active rate.
  const duration = Math.max(1, text.length / (14 * rate));
  const currentTime = Math.min(position * duration, duration);

  useEffect(() => {
    if (typeof window === "undefined" || !("speechSynthesis" in window)) {
      setSupported(false);
    }
    return () => {
      if (typeof window !== "undefined" && "speechSynthesis" in window) {
        window.speechSynthesis.cancel();
      }
      if (tickRef.current !== null) cancelAnimationFrame(tickRef.current);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  function startTicking() {
    if (tickRef.current !== null) cancelAnimationFrame(tickRef.current);
    const loop = () => {
      const elapsed = (Date.now() - startTimeRef.current) / 1000;
      const advance = elapsed / duration;
      const next = Math.min(1, startPosRef.current + advance);
      setPosition(next);
      if (next < 1) {
        tickRef.current = requestAnimationFrame(loop);
      }
    };
    tickRef.current = requestAnimationFrame(loop);
  }

  function stopTicking() {
    if (tickRef.current !== null) {
      cancelAnimationFrame(tickRef.current);
      tickRef.current = null;
    }
  }

  function playFrom(fraction: number) {
    if (!supported) return;
    window.speechSynthesis.cancel();
    const startFrac = Math.max(0, Math.min(0.999, fraction));
    const startIdx = Math.floor(text.length * startFrac);
    const remaining = text.substring(startIdx);
    const u = new SpeechSynthesisUtterance(remaining);
    u.lang = locale;
    u.rate = rate;
    const voice = pickVoice(locale);
    if (voice) u.voice = voice;
    u.onstart = () => {
      startPosRef.current = startFrac;
      startTimeRef.current = Date.now();
      setIsPlaying(true);
      startTicking();
    };
    u.onend = () => {
      stopTicking();
      setIsPlaying(false);
      setPosition(0);
      startPosRef.current = 0;
    };
    u.onerror = () => {
      stopTicking();
      setIsPlaying(false);
    };
    utterRef.current = u;
    window.speechSynthesis.speak(u);
  }

  function pause() {
    if (!supported) return;
    window.speechSynthesis.cancel();
    stopTicking();
    setIsPlaying(false);
    // Freeze position where the user paused so resume picks up there.
    startPosRef.current = position;
  }

  function toggle() {
    if (isPlaying) pause();
    else playFrom(position >= 1 ? 0 : position);
  }

  function seek(e: React.MouseEvent<HTMLDivElement>) {
    const rect = e.currentTarget.getBoundingClientRect();
    const ratio = Math.max(0, Math.min(1, (e.clientX - rect.left) / rect.width));
    const wasPlaying = isPlaying;
    pause();
    setPosition(ratio);
    startPosRef.current = ratio;
    if (wasPlaying) playFrom(ratio);
  }

  function cycleRate() {
    const idx = RATE_OPTIONS.indexOf(rate);
    const nextRate = RATE_OPTIONS[(idx + 1) % RATE_OPTIONS.length];
    setRate(nextRate);
    if (isPlaying) {
      // Replay from current position at the new rate.
      const pos = position;
      window.speechSynthesis.cancel();
      stopTicking();
      // Defer to next tick so the rate update is in effect.
      setTimeout(() => playFrom(pos), 0);
    }
  }

  return (
    <div className="rounded-2xl border-2 border-border bg-white p-3 sm:p-4 mb-4">
      <div className="flex items-center gap-2 sm:gap-3">
        <button
          type="button"
          onClick={toggle}
          disabled={!supported}
          aria-label={isPlaying ? "Pause" : "Play"}
          className="flex-shrink-0 w-11 h-11 rounded-full bg-teal text-white flex items-center justify-center shadow-sm shadow-teal/30 hover:bg-teal-dark transition-colors disabled:opacity-40 disabled:cursor-not-allowed"
        >
          {isPlaying ? (
            <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
              <path d="M6 5h4v14H6V5zm8 0h4v14h-4V5z" />
            </svg>
          ) : (
            <svg className="w-5 h-5 ml-0.5" fill="currentColor" viewBox="0 0 24 24">
              <path d="M8 5v14l11-7z" />
            </svg>
          )}
        </button>
        <div
          onClick={seek}
          role="slider"
          aria-label="Audio progress"
          aria-valuemin={0}
          aria-valuemax={100}
          aria-valuenow={Math.round(position * 100)}
          tabIndex={0}
          className="flex-1 h-11 flex items-center cursor-pointer relative select-none"
        >
          {/* Waveform bars layer */}
          <div className="absolute inset-0 flex items-center gap-[2px] px-1">
            {heights.map((h, i) => {
              const barFrac = (i + 0.5) / BAR_COUNT;
              const filled = barFrac <= position;
              const isCursor =
                isPlaying && Math.abs(barFrac - position) < 1 / BAR_COUNT;
              return (
                <span
                  key={i}
                  className={`flex-1 rounded-full ${
                    filled ? "bg-navy" : "bg-navy/15"
                  } ${isCursor ? "animate-pulse bg-teal-dark" : ""}`}
                  style={{ height: `${h * 100}%` }}
                />
              );
            })}
          </div>
          {/* Progress fill stripe at the bottom (subtle, beneath bars) */}
          <div
            className="absolute bottom-0 left-0 h-[3px] rounded-full bg-teal pointer-events-none"
            style={{ width: `${position * 100}%` }}
          />
        </div>
        <div className="flex-shrink-0 text-[11px] tabular-nums text-navy/60 font-medium min-w-[60px] text-right">
          {fmtClock(currentTime)} / {fmtClock(duration)}
        </div>
        <button
          type="button"
          onClick={cycleRate}
          disabled={!supported}
          aria-label="Playback speed"
          className="flex-shrink-0 text-xs font-bold px-2.5 py-1.5 rounded-md bg-navy/5 hover:bg-navy/10 text-navy w-[52px] disabled:opacity-40"
        >
          {rate === 1 ? "1x" : `${rate}x`}
        </button>
      </div>
      {!supported && (
        <p className="mt-2 text-[11px] text-amber-700">
          Audio playback isn&apos;t available in this browser. Try Chrome.
        </p>
      )}
    </div>
  );
}

function fmtClock(s: number): string {
  const m = Math.floor(s / 60);
  const sec = Math.floor(s % 60);
  return `${m}:${String(sec).padStart(2, "0")}`;
}

// Collapse runs of repeated tokens that Web Speech sometimes produces
// when continuous mode re-fires final results ("hello hello hello world"
// → "hello world"). Operates on tokens and on 2-, 3-, 4-word phrases.
function dedupeTranscript(text: string): string {
  if (!text) return text;
  let tokens = text.split(/\s+/).filter(Boolean);
  // Pass 1: collapse identical consecutive single words (case-insensitive).
  const out: string[] = [];
  for (const w of tokens) {
    if (out.length === 0 || out[out.length - 1].toLowerCase() !== w.toLowerCase()) {
      out.push(w);
    }
  }
  tokens = out;
  // Pass 2: collapse identical consecutive n-grams (n = 2..4).
  for (let n = 4; n >= 2; n--) {
    const compacted: string[] = [];
    let i = 0;
    while (i < tokens.length) {
      if (i + 2 * n <= tokens.length) {
        const left = tokens.slice(i, i + n).join(" ").toLowerCase();
        const right = tokens.slice(i + n, i + 2 * n).join(" ").toLowerCase();
        if (left === right) {
          compacted.push(...tokens.slice(i, i + n));
          i += 2 * n;
          continue;
        }
      }
      compacted.push(tokens[i]);
      i += 1;
    }
    tokens = compacted;
  }
  return tokens.join(" ");
}

function countWords(text: string): number {
  return text.trim() ? text.trim().split(/\s+/).length : 0;
}

// ---------- SPEAKING (free monologue, transcript stored as answer) ----------
function SpeakingQuestion({
  prompt,
  languageName,
  localeCode,
  value,
  onChange,
}: {
  prompt: string;
  languageName: string;
  localeCode: string;
  value: string;
  onChange: (v: string) => void;
}) {
  const [recording, setRecording] = useState(false);
  const [processing, setProcessing] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const recRef = useRef<ISpeechRecognition | null>(null);
  // finalRef holds the cleaned final transcript across `onresult` calls.
  // The previous implementation reset finalStr from finalRef on every event
  // AND iterated all results from index 0, which appended every already-final
  // result a second time — hence the heavy duplication. We now use
  // e.resultIndex (the index of the first result that changed in this batch)
  // so each final result is consumed exactly once.
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
    rec.lang = localeCode;
    // Interim results are NOT shown in the UI — they were the source of the
    // duplication bug. We still set the flag to true so onresult fires often
    // enough to feel responsive; only the final segments are appended.
    rec.interimResults = true;
    rec.continuous = true;
    rec.onresult = (e) => {
      const evt = e as unknown as {
        resultIndex?: number;
        results: ArrayLike<{ 0: { transcript: string }; isFinal: boolean }>;
      };
      const startIdx =
        typeof evt.resultIndex === "number" ? evt.resultIndex : 0;
      let appended = "";
      for (let i = startIdx; i < evt.results.length; i++) {
        const r = evt.results[i];
        if (r.isFinal) {
          const t = r[0].transcript.trim();
          if (t) appended += " " + t;
        }
      }
      if (appended) {
        const merged = (finalRef.current + appended).trim();
        finalRef.current = merged;
        onChange(merged);
      }
    };
    rec.onerror = (e) => {
      setError(`Microphone error: ${e.error}`);
      setRecording(false);
    };
    rec.onend = () => {
      // Triggered when the user stops, or when the recogniser ends naturally.
      setRecording(false);
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
    if (!recording) return;
    recRef.current?.stop();
    setRecording(false);
    // Brief "processing" state before showing the cleaned transcript so the
    // user gets visible feedback that the recording was captured. Final
    // dedupe runs as a safety net for any consecutive-repeat artefacts the
    // recogniser may still emit at the very end of a session.
    setProcessing(true);
    setTimeout(() => {
      const cleaned = dedupeTranscript(finalRef.current);
      finalRef.current = cleaned;
      onChange(cleaned);
      setProcessing(false);
    }, 600);
  }

  const wordCount = countWords(value);

  return (
    <>
      <h2 className="text-lg sm:text-xl font-bold text-navy mb-3">{prompt}</h2>
      <p className="text-xs text-navy/50 mb-4">
        Press <strong>Start recording</strong>, speak freely in {languageName},
        then press <strong>Stop</strong> when you have finished. Use the
        Next button below to move on to the next prompt.
      </p>
      <div className="flex flex-col gap-3">
        {!recording ? (
          <button
            type="button"
            onClick={start}
            disabled={processing}
            className="px-6 py-3 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors disabled:opacity-50"
          >
            🎤 Start recording
          </button>
        ) : (
          <button
            type="button"
            onClick={stop}
            className="px-6 py-3 text-sm font-semibold text-white bg-red-600 rounded-xl hover:bg-red-700 transition-colors inline-flex items-center justify-center gap-2"
          >
            {/* Pulsing red mic indicator so the user always sees they are live */}
            <span className="relative inline-flex items-center justify-center w-5 h-5">
              <span className="absolute inline-flex w-full h-full rounded-full bg-white/70 opacity-75 animate-ping" />
              <svg
                className="relative w-4 h-4"
                fill="currentColor"
                viewBox="0 0 24 24"
              >
                <path d="M12 14a3 3 0 0 0 3-3V5a3 3 0 1 0-6 0v6a3 3 0 0 0 3 3zm5-3a5 5 0 0 1-10 0H5a7 7 0 0 0 6 6.92V21h2v-3.08A7 7 0 0 0 19 11z" />
              </svg>
            </span>
            Stop recording
          </button>
        )}
        <div className="rounded-xl border border-border bg-navy/5 p-3 min-h-[6rem]">
          <div className="flex items-center justify-between mb-1">
            <p className="text-xs text-navy/50 uppercase tracking-wider">
              Transcript
            </p>
            <p className="text-[11px] text-navy/50 tabular-nums">
              {wordCount} {wordCount === 1 ? "word" : "words"}
            </p>
          </div>
          {processing ? (
            <p className="text-navy/60 text-sm italic">
              Processing your response…
            </p>
          ) : (
            <p className="text-navy text-sm whitespace-pre-wrap">
              {value || (recording ? "Listening…" : "(nothing recorded yet)")}
            </p>
          )}
        </div>
      </div>
      {error && <p className="mt-3 text-xs text-red-600">{error}</p>}
    </>
  );
}

// ---------- WRITING (English prompt → target-language prose) ----------
function WritingQuestion({
  prompt,
  languageName,
  value,
  onChange,
}: {
  prompt: string;
  languageName: string;
  value: string;
  onChange: (v: string) => void;
}) {
  return (
    <>
      <h2 className="text-lg sm:text-xl font-bold text-navy mb-3">{prompt}</h2>
      <textarea
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={`Write your ${languageName} response…`}
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

// ---------- ROLEPLAY (B1/B2/C1 only) ----------
function RoleplayScreen({
  level,
  languageSlug,
  languageName,
  scenario,
  transcript,
  stepIdx,
  totalRoleplays,
  onAppendUser,
  onAppendAI,
  onPrev,
  onNext,
}: {
  level: string;
  languageSlug: string;
  languageName: string;
  scenario: RoleplayScenario;
  transcript: RoleplayTranscript;
  stepIdx: number;
  totalRoleplays: number;
  onAppendUser: (text: string) => void;
  onAppendAI: (text: string) => void;
  onPrev: () => void;
  onNext: () => void;
}) {
  const [input, setInput] = useState("");
  const [isThinking, setIsThinking] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const scrollerRef = useRef<HTMLDivElement | null>(null);

  const userTurns = transcript.turns.filter((t) => t.role === "user").length;
  const isFinished =
    userTurns >= scenario.target_exchanges &&
    transcript.turns[transcript.turns.length - 1]?.role === "ai";

  // Auto-scroll the transcript when it grows.
  useEffect(() => {
    if (scrollerRef.current) {
      scrollerRef.current.scrollTop = scrollerRef.current.scrollHeight;
    }
  }, [transcript.turns.length]);

  async function sendTurn() {
    if (isThinking || isFinished) return;
    const trimmed = input.trim();
    if (trimmed.length === 0) return;
    // Append the user's turn locally first, then call the AI route.
    onAppendUser(trimmed);
    const newHistory = [...transcript.turns, { role: "user" as const, text: trimmed }];
    setInput("");
    setIsThinking(true);
    setError(null);
    try {
      const res = await fetch("/api/roleplay-turn", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({
          level,
          language: languageSlug,
          topic: scenario.topic_label,
          scenario: scenario.scenario,
          user_role: scenario.user_role,
          ai_role: scenario.ai_role,
          target_exchanges: scenario.target_exchanges,
          history: newHistory,
        }),
      });
      if (!res.ok) {
        setError(`Could not get the next AI line (HTTP ${res.status}).`);
        return;
      }
      const data = (await res.json()) as {
        next_line: string;
        is_final: boolean;
      };
      onAppendAI(data.next_line || "…");
    } catch (e) {
      setError(
        e instanceof Error
          ? e.message
          : "Could not reach the roleplay engine.",
      );
    } finally {
      setIsThinking(false);
    }
  }

  function onKey(e: React.KeyboardEvent<HTMLTextAreaElement>) {
    if (e.key === "Enter" && (e.metaKey || e.ctrlKey)) {
      e.preventDefault();
      sendTurn();
    }
  }

  return (
    <>
      <div className="bg-white border border-border rounded-2xl p-6 sm:p-7 mb-4 shadow-sm">
        <p className="text-xs font-semibold text-navy/40 uppercase tracking-wider mb-2">
          Roleplay {stepIdx + 1} of {totalRoleplays} — {scenario.topic_label}
        </p>
        <p className="text-sm text-navy/80 leading-relaxed mb-3">
          {scenario.scenario}
        </p>
        <p className="text-xs text-navy/60">
          You play <span className="font-semibold">{scenario.user_role}</span>.
          The AI plays <span className="font-semibold">{scenario.ai_role}</span>.
          Each of your replies should be at least two full {languageName}{" "}
          sentences (except a greeting or farewell).
        </p>
      </div>

      <div
        ref={scrollerRef}
        className="bg-navy/5 border border-border rounded-2xl p-4 mb-4 h-[22rem] overflow-y-auto space-y-3"
      >
        {transcript.turns.map((t, i) => (
          <div
            key={i}
            className={`flex ${t.role === "user" ? "justify-end" : "justify-start"}`}
          >
            <div
              className={`max-w-[85%] rounded-2xl px-4 py-2.5 text-sm leading-relaxed whitespace-pre-wrap ${
                t.role === "user"
                  ? "bg-teal text-white"
                  : "bg-white text-navy border border-border"
              }`}
            >
              <p className="text-[10px] uppercase tracking-wider opacity-60 mb-0.5">
                {t.role === "user" ? scenario.user_role : scenario.ai_role}
              </p>
              {t.text}
            </div>
          </div>
        ))}
        {isThinking && (
          <div className="flex justify-start">
            <div className="bg-white text-navy border border-border rounded-2xl px-4 py-2.5 text-sm italic opacity-70">
              {scenario.ai_role} is typing…
            </div>
          </div>
        )}
      </div>

      <div className="mb-4">
        <textarea
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={onKey}
          placeholder={
            isFinished
              ? "This roleplay is complete. Press Next to continue."
              : `Type your ${languageName} reply (at least 2 sentences)…`
          }
          disabled={isFinished || isThinking}
          rows={3}
          className="w-full px-4 py-3 rounded-xl border-2 border-border bg-white text-navy text-base focus:border-teal focus:outline-none resize-none disabled:bg-navy/5"
        />
        <div className="flex items-center justify-between mt-2">
          <p className="text-xs text-navy/50">
            User turns so far: {userTurns} / {scenario.target_exchanges}
            {isFinished && " · complete"}
          </p>
          <button
            type="button"
            onClick={sendTurn}
            disabled={isFinished || isThinking || input.trim().length === 0}
            className="px-5 py-2 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors disabled:opacity-40 disabled:cursor-not-allowed"
          >
            Send reply
          </button>
        </div>
        {error && (
          <p className="mt-2 text-xs text-red-600">{error}</p>
        )}
      </div>

      <NavFooter
        onPrev={onPrev}
        onNext={onNext}
        nextLabel={
          stepIdx === totalRoleplays - 1 ? "Continue to writing" : "Next roleplay"
        }
      />
      {!isFinished && (
        <p className="mt-3 text-center text-xs text-navy/50">
          You can keep going or click {stepIdx === totalRoleplays - 1 ? "“Continue to writing”" : "“Next roleplay”"} when you have finished this conversation. Incomplete roleplays are graded on what you said.
        </p>
      )}
    </>
  );
}

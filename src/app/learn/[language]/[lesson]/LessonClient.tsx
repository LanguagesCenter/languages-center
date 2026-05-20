"use client";

import { useMemo, useState, useTransition } from "react";
import Link from "next/link";
import type { DbExercise, DbLesson } from "@/lib/learn";
import { completeLesson } from "@/lib/learn-actions";

interface Props {
  languageSlug: string;
  languageName: string;
  lesson: DbLesson;
  exercises: DbExercise[];
}

const ENCOURAGEMENTS_RIGHT = ["Nice!", "Great job!", "You're on fire!", "Brilliant!", "Sí, sí, sí!"];
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
          if (isCorrect) {
            stateCls = "border-teal bg-teal-light text-teal-dark";
          } else if (isPicked) {
            stateCls = "border-red-300 bg-red-50 text-red-700";
          } else {
            stateCls = "border-border bg-white text-navy/40";
          }
        }
        return (
          <button
            key={opt}
            type="button"
            disabled={disabled}
            onClick={() => onAnswer(opt)}
            className={`w-full py-4 px-5 rounded-xl border-2 text-left font-medium transition-all ${stateCls}`}
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
    pickedAnswer?.toLowerCase().trim() === exercise.correct_answer.toLowerCase().trim();

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
  const pairs = useMemo(() => {
    return exercise.correct_answer.split("|").map((entry) => {
      const [left, right] = entry.split(":");
      return { left: left ?? "", right: right ?? "" };
    });
  }, [exercise.correct_answer]);

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
      if (Object.keys(next).length === pairs.length) {
        onAnswer("matched");
      }
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

export default function LessonClient({
  languageSlug,
  languageName,
  lesson,
  exercises,
}: Props) {
  const [pending, startTransition] = useTransition();
  const [step, setStep] = useState(0);
  const [pickedAnswer, setPickedAnswer] = useState<string | null>(null);
  const [showFeedback, setShowFeedback] = useState(false);
  const [wasCorrect, setWasCorrect] = useState(false);
  const [completion, setCompletion] = useState<{
    xp_earned: number;
    already_completed: boolean;
    current_streak?: number;
  } | null>(null);

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
    const correct =
      exercise.type === "matching"
        ? true
        : answer.toLowerCase().trim() === exercise.correct_answer.toLowerCase().trim();
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
      const result = await completeLesson(lesson.id, languageSlug);
      if (result.ok) {
        setCompletion({
          xp_earned: result.xp_earned,
          already_completed: result.already_completed,
          current_streak: result.current_streak,
        });
      }
    });
  }

  if (completion) {
    return (
      <main className="min-h-screen bg-gradient-to-b from-teal-light to-background flex items-center justify-center p-6">
        <div className="bg-white rounded-3xl border border-border p-8 sm:p-12 text-center max-w-md w-full shadow-xl">
          <div className="w-20 h-20 mx-auto mb-6 rounded-full bg-gradient-to-br from-teal to-teal-dark flex items-center justify-center shadow-lg">
            <svg className="w-12 h-12 text-white" fill="none" stroke="currentColor" strokeWidth={3} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
            </svg>
          </div>
          <h1 className="text-3xl font-bold text-navy mb-2">Lesson complete!</h1>
          <p className="text-sm text-navy/60 mb-8">
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

          <div className="flex flex-col gap-2">
            <Link
              href={`/learn/${languageSlug}`}
              className="block py-3 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors"
            >
              Continue learning
            </Link>
            <Link
              href="/dashboard"
              className="block py-3 text-sm font-medium text-navy/60 hover:text-teal transition-colors"
            >
              View dashboard
            </Link>
          </div>
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
        {exercise.translation && (
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
              <p
                className={`text-lg font-bold ${
                  wasCorrect ? "text-teal-dark" : "text-red-700"
                }`}
              >
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

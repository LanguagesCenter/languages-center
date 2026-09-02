"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import type {
  LessonContent,
  LessonSection,
  SceneSection,
  SignSection,
  PhrasesSection,
  DialogueSection,
  QuizSection,
  SignWord,
  Phrase,
  DialogueLine,
  QuizQuestion,
} from "@/lib/traveler";
import { markLessonComplete } from "@/app/learn/[language]/travel/[city]/[lesson]/actions";

// ============================================================
// Audio helper — leans on the browser's SpeechSynthesis API so we
// can play native-accent Spanish (es-ES) or French (fr-FR) without
// hosting per-phrase audio files.
// ============================================================

function speak(text: string, lang: string) {
  if (typeof window === "undefined" || !window.speechSynthesis) return;
  window.speechSynthesis.cancel();
  const utterance = new SpeechSynthesisUtterance(text);
  utterance.lang = lang;
  utterance.rate = 0.9;
  window.speechSynthesis.speak(utterance);
}

// ============================================================
// Section pickers
// ============================================================

function pickSection<T extends LessonSection>(
  sections: LessonSection[],
  kind: T["kind"],
): T | undefined {
  return sections.find((s) => s.kind === kind) as T | undefined;
}

// ============================================================
// Main runner
// ============================================================

export default function TravelerLessonRunner({
  languageSlug,
  citySlug,
  content,
  speechLang,
  isPremium,
}: {
  languageSlug: string;
  citySlug: string;
  content: LessonContent;
  speechLang: string;
  isPremium: boolean;
}) {
  const { lesson, courseCity, sections, nextLesson } = content;

  const scene = pickSection<SceneSection>(sections, "scene");
  const sign = pickSection<SignSection>(sections, "sign");
  const phrases = pickSection<PhrasesSection>(sections, "phrases");
  const dialogue = pickSection<DialogueSection>(sections, "dialogue");
  const quiz = pickSection<QuizSection>(sections, "quiz");

  const hasAnyContent =
    !!scene || !!sign || !!phrases || !!dialogue || !!quiz;

  // Quiz state
  const [quizScore, setQuizScore] = useState(0);
  const [quizComplete, setQuizComplete] = useState(false);
  const [xpEarned, setXpEarned] = useState<number | null>(null);
  const [saving, setSaving] = useState(false);
  const [saveError, setSaveError] = useState<string | null>(null);

  async function handleQuizFinished(score: number) {
    setQuizScore(score);
    setQuizComplete(true);
    setSaving(true);
    setSaveError(null);
    try {
      const earned = await markLessonComplete(lesson.id);
      setXpEarned(earned);
    } catch (err) {
      setSaveError(
        err instanceof Error ? err.message : "Could not save progress",
      );
    } finally {
      setSaving(false);
    }
  }

  // No content authored yet — show a graceful "coming soon" panel
  // instead of an empty screen.
  if (!hasAnyContent) {
    return (
      <section className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 pt-4 pb-16">
        <TravelStamp title={courseCity} sublabel={lesson.locationName} />
        <h1 className="text-3xl sm:text-4xl font-bold text-navy tracking-tight mt-6">
          {lesson.orderIndex}. {lesson.title}
        </h1>
        <p className="text-sm text-navy/60 mt-1.5">{lesson.locationName}</p>
        <div className="mt-8 rounded-2xl border border-dashed border-amber-300 bg-amber-50/60 p-8 text-center">
          <p className="text-4xl mb-3" aria-hidden>
            🧳
          </p>
          <h2 className="text-lg font-bold text-amber-950 mb-1">
            This stop is being written
          </h2>
          <p className="text-sm text-amber-900/80 max-w-md mx-auto">
            The immersive scene, sign analysis, phrase deck, dialogue, and
            exercises for this lesson are being authored. Check back soon.
          </p>
          <Link
            href={`/learn/${languageSlug}/travel/${citySlug}`}
            className="mt-6 inline-flex items-center gap-1.5 px-4 py-2 text-sm font-semibold text-white bg-teal rounded-full hover:bg-teal-dark transition-colors"
          >
            Back to {courseCity}
          </Link>
        </div>
      </section>
    );
  }

  return (
    <>
      {scene && (
        <SceneSetter
          scene={scene}
          city={courseCity}
          lessonTitle={lesson.title}
          lessonNumber={lesson.orderIndex}
          locationName={lesson.locationName}
        />
      )}

      <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 pb-16 space-y-10 sm:space-y-14">
        {sign && (
          <SectionShell number={1} label="Sign & vocabulary">
            <SignBlock sign={sign} speechLang={speechLang} />
          </SectionShell>
        )}

        {phrases && phrases.phrases.length > 0 && (
          <SectionShell number={2} label="Key phrases">
            {phrases.grammarNote && (
              <div className="mb-4 rounded-xl border border-amber-200 bg-amber-50/70 p-3 sm:p-4">
                <p className="text-[10px] font-bold uppercase tracking-wider text-amber-800 mb-1">
                  Grammar note
                </p>
                <p className="text-sm text-amber-950 leading-relaxed">
                  {phrases.grammarNote}
                </p>
              </div>
            )}
            <PhraseDeck phrases={phrases.phrases} speechLang={speechLang} />
          </SectionShell>
        )}

        {dialogue && dialogue.lines.length > 0 && (
          <SectionShell number={3} label="Realistic dialogue">
            <DialogueBlock
              lines={dialogue.lines}
              speechLang={speechLang}
            />
          </SectionShell>
        )}

        {quiz && quiz.questions.length > 0 && !quizComplete && (
          <SectionShell number={4} label="Quick exercises">
            <QuizBlock
              questions={quiz.questions}
              speechLang={speechLang}
              onFinished={handleQuizFinished}
            />
          </SectionShell>
        )}

        {quizComplete && (
          <CompletionCard
            city={courseCity}
            lessonTitle={lesson.title}
            xpTotal={lesson.xpReward}
            xpEarned={xpEarned}
            saving={saving}
            saveError={saveError}
            score={quizScore}
            totalQuestions={quiz?.questions.length ?? 0}
            nextLesson={nextLesson}
            languageSlug={languageSlug}
            citySlug={citySlug}
            isPremium={isPremium}
          />
        )}
      </div>
    </>
  );
}

// ============================================================
// Shared building blocks
// ============================================================

function TravelStamp({
  title,
  sublabel,
}: {
  title: string;
  sublabel?: string | null;
}) {
  return (
    <div className="inline-block -rotate-3">
      <div className="border-[3px] border-red-700/70 text-red-800 px-3 py-1.5 rounded-md font-black uppercase tracking-widest text-xs sm:text-sm bg-red-50/40">
        {title}
        {sublabel && (
          <div className="text-[9px] sm:text-[10px] font-semibold tracking-wider text-red-800/80 mt-0.5">
            {sublabel}
          </div>
        )}
      </div>
    </div>
  );
}

function SectionShell({
  number,
  label,
  children,
}: {
  number: number;
  label: string;
  children: React.ReactNode;
}) {
  return (
    <section>
      <div className="flex items-center gap-3 mb-4">
        <span className="inline-flex items-center justify-center w-8 h-8 rounded-full bg-amber-100 text-amber-900 font-bold text-sm ring-2 ring-amber-200">
          {number}
        </span>
        <p className="text-xs font-bold uppercase tracking-[0.16em] text-amber-900/80">
          {label}
        </p>
      </div>
      {children}
    </section>
  );
}

// ============================================================
// Scene setter
// ============================================================

function SceneSetter({
  scene,
  city,
  lessonTitle,
  lessonNumber,
  locationName,
}: {
  scene: SceneSection;
  city: string;
  lessonTitle: string;
  lessonNumber: number;
  locationName: string;
}) {
  return (
    <section className="relative">
      <div className="relative w-full h-72 sm:h-96 lg:h-[460px] bg-navy overflow-hidden">
        {scene.imageUrl && (
          <Image
            src={scene.imageUrl}
            alt={scene.imageAlt ?? `${city} scene`}
            fill
            sizes="100vw"
            className="object-cover"
            priority
            unoptimized
          />
        )}
        <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/25 to-transparent" />
        <div className="absolute inset-x-0 bottom-0">
          <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 pb-6 sm:pb-10">
            <div className="mb-4">
              <TravelStamp
                title={scene.stamp ?? city}
                sublabel={scene.stampSublabel ?? locationName}
              />
            </div>
            <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-white/80">
              {city} · Lesson {lessonNumber}
            </p>
            <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-white tracking-tight mt-1 drop-shadow-sm">
              {lessonTitle}
            </h1>
          </div>
        </div>
      </div>

      {scene.description && (
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 pt-6">
          <div className="rounded-2xl border border-amber-200 bg-gradient-to-br from-amber-50 to-orange-50/60 p-5 sm:p-6 shadow-sm">
            <p
              className="text-sm sm:text-base text-navy/85 leading-relaxed"
              dangerouslySetInnerHTML={{ __html: renderInlineMarkdown(scene.description) }}
            />
          </div>
        </div>
      )}
    </section>
  );
}

// Minimal markdown-ish inline renderer for **bold** and *italic*.
// Keeps the DB payload readable while still letting authors emphasize
// place names. We escape everything else first to avoid HTML injection.
function renderInlineMarkdown(input: string): string {
  const escape = (s: string) =>
    s
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;");
  const escaped = escape(input);
  return escaped
    .replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>")
    .replace(/\*(.+?)\*/g, "<em>$1</em>")
    .replace(/\n/g, "<br />");
}

// ============================================================
// Sign / image analysis
// ============================================================

const SIGN_STYLES: Record<
  SignSection["style"],
  { wrapper: string; title: string; subtitle: string; word: string }
> = {
  airport_blue: {
    wrapper:
      "bg-gradient-to-br from-blue-800 to-blue-950 text-white ring-2 ring-blue-900/40 border-4 border-blue-900/20",
    title: "font-black tracking-widest text-3xl sm:text-4xl",
    subtitle: "text-blue-200 tracking-wider text-xs sm:text-sm",
    word: "bg-blue-700/60 hover:bg-blue-600/80 text-white ring-1 ring-blue-300/30",
  },
  menu_card: {
    wrapper:
      "bg-gradient-to-br from-amber-50 to-orange-100 text-amber-950 ring-1 ring-amber-300 border-4 border-amber-200",
    title: "font-serif italic text-3xl sm:text-4xl",
    subtitle: "text-amber-800/70 italic text-xs sm:text-sm",
    word: "bg-amber-200/60 hover:bg-amber-300/80 text-amber-950 ring-1 ring-amber-300",
  },
  street: {
    wrapper:
      "bg-gradient-to-br from-emerald-700 to-emerald-900 text-white ring-2 ring-emerald-900/40 border-4 border-white/20",
    title: "font-bold tracking-wide text-2xl sm:text-3xl uppercase",
    subtitle: "text-emerald-200 tracking-wider text-xs sm:text-sm",
    word: "bg-emerald-600/60 hover:bg-emerald-500/80 text-white ring-1 ring-emerald-200/30",
  },
  notice: {
    wrapper:
      "bg-stone-50 text-stone-900 ring-1 ring-stone-300 border-4 border-stone-200 shadow-[0_2px_0_rgba(0,0,0,0.06)]",
    title: "font-bold text-2xl sm:text-3xl",
    subtitle: "text-stone-500 tracking-wide text-xs sm:text-sm",
    word: "bg-stone-200 hover:bg-stone-300 text-stone-900 ring-1 ring-stone-300",
  },
  neon: {
    wrapper:
      "bg-neutral-900 text-pink-300 ring-2 ring-pink-500/40 border-4 border-pink-400/20 shadow-[0_0_40px_rgba(236,72,153,0.35)]",
    title:
      "font-black text-3xl sm:text-4xl uppercase tracking-widest text-pink-300 drop-shadow-[0_0_8px_rgba(236,72,153,0.9)]",
    subtitle:
      "text-pink-200 tracking-widest text-xs sm:text-sm uppercase drop-shadow-[0_0_6px_rgba(236,72,153,0.7)]",
    word: "bg-pink-900/40 hover:bg-pink-800/60 text-pink-100 ring-1 ring-pink-400/30",
  },
};

function SignBlock({
  sign,
  speechLang,
}: {
  sign: SignSection;
  speechLang: string;
}) {
  const styles = SIGN_STYLES[sign.style];
  const [active, setActive] = useState<SignWord | null>(null);

  return (
    <div>
      {sign.imageUrl && (
        <div className="relative w-full h-48 sm:h-64 rounded-2xl overflow-hidden mb-4 ring-1 ring-black/5">
          <Image
            src={sign.imageUrl}
            alt={sign.imageAlt ?? sign.title}
            fill
            sizes="(min-width: 640px) 640px, 100vw"
            className="object-cover"
            unoptimized
          />
        </div>
      )}

      <div
        className={`${styles.wrapper} rounded-2xl p-5 sm:p-8 text-center`}
      >
        {sign.icon && (
          <p className="text-2xl sm:text-3xl opacity-80 mb-2" aria-hidden>
            {sign.icon}
          </p>
        )}
        <h3 className={styles.title}>{sign.title}</h3>
        {sign.subtitle && (
          <p className={`mt-1 ${styles.subtitle}`}>{sign.subtitle}</p>
        )}
      </div>

      {sign.note && (
        <p className="text-xs text-navy/50 italic mt-2 text-center">
          {sign.note}
        </p>
      )}

      <div className="mt-5">
        <p className="text-xs font-semibold uppercase tracking-wider text-navy/50 mb-2">
          Tap a word to decode it
        </p>
        <div className="flex flex-wrap gap-2">
          {sign.words.map((word, i) => (
            <button
              key={`${word.text}-${i}`}
              type="button"
              onClick={() => setActive(word)}
              className={`${styles.word} inline-flex items-center gap-1 rounded-lg px-3 py-1.5 text-sm font-bold transition-colors`}
            >
              {word.text}
            </button>
          ))}
        </div>
      </div>

      {active && (
        <div className="mt-4 rounded-xl border border-amber-200 bg-amber-50/70 p-4 shadow-sm">
          <div className="flex items-start justify-between gap-3">
            <div className="min-w-0">
              <p className="text-lg font-bold text-navy break-words">
                {active.text}
              </p>
              {active.phonetic && (
                <p className="text-xs text-navy/60 italic mt-0.5">
                  {active.phonetic}
                </p>
              )}
              {active.english && (
                <p className="text-sm text-navy/80 mt-1.5">
                  <span className="font-semibold text-navy/60">→ </span>
                  {active.english}
                </p>
              )}
              {active.tip && (
                <p className="text-xs text-amber-900/80 mt-2 leading-relaxed">
                  <span className="font-bold uppercase tracking-wider text-amber-800">
                    Memory tip:{" "}
                  </span>
                  {active.tip}
                </p>
              )}
            </div>
            <div className="flex items-center gap-1.5 shrink-0">
              <button
                type="button"
                onClick={() => speak(active.text, speechLang)}
                aria-label="Play word"
                className="w-8 h-8 rounded-full bg-teal text-white flex items-center justify-center hover:bg-teal-dark transition-colors"
              >
                <svg
                  className="w-4 h-4"
                  fill="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path d="M8 5v14l11-7z" />
                </svg>
              </button>
              <button
                type="button"
                onClick={() => setActive(null)}
                aria-label="Close"
                className="w-8 h-8 rounded-full bg-navy/5 text-navy/60 flex items-center justify-center hover:bg-navy/10 transition-colors"
              >
                <svg
                  className="w-4 h-4"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth={2}
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// ============================================================
// Phrase deck
// ============================================================

function PhraseDeck({
  phrases,
  speechLang,
}: {
  phrases: Phrase[];
  speechLang: string;
}) {
  return (
    <div className="grid gap-3">
      {phrases.map((p, i) => (
        <PhraseCard key={`${p.phrase}-${i}`} phrase={p} speechLang={speechLang} />
      ))}
    </div>
  );
}

function PhraseCard({
  phrase,
  speechLang,
}: {
  phrase: Phrase;
  speechLang: string;
}) {
  const [showTip, setShowTip] = useState(false);
  return (
    <div className="rounded-2xl border border-border bg-white p-4 sm:p-5 hover:border-amber-300 transition-colors">
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0">
          <p className="text-base sm:text-lg font-bold text-navy">
            {phrase.phrase}
          </p>
          {phrase.phonetic && (
            <p className="text-xs sm:text-sm text-navy/50 italic mt-0.5">
              [{phrase.phonetic}]
            </p>
          )}
          {phrase.english && (
            <p className="text-sm text-navy/80 mt-2">
              <span className="text-navy/50 font-semibold">→ </span>
              {phrase.english}
            </p>
          )}
        </div>
        <button
          type="button"
          onClick={() => speak(phrase.phrase, speechLang)}
          aria-label={`Play ${phrase.phrase}`}
          className="shrink-0 inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-bold text-white bg-teal rounded-full hover:bg-teal-dark transition-colors"
        >
          <svg className="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 24 24">
            <path d="M8 5v14l11-7z" />
          </svg>
          Listen
        </button>
      </div>

      {(phrase.tip || phrase.grammar) && (
        <>
          <button
            type="button"
            onClick={() => setShowTip((v) => !v)}
            className="mt-3 text-xs font-semibold text-amber-800 hover:text-amber-900 inline-flex items-center gap-1"
          >
            {showTip ? "Hide" : "Show"} tips
            <svg
              className={`w-3 h-3 transition-transform ${showTip ? "rotate-180" : ""}`}
              fill="none"
              stroke="currentColor"
              strokeWidth={2.5}
              viewBox="0 0 24 24"
            >
              <path strokeLinecap="round" strokeLinejoin="round" d="M19 9l-7 7-7-7" />
            </svg>
          </button>
          {showTip && (
            <div className="mt-2 rounded-lg bg-amber-50/70 border border-amber-200 p-3 space-y-1.5">
              {phrase.tip && (
                <p className="text-xs text-amber-900/90 leading-relaxed">
                  <span className="font-bold uppercase tracking-wider text-amber-800">
                    Memory trick:{" "}
                  </span>
                  {phrase.tip}
                </p>
              )}
              {phrase.grammar && (
                <p className="text-xs text-amber-900/90 leading-relaxed">
                  <span className="font-bold uppercase tracking-wider text-amber-800">
                    Grammar note:{" "}
                  </span>
                  {phrase.grammar}
                </p>
              )}
            </div>
          )}
        </>
      )}
    </div>
  );
}

// ============================================================
// Dialogue
// ============================================================

function DialogueBlock({
  lines,
  speechLang,
}: {
  lines: DialogueLine[];
  speechLang: string;
}) {
  const [revealed, setRevealed] = useState<Set<number>>(new Set());
  const [playing, setPlaying] = useState(false);
  const cancelRef = useRef(false);

  const toggle = (i: number) => {
    setRevealed((prev) => {
      const next = new Set(prev);
      if (next.has(i)) next.delete(i);
      else next.add(i);
      return next;
    });
  };

  async function playAll() {
    if (playing) {
      // Cancel in-flight playback
      cancelRef.current = true;
      window.speechSynthesis?.cancel();
      setPlaying(false);
      return;
    }
    setPlaying(true);
    cancelRef.current = false;
    for (let i = 0; i < lines.length; i++) {
      if (cancelRef.current) break;
      await new Promise<void>((resolve) => {
        const u = new SpeechSynthesisUtterance(lines[i].target);
        u.lang = speechLang;
        u.rate = 0.9;
        u.onend = () => resolve();
        u.onerror = () => resolve();
        window.speechSynthesis.speak(u);
      });
      // brief pause between lines
      await new Promise((r) => setTimeout(r, 200));
    }
    setPlaying(false);
  }

  useEffect(() => {
    return () => {
      cancelRef.current = true;
      window.speechSynthesis?.cancel();
    };
  }, []);

  return (
    <div className="rounded-2xl border border-border bg-white shadow-sm overflow-hidden">
      <div className="flex items-center justify-between px-4 sm:px-5 py-3 border-b border-border bg-navy/[0.03]">
        <p className="text-xs font-bold uppercase tracking-wider text-navy/60">
          Tap a line to reveal the translation
        </p>
        <button
          type="button"
          onClick={playAll}
          className="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-bold text-white bg-teal rounded-full hover:bg-teal-dark transition-colors"
        >
          {playing ? (
            <>
              <svg className="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 24 24">
                <path d="M6 6h12v12H6z" />
              </svg>
              Stop
            </>
          ) : (
            <>
              <svg className="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 24 24">
                <path d="M8 5v14l11-7z" />
              </svg>
              Play all
            </>
          )}
        </button>
      </div>
      <ul className="divide-y divide-border">
        {lines.map((line, i) => {
          const isYou = /you/i.test(line.speaker);
          return (
            <li
              key={i}
              className={`px-4 sm:px-5 py-3 flex ${isYou ? "justify-end" : "justify-start"}`}
            >
              <div
                className={`max-w-[85%] rounded-2xl px-4 py-2.5 ${
                  isYou
                    ? "bg-teal text-white rounded-br-sm"
                    : "bg-navy/[0.06] text-navy rounded-bl-sm"
                }`}
              >
                <p
                  className={`text-[10px] font-bold uppercase tracking-wider mb-0.5 ${
                    isYou ? "text-white/75" : "text-navy/50"
                  }`}
                >
                  {line.speaker}
                </p>
                <p className="text-sm sm:text-base font-medium leading-snug">
                  {line.target}
                </p>
                <div className="flex items-center gap-2 mt-1.5">
                  <button
                    type="button"
                    onClick={() => speak(line.target, speechLang)}
                    aria-label="Play line"
                    className={`inline-flex items-center gap-1 text-[11px] font-bold ${
                      isYou
                        ? "text-white/85 hover:text-white"
                        : "text-teal-dark hover:text-teal"
                    }`}
                  >
                    <svg className="w-3 h-3" fill="currentColor" viewBox="0 0 24 24">
                      <path d="M8 5v14l11-7z" />
                    </svg>
                    Play
                  </button>
                  <button
                    type="button"
                    onClick={() => toggle(i)}
                    className={`inline-flex items-center gap-1 text-[11px] font-bold ${
                      isYou
                        ? "text-white/85 hover:text-white"
                        : "text-teal-dark hover:text-teal"
                    }`}
                  >
                    {revealed.has(i) ? "Hide" : "Translate"}
                  </button>
                </div>
                {revealed.has(i) && (
                  <p
                    className={`text-xs mt-1.5 italic ${
                      isYou ? "text-white/90" : "text-navy/70"
                    }`}
                  >
                    {line.english}
                  </p>
                )}
              </div>
            </li>
          );
        })}
      </ul>
    </div>
  );
}

// ============================================================
// Quiz — 4 exercises, immediate feedback, running score
// ============================================================

interface QuizChoice {
  text: string;
  correct: boolean;
}

function QuizBlock({
  questions,
  speechLang,
  onFinished,
}: {
  questions: QuizQuestion[];
  speechLang: string;
  onFinished: (score: number) => void;
}) {
  const [index, setIndex] = useState(0);
  const [score, setScore] = useState(0);
  const [answer, setAnswer] = useState<string | null>(null);
  const [textInput, setTextInput] = useState("");
  const [committed, setCommitted] = useState(false);

  const q = questions[index];
  const total = questions.length;

  // Shuffle choices once per question (stable across renders while on
  // that question so the correct one doesn't hop around after you
  // tap).
  const choices = useMemo<QuizChoice[]>(() => {
    if (q.type === "fill_blank") return [];
    const items: QuizChoice[] = [
      { text: q.correctAnswer, correct: true },
      ...q.wrongAnswers.map((w) => ({ text: w, correct: false })),
    ];
    // Simple Fisher-Yates
    for (let i = items.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [items[i], items[j]] = [items[j], items[i]];
    }
    return items;
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [index, q.correctAnswer, q.type]);

  function commitChoice(text: string) {
    if (committed) return;
    setAnswer(text);
    setCommitted(true);
    if (text.trim().toLowerCase() === q.correctAnswer.trim().toLowerCase()) {
      setScore((s) => s + 1);
    }
  }

  function submitTextAnswer() {
    if (committed || textInput.trim().length === 0) return;
    commitChoice(textInput);
  }

  function next() {
    if (index + 1 >= total) {
      onFinished(score);
      return;
    }
    setIndex((i) => i + 1);
    setAnswer(null);
    setTextInput("");
    setCommitted(false);
  }

  const correct =
    committed && answer?.trim().toLowerCase() === q.correctAnswer.trim().toLowerCase();

  return (
    <div className="rounded-2xl border border-border bg-white p-5 sm:p-6 shadow-sm">
      <div className="flex items-center justify-between mb-3">
        <p className="text-xs font-bold uppercase tracking-wider text-navy/50">
          Question {index + 1} of {total}
        </p>
        <p className="text-xs font-bold text-teal-dark">
          {score} / {total}
        </p>
      </div>

      <div className="w-full h-1.5 bg-navy/5 rounded-full overflow-hidden mb-5">
        <div
          className="h-full bg-teal transition-all duration-300"
          style={{ width: `${((index + (committed ? 1 : 0)) / total) * 100}%` }}
        />
      </div>

      {q.type === "listening" && q.audioPrompt && (
        <div className="mb-4">
          <button
            type="button"
            onClick={() => speak(q.audioPrompt!, speechLang)}
            className="inline-flex items-center gap-2 px-4 py-2.5 text-sm font-bold text-white bg-teal rounded-full hover:bg-teal-dark transition-colors"
          >
            <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
              <path d="M8 5v14l11-7z" />
            </svg>
            Listen again
          </button>
          <p className="text-xs text-navy/50 mt-2 italic">
            Tap to hear the phrase in {speechLang.startsWith("es") ? "Spanish" : "French"}
          </p>
        </div>
      )}

      <p className="text-base sm:text-lg font-bold text-navy leading-snug mb-4">
        {q.question}
      </p>

      {q.type === "fill_blank" ? (
        <div>
          <input
            type="text"
            value={textInput}
            onChange={(e) => setTextInput(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter" && !committed) submitTextAnswer();
            }}
            disabled={committed}
            placeholder="Type your answer…"
            className="w-full rounded-xl border border-border bg-white px-4 py-3 text-base focus:outline-none focus:ring-2 focus:ring-teal focus:border-transparent disabled:bg-navy/[0.03]"
            autoFocus
          />
          {!committed && (
            <button
              type="button"
              onClick={submitTextAnswer}
              disabled={textInput.trim().length === 0}
              className="mt-3 inline-flex items-center gap-1.5 px-4 py-2 text-sm font-bold text-white bg-teal rounded-full hover:bg-teal-dark disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              Check answer
            </button>
          )}
        </div>
      ) : (
        <div className="grid gap-2">
          {choices.map((c) => {
            const isChosen = answer === c.text;
            const showCorrect = committed && c.correct;
            const showWrong = committed && isChosen && !c.correct;
            return (
              <button
                key={c.text}
                type="button"
                onClick={() => commitChoice(c.text)}
                disabled={committed}
                className={`text-left rounded-xl border-2 px-4 py-3 text-sm sm:text-base font-medium transition-all ${
                  showCorrect
                    ? "border-emerald-400 bg-emerald-50 text-emerald-900"
                    : showWrong
                    ? "border-red-400 bg-red-50 text-red-900"
                    : committed
                    ? "border-border bg-white text-navy/60"
                    : "border-border bg-white text-navy hover:border-teal/40 hover:bg-teal-light/30"
                }`}
              >
                <div className="flex items-center justify-between gap-2">
                  <span>{c.text}</span>
                  {showCorrect && (
                    <svg
                      className="w-5 h-5 shrink-0"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth={3}
                      viewBox="0 0 24 24"
                    >
                      <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                    </svg>
                  )}
                  {showWrong && (
                    <svg
                      className="w-5 h-5 shrink-0"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth={3}
                      viewBox="0 0 24 24"
                    >
                      <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                  )}
                </div>
              </button>
            );
          })}
        </div>
      )}

      {committed && (
        <div
          className={`mt-4 rounded-xl p-4 ${
            correct
              ? "bg-emerald-50 border border-emerald-200"
              : "bg-red-50 border border-red-200"
          }`}
        >
          <p
            className={`text-sm font-bold ${
              correct ? "text-emerald-800" : "text-red-800"
            }`}
          >
            {correct ? "Correct!" : `Not quite — the answer is "${q.correctAnswer}"`}
          </p>
          {q.translation && (
            <p className="text-xs text-navy/60 mt-1">
              <span className="font-semibold">Meaning: </span>
              {q.translation}
            </p>
          )}
          <button
            type="button"
            onClick={next}
            className="mt-3 inline-flex items-center gap-1.5 px-4 py-2 text-sm font-bold text-white bg-teal rounded-full hover:bg-teal-dark transition-colors"
          >
            {index + 1 >= total ? "Finish lesson" : "Next question"}
            <svg
              className="w-3.5 h-3.5"
              fill="none"
              stroke="currentColor"
              strokeWidth={2.5}
              viewBox="0 0 24 24"
            >
              <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
            </svg>
          </button>
        </div>
      )}
    </div>
  );
}

// ============================================================
// Completion card
// ============================================================

function CompletionCard({
  city,
  lessonTitle,
  xpTotal,
  xpEarned,
  saving,
  saveError,
  score,
  totalQuestions,
  nextLesson,
  languageSlug,
  citySlug,
  isPremium,
}: {
  city: string;
  lessonTitle: string;
  xpTotal: number;
  xpEarned: number | null;
  saving: boolean;
  saveError: string | null;
  score: number;
  totalQuestions: number;
  nextLesson: LessonContent["nextLesson"];
  languageSlug: string;
  citySlug: string;
  isPremium: boolean;
}) {
  const alreadyDone = xpEarned === 0;
  const nextLocked = nextLesson?.isPremium && !isPremium;

  return (
    <section className="rounded-3xl border-2 border-amber-300 bg-gradient-to-br from-amber-50 via-orange-50 to-white p-6 sm:p-8 shadow-lg text-center">
      <div className="flex justify-center mb-4">
        <div className="rotate-3">
          <TravelStamp title="Complete" sublabel={city} />
        </div>
      </div>
      <h2 className="text-2xl sm:text-3xl font-bold text-navy tracking-tight">
        {lessonTitle} — done!
      </h2>
      <p className="text-sm text-navy/60 mt-1">
        {score} / {totalQuestions} correct
      </p>

      <div className="mt-6 inline-flex items-center gap-2 px-4 py-2 rounded-full bg-teal text-white text-sm font-bold shadow">
        <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
          <path d="M12 2l2.4 7.4H22l-6.2 4.5 2.4 7.4L12 16.9 5.8 21.3l2.4-7.4L2 9.4h7.6z" />
        </svg>
        {saving
          ? "Saving…"
          : alreadyDone
          ? "Already completed"
          : `+${xpEarned ?? xpTotal} XP earned`}
      </div>

      {saveError && (
        <p className="text-xs text-red-700 mt-2">{saveError}</p>
      )}

      {nextLesson ? (
        <div className="mt-8">
          <p className="text-xs font-bold uppercase tracking-widest text-navy/50 mb-2">
            Next stop
          </p>
          <div className="rounded-2xl border border-border bg-white p-4 sm:p-5 text-left flex items-center gap-4">
            <div className="shrink-0 w-11 h-11 rounded-xl bg-gradient-to-br from-orange-500 to-red-600 text-white flex items-center justify-center shadow">
              <svg
                className="w-5 h-5"
                fill="none"
                stroke="currentColor"
                strokeWidth={2}
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M17.657 16.657L13.414 20.9a2 2 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"
                />
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"
                />
              </svg>
            </div>
            <div className="min-w-0 flex-1">
              <p className="text-sm font-bold text-navy leading-tight">
                {nextLesson.orderIndex}. {nextLesson.title}
              </p>
              <p className="text-xs text-navy/50 mt-0.5">
                {nextLesson.locationName}
              </p>
            </div>
            {nextLocked && (
              <span className="shrink-0 text-[10px] font-bold uppercase tracking-wider text-amber-800 bg-amber-100 border border-amber-300 rounded-full px-2 py-0.5">
                Premium
              </span>
            )}
          </div>

          {nextLocked ? (
            <div className="mt-5 flex flex-col sm:flex-row gap-3 justify-center">
              <Link
                href="/pricing"
                className="inline-flex items-center justify-center gap-1.5 px-5 py-3 text-sm font-bold text-white bg-amber-600 rounded-full hover:bg-amber-700 shadow-md transition-all"
              >
                Upgrade to continue
                <svg
                  className="w-3.5 h-3.5"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth={2.5}
                  viewBox="0 0 24 24"
                >
                  <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
                </svg>
              </Link>
              <Link
                href={`/learn/${languageSlug}/travel/${citySlug}`}
                className="inline-flex items-center justify-center gap-1.5 px-5 py-3 text-sm font-bold text-teal-dark bg-white border border-border rounded-full hover:border-teal/40 transition-colors"
              >
                Back to journey
              </Link>
            </div>
          ) : (
            <div className="mt-5 flex flex-col sm:flex-row gap-3 justify-center">
              <Link
                href={`/learn/${languageSlug}/travel/${citySlug}/${nextLesson.id}`}
                className="inline-flex items-center justify-center gap-1.5 px-5 py-3 text-sm font-bold text-white bg-teal rounded-full hover:bg-teal-dark shadow-md transition-all"
              >
                Continue Journey
                <svg
                  className="w-3.5 h-3.5"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth={2.5}
                  viewBox="0 0 24 24"
                >
                  <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
                </svg>
              </Link>
              <Link
                href={`/learn/${languageSlug}/travel/${citySlug}`}
                className="inline-flex items-center justify-center gap-1.5 px-5 py-3 text-sm font-bold text-teal-dark bg-white border border-border rounded-full hover:border-teal/40 transition-colors"
              >
                Back to journey
              </Link>
            </div>
          )}
        </div>
      ) : (
        <div className="mt-8">
          <p className="text-sm text-navy/70">
            You&rsquo;ve reached the final stop of the {city} journey. 🎉
          </p>
          <Link
            href={`/learn/${languageSlug}/travel`}
            className="mt-5 inline-flex items-center justify-center gap-1.5 px-5 py-3 text-sm font-bold text-white bg-teal rounded-full hover:bg-teal-dark shadow-md transition-all"
          >
            Pick your next city
            <svg
              className="w-3.5 h-3.5"
              fill="none"
              stroke="currentColor"
              strokeWidth={2.5}
              viewBox="0 0 24 24"
            >
              <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
            </svg>
          </Link>
        </div>
      )}
    </section>
  );
}

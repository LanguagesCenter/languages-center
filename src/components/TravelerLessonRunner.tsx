"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
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
// Speech / audio primitives
// ============================================================

// Chrome loads voices asynchronously and fires 'voiceschanged' when
// the list is ready. Safari + Firefox return voices synchronously.
// This hook returns the best-matching voice for the requested lang
// tag (e.g. "es-ES" or "fr-FR") once available.
function useSpeechVoice(lang: string): SpeechSynthesisVoice | null {
  const [voice, setVoice] = useState<SpeechSynthesisVoice | null>(null);

  useEffect(() => {
    if (typeof window === "undefined" || !window.speechSynthesis) return;

    function pick(): SpeechSynthesisVoice | null {
      const all = window.speechSynthesis.getVoices();
      if (all.length === 0) return null;
      const target = lang.toLowerCase();
      const prefix = target.split("-")[0];
      const exact = all.find((v) => v.lang.toLowerCase() === target);
      if (exact) return exact;
      const startsWith = all.find((v) =>
        v.lang.toLowerCase().startsWith(target),
      );
      if (startsWith) return startsWith;
      const anyRegion = all.find((v) =>
        v.lang.toLowerCase().startsWith(prefix + "-"),
      );
      if (anyRegion) return anyRegion;
      return null;
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
  }, [lang]);

  return voice;
}

// Reusable Play/Pause button. Owns its own utterance lifecycle so the
// icon flips *instantly* on click and reverts to Play when speech
// finishes (utterance.onend). Multiple AudioButtons on the same page
// share the browser's single speechSynthesis queue — starting one
// cancels any other in flight, and each button subscribes to the
// global 'end' event to reset its own state when interrupted.
function AudioButton({
  text,
  lang,
  size = "md",
  tone = "teal",
  label = "Play",
  className = "",
}: {
  text: string;
  lang: string;
  size?: "sm" | "md" | "lg";
  tone?: "teal" | "outline" | "onDark";
  label?: string;
  className?: string;
}) {
  const voice = useSpeechVoice(lang);
  const [playing, setPlaying] = useState(false);
  const utterRef = useRef<SpeechSynthesisUtterance | null>(null);

  const stop = useCallback(() => {
    if (typeof window === "undefined") return;
    window.speechSynthesis.cancel();
    setPlaying(false);
    utterRef.current = null;
  }, []);

  const toggle = useCallback(() => {
    if (typeof window === "undefined" || !window.speechSynthesis) return;
    if (playing) {
      stop();
      return;
    }
    // Cancel anything else in flight, then queue our utterance.
    window.speechSynthesis.cancel();
    const u = new SpeechSynthesisUtterance(text);
    u.lang = lang;
    if (voice) u.voice = voice;
    u.rate = 0.9;
    u.onend = () => {
      // Only reset if this is still the active utterance — otherwise
      // another button already grabbed the queue.
      if (utterRef.current === u) {
        setPlaying(false);
        utterRef.current = null;
      }
    };
    u.onerror = () => {
      if (utterRef.current === u) {
        setPlaying(false);
        utterRef.current = null;
      }
    };
    utterRef.current = u;
    setPlaying(true);
    window.speechSynthesis.speak(u);
  }, [playing, stop, text, lang, voice]);

  // Cancel if the button unmounts mid-speech.
  useEffect(() => {
    return () => {
      if (utterRef.current) {
        window.speechSynthesis.cancel();
      }
    };
  }, []);

  const sizeClass =
    size === "sm" ? "w-8 h-8" : size === "lg" ? "w-14 h-14" : "w-10 h-10";
  const iconSize =
    size === "sm" ? "w-3.5 h-3.5" : size === "lg" ? "w-6 h-6" : "w-4 h-4";
  const toneClass =
    tone === "onDark"
      ? "bg-white/20 text-white hover:bg-white/30 backdrop-blur"
      : tone === "outline"
      ? "bg-white text-teal-dark border-2 border-teal/30 hover:border-teal"
      : "bg-teal text-white hover:bg-teal-dark";

  return (
    <button
      type="button"
      onClick={toggle}
      aria-label={playing ? "Pause" : label}
      aria-pressed={playing}
      className={`inline-flex items-center justify-center rounded-full transition-colors ${sizeClass} ${toneClass} ${className}`}
    >
      {playing ? (
        <svg
          className={iconSize}
          fill="currentColor"
          viewBox="0 0 24 24"
          aria-hidden
        >
          <path d="M6 4h4v16H6zM14 4h4v16h-4z" />
        </svg>
      ) : (
        <svg
          className={iconSize}
          fill="currentColor"
          viewBox="0 0 24 24"
          aria-hidden
        >
          <path d="M8 5v14l11-7z" />
        </svg>
      )}
    </button>
  );
}

// ============================================================
// City → locals (name + avatar palette). Used to give non-You
// speakers in the dialogue a face and a first name.
// ============================================================

const CITY_LOCALS: Record<
  string,
  { names: string[]; palette: string }
> = {
  Madrid:         { names: ["Carlos", "María", "Diego"],          palette: "bg-red-600" },
  Barcelona:      { names: ["Jordi", "Marta", "Pau"],             palette: "bg-rose-600" },
  "Mexico City":  { names: ["Carlos", "Guadalupe", "Alejandro"],  palette: "bg-emerald-700" },
  "Buenos Aires": { names: ["Matías", "Valentina", "Sofía"],      palette: "bg-sky-600" },
  Paris:          { names: ["Julien", "Camille", "Léa"],          palette: "bg-blue-700" },
  Lyon:           { names: ["Antoine", "Élise", "Théo"],          palette: "bg-red-700" },
  Montreal:       { names: ["Jean-Philippe", "Sophie", "Émile"],  palette: "bg-red-600" },
};

function localsFor(city: string) {
  return CITY_LOCALS[city] ?? { names: ["Alex"], palette: "bg-teal" };
}

// Assign each unique non-You speaker in the dialogue a name + avatar.
// Officer / Waiter / Driver stays as the role in parentheses so the
// learner still sees the situational cue.
function buildSpeakerMap(dialogue: DialogueLine[], city: string) {
  const { names, palette } = localsFor(city);
  const uniqueRoles: string[] = [];
  for (const line of dialogue) {
    if (/^you$/i.test(line.speaker)) continue;
    if (!uniqueRoles.includes(line.speaker)) uniqueRoles.push(line.speaker);
  }
  const map = new Map<
    string,
    { name: string; role: string; initial: string; palette: string }
  >();
  uniqueRoles.forEach((role, i) => {
    const name = names[i % names.length];
    map.set(role, {
      name,
      role,
      initial: name.trim().charAt(0).toUpperCase(),
      palette,
    });
  });
  return map;
}

// ============================================================
// Section pickers + step model
// ============================================================

function pickSection<T extends LessonSection>(
  sections: LessonSection[],
  kind: T["kind"],
): T | undefined {
  return sections.find((s) => s.kind === kind) as T | undefined;
}

type Step =
  | { kind: "scene"; scene: SceneSection }
  | { kind: "sign"; sign: SignSection }
  | { kind: "phrase"; phrase: Phrase; index: number; total: number }
  | { kind: "grammarNote"; note: string }
  | { kind: "dialogue"; dialogue: DialogueSection }
  | { kind: "quiz"; question: QuizQuestion; index: number; total: number }
  | { kind: "complete" };

function buildSteps(sections: LessonSection[]): Step[] {
  const scene = pickSection<SceneSection>(sections, "scene");
  const sign = pickSection<SignSection>(sections, "sign");
  const phrases = pickSection<PhrasesSection>(sections, "phrases");
  const dialogue = pickSection<DialogueSection>(sections, "dialogue");
  const quiz = pickSection<QuizSection>(sections, "quiz");

  const steps: Step[] = [];
  if (scene) steps.push({ kind: "scene", scene });
  if (sign && sign.title) steps.push({ kind: "sign", sign });
  if (phrases) {
    phrases.phrases.forEach((phrase, i) =>
      steps.push({ kind: "phrase", phrase, index: i, total: phrases.phrases.length }),
    );
    if (phrases.grammarNote) {
      steps.push({ kind: "grammarNote", note: phrases.grammarNote });
    }
  }
  if (dialogue && dialogue.lines.length > 0) {
    steps.push({ kind: "dialogue", dialogue });
  }
  if (quiz) {
    quiz.questions.forEach((question, i) =>
      steps.push({ kind: "quiz", question, index: i, total: quiz.questions.length }),
    );
  }
  steps.push({ kind: "complete" });
  return steps;
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
  const steps = useMemo(() => buildSteps(sections), [sections]);

  const [index, setIndex] = useState(0);
  const [quizScore, setQuizScore] = useState(0);

  // Quiz answers accumulate as the user progresses so the completion
  // screen can show a final score. Keyed by the quiz-step's global
  // step index so re-visiting a step (via back-nav — not currently
  // exposed, but harmless) doesn't double-count.
  const [answered, setAnswered] = useState<Record<number, boolean>>({});

  const step = steps[Math.min(index, steps.length - 1)];
  const canGoNext = index < steps.length - 1;

  const goNext = useCallback(() => {
    // Cancel any lingering speech when advancing.
    if (typeof window !== "undefined") window.speechSynthesis?.cancel();
    setIndex((i) => Math.min(i + 1, steps.length - 1));
  }, [steps.length]);

  // Global keyboard: Space / Enter / → advance the adventure. Ignore
  // when focus is in a text input (fill-blank quiz).
  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      const target = e.target as HTMLElement | null;
      if (target && (target.tagName === "INPUT" || target.tagName === "TEXTAREA")) return;
      if (e.key === "ArrowRight" || e.key === " " || e.key === "Enter") {
        // Only advance if the current step allows it — individual steps
        // gate the Continue button (e.g. quiz needs an answer first).
        // We defer to a data attribute on the button to keep this simple.
        const btn = document.querySelector<HTMLButtonElement>(
          "[data-adventure-continue]:not([disabled])",
        );
        if (btn) {
          e.preventDefault();
          btn.click();
        }
      }
    }
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, []);

  function handleQuizAnswer(correct: boolean) {
    setAnswered((prev) => {
      if (prev[index]) return prev;
      if (correct) setQuizScore((s) => s + 1);
      return { ...prev, [index]: true };
    });
  }

  // Empty-lesson fallback — content hasn't been authored yet.
  if (steps.length <= 1) {
    return (
      <div className="max-w-xl mx-auto px-4 sm:px-6 lg:px-8 pt-4 pb-16">
        <h1 className="text-3xl sm:text-4xl font-bold text-navy tracking-tight mt-4">
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
            challenges for this lesson are being authored. Check back soon.
          </p>
          <Link
            href={`/learn/${languageSlug}/travel/${citySlug}`}
            className="mt-6 inline-flex items-center gap-1.5 px-4 py-2 text-sm font-semibold text-white bg-teal rounded-full hover:bg-teal-dark transition-colors"
          >
            Back to {courseCity}
          </Link>
        </div>
      </div>
    );
  }

  const progressPct = Math.round(((index + 1) / steps.length) * 100);

  return (
    <div className="min-h-[calc(100vh-4rem)]">
      {/* Progress bar pinned to the top of the runner surface */}
      <div className="sticky top-16 z-30 bg-white/85 backdrop-blur border-b border-border">
        <div className="max-w-xl mx-auto px-4 sm:px-6 lg:px-8 py-2 flex items-center gap-3">
          <Link
            href={`/learn/${languageSlug}/travel/${citySlug}`}
            aria-label={`Exit to ${courseCity}`}
            className="shrink-0 inline-flex items-center justify-center w-7 h-7 rounded-full text-navy/60 hover:text-navy hover:bg-navy/5 transition-colors"
          >
            <svg
              className="w-4 h-4"
              fill="none"
              stroke="currentColor"
              strokeWidth={2}
              viewBox="0 0 24 24"
              aria-hidden
            >
              <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </Link>
          <p className="text-[10px] font-bold uppercase tracking-widest text-navy/50 shrink-0">
            {courseCity} · L{lesson.orderIndex}
          </p>
          <div className="flex-1 h-1.5 bg-navy/5 rounded-full overflow-hidden">
            <div
              className="h-full bg-gradient-to-r from-teal to-teal-dark rounded-full transition-all duration-500"
              style={{ width: `${progressPct}%` }}
            />
          </div>
          <p className="text-[10px] font-bold tabular-nums text-navy/60 shrink-0">
            {index + 1} / {steps.length}
          </p>
        </div>
      </div>

      {/* Every step gets a fresh key so React remounts on advance and
          our CSS fade-in plays. */}
      <div key={index} className="animate-adventure-in">
        {step.kind === "scene" && (
          <SceneStep scene={step.scene} city={courseCity} lesson={lesson} onContinue={goNext} />
        )}
        {step.kind === "sign" && (
          <SignStep sign={step.sign} speechLang={speechLang} onContinue={goNext} />
        )}
        {step.kind === "phrase" && (
          <PhraseStep
            phrase={step.phrase}
            index={step.index}
            total={step.total}
            speechLang={speechLang}
            onContinue={goNext}
          />
        )}
        {step.kind === "grammarNote" && (
          <GrammarNoteStep note={step.note} onContinue={goNext} />
        )}
        {step.kind === "dialogue" && (
          <DialogueStep
            dialogue={step.dialogue}
            city={courseCity}
            speechLang={speechLang}
            onContinue={goNext}
          />
        )}
        {step.kind === "quiz" && (
          <QuizStep
            question={step.question}
            index={step.index}
            total={step.total}
            speechLang={speechLang}
            alreadyAnswered={!!answered[index]}
            onAnswer={handleQuizAnswer}
            onContinue={goNext}
            canContinue={canGoNext}
          />
        )}
        {step.kind === "complete" && (
          <CompleteStep
            city={courseCity}
            lesson={lesson}
            nextLesson={nextLesson}
            languageSlug={languageSlug}
            citySlug={citySlug}
            isPremium={isPremium}
            score={quizScore}
            totalQuestions={
              steps.filter((s) => s.kind === "quiz").length
            }
          />
        )}
      </div>

      {/* Animation keyframes — declared inline so this component is
          fully self-contained. adventure-in fades + lifts each new
          step into place; stamp-in scales the passport stamp on the
          completion screen. */}
      <style>{`
        @keyframes adventureIn {
          from { opacity: 0; transform: translateY(12px); }
          to   { opacity: 1; transform: translateY(0); }
        }
        .animate-adventure-in { animation: adventureIn 380ms cubic-bezier(.2,.7,.2,1) both; }

        @keyframes stampIn {
          0%   { opacity: 0; transform: scale(0) rotate(-45deg); }
          65%  { opacity: 1; transform: scale(1.25) rotate(-2deg); }
          100% { opacity: 1; transform: scale(1) rotate(-8deg); }
        }
        .animate-stamp-in { animation: stampIn 900ms cubic-bezier(.2,.7,.2,1) both; }

        @keyframes chatIn {
          from { opacity: 0; transform: translateY(8px); }
          to   { opacity: 1; transform: translateY(0); }
        }
        .animate-chat-in { animation: chatIn 320ms cubic-bezier(.2,.7,.2,1) both; }

        @keyframes celebrate {
          0%   { transform: scale(1); }
          50%  { transform: scale(1.06); }
          100% { transform: scale(1); }
        }
        .animate-celebrate { animation: celebrate 500ms ease-out both; }
      `}</style>
    </div>
  );
}

// ============================================================
// Shared UI atoms
// ============================================================

function ContinueButton({
  label = "Continue",
  onClick,
  disabled = false,
  variant = "primary",
}: {
  label?: string;
  onClick: () => void;
  disabled?: boolean;
  variant?: "primary" | "onDark";
}) {
  const base =
    variant === "onDark"
      ? "bg-white text-navy hover:bg-white/90"
      : "bg-teal text-white hover:bg-teal-dark";
  return (
    <button
      type="button"
      onClick={onClick}
      disabled={disabled}
      data-adventure-continue={disabled ? undefined : true}
      className={`inline-flex items-center justify-center gap-2 px-6 py-3.5 text-sm font-bold rounded-full shadow-md transition-all disabled:opacity-40 disabled:cursor-not-allowed active:scale-95 ${base}`}
    >
      {label}
      <svg
        className="w-4 h-4"
        fill="none"
        stroke="currentColor"
        strokeWidth={2.5}
        viewBox="0 0 24 24"
        aria-hidden
      >
        <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
      </svg>
    </button>
  );
}

function TravelStamp({
  title,
  sublabel,
  animate = false,
}: {
  title: string;
  sublabel?: string | null;
  animate?: boolean;
}) {
  return (
    <div className={`inline-block -rotate-3 ${animate ? "animate-stamp-in" : ""}`}>
      <div className="border-[3px] border-red-700/70 text-red-800 px-4 py-2 rounded-md font-black uppercase tracking-widest text-sm sm:text-base bg-red-50/40">
        {title}
        {sublabel && (
          <div className="text-[10px] font-semibold tracking-wider text-red-800/80 mt-0.5">
            {sublabel}
          </div>
        )}
      </div>
    </div>
  );
}

function StepShell({
  children,
  className = "",
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <div
      className={`max-w-xl mx-auto px-4 sm:px-6 lg:px-8 pt-6 sm:pt-10 pb-24 flex flex-col min-h-[calc(100vh-8rem)] ${className}`}
    >
      {children}
    </div>
  );
}

// ============================================================
// SceneStep — full-bleed cinematic opening
// ============================================================

function SceneStep({
  scene,
  city,
  lesson,
  onContinue,
}: {
  scene: SceneSection;
  city: string;
  lesson: LessonContent["lesson"];
  onContinue: () => void;
}) {
  return (
    <div className="relative">
      <div className="relative w-full h-[60vh] sm:h-[65vh] lg:h-[70vh] min-h-[380px] bg-gradient-to-br from-navy via-navy to-navy/80 overflow-hidden">
        {scene.imageUrl ? (
          <Image
            src={scene.imageUrl}
            alt={scene.imageAlt ?? `${city} scene`}
            fill
            sizes="100vw"
            className="object-cover"
            priority
            unoptimized
          />
        ) : (
          <div className="absolute inset-0 bg-gradient-to-br from-amber-800 via-orange-900 to-red-950" />
        )}
        <div className="absolute inset-0 bg-gradient-to-t from-black/90 via-black/40 to-transparent" />
        <div className="absolute inset-x-0 bottom-0">
          <div className="max-w-xl mx-auto px-4 sm:px-6 lg:px-8 pb-8 sm:pb-12">
            <div className="mb-5">
              <TravelStamp
                title={scene.stamp ?? city}
                sublabel={scene.stampSublabel ?? lesson.locationName}
              />
            </div>
            <p className="text-[11px] font-semibold uppercase tracking-[0.2em] text-white/70">
              {city} · Lesson {lesson.orderIndex}
            </p>
            <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-white tracking-tight mt-2 drop-shadow-lg leading-tight">
              {lesson.title}
            </h1>
          </div>
        </div>
      </div>

      <StepShell>
        {scene.description ? (
          <p
            className="text-base sm:text-lg text-navy/90 leading-relaxed"
            dangerouslySetInnerHTML={{ __html: renderInlineMarkdown(scene.description) }}
          />
        ) : (
          <p className="text-base text-navy/60 italic">
            You&rsquo;ve arrived. Time to see what {city} has in store.
          </p>
        )}
        <div className="flex-1" />
        <div className="mt-8 flex justify-center">
          <ContinueButton onClick={onContinue} />
        </div>
      </StepShell>
    </div>
  );
}

function renderInlineMarkdown(input: string): string {
  const escape = (s: string) =>
    s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  return escape(input)
    .replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>")
    .replace(/\*(.+?)\*/g, "<em>$1</em>")
    .replace(/\n/g, "<br />");
}

// ============================================================
// SignStep — discovery moment with tap-to-decode words
// ============================================================

const SIGN_STYLES: Record<
  SignSection["style"],
  { wrapper: string; title: string; subtitle: string; word: string }
> = {
  airport_blue: {
    wrapper:
      "bg-gradient-to-br from-blue-800 to-blue-950 text-white ring-2 ring-blue-900/40 border-4 border-blue-900/20",
    title: "font-black tracking-widest text-2xl sm:text-4xl",
    subtitle: "text-blue-200 tracking-wider text-xs sm:text-sm",
    word: "bg-blue-700/60 hover:bg-blue-600/80 text-white ring-1 ring-blue-300/30",
  },
  menu_card: {
    wrapper:
      "bg-gradient-to-br from-amber-50 to-orange-100 text-amber-950 ring-1 ring-amber-300 border-4 border-amber-200",
    title: "font-serif italic text-2xl sm:text-4xl",
    subtitle: "text-amber-800/70 italic text-xs sm:text-sm",
    word: "bg-amber-200/60 hover:bg-amber-300/80 text-amber-950 ring-1 ring-amber-300",
  },
  street: {
    wrapper:
      "bg-gradient-to-br from-emerald-700 to-emerald-900 text-white ring-2 ring-emerald-900/40 border-4 border-white/20",
    title: "font-bold tracking-wide text-xl sm:text-3xl uppercase",
    subtitle: "text-emerald-200 tracking-wider text-xs sm:text-sm",
    word: "bg-emerald-600/60 hover:bg-emerald-500/80 text-white ring-1 ring-emerald-200/30",
  },
  notice: {
    wrapper:
      "bg-stone-50 text-stone-900 ring-1 ring-stone-300 border-4 border-stone-200 shadow-[0_2px_0_rgba(0,0,0,0.06)]",
    title: "font-bold text-xl sm:text-3xl",
    subtitle: "text-stone-500 tracking-wide text-xs sm:text-sm",
    word: "bg-stone-200 hover:bg-stone-300 text-stone-900 ring-1 ring-stone-300",
  },
  neon: {
    wrapper:
      "bg-neutral-900 text-pink-300 ring-2 ring-pink-500/40 border-4 border-pink-400/20 shadow-[0_0_40px_rgba(236,72,153,0.35)]",
    title:
      "font-black text-2xl sm:text-4xl uppercase tracking-widest text-pink-300 drop-shadow-[0_0_8px_rgba(236,72,153,0.9)]",
    subtitle:
      "text-pink-200 tracking-widest text-xs sm:text-sm uppercase drop-shadow-[0_0_6px_rgba(236,72,153,0.7)]",
    word: "bg-pink-900/40 hover:bg-pink-800/60 text-pink-100 ring-1 ring-pink-400/30",
  },
};

function SignStep({
  sign,
  speechLang,
  onContinue,
}: {
  sign: SignSection;
  speechLang: string;
  onContinue: () => void;
}) {
  const styles = SIGN_STYLES[sign.style];
  const [active, setActive] = useState<SignWord | null>(null);
  const [tapped, setTapped] = useState<Set<number>>(new Set());
  const allTapped = sign.words.length > 0 && tapped.size >= sign.words.length;

  return (
    <StepShell>
      <p className="text-xs font-bold uppercase tracking-[0.16em] text-amber-900/80 mb-2">
        Discovery moment
      </p>
      <h2 className="text-lg sm:text-xl font-bold text-navy leading-snug mb-4">
        Something catches your eye…
      </h2>

      <div className={`${styles.wrapper} rounded-2xl p-5 sm:p-8 text-center animate-adventure-in`}>
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
        <p className="text-xs text-navy/50 italic mt-2 text-center">{sign.note}</p>
      )}

      <div className="mt-6">
        <p className="text-sm font-semibold text-navy/70 mb-3">
          Tap each word to decode it ({tapped.size} / {sign.words.length})
        </p>
        <div className="flex flex-wrap gap-2">
          {sign.words.map((word, i) => {
            const isDone = tapped.has(i);
            return (
              <button
                key={`${word.text}-${i}`}
                type="button"
                onClick={() => {
                  setActive(word);
                  setTapped((s) => new Set(s).add(i));
                }}
                className={`${styles.word} inline-flex items-center gap-1.5 rounded-lg px-3 py-2 text-sm font-bold min-h-11 transition-all ${isDone ? "opacity-70" : ""}`}
              >
                {isDone && (
                  <svg
                    className="w-3.5 h-3.5"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth={3}
                    viewBox="0 0 24 24"
                    aria-hidden
                  >
                    <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                  </svg>
                )}
                {word.text}
              </button>
            );
          })}
        </div>
      </div>

      {active && (
        <div className="mt-5 rounded-2xl border border-amber-300 bg-amber-50 p-4 shadow-sm animate-adventure-in">
          <div className="flex items-start justify-between gap-3">
            <div className="min-w-0">
              <p className="text-xl font-bold text-navy break-words">
                {active.text}
              </p>
              {active.phonetic && (
                <p className="text-sm text-navy/60 italic mt-1">
                  [{active.phonetic}]
                </p>
              )}
              {active.english && (
                <p className="text-sm text-navy/85 mt-2">
                  <span className="font-semibold text-navy/60">→ </span>
                  {active.english}
                </p>
              )}
              {active.tip && (
                <p className="text-xs text-amber-900/85 mt-2 leading-relaxed">
                  <span className="font-bold uppercase tracking-wider text-amber-800">
                    Memory tip:{" "}
                  </span>
                  {active.tip}
                </p>
              )}
            </div>
            <div className="flex items-center gap-1.5 shrink-0">
              <AudioButton text={active.text} lang={speechLang} size="md" label="Play word" />
              <button
                type="button"
                onClick={() => setActive(null)}
                aria-label="Close"
                className="w-10 h-10 rounded-full bg-navy/5 text-navy/60 flex items-center justify-center hover:bg-navy/10 transition-colors"
              >
                <svg
                  className="w-4 h-4"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth={2}
                  viewBox="0 0 24 24"
                  aria-hidden
                >
                  <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
          </div>
        </div>
      )}

      <div className="flex-1" />
      <div className="mt-8 flex justify-center">
        <ContinueButton
          onClick={onContinue}
          label={allTapped ? "Got it" : "Skip ahead"}
        />
      </div>
    </StepShell>
  );
}

// ============================================================
// PhraseStep — one phrase at a time
// ============================================================

function PhraseStep({
  phrase,
  index,
  total,
  speechLang,
  onContinue,
}: {
  phrase: Phrase;
  index: number;
  total: number;
  speechLang: string;
  onContinue: () => void;
}) {
  const [showTip, setShowTip] = useState(false);

  return (
    <StepShell>
      <p className="text-xs font-bold uppercase tracking-[0.16em] text-amber-900/80 mb-2">
        Phrase {index + 1} of {total}
      </p>
      <div className="mt-4 rounded-3xl bg-white border border-border shadow-sm p-6 sm:p-8">
        <p className="text-2xl sm:text-3xl font-bold text-navy leading-snug">
          {phrase.phrase}
        </p>
        {phrase.phonetic && (
          <p className="text-sm sm:text-base text-navy/55 italic mt-2">
            [{phrase.phonetic}]
          </p>
        )}
        {phrase.english && (
          <p className="text-base text-navy/80 mt-4">
            <span className="text-navy/45 font-semibold">→ </span>
            {phrase.english}
          </p>
        )}

        <div className="mt-6 flex items-center gap-3">
          <AudioButton
            text={phrase.phrase}
            lang={speechLang}
            size="lg"
            label="Play phrase"
          />
          <div className="text-xs text-navy/50">
            Tap to hear it in a native accent.
          </div>
        </div>
      </div>

      {(phrase.tip || phrase.grammar) && (
        <div className="mt-4">
          <button
            type="button"
            onClick={() => setShowTip((v) => !v)}
            className="inline-flex items-center gap-1 text-xs font-semibold text-amber-800 hover:text-amber-900"
          >
            {showTip ? "Hide" : "Show"} memory tips
            <svg
              className={`w-3 h-3 transition-transform ${showTip ? "rotate-180" : ""}`}
              fill="none"
              stroke="currentColor"
              strokeWidth={2.5}
              viewBox="0 0 24 24"
              aria-hidden
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M19 9l-7 7-7-7"
              />
            </svg>
          </button>
          {showTip && (
            <div className="mt-2 rounded-xl bg-amber-50 border border-amber-200 p-3 space-y-1.5 animate-adventure-in">
              {phrase.tip && (
                <p className="text-xs text-amber-900 leading-relaxed">
                  <span className="font-bold uppercase tracking-wider text-amber-800">
                    Memory trick:{" "}
                  </span>
                  {phrase.tip}
                </p>
              )}
              {phrase.grammar && (
                <p className="text-xs text-amber-900 leading-relaxed">
                  <span className="font-bold uppercase tracking-wider text-amber-800">
                    Grammar note:{" "}
                  </span>
                  {phrase.grammar}
                </p>
              )}
            </div>
          )}
        </div>
      )}

      <div className="flex-1" />
      <div className="mt-8 flex justify-center">
        <ContinueButton
          onClick={onContinue}
          label={index + 1 < total ? "Next phrase" : "Continue"}
        />
      </div>
    </StepShell>
  );
}

// ============================================================
// GrammarNoteStep — small card between phrases and dialogue
// ============================================================

function GrammarNoteStep({
  note,
  onContinue,
}: {
  note: string;
  onContinue: () => void;
}) {
  return (
    <StepShell>
      <p className="text-xs font-bold uppercase tracking-[0.16em] text-amber-900/80 mb-2">
        The pattern
      </p>
      <div className="mt-2 rounded-3xl border-2 border-amber-300 bg-gradient-to-br from-amber-50 to-orange-50 p-6 sm:p-8 shadow-sm">
        <div className="flex items-center gap-3 mb-4">
          <span className="inline-flex items-center justify-center w-10 h-10 rounded-full bg-amber-500 text-white font-bold">
            <svg
              className="w-5 h-5"
              fill="none"
              stroke="currentColor"
              strokeWidth={2.5}
              viewBox="0 0 24 24"
              aria-hidden
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M13 10V3L4 14h7v7l9-11h-7z"
              />
            </svg>
          </span>
          <p className="text-sm font-bold uppercase tracking-wider text-amber-900">
            One grammar takeaway
          </p>
        </div>
        <p className="text-base sm:text-lg text-amber-950 leading-relaxed">
          {note}
        </p>
      </div>
      <div className="flex-1" />
      <div className="mt-8 flex justify-center">
        <ContinueButton onClick={onContinue} label="Let's talk to a local" />
      </div>
    </StepShell>
  );
}

// ============================================================
// DialogueStep — auto-play chat interface with named locals
// ============================================================

function DialogueStep({
  dialogue,
  city,
  speechLang,
  onContinue,
}: {
  dialogue: DialogueSection;
  city: string;
  speechLang: string;
  onContinue: () => void;
}) {
  const speakerMap = useMemo(
    () => buildSpeakerMap(dialogue.lines, city),
    [dialogue.lines, city],
  );
  const [visibleCount, setVisibleCount] = useState(0);
  const [revealed, setRevealed] = useState<Set<number>>(new Set());

  // Auto-reveal messages one at a time with a small delay.
  useEffect(() => {
    if (visibleCount >= dialogue.lines.length) return;
    const t = setTimeout(() => {
      setVisibleCount((n) => Math.min(n + 1, dialogue.lines.length));
    }, visibleCount === 0 ? 250 : 900);
    return () => clearTimeout(t);
  }, [visibleCount, dialogue.lines.length]);

  const allShown = visibleCount >= dialogue.lines.length;

  function toggleTranslation(i: number) {
    setRevealed((prev) => {
      const next = new Set(prev);
      if (next.has(i)) next.delete(i);
      else next.add(i);
      return next;
    });
  }

  return (
    <StepShell>
      <p className="text-xs font-bold uppercase tracking-[0.16em] text-amber-900/80 mb-2">
        Live dialogue
      </p>
      <h2 className="text-lg sm:text-xl font-bold text-navy leading-snug mb-5">
        Real conversation with a local
      </h2>

      <ol className="space-y-3">
        {dialogue.lines.slice(0, visibleCount).map((line, i) => {
          const isYou = /^you$/i.test(line.speaker);
          const local = speakerMap.get(line.speaker);
          return (
            <li
              key={i}
              className={`flex items-end gap-2 animate-chat-in ${isYou ? "justify-end" : "justify-start"}`}
            >
              {!isYou && local && (
                <div
                  className={`shrink-0 w-9 h-9 rounded-full ${local.palette} text-white flex items-center justify-center text-sm font-bold shadow`}
                  aria-label={`${local.name} — ${local.role}`}
                  title={`${local.name} · ${local.role}`}
                >
                  {local.initial}
                </div>
              )}
              <div
                className={`max-w-[80%] rounded-2xl px-4 py-3 shadow-sm ${
                  isYou
                    ? "bg-teal text-white rounded-br-sm"
                    : "bg-white text-navy border border-border rounded-bl-sm"
                }`}
              >
                <p
                  className={`text-[10px] font-bold uppercase tracking-wider mb-0.5 ${
                    isYou ? "text-white/75" : "text-navy/50"
                  }`}
                >
                  {isYou ? "You" : local ? `${local.name} (${local.role})` : line.speaker}
                </p>
                <p className="text-sm sm:text-base font-medium leading-snug">
                  {line.target}
                </p>
                <div className="flex items-center gap-2 mt-2">
                  <AudioButton
                    text={line.target}
                    lang={speechLang}
                    size="sm"
                    tone={isYou ? "onDark" : "outline"}
                    label="Play line"
                  />
                  <button
                    type="button"
                    onClick={() => toggleTranslation(i)}
                    className={`inline-flex items-center gap-1 text-[11px] font-bold ${
                      isYou ? "text-white/85 hover:text-white" : "text-teal-dark hover:text-teal"
                    }`}
                  >
                    {revealed.has(i) ? "Hide translation" : "Translate"}
                  </button>
                </div>
                {revealed.has(i) && (
                  <p
                    className={`text-xs mt-2 italic ${isYou ? "text-white/90" : "text-navy/70"}`}
                  >
                    {line.english}
                  </p>
                )}
              </div>
              {isYou && (
                <div className="shrink-0 w-9 h-9 rounded-full bg-teal-dark text-white flex items-center justify-center text-sm font-bold shadow">
                  Y
                </div>
              )}
            </li>
          );
        })}
      </ol>

      {allShown && (
        <div className="mt-6 flex justify-center animate-adventure-in">
          <div className="inline-flex items-center gap-2 rounded-full bg-emerald-50 border border-emerald-200 px-4 py-2 text-sm font-bold text-emerald-800">
            <svg
              className="w-4 h-4"
              fill="none"
              stroke="currentColor"
              strokeWidth={3}
              viewBox="0 0 24 24"
              aria-hidden
            >
              <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
            </svg>
            You handled that well
          </div>
        </div>
      )}

      <div className="flex-1" />
      <div className="mt-8 flex justify-center">
        <ContinueButton
          onClick={onContinue}
          label={allShown ? "Ready for the challenge" : "Skip ahead"}
        />
      </div>
    </StepShell>
  );
}

// ============================================================
// QuizStep — one challenge at a time
// ============================================================

function QuizStep({
  question,
  index,
  total,
  speechLang,
  alreadyAnswered,
  onAnswer,
  onContinue,
}: {
  question: QuizQuestion;
  index: number;
  total: number;
  speechLang: string;
  alreadyAnswered: boolean;
  onAnswer: (correct: boolean) => void;
  onContinue: () => void;
  canContinue: boolean;
}) {
  const [selected, setSelected] = useState<string | null>(null);
  const [textInput, setTextInput] = useState("");
  const [committed, setCommitted] = useState(false);

  // Shuffle once per mount so the correct answer doesn't jump when
  // the user re-taps a locked-in card.
  const choices = useMemo(() => {
    if (question.type === "fill_blank") return [];
    const items = [question.correctAnswer, ...question.wrongAnswers].map(
      (text) => ({ text, correct: text === question.correctAnswer }),
    );
    for (let i = items.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [items[i], items[j]] = [items[j], items[i]];
    }
    return items;
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [question.correctAnswer]);

  function commit(answer: string) {
    if (committed) return;
    const correct =
      answer.trim().toLowerCase() === question.correctAnswer.trim().toLowerCase();
    setSelected(answer);
    setCommitted(true);
    if (!alreadyAnswered) onAnswer(correct);
  }

  function submitText() {
    if (committed || textInput.trim().length === 0) return;
    commit(textInput);
  }

  const isCorrect =
    committed &&
    selected?.trim().toLowerCase() === question.correctAnswer.trim().toLowerCase();

  const scenario = adventureFramingFor(question, index, total);

  return (
    <StepShell>
      <p className="text-xs font-bold uppercase tracking-[0.16em] text-amber-900/80 mb-2">
        Challenge {index + 1} of {total}
      </p>
      <div className="rounded-3xl bg-white border border-border shadow-sm p-5 sm:p-7">
        <p className="text-sm sm:text-base font-semibold text-navy/80 mb-4 leading-relaxed">
          {scenario}
        </p>

        {question.type === "listening" && question.audioPrompt && (
          <div className="mb-5 rounded-2xl bg-teal-light/40 border border-teal/20 p-4 flex items-center gap-3">
            <AudioButton
              text={question.audioPrompt}
              lang={speechLang}
              size="lg"
              label="Play audio"
            />
            <div className="text-xs text-navy/60">
              Tap to hear the phrase again.
            </div>
          </div>
        )}

        <p className="text-base sm:text-lg font-bold text-navy leading-snug mb-4">
          {question.question}
        </p>

        {question.type === "fill_blank" ? (
          <div>
            <input
              type="text"
              value={textInput}
              onChange={(e) => setTextInput(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === "Enter" && !committed) {
                  e.preventDefault();
                  submitText();
                }
              }}
              disabled={committed}
              placeholder="Type your answer…"
              className="w-full rounded-xl border-2 border-border bg-white px-4 py-3 text-base focus:outline-none focus:ring-2 focus:ring-teal focus:border-transparent disabled:bg-navy/[0.03]"
              autoFocus
            />
            {!committed && (
              <button
                type="button"
                onClick={submitText}
                disabled={textInput.trim().length === 0}
                className="mt-3 inline-flex items-center gap-1.5 px-4 py-2.5 text-sm font-bold text-white bg-teal rounded-full hover:bg-teal-dark disabled:opacity-50 transition-colors"
              >
                Check answer
              </button>
            )}
          </div>
        ) : (
          <div className="grid gap-2.5">
            {choices.map((c) => {
              const isChosen = selected === c.text;
              const showRight = committed && c.correct;
              const showWrong = committed && isChosen && !c.correct;
              return (
                <button
                  key={c.text}
                  type="button"
                  onClick={() => commit(c.text)}
                  disabled={committed}
                  className={`text-left rounded-2xl border-2 px-4 py-3.5 text-sm sm:text-base font-medium min-h-14 transition-all active:scale-[0.98] ${
                    showRight
                      ? "border-emerald-400 bg-emerald-50 text-emerald-900 animate-celebrate"
                      : showWrong
                      ? "border-red-400 bg-red-50 text-red-900"
                      : committed
                      ? "border-border bg-white text-navy/60"
                      : "border-border bg-white text-navy hover:border-teal/40 hover:bg-teal-light/30"
                  }`}
                >
                  <div className="flex items-center justify-between gap-2">
                    <span>{c.text}</span>
                    {showRight && (
                      <svg
                        className="w-5 h-5 shrink-0"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth={3}
                        viewBox="0 0 24 24"
                        aria-hidden
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          d="M5 13l4 4L19 7"
                        />
                      </svg>
                    )}
                    {showWrong && (
                      <svg
                        className="w-5 h-5 shrink-0"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth={3}
                        viewBox="0 0 24 24"
                        aria-hidden
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          d="M6 18L18 6M6 6l12 12"
                        />
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
            className={`mt-5 rounded-2xl p-4 animate-adventure-in ${
              isCorrect
                ? "bg-emerald-50 border border-emerald-200"
                : "bg-amber-50 border border-amber-200"
            }`}
          >
            <p
              className={`text-sm font-bold ${
                isCorrect ? "text-emerald-800" : "text-amber-900"
              }`}
            >
              {isCorrect
                ? celebrationFor(index)
                : `Not quite — the right answer is “${question.correctAnswer}”`}
            </p>
            {question.translation && (
              <p className="text-xs text-navy/60 mt-1">
                <span className="font-semibold">Meaning: </span>
                {question.translation}
              </p>
            )}
          </div>
        )}
      </div>

      <div className="flex-1" />
      <div className="mt-8 flex justify-center">
        <ContinueButton
          onClick={onContinue}
          label={index + 1 < total ? "Next challenge" : "Finish the story"}
          disabled={!committed}
        />
      </div>
    </StepShell>
  );
}

// Framing sentences that make each quiz feel like part of the story
// instead of "Question 1 / 2 / 3". Rotates by index so successive
// challenges don't all open with the same line.
const CHALLENGE_FRAMES = [
  "A local turns to you and asks something. How do you respond?",
  "You hear a phrase on the loudspeaker. Pick the right meaning.",
  "It&rsquo;s your turn to speak. What do you say?",
  "One last test before you move on — pick the right fit.",
];
function adventureFramingFor(_q: QuizQuestion, index: number, _total: number) {
  return CHALLENGE_FRAMES[index % CHALLENGE_FRAMES.length];
}

const CELEBRATIONS = [
  "¡Perfecto! Nailed it.",
  "Nice — that&rsquo;s exactly how a local would say it.",
  "Confident answer. You&rsquo;re getting the hang of this.",
  "That&rsquo;s the one. Momentum building.",
];
function celebrationFor(index: number) {
  return CELEBRATIONS[index % CELEBRATIONS.length];
}

// ============================================================
// CompleteStep — passport stamp animation + next-stop preview
// ============================================================

function CompleteStep({
  city,
  lesson,
  nextLesson,
  languageSlug,
  citySlug,
  isPremium,
  score,
  totalQuestions,
}: {
  city: string;
  lesson: LessonContent["lesson"];
  nextLesson: LessonContent["nextLesson"];
  languageSlug: string;
  citySlug: string;
  isPremium: boolean;
  score: number;
  totalQuestions: number;
}) {
  const [xpEarned, setXpEarned] = useState<number | null>(null);
  const [saving, setSaving] = useState(true);
  const [saveError, setSaveError] = useState<string | null>(null);

  // Fire the completion mutation exactly once when the screen mounts.
  useEffect(() => {
    let cancelled = false;
    async function run() {
      try {
        const earned = await markLessonComplete(lesson.id);
        if (!cancelled) setXpEarned(earned);
      } catch (err) {
        if (!cancelled) {
          setSaveError(
            err instanceof Error ? err.message : "Could not save progress",
          );
        }
      } finally {
        if (!cancelled) setSaving(false);
      }
    }
    run();
    return () => {
      cancelled = true;
    };
  }, [lesson.id]);

  const alreadyDone = xpEarned === 0;
  const nextLocked = nextLesson?.isPremium && !isPremium;

  return (
    <StepShell>
      <div className="text-center">
        <div className="flex justify-center mb-6 min-h-[92px] items-center">
          <TravelStamp
            title={city}
            sublabel={`L${lesson.orderIndex} · COMPLETE`}
            animate
          />
        </div>
        <h2 className="text-2xl sm:text-3xl font-bold text-navy tracking-tight">
          {lesson.title} — done!
        </h2>
        <p className="text-sm text-navy/60 mt-1">
          {totalQuestions > 0
            ? `${score} / ${totalQuestions} challenges nailed`
            : "Ready for the next stop"}
        </p>

        <div className="mt-6 inline-flex items-center gap-2 px-4 py-2 rounded-full bg-teal text-white text-sm font-bold shadow">
          <svg
            className="w-4 h-4"
            fill="currentColor"
            viewBox="0 0 24 24"
            aria-hidden
          >
            <path d="M12 2l2.4 7.4H22l-6.2 4.5 2.4 7.4L12 16.9 5.8 21.3l2.4-7.4L2 9.4h7.6z" />
          </svg>
          {saving
            ? "Saving…"
            : alreadyDone
            ? "Already completed"
            : `+${xpEarned ?? lesson.xpReward} XP earned`}
        </div>

        {saveError && (
          <p className="text-xs text-red-700 mt-2">{saveError}</p>
        )}

        {nextLesson ? (
          <div className="mt-8 text-left">
            <p className="text-xs font-bold uppercase tracking-widest text-navy/50 mb-2 text-center">
              Next stop
            </p>
            <div className="rounded-2xl border border-border bg-white p-4 sm:p-5 flex items-center gap-4 shadow-sm">
              <div className="shrink-0 w-12 h-12 rounded-xl bg-gradient-to-br from-orange-500 to-red-600 text-white flex items-center justify-center shadow">
                <svg
                  className="w-6 h-6"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth={2}
                  viewBox="0 0 24 24"
                  aria-hidden
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
                <p className="text-xs text-navy/55 mt-0.5">
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
              <div className="mt-6 flex flex-col sm:flex-row gap-3 justify-center">
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
                    aria-hidden
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      d="M9 5l7 7-7 7"
                    />
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
              <div className="mt-6 flex flex-col sm:flex-row gap-3 justify-center">
                <Link
                  href={`/learn/${languageSlug}/travel/${citySlug}/${nextLesson.id}`}
                  className="inline-flex items-center justify-center gap-1.5 px-5 py-3 text-sm font-bold text-white bg-teal rounded-full hover:bg-teal-dark shadow-md transition-all"
                >
                  Continue the journey
                  <svg
                    className="w-3.5 h-3.5"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth={2.5}
                    viewBox="0 0 24 24"
                    aria-hidden
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      d="M9 5l7 7-7 7"
                    />
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
              className="mt-6 inline-flex items-center justify-center gap-1.5 px-5 py-3 text-sm font-bold text-white bg-teal rounded-full hover:bg-teal-dark shadow-md transition-all"
            >
              Pick your next city
              <svg
                className="w-3.5 h-3.5"
                fill="none"
                stroke="currentColor"
                strokeWidth={2.5}
                viewBox="0 0 24 24"
                aria-hidden
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M9 5l7 7-7 7"
                />
              </svg>
            </Link>
          </div>
        )}
      </div>
    </StepShell>
  );
}

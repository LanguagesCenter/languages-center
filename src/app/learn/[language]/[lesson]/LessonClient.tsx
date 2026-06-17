"use client";

import { useEffect, useMemo, useRef, useState, useTransition } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import type { DbExercise, DbLesson } from "@/lib/learn";
import { SPEECH_LANG_CODES } from "@/lib/speech";
import { completeLesson } from "@/lib/learn-actions";
import { useI18n } from "@/components/I18nProvider";

interface Props {
  languageSlug: string;
  languageName: string;
  lesson: DbLesson;
  exercises: DbExercise[];
  sectionId: number;
  /** CEFR level of the course (used for AI lesson grading). */
  level: string;
  /** Section / course title (used for AI lesson grading context). */
  sectionTitle: string;
}

interface GradedLessonResponse {
  score: number;
  feedback: string;
  passed: boolean;
  correctedVersion: string;
  encouragement: string;
}

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

// Removes phonetic guides like "[OH-lah]" or "[KOOM-breh]" from a string.
// Phonetics belong in the teaching/vocab card, not in exercise text where
// they give the answer away.
function stripPhonetic(s: string | null | undefined): string {
  if (!s) return "";
  return s
    .replace(/\s*\[[A-Za-z][A-Za-z\s/\-]*\]\s*/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

// ---------------- TTS voice picker ----------------
// Browsers ship many voices; if we don't pick one explicitly, English
// engines pronounce Spanish words like an English speaker would. Find a
// real native voice matching the requested locale, falling back through
// region → language → null.
function pickVoiceForLang(lang: string): SpeechSynthesisVoice | null {
  if (typeof window === "undefined" || !("speechSynthesis" in window)) return null;
  const voices = window.speechSynthesis.getVoices();
  if (voices.length === 0) return null;
  const target = lang.toLowerCase();
  const langPart = target.split("-")[0];
  // 1) exact locale: es-ES
  const exact = voices.find((v) => v.lang.toLowerCase() === target);
  if (exact) return exact;
  // 2) any locale of the same language (es-MX, es-AR, es-US, ...)
  const partial = voices.find((v) => v.lang.toLowerCase().startsWith(langPart + "-"));
  if (partial) return partial;
  // 3) bare language code or anything that starts with it
  return voices.find((v) => v.lang.toLowerCase().startsWith(langPart)) ?? null;
}

// Some browsers (Chrome) return [] on the first getVoices() call and fire
// `voiceschanged` once the list is ready. Touch getVoices() eagerly so the
// list is warm by the time the user clicks play.
function primeVoices() {
  if (typeof window === "undefined" || !("speechSynthesis" in window)) return;
  window.speechSynthesis.getVoices();
}

// ---------------- TTS hook ----------------
// Tracks whether speechSynthesis is currently speaking so the UI can flip
// play/pause icons accordingly.
function useTts(text: string, lang: string) {
  const [isPlaying, setIsPlaying] = useState(false);
  const supported =
    typeof window !== "undefined" && "speechSynthesis" in window;

  // Warm the voices list once mounted so the first Play has a real voice.
  useEffect(() => {
    primeVoices();
    if (!supported) return;
    const handler = () => primeVoices();
    window.speechSynthesis.addEventListener?.("voiceschanged", handler);
    return () => {
      window.speechSynthesis.removeEventListener?.("voiceschanged", handler);
    };
  }, [supported]);

  const play = () => {
    if (!supported) return;
    try {
      window.speechSynthesis.cancel();
      const utterance = new SpeechSynthesisUtterance(text);
      utterance.lang = lang;
      const voice = pickVoiceForLang(lang);
      if (voice) utterance.voice = voice;
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
  // Reset the input whenever the underlying exercise changes; otherwise
  // the previous answer leaks into the next fill-blank question.
  useEffect(() => {
    setValue("");
  }, [exercise.id]);
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

function ListeningExercise(props: {
  exercise: DbExercise;
  onAnswer: (answer: string) => void;
  disabled: boolean;
  pickedAnswer: string | null;
  speechLang: string;
}) {
  // New A1 (migration 039) format: when there are no MC distractors we
  // render a typed-response listening flow; the AI grader scores the
  // candidate's typed Spanish reply to the audio.
  const isTypedMode =
    !props.exercise.wrong_answers || props.exercise.wrong_answers.length === 0;
  if (isTypedMode) {
    return (
      <ListeningTypedExercise
        exercise={props.exercise}
        onAnswer={props.onAnswer}
        disabled={props.disabled}
        speechLang={props.speechLang}
      />
    );
  }
  return <ListeningMcExercise {...props} />;
}

function ListeningMcExercise({
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
  const { t } = useI18n();
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
            {t("lesson.listen.heading")}
          </p>
          <p className="text-sm text-navy/70">
            {hasTts
              ? isPlaying
                ? t("lesson.listen.playing")
                : t("lesson.listen.tap")
              : t("lesson.listen.unsupported")}
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
      {disabled && exercise.translation && (
        <p className="text-xs text-navy/50 text-center">
          {t("lesson.listen.meaning")}{" "}
          <span className="font-semibold text-navy/70">
            {stripPhonetic(exercise.translation)}
          </span>
        </p>
      )}
    </div>
  );
}

function SpeakingExercise(props: {
  exercise: DbExercise;
  onAnswer: (answer: string) => void;
  disabled: boolean;
  speechLang: string;
}) {
  // New A1 (migration 039) format: when there's no target phrase to repeat
  // (correct_answer empty), render the topic-prompt monologue flow.
  const isTopicMode =
    !props.exercise.correct_answer ||
    props.exercise.correct_answer.trim() === "";
  if (isTopicMode) {
    return (
      <SpeakingTopicExercise
        exercise={props.exercise}
        onAnswer={props.onAnswer}
        disabled={props.disabled}
        speechLang={props.speechLang}
      />
    );
  }
  return <SpeakingRepeatExercise {...props} />;
}

function SpeakingRepeatExercise({
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
  const { t } = useI18n();
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
      setError(
        ev.error === "not-allowed"
          ? t("lesson.speak.micBlocked")
          : t("lesson.speak.error", { detail: ev.error }),
      );
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
            {t("lesson.speak.heading")}
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
          {t("lesson.speak.heard")}
        </p>
        <p className="text-base text-navy min-h-[1.5rem]">
          {transcript ||
            (listening ? (
              t("lesson.speak.listening")
            ) : (
              <span className="text-navy/30">{t("lesson.speak.press")}</span>
            ))}
        </p>
      </div>

      {error && (
        <div className="text-sm text-red-600 bg-red-50 border border-red-200 rounded-xl px-3.5 py-2.5">
          {error}
        </div>
      )}

      {!supported && (
        <div className="text-sm text-amber-800 bg-amber-50 border border-amber-200 rounded-xl px-3.5 py-2.5">
          {t("lesson.speak.unsupported")}
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
            {t("lesson.speak.stopRecording")}
          </button>
        ) : (
          <button
            type="button"
            onClick={start}
            disabled={disabled || !supported}
            className="flex-1 py-3 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {transcript
              ? t("lesson.speak.tryAgain")
              : t("lesson.speak.startRecording")}
          </button>
        )}
        <button
          type="button"
          onClick={submit}
          disabled={disabled || !transcript.trim()}
          className="flex-1 py-3 text-sm font-semibold text-teal-dark bg-teal-light border border-teal/40 rounded-xl hover:bg-teal-light/70 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {supported ? t("lesson.speak.submit") : t("lesson.speak.skip")}
        </button>
      </div>
    </div>
  );
}

// ---------------- Main component ----------------

type TeachingPhase = "intro" | "vocab" | "dialogue" | "grammar" | "exercises";

function DialoguePhase({
  lesson,
  speak,
}: {
  lesson: DbLesson;
  speak: (text: string) => void;
}) {
  const { t } = useI18n();
  // For conversation lessons (lesson 8), hide English by default and let the
  // user reveal it. For teaching dialogues, show both side by side.
  const isConversation = lesson.type === "conversation";
  const [showEnglish, setShowEnglish] = useState(!isConversation);
  return (
    <>
      <p className="text-xs font-semibold text-teal-dark uppercase tracking-wider mb-3">
        {isConversation
          ? t("lesson.dialogue.conversation")
          : t("lesson.dialogue.dialogue")}
      </p>
      <div className="flex items-center justify-between gap-3 mb-5 flex-wrap">
        <h2 className="text-xl font-bold text-navy">
          {isConversation
            ? t("lesson.dialogue.convHeading")
            : t("lesson.dialogue.inContext")}
        </h2>
        <div className="flex items-center gap-2">
          {isConversation && (
            <button
              type="button"
              onClick={() => setShowEnglish((v) => !v)}
              className="inline-flex items-center gap-2 px-3 py-1.5 text-xs font-semibold rounded-full bg-navy/5 text-navy/70 hover:bg-navy/10 transition-colors"
            >
              {showEnglish
                ? t("lesson.dialogue.hideEnglish")
                : t("lesson.dialogue.revealEnglish")}
            </button>
          )}
          <button
            type="button"
            onClick={() => speak(lesson.dialogue!.map((d) => d.spanish).join(". "))}
            className="inline-flex items-center gap-2 px-3 py-1.5 text-xs font-semibold rounded-full bg-teal-light text-teal-dark hover:bg-teal hover:text-white transition-colors"
          >
            <svg className="w-3 h-3" fill="currentColor" viewBox="0 0 24 24">
              <path d="M8 5v14l11-7z" />
            </svg>
            {t("lesson.dialogue.listenAll")}
          </button>
        </div>
      </div>
      <div className="space-y-3">
        {lesson.dialogue!.map((d, i) => (
          <div
            key={i}
            className={`grid ${showEnglish ? "grid-cols-[auto_1fr_1fr]" : "grid-cols-[auto_1fr]"} gap-3 items-start text-sm`}
          >
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
            {showEnglish && (
              <div className="text-navy/50 italic pt-4">{d.english}</div>
            )}
          </div>
        ))}
      </div>
    </>
  );
}

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
  const { t } = useI18n();
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
    const voice = pickVoiceForLang(speechLang);
    if (voice) u.voice = voice;
    u.rate = 0.85;
    window.speechSynthesis.speak(u);
  }

  return (
    <main className="min-h-screen bg-background px-4 py-10">
      <div className="max-w-3xl mx-auto">
        <div className="flex items-center justify-between mb-6 text-xs text-navy/50">
          <Link href={`/learn/${languageSlug}`} className="hover:text-teal transition-colors">
            ← {t("lesson.teaching.backToCourse")}
          </Link>
          <span>
            {t("lesson.teaching.step", {
              current: idx + 1,
              total: phasesInOrder.length + (hasExercises ? 1 : 0),
            })}
          </span>
        </div>

        <div className="bg-white border border-border rounded-2xl p-8 shadow-sm">
          {phase === "intro" && (
            <>
              <p className="text-xs font-semibold text-teal-dark uppercase tracking-wider mb-3">
                {t("lesson.teaching.intro")}
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
                {t("lesson.teaching.vocab")}
              </p>
              <h2 className="text-xl font-bold text-navy mb-5">
                {t("lesson.teaching.learnWords")}
              </h2>
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
            <DialoguePhase lesson={lesson} speak={speak} />
          )}

          {phase === "grammar" && hasGrammar && (
            <>
              <p className="text-xs font-semibold text-teal-dark uppercase tracking-wider mb-3">
                {t("lesson.teaching.grammar")}
              </p>
              <h2 className="text-xl font-bold text-navy mb-4">
                {t("lesson.teaching.quickRule")}
              </h2>
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
              ← {t("lesson.teaching.back")}
            </button>
            <button
              type="button"
              onClick={next}
              className="px-6 py-2.5 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors"
            >
              {isLastPhase
                ? hasExercises
                  ? `${t("lesson.teaching.startExercises")} →`
                  : t("lesson.teaching.done")
                : `${t("lesson.teaching.next")} →`}
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
  level,
  sectionTitle,
}: Props) {
  const router = useRouter();
  const { t } = useI18n();
  const speechLang = SPEECH_LANG_CODES[languageSlug] ?? "en-US";
  const [pending, startTransition] = useTransition();
  const [phase, setPhase] = useState<TeachingPhase>("intro");
  const [step, setStep] = useState(0);
  const [pickedAnswer, setPickedAnswer] = useState<string | null>(null);
  const [showFeedback, setShowFeedback] = useState(false);
  const [wasCorrect, setWasCorrect] = useState(false);
  const [correctCount, setCorrectCount] = useState(0);
  // AI-graded responses (writing & speaking) populate these. The rich
  // feedback panel below replaces the simple correct/incorrect footer
  // whenever we have a graded response in hand.
  const [grading, setGrading] = useState(false);
  const [gradedResponse, setGradedResponse] =
    useState<GradedLessonResponse | null>(null);
  // Indexes (into the `exercises` array) of questions the user got wrong on
  // their first pass through the lesson. They'll be re-shown in a review
  // phase before the user can finish.
  const [wrongIndexes, setWrongIndexes] = useState<number[]>([]);
  const [inReview, setInReview] = useState(false);
  const [reviewIdx, setReviewIdx] = useState(0);
  // Bumped on every review retry to force the exercise component to remount,
  // clearing any typed-in input or matched pairs from the failed attempt.
  const [attemptKey, setAttemptKey] = useState(0);
  const isUnitTest = lesson.type === "unit_test";
  const passingScore = 7;
  const [completion, setCompletion] = useState<{
    xp_earned: number;
    already_completed: boolean;
    current_streak?: number;
    saved: boolean;
    not_authenticated?: boolean;
    error?: string;
    unit_test_score?: number;
    unit_test_total?: number;
    unit_test_passed?: boolean;
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
          <h1 className="text-xl font-bold text-navy mb-2">
            {t("lesson.empty.heading")}
          </h1>
          <p className="text-sm text-navy/60 mb-6">{t("lesson.empty.body")}</p>
          <Link
            href={`/learn/${languageSlug}`}
            className="inline-block px-5 py-2.5 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors"
          >
            {t("lesson.teaching.backToCourse")}
          </Link>
        </div>
      </main>
    );
  }

  // Which exercise is currently on screen: during the main pass it's
  // `step`; during the review pass we look up the next index that the user
  // got wrong.
  const reviewExerciseIdx = inReview ? wrongIndexes[reviewIdx] ?? 0 : step;
  const exercise = exercises[reviewExerciseIdx];
  const isLastMain = step === exercises.length - 1;
  const isLastReview = inReview && reviewIdx === wrongIndexes.length - 1;
  const xpPerExercise = Math.max(1, Math.floor(lesson.xp_reward / exercises.length));
  // Progress: main pass fills the bar to 100% by the last exercise; the
  // review pass holds it at 100% (we're past "doing the lesson" now).
  const progressPct = inReview
    ? 100
    : ((step + (showFeedback ? 1 : 0)) / exercises.length) * 100;

  function handleAnswer(answer: string) {
    if (showFeedback || grading) return;
    // Writing, speaking and typed-listening (no MC options) go through the
    // AI grader. Old-format listening with MC options falls through to the
    // existing local comparison below.
    const isTypedListening =
      exercise.type === "listening" &&
      (!exercise.wrong_answers || exercise.wrong_answers.length === 0);
    if (
      exercise.type === "speaking" ||
      (exercise.type as string) === "writing" ||
      isTypedListening
    ) {
      gradeViaAI(answer);
      return;
    }
    let correct = false;
    if (exercise.type === "matching") {
      correct = true; // matching only fires when fully matched
    } else {
      correct =
        normalize(answer) === normalize(exercise.correct_answer);
    }
    setPickedAnswer(answer);
    setWasCorrect(correct);
    if (correct && !inReview) setCorrectCount((c) => c + 1);
    if (!correct && !inReview) {
      setWrongIndexes((arr) => (arr.includes(step) ? arr : [...arr, step]));
    }
    setShowFeedback(true);
  }

  async function gradeViaAI(answer: string) {
    setPickedAnswer(answer);
    setGrading(true);
    setGradedResponse(null);
    try {
      const res = await fetch("/api/grade-lesson-response", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({
          type:
            exercise.type === "listening"
              ? "listening"
              : (exercise.type as string) === "writing"
                ? "writing"
                : "speaking",
          prompt: stripPhonetic(exercise.question),
          response: answer,
          level,
          section: sectionTitle,
          lessonNumber: lesson.order_index,
          language: languageSlug,
          lessonId: lesson.id,
          exerciseId: exercise.id,
        }),
      });
      let result: GradedLessonResponse;
      if (!res.ok) {
        result = {
          score: 5,
          feedback:
            "We couldn't auto-grade this response — a neutral score was recorded.",
          passed: false,
          correctedVersion: "",
          encouragement: "Keep practising!",
        };
      } else {
        result = (await res.json()) as GradedLessonResponse;
      }
      setGradedResponse(result);
      setWasCorrect(result.passed);
      if (result.passed && !inReview) setCorrectCount((c) => c + 1);
      if (!result.passed && !inReview) {
        setWrongIndexes((arr) =>
          arr.includes(step) ? arr : [...arr, step],
        );
      }
      setShowFeedback(true);
    } catch (err) {
      console.error("[lesson] grading failed", err);
      setGradedResponse({
        score: 5,
        feedback: "We couldn't reach the grader. A neutral score was recorded.",
        passed: false,
        correctedVersion: "",
        encouragement: "Keep practising!",
      });
      setWasCorrect(false);
      setShowFeedback(true);
    } finally {
      setGrading(false);
    }
  }

  function handleRetake() {
    if (typeof window !== "undefined" && "speechSynthesis" in window) {
      window.speechSynthesis.cancel();
    }
    setStep(0);
    setPickedAnswer(null);
    setShowFeedback(false); setGradedResponse(null);
    setWasCorrect(false);
    setCorrectCount(0);
    setWrongIndexes([]);
    setInReview(false);
    setReviewIdx(0);
    setCompletion(null);
    setPhase("exercises");
  }

  function finishLesson() {
    // Always save progress and redirect. No score-based gate — even if the
    // user fails a unit test, we record the attempt and let them retake
    // from the section page. Stranding them on a completion screen is
    // worse than recording a failed attempt.
    startTransition(async () => {
      try {
        const result = await completeLesson(lesson.id, languageSlug);
        setCompletion({
          xp_earned: result.ok ? result.xp_earned : 0,
          already_completed: result.ok ? result.already_completed : false,
          current_streak: result.ok ? result.current_streak : undefined,
          saved: result.ok,
          not_authenticated: result.not_authenticated,
          error: result.ok
            ? undefined
            : (result.error ?? t("lesson.errors.couldNotSave")),
          unit_test_score: isUnitTest ? correctCount : undefined,
          unit_test_total: isUnitTest ? exercises.length : undefined,
          unit_test_passed: isUnitTest ? correctCount >= passingScore : undefined,
        });
      } catch (err) {
        setCompletion({
          xp_earned: 0,
          already_completed: false,
          saved: false,
          error:
            err instanceof Error ? err.message : t("lesson.errors.unexpected"),
        });
      }
    });
  }

  function handleContinue() {
    // ----- REVIEW PASS -----
    if (inReview) {
      // Wrong on a review item: stay on this question, let them retry.
      if (!wasCorrect) {
        setPickedAnswer(null);
        setShowFeedback(false); setGradedResponse(null);
        setWasCorrect(false);
        setAttemptKey((k) => k + 1);
        return;
      }
      // Correct: advance to the next review item, or finish if done.
      if (isLastReview) {
        finishLesson();
        return;
      }
      setReviewIdx((i) => i + 1);
      setPickedAnswer(null);
      setShowFeedback(false); setGradedResponse(null);
      setWasCorrect(false);
      return;
    }

    // ----- MAIN PASS -----
    if (!isLastMain) {
      setStep((s) => s + 1);
      setPickedAnswer(null);
      setShowFeedback(false); setGradedResponse(null);
      setWasCorrect(false);
      return;
    }
    // Last main-pass exercise just answered. If the user got anything wrong,
    // enter the review phase first.
    if (wrongIndexes.length > 0) {
      setInReview(true);
      setReviewIdx(0);
      setPickedAnswer(null);
      setShowFeedback(false); setGradedResponse(null);
      setWasCorrect(false);
      return;
    }
    finishLesson();
  }

  if (completion && isUnitTest) {
    const score = completion.unit_test_score ?? 0;
    const total = completion.unit_test_total ?? exercises.length;
    const passed = completion.unit_test_passed ?? false;
    const headerBg = passed ? "from-teal to-teal-dark" : "from-amber-400 to-amber-600";
    return (
      <main className="min-h-screen bg-gradient-to-b from-teal-light to-background flex items-center justify-center p-6">
        <div className="bg-white rounded-3xl border border-border p-8 sm:p-12 text-center max-w-md w-full shadow-xl">
          <div className={`w-20 h-20 mx-auto mb-6 rounded-full bg-gradient-to-br ${headerBg} flex items-center justify-center shadow-lg`}>
            <svg className="w-12 h-12 text-white" fill="none" stroke="currentColor" strokeWidth={3} viewBox="0 0 24 24">
              {passed ? (
                <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
              ) : (
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" />
              )}
            </svg>
          </div>
          <p className="text-xs font-semibold text-teal-dark uppercase tracking-wider mb-2">
            {lesson.title}
          </p>
          <h1 className="text-3xl font-bold text-navy mb-2">
            {passed
              ? t("lesson.unitTest.passed")
              : t("lesson.unitTest.failed")}
          </h1>
          <p className="text-sm text-navy/60 mb-6">
            <span
              dangerouslySetInnerHTML={{
                __html: t("lesson.unitTest.score", { score, total }).replace(
                  /(\d+\s*\/\s*\d+)/,
                  '<span class="font-bold text-navy">$1</span>',
                ),
              }}
            />{" "}
            {passed
              ? t("lesson.unitTest.great")
              : t("lesson.unitTest.needPass", { needed: passingScore })}
          </p>
          {passed && (
            <div className="bg-teal-light rounded-2xl p-4 mb-6">
              <p className="text-xs text-teal-dark font-semibold uppercase tracking-wide mb-1">
                {t("lesson.complete.xpEarned")}
              </p>
              <p className="text-2xl font-bold text-teal-dark">
                {completion.already_completed ? 0 : completion.xp_earned}
              </p>
            </div>
          )}
          {!completion.saved && completion.error && (
            <p className="text-xs text-red-700 bg-red-50 border border-red-200 rounded-xl px-3 py-2 mb-4 text-start">
              {completion.error}
            </p>
          )}
          <div className="flex flex-col gap-2">
            <button
              type="button"
              onClick={handleRetake}
              className="block py-3 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors"
            >
              {passed
                ? t("lesson.unitTest.retake")
                : t("lesson.unitTest.tryAgain")}
            </button>
            <Link
              href={sectionUrl}
              className="block py-3 text-sm font-medium text-navy/60 hover:text-teal transition-colors"
            >
              {t("lesson.complete.backToSection")}
            </Link>
          </div>
        </div>
      </main>
    );
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
              <h1 className="text-3xl font-bold text-navy mb-2">
                {t("lesson.complete.heading")}
              </h1>
              <p className="text-sm text-navy/60 mb-6">
                {completion.already_completed
                  ? t("lesson.complete.alreadyMastered")
                  : t("lesson.complete.body", {
                      title: lesson.title,
                      language: languageName,
                    })}
              </p>

              <div className="grid grid-cols-2 gap-3 mb-8">
                <div className="bg-teal-light rounded-2xl p-4">
                  <p className="text-xs text-teal-dark font-semibold uppercase tracking-wide mb-1">
                    {t("lesson.complete.xpEarned")}
                  </p>
                  <p className="text-2xl font-bold text-teal-dark">
                    {completion.already_completed ? 0 : completion.xp_earned}
                  </p>
                </div>
                <div className="bg-peach-light rounded-2xl p-4">
                  <p className="text-xs text-amber-700 font-semibold uppercase tracking-wide mb-1">
                    {t("lesson.complete.streak")}
                  </p>
                  <p className="text-2xl font-bold text-amber-700">
                    🔥 {completion.current_streak ?? 0}
                  </p>
                </div>
              </div>

              <p className="text-xs text-navy/40 mb-3">
                {t("lesson.complete.redirecting")}
              </p>
              <div className="flex flex-col gap-2">
                <Link
                  href={sectionUrl}
                  className="block py-3 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors"
                >
                  {t("lesson.complete.backToSection")}
                </Link>
                <Link
                  href="/dashboard"
                  className="block py-3 text-sm font-medium text-navy/60 hover:text-teal transition-colors"
                >
                  {t("lesson.complete.viewDashboard")}
                </Link>
              </div>
            </>
          ) : completion.not_authenticated ? (
            <>
              <h1 className="text-2xl font-bold text-navy mb-2">
                {t("lesson.signIn.heading")}
              </h1>
              <p className="text-sm text-navy/60 mb-6">
                {t("lesson.signIn.body", { title: lesson.title })}
              </p>
              <div className="flex flex-col gap-2">
                <Link
                  href={`/login?next=/learn/${languageSlug}/${lesson.id}`}
                  className="block py-3 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors"
                >
                  {t("lesson.signIn.cta")}
                </Link>
                <button
                  type="button"
                  onClick={() => setCompletion(null)}
                  className="block py-3 text-sm font-medium text-navy/60 hover:text-teal transition-colors"
                >
                  {t("lesson.signIn.back")}
                </button>
              </div>
            </>
          ) : (
            <>
              <h1 className="text-2xl font-bold text-navy mb-2">
                {t("lesson.saveFail.heading")}
              </h1>
              <p className="text-sm text-navy/60 mb-3">
                {t("lesson.saveFail.body")}
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
                  {pending
                    ? t("lesson.saveFail.retrying")
                    : t("lesson.saveFail.retry")}
                </button>
                <Link
                  href={sectionUrl}
                  className="block py-3 text-sm font-medium text-navy/60 hover:text-teal transition-colors"
                >
                  {t("lesson.saveFail.skip")}
                </Link>
              </div>
            </>
          )}
        </div>
      </main>
    );
  }

  const encouragement = wasCorrect
    ? t(`lesson.encouragement.right.${step % 4}`)
    : t(`lesson.encouragement.wrong.${step % 3}`);

  return (
    <main className="min-h-screen bg-background flex flex-col">
      <header className="border-b border-border bg-white/60 backdrop-blur sticky top-0 z-10">
        <div className="max-w-2xl mx-auto px-4 sm:px-6 py-4 flex items-center gap-4">
          <Link
            href={`/learn/${languageSlug}`}
            aria-label={t("lesson.header.quit")}
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
            {inReview
              ? t("lesson.review.counter", {
                  current: reviewIdx + 1,
                  total: wrongIndexes.length,
                })
              : t("lesson.header.progress", {
                  current: step + 1,
                  total: exercises.length,
                })}
          </span>
        </div>
      </header>

      <section className="flex-1 max-w-2xl mx-auto w-full px-4 sm:px-6 py-10">
        {inReview && (
          <div className="mb-6 rounded-2xl border-2 border-red-300 bg-red-50 px-5 py-4">
            <p className="text-xs font-bold uppercase tracking-wider text-red-700 mb-1">
              {t("lesson.review.banner", {
                current: reviewIdx + 1,
                total: wrongIndexes.length,
              })}
            </p>
            <p className="text-sm font-semibold text-red-700">
              {t("lesson.review.body")}
            </p>
          </div>
        )}
        <p className="text-xs font-semibold uppercase tracking-wider text-teal-dark mb-2">
          {exercise.type.replace("_", " ")}
        </p>
        <h1 className="text-2xl sm:text-3xl font-bold text-navy mb-2 leading-snug">
          {stripPhonetic(exercise.question)}
        </h1>
        {exercise.translation &&
          exercise.type !== "speaking" &&
          exercise.type !== "listening" && (
            <p className="text-sm text-navy/50 mb-8">
              {stripPhonetic(exercise.translation)}
            </p>
          )}
        <div className="mt-8" key={`${exercise.id}-${attemptKey}`}>
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

      {/* Grading-in-progress band shown while we wait for the AI grader. */}
      {grading && (
        <footer className="border-t-2 px-4 sm:px-6 py-6 bg-peach-light border-peach-dark/30">
          <div className="max-w-2xl mx-auto flex items-center gap-3">
            <span className="w-3 h-3 rounded-full bg-teal animate-pulse" />
            <p className="text-sm font-semibold text-navy/80">
              Grading your response…
            </p>
          </div>
        </footer>
      )}

      {/* Rich AI feedback panel for writing & speaking submissions. */}
      {showFeedback && gradedResponse && (
        <footer className="border-t-2 border-border bg-white px-4 sm:px-6 py-6">
          <div className="max-w-2xl mx-auto">
            <FeedbackPanel
              graded={gradedResponse}
              continueLabel={
                pending
                  ? t("lesson.footer.saving")
                  : inReview
                    ? gradedResponse.passed
                      ? isLastReview
                        ? t("lesson.footer.finish")
                        : `${t("lesson.review.next")} →`
                      : t("lesson.review.tryAgain")
                    : isLastMain
                      ? wrongIndexes.length > 0
                        ? `${t("lesson.footer.reviewMistakes")} →`
                        : t("lesson.footer.finish")
                      : t("lesson.footer.continue")
              }
              onContinue={handleContinue}
              continueDisabled={pending}
            />
          </div>
        </footer>
      )}

      {/* Original simple footer for non-AI-graded exercise types. */}
      {showFeedback && !gradedResponse && (
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
                <p className="text-sm text-teal-dark/80">
                  {t("lesson.footer.xp", { xp: xpPerExercise })}
                </p>
              ) : (
                <p className="text-sm text-red-700/80">
                  {t("lesson.footer.noXp")}
                </p>
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
              {pending
                ? t("lesson.footer.saving")
                : inReview
                  ? wasCorrect
                    ? isLastReview
                      ? t("lesson.footer.finish")
                      : `${t("lesson.review.next")} →`
                    : t("lesson.review.tryAgain")
                  : isLastMain
                    ? wrongIndexes.length > 0
                      ? `${t("lesson.footer.reviewMistakes")} →`
                      : t("lesson.footer.finish")
                    : t("lesson.footer.continue")}
            </button>
          </div>
        </footer>
      )}
    </main>
  );
}

// ---------- New typed-response Listening exercise (A1+ AI-graded) ----------
function ListeningTypedExercise({
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
  // The TTS reads exercise.question (the Spanish audio prompt). The user
  // types a Spanish reply that the AI grader scores.
  const [typed, setTyped] = useState("");
  const { isPlaying, play, stop, supported: hasTts } = useTts(
    stripPhonetic(exercise.question),
    speechLang,
  );

  // Auto-play once on mount when supported.
  useEffect(() => {
    if (hasTts) play();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  function submit() {
    if (disabled || !typed.trim()) return;
    onAnswer(typed.trim());
  }

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
            Listening
          </p>
          <p className="text-sm text-navy/70">
            {hasTts
              ? "Press play to hear the question. You can replay as many times as you like."
              : "Audio is not available in this browser. Type your best guess."}
          </p>
        </div>
      </div>

      <div>
        <label
          htmlFor="listening-typed"
          className="text-xs font-semibold uppercase tracking-wider text-navy/50 mb-2 block"
        >
          Your Spanish reply
        </label>
        <textarea
          id="listening-typed"
          value={typed}
          onChange={(e) => setTyped(e.target.value)}
          disabled={disabled}
          placeholder="Write a Spanish reply to what you heard…"
          rows={3}
          className="w-full px-4 py-3 rounded-xl border-2 border-border bg-white text-navy text-base focus:border-teal focus:outline-none resize-none disabled:bg-navy/5"
        />
      </div>

      <button
        type="button"
        onClick={submit}
        disabled={disabled || !typed.trim()}
        className="w-full py-3 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
      >
        Submit answer
      </button>
    </div>
  );
}

// ---------- New topic-prompt Speaking exercise (A1+ AI-graded) ----------
function SpeakingTopicExercise({
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
  const { t } = useI18n();
  const [transcript, setTranscript] = useState("");
  const [recording, setRecording] = useState(false);
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
    rec.continuous = true;
    rec.onresult = (ev) => {
      let text = "";
      for (let i = 0; i < ev.results.length; i++) {
        text += ev.results[i][0].transcript + " ";
      }
      setTranscript(text.trim());
    };
    rec.onerror = (ev) => {
      setError(
        ev.error === "not-allowed"
          ? t("lesson.speak.micBlocked")
          : t("lesson.speak.error", { detail: ev.error }),
      );
      setRecording(false);
    };
    rec.onend = () => setRecording(false);
    recRef.current = rec;
    setRecording(true);
    rec.start();
  }

  function done() {
    recRef.current?.stop();
    setRecording(false);
    if (transcript.trim() && !disabled) {
      onAnswer(transcript.trim());
    }
  }

  return (
    <div className="space-y-5">
      <div className="rounded-2xl border-2 border-peach-dark/40 bg-peach-light p-5">
        <p className="text-xs font-semibold uppercase tracking-wider text-amber-800 mb-2">
          Topic
        </p>
        <p className="text-base sm:text-lg font-semibold text-navy leading-snug">
          {stripPhonetic(exercise.question)}
        </p>
      </div>

      <div className="rounded-2xl border-2 border-border bg-white p-5 min-h-[120px]">
        <p className="text-xs font-semibold uppercase tracking-wider text-navy/50 mb-2">
          Transcript
        </p>
        <p className="text-base text-navy whitespace-pre-wrap min-h-[1.5rem]">
          {transcript ||
            (recording ? (
              <span className="text-navy/40 italic">Listening…</span>
            ) : (
              <span className="text-navy/30">
                Press “Start recording”, speak in Spanish, then press “I am
                done speaking”.
              </span>
            ))}
        </p>
      </div>

      {error && (
        <div className="text-sm text-red-600 bg-red-50 border border-red-200 rounded-xl px-3.5 py-2.5">
          {error}
        </div>
      )}

      {!supported && (
        <div className="text-sm text-amber-800 bg-amber-50 border border-amber-200 rounded-xl px-3.5 py-2.5">
          {t("lesson.speak.unsupported")}
        </div>
      )}

      <div className="flex flex-col sm:flex-row gap-3 items-stretch">
        {!recording ? (
          <button
            type="button"
            onClick={start}
            disabled={disabled || !supported}
            className="flex-1 inline-flex items-center justify-center gap-2 py-3 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <span className="w-2.5 h-2.5 rounded-full bg-white/90" />
            {transcript ? "Record again" : "Start recording"}
          </button>
        ) : (
          <button
            type="button"
            onClick={done}
            disabled={disabled}
            className="flex-1 inline-flex items-center justify-center gap-2 py-3 text-sm font-semibold text-white bg-red-500 rounded-xl hover:bg-red-600 transition-colors disabled:opacity-50"
          >
            {/* Pulsing red mic indicator while recording */}
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
            I am done speaking
          </button>
        )}
      </div>
    </div>
  );
}

// ---------- Instant-feedback panel for AI-graded responses ----------
function FeedbackPanel({
  graded,
  continueLabel,
  onContinue,
  continueDisabled,
}: {
  graded: GradedLessonResponse;
  continueLabel: string;
  onContinue: () => void;
  continueDisabled: boolean;
}) {
  const score = Math.max(0, Math.min(10, graded.score));
  const pct = (score / 10) * 100;
  // Color thresholds: <6 red, 6-7 yellow, 8-10 green.
  const tone =
    score >= 8 ? "green" : score >= 6 ? "yellow" : "red";
  const barClass =
    tone === "green"
      ? "bg-emerald-500"
      : tone === "yellow"
        ? "bg-amber-400"
        : "bg-red-500";
  const labelClass =
    tone === "green"
      ? "text-emerald-700"
      : tone === "yellow"
        ? "text-amber-700"
        : "text-red-700";

  return (
    <div className="space-y-5">
      <div>
        <div className="flex items-center justify-between mb-1.5">
          <p className="text-xs font-semibold uppercase tracking-wider text-navy/50">
            Score
          </p>
          <p className={`text-xl font-bold tabular-nums ${labelClass}`}>
            {score}/10
          </p>
        </div>
        <div className="h-3 w-full rounded-full bg-navy/10 overflow-hidden">
          <div
            className={`h-full rounded-full transition-all duration-500 ${barClass}`}
            style={{ width: `${pct}%` }}
          />
        </div>
      </div>

      <div>
        <p className="text-xs font-semibold uppercase tracking-wider text-navy/50 mb-1.5">
          Feedback
        </p>
        <p className="text-sm text-navy leading-relaxed">{graded.feedback}</p>
      </div>

      {graded.correctedVersion && (
        <div>
          <p className="text-xs font-semibold uppercase tracking-wider text-navy/50 mb-1.5">
            What a native would say
          </p>
          <p className="text-sm text-navy bg-teal-light border border-teal/30 rounded-xl px-4 py-3 leading-relaxed">
            {graded.correctedVersion}
          </p>
        </div>
      )}

      <p className={`text-base font-semibold ${labelClass}`}>
        {graded.encouragement}
      </p>

      <div className="flex justify-end">
        <button
          type="button"
          onClick={onContinue}
          disabled={continueDisabled}
          className="px-8 py-3 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {continueLabel}
        </button>
      </div>
    </div>
  );
}

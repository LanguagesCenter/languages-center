"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import type { SkippedSpeakingRow } from "@/lib/traveler";
import {
  speak,
  warmUpSpeech,
  isAudioAvailable,
  type PlayHandle,
} from "@/lib/speech";
import type { TranslationCheck } from "@/lib/traveler-preview";
import { markSkipCompleted } from "./actions";

// Minimal client-side speech recognition — same engine the lesson
// runner uses, trimmed down for this standalone practice flow. Kept
// in-file because it only runs here and the shared helpers in
// PreviewLessonRunner are not exported.

interface ISpeechRecognition extends EventTarget {
  lang: string;
  interimResults: boolean;
  continuous: boolean;
  onresult:
    | ((this: ISpeechRecognition, ev: SpeechRecognitionResultEvent) => void)
    | null;
  onerror:
    | ((this: ISpeechRecognition, ev: SpeechRecognitionErrorEvent) => void)
    | null;
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
function getSR(): (new () => ISpeechRecognition) | null {
  if (typeof window === "undefined") return null;
  const w = window as unknown as {
    SpeechRecognition?: new () => ISpeechRecognition;
    webkitSpeechRecognition?: new () => ISpeechRecognition;
  };
  return w.SpeechRecognition ?? w.webkitSpeechRecognition ?? null;
}
function norm(s: string): string {
  return s
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/[¿?¡!.,;:]/g, "")
    .replace(/\s+/g, " ")
    .trim();
}
function matches(heard: string, expected: string): boolean {
  const h = norm(heard);
  const e = norm(expected);
  if (h === e) return true;
  if (h.includes(e) || e.includes(h)) return true;
  const ew = e.split(" ");
  const hw = new Set(h.split(" "));
  return ew.filter((w) => hw.has(w)).length / ew.length >= 0.7;
}

export default function SpeakingPracticeRunner({
  rows,
  speechLang,
}: {
  rows: SkippedSpeakingRow[];
  speechLang: string;
}) {
  const router = useRouter();
  // Local copy so we can hide a row immediately after completing it
  // without waiting on the server round-trip.
  const [open, setOpen] = useState<SkippedSpeakingRow[]>(rows);

  // Group open rows by lesson for the UI.
  const grouped = useMemo(() => {
    const map = new Map<number, {
      lessonId: number;
      lessonTitle: string;
      lessonLocation: string;
      lessonOrderIndex: number;
      items: SkippedSpeakingRow[];
    }>();
    for (const r of open) {
      const existing = map.get(r.lessonId);
      if (existing) {
        existing.items.push(r);
      } else {
        map.set(r.lessonId, {
          lessonId: r.lessonId,
          lessonTitle: r.lessonTitle,
          lessonLocation: r.lessonLocation,
          lessonOrderIndex: r.lessonOrderIndex,
          items: [r],
        });
      }
    }
    return Array.from(map.values()).sort(
      (a, b) => a.lessonOrderIndex - b.lessonOrderIndex,
    );
  }, [open]);

  async function markDone(rowId: string) {
    setOpen((cur) => cur.filter((r) => r.id !== rowId));
    try {
      await markSkipCompleted(rowId);
      // Refresh so the city page's badge count updates when the user
      // navigates back.
      router.refresh();
    } catch (err) {
      console.error("markSkipCompleted failed", err);
    }
  }

  if (open.length === 0) {
    return (
      <div className="max-w-xl mx-auto px-4 sm:px-6 py-16 text-center space-y-4">
        <div className="mx-auto w-20 h-20 rounded-full bg-teal-light flex items-center justify-center">
          <svg className="w-10 h-10 text-teal-dark" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
          </svg>
        </div>
        <h2 className="text-2xl font-black text-navy">All caught up</h2>
        <p className="text-sm text-navy/60 leading-relaxed">
          You don&apos;t have any speaking exercises waiting. Come back here any
          time an exercise asks you to speak and you&apos;re not in a place where
          you can — we&apos;ll save it and you can practice later.
        </p>
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto px-4 sm:px-6 py-6 space-y-6">
      {grouped.map((group) => (
        <div
          key={group.lessonId}
          className="bg-white border border-border rounded-2xl p-5 sm:p-6 shadow-sm space-y-4"
        >
          <div>
            <p className="text-[10px] uppercase tracking-[0.18em] font-bold text-teal-dark">
              Lesson {group.lessonOrderIndex}
            </p>
            <h2 className="text-lg sm:text-xl font-bold text-navy tracking-tight leading-tight mt-0.5">
              {group.lessonTitle}
            </h2>
            <p className="text-xs text-navy/60 mt-0.5">{group.lessonLocation}</p>
          </div>
          <div className="space-y-3">
            {group.items.map((item) => (
              <PracticeItem
                key={item.id}
                row={item}
                speechLang={speechLang}
                onDone={() => markDone(item.id)}
              />
            ))}
          </div>
        </div>
      ))}
      <div className="pt-2 text-center">
        <Link
          href=".."
          className="text-sm text-teal-dark hover:underline"
        >
          ← Back to city
        </Link>
      </div>
    </div>
  );
}

function PracticeItem({
  row,
  speechLang,
  onDone,
}: {
  row: SkippedSpeakingRow;
  speechLang: string;
  onDone: () => void;
}) {
  const [transcript, setTranscript] = useState("");
  const [listening, setListening] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [status, setStatus] = useState<"idle" | "correct" | "wrong" | "xcheck">(
    "idle",
  );
  const [audioUnavailable, setAudioUnavailable] = useState(false);
  const SR = getSR();
  const supported = SR !== null;
  const check: TranslationCheck | null = row.translationCheck ?? null;

  useEffect(() => {
    warmUpSpeech();
  }, []);

  function playAudio() {
    speak(row.expected, speechLang, {
      rate: 0.9,
      onerror: (reason) => {
        if (reason === "speech-synthesis-unavailable") setAudioUnavailable(true);
      },
    });
    setTimeout(() => {
      if (!isAudioAvailable()) setAudioUnavailable(true);
    }, 2000);
  }

  function markPassed() {
    // If we have a translation check, show it before marking done so
    // the learner has to demonstrate both production AND meaning.
    if (check) {
      setStatus("xcheck");
      return;
    }
    onDone();
  }

  function start() {
    if (!SR) return;
    setError(null);
    setTranscript("");
    setStatus("idle");
    const rec = new SR();
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
          ? "Microphone blocked — allow it in your browser."
          : `Error: ${ev.error}`,
      );
      setListening(false);
    };
    rec.onend = () => {
      setListening(false);
      setTranscript((cur) => {
        if (cur.trim()) {
          const ok = matches(cur, row.expected);
          if (ok) {
            setStatus("correct");
            markPassed();
          } else {
            setStatus("wrong");
          }
        }
        return cur;
      });
    };
    setListening(true);
    rec.start();
  }

  if (status === "xcheck" && check) {
    return (
      <PracticeXCheck
        check={check}
        phrase={row.expected}
        onDone={() => onDone()}
      />
    );
  }

  return (
    <div
      className={`rounded-xl border-2 p-4 ${
        status === "correct"
          ? "border-teal/40 bg-teal-light"
          : status === "wrong"
            ? "border-red-300 bg-red-50"
            : "border-border bg-white"
      }`}
    >
      <p className="text-sm text-navy/70 mb-2">{row.prompt}</p>
      <div className="flex items-center gap-3 mb-3">
        <div className="flex-1 min-w-0">
          <p className="text-lg font-bold text-navy leading-tight">
            {row.expected}
          </p>
        </div>
        {audioUnavailable ? (
          <span
            title="Audio isn't available on this device"
            className="shrink-0 w-10 h-10 rounded-full bg-navy/10 text-navy/40 flex items-center justify-center"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 6v12m6-6H6" />
            </svg>
          </span>
        ) : (
          <button
            type="button"
            onClick={playAudio}
            aria-label="Play"
            className="shrink-0 w-10 h-10 rounded-full bg-teal text-white flex items-center justify-center hover:bg-teal-dark transition-colors"
          >
            <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
              <path d="M8 5v14l11-7z" />
            </svg>
          </button>
        )}
      </div>
      <div className="rounded-lg border border-border bg-white px-3 py-2 min-h-[52px]">
        <p className="text-[10px] font-semibold uppercase tracking-wider text-navy/50 mb-1">
          You said
        </p>
        <p className="text-sm text-navy min-h-[1.25rem]">
          {transcript ||
            (listening ? (
              <span className="text-navy/50">Listening…</span>
            ) : (
              <span className="text-navy/30">Press the mic and say it aloud.</span>
            ))}
        </p>
      </div>
      {status === "wrong" && (
        <p className="text-xs text-red-600 mt-2">
          Not quite — try again.
        </p>
      )}
      {status === "correct" && (
        <p className="text-xs text-teal-dark font-semibold mt-2">
          ✓ Nice — marking this as done.
        </p>
      )}
      {error && <p className="text-xs text-red-600 mt-2">{error}</p>}
      <div className="flex gap-2 mt-3">
        {supported ? (
          <button
            type="button"
            onClick={start}
            disabled={listening}
            className="flex-1 py-3 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors min-h-[44px] disabled:opacity-60"
          >
            {listening ? "Listening…" : "🎤 Speak"}
          </button>
        ) : (
          <button
            type="button"
            onClick={markPassed}
            className="flex-1 py-3 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors min-h-[44px]"
          >
            I said it — mark done
          </button>
        )}
      </div>
    </div>
  );
}

function PracticeXCheck({
  check,
  phrase,
  onDone,
}: {
  check: TranslationCheck;
  phrase: string;
  onDone: () => void;
}) {
  const [picked, setPicked] = useState<number | null>(null);
  const correctOption = check.options[check.correctIndex];
  if (picked !== null) {
    const ok = picked === check.correctIndex;
    return (
      <div
        className={`rounded-xl border-2 p-4 ${ok ? "border-teal/40 bg-teal-light" : "border-red-300 bg-red-50"}`}
      >
        <div className="flex items-center gap-3 mb-2">
          <span
            className={`inline-flex items-center justify-center w-8 h-8 rounded-full ${ok ? "bg-teal text-white" : "bg-red-500 text-white"}`}
          >
            {ok ? (
              <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={3} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
              </svg>
            ) : (
              <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={3} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
              </svg>
            )}
          </span>
          <p className={`text-sm font-bold ${ok ? "text-teal-dark" : "text-red-700"}`}>
            {ok ? "Correct" : "Not quite"}
          </p>
        </div>
        {!ok && (
          <p className="text-sm text-navy/80 mb-1">
            Correct answer: <span className="font-bold text-navy">{correctOption}</span>
          </p>
        )}
        <p className="text-sm text-navy/80 leading-relaxed">{check.explanation}</p>
        <button
          type="button"
          onClick={onDone}
          className="mt-3 w-full py-3 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors min-h-[44px]"
        >
          Continue →
        </button>
      </div>
    );
  }
  return (
    <div className="rounded-xl border-2 border-border bg-white p-4 space-y-3">
      <p className="text-sm font-semibold text-navy">
        You said <span className="font-black text-teal-dark">“{phrase}”</span>. What does it mean?
      </p>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
        {check.options.map((opt, i) => (
          <button
            key={i}
            type="button"
            onClick={() => setPicked(i)}
            className="py-3 px-4 rounded-xl border-2 border-border bg-white text-navy text-start text-sm font-medium hover:border-teal hover:bg-teal-light transition-all min-h-[44px]"
          >
            {opt}
          </button>
        ))}
      </div>
    </div>
  );
}

"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import Link from "next/link";
import type { TravelPhrase, TravelPhrasebook } from "@/lib/travel-phrases";

// ---------------- TTS ----------------
// Same voice-picker strategy as the lesson player: prefer an exact locale
// match, then any locale of the same base language, then anything that
// starts with the base code. Without this, an English engine will read
// Spanish/French with an American accent.
function pickVoiceForLang(lang: string): SpeechSynthesisVoice | null {
  if (typeof window === "undefined" || !("speechSynthesis" in window)) return null;
  const voices = window.speechSynthesis.getVoices();
  if (voices.length === 0) return null;
  const target = lang.toLowerCase();
  const langPart = target.split("-")[0];
  const exact = voices.find((v) => v.lang.toLowerCase() === target);
  if (exact) return exact;
  const partial = voices.find((v) =>
    v.lang.toLowerCase().startsWith(langPart + "-"),
  );
  if (partial) return partial;
  return voices.find((v) => v.lang.toLowerCase().startsWith(langPart)) ?? null;
}

function primeVoices() {
  if (typeof window === "undefined" || !("speechSynthesis" in window)) return;
  window.speechSynthesis.getVoices();
}

function speak(text: string, lang: string) {
  if (typeof window === "undefined" || !("speechSynthesis" in window)) return;
  try {
    window.speechSynthesis.cancel();
    const u = new SpeechSynthesisUtterance(text);
    u.lang = lang;
    const v = pickVoiceForLang(lang);
    if (v) u.voice = v;
    u.rate = 0.9;
    window.speechSynthesis.speak(u);
  } catch {
    /* ignore */
  }
}

// Speaker icon button — appears next to every phrase in list mode and on
// the back of every flashcard.
function SpeakerButton({
  text,
  lang,
  size = "md",
  label,
}: {
  text: string;
  lang: string;
  size?: "sm" | "md" | "lg";
  label: string;
}) {
  const dim = size === "sm" ? "w-9 h-9" : size === "lg" ? "w-14 h-14" : "w-11 h-11";
  const icon = size === "sm" ? "w-4 h-4" : size === "lg" ? "w-6 h-6" : "w-5 h-5";
  return (
    <button
      type="button"
      onClick={(e) => {
        e.stopPropagation();
        speak(text, lang);
      }}
      aria-label={label}
      title={label}
      className={`shrink-0 ${dim} inline-flex items-center justify-center rounded-full bg-teal-light text-teal-dark hover:bg-teal hover:text-white active:scale-95 transition-all`}
    >
      <svg className={icon} fill="currentColor" viewBox="0 0 24 24">
        <path d="M3 10v4a1 1 0 001 1h3l4.29 4.29a1 1 0 001.71-.71V5.42a1 1 0 00-1.71-.71L7 9H4a1 1 0 00-1 1zm13.5 2a4.5 4.5 0 00-2.5-4.03v8.05A4.5 4.5 0 0016.5 12zM14 3.23v2.06A7 7 0 0119 12a7 7 0 01-5 6.71v2.06A9 9 0 0021 12a9 9 0 00-7-8.77z" />
      </svg>
    </button>
  );
}

// ---------------- Flat phrase list with category info ----------------
interface FlatPhrase extends TravelPhrase {
  categoryId: string;
  categoryTitle: string;
  key: string;
}

function flatten(book: TravelPhrasebook): FlatPhrase[] {
  const out: FlatPhrase[] = [];
  for (const cat of book.categories) {
    for (const p of cat.phrases) {
      out.push({
        ...p,
        categoryId: cat.id,
        categoryTitle: cat.title,
        // Stable per-phrase key derived from the phrase text — safe because
        // each phrasebook has no repeated target-language phrases.
        key: `${cat.id}::${p.phrase}`,
      });
    }
  }
  return out;
}

// ---------------- Known/practice persistence ----------------
type Status = "unset" | "known" | "practice";
type StatusMap = Record<string, Status>;

function storageKey(slug: string) {
  return `travel-guide:${slug}:v1`;
}

function loadStatuses(slug: string): StatusMap {
  if (typeof window === "undefined") return {};
  try {
    const raw = window.localStorage.getItem(storageKey(slug));
    if (!raw) return {};
    const parsed = JSON.parse(raw);
    if (parsed && typeof parsed === "object") return parsed as StatusMap;
  } catch {
    /* ignore */
  }
  return {};
}

function saveStatuses(slug: string, map: StatusMap) {
  if (typeof window === "undefined") return;
  try {
    window.localStorage.setItem(storageKey(slug), JSON.stringify(map));
  } catch {
    /* ignore */
  }
}

// ---------------- Component ----------------
type Mode = "list" | "flashcards";
type Filter = "all" | "practice" | "known";

export default function TravelGuideClient({ book }: { book: TravelPhrasebook }) {
  const flat = useMemo(() => flatten(book), [book]);
  const [mode, setMode] = useState<Mode>("list");
  const [statuses, setStatuses] = useState<StatusMap>({});
  const [hydrated, setHydrated] = useState(false);

  // Warm the TTS voice list once — Chrome returns [] on the very first
  // getVoices() call and only populates after the `voiceschanged` event.
  useEffect(() => {
    primeVoices();
    if (typeof window === "undefined" || !("speechSynthesis" in window)) return;
    const handler = () => primeVoices();
    window.speechSynthesis.addEventListener?.("voiceschanged", handler);
    return () => {
      window.speechSynthesis.removeEventListener?.("voiceschanged", handler);
    };
  }, []);

  // Rehydrate saved marks from localStorage. We deliberately start with an
  // empty map so the first client render matches the SSR output, then swap
  // in the real data on mount. This is exactly the pattern the lint rule
  // warns about, but it's the right call for hydration-safe reads from a
  // browser-only store — see React docs on useSyncExternalStore alternatives.
  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setStatuses(loadStatuses(book.slug));
    setHydrated(true);
  }, [book.slug]);

  const setStatus = useCallback(
    (key: string, next: Status) => {
      setStatuses((prev) => {
        const merged = { ...prev, [key]: next };
        saveStatuses(book.slug, merged);
        return merged;
      });
    },
    [book.slug],
  );

  const knownCount = hydrated
    ? Object.values(statuses).filter((s) => s === "known").length
    : 0;
  const practiceCount = hydrated
    ? Object.values(statuses).filter((s) => s === "practice").length
    : 0;

  return (
    <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8 sm:py-10">
      <Link
        href={`/languages/${book.slug}`}
        className="inline-flex items-center gap-1.5 text-sm text-navy/60 hover:text-teal transition-colors mb-4"
      >
        <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" />
        </svg>
        Back to {book.language}
      </Link>

      <header className="mb-8">
        <p className="text-xs font-semibold uppercase tracking-[0.18em] text-blue-700 mb-2">
          Phrase Passport
        </p>
        <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-navy tracking-tight">
          {book.language} Phrase Passport
        </h1>
        <p className="text-sm sm:text-base text-navy/60 mt-2 max-w-2xl">
          65 essential phrases for greetings, getting around, food, shopping and
          emergencies — with pronunciation and audio for every entry. Perfect
          to skim on the plane.
        </p>

        {/* Mode toggle */}
        <div className="mt-6 inline-flex rounded-full border border-border bg-white p-1 shadow-sm">
          <button
            type="button"
            onClick={() => setMode("list")}
            className={`px-4 sm:px-5 py-2 text-sm font-semibold rounded-full transition-colors ${
              mode === "list"
                ? "bg-teal text-white shadow"
                : "text-navy/70 hover:text-teal"
            }`}
          >
            View phrases
          </button>
          <button
            type="button"
            onClick={() => setMode("flashcards")}
            className={`px-4 sm:px-5 py-2 text-sm font-semibold rounded-full transition-colors ${
              mode === "flashcards"
                ? "bg-teal text-white shadow"
                : "text-navy/70 hover:text-teal"
            }`}
          >
            Study with flashcards
          </button>
        </div>

        {hydrated && (knownCount > 0 || practiceCount > 0) && (
          <p className="text-xs text-navy/50 mt-3">
            {knownCount} marked known · {practiceCount} marked to practice
          </p>
        )}
      </header>

      {mode === "list" ? (
        <PhraseList book={book} statuses={statuses} setStatus={setStatus} />
      ) : (
        <FlashcardDeck
          phrases={flat}
          statuses={statuses}
          setStatus={setStatus}
          language={book.language}
          speechLang={book.speechLang}
        />
      )}
    </div>
  );
}

// ---------------- List mode ----------------

function PhraseList({
  book,
  statuses,
  setStatus,
}: {
  book: TravelPhrasebook;
  statuses: StatusMap;
  setStatus: (key: string, next: Status) => void;
}) {
  return (
    <div className="space-y-10">
      {book.categories.map((cat) => (
        <section key={cat.id} id={cat.id} className="scroll-mt-20">
          <div className="flex items-baseline justify-between mb-4">
            <h2 className="text-xl sm:text-2xl font-bold text-navy tracking-tight">
              {cat.title}
            </h2>
            <span className="text-xs text-navy/40 tabular-nums">
              {cat.phrases.length} {cat.phrases.length === 1 ? "phrase" : "phrases"}
            </span>
          </div>
          <ul className="grid grid-cols-1 md:grid-cols-2 gap-3 sm:gap-4">
            {cat.phrases.map((p) => {
              const key = `${cat.id}::${p.phrase}`;
              const status = statuses[key] ?? "unset";
              return (
                <li key={key}>
                  <PhraseCard
                    phrase={p}
                    speechLang={book.speechLang}
                    status={status}
                    onMark={(next) => setStatus(key, next)}
                  />
                </li>
              );
            })}
          </ul>
        </section>
      ))}
    </div>
  );
}

function PhraseCard({
  phrase,
  speechLang,
  status,
  onMark,
}: {
  phrase: TravelPhrase;
  speechLang: string;
  status: Status;
  onMark: (s: Status) => void;
}) {
  const ring =
    status === "known"
      ? "border-emerald-200 bg-emerald-50/40"
      : status === "practice"
      ? "border-amber-200 bg-amber-50/40"
      : "border-border bg-white";
  return (
    <div
      className={`group rounded-2xl border ${ring} p-4 sm:p-5 shadow-sm hover:shadow-md transition-shadow`}
    >
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0">
          <p className="text-lg sm:text-xl font-bold text-navy leading-snug break-words">
            {phrase.phrase}
          </p>
          <p className="text-sm text-navy/50 italic mt-1">[{phrase.phonetic}]</p>
          <p className="text-sm text-navy/80 mt-2">{phrase.english}</p>
        </div>
        <SpeakerButton
          text={phrase.phrase}
          lang={speechLang}
          label={`Play "${phrase.phrase}"`}
        />
      </div>
      <div className="mt-4 flex gap-2">
        <button
          type="button"
          onClick={() => onMark(status === "known" ? "unset" : "known")}
          className={`flex-1 text-xs font-semibold rounded-full py-1.5 border transition-colors ${
            status === "known"
              ? "bg-emerald-600 text-white border-emerald-600"
              : "text-emerald-700 border-emerald-200 bg-white hover:bg-emerald-50"
          }`}
        >
          {status === "known" ? "✓ Known" : "Mark known"}
        </button>
        <button
          type="button"
          onClick={() => onMark(status === "practice" ? "unset" : "practice")}
          className={`flex-1 text-xs font-semibold rounded-full py-1.5 border transition-colors ${
            status === "practice"
              ? "bg-amber-600 text-white border-amber-600"
              : "text-amber-800 border-amber-200 bg-white hover:bg-amber-50"
          }`}
        >
          {status === "practice" ? "★ Practice" : "Practice more"}
        </button>
      </div>
    </div>
  );
}

// ---------------- Flashcard mode ----------------

function FlashcardDeck({
  phrases,
  statuses,
  setStatus,
  language,
  speechLang,
}: {
  phrases: FlatPhrase[];
  statuses: StatusMap;
  setStatus: (key: string, next: Status) => void;
  language: string;
  speechLang: string;
}) {
  const [order, setOrder] = useState<number[]>(() =>
    phrases.map((_, i) => i),
  );
  const [filter, setFilter] = useState<Filter>("all");
  const [cursor, setCursor] = useState(0);
  const [flipped, setFlipped] = useState(false);

  // Rebuild the visible deck whenever the filter or the underlying
  // statuses change. `visibleOrder` holds the current filtered ordering
  // (indexes into `phrases`).
  const visibleOrder = useMemo(() => {
    if (filter === "all") return order;
    return order.filter((i) => {
      const key = phrases[i].key;
      const st = statuses[key] ?? "unset";
      if (filter === "known") return st === "known";
      // "practice" filter = anything the user hasn't marked as known,
      // so it doubles as a "cards to keep practising" review deck.
      return st !== "known";
    });
  }, [order, filter, statuses, phrases]);

  const total = visibleOrder.length;
  // The filter can shrink the deck under the current cursor. `safeCursor`
  // is the render-time clamp — we never write it back into state (that'd
  // cascade another render); every read below goes through it.
  const safeCursor = total === 0 ? 0 : Math.min(cursor, total - 1);

  const currentIdx = total > 0 ? visibleOrder[safeCursor] : null;
  const current = currentIdx != null ? phrases[currentIdx] : null;

  const shuffle = () => {
    const shuffled = [...order];
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    setOrder(shuffled);
    setCursor(0);
    setFlipped(false);
  };

  const next = useCallback(() => {
    if (total === 0) return;
    setCursor((c) => (c + 1) % total);
    setFlipped(false);
  }, [total]);

  const prev = useCallback(() => {
    if (total === 0) return;
    setCursor((c) => (c - 1 + total) % total);
    setFlipped(false);
  }, [total]);

  // Arrow key navigation + space to flip. Feels natural for a keyboard
  // user rifling through the deck.
  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if (e.target instanceof HTMLElement) {
        const tag = e.target.tagName;
        if (tag === "INPUT" || tag === "TEXTAREA" || e.target.isContentEditable) return;
      }
      if (e.key === "ArrowRight") {
        e.preventDefault();
        next();
      } else if (e.key === "ArrowLeft") {
        e.preventDefault();
        prev();
      } else if (e.key === " " || e.key === "Enter") {
        e.preventDefault();
        setFlipped((f) => !f);
      }
    }
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [next, prev]);

  return (
    <div>
      {/* Controls */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 mb-4">
        <div className="inline-flex rounded-full border border-border bg-white p-1 self-start shadow-sm">
          {(
            [
              { id: "all", label: "All" },
              { id: "practice", label: "To practice" },
              { id: "known", label: "Known" },
            ] as { id: Filter; label: string }[]
          ).map((f) => (
            <button
              key={f.id}
              type="button"
              onClick={() => {
                setFilter(f.id);
                setCursor(0);
                setFlipped(false);
              }}
              className={`px-3 sm:px-4 py-1.5 text-xs sm:text-sm font-semibold rounded-full transition-colors ${
                filter === f.id
                  ? "bg-navy text-white"
                  : "text-navy/70 hover:text-navy"
              }`}
            >
              {f.label}
            </button>
          ))}
        </div>
        <button
          type="button"
          onClick={shuffle}
          className="inline-flex items-center justify-center gap-2 self-start px-4 py-2 text-sm font-semibold text-teal-dark bg-teal-light rounded-full border border-teal/30 hover:bg-teal hover:text-white hover:border-teal transition-colors"
        >
          <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" d="M4 4h5l3 4 3-4h5v5l-4 3 4 3v5h-5l-3-4-3 4H4v-5l4-3-4-3V4z" />
          </svg>
          Shuffle
        </button>
      </div>

      {/* Card area */}
      {total === 0 || !current ? (
        <div className="rounded-3xl border border-dashed border-border bg-white p-12 text-center">
          <p className="text-sm text-navy/60">
            No cards match this filter yet. Mark some phrases in the list view
            to build your practice deck.
          </p>
        </div>
      ) : (
        <>
          <div className="flex items-center justify-between text-xs text-navy/50 mb-2 tabular-nums">
            <span>
              Card <span className="font-semibold text-navy">{safeCursor + 1}</span> of {total}
            </span>
            <span className="uppercase tracking-wider">{current.categoryTitle}</span>
          </div>
          <div className="w-full h-1.5 bg-navy/5 rounded-full overflow-hidden mb-4">
            <div
              className="h-full bg-gradient-to-r from-teal to-teal-dark transition-all duration-300"
              style={{ width: `${((safeCursor + 1) / total) * 100}%` }}
            />
          </div>

          <Flashcard
            phrase={current}
            language={language}
            speechLang={speechLang}
            flipped={flipped}
            onFlip={() => setFlipped((f) => !f)}
          />

          {/* Nav row */}
          <div className="mt-5 flex items-center justify-between gap-3">
            <button
              type="button"
              onClick={prev}
              className="inline-flex items-center gap-2 px-4 py-2.5 text-sm font-semibold text-navy/80 bg-white border border-border rounded-full hover:border-teal/40 hover:text-teal transition-colors"
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" />
              </svg>
              Previous
            </button>
            <button
              type="button"
              onClick={() => setFlipped((f) => !f)}
              className="hidden sm:inline-flex items-center gap-2 px-5 py-2.5 text-sm font-semibold text-teal-dark bg-white border border-teal/30 rounded-full hover:bg-teal hover:text-white hover:border-teal transition-colors"
            >
              Flip
            </button>
            <button
              type="button"
              onClick={next}
              className="inline-flex items-center gap-2 px-4 py-2.5 text-sm font-semibold text-white bg-teal rounded-full hover:bg-teal-dark transition-colors"
            >
              Next
              <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
              </svg>
            </button>
          </div>

          {/* Mark row */}
          <div className="mt-4 flex gap-2">
            <button
              type="button"
              onClick={() => {
                const cur = statuses[current.key] ?? "unset";
                setStatus(current.key, cur === "known" ? "unset" : "known");
              }}
              className={`flex-1 text-sm font-semibold rounded-full py-2.5 border transition-colors ${
                statuses[current.key] === "known"
                  ? "bg-emerald-600 text-white border-emerald-600"
                  : "text-emerald-700 border-emerald-200 bg-white hover:bg-emerald-50"
              }`}
            >
              {statuses[current.key] === "known" ? "✓ Known" : "Mark known"}
            </button>
            <button
              type="button"
              onClick={() => {
                const cur = statuses[current.key] ?? "unset";
                setStatus(current.key, cur === "practice" ? "unset" : "practice");
              }}
              className={`flex-1 text-sm font-semibold rounded-full py-2.5 border transition-colors ${
                statuses[current.key] === "practice"
                  ? "bg-amber-600 text-white border-amber-600"
                  : "text-amber-800 border-amber-200 bg-white hover:bg-amber-50"
              }`}
            >
              {statuses[current.key] === "practice" ? "★ Practice more" : "Practice more"}
            </button>
          </div>

          <p className="mt-4 text-center text-[11px] text-navy/40">
            Tip: ← / → to navigate · Space to flip
          </p>
        </>
      )}
    </div>
  );
}

function Flashcard({
  phrase,
  language,
  speechLang,
  flipped,
  onFlip,
}: {
  phrase: FlatPhrase;
  language: string;
  speechLang: string;
  flipped: boolean;
  onFlip: () => void;
}) {
  // Inline styles for the 3D flip so we don't need to teach Tailwind about
  // perspective/backface-visibility utilities. The card is a fixed-height
  // stage with two absolutely-positioned faces.
  return (
    <div
      className="relative w-full"
      style={{ perspective: "1400px" }}
    >
      <button
        type="button"
        onClick={onFlip}
        className="relative block w-full text-left"
        style={{ height: "min(60vh, 380px)" }}
        aria-label="Flip card"
      >
        <div
          className="relative w-full h-full transition-transform duration-500"
          style={{
            transformStyle: "preserve-3d",
            transform: flipped ? "rotateY(180deg)" : "rotateY(0deg)",
          }}
        >
          {/* Front — English */}
          <div
            className="absolute inset-0 rounded-3xl border border-border bg-white shadow-lg flex flex-col items-center justify-center p-8 text-center"
            style={{ backfaceVisibility: "hidden", WebkitBackfaceVisibility: "hidden" }}
          >
            <p className="text-[10px] uppercase tracking-[0.18em] font-semibold text-navy/40 mb-4">
              English
            </p>
            <p className="text-2xl sm:text-3xl lg:text-4xl font-bold text-navy leading-snug">
              {phrase.english}
            </p>
            <p className="mt-6 text-xs text-navy/40">Tap to reveal the {language} phrase</p>
          </div>

          {/* Back — target language */}
          <div
            className="absolute inset-0 rounded-3xl border border-teal/30 bg-gradient-to-br from-teal-light to-white shadow-lg flex flex-col items-center justify-center p-8 text-center"
            style={{
              backfaceVisibility: "hidden",
              WebkitBackfaceVisibility: "hidden",
              transform: "rotateY(180deg)",
            }}
          >
            <p className="text-[10px] uppercase tracking-[0.18em] font-semibold text-teal-dark mb-4">
              {language}
            </p>
            <p className="text-2xl sm:text-3xl lg:text-4xl font-bold text-navy leading-snug break-words">
              {phrase.phrase}
            </p>
            <p className="mt-3 text-sm sm:text-base text-navy/60 italic">
              [{phrase.phonetic}]
            </p>
            <div className="mt-6">
              <SpeakerButton
                text={phrase.phrase}
                lang={speechLang}
                size="lg"
                label={`Play "${phrase.phrase}"`}
              />
            </div>
          </div>
        </div>
      </button>
    </div>
  );
}

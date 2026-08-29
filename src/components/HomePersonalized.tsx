import Link from "next/link";
import Image from "next/image";
import StreakFlame from "@/components/StreakFlame";
import { FLAG_CODES } from "@/lib/flag-codes";
import { hasTravelPhrasebook } from "@/lib/travel-phrases";
import type { CEFRLevel } from "@/lib/learn";
import { CEFR_LABEL } from "@/lib/learn";

// Everything the personalized homepage needs, resolved server-side and
// handed in as a single prop. Kept as plain data (no live DB clients)
// so this component stays a pure server component.
export interface ActiveLanguageEntry {
  slug: string;
  name: string; // already localized
  countryCode: string;
  currentLevel: CEFRLevel;
  levelCompleted: number;
  levelTotal: number;
  levelPct: number;
  totalCompleted: number;
  totalLessons: number;
  totalXp: number;
  continueHref: string; // deep link to the next lesson (or /learn/{slug})
  lastLessonTitle: string | null;
}

export interface ExploreLanguageEntry {
  slug: string;
  name: string;
  countryCode: string;
  lessonsTotal: number;
}

export interface HomePersonalizedProps {
  displayName: string;
  totalXp: number;
  currentStreak: number;
  longestStreak: number;
  weeklyCount: number;
  weeklyGoal: number;
  active: ActiveLanguageEntry[];
  explore: ExploreLanguageEntry[];
}

const LEVEL_PILL: Record<CEFRLevel, string> = {
  A1: "bg-emerald-50 text-emerald-700 ring-emerald-200",
  A2: "bg-teal-light text-teal-dark ring-teal/30",
  B1: "bg-amber-50 text-amber-800 ring-amber-200",
  B2: "bg-orange-50 text-orange-800 ring-orange-200",
  C1: "bg-rose-50 text-rose-800 ring-rose-200",
};

function motivationalMessage(streak: number, weekly: number): string {
  if (streak >= 7 && weekly >= 5) return "You're on fire this week — keep it going.";
  if (streak >= 3) return "You're building a real habit. Nice work.";
  if (weekly >= 3) return "Great pace this week. One more today?";
  if (weekly >= 1) return "You've made progress this week — keep the momentum.";
  return "A short session today keeps your streak alive.";
}

export default function HomePersonalized({
  displayName,
  totalXp,
  currentStreak,
  longestStreak,
  weeklyCount,
  weeklyGoal,
  active,
  explore,
}: HomePersonalizedProps) {
  const dailyPct = Math.min(100, Math.round((weeklyCount / weeklyGoal) * 100));
  return (
    <main className="flex-1">
      {/* Personalized welcome — replaces the marketing hero entirely for
          returning learners. Warm, low-key palette so it feels like a
          continuation, not a landing page. */}
      <section className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pt-8 sm:pt-12 pb-4">
        <div className="flex flex-col lg:flex-row lg:items-end lg:justify-between gap-4">
          <div>
            <p className="text-xs sm:text-sm font-semibold uppercase tracking-[0.15em] text-teal-dark">
              Welcome back
            </p>
            <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-navy tracking-tight mt-1">
              {displayName}
            </h1>
            <p className="text-sm sm:text-base text-navy/60 mt-2 max-w-xl">
              {motivationalMessage(currentStreak, weeklyCount)}
            </p>
          </div>
          <Link
            href="/profile"
            className="inline-flex items-center gap-2 self-start px-4 py-2 text-sm font-medium text-teal-dark bg-white border border-border rounded-full hover:border-teal/40 transition-colors"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.5 20.12a7.5 7.5 0 0115 0" />
            </svg>
            View profile
          </Link>
        </div>
      </section>

      {/* Stats + daily goal — four tiles that give the whole picture at a
          glance. Grid stays 2-up on mobile so nothing shrinks illegibly. */}
      <section className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pt-4 pb-6">
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
          <div className="bg-white border border-border rounded-2xl px-4 py-4 sm:py-5 shadow-sm">
            <div className="flex items-center gap-3">
              <StreakFlame streak={currentStreak} size="md" iconOnly />
              <div className="min-w-0">
                <p className="text-lg sm:text-2xl font-bold text-navy tabular-nums leading-tight">
                  {currentStreak}
                </p>
                <p className="text-[10px] sm:text-xs uppercase tracking-wider text-navy/50">
                  Day streak
                </p>
              </div>
            </div>
            {longestStreak > currentStreak && (
              <p className="hidden sm:block text-[11px] text-navy/40 mt-2">
                Longest: {longestStreak}
              </p>
            )}
          </div>
          <div className="bg-white border border-border rounded-2xl px-4 py-4 sm:py-5 shadow-sm">
            <div className="flex items-center gap-3">
              <span className="shrink-0 w-9 h-9 sm:w-10 sm:h-10 rounded-full bg-teal-light text-teal-dark flex items-center justify-center">
                <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 2l2.4 7.4H22l-6.2 4.5 2.4 7.4L12 16.9 5.8 21.3l2.4-7.4L2 9.4h7.6z" />
                </svg>
              </span>
              <div className="min-w-0">
                <p className="text-lg sm:text-2xl font-bold text-navy tabular-nums leading-tight">
                  {totalXp.toLocaleString()}
                </p>
                <p className="text-[10px] sm:text-xs uppercase tracking-wider text-navy/50">
                  Total XP
                </p>
              </div>
            </div>
          </div>
          <div className="bg-white border border-border rounded-2xl px-4 py-4 sm:py-5 shadow-sm">
            <div className="flex items-center gap-3">
              <span className="shrink-0 w-9 h-9 sm:w-10 sm:h-10 rounded-full bg-peach-light text-amber-700 flex items-center justify-center">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </span>
              <div className="min-w-0">
                <p className="text-lg sm:text-2xl font-bold text-navy tabular-nums leading-tight">
                  {weeklyCount}
                </p>
                <p className="text-[10px] sm:text-xs uppercase tracking-wider text-navy/50">
                  Lessons this week
                </p>
              </div>
            </div>
          </div>
          <div className="bg-gradient-to-br from-teal to-teal-dark text-white rounded-2xl px-4 py-4 sm:py-5 shadow-sm">
            <div className="flex items-center justify-between gap-2">
              <p className="text-[10px] sm:text-xs uppercase tracking-wider text-white/80">
                Weekly lesson goal
              </p>
              <p className="text-xs tabular-nums text-white/80">
                {Math.min(weeklyCount, weeklyGoal)} / {weeklyGoal} lessons
              </p>
            </div>
            <div className="mt-2 w-full h-2 bg-white/25 rounded-full overflow-hidden">
              <div
                className="h-full bg-white rounded-full transition-all duration-500"
                style={{ width: `${dailyPct}%` }}
              />
            </div>
            <p className="mt-2 text-xs sm:text-sm text-white/90">
              {weeklyCount >= weeklyGoal
                ? "Weekly goal reached — nice one!"
                : `${weeklyGoal - weeklyCount} more ${weeklyGoal - weeklyCount === 1 ? "lesson" : "lessons"} to reach your goal this week`}
            </p>
          </div>
        </div>
      </section>

      {/* Travel-guide callout — only rendered when at least one active
          language has a phrasebook. This is the ONE place in the app it
          appears; it used to live on /learn but was consolidated here so
          the homepage is the single home for the "bonus tool" pitch. */}
      {(() => {
        const travelLangs = active.filter((l) => hasTravelPhrasebook(l.slug));
        if (travelLangs.length === 0) return null;
        return (
          <section className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pb-4">
            <div className="rounded-2xl border border-amber-300/70 bg-gradient-to-r from-amber-50 via-orange-50 to-amber-100 p-4 sm:p-5 flex flex-col sm:flex-row sm:items-center gap-4 shadow-sm">
              <div className="shrink-0 w-11 h-11 sm:w-12 sm:h-12 rounded-xl bg-gradient-to-br from-amber-500 to-orange-600 text-white flex items-center justify-center shadow ring-2 ring-white">
                <svg className="w-6 h-6" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M9 7V5a2 2 0 012-2h2a2 2 0 012 2v2" />
                  <rect x="3" y="7" width="18" height="14" rx="2" strokeLinecap="round" strokeLinejoin="round" />
                  <path strokeLinecap="round" strokeLinejoin="round" d="M8 11v6M16 11v6M12 11v6" />
                </svg>
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm sm:text-base font-semibold text-amber-950">
                  Planning a trip? Check out our travel phrase guide
                </p>
                <p className="text-xs sm:text-sm text-amber-900/70 mt-0.5">
                  65 essential phrases with pronunciation and flashcards — a bonus tool alongside your course.
                </p>
              </div>
              <div className="flex flex-wrap gap-2 sm:justify-end">
                {travelLangs.map((l) => (
                  <Link
                    key={l.slug}
                    href={`/languages/${l.slug}/travel-guide`}
                    className="inline-flex items-center gap-1.5 px-4 py-2 text-xs sm:text-sm font-bold text-white bg-amber-600 rounded-full shadow hover:bg-amber-700 transition-colors whitespace-nowrap"
                  >
                    <span aria-hidden>✈</span>
                    {l.name} Guide
                    <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
                    </svg>
                  </Link>
                ))}
              </div>
            </div>
          </section>
        );
      })()}

      {/* Active languages — the meat of the personalized homepage.
          Each card jumps directly to the user's next lesson. */}
      <section className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pt-2 pb-10">
        <h2 className="text-xl sm:text-2xl font-bold text-navy tracking-tight mb-4">
          Continue learning
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 sm:gap-5">
          {active.map((lang) => (
            <ActiveLanguageCard key={lang.slug} lang={lang} />
          ))}
        </div>
      </section>

      {/* Explore row for anything the learner hasn't touched yet. When
          they've already started every visible language, swap in a
          "studying everything" message so the section isn't just missing. */}
      <section className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pb-14">
        <div className="flex items-baseline justify-between mb-3">
          <h2 className="text-base sm:text-lg font-bold text-navy tracking-tight">
            Explore more languages
          </h2>
          {explore.length > 0 && (
            <span className="text-xs text-navy/40 tabular-nums">
              {explore.length} available
            </span>
          )}
        </div>
        {explore.length === 0 ? (
          <div className="rounded-2xl border border-dashed border-border bg-white/60 p-6 sm:p-8 text-center">
            <p className="text-2xl sm:text-3xl mb-2" aria-hidden>🌍</p>
            <p className="text-sm sm:text-base font-semibold text-navy">
              You&rsquo;re studying every available language.
            </p>
            <p className="text-xs sm:text-sm text-navy/60 mt-1">
              More coming soon — check back for new courses.
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3 sm:gap-4">
            {explore.map((l) => (
              <Link
                key={l.slug}
                href={`/languages/${l.slug}`}
                className="group flex items-center gap-3 bg-white border border-border rounded-xl p-3 sm:p-4 hover:border-teal/40 hover:shadow-md transition-all"
              >
                <Image
                  src={`https://flagcdn.com/w80/${l.countryCode}.png`}
                  alt={`${l.name} flag`}
                  width={36}
                  height={27}
                  className="rounded-sm object-cover shadow-sm ring-1 ring-black/5 shrink-0"
                />
                <div className="min-w-0 flex-1">
                  <p className="text-sm sm:text-base font-semibold text-navy truncate group-hover:text-teal transition-colors">
                    {l.name}
                  </p>
                  <p className="text-[11px] sm:text-xs text-navy/40">
                    {l.lessonsTotal} lessons
                  </p>
                </div>
                <svg className="w-4 h-4 text-teal/0 group-hover:text-teal transition-colors" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
                </svg>
              </Link>
            ))}
          </div>
        )}
      </section>

    </main>
  );
}

function ActiveLanguageCard({ lang }: { lang: ActiveLanguageEntry }) {
  const pill = LEVEL_PILL[lang.currentLevel];
  const flag = FLAG_CODES[lang.slug] ?? lang.countryCode;
  const showTravel = hasTravelPhrasebook(lang.slug);
  return (
    <div className="group relative bg-white border border-border rounded-2xl p-5 sm:p-6 hover:shadow-lg hover:border-teal/40 transition-all">
      {showTravel && (
        <Link
          href={`/languages/${lang.slug}/travel-guide`}
          className="absolute top-3 right-3 z-10 inline-flex items-center gap-1 rounded-full bg-amber-100 text-amber-900 text-[10px] font-bold px-2 py-1 border border-amber-300 hover:bg-amber-200 transition-colors"
          aria-label={`Open ${lang.name} travel guide`}
        >
          <span aria-hidden>✈</span>
          Travel Guide
        </Link>
      )}
      <div className="flex items-start gap-4">
        <Image
          src={`https://flagcdn.com/w160/${flag}.png`}
          alt={`${lang.name} flag`}
          width={64}
          height={48}
          className="rounded-md object-cover shadow-sm ring-1 ring-black/5 shrink-0"
        />
        <div className="min-w-0 flex-1 pr-24">
          <div className="flex items-center gap-2 mb-1">
            <h3 className="text-xl sm:text-2xl font-bold text-navy tracking-tight truncate">
              {lang.name}
            </h3>
            <span className={`inline-flex items-center rounded-full px-2 py-0.5 text-[10px] font-bold ring-1 ${pill}`}>
              {lang.currentLevel}
            </span>
          </div>
          <p className="text-xs sm:text-sm text-navy/50">
            {CEFR_LABEL[lang.currentLevel]} · {lang.totalXp.toLocaleString()} XP earned
          </p>
        </div>
      </div>

      <div className="mt-5">
        <div className="flex items-center justify-between text-xs text-navy/60 mb-1.5">
          <span>
            {lang.currentLevel} progress · {lang.levelCompleted} / {lang.levelTotal} lessons
          </span>
          <span className="font-semibold text-navy/70 tabular-nums">{lang.levelPct}%</span>
        </div>
        <div className="w-full h-2.5 bg-navy/5 rounded-full overflow-hidden">
          <div
            className="h-full bg-gradient-to-r from-teal to-teal-dark rounded-full transition-all duration-500"
            style={{ width: `${lang.levelPct}%` }}
          />
        </div>
      </div>

      {lang.lastLessonTitle && (
        <p className="mt-4 text-xs text-navy/50">
          <span className="uppercase tracking-wider text-navy/40">Last lesson:</span>{" "}
          <span className="text-navy/70 font-medium">{lang.lastLessonTitle}</span>
        </p>
      )}

      <Link
        href={lang.continueHref}
        className="mt-5 inline-flex items-center justify-center w-full gap-1.5 py-3 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark active:scale-[0.98] transition-all"
      >
        Continue where you left off
        <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
        </svg>
      </Link>
    </div>
  );
}

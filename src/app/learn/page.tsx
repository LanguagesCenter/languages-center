import Link from "next/link";
import Image from "next/image";
import { redirect } from "next/navigation";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import StreakFlame from "@/components/StreakFlame";
import { createClient } from "@/lib/supabase/server";
import {
  getLanguagesWithProgress,
  getUserProfile,
  getLessonsCompletedThisWeek,
  type LanguageProgress,
} from "@/lib/learn";
import { FLAG_CODES } from "@/lib/flag-codes";
import { getServerLang, getServerT } from "@/lib/i18n-server";
import { getLocalizedLanguageName } from "@/lib/i18n";
import { sortByPopularity } from "@/lib/language-proximity";
import { hasTravelPhrasebook } from "@/lib/travel-phrases";

export const metadata = {
  title: "Learn — Languages Center",
};

function ProgressBar({ pct }: { pct: number }) {
  return (
    <div className="w-full h-2.5 bg-navy/5 rounded-full overflow-hidden">
      <div
        className="h-full bg-gradient-to-r from-teal to-teal-dark rounded-full transition-all duration-500"
        style={{ width: `${pct}%` }}
      />
    </div>
  );
}

function LanguageProgressCard({
  entry,
  localizedName,
  notStartedLabel,
  lessonsLabel,
  startLabel,
  continueLabel,
}: {
  entry: LanguageProgress;
  localizedName: string;
  notStartedLabel: string;
  lessonsLabel: string;
  startLabel: string;
  continueLabel: string;
}) {
  const code = FLAG_CODES[entry.language.code] ?? entry.language.code;
  const hasProgress = entry.completedLessons > 0;
  return (
    <Link
      href={`/learn/${entry.language.code}`}
      className="group flex flex-col bg-white border border-border rounded-2xl p-5 sm:p-6 sm:hover:shadow-lg sm:hover:border-teal/40 sm:hover:-translate-y-0.5 transition-all duration-200"
    >
      <div className="flex items-center justify-between mb-4">
        <Image
          src={`https://flagcdn.com/w80/${code}.png`}
          alt={`${localizedName} flag`}
          width={48}
          height={36}
          className="rounded-md object-cover shadow-sm ring-1 ring-black/5"
        />
        {entry.stats && entry.stats.total_xp > 0 ? (
          <span className="text-xs font-semibold text-teal-dark bg-teal-light px-2.5 py-1 rounded-full">
            {entry.stats.total_xp} XP
          </span>
        ) : (
          <span className="text-xs text-navy/40">{notStartedLabel}</span>
        )}
      </div>
      <h3 className="text-lg sm:text-xl font-bold text-navy mb-3 group-hover:text-teal transition-colors tracking-tight">
        {localizedName}
      </h3>
      <div className="space-y-2 mt-auto">
        <ProgressBar pct={entry.progressPct} />
        <div className="flex items-center justify-between text-xs text-navy/50">
          <span>
            {entry.completedLessons} / {entry.totalLessons} {lessonsLabel}
          </span>
          <span className="font-medium text-navy/70">{entry.progressPct}%</span>
        </div>
      </div>
      <span className="mt-5 inline-flex items-center justify-center gap-1.5 py-3 sm:py-2.5 text-sm font-semibold text-white bg-teal rounded-xl group-hover:bg-teal-dark active:scale-[0.98] transition-all">
        {hasProgress ? continueLabel : startLabel}
        <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
        </svg>
      </span>
    </Link>
  );
}

export default async function LearnPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    redirect("/login");
  }

  const t = await getServerT();
  const uiLang = await getServerLang();
  const [progress, profile, weeklyCount] = await Promise.all([
    getLanguagesWithProgress(),
    getUserProfile(),
    getLessonsCompletedThisWeek(),
  ]);

  const totalXp = profile?.total_xp ?? 0;
  const currentStreak = profile?.current_streak ?? 0;
  const longestStreak = profile?.longest_streak ?? 0;

  // Split the visible catalogue into "already started" and "explore".
  // Started = at least one completed lesson OR earned XP; anything else
  // sits in the discovery row below.
  const started = progress.filter(
    (entry) =>
      entry.completedLessons > 0 ||
      (entry.stats?.total_xp ?? 0) > 0,
  );
  const startedCodes = new Set(started.map((e) => e.language.code));
  const explore = progress.filter(
    (entry) =>
      !startedCodes.has(entry.language.code) && entry.totalLessons > 0,
  );

  return (
    <>
      <Navbar />
      <main className="flex-1">
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-8 sm:pt-10 lg:pt-12 pb-4">
          <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-4 mb-6">
            <div>
              <h1 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-navy tracking-tight">
                {t("learn.keepLearning")}
              </h1>
              <p className="text-sm text-navy/60 mt-1.5">
                {t("learn.pickLang")}
              </p>
            </div>
            <Link
              href="/profile"
              className="inline-flex items-center justify-center gap-2 self-start px-4 py-2.5 text-sm font-semibold text-teal-dark bg-teal-light rounded-full border border-teal/30 hover:bg-teal hover:text-white hover:border-teal transition-colors"
            >
              <svg className="w-4 h-4 shrink-0" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" />
              </svg>
              <span className="hidden sm:inline">View Profile &amp; Certifications</span>
              <span className="sm:hidden">Profile</span>
            </Link>
          </div>

          {/* Progress summary — three at-a-glance stats above the language
              grid. Grid layout stays consistent from mobile up so the
              summary reads the same on every device. */}
          <div className="grid grid-cols-3 gap-3 sm:gap-4">
            <div className="bg-white border border-border rounded-2xl px-3 sm:px-5 py-4 sm:py-5 shadow-sm">
              <div className="flex items-center gap-2 sm:gap-3">
                <StreakFlame streak={currentStreak} size="md" />
                <div className="min-w-0">
                  <p className="text-lg sm:text-2xl font-bold text-navy leading-tight">
                    {currentStreak}
                  </p>
                  <p className="text-[10px] sm:text-xs text-navy/50 uppercase tracking-wider truncate">
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
            <div className="bg-white border border-border rounded-2xl px-3 sm:px-5 py-4 sm:py-5 shadow-sm">
              <div className="flex items-center gap-2 sm:gap-3">
                <span className="shrink-0 w-9 h-9 sm:w-10 sm:h-10 rounded-full bg-teal-light text-teal-dark flex items-center justify-center">
                  <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M12 2l2.4 7.4H22l-6.2 4.5 2.4 7.4L12 16.9 5.8 21.3l2.4-7.4L2 9.4h7.6z" />
                  </svg>
                </span>
                <div className="min-w-0">
                  <p className="text-lg sm:text-2xl font-bold text-navy leading-tight tabular-nums">
                    {totalXp.toLocaleString()}
                  </p>
                  <p className="text-[10px] sm:text-xs text-navy/50 uppercase tracking-wider truncate">
                    Total XP
                  </p>
                </div>
              </div>
            </div>
            <div className="bg-white border border-border rounded-2xl px-3 sm:px-5 py-4 sm:py-5 shadow-sm">
              <div className="flex items-center gap-2 sm:gap-3">
                <span className="shrink-0 w-9 h-9 sm:w-10 sm:h-10 rounded-full bg-peach-light text-amber-700 flex items-center justify-center">
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                </span>
                <div className="min-w-0">
                  <p className="text-lg sm:text-2xl font-bold text-navy leading-tight tabular-nums">
                    {weeklyCount}
                  </p>
                  <p className="text-[10px] sm:text-xs text-navy/50 uppercase tracking-wider truncate">
                    Lessons this week
                  </p>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-6 pb-8">
          {/* Travel-guide banner sits above the started grid whenever at
              least one Spanish/French course is active. */}
          {(() => {
            const travelLanguages = started
              .map((e) => ({
                slug: e.language.code,
                name: getLocalizedLanguageName(
                  e.language.code,
                  uiLang,
                  e.language.name,
                ),
              }))
              .filter((l) => hasTravelPhrasebook(l.slug));
            if (travelLanguages.length === 0) return null;
            return (
              <div className="mb-6 rounded-2xl border border-amber-300/70 bg-gradient-to-r from-amber-50 via-orange-50 to-amber-100 p-4 sm:p-5 flex flex-col sm:flex-row sm:items-center gap-4 shadow-sm">
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
                  {travelLanguages.map((l) => (
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
            );
          })()}

          {/* Active language grid. Empty state pushes users to the homepage
              to pick their first language. */}
          {started.length === 0 ? (
            <div className="text-center py-16 border border-dashed border-border rounded-2xl bg-white">
              <p className="text-sm text-navy/60 mb-4">
                {t("learn.noStartedYet")}
              </p>
              <Link
                href="/"
                className="inline-flex items-center gap-2 px-5 py-2.5 text-sm font-semibold text-white bg-teal rounded-full hover:bg-teal-dark transition-colors"
              >
                {t("learn.browseLanguages")}
              </Link>
            </div>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
              {sortByPopularity(
                started.map((entry) => ({
                  ...entry,
                  slug: entry.language.code,
                })),
              ).map((entry) => {
                const localizedName = getLocalizedLanguageName(
                  entry.language.code,
                  uiLang,
                  entry.language.name,
                );
                return (
                  <LanguageProgressCard
                    key={entry.language.id}
                    entry={entry}
                    localizedName={localizedName}
                    notStartedLabel={t("learn.notStarted")}
                    lessonsLabel={t("learn.lessons")}
                    startLabel={t("card.startLearning", {
                      language: localizedName,
                    })}
                    continueLabel={t("card.continueLearning", {
                      language: localizedName,
                    })}
                  />
                );
              })}
            </div>
          )}
        </section>

        {/* Explore more languages — smaller cards for languages the user
            hasn't started. Only rendered once the learner has started
            something; the "studying everything" fallback replaces the
            grid when the visible catalogue is exhausted. */}
        {started.length > 0 && (
          <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
            <div className="flex items-baseline justify-between mb-4">
              <h2 className="text-lg sm:text-xl font-bold text-navy tracking-tight">
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
              <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-3 sm:gap-4">
                {sortByPopularity(
                  explore.map((entry) => ({
                    ...entry,
                    slug: entry.language.code,
                  })),
                ).map((entry) => {
                  const localizedName = getLocalizedLanguageName(
                    entry.language.code,
                    uiLang,
                    entry.language.name,
                  );
                  const flag = FLAG_CODES[entry.language.code] ?? entry.language.code;
                  return (
                    <Link
                      key={entry.language.id}
                      href={`/learn/${entry.language.code}`}
                      className="group flex items-center gap-3 bg-white border border-border rounded-xl p-3 sm:p-4 hover:border-teal/40 hover:shadow-md transition-all"
                    >
                      <Image
                        src={`https://flagcdn.com/w80/${flag}.png`}
                        alt={`${localizedName} flag`}
                        width={36}
                        height={27}
                        className="rounded-sm object-cover shadow-sm ring-1 ring-black/5 shrink-0"
                      />
                      <div className="min-w-0 flex-1">
                        <p className="text-sm sm:text-base font-semibold text-navy truncate group-hover:text-teal transition-colors">
                          {localizedName}
                        </p>
                        <p className="text-[11px] sm:text-xs text-navy/40">
                          {entry.totalLessons} {t("learn.lessons")}
                        </p>
                      </div>
                      <span className="text-teal opacity-0 group-hover:opacity-100 transition-opacity" aria-hidden>
                        <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
                        </svg>
                      </span>
                    </Link>
                  );
                })}
              </div>
            )}
          </section>
        )}
      </main>
      <Footer />
    </>
  );
}

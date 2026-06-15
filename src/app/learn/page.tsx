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
  type LanguageProgress,
} from "@/lib/learn";
import { FLAG_CODES } from "@/lib/flag-codes";
import { getServerLang, getServerT } from "@/lib/i18n-server";
import { getLocalizedLanguageName } from "@/lib/i18n";
import { sortByPopularity } from "@/lib/language-proximity";

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
  const [progress, profile] = await Promise.all([
    getLanguagesWithProgress(),
    getUserProfile(),
  ]);

  const totalXp = profile?.total_xp ?? 0;
  const currentStreak = profile?.current_streak ?? 0;

  return (
    <>
      <Navbar />
      <main className="flex-1">
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-8 sm:pt-10 lg:pt-12 pb-6">
          <div className="flex flex-col gap-5 lg:flex-row lg:items-center lg:justify-between">
            <div>
              <h1 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-navy tracking-tight">
                {t("learn.keepLearning")}
              </h1>
              <p className="text-sm text-navy/60 mt-1.5">
                {t("learn.pickLang")}
              </p>
            </div>
            <div className="flex items-stretch sm:items-center gap-3 flex-wrap">
              <Link
                href="/profile"
                className="inline-flex items-center justify-center gap-2 flex-1 sm:flex-none px-4 py-2.5 text-sm font-semibold text-teal-dark bg-teal-light rounded-full border border-teal/30 hover:bg-teal hover:text-white hover:border-teal transition-colors"
              >
                <svg className="w-4 h-4 shrink-0" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" />
                </svg>
                <span className="hidden sm:inline">View Profile &amp; Certifications</span>
                <span className="sm:hidden">Profile</span>
              </Link>
              <div className="flex items-center gap-4 sm:gap-6 bg-white border border-border rounded-2xl px-4 sm:px-5 py-3 sm:py-4 shadow-sm flex-1 sm:flex-none justify-center">
                <StreakFlame streak={currentStreak} size="md" />
                <div className="h-10 w-px bg-border" />
                <div className="flex flex-col leading-tight">
                  <span className="text-lg sm:text-2xl font-bold text-navy">
                    {totalXp.toLocaleString()}
                  </span>
                  <span className="text-[11px] sm:text-xs text-navy/50">{t("learn.totalXp")}</span>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
          {/* Only show languages the user has actually started. Anything
              else lives on the homepage where the user can pick one to
              begin. */}
          {(() => {
            const started = progress.filter(
              (entry) =>
                entry.completedLessons > 0 ||
                (entry.stats?.total_xp ?? 0) > 0,
            );

            if (started.length === 0) {
              return (
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
              );
            }

            return (
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
            );
          })()}
        </section>
      </main>
      <Footer />
    </>
  );
}

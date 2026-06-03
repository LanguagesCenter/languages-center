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
}: {
  entry: LanguageProgress;
  localizedName: string;
  notStartedLabel: string;
  lessonsLabel: string;
}) {
  const code = FLAG_CODES[entry.language.code] ?? entry.language.code;
  return (
    <Link
      href={`/learn/${entry.language.code}`}
      className="group bg-white border border-border rounded-2xl p-6 hover:shadow-lg hover:border-teal/40 hover:scale-[1.02] transition-all duration-200"
    >
      <div className="flex items-center justify-between mb-4">
        <Image
          src={`https://flagcdn.com/w80/${code}.png`}
          alt={`${localizedName} flag`}
          width={40}
          height={30}
          className="rounded-sm object-cover shadow-sm"
        />
        {entry.stats && entry.stats.total_xp > 0 ? (
          <span className="text-xs font-semibold text-teal-dark bg-teal-light px-2.5 py-1 rounded-full">
            {entry.stats.total_xp} XP
          </span>
        ) : (
          <span className="text-xs text-navy/40">{notStartedLabel}</span>
        )}
      </div>
      <h3 className="text-lg font-semibold text-navy mb-3 group-hover:text-teal transition-colors">
        {localizedName}
      </h3>
      <div className="space-y-2">
        <ProgressBar pct={entry.progressPct} />
        <div className="flex items-center justify-between text-xs text-navy/50">
          <span>
            {entry.completedLessons} / {entry.totalLessons} {lessonsLabel}
          </span>
          <span className="font-medium text-navy/70">{entry.progressPct}%</span>
        </div>
      </div>
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
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-10 pb-6">
          <div className="flex flex-col gap-6 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <h1 className="text-3xl sm:text-4xl font-bold text-navy tracking-tight">
                {t("learn.keepLearning")}
              </h1>
              <p className="text-sm text-navy/60 mt-1.5">
                {t("learn.pickLang")}
              </p>
            </div>
            <div className="flex items-center gap-3 flex-wrap">
              <Link
                href="/profile"
                className="inline-flex items-center gap-2 px-4 py-2.5 text-sm font-semibold text-teal-dark bg-teal-light rounded-full border border-teal/30 hover:bg-teal hover:text-white hover:border-teal transition-colors"
              >
                <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" />
                </svg>
                View Profile &amp; Certifications
              </Link>
              <div className="flex items-center gap-6 bg-white border border-border rounded-2xl px-5 py-4 shadow-sm">
                <StreakFlame streak={currentStreak} size="md" />
                <div className="h-10 w-px bg-border" />
                <div className="flex flex-col leading-tight">
                  <span className="text-lg sm:text-2xl font-bold text-navy">
                    {totalXp.toLocaleString()}
                  </span>
                  <span className="text-xs text-navy/50">{t("learn.totalXp")}</span>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
            {progress.map((entry) => (
              <LanguageProgressCard
                key={entry.language.id}
                entry={entry}
                localizedName={getLocalizedLanguageName(
                  entry.language.code,
                  uiLang,
                  entry.language.name,
                )}
                notStartedLabel={t("learn.notStarted")}
                lessonsLabel={t("learn.lessons")}
              />
            ))}
          </div>
        </section>
      </main>
      <Footer />
    </>
  );
}

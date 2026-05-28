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
  getFirstIncompleteLessonId,
} from "@/lib/learn";

export const metadata = {
  title: "Dashboard — Languages Center",
};

import { FLAG_CODES } from "@/lib/flag-codes";
import { getServerT } from "@/lib/i18n-server";

export default async function DashboardPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const t = await getServerT();
  const [progress, profile, weeklyCount] = await Promise.all([
    getLanguagesWithProgress(),
    getUserProfile(),
    getLessonsCompletedThisWeek(),
  ]);

  const started = progress.filter(
    (p) => p.completedLessons > 0 || (p.stats?.total_xp ?? 0) > 0,
  );

  const continueTargets = await Promise.all(
    started.map(async (entry) => ({
      entry,
      lessonId: await getFirstIncompleteLessonId(entry.language.id),
    })),
  );

  const totalXp = profile?.total_xp ?? 0;
  const streak = profile?.current_streak ?? 0;
  const longest = profile?.longest_streak ?? 0;

  return (
    <>
      <Navbar />
      <main className="flex-1">
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-10 pb-6">
          <h1 className="text-3xl sm:text-4xl font-bold text-navy tracking-tight">
            {t("dashboard.welcomeBack")}
          </h1>
          <p className="text-sm text-navy/60 mt-1.5">
            {t("dashboard.subtitle")}
          </p>
        </section>

        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-8">
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
            <div className="bg-white border border-border rounded-2xl p-5">
              <StreakFlame streak={streak} size="lg" />
              <p className="text-xs text-navy/40 mt-3">
                {t("dashboard.longest")}: <span className="font-semibold text-navy/60">{longest} {t("dashboard.days")}</span>
              </p>
            </div>
            <div className="bg-white border border-border rounded-2xl p-5">
              <p className="text-xs font-semibold text-teal-dark uppercase tracking-wide mb-2">
                {t("dashboard.totalXp")}
              </p>
              <p className="text-3xl font-bold text-navy">{totalXp.toLocaleString()}</p>
              <p className="text-xs text-navy/40 mt-1">{t("dashboard.allLangs")}</p>
            </div>
            <div className="bg-white border border-border rounded-2xl p-5">
              <p className="text-xs font-semibold text-teal-dark uppercase tracking-wide mb-2">
                {t("dashboard.thisWeek")}
              </p>
              <p className="text-3xl font-bold text-navy">{weeklyCount}</p>
              <p className="text-xs text-navy/40 mt-1">{t("dashboard.weekLessons")}</p>
            </div>
            <div className="bg-white border border-border rounded-2xl p-5">
              <p className="text-xs font-semibold text-teal-dark uppercase tracking-wide mb-2">
                {t("dashboard.languages")}
              </p>
              <p className="text-3xl font-bold text-navy">
                {started.length}
                <span className="text-sm font-medium text-navy/40"> / {progress.length}</span>
              </p>
              <p className="text-xs text-navy/40 mt-1">{t("dashboard.started")}</p>
            </div>
          </div>
        </section>

        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-8">
          <h2 className="text-xl font-bold text-navy mb-4">{t("dashboard.streaksByLanguage")}</h2>
          {started.length === 0 ? (
            <div className="bg-white border border-border rounded-2xl p-8 text-center">
              <p className="text-sm text-navy/60 mb-4">
                {t("dashboard.noLanguagesYet")}
              </p>
              <Link
                href="/learn"
                className="inline-block px-5 py-2.5 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors"
              >
                {t("dashboard.browseLanguages")}
              </Link>
            </div>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              {started.map(({ language, stats }) => {
                const code = FLAG_CODES[language.code] ?? language.code;
                return (
                  <div
                    key={language.id}
                    className="bg-white border border-border rounded-2xl p-5 flex items-center gap-4"
                  >
                    <Image
                      src={`https://flagcdn.com/w80/${code}.png`}
                      alt={`${language.name} flag`}
                      width={48}
                      height={36}
                      className="rounded-sm object-cover shadow-sm"
                    />
                    <div className="flex-1">
                      <p className="font-semibold text-navy">{language.name}</p>
                      <p className="text-xs text-navy/50">
                        {stats?.total_xp ?? 0} {t("dashboard.xpEarned")}
                      </p>
                    </div>
                    <StreakFlame streak={stats?.current_streak ?? 0} size="sm" />
                  </div>
                );
              })}
            </div>
          )}
        </section>

        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
          <h2 className="text-xl font-bold text-navy mb-4">{t("dashboard.continueLearning")}</h2>
          {continueTargets.length === 0 ? (
            <p className="text-sm text-navy/50">
              {t("dashboard.startLanguage")}{" "}
              <Link href="/learn" className="text-teal font-medium hover:text-teal-dark">
                {t("dashboard.learnPage")}
              </Link>{" "}
              {t("dashboard.toSeeProgress")}
            </p>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              {continueTargets.map(({ entry, lessonId }) => {
                const code = FLAG_CODES[entry.language.code] ?? entry.language.code;
                const href = lessonId
                  ? `/learn/${entry.language.code}/${lessonId}`
                  : `/learn/${entry.language.code}`;
                const cta = lessonId ? t("dashboard.continue") : t("dashboard.reviewCourse");
                return (
                  <div
                    key={entry.language.id}
                    className="bg-white border border-border rounded-2xl p-5"
                  >
                    <div className="flex items-center gap-3 mb-3">
                      <Image
                        src={`https://flagcdn.com/w80/${code}.png`}
                        alt={`${entry.language.name} flag`}
                        width={36}
                        height={27}
                        className="rounded-sm object-cover shadow-sm"
                      />
                      <div>
                        <p className="font-semibold text-navy">{entry.language.name}</p>
                        <p className="text-xs text-navy/50">
                          {entry.completedLessons} / {entry.totalLessons} {t("learn.lessons")}
                        </p>
                      </div>
                    </div>
                    <div className="w-full h-2 bg-navy/5 rounded-full overflow-hidden mb-4">
                      <div
                        className="h-full bg-gradient-to-r from-teal to-teal-dark rounded-full"
                        style={{ width: `${entry.progressPct}%` }}
                      />
                    </div>
                    <Link
                      href={href}
                      className="block w-full py-2.5 text-center text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors"
                    >
                      {cta}
                    </Link>
                  </div>
                );
              })}
            </div>
          )}
        </section>
      </main>
      <Footer />
    </>
  );
}

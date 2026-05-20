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

export const metadata = {
  title: "Learn — Languages Center",
};

const FLAG_CODES: Record<string, string> = {
  spanish: "es",
  french: "fr",
  german: "de",
  greek: "gr",
  swedish: "se",
  danish: "dk",
  finnish: "fi",
  albanian: "al",
  icelandic: "is",
  faroese: "fo",
  corsican: "fr",
  english: "gb",
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

function LanguageProgressCard({ entry }: { entry: LanguageProgress }) {
  const code = FLAG_CODES[entry.language.code] ?? entry.language.code;
  return (
    <Link
      href={`/learn/${entry.language.code}`}
      className="group bg-white border border-border rounded-2xl p-6 hover:shadow-lg hover:border-teal/40 hover:scale-[1.02] transition-all duration-200"
    >
      <div className="flex items-center justify-between mb-4">
        <Image
          src={`https://flagcdn.com/w80/${code}.png`}
          alt={`${entry.language.name} flag`}
          width={40}
          height={30}
          className="rounded-sm object-cover shadow-sm"
        />
        {entry.stats && entry.stats.total_xp > 0 ? (
          <span className="text-xs font-semibold text-teal-dark bg-teal-light px-2.5 py-1 rounded-full">
            {entry.stats.total_xp} XP
          </span>
        ) : (
          <span className="text-xs text-navy/40">Not started</span>
        )}
      </div>
      <h3 className="text-lg font-semibold text-navy mb-3 group-hover:text-teal transition-colors">
        {entry.language.name}
      </h3>
      <div className="space-y-2">
        <ProgressBar pct={entry.progressPct} />
        <div className="flex items-center justify-between text-xs text-navy/50">
          <span>
            {entry.completedLessons} / {entry.totalLessons} lessons
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
                Keep learning
              </h1>
              <p className="text-sm text-navy/60 mt-1.5">
                Pick a language and continue where you left off.
              </p>
            </div>
            <div className="flex items-center gap-6 bg-white border border-border rounded-2xl px-5 py-4 shadow-sm">
              <StreakFlame streak={currentStreak} size="md" />
              <div className="h-10 w-px bg-border" />
              <div className="flex flex-col leading-tight">
                <span className="text-lg sm:text-2xl font-bold text-navy">
                  {totalXp.toLocaleString()}
                </span>
                <span className="text-xs text-navy/50">total XP</span>
              </div>
            </div>
          </div>
        </section>

        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
            {progress.map((entry) => (
              <LanguageProgressCard key={entry.language.id} entry={entry} />
            ))}
          </div>
        </section>
      </main>
      <Footer />
    </>
  );
}

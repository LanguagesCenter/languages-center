import Link from "next/link";
import { redirect } from "next/navigation";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { createClient } from "@/lib/supabase/server";
import { getAllAttemptsForUser, type PlacementAttempt } from "@/lib/placement-exam";

export const metadata = {
  title: "Profile — Languages Center",
};

// Known placement exams we currently offer. Add to this as new ones land.
const KNOWN_EXAMS: Array<{ language_slug: string; language_name: string; level: string; href: string }> = [
  {
    language_slug: "spanish",
    language_name: "Spanish",
    level: "A1",
    href: "/learn/spanish/placement/a1",
  },
];

type AttemptWithLanguage = PlacementAttempt & {
  language: { code: string; name: string };
};

function ScoreBar({ pct }: { pct: number }) {
  const hue = Math.round((pct / 100) * 120);
  return (
    <div className="w-full h-2.5 rounded-full bg-navy/5 overflow-hidden">
      <div
        className="h-full rounded-full transition-all"
        style={{ width: `${pct}%`, backgroundColor: `hsl(${hue}, 70%, 45%)` }}
      />
    </div>
  );
}

export default async function ProfilePage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    redirect("/login?next=/profile");
  }

  const attempts = (await getAllAttemptsForUser(user.id)) as AttemptWithLanguage[];
  // Latest attempt per (language_code, level)
  const latestByKey = new Map<string, AttemptWithLanguage>();
  for (const a of attempts) {
    const k = `${a.language.code}::${a.level}`;
    if (!latestByKey.has(k)) latestByKey.set(k, a);
  }

  const displayName =
    (user.user_metadata?.full_name as string | undefined) ??
    user.email?.split("@")[0] ??
    "Learner";
  const initials = displayName
    .split(" ")
    .map((n) => n[0]?.toUpperCase() ?? "")
    .join("")
    .slice(0, 2);
  const joined = user.created_at ? new Date(user.created_at) : null;
  const isPremium = !!user.user_metadata?.is_premium;

  return (
    <>
      <Navbar />
      <main className="flex-1">
        <section className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 pt-10 pb-8">
          {/* PROFILE */}
          <div className="bg-white border border-border rounded-2xl p-6 mb-6">
            <div className="flex items-center gap-5">
              <div className="w-16 h-16 rounded-full bg-teal-light text-teal-dark flex items-center justify-center text-xl font-bold">
                {initials || "?"}
              </div>
              <div className="flex-1 min-w-0">
                <h1 className="text-2xl font-bold text-navy tracking-tight truncate">
                  {displayName}
                </h1>
                <p className="text-sm text-navy/60 truncate">{user.email}</p>
                {joined && (
                  <p className="text-xs text-navy/40 mt-0.5">
                    Joined {joined.toLocaleDateString()}
                  </p>
                )}
              </div>
              <button
                type="button"
                className="px-4 py-2 text-sm font-semibold text-teal-dark bg-teal-light rounded-full hover:bg-teal hover:text-white transition-colors"
              >
                Edit profile
              </button>
            </div>
          </div>

          {/* SETTINGS */}
          <div className="bg-white border border-border rounded-2xl p-6 mb-6">
            <h2 className="text-lg font-bold text-navy mb-4">Settings</h2>
            <dl className="space-y-3 text-sm">
              <div className="flex items-center justify-between">
                <dt className="text-navy/60">Site language</dt>
                <dd className="text-navy font-medium">Use the language switcher in the navbar.</dd>
              </div>
              <div className="flex items-center justify-between">
                <dt className="text-navy/60">Email notifications</dt>
                <dd className="text-navy font-medium">Coming soon</dd>
              </div>
              <div className="flex items-center justify-between">
                <dt className="text-navy/60">Subscription</dt>
                <dd className="flex items-center gap-3">
                  <span
                    className={`px-2.5 py-1 rounded-full text-xs font-semibold ${
                      isPremium
                        ? "bg-teal-light text-teal-dark"
                        : "bg-navy/5 text-navy/60"
                    }`}
                  >
                    {isPremium ? "Premium" : "Free"}
                  </span>
                  <Link
                    href="/pricing"
                    className="text-xs font-semibold text-teal-dark hover:text-teal"
                  >
                    Manage
                  </Link>
                </dd>
              </div>
            </dl>
          </div>

          {/* CERTIFICATIONS */}
          <div className="bg-white border border-border rounded-2xl p-6">
            <h2 className="text-lg font-bold text-navy mb-4">Certifications</h2>
            <div className="space-y-3">
              {KNOWN_EXAMS.map((exam) => {
                const key = `${exam.language_slug}::${exam.level}`;
                const attempt = latestByKey.get(key);
                if (!attempt) {
                  return (
                    <div
                      key={key}
                      className="flex items-center justify-between gap-4 border border-dashed border-border rounded-xl p-4 bg-navy/2"
                    >
                      <div>
                        <p className="text-sm font-semibold text-navy">
                          {exam.language_name} {exam.level}
                        </p>
                        <p className="text-xs text-navy/40">Not yet attempted</p>
                      </div>
                      <Link
                        href={exam.href}
                        className="px-4 py-2 text-sm font-semibold text-white bg-teal rounded-full hover:bg-teal-dark transition-colors"
                      >
                        Take exam
                      </Link>
                    </div>
                  );
                }
                return (
                  <div
                    key={key}
                    className="border border-border rounded-xl p-4 grid grid-cols-1 sm:grid-cols-[1fr_auto] gap-3 items-start"
                  >
                    <div className="min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <p className="text-sm font-semibold text-navy">
                          {exam.language_name} {exam.level}
                        </p>
                        <span
                          className={`px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider rounded-full ${
                            attempt.passed
                              ? "bg-teal-light text-teal-dark"
                              : "bg-red-50 text-red-700"
                          }`}
                        >
                          {attempt.passed ? "Pass" : "Fail"}
                        </span>
                      </div>
                      <p className="text-xs text-navy/40 mb-2">
                        Taken {new Date(attempt.completed_at).toLocaleDateString()}
                      </p>
                      <div className="grid grid-cols-[1fr_auto] items-center gap-3">
                        <ScoreBar pct={attempt.score_percentage} />
                        <span className="text-sm font-bold text-navy tabular-nums">
                          {attempt.score_percentage}%
                        </span>
                      </div>
                    </div>
                    <Link
                      href={exam.href}
                      className="px-4 py-2 text-sm font-semibold text-teal-dark bg-teal-light rounded-full hover:bg-teal hover:text-white transition-colors text-center"
                    >
                      Retake
                    </Link>
                  </div>
                );
              })}
            </div>
          </div>
        </section>
      </main>
      <Footer />
    </>
  );
}

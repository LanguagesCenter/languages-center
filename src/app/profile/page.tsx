import Link from "next/link";
import { redirect } from "next/navigation";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { createClient } from "@/lib/supabase/server";
import { getAllAttemptsForUser, type PlacementAttempt } from "@/lib/placement-exam";
import { isCurrentUserPremium } from "@/lib/learn";
import { signOut } from "@/lib/profile-actions";
import { getServerT } from "@/lib/i18n-server";
import UsernameForm from "./UsernameForm";

export const metadata = {
  title: "Profile — Languages Center",
};

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
  const isPremium = await isCurrentUserPremium();
  const t = await getServerT();
  const subStatus = (user.user_metadata?.subscription_status as
    | string
    | undefined) ?? null;
  const cancelAt = (user.user_metadata?.subscription_cancel_at as
    | string
    | undefined) ?? null;

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
                    {t("profile.joined", {
                      date: joined.toLocaleDateString(),
                    })}
                  </p>
                )}
              </div>
              <form action={signOut}>
                <button
                  type="submit"
                  className="px-4 py-2 text-sm font-semibold text-red-700 bg-red-50 rounded-full hover:bg-red-100 transition-colors"
                >
                  {t("profile.signOut")}
                </button>
              </form>
            </div>
          </div>

          {/* SETTINGS */}
          <div className="bg-white border border-border rounded-2xl p-6 mb-6">
            <h2 className="text-lg font-bold text-navy mb-4">
              {t("profile.settings")}
            </h2>
            <div className="mb-6 pb-6 border-b border-border">
              <UsernameForm initial={displayName} />
            </div>
            <dl className="space-y-3 text-sm">
              <div className="flex items-center justify-between">
                <dt className="text-navy/60">{t("switcher.label")}</dt>
                <dd className="text-navy font-medium">
                  {t("profile.useNavbarSwitcher")}
                </dd>
              </div>
              <div className="flex items-center justify-between">
                <dt className="text-navy/60">{t("profile.emailNotifs")}</dt>
                <dd className="text-navy font-medium">
                  {t("profile.comingSoon")}
                </dd>
              </div>
              <div className="flex items-center justify-between gap-3">
                <dt className="text-navy/60">{t("profile.subscription")}</dt>
                <dd className="flex flex-wrap items-center justify-end gap-2">
                  <span
                    className={`px-2.5 py-1 rounded-full text-xs font-semibold ${
                      isPremium
                        ? subStatus === "past_due"
                          ? "bg-red-50 text-red-700"
                          : subStatus === "canceling"
                            ? "bg-amber-50 text-amber-800"
                            : "bg-teal-light text-teal-dark"
                        : "bg-navy/5 text-navy/60"
                    }`}
                  >
                    {isPremium
                      ? t("profile.premium")
                      : t("profile.free")}
                  </span>
                  {/* Status detail: canceling on date, past-due, etc. */}
                  {subStatus === "canceling" && (
                    <span className="text-xs text-amber-800">
                      {cancelAt
                        ? t("profile.subCancelingOn", {
                            date: new Date(cancelAt).toLocaleDateString(),
                          })
                        : t("profile.subCanceling")}
                    </span>
                  )}
                  {subStatus === "past_due" && (
                    <span className="text-xs text-red-700">
                      {t("profile.subPastDue")}
                    </span>
                  )}
                  {subStatus === "trialing" && (
                    <span className="text-xs text-teal-dark">
                      {t("profile.subTrialing")}
                    </span>
                  )}
                  {!isPremium && subStatus === "canceled" && (
                    <span className="text-xs text-navy/50">
                      {t("profile.subCanceled")}
                    </span>
                  )}
                  <Link
                    href="/pricing"
                    className="text-xs font-semibold text-teal-dark hover:text-teal"
                  >
                    {t("profile.manage")}
                  </Link>
                </dd>
              </div>
            </dl>
          </div>

          {/* CERTIFICATIONS */}
          <div
            id="certifications"
            className="bg-white border border-border rounded-2xl p-6 scroll-mt-24"
          >
            <h2 className="text-lg font-bold text-navy mb-4">
              {t("profile.certifications")}
            </h2>
            {latestByKey.size === 0 ? (
              <div className="text-center py-8 border border-dashed border-border rounded-xl">
                <p className="text-sm text-navy/50">
                  {t("profile.noTests")}
                </p>
                <p className="text-xs text-navy/40 mt-1">
                  {t("profile.noTestsBody")}
                </p>
              </div>
            ) : (
              <div className="space-y-3">
                {Array.from(latestByKey.values()).map((attempt) => {
                  const key = `${attempt.language.code}::${attempt.level}`;
                  const examHref = `/learn/${attempt.language.code}/placement/${attempt.level.toLowerCase()}`;
                  return (
                    <div
                      key={key}
                      className="border border-border rounded-xl p-4 grid grid-cols-1 sm:grid-cols-[1fr_auto] gap-3 items-start"
                    >
                      <div className="min-w-0">
                        <div className="flex items-center gap-2 mb-1">
                          <p className="text-sm font-semibold text-navy">
                            {attempt.language.name} {attempt.level}
                          </p>
                          <span
                            className={`px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider rounded-full ${
                              attempt.passed
                                ? "bg-teal-light text-teal-dark"
                                : "bg-red-50 text-red-700"
                            }`}
                          >
                            {attempt.passed
                              ? t("profile.pass")
                              : t("profile.fail")}
                          </span>
                        </div>
                        <p className="text-xs text-navy/40 mb-2">
                          {t("profile.taken", {
                            date: new Date(
                              attempt.completed_at,
                            ).toLocaleDateString(),
                          })}
                        </p>
                        <div className="grid grid-cols-[1fr_auto] items-center gap-3">
                          <ScoreBar pct={attempt.score_percentage} />
                          <span className="text-sm font-bold text-navy tabular-nums">
                            {attempt.score_percentage}%
                          </span>
                        </div>
                      </div>
                      <Link
                        href={examHref}
                        className="px-4 py-2 text-sm font-semibold text-teal-dark bg-teal-light rounded-full hover:bg-teal hover:text-white transition-colors text-center"
                      >
                        {t("profile.retake")}
                      </Link>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        </section>
      </main>
      <Footer />
    </>
  );
}

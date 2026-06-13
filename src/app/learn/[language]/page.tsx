import Link from "next/link";
import Image from "next/image";
import { notFound, redirect } from "next/navigation";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { createClient } from "@/lib/supabase/server";
import {
  getLanguageBySlug,
  getCEFRTreeForLanguage,
  getHighestReachedLevel,
  isCurrentUserPremium,
  CEFR_LABEL,
  type CEFRLevelGroup,
  type SectionWithProgress,
} from "@/lib/learn";

import { FLAG_CODES } from "@/lib/flag-codes";
import { getServerLang, getServerT } from "@/lib/i18n-server";
import {
  getLocalizedLanguageName,
  translateSectionTitle,
  translateSectionDescription,
  type UiLang,
} from "@/lib/i18n";

const LEVEL_STYLES: Record<
  string,
  { ring: string; pillBg: string; pillText: string; accent: string; gradient: string }
> = {
  A1: {
    ring: "ring-emerald-200",
    pillBg: "bg-emerald-50",
    pillText: "text-emerald-700",
    accent: "text-emerald-700",
    gradient: "from-emerald-500/10 to-transparent",
  },
  A2: {
    ring: "ring-teal/30",
    pillBg: "bg-teal-light",
    pillText: "text-teal-dark",
    accent: "text-teal-dark",
    gradient: "from-teal/15 to-transparent",
  },
  B1: {
    ring: "ring-amber-200",
    pillBg: "bg-amber-50",
    pillText: "text-amber-800",
    accent: "text-amber-800",
    gradient: "from-amber-400/15 to-transparent",
  },
  B2: {
    ring: "ring-orange-200",
    pillBg: "bg-orange-50",
    pillText: "text-orange-800",
    accent: "text-orange-800",
    gradient: "from-orange-500/15 to-transparent",
  },
  C1: {
    ring: "ring-rose-200",
    pillBg: "bg-rose-50",
    pillText: "text-rose-800",
    accent: "text-rose-800",
    gradient: "from-rose-500/15 to-transparent",
  },
};

function CefrBadge({ level, size = "md" }: { level: string; size?: "sm" | "md" | "lg" }) {
  const styles = LEVEL_STYLES[level] ?? LEVEL_STYLES.A1;
  const padding =
    size === "lg" ? "px-3 py-1.5 text-sm" : size === "sm" ? "px-2 py-0.5 text-[10px]" : "px-2.5 py-1 text-xs";
  return (
    <span
      className={`inline-flex items-center gap-1.5 rounded-full font-semibold ${padding} ${styles.pillBg} ${styles.pillText} ring-1 ${styles.ring}`}
    >
      {level}
    </span>
  );
}

function SectionCard({
  section,
  languageSlug,
  uiLang,
  localizedLanguageName,
  doneLabel,
  lessonsLabel,
}: {
  section: SectionWithProgress;
  languageSlug: string;
  uiLang: UiLang;
  localizedLanguageName: string;
  doneLabel: string;
  lessonsLabel: string;
}) {
  const pct =
    section.lessonsTotal === 0
      ? 0
      : Math.round((section.lessonsCompleted / section.lessonsTotal) * 100);
  const complete = section.lessonsTotal > 0 && section.lessonsCompleted >= section.lessonsTotal;
  const localizedTitle = translateSectionTitle(section.title, uiLang);
  const localizedDescription = translateSectionDescription(
    section.title,
    section.cefr_level,
    localizedLanguageName,
    uiLang,
  );

  const body = (
    <div
      className={`relative h-full bg-white border rounded-2xl p-5 transition-all ${
        section.locked
          ? "border-border opacity-60"
          : "border-border hover:border-teal/40 hover:shadow-md hover:-translate-y-0.5"
      }`}
    >
      <div className="flex items-start justify-between mb-3">
        <CefrBadge level={section.cefr_level} size="sm" />
        {complete && (
          <span className="inline-flex items-center gap-1 text-xs font-semibold text-teal-dark">
            <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth={3} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
            </svg>
            {doneLabel}
          </span>
        )}
        {section.locked && (
          <svg className="w-4 h-4 text-navy/40" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 1 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z" />
          </svg>
        )}
      </div>
      <h3 className="text-base font-semibold text-navy leading-tight mb-2">
        {localizedTitle}
      </h3>
      <p className="text-xs text-navy/50 mb-4 line-clamp-2 leading-relaxed">
        {localizedDescription}
      </p>
      <div className="space-y-1.5">
        <div className="h-1.5 w-full rounded-full bg-navy/5 overflow-hidden">
          <div
            className="h-full rounded-full bg-gradient-to-r from-teal to-teal-dark transition-all"
            style={{ width: `${pct}%` }}
          />
        </div>
        <div className="flex items-center justify-between text-[11px] text-navy/50">
          <span>
            {section.lessonsCompleted} / {section.lessonsTotal} {lessonsLabel}
          </span>
          <span className="font-semibold text-navy/70">{pct}%</span>
        </div>
      </div>
    </div>
  );

  if (section.locked) return body;
  return (
    <Link href={`/learn/${languageSlug}/sections/${section.id}`} className="block">
      {body}
    </Link>
  );
}

function PlacementExamCard({
  languageSlug,
  level,
  isPremium,
}: {
  languageSlug: string;
  level: string;
  isPremium: boolean;
}) {
  return (
    <Link
      href={`/learn/${languageSlug}/placement/${level.toLowerCase()}`}
      className="block mb-4 bg-white border border-teal/40 rounded-2xl p-4 sm:p-5 hover:border-teal hover:shadow-md transition-all"
    >
      <div className="flex items-center gap-4">
        <div className="shrink-0 w-12 h-12 rounded-2xl bg-teal text-white flex items-center justify-center shadow-sm">
          <svg className="w-6 h-6" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-xs font-semibold text-teal-dark uppercase tracking-wider mb-0.5">
            {level} Placement Exam
          </p>
          <h3 className="text-base sm:text-lg font-bold text-navy leading-tight">
            Test your current Spanish level and earn your {level} certificate
          </h3>
          <p className="text-xs text-navy/50 mt-0.5">
            45 min · vocabulary, listening, speaking, writing
          </p>
        </div>
        {/* Pricing badge only for non-premium users. Premium users get a
            clean "Take Exam" pill with no paywall mention. */}
        {isPremium ? (
          <span className="shrink-0 hidden sm:inline-flex px-4 py-2 rounded-full bg-teal text-white text-sm font-semibold">
            Take Exam
          </span>
        ) : (
          <div className="shrink-0 hidden sm:flex flex-col items-end gap-1">
            <span className="px-3 py-1 rounded-full bg-teal-light text-teal-dark text-xs font-bold">
              Free with Premium
            </span>
            <span className="text-[10px] text-navy/50">or $0.99 one-time</span>
          </div>
        )}
        <svg className="shrink-0 w-5 h-5 text-teal" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
        </svg>
      </div>
    </Link>
  );
}

function LevelAccordion({
  group,
  languageSlug,
  defaultOpen,
  uiLang,
  localizedLanguageName,
  doneLabel,
  lessonsLabel,
  sectionsLabel,
  sectionLabel,
  noSectionsLabel,
  showPlacementExam,
  isPremium,
}: {
  group: CEFRLevelGroup;
  languageSlug: string;
  defaultOpen: boolean;
  uiLang: UiLang;
  localizedLanguageName: string;
  doneLabel: string;
  lessonsLabel: string;
  sectionsLabel: string;
  sectionLabel: string;
  noSectionsLabel: string;
  showPlacementExam: boolean;
  isPremium: boolean;
}) {
  const styles = LEVEL_STYLES[group.level] ?? LEVEL_STYLES.A1;
  const pct =
    group.lessonsTotal === 0
      ? 0
      : Math.round((group.lessonsCompleted / group.lessonsTotal) * 100);

  return (
    <details
      open={defaultOpen}
      className={`group rounded-3xl border border-border bg-gradient-to-br ${styles.gradient} overflow-hidden`}
    >
      <summary className="cursor-pointer list-none p-6 sm:p-7 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 select-none">
        <div className="flex items-center gap-4">
          <CefrBadge level={group.level} size="lg" />
          <div>
            <h2 className="text-xl font-bold text-navy tracking-tight">
              {group.label}
            </h2>
            <p className="text-xs text-navy/50 mt-0.5">
              {group.sections.length}{" "}
              {group.sections.length === 1 ? sectionLabel : sectionsLabel} ·{" "}
              {group.lessonsTotal} {lessonsLabel}
            </p>
          </div>
        </div>
        <div className="flex items-center gap-4">
          <div className="hidden sm:block w-48">
            <div className="h-1.5 w-full rounded-full bg-navy/10 overflow-hidden">
              <div
                className="h-full rounded-full bg-gradient-to-r from-teal to-teal-dark transition-all"
                style={{ width: `${pct}%` }}
              />
            </div>
            <p className="text-[11px] text-navy/50 mt-1.5 text-end">
              {group.lessonsCompleted} / {group.lessonsTotal} · {pct}%
            </p>
          </div>
          <svg
            className="w-5 h-5 text-navy/40 transition-transform group-open:rotate-180"
            fill="none"
            stroke="currentColor"
            strokeWidth={2.5}
            viewBox="0 0 24 24"
          >
            <path strokeLinecap="round" strokeLinejoin="round" d="M19 9l-7 7-7-7" />
          </svg>
        </div>
      </summary>

      <div className="px-6 sm:px-7 pb-6 sm:pb-7">
        {showPlacementExam && (
          <PlacementExamCard
            languageSlug={languageSlug}
            level={group.level}
            isPremium={isPremium}
          />
        )}
        {group.sections.length === 0 ? (
          <p className="text-sm text-navy/50">{noSectionsLabel}</p>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
            {group.sections.map((section) => (
              <SectionCard
                key={section.id}
                section={section}
                languageSlug={languageSlug}
                uiLang={uiLang}
                localizedLanguageName={localizedLanguageName}
                doneLabel={doneLabel}
                lessonsLabel={lessonsLabel}
              />
            ))}
          </div>
        )}
      </div>
    </details>
  );
}

export default async function LanguagePage(props: PageProps<"/learn/[language]">) {
  const { language: slug } = await props.params;

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const language = await getLanguageBySlug(slug);
  if (!language) notFound();

  const t = await getServerT();
  const uiLang = await getServerLang();
  const localizedLanguageName = getLocalizedLanguageName(
    language.code,
    uiLang,
    language.name,
  );

  const tree = await getCEFRTreeForLanguage(language.id);
  const flagCode = FLAG_CODES[language.code] ?? language.code;
  const reachedLevel = getHighestReachedLevel(tree);
  const isPremium = await isCurrentUserPremium();

  const totalLessons = tree.reduce((sum, g) => sum + g.lessonsTotal, 0);
  const completedLessons = tree.reduce((sum, g) => sum + g.lessonsCompleted, 0);
  const overallPct =
    totalLessons === 0 ? 0 : Math.round((completedLessons / totalLessons) * 100);

  // Open the level the user is most likely working on
  const openLevel: string =
    tree.find((g) => g.lessonsCompleted < g.lessonsTotal)?.level ?? reachedLevel;

  return (
    <>
      <Navbar />
      <main className="flex-1">
        <section className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pt-10 pb-8">
          <Link
            href="/learn"
            className="inline-flex items-center gap-1.5 text-sm text-navy/60 hover:text-teal transition-colors mb-6"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" />
            </svg>
            {t("cefr.allLanguages")}
          </Link>

          <div className="grid grid-cols-1 md:grid-cols-[auto_1fr_auto] gap-6 md:items-center">
            <Image
              src={`https://flagcdn.com/w160/${flagCode}.png`}
              alt={`${localizedLanguageName} flag`}
              width={80}
              height={60}
              className="rounded-md object-cover shadow-sm"
            />
            <div>
              <div className="flex items-center gap-3 mb-1">
                <h1 className="text-3xl sm:text-4xl font-bold text-navy tracking-tight">
                  {localizedLanguageName}
                </h1>
                <CefrBadge level={reachedLevel} size="md" />
              </div>
              <p className="text-sm text-navy/60">
                {t("cefr.lessonsComplete", {
                  completed: completedLessons,
                  total: totalLessons,
                })}{" "}
                · {t("cefr.overallPct", { pct: overallPct })}
              </p>
            </div>
            <div className="hidden md:flex flex-col items-end gap-2">
              <Link
                href={`/languages/${slug}/articles`}
                className="inline-flex items-center gap-2 text-sm font-medium text-teal hover:text-teal-dark transition-colors"
              >
                {t("overview.browseArticles")}
                <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
                </svg>
              </Link>
              <Link
                href={`/languages/${slug}`}
                className="text-xs text-navy/50 hover:text-navy/80 transition-colors"
              >
                {t("cefr.languageOverview")}
              </Link>
            </div>
          </div>

          <div className="mt-6 h-2 w-full rounded-full bg-navy/5 overflow-hidden">
            <div
              className="h-full rounded-full bg-gradient-to-r from-teal to-teal-dark transition-all"
              style={{ width: `${overallPct}%` }}
            />
          </div>

          {/* CEFR scale visualisation */}
          <div className="mt-3 flex items-center gap-2 text-[11px] font-semibold tracking-wider">
            {(["A1", "A2", "B1", "B2", "C1"] as const).map((lvl) => (
              <div key={lvl} className="flex-1 text-center">
                <span
                  className={`inline-block px-2 py-0.5 rounded-full ${
                    lvl === reachedLevel
                      ? "bg-teal text-white"
                      : "bg-navy/5 text-navy/40"
                  }`}
                >
                  {lvl}
                </span>
                <p className="text-[10px] text-navy/40 mt-0.5 font-normal">
                  {CEFR_LABEL[lvl]}
                </p>
              </div>
            ))}
          </div>
        </section>

        <section className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pb-20 space-y-4">
          {tree.map((group) => (
            <LevelAccordion
              key={group.level}
              group={group}
              languageSlug={slug}
              defaultOpen={group.level === openLevel}
              uiLang={uiLang}
              localizedLanguageName={localizedLanguageName}
              doneLabel={t("cefr.done")}
              lessonsLabel={t("learn.lessons")}
              sectionsLabel={t("cefr.sections")}
              sectionLabel={t("cefr.section")}
              noSectionsLabel={t("cefr.noSections")}
              showPlacementExam={
                slug === "spanish" &&
                ["A1", "A2", "B1", "B2", "C1"].includes(group.level)
              }
              isPremium={isPremium}
            />
          ))}
        </section>
      </main>
      <Footer />
    </>
  );
}

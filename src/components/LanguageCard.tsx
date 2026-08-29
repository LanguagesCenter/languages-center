"use client";

import Image from "next/image";
import Link from "next/link";
import { useI18n } from "@/components/I18nProvider";
import { getLocalizedLanguageName } from "@/lib/i18n";
import type { Language, Difficulty } from "@/lib/languages";
import { hasTravelPhrasebook } from "@/lib/travel-phrases";

// Languages with a Traveler's Course today (city-by-city trip
// simulator, separate from the CEFR curriculum). Add slugs here as
// courses get seeded in traveler_courses.
const TRAVELER_COURSE_SLUGS = new Set(["spanish", "french"]);
function hasTravelerCourse(slug: string): boolean {
  return TRAVELER_COURSE_SLUGS.has(slug);
}

function DifficultyBadge({ level }: { level: Difficulty }) {
  const { t } = useI18n();
  const colors: Record<Difficulty, string> = {
    Easy: "bg-teal-light text-teal-dark border-teal/20",
    Medium: "bg-peach-light text-amber-700 border-peach-dark/40",
    Hard: "bg-red-50 text-red-700 border-red-200",
  };
  const labelKey =
    level === "Easy" ? "card.easy" : level === "Medium" ? "card.medium" : "card.hard";

  return (
    <span
      className={`inline-block px-2.5 py-0.5 text-xs font-medium rounded-full border ${colors[level]}`}
    >
      {t(labelKey)}
    </span>
  );
}

function FlagImage({ countryCode, name }: { countryCode: string; name: string }) {
  return (
    <Image
      src={`https://flagcdn.com/w80/${countryCode}.png`}
      alt={`${name} flag`}
      width={48}
      height={36}
      className="rounded-md object-cover shadow-sm ring-1 ring-black/5"
    />
  );
}

export default function LanguageCard({
  language,
  lessonsTotal,
  hasProgress = false,
  travelerCompletedCount = 0,
}: {
  language: Language;
  lessonsTotal?: number;
  // True if the current user has at least one completed lesson in this
  // language. Determines whether the CTA reads "Start learning X" or
  // "Continue learning X".
  hasProgress?: boolean;
  // Number of Traveler's Course lessons this user has completed for the
  // language. Determines whether the Traveler's Course CTA reads "Start
  // Journey" (0 completions) or "Continue Journey" (≥1). 0 for anon.
  travelerCompletedCount?: number;
}) {
  const { t, lang } = useI18n();
  const localizedName = getLocalizedLanguageName(language.slug, lang, language.name);
  return (
    // Card body links to the overview page. The Start/Continue CTA below
    // is its own link that goes straight to the learning route. Both can't
    // be nested as <Link> inside <Link>, so the outer wrapper is a div.
    <div
      id={language.slug}
      // No translate/scale on touch devices: it feels janky when the press
      // animation overlaps card snap on small viewports. Hover-only motion
      // is restored for sm+ where a real cursor exists.
      className="group flex flex-col bg-white border border-border rounded-2xl p-5 sm:p-6 sm:hover:shadow-lg sm:hover:border-teal/40 sm:hover:-translate-y-0.5 focus-within:ring-2 focus-within:ring-teal focus-within:ring-offset-2 transition-all duration-200"
    >
      <Link
        href={`/languages/${language.slug}`}
        aria-label={`Learn more about ${localizedName}`}
        className="block focus-visible:outline-none"
      >
        <div className="flex items-start justify-between mb-4">
          <FlagImage countryCode={language.countryCode} name={language.name} />
          <span
            aria-hidden
            className="text-teal/0 group-hover:text-teal translate-x-0 group-hover:translate-x-1 transition-all duration-200"
          >
            <svg
              className="w-5 h-5"
              fill="none"
              stroke="currentColor"
              strokeWidth={2.5}
              viewBox="0 0 24 24"
            >
              <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
            </svg>
          </span>
        </div>
        <h3 className="text-lg sm:text-xl font-bold text-navy mb-1 group-hover:text-teal transition-colors tracking-tight">
          {localizedName}
        </h3>
        {typeof lessonsTotal === "number" && (
          <p className="text-xs text-navy/50 mb-3">
            {lessonsTotal} {lessonsTotal === 1 ? "lesson" : "lessons"}
          </p>
        )}
        <div className="space-y-2.5 mt-3">
          <div className="flex items-center justify-between">
            <span className="text-xs text-navy/50 uppercase tracking-wide font-medium">
              {t("card.grammar")}
            </span>
            <DifficultyBadge level={language.grammar} />
          </div>
          <div className="flex items-center justify-between">
            <span className="text-xs text-navy/50 uppercase tracking-wide font-medium">
              {t("card.pronunciation")}
            </span>
            <DifficultyBadge level={language.pronunciation} />
          </div>
        </div>
      </Link>

      {/* Phrase Passport badge — small pill, sits above the main CTA
          alongside any other quick-reference tags. Only rendered for
          languages that ship a phrasebook (Spanish + French today). */}
      {hasTravelPhrasebook(language.slug) && (
        <div className="mt-4 flex flex-wrap gap-2">
          <Link
            href={`/languages/${language.slug}/travel-guide`}
            onClick={(e) => e.stopPropagation()}
            className="inline-flex items-center gap-1.5 rounded-full bg-blue-100 text-blue-800 text-xs font-bold px-3 py-1.5 border border-blue-300 hover:bg-blue-200 hover:border-blue-400 active:scale-95 transition-colors"
            aria-label={`Open ${localizedName} Phrase Passport`}
          >
            <svg className="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 24 24" aria-hidden>
              <path d="M5 3a2 2 0 00-2 2v16l7-4 7 4V5a2 2 0 00-2-2H5z" />
            </svg>
            Phrase Passport
          </Link>
        </div>
      )}

      <Link
        href={`/learn/${language.slug}`}
        className="mt-4 inline-flex items-center justify-center gap-1.5 py-3 sm:py-2.5 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark active:scale-[0.98] transition-all"
      >
        {t(
          hasProgress ? "card.continueLearning" : "card.startLearning",
          { language: localizedName },
        )}
        <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
        </svg>
      </Link>

      {/* Traveler's Course mini-section — visually separated from the
          main card by a divider so it reads as a bonus feature rather
          than another badge. Whole row is a Link → /learn/{slug}/travel.
          CTA copy flips based on completed traveler-lesson count. */}
      {hasTravelerCourse(language.slug) && (
        <Link
          href={`/learn/${language.slug}/travel`}
          onClick={(e) => e.stopPropagation()}
          aria-label={`${
            travelerCompletedCount > 0 ? "Continue" : "Start"
          } ${localizedName} Traveler's Course`}
          className="group/traveler mt-4 -mx-5 sm:-mx-6 -mb-5 sm:-mb-6 px-5 sm:px-6 pt-4 pb-5 sm:pb-6 flex items-center justify-between gap-3 border-t border-dashed border-navy/10 bg-gradient-to-br from-orange-50/60 to-amber-50/40 rounded-b-2xl hover:from-orange-100/80 hover:to-amber-100/60 transition-colors"
        >
          <div className="flex items-center gap-2.5 min-w-0">
            <span className="shrink-0 w-8 h-8 rounded-lg bg-gradient-to-br from-orange-500 to-red-600 text-white flex items-center justify-center shadow-sm ring-2 ring-white">
              <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24" aria-hidden>
                <path d="M21 16v-2l-8-5V3.5a1.5 1.5 0 00-3 0V9l-8 5v2l8-2.5V19l-2 1.5V22l3.5-1L15 22v-1.5L13 19v-5.5L21 16z" />
              </svg>
            </span>
            <div className="min-w-0">
              <p className="text-[10px] font-bold uppercase tracking-[0.14em] text-orange-700/80 leading-none">
                Bonus
              </p>
              <p className="text-sm font-bold text-orange-950 leading-tight mt-0.5 truncate">
                Traveler&rsquo;s Course
              </p>
            </div>
          </div>
          <span className="shrink-0 inline-flex items-center gap-1 px-3 py-1.5 text-xs font-bold text-white bg-orange-600 rounded-full shadow-sm group-hover/traveler:bg-orange-700 group-hover/traveler:shadow-md transition-all whitespace-nowrap">
            {travelerCompletedCount > 0 ? "Continue Journey" : "Start Journey"}
            <svg className="w-3 h-3 group-hover/traveler:translate-x-0.5 transition-transform" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
            </svg>
          </span>
        </Link>
      )}
    </div>
  );
}

"use client";

import Image from "next/image";
import Link from "next/link";
import { useI18n } from "@/components/I18nProvider";
import { getLocalizedLanguageName } from "@/lib/i18n";
import type { Language, Difficulty } from "@/lib/languages";
import { hasTravelPhrasebook } from "@/lib/travel-phrases";

// Languages where the Traveler's Course now leads the card. These flip
// the primary CTA to "Start your trip" and demote the Fluency Course
// (ex-"Learn X") to a smaller secondary row. Other languages keep the
// Fluency Course as the primary action, unchanged.
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
  // language's Fluency Course. Determines whether the Fluency row below
  // reads "Start learning" or "Continue learning".
  hasProgress?: boolean;
  // Number of Traveler's Course lessons this user has completed for the
  // language. Determines whether the trip CTA reads "Start your trip"
  // (0 completions) or "Continue your trip" (≥1). 0 for anon.
  travelerCompletedCount?: number;
}) {
  const { t, lang } = useI18n();
  const localizedName = getLocalizedLanguageName(language.slug, lang, language.name);
  const travelerLang = hasTravelerCourse(language.slug);
  const hasTripProgress = travelerCompletedCount > 0;
  return (
    // Card body links to the overview page. Both CTAs are their own
    // links; nested anchors aren't valid, so the outer wrapper is a div.
    <div
      id={language.slug}
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

      {/* Phrase Lookup badge — small pill above the CTAs. Only rendered
          for languages that ship a phrasebook (Spanish + French today). */}
      {hasTravelPhrasebook(language.slug) && (
        <div className="mt-4 flex flex-wrap gap-2">
          <Link
            href={`/languages/${language.slug}/travel-guide`}
            onClick={(e) => e.stopPropagation()}
            className="inline-flex items-center gap-1.5 rounded-full bg-blue-100 text-blue-800 text-xs font-bold px-3 py-1.5 border border-blue-300 hover:bg-blue-200 hover:border-blue-400 active:scale-95 transition-colors"
            aria-label={`Open ${localizedName} Phrase Lookup`}
          >
            <svg className="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 24 24" aria-hidden>
              <path d="M5 3a2 2 0 00-2 2v16l7-4 7 4V5a2 2 0 00-2-2H5z" />
            </svg>
            {t("nav.phraseLookup")}
          </Link>
        </div>
      )}

      {/* Primary CTA — flips based on whether this language has a
          Traveler's Course. Spanish/French lead with the trip; other
          languages still lead with the Fluency Course. */}
      {travelerLang ? (
        <Link
          href={`/learn/${language.slug}/start`}
          onClick={(e) => e.stopPropagation()}
          className="mt-4 inline-flex items-center justify-center gap-1.5 py-3 sm:py-2.5 text-sm font-semibold text-white bg-gradient-to-br from-orange-500 to-red-600 rounded-xl hover:from-orange-600 hover:to-red-700 shadow-sm hover:shadow-md active:scale-[0.98] transition-all"
        >
          <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24" aria-hidden>
            <path d="M21 16v-2l-8-5V3.5a1.5 1.5 0 00-3 0V9l-8 5v2l8-2.5V19l-2 1.5V22l3.5-1L15 22v-1.5L13 19v-5.5L21 16z" />
          </svg>
          {hasTripProgress ? t("card.continueTrip") : t("card.startTrip")}
          <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
          </svg>
        </Link>
      ) : (
        <Link
          href={`/learn/${language.slug}`}
          onClick={(e) => e.stopPropagation()}
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
      )}

      {/* Fluency Course row — demoted on Spanish/French. Shows the
          Fluency Course as a secondary track inside the same card, with
          its own Start/Continue CTA. Hidden for languages where the
          Fluency Course IS the primary CTA (non-traveler languages),
          since showing it twice would just be noise. */}
      {travelerLang && (
        <Link
          href={`/learn/${language.slug}`}
          onClick={(e) => e.stopPropagation()}
          className="group/fluency mt-4 -mx-5 sm:-mx-6 -mb-5 sm:-mb-6 px-5 sm:px-6 pt-4 pb-5 sm:pb-6 flex items-center justify-between gap-3 border-t border-dashed border-navy/10 bg-gradient-to-br from-teal-light/30 to-teal-light/10 rounded-b-2xl hover:from-teal-light/60 hover:to-teal-light/30 transition-colors"
        >
          <div className="flex items-center gap-2.5 min-w-0">
            <span className="shrink-0 w-8 h-8 rounded-lg bg-teal text-white flex items-center justify-center shadow-sm ring-2 ring-white">
              <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24" aria-hidden>
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
              </svg>
            </span>
            <div className="min-w-0">
              <p className="text-[10px] font-bold uppercase tracking-[0.14em] text-teal-dark leading-none">
                A1 → C1
              </p>
              <p className="text-sm font-bold text-navy leading-tight mt-0.5 truncate">
                {t("card.fluencyCourse")}
              </p>
            </div>
          </div>
          <span className="shrink-0 inline-flex items-center gap-1 px-3 py-1.5 text-xs font-bold text-white bg-teal rounded-full shadow-sm group-hover/fluency:bg-teal-dark group-hover/fluency:shadow-md transition-all whitespace-nowrap">
            {hasProgress ? t("card.fluencyContinue") : t("card.fluencyStart")}
            <svg className="w-3 h-3 group-hover/fluency:translate-x-0.5 transition-transform" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
            </svg>
          </span>
        </Link>
      )}
    </div>
  );
}

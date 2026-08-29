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
}: {
  language: Language;
  lessonsTotal?: number;
  // True if the current user has at least one completed lesson in this
  // language. Determines whether the CTA reads "Start learning X" or
  // "Continue learning X".
  hasProgress?: boolean;
}) {
  const { t, lang } = useI18n();
  const localizedName = getLocalizedLanguageName(language.slug, lang, language.name);
  return (
    // Card body links to the overview page. The Start/Continue CTA below
    // is its own link that goes straight to the learning route. Both can't
    // be nested as <Link> inside <Link>, so the outer wrapper is a div.
    // `relative` is set so the optional Travel Guide corner tag can be
    // positioned inside the card.
    <div
      id={language.slug}
      // No translate/scale on touch devices: it feels janky when the press
      // animation overlaps card snap on small viewports. Hover-only motion
      // is restored for sm+ where a real cursor exists.
      className="group relative flex flex-col bg-white border border-border rounded-2xl p-5 sm:p-6 sm:hover:shadow-lg sm:hover:border-teal/40 sm:hover:-translate-y-0.5 focus-within:ring-2 focus-within:ring-teal focus-within:ring-offset-2 transition-all duration-200"
    >
      {/* Corner-tag stack. Traveler's Course sits above Travel Guide
          because it's the more immersive product; both share the
          top-right column and use z-10 so their click targets aren't
          swallowed by the card's Overview / Start-learning links. */}
      <div className="absolute top-3 right-3 z-10 flex flex-col items-end gap-1.5">
        {hasTravelerCourse(language.slug) && (
          <Link
            href={`/learn/${language.slug}/travel`}
            onClick={(e) => e.stopPropagation()}
            className="inline-flex items-center gap-1 rounded-full bg-sky-100 text-sky-900 text-[10px] sm:text-xs font-bold px-2.5 py-1 border border-sky-300 shadow-sm hover:bg-sky-200 hover:border-sky-400 active:scale-95 transition-colors"
            aria-label={`Open ${localizedName} traveler's course`}
          >
            <span aria-hidden>✈</span>
            Traveler&rsquo;s Course
          </Link>
        )}
        {hasTravelPhrasebook(language.slug) && (
          <Link
            href={`/languages/${language.slug}/travel-guide`}
            onClick={(e) => e.stopPropagation()}
            className="inline-flex items-center gap-1 rounded-full bg-amber-100 text-amber-900 text-[10px] sm:text-xs font-bold px-2.5 py-1 border border-amber-300 shadow-sm hover:bg-amber-200 hover:border-amber-400 active:scale-95 transition-colors"
            aria-label={`Open ${localizedName} travel phrase guide`}
          >
            <span aria-hidden>✈</span>
            Travel Guide
          </Link>
        )}
      </div>
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
      <Link
        href={`/learn/${language.slug}`}
        className="mt-5 inline-flex items-center justify-center gap-1.5 py-3 sm:py-2.5 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark active:scale-[0.98] transition-all"
      >
        {t(
          hasProgress ? "card.continueLearning" : "card.startLearning",
          { language: localizedName },
        )}
        <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
        </svg>
      </Link>
    </div>
  );
}

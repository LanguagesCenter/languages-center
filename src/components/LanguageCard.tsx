"use client";

import Image from "next/image";
import Link from "next/link";
import { useI18n } from "@/components/I18nProvider";
import { getLocalizedLanguageName } from "@/lib/i18n";
import type { Language, Difficulty } from "@/lib/languages";

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
      width={40}
      height={30}
      className="rounded-sm object-cover shadow-sm"
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
    <div
      id={language.slug}
      className="group flex flex-col bg-white border border-border rounded-2xl p-6 hover:shadow-lg hover:border-teal/40 hover:-translate-y-1 hover:scale-[1.02] focus-within:ring-2 focus-within:ring-teal focus-within:ring-offset-2 transition-all duration-200"
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
        <h3 className="text-lg font-semibold text-navy mb-1 group-hover:text-teal transition-colors">
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
        className="mt-5 inline-flex items-center justify-center gap-1.5 py-2.5 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors"
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

"use client";

import { useMemo } from "react";
import LanguageCard from "@/components/LanguageCard";
import { useI18n } from "@/components/I18nProvider";
import { UI_LANG_NAMES } from "@/lib/i18n";
import { sortByPopularity } from "@/lib/language-proximity";
import type { Language } from "@/lib/languages";

export interface LanguageGridItem extends Language {
  lessonsTotal?: number;
  hasProgress?: boolean;
}

export default function LanguageGrid({
  languages,
}: {
  languages: LanguageGridItem[];
}) {
  const { lang, t } = useI18n();

  // The user's UI language has its own dedicated card hidden — there's no
  // point promoting their native language as a learning target.
  const nativeSlug = UI_LANG_NAMES[lang]?.slug ?? null;

  const visible = useMemo(() => {
    const filtered = nativeSlug
      ? languages.filter((l) => l.slug !== nativeSlug)
      : languages;
    // Site-wide popularity ranking — matches the navbar dropdown and the
    // /learn page so cards appear in the same order everywhere.
    return sortByPopularity(filtered);
  }, [languages, nativeSlug]);

  if (languages.length === 0) {
    return (
      <div className="text-center py-16">
        <p className="text-sm text-navy/50">
          No languages available yet — check back soon.
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-5 sm:space-y-6">
      <p className="text-[11px] sm:text-xs uppercase tracking-[0.15em] font-semibold text-teal-dark">
        {t("home.recommended")}
      </p>
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 sm:gap-5 lg:gap-6">
        {visible.map((entry) => (
          <LanguageCard
            key={entry.slug}
            language={entry}
            lessonsTotal={entry.lessonsTotal}
            hasProgress={entry.hasProgress}
          />
        ))}
      </div>
    </div>
  );
}

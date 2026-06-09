"use client";

import { useMemo, useState } from "react";
import LanguageCard from "@/components/LanguageCard";
import { useI18n } from "@/components/I18nProvider";
import { UI_LANG_NAMES, getLocalizedLanguageName } from "@/lib/i18n";
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
  const { lang, t, ready } = useI18n();
  const [showNative, setShowNative] = useState(false);

  const nativeSlug = UI_LANG_NAMES[lang]?.slug ?? null;
  const nativeLanguage = nativeSlug
    ? languages.find((l) => l.slug === nativeSlug)
    : null;
  const nativeName = nativeLanguage
    ? getLocalizedLanguageName(nativeLanguage.slug, lang, nativeLanguage.name)
    : "";

  const visible = useMemo(() => {
    const filtered = ready
      ? languages.filter((l) => showNative || l.slug !== nativeSlug)
      : languages;
    // Site-wide popularity ranking — matches the navbar dropdown and the
    // /learn page so cards appear in the same order everywhere.
    return sortByPopularity(filtered);
  }, [languages, ready, nativeSlug, showNative]);

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
    <div className="space-y-6">
      {ready && (
        <div className="flex items-center justify-between">
          <p className="text-xs uppercase tracking-wider font-semibold text-teal-dark">
            {t("home.recommended")}
          </p>
          {nativeName && (
            <button
              type="button"
              onClick={() => setShowNative((s) => !s)}
              className="text-xs font-medium text-navy/60 hover:text-teal transition-colors"
            >
              {showNative
                ? t("home.hideNative")
                : t("home.addNative", { language: nativeName })}
            </button>
          )}
        </div>
      )}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
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

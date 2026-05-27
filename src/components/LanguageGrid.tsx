"use client";

import { useMemo, useState } from "react";
import LanguageCard from "@/components/LanguageCard";
import { useI18n } from "@/components/I18nProvider";
import { UI_LANG_NAMES, getLocalizedLanguageName } from "@/lib/i18n";
import { sortByProximity } from "@/lib/language-proximity";
import type { Language } from "@/lib/languages";

export default function LanguageGrid({ languages }: { languages: Language[] }) {
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
    return ready ? sortByProximity(filtered, lang) : filtered;
  }, [languages, ready, lang, nativeSlug, showNative]);

  // Until i18n is hydrated, render in the default English order to keep SSR
  // and the first paint identical. Once the client knows the user's UI lang
  // we re-sort and re-filter.
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
        {visible.map((lang) => (
          <LanguageCard key={lang.slug} language={lang} />
        ))}
      </div>
    </div>
  );
}

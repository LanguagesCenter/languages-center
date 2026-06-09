"use client";

import { useState } from "react";
import { useI18n } from "@/components/I18nProvider";
import { UI_LANG_NAMES } from "@/lib/i18n";

interface Props {
  // Translation paragraphs in the user's selected UI language, if the
  // article has one. Empty/undefined → fall back to English.
  paragraphsByLang?: Record<string, string[]>;
  englishParagraphs: string[];
}

/**
 * Translation panel for an article.
 *
 * Tries to show the translation in the user's selected site language.
 * The articles table currently stores only an English translation, so
 * the fallback path is hit for every non-English UI language. When that
 * happens we surface a clear "Showing English translation (UI lang
 * translation not yet available)" banner instead of pretending the
 * English copy is in the user's language.
 *
 * To add a real translation in, say, Spanish: store a Spanish copy of
 * `content_english` on the article row (we'd extend the schema to
 * something like `content_translations jsonb` keyed by UI lang) and
 * the loader populates `paragraphsByLang.es`. This component then
 * shows it without the fallback banner.
 */
export default function ArticleTranslation({
  paragraphsByLang,
  englishParagraphs,
}: Props) {
  const { t, lang } = useI18n();
  const [open, setOpen] = useState(false);

  const localized = paragraphsByLang?.[lang] ?? [];
  const usingFallback = lang !== "en" && localized.length === 0;
  const paragraphs = usingFallback || lang === "en" ? englishParagraphs : localized;

  const localizedLangName =
    UI_LANG_NAMES[lang]?.native ?? UI_LANG_NAMES.en.native;

  return (
    <div>
      <p className="text-xs font-semibold uppercase tracking-wider text-navy/40 mb-3">
        {t("article.translation")}
      </p>
      <button
        type="button"
        onClick={() => setOpen((o) => !o)}
        aria-expanded={open}
        className="inline-flex items-center gap-1.5 px-4 py-2 mb-4 text-sm font-semibold text-teal-dark bg-teal-light rounded-full hover:bg-teal hover:text-white transition-colors"
      >
        {open ? t("article.hideTranslation") : t("article.showTranslation")}
        <svg
          className={`w-3.5 h-3.5 transition-transform ${open ? "rotate-180" : ""}`}
          fill="none"
          stroke="currentColor"
          strokeWidth={2.5}
          viewBox="0 0 24 24"
        >
          <path strokeLinecap="round" strokeLinejoin="round" d="M19 9l-7 7-7-7" />
        </svg>
      </button>
      {open && (
        <>
          {usingFallback && (
            <div className="mb-4 rounded-xl border border-amber-200 bg-amber-50 px-4 py-3 text-xs text-amber-800">
              {t("article.englishFallback", {
                language: localizedLangName,
              })}
            </div>
          )}
          <div className="prose prose-sm max-w-none text-navy/70 leading-relaxed space-y-4">
            {paragraphs.map((p, i) => (
              <p key={i}>{p}</p>
            ))}
          </div>
        </>
      )}
    </div>
  );
}

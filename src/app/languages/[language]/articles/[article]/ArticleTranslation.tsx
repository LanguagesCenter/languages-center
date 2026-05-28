"use client";

import { useState } from "react";
import { useI18n } from "@/components/I18nProvider";

interface Props {
  paragraphs: string[];
}

// Hides the translation by default. Button label uses the user's UI lang.
// The translation content itself comes from the DB (currently English-only —
// to localize it per-language, store translations in the articles table.)
export default function ArticleTranslation({ paragraphs }: Props) {
  const { t } = useI18n();
  const [open, setOpen] = useState(false);

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
        <div className="prose prose-sm max-w-none text-navy/70 leading-relaxed space-y-4">
          {paragraphs.map((p, i) => (
            <p key={i}>{p}</p>
          ))}
        </div>
      )}
    </div>
  );
}

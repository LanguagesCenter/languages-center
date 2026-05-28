"use client";

import { useEffect, useRef, useState } from "react";
import Image from "next/image";
import { useI18n } from "@/components/I18nProvider";
import {
  SUPPORTED_UI_LANGUAGES,
  UI_LANG_NAMES,
  type UiLang,
} from "@/lib/i18n";

function FlagImg({
  countryCode,
  alt,
  size = 20,
}: {
  countryCode: string;
  alt: string;
  size?: number;
}) {
  const height = Math.round(size * 0.75);
  return (
    <span
      className="relative inline-block rounded-sm overflow-hidden shadow-sm shrink-0 ring-1 ring-black/5"
      style={{ width: `${size}px`, height: `${height}px` }}
    >
      <Image
        src={`https://flagcdn.com/w40/${countryCode}.png`}
        alt={alt}
        fill
        sizes={`${size}px`}
        className="object-cover"
        unoptimized
      />
    </span>
  );
}

export default function LanguageSwitcher() {
  const { lang, setLang, t } = useI18n();
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function onClick(e: MouseEvent) {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    }
    document.addEventListener("mousedown", onClick);
    return () => document.removeEventListener("mousedown", onClick);
  }, []);

  const current = UI_LANG_NAMES[lang];

  return (
    <div className="relative" ref={ref}>
      <button
        onClick={() => setOpen((o) => !o)}
        aria-label={t("switcher.label")}
        title={t("switcher.label")}
        className="flex items-center gap-2 px-2.5 py-1.5 text-sm font-medium text-navy/70 hover:text-teal rounded-full border border-border hover:border-teal/30 transition-colors"
      >
        <FlagImg countryCode={current.countryCode} alt="" size={20} />
        <span className="hidden sm:inline">{current.native}</span>
        <svg
          className={`w-3.5 h-3.5 transition-transform ${open ? "rotate-180" : ""}`}
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
        </svg>
      </button>
      {open && (
        <div
          role="menu"
          className="absolute end-0 top-full mt-2 w-60 max-h-96 overflow-y-auto bg-white rounded-xl shadow-lg border border-border py-1.5 z-50"
        >
          <p className="px-3 py-1.5 text-[10px] font-semibold uppercase tracking-wider text-navy/40">
            {t("switcher.label")}
          </p>
          {SUPPORTED_UI_LANGUAGES.map((code) => {
            const item = UI_LANG_NAMES[code as UiLang];
            const active = code === lang;
            return (
              <button
                key={code}
                onClick={() => {
                  setLang(code as UiLang);
                  setOpen(false);
                }}
                className={`w-full flex items-center gap-3 px-3 py-2 text-sm text-start transition-colors ${
                  active
                    ? "bg-teal-light text-teal-dark"
                    : "text-navy/80 hover:bg-peach-light hover:text-teal-dark"
                }`}
              >
                <FlagImg countryCode={item.countryCode} alt="" size={20} />
                <span className="flex-1 truncate">{item.native}</span>
                {active && (
                  <svg className="w-4 h-4 text-teal" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                  </svg>
                )}
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
}

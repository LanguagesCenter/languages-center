"use client";

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from "react";
import {
  DEFAULT_UI_LANG,
  RTL_LANGS,
  SUPPORTED_UI_LANGUAGES,
  detectBrowserLang,
  translate,
  type UiLang,
} from "@/lib/i18n";

interface I18nContextValue {
  lang: UiLang;
  setLang: (lang: UiLang) => void;
  t: (key: string, vars?: Record<string, string | number>) => string;
  ready: boolean;
}

const I18nContext = createContext<I18nContextValue | null>(null);

const STORAGE_KEY = "lc-ui-lang";
const COOKIE_KEY = "lc-ui-lang";

function writeCookie(value: string) {
  try {
    document.cookie = `${COOKIE_KEY}=${encodeURIComponent(value)};path=/;max-age=${60 * 60 * 24 * 365};samesite=lax`;
  } catch {
    /* ignore */
  }
}

export function I18nProvider({ children }: { children: React.ReactNode }) {
  const [lang, setLangState] = useState<UiLang>(DEFAULT_UI_LANG);
  const [ready, setReady] = useState(false);

  // First-load detection: prefer saved preference; otherwise walk
  // navigator.languages[] in priority order and accept the first supported
  // base code. Falls back to navigator.language, then English.
  useEffect(() => {
    let next: UiLang = DEFAULT_UI_LANG;
    try {
      const saved = window.localStorage.getItem(STORAGE_KEY);
      if (saved && (SUPPORTED_UI_LANGUAGES as readonly string[]).includes(saved)) {
        next = saved as UiLang;
      } else {
        next = detectBrowserLang({
          language: window.navigator.language,
          languages: window.navigator.languages,
        });
        // Persist the detection so future visits skip the navigator step.
        window.localStorage.setItem(STORAGE_KEY, next);
      }
    } catch {
      next = DEFAULT_UI_LANG;
    }
    setLangState(next);
    writeCookie(next);
    setReady(true);
  }, []);

  // Reflect the language and text direction on <html> so screen readers,
  // browser features and Tailwind's RTL utilities pick it up.
  useEffect(() => {
    if (typeof document !== "undefined") {
      document.documentElement.setAttribute("lang", lang);
      document.documentElement.setAttribute(
        "dir",
        RTL_LANGS.includes(lang) ? "rtl" : "ltr",
      );
    }
  }, [lang]);

  const setLang = useCallback((next: UiLang) => {
    setLangState(next);
    try {
      window.localStorage.setItem(STORAGE_KEY, next);
    } catch {
      /* ignore */
    }
    writeCookie(next);
  }, []);

  const value = useMemo<I18nContextValue>(
    () => ({
      lang,
      setLang,
      t: (key, vars) => translate(lang, key, vars),
      ready,
    }),
    [lang, setLang, ready],
  );

  return <I18nContext.Provider value={value}>{children}</I18nContext.Provider>;
}

export function useI18n(): I18nContextValue {
  const ctx = useContext(I18nContext);
  if (!ctx) {
    // Fall back to English without crashing if a consumer is rendered
    // outside the provider — useful during quick tests.
    return {
      lang: DEFAULT_UI_LANG,
      setLang: () => {},
      t: (key) => translate(DEFAULT_UI_LANG, key),
      ready: false,
    };
  }
  return ctx;
}

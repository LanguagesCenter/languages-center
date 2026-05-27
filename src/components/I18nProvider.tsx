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

export function I18nProvider({ children }: { children: React.ReactNode }) {
  const [lang, setLangState] = useState<UiLang>(DEFAULT_UI_LANG);
  const [ready, setReady] = useState(false);

  // First-load detection: prefer saved preference; otherwise sniff navigator.language.
  useEffect(() => {
    let next: UiLang = DEFAULT_UI_LANG;
    try {
      const saved = window.localStorage.getItem(STORAGE_KEY);
      if (saved && (SUPPORTED_UI_LANGUAGES as readonly string[]).includes(saved)) {
        next = saved as UiLang;
      } else {
        next = detectBrowserLang(window.navigator.language);
        // Persist the detection so future visits skip the navigator step.
        window.localStorage.setItem(STORAGE_KEY, next);
      }
    } catch {
      next = DEFAULT_UI_LANG;
    }
    setLangState(next);
    setReady(true);
  }, []);

  // Reflect the language on <html lang="..."> so screen readers and
  // browser features pick it up.
  useEffect(() => {
    if (typeof document !== "undefined") {
      document.documentElement.setAttribute("lang", lang);
    }
  }, [lang]);

  const setLang = useCallback((next: UiLang) => {
    setLangState(next);
    try {
      window.localStorage.setItem(STORAGE_KEY, next);
    } catch {
      /* ignore */
    }
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

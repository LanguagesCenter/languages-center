import { cookies } from "next/headers";
import {
  DEFAULT_UI_LANG,
  RTL_LANGS,
  SUPPORTED_UI_LANGUAGES,
  translate,
  type UiLang,
} from "./i18n";

export const UI_LANG_COOKIE = "lc-ui-lang";

/** Read the user's chosen UI language from the cookie set by I18nProvider. */
export async function getServerLang(): Promise<UiLang> {
  const store = await cookies();
  const value = store.get(UI_LANG_COOKIE)?.value;
  if (value && (SUPPORTED_UI_LANGUAGES as readonly string[]).includes(value)) {
    return value as UiLang;
  }
  return DEFAULT_UI_LANG;
}

export async function getServerDir(): Promise<"ltr" | "rtl"> {
  return RTL_LANGS.includes(await getServerLang()) ? "rtl" : "ltr";
}

/**
 * Server equivalent of useI18n().t — call it in a server component, get
 * back a t(key, vars) function bound to the current cookie language.
 */
export async function getServerT(): Promise<
  (key: string, vars?: Record<string, string | number>) => string
> {
  const lang = await getServerLang();
  return (key, vars) => translate(lang, key, vars);
}

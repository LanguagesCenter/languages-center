// Linguistic / geographic proximity ordering for the homepage.
// Given an interface-language UI code (e.g. "es"), return the target-language
// slugs in the order they should be presented (most relevant first).
//
// Lists deliberately exclude the user's native language — the homepage adds
// it back manually if the user opts in.

import type { UiLang } from "@/lib/i18n";

const PROXIMITY: Record<UiLang, string[]> = {
  en: ["german",   "french",  "spanish", "swedish", "danish",   "greek",     "icelandic", "corsican", "albanian", "finnish",  "faroese"],
  es: ["french",   "corsican","english", "german",  "greek",    "swedish",   "danish",    "icelandic","albanian", "finnish",  "faroese"],
  fr: ["spanish",  "corsican","english", "german",  "greek",    "swedish",   "danish",    "icelandic","albanian", "finnish",  "faroese"],
  de: ["english",  "swedish", "danish",  "icelandic","faroese", "french",    "spanish",   "greek",    "corsican", "albanian", "finnish"],
  el: ["english",  "french",  "spanish", "german",  "albanian", "swedish",   "danish",    "icelandic","corsican", "finnish",  "faroese"],
  sv: ["danish",   "icelandic","faroese","german",  "english",  "french",    "spanish",   "greek",    "corsican", "albanian", "finnish"],
  da: ["swedish",  "icelandic","faroese","german",  "english",  "french",    "spanish",   "greek",    "corsican", "albanian", "finnish"],
  fi: ["swedish",  "english", "danish",  "german",  "french",   "spanish",   "icelandic", "faroese",  "greek",    "corsican", "albanian"],
  sq: ["greek",    "english", "french",  "spanish", "german",   "swedish",   "danish",    "icelandic","corsican", "finnish",  "faroese"],
  is: ["faroese",  "danish",  "swedish", "german",  "english",  "french",    "spanish",   "greek",    "corsican", "albanian", "finnish"],
};

export function getRecommendedOrder(uiLang: UiLang): string[] {
  return PROXIMITY[uiLang] ?? PROXIMITY.en;
}

// Sort a list of language slugs by proximity for a given UI lang.
// Unknown slugs go to the end in alphabetical order.
export function sortByProximity<T extends { slug: string }>(
  items: T[],
  uiLang: UiLang,
): T[] {
  const order = getRecommendedOrder(uiLang);
  const indexOf = (slug: string) => {
    const idx = order.indexOf(slug);
    return idx === -1 ? order.length + 1 : idx;
  };
  return [...items].sort((a, b) => indexOf(a.slug) - indexOf(b.slug));
}

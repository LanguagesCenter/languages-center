// Linguistic / geographic proximity ordering for the homepage.
// Given an interface-language UI code (e.g. "es"), return the target-language
// slugs in the order they should be presented (most relevant first).
//
// For UI languages that are ALSO one of our target languages, the user's
// native language is omitted (the homepage adds it back via opt-in).
// For UI languages that aren't taught here, all 12 targets appear.

import type { UiLang } from "@/lib/i18n";

const PROXIMITY: Record<UiLang, string[]> = {
  // UI lang == target lang: exclude self.
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

  // UI langs we don't teach: all 12 targets appear.
  zh: ["english",  "french",  "german",  "spanish", "swedish",  "danish",    "greek",     "icelandic","corsican", "albanian", "finnish",  "faroese"],
  hi: ["english",  "french",  "spanish", "german",  "greek",    "swedish",   "danish",    "icelandic","corsican", "albanian", "finnish",  "faroese"],
  pt: ["spanish",  "french",  "corsican","english", "german",   "greek",     "swedish",   "danish",   "icelandic","albanian", "finnish",  "faroese"],
  bn: ["english",  "french",  "spanish", "german",  "greek",    "swedish",   "danish",    "icelandic","corsican", "albanian", "finnish",  "faroese"],
  ur: ["english",  "french",  "spanish", "german",  "greek",    "swedish",   "danish",    "icelandic","corsican", "albanian", "finnish",  "faroese"],
  ru: ["english",  "german",  "greek",   "french",  "spanish",  "swedish",   "danish",    "icelandic","albanian", "finnish",  "corsican", "faroese"],
  ja: ["english",  "french",  "german",  "spanish", "greek",    "swedish",   "danish",    "icelandic","corsican", "albanian", "finnish",  "faroese"],
  tr: ["greek",    "albanian","english", "french",  "german",   "spanish",   "swedish",   "danish",   "icelandic","corsican", "finnish",  "faroese"],
  vi: ["english",  "french",  "german",  "spanish", "greek",    "swedish",   "danish",    "icelandic","corsican", "albanian", "finnish",  "faroese"],
  ar: ["english",  "french",  "greek",   "spanish", "albanian", "german",    "swedish",   "danish",   "icelandic","corsican", "finnish",  "faroese"],
  ko: ["english",  "french",  "german",  "spanish", "greek",    "swedish",   "danish",    "icelandic","corsican", "albanian", "finnish",  "faroese"],
  it: ["french",   "spanish", "corsican","english", "german",   "greek",     "swedish",   "danish",   "icelandic","albanian", "finnish",  "faroese"],
  ms: ["english",  "french",  "german",  "spanish", "greek",    "swedish",   "danish",    "icelandic","corsican", "albanian", "finnish",  "faroese"],
  id: ["english",  "french",  "german",  "spanish", "greek",    "swedish",   "danish",    "icelandic","corsican", "albanian", "finnish",  "faroese"],
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

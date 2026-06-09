// Linguistic / geographic proximity ordering for the homepage.
// Given an interface-language UI code (e.g. "es"), return the 25 most
// relevant target-language slugs in order (the user's own language is
// excluded — the homepage adds it back via opt-in).

import type { UiLang } from "@/lib/i18n";

const PROXIMITY: Record<UiLang, string[]> = {
  en: ["german","french","spanish","italian","portuguese","swedish","danish","japanese","korean","chinese","russian","greek","turkish","arabic","hindi","urdu","bengali","vietnamese","malay","indonesian","icelandic","corsican","albanian","finnish","faroese"],
  es: ["portuguese","italian","french","corsican","english","german","greek","swedish","danish","russian","japanese","chinese","korean","arabic","turkish","hindi","urdu","bengali","vietnamese","malay","indonesian","icelandic","albanian","finnish","faroese"],
  fr: ["italian","spanish","portuguese","corsican","english","german","swedish","danish","greek","arabic","russian","japanese","chinese","korean","turkish","hindi","urdu","bengali","vietnamese","malay","indonesian","icelandic","albanian","finnish","faroese"],
  de: ["english","swedish","danish","icelandic","faroese","french","italian","spanish","portuguese","russian","greek","turkish","japanese","chinese","korean","arabic","hindi","urdu","bengali","vietnamese","malay","indonesian","corsican","albanian","finnish"],
  el: ["english","italian","french","spanish","albanian","turkish","portuguese","german","russian","arabic","japanese","chinese","korean","swedish","danish","hindi","urdu","bengali","vietnamese","malay","indonesian","icelandic","corsican","finnish","faroese"],
  sv: ["danish","icelandic","faroese","german","english","french","italian","spanish","portuguese","finnish","russian","greek","japanese","chinese","korean","turkish","arabic","hindi","urdu","bengali","vietnamese","malay","indonesian","corsican","albanian"],
  da: ["swedish","icelandic","faroese","german","english","french","italian","spanish","portuguese","finnish","russian","greek","japanese","chinese","korean","turkish","arabic","hindi","urdu","bengali","vietnamese","malay","indonesian","corsican","albanian"],
  fi: ["swedish","english","danish","icelandic","faroese","german","russian","french","italian","spanish","portuguese","greek","japanese","chinese","korean","turkish","arabic","hindi","urdu","bengali","vietnamese","malay","indonesian","corsican","albanian"],
  sq: ["greek","italian","english","french","spanish","turkish","german","russian","arabic","portuguese","swedish","danish","japanese","chinese","korean","hindi","urdu","bengali","vietnamese","malay","indonesian","icelandic","corsican","finnish","faroese"],
  is: ["faroese","danish","swedish","german","english","french","italian","spanish","portuguese","finnish","russian","greek","japanese","chinese","korean","turkish","arabic","hindi","urdu","bengali","vietnamese","malay","indonesian","corsican","albanian"],
  zh: ["japanese","korean","vietnamese","english","malay","indonesian","french","german","spanish","italian","portuguese","russian","arabic","hindi","urdu","bengali","turkish","greek","swedish","danish","icelandic","corsican","albanian","finnish","faroese"],
  hi: ["urdu","bengali","english","french","spanish","italian","portuguese","german","arabic","russian","japanese","chinese","korean","turkish","greek","swedish","danish","vietnamese","malay","indonesian","icelandic","corsican","albanian","finnish","faroese"],
  pt: ["spanish","italian","french","corsican","english","german","greek","swedish","danish","russian","japanese","chinese","korean","arabic","hindi","urdu","bengali","vietnamese","turkish","malay","indonesian","icelandic","albanian","finnish","faroese"],
  bn: ["hindi","urdu","english","french","spanish","italian","portuguese","german","arabic","russian","japanese","chinese","korean","turkish","greek","swedish","danish","vietnamese","malay","indonesian","icelandic","corsican","albanian","finnish","faroese"],
  ur: ["hindi","bengali","arabic","english","french","spanish","italian","portuguese","german","russian","japanese","chinese","korean","turkish","greek","swedish","danish","vietnamese","malay","indonesian","icelandic","corsican","albanian","finnish","faroese"],
  ru: ["english","german","greek","french","italian","spanish","portuguese","swedish","danish","finnish","japanese","chinese","korean","turkish","arabic","hindi","urdu","bengali","vietnamese","malay","indonesian","icelandic","corsican","albanian","faroese"],
  ja: ["korean","chinese","vietnamese","english","french","german","spanish","italian","portuguese","russian","arabic","hindi","urdu","bengali","turkish","greek","swedish","danish","malay","indonesian","icelandic","corsican","albanian","finnish","faroese"],
  tr: ["greek","albanian","english","french","italian","spanish","german","russian","arabic","portuguese","japanese","chinese","korean","hindi","urdu","bengali","swedish","danish","vietnamese","malay","indonesian","icelandic","corsican","finnish","faroese"],
  vi: ["chinese","korean","japanese","english","french","german","spanish","italian","portuguese","russian","arabic","hindi","urdu","bengali","turkish","greek","swedish","danish","malay","indonesian","icelandic","corsican","albanian","finnish","faroese"],
  ar: ["english","french","urdu","greek","spanish","italian","portuguese","german","turkish","hindi","bengali","russian","japanese","chinese","korean","albanian","swedish","danish","vietnamese","malay","indonesian","icelandic","corsican","finnish","faroese"],
  ko: ["japanese","chinese","vietnamese","english","french","german","spanish","italian","portuguese","russian","arabic","hindi","urdu","bengali","turkish","greek","swedish","danish","malay","indonesian","icelandic","corsican","albanian","finnish","faroese"],
  it: ["spanish","french","corsican","portuguese","english","german","greek","swedish","danish","russian","japanese","chinese","korean","arabic","hindi","urdu","bengali","vietnamese","turkish","malay","indonesian","icelandic","albanian","finnish","faroese"],
  ms: ["indonesian","english","chinese","japanese","korean","vietnamese","french","german","spanish","italian","portuguese","arabic","russian","hindi","urdu","bengali","turkish","greek","swedish","danish","icelandic","corsican","albanian","finnish","faroese"],
  id: ["malay","english","chinese","japanese","korean","vietnamese","french","german","spanish","italian","portuguese","arabic","russian","hindi","urdu","bengali","turkish","greek","swedish","danish","icelandic","corsican","albanian","finnish","faroese"],
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

// Site-wide popularity ranking. Used by every list that doesn't have its
// own per-user ordering (navbar dropdown, homepage cards, /learn page,
// language overview "related languages" fallback). Slugs not in this
// list fall to the end. Keep this list authoritative — when adding a
// new language to the curriculum, place it here too.
export const POPULARITY_ORDER: readonly string[] = [
  "spanish",
  "french",
  "italian",
  "portuguese",
  "german",
  "japanese",
  "korean",
  "chinese",
  "arabic",
  "russian",
  "hindi",
  "turkish",
  "vietnamese",
  "greek",
  "swedish",
  "danish",
  "finnish",
  "indonesian",
  "malay",
  "bengali",
  "urdu",
  "albanian",
  "icelandic",
  "faroese",
  "corsican",
  "english",
];

export function sortByPopularity<T extends { slug?: string; code?: string }>(
  items: T[],
): T[] {
  const indexOf = (key: string | undefined) => {
    if (!key) return POPULARITY_ORDER.length + 1;
    const idx = POPULARITY_ORDER.indexOf(key);
    return idx === -1 ? POPULARITY_ORDER.length + 1 : idx;
  };
  return [...items].sort(
    (a, b) => indexOf(a.slug ?? a.code) - indexOf(b.slug ?? b.code),
  );
}

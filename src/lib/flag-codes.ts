// Map our target-language slugs to the country code used by flagcdn.com.
// Used by every page that needs to render a flag from a language slug.

export const FLAG_CODES: Record<string, string> = {
  spanish:    "es",
  french:     "fr",
  german:     "de",
  greek:      "gr",
  swedish:    "se",
  danish:     "dk",
  finnish:    "fi",
  albanian:   "al",
  icelandic:  "is",
  faroese:    "fo",
  corsican:   "fr",
  english:    "gb",
  chinese:    "cn",
  hindi:      "in",
  portuguese: "pt",
  bengali:    "bd",
  urdu:       "pk",
  russian:    "ru",
  japanese:   "jp",
  turkish:    "tr",
  vietnamese: "vn",
  arabic:     "sa",
  korean:     "kr",
  italian:    "it",
  malay:      "my",
  indonesian: "id",
};

export function flagCodeForSlug(slug: string): string {
  return FLAG_CODES[slug] ?? slug;
}

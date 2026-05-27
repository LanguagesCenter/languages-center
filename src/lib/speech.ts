// Client-safe constants for the Web Speech API.
// Keep this file free of any server-only imports.

export const SPEECH_LANG_CODES: Record<string, string> = {
  spanish:    "es-ES",
  french:     "fr-FR",
  german:     "de-DE",
  greek:      "el-GR",
  swedish:    "sv-SE",
  danish:     "da-DK",
  finnish:    "fi-FI",
  albanian:   "sq-AL",
  icelandic:  "is-IS",
  faroese:    "fo-FO",
  corsican:   "it-IT", // Corsican has limited browser support; fall back to Italian.
  english:    "en-US",
  chinese:    "zh-CN",
  hindi:      "hi-IN",
  portuguese: "pt-PT",
  bengali:    "bn-BD",
  urdu:       "ur-PK",
  russian:    "ru-RU",
  japanese:   "ja-JP",
  turkish:    "tr-TR",
  vietnamese: "vi-VN",
  arabic:     "ar-SA",
  korean:     "ko-KR",
  italian:    "it-IT",
  malay:      "ms-MY",
  indonesian: "id-ID",
};

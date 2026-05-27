export type Difficulty = "Easy" | "Medium" | "Hard";

export interface Language {
  name: string;
  slug: string;
  countryCode: string;
  grammar: Difficulty;
  pronunciation: Difficulty;
}

export const languages: Language[] = [
  { name: "Spanish", slug: "spanish", countryCode: "es", grammar: "Easy", pronunciation: "Easy" },
  { name: "French", slug: "french", countryCode: "fr", grammar: "Easy", pronunciation: "Medium" },
  { name: "German", slug: "german", countryCode: "de", grammar: "Medium", pronunciation: "Medium" },
  { name: "Greek", slug: "greek", countryCode: "gr", grammar: "Medium", pronunciation: "Medium" },
  { name: "Swedish", slug: "swedish", countryCode: "se", grammar: "Easy", pronunciation: "Easy" },
  { name: "Danish", slug: "danish", countryCode: "dk", grammar: "Easy", pronunciation: "Medium" },
  { name: "Finnish", slug: "finnish", countryCode: "fi", grammar: "Hard", pronunciation: "Medium" },
  { name: "Albanian", slug: "albanian", countryCode: "al", grammar: "Hard", pronunciation: "Medium" },
  { name: "Icelandic", slug: "icelandic", countryCode: "is", grammar: "Hard", pronunciation: "Medium" },
  { name: "Faroese", slug: "faroese", countryCode: "fo", grammar: "Easy", pronunciation: "Medium" },
  { name: "Corsican", slug: "corsican", countryCode: "fr", grammar: "Medium", pronunciation: "Medium" },
  { name: "English", slug: "english", countryCode: "gb", grammar: "Easy", pronunciation: "Easy" },
  { name: "Chinese", slug: "chinese", countryCode: "cn", grammar: "Hard", pronunciation: "Hard" },
  { name: "Hindi", slug: "hindi", countryCode: "in", grammar: "Medium", pronunciation: "Medium" },
  { name: "Portuguese", slug: "portuguese", countryCode: "pt", grammar: "Easy", pronunciation: "Medium" },
  { name: "Bengali", slug: "bengali", countryCode: "bd", grammar: "Hard", pronunciation: "Medium" },
  { name: "Urdu", slug: "urdu", countryCode: "pk", grammar: "Hard", pronunciation: "Medium" },
  { name: "Russian", slug: "russian", countryCode: "ru", grammar: "Hard", pronunciation: "Medium" },
  { name: "Japanese", slug: "japanese", countryCode: "jp", grammar: "Hard", pronunciation: "Hard" },
  { name: "Turkish", slug: "turkish", countryCode: "tr", grammar: "Medium", pronunciation: "Medium" },
  { name: "Vietnamese", slug: "vietnamese", countryCode: "vn", grammar: "Hard", pronunciation: "Hard" },
  { name: "Arabic", slug: "arabic", countryCode: "sa", grammar: "Hard", pronunciation: "Hard" },
  { name: "Korean", slug: "korean", countryCode: "kr", grammar: "Hard", pronunciation: "Medium" },
  { name: "Italian", slug: "italian", countryCode: "it", grammar: "Easy", pronunciation: "Easy" },
  { name: "Malay", slug: "malay", countryCode: "my", grammar: "Easy", pronunciation: "Easy" },
  { name: "Indonesian", slug: "indonesian", countryCode: "id", grammar: "Easy", pronunciation: "Easy" },
];

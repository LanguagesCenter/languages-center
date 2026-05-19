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
];

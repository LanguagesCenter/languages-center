import type { Difficulty } from "@/lib/languages";

export interface LanguageOverview {
  slug: string;
  name: string;
  nativeName: string;
  countryCode: string;
  flagEmoji: string;
  grammar: Difficulty;
  pronunciation: Difficulty;
  speakers: string;
  regions: string;
  about: string;
  facts: string[];
  whyLearn: { title: string; description: string }[];
  courses: { title: "Beginner" | "Intermediate" | "Advanced"; description: string; topics: string[] }[];
  related: string[];
}

const standardCourses = (beginner: string, intermediate: string, advanced: string) =>
  [
    {
      title: "Beginner" as const,
      description: beginner,
      topics: ["Greetings", "Numbers 1–10", "Colours", "Family", "Common verbs"],
    },
    {
      title: "Intermediate" as const,
      description: intermediate,
      topics: ["Travel & directions", "Food & dining", "Past tense", "Shopping", "Daily routines"],
    },
    {
      title: "Advanced" as const,
      description: advanced,
      topics: ["Subjunctive mood", "Idioms", "Business vocab", "Literature", "Debate"],
    },
  ];

export const languageOverviews: Record<string, LanguageOverview> = {
  spanish: {
    slug: "spanish",
    name: "Spanish",
    nativeName: "Español",
    countryCode: "es",
    flagEmoji: "🇪🇸",
    grammar: "Easy",
    pronunciation: "Easy",
    speakers: "500+ million native speakers",
    regions: "Spain, Mexico, most of Latin America, Equatorial Guinea, parts of the US",
    about:
      "Spanish (español or castellano) is a Romance language that grew out of Vulgar Latin in the Iberian Peninsula and travelled across the Atlantic with the Spanish Empire. Today it is the world's second-most spoken native language, with vibrant regional varieties from Madrid to Buenos Aires.",
    facts: [
      "Official language of 20 countries plus Puerto Rico",
      "Cervantes' Don Quixote (1605) is widely regarded as the first modern novel",
      "Spelling is almost perfectly phonetic — pronunciation is a real beginner advantage",
    ],
    whyLearn: [
      {
        title: "Career leverage",
        description:
          "Spanish is the most useful second language for business across the Americas — and a major employability boost in the US, Spain, and Latin America.",
      },
      {
        title: "Cultural depth",
        description:
          "Unlock film, music, and literature from over twenty distinct national traditions — from flamenco to magical realism.",
      },
      {
        title: "Quick early wins",
        description:
          "Phonetic spelling, shared Latin roots with English, and gentle grammar make Spanish one of the fastest languages to find your feet in.",
      },
    ],
    courses: standardCourses(
      "Build a survival toolkit — introduce yourself, ask for help, and navigate shops, taxis, and menus.",
      "Move past tourist phrases into real conversations about your day, your past, and your plans.",
      "Refine the subjunctive, master idioms, and read literature with growing confidence.",
    ),
    related: ["french", "corsican", "english"],
  },

  french: {
    slug: "french",
    name: "French",
    nativeName: "Français",
    countryCode: "fr",
    flagEmoji: "🇫🇷",
    grammar: "Easy",
    pronunciation: "Medium",
    speakers: "300+ million speakers worldwide",
    regions: "France, Belgium, Switzerland, Canada (Québec), and much of West and Central Africa",
    about:
      "French (français) descends from Vulgar Latin spoken in Gaul. Carried across the world by exploration, trade, and diplomacy, it remains a working language of the UN, the EU, the IOC, and the Red Cross — and the second-most studied language on earth.",
    facts: [
      "Around 30% of English vocabulary is of French origin, mostly via the Norman Conquest",
      "French was the language of European diplomacy for nearly three centuries",
      "The Académie française has been guarding French since 1635 — and still debates new words today",
    ],
    whyLearn: [
      {
        title: "A global career edge",
        description:
          "French opens doors in diplomacy, fashion, luxury goods, and Africa's rapidly growing economies.",
      },
      {
        title: "Travel further, deeper",
        description:
          "From Paris bistros to Marrakech medinas and Montréal cafés, French lets you slip past the tourist surface.",
      },
      {
        title: "A massive vocabulary head start",
        description:
          "Thousands of English words — government, restaurant, fiancée — are already French. You know more than you think.",
      },
    ],
    courses: standardCourses(
      "Learn the sounds, the polite greetings, and the survival phrases for any first trip to a francophone city.",
      "Discuss food, travel, and daily life confidently, and start handling the passé composé and imparfait.",
      "Wrestle with the subjunctive, polish your accent, and read Le Monde with a dictionary at hand — at first.",
    ),
    related: ["spanish", "corsican", "english"],
  },

  german: {
    slug: "german",
    name: "German",
    nativeName: "Deutsch",
    countryCode: "de",
    flagEmoji: "🇩🇪",
    grammar: "Medium",
    pronunciation: "Medium",
    speakers: "130+ million speakers",
    regions: "Germany, Austria, Switzerland, Liechtenstein, parts of Belgium, Luxembourg, and Italy",
    about:
      "German (Deutsch) is a West Germanic language and the most widely spoken native tongue in the European Union. Famous for its logical compound words and its three grammatical genders, it sits at the heart of European philosophy, science, and engineering.",
    facts: [
      "All nouns are capitalised — der Hund, die Katze, das Buch",
      "Compound nouns can grow famously long: Donaudampfschifffahrtsgesellschaft is a real word",
      "Three genders (der, die, das) and four cases keep beginners on their toes",
    ],
    whyLearn: [
      {
        title: "Europe's economic engine",
        description:
          "Germany is the EU's largest economy. German is a serious advantage in engineering, automotive, finance, and research roles.",
      },
      {
        title: "A philosophical heritage",
        description:
          "Kant, Hegel, Nietzsche, Goethe, Mann — read them as they wrote, with all their precision intact.",
      },
      {
        title: "Gateway to Germanic languages",
        description:
          "Master German and Dutch, Swedish, and Danish all become measurably easier.",
      },
    ],
    courses: standardCourses(
      "Get to grips with der/die/das, build a starter vocabulary, and survive a trip to Berlin.",
      "Handle the four cases, talk about your past and your plans, and start understanding native speech.",
      "Polish your Konjunktiv, read literature unaided, and discuss politics or philosophy with nuance.",
    ),
    related: ["swedish", "danish", "english"],
  },

  greek: {
    slug: "greek",
    name: "Greek",
    nativeName: "Ελληνικά",
    countryCode: "gr",
    flagEmoji: "🇬🇷",
    grammar: "Medium",
    pronunciation: "Medium",
    speakers: "13+ million speakers",
    regions: "Greece, Cyprus, and Greek-speaking communities in Albania, Italy, and Turkey",
    about:
      "Greek (Ελληνικά) is the oldest documented Indo-European language, with a continuous written record stretching over 3,400 years. Modern Greek descends directly from Ancient Greek, and the modern script — adapted from Phoenician around 800 BCE — is still the same alphabet you'll see on Athenian street signs today.",
    facts: [
      "The Greek alphabet is the ancestor of the Latin and Cyrillic scripts",
      "Around 150,000 English words have Greek roots — democracy, philosophy, telephone, photograph",
      "Modern Greek keeps distinct formal and informal forms of 'you'",
    ],
    whyLearn: [
      {
        title: "Read the originals",
        description:
          "Plato, Aristotle, and the New Testament were all written in Greek. Even modern Greek gets you remarkably close.",
      },
      {
        title: "Crack scientific vocabulary",
        description:
          "Once you know Greek roots, medical, scientific, and technical words start decoding themselves.",
      },
      {
        title: "A rich modern culture",
        description:
          "From rebetiko music to Theo Angelopoulos cinema, modern Greece has a culture every bit as compelling as its ancient one.",
      },
    ],
    courses: standardCourses(
      "Learn the alphabet, the sounds, and the everyday phrases you need for a first Greek summer.",
      "Talk about food, travel, and family — and start to feel the rhythm of native conversation.",
      "Read newspapers and short stories, understand the news, and discuss culture and history fluently.",
    ),
    related: ["albanian", "english", "icelandic"],
  },

  swedish: {
    slug: "swedish",
    name: "Swedish",
    nativeName: "Svenska",
    countryCode: "se",
    flagEmoji: "🇸🇪",
    grammar: "Easy",
    pronunciation: "Easy",
    speakers: "10+ million speakers",
    regions: "Sweden, parts of Finland (where it is co-official), Åland Islands",
    about:
      "Swedish (svenska) is a North Germanic language descended from Old Norse and the largest of the mainland Scandinavian languages. Its famously melodic two-tone pitch accent gives spoken Swedish a sing-song quality you can hear in almost any conversation.",
    facts: [
      "Mostly mutually intelligible with Norwegian and Danish in writing",
      "Three extra vowels — å, ä, ö — sit at the end of the alphabet",
      "Sweden gave the world IKEA, Spotify, Volvo, and Skype",
    ],
    whyLearn: [
      {
        title: "Friendly to English speakers",
        description:
          "Shared Germanic roots, similar word order, and minimal verb conjugation make Swedish one of the gentler languages to learn.",
      },
      {
        title: "Tech and design careers",
        description:
          "Sweden punches far above its weight in tech, gaming, and product design — Swedish is a real boost in those industries.",
      },
      {
        title: "Three languages in one",
        description:
          "Learn Swedish and you'll find written Norwegian and Danish surprisingly easy to follow.",
      },
    ],
    courses: standardCourses(
      "Master the pitch accent, the en/ett genders, and the small talk that opens any Swedish café conversation.",
      "Tell stories in the past tense, navigate IKEA in Swedish, and order fika like a local.",
      "Tackle complex word order, read Astrid Lindgren without help, and follow Swedish news comfortably.",
    ),
    related: ["danish", "icelandic", "german"],
  },

  danish: {
    slug: "danish",
    name: "Danish",
    nativeName: "Dansk",
    countryCode: "dk",
    flagEmoji: "🇩🇰",
    grammar: "Easy",
    pronunciation: "Medium",
    speakers: "6+ million speakers",
    regions: "Denmark, the Faroe Islands, Greenland, and northern Germany",
    about:
      "Danish (dansk) is a North Germanic language spoken across Denmark and as a second language in the Faroe Islands and Greenland. Its softly swallowed pronunciation is the source of countless friendly jokes among its Scandinavian neighbours — but it sits at the heart of one of the world's happiest countries.",
    facts: [
      "Danish numbers above twenty use a vigesimal (base-20) system: 50 is 'halvtreds' — literally 'half-third twenty'",
      "Spoken Danish is famously soft; written Danish is nearly identical to Norwegian Bokmål",
      "Denmark consistently ranks among the world's top three happiest countries",
    ],
    whyLearn: [
      {
        title: "Live and work happily",
        description:
          "Denmark offers one of the world's most rewarding work-life balances — and speaking Danish unlocks the social side of it.",
      },
      {
        title: "Two languages for the price of one",
        description:
          "Norwegian and Swedish become much easier once you can read Danish.",
      },
      {
        title: "Design and culture",
        description:
          "Get closer to Scandinavian design, the New Nordic kitchen, and Danish cinema's golden generation.",
      },
    ],
    courses: standardCourses(
      "Tame the famously soft pronunciation and learn the small talk Danes use every day.",
      "Discuss your week, the weather, and your weekend plans — and read children's stories with ease.",
      "Follow newspapers, hold opinions in writing, and crack the vigesimal numbers above forty.",
    ),
    related: ["swedish", "faroese", "icelandic"],
  },

  finnish: {
    slug: "finnish",
    name: "Finnish",
    nativeName: "Suomi",
    countryCode: "fi",
    flagEmoji: "🇫🇮",
    grammar: "Hard",
    pronunciation: "Medium",
    speakers: "5.5+ million speakers",
    regions: "Finland, parts of Sweden and Norway, Estonian-Finnish border communities",
    about:
      "Finnish (suomi) is a Uralic language — not Indo-European at all. It's a cousin to Estonian and a more distant relative of Hungarian, and its grammar will rewire how you think about language. Fifteen cases replace prepositions, and word endings carry meaning that English packages with extra words.",
    facts: [
      "Has 15 grammatical cases — twice as many as German",
      "No grammatical gender and no articles ('a' / 'the')",
      "The Kalevala, Finland's national epic, helped inspire Tolkien's Quenya elvish",
    ],
    whyLearn: [
      {
        title: "Rewire your brain",
        description:
          "Finnish's case system is a beautiful workout — once it clicks, you'll think about language in a new way.",
      },
      {
        title: "Live where the world is happy",
        description:
          "Finland ranks #1 in the World Happiness Report. Speaking Finnish opens up its quiet, generous culture.",
      },
      {
        title: "Rare and respected",
        description:
          "Few foreigners learn Finnish well — those who do are met with real warmth and curiosity.",
      },
    ],
    courses: standardCourses(
      "Learn the alphabet's perfect phonetic spelling, the basic cases, and the survival phrases.",
      "Tackle more cases, talk about everyday life, and start reading short stories with help.",
      "Master the consonant gradation, read Finnish literature, and write essays in clear, idiomatic Finnish.",
    ),
    related: ["swedish", "icelandic", "albanian"],
  },

  albanian: {
    slug: "albanian",
    name: "Albanian",
    nativeName: "Shqip",
    countryCode: "al",
    flagEmoji: "🇦🇱",
    grammar: "Hard",
    pronunciation: "Medium",
    speakers: "7.5+ million speakers",
    regions: "Albania, Kosovo, North Macedonia, Montenegro, and Albanian communities in Italy and Greece",
    about:
      "Albanian (shqip) is an Indo-European language that forms its own independent branch — no close living relatives. Its split into the northern Gheg and southern Tosk dialects gives the language a complex, layered identity, and its modern literary form was standardised on Tosk in 1972.",
    facts: [
      "An entire branch of the Indo-European family tree — no close cousins survive",
      "Two main dialect groups: Gheg (north) and Tosk (south)",
      "Albanian has a rich set of admirative verb forms used to express surprise or hearsay",
    ],
    whyLearn: [
      {
        title: "Rare and rewarding",
        description:
          "Few outsiders speak Albanian — locals will be delighted to meet you halfway.",
      },
      {
        title: "Travel the Balkans",
        description:
          "Albania, Kosovo, and parts of North Macedonia open up in a way English travel never quite manages.",
      },
      {
        title: "A unique literary tradition",
        description:
          "Read Ismail Kadare and contemporary Albanian poets in the original — a small but exquisite canon.",
      },
    ],
    courses: standardCourses(
      "Find your feet with the alphabet, the friendly greetings, and the simplest tenses.",
      "Discuss food, family, and travel, and start handling the noun cases with confidence.",
      "Read newspapers and novels, master the admirative mood, and write fluently.",
    ),
    related: ["greek", "icelandic", "faroese"],
  },

  icelandic: {
    slug: "icelandic",
    name: "Icelandic",
    nativeName: "Íslenska",
    countryCode: "is",
    flagEmoji: "🇮🇸",
    grammar: "Hard",
    pronunciation: "Medium",
    speakers: "≈350,000 speakers",
    regions: "Iceland, with small communities in Canada (notably Manitoba)",
    about:
      "Icelandic (íslenska) is a North Germanic language that has changed remarkably little since Viking settlers arrived in the 9th century. Modern Icelanders can read the 13th-century sagas with relative ease, and the country has an active language committee that coins native words rather than borrowing — 'tölva' (computer) literally means 'number prophetess'.",
    facts: [
      "Modern Icelanders read 13th-century Old Norse sagas with relative ease",
      "Uses the runic-derived letters þ (thorn) and ð (eth)",
      "New technical words are coined from native roots — 'tölva' for computer, 'sími' for telephone",
    ],
    whyLearn: [
      {
        title: "Read the sagas in the original",
        description:
          "Njál's Saga, the Eddas, Snorri Sturluson — Old Norse literature lives on in modern Icelandic.",
      },
      {
        title: "Deepen your Iceland trip",
        description:
          "Beyond Reykjavík's English-friendly tourist circuit lies a country whose books, films, and small-town life run in Icelandic.",
      },
      {
        title: "A linguistic achievement",
        description:
          "Few languages have remained this stable for a millennium — learning Icelandic is a window into how Europeans spoke a thousand years ago.",
      },
    ],
    courses: standardCourses(
      "Learn the alphabet (including þ and ð), the four cases at their simplest, and survival phrases.",
      "Read folk tales, talk about everyday life, and start handling the dreaded strong verbs.",
      "Read sagas in modernised editions, write essays, and discuss politics or literature with fluency.",
    ),
    related: ["faroese", "danish", "swedish"],
  },

  faroese: {
    slug: "faroese",
    name: "Faroese",
    nativeName: "Føroyskt",
    countryCode: "fo",
    flagEmoji: "🇫🇴",
    grammar: "Easy",
    pronunciation: "Medium",
    speakers: "≈70,000 speakers",
    regions: "Faroe Islands, and Faroese communities in Denmark",
    about:
      "Faroese (føroyskt) is a North Germanic language descended from Old West Norse, spoken in the windswept Faroe Islands — a self-governing archipelago of Denmark. It's the closest living relative of Icelandic and a survivor of one of Europe's most successful small-language revivals.",
    facts: [
      "Closest living relative of Icelandic — they share much of their grammar",
      "Only became an official school subject in 1937 — Danish was dominant before",
      "The Faroe Islands have one of Europe's most active small-language music scenes",
    ],
    whyLearn: [
      {
        title: "One of the world's rarest official languages",
        description:
          "Few outsiders ever learn Faroese — those who do are warmly welcomed.",
      },
      {
        title: "Doorway to Norse heritage",
        description:
          "Faroese is a living link to Old Norse, almost as conservative as Icelandic.",
      },
      {
        title: "Dramatic Atlantic culture",
        description:
          "From chain dance ballads to contemporary indie bands, Faroese culture is small but uncommonly vibrant.",
      },
    ],
    courses: standardCourses(
      "Get to grips with the writing system, the basic cases, and the everyday small talk of Tórshavn.",
      "Discuss food, weather, and daily life, and start reading short children's books with help.",
      "Read modern Faroese novels and ballads, and write fluently in long form.",
    ),
    related: ["icelandic", "danish", "swedish"],
  },

  corsican: {
    slug: "corsican",
    name: "Corsican",
    nativeName: "Corsu",
    countryCode: "fr",
    flagEmoji: "🇫🇷",
    grammar: "Medium",
    pronunciation: "Medium",
    speakers: "≈150,000 speakers",
    regions: "Corsica (France) and small communities in northern Sardinia",
    about:
      "Corsican (corsu) is a Romance language closer to medieval Tuscan than to modern French, spoken on the Mediterranean island of Corsica. UNESCO lists it as endangered, but a strong revival movement has put it back into schools, road signs, and local media.",
    facts: [
      "Closer to medieval Italian than to modern French",
      "UNESCO lists Corsican as endangered, but it is actively taught in Corsican schools",
      "Napoleon Bonaparte's first language was Corsican — French came later",
    ],
    whyLearn: [
      {
        title: "Open a Mediterranean window",
        description:
          "Corsica's culture — its food, music, and Napoleon's birthplace — is much richer in Corsican than in French.",
      },
      {
        title: "A bridge to Italian",
        description:
          "Once Corsican basics click, Italian becomes remarkably easy.",
      },
      {
        title: "Help preserve a beautiful language",
        description:
          "Every new learner is part of keeping an endangered Romance language alive.",
      },
    ],
    courses: standardCourses(
      "Learn pronunciation, basic verbs, and the everyday phrases of Bastia and Ajaccio.",
      "Talk about food, family, and the island, and read short stories and songs.",
      "Read Corsican poetry and prose, and discuss politics, history, and culture fluently.",
    ),
    related: ["french", "spanish", "english"],
  },

  english: {
    slug: "english",
    name: "English",
    nativeName: "English",
    countryCode: "gb",
    flagEmoji: "🇬🇧",
    grammar: "Easy",
    pronunciation: "Easy",
    speakers: "1.5+ billion speakers (around 400 million native)",
    regions: "United Kingdom, United States, Canada, Australia, New Zealand, Ireland — and the rest of the world as a lingua franca",
    about:
      "English is a West Germanic language that became the world's primary lingua franca through centuries of British influence and American cultural reach. It has the largest vocabulary of any human language and the most extensive body of literature, film, and online content.",
    facts: [
      "Around 170,000 words are in current use — the largest vocabulary of any language",
      "Has borrowed extensively from French, Latin, Norse, and dozens of other languages",
      "More people speak English as a second language than as a first",
    ],
    whyLearn: [
      {
        title: "The universal language",
        description:
          "Business, science, aviation, the internet, and pop culture all default to English.",
      },
      {
        title: "Travel anywhere",
        description:
          "Wherever you go, you'll find someone who speaks at least some English.",
      },
      {
        title: "Unmatched cultural library",
        description:
          "The world's largest film industries, music catalogues, and online libraries are all primarily English.",
      },
    ],
    courses: standardCourses(
      "Build a confident foundation in everyday English — greetings, small talk, and the present tense.",
      "Tell stories in past and future tenses, write short emails, and handle work and travel situations.",
      "Refine your style, master phrasal verbs and idioms, and write essays with native-level nuance.",
    ),
    related: ["german", "swedish", "danish"],
  },
};

export function getOverview(slug: string): LanguageOverview | null {
  return languageOverviews[slug] ?? null;
}

export function getAllOverviewSlugs(): string[] {
  return Object.keys(languageOverviews);
}

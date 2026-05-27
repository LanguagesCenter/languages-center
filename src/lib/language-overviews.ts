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

  chinese: {
    slug: "chinese",
    name: "Chinese",
    nativeName: "中文",
    countryCode: "cn",
    flagEmoji: "🇨🇳",
    grammar: "Hard",
    pronunciation: "Hard",
    speakers: "1.1 billion+ native speakers (Mandarin)",
    regions: "Mainland China, Taiwan, Singapore, and Chinese-speaking communities worldwide",
    about:
      "Mandarin Chinese (普通话, Pǔtōnghuà) is the most widely spoken language on earth by native speakers. It uses a logographic writing system whose characters can date back over 3,000 years, and a four-tone pitch system that gives spoken Mandarin its distinctive musical quality.",
    facts: [
      "Four pitch tones (plus a neutral) change the meaning of otherwise identical syllables",
      "Modern Chinese uses around 3,500 characters for everyday literacy",
      "There is no verb conjugation, no gender, and no plural — context does the heavy lifting",
    ],
    whyLearn: [
      {
        title: "Open the world's largest market",
        description:
          "Mandarin is essential for serious work in trade, manufacturing, tech, and finance across Greater China.",
      },
      {
        title: "Unlock 3,000 years of culture",
        description:
          "From the Analects to contemporary cinema, Chinese literature and art reward direct reading.",
      },
      {
        title: "Train your ear and eye",
        description:
          "Tones and characters reshape how you think about language — a serious cognitive workout.",
      },
    ],
    courses: standardCourses(
      "Learn pinyin, the four tones, and your first 100 characters with everyday greetings.",
      "Hold real conversations about food, travel, and family, and read short news items.",
      "Read essays and contemporary fiction, master complex measure words, and write fluently.",
    ),
    related: ["japanese", "korean", "vietnamese"],
  },

  hindi: {
    slug: "hindi",
    name: "Hindi",
    nativeName: "हिन्दी",
    countryCode: "in",
    flagEmoji: "🇮🇳",
    grammar: "Medium",
    pronunciation: "Medium",
    speakers: "600+ million speakers",
    regions: "Northern and central India, Nepal, Fiji, and the South Asian diaspora",
    about:
      "Hindi (हिन्दी) is an Indo-Aryan language descended from Sanskrit and written in the Devanagari script. It shares its colloquial form with Urdu — together they're often called Hindustani — and serves as a lingua franca across much of India.",
    facts: [
      "Devanagari is one of the most phonetically consistent scripts in the world",
      "Hindi and Urdu are mutually intelligible in everyday speech",
      "Bollywood is the world's largest film industry by ticket sales",
    ],
    whyLearn: [
      {
        title: "Speak with 600 million people",
        description:
          "Hindi unlocks daily life across India's economic boom and its globally connected diaspora.",
      },
      {
        title: "A doorway to a continent",
        description:
          "Once you have Hindi, Urdu, Punjabi, Marathi and Nepali become far more approachable.",
      },
      {
        title: "Bollywood, cricket and biryani",
        description:
          "Pop culture in Hindi is loud, joyful, and best appreciated without subtitles.",
      },
    ],
    courses: standardCourses(
      "Learn Devanagari, the basics of gender and word order, and survival greetings.",
      "Talk about your day in past and future tenses, and handle markets, travel and hospitality.",
      "Read modern Hindi literature, follow news bulletins, and write polished essays.",
    ),
    related: ["urdu", "bengali", "english"],
  },

  portuguese: {
    slug: "portuguese",
    name: "Portuguese",
    nativeName: "Português",
    countryCode: "pt",
    flagEmoji: "🇵🇹",
    grammar: "Easy",
    pronunciation: "Medium",
    speakers: "260+ million speakers",
    regions: "Portugal, Brazil, Angola, Mozambique, Cape Verde, and other Lusophone countries",
    about:
      "Portuguese (português) is a Romance language that spread from the Iberian Peninsula across the Atlantic with the Age of Discovery. Brazilian and European varieties differ in accent and vocabulary but remain a single language with a rich literary and musical tradition.",
    facts: [
      "Portuguese is the official language of nine countries across four continents",
      "Brazil holds the largest community of Portuguese speakers by far",
      "Distinctive nasal vowels (ão, em, õe) give Portuguese its musical fingerprint",
    ],
    whyLearn: [
      {
        title: "Reach Brazil and beyond",
        description:
          "Portuguese is your gateway to South America's largest economy and a vibrant African diaspora.",
      },
      {
        title: "An easy Romance bridge",
        description:
          "If you already have Spanish or Italian, Portuguese clicks into place fast.",
      },
      {
        title: "Music, football, and food",
        description:
          "From bossa nova and fado to samba and feijoada, Portuguese culture is a feast.",
      },
    ],
    courses: standardCourses(
      "Get the sounds of Portuguese under your tongue and the survival phrases of a first trip.",
      "Talk about food, family and travel in past tenses, and start reading short articles.",
      "Master the subjunctive, follow Brazilian and Portuguese news, and read fiction unaided.",
    ),
    related: ["spanish", "italian", "french"],
  },

  bengali: {
    slug: "bengali",
    name: "Bengali",
    nativeName: "বাংলা",
    countryCode: "bd",
    flagEmoji: "🇧🇩",
    grammar: "Hard",
    pronunciation: "Medium",
    speakers: "230+ million speakers",
    regions: "Bangladesh, West Bengal (India), and Bengali-speaking communities worldwide",
    about:
      "Bengali (বাংলা, Bangla) is an Indo-Aryan language with a literary heritage anchored by Nobel laureate Rabindranath Tagore. It uses its own elegant script, lacks grammatical gender, and is the seventh-most spoken language on earth.",
    facts: [
      "Rabindranath Tagore was the first non-European Nobel laureate in literature, in 1913",
      "International Mother Language Day (21 February) commemorates Bengali language martyrs",
      "Bengali has no grammatical gender — verbs and adjectives don't change with the noun",
    ],
    whyLearn: [
      {
        title: "Speak with the world's seventh-largest language community",
        description:
          "Bengali is essential for Bangladesh's economy and West Bengal's cultural scene.",
      },
      {
        title: "Read Tagore in the original",
        description:
          "Bengali literature, music and theatre have a depth that's hard to translate.",
      },
      {
        title: "A gentler entry into South Asia",
        description:
          "No grammatical gender and a regular phonetic script make Bengali friendlier than it looks.",
      },
    ],
    courses: standardCourses(
      "Learn the Bengali script, greetings, numbers, and the easy verb endings.",
      "Talk about everyday life, handle the past tenses, and read Tagore-inspired short stories.",
      "Read novels and news fluently, write essays, and discuss culture and politics with nuance.",
    ),
    related: ["hindi", "urdu", "english"],
  },

  urdu: {
    slug: "urdu",
    name: "Urdu",
    nativeName: "اردو",
    countryCode: "pk",
    flagEmoji: "🇵🇰",
    grammar: "Hard",
    pronunciation: "Medium",
    speakers: "230+ million speakers (with Hindi, far more)",
    regions: "Pakistan, India, and the South Asian diaspora",
    about:
      "Urdu (اردو) is the national language of Pakistan and a co-official language of several Indian states. It's structurally Hindi's twin — Hindustani in everyday speech — but written in a beautiful Perso-Arabic script and laced with Persian and Arabic vocabulary.",
    facts: [
      "Urdu is mutually intelligible with Hindi in everyday conversation",
      "It's traditionally the language of South Asian poetry (ghazal, nazm)",
      "Urdu is written right-to-left in a nasta'liq calligraphic style",
    ],
    whyLearn: [
      {
        title: "Two languages for one",
        description:
          "Learn Urdu and you can converse with Hindi speakers as well — that's roughly a billion people.",
      },
      {
        title: "The poetry tradition of South Asia",
        description:
          "Urdu ghazals by Ghalib, Iqbal and Faiz are some of the world's most beloved poetry.",
      },
      {
        title: "Pakistan, near and far",
        description:
          "Urdu is the lingua franca of Pakistan and its global diaspora — from London to Dubai.",
      },
    ],
    courses: standardCourses(
      "Learn the Urdu script and the greetings of everyday Pakistani life.",
      "Discuss food, family, and travel in past tenses, and start reading short stories.",
      "Read poetry, master honorific forms, and write fluent prose for any occasion.",
    ),
    related: ["hindi", "arabic", "bengali"],
  },

  russian: {
    slug: "russian",
    name: "Russian",
    nativeName: "Русский",
    countryCode: "ru",
    flagEmoji: "🇷🇺",
    grammar: "Hard",
    pronunciation: "Medium",
    speakers: "260+ million speakers",
    regions: "Russia, Belarus, Kazakhstan, and Russian-speaking communities in the Baltics and Eastern Europe",
    about:
      "Russian (русский язык) is an East Slavic language written in Cyrillic, the script adapted from Greek by missionaries in the 9th century. Its six cases and rich verbal aspect give it remarkable expressive precision — and a literary tradition that needs no introduction.",
    facts: [
      "Russian has six grammatical cases and two verbal aspects (perfective and imperfective)",
      "The Cyrillic alphabet was adapted from Greek by Saints Cyril and Methodius",
      "Russian space exploration, sciences and mathematics produced a vast technical vocabulary",
    ],
    whyLearn: [
      {
        title: "Read Dostoevsky in the original",
        description:
          "Russian literature loses something in translation — Tolstoy, Bulgakov and Akhmatova reward the patient.",
      },
      {
        title: "Engineering and sciences",
        description:
          "Russian is one of the world's great languages of mathematics, physics and aerospace.",
      },
      {
        title: "Gateway to Slavic",
        description:
          "With Russian under your belt, Ukrainian, Polish and Czech become much more approachable.",
      },
    ],
    courses: standardCourses(
      "Learn the Cyrillic alphabet, the basic noun cases, and the friendliest greetings.",
      "Speak about your day in past and future tenses, and read children's books unaided.",
      "Read newspapers and short fiction, handle perfective and imperfective with ease, and debate fluently.",
    ),
    related: ["english", "german", "greek"],
  },

  japanese: {
    slug: "japanese",
    name: "Japanese",
    nativeName: "日本語",
    countryCode: "jp",
    flagEmoji: "🇯🇵",
    grammar: "Hard",
    pronunciation: "Hard",
    speakers: "125+ million speakers",
    regions: "Japan, and small Japanese-speaking communities in Brazil, Peru, and the United States",
    about:
      "Japanese (日本語, Nihongo) is a language isolate (or part of a tiny Japonic family with Ryukyuan). It uses three writing systems together — hiragana, katakana, and the Chinese-derived kanji — and a politeness system that encodes social relationships into the verbs themselves.",
    facts: [
      "Japanese uses three scripts at once: hiragana, katakana, and kanji",
      "Politeness levels (keigo) change the entire shape of verbs and sentences",
      "Subject-Object-Verb word order — the verb almost always comes last",
    ],
    whyLearn: [
      {
        title: "Anime, manga, and video games — at the source",
        description:
          "A vast pop-culture catalogue is available in Japanese long before it's translated.",
      },
      {
        title: "Tech, design, and craftsmanship",
        description:
          "From Sony and Nintendo to Muji and shokunin traditions, Japanese culture is meticulously crafted.",
      },
      {
        title: "A truly different worldview",
        description:
          "Japanese grammar and politeness rewire how you think about social interaction.",
      },
    ],
    courses: standardCourses(
      "Master hiragana and katakana, the polite forms, and your first 100 kanji.",
      "Handle daily life politely, switch between casual and formal speech, and start reading manga.",
      "Read novels, business emails, and editorials; master keigo and the full kanji set.",
    ),
    related: ["korean", "chinese", "english"],
  },

  turkish: {
    slug: "turkish",
    name: "Turkish",
    nativeName: "Türkçe",
    countryCode: "tr",
    flagEmoji: "🇹🇷",
    grammar: "Medium",
    pronunciation: "Medium",
    speakers: "80+ million speakers",
    regions: "Turkey, Cyprus, and Turkish-speaking communities in the Balkans, Germany, and Central Asia",
    about:
      "Turkish (Türkçe) is a Turkic language that switched to the Latin alphabet in 1928 as part of Atatürk's language reforms. It's famously agglutinative — you can build long, precise words by stacking suffixes — and uses vowel harmony to keep them flowing.",
    facts: [
      "Vowel harmony keeps vowels within a single word in the same front/back family",
      "Turkish switched from Arabic to Latin script in 1928",
      "Agglutination lets one word like \"evlerinizden\" express \"from your houses\"",
    ],
    whyLearn: [
      {
        title: "Sit at the crossroads of Europe and Asia",
        description:
          "Turkish opens up Istanbul, Anatolia, and the wider Turkic-speaking world.",
      },
      {
        title: "An efficient grammar machine",
        description:
          "Once vowel harmony and agglutination click, Turkish is remarkably regular and expressive.",
      },
      {
        title: "A bridge to the Turkic world",
        description:
          "Turkish makes Azerbaijani, Turkmen, and Uzbek surprisingly approachable.",
      },
    ],
    courses: standardCourses(
      "Get the sounds of Turkish vowels, the friendliest greetings, and your first verbs.",
      "Handle markets and travel, master the past tense, and start reading short news items.",
      "Read literature and editorials, master the evidential mood, and write fluent essays.",
    ),
    related: ["greek", "albanian", "english"],
  },

  vietnamese: {
    slug: "vietnamese",
    name: "Vietnamese",
    nativeName: "Tiếng Việt",
    countryCode: "vn",
    flagEmoji: "🇻🇳",
    grammar: "Hard",
    pronunciation: "Hard",
    speakers: "85+ million speakers",
    regions: "Vietnam, with significant diaspora communities in the United States, France, and Australia",
    about:
      "Vietnamese (Tiếng Việt) is an Austroasiatic language with six tones and a uniquely diacritic-rich Latin script — quốc ngữ — that replaced earlier Chinese-character writing in the 20th century. Its tones are demanding, but its grammar is among the world's simplest: no verb conjugation, no gender, no articles.",
    facts: [
      "Six pitch tones make pronunciation the central challenge — and the music",
      "Quốc ngữ uses Latin letters with extensive diacritic marks",
      "No verb tenses or conjugations — time is shown with small marker words",
    ],
    whyLearn: [
      {
        title: "Vietnam's fast-growing economy",
        description:
          "Vietnamese is an asset in manufacturing, technology, and tourism across Southeast Asia.",
      },
      {
        title: "A wonderful food culture",
        description:
          "Phở, bún chả, bánh mì — the menu opens up properly once you can ask in Vietnamese.",
      },
      {
        title: "Simple grammar, rich tones",
        description:
          "Once tones click, Vietnamese grammar is one of the most economical you'll meet.",
      },
    ],
    courses: standardCourses(
      "Learn the six tones, the everyday greetings, and the first 200 essential words.",
      "Talk about food, travel and family with confidence, and read short news items.",
      "Read literature and editorials, master regional differences, and write fluent essays.",
    ),
    related: ["chinese", "korean", "english"],
  },

  arabic: {
    slug: "arabic",
    name: "Arabic",
    nativeName: "العربية",
    countryCode: "sa",
    flagEmoji: "🇸🇦",
    grammar: "Hard",
    pronunciation: "Hard",
    speakers: "380+ million native speakers (Modern Standard Arabic plus dialects)",
    regions: "Across 22 countries from Morocco to Oman, plus large communities worldwide",
    about:
      "Arabic (العربية) is a Central Semitic language whose written standard — Modern Standard Arabic (MSA) — is based on the classical Arabic of the Qur'an. Spoken dialects vary widely from Morocco to Iraq, but MSA is the language of news, books, and formal occasions everywhere.",
    facts: [
      "Arabic is written right-to-left in a flowing cursive script",
      "A three-consonant root system generates families of related words",
      "Modern Standard Arabic and regional dialects often differ as much as related languages",
    ],
    whyLearn: [
      {
        title: "22 countries open up",
        description:
          "Arabic is the language of business, news and culture across the Middle East and North Africa.",
      },
      {
        title: "The world's most beautiful script",
        description:
          "Calligraphy turns Arabic writing into an art form all by itself.",
      },
      {
        title: "Read the classics in the original",
        description:
          "The Qur'an, One Thousand and One Nights, and Naguib Mahfouz all started in Arabic.",
      },
    ],
    courses: standardCourses(
      "Learn the script, the sounds of the throat consonants, and the friendliest greetings.",
      "Hold daily-life conversations, handle the past and present, and read short news items.",
      "Read editorials and literature, navigate dialects, and write polished formal Arabic.",
    ),
    related: ["urdu", "greek", "english"],
  },

  korean: {
    slug: "korean",
    name: "Korean",
    nativeName: "한국어",
    countryCode: "kr",
    flagEmoji: "🇰🇷",
    grammar: "Hard",
    pronunciation: "Medium",
    speakers: "80+ million speakers",
    regions: "South Korea, North Korea, and Korean-speaking communities worldwide",
    about:
      "Korean (한국어) is a language isolate (or part of the small Koreanic family) written in Hangul — an alphabet so well designed that King Sejong's court could promote literacy across the kingdom in the 15th century. Modern Korean has a sophisticated honorific system woven into its verbs.",
    facts: [
      "Hangul was invented in 1443 — most alphabets evolved over centuries; this one was designed",
      "Subject-Object-Verb word order, like Japanese",
      "Honorifics, casual speech, and formal speech each have distinct verb endings",
    ],
    whyLearn: [
      {
        title: "K-pop, K-drama, and beyond",
        description:
          "Korean pop culture has become one of the world's most influential — and most fun in the original.",
      },
      {
        title: "Tech and design powerhouse",
        description:
          "Samsung, LG, Hyundai, gaming, semiconductors — Korean opens doors in serious industries.",
      },
      {
        title: "The world's most logical alphabet",
        description:
          "Hangul is famously learnable in a single weekend — the writing system itself is the welcome mat.",
      },
    ],
    courses: standardCourses(
      "Master Hangul over a weekend and tackle the friendliest greetings of Seoul cafés.",
      "Handle daily life politely, switch between casual and formal speech, and read short stories.",
      "Read novels and news, master the honorific system, and write fluent business Korean.",
    ),
    related: ["japanese", "chinese", "english"],
  },

  italian: {
    slug: "italian",
    name: "Italian",
    nativeName: "Italiano",
    countryCode: "it",
    flagEmoji: "🇮🇹",
    grammar: "Easy",
    pronunciation: "Easy",
    speakers: "65+ million speakers",
    regions: "Italy, San Marino, Vatican City, Switzerland (Ticino), and Italian diaspora communities",
    about:
      "Italian (italiano) is the Romance language closest to its Latin parent among the major Romance languages. It's the language of opera, of pasta, of the Renaissance — and one of the most rewarding to speak out loud because of its musical, vowel-rich phonology.",
    facts: [
      "Italian is the closest major Romance language to Vulgar Latin",
      "Almost every Italian word ends in a vowel, which makes speech famously melodic",
      "Standard Italian is based on the Tuscan dialect of Dante",
    ],
    whyLearn: [
      {
        title: "Italy, fully experienced",
        description:
          "From Roman ruins to Sicilian markets, Italian unlocks the country a tourist never quite reaches.",
      },
      {
        title: "Music, food and art",
        description:
          "Opera, cinema, the cuisine and the world's deepest art history are all easier in Italian.",
      },
      {
        title: "A bridge to other Romance languages",
        description:
          "Italian's regularity makes Spanish, Portuguese, and Corsican fall into place quickly.",
      },
    ],
    courses: standardCourses(
      "Learn the vowel-bright sounds, friendly greetings, and the easy regular verbs.",
      "Hold real conversations about food, family and travel; tackle past and future tenses.",
      "Read Calvino and Ferrante in the original, master the subjunctive, and write fluently.",
    ),
    related: ["spanish", "french", "corsican"],
  },

  malay: {
    slug: "malay",
    name: "Malay",
    nativeName: "Bahasa Melayu",
    countryCode: "my",
    flagEmoji: "🇲🇾",
    grammar: "Easy",
    pronunciation: "Easy",
    speakers: "200+ million speakers (with Indonesian, mutually intelligible)",
    regions: "Malaysia, Brunei, Singapore, and parts of southern Thailand and the Philippines",
    about:
      "Malay (Bahasa Melayu) is an Austronesian language and a regional lingua franca across maritime Southeast Asia. Written in Latin script (Rumi) since the 19th century — and historically in the Jawi Arabic-derived script — Malay has famously friendly grammar with no verb conjugation, no gender, and no tones.",
    facts: [
      "No tones, no verb conjugations, no grammatical gender",
      "Malay is the third Austronesian language by speakers, after Indonesian and Tagalog",
      "Jawi, the Arabic-derived script, is still used for religious and ceremonial texts",
    ],
    whyLearn: [
      {
        title: "Southeast Asia's regional language",
        description:
          "Malay reaches across Malaysia, Singapore, Brunei, and parts of southern Thailand.",
      },
      {
        title: "One of the gentlest grammars in the world",
        description:
          "No tones, no conjugations, no gender — Malay is forgiving and fast to make progress in.",
      },
      {
        title: "Two languages for the price of one",
        description:
          "Malay and Indonesian are mutually intelligible at the everyday level — learn one, follow both.",
      },
    ],
    courses: standardCourses(
      "Get comfortable with Malay sounds, the survival phrases, and the easy verbal markers.",
      "Hold real conversations about food and travel, and start reading short news pieces.",
      "Read literature and editorials, handle formal Malay, and write polished essays.",
    ),
    related: ["indonesian", "english", "vietnamese"],
  },

  indonesian: {
    slug: "indonesian",
    name: "Indonesian",
    nativeName: "Bahasa Indonesia",
    countryCode: "id",
    flagEmoji: "🇮🇩",
    grammar: "Easy",
    pronunciation: "Easy",
    speakers: "200+ million speakers (with Malay, mutually intelligible)",
    regions: "Indonesia — the world's largest island nation",
    about:
      "Indonesian (Bahasa Indonesia) is the standardized register of Malay and the national language of Indonesia — the fourth most populous country on earth. Famously easy to start (no tones, no conjugations, no gender), it remains a giant of Southeast Asia and a friendly entry point to the Austronesian family.",
    facts: [
      "Indonesia is the world's largest island nation — over 17,000 islands",
      "Indonesian and Malay are mutually intelligible everyday languages",
      "Plural is shown by simply repeating the noun (orang \"person\" → orang-orang \"people\")",
    ],
    whyLearn: [
      {
        title: "A giant economy and culture",
        description:
          "Indonesia is the world's fourth most populous country and the largest economy in Southeast Asia.",
      },
      {
        title: "Famously beginner-friendly",
        description:
          "No tones, no conjugations, no gender — Indonesian gives quick wins from day one.",
      },
      {
        title: "Travel a country of 17,000 islands",
        description:
          "From Bali to Sumatra, Indonesian opens up a country tourists rarely see in depth.",
      },
    ],
    courses: standardCourses(
      "Master the friendly Indonesian sounds, the survival phrases, and the everyday verbs.",
      "Hold real conversations about food, family, and travel, and start reading short news pieces.",
      "Read literature and editorials, handle formal registers, and write polished essays.",
    ),
    related: ["malay", "english", "vietnamese"],
  },
};

export function getOverview(slug: string): LanguageOverview | null {
  return languageOverviews[slug] ?? null;
}

export function getAllOverviewSlugs(): string[] {
  return Object.keys(languageOverviews);
}

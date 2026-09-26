// ============================================================
// traveler-preview.ts
//
// Hand-authored content for the new Madrid lesson experience.
// Powers /preview/madrid/[lesson] — read-only, no DB, no auth.
// If we like the shape here, this becomes the JSON emitted by the
// generator script and stored on traveler_lesson_content.data.
// ============================================================

export type OpeningImage = {
  kind: "image";
  imageUrl: string;
  imageAlt: string;
  fullSignText: string;
};

export type AudioLine = {
  speaker: string;
  gender?: "male" | "female";
  text: string;
  pauseAfterMs?: number;
};

export type OpeningAudio = {
  kind: "audio";
  script: AudioLine[];
  durationHint: string;
};

export type GatedExercise =
  | {
      kind: "multiple_choice";
      question: string;
      correct: string;
      wrong: string[];
    }
  | {
      kind: "tap_word";
      prompt: string;
      correct: string;
      distractors: string[];
    }
  | {
      kind: "speaking";
      prompt: string;
      expected: string;
      translation: string;
    }
  | {
      kind: "fill_blank";
      prompt: string;
      correct: string;
      hint?: string;
    };

export type DecodeStep = {
  wordOrPhrase: string;
  phonetic: string;
  english: string;
  mnemonic: string;
  culturalNote?: string;
  audioSnippet?: string;
  gatedExercise: GatedExercise;
};

export type EndQuizQuestion =
  | {
      kind: "multiple_choice";
      question: string;
      correct: string;
      wrong: string[];
    }
  | { kind: "fill_blank"; prompt: string; correct: string; hint?: string }
  | {
      kind: "listening";
      audio: string;
      question: string;
      correct: string;
      wrong: string[];
    }
  | {
      kind: "speaking";
      prompt: string;
      expected: string;
      translation: string;
    };

export type PreviewLesson = {
  id: number;
  orderIndex: number;
  title: string;
  location: string;
  city: string;
  country: string;
  lessonType: "sign" | "menu" | "audio_announcement" | "overheard" | "document" | "advertisement";
  medium: "image" | "audio";
  scene: string;
  opening: OpeningImage | OpeningAudio;
  decodeSteps: DecodeStep[];
  buildup: {
    fullEnglish: string;
    celebrationMessage: string;
  };
  endQuiz: EndQuizQuestion[];
  xpReward: number;
  nextLesson?: { id: number; title: string; location: string; isPremium: boolean };
};

// ============================================================
// Lesson 1 — Airport Arrivals (image / sign decoding)
// ============================================================

const lesson1: PreviewLesson = {
  id: 1,
  orderIndex: 1,
  title: "Airport Arrivals",
  location: "Madrid-Barajas Airport, Terminal 4",
  city: "Madrid",
  country: "Spain",
  lessonType: "sign",
  medium: "image",
  scene:
    "You just landed at Madrid-Barajas Airport, Terminal 4. You follow the crowd down a long corridor and look up. You see this sign.",
  opening: {
    kind: "image",
    imageUrl: "/preview/madrid-l1-arrivals.jpg",
    imageAlt:
      "Photorealistic overhead airport sign in Madrid-Barajas Terminal 4, dark blue background with white text reading LLEGADAS INTERNACIONALES, CONTROL DE PASAPORTES, RECOGIDA DE EQUIPAJES, SALIDA with directional arrows.",
    fullSignText:
      "LLEGADAS INTERNACIONALES  ·  CONTROL DE PASAPORTES  ·  RECOGIDA DE EQUIPAJES  ·  SALIDA",
  },
  decodeSteps: [
    {
      wordOrPhrase: "LLEGADAS",
      phonetic: "[yeh-GAH-dahs]",
      english: "arrivals",
      mnemonic:
        "LLEGADAS sounds like ‘yeh-gathers’ — picture a crowd gathering after they arrive.",
      culturalNote:
        "Every Spanish airport pairs LLEGADAS (arrivals) with SALIDAS (departures). If you see SALIDAS you're on the wrong floor.",
      gatedExercise: {
        kind: "multiple_choice",
        question: "What does LLEGADAS mean?",
        correct: "Arrivals",
        wrong: ["Departures", "Gates", "Delays"],
      },
    },
    {
      wordOrPhrase: "INTERNACIONALES",
      phonetic: "[een-ter-nah-syoh-NAH-lays]",
      english: "international",
      mnemonic:
        "Same word as English — just the Spanish -ES plural ending. Trust the cognate.",
      gatedExercise: {
        kind: "tap_word",
        prompt: "Tap the word that means ‘international’.",
        correct: "INTERNACIONALES",
        distractors: ["NACIONALES", "REGIONALES", "PERSONALES"],
      },
    },
    {
      wordOrPhrase: "CONTROL DE PASAPORTES",
      phonetic: "[kohn-TROHL deh pah-sah-POR-tess]",
      english: "passport control",
      mnemonic:
        "CONTROL = control. PASAPORTES = passports. Almost identical to English — the only trick is stress on the second-to-last syllable.",
      culturalNote:
        "Non-EU travelers queue at ‘Todos Pasaportes’. EU passport holders can use the automated eGates.",
      gatedExercise: {
        kind: "speaking",
        prompt: "Say it aloud.",
        expected: "control de pasaportes",
        translation: "passport control",
      },
    },
    {
      wordOrPhrase: "RECOGIDA DE EQUIPAJES",
      phonetic: "[ray-koh-HEE-dah deh eh-kee-PAH-hess]",
      english: "baggage claim",
      mnemonic:
        "RECOGIDA = pick-up (from recoger, to collect). EQUIPAJES = luggage — think ‘equipment’ you travel with.",
      culturalNote:
        "The belt number is announced overhead and on the flight-info displays — look for your flight code (e.g. ‘IB6252’).",
      gatedExercise: {
        kind: "multiple_choice",
        question: "Which of these means ‘baggage claim’?",
        correct: "RECOGIDA DE EQUIPAJES",
        wrong: ["SALA DE EMBARQUE", "PUERTA DE SALIDA", "FACTURACIÓN"],
      },
    },
    {
      wordOrPhrase: "SALIDA",
      phonetic: "[sah-LEE-dah]",
      english: "exit / way out",
      mnemonic:
        "SALIDA — think ‘sally forth’, to go out. SALIDA = exit.",
      culturalNote:
        "In Madrid metros and airports, SALIDA signs are green (like an EU emergency-exit sign). Follow the green arrow.",
      gatedExercise: {
        kind: "speaking",
        prompt: "Say it aloud.",
        expected: "salida",
        translation: "exit",
      },
    },
  ],
  buildup: {
    fullEnglish:
      "International Arrivals  ·  Passport Control  ·  Baggage Claim  ·  Exit",
    celebrationMessage:
      "You just read a Spanish airport sign without a translator. That's the whole game.",
  },
  endQuiz: [
    {
      kind: "multiple_choice",
      question: "What does SALIDA mean?",
      correct: "Exit",
      wrong: ["Entrance", "Baggage claim", "Passport"],
    },
    {
      kind: "fill_blank",
      prompt: "Passport control is CONTROL DE ______",
      correct: "PASAPORTES",
      hint: "Same word as English, plural.",
    },
    {
      kind: "listening",
      audio: "LLEGADAS",
      question: "You just heard the announcer say this word. What does it mean?",
      correct: "Arrivals",
      wrong: ["Departures", "Delays", "Gate change"],
    },
    {
      kind: "multiple_choice",
      question: "Which sign points to baggage claim?",
      correct: "RECOGIDA DE EQUIPAJES",
      wrong: ["LLEGADAS", "SALIDA", "CONTROL DE PASAPORTES"],
    },
    {
      kind: "speaking",
      prompt: "Say the word for ‘exit’.",
      expected: "salida",
      translation: "exit",
    },
  ],
  xpReward: 20,
  nextLesson: {
    id: 2,
    title: "The Passport Officer",
    location: "Immigration Hall",
    isPremium: false,
  },
};

// ============================================================
// Lesson 3 — Taxi to the City (audio / overheard conversation)
// ============================================================

const lesson3: PreviewLesson = {
  id: 3,
  orderIndex: 3,
  title: "The Taxi to Puerta del Sol",
  location: "Airport Taxi Rank, Madrid-Barajas",
  city: "Madrid",
  country: "Spain",
  lessonType: "overheard",
  medium: "audio",
  scene:
    "You slide into the back of a white-and-red Madrid taxi. You need to get to Puerta del Sol. The driver turns around. Listen — no transcript.",
  opening: {
    kind: "audio",
    durationHint: "~18 seconds",
    script: [
      {
        speaker: "Driver",
        gender: "male",
        text: "Hola, buenas tardes. ¿A dónde le llevo?",
        pauseAfterMs: 1400,
      },
      {
        speaker: "Driver",
        gender: "male",
        text: "Muy bien, a la Puerta del Sol. Son treinta euros con la tarifa fija. ¿Le parece?",
        pauseAfterMs: 1400,
      },
      {
        speaker: "Driver",
        gender: "male",
        text: "¿Primera vez en Madrid?",
      },
    ],
  },
  decodeSteps: [
    {
      wordOrPhrase: "Hola, buenas tardes",
      phonetic: "[OH-lah BWEH-nahs TAR-dess]",
      english: "Hello, good afternoon",
      mnemonic:
        "BUENAS = ‘goods’. TARDES = ‘tardy / late’. Together: the good late-part of the day.",
      culturalNote:
        "‘Buenas tardes’ kicks in around 2pm after lunch. Before that it's ‘buenos días’. After sunset, ‘buenas noches’.",
      audioSnippet: "Hola, buenas tardes.",
      gatedExercise: {
        kind: "multiple_choice",
        question: "What did the driver just say?",
        correct: "Hello, good afternoon",
        wrong: ["Hello, good morning", "Welcome, good evening", "Goodbye, safe travels"],
      },
    },
    {
      wordOrPhrase: "¿A dónde le llevo?",
      phonetic: "[ah DOHN-deh leh YEH-voh]",
      english: "Where can I take you?",
      mnemonic:
        "DÓNDE = where. LLEVO = ‘I carry’ (from llevar). Literally: ‘Where do I carry you?’",
      culturalNote:
        "The formal ‘le’ (not ‘te’) is standard taxi register. Answer with ‘A…’ then your destination: ‘A la Puerta del Sol’.",
      audioSnippet: "¿A dónde le llevo?",
      gatedExercise: {
        kind: "tap_word",
        prompt: "Tap the word that means ‘where’.",
        correct: "DÓNDE",
        distractors: ["CUÁNDO", "CÓMO", "QUIÉN"],
      },
    },
    {
      wordOrPhrase: "Muy bien",
      phonetic: "[mwee bee-EHN]",
      english: "Very well / Alright",
      mnemonic:
        "MUY = ‘mwee’ (very). BIEN = ‘bee-en’ (well). Two syllables, one of the most useful phrases in Spanish.",
      audioSnippet: "Muy bien.",
      gatedExercise: {
        kind: "speaking",
        prompt: "Say it aloud.",
        expected: "muy bien",
        translation: "very well / alright",
      },
    },
    {
      wordOrPhrase: "treinta euros",
      phonetic: "[TRAYN-tah EH-oo-rohs]",
      english: "thirty euros",
      mnemonic:
        "TREINTA rhymes with ‘pinta’. Think ‘pay a treinta for a pinta’. EUROS = euros.",
      culturalNote:
        "Since 2014 Madrid has a fixed €30 rate between Barajas Airport and central Madrid inside the M-30 ring — including Puerta del Sol.",
      audioSnippet: "Son treinta euros.",
      gatedExercise: {
        kind: "multiple_choice",
        question: "How much did the driver quote?",
        correct: "30 euros",
        wrong: ["13 euros", "40 euros", "It depends on the meter"],
      },
    },
    {
      wordOrPhrase: "tarifa fija",
      phonetic: "[tah-REE-fah FEE-hah]",
      english: "fixed rate",
      mnemonic:
        "TARIFA = tariff / fare. FIJA = fixed (think ‘affix’). Fare that's affixed.",
      culturalNote:
        "Always confirm ‘tarifa fija’ at the start of an airport ride — otherwise some drivers may try to run the meter.",
      audioSnippet: "con la tarifa fija",
      gatedExercise: {
        kind: "tap_word",
        prompt: "Tap the word that means ‘fixed’.",
        correct: "FIJA",
        distractors: ["FÁCIL", "FUERTE", "FRESCA"],
      },
    },
    {
      wordOrPhrase: "¿Primera vez en Madrid?",
      phonetic: "[pree-MEH-rah beth ehn mah-DREED]",
      english: "First time in Madrid?",
      mnemonic:
        "PRIMERA = primary / first. VEZ = time / occasion (as in ‘a vez, twice, thrice’).",
      audioSnippet: "¿Primera vez en Madrid?",
      gatedExercise: {
        kind: "speaking",
        prompt: "Answer him. Say: ‘Sí, primera vez’.",
        expected: "sí primera vez",
        translation: "Yes, first time.",
      },
    },
  ],
  buildup: {
    fullEnglish:
      "“Hello, good afternoon. Where can I take you?” … “Very well — to Puerta del Sol. That's thirty euros with the fixed rate. Sound good?” … “First time in Madrid?”",
    celebrationMessage:
      "You just followed a full Spanish taxi conversation by ear. Reset the audio and try it once more with no help.",
  },
  endQuiz: [
    {
      kind: "multiple_choice",
      question: "What does ‘tarifa fija’ mean?",
      correct: "Fixed rate",
      wrong: ["Meter running", "Discount", "Cash only"],
    },
    {
      kind: "listening",
      audio: "Buenas tardes.",
      question: "You just heard this. What does it mean?",
      correct: "Good afternoon",
      wrong: ["Good morning", "Good night", "Goodbye"],
    },
    {
      kind: "fill_blank",
      prompt: "Complete: ‘¿Primera ______ en Madrid?’",
      correct: "vez",
      hint: "Means ‘time’ or ‘occasion’.",
    },
    {
      kind: "multiple_choice",
      question: "How much is the airport-to-Sol taxi with the fixed rate?",
      correct: "€30",
      wrong: ["€13", "€45", "It varies by traffic"],
    },
    {
      kind: "speaking",
      prompt: "Say ‘Very well’ in Spanish.",
      expected: "muy bien",
      translation: "very well",
    },
  ],
  xpReward: 25,
  nextLesson: {
    id: 4,
    title: "Checking Into the Hotel",
    location: "Hotel reception, Gran Vía",
    isPremium: false,
  },
};

// ============================================================
// Public API
// ============================================================

const LESSONS: Record<number, PreviewLesson> = {
  1: lesson1,
  3: lesson3,
};

export function getPreviewLesson(id: number): PreviewLesson | null {
  return LESSONS[id] ?? null;
}

export function listPreviewLessons(): PreviewLesson[] {
  return Object.values(LESSONS).sort((a, b) => a.orderIndex - b.orderIndex);
}

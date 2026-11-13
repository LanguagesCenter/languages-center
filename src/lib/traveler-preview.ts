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
  // Provenance of the image: "streetview" means a Google Street View
  // Static capture of the real location (badged in the UI);
  // "unsplash" means a stock photo matched to the scenario.
  imageSource?: "streetview" | "unsplash";
};

// A highlight region overlaid on the image during a decode step. For
// Street View / Unsplash photos the exact text pixel coordinates are
// usually unknown, so the generator prefers the "caption" fallback:
// a strip rendered below the image reproducing the sign text in the
// original Spanish, with the current word highlighted.
//
// - kind="region": a box overlay in normalized (0..1) coordinates
//   relative to the image frame. x/y point to the top-left corner.
// - kind="caption": a caption strip below the image showing
//   `fullText`, with `highlightWord` wrapped in a glowing span.
export type DecodeHighlight =
  | {
      kind: "region";
      x: number;
      y: number;
      width: number;
      height: number;
      // The verbatim Spanish text inside the region. Also rendered in
      // the caption strip as a safety net (not every browser's Image
      // layout exactly matches the authored pixel coords).
      text: string;
    }
  | {
      kind: "caption";
      fullText: string;
      highlightWord: string;
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

// Translation-check follow-up appended to every speaking exercise.
// After the learner speaks (or taps "I can't speak now"), the runner
// shows this as a second question with 4 English options so the
// learner has to prove they also know what the phrase means. Also
// used on the Speaking Practice page.
export type TranslationCheck = {
  options: string[];        // 4 English strings
  correctIndex: number;     // index into options
  explanation: string;      // 1-2 sentences revealed after answering
};

// Every exercise now carries an `explanation` field — a 1-2 sentence
// note revealed after the learner answers. For a correct answer it
// reinforces the hint chain; for an incorrect answer it names the
// right choice and ties it back to the image / hints so the learner
// understands WHY. Optional on legacy content; required by the new
// generator.
export type GatedExercise =
  | {
      kind: "multiple_choice";
      question: string;
      correct: string;
      wrong: string[];
      explanation?: string;
    }
  | {
      kind: "tap_word";
      prompt: string;
      correct: string;
      distractors: string[];
      explanation?: string;
    }
  | {
      kind: "speaking";
      prompt: string;
      expected: string;
      // The meaning of the expected phrase. Kept on speaking
      // exercises because the learner cannot answer without knowing
      // what to say — it's not a "guess the translation" moment.
      translation: string;
      explanation?: string;
      // Required by the new generator (optional for legacy content).
      // Runner shows this as a second question after the speaking
      // attempt so the learner proves they ALSO know the meaning.
      translationCheck?: TranslationCheck;
    }
  | {
      kind: "fill_blank";
      prompt: string;
      correct: string;
      hint?: string;
      explanation?: string;
    };

export type DecodeStep = {
  wordOrPhrase: string;
  phonetic: string;
  // English translation. The new runner does NOT render this during
  // the decode step — the meaning is withheld until the end-of-lesson
  // quiz / buildup reveal. Kept on the data structure because the
  // quiz, feedback explanations, and legacy renderers need it.
  english: string;
  // Legacy single-string tip. Still populated by the generator for
  // backward compat, but the new runner reads `hints[]` instead.
  mnemonic: string;
  // Second legacy tip bucket — folded into `hints[]` on the new path.
  culturalNote?: string;
  // Up to 3 progressive hints the learner uncovers one at a time by
  // tapping Continue. The LAST Continue advances from hints → the
  // step's gated exercise. The new generator MUST emit this array
  // without ever including the English translation of the word.
  hints?: string[];
  // Highlights the word being decoded on the opening image or audio
  // player. For audio, use `audioSnippet` + the pulsing waveform
  // segment; for images, use this `highlight` shape.
  highlight?: DecodeHighlight;
  audioSnippet?: string;
  gatedExercise: GatedExercise;
};

export type EndQuizQuestion =
  | {
      kind: "multiple_choice";
      question: string;
      correct: string;
      wrong: string[];
      explanation?: string;
    }
  | {
      kind: "fill_blank";
      prompt: string;
      correct: string;
      hint?: string;
      explanation?: string;
    }
  | {
      kind: "listening";
      audio: string;
      question: string;
      correct: string;
      wrong: string[];
      explanation?: string;
    }
  | {
      kind: "speaking";
      prompt: string;
      expected: string;
      translation: string;
      explanation?: string;
      translationCheck?: TranslationCheck;
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
      highlight: {
        kind: "caption",
        fullText:
          "LLEGADAS INTERNACIONALES · CONTROL DE PASAPORTES · RECOGIDA DE EQUIPAJES · SALIDA",
        highlightWord: "LLEGADAS",
      },
      hints: [
        "Say it: yeh-GAH-dahs. Comes from llegar — related to ‘allegiance’ and ‘legate’ in English, both from Latin ligare, to bind / arrive at.",
        "This sign is overhead immediately after you leave the plane. Think about what that first word has to describe: everyone around you just did it.",
        "It pairs with SALIDAS (going out). One tells you what just happened to you, one tells you what the people on the other side of the building are about to do.",
      ],
      gatedExercise: {
        kind: "multiple_choice",
        question: "LLEGADAS — what does this word on the sign mean?",
        correct: "Arrivals",
        wrong: ["Departures", "Baggage claim", "Passport control"],
        explanation:
          "LLEGADAS = ARRIVALS. The word is from llegar (to arrive). SALIDAS on the other side of the terminal is Departures.",
      },
    },
    {
      wordOrPhrase: "INTERNACIONALES",
      phonetic: "[een-ter-nah-syoh-NAH-lays]",
      english: "international",
      mnemonic:
        "Same word as English — just the Spanish -ES plural ending. Trust the cognate.",
      highlight: {
        kind: "caption",
        fullText:
          "LLEGADAS INTERNACIONALES · CONTROL DE PASAPORTES · RECOGIDA DE EQUIPAJES · SALIDA",
        highlightWord: "INTERNACIONALES",
      },
      hints: [
        "This is one of those words that's almost spelled the same in English — just rearrange the ending.",
        "The -ES on the end is Spanish plural. Drop it and you've got a word you use every day.",
      ],
      gatedExercise: {
        kind: "multiple_choice",
        question: "INTERNACIONALES — what does this word tell you about your arrivals hall?",
        correct: "This hall is for international flights",
        wrong: [
          "This hall is for domestic flights only",
          "This hall is temporarily closed",
          "This hall is for crew members",
        ],
        explanation:
          "INTERNACIONALES = INTERNATIONAL (plural). The -ES ending is Spanish plural; drop it and you get the English word.",
      },
    },
    {
      wordOrPhrase: "CONTROL DE PASAPORTES",
      phonetic: "[kohn-TROHL deh pah-sah-POR-tess]",
      english: "passport control",
      mnemonic:
        "CONTROL = control. PASAPORTES = passports. Almost identical to English — the only trick is stress on the second-to-last syllable.",
      highlight: {
        kind: "caption",
        fullText:
          "LLEGADAS INTERNACIONALES · CONTROL DE PASAPORTES · RECOGIDA DE EQUIPAJES · SALIDA",
        highlightWord: "CONTROL DE PASAPORTES",
      },
      hints: [
        "Say it: kohn-TROHL deh pah-sah-POR-tess. Both halves are near-identical to their English cognates.",
        "‘DE’ in Spanish connects two nouns and means ‘of’ — like ‘Casa de Juan’ (Juan’s house). So this is ‘control OF ______’.",
        "You're about to show your blue or burgundy booklet to an officer. What's this checkpoint for?",
      ],
      gatedExercise: {
        kind: "speaking",
        prompt: "Say it aloud.",
        expected: "control de pasaportes",
        translation: "passport control",
        explanation:
          "CONTROL DE PASAPORTES = PASSPORT CONTROL. Stress lands on the second-to-last syllable in both halves (konTROL · pasaPORtes).",
        translationCheck: {
          options: [
            "Passport control",
            "Passport renewal office",
            "Lost and found",
            "Customs declaration",
          ],
          correctIndex: 0,
          explanation:
            "CONTROL DE PASAPORTES is where an officer checks your passport before you enter the country.",
        },
      },
    },
    {
      wordOrPhrase: "RECOGIDA DE EQUIPAJES",
      phonetic: "[ray-koh-HEE-dah deh eh-kee-PAH-hess]",
      english: "baggage claim",
      mnemonic:
        "RECOGIDA = pick-up (from recoger, to collect). EQUIPAJES = luggage — think ‘equipment’ you travel with.",
      highlight: {
        kind: "caption",
        fullText:
          "LLEGADAS INTERNACIONALES · CONTROL DE PASAPORTES · RECOGIDA DE EQUIPAJES · SALIDA",
        highlightWord: "RECOGIDA DE EQUIPAJES",
      },
      hints: [
        "RECOGIDA comes from recoger — ‘to collect, pick up’. Think ‘recollect’.",
        "EQUIPAJES is close to the English word for travel gear — what you bring with you.",
        "After passport control, every traveler heads to the same place. What are they going to pick up?",
      ],
      gatedExercise: {
        kind: "multiple_choice",
        question: "RECOGIDA DE EQUIPAJES — what does this sign tell you?",
        correct: "Where to pick up your checked luggage",
        wrong: [
          "Where to board your flight",
          "Where to check in your luggage",
          "Where to report lost luggage",
        ],
        explanation:
          "RECOGIDA DE EQUIPAJES = BAGGAGE CLAIM, literally ‘collection of luggage’. The wrong answers would be SALA DE EMBARQUE, FACTURACIÓN, and OBJETOS PERDIDOS respectively.",
      },
    },
    {
      wordOrPhrase: "SALIDA",
      phonetic: "[sah-LEE-dah]",
      english: "exit",
      mnemonic:
        "SALIDA — think ‘sally forth’, to go out.",
      highlight: {
        kind: "caption",
        fullText:
          "LLEGADAS INTERNACIONALES · CONTROL DE PASAPORTES · RECOGIDA DE EQUIPAJES · SALIDA",
        highlightWord: "SALIDA",
      },
      hints: [
        "Sounds like ‘sally’ — to ‘sally forth’ means to go out. English owes that word to the same root (Latin salire, to spring out).",
        "This is the very last word on the sign. Everything else leads you here.",
      ],
      gatedExercise: {
        kind: "speaking",
        prompt: "Say it aloud.",
        expected: "salida",
        translation: "exit",
        explanation:
          "SALIDA = EXIT / WAY OUT. In Madrid, SALIDA signs are green — follow the green arrow.",
        translationCheck: {
          options: ["Exit", "Entrance", "Information", "Taxi rank"],
          correctIndex: 0,
          explanation:
            "SALIDA = EXIT. You'll see it everywhere in airports and metro stations, always pointing toward the way out.",
        },
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
      question: "SALIDA — what does this word mean?",
      correct: "Exit",
      wrong: ["Entrance", "Baggage claim", "Passport control"],
      explanation:
        "SALIDA = EXIT. Spanish verb salir means to leave; the English ‘sally forth’ shares the same Latin root.",
    },
    {
      kind: "fill_blank",
      prompt: "Passport control is CONTROL DE ______",
      correct: "PASAPORTES",
      hint: "Same word as English, plural.",
      explanation:
        "PASAPORTES = PASSPORTS. ‘DE’ connects the two nouns, making ‘control OF passports’.",
    },
    {
      kind: "listening",
      audio: "LLEGADAS",
      question: "You just heard the announcer say this word. What does it mean?",
      correct: "Arrivals",
      wrong: ["Departures", "Delays", "Gate change"],
      explanation:
        "LLEGADAS = ARRIVALS, from llegar (to arrive). SALIDAS would be departures — opposite side of the terminal.",
    },
    {
      kind: "multiple_choice",
      question: "RECOGIDA DE EQUIPAJES — what does this sign tell you?",
      correct: "Where to pick up your checked bags",
      wrong: [
        "Where to check in your bags",
        "Where to report lost bags",
        "Where to board the plane",
      ],
      explanation:
        "RECOGIDA DE EQUIPAJES = ‘collection of luggage’, i.e. baggage claim.",
    },
    {
      kind: "speaking",
      prompt: "Say the word for ‘exit’.",
      expected: "salida",
      translation: "exit",
      explanation:
        "SALIDA = EXIT. Sa-LEE-dah. In Madrid airports and metros, SALIDA signs are green.",
      translationCheck: {
        options: ["Exit", "Entrance", "Welcome", "Elevator"],
        correctIndex: 0,
        explanation:
          "SALIDA = EXIT. The verb salir means to leave — it's the word that gets you out of every airport, metro, and museum in Spain.",
      },
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
      hints: [
        "You've heard HOLA a thousand times — it's the Spanish you already know.",
        "BUENAS is the feminine plural of BUENO (good). TARDES is close to the English ‘tardy’ — late in the day.",
        "In Spain, this greeting kicks in right after lunch, around 2pm. Before that it's BUENOS DÍAS; after sunset, BUENAS NOCHES.",
      ],
      audioSnippet: "Hola, buenas tardes.",
      gatedExercise: {
        kind: "multiple_choice",
        question: "What did the driver just say?",
        correct: "Hello, good afternoon",
        wrong: ["Hello, good morning", "Welcome, good evening", "Goodbye, safe travels"],
        explanation:
          "HOLA, BUENAS TARDES = HELLO, GOOD AFTERNOON. BUENAS DÍAS is good morning; BUENAS NOCHES is good evening/night.",
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

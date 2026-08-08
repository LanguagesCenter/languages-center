// Quick-reference travel phrasebooks. Each slug gets 65 phrases across
// eight categories in a fixed order so counts and section headings match
// across the app.

export interface TravelPhrase {
  phrase: string;
  phonetic: string;
  english: string;
}

export interface TravelCategory {
  id: string;
  title: string;
  phrases: TravelPhrase[];
}

export interface TravelPhrasebook {
  slug: string;
  language: string;
  speechLang: string;
  categories: TravelCategory[];
}

const TRAVEL_PHRASEBOOKS: Record<string, TravelPhrasebook> = {
  spanish: {
    slug: "spanish",
    language: "Spanish",
    speechLang: "es-ES",
    categories: [
      {
        id: "greetings",
        title: "Greetings & Basics",
        phrases: [
          { phrase: "Hola",                 phonetic: "OH-lah",                              english: "Hello" },
          { phrase: "Buenos días",          phonetic: "BWEH-nohs DEE-ahs",                   english: "Good morning" },
          { phrase: "Buenas tardes",        phonetic: "BWEH-nahs TAR-dehs",                  english: "Good afternoon" },
          { phrase: "Buenas noches",        phonetic: "BWEH-nahs NOH-chehs",                 english: "Good evening / Good night" },
          { phrase: "Adiós",                phonetic: "ah-dee-OHS",                          english: "Goodbye" },
          { phrase: "Por favor",            phonetic: "por fah-VOR",                         english: "Please" },
          { phrase: "Gracias",              phonetic: "GRAH-see-ahs",                        english: "Thank you" },
          { phrase: "De nada",              phonetic: "deh NAH-dah",                         english: "You're welcome" },
          { phrase: "Perdón",               phonetic: "pehr-DOHN",                           english: "Excuse me / Sorry" },
          { phrase: "¿Habla inglés?",       phonetic: "AH-blah een-GLEHS",                   english: "Do you speak English?" },
        ],
      },
      {
        id: "directions",
        title: "Getting Around & Directions",
        phrases: [
          { phrase: "¿Dónde está…?",        phonetic: "DOHN-deh ehs-TAH",                    english: "Where is…?" },
          { phrase: "¿Cómo llego a…?",      phonetic: "KOH-moh YEH-goh ah",                  english: "How do I get to…?" },
          { phrase: "A la izquierda",       phonetic: "ah lah ees-kee-EHR-dah",              english: "To the left" },
          { phrase: "A la derecha",         phonetic: "ah lah deh-REH-chah",                 english: "To the right" },
          { phrase: "Todo recto",           phonetic: "TOH-doh REHK-toh",                    english: "Straight ahead" },
          { phrase: "Cerca / Lejos",        phonetic: "SEHR-kah / LEH-hohs",                 english: "Near / Far" },
          { phrase: "La estación",          phonetic: "lah ehs-tah-see-OHN",                 english: "The station" },
          { phrase: "El aeropuerto",        phonetic: "el ah-eh-roh-PWEHR-toh",              english: "The airport" },
          { phrase: "Un taxi, por favor",   phonetic: "oon TAHK-see por fah-VOR",            english: "A taxi, please" },
          { phrase: "¿A qué hora sale?",    phonetic: "ah keh OH-rah SAH-leh",               english: "What time does it leave?" },
        ],
      },
      {
        id: "accommodation",
        title: "Accommodation",
        phrases: [
          { phrase: "Tengo una reserva",             phonetic: "TEHN-goh OO-nah reh-SEHR-bah",             english: "I have a reservation" },
          { phrase: "¿Tiene habitaciones libres?",   phonetic: "TYEH-neh ah-bee-tah-see-OH-nehs LEE-brehs", english: "Do you have rooms available?" },
          { phrase: "Una habitación doble",          phonetic: "OO-nah ah-bee-tah-see-OHN DOH-bleh",       english: "A double room" },
          { phrase: "Una habitación individual",     phonetic: "OO-nah ah-bee-tah-see-OHN een-dee-bee-DWAHL", english: "A single room" },
          { phrase: "¿Cuánto por noche?",            phonetic: "KWAHN-toh por NOH-cheh",                   english: "How much per night?" },
          { phrase: "El desayuno está incluido",     phonetic: "el deh-sah-YOO-noh ehs-TAH een-KLOO-ee-doh", english: "Breakfast is included" },
          { phrase: "La llave, por favor",           phonetic: "lah YAH-beh por fah-VOR",                  english: "The key, please" },
          { phrase: "¿Hay wifi?",                    phonetic: "eye WEE-fee",                              english: "Is there wifi?" },
        ],
      },
      {
        id: "food",
        title: "Ordering Food & Drinks",
        phrases: [
          { phrase: "Una mesa para dos",     phonetic: "OO-nah MEH-sah PAH-rah dohs",         english: "A table for two" },
          { phrase: "La carta, por favor",   phonetic: "lah KAR-tah por fah-VOR",             english: "The menu, please" },
          { phrase: "Quisiera…",             phonetic: "kee-see-EH-rah",                      english: "I would like…" },
          { phrase: "Agua, por favor",       phonetic: "AH-gwah por fah-VOR",                 english: "Water, please" },
          { phrase: "Una cerveza",           phonetic: "OO-nah sehr-BEH-sah",                 english: "A beer" },
          { phrase: "Una copa de vino",      phonetic: "OO-nah KOH-pah deh BEE-noh",          english: "A glass of wine" },
          { phrase: "Soy vegetariano/a",     phonetic: "soy beh-heh-tah-ree-AH-noh",          english: "I'm vegetarian" },
          { phrase: "Está delicioso",        phonetic: "ehs-TAH deh-lee-see-OH-soh",          english: "It's delicious" },
          { phrase: "Sin gluten",            phonetic: "seen GLOO-tehn",                      english: "Gluten-free" },
          { phrase: "La cuenta, por favor",  phonetic: "lah KWEHN-tah por fah-VOR",           english: "The bill, please" },
        ],
      },
      {
        id: "shopping",
        title: "Shopping",
        phrases: [
          { phrase: "¿Cuánto cuesta?",             phonetic: "KWAHN-toh KWEHS-tah",                      english: "How much is it?" },
          { phrase: "Es muy caro",                 phonetic: "ehs mwee KAH-roh",                         english: "It's very expensive" },
          { phrase: "¿Puedo probármelo?",          phonetic: "PWEH-doh proh-BAHR-meh-loh",               english: "Can I try it on?" },
          { phrase: "¿Tiene una talla más grande?", phonetic: "TYEH-neh OO-nah TAH-yah mahs GRAHN-deh",  english: "Do you have a bigger size?" },
          { phrase: "Sólo estoy mirando",          phonetic: "SOH-loh ehs-TOY mee-RAHN-doh",             english: "I'm just looking" },
          { phrase: "Me lo llevo",                 phonetic: "meh loh YEH-boh",                          english: "I'll take it" },
          { phrase: "¿Acepta tarjeta?",            phonetic: "ah-SEHP-tah tar-HEH-tah",                  english: "Do you accept card?" },
          { phrase: "Un recibo, por favor",        phonetic: "oon reh-SEE-boh por fah-VOR",              english: "A receipt, please" },
        ],
      },
      {
        id: "emergencies",
        title: "Emergencies & Health",
        phrases: [
          { phrase: "¡Ayuda!",                     phonetic: "ah-YOO-dah",                               english: "Help!" },
          { phrase: "Llame a la policía",          phonetic: "YAH-meh ah lah poh-lee-SEE-ah",            english: "Call the police" },
          { phrase: "Necesito un médico",          phonetic: "neh-seh-SEE-toh oon MEH-dee-koh",          english: "I need a doctor" },
          { phrase: "Me duele aquí",               phonetic: "meh DWEH-leh ah-KEE",                      english: "It hurts here" },
          { phrase: "Soy alérgico/a",              phonetic: "soy ah-LEHR-hee-koh",                      english: "I'm allergic" },
          { phrase: "Llame a una ambulancia",      phonetic: "YAH-meh ah OO-nah ahm-boo-LAHN-see-ah",    english: "Call an ambulance" },
          { phrase: "Me han robado",               phonetic: "meh ahn roh-BAH-doh",                      english: "I've been robbed" },
          { phrase: "¿Dónde está la farmacia?",    phonetic: "DOHN-deh ehs-TAH lah far-MAH-see-ah",      english: "Where is the pharmacy?" },
        ],
      },
      {
        id: "numbers",
        title: "Numbers & Money",
        phrases: [
          { phrase: "Uno, dos, tres",              phonetic: "OO-noh, dohs, trehs",                      english: "One, two, three" },
          { phrase: "Cuatro, cinco, seis",         phonetic: "KWAH-troh, SEEN-koh, seys",                english: "Four, five, six" },
          { phrase: "Siete, ocho, nueve, diez",    phonetic: "see-EH-teh, OH-choh, NWEH-beh, dee-EHS",   english: "Seven, eight, nine, ten" },
          { phrase: "Veinte, cincuenta, cien",     phonetic: "BEHN-teh, seen-KWEHN-tah, see-EHN",        english: "Twenty, fifty, one hundred" },
          { phrase: "En efectivo",                 phonetic: "ehn eh-fehk-TEE-boh",                      english: "In cash" },
          { phrase: "Con tarjeta",                 phonetic: "kohn tar-HEH-tah",                         english: "By card" },
        ],
      },
      {
        id: "smalltalk",
        title: "Small Talk",
        phrases: [
          { phrase: "¿Cómo estás?",                phonetic: "KOH-moh ehs-TAHS",                         english: "How are you?" },
          { phrase: "Muy bien, gracias",           phonetic: "mwee bee-EHN GRAH-see-ahs",                english: "Very well, thanks" },
          { phrase: "¿Cómo te llamas?",            phonetic: "KOH-moh teh YAH-mahs",                     english: "What's your name?" },
          { phrase: "Me llamo…",                   phonetic: "meh YAH-moh",                              english: "My name is…" },
          { phrase: "Mucho gusto",                 phonetic: "MOO-choh GOOS-toh",                        english: "Nice to meet you" },
        ],
      },
    ],
  },
  french: {
    slug: "french",
    language: "French",
    speechLang: "fr-FR",
    categories: [
      {
        id: "greetings",
        title: "Greetings & Basics",
        phrases: [
          { phrase: "Bonjour",              phonetic: "bohn-ZHOOR",                          english: "Hello / Good day" },
          { phrase: "Bonsoir",              phonetic: "bohn-SWAHR",                          english: "Good evening" },
          { phrase: "Salut",                phonetic: "sah-LOO",                             english: "Hi / Bye (informal)" },
          { phrase: "Au revoir",            phonetic: "oh ruh-VWAHR",                        english: "Goodbye" },
          { phrase: "S'il vous plaît",      phonetic: "seel voo PLEH",                       english: "Please" },
          { phrase: "Merci",                phonetic: "mehr-SEE",                            english: "Thank you" },
          { phrase: "De rien",              phonetic: "duh ree-EHN",                         english: "You're welcome" },
          { phrase: "Excusez-moi",          phonetic: "ehks-koo-zay MWAH",                   english: "Excuse me" },
          { phrase: "Pardon",               phonetic: "par-DOHN",                            english: "Sorry" },
          { phrase: "Parlez-vous anglais ?", phonetic: "par-lay VOO ahn-GLEH",               english: "Do you speak English?" },
        ],
      },
      {
        id: "directions",
        title: "Getting Around & Directions",
        phrases: [
          { phrase: "Où est… ?",                    phonetic: "oo EH",                        english: "Where is…?" },
          { phrase: "Comment aller à… ?",           phonetic: "koh-MAHN ah-LAY ah",           english: "How do I get to…?" },
          { phrase: "À gauche",                     phonetic: "ah GOHSH",                     english: "To the left" },
          { phrase: "À droite",                     phonetic: "ah DRWAHT",                    english: "To the right" },
          { phrase: "Tout droit",                   phonetic: "too DRWAH",                    english: "Straight ahead" },
          { phrase: "Près / Loin",                  phonetic: "PREH / LWAHN",                 english: "Near / Far" },
          { phrase: "La gare",                      phonetic: "lah GAR",                      english: "The train station" },
          { phrase: "L'aéroport",                   phonetic: "lah-ay-roh-POR",               english: "The airport" },
          { phrase: "Un taxi, s'il vous plaît",     phonetic: "uhn tahk-SEE seel voo PLEH",   english: "A taxi, please" },
          { phrase: "À quelle heure part-il ?",     phonetic: "ah kehl UHR par-TEEL",         english: "What time does it leave?" },
        ],
      },
      {
        id: "accommodation",
        title: "Accommodation",
        phrases: [
          { phrase: "J'ai une réservation",              phonetic: "zhay OON ray-zehr-vah-SYOHN",           english: "I have a reservation" },
          { phrase: "Avez-vous des chambres libres ?",   phonetic: "ah-VAY voo day SHAHM-bruh LEE-bruh",     english: "Do you have rooms available?" },
          { phrase: "Une chambre double",                phonetic: "OON SHAHM-bruh DOO-bluh",               english: "A double room" },
          { phrase: "Une chambre simple",                phonetic: "OON SHAHM-bruh SAHN-pluh",              english: "A single room" },
          { phrase: "Combien par nuit ?",                phonetic: "kohm-BYEHN par NWEE",                   english: "How much per night?" },
          { phrase: "Le petit déjeuner est inclus",      phonetic: "luh puh-TEE day-zhuh-NAY ay ahn-KLOO",  english: "Breakfast is included" },
          { phrase: "La clé, s'il vous plaît",           phonetic: "lah KLAY seel voo PLEH",                english: "The key, please" },
          { phrase: "Y a-t-il du wifi ?",                phonetic: "ee ah-teel doo WEE-fee",                english: "Is there wifi?" },
        ],
      },
      {
        id: "food",
        title: "Ordering Food & Drinks",
        phrases: [
          { phrase: "Une table pour deux",           phonetic: "OON TAH-bluh poor DUH",                english: "A table for two" },
          { phrase: "La carte, s'il vous plaît",     phonetic: "lah KART seel voo PLEH",               english: "The menu, please" },
          { phrase: "Je voudrais…",                  phonetic: "zhuh voo-DREH",                        english: "I would like…" },
          { phrase: "De l'eau, s'il vous plaît",     phonetic: "duh LOH seel voo PLEH",                english: "Water, please" },
          { phrase: "Une bière",                     phonetic: "OON bee-EHR",                          english: "A beer" },
          { phrase: "Un verre de vin",               phonetic: "uhn VEHR duh VAHN",                    english: "A glass of wine" },
          { phrase: "Je suis végétarien(ne)",        phonetic: "zhuh SWEE vay-zhay-tah-RYEHN",         english: "I'm vegetarian" },
          { phrase: "C'est délicieux",               phonetic: "say day-lee-SYUH",                     english: "It's delicious" },
          { phrase: "Sans gluten",                   phonetic: "sahn gloo-TEHN",                       english: "Gluten-free" },
          { phrase: "L'addition, s'il vous plaît",   phonetic: "lah-dee-SYOHN seel voo PLEH",          english: "The bill, please" },
        ],
      },
      {
        id: "shopping",
        title: "Shopping",
        phrases: [
          { phrase: "Combien ça coûte ?",                 phonetic: "kohm-BYEHN sah KOOT",              english: "How much does it cost?" },
          { phrase: "C'est trop cher",                    phonetic: "say troh SHEHR",                   english: "It's too expensive" },
          { phrase: "Puis-je l'essayer ?",                phonetic: "pweezh leh-say-YAY",               english: "Can I try it on?" },
          { phrase: "Avez-vous une taille plus grande ?", phonetic: "ah-VAY voo OON TAHY ploo GRAHND",  english: "Do you have a bigger size?" },
          { phrase: "Je regarde seulement",               phonetic: "zhuh ruh-GARD suhl-MAHN",          english: "I'm just looking" },
          { phrase: "Je le prends",                       phonetic: "zhuh luh PRAHN",                   english: "I'll take it" },
          { phrase: "Acceptez-vous la carte ?",           phonetic: "ahk-sehp-TAY voo lah KART",        english: "Do you accept card?" },
          { phrase: "Un reçu, s'il vous plaît",           phonetic: "uhn ruh-SOO seel voo PLEH",        english: "A receipt, please" },
        ],
      },
      {
        id: "emergencies",
        title: "Emergencies & Health",
        phrases: [
          { phrase: "Au secours !",                  phonetic: "oh suh-KOOR",                          english: "Help!" },
          { phrase: "Appelez la police",             phonetic: "ah-play lah poh-LEES",                 english: "Call the police" },
          { phrase: "J'ai besoin d'un médecin",      phonetic: "zhay buh-ZWAHN duhn mayd-SAHN",        english: "I need a doctor" },
          { phrase: "J'ai mal ici",                  phonetic: "zhay MAHL ee-SEE",                     english: "It hurts here" },
          { phrase: "Je suis allergique",            phonetic: "zhuh SWEE ah-lehr-ZHEEK",              english: "I'm allergic" },
          { phrase: "Appelez une ambulance",         phonetic: "ah-play OON ahm-boo-LAHNS",            english: "Call an ambulance" },
          { phrase: "On m'a volé",                   phonetic: "ohn mah voh-LAY",                      english: "I've been robbed" },
          { phrase: "Où est la pharmacie ?",         phonetic: "oo EH lah far-mah-SEE",                english: "Where is the pharmacy?" },
        ],
      },
      {
        id: "numbers",
        title: "Numbers & Money",
        phrases: [
          { phrase: "Un, deux, trois",               phonetic: "uhn, DUH, TRWAH",                      english: "One, two, three" },
          { phrase: "Quatre, cinq, six",             phonetic: "KAH-truh, SANK, SEES",                 english: "Four, five, six" },
          { phrase: "Sept, huit, neuf, dix",         phonetic: "SEHT, WEET, NUHF, DEES",               english: "Seven, eight, nine, ten" },
          { phrase: "Vingt, cinquante, cent",        phonetic: "VAHN, san-KAHNT, SAHN",                english: "Twenty, fifty, one hundred" },
          { phrase: "En espèces",                    phonetic: "ahn ehs-PEHS",                         english: "In cash" },
          { phrase: "Par carte",                     phonetic: "par KART",                             english: "By card" },
        ],
      },
      {
        id: "smalltalk",
        title: "Small Talk",
        phrases: [
          { phrase: "Comment ça va ?",               phonetic: "koh-MAHN sah VAH",                     english: "How are you?" },
          { phrase: "Très bien, merci",              phonetic: "treh BYEHN mehr-SEE",                  english: "Very well, thank you" },
          { phrase: "Comment tu t'appelles ?",       phonetic: "koh-MAHN too tah-PEHL",                english: "What's your name?" },
          { phrase: "Je m'appelle…",                 phonetic: "zhuh mah-PEHL",                        english: "My name is…" },
          { phrase: "Enchanté(e)",                   phonetic: "ahn-shahn-TAY",                        english: "Nice to meet you" },
        ],
      },
    ],
  },
};

export function getTravelPhrasebook(slug: string): TravelPhrasebook | null {
  return TRAVEL_PHRASEBOOKS[slug] ?? null;
}

export function hasTravelPhrasebook(slug: string): boolean {
  return slug in TRAVEL_PHRASEBOOKS;
}

export function totalPhraseCount(book: TravelPhrasebook): number {
  return book.categories.reduce((sum, c) => sum + c.phrases.length, 0);
}

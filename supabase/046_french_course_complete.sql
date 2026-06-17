-- 046_french_course_complete.sql
-- Build the complete French course mirroring the Spanish structure:
--   5 CEFR levels (A1-C1) × 15 sections × 9 lessons (8 teaching + 1 unit_test).
-- The French language row already exists in public.languages (code 'french').
-- The exercises type constraint already accepts 'writing' from migration 039.
-- The speech-recognition layer already maps 'french' → 'fr-FR' in
-- src/lib/speech.ts.
--
-- NOTE on jsonb field names: dialogue lines use the key "spanish" and
-- vocab examples use "example_es" for the target-language string. This is a
-- historical name dating back to when Spanish was the only seeded language;
-- the rendering code (LessonClient.tsx, lib/learn.ts) still reads those keys.
-- The values inside are real French — just stored under the legacy key name.
--
-- Approach:
--   Phase 1: Wipe any existing French courses.
--   Phase 2: For each level × section, create the 8 lesson skeleton plus a
--            unit_test lesson, with type-appropriate teaching content
--            (intro / vocab_items / dialogue / grammar_note).
--   Phase 3: Insert exercises per lesson type using the same homogeneous
--            pattern as Spanish migrations 044 + 045:
--              vocabulary: section-themed MC + fill-blank (A1) +
--                          level-tier MC/fill-blank for higher levels
--              grammar:    level-tier MC + fill-blank
--              phrases:    level-tier dialogue completion fill-blank
--              listening:  3 MC listening + 1 typed-response (AI-graded)
--              speaking:   2 repeat-phrase + 2 topic monologue (AI-graded)
--              reading:    1 passage + 3 comprehension MC
--              writing:    3 prompts (AI-graded)
--              unit_test:  10 mixed MC + fill-blank questions
--
-- Voice: the existing fr-FR mapping in src/lib/speech.ts drives the TTS.
--
-- Idempotent.

alter table public.exercises drop constraint if exists exercises_type_check;
alter table public.exercises
  add constraint exercises_type_check
  check (type in ('multiple_choice','fill_blank','matching','listening','speaking','writing'));

alter table public.lessons drop constraint if exists lessons_type_check;
alter table public.lessons
  add constraint lessons_type_check
  check (type in (
    'vocabulary','grammar','phrases','listening','speaking',
    'reading','writing','podcast','unit_test','conversation'
  ));

-- ============== PHASE 1 + 2: Build the course skeleton ==============
do $$
declare
  v_lang_id   bigint;
  v_course_id bigint;
  v_lesson_id bigint;
  v_level     text;
  -- v_section holds the FRENCH section name and is used inside teaching
  -- content (intros, dialogue prompts, vocab examples) which is supposed
  -- to be in French. v_section_en holds the English canonical name and
  -- is used for course/lesson title + description rows so the i18n layer
  -- can translate them to the active UI language (see
  -- src/lib/i18n.ts:translateSectionTitle).
  v_section     text;
  v_section_en  text;
  v_xp        int;
  v_idx       int;
  v_sections     text[];
  v_sections_en  text[];
  v_podcast_desc text;
  i int;

  -- French section labels (used inside teaching content).
  a1_sections text[] := array[
    'Salutations','Nombres','Couleurs','Famille','Nourriture',
    'Heure','Météo','Courses','Animaux','Parties du corps',
    'Vêtements','Maison','Transports','Jours et mois','Verbes de base'
  ];
  a2_sections text[] := array[
    'Routines quotidiennes','Santé et corps','Loisirs','Travail et emploi','Itinéraires',
    'Sentiments et émotions','Fêtes','Nature','Sports','Musique',
    'Préparation de voyage','Restaurants','École','Bases de la technologie','Réseaux sociaux'
  ];
  b1_sections text[] := array[
    'Voyages et tourisme','Actualités et médias','Environnement','Relations','Culture et traditions',
    'Argent et banques','Éducation','Politique de base','Cuisine','Art et littérature',
    'Santé et médecine','Bases du business','Sports et fitness','Musique et divertissement','Bases des sciences'
  ];
  b2_sections text[] := array[
    'Politique et société','Technologie et innovation','Philosophie et éthique','Littérature et poésie',
    'Économie et affaires','Sciences et recherche','Arts et culture','Médias et journalisme',
    'Droit et justice','Histoire','Psychologie','Architecture','Mode et design',
    'Analyse sportive','Enjeux environnementaux'
  ];
  c1_sections text[] := array[
    'Expressions idiomatiques','Grammaire avancée','Écriture formelle','Débat et discussion','Contenu natif',
    'Langue académique','Communication professionnelle','Nuances culturelles','Rhétorique et persuasion',
    'Littérature avancée','Structures grammaticales complexes','Dialectes régionaux','Argot et langue informelle',
    'Compétences de traduction','Enseignement des langues'
  ];

  -- English canonical section labels (used for course/lesson titles +
  -- descriptions; matches 015_spanish_restructure_15x8.sql 1:1 so both
  -- courses share the same i18n translation slug).
  a1_sections_en text[] := array[
    'Greetings','Numbers','Colors','Family','Food','Time','Weather','Shopping',
    'Animals','Body Parts','Clothes','House & Home','Transport','Days & Months','Basic Verbs'
  ];
  a2_sections_en text[] := array[
    'Daily Routines','Health & Body','Hobbies','Work & Jobs','Directions',
    'Feelings & Emotions','Celebrations','Nature','Sports','Music',
    'Travel Planning','Restaurants','School','Technology Basics','Social Media'
  ];
  b1_sections_en text[] := array[
    'Travel & Tourism','News & Media','Environment','Relationships','Culture & Traditions',
    'Money & Banking','Education','Politics Basics','Food & Cooking','Art & Literature',
    'Health & Medicine','Business Basics','Sports & Fitness','Music & Entertainment','Science Basics'
  ];
  b2_sections_en text[] := array[
    'Politics & Society','Technology & Innovation','Philosophy & Ethics','Literature & Poetry',
    'Business & Economics','Science & Research','Arts & Culture','Media & Journalism',
    'Law & Justice','History','Psychology','Architecture','Fashion & Design',
    'Sports Analysis','Environmental Issues'
  ];
  c1_sections_en text[] := array[
    'Idioms & Expressions','Advanced Grammar','Formal Writing','Debate & Discussion','Native Content',
    'Academic Language','Professional Communication','Cultural Nuance','Rhetoric & Persuasion',
    'Advanced Literature','Complex Grammar Structures','Regional Dialects','Slang & Informal Language',
    'Translation Skills','Language Teaching'
  ];

  -- Per-A1-section vocabulary (8 items: word, phonetic, english, example_fr, example_en).
  -- Stored as a flat array indexed [section_idx * 8 + word_idx].
  a1_vocab jsonb[] := array[
    -- 1: Salutations
    '[{"word":"bonjour","phonetic":"[bohn-zhoor]","english":"hello / good morning","example_es":"Bonjour, comment ça va?","example_en":"Hello, how are you?"},
       {"word":"salut","phonetic":"[sah-loo]","english":"hi","example_es":"Salut Marie!","example_en":"Hi Marie!"},
       {"word":"merci","phonetic":"[mehr-see]","english":"thank you","example_es":"Merci beaucoup.","example_en":"Thank you very much."},
       {"word":"au revoir","phonetic":"[oh ruh-vwahr]","english":"goodbye","example_es":"Au revoir, à demain.","example_en":"Goodbye, see you tomorrow."},
       {"word":"bonsoir","phonetic":"[bohn-swahr]","english":"good evening","example_es":"Bonsoir madame.","example_en":"Good evening, madam."},
       {"word":"oui","phonetic":"[wee]","english":"yes","example_es":"Oui, bien sûr.","example_en":"Yes, of course."},
       {"word":"non","phonetic":"[nohn]","english":"no","example_es":"Non, merci.","example_en":"No, thank you."},
       {"word":"s’il vous plaît","phonetic":"[seel voo pleh]","english":"please","example_es":"Un café, s’il vous plaît.","example_en":"A coffee, please."}]'::jsonb,
    -- 2: Nombres
    '[{"word":"un","phonetic":"[uhn]","english":"one","example_es":"J’ai un frère.","example_en":"I have one brother."},
       {"word":"deux","phonetic":"[duh]","english":"two","example_es":"Deux cafés, s’il vous plaît.","example_en":"Two coffees, please."},
       {"word":"trois","phonetic":"[twah]","english":"three","example_es":"Il a trois enfants.","example_en":"He has three children."},
       {"word":"quatre","phonetic":"[katr]","english":"four","example_es":"Quatre euros.","example_en":"Four euros."},
       {"word":"cinq","phonetic":"[sank]","english":"five","example_es":"Cinq minutes.","example_en":"Five minutes."},
       {"word":"six","phonetic":"[sees]","english":"six","example_es":"Six heures.","example_en":"Six o’clock."},
       {"word":"sept","phonetic":"[set]","english":"seven","example_es":"Sept jours.","example_en":"Seven days."},
       {"word":"huit","phonetic":"[weet]","english":"eight","example_es":"Huit ans.","example_en":"Eight years."}]'::jsonb,
    -- 3: Couleurs
    '[{"word":"rouge","phonetic":"[roozh]","english":"red","example_es":"Une voiture rouge.","example_en":"A red car."},
       {"word":"bleu","phonetic":"[bluh]","english":"blue","example_es":"Le ciel est bleu.","example_en":"The sky is blue."},
       {"word":"vert","phonetic":"[vehr]","english":"green","example_es":"L’herbe est verte.","example_en":"The grass is green."},
       {"word":"jaune","phonetic":"[zhohn]","english":"yellow","example_es":"Un citron jaune.","example_en":"A yellow lemon."},
       {"word":"noir","phonetic":"[nwahr]","english":"black","example_es":"Un chat noir.","example_en":"A black cat."},
       {"word":"blanc","phonetic":"[blahn]","english":"white","example_es":"La neige est blanche.","example_en":"The snow is white."},
       {"word":"rose","phonetic":"[rohz]","english":"pink","example_es":"Une rose rose.","example_en":"A pink rose."},
       {"word":"orange","phonetic":"[oh-rahnzh]","english":"orange","example_es":"Une orange orange.","example_en":"An orange orange."}]'::jsonb,
    -- 4: Famille
    '[{"word":"père","phonetic":"[pehr]","english":"father","example_es":"Mon père est gentil.","example_en":"My father is kind."},
       {"word":"mère","phonetic":"[mehr]","english":"mother","example_es":"Ma mère est médecin.","example_en":"My mother is a doctor."},
       {"word":"frère","phonetic":"[frehr]","english":"brother","example_es":"J’ai un frère.","example_en":"I have a brother."},
       {"word":"sœur","phonetic":"[suhr]","english":"sister","example_es":"Ma sœur a dix ans.","example_en":"My sister is ten."},
       {"word":"fils","phonetic":"[fees]","english":"son","example_es":"Son fils est étudiant.","example_en":"His son is a student."},
       {"word":"fille","phonetic":"[fee]","english":"daughter / girl","example_es":"Ma fille s’appelle Anna.","example_en":"My daughter is called Anna."},
       {"word":"grand-père","phonetic":"[grahn-pehr]","english":"grandfather","example_es":"Mon grand-père a 80 ans.","example_en":"My grandfather is 80."},
       {"word":"grand-mère","phonetic":"[grahn-mehr]","english":"grandmother","example_es":"Ma grand-mère cuisine bien.","example_en":"My grandmother cooks well."}]'::jsonb,
    -- 5: Nourriture
    '[{"word":"pain","phonetic":"[pahn]","english":"bread","example_es":"Je mange du pain.","example_en":"I eat bread."},
       {"word":"eau","phonetic":"[oh]","english":"water","example_es":"Un verre d’eau.","example_en":"A glass of water."},
       {"word":"fromage","phonetic":"[froh-mazh]","english":"cheese","example_es":"J’aime le fromage français.","example_en":"I like French cheese."},
       {"word":"viande","phonetic":"[vee-ahnd]","english":"meat","example_es":"Je ne mange pas de viande.","example_en":"I don’t eat meat."},
       {"word":"pomme","phonetic":"[pum]","english":"apple","example_es":"Une pomme rouge.","example_en":"A red apple."},
       {"word":"riz","phonetic":"[ree]","english":"rice","example_es":"Du riz blanc.","example_en":"White rice."},
       {"word":"café","phonetic":"[kah-fay]","english":"coffee","example_es":"Un café noir.","example_en":"A black coffee."},
       {"word":"thé","phonetic":"[tay]","english":"tea","example_es":"Un thé vert.","example_en":"A green tea."}]'::jsonb,
    -- 6: Heure
    '[{"word":"heure","phonetic":"[uhr]","english":"hour / time","example_es":"Quelle heure est-il?","example_en":"What time is it?"},
       {"word":"minute","phonetic":"[mee-noot]","english":"minute","example_es":"Cinq minutes.","example_en":"Five minutes."},
       {"word":"jour","phonetic":"[zhoor]","english":"day","example_es":"Un jour férié.","example_en":"A public holiday."},
       {"word":"nuit","phonetic":"[nwee]","english":"night","example_es":"Bonne nuit.","example_en":"Good night."},
       {"word":"matin","phonetic":"[mah-tan]","english":"morning","example_es":"Le matin, je cours.","example_en":"In the morning, I run."},
       {"word":"soir","phonetic":"[swahr]","english":"evening","example_es":"Le soir, je lis.","example_en":"In the evening, I read."},
       {"word":"midi","phonetic":"[mee-dee]","english":"noon","example_es":"On mange à midi.","example_en":"We eat at noon."},
       {"word":"minuit","phonetic":"[mee-nwee]","english":"midnight","example_es":"À minuit pile.","example_en":"At midnight sharp."}]'::jsonb,
    -- 7: Météo
    '[{"word":"soleil","phonetic":"[soh-leh-ee]","english":"sun","example_es":"Il y a du soleil.","example_en":"It’s sunny."},
       {"word":"pluie","phonetic":"[plwee]","english":"rain","example_es":"Il y a de la pluie.","example_en":"There’s rain."},
       {"word":"neige","phonetic":"[nezh]","english":"snow","example_es":"La neige tombe.","example_en":"The snow is falling."},
       {"word":"vent","phonetic":"[vahn]","english":"wind","example_es":"Il y a du vent.","example_en":"It’s windy."},
       {"word":"chaud","phonetic":"[shoh]","english":"hot","example_es":"Il fait chaud.","example_en":"It’s hot."},
       {"word":"froid","phonetic":"[frwah]","english":"cold","example_es":"Il fait froid.","example_en":"It’s cold."},
       {"word":"nuage","phonetic":"[nwazh]","english":"cloud","example_es":"Un gros nuage.","example_en":"A big cloud."},
       {"word":"temps","phonetic":"[tahn]","english":"weather","example_es":"Quel temps fait-il?","example_en":"What’s the weather like?"}]'::jsonb,
    -- 8: Courses
    '[{"word":"magasin","phonetic":"[mah-gah-zan]","english":"shop / store","example_es":"Le magasin est ouvert.","example_en":"The shop is open."},
       {"word":"prix","phonetic":"[pree]","english":"price","example_es":"Quel est le prix?","example_en":"What’s the price?"},
       {"word":"acheter","phonetic":"[ahsh-tay]","english":"to buy","example_es":"J’aime acheter des livres.","example_en":"I like to buy books."},
       {"word":"payer","phonetic":"[peh-yay]","english":"to pay","example_es":"Je paie par carte.","example_en":"I pay by card."},
       {"word":"argent","phonetic":"[ahr-zhan]","english":"money","example_es":"J’ai un peu d’argent.","example_en":"I have a little money."},
       {"word":"euro","phonetic":"[uh-roh]","english":"euro","example_es":"Ça fait dix euros.","example_en":"That’s ten euros."},
       {"word":"marché","phonetic":"[mahr-shay]","english":"market","example_es":"On va au marché.","example_en":"We’re going to the market."},
       {"word":"supermarché","phonetic":"[soo-pehr-mahr-shay]","english":"supermarket","example_es":"Le supermarché est grand.","example_en":"The supermarket is big."}]'::jsonb,
    -- 9: Animaux
    '[{"word":"chien","phonetic":"[shyan]","english":"dog","example_es":"Mon chien est gentil.","example_en":"My dog is kind."},
       {"word":"chat","phonetic":"[shah]","english":"cat","example_es":"Le chat dort.","example_en":"The cat is sleeping."},
       {"word":"oiseau","phonetic":"[wah-zoh]","english":"bird","example_es":"Un oiseau chante.","example_en":"A bird is singing."},
       {"word":"poisson","phonetic":"[pwah-sohn]","english":"fish","example_es":"Le poisson nage.","example_en":"The fish swims."},
       {"word":"cheval","phonetic":"[shuh-vahl]","english":"horse","example_es":"Un cheval blanc.","example_en":"A white horse."},
       {"word":"vache","phonetic":"[vash]","english":"cow","example_es":"La vache mange l’herbe.","example_en":"The cow eats the grass."},
       {"word":"cochon","phonetic":"[koh-shohn]","english":"pig","example_es":"Un cochon rose.","example_en":"A pink pig."},
       {"word":"lapin","phonetic":"[lah-pan]","english":"rabbit","example_es":"Un lapin gris.","example_en":"A grey rabbit."}]'::jsonb,
    -- 10: Parties du corps
    '[{"word":"tête","phonetic":"[tet]","english":"head","example_es":"J’ai mal à la tête.","example_en":"I have a headache."},
       {"word":"main","phonetic":"[man]","english":"hand","example_es":"Lave-toi les mains.","example_en":"Wash your hands."},
       {"word":"pied","phonetic":"[pyay]","english":"foot","example_es":"J’ai mal au pied.","example_en":"My foot hurts."},
       {"word":"œil","phonetic":"[uh-ee]","english":"eye","example_es":"Un œil bleu.","example_en":"A blue eye."},
       {"word":"bouche","phonetic":"[boosh]","english":"mouth","example_es":"Ouvrez la bouche.","example_en":"Open your mouth."},
       {"word":"oreille","phonetic":"[oh-reh-ee]","english":"ear","example_es":"J’ai mal aux oreilles.","example_en":"My ears hurt."},
       {"word":"bras","phonetic":"[brah]","english":"arm","example_es":"Levez les bras.","example_en":"Raise your arms."},
       {"word":"jambe","phonetic":"[zhahmb]","english":"leg","example_es":"Ma jambe est cassée.","example_en":"My leg is broken."}]'::jsonb,
    -- 11: Vêtements
    '[{"word":"chemise","phonetic":"[shuh-meez]","english":"shirt","example_es":"Une chemise blanche.","example_en":"A white shirt."},
       {"word":"pantalon","phonetic":"[pahn-tah-lohn]","english":"trousers","example_es":"Un pantalon noir.","example_en":"Black trousers."},
       {"word":"robe","phonetic":"[rohb]","english":"dress","example_es":"Une robe d’été.","example_en":"A summer dress."},
       {"word":"chaussure","phonetic":"[shoh-soor]","english":"shoe","example_es":"De nouvelles chaussures.","example_en":"New shoes."},
       {"word":"manteau","phonetic":"[mahn-toh]","english":"coat","example_es":"Mets ton manteau.","example_en":"Put on your coat."},
       {"word":"chapeau","phonetic":"[shah-poh]","english":"hat","example_es":"Un beau chapeau.","example_en":"A nice hat."},
       {"word":"chaussette","phonetic":"[shoh-set]","english":"sock","example_es":"Une paire de chaussettes.","example_en":"A pair of socks."},
       {"word":"écharpe","phonetic":"[ay-sharp]","english":"scarf","example_es":"Une écharpe rouge.","example_en":"A red scarf."}]'::jsonb,
    -- 12: Maison
    '[{"word":"maison","phonetic":"[meh-zohn]","english":"house","example_es":"Une grande maison.","example_en":"A big house."},
       {"word":"chambre","phonetic":"[shahmbr]","english":"bedroom","example_es":"Ma chambre est petite.","example_en":"My bedroom is small."},
       {"word":"cuisine","phonetic":"[kwee-zeen]","english":"kitchen","example_es":"Une belle cuisine.","example_en":"A beautiful kitchen."},
       {"word":"salon","phonetic":"[sah-lohn]","english":"living room","example_es":"Le salon est lumineux.","example_en":"The living room is bright."},
       {"word":"salle de bain","phonetic":"[sahl duh ban]","english":"bathroom","example_es":"La salle de bain est rénovée.","example_en":"The bathroom is renovated."},
       {"word":"jardin","phonetic":"[zhahr-dan]","english":"garden","example_es":"Un jardin fleuri.","example_en":"A flowery garden."},
       {"word":"porte","phonetic":"[port]","english":"door","example_es":"Ferme la porte.","example_en":"Close the door."},
       {"word":"fenêtre","phonetic":"[fuh-netr]","english":"window","example_es":"Ouvre la fenêtre.","example_en":"Open the window."}]'::jsonb,
    -- 13: Transports
    '[{"word":"voiture","phonetic":"[vwah-toor]","english":"car","example_es":"Ma voiture est rouge.","example_en":"My car is red."},
       {"word":"bus","phonetic":"[boos]","english":"bus","example_es":"Je prends le bus.","example_en":"I take the bus."},
       {"word":"train","phonetic":"[tran]","english":"train","example_es":"Le train part à 8h.","example_en":"The train leaves at 8."},
       {"word":"avion","phonetic":"[ah-vyon]","english":"plane","example_es":"L’avion atterrit.","example_en":"The plane is landing."},
       {"word":"vélo","phonetic":"[vay-loh]","english":"bicycle","example_es":"Je vais à vélo.","example_en":"I go by bike."},
       {"word":"bateau","phonetic":"[bah-toh]","english":"boat","example_es":"Un bateau sur le lac.","example_en":"A boat on the lake."},
       {"word":"métro","phonetic":"[may-troh]","english":"metro","example_es":"Le métro est rapide.","example_en":"The metro is fast."},
       {"word":"taxi","phonetic":"[tahk-see]","english":"taxi","example_es":"Appelle un taxi.","example_en":"Call a taxi."}]'::jsonb,
    -- 14: Jours et mois
    '[{"word":"lundi","phonetic":"[luhn-dee]","english":"Monday","example_es":"Je travaille lundi.","example_en":"I work on Monday."},
       {"word":"mardi","phonetic":"[mahr-dee]","english":"Tuesday","example_es":"On se voit mardi.","example_en":"We meet on Tuesday."},
       {"word":"mercredi","phonetic":"[mer-kruh-dee]","english":"Wednesday","example_es":"Mercredi prochain.","example_en":"Next Wednesday."},
       {"word":"jeudi","phonetic":"[zhuh-dee]","english":"Thursday","example_es":"Jeudi matin.","example_en":"Thursday morning."},
       {"word":"vendredi","phonetic":"[vahn-druh-dee]","english":"Friday","example_es":"Vendredi soir.","example_en":"Friday evening."},
       {"word":"samedi","phonetic":"[sahm-dee]","english":"Saturday","example_es":"Samedi, je sors.","example_en":"On Saturday, I go out."},
       {"word":"dimanche","phonetic":"[dee-mahnsh]","english":"Sunday","example_es":"Dimanche en famille.","example_en":"Sunday with family."},
       {"word":"janvier","phonetic":"[zhahn-vyay]","english":"January","example_es":"Janvier est froid.","example_en":"January is cold."}]'::jsonb,
    -- 15: Verbes de base
    '[{"word":"être","phonetic":"[etr]","english":"to be","example_es":"Je suis ici.","example_en":"I am here."},
       {"word":"avoir","phonetic":"[ah-vwahr]","english":"to have","example_es":"J’ai un livre.","example_en":"I have a book."},
       {"word":"aller","phonetic":"[ah-lay]","english":"to go","example_es":"Je vais à Paris.","example_en":"I’m going to Paris."},
       {"word":"faire","phonetic":"[fer]","english":"to do / to make","example_es":"Je fais du sport.","example_en":"I do sport."},
       {"word":"dire","phonetic":"[deer]","english":"to say","example_es":"Dis-moi tout.","example_en":"Tell me everything."},
       {"word":"voir","phonetic":"[vwahr]","english":"to see","example_es":"Je vois la mer.","example_en":"I see the sea."},
       {"word":"savoir","phonetic":"[sah-vwahr]","english":"to know","example_es":"Je sais nager.","example_en":"I know how to swim."},
       {"word":"pouvoir","phonetic":"[poo-vwahr]","english":"can / to be able to","example_es":"Je peux t’aider.","example_en":"I can help you."}]'::jsonb
  ];

  -- Generic vocab item template for non-A1 levels (per-level set of 8 useful
  -- words from a richer register, reused across all 15 sections of that level).
  a2_vocab jsonb := '[{"word":"hier","phonetic":"[yehr]","english":"yesterday","example_es":"Hier, je suis allé au cinéma.","example_en":"Yesterday I went to the cinema."},{"word":"demain","phonetic":"[duh-man]","english":"tomorrow","example_es":"Demain, je travaille.","example_en":"Tomorrow I work."},{"word":"toujours","phonetic":"[too-zhoor]","english":"always","example_es":"Je prends toujours du café.","example_en":"I always have coffee."},{"word":"souvent","phonetic":"[soo-vahn]","english":"often","example_es":"Je sors souvent le soir.","example_en":"I often go out in the evening."},{"word":"déjeuner","phonetic":"[day-zhuh-nay]","english":"to have lunch","example_es":"On déjeune à midi.","example_en":"We have lunch at noon."},{"word":"voyager","phonetic":"[vwah-yah-zhay]","english":"to travel","example_es":"J’aime voyager en train.","example_en":"I like travelling by train."},{"word":"essayer","phonetic":"[eh-seh-yay]","english":"to try","example_es":"J’essaie un nouveau plat.","example_en":"I’m trying a new dish."},{"word":"important","phonetic":"[an-por-tahn]","english":"important","example_es":"C’est important pour moi.","example_en":"It’s important to me."}]'::jsonb;

  b1_vocab jsonb := '[{"word":"cependant","phonetic":"[suh-pahn-dahn]","english":"however","example_es":"J’aime le café; cependant, j’en bois peu.","example_en":"I like coffee; however, I drink little of it."},{"word":"néanmoins","phonetic":"[nay-ahn-mwan]","english":"nevertheless","example_es":"C’est difficile, néanmoins j’y arriverai.","example_en":"It’s hard; nevertheless, I’ll manage."},{"word":"projet","phonetic":"[proh-zheh]","english":"project","example_es":"J’ai un nouveau projet.","example_en":"I have a new project."},{"word":"avenir","phonetic":"[ahv-neer]","english":"future","example_es":"Je pense à mon avenir.","example_en":"I think about my future."},{"word":"investir","phonetic":"[an-veh-steer]","english":"to invest","example_es":"J’investis du temps dans mes études.","example_en":"I invest time in my studies."},{"word":"réussir","phonetic":"[ray-oo-seer]","english":"to succeed","example_es":"Je veux réussir mes examens.","example_en":"I want to pass my exams."},{"word":"environnement","phonetic":"[ahn-vee-ronh-mahn]","english":"environment","example_es":"L’environnement est fragile.","example_en":"The environment is fragile."},{"word":"opinion","phonetic":"[oh-pee-nyohn]","english":"opinion","example_es":"À mon avis, c’est juste.","example_en":"In my opinion, it’s fair."}]'::jsonb;

  b2_vocab jsonb := '[{"word":"toutefois","phonetic":"[toot-fwah]","english":"however / nevertheless","example_es":"L’idée est bonne; toutefois, elle est coûteuse.","example_en":"The idea is good; however, it is costly."},{"word":"par conséquent","phonetic":"[par konh-say-kahn]","english":"consequently","example_es":"Il pleut, par conséquent on reste.","example_en":"It’s raining; consequently, we’ll stay in."},{"word":"souligner","phonetic":"[soo-lee-nyay]","english":"to underline / emphasise","example_es":"Je souligne l’importance de cette mesure.","example_en":"I emphasise the importance of this measure."},{"word":"perspective","phonetic":"[pehrsh-pek-teev]","english":"perspective","example_es":"De cette perspective, tout change.","example_en":"From this perspective, everything changes."},{"word":"enjeu","phonetic":"[ahn-zhuh]","english":"issue / stake","example_es":"Le climat est un enjeu majeur.","example_en":"Climate is a major issue."},{"word":"durable","phonetic":"[dyoo-rahbl]","english":"sustainable","example_es":"Un développement durable.","example_en":"Sustainable development."},{"word":"inévitable","phonetic":"[ee-nay-vee-tahbl]","english":"inevitable","example_es":"Le changement est inévitable.","example_en":"Change is inevitable."},{"word":"controverse","phonetic":"[kohn-troh-vehrs]","english":"controversy","example_es":"Cette décision suscite la controverse.","example_en":"This decision raises controversy."}]'::jsonb;

  c1_vocab jsonb := '[{"word":"nonobstant","phonetic":"[nohn-ohp-stahn]","english":"notwithstanding","example_es":"Nonobstant les obstacles, il a réussi.","example_en":"Notwithstanding the obstacles, he succeeded."},{"word":"il convient de","phonetic":"[eel konh-vyan duh]","english":"it is appropriate to","example_es":"Il convient de nuancer le propos.","example_en":"It is appropriate to nuance the statement."},{"word":"étayer","phonetic":"[ay-teh-yay]","english":"to substantiate","example_es":"Il faut étayer cet argument.","example_en":"This argument must be substantiated."},{"word":"sous-jacent","phonetic":"[soo-zhah-sahn]","english":"underlying","example_es":"Les causes sous-jacentes sont multiples.","example_en":"The underlying causes are multiple."},{"word":"prépondérant","phonetic":"[pray-pohn-day-rahn]","english":"predominant","example_es":"Un rôle prépondérant.","example_en":"A predominant role."},{"word":"appréhender","phonetic":"[ah-pray-ahn-day]","english":"to grasp / apprehend","example_es":"Il faut appréhender la complexité du sujet.","example_en":"The complexity of the subject must be grasped."},{"word":"de facto","phonetic":"[duh fak-toh]","english":"de facto","example_es":"C’est, de facto, la norme.","example_en":"This is, de facto, the norm."},{"word":"paradigme","phonetic":"[pah-rah-deegm]","english":"paradigm","example_es":"Un changement de paradigme.","example_en":"A paradigm shift."}]'::jsonb;

  -- Per-level grammar_note text (reused across all 15 sections of that level).
  a1_grammar_note text := 'Subject pronouns: je (I), tu (you, informal), il/elle (he/she), nous (we), vous (you formal/plural), ils/elles (they). Regular -er verbs in the present tense drop -er and add -e/-es/-e/-ons/-ez/-ent (parler → je parle, tu parles, il parle, nous parlons, vous parlez, ils parlent). Articles agree with gender: le/la/les for definite, un/une/des for indefinite.';
  a2_grammar_note text := 'Passé composé: auxiliary (avoir / être) + past participle. Most verbs take avoir (j’ai mangé); être is used with reflexive verbs and a fixed list of verbs of motion (aller, venir, arriver…). Past participles with être agree in gender and number with the subject (elle est partie, ils sont partis).';
  b1_grammar_note text := 'Subjunctive present after expressions of wish, doubt or emotion: que + subjunctive. Common triggers: il faut que, je veux que, j’ai peur que, bien que, pour que. Conjugation: take the ils/elles form of present indicative, drop -ent and add subjunctive endings (-e, -es, -e, -ions, -iez, -ent). Si-clauses Type 2: Si + imperfect → conditional present (Si j’avais le temps, je voyagerais).';
  b2_grammar_note text := 'Conditional past (j’aurais aimé, nous aurions dû) + plus-que-parfait du subjonctif and complex Si-clauses: Type 3 — Si + plus-que-parfait → conditional past (Si j’avais étudié plus, j’aurais réussi). Concessive subjunctive after bien que, quoique, à condition que. Advanced connectors: néanmoins, en revanche, par conséquent, en effet.';
  c1_grammar_note text := 'Advanced syntactic patterns: cleft sentences (C’est X qui…), inversion in formal register, subjunctive after impersonal expressions of opinion (il est possible que, il est inadmissible que), conditional with rhetorical force, subjunctive imperfect in highly formal writing, sequence of tenses across embedded clauses.';

  -- Per-level dialogue jsonb (used as the lesson 3 "phrases" dialogue and as
  -- a richer dialogue for several other lesson types).
  a1_dialogue jsonb := '[{"speaker":"Marie","spanish":"Bonjour, comment ça va?","english":"Hello, how are you?"},{"speaker":"Paul","spanish":"Ça va bien, merci. Et toi?","english":"I’m fine, thanks. And you?"},{"speaker":"Marie","spanish":"Très bien. Tu fais quoi ce soir?","english":"Very well. What are you doing tonight?"},{"speaker":"Paul","spanish":"Je vais au cinéma avec ma sœur.","english":"I’m going to the cinema with my sister."}]'::jsonb;
  a2_dialogue jsonb := '[{"speaker":"Léa","spanish":"Tu as fait quoi le week-end dernier?","english":"What did you do last weekend?"},{"speaker":"Marc","spanish":"Je suis allé à la mer avec mes amis. C’était super!","english":"I went to the seaside with my friends. It was great!"},{"speaker":"Léa","spanish":"Vous avez voyagé en train ou en voiture?","english":"Did you travel by train or by car?"},{"speaker":"Marc","spanish":"En train. C’est plus rapide et plus écologique.","english":"By train. It’s faster and greener."}]'::jsonb;
  b1_dialogue jsonb := '[{"speaker":"Sophie","spanish":"Cependant, je pense que voyager seul peut être enrichissant.","english":"However, I think travelling alone can be enriching."},{"speaker":"Julien","spanish":"Tu as raison, mais il faut aussi être prudent.","english":"You’re right, but you also have to be careful."},{"speaker":"Sophie","spanish":"Si j’avais plus de temps, je partirais six mois en Asie.","english":"If I had more time, I’d go to Asia for six months."},{"speaker":"Julien","spanish":"Et qu’est-ce qui te retient cette année?","english":"And what’s holding you back this year?"}]'::jsonb;
  b2_dialogue jsonb := '[{"speaker":"Nicolas","spanish":"Toutefois, je doute que cette politique soit efficace à long terme.","english":"However, I doubt that this policy will be effective in the long term."},{"speaker":"Amélie","spanish":"Il faudrait que les acteurs économiques jouent le jeu, sinon rien ne changera.","english":"Economic actors would have to play along, otherwise nothing will change."},{"speaker":"Nicolas","spanish":"Cependant, soulignons les progrès accomplis depuis dix ans.","english":"However, let us emphasise the progress made over the past ten years."},{"speaker":"Amélie","spanish":"Certes, par conséquent il convient de rester prudent.","english":"Certainly, consequently we should remain cautious."}]'::jsonb;
  c1_dialogue jsonb := '[{"speaker":"Professeur","spanish":"Nonobstant la complexité du sujet, il convient d’en appréhender les enjeux sous-jacents.","english":"Notwithstanding the complexity of the subject, it is appropriate to grasp its underlying issues."},{"speaker":"Étudiante","spanish":"Auriez-vous des références qui étayent cette analyse?","english":"Would you have references that substantiate this analysis?"},{"speaker":"Professeur","spanish":"Bien évidemment. Je vous renvoie aux travaux récents publiés dans la revue.","english":"Of course. I refer you to the recent work published in the journal."},{"speaker":"Étudiante","spanish":"Merci. Je m’y plongerai dès ce soir.","english":"Thank you. I’ll delve into them this evening."}]'::jsonb;

  -- Reading passages per level (used in lesson 6).
  a1_reading_passage text := 'Je m’appelle Sophie. J’ai vingt-cinq ans et j’habite à Paris. Le matin, je vais au travail en bus. Le soir, j’étudie l’anglais. Le week-end, je rends visite à mes parents à la campagne.';
  a2_reading_passage text := 'L’année dernière, j’ai changé de travail. Avant, je travaillais dans un petit bureau et je m’ennuyais. J’ai trouvé un poste dans une entreprise internationale qui offre des opportunités de voyage. Au début, c’était difficile, mais maintenant je suis content car j’ai appris beaucoup de choses.';
  b1_reading_passage text := 'De plus en plus de jeunes décident d’étudier ou de travailler à l’étranger après leurs études. Les raisons sont variées: beaucoup cherchent de meilleurs salaires, d’autres veulent apprendre une langue ou découvrir une nouvelle culture. Cependant, cette tendance inquiète certains experts qui craignent une perte de talents difficile à compenser. C’est pourquoi plusieurs gouvernements ont commencé à proposer des incitations pour faire revenir ces jeunes.';
  b2_reading_passage text := 'L’intelligence artificielle générative bouleverse le monde créatif avec une rapidité inattendue. Pour certains, ce n’est qu’un outil de plus, comparable à l’ordinateur en son temps; d’autres dénoncent un appauvrissement du travail humain. Le débat n’est pas uniquement économique: lorsque la machine produit des œuvres conformes aux standards de qualité, elle remet en cause l’idée même d’auteur et d’originalité. Il est probable que la discussion se prolonge encore longtemps.';
  c1_reading_passage text := 'La discussion autour du modèle de la « ville du quart d’heure » se formule depuis des décennies dans les cercles urbanistiques. Elle n’a toutefois trouvé un véritable écho politique qu’au cours des dernières années. Ses défenseurs soulignent qu’avoir école, travail, commerces et loisirs à quinze minutes à pied réduit les émissions, améliore la santé publique et favorise une sociabilité que la motorisation massive avait reléguée. Pourtant, ses détracteurs ont ouvert un front inattendu: certains y voient une restriction déguisée de la liberté de mouvement, allant jusqu’à associer le modèle à des thèses conspirationnistes. Le débat dépasse donc le champ technique et devient profondément culturel et symbolique.';
begin
  select id into v_lang_id from public.languages where code = 'french';
  if v_lang_id is null then raise exception 'French language not found in public.languages'; end if;

  -- Wipe any existing French content so the migration is idempotent.
  delete from public.courses where language_id = v_lang_id;

  for v_idx in 1..5 loop
    case v_idx
      when 1 then v_level := 'A1'; v_sections := a1_sections; v_sections_en := a1_sections_en; v_xp := 10;
      when 2 then v_level := 'A2'; v_sections := a2_sections; v_sections_en := a2_sections_en; v_xp := 15;
      when 3 then v_level := 'B1'; v_sections := b1_sections; v_sections_en := b1_sections_en; v_xp := 20;
      when 4 then v_level := 'B2'; v_sections := b2_sections; v_sections_en := b2_sections_en; v_xp := 25;
      when 5 then v_level := 'C1'; v_sections := c1_sections; v_sections_en := c1_sections_en; v_xp := 30;
    end case;

    for i in 1..15 loop
      v_section    := v_sections[i];
      v_section_en := v_sections_en[i];
      -- Alternating podcast / video description for lesson 8.
      v_podcast_desc := case when i % 2 = 1
        then 'Listen to a short French podcast about ' || v_section_en || '.'
        else 'Watch a short French video about ' || v_section_en || '.'
      end;

      -- Course title + description use the English canonical section name
      -- so translateSectionTitle / translateSectionDescription in i18n.ts
      -- can swap them into the active UI language.
      insert into public.courses (language_id, title, description, cefr_level, order_index)
      values (
        v_lang_id, v_section_en,
        'Build your ' || v_level || ' French skills in ' || v_section_en || '.',
        v_level, i
      )
      returning id into v_course_id;

      -- 8 teaching lessons + 1 unit_test (order_index 9).
      -- Lesson titles use English ('Greetings — Vocabulary') to match Spanish.
      insert into public.lessons (course_id, title, description, type, order_index, xp_reward) values
        (v_course_id, v_section_en || ' — Vocabulary',              'Learn key French vocabulary for ' || v_section_en || '.',         'vocabulary', 1, v_xp),
        (v_course_id, v_section_en || ' — Grammar',                 'Practise the grammar patterns used in ' || v_section_en || '.',    'grammar',    2, v_xp),
        (v_course_id, v_section_en || ' — Phrases & Conversation',  'Common French phrases for ' || v_section_en || '.',                'phrases',    3, v_xp),
        (v_course_id, v_section_en || ' — Listening',               'Listen and respond in French about ' || v_section_en || '.',       'listening',  4, v_xp),
        (v_course_id, v_section_en || ' — Speaking',                'Speak in French about ' || v_section_en || '.',                    'speaking',   5, v_xp),
        (v_course_id, v_section_en || ' — Reading & Comprehension', 'Read a short French text on ' || v_section_en || '.',              'reading',    6, v_xp),
        (v_course_id, v_section_en || ' — Writing',                 'Write a short French text about ' || v_section_en || '.',          'writing',    7, v_xp),
        (v_course_id, v_section_en || ' — Podcast / Video',         v_podcast_desc,                                                      'podcast',    8, v_xp),
        (v_course_id, 'Section Test: ' || v_section_en,             'Review test for ' || v_section_en || '. Pass with 7/10 to earn 50 XP.', 'unit_test', 9, 50);

      ----------------------------------------------------------------
      -- TEACHING CONTENT — set intro / vocab_items / dialogue / grammar
      ----------------------------------------------------------------

      -- Lesson 1 (vocabulary): section-themed vocab for A1; level-templated for higher.
      update public.lessons set
        intro = case v_level
          when 'A1' then 'Apprenons quelques mots clés liés à ' || v_section || '. Lisez les exemples à voix haute pour vous habituer à la prononciation.'
          else 'Enrichissons votre vocabulaire ' || v_level || ' avec des mots utiles pour parler de ' || v_section || ' et plus encore.'
        end,
        vocab_items = case v_level
          when 'A1' then a1_vocab[i]
          when 'A2' then a2_vocab
          when 'B1' then b1_vocab
          when 'B2' then b2_vocab
          when 'C1' then c1_vocab
        end,
        dialogue = case v_level
          when 'A1' then a1_dialogue
          when 'A2' then a2_dialogue
          when 'B1' then b1_dialogue
          when 'B2' then b2_dialogue
          when 'C1' then c1_dialogue
        end,
        grammar_note = case v_level
          when 'A1' then a1_grammar_note
          when 'A2' then a2_grammar_note
          when 'B1' then b1_grammar_note
          when 'B2' then b2_grammar_note
          when 'C1' then c1_grammar_note
        end
      where course_id = v_course_id and order_index = 1;

      -- Lesson 2 (grammar): intro + grammar_note.
      update public.lessons set
        intro = 'Travaillons la grammaire ' || v_level || ' au service de ' || v_section || '. Faites attention aux exemples.',
        grammar_note = case v_level
          when 'A1' then a1_grammar_note
          when 'A2' then a2_grammar_note
          when 'B1' then b1_grammar_note
          when 'B2' then b2_grammar_note
          when 'C1' then c1_grammar_note
        end,
        dialogue = case v_level
          when 'A1' then a1_dialogue
          when 'A2' then a2_dialogue
          when 'B1' then b1_dialogue
          when 'B2' then b2_dialogue
          when 'C1' then c1_dialogue
        end
      where course_id = v_course_id and order_index = 2;

      -- Lesson 3 (phrases): dialogue is the centrepiece.
      update public.lessons set
        intro = 'Découvrons quelques expressions et un court dialogue autour de ' || v_section || '.',
        dialogue = case v_level
          when 'A1' then a1_dialogue
          when 'A2' then a2_dialogue
          when 'B1' then b1_dialogue
          when 'B2' then b2_dialogue
          when 'C1' then c1_dialogue
        end
      where course_id = v_course_id and order_index = 3;

      -- Lesson 4 (listening): short intro + dialogue for context.
      update public.lessons set
        intro = 'Entraînons-nous à l’oral. Écoutez attentivement et répondez en français. Vous pouvez réécouter autant de fois que nécessaire.',
        dialogue = case v_level
          when 'A1' then a1_dialogue
          when 'A2' then a2_dialogue
          when 'B1' then b1_dialogue
          when 'B2' then b2_dialogue
          when 'C1' then c1_dialogue
        end
      where course_id = v_course_id and order_index = 4;

      -- Lesson 5 (speaking)
      update public.lessons set
        intro = 'À votre tour de parler! Activez le micro et exprimez-vous en français de manière naturelle.'
      where course_id = v_course_id and order_index = 5;

      -- Lesson 6 (reading): use the per-level passage as intro so the student sees it.
      update public.lessons set
        intro = case v_level
          when 'A1' then a1_reading_passage
          when 'A2' then a2_reading_passage
          when 'B1' then b1_reading_passage
          when 'B2' then b2_reading_passage
          when 'C1' then c1_reading_passage
        end
      where course_id = v_course_id and order_index = 6;

      -- Lesson 7 (writing)
      update public.lessons set
        intro = 'Exercez-vous à l’écrit. Soignez la grammaire, l’orthographe et la richesse du vocabulaire.'
      where course_id = v_course_id and order_index = 7;

      -- Lesson 8 (podcast / video)
      update public.lessons set
        intro = v_podcast_desc
      where course_id = v_course_id and order_index = 8;

    end loop;
  end loop;
end $$;

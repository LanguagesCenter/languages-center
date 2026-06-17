-- 050_french_course_titles_english.sql
-- Switch French course/lesson TITLES and DESCRIPTIONS to the English
-- canonical strings the i18n layer already translates (see translateSectionTitle
-- / translateSectionDescription in src/lib/i18n.ts). Teaching CONTENT
-- (intros, vocab, dialogue, grammar notes) stays in French — only the
-- DB metadata fields change so the UI can render section names in whichever
-- site language the user picked.
--
-- Idempotent: each UPDATE is gated by the current French value, so re-running
-- after rows have already been renamed is a no-op.

do $$
declare
  v_lang_id bigint;
  -- French ↔ English section-name pairs. Must match the Spanish course's
  -- English titles exactly (see 015_spanish_restructure_15x8.sql) so both
  -- courses share the same translation slug.
  pairs text[][] := array[
    -- A1
    ['Salutations',                        'Greetings'],
    ['Nombres',                            'Numbers'],
    ['Couleurs',                           'Colors'],
    ['Famille',                            'Family'],
    ['Nourriture',                         'Food'],
    ['Heure',                              'Time'],
    ['Météo',                              'Weather'],
    ['Courses',                            'Shopping'],
    ['Animaux',                            'Animals'],
    ['Parties du corps',                   'Body Parts'],
    ['Vêtements',                          'Clothes'],
    ['Maison',                             'House & Home'],
    ['Transports',                         'Transport'],
    ['Jours et mois',                      'Days & Months'],
    ['Verbes de base',                     'Basic Verbs'],
    -- A2
    ['Routines quotidiennes',              'Daily Routines'],
    ['Santé et corps',                     'Health & Body'],
    ['Loisirs',                            'Hobbies'],
    ['Travail et emploi',                  'Work & Jobs'],
    ['Itinéraires',                        'Directions'],
    ['Sentiments et émotions',             'Feelings & Emotions'],
    ['Fêtes',                              'Celebrations'],
    ['Nature',                             'Nature'],
    ['Sports',                             'Sports'],
    ['Musique',                            'Music'],
    ['Préparation de voyage',              'Travel Planning'],
    ['Restaurants',                        'Restaurants'],
    ['École',                              'School'],
    ['Bases de la technologie',            'Technology Basics'],
    ['Réseaux sociaux',                    'Social Media'],
    -- B1
    ['Voyages et tourisme',                'Travel & Tourism'],
    ['Actualités et médias',               'News & Media'],
    ['Environnement',                      'Environment'],
    ['Relations',                          'Relationships'],
    ['Culture et traditions',              'Culture & Traditions'],
    ['Argent et banques',                  'Money & Banking'],
    ['Éducation',                          'Education'],
    ['Politique de base',                  'Politics Basics'],
    ['Cuisine',                            'Food & Cooking'],
    ['Art et littérature',                 'Art & Literature'],
    ['Santé et médecine',                  'Health & Medicine'],
    ['Bases du business',                  'Business Basics'],
    ['Sports et fitness',                  'Sports & Fitness'],
    ['Musique et divertissement',          'Music & Entertainment'],
    ['Bases des sciences',                 'Science Basics'],
    -- B2
    ['Politique et société',               'Politics & Society'],
    ['Technologie et innovation',          'Technology & Innovation'],
    ['Philosophie et éthique',             'Philosophy & Ethics'],
    ['Littérature et poésie',              'Literature & Poetry'],
    ['Économie et affaires',               'Business & Economics'],
    ['Sciences et recherche',              'Science & Research'],
    ['Arts et culture',                    'Arts & Culture'],
    ['Médias et journalisme',              'Media & Journalism'],
    ['Droit et justice',                   'Law & Justice'],
    ['Histoire',                           'History'],
    ['Psychologie',                        'Psychology'],
    ['Architecture',                       'Architecture'],
    ['Mode et design',                     'Fashion & Design'],
    ['Analyse sportive',                   'Sports Analysis'],
    ['Enjeux environnementaux',            'Environmental Issues'],
    -- C1
    ['Expressions idiomatiques',           'Idioms & Expressions'],
    ['Grammaire avancée',                  'Advanced Grammar'],
    ['Écriture formelle',                  'Formal Writing'],
    ['Débat et discussion',                'Debate & Discussion'],
    ['Contenu natif',                      'Native Content'],
    ['Langue académique',                  'Academic Language'],
    ['Communication professionnelle',      'Professional Communication'],
    ['Nuances culturelles',                'Cultural Nuance'],
    ['Rhétorique et persuasion',           'Rhetoric & Persuasion'],
    ['Littérature avancée',                'Advanced Literature'],
    ['Structures grammaticales complexes', 'Complex Grammar Structures'],
    ['Dialectes régionaux',                'Regional Dialects'],
    ['Argot et langue informelle',         'Slang & Informal Language'],
    ['Compétences de traduction',          'Translation Skills'],
    ['Enseignement des langues',           'Language Teaching']
  ];
  i int;
  fr_section text;
  en_section text;
begin
  select id into v_lang_id from public.languages where code = 'french';
  if v_lang_id is null then raise exception 'French language not found'; end if;

  -- 1) Per-section renames: course title + course description + lesson title prefix
  --    + unit_test lesson title + unit_test description + every lesson description
  --    that mentions the section name.
  for i in 1..array_length(pairs, 1) loop
    fr_section := pairs[i][1];
    en_section := pairs[i][2];

    -- Course title + description.
    update public.courses
       set title = en_section,
           description = 'Build your ' || cefr_level || ' French skills in ' || en_section || '.'
     where language_id = v_lang_id and title = fr_section;

    -- Teaching lessons: replace the French section prefix with the English one
    -- (the type suffix is handled in step 2 below).
    update public.lessons l
       set title = en_section || substring(l.title from char_length(fr_section) + 1)
     where l.course_id in (select id from public.courses where language_id = v_lang_id)
       and l.title like fr_section || ' — %';

    -- Unit-test lesson: 'Section Test: <Section>'.
    update public.lessons l
       set title = 'Section Test: ' || en_section,
           description = 'Review test for ' || en_section || '. Pass with 7/10 to earn 50 XP.'
     where l.course_id in (select id from public.courses where language_id = v_lang_id)
       and l.title = 'Section Test: ' || fr_section;

    -- Lesson descriptions that mention the section name verbatim.
    update public.lessons l
       set description = replace(l.description, fr_section, en_section)
     where l.course_id in (select id from public.courses where language_id = v_lang_id)
       and l.description like '%' || fr_section || '%';
  end loop;

  -- 2) Replace French lesson-type suffixes with the English canonical forms
  --    that the Spanish course already uses, so every lesson reads
  --    '<English Section> — <English Type>'.
  update public.lessons l
     set title = replace(l.title, ' — Vocabulaire', ' — Vocabulary')
   where l.course_id in (select id from public.courses where language_id = v_lang_id)
     and l.title like '% — Vocabulaire';

  update public.lessons l
     set title = replace(l.title, ' — Grammaire', ' — Grammar')
   where l.course_id in (select id from public.courses where language_id = v_lang_id)
     and l.title like '% — Grammaire';

  update public.lessons l
     set title = replace(l.title, ' — Expressions', ' — Phrases & Conversation')
   where l.course_id in (select id from public.courses where language_id = v_lang_id)
     and l.title like '% — Expressions';

  update public.lessons l
     set title = replace(l.title, ' — Compréhension orale', ' — Listening')
   where l.course_id in (select id from public.courses where language_id = v_lang_id)
     and l.title like '% — Compréhension orale';

  update public.lessons l
     set title = replace(l.title, ' — Expression orale', ' — Speaking')
   where l.course_id in (select id from public.courses where language_id = v_lang_id)
     and l.title like '% — Expression orale';

  update public.lessons l
     set title = replace(l.title, ' — Lecture', ' — Reading & Comprehension')
   where l.course_id in (select id from public.courses where language_id = v_lang_id)
     and l.title like '% — Lecture';

  update public.lessons l
     set title = replace(l.title, ' — Écriture', ' — Writing')
   where l.course_id in (select id from public.courses where language_id = v_lang_id)
     and l.title like '% — Écriture';

  update public.lessons l
     set title = replace(l.title, ' — Podcast / Vidéo', ' — Podcast / Video')
   where l.course_id in (select id from public.courses where language_id = v_lang_id)
     and l.title like '% — Podcast / Vidéo';
end $$;

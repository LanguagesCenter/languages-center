-- 015_spanish_restructure_15x8.sql
-- Restructure Spanish to 5 CEFR levels x 15 sections x 8 lessons each.
--
-- WHAT THIS DOES
--   1. Extends public.lessons.type check to allow 'reading', 'writing', 'podcast'.
--   2. Wipes ALL Spanish courses (cascades to lessons + exercises).
--      Articles stay (they are tied to language_id, not course_id).
--   3. Reseeds 75 courses + 600 lesson skeletons under the new structure.
--      Each lesson gets a title, description, type and xp_reward but zero
--      exercises. The UI already handles empty lessons gracefully.
--   4. Lesson 8 of every section carries the "Content coming soon" placeholder.
--
-- WHAT THIS DOES NOT DO
--   Does not add exercise rows for the new lessons. Real exercise content
--   will be backfilled in follow-up migrations (016_spanish_a1, etc.) one
--   CEFR level at a time.
--
-- Idempotent: safe to run again. Wipes Spanish courses and reseeds.

alter table public.lessons drop constraint if exists lessons_type_check;
alter table public.lessons
  add constraint lessons_type_check
  check (type in ('vocabulary','grammar','phrases','listening','speaking','reading','writing','podcast'));

do $$
declare
  v_lang_id       bigint;
  v_course_id     bigint;
  v_podcast_desc  text := 'Content coming soon - Premium subscribers will get access to curated podcast and video content for this topic.';
  v_level         text;
  v_section       text;
  v_xp            int;
  v_sections      text[];
  i               int;
  v_idx           int;
  a1_sections text[] := array[
    'Greetings','Numbers','Colors','Family','Food','Time','Weather','Shopping',
    'Animals','Body Parts','Clothes','House & Home','Transport','Days & Months','Basic Verbs'
  ];
  a2_sections text[] := array[
    'Daily Routines','Health & Body','Hobbies','Work & Jobs','Directions',
    'Feelings & Emotions','Celebrations','Nature','Sports','Music',
    'Travel Planning','Restaurants','School','Technology Basics','Social Media'
  ];
  b1_sections text[] := array[
    'Travel & Tourism','News & Media','Environment','Relationships','Culture & Traditions',
    'Money & Banking','Education','Politics Basics','Food & Cooking','Art & Literature',
    'Health & Medicine','Business Basics','Sports & Fitness','Music & Entertainment','Science Basics'
  ];
  b2_sections text[] := array[
    'Politics & Society','Technology & Innovation','Philosophy & Ethics','Literature & Poetry',
    'Business & Economics','Science & Research','Arts & Culture','Media & Journalism',
    'Law & Justice','History','Psychology','Architecture','Fashion & Design',
    'Sports Analysis','Environmental Issues'
  ];
  c1_sections text[] := array[
    'Idioms & Expressions','Advanced Grammar','Formal Writing','Debate & Discussion','Native Content',
    'Academic Language','Professional Communication','Cultural Nuance','Rhetoric & Persuasion',
    'Advanced Literature','Complex Grammar Structures','Regional Dialects','Slang & Informal Language',
    'Translation Skills','Language Teaching'
  ];
begin
  select id into v_lang_id from public.languages where code = 'spanish';
  if v_lang_id is null then
    raise exception 'Spanish language not found in public.languages';
  end if;

  -- Wipe Spanish courses (cascades to lessons + exercises).
  delete from public.courses where language_id = v_lang_id;

  for v_idx in 1..5 loop
    case v_idx
      when 1 then v_level := 'A1'; v_sections := a1_sections; v_xp := 10;
      when 2 then v_level := 'A2'; v_sections := a2_sections; v_xp := 15;
      when 3 then v_level := 'B1'; v_sections := b1_sections; v_xp := 20;
      when 4 then v_level := 'B2'; v_sections := b2_sections; v_xp := 25;
      when 5 then v_level := 'C1'; v_sections := c1_sections; v_xp := 30;
    end case;

    for i in 1..15 loop
      v_section := v_sections[i];

      insert into public.courses (language_id, title, description, cefr_level, order_index)
      values (
        v_lang_id,
        v_section,
        'Build your ' || v_level || ' Spanish skills in ' || v_section || '.',
        v_level,
        i
      )
      returning id into v_course_id;

      insert into public.lessons (course_id, title, description, type, order_index, xp_reward) values
        (v_course_id, v_section || ' — Vocabulary',              'Learn key Spanish vocabulary for ' || v_section || '.',                'vocabulary', 1, v_xp),
        (v_course_id, v_section || ' — Grammar',                 'Practise the grammar patterns used in ' || v_section || '.',           'grammar',    2, v_xp),
        (v_course_id, v_section || ' — Phrases & Conversation',  'Common phrases and short dialogues for ' || v_section || '.',          'phrases',    3, v_xp),
        (v_course_id, v_section || ' — Listening',               'Hear and recognise ' || v_section || ' in spoken Spanish.',            'listening',  4, v_xp),
        (v_course_id, v_section || ' — Speaking',                'Say ' || v_section || ' phrases out loud.',                            'speaking',   5, v_xp),
        (v_course_id, v_section || ' — Reading & Comprehension', 'Read and understand a short Spanish text on ' || v_section || '.',     'reading',    6, v_xp),
        (v_course_id, v_section || ' — Writing',                 'Compose your own short text about ' || v_section || ' in Spanish.',    'writing',    7, v_xp),
        (v_course_id, v_section || ' — Podcast / Video',         v_podcast_desc,                                                          'podcast',    8, v_xp);
    end loop;
  end loop;
end $$;

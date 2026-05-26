-- ============================================================
-- Languages Center — CEFR redesign
-- Run this AFTER 001_schema.sql + 002_seed_and_rpc.sql (or the
-- consolidated 003_complete_install.sql). It does the following:
--
--   1. Adds cefr_level to public.courses (A1..C1)
--   2. Creates new tables: articles, podcasts, videos
--   3. Wipes existing course/lesson/exercise rows (user_progress cascades)
--   4. Reseeds 12 languages with the CEFR-scale section structure:
--        A1 — 8 sections   A2 — 8 sections
--        B1 — 7 sections   B2 — 7 sections
--        C1 — 5 sections   (35 sections per language)
--      Each section: 4 lessons. Each lesson: 3 exercises
--        (multiple_choice, listening, speaking).
--   5. Seeds 3 articles per language (A1, B1, C1)
--   6. Seeds 3 podcasts + 3 videos per language (all flagged premium)
--
-- Safe to re-run.
-- ============================================================

-- ---------- 1. Schema changes ----------

alter table public.courses drop constraint if exists courses_cefr_level_check;
alter table public.courses add column if not exists cefr_level text;
-- Existing rows would have null cefr_level; we wipe them in step 3 anyway.
alter table public.courses
  add constraint courses_cefr_level_check
  check (cefr_level is null or cefr_level in ('A1','A2','B1','B2','C1'));

create table if not exists public.articles (
  id bigint generated always as identity primary key,
  language_id bigint not null references public.languages(id) on delete cascade,
  slug text not null,
  title text not null,
  title_english text not null,
  level text not null check (level in ('A1','A2','B1','B2','C1')),
  reading_minutes int not null default 5,
  content_target text not null,
  content_english text not null,
  order_index int not null,
  created_at timestamptz default now(),
  unique(language_id, slug)
);

create table if not exists public.podcasts (
  id bigint generated always as identity primary key,
  language_id bigint not null references public.languages(id) on delete cascade,
  title text not null,
  description text,
  duration_minutes int not null default 15,
  level text not null check (level in ('A1','A2','B1','B2','C1')),
  is_premium boolean not null default true,
  order_index int not null,
  created_at timestamptz default now()
);

create table if not exists public.videos (
  id bigint generated always as identity primary key,
  language_id bigint not null references public.languages(id) on delete cascade,
  title text not null,
  description text,
  duration_minutes int not null default 10,
  level text not null check (level in ('A1','A2','B1','B2','C1')),
  is_premium boolean not null default true,
  order_index int not null,
  created_at timestamptz default now()
);

create index if not exists idx_articles_language on public.articles(language_id);
create index if not exists idx_podcasts_language on public.podcasts(language_id);
create index if not exists idx_videos_language   on public.videos(language_id);

alter table public.articles enable row level security;
alter table public.podcasts enable row level security;
alter table public.videos   enable row level security;

drop policy if exists "Articles are viewable by everyone" on public.articles;
drop policy if exists "Podcasts are viewable by everyone" on public.podcasts;
drop policy if exists "Videos are viewable by everyone"   on public.videos;
create policy "Articles are viewable by everyone" on public.articles for select using (true);
create policy "Podcasts are viewable by everyone" on public.podcasts for select using (true);
create policy "Videos are viewable by everyone"   on public.videos   for select using (true);

-- ---------- 2. Wipe legacy course content ----------

delete from public.exercises;
delete from public.lessons;
delete from public.courses;

-- Lock cefr_level NOT NULL now that legacy rows are gone
alter table public.courses alter column cefr_level set not null;

-- ---------- 3. Reseed courses + lessons + exercises ----------

do $cefr_seed$
declare
  lang record;
  section_idx int;
  lesson_idx int;
  section_title text;
  section_desc text;
  course_id bigint;
  lesson_id bigint;
  current_level text;
  sections_in_level text[];
  level_loop int;
  -- Section definitions per CEFR level
  a1_sections text[] := array['Greetings','Numbers','Colors','Family','Food','Time','Weather','Shopping'];
  a2_sections text[] := array['Daily Routines','Transport','Health','Hobbies','Work','Directions','Feelings','Celebrations'];
  b1_sections text[] := array['Travel','News & Media','Environment','Relationships','Culture','Money','Education'];
  b2_sections text[] := array['Politics','Technology','Philosophy','Literature','Business','Science','Arts'];
  c1_sections text[] := array['Idioms & Expressions','Advanced Grammar','Formal Writing','Debate & Discussion','Native Content'];
  -- Per-language vocab for A1 Greetings/Numbers/Colors (other A1 sections + A2..C1 use templates)
  v_hello text;
  v_thanks text;
  v_goodbye text;
  v_please text := 'Please';
  v_n1 text;
  v_n2 text;
  v_n3 text;
  v_n4 text;
  v_red text;
  v_blue text;
  v_green text;
  v_yellow text;
begin
  for lang in select id, code, name from public.languages order by id loop

    case lang.code
      when 'spanish' then
        v_hello := 'Hola'; v_thanks := 'Gracias'; v_goodbye := 'Adiós';
        v_n1 := 'Uno'; v_n2 := 'Dos'; v_n3 := 'Tres'; v_n4 := 'Cuatro';
        v_red := 'Rojo'; v_blue := 'Azul'; v_green := 'Verde'; v_yellow := 'Amarillo';
      when 'french' then
        v_hello := 'Bonjour'; v_thanks := 'Merci'; v_goodbye := 'Au revoir';
        v_n1 := 'Un'; v_n2 := 'Deux'; v_n3 := 'Trois'; v_n4 := 'Quatre';
        v_red := 'Rouge'; v_blue := 'Bleu'; v_green := 'Vert'; v_yellow := 'Jaune';
      when 'german' then
        v_hello := 'Hallo'; v_thanks := 'Danke'; v_goodbye := 'Tschuess';
        v_n1 := 'Eins'; v_n2 := 'Zwei'; v_n3 := 'Drei'; v_n4 := 'Vier';
        v_red := 'Rot'; v_blue := 'Blau'; v_green := 'Gruen'; v_yellow := 'Gelb';
      when 'greek' then
        v_hello := 'Γεια'; v_thanks := 'Ευχαριστώ'; v_goodbye := 'Αντίο';
        v_n1 := 'Ένα'; v_n2 := 'Δύο'; v_n3 := 'Τρία'; v_n4 := 'Τέσσερα';
        v_red := 'Κόκκινο'; v_blue := 'Μπλε'; v_green := 'Πράσινο'; v_yellow := 'Κίτρινο';
      when 'swedish' then
        v_hello := 'Hej'; v_thanks := 'Tack'; v_goodbye := 'Hej da';
        v_n1 := 'Ett'; v_n2 := 'Tva'; v_n3 := 'Tre'; v_n4 := 'Fyra';
        v_red := 'Rod'; v_blue := 'Bla'; v_green := 'Gron'; v_yellow := 'Gul';
      when 'danish' then
        v_hello := 'Hej'; v_thanks := 'Tak'; v_goodbye := 'Farvel';
        v_n1 := 'En'; v_n2 := 'To'; v_n3 := 'Tre'; v_n4 := 'Fire';
        v_red := 'Rod'; v_blue := 'Bla'; v_green := 'Gron'; v_yellow := 'Gul';
      when 'finnish' then
        v_hello := 'Hei'; v_thanks := 'Kiitos'; v_goodbye := 'Nakemiin';
        v_n1 := 'Yksi'; v_n2 := 'Kaksi'; v_n3 := 'Kolme'; v_n4 := 'Nelja';
        v_red := 'Punainen'; v_blue := 'Sininen'; v_green := 'Vihrea'; v_yellow := 'Keltainen';
      when 'albanian' then
        v_hello := 'Pershendetje'; v_thanks := 'Faleminderit'; v_goodbye := 'Mirupafshim';
        v_n1 := 'Nje'; v_n2 := 'Dy'; v_n3 := 'Tre'; v_n4 := 'Kater';
        v_red := 'E kuqe'; v_blue := 'Blu'; v_green := 'E gjelber'; v_yellow := 'E verdhe';
      when 'icelandic' then
        v_hello := 'Hallo'; v_thanks := 'Takk'; v_goodbye := 'Bless';
        v_n1 := 'Einn'; v_n2 := 'Tveir'; v_n3 := 'Thrir'; v_n4 := 'Fjorir';
        v_red := 'Raudur'; v_blue := 'Blar'; v_green := 'Graenn'; v_yellow := 'Gulur';
      when 'faroese' then
        v_hello := 'Hallo'; v_thanks := 'Takk'; v_goodbye := 'Farvael';
        v_n1 := 'Ein'; v_n2 := 'Tveir'; v_n3 := 'Triggir'; v_n4 := 'Fyra';
        v_red := 'Reydur'; v_blue := 'Blar'; v_green := 'Gronur'; v_yellow := 'Gulur';
      when 'corsican' then
        v_hello := 'Bonghjornu'; v_thanks := 'Grazie'; v_goodbye := 'Avvedeci';
        v_n1 := 'Unu'; v_n2 := 'Dui'; v_n3 := 'Tre'; v_n4 := 'Quattru';
        v_red := 'Rossu'; v_blue := 'Blu'; v_green := 'Verde'; v_yellow := 'Giallu';
      when 'english' then
        v_hello := 'Hello'; v_thanks := 'Thanks'; v_goodbye := 'Goodbye';
        v_n1 := 'One'; v_n2 := 'Two'; v_n3 := 'Three'; v_n4 := 'Four';
        v_red := 'Red'; v_blue := 'Blue'; v_green := 'Green'; v_yellow := 'Yellow';
      else
        v_hello := 'Hello'; v_thanks := 'Thanks'; v_goodbye := 'Goodbye';
        v_n1 := 'One'; v_n2 := 'Two'; v_n3 := 'Three'; v_n4 := 'Four';
        v_red := 'Red'; v_blue := 'Blue'; v_green := 'Green'; v_yellow := 'Yellow';
    end case;

    for level_loop in 1..5 loop
      case level_loop
        when 1 then current_level := 'A1'; sections_in_level := a1_sections;
        when 2 then current_level := 'A2'; sections_in_level := a2_sections;
        when 3 then current_level := 'B1'; sections_in_level := b1_sections;
        when 4 then current_level := 'B2'; sections_in_level := b2_sections;
        when 5 then current_level := 'C1'; sections_in_level := c1_sections;
      end case;

      for section_idx in 1..array_length(sections_in_level, 1) loop
        section_title := sections_in_level[section_idx];
        section_desc := 'Build your ' || current_level || ' ' || lang.name || ' skills in ' || section_title || '.';

        insert into public.courses (language_id, title, description, cefr_level, order_index)
        values (lang.id, section_title, section_desc, current_level, section_idx)
        returning id into course_id;

        for lesson_idx in 1..4 loop
          insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
          values (
            course_id,
            section_title || ' — Lesson ' || lesson_idx,
            'Practice ' || section_title || ' in ' || lang.name,
            case lesson_idx when 1 then 'vocabulary' when 2 then 'phrases' when 3 then 'listening' else 'speaking' end,
            lesson_idx,
            10 + (level_loop - 1) * 5
          )
          returning id into lesson_id;

          -- 3 exercises per lesson: multiple_choice, listening, speaking.
          -- A1 Greetings/Numbers/Colors use real per-language vocab.
          if current_level = 'A1' and section_title = 'Greetings' then
            insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
              (lesson_id, 'multiple_choice',
                'How do you say Hello in ' || lang.name,
                v_hello, array[v_thanks, v_goodbye, v_please], 'Hello', 1),
              (lesson_id, 'listening',
                'Listen and pick the ' || lang.name || ' word you hear',
                v_hello, array[v_thanks, v_goodbye, v_please], 'Hello', 2),
              (lesson_id, 'speaking',
                'Say it out loud in ' || lang.name,
                v_hello, '{}'::text[], 'Hello', 3);
          elsif current_level = 'A1' and section_title = 'Numbers' then
            insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
              (lesson_id, 'multiple_choice',
                'Which is the number three in ' || lang.name,
                v_n3, array[v_n1, v_n2, v_n4], '3', 1),
              (lesson_id, 'listening',
                'Listen and pick the ' || lang.name || ' number you hear',
                v_n2, array[v_n1, v_n3, v_n4], '2', 2),
              (lesson_id, 'speaking',
                'Count out loud in ' || lang.name,
                v_n1 || ' ' || v_n2 || ' ' || v_n3, '{}'::text[], '1, 2, 3', 3);
          elsif current_level = 'A1' and section_title = 'Colors' then
            insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
              (lesson_id, 'multiple_choice',
                'Which is red in ' || lang.name,
                v_red, array[v_blue, v_green, v_yellow], 'Red', 1),
              (lesson_id, 'listening',
                'Listen and pick the ' || lang.name || ' colour you hear',
                v_green, array[v_red, v_blue, v_yellow], 'Green', 2),
              (lesson_id, 'speaking',
                'Say the three colours in ' || lang.name,
                v_red || ' ' || v_blue || ' ' || v_green, '{}'::text[], 'Red Blue Green', 3);
          else
            -- Generic templated content for everything else.
            insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
              (lesson_id, 'multiple_choice',
                'Which ' || lang.name || ' phrase best fits the ' || section_title || ' context',
                section_title || ' core phrase',
                array[section_title || ' option B', section_title || ' option C', section_title || ' option D'],
                section_title || ' vocabulary',
                1),
              (lesson_id, 'listening',
                'Listen to the ' || lang.name || ' phrase about ' || section_title || ' and pick the meaning',
                section_title || ' core phrase',
                array['Distractor A','Distractor B','Distractor C'],
                section_title || ' listening',
                2),
              (lesson_id, 'speaking',
                'Pronounce the ' || lang.name || ' phrase for ' || section_title,
                section_title || ' core phrase',
                '{}'::text[],
                section_title || ' speaking',
                3);
          end if;
        end loop;
      end loop;
    end loop;
  end loop;
end
$cefr_seed$;

-- ---------- 4. Articles (3 per language) ----------

do $articles_seed$
declare
  lang record;
  art_titles text[]   := array['A Day in the City','Modern Life','A Cultural Journey'];
  art_levels text[]   := array['A1','B1','C1'];
  art_minutes int[]   := array[3, 7, 12];
  i int;
begin
  for lang in select id, code, name from public.languages order by id loop
    delete from public.articles where language_id = lang.id;
    for i in 1..3 loop
      insert into public.articles (language_id, slug, title, title_english, level, reading_minutes, content_target, content_english, order_index)
      values (
        lang.id,
        lower(replace(art_titles[i], ' ', '-')) || '-' || lower(art_levels[i]),
        art_titles[i] || ' (' || lang.name || ')',
        art_titles[i],
        art_levels[i],
        art_minutes[i],
        '[Placeholder ' || lang.name || ' text]. This is a sample article at the ' || art_levels[i] ||
          ' level, demonstrating how an authentic ' || lang.name || ' reading would appear alongside the English translation. ' ||
          'In a production deployment this paragraph would contain real ' || lang.name || ' prose, written by a native speaker.',
        'Placeholder English translation for ' || art_titles[i] || '. This is a sample article at the ' || art_levels[i] ||
          ' level. The two columns let a learner read the ' || lang.name || ' text on one side and check the English meaning on the other, ' ||
          'sentence by sentence. Real production content would replace this placeholder.',
        i
      );
    end loop;
  end loop;
end
$articles_seed$;

-- ---------- 5. Podcasts (3 per language, all premium) ----------

do $podcasts_seed$
declare
  lang record;
  pc_titles text[] := array['Conversational Starter','Native Speaker Stories','Deep Dive Conversations'];
  pc_descs text[] := array[
    'Easy listening for beginners — slow and clear speech with study notes.',
    'Real native speakers sharing daily life stories with a transcript.',
    'Advanced topics discussed by fluent speakers — full transcript and glossary.'
  ];
  pc_levels text[]  := array['A1','B1','C1'];
  pc_mins int[]     := array[10, 20, 35];
  i int;
begin
  for lang in select id, code, name from public.languages order by id loop
    delete from public.podcasts where language_id = lang.id;
    for i in 1..3 loop
      insert into public.podcasts (language_id, title, description, duration_minutes, level, is_premium, order_index)
      values (lang.id, pc_titles[i] || ' — ' || lang.name, pc_descs[i], pc_mins[i], pc_levels[i], true, i);
    end loop;
  end loop;
end
$podcasts_seed$;

-- ---------- 6. Videos (3 per language, all premium) ----------

do $videos_seed$
declare
  lang record;
  vd_titles text[] := array['First Words','Real-Life Scenes','Native Discussions'];
  vd_descs text[] := array[
    'Animated short videos covering essential beginner vocabulary.',
    'Scripted real-life scenes filmed with native pronunciation.',
    'Documentary clips and panel discussions for advanced learners.'
  ];
  vd_levels text[]  := array['A1','B1','C1'];
  vd_mins int[]     := array[5, 12, 25];
  i int;
begin
  for lang in select id, code, name from public.languages order by id loop
    delete from public.videos where language_id = lang.id;
    for i in 1..3 loop
      insert into public.videos (language_id, title, description, duration_minutes, level, is_premium, order_index)
      values (lang.id, vd_titles[i] || ' — ' || lang.name, vd_descs[i], vd_mins[i], vd_levels[i], true, i);
    end loop;
  end loop;
end
$videos_seed$;

-- ============================================================
-- Done. After running this you should have:
--   12 languages
--  420 courses (35 sections × 12 languages)
-- 1680 lessons (4 lessons × 420 courses)
-- 5040 exercises (3 per lesson, with listening + speaking now seeded)
--   36 articles (3 per language)
--   36 podcasts (3 per language, premium)
--   36 videos   (3 per language, premium)
-- ============================================================

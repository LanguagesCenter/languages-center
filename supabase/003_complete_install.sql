-- ============================================================
-- Languages Center — complete schema + content seed
-- Paste this whole file into the Supabase SQL editor and run it.
-- Safe to re-run: schema uses IF NOT EXISTS, languages use
-- ON CONFLICT DO NOTHING, and the content seed skips languages
-- that already have courses.
-- ============================================================

-- ---------- 1. SCHEMA ----------

create table if not exists public.languages (
  id bigint generated always as identity primary key,
  name text not null,
  code text not null unique,
  flag_emoji text,
  difficulty_grammar text not null check (difficulty_grammar in ('Easy','Medium','Hard')),
  difficulty_pronunciation text not null check (difficulty_pronunciation in ('Easy','Medium','Hard')),
  created_at timestamptz default now()
);

create table if not exists public.courses (
  id bigint generated always as identity primary key,
  language_id bigint not null references public.languages(id) on delete cascade,
  title text not null,
  description text,
  order_index int not null,
  created_at timestamptz default now()
);

create table if not exists public.lessons (
  id bigint generated always as identity primary key,
  course_id bigint not null references public.courses(id) on delete cascade,
  title text not null,
  description text,
  type text not null check (type in ('vocabulary','grammar','phrases','listening','speaking')),
  order_index int not null,
  xp_reward int not null default 10,
  created_at timestamptz default now()
);

create table if not exists public.exercises (
  id bigint generated always as identity primary key,
  lesson_id bigint not null references public.lessons(id) on delete cascade,
  type text not null check (type in ('multiple_choice','fill_blank','matching','listening','speaking')),
  question text not null,
  correct_answer text not null,
  wrong_answers text[] default '{}',
  audio_url text,
  translation text,
  order_index int not null,
  created_at timestamptz default now()
);

create table if not exists public.user_progress (
  id uuid default gen_random_uuid() primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  lesson_id bigint not null references public.lessons(id) on delete cascade,
  completed boolean default false,
  score int default 0,
  completed_at timestamptz,
  created_at timestamptz default now(),
  unique(user_id, lesson_id)
);

create table if not exists public.user_stats (
  id uuid default gen_random_uuid() primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  language_id bigint not null references public.languages(id) on delete cascade,
  total_xp int default 0,
  current_streak int default 0,
  longest_streak int default 0,
  last_activity_date date,
  created_at timestamptz default now(),
  unique(user_id, language_id)
);

create table if not exists public.user_achievements (
  id uuid default gen_random_uuid() primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  achievement_type text not null,
  earned_at timestamptz default now(),
  unique(user_id, achievement_type)
);

-- ---------- 2. INDEXES ----------

create index if not exists idx_courses_language     on public.courses(language_id);
create index if not exists idx_lessons_course       on public.lessons(course_id);
create index if not exists idx_exercises_lesson     on public.exercises(lesson_id);
create index if not exists idx_user_progress_user   on public.user_progress(user_id);
create index if not exists idx_user_progress_lesson on public.user_progress(lesson_id);
create index if not exists idx_user_stats_user      on public.user_stats(user_id);
create index if not exists idx_user_achievements_user on public.user_achievements(user_id);

-- ---------- 3. ROW LEVEL SECURITY ----------

alter table public.languages         enable row level security;
alter table public.courses           enable row level security;
alter table public.lessons           enable row level security;
alter table public.exercises         enable row level security;
alter table public.user_progress     enable row level security;
alter table public.user_stats        enable row level security;
alter table public.user_achievements enable row level security;

drop policy if exists "Languages are viewable by everyone" on public.languages;
drop policy if exists "Courses are viewable by everyone"   on public.courses;
drop policy if exists "Lessons are viewable by everyone"   on public.lessons;
drop policy if exists "Exercises are viewable by everyone" on public.exercises;
create policy "Languages are viewable by everyone" on public.languages for select using (true);
create policy "Courses are viewable by everyone"   on public.courses   for select using (true);
create policy "Lessons are viewable by everyone"   on public.lessons   for select using (true);
create policy "Exercises are viewable by everyone" on public.exercises for select using (true);

drop policy if exists "Users can view own progress"   on public.user_progress;
drop policy if exists "Users can insert own progress" on public.user_progress;
drop policy if exists "Users can update own progress" on public.user_progress;
create policy "Users can view own progress"   on public.user_progress for select using (auth.uid() = user_id);
create policy "Users can insert own progress" on public.user_progress for insert with check (auth.uid() = user_id);
create policy "Users can update own progress" on public.user_progress for update using (auth.uid() = user_id);

drop policy if exists "Users can view own stats"   on public.user_stats;
drop policy if exists "Users can insert own stats" on public.user_stats;
drop policy if exists "Users can update own stats" on public.user_stats;
create policy "Users can view own stats"   on public.user_stats for select using (auth.uid() = user_id);
create policy "Users can insert own stats" on public.user_stats for insert with check (auth.uid() = user_id);
create policy "Users can update own stats" on public.user_stats for update using (auth.uid() = user_id);

drop policy if exists "Users can view own achievements"   on public.user_achievements;
drop policy if exists "Users can insert own achievements" on public.user_achievements;
create policy "Users can view own achievements"   on public.user_achievements for select using (auth.uid() = user_id);
create policy "Users can insert own achievements" on public.user_achievements for insert with check (auth.uid() = user_id);

-- ---------- 4. SEED LANGUAGES ----------

insert into public.languages (name, code, flag_emoji, difficulty_grammar, difficulty_pronunciation) values
  ('Spanish',   'spanish',   '🇪🇸', 'Easy',   'Easy'),
  ('French',    'french',    '🇫🇷', 'Easy',   'Medium'),
  ('German',    'german',    '🇩🇪', 'Medium', 'Medium'),
  ('Greek',     'greek',     '🇬🇷', 'Medium', 'Medium'),
  ('Swedish',   'swedish',   '🇸🇪', 'Easy',   'Easy'),
  ('Danish',    'danish',    '🇩🇰', 'Easy',   'Medium'),
  ('Finnish',   'finnish',   '🇫🇮', 'Hard',   'Medium'),
  ('Albanian',  'albanian',  '🇦🇱', 'Hard',   'Medium'),
  ('Icelandic', 'icelandic', '🇮🇸', 'Hard',   'Medium'),
  ('Faroese',   'faroese',   '🇫🇴', 'Easy',   'Medium'),
  ('Corsican',  'corsican',  '🇫🇷', 'Medium', 'Medium'),
  ('English',   'english',   '🇬🇧', 'Easy',   'Easy')
on conflict (code) do nothing;

-- ---------- 5. SEED COURSES + LESSONS + EXERCISES ----------
-- For each language: 3 courses (Beginner/Intermediate/Advanced),
-- 5 lessons per course, 5 exercises per lesson (one of each exercise
-- type: multiple_choice, fill_blank, matching, listening, speaking).
--
-- Wrong-answer arrays are hardcoded per language in the CASE block,
-- so no subscripted array constructors (array[v_x[2], v_x[3]]) are
-- used anywhere in the INSERT statements. All English copy avoids
-- internal double quotes, apostrophes, and question marks.

do $seed$
declare
  lang record;
  v_greeting text;
  v_thanks   text;
  v_goodbye  text;
  v_please   text := 'Please';
  v_numbers  text[];
  v_colors   text[];
  v_family   text[];
  v_verbs    text[];
  v_i_am     text;
  -- Pre-built wrong-answer arrays (set once per language in CASE)
  v_wa_greet     text[];  -- [thanks, goodbye, Please] for hello question and hello listening
  v_wa_num_three text[];  -- numbers other than the 3rd one
  v_wa_num_two   text[];  -- numbers other than the 2nd one
  v_wa_red       text[];  -- colors other than the 1st one
  v_wa_green     text[];  -- colors other than the 3rd one
  v_wa_mother    text[];  -- family other than the 1st one
  v_wa_brother   text[];  -- family other than the 3rd one
  v_wa_tobe      text[];  -- verbs other than the 1st one
  v_wa_tohave    text[];  -- verbs other than the 2nd one
  course_id  bigint;
  lesson_id  bigint;
  tier       int;
  lesson_idx int;
  tier_names text[] := array['Beginner','Intermediate','Advanced'];
  tier_descs text[] := array[
    'Start your journey with the essentials.',
    'Build fluency with everyday topics.',
    'Master complex grammar and nuance.'
  ];
  beginner_titles     text[] := array['Greetings','Numbers 1-10','Colours','Family Members','Common Verbs'];
  intermediate_titles text[] := array['Travel & Directions','Food & Dining','Past Tense Basics','Shopping','Daily Routines'];
  advanced_titles     text[] := array['Subjunctive Mood','Idioms & Expressions','Business Vocabulary','Literature & Culture','Debate & Opinion'];
  lesson_types text[] := array['vocabulary','grammar','phrases','listening','speaking'];
  lesson_title text;
begin
  for lang in select id, code, name from public.languages order by id loop
    if exists (select 1 from public.courses where language_id = lang.id) then
      continue;
    end if;

    case lang.code
      when 'spanish' then
        v_greeting := 'Hola'; v_thanks := 'Gracias'; v_goodbye := 'Adiós';
        v_numbers := array['Uno','Dos','Tres','Cuatro','Cinco'];
        v_colors  := array['Rojo','Azul','Verde','Amarillo'];
        v_family  := array['Madre','Padre','Hermano','Hermana'];
        v_verbs   := array['Ser','Tener','Hacer','Ir'];
        v_i_am    := 'soy';
        v_wa_greet     := array['Gracias','Adiós','Please'];
        v_wa_num_three := array['Uno','Dos','Cuatro'];
        v_wa_num_two   := array['Uno','Tres','Cinco'];
        v_wa_red       := array['Azul','Verde','Amarillo'];
        v_wa_green     := array['Rojo','Azul','Amarillo'];
        v_wa_mother    := array['Padre','Hermano','Hermana'];
        v_wa_brother   := array['Madre','Padre','Hermana'];
        v_wa_tobe      := array['Tener','Hacer','Ir'];
        v_wa_tohave    := array['Ser','Hacer','Ir'];

      when 'french' then
        v_greeting := 'Bonjour'; v_thanks := 'Merci'; v_goodbye := 'Au revoir';
        v_numbers := array['Un','Deux','Trois','Quatre','Cinq'];
        v_colors  := array['Rouge','Bleu','Vert','Jaune'];
        v_family  := array['Mère','Père','Frère','Soeur'];
        v_verbs   := array['Être','Avoir','Faire','Aller'];
        v_i_am    := 'suis';
        v_wa_greet     := array['Merci','Au revoir','Please'];
        v_wa_num_three := array['Un','Deux','Quatre'];
        v_wa_num_two   := array['Un','Trois','Cinq'];
        v_wa_red       := array['Bleu','Vert','Jaune'];
        v_wa_green     := array['Rouge','Bleu','Jaune'];
        v_wa_mother    := array['Père','Frère','Soeur'];
        v_wa_brother   := array['Mère','Père','Soeur'];
        v_wa_tobe      := array['Avoir','Faire','Aller'];
        v_wa_tohave    := array['Être','Faire','Aller'];

      when 'german' then
        v_greeting := 'Hallo'; v_thanks := 'Danke'; v_goodbye := 'Tschüss';
        v_numbers := array['Eins','Zwei','Drei','Vier','Fünf'];
        v_colors  := array['Rot','Blau','Grün','Gelb'];
        v_family  := array['Mutter','Vater','Bruder','Schwester'];
        v_verbs   := array['Sein','Haben','Machen','Gehen'];
        v_i_am    := 'bin';
        v_wa_greet     := array['Danke','Tschüss','Please'];
        v_wa_num_three := array['Eins','Zwei','Vier'];
        v_wa_num_two   := array['Eins','Drei','Fünf'];
        v_wa_red       := array['Blau','Grün','Gelb'];
        v_wa_green     := array['Rot','Blau','Gelb'];
        v_wa_mother    := array['Vater','Bruder','Schwester'];
        v_wa_brother   := array['Mutter','Vater','Schwester'];
        v_wa_tobe      := array['Haben','Machen','Gehen'];
        v_wa_tohave    := array['Sein','Machen','Gehen'];

      when 'greek' then
        v_greeting := 'Γεια'; v_thanks := 'Ευχαριστώ'; v_goodbye := 'Αντίο';
        v_numbers := array['Ένα','Δύο','Τρία','Τέσσερα','Πέντε'];
        v_colors  := array['Κόκκινο','Μπλε','Πράσινο','Κίτρινο'];
        v_family  := array['Μητέρα','Πατέρας','Αδελφός','Αδελφή'];
        v_verbs   := array['Είμαι','Έχω','Κάνω','Πάω'];
        v_i_am    := 'είμαι';
        v_wa_greet     := array['Ευχαριστώ','Αντίο','Please'];
        v_wa_num_three := array['Ένα','Δύο','Τέσσερα'];
        v_wa_num_two   := array['Ένα','Τρία','Πέντε'];
        v_wa_red       := array['Μπλε','Πράσινο','Κίτρινο'];
        v_wa_green     := array['Κόκκινο','Μπλε','Κίτρινο'];
        v_wa_mother    := array['Πατέρας','Αδελφός','Αδελφή'];
        v_wa_brother   := array['Μητέρα','Πατέρας','Αδελφή'];
        v_wa_tobe      := array['Έχω','Κάνω','Πάω'];
        v_wa_tohave    := array['Είμαι','Κάνω','Πάω'];

      when 'swedish' then
        v_greeting := 'Hej'; v_thanks := 'Tack'; v_goodbye := 'Hej då';
        v_numbers := array['Ett','Två','Tre','Fyra','Fem'];
        v_colors  := array['Röd','Blå','Grön','Gul'];
        v_family  := array['Mor','Far','Bror','Syster'];
        v_verbs   := array['Vara','Ha','Göra','Gå'];
        v_i_am    := 'är';
        v_wa_greet     := array['Tack','Hej då','Please'];
        v_wa_num_three := array['Ett','Två','Fyra'];
        v_wa_num_two   := array['Ett','Tre','Fem'];
        v_wa_red       := array['Blå','Grön','Gul'];
        v_wa_green     := array['Röd','Blå','Gul'];
        v_wa_mother    := array['Far','Bror','Syster'];
        v_wa_brother   := array['Mor','Far','Syster'];
        v_wa_tobe      := array['Ha','Göra','Gå'];
        v_wa_tohave    := array['Vara','Göra','Gå'];

      when 'danish' then
        v_greeting := 'Hej'; v_thanks := 'Tak'; v_goodbye := 'Farvel';
        v_numbers := array['En','To','Tre','Fire','Fem'];
        v_colors  := array['Rød','Blå','Grøn','Gul'];
        v_family  := array['Mor','Far','Bror','Søster'];
        v_verbs   := array['Være','Have','Gøre','Gå'];
        v_i_am    := 'er';
        v_wa_greet     := array['Tak','Farvel','Please'];
        v_wa_num_three := array['En','To','Fire'];
        v_wa_num_two   := array['En','Tre','Fem'];
        v_wa_red       := array['Blå','Grøn','Gul'];
        v_wa_green     := array['Rød','Blå','Gul'];
        v_wa_mother    := array['Far','Bror','Søster'];
        v_wa_brother   := array['Mor','Far','Søster'];
        v_wa_tobe      := array['Have','Gøre','Gå'];
        v_wa_tohave    := array['Være','Gøre','Gå'];

      when 'finnish' then
        v_greeting := 'Hei'; v_thanks := 'Kiitos'; v_goodbye := 'Näkemiin';
        v_numbers := array['Yksi','Kaksi','Kolme','Neljä','Viisi'];
        v_colors  := array['Punainen','Sininen','Vihreä','Keltainen'];
        v_family  := array['Äiti','Isä','Veli','Sisko'];
        v_verbs   := array['Olla','Saada','Tehdä','Mennä'];
        v_i_am    := 'olen';
        v_wa_greet     := array['Kiitos','Näkemiin','Please'];
        v_wa_num_three := array['Yksi','Kaksi','Neljä'];
        v_wa_num_two   := array['Yksi','Kolme','Viisi'];
        v_wa_red       := array['Sininen','Vihreä','Keltainen'];
        v_wa_green     := array['Punainen','Sininen','Keltainen'];
        v_wa_mother    := array['Isä','Veli','Sisko'];
        v_wa_brother   := array['Äiti','Isä','Sisko'];
        v_wa_tobe      := array['Saada','Tehdä','Mennä'];
        v_wa_tohave    := array['Olla','Tehdä','Mennä'];

      when 'albanian' then
        v_greeting := 'Përshëndetje'; v_thanks := 'Faleminderit'; v_goodbye := 'Mirupafshim';
        v_numbers := array['Një','Dy','Tre','Katër','Pesë'];
        v_colors  := array['E kuqe','Blu','E gjelbër','E verdhë'];
        v_family  := array['Nëna','Babai','Vëllai','Motra'];
        v_verbs   := array['Të jesh','Të kesh','Të bësh','Të shkosh'];
        v_i_am    := 'jam';
        v_wa_greet     := array['Faleminderit','Mirupafshim','Please'];
        v_wa_num_three := array['Një','Dy','Katër'];
        v_wa_num_two   := array['Një','Tre','Pesë'];
        v_wa_red       := array['Blu','E gjelbër','E verdhë'];
        v_wa_green     := array['E kuqe','Blu','E verdhë'];
        v_wa_mother    := array['Babai','Vëllai','Motra'];
        v_wa_brother   := array['Nëna','Babai','Motra'];
        v_wa_tobe      := array['Të kesh','Të bësh','Të shkosh'];
        v_wa_tohave    := array['Të jesh','Të bësh','Të shkosh'];

      when 'icelandic' then
        v_greeting := 'Halló'; v_thanks := 'Takk'; v_goodbye := 'Bless';
        v_numbers := array['Einn','Tveir','Þrír','Fjórir','Fimm'];
        v_colors  := array['Rauður','Blár','Grænn','Gulur'];
        v_family  := array['Móðir','Faðir','Bróðir','Systir'];
        v_verbs   := array['Vera','Hafa','Gera','Fara'];
        v_i_am    := 'er';
        v_wa_greet     := array['Takk','Bless','Please'];
        v_wa_num_three := array['Einn','Tveir','Fjórir'];
        v_wa_num_two   := array['Einn','Þrír','Fimm'];
        v_wa_red       := array['Blár','Grænn','Gulur'];
        v_wa_green     := array['Rauður','Blár','Gulur'];
        v_wa_mother    := array['Faðir','Bróðir','Systir'];
        v_wa_brother   := array['Móðir','Faðir','Systir'];
        v_wa_tobe      := array['Hafa','Gera','Fara'];
        v_wa_tohave    := array['Vera','Gera','Fara'];

      when 'faroese' then
        v_greeting := 'Halló'; v_thanks := 'Takk'; v_goodbye := 'Farvæl';
        v_numbers := array['Ein','Tveir','Tríggir','Fýra','Fimm'];
        v_colors  := array['Reyður','Blár','Grønur','Gulur'];
        v_family  := array['Mamma','Pápi','Beiggi','Systir'];
        v_verbs   := array['Vera','Hava','Gera','Fara'];
        v_i_am    := 'eri';
        v_wa_greet     := array['Takk','Farvæl','Please'];
        v_wa_num_three := array['Ein','Tveir','Fýra'];
        v_wa_num_two   := array['Ein','Tríggir','Fimm'];
        v_wa_red       := array['Blár','Grønur','Gulur'];
        v_wa_green     := array['Reyður','Blár','Gulur'];
        v_wa_mother    := array['Pápi','Beiggi','Systir'];
        v_wa_brother   := array['Mamma','Pápi','Systir'];
        v_wa_tobe      := array['Hava','Gera','Fara'];
        v_wa_tohave    := array['Vera','Gera','Fara'];

      when 'corsican' then
        v_greeting := 'Bonghjornu'; v_thanks := 'Grazie'; v_goodbye := 'Avvedeci';
        v_numbers := array['Unu','Dui','Trè','Quattru','Cinque'];
        v_colors  := array['Rossu','Blu','Verde','Giallu'];
        v_family  := array['Mamma','Babbu','Fratellu','Surella'];
        v_verbs   := array['Esse','Avè','Fà','Andà'];
        v_i_am    := 'sò';
        v_wa_greet     := array['Grazie','Avvedeci','Please'];
        v_wa_num_three := array['Unu','Dui','Quattru'];
        v_wa_num_two   := array['Unu','Trè','Cinque'];
        v_wa_red       := array['Blu','Verde','Giallu'];
        v_wa_green     := array['Rossu','Blu','Giallu'];
        v_wa_mother    := array['Babbu','Fratellu','Surella'];
        v_wa_brother   := array['Mamma','Babbu','Surella'];
        v_wa_tobe      := array['Avè','Fà','Andà'];
        v_wa_tohave    := array['Esse','Fà','Andà'];

      when 'english' then
        v_greeting := 'Hello'; v_thanks := 'Thanks'; v_goodbye := 'Goodbye';
        v_numbers := array['One','Two','Three','Four','Five'];
        v_colors  := array['Red','Blue','Green','Yellow'];
        v_family  := array['Mother','Father','Brother','Sister'];
        v_verbs   := array['To be','To have','To do','To go'];
        v_i_am    := 'am';
        v_wa_greet     := array['Thanks','Goodbye','Please'];
        v_wa_num_three := array['One','Two','Four'];
        v_wa_num_two   := array['One','Three','Five'];
        v_wa_red       := array['Blue','Green','Yellow'];
        v_wa_green     := array['Red','Blue','Yellow'];
        v_wa_mother    := array['Father','Brother','Sister'];
        v_wa_brother   := array['Mother','Father','Sister'];
        v_wa_tobe      := array['To have','To do','To go'];
        v_wa_tohave    := array['To be','To do','To go'];

      else
        v_greeting := 'Hello'; v_thanks := 'Thanks'; v_goodbye := 'Goodbye';
        v_numbers := array['One','Two','Three','Four','Five'];
        v_colors  := array['Red','Blue','Green','Yellow'];
        v_family  := array['Mother','Father','Brother','Sister'];
        v_verbs   := array['To be','To have','To do','To go'];
        v_i_am    := 'am';
        v_wa_greet     := array['Thanks','Goodbye','Please'];
        v_wa_num_three := array['One','Two','Four'];
        v_wa_num_two   := array['One','Three','Five'];
        v_wa_red       := array['Blue','Green','Yellow'];
        v_wa_green     := array['Red','Blue','Yellow'];
        v_wa_mother    := array['Father','Brother','Sister'];
        v_wa_brother   := array['Mother','Father','Sister'];
        v_wa_tobe      := array['To have','To do','To go'];
        v_wa_tohave    := array['To be','To do','To go'];
    end case;

    -- ----- 3 courses per language -----
    for tier in 1..3 loop
      insert into public.courses (language_id, title, description, order_index)
      values (lang.id, tier_names[tier], tier_descs[tier], tier)
      returning id into course_id;

      -- ----- 5 lessons per course -----
      for lesson_idx in 1..5 loop
        if tier = 1 then
          lesson_title := beginner_titles[lesson_idx];
        elsif tier = 2 then
          lesson_title := intermediate_titles[lesson_idx];
        else
          lesson_title := advanced_titles[lesson_idx];
        end if;

        insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
        values (
          course_id,
          lesson_title,
          'Learn ' || lesson_title || ' in ' || lang.name,
          lesson_types[lesson_idx],
          lesson_idx,
          10 + (tier - 1) * 5
        )
        returning id into lesson_id;

        -- 5 exercises per lesson — one of each exercise type
        if tier = 1 and lesson_idx = 1 then
          -- Greetings
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'How do you say Hello in ' || lang.name,
              v_greeting, v_wa_greet, 'Hello', 1),
            (lesson_id, 'fill_blank',
              'In ' || lang.name || ' the word for Thanks is ___',
              v_thanks, '{}'::text[], 'Thanks', 2),
            (lesson_id, 'matching',
              'Match the ' || lang.name || ' greetings to their English meaning',
              v_greeting || ':Hello|' || v_thanks || ':Thanks|' || v_goodbye || ':Goodbye|' || v_please || ':Please',
              '{}'::text[], 'Greetings', 3),
            (lesson_id, 'listening',
              'Listen and pick the ' || lang.name || ' word that means Hello',
              v_greeting, v_wa_greet, 'Hello', 4),
            (lesson_id, 'speaking',
              'Say it out loud: ' || v_greeting || ' (Hello)',
              v_greeting, '{}'::text[], 'Hello in ' || lang.name, 5);

        elsif tier = 1 and lesson_idx = 2 then
          -- Numbers 1-10
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'Which is the number three in ' || lang.name,
              v_numbers[3], v_wa_num_three, '3', 1),
            (lesson_id, 'fill_blank',
              'The number 5 in ' || lang.name || ' is ___',
              v_numbers[5], '{}'::text[], '5', 2),
            (lesson_id, 'matching',
              'Match the ' || lang.name || ' numbers to digits',
              v_numbers[1] || ':1|' || v_numbers[2] || ':2|' || v_numbers[3] || ':3|' || v_numbers[4] || ':4',
              '{}'::text[], 'Numbers 1-4', 3),
            (lesson_id, 'listening',
              'Listen and pick the ' || lang.name || ' number you hear',
              v_numbers[2], v_wa_num_two, '2', 4),
            (lesson_id, 'speaking',
              'Count out loud: ' || v_numbers[1] || ', ' || v_numbers[2] || ', ' || v_numbers[3],
              v_numbers[1] || ' ' || v_numbers[2] || ' ' || v_numbers[3], '{}'::text[], '1, 2, 3', 5);

        elsif tier = 1 and lesson_idx = 3 then
          -- Colours
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'Which is the word for red in ' || lang.name,
              v_colors[1], v_wa_red, 'Red', 1),
            (lesson_id, 'fill_blank',
              'In ' || lang.name || ' the sky is ___',
              v_colors[2], '{}'::text[], 'Blue', 2),
            (lesson_id, 'matching',
              'Match the ' || lang.name || ' colours to English',
              v_colors[1] || ':Red|' || v_colors[2] || ':Blue|' || v_colors[3] || ':Green|' || v_colors[4] || ':Yellow',
              '{}'::text[], 'Colours', 3),
            (lesson_id, 'listening',
              'Listen and pick the ' || lang.name || ' colour you hear',
              v_colors[3], v_wa_green, 'Green', 4),
            (lesson_id, 'speaking',
              'Pronounce the colours: ' || v_colors[1] || ', ' || v_colors[2] || ', ' || v_colors[3],
              v_colors[1] || ' ' || v_colors[2] || ' ' || v_colors[3], '{}'::text[], 'Red, Blue, Green', 5);

        elsif tier = 1 and lesson_idx = 4 then
          -- Family Members
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'Which is the word for mother in ' || lang.name,
              v_family[1], v_wa_mother, 'Mother', 1),
            (lesson_id, 'fill_blank',
              'My father in ' || lang.name || ' is ___',
              v_family[2], '{}'::text[], 'Father', 2),
            (lesson_id, 'matching',
              'Match the ' || lang.name || ' family words to English',
              v_family[1] || ':Mother|' || v_family[2] || ':Father|' || v_family[3] || ':Brother|' || v_family[4] || ':Sister',
              '{}'::text[], 'Family', 3),
            (lesson_id, 'listening',
              'Listen and pick the ' || lang.name || ' family word you hear',
              v_family[3], v_wa_brother, 'Brother', 4),
            (lesson_id, 'speaking',
              'Introduce your family: ' || v_family[1] || ', ' || v_family[2] || ', ' || v_family[3] || ', ' || v_family[4],
              v_family[1] || ' ' || v_family[2] || ' ' || v_family[3] || ' ' || v_family[4], '{}'::text[],
              'Mother, Father, Brother, Sister', 5);

        elsif tier = 1 and lesson_idx = 5 then
          -- Common Verbs
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'Which ' || lang.name || ' verb means to be',
              v_verbs[1], v_wa_tobe, 'To be', 1),
            (lesson_id, 'fill_blank',
              'I am in ' || lang.name || ' is: I ___',
              v_i_am, '{}'::text[], 'I am', 2),
            (lesson_id, 'matching',
              'Match the ' || lang.name || ' verbs to English',
              v_verbs[1] || ':To be|' || v_verbs[2] || ':To have|' || v_verbs[3] || ':To do|' || v_verbs[4] || ':To go',
              '{}'::text[], 'Common verbs', 3),
            (lesson_id, 'listening',
              'Listen and pick the ' || lang.name || ' verb you hear',
              v_verbs[2], v_wa_tohave, 'To have', 4),
            (lesson_id, 'speaking',
              'Say the four verbs: ' || v_verbs[1] || ', ' || v_verbs[2] || ', ' || v_verbs[3] || ', ' || v_verbs[4],
              v_verbs[1] || ' ' || v_verbs[2] || ' ' || v_verbs[3] || ' ' || v_verbs[4], '{}'::text[],
              'To be, to have, to do, to go', 5);

        elsif tier = 2 and lesson_idx = 1 then
          -- Travel & Directions
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'In ' || lang.name || ' where would you ask where the train station is',
              'At the station', array['At a restaurant','At home','At the airport'], 'Travel context', 1),
            (lesson_id, 'fill_blank',
              'Complete this ' || lang.name || ' phrase: I would like to go to the ___',
              'station', '{}'::text[], 'I would like to go to the station', 2),
            (lesson_id, 'matching',
              'Match these ' || lang.name || ' travel words to English',
              'Station:Station|Hotel:Hotel|Airport:Airport|Map:Map',
              '{}'::text[], 'Travel vocabulary', 3),
            (lesson_id, 'listening',
              'Listen to the ' || lang.name || ' announcement and pick the platform',
              'Platform 3', array['Platform 1','Platform 2','Platform 4'], 'Platform 3', 4),
            (lesson_id, 'speaking',
              'Ask in ' || lang.name || ': Where is the train station, please',
              'Where is the train station', '{}'::text[],
              'Where is the train station', 5);

        elsif tier = 2 and lesson_idx = 2 then
          -- Food & Dining
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'Which ' || lang.name || ' phrase means I would like a table for two',
              'A table for two', array['The bill, please','A coffee','Where is the toilet'],
              'A table for two', 1),
            (lesson_id, 'fill_blank',
              'Order in ' || lang.name || ': I would like a ___ please',
              'coffee', '{}'::text[], 'I would like a coffee', 2),
            (lesson_id, 'matching',
              'Match these ' || lang.name || ' food words to English',
              'Bread:Bread|Water:Water|Coffee:Coffee|Wine:Wine',
              '{}'::text[], 'Food and drink', 3),
            (lesson_id, 'listening',
              'Listen and pick what the customer ordered',
              'Coffee and bread', array['Water and salad','Wine and steak','Tea and cake'],
              'Coffee and bread', 4),
            (lesson_id, 'speaking',
              'Order out loud in ' || lang.name || ': The bill, please',
              'The bill, please', '{}'::text[], 'The bill, please', 5);

        elsif tier = 2 and lesson_idx = 3 then
          -- Past Tense Basics
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'In ' || lang.name || ' which is the past tense of to go',
              'went', array['go','going','will go'], 'went', 1),
            (lesson_id, 'fill_blank',
              'Past tense in ' || lang.name || ': Yesterday I ___ to the market',
              'went', '{}'::text[], 'Yesterday I went to the market', 2),
            (lesson_id, 'matching',
              'Match ' || lang.name || ' present-tense verbs to their past form',
              'is:was|has:had|goes:went|does:did',
              '{}'::text[], 'Past tenses', 3),
            (lesson_id, 'listening',
              'Listen and decide whether the verb is past or present tense',
              'past', array['present','future','imperative'], 'past', 4),
            (lesson_id, 'speaking',
              'Say in ' || lang.name || ': I ate breakfast this morning',
              'I ate breakfast this morning', '{}'::text[],
              'I ate breakfast this morning', 5);

        elsif tier = 2 and lesson_idx = 4 then
          -- Shopping
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'In ' || lang.name || ' which phrase means how much does this cost',
              'How much', array['Where is it','When does it open','What is this'], 'How much', 1),
            (lesson_id, 'fill_blank',
              'Complete in ' || lang.name || ': It costs ten ___',
              'euros', '{}'::text[], 'It costs ten euros', 2),
            (lesson_id, 'matching',
              'Match these ' || lang.name || ' shopping words to English',
              'Shop:Shop|Money:Money|Price:Price|Receipt:Receipt',
              '{}'::text[], 'Shopping vocabulary', 3),
            (lesson_id, 'listening',
              'Listen and pick the total price',
              '25 euros', array['15 euros','35 euros','45 euros'], '25 euros', 4),
            (lesson_id, 'speaking',
              'Ask in ' || lang.name || ': Can I pay by card',
              'Can I pay by card', '{}'::text[], 'Can I pay by card', 5);

        elsif tier = 2 and lesson_idx = 5 then
          -- Daily Routines
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'In ' || lang.name || ' which sentence means I wake up at seven',
              'I wake up at seven', array['I sleep at seven','I work at seven','I eat at seven'],
              'I wake up at seven', 1),
            (lesson_id, 'fill_blank',
              'Daily routine in ' || lang.name || ': Every morning I ___',
              'drink coffee', '{}'::text[], 'Every morning I drink coffee', 2),
            (lesson_id, 'matching',
              'Match these ' || lang.name || ' routine verbs to English',
              'Wake up:Wake up|Eat:Eat|Work:Work|Sleep:Sleep',
              '{}'::text[], 'Routine verbs', 3),
            (lesson_id, 'listening',
              'Listen and pick the time the speaker starts work',
              '9am', array['8am','10am','noon'], '9am', 4),
            (lesson_id, 'speaking',
              'Describe your morning in ' || lang.name || ': I wake up, eat breakfast and go to work',
              'I wake up, eat breakfast and go to work', '{}'::text[],
              'Describe a morning routine', 5);

        elsif tier = 3 and lesson_idx = 1 then
          -- Subjunctive Mood
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'Which sentence uses the ' || lang.name || ' subjunctive mood',
              'I hope that he comes', array['He comes home','He came home','He will come home'],
              'Subjunctive: I hope that he comes', 1),
            (lesson_id, 'fill_blank',
              'Use the ' || lang.name || ' subjunctive: It is important that you ___ here',
              'be', '{}'::text[], 'It is important that you be here', 2),
            (lesson_id, 'matching',
              'Match these ' || lang.name || ' verbs from indicative to subjunctive',
              'is:be|has:have|goes:go|does:do',
              '{}'::text[], 'Indicative vs subjunctive', 3),
            (lesson_id, 'listening',
              'Listen and decide whether the verb is indicative or subjunctive',
              'subjunctive', array['indicative','imperative','infinitive'], 'subjunctive', 4),
            (lesson_id, 'speaking',
              'Say in ' || lang.name || ': I wish that he were here',
              'I wish that he were here', '{}'::text[], 'I wish that he were here', 5);

        elsif tier = 3 and lesson_idx = 2 then
          -- Idioms & Expressions
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'What does the ' || lang.name || ' idiom to have a frog in your throat mean',
              'To be hoarse', array['To be hungry','To be lying','To be tired'], 'To be hoarse', 1),
            (lesson_id, 'fill_blank',
              'Complete the ' || lang.name || ' idiom: It is raining ___ and dogs',
              'cats', '{}'::text[], 'It is raining cats and dogs', 2),
            (lesson_id, 'matching',
              'Match these ' || lang.name || ' idioms to their meanings',
              'Break a leg:Good luck|Piece of cake:Easy|Spill the beans:Reveal a secret|Hit the books:Study',
              '{}'::text[], 'Common idioms', 3),
            (lesson_id, 'listening',
              'Listen and pick the idiom being used',
              'Break a leg', array['Piece of cake','Hit the road','Cold feet'], 'Break a leg', 4),
            (lesson_id, 'speaking',
              'Use this idiom in ' || lang.name || ': It is a piece of cake',
              'It is a piece of cake', '{}'::text[], 'It is a piece of cake', 5);

        elsif tier = 3 and lesson_idx = 3 then
          -- Business Vocabulary
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'Which ' || lang.name || ' phrase is most appropriate to open a business email',
              'Dear Sir or Madam', array['Hey there','What is up','Yo'], 'Dear Sir or Madam', 1),
            (lesson_id, 'fill_blank',
              'Business ' || lang.name || ': Please find ___ the report',
              'attached', '{}'::text[], 'Please find attached the report', 2),
            (lesson_id, 'matching',
              'Match these ' || lang.name || ' business terms to English',
              'Meeting:Meeting|Contract:Contract|Deadline:Deadline|Invoice:Invoice',
              '{}'::text[], 'Business vocabulary', 3),
            (lesson_id, 'listening',
              'Listen to the ' || lang.name || ' meeting clip and pick what was decided',
              'They agreed on the budget', array['They cancelled the project','They hired a new team','They postponed the launch'],
              'They agreed on the budget', 4),
            (lesson_id, 'speaking',
              'Open a meeting in ' || lang.name || ': Thank you all for coming today',
              'Thank you all for coming today', '{}'::text[],
              'Thank you all for coming today', 5);

        elsif tier = 3 and lesson_idx = 4 then
          -- Literature & Culture
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'Which is a well-known work of ' || lang.name || ' literature',
              'A famous novel', array['A modern app','A pop song','A web series'], 'Sample literature reference', 1),
            (lesson_id, 'fill_blank',
              'A ' || lang.name || ' poet often wrote about ___',
              'love', '{}'::text[], 'Love', 2),
            (lesson_id, 'matching',
              'Match these literary terms to their meanings',
              'Metaphor:Implicit comparison|Simile:Explicit comparison|Verse:Line of poetry|Stanza:Group of lines',
              '{}'::text[], 'Literary terms', 3),
            (lesson_id, 'listening',
              'Listen to the ' || lang.name || ' poem and pick the main emotion',
              'Longing', array['Joy','Anger','Confusion'], 'Longing', 4),
            (lesson_id, 'speaking',
              'Read aloud in ' || lang.name || ' the opening line of a famous poem',
              'Opening line of a famous poem', '{}'::text[],
              'Opening line of a famous poem', 5);

        else
          -- tier = 3, lesson_idx = 5 -- Debate & Opinion
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'Which ' || lang.name || ' phrase introduces an opinion',
              'In my opinion', array['On the other hand','For example','In conclusion'], 'In my opinion', 1),
            (lesson_id, 'fill_blank',
              'Complete: I ___ that we should consider all options',
              'believe', '{}'::text[], 'I believe that we should consider all options', 2),
            (lesson_id, 'matching',
              'Match these debate phrases to their function',
              'In my view:Opinion|However:Contrast|Therefore:Conclusion|For instance:Example',
              '{}'::text[], 'Debate connectors', 3),
            (lesson_id, 'listening',
              'Listen to the debate and pick what the speaker is arguing for',
              'Renewable energy', array['Lower taxes','More tourism','Stricter laws'], 'Renewable energy', 4),
            (lesson_id, 'speaking',
              'State your opinion in ' || lang.name || ': In my view, language learning opens doors',
              'In my view, language learning opens doors', '{}'::text[],
              'In my view, language learning opens doors', 5);
        end if;
      end loop;
    end loop;
  end loop;
end
$seed$;

-- ============================================================
-- Done. You should now have:
--   12 languages
--   36 courses (3 per language)
--  180 lessons (5 per course)
--  900 exercises (5 per lesson)
-- ============================================================

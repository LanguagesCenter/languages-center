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

create index if not exists idx_courses_language on public.courses(language_id);
create index if not exists idx_lessons_course on public.lessons(course_id);
create index if not exists idx_exercises_lesson on public.exercises(lesson_id);
create index if not exists idx_user_progress_user on public.user_progress(user_id);
create index if not exists idx_user_progress_lesson on public.user_progress(lesson_id);
create index if not exists idx_user_stats_user on public.user_stats(user_id);
create index if not exists idx_user_achievements_user on public.user_achievements(user_id);

-- ---------- 3. ROW LEVEL SECURITY ----------

alter table public.languages enable row level security;
alter table public.courses enable row level security;
alter table public.lessons enable row level security;
alter table public.exercises enable row level security;
alter table public.user_progress enable row level security;
alter table public.user_stats enable row level security;
alter table public.user_achievements enable row level security;

-- Content tables: readable by everyone
drop policy if exists "Languages are viewable by everyone" on public.languages;
drop policy if exists "Courses are viewable by everyone"   on public.courses;
drop policy if exists "Lessons are viewable by everyone"   on public.lessons;
drop policy if exists "Exercises are viewable by everyone" on public.exercises;
create policy "Languages are viewable by everyone" on public.languages for select using (true);
create policy "Courses are viewable by everyone"   on public.courses   for select using (true);
create policy "Lessons are viewable by everyone"   on public.lessons   for select using (true);
create policy "Exercises are viewable by everyone" on public.exercises for select using (true);

-- User tables: scoped to the authenticated user
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
-- 5 lessons per course, 5 exercises per lesson (one of each type:
-- multiple_choice, fill_blank, matching, listening, speaking).

do $seed$
declare
  lang record;
  v_greeting       text;
  v_thanks         text;
  v_goodbye        text;
  v_please         text := 'Please';
  v_numbers        text[];
  v_colors         text[];
  v_family         text[];
  v_verbs          text[];
  v_i_am           text;
  v_yes            text;
  v_no             text;
  course_id        bigint;
  lesson_id        bigint;
  tier             int;
  lesson_idx       int;
  tier_names       text[] := array['Beginner','Intermediate','Advanced'];
  tier_descs       text[] := array[
    'Start your journey with the essentials.',
    'Build fluency with everyday topics.',
    'Master complex grammar and nuance.'
  ];
  beginner_titles    text[] := array['Greetings','Numbers 1-10','Colours','Family Members','Common Verbs'];
  intermediate_titles text[] := array['Travel & Directions','Food & Dining','Past Tense Basics','Shopping','Daily Routines'];
  advanced_titles    text[] := array['Subjunctive Mood','Idioms & Expressions','Business Vocabulary','Literature & Culture','Debate & Opinion'];
  -- Lesson types cycle through all 5 in order
  lesson_types     text[] := array['vocabulary','grammar','phrases','listening','speaking'];
  lesson_title     text;
begin
  for lang in select id, code, name from public.languages order by id loop
    -- Skip if already seeded
    if exists (select 1 from public.courses where language_id = lang.id) then
      continue;
    end if;

    -- ----- Per-language vocab (used by Beginner content) -----
    case lang.code
      when 'spanish' then
        v_greeting := 'Hola'; v_thanks := 'Gracias'; v_goodbye := 'Adiós';
        v_yes := 'Sí'; v_no := 'No';
        v_numbers := array['Uno','Dos','Tres','Cuatro','Cinco'];
        v_colors  := array['Rojo','Azul','Verde','Amarillo'];
        v_family  := array['Madre','Padre','Hermano','Hermana'];
        v_verbs   := array['Ser','Tener','Hacer','Ir'];
        v_i_am    := 'soy';
      when 'french' then
        v_greeting := 'Bonjour'; v_thanks := 'Merci'; v_goodbye := 'Au revoir';
        v_yes := 'Oui'; v_no := 'Non';
        v_numbers := array['Un','Deux','Trois','Quatre','Cinq'];
        v_colors  := array['Rouge','Bleu','Vert','Jaune'];
        v_family  := array['Mère','Père','Frère','Sœur'];
        v_verbs   := array['Être','Avoir','Faire','Aller'];
        v_i_am    := 'suis';
      when 'german' then
        v_greeting := 'Hallo'; v_thanks := 'Danke'; v_goodbye := 'Tschüss';
        v_yes := 'Ja'; v_no := 'Nein';
        v_numbers := array['Eins','Zwei','Drei','Vier','Fünf'];
        v_colors  := array['Rot','Blau','Grün','Gelb'];
        v_family  := array['Mutter','Vater','Bruder','Schwester'];
        v_verbs   := array['Sein','Haben','Machen','Gehen'];
        v_i_am    := 'bin';
      when 'greek' then
        v_greeting := 'Γεια'; v_thanks := 'Ευχαριστώ'; v_goodbye := 'Αντίο';
        v_yes := 'Ναι'; v_no := 'Όχι';
        v_numbers := array['Ένα','Δύο','Τρία','Τέσσερα','Πέντε'];
        v_colors  := array['Κόκκινο','Μπλε','Πράσινο','Κίτρινο'];
        v_family  := array['Μητέρα','Πατέρας','Αδελφός','Αδελφή'];
        v_verbs   := array['Είμαι','Έχω','Κάνω','Πάω'];
        v_i_am    := 'είμαι';
      when 'swedish' then
        v_greeting := 'Hej'; v_thanks := 'Tack'; v_goodbye := 'Hej då';
        v_yes := 'Ja'; v_no := 'Nej';
        v_numbers := array['Ett','Två','Tre','Fyra','Fem'];
        v_colors  := array['Röd','Blå','Grön','Gul'];
        v_family  := array['Mor','Far','Bror','Syster'];
        v_verbs   := array['Vara','Ha','Göra','Gå'];
        v_i_am    := 'är';
      when 'danish' then
        v_greeting := 'Hej'; v_thanks := 'Tak'; v_goodbye := 'Farvel';
        v_yes := 'Ja'; v_no := 'Nej';
        v_numbers := array['En','To','Tre','Fire','Fem'];
        v_colors  := array['Rød','Blå','Grøn','Gul'];
        v_family  := array['Mor','Far','Bror','Søster'];
        v_verbs   := array['Være','Have','Gøre','Gå'];
        v_i_am    := 'er';
      when 'finnish' then
        v_greeting := 'Hei'; v_thanks := 'Kiitos'; v_goodbye := 'Näkemiin';
        v_yes := 'Kyllä'; v_no := 'Ei';
        v_numbers := array['Yksi','Kaksi','Kolme','Neljä','Viisi'];
        v_colors  := array['Punainen','Sininen','Vihreä','Keltainen'];
        v_family  := array['Äiti','Isä','Veli','Sisko'];
        v_verbs   := array['Olla','Saada','Tehdä','Mennä'];
        v_i_am    := 'olen';
      when 'albanian' then
        v_greeting := 'Përshëndetje'; v_thanks := 'Faleminderit'; v_goodbye := 'Mirupafshim';
        v_yes := 'Po'; v_no := 'Jo';
        v_numbers := array['Një','Dy','Tre','Katër','Pesë'];
        v_colors  := array['E kuqe','Blu','E gjelbër','E verdhë'];
        v_family  := array['Nëna','Babai','Vëllai','Motra'];
        v_verbs   := array['Të jesh','Të kesh','Të bësh','Të shkosh'];
        v_i_am    := 'jam';
      when 'icelandic' then
        v_greeting := 'Halló'; v_thanks := 'Takk'; v_goodbye := 'Bless';
        v_yes := 'Já'; v_no := 'Nei';
        v_numbers := array['Einn','Tveir','Þrír','Fjórir','Fimm'];
        v_colors  := array['Rauður','Blár','Grænn','Gulur'];
        v_family  := array['Móðir','Faðir','Bróðir','Systir'];
        v_verbs   := array['Vera','Hafa','Gera','Fara'];
        v_i_am    := 'er';
      when 'faroese' then
        v_greeting := 'Halló'; v_thanks := 'Takk'; v_goodbye := 'Farvæl';
        v_yes := 'Ja'; v_no := 'Nei';
        v_numbers := array['Ein','Tveir','Tríggir','Fýra','Fimm'];
        v_colors  := array['Reyður','Blár','Grønur','Gulur'];
        v_family  := array['Mamma','Pápi','Beiggi','Systir'];
        v_verbs   := array['Vera','Hava','Gera','Fara'];
        v_i_am    := 'eri';
      when 'corsican' then
        v_greeting := 'Bonghjornu'; v_thanks := 'Grazie'; v_goodbye := 'Avvedeci';
        v_yes := 'Iè'; v_no := 'Nò';
        v_numbers := array['Unu','Dui','Trè','Quattru','Cinque'];
        v_colors  := array['Rossu','Blu','Verde','Giallu'];
        v_family  := array['Mamma','Babbu','Fratellu','Surella'];
        v_verbs   := array['Esse','Avè','Fà','Andà'];
        v_i_am    := 'sò';
      when 'english' then
        v_greeting := 'Hello'; v_thanks := 'Thanks'; v_goodbye := 'Goodbye';
        v_yes := 'Yes'; v_no := 'No';
        v_numbers := array['One','Two','Three','Four','Five'];
        v_colors  := array['Red','Blue','Green','Yellow'];
        v_family  := array['Mother','Father','Brother','Sister'];
        v_verbs   := array['To be','To have','To do','To go'];
        v_i_am    := 'am';
      else
        -- Generic fallback (shouldn't be hit)
        v_greeting := 'Hello'; v_thanks := 'Thanks'; v_goodbye := 'Goodbye';
        v_yes := 'Yes'; v_no := 'No';
        v_numbers := array['1','2','3','4','5'];
        v_colors  := array['Red','Blue','Green','Yellow'];
        v_family  := array['Mother','Father','Brother','Sister'];
        v_verbs   := array['To be','To have','To do','To go'];
        v_i_am    := 'am';
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

        -- =========================================================
        -- Exercises: 5 per lesson, one of each exercise type.
        -- =========================================================
        if tier = 1 and lesson_idx = 1 then
          -- Greetings
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'How do you say "Hello" in ' || lang.name || '?',
              v_greeting, array[v_thanks, v_goodbye, v_please], 'Hello', 1),
            (lesson_id, 'fill_blank',
              'In ' || lang.name || ', the word for "Thanks" is ___',
              v_thanks, array[]::text[], 'Thanks', 2),
            (lesson_id, 'matching',
              'Match the ' || lang.name || ' greetings to their English meaning',
              v_greeting||':Hello|'||v_thanks||':Thanks|'||v_goodbye||':Goodbye|'||v_please||':Please',
              array[]::text[], 'Greetings', 3),
            (lesson_id, 'listening',
              'Listen — which ' || lang.name || ' word means "Hello"?',
              v_greeting, array[v_thanks, v_goodbye, v_please], 'Hello', 4),
            (lesson_id, 'speaking',
              'Say it out loud: "' || v_greeting || '" (Hello)',
              v_greeting, array[]::text[], 'Hello in ' || lang.name, 5);

        elsif tier = 1 and lesson_idx = 2 then
          -- Numbers 1-10
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'Which is "three" in ' || lang.name || '?',
              v_numbers[3], array[v_numbers[1], v_numbers[2], v_numbers[4]], '3', 1),
            (lesson_id, 'fill_blank',
              'The number 5 in ' || lang.name || ' is ___',
              v_numbers[5], array[]::text[], '5', 2),
            (lesson_id, 'matching',
              'Match the ' || lang.name || ' numbers to digits',
              v_numbers[1]||':1|'||v_numbers[2]||':2|'||v_numbers[3]||':3|'||v_numbers[4]||':4',
              array[]::text[], 'Numbers 1-4', 3),
            (lesson_id, 'listening',
              'Listen — which number is being said?',
              v_numbers[2], array[v_numbers[1], v_numbers[3], v_numbers[5]], '2', 4),
            (lesson_id, 'speaking',
              'Count out loud: ' || v_numbers[1] || ', ' || v_numbers[2] || ', ' || v_numbers[3],
              v_numbers[1]||' '||v_numbers[2]||' '||v_numbers[3], array[]::text[], '1, 2, 3', 5);

        elsif tier = 1 and lesson_idx = 3 then
          -- Colours
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'Which is "red" in ' || lang.name || '?',
              v_colors[1], array[v_colors[2], v_colors[3], v_colors[4]], 'Red', 1),
            (lesson_id, 'fill_blank',
              'In ' || lang.name || ', the sky is ___',
              v_colors[2], array[]::text[], 'Blue', 2),
            (lesson_id, 'matching',
              'Match the ' || lang.name || ' colours to English',
              v_colors[1]||':Red|'||v_colors[2]||':Blue|'||v_colors[3]||':Green|'||v_colors[4]||':Yellow',
              array[]::text[], 'Colours', 3),
            (lesson_id, 'listening',
              'Listen — which colour is being named?',
              v_colors[3], array[v_colors[1], v_colors[2], v_colors[4]], 'Green', 4),
            (lesson_id, 'speaking',
              'Pronounce the colours: ' || v_colors[1] || ', ' || v_colors[2] || ', ' || v_colors[3],
              v_colors[1]||' '||v_colors[2]||' '||v_colors[3], array[]::text[], 'Red, Blue, Green', 5);

        elsif tier = 1 and lesson_idx = 4 then
          -- Family Members
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'Which is "mother" in ' || lang.name || '?',
              v_family[1], array[v_family[2], v_family[3], v_family[4]], 'Mother', 1),
            (lesson_id, 'fill_blank',
              'My father in ' || lang.name || ': ___',
              v_family[2], array[]::text[], 'Father', 2),
            (lesson_id, 'matching',
              'Match the ' || lang.name || ' family words to English',
              v_family[1]||':Mother|'||v_family[2]||':Father|'||v_family[3]||':Brother|'||v_family[4]||':Sister',
              array[]::text[], 'Family', 3),
            (lesson_id, 'listening',
              'Listen — which family member is mentioned?',
              v_family[3], array[v_family[1], v_family[2], v_family[4]], 'Brother', 4),
            (lesson_id, 'speaking',
              'Introduce your family: "' || v_family[1] || ', ' || v_family[2] || ', ' || v_family[3] || ', ' || v_family[4] || '"',
              v_family[1]||' '||v_family[2]||' '||v_family[3]||' '||v_family[4], array[]::text[],
              'Mother, Father, Brother, Sister', 5);

        elsif tier = 1 and lesson_idx = 5 then
          -- Common Verbs
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'Which ' || lang.name || ' verb means "to be"?',
              v_verbs[1], array[v_verbs[2], v_verbs[3], v_verbs[4]], 'To be', 1),
            (lesson_id, 'fill_blank',
              '"I am" in ' || lang.name || ': I ___',
              v_i_am, array[]::text[], 'I am', 2),
            (lesson_id, 'matching',
              'Match the ' || lang.name || ' verbs to English',
              v_verbs[1]||':To be|'||v_verbs[2]||':To have|'||v_verbs[3]||':To do|'||v_verbs[4]||':To go',
              array[]::text[], 'Common verbs', 3),
            (lesson_id, 'listening',
              'Listen — which verb is used?',
              v_verbs[2], array[v_verbs[1], v_verbs[3], v_verbs[4]], 'To have', 4),
            (lesson_id, 'speaking',
              'Say the four verbs: ' || v_verbs[1] || ', ' || v_verbs[2] || ', ' || v_verbs[3] || ', ' || v_verbs[4],
              v_verbs[1]||' '||v_verbs[2]||' '||v_verbs[3]||' '||v_verbs[4], array[]::text[],
              'To be, to have, to do, to go', 5);

        elsif tier = 2 and lesson_idx = 1 then
          -- Travel & Directions
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'In ' || lang.name || ', where would you ask "Where is the train station?"',
              'At the station', array['At a restaurant','At home','At the airport'], 'Travel context', 1),
            (lesson_id, 'fill_blank',
              'Complete the ' || lang.name || ' phrase: "I would like to go to the ___"',
              'station', array[]::text[], 'I would like to go to the station', 2),
            (lesson_id, 'matching',
              'Match these ' || lang.name || ' travel words to English',
              'Station:Station|Hotel:Hotel|Airport:Airport|Map:Map',
              array[]::text[], 'Travel vocabulary', 3),
            (lesson_id, 'listening',
              'Listen to the ' || lang.name || ' announcement — which platform?',
              'Platform 3', array['Platform 1','Platform 2','Platform 4'], 'Platform 3', 4),
            (lesson_id, 'speaking',
              'Ask in ' || lang.name || ': "Where is the train station, please?"',
              'Where is the train station?', array[]::text[],
              'Where is the train station?', 5);

        elsif tier = 2 and lesson_idx = 2 then
          -- Food & Dining
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'Which ' || lang.name || ' phrase means "I would like a table for two"?',
              'A table for two', array['The bill, please','A coffee','Where is the toilet?'],
              'A table for two', 1),
            (lesson_id, 'fill_blank',
              'Order in ' || lang.name || ': "I would like a ___, please" (coffee)',
              'coffee', array[]::text[], 'I would like a coffee', 2),
            (lesson_id, 'matching',
              'Match these ' || lang.name || ' food words to English',
              'Bread:Bread|Water:Water|Coffee:Coffee|Wine:Wine',
              array[]::text[], 'Food and drink', 3),
            (lesson_id, 'listening',
              'Listen — what did the customer order?',
              'Coffee and bread', array['Water and salad','Wine and steak','Tea and cake'],
              'Coffee and bread', 4),
            (lesson_id, 'speaking',
              'Order out loud in ' || lang.name || ': "The bill, please."',
              'The bill, please', array[]::text[], 'The bill, please', 5);

        elsif tier = 2 and lesson_idx = 3 then
          -- Past Tense Basics
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'In ' || lang.name || ', which is the past tense of "to go"?',
              'went', array['go','going','will go'], 'went', 1),
            (lesson_id, 'fill_blank',
              'Past tense in ' || lang.name || ': "Yesterday I ___ to the market"',
              'went', array[]::text[], 'Yesterday I went to the market', 2),
            (lesson_id, 'matching',
              'Match ' || lang.name || ' present-tense verbs to their past form',
              'is:was|has:had|goes:went|does:did',
              array[]::text[], 'Past tenses', 3),
            (lesson_id, 'listening',
              'Listen — is the sentence in past or present tense?',
              'past', array['present','future','imperative'], 'past', 4),
            (lesson_id, 'speaking',
              'Say in ' || lang.name || ': "I ate breakfast this morning"',
              'I ate breakfast this morning', array[]::text[],
              'I ate breakfast this morning', 5);

        elsif tier = 2 and lesson_idx = 4 then
          -- Shopping
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'In ' || lang.name || ', which means "How much does this cost?"',
              'How much?', array['Where is it?','When does it open?','What is this?'], 'How much?', 1),
            (lesson_id, 'fill_blank',
              'Complete in ' || lang.name || ': "It costs ten ___" (currency)',
              'euros', array[]::text[], 'It costs ten euros', 2),
            (lesson_id, 'matching',
              'Match these ' || lang.name || ' shopping words to English',
              'Shop:Shop|Money:Money|Price:Price|Receipt:Receipt',
              array[]::text[], 'Shopping vocabulary', 3),
            (lesson_id, 'listening',
              'Listen — what is the total price?',
              '€25', array['€15','€35','€45'], '€25', 4),
            (lesson_id, 'speaking',
              'Ask in ' || lang.name || ': "Can I pay by card?"',
              'Can I pay by card?', array[]::text[], 'Can I pay by card?', 5);

        elsif tier = 2 and lesson_idx = 5 then
          -- Daily Routines
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'In ' || lang.name || ', which means "I wake up at seven"?',
              'I wake up at seven', array['I sleep at seven','I work at seven','I eat at seven'],
              'I wake up at seven', 1),
            (lesson_id, 'fill_blank',
              'Daily routine in ' || lang.name || ': "Every morning I ___" (drink coffee)',
              'drink coffee', array[]::text[], 'Every morning I drink coffee', 2),
            (lesson_id, 'matching',
              'Match these ' || lang.name || ' routine verbs to English',
              'Wake up:Wake up|Eat:Eat|Work:Work|Sleep:Sleep',
              array[]::text[], 'Routine verbs', 3),
            (lesson_id, 'listening',
              'Listen — what time does the speaker start work?',
              '9am', array['8am','10am','noon'], '9am', 4),
            (lesson_id, 'speaking',
              'Describe your morning in ' || lang.name || ': "I wake up, eat breakfast and go to work."',
              'I wake up, eat breakfast and go to work', array[]::text[],
              'Describe a morning routine', 5);

        elsif tier = 3 and lesson_idx = 1 then
          -- Subjunctive Mood
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'Which sentence uses the ' || lang.name || ' subjunctive?',
              'I hope that he comes', array['He comes home','He came home','He will come home'],
              'Subjunctive: I hope that he comes', 1),
            (lesson_id, 'fill_blank',
              'Use the ' || lang.name || ' subjunctive: "It is important that you ___ here" (be)',
              'be', array[]::text[], 'It is important that you be here', 2),
            (lesson_id, 'matching',
              'Match these ' || lang.name || ' verbs (indicative → subjunctive)',
              'is:be|has:have|goes:go|does:do',
              array[]::text[], 'Indicative vs subjunctive', 3),
            (lesson_id, 'listening',
              'Listen — is the verb in indicative or subjunctive mood?',
              'subjunctive', array['indicative','imperative','infinitive'], 'subjunctive', 4),
            (lesson_id, 'speaking',
              'Say in ' || lang.name || ': "I wish that he were here."',
              'I wish that he were here', array[]::text[], 'I wish that he were here', 5);

        elsif tier = 3 and lesson_idx = 2 then
          -- Idioms & Expressions
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'What does this ' || lang.name || ' idiom mean: "to have a frog in your throat"?',
              'To be hoarse', array['To be hungry','To be lying','To be tired'], 'To be hoarse', 1),
            (lesson_id, 'fill_blank',
              'Complete the ' || lang.name || ' idiom: "It''s raining ___ and dogs"',
              'cats', array[]::text[], 'It''s raining cats and dogs', 2),
            (lesson_id, 'matching',
              'Match these ' || lang.name || ' idioms to their meanings',
              'Break a leg:Good luck|Piece of cake:Easy|Spill the beans:Reveal a secret|Hit the books:Study',
              array[]::text[], 'Common idioms', 3),
            (lesson_id, 'listening',
              'Listen — which idiom is being used?',
              'Break a leg', array['Piece of cake','Hit the road','Cold feet'], 'Break a leg', 4),
            (lesson_id, 'speaking',
              'Use this idiom in ' || lang.name || ': "It''s a piece of cake."',
              'It''s a piece of cake', array[]::text[], 'It''s a piece of cake', 5);

        elsif tier = 3 and lesson_idx = 3 then
          -- Business Vocabulary
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'Which ' || lang.name || ' phrase is most appropriate to open a business email?',
              'Dear Sir or Madam', array['Hey there','What''s up','Yo'], 'Dear Sir or Madam', 1),
            (lesson_id, 'fill_blank',
              'Business ' || lang.name || ': "Please find ___ the report" (attached)',
              'attached', array[]::text[], 'Please find attached the report', 2),
            (lesson_id, 'matching',
              'Match these ' || lang.name || ' business terms to English',
              'Meeting:Meeting|Contract:Contract|Deadline:Deadline|Invoice:Invoice',
              array[]::text[], 'Business vocabulary', 3),
            (lesson_id, 'listening',
              'Listen to the ' || lang.name || ' meeting clip — what was decided?',
              'They agreed on the budget', array['They cancelled the project','They hired a new team','They postponed the launch'],
              'They agreed on the budget', 4),
            (lesson_id, 'speaking',
              'Open a meeting in ' || lang.name || ': "Thank you all for coming today."',
              'Thank you all for coming today', array[]::text[],
              'Thank you all for coming today', 5);

        elsif tier = 3 and lesson_idx = 4 then
          -- Literature & Culture
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'Which is a well-known work of ' || lang.name || ' literature?',
              'A famous novel', array['A modern app','A pop song','A web series'], 'Sample literature reference', 1),
            (lesson_id, 'fill_blank',
              'A ' || lang.name || ' poet often wrote about ___ (a common theme)',
              'love', array[]::text[], 'Love', 2),
            (lesson_id, 'matching',
              'Match these literary terms to their meanings',
              'Metaphor:Implicit comparison|Simile:Explicit comparison|Verse:Line of poetry|Stanza:Group of lines',
              array[]::text[], 'Literary terms', 3),
            (lesson_id, 'listening',
              'Listen to the ' || lang.name || ' poem — what is the main emotion?',
              'Longing', array['Joy','Anger','Confusion'], 'Longing', 4),
            (lesson_id, 'speaking',
              'Read aloud in ' || lang.name || ' the opening line of a famous poem.',
              'Opening line of a famous poem', array[]::text[],
              'Opening line of a famous poem', 5);

        else
          -- tier = 3, lesson_idx = 5 -- Debate & Opinion
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'Which ' || lang.name || ' phrase introduces an opinion?',
              'In my opinion', array['On the other hand','For example','In conclusion'], 'In my opinion', 1),
            (lesson_id, 'fill_blank',
              'Complete: "I ___ that we should consider all options" (believe)',
              'believe', array[]::text[], 'I believe that we should consider all options', 2),
            (lesson_id, 'matching',
              'Match these debate phrases to their function',
              'In my view:Opinion|However:Contrast|Therefore:Conclusion|For instance:Example',
              array[]::text[], 'Debate connectors', 3),
            (lesson_id, 'listening',
              'Listen to the debate — what is the speaker arguing for?',
              'Renewable energy', array['Lower taxes','More tourism','Stricter laws'], 'Renewable energy', 4),
            (lesson_id, 'speaking',
              'State your opinion in ' || lang.name || ': "In my view, language learning opens doors."',
              'In my view, language learning opens doors', array[]::text[],
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

-- ============================================================
-- Languages Center — combined seed for all 26 languages
--
-- Merges 005_cefr_redesign.sql + 006_add_14_languages.sql into a single
-- paste. Adds the cefr_level column + articles/podcasts/videos tables
-- (idempotent), inserts all 26 languages, then runs the CEFR seed,
-- articles seed, podcasts seed, and videos seed in one go.
--
-- Safe to re-run: the per-language seed skips any language that already
-- has courses, so re-running over an existing CEFR install is a no-op
-- for that language.
--
-- Assumes the base tables (languages, courses, lessons, exercises,
-- user_progress, user_stats, user_achievements) exist already — i.e.
-- you have run 001_schema.sql or 003_complete_install.sql at some point.
-- ============================================================

-- ---------- 1. Schema additions ----------

alter table public.courses drop constraint if exists courses_cefr_level_check;
alter table public.courses add column if not exists cefr_level text;
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

-- ---------- 2. Seed all 26 languages ----------

insert into public.languages (name, code, flag_emoji, difficulty_grammar, difficulty_pronunciation) values
  ('Spanish',    'spanish',    '🇪🇸', 'Easy',   'Easy'),
  ('French',     'french',     '🇫🇷', 'Easy',   'Medium'),
  ('German',     'german',     '🇩🇪', 'Medium', 'Medium'),
  ('Greek',      'greek',      '🇬🇷', 'Medium', 'Medium'),
  ('Swedish',    'swedish',    '🇸🇪', 'Easy',   'Easy'),
  ('Danish',     'danish',     '🇩🇰', 'Easy',   'Medium'),
  ('Finnish',    'finnish',    '🇫🇮', 'Hard',   'Medium'),
  ('Albanian',   'albanian',   '🇦🇱', 'Hard',   'Medium'),
  ('Icelandic',  'icelandic',  '🇮🇸', 'Hard',   'Medium'),
  ('Faroese',    'faroese',    '🇫🇴', 'Easy',   'Medium'),
  ('Corsican',   'corsican',   '🇫🇷', 'Medium', 'Medium'),
  ('English',    'english',    '🇬🇧', 'Easy',   'Easy'),
  ('Chinese',    'chinese',    '🇨🇳', 'Hard',   'Hard'),
  ('Hindi',      'hindi',      '🇮🇳', 'Medium', 'Medium'),
  ('Portuguese', 'portuguese', '🇵🇹', 'Easy',   'Medium'),
  ('Bengali',    'bengali',    '🇧🇩', 'Hard',   'Medium'),
  ('Urdu',       'urdu',       '🇵🇰', 'Hard',   'Medium'),
  ('Russian',    'russian',    '🇷🇺', 'Hard',   'Medium'),
  ('Japanese',   'japanese',   '🇯🇵', 'Hard',   'Hard'),
  ('Turkish',    'turkish',    '🇹🇷', 'Medium', 'Medium'),
  ('Vietnamese', 'vietnamese', '🇻🇳', 'Hard',   'Hard'),
  ('Arabic',     'arabic',     '🇸🇦', 'Hard',   'Hard'),
  ('Korean',     'korean',     '🇰🇷', 'Hard',   'Medium'),
  ('Italian',    'italian',    '🇮🇹', 'Easy',   'Easy'),
  ('Malay',      'malay',      '🇲🇾', 'Easy',   'Easy'),
  ('Indonesian', 'indonesian', '🇮🇩', 'Easy',   'Easy')
on conflict (code) do nothing;

-- ---------- 3. CEFR seed (sections + lessons + exercises) ----------
-- Per language: 5 CEFR levels (A1 8, A2 8, B1 7, B2 7, C1 5) = 35 sections;
-- 4 lessons per section; 3 exercises per lesson (multiple_choice, listening,
-- speaking). A1 Greetings / Numbers / Colors use real per-language vocab.

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
  a1_sections text[] := array['Greetings','Numbers','Colors','Family','Food','Time','Weather','Shopping'];
  a2_sections text[] := array['Daily Routines','Transport','Health','Hobbies','Work','Directions','Feelings','Celebrations'];
  b1_sections text[] := array['Travel','News & Media','Environment','Relationships','Culture','Money','Education'];
  b2_sections text[] := array['Politics','Technology','Philosophy','Literature','Business','Science','Arts'];
  c1_sections text[] := array['Idioms & Expressions','Advanced Grammar','Formal Writing','Debate & Discussion','Native Content'];
  v_hello text; v_thanks text; v_goodbye text;
  v_please text := 'Please';
  v_n1 text; v_n2 text; v_n3 text; v_n4 text;
  v_red text; v_blue text; v_green text; v_yellow text;
begin
  for lang in select id, code, name from public.languages order by id loop
    if exists (select 1 from public.courses where language_id = lang.id) then
      continue;
    end if;

    case lang.code
      -- Original 12 -----------------------------------------------------
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
      -- New 14 ----------------------------------------------------------
      when 'chinese' then
        v_hello := '你好'; v_thanks := '谢谢'; v_goodbye := '再见';
        v_n1 := '一'; v_n2 := '二'; v_n3 := '三'; v_n4 := '四';
        v_red := '红色'; v_blue := '蓝色'; v_green := '绿色'; v_yellow := '黄色';
      when 'hindi' then
        v_hello := 'नमस्ते'; v_thanks := 'धन्यवाद'; v_goodbye := 'अलविदा';
        v_n1 := 'एक'; v_n2 := 'दो'; v_n3 := 'तीन'; v_n4 := 'चार';
        v_red := 'लाल'; v_blue := 'नीला'; v_green := 'हरा'; v_yellow := 'पीला';
      when 'portuguese' then
        v_hello := 'Olá'; v_thanks := 'Obrigado'; v_goodbye := 'Adeus';
        v_n1 := 'Um'; v_n2 := 'Dois'; v_n3 := 'Três'; v_n4 := 'Quatro';
        v_red := 'Vermelho'; v_blue := 'Azul'; v_green := 'Verde'; v_yellow := 'Amarelo';
      when 'bengali' then
        v_hello := 'হ্যালো'; v_thanks := 'ধন্যবাদ'; v_goodbye := 'বিদায়';
        v_n1 := 'এক'; v_n2 := 'দুই'; v_n3 := 'তিন'; v_n4 := 'চার';
        v_red := 'লাল'; v_blue := 'নীল'; v_green := 'সবুজ'; v_yellow := 'হলুদ';
      when 'urdu' then
        v_hello := 'ہیلو'; v_thanks := 'شکریہ'; v_goodbye := 'الوداع';
        v_n1 := 'ایک'; v_n2 := 'دو'; v_n3 := 'تین'; v_n4 := 'چار';
        v_red := 'سرخ'; v_blue := 'نیلا'; v_green := 'سبز'; v_yellow := 'پیلا';
      when 'russian' then
        v_hello := 'Привет'; v_thanks := 'Спасибо'; v_goodbye := 'Пока';
        v_n1 := 'Один'; v_n2 := 'Два'; v_n3 := 'Три'; v_n4 := 'Четыре';
        v_red := 'Красный'; v_blue := 'Синий'; v_green := 'Зелёный'; v_yellow := 'Жёлтый';
      when 'japanese' then
        v_hello := 'こんにちは'; v_thanks := 'ありがとう'; v_goodbye := 'さようなら';
        v_n1 := '一'; v_n2 := '二'; v_n3 := '三'; v_n4 := '四';
        v_red := '赤'; v_blue := '青'; v_green := '緑'; v_yellow := '黄';
      when 'turkish' then
        v_hello := 'Merhaba'; v_thanks := 'Teşekkürler'; v_goodbye := 'Hoşçakal';
        v_n1 := 'Bir'; v_n2 := 'İki'; v_n3 := 'Üç'; v_n4 := 'Dört';
        v_red := 'Kırmızı'; v_blue := 'Mavi'; v_green := 'Yeşil'; v_yellow := 'Sarı';
      when 'vietnamese' then
        v_hello := 'Xin chào'; v_thanks := 'Cảm ơn'; v_goodbye := 'Tạm biệt';
        v_n1 := 'Một'; v_n2 := 'Hai'; v_n3 := 'Ba'; v_n4 := 'Bốn';
        v_red := 'Đỏ'; v_blue := 'Xanh dương'; v_green := 'Xanh lá'; v_yellow := 'Vàng';
      when 'arabic' then
        v_hello := 'مرحباً'; v_thanks := 'شكراً'; v_goodbye := 'مع السلامة';
        v_n1 := 'واحد'; v_n2 := 'اثنان'; v_n3 := 'ثلاثة'; v_n4 := 'أربعة';
        v_red := 'أحمر'; v_blue := 'أزرق'; v_green := 'أخضر'; v_yellow := 'أصفر';
      when 'korean' then
        v_hello := '안녕하세요'; v_thanks := '감사합니다'; v_goodbye := '안녕히 가세요';
        v_n1 := '하나'; v_n2 := '둘'; v_n3 := '셋'; v_n4 := '넷';
        v_red := '빨강'; v_blue := '파랑'; v_green := '초록'; v_yellow := '노랑';
      when 'italian' then
        v_hello := 'Ciao'; v_thanks := 'Grazie'; v_goodbye := 'Arrivederci';
        v_n1 := 'Uno'; v_n2 := 'Due'; v_n3 := 'Tre'; v_n4 := 'Quattro';
        v_red := 'Rosso'; v_blue := 'Blu'; v_green := 'Verde'; v_yellow := 'Giallo';
      when 'malay' then
        v_hello := 'Hai'; v_thanks := 'Terima kasih'; v_goodbye := 'Selamat tinggal';
        v_n1 := 'Satu'; v_n2 := 'Dua'; v_n3 := 'Tiga'; v_n4 := 'Empat';
        v_red := 'Merah'; v_blue := 'Biru'; v_green := 'Hijau'; v_yellow := 'Kuning';
      when 'indonesian' then
        v_hello := 'Halo'; v_thanks := 'Terima kasih'; v_goodbye := 'Selamat tinggal';
        v_n1 := 'Satu'; v_n2 := 'Dua'; v_n3 := 'Tiga'; v_n4 := 'Empat';
        v_red := 'Merah'; v_blue := 'Biru'; v_green := 'Hijau'; v_yellow := 'Kuning';
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

          if current_level = 'A1' and section_title = 'Greetings' then
            insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
              (lesson_id, 'multiple_choice', 'How do you say Hello in ' || lang.name, v_hello, array[v_thanks, v_goodbye, v_please], 'Hello', 1),
              (lesson_id, 'listening',       'Listen and pick the ' || lang.name || ' word you hear', v_hello, array[v_thanks, v_goodbye, v_please], 'Hello', 2),
              (lesson_id, 'speaking',        'Say it out loud in ' || lang.name, v_hello, '{}'::text[], 'Hello', 3);
          elsif current_level = 'A1' and section_title = 'Numbers' then
            insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
              (lesson_id, 'multiple_choice', 'Which is the number three in ' || lang.name, v_n3, array[v_n1, v_n2, v_n4], '3', 1),
              (lesson_id, 'listening',       'Listen and pick the ' || lang.name || ' number you hear', v_n2, array[v_n1, v_n3, v_n4], '2', 2),
              (lesson_id, 'speaking',        'Count out loud in ' || lang.name, v_n1 || ' ' || v_n2 || ' ' || v_n3, '{}'::text[], '1, 2, 3', 3);
          elsif current_level = 'A1' and section_title = 'Colors' then
            insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
              (lesson_id, 'multiple_choice', 'Which is red in ' || lang.name, v_red, array[v_blue, v_green, v_yellow], 'Red', 1),
              (lesson_id, 'listening',       'Listen and pick the ' || lang.name || ' colour you hear', v_green, array[v_red, v_blue, v_yellow], 'Green', 2),
              (lesson_id, 'speaking',        'Say the three colours in ' || lang.name, v_red || ' ' || v_blue || ' ' || v_green, '{}'::text[], 'Red Blue Green', 3);
          else
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

  -- Lock cefr_level NOT NULL once every course row has one set.
  if not exists (select 1 from public.courses where cefr_level is null) then
    alter table public.courses alter column cefr_level set not null;
  end if;
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
-- Done. After running this you'll have:
--   26 languages
--  910 courses (35 sections × 26 langs)
-- 3640 lessons (4 lessons × 910 courses)
-- 10920 exercises (3 per lesson)
--   78 articles (3 per language)
--   78 podcasts (3 per language)
--   78 videos   (3 per language)
-- ============================================================

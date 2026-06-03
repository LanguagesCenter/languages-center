-- 020_placement_exam.sql
-- Placement exam infrastructure: questions, payments, attempts.
-- Includes A1 Spanish seed (40 questions: 15 vocab + 10 listening + 8 speaking + 7 writing).
-- RLS: users can only see their own payments and attempts.

-- ============== QUESTIONS ==============
create table if not exists public.placement_exam_questions (
  id bigint generated always as identity primary key,
  language_id bigint not null references public.languages(id) on delete cascade,
  level text not null check (level in ('A1','A2','B1','B2','C1')),
  category text not null check (category in ('vocabulary','listening','speaking','writing')),
  question text not null,
  correct_answer text not null,
  wrong_answers text[] default '{}',
  hint text,
  order_index int not null default 0,
  created_at timestamptz default now()
);

create index if not exists idx_placement_questions_lang_level
  on public.placement_exam_questions(language_id, level, order_index);

alter table public.placement_exam_questions enable row level security;
drop policy if exists "Placement questions are readable by authenticated users" on public.placement_exam_questions;
create policy "Placement questions are readable by authenticated users"
  on public.placement_exam_questions for select
  to authenticated
  using (true);

-- ============== PAYMENTS ==============
create table if not exists public.placement_exam_payments (
  id uuid default gen_random_uuid() primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  language_id bigint not null references public.languages(id) on delete cascade,
  level text not null check (level in ('A1','A2','B1','B2','C1')),
  stripe_payment_id text not null,
  paid_at timestamptz not null default now()
);

create index if not exists idx_placement_payments_user
  on public.placement_exam_payments(user_id, language_id, level);

alter table public.placement_exam_payments enable row level security;
drop policy if exists "Users see their own placement payments" on public.placement_exam_payments;
create policy "Users see their own placement payments"
  on public.placement_exam_payments for select
  using (auth.uid() = user_id);
drop policy if exists "Users can insert their own placement payments" on public.placement_exam_payments;
create policy "Users can insert their own placement payments"
  on public.placement_exam_payments for insert
  with check (auth.uid() = user_id);

-- ============== ATTEMPTS ==============
create table if not exists public.placement_exam_attempts (
  id uuid default gen_random_uuid() primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  language_id bigint not null references public.languages(id) on delete cascade,
  level text not null check (level in ('A1','A2','B1','B2','C1')),
  score_percentage int not null check (score_percentage between 0 and 100),
  vocabulary_score int not null default 0,
  listening_score int not null default 0,
  speaking_score int not null default 0,
  writing_score int not null default 0,
  passed boolean not null default false,
  completed_at timestamptz not null default now(),
  time_taken_seconds int not null default 0,
  last_attempt_at timestamptz not null default now()
);

create index if not exists idx_placement_attempts_user
  on public.placement_exam_attempts(user_id, language_id, level, completed_at desc);

alter table public.placement_exam_attempts enable row level security;
drop policy if exists "Users see their own placement attempts" on public.placement_exam_attempts;
create policy "Users see their own placement attempts"
  on public.placement_exam_attempts for select
  using (auth.uid() = user_id);
drop policy if exists "Users can insert their own placement attempts" on public.placement_exam_attempts;
create policy "Users can insert their own placement attempts"
  on public.placement_exam_attempts for insert
  with check (auth.uid() = user_id);

-- ============== SEED: Spanish A1 (40 questions) ==============
do $$
declare
  v_lang_id bigint;
begin
  select id into v_lang_id from public.languages where code = 'spanish';
  if v_lang_id is null then
    raise exception 'Spanish language not found';
  end if;

  -- Idempotent: clear existing A1 Spanish placement questions before reseeding.
  delete from public.placement_exam_questions where language_id = v_lang_id and level = 'A1';

  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, hint, order_index) values
    -- ---------- VOCABULARY (15) ----------
    (v_lang_id,'A1','vocabulary','How do you say "Hello" in Spanish?','Hola',array['Adiós','Gracias','Sí'],'A greeting',1),
    (v_lang_id,'A1','vocabulary','How do you say "Goodbye" in Spanish?','Adiós',array['Hola','Buenos días','Por favor'],'A farewell',2),
    (v_lang_id,'A1','vocabulary','How do you say "Mother" in Spanish?','madre',array['padre','hermana','abuela'],'Family',3),
    (v_lang_id,'A1','vocabulary','How do you say "Water" in Spanish?','agua',array['aceite','azúcar','aire'],'A drink',4),
    (v_lang_id,'A1','vocabulary','What is "red" in Spanish?','rojo',array['rosa','negro','verde'],'A color',5),
    (v_lang_id,'A1','vocabulary','What is "blue" in Spanish?','azul',array['amarillo','blanco','azulejo'],'A color',6),
    (v_lang_id,'A1','vocabulary','How do you say "dog"?','perro',array['gato','pájaro','pez'],'An animal',7),
    (v_lang_id,'A1','vocabulary','How do you say "house"?','casa',array['cama','calle','cara'],'A place',8),
    (v_lang_id,'A1','vocabulary','What is "one"?','uno',array['dos','tres','siete'],'A number',9),
    (v_lang_id,'A1','vocabulary','What is "thank you"?','gracias',array['de nada','por favor','perdón'],'Polite',10),
    (v_lang_id,'A1','vocabulary','How do you say "head"?','cabeza',array['mano','pie','ojo'],'Body',11),
    (v_lang_id,'A1','vocabulary','How do you say "Monday"?','lunes',array['martes','viernes','luna'],'Day of week',12),
    (v_lang_id,'A1','vocabulary','Which verb means "to have"?','tener',array['ser','estar','ir'],'Possession',13),
    (v_lang_id,'A1','vocabulary','Which is "big"?','grande',array['pequeño','poco','alto'],'Size',14),
    (v_lang_id,'A1','vocabulary','What does "buenos días" mean?','good morning',array['good night','goodbye','please'],'Time of day',15),
    -- ---------- LISTENING (10) ----------
    -- The TTS reads `question` (Spanish). User picks the English meaning.
    (v_lang_id,'A1','listening','Hola',array['Goodbye','Thank you','Please']::text[],'Hello, hi',null,16),
    (v_lang_id,'A1','listening','Buenos días',array['Good night','See you later','Pleased to meet you']::text[],'Good morning',null,17),
    (v_lang_id,'A1','listening','¿Cómo estás?',array['What is your name?','Where are you from?','How old are you?']::text[],'How are you?',null,18),
    (v_lang_id,'A1','listening','Me llamo Ana',array['Ana calls me','I see Ana','I know Ana']::text[],'My name is Ana',null,19),
    (v_lang_id,'A1','listening','Tengo veinte años',array['I have 20 dogs','I am 20 years old','I have 20 books']::text[],'I am 20 years old',null,20),
    (v_lang_id,'A1','listening','Hace sol',array['It is cold','It is raining','It is windy']::text[],'It is sunny',null,21),
    (v_lang_id,'A1','listening','Quiero un café',array['I drink coffee','I want a coffee','I love coffee']::text[],'I want a coffee',null,22),
    (v_lang_id,'A1','listening','Voy al trabajo',array['I am at work','I work hard','I love work']::text[],'I go to work',null,23),
    (v_lang_id,'A1','listening','Me duele la cabeza',array['I am hungry','My head hurts','I am tired']::text[],'My head hurts',null,24),
    (v_lang_id,'A1','listening','¿Cuánto cuesta?',array['How are you?','What is it called?','Where is it?']::text[],'How much does it cost?',null,25),
    -- ---------- SPEAKING (8) ----------
    -- User pronounces `correct_answer` (Spanish). The question is an instruction.
    (v_lang_id,'A1','speaking','Say this phrase aloud: "Hola, ¿cómo estás?"','Hola, ¿cómo estás?',array[]::text[],'Hi, how are you?',26),
    (v_lang_id,'A1','speaking','Say this phrase aloud: "Me llamo Carlos."','Me llamo Carlos',array[]::text[],'My name is Carlos.',27),
    (v_lang_id,'A1','speaking','Say this phrase aloud: "Soy de México."','Soy de México',array[]::text[],'I am from Mexico.',28),
    (v_lang_id,'A1','speaking','Say this phrase aloud: "Tengo hambre."','Tengo hambre',array[]::text[],'I am hungry.',29),
    (v_lang_id,'A1','speaking','Say this phrase aloud: "Hace mucho calor."','Hace mucho calor',array[]::text[],'It is very hot.',30),
    (v_lang_id,'A1','speaking','Say this phrase aloud: "Mi familia es grande."','Mi familia es grande',array[]::text[],'My family is big.',31),
    (v_lang_id,'A1','speaking','Say this phrase aloud: "Voy a casa."','Voy a casa',array[]::text[],'I go home.',32),
    (v_lang_id,'A1','speaking','Say this phrase aloud: "Hasta mañana."','Hasta mañana',array[]::text[],'See you tomorrow.',33),
    -- ---------- WRITING (7) ----------
    -- User types Spanish translation of English `question`.
    (v_lang_id,'A1','writing','Translate to Spanish: "Hello"','Hola',array[]::text[],'Greeting',34),
    (v_lang_id,'A1','writing','Translate to Spanish: "Good morning"','Buenos días',array[]::text[],'Morning greeting',35),
    (v_lang_id,'A1','writing','Translate to Spanish: "My name is Pedro"','Me llamo Pedro',array[]::text[],'Use llamarse',36),
    (v_lang_id,'A1','writing','Translate to Spanish: "I am hungry"','Tengo hambre',array[]::text[],'Use tener',37),
    (v_lang_id,'A1','writing','Translate to Spanish: "It is cold"','Hace frío',array[]::text[],'Use hacer for weather',38),
    (v_lang_id,'A1','writing','Translate to Spanish: "I have a brother"','Tengo un hermano',array[]::text[],'Use tener',39),
    (v_lang_id,'A1','writing','Translate to Spanish: "How much does it cost?"','¿Cuánto cuesta?',array[]::text[],'Inverted ¿',40);
end $$;

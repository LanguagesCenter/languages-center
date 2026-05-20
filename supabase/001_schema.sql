-- ============================================================
-- Languages Center — Database Schema
-- Run this in the Supabase SQL Editor
-- ============================================================

-- 1. Languages
create table public.languages (
  id bigint generated always as identity primary key,
  name text not null,
  code text not null unique,
  flag_emoji text,
  difficulty_grammar text not null check (difficulty_grammar in ('Easy', 'Medium', 'Hard')),
  difficulty_pronunciation text not null check (difficulty_pronunciation in ('Easy', 'Medium', 'Hard')),
  created_at timestamptz default now()
);

-- 2. Courses
create table public.courses (
  id bigint generated always as identity primary key,
  language_id bigint not null references public.languages(id) on delete cascade,
  title text not null,
  description text,
  order_index int not null,
  created_at timestamptz default now()
);

-- 3. Lessons
create table public.lessons (
  id bigint generated always as identity primary key,
  course_id bigint not null references public.courses(id) on delete cascade,
  title text not null,
  description text,
  type text not null check (type in ('vocabulary', 'grammar', 'phrases', 'listening', 'speaking')),
  order_index int not null,
  xp_reward int not null default 10,
  created_at timestamptz default now()
);

-- 4. Exercises
create table public.exercises (
  id bigint generated always as identity primary key,
  lesson_id bigint not null references public.lessons(id) on delete cascade,
  type text not null check (type in ('multiple_choice', 'fill_blank', 'matching', 'listening', 'speaking')),
  question text not null,
  correct_answer text not null,
  wrong_answers text[] default '{}',
  audio_url text,
  translation text,
  order_index int not null,
  created_at timestamptz default now()
);

-- 5. User Progress
create table public.user_progress (
  id uuid default gen_random_uuid() primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  lesson_id bigint not null references public.lessons(id) on delete cascade,
  completed boolean default false,
  score int default 0,
  completed_at timestamptz,
  created_at timestamptz default now(),
  unique(user_id, lesson_id)
);

-- 6. User Stats
create table public.user_stats (
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

-- 7. User Achievements
create table public.user_achievements (
  id uuid default gen_random_uuid() primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  achievement_type text not null,
  earned_at timestamptz default now(),
  unique(user_id, achievement_type)
);

-- ============================================================
-- Indexes
-- ============================================================
create index idx_courses_language on public.courses(language_id);
create index idx_lessons_course on public.lessons(course_id);
create index idx_exercises_lesson on public.exercises(lesson_id);
create index idx_user_progress_user on public.user_progress(user_id);
create index idx_user_progress_lesson on public.user_progress(lesson_id);
create index idx_user_stats_user on public.user_stats(user_id);
create index idx_user_achievements_user on public.user_achievements(user_id);

-- ============================================================
-- Row Level Security
-- ============================================================

-- Content tables: readable by everyone
alter table public.languages enable row level security;
alter table public.courses enable row level security;
alter table public.lessons enable row level security;
alter table public.exercises enable row level security;

create policy "Languages are viewable by everyone" on public.languages for select using (true);
create policy "Courses are viewable by everyone" on public.courses for select using (true);
create policy "Lessons are viewable by everyone" on public.lessons for select using (true);
create policy "Exercises are viewable by everyone" on public.exercises for select using (true);

-- User tables: users can only access their own data
alter table public.user_progress enable row level security;
alter table public.user_stats enable row level security;
alter table public.user_achievements enable row level security;

create policy "Users can view own progress" on public.user_progress for select using (auth.uid() = user_id);
create policy "Users can insert own progress" on public.user_progress for insert with check (auth.uid() = user_id);
create policy "Users can update own progress" on public.user_progress for update using (auth.uid() = user_id);

create policy "Users can view own stats" on public.user_stats for select using (auth.uid() = user_id);
create policy "Users can insert own stats" on public.user_stats for insert with check (auth.uid() = user_id);
create policy "Users can update own stats" on public.user_stats for update using (auth.uid() = user_id);

create policy "Users can view own achievements" on public.user_achievements for select using (auth.uid() = user_id);
create policy "Users can insert own achievements" on public.user_achievements for insert with check (auth.uid() = user_id);

-- 038_lesson_graded_responses.sql
-- Storage for every AI-graded writing / speaking / listening response a user
-- produces inside a lesson. Powers the instant-feedback panel and lets us
-- show progress over time on the dashboard later.
-- Idempotent.

create table if not exists public.lesson_graded_responses (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  -- Nullable so the system still records a response if the lesson row has
  -- been pruned. We don't want to lose feedback history because curriculum
  -- changed.
  lesson_id bigint references public.lessons(id) on delete set null,
  exercise_id bigint references public.exercises(id) on delete set null,
  type text not null check (type in ('writing','speaking','listening')),
  prompt text not null,
  response text not null,
  score int not null check (score between 0 and 10),
  feedback text,
  corrected_version text,
  encouragement text,
  created_at timestamptz not null default now()
);

create index if not exists idx_lesson_graded_responses_user
  on public.lesson_graded_responses(user_id, created_at desc);
create index if not exists idx_lesson_graded_responses_lesson
  on public.lesson_graded_responses(lesson_id);

alter table public.lesson_graded_responses enable row level security;

drop policy if exists "Users see their own graded responses"
  on public.lesson_graded_responses;
create policy "Users see their own graded responses"
  on public.lesson_graded_responses for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert their own graded responses"
  on public.lesson_graded_responses;
create policy "Users can insert their own graded responses"
  on public.lesson_graded_responses for insert
  with check (auth.uid() = user_id);

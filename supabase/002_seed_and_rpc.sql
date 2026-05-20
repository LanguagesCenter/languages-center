-- ============================================================
-- Languages Center — User profile + content seed + RPC
-- Run this AFTER 001_schema.sql in the Supabase SQL Editor
-- ============================================================

-- ---------- user_profile (global XP / streak) ----------
create table if not exists public.user_profile (
  user_id uuid primary key references auth.users(id) on delete cascade,
  total_xp int not null default 0,
  current_streak int not null default 0,
  longest_streak int not null default 0,
  last_activity_date date,
  updated_at timestamptz default now()
);

alter table public.user_profile enable row level security;

drop policy if exists "Users can view own profile" on public.user_profile;
drop policy if exists "Users can insert own profile" on public.user_profile;
drop policy if exists "Users can update own profile" on public.user_profile;

create policy "Users can view own profile" on public.user_profile
  for select using (auth.uid() = user_id);
create policy "Users can insert own profile" on public.user_profile
  for insert with check (auth.uid() = user_id);
create policy "Users can update own profile" on public.user_profile
  for update using (auth.uid() = user_id);

-- ---------- Seed languages ----------
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

-- ---------- Seed courses + lessons + exercises ----------
-- For each language, create three courses (Beginner / Intermediate / Advanced),
-- five lessons per course, and four exercises per lesson.
do $seed$
declare
  lang record;
  course_tiers text[] := array['Beginner', 'Intermediate', 'Advanced'];
  course_blurbs text[] := array[
    'Start your journey with the essentials.',
    'Build fluency with everyday topics.',
    'Master complex grammar and nuance.'
  ];
  lesson_topics text[][] := array[
    array['Greetings', 'Numbers 1-10', 'Colours', 'Family Members', 'Common Verbs'],
    array['Travel & Directions', 'Food & Dining', 'Past Tense Basics', 'Shopping', 'Daily Routines'],
    array['Subjunctive Mood', 'Idioms & Expressions', 'Business Vocabulary', 'Literature & Culture', 'Debate & Opinion']
  ];
  lesson_types text[] := array['vocabulary', 'vocabulary', 'grammar', 'phrases', 'phrases'];
  course_id bigint;
  lesson_id bigint;
  tier_idx int;
  lesson_idx int;
begin
  for lang in select id, name from public.languages order by id loop
    for tier_idx in 1..3 loop
      insert into public.courses (language_id, title, description, order_index)
      values (lang.id, course_tiers[tier_idx], course_blurbs[tier_idx], tier_idx)
      returning id into course_id;

      for lesson_idx in 1..5 loop
        insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
        values (
          course_id,
          lesson_topics[tier_idx][lesson_idx],
          'Learn ' || lesson_topics[tier_idx][lesson_idx] || ' in ' || lang.name,
          lesson_types[lesson_idx],
          lesson_idx,
          10 + (tier_idx - 1) * 5
        )
        returning id into lesson_id;

        -- Four exercises per lesson: 2 multiple choice, 1 fill blank, 1 matching
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
          (lesson_id, 'multiple_choice',
            'Which word means "' || lesson_topics[tier_idx][lesson_idx] || '" in ' || lang.name || '?',
            lang.name || ': ' || lesson_topics[tier_idx][lesson_idx],
            array[
              lang.name || ': option B',
              lang.name || ': option C',
              lang.name || ': option D'
            ],
            lesson_topics[tier_idx][lesson_idx],
            1),
          (lesson_id, 'multiple_choice',
            'Choose the correct translation of "Hello" in ' || lang.name || '.',
            lang.name || ' hello',
            array[
              lang.name || ' goodbye',
              lang.name || ' please',
              lang.name || ' thanks'
            ],
            'Hello',
            2),
          (lesson_id, 'fill_blank',
            'Fill in: "I am learning ___" (' || lang.name || ' for ' || lesson_topics[tier_idx][lesson_idx] || ')',
            lower(lang.name),
            array[]::text[],
            'I am learning ' || lang.name,
            3),
          (lesson_id, 'matching',
            'Match the ' || lang.name || ' words to their English meaning',
            'one:uno|two:dos|three:tres|four:cuatro',
            array[]::text[],
            'Numbers',
            4);
      end loop;
    end loop;
  end loop;
end
$seed$;

-- ---------- complete_lesson RPC ----------
-- Atomically marks a lesson complete, awards XP, and updates streak.
create or replace function public.complete_lesson(p_lesson_id bigint)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_xp int;
  v_language_id bigint;
  v_today date := current_date;
  v_yesterday date := current_date - 1;
  v_was_completed boolean;
  v_new_streak int;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  select l.xp_reward, c.language_id
    into v_xp, v_language_id
  from public.lessons l
  join public.courses c on c.id = l.course_id
  where l.id = p_lesson_id;

  if v_xp is null then
    raise exception 'Lesson not found';
  end if;

  select coalesce(completed, false)
    into v_was_completed
  from public.user_progress
  where user_id = v_user_id and lesson_id = p_lesson_id;

  v_was_completed := coalesce(v_was_completed, false);

  insert into public.user_progress (user_id, lesson_id, completed, score, completed_at)
  values (v_user_id, p_lesson_id, true, v_xp, now())
  on conflict (user_id, lesson_id) do update set
    completed = true,
    score = greatest(public.user_progress.score, v_xp),
    completed_at = now();

  if v_was_completed then
    return json_build_object('xp_earned', 0, 'already_completed', true);
  end if;

  -- per-language stats
  insert into public.user_stats (user_id, language_id, total_xp, current_streak, longest_streak, last_activity_date)
  values (v_user_id, v_language_id, v_xp, 1, 1, v_today)
  on conflict (user_id, language_id) do update set
    total_xp = public.user_stats.total_xp + v_xp,
    current_streak = case
      when public.user_stats.last_activity_date = v_today then public.user_stats.current_streak
      when public.user_stats.last_activity_date = v_yesterday then public.user_stats.current_streak + 1
      else 1
    end,
    longest_streak = greatest(
      public.user_stats.longest_streak,
      case
        when public.user_stats.last_activity_date = v_today then public.user_stats.current_streak
        when public.user_stats.last_activity_date = v_yesterday then public.user_stats.current_streak + 1
        else 1
      end
    ),
    last_activity_date = v_today;

  -- global profile streak (across all languages)
  insert into public.user_profile (user_id, total_xp, current_streak, longest_streak, last_activity_date)
  values (v_user_id, v_xp, 1, 1, v_today)
  on conflict (user_id) do update set
    total_xp = public.user_profile.total_xp + v_xp,
    current_streak = case
      when public.user_profile.last_activity_date = v_today then public.user_profile.current_streak
      when public.user_profile.last_activity_date = v_yesterday then public.user_profile.current_streak + 1
      else 1
    end,
    longest_streak = greatest(
      public.user_profile.longest_streak,
      case
        when public.user_profile.last_activity_date = v_today then public.user_profile.current_streak
        when public.user_profile.last_activity_date = v_yesterday then public.user_profile.current_streak + 1
        else 1
      end
    ),
    last_activity_date = v_today,
    updated_at = now()
  returning current_streak into v_new_streak;

  return json_build_object(
    'xp_earned', v_xp,
    'already_completed', false,
    'current_streak', v_new_streak
  );
end;
$$;

grant execute on function public.complete_lesson(bigint) to authenticated;

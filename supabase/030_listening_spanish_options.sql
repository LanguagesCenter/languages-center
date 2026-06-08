-- 030_listening_spanish_options.sql
-- Fix listening exercises so the answer options are in Spanish, not English.
--
-- Before: question read "Listen and pick the English meaning.",
-- correct_answer was a Spanish phrase (also the audio source), and
-- wrong_answers were three English distractors. When shuffled, the only
-- Spanish option was always the right one — a free pass.
--
-- After: question reads "What did you hear? Pick the Spanish phrase.",
-- correct_answer is still the Spanish phrase the TTS plays, and
-- wrong_answers are three OTHER Spanish phrases drawn from the same CEFR
-- level's listening pool. The English meaning still lives on the
-- `translation` column and is shown by the lesson UI as a hint only after
-- the user answers.
--
-- Distractors are picked from the curriculum itself — no hand-curation.
-- The pool is whatever listening exercises already exist at the same CEFR
-- level. Re-running the migration reshuffles the distractors, which is
-- harmless.
--
-- Also rewrites the listening rows in placement_exam_questions, where the
-- original 020 / 022 had the same bug.

-- ============== PART 1: exercises (lesson questions) ==============
do $$
declare
  e record;
  pool text[];
begin
  for e in
    select ex.id, ex.correct_answer, c.cefr_level
    from public.exercises ex
    join public.lessons l on l.id = ex.lesson_id
    join public.courses c on c.id = l.course_id
    join public.languages lang on lang.id = c.language_id
    where lang.code = 'spanish' and ex.type = 'listening'
  loop
    select array_agg(other_answer)
    from (
      select distinct ex2.correct_answer as other_answer
      from public.exercises ex2
      join public.lessons l2 on l2.id = ex2.lesson_id
      join public.courses c2 on c2.id = l2.course_id
      join public.languages lang2 on lang2.id = c2.language_id
      where lang2.code = 'spanish'
        and ex2.type = 'listening'
        and c2.cefr_level = e.cefr_level
        and ex2.id <> e.id
        and ex2.correct_answer <> e.correct_answer
      order by random()
      limit 3
    ) sub
    into pool;

    update public.exercises
    set wrong_answers = coalesce(pool, array[]::text[]),
        question      = 'What did you hear? Pick the Spanish phrase.'
    where id = e.id;
  end loop;
end $$;

-- ============== PART 2: placement_exam_questions ==============
-- Repair the original 020 / 022 data, which stored Spanish in `question`
-- and English distractors in `wrong_answers`. After this block:
--   question       = Spanish phrase (still the audio source)
--   correct_answer = same Spanish phrase (matches what the user picks)
--   wrong_answers  = 3 other Spanish phrases at the same level
--   hint           = English meaning (already set in 020 / 022)

do $$
declare
  v_lang_id bigint;
  q record;
  pool text[];
begin
  select id into v_lang_id from public.languages where code = 'spanish';
  if v_lang_id is null then
    raise notice 'Spanish language not found — skipping placement fix';
    return;
  end if;

  for q in
    select id, level, question
    from public.placement_exam_questions
    where language_id = v_lang_id and category = 'listening'
  loop
    select array_agg(other_q)
    from (
      select distinct q2.question as other_q
      from public.placement_exam_questions q2
      where q2.language_id = v_lang_id
        and q2.category = 'listening'
        and q2.level = q.level
        and q2.id <> q.id
        and q2.question <> q.question
      order by random()
      limit 3
    ) sub
    into pool;

    update public.placement_exam_questions
    set correct_answer = question,
        wrong_answers  = coalesce(pool, array[]::text[])
    where id = q.id;
  end loop;
end $$;

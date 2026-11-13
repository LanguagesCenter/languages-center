-- ============================================================
-- 058_traveler_skipped_speaking.sql
--
-- Backs the "I can't speak now" button on every speaking exercise in
-- the Traveler's Course. Tapping Skip inserts a row here (RLS: self).
-- The city-travel home page reads `WHERE completed_at IS NULL` to
-- show a mic badge with a count, and the Speaking Practice page
-- lists every skipped exercise so the learner can come back later.
-- When they pass the exercise, completed_at is stamped and the row
-- disappears from the badge.
-- ============================================================

CREATE TABLE IF NOT EXISTS public.traveler_skipped_speaking (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  traveler_lesson_id  BIGINT NOT NULL REFERENCES public.traveler_lessons(id) ON DELETE CASCADE,
  -- Stable identifier for which exercise inside the lesson was skipped.
  -- Matches the runner's internal ref: "decode:3" or "endquiz:2".
  exercise_ref        TEXT NOT NULL,
  prompt              TEXT NOT NULL,
  expected            TEXT NOT NULL,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  -- Null until the learner comes back and completes the exercise
  -- successfully from the Speaking Practice panel.
  completed_at        TIMESTAMPTZ,
  -- One skip row per (user, lesson, exercise) — re-skipping bumps
  -- created_at via ON CONFLICT DO UPDATE, doesn't create duplicates.
  UNIQUE (user_id, traveler_lesson_id, exercise_ref)
);

CREATE INDEX IF NOT EXISTS traveler_skipped_speaking_user_open_idx
  ON public.traveler_skipped_speaking (user_id, completed_at)
  WHERE completed_at IS NULL;

CREATE INDEX IF NOT EXISTS traveler_skipped_speaking_user_lesson_idx
  ON public.traveler_skipped_speaking (user_id, traveler_lesson_id);

-- ============================================================
-- RLS — users see only their own rows.
-- ============================================================

ALTER TABLE public.traveler_skipped_speaking ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "skipped_speaking_select_own" ON public.traveler_skipped_speaking;
CREATE POLICY "skipped_speaking_select_own"
  ON public.traveler_skipped_speaking
  FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "skipped_speaking_insert_own" ON public.traveler_skipped_speaking;
CREATE POLICY "skipped_speaking_insert_own"
  ON public.traveler_skipped_speaking
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "skipped_speaking_update_own" ON public.traveler_skipped_speaking;
CREATE POLICY "skipped_speaking_update_own"
  ON public.traveler_skipped_speaking
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "skipped_speaking_delete_own" ON public.traveler_skipped_speaking;
CREATE POLICY "skipped_speaking_delete_own"
  ON public.traveler_skipped_speaking
  FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================
-- 056_traveler_v2_content_type.sql
--
-- Add 'v2_lesson' to the allowed content_type values on
-- traveler_lesson_content so the new Adventure v2 generator
-- (scripts/generate-traveler-v2.mjs) can write its single-row
-- JSONB payload per lesson.
--
-- The v2 generator emits exactly one row per lesson:
--   content_type='v2_lesson', data=<PreviewLesson JSON>
-- Everything the runner needs — opening, decodeSteps,
-- buildup, endQuiz — lives inside the data blob.
--
-- Safe to re-run. Drops the existing check by name and recreates
-- with the widened whitelist.
-- ============================================================

ALTER TABLE public.traveler_lesson_content
  DROP CONSTRAINT IF EXISTS traveler_lesson_content_content_type_check;

ALTER TABLE public.traveler_lesson_content
  ADD CONSTRAINT traveler_lesson_content_content_type_check
  CHECK (content_type IN (
    'image','dialogue','explanation','quiz',   -- legacy from 053
    'scene','sign','phrases',                  -- v1 adventure (054)
    'v2_lesson'                                -- v2 adventure (this migration)
  ));

-- Verification (should return the widened list).
SELECT conname, pg_get_constraintdef(oid) AS def
  FROM pg_constraint
 WHERE conrelid = 'public.traveler_lesson_content'::regclass
   AND conname = 'traveler_lesson_content_content_type_check';

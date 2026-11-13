-- ============================================================
-- 059_traveler_skipped_speaking_translation_check.sql
--
-- Add a JSONB column to carry the translation-check follow-up
-- question alongside each skipped speaking exercise. The runner
-- now shows a "What does this mean?" question after every speaking
-- exercise (the primary audio-production attempt + a comprehension
-- check), and the Speaking Practice page replays both.
--
-- Nullable because legacy rows don't carry one — the UI falls back
-- to the old pass-through behavior when it's null.
-- ============================================================

ALTER TABLE public.traveler_skipped_speaking
  ADD COLUMN IF NOT EXISTS translation_check JSONB;

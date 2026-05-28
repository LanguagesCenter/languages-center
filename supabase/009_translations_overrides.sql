-- Optional: per-locale title/description overrides for courses + lessons.
--
-- This is NOT required for the new UI translation to work. The app
-- already translates the standard CEFR section titles (Greetings,
-- Numbers, …) and the "Section — Lesson N" pattern entirely client-side
-- via src/lib/i18n.ts. Apply this migration only if you later want to
-- store editor-provided translations per language.
--
-- Schema:
--   title_translations / description_translations are jsonb maps keyed by
--   our UI language codes ("en", "es", "fr", …). Example:
--     {"en": "Greetings", "es": "Saludos", "fr": "Salutations"}
--
-- The app should prefer overrides[lang] when present, then fall back to
-- the client-side translate helper, then the raw column.

alter table public.courses
  add column if not exists title_translations jsonb default '{}'::jsonb,
  add column if not exists description_translations jsonb default '{}'::jsonb;

alter table public.lessons
  add column if not exists title_translations jsonb default '{}'::jsonb,
  add column if not exists description_translations jsonb default '{}'::jsonb;

create index if not exists courses_title_translations_gin
  on public.courses using gin (title_translations);

create index if not exists lessons_title_translations_gin
  on public.lessons using gin (title_translations);

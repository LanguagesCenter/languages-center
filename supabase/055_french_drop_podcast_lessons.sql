-- ============================================================
-- 055_french_drop_podcast_lessons.sql
--
-- Removes the extra "Podcast / Video" lesson (order_index = 9) from
-- every French course so the French curriculum structure matches
-- Spanish: 9 lessons per section, ending on the section test.
--
-- BEFORE  (French, 10 lessons per course)
--   1  vocabulary
--   2  grammar
--   3  phrases
--   4  listening
--   5  speaking
--   6  reading
--   7  writing
--   8  conversation
--   9  podcast          ← DELETE
--   10 unit_test
--
-- AFTER   (matches Spanish, 9 lessons per course)
--   1  vocabulary
--   2  grammar
--   3  phrases
--   4  listening
--   5  speaking
--   6  reading
--   7  writing
--   8  conversation
--   9  unit_test        ← renumbered from 10
--
-- Scope:
--   • 75 French courses total (15 sections × 5 CEFR levels)
--   • Every course has exactly 1 lesson of type 'podcast' at
--     order_index = 9 today (verified against production).
--   • 0 user_progress rows reference these podcast lessons today,
--     so the DELETE won't cascade any real user data.
--
-- Safe to re-run: the DELETE is a no-op once the rows are gone, and
-- the UPDATE only touches rows whose order_index is still 10.
-- ============================================================


-- 1. Delete every French podcast lesson.
-- ------------------------------------------------------------
DELETE FROM public.lessons
 WHERE type = 'podcast'
   AND course_id IN (
     SELECT id FROM public.courses WHERE language_id = 2
   );


-- 2. Renumber the unit test lesson from order_index = 10 → 9 in
--    every affected French course.
-- ------------------------------------------------------------
UPDATE public.lessons
   SET order_index = 9
 WHERE order_index = 10
   AND course_id IN (
     SELECT id FROM public.courses WHERE language_id = 2
   );


-- 3. Verification
--    Expected: 675 French lessons (75 courses × 9 lessons), every
--    French course has exactly 9 lessons, and the highest
--    order_index in every French course is 9.
-- ------------------------------------------------------------
SELECT 'total_french_lessons' AS metric,
       COUNT(*)::text AS value
  FROM public.lessons l
  JOIN public.courses c ON c.id = l.course_id
 WHERE c.language_id = 2
UNION ALL
SELECT 'french_courses_with_9_lessons',
       COUNT(*)::text
  FROM (
    SELECT c.id
      FROM public.courses c
      JOIN public.lessons l ON l.course_id = c.id
     WHERE c.language_id = 2
     GROUP BY c.id
    HAVING COUNT(l.id) = 9
  ) t
UNION ALL
SELECT 'french_courses_with_wrong_count',
       COUNT(*)::text
  FROM (
    SELECT c.id
      FROM public.courses c
      JOIN public.lessons l ON l.course_id = c.id
     WHERE c.language_id = 2
     GROUP BY c.id
    HAVING COUNT(l.id) <> 9
  ) t
UNION ALL
SELECT 'french_lessons_at_order_10',
       COUNT(*)::text
  FROM public.lessons l
  JOIN public.courses c ON c.id = l.course_id
 WHERE c.language_id = 2
   AND l.order_index = 10;

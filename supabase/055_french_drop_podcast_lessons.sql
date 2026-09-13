-- ============================================================
-- 055_french_drop_podcast_lessons.sql
--
-- Fix French course structure to match Spanish: 9 lessons per section,
-- ending on the section test. Removes the extra "Podcast / Video"
-- lesson from every French course (75 rows today, all at order_index
-- 9, type='podcast') and renumbers the remaining lessons in each
-- course so order_index is a gapless 1..N sequence.
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
--   10 unit_test        ← becomes 9 after renumber
--
-- AFTER   (matches Spanish, 9 lessons per course)
--   1..8 unchanged
--   9    unit_test
--
-- Scope: 75 French courses (15 sections × 5 CEFR levels). Also
-- catches any 'video'-type lesson defensively; today there are none.
--
-- Safe to re-run. The DELETE becomes a no-op once the rows are gone
-- and the renumber leaves already-sequential courses untouched.
-- ============================================================


-- 1. Delete every French podcast + video lesson.
-- ------------------------------------------------------------
DELETE FROM public.lessons
 WHERE type IN ('podcast', 'video')
   AND course_id IN (SELECT id FROM public.courses WHERE language_id = 2);


-- 2. Renumber remaining French lessons per course so order_index is
--    a gapless 1..N sequence. Two-step to avoid transient unique-key
--    conflicts on (course_id, order_index):
--      2a. Bump every French lesson into a high temporary range.
--      2b. Rewrite each lesson's order_index using ROW_NUMBER.
-- ------------------------------------------------------------
UPDATE public.lessons
   SET order_index = order_index + 1000
 WHERE course_id IN (SELECT id FROM public.courses WHERE language_id = 2);

WITH renum AS (
  SELECT id,
         ROW_NUMBER() OVER (
           PARTITION BY course_id
           ORDER BY order_index ASC
         ) AS new_order
    FROM public.lessons
   WHERE course_id IN (SELECT id FROM public.courses WHERE language_id = 2)
)
UPDATE public.lessons AS l
   SET order_index = r.new_order
  FROM renum r
 WHERE l.id = r.id;


-- 3. Verification
--    Expected:
--      total_french_lessons              = 675
--      french_courses_with_9_lessons     = 75
--      french_courses_with_wrong_count   = 0
--      max_order_index_across_french     = 9
--      french_lessons_type_podcast_video = 0
-- ------------------------------------------------------------
SELECT 'total_french_lessons' AS metric, COUNT(*)::text AS value
  FROM public.lessons l
  JOIN public.courses c ON c.id = l.course_id
 WHERE c.language_id = 2
UNION ALL
SELECT 'french_courses_with_9_lessons', COUNT(*)::text
  FROM (
    SELECT c.id
      FROM public.courses c
      JOIN public.lessons l ON l.course_id = c.id
     WHERE c.language_id = 2
     GROUP BY c.id
    HAVING COUNT(l.id) = 9
  ) t
UNION ALL
SELECT 'french_courses_with_wrong_count', COUNT(*)::text
  FROM (
    SELECT c.id
      FROM public.courses c
      JOIN public.lessons l ON l.course_id = c.id
     WHERE c.language_id = 2
     GROUP BY c.id
    HAVING COUNT(l.id) <> 9
  ) t
UNION ALL
SELECT 'max_order_index_across_french', MAX(l.order_index)::text
  FROM public.lessons l
  JOIN public.courses c ON c.id = l.course_id
 WHERE c.language_id = 2
UNION ALL
SELECT 'french_lessons_type_podcast_video', COUNT(*)::text
  FROM public.lessons l
  JOIN public.courses c ON c.id = l.course_id
 WHERE c.language_id = 2
   AND l.type IN ('podcast', 'video');

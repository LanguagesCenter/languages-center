-- ============================================================
-- Languages Center — backfill missing CEFR levels
-- For every language and every CEFR level (A1..C1), ensure the
-- expected sections (and their 4 lessons + 3 exercises per lesson)
-- exist. Skips sections that are already present, so this is safe to
-- run over an existing partial install.
--
-- Use this when the /learn/[language] tree is missing entire levels
-- such as A2 and B2 — the fix backfills those without touching A1,
-- B1, or C1 content that's already seeded.
-- ============================================================

do $fix_levels$
declare
  lang record;
  level_loop int;
  current_level text;
  sections_in_level text[];
  section_idx int;
  lesson_idx int;
  section_title text;
  course_id bigint;
  lesson_id bigint;
  a1_sections text[] := array['Greetings','Numbers','Colors','Family','Food','Time','Weather','Shopping'];
  a2_sections text[] := array['Daily Routines','Transport','Health','Hobbies','Work','Directions','Feelings','Celebrations'];
  b1_sections text[] := array['Travel','News & Media','Environment','Relationships','Culture','Money','Education'];
  b2_sections text[] := array['Politics','Technology','Philosophy','Literature','Business','Science','Arts'];
  c1_sections text[] := array['Idioms & Expressions','Advanced Grammar','Formal Writing','Debate & Discussion','Native Content'];
begin
  for lang in select id, code, name from public.languages order by id loop
    for level_loop in 1..5 loop
      case level_loop
        when 1 then current_level := 'A1'; sections_in_level := a1_sections;
        when 2 then current_level := 'A2'; sections_in_level := a2_sections;
        when 3 then current_level := 'B1'; sections_in_level := b1_sections;
        when 4 then current_level := 'B2'; sections_in_level := b2_sections;
        when 5 then current_level := 'C1'; sections_in_level := c1_sections;
      end case;

      for section_idx in 1..array_length(sections_in_level, 1) loop
        section_title := sections_in_level[section_idx];

        -- Skip if this exact (language, level, order_index) section is
        -- already in the table. We use order_index instead of title so a
        -- renamed section doesn't cause a duplicate.
        if exists (
          select 1 from public.courses
          where language_id = lang.id
            and cefr_level = current_level
            and order_index = section_idx
        ) then
          continue;
        end if;

        insert into public.courses (language_id, title, description, cefr_level, order_index)
        values (
          lang.id,
          section_title,
          'Build your ' || current_level || ' ' || lang.name || ' skills in ' || section_title || '.',
          current_level,
          section_idx
        )
        returning id into course_id;

        for lesson_idx in 1..4 loop
          insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
          values (
            course_id,
            section_title || ' — Lesson ' || lesson_idx,
            'Practice ' || section_title || ' in ' || lang.name,
            case lesson_idx when 1 then 'vocabulary' when 2 then 'phrases' when 3 then 'listening' else 'speaking' end,
            lesson_idx,
            10 + (level_loop - 1) * 5
          )
          returning id into lesson_id;

          -- Generic templated exercises. (The original A1 Greetings /
          -- Numbers / Colors content was language-specific and is not
          -- regenerated here — those were seeded by the original loop.)
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
            (lesson_id, 'multiple_choice',
              'Which ' || lang.name || ' phrase best fits the ' || section_title || ' context',
              section_title || ' core phrase',
              array[section_title || ' option B', section_title || ' option C', section_title || ' option D'],
              section_title || ' vocabulary',
              1),
            (lesson_id, 'listening',
              'Listen to the ' || lang.name || ' phrase about ' || section_title || ' and pick the meaning',
              section_title || ' core phrase',
              array['Distractor A','Distractor B','Distractor C'],
              section_title || ' listening',
              2),
            (lesson_id, 'speaking',
              'Pronounce the ' || lang.name || ' phrase for ' || section_title,
              section_title || ' core phrase',
              '{}'::text[],
              section_title || ' speaking',
              3);
        end loop;
      end loop;
    end loop;
  end loop;

  -- Now that every course row has a level, lock the column NOT NULL.
  if not exists (select 1 from public.courses where cefr_level is null) then
    alter table public.courses alter column cefr_level set not null;
  end if;
end
$fix_levels$;

-- Diagnostic: section counts per (language, level). After the fix you
-- should see 8 / 8 / 7 / 7 / 5 for A1 / A2 / B1 / B2 / C1 on every row.
select
  l.name as language,
  count(*) filter (where c.cefr_level = 'A1') as a1_sections,
  count(*) filter (where c.cefr_level = 'A2') as a2_sections,
  count(*) filter (where c.cefr_level = 'B1') as b1_sections,
  count(*) filter (where c.cefr_level = 'B2') as b2_sections,
  count(*) filter (where c.cefr_level = 'C1') as c1_sections
from public.languages l
left join public.courses c on c.language_id = l.id
group by l.id, l.name
order by l.id;

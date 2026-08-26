-- ============================================================
-- 053_travelers_course.sql
--
-- Traveler's Course — a completely separate course track from the
-- main CEFR curriculum. Simulates a 2-week trip abroad city by city,
-- teaching real signs, dialogues, and cultural context you'd
-- encounter on the ground.
--
-- Contains:
--   • 4 new tables (traveler_courses, traveler_lessons,
--     traveler_lesson_content, traveler_progress)
--   • RLS policies (public read on catalogue, self-only on progress)
--   • Seed: 7 city courses (4 Spanish, 3 French)
--   • Seed: 99 lesson rows (metadata only — title, location, type,
--     order_index, xp_reward, is_premium)
--   • Sample lesson content for the first Madrid and Paris lessons
--     (illustrative — the other 97 have no content yet and can be
--     authored later manually or via a content-generation script)
--
-- Safe to run once. Re-running is NOT idempotent — the INSERTs will
-- duplicate. If iterating, drop the tables between runs:
--   DROP TABLE IF EXISTS
--     public.traveler_progress,
--     public.traveler_lesson_content,
--     public.traveler_lessons,
--     public.traveler_courses CASCADE;
-- ============================================================

-- ============================================================
-- 1. TABLES
-- ============================================================

CREATE TABLE IF NOT EXISTS public.traveler_courses (
  id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  language_id     BIGINT NOT NULL REFERENCES public.languages(id) ON DELETE CASCADE,
  city            TEXT NOT NULL,
  country         TEXT NOT NULL,
  description     TEXT,
  cover_image_url TEXT,
  order_index     INT NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (language_id, city)
);

CREATE TABLE IF NOT EXISTS public.traveler_lessons (
  id                  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  traveler_course_id  BIGINT NOT NULL REFERENCES public.traveler_courses(id) ON DELETE CASCADE,
  title               TEXT NOT NULL,
  location_name       TEXT NOT NULL,
  lesson_type         TEXT NOT NULL CHECK (lesson_type IN ('sign','conversation','cultural','mixed')),
  order_index         INT NOT NULL,
  xp_reward           INT NOT NULL DEFAULT 20,
  is_premium          BOOLEAN NOT NULL DEFAULT FALSE,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (traveler_course_id, order_index)
);

CREATE TABLE IF NOT EXISTS public.traveler_lesson_content (
  id                  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  traveler_lesson_id  BIGINT NOT NULL REFERENCES public.traveler_lessons(id) ON DELETE CASCADE,
  content_type        TEXT NOT NULL CHECK (content_type IN ('image','dialogue','explanation','quiz')),
  content_order       INT NOT NULL,
  image_url           TEXT,
  image_alt           TEXT,
  dialogue_lines      JSONB NOT NULL DEFAULT '[]'::jsonb,
  explanation_text    TEXT,
  quiz_questions      JSONB NOT NULL DEFAULT '[]'::jsonb,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (traveler_lesson_id, content_order)
);

CREATE TABLE IF NOT EXISTS public.traveler_progress (
  id                  UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id             UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  traveler_lesson_id  BIGINT NOT NULL REFERENCES public.traveler_lessons(id) ON DELETE CASCADE,
  completed           BOOLEAN NOT NULL DEFAULT FALSE,
  completed_at        TIMESTAMPTZ,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, traveler_lesson_id)
);

-- ============================================================
-- 2. INDEXES (join keys, most-queried filters)
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_traveler_courses_language
  ON public.traveler_courses (language_id, order_index);

CREATE INDEX IF NOT EXISTS idx_traveler_lessons_course
  ON public.traveler_lessons (traveler_course_id, order_index);

CREATE INDEX IF NOT EXISTS idx_traveler_lesson_content_lesson
  ON public.traveler_lesson_content (traveler_lesson_id, content_order);

CREATE INDEX IF NOT EXISTS idx_traveler_progress_user
  ON public.traveler_progress (user_id, traveler_lesson_id);

CREATE INDEX IF NOT EXISTS idx_traveler_progress_lesson
  ON public.traveler_progress (traveler_lesson_id);

-- ============================================================
-- 3. RLS
-- Public catalogue (courses, lessons, content) is readable by anyone.
-- Progress is self-only.
-- ============================================================

ALTER TABLE public.traveler_courses         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.traveler_lessons         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.traveler_lesson_content  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.traveler_progress        ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS traveler_courses_read_all ON public.traveler_courses;
CREATE POLICY traveler_courses_read_all
  ON public.traveler_courses FOR SELECT
  USING (TRUE);

DROP POLICY IF EXISTS traveler_lessons_read_all ON public.traveler_lessons;
CREATE POLICY traveler_lessons_read_all
  ON public.traveler_lessons FOR SELECT
  USING (TRUE);

DROP POLICY IF EXISTS traveler_lesson_content_read_all ON public.traveler_lesson_content;
CREATE POLICY traveler_lesson_content_read_all
  ON public.traveler_lesson_content FOR SELECT
  USING (TRUE);

-- Progress: user can see and mutate ONLY their own rows.
DROP POLICY IF EXISTS traveler_progress_select_self ON public.traveler_progress;
CREATE POLICY traveler_progress_select_self
  ON public.traveler_progress FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS traveler_progress_insert_self ON public.traveler_progress;
CREATE POLICY traveler_progress_insert_self
  ON public.traveler_progress FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS traveler_progress_update_self ON public.traveler_progress;
CREATE POLICY traveler_progress_update_self
  ON public.traveler_progress FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS traveler_progress_delete_self ON public.traveler_progress;
CREATE POLICY traveler_progress_delete_self
  ON public.traveler_progress FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================
-- 4. SEED: 7 city courses
-- ============================================================

INSERT INTO public.traveler_courses (language_id, city, country, description, cover_image_url, order_index)
SELECT id, 'Madrid', 'Spain',
       'Two weeks in the Spanish capital — from Barajas Airport to Retiro Park, learn the Spanish you''ll actually hear.',
       '/traveler/covers/madrid.jpg', 1
FROM public.languages WHERE code = 'spanish'
UNION ALL
SELECT id, 'Barcelona', 'Spain',
       'Catalan-flavored Spanish for a coastal trip — Gothic Quarter, La Rambla, Sagrada Família.',
       '/traveler/covers/barcelona.jpg', 2
FROM public.languages WHERE code = 'spanish'
UNION ALL
SELECT id, 'Mexico City', 'Mexico',
       'Latin American Spanish across CDMX — Roma Norte cafés, Coyoacán markets, Museo Frida Kahlo.',
       '/traveler/covers/mexico-city.jpg', 3
FROM public.languages WHERE code = 'spanish'
UNION ALL
SELECT id, 'Buenos Aires', 'Argentina',
       'Rioplatense Spanish and porteño culture — San Telmo, Palermo, and the Subte.',
       '/traveler/covers/buenos-aires.jpg', 4
FROM public.languages WHERE code = 'spanish'
UNION ALL
SELECT id, 'Paris', 'France',
       'Two weeks in the City of Light — from Charles de Gaulle to a picnic in the Jardin du Luxembourg.',
       '/traveler/covers/paris.jpg', 1
FROM public.languages WHERE code = 'french'
UNION ALL
SELECT id, 'Lyon', 'France',
       'Gastronomy and Renaissance streets — the food capital of France in 12 lessons.',
       '/traveler/covers/lyon.jpg', 2
FROM public.languages WHERE code = 'french'
UNION ALL
SELECT id, 'Montreal', 'Canada',
       'Québécois French in Vieux-Montréal — accent, expressions, and North American context.',
       '/traveler/covers/montreal.jpg', 3
FROM public.languages WHERE code = 'french';

-- ============================================================
-- 5. SEED: 99 lessons across the 7 courses
-- Wrapped in a DO block so we can look up each course_id once
-- and INSERT its lessons in a single statement.
-- ============================================================

DO $$
DECLARE
  madrid_id       BIGINT; barcelona_id    BIGINT;
  mexico_id       BIGINT; buenos_aires_id BIGINT;
  paris_id        BIGINT; lyon_id         BIGINT;
  montreal_id     BIGINT;
BEGIN
  SELECT id INTO madrid_id       FROM public.traveler_courses WHERE city = 'Madrid';
  SELECT id INTO barcelona_id    FROM public.traveler_courses WHERE city = 'Barcelona';
  SELECT id INTO mexico_id       FROM public.traveler_courses WHERE city = 'Mexico City';
  SELECT id INTO buenos_aires_id FROM public.traveler_courses WHERE city = 'Buenos Aires';
  SELECT id INTO paris_id        FROM public.traveler_courses WHERE city = 'Paris';
  SELECT id INTO lyon_id         FROM public.traveler_courses WHERE city = 'Lyon';
  SELECT id INTO montreal_id     FROM public.traveler_courses WHERE city = 'Montreal';

  ------------------------------------------------------------------
  -- Madrid (15 lessons; 1–5 free, 6–15 premium)
  ------------------------------------------------------------------
  INSERT INTO public.traveler_lessons (traveler_course_id, title, location_name, lesson_type, order_index, xp_reward, is_premium) VALUES
    (madrid_id, 'Airport Arrivals',      'Madrid-Barajas Airport — Arrivals Hall',   'sign',         1,  20, FALSE),
    (madrid_id, 'Airport Departures',    'Barajas T4 Departures',                     'sign',         2,  20, FALSE),
    (madrid_id, 'Taxi to the City',      'Airport Taxi Stand',                        'conversation', 3,  20, FALSE),
    (madrid_id, 'Hotel Check-in',        'Hotel Reception, Chueca',                   'conversation', 4,  20, FALSE),
    (madrid_id, 'In Your Hotel Room',    'Hotel Room, Chueca',                        'conversation', 5,  20, FALSE),
    (madrid_id, 'Morning at the Café',   'Café at Plaza Mayor',                       'conversation', 6,  20, TRUE),
    (madrid_id, 'Reading Street Signs',  'Gran Vía',                                  'sign',         7,  20, TRUE),
    (madrid_id, 'Riding the Metro',      'Sol Metro Station',                         'sign',         8,  20, TRUE),
    (madrid_id, 'At the Market',         'Mercado de San Miguel',                     'conversation', 9,  20, TRUE),
    (madrid_id, 'Ordering at Casa Botín','Casa Botín Restaurant',                     'conversation', 10, 20, TRUE),
    (madrid_id, 'Museo del Prado',       'Museo del Prado',                           'cultural',     11, 20, TRUE),
    (madrid_id, 'Shopping at El Corte',  'El Corte Inglés',                           'conversation', 12, 20, TRUE),
    (madrid_id, 'A Visit to the Farmacia','Farmacia in Salamanca',                    'conversation', 13, 20, TRUE),
    (madrid_id, 'Afternoon in Retiro',   'Parque del Retiro',                         'cultural',     14, 20, TRUE),
    (madrid_id, 'Flying Home',           'Barajas T4 Check-in',                       'conversation', 15, 20, TRUE);

  ------------------------------------------------------------------
  -- Barcelona (15)
  ------------------------------------------------------------------
  INSERT INTO public.traveler_lessons (traveler_course_id, title, location_name, lesson_type, order_index, xp_reward, is_premium) VALUES
    (barcelona_id, 'Landing at El Prat',       'Barcelona-El Prat Airport — Arrivals',      'sign',         1,  20, FALSE),
    (barcelona_id, 'Airport Departures',       'El Prat T1 Departures',                     'sign',         2,  20, FALSE),
    (barcelona_id, 'Taxi to the Gothic Quarter','Airport Taxi Stand',                        'conversation', 3,  20, FALSE),
    (barcelona_id, 'Hotel Check-in',           'Hotel Reception, Gothic Quarter',           'conversation', 4,  20, FALSE),
    (barcelona_id, 'In Your Hotel Room',       'Hotel Room, Gothic Quarter',                'conversation', 5,  20, FALSE),
    (barcelona_id, 'Coffee at Plaça Reial',    'Café at Plaça Reial',                       'conversation', 6,  20, TRUE),
    (barcelona_id, 'Walking La Rambla',        'La Rambla',                                 'sign',         7,  20, TRUE),
    (barcelona_id, 'The Barcelona Metro',      'Passeig de Gràcia Metro',                   'sign',         8,  20, TRUE),
    (barcelona_id, 'At La Boqueria',           'Mercat de la Boqueria',                     'conversation', 9,  20, TRUE),
    (barcelona_id, 'Tapas in El Born',         'Restaurant in El Born',                     'conversation', 10, 20, TRUE),
    (barcelona_id, 'Sagrada Família',          'Sagrada Família',                           'cultural',     11, 20, TRUE),
    (barcelona_id, 'Shopping Passeig de Gràcia','Passeig de Gràcia Boutiques',              'conversation', 12, 20, TRUE),
    (barcelona_id, 'Farmacia in Eixample',     'Farmacia in Eixample',                      'conversation', 13, 20, TRUE),
    (barcelona_id, 'A Morning at Parc Güell',  'Parc Güell',                                'cultural',     14, 20, TRUE),
    (barcelona_id, 'Flying Home from El Prat', 'El Prat T1 Check-in',                       'conversation', 15, 20, TRUE);

  ------------------------------------------------------------------
  -- Mexico City (15)
  ------------------------------------------------------------------
  INSERT INTO public.traveler_lessons (traveler_course_id, title, location_name, lesson_type, order_index, xp_reward, is_premium) VALUES
    (mexico_id, 'Landing at AICM',         'AICM — Arrivals Terminal 2',              'sign',         1,  20, FALSE),
    (mexico_id, 'Airport Departures',      'AICM T2 Departures',                       'sign',         2,  20, FALSE),
    (mexico_id, 'Taxi to Roma Norte',      'Airport Taxi Stand',                        'conversation', 3,  20, FALSE),
    (mexico_id, 'Hotel Check-in',          'Hotel Reception, Roma Norte',              'conversation', 4,  20, FALSE),
    (mexico_id, 'In Your Hotel Room',      'Hotel Room, Roma Norte',                    'conversation', 5,  20, FALSE),
    (mexico_id, 'Café in La Condesa',      'Café en La Condesa',                        'conversation', 6,  20, TRUE),
    (mexico_id, 'Walking Reforma',         'Paseo de la Reforma',                       'sign',         7,  20, TRUE),
    (mexico_id, 'Metro de Ciudad de México','Estación Insurgentes',                     'sign',         8,  20, TRUE),
    (mexico_id, 'Mercado de Coyoacán',     'Mercado de Coyoacán',                       'conversation', 9,  20, TRUE),
    (mexico_id, 'Comida in Polanco',       'Restaurante en Polanco',                    'conversation', 10, 20, TRUE),
    (mexico_id, 'Museo Frida Kahlo',       'Museo Frida Kahlo',                         'cultural',     11, 20, TRUE),
    (mexico_id, 'Shopping at Antara',      'Antara Fashion Hall',                       'conversation', 12, 20, TRUE),
    (mexico_id, 'A Visit to the Farmacia', 'Farmacia del Ahorro',                       'conversation', 13, 20, TRUE),
    (mexico_id, 'Afternoon at Parque México','Parque México',                           'cultural',     14, 20, TRUE),
    (mexico_id, 'Flying Home from CDMX',   'AICM T2 Check-in',                          'conversation', 15, 20, TRUE);

  ------------------------------------------------------------------
  -- Buenos Aires (15)
  ------------------------------------------------------------------
  INSERT INTO public.traveler_lessons (traveler_course_id, title, location_name, lesson_type, order_index, xp_reward, is_premium) VALUES
    (buenos_aires_id, 'Landing at Ezeiza',       'Ministro Pistarini (Ezeiza) — Arrivals',   'sign',         1,  20, FALSE),
    (buenos_aires_id, 'Ezeiza Departures',       'Ezeiza International Departures',           'sign',         2,  20, FALSE),
    (buenos_aires_id, 'Remis to San Telmo',      'Airport Taxi Stand',                        'conversation', 3,  20, FALSE),
    (buenos_aires_id, 'Hotel Check-in',          'Hotel Reception, San Telmo',                'conversation', 4,  20, FALSE),
    (buenos_aires_id, 'In Your Hotel Room',      'Hotel Room, San Telmo',                     'conversation', 5,  20, FALSE),
    (buenos_aires_id, 'Café at Plaza Dorrego',   'Café at Plaza Dorrego',                     'conversation', 6,  20, TRUE),
    (buenos_aires_id, 'Avenida 9 de Julio',      'Avenida 9 de Julio',                        'sign',         7,  20, TRUE),
    (buenos_aires_id, 'Riding the Subte',        'Subte Línea D',                             'sign',         8,  20, TRUE),
    (buenos_aires_id, 'Feria de San Telmo',      'Feria de San Telmo',                        'conversation', 9,  20, TRUE),
    (buenos_aires_id, 'A Parrilla in Palermo',   'Parrilla in Palermo',                       'conversation', 10, 20, TRUE),
    (buenos_aires_id, 'Casa Rosada',             'Casa Rosada',                               'cultural',     11, 20, TRUE),
    (buenos_aires_id, 'Alto Palermo Shopping',   'Alto Palermo Shopping',                     'conversation', 12, 20, TRUE),
    (buenos_aires_id, 'A Visit to the Farmacia', 'Farmacia in Recoleta',                      'conversation', 13, 20, TRUE),
    (buenos_aires_id, 'Sunday at Plaza Serrano', 'Plaza Serrano',                             'cultural',     14, 20, TRUE),
    (buenos_aires_id, 'Flying Home from Ezeiza', 'Ezeiza Check-in',                           'conversation', 15, 20, TRUE);

  ------------------------------------------------------------------
  -- Paris (15)
  ------------------------------------------------------------------
  INSERT INTO public.traveler_lessons (traveler_course_id, title, location_name, lesson_type, order_index, xp_reward, is_premium) VALUES
    (paris_id, 'Arrivée à Charles de Gaulle', 'Charles de Gaulle T2E — Arrivals',        'sign',         1,  20, FALSE),
    (paris_id, 'CDG Departures',              'CDG T2E Departures',                       'sign',         2,  20, FALSE),
    (paris_id, 'Taxi to Le Marais',           'Airport Taxi Stand',                        'conversation', 3,  20, FALSE),
    (paris_id, 'Hotel Check-in',              'Hotel Reception, Le Marais',                'conversation', 4,  20, FALSE),
    (paris_id, 'In Your Hotel Room',          'Hotel Room, Le Marais',                     'conversation', 5,  20, FALSE),
    (paris_id, 'Café on Île Saint-Louis',     'Café at Île Saint-Louis',                   'conversation', 6,  20, TRUE),
    (paris_id, 'Champs-Élysées',              'Champs-Élysées',                            'sign',         7,  20, TRUE),
    (paris_id, 'Le Métro Parisien',           'Châtelet Métro',                            'sign',         8,  20, TRUE),
    (paris_id, 'Marché Bastille',             'Marché Bastille',                           'conversation', 9,  20, TRUE),
    (paris_id, 'Bistro in Saint-Germain',     'Bistro in Saint-Germain',                   'conversation', 10, 20, TRUE),
    (paris_id, 'La Tour Eiffel',              'La Tour Eiffel',                            'cultural',     11, 20, TRUE),
    (paris_id, 'Galeries Lafayette',          'Galeries Lafayette',                        'conversation', 12, 20, TRUE),
    (paris_id, 'À la Pharmacie',              'Pharmacie in Le Marais',                    'conversation', 13, 20, TRUE),
    (paris_id, 'Jardin du Luxembourg',        'Jardin du Luxembourg',                      'cultural',     14, 20, TRUE),
    (paris_id, 'Retour à la Maison',          'CDG T2E Check-in',                          'conversation', 15, 20, TRUE);

  ------------------------------------------------------------------
  -- Lyon (12 — trimmed from the 15-lesson template)
  ------------------------------------------------------------------
  INSERT INTO public.traveler_lessons (traveler_course_id, title, location_name, lesson_type, order_index, xp_reward, is_premium) VALUES
    (lyon_id, 'Arrivée à Saint-Exupéry',       'Lyon–Saint Exupéry — Arrivals',            'sign',         1,  20, FALSE),
    (lyon_id, 'Taxi to Vieux Lyon',            'Airport Taxi Stand',                        'conversation', 2,  20, FALSE),
    (lyon_id, 'Hotel Check-in',                'Hotel Reception, Vieux Lyon',               'conversation', 3,  20, FALSE),
    (lyon_id, 'In Your Hotel Room',            'Hotel Room, Vieux Lyon',                    'conversation', 4,  20, FALSE),
    (lyon_id, 'Café at Place Bellecour',       'Café at Place Bellecour',                   'conversation', 5,  20, FALSE),
    (lyon_id, 'Rue de la République',          'Rue de la République',                      'sign',         6,  20, TRUE),
    (lyon_id, 'Métro Ligne A',                 'Bellecour Métro',                           'sign',         7,  20, TRUE),
    (lyon_id, 'Marché de la Croix-Rousse',     'Marché de la Croix-Rousse',                 'conversation', 8,  20, TRUE),
    (lyon_id, 'Dîner dans un Bouchon',         'Bouchon Lyonnais',                          'conversation', 9,  20, TRUE),
    (lyon_id, 'Basilique de Fourvière',        'Basilique de Fourvière',                    'cultural',     10, 20, TRUE),
    (lyon_id, 'Presqu''île Shopping',          'Presqu''île Shopping',                      'conversation', 11, 20, TRUE),
    (lyon_id, 'Retour à la Maison',            'Lyon–Saint Exupéry Check-in',               'conversation', 12, 20, TRUE);

  ------------------------------------------------------------------
  -- Montreal (12)
  ------------------------------------------------------------------
  INSERT INTO public.traveler_lessons (traveler_course_id, title, location_name, lesson_type, order_index, xp_reward, is_premium) VALUES
    (montreal_id, 'Arrivée à Trudeau',           'Montréal-Trudeau Airport — Arrivals',      'sign',         1,  20, FALSE),
    (montreal_id, 'Taxi to Vieux-Montréal',      'Airport Taxi Stand',                        'conversation', 2,  20, FALSE),
    (montreal_id, 'Hotel Check-in',              'Hotel Reception, Vieux-Montréal',           'conversation', 3,  20, FALSE),
    (montreal_id, 'In Your Hotel Room',          'Hotel Room, Vieux-Montréal',                'conversation', 4,  20, FALSE),
    (montreal_id, 'Café on Plateau Mont-Royal',  'Café in Plateau Mont-Royal',                'conversation', 5,  20, FALSE),
    (montreal_id, 'Rue Saint-Denis',             'Rue Saint-Denis',                           'sign',         6,  20, TRUE),
    (montreal_id, 'Le Métro de Montréal',        'Berri-UQAM Métro',                          'sign',         7,  20, TRUE),
    (montreal_id, 'Marché Jean-Talon',           'Marché Jean-Talon',                         'conversation', 8,  20, TRUE),
    (montreal_id, 'Dîner in Vieux-Montréal',     'Restaurant in Vieux-Montréal',              'conversation', 9,  20, TRUE),
    (montreal_id, 'Basilique Notre-Dame',        'Basilique Notre-Dame',                      'cultural',     10, 20, TRUE),
    (montreal_id, 'Rue Sainte-Catherine',        'Rue Sainte-Catherine Shopping',             'conversation', 11, 20, TRUE),
    (montreal_id, 'Retour à la Maison',          'Trudeau Check-in',                          'conversation', 12, 20, TRUE);
END $$;

-- ============================================================
-- 6. SEED: sample lesson content
-- Populates ONE fully-authored lesson per language so the shape of
-- traveler_lesson_content is clear and the app has real content to
-- render. The remaining 97 lessons have no content yet — author
-- manually or via a content-generation script analogous to
-- scripts/regenerate-exercises.mjs.
-- ============================================================

-- Madrid — Lesson 1: Airport Arrivals -----------------------------
DO $$
DECLARE
  lesson_id BIGINT;
BEGIN
  SELECT l.id INTO lesson_id
  FROM public.traveler_lessons l
  JOIN public.traveler_courses c ON c.id = l.traveler_course_id
  WHERE c.city = 'Madrid' AND l.order_index = 1;

  INSERT INTO public.traveler_lesson_content
    (traveler_lesson_id, content_type, content_order, image_url, image_alt, explanation_text)
  VALUES
    (lesson_id, 'image', 1,
     '/traveler/madrid/01-arrivals-sign.jpg',
     'Overhead sign at Madrid-Barajas Airport reading "Llegadas — Arrivals" with arrows',
     NULL);

  INSERT INTO public.traveler_lesson_content
    (traveler_lesson_id, content_type, content_order, explanation_text)
  VALUES
    (lesson_id, 'explanation', 2,
     E'The sign says **Llegadas** — "Arrivals". \n\n' ||
     E'"Llegadas" is the plural of "llegada" (arrival), from the verb *llegar* (to arrive). The **-adas** ending is the past participle used as a noun — you''ll see the parallel structure in English: *arrive → arrival → arrivals*.\n\n' ||
     E'Related signs you''ll spot at any Spanish-speaking airport:\n' ||
     E'• **Salidas** — Departures (from *salir*, to leave)\n' ||
     E'• **Recogida de equipajes** — Baggage claim (literally "collection of luggage")\n' ||
     E'• **Control de pasaportes** — Passport control\n' ||
     E'• **Aduanas** — Customs');

  INSERT INTO public.traveler_lesson_content
    (traveler_lesson_id, content_type, content_order, dialogue_lines)
  VALUES
    (lesson_id, 'dialogue', 3,
     jsonb_build_array(
       jsonb_build_object('speaker', 'Immigration Officer', 'spanish', 'Buenos días. Pasaporte, por favor.',            'english', 'Good morning. Passport, please.'),
       jsonb_build_object('speaker', 'You',                  'spanish', 'Aquí tiene.',                                    'english', 'Here you go.'),
       jsonb_build_object('speaker', 'Immigration Officer', 'spanish', '¿Cuál es el motivo de su visita?',              'english', 'What is the purpose of your visit?'),
       jsonb_build_object('speaker', 'You',                  'spanish', 'Turismo. Voy a estar aquí una semana.',          'english', 'Tourism. I''ll be here for a week.'),
       jsonb_build_object('speaker', 'Immigration Officer', 'spanish', '¿Dónde se hospeda?',                             'english', 'Where are you staying?'),
       jsonb_build_object('speaker', 'You',                  'spanish', 'En un hotel en el centro, en Chueca.',           'english', 'At a hotel in the city center, in Chueca.'),
       jsonb_build_object('speaker', 'Immigration Officer', 'spanish', 'Perfecto. Bienvenido a España.',                 'english', 'Perfect. Welcome to Spain.'),
       jsonb_build_object('speaker', 'You',                  'spanish', 'Gracias.',                                       'english', 'Thank you.')
     ));

  INSERT INTO public.traveler_lesson_content
    (traveler_lesson_id, content_type, content_order, quiz_questions)
  VALUES
    (lesson_id, 'quiz', 4,
     jsonb_build_array(
       jsonb_build_object(
         'question',       'What does the sign "Llegadas" mean?',
         'correct_answer', 'Arrivals',
         'wrong_answers',  jsonb_build_array('Departures','Baggage claim','Customs'),
         'translation',    NULL
       ),
       jsonb_build_object(
         'question',       'How would you respond to "Pasaporte, por favor"?',
         'correct_answer', 'Aquí tiene',
         'wrong_answers',  jsonb_build_array('No, gracias','Buenos días','Perdón'),
         'translation',    'Here you go'
       ),
       jsonb_build_object(
         'question',       'How do you say "Tourism" in Spanish?',
         'correct_answer', 'Turismo',
         'wrong_answers',  jsonb_build_array('Trabajo','Estudio','Familia'),
         'translation',    'Tourism'
       ),
       jsonb_build_object(
         'question',       'Complete: "Voy a estar aquí una ___" (I''ll be here for a week)',
         'correct_answer', 'semana',
         'wrong_answers',  jsonb_build_array('día','mes','hora'),
         'translation',    'week'
       ),
       jsonb_build_object(
         'question',       'The officer says "Bienvenido a España." What does this mean?',
         'correct_answer', 'Welcome to Spain',
         'wrong_answers',  jsonb_build_array('Have a good trip','See you soon','Enjoy your stay'),
         'translation',    NULL
       )
     ));
END $$;

-- Paris — Lesson 1: Arrivée à Charles de Gaulle -------------------
DO $$
DECLARE
  lesson_id BIGINT;
BEGIN
  SELECT l.id INTO lesson_id
  FROM public.traveler_lessons l
  JOIN public.traveler_courses c ON c.id = l.traveler_course_id
  WHERE c.city = 'Paris' AND l.order_index = 1;

  INSERT INTO public.traveler_lesson_content
    (traveler_lesson_id, content_type, content_order, image_url, image_alt, explanation_text)
  VALUES
    (lesson_id, 'image', 1,
     '/traveler/paris/01-arrivals-sign.jpg',
     'Overhead sign at Charles de Gaulle reading "Arrivées / Arrivals" with directional arrows',
     NULL);

  INSERT INTO public.traveler_lesson_content
    (traveler_lesson_id, content_type, content_order, explanation_text)
  VALUES
    (lesson_id, 'explanation', 2,
     E'The sign says **Arrivées** — "Arrivals". \n\n' ||
     E'"Arrivées" is the plural of *arrivée* (arrival), from the verb *arriver* (to arrive). The **-ée** ending marks a feminine past-participle noun — very common in French airport, station, and hotel signage. Notice the English cognate: *arrive → arrival → arrivals*.\n\n' ||
     E'Other signs you''ll see in any French airport:\n' ||
     E'• **Départs** — Departures (from *partir*, to leave)\n' ||
     E'• **Livraison des bagages** — Baggage claim (literally "delivery of the baggage")\n' ||
     E'• **Contrôle des passeports** — Passport control\n' ||
     E'• **Douane** — Customs');

  INSERT INTO public.traveler_lesson_content
    (traveler_lesson_id, content_type, content_order, dialogue_lines)
  VALUES
    (lesson_id, 'dialogue', 3,
     jsonb_build_array(
       jsonb_build_object('speaker', 'Agent',              'spanish', 'Bonjour. Passeport, s''il vous plaît.',             'french', 'Bonjour. Passeport, s''il vous plaît.',             'english', 'Hello. Passport, please.'),
       jsonb_build_object('speaker', 'You',                'spanish', 'Voilà.',                                             'french', 'Voilà.',                                             'english', 'Here it is.'),
       jsonb_build_object('speaker', 'Agent',              'spanish', 'Quel est le motif de votre visite ?',                'french', 'Quel est le motif de votre visite ?',                'english', 'What is the purpose of your visit?'),
       jsonb_build_object('speaker', 'You',                'spanish', 'Le tourisme. Je reste une semaine.',                 'french', 'Le tourisme. Je reste une semaine.',                 'english', 'Tourism. I''m staying a week.'),
       jsonb_build_object('speaker', 'Agent',              'spanish', 'Où logez-vous ?',                                    'french', 'Où logez-vous ?',                                    'english', 'Where are you staying?'),
       jsonb_build_object('speaker', 'You',                'spanish', 'Dans un hôtel dans le Marais.',                      'french', 'Dans un hôtel dans le Marais.',                      'english', 'At a hotel in Le Marais.'),
       jsonb_build_object('speaker', 'Agent',              'spanish', 'Très bien. Bienvenue en France.',                    'french', 'Très bien. Bienvenue en France.',                    'english', 'Very good. Welcome to France.'),
       jsonb_build_object('speaker', 'You',                'spanish', 'Merci.',                                             'french', 'Merci.',                                             'english', 'Thank you.')
     ));

  INSERT INTO public.traveler_lesson_content
    (traveler_lesson_id, content_type, content_order, quiz_questions)
  VALUES
    (lesson_id, 'quiz', 4,
     jsonb_build_array(
       jsonb_build_object(
         'question',       'What does the sign "Arrivées" mean?',
         'correct_answer', 'Arrivals',
         'wrong_answers',  jsonb_build_array('Departures','Baggage claim','Customs'),
         'translation',    NULL
       ),
       jsonb_build_object(
         'question',       'How would you respond to "Passeport, s''il vous plaît"?',
         'correct_answer', 'Voilà',
         'wrong_answers',  jsonb_build_array('Bonjour','Non merci','Excusez-moi'),
         'translation',    'Here it is'
       ),
       jsonb_build_object(
         'question',       'How do you say "Tourism" in French?',
         'correct_answer', 'Le tourisme',
         'wrong_answers',  jsonb_build_array('Le travail','Les études','La famille'),
         'translation',    'Tourism'
       ),
       jsonb_build_object(
         'question',       'Complete: "Je reste une ___" (I''m staying a week)',
         'correct_answer', 'semaine',
         'wrong_answers',  jsonb_build_array('jour','mois','heure'),
         'translation',    'week'
       ),
       jsonb_build_object(
         'question',       'The officer says "Bienvenue en France." What does this mean?',
         'correct_answer', 'Welcome to France',
         'wrong_answers',  jsonb_build_array('Have a good trip','See you soon','Enjoy your stay'),
         'translation',    NULL
       )
     ));
END $$;

-- ============================================================
-- Verification: expected row counts
-- 7 courses, 99 lessons (60 spanish + 39 french), 8 content rows
-- (4 for madrid L1 + 4 for paris L1).
-- ============================================================

SELECT 'traveler_courses' AS table_name, COUNT(*) AS rows FROM public.traveler_courses
UNION ALL SELECT 'traveler_lessons',        COUNT(*) FROM public.traveler_lessons
UNION ALL SELECT 'traveler_lesson_content', COUNT(*) FROM public.traveler_lesson_content
UNION ALL SELECT 'traveler_progress',       COUNT(*) FROM public.traveler_progress
ORDER BY table_name;

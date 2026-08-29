-- ============================================================
-- 054_travelers_50_lessons.sql
--
-- Expands every Traveler's Course city (7 total) from 12/15 lessons
-- to exactly 50 lessons following one logical trip arc:
--
--    Lessons 1–5  (FREE)     — Arrival & settling in
--    Lessons 6–10 (Premium)  — Getting oriented
--    Lessons 11–15           — Food & drink
--    Lessons 16–20           — Shopping
--    Lessons 21–25           — Tourist attractions
--    Lessons 26–30           — Daily life
--    Lessons 31–35           — Social situations
--    Lessons 36–40           — Going out
--    Lessons 41–45           — Practical emergencies
--    Lessons 46–49           — Departure
--    Lesson  50              — Plane ride home
--
-- Titles and locations are adapted per city so Madrid references
-- Barajas / Retiro / Casa Botín, Paris references CDG / Le Marais /
-- Champs-Élysées, Buenos Aires references Ezeiza / San Telmo /
-- La Bombonera, etc.
--
-- --- SAFETY NOTE ------------------------------------------------------
-- This migration is idempotent (safe to re-run) but it DELETES every
-- existing traveler_lesson and traveler_lesson_content row for the 7
-- cities before re-inserting. Because traveler_progress has ON DELETE
-- CASCADE against traveler_lessons, any user progress on the old
-- lesson IDs will be dropped. This is acceptable here because the
-- traveler course hasn't launched with real learners yet; if that
-- changes, add a lesson-ID remapping step before re-running.
--
-- Also extends the schema:
--   • Adds a `data JSONB` column on traveler_lesson_content for
--     structured payloads (sign words, phrase decks, scene stamps).
--   • Extends the content_type CHECK constraint with 'scene', 'sign',
--     and 'phrases' — the three new sections used by the immersive
--     lesson runner.
--
-- --- CONTENT SCOPE ----------------------------------------------------
-- Full immersive content (scene → sign → phrases → dialogue → quiz)
-- is authored inline for:
--   • Madrid lessons 1, 2, 3   (Landing / Departures gate / Taxi)
--   • Paris  lessons 1, 2, 3   (Landing / Departures gate / Taxi)
--   • Barcelona L1, Mexico City L1, Buenos Aires L1, Lyon L1, Montreal L1
--
-- Total: 11 fully-authored lessons across 7 cities. The remaining 339
-- lessons have metadata only. The lesson runner falls back to a
-- graceful "content coming soon" panel when a lesson has no content
-- rows. Author more lessons manually or via a Claude-powered content
-- generator analogous to scripts/regenerate-exercises.mjs.
-- ============================================================


-- ============================================================
-- 1. SCHEMA EXTENSIONS
-- ============================================================

ALTER TABLE public.traveler_lesson_content
  ADD COLUMN IF NOT EXISTS data JSONB NOT NULL DEFAULT '{}'::jsonb;

ALTER TABLE public.traveler_lesson_content
  DROP CONSTRAINT IF EXISTS traveler_lesson_content_content_type_check;

ALTER TABLE public.traveler_lesson_content
  ADD CONSTRAINT traveler_lesson_content_content_type_check
  CHECK (content_type IN (
    'image','dialogue','explanation','quiz',   -- legacy from 053
    'scene','sign','phrases'                   -- new in 054
  ));


-- ============================================================
-- 2. RESET (idempotent)
-- Delete lessons for the 7 traveler cities. content + progress
-- cascade via FK ON DELETE CASCADE.
-- ============================================================

DELETE FROM public.traveler_lessons
 WHERE traveler_course_id IN (
   SELECT id FROM public.traveler_courses
    WHERE city IN (
      'Madrid','Barcelona','Mexico City','Buenos Aires',
      'Paris','Lyon','Montreal'
    )
 );


-- ============================================================
-- 3. SEED: 50 lessons per city × 7 cities = 350 lesson rows
-- Every city follows the same 50-slot arc; only titles + location
-- strings differ.
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

  -- ================ MADRID ================
  INSERT INTO public.traveler_lessons (traveler_course_id, title, location_name, lesson_type, order_index, xp_reward, is_premium) VALUES
    (madrid_id, 'Landing at Barajas',                'Madrid-Barajas T4 — Immigration',        'sign',         1,  20, FALSE),
    (madrid_id, 'Barajas Departures Gate',           'Barajas T4 — Departures Hall',           'sign',         2,  20, FALSE),
    (madrid_id, 'Taxi to Chueca',                    'Airport Taxi Rank',                       'conversation', 3,  20, FALSE),
    (madrid_id, 'Hotel Check-in',                    'Hotel Reception, Chueca',                 'conversation', 4,  20, FALSE),
    (madrid_id, 'Your Hotel Room',                   'Hotel Room, Chueca',                      'conversation', 5,  20, FALSE),
    (madrid_id, 'Sol Metro Station',                 'Sol Metro Station, Línea 1',              'sign',         6,  20, TRUE),
    (madrid_id, 'Reading Gran Vía Signs',            'Gran Vía',                                'sign',         7,  20, TRUE),
    (madrid_id, 'Asking Directions in Malasaña',     'Calle Fuencarral',                        'conversation', 8,  20, TRUE),
    (madrid_id, 'Buying a Metro Map',                'Sol Metro Info Kiosk',                    'mixed',        9,  20, TRUE),
    (madrid_id, 'Walking Lavapiés',                  'Barrio de Lavapiés',                      'cultural',     10, 20, TRUE),
    (madrid_id, 'Breakfast at Café Comercial',       'Café Comercial, Bilbao',                  'conversation', 11, 20, TRUE),
    (madrid_id, 'Mercado de San Miguel',             'Mercado de San Miguel',                   'conversation', 12, 20, TRUE),
    (madrid_id, 'Lunch at Casa Botín',               'Casa Botín Restaurant',                   'conversation', 13, 20, TRUE),
    (madrid_id, 'Ordering Caña in Malasaña',         'Bar in Malasaña',                         'conversation', 14, 20, TRUE),
    (madrid_id, 'Chocolate con Churros',             'Chocolatería San Ginés',                  'conversation', 15, 20, TRUE),
    (madrid_id, 'Shopping at Zara Gran Vía',         'Zara, Gran Vía',                          'conversation', 16, 20, TRUE),
    (madrid_id, 'Farmacia in Salamanca',             'Farmacia in Salamanca',                   'conversation', 17, 20, TRUE),
    (madrid_id, 'Souvenirs at Plaza Mayor',          'Plaza Mayor Souvenir Shop',               'conversation', 18, 20, TRUE),
    (madrid_id, 'Bargaining at El Rastro',           'El Rastro Sunday Market',                 'conversation', 19, 20, TRUE),
    (madrid_id, 'Returns at El Corte Inglés',        'El Corte Inglés Callao',                  'conversation', 20, 20, TRUE),
    (madrid_id, 'Buying Prado Tickets',              'Museo del Prado Ticket Office',           'conversation', 21, 20, TRUE),
    (madrid_id, 'Guided Tour at Palacio Real',       'Palacio Real de Madrid',                  'cultural',     22, 20, TRUE),
    (madrid_id, 'Museo Reina Sofía',                 'Museo Reina Sofía',                       'cultural',     23, 20, TRUE),
    (madrid_id, 'Templo de Debod at Sunset',         'Templo de Debod',                         'cultural',     24, 20, TRUE),
    (madrid_id, 'Afternoon in El Retiro',            'Parque del Retiro',                       'cultural',     25, 20, TRUE),
    (madrid_id, 'Mercadona Grocery',                 'Mercadona, Malasaña',                     'conversation', 26, 20, TRUE),
    (madrid_id, 'Post Office at Cibeles',            'Palacio de Cibeles Correos',              'conversation', 27, 20, TRUE),
    (madrid_id, 'ATM at BBVA',                       'BBVA ATM, Gran Vía',                      'sign',         28, 20, TRUE),
    (madrid_id, 'Wash & Dry in Chamberí',            'Lavandería, Chamberí',                    'conversation', 29, 20, TRUE),
    (madrid_id, 'Sign Up at the Gym',                'Gimnasio in Chamberí',                    'conversation', 30, 20, TRUE),
    (madrid_id, 'Making Friends at a Bar',           'Bar in Malasaña',                         'conversation', 31, 20, TRUE),
    (madrid_id, 'Small Talk with Your Uber',         'Uber to Chueca',                          'conversation', 32, 20, TRUE),
    (madrid_id, 'Invitation to a Cena',              'Friend''s Flat in Chueca',                'conversation', 33, 20, TRUE),
    (madrid_id, 'Complimenting Spanish Food',        'Restaurant in La Latina',                 'conversation', 34, 20, TRUE),
    (madrid_id, 'Misunderstandings at the Mercado',  'Mercado de la Cebada',                    'conversation', 35, 20, TRUE),
    (madrid_id, 'Sherry Bar in La Latina',           'La Venencia',                             'conversation', 36, 20, TRUE),
    (madrid_id, 'Nightclub Pachá',                   'Pachá Madrid',                            'conversation', 37, 20, TRUE),
    (madrid_id, 'Flamenco at Corral de la Morería',  'Corral de la Morería',                    'cultural',     38, 20, TRUE),
    (madrid_id, 'Real Madrid at the Bernabéu',       'Santiago Bernabéu Stadium',               'cultural',     39, 20, TRUE),
    (madrid_id, 'Cinema at Cines Callao',            'Cines Callao',                            'cultural',     40, 20, TRUE),
    (madrid_id, 'Lost Wallet at Sol Metro',          'Sol Metro Lost & Found',                  'conversation', 41, 20, TRUE),
    (madrid_id, 'Feeling Sick — CS Chueca',          'Centro de Salud Chueca',                  'conversation', 42, 20, TRUE),
    (madrid_id, 'Reporting Theft to Policía',        'Comisaría de Centro',                     'conversation', 43, 20, TRUE),
    (madrid_id, 'Broken Phone at Vodafone',          'Vodafone Store, Gran Vía',                'conversation', 44, 20, TRUE),
    (madrid_id, 'Missed the Last Metro',             'Sol Night Bus Stop',                      'conversation', 45, 20, TRUE),
    (madrid_id, 'Packing Up in Chueca',              'Hotel Room, Chueca',                      'conversation', 46, 20, TRUE),
    (madrid_id, 'Late Checkout Call',                'Hotel Reception, Chueca',                 'conversation', 47, 20, TRUE),
    (madrid_id, 'Back to Barajas',                   'Barajas T4 Departures',                   'conversation', 48, 20, TRUE),
    (madrid_id, 'Duty Free at Barajas',              'Barajas T4 Duty Free',                    'conversation', 49, 20, TRUE),
    (madrid_id, 'Iberia Flight Home',                'Iberia Flight IB6250',                    'mixed',        50, 20, TRUE);

  -- ================ BARCELONA ================
  INSERT INTO public.traveler_lessons (traveler_course_id, title, location_name, lesson_type, order_index, xp_reward, is_premium) VALUES
    (barcelona_id, 'Landing at El Prat',                'Barcelona-El Prat T1 — Immigration',      'sign',         1,  20, FALSE),
    (barcelona_id, 'El Prat Departures Gate',           'El Prat T1 — Departures Hall',            'sign',         2,  20, FALSE),
    (barcelona_id, 'Taxi to the Gothic Quarter',        'Airport Taxi Rank',                        'conversation', 3,  20, FALSE),
    (barcelona_id, 'Hotel Check-in',                    'Hotel Reception, Gothic Quarter',          'conversation', 4,  20, FALSE),
    (barcelona_id, 'Your Hotel Room',                   'Hotel Room, Gothic Quarter',               'conversation', 5,  20, FALSE),
    (barcelona_id, 'Passeig de Gràcia Metro',           'Passeig de Gràcia Station, L3',            'sign',         6,  20, TRUE),
    (barcelona_id, 'Reading La Rambla Signs',           'La Rambla',                                'sign',         7,  20, TRUE),
    (barcelona_id, 'Asking Directions in El Born',      'Carrer de Montcada',                       'conversation', 8,  20, TRUE),
    (barcelona_id, 'Buying a T-Casual Card',            'Metro Info Kiosk',                         'mixed',        9,  20, TRUE),
    (barcelona_id, 'Walking El Raval',                  'Barri del Raval',                          'cultural',     10, 20, TRUE),
    (barcelona_id, 'Breakfast at Granja Viader',        'Granja Viader',                            'conversation', 11, 20, TRUE),
    (barcelona_id, 'Mercat de la Boqueria',             'Mercat de la Boqueria',                    'conversation', 12, 20, TRUE),
    (barcelona_id, 'Tapas at El Xampanyet',             'El Xampanyet, El Born',                    'conversation', 13, 20, TRUE),
    (barcelona_id, 'Ordering a Vermut',                 'Vermuteria in Gràcia',                     'conversation', 14, 20, TRUE),
    (barcelona_id, 'Paying at Els Quatre Gats',         'Els Quatre Gats',                          'conversation', 15, 20, TRUE),
    (barcelona_id, 'Shopping Passeig de Gràcia',        'Massimo Dutti, Passeig de Gràcia',         'conversation', 16, 20, TRUE),
    (barcelona_id, 'Farmacia in Eixample',              'Farmacia, Carrer d''Aragó',                'conversation', 17, 20, TRUE),
    (barcelona_id, 'Souvenirs at Plaça Reial',          'Plaça Reial Souvenir Shop',                'conversation', 18, 20, TRUE),
    (barcelona_id, 'Bargaining at Encants Vells',       'Mercat dels Encants',                      'conversation', 19, 20, TRUE),
    (barcelona_id, 'Returns at El Corte Inglés',        'El Corte Inglés Plaça Catalunya',          'conversation', 20, 20, TRUE),
    (barcelona_id, 'Buying Sagrada Família Tickets',    'Sagrada Família Ticket Office',            'conversation', 21, 20, TRUE),
    (barcelona_id, 'Guided Tour at Casa Batlló',        'Casa Batlló',                              'cultural',     22, 20, TRUE),
    (barcelona_id, 'MACBA Modern Art',                  'MACBA',                                    'cultural',     23, 20, TRUE),
    (barcelona_id, 'Bunkers del Carmel at Sunset',      'Bunkers del Carmel',                       'cultural',     24, 20, TRUE),
    (barcelona_id, 'Morning at Parc Güell',             'Parc Güell',                               'cultural',     25, 20, TRUE),
    (barcelona_id, 'Bonpreu Grocery',                   'Bonpreu, Gràcia',                          'conversation', 26, 20, TRUE),
    (barcelona_id, 'Post Office on Via Laietana',       'Correus Via Laietana',                     'conversation', 27, 20, TRUE),
    (barcelona_id, 'ATM at CaixaBank',                  'CaixaBank ATM, La Rambla',                 'sign',         28, 20, TRUE),
    (barcelona_id, 'Lavandería in El Born',             'Lavandería, El Born',                      'conversation', 29, 20, TRUE),
    (barcelona_id, 'Sign Up at DiR Gym',                'DiR Gym in Eixample',                      'conversation', 30, 20, TRUE),
    (barcelona_id, 'Making Friends at a Vermuteria',    'Bar del Pla',                              'conversation', 31, 20, TRUE),
    (barcelona_id, 'Small Talk with Your Cabbie',       'Taxi to Barceloneta',                      'conversation', 32, 20, TRUE),
    (barcelona_id, 'Invitation to a Sopar',             'Friend''s Flat in Gràcia',                 'conversation', 33, 20, TRUE),
    (barcelona_id, 'Complimenting Catalan Food',        'Restaurant in El Born',                    'conversation', 34, 20, TRUE),
    (barcelona_id, 'Misunderstandings at the Boqueria', 'Mercat de la Boqueria',                    'conversation', 35, 20, TRUE),
    (barcelona_id, 'Cava Bar in El Born',               'El Xampanyet',                             'conversation', 36, 20, TRUE),
    (barcelona_id, 'Nightclub Opium',                   'Opium Barcelona',                          'conversation', 37, 20, TRUE),
    (barcelona_id, 'Live Rumba at Jamboree',            'Jamboree Jazz Club',                       'cultural',     38, 20, TRUE),
    (barcelona_id, 'FC Barcelona at Camp Nou',          'Spotify Camp Nou',                         'cultural',     39, 20, TRUE),
    (barcelona_id, 'Cinema at Yelmo Icaria',            'Yelmo Cines Icaria',                       'cultural',     40, 20, TRUE),
    (barcelona_id, 'Lost Wallet on the L3',             'Passeig de Gràcia Lost & Found',           'conversation', 41, 20, TRUE),
    (barcelona_id, 'Feeling Sick — CAP Casanova',       'CAP Casanova',                             'conversation', 42, 20, TRUE),
    (barcelona_id, 'Reporting Theft to the Mossos',     'Comissaria de les Rambles',                'conversation', 43, 20, TRUE),
    (barcelona_id, 'Broken Phone at Movistar',          'Movistar, Passeig de Gràcia',              'conversation', 44, 20, TRUE),
    (barcelona_id, 'Missed the Last Metro',             'Barcelona NitBus Stop',                    'conversation', 45, 20, TRUE),
    (barcelona_id, 'Packing Up in the Gothic Quarter',  'Hotel Room, Gothic Quarter',               'conversation', 46, 20, TRUE),
    (barcelona_id, 'Late Checkout Call',                'Hotel Reception, Gothic Quarter',          'conversation', 47, 20, TRUE),
    (barcelona_id, 'Back to El Prat',                   'El Prat T1 Departures',                    'conversation', 48, 20, TRUE),
    (barcelona_id, 'Duty Free at El Prat',              'El Prat T1 Duty Free',                     'conversation', 49, 20, TRUE),
    (barcelona_id, 'Vueling Flight Home',               'Vueling Flight VY1234',                    'mixed',        50, 20, TRUE);

  -- ================ MEXICO CITY ================
  INSERT INTO public.traveler_lessons (traveler_course_id, title, location_name, lesson_type, order_index, xp_reward, is_premium) VALUES
    (mexico_id, 'Landing at AICM',                   'AICM T2 — Migración',                       'sign',         1,  20, FALSE),
    (mexico_id, 'AICM Departures Gate',              'AICM T2 — Salidas',                          'sign',         2,  20, FALSE),
    (mexico_id, 'Taxi Autorizado to Roma Norte',     'Sitio de Taxis, AICM',                       'conversation', 3,  20, FALSE),
    (mexico_id, 'Hotel Check-in',                    'Hotel Reception, Roma Norte',                'conversation', 4,  20, FALSE),
    (mexico_id, 'Your Hotel Room',                   'Hotel Room, Roma Norte',                     'conversation', 5,  20, FALSE),
    (mexico_id, 'Metrobús at Insurgentes',           'Metrobús Insurgentes',                       'sign',         6,  20, TRUE),
    (mexico_id, 'Reading Reforma Signs',             'Paseo de la Reforma',                        'sign',         7,  20, TRUE),
    (mexico_id, 'Asking Directions in La Condesa',   'Avenida Ámsterdam',                          'conversation', 8,  20, TRUE),
    (mexico_id, 'Buying a Metrobús Card',            'Estación Insurgentes',                       'mixed',        9,  20, TRUE),
    (mexico_id, 'Walking La Condesa',                'Colonia Condesa',                            'cultural',     10, 20, TRUE),
    (mexico_id, 'Chilaquiles at El Cardenal',        'Restaurante El Cardenal',                    'conversation', 11, 20, TRUE),
    (mexico_id, 'Mercado de Coyoacán',               'Mercado de Coyoacán',                        'conversation', 12, 20, TRUE),
    (mexico_id, 'Comida at Contramar',               'Contramar',                                  'conversation', 13, 20, TRUE),
    (mexico_id, 'Ordering Mezcal',                   'Mezcal Bar in La Roma',                      'conversation', 14, 20, TRUE),
    (mexico_id, 'La Cuenta at Pujol',                'Pujol Restaurant',                           'conversation', 15, 20, TRUE),
    (mexico_id, 'Shopping at Antara',                'Antara Fashion Hall',                        'conversation', 16, 20, TRUE),
    (mexico_id, 'Farmacia del Ahorro',               'Farmacia del Ahorro',                        'conversation', 17, 20, TRUE),
    (mexico_id, 'Souvenirs at Ciudadela',            'Mercado de Artesanías La Ciudadela',         'conversation', 18, 20, TRUE),
    (mexico_id, 'Bargaining at La Lagunilla',        'Mercado La Lagunilla',                       'conversation', 19, 20, TRUE),
    (mexico_id, 'Returns at Liverpool Polanco',      'Liverpool Polanco',                          'conversation', 20, 20, TRUE),
    (mexico_id, 'Buying Frida Kahlo Tickets',        'Museo Frida Kahlo Ticket Office',            'conversation', 21, 20, TRUE),
    (mexico_id, 'Guided Tour at Templo Mayor',       'Templo Mayor',                               'cultural',     22, 20, TRUE),
    (mexico_id, 'Museo Nacional de Antropología',    'MNA, Chapultepec',                           'cultural',     23, 20, TRUE),
    (mexico_id, 'Xochimilco Trajineras',             'Embarcadero Nuevo Nativitas',                'cultural',     24, 20, TRUE),
    (mexico_id, 'Afternoon at Parque México',        'Parque México',                              'cultural',     25, 20, TRUE),
    (mexico_id, 'Chedraui Grocery',                  'Chedraui, Condesa',                          'conversation', 26, 20, TRUE),
    (mexico_id, 'Correos de México',                 'Palacio de Correos',                         'conversation', 27, 20, TRUE),
    (mexico_id, 'ATM at Banamex',                    'Banamex ATM, Reforma',                       'sign',         28, 20, TRUE),
    (mexico_id, 'Lavandería in La Roma',             'Lavandería, La Roma',                        'conversation', 29, 20, TRUE),
    (mexico_id, 'Sign Up at Sport City',             'Sport City Gym, Condesa',                    'conversation', 30, 20, TRUE),
    (mexico_id, 'Making Friends at a Cantina',       'Salón Palacio',                              'conversation', 31, 20, TRUE),
    (mexico_id, 'Small Talk with Your Uber',         'Uber to Coyoacán',                           'conversation', 32, 20, TRUE),
    (mexico_id, 'Invitation to a Comida',            'Friend''s Home in Condesa',                  'conversation', 33, 20, TRUE),
    (mexico_id, 'Complimenting Mexican Food',        'Restaurant in Polanco',                      'conversation', 34, 20, TRUE),
    (mexico_id, 'Misunderstandings at the Mercado',  'Mercado Jamaica',                            'conversation', 35, 20, TRUE),
    (mexico_id, 'Pulquería in Centro',               'Pulquería Las Duelistas',                    'conversation', 36, 20, TRUE),
    (mexico_id, 'Nightclub in Zona Rosa',            'Envy Zona Rosa',                             'conversation', 37, 20, TRUE),
    (mexico_id, 'Mariachi at Plaza Garibaldi',       'Plaza Garibaldi',                            'cultural',     38, 20, TRUE),
    (mexico_id, 'Fútbol at Estadio Azteca',          'Estadio Azteca',                             'cultural',     39, 20, TRUE),
    (mexico_id, 'Cinemex at Antara',                 'Cinemex Antara',                             'cultural',     40, 20, TRUE),
    (mexico_id, 'Lost Wallet at Metro Insurgentes',  'Metro Insurgentes Lost & Found',             'conversation', 41, 20, TRUE),
    (mexico_id, 'Feeling Sick — Farmacia Consult',   'Farmacia con Consultorio, Condesa',          'conversation', 42, 20, TRUE),
    (mexico_id, 'Denuncia at Ministerio Público',    'MP, Colonia Roma',                           'conversation', 43, 20, TRUE),
    (mexico_id, 'Broken Phone at Telcel',            'Telcel Center, Reforma',                     'conversation', 44, 20, TRUE),
    (mexico_id, 'Missed the Last Metro',             'Metro Nocturno Stop',                        'conversation', 45, 20, TRUE),
    (mexico_id, 'Packing Up in Roma Norte',          'Hotel Room, Roma Norte',                     'conversation', 46, 20, TRUE),
    (mexico_id, 'Late Checkout Call',                'Hotel Reception, Roma Norte',                'conversation', 47, 20, TRUE),
    (mexico_id, 'Back to AICM T2',                   'AICM T2 Salidas',                            'conversation', 48, 20, TRUE),
    (mexico_id, 'Duty Free at AICM',                 'AICM T2 Duty Free',                          'conversation', 49, 20, TRUE),
    (mexico_id, 'Aeroméxico Flight Home',            'Aeroméxico Flight AM100',                    'mixed',        50, 20, TRUE);

  -- ================ BUENOS AIRES ================
  INSERT INTO public.traveler_lessons (traveler_course_id, title, location_name, lesson_type, order_index, xp_reward, is_premium) VALUES
    (buenos_aires_id, 'Landing at Ezeiza',               'Ezeiza — Migraciones',                          'sign',         1,  20, FALSE),
    (buenos_aires_id, 'Ezeiza Departures Gate',          'Ezeiza — Salidas Internacionales',              'sign',         2,  20, FALSE),
    (buenos_aires_id, 'Remis to San Telmo',              'Sitio de Remises, Ezeiza',                      'conversation', 3,  20, FALSE),
    (buenos_aires_id, 'Hotel Check-in',                  'Hotel Reception, San Telmo',                    'conversation', 4,  20, FALSE),
    (buenos_aires_id, 'Your Hotel Room',                 'Hotel Room, San Telmo',                         'conversation', 5,  20, FALSE),
    (buenos_aires_id, 'Subte Línea D',                   'Estación Facultad de Medicina',                 'sign',         6,  20, TRUE),
    (buenos_aires_id, 'Reading 9 de Julio Signs',        'Avenida 9 de Julio',                            'sign',         7,  20, TRUE),
    (buenos_aires_id, 'Asking Directions in Palermo',    'Palermo Soho',                                  'conversation', 8,  20, TRUE),
    (buenos_aires_id, 'Buying a SUBE Card',              'SUBE Kiosk, Subte D',                           'mixed',        9,  20, TRUE),
    (buenos_aires_id, 'Walking Palermo Soho',            'Palermo Soho',                                  'cultural',     10, 20, TRUE),
    (buenos_aires_id, 'Medialunas at Café Tortoni',      'Café Tortoni',                                  'conversation', 11, 20, TRUE),
    (buenos_aires_id, 'Feria de San Telmo',              'Feria de San Telmo',                            'conversation', 12, 20, TRUE),
    (buenos_aires_id, 'Lunch at Don Julio',              'Parrilla Don Julio, Palermo',                   'conversation', 13, 20, TRUE),
    (buenos_aires_id, 'Ordering Fernet con Coca',        'Bar in San Telmo',                              'conversation', 14, 20, TRUE),
    (buenos_aires_id, 'Paying at El Preferido',          'El Preferido de Palermo',                       'conversation', 15, 20, TRUE),
    (buenos_aires_id, 'Shopping at Alto Palermo',        'Alto Palermo Shopping',                         'conversation', 16, 20, TRUE),
    (buenos_aires_id, 'Farmacia in Recoleta',            'Farmacity, Recoleta',                           'conversation', 17, 20, TRUE),
    (buenos_aires_id, 'Souvenirs at Mataderos',          'Feria de Mataderos',                            'conversation', 18, 20, TRUE),
    (buenos_aires_id, 'Bargaining Sunday at San Telmo',  'Feria San Telmo Domingo',                       'conversation', 19, 20, TRUE),
    (buenos_aires_id, 'Returns at Falabella',            'Falabella, Alto Palermo',                       'conversation', 20, 20, TRUE),
    (buenos_aires_id, 'Buying Recoleta Cemetery Tickets','Cementerio de la Recoleta',                     'conversation', 21, 20, TRUE),
    (buenos_aires_id, 'Guided Tour at Teatro Colón',     'Teatro Colón',                                  'cultural',     22, 20, TRUE),
    (buenos_aires_id, 'MALBA Modern Art',                'MALBA',                                         'cultural',     23, 20, TRUE),
    (buenos_aires_id, 'Puerto Madero at Sunset',         'Puerto Madero',                                 'cultural',     24, 20, TRUE),
    (buenos_aires_id, 'Sunday at Plaza Serrano',         'Plaza Serrano, Palermo',                        'cultural',     25, 20, TRUE),
    (buenos_aires_id, 'Coto Grocery',                    'Coto, Palermo',                                 'conversation', 26, 20, TRUE),
    (buenos_aires_id, 'Correo Argentino',                'Correo Argentino, Centro',                      'conversation', 27, 20, TRUE),
    (buenos_aires_id, 'ATM at Banco Nación',             'Banco Nación ATM',                              'sign',         28, 20, TRUE),
    (buenos_aires_id, 'Lavadero in San Telmo',           'Lavadero, San Telmo',                           'conversation', 29, 20, TRUE),
    (buenos_aires_id, 'Sign Up at SportClub',            'SportClub, Palermo',                            'conversation', 30, 20, TRUE),
    (buenos_aires_id, 'Making Friends at a Bar',         'Bar Bebop, San Telmo',                          'conversation', 31, 20, TRUE),
    (buenos_aires_id, 'Small Talk with Your Remisero',   'Remis to Puerto Madero',                        'conversation', 32, 20, TRUE),
    (buenos_aires_id, 'Invitation to an Asado',          'Friend''s Terrace, Palermo',                    'conversation', 33, 20, TRUE),
    (buenos_aires_id, 'Complimenting Argentine Food',    'Parrilla in Palermo',                           'conversation', 34, 20, TRUE),
    (buenos_aires_id, 'Misunderstandings at the Feria',  'Feria de San Telmo',                            'conversation', 35, 20, TRUE),
    (buenos_aires_id, 'Cerveza Artesanal in Palermo',    'Antares Palermo',                               'conversation', 36, 20, TRUE),
    (buenos_aires_id, 'Milonga in San Telmo',            'La Catedral Milonga',                           'conversation', 37, 20, TRUE),
    (buenos_aires_id, 'Live Tango at Café Angelitos',    'Café de los Angelitos',                         'cultural',     38, 20, TRUE),
    (buenos_aires_id, 'Boca vs. River at La Bombonera',  'La Bombonera',                                  'cultural',     39, 20, TRUE),
    (buenos_aires_id, 'Cinema at Cinemark Palermo',      'Cinemark Palermo',                              'cultural',     40, 20, TRUE),
    (buenos_aires_id, 'Lost Wallet on the Subte',        'Subte D Lost & Found',                          'conversation', 41, 20, TRUE),
    (buenos_aires_id, 'Feeling Sick — Hospital Alemán',  'Hospital Alemán, Palermo',                      'conversation', 42, 20, TRUE),
    (buenos_aires_id, 'Denuncia at Comisaría Palermo',   'Comisaría Palermo',                             'conversation', 43, 20, TRUE),
    (buenos_aires_id, 'Broken Phone at Movistar',        'Movistar, Palermo',                             'conversation', 44, 20, TRUE),
    (buenos_aires_id, 'Missed the Last Subte',           'Colectivo 39 Bus Stop',                         'conversation', 45, 20, TRUE),
    (buenos_aires_id, 'Packing Up in San Telmo',         'Hotel Room, San Telmo',                         'conversation', 46, 20, TRUE),
    (buenos_aires_id, 'Late Checkout Call',              'Hotel Reception, San Telmo',                    'conversation', 47, 20, TRUE),
    (buenos_aires_id, 'Back to Ezeiza',                  'Ezeiza Check-in',                               'conversation', 48, 20, TRUE),
    (buenos_aires_id, 'Duty Free at Ezeiza',             'Ezeiza Duty Free',                              'conversation', 49, 20, TRUE),
    (buenos_aires_id, 'Aerolíneas Flight Home',          'Aerolíneas Flight AR1300',                      'mixed',        50, 20, TRUE);

  -- ================ PARIS ================
  INSERT INTO public.traveler_lessons (traveler_course_id, title, location_name, lesson_type, order_index, xp_reward, is_premium) VALUES
    (paris_id, 'Arrivée à Charles de Gaulle',      'Charles de Gaulle T2E — Immigration',      'sign',         1,  20, FALSE),
    (paris_id, 'CDG Départs',                      'CDG T2E — Départs',                        'sign',         2,  20, FALSE),
    (paris_id, 'Taxi to Le Marais',                'Airport Taxi Rank',                         'conversation', 3,  20, FALSE),
    (paris_id, 'Hotel Check-in',                   'Hotel Reception, Le Marais',                'conversation', 4,  20, FALSE),
    (paris_id, 'Your Hotel Room',                  'Hotel Room, Le Marais',                     'conversation', 5,  20, FALSE),
    (paris_id, 'Le Métro Parisien',                'Châtelet-Les Halles, Ligne 1',              'sign',         6,  20, TRUE),
    (paris_id, 'Reading Champs-Élysées Signs',     'Champs-Élysées',                            'sign',         7,  20, TRUE),
    (paris_id, 'Asking Directions in the Quartier','Rue Mouffetard',                            'conversation', 8,  20, TRUE),
    (paris_id, 'Buying a Navigo Découverte',       'RATP Kiosk, Châtelet',                      'mixed',        9,  20, TRUE),
    (paris_id, 'Walking Montmartre',               'Montmartre',                                'cultural',     10, 20, TRUE),
    (paris_id, 'Croissant at Café de Flore',       'Café de Flore, Saint-Germain',              'conversation', 11, 20, TRUE),
    (paris_id, 'Marché Bastille',                  'Marché Bastille',                           'conversation', 12, 20, TRUE),
    (paris_id, 'Bistro Lunch at L''Ami Louis',     'Chez L''Ami Louis',                         'conversation', 13, 20, TRUE),
    (paris_id, 'Ordering a Kir Royal',             'Bar Hemingway, Ritz',                       'conversation', 14, 20, TRUE),
    (paris_id, 'L''Addition at Le Petit Vendôme',  'Le Petit Vendôme',                          'conversation', 15, 20, TRUE),
    (paris_id, 'Shopping at Galeries Lafayette',   'Galeries Lafayette',                        'conversation', 16, 20, TRUE),
    (paris_id, 'Pharmacie in Le Marais',           'Pharmacie, Le Marais',                      'conversation', 17, 20, TRUE),
    (paris_id, 'Souvenirs at Île Saint-Louis',     'Souvenir Shop, Île Saint-Louis',            'conversation', 18, 20, TRUE),
    (paris_id, 'Bargaining at Marché aux Puces',   'Marché aux Puces de Saint-Ouen',            'conversation', 19, 20, TRUE),
    (paris_id, 'Returns at Le Bon Marché',         'Le Bon Marché',                             'conversation', 20, 20, TRUE),
    (paris_id, 'Buying Louvre Tickets',            'Louvre Ticket Office',                      'conversation', 21, 20, TRUE),
    (paris_id, 'Guided Tour at Versailles',        'Château de Versailles',                     'cultural',     22, 20, TRUE),
    (paris_id, 'Musée d''Orsay',                   'Musée d''Orsay',                            'cultural',     23, 20, TRUE),
    (paris_id, 'Sacré-Cœur at Sunset',             'Sacré-Cœur, Montmartre',                    'cultural',     24, 20, TRUE),
    (paris_id, 'Afternoon in Luxembourg',          'Jardin du Luxembourg',                      'cultural',     25, 20, TRUE),
    (paris_id, 'Monoprix Grocery',                 'Monoprix, Le Marais',                       'conversation', 26, 20, TRUE),
    (paris_id, 'La Poste on Rue de Rivoli',        'La Poste, Rue de Rivoli',                   'conversation', 27, 20, TRUE),
    (paris_id, 'DAB at BNP Paribas',               'BNP Paribas DAB',                           'sign',         28, 20, TRUE),
    (paris_id, 'Laverie in Le Marais',             'Laverie, Le Marais',                        'conversation', 29, 20, TRUE),
    (paris_id, 'Sign Up at Basic-Fit',             'Basic-Fit, Le Marais',                      'conversation', 30, 20, TRUE),
    (paris_id, 'Making Friends at a Rooftop',      'Le Perchoir, Le Marais',                    'conversation', 31, 20, TRUE),
    (paris_id, 'Small Talk with Your Chauffeur',   'Uber to the Louvre',                        'conversation', 32, 20, TRUE),
    (paris_id, 'Invitation to Dîner',              'Friend''s Flat, 3e Arrondissement',         'conversation', 33, 20, TRUE),
    (paris_id, 'Complimenting French Food',        'Bistro in Saint-Germain',                   'conversation', 34, 20, TRUE),
    (paris_id, 'Misunderstandings at the Marché',  'Marché Aligre',                             'conversation', 35, 20, TRUE),
    (paris_id, 'Wine Bar in Le Marais',            'Le Barav',                                  'conversation', 36, 20, TRUE),
    (paris_id, 'Nightclub Rex Club',               'Rex Club',                                  'conversation', 37, 20, TRUE),
    (paris_id, 'Jazz at Duc des Lombards',         'Duc des Lombards',                          'cultural',     38, 20, TRUE),
    (paris_id, 'PSG at Parc des Princes',          'Parc des Princes',                          'cultural',     39, 20, TRUE),
    (paris_id, 'Cinema at UGC Ciné Cité',          'UGC Ciné Cité Les Halles',                  'cultural',     40, 20, TRUE),
    (paris_id, 'Lost Wallet on the Métro',         'RATP Objets Trouvés',                       'conversation', 41, 20, TRUE),
    (paris_id, 'Feeling Sick — Pharmacie de Garde','Pharmacie Bastille',                        'conversation', 42, 20, TRUE),
    (paris_id, 'Reporting Theft — Commissariat',   'Commissariat du 4e',                        'conversation', 43, 20, TRUE),
    (paris_id, 'Broken Phone at Orange',           'Orange Store, Rivoli',                      'conversation', 44, 20, TRUE),
    (paris_id, 'Missed the Last Métro',            'Noctilien N01 Bus Stop',                    'conversation', 45, 20, TRUE),
    (paris_id, 'Packing Up in Le Marais',          'Hotel Room, Le Marais',                     'conversation', 46, 20, TRUE),
    (paris_id, 'Late Checkout Call',               'Hotel Reception, Le Marais',                'conversation', 47, 20, TRUE),
    (paris_id, 'Retour à CDG',                     'CDG T2E Départs',                           'conversation', 48, 20, TRUE),
    (paris_id, 'Duty Free at CDG',                 'CDG T2E Duty Free',                         'conversation', 49, 20, TRUE),
    (paris_id, 'Air France Flight Home',           'Air France Flight AF9',                     'mixed',        50, 20, TRUE);

  -- ================ LYON ================
  INSERT INTO public.traveler_lessons (traveler_course_id, title, location_name, lesson_type, order_index, xp_reward, is_premium) VALUES
    (lyon_id, 'Arrivée à Saint-Exupéry',           'Lyon–Saint Exupéry Arrivals',              'sign',         1,  20, FALSE),
    (lyon_id, 'Saint-Exupéry Départs',             'Saint-Exupéry — Départs',                  'sign',         2,  20, FALSE),
    (lyon_id, 'Rhônexpress to Vieux Lyon',         'Rhônexpress Ticket Machine',                'conversation', 3,  20, FALSE),
    (lyon_id, 'Hotel Check-in',                    'Hotel Reception, Vieux Lyon',               'conversation', 4,  20, FALSE),
    (lyon_id, 'Your Hotel Room',                   'Hotel Room, Vieux Lyon',                    'conversation', 5,  20, FALSE),
    (lyon_id, 'Métro Ligne A',                     'Bellecour Métro Station',                   'sign',         6,  20, TRUE),
    (lyon_id, 'Reading Place Bellecour Signs',     'Place Bellecour',                           'sign',         7,  20, TRUE),
    (lyon_id, 'Asking Directions in Croix-Rousse', 'Boulevard de la Croix-Rousse',              'conversation', 8,  20, TRUE),
    (lyon_id, 'Buying a TCL Ticket',               'TCL Ticket Machine',                        'mixed',        9,  20, TRUE),
    (lyon_id, 'Walking the Traboules',             'Vieux Lyon, Traboules',                     'cultural',     10, 20, TRUE),
    (lyon_id, 'Café at Place Bellecour',           'Café at Place Bellecour',                   'conversation', 11, 20, TRUE),
    (lyon_id, 'Marché de la Croix-Rousse',         'Marché de la Croix-Rousse',                 'conversation', 12, 20, TRUE),
    (lyon_id, 'Bouchon Lunch',                     'Bouchon Daniel & Denise',                   'conversation', 13, 20, TRUE),
    (lyon_id, 'Ordering a Beaujolais',             'Wine Bar in Presqu''île',                   'conversation', 14, 20, TRUE),
    (lyon_id, 'L''Addition at Le Bistrot',         'Le Bistrot du Potager',                     'conversation', 15, 20, TRUE),
    (lyon_id, 'Shopping Rue de la République',     'Rue de la République',                      'conversation', 16, 20, TRUE),
    (lyon_id, 'Pharmacie in Presqu''île',          'Pharmacie, Presqu''île',                    'conversation', 17, 20, TRUE),
    (lyon_id, 'Souvenirs at Vieux Lyon',           'Souvenir Shop, Vieux Lyon',                 'conversation', 18, 20, TRUE),
    (lyon_id, 'Bargaining at Puces du Canal',      'Puces du Canal',                            'conversation', 19, 20, TRUE),
    (lyon_id, 'Returns at Printemps',              'Printemps Lyon',                            'conversation', 20, 20, TRUE),
    (lyon_id, 'Buying Fourvière Tickets',          'Basilique de Fourvière',                    'conversation', 21, 20, TRUE),
    (lyon_id, 'Tour at Musée Miniature',           'Musée Miniature et Cinéma',                 'cultural',     22, 20, TRUE),
    (lyon_id, 'Musée des Beaux-Arts',              'Musée des Beaux-Arts de Lyon',              'cultural',     23, 20, TRUE),
    (lyon_id, 'Fourvière at Sunset',               'Basilique de Fourvière',                    'cultural',     24, 20, TRUE),
    (lyon_id, 'Afternoon at Parc de la Tête d''Or','Parc de la Tête d''Or',                     'cultural',     25, 20, TRUE),
    (lyon_id, 'Monoprix Grocery',                  'Monoprix, Presqu''île',                     'conversation', 26, 20, TRUE),
    (lyon_id, 'La Poste on Place Bellecour',       'La Poste Bellecour',                        'conversation', 27, 20, TRUE),
    (lyon_id, 'DAB at Crédit Agricole',            'Crédit Agricole DAB',                       'sign',         28, 20, TRUE),
    (lyon_id, 'Laverie in Croix-Rousse',           'Laverie, Croix-Rousse',                     'conversation', 29, 20, TRUE),
    (lyon_id, 'Sign Up at Neoness',                'Neoness Gym, Part-Dieu',                    'conversation', 30, 20, TRUE),
    (lyon_id, 'Making Friends at a Café',          'Café de la Cloche',                         'conversation', 31, 20, TRUE),
    (lyon_id, 'Small Talk with Your Chauffeur',    'Uber to Vieux Lyon',                        'conversation', 32, 20, TRUE),
    (lyon_id, 'Invitation to Dîner',               'Friend''s Flat, Croix-Rousse',              'conversation', 33, 20, TRUE),
    (lyon_id, 'Complimenting Lyonnais Food',       'Bouchon in Vieux Lyon',                     'conversation', 34, 20, TRUE),
    (lyon_id, 'Misunderstandings at the Marché',   'Marché Saint-Antoine',                      'conversation', 35, 20, TRUE),
    (lyon_id, 'Wine Bar on Rue Mercière',          'La Cave d''à Côté',                         'conversation', 36, 20, TRUE),
    (lyon_id, 'Nightclub Le Sucre',                'Le Sucre',                                  'conversation', 37, 20, TRUE),
    (lyon_id, 'Jazz at Hot Club',                  'Hot Club de Lyon',                          'cultural',     38, 20, TRUE),
    (lyon_id, 'OL at Groupama Stadium',            'Groupama Stadium',                          'cultural',     39, 20, TRUE),
    (lyon_id, 'Cinema at Pathé Bellecour',         'Pathé Bellecour',                           'cultural',     40, 20, TRUE),
    (lyon_id, 'Lost Wallet on the Métro',          'TCL Objets Trouvés',                        'conversation', 41, 20, TRUE),
    (lyon_id, 'Feeling Sick — Pharmacie de Garde', 'Pharmacie Bellecour',                       'conversation', 42, 20, TRUE),
    (lyon_id, 'Reporting Theft — Commissariat',    'Commissariat de Lyon',                      'conversation', 43, 20, TRUE),
    (lyon_id, 'Broken Phone at SFR',               'SFR Store, Presqu''île',                    'conversation', 44, 20, TRUE),
    (lyon_id, 'Missed the Last Métro',             'Pleine Lune Night Bus',                     'conversation', 45, 20, TRUE),
    (lyon_id, 'Packing Up in Vieux Lyon',          'Hotel Room, Vieux Lyon',                    'conversation', 46, 20, TRUE),
    (lyon_id, 'Late Checkout Call',                'Hotel Reception, Vieux Lyon',               'conversation', 47, 20, TRUE),
    (lyon_id, 'Back to Saint-Exupéry',             'Saint-Exupéry Check-in',                    'conversation', 48, 20, TRUE),
    (lyon_id, 'Duty Free at Saint-Exupéry',        'Saint-Exupéry Duty Free',                   'conversation', 49, 20, TRUE),
    (lyon_id, 'Air France Flight Home',            'Air France Flight AF7699',                  'mixed',        50, 20, TRUE);

  -- ================ MONTREAL ================
  INSERT INTO public.traveler_lessons (traveler_course_id, title, location_name, lesson_type, order_index, xp_reward, is_premium) VALUES
    (montreal_id, 'Arrivée à Trudeau',                'Montréal-Trudeau Arrivals',                 'sign',         1,  20, FALSE),
    (montreal_id, 'Trudeau Départs',                  'Trudeau International Departures',          'sign',         2,  20, FALSE),
    (montreal_id, 'Taxi to Vieux-Montréal',           'Airport Taxi Stand',                        'conversation', 3,  20, FALSE),
    (montreal_id, 'Hotel Check-in',                   'Hotel Reception, Vieux-Montréal',           'conversation', 4,  20, FALSE),
    (montreal_id, 'Your Hotel Room',                  'Hotel Room, Vieux-Montréal',                'conversation', 5,  20, FALSE),
    (montreal_id, 'Métro Berri-UQAM',                 'Berri-UQAM, Ligne Orange',                  'sign',         6,  20, TRUE),
    (montreal_id, 'Reading Sainte-Catherine Signs',   'Rue Sainte-Catherine',                      'sign',         7,  20, TRUE),
    (montreal_id, 'Asking Directions on Le Plateau',  'Avenue du Mont-Royal',                      'conversation', 8,  20, TRUE),
    (montreal_id, 'Buying an OPUS Card',              'STM Ticket Booth',                          'mixed',        9,  20, TRUE),
    (montreal_id, 'Walking Le Plateau',               'Plateau Mont-Royal',                        'cultural',     10, 20, TRUE),
    (montreal_id, 'Bagel at St-Viateur',              'St-Viateur Bagel',                          'conversation', 11, 20, TRUE),
    (montreal_id, 'Marché Jean-Talon',                'Marché Jean-Talon',                         'conversation', 12, 20, TRUE),
    (montreal_id, 'Poutine at La Banquise',           'La Banquise',                               'conversation', 13, 20, TRUE),
    (montreal_id, 'Ordering a Caribou',               'Bar Les Foufounes Électriques',             'conversation', 14, 20, TRUE),
    (montreal_id, 'L''Addition at Toqué!',            'Toqué!',                                    'conversation', 15, 20, TRUE),
    (montreal_id, 'Shopping at Simons',               'La Maison Simons, Sainte-Catherine',        'conversation', 16, 20, TRUE),
    (montreal_id, 'Pharmaprix in Le Plateau',         'Pharmaprix, Le Plateau',                    'conversation', 17, 20, TRUE),
    (montreal_id, 'Souvenirs at Vieux-Port',          'Souvenir Shop, Vieux-Port',                 'conversation', 18, 20, TRUE),
    (montreal_id, 'Bargaining at Marché aux Puces',   'Marché aux Puces Saint-Michel',             'conversation', 19, 20, TRUE),
    (montreal_id, 'Returns at La Baie',               'La Baie, Downtown',                         'conversation', 20, 20, TRUE),
    (montreal_id, 'Buying Notre-Dame Tickets',        'Basilique Notre-Dame',                      'conversation', 21, 20, TRUE),
    (montreal_id, 'Guided Tour at Habitat 67',        'Habitat 67',                                'cultural',     22, 20, TRUE),
    (montreal_id, 'Musée des Beaux-Arts',             'Musée des Beaux-Arts de Montréal',          'cultural',     23, 20, TRUE),
    (montreal_id, 'Mont-Royal at Sunset',             'Belvédère Kondiaronk',                      'cultural',     24, 20, TRUE),
    (montreal_id, 'Afternoon at Parc La Fontaine',    'Parc La Fontaine',                          'cultural',     25, 20, TRUE),
    (montreal_id, 'IGA Grocery',                      'IGA, Le Plateau',                           'conversation', 26, 20, TRUE),
    (montreal_id, 'Postes Canada',                    'Postes Canada, Downtown',                   'conversation', 27, 20, TRUE),
    (montreal_id, 'DAB at Desjardins',                'Desjardins DAB',                            'sign',         28, 20, TRUE),
    (montreal_id, 'Buanderie in Le Plateau',          'Buanderie, Le Plateau',                     'conversation', 29, 20, TRUE),
    (montreal_id, 'Sign Up at Nautilus Plus',         'Nautilus Plus, Downtown',                   'conversation', 30, 20, TRUE),
    (montreal_id, 'Making Friends at a Terrasse',     'Terrasse Nelligan',                         'conversation', 31, 20, TRUE),
    (montreal_id, 'Small Talk with Your Chauffeur',   'Uber to Vieux-Montréal',                    'conversation', 32, 20, TRUE),
    (montreal_id, 'Invitation to Souper',             'Friend''s Flat, Le Plateau',                'conversation', 33, 20, TRUE),
    (montreal_id, 'Complimenting Québec Food',        'Restaurant in Vieux-Montréal',              'conversation', 34, 20, TRUE),
    (montreal_id, 'Misunderstandings at Jean-Talon',  'Marché Jean-Talon',                         'conversation', 35, 20, TRUE),
    (montreal_id, 'Microbrasserie on Le Plateau',     'Dieu du Ciel!',                             'conversation', 36, 20, TRUE),
    (montreal_id, 'Nightclub Muzique',                'Club Muzique',                              'conversation', 37, 20, TRUE),
    (montreal_id, 'Live Jazz at Upstairs',            'Upstairs Jazz Club',                        'cultural',     38, 20, TRUE),
    (montreal_id, 'Canadiens at Bell Centre',         'Centre Bell',                               'cultural',     39, 20, TRUE),
    (montreal_id, 'Cinema at Cineplex Forum',         'Cineplex Forum',                            'cultural',     40, 20, TRUE),
    (montreal_id, 'Lost Wallet on the Métro',         'STM Objets Trouvés',                        'conversation', 41, 20, TRUE),
    (montreal_id, 'Feeling Sick — CLSC',              'CLSC Métro',                                'conversation', 42, 20, TRUE),
    (montreal_id, 'Reporting Theft to SPVM',          'Poste de Quartier 22, SPVM',                'conversation', 43, 20, TRUE),
    (montreal_id, 'Broken Phone at Bell',             'Bell Store, Sainte-Catherine',              'conversation', 44, 20, TRUE),
    (montreal_id, 'Missed the Last Métro',            'Bus 361 Night Line',                        'conversation', 45, 20, TRUE),
    (montreal_id, 'Packing Up in Vieux-Montréal',     'Hotel Room, Vieux-Montréal',                'conversation', 46, 20, TRUE),
    (montreal_id, 'Late Checkout Call',               'Hotel Reception, Vieux-Montréal',           'conversation', 47, 20, TRUE),
    (montreal_id, 'Back to Trudeau',                  'Trudeau Check-in',                          'conversation', 48, 20, TRUE),
    (montreal_id, 'Duty Free at Trudeau',             'Trudeau Duty Free',                         'conversation', 49, 20, TRUE),
    (montreal_id, 'Air Canada Flight Home',           'Air Canada Flight AC800',                   'mixed',        50, 20, TRUE);
END $$;


-- ============================================================
-- 4. SEED: fully authored content for 11 lessons
--
-- Structure per lesson (5 content rows):
--   order 1 = 'scene'   → hero image + immersive 2nd-person description
--   order 2 = 'sign'    → styled sign/menu/notice with clickable words
--   order 3 = 'phrases' → 5 essential phrases with phonetic + tip
--   order 4 = 'dialogue'→ 6–8 line conversation
--   order 5 = 'quiz'    → 4 mixed exercises (multiple_choice + fill_blank)
-- ============================================================

-- ---------------- MADRID — Lesson 1 ----------------
DO $$
DECLARE lid BIGINT;
BEGIN
  SELECT l.id INTO lid
  FROM public.traveler_lessons l
  JOIN public.traveler_courses c ON c.id = l.traveler_course_id
  WHERE c.city = 'Madrid' AND l.order_index = 1;

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, image_url, image_alt, explanation_text, data) VALUES
  (lid, 'scene', 1,
   'https://images.unsplash.com/photo-1543783207-ec64e4d95325?w=1600&h=900&fit=crop&q=80',
   'Aerial view of Madrid at dusk with sun setting over the city',
   E'You''ve just landed at **Madrid-Barajas Terminal 4**. The plane doors open and you step onto the jet bridge into warm Madrid air. Following the crowd, you head down long corridors, past duty-free shops and cafés, toward passport control. Overhead signs in blue direct you to **Llegadas** — Arrivals.',
   jsonb_build_object('stamp','MADRID','stampSublabel','MAD · BARAJAS T4'));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, data) VALUES
  (lid, 'sign', 2,
   jsonb_build_object(
     'style','airport_blue',
     'title','LLEGADAS',
     'subtitle','ARRIVALS',
     'icon','→',
     'note','Overhead directional sign after disembarking.',
     'words', jsonb_build_array(
       jsonb_build_object('text','LLEGADAS','phonetic','yeh-GAH-dahs','english','Arrivals','tip','From *llegar* (to arrive) — think "we llegar-ed, so it''s llegadas".'),
       jsonb_build_object('text','SALIDAS','phonetic','sah-LEE-dahs','english','Departures','tip','From *salir* (to leave) — the opposite direction sign.'),
       jsonb_build_object('text','RECOGIDA DE EQUIPAJES','phonetic','reh-koh-HEE-dah deh eh-kee-PAH-hes','english','Baggage claim','tip','Literally "collection of luggage".'),
       jsonb_build_object('text','ADUANAS','phonetic','ah-DWAH-nahs','english','Customs','tip','Cognate of "duana" — the customs office.')
     )));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, data) VALUES
  (lid, 'phrases', 3,
   jsonb_build_object('phrases', jsonb_build_array(
     jsonb_build_object('phrase','Buenos días.','phonetic','BWEH-nohs DEE-ahs','english','Good morning.','tip','Use it before noon; after that, buenas tardes.','grammar','Formal greeting — works with strangers.'),
     jsonb_build_object('phrase','Aquí tiene.','phonetic','ah-KEE tee-EH-neh','english','Here you go.','tip','Say this when handing over your passport.','grammar','Literally "here you have" — a set phrase.'),
     jsonb_build_object('phrase','Turismo.','phonetic','too-REES-moh','english','Tourism.','tip','One-word answer to "purpose of visit".','grammar','Noun — no verb needed.'),
     jsonb_build_object('phrase','Voy a estar una semana.','phonetic','boy ah es-TAR oo-nah seh-MAH-nah','english','I''ll be here a week.','tip','Swap "semana" for "quince días" (two weeks) or "un mes" (a month).','grammar','Ir + a + infinitive is Spanish future tense.'),
     jsonb_build_object('phrase','Gracias, igualmente.','phonetic','GRAH-see-ahs ee-gwahl-MEN-teh','english','Thanks, you too.','tip','Response to "welcome to Spain".','grammar','*Igualmente* = "same to you".')
   )));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, dialogue_lines) VALUES
  (lid, 'dialogue', 4, jsonb_build_array(
    jsonb_build_object('speaker','Officer','target','Buenos días. Pasaporte, por favor.',              'english','Good morning. Passport, please.'),
    jsonb_build_object('speaker','You',    'target','Aquí tiene.',                                     'english','Here you go.'),
    jsonb_build_object('speaker','Officer','target','¿Cuál es el motivo de su visita?',               'english','What is the purpose of your visit?'),
    jsonb_build_object('speaker','You',    'target','Turismo. Voy a estar una semana.',                'english','Tourism. I''ll be here a week.'),
    jsonb_build_object('speaker','Officer','target','¿Dónde se hospeda?',                              'english','Where are you staying?'),
    jsonb_build_object('speaker','You',    'target','En un hotel en Chueca.',                          'english','At a hotel in Chueca.'),
    jsonb_build_object('speaker','Officer','target','Perfecto. Bienvenido a España.',                  'english','Perfect. Welcome to Spain.'),
    jsonb_build_object('speaker','You',    'target','Gracias, igualmente.',                            'english','Thanks, you too.')
  ));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, quiz_questions) VALUES
  (lid, 'quiz', 5, jsonb_build_array(
    jsonb_build_object('type','multiple_choice','question','What does the sign "Llegadas" mean?','correct_answer','Arrivals','wrong_answers',jsonb_build_array('Departures','Baggage claim','Customs')),
    jsonb_build_object('type','multiple_choice','question','How would you respond to "Pasaporte, por favor"?','correct_answer','Aquí tiene','wrong_answers',jsonb_build_array('No, gracias','Buenos días','Perdón'),'translation','Here you go'),
    jsonb_build_object('type','fill_blank','question','Complete the sentence: "Voy a estar una ___" (I''ll be here a week)','correct_answer','semana','wrong_answers',jsonb_build_array('día','mes','hora'),'translation','week'),
    jsonb_build_object('type','listening','question','You hear the officer say something. What does it mean?','audio_prompt','Bienvenido a España','correct_answer','Welcome to Spain','wrong_answers',jsonb_build_array('Have a good trip','Enjoy your stay','See you soon'))
  ));
END $$;

-- ---------------- MADRID — Lesson 2 ----------------
DO $$
DECLARE lid BIGINT;
BEGIN
  SELECT l.id INTO lid FROM public.traveler_lessons l
  JOIN public.traveler_courses c ON c.id = l.traveler_course_id
  WHERE c.city = 'Madrid' AND l.order_index = 2;

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, image_url, image_alt, explanation_text, data) VALUES
  (lid, 'scene', 1,
   'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=1600&h=900&fit=crop&q=80',
   'Departures board at a modern airport terminal',
   E'Two weeks later, you''re back at **Barajas T4** — this time to fly home. The check-in area buzzes with rolling suitcases. You need to find your gate, listen for boarding calls, and understand the overhead announcements before you can board.',
   jsonb_build_object('stamp','BARAJAS','stampSublabel','DEPARTURES · T4'));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, data) VALUES
  (lid, 'sign', 2, jsonb_build_object(
    'style','airport_blue',
    'title','PUERTA E45',
    'subtitle','GATE E45 · EMBARQUE 10:35',
    'icon','✈',
    'note','Boarding screen next to your gate.',
    'words', jsonb_build_array(
      jsonb_build_object('text','PUERTA','phonetic','PWAIR-tah','english','Gate','tip','Also means "door".'),
      jsonb_build_object('text','EMBARQUE','phonetic','em-BAR-keh','english','Boarding','tip','From *embarcar* — to board.'),
      jsonb_build_object('text','VUELO','phonetic','BWEH-loh','english','Flight','tip','From *volar* (to fly).'),
      jsonb_build_object('text','DESTINO','phonetic','des-TEE-noh','english','Destination','tip','Same word in English cognate.')
    )));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, data) VALUES
  (lid, 'phrases', 3, jsonb_build_object('phrases', jsonb_build_array(
    jsonb_build_object('phrase','¿Dónde está la puerta E45?','phonetic','DON-deh es-TAH lah PWAIR-tah eh KWAH-ren-tah-SEEN-koh','english','Where is gate E45?','tip','Substitute your gate letter/number.','grammar','*¿Dónde está...?* is the go-to "where is..." question.'),
    jsonb_build_object('phrase','¿A qué hora embarcamos?','phonetic','ah keh OH-rah em-bar-KAH-mos','english','What time do we board?','tip','Use "salimos" (leave) instead of "embarcamos" for takeoff.','grammar','1st-person plural — includes yourself.'),
    jsonb_build_object('phrase','Tengo una escala en...','phonetic','TEN-goh oo-nah es-KAH-lah en','english','I have a layover in...','tip','Follow with a city name.','grammar','*Escala* = stopover.'),
    jsonb_build_object('phrase','¿Está retrasado el vuelo?','phonetic','es-TAH reh-trah-SAH-doh el BWEH-loh','english','Is the flight delayed?','tip','Ask this at the gate desk if things look quiet.','grammar','*Retrasado* = delayed (past participle).'),
    jsonb_build_object('phrase','Feliz viaje.','phonetic','feh-LEES bee-AH-heh','english','Have a good trip.','tip','What the gate agent may say to you.','grammar','Casual, warm sign-off.')
  )));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, dialogue_lines) VALUES
  (lid, 'dialogue', 4, jsonb_build_array(
    jsonb_build_object('speaker','You',   'target','Perdone, ¿dónde está la puerta E45?','english','Excuse me, where is gate E45?'),
    jsonb_build_object('speaker','Agent', 'target','Al fondo a la derecha, después del control de seguridad.','english','At the end on the right, past security.'),
    jsonb_build_object('speaker','You',   'target','¿A qué hora empieza el embarque?','english','What time does boarding start?'),
    jsonb_build_object('speaker','Agent', 'target','A las diez y treinta y cinco.','english','At 10:35.'),
    jsonb_build_object('speaker','You',   'target','¿Está retrasado el vuelo?','english','Is the flight delayed?'),
    jsonb_build_object('speaker','Agent', 'target','No, sale a la hora. Feliz viaje.','english','No, it leaves on time. Have a good trip.'),
    jsonb_build_object('speaker','You',   'target','Muchas gracias.','english','Thank you very much.')
  ));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, quiz_questions) VALUES
  (lid, 'quiz', 5, jsonb_build_array(
    jsonb_build_object('type','multiple_choice','question','What does "PUERTA" mean at the airport?','correct_answer','Gate','wrong_answers',jsonb_build_array('Ticket','Aisle','Baggage')),
    jsonb_build_object('type','multiple_choice','question','You want to ask if the flight is delayed. Which phrase?','correct_answer','¿Está retrasado el vuelo?','wrong_answers',jsonb_build_array('¿Dónde está la puerta?','¿A qué hora embarcamos?','Feliz viaje')),
    jsonb_build_object('type','fill_blank','question','Complete: "Tengo una ___ en Barcelona." (I have a layover in Barcelona)','correct_answer','escala','wrong_answers',jsonb_build_array('puerta','vuelo','maleta'),'translation','layover'),
    jsonb_build_object('type','listening','question','What are you being told?','audio_prompt','El embarque comienza a las diez y treinta y cinco','correct_answer','Boarding starts at 10:35','wrong_answers',jsonb_build_array('The flight is at 10:35','The gate is 10:35','You have a layover at 10:35'))
  ));
END $$;

-- ---------------- MADRID — Lesson 3 ----------------
DO $$
DECLARE lid BIGINT;
BEGIN
  SELECT l.id INTO lid FROM public.traveler_lessons l
  JOIN public.traveler_courses c ON c.id = l.traveler_course_id
  WHERE c.city = 'Madrid' AND l.order_index = 3;

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, image_url, image_alt, explanation_text, data) VALUES
  (lid, 'scene', 1,
   'https://images.unsplash.com/photo-1543872084-c7bd3822856f?w=1600&h=900&fit=crop&q=80',
   'White and red Madrid taxi at an airport taxi rank',
   E'Out through the sliding doors, into the taxi rank. A line of the classic **white-with-red-stripe** Madrid taxis waits. You wheel your suitcase to the front of the queue and the driver pops the trunk.',
   jsonb_build_object('stamp','TAXI','stampSublabel','BARAJAS → CHUECA'));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, data) VALUES
  (lid, 'sign', 2, jsonb_build_object(
    'style','notice',
    'title','TARIFA FIJA AEROPUERTO — CENTRO',
    'subtitle','FLAT AIRPORT FARE — CITY CENTER',
    'note','Posted rate card at the taxi rank.',
    'words', jsonb_build_array(
      jsonb_build_object('text','TARIFA FIJA','phonetic','tah-REE-fah FEE-hah','english','Flat rate','tip','30€ from Barajas to the city center — memorize this so you can''t be overcharged.'),
      jsonb_build_object('text','SUPLEMENTO','phonetic','soo-pleh-MEN-toh','english','Surcharge','tip','Common for late nights, holidays, extra bags.'),
      jsonb_build_object('text','MALETAS','phonetic','mah-LEH-tahs','english','Suitcases','tip','Also *equipaje* for luggage generally.'),
      jsonb_build_object('text','CENTRO','phonetic','SEN-troh','english','City center','tip','Everything inside the M-30 ring road counts as centro.')
    )));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, data) VALUES
  (lid, 'phrases', 3, jsonb_build_object('phrases', jsonb_build_array(
    jsonb_build_object('phrase','A Chueca, por favor.','phonetic','ah CHWEH-kah por fah-BOR','english','To Chueca, please.','tip','Give the neighborhood, not just the address, so the driver knows the route.'),
    jsonb_build_object('phrase','¿Cuánto cuesta?','phonetic','KWAN-toh KWES-tah','english','How much is it?','tip','Ask this before setting off, especially if there''s no meter.','grammar','*Cuesta* comes from *costar* (to cost).'),
    jsonb_build_object('phrase','¿Puede usar el taxímetro?','phonetic','PWEH-deh oo-SAR el tak-SEE-meh-troh','english','Can you use the meter?','tip','Politely insists on the meter when you suspect a flat rate isn''t applied.'),
    jsonb_build_object('phrase','La dirección es Calle Hortaleza número 30.','phonetic','lah dee-rek-see-OHN es KAH-yeh or-tah-LEH-thah NOO-meh-roh TREN-tah','english','The address is Hortaleza street, number 30.','tip','Say the street type ("Calle") + name + number.'),
    jsonb_build_object('phrase','¿Me da un recibo, por favor?','phonetic','meh dah oon reh-SEE-boh por fah-BOR','english','Can I have a receipt, please?','tip','Useful for expenses, but also to have the driver''s ID.')
  )));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, dialogue_lines) VALUES
  (lid, 'dialogue', 4, jsonb_build_array(
    jsonb_build_object('speaker','Driver','target','Buenas. ¿A dónde vamos?','english','Hi. Where are we going?'),
    jsonb_build_object('speaker','You',   'target','A Chueca, por favor. Calle Hortaleza número 30.','english','To Chueca, please. Hortaleza street, number 30.'),
    jsonb_build_object('speaker','Driver','target','Perfecto. Con la tarifa fija son treinta euros.','english','Perfect. With the flat rate that''s thirty euros.'),
    jsonb_build_object('speaker','You',   'target','¿Puede usar el taxímetro, mejor?','english','Could you use the meter instead?'),
    jsonb_build_object('speaker','Driver','target','Del aeropuerto al centro es tarifa fija, señor. Son treinta.','english','From the airport to the center it''s a flat rate, sir. It''s thirty.'),
    jsonb_build_object('speaker','You',   'target','De acuerdo. ¿Me da un recibo al llegar?','english','Alright. Can I have a receipt when we arrive?'),
    jsonb_build_object('speaker','Driver','target','Claro, sin problema.','english','Of course, no problem.')
  ));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, quiz_questions) VALUES
  (lid, 'quiz', 5, jsonb_build_array(
    jsonb_build_object('type','multiple_choice','question','The sign says "TARIFA FIJA". What does that mean?','correct_answer','Flat rate','wrong_answers',jsonb_build_array('Extra fee','Meter reading','Cash only')),
    jsonb_build_object('type','fill_blank','question','Complete: "A ___, por favor" (To Chueca, please)','correct_answer','Chueca','wrong_answers',jsonb_build_array('Calle','Aeropuerto','Ahí'),'translation','Chueca'),
    jsonb_build_object('type','multiple_choice','question','How do you politely ask for a receipt?','correct_answer','¿Me da un recibo, por favor?','wrong_answers',jsonb_build_array('¿Cuánto cuesta?','¿Puede usar el taxímetro?','A Chueca, por favor')),
    jsonb_build_object('type','listening','question','What is the driver telling you?','audio_prompt','Con la tarifa fija son treinta euros','correct_answer','With the flat rate that''s thirty euros','wrong_answers',jsonb_build_array('The meter reads thirty euros','Please give me thirty euros','Thirty euros to the airport'))
  ));
END $$;

-- ---------------- PARIS — Lesson 1 ----------------
DO $$
DECLARE lid BIGINT;
BEGIN
  SELECT l.id INTO lid FROM public.traveler_lessons l
  JOIN public.traveler_courses c ON c.id = l.traveler_course_id
  WHERE c.city = 'Paris' AND l.order_index = 1;

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, image_url, image_alt, explanation_text, data) VALUES
  (lid, 'scene', 1,
   'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=1600&h=900&fit=crop&q=80',
   'Eiffel Tower against a Paris skyline at golden hour',
   E'Wheels down at **Charles de Gaulle, Terminal 2E**. The plane taxis past the arched glass roof and you file off with the crowd. Long corridors of moving walkways funnel you toward passport control, where officers wait in glass booths beneath a big sign: **Contrôle des passeports**.',
   jsonb_build_object('stamp','PARIS','stampSublabel','CDG · T2E'));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, data) VALUES
  (lid, 'sign', 2, jsonb_build_object(
    'style','airport_blue',
    'title','ARRIVÉES',
    'subtitle','ARRIVALS',
    'icon','→',
    'note','Overhead sign directing arriving passengers.',
    'words', jsonb_build_array(
      jsonb_build_object('text','ARRIVÉES','phonetic','ah-ree-VAY','english','Arrivals','tip','From *arriver* (to arrive). The -ée ending is a feminine past participle noun.'),
      jsonb_build_object('text','DÉPARTS','phonetic','day-PAR','english','Departures','tip','From *partir* (to leave).'),
      jsonb_build_object('text','LIVRAISON DES BAGAGES','phonetic','lee-vray-ZOHN day bah-GAHZH','english','Baggage claim','tip','Literally "delivery of the baggage".'),
      jsonb_build_object('text','DOUANE','phonetic','doo-AHN','english','Customs','tip','You''ll pass through here after collecting bags.')
    )));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, data) VALUES
  (lid, 'phrases', 3, jsonb_build_object('phrases', jsonb_build_array(
    jsonb_build_object('phrase','Bonjour.','phonetic','bohn-ZHOOR','english','Hello.','tip','Always start every interaction with *bonjour* — critical to being polite in France.','grammar','Neutral, formal, works with everyone.'),
    jsonb_build_object('phrase','Voilà.','phonetic','vwah-LAH','english','Here it is.','tip','Say this while handing over your passport.','grammar','A set phrase — no grammar to learn.'),
    jsonb_build_object('phrase','Le tourisme.','phonetic','luh too-REEZM','english','Tourism.','tip','Answer to "purpose of your visit".','grammar','Nouns take an article: *le* tourisme.'),
    jsonb_build_object('phrase','Je reste une semaine.','phonetic','zhuh REST oon suh-MEN','english','I''m staying a week.','tip','Swap "une semaine" for "dix jours" (ten days) or "un mois" (a month).','grammar','*Rester* = to stay/remain.'),
    jsonb_build_object('phrase','Merci, vous aussi.','phonetic','mair-SEE vooz oh-SEE','english','Thank you, you too.','tip','Response when told "bon séjour" (enjoy your stay).')
  )));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, dialogue_lines) VALUES
  (lid, 'dialogue', 4, jsonb_build_array(
    jsonb_build_object('speaker','Officer','target','Bonjour. Passeport, s''il vous plaît.',    'english','Hello. Passport, please.'),
    jsonb_build_object('speaker','You',    'target','Voilà.',                                    'english','Here it is.'),
    jsonb_build_object('speaker','Officer','target','Quel est le motif de votre visite ?',      'english','What is the purpose of your visit?'),
    jsonb_build_object('speaker','You',    'target','Le tourisme. Je reste une semaine.',        'english','Tourism. I''m staying a week.'),
    jsonb_build_object('speaker','Officer','target','Où logez-vous ?',                           'english','Where are you staying?'),
    jsonb_build_object('speaker','You',    'target','Dans un hôtel dans le Marais.',             'english','At a hotel in Le Marais.'),
    jsonb_build_object('speaker','Officer','target','Très bien. Bon séjour en France.',          'english','Very good. Enjoy your stay in France.'),
    jsonb_build_object('speaker','You',    'target','Merci, vous aussi.',                        'english','Thank you, you too.')
  ));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, quiz_questions) VALUES
  (lid, 'quiz', 5, jsonb_build_array(
    jsonb_build_object('type','multiple_choice','question','What does the sign "Arrivées" mean?','correct_answer','Arrivals','wrong_answers',jsonb_build_array('Departures','Baggage claim','Customs')),
    jsonb_build_object('type','multiple_choice','question','You are handed back your passport. What is the officer likely to say?','correct_answer','Bon séjour en France','wrong_answers',jsonb_build_array('Bonjour','Voilà','Au revoir'),'translation','Enjoy your stay in France'),
    jsonb_build_object('type','fill_blank','question','Complete: "Je reste une ___" (I''m staying a week)','correct_answer','semaine','wrong_answers',jsonb_build_array('jour','mois','heure'),'translation','week'),
    jsonb_build_object('type','listening','question','What is being asked?','audio_prompt','Quel est le motif de votre visite ?','correct_answer','What is the purpose of your visit?','wrong_answers',jsonb_build_array('Where are you staying?','How long will you be here?','Do you have anything to declare?'))
  ));
END $$;

-- ---------------- PARIS — Lesson 2 ----------------
DO $$
DECLARE lid BIGINT;
BEGIN
  SELECT l.id INTO lid FROM public.traveler_lessons l
  JOIN public.traveler_courses c ON c.id = l.traveler_course_id
  WHERE c.city = 'Paris' AND l.order_index = 2;

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, image_url, image_alt, explanation_text, data) VALUES
  (lid, 'scene', 1,
   'https://images.unsplash.com/photo-1569154941061-e231b4725ef1?w=1600&h=900&fit=crop&q=80',
   'Passenger walking through modern airport departures with signs overhead',
   E'You''re back at **CDG Terminal 2E**, suitcase in tow. The bright departures hall stretches out, screens flicking through flights. You need to find your gate, listen for the boarding call, and understand each announcement over the tinny PA.',
   jsonb_build_object('stamp','CDG','stampSublabel','DÉPARTS · T2E'));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, data) VALUES
  (lid, 'sign', 2, jsonb_build_object(
    'style','airport_blue',
    'title','PORTE K42',
    'subtitle','GATE K42 · EMBARQUEMENT 10:35',
    'icon','✈',
    'note','Boarding screen next to your gate.',
    'words', jsonb_build_array(
      jsonb_build_object('text','PORTE','phonetic','port','english','Gate','tip','Also means "door".'),
      jsonb_build_object('text','EMBARQUEMENT','phonetic','ahn-bark-MAHN','english','Boarding','tip','Same root as English "embark".'),
      jsonb_build_object('text','VOL','phonetic','vohl','english','Flight','tip','Also means "theft" — context matters!'),
      jsonb_build_object('text','DESTINATION','phonetic','dess-tee-nah-SYOHN','english','Destination','tip','English cognate — easy to remember.')
    )));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, data) VALUES
  (lid, 'phrases', 3, jsonb_build_object('phrases', jsonb_build_array(
    jsonb_build_object('phrase','Où est la porte K42 ?','phonetic','ooh eh lah port kah kah-RAHNT-duh','english','Where is gate K42?','tip','Sub in your gate letter/number.','grammar','*Où est...?* → "Where is...?"'),
    jsonb_build_object('phrase','L''embarquement commence à quelle heure ?','phonetic','lahn-bark-MAHN koh-MAHNS ah KEHL urr','english','What time does boarding start?','tip','Or simply *À quelle heure on embarque ?*'),
    jsonb_build_object('phrase','J''ai une correspondance à...','phonetic','zhay oon koh-res-pon-DAHNS ah','english','I have a connection in...','tip','*Correspondance* is used for any transport transfer.'),
    jsonb_build_object('phrase','Est-ce que le vol est en retard ?','phonetic','ess kuh luh vohl eh tahn ruh-TAR','english','Is the flight late?','tip','*En retard* = late/delayed.','grammar','*Est-ce que...* is the universal yes/no question opener.'),
    jsonb_build_object('phrase','Bon voyage.','phonetic','bohn voy-YAHZH','english','Have a good trip.','tip','The gate agent may say this to you as you board.')
  )));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, dialogue_lines) VALUES
  (lid, 'dialogue', 4, jsonb_build_array(
    jsonb_build_object('speaker','You',   'target','Bonjour. Où est la porte K42, s''il vous plaît ?','english','Hello. Where is gate K42, please?'),
    jsonb_build_object('speaker','Agent', 'target','Au bout du couloir, à droite, après la sécurité.','english','At the end of the hallway, on the right, past security.'),
    jsonb_build_object('speaker','You',   'target','L''embarquement commence à quelle heure ?','english','What time does boarding start?'),
    jsonb_build_object('speaker','Agent', 'target','À dix heures trente-cinq.','english','At 10:35.'),
    jsonb_build_object('speaker','You',   'target','Est-ce que le vol est en retard ?','english','Is the flight delayed?'),
    jsonb_build_object('speaker','Agent', 'target','Non, il part à l''heure. Bon voyage.','english','No, it leaves on time. Have a good trip.'),
    jsonb_build_object('speaker','You',   'target','Merci beaucoup.','english','Thank you very much.')
  ));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, quiz_questions) VALUES
  (lid, 'quiz', 5, jsonb_build_array(
    jsonb_build_object('type','multiple_choice','question','What does "PORTE" mean at the airport?','correct_answer','Gate','wrong_answers',jsonb_build_array('Ticket','Aisle','Baggage')),
    jsonb_build_object('type','multiple_choice','question','You want to ask if the flight is delayed. Which phrase?','correct_answer','Est-ce que le vol est en retard ?','wrong_answers',jsonb_build_array('Où est la porte ?','L''embarquement commence à quelle heure ?','Bon voyage')),
    jsonb_build_object('type','fill_blank','question','Complete: "J''ai une ___ à Amsterdam" (I have a connection in Amsterdam)','correct_answer','correspondance','wrong_answers',jsonb_build_array('porte','valise','destination'),'translation','connection'),
    jsonb_build_object('type','listening','question','What is being announced?','audio_prompt','L''embarquement commence à dix heures trente-cinq','correct_answer','Boarding starts at 10:35','wrong_answers',jsonb_build_array('The flight is at 10:35','Gate change to 10:35','The plane departs in 35 minutes'))
  ));
END $$;

-- ---------------- PARIS — Lesson 3 ----------------
DO $$
DECLARE lid BIGINT;
BEGIN
  SELECT l.id INTO lid FROM public.traveler_lessons l
  JOIN public.traveler_courses c ON c.id = l.traveler_course_id
  WHERE c.city = 'Paris' AND l.order_index = 3;

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, image_url, image_alt, explanation_text, data) VALUES
  (lid, 'scene', 1,
   'https://images.unsplash.com/photo-1568972340672-c95c14e57c07?w=1600&h=900&fit=crop&q=80',
   'Paris taxi rank with silver Mercedes taxis lined up outside an airport terminal',
   E'You wheel your suitcase through the sliding doors and outside to the **taxi rank at CDG**. A row of silver-and-white taxis waits, each with a green **libre** light on the roof. The rank marshal waves you toward the next available cab. Time to give your address in French.',
   jsonb_build_object('stamp','TAXI','stampSublabel','CDG → LE MARAIS'));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, data) VALUES
  (lid, 'sign', 2, jsonb_build_object(
    'style','notice',
    'title','TARIF FORFAITAIRE PARIS RIVE DROITE — 56 €',
    'subtitle','FLAT FARE, RIGHT BANK — €56',
    'note','Regulated flat fare posted at the CDG taxi rank.',
    'words', jsonb_build_array(
      jsonb_build_object('text','TARIF FORFAITAIRE','phonetic','tah-REEF for-fay-TAIR','english','Flat fare','tip','Legally posted from CDG: €56 Right Bank, €65 Left Bank — memorize this.'),
      jsonb_build_object('text','RIVE DROITE','phonetic','reev DWAHT','english','Right Bank','tip','The northern half of Paris (Le Marais, Louvre, Champs-Élysées).'),
      jsonb_build_object('text','SUPPLÉMENT','phonetic','soo-play-MAHN','english','Surcharge','tip','May apply for a 4th passenger or oversized luggage.'),
      jsonb_build_object('text','LIBRE','phonetic','LEE-bruh','english','Free (available)','tip','Green light on the taxi roof = available.')
    )));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, data) VALUES
  (lid, 'phrases', 3, jsonb_build_object('phrases', jsonb_build_array(
    jsonb_build_object('phrase','Bonjour. Dans le Marais, s''il vous plaît.','phonetic','bohn-ZHOOR dahn luh mah-RAY seel voo PLAY','english','Hello. To Le Marais, please.','tip','Always open with *bonjour*. Give the neighborhood before the address.'),
    jsonb_build_object('phrase','L''adresse est 12 rue des Rosiers.','phonetic','lah-DRESS eh dooz roo day roh-ZYAY','english','The address is 12 Rue des Rosiers.','tip','Structure: number + rue + name.'),
    jsonb_build_object('phrase','Combien ça coûte ?','phonetic','kohm-BYAN sah KOOT','english','How much does it cost?','tip','Confirm the flat fare before you set off.'),
    jsonb_build_object('phrase','Vous pouvez mettre le compteur ?','phonetic','voo poo-VAY MET-truh luh kohn-TUR','english','Can you turn on the meter?','tip','Insists politely on the meter.','grammar','*Mettre* here means "to switch on".'),
    jsonb_build_object('phrase','Un reçu, s''il vous plaît.','phonetic','uhn ruh-SOO seel voo PLAY','english','A receipt, please.','tip','Ask when you arrive and pay.')
  )));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, dialogue_lines) VALUES
  (lid, 'dialogue', 4, jsonb_build_array(
    jsonb_build_object('speaker','Driver','target','Bonjour. Vous allez où ?','english','Hello. Where are you going?'),
    jsonb_build_object('speaker','You',   'target','Bonjour. Dans le Marais, s''il vous plaît. 12 rue des Rosiers.','english','Hello. To Le Marais, please. 12 Rue des Rosiers.'),
    jsonb_build_object('speaker','Driver','target','Très bien. C''est un tarif forfaitaire : 56 €.','english','Very good. It''s a flat fare: €56.'),
    jsonb_build_object('speaker','You',   'target','D''accord. Vous acceptez la carte bancaire ?','english','OK. Do you accept card?'),
    jsonb_build_object('speaker','Driver','target','Oui, bien sûr.','english','Yes, of course.'),
    jsonb_build_object('speaker','You',   'target','Merci. Un reçu à l''arrivée, s''il vous plaît.','english','Thanks. A receipt on arrival, please.'),
    jsonb_build_object('speaker','Driver','target','Pas de problème.','english','No problem.')
  ));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, quiz_questions) VALUES
  (lid, 'quiz', 5, jsonb_build_array(
    jsonb_build_object('type','multiple_choice','question','What does "TARIF FORFAITAIRE" mean?','correct_answer','Flat fare','wrong_answers',jsonb_build_array('Meter fare','Cash only','Extra charge')),
    jsonb_build_object('type','fill_blank','question','Complete: "L''adresse est 12 ___ des Rosiers." (The address is 12 Rue des Rosiers.)','correct_answer','rue','wrong_answers',jsonb_build_array('boulevard','place','avenue'),'translation','street'),
    jsonb_build_object('type','multiple_choice','question','How do you politely ask for a receipt?','correct_answer','Un reçu, s''il vous plaît','wrong_answers',jsonb_build_array('Combien ça coûte ?','Vous acceptez la carte ?','Bonjour')),
    jsonb_build_object('type','listening','question','What is the driver telling you?','audio_prompt','C''est un tarif forfaitaire, cinquante-six euros','correct_answer','It''s a flat fare, fifty-six euros','wrong_answers',jsonb_build_array('The meter reads fifty-six euros','You owe me fifty-six euros','Fifty-six euros to the airport'))
  ));
END $$;

-- ---------------- BARCELONA — Lesson 1 ----------------
DO $$
DECLARE lid BIGINT;
BEGIN
  SELECT l.id INTO lid FROM public.traveler_lessons l
  JOIN public.traveler_courses c ON c.id = l.traveler_course_id
  WHERE c.city = 'Barcelona' AND l.order_index = 1;

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, image_url, image_alt, explanation_text, data) VALUES
  (lid, 'scene', 1,
   'https://images.unsplash.com/photo-1583422409516-2895a77efded?w=1600&h=900&fit=crop&q=80',
   'Aerial view of Barcelona showing Sagrada Família and rooftops',
   E'You''ve just landed at **Barcelona-El Prat, Terminal 1**. Mediterranean light floods the glass concourse. Signs are bilingual — Catalan on top, Spanish beneath — as you follow the crowd toward passport control.',
   jsonb_build_object('stamp','BARCELONA','stampSublabel','BCN · EL PRAT T1'));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, data) VALUES
  (lid, 'sign', 2, jsonb_build_object(
    'style','airport_blue',
    'title','ARRIBADES · LLEGADAS',
    'subtitle','ARRIVALS',
    'icon','→',
    'note','Bilingual sign — Catalan first, Spanish second.',
    'words', jsonb_build_array(
      jsonb_build_object('text','LLEGADAS','phonetic','yeh-GAH-dahs','english','Arrivals (Spanish)','tip','Same as Madrid — the Spanish word for arrivals.'),
      jsonb_build_object('text','ARRIBADES','phonetic','ah-ree-BAH-des','english','Arrivals (Catalan)','tip','Catalan version — you''ll see both on every airport sign.'),
      jsonb_build_object('text','RECOLLIDA D''EQUIPATGES','phonetic','reh-koh-YEE-dah deh-kee-PAH-jehs','english','Baggage claim (Catalan)','tip','Catalan version of *recogida de equipajes*.'),
      jsonb_build_object('text','DUANA','phonetic','doo-AH-nah','english','Customs (Catalan)','tip','Same word in Spanish (*aduana*) minus the leading a-.')
    )));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, data) VALUES
  (lid, 'phrases', 3, jsonb_build_object('phrases', jsonb_build_array(
    jsonb_build_object('phrase','Buenos días.','phonetic','BWEH-nohs DEE-ahs','english','Good morning.','tip','Officers speak Spanish; Catalan optional in this setting.'),
    jsonb_build_object('phrase','Aquí tiene mi pasaporte.','phonetic','ah-KEE tee-EH-neh mee pah-sah-POR-teh','english','Here''s my passport.','tip','A tiny bit longer than just "aquí tiene" — a polite touch.'),
    jsonb_build_object('phrase','Vengo de vacaciones.','phonetic','BEN-goh deh bah-kah-see-OH-nes','english','I''m here on vacation.','tip','More natural than "turismo" in a conversational answer.'),
    jsonb_build_object('phrase','Voy a estar diez días.','phonetic','boy ah es-TAR dee-EHS DEE-ahs','english','I''ll be here ten days.','tip','Swap the number as needed.'),
    jsonb_build_object('phrase','Muchas gracias.','phonetic','MOO-chas GRAH-see-ahs','english','Thank you very much.','tip','A universal sign-off after any exchange.')
  )));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, dialogue_lines) VALUES
  (lid, 'dialogue', 4, jsonb_build_array(
    jsonb_build_object('speaker','Officer','target','Buenos días. Pasaporte, por favor.','english','Good morning. Passport, please.'),
    jsonb_build_object('speaker','You',    'target','Aquí tiene mi pasaporte.','english','Here''s my passport.'),
    jsonb_build_object('speaker','Officer','target','¿Vacaciones o negocios?','english','Vacation or business?'),
    jsonb_build_object('speaker','You',    'target','Vengo de vacaciones. Voy a estar diez días.','english','I''m here on vacation. I''ll be here ten days.'),
    jsonb_build_object('speaker','Officer','target','¿En qué zona se hospeda?','english','What area are you staying in?'),
    jsonb_build_object('speaker','You',    'target','En un hotel en el Barrio Gótico.','english','At a hotel in the Gothic Quarter.'),
    jsonb_build_object('speaker','Officer','target','Perfecto. Que disfrute Barcelona.','english','Perfect. Enjoy Barcelona.'),
    jsonb_build_object('speaker','You',    'target','Muchas gracias.','english','Thank you very much.')
  ));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, quiz_questions) VALUES
  (lid, 'quiz', 5, jsonb_build_array(
    jsonb_build_object('type','multiple_choice','question','You see "ARRIBADES · LLEGADAS" — which language pair is that?','correct_answer','Catalan then Spanish','wrong_answers',jsonb_build_array('Spanish then Catalan','Catalan then English','Portuguese then Spanish')),
    jsonb_build_object('type','multiple_choice','question','How would you say "I''m here on vacation" naturally in Spanish?','correct_answer','Vengo de vacaciones','wrong_answers',jsonb_build_array('Estoy trabajando','Estoy estudiando','No hablo español')),
    jsonb_build_object('type','fill_blank','question','Complete: "En un hotel en el Barrio ___" (in a hotel in the Gothic Quarter)','correct_answer','Gótico','wrong_answers',jsonb_build_array('Nuevo','Viejo','Alto'),'translation','Gothic'),
    jsonb_build_object('type','listening','question','What did the officer say?','audio_prompt','Que disfrute Barcelona','correct_answer','Enjoy Barcelona','wrong_answers',jsonb_build_array('Welcome to Spain','Have a safe trip','Please wait here'))
  ));
END $$;

-- ---------------- MEXICO CITY — Lesson 1 ----------------
DO $$
DECLARE lid BIGINT;
BEGIN
  SELECT l.id INTO lid FROM public.traveler_lessons l
  JOIN public.traveler_courses c ON c.id = l.traveler_course_id
  WHERE c.city = 'Mexico City' AND l.order_index = 1;

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, image_url, image_alt, explanation_text, data) VALUES
  (lid, 'scene', 1,
   'https://images.unsplash.com/photo-1518659526054-190340b32735?w=1600&h=900&fit=crop&q=80',
   'Panoramic view of Mexico City with skyscrapers and Popocatépetl volcano',
   E'Wheels down at **Aeropuerto Internacional Benito Juárez (AICM), Terminal 2**. You step off the jet bridge into the busy concourse and follow signs marked **Migración** — Mexican Spanish for immigration.',
   jsonb_build_object('stamp','MÉXICO','stampSublabel','MEX · AICM T2'));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, data) VALUES
  (lid, 'sign', 2, jsonb_build_object(
    'style','airport_blue',
    'title','MIGRACIÓN',
    'subtitle','IMMIGRATION',
    'icon','→',
    'note','You''ll see *Migración* rather than *Control de pasaportes* in Mexico.',
    'words', jsonb_build_array(
      jsonb_build_object('text','MIGRACIÓN','phonetic','mee-grah-see-OHN','english','Immigration','tip','Mexican Spanish preferred term.'),
      jsonb_build_object('text','MEXICANOS','phonetic','meh-hee-KAH-nohs','english','Mexicans','tip','This line is for Mexican citizens only.'),
      jsonb_build_object('text','EXTRANJEROS','phonetic','ex-tran-HEH-rohs','english','Foreigners','tip','This is your line as a visitor.'),
      jsonb_build_object('text','FMM','phonetic','EH-feh EH-meh EH-meh','english','Visitor form','tip','*Forma Migratoria Múltiple* — keep the stub, you need it to leave.')
    )));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, data) VALUES
  (lid, 'phrases', 3, jsonb_build_object('phrases', jsonb_build_array(
    jsonb_build_object('phrase','Buenas tardes.','phonetic','BWEH-nahs TAR-des','english','Good afternoon.','tip','Most flights land after noon — start with *tardes*, not *días*.'),
    jsonb_build_object('phrase','Aquí está mi pasaporte y mi FMM.','phonetic','ah-KEE es-TAH mee pah-sah-POR-teh ee mee EH-feh EH-meh EH-meh','english','Here are my passport and FMM.','tip','You fill out the FMM on the plane.'),
    jsonb_build_object('phrase','Vengo de turista.','phonetic','BEN-goh deh too-REES-tah','english','I''m here as a tourist.','tip','A very common Mexican phrasing.'),
    jsonb_build_object('phrase','Me hospedo en Roma Norte.','phonetic','meh os-PEH-doh en ROH-mah NOR-teh','english','I''m staying in Roma Norte.','tip','Neighborhoods (colonias) are how locals describe locations.'),
    jsonb_build_object('phrase','¿Cuánto tiempo puedo quedarme?','phonetic','KWAN-toh tee-EM-poh PWEH-doh keh-DAR-meh','english','How long can I stay?','tip','Officers usually grant 180 days; nice to confirm.')
  )));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, dialogue_lines) VALUES
  (lid, 'dialogue', 4, jsonb_build_array(
    jsonb_build_object('speaker','Officer','target','Buenas tardes. Pasaporte y FMM, por favor.','english','Good afternoon. Passport and FMM, please.'),
    jsonb_build_object('speaker','You',    'target','Aquí está mi pasaporte y mi FMM.','english','Here are my passport and FMM.'),
    jsonb_build_object('speaker','Officer','target','¿Motivo del viaje?','english','Purpose of the trip?'),
    jsonb_build_object('speaker','You',    'target','Vengo de turista.','english','I''m here as a tourist.'),
    jsonb_build_object('speaker','Officer','target','¿Dónde se hospeda?','english','Where are you staying?'),
    jsonb_build_object('speaker','You',    'target','Me hospedo en Roma Norte.','english','I''m staying in Roma Norte.'),
    jsonb_build_object('speaker','Officer','target','Le autorizo 180 días. Bienvenido a México.','english','I''m authorizing 180 days. Welcome to Mexico.'),
    jsonb_build_object('speaker','You',    'target','Muchas gracias.','english','Thank you very much.')
  ));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, quiz_questions) VALUES
  (lid, 'quiz', 5, jsonb_build_array(
    jsonb_build_object('type','multiple_choice','question','What does "MIGRACIÓN" mean at a Mexican airport?','correct_answer','Immigration','wrong_answers',jsonb_build_array('Baggage claim','Customs','Departures')),
    jsonb_build_object('type','multiple_choice','question','You''re a visitor from abroad. Which line?','correct_answer','EXTRANJEROS','wrong_answers',jsonb_build_array('MEXICANOS','FMM','MIGRACIÓN')),
    jsonb_build_object('type','fill_blank','question','Complete: "Me hospedo en ___ Norte" (I''m staying in Roma Norte)','correct_answer','Roma','wrong_answers',jsonb_build_array('San','Nuevo','Vieja'),'translation','Roma'),
    jsonb_build_object('type','listening','question','What is being said?','audio_prompt','Le autorizo ciento ochenta días','correct_answer','I''m authorizing 180 days','wrong_answers',jsonb_build_array('You have 80 days','You can stay 8 days','Please wait 180 minutes'))
  ));
END $$;

-- ---------------- BUENOS AIRES — Lesson 1 ----------------
DO $$
DECLARE lid BIGINT;
BEGIN
  SELECT l.id INTO lid FROM public.traveler_lessons l
  JOIN public.traveler_courses c ON c.id = l.traveler_course_id
  WHERE c.city = 'Buenos Aires' AND l.order_index = 1;

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, image_url, image_alt, explanation_text, data) VALUES
  (lid, 'scene', 1,
   'https://images.unsplash.com/photo-1589909202802-8f4aadce1849?w=1600&h=900&fit=crop&q=80',
   'Aerial view of Buenos Aires with the Obelisk visible',
   E'You''ve landed at **Ezeiza** (Ministro Pistarini International). The concourse buzzes with Rioplatense Spanish — that unmistakable soft accent with **sh** sounds instead of **y** or **ll**. Follow the signs for **Migraciones**.',
   jsonb_build_object('stamp','BUENOS AIRES','stampSublabel','EZE · EZEIZA'));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, data) VALUES
  (lid, 'sign', 2, jsonb_build_object(
    'style','airport_blue',
    'title','MIGRACIONES',
    'subtitle','IMMIGRATION',
    'icon','→',
    'note','In Argentina the sign reads *Migraciones* (plural).',
    'words', jsonb_build_array(
      jsonb_build_object('text','MIGRACIONES','phonetic','mee-grah-see-OH-nes','english','Immigration','tip','Argentine Spanish uses the plural.'),
      jsonb_build_object('text','ARGENTINOS','phonetic','ar-hen-TEE-nos','english','Argentines','tip','This line is for Argentine citizens.'),
      jsonb_build_object('text','EXTRANJEROS','phonetic','ex-tran-HEH-ros','english','Foreigners','tip','Your line as a visitor.'),
      jsonb_build_object('text','RECLAMO DE EQUIPAJE','phonetic','reh-KLAH-moh deh eh-kee-PAH-heh','english','Baggage claim','tip','In Argentina, *reclamo* replaces *recogida*.')
    )));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, data) VALUES
  (lid, 'phrases', 3, jsonb_build_object('phrases', jsonb_build_array(
    jsonb_build_object('phrase','Buen día.','phonetic','bwen DEE-ah','english','Good day.','tip','Argentines often say *buen día* (singular) rather than *buenos días*.'),
    jsonb_build_object('phrase','Acá tiene.','phonetic','ah-KAH tee-EH-neh','english','Here you go.','tip','*Acá* is Argentine for *aquí*.'),
    jsonb_build_object('phrase','Vengo de vacaciones.','phonetic','BEN-goh deh bah-kah-see-OH-nes','english','I''m here on vacation.','tip','Same as elsewhere — vacaciones is universal.'),
    jsonb_build_object('phrase','Me alojo en San Telmo.','phonetic','meh ah-LOH-shoh en san TEL-moh','english','I''m staying in San Telmo.','tip','*Alojarse* is more common than *hospedarse* in Argentina.'),
    jsonb_build_object('phrase','¡Gracias, che!','phonetic','GRAH-see-ahs cheh','english','Thanks, mate!','tip','*Che* is Argentine for "hey/mate" — friendly filler.')
  )));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, dialogue_lines) VALUES
  (lid, 'dialogue', 4, jsonb_build_array(
    jsonb_build_object('speaker','Officer','target','Buen día. Pasaporte, por favor.','english','Good day. Passport, please.'),
    jsonb_build_object('speaker','You',    'target','Acá tiene.','english','Here you go.'),
    jsonb_build_object('speaker','Officer','target','¿Motivo del viaje?','english','Purpose of your trip?'),
    jsonb_build_object('speaker','You',    'target','Vengo de vacaciones. Diez días.','english','I''m here on vacation. Ten days.'),
    jsonb_build_object('speaker','Officer','target','¿En qué barrio se aloja?','english','What neighborhood are you staying in?'),
    jsonb_build_object('speaker','You',    'target','Me alojo en San Telmo.','english','I''m staying in San Telmo.'),
    jsonb_build_object('speaker','Officer','target','Perfecto. Que disfrute Buenos Aires.','english','Perfect. Enjoy Buenos Aires.'),
    jsonb_build_object('speaker','You',    'target','Gracias.','english','Thank you.')
  ));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, quiz_questions) VALUES
  (lid, 'quiz', 5, jsonb_build_array(
    jsonb_build_object('type','multiple_choice','question','How does Argentine Spanish differ for "here"?','correct_answer','acá instead of aquí','wrong_answers',jsonb_build_array('here instead of aquí','allá instead of aquí','ahí instead of aquí')),
    jsonb_build_object('type','multiple_choice','question','You want to say "I''m staying in San Telmo" the Argentine way. Which verb?','correct_answer','Me alojo','wrong_answers',jsonb_build_array('Me hospedo','Me quedo','Me vengo')),
    jsonb_build_object('type','fill_blank','question','Complete the Argentine greeting: "Buen ___" (Good day)','correct_answer','día','wrong_answers',jsonb_build_array('días','tarde','noche'),'translation','day'),
    jsonb_build_object('type','listening','question','What is being asked?','audio_prompt','¿En qué barrio se aloja?','correct_answer','What neighborhood are you staying in?','wrong_answers',jsonb_build_array('What airline are you flying?','How many days are you staying?','Do you have anything to declare?'))
  ));
END $$;

-- ---------------- LYON — Lesson 1 ----------------
DO $$
DECLARE lid BIGINT;
BEGIN
  SELECT l.id INTO lid FROM public.traveler_lessons l
  JOIN public.traveler_courses c ON c.id = l.traveler_course_id
  WHERE c.city = 'Lyon' AND l.order_index = 1;

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, image_url, image_alt, explanation_text, data) VALUES
  (lid, 'scene', 1,
   'https://images.unsplash.com/photo-1524484485831-a92ffc0de03f?w=1600&h=900&fit=crop&q=80',
   'View of Vieux Lyon rooftops with Basilique de Fourvière on the hill',
   E'You''ve landed at **Lyon-Saint Exupéry**. The concourse is small and calm — nothing like CDG''s scale. You follow signs marked **Arrivées** through immigration, ready to take the Rhônexpress into town.',
   jsonb_build_object('stamp','LYON','stampSublabel','LYS · SAINT-EXUPÉRY'));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, data) VALUES
  (lid, 'sign', 2, jsonb_build_object(
    'style','airport_blue',
    'title','ARRIVÉES',
    'subtitle','ARRIVALS',
    'icon','→',
    'note','Same signage system as CDG — France-wide standard.',
    'words', jsonb_build_array(
      jsonb_build_object('text','ARRIVÉES','phonetic','ah-ree-VAY','english','Arrivals','tip','See Paris L1 for the etymology.'),
      jsonb_build_object('text','SORTIE','phonetic','sor-TEE','english','Exit','tip','Follow this after clearing customs.'),
      jsonb_build_object('text','NAVETTE','phonetic','nah-VET','english','Shuttle','tip','The Rhônexpress tram is signed as a *navette* to *Part-Dieu*.'),
      jsonb_build_object('text','RHÔNEXPRESS','phonetic','ron-ex-PRESS','english','Rhône Express (airport tram)','tip','30 minutes to Part-Dieu train station.')
    )));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, data) VALUES
  (lid, 'phrases', 3, jsonb_build_object('phrases', jsonb_build_array(
    jsonb_build_object('phrase','Bonjour.','phonetic','bohn-ZHOOR','english','Hello.','tip','Same rule as Paris: always start with *bonjour*.'),
    jsonb_build_object('phrase','Voici mon passeport.','phonetic','vwah-SEE mohn pahs-POR','english','Here''s my passport.','tip','Slightly more formal than *voilà*.'),
    jsonb_build_object('phrase','Je viens pour le tourisme.','phonetic','zhuh vyahn poor luh too-REEZM','english','I''m here for tourism.','tip','A complete-sentence alternative to just "le tourisme".'),
    jsonb_build_object('phrase','Je vais à Lyon.','phonetic','zhuh vay ah lyohn','english','I''m going to Lyon.','tip','The airport is 20 km from the city — clarify where you''re headed.'),
    jsonb_build_object('phrase','Merci beaucoup.','phonetic','mair-SEE boh-KOO','english','Thank you very much.','tip','Standard polite sign-off.')
  )));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, dialogue_lines) VALUES
  (lid, 'dialogue', 4, jsonb_build_array(
    jsonb_build_object('speaker','Officer','target','Bonjour. Passeport, s''il vous plaît.','english','Hello. Passport, please.'),
    jsonb_build_object('speaker','You',    'target','Voici mon passeport.','english','Here''s my passport.'),
    jsonb_build_object('speaker','Officer','target','Quel est le motif de votre voyage ?','english','What is the purpose of your trip?'),
    jsonb_build_object('speaker','You',    'target','Je viens pour le tourisme. Je vais à Lyon.','english','I''m here for tourism. I''m going to Lyon.'),
    jsonb_build_object('speaker','Officer','target','Combien de temps restez-vous ?','english','How long are you staying?'),
    jsonb_build_object('speaker','You',    'target','Une semaine.','english','A week.'),
    jsonb_build_object('speaker','Officer','target','Très bien. Bon séjour.','english','Very good. Enjoy your stay.'),
    jsonb_build_object('speaker','You',    'target','Merci beaucoup.','english','Thank you very much.')
  ));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, quiz_questions) VALUES
  (lid, 'quiz', 5, jsonb_build_array(
    jsonb_build_object('type','multiple_choice','question','What does "NAVETTE" mean at the airport?','correct_answer','Shuttle','wrong_answers',jsonb_build_array('Gate','Terminal','Runway')),
    jsonb_build_object('type','multiple_choice','question','What is the Rhônexpress?','correct_answer','The airport tram to Lyon Part-Dieu','wrong_answers',jsonb_build_array('A local bus service','A high-speed TGV train','An express passport lane')),
    jsonb_build_object('type','fill_blank','question','Complete: "Je vais à ___" (I''m going to Lyon)','correct_answer','Lyon','wrong_answers',jsonb_build_array('Paris','Marseille','Bordeaux'),'translation','Lyon'),
    jsonb_build_object('type','listening','question','What is being asked?','audio_prompt','Combien de temps restez-vous ?','correct_answer','How long are you staying?','wrong_answers',jsonb_build_array('Where are you going?','What is your name?','What airline are you flying?'))
  ));
END $$;

-- ---------------- MONTREAL — Lesson 1 ----------------
DO $$
DECLARE lid BIGINT;
BEGIN
  SELECT l.id INTO lid FROM public.traveler_lessons l
  JOIN public.traveler_courses c ON c.id = l.traveler_course_id
  WHERE c.city = 'Montreal' AND l.order_index = 1;

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, image_url, image_alt, explanation_text, data) VALUES
  (lid, 'scene', 1,
   'https://images.unsplash.com/photo-1519178614-68673b201f36?w=1600&h=900&fit=crop&q=80',
   'View of downtown Montreal with skyscrapers and Mont-Royal in the background',
   E'You''ve landed at **Montréal-Trudeau (YUL)**. Signs are bilingual — French first, English second, per Québec law. You follow the crowd toward passport control, where friendly agents switch effortlessly between the two.',
   jsonb_build_object('stamp','MONTRÉAL','stampSublabel','YUL · TRUDEAU'));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, data) VALUES
  (lid, 'sign', 2, jsonb_build_object(
    'style','airport_blue',
    'title','ARRIVÉES · ARRIVALS',
    'subtitle','CONTRÔLE DES PASSEPORTS · PASSPORT CONTROL',
    'icon','→',
    'note','Bilingual signage — French first is the law in Québec.',
    'words', jsonb_build_array(
      jsonb_build_object('text','ARRIVÉES','phonetic','ah-ree-VAY','english','Arrivals','tip','Same as France — Québec French uses the same vocabulary.'),
      jsonb_build_object('text','DOUANES','phonetic','doo-AHN','english','Customs','tip','You''ll do a two-step: passport, then customs.'),
      jsonb_build_object('text','LIVRAISON DES BAGAGES','phonetic','lee-vray-ZOHN day bah-GAHZH','english','Baggage claim','tip','Identical to Paris.'),
      jsonb_build_object('text','SORTIE','phonetic','sor-TEE','english','Exit','tip','Follow signs to the taxis or the STM shuttle.')
    )));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, data) VALUES
  (lid, 'phrases', 3, jsonb_build_object('phrases', jsonb_build_array(
    jsonb_build_object('phrase','Bonjour, allô.','phonetic','bohn-ZHOOR ah-LOH','english','Hi (Québécois greeting).','tip','Québécois often greet with *bonjour-hi* — showing both languages.'),
    jsonb_build_object('phrase','Voici mon passeport.','phonetic','vwah-SEE mohn pahs-POR','english','Here''s my passport.','tip','Same as European French.'),
    jsonb_build_object('phrase','Je suis en vacances.','phonetic','zhuh sweez ahn vah-KAHNS','english','I''m on vacation.','tip','A very natural Québécois phrasing.'),
    jsonb_build_object('phrase','Je reste deux semaines.','phonetic','zhuh REST duh suh-MEN','english','I''m staying two weeks.','tip','Structure works for any number.'),
    jsonb_build_object('phrase','Merci, bonne journée.','phonetic','mair-SEE bun zhoor-NAY','english','Thanks, have a good day.','tip','Warm Québécois sign-off.')
  )));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, dialogue_lines) VALUES
  (lid, 'dialogue', 4, jsonb_build_array(
    jsonb_build_object('speaker','Officer','target','Bonjour, hi. Passeport, s''il vous plaît.','english','Bonjour, hi. Passport, please.'),
    jsonb_build_object('speaker','You',    'target','Voici mon passeport.','english','Here''s my passport.'),
    jsonb_build_object('speaker','Officer','target','Quelle est la raison de votre visite au Canada ?','english','What is the reason for your visit to Canada?'),
    jsonb_build_object('speaker','You',    'target','Je suis en vacances. Je reste deux semaines.','english','I''m on vacation. I''m staying two weeks.'),
    jsonb_build_object('speaker','Officer','target','Où logez-vous à Montréal ?','english','Where are you staying in Montreal?'),
    jsonb_build_object('speaker','You',    'target','Dans un hôtel dans le Vieux-Montréal.','english','At a hotel in Old Montreal.'),
    jsonb_build_object('speaker','Officer','target','Parfait. Bienvenue au Canada.','english','Perfect. Welcome to Canada.'),
    jsonb_build_object('speaker','You',    'target','Merci, bonne journée.','english','Thanks, have a good day.')
  ));

  INSERT INTO public.traveler_lesson_content (traveler_lesson_id, content_type, content_order, quiz_questions) VALUES
  (lid, 'quiz', 5, jsonb_build_array(
    jsonb_build_object('type','multiple_choice','question','What is the classic Québécois bilingual greeting?','correct_answer','Bonjour-hi','wrong_answers',jsonb_build_array('Salut','Allô-bye','Bonsoir')),
    jsonb_build_object('type','fill_blank','question','Complete: "Je reste ___ semaines" (I''m staying two weeks)','correct_answer','deux','wrong_answers',jsonb_build_array('trois','quatre','cinq'),'translation','two'),
    jsonb_build_object('type','multiple_choice','question','You want to say you''re staying at a hotel in Old Montreal. Which is correct?','correct_answer','Dans un hôtel dans le Vieux-Montréal','wrong_answers',jsonb_build_array('Chez un ami à Montréal','Dans un Airbnb au centre-ville','À la campagne près de Québec')),
    jsonb_build_object('type','listening','question','What did the officer say?','audio_prompt','Bienvenue au Canada','correct_answer','Welcome to Canada','wrong_answers',jsonb_build_array('Have a nice trip','Please wait here','See you soon'))
  ));
END $$;


-- ============================================================
-- 5. VERIFICATION
--   Expected:
--     traveler_courses         =   7
--     traveler_lessons         = 350   (7 × 50)
--     traveler_lesson_content  =  55   (11 lessons × 5 sections)
-- ============================================================

SELECT 'traveler_courses'        AS table_name, COUNT(*) AS rows FROM public.traveler_courses
UNION ALL SELECT 'traveler_lessons',        COUNT(*) FROM public.traveler_lessons
UNION ALL SELECT 'traveler_lesson_content', COUNT(*) FROM public.traveler_lesson_content
UNION ALL SELECT 'traveler_progress',       COUNT(*) FROM public.traveler_progress
ORDER BY table_name;

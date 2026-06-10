-- 033_spanish_b1_complete.sql
-- Full Spanish B1 curriculum in one migration. Mirrors the structure
-- already established for A1 (017-021) and A2 (024-027): teaching phase
-- on lessons 1-7, 5 substantive exercises per lesson, listening +
-- speaking additions on lessons 1/2/3/6/7, conversation dialogue at
-- lesson 8 with 6 comprehension questions, and a unit test at lesson 9.
--
-- B1 sections (already created as skeletons by migration 015):
--   Travel & Tourism, News & Media, Environment, Relationships,
--   Culture & Traditions, Money & Banking, Education, Politics Basics,
--   Food & Cooking, Art & Literature, Health & Medicine, Business Basics,
--   Sports & Fitness, Music & Entertainment, Science Basics
--
-- Idempotent: every block deletes existing exercises / lesson 9 rows
-- before inserting, and overwrites the lessons.* fields on lessons 1-8.

-- Ensure lesson type check accepts conversation + unit_test.
alter table public.lessons drop constraint if exists lessons_type_check;
alter table public.lessons
  add constraint lessons_type_check
  check (type in (
    'vocabulary','grammar','phrases','listening','speaking',
    'reading','writing','podcast','unit_test','conversation'
  ));

do $$
declare
  v_lang_id   bigint;
  v_course_id bigint;
  v_l1 bigint; v_l2 bigint; v_l3 bigint; v_l4 bigint;
  v_l5 bigint; v_l6 bigint; v_l7 bigint; v_l8 bigint;
  v_lesson_id bigint;
begin
  select id into v_lang_id from public.languages where code = 'spanish';

  -- ===========================================================
  -- B1.1 TRAVEL & TOURISM
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B1' and title = 'Travel & Tourism';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro = 'In this lesson you''ll learn the travel vocabulary you need to plan and describe a trip in Spanish.',
    vocab_items = '[
      {"word":"el itinerario","phonetic":"[ee-tee-neh-RAH-ryoh]","english":"itinerary","example_es":"Mi itinerario incluye tres ciudades.","example_en":"My itinerary includes three cities."},
      {"word":"el alojamiento","phonetic":"[ah-loh-hah-MYEHN-toh]","english":"accommodation","example_es":"Busco alojamiento barato.","example_en":"I''m looking for cheap accommodation."},
      {"word":"el guía turístico","phonetic":"[GEE-ah too-REES-tee-koh]","english":"tour guide","example_es":"El guía habla tres idiomas.","example_en":"The guide speaks three languages."},
      {"word":"la frontera","phonetic":"[frohn-TEH-rah]","english":"border","example_es":"Cruzamos la frontera en autobús.","example_en":"We crossed the border by bus."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Agente","spanish":"¿Ya tiene listo el itinerario?","english":"Do you have your itinerary ready?"},
      {"speaker":"Marta","spanish":"Sí, voy a tres ciudades en dos semanas.","english":"Yes, I''m going to three cities in two weeks."},
      {"speaker":"Agente","spanish":"Necesita reservar el alojamiento cuanto antes.","english":"You need to book accommodation as soon as possible."}
    ]'::jsonb,
    grammar_note = 'B1 introduces the future tense: viajaré, reservaré, visitaré. Built on the infinitive + endings (-é, -ás, -á, -emos, -éis, -án).'
  where id = v_l1;

  update public.lessons set
    intro = 'Travel verbs in past tense — preterite vs imperfect. Use preterite for finished events, imperfect for backgrounds and descriptions.',
    vocab_items = '[
      {"word":"viajé","phonetic":"[byah-HEH]","english":"I travelled","example_es":"El año pasado viajé a Perú.","example_en":"Last year I travelled to Peru."},
      {"word":"viajaba","phonetic":"[byah-HAH-bah]","english":"I was travelling","example_es":"Cuando era niño viajaba mucho.","example_en":"When I was a child I travelled a lot."},
      {"word":"perdí","phonetic":"[pehr-DEE]","english":"I lost","example_es":"Perdí mi maleta en el aeropuerto.","example_en":"I lost my suitcase at the airport."},
      {"word":"hacía","phonetic":"[ah-SEE-ah]","english":"it was (weather)","example_es":"Hacía mucho calor cuando llegué.","example_en":"It was very hot when I arrived."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Luis","spanish":"¿Qué tal el viaje?","english":"How was the trip?"},
      {"speaker":"Sofía","spanish":"Increíble, pero perdí mi maleta el primer día.","english":"Incredible, but I lost my suitcase on the first day."},
      {"speaker":"Luis","spanish":"¿Y qué hacías mientras esperabas?","english":"And what were you doing while you waited?"}
    ]'::jsonb,
    grammar_note = 'Preterite = single completed action (viajé). Imperfect = ongoing or repeated background (viajaba, hacía). Both often appear in the same sentence: "Cuando llegué, llovía."'
  where id = v_l2;

  update public.lessons set
    intro = 'Useful phrases at the airport, hotel reception and tourist office.',
    vocab_items = '[
      {"word":"¿Hay servicio de habitaciones?","phonetic":"[I sehr-BEE-syoh deh ah-bee-tah-SYOH-nehs]","english":"Is there room service?","example_es":"¿Hay servicio de habitaciones a las once?","example_en":"Is there room service at eleven?"},
      {"word":"Quisiera reservar","phonetic":"[kee-SYEH-rah rreh-sehr-BAR]","english":"I would like to book","example_es":"Quisiera reservar una habitación doble.","example_en":"I would like to book a double room."},
      {"word":"¿Está incluido el desayuno?","phonetic":"[ehs-TAH een-kloo-EE-doh ehl deh-sah-YOO-noh]","english":"Is breakfast included?","example_es":"¿Está incluido el desayuno en el precio?","example_en":"Is breakfast included in the price?"},
      {"word":"Me han perdido la maleta","phonetic":"[meh ahn pehr-DEE-doh lah mah-LEH-tah]","english":"They''ve lost my suitcase","example_es":"Me han perdido la maleta y necesito ayuda.","example_en":"They''ve lost my suitcase and I need help."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Recepcionista","spanish":"¿En qué puedo ayudarle?","english":"How can I help you?"},
      {"speaker":"Cliente","spanish":"Quisiera reservar una habitación doble para tres noches.","english":"I''d like to book a double room for three nights."},
      {"speaker":"Recepcionista","spanish":"¿Con desayuno incluido?","english":"With breakfast included?"}
    ]'::jsonb,
    grammar_note = 'QUISIERA is the conditional/polite form of querer — use it instead of "quiero" when speaking to staff. Much softer and very common in service Spanish.'
  where id = v_l3;

  update public.lessons set
    intro = 'Train your ear for airport and hotel announcements.',
    vocab_items = '[
      {"word":"el embarque","phonetic":"[ehm-BAR-keh]","english":"boarding","example_es":"El embarque comienza a las once.","example_en":"Boarding begins at eleven."},
      {"word":"la escala","phonetic":"[ehs-KAH-lah]","english":"layover","example_es":"Tengo una escala de dos horas.","example_en":"I have a two-hour layover."},
      {"word":"la salida","phonetic":"[sah-LEE-dah]","english":"departure / exit","example_es":"La salida está retrasada.","example_en":"Departure is delayed."},
      {"word":"el equipaje","phonetic":"[eh-kee-PAH-heh]","english":"luggage","example_es":"Mi equipaje pesa demasiado.","example_en":"My luggage is too heavy."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Megafonía","spanish":"Atención pasajeros del vuelo IB 245 a Buenos Aires.","english":"Attention passengers on flight IB 245 to Buenos Aires."},
      {"speaker":"Megafonía","spanish":"El embarque comenzará a las quince y cuarto por la puerta veintidós.","english":"Boarding will begin at 15:15 at gate 22."},
      {"speaker":"Megafonía","spanish":"Por favor, no dejen su equipaje sin vigilancia.","english":"Please do not leave your luggage unattended."}
    ]'::jsonb,
    grammar_note = 'In formal announcements you''ll hear the future indicative often: comenzará, saldrá, aterrizará. Don''t confuse with the ir a + infinitive near future used in casual speech.'
  where id = v_l4;

  update public.lessons set
    intro = 'Say full travel phrases out loud — at the desk, on the plane, at the hotel.',
    vocab_items = '[
      {"word":"¿Cuál es la puerta de embarque?","phonetic":"[KWAHL ehs lah PWEHR-tah]","english":"What gate is it?","example_es":"¿Cuál es la puerta de embarque para Madrid?","example_en":"What gate is it for Madrid?"},
      {"word":"Voy a facturar dos maletas","phonetic":"[BOY ah fahk-too-RAR]","english":"I''m checking two bags","example_es":"Voy a facturar dos maletas grandes.","example_en":"I''m checking two large bags."},
      {"word":"Necesito una conexión","phonetic":"[neh-seh-SEE-toh OO-nah koh-nehk-SYOHN]","english":"I need a connection","example_es":"Necesito una conexión en Madrid.","example_en":"I need a connection in Madrid."},
      {"word":"¿Cuánto cuesta el upgrade?","phonetic":"[KWAHN-toh KWEHS-tah]","english":"How much for the upgrade?","example_es":"¿Cuánto cuesta el upgrade a primera?","example_en":"How much for the upgrade to first class?"}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Viajero","spanish":"Disculpe, ¿cuál es la puerta de embarque?","english":"Excuse me, what is the boarding gate?"},
      {"speaker":"Empleado","spanish":"La 22, pero está cambiando. Mire la pantalla.","english":"Gate 22, but it''s changing. Check the screen."},
      {"speaker":"Viajero","spanish":"Gracias. Voy a facturar mi maleta.","english":"Thanks. I''m going to check my bag."}
    ]'::jsonb,
    grammar_note = 'Use the polite "disculpe" instead of "perdón" when interrupting strangers in a more formal setting.'
  where id = v_l5;

  update public.lessons set
    intro = 'Read a short travel review and pick out key facts.',
    vocab_items = '[
      {"word":"la reseña","phonetic":"[rreh-SEH-nyah]","english":"review","example_es":"Escribí una reseña del hotel.","example_en":"I wrote a hotel review."},
      {"word":"la estancia","phonetic":"[ehs-TAHN-syah]","english":"stay","example_es":"Disfruté toda la estancia.","example_en":"I enjoyed the whole stay."},
      {"word":"la atención","phonetic":"[ah-tehn-SYOHN]","english":"service / attention","example_es":"La atención fue excelente.","example_en":"The service was excellent."},
      {"word":"decepcionante","phonetic":"[deh-sehp-syoh-NAHN-teh]","english":"disappointing","example_es":"El desayuno fue decepcionante.","example_en":"Breakfast was disappointing."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"El hotel Las Palmeras tiene una ubicación excelente, justo en el centro.","english":"The Las Palmeras hotel has an excellent location, right in the centre."},
      {"speaker":"Texto","spanish":"Las habitaciones son amplias, pero el desayuno fue decepcionante.","english":"The rooms are spacious, but breakfast was disappointing."},
      {"speaker":"Texto","spanish":"La atención del personal compensó cualquier defecto.","english":"The staff''s service made up for any flaw."}
    ]'::jsonb,
    grammar_note = 'Reviews mix preterite (fue, llegamos) for specific events with present (es, son) for ongoing characteristics. Notice the contrast in the dialogue above.'
  where id = v_l6;

  update public.lessons set
    intro = 'Write a short travel review combining preterite, imperfect and opinion connectors.',
    vocab_items = '[
      {"word":"recomendar","phonetic":"[rreh-koh-mehn-DAR]","english":"to recommend","example_es":"Recomiendo este hotel sin reservas.","example_en":"I recommend this hotel without reservation."},
      {"word":"sin embargo","phonetic":"[seen ehm-BAR-goh]","english":"however","example_es":"Era barato; sin embargo, estaba sucio.","example_en":"It was cheap; however, it was dirty."},
      {"word":"en general","phonetic":"[ehn heh-neh-RAHL]","english":"overall","example_es":"En general, una buena experiencia.","example_en":"Overall, a good experience."},
      {"word":"a pesar de","phonetic":"[ah peh-SAR deh]","english":"despite","example_es":"A pesar del precio, no lo recomendaría.","example_en":"Despite the price, I wouldn''t recommend it."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Modelo","spanish":"Pasé tres noches en este hotel durante mi viaje a Barcelona.","english":"I spent three nights at this hotel during my Barcelona trip."},
      {"speaker":"Modelo","spanish":"La ubicación era ideal y el personal muy amable.","english":"The location was ideal and the staff very kind."},
      {"speaker":"Modelo","spanish":"Sin embargo, el desayuno fue decepcionante. En general, lo recomendaría.","english":"However, breakfast was disappointing. Overall I would recommend it."}
    ]'::jsonb,
    grammar_note = 'Conditional tense for polite opinions: recomendaría, diría, sugeriría. Built on infinitive + -ía endings.'
  where id = v_l7;

  -- Substantive exercises (lessons 1-7), 5 each
  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','How do you say "itinerary"?','el itinerario',array['la frontera','el alojamiento','el guía'],'itinerary',1),
  (v_l1,'fill_blank','Complete: "Necesito ____ barato." (accommodation)','alojamiento',array['itinerario','frontera','guía'],'accommodation',2),
  (v_l1,'multiple_choice','What does "cruzar la frontera" mean?','to cross the border',array['to plan a trip','to book a hotel','to take a tour'],'to cross the border',3),
  (v_l1,'listening','What did you hear? Pick the Spanish phrase.','Mi itinerario incluye tres ciudades',array['Busco alojamiento barato','El guía habla tres idiomas','Cruzamos la frontera'],'My itinerary includes three cities',4),
  (v_l1,'speaking','Say this aloud: "Voy a reservar un hotel."','Voy a reservar un hotel',array[]::text[],'I''m going to book a hotel.',5),
  (v_l2,'multiple_choice','Which is the preterite "I lost"?','perdí',array['perdía','pierdo','perdería'],'I lost (preterite)',1),
  (v_l2,'fill_blank','Complete: "Cuando era niño, ____ mucho." (I travelled - imperfect)','viajaba',array['viajé','viajo','viajaré'],'I used to travel',2),
  (v_l2,'multiple_choice','Translate "Hacía calor cuando llegué."','It was hot when I arrived',array['It''s hot when I arrive','I felt hot','I arrive when it''s hot'],'It was hot when I arrived',3),
  (v_l2,'listening','What did you hear?','Perdí mi maleta en el aeropuerto',array['Cuando era niño viajaba mucho','Hacía calor cuando llegué','El año pasado viajé a Perú'],'I lost my suitcase at the airport',4),
  (v_l2,'speaking','Say this aloud: "Cuando llegué llovía."','Cuando llegué llovía',array[]::text[],'When I arrived it was raining.',5),
  (v_l3,'multiple_choice','How do you politely ask to book?','Quisiera reservar',array['Quiero reservar','Reservar puedo','Reservo'],'I would like to book',1),
  (v_l3,'fill_blank','Complete: "¿Está ____ el desayuno?" (included)','incluido',array['incluyendo','incluye','incluyo'],'included',2),
  (v_l3,'multiple_choice','What does "Me han perdido la maleta" mean?','They''ve lost my suitcase',array['I''ve lost my suitcase','My suitcase is mine','I sold my suitcase'],'They''ve lost my suitcase',3),
  (v_l3,'listening','What did you hear?','Quisiera reservar una habitación doble',array['¿Hay servicio de habitaciones?','¿Está incluido el desayuno?','Me han perdido la maleta'],'I''d like to book a double room',4),
  (v_l3,'speaking','Say this aloud: "Quisiera reservar una habitación doble."','Quisiera reservar una habitación doble',array[]::text[],'I''d like to book a double room.',5),
  (v_l4,'multiple_choice','What is "boarding"?','el embarque',array['la escala','la salida','el equipaje'],'boarding',1),
  (v_l4,'fill_blank','Complete: "Tengo una ____ de dos horas." (layover)','escala',array['salida','equipaje','embarque'],'layover',2),
  (v_l4,'multiple_choice','What does "vigilancia" mean?','watch / supervision',array['announcement','luggage','gate'],'watch',3),
  (v_l4,'listening','What did you hear?','El embarque comenzará a las quince y cuarto',array['Mi equipaje pesa demasiado','La salida está retrasada','Tengo una escala de dos horas'],'Boarding will begin at 15:15',4),
  (v_l4,'speaking','Say this aloud: "La salida está retrasada."','La salida está retrasada',array[]::text[],'Departure is delayed.',5),
  (v_l5,'multiple_choice','How do you ask "What gate is it?"','¿Cuál es la puerta de embarque?',array['¿Dónde está la maleta?','¿Cuánto cuesta el vuelo?','¿A qué hora sale?'],'What gate?',1),
  (v_l5,'fill_blank','Complete: "Voy a ____ dos maletas." (check)','facturar',array['perder','reservar','cruzar'],'to check (luggage)',2),
  (v_l5,'multiple_choice','What does "una conexión" mean?','a connection',array['a delay','an upgrade','a refund'],'a connection',3),
  (v_l5,'listening','What did you hear?','Voy a facturar dos maletas grandes',array['¿Cuánto cuesta el upgrade?','La 22, pero está cambiando','Necesito una conexión en Madrid'],'I''m checking two large bags',4),
  (v_l5,'speaking','Say this aloud: "Necesito una conexión en Madrid."','Necesito una conexión en Madrid',array[]::text[],'I need a connection in Madrid.',5),
  (v_l6,'multiple_choice','What is "review"?','la reseña',array['la estancia','la atención','la decepción'],'review',1),
  (v_l6,'fill_blank','Complete: "El desayuno fue ____" (disappointing)','decepcionante',array['excelente','amable','grande'],'disappointing',2),
  (v_l6,'multiple_choice','What does "ubicación" mean?','location',array['service','room','breakfast'],'location',3),
  (v_l6,'listening','What did you hear?','La atención del personal compensó cualquier defecto',array['El hotel tiene una ubicación excelente','Las habitaciones son amplias','El desayuno fue decepcionante'],'The staff''s service made up for any flaw',4),
  (v_l6,'speaking','Say this aloud: "Disfruté toda la estancia."','Disfruté toda la estancia',array[]::text[],'I enjoyed the whole stay.',5),
  (v_l7,'multiple_choice','How do you say "however"?','sin embargo',array['en general','a pesar de','recomendar'],'however',1),
  (v_l7,'fill_blank','Complete: "____, una buena experiencia." (Overall)','En general',array['Sin embargo','A pesar de','Recomendar'],'Overall',2),
  (v_l7,'multiple_choice','What does "lo recomendaría" mean?','I would recommend it',array['I recommended it','I will recommend it','I recommend it'],'I would recommend it (conditional)',3),
  (v_l7,'listening','What did you hear?','En general, lo recomendaría',array['La ubicación era ideal','Sin embargo, fue decepcionante','A pesar del precio'],'Overall I would recommend it',4),
  (v_l7,'speaking','Say this aloud: "Recomiendo este hotel."','Recomiendo este hotel',array[]::text[],'I recommend this hotel.',5);

  -- L+S additions (lessons 1,2,3,6,7), 4 each
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Busco alojamiento barato',array['Mi itinerario incluye tres ciudades','El guía habla tres idiomas','Cruzamos la frontera en autobús'],'I''m looking for cheap accommodation',6),
  (v_l1,'listening','What did you hear?','El guía habla tres idiomas',array['Busco alojamiento barato','Mi itinerario incluye tres ciudades','Cruzamos la frontera'],'The guide speaks three languages',7),
  (v_l1,'speaking','Say this aloud: "Mi itinerario incluye tres ciudades."','Mi itinerario incluye tres ciudades',array[]::text[],'My itinerary includes three cities.',8),
  (v_l1,'speaking','Say this aloud: "Cruzamos la frontera en autobús."','Cruzamos la frontera en autobús',array[]::text[],'We crossed the border by bus.',9),
  (v_l2,'listening','What did you hear?','El año pasado viajé a Perú',array['Cuando era niño viajaba mucho','Perdí mi maleta','Hacía calor cuando llegué'],'Last year I travelled to Peru',6),
  (v_l2,'listening','What did you hear?','Cuando era niño viajaba mucho',array['El año pasado viajé','Perdí mi maleta','Hacía calor'],'When I was a child I travelled a lot',7),
  (v_l2,'speaking','Say this aloud: "Perdí mi maleta."','Perdí mi maleta',array[]::text[],'I lost my suitcase.',8),
  (v_l2,'speaking','Say this aloud: "Hacía calor cuando llegué."','Hacía calor cuando llegué',array[]::text[],'It was hot when I arrived.',9),
  (v_l3,'listening','What did you hear?','¿Hay servicio de habitaciones?',array['Quisiera reservar','¿Está incluido el desayuno?','Me han perdido la maleta'],'Is there room service?',6),
  (v_l3,'listening','What did you hear?','¿Está incluido el desayuno?',array['Quisiera reservar','¿Hay servicio?','Me han perdido la maleta'],'Is breakfast included?',7),
  (v_l3,'speaking','Say this aloud: "¿Está incluido el desayuno?"','¿Está incluido el desayuno?',array[]::text[],'Is breakfast included?',8),
  (v_l3,'speaking','Say this aloud: "Me han perdido la maleta."','Me han perdido la maleta',array[]::text[],'They''ve lost my suitcase.',9),
  (v_l6,'listening','What did you hear?','Las habitaciones son amplias',array['El desayuno fue decepcionante','La atención fue excelente','Escribí una reseña'],'The rooms are spacious',6),
  (v_l6,'listening','What did you hear?','La atención fue excelente',array['Las habitaciones son amplias','El desayuno fue decepcionante','Disfruté toda la estancia'],'The service was excellent',7),
  (v_l6,'speaking','Say this aloud: "La atención fue excelente."','La atención fue excelente',array[]::text[],'The service was excellent.',8),
  (v_l6,'speaking','Say this aloud: "El desayuno fue decepcionante."','El desayuno fue decepcionante',array[]::text[],'Breakfast was disappointing.',9),
  (v_l7,'listening','What did you hear?','A pesar del precio, no lo recomendaría',array['En general, lo recomendaría','Era barato; sin embargo, estaba sucio','Pasé tres noches'],'Despite the price, I wouldn''t recommend it',6),
  (v_l7,'listening','What did you hear?','Sin embargo, el desayuno fue decepcionante',array['En general, una buena experiencia','La ubicación era ideal','Recomiendo este hotel'],'However, breakfast was disappointing',7),
  (v_l7,'speaking','Say this aloud: "Sin embargo, lo recomendaría."','Sin embargo, lo recomendaría',array[]::text[],'However, I would recommend it.',8),
  (v_l7,'speaking','Say this aloud: "A pesar del precio, fue genial."','A pesar del precio, fue genial',array[]::text[],'Despite the price, it was great.',9);

  -- Lesson 8 conversation
  update public.lessons set
    type = 'conversation',
    title = 'Travel & Tourism — Conversation Practice',
    description = 'Two travellers meet on a delayed flight and talk about their itineraries.',
    intro = 'Eva and Tomás are stuck at the airport. Listen as they compare their travel plans.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Eva","spanish":"¿También a Buenos Aires?","english":"Also going to Buenos Aires?"},
      {"speaker":"Tomás","spanish":"Sí, pero tengo una escala en Madrid de cuatro horas.","english":"Yes, but I have a four-hour layover in Madrid."},
      {"speaker":"Eva","spanish":"¡Qué pesado! Yo voy directo.","english":"What a drag! I''m going direct."},
      {"speaker":"Tomás","spanish":"¿Y tu itinerario?","english":"What about your itinerary?"},
      {"speaker":"Eva","spanish":"Tres ciudades en dos semanas: Buenos Aires, Mendoza y Bariloche.","english":"Three cities in two weeks: Buenos Aires, Mendoza and Bariloche."},
      {"speaker":"Tomás","spanish":"¿Has reservado todo el alojamiento?","english":"Have you booked all the accommodation?"},
      {"speaker":"Eva","spanish":"Casi todo. Sólo me falta el último hotel.","english":"Almost. I''m just missing the last hotel."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','Where are they both going?','Buenos Aires',array['Madrid','Mendoza','Bariloche'],'Buenos Aires',1),
  (v_l8,'multiple_choice','How long is Tomás''s layover?','4 hours',array['2 hours','3 hours','6 hours'],'cuatro horas',2),
  (v_l8,'multiple_choice','How many cities will Eva visit?','3',array['2','4','5'],'Tres ciudades',3),
  (v_l8,'multiple_choice','True or false: Eva has a layover too.','False',array['True'],'Yo voy directo',4),
  (v_l8,'fill_blank','Complete: "Sólo me ____ el último hotel." (missing)','falta',array['hace','tiene','toca'],'missing',5),
  (v_l8,'multiple_choice','Has Eva booked all her accommodation?','Almost all of it',array['None','All','She doesn''t know'],'Casi todo',6);

  -- Unit test (lesson 9)
  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Travel & Tourism', 'Review test for the whole Travel & Tourism section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "itinerary"?','el itinerario',array['el equipaje','la escala','la frontera'],'itinerary',1),
  (v_lesson_id,'multiple_choice','Which is preterite of "viajar" (I)?','viajé',array['viajaba','viajo','viajaré'],'I travelled',2),
  (v_lesson_id,'multiple_choice','How to politely book?','Quisiera reservar',array['Quiero reservar','Reservaré','Reservé'],'I would like to book',3),
  (v_lesson_id,'multiple_choice','True/false: Imperfect = single completed action.','False',array['True'],'Imperfect = ongoing/background',4),
  (v_lesson_id,'fill_blank','Complete: "El embarque ____ a las once." (will begin)','comenzará',array['comenzaba','comienza','comenzó'],'will begin (future)',5),
  (v_lesson_id,'fill_blank','Complete: "Sin ____, lo recomiendo." (however)','embargo',array['general','pesar','duda'],'sin embargo',6),
  (v_lesson_id,'listening','What did you hear?','Mi itinerario incluye tres ciudades',array['Busco alojamiento','La salida está retrasada','El embarque comenzará'],'My itinerary includes three cities',7),
  (v_lesson_id,'listening','What did you hear?','La atención fue excelente',array['El desayuno fue decepcionante','Las habitaciones son amplias','Disfruté toda la estancia'],'The service was excellent',8),
  (v_lesson_id,'speaking','Say this aloud: "Quisiera reservar una habitación."','Quisiera reservar una habitación',array[]::text[],'I''d like to book a room.',9),
  (v_lesson_id,'speaking','Say this aloud: "Sin embargo, lo recomendaría."','Sin embargo, lo recomendaría',array[]::text[],'However, I would recommend it.',10);

  -- ===========================================================
  -- B1.2 NEWS & MEDIA
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B1' and title = 'News & Media';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro = 'Vocabulary for talking about news, headlines and media sources.',
    vocab_items = '[
      {"word":"la noticia","phonetic":"[noh-TEE-syah]","english":"the news (item)","example_es":"La noticia salió ayer.","example_en":"The news came out yesterday."},
      {"word":"el titular","phonetic":"[tee-too-LAR]","english":"the headline","example_es":"El titular era impactante.","example_en":"The headline was striking."},
      {"word":"el periodista","phonetic":"[peh-ryoh-DEES-tah]","english":"the journalist","example_es":"El periodista entrevistó al ministro.","example_en":"The journalist interviewed the minister."},
      {"word":"la fuente","phonetic":"[FWEHN-teh]","english":"the source","example_es":"Necesitamos una fuente confiable.","example_en":"We need a reliable source."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Ana","spanish":"¿Has leído el titular de hoy?","english":"Have you read today''s headline?"},
      {"speaker":"Luis","spanish":"Sí, pero la fuente no es muy confiable.","english":"Yes, but the source isn''t very reliable."},
      {"speaker":"Ana","spanish":"Tienes razón, hay que verificar la noticia.","english":"You''re right, we have to verify the news."}
    ]'::jsonb,
    grammar_note = 'Present perfect: he/has/ha/hemos/habéis/han + past participle. Used for recent events with present relevance: "¿Has leído?" = "Have you read?"'
  where id = v_l1;

  update public.lessons set
    intro = 'Reporting verbs and indirect speech. How to say what someone else said.',
    vocab_items = '[
      {"word":"afirmar","phonetic":"[ah-feer-MAR]","english":"to claim / assert","example_es":"El presidente afirmó que ganaría.","example_en":"The president claimed he would win."},
      {"word":"negar","phonetic":"[neh-GAR]","english":"to deny","example_es":"El sospechoso negó todo.","example_en":"The suspect denied everything."},
      {"word":"declarar","phonetic":"[deh-klah-RAR]","english":"to declare","example_es":"La empresa declaró bancarrota.","example_en":"The company declared bankruptcy."},
      {"word":"según","phonetic":"[seh-GOON]","english":"according to","example_es":"Según el informe, los datos son ciertos.","example_en":"According to the report, the data is correct."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Eva","spanish":"¿Qué dijo el alcalde?","english":"What did the mayor say?"},
      {"speaker":"Iván","spanish":"Declaró que el proyecto comenzará en marzo.","english":"He declared the project will start in March."},
      {"speaker":"Eva","spanish":"Según otros, no hay presupuesto suficiente.","english":"According to others, there isn''t enough budget."}
    ]'::jsonb,
    grammar_note = 'Indirect speech: "Dijo que vendría" (He said he would come). Verb tenses shift back: present → imperfect, future → conditional.'
  where id = v_l2;

  update public.lessons set
    intro = 'Phrases for discussing what''s in the news with friends.',
    vocab_items = '[
      {"word":"al parecer","phonetic":"[ahl pah-reh-SEHR]","english":"apparently","example_es":"Al parecer, hubo un acuerdo.","example_en":"Apparently there was an agreement."},
      {"word":"estar al día","phonetic":"[ehs-TAR ahl DEE-ah]","english":"to be up to date","example_es":"Intento estar al día con las noticias.","example_en":"I try to keep up with the news."},
      {"word":"sin duda","phonetic":"[seen DOO-dah]","english":"no doubt","example_es":"Sin duda, es un escándalo.","example_en":"No doubt, it''s a scandal."},
      {"word":"polémico","phonetic":"[poh-LEH-mee-koh]","english":"controversial","example_es":"Es un tema muy polémico.","example_en":"It''s a very controversial topic."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Marta","spanish":"¿Has visto lo del nuevo impuesto?","english":"Have you seen the news about the new tax?"},
      {"speaker":"Pedro","spanish":"Sí, es muy polémico. Al parecer afecta a todos.","english":"Yes, it''s very controversial. Apparently it affects everyone."},
      {"speaker":"Marta","spanish":"Sin duda va a haber protestas.","english":"No doubt there will be protests."}
    ]'::jsonb,
    grammar_note = '"Lo de + noun" = "the matter of / the thing about". A casual way to refer to a news story without naming it.'
  where id = v_l3;

  update public.lessons set
    intro = 'Listen to short news bulletins. Focus on the main facts.',
    vocab_items = '[
      {"word":"el comunicado","phonetic":"[koh-moo-nee-KAH-doh]","english":"the press release","example_es":"El comunicado oficial salió hoy.","example_en":"The official press release came out today."},
      {"word":"la encuesta","phonetic":"[ehn-KWEHS-tah]","english":"the poll","example_es":"Una encuesta muestra apoyo.","example_en":"A poll shows support."},
      {"word":"el portavoz","phonetic":"[pohr-tah-BOHS]","english":"the spokesperson","example_es":"El portavoz aclaró la situación.","example_en":"The spokesperson clarified the situation."},
      {"word":"la rueda de prensa","phonetic":"[RRWEH-dah deh PREHN-sah]","english":"press conference","example_es":"Habrá rueda de prensa mañana.","example_en":"There will be a press conference tomorrow."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Locutor","spanish":"En el comunicado oficial, el ministerio confirma los cambios.","english":"In the official press release, the ministry confirms the changes."},
      {"speaker":"Locutor","spanish":"Una nueva encuesta muestra que el 60% de los ciudadanos apoyan la medida.","english":"A new poll shows 60% of citizens support the measure."},
      {"speaker":"Locutor","spanish":"Mañana habrá una rueda de prensa.","english":"Tomorrow there will be a press conference."}
    ]'::jsonb,
    grammar_note = 'News Spanish uses many noun-based constructions: "habrá rueda de prensa", "tendrá lugar la reunión". Future of haber / tener.'
  where id = v_l4;

  update public.lessons set
    intro = 'Practice saying news phrases aloud as if you were a reporter.',
    vocab_items = '[
      {"word":"Según fuentes oficiales","phonetic":"[seh-GOON FWEHN-tehs oh-fee-SYAH-lehs]","english":"According to official sources","example_es":"Según fuentes oficiales, el plan está aprobado.","example_en":"According to official sources, the plan is approved."},
      {"word":"Buenas noches","phonetic":"[BWEH-nahs NOH-chehs]","english":"Good evening","example_es":"Buenas noches y bienvenidos al noticiero.","example_en":"Good evening and welcome to the news."},
      {"word":"hubo un atentado","phonetic":"[OO-boh oon ah-tehn-TAH-doh]","english":"there was an attack","example_es":"Anoche hubo un atentado en el centro.","example_en":"Last night there was an attack downtown."},
      {"word":"sin víctimas","phonetic":"[seen BEEK-tee-mahs]","english":"no casualties","example_es":"El accidente no tuvo víctimas.","example_en":"The accident had no casualties."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Reportero","spanish":"Buenas noches. Según fuentes oficiales, el acuerdo está firmado.","english":"Good evening. According to official sources, the agreement is signed."},
      {"speaker":"Reportero","spanish":"En otra noticia, hubo un accidente en la autopista, sin víctimas.","english":"In other news, there was an accident on the highway, no casualties."},
      {"speaker":"Reportero","spanish":"Mañana ampliaremos la información.","english":"Tomorrow we''ll expand on the story."}
    ]'::jsonb,
    grammar_note = '"Hubo" is the preterite of "haber" — used for one-time past events. Don''t confuse with "había" (imperfect) for ongoing background.'
  where id = v_l5;

  update public.lessons set
    intro = 'Read a short news article and extract the key facts.',
    vocab_items = '[
      {"word":"la cumbre","phonetic":"[KOOM-breh]","english":"summit","example_es":"La cumbre se celebró en París.","example_en":"The summit was held in Paris."},
      {"word":"el acuerdo","phonetic":"[ah-KWEHR-doh]","english":"agreement","example_es":"Firmaron un acuerdo histórico.","example_en":"They signed a historic agreement."},
      {"word":"reducir","phonetic":"[rreh-doo-SEER]","english":"to reduce","example_es":"Los países decidieron reducir las emisiones.","example_en":"The countries decided to reduce emissions."},
      {"word":"hasta el año 2030","phonetic":"[AHS-tah]","english":"by 2030","example_es":"Hasta el año 2030 cumplirán la meta.","example_en":"By 2030 they''ll meet the goal."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"La cumbre climática se celebró ayer en París con la participación de 50 países.","english":"The climate summit was held yesterday in Paris with 50 countries participating."},
      {"speaker":"Texto","spanish":"Los líderes firmaron un acuerdo para reducir las emisiones de CO2 un 40% hasta 2030.","english":"Leaders signed an agreement to cut CO2 emissions 40% by 2030."},
      {"speaker":"Texto","spanish":"Sin embargo, varios expertos consideran la meta poco realista.","english":"However, several experts consider the goal unrealistic."}
    ]'::jsonb,
    grammar_note = 'Headlines and serious news lean heavily on the preterite for completed events: se celebró, firmaron, decidieron. Notice the dropped pronouns and tight word order.'
  where id = v_l6;

  update public.lessons set
    intro = 'Write a short news-style paragraph using the structures from this section.',
    vocab_items = '[
      {"word":"informar","phonetic":"[een-fohr-MAR]","english":"to inform / report","example_es":"Informamos sobre los últimos cambios.","example_en":"We report on the latest changes."},
      {"word":"según el informe","phonetic":"[seh-GOON ehl een-FOHR-meh]","english":"according to the report","example_es":"Según el informe, hay avances.","example_en":"According to the report, there is progress."},
      {"word":"en cifras","phonetic":"[ehn SEE-frahs]","english":"in numbers","example_es":"En cifras, son 200 millones de euros.","example_en":"In numbers, that''s 200 million euros."},
      {"word":"a corto plazo","phonetic":"[ah KOHR-toh PLAH-soh]","english":"in the short term","example_es":"A corto plazo no habrá cambios.","example_en":"In the short term there won''t be changes."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Modelo","spanish":"Madrid, 5 de junio. Según el último informe del Ministerio de Salud, los casos descendieron un 15%.","english":"Madrid, June 5. According to the latest Ministry of Health report, cases dropped 15%."},
      {"speaker":"Modelo","spanish":"En cifras, son 12.000 contagios menos que el mes pasado.","english":"In numbers, that''s 12,000 fewer infections than last month."},
      {"speaker":"Modelo","spanish":"A corto plazo, las autoridades mantendrán las medidas actuales.","english":"In the short term, authorities will keep current measures in place."}
    ]'::jsonb,
    grammar_note = 'News writing uses the future indicative for confirmed plans: mantendrán, anunciarán, se reunirán. Sound is more formal than ir a + infinitive.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "headline"?','el titular',array['la noticia','el periodista','la fuente'],'headline',1),
  (v_l1,'fill_blank','Complete: "Necesitamos una ____ confiable." (source)','fuente',array['titular','periodista','noticia'],'source',2),
  (v_l1,'multiple_choice','What does "verificar" mean?','to verify',array['to deny','to publish','to read'],'to verify',3),
  (v_l1,'listening','What did you hear?','El titular era impactante',array['La noticia salió ayer','El periodista entrevistó','Necesitamos una fuente'],'The headline was striking',4),
  (v_l1,'speaking','Say this aloud: "He leído el titular."','He leído el titular',array[]::text[],'I''ve read the headline.',5),
  (v_l2,'multiple_choice','What does "afirmar" mean?','to claim',array['to deny','to declare','to ask'],'to claim',1),
  (v_l2,'fill_blank','Complete: "____ el informe, hay avances." (according to)','Según',array['Como','Aunque','Hasta'],'according to',2),
  (v_l2,'multiple_choice','What does "negar" mean?','to deny',array['to confirm','to share','to explain'],'to deny',3),
  (v_l2,'listening','What did you hear?','El sospechoso negó todo',array['El presidente afirmó','La empresa declaró','Según el informe'],'The suspect denied everything',4),
  (v_l2,'speaking','Say this aloud: "Dijo que vendría."','Dijo que vendría',array[]::text[],'He said he would come.',5),
  (v_l3,'multiple_choice','How do you say "apparently"?','al parecer',array['sin duda','según','polémico'],'apparently',1),
  (v_l3,'fill_blank','Complete: "Es un tema muy ____" (controversial)','polémico',array['confiable','impactante','aprobado'],'controversial',2),
  (v_l3,'multiple_choice','What does "estar al día" mean?','to be up to date',array['to be late','to be tired','to be in charge'],'to be up to date',3),
  (v_l3,'listening','What did you hear?','Sin duda va a haber protestas',array['Al parecer hubo un acuerdo','Es un tema polémico','Intento estar al día'],'No doubt there will be protests',4),
  (v_l3,'speaking','Say this aloud: "Es un tema muy polémico."','Es un tema muy polémico',array[]::text[],'It''s a very controversial topic.',5),
  (v_l4,'multiple_choice','What is "press conference"?','la rueda de prensa',array['la encuesta','el comunicado','el portavoz'],'press conference',1),
  (v_l4,'fill_blank','Complete: "Una ____ muestra apoyo." (poll)','encuesta',array['rueda','fuente','noticia'],'poll',2),
  (v_l4,'multiple_choice','What does "portavoz" mean?','spokesperson',array['journalist','source','headline'],'spokesperson',3),
  (v_l4,'listening','What did you hear?','Mañana habrá una rueda de prensa',array['El comunicado oficial salió','Una nueva encuesta muestra apoyo','El portavoz aclaró'],'Tomorrow there will be a press conference',4),
  (v_l4,'speaking','Say this aloud: "Habrá rueda de prensa mañana."','Habrá rueda de prensa mañana',array[]::text[],'There will be a press conference tomorrow.',5),
  (v_l5,'multiple_choice','How to start a news segment?','Buenas noches y bienvenidos al noticiero',array['Adiós y gracias','Hola amigos','Voy al trabajo'],'Good evening, welcome to the news',1),
  (v_l5,'fill_blank','Complete: "Anoche ____ un atentado." (there was)','hubo',array['había','habrá','hay'],'there was (preterite)',2),
  (v_l5,'multiple_choice','What does "sin víctimas" mean?','no casualties',array['with witnesses','with warnings','no police'],'no casualties',3),
  (v_l5,'listening','What did you hear?','Según fuentes oficiales, el acuerdo está firmado',array['Buenas noches y bienvenidos','Hubo un accidente sin víctimas','Mañana ampliaremos la información'],'According to official sources, the agreement is signed',4),
  (v_l5,'speaking','Say this aloud: "Anoche hubo un accidente sin víctimas."','Anoche hubo un accidente sin víctimas',array[]::text[],'Last night there was an accident, no casualties.',5),
  (v_l6,'multiple_choice','What is "summit"?','la cumbre',array['el acuerdo','la encuesta','el informe'],'summit',1),
  (v_l6,'fill_blank','Complete: "Los países decidieron ____ las emisiones." (to reduce)','reducir',array['firmar','informar','aclarar'],'to reduce',2),
  (v_l6,'multiple_choice','When will emissions be cut?','by 2030',array['by 2025','by 2050','by 2020'],'hasta 2030',3),
  (v_l6,'listening','What did you hear?','Los líderes firmaron un acuerdo histórico',array['La cumbre climática se celebró ayer','Sin embargo, los expertos consideran','En otra noticia'],'Leaders signed a historic agreement',4),
  (v_l6,'speaking','Say this aloud: "Firmaron un acuerdo histórico."','Firmaron un acuerdo histórico',array[]::text[],'They signed a historic agreement.',5),
  (v_l7,'multiple_choice','How do you say "according to the report"?','según el informe',array['sin embargo','a corto plazo','en cifras'],'according to the report',1),
  (v_l7,'fill_blank','Complete: "A corto ____, no habrá cambios." (term)','plazo',array['mes','día','año'],'short term',2),
  (v_l7,'multiple_choice','What does "en cifras" mean?','in numbers',array['in writing','in summary','in advance'],'in numbers',3),
  (v_l7,'listening','What did you hear?','A corto plazo, las autoridades mantendrán las medidas',array['Madrid, 5 de junio','En cifras son 12.000 contagios menos','Las autoridades anunciarán cambios'],'In the short term, authorities will keep the measures',4),
  (v_l7,'speaking','Say this aloud: "Los casos descendieron un 15%."','Los casos descendieron un 15%',array[]::text[],'Cases dropped 15%.',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','La noticia salió ayer',array['El titular era impactante','El periodista entrevistó al ministro','Necesitamos una fuente confiable'],'The news came out yesterday',6),
  (v_l1,'listening','What did you hear?','El periodista entrevistó al ministro',array['La noticia salió ayer','El titular era impactante','Necesitamos una fuente'],'The journalist interviewed the minister',7),
  (v_l1,'speaking','Say this aloud: "¿Has leído el titular?"','¿Has leído el titular?',array[]::text[],'Have you read the headline?',8),
  (v_l1,'speaking','Say this aloud: "Necesitamos una fuente confiable."','Necesitamos una fuente confiable',array[]::text[],'We need a reliable source.',9),
  (v_l2,'listening','What did you hear?','El presidente afirmó que ganaría',array['El sospechoso negó todo','La empresa declaró bancarrota','Según el informe'],'The president claimed he would win',6),
  (v_l2,'listening','What did you hear?','La empresa declaró bancarrota',array['Negó todo','Afirmó que ganaría','Según el informe'],'The company declared bankruptcy',7),
  (v_l2,'speaking','Say this aloud: "Según el informe."','Según el informe',array[]::text[],'According to the report.',8),
  (v_l2,'speaking','Say this aloud: "El sospechoso negó todo."','El sospechoso negó todo',array[]::text[],'The suspect denied everything.',9),
  (v_l3,'listening','What did you hear?','Al parecer hubo un acuerdo',array['Es un tema polémico','Sin duda va a haber protestas','Intento estar al día'],'Apparently there was an agreement',6),
  (v_l3,'listening','What did you hear?','Intento estar al día con las noticias',array['Al parecer hubo un acuerdo','Es un tema polémico','Sin duda'],'I try to keep up with the news',7),
  (v_l3,'speaking','Say this aloud: "Al parecer hubo un acuerdo."','Al parecer hubo un acuerdo',array[]::text[],'Apparently there was an agreement.',8),
  (v_l3,'speaking','Say this aloud: "Intento estar al día."','Intento estar al día',array[]::text[],'I try to keep up to date.',9),
  (v_l6,'listening','What did you hear?','La cumbre climática se celebró en París',array['Los líderes firmaron un acuerdo','Varios expertos consideran la meta','Reducir las emisiones'],'The climate summit was held in Paris',6),
  (v_l6,'listening','What did you hear?','Varios expertos consideran la meta poco realista',array['La cumbre se celebró','Reducir las emisiones','Firmaron un acuerdo'],'Several experts consider the goal unrealistic',7),
  (v_l6,'speaking','Say this aloud: "La cumbre climática se celebró ayer."','La cumbre climática se celebró ayer',array[]::text[],'The climate summit was held yesterday.',8),
  (v_l6,'speaking','Say this aloud: "Hay que reducir las emisiones."','Hay que reducir las emisiones',array[]::text[],'We must reduce emissions.',9),
  (v_l7,'listening','What did you hear?','Según el último informe, los casos descendieron un 15%',array['En cifras son 12.000 menos','Las autoridades mantendrán','A corto plazo no habrá cambios'],'According to the latest report, cases dropped 15%',6),
  (v_l7,'listening','What did you hear?','Las autoridades mantendrán las medidas actuales',array['Según el informe','En cifras','A corto plazo'],'Authorities will keep the current measures',7),
  (v_l7,'speaking','Say this aloud: "A corto plazo no habrá cambios."','A corto plazo no habrá cambios',array[]::text[],'In the short term there won''t be changes.',8),
  (v_l7,'speaking','Say this aloud: "Informamos sobre los cambios."','Informamos sobre los cambios',array[]::text[],'We report on the changes.',9);

  update public.lessons set
    type = 'conversation',
    title = 'News & Media — Conversation Practice',
    description = 'Two friends discuss a controversial news story over coffee.',
    intro = 'Ana and Luis are catching up over coffee. Listen as they debate a news story they both saw this morning.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Ana","spanish":"¿Has visto la noticia del nuevo impuesto?","english":"Have you seen the news about the new tax?"},
      {"speaker":"Luis","spanish":"Sí, salió ayer. Pero la fuente no es muy confiable.","english":"Yes, it came out yesterday. But the source isn''t very reliable."},
      {"speaker":"Ana","spanish":"Según el comunicado oficial, el gobierno afirma que ayudará.","english":"According to the official press release, the government claims it will help."},
      {"speaker":"Luis","spanish":"Al parecer, una encuesta muestra que el 60% lo apoya.","english":"Apparently a poll shows 60% support it."},
      {"speaker":"Ana","spanish":"Pues a mí me parece muy polémico. Sin duda habrá protestas.","english":"Well it seems very controversial to me. No doubt there will be protests."},
      {"speaker":"Luis","spanish":"Mañana hay una rueda de prensa. Estaremos al día.","english":"There''s a press conference tomorrow. We''ll be up to date."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','What news are they discussing?','A new tax',array['A summit','A scandal','An accident'],'el nuevo impuesto',1),
  (v_l8,'multiple_choice','What''s Luis''s issue with the news?','The source isn''t reliable',array['It''s too old','He hasn''t read it','It''s wrong'],'la fuente no es muy confiable',2),
  (v_l8,'multiple_choice','What % supports the measure per the poll?','60%',array['40%','50%','70%'],'el 60% lo apoya',3),
  (v_l8,'multiple_choice','True or false: Ana thinks there''ll be protests.','True',array['False'],'Sin duda habrá protestas',4),
  (v_l8,'fill_blank','Complete: "Mañana hay una ____ de prensa." (conference)','rueda',array['fuente','noticia','encuesta'],'press conference',5),
  (v_l8,'multiple_choice','When is the press conference?','Tomorrow',array['Today','Yesterday','Next week'],'Mañana',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: News & Media', 'Review test for the whole News & Media section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "headline"?','el titular',array['la noticia','el periodista','la fuente'],'headline',1),
  (v_lesson_id,'multiple_choice','Which means "to deny"?','negar',array['afirmar','declarar','informar'],'to deny',2),
  (v_lesson_id,'multiple_choice','True/false: "Hubo" is preterite of haber.','True',array['False'],'hubo = preterite haber',3),
  (v_lesson_id,'multiple_choice','What does "polémico" mean?','controversial',array['boring','important','clear'],'controversial',4),
  (v_lesson_id,'fill_blank','Complete: "____ fuentes oficiales, el plan está aprobado." (according to)','Según',array['Como','Aunque','Hasta'],'according to',5),
  (v_lesson_id,'fill_blank','Complete: "Una ____ muestra apoyo." (poll)','encuesta',array['rueda','fuente','noticia'],'poll',6),
  (v_lesson_id,'listening','What did you hear?','La noticia salió ayer',array['El titular era impactante','Mañana habrá rueda de prensa','El sospechoso negó todo'],'The news came out yesterday',7),
  (v_lesson_id,'listening','What did you hear?','Sin duda habrá protestas',array['Al parecer hubo un acuerdo','Hubo un accidente sin víctimas','La cumbre se celebró'],'No doubt there will be protests',8),
  (v_lesson_id,'speaking','Say this aloud: "Según el informe, los casos descendieron."','Según el informe, los casos descendieron',array[]::text[],'According to the report, cases dropped.',9),
  (v_lesson_id,'speaking','Say this aloud: "Habrá rueda de prensa mañana."','Habrá rueda de prensa mañana',array[]::text[],'There''ll be a press conference tomorrow.',10);

  -- ===========================================================
  -- B1.3 ENVIRONMENT
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B1' and title = 'Environment';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set intro = 'Core environmental vocabulary.',
    vocab_items = '[{"word":"el medio ambiente","phonetic":"[MEH-dyoh ahm-BYEHN-teh]","english":"the environment","example_es":"Hay que proteger el medio ambiente.","example_en":"We have to protect the environment."},{"word":"el cambio climático","phonetic":"[KAHM-byoh klee-MAH-tee-koh]","english":"climate change","example_es":"El cambio climático es real.","example_en":"Climate change is real."},{"word":"reciclar","phonetic":"[rreh-see-KLAR]","english":"to recycle","example_es":"En mi casa reciclamos todo.","example_en":"At home we recycle everything."},{"word":"la contaminación","phonetic":"[kohn-tah-mee-nah-SYOHN]","english":"pollution","example_es":"La contaminación del aire es grave.","example_en":"Air pollution is serious."}]'::jsonb,
    dialogue = '[{"speaker":"Lola","spanish":"¿Reciclas en casa?","english":"Do you recycle at home?"},{"speaker":"Marco","spanish":"Sí, intento reducir la contaminación.","english":"Yes, I try to reduce pollution."},{"speaker":"Lola","spanish":"El cambio climático nos afecta a todos.","english":"Climate change affects us all."}]'::jsonb,
    grammar_note = 'Impersonal "se": "se recicla", "se contamina", "se protege". Used to talk about general practices without naming a subject.'
  where id = v_l1;
  update public.lessons set intro = 'Subjunctive after expressions of doubt and necessity.',
    vocab_items = '[{"word":"es necesario que","phonetic":"[NEH-seh-SAH-ryoh keh]","english":"it''s necessary that","example_es":"Es necesario que reciclemos.","example_en":"It''s necessary that we recycle."},{"word":"dudar que","phonetic":"[doo-DAR keh]","english":"to doubt that","example_es":"Dudo que llegue a tiempo.","example_en":"I doubt it arrives in time."},{"word":"ojalá","phonetic":"[oh-hah-LAH]","english":"hopefully","example_es":"Ojalá llueva pronto.","example_en":"Hopefully it rains soon."},{"word":"a menos que","phonetic":"[ah MEH-nohs keh]","english":"unless","example_es":"No mejora a menos que actuemos.","example_en":"It won''t improve unless we act."}]'::jsonb,
    dialogue = '[{"speaker":"Eva","spanish":"Es necesario que reduzcamos el plástico.","english":"It''s necessary that we reduce plastic."},{"speaker":"Diego","spanish":"Dudo que sea fácil.","english":"I doubt it''s easy."},{"speaker":"Eva","spanish":"Ojalá la gente se conciencie.","english":"Hopefully people become aware."}]'::jsonb,
    grammar_note = 'Present subjunctive forms: hable, coma, viva. Triggered by expressions of doubt (dudo que), wish (ojalá), necessity (es necesario que).'
  where id = v_l2;
  update public.lessons set intro = 'Everyday phrases for green habits.',
    vocab_items = '[{"word":"separar la basura","phonetic":"[seh-pah-RAR lah bah-SOO-rah]","english":"to sort the rubbish","example_es":"Separamos la basura por colores.","example_en":"We sort the rubbish by colour."},{"word":"ahorrar energía","phonetic":"[ah-oh-RRAR eh-nehr-HEE-ah]","english":"to save energy","example_es":"Apagamos luces para ahorrar energía.","example_en":"We turn off lights to save energy."},{"word":"reutilizar","phonetic":"[rreh-oo-tee-lee-SAR]","english":"to reuse","example_es":"Reutilizo las bolsas.","example_en":"I reuse bags."},{"word":"el cubo de reciclaje","phonetic":"[KOO-boh deh rreh-see-KLAH-heh]","english":"recycling bin","example_es":"El cubo amarillo es para plástico.","example_en":"The yellow bin is for plastic."}]'::jsonb,
    dialogue = '[{"speaker":"Hijo","spanish":"¿Dónde tiro la botella?","english":"Where do I throw the bottle?"},{"speaker":"Madre","spanish":"Al cubo amarillo, hay que separar la basura.","english":"In the yellow bin, we have to sort the rubbish."},{"speaker":"Hijo","spanish":"Vale, así ahorramos energía y reciclamos.","english":"OK, this way we save energy and recycle."}]'::jsonb,
    grammar_note = '"Hay que + infinitive" = "one has to" — impersonal obligation. Different from "tengo que" which is personal.'
  where id = v_l3;
  update public.lessons set intro = 'Listen for environment talk.',
    vocab_items = '[{"word":"la deforestación","phonetic":"[deh-foh-rehs-tah-SYOHN]","english":"deforestation","example_es":"La deforestación destruye hábitats.","example_en":"Deforestation destroys habitats."},{"word":"el calentamiento global","phonetic":"[kah-lehn-tah-MYEHN-toh]","english":"global warming","example_es":"El calentamiento global aumenta.","example_en":"Global warming is rising."},{"word":"la energía renovable","phonetic":"[eh-nehr-HEE-ah rreh-noh-BAH-bleh]","english":"renewable energy","example_es":"Apuestan por energía renovable.","example_en":"They bet on renewable energy."},{"word":"el desperdicio","phonetic":"[dehs-pehr-DEE-syoh]","english":"waste","example_es":"Reducir el desperdicio es clave.","example_en":"Reducing waste is key."}]'::jsonb,
    dialogue = '[{"speaker":"Locutor","spanish":"La deforestación en el Amazonas continúa.","english":"Amazon deforestation continues."},{"speaker":"Locutor","spanish":"Los expertos piden más energía renovable.","english":"Experts call for more renewable energy."},{"speaker":"Locutor","spanish":"Reducir el desperdicio es esencial.","english":"Reducing waste is essential."}]'::jsonb,
    grammar_note = 'News-style Spanish uses noun-heavy structures. Track the nouns to follow the topic.'
  where id = v_l4;
  update public.lessons set intro = 'Speak about your green habits.',
    vocab_items = '[{"word":"Cuido el medio ambiente","phonetic":"[KWEE-doh ehl MEH-dyoh]","english":"I look after the environment","example_es":"Cuido el medio ambiente desde joven.","example_en":"I''ve looked after the environment since I was young."},{"word":"Apago las luces","phonetic":"[ah-PAH-goh lahs LOO-sehs]","english":"I turn off lights","example_es":"Apago las luces al salir.","example_en":"I turn off lights when I leave."},{"word":"Voy en bici","phonetic":"[BOY ehn BEE-see]","english":"I go by bike","example_es":"Voy en bici al trabajo.","example_en":"I go to work by bike."},{"word":"Llevo bolsa de tela","phonetic":"[YEH-boh BOHL-sah deh TEH-lah]","english":"I carry a cloth bag","example_es":"Siempre llevo bolsa de tela.","example_en":"I always carry a cloth bag."}]'::jsonb,
    dialogue = '[{"speaker":"Tú","spanish":"Cuido el medio ambiente en lo posible.","english":"I look after the environment when I can."},{"speaker":"Amiga","spanish":"¿Cómo?","english":"How?"},{"speaker":"Tú","spanish":"Voy en bici, apago luces y reciclo todo.","english":"I bike, turn off lights and recycle everything."}]'::jsonb,
    grammar_note = '"En lo posible" = "as much as possible". Useful hedge that softens claims about your habits.'
  where id = v_l5;
  update public.lessons set intro = 'Read about an environmental campaign.',
    vocab_items = '[{"word":"la campaña","phonetic":"[kahm-PAH-nyah]","english":"the campaign","example_es":"La campaña dura un mes.","example_en":"The campaign lasts a month."},{"word":"sensibilizar","phonetic":"[sehn-see-bee-lee-SAR]","english":"to raise awareness","example_es":"Sensibilizan a los jóvenes.","example_en":"They raise youth awareness."},{"word":"la basura plástica","phonetic":"[bah-SOO-rah PLAHS-tee-kah]","english":"plastic waste","example_es":"La basura plástica contamina el mar.","example_en":"Plastic waste pollutes the sea."},{"word":"voluntario","phonetic":"[boh-loon-TAH-ryoh]","english":"volunteer","example_es":"Hay 200 voluntarios.","example_en":"There are 200 volunteers."}]'::jsonb,
    dialogue = '[{"speaker":"Texto","spanish":"Una campaña ciudadana busca reducir la basura plástica en las playas.","english":"A citizen campaign aims to reduce plastic waste on beaches."},{"speaker":"Texto","spanish":"Más de doscientos voluntarios recogieron tres toneladas en un día.","english":"Over 200 volunteers collected three tons in a day."},{"speaker":"Texto","spanish":"Los organizadores quieren sensibilizar a los jóvenes.","english":"Organizers want to raise awareness among young people."}]'::jsonb,
    grammar_note = 'Articles often combine present (busca, quieren) with preterite (recogieron) — present for the campaign''s purpose, preterite for the specific event reported.'
  where id = v_l6;
  update public.lessons set intro = 'Write a short opinion on environmental action.',
    vocab_items = '[{"word":"opino que","phonetic":"[oh-PEE-noh keh]","english":"I think that","example_es":"Opino que hay que actuar ya.","example_en":"I think we must act now."},{"word":"sostenible","phonetic":"[sohs-teh-NEE-bleh]","english":"sustainable","example_es":"Buscamos un futuro sostenible.","example_en":"We want a sustainable future."},{"word":"colaborar","phonetic":"[koh-lah-boh-RAR]","english":"to collaborate","example_es":"Todos debemos colaborar.","example_en":"We all have to collaborate."},{"word":"si no actuamos","phonetic":"[see noh ahk-TWAH-mohs]","english":"if we don''t act","example_es":"Si no actuamos, será tarde.","example_en":"If we don''t act, it''ll be too late."}]'::jsonb,
    dialogue = '[{"speaker":"Modelo","spanish":"Opino que el cambio climático es la mayor crisis de nuestro tiempo.","english":"I think climate change is the greatest crisis of our time."},{"speaker":"Modelo","spanish":"Si no actuamos pronto, las consecuencias serán graves.","english":"If we don''t act soon, the consequences will be serious."},{"speaker":"Modelo","spanish":"Todos podemos colaborar reciclando y consumiendo de forma sostenible.","english":"We can all collaborate by recycling and consuming sustainably."}]'::jsonb,
    grammar_note = '"Si + present, future" expresses likely conditions: "Si no actuamos, será tarde."'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "the environment"?','el medio ambiente',array['el cambio climático','la contaminación','el reciclaje'],'the environment',1),
  (v_l1,'fill_blank','Complete: "En mi casa ____ todo." (we recycle)','reciclamos',array['contaminamos','tiramos','reducimos'],'we recycle',2),
  (v_l1,'multiple_choice','What does "la contaminación" mean?','pollution',array['climate','rubbish','energy'],'pollution',3),
  (v_l1,'listening','What did you hear?','El cambio climático es real',array['Hay que proteger el medio ambiente','En mi casa reciclamos','La contaminación del aire'],'Climate change is real',4),
  (v_l1,'speaking','Say this aloud: "Hay que proteger el medio ambiente."','Hay que proteger el medio ambiente',array[]::text[],'We must protect the environment.',5),
  (v_l2,'multiple_choice','How do you say "hopefully"?','ojalá',array['dudo','quizás','tal vez'],'hopefully',1),
  (v_l2,'fill_blank','Complete: "Es necesario que ____" (we recycle - subj)','reciclemos',array['reciclamos','reciclar','reciclado'],'we recycle (subj)',2),
  (v_l2,'multiple_choice','What does "a menos que" mean?','unless',array['because','although','since'],'unless',3),
  (v_l2,'listening','What did you hear?','Ojalá llueva pronto',array['Es necesario que reciclemos','Dudo que sea fácil','No mejora a menos que'],'Hopefully it rains soon',4),
  (v_l2,'speaking','Say this aloud: "Es necesario que reduzcamos el plástico."','Es necesario que reduzcamos el plástico',array[]::text[],'It''s necessary we reduce plastic.',5),
  (v_l3,'multiple_choice','What is "to save energy"?','ahorrar energía',array['reciclar','separar la basura','reutilizar'],'to save energy',1),
  (v_l3,'fill_blank','Complete: "____ que separar la basura." (one has)','Hay',array['Tener','Estar','Ser'],'hay que',2),
  (v_l3,'multiple_choice','Yellow bin = ?','plastic',array['paper','glass','metal'],'plástico',3),
  (v_l3,'listening','What did you hear?','Al cubo amarillo, hay que separar la basura',array['Reutilizo las bolsas','Apagamos luces para ahorrar','El cubo amarillo es para plástico'],'In the yellow bin, you have to sort',4),
  (v_l3,'speaking','Say this aloud: "Hay que separar la basura."','Hay que separar la basura',array[]::text[],'You have to sort the rubbish.',5),
  (v_l4,'multiple_choice','What is "deforestation"?','la deforestación',array['el desperdicio','el calentamiento global','la energía renovable'],'deforestation',1),
  (v_l4,'fill_blank','Complete: "Apuestan por energía ____" (renewable)','renovable',array['plástica','global','sostenible'],'renewable',2),
  (v_l4,'multiple_choice','What does "calentamiento global" mean?','global warming',array['climate change','deforestation','waste'],'global warming',3),
  (v_l4,'listening','What did you hear?','La deforestación en el Amazonas continúa',array['Los expertos piden energía renovable','Reducir el desperdicio es esencial','El cambio climático nos afecta'],'Amazon deforestation continues',4),
  (v_l4,'speaking','Say this aloud: "El calentamiento global aumenta."','El calentamiento global aumenta',array[]::text[],'Global warming is rising.',5),
  (v_l5,'multiple_choice','How do you say "I bike to work"?','Voy en bici al trabajo',array['Voy a pie','Voy en coche','Voy en bus'],'I bike to work',1),
  (v_l5,'fill_blank','Complete: "Siempre llevo bolsa de ____" (cloth)','tela',array['plástico','papel','vidrio'],'cloth',2),
  (v_l5,'multiple_choice','What does "en lo posible" mean?','as much as possible',array['as soon as possible','as little as possible','for the time being'],'as much as possible',3),
  (v_l5,'listening','What did you hear?','Apago las luces al salir',array['Voy en bici al trabajo','Siempre llevo bolsa de tela','Cuido el medio ambiente'],'I turn off lights when I leave',4),
  (v_l5,'speaking','Say this aloud: "Voy en bici al trabajo."','Voy en bici al trabajo',array[]::text[],'I bike to work.',5),
  (v_l6,'multiple_choice','What is "campaign"?','la campaña',array['la voluntaria','la basura','la energía'],'campaign',1),
  (v_l6,'fill_blank','Complete: "Hay 200 ____" (volunteers)','voluntarios',array['campañas','toneladas','basuras'],'volunteers',2),
  (v_l6,'multiple_choice','What does "sensibilizar" mean?','to raise awareness',array['to recycle','to clean','to ban'],'to raise awareness',3),
  (v_l6,'listening','What did you hear?','Más de doscientos voluntarios recogieron tres toneladas',array['La campaña dura un mes','Los organizadores quieren sensibilizar','La basura plástica contamina el mar'],'More than 200 volunteers collected three tons',4),
  (v_l6,'speaking','Say this aloud: "Quieren sensibilizar a los jóvenes."','Quieren sensibilizar a los jóvenes',array[]::text[],'They want to raise youth awareness.',5),
  (v_l7,'multiple_choice','How do you say "I think that"?','opino que',array['si no actuamos','colaborar','sostenible'],'I think that',1),
  (v_l7,'fill_blank','Complete: "Buscamos un futuro ____" (sustainable)','sostenible',array['sostenido','sostiene','sostener'],'sustainable',2),
  (v_l7,'multiple_choice','What does "si no actuamos" mean?','if we don''t act',array['when we act','because we act','before we act'],'if we don''t act',3),
  (v_l7,'listening','What did you hear?','Si no actuamos pronto, las consecuencias serán graves',array['Opino que es la mayor crisis','Todos podemos colaborar','Reciclando y consumiendo'],'If we don''t act soon, the consequences will be serious',4),
  (v_l7,'speaking','Say this aloud: "Todos debemos colaborar."','Todos debemos colaborar',array[]::text[],'We all have to collaborate.',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','La contaminación del aire es grave',array['El cambio climático es real','Hay que proteger','Reciclamos todo'],'Air pollution is serious',6),
  (v_l1,'listening','What did you hear?','Hay que proteger el medio ambiente',array['Reciclamos todo','La contaminación es grave','El cambio climático'],'We must protect the environment',7),
  (v_l1,'speaking','Say this aloud: "Reciclamos todo en casa."','Reciclamos todo en casa',array[]::text[],'We recycle everything at home.',8),
  (v_l1,'speaking','Say this aloud: "La contaminación del aire es grave."','La contaminación del aire es grave',array[]::text[],'Air pollution is serious.',9),
  (v_l2,'listening','What did you hear?','Dudo que sea fácil',array['Es necesario que reciclemos','Ojalá llueva pronto','No mejora a menos que'],'I doubt it''s easy',6),
  (v_l2,'listening','What did you hear?','No mejora a menos que actuemos',array['Es necesario','Dudo que','Ojalá'],'It won''t improve unless we act',7),
  (v_l2,'speaking','Say this aloud: "Dudo que sea fácil."','Dudo que sea fácil',array[]::text[],'I doubt it''s easy.',8),
  (v_l2,'speaking','Say this aloud: "Ojalá la gente se conciencie."','Ojalá la gente se conciencie',array[]::text[],'Hopefully people become aware.',9),
  (v_l3,'listening','What did you hear?','Reutilizo las bolsas',array['Hay que separar','El cubo amarillo','Apagamos luces'],'I reuse bags',6),
  (v_l3,'listening','What did you hear?','Apagamos luces para ahorrar energía',array['Reutilizo bolsas','El cubo amarillo','Hay que separar'],'We turn off lights to save energy',7),
  (v_l3,'speaking','Say this aloud: "Reutilizo las bolsas."','Reutilizo las bolsas',array[]::text[],'I reuse bags.',8),
  (v_l3,'speaking','Say this aloud: "Ahorramos energía y reciclamos."','Ahorramos energía y reciclamos',array[]::text[],'We save energy and recycle.',9),
  (v_l6,'listening','What did you hear?','Una campaña ciudadana busca reducir la basura plástica',array['Más de doscientos voluntarios','Los organizadores quieren sensibilizar','Tres toneladas en un día'],'A citizen campaign aims to reduce plastic waste',6),
  (v_l6,'listening','What did you hear?','Tres toneladas en un día',array['Doscientos voluntarios','Una campaña ciudadana','Quieren sensibilizar a los jóvenes'],'Three tons in one day',7),
  (v_l6,'speaking','Say this aloud: "Hay doscientos voluntarios."','Hay doscientos voluntarios',array[]::text[],'There are 200 volunteers.',8),
  (v_l6,'speaking','Say this aloud: "La basura plástica contamina el mar."','La basura plástica contamina el mar',array[]::text[],'Plastic waste pollutes the sea.',9),
  (v_l7,'listening','What did you hear?','Opino que el cambio climático es la mayor crisis',array['Reciclando y consumiendo','Las consecuencias serán graves','Todos podemos colaborar'],'I think climate change is the greatest crisis',6),
  (v_l7,'listening','What did you hear?','Consumiendo de forma sostenible',array['Si no actuamos','Opino que','Todos podemos colaborar'],'Consuming sustainably',7),
  (v_l7,'speaking','Say this aloud: "Opino que hay que actuar ya."','Opino que hay que actuar ya',array[]::text[],'I think we must act now.',8),
  (v_l7,'speaking','Say this aloud: "Buscamos un futuro sostenible."','Buscamos un futuro sostenible',array[]::text[],'We want a sustainable future.',9);

  update public.lessons set type='conversation', title='Environment — Conversation Practice',
    description='Two neighbours debate what individual action can do for climate change.',
    intro='Lola and Marco talk about whether small actions matter.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Lola","spanish":"¿De verdad crees que reciclar cambia algo?","english":"Do you really think recycling changes anything?"},{"speaker":"Marco","spanish":"Es necesario que cada uno haga su parte.","english":"It''s necessary that each person does their part."},{"speaker":"Lola","spanish":"Dudo que sea suficiente sin las empresas grandes.","english":"I doubt it''s enough without big companies."},{"speaker":"Marco","spanish":"Pero si no actuamos nosotros, ellas tampoco lo harán.","english":"But if we don''t act, they won''t either."},{"speaker":"Lola","spanish":"Tienes razón. Voy a empezar a separar la basura.","english":"You''re right. I''ll start sorting the rubbish."},{"speaker":"Marco","spanish":"Ojalá más gente piense así.","english":"Hopefully more people think like this."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','What is Lola sceptical about?','That recycling alone changes things',array['Big companies','Marco''s opinion','Sorting rubbish'],'¿De verdad crees que reciclar cambia algo?',1),
  (v_l8,'multiple_choice','What is Marco''s position?','Each person must do their part',array['Companies should act first','Government must lead','Nothing works'],'cada uno haga su parte',2),
  (v_l8,'multiple_choice','True or false: Lola decides to start sorting rubbish.','True',array['False'],'Voy a empezar a separar la basura',3),
  (v_l8,'fill_blank','Complete: "Es necesario que cada uno ____ su parte." (do - subj)','haga',array['hace','hizo','hará'],'do (subjunctive)',4),
  (v_l8,'multiple_choice','What does "ojalá más gente piense así" mean?','Hopefully more people think this way',array['Many people think this way','No one thinks this way','Some people will think'],'Hopefully more people think this way',5),
  (v_l8,'multiple_choice','Who convinces whom?','Marco convinces Lola',array['Lola convinces Marco','Neither convinces the other','They agree from the start'],'Marco convinces Lola',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Environment', 'Review test for the whole Environment section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "the environment"?','el medio ambiente',array['el cambio climático','la contaminación','la energía'],'environment',1),
  (v_lesson_id,'multiple_choice','Which is the subjunctive of "reciclar" (we)?','reciclemos',array['reciclamos','reciclar','reciclado'],'we recycle (subj)',2),
  (v_lesson_id,'multiple_choice','What does "hay que" express?','impersonal obligation',array['personal preference','past action','future plan'],'hay que = one has to',3),
  (v_lesson_id,'multiple_choice','True/false: "ojalá" triggers the subjunctive.','True',array['False'],'ojalá + subjunctive',4),
  (v_lesson_id,'fill_blank','Complete: "Es necesario ____ reciclemos." (that)','que',array['de','en','para'],'that',5),
  (v_lesson_id,'fill_blank','Complete: "Apuestan por energía ____" (renewable)','renovable',array['plástica','sostenible','global'],'renewable',6),
  (v_lesson_id,'listening','What did you hear?','El cambio climático es real',array['Hay doscientos voluntarios','Voy en bici al trabajo','La contaminación es grave'],'Climate change is real',7),
  (v_lesson_id,'listening','What did you hear?','Hay que separar la basura',array['Apagamos las luces','Reutilizo las bolsas','Cuido el medio ambiente'],'You have to sort the rubbish',8),
  (v_lesson_id,'speaking','Say this aloud: "Es necesario que reciclemos."','Es necesario que reciclemos',array[]::text[],'It''s necessary that we recycle.',9),
  (v_lesson_id,'speaking','Say this aloud: "Todos debemos colaborar."','Todos debemos colaborar',array[]::text[],'We all have to collaborate.',10);

  -- ===========================================================
  -- B1.4 RELATIONSHIPS
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B1' and title = 'Relationships';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set intro = 'Vocabulary to describe friendships and relationships.',
    vocab_items = '[{"word":"la amistad","phonetic":"[ah-mees-TAHD]","english":"friendship","example_es":"Nuestra amistad dura años.","example_en":"Our friendship has lasted years."},{"word":"la pareja","phonetic":"[pah-REH-hah]","english":"partner","example_es":"Mi pareja es muy paciente.","example_en":"My partner is very patient."},{"word":"confiar en","phonetic":"[kohn-fyahr]","english":"to trust","example_es":"Confío en él totalmente.","example_en":"I trust him completely."},{"word":"discutir","phonetic":"[dees-koo-TEER]","english":"to argue","example_es":"A veces discutimos pero nos perdonamos.","example_en":"Sometimes we argue but we forgive each other."}]'::jsonb,
    dialogue = '[{"speaker":"Ana","spanish":"¿Cómo va con tu pareja?","english":"How are things with your partner?"},{"speaker":"Luis","spanish":"Bien, aunque a veces discutimos.","english":"Good, although we sometimes argue."},{"speaker":"Ana","spanish":"Lo importante es confiar el uno en el otro.","english":"What matters is to trust each other."}]'::jsonb,
    grammar_note = 'Reciprocal verbs: nos perdonamos, nos queremos, se aman. Same structure as reflexives but the action is mutual.'
  where id = v_l1;
  update public.lessons set intro = 'Talking about feelings — verbs like gustar.',
    vocab_items = '[{"word":"caer bien","phonetic":"[kah-EHR byehn]","english":"to like someone","example_es":"Me cae bien tu amigo.","example_en":"I like your friend."},{"word":"echar de menos","phonetic":"[eh-CHAR deh MEH-nohs]","english":"to miss","example_es":"Echo de menos a mi familia.","example_en":"I miss my family."},{"word":"enfadarse con","phonetic":"[ehn-fah-DAR-seh]","english":"to get angry with","example_es":"Se enfada conmigo a veces.","example_en":"He gets angry with me sometimes."},{"word":"llevarse bien","phonetic":"[yeh-BAR-seh byehn]","english":"to get on well","example_es":"Me llevo bien con mis suegros.","example_en":"I get on well with my in-laws."}]'::jsonb,
    dialogue = '[{"speaker":"Eva","spanish":"¿Cómo te llevas con tu hermana?","english":"How do you get on with your sister?"},{"speaker":"Pablo","spanish":"Muy bien, pero a veces nos enfadamos.","english":"Very well, but sometimes we get angry."},{"speaker":"Eva","spanish":"Cuando estamos lejos, la echo mucho de menos.","english":"When we are far apart, I miss her a lot."}]'::jsonb,
    grammar_note = 'These verbs work like gustar — backwards: ME cae bien (literally "he falls well TO me"). The person who feels is the indirect object.'
  where id = v_l2;
  update public.lessons set intro = 'Phrases for tricky conversations.',
    vocab_items = '[{"word":"hablar las cosas","phonetic":"[ah-BLAR lahs KOH-sahs]","english":"to talk things out","example_es":"Hay que hablar las cosas con calma.","example_en":"We need to talk things out calmly."},{"word":"pedir perdón","phonetic":"[peh-DEER pehr-DOHN]","english":"to apologise","example_es":"Le pedí perdón ayer.","example_en":"I apologised yesterday."},{"word":"poner límites","phonetic":"[poh-NEHR LEE-mee-tehs]","english":"to set boundaries","example_es":"Es importante poner límites.","example_en":"It''s important to set boundaries."},{"word":"romper con","phonetic":"[rrohm-PEHR kohn]","english":"to break up with","example_es":"Rompió con su novia.","example_en":"He broke up with his girlfriend."}]'::jsonb,
    dialogue = '[{"speaker":"Marta","spanish":"Tenemos que hablar las cosas con calma.","english":"We need to talk things out calmly."},{"speaker":"Diego","spanish":"De acuerdo. Quiero pedirte perdón.","english":"Agreed. I want to apologise to you."},{"speaker":"Marta","spanish":"Yo también. Hay que poner límites más claros.","english":"Me too. We need to set clearer boundaries."}]'::jsonb,
    grammar_note = '"Le pedí perdón" — "le" is the indirect object pronoun. Use "le pido perdón A ALGUIEN" — the personal "a" follows when the recipient is mentioned.'
  where id = v_l3;
  update public.lessons set intro = 'Listen to a conversation about friendship.',
    vocab_items = '[{"word":"un buen amigo","phonetic":"[oon bwehn ah-MEE-goh]","english":"a good friend","example_es":"Es un buen amigo desde la escuela.","example_en":"He''s been a good friend since school."},{"word":"contar con","phonetic":"[kohn-TAR kohn]","english":"to count on","example_es":"Sé que puedo contar contigo.","example_en":"I know I can count on you."},{"word":"escuchar","phonetic":"[ehs-koo-CHAR]","english":"to listen","example_es":"Me escucha sin juzgar.","example_en":"He listens without judging."},{"word":"apoyar","phonetic":"[ah-poh-YAR]","english":"to support","example_es":"Siempre apoya mis decisiones.","example_en":"He always supports my decisions."}]'::jsonb,
    dialogue = '[{"speaker":"Eva","spanish":"Marcos es un buen amigo desde la escuela.","english":"Marcos has been a good friend since school."},{"speaker":"Eva","spanish":"Siempre me escucha sin juzgar.","english":"He always listens without judging."},{"speaker":"Eva","spanish":"Sé que puedo contar con él en cualquier momento.","english":"I know I can count on him at any moment."}]'::jsonb,
    grammar_note = 'Contar CON alguien = to count ON someone. Contar A alguien algo = to tell someone something. Two different uses of contar.'
  where id = v_l4;
  update public.lessons set intro = 'Talk about your closest people.',
    vocab_items = '[{"word":"Mi mejor amigo","phonetic":"[mee meh-HOR ah-MEE-goh]","english":"My best friend","example_es":"Mi mejor amigo es como un hermano.","example_en":"My best friend is like a brother."},{"word":"Confío en él","phonetic":"[kohn-FEE-oh ehn ehl]","english":"I trust him","example_es":"Confío en él con cualquier cosa.","example_en":"I trust him with anything."},{"word":"Nos conocemos hace años","phonetic":"[nohs koh-noh-SEH-mohs]","english":"We''ve known each other for years","example_es":"Nos conocemos hace diez años.","example_en":"We''ve known each other for ten years."},{"word":"Me apoya siempre","phonetic":"[meh ah-POH-yah]","english":"He always supports me","example_es":"Me apoya en todo lo que hago.","example_en":"He supports me in everything I do."}]'::jsonb,
    dialogue = '[{"speaker":"Tú","spanish":"Mi mejor amigo se llama David.","english":"My best friend is David."},{"speaker":"Amiga","spanish":"¿Hace cuánto se conocen?","english":"How long have you known each other?"},{"speaker":"Tú","spanish":"Hace diez años. Confío en él totalmente.","english":"For ten years. I trust him completely."}]'::jsonb,
    grammar_note = '"Hace + time + que" or "hace + time" = "for X time" (still ongoing). "Hace diez años que nos conocemos" = "We''ve known each other for ten years."'
  where id = v_l5;
  update public.lessons set intro = 'Read about long-distance friendships.',
    vocab_items = '[{"word":"a distancia","phonetic":"[ah dees-TAHN-syah]","english":"long-distance","example_es":"Es difícil mantener una amistad a distancia.","example_en":"It''s hard to keep a long-distance friendship."},{"word":"el tiempo libre","phonetic":"[TYEHM-poh LEE-breh]","english":"free time","example_es":"En el tiempo libre llamamos a casa.","example_en":"In our free time we call home."},{"word":"sentirse cerca","phonetic":"[sehn-TEER-seh SEHR-kah]","english":"to feel close","example_es":"Nos sentimos cerca pese a la distancia.","example_en":"We feel close despite the distance."},{"word":"mensaje de voz","phonetic":"[mehn-SAH-heh deh bohs]","english":"voice message","example_es":"Le envío mensajes de voz todos los días.","example_en":"I send him voice messages every day."}]'::jsonb,
    dialogue = '[{"speaker":"Texto","spanish":"Mantener una amistad a distancia no es fácil, pero es posible.","english":"Maintaining a long-distance friendship isn''t easy, but it''s possible."},{"speaker":"Texto","spanish":"Con mensajes de voz y videollamadas semanales, nos sentimos cerca.","english":"With voice messages and weekly video calls, we feel close."},{"speaker":"Texto","spanish":"Aunque vivimos en países distintos, nos contamos todo.","english":"Although we live in different countries, we tell each other everything."}]'::jsonb,
    grammar_note = '"Aunque" + indicative = "although (factual)". "Aunque" + subjunctive = "even if (hypothetical)". Here we use indicative because the distance is real.'
  where id = v_l6;
  update public.lessons set intro = 'Write about a person who matters to you.',
    vocab_items = '[{"word":"significar","phonetic":"[seeg-nee-fee-KAR]","english":"to mean","example_es":"Significa mucho para mí.","example_en":"He means a lot to me."},{"word":"agradecido","phonetic":"[ah-grah-deh-SEE-doh]","english":"grateful","example_es":"Estoy agradecido por su apoyo.","example_en":"I''m grateful for his support."},{"word":"sin importar","phonetic":"[seen eem-pohr-TAR]","english":"no matter","example_es":"Sin importar la distancia, somos amigos.","example_en":"No matter the distance, we''re friends."},{"word":"recuerdo","phonetic":"[rreh-KWEHR-doh]","english":"memory / I remember","example_es":"Recuerdo el día que nos conocimos.","example_en":"I remember the day we met."}]'::jsonb,
    dialogue = '[{"speaker":"Modelo","spanish":"Mi abuela significa mucho para mí.","english":"My grandmother means a lot to me."},{"speaker":"Modelo","spanish":"Estoy agradecido por todo lo que me enseñó.","english":"I''m grateful for everything she taught me."},{"speaker":"Modelo","spanish":"Sin importar la distancia, hablamos cada semana.","english":"No matter the distance, we talk every week."}]'::jsonb,
    grammar_note = '"Lo que" = "the thing that / what". "Todo lo que me enseñó" = "everything (that) she taught me." A common B1 relative pronoun.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "friendship"?','la amistad',array['la pareja','la confianza','la familia'],'friendship',1),
  (v_l1,'fill_blank','Complete: "____ en él totalmente." (I trust)','Confío',array['Apoyo','Discuto','Quiero'],'I trust',2),
  (v_l1,'multiple_choice','What does "discutir" mean?','to argue',array['to agree','to talk','to celebrate'],'to argue',3),
  (v_l1,'listening','What did you hear?','Confío en él totalmente',array['Nuestra amistad dura años','Mi pareja es muy paciente','A veces discutimos'],'I trust him completely',4),
  (v_l1,'speaking','Say this aloud: "Confío en ti totalmente."','Confío en ti totalmente',array[]::text[],'I trust you completely.',5),
  (v_l2,'multiple_choice','How do you say "to miss"?','echar de menos',array['caer bien','llevarse bien','enfadarse'],'to miss',1),
  (v_l2,'fill_blank','Complete: "Me ____ bien con mis suegros." (get on)','llevo',array['caigo','enfado','quiero'],'I get on',2),
  (v_l2,'multiple_choice','What does "caer bien" mean?','to like someone',array['to fall','to get angry','to leave'],'to like someone',3),
  (v_l2,'listening','What did you hear?','Echo de menos a mi familia',array['Me cae bien tu amigo','Se enfada conmigo','Me llevo bien'],'I miss my family',4),
  (v_l2,'speaking','Say this aloud: "Me llevo bien con mi familia."','Me llevo bien con mi familia',array[]::text[],'I get on well with my family.',5),
  (v_l3,'multiple_choice','How do you say "to apologise"?','pedir perdón',array['poner límites','romper con','hablar las cosas'],'to apologise',1),
  (v_l3,'fill_blank','Complete: "Hay que ____ límites." (set)','poner',array['hablar','romper','pedir'],'to set',2),
  (v_l3,'multiple_choice','What does "romper con" mean?','to break up with',array['to apologise','to listen','to argue'],'to break up with',3),
  (v_l3,'listening','What did you hear?','Tenemos que hablar las cosas con calma',array['Quiero pedirte perdón','Hay que poner límites','Rompió con su novia'],'We need to talk things out calmly',4),
  (v_l3,'speaking','Say this aloud: "Quiero pedirte perdón."','Quiero pedirte perdón',array[]::text[],'I want to apologise.',5),
  (v_l4,'multiple_choice','What does "contar con" mean?','to count on',array['to tell','to count','to call'],'to count on',1),
  (v_l4,'fill_blank','Complete: "Me ____ sin juzgar." (listens)','escucha',array['apoya','cuenta','conoce'],'listens',2),
  (v_l4,'multiple_choice','What does "apoyar" mean?','to support',array['to listen','to call','to count'],'to support',3),
  (v_l4,'listening','What did you hear?','Sé que puedo contar con él',array['Es un buen amigo desde la escuela','Me escucha sin juzgar','Siempre apoya'],'I know I can count on him',4),
  (v_l4,'speaking','Say this aloud: "Puedo contar contigo."','Puedo contar contigo',array[]::text[],'I can count on you.',5),
  (v_l5,'multiple_choice','How do you say "We''ve known each other for years"?','Nos conocemos hace años',array['Me conozco hace años','Nos conocemos años hace','Nos conoceremos'],'We''ve known each other for years',1),
  (v_l5,'fill_blank','Complete: "____ diez años que somos amigos." (for/it''s been)','Hace',array['Desde','Por','Para'],'It''s been',2),
  (v_l5,'multiple_choice','What does "Me apoya siempre" mean?','He always supports me',array['I always support him','He listens to me','I miss him'],'He always supports me',3),
  (v_l5,'listening','What did you hear?','Confío en él totalmente',array['Mi mejor amigo se llama David','Hace diez años','Nos conocemos hace años'],'I trust him completely',4),
  (v_l5,'speaking','Say this aloud: "Nos conocemos hace diez años."','Nos conocemos hace diez años',array[]::text[],'We''ve known each other for ten years.',5),
  (v_l6,'multiple_choice','How do you say "long-distance"?','a distancia',array['en línea','de cerca','a tiempo'],'long-distance',1),
  (v_l6,'fill_blank','Complete: "Nos sentimos ____ pese a la distancia." (close)','cerca',array['lejos','solos','tristes'],'close',2),
  (v_l6,'multiple_choice','What does "aunque" mean?','although',array['if','when','because'],'although',3),
  (v_l6,'listening','What did you hear?','Aunque vivimos en países distintos, nos contamos todo',array['Mantener una amistad','Con mensajes de voz','Nos sentimos cerca'],'Although we live in different countries, we tell each other everything',4),
  (v_l6,'speaking','Say this aloud: "Nos sentimos cerca pese a la distancia."','Nos sentimos cerca pese a la distancia',array[]::text[],'We feel close despite the distance.',5),
  (v_l7,'multiple_choice','How do you say "to mean"?','significar',array['agradecer','importar','recordar'],'to mean',1),
  (v_l7,'fill_blank','Complete: "Estoy ____ por su apoyo." (grateful)','agradecido',array['cansado','enfadado','aburrido'],'grateful',2),
  (v_l7,'multiple_choice','What does "sin importar" mean?','no matter',array['without speaking','without listening','without doubt'],'no matter',3),
  (v_l7,'listening','What did you hear?','Mi abuela significa mucho para mí',array['Estoy agradecido','Sin importar la distancia','Recuerdo el día'],'My grandmother means a lot to me',4),
  (v_l7,'speaking','Say this aloud: "Significa mucho para mí."','Significa mucho para mí',array[]::text[],'It means a lot to me.',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Nuestra amistad dura años',array['Mi pareja es paciente','A veces discutimos','Confío en él totalmente'],'Our friendship has lasted years',6),
  (v_l1,'listening','What did you hear?','Mi pareja es muy paciente',array['Nuestra amistad','A veces discutimos','Confío en él'],'My partner is very patient',7),
  (v_l1,'speaking','Say this aloud: "Mi pareja es muy paciente."','Mi pareja es muy paciente',array[]::text[],'My partner is very patient.',8),
  (v_l1,'speaking','Say this aloud: "A veces discutimos pero nos perdonamos."','A veces discutimos pero nos perdonamos',array[]::text[],'Sometimes we argue but we forgive each other.',9),
  (v_l2,'listening','What did you hear?','Me cae bien tu amigo',array['Echo de menos a mi familia','Se enfada conmigo','Me llevo bien'],'I like your friend',6),
  (v_l2,'listening','What did you hear?','Se enfada conmigo a veces',array['Me cae bien tu amigo','Echo de menos','Me llevo bien'],'He gets angry with me sometimes',7),
  (v_l2,'speaking','Say this aloud: "Echo de menos a mi familia."','Echo de menos a mi familia',array[]::text[],'I miss my family.',8),
  (v_l2,'speaking','Say this aloud: "Me cae bien tu amigo."','Me cae bien tu amigo',array[]::text[],'I like your friend.',9),
  (v_l3,'listening','What did you hear?','Le pedí perdón ayer',array['Hay que hablar las cosas','Es importante poner límites','Rompió con su novia'],'I apologised yesterday',6),
  (v_l3,'listening','What did you hear?','Hay que poner límites más claros',array['Le pedí perdón ayer','Tenemos que hablar las cosas','Rompió con su novia'],'We have to set clearer boundaries',7),
  (v_l3,'speaking','Say this aloud: "Hay que poner límites claros."','Hay que poner límites claros',array[]::text[],'We have to set clear boundaries.',8),
  (v_l3,'speaking','Say this aloud: "Le pedí perdón ayer."','Le pedí perdón ayer',array[]::text[],'I apologised yesterday.',9),
  (v_l6,'listening','What did you hear?','Con mensajes de voz y videollamadas',array['Mantener una amistad','Nos sentimos cerca','Nos contamos todo'],'With voice messages and video calls',6),
  (v_l6,'listening','What did you hear?','Le envío mensajes de voz todos los días',array['Mantener una amistad','Nos sentimos cerca','Aunque vivimos'],'I send him voice messages every day',7),
  (v_l6,'speaking','Say this aloud: "Le envío mensajes de voz."','Le envío mensajes de voz',array[]::text[],'I send him voice messages.',8),
  (v_l6,'speaking','Say this aloud: "Es difícil mantener una amistad a distancia."','Es difícil mantener una amistad a distancia',array[]::text[],'It''s hard to maintain a long-distance friendship.',9),
  (v_l7,'listening','What did you hear?','Sin importar la distancia, somos amigos',array['Significa mucho para mí','Estoy agradecido','Recuerdo el día'],'No matter the distance, we''re friends',6),
  (v_l7,'listening','What did you hear?','Recuerdo el día que nos conocimos',array['Significa mucho','Estoy agradecido','Sin importar la distancia'],'I remember the day we met',7),
  (v_l7,'speaking','Say this aloud: "Estoy agradecido por su apoyo."','Estoy agradecido por su apoyo',array[]::text[],'I''m grateful for his support.',8),
  (v_l7,'speaking','Say this aloud: "Recuerdo el día que nos conocimos."','Recuerdo el día que nos conocimos',array[]::text[],'I remember the day we met.',9);

  update public.lessons set type='conversation', title='Relationships — Conversation Practice',
    description='Two friends catch up about life and love.',
    intro='Ana asks Luis how things are going. Listen for relationship vocabulary in action.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Ana","spanish":"¿Cómo va todo con tu pareja?","english":"How''s everything with your partner?"},{"speaker":"Luis","spanish":"Bien, aunque discutimos hace una semana.","english":"Good, although we argued a week ago."},{"speaker":"Ana","spanish":"¿Por qué?","english":"Why?"},{"speaker":"Luis","spanish":"Por una tontería. Pero hablamos las cosas y nos pedimos perdón.","english":"Over a silly thing. But we talked it out and apologised."},{"speaker":"Ana","spanish":"Me alegro. Lo importante es confiar el uno en el otro.","english":"I''m glad. The important thing is to trust each other."},{"speaker":"Luis","spanish":"Sí. Sé que puedo contar con ella, y eso es todo.","english":"Yes. I know I can count on her, and that''s everything."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','When did they argue?','A week ago',array['Yesterday','Last month','Never'],'discutimos hace una semana',1),
  (v_l8,'multiple_choice','What was the argument about?','A silly thing',array['Money','Family','Work'],'Por una tontería',2),
  (v_l8,'multiple_choice','How did they resolve it?','They talked and apologised',array['They broke up','They ignored it','They asked friends'],'hablamos las cosas y nos pedimos perdón',3),
  (v_l8,'multiple_choice','True or false: Luis trusts his partner.','True',array['False'],'Sé que puedo contar con ella',4),
  (v_l8,'fill_blank','Complete: "Lo importante es ____ el uno en el otro." (to trust)','confiar',array['hablar','discutir','romper'],'to trust',5),
  (v_l8,'multiple_choice','How does Ana feel about Luis''s situation?','Glad',array['Worried','Sad','Indifferent'],'Me alegro',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Relationships', 'Review test for the Relationships section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "to trust"?','confiar en',array['discutir','romper con','poner límites'],'to trust',1),
  (v_lesson_id,'multiple_choice','Which means "to miss someone"?','echar de menos',array['caer bien','llevarse bien','contar con'],'to miss',2),
  (v_lesson_id,'multiple_choice','True/false: gustar/caer bien put the person who feels as the indirect object.','True',array['False'],'me cae bien = he is pleasing to me',3),
  (v_lesson_id,'multiple_choice','What does "aunque" mean?','although',array['if','because','when'],'although',4),
  (v_lesson_id,'fill_blank','Complete: "Hay que poner ____" (boundaries)','límites',array['acuerdos','perdones','distancias'],'boundaries',5),
  (v_lesson_id,'fill_blank','Complete: "____ años que somos amigos." (it''s been)','Hace',array['Desde','Por','Para'],'It''s been',6),
  (v_lesson_id,'listening','What did you hear?','Echo de menos a mi familia',array['Me cae bien tu amigo','Hay que poner límites','Nos sentimos cerca'],'I miss my family',7),
  (v_lesson_id,'listening','What did you hear?','Sé que puedo contar con él',array['Le pedí perdón','Significa mucho para mí','Estoy agradecido'],'I know I can count on him',8),
  (v_lesson_id,'speaking','Say this aloud: "Confío en ti totalmente."','Confío en ti totalmente',array[]::text[],'I trust you completely.',9),
  (v_lesson_id,'speaking','Say this aloud: "Nos llevamos muy bien."','Nos llevamos muy bien',array[]::text[],'We get on really well.',10);

  -- ===========================================================
  -- B1.5 CULTURE & TRADITIONS
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B1' and title = 'Culture & Traditions';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set intro='Words for festivals, traditions and customs.',
    vocab_items='[{"word":"la tradición","phonetic":"[trah-dee-SYOHN]","english":"tradition","example_es":"Es una tradición muy antigua.","example_en":"It''s a very old tradition."},{"word":"la fiesta popular","phonetic":"[FYEHS-tah poh-poo-LAR]","english":"popular festival","example_es":"Asistimos a la fiesta popular del pueblo.","example_en":"We attend the town''s popular festival."},{"word":"el desfile","phonetic":"[dehs-FEE-leh]","english":"parade","example_es":"El desfile dura horas.","example_en":"The parade lasts hours."},{"word":"las costumbres","phonetic":"[kohs-TOOM-brehs]","english":"customs","example_es":"Las costumbres varían según la región.","example_en":"Customs vary by region."}]'::jsonb,
    dialogue='[{"speaker":"Ana","spanish":"¿Vas a la fiesta del pueblo?","english":"Are you going to the town festival?"},{"speaker":"Pedro","spanish":"Sí, no me pierdo el desfile.","english":"Yes, I don''t miss the parade."},{"speaker":"Ana","spanish":"Es una tradición muy bonita.","english":"It''s a very lovely tradition."}]'::jsonb,
    grammar_note='"Soler + infinitivo" = to usually do. "Solemos celebrar" = "We usually celebrate." Used to talk about habits.'
  where id = v_l1;
  update public.lessons set intro='Subjunctive in time clauses with cuando.',
    vocab_items='[{"word":"cuando lleguen","phonetic":"[KWAHN-doh YEH-gehn]","english":"when they arrive","example_es":"Cuando lleguen los invitados, comeremos.","example_en":"When the guests arrive, we''ll eat."},{"word":"hasta que","phonetic":"[AHS-tah keh]","english":"until","example_es":"Bailaremos hasta que amanezca.","example_en":"We''ll dance until dawn."},{"word":"antes de que","phonetic":"[AHN-tehs deh keh]","english":"before","example_es":"Compra el regalo antes de que cierre la tienda.","example_en":"Buy the gift before the shop closes."},{"word":"en cuanto","phonetic":"[ehn KWAHN-toh]","english":"as soon as","example_es":"En cuanto termine, te llamo.","example_en":"As soon as I finish, I''ll call you."}]'::jsonb,
    dialogue='[{"speaker":"Eva","spanish":"¿Vamos juntos al desfile?","english":"Shall we go to the parade together?"},{"speaker":"Iván","spanish":"En cuanto termine de trabajar te llamo.","english":"As soon as I finish work I''ll call you."},{"speaker":"Eva","spanish":"Vale, pero ven antes de que empiece.","english":"OK, but come before it starts."}]'::jsonb,
    grammar_note='Time conjunctions about future events take subjunctive: cuando termine, antes de que llegue, hasta que vuelva.'
  where id = v_l2;
  update public.lessons set intro='Phrases to describe festivals.',
    vocab_items='[{"word":"ambiente festivo","phonetic":"[ahm-BYEHN-teh fehs-TEE-boh]","english":"festive atmosphere","example_es":"Hay un gran ambiente festivo.","example_en":"There''s a great festive atmosphere."},{"word":"vestirse de","phonetic":"[behs-TEER-seh deh]","english":"to dress as","example_es":"Los niños se visten de superhéroes.","example_en":"The kids dress as superheroes."},{"word":"el cabezudo","phonetic":"[kah-beh-SOO-doh]","english":"big-head figure","example_es":"Los cabezudos asustan a los niños.","example_en":"The big-heads scare the children."},{"word":"comparsa","phonetic":"[kohm-PAR-sah]","english":"troupe","example_es":"Cada comparsa lleva su música.","example_en":"Each troupe brings its own music."}]'::jsonb,
    dialogue='[{"speaker":"Marta","spanish":"¡Qué ambiente festivo!","english":"What a festive atmosphere!"},{"speaker":"Carlos","spanish":"Sí, las comparsas son espectaculares.","english":"Yes, the troupes are spectacular."},{"speaker":"Marta","spanish":"Mira, los niños se visten de piratas.","english":"Look, the kids are dressed as pirates."}]'::jsonb,
    grammar_note='"¡Qué + noun!" or "¡Qué + adjective!" = expressive exclamation. "¡Qué ambiente!" "¡Qué bonito!"'
  where id = v_l3;
  update public.lessons set intro='Listen to descriptions of regional festivals.',
    vocab_items='[{"word":"la víspera","phonetic":"[BEES-peh-rah]","english":"the eve","example_es":"La víspera de la fiesta hay fuegos artificiales.","example_en":"On the eve of the festival there are fireworks."},{"word":"la procesión","phonetic":"[proh-seh-SYOHN]","english":"procession","example_es":"La procesión recorre las calles.","example_en":"The procession winds through the streets."},{"word":"el patrón","phonetic":"[pah-TROHN]","english":"patron saint","example_es":"Cada pueblo tiene su patrón.","example_en":"Every town has its patron saint."},{"word":"la verbena","phonetic":"[behr-BEH-nah]","english":"open-air party","example_es":"La verbena dura hasta las tres.","example_en":"The open-air party lasts until three."}]'::jsonb,
    dialogue='[{"speaker":"Voz","spanish":"La víspera del patrón hay fuegos artificiales.","english":"On the eve of the patron saint there are fireworks."},{"speaker":"Voz","spanish":"Después, una procesión recorre el centro.","english":"Afterwards a procession winds through the centre."},{"speaker":"Voz","spanish":"La verbena dura hasta las tres de la madrugada.","english":"The open-air party lasts until three in the morning."}]'::jsonb,
    grammar_note='Festival announcements use the simple present for scheduled events: hay fuegos, recorre el centro, dura hasta las tres.'
  where id = v_l4;
  update public.lessons set intro='Speak about your favourite tradition.',
    vocab_items='[{"word":"Mi tradición favorita","phonetic":"[mee trah-dee-SYOHN]","english":"My favourite tradition","example_es":"Mi tradición favorita es la Nochebuena.","example_en":"My favourite tradition is Christmas Eve."},{"word":"Solemos reunirnos","phonetic":"[soh-LEH-mohs rreh-oo-NEER-nohs]","english":"We usually gather","example_es":"Solemos reunirnos en casa de mi abuela.","example_en":"We usually gather at my grandma''s."},{"word":"Comemos","phonetic":"[koh-MEH-mohs]","english":"We eat","example_es":"Comemos comida tradicional.","example_en":"We eat traditional food."},{"word":"Cantamos villancicos","phonetic":"[kahn-TAH-mohs bee-yahn-SEE-kohs]","english":"We sing Christmas carols","example_es":"Cantamos villancicos toda la noche.","example_en":"We sing carols all night."}]'::jsonb,
    dialogue='[{"speaker":"Tú","spanish":"Mi tradición favorita es la Nochebuena.","english":"My favourite tradition is Christmas Eve."},{"speaker":"Amigo","spanish":"¿Qué hacéis?","english":"What do you do?"},{"speaker":"Tú","spanish":"Solemos reunirnos en casa de mi abuela y comemos juntos.","english":"We usually gather at my grandma''s and eat together."}]'::jsonb,
    grammar_note='"Solemos + infinitive" describes a habitual collective action: solemos reunirnos, solemos viajar, solemos cantar.'
  where id = v_l5;
  update public.lessons set intro='Read about a regional tradition.',
    vocab_items='[{"word":"el origen","phonetic":"[oh-REE-hehn]","english":"the origin","example_es":"El origen de la fiesta es medieval.","example_en":"The origin of the festival is medieval."},{"word":"celebrar","phonetic":"[seh-leh-BRAR]","english":"to celebrate","example_es":"Lo celebran cada año.","example_en":"They celebrate it every year."},{"word":"reunir a","phonetic":"[rreh-oo-NEER]","english":"to bring together","example_es":"Reúne a familias enteras.","example_en":"It brings whole families together."},{"word":"el pueblo","phonetic":"[PWEH-bloh]","english":"the village","example_es":"Todo el pueblo participa.","example_en":"The whole village participates."}]'::jsonb,
    dialogue='[{"speaker":"Texto","spanish":"La Tomatina, en Buñol, es una de las fiestas más famosas de España.","english":"La Tomatina, in Buñol, is one of Spain''s most famous festivals."},{"speaker":"Texto","spanish":"Su origen se remonta a 1945 y atrae a miles de visitantes cada agosto.","english":"Its origin goes back to 1945 and it attracts thousands of visitors every August."},{"speaker":"Texto","spanish":"Durante una hora, los participantes se lanzan tomates por las calles.","english":"For one hour, participants throw tomatoes at each other in the streets."}]'::jsonb,
    grammar_note='"Se remonta a + year" = "dates back to". Common in articles about origin or history.'
  where id = v_l6;
  update public.lessons set intro='Write about a tradition in your country.',
    vocab_items='[{"word":"se celebra","phonetic":"[seh seh-LEH-brah]","english":"is celebrated","example_es":"Se celebra el 12 de octubre.","example_en":"It''s celebrated on October 12th."},{"word":"consiste en","phonetic":"[kohn-SEES-teh ehn]","english":"consists of","example_es":"Consiste en una procesión.","example_en":"It consists of a procession."},{"word":"durante","phonetic":"[doo-RAHN-teh]","english":"during","example_es":"Durante tres días no se trabaja.","example_en":"During three days no one works."},{"word":"además","phonetic":"[ah-deh-MAHS]","english":"in addition","example_es":"Además, se come una comida típica.","example_en":"In addition, a typical meal is eaten."}]'::jsonb,
    dialogue='[{"speaker":"Modelo","spanish":"En mi país se celebra el Día de los Muertos en noviembre.","english":"In my country we celebrate Day of the Dead in November."},{"speaker":"Modelo","spanish":"Consiste en visitar a nuestros familiares fallecidos en el cementerio.","english":"It consists of visiting our deceased relatives at the cemetery."},{"speaker":"Modelo","spanish":"Además, preparamos su comida favorita en casa.","english":"In addition, we prepare their favourite food at home."}]'::jsonb,
    grammar_note='Impersonal "se" + 3rd person verb describes practices without naming a subject: se celebra, se come, se prepara.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "tradition"?','la tradición',array['el desfile','la fiesta popular','las costumbres'],'tradition',1),
  (v_l1,'fill_blank','Complete: "El ____ dura horas." (parade)','desfile',array['ambiente','origen','patrón'],'parade',2),
  (v_l1,'multiple_choice','What does "costumbres" mean?','customs',array['parades','songs','dishes'],'customs',3),
  (v_l1,'listening','What did you hear?','No me pierdo el desfile',array['Es una tradición antigua','Las costumbres varían','Asistimos a la fiesta'],'I don''t miss the parade',4),
  (v_l1,'speaking','Say this aloud: "Es una tradición muy antigua."','Es una tradición muy antigua',array[]::text[],'It''s a very old tradition.',5),
  (v_l2,'multiple_choice','How to say "as soon as"?','en cuanto',array['hasta que','antes de que','aunque'],'as soon as',1),
  (v_l2,'fill_blank','Complete: "Cuando ____ los invitados." (arrive - subj)','lleguen',array['llegan','llegaron','llegarán'],'arrive (subj)',2),
  (v_l2,'multiple_choice','What does "antes de que" trigger?','subjunctive',array['preterite','imperfect','future'],'subjunctive',3),
  (v_l2,'listening','What did you hear?','Bailaremos hasta que amanezca',array['Cuando lleguen los invitados','En cuanto termine','Compra el regalo'],'We''ll dance until dawn',4),
  (v_l2,'speaking','Say this aloud: "En cuanto termine, te llamo."','En cuanto termine, te llamo',array[]::text[],'As soon as I finish, I''ll call you.',5),
  (v_l3,'multiple_choice','What is "festive atmosphere"?','ambiente festivo',array['cabezudo','comparsa','desfile'],'festive atmosphere',1),
  (v_l3,'fill_blank','Complete: "Los niños se ____ de piratas." (dress)','visten',array['llevan','ponen','prestan'],'dress',2),
  (v_l3,'multiple_choice','What is "comparsa"?','troupe',array['parade','custom','village'],'troupe',3),
  (v_l3,'listening','What did you hear?','¡Qué ambiente festivo!',array['Las comparsas son espectaculares','Los cabezudos asustan','Los niños se visten de piratas'],'What a festive atmosphere!',4),
  (v_l3,'speaking','Say this aloud: "Las comparsas son espectaculares."','Las comparsas son espectaculares',array[]::text[],'The troupes are spectacular.',5),
  (v_l4,'multiple_choice','What is "the eve"?','la víspera',array['la verbena','la procesión','el patrón'],'the eve',1),
  (v_l4,'fill_blank','Complete: "Cada pueblo tiene su ____" (patron saint)','patrón',array['víspera','verbena','procesión'],'patron saint',2),
  (v_l4,'multiple_choice','What is "verbena"?','open-air party',array['procession','parade','tradition'],'open-air party',3),
  (v_l4,'listening','What did you hear?','La verbena dura hasta las tres de la madrugada',array['La víspera del patrón','Una procesión recorre el centro','La procesión recorre las calles'],'The open-air party lasts until three in the morning',4),
  (v_l4,'speaking','Say this aloud: "La procesión recorre las calles."','La procesión recorre las calles',array[]::text[],'The procession winds through the streets.',5),
  (v_l5,'multiple_choice','How to say "we usually gather"?','solemos reunirnos',array['vamos a reunirnos','nos reunimos','reunimos'],'we usually gather',1),
  (v_l5,'fill_blank','Complete: "Cantamos ____" (carols)','villancicos',array['canciones','desfiles','tradiciones'],'carols',2),
  (v_l5,'multiple_choice','What does "Mi tradición favorita es" mean?','My favourite tradition is',array['I love traditions','My friend''s tradition','I have many traditions'],'My favourite tradition is',3),
  (v_l5,'listening','What did you hear?','Solemos reunirnos en casa de mi abuela',array['Mi tradición favorita es','Comemos comida tradicional','Cantamos villancicos toda la noche'],'We usually gather at my grandma''s',4),
  (v_l5,'speaking','Say this aloud: "Solemos reunirnos toda la familia."','Solemos reunirnos toda la familia',array[]::text[],'The whole family usually gathers.',5),
  (v_l6,'multiple_choice','What is "origin"?','el origen',array['el pueblo','la celebración','la fiesta'],'origin',1),
  (v_l6,'fill_blank','Complete: "Su origen se ____ a 1945." (dates back)','remonta',array['celebra','reúne','consiste'],'dates back',2),
  (v_l6,'multiple_choice','Where is La Tomatina?','Buñol',array['Madrid','Pamplona','Sevilla'],'Buñol',3),
  (v_l6,'listening','What did you hear?','Atrae a miles de visitantes cada agosto',array['Su origen se remonta a 1945','Es una de las fiestas más famosas','Durante una hora se lanzan tomates'],'It attracts thousands of visitors every August',4),
  (v_l6,'speaking','Say this aloud: "Reúne a familias enteras."','Reúne a familias enteras',array[]::text[],'It brings whole families together.',5),
  (v_l7,'multiple_choice','How to say "consists of"?','consiste en',array['se celebra','durante','además'],'consists of',1),
  (v_l7,'fill_blank','Complete: "____, se come una comida típica." (in addition)','Además',array['Durante','Consiste','Después'],'in addition',2),
  (v_l7,'multiple_choice','What does "se celebra" mean?','is celebrated',array['celebrates','celebrated','celebrating'],'is celebrated',3),
  (v_l7,'listening','What did you hear?','En mi país se celebra el Día de los Muertos en noviembre',array['Consiste en visitar a nuestros familiares','Además preparamos su comida','Durante tres días no se trabaja'],'In my country we celebrate Day of the Dead in November',4),
  (v_l7,'speaking','Say this aloud: "Consiste en una procesión."','Consiste en una procesión',array[]::text[],'It consists of a procession.',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Asistimos a la fiesta popular del pueblo',array['Es una tradición antigua','El desfile dura horas','Las costumbres varían'],'We attend the town''s popular festival',6),
  (v_l1,'listening','What did you hear?','Las costumbres varían según la región',array['Es una tradición antigua','Asistimos a la fiesta','El desfile dura horas'],'Customs vary by region',7),
  (v_l1,'speaking','Say this aloud: "Asistimos a la fiesta del pueblo."','Asistimos a la fiesta del pueblo',array[]::text[],'We attend the town festival.',8),
  (v_l1,'speaking','Say this aloud: "Las costumbres varían según la región."','Las costumbres varían según la región',array[]::text[],'Customs vary by region.',9),
  (v_l2,'listening','What did you hear?','Cuando lleguen los invitados, comeremos',array['Hasta que amanezca','Antes de que cierre','En cuanto termine'],'When the guests arrive, we''ll eat',6),
  (v_l2,'listening','What did you hear?','Compra el regalo antes de que cierre la tienda',array['Cuando lleguen','Bailaremos hasta','En cuanto termine'],'Buy the gift before the shop closes',7),
  (v_l2,'speaking','Say this aloud: "Bailaremos hasta que amanezca."','Bailaremos hasta que amanezca',array[]::text[],'We''ll dance until dawn.',8),
  (v_l2,'speaking','Say this aloud: "Antes de que cierre, compra el regalo."','Antes de que cierre, compra el regalo',array[]::text[],'Before it closes, buy the gift.',9),
  (v_l3,'listening','What did you hear?','Cada comparsa lleva su música',array['Hay un gran ambiente festivo','Los cabezudos asustan','Los niños se visten de superhéroes'],'Each troupe brings its own music',6),
  (v_l3,'listening','What did you hear?','Los cabezudos asustan a los niños',array['Hay un gran ambiente festivo','Cada comparsa lleva su música','Los niños se visten'],'The big-heads scare the children',7),
  (v_l3,'speaking','Say this aloud: "Hay un gran ambiente festivo."','Hay un gran ambiente festivo',array[]::text[],'There''s a great festive atmosphere.',8),
  (v_l3,'speaking','Say this aloud: "Los niños se visten de superhéroes."','Los niños se visten de superhéroes',array[]::text[],'The kids dress as superheroes.',9),
  (v_l6,'listening','What did you hear?','Durante una hora, los participantes se lanzan tomates',array['La Tomatina es famosa','Atrae a miles de visitantes','Su origen se remonta a 1945'],'For an hour, participants throw tomatoes',6),
  (v_l6,'listening','What did you hear?','Una de las fiestas más famosas de España',array['Atrae a miles de visitantes','Durante una hora','Reúne a familias enteras'],'One of Spain''s most famous festivals',7),
  (v_l6,'speaking','Say this aloud: "Su origen se remonta al siglo XV."','Su origen se remonta al siglo XV',array[]::text[],'Its origin dates back to the 15th century.',8),
  (v_l6,'speaking','Say this aloud: "Todo el pueblo participa."','Todo el pueblo participa',array[]::text[],'The whole village participates.',9),
  (v_l7,'listening','What did you hear?','Durante tres días no se trabaja',array['Consiste en una procesión','Se celebra el 12 de octubre','Además se come una comida típica'],'During three days no one works',6),
  (v_l7,'listening','What did you hear?','Preparamos su comida favorita en casa',array['Visitamos a nuestros familiares','Se celebra en noviembre','Consiste en una procesión'],'We prepare their favourite food at home',7),
  (v_l7,'speaking','Say this aloud: "Se celebra el 12 de octubre."','Se celebra el 12 de octubre',array[]::text[],'It''s celebrated on October 12th.',8),
  (v_l7,'speaking','Say this aloud: "Además, preparamos una comida típica."','Además, preparamos una comida típica',array[]::text[],'In addition, we prepare a typical meal.',9);

  update public.lessons set type='conversation', title='Culture & Traditions — Conversation Practice',
    description='Two friends compare their favourite traditions.',
    intro='Eva and Pedro compare festivals — one regional, one family-based.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Eva","spanish":"¿Cuál es tu tradición favorita?","english":"What''s your favourite tradition?"},{"speaker":"Pedro","spanish":"La Tomatina, sin duda.","english":"La Tomatina, no doubt."},{"speaker":"Eva","spanish":"¡Qué locura! ¿Y desde cuándo se celebra?","english":"What madness! And since when is it celebrated?"},{"speaker":"Pedro","spanish":"Su origen se remonta a 1945.","english":"Its origin goes back to 1945."},{"speaker":"Eva","spanish":"Yo prefiero la Nochebuena, solemos reunirnos toda la familia.","english":"I prefer Christmas Eve, the whole family usually gathers."},{"speaker":"Pedro","spanish":"Cada uno con su tradición. Lo importante es compartirla.","english":"To each their own tradition. The important thing is to share it."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','Pedro''s favourite tradition?','La Tomatina',array['Nochebuena','Day of the Dead','Carnival'],'La Tomatina, sin duda',1),
  (v_l8,'multiple_choice','When did La Tomatina start?','1945',array['1950','1900','2000'],'Su origen se remonta a 1945',2),
  (v_l8,'multiple_choice','Eva''s favourite?','Christmas Eve',array['La Tomatina','Carnival','Halloween'],'la Nochebuena',3),
  (v_l8,'multiple_choice','True or false: Eva''s tradition is solitary.','False',array['True'],'solemos reunirnos toda la familia',4),
  (v_l8,'fill_blank','Complete: "Su origen ____ a 1945." (dates back)','se remonta',array['se reúne','se celebra','se comparte'],'dates back',5),
  (v_l8,'multiple_choice','What''s Pedro''s final point?','To each their own; share it',array['His tradition is best','Tradition is over','Family is everything'],'Cada uno con su tradición. Lo importante es compartirla',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Culture & Traditions', 'Review test for the Culture & Traditions section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "tradition"?','la tradición',array['la procesión','el desfile','la víspera'],'tradition',1),
  (v_lesson_id,'multiple_choice','Which conjunction triggers subjunctive about future time?','en cuanto',array['porque','si','aunque (factual)'],'as soon as + subj',2),
  (v_lesson_id,'multiple_choice','What does "solemos" mean?','we usually',array['we used to','we have to','we want to'],'we usually + inf',3),
  (v_lesson_id,'multiple_choice','True/false: "se celebra" is impersonal.','True',array['False'],'impersonal se',4),
  (v_lesson_id,'fill_blank','Complete: "Cuando ____ los invitados." (arrive)','lleguen',array['llegan','llegaron','llegan'],'arrive (subj)',5),
  (v_lesson_id,'fill_blank','Complete: "Su origen ____ a 1945." (dates back)','se remonta',array['se celebra','se reúne','se trata'],'dates back',6),
  (v_lesson_id,'listening','What did you hear?','La verbena dura hasta las tres de la madrugada',array['La víspera del patrón','La procesión recorre el centro','El desfile dura horas'],'The open-air party lasts until 3 a.m.',7),
  (v_lesson_id,'listening','What did you hear?','Solemos reunirnos en casa de mi abuela',array['Cantamos villancicos','Consiste en una procesión','Asistimos a la fiesta popular'],'We usually gather at my grandma''s',8),
  (v_lesson_id,'speaking','Say this aloud: "Es una tradición muy antigua."','Es una tradición muy antigua',array[]::text[],'It''s a very old tradition.',9),
  (v_lesson_id,'speaking','Say this aloud: "En cuanto termine, te llamo."','En cuanto termine, te llamo',array[]::text[],'As soon as I finish, I''ll call you.',10);

  -- ===========================================================
  -- B1.6 MONEY & BANKING
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B1' and title = 'Money & Banking';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set intro='Banking vocabulary you need at the counter or app.',
    vocab_items='[{"word":"la cuenta corriente","phonetic":"[KWEHN-tah koh-RRYEHN-teh]","english":"current account","example_es":"Abrí una cuenta corriente.","example_en":"I opened a current account."},{"word":"transferir","phonetic":"[trahns-feh-REER]","english":"to transfer","example_es":"Voy a transferir cien euros.","example_en":"I''m going to transfer 100 euros."},{"word":"el saldo","phonetic":"[SAHL-doh]","english":"balance","example_es":"Mi saldo es bajo.","example_en":"My balance is low."},{"word":"el préstamo","phonetic":"[PREHS-tah-moh]","english":"loan","example_es":"Pedí un préstamo al banco.","example_en":"I asked the bank for a loan."}]'::jsonb,
    dialogue='[{"speaker":"Empleado","spanish":"¿En qué puedo ayudarle?","english":"How can I help you?"},{"speaker":"Cliente","spanish":"Quiero abrir una cuenta corriente.","english":"I want to open a current account."},{"speaker":"Empleado","spanish":"Necesitará su DNI y un comprobante de domicilio.","english":"You''ll need your ID and proof of address."}]'::jsonb,
    grammar_note='"Pedir" requires the indirect object: "pedir algo A alguien". "Pedí un préstamo AL banco."'
  where id = v_l1;
  update public.lessons set intro='Conditional for hypotheticals.',
    vocab_items='[{"word":"ahorraría","phonetic":"[ah-oh-rrah-REE-ah]","english":"I would save","example_es":"Si pudiera, ahorraría más.","example_en":"If I could, I''d save more."},{"word":"si tuviera","phonetic":"[see too-BYEH-rah]","english":"if I had","example_es":"Si tuviera dinero, viajaría.","example_en":"If I had money, I''d travel."},{"word":"invertir","phonetic":"[een-behr-TEER]","english":"to invest","example_es":"Invertiría en una empresa.","example_en":"I''d invest in a company."},{"word":"gastar menos","phonetic":"[gahs-TAR MEH-nohs]","english":"to spend less","example_es":"Debería gastar menos.","example_en":"I should spend less."}]'::jsonb,
    dialogue='[{"speaker":"Eva","spanish":"¿Qué harías si tuvieras mucho dinero?","english":"What would you do if you had a lot of money?"},{"speaker":"Luis","spanish":"Lo invertiría y viajaría.","english":"I''d invest it and travel."},{"speaker":"Eva","spanish":"Yo ahorraría para una casa.","english":"I''d save for a house."}]'::jsonb,
    grammar_note='"Si + imperfect subjunctive + conditional" expresses hypotheticals. "Si tuviera dinero, viajaría."'
  where id = v_l2;
  update public.lessons set intro='Phrases for everyday banking conversations.',
    vocab_items='[{"word":"la tarjeta de crédito","phonetic":"[tahr-HEH-tah deh KREH-dee-toh]","english":"credit card","example_es":"Mi tarjeta de crédito no funciona.","example_en":"My credit card isn''t working."},{"word":"el cajero automático","phonetic":"[kah-HEH-roh ow-toh-MAH-tee-koh]","english":"ATM","example_es":"¿Dónde está el cajero más cercano?","example_en":"Where''s the nearest ATM?"},{"word":"hacer un ingreso","phonetic":"[ah-SEHR oon een-GREH-soh]","english":"to make a deposit","example_es":"Quiero hacer un ingreso.","example_en":"I want to make a deposit."},{"word":"la cuota","phonetic":"[KWOH-tah]","english":"fee","example_es":"La cuota mensual es alta.","example_en":"The monthly fee is high."}]'::jsonb,
    dialogue='[{"speaker":"Cliente","spanish":"Mi tarjeta no funciona en el cajero.","english":"My card isn''t working at the ATM."},{"speaker":"Empleado","spanish":"Voy a revisar. ¿Cuándo la usó por última vez?","english":"I''ll check. When did you last use it?"},{"speaker":"Cliente","spanish":"Ayer hice un ingreso sin problema.","english":"Yesterday I made a deposit without trouble."}]'::jsonb,
    grammar_note='"Por última vez" = for the last time. "Por primera vez" = for the first time. Both very useful for narrating sequences.'
  where id = v_l3;
  update public.lessons set intro='Listen to banking app alerts.',
    vocab_items='[{"word":"el cargo","phonetic":"[KAR-goh]","english":"the charge","example_es":"Hay un cargo extraño.","example_en":"There''s a strange charge."},{"word":"sospechoso","phonetic":"[sohs-peh-CHOH-soh]","english":"suspicious","example_es":"Un movimiento sospechoso.","example_en":"A suspicious transaction."},{"word":"verificar","phonetic":"[beh-ree-fee-KAR]","english":"to verify","example_es":"Verifique su identidad.","example_en":"Verify your identity."},{"word":"bloquear","phonetic":"[bloh-keh-AR]","english":"to block","example_es":"Bloqueé la tarjeta.","example_en":"I blocked the card."}]'::jsonb,
    dialogue='[{"speaker":"App","spanish":"Detectamos un movimiento sospechoso en su cuenta.","english":"We detected a suspicious transaction on your account."},{"speaker":"App","spanish":"Por favor, verifique su identidad cuanto antes.","english":"Please verify your identity as soon as possible."},{"speaker":"App","spanish":"Si no fue usted, bloquee la tarjeta de inmediato.","english":"If it wasn''t you, block the card immediately."}]'::jsonb,
    grammar_note='Formal usted commands: verifique, bloquee, llame. Polite tone for banking communications.'
  where id = v_l4;
  update public.lessons set intro='Talk about saving and spending.',
    vocab_items='[{"word":"Ahorro un poco cada mes","phonetic":"[ah-OH-rroh oon POH-koh]","english":"I save a bit each month","example_es":"Ahorro un poco cada mes para emergencias.","example_en":"I save a bit each month for emergencies."},{"word":"Pago con tarjeta","phonetic":"[PAH-goh kohn tahr-HEH-tah]","english":"I pay by card","example_es":"Pago con tarjeta casi siempre.","example_en":"I pay by card almost always."},{"word":"Invierto en fondos","phonetic":"[een-BYEHR-toh ehn FOHN-dohs]","english":"I invest in funds","example_es":"Invierto en fondos indexados.","example_en":"I invest in index funds."},{"word":"Mi presupuesto es","phonetic":"[mee preh-soo-PWEHS-toh]","english":"My budget is","example_es":"Mi presupuesto es de mil al mes.","example_en":"My budget is a thousand a month."}]'::jsonb,
    dialogue='[{"speaker":"Tú","spanish":"Ahorro un poco cada mes para emergencias.","english":"I save a bit each month for emergencies."},{"speaker":"Amigo","spanish":"¿Y para vacaciones?","english":"And for holidays?"},{"speaker":"Tú","spanish":"Tengo otra cuenta. Mi presupuesto es estricto.","english":"I have another account. My budget is strict."}]'::jsonb,
    grammar_note='Two-account strategy described with "tengo otra cuenta" — present indicative for habits and ongoing facts.'
  where id = v_l5;
  update public.lessons set intro='Read a short personal-finance tip column.',
    vocab_items='[{"word":"controlar los gastos","phonetic":"[kohn-troh-LAR lohs GAHS-tohs]","english":"to control spending","example_es":"Controla tus gastos diarios.","example_en":"Control your daily spending."},{"word":"el fondo de emergencia","phonetic":"[FOHN-doh deh eh-mehr-HEHN-syah]","english":"emergency fund","example_es":"Mantén un fondo de emergencia.","example_en":"Keep an emergency fund."},{"word":"la deuda","phonetic":"[DEH-oo-dah]","english":"the debt","example_es":"Evita acumular deuda.","example_en":"Avoid accumulating debt."},{"word":"la inversión","phonetic":"[een-behr-SYOHN]","english":"investment","example_es":"Una inversión a largo plazo.","example_en":"A long-term investment."}]'::jsonb,
    dialogue='[{"speaker":"Texto","spanish":"Para controlar tus gastos, anota cada compra que haces.","english":"To control your spending, write down every purchase you make."},{"speaker":"Texto","spanish":"Mantén un fondo de emergencia equivalente a tres meses de gastos.","english":"Keep an emergency fund equal to three months of expenses."},{"speaker":"Texto","spanish":"Evita acumular deudas con intereses altos.","english":"Avoid accumulating high-interest debt."}]'::jsonb,
    grammar_note='Tú-form imperatives: anota, mantén, evita. The instructional voice of advice articles.'
  where id = v_l6;
  update public.lessons set intro='Write financial advice for a friend.',
    vocab_items='[{"word":"te recomiendo","phonetic":"[teh rreh-koh-MYEHN-doh]","english":"I recommend","example_es":"Te recomiendo abrir una cuenta de ahorros.","example_en":"I recommend opening a savings account."},{"word":"a largo plazo","phonetic":"[ah LAR-goh PLAH-soh]","english":"long-term","example_es":"Invertir a largo plazo es mejor.","example_en":"Investing long-term is better."},{"word":"automatizar","phonetic":"[ow-toh-mah-tee-SAR]","english":"to automate","example_es":"Automatiza tus ahorros.","example_en":"Automate your savings."},{"word":"poco a poco","phonetic":"[POH-koh ah POH-koh]","english":"little by little","example_es":"Poco a poco se acumula.","example_en":"Little by little it adds up."}]'::jsonb,
    dialogue='[{"speaker":"Modelo","spanish":"Te recomiendo abrir una cuenta de ahorros separada.","english":"I recommend opening a separate savings account."},{"speaker":"Modelo","spanish":"Automatiza una transferencia mensual a esa cuenta.","english":"Automate a monthly transfer to that account."},{"speaker":"Modelo","spanish":"Poco a poco se acumula y tendrás un fondo de emergencia.","english":"Little by little it adds up and you''ll have an emergency fund."}]'::jsonb,
    grammar_note='"Te recomiendo + infinitive" is the polite way to give advice to a friend. With subjunctive when there''s a subject change: "te recomiendo que abras..."'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "current account"?','la cuenta corriente',array['el préstamo','el saldo','la transferencia'],'current account',1),
  (v_l1,'fill_blank','Complete: "Voy a ____ cien euros." (transfer)','transferir',array['ahorrar','pedir','invertir'],'transfer',2),
  (v_l1,'multiple_choice','What does "préstamo" mean?','loan',array['balance','transfer','account'],'loan',3),
  (v_l1,'listening','What did you hear?','Quiero abrir una cuenta corriente',array['Abrí una cuenta corriente','Voy a transferir cien euros','Mi saldo es bajo'],'I want to open a current account',4),
  (v_l1,'speaking','Say this aloud: "Quiero abrir una cuenta corriente."','Quiero abrir una cuenta corriente',array[]::text[],'I want to open a current account.',5),
  (v_l2,'multiple_choice','How to say "if I had"?','si tuviera',array['si tengo','si tenía','si tendré'],'if I had',1),
  (v_l2,'fill_blank','Complete: "Si pudiera, ____ más." (I''d save)','ahorraría',array['ahorro','ahorré','ahorraré'],'I''d save',2),
  (v_l2,'multiple_choice','What does "invertir" mean?','to invest',array['to save','to spend','to lend'],'to invest',3),
  (v_l2,'listening','What did you hear?','Si tuviera dinero, viajaría',array['Lo invertiría y viajaría','Yo ahorraría para una casa','Debería gastar menos'],'If I had money, I''d travel',4),
  (v_l2,'speaking','Say this aloud: "Si tuviera dinero, viajaría."','Si tuviera dinero, viajaría',array[]::text[],'If I had money, I''d travel.',5),
  (v_l3,'multiple_choice','What is "ATM"?','el cajero automático',array['la tarjeta','la cuota','el ingreso'],'ATM',1),
  (v_l3,'fill_blank','Complete: "Quiero hacer un ____" (deposit)','ingreso',array['cargo','saldo','préstamo'],'deposit',2),
  (v_l3,'multiple_choice','What does "la cuota" mean?','the fee',array['the loan','the balance','the deposit'],'the fee',3),
  (v_l3,'listening','What did you hear?','Mi tarjeta no funciona en el cajero',array['Ayer hice un ingreso','¿Cuándo la usó?','Voy a revisar'],'My card isn''t working at the ATM',4),
  (v_l3,'speaking','Say this aloud: "Mi tarjeta de crédito no funciona."','Mi tarjeta de crédito no funciona',array[]::text[],'My credit card isn''t working.',5),
  (v_l4,'multiple_choice','What is "the charge"?','el cargo',array['el préstamo','la cuota','el saldo'],'the charge',1),
  (v_l4,'fill_blank','Complete: "____ su identidad." (verify - formal command)','Verifique',array['Verifica','Verificar','Verificará'],'verify (formal)',2),
  (v_l4,'multiple_choice','What does "sospechoso" mean?','suspicious',array['suspended','suspicious-looking','smart'],'suspicious',3),
  (v_l4,'listening','What did you hear?','Bloquee la tarjeta de inmediato',array['Detectamos un movimiento sospechoso','Verifique su identidad','Hay un cargo extraño'],'Block the card immediately',4),
  (v_l4,'speaking','Say this aloud: "Verifique su identidad."','Verifique su identidad',array[]::text[],'Verify your identity.',5),
  (v_l5,'multiple_choice','How to say "I save a bit each month"?','Ahorro un poco cada mes',array['Pago con tarjeta','Invierto en fondos','Tengo presupuesto'],'I save a bit each month',1),
  (v_l5,'fill_blank','Complete: "Mi ____ es estricto." (budget)','presupuesto',array['cargo','cuota','saldo'],'budget',2),
  (v_l5,'multiple_choice','What is "fondos indexados"?','index funds',array['hedge funds','crypto','savings accounts'],'index funds',3),
  (v_l5,'listening','What did you hear?','Tengo otra cuenta. Mi presupuesto es estricto',array['Pago con tarjeta casi siempre','Ahorro un poco cada mes','Invierto en fondos indexados'],'I have another account. My budget is strict',4),
  (v_l5,'speaking','Say this aloud: "Mi presupuesto es de mil al mes."','Mi presupuesto es de mil al mes',array[]::text[],'My budget is a thousand a month.',5),
  (v_l6,'multiple_choice','What is "emergency fund"?','el fondo de emergencia',array['la deuda','la inversión','el cargo'],'emergency fund',1),
  (v_l6,'fill_blank','Complete: "Evita acumular ____" (debt)','deuda',array['fondo','inversión','gasto'],'debt',2),
  (v_l6,'multiple_choice','What does "controlar los gastos" mean?','control spending',array['raise income','take loans','close accounts'],'control spending',3),
  (v_l6,'listening','What did you hear?','Anota cada compra que haces',array['Mantén un fondo de emergencia','Evita acumular deudas','Una inversión a largo plazo'],'Write down every purchase you make',4),
  (v_l6,'speaking','Say this aloud: "Mantén un fondo de emergencia."','Mantén un fondo de emergencia',array[]::text[],'Keep an emergency fund.',5),
  (v_l7,'multiple_choice','How to say "long-term"?','a largo plazo',array['poco a poco','automatizar','recomendar'],'long-term',1),
  (v_l7,'fill_blank','Complete: "____ tus ahorros." (automate)','Automatiza',array['Recomienda','Acumula','Gasta'],'automate',2),
  (v_l7,'multiple_choice','What does "poco a poco" mean?','little by little',array['quickly','rarely','never'],'little by little',3),
  (v_l7,'listening','What did you hear?','Te recomiendo abrir una cuenta de ahorros separada',array['Automatiza una transferencia mensual','Poco a poco se acumula','Tendrás un fondo de emergencia'],'I recommend opening a separate savings account',4),
  (v_l7,'speaking','Say this aloud: "Automatiza tus ahorros."','Automatiza tus ahorros',array[]::text[],'Automate your savings.',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Mi saldo es bajo',array['Abrí una cuenta corriente','Voy a transferir cien euros','Pedí un préstamo al banco'],'My balance is low',6),
  (v_l1,'listening','What did you hear?','Pedí un préstamo al banco',array['Abrí una cuenta corriente','Voy a transferir','Mi saldo es bajo'],'I asked the bank for a loan',7),
  (v_l1,'speaking','Say this aloud: "Pedí un préstamo al banco."','Pedí un préstamo al banco',array[]::text[],'I asked the bank for a loan.',8),
  (v_l1,'speaking','Say this aloud: "Voy a transferir cien euros."','Voy a transferir cien euros',array[]::text[],'I''m going to transfer 100 euros.',9),
  (v_l2,'listening','What did you hear?','Lo invertiría y viajaría',array['Si pudiera ahorraría más','Yo ahorraría para una casa','Debería gastar menos'],'I''d invest it and travel',6),
  (v_l2,'listening','What did you hear?','Debería gastar menos',array['Lo invertiría','Yo ahorraría','Si tuviera dinero'],'I should spend less',7),
  (v_l2,'speaking','Say this aloud: "Lo invertiría y viajaría."','Lo invertiría y viajaría',array[]::text[],'I''d invest it and travel.',8),
  (v_l2,'speaking','Say this aloud: "Debería gastar menos."','Debería gastar menos',array[]::text[],'I should spend less.',9),
  (v_l3,'listening','What did you hear?','La cuota mensual es alta',array['¿Dónde está el cajero?','Quiero hacer un ingreso','Mi tarjeta no funciona'],'The monthly fee is high',6),
  (v_l3,'listening','What did you hear?','¿Dónde está el cajero más cercano?',array['Quiero hacer un ingreso','La cuota mensual es alta','Mi tarjeta no funciona'],'Where''s the nearest ATM?',7),
  (v_l3,'speaking','Say this aloud: "¿Dónde está el cajero más cercano?"','¿Dónde está el cajero más cercano?',array[]::text[],'Where''s the nearest ATM?',8),
  (v_l3,'speaking','Say this aloud: "Quiero hacer un ingreso."','Quiero hacer un ingreso',array[]::text[],'I want to make a deposit.',9),
  (v_l6,'listening','What did you hear?','Mantén un fondo de emergencia',array['Controla tus gastos diarios','Evita acumular deuda','Una inversión a largo plazo'],'Keep an emergency fund',6),
  (v_l6,'listening','What did you hear?','Una inversión a largo plazo',array['Mantén un fondo de emergencia','Evita acumular deuda','Controla tus gastos'],'A long-term investment',7),
  (v_l6,'speaking','Say this aloud: "Controla tus gastos diarios."','Controla tus gastos diarios',array[]::text[],'Control your daily spending.',8),
  (v_l6,'speaking','Say this aloud: "Evita acumular deudas."','Evita acumular deudas',array[]::text[],'Avoid accumulating debt.',9),
  (v_l7,'listening','What did you hear?','Poco a poco se acumula',array['Te recomiendo abrir','Automatiza una transferencia','Tendrás un fondo de emergencia'],'Little by little it adds up',6),
  (v_l7,'listening','What did you hear?','Tendrás un fondo de emergencia',array['Te recomiendo','Automatiza','Poco a poco'],'You''ll have an emergency fund',7),
  (v_l7,'speaking','Say this aloud: "Te recomiendo invertir a largo plazo."','Te recomiendo invertir a largo plazo',array[]::text[],'I recommend investing long-term.',8),
  (v_l7,'speaking','Say this aloud: "Poco a poco se acumula."','Poco a poco se acumula',array[]::text[],'Little by little it adds up.',9);

  update public.lessons set type='conversation', title='Money & Banking — Conversation Practice',
    description='A customer talks to a bank advisor about their finances.',
    intro='Listen to a meeting with a financial advisor.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Asesor","spanish":"Bienvenida. ¿Cuál es su situación financiera?","english":"Welcome. What''s your financial situation?"},{"speaker":"Marta","spanish":"Tengo una cuenta corriente y algo de ahorros, pero quiero empezar a invertir.","english":"I have a current account and some savings, but I want to start investing."},{"speaker":"Asesor","spanish":"¿A largo plazo o a corto plazo?","english":"Long-term or short-term?"},{"speaker":"Marta","spanish":"A largo plazo. Si pudiera, invertiría en fondos indexados.","english":"Long-term. If I could, I''d invest in index funds."},{"speaker":"Asesor","spanish":"Excelente. Le recomiendo automatizar una transferencia mensual.","english":"Excellent. I recommend automating a monthly transfer."},{"speaker":"Marta","spanish":"Perfecto. ¿Cuál sería el mínimo recomendado?","english":"Perfect. What would be the recommended minimum?"}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','What does Marta want to start?','Investing',array['Borrowing','Spending','Closing her account'],'quiero empezar a invertir',1),
  (v_l8,'multiple_choice','Long or short term?','Long-term',array['Short-term','Both','Neither'],'A largo plazo',2),
  (v_l8,'multiple_choice','Where would she invest?','Index funds',array['Real estate','Crypto','Savings'],'fondos indexados',3),
  (v_l8,'multiple_choice','True or false: The advisor recommends manual transfers.','False',array['True'],'automatizar una transferencia mensual',4),
  (v_l8,'fill_blank','Complete: "Si ____, invertiría en fondos." (I could)','pudiera',array['puedo','podía','podría'],'I could',5),
  (v_l8,'multiple_choice','What does Marta ask about at the end?','The recommended minimum',array['The location','The advisor''s name','The fees'],'¿Cuál sería el mínimo recomendado?',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Money & Banking', 'Review test for the Money & Banking section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "loan"?','el préstamo',array['el saldo','el cargo','la cuota'],'loan',1),
  (v_lesson_id,'multiple_choice','Which is the conditional of ahorrar (I)?','ahorraría',array['ahorré','ahorraba','ahorro'],'I would save',2),
  (v_lesson_id,'multiple_choice','What is "to transfer"?','transferir',array['ahorrar','invertir','gastar'],'to transfer',3),
  (v_lesson_id,'multiple_choice','True/false: si + imperfect subj triggers conditional in the main clause.','True',array['False'],'si tuviera, viajaría',4),
  (v_lesson_id,'fill_blank','Complete: "____ su identidad." (verify - formal)','Verifique',array['Verifica','Verificar','Verifica'],'verify (formal)',5),
  (v_lesson_id,'fill_blank','Complete: "A largo ____" (term)','plazo',array['mes','día','año'],'long-term',6),
  (v_lesson_id,'listening','What did you hear?','Quiero abrir una cuenta corriente',array['Voy a transferir cien euros','Mi saldo es bajo','Pedí un préstamo'],'I want to open a current account',7),
  (v_lesson_id,'listening','What did you hear?','Si tuviera dinero, viajaría',array['Lo invertiría y viajaría','Yo ahorraría para una casa','Debería gastar menos'],'If I had money, I''d travel',8),
  (v_lesson_id,'speaking','Say this aloud: "Mantén un fondo de emergencia."','Mantén un fondo de emergencia',array[]::text[],'Keep an emergency fund.',9),
  (v_lesson_id,'speaking','Say this aloud: "Te recomiendo invertir a largo plazo."','Te recomiendo invertir a largo plazo',array[]::text[],'I recommend investing long-term.',10);

  -- ===========================================================
  -- B1.7 EDUCATION
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B1' and title = 'Education';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set intro='Education vocabulary — schools, degrees, exams.',
    vocab_items='[{"word":"la matrícula","phonetic":"[mah-TREE-koo-lah]","english":"enrolment / tuition","example_es":"La matrícula es cara.","example_en":"Enrolment is expensive."},{"word":"la beca","phonetic":"[BEH-kah]","english":"scholarship","example_es":"Obtuve una beca.","example_en":"I got a scholarship."},{"word":"el título","phonetic":"[TEE-too-loh]","english":"degree","example_es":"Tengo un título universitario.","example_en":"I have a university degree."},{"word":"licenciado","phonetic":"[lee-sehn-SYAH-doh]","english":"graduate","example_es":"Me licencié en Derecho.","example_en":"I graduated in Law."}]'::jsonb,
    dialogue='[{"speaker":"Inés","spanish":"¿Conseguiste la beca?","english":"Did you get the scholarship?"},{"speaker":"Jorge","spanish":"Sí, así que pagaré menos matrícula.","english":"Yes, so I''ll pay less tuition."},{"speaker":"Inés","spanish":"Enhorabuena. ¿Cuándo te licencias?","english":"Congratulations. When do you graduate?"}]'::jsonb,
    grammar_note='"Conseguir" (to get / achieve) — preterite: conseguí, conseguiste, consiguió. Stem-changing in 3rd person.'
  where id = v_l1;
  update public.lessons set intro='Talking about long efforts: imperfect vs preterite.',
    vocab_items='[{"word":"estudiaba","phonetic":"[ehs-too-DYAH-bah]","english":"I used to study","example_es":"Estudiaba todos los días.","example_en":"I used to study every day."},{"word":"hasta que aprobé","phonetic":"[AHS-tah keh ah-proh-BEH]","english":"until I passed","example_es":"Repetía las pruebas hasta que aprobé.","example_en":"I kept retaking the tests until I passed."},{"word":"a base de","phonetic":"[ah BAH-seh deh]","english":"by means of","example_es":"Lo logré a base de esfuerzo.","example_en":"I did it through hard work."},{"word":"superar","phonetic":"[soo-peh-RAR]","english":"to overcome","example_es":"Superé el examen final.","example_en":"I passed the final exam."}]'::jsonb,
    dialogue='[{"speaker":"Eva","spanish":"¿Cómo conseguiste aprobar?","english":"How did you manage to pass?"},{"speaker":"Iván","spanish":"Estudiaba todos los días, sin descanso.","english":"I studied every day, without rest."},{"speaker":"Eva","spanish":"A base de esfuerzo, lo lograste.","english":"Through hard work, you did it."}]'::jsonb,
    grammar_note='Imperfect (estudiaba, repetía) = ongoing past habit. Preterite (aprobé, conseguí) = the single result. Both together tell a study journey.'
  where id = v_l2;
  update public.lessons set intro='Phrases for classroom and university life.',
    vocab_items='[{"word":"asistir a clase","phonetic":"[ah-sees-TEER ah KLAH-seh]","english":"to attend class","example_es":"Hay que asistir a clase.","example_en":"You have to attend class."},{"word":"entregar el trabajo","phonetic":"[ehn-treh-GAR]","english":"to hand in homework","example_es":"Entregué el trabajo a tiempo.","example_en":"I handed in the homework on time."},{"word":"sacar buenas notas","phonetic":"[sah-KAR BWEH-nahs NOH-tahs]","english":"to get good grades","example_es":"Saca buenas notas en todo.","example_en":"He gets good grades in everything."},{"word":"presentar un proyecto","phonetic":"[preh-sehn-TAR]","english":"to present a project","example_es":"Presenté un proyecto sobre el clima.","example_en":"I presented a project on the climate."}]'::jsonb,
    dialogue='[{"speaker":"Tutora","spanish":"¿Has entregado el trabajo?","english":"Have you handed in the homework?"},{"speaker":"Estudiante","spanish":"Sí, ayer presenté el proyecto.","english":"Yes, yesterday I presented the project."},{"speaker":"Tutora","spanish":"Bien. Si sigues así, sacarás buenas notas.","english":"Good. If you keep this up, you''ll get good grades."}]'::jsonb,
    grammar_note='"Si + present + future" expresses future likelihood: "Si sigues así, sacarás buenas notas."'
  where id = v_l3;
  update public.lessons set intro='Listen to a university orientation.',
    vocab_items='[{"word":"la asignatura optativa","phonetic":"[ah-seeg-nah-TOO-rah ohp-tah-TEE-bah]","english":"elective subject","example_es":"Elige dos asignaturas optativas.","example_en":"Choose two elective subjects."},{"word":"el plan de estudios","phonetic":"[plahn deh ehs-TOO-dyohs]","english":"curriculum","example_es":"Aquí está el plan de estudios.","example_en":"Here''s the curriculum."},{"word":"el horario","phonetic":"[oh-RAH-ryoh]","english":"schedule","example_es":"Revisa tu horario.","example_en":"Check your schedule."},{"word":"el examen final","phonetic":"[ehk-SAH-mehn fee-NAHL]","english":"final exam","example_es":"El examen final es en junio.","example_en":"The final exam is in June."}]'::jsonb,
    dialogue='[{"speaker":"Profesora","spanish":"Bienvenidos al curso.","english":"Welcome to the course."},{"speaker":"Profesora","spanish":"Aquí está el plan de estudios y el horario.","english":"Here''s the curriculum and the schedule."},{"speaker":"Profesora","spanish":"Deben elegir dos asignaturas optativas antes del examen final.","english":"You must choose two electives before the final exam."}]'::jsonb,
    grammar_note='"Deber + infinitive" expresses formal obligation: "Deben elegir." Stronger than "tener que" in academic / professional contexts.'
  where id = v_l4;
  update public.lessons set intro='Talk about your studies.',
    vocab_items='[{"word":"Estudio en la universidad","phonetic":"[ehs-TOO-dyoh ehn lah]","english":"I study at university","example_es":"Estudio en la universidad pública.","example_en":"I study at a public university."},{"word":"Mi carrera es","phonetic":"[mee kah-RREH-rah]","english":"My degree is","example_es":"Mi carrera es Filología.","example_en":"My degree is Philology."},{"word":"En segundo año","phonetic":"[ehn seh-GOON-doh AH-nyoh]","english":"In the second year","example_es":"Estoy en segundo año.","example_en":"I''m in my second year."},{"word":"Hago prácticas en","phonetic":"[AH-goh PRAHK-tee-kahs]","english":"I''m interning at","example_es":"Hago prácticas en un periódico.","example_en":"I''m interning at a newspaper."}]'::jsonb,
    dialogue='[{"speaker":"Tú","spanish":"Estudio Periodismo en la universidad pública.","english":"I study Journalism at a public university."},{"speaker":"Amigo","spanish":"¿En qué curso estás?","english":"What year are you in?"},{"speaker":"Tú","spanish":"En tercer año. Hago prácticas en un periódico.","english":"In third year. I''m interning at a newspaper."}]'::jsonb,
    grammar_note='"Hacer prácticas" = to do an internship. Common collocation in Spain. In Latin America "hacer pasantías" is more common.'
  where id = v_l5;
  update public.lessons set intro='Read about online learning.',
    vocab_items='[{"word":"la enseñanza en línea","phonetic":"[ehn-seh-NYAHN-sah ehn LEE-neh-ah]","english":"online education","example_es":"La enseñanza en línea creció mucho.","example_en":"Online education has grown a lot."},{"word":"la flexibilidad","phonetic":"[flehk-see-bee-lee-DAHD]","english":"flexibility","example_es":"Ofrece mucha flexibilidad.","example_en":"It offers a lot of flexibility."},{"word":"el aula virtual","phonetic":"[OW-lah beer-TWAHL]","english":"virtual classroom","example_es":"El aula virtual es interactiva.","example_en":"The virtual classroom is interactive."},{"word":"el reto","phonetic":"[RREH-toh]","english":"challenge","example_es":"El mayor reto es la concentración.","example_en":"The biggest challenge is concentration."}]'::jsonb,
    dialogue='[{"speaker":"Texto","spanish":"La enseñanza en línea ha cambiado el panorama educativo.","english":"Online education has changed the educational landscape."},{"speaker":"Texto","spanish":"Ofrece flexibilidad y acceso a estudiantes de todo el mundo.","english":"It offers flexibility and access to students worldwide."},{"speaker":"Texto","spanish":"Sin embargo, el mayor reto sigue siendo mantener la motivación.","english":"However, the biggest challenge remains keeping motivation."}]'::jsonb,
    grammar_note='"Seguir siendo" = "to continue being / to remain". Useful for description: "sigue siendo un problema", "sigue siendo importante".'
  where id = v_l6;
  update public.lessons set intro='Write about your learning experience.',
    vocab_items='[{"word":"aprender","phonetic":"[ah-prehn-DEHR]","english":"to learn","example_es":"Aprendí mucho en la universidad.","example_en":"I learned a lot at university."},{"word":"motivado","phonetic":"[moh-tee-BAH-doh]","english":"motivated","example_es":"Estoy muy motivado este curso.","example_en":"I''m very motivated this term."},{"word":"el progreso","phonetic":"[proh-GREH-soh]","english":"the progress","example_es":"Mi progreso es lento pero constante.","example_en":"My progress is slow but steady."},{"word":"además de","phonetic":"[ah-deh-MAHS deh]","english":"in addition to","example_es":"Además de inglés, estudio chino.","example_en":"In addition to English, I''m studying Chinese."}]'::jsonb,
    dialogue='[{"speaker":"Modelo","spanish":"Aprender un idioma requiere paciencia y constancia.","english":"Learning a language requires patience and consistency."},{"speaker":"Modelo","spanish":"Estoy muy motivado porque mi progreso es notable.","english":"I''m very motivated because my progress is noticeable."},{"speaker":"Modelo","spanish":"Además de las clases, practico todos los días con una app.","english":"In addition to classes, I practise every day with an app."}]'::jsonb,
    grammar_note='Abstract nouns from infinitives: "Aprender un idioma requiere..." The infinitive acts as a singular noun.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "scholarship"?','la beca',array['la matrícula','el título','el horario'],'scholarship',1),
  (v_l1,'fill_blank','Complete: "La ____ es cara." (enrolment)','matrícula',array['beca','título','progreso'],'enrolment',2),
  (v_l1,'multiple_choice','What does "licenciado" mean?','graduate',array['teacher','student','intern'],'graduate',3),
  (v_l1,'listening','What did you hear?','Obtuve una beca',array['Tengo un título universitario','La matrícula es cara','Me licencié en Derecho'],'I got a scholarship',4),
  (v_l1,'speaking','Say this aloud: "Tengo un título universitario."','Tengo un título universitario',array[]::text[],'I have a university degree.',5),
  (v_l2,'multiple_choice','How to say "I used to study"?','estudiaba',array['estudié','estudio','estudiaré'],'I used to study (imperfect)',1),
  (v_l2,'fill_blank','Complete: "Lo logré a ____ de esfuerzo." (by means)','base',array['causa','pesar','través'],'by means of',2),
  (v_l2,'multiple_choice','What does "superar" mean?','to overcome',array['to fail','to retake','to enrol'],'to overcome',3),
  (v_l2,'listening','What did you hear?','Estudiaba todos los días, sin descanso',array['A base de esfuerzo, lo lograste','Repetía las pruebas hasta que aprobé','Superé el examen final'],'I studied every day, without rest',4),
  (v_l2,'speaking','Say this aloud: "A base de esfuerzo, lo logré."','A base de esfuerzo, lo logré',array[]::text[],'Through hard work, I did it.',5),
  (v_l3,'multiple_choice','What is "to attend class"?','asistir a clase',array['entregar el trabajo','sacar buenas notas','presentar un proyecto'],'to attend class',1),
  (v_l3,'fill_blank','Complete: "Saca buenas ____ en todo." (grades)','notas',array['horarios','asignaturas','presentaciones'],'grades',2),
  (v_l3,'multiple_choice','What does "entregar" mean?','to hand in',array['to write','to receive','to forget'],'to hand in',3),
  (v_l3,'listening','What did you hear?','Sí, ayer presenté el proyecto',array['¿Has entregado el trabajo?','Si sigues así, sacarás buenas notas','Hay que asistir a clase'],'Yes, yesterday I presented the project',4),
  (v_l3,'speaking','Say this aloud: "Hay que asistir a clase."','Hay que asistir a clase',array[]::text[],'You have to attend class.',5),
  (v_l4,'multiple_choice','What is "elective subject"?','la asignatura optativa',array['el plan de estudios','el horario','el examen final'],'elective',1),
  (v_l4,'fill_blank','Complete: "Revisa tu ____" (schedule)','horario',array['plan','asignatura','examen'],'schedule',2),
  (v_l4,'multiple_choice','What is "plan de estudios"?','curriculum',array['schedule','exam','grade'],'curriculum',3),
  (v_l4,'listening','What did you hear?','Deben elegir dos asignaturas optativas antes del examen final',array['Aquí está el plan de estudios','Bienvenidos al curso','Revisa tu horario'],'You must choose two electives before the final exam',4),
  (v_l4,'speaking','Say this aloud: "Aquí está el plan de estudios."','Aquí está el plan de estudios',array[]::text[],'Here''s the curriculum.',5),
  (v_l5,'multiple_choice','How to say "I''m interning at"?','Hago prácticas en',array['Estudio en','Mi carrera es','En segundo año'],'I''m interning at',1),
  (v_l5,'fill_blank','Complete: "En ____ año." (third)','tercer',array['segundo','primer','cuarto'],'third',2),
  (v_l5,'multiple_choice','What does "carrera" mean here?','degree / major',array['career','race','job'],'degree',3),
  (v_l5,'listening','What did you hear?','Hago prácticas en un periódico',array['Estudio Periodismo','Mi carrera es Filología','En segundo año'],'I''m interning at a newspaper',4),
  (v_l5,'speaking','Say this aloud: "Estudio Periodismo en la universidad."','Estudio Periodismo en la universidad',array[]::text[],'I study Journalism at the university.',5),
  (v_l6,'multiple_choice','What is "online education"?','la enseñanza en línea',array['la flexibilidad','el aula virtual','el reto'],'online education',1),
  (v_l6,'fill_blank','Complete: "El mayor ____ es la concentración." (challenge)','reto',array['progreso','aula','plan'],'challenge',2),
  (v_l6,'multiple_choice','What does "seguir siendo" mean?','to continue being',array['to stop being','to become','to need'],'to continue being',3),
  (v_l6,'listening','What did you hear?','Ofrece flexibilidad y acceso a estudiantes de todo el mundo',array['La enseñanza en línea ha cambiado','El mayor reto sigue siendo','El aula virtual es interactiva'],'It offers flexibility and access to students worldwide',4),
  (v_l6,'speaking','Say this aloud: "El aula virtual es interactiva."','El aula virtual es interactiva',array[]::text[],'The virtual classroom is interactive.',5),
  (v_l7,'multiple_choice','How to say "progress"?','el progreso',array['el reto','el horario','la flexibilidad'],'progress',1),
  (v_l7,'fill_blank','Complete: "____ de las clases, practico todos los días." (in addition)','Además',array['Sin embargo','A pesar','Durante'],'in addition',2),
  (v_l7,'multiple_choice','What does "constancia" mean?','consistency',array['confidence','curiosity','course'],'consistency',3),
  (v_l7,'listening','What did you hear?','Aprender un idioma requiere paciencia y constancia',array['Estoy muy motivado este curso','Mi progreso es lento pero constante','Además de inglés estudio chino'],'Learning a language requires patience and consistency',4),
  (v_l7,'speaking','Say this aloud: "Aprender un idioma requiere paciencia."','Aprender un idioma requiere paciencia',array[]::text[],'Learning a language requires patience.',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Me licencié en Derecho',array['Obtuve una beca','Tengo un título universitario','La matrícula es cara'],'I graduated in Law',6),
  (v_l1,'listening','What did you hear?','La matrícula es cara',array['Obtuve una beca','Tengo un título','Me licencié en Derecho'],'Enrolment is expensive',7),
  (v_l1,'speaking','Say this aloud: "Obtuve una beca."','Obtuve una beca',array[]::text[],'I got a scholarship.',8),
  (v_l1,'speaking','Say this aloud: "Me licencié en Derecho."','Me licencié en Derecho',array[]::text[],'I graduated in Law.',9),
  (v_l2,'listening','What did you hear?','Repetía las pruebas hasta que aprobé',array['Estudiaba todos los días','A base de esfuerzo','Superé el examen final'],'I kept retaking the tests until I passed',6),
  (v_l2,'listening','What did you hear?','Superé el examen final',array['Estudiaba todos los días','Repetía las pruebas','A base de esfuerzo'],'I passed the final exam',7),
  (v_l2,'speaking','Say this aloud: "Superé el examen final."','Superé el examen final',array[]::text[],'I passed the final exam.',8),
  (v_l2,'speaking','Say this aloud: "Repetía las pruebas hasta que aprobé."','Repetía las pruebas hasta que aprobé',array[]::text[],'I kept retaking the tests until I passed.',9),
  (v_l3,'listening','What did you hear?','Si sigues así, sacarás buenas notas',array['¿Has entregado el trabajo?','Sí, ayer presenté el proyecto','Hay que asistir a clase'],'If you keep this up, you''ll get good grades',6),
  (v_l3,'listening','What did you hear?','Presenté un proyecto sobre el clima',array['Entregué el trabajo a tiempo','Saca buenas notas en todo','Si sigues así'],'I presented a project on the climate',7),
  (v_l3,'speaking','Say this aloud: "Entregué el trabajo a tiempo."','Entregué el trabajo a tiempo',array[]::text[],'I handed in the homework on time.',8),
  (v_l3,'speaking','Say this aloud: "Saca buenas notas en todo."','Saca buenas notas en todo',array[]::text[],'He gets good grades in everything.',9),
  (v_l6,'listening','What did you hear?','La enseñanza en línea ha cambiado el panorama educativo',array['Ofrece flexibilidad y acceso','El mayor reto sigue siendo','El aula virtual es interactiva'],'Online education has changed the educational landscape',6),
  (v_l6,'listening','What did you hear?','Mantener la motivación',array['La enseñanza en línea','Ofrece flexibilidad','El aula virtual'],'Keeping motivation',7),
  (v_l6,'speaking','Say this aloud: "El mayor reto es mantener la motivación."','El mayor reto es mantener la motivación',array[]::text[],'The biggest challenge is keeping motivation.',8),
  (v_l6,'speaking','Say this aloud: "Ofrece mucha flexibilidad."','Ofrece mucha flexibilidad',array[]::text[],'It offers a lot of flexibility.',9),
  (v_l7,'listening','What did you hear?','Mi progreso es lento pero constante',array['Estoy muy motivado','Practico todos los días con una app','Además de inglés'],'My progress is slow but steady',6),
  (v_l7,'listening','What did you hear?','Estoy muy motivado porque mi progreso es notable',array['Aprender un idioma','Además de las clases','Practico todos los días'],'I''m very motivated because my progress is noticeable',7),
  (v_l7,'speaking','Say this aloud: "Estoy muy motivado este curso."','Estoy muy motivado este curso',array[]::text[],'I''m very motivated this term.',8),
  (v_l7,'speaking','Say this aloud: "Además de inglés, estudio chino."','Además de inglés, estudio chino',array[]::text[],'In addition to English, I''m studying Chinese.',9);

  update public.lessons set type='conversation', title='Education — Conversation Practice',
    description='Two students compare their study journeys.',
    intro='Inés and Jorge meet after a long term and compare progress.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Inés","spanish":"¿Cómo te fue este semestre?","english":"How did this semester go?"},{"speaker":"Jorge","spanish":"Bastante bien. Conseguí la beca y aprobé todas las asignaturas.","english":"Pretty well. I got the scholarship and passed all my subjects."},{"speaker":"Inés","spanish":"¡Enhorabuena! ¿Cómo lo hiciste?","english":"Congratulations! How did you do it?"},{"speaker":"Jorge","spanish":"Estudiaba todos los días y entregaba los trabajos a tiempo.","english":"I studied every day and handed in assignments on time."},{"speaker":"Inés","spanish":"A base de esfuerzo, vamos.","english":"Through hard work, basically."},{"speaker":"Jorge","spanish":"Eso es. Y el próximo año empiezo prácticas.","english":"That''s it. And next year I start an internship."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','What did Jorge get?','A scholarship',array['A new course','A job','A degree'],'Conseguí la beca',1),
  (v_l8,'multiple_choice','Did he pass all subjects?','Yes',array['No','Some','Doesn''t say'],'aprobé todas las asignaturas',2),
  (v_l8,'multiple_choice','How did he do it?','By studying every day and handing in on time',array['By luck','By cheating','By cramming'],'Estudiaba todos los días y entregaba los trabajos a tiempo',3),
  (v_l8,'multiple_choice','True or false: He starts an internship next year.','True',array['False'],'el próximo año empiezo prácticas',4),
  (v_l8,'fill_blank','Complete: "A ____ de esfuerzo." (through)','base',array['causa','pesar','través'],'through',5),
  (v_l8,'multiple_choice','Inés''s reaction?','Congratulations',array['Doubt','Indifference','Anger'],'¡Enhorabuena!',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Education', 'Review test for the Education section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "scholarship"?','la beca',array['la matrícula','el título','el reto'],'scholarship',1),
  (v_lesson_id,'multiple_choice','Imperfect "I used to study"?','estudiaba',array['estudié','estudio','estudiaré'],'I used to study',2),
  (v_lesson_id,'multiple_choice','What does "asistir a clase" mean?','to attend class',array['to teach class','to skip class','to start class'],'to attend class',3),
  (v_lesson_id,'multiple_choice','True/false: "seguir siendo" = to remain.','True',array['False'],'seguir siendo = to keep being',4),
  (v_lesson_id,'fill_blank','Complete: "A ____ de esfuerzo." (through)','base',array['causa','pesar','través'],'through',5),
  (v_lesson_id,'fill_blank','Complete: "Hago ____ en un periódico." (internship)','prácticas',array['proyectos','clases','exámenes'],'internship',6),
  (v_lesson_id,'listening','What did you hear?','Obtuve una beca',array['La matrícula es cara','Tengo un título universitario','Me licencié en Derecho'],'I got a scholarship',7),
  (v_lesson_id,'listening','What did you hear?','El aula virtual es interactiva',array['Ofrece flexibilidad','El mayor reto es la concentración','La enseñanza en línea creció'],'The virtual classroom is interactive',8),
  (v_lesson_id,'speaking','Say this aloud: "Estoy muy motivado este curso."','Estoy muy motivado este curso',array[]::text[],'I''m very motivated this term.',9),
  (v_lesson_id,'speaking','Say this aloud: "Aprender un idioma requiere constancia."','Aprender un idioma requiere constancia',array[]::text[],'Learning a language requires consistency.',10);

  -- ===========================================================
  -- B1.8 POLITICS BASICS
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B1' and title = 'Politics Basics';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set intro='Basic political vocabulary for the news.',
    vocab_items='[{"word":"el gobierno","phonetic":"[goh-BYEHR-noh]","english":"government","example_es":"El gobierno aprobó una ley.","example_en":"The government passed a law."},{"word":"el partido","phonetic":"[pahr-TEE-doh]","english":"party","example_es":"Es del partido conservador.","example_en":"He''s from the conservative party."},{"word":"las elecciones","phonetic":"[eh-lehk-SYOH-nehs]","english":"elections","example_es":"Las elecciones son en mayo.","example_en":"Elections are in May."},{"word":"el voto","phonetic":"[BOH-toh]","english":"the vote","example_es":"Cada voto cuenta.","example_en":"Every vote counts."}]'::jsonb,
    dialogue='[{"speaker":"Ana","spanish":"¿Vas a votar en las elecciones?","english":"Are you going to vote in the election?"},{"speaker":"Luis","spanish":"Sí, cada voto cuenta.","english":"Yes, every vote counts."},{"speaker":"Ana","spanish":"¿A qué partido apoyas?","english":"What party do you support?"}]'::jsonb,
    grammar_note='Spanish political vocabulary uses many definite articles: EL gobierno, LOS partidos, LAS elecciones. Articles signal the topic.'
  where id = v_l1;
  update public.lessons set intro='Expressing opinion with subjunctive.',
    vocab_items='[{"word":"creo que","phonetic":"[KREH-oh keh]","english":"I think that","example_es":"Creo que es justo.","example_en":"I think it''s fair."},{"word":"no creo que sea","phonetic":"[noh KREH-oh keh SEH-ah]","english":"I don''t think it''s","example_es":"No creo que sea justo.","example_en":"I don''t think it''s fair."},{"word":"estar de acuerdo","phonetic":"[ehs-TAR deh ah-KWEHR-doh]","english":"to agree","example_es":"Estoy de acuerdo contigo.","example_en":"I agree with you."},{"word":"oponerse a","phonetic":"[oh-poh-NEHR-seh]","english":"to oppose","example_es":"Se oponen a la ley.","example_en":"They oppose the law."}]'::jsonb,
    dialogue='[{"speaker":"Eva","spanish":"Creo que esa ley es justa.","english":"I think that law is fair."},{"speaker":"Iván","spanish":"No creo que sea justa para todos.","english":"I don''t think it''s fair for everyone."},{"speaker":"Eva","spanish":"Pues no estamos de acuerdo.","english":"Well, we don''t agree."}]'::jsonb,
    grammar_note='"Creo que" + indicative. "No creo que" + subjunctive. Doubt or negation triggers subjunctive.'
  where id = v_l2;
  update public.lessons set intro='Phrases for political discussions.',
    vocab_items='[{"word":"el debate","phonetic":"[deh-BAH-teh]","english":"debate","example_es":"El debate fue acalorado.","example_en":"The debate was heated."},{"word":"la propuesta","phonetic":"[proh-PWEHS-tah]","english":"proposal","example_es":"La propuesta no convence.","example_en":"The proposal isn''t convincing."},{"word":"el impuesto","phonetic":"[eem-PWEHS-toh]","english":"tax","example_es":"Subirán los impuestos.","example_en":"They''ll raise taxes."},{"word":"la reforma","phonetic":"[rreh-FOHR-mah]","english":"reform","example_es":"Hace falta una reforma.","example_en":"A reform is needed."}]'::jsonb,
    dialogue='[{"speaker":"Marta","spanish":"¿Viste el debate de anoche?","english":"Did you see last night''s debate?"},{"speaker":"Pedro","spanish":"Sí, la propuesta sobre los impuestos fue lo más polémico.","english":"Yes, the tax proposal was the most controversial part."},{"speaker":"Marta","spanish":"Hace falta una reforma profunda.","english":"A deep reform is needed."}]'::jsonb,
    grammar_note='"Hacer falta" = "to be necessary / needed". Impersonal: "Hace falta una reforma." Plural: "Hacen falta cambios."'
  where id = v_l3;
  update public.lessons set intro='Listen to a political broadcast.',
    vocab_items='[{"word":"la candidata","phonetic":"[kahn-dee-DAH-tah]","english":"candidate (f)","example_es":"La candidata habló claramente.","example_en":"The candidate spoke clearly."},{"word":"la campaña","phonetic":"[kahm-PAH-nyah]","english":"campaign","example_es":"La campaña terminó ayer.","example_en":"The campaign ended yesterday."},{"word":"la encuesta","phonetic":"[ehn-KWEHS-tah]","english":"poll","example_es":"Según la encuesta, gana ella.","example_en":"According to the poll, she wins."},{"word":"prometer","phonetic":"[proh-meh-TEHR]","english":"to promise","example_es":"Prometió bajar los impuestos.","example_en":"She promised to lower taxes."}]'::jsonb,
    dialogue='[{"speaker":"Locutor","spanish":"La candidata Pérez ganó el debate de anoche.","english":"Candidate Pérez won last night''s debate."},{"speaker":"Locutor","spanish":"Según la última encuesta, lidera con un 5%.","english":"According to the latest poll, she leads by 5%."},{"speaker":"Locutor","spanish":"En su discurso, prometió una reforma fiscal.","english":"In her speech, she promised tax reform."}]'::jsonb,
    grammar_note='Election Spanish heavy on preterite (ganó, prometió) for completed events and present (lidera) for ongoing state.'
  where id = v_l4;
  update public.lessons set intro='Express your political views.',
    vocab_items='[{"word":"En mi opinión","phonetic":"[ehn mee oh-pee-NYOHN]","english":"In my opinion","example_es":"En mi opinión, hay que cambiar.","example_en":"In my opinion, we have to change."},{"word":"Me preocupa","phonetic":"[meh preh-oh-KOO-pah]","english":"It worries me","example_es":"Me preocupa el desempleo.","example_en":"Unemployment worries me."},{"word":"votaría por","phonetic":"[boh-tah-REE-ah]","english":"I would vote for","example_es":"Votaría por un cambio.","example_en":"I''d vote for change."},{"word":"el cambio","phonetic":"[KAHM-byoh]","english":"change","example_es":"Necesitamos un cambio.","example_en":"We need change."}]'::jsonb,
    dialogue='[{"speaker":"Tú","spanish":"En mi opinión, necesitamos un cambio.","english":"In my opinion, we need change."},{"speaker":"Amiga","spanish":"¿Por qué?","english":"Why?"},{"speaker":"Tú","spanish":"Me preocupa el desempleo. Votaría por reformas.","english":"Unemployment worries me. I''d vote for reform."}]'::jsonb,
    grammar_note='"Me preocupa + noun" works backwards like gustar: the topic is the subject, the worried person is the indirect object.'
  where id = v_l5;
  update public.lessons set intro='Read about voter turnout.',
    vocab_items='[{"word":"la participación","phonetic":"[pahr-tee-see-pah-SYOHN]","english":"participation / turnout","example_es":"La participación fue alta.","example_en":"Turnout was high."},{"word":"abstenerse","phonetic":"[ahbs-teh-NEHR-seh]","english":"to abstain","example_es":"Mucha gente se abstuvo.","example_en":"Many people abstained."},{"word":"el ciudadano","phonetic":"[syoo-dah-DAH-noh]","english":"citizen","example_es":"Cada ciudadano tiene voto.","example_en":"Every citizen has a vote."},{"word":"la urna","phonetic":"[OOR-nah]","english":"ballot box","example_es":"Acuden a las urnas.","example_en":"They go to the ballot box."}]'::jsonb,
    dialogue='[{"speaker":"Texto","spanish":"La participación en las últimas elecciones alcanzó el 75%.","english":"Turnout in the last election reached 75%."},{"speaker":"Texto","spanish":"Sin embargo, dos de cada diez ciudadanos se abstuvieron.","english":"However, two in ten citizens abstained."},{"speaker":"Texto","spanish":"Las urnas reflejaron un país dividido.","english":"The ballot boxes reflected a divided country."}]'::jsonb,
    grammar_note='"Acudir a + place" = to attend / go to (somewhat formal). "Acuden a las urnas" = "They turn out to vote."'
  where id = v_l6;
  update public.lessons set intro='Write a short opinion piece.',
    vocab_items='[{"word":"a favor de","phonetic":"[ah fah-BOHR deh]","english":"in favour of","example_es":"Estoy a favor de la reforma.","example_en":"I''m in favour of the reform."},{"word":"en contra de","phonetic":"[ehn KOHN-trah]","english":"against","example_es":"Estoy en contra de subir impuestos.","example_en":"I''m against raising taxes."},{"word":"por un lado","phonetic":"[pohr oon LAH-doh]","english":"on one hand","example_es":"Por un lado es necesario.","example_en":"On one hand, it''s necessary."},{"word":"por otro lado","phonetic":"[pohr OH-troh LAH-doh]","english":"on the other hand","example_es":"Por otro lado, es injusto.","example_en":"On the other hand, it''s unfair."}]'::jsonb,
    dialogue='[{"speaker":"Modelo","spanish":"Estoy a favor de la nueva ley educativa.","english":"I''m in favour of the new education law."},{"speaker":"Modelo","spanish":"Por un lado, mejora la formación; por otro lado, sube los impuestos.","english":"On one hand it improves training; on the other it raises taxes."},{"speaker":"Modelo","spanish":"En mi opinión, el beneficio compensa el coste.","english":"In my opinion, the benefit outweighs the cost."}]'::jsonb,
    grammar_note='Opinion connectors balance pros and cons: "por un lado / por otro lado", "sin embargo", "en mi opinión".'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "government"?','el gobierno',array['el partido','las elecciones','el voto'],'government',1),
  (v_l1,'fill_blank','Complete: "Cada ____ cuenta." (vote)','voto',array['partido','gobierno','elección'],'vote',2),
  (v_l1,'multiple_choice','What does "partido" mean here?','party',array['game','match','session'],'party',3),
  (v_l1,'listening','What did you hear?','Las elecciones son en mayo',array['Cada voto cuenta','El gobierno aprobó una ley','¿A qué partido apoyas?'],'Elections are in May',4),
  (v_l1,'speaking','Say this aloud: "Cada voto cuenta."','Cada voto cuenta',array[]::text[],'Every vote counts.',5),
  (v_l2,'multiple_choice','What follows "no creo que"?','subjunctive',array['preterite','imperfect','indicative'],'subjunctive',1),
  (v_l2,'fill_blank','Complete: "No creo que ____" (it''s - subj)','sea',array['es','era','será'],'be (subj)',2),
  (v_l2,'multiple_choice','What does "oponerse a" mean?','to oppose','to agree with','to support','to ignore','to oppose',3),
  (v_l2,'listening','What did you hear?','No creo que sea justa para todos',array['Creo que esa ley es justa','Pues no estamos de acuerdo','Se oponen a la ley'],'I don''t think it''s fair for everyone',4),
  (v_l2,'speaking','Say this aloud: "No creo que sea justo."','No creo que sea justo',array[]::text[],'I don''t think it''s fair.',5),
  (v_l3,'multiple_choice','What is "proposal"?','la propuesta',array['el debate','el impuesto','la reforma'],'proposal',1),
  (v_l3,'fill_blank','Complete: "Hace falta una ____" (reform)','reforma',array['propuesta','impuesto','debate'],'reform',2),
  (v_l3,'multiple_choice','What does "impuestos" mean?','taxes',array['proposals','reforms','debates'],'taxes',3),
  (v_l3,'listening','What did you hear?','¿Viste el debate de anoche?',array['Hace falta una reforma profunda','La propuesta fue polémica','Subirán los impuestos'],'Did you see last night''s debate?',4),
  (v_l3,'speaking','Say this aloud: "Hace falta una reforma."','Hace falta una reforma',array[]::text[],'A reform is needed.',5),
  (v_l4,'multiple_choice','What is "campaign"?','la campaña',array['la encuesta','la candidata','el discurso'],'campaign',1),
  (v_l4,'fill_blank','Complete: "____ bajar los impuestos." (she promised)','Prometió',array['Prometo','Prometía','Prometerá'],'she promised',2),
  (v_l4,'multiple_choice','What does "encuesta" mean?','poll',array['debate','speech','vote'],'poll',3),
  (v_l4,'listening','What did you hear?','La candidata Pérez ganó el debate de anoche',array['Según la última encuesta','En su discurso prometió','La campaña terminó ayer'],'Candidate Pérez won last night''s debate',4),
  (v_l4,'speaking','Say this aloud: "Prometió una reforma fiscal."','Prometió una reforma fiscal',array[]::text[],'She promised tax reform.',5),
  (v_l5,'multiple_choice','How to say "in my opinion"?','En mi opinión',array['Me preocupa','Votaría por','El cambio'],'in my opinion',1),
  (v_l5,'fill_blank','Complete: "____ el desempleo." (it worries me)','Me preocupa',array['Me gusta','Me cae bien','Me importa'],'it worries me',2),
  (v_l5,'multiple_choice','What does "votaría" mean?','I would vote',array['I voted','I vote','I''ll vote'],'I would vote',3),
  (v_l5,'listening','What did you hear?','En mi opinión, necesitamos un cambio',array['Me preocupa el desempleo','Votaría por un cambio','Necesitamos un cambio'],'In my opinion, we need change',4),
  (v_l5,'speaking','Say this aloud: "Me preocupa el desempleo."','Me preocupa el desempleo',array[]::text[],'Unemployment worries me.',5),
  (v_l6,'multiple_choice','What is "turnout"?','la participación',array['la abstención','la urna','el ciudadano'],'turnout',1),
  (v_l6,'fill_blank','Complete: "Mucha gente se ____" (abstained)','abstuvo',array['votó','prometió','participó'],'abstained',2),
  (v_l6,'multiple_choice','What does "las urnas" mean?','ballot boxes',array['voters','votes','candidates'],'ballot boxes',3),
  (v_l6,'listening','What did you hear?','La participación alcanzó el 75%',array['Dos de cada diez se abstuvieron','Las urnas reflejaron un país dividido','Cada ciudadano tiene voto'],'Turnout reached 75%',4),
  (v_l6,'speaking','Say this aloud: "Cada ciudadano tiene voto."','Cada ciudadano tiene voto',array[]::text[],'Every citizen has a vote.',5),
  (v_l7,'multiple_choice','How to say "on the other hand"?','por otro lado',array['por un lado','a favor de','en contra de'],'on the other hand',1),
  (v_l7,'fill_blank','Complete: "Estoy ____ de la reforma." (in favour of)','a favor',array['en contra','sin duda','por otro lado'],'in favour of',2),
  (v_l7,'multiple_choice','What does "en contra de" mean?','against',array['in favour of','on the other hand','in my opinion'],'against',3),
  (v_l7,'listening','What did you hear?','Por un lado, mejora la formación',array['Estoy a favor de la nueva ley','Por otro lado sube los impuestos','El beneficio compensa el coste'],'On one hand, it improves training',4),
  (v_l7,'speaking','Say this aloud: "Estoy a favor de la reforma."','Estoy a favor de la reforma',array[]::text[],'I''m in favour of the reform.',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','El gobierno aprobó una ley',array['Es del partido conservador','Las elecciones son en mayo','Cada voto cuenta'],'The government passed a law',6),
  (v_l1,'listening','What did you hear?','Es del partido conservador',array['El gobierno aprobó','Las elecciones son en mayo','Cada voto cuenta'],'He''s from the conservative party',7),
  (v_l1,'speaking','Say this aloud: "El gobierno aprobó una ley."','El gobierno aprobó una ley',array[]::text[],'The government passed a law.',8),
  (v_l1,'speaking','Say this aloud: "Las elecciones son en mayo."','Las elecciones son en mayo',array[]::text[],'Elections are in May.',9),
  (v_l2,'listening','What did you hear?','Estoy de acuerdo contigo',array['Creo que es justo','No creo que sea justa','Se oponen a la ley'],'I agree with you',6),
  (v_l2,'listening','What did you hear?','Se oponen a la ley',array['Estoy de acuerdo','Creo que es justo','Pues no estamos'],'They oppose the law',7),
  (v_l2,'speaking','Say this aloud: "Estoy de acuerdo contigo."','Estoy de acuerdo contigo',array[]::text[],'I agree with you.',8),
  (v_l2,'speaking','Say this aloud: "Se oponen a la ley."','Se oponen a la ley',array[]::text[],'They oppose the law.',9),
  (v_l3,'listening','What did you hear?','Subirán los impuestos',array['El debate fue acalorado','La propuesta no convence','Hace falta una reforma'],'They''ll raise taxes',6),
  (v_l3,'listening','What did you hear?','La propuesta sobre los impuestos fue lo más polémico',array['Subirán los impuestos','¿Viste el debate?','Hace falta una reforma'],'The tax proposal was the most controversial part',7),
  (v_l3,'speaking','Say this aloud: "El debate fue acalorado."','El debate fue acalorado',array[]::text[],'The debate was heated.',8),
  (v_l3,'speaking','Say this aloud: "La propuesta no convence."','La propuesta no convence',array[]::text[],'The proposal isn''t convincing.',9),
  (v_l6,'listening','What did you hear?','Las urnas reflejaron un país dividido',array['La participación alcanzó el 75%','Dos de cada diez se abstuvieron','Cada ciudadano tiene voto'],'The ballot boxes reflected a divided country',6),
  (v_l6,'listening','What did you hear?','Acuden a las urnas',array['La participación alcanzó','Mucha gente se abstuvo','Las urnas reflejaron'],'They go to the ballot box',7),
  (v_l6,'speaking','Say this aloud: "La participación fue alta."','La participación fue alta',array[]::text[],'Turnout was high.',8),
  (v_l6,'speaking','Say this aloud: "Mucha gente se abstuvo."','Mucha gente se abstuvo',array[]::text[],'Many people abstained.',9),
  (v_l7,'listening','What did you hear?','En mi opinión, el beneficio compensa el coste',array['Estoy a favor de la nueva ley','Por un lado, mejora la formación','Por otro lado sube los impuestos'],'In my opinion, the benefit outweighs the cost',6),
  (v_l7,'listening','What did you hear?','Estoy en contra de subir impuestos',array['Estoy a favor de la reforma','Por otro lado es injusto','Por un lado es necesario'],'I''m against raising taxes',7),
  (v_l7,'speaking','Say this aloud: "Por un lado es necesario, por otro lado es caro."','Por un lado es necesario, por otro lado es caro',array[]::text[],'On one hand it''s necessary, on the other it''s expensive.',8),
  (v_l7,'speaking','Say this aloud: "Estoy en contra de subir los impuestos."','Estoy en contra de subir los impuestos',array[]::text[],'I''m against raising taxes.',9);

  update public.lessons set type='conversation', title='Politics Basics — Conversation Practice',
    description='Two friends discuss a controversial new law.',
    intro='Ana and Luis disagree about a new education reform.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Ana","spanish":"¿Viste el debate sobre la nueva reforma educativa?","english":"Did you see the debate about the new education reform?"},{"speaker":"Luis","spanish":"Sí. Creo que es necesaria.","english":"Yes. I think it''s necessary."},{"speaker":"Ana","spanish":"No creo que sea justa para todos. Subirá los impuestos.","english":"I don''t think it''s fair for everyone. It''ll raise taxes."},{"speaker":"Luis","spanish":"Por un lado, sí. Por otro lado, mejorará la educación.","english":"On one hand, yes. On the other, it''ll improve education."},{"speaker":"Ana","spanish":"Me preocupa la clase media.","english":"The middle class worries me."},{"speaker":"Luis","spanish":"Pues no estamos de acuerdo. Pero respeto tu opinión.","english":"Well, we don''t agree. But I respect your opinion."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','What is the debate about?','Education reform',array['Tax reform','Election','Foreign policy'],'la nueva reforma educativa',1),
  (v_l8,'multiple_choice','What''s Luis''s view?','It''s necessary',array['It''s unfair','He hasn''t decided','He''s against it'],'Creo que es necesaria',2),
  (v_l8,'multiple_choice','Ana''s concern?','The middle class',array['Children','Teachers','Tax revenue'],'Me preocupa la clase media',3),
  (v_l8,'multiple_choice','True or false: They agree at the end.','False',array['True'],'no estamos de acuerdo',4),
  (v_l8,'fill_blank','Complete: "No creo que ____ justa." (it''s - subj)','sea',array['es','era','será'],'be (subj)',5),
  (v_l8,'multiple_choice','How does Luis end the conversation?','Respecting her opinion',array['Insulting her','Walking away','Changing his mind'],'respeto tu opinión',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Politics Basics', 'Review test for the Politics Basics section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "elections"?','las elecciones',array['el voto','el partido','el gobierno'],'elections',1),
  (v_lesson_id,'multiple_choice','"No creo que" triggers...','subjunctive',array['indicative','imperfect','preterite'],'subjunctive',2),
  (v_lesson_id,'multiple_choice','What does "abstenerse" mean?','to abstain',array['to vote','to win','to debate'],'to abstain',3),
  (v_lesson_id,'multiple_choice','True/false: "Me preocupa" works like gustar.','True',array['False'],'me preocupa X = X worries me',4),
  (v_lesson_id,'fill_blank','Complete: "Hace ____ una reforma." (it''s needed)','falta',array['mucho','poco','tiempo'],'hace falta',5),
  (v_lesson_id,'fill_blank','Complete: "Por un ____" (hand)','lado',array['mano','sitio','tiempo'],'on one hand',6),
  (v_lesson_id,'listening','What did you hear?','Cada voto cuenta',array['Las elecciones son en mayo','El gobierno aprobó una ley','¿A qué partido apoyas?'],'Every vote counts',7),
  (v_lesson_id,'listening','What did you hear?','Estoy a favor de la reforma',array['Por un lado es necesario','En mi opinión','Me preocupa el desempleo'],'I''m in favour of the reform',8),
  (v_lesson_id,'speaking','Say this aloud: "No creo que sea justo."','No creo que sea justo',array[]::text[],'I don''t think it''s fair.',9),
  (v_lesson_id,'speaking','Say this aloud: "Por un lado es necesario."','Por un lado es necesario',array[]::text[],'On one hand it''s necessary.',10);

  -- ===========================================================
  -- B1.9 FOOD & COOKING
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B1' and title = 'Food & Cooking';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set intro='Cooking-related vocabulary.',
    vocab_items='[{"word":"la receta","phonetic":"[rreh-SEH-tah]","english":"recipe","example_es":"Esta receta es de mi abuela.","example_en":"This recipe is from my grandmother."},{"word":"el ingrediente","phonetic":"[een-greh-DYEHN-teh]","english":"ingredient","example_es":"Necesito tres ingredientes.","example_en":"I need three ingredients."},{"word":"picar","phonetic":"[pee-KAR]","english":"to chop","example_es":"Pica la cebolla fina.","example_en":"Chop the onion finely."},{"word":"freír","phonetic":"[freh-EER]","english":"to fry","example_es":"Frío el pescado en aceite.","example_en":"I fry the fish in oil."}]'::jsonb,
    dialogue='[{"speaker":"Pablo","spanish":"¿Conoces esta receta?","english":"Do you know this recipe?"},{"speaker":"Eva","spanish":"Sí, es muy fácil. Picas la cebolla, fríes el pescado.","english":"Yes, very easy. You chop the onion, fry the fish."},{"speaker":"Pablo","spanish":"¿Cuántos ingredientes lleva?","english":"How many ingredients does it have?"}]'::jsonb,
    grammar_note='Recipe Spanish uses tú-form imperative or infinitive: "pica" (chop) or "picar" (to chop). Both are acceptable in written recipes.'
  where id = v_l1;
  update public.lessons set intro='Imperatives in cooking.',
    vocab_items='[{"word":"añade","phonetic":"[ah-NYAH-deh]","english":"add (you)","example_es":"Añade sal al gusto.","example_en":"Add salt to taste."},{"word":"mezcla","phonetic":"[MEHS-klah]","english":"mix (you)","example_es":"Mezcla todo bien.","example_en":"Mix everything well."},{"word":"hierve","phonetic":"[YEHR-beh]","english":"boil (you)","example_es":"Hierve el agua diez minutos.","example_en":"Boil the water ten minutes."},{"word":"deja reposar","phonetic":"[DEH-hah rreh-poh-SAR]","english":"let rest","example_es":"Deja reposar la masa una hora.","example_en":"Let the dough rest one hour."}]'::jsonb,
    dialogue='[{"speaker":"Madre","spanish":"Primero añade la harina.","english":"First add the flour."},{"speaker":"Hija","spanish":"¿Y luego?","english":"And then?"},{"speaker":"Madre","spanish":"Mezcla todo y deja reposar la masa.","english":"Mix everything and let the dough rest."}]'::jsonb,
    grammar_note='Affirmative tú imperative: drop the s from the regular present tense. "tú añades" → "añade", "tú mezclas" → "mezcla".'
  where id = v_l2;
  update public.lessons set intro='Phrases for restaurants and kitchens.',
    vocab_items='[{"word":"está en su punto","phonetic":"[ehs-TAH ehn soo POON-toh]","english":"it''s just right","example_es":"El filete está en su punto.","example_en":"The steak is just right."},{"word":"al gusto","phonetic":"[ahl GOOS-toh]","english":"to taste","example_es":"Sal y pimienta al gusto.","example_en":"Salt and pepper to taste."},{"word":"se me ha quemado","phonetic":"[seh meh ah keh-MAH-doh]","english":"I burnt it","example_es":"Se me ha quemado la pasta.","example_en":"I burnt the pasta."},{"word":"sabe bien","phonetic":"[SAH-beh byehn]","english":"it tastes good","example_es":"Sabe bien sin sal.","example_en":"It tastes good without salt."}]'::jsonb,
    dialogue='[{"speaker":"Cliente","spanish":"Está delicioso. ¿Está al punto?","english":"It''s delicious. Is it just right?"},{"speaker":"Chef","spanish":"Sí, lo cocino siempre así.","english":"Yes, I always cook it this way."},{"speaker":"Cliente","spanish":"Una pizca de sal más y perfecto.","english":"A pinch more salt and it''s perfect."}]'::jsonb,
    grammar_note='"Se me + verb" = unplanned action: "se me ha quemado" = "it got burned on me". A common dative-of-misfortune construction.'
  where id = v_l3;
  update public.lessons set intro='Listen to a cooking show.',
    vocab_items='[{"word":"el sartén","phonetic":"[sahr-TEHN]","english":"frying pan","example_es":"Calienta el sartén.","example_en":"Heat the frying pan."},{"word":"la olla","phonetic":"[OH-yah]","english":"pot","example_es":"En la olla hierve el caldo.","example_en":"In the pot the broth boils."},{"word":"el horno","phonetic":"[OHR-noh]","english":"oven","example_es":"Precalienta el horno.","example_en":"Preheat the oven."},{"word":"a fuego lento","phonetic":"[ah FWEH-goh LEHN-toh]","english":"on low heat","example_es":"Cocina a fuego lento.","example_en":"Cook on low heat."}]'::jsonb,
    dialogue='[{"speaker":"Chef TV","spanish":"Hoy preparamos paella valenciana.","english":"Today we prepare Valencian paella."},{"speaker":"Chef TV","spanish":"Calienta el sartén con aceite y añade el sofrito.","english":"Heat the frying pan with oil and add the sofrito."},{"speaker":"Chef TV","spanish":"Después, cocina a fuego lento durante media hora.","english":"Then cook on low heat for half an hour."}]'::jsonb,
    grammar_note='Cooking instructions use a mix of imperatives and impersonal "se + 3rd person": "se añade", "se hierve" — both correct.'
  where id = v_l4;
  update public.lessons set intro='Speak about your cooking habits.',
    vocab_items='[{"word":"Cocino casi todos los días","phonetic":"[koh-SEE-noh]","english":"I cook almost every day","example_es":"Cocino casi todos los días en casa.","example_en":"I cook at home almost every day."},{"word":"Mi plato favorito","phonetic":"[mee PLAH-toh]","english":"My favourite dish","example_es":"Mi plato favorito es la tortilla.","example_en":"My favourite dish is the omelette."},{"word":"No soy muy bueno cocinando","phonetic":"[noh SOY mwee BWEH-noh]","english":"I''m not great at cooking","example_es":"No soy muy bueno cocinando, pero intento.","example_en":"I''m not great at cooking, but I try."},{"word":"Suelo improvisar","phonetic":"[SWEH-loh een-proh-bee-SAR]","english":"I usually improvise","example_es":"Suelo improvisar con lo que hay.","example_en":"I usually improvise with what I have."}]'::jsonb,
    dialogue='[{"speaker":"Tú","spanish":"Cocino casi todos los días.","english":"I cook almost every day."},{"speaker":"Amigo","spanish":"¿Tienes algún plato favorito?","english":"Do you have a favourite dish?"},{"speaker":"Tú","spanish":"La tortilla de patatas. Suelo improvisar con lo que hay.","english":"Potato omelette. I usually improvise with what I have."}]'::jsonb,
    grammar_note='"Lo que hay" = "what there is". Common construction: "lo que hay en la nevera" = "what''s in the fridge".'
  where id = v_l5;
  update public.lessons set intro='Read a short recipe blog post.',
    vocab_items='[{"word":"casero","phonetic":"[kah-SEH-roh]","english":"homemade","example_es":"Pan casero, recién hecho.","example_en":"Homemade bread, fresh."},{"word":"el truco","phonetic":"[TROO-koh]","english":"the trick","example_es":"El truco está en el aceite.","example_en":"The trick is in the oil."},{"word":"crujiente","phonetic":"[kroo-HYEHN-teh]","english":"crispy","example_es":"Queda muy crujiente.","example_en":"It comes out very crispy."},{"word":"riquísimo","phonetic":"[rree-KEE-see-moh]","english":"delicious","example_es":"Está riquísimo.","example_en":"It''s delicious."}]'::jsonb,
    dialogue='[{"speaker":"Blog","spanish":"Esta receta de pan casero es la favorita de mi familia.","english":"This homemade bread recipe is my family''s favourite."},{"speaker":"Blog","spanish":"El truco está en dejar reposar la masa durante una hora.","english":"The trick is letting the dough rest for an hour."},{"speaker":"Blog","spanish":"Queda crujiente por fuera y blando por dentro.","english":"It comes out crispy on the outside and soft on the inside."}]'::jsonb,
    grammar_note='"-ísimo" superlative suffix: rico → riquísimo (very tasty), bueno → buenísimo (very good). A B1 essential.'
  where id = v_l6;
  update public.lessons set intro='Write your own recipe.',
    vocab_items='[{"word":"se necesitan","phonetic":"[seh neh-seh-SEE-tahn]","english":"are needed","example_es":"Se necesitan tres huevos.","example_en":"Three eggs are needed."},{"word":"primero","phonetic":"[pree-MEH-roh]","english":"first","example_es":"Primero pica la cebolla.","example_en":"First chop the onion."},{"word":"a continuación","phonetic":"[ah kohn-tee-nwah-SYOHN]","english":"next","example_es":"A continuación, añade el aceite.","example_en":"Next, add the oil."},{"word":"finalmente","phonetic":"[fee-nahl-MEHN-teh]","english":"finally","example_es":"Finalmente, sirve caliente.","example_en":"Finally, serve hot."}]'::jsonb,
    dialogue='[{"speaker":"Modelo","spanish":"Para hacer tortilla, se necesitan tres huevos y dos patatas.","english":"To make a tortilla, three eggs and two potatoes are needed."},{"speaker":"Modelo","spanish":"Primero pica las patatas y fríelas. A continuación, mezcla los huevos.","english":"First chop the potatoes and fry them. Next, beat the eggs."},{"speaker":"Modelo","spanish":"Finalmente, mezcla todo y cocina cinco minutos por cada lado.","english":"Finally, mix everything and cook five minutes on each side."}]'::jsonb,
    grammar_note='Sequence markers organize a recipe paragraph: primero, después/luego, a continuación, finalmente. All B1 high-frequency.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "recipe"?','la receta',array['el ingrediente','el plato','la cocina'],'recipe',1),
  (v_l1,'fill_blank','Complete: "____ la cebolla fina." (chop)','Pica',array['Fríe','Hierve','Mezcla'],'chop',2),
  (v_l1,'multiple_choice','What does "freír" mean?','to fry',array['to boil','to bake','to mix'],'to fry',3),
  (v_l1,'listening','What did you hear?','Esta receta es de mi abuela',array['Necesito tres ingredientes','Pica la cebolla fina','Frío el pescado en aceite'],'This recipe is from my grandmother',4),
  (v_l1,'speaking','Say this aloud: "Esta receta es muy fácil."','Esta receta es muy fácil',array[]::text[],'This recipe is very easy.',5),
  (v_l2,'multiple_choice','How to say "mix" (you)?','mezcla',array['hierve','añade','deja'],'mix (you)',1),
  (v_l2,'fill_blank','Complete: "____ reposar la masa." (let)','Deja',array['Pica','Fríe','Hierve'],'let',2),
  (v_l2,'multiple_choice','What does "añade" mean?','add (you)',array['mix','boil','rest'],'add (you)',3),
  (v_l2,'listening','What did you hear?','Primero añade la harina',array['Mezcla todo y deja reposar','Hierve el agua diez minutos','Y luego'],'First add the flour',4),
  (v_l2,'speaking','Say this aloud: "Mezcla todo bien."','Mezcla todo bien',array[]::text[],'Mix everything well.',5),
  (v_l3,'multiple_choice','How to say "it''s just right"?','está en su punto',array['está al gusto','sabe bien','se me ha quemado'],'it''s just right',1),
  (v_l3,'fill_blank','Complete: "Sal y pimienta al ____" (taste)','gusto',array['punto','toque','sabor'],'taste',2),
  (v_l3,'multiple_choice','What does "se me ha quemado" mean?','I burnt it',array['I cooked it','I cleaned it','I served it'],'I burnt it',3),
  (v_l3,'listening','What did you hear?','Una pizca de sal más y perfecto',array['El filete está en su punto','Sabe bien sin sal','Se me ha quemado la pasta'],'A pinch more salt and it''s perfect',4),
  (v_l3,'speaking','Say this aloud: "Se me ha quemado la pasta."','Se me ha quemado la pasta',array[]::text[],'I burnt the pasta.',5),
  (v_l4,'multiple_choice','What is "frying pan"?','el sartén',array['la olla','el horno','el plato'],'frying pan',1),
  (v_l4,'fill_blank','Complete: "Cocina a ____ lento." (heat)','fuego',array['horno','olla','sartén'],'heat',2),
  (v_l4,'multiple_choice','What does "precalienta" mean?','preheat',array['turn off','wash','clean'],'preheat',3),
  (v_l4,'listening','What did you hear?','Cocina a fuego lento durante media hora',array['Calienta el sartén con aceite','Hoy preparamos paella','Añade el sofrito'],'Cook on low heat for half an hour',4),
  (v_l4,'speaking','Say this aloud: "Calienta el sartén con aceite."','Calienta el sartén con aceite',array[]::text[],'Heat the frying pan with oil.',5),
  (v_l5,'multiple_choice','How to say "I usually improvise"?','Suelo improvisar',array['Cocino casi todos los días','Mi plato favorito','No soy muy bueno'],'I usually improvise',1),
  (v_l5,'fill_blank','Complete: "Suelo improvisar con ____ hay." (what)','lo que',array['eso que','algo que','nada que'],'what there is',2),
  (v_l5,'multiple_choice','What does "No soy muy bueno cocinando" mean?','I''m not great at cooking',array['I love cooking','I''m a chef','I never cook'],'I''m not great at cooking',3),
  (v_l5,'listening','What did you hear?','Mi plato favorito es la tortilla',array['Cocino casi todos los días','No soy muy bueno cocinando','Suelo improvisar con lo que hay'],'My favourite dish is the omelette',4),
  (v_l5,'speaking','Say this aloud: "Cocino casi todos los días."','Cocino casi todos los días',array[]::text[],'I cook almost every day.',5),
  (v_l6,'multiple_choice','What is "homemade"?','casero',array['casual','riquísimo','crujiente'],'homemade',1),
  (v_l6,'fill_blank','Complete: "Está ____" (delicious)','riquísimo',array['casero','crujiente','blando'],'delicious',2),
  (v_l6,'multiple_choice','What does "el truco" mean?','the trick',array['the secret','the method','the result'],'the trick',3),
  (v_l6,'listening','What did you hear?','Queda crujiente por fuera y blando por dentro',array['Esta receta es la favorita de mi familia','El truco está en dejar reposar','Está riquísimo'],'It comes out crispy on the outside and soft on the inside',4),
  (v_l6,'speaking','Say this aloud: "El truco está en el aceite."','El truco está en el aceite',array[]::text[],'The trick is in the oil.',5),
  (v_l7,'multiple_choice','How to say "are needed"?','se necesitan',array['se necesita','se necesite','se necesitando'],'are needed',1),
  (v_l7,'fill_blank','Complete: "A ____, añade el aceite." (next)','continuación',array['principio','final','seguir'],'next',2),
  (v_l7,'multiple_choice','What does "finalmente" mean?','finally',array['first','next','suddenly'],'finally',3),
  (v_l7,'listening','What did you hear?','Para hacer tortilla, se necesitan tres huevos y dos patatas',array['Primero pica las patatas y fríelas','A continuación mezcla los huevos','Finalmente, mezcla todo'],'To make a tortilla, three eggs and two potatoes are needed',4),
  (v_l7,'speaking','Say this aloud: "Finalmente, sirve caliente."','Finalmente, sirve caliente',array[]::text[],'Finally, serve hot.',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Pica la cebolla fina',array['Esta receta es muy fácil','Necesito tres ingredientes','Frío el pescado en aceite'],'Chop the onion finely',6),
  (v_l1,'listening','What did you hear?','Frío el pescado en aceite',array['Picas la cebolla','Esta receta es de mi abuela','Necesito tres ingredientes'],'I fry the fish in oil',7),
  (v_l1,'speaking','Say this aloud: "Pica la cebolla fina."','Pica la cebolla fina',array[]::text[],'Chop the onion finely.',8),
  (v_l1,'speaking','Say this aloud: "Necesito tres ingredientes."','Necesito tres ingredientes',array[]::text[],'I need three ingredients.',9),
  (v_l2,'listening','What did you hear?','Hierve el agua diez minutos',array['Añade sal al gusto','Mezcla todo bien','Deja reposar la masa'],'Boil the water ten minutes',6),
  (v_l2,'listening','What did you hear?','Mezcla todo y deja reposar la masa',array['Primero añade la harina','¿Y luego?','Hierve el agua diez minutos'],'Mix everything and let the dough rest',7),
  (v_l2,'speaking','Say this aloud: "Añade sal al gusto."','Añade sal al gusto',array[]::text[],'Add salt to taste.',8),
  (v_l2,'speaking','Say this aloud: "Hierve el agua diez minutos."','Hierve el agua diez minutos',array[]::text[],'Boil the water ten minutes.',9),
  (v_l3,'listening','What did you hear?','El filete está en su punto',array['Sabe bien sin sal','Se me ha quemado la pasta','Una pizca de sal'],'The steak is just right',6),
  (v_l3,'listening','What did you hear?','Sabe bien sin sal',array['El filete está en su punto','Se me ha quemado','Una pizca de sal'],'It tastes good without salt',7),
  (v_l3,'speaking','Say this aloud: "Sabe bien sin sal."','Sabe bien sin sal',array[]::text[],'It tastes good without salt.',8),
  (v_l3,'speaking','Say this aloud: "El filete está en su punto."','El filete está en su punto',array[]::text[],'The steak is just right.',9),
  (v_l6,'listening','What did you hear?','El truco está en dejar reposar la masa',array['Esta receta es la favorita','Queda crujiente por fuera','Está riquísimo'],'The trick is letting the dough rest',6),
  (v_l6,'listening','What did you hear?','Esta receta de pan casero es la favorita de mi familia',array['El truco está en el aceite','Queda crujiente por fuera','Está riquísimo'],'This homemade bread recipe is my family''s favourite',7),
  (v_l6,'speaking','Say this aloud: "Queda crujiente por fuera."','Queda crujiente por fuera',array[]::text[],'It comes out crispy on the outside.',8),
  (v_l6,'speaking','Say this aloud: "Está riquísimo."','Está riquísimo',array[]::text[],'It''s delicious.',9),
  (v_l7,'listening','What did you hear?','Primero pica las patatas y fríelas',array['A continuación mezcla los huevos','Finalmente mezcla todo','Se necesitan tres huevos'],'First chop the potatoes and fry them',6),
  (v_l7,'listening','What did you hear?','Finalmente, mezcla todo y cocina cinco minutos por cada lado',array['Primero pica las patatas','A continuación, añade el aceite','Se necesitan tres huevos'],'Finally, mix everything and cook five minutes on each side',7),
  (v_l7,'speaking','Say this aloud: "Primero pica la cebolla."','Primero pica la cebolla',array[]::text[],'First chop the onion.',8),
  (v_l7,'speaking','Say this aloud: "Se necesitan tres huevos y dos patatas."','Se necesitan tres huevos y dos patatas',array[]::text[],'Three eggs and two potatoes are needed.',9);

  update public.lessons set type='conversation', title='Food & Cooking — Conversation Practice',
    description='A friend asks for a family recipe.',
    intro='Pablo asks Eva for her abuela''s tortilla recipe. Listen for cooking verbs.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Pablo","spanish":"¿Me das la receta de la tortilla de tu abuela?","english":"Can you give me your grandmother''s tortilla recipe?"},{"speaker":"Eva","spanish":"Claro. Se necesitan tres huevos y dos patatas.","english":"Sure. Three eggs and two potatoes are needed."},{"speaker":"Pablo","spanish":"¿Cómo se hace?","english":"How is it made?"},{"speaker":"Eva","spanish":"Primero pica las patatas en rodajas finas. A continuación, fríelas a fuego lento.","english":"First chop the potatoes into thin slices. Next, fry them on low heat."},{"speaker":"Pablo","spanish":"¿Y luego?","english":"And then?"},{"speaker":"Eva","spanish":"Mezcla con los huevos. Finalmente, cocina cinco minutos por cada lado. ¡Queda riquísima!","english":"Mix with the eggs. Finally, cook five minutes on each side. It''s delicious!"}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','How many eggs are needed?','3',array['2','4','5'],'Se necesitan tres huevos',1),
  (v_l8,'multiple_choice','How many potatoes?','2',array['3','4','1'],'dos patatas',2),
  (v_l8,'multiple_choice','How should you cut the potatoes?','In thin slices',array['In cubes','In strips','Whole'],'en rodajas finas',3),
  (v_l8,'multiple_choice','True or false: Cook on high heat.','False',array['True'],'a fuego lento',4),
  (v_l8,'fill_blank','Complete: "____ cinco minutos por cada lado." (cook)','cocina',array['pica','mezcla','fríe'],'cook',5),
  (v_l8,'multiple_choice','Eva''s closing description?','Delicious',array['Healthy','Easy','Hard'],'¡Queda riquísima!',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Food & Cooking', 'Review test for the Food & Cooking section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "recipe"?','la receta',array['el plato','la receta','el truco'],'recipe',1),
  (v_lesson_id,'multiple_choice','Imperative "chop" (tú)?','pica',array['picas','picar','picaba'],'chop (tú)',2),
  (v_lesson_id,'multiple_choice','What does "a fuego lento" mean?','on low heat',array['on high heat','quickly','slowly mixing'],'on low heat',3),
  (v_lesson_id,'multiple_choice','True/false: "se me ha quemado" = I burnt it (unplanned).','True',array['False'],'dative of misfortune',4),
  (v_lesson_id,'fill_blank','Complete: "Sal al ____" (taste)','gusto',array['punto','sabor','toque'],'to taste',5),
  (v_lesson_id,'fill_blank','Complete: "Está rico" → emphatic "very tasty" = "____" ','riquísimo',array['riquísima','rica','muy rica'],'-ísimo suffix',6),
  (v_lesson_id,'listening','What did you hear?','Pica la cebolla fina',array['Frío el pescado','Mezcla todo','Hierve el agua'],'Chop the onion finely',7),
  (v_lesson_id,'listening','What did you hear?','Finalmente, sirve caliente',array['Primero pica las patatas','A continuación, añade el aceite','Se necesitan tres huevos'],'Finally, serve hot',8),
  (v_lesson_id,'speaking','Say this aloud: "Mezcla todo bien."','Mezcla todo bien',array[]::text[],'Mix everything well.',9),
  (v_lesson_id,'speaking','Say this aloud: "Cocina a fuego lento."','Cocina a fuego lento',array[]::text[],'Cook on low heat.',10);

  -- ===========================================================
  -- B1.10 ART & LITERATURE
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B1' and title = 'Art & Literature';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set intro='Art and book vocabulary.',
    vocab_items='[{"word":"el cuadro","phonetic":"[KWAH-droh]","english":"painting","example_es":"Este cuadro es de Velázquez.","example_en":"This painting is by Velázquez."},{"word":"la novela","phonetic":"[noh-BEH-lah]","english":"novel","example_es":"Leí una novela fantástica.","example_en":"I read a fantastic novel."},{"word":"el autor","phonetic":"[ow-TOHR]","english":"author","example_es":"El autor escribió diez libros.","example_en":"The author wrote ten books."},{"word":"la obra","phonetic":"[OH-brah]","english":"work","example_es":"Su obra es muy reconocida.","example_en":"His work is highly regarded."}]'::jsonb,
    dialogue='[{"speaker":"Eva","spanish":"¿Qué libro estás leyendo?","english":"What book are you reading?"},{"speaker":"Pablo","spanish":"Una novela del autor argentino Borges.","english":"A novel by the Argentine author Borges."},{"speaker":"Eva","spanish":"Su obra es muy compleja.","english":"His work is very complex."}]'::jsonb,
    grammar_note='Authors keep masculine article even if female writes them: "una novela del autor / de la autora". Match gender.'
  where id = v_l1;
  update public.lessons set intro='Talking about books with the present perfect.',
    vocab_items='[{"word":"he leído","phonetic":"[eh leh-EE-doh]","english":"I''ve read","example_es":"He leído todos sus libros.","example_en":"I''ve read all his books."},{"word":"me ha gustado","phonetic":"[meh ah goos-TAH-doh]","english":"I''ve liked it","example_es":"Me ha gustado mucho.","example_en":"I''ve liked it a lot."},{"word":"recomendar","phonetic":"[rreh-koh-mehn-DAR]","english":"to recommend","example_es":"Te lo recomiendo.","example_en":"I recommend it to you."},{"word":"el premio","phonetic":"[PREH-myoh]","english":"prize","example_es":"Ganó el premio Nobel.","example_en":"He won the Nobel Prize."}]'::jsonb,
    dialogue='[{"speaker":"Marta","spanish":"¿Has leído algo de García Márquez?","english":"Have you read anything by García Márquez?"},{"speaker":"Luis","spanish":"He leído Cien años de soledad. Me ha gustado mucho.","english":"I''ve read One Hundred Years of Solitude. I really liked it."},{"speaker":"Marta","spanish":"Te recomiendo también Crónica de una muerte anunciada.","english":"I also recommend Chronicle of a Death Foretold."}]'::jsonb,
    grammar_note='Present perfect (he leído) — for life experience and recent past. Differs from preterite (leí) which marks a specific completed event.'
  where id = v_l2;
  update public.lessons set intro='Phrases for galleries and bookshops.',
    vocab_items='[{"word":"la exposición","phonetic":"[ehks-poh-see-SYOHN]","english":"exhibition","example_es":"La exposición termina el lunes.","example_en":"The exhibition ends on Monday."},{"word":"la galería","phonetic":"[gah-leh-REE-ah]","english":"gallery","example_es":"En esta galería hay obras de Picasso.","example_en":"This gallery has works by Picasso."},{"word":"agotado","phonetic":"[ah-goh-TAH-doh]","english":"sold out","example_es":"El libro está agotado.","example_en":"The book is sold out."},{"word":"ejemplares","phonetic":"[eh-hehm-PLAH-rehs]","english":"copies","example_es":"Quedan pocos ejemplares.","example_en":"Few copies are left."}]'::jsonb,
    dialogue='[{"speaker":"Cliente","spanish":"¿Tienen ejemplares de la última novela de Vargas Llosa?","english":"Do you have copies of Vargas Llosa''s latest novel?"},{"speaker":"Librero","spanish":"Está agotado, pero llega un envío mañana.","english":"It''s sold out, but a shipment arrives tomorrow."},{"speaker":"Cliente","spanish":"¿Saben de alguna exposición sobre él?","english":"Do you know of any exhibitions about him?"}]'::jsonb,
    grammar_note='"Saber de" = "to know about/of (the existence)". Different from "conocer" (to be familiar with): "¿Sabes de un libro?" vs "¿Conoces ese libro?"'
  where id = v_l3;
  update public.lessons set intro='Listen to a museum audio guide.',
    vocab_items='[{"word":"la pintura al óleo","phonetic":"[peen-TOO-rah ahl OH-leh-oh]","english":"oil painting","example_es":"Es una pintura al óleo.","example_en":"It''s an oil painting."},{"word":"el siglo","phonetic":"[SEE-gloh]","english":"century","example_es":"Del siglo XVII.","example_en":"From the 17th century."},{"word":"el retrato","phonetic":"[rreh-TRAH-toh]","english":"portrait","example_es":"Es un retrato de la familia real.","example_en":"It''s a portrait of the royal family."},{"word":"obra maestra","phonetic":"[OH-brah mah-EHS-trah]","english":"masterpiece","example_es":"Es considerada una obra maestra.","example_en":"It''s considered a masterpiece."}]'::jsonb,
    dialogue='[{"speaker":"Audio","spanish":"A su derecha verán un retrato de Velázquez.","english":"To your right you''ll see a portrait by Velázquez."},{"speaker":"Audio","spanish":"Es una pintura al óleo del siglo diecisiete.","english":"It''s an oil painting from the 17th century."},{"speaker":"Audio","spanish":"Está considerada una obra maestra del Barroco español.","english":"It''s considered a masterpiece of Spanish Baroque."}]'::jsonb,
    grammar_note='Centuries in Spanish use Roman numerals: "siglo XVII" (read "diecisiete"), "siglo XX" (read "veinte").'
  where id = v_l4;
  update public.lessons set intro='Speak about your reading preferences.',
    vocab_items='[{"word":"Me encanta la ficción","phonetic":"[meh ehn-KAHN-tah]","english":"I love fiction","example_es":"Me encanta la ficción contemporánea.","example_en":"I love contemporary fiction."},{"word":"Leí un libro increíble","phonetic":"[leh-EE oon LEE-broh]","english":"I read an incredible book","example_es":"Leí un libro increíble el mes pasado.","example_en":"I read an incredible book last month."},{"word":"Lo leí en una semana","phonetic":"[loh leh-EE]","english":"I read it in a week","example_es":"Lo leí en una semana.","example_en":"I read it in a week."},{"word":"trata de","phonetic":"[TRAH-tah deh]","english":"it''s about","example_es":"Trata de la guerra civil.","example_en":"It''s about the civil war."}]'::jsonb,
    dialogue='[{"speaker":"Tú","spanish":"Leí un libro increíble el mes pasado.","english":"I read an incredible book last month."},{"speaker":"Amigo","spanish":"¿De qué trata?","english":"What''s it about?"},{"speaker":"Tú","spanish":"Trata de la posguerra española. Lo leí en una semana.","english":"It''s about the Spanish post-war. I read it in a week."}]'::jsonb,
    grammar_note='"Tratar DE + topic" = "to be about". Reflexive form "tratarse de" is more formal: "Se trata de un libro sobre..."'
  where id = v_l5;
  update public.lessons set intro='Read about a Spanish-speaking writer.',
    vocab_items='[{"word":"el escritor","phonetic":"[ehs-kree-TOHR]","english":"writer","example_es":"Es un escritor chileno.","example_en":"He''s a Chilean writer."},{"word":"el realismo mágico","phonetic":"[rreh-ah-LEES-moh MAH-hee-koh]","english":"magical realism","example_es":"Es famoso por el realismo mágico.","example_en":"He''s famous for magical realism."},{"word":"publicar","phonetic":"[poo-blee-KAR]","english":"to publish","example_es":"Publicó su primer libro en 1982.","example_en":"He published his first book in 1982."},{"word":"traducido","phonetic":"[trah-doo-SEE-doh]","english":"translated","example_es":"Sus libros están traducidos a treinta idiomas.","example_en":"His books are translated into thirty languages."}]'::jsonb,
    dialogue='[{"speaker":"Texto","spanish":"Isabel Allende es una de las escritoras latinoamericanas más conocidas.","english":"Isabel Allende is one of the best-known Latin American women writers."},{"speaker":"Texto","spanish":"Publicó La casa de los espíritus en 1982, una obra del realismo mágico.","english":"She published The House of the Spirits in 1982, a work of magical realism."},{"speaker":"Texto","spanish":"Sus libros están traducidos a más de treinta idiomas.","english":"Her books are translated into more than thirty languages."}]'::jsonb,
    grammar_note='"Estar + past participle" = passive description: "están traducidos", "está publicado". State, not action.'
  where id = v_l6;
  update public.lessons set intro='Write a short book review.',
    vocab_items='[{"word":"el argumento","phonetic":"[ahr-goo-MEHN-toh]","english":"plot","example_es":"El argumento es complejo.","example_en":"The plot is complex."},{"word":"los personajes","phonetic":"[pehr-soh-NAH-hehs]","english":"characters","example_es":"Los personajes son inolvidables.","example_en":"The characters are unforgettable."},{"word":"engancha","phonetic":"[ehn-GAHN-chah]","english":"it hooks you","example_es":"Engancha desde la primera página.","example_en":"It hooks you from the first page."},{"word":"recomendable","phonetic":"[rreh-koh-mehn-DAH-bleh]","english":"recommendable","example_es":"Es totalmente recomendable.","example_en":"It''s totally recommendable."}]'::jsonb,
    dialogue='[{"speaker":"Modelo","spanish":"Acabo de terminar Cien años de soledad.","english":"I just finished One Hundred Years of Solitude."},{"speaker":"Modelo","spanish":"El argumento es complejo y los personajes inolvidables.","english":"The plot is complex and the characters unforgettable."},{"speaker":"Modelo","spanish":"Engancha desde la primera página. Totalmente recomendable.","english":"It hooks you from the first page. Totally recommendable."}]'::jsonb,
    grammar_note='"Acabar DE + infinitive" = "to have just done". "Acabo de leer" = "I just read". A very common B1 structure.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "novel"?','la novela',array['el cuadro','el autor','la obra'],'novel',1),
  (v_l1,'fill_blank','Complete: "Su ____ es muy reconocida." (work)','obra',array['cuadro','novela','autor'],'work',2),
  (v_l1,'multiple_choice','What does "autor" mean?','author',array['painter','reader','editor'],'author',3),
  (v_l1,'listening','What did you hear?','Una novela del autor argentino Borges',array['Este cuadro es de Velázquez','Su obra es muy compleja','El autor escribió diez libros'],'A novel by the Argentine author Borges',4),
  (v_l1,'speaking','Say this aloud: "El autor escribió diez libros."','El autor escribió diez libros',array[]::text[],'The author wrote ten books.',5),
  (v_l2,'multiple_choice','How to say "I''ve read"?','he leído',array['leía','leeré','leyendo'],'I''ve read',1),
  (v_l2,'fill_blank','Complete: "Me ha ____ mucho." (liked)','gustado',array['gusta','gustaba','gustaría'],'liked',2),
  (v_l2,'multiple_choice','What does "premio" mean?','prize',array['novel','author','copy'],'prize',3),
  (v_l2,'listening','What did you hear?','He leído Cien años de soledad',array['¿Has leído algo?','Me ha gustado mucho','Te recomiendo también'],'I''ve read One Hundred Years of Solitude',4),
  (v_l2,'speaking','Say this aloud: "Te lo recomiendo."','Te lo recomiendo',array[]::text[],'I recommend it to you.',5),
  (v_l3,'multiple_choice','What is "exhibition"?','la exposición',array['la galería','el cuadro','la obra'],'exhibition',1),
  (v_l3,'fill_blank','Complete: "El libro está ____" (sold out)','agotado',array['publicado','traducido','recomendable'],'sold out',2),
  (v_l3,'multiple_choice','What does "ejemplares" mean?','copies',array['authors','exhibitions','galleries'],'copies',3),
  (v_l3,'listening','What did you hear?','Está agotado, pero llega un envío mañana',array['Quedan pocos ejemplares','¿Saben de alguna exposición?','En esta galería hay obras'],'It''s sold out, but a shipment arrives tomorrow',4),
  (v_l3,'speaking','Say this aloud: "¿Tienen ejemplares de la última novela?"','¿Tienen ejemplares de la última novela?',array[]::text[],'Do you have copies of the latest novel?',5),
  (v_l4,'multiple_choice','What is "oil painting"?','la pintura al óleo',array['el retrato','el siglo','la obra maestra'],'oil painting',1),
  (v_l4,'fill_blank','Complete: "Del ____ XVII." (century)','siglo',array['año','día','mes'],'century',2),
  (v_l4,'multiple_choice','What does "obra maestra" mean?','masterpiece',array['portrait','painting','sculpture'],'masterpiece',3),
  (v_l4,'listening','What did you hear?','Es una pintura al óleo del siglo diecisiete',array['A su derecha verán un retrato','Está considerada una obra maestra','Es un retrato de la familia real'],'It''s an oil painting from the 17th century',4),
  (v_l4,'speaking','Say this aloud: "Es considerada una obra maestra."','Es considerada una obra maestra',array[]::text[],'It''s considered a masterpiece.',5),
  (v_l5,'multiple_choice','How to say "I love fiction"?','Me encanta la ficción',array['Leí un libro','Lo leí en una semana','Trata de la guerra'],'I love fiction',1),
  (v_l5,'fill_blank','Complete: "____ de la guerra civil." (it''s about)','Trata',array['Habla','Cuenta','Sucede'],'it''s about',2),
  (v_l5,'multiple_choice','What does "Lo leí en una semana" mean?','I read it in a week',array['I read it last week','I''ll read it in a week','I read it once'],'I read it in a week',3),
  (v_l5,'listening','What did you hear?','Trata de la posguerra española',array['Leí un libro increíble el mes pasado','Lo leí en una semana','¿De qué trata?'],'It''s about the Spanish post-war',4),
  (v_l5,'speaking','Say this aloud: "Lo leí en una semana."','Lo leí en una semana',array[]::text[],'I read it in a week.',5),
  (v_l6,'multiple_choice','What is "magical realism"?','el realismo mágico',array['el escritor','traducido','publicar'],'magical realism',1),
  (v_l6,'fill_blank','Complete: "Sus libros están ____ a treinta idiomas." (translated)','traducidos',array['publicados','escritos','vendidos'],'translated',2),
  (v_l6,'multiple_choice','When did Isabel Allende publish La casa de los espíritus?','1982',array['1975','1990','2000'],'1982',3),
  (v_l6,'listening','What did you hear?','Sus libros están traducidos a más de treinta idiomas',array['Isabel Allende es una de las escritoras','Publicó La casa de los espíritus','Una obra del realismo mágico'],'Her books are translated into more than thirty languages',4),
  (v_l6,'speaking','Say this aloud: "Sus libros están traducidos a treinta idiomas."','Sus libros están traducidos a treinta idiomas',array[]::text[],'Her books are translated into thirty languages.',5),
  (v_l7,'multiple_choice','What is "plot"?','el argumento',array['los personajes','el escritor','la obra'],'plot',1),
  (v_l7,'fill_blank','Complete: "____ desde la primera página." (it hooks)','Engancha',array['Termina','Empieza','Sigue'],'it hooks',2),
  (v_l7,'multiple_choice','What does "acabar de + inf" mean?','to have just done','to finish doing','to start doing','to need to do','to have just done',3),
  (v_l7,'listening','What did you hear?','Engancha desde la primera página',array['Acabo de terminar','El argumento es complejo','Totalmente recomendable'],'It hooks you from the first page',4),
  (v_l7,'speaking','Say this aloud: "Acabo de terminar la novela."','Acabo de terminar la novela',array[]::text[],'I just finished the novel.',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Este cuadro es de Velázquez',array['Su obra es muy compleja','Leí una novela fantástica','El autor escribió diez libros'],'This painting is by Velázquez',6),
  (v_l1,'listening','What did you hear?','Su obra es muy compleja',array['Este cuadro es de Velázquez','Leí una novela','El autor escribió'],'His work is very complex',7),
  (v_l1,'speaking','Say this aloud: "Su obra es muy reconocida."','Su obra es muy reconocida',array[]::text[],'His work is highly regarded.',8),
  (v_l1,'speaking','Say this aloud: "Leí una novela fantástica."','Leí una novela fantástica',array[]::text[],'I read a fantastic novel.',9),
  (v_l2,'listening','What did you hear?','Ganó el premio Nobel',array['He leído todos sus libros','Me ha gustado mucho','Te recomiendo Crónica'],'He won the Nobel Prize',6),
  (v_l2,'listening','What did you hear?','Te recomiendo también Crónica de una muerte anunciada',array['He leído Cien años de soledad','Me ha gustado mucho','Ganó el premio Nobel'],'I also recommend Chronicle of a Death Foretold',7),
  (v_l2,'speaking','Say this aloud: "He leído todos sus libros."','He leído todos sus libros',array[]::text[],'I''ve read all his books.',8),
  (v_l2,'speaking','Say this aloud: "Ganó el premio Nobel."','Ganó el premio Nobel',array[]::text[],'He won the Nobel Prize.',9),
  (v_l3,'listening','What did you hear?','Quedan pocos ejemplares',array['El libro está agotado','En esta galería hay obras de Picasso','La exposición termina el lunes'],'Few copies are left',6),
  (v_l3,'listening','What did you hear?','En esta galería hay obras de Picasso',array['Quedan pocos ejemplares','El libro está agotado','La exposición termina'],'This gallery has works by Picasso',7),
  (v_l3,'speaking','Say this aloud: "La exposición termina el lunes."','La exposición termina el lunes',array[]::text[],'The exhibition ends on Monday.',8),
  (v_l3,'speaking','Say this aloud: "Quedan pocos ejemplares."','Quedan pocos ejemplares',array[]::text[],'Few copies are left.',9),
  (v_l6,'listening','What did you hear?','Publicó La casa de los espíritus en 1982',array['Es una de las escritoras latinoamericanas','Una obra del realismo mágico','Sus libros están traducidos'],'She published The House of the Spirits in 1982',6),
  (v_l6,'listening','What did you hear?','Una obra del realismo mágico',array['Publicó La casa de los espíritus','Sus libros están traducidos','Es famoso por el realismo'],'A work of magical realism',7),
  (v_l6,'speaking','Say this aloud: "Publicó su primer libro en 1982."','Publicó su primer libro en 1982',array[]::text[],'He published his first book in 1982.',8),
  (v_l6,'speaking','Say this aloud: "Es famoso por el realismo mágico."','Es famoso por el realismo mágico',array[]::text[],'He''s famous for magical realism.',9),
  (v_l7,'listening','What did you hear?','El argumento es complejo y los personajes inolvidables',array['Acabo de terminar la novela','Engancha desde la primera página','Totalmente recomendable'],'The plot is complex and the characters unforgettable',6),
  (v_l7,'listening','What did you hear?','Totalmente recomendable',array['Acabo de terminar','El argumento es complejo','Engancha desde la primera página'],'Totally recommendable',7),
  (v_l7,'speaking','Say this aloud: "Los personajes son inolvidables."','Los personajes son inolvidables',array[]::text[],'The characters are unforgettable.',8),
  (v_l7,'speaking','Say this aloud: "Engancha desde la primera página."','Engancha desde la primera página',array[]::text[],'It hooks you from the first page.',9);

  update public.lessons set type='conversation', title='Art & Literature — Conversation Practice',
    description='Two friends recommend books to each other.',
    intro='Marta and Luis swap book recommendations after a long week.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Marta","spanish":"¿Has leído algo bueno últimamente?","english":"Have you read anything good lately?"},{"speaker":"Luis","spanish":"Acabo de terminar Cien años de soledad.","english":"I just finished One Hundred Years of Solitude."},{"speaker":"Marta","spanish":"¿De García Márquez? ¿Te ha gustado?","english":"By García Márquez? Did you like it?"},{"speaker":"Luis","spanish":"Mucho. Engancha desde la primera página. Es una obra maestra.","english":"A lot. It hooks you from the first page. It''s a masterpiece."},{"speaker":"Marta","spanish":"Yo leí La casa de los espíritus el mes pasado. Trata de una familia chilena.","english":"I read The House of the Spirits last month. It''s about a Chilean family."},{"speaker":"Luis","spanish":"Te recomiendo entonces a Borges. Sus cuentos son cortos pero brillantes.","english":"Then I recommend Borges. His short stories are short but brilliant."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','What did Luis just finish?','Cien años de soledad',array['La casa de los espíritus','Borges'' stories','A Vargas Llosa novel'],'Acabo de terminar Cien años de soledad',1),
  (v_l8,'multiple_choice','How does Luis describe the book?','A masterpiece',array['Boring','Overrated','Hard to follow'],'Es una obra maestra',2),
  (v_l8,'multiple_choice','What did Marta read last month?','La casa de los espíritus',array['Borges','Vargas Llosa','Cien años de soledad'],'Yo leí La casa de los espíritus el mes pasado',3),
  (v_l8,'multiple_choice','True or false: Luis recommends Borges to Marta.','True',array['False'],'Te recomiendo entonces a Borges',4),
  (v_l8,'fill_blank','Complete: "____ de terminar la novela." (I''ve just)','Acabo',array['Termino','Voy','Empiezo'],'I''ve just',5),
  (v_l8,'multiple_choice','What''s the plot of Marta''s book?','A Chilean family',array['Spanish civil war','Magical realism in Colombia','A detective story'],'Trata de una familia chilena',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Art & Literature', 'Review test for the Art & Literature section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "novel"?','la novela',array['el cuadro','el autor','la obra'],'novel',1),
  (v_lesson_id,'multiple_choice','Present perfect of leer (I)?','he leído',array['leí','leía','leeré'],'I''ve read',2),
  (v_lesson_id,'multiple_choice','What is "masterpiece"?','obra maestra',array['retrato','pintura al óleo','siglo'],'masterpiece',3),
  (v_lesson_id,'multiple_choice','True/false: "tratar de" = to be about.','True',array['False'],'tratar de = to be about',4),
  (v_lesson_id,'fill_blank','Complete: "____ de terminar la novela." (I''ve just)','Acabo',array['Voy','Termino','Empiezo'],'acabar de + inf',5),
  (v_lesson_id,'fill_blank','Complete: "Sus libros están ____ a treinta idiomas." (translated)','traducidos',array['publicados','escritos','vendidos'],'translated',6),
  (v_lesson_id,'listening','What did you hear?','Te recomiendo también Crónica de una muerte anunciada',array['He leído todos sus libros','Engancha desde la primera página','Quedan pocos ejemplares'],'I also recommend Chronicle of a Death Foretold',7),
  (v_lesson_id,'listening','What did you hear?','Es considerada una obra maestra del Barroco español',array['Es una pintura al óleo','A su derecha verán un retrato','Sus libros están traducidos'],'It''s considered a masterpiece of Spanish Baroque',8),
  (v_lesson_id,'speaking','Say this aloud: "He leído todos sus libros."','He leído todos sus libros',array[]::text[],'I''ve read all his books.',9),
  (v_lesson_id,'speaking','Say this aloud: "Acabo de terminar la novela."','Acabo de terminar la novela',array[]::text[],'I just finished the novel.',10);

  -- ===========================================================
  -- B1.11 HEALTH & MEDICINE
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B1' and title = 'Health & Medicine';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set intro='Medical vocabulary you need at the clinic.',
    vocab_items='[{"word":"el diagnóstico","phonetic":"[dyahg-NOHS-tee-koh]","english":"diagnosis","example_es":"El médico me dio el diagnóstico.","example_en":"The doctor gave me the diagnosis."},{"word":"la radiografía","phonetic":"[rrah-dyoh-grah-FEE-ah]","english":"X-ray","example_es":"Necesito una radiografía.","example_en":"I need an X-ray."},{"word":"recetar","phonetic":"[rreh-seh-TAR]","english":"to prescribe","example_es":"El doctor me recetó antibióticos.","example_en":"The doctor prescribed antibiotics."},{"word":"el tratamiento","phonetic":"[trah-tah-MYEHN-toh]","english":"treatment","example_es":"El tratamiento dura dos semanas.","example_en":"The treatment lasts two weeks."}]'::jsonb,
    dialogue='[{"speaker":"Paciente","spanish":"¿Cuál es el diagnóstico?","english":"What''s the diagnosis?"},{"speaker":"Médico","spanish":"Una gripe fuerte. Te recetaré antibióticos.","english":"A bad flu. I''ll prescribe you antibiotics."},{"speaker":"Paciente","spanish":"¿Cuánto dura el tratamiento?","english":"How long does the treatment last?"}]'::jsonb,
    grammar_note='Future tense for promises: "te recetaré", "te llamaré". Standard B1 use of future indicative.'
  where id = v_l1;
  update public.lessons set intro='Reporting symptoms with present perfect.',
    vocab_items='[{"word":"me he encontrado mal","phonetic":"[meh eh ehn-kohn-TRAH-doh mahl]","english":"I''ve been feeling bad","example_es":"Me he encontrado mal toda la semana.","example_en":"I''ve been feeling bad all week."},{"word":"he tenido fiebre","phonetic":"[eh teh-NEE-doh FYEH-breh]","english":"I''ve had a fever","example_es":"He tenido fiebre dos días.","example_en":"I''ve had a fever for two days."},{"word":"me he caído","phonetic":"[meh eh kah-EE-doh]","english":"I''ve fallen","example_es":"Me he caído y me duele.","example_en":"I''ve fallen and it hurts."},{"word":"el dolor de espalda","phonetic":"[doh-LOHR deh ehs-PAHL-dah]","english":"back pain","example_es":"Tengo un fuerte dolor de espalda.","example_en":"I have a strong back pain."}]'::jsonb,
    dialogue='[{"speaker":"Doctora","spanish":"¿Qué le sucede?","english":"What''s happening to you?"},{"speaker":"Paciente","spanish":"Me he encontrado mal toda la semana.","english":"I''ve been feeling bad all week."},{"speaker":"Doctora","spanish":"¿Ha tenido fiebre?","english":"Have you had a fever?"}]'::jsonb,
    grammar_note='Present perfect for symptoms still relevant: "Me he encontrado mal" — better than preterite if you''re still feeling that way.'
  where id = v_l2;
  update public.lessons set intro='Phrases at the pharmacy.',
    vocab_items='[{"word":"sin receta","phonetic":"[seen rreh-SEH-tah]","english":"over-the-counter","example_es":"Estos medicamentos son sin receta.","example_en":"These medicines are over-the-counter."},{"word":"el efecto secundario","phonetic":"[eh-FEHK-toh seh-koon-DAH-ryoh]","english":"side effect","example_es":"Tiene algunos efectos secundarios.","example_en":"It has some side effects."},{"word":"caduca","phonetic":"[kah-DOO-kah]","english":"expires","example_es":"Caduca el próximo mes.","example_en":"It expires next month."},{"word":"en ayunas","phonetic":"[ehn ah-YOO-nahs]","english":"on an empty stomach","example_es":"Tómelo en ayunas.","example_en":"Take it on an empty stomach."}]'::jsonb,
    dialogue='[{"speaker":"Cliente","spanish":"¿Esto se vende sin receta?","english":"Is this sold without a prescription?"},{"speaker":"Farmacéutico","spanish":"Sí. Tómelo en ayunas, una vez al día.","english":"Yes. Take it on an empty stomach, once a day."},{"speaker":"Cliente","spanish":"¿Tiene efectos secundarios?","english":"Does it have side effects?"}]'::jsonb,
    grammar_note='Formal command "Tómelo" — usted form (+ object pronoun "lo" attached). Polite shop / pharmacy register.'
  where id = v_l3;
  update public.lessons set intro='Listen to a doctor''s instructions.',
    vocab_items='[{"word":"el chequeo","phonetic":"[cheh-KEH-oh]","english":"check-up","example_es":"Necesita un chequeo anual.","example_en":"You need an annual check-up."},{"word":"analizar la sangre","phonetic":"[ah-nah-lee-SAR lah SAHN-greh]","english":"to do a blood test","example_es":"Vamos a analizar la sangre.","example_en":"We''re going to do a blood test."},{"word":"la presión","phonetic":"[preh-SYOHN]","english":"blood pressure","example_es":"Su presión está alta.","example_en":"Your blood pressure is high."},{"word":"el seguimiento","phonetic":"[seh-gee-MYEHN-toh]","english":"follow-up","example_es":"Haremos un seguimiento en un mes.","example_en":"We''ll do a follow-up in a month."}]'::jsonb,
    dialogue='[{"speaker":"Médico","spanish":"Voy a hacerle un chequeo completo.","english":"I''m going to do a complete check-up."},{"speaker":"Médico","spanish":"Vamos a analizar la sangre y medir la presión.","english":"We''re going to do a blood test and measure your blood pressure."},{"speaker":"Médico","spanish":"Haremos un seguimiento en un mes.","english":"We''ll do a follow-up in a month."}]'::jsonb,
    grammar_note='"Vamos a + inf" = near future in formal context: "Vamos a analizar". Equally used in medical or any first-person plural plan.'
  where id = v_l4;
  update public.lessons set intro='Talk about your health.',
    vocab_items='[{"word":"Hago ejercicio","phonetic":"[AH-goh eh-hehr-SEE-syoh]","english":"I exercise","example_es":"Hago ejercicio tres veces por semana.","example_en":"I exercise three times a week."},{"word":"Como sano","phonetic":"[KOH-moh SAH-noh]","english":"I eat healthily","example_es":"Intento comer sano.","example_en":"I try to eat healthily."},{"word":"Voy al médico","phonetic":"[BOY ahl MEH-dee-koh]","english":"I go to the doctor","example_es":"Voy al médico una vez al año.","example_en":"I go to the doctor once a year."},{"word":"Cuido mi salud","phonetic":"[KWEE-doh mee sah-LOOD]","english":"I take care of my health","example_es":"Cuido mi salud con buenos hábitos.","example_en":"I take care of my health with good habits."}]'::jsonb,
    dialogue='[{"speaker":"Tú","spanish":"Hago ejercicio tres veces por semana.","english":"I exercise three times a week."},{"speaker":"Amigo","spanish":"¿Y vas al médico?","english":"And do you go to the doctor?"},{"speaker":"Tú","spanish":"Una vez al año, para un chequeo.","english":"Once a year, for a check-up."}]'::jsonb,
    grammar_note='"Tres veces por semana" / "una vez al año" — frequency expressions. Notice the lack of article in "veces por semana".'
  where id = v_l5;
  update public.lessons set intro='Read advice on a healthy lifestyle.',
    vocab_items='[{"word":"hábitos saludables","phonetic":"[AH-bee-tohs sah-loo-DAH-blehs]","english":"healthy habits","example_es":"Adopta hábitos saludables.","example_en":"Adopt healthy habits."},{"word":"el estrés","phonetic":"[ehs-TREHS]","english":"stress","example_es":"El estrés afecta la salud.","example_en":"Stress affects health."},{"word":"dormir bien","phonetic":"[dohr-MEER byehn]","english":"to sleep well","example_es":"Es vital dormir bien.","example_en":"Sleeping well is vital."},{"word":"prevenir","phonetic":"[preh-beh-NEER]","english":"to prevent","example_es":"Prevenir es mejor que curar.","example_en":"Prevention is better than cure."}]'::jsonb,
    dialogue='[{"speaker":"Texto","spanish":"Adoptar hábitos saludables es la mejor manera de prevenir enfermedades.","english":"Adopting healthy habits is the best way to prevent diseases."},{"speaker":"Texto","spanish":"Comer bien, hacer ejercicio y dormir lo suficiente son la base.","english":"Eating well, exercising and sleeping enough are the foundation."},{"speaker":"Texto","spanish":"También es importante reducir el estrés diario.","english":"It''s also important to reduce daily stress."}]'::jsonb,
    grammar_note='"Es vital / es importante / es necesario + infinitive" — impersonal recommendations. With subjunctive when subject is specified: "Es importante QUE TÚ DUERMAS."'
  where id = v_l6;
  update public.lessons set intro='Write advice for a friend who feels stressed.',
    vocab_items='[{"word":"deberías","phonetic":"[deh-beh-REE-ahs]","english":"you should","example_es":"Deberías descansar más.","example_en":"You should rest more."},{"word":"intenta","phonetic":"[een-TEHN-tah]","english":"try (you)","example_es":"Intenta hacer ejercicio.","example_en":"Try to exercise."},{"word":"un consejo","phonetic":"[oon kohn-SEH-hoh]","english":"a piece of advice","example_es":"Te doy un consejo.","example_en":"I''ll give you a piece of advice."},{"word":"poco a poco","phonetic":"[POH-koh ah POH-koh]","english":"little by little","example_es":"Poco a poco verás cambios.","example_en":"Little by little you''ll see changes."}]'::jsonb,
    dialogue='[{"speaker":"Modelo","spanish":"Deberías cuidar más tu salud.","english":"You should take better care of your health."},{"speaker":"Modelo","spanish":"Intenta dormir ocho horas y hacer ejercicio tres veces por semana.","english":"Try to sleep eight hours and exercise three times a week."},{"speaker":"Modelo","spanish":"Poco a poco verás cambios.","english":"Little by little you''ll see changes."}]'::jsonb,
    grammar_note='"Deberías" (conditional of deber) = soft advice. Stronger than "te recomiendo", lighter than "tienes que".'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "diagnosis"?','el diagnóstico',array['la radiografía','el tratamiento','el chequeo'],'diagnosis',1),
  (v_l1,'fill_blank','Complete: "El doctor me ____ antibióticos." (prescribed)','recetó',array['analizó','curó','duro'],'prescribed',2),
  (v_l1,'multiple_choice','What does "tratamiento" mean?','treatment',array['diagnosis','X-ray','prescription'],'treatment',3),
  (v_l1,'listening','What did you hear?','Una gripe fuerte. Te recetaré antibióticos',array['¿Cuál es el diagnóstico?','¿Cuánto dura el tratamiento?','Necesito una radiografía'],'A bad flu. I''ll prescribe you antibiotics',4),
  (v_l1,'speaking','Say this aloud: "Necesito una radiografía."','Necesito una radiografía',array[]::text[],'I need an X-ray.',5),
  (v_l2,'multiple_choice','How to say "I''ve had a fever"?','he tenido fiebre',array['tuve fiebre','tengo fiebre','tenía fiebre'],'I''ve had a fever',1),
  (v_l2,'fill_blank','Complete: "Me he ____ mal toda la semana." (felt bad)','encontrado',array['caído','tenido','dolido'],'felt',2),
  (v_l2,'multiple_choice','What does "dolor de espalda" mean?','back pain',array['headache','stomach pain','sore throat'],'back pain',3),
  (v_l2,'listening','What did you hear?','Me he encontrado mal toda la semana',array['¿Qué le sucede?','¿Ha tenido fiebre?','Me he caído y me duele'],'I''ve been feeling bad all week',4),
  (v_l2,'speaking','Say this aloud: "He tenido fiebre dos días."','He tenido fiebre dos días',array[]::text[],'I''ve had a fever for two days.',5),
  (v_l3,'multiple_choice','How to say "over-the-counter"?','sin receta',array['sin efecto','en ayunas','con receta'],'over-the-counter',1),
  (v_l3,'fill_blank','Complete: "Tómelo en ____" (on an empty stomach)','ayunas',array['receta','sangre','presión'],'on an empty stomach',2),
  (v_l3,'multiple_choice','What does "caduca" mean?','expires',array['costs','works','contains'],'expires',3),
  (v_l3,'listening','What did you hear?','Tómelo en ayunas, una vez al día',array['¿Esto se vende sin receta?','¿Tiene efectos secundarios?','Caduca el próximo mes'],'Take it on an empty stomach, once a day',4),
  (v_l3,'speaking','Say this aloud: "¿Tiene efectos secundarios?"','¿Tiene efectos secundarios?',array[]::text[],'Does it have side effects?',5),
  (v_l4,'multiple_choice','What is "check-up"?','el chequeo',array['el seguimiento','la presión','la sangre'],'check-up',1),
  (v_l4,'fill_blank','Complete: "Vamos a ____ la sangre." (analyse)','analizar',array['medir','recetar','prevenir'],'analyse',2),
  (v_l4,'multiple_choice','What does "presión" mean here?','blood pressure',array['stress','urgency','pressure cooker'],'blood pressure',3),
  (v_l4,'listening','What did you hear?','Vamos a analizar la sangre y medir la presión',array['Voy a hacerle un chequeo completo','Haremos un seguimiento en un mes','Su presión está alta'],'We''re going to do a blood test and measure your blood pressure',4),
  (v_l4,'speaking','Say this aloud: "Haremos un seguimiento en un mes."','Haremos un seguimiento en un mes',array[]::text[],'We''ll do a follow-up in a month.',5),
  (v_l5,'multiple_choice','How to say "I exercise three times a week"?','Hago ejercicio tres veces por semana',array['Voy al médico','Cuido mi salud','Como sano'],'I exercise three times a week',1),
  (v_l5,'fill_blank','Complete: "Una ____ al año." (time)','vez',array['veces','mes','día'],'time (once)',2),
  (v_l5,'multiple_choice','What does "Cuido mi salud" mean?','I take care of my health',array['I''m a doctor','I help others','I''m sick'],'I take care of my health',3),
  (v_l5,'listening','What did you hear?','Hago ejercicio tres veces por semana',array['Una vez al año, para un chequeo','Intento comer sano','Cuido mi salud con buenos hábitos'],'I exercise three times a week',4),
  (v_l5,'speaking','Say this aloud: "Intento comer sano."','Intento comer sano',array[]::text[],'I try to eat healthily.',5),
  (v_l6,'multiple_choice','What is "stress"?','el estrés',array['los hábitos','el ejercicio','el seguimiento'],'stress',1),
  (v_l6,'fill_blank','Complete: "____ es mejor que curar." (to prevent)','Prevenir',array['Comer','Dormir','Curar'],'to prevent',2),
  (v_l6,'multiple_choice','What does "vital" mean?','vital',array['risky','optional','expensive'],'vital',3),
  (v_l6,'listening','What did you hear?','Adoptar hábitos saludables es la mejor manera de prevenir enfermedades',array['Comer bien, hacer ejercicio y dormir','También es importante reducir el estrés','El estrés afecta la salud'],'Adopting healthy habits is the best way to prevent diseases',4),
  (v_l6,'speaking','Say this aloud: "Es vital dormir bien."','Es vital dormir bien',array[]::text[],'Sleeping well is vital.',5),
  (v_l7,'multiple_choice','How to say "you should"?','deberías',array['intenta','poco a poco','un consejo'],'you should',1),
  (v_l7,'fill_blank','Complete: "____ hacer ejercicio." (try - you)','Intenta',array['Deberías','Debes','Hazlo'],'try (tú command)',2),
  (v_l7,'multiple_choice','What does "poco a poco" mean?','little by little',array['quickly','rarely','seldom'],'little by little',3),
  (v_l7,'listening','What did you hear?','Intenta dormir ocho horas y hacer ejercicio tres veces por semana',array['Deberías cuidar más tu salud','Poco a poco verás cambios','Te doy un consejo'],'Try to sleep eight hours and exercise three times a week',4),
  (v_l7,'speaking','Say this aloud: "Deberías descansar más."','Deberías descansar más',array[]::text[],'You should rest more.',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Necesito una radiografía',array['El médico me dio el diagnóstico','El doctor me recetó antibióticos','El tratamiento dura dos semanas'],'I need an X-ray',6),
  (v_l1,'listening','What did you hear?','El tratamiento dura dos semanas',array['El médico me dio el diagnóstico','El doctor me recetó','Necesito una radiografía'],'The treatment lasts two weeks',7),
  (v_l1,'speaking','Say this aloud: "¿Cuál es el diagnóstico?"','¿Cuál es el diagnóstico?',array[]::text[],'What''s the diagnosis?',8),
  (v_l1,'speaking','Say this aloud: "El tratamiento dura dos semanas."','El tratamiento dura dos semanas',array[]::text[],'The treatment lasts two weeks.',9),
  (v_l2,'listening','What did you hear?','He tenido fiebre dos días',array['Me he caído y me duele','Tengo un fuerte dolor','¿Ha tenido fiebre?'],'I''ve had a fever for two days',6),
  (v_l2,'listening','What did you hear?','Me he caído y me duele',array['He tenido fiebre','Me he encontrado mal','Tengo un fuerte dolor'],'I''ve fallen and it hurts',7),
  (v_l2,'speaking','Say this aloud: "Tengo un fuerte dolor de espalda."','Tengo un fuerte dolor de espalda',array[]::text[],'I have a strong back pain.',8),
  (v_l2,'speaking','Say this aloud: "Me he caído y me duele."','Me he caído y me duele',array[]::text[],'I''ve fallen and it hurts.',9),
  (v_l3,'listening','What did you hear?','Caduca el próximo mes',array['Estos medicamentos son sin receta','Tiene algunos efectos secundarios','Tómelo en ayunas'],'It expires next month',6),
  (v_l3,'listening','What did you hear?','Tiene algunos efectos secundarios',array['Estos medicamentos son sin receta','Caduca el próximo mes','Tómelo en ayunas'],'It has some side effects',7),
  (v_l3,'speaking','Say this aloud: "Estos medicamentos son sin receta."','Estos medicamentos son sin receta',array[]::text[],'These medicines are over-the-counter.',8),
  (v_l3,'speaking','Say this aloud: "Caduca el próximo mes."','Caduca el próximo mes',array[]::text[],'It expires next month.',9),
  (v_l6,'listening','What did you hear?','Comer bien, hacer ejercicio y dormir lo suficiente',array['Adoptar hábitos saludables','También es importante reducir','Prevenir es mejor que curar'],'Eat well, exercise and sleep enough',6),
  (v_l6,'listening','What did you hear?','Prevenir es mejor que curar',array['Adoptar hábitos saludables','El estrés afecta la salud','Es vital dormir bien'],'Prevention is better than cure',7),
  (v_l6,'speaking','Say this aloud: "El estrés afecta la salud."','El estrés afecta la salud',array[]::text[],'Stress affects health.',8),
  (v_l6,'speaking','Say this aloud: "Adopta hábitos saludables."','Adopta hábitos saludables',array[]::text[],'Adopt healthy habits.',9),
  (v_l7,'listening','What did you hear?','Poco a poco verás cambios',array['Deberías cuidar más tu salud','Intenta dormir ocho horas','Te doy un consejo'],'Little by little you''ll see changes',6),
  (v_l7,'listening','What did you hear?','Te doy un consejo',array['Deberías descansar más','Intenta hacer ejercicio','Poco a poco verás cambios'],'I''ll give you a piece of advice',7),
  (v_l7,'speaking','Say this aloud: "Poco a poco verás cambios."','Poco a poco verás cambios',array[]::text[],'Little by little you''ll see changes.',8),
  (v_l7,'speaking','Say this aloud: "Te doy un consejo."','Te doy un consejo',array[]::text[],'I''ll give you a piece of advice.',9);

  update public.lessons set type='conversation', title='Health & Medicine — Conversation Practice',
    description='A patient describes symptoms at a clinic.',
    intro='Listen to a doctor''s appointment. Notice present-perfect symptom phrases.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Doctora","spanish":"Buenos días, ¿qué le sucede?","english":"Good morning, what''s happening with you?"},{"speaker":"Paciente","spanish":"Me he encontrado mal toda la semana. He tenido fiebre y dolor de cabeza.","english":"I''ve been feeling bad all week. I''ve had a fever and a headache."},{"speaker":"Doctora","spanish":"¿Ha tomado algo?","english":"Have you taken anything?"},{"speaker":"Paciente","spanish":"Paracetamol, pero el dolor sigue.","english":"Paracetamol, but the pain continues."},{"speaker":"Doctora","spanish":"Le voy a recetar un antibiótico y haremos seguimiento en una semana.","english":"I''ll prescribe an antibiotic and we''ll follow up in a week."},{"speaker":"Paciente","spanish":"De acuerdo. ¿Algún efecto secundario que deba saber?","english":"All right. Any side effect I should know about?"}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','How long has the patient felt bad?','All week',array['One day','Two days','Three months'],'toda la semana',1),
  (v_l8,'multiple_choice','What symptoms?','Fever and headache',array['Back pain','Stomach ache','Sore throat'],'He tenido fiebre y dolor de cabeza',2),
  (v_l8,'multiple_choice','Has he taken anything?','Paracetamol',array['Antibiotics','Nothing','Vitamins'],'Paracetamol',3),
  (v_l8,'multiple_choice','True or false: The doctor prescribes an antibiotic.','True',array['False'],'Le voy a recetar un antibiótico',4),
  (v_l8,'fill_blank','Complete: "Me ____ encontrado mal." (have)','he',array['ha','han','hemos'],'I''ve',5),
  (v_l8,'multiple_choice','When is the follow-up?','In a week',array['In a month','In three days','Next year'],'haremos seguimiento en una semana',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Health & Medicine', 'Review test for the Health & Medicine section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "treatment"?','el tratamiento',array['el diagnóstico','la radiografía','el chequeo'],'treatment',1),
  (v_lesson_id,'multiple_choice','Present perfect "I''ve had"?','he tenido',array['tuve','tenía','tendría'],'I''ve had',2),
  (v_lesson_id,'multiple_choice','What does "en ayunas" mean?','on an empty stomach',array['after eating','before sleep','with water'],'on an empty stomach',3),
  (v_lesson_id,'multiple_choice','True/false: "Deberías" softens advice.','True',array['False'],'softer than tienes que',4),
  (v_lesson_id,'fill_blank','Complete: "Poco a ____" (little by little)','poco',array['vez','día','mes'],'little by little',5),
  (v_lesson_id,'fill_blank','Complete: "Tres veces ____ semana." (per)','por',array['en','de','a'],'per',6),
  (v_lesson_id,'listening','What did you hear?','Necesito una radiografía',array['El médico me dio el diagnóstico','El tratamiento dura dos semanas','El doctor me recetó antibióticos'],'I need an X-ray',7),
  (v_lesson_id,'listening','What did you hear?','Es vital dormir bien',array['Adoptar hábitos saludables','El estrés afecta la salud','Prevenir es mejor que curar'],'Sleeping well is vital',8),
  (v_lesson_id,'speaking','Say this aloud: "He tenido fiebre dos días."','He tenido fiebre dos días',array[]::text[],'I''ve had a fever for two days.',9),
  (v_lesson_id,'speaking','Say this aloud: "Deberías descansar más."','Deberías descansar más',array[]::text[],'You should rest more.',10);

  -- ===========================================================
  -- B1.12 BUSINESS BASICS
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B1' and title = 'Business Basics';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set intro='Office and meeting vocabulary.',
    vocab_items='[{"word":"la reunión","phonetic":"[rreh-oo-NYOHN]","english":"meeting","example_es":"Tenemos una reunión a las tres.","example_en":"We have a meeting at three."},{"word":"el presupuesto","phonetic":"[preh-soo-PWEHS-toh]","english":"budget","example_es":"El presupuesto es ajustado.","example_en":"The budget is tight."},{"word":"el cliente","phonetic":"[klee-EHN-teh]","english":"client","example_es":"Tenemos un cliente nuevo.","example_en":"We have a new client."},{"word":"el plazo","phonetic":"[PLAH-soh]","english":"deadline","example_es":"El plazo termina el viernes.","example_en":"The deadline is Friday."}]'::jsonb,
    dialogue='[{"speaker":"Jefe","spanish":"Tenemos una reunión con el cliente nuevo.","english":"We have a meeting with the new client."},{"speaker":"Empleada","spanish":"¿Cuál es el plazo?","english":"What''s the deadline?"},{"speaker":"Jefe","spanish":"El viernes. El presupuesto es ajustado.","english":"Friday. The budget is tight."}]'::jsonb,
    grammar_note='"Plazo" = deadline / term. "A corto plazo" = short-term. "A largo plazo" = long-term. Common B1 expressions.'
  where id = v_l1;
  update public.lessons set intro='Verbs for business actions.',
    vocab_items='[{"word":"negociar","phonetic":"[neh-goh-SYAR]","english":"to negotiate","example_es":"Estamos negociando un contrato.","example_en":"We''re negotiating a contract."},{"word":"firmar","phonetic":"[feer-MAR]","english":"to sign","example_es":"Firmamos el acuerdo ayer.","example_en":"We signed the agreement yesterday."},{"word":"cumplir","phonetic":"[koom-PLEER]","english":"to meet (a goal)","example_es":"Cumplimos los objetivos.","example_en":"We met the targets."},{"word":"presentar un informe","phonetic":"[preh-sehn-TAR oon een-FOHR-meh]","english":"to present a report","example_es":"Voy a presentar un informe.","example_en":"I''m going to present a report."}]'::jsonb,
    dialogue='[{"speaker":"Eva","spanish":"¿Firmaron el contrato?","english":"Did they sign the contract?"},{"speaker":"Iván","spanish":"Sí, ayer. Estuvimos negociando dos semanas.","english":"Yes, yesterday. We were negotiating for two weeks."},{"speaker":"Eva","spanish":"Esperemos cumplir los objetivos.","english":"Let''s hope we meet the targets."}]'::jsonb,
    grammar_note='"Estuvimos + gerund" = past progressive: ongoing action in the past. Different from imperfect — emphasizes duration.'
  where id = v_l2;
  update public.lessons set intro='Phrases for meetings and emails.',
    vocab_items='[{"word":"De acuerdo","phonetic":"[deh ah-KWEHR-doh]","english":"Agreed","example_es":"De acuerdo, lo haremos así.","example_en":"Agreed, we''ll do it this way."},{"word":"Le envío adjunto","phonetic":"[leh ehn-BEE-oh ahd-HOON-toh]","english":"I''m sending you attached","example_es":"Le envío adjunto el documento.","example_en":"I''m sending you the document attached."},{"word":"Quedo a la espera","phonetic":"[KEH-doh ah lah ehs-PEH-rah]","english":"I look forward to","example_es":"Quedo a la espera de su respuesta.","example_en":"I look forward to your reply."},{"word":"un saludo cordial","phonetic":"[soh-LOO-doh kohr-DYAHL]","english":"best regards","example_es":"Un saludo cordial.","example_en":"Best regards."}]'::jsonb,
    dialogue='[{"speaker":"Email","spanish":"Estimada señora Pérez:","english":"Dear Mrs. Pérez,"},{"speaker":"Email","spanish":"Le envío adjunto el informe trimestral.","english":"I''m sending you the quarterly report attached."},{"speaker":"Email","spanish":"Quedo a la espera de sus comentarios. Un saludo cordial.","english":"I look forward to your comments. Best regards."}]'::jsonb,
    grammar_note='Formal Spanish emails open with "Estimado/a + name" and close with "Un saludo cordial / Atentamente." Subjunctive in "quedo a la espera" is conventional.'
  where id = v_l3;
  update public.lessons set intro='Listen to a project meeting.',
    vocab_items='[{"word":"el equipo","phonetic":"[eh-KEE-poh]","english":"team","example_es":"Mi equipo es eficiente.","example_en":"My team is efficient."},{"word":"el avance","phonetic":"[ah-BAHN-seh]","english":"progress","example_es":"Reportamos el avance del proyecto.","example_en":"We report the project''s progress."},{"speaker":"v","word":"el retraso","phonetic":"[rreh-TRAH-soh]","english":"delay","example_es":"Hay un retraso de dos semanas.","example_en":"There''s a two-week delay."},{"word":"el objetivo","phonetic":"[ohb-heh-TEE-boh]","english":"goal","example_es":"Nuestro objetivo es claro.","example_en":"Our goal is clear."}]'::jsonb,
    dialogue='[{"speaker":"Jefe","spanish":"Buenos días. Empezamos la reunión semanal.","english":"Good morning. We''re starting the weekly meeting."},{"speaker":"Jefe","spanish":"Por favor, cada equipo presenta su avance.","english":"Each team please present their progress."},{"speaker":"Jefe","spanish":"Hay un retraso de dos semanas en el proyecto principal.","english":"There''s a two-week delay on the main project."}]'::jsonb,
    grammar_note='Meeting Spanish stays in present indicative for procedure: "empezamos", "presenta", "hay". Past for completed actions: "presentamos ayer".'
  where id = v_l4;
  update public.lessons set intro='Speak about your work.',
    vocab_items='[{"word":"Trabajo en marketing","phonetic":"[trah-BAH-hoh ehn]","english":"I work in marketing","example_es":"Trabajo en marketing digital.","example_en":"I work in digital marketing."},{"word":"Llevo dos años","phonetic":"[YEH-boh dohs AH-nyohs]","english":"I''ve been there two years","example_es":"Llevo dos años en la empresa.","example_en":"I''ve been at the company two years."},{"word":"Manejo proyectos","phonetic":"[mah-NEH-hoh proh-YEHK-tohs]","english":"I manage projects","example_es":"Manejo proyectos internacionales.","example_en":"I manage international projects."},{"word":"Reporto al director","phonetic":"[rreh-POHR-toh]","english":"I report to the director","example_es":"Reporto directamente al director.","example_en":"I report directly to the director."}]'::jsonb,
    dialogue='[{"speaker":"Tú","spanish":"Trabajo en marketing digital desde hace dos años.","english":"I''ve been working in digital marketing for two years."},{"speaker":"Persona","spanish":"¿Qué haces exactamente?","english":"What do you do exactly?"},{"speaker":"Tú","spanish":"Manejo proyectos internacionales y reporto al director.","english":"I manage international projects and report to the director."}]'::jsonb,
    grammar_note='"Llevar + time + gerund or location" = duration: "Llevo dos años en la empresa" / "Llevo dos años trabajando aquí". Both correct.'
  where id = v_l5;
  update public.lessons set intro='Read a workplace article.',
    vocab_items='[{"word":"el teletrabajo","phonetic":"[teh-leh-trah-BAH-hoh]","english":"remote work","example_es":"El teletrabajo aumenta cada año.","example_en":"Remote work grows every year."},{"word":"la productividad","phonetic":"[proh-dook-tee-bee-DAHD]","english":"productivity","example_es":"La productividad mejoró.","example_en":"Productivity improved."},{"word":"flexibilizar","phonetic":"[flehk-see-bee-lee-SAR]","english":"to make flexible","example_es":"Flexibilizamos los horarios.","example_en":"We made schedules flexible."},{"word":"el equilibrio","phonetic":"[eh-kee-LEE-bryoh]","english":"balance","example_es":"Es difícil mantener el equilibrio.","example_en":"It''s hard to maintain balance."}]'::jsonb,
    dialogue='[{"speaker":"Texto","spanish":"El teletrabajo ha transformado el mundo laboral en los últimos años.","english":"Remote work has transformed the workforce in recent years."},{"speaker":"Texto","spanish":"Muchas empresas han flexibilizado los horarios y la productividad ha mejorado.","english":"Many companies have made schedules flexible and productivity has improved."},{"speaker":"Texto","spanish":"Sin embargo, es difícil mantener el equilibrio entre trabajo y vida personal.","english":"However, it''s hard to maintain balance between work and personal life."}]'::jsonb,
    grammar_note='Present perfect for recent changes: "ha transformado", "han flexibilizado", "ha mejorado". A very B1-typical use.'
  where id = v_l6;
  update public.lessons set intro='Write a short professional email.',
    vocab_items='[{"word":"agradecer","phonetic":"[ah-grah-deh-SEHR]","english":"to thank","example_es":"Le agradezco su tiempo.","example_en":"I thank you for your time."},{"word":"confirmar","phonetic":"[kohn-feer-MAR]","english":"to confirm","example_es":"Confirmo la reunión del lunes.","example_en":"I confirm Monday''s meeting."},{"word":"posponer","phonetic":"[pohs-poh-NEHR]","english":"to postpone","example_es":"Posponemos la reunión al jueves.","example_en":"We''re postponing the meeting to Thursday."},{"word":"a la mayor brevedad","phonetic":"[ah lah mah-YOHR breh-beh-DAHD]","english":"as soon as possible","example_es":"Responderé a la mayor brevedad.","example_en":"I''ll reply as soon as possible."}]'::jsonb,
    dialogue='[{"speaker":"Modelo","spanish":"Estimado Sr. Martínez:","english":"Dear Mr. Martínez,"},{"speaker":"Modelo","spanish":"Le agradezco su mensaje. Confirmo la reunión del lunes a las once.","english":"Thank you for your message. I confirm Monday''s meeting at eleven."},{"speaker":"Modelo","spanish":"Quedo a su disposición para cualquier consulta. Un saludo cordial.","english":"I remain at your disposal for any query. Best regards."}]'::jsonb,
    grammar_note='Common formal close: "Quedo a su disposición" — "I remain at your disposal". Higher register than English equivalent but standard in Spanish.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "deadline"?','el plazo',array['el cliente','el presupuesto','la reunión'],'deadline',1),
  (v_l1,'fill_blank','Complete: "El ____ termina el viernes." (deadline)','plazo',array['cliente','presupuesto','equipo'],'deadline',2),
  (v_l1,'multiple_choice','What does "presupuesto" mean?','budget',array['client','meeting','deadline'],'budget',3),
  (v_l1,'listening','What did you hear?','El viernes. El presupuesto es ajustado',array['Tenemos una reunión a las tres','El plazo termina el viernes','Tenemos un cliente nuevo'],'Friday. The budget is tight',4),
  (v_l1,'speaking','Say this aloud: "Tenemos un cliente nuevo."','Tenemos un cliente nuevo',array[]::text[],'We have a new client.',5),
  (v_l2,'multiple_choice','How to say "to negotiate"?','negociar',array['firmar','cumplir','presentar'],'to negotiate',1),
  (v_l2,'fill_blank','Complete: "Firmamos el ____ ayer." (agreement)','acuerdo',array['informe','contrato','equipo'],'agreement',2),
  (v_l2,'multiple_choice','What does "cumplir" mean?','to meet (a goal)',array['to start','to ignore','to delay'],'to meet (a goal)',3),
  (v_l2,'listening','What did you hear?','Estuvimos negociando dos semanas',array['Sí, ayer','Esperemos cumplir los objetivos','¿Firmaron el contrato?'],'We were negotiating for two weeks',4),
  (v_l2,'speaking','Say this aloud: "Voy a presentar un informe."','Voy a presentar un informe',array[]::text[],'I''m going to present a report.',5),
  (v_l3,'multiple_choice','How to say "I''m sending you attached"?','Le envío adjunto',array['Quedo a la espera','De acuerdo','Un saludo cordial'],'I''m sending you attached',1),
  (v_l3,'fill_blank','Complete: "Un ____ cordial." (greeting)','saludo',array['envío','espera','acuerdo'],'greeting',2),
  (v_l3,'multiple_choice','What does "Quedo a la espera" mean?','I look forward to',array['I''m waiting','I''ll wait','I look back'],'I look forward to',3),
  (v_l3,'listening','What did you hear?','Quedo a la espera de sus comentarios',array['Estimada señora Pérez','Le envío adjunto el informe trimestral','Un saludo cordial'],'I look forward to your comments',4),
  (v_l3,'speaking','Say this aloud: "Un saludo cordial."','Un saludo cordial',array[]::text[],'Best regards.',5),
  (v_l4,'multiple_choice','What is "delay"?','el retraso',array['el avance','el equipo','el objetivo'],'delay',1),
  (v_l4,'fill_blank','Complete: "Cada ____ presenta su avance." (team)','equipo',array['retraso','objetivo','avance'],'team',2),
  (v_l4,'multiple_choice','What does "el avance" mean?','progress',array['delay','goal','schedule'],'progress',3),
  (v_l4,'listening','What did you hear?','Hay un retraso de dos semanas en el proyecto principal',array['Empezamos la reunión semanal','Cada equipo presenta su avance','Nuestro objetivo es claro'],'There''s a two-week delay on the main project',4),
  (v_l4,'speaking','Say this aloud: "Nuestro objetivo es claro."','Nuestro objetivo es claro',array[]::text[],'Our goal is clear.',5),
  (v_l5,'multiple_choice','How to say "I''ve been there two years"?','Llevo dos años',array['Trabajo dos años','Tuve dos años','Estuve dos años'],'I''ve been there two years',1),
  (v_l5,'fill_blank','Complete: "____ proyectos internacionales." (I manage)','Manejo',array['Reporto','Llevo','Trabajo'],'I manage',2),
  (v_l5,'multiple_choice','What does "reporto al director" mean?','I report to the director',array['I write to the director','I avoid the director','I work for clients'],'I report to the director',3),
  (v_l5,'listening','What did you hear?','Manejo proyectos internacionales y reporto al director',array['Trabajo en marketing digital','Llevo dos años en la empresa','¿Qué haces exactamente?'],'I manage international projects and report to the director',4),
  (v_l5,'speaking','Say this aloud: "Llevo dos años en la empresa."','Llevo dos años en la empresa',array[]::text[],'I''ve been at the company two years.',5),
  (v_l6,'multiple_choice','What is "remote work"?','el teletrabajo',array['la productividad','el equilibrio','el avance'],'remote work',1),
  (v_l6,'fill_blank','Complete: "Es difícil mantener el ____" (balance)','equilibrio',array['retraso','plazo','avance'],'balance',2),
  (v_l6,'multiple_choice','What does "flexibilizar" mean?','to make flexible',array['to fire','to grow','to delay'],'to make flexible',3),
  (v_l6,'listening','What did you hear?','La productividad ha mejorado',array['El teletrabajo ha transformado','Es difícil mantener el equilibrio','Muchas empresas han flexibilizado'],'Productivity has improved',4),
  (v_l6,'speaking','Say this aloud: "Es difícil mantener el equilibrio."','Es difícil mantener el equilibrio',array[]::text[],'It''s hard to maintain balance.',5),
  (v_l7,'multiple_choice','How to say "to confirm"?','confirmar',array['agradecer','posponer','presentar'],'to confirm',1),
  (v_l7,'fill_blank','Complete: "A la mayor ____" (brevity)','brevedad',array['confirmación','espera','reunión'],'brevity (ASAP)',2),
  (v_l7,'multiple_choice','What does "Le agradezco su tiempo" mean?','I thank you for your time',array['I''ll send you the time','I''m late','Goodbye'],'I thank you for your time',3),
  (v_l7,'listening','What did you hear?','Confirmo la reunión del lunes a las once',array['Le agradezco su mensaje','Quedo a su disposición','Un saludo cordial'],'I confirm Monday''s meeting at eleven',4),
  (v_l7,'speaking','Say this aloud: "Le agradezco su tiempo."','Le agradezco su tiempo',array[]::text[],'I thank you for your time.',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Tenemos un cliente nuevo',array['El plazo termina el viernes','Tenemos una reunión a las tres','El presupuesto es ajustado'],'We have a new client',6),
  (v_l1,'listening','What did you hear?','Tenemos una reunión a las tres',array['Tenemos un cliente nuevo','El plazo termina el viernes','El presupuesto es ajustado'],'We have a meeting at three',7),
  (v_l1,'speaking','Say this aloud: "El plazo termina el viernes."','El plazo termina el viernes',array[]::text[],'The deadline is Friday.',8),
  (v_l1,'speaking','Say this aloud: "El presupuesto es ajustado."','El presupuesto es ajustado',array[]::text[],'The budget is tight.',9),
  (v_l2,'listening','What did you hear?','Esperemos cumplir los objetivos',array['¿Firmaron el contrato?','Sí, ayer','Estuvimos negociando dos semanas'],'Let''s hope we meet the targets',6),
  (v_l2,'listening','What did you hear?','Firmamos el acuerdo ayer',array['Estuvimos negociando','Voy a presentar un informe','Cumplimos los objetivos'],'We signed the agreement yesterday',7),
  (v_l2,'speaking','Say this aloud: "Cumplimos los objetivos."','Cumplimos los objetivos',array[]::text[],'We met the targets.',8),
  (v_l2,'speaking','Say this aloud: "Estamos negociando un contrato."','Estamos negociando un contrato',array[]::text[],'We''re negotiating a contract.',9),
  (v_l3,'listening','What did you hear?','Le envío adjunto el documento',array['Quedo a la espera','De acuerdo','Un saludo cordial'],'I''m sending you the document attached',6),
  (v_l3,'listening','What did you hear?','De acuerdo, lo haremos así',array['Quedo a la espera','Le envío adjunto','Un saludo cordial'],'Agreed, we''ll do it this way',7),
  (v_l3,'speaking','Say this aloud: "Quedo a la espera de su respuesta."','Quedo a la espera de su respuesta',array[]::text[],'I look forward to your reply.',8),
  (v_l3,'speaking','Say this aloud: "De acuerdo, lo haremos así."','De acuerdo, lo haremos así',array[]::text[],'Agreed, we''ll do it this way.',9),
  (v_l6,'listening','What did you hear?','Muchas empresas han flexibilizado los horarios',array['El teletrabajo ha transformado','La productividad ha mejorado','Es difícil mantener el equilibrio'],'Many companies have made schedules flexible',6),
  (v_l6,'listening','What did you hear?','El teletrabajo ha transformado el mundo laboral',array['Muchas empresas han flexibilizado','La productividad ha mejorado','Es difícil mantener el equilibrio'],'Remote work has transformed the workforce',7),
  (v_l6,'speaking','Say this aloud: "El teletrabajo aumenta cada año."','El teletrabajo aumenta cada año',array[]::text[],'Remote work grows every year.',8),
  (v_l6,'speaking','Say this aloud: "Flexibilizamos los horarios."','Flexibilizamos los horarios',array[]::text[],'We made schedules flexible.',9),
  (v_l7,'listening','What did you hear?','Le agradezco su mensaje',array['Confirmo la reunión','Quedo a su disposición','Un saludo cordial'],'Thank you for your message',6),
  (v_l7,'listening','What did you hear?','Quedo a su disposición para cualquier consulta',array['Confirmo la reunión','Le agradezco su tiempo','Un saludo cordial'],'I remain at your disposal for any query',7),
  (v_l7,'speaking','Say this aloud: "Confirmo la reunión del lunes."','Confirmo la reunión del lunes',array[]::text[],'I confirm Monday''s meeting.',8),
  (v_l7,'speaking','Say this aloud: "Quedo a su disposición."','Quedo a su disposición',array[]::text[],'I remain at your disposal.',9);

  update public.lessons set type='conversation', title='Business Basics — Conversation Practice',
    description='A team checks in on project progress.',
    intro='Listen to a short team meeting about a delayed project.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Jefe","spanish":"Buenos días. ¿Cómo va el proyecto del cliente nuevo?","english":"Good morning. How''s the new client''s project going?"},{"speaker":"Eva","spanish":"Hay un retraso de dos semanas.","english":"There''s a two-week delay."},{"speaker":"Jefe","spanish":"¿Cuál es el motivo?","english":"What''s the reason?"},{"speaker":"Eva","spanish":"Estuvimos negociando el presupuesto y se alargó.","english":"We were negotiating the budget and it dragged on."},{"speaker":"Jefe","spanish":"De acuerdo. Le envío al cliente un correo confirmando el nuevo plazo.","english":"All right. I''ll send the client an email confirming the new deadline."},{"speaker":"Eva","spanish":"Te paso el informe a la mayor brevedad.","english":"I''ll send you the report as soon as possible."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','How long is the delay?','Two weeks',array['One week','One month','Three days'],'Hay un retraso de dos semanas',1),
  (v_l8,'multiple_choice','What caused the delay?','Budget negotiation',array['Sick team','Bad weather','Holiday'],'Estuvimos negociando el presupuesto',2),
  (v_l8,'multiple_choice','What will the boss do?','Email the client',array['Cancel the project','Fire someone','Hire more staff'],'Le envío al cliente un correo confirmando el nuevo plazo',3),
  (v_l8,'multiple_choice','True or false: Eva agrees to send the report quickly.','True',array['False'],'Te paso el informe a la mayor brevedad',4),
  (v_l8,'fill_blank','Complete: "A la mayor ____" (brevity)','brevedad',array['rapidez','urgencia','prisa'],'brevity (ASAP)',5),
  (v_l8,'multiple_choice','The general tone of the meeting?','Professional and constructive',array['Angry','Casual','Confused'],'De acuerdo. Le envío al cliente un correo',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Business Basics', 'Review test for the Business Basics section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "deadline"?','el plazo',array['el cliente','el avance','el equipo'],'deadline',1),
  (v_lesson_id,'multiple_choice','Past progressive of "estar" (we)?','estuvimos',array['estuviéramos','estamos','estábamos'],'we were (estar)',2),
  (v_lesson_id,'multiple_choice','How to say "I look forward to your reply"?','Quedo a la espera de su respuesta',array['Le envío adjunto','Le agradezco su tiempo','Un saludo cordial'],'I look forward to your reply',3),
  (v_lesson_id,'multiple_choice','True/false: "llevar + time" expresses duration.','True',array['False'],'Llevo dos años',4),
  (v_lesson_id,'fill_blank','Complete: "A la mayor ____" (ASAP)','brevedad',array['hora','urgencia','prisa'],'brevedad',5),
  (v_lesson_id,'fill_blank','Complete: "____ proyectos internacionales." (I manage)','Manejo',array['Reporto','Llevo','Trabajo'],'I manage',6),
  (v_lesson_id,'listening','What did you hear?','El plazo termina el viernes',array['Tenemos una reunión a las tres','El presupuesto es ajustado','Tenemos un cliente nuevo'],'The deadline is Friday',7),
  (v_lesson_id,'listening','What did you hear?','El teletrabajo aumenta cada año',array['La productividad ha mejorado','Muchas empresas han flexibilizado','Es difícil mantener el equilibrio'],'Remote work grows every year',8),
  (v_lesson_id,'speaking','Say this aloud: "Confirmo la reunión del lunes."','Confirmo la reunión del lunes',array[]::text[],'I confirm Monday''s meeting.',9),
  (v_lesson_id,'speaking','Say this aloud: "Llevo dos años en la empresa."','Llevo dos años en la empresa',array[]::text[],'I''ve been at the company two years.',10);

  -- ===========================================================
  -- B1.13 SPORTS & FITNESS
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B1' and title = 'Sports & Fitness';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set intro='Sports vocabulary at B1.',
    vocab_items='[{"word":"el campeonato","phonetic":"[kahm-peh-oh-NAH-toh]","english":"championship","example_es":"Ganamos el campeonato.","example_en":"We won the championship."},{"word":"el árbitro","phonetic":"[AR-bee-troh]","english":"referee","example_es":"El árbitro pitó penalti.","example_en":"The referee called a penalty."},{"word":"empatar","phonetic":"[ehm-pah-TAR]","english":"to draw","example_es":"Empatamos a dos.","example_en":"We drew two-all."},{"word":"el entrenamiento","phonetic":"[ehn-treh-nah-MYEHN-toh]","english":"training","example_es":"El entrenamiento es intenso.","example_en":"Training is intense."}]'::jsonb,
    dialogue='[{"speaker":"Eva","spanish":"¿Quién ganó el campeonato?","english":"Who won the championship?"},{"speaker":"Pedro","spanish":"Empatamos en la final.","english":"We drew in the final."},{"speaker":"Eva","spanish":"¡Vaya! ¿Y el árbitro?","english":"Oh! And the referee?"}]'::jsonb,
    grammar_note='"Vaya" — interjection of surprise / disappointment. Like "wow" or "oh boy". Common in spoken Spanish.'
  where id = v_l1;
  update public.lessons set intro='Past progressive in sports narrative.',
    vocab_items='[{"word":"estaba ganando","phonetic":"[ehs-TAH-bah gah-NAHN-doh]","english":"I was winning","example_es":"Estaba ganando dos a cero.","example_en":"I was winning two to nothing."},{"word":"sufrir una lesión","phonetic":"[soo-FREER OO-nah leh-SYOHN]","english":"to suffer an injury","example_es":"Sufrí una lesión en la rodilla.","example_en":"I suffered a knee injury."},{"word":"recuperarse","phonetic":"[rreh-koo-peh-RAR-seh]","english":"to recover","example_es":"Me recuperé en dos meses.","example_en":"I recovered in two months."},{"word":"perder por","phonetic":"[pehr-DEHR pohr]","english":"to lose by","example_es":"Perdimos por un punto.","example_en":"We lost by one point."}]'::jsonb,
    dialogue='[{"speaker":"Iván","spanish":"Estábamos ganando, pero sufrí una lesión.","english":"We were winning, but I suffered an injury."},{"speaker":"Eva","spanish":"¿Te recuperaste rápido?","english":"Did you recover quickly?"},{"speaker":"Iván","spanish":"En dos meses. Perdimos por un punto.","english":"In two months. We lost by one point."}]'::jsonb,
    grammar_note='Past progressive sets the scene; preterite breaks it: "Estábamos ganando cuando sufrí una lesión."'
  where id = v_l2;
  update public.lessons set intro='Phrases at the gym.',
    vocab_items='[{"word":"hacer cardio","phonetic":"[ah-SEHR KAR-dyoh]","english":"to do cardio","example_es":"Hago cardio media hora.","example_en":"I do cardio for half an hour."},{"word":"levantar pesas","phonetic":"[leh-bahn-TAR PEH-sahs]","english":"to lift weights","example_es":"Levanto pesas tres veces por semana.","example_en":"I lift weights three times a week."},{"word":"el entrenador","phonetic":"[ehn-treh-nah-DOHR]","english":"the trainer","example_es":"Mi entrenador es muy exigente.","example_en":"My trainer is very demanding."},{"word":"el calentamiento","phonetic":"[kah-lehn-tah-MYEHN-toh]","english":"warm-up","example_es":"Hago calentamiento primero.","example_en":"I warm up first."}]'::jsonb,
    dialogue='[{"speaker":"Tú","spanish":"Hago cardio media hora y luego levanto pesas.","english":"I do cardio for half an hour and then lift weights."},{"speaker":"Entrenador","spanish":"¿Haces calentamiento primero?","english":"Do you warm up first?"},{"speaker":"Tú","spanish":"Sí, diez minutos. Mi entrenador es exigente.","english":"Yes, ten minutes. My trainer is demanding."}]'::jsonb,
    grammar_note='"Hacer + sport" or "practicar + sport" are interchangeable for many activities: hago yoga / practico yoga. Both correct.'
  where id = v_l3;
  update public.lessons set intro='Listen to a sports commentator.',
    vocab_items='[{"word":"el partido","phonetic":"[pahr-TEE-doh]","english":"the match","example_es":"El partido está empatado.","example_en":"The match is tied."},{"word":"marcar","phonetic":"[mahr-KAR]","english":"to score","example_es":"Marcó el gol decisivo.","example_en":"He scored the decisive goal."},{"word":"el aficionado","phonetic":"[ah-fee-syoh-NAH-doh]","english":"the fan","example_es":"Los aficionados celebran.","example_en":"The fans celebrate."},{"word":"el descanso","phonetic":"[dehs-KAHN-soh]","english":"half-time","example_es":"En el descanso van empatados.","example_en":"At half-time they''re tied."}]'::jsonb,
    dialogue='[{"speaker":"Locutor","spanish":"Comienza la segunda parte del partido.","english":"The second half of the match begins."},{"speaker":"Locutor","spanish":"En el minuto sesenta y dos, ¡marca González!","english":"In minute 62, González scores!"},{"speaker":"Locutor","spanish":"Los aficionados celebran en las gradas.","english":"The fans celebrate in the stands."}]'::jsonb,
    grammar_note='Sports commentary uses lots of historical present: "marca", "lanza", "para" — even when narrating live action that''s essentially past.'
  where id = v_l4;
  update public.lessons set intro='Talk about your sport.',
    vocab_items='[{"word":"Practico fútbol","phonetic":"[prahk-TEE-koh]","english":"I play football","example_es":"Practico fútbol los sábados.","example_en":"I play football on Saturdays."},{"word":"Entreno tres veces","phonetic":"[ehn-TREH-noh]","english":"I train three times","example_es":"Entreno tres veces por semana.","example_en":"I train three times a week."},{"word":"Soy aficionado al","phonetic":"[SOY ah-fee-syoh-NAH-doh]","english":"I''m a fan of","example_es":"Soy aficionado al baloncesto.","example_en":"I''m a fan of basketball."},{"word":"Veo los partidos","phonetic":"[BEH-oh lohs pahr-TEE-dohs]","english":"I watch the matches","example_es":"Veo todos los partidos.","example_en":"I watch all the matches."}]'::jsonb,
    dialogue='[{"speaker":"Tú","spanish":"Practico fútbol los sábados.","english":"I play football on Saturdays."},{"speaker":"Amigo","spanish":"¿Vas al gimnasio entre semana?","english":"Do you go to the gym during the week?"},{"speaker":"Tú","spanish":"Sí, entreno tres veces por semana.","english":"Yes, I train three times a week."}]'::jsonb,
    grammar_note='"Aficionado A + sport" — fan of. "Aficionado al fútbol", "aficionada al tenis". Note the gender agreement with the speaker.'
  where id = v_l5;
  update public.lessons set intro='Read about sport benefits.',
    vocab_items='[{"word":"beneficiar","phonetic":"[beh-neh-fee-SYAR]","english":"to benefit","example_es":"El deporte beneficia la salud.","example_en":"Sport benefits health."},{"word":"reducir","phonetic":"[rreh-doo-SEER]","english":"to reduce","example_es":"Reduce el estrés.","example_en":"It reduces stress."},{"word":"la resistencia","phonetic":"[rreh-sees-TEHN-syah]","english":"endurance","example_es":"Mejora la resistencia.","example_en":"It improves endurance."},{"word":"al menos","phonetic":"[ahl MEH-nohs]","english":"at least","example_es":"Al menos treinta minutos al día.","example_en":"At least thirty minutes a day."}]'::jsonb,
    dialogue='[{"speaker":"Texto","spanish":"Practicar deporte regularmente beneficia la salud física y mental.","english":"Regular sports practice benefits physical and mental health."},{"speaker":"Texto","spanish":"Mejora la resistencia, reduce el estrés y favorece el sueño.","english":"It improves endurance, reduces stress and helps sleep."},{"speaker":"Texto","spanish":"Los expertos recomiendan al menos treinta minutos diarios.","english":"Experts recommend at least thirty minutes daily."}]'::jsonb,
    grammar_note='"Practicar deporte" — singular collective. Spanish often uses singular where English uses plural: "hacer ejercicio", "leer literatura".'
  where id = v_l6;
  update public.lessons set intro='Write about your fitness goal.',
    vocab_items='[{"word":"mi objetivo","phonetic":"[mee ohb-heh-TEE-boh]","english":"my goal","example_es":"Mi objetivo es correr un maratón.","example_en":"My goal is to run a marathon."},{"word":"a finales de","phonetic":"[ah fee-NAH-lehs deh]","english":"by the end of","example_es":"A finales de año.","example_en":"By the end of the year."},{"word":"voy mejorando","phonetic":"[BOY meh-hoh-RAHN-doh]","english":"I''m improving","example_es":"Voy mejorando poco a poco.","example_en":"I''m improving little by little."},{"word":"con disciplina","phonetic":"[kohn dees-see-PLEE-nah]","english":"with discipline","example_es":"Con disciplina lo lograré.","example_en":"With discipline I''ll do it."}]'::jsonb,
    dialogue='[{"speaker":"Modelo","spanish":"Mi objetivo es correr un maratón a finales de año.","english":"My goal is to run a marathon by the end of the year."},{"speaker":"Modelo","spanish":"Entreno cuatro días por semana y voy mejorando poco a poco.","english":"I train four days a week and I''m improving little by little."},{"speaker":"Modelo","spanish":"Con disciplina y paciencia, lo lograré.","english":"With discipline and patience, I''ll do it."}]'::jsonb,
    grammar_note='"Ir + gerund" expresses gradual progression: "voy mejorando", "vamos creciendo". Different from "estar + gerund" (current action).'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "championship"?','el campeonato',array['el árbitro','el entrenamiento','el partido'],'championship',1),
  (v_l1,'fill_blank','Complete: "____ a dos." (we drew)','Empatamos',array['Ganamos','Perdimos','Marcamos'],'we drew',2),
  (v_l1,'multiple_choice','What does "árbitro" mean?','referee',array['coach','captain','striker'],'referee',3),
  (v_l1,'listening','What did you hear?','Empatamos en la final',array['Ganamos el campeonato','El árbitro pitó penalti','El entrenamiento es intenso'],'We drew in the final',4),
  (v_l1,'speaking','Say this aloud: "El entrenamiento es intenso."','El entrenamiento es intenso',array[]::text[],'Training is intense.',5),
  (v_l2,'multiple_choice','How to say "I was winning"?','estaba ganando',array['gané','ganaba','ganaré'],'I was winning',1),
  (v_l2,'fill_blank','Complete: "____ por un punto." (we lost)','Perdimos',array['Empatamos','Ganamos','Marcamos'],'we lost',2),
  (v_l2,'multiple_choice','What does "sufrir una lesión" mean?','to suffer an injury',array['to recover','to win','to lose'],'to suffer an injury',3),
  (v_l2,'listening','What did you hear?','Sufrí una lesión en la rodilla',array['Me recuperé en dos meses','Estaba ganando dos a cero','Perdimos por un punto'],'I suffered a knee injury',4),
  (v_l2,'speaking','Say this aloud: "Me recuperé en dos meses."','Me recuperé en dos meses',array[]::text[],'I recovered in two months.',5),
  (v_l3,'multiple_choice','What is "warm-up"?','el calentamiento',array['el entrenador','las pesas','el cardio'],'warm-up',1),
  (v_l3,'fill_blank','Complete: "Hago ____ media hora." (cardio)','cardio',array['pesas','calentamiento','entrenamiento'],'cardio',2),
  (v_l3,'multiple_choice','What does "entrenador" mean?','trainer',array['referee','team','player'],'trainer',3),
  (v_l3,'listening','What did you hear?','Mi entrenador es exigente',array['Hago cardio media hora','Levanto pesas tres veces','¿Haces calentamiento primero?'],'My trainer is demanding',4),
  (v_l3,'speaking','Say this aloud: "Levanto pesas tres veces por semana."','Levanto pesas tres veces por semana',array[]::text[],'I lift weights three times a week.',5),
  (v_l4,'multiple_choice','What is "half-time"?','el descanso',array['el partido','el aficionado','el gol'],'half-time',1),
  (v_l4,'fill_blank','Complete: "____ el gol decisivo." (scored)','Marcó',array['Empató','Perdió','Sufrió'],'scored',2),
  (v_l4,'multiple_choice','What does "aficionados" mean?','fans',array['referees','coaches','players'],'fans',3),
  (v_l4,'listening','What did you hear?','¡Marca González!',array['Comienza la segunda parte','Los aficionados celebran','En el minuto sesenta y dos'],'González scores!',4),
  (v_l4,'speaking','Say this aloud: "Los aficionados celebran."','Los aficionados celebran',array[]::text[],'The fans celebrate.',5),
  (v_l5,'multiple_choice','How to say "I''m a fan of basketball"?','Soy aficionado al baloncesto',array['Practico fútbol','Entreno tres veces','Veo los partidos'],'I''m a fan of basketball',1),
  (v_l5,'fill_blank','Complete: "____ tres veces por semana." (I train)','Entreno',array['Practico','Veo','Soy'],'I train',2),
  (v_l5,'multiple_choice','What does "Veo los partidos" mean?','I watch the matches',array['I play matches','I miss matches','I attend matches'],'I watch the matches',3),
  (v_l5,'listening','What did you hear?','Sí, entreno tres veces por semana',array['Practico fútbol los sábados','¿Vas al gimnasio?','Soy aficionado al baloncesto'],'Yes, I train three times a week',4),
  (v_l5,'speaking','Say this aloud: "Practico fútbol los sábados."','Practico fútbol los sábados',array[]::text[],'I play football on Saturdays.',5),
  (v_l6,'multiple_choice','What does "beneficiar" mean?','to benefit',array['to harm','to slow','to ignore'],'to benefit',1),
  (v_l6,'fill_blank','Complete: "Mejora la ____" (endurance)','resistencia',array['salud','calma','presión'],'endurance',2),
  (v_l6,'multiple_choice','What does "al menos" mean?','at least',array['at most','exactly','rarely'],'at least',3),
  (v_l6,'listening','What did you hear?','Los expertos recomiendan al menos treinta minutos diarios',array['Practicar deporte regularmente beneficia la salud','Mejora la resistencia, reduce el estrés','Reduce el estrés y favorece el sueño'],'Experts recommend at least thirty minutes daily',4),
  (v_l6,'speaking','Say this aloud: "El deporte reduce el estrés."','El deporte reduce el estrés',array[]::text[],'Sport reduces stress.',5),
  (v_l7,'multiple_choice','How to say "I''m improving"?','voy mejorando',array['mejoro','mejoraba','mejoraré'],'I''m improving (gradually)',1),
  (v_l7,'fill_blank','Complete: "Con ____ lo lograré." (discipline)','disciplina',array['paciencia','energía','objetivo'],'discipline',2),
  (v_l7,'multiple_choice','What does "a finales de año" mean?','by the end of the year',array['at the start of the year','last year','every year'],'by the end of the year',3),
  (v_l7,'listening','What did you hear?','Entreno cuatro días por semana y voy mejorando poco a poco',array['Mi objetivo es correr un maratón','Con disciplina y paciencia, lo lograré','A finales de año'],'I train four days a week and I''m improving little by little',4),
  (v_l7,'speaking','Say this aloud: "Mi objetivo es correr un maratón."','Mi objetivo es correr un maratón',array[]::text[],'My goal is to run a marathon.',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','El árbitro pitó penalti',array['Ganamos el campeonato','El entrenamiento es intenso','Empatamos a dos'],'The referee called a penalty',6),
  (v_l1,'listening','What did you hear?','Ganamos el campeonato',array['El árbitro pitó penalti','Empatamos a dos','El entrenamiento es intenso'],'We won the championship',7),
  (v_l1,'speaking','Say this aloud: "Ganamos el campeonato."','Ganamos el campeonato',array[]::text[],'We won the championship.',8),
  (v_l1,'speaking','Say this aloud: "Empatamos en la final."','Empatamos en la final',array[]::text[],'We drew in the final.',9),
  (v_l2,'listening','What did you hear?','Estábamos ganando, pero sufrí una lesión',array['¿Te recuperaste rápido?','En dos meses','Perdimos por un punto'],'We were winning, but I suffered an injury',6),
  (v_l2,'listening','What did you hear?','Estaba ganando dos a cero',array['Sufrí una lesión','Me recuperé en dos meses','Perdimos por un punto'],'I was winning two to nothing',7),
  (v_l2,'speaking','Say this aloud: "Estábamos ganando cuando sufrí una lesión."','Estábamos ganando cuando sufrí una lesión',array[]::text[],'We were winning when I got injured.',8),
  (v_l2,'speaking','Say this aloud: "Perdimos por un punto."','Perdimos por un punto',array[]::text[],'We lost by one point.',9),
  (v_l3,'listening','What did you hear?','Hago calentamiento primero',array['Hago cardio media hora','Levanto pesas tres veces','Mi entrenador es exigente'],'I warm up first',6),
  (v_l3,'listening','What did you hear?','Levanto pesas tres veces por semana',array['Hago cardio media hora','Hago calentamiento primero','Mi entrenador es exigente'],'I lift weights three times a week',7),
  (v_l3,'speaking','Say this aloud: "Hago calentamiento primero."','Hago calentamiento primero',array[]::text[],'I warm up first.',8),
  (v_l3,'speaking','Say this aloud: "Mi entrenador es muy exigente."','Mi entrenador es muy exigente',array[]::text[],'My trainer is very demanding.',9),
  (v_l6,'listening','What did you hear?','Mejora la resistencia, reduce el estrés y favorece el sueño',array['Practicar deporte regularmente','Los expertos recomiendan al menos','Al menos treinta minutos al día'],'It improves endurance, reduces stress and helps sleep',6),
  (v_l6,'listening','What did you hear?','Practicar deporte regularmente beneficia la salud',array['Mejora la resistencia','Reduce el estrés','Los expertos recomiendan'],'Regular sports practice benefits health',7),
  (v_l6,'speaking','Say this aloud: "Practicar deporte beneficia la salud."','Practicar deporte beneficia la salud',array[]::text[],'Practising sport benefits health.',8),
  (v_l6,'speaking','Say this aloud: "Al menos treinta minutos al día."','Al menos treinta minutos al día',array[]::text[],'At least thirty minutes a day.',9),
  (v_l7,'listening','What did you hear?','Con disciplina y paciencia, lo lograré',array['Mi objetivo es correr','A finales de año','Entreno cuatro días'],'With discipline and patience, I''ll do it',6),
  (v_l7,'listening','What did you hear?','Voy mejorando poco a poco',array['Mi objetivo es correr un maratón','Con disciplina lo lograré','A finales de año'],'I''m improving little by little',7),
  (v_l7,'speaking','Say this aloud: "A finales de año correré el maratón."','A finales de año correré el maratón',array[]::text[],'By the end of the year I''ll run the marathon.',8),
  (v_l7,'speaking','Say this aloud: "Voy mejorando poco a poco."','Voy mejorando poco a poco',array[]::text[],'I''m improving little by little.',9);

  update public.lessons set type='conversation', title='Sports & Fitness — Conversation Practice',
    description='Two friends compare workouts.',
    intro='Pedro and Eva swap fitness habits at a café.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Pedro","spanish":"¿Sigues entrenando para el maratón?","english":"Are you still training for the marathon?"},{"speaker":"Eva","spanish":"Sí. Voy mejorando poco a poco. Corro cuatro veces por semana.","english":"Yes. I''m improving little by little. I run four times a week."},{"speaker":"Pedro","spanish":"¿Y haces calentamiento antes?","english":"And do you warm up beforehand?"},{"speaker":"Eva","spanish":"Sí, siempre. Mi entrenador es muy exigente.","english":"Yes, always. My trainer is very demanding."},{"speaker":"Pedro","spanish":"Estaba pensando en empezar a correr.","english":"I was thinking about starting to run."},{"speaker":"Eva","spanish":"Con disciplina, llegarás muy lejos.","english":"With discipline, you''ll go very far."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','What is Eva training for?','A marathon',array['A football match','A swim race','A bike race'],'¿Sigues entrenando para el maratón?',1),
  (v_l8,'multiple_choice','How often does Eva run?','Four times a week',array['Twice a week','Daily','Once a week'],'Corro cuatro veces por semana',2),
  (v_l8,'multiple_choice','Does she warm up?','Yes, always',array['No','Sometimes','Only Sundays'],'Sí, siempre',3),
  (v_l8,'multiple_choice','True or false: Pedro already runs.','False',array['True'],'Estaba pensando en empezar a correr',4),
  (v_l8,'fill_blank','Complete: "Voy ____ poco a poco." (improving)','mejorando',array['mejorar','mejoré','mejoraré'],'improving (gradually)',5),
  (v_l8,'multiple_choice','Eva''s advice to Pedro?','With discipline you''ll go far',array['Don''t bother','It''s too hard','Buy expensive shoes'],'Con disciplina, llegarás muy lejos',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Sports & Fitness', 'Review test for the Sports & Fitness section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "championship"?','el campeonato',array['el partido','el árbitro','el aficionado'],'championship',1),
  (v_lesson_id,'multiple_choice','Past progressive of "ganar" (I)?','estaba ganando',array['ganaba','ganaré','gané'],'I was winning',2),
  (v_lesson_id,'multiple_choice','What does "calentamiento" mean?','warm-up',array['training','stretching','cooldown'],'warm-up',3),
  (v_lesson_id,'multiple_choice','True/false: "ir + gerund" expresses gradual progress.','True',array['False'],'voy mejorando = gradually improving',4),
  (v_lesson_id,'fill_blank','Complete: "Al ____ treinta minutos al día." (at least)','menos',array['más','poco','mucho'],'at least',5),
  (v_lesson_id,'fill_blank','Complete: "Soy aficionado ____ baloncesto." (to the)','al',array['del','en el','con el'],'aficionado al',6),
  (v_lesson_id,'listening','What did you hear?','Empatamos en la final',array['Ganamos el campeonato','El árbitro pitó penalti','El entrenamiento es intenso'],'We drew in the final',7),
  (v_lesson_id,'listening','What did you hear?','Voy mejorando poco a poco',array['Mi objetivo es correr un maratón','Con disciplina lo lograré','A finales de año'],'I''m improving little by little',8),
  (v_lesson_id,'speaking','Say this aloud: "Practico fútbol los sábados."','Practico fútbol los sábados',array[]::text[],'I play football on Saturdays.',9),
  (v_lesson_id,'speaking','Say this aloud: "Con disciplina lo lograré."','Con disciplina lo lograré',array[]::text[],'With discipline I''ll do it.',10);

  -- ===========================================================
  -- B1.14 MUSIC & ENTERTAINMENT
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B1' and title = 'Music & Entertainment';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set intro='Music and entertainment vocabulary.',
    vocab_items='[{"word":"el género","phonetic":"[HEH-neh-roh]","english":"genre","example_es":"Mi género favorito es el rock.","example_en":"My favourite genre is rock."},{"word":"el estreno","phonetic":"[ehs-TREH-noh]","english":"premiere","example_es":"Fui al estreno de la película.","example_en":"I went to the film premiere."},{"word":"el guion","phonetic":"[gee-OHN]","english":"script","example_es":"El guion es brillante.","example_en":"The script is brilliant."},{"word":"el escenario","phonetic":"[eh-seh-NAH-ryoh]","english":"stage","example_es":"El cantante salió al escenario.","example_en":"The singer came onto the stage."}]'::jsonb,
    dialogue='[{"speaker":"Lola","spanish":"¿Fuiste al estreno?","english":"Did you go to the premiere?"},{"speaker":"Marco","spanish":"Sí, el guion es brillante.","english":"Yes, the script is brilliant."},{"speaker":"Lola","spanish":"¿De qué género es?","english":"What genre is it?"}]'::jsonb,
    grammar_note='"De qué + noun + es" = "what kind of + noun is it?" Useful question form: "¿De qué género es?", "¿De qué color es?"'
  where id = v_l1;
  update public.lessons set intro='Talking about reviews with subjunctive.',
    vocab_items='[{"word":"me parece que","phonetic":"[meh pah-REH-seh keh]","english":"I think that","example_es":"Me parece que es excelente.","example_en":"I think it''s excellent."},{"word":"no me parece que sea","phonetic":"[noh meh pah-REH-seh keh SEH-ah]","english":"I don''t think it''s","example_es":"No me parece que sea original.","example_en":"I don''t think it''s original."},{"word":"impresionante","phonetic":"[eem-preh-syoh-NAHN-teh]","english":"impressive","example_es":"La actuación fue impresionante.","example_en":"The performance was impressive."},{"word":"sobrevalorado","phonetic":"[soh-breh-bah-loh-RAH-doh]","english":"overrated","example_es":"Ese álbum está sobrevalorado.","example_en":"That album is overrated."}]'::jsonb,
    dialogue='[{"speaker":"Eva","spanish":"Me parece que es la mejor película del año.","english":"I think it''s the best film of the year."},{"speaker":"Iván","spanish":"No me parece que sea para tanto.","english":"I don''t think it''s such a big deal."},{"speaker":"Eva","spanish":"Para mí, la actuación fue impresionante.","english":"To me, the performance was impressive."}]'::jsonb,
    grammar_note='"Me parece que" + indicative. "No me parece que" + subjunctive — same rule as "creer que / no creer que".'
  where id = v_l2;
  update public.lessons set intro='Phrases at concerts and cinemas.',
    vocab_items='[{"word":"entradas agotadas","phonetic":"[ehn-TRAH-dahs ah-goh-TAH-dahs]","english":"tickets sold out","example_es":"Las entradas están agotadas.","example_en":"The tickets are sold out."},{"word":"hacer cola","phonetic":"[ah-SEHR KOH-lah]","english":"to queue","example_es":"Hicimos cola dos horas.","example_en":"We queued for two hours."},{"word":"el aforo","phonetic":"[ah-FOH-roh]","english":"capacity","example_es":"El aforo es de cinco mil.","example_en":"The capacity is five thousand."},{"word":"emocionante","phonetic":"[eh-moh-syoh-NAHN-teh]","english":"exciting","example_es":"Fue un concierto emocionante.","example_en":"It was an exciting concert."}]'::jsonb,
    dialogue='[{"speaker":"Marta","spanish":"Hicimos cola dos horas para entrar.","english":"We queued two hours to get in."},{"speaker":"Pedro","spanish":"¿Y mereció la pena?","english":"And was it worth it?"},{"speaker":"Marta","spanish":"Sí, fue emocionante. El aforo estaba completo.","english":"Yes, it was exciting. The venue was full."}]'::jsonb,
    grammar_note='"Merecer la pena + infinitive" = "to be worth it". A B1 essential expression.'
  where id = v_l3;
  update public.lessons set intro='Listen to a music review.',
    vocab_items='[{"word":"el álbum","phonetic":"[AHL-boom]","english":"album","example_es":"Su nuevo álbum es excelente.","example_en":"Their new album is excellent."},{"word":"el sencillo","phonetic":"[sehn-SEE-yoh]","english":"single","example_es":"Lanzaron un sencillo.","example_en":"They released a single."},{"word":"colaboración","phonetic":"[koh-lah-boh-rah-SYOHN]","english":"collaboration","example_es":"Una colaboración con Bad Bunny.","example_en":"A collaboration with Bad Bunny."},{"word":"la gira","phonetic":"[HEE-rah]","english":"tour","example_es":"Empiezan la gira mundial.","example_en":"They start the world tour."}]'::jsonb,
    dialogue='[{"speaker":"Locutor","spanish":"El nuevo álbum de Rosalía mezcla flamenco con reguetón.","english":"Rosalía''s new album mixes flamenco with reggaeton."},{"speaker":"Locutor","spanish":"Incluye una colaboración con Bad Bunny.","english":"It includes a collaboration with Bad Bunny."},{"speaker":"Locutor","spanish":"La gira mundial empieza en septiembre.","english":"The world tour begins in September."}]'::jsonb,
    grammar_note='Music journalism Spanish uses present indicative for ongoing description: "mezcla", "incluye", "empieza".'
  where id = v_l4;
  update public.lessons set intro='Speak about your taste.',
    vocab_items='[{"word":"Me encanta el cine","phonetic":"[meh ehn-KAHN-tah]","english":"I love cinema","example_es":"Me encanta el cine español.","example_en":"I love Spanish cinema."},{"word":"Voy al cine","phonetic":"[BOY ahl SEE-neh]","english":"I go to the cinema","example_es":"Voy al cine una vez al mes.","example_en":"I go to the cinema once a month."},{"word":"Mi cantante favorito","phonetic":"[mee kahn-TAHN-teh]","english":"My favourite singer","example_es":"Mi cantante favorito es Pablo Alborán.","example_en":"My favourite singer is Pablo Alborán."},{"word":"Suelo escuchar","phonetic":"[SWEH-loh]","english":"I usually listen to","example_es":"Suelo escuchar pop latino.","example_en":"I usually listen to Latin pop."}]'::jsonb,
    dialogue='[{"speaker":"Tú","spanish":"Me encanta el cine español.","english":"I love Spanish cinema."},{"speaker":"Amigo","spanish":"¿Y de música?","english":"And music?"},{"speaker":"Tú","spanish":"Suelo escuchar pop latino. Mi cantante favorito es Pablo Alborán.","english":"I usually listen to Latin pop. My favourite singer is Pablo Alborán."}]'::jsonb,
    grammar_note='"Soler + infinitive" describes habits: "suelo escuchar", "suelo ver". A more elegant B1 alternative to "siempre + verb".'
  where id = v_l5;
  update public.lessons set intro='Read a film review.',
    vocab_items='[{"word":"el director","phonetic":"[dee-rehk-TOHR]","english":"director","example_es":"El director es chileno.","example_en":"The director is Chilean."},{"word":"interpretar","phonetic":"[een-tehr-preh-TAR]","english":"to play (a role)","example_es":"Interpreta a un detective.","example_en":"He plays a detective."},{"word":"la trama","phonetic":"[TRAH-mah]","english":"the plot","example_es":"La trama te atrapa.","example_en":"The plot grips you."},{"word":"premiada","phonetic":"[preh-MYAH-dah]","english":"award-winning","example_es":"Una película premiada.","example_en":"An award-winning film."}]'::jsonb,
    dialogue='[{"speaker":"Texto","spanish":"La nueva película de Pedro Almodóvar fue premiada en Cannes.","english":"Pedro Almodóvar''s new film won an award at Cannes."},{"speaker":"Texto","spanish":"Penélope Cruz interpreta a una madre que busca la verdad.","english":"Penélope Cruz plays a mother searching for the truth."},{"speaker":"Texto","spanish":"La trama te atrapa desde el primer minuto.","english":"The plot grips you from the first minute."}]'::jsonb,
    grammar_note='"Atrapar" (literally to trap / catch) = "to grip" or "to captivate" in reviews. Used metaphorically for narratives.'
  where id = v_l6;
  update public.lessons set intro='Write a short film or concert review.',
    vocab_items='[{"word":"no te la pierdas","phonetic":"[noh teh lah PYEHR-dahs]","english":"don''t miss it","example_es":"Es genial, no te la pierdas.","example_en":"It''s great, don''t miss it."},{"word":"lo mejor","phonetic":"[loh meh-HOR]","english":"the best","example_es":"Lo mejor es el final.","example_en":"The best part is the ending."},{"word":"lo peor","phonetic":"[loh peh-OHR]","english":"the worst","example_es":"Lo peor fue el guion.","example_en":"The worst part was the script."},{"word":"vale la pena","phonetic":"[BAH-leh lah PEH-nah]","english":"it''s worth it","example_es":"Vale la pena verla.","example_en":"It''s worth watching."}]'::jsonb,
    dialogue='[{"speaker":"Modelo","spanish":"La nueva película de Almodóvar es brillante.","english":"Almodóvar''s new film is brilliant."},{"speaker":"Modelo","spanish":"Lo mejor es la actuación de Penélope Cruz; lo peor, un final algo confuso.","english":"The best is Penélope Cruz''s acting; the worst, a somewhat confusing ending."},{"speaker":"Modelo","spanish":"Vale la pena verla. No te la pierdas.","english":"It''s worth seeing. Don''t miss it."}]'::jsonb,
    grammar_note='"Lo + adjective" creates abstract noun: "lo mejor" (the best part), "lo malo" (the bad thing). Common B1 construction.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "genre"?','el género',array['el estreno','el guion','el escenario'],'genre',1),
  (v_l1,'fill_blank','Complete: "Fui al ____ de la película." (premiere)','estreno',array['guion','género','escenario'],'premiere',2),
  (v_l1,'multiple_choice','What does "el escenario" mean?','the stage',array['the script','the genre','the audience'],'stage',3),
  (v_l1,'listening','What did you hear?','¿Fuiste al estreno?',array['Mi género favorito es el rock','Sí, el guion es brillante','El cantante salió al escenario'],'Did you go to the premiere?',4),
  (v_l1,'speaking','Say this aloud: "El guion es brillante."','El guion es brillante',array[]::text[],'The script is brilliant.',5),
  (v_l2,'multiple_choice','What follows "no me parece que"?','subjunctive',array['imperfect','preterite','indicative'],'subjunctive',1),
  (v_l2,'fill_blank','Complete: "Ese álbum está ____" (overrated)','sobrevalorado',array['impresionante','emocionante','premiado'],'overrated',2),
  (v_l2,'multiple_choice','What does "para tanto" mean?','such a big deal',array['way too much','too late','great enough'],'such a big deal',3),
  (v_l2,'listening','What did you hear?','No me parece que sea para tanto',array['Me parece que es excelente','La actuación fue impresionante','Ese álbum está sobrevalorado'],'I don''t think it''s such a big deal',4),
  (v_l2,'speaking','Say this aloud: "La actuación fue impresionante."','La actuación fue impresionante',array[]::text[],'The performance was impressive.',5),
  (v_l3,'multiple_choice','How to say "to queue"?','hacer cola',array['merecer la pena','hacer cardio','hacer cola con'],'to queue',1),
  (v_l3,'fill_blank','Complete: "Las entradas están ____" (sold out)','agotadas',array['agotada','agotado','agotando'],'sold out',2),
  (v_l3,'multiple_choice','What does "aforo" mean?','capacity',array['stage','ticket','queue'],'capacity',3),
  (v_l3,'listening','What did you hear?','Hicimos cola dos horas para entrar',array['¿Y mereció la pena?','El aforo estaba completo','Fue un concierto emocionante'],'We queued two hours to get in',4),
  (v_l3,'speaking','Say this aloud: "Mereció la pena."','Mereció la pena',array[]::text[],'It was worth it.',5),
  (v_l4,'multiple_choice','What is "tour"?','la gira',array['el sencillo','el álbum','la colaboración'],'tour',1),
  (v_l4,'fill_blank','Complete: "Lanzaron un ____" (single)','sencillo',array['álbum','gira','género'],'single',2),
  (v_l4,'multiple_choice','What does "colaboración" mean?','collaboration',array['tour','album','review'],'collaboration',3),
  (v_l4,'listening','What did you hear?','La gira mundial empieza en septiembre',array['Su nuevo álbum es excelente','Incluye una colaboración con Bad Bunny','El nuevo álbum mezcla flamenco'],'The world tour begins in September',4),
  (v_l4,'speaking','Say this aloud: "Su nuevo álbum es excelente."','Su nuevo álbum es excelente',array[]::text[],'Their new album is excellent.',5),
  (v_l5,'multiple_choice','How to say "I usually listen to"?','Suelo escuchar',array['Me encanta el cine','Voy al cine','Mi cantante favorito'],'I usually listen to',1),
  (v_l5,'fill_blank','Complete: "Voy al cine una ____ al mes." (time)','vez',array['veces','día','año'],'time (once)',2),
  (v_l5,'multiple_choice','What does "Suelo escuchar" mean?','I usually listen to',array['I love listening','I rarely listen','I dislike'],'I usually listen to',3),
  (v_l5,'listening','What did you hear?','Mi cantante favorito es Pablo Alborán',array['Me encanta el cine español','Voy al cine una vez al mes','Suelo escuchar pop latino'],'My favourite singer is Pablo Alborán',4),
  (v_l5,'speaking','Say this aloud: "Voy al cine una vez al mes."','Voy al cine una vez al mes',array[]::text[],'I go to the cinema once a month.',5),
  (v_l6,'multiple_choice','What does "interpretar" mean?','to play (a role)',array['to interpret','to translate','to perform music'],'to play a role',1),
  (v_l6,'fill_blank','Complete: "La trama te ____" (grips you)','atrapa',array['busca','interpreta','premia'],'grips you',2),
  (v_l6,'multiple_choice','What is "premiada"?','award-winning',array['premiering','to premiere','underrated'],'award-winning',3),
  (v_l6,'listening','What did you hear?','Penélope Cruz interpreta a una madre que busca la verdad',array['La nueva película de Pedro Almodóvar','La trama te atrapa desde el primer minuto','Una película premiada'],'Penélope Cruz plays a mother searching for the truth',4),
  (v_l6,'speaking','Say this aloud: "La trama te atrapa."','La trama te atrapa',array[]::text[],'The plot grips you.',5),
  (v_l7,'multiple_choice','How to say "don''t miss it"?','no te la pierdas',array['vale la pena','lo mejor','lo peor'],'don''t miss it',1),
  (v_l7,'fill_blank','Complete: "Lo ____ es el final." (best)','mejor',array['peor','bueno','único'],'best',2),
  (v_l7,'multiple_choice','What does "vale la pena" mean?','it''s worth it',array['it''s expensive','it''s a pain','it''s great'],'it''s worth it',3),
  (v_l7,'listening','What did you hear?','Lo mejor es la actuación de Penélope Cruz',array['Lo peor, un final algo confuso','Vale la pena verla','No te la pierdas'],'The best is Penélope Cruz''s acting',4),
  (v_l7,'speaking','Say this aloud: "Vale la pena verla."','Vale la pena verla',array[]::text[],'It''s worth seeing.',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','El cantante salió al escenario',array['Mi género favorito es el rock','Fui al estreno','El guion es brillante'],'The singer came onto the stage',6),
  (v_l1,'listening','What did you hear?','Mi género favorito es el rock',array['Fui al estreno de la película','El guion es brillante','El cantante salió al escenario'],'My favourite genre is rock',7),
  (v_l1,'speaking','Say this aloud: "El cantante salió al escenario."','El cantante salió al escenario',array[]::text[],'The singer came onto the stage.',8),
  (v_l1,'speaking','Say this aloud: "Fui al estreno de la película."','Fui al estreno de la película',array[]::text[],'I went to the film premiere.',9),
  (v_l2,'listening','What did you hear?','La actuación fue impresionante',array['Me parece que es excelente','No me parece que sea original','Ese álbum está sobrevalorado'],'The performance was impressive',6),
  (v_l2,'listening','What did you hear?','Me parece que es la mejor película del año',array['No me parece que sea para tanto','Para mí, la actuación fue impresionante','La actuación fue impresionante'],'I think it''s the best film of the year',7),
  (v_l2,'speaking','Say this aloud: "Me parece que es excelente."','Me parece que es excelente',array[]::text[],'I think it''s excellent.',8),
  (v_l2,'speaking','Say this aloud: "No me parece que sea original."','No me parece que sea original',array[]::text[],'I don''t think it''s original.',9),
  (v_l3,'listening','What did you hear?','El aforo es de cinco mil',array['Las entradas están agotadas','Hicimos cola dos horas','Fue un concierto emocionante'],'The capacity is five thousand',6),
  (v_l3,'listening','What did you hear?','Fue un concierto emocionante',array['Hicimos cola dos horas','Las entradas están agotadas','El aforo está completo'],'It was an exciting concert',7),
  (v_l3,'speaking','Say this aloud: "Las entradas están agotadas."','Las entradas están agotadas',array[]::text[],'The tickets are sold out.',8),
  (v_l3,'speaking','Say this aloud: "El aforo estaba completo."','El aforo estaba completo',array[]::text[],'The venue was full.',9),
  (v_l6,'listening','What did you hear?','La nueva película de Pedro Almodóvar fue premiada en Cannes',array['Penélope Cruz interpreta','La trama te atrapa','Es chileno'],'Pedro Almodóvar''s new film won an award at Cannes',6),
  (v_l6,'listening','What did you hear?','Una película premiada',array['Penélope Cruz interpreta','La trama te atrapa','El director es chileno'],'An award-winning film',7),
  (v_l6,'speaking','Say this aloud: "Penélope Cruz interpreta a una madre."','Penélope Cruz interpreta a una madre',array[]::text[],'Penélope Cruz plays a mother.',8),
  (v_l6,'speaking','Say this aloud: "Una película premiada."','Una película premiada',array[]::text[],'An award-winning film.',9),
  (v_l7,'listening','What did you hear?','No te la pierdas',array['Lo mejor es el final','Lo peor fue el guion','Vale la pena verla'],'Don''t miss it',6),
  (v_l7,'listening','What did you hear?','Lo peor fue el guion',array['Lo mejor es el final','Vale la pena verla','No te la pierdas'],'The worst was the script',7),
  (v_l7,'speaking','Say this aloud: "No te la pierdas."','No te la pierdas',array[]::text[],'Don''t miss it.',8),
  (v_l7,'speaking','Say this aloud: "Lo mejor es el final."','Lo mejor es el final',array[]::text[],'The best is the ending.',9);

  update public.lessons set type='conversation', title='Music & Entertainment — Conversation Practice',
    description='Two friends debate a film and a concert.',
    intro='Lola and Marco compare their favourite Saturday night plans.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Lola","spanish":"¿Fuiste al concierto el sábado?","english":"Did you go to the concert on Saturday?"},{"speaker":"Marco","spanish":"Sí. Hicimos cola dos horas pero mereció la pena.","english":"Yes. We queued for two hours but it was worth it."},{"speaker":"Lola","spanish":"Yo fui al estreno de la nueva de Almodóvar.","english":"I went to the premiere of Almodóvar''s new film."},{"speaker":"Marco","spanish":"¿Y qué tal?","english":"And how was it?"},{"speaker":"Lola","spanish":"Lo mejor es la actuación de Penélope. Vale la pena verla.","english":"The best part is Penélope''s acting. It''s worth seeing."},{"speaker":"Marco","spanish":"A mí no me parece que el cine de Almodóvar sea para todos, pero la veré.","english":"I don''t think Almodóvar''s cinema is for everyone, but I''ll watch it."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','How long did Marco queue?','Two hours',array['One hour','Three hours','Half an hour'],'Hicimos cola dos horas',1),
  (v_l8,'multiple_choice','Was it worth it for Marco?','Yes',array['No','Doesn''t say','Partly'],'mereció la pena',2),
  (v_l8,'multiple_choice','What did Lola go to?','Almodóvar''s premiere',array['A concert','A play','A festival'],'el estreno de la nueva de Almodóvar',3),
  (v_l8,'multiple_choice','True or false: Marco loves Almodóvar without reservation.','False',array['True'],'no me parece que sea para todos',4),
  (v_l8,'fill_blank','Complete: "____ ver la película." (it''s worth)','Vale la pena',array['No te la pierdas','Lo mejor','Lo peor'],'it''s worth',5),
  (v_l8,'multiple_choice','Will Marco watch the film?','Yes',array['No','Maybe','He already has'],'pero la veré',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Music & Entertainment', 'Review test for the Music & Entertainment section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "stage"?','el escenario',array['el guion','el estreno','el género'],'stage',1),
  (v_lesson_id,'multiple_choice','"No me parece que" triggers...','subjunctive',array['preterite','imperfect','indicative'],'subjunctive',2),
  (v_lesson_id,'multiple_choice','What does "merecer la pena" mean?','to be worth it',array['to last','to enjoy','to disappoint'],'to be worth it',3),
  (v_lesson_id,'multiple_choice','True/false: "lo mejor" = the best part.','True',array['False'],'lo + adj = abstract noun',4),
  (v_lesson_id,'fill_blank','Complete: "____ escuchar pop latino." (I usually)','Suelo',array['Quiero','Empiezo','Voy'],'I usually',5),
  (v_lesson_id,'fill_blank','Complete: "Una película ____" (award-winning)','premiada',array['premiar','premio','premios'],'award-winning',6),
  (v_lesson_id,'listening','What did you hear?','Las entradas están agotadas',array['Hicimos cola dos horas','El aforo está completo','Fue un concierto emocionante'],'The tickets are sold out',7),
  (v_lesson_id,'listening','What did you hear?','Lo mejor es la actuación',array['Vale la pena verla','No te la pierdas','Lo peor fue el guion'],'The best part is the acting',8),
  (v_lesson_id,'speaking','Say this aloud: "Vale la pena verla."','Vale la pena verla',array[]::text[],'It''s worth seeing.',9),
  (v_lesson_id,'speaking','Say this aloud: "Suelo escuchar pop latino."','Suelo escuchar pop latino',array[]::text[],'I usually listen to Latin pop.',10);

  -- ===========================================================
  -- B1.15 SCIENCE BASICS
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B1' and title = 'Science Basics';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set intro='Science vocabulary at B1.',
    vocab_items='[{"word":"el experimento","phonetic":"[ehks-peh-ree-MEHN-toh]","english":"experiment","example_es":"El experimento dura una semana.","example_en":"The experiment lasts a week."},{"word":"la hipótesis","phonetic":"[ee-POH-teh-sees]","english":"hypothesis","example_es":"Nuestra hipótesis es clara.","example_en":"Our hypothesis is clear."},{"word":"el laboratorio","phonetic":"[lah-boh-rah-TOH-ryoh]","english":"laboratory","example_es":"Trabajo en un laboratorio.","example_en":"I work in a laboratory."},{"word":"comprobar","phonetic":"[kohm-proh-BAR]","english":"to verify","example_es":"Hay que comprobar los datos.","example_en":"We have to verify the data."}]'::jsonb,
    dialogue='[{"speaker":"Eva","spanish":"¿Cómo va el experimento?","english":"How''s the experiment going?"},{"speaker":"Luis","spanish":"Bien. Tenemos que comprobar la hipótesis.","english":"Well. We need to verify the hypothesis."},{"speaker":"Eva","spanish":"¿Y los datos del laboratorio?","english":"And the lab data?"}]'::jsonb,
    grammar_note='"Comprobar" vs "verificar" — both mean to verify. "Comprobar" is more everyday Spanish, "verificar" is more formal.'
  where id = v_l1;
  update public.lessons set intro='Passive voice with se.',
    vocab_items='[{"word":"se descubrió","phonetic":"[seh dehs-koo-BRYOH]","english":"was discovered","example_es":"Se descubrió en 1928.","example_en":"It was discovered in 1928."},{"word":"se ha demostrado","phonetic":"[seh ah deh-mohs-TRAH-doh]","english":"it has been shown","example_es":"Se ha demostrado el efecto.","example_en":"The effect has been shown."},{"word":"se observa","phonetic":"[seh ohb-SEHR-bah]","english":"is observed","example_es":"Se observa un patrón claro.","example_en":"A clear pattern is observed."},{"word":"se concluye que","phonetic":"[seh kohn-KLOO-yeh keh]","english":"it is concluded that","example_es":"Se concluye que el tratamiento funciona.","example_en":"It is concluded that the treatment works."}]'::jsonb,
    dialogue='[{"speaker":"Profesor","spanish":"La penicilina se descubrió en 1928.","english":"Penicillin was discovered in 1928."},{"speaker":"Estudiante","spanish":"¿Y se ha demostrado su eficacia?","english":"And has its effectiveness been shown?"},{"speaker":"Profesor","spanish":"Sí, se ha demostrado en miles de estudios.","english":"Yes, it has been demonstrated in thousands of studies."}]'::jsonb,
    grammar_note='Passive "se" + 3rd person verb = generic passive. "Se descubrió" = "was discovered" (no agent). Standard in scientific Spanish.'
  where id = v_l2;
  update public.lessons set intro='Phrases for explaining a phenomenon.',
    vocab_items='[{"word":"se debe a","phonetic":"[seh DEH-beh ah]","english":"is due to","example_es":"Se debe a la temperatura.","example_en":"It''s due to the temperature."},{"word":"depende de","phonetic":"[deh-PEHN-deh deh]","english":"depends on","example_es":"Depende de varios factores.","example_en":"It depends on several factors."},{"word":"por ejemplo","phonetic":"[pohr eh-HEHM-ploh]","english":"for example","example_es":"Por ejemplo, en el agua.","example_en":"For example, in water."},{"word":"en otras palabras","phonetic":"[ehn OH-trahs pah-LAH-brahs]","english":"in other words","example_es":"En otras palabras, no funciona.","example_en":"In other words, it doesn''t work."}]'::jsonb,
    dialogue='[{"speaker":"Profesora","spanish":"El cambio climático se debe a la actividad humana.","english":"Climate change is due to human activity."},{"speaker":"Estudiante","spanish":"¿Por ejemplo?","english":"For example?"},{"speaker":"Profesora","spanish":"Por ejemplo, la quema de combustibles fósiles.","english":"For example, the burning of fossil fuels."}]'::jsonb,
    grammar_note='"Deberse a" = causation. Different from "debe + infinitive" (obligation): "se debe a" (is caused by) vs "debe estudiar" (must study).'
  where id = v_l3;
  update public.lessons set intro='Listen to a science podcast.',
    vocab_items='[{"word":"el avance científico","phonetic":"[ah-BAHN-seh syehn-TEE-fee-koh]","english":"scientific advance","example_es":"Un nuevo avance científico.","example_en":"A new scientific advance."},{"word":"la vacuna","phonetic":"[bah-KOO-nah]","english":"vaccine","example_es":"La vacuna está disponible.","example_en":"The vaccine is available."},{"word":"el genoma","phonetic":"[heh-NOH-mah]","english":"genome","example_es":"Analizan el genoma humano.","example_en":"They analyse the human genome."},{"word":"reducir el riesgo","phonetic":"[rreh-doo-SEER ehl RRYEHS-goh]","english":"reduce the risk","example_es":"Para reducir el riesgo.","example_en":"To reduce the risk."}]'::jsonb,
    dialogue='[{"speaker":"Podcast","spanish":"Un nuevo avance científico podría reducir el riesgo de Alzheimer.","english":"A new scientific advance could reduce the risk of Alzheimer''s."},{"speaker":"Podcast","spanish":"Los investigadores analizaron el genoma de cinco mil pacientes.","english":"Researchers analysed the genome of five thousand patients."},{"speaker":"Podcast","spanish":"Una vacuna preventiva podría estar disponible en cinco años.","english":"A preventive vaccine could be available in five years."}]'::jsonb,
    grammar_note='Conditional in science: "podría reducir", "podría estar". Hedge for results not yet proven: "could reduce", not "will reduce".'
  where id = v_l4;
  update public.lessons set intro='Talk about a topic that interests you.',
    vocab_items='[{"word":"Me fascina","phonetic":"[meh fah-SEE-nah]","english":"I''m fascinated by","example_es":"Me fascina la astronomía.","example_en":"I''m fascinated by astronomy."},{"word":"He leído sobre","phonetic":"[eh leh-EE-doh SOH-breh]","english":"I''ve read about","example_es":"He leído sobre los agujeros negros.","example_en":"I''ve read about black holes."},{"word":"Es complejo pero","phonetic":"[ehs kohm-PLEH-hoh]","english":"It''s complex but","example_es":"Es complejo pero interesante.","example_en":"It''s complex but interesting."},{"word":"Me gustaría aprender","phonetic":"[meh goos-tah-REE-ah]","english":"I''d like to learn","example_es":"Me gustaría aprender física.","example_en":"I''d like to learn physics."}]'::jsonb,
    dialogue='[{"speaker":"Tú","spanish":"Me fascina la astronomía.","english":"I''m fascinated by astronomy."},{"speaker":"Amigo","spanish":"¿Has leído algo en concreto?","english":"Have you read anything specific?"},{"speaker":"Tú","spanish":"Sí, sobre los agujeros negros. Es complejo pero interesante.","english":"Yes, about black holes. It''s complex but interesting."}]'::jsonb,
    grammar_note='"Me gustaría + infinitive" = "I''d like to". Conditional of gustar. Softer than "quiero" (I want).'
  where id = v_l5;
  update public.lessons set intro='Read about a discovery.',
    vocab_items='[{"word":"el descubrimiento","phonetic":"[dehs-koo-bree-MYEHN-toh]","english":"discovery","example_es":"Un descubrimiento sorprendente.","example_en":"A surprising discovery."},{"word":"el investigador","phonetic":"[een-behs-tee-gah-DOHR]","english":"researcher","example_es":"Los investigadores del MIT.","example_en":"MIT researchers."},{"word":"abrir nuevas puertas","phonetic":"[ah-BREER NWEH-bahs PWEHR-tahs]","english":"to open new doors","example_es":"Esto abre nuevas puertas.","example_en":"This opens new doors."},{"word":"revolucionar","phonetic":"[rreh-boh-loo-syoh-NAR]","english":"to revolutionize","example_es":"Podría revolucionar la medicina.","example_en":"It could revolutionize medicine."}]'::jsonb,
    dialogue='[{"speaker":"Texto","spanish":"Un equipo de investigadores del MIT logró un avance sorprendente en computación cuántica.","english":"An MIT research team achieved a surprising advance in quantum computing."},{"speaker":"Texto","spanish":"Este descubrimiento podría revolucionar la criptografía.","english":"This discovery could revolutionize cryptography."},{"speaker":"Texto","spanish":"Abre nuevas puertas en el campo de la inteligencia artificial.","english":"It opens new doors in the field of artificial intelligence."}]'::jsonb,
    grammar_note='"Lograr + infinitive" = "to manage to". "Lograron descubrir" = "they managed to discover". Common in scientific reporting.'
  where id = v_l6;
  update public.lessons set intro='Write a short science news piece.',
    vocab_items='[{"word":"según los expertos","phonetic":"[seh-GOON]","english":"according to experts","example_es":"Según los expertos, es posible.","example_en":"According to experts, it''s possible."},{"word":"podría","phonetic":"[poh-DREE-ah]","english":"could","example_es":"Podría cambiar todo.","example_en":"It could change everything."},{"word":"en los próximos años","phonetic":"[ehn lohs PROHK-see-mohs]","english":"in the coming years","example_es":"En los próximos años habrá novedades.","example_en":"In the coming years there will be news."},{"word":"impacto","phonetic":"[eem-PAHK-toh]","english":"impact","example_es":"El impacto será enorme.","example_en":"The impact will be huge."}]'::jsonb,
    dialogue='[{"speaker":"Modelo","spanish":"Según los expertos, la inteligencia artificial podría revolucionar la educación.","english":"According to experts, artificial intelligence could revolutionize education."},{"speaker":"Modelo","spanish":"En los próximos años se desarrollarán nuevas herramientas de aprendizaje.","english":"In the coming years new learning tools will be developed."},{"speaker":"Modelo","spanish":"El impacto sobre el aula tradicional será profundo.","english":"The impact on the traditional classroom will be profound."}]'::jsonb,
    grammar_note='"Se desarrollarán" = passive se + future. Standard in formal predictive writing.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "hypothesis"?','la hipótesis',array['el experimento','el laboratorio','el descubrimiento'],'hypothesis',1),
  (v_l1,'fill_blank','Complete: "Hay que ____ los datos." (verify)','comprobar',array['descubrir','observar','demostrar'],'verify',2),
  (v_l1,'multiple_choice','What does "laboratorio" mean?','laboratory',array['library','classroom','observatory'],'laboratory',3),
  (v_l1,'listening','What did you hear?','Tenemos que comprobar la hipótesis',array['El experimento dura una semana','Nuestra hipótesis es clara','Trabajo en un laboratorio'],'We need to verify the hypothesis',4),
  (v_l1,'speaking','Say this aloud: "Nuestra hipótesis es clara."','Nuestra hipótesis es clara',array[]::text[],'Our hypothesis is clear.',5),
  (v_l2,'multiple_choice','How to say "was discovered"?','se descubrió',array['descubrió','se descubre','se descubría'],'was discovered',1),
  (v_l2,'fill_blank','Complete: "Se ha ____ el efecto." (shown)','demostrado',array['observado','concluido','descubierto'],'shown',2),
  (v_l2,'multiple_choice','What does "se observa" mean?','is observed',array['observed','observing','obscure'],'is observed',3),
  (v_l2,'listening','What did you hear?','La penicilina se descubrió en 1928',array['Se observa un patrón claro','Se concluye que el tratamiento funciona','Se ha demostrado en miles de estudios'],'Penicillin was discovered in 1928',4),
  (v_l2,'speaking','Say this aloud: "Se ha demostrado el efecto."','Se ha demostrado el efecto',array[]::text[],'The effect has been shown.',5),
  (v_l3,'multiple_choice','How to say "is due to"?','se debe a',array['depende de','por ejemplo','en otras palabras'],'is due to',1),
  (v_l3,'fill_blank','Complete: "____ varios factores." (depends on)','Depende de',array['Se debe a','Por ejemplo','En otras palabras'],'depends on',2),
  (v_l3,'multiple_choice','What does "en otras palabras" mean?','in other words',array['for example','therefore','however'],'in other words',3),
  (v_l3,'listening','What did you hear?','El cambio climático se debe a la actividad humana',array['Por ejemplo, la quema de combustibles','Depende de varios factores','Se debe a la temperatura'],'Climate change is due to human activity',4),
  (v_l3,'speaking','Say this aloud: "Se debe a la temperatura."','Se debe a la temperatura',array[]::text[],'It''s due to the temperature.',5),
  (v_l4,'multiple_choice','What is "vaccine"?','la vacuna',array['el genoma','el avance','el riesgo'],'vaccine',1),
  (v_l4,'fill_blank','Complete: "Para ____ el riesgo." (reduce)','reducir',array['analizar','observar','descubrir'],'reduce',2),
  (v_l4,'multiple_choice','What does "el genoma" mean?','genome',array['gene','genealogy','generation'],'genome',3),
  (v_l4,'listening','What did you hear?','Los investigadores analizaron el genoma de cinco mil pacientes',array['Un nuevo avance científico podría reducir el riesgo','Una vacuna preventiva podría estar disponible','Para reducir el riesgo'],'Researchers analysed the genome of 5000 patients',4),
  (v_l4,'speaking','Say this aloud: "Una vacuna preventiva podría estar disponible."','Una vacuna preventiva podría estar disponible',array[]::text[],'A preventive vaccine could be available.',5),
  (v_l5,'multiple_choice','How to say "I''m fascinated by"?','Me fascina',array['He leído sobre','Es complejo pero','Me gustaría aprender'],'I''m fascinated by',1),
  (v_l5,'fill_blank','Complete: "Me ____ aprender física." (I''d like)','gustaría',array['gusta','gustaba','gustó'],'I''d like',2),
  (v_l5,'multiple_choice','What does "Es complejo pero interesante" mean?','It''s complex but interesting',array['It''s simple but boring','It''s clear and easy','It''s difficult and useless'],'It''s complex but interesting',3),
  (v_l5,'listening','What did you hear?','Sí, sobre los agujeros negros',array['Me fascina la astronomía','¿Has leído algo en concreto?','Es complejo pero interesante'],'Yes, about black holes',4),
  (v_l5,'speaking','Say this aloud: "Me fascina la astronomía."','Me fascina la astronomía',array[]::text[],'I''m fascinated by astronomy.',5),
  (v_l6,'multiple_choice','What is "researcher"?','el investigador',array['el descubrimiento','el genoma','el avance'],'researcher',1),
  (v_l6,'fill_blank','Complete: "Podría ____ la medicina." (revolutionize)','revolucionar',array['comprobar','abrir','reducir'],'revolutionize',2),
  (v_l6,'multiple_choice','What does "abrir nuevas puertas" mean?','to open new doors',array['to find new keys','to open windows','to close roads'],'to open new doors',3),
  (v_l6,'listening','What did you hear?','Este descubrimiento podría revolucionar la criptografía',array['Un equipo de investigadores del MIT','Abre nuevas puertas','En el campo de la IA'],'This discovery could revolutionize cryptography',4),
  (v_l6,'speaking','Say this aloud: "Esto abre nuevas puertas."','Esto abre nuevas puertas',array[]::text[],'This opens new doors.',5),
  (v_l7,'multiple_choice','How to say "according to experts"?','según los expertos',array['en los próximos años','impacto','podría'],'according to experts',1),
  (v_l7,'fill_blank','Complete: "En los próximos ____" (years)','años',array['días','meses','semanas'],'years',2),
  (v_l7,'multiple_choice','What does "podría" mean?','could',array['will','should','wants to'],'could',3),
  (v_l7,'listening','What did you hear?','En los próximos años se desarrollarán nuevas herramientas',array['Según los expertos, la IA podría','El impacto sobre el aula será profundo','La inteligencia artificial podría revolucionar'],'In the coming years new tools will be developed',4),
  (v_l7,'speaking','Say this aloud: "El impacto será enorme."','El impacto será enorme',array[]::text[],'The impact will be huge.',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','El experimento dura una semana',array['Nuestra hipótesis es clara','Trabajo en un laboratorio','Hay que comprobar los datos'],'The experiment lasts a week',6),
  (v_l1,'listening','What did you hear?','Trabajo en un laboratorio',array['El experimento dura una semana','Nuestra hipótesis es clara','Tenemos que comprobar la hipótesis'],'I work in a laboratory',7),
  (v_l1,'speaking','Say this aloud: "Trabajo en un laboratorio."','Trabajo en un laboratorio',array[]::text[],'I work in a laboratory.',8),
  (v_l1,'speaking','Say this aloud: "Hay que comprobar los datos."','Hay que comprobar los datos',array[]::text[],'We have to verify the data.',9),
  (v_l2,'listening','What did you hear?','Se concluye que el tratamiento funciona',array['Se descubrió en 1928','Se ha demostrado el efecto','Se observa un patrón claro'],'It is concluded that the treatment works',6),
  (v_l2,'listening','What did you hear?','Se observa un patrón claro',array['Se descubrió en 1928','Se ha demostrado el efecto','Se concluye que el tratamiento funciona'],'A clear pattern is observed',7),
  (v_l2,'speaking','Say this aloud: "Se concluye que funciona."','Se concluye que funciona',array[]::text[],'It is concluded that it works.',8),
  (v_l2,'speaking','Say this aloud: "Se observa un patrón."','Se observa un patrón',array[]::text[],'A pattern is observed.',9),
  (v_l3,'listening','What did you hear?','Por ejemplo, la quema de combustibles fósiles',array['El cambio climático se debe','Depende de varios factores','En otras palabras, no funciona'],'For example, the burning of fossil fuels',6),
  (v_l3,'listening','What did you hear?','En otras palabras, no funciona',array['Por ejemplo','Depende de','Se debe a la temperatura'],'In other words, it doesn''t work',7),
  (v_l3,'speaking','Say this aloud: "Depende de varios factores."','Depende de varios factores',array[]::text[],'It depends on several factors.',8),
  (v_l3,'speaking','Say this aloud: "En otras palabras, no funciona."','En otras palabras, no funciona',array[]::text[],'In other words, it doesn''t work.',9),
  (v_l6,'listening','What did you hear?','Abre nuevas puertas en el campo de la inteligencia artificial',array['Un equipo logró un avance sorprendente','Este descubrimiento podría revolucionar','Los investigadores del MIT'],'It opens new doors in the field of AI',6),
  (v_l6,'listening','What did you hear?','Un equipo de investigadores del MIT logró un avance sorprendente',array['Este descubrimiento','Abre nuevas puertas','Podría revolucionar la criptografía'],'An MIT team achieved a surprising advance',7),
  (v_l6,'speaking','Say this aloud: "Los investigadores del MIT lograron un avance."','Los investigadores del MIT lograron un avance',array[]::text[],'MIT researchers achieved an advance.',8),
  (v_l6,'speaking','Say this aloud: "Podría revolucionar la medicina."','Podría revolucionar la medicina',array[]::text[],'It could revolutionize medicine.',9),
  (v_l7,'listening','What did you hear?','El impacto sobre el aula tradicional será profundo',array['Según los expertos','En los próximos años','La inteligencia artificial podría revolucionar'],'The impact on the traditional classroom will be profound',6),
  (v_l7,'listening','What did you hear?','Según los expertos, la inteligencia artificial podría revolucionar la educación',array['En los próximos años','El impacto sobre el aula','Habrá novedades'],'According to experts, AI could revolutionize education',7),
  (v_l7,'speaking','Say this aloud: "Según los expertos, es posible."','Según los expertos, es posible',array[]::text[],'According to experts, it''s possible.',8),
  (v_l7,'speaking','Say this aloud: "Podría cambiar todo."','Podría cambiar todo',array[]::text[],'It could change everything.',9);

  update public.lessons set type='conversation', title='Science Basics — Conversation Practice',
    description='A professor explains a recent discovery to a student.',
    intro='Listen to a Q&A about a new study.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Estudiante","spanish":"¿En qué consiste el descubrimiento?","english":"What does the discovery consist of?"},{"speaker":"Profesor","spanish":"Se descubrió un nuevo tratamiento que podría reducir el riesgo de Alzheimer.","english":"A new treatment was discovered that could reduce the risk of Alzheimer''s."},{"speaker":"Estudiante","spanish":"¿Se ha demostrado que funciona?","english":"Has it been shown to work?"},{"speaker":"Profesor","spanish":"Se observa un efecto positivo en cinco mil pacientes.","english":"A positive effect is observed in five thousand patients."},{"speaker":"Estudiante","spanish":"En otras palabras, todavía es preliminar.","english":"In other words, it''s still preliminary."},{"speaker":"Profesor","spanish":"Exacto. Pero abre nuevas puertas para la investigación.","english":"Exactly. But it opens new doors for research."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','What was discovered?','A new Alzheimer''s treatment',array['A vaccine','A genome','A particle'],'un nuevo tratamiento que podría reducir el riesgo de Alzheimer',1),
  (v_l8,'multiple_choice','How many patients show the effect?','5000',array['500','50000','500000'],'cinco mil pacientes',2),
  (v_l8,'multiple_choice','True or false: The student says it''s preliminary.','True',array['False'],'En otras palabras, todavía es preliminar',3),
  (v_l8,'multiple_choice','Professor''s final point?','It opens new research doors',array['It''s already a cure','It''s a failure','It''s very expensive'],'abre nuevas puertas para la investigación',4),
  (v_l8,'fill_blank','Complete: "Se ____ un efecto positivo." (is observed)','observa',array['observó','observa','observará'],'is observed',5),
  (v_l8,'multiple_choice','What does "podría" suggest?','Uncertainty about a future result',array['Certainty','Past failure','Permission'],'conditional hedge',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Science Basics', 'Review test for the Science Basics section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "experiment"?','el experimento',array['la hipótesis','el laboratorio','el descubrimiento'],'experiment',1),
  (v_lesson_id,'multiple_choice','Passive se + verb structure?','se descubrió',array['descubrió se','descubrirse','descubría'],'passive se',2),
  (v_lesson_id,'multiple_choice','What does "se debe a" mean?','is due to',array['must','should be','depends on'],'is due to',3),
  (v_lesson_id,'multiple_choice','True/false: "podría" expresses certainty.','False',array['True'],'podría = could (hedge)',4),
  (v_lesson_id,'fill_blank','Complete: "Se ____ un patrón." (is observed)','observa',array['observó','observará','observando'],'is observed',5),
  (v_lesson_id,'fill_blank','Complete: "Me ____ aprender física." (I''d like)','gustaría',array['gusta','gustaba','gusté'],'I''d like',6),
  (v_lesson_id,'listening','What did you hear?','La penicilina se descubrió en 1928',array['Tenemos que comprobar la hipótesis','El cambio climático se debe a la actividad humana','Los investigadores analizaron el genoma'],'Penicillin was discovered in 1928',7),
  (v_lesson_id,'listening','What did you hear?','Podría revolucionar la criptografía',array['Abre nuevas puertas','Según los expertos','En los próximos años'],'It could revolutionize cryptography',8),
  (v_lesson_id,'speaking','Say this aloud: "Se ha demostrado el efecto."','Se ha demostrado el efecto',array[]::text[],'The effect has been shown.',9),
  (v_lesson_id,'speaking','Say this aloud: "Podría revolucionar la medicina."','Podría revolucionar la medicina',array[]::text[],'It could revolutionize medicine.',10);

end $$;

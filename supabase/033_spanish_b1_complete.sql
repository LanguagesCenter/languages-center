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

end $$;

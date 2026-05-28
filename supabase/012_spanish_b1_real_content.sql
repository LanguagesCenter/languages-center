-- 012_spanish_b1_real_content.sql
-- Real Spanish B1 lesson content + the B1 article.
-- Idempotent: re-running deletes Spanish B1 + B1 article and reseeds.
-- A1 (010), A2 (011), B2 and C1 stay on their current content.
--
-- B1 introduces preterite vs imperfect, future tense, conditional,
-- subjunctive after "espero que / quiero que", relative pronouns,
-- and discourse connectors (sin embargo, aunque, por lo tanto).
-- Per lesson: 10 vocab MC + 5 phrase MC + 3 listening + 2 speaking + 2 fill_blank.

do $$
declare
  v_lang_id   bigint;
  v_course_id bigint;
  v_lesson_id bigint;
begin
  select id into v_lang_id from public.languages where code = 'spanish';
  if v_lang_id is null then
    raise exception 'Spanish language not found in public.languages';
  end if;

  delete from public.courses  where language_id = v_lang_id and cefr_level = 'B1';
  delete from public.articles where language_id = v_lang_id and level = 'B1';

  -- =================== B1.1 TRAVEL ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Travel', 'Plan trips, navigate airports and tell travel stories in Spanish.', 'B1', 1)
  returning id into v_course_id;

  -- Lesson 1: airport + booking vocab
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Travel — Lesson 1', 'Airport, booking and reservation vocab.', 'vocabulary', 1, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "visa (travel document)"?','el visado',array['la visa (LatAm)','el vista','el pasaporte'],'Visa (Spain) [bee-SAH-doh]',1),
    (v_lesson_id,'multiple_choice','How do you say "flight"?','el vuelo',array['el viaje','el avión','la volada'],'Flight [BWEH-loh]',2),
    (v_lesson_id,'multiple_choice','How do you say "to take off (plane)"?','despegar',array['levantar','elevar','aterrizar'],'To take off [dehs-peh-GAHR]',3),
    (v_lesson_id,'multiple_choice','How do you say "to land (plane)"?','aterrizar',array['despegar','bajar','llegar'],'To land [ah-teh-rree-SAHR]',4),
    (v_lesson_id,'multiple_choice','How do you say "luggage"?','el equipaje',array['la maleta','la bolsa','el bulto'],'Luggage [eh-kee-PAH-heh]',5),
    (v_lesson_id,'multiple_choice','How do you say "boarding"?','el embarque',array['el aterrizaje','la salida','la llegada'],'Boarding [ehm-BAR-keh]',6),
    (v_lesson_id,'multiple_choice','How do you say "reservation / booking"?','la reserva',array['la reservación (LatAm)','la entrada','el viaje'],'Booking (Spain) [reh-SEHR-bah]',7),
    (v_lesson_id,'multiple_choice','How do you say "accommodation / lodging"?','el alojamiento',array['el hotel','la casa','la habitación'],'Accommodation [ah-loh-hah-MYEHN-toh]',8),
    (v_lesson_id,'multiple_choice','How do you say "hostel"?','el albergue',array['el hostal','el hotel','la posada'],'Hostel [ahl-BEHR-geh]',9),
    (v_lesson_id,'multiple_choice','How do you say "backpack"?','la mochila',array['la maleta','el bolso','la cartera'],'Backpack [moh-CHEE-lah]',10),
    (v_lesson_id,'multiple_choice','How do you say "border (frontier)"?','la frontera',array['la línea','el límite','la orilla'],'Border [frohn-TEH-rah]',11),
    (v_lesson_id,'multiple_choice','How do you say "customs (airport)"?','la aduana',array['la frontera','la oficina','el control'],'Customs [ah-DWAH-nah]',12),
    (v_lesson_id,'multiple_choice','How do you say "foreign currency"?','las divisas',array['el cambio','el dinero','las monedas'],'Foreign currency [dee-BEE-sahs]',13),
    (v_lesson_id,'multiple_choice','How do you say "itinerary"?','el itinerario',array['el plan','el viaje','la ruta'],'Itinerary [ee-tee-neh-RAH-ryoh]',14),
    (v_lesson_id,'multiple_choice','How do you say "layover / stopover"?','la escala',array['la parada','la conexión también','el alto'],'Layover [ehs-KAH-lah]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','tengo una reserva para esta noche',array['tengo una habitación esta noche','quiero una reserva','tengo reserva para mañana'],'I have a reservation for tonight',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','el vuelo despega a las nueve',array['el vuelo llega a las nueve','el avión sale a las nueve','despega a las diez'],'The flight takes off at nine',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','perdí el equipaje',array['perdí el vuelo','encontré el equipaje','perdí mi maleta'],'I lost my luggage',18),
    (v_lesson_id,'speaking','Say "I have a reservation under the name García" in Spanish.','Tengo una reserva a nombre de García',array[]::text[],'Tengo una reserva a nombre de García',19),
    (v_lesson_id,'speaking','Say "My flight has a layover in Madrid" in Spanish.','Mi vuelo hace escala en Madrid',array[]::text[],'Mi vuelo hace escala en Madrid',20),
    (v_lesson_id,'fill_blank','Complete: "Mi vuelo ___ escala en Lisboa." (My flight has a layover in Lisbon.)','hace',array['tiene','va','está'],'makes',21),
    (v_lesson_id,'fill_blank','Complete: "Necesito un ___ para viajar a India." (I need a visa to travel to India.)','visado',array['vuelo','vista','equipaje'],'visa',22);

  -- Lesson 2: telling past trip stories (preterite intro)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Travel — Lesson 2', 'Tell stories about past trips (preterite).', 'grammar', 2, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','Which tense is for finished past actions?','el pretérito indefinido',array['el imperfecto','el presente','el futuro'],'Preterite (completed past)',1),
    (v_lesson_id,'multiple_choice','Conjugate: "I traveled" (yo, viajar)','viajé',array['viajo','viajaba','viajaré'],'I traveled [byah-HEH]',2),
    (v_lesson_id,'multiple_choice','Conjugate: "you (informal) ate" (tú, comer)','comiste',array['comías','comes','comerás'],'You ate [koh-MEES-teh]',3),
    (v_lesson_id,'multiple_choice','Conjugate: "she went" (ella, ir)','fue',array['iba','va','irá'],'She went [FWEH]',4),
    (v_lesson_id,'multiple_choice','Conjugate: "we visited" (nosotros, visitar)','visitamos',array['visitábamos','visitaremos','visitamos (note: same as present)'],'We visited',5),
    (v_lesson_id,'multiple_choice','Conjugate: "they bought" (ellos, comprar)','compraron',array['compraban','compraran','compran'],'They bought [kohm-PRAH-rohn]',6),
    (v_lesson_id,'multiple_choice','Translate "El año pasado fui a Italia."','Last year I went to Italy',array['I am going to Italy','I will go to Italy next year','I always go to Italy'],'Last year I went to Italy',7),
    (v_lesson_id,'multiple_choice','Translate "Visitamos el Coliseo."','We visited the Colosseum',array['We are visiting the Colosseum','We will visit the Colosseum','We always visit the Colosseum'],'We visited the Colosseum',8),
    (v_lesson_id,'multiple_choice','Which is correct: "I saw a movie yesterday"?','Ayer vi una película',array['Ayer veo una película','Ayer veía una película','Ayer veré una película'],'Use preterite for "yesterday"',9),
    (v_lesson_id,'multiple_choice','Conjugate: "I made" (yo, hacer)','hice',array['hago','hacía','hicimos'],'I made / did [EE-seh]',10),
    (v_lesson_id,'multiple_choice','Conjugate: "I had" (yo, tener)','tuve',array['tengo','tenía','tuvo'],'I had [TOO-beh]',11),
    (v_lesson_id,'multiple_choice','Conjugate: "I came" (yo, venir)','vine',array['vengo','venía','vino'],'I came [BEE-neh]',12),
    (v_lesson_id,'multiple_choice','Conjugate: "I said" (yo, decir)','dije',array['digo','decía','dijo'],'I said [DEE-heh]',13),
    (v_lesson_id,'multiple_choice','Translate "Pasamos dos semanas en la playa."','We spent two weeks at the beach',array['We will spend two weeks','We spend two weeks','We used to spend two weeks'],'We spent two weeks at the beach',14),
    (v_lesson_id,'multiple_choice','Translate "Conocí a personas muy interesantes."','I met very interesting people',array['I knew interesting people','I know interesting people','I will meet interesting people'],'I met very interesting people',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','el verano pasado fui a francia',array['el verano pasado iba a francia','el verano fui a francia','el próximo verano voy a francia'],'Last summer I went to France',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','visitamos muchos museos',array['visitábamos muchos museos','visitaremos muchos museos','visitamos un museo'],'We visited many museums',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','perdí el avión',array['perdí el tren','perdí el avión a Madrid','encontré el avión'],'I missed the plane',18),
    (v_lesson_id,'speaking','Say "Last year I traveled to Mexico" in Spanish.','El año pasado viajé a México',array[]::text[],'El año pasado viajé a México',19),
    (v_lesson_id,'speaking','Say "We visited the museum yesterday" in Spanish.','Ayer visitamos el museo',array[]::text[],'Ayer visitamos el museo',20),
    (v_lesson_id,'fill_blank','Complete: "Ayer ___ a Madrid." (yo, ir)','fui',array['voy','iba','iré'],'I went',21),
    (v_lesson_id,'fill_blank','Complete: "El mes pasado ___ Roma." (we, visitar)','visitamos',array['visitábamos','visitamos','visitar'],'we visited',22);

  -- Lesson 3: travel anecdotes (listening - preterite vs imperfect)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Travel — Lesson 3', 'Background vs events: imperfect & preterite.', 'listening', 3, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','Which tense describes ongoing past states / background?','el imperfecto',array['el pretérito indefinido','el presente','el futuro'],'Imperfect (background)',1),
    (v_lesson_id,'multiple_choice','Conjugate: "I used to travel" (yo, viajar)','viajaba',array['viajé','viajo','viajaré'],'I used to travel [byah-HAH-bah]',2),
    (v_lesson_id,'multiple_choice','Conjugate: "we used to live" (nosotros, vivir)','vivíamos',array['vivimos','vivíamos','vivíamos a'],'We used to live [bee-BEE-ah-mohs]',3),
    (v_lesson_id,'multiple_choice','Conjugate: "she was (irregular)"','era',array['fue','está','estaba'],'She was (ser, imperfect) [EH-rah]',4),
    (v_lesson_id,'multiple_choice','Translate "Cuando era niño, viajaba con mi familia."','When I was a child, I used to travel with my family',array['I traveled with my family today','I will travel with my family','When my child traveled'],'When I was a child, I used to travel with my family',5),
    (v_lesson_id,'multiple_choice','Which is the right form for "It was raining when I arrived"?','Llovía cuando llegué',array['Llueve cuando llegué','Lluvió cuando llegaba','Llueve cuando llegaba'],'Imperfect for background + preterite for event',6),
    (v_lesson_id,'multiple_choice','Translate "Estábamos en el aeropuerto cuando empezó la tormenta."','We were at the airport when the storm started',array['We will be at the airport in a storm','The storm at the airport','We always have storms'],'We were at the airport when the storm started',7),
    (v_lesson_id,'multiple_choice','How do you say "to lose the flight"?','perder el vuelo',array['fallar el vuelo','olvidar el vuelo','dejar el vuelo'],'To miss the flight',8),
    (v_lesson_id,'multiple_choice','How do you say "to forget the passport"?','olvidar el pasaporte',array['perder el pasaporte','dejar el pasaporte','no encontrar el pasaporte'],'To forget the passport',9),
    (v_lesson_id,'multiple_choice','How do you say "delayed flight"?','vuelo retrasado',array['vuelo atrasado también','vuelo tarde','vuelo siguiente'],'Delayed flight',10),
    (v_lesson_id,'multiple_choice','Translate "El vuelo estaba retrasado y perdí la conexión."','The flight was delayed and I missed the connection',array['The flight is delayed','I missed the flight','The connection is delayed'],'The flight was delayed and I missed the connection',11),
    (v_lesson_id,'multiple_choice','How do you say "I got lost in the city"?','Me perdí en la ciudad',array['Perdí la ciudad','Me perdió en la ciudad','Estaba perdido la ciudad'],'I got lost in the city',12),
    (v_lesson_id,'multiple_choice','How do you say "Suddenly..."?','De repente...',array['Repentinamente también','De pronto también','En repente'],'Suddenly [deh reh-PEHN-teh]',13),
    (v_lesson_id,'multiple_choice','How do you say "What a coincidence!"?','¡Qué casualidad!',array['¡Qué accidente!','¡Qué chiripa!','¡Qué pena!'],'What a coincidence! [kah-soo-ah-lee-DAHD]',14),
    (v_lesson_id,'multiple_choice','Translate "Mientras esperaba el tren, conocí a un viejo amigo."','While I was waiting for the train, I met an old friend',array['I am waiting for the train','I will wait for the train','I met a friend on the train'],'While I was waiting for the train, I met an old friend',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','llovía cuando llegué al hotel',array['llueve cuando llegué','llovía cuando llegaba','llovió cuando llegué'],'It was raining when I arrived',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','perdí el vuelo y me enfadé',array['perdí el tren y me enfadé','perdí el vuelo','no perdí el vuelo'],'I missed the flight and got angry',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','de repente empezó a llover',array['empezó a llover','de pronto empezó a nevar','de repente paró de llover'],'Suddenly it started to rain',18),
    (v_lesson_id,'speaking','Say "When I was a child, I traveled a lot" in Spanish.','Cuando era niño, viajaba mucho',array[]::text[],'Cuando era niño, viajaba mucho',19),
    (v_lesson_id,'speaking','Say "It was raining when I arrived" in Spanish.','Llovía cuando llegué',array[]::text[],'Llovía cuando llegué',20),
    (v_lesson_id,'fill_blank','Complete: "Cuando ___ niño, viajaba con mis padres." (I was)','era',array['fui','soy','sería'],'I was (imperfect)',21),
    (v_lesson_id,'fill_blank','Complete: "___ el avión por cinco minutos." (I missed)','Perdí',array['Perdía','Perdo','Pierdo'],'I missed',22);

  -- Lesson 4: planning future trips (futuro + condicional)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Travel — Lesson 4', 'Plan trips: future and conditional.', 'speaking', 4, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','Conjugate: "I will travel" (yo, viajar)','viajaré',array['viajo','viajaba','viajaría'],'I will travel [byah-hah-REH]',1),
    (v_lesson_id,'multiple_choice','Conjugate: "you will go" (tú, ir)','irás',array['vas','ibas','irías'],'You will go [ee-RAHS]',2),
    (v_lesson_id,'multiple_choice','Conjugate: "we will see" (nosotros, ver)','veremos',array['vemos','veíamos','vimos'],'We will see [beh-REH-mohs]',3),
    (v_lesson_id,'multiple_choice','Conjugate: "they will arrive" (ellos, llegar)','llegarán',array['llegan','llegaron','llegarían'],'They will arrive',4),
    (v_lesson_id,'multiple_choice','Conjugate: "I would go" (yo, ir, conditional)','iría',array['voy','iba','iré'],'I would go [ee-REE-ah]',5),
    (v_lesson_id,'multiple_choice','Conjugate: "I would like" (yo, gustar)','me gustaría',array['me gusta','me gustaba','me gustó'],'I would like',6),
    (v_lesson_id,'multiple_choice','Translate "Me gustaría visitar Japón algún día."','I would like to visit Japan someday',array['I will visit Japan','I like Japan','I want Japan'],'I would like to visit Japan someday',7),
    (v_lesson_id,'multiple_choice','Translate "El próximo año iré a Argentina."','Next year I will go to Argentina',array['Last year I went to Argentina','I always go to Argentina','I go to Argentina'],'Next year I will go to Argentina',8),
    (v_lesson_id,'multiple_choice','How do you say "If I had time, I would travel more"?','Si tuviera tiempo, viajaría más',array['Si tengo tiempo viajo','Si tendré tiempo viajaré','Si tuviera tiempo viaja'],'If I had time, I would travel more (subj + cond)',9),
    (v_lesson_id,'multiple_choice','How do you say "to make a list"?','hacer una lista',array['hacer lista','dar una lista','poner una lista'],'To make a list',10),
    (v_lesson_id,'multiple_choice','How do you say "to save money for a trip"?','ahorrar dinero para un viaje',array['guardar dinero por viaje','tener dinero viaje','poner dinero viaje'],'To save money for a trip [ah-oh-RRAHR]',11),
    (v_lesson_id,'multiple_choice','How do you say "tourist destination"?','el destino turístico',array['el destino de turismo','el lugar turismo','el sitio'],'Tourist destination',12),
    (v_lesson_id,'multiple_choice','How do you say "off the beaten path"?','fuera de las rutas turísticas',array['lejos del turismo','sin turismo','fuera turismo'],'Off the beaten path',13),
    (v_lesson_id,'multiple_choice','How do you say "I cannot wait!"?','¡No puedo esperar!',array['¡Espera!','¡Pronto!','¡Voy ya!'],'I cannot wait!',14),
    (v_lesson_id,'multiple_choice','Translate "Espero que tengas buen viaje."','I hope you have a good trip',array['I hope you went well','You will have a good trip','Have a good trip'],'I hope you have a good trip (subjunctive!)',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','el próximo verano iré a tailandia',array['el próximo verano voy a tailandia','el verano pasado fui a tailandia','iré a tailandia'],'Next summer I will go to Thailand',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','me gustaría visitar perú',array['me gusta visitar perú','quiero visitar perú','visitaría perú'],'I would like to visit Peru',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','espero que tengas buen viaje',array['ten buen viaje','tendrás buen viaje','espero buen viaje'],'I hope you have a good trip',18),
    (v_lesson_id,'speaking','Say "Next year I will travel to Japan" in Spanish.','El próximo año viajaré a Japón',array[]::text[],'El próximo año viajaré a Japón',19),
    (v_lesson_id,'speaking','Say "I would love to visit Argentina" in Spanish.','Me encantaría visitar Argentina',array[]::text[],'Me encantaría visitar Argentina',20),
    (v_lesson_id,'fill_blank','Complete: "Me ___ visitar Japón." (I would like to)','gustaría',array['gusta','gustaba','gustaré'],'I would like',21),
    (v_lesson_id,'fill_blank','Complete: "Espero que ___ buen viaje." (you have)','tengas',array['tienes','tendrás','tenías'],'you have (subjunctive)',22);

  -- =================== B1.2 NEWS & MEDIA ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'News & Media', 'Read headlines, discuss the news and form opinions in Spanish.', 'B1', 2)
  returning id into v_course_id;

  -- Lesson 1: media vocab
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'News & Media — Lesson 1', 'Newspapers, TV and online media.', 'vocabulary', 1, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "newspaper"?','el periódico',array['el diario también','el periodista','la prensa'],'Newspaper [peh-RYOH-dee-koh]',1),
    (v_lesson_id,'multiple_choice','How do you say "the news (item)"?','la noticia',array['las noticias (plural)','el noticiero','el noticias'],'News item [noh-TEE-syah]',2),
    (v_lesson_id,'multiple_choice','How do you say "headline"?','el titular',array['el título','la página','el cabezal'],'Headline [tee-too-LAHR]',3),
    (v_lesson_id,'multiple_choice','How do you say "journalist"?','el periodista',array['el reportero también','el editor','el escritor'],'Journalist [peh-ryoh-DEES-tah]',4),
    (v_lesson_id,'multiple_choice','How do you say "report (article)"?','el reportaje',array['el informe','el reportero','la noticia'],'Report [reh-pohr-TAH-heh]',5),
    (v_lesson_id,'multiple_choice','How do you say "social media"?','las redes sociales',array['las medias sociales','el internet','las páginas'],'Social media [REH-dehs soh-SYAH-lehs]',6),
    (v_lesson_id,'multiple_choice','How do you say "advertisement"?','el anuncio',array['la publicidad también','la propaganda','el comercio'],'Advertisement [ah-NOON-syoh]',7),
    (v_lesson_id,'multiple_choice','How do you say "advertising / publicity"?','la publicidad',array['el anuncio','la propaganda','la publicación'],'Advertising [poo-blee-see-DAHD]',8),
    (v_lesson_id,'multiple_choice','How do you say "website"?','la página web',array['la web','el sitio web también','el página'],'Website [PAH-hee-nah WEHB]',9),
    (v_lesson_id,'multiple_choice','How do you say "opinion"?','la opinión',array['el pensar','la idea','la creencia'],'Opinion [oh-pee-NYOHN]',10),
    (v_lesson_id,'multiple_choice','How do you say "article"?','el artículo',array['la editorial','el ensayo','la columna'],'Article [ahr-TEE-koo-loh]',11),
    (v_lesson_id,'multiple_choice','How do you say "press (the press)"?','la prensa',array['el periódico','las noticias','el periodismo'],'Press [PREHN-sah]',12),
    (v_lesson_id,'multiple_choice','How do you say "TV host / presenter"?','el presentador',array['el comentarista','el conductor (LatAm)','el animador'],'TV host [preh-sehn-tah-DOHR]',13),
    (v_lesson_id,'multiple_choice','How do you say "interview"?','la entrevista',array['la conferencia','la conversación','la reunión'],'Interview [ehn-treh-BEES-tah]',14),
    (v_lesson_id,'multiple_choice','How do you say "channel (TV)"?','el canal',array['la cadena también','la red','el medio'],'Channel [kah-NAHL]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','leí el periódico esta mañana',array['vi el periódico','leí un libro esta mañana','leeré el periódico'],'I read the newspaper this morning',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','la noticia más importante',array['la noticia más urgente','las noticias importantes','la noticia es importante'],'The most important news',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','vi una entrevista en la tele',array['vi una conferencia en la tele','escuché una entrevista','vi un programa en la tele'],'I saw an interview on TV',18),
    (v_lesson_id,'speaking','Say "I read the newspaper every day" in Spanish.','Leo el periódico todos los días',array[]::text[],'Leo el periódico todos los días',19),
    (v_lesson_id,'speaking','Say "Social media is very influential" in Spanish.','Las redes sociales son muy influyentes',array[]::text[],'Las redes sociales son muy influyentes',20),
    (v_lesson_id,'fill_blank','Complete: "El ___ del periódico es impactante." (The headline of the newspaper is striking.)','titular',array['título','presentador','periodista'],'headline',21),
    (v_lesson_id,'fill_blank','Complete: "Vi la entrevista en el ___" (I saw the interview on the channel.)','canal',array['cana','canon','canil'],'channel',22);

  -- Lesson 2: opinions and discourse markers
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'News & Media — Lesson 2', 'Give opinions and connect ideas.', 'phrases', 2, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "In my opinion..."?','En mi opinión...',array['Para mi opinión','Yo opinión','A mi opinión'],'In my opinion [oh-pee-NYOHN]',1),
    (v_lesson_id,'multiple_choice','How do you say "I think that..."?','Pienso que...',array['Yo pienso','Yo pensar','Creo que también'],'I think that... [PYEHN-soh keh]',2),
    (v_lesson_id,'multiple_choice','How do you say "I believe that..."?','Creo que...',array['Yo creer','Tengo creer','Creo'],'I believe that... [KREH-oh keh]',3),
    (v_lesson_id,'multiple_choice','How do you say "however"?','sin embargo',array['pero','aunque','no obstante también'],'However [seen ehm-BAHR-goh]',4),
    (v_lesson_id,'multiple_choice','How do you say "although"?','aunque',array['pero','sin embargo','aunque que'],'Although [AHWN-keh]',5),
    (v_lesson_id,'multiple_choice','How do you say "therefore"?','por lo tanto',array['por tanto también','porque','por eso también'],'Therefore [pohr loh TAHN-toh]',6),
    (v_lesson_id,'multiple_choice','How do you say "in addition / furthermore"?','además',array['también','aparte','más allá'],'In addition [ah-deh-MAHS]',7),
    (v_lesson_id,'multiple_choice','How do you say "I agree"?','Estoy de acuerdo',array['Yo de acuerdo','Tengo acuerdo','Me parece'],'I agree [ah-KWEHR-doh]',8),
    (v_lesson_id,'multiple_choice','How do you say "I disagree"?','No estoy de acuerdo',array['Yo no acuerdo','No acuerdo','Discordo'],'I disagree',9),
    (v_lesson_id,'multiple_choice','How do you say "to be true / right"?','tener razón',array['ser verdadero','estar correcto','tener verdad'],'To be right [rah-SOHN]',10),
    (v_lesson_id,'multiple_choice','How do you say "from my point of view"?','desde mi punto de vista',array['de mi vista','en mi punto','para mi vista'],'From my point of view',11),
    (v_lesson_id,'multiple_choice','How do you say "on the other hand"?','por otro lado',array['otra parte','para otro lado','a otro lado'],'On the other hand',12),
    (v_lesson_id,'multiple_choice','How do you say "Whats your opinion?"','¿Cuál es tu opinión?',array['¿Qué opinas?','¿Cómo piensas?','All correct (¿Cuál?, ¿Qué?, ¿Cómo?)'],'Whats your opinion?',13),
    (v_lesson_id,'multiple_choice','How do you say "to be honest"?','para ser sincero',array['ser sincero','con sinceridad también','sinceramente también'],'To be honest [seen-SEH-roh]',14),
    (v_lesson_id,'multiple_choice','Translate "Aunque la prensa lo critica, mucha gente lo apoya."','Although the press criticizes him, many people support him',array['The press supports him','Many people criticize him','The press and people support him'],'Although the press criticizes him, many people support him',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','en mi opinión es muy importante',array['mi opinión es importante','en mi vista es muy importante','en mi opinión no es importante'],'In my opinion it is very important',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','sin embargo no estoy de acuerdo',array['no estoy de acuerdo','con embargo no acuerdo','sin embargo de acuerdo'],'However I disagree',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','desde mi punto de vista',array['desde mi vista','en mi punto','desde el punto'],'From my point of view',18),
    (v_lesson_id,'speaking','Say "In my opinion, social media is dangerous" in Spanish.','En mi opinión, las redes sociales son peligrosas',array[]::text[],'En mi opinión, las redes sociales son peligrosas',19),
    (v_lesson_id,'speaking','Say "I disagree with you" in Spanish.','No estoy de acuerdo contigo',array[]::text[],'No estoy de acuerdo contigo',20),
    (v_lesson_id,'fill_blank','Complete: "Estoy ___ acuerdo." (I agree.)','de',array['en','con','a'],'in agreement',21),
    (v_lesson_id,'fill_blank','Complete: "Pienso ___ es importante." (I think that it is important.)','que',array['de','en','si'],'that',22);

  -- Lesson 3: discussing news (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'News & Media — Lesson 3', 'Listen to news-style language.', 'listening', 3, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "According to..."?','Según...',array['De acuerdo a','Acerca de','Por'],'According to... [seh-GOON]',1),
    (v_lesson_id,'multiple_choice','How do you say "the government"?','el gobierno',array['el estado','el país','la nación'],'Government [goh-BYEHR-noh]',2),
    (v_lesson_id,'multiple_choice','How do you say "the president"?','el presidente',array['el ministro','el jefe','el líder'],'President [preh-see-DEHN-teh]',3),
    (v_lesson_id,'multiple_choice','How do you say "elections"?','las elecciones',array['las votaciones también','los votos','la decisión'],'Elections [eh-lehk-SYOH-nehs]',4),
    (v_lesson_id,'multiple_choice','How do you say "law"?','la ley',array['la regla','la norma','el código'],'Law [LAY]',5),
    (v_lesson_id,'multiple_choice','How do you say "economy"?','la economía',array['el mercado','la moneda','el dinero'],'Economy [eh-koh-noh-MEE-ah]',6),
    (v_lesson_id,'multiple_choice','How do you say "crisis"?','la crisis',array['la criss','el problema','el conflicto'],'Crisis [KREE-sees]',7),
    (v_lesson_id,'multiple_choice','How do you say "to inform / report"?','informar',array['contar','decir','noticiar'],'To inform [een-fohr-MAHR]',8),
    (v_lesson_id,'multiple_choice','How do you say "to publish"?','publicar',array['hacer público','imprimir','editar'],'To publish [poo-blee-KAHR]',9),
    (v_lesson_id,'multiple_choice','How do you say "to broadcast"?','emitir',array['transmitir también','enviar','difundir también'],'To broadcast [eh-mee-TEER]',10),
    (v_lesson_id,'multiple_choice','How do you say "breaking news"?','noticias de última hora',array['noticias importantes','noticias recientes','noticias frescas'],'Breaking news',11),
    (v_lesson_id,'multiple_choice','How do you say "freedom of the press"?','la libertad de prensa',array['libertad de medios','libertad de noticias','libertad de periódico'],'Freedom of the press',12),
    (v_lesson_id,'multiple_choice','How do you say "fake news"?','las noticias falsas',array['noticias mentiras','noticias mal','las noticias engañosas'],'Fake news [FAHL-sahs]',13),
    (v_lesson_id,'multiple_choice','How do you say "to censor"?','censurar',array['silenciar','prohibir','callar'],'To censor [sehn-soo-RAHR]',14),
    (v_lesson_id,'multiple_choice','Translate "Según el gobierno, la economía está mejorando."','According to the government, the economy is improving',array['The economy is bad','The government says nothing','According to the press'],'According to the government, the economy is improving',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','según el periódico',array['según el periodista','según las noticias','el periódico dice'],'According to the newspaper',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','noticias de última hora',array['noticias urgentes','últimas noticias','noticias frescas'],'Breaking news',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','el presidente habló esta mañana',array['el presidente habla esta mañana','la presidenta habló esta mañana','el presidente hablará'],'The president spoke this morning',18),
    (v_lesson_id,'speaking','Say "According to the news..." in Spanish.','Según las noticias...',array[]::text[],'Según las noticias...',19),
    (v_lesson_id,'speaking','Say "Freedom of the press is fundamental" in Spanish.','La libertad de prensa es fundamental',array[]::text[],'La libertad de prensa es fundamental',20),
    (v_lesson_id,'fill_blank','Complete: "___ el periódico, hubo una protesta." (According to)','Según',array['Por','Para','De'],'According to',21),
    (v_lesson_id,'fill_blank','Complete: "Las noticias de última ___" (Breaking news)','hora',array['minuto','día','semana'],'hour',22);

  -- Lesson 4: debating in conversation (speaking)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'News & Media — Lesson 4', 'Argue your case respectfully.', 'speaking', 4, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "I would like to add..."?','Me gustaría añadir...',array['Quiero añadir','Yo agregar','Voy a sumar'],'I would like to add... [ah-nyah-DEER]',1),
    (v_lesson_id,'multiple_choice','How do you say "Let me explain"?','Déjame explicar',array['Yo explicar','Permíteme explicar también','Para explicar'],'Let me explain [ehks-plee-KAHR]',2),
    (v_lesson_id,'multiple_choice','How do you say "I see your point, but..."?','Entiendo tu punto, pero...',array['Veo tu punto','Yo tu punto','Acepto, pero'],'I see your point, but...',3),
    (v_lesson_id,'multiple_choice','How do you say "lets agree to disagree"?','aceptemos que no estamos de acuerdo',array['acordamos no acordar','no de acuerdo y ya','vamos disagree'],'Lets agree to disagree',4),
    (v_lesson_id,'multiple_choice','How do you say "I think you are exaggerating"?','Creo que estás exagerando',array['Tú exageras','Yo creo exagerar','Eres exagerado'],'I think you are exaggerating [ehks-ah-heh-RAHN-doh]',5),
    (v_lesson_id,'multiple_choice','How do you say "fact"?','el hecho',array['la realidad','la verdad','el dato'],'Fact [EH-choh]',6),
    (v_lesson_id,'multiple_choice','How do you say "evidence / proof"?','la prueba',array['la evidencia también','el ensayo','la verdad'],'Evidence [PRWEH-bah]',7),
    (v_lesson_id,'multiple_choice','How do you say "to argue / discuss"?','discutir',array['hablar','arguar','contradecir'],'To argue [dees-koo-TEER]',8),
    (v_lesson_id,'multiple_choice','How do you say "to convince"?','convencer',array['persuadir también','vencer','controlar'],'To convince [kohn-behn-SEHR]',9),
    (v_lesson_id,'multiple_choice','How do you say "for example"?','por ejemplo',array['como ejemplo','de ejemplo','en ejemplo'],'For example [eh-HEM-ploh]',10),
    (v_lesson_id,'multiple_choice','How do you say "as a result"?','como resultado',array['de resultado','en resultado','por resultado'],'As a result',11),
    (v_lesson_id,'multiple_choice','How do you say "in conclusion"?','en conclusión',array['como conclusión','para conclusión','al final'],'In conclusion [kohn-kloo-SYOHN]',12),
    (v_lesson_id,'multiple_choice','How do you say "to question / doubt"?','poner en duda',array['poner duda','dar duda','tener duda'],'To question (something)',13),
    (v_lesson_id,'multiple_choice','How do you say "respectfully"?','con respeto',array['respetuosamente también','en respeto','respeto'],'Respectfully',14),
    (v_lesson_id,'multiple_choice','Translate "Aunque no estoy de acuerdo, respeto tu opinión."','Although I disagree, I respect your opinion',array['I do not respect your opinion','I disagree because I respect you','Your opinion is wrong'],'Although I disagree, I respect your opinion',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','me gustaría añadir algo',array['quiero añadir algo','me gusta añadir','no quiero añadir nada'],'I would like to add something',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','entiendo tu punto pero',array['veo tu punto pero','no entiendo tu punto','entiendo todo'],'I see your point, but...',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','por ejemplo',array['como ejemplo','para ejemplo','de ejemplo'],'For example',18),
    (v_lesson_id,'speaking','Say "I see your point, but I disagree" in Spanish.','Entiendo tu punto, pero no estoy de acuerdo',array[]::text[],'Entiendo tu punto, pero no estoy de acuerdo',19),
    (v_lesson_id,'speaking','Say "I respect your opinion" in Spanish.','Respeto tu opinión',array[]::text[],'Respeto tu opinión',20),
    (v_lesson_id,'fill_blank','Complete: "Aunque no estoy de acuerdo, ___ tu opinión." (I respect)','respeto',array['respetar','respeté','respetaré'],'I respect',21),
    (v_lesson_id,'fill_blank','Complete: "Por ___, las redes sociales..." (For example)','ejemplo',array['ejempla','muestra','prueba'],'example',22);

  -- =================== B1.3 ENVIRONMENT ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Environment', 'Discuss the planet, sustainability and climate.', 'B1', 3)
  returning id into v_course_id;

  -- Lesson 1: environment vocab
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Environment — Lesson 1', 'Climate, pollution and nature.', 'vocabulary', 1, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "the environment"?','el medio ambiente',array['la naturaleza','el ambiente','el medio'],'Environment [MEH-dyoh ahm-BYEHN-teh]',1),
    (v_lesson_id,'multiple_choice','How do you say "pollution"?','la contaminación',array['la basura','el humo','la suciedad'],'Pollution [kohn-tah-mee-nah-SYOHN]',2),
    (v_lesson_id,'multiple_choice','How do you say "to recycle"?','reciclar',array['reusar','reciclo','volver a usar'],'To recycle [reh-see-KLAHR]',3),
    (v_lesson_id,'multiple_choice','How do you say "trash / garbage"?','la basura',array['el desperdicio','los desechos también','la suciedad'],'Trash [bah-SOO-rah]',4),
    (v_lesson_id,'multiple_choice','How do you say "plastic"?','el plástico',array['el polietileno','el material','el sintético'],'Plastic [PLAHS-tee-koh]',5),
    (v_lesson_id,'multiple_choice','How do you say "global warming"?','el calentamiento global',array['el calor global','el calentamiento mundial','el calor mundial'],'Global warming [kah-lehn-tah-MYEHN-toh]',6),
    (v_lesson_id,'multiple_choice','How do you say "renewable energy"?','la energía renovable',array['la energía limpia','la energía verde','la energía nueva'],'Renewable energy [reh-noh-BAH-bleh]',7),
    (v_lesson_id,'multiple_choice','How do you say "sustainable"?','sostenible',array['sustentable también','duradero','renovable'],'Sustainable [sohs-teh-NEE-bleh]',8),
    (v_lesson_id,'multiple_choice','How do you say "deforestation"?','la deforestación',array['la talada','el corte de árboles','la desforestación'],'Deforestation [deh-foh-rehs-tah-SYOHN]',9),
    (v_lesson_id,'multiple_choice','How do you say "species"?','las especies',array['los especies','la raza','la familia'],'Species [ehs-PEH-syehs]',10),
    (v_lesson_id,'multiple_choice','How do you say "nature"?','la naturaleza',array['el natural','el medio ambiente','el medio'],'Nature [nah-too-rah-LEH-sah]',11),
    (v_lesson_id,'multiple_choice','How do you say "planet"?','el planeta',array['la tierra','el mundo','la esfera'],'Planet [plah-NEH-tah]',12),
    (v_lesson_id,'multiple_choice','How do you say "natural resources"?','los recursos naturales',array['la naturaleza','los productos','los materiales'],'Natural resources [reh-KOOR-sohs]',13),
    (v_lesson_id,'multiple_choice','How do you say "fresh water"?','el agua dulce',array['el agua limpia','el agua nueva','el agua fresca'],'Fresh water [AH-gwah DOOL-seh]',14),
    (v_lesson_id,'multiple_choice','How do you say "to save (resources)"?','ahorrar',array['guardar','salvar','proteger'],'To save (resources) [ah-oh-RRAHR]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','tenemos que cuidar el planeta',array['debemos cuidar el planeta','vamos a cuidar el planeta','cuidamos el planeta'],'We have to take care of the planet',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','el calentamiento global es real',array['el calor global existe','el calentamiento del mundo','el cambio climático es real'],'Global warming is real',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','reciclo plástico cada semana',array['reciclo plástico cada día','reciclo papel cada semana','no reciclo plástico'],'I recycle plastic every week',18),
    (v_lesson_id,'speaking','Say "We need to take care of the planet" in Spanish.','Tenemos que cuidar el planeta',array[]::text[],'Tenemos que cuidar el planeta',19),
    (v_lesson_id,'speaking','Say "Renewable energy is the future" in Spanish.','La energía renovable es el futuro',array[]::text[],'La energía renovable es el futuro',20),
    (v_lesson_id,'fill_blank','Complete: "Reciclo el ___" (I recycle plastic.)','plástico',array['platic','plástica','plásticos'],'plastic',21),
    (v_lesson_id,'fill_blank','Complete: "El calentamiento ___ es un problema." (Global warming is a problem.)','global',array['globo','grande','mundo'],'global',22);

  -- Lesson 2: actions and habits
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Environment — Lesson 2', 'Eco-friendly habits and actions.', 'phrases', 2, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "to protect"?','proteger',array['cuidar también','defender','salvar'],'To protect [proh-teh-HEHR]',1),
    (v_lesson_id,'multiple_choice','How do you say "to conserve"?','conservar',array['preservar también','guardar','mantener'],'To conserve [kohn-sehr-BAHR]',2),
    (v_lesson_id,'multiple_choice','How do you say "waste / garbage"?','los residuos',array['los desechos también','las basuras','los sobras'],'Waste [reh-SEE-dwohs]',3),
    (v_lesson_id,'multiple_choice','How do you say "to reduce"?','reducir',array['disminuir también','reducer','minimizar'],'To reduce [reh-doo-SEER]',4),
    (v_lesson_id,'multiple_choice','How do you say "to reuse"?','reutilizar',array['usar de nuevo también','usar otra vez','reusar'],'To reuse [reh-oo-tee-lee-SAHR]',5),
    (v_lesson_id,'multiple_choice','How do you say "to pollute"?','contaminar',array['ensuciar','manchar','contaminarse'],'To pollute [kohn-tah-mee-NAHR]',6),
    (v_lesson_id,'multiple_choice','How do you say "Lets reduce, reuse, recycle"?','Reducir, reutilizar, reciclar',array['Reducir, reusar, repetir','Reducir, usar, reciclar','Reducir, reutilizar y reciclar'],'Reduce, reuse, recycle',7),
    (v_lesson_id,'multiple_choice','How do you say "to use less water"?','usar menos agua',array['usar agua poca','poca agua','agua menos'],'To use less water',8),
    (v_lesson_id,'multiple_choice','How do you say "to turn off the lights"?','apagar las luces',array['cerrar las luces','quitar luces','poner luces'],'To turn off the lights [ah-pah-GAHR]',9),
    (v_lesson_id,'multiple_choice','How do you say "to drive less"?','conducir menos',array['manejar poco','ir menos','viajar poco'],'To drive less',10),
    (v_lesson_id,'multiple_choice','How do you say "public transport"?','el transporte público',array['transporte de público','el transporte de gente','el bus'],'Public transport',11),
    (v_lesson_id,'multiple_choice','How do you say "electric car"?','el coche eléctrico',array['el carro eléctrico (LatAm)','el coche electric','el eléctrico coche'],'Electric car (Spain) [eh-LEHK-tree-koh]',12),
    (v_lesson_id,'multiple_choice','How do you say "solar panel"?','el panel solar',array['la placa solar también','el solar panel','el panel de sol'],'Solar panel [SOH-lahr]',13),
    (v_lesson_id,'multiple_choice','How do you say "to plant trees"?','plantar árboles',array['poner árboles','tirar árboles','sembrar árboles también'],'To plant trees [plahn-TAHR]',14),
    (v_lesson_id,'multiple_choice','Translate "Si todos reciclamos, ayudamos al planeta."','If we all recycle, we help the planet',array['We will recycle','We recycled the planet','The planet recycles us'],'If we all recycle, we help the planet',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','apago las luces siempre',array['apago las luces a veces','enciendo las luces','no apago las luces'],'I always turn off the lights',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','uso transporte público',array['uso bicicleta','uso transporte privado','no uso transporte'],'I use public transport',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','tenemos que plantar más árboles',array['plantamos árboles','planté un árbol','tenemos plantar árbol'],'We have to plant more trees',18),
    (v_lesson_id,'speaking','Say "I recycle every day" in Spanish.','Reciclo todos los días',array[]::text[],'Reciclo todos los días',19),
    (v_lesson_id,'speaking','Say "We have to protect the environment" in Spanish.','Tenemos que proteger el medio ambiente',array[]::text[],'Tenemos que proteger el medio ambiente',20),
    (v_lesson_id,'fill_blank','Complete: "Tenemos que ___ menos agua." (use less water)','usar',array['gastar','poner','beber'],'use',21),
    (v_lesson_id,'fill_blank','Complete: "El transporte ___ es mejor para el planeta." (Public transport)','público',array['privado','pública','colectivo'],'public',22);

  -- Lesson 3: climate change debate (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Environment — Lesson 3', 'Climate change debate language.', 'listening', 3, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "climate change"?','el cambio climático',array['el cambio del clima','la cambio climática','el climático cambio'],'Climate change [klee-MAH-tee-koh]',1),
    (v_lesson_id,'multiple_choice','How do you say "greenhouse effect"?','el efecto invernadero',array['efecto verde','el efecto sol','el efecto cálido'],'Greenhouse effect [een-behr-nah-DEH-roh]',2),
    (v_lesson_id,'multiple_choice','How do you say "carbon emissions"?','las emisiones de carbono',array['emisiones de carbono','las emisiones carbón','de carbono emisiones'],'Carbon emissions [eh-mee-SYOH-nehs]',3),
    (v_lesson_id,'multiple_choice','How do you say "to melt (ice)"?','derretirse',array['fundirse también','desaparecer','liquidarse'],'To melt [deh-rreh-TEER-seh]',4),
    (v_lesson_id,'multiple_choice','How do you say "sea level"?','el nivel del mar',array['el nivel mar','el agua nivel','la altura mar'],'Sea level [nee-BEHL]',5),
    (v_lesson_id,'multiple_choice','How do you say "drought"?','la sequía',array['la sequía también','la falta de lluvia','el seco'],'Drought [seh-KEE-ah]',6),
    (v_lesson_id,'multiple_choice','How do you say "flood"?','la inundación',array['la avalancha','el agua','el desbordamiento'],'Flood [ee-noon-dah-SYOHN]',7),
    (v_lesson_id,'multiple_choice','How do you say "wildfire"?','el incendio forestal',array['el fuego del bosque','el incendio','el fuego natural'],'Wildfire [een-SEHN-dyoh]',8),
    (v_lesson_id,'multiple_choice','How do you say "to be in danger"?','estar en peligro',array['tener peligro','ser peligroso','con peligro'],'To be in danger [peh-LEE-groh]',9),
    (v_lesson_id,'multiple_choice','How do you say "ecosystem"?','el ecosistema',array['el sistema ecológico','el ecosistem','el sistem'],'Ecosystem [eh-koh-sees-TEH-mah]',10),
    (v_lesson_id,'multiple_choice','How do you say "biodiversity"?','la biodiversidad',array['la diversidad biológica','la bio diversidad','las especies'],'Biodiversity [byoh-dee-behr-see-DAHD]',11),
    (v_lesson_id,'multiple_choice','How do you say "carbon footprint"?','la huella de carbono',array['la marca de carbono','el carbono pie','la huella ambiental'],'Carbon footprint [WEH-yah]',12),
    (v_lesson_id,'multiple_choice','How do you say "to combat / fight"?','combatir',array['luchar contra también','pelear','combinar'],'To combat [kohm-bah-TEER]',13),
    (v_lesson_id,'multiple_choice','How do you say "the next generation"?','la próxima generación',array['las generación siguiente','la futura generación también','la generación próxima'],'The next generation',14),
    (v_lesson_id,'multiple_choice','Translate "El cambio climático afecta a todo el planeta."','Climate change affects the whole planet',array['Climate change is the planet','The planet causes climate change','Climate change is changing'],'Climate change affects the whole planet',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','el cambio climático es real',array['el cambio del tiempo es real','el clima es real','el cambio climático es serio'],'Climate change is real',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','muchas especies están en peligro',array['las especies son peligrosas','muchas especies están aquí','están en peligro muchas especies'],'Many species are in danger',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','debemos reducir las emisiones',array['vamos a reducir emisiones','reducimos las emisiones','tenemos emisiones'],'We must reduce emissions',18),
    (v_lesson_id,'speaking','Say "Climate change affects everyone" in Spanish.','El cambio climático afecta a todos',array[]::text[],'El cambio climático afecta a todos',19),
    (v_lesson_id,'speaking','Say "We must protect our ecosystems" in Spanish.','Debemos proteger nuestros ecosistemas',array[]::text[],'Debemos proteger nuestros ecosistemas',20),
    (v_lesson_id,'fill_blank','Complete: "El efecto ___" (The greenhouse effect)','invernadero',array['verde','calor','tropical'],'greenhouse',21),
    (v_lesson_id,'fill_blank','Complete: "Las especies en ___" (Species in danger)','peligro',array['peligros','peligrosos','riesgo'],'danger',22);

  -- Lesson 4: speaking about your eco-habits
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Environment — Lesson 4', 'Share what you do for the planet.', 'speaking', 4, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "Im worried about the environment"?','Me preocupa el medio ambiente',array['Preocupo el medio','Tengo preocupado','Soy preocupado'],'Im worried about the environment',1),
    (v_lesson_id,'multiple_choice','How do you say "Every little bit helps"?','Cada granito de arena cuenta',array['Cada poco ayuda','Cada cosita cuenta','Cada uno ayuda'],'Every little bit helps [grah-NEE-toh]',2),
    (v_lesson_id,'multiple_choice','How do you say "to make a difference"?','marcar la diferencia',array['hacer diferencia','dar diferencia','poner diferencia'],'To make a difference',3),
    (v_lesson_id,'multiple_choice','How do you say "I try to..."?','Intento...',array['Probo','Yo trato','Yo prueba'],'I try to... [een-TEHN-toh]',4),
    (v_lesson_id,'multiple_choice','How do you say "I use a reusable bottle"?','Uso una botella reutilizable',array['Tengo botella reusable','Uso una botella otra vez','Tomo agua de botella'],'I use a reusable bottle',5),
    (v_lesson_id,'multiple_choice','How do you say "to bring your own bag"?','llevar tu propia bolsa',array['traer bolsa','tener bolsa','poner bolsa'],'To bring your own bag',6),
    (v_lesson_id,'multiple_choice','How do you say "to compost"?','hacer compost',array['hacer fertilizante','hacer abono también','hacer reciclaje'],'To compost',7),
    (v_lesson_id,'multiple_choice','How do you say "vegetarian / plant-based"?','vegetariano',array['vegano (vegan)','vegetal','plant'],'Vegetarian',8),
    (v_lesson_id,'multiple_choice','How do you say "Its important to inform people"?','Es importante informar a la gente',array['Importante decir gente','Hay que informar gente','Necesitamos informar'],'Its important to inform people',9),
    (v_lesson_id,'multiple_choice','How do you say "small actions matter"?','las pequeñas acciones importan',array['las acciones pequeños importan','pequeñas acciones son','los pequeños cuentan'],'Small actions matter',10),
    (v_lesson_id,'multiple_choice','How do you say "Im optimistic about the future"?','Soy optimista sobre el futuro',array['Tengo optimismo del futuro','Estoy optimista del futuro','El futuro es optimista'],'Im optimistic about the future',11),
    (v_lesson_id,'multiple_choice','How do you say "Im pessimistic"?','Soy pesimista',array['Tengo pesimismo','Estoy pesimista también','Pesimo soy'],'Im pessimistic [peh-see-MEES-tah]',12),
    (v_lesson_id,'multiple_choice','How do you say "If we dont act now..."','Si no actuamos ahora...',array['Si no acto','No actuamos hoy','No vamos a actuar'],'If we dont act now...',13),
    (v_lesson_id,'multiple_choice','How do you say "future generations"?','las generaciones futuras',array['las generaciones del futuro','los futuro generaciones','las generaciones por venir'],'Future generations',14),
    (v_lesson_id,'multiple_choice','Translate "Espero que el mundo se vuelva más sostenible."','I hope the world becomes more sustainable',array['I will sustain the world','The world is sustainable','I make the world sustainable'],'I hope the world becomes more sustainable (subjunctive)',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','me preocupa el medio ambiente',array['preocupo el medio','no me preocupa el ambiente','le preocupa el ambiente'],'Im worried about the environment',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','uso una botella reutilizable',array['uso una botella','tengo una botella','reuso mi botella'],'I use a reusable bottle',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','si no actuamos ahora',array['si actuamos ahora','si no actuamos pronto','si no actuamos hoy'],'If we dont act now',18),
    (v_lesson_id,'speaking','Say "I try to reduce my plastic use" in Spanish.','Intento reducir mi uso de plástico',array[]::text[],'Intento reducir mi uso de plástico',19),
    (v_lesson_id,'speaking','Say "Small actions matter" in Spanish.','Las pequeñas acciones importan',array[]::text[],'Las pequeñas acciones importan',20),
    (v_lesson_id,'fill_blank','Complete: "Me ___ el medio ambiente." (Im worried about)','preocupa',array['preocupo','preocupado','preocupar'],'worries me',21),
    (v_lesson_id,'fill_blank','Complete: "Las generaciones ___" (future generations)','futuras',array['futuros','futurista','futuras y'],'future',22);

  -- =================== B1.4 RELATIONSHIPS ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Relationships', 'Talk about friends, partners and how people connect.', 'B1', 4)
  returning id into v_course_id;

  -- Lesson 1: friendship + romance vocab
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Relationships — Lesson 1', 'Friends, partners, dating.', 'vocabulary', 1, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "friendship"?','la amistad',array['el amigo','la amiga','la amistosidad'],'Friendship [ah-mees-TAHD]',1),
    (v_lesson_id,'multiple_choice','How do you say "partner / couple"?','la pareja',array['la persona','el novio','el par'],'Partner / couple [pah-REH-hah]',2),
    (v_lesson_id,'multiple_choice','How do you say "to date someone"?','salir con alguien',array['ir con alguien','andar con alguien también','salir con persona'],'To date someone',3),
    (v_lesson_id,'multiple_choice','How do you say "to break up"?','romper',array['cortar también','separar','romperse'],'To break up [rohm-PEHR]',4),
    (v_lesson_id,'multiple_choice','How do you say "date (appointment)"?','la cita',array['la fecha','la salida','el encuentro'],'Date (meeting) [SEE-tah]',5),
    (v_lesson_id,'multiple_choice','How do you say "divorce"?','el divorcio',array['la separación','el desunido','el divor'],'Divorce [dee-BOHR-syoh]',6),
    (v_lesson_id,'multiple_choice','How do you say "single (m.)"?','soltero',array['soltera','solo','solitario'],'Single (m.) [sohl-TEH-roh]',7),
    (v_lesson_id,'multiple_choice','How do you say "to get engaged"?','comprometerse',array['casarse','enamorarse','prometer'],'To get engaged [kohm-proh-meh-TEHR-seh]',8),
    (v_lesson_id,'multiple_choice','How do you say "trust"?','la confianza',array['la confidencia','la fe','la seguridad'],'Trust [kohn-FYAHN-sah]',9),
    (v_lesson_id,'multiple_choice','How do you say "communication"?','la comunicación',array['el hablar','la conversación','la comunicado'],'Communication [koh-moo-nee-kah-SYOHN]',10),
    (v_lesson_id,'multiple_choice','How do you say "to argue / fight"?','discutir',array['pelear también','luchar','riñar también'],'To argue [dees-koo-TEER]',11),
    (v_lesson_id,'multiple_choice','How do you say "to get along well"?','llevarse bien',array['ir bien','ser bien','tener bien'],'To get along well [yeh-BAHR-seh BYEHN]',12),
    (v_lesson_id,'multiple_choice','How do you say "to get along badly"?','llevarse mal',array['ser mal','tener mal','no llevarse'],'To get along badly',13),
    (v_lesson_id,'multiple_choice','How do you say "best friend"?','el mejor amigo',array['amigo mejor','amigo bueno','primer amigo'],'Best friend (m.) [meh-HOHR ah-MEE-goh]',14),
    (v_lesson_id,'multiple_choice','How do you say "neighbor"?','el vecino',array['el visitante','el vecino aquí','la persona'],'Neighbor [beh-SEE-noh]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','rompí con mi novia',array['rompí mi novia','rompimos','no rompí con mi novia'],'I broke up with my girlfriend',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','nos llevamos muy bien',array['nos llevamos bien','no nos llevamos bien','se llevan muy bien'],'We get along very well',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','tengo una cita esta noche',array['tengo una citación','tengo una reserva esta noche','tienes una cita'],'I have a date tonight',18),
    (v_lesson_id,'speaking','Say "I get along well with my brother" in Spanish.','Me llevo bien con mi hermano',array[]::text[],'Me llevo bien con mi hermano',19),
    (v_lesson_id,'speaking','Say "I broke up with my partner" in Spanish.','Rompí con mi pareja',array[]::text[],'Rompí con mi pareja',20),
    (v_lesson_id,'fill_blank','Complete: "Me llevo bien ___ mi vecino." (with)','con',array['de','a','para'],'with',21),
    (v_lesson_id,'fill_blank','Complete: "Mi mejor ___" (my best friend)','amigo',array['amiga','amistad','vecino'],'friend (m.)',22);

  -- Lesson 2: describing relationships
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Relationships — Lesson 2', 'Describe friends and partners.', 'phrases', 2, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "kind / nice"?','simpático',array['amable también','bueno','agradable'],'Kind (m.) [seem-PAH-tee-koh]',1),
    (v_lesson_id,'multiple_choice','How do you say "funny"?','divertido',array['gracioso también','cómico','feliz'],'Funny [dee-behr-TEE-doh]',2),
    (v_lesson_id,'multiple_choice','How do you say "serious"?','serio',array['triste','formal','tranquilo'],'Serious [SEH-ryoh]',3),
    (v_lesson_id,'multiple_choice','How do you say "generous"?','generoso',array['amable','bueno','dadivoso'],'Generous [heh-neh-ROH-soh]',4),
    (v_lesson_id,'multiple_choice','How do you say "selfish"?','egoísta',array['egoísmo','solo','propio'],'Selfish [eh-goh-EES-tah]',5),
    (v_lesson_id,'multiple_choice','How do you say "shy"?','tímido',array['callado','reservado','introvertido también'],'Shy [TEE-mee-doh]',6),
    (v_lesson_id,'multiple_choice','How do you say "outgoing"?','extrovertido',array['sociable también','amistoso','animado'],'Outgoing [ehks-troh-behr-TEE-doh]',7),
    (v_lesson_id,'multiple_choice','How do you say "honest"?','honesto',array['honrado también','sincero','franco'],'Honest [oh-NEHS-toh]',8),
    (v_lesson_id,'multiple_choice','How do you say "loyal"?','leal',array['fiel también','sincero','confianza'],'Loyal [leh-AHL]',9),
    (v_lesson_id,'multiple_choice','How do you say "stubborn"?','testarudo',array['terco también','cabezón también','duro'],'Stubborn [tehs-tah-ROO-doh]',10),
    (v_lesson_id,'multiple_choice','How do you say "We have a lot in common"?','Tenemos mucho en común',array['Somos similar','Somos iguales','Tenemos común'],'We have a lot in common',1+10),
    (v_lesson_id,'multiple_choice','How do you say "We are very different"?','Somos muy diferentes',array['Estamos diferentes','Diferimos mucho','Somos distintos también'],'We are very different',12),
    (v_lesson_id,'multiple_choice','How do you say "We have known each other for years"?','Nos conocemos desde hace años',array['Nos conocimos años','Nos conocemos años','Hemos conocido años'],'We have known each other for years',13),
    (v_lesson_id,'multiple_choice','How do you say "we met at university"?','nos conocimos en la universidad',array['conocimos en universidad','nos conocemos en universidad','conocí en universidad'],'We met at university',14),
    (v_lesson_id,'multiple_choice','Translate "Mi mejor amiga es muy generosa y siempre me ayuda."','My best friend is very generous and always helps me',array['My friend gives me everything','I am generous','I always help my friend'],'My best friend is very generous and always helps me',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','tenemos mucho en común',array['no tenemos nada en común','tenemos algo en común','somos muy parecidos'],'We have a lot in common',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','es muy simpático',array['es muy serio','es muy simpática','no es simpático'],'He is very kind',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','nos conocimos en la universidad',array['nos conocimos en el trabajo','conocimos universidad','nos conocemos en la universidad'],'We met at university',18),
    (v_lesson_id,'speaking','Say "My best friend is funny and kind" in Spanish.','Mi mejor amigo es divertido y simpático',array[]::text[],'Mi mejor amigo es divertido y simpático',19),
    (v_lesson_id,'speaking','Say "We have known each other since childhood" in Spanish.','Nos conocemos desde la infancia',array[]::text[],'Nos conocemos desde la infancia',20),
    (v_lesson_id,'fill_blank','Complete: "Nos llevamos ___" (We get along well)','bien',array['mal','mucho','bueno'],'well',21),
    (v_lesson_id,'fill_blank','Complete: "Es muy ___" (He is very generous.)','generoso',array['generosa','egoísta','grande'],'generous (m.)',22);

  -- Lesson 3: relationship stories (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Relationships — Lesson 3', 'How couples meet, fall in love and break up.', 'listening', 3, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "to fall in love"?','enamorarse',array['amar','quererse','enamorar'],'To fall in love [eh-nah-moh-RAHR-seh]',1),
    (v_lesson_id,'multiple_choice','How do you say "love at first sight"?','amor a primera vista',array['amor inmediato','amor primer vista','primero amor'],'Love at first sight [PREE-meh-rah BEES-tah]',2),
    (v_lesson_id,'multiple_choice','How do you say "to flirt"?','coquetear',array['ligar también','flirtear también','coqueto'],'To flirt [koh-keh-teh-AHR]',3),
    (v_lesson_id,'multiple_choice','How do you say "honeymoon"?','la luna de miel',array['el viaje romántico','la luna','el viaje'],'Honeymoon [LOO-nah deh MYEHL]',4),
    (v_lesson_id,'multiple_choice','How do you say "to live together"?','convivir',array['vivir juntos también','cohabitar','vivir aquí'],'To live together [kohn-bee-BEER]',5),
    (v_lesson_id,'multiple_choice','How do you say "to fight (about something)"?','pelearse por algo',array['pelear sobre','luchar por','discutir algo también'],'To fight about something [peh-leh-AHR-seh]',6),
    (v_lesson_id,'multiple_choice','How do you say "to make up (after fighting)"?','reconciliarse',array['hacer las paces también','perdonarse','arreglarse'],'To make up [reh-kohn-see-LYAHR-seh]',7),
    (v_lesson_id,'multiple_choice','How do you say "ex-boyfriend"?','el ex novio',array['mi pasado','el ex novio antiguo','el antiguo'],'Ex-boyfriend [EHKS NOH-byoh]',8),
    (v_lesson_id,'multiple_choice','How do you say "to cheat (on a partner)"?','engañar',array['mentir','traicionar también','infidelidad'],'To cheat on someone [ehn-gah-NYAHR]',9),
    (v_lesson_id,'multiple_choice','How do you say "jealousy"?','los celos',array['la envidia','el celoso','la jealousy'],'Jealousy [SEH-lohs]',10),
    (v_lesson_id,'multiple_choice','How do you say "to be jealous"?','estar celoso',array['ser celoso','tener celos también','tener celoso'],'To be jealous',11),
    (v_lesson_id,'multiple_choice','How do you say "soulmate"?','el alma gemela',array['la pareja perfecta','el otro','el destino'],'Soulmate [AHL-mah heh-MEH-lah]',12),
    (v_lesson_id,'multiple_choice','How do you say "to propose marriage"?','pedir matrimonio',array['proponer','ofrecer matrimonio','prometer'],'To propose marriage [mah-tree-MOH-nyoh]',13),
    (v_lesson_id,'multiple_choice','How do you say "long-distance relationship"?','relación a distancia',array['relación de lejos','relación lejana','distancia relación'],'Long-distance relationship',14),
    (v_lesson_id,'multiple_choice','Translate "Se conocieron en una fiesta y se enamoraron."','They met at a party and fell in love',array['They went to a party in love','They got married at a party','They fell at a party'],'They met at a party and fell in love',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','nos enamoramos en seguida',array['nos enamoramos','en seguida nos casamos','nos conocimos en seguida'],'We fell in love immediately',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','tenemos una relación a distancia',array['tenemos una relación cerca','vivimos juntos','no tenemos relación'],'We have a long-distance relationship',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','le pidió matrimonio',array['le dio matrimonio','le pidió consejo','le ofreció matrimonio'],'He proposed marriage to her',18),
    (v_lesson_id,'speaking','Say "We fell in love at first sight" in Spanish.','Nos enamoramos a primera vista',array[]::text[],'Nos enamoramos a primera vista',19),
    (v_lesson_id,'speaking','Say "They have a long-distance relationship" in Spanish.','Tienen una relación a distancia',array[]::text[],'Tienen una relación a distancia',20),
    (v_lesson_id,'fill_blank','Complete: "Se ___ a primera vista." (they fell in love)','enamoraron',array['enamoraban','enamoran','enamorar'],'they fell in love',21),
    (v_lesson_id,'fill_blank','Complete: "Tenemos una relación ___ distancia." (long-distance)','a',array['de','en','con'],'at',22);

  -- Lesson 4: speaking about relationships
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Relationships — Lesson 4', 'Open up about your own connections.', 'speaking', 4, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "I trust you"?','Confío en ti',array['Yo confío ti','Te confío','Tengo confianza'],'I trust you [kohn-FEE-oh]',1),
    (v_lesson_id,'multiple_choice','How do you say "I miss you"?','Te echo de menos',array['Te extraño (LatAm)','Yo extraño','Me faltas'],'I miss you (Spain)',2),
    (v_lesson_id,'multiple_choice','How do you say "I am there for you"?','Estoy aquí para ti',array['Soy para ti','Estoy contigo','Para ti'],'Im here for you',3),
    (v_lesson_id,'multiple_choice','How do you say "Lets talk about it"?','Hablemos de ello',array['Hablar de eso','Vamos hablar','Vamos a hablar de ello'],'Lets talk about it',4),
    (v_lesson_id,'multiple_choice','How do you say "I forgive you"?','Te perdono',array['Yo perdón','Tengo perdón','Te perdonar'],'I forgive you [pehr-DOH-noh]',5),
    (v_lesson_id,'multiple_choice','How do you say "Im sorry, I was wrong"?','Lo siento, me equivoqué',array['Lo siento, soy mal','Sentí, equivoqué','Perdón, soy malo'],'Im sorry, I was wrong [eh-kee-boh-KEH]',6),
    (v_lesson_id,'multiple_choice','How do you say "Im hurt"?','Estoy dolido',array['Tengo dolor','Soy dolido','Me duele alma'],'Im hurt (emotionally) [doh-LEE-doh]',7),
    (v_lesson_id,'multiple_choice','How do you say "to need space"?','necesitar espacio',array['querer espacio','tener espacio','necesitar lugar'],'To need space [ehs-PAH-syoh]',8),
    (v_lesson_id,'multiple_choice','How do you say "Lets give it time"?','Démonos tiempo',array['Damos tiempo','Vamos a dar tiempo','Tomamos tiempo'],'Lets give it time',9),
    (v_lesson_id,'multiple_choice','How do you say "to support someone"?','apoyar a alguien',array['ayudar también','soportar (means tolerate)','dar apoyo'],'To support someone [ah-poh-YAHR]',10),
    (v_lesson_id,'multiple_choice','How do you say "I love you so much"?','Te quiero mucho',array['Te amo mucho (deeper)','Yo amor mucho','Te quiero muy'],'I love you so much',11),
    (v_lesson_id,'multiple_choice','How do you say "You mean a lot to me"?','Significas mucho para mí',array['Eres importante para mí','Significar para mí','Tú significar'],'You mean a lot to me [seeg-nee-FEE-kahs]',12),
    (v_lesson_id,'multiple_choice','How do you say "Lets stay friends"?','Quedémonos como amigos',array['Seamos amigos','Vamos amigos','Quedar como amigos'],'Lets stay friends',13),
    (v_lesson_id,'multiple_choice','How do you say "to grow apart"?','distanciarse',array['alejarse','separarse poco a poco también','crecer aparte'],'To grow apart [dees-tahn-SYAHR-seh]',14),
    (v_lesson_id,'multiple_choice','Translate "Espero que sigamos siendo amigos."','I hope we stay friends',array['I will stay friends','We are friends','We were friends'],'I hope we stay friends (subjunctive)',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','confío en ti',array['te confío','no confío en ti','tengo confianza'],'I trust you',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','te quiero mucho',array['te amo mucho','yo te quiero','quiero mucho'],'I love you so much',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','lo siento me equivoqué',array['lo siento mucho','siento que me equivoqué','perdón, equivoqué'],'Im sorry, I was wrong',18),
    (v_lesson_id,'speaking','Say "You mean a lot to me" in Spanish.','Significas mucho para mí',array[]::text[],'Significas mucho para mí',19),
    (v_lesson_id,'speaking','Say "Im here for you" in Spanish.','Estoy aquí para ti',array[]::text[],'Estoy aquí para ti',20),
    (v_lesson_id,'fill_blank','Complete: "Confío ___ ti." (I trust you.)','en',array['a','de','con'],'in',21),
    (v_lesson_id,'fill_blank','Complete: "Espero que ___ amigos." (we stay friends)','seamos',array['somos','seremos','fuimos'],'we be (subj.)',22);

  -- =================== B1.5 CULTURE ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Culture', 'Talk about traditions, art and Hispanic culture.', 'B1', 5)
  returning id into v_course_id;

  -- Lesson 1: culture vocab
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Culture — Lesson 1', 'Traditions, customs and identity.', 'vocabulary', 1, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "culture"?','la cultura',array['la tradición','el arte','la civilización'],'Culture [kool-TOO-rah]',1),
    (v_lesson_id,'multiple_choice','How do you say "tradition"?','la tradición',array['la costumbre','la cultura','el clásico'],'Tradition [trah-dee-SYOHN]',2),
    (v_lesson_id,'multiple_choice','How do you say "custom"?','la costumbre',array['la tradición','el hábito también','la habitación'],'Custom [kohs-TOOM-breh]',3),
    (v_lesson_id,'multiple_choice','How do you say "national holiday"?','la fiesta nacional',array['el día festivo también','el día nacional','la festividad'],'National holiday',4),
    (v_lesson_id,'multiple_choice','How do you say "religion"?','la religión',array['la fe','el rito','el dios'],'Religion [reh-lee-HYOHN]',5),
    (v_lesson_id,'multiple_choice','How do you say "language (tongue)"?','el idioma',array['la lengua también','el lenguaje','el habla'],'Language [ee-DYOH-mah]',6),
    (v_lesson_id,'multiple_choice','How do you say "gastronomy / cuisine"?','la gastronomía',array['la comida','la cocina también','el sabor'],'Gastronomy [gahs-troh-noh-MEE-ah]',7),
    (v_lesson_id,'multiple_choice','How do you say "art"?','el arte',array['las artes','la artística','el pintura'],'Art [AR-teh]',8),
    (v_lesson_id,'multiple_choice','How do you say "museum"?','el museo',array['la galería','la exposición','el museo de arte'],'Museum [moo-SEH-oh]',9),
    (v_lesson_id,'multiple_choice','How do you say "exhibition"?','la exposición',array['la muestra también','la presentación','la exposición de arte'],'Exhibition [ehks-poh-see-SYOHN]',10),
    (v_lesson_id,'multiple_choice','How do you say "monument"?','el monumento',array['la escultura','la estatua','el símbolo'],'Monument [moh-noo-MEHN-toh]',11),
    (v_lesson_id,'multiple_choice','How do you say "heritage"?','la herencia',array['el patrimonio también','la herencia cultural','el pasado'],'Heritage [eh-REHN-syah]',12),
    (v_lesson_id,'multiple_choice','How do you say "identity"?','la identidad',array['la persona','la cultura','la identidad personal'],'Identity [ee-dehn-tee-DAHD]',13),
    (v_lesson_id,'multiple_choice','How do you say "multicultural"?','multicultural',array['multinacional','multicultura','multiétnico'],'Multicultural [mool-tee-kool-too-RAHL]',14),
    (v_lesson_id,'multiple_choice','How do you say "festival"?','el festival',array['la fiesta','el carnaval','la celebración'],'Festival [fehs-tee-BAHL]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','la cultura española es muy rica',array['la comida española es rica','la cultura es rica','la cultura española es muy diversa'],'Spanish culture is very rich',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','visité el museo el sábado',array['visité el palacio','visito el museo','visité un museo'],'I visited the museum on Saturday',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','es una tradición muy antigua',array['es una tradición nueva','es una costumbre muy antigua','las tradiciones antiguas'],'It is a very old tradition',18),
    (v_lesson_id,'speaking','Say "Spanish culture is very rich" in Spanish.','La cultura española es muy rica',array[]::text[],'La cultura española es muy rica',19),
    (v_lesson_id,'speaking','Say "I love Mexican gastronomy" in Spanish.','Me encanta la gastronomía mexicana',array[]::text[],'Me encanta la gastronomía mexicana',20),
    (v_lesson_id,'fill_blank','Complete: "Es una ___ muy antigua." (very old tradition)','tradición',array['costumbre','cultura','antigua'],'tradition',21),
    (v_lesson_id,'fill_blank','Complete: "El ___ del Prado es famoso." (The Prado museum)','Museo',array['Palacio','Plaza','Mercado'],'museum',22);

  -- Lesson 2: Spanish-speaking countries
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Culture — Lesson 2', 'Hispanic countries and their differences.', 'phrases', 2, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "country"?','el país',array['el estado','la nación','la tierra'],'Country [pah-EES]',1),
    (v_lesson_id,'multiple_choice','How do you say "Spanish-speaking (countries)"?','hispanohablantes',array['de habla hispana también','hispanos','españoles'],'Spanish-speaking [ees-pah-noh-ah-BLAHN-tehs]',2),
    (v_lesson_id,'multiple_choice','How do you say "Latin America"?','América Latina',array['Latinoamérica también','Sudamérica','Hispanoamérica'],'Latin America',3),
    (v_lesson_id,'multiple_choice','How do you say "the capital"?','la capital',array['el capital (money)','la capitalida','la cabeza'],'The capital (city) [kah-pee-TAHL]',4),
    (v_lesson_id,'multiple_choice','What is the capital of Argentina?','Buenos Aires',array['Lima','Santiago','Bogotá'],'Buenos Aires',5),
    (v_lesson_id,'multiple_choice','What is the capital of Mexico?','Ciudad de México',array['Guadalajara','Monterrey','Tijuana'],'Mexico City',6),
    (v_lesson_id,'multiple_choice','How do you say "Hispanic / Latino culture varies a lot"?','La cultura hispana varía mucho',array['Cultura hispano cambia','La hispano cultura','La cultura latina varía'],'Hispanic culture varies a lot',7),
    (v_lesson_id,'multiple_choice','How do you say "Each country has its own accent"?','Cada país tiene su propio acento',array['Cada país un acento','Todo país tiene acento','Cada uno tiene acento'],'Each country has its own accent [ah-SEHN-toh]',8),
    (v_lesson_id,'multiple_choice','How do you say "regional dish"?','el plato típico',array['el plato regional también','el plato local','la comida regional'],'Regional dish [PLAH-toh TEE-pee-koh]',9),
    (v_lesson_id,'multiple_choice','What is "la paella" famous for?','España (Valencia)',array['México','Perú','Colombia'],'Spain (Valencia)',10),
    (v_lesson_id,'multiple_choice','What is "el ceviche" famous for?','Perú',array['Argentina','Cuba','España'],'Peru',11),
    (v_lesson_id,'multiple_choice','What is "el tango" associated with?','Argentina',array['España','Cuba','Chile'],'Argentina',12),
    (v_lesson_id,'multiple_choice','What dance is "el flamenco"?','un baile español',array['un baile mexicano','un baile cubano','un baile argentino'],'Flamenco — Spanish dance',13),
    (v_lesson_id,'multiple_choice','How do you say "Mexican food is spicy"?','La comida mexicana es picante',array['Comida mexicana picosa','Mexicana es picante','La comida mexicana picante'],'Mexican food is spicy [pee-KAHN-teh]',14),
    (v_lesson_id,'multiple_choice','Translate "Cada región tiene sus propias tradiciones."','Each region has its own traditions',array['All regions have traditions','Regions have one tradition','The region traditions'],'Each region has its own traditions',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','la capital de españa es madrid',array['la capital de españa','madrid es la capital','la capital de méxico es madrid'],'The capital of Spain is Madrid',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','cada país tiene su acento',array['todos los países tienen acento','cada país acento','un país tiene un acento'],'Each country has its accent',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','la paella es típica de valencia',array['la paella es de valencia','el paella es valenciano','la paella es típica de españa'],'Paella is typical of Valencia',18),
    (v_lesson_id,'speaking','Say "Each region has its own traditions" in Spanish.','Cada región tiene sus propias tradiciones',array[]::text[],'Cada región tiene sus propias tradiciones',19),
    (v_lesson_id,'speaking','Say "Latin culture is very rich" in Spanish.','La cultura latina es muy rica',array[]::text[],'La cultura latina es muy rica',20),
    (v_lesson_id,'fill_blank','Complete: "La capital de Argentina es ___" (Buenos Aires)','Buenos Aires',array['Madrid','Lima','Santiago'],'Buenos Aires',21),
    (v_lesson_id,'fill_blank','Complete: "El plato ___ de Perú es el ceviche." (typical)','típico',array['regional','nacional','famoso'],'typical',22);

  -- Lesson 3: arts & festivals (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Culture — Lesson 3', 'Music, dance and big festivals.', 'listening', 3, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "music"?','la música',array['las canciones','el música','la melodía'],'Music [MOO-see-kah]',1),
    (v_lesson_id,'multiple_choice','How do you say "dance"?','el baile',array['la danza también','el baileo','la bailarina'],'Dance [BAY-leh]',2),
    (v_lesson_id,'multiple_choice','How do you say "song"?','la canción',array['la canzón','el cantar','el cante'],'Song [kahn-SYOHN]',3),
    (v_lesson_id,'multiple_choice','How do you say "singer"?','el cantante',array['el cantor','la cantadora','el músico'],'Singer [kahn-TAHN-teh]',4),
    (v_lesson_id,'multiple_choice','How do you say "painter"?','el pintor',array['el artista','el dibujante','el pintador'],'Painter [peen-TOHR]',5),
    (v_lesson_id,'multiple_choice','How do you say "painting (artwork)"?','el cuadro',array['la pintura también','la imagen','el dibujo'],'Painting [KWAH-droh]',6),
    (v_lesson_id,'multiple_choice','How do you say "writer"?','el escritor',array['el autor también','el escribano','el redactor'],'Writer [ehs-kree-TOHR]',7),
    (v_lesson_id,'multiple_choice','How do you say "novel"?','la novela',array['el libro','la historia','el relato'],'Novel [noh-BEH-lah]',8),
    (v_lesson_id,'multiple_choice','How do you say "movie / film"?','la película',array['el filme también','el cine','el film'],'Movie [peh-LEE-koo-lah]',9),
    (v_lesson_id,'multiple_choice','How do you say "director"?','el director',array['el productor','el realizador','el creador'],'Director (film) [dee-rehk-TOHR]',10),
    (v_lesson_id,'multiple_choice','How do you say "actor (m.)"?','el actor',array['el actuante','el intérprete','el artista'],'Actor [ahk-TOHR]',11),
    (v_lesson_id,'multiple_choice','How do you say "play (theater)"?','la obra de teatro',array['el teatro','la representación','el drama'],'Play (theater) [OH-brah deh teh-AH-troh]',12),
    (v_lesson_id,'multiple_choice','What is "La Tomatina"?','un festival en España',array['una comida','un baile','un cantante'],'A Spanish festival (tomato fight)',13),
    (v_lesson_id,'multiple_choice','What is "el Carnaval de Río"?','un festival en Brasil',array['un baile español','una fiesta argentina','una comida'],'Rio Carnival (Brazil)',14),
    (v_lesson_id,'multiple_choice','Translate "Pablo Picasso fue un pintor muy famoso."','Pablo Picasso was a very famous painter',array['Picasso is famous','Picasso was a writer','Picasso painted today'],'Pablo Picasso was a very famous painter',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','me gusta la música latina',array['me gusta la música también','no me gusta latina','escucho música latina'],'I like Latin music',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','vi una obra de teatro genial',array['vi una película genial','vi una obra de teatro buena','la obra fue genial'],'I saw a great play',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','el flamenco viene de andalucía',array['el flamenco es español','el flamenco viene de españa','el tango viene de andalucía'],'Flamenco comes from Andalusia',18),
    (v_lesson_id,'speaking','Say "I love Latin American literature" in Spanish.','Me encanta la literatura latinoamericana',array[]::text[],'Me encanta la literatura latinoamericana',19),
    (v_lesson_id,'speaking','Say "Flamenco is a traditional Spanish dance" in Spanish.','El flamenco es un baile tradicional español',array[]::text[],'El flamenco es un baile tradicional español',20),
    (v_lesson_id,'fill_blank','Complete: "Vi una ___ española anoche." (Spanish movie)','película',array['música','obra','novela'],'movie',21),
    (v_lesson_id,'fill_blank','Complete: "El ___ es un baile argentino." (tango)','tango',array['flamenco','salsa','merengue'],'tango',22);

  -- Lesson 4: speaking about culture
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Culture — Lesson 4', 'Share your cultural background out loud.', 'speaking', 4, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "Im interested in..."?','Me interesa...',array['Yo intereso','Tengo interés también','Yo soy interesado'],'Im interested in... [een-teh-REH-sah]',1),
    (v_lesson_id,'multiple_choice','How do you say "What do you know about...?"','¿Qué sabes sobre...?',array['¿Qué conoces?','¿Qué tienes sobre?','¿Cómo sabes?'],'What do you know about...?',2),
    (v_lesson_id,'multiple_choice','How do you say "to learn about other cultures"?','aprender sobre otras culturas',array['saber otras culturas','conocer culturas','estudiar culturas otras'],'To learn about other cultures',3),
    (v_lesson_id,'multiple_choice','How do you say "to respect differences"?','respetar las diferencias',array['ver diferencias','dar respeto','aceptar diferencias también'],'To respect differences',4),
    (v_lesson_id,'multiple_choice','How do you say "I have traveled to..."?','He viajado a...',array['Viajé a','Voy a','Yo viajar a'],'I have traveled to... (present perfect)',5),
    (v_lesson_id,'multiple_choice','How do you say "to explore new traditions"?','explorar nuevas tradiciones',array['ver tradiciones nuevas','conocer','explorar tradición'],'To explore new traditions',6),
    (v_lesson_id,'multiple_choice','How do you say "I am proud of my heritage"?','Estoy orgulloso de mi herencia',array['Soy orgulloso herencia','Tengo orgullo herencia','Mi herencia es orgullo'],'I am proud of my heritage [ohr-goo-YOH-soh]',7),
    (v_lesson_id,'multiple_choice','How do you say "to assimilate"?','asimilarse',array['integrarse también','adaptarse también','ajustarse'],'To assimilate [ah-see-mee-LAHR-seh]',8),
    (v_lesson_id,'multiple_choice','How do you say "to integrate"?','integrarse',array['unirse','sumarse','asimilarse también'],'To integrate [een-teh-GRAHR-seh]',9),
    (v_lesson_id,'multiple_choice','How do you say "stereotype"?','el estereotipo',array['el cliché también','el prejuicio','el estereotipos'],'Stereotype [ehs-teh-reh-oh-TEE-poh]',10),
    (v_lesson_id,'multiple_choice','How do you say "prejudice"?','el prejuicio',array['el juicio','la opinión','la discriminación'],'Prejudice [preh-HWEE-syoh]',11),
    (v_lesson_id,'multiple_choice','How do you say "diversity"?','la diversidad',array['la variedad también','la pluralidad','la multipl'],'Diversity [dee-behr-see-DAHD]',12),
    (v_lesson_id,'multiple_choice','How do you say "to celebrate diversity"?','celebrar la diversidad',array['hacer diversidad','festejar diversidad también','dar diversidad'],'To celebrate diversity',13),
    (v_lesson_id,'multiple_choice','How do you say "to feel at home"?','sentirse como en casa',array['estar como casa','ser en casa','sentirse en casa'],'To feel at home',14),
    (v_lesson_id,'multiple_choice','Translate "Aunque vivo en España, soy peruano de origen."','Although I live in Spain, I am originally Peruvian',array['I am peruano in Spain','I live in Spain peruano','Peru and Spain'],'Although I live in Spain, I am originally Peruvian',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','me interesa mucho la cultura',array['me interesa la cultura','tengo mucho interés','no me interesa la cultura'],'I am very interested in culture',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','estoy orgulloso de mi herencia',array['tengo orgullo','soy orgulloso','estoy orgullosa de mi herencia'],'I am proud of my heritage',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','he viajado a muchos países',array['viajo a muchos países','viajé a muchos países','iré a muchos países'],'I have traveled to many countries',18),
    (v_lesson_id,'speaking','Say "I am very interested in learning about other cultures" in Spanish.','Me interesa mucho aprender sobre otras culturas',array[]::text[],'Me interesa mucho aprender sobre otras culturas',19),
    (v_lesson_id,'speaking','Say "I am proud of my Hispanic heritage" in Spanish.','Estoy orgulloso de mi herencia hispana',array[]::text[],'Estoy orgulloso de mi herencia hispana',20),
    (v_lesson_id,'fill_blank','Complete: "Me ___ la cultura japonesa." (Im interested in)','interesa',array['intereso','interesado','interesar'],'interests me',21),
    (v_lesson_id,'fill_blank','Complete: "He ___ a muchos países." (have traveled)','viajado',array['viajado mucho','viajar','viajaba'],'traveled (past part.)',22);

  -- =================== B1.6 MONEY ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Money', 'Banking, budgeting and personal finance in Spanish.', 'B1', 6)
  returning id into v_course_id;

  -- Lesson 1: banking vocab
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Money — Lesson 1', 'Banks, accounts and basic finance.', 'vocabulary', 1, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "bank"?','el banco',array['el cajero','la caja','el banquero'],'Bank [BAHN-koh]',1),
    (v_lesson_id,'multiple_choice','How do you say "current / checking account"?','la cuenta corriente',array['la cuenta de ahorro','la cuenta','la caja'],'Current account [KWEHN-tah koh-RRYEHN-teh]',2),
    (v_lesson_id,'multiple_choice','How do you say "savings account"?','la cuenta de ahorros',array['la cuenta corriente','la cuenta','la caja de ahorros'],'Savings account [ah-OH-rrohs]',3),
    (v_lesson_id,'multiple_choice','How do you say "to save (money)"?','ahorrar',array['guardar','salvar','conservar'],'To save money [ah-oh-RRAHR]',4),
    (v_lesson_id,'multiple_choice','How do you say "to spend (money)"?','gastar',array['pagar','perder','dar'],'To spend [gahs-TAHR]',5),
    (v_lesson_id,'multiple_choice','How do you say "to lend"?','prestar',array['pedir prestado','dar','poner'],'To lend [prehs-TAHR]',6),
    (v_lesson_id,'multiple_choice','How do you say "to borrow"?','pedir prestado',array['prestar','tomar','adquirir'],'To borrow [peh-DEER prehs-TAH-doh]',7),
    (v_lesson_id,'multiple_choice','How do you say "debt"?','la deuda',array['el préstamo','la pago','el debido'],'Debt [DEH-oo-dah]',8),
    (v_lesson_id,'multiple_choice','How do you say "mortgage"?','la hipoteca',array['el préstamo','el alquiler','la casa'],'Mortgage [ee-poh-TEH-kah]',9),
    (v_lesson_id,'multiple_choice','How do you say "rent (housing)"?','el alquiler',array['la renta (LatAm)','la casa','el alquiladero'],'Rent (Spain) [ahl-kee-LEHR]',10),
    (v_lesson_id,'multiple_choice','How do you say "bill / invoice"?','la factura',array['la cuenta','el recibo','el bill'],'Bill [fahk-TOO-rah]',11),
    (v_lesson_id,'multiple_choice','How do you say "budget"?','el presupuesto',array['el dinero','el plan','el control'],'Budget [preh-soo-PWEHS-toh]',12),
    (v_lesson_id,'multiple_choice','How do you say "to transfer (money)"?','transferir',array['enviar','poner','dar'],'To transfer [trahns-feh-REER]',13),
    (v_lesson_id,'multiple_choice','How do you say "ATM / cash machine"?','el cajero automático',array['el banco','la máquina','el cajero'],'ATM [kah-HEH-roh ow-toh-MAH-tee-koh]',14),
    (v_lesson_id,'multiple_choice','How do you say "to withdraw cash"?','sacar dinero',array['tomar dinero','quitar dinero','retirar dinero también'],'To withdraw cash',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','tengo que pagar el alquiler',array['tengo que pagar la hipoteca','pagaré el alquiler','no pago alquiler'],'I have to pay the rent',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','voy al cajero',array['voy al banco','voy a la caja','voy a sacar dinero'],'Im going to the ATM',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','necesito hacer una transferencia',array['necesito una transferencia','quiero transferir','hago una transferencia'],'I need to make a transfer',18),
    (v_lesson_id,'speaking','Say "I need to open a bank account" in Spanish.','Necesito abrir una cuenta bancaria',array[]::text[],'Necesito abrir una cuenta bancaria',19),
    (v_lesson_id,'speaking','Say "I have to pay the bill" in Spanish.','Tengo que pagar la factura',array[]::text[],'Tengo que pagar la factura',20),
    (v_lesson_id,'fill_blank','Complete: "Voy al ___ a sacar dinero." (ATM)','cajero',array['banco','caja','cajera'],'ATM',21),
    (v_lesson_id,'fill_blank','Complete: "Necesito ___ dinero para el viaje." (to save)','ahorrar',array['gastar','perder','dar'],'to save',22);

  -- Lesson 2: budgeting + salary
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Money — Lesson 2', 'Salary, taxes and budgeting.', 'phrases', 2, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "salary"?','el sueldo',array['el salario también','el pago','el ingreso'],'Salary [SWEHL-doh]',1),
    (v_lesson_id,'multiple_choice','How do you say "income"?','los ingresos',array['las ganancias también','el sueldo','las entradas'],'Income [een-GREH-sohs]',2),
    (v_lesson_id,'multiple_choice','How do you say "expenses"?','los gastos',array['los pagos','las cuentas','los gastos personales'],'Expenses [GAHS-tohs]',3),
    (v_lesson_id,'multiple_choice','How do you say "taxes"?','los impuestos',array['las tasas','los pagos','las gastos'],'Taxes [eem-PWEHS-tohs]',4),
    (v_lesson_id,'multiple_choice','How do you say "net salary"?','el sueldo neto',array['el sueldo bruto (gross)','el salario','el dinero limpio'],'Net salary [NEH-toh]',5),
    (v_lesson_id,'multiple_choice','How do you say "gross salary"?','el sueldo bruto',array['el sueldo neto','el salario total','el sueldo completo'],'Gross salary [BROO-toh]',6),
    (v_lesson_id,'multiple_choice','How do you say "investment"?','la inversión',array['el invierno','la inversor','la cosa'],'Investment [een-behr-SYOHN]',7),
    (v_lesson_id,'multiple_choice','How do you say "credit card"?','la tarjeta de crédito',array['la tarjeta crédito','la tarjeta de débito','la carta crédito'],'Credit card [KREH-dee-toh]',8),
    (v_lesson_id,'multiple_choice','How do you say "debit card"?','la tarjeta de débito',array['la tarjeta de crédito','la tarjeta','la tarjeta directo'],'Debit card [DEH-bee-toh]',9),
    (v_lesson_id,'multiple_choice','How do you say "interest rate"?','la tasa de interés',array['el porcentaje','el coste de interés','el por ciento'],'Interest rate [TAH-sah]',10),
    (v_lesson_id,'multiple_choice','How do you say "to make a budget"?','hacer un presupuesto',array['poner presupuesto','crear un plan','tener presupuesto también'],'To make a budget',11),
    (v_lesson_id,'multiple_choice','How do you say "to live within your means"?','vivir según tus medios',array['vivir bajo medios','tener medios','vivir poco'],'To live within your means [MEH-dyohs]',12),
    (v_lesson_id,'multiple_choice','How do you say "to be broke"?','estar pelado',array['estar sin dinero también','sin nada','sin pesos'],'To be broke (Spain) [peh-LAH-doh]',13),
    (v_lesson_id,'multiple_choice','How do you say "to be rich"?','ser rico',array['estar rico','tener rico','ser dinero'],'To be rich [REE-koh]',14),
    (v_lesson_id,'multiple_choice','Translate "Trato de ahorrar el 20% de mi sueldo cada mes."','I try to save 20% of my salary each month',array['I save 20 dollars','I will save 20 every month','I have 20% to spend'],'I try to save 20% of my salary each month',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','mi sueldo neto es bajo',array['mi sueldo es alto','mi sueldo bruto es bajo','mi sueldo es neto'],'My net salary is low',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','tengo que pagar impuestos',array['no pago impuestos','pago impuestos','pagaré impuestos'],'I have to pay taxes',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','estoy haciendo un presupuesto',array['hice un presupuesto','tengo un presupuesto','estoy haciendo un plan'],'Im making a budget',18),
    (v_lesson_id,'speaking','Say "I try to save money every month" in Spanish.','Trato de ahorrar dinero cada mes',array[]::text[],'Trato de ahorrar dinero cada mes',19),
    (v_lesson_id,'speaking','Say "I do not like to spend a lot" in Spanish.','No me gusta gastar mucho',array[]::text[],'No me gusta gastar mucho',20),
    (v_lesson_id,'fill_blank','Complete: "Tengo que pagar los ___" (taxes)','impuestos',array['precios','gastos','sueldos'],'taxes',21),
    (v_lesson_id,'fill_blank','Complete: "Pago con tarjeta de ___" (credit)','crédito',array['débito','dinero','banco'],'credit',22);

  -- Lesson 3: shopping smart + savings (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Money — Lesson 3', 'Discounts, sales and being thrifty.', 'listening', 3, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "sale (discount)"?','la rebaja',array['la oferta también','el descuento','la liquidación también'],'Sale [reh-BAH-hah]',1),
    (v_lesson_id,'multiple_choice','How do you say "to be on sale"?','estar de oferta',array['estar en venta','tener oferta','ser oferta'],'To be on sale',2),
    (v_lesson_id,'multiple_choice','How do you say "free shipping"?','envío gratis',array['envío sin costo también','envío barato','sin envío'],'Free shipping [ehn-BEE-oh]',3),
    (v_lesson_id,'multiple_choice','How do you say "expensive"?','caro',array['barato','costoso también','altísimo'],'Expensive [KAH-roh]',4),
    (v_lesson_id,'multiple_choice','How do you say "cheap"?','barato',array['caro','económico también','barata'],'Cheap [bah-RAH-toh]',5),
    (v_lesson_id,'multiple_choice','How do you say "to be worth it"?','valer la pena',array['costar la pena','tener pena','ser pena'],'To be worth it [bah-LEHR lah PEH-nah]',6),
    (v_lesson_id,'multiple_choice','How do you say "to save up for..."?','ahorrar para...',array['guardar para','tener para','poner para'],'To save up for...',7),
    (v_lesson_id,'multiple_choice','How do you say "luxury"?','el lujo',array['lo caro','la riqueza','el caro'],'Luxury [LOO-hoh]',8),
    (v_lesson_id,'multiple_choice','How do you say "second-hand"?','de segunda mano',array['usado también','de segundo','de mano segunda'],'Second-hand [seh-GOON-dah MAH-noh]',9),
    (v_lesson_id,'multiple_choice','How do you say "to haggle"?','regatear',array['negociar también','discutir','quitar precio'],'To haggle [reh-gah-teh-AHR]',10),
    (v_lesson_id,'multiple_choice','How do you say "Im on a budget"?','Tengo un presupuesto ajustado',array['Tengo poco dinero','Tengo presupuesto','Soy presupuesto'],'Im on a budget [ah-hoos-TAH-doh]',11),
    (v_lesson_id,'multiple_choice','How do you say "tip (gratuity)"?','la propina',array['el extra','el regalo','la gratificación'],'Tip [proh-PEE-nah]',12),
    (v_lesson_id,'multiple_choice','How do you say "to give a tip"?','dejar propina',array['dar propina también','poner propina','tener propina'],'To leave a tip',13),
    (v_lesson_id,'multiple_choice','How do you say "Im saving up for a trip"?','Estoy ahorrando para un viaje',array['Yo ahorrar','Ahorro un viaje','Voy a ahorrar'],'Im saving up for a trip',14),
    (v_lesson_id,'multiple_choice','Translate "Compré esta camisa de segunda mano y me costó muy poco."','I bought this shirt second-hand and it cost me very little',array['I sell second-hand shirts','I bought a new shirt','This shirt is very expensive'],'I bought this shirt second-hand and it cost me very little',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','está de oferta esta semana',array['está caro esta semana','no está de oferta','tiene oferta'],'Its on sale this week',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','vale la pena',array['no vale la pena','tiene la pena','vale pena'],'Its worth it',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','dejé propina',array['no dejé propina','pagué propina','dejaba propina'],'I left a tip',18),
    (v_lesson_id,'speaking','Say "Its on sale this week" in Spanish.','Está de oferta esta semana',array[]::text[],'Está de oferta esta semana',19),
    (v_lesson_id,'speaking','Say "I bought it second-hand" in Spanish.','Lo compré de segunda mano',array[]::text[],'Lo compré de segunda mano',20),
    (v_lesson_id,'fill_blank','Complete: "Está ___ oferta." (on sale)','de',array['en','con','a'],'on (sale)',21),
    (v_lesson_id,'fill_blank','Complete: "Lo compré de segunda ___" (hand)','mano',array['vez','tiempo','mes'],'hand',22);

  -- Lesson 4: speaking about money
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Money — Lesson 4', 'Talk about your relationship with money.', 'speaking', 4, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "Im saving for retirement"?','Estoy ahorrando para la jubilación',array['Yo ahorrar jubilación','Tengo ahorrar para','Yo jubilación'],'Im saving for retirement [hoo-bee-lah-SYOHN]',1),
    (v_lesson_id,'multiple_choice','How do you say "Money is not everything"?','El dinero no lo es todo',array['Dinero no todo','El dinero es nada','No es todo dinero'],'Money is not everything',2),
    (v_lesson_id,'multiple_choice','How do you say "Money doesnt buy happiness"?','El dinero no compra la felicidad',array['Dinero no felicidad','La felicidad no se compra','El dinero da felicidad'],'Money doesnt buy happiness',3),
    (v_lesson_id,'multiple_choice','How do you say "Time is money"?','El tiempo es oro',array['Tiempo es dinero','El tiempo dinero','El dinero es tiempo'],'Time is gold (Spanish idiom)',4),
    (v_lesson_id,'multiple_choice','How do you say "Im paying off debt"?','Estoy pagando una deuda',array['Yo deuda paga','Pago una deuda','Tengo paga deuda'],'Im paying off debt',5),
    (v_lesson_id,'multiple_choice','How do you say "to invest in stocks"?','invertir en acciones',array['invertir acciones','poner en acciones','meter en acciones'],'To invest in stocks [ahk-SYOH-nehs]',6),
    (v_lesson_id,'multiple_choice','How do you say "to inherit"?','heredar',array['recibir','heredarse','heredo'],'To inherit [eh-reh-DAHR]',7),
    (v_lesson_id,'multiple_choice','How do you say "inheritance"?','la herencia',array['la herencia familiar','el dejo','la sucesión'],'Inheritance [eh-REHN-syah]',8),
    (v_lesson_id,'multiple_choice','How do you say "financial freedom"?','la libertad financiera',array['libertad económica también','la libertad de dinero','la libertad del banco'],'Financial freedom',9),
    (v_lesson_id,'multiple_choice','How do you say "Living paycheck to paycheck"?','Vivir al día',array['Vivir día a día','Vivir con sueldo','Pagar día a día'],'Living paycheck to paycheck',10),
    (v_lesson_id,'multiple_choice','How do you say "to splurge"?','derrochar',array['gastar mucho','tirar dinero','despilfarrar también'],'To splurge [deh-rroh-CHAR]',11),
    (v_lesson_id,'multiple_choice','How do you say "to be greedy"?','ser tacaño',array['ser avaro también','tener avaricia','quitar dinero'],'To be stingy/greedy [tah-KAH-nyoh]',12),
    (v_lesson_id,'multiple_choice','How do you say "to be generous (with money)"?','ser generoso',array['dar mucho','ser amable','tener dinero'],'To be generous',13),
    (v_lesson_id,'multiple_choice','How do you say "to inherit from parents"?','heredar de los padres',array['recibir de padres','heredar a padres','tomar de padres'],'To inherit from parents',14),
    (v_lesson_id,'multiple_choice','Translate "Si gano la lotería, viajaré por el mundo."','If I win the lottery, I will travel the world',array['I won the lottery','I will travel if I have money','I am rich now'],'If I win the lottery, I will travel the world',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','el dinero no lo es todo',array['el dinero es todo','el dinero no es nada','dinero no es todo'],'Money is not everything',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','estoy pagando una deuda',array['pagué una deuda','tengo una deuda','no tengo deuda'],'Im paying off a debt',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','el tiempo es oro',array['el dinero es oro','el oro es dinero','el tiempo es plata'],'Time is gold',18),
    (v_lesson_id,'speaking','Say "Money is not everything" in Spanish.','El dinero no lo es todo',array[]::text[],'El dinero no lo es todo',19),
    (v_lesson_id,'speaking','Say "Im saving for a house" in Spanish.','Estoy ahorrando para una casa',array[]::text[],'Estoy ahorrando para una casa',20),
    (v_lesson_id,'fill_blank','Complete: "Estoy ahorrando ___ una casa." (for)','para',array['por','de','a'],'for',21),
    (v_lesson_id,'fill_blank','Complete: "El tiempo es ___" (gold)','oro',array['dinero','tiempo','plata'],'gold',22);

  -- =================== B1.7 EDUCATION ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Education', 'University, studying and academic vocabulary in Spanish.', 'B1', 7)
  returning id into v_course_id;

  -- Lesson 1: school + university vocab
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Education — Lesson 1', 'Studying, classes and qualifications.', 'vocabulary', 1, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "to study"?','estudiar',array['aprender','enseñar','leer'],'To study [ehs-too-DYAHR]',1),
    (v_lesson_id,'multiple_choice','How do you say "university"?','la universidad',array['la escuela','el instituto','la academia'],'University [oo-nee-behr-see-DAHD]',2),
    (v_lesson_id,'multiple_choice','How do you say "subject (academic)"?','la asignatura',array['la materia (LatAm)','el tema','la clase'],'Subject (Spain) [ah-seeg-nah-TOO-rah]',3),
    (v_lesson_id,'multiple_choice','How do you say "exam"?','el examen',array['la prueba también','el test','la prueba'],'Exam [ehk-SAH-mehn]',4),
    (v_lesson_id,'multiple_choice','How do you say "to pass (an exam)"?','aprobar',array['pasar también','sacar','ganar'],'To pass [ah-proh-BAHR]',5),
    (v_lesson_id,'multiple_choice','How do you say "to fail (an exam)"?','suspender',array['reprobar (LatAm)','perder','no pasar también'],'To fail (Spain) [soos-pehn-DEHR]',6),
    (v_lesson_id,'multiple_choice','How do you say "grade / mark"?','la nota',array['el grado','la calificación también','el puntaje'],'Grade [NOH-tah]',7),
    (v_lesson_id,'multiple_choice','How do you say "scholarship"?','la beca',array['la ayuda','el premio','la subvención'],'Scholarship [BEH-kah]',8),
    (v_lesson_id,'multiple_choice','How do you say "tuition / enrollment"?','la matrícula',array['la inscripción también','el registro','la cuota'],'Tuition / enrollment [mah-TREE-koo-lah]',9),
    (v_lesson_id,'multiple_choice','How do you say "degree / major"?','la carrera',array['el grado','la especialidad','el título'],'University degree [kah-RREH-rah]',10),
    (v_lesson_id,'multiple_choice','How do you say "masters degree"?','el máster',array['la maestría (LatAm)','el grado superior','el doctorado'],'Masters (Spain) [MAHS-tehr]',11),
    (v_lesson_id,'multiple_choice','How do you say "PhD"?','el doctorado',array['el doctorate','el doctor','la tesis'],'PhD [dohk-toh-RAH-doh]',12),
    (v_lesson_id,'multiple_choice','How do you say "professor (university)"?','el profesor',array['el catedrático también','el maestro','el director'],'Professor [proh-feh-SOHR]',13),
    (v_lesson_id,'multiple_choice','How do you say "student"?','el alumno',array['el estudiante también','el aprendiz','el escolar'],'Student [ah-LOOM-noh]',14),
    (v_lesson_id,'multiple_choice','How do you say "library"?','la biblioteca',array['la librería (= bookstore!)','la sala','el aula'],'Library (not librería!) [bee-blyoh-TEH-kah]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','estudio en la universidad',array['estudia en la universidad','estudio en la escuela','trabajo en la universidad'],'I study at the university',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','aprobé el examen',array['suspendí el examen','aprobé la asignatura','aprobaré el examen'],'I passed the exam',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','tengo una beca',array['tengo una nota','tengo un examen','no tengo beca'],'I have a scholarship',18),
    (v_lesson_id,'speaking','Say "I study medicine at university" in Spanish.','Estudio medicina en la universidad',array[]::text[],'Estudio medicina en la universidad',19),
    (v_lesson_id,'speaking','Say "I passed the exam" in Spanish.','Aprobé el examen',array[]::text[],'Aprobé el examen',20),
    (v_lesson_id,'fill_blank','Complete: "Estudio en la ___" (university)','universidad',array['escuela','librería','clase'],'university',21),
    (v_lesson_id,'fill_blank','Complete: "___ el examen ayer." (I passed)','Aprobé',array['Aprobaba','Apruebo','Aprobaré'],'I passed',22);

  -- Lesson 2: academic work
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Education — Lesson 2', 'Essays, research and academic life.', 'phrases', 2, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "essay"?','el ensayo',array['el artículo','el texto','el trabajo'],'Essay [ehn-SAH-yoh]',1),
    (v_lesson_id,'multiple_choice','How do you say "research"?','la investigación',array['el estudio también','el trabajo','la investigador'],'Research [een-behs-tee-gah-SYOHN]',2),
    (v_lesson_id,'multiple_choice','How do you say "thesis"?','la tesis',array['el ensayo','el doctorado','la teoría'],'Thesis [TEH-sees]',3),
    (v_lesson_id,'multiple_choice','How do you say "lecture (academic)"?','la conferencia',array['la clase también','la lección','el discurso'],'Lecture [kohn-feh-REHN-syah]',4),
    (v_lesson_id,'multiple_choice','How do you say "classroom"?','el aula',array['la clase','la sala','la habitación'],'Classroom [AH-oo-lah]',5),
    (v_lesson_id,'multiple_choice','How do you say "syllabus"?','el temario',array['el programa también','el plan','el horario'],'Syllabus [teh-MAH-ryoh]',6),
    (v_lesson_id,'multiple_choice','How do you say "deadline"?','la fecha límite',array['el plazo también','el final','la fecha tope también'],'Deadline [FEH-chah LEE-mee-teh]',7),
    (v_lesson_id,'multiple_choice','How do you say "to study for an exam"?','estudiar para un examen',array['estudiar al examen','estudiar el examen también','aprender el examen'],'To study for an exam',8),
    (v_lesson_id,'multiple_choice','How do you say "to take notes"?','tomar apuntes',array['hacer apuntes','tomar notas también','escribir apuntes'],'To take notes [ah-POON-tehs]',9),
    (v_lesson_id,'multiple_choice','How do you say "to memorize"?','memorizar',array['aprender de memoria también','recordar','memoria'],'To memorize [meh-moh-ree-SAHR]',10),
    (v_lesson_id,'multiple_choice','How do you say "to do homework"?','hacer los deberes',array['hacer la tarea (LatAm)','tener tareas','hacer trabajo'],'To do homework (Spain) [deh-BEH-rehs]',11),
    (v_lesson_id,'multiple_choice','How do you say "presentation"?','la presentación',array['la exposición también','el discurso','la demostración'],'Presentation',12),
    (v_lesson_id,'multiple_choice','How do you say "to graduate"?','graduarse',array['terminar','licenciarse','salir'],'To graduate [grah-doo-AHR-seh]',13),
    (v_lesson_id,'multiple_choice','How do you say "alumni / graduate"?','el graduado',array['el licenciado también','el alumno','el bachiller'],'Graduate (person)',14),
    (v_lesson_id,'multiple_choice','Translate "Tengo que entregar el ensayo el viernes."','I have to hand in the essay on Friday',array['I wrote the essay Friday','I will write an essay','I read the essay Friday'],'I have to hand in the essay on Friday',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','tengo que estudiar para el examen',array['estudio para el examen','tengo un examen','tengo que aprender'],'I have to study for the exam',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','la fecha límite es mañana',array['mañana es el examen','la clase es mañana','la fecha es lunes'],'The deadline is tomorrow',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','me gradué el año pasado',array['me gradúo este año','me graduaré','el año pasado fue'],'I graduated last year',18),
    (v_lesson_id,'speaking','Say "I have to do my homework" in Spanish.','Tengo que hacer los deberes',array[]::text[],'Tengo que hacer los deberes',19),
    (v_lesson_id,'speaking','Say "I am writing a thesis" in Spanish.','Estoy escribiendo una tesis',array[]::text[],'Estoy escribiendo una tesis',20),
    (v_lesson_id,'fill_blank','Complete: "Tengo que ___ los deberes." (do)','hacer',array['tener','ir','dar'],'do',21),
    (v_lesson_id,'fill_blank','Complete: "Me ___ el año pasado." (I graduated)','gradué',array['graduaba','gradúo','graduaré'],'I graduated',22);

  -- Lesson 3: studying tips + struggles (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Education — Lesson 3', 'Study habits and challenges.', 'listening', 3, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "I cannot concentrate"?','No me puedo concentrar',array['Yo no concentrar','No tengo concentración','No concentro'],'I cannot concentrate [kohn-sehn-TRAHR]',1),
    (v_lesson_id,'multiple_choice','How do you say "I am very behind"?','Estoy muy atrasado',array['Tengo atraso','Soy atrasado','Estoy retrasado también'],'I am very behind',2),
    (v_lesson_id,'multiple_choice','How do you say "I need help"?','Necesito ayuda',array['Tengo ayuda','Quiero ayudar','Voy a ayudar'],'I need help',3),
    (v_lesson_id,'multiple_choice','How do you say "Could you explain it again?"','¿Podrías explicarlo otra vez?',array['¿Puedes explicar?','¿Explica más?','¿Explica de nuevo?'],'Could you explain it again? (conditional)',4),
    (v_lesson_id,'multiple_choice','How do you say "I have an exam tomorrow"?','Tengo un examen mañana',array['Mañana examen','Tengo examen tomorrow','Tengo mañana examen'],'I have an exam tomorrow',5),
    (v_lesson_id,'multiple_choice','How do you say "to cram (study intensively)"?','empollar',array['estudiar mucho también','meterle','meter horas'],'To cram (Spain) [ehm-poh-YAHR]',6),
    (v_lesson_id,'multiple_choice','How do you say "study group"?','el grupo de estudio',array['grupos estudio','el equipo','el grupo de aprender'],'Study group',7),
    (v_lesson_id,'multiple_choice','How do you say "to take a break"?','tomar un descanso',array['descansar también','dar un descanso','hacer descanso'],'To take a break [dehs-KAHN-soh]',8),
    (v_lesson_id,'multiple_choice','How do you say "Im exhausted"?','Estoy agotado',array['Soy agotado','Tengo agotado','Hago agotado'],'Im exhausted [ah-goh-TAH-doh]',9),
    (v_lesson_id,'multiple_choice','How do you say "Im stressed"?','Estoy estresado',array['Tengo estrés también','Soy estresado','Tengo estresado'],'Im stressed',10),
    (v_lesson_id,'multiple_choice','How do you say "Hes very smart"?','Es muy listo',array['Es muy inteligente también','Tiene inteligente','Está listo'],'Hes very smart [LEES-toh]',11),
    (v_lesson_id,'multiple_choice','How do you say "to understand"?','entender',array['comprender también','saber','aprender'],'To understand [ehn-tehn-DEHR]',12),
    (v_lesson_id,'multiple_choice','How do you say "I do not understand"?','No entiendo',array['Yo no entender','Tengo no entender','No entendí'],'I do not understand',13),
    (v_lesson_id,'multiple_choice','How do you say "to give up"?','rendirse',array['darse por vencido también','dejar','abandonar también'],'To give up [rehn-DEER-seh]',14),
    (v_lesson_id,'multiple_choice','Translate "Aunque es difícil, no me rindo."','Although it is hard, I do not give up',array['I gave up because it was hard','It is too hard for me','I rendered the hard task'],'Although it is hard, I do not give up',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','no me puedo concentrar',array['no puedo estudiar','no me concentro','me puedo concentrar'],'I cannot concentrate',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','tengo un examen mañana',array['tendré un examen mañana','tengo dos exámenes','el examen es mañana'],'I have an exam tomorrow',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','estoy muy estresado',array['estoy muy cansado','no estoy estresado','soy muy estresado'],'I am very stressed',18),
    (v_lesson_id,'speaking','Say "I have an exam next week" in Spanish.','Tengo un examen la próxima semana',array[]::text[],'Tengo un examen la próxima semana',19),
    (v_lesson_id,'speaking','Say "I need help with math" in Spanish.','Necesito ayuda con matemáticas',array[]::text[],'Necesito ayuda con matemáticas',20),
    (v_lesson_id,'fill_blank','Complete: "No me puedo ___" (I cannot concentrate)','concentrar',array['estudiar','memorizar','aprender'],'concentrate',21),
    (v_lesson_id,'fill_blank','Complete: "Necesito ayuda ___ matemáticas." (with)','con',array['de','en','para'],'with',22);

  -- Lesson 4: speaking about your studies
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Education — Lesson 4', 'Talk about your education out loud.', 'speaking', 4, 20)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you ask "What are you studying?"','¿Qué estudias?',array['¿Qué estudia?','¿Cómo estudias?','¿Qué estudiaste?'],'What are you studying?',1),
    (v_lesson_id,'multiple_choice','How do you say "Im studying engineering"?','Estudio ingeniería',array['Soy ingeniería','Estoy ingeniería','Tengo ingeniería'],'Im studying engineering [een-heh-nyeh-REE-ah]',2),
    (v_lesson_id,'multiple_choice','How do you say "I want to be a doctor"?','Quiero ser médico',array['Yo quiero médico','Voy a ser médico también','Yo seré médico también'],'I want to be a doctor',3),
    (v_lesson_id,'multiple_choice','How do you say "Im in my second year"?','Estoy en segundo año',array['Soy segundo año','Tengo segundo año','En el año segundo'],'Im in my second year',4),
    (v_lesson_id,'multiple_choice','How do you say "Im learning Spanish"?','Estoy aprendiendo español',array['Yo aprender español','Tengo aprender','Voy aprender'],'Im learning Spanish',5),
    (v_lesson_id,'multiple_choice','How do you say "I have already learned a lot"?','Ya he aprendido mucho',array['Ya aprendí mucho','Yo aprendido mucho','He mucho aprendido'],'I have already learned a lot',6),
    (v_lesson_id,'multiple_choice','How do you say "Education is important"?','La educación es importante',array['Educación importante','La educar importante','Es importante educación'],'Education is important',7),
    (v_lesson_id,'multiple_choice','How do you say "to be self-taught"?','ser autodidacta',array['enseñarse a sí mismo','aprender solo también','autoaprender'],'To be self-taught [ow-toh-dee-DAHK-tah]',8),
    (v_lesson_id,'multiple_choice','How do you say "online course"?','el curso en línea',array['el curso online también','curso de internet','el curso digital'],'Online course',9),
    (v_lesson_id,'multiple_choice','How do you say "to take a course"?','hacer un curso',array['tomar un curso (LatAm)','tener curso','poner curso'],'To take a course',10),
    (v_lesson_id,'multiple_choice','How do you say "exchange program"?','programa de intercambio',array['programa de cambio','intercambio educativo','el viaje de estudio'],'Exchange program',11),
    (v_lesson_id,'multiple_choice','How do you say "to learn from mistakes"?','aprender de los errores',array['aprender errores','tomar errores','equivocarse para aprender'],'To learn from mistakes',12),
    (v_lesson_id,'multiple_choice','How do you say "lifelong learning"?','el aprendizaje permanente',array['aprendizaje toda la vida','aprender siempre','la educación continua también'],'Lifelong learning',13),
    (v_lesson_id,'multiple_choice','How do you say "to dropout (quit school)"?','dejar los estudios',array['abandonar la escuela también','salir de la escuela','dejarse'],'To drop out',14),
    (v_lesson_id,'multiple_choice','Translate "Si pudiera, estudiaría medicina."','If I could, I would study medicine',array['I can study medicine','I will study medicine','I have studied medicine'],'If I could, I would study medicine (conditional)',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','estoy estudiando español',array['estudio español','estudié español','estaba estudiando español'],'Im studying Spanish',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','ya he aprendido mucho',array['ya aprendí mucho','aprendí mucho','aprendo mucho'],'I have already learned a lot',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','quiero ser médico',array['quiero ser doctor','soy médico','voy a ser médico'],'I want to be a doctor',18),
    (v_lesson_id,'speaking','Say "Im studying Spanish at the university" in Spanish.','Estudio español en la universidad',array[]::text[],'Estudio español en la universidad',19),
    (v_lesson_id,'speaking','Say "Education is the key to success" in Spanish.','La educación es la clave del éxito',array[]::text[],'La educación es la clave del éxito',20),
    (v_lesson_id,'fill_blank','Complete: "Estoy ___ español." (Im learning)','aprendiendo',array['aprender','aprendido','aprendía'],'learning',21),
    (v_lesson_id,'fill_blank','Complete: "Quiero ___ médico." (to be)','ser',array['estar','tener','hacer'],'to be',22);

  -- =================== B1 ARTICLE ===================
  insert into public.articles (language_id, slug, title, title_english, level, reading_minutes, content_target, content_english, order_index)
  values (
    v_lang_id,
    'b1-el-tapeo-en-espana',
    'El tapeo en España',
    'Tapas Culture in Spain',
    'B1',
    3,
    E'En España, salir de tapas es mucho más que comer. Es una tradición social muy antigua, especialmente popular en Andalucía y Madrid. Las tapas son pequeñas porciones de comida que se sirven con una bebida, normalmente cerveza o vino.\n\nLa palabra "tapa" viene del verbo "tapar", que significa cubrir. Hay varias teorías sobre su origen. Según una de ellas, los camareros antiguamente cubrían las copas con un trozo de pan o jamón para evitar que entraran moscas. Con el tiempo, esa costumbre se transformó en una forma de comer entre amigos.\n\nIr de tapas es un ritual: se camina de bar en bar, se piden tapas distintas y se conversa. En muchas ciudades del sur, como Granada, las tapas todavía son gratis cuando pides una bebida. En el norte, en cambio, suelen llamarse "pinchos" y se pagan aparte.\n\nLas tapas más típicas incluyen la tortilla de patatas, el jamón ibérico, las croquetas, los boquerones en vinagre y las patatas bravas. Cada región tiene sus especialidades, así que probar tapas es también una forma de conocer la diversidad gastronómica del país.\n\nMás que una comida, el tapeo es una manera de vivir: lento, social y siempre acompañado.',
    E'In Spain, going out for tapas is much more than eating. It is a very old social tradition, especially popular in Andalusia and Madrid. Tapas are small portions of food served with a drink, usually beer or wine.\n\nThe word "tapa" comes from the verb "tapar", which means to cover. There are several theories about its origin. According to one of them, waiters used to cover the glasses with a piece of bread or ham to prevent flies from getting in. Over time, that custom transformed into a way of eating among friends.\n\nGoing for tapas is a ritual: you walk from bar to bar, you order different tapas and you chat. In many cities in the south, like Granada, tapas are still free when you order a drink. In the north, on the other hand, they are usually called "pinchos" and are paid for separately.\n\nThe most typical tapas include Spanish omelette, Iberian ham, croquettes, marinated anchovies and "patatas bravas". Each region has its specialties, so trying tapas is also a way to discover the gastronomic diversity of the country.\n\nMore than a meal, tapeo is a way of living: slow, social and always in good company.',
    1
  );

end $$;

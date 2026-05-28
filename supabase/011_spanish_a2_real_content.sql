-- 011_spanish_a2_real_content.sql
-- Real Spanish A2 lesson content.
-- Idempotent: re-running deletes Spanish A2 and reseeds.
-- A1 (010), B1, B2, C1 stay on their current content.
--
-- Per lesson: 10 vocab MC + 5 phrase MC + 3 listening + 2 speaking + 2 fill_blank.
-- A2 introduces: present-tense conjugation (yo/tú/él/ella), ir + a + infinitive,
-- reflexive verbs, direct/indirect object pronouns, gustar-style verbs.

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

  delete from public.courses where language_id = v_lang_id and cefr_level = 'A2';

  -- =================== A2.1 DAILY ROUTINES ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Daily Routines', 'Talk about your day with reflexive verbs in Spanish.', 'A2', 1)
  returning id into v_course_id;

  -- Lesson 1: reflexive verbs (morning routine)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Daily Routines — Lesson 1', 'Wake up, shower, get dressed.', 'vocabulary', 1, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "to wake up" (reflexive)?','despertarse',array['dormirse','levantarse','vestirse'],'To wake up [dehs-pehr-TAHR-seh]',1),
    (v_lesson_id,'multiple_choice','How do you say "to get up"?','levantarse',array['despertarse','sentarse','llevarse'],'To get up [leh-bahn-TAHR-seh]',2),
    (v_lesson_id,'multiple_choice','How do you say "to shower"?','ducharse',array['lavarse','bañarse también','duchar'],'To shower [doo-CHAR-seh]',3),
    (v_lesson_id,'multiple_choice','How do you say "to get dressed"?','vestirse',array['desvestirse','llevarse','llevar'],'To get dressed [behs-TEER-seh]',4),
    (v_lesson_id,'multiple_choice','How do you say "to brush ones teeth"?','lavarse los dientes',array['cepillarse los dientes','peinarse los dientes','poner los dientes'],'To brush ones teeth',5),
    (v_lesson_id,'multiple_choice','How do you say "to comb / style hair"?','peinarse',array['lavarse','pintarse','pegarse'],'To comb hair [peh-ee-NAHR-seh]',6),
    (v_lesson_id,'multiple_choice','How do you say "to have breakfast"?','desayunar',array['cenar','comer','almorzar'],'To have breakfast [deh-sah-yoo-NAHR]',7),
    (v_lesson_id,'multiple_choice','How do you say "to go to work"?','ir al trabajo',array['hacer trabajo','tener trabajo','venir trabajo'],'To go to work',8),
    (v_lesson_id,'multiple_choice','Conjugate: "I get up" (yo)','me levanto',array['te levantas','se levanta','levantarme'],'I get up [meh leh-BAHN-toh]',9),
    (v_lesson_id,'multiple_choice','Conjugate: "I shower" (yo)','me ducho',array['te duchas','se ducha','ducho'],'I shower [meh DOO-choh]',10),
    (v_lesson_id,'multiple_choice','Conjugate: "you (informal) get up"','te levantas',array['me levanto','se levanta','os levantáis'],'You get up [teh leh-BAHN-tahs]',11),
    (v_lesson_id,'multiple_choice','Conjugate: "she gets up"','se levanta',array['me levanto','te levantas','nos levantamos'],'She gets up [seh leh-BAHN-tah]',12),
    (v_lesson_id,'multiple_choice','Translate "Me ducho por la mañana."','I shower in the morning',array['I showered this morning','I will shower in the morning','I get dressed in the morning'],'I shower in the morning',13),
    (v_lesson_id,'multiple_choice','Translate "Mi hermano se viste rápido."','My brother gets dressed quickly',array['My brother dresses me','My brother wears something quickly','My brother is dressed'],'My brother gets dressed quickly',14),
    (v_lesson_id,'multiple_choice','How do you say "Then I have breakfast"?','Después desayuno',array['Antes desayuno','Más tarde el desayuno','Y desayunar'],'Then I have breakfast [dehs-PWEHS]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','me levanto a las siete',array['me levanto a las ocho','me acuesto a las siete','te levantas a las siete'],'I get up at seven',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','me ducho rápido',array['me ducho lento','me ducha rápido','no me ducho'],'I shower quickly',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','desayuno café y pan',array['ceno café y pan','desayuno té y pan','desayuna café y pan'],'I have coffee and bread for breakfast',18),
    (v_lesson_id,'speaking','Say "I get up at seven" in Spanish.','Me levanto a las siete',array[]::text[],'Me levanto a las siete',19),
    (v_lesson_id,'speaking','Say "I have breakfast at eight" in Spanish.','Desayuno a las ocho',array[]::text[],'Desayuno a las ocho',20),
    (v_lesson_id,'fill_blank','Complete: "___ ducho cada mañana." (I shower every morning.)','Me',array['Te','Se','Nos'],'Myself (reflexive)',21),
    (v_lesson_id,'fill_blank','Complete: "Mi hermana ___ levanta tarde." (My sister gets up late.)','se',array['me','te','nos'],'herself (reflexive)',22);

  -- Lesson 2: evening routine
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Daily Routines — Lesson 2', 'Evening, dinner and bedtime.', 'phrases', 2, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "to have dinner"?','cenar',array['comer','desayunar','almorzar'],'To have dinner [seh-NAHR]',1),
    (v_lesson_id,'multiple_choice','How do you say "to go to bed"?','acostarse',array['despertarse','sentarse','levantarse'],'To go to bed [ah-kohs-TAHR-seh]',2),
    (v_lesson_id,'multiple_choice','How do you say "to sleep"?','dormir',array['despertar','soñar','sentir'],'To sleep [dohr-MEER]',3),
    (v_lesson_id,'multiple_choice','How do you say "to rest"?','descansar',array['cansarse','desencantar','dejar'],'To rest [dehs-kahn-SAHR]',4),
    (v_lesson_id,'multiple_choice','How do you say "to watch TV"?','ver la televisión',array['mirar al televisor','tener televisión','hacer televisión'],'To watch TV [BEHR lah teh-leh-bee-SYOHN]',5),
    (v_lesson_id,'multiple_choice','How do you say "to read a book"?','leer un libro',array['mirar un libro','ver un libro','tener un libro'],'To read a book [leh-EHR]',6),
    (v_lesson_id,'multiple_choice','Conjugate: "I go to bed" (yo)','me acuesto',array['te acuestas','se acuesta','acostarme'],'I go to bed [meh ah-KWEHS-toh]',7),
    (v_lesson_id,'multiple_choice','Conjugate: "you (informal) go to bed"','te acuestas',array['me acuesto','se acuesta','os acostáis'],'You go to bed',8),
    (v_lesson_id,'multiple_choice','Conjugate: "he goes to bed"','se acuesta',array['te acuestas','me acuesto','nos acostamos'],'He goes to bed',9),
    (v_lesson_id,'multiple_choice','Conjugate: "I sleep eight hours"','duermo ocho horas',array['dormo ocho horas','duermes ocho horas','duerme ocho horas'],'I sleep 8 hours [DWEHR-moh]',10),
    (v_lesson_id,'multiple_choice','Translate "Cenamos en familia."','We have dinner as a family',array['We will have dinner','We had family dinner','We always cook'],'We have dinner as a family',11),
    (v_lesson_id,'multiple_choice','Translate "Después de cenar, leo un libro."','After dinner, I read a book',array['I read after eating','Before dinner I read','I read books at dinner'],'After dinner, I read a book',12),
    (v_lesson_id,'multiple_choice','How do you say "I am tired"?','Estoy cansado',array['Soy cansado','Tengo cansado','Me canso'],'I am tired [kahn-SAH-doh]',13),
    (v_lesson_id,'multiple_choice','How do you say "Goodnight, sweet dreams"?','Buenas noches, que descanses',array['Buenas noches, hasta luego','Buenas noches, gracias','Hasta mañana, buen sueño'],'Goodnight, sleep well',14),
    (v_lesson_id,'multiple_choice','How do you say "early in the morning"?','temprano por la mañana',array['tarde por la mañana','pronto la mañana','en la madrugada'],'Early in the morning [tehm-PRAH-noh]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','me acuesto a las once',array['me levanto a las once','se acuesta a las once','me acuesto a las nueve'],'I go to bed at eleven',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','después de cenar veo la tele',array['antes de cenar veo la tele','después de cenar leo un libro','no veo la tele'],'After dinner I watch TV',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','duermo ocho horas',array['duermes ocho horas','duermo seis horas','no duermo bien'],'I sleep eight hours',18),
    (v_lesson_id,'speaking','Say "I go to bed at eleven" in Spanish.','Me acuesto a las once',array[]::text[],'Me acuesto a las once',19),
    (v_lesson_id,'speaking','Say "I sleep eight hours" in Spanish.','Duermo ocho horas',array[]::text[],'Duermo ocho horas',20),
    (v_lesson_id,'fill_blank','Complete: "___ acuesto temprano." (I go to bed early.)','Me',array['Te','Se','Nos'],'Myself',21),
    (v_lesson_id,'fill_blank','Complete: "Estoy muy ___" (I am very tired.)','cansado',array['cansada','cansamos','cansar'],'tired (m.)',22);

  -- Lesson 3: weekly schedule (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Daily Routines — Lesson 3', 'Listen for daily and weekly schedules.', 'listening', 3, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "during the week"?','durante la semana',array['durante el día','la semana','en semana'],'During the week [doo-RAHN-teh]',1),
    (v_lesson_id,'multiple_choice','How do you say "on weekends"?','los fines de semana',array['en fines de semana','al fin','de semanas'],'On weekends',2),
    (v_lesson_id,'multiple_choice','How do you say "I work from home"?','Trabajo desde casa',array['Trabajo en casa también','Trabajo a casa','Tengo casa trabajo'],'I work from home [DEHS-deh KAH-sah]',3),
    (v_lesson_id,'multiple_choice','How do you say "before"?','antes',array['después','luego','tarde'],'Before [AHN-tehs]',4),
    (v_lesson_id,'multiple_choice','How do you say "after"?','después',array['antes','tarde','luego también'],'After [dehs-PWEHS]',5),
    (v_lesson_id,'multiple_choice','How do you say "then / next"?','luego',array['ahora','ya','nunca'],'Then / next [LWEH-goh]',6),
    (v_lesson_id,'multiple_choice','How do you say "to go for a walk"?','dar un paseo',array['ir un paseo','hacer un paseo','tener paseo'],'To go for a walk [pah-SEH-oh]',7),
    (v_lesson_id,'multiple_choice','How do you say "to do exercise"?','hacer ejercicio',array['ser ejercicio','tener ejercicio','dar ejercicio'],'To do exercise [eh-hehr-SEE-syoh]',8),
    (v_lesson_id,'multiple_choice','Conjugate: "we get up" (nosotros)','nos levantamos',array['os levantáis','se levantan','me levanto'],'We get up [nohs leh-bahn-TAH-mohs]',9),
    (v_lesson_id,'multiple_choice','Conjugate: "they get up"','se levantan',array['nos levantamos','os levantáis','me levanto'],'They get up',10),
    (v_lesson_id,'multiple_choice','How do you say "Usually I have breakfast at home"?','Normalmente desayuno en casa',array['Normalmente desayunar en casa','Yo desayuno casa','En casa el desayuno'],'Usually I have breakfast at home',11),
    (v_lesson_id,'multiple_choice','How do you say "I never eat breakfast"?','Nunca desayuno',array['Yo no desayuno nunca','Desayuno nunca','No desayunar'],'I never eat breakfast',12),
    (v_lesson_id,'multiple_choice','How do you say "twice a week"?','dos veces a la semana',array['dos vez por semana','dos por semana','dos veces semana'],'Twice a week',13),
    (v_lesson_id,'multiple_choice','How do you say "every morning"?','todas las mañanas',array['cada mañanas','toda mañana','en la mañana'],'Every morning',14),
    (v_lesson_id,'multiple_choice','How do you say "the weekend is for resting"?','el fin de semana es para descansar',array['el fin de semana es descansar','para descansar es fin','descansamos el fin de semana'],'Weekends are for resting',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','trabajo desde casa los lunes',array['trabajo en casa los lunes','trabajo los martes','trabajo desde casa'],'I work from home on Mondays',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','hago ejercicio tres veces a la semana',array['hago deporte cada día','hago ejercicio una vez','hago ejercicio los lunes'],'I exercise three times a week',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','los sábados doy un paseo',array['los sábados duermo','doy un paseo los domingos','damos un paseo'],'On Saturdays I take a walk',18),
    (v_lesson_id,'speaking','Say "I work from home on Fridays" in Spanish.','Trabajo desde casa los viernes',array[]::text[],'Trabajo desde casa los viernes',19),
    (v_lesson_id,'speaking','Say "Every morning I do exercise" in Spanish.','Todas las mañanas hago ejercicio',array[]::text[],'Todas las mañanas hago ejercicio',20),
    (v_lesson_id,'fill_blank','Complete: "Hago ejercicio tres ___ a la semana." (three times a week)','veces',array['vez','veza','vezas'],'times',21),
    (v_lesson_id,'fill_blank','Complete: "Trabajo ___ casa." (from home)','desde',array['de','en','por'],'from',22);

  -- Lesson 4: speaking about your day
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Daily Routines — Lesson 4', 'Describe your whole day out loud.', 'speaking', 4, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "First..."?','Primero...',array['Antes...','Después...','Luego...'],'First [pree-MEH-roh]',1),
    (v_lesson_id,'multiple_choice','How do you say "Finally..."?','Finalmente',array['Al final también','En final','Última'],'Finally [fee-nahl-MEHN-teh]',2),
    (v_lesson_id,'multiple_choice','How do you say "I am always busy"?','Siempre estoy ocupado',array['Siempre soy ocupado','Yo ocupado siempre','Estar ocupado siempre'],'I am always busy [oh-koo-PAH-doh]',3),
    (v_lesson_id,'multiple_choice','How do you say "free time"?','el tiempo libre',array['el tiempo gratis','tiempo de libre','la hora libre'],'Free time [TYEHM-poh LEE-breh]',4),
    (v_lesson_id,'multiple_choice','How do you say "I have free time on weekends"?','Tengo tiempo libre los fines de semana',array['Hay tiempo libre','Tengo libre tiempo','Soy tiempo libre'],'I have free time on weekends',5),
    (v_lesson_id,'multiple_choice','How do you say "I prepare lunch at home"?','Preparo la comida en casa',array['Hago la comida','Cocino para casa','Cocinar en casa'],'I prepare lunch at home',6),
    (v_lesson_id,'multiple_choice','How do you say "How do you start your day?"','¿Cómo empiezas tu día?',array['¿Qué haces día?','¿Cuándo empieza día?','¿Empezar el día?'],'How do you start your day? [ehm-PYEH-sahs]',7),
    (v_lesson_id,'multiple_choice','How do you say "I take a nap"?','Hago la siesta',array['Tomo siesta','Estoy siesta','Voy a siesta'],'I take a nap [SYEHS-tah]',8),
    (v_lesson_id,'multiple_choice','How do you say "I walk to work"?','Voy al trabajo caminando',array['Camino a trabajo','Voy trabajo a pie también','Trabajo caminando'],'I walk to work',9),
    (v_lesson_id,'multiple_choice','How do you say "Sometimes I cook"?','A veces cocino',array['Cocino a veces también','A veces cocinar','Yo a veces cocina'],'Sometimes I cook',10),
    (v_lesson_id,'multiple_choice','Translate "Después del trabajo, voy al gimnasio."','After work, I go to the gym',array['I work and go to gym','Before work, I go to gym','I go to gym in morning'],'After work, I go to the gym',11),
    (v_lesson_id,'multiple_choice','How do you say "I prefer to wake up early"?','Prefiero despertarme temprano',array['Quiero despertar pronto','Me gusta tarde','Yo despertar tarde'],'I prefer to wake up early',12),
    (v_lesson_id,'multiple_choice','How do you say "It depends on the day"?','Depende del día',array['Depender del día','Es el día','El día depende'],'It depends on the day [deh-PEHN-deh]',13),
    (v_lesson_id,'multiple_choice','How do you say "I am a morning person"?','Soy una persona madrugadora',array['Estoy madrugando','Tengo persona mañana','Soy mañana persona'],'I am a morning person [mah-droo-gah-DOH-rah]',14),
    (v_lesson_id,'multiple_choice','How do you say "I am a night owl"?','Soy una persona nocturna',array['Soy noche','Tengo noche','Estoy noche'],'I am a night owl [nohk-TOOR-nah]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','después del trabajo voy al gimnasio',array['antes del trabajo voy al gimnasio','después del trabajo voy a casa','voy al gimnasio por la mañana'],'After work I go to the gym',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','tengo tiempo libre los domingos',array['tengo tiempo los lunes','no tengo tiempo libre','tengo tiempo libre los sábados'],'I have free time on Sundays',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','prefiero despertarme temprano',array['prefiero acostarme tarde','prefiero despertarme tarde','quiero despertar temprano'],'I prefer to wake up early',18),
    (v_lesson_id,'speaking','Say "I am always busy" in Spanish.','Siempre estoy ocupado',array[]::text[],'Siempre estoy ocupado',19),
    (v_lesson_id,'speaking','Say "After work I go to the gym" in Spanish.','Después del trabajo voy al gimnasio',array[]::text[],'Después del trabajo voy al gimnasio',20),
    (v_lesson_id,'fill_blank','Complete: "___ despertarme temprano." (I prefer to wake up early.)','Prefiero',array['Quiero','Tengo','Soy'],'I prefer',21),
    (v_lesson_id,'fill_blank','Complete: "Tengo tiempo ___" (I have free time.)','libre',array['gratis','suelto','vacío'],'free (available)',22);

  -- =================== A2.2 TRANSPORT ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Transport', 'Move around the city or country in Spanish.', 'A2', 2)
  returning id into v_course_id;

  -- Lesson 1: vehicles
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Transport — Lesson 1', 'Vehicles and getting around.', 'vocabulary', 1, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "car"?','el coche',array['el carro (LatAm)','el camión','el cocho'],'Car (Spain) [KOH-cheh]',1),
    (v_lesson_id,'multiple_choice','How do you say "bus"?','el autobús',array['el avión','el auto','el camión también'],'Bus [ow-toh-BOOS]',2),
    (v_lesson_id,'multiple_choice','How do you say "train"?','el tren',array['el tranvía','el camión','el transporte'],'Train [TREHN]',3),
    (v_lesson_id,'multiple_choice','How do you say "subway / metro"?','el metro',array['el metropolitano','el medio','el tube'],'Subway [MEH-troh]',4),
    (v_lesson_id,'multiple_choice','How do you say "plane"?','el avión',array['el aeropuerto','el aire','el aviador'],'Plane [ah-BYOHN]',5),
    (v_lesson_id,'multiple_choice','How do you say "bicycle"?','la bicicleta',array['la moto','la biblioteca','el bicicleto'],'Bicycle [bee-see-KLEH-tah]',6),
    (v_lesson_id,'multiple_choice','How do you say "motorcycle"?','la moto',array['el moto','la bici','el motor'],'Motorcycle [MOH-toh]',7),
    (v_lesson_id,'multiple_choice','How do you say "taxi"?','el taxi',array['la taxa','el taxim','el tablón'],'Taxi [TAHK-see]',8),
    (v_lesson_id,'multiple_choice','How do you say "to drive"?','conducir',array['manejar (LatAm)','conducir el coche','correr'],'To drive (Spain) [kohn-doo-SEER]',9),
    (v_lesson_id,'multiple_choice','How do you say "to take (the bus)"?','tomar (el autobús)',array['coger (el autobús)','tener (el autobús)','llevar (el autobús)'],'To take [toh-MAHR / koh-HEHR]',10),
    (v_lesson_id,'multiple_choice','How do you say "station"?','la estación',array['la parada','el aeropuerto','el puerto'],'Station [ehs-tah-SYOHN]',11),
    (v_lesson_id,'multiple_choice','How do you say "bus stop"?','la parada de autobús',array['la estación de bus','el alto del autobús','el lugar del bus'],'Bus stop [pah-RAH-dah]',12),
    (v_lesson_id,'multiple_choice','How do you say "ticket"?','el billete',array['el boleto (LatAm)','el pase','la entrada'],'Ticket (Spain) [bee-YEH-teh]',13),
    (v_lesson_id,'multiple_choice','How do you say "to travel"?','viajar',array['viaje','viajante','vivir'],'To travel [byah-HAHR]',14),
    (v_lesson_id,'multiple_choice','How do you say "the airport"?','el aeropuerto',array['el avión','el aire','la aerolínea'],'Airport [ah-eh-roh-PWEHR-toh]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','tomo el autobús',array['tomo el avión','tomo el metro','tomo un café'],'I take the bus',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','un billete de ida y vuelta',array['un billete de ida','un boleto de ida','un viaje de ida'],'A round-trip ticket',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','voy en bicicleta',array['voy en coche','voy a la biblioteca','voy en bici también'],'I go by bicycle',18),
    (v_lesson_id,'speaking','Say "I take the bus to work" in Spanish.','Tomo el autobús al trabajo',array[]::text[],'Tomo el autobús al trabajo',19),
    (v_lesson_id,'speaking','Say "I go by bicycle" in Spanish.','Voy en bicicleta',array[]::text[],'Voy en bicicleta',20),
    (v_lesson_id,'fill_blank','Complete: "Voy ___ tren." (I go by train.)','en',array['de','con','a'],'by',21),
    (v_lesson_id,'fill_blank','Complete: "Un ___ de ida y vuelta, por favor." (A round-trip ticket)','billete',array['boleto','pasaje','entrada'],'ticket (Spain)',22);

  -- Lesson 2: buying tickets, asking
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Transport — Lesson 2', 'Buy tickets and ask about travel.', 'phrases', 2, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "one-way ticket"?','un billete de ida',array['billete de ir','un billete vuelta','un billete solo'],'One-way ticket [EE-dah]',1),
    (v_lesson_id,'multiple_choice','How do you say "round-trip"?','ida y vuelta',array['ir y volver','salir y entrar','viaje completo'],'Round-trip [EE-dah ee BWEHL-tah]',2),
    (v_lesson_id,'multiple_choice','How do you ask "What time does it leave?"','¿A qué hora sale?',array['¿Cuándo es?','¿Qué hora sale?','¿Cuál es la hora?'],'What time does it leave? [SAH-leh]',3),
    (v_lesson_id,'multiple_choice','How do you ask "What time does it arrive?"','¿A qué hora llega?',array['¿Cuándo llega?','¿Qué hora es la llegada?','¿Cuál llega?'],'What time does it arrive? [YEH-gah]',4),
    (v_lesson_id,'multiple_choice','How do you ask "Where is the station?"','¿Dónde está la estación?',array['¿Cómo está la estación?','¿Dónde es estación?','¿Cuál es la estación?'],'Where is the station?',5),
    (v_lesson_id,'multiple_choice','How do you say "the next train"?','el próximo tren',array['el tren siguiente también','el tren que sigue','el tren después'],'The next train [PROHK-see-moh]',6),
    (v_lesson_id,'multiple_choice','How do you say "the last bus"?','el último autobús',array['el final autobús','el autobús último','el autobús que termina'],'The last bus [OOL-tee-moh]',7),
    (v_lesson_id,'multiple_choice','How do you say "platform"?','el andén',array['el andamiento','el camino','el paso'],'Platform [ahn-DEHN]',8),
    (v_lesson_id,'multiple_choice','How do you say "first class"?','primera clase',array['clase primera también','clase de primero','clase un'],'First class [pree-MEH-rah KLAH-seh]',9),
    (v_lesson_id,'multiple_choice','How do you say "delayed"?','retrasado',array['atrasado también','tarde','tardío'],'Delayed [reh-trah-SAH-doh]',10),
    (v_lesson_id,'multiple_choice','How do you say "on time"?','a tiempo',array['en hora','de hora','con tiempo'],'On time [ah TYEHM-poh]',11),
    (v_lesson_id,'multiple_choice','How do you say "Is this seat free?"','¿Está libre este asiento?',array['¿Hay asiento aquí?','¿El asiento es?','¿Puedo este asiento?'],'Is this seat free? [ah-SYEHN-toh]',12),
    (v_lesson_id,'multiple_choice','How do you say "I need to change trains"?','Necesito cambiar de tren',array['Necesito otro tren','Cambio tren','Quiero tren otro'],'I need to change trains [kahm-BYAHR]',13),
    (v_lesson_id,'multiple_choice','How do you say "How long does it take?"','¿Cuánto tarda?',array['¿Cuándo dura?','¿Qué tarda?','¿Cuál es tiempo?'],'How long does it take? [TAR-dah]',14),
    (v_lesson_id,'multiple_choice','Translate "El tren a Madrid sale del andén tres."','The train to Madrid leaves from platform three',array['The train arrives at platform 3','Madrid has three platforms','Platform three is for trains'],'The train to Madrid leaves from platform 3',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','¿a qué hora sale el tren?',array['¿a qué hora llega el tren?','¿qué hora sale?','¿dónde está el tren?'],'What time does the train leave?',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','está retrasado',array['está a tiempo','está aquí','está libre'],'It is delayed',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','el andén número cinco',array['el andén número quince','el andén número diez','el número cinco'],'Platform number five',18),
    (v_lesson_id,'speaking','Say "What time does the bus leave?" in Spanish.','¿A qué hora sale el autobús?',array[]::text[],'¿A qué hora sale el autobús?',19),
    (v_lesson_id,'speaking','Say "Is this seat free?" in Spanish.','¿Está libre este asiento?',array[]::text[],'¿Está libre este asiento?',20),
    (v_lesson_id,'fill_blank','Complete: "El próximo tren ___ a las nueve." (The next train leaves at nine.)','sale',array['llega','tiene','va'],'leaves',21),
    (v_lesson_id,'fill_blank','Complete: "Necesito ___ de tren." (I need to change trains.)','cambiar',array['mover','salir','llegar'],'to change',22);

  -- Lesson 3: directions on transport (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Transport — Lesson 3', 'Listen to announcements and directions.', 'listening', 3, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "Which line goes to..."?','¿Qué línea va a...?',array['¿Cuál tren a...?','¿Qué línea es?','¿Cuál camino?'],'Which line goes to... [LEE-neh-ah]',1),
    (v_lesson_id,'multiple_choice','How do you say "the next stop"?','la próxima parada',array['parada próxima también','la parada siguiente también','la parada después'],'The next stop',2),
    (v_lesson_id,'multiple_choice','How do you say "the door is closing"?','la puerta se cierra',array['la puerta cierra','la puerta es cerrada','la puerta cerrar'],'The door is closing',3),
    (v_lesson_id,'multiple_choice','How do you say "get off at"?','bajar en',array['salir en','dejar en','llegar a'],'Get off at [bah-HAHR]',4),
    (v_lesson_id,'multiple_choice','How do you say "get on"?','subir',array['entrar','poner','llegar'],'Get on [soo-BEER]',5),
    (v_lesson_id,'multiple_choice','How do you say "go straight"?','seguir recto',array['ir recto también','seguir derecho (LatAm)','ir adelante'],'Go straight [seh-GHEER REHK-toh]',6),
    (v_lesson_id,'multiple_choice','How do you say "go back / return"?','volver',array['regresar también','retornar','volverse'],'Go back [bohl-BEHR]',7),
    (v_lesson_id,'multiple_choice','How do you say "I missed the train"?','Perdí el tren',array['Faltó el tren','No tomé el tren','Olvidé el tren'],'I missed the train [pehr-DEE]',8),
    (v_lesson_id,'multiple_choice','How do you say "the highway"?','la autopista',array['la carretera','la calle','la avenida'],'Highway [ow-toh-PEES-tah]',9),
    (v_lesson_id,'multiple_choice','How do you say "the road"?','la carretera',array['la calle','la avenida','la senda'],'Road [kah-rreh-TEH-rah]',10),
    (v_lesson_id,'multiple_choice','How do you say "traffic jam"?','el atasco',array['el trafico','el tapón también','el problema'],'Traffic jam [ah-TAHS-koh]',11),
    (v_lesson_id,'multiple_choice','How do you say "rush hour"?','la hora punta',array['hora pico (LatAm)','la hora más','la hora pico'],'Rush hour (Spain) [POON-tah]',12),
    (v_lesson_id,'multiple_choice','How do you say "to park"?','aparcar',array['estacionar (LatAm)','parar','aparcar el coche'],'To park (Spain) [ah-pahr-KAHR]',13),
    (v_lesson_id,'multiple_choice','How do you say "the parking lot"?','el aparcamiento',array['el estacionamiento (LatAm)','el parking','la zona de parar'],'Parking lot (Spain)',14),
    (v_lesson_id,'multiple_choice','Translate "El metro pasa cada cinco minutos."','The subway runs every five minutes',array['The subway is slow','I take the subway','The subway costs five euros'],'The subway runs every 5 minutes',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','próxima parada',array['próxima salida','última parada','próximo viaje'],'Next stop',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','hay mucho tráfico',array['no hay tráfico','hay un atasco','hay mucho tiempo'],'There is a lot of traffic',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','perdí el autobús',array['perdí el tren','tomé el autobús','perdí el camino'],'I missed the bus',18),
    (v_lesson_id,'speaking','Say "Where is the next stop?" in Spanish.','¿Dónde está la próxima parada?',array[]::text[],'¿Dónde está la próxima parada?',19),
    (v_lesson_id,'speaking','Say "There is a lot of traffic" in Spanish.','Hay mucho tráfico',array[]::text[],'Hay mucho tráfico',20),
    (v_lesson_id,'fill_blank','Complete: "Tengo que ___ en la próxima parada." (I have to get off at the next stop.)','bajar',array['subir','volver','llegar'],'get off',21),
    (v_lesson_id,'fill_blank','Complete: "Hay mucho ___" (There is a lot of traffic.)','tráfico',array['atasco','camino','coche'],'traffic',22);

  -- Lesson 4: planning a trip
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Transport — Lesson 4', 'Plan a short trip and talk about it.', 'speaking', 4, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "I am going to travel"?','Voy a viajar',array['Yo viajar','Estoy viajar','Tengo viajar'],'I am going to travel [BOY ah byah-HAHR]',1),
    (v_lesson_id,'multiple_choice','How do you say "I want to visit Madrid"?','Quiero visitar Madrid',array['Voy a Madrid también','Yo Madrid','Hay Madrid'],'I want to visit Madrid',2),
    (v_lesson_id,'multiple_choice','How do you say "How much is the ticket?"','¿Cuánto cuesta el billete?',array['¿Cuál es el precio?','¿Cuánto el billete?','¿Cuesta cuánto?'],'How much is the ticket?',3),
    (v_lesson_id,'multiple_choice','How do you say "Is there a discount for students?"','¿Hay descuento para estudiantes?',array['¿Tienes descuento estudiantes?','¿Es descuento estudiantes?','¿Cuánto descuento?'],'Is there a discount for students?',4),
    (v_lesson_id,'multiple_choice','How do you say "I prefer to go by train"?','Prefiero ir en tren',array['Yo prefiero tren','Quiero tren','Voy a tren'],'I prefer to go by train',5),
    (v_lesson_id,'multiple_choice','How do you say "the trip takes two hours"?','el viaje dura dos horas',array['el viaje tiene dos horas','el viaje es dos horas','dos horas de viaje'],'The trip takes two hours [DOO-rah]',6),
    (v_lesson_id,'multiple_choice','How do you say "without a stop"?','sin parar',array['no parar','sin parada','con parada'],'Without stopping [seen pah-RAHR]',7),
    (v_lesson_id,'multiple_choice','How do you say "to take a flight"?','tomar un vuelo',array['coger un avión','tomar avión','volar'],'To take a flight [BWEH-loh]',8),
    (v_lesson_id,'multiple_choice','How do you say "to land"?','aterrizar',array['llegar','bajar','tocar tierra'],'To land [ah-teh-rree-SAHR]',9),
    (v_lesson_id,'multiple_choice','How do you say "to take off"?','despegar',array['subir','salir','volar'],'To take off [dehs-peh-GAHR]',10),
    (v_lesson_id,'multiple_choice','How do you say "boarding pass"?','la tarjeta de embarque',array['el billete','la entrada','el pase'],'Boarding pass [ehm-BAR-keh]',11),
    (v_lesson_id,'multiple_choice','How do you say "passport"?','el pasaporte',array['el pasaje','el pase de viaje','el documento'],'Passport [pah-sah-POHR-teh]',12),
    (v_lesson_id,'multiple_choice','How do you say "the luggage"?','el equipaje',array['las maletas también','la carga','la bolsa'],'Luggage [eh-kee-PAH-heh]',13),
    (v_lesson_id,'multiple_choice','How do you say "the gate (airport)"?','la puerta de embarque',array['la puerta de avión','la entrada','la salida'],'Boarding gate',14),
    (v_lesson_id,'multiple_choice','Translate "Mi vuelo sale a las tres de la tarde."','My flight leaves at 3 PM',array['My flight arrives at 3','I leave at 3 PM','The flight is at 3 in the morning'],'My flight leaves at 3 PM',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','prefiero ir en tren',array['prefiero ir en avión','quiero ir en tren','voy en tren'],'I prefer to go by train',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','el viaje dura dos horas',array['el viaje dura tres horas','el viaje es dos horas','dura dos minutos'],'The trip takes 2 hours',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','mi vuelo es a las tres',array['mi viaje es a las tres','mi tren es a las tres','a las tres voy'],'My flight is at three',18),
    (v_lesson_id,'speaking','Say "I prefer to travel by train" in Spanish.','Prefiero viajar en tren',array[]::text[],'Prefiero viajar en tren',19),
    (v_lesson_id,'speaking','Say "How much does the ticket cost?" in Spanish.','¿Cuánto cuesta el billete?',array[]::text[],'¿Cuánto cuesta el billete?',20),
    (v_lesson_id,'fill_blank','Complete: "Voy ___ viajar a México." (I am going to travel to Mexico.)','a',array['en','de','para'],'going to',21),
    (v_lesson_id,'fill_blank','Complete: "El vuelo ___ dos horas." (The flight lasts two hours.)','dura',array['lleva','tiene','hace'],'lasts',22);

  -- =================== A2.3 HEALTH ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Health', 'Talk about your body, symptoms and the doctor in Spanish.', 'A2', 3)
  returning id into v_course_id;

  -- Lesson 1: body parts
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Health — Lesson 1', 'Parts of the body.', 'vocabulary', 1, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "head"?','la cabeza',array['el cabello','la cara','el cuello'],'Head [kah-BEH-sah]',1),
    (v_lesson_id,'multiple_choice','How do you say "eye"?','el ojo',array['el oído','la oreja','el hoyo'],'Eye [OH-hoh]',2),
    (v_lesson_id,'multiple_choice','How do you say "ear"?','la oreja',array['el oído (inner)','el ojo','la órbita'],'Ear (outer) [oh-REH-hah]',3),
    (v_lesson_id,'multiple_choice','How do you say "nose"?','la nariz',array['la boca','la oreja','la nuca'],'Nose [nah-REES]',4),
    (v_lesson_id,'multiple_choice','How do you say "mouth"?','la boca',array['la lengua','la nariz','el labio'],'Mouth [BOH-kah]',5),
    (v_lesson_id,'multiple_choice','How do you say "arm"?','el brazo',array['la pierna','el hombro','la mano'],'Arm [BRAH-soh]',6),
    (v_lesson_id,'multiple_choice','How do you say "hand"?','la mano',array['el dedo','la muñeca','la palma'],'Hand [MAH-noh]',7),
    (v_lesson_id,'multiple_choice','How do you say "leg"?','la pierna',array['el pie','el brazo','el muslo'],'Leg [PYEHR-nah]',8),
    (v_lesson_id,'multiple_choice','How do you say "foot"?','el pie',array['la pierna','el tobillo','la planta'],'Foot [PYEH]',9),
    (v_lesson_id,'multiple_choice','How do you say "stomach"?','el estómago',array['el pecho','el hígado','la barriga también'],'Stomach [ehs-TOH-mah-goh]',10),
    (v_lesson_id,'multiple_choice','How do you say "back"?','la espalda',array['el pecho','el hombro','la columna'],'Back [ehs-PAHL-dah]',11),
    (v_lesson_id,'multiple_choice','How do you say "throat"?','la garganta',array['el cuello','la lengua','la boca'],'Throat [gahr-GAHN-tah]',12),
    (v_lesson_id,'multiple_choice','How do you say "tooth"?','el diente',array['la encía','el colmillo','la muela'],'Tooth [DYEHN-teh]',13),
    (v_lesson_id,'multiple_choice','How do you say "heart"?','el corazón',array['el pulmón','el hígado','el cerebro'],'Heart [koh-rah-SOHN]',14),
    (v_lesson_id,'multiple_choice','How do you say "finger"?','el dedo',array['la mano','la uña','el pulgar'],'Finger [DEH-doh]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','me duele la cabeza',array['me duele el cuello','me duele la espalda','me duele la cara'],'My head hurts',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','me duele el estómago',array['me duele la espalda','me duele el cuello','me duele el oído'],'My stomach hurts',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','tengo la garganta seca',array['tengo la nariz seca','tengo la cara seca','tengo la garganta roja'],'My throat is dry',18),
    (v_lesson_id,'speaking','Say "My head hurts" in Spanish.','Me duele la cabeza',array[]::text[],'Me duele la cabeza',19),
    (v_lesson_id,'speaking','Say "My back hurts" in Spanish.','Me duele la espalda',array[]::text[],'Me duele la espalda',20),
    (v_lesson_id,'fill_blank','Complete: "Me ___ la cabeza." (My head hurts.)','duele',array['duelo','duelen','duela'],'hurts (singular)',21),
    (v_lesson_id,'fill_blank','Complete: "Me duelen los ___" (My eyes hurt.)','ojos',array['ojo','dedo','dientes'],'eyes',22);

  -- Lesson 2: symptoms and at the doctor
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Health — Lesson 2', 'Symptoms and seeing the doctor.', 'phrases', 2, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "doctor"?','el médico',array['el doctor también','el medio','el medicina'],'Doctor [MEH-dee-koh]',1),
    (v_lesson_id,'multiple_choice','How do you say "nurse"?','la enfermera',array['la enferma','el enfermero','la enfermería'],'Nurse [ehn-fehr-MEH-rah]',2),
    (v_lesson_id,'multiple_choice','How do you say "hospital"?','el hospital',array['la clínica','la enfermería','la sala'],'Hospital [ohs-pee-TAHL]',3),
    (v_lesson_id,'multiple_choice','How do you say "pharmacy"?','la farmacia',array['el farmacéutico','la medicina','la droguería'],'Pharmacy [fahr-MAH-syah]',4),
    (v_lesson_id,'multiple_choice','How do you say "medicine"?','la medicina',array['el medicamento también','la pastilla','la cura'],'Medicine [meh-dee-SEE-nah]',5),
    (v_lesson_id,'multiple_choice','How do you say "pill"?','la pastilla',array['el comprimido también','la tableta también','el polvo'],'Pill [pahs-TEE-yah]',6),
    (v_lesson_id,'multiple_choice','How do you say "fever"?','la fiebre',array['la calentura también','el frío','la temperatura'],'Fever [FYEH-breh]',7),
    (v_lesson_id,'multiple_choice','How do you say "flu"?','la gripe',array['el gripo','el resfriado','el catarro'],'Flu [GREE-peh]',8),
    (v_lesson_id,'multiple_choice','How do you say "cold (illness)"?','el resfriado',array['el frío','el catarro también','la gripe'],'Cold (illness) [rehs-FRYAH-doh]',9),
    (v_lesson_id,'multiple_choice','How do you say "to hurt / ache"?','doler',array['herir','daño','dolor'],'To hurt [doh-LEHR]',10),
    (v_lesson_id,'multiple_choice','How do you say "pain"?','el dolor',array['el daño','el doler','la pena'],'Pain [doh-LOHR]',11),
    (v_lesson_id,'multiple_choice','How do you say "I feel sick"?','Me siento mal',array['Yo estoy mal','Me caigo mal','Estoy enfermo también'],'I feel sick [meh SYEHN-toh MAHL]',12),
    (v_lesson_id,'multiple_choice','How do you say "I have a cough"?','Tengo tos',array['Soy tos','Estoy tos','Hago tos'],'I have a cough [TOHS]',13),
    (v_lesson_id,'multiple_choice','How do you say "I am sick"?','Estoy enfermo',array['Soy enfermo','Tengo enfermo','Estoy mal'],'I am sick [ehn-FEHR-moh]',14),
    (v_lesson_id,'multiple_choice','How do you say "appointment"?','la cita',array['la consulta','la reunión','el citar'],'Appointment [SEE-tah]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','tengo fiebre',array['tengo gripe','tengo frío','tengo hambre'],'I have a fever',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','necesito ir al médico',array['voy al médico','tengo que ir al hospital','necesito una pastilla'],'I need to go to the doctor',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','me siento mal',array['me siento bien','me caigo mal','siento mal'],'I feel sick',18),
    (v_lesson_id,'speaking','Say "I have a fever" in Spanish.','Tengo fiebre',array[]::text[],'Tengo fiebre',19),
    (v_lesson_id,'speaking','Say "I need a doctor" in Spanish.','Necesito un médico',array[]::text[],'Necesito un médico',20),
    (v_lesson_id,'fill_blank','Complete: "Tengo ___" (I have a fever.)','fiebre',array['gripe','frío','sed'],'fever',21),
    (v_lesson_id,'fill_blank','Complete: "Estoy ___" (I am sick.)','enfermo',array['enferma','enfermos','enfermar'],'sick (m.)',22);

  -- Lesson 3: at the pharmacy (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Health — Lesson 3', 'At the pharmacy: ask for what you need.', 'listening', 3, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "Do I need a prescription?"','¿Necesito una receta?',array['¿Tienes receta?','¿Es receta?','¿Cómo receta?'],'Do I need a prescription? [reh-SEH-tah]',1),
    (v_lesson_id,'multiple_choice','How do you say "Take this pill twice a day"?','Tome esta pastilla dos veces al día',array['Toma pastillas','Pone una pastilla','Toma esto cada día'],'Take this pill twice a day',2),
    (v_lesson_id,'multiple_choice','How do you say "Im allergic to..."','Soy alérgico a...',array['Estoy alérgico','Tengo alergia también','Yo alergia'],'I am allergic to... [ah-LEHR-hee-koh]',3),
    (v_lesson_id,'multiple_choice','How do you say "antibiotic"?','el antibiótico',array['la antibio','antibiótica','antibiotic'],'Antibiotic [ahn-tee-BYOH-tee-koh]',4),
    (v_lesson_id,'multiple_choice','How do you say "aspirin"?','la aspirina',array['la pastilla','la cura','la medicina'],'Aspirin [ahs-pee-REE-nah]',5),
    (v_lesson_id,'multiple_choice','How do you say "to feel better"?','sentirse mejor',array['ser mejor','sentir bueno','ir mejor'],'To feel better [sehn-TEER-seh meh-HOHR]',6),
    (v_lesson_id,'multiple_choice','How do you say "to get well soon"?','recuperarse pronto',array['mejorar rápido','curarse rápido','sanar mejor'],'To get well soon [reh-koo-peh-RAHR-seh]',7),
    (v_lesson_id,'multiple_choice','How do you say "vomit"?','vomitar',array['vomito','vómito','vómica'],'To vomit [boh-mee-TAHR]',8),
    (v_lesson_id,'multiple_choice','How do you say "dizzy"?','mareado',array['enfermo','cansado','débil'],'Dizzy [mah-reh-AH-doh]',9),
    (v_lesson_id,'multiple_choice','How do you say "I am bleeding"?','Estoy sangrando',array['Tengo sangre','Yo sangre','Soy sangre'],'I am bleeding [sahn-GRAHN-doh]',10),
    (v_lesson_id,'multiple_choice','How do you say "broken bone"?','un hueso roto',array['un hueso quebrado también','un hueso malo','un hueso enfermo'],'Broken bone [WEH-soh ROH-toh]',11),
    (v_lesson_id,'multiple_choice','How do you say "Help, an emergency!"?','¡Socorro, una emergencia!',array['¡Ayudar emergencia!','¡Emergencia, por favor!','¡Necesito ayuda!'],'Help, an emergency! [soh-KOH-rroh]',12),
    (v_lesson_id,'multiple_choice','How do you say "Call an ambulance!"?','¡Llama una ambulancia!',array['¡Coger una ambulancia!','¡Ambulancia ya!','¡Necesito ambulancia!'],'Call an ambulance! [ahm-boo-LAHN-syah]',13),
    (v_lesson_id,'multiple_choice','How do you say "Take three times a day"?','Tome tres veces al día',array['Tomar tres días','Toma tres veces día','Tres tomas a día'],'Take three times a day',14),
    (v_lesson_id,'multiple_choice','How do you say "with food / on a full stomach"?','con comida',array['en comida','sobre comida','con el estómago lleno'],'With food [kohn koh-MEE-dah]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','tome dos pastillas al día',array['tome una pastilla al día','tome tres pastillas al día','toma dos pastillas en día'],'Take two pills a day',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','soy alérgico a la penicilina',array['soy alérgico a los antibióticos','tengo alergia a la aspirina','soy alérgica a la penicilina'],'I am allergic to penicillin',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','estoy mareado',array['estoy cansado','estoy enfermo','soy mareado'],'I am dizzy',18),
    (v_lesson_id,'speaking','Say "I am allergic to peanuts" in Spanish.','Soy alérgico a los cacahuetes',array[]::text[],'Soy alérgico a los cacahuetes',19),
    (v_lesson_id,'speaking','Say "Take this twice a day" in Spanish.','Tome esto dos veces al día',array[]::text[],'Tome esto dos veces al día',20),
    (v_lesson_id,'fill_blank','Complete: "Tome esta pastilla ___ veces al día." (twice a day)','dos',array['una','tres','cuatro'],'twice',21),
    (v_lesson_id,'fill_blank','Complete: "Soy alérgico ___ los frutos secos." (allergic to nuts)','a',array['de','con','en'],'to',22);

  -- Lesson 4: healthy habits
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Health — Lesson 4', 'Talk about healthy lifestyle out loud.', 'speaking', 4, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "to take care of yourself"?','cuidarse',array['cuidar','cuidados','cuidate'],'To take care of yourself [kwee-DAHR-seh]',1),
    (v_lesson_id,'multiple_choice','How do you say "to exercise / work out"?','hacer ejercicio',array['ser ejercicio','hacer deporte también','tener ejercicio'],'To exercise',2),
    (v_lesson_id,'multiple_choice','How do you say "to eat healthy"?','comer sano',array['comer saludable también','comer salud','comer salada'],'To eat healthy [SAH-noh]',3),
    (v_lesson_id,'multiple_choice','How do you say "to drink water"?','beber agua',array['tomar agua también','poner agua','sacar agua'],'To drink water',4),
    (v_lesson_id,'multiple_choice','How do you say "to sleep well"?','dormir bien',array['ser bien dormir','dormir mucho','dormido bien'],'To sleep well',5),
    (v_lesson_id,'multiple_choice','How do you say "to quit smoking"?','dejar de fumar',array['parar fumar','no fumar más','salir de fumar'],'To quit smoking [deh-HAHR deh foo-MAHR]',6),
    (v_lesson_id,'multiple_choice','How do you say "It is bad for your health"?','Es malo para la salud',array['Es malo a la salud','Hace mala salud','La salud es mala'],'It is bad for your health',7),
    (v_lesson_id,'multiple_choice','How do you say "It is good for your health"?','Es bueno para la salud',array['Es bueno a la salud','Hace buena salud','La salud es buena'],'It is good for your health',8),
    (v_lesson_id,'multiple_choice','How do you say "stress"?','el estrés',array['el estress','el strés','la tensión'],'Stress [ehs-TREHS]',9),
    (v_lesson_id,'multiple_choice','How do you say "to relax"?','relajarse',array['descansar','calmarse también','tranquilo'],'To relax [reh-lah-HAR-seh]',10),
    (v_lesson_id,'multiple_choice','How do you say "I do yoga"?','Hago yoga',array['Soy yoga','Tengo yoga','Voy yoga'],'I do yoga [YOH-gah]',11),
    (v_lesson_id,'multiple_choice','How do you say "I run every morning"?','Corro todas las mañanas',array['Yo correr cada mañana','Corro toda mañana','Yo corro las mañanas'],'I run every morning',12),
    (v_lesson_id,'multiple_choice','How do you say "to gain weight"?','engordar',array['ganar peso también','aumentar','crecer'],'To gain weight [ehn-gohr-DAHR]',13),
    (v_lesson_id,'multiple_choice','How do you say "to lose weight"?','adelgazar',array['perder peso también','bajar','disminuir'],'To lose weight [ah-dehl-gah-SAHR]',14),
    (v_lesson_id,'multiple_choice','Translate "Es importante hacer deporte."','It is important to do sports',array['I do sports always','Sports are important to do','It is good to do sports'],'It is important to do sports',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','tengo que dejar de fumar',array['quiero dejar de fumar','estoy fumando','no quiero fumar'],'I have to quit smoking',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','corro todas las mañanas',array['corro cada noche','corremos las mañanas','corro las noches'],'I run every morning',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','es bueno para la salud',array['es malo para la salud','es bueno para la cabeza','es buena para la salud'],'It is good for your health',18),
    (v_lesson_id,'speaking','Say "I do exercise every day" in Spanish.','Hago ejercicio todos los días',array[]::text[],'Hago ejercicio todos los días',19),
    (v_lesson_id,'speaking','Say "Smoking is bad for your health" in Spanish.','Fumar es malo para la salud',array[]::text[],'Fumar es malo para la salud',20),
    (v_lesson_id,'fill_blank','Complete: "Tengo que ___ de fumar." (I have to quit smoking.)','dejar',array['parar','salir','quitar'],'to quit',21),
    (v_lesson_id,'fill_blank','Complete: "Es bueno ___ la salud." (good for your health)','para',array['a','en','con'],'for',22);

  -- =================== A2.4 HOBBIES ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Hobbies', 'Talk about what you do in your free time.', 'A2', 4)
  returning id into v_course_id;

  -- Lesson 1: hobby verbs
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Hobbies — Lesson 1', 'Common free-time activities.', 'vocabulary', 1, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "to read"?','leer',array['ver','escribir','correr'],'To read [leh-EHR]',1),
    (v_lesson_id,'multiple_choice','How do you say "to write"?','escribir',array['describir','leer','dibujar'],'To write [ehs-kree-BEER]',2),
    (v_lesson_id,'multiple_choice','How do you say "to listen to music"?','escuchar música',array['oír música','ver música','tocar música'],'To listen to music [ehs-koo-CHAR]',3),
    (v_lesson_id,'multiple_choice','How do you say "to watch movies"?','ver películas',array['mirar películas también','ir al cine','filme'],'To watch movies [pe-LEE-koo-lahs]',4),
    (v_lesson_id,'multiple_choice','How do you say "to play (a sport)"?','jugar',array['tocar','hacer','poner'],'To play (sport) [hoo-GAR]',5),
    (v_lesson_id,'multiple_choice','How do you say "to play (an instrument)"?','tocar',array['jugar','hacer','sonar'],'To play (instrument) [toh-KAHR]',6),
    (v_lesson_id,'multiple_choice','How do you say "to swim"?','nadar',array['nadie','nado','natación'],'To swim [nah-DAHR]',7),
    (v_lesson_id,'multiple_choice','How do you say "to run"?','correr',array['caminar','andar','currar'],'To run [koh-RREHR]',8),
    (v_lesson_id,'multiple_choice','How do you say "to dance"?','bailar',array['cantar','beber','bañar'],'To dance [bay-LAHR]',9),
    (v_lesson_id,'multiple_choice','How do you say "to cook"?','cocinar',array['comer','cobrar','cocina'],'To cook [koh-see-NAHR]',10),
    (v_lesson_id,'multiple_choice','How do you say "to paint"?','pintar',array['dibujar','pisar','poner'],'To paint [peen-TAHR]',11),
    (v_lesson_id,'multiple_choice','How do you say "to draw"?','dibujar',array['pintar','escribir','describir'],'To draw [dee-boo-HAR]',12),
    (v_lesson_id,'multiple_choice','How do you say "photography"?','la fotografía',array['las fotos','el foto','la fotografía digital'],'Photography [foh-toh-grah-FEE-ah]',13),
    (v_lesson_id,'multiple_choice','How do you say "gardening"?','la jardinería',array['el jardín','la jardín','jardinero'],'Gardening [hahr-dee-neh-REE-ah]',14),
    (v_lesson_id,'multiple_choice','How do you say "chess"?','el ajedrez',array['las cartas','el juego','la jota'],'Chess [ah-heh-DREHS]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','me gusta leer',array['me gusta ver','no me gusta leer','quiero leer'],'I like to read',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','escucho música cada día',array['escribo música cada día','escucho música los domingos','no escucho música'],'I listen to music every day',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','juego al fútbol',array['toco fútbol','jugamos fútbol','juego al tenis'],'I play soccer',18),
    (v_lesson_id,'speaking','Say "I like to read" in Spanish.','Me gusta leer',array[]::text[],'Me gusta leer',19),
    (v_lesson_id,'speaking','Say "I play the guitar" in Spanish.','Toco la guitarra',array[]::text[],'Toco la guitarra',20),
    (v_lesson_id,'fill_blank','Complete: "___ al fútbol los sábados." (I play soccer on Saturdays.)','Juego',array['Toco','Hago','Voy'],'I play (sport)',21),
    (v_lesson_id,'fill_blank','Complete: "___ la guitarra." (I play the guitar.)','Toco',array['Juego','Hago','Pongo'],'I play (instrument)',22);

  -- Lesson 2: sports & instruments
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Hobbies — Lesson 2', 'Sports and musical instruments.', 'phrases', 2, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "soccer / football"?','el fútbol',array['el balón','el football','el juego'],'Soccer [FOOT-bohl]',1),
    (v_lesson_id,'multiple_choice','How do you say "basketball"?','el baloncesto',array['el básquet también','el basketball','el balón cesto'],'Basketball (Spain) [bah-lohn-SEHS-toh]',2),
    (v_lesson_id,'multiple_choice','How do you say "tennis"?','el tenis',array['el ping pong','el tenista','la raqueta'],'Tennis [TEH-nees]',3),
    (v_lesson_id,'multiple_choice','How do you say "swimming"?','la natación',array['el nadar','el agua','las olas'],'Swimming [nah-tah-SYOHN]',4),
    (v_lesson_id,'multiple_choice','How do you say "cycling"?','el ciclismo',array['la bici','la bicicleta','el ciclista'],'Cycling [see-KLEES-moh]',5),
    (v_lesson_id,'multiple_choice','How do you say "running"?','correr / el running',array['la carrera','el corredor','el correr'],'Running [koh-RREHR]',6),
    (v_lesson_id,'multiple_choice','How do you say "guitar"?','la guitarra',array['el ukulele','la guitar','la guitarrón'],'Guitar [gee-TAH-rrah]',7),
    (v_lesson_id,'multiple_choice','How do you say "piano"?','el piano',array['el teclado también','la pianola','el piano de cola'],'Piano [PYAH-noh]',8),
    (v_lesson_id,'multiple_choice','How do you say "violin"?','el violín',array['el violón','la vihuela','el cello'],'Violin [byoh-LEEN]',9),
    (v_lesson_id,'multiple_choice','How do you say "drums"?','la batería',array['los tambores también','el bombo','la percusión'],'Drums [bah-teh-REE-ah]',10),
    (v_lesson_id,'multiple_choice','How do you say "I am in a band"?','Estoy en una banda',array['Soy en una banda','Yo banda','Estoy banda'],'I am in a band [BAHN-dah]',11),
    (v_lesson_id,'multiple_choice','How do you say "I play in a team"?','Juego en un equipo',array['Yo equipo juego','Jugamos en equipo','Soy un equipo'],'I play on a team [eh-KEE-poh]',12),
    (v_lesson_id,'multiple_choice','How do you say "the gym"?','el gimnasio',array['el club','el deportivo','la sala'],'Gym [heem-NAH-syoh]',13),
    (v_lesson_id,'multiple_choice','How do you say "the swimming pool"?','la piscina',array['la pileta (LatAm)','el agua','la natación'],'Swimming pool [pee-SEE-nah]',14),
    (v_lesson_id,'multiple_choice','Translate "Toco el piano desde hace cinco años."','I have been playing piano for 5 years',array['I will play piano in 5 years','I played piano','I play piano 5 hours'],'I have been playing piano for 5 years',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','juego al tenis los sábados',array['juego al fútbol los sábados','toco tenis los sábados','jugamos al tenis'],'I play tennis on Saturdays',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','voy al gimnasio',array['voy a la piscina','voy al campo','voy al jardín'],'I go to the gym',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','toco la batería en una banda',array['toco el violín','toco en una banda','toco la guitarra'],'I play drums in a band',18),
    (v_lesson_id,'speaking','Say "I play basketball" in Spanish.','Juego al baloncesto',array[]::text[],'Juego al baloncesto',19),
    (v_lesson_id,'speaking','Say "I go to the gym three times a week" in Spanish.','Voy al gimnasio tres veces a la semana',array[]::text[],'Voy al gimnasio tres veces a la semana',20),
    (v_lesson_id,'fill_blank','Complete: "Juego ___ tenis." (I play tennis.)','al',array['en','a','el'],'(jugar a + sport)',21),
    (v_lesson_id,'fill_blank','Complete: "Toco ___ guitarra." (I play the guitar.)','la',array['al','en','un'],'(tocar + instrument)',22);

  -- Lesson 3: discussing preferences (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Hobbies — Lesson 3', 'Listen for likes, dislikes and preferences.', 'listening', 3, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "I love reading"?','Me encanta leer',array['Yo amo leer','Me gusta mucho leer también','Quiero leer'],'I love reading [ehn-KAHN-tah]',1),
    (v_lesson_id,'multiple_choice','How do you say "I cannot stand boredom"?','No soporto el aburrimiento',array['No me gusta aburrir','Odio aburrirse','No tener aburrido'],'I cannot stand boredom [soh-POHR-toh]',2),
    (v_lesson_id,'multiple_choice','How do you say "I hate cooking"?','Odio cocinar',array['No me cocina','No me gusta cocinar también','Me molesta cocina'],'I hate cooking [OH-dyoh]',3),
    (v_lesson_id,'multiple_choice','How do you say "What do you like to do?"','¿Qué te gusta hacer?',array['¿Qué haces gustas?','¿Cómo gustar?','¿Qué quieres hacer?'],'What do you like to do?',4),
    (v_lesson_id,'multiple_choice','How do you say "Do you like sports?"','¿Te gustan los deportes?',array['¿Te gusta los deportes?','¿Tienes deportes?','¿Eres deporte?'],'Do you like sports?',5),
    (v_lesson_id,'multiple_choice','How do you say "We agree"?','Estamos de acuerdo',array['Somos de acuerdo','Tenemos de acuerdo','Vamos de acuerdo'],'We agree [ah-KWEHR-doh]',6),
    (v_lesson_id,'multiple_choice','How do you say "I disagree"?','No estoy de acuerdo',array['Yo no acuerdo','No de acuerdo','No tengo acuerdo'],'I disagree',7),
    (v_lesson_id,'multiple_choice','How do you say "in my free time"?','en mi tiempo libre',array['mi tiempo libre','de tiempo libre','con tiempo libre'],'In my free time',8),
    (v_lesson_id,'multiple_choice','How do you say "boring"?','aburrido',array['aburrida','aburrir','aburre'],'Boring (m.) [ah-boo-RREE-doh]',9),
    (v_lesson_id,'multiple_choice','How do you say "fun / entertaining"?','divertido',array['divertida','divertir','divierte'],'Fun [dee-behr-TEE-doh]',10),
    (v_lesson_id,'multiple_choice','How do you say "exciting"?','emocionante',array['emoción','emocionado','emotivo'],'Exciting [eh-moh-syoh-NAHN-teh]',11),
    (v_lesson_id,'multiple_choice','How do you say "Do you want to come?"','¿Quieres venir?',array['¿Vienes querer?','¿Cuándo vienes?','¿Vendrás?'],'Do you want to come?',12),
    (v_lesson_id,'multiple_choice','How do you say "Maybe / Perhaps"?','Quizás',array['Tal vez también','Posible','Quitar'],'Maybe [kee-SAHS]',13),
    (v_lesson_id,'multiple_choice','How do you say "I prefer to stay home"?','Prefiero quedarme en casa',array['Prefiero estar casa','Yo preferir casa','Quero quedar en casa'],'I prefer to stay home',14),
    (v_lesson_id,'multiple_choice','Translate "Me gustan tanto el cine como el teatro."','I like the cinema as much as the theater',array['I like cinema but not theater','I prefer the cinema','The theater is better'],'I like cinema as much as theater',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','me encanta bailar',array['me gusta bailar','no me gusta bailar','odio bailar'],'I love dancing',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','en mi tiempo libre leo',array['en mi tiempo libre escribo','en mi tiempo libro leo','en tu tiempo libre lees'],'In my free time I read',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','prefiero quedarme en casa',array['prefiero salir','quiero estar en casa','prefiero quedar en casa'],'I prefer to stay home',18),
    (v_lesson_id,'speaking','Say "I love dancing" in Spanish.','Me encanta bailar',array[]::text[],'Me encanta bailar',19),
    (v_lesson_id,'speaking','Say "I prefer to stay home" in Spanish.','Prefiero quedarme en casa',array[]::text[],'Prefiero quedarme en casa',20),
    (v_lesson_id,'fill_blank','Complete: "Me ___ leer libros." (I love reading books.)','encanta',array['gusta','prefiere','odia'],'love (singular)',21),
    (v_lesson_id,'fill_blank','Complete: "Me ___ las películas de acción." (I love action movies.)','encantan',array['encanta','gusta','prefiere'],'love (plural)',22);

  -- Lesson 4: making plans
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Hobbies — Lesson 4', 'Invite friends and make plans.', 'speaking', 4, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "Do you want to go to the cinema?"','¿Quieres ir al cine?',array['¿Vamos al cine?','¿Cine?','¿Quieres cine?'],'Do you want to go to the cinema?',1),
    (v_lesson_id,'multiple_choice','How do you say "Let us go to the park"?','Vamos al parque',array['Vamonos al parque','Iremos parque','Vayámonos parque'],'Let us go to the park',2),
    (v_lesson_id,'multiple_choice','How do you say "What a great idea!"?','¡Qué buena idea!',array['¡Cómo buena!','¡Idea buena!','¡Buena la idea!'],'What a great idea!',3),
    (v_lesson_id,'multiple_choice','How do you say "I cannot, I am busy"?','No puedo, estoy ocupado',array['No puede ocupado','Estoy ocupar','Soy ocupado'],'I cannot, I am busy',4),
    (v_lesson_id,'multiple_choice','How do you say "When?"','¿Cuándo?',array['¿Cuál?','¿Qué tal?','¿Cómo?'],'When? [KWAHN-doh]',5),
    (v_lesson_id,'multiple_choice','How do you say "Where?"','¿Dónde?',array['¿Adónde?','¿Cuándo?','¿Cuál?'],'Where? [DOHN-deh]',6),
    (v_lesson_id,'multiple_choice','How do you say "See you at 8"?','Nos vemos a las ocho',array['Te veo a las ocho también','Nos vemos a las ocho hora','Veo ti a las ocho'],'See you at 8',7),
    (v_lesson_id,'multiple_choice','How do you say "to meet up with friends"?','quedar con los amigos',array['encontrar amigos','reunirse con amigos también','ir a amigos'],'To meet up with friends [keh-DAHR]',8),
    (v_lesson_id,'multiple_choice','How do you say "to go out"?','salir',array['ir','llegar','dejar'],'To go out [sah-LEER]',9),
    (v_lesson_id,'multiple_choice','How do you say "to stay in"?','quedarse en casa',array['ir a casa','no salir','estar en casa también'],'To stay in [keh-DAHR-seh]',10),
    (v_lesson_id,'multiple_choice','How do you say "I will pick you up"?','Te recojo',array['Yo paso','Yo tomo','Te llevo'],'I will pick you up [reh-KOH-hoh]',11),
    (v_lesson_id,'multiple_choice','How do you say "to invite someone to dinner"?','invitar a alguien a cenar',array['llevar a cenar','dar la cena','poner cena'],'To invite someone to dinner',12),
    (v_lesson_id,'multiple_choice','How do you say "I am free on Friday"?','Estoy libre el viernes',array['Tengo libre el viernes','Soy libre el viernes','Hay libre el viernes'],'I am free on Friday',13),
    (v_lesson_id,'multiple_choice','How do you say "We had a great time"?','Lo pasamos muy bien',array['Tuvimos buen tiempo','Estuvimos muy bien','Hicimos tiempo bien'],'We had a great time [LOH pah-SAH-mohs]',14),
    (v_lesson_id,'multiple_choice','Translate "¿Te apetece tomar un café?"','Do you fancy a coffee? (Spain)',array['Do you want coffee?','Will you take coffee?','Will you serve coffee?'],'Do you fancy a coffee? [ah-peh-TEH-seh]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','¿quieres ir al cine?',array['¿quieres ir a casa?','¿vamos al cine?','¿quieres cine?'],'Do you want to go to the cinema?',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','nos vemos a las ocho',array['nos vemos a las nueve','te veo a las ocho','vemos a las ocho'],'See you at eight',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','lo pasamos muy bien',array['lo pasamos mal','pasamos bien','lo pasamos buena'],'We had a great time',18),
    (v_lesson_id,'speaking','Say "Do you want to go to the cinema?" in Spanish.','¿Quieres ir al cine?',array[]::text[],'¿Quieres ir al cine?',19),
    (v_lesson_id,'speaking','Say "I am free on Saturday" in Spanish.','Estoy libre el sábado',array[]::text[],'Estoy libre el sábado',20),
    (v_lesson_id,'fill_blank','Complete: "¿Quieres ___ al cine?" (Do you want to go to the cinema?)','ir',array['venir','hacer','dar'],'to go',21),
    (v_lesson_id,'fill_blank','Complete: "Nos ___ a las ocho." (See you at 8.)','vemos',array['voy','vamos','venimos'],'we see (each other)',22);

  -- =================== A2.5 WORK ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Work', 'Workplace vocabulary and conversations in Spanish.', 'A2', 5)
  returning id into v_course_id;

  -- Lesson 1: workplace vocab
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Work — Lesson 1', 'Office, colleagues and equipment.', 'vocabulary', 1, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "work / job"?','el trabajo',array['la oficina','la tarea','el empleo también'],'Work [trah-BAH-hoh]',1),
    (v_lesson_id,'multiple_choice','How do you say "office"?','la oficina',array['el despacho también','la sala','el cubículo'],'Office [oh-fee-SEE-nah]',2),
    (v_lesson_id,'multiple_choice','How do you say "boss"?','el jefe',array['el director también','el empleado','el dueño'],'Boss [HEH-feh]',3),
    (v_lesson_id,'multiple_choice','How do you say "employee"?','el empleado',array['el jefe','el trabajador también','el director'],'Employee [ehm-pleh-AH-doh]',4),
    (v_lesson_id,'multiple_choice','How do you say "colleague / coworker"?','el compañero de trabajo',array['el amigo','el socio','el comparado'],'Colleague [kohm-pah-NYEH-roh]',5),
    (v_lesson_id,'multiple_choice','How do you say "meeting"?','la reunión',array['la junta también','la conferencia','la mesa'],'Meeting [reh-OO-nyohn]',6),
    (v_lesson_id,'multiple_choice','How do you say "computer"?','el ordenador',array['la computadora (LatAm)','el ordenado','la ordenamiento'],'Computer (Spain) [ohr-deh-nah-DOHR]',7),
    (v_lesson_id,'multiple_choice','How do you say "to call (phone)"?','llamar',array['llamado','llamando','llamada'],'To call [yah-MAHR]',8),
    (v_lesson_id,'multiple_choice','How do you say "to send an email"?','enviar un correo',array['mandar un correo también','enviar mail','poner un correo'],'To send an email [ehn-BYAR]',9),
    (v_lesson_id,'multiple_choice','How do you say "salary"?','el sueldo',array['el salario también','el pago','el dinero'],'Salary [SWEHL-doh]',10),
    (v_lesson_id,'multiple_choice','How do you say "schedule"?','el horario',array['el calendario','el horizonte','la hora'],'Schedule [oh-RAH-ryoh]',11),
    (v_lesson_id,'multiple_choice','How do you say "profession"?','la profesión',array['la práctica','la persona','la posición'],'Profession [proh-feh-SYOHN]',12),
    (v_lesson_id,'multiple_choice','How do you say "vacation"?','las vacaciones',array['el descanso','el fin','los días libres'],'Vacation [bah-kah-SYOH-nehs]',13),
    (v_lesson_id,'multiple_choice','How do you say "contract"?','el contrato',array['el documento','el acuerdo','el papel'],'Contract [kohn-TRAH-toh]',14),
    (v_lesson_id,'multiple_choice','How do you say "to hire"?','contratar',array['emplear','dar trabajo','tomar'],'To hire [kohn-trah-TAHR]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','tenemos una reunión',array['tenemos un trabajo','tenemos una idea','tengo una reunión'],'We have a meeting',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','mi jefe es muy simpático',array['mi jefe es muy estricto','mi jefa es simpática','mi trabajo es simpático'],'My boss is very nice',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','envío un correo',array['enviaré un correo','envías un correo','envío un coche'],'I send an email',18),
    (v_lesson_id,'speaking','Say "I work in an office" in Spanish.','Trabajo en una oficina',array[]::text[],'Trabajo en una oficina',19),
    (v_lesson_id,'speaking','Say "I have a meeting at three" in Spanish.','Tengo una reunión a las tres',array[]::text[],'Tengo una reunión a las tres',20),
    (v_lesson_id,'fill_blank','Complete: "Trabajo en una ___" (I work in an office.)','oficina',array['tienda','sala','casa'],'office',21),
    (v_lesson_id,'fill_blank','Complete: "Mi ___ se llama Juan." (My boss is named Juan.)','jefe',array['compañero','empleado','amigo'],'boss',22);

  -- Lesson 2: professions & job interviews
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Work — Lesson 2', 'Jobs and interview language.', 'phrases', 2, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "doctor (profession)"?','el médico',array['el doctor también','el medicina','el sanador'],'Doctor [MEH-dee-koh]',1),
    (v_lesson_id,'multiple_choice','How do you say "teacher"?','el profesor',array['el maestro también','el director','el aprendiz'],'Teacher [proh-feh-SOHR]',2),
    (v_lesson_id,'multiple_choice','How do you say "engineer"?','el ingeniero',array['la ingeniería','el técnico','el constructor'],'Engineer [een-heh-NYEH-roh]',3),
    (v_lesson_id,'multiple_choice','How do you say "lawyer"?','el abogado',array['el juez','el cliente','el legal'],'Lawyer [ah-boh-GAH-doh]',4),
    (v_lesson_id,'multiple_choice','How do you say "secretary"?','la secretaria',array['el secreto','la administradora','la asistente'],'Secretary [seh-kreh-TAH-ryah]',5),
    (v_lesson_id,'multiple_choice','How do you say "to work in / as"?','trabajar de',array['trabajar como','trabajar en','trabajar para'],'To work as [trah-bah-HAHR deh]',6),
    (v_lesson_id,'multiple_choice','How do you say "I have an interview"?','Tengo una entrevista',array['Tengo una reunión','Estoy entrevista','Voy entrevista'],'I have an interview [ehn-treh-BEES-tah]',7),
    (v_lesson_id,'multiple_choice','How do you say "to apply for a job"?','solicitar un trabajo',array['pedir trabajo','aplicar trabajo','pedir un puesto también'],'To apply for a job [soh-lee-see-TAHR]',8),
    (v_lesson_id,'multiple_choice','How do you say "CV / résumé"?','el currículum',array['la carta','el papel','el formulario'],'CV [koo-RREE-koo-loom]',9),
    (v_lesson_id,'multiple_choice','How do you say "experience"?','la experiencia',array['la expedición','el experiencia','la experimentación'],'Experience [ehks-peh-RYEHN-syah]',10),
    (v_lesson_id,'multiple_choice','How do you say "skill"?','la habilidad',array['la talentos','el talento también','la fuerza'],'Skill [ah-bee-lee-DAHD]',11),
    (v_lesson_id,'multiple_choice','How do you say "full-time"?','a tiempo completo',array['todo el tiempo','tiempo entero','completo tiempo'],'Full-time',12),
    (v_lesson_id,'multiple_choice','How do you say "part-time"?','a tiempo parcial',array['medio tiempo también','tiempo poco','parte de tiempo'],'Part-time [pahr-SYAHL]',13),
    (v_lesson_id,'multiple_choice','How do you say "I am unemployed"?','Estoy en paro',array['Estoy sin trabajo también','Soy desempleado también','No trabajo'],'I am unemployed (Spain) [PAH-roh]',14),
    (v_lesson_id,'multiple_choice','Translate "Trabajo de ingeniero en una empresa de tecnología."','I work as an engineer at a tech company',array['I am an engineer at home','I will work in technology','I worked at a company'],'I work as an engineer at a tech company',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','soy abogada',array['soy ingeniera','soy abogado','soy abuela'],'I am a lawyer (f.)',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','tengo una entrevista mañana',array['tengo una reunión mañana','tienes una entrevista','tengo entrevista hoy'],'I have an interview tomorrow',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','trabajo a tiempo completo',array['trabajo a tiempo parcial','trabajamos a tiempo completo','trabajo medio tiempo'],'I work full-time',18),
    (v_lesson_id,'speaking','Say "I am a teacher" in Spanish.','Soy profesor',array[]::text[],'Soy profesor',19),
    (v_lesson_id,'speaking','Say "I work full-time" in Spanish.','Trabajo a tiempo completo',array[]::text[],'Trabajo a tiempo completo',20),
    (v_lesson_id,'fill_blank','Complete: "Trabajo ___ médico." (I work as a doctor.)','de',array['como','en','con'],'as',21),
    (v_lesson_id,'fill_blank','Complete: "Tengo ___ años de experiencia." (5 years of experience)','cinco',array['cincuenta','quince','cinco años'],'five',22);

  -- Lesson 3: at the workplace (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Work — Lesson 3', 'Talk on the phone and in meetings.', 'listening', 3, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you answer the phone in Spanish (Spain)?','¿Dígame?',array['¿Hola?','¿Quién?','¿Aló? (LatAm)'],'Hello? (Spain) [DEE-gah-meh]',1),
    (v_lesson_id,'multiple_choice','How do you say "Can I speak to..."','¿Puedo hablar con...?',array['¿Habla con...?','¿Quiero hablar...?','¿Estoy con...?'],'Can I speak to...?',2),
    (v_lesson_id,'multiple_choice','How do you say "He is not available"?','No está disponible',array['No es disponible','No tiene disponible','Está sin disponible'],'He is not available [dees-poh-NEE-bleh]',3),
    (v_lesson_id,'multiple_choice','How do you say "I will call later"?','Llamo más tarde',array['Llamaré más tarde también','Voy a llamar','Llamando luego'],'I will call later',4),
    (v_lesson_id,'multiple_choice','How do you say "Can you take a message?"','¿Puede tomar un mensaje?',array['¿Tiene mensaje?','¿Mensaje?','¿Quieres mensaje?'],'Can you take a message?',5),
    (v_lesson_id,'multiple_choice','How do you say "deadline"?','la fecha límite',array['el plazo también','el final','el día último'],'Deadline [LEE-mee-teh]',6),
    (v_lesson_id,'multiple_choice','How do you say "project"?','el proyecto',array['el plan','la tarea','la idea'],'Project [proh-YEHK-toh]',7),
    (v_lesson_id,'multiple_choice','How do you say "deadline is Monday"?','la fecha límite es el lunes',array['lunes es fecha','el lunes límite','la fecha lunes'],'The deadline is Monday',8),
    (v_lesson_id,'multiple_choice','How do you say "I am behind schedule"?','Voy con retraso',array['Estoy retrasado también','Estoy tarde','Tengo retraso'],'I am behind schedule',9),
    (v_lesson_id,'multiple_choice','How do you say "We need to discuss this"?','Necesitamos hablar de esto',array['Hay que discutir esto','Tenemos hablar esto','Hablamos esto'],'We need to discuss this',10),
    (v_lesson_id,'multiple_choice','How do you say "to take notes"?','tomar notas',array['hacer notas','escribir notas también','poner notas'],'To take notes',11),
    (v_lesson_id,'multiple_choice','How do you say "agenda"?','el orden del día',array['la agenda también','el plan del día','el calendario'],'Agenda',12),
    (v_lesson_id,'multiple_choice','How do you say "to attend a meeting"?','asistir a una reunión',array['ir a una reunión también','estar en reunión','sentarse en reunión'],'To attend a meeting [ah-sees-TEER]',13),
    (v_lesson_id,'multiple_choice','How do you say "What time does the meeting start?"','¿A qué hora empieza la reunión?',array['¿Cuándo es la reunión?','¿Qué hora reunión?','¿La reunión cuándo?'],'What time does the meeting start?',14),
    (v_lesson_id,'multiple_choice','Translate "Tenemos que terminar este proyecto antes del viernes."','We have to finish this project before Friday',array['The project is good for Friday','We will finish on Friday','We started the project Friday'],'We have to finish this project before Friday',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','¿puedo hablar con el jefe?',array['¿hablo con el jefe?','¿puedes hablar con el jefe?','¿llamo al jefe?'],'Can I speak to the boss?',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','la reunión empieza a las diez',array['la reunión empieza a las once','la reunión termina a las diez','las reuniones empiezan a las diez'],'The meeting starts at ten',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','tenemos que terminar el proyecto',array['queremos terminar el proyecto','tenemos terminar el proyecto','terminamos el proyecto'],'We have to finish the project',18),
    (v_lesson_id,'speaking','Say "Can I speak to María, please?" in Spanish.','¿Puedo hablar con María, por favor?',array[]::text[],'¿Puedo hablar con María, por favor?',19),
    (v_lesson_id,'speaking','Say "The meeting starts at three" in Spanish.','La reunión empieza a las tres',array[]::text[],'La reunión empieza a las tres',20),
    (v_lesson_id,'fill_blank','Complete: "Tenemos que ___ el proyecto." (finish the project)','terminar',array['empezar','tomar','llegar'],'to finish',21),
    (v_lesson_id,'fill_blank','Complete: "La reunión empieza ___ las diez." (at ten)','a',array['en','de','para'],'at',22);

  -- Lesson 4: speaking about your job
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Work — Lesson 4', 'Describe your job and routine.', 'speaking', 4, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "I like my job"?','Me gusta mi trabajo',array['Tengo gusto trabajo','Mi trabajo gusta','Soy trabajo'],'I like my job',1),
    (v_lesson_id,'multiple_choice','How do you say "It is stressful"?','Es estresante',array['Está estrés','Tiene estrés también','Hace estrés'],'It is stressful [ehs-treh-SAHN-teh]',2),
    (v_lesson_id,'multiple_choice','How do you say "I work from 9 to 5"?','Trabajo de nueve a cinco',array['Trabajo nueve a cinco','Tengo trabajo 9 a 5','Voy de 9 a 5'],'I work from 9 to 5',3),
    (v_lesson_id,'multiple_choice','How do you say "I am self-employed"?','Soy autónomo',array['Soy independiente también','Trabajo por mí','Soy mi jefe'],'I am self-employed (Spain) [ow-TOH-noh-moh]',4),
    (v_lesson_id,'multiple_choice','How do you say "I work remotely"?','Trabajo a distancia',array['Trabajo lejos','Trabajo desde casa también','Trabajo en remoto'],'I work remotely',5),
    (v_lesson_id,'multiple_choice','How do you say "I love working with people"?','Me encanta trabajar con personas',array['Me gusta personas','Trabajo con gente','Amo personas trabajar'],'I love working with people',6),
    (v_lesson_id,'multiple_choice','How do you say "I am looking for a new job"?','Estoy buscando un nuevo trabajo',array['Busco trabajo nuevo','Tengo nuevo trabajo','Voy a trabajo'],'I am looking for a new job',7),
    (v_lesson_id,'multiple_choice','How do you say "I got a promotion"?','Me ascendieron',array['Me dieron ascenso','Soy ascendido','Tengo ascendido'],'I got promoted [ah-sehn-DYEH-rohn]',8),
    (v_lesson_id,'multiple_choice','How do you say "I just got hired"?','Acabo de ser contratado',array['Soy contratado','Tengo contrato','Me contratan'],'I just got hired [ah-KAH-boh deh]',9),
    (v_lesson_id,'multiple_choice','How do you say "I want a raise"?','Quiero un aumento',array['Quiero más sueldo','Pido aumento','Quiero más'],'I want a raise [ow-MEHN-toh]',10),
    (v_lesson_id,'multiple_choice','How do you say "to retire"?','jubilarse',array['retirarse también','dejar trabajar','salir trabajo'],'To retire [hoo-bee-LAHR-seh]',11),
    (v_lesson_id,'multiple_choice','How do you say "I work for a small company"?','Trabajo para una empresa pequeña',array['Trabajo en una empresa pequeña también','Tengo empresa pequeña','Soy empresa pequeña'],'I work for a small company',12),
    (v_lesson_id,'multiple_choice','How do you say "My job is interesting"?','Mi trabajo es interesante',array['Mi trabajo está interesante','Mi trabajo tiene interés','Trabajo interesa'],'My job is interesting',13),
    (v_lesson_id,'multiple_choice','How do you say "to commute"?','desplazarse al trabajo',array['ir al trabajo también','viajar al trabajo','correr al trabajo'],'To commute',14),
    (v_lesson_id,'multiple_choice','Translate "Trabajo desde casa los lunes y martes."','I work from home on Mondays and Tuesdays',array['I work in the office on Mondays','I will work from home','I worked at home'],'I work from home on Mondays and Tuesdays',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','me encanta mi trabajo',array['me gusta mi trabajo','no me gusta mi trabajo','encanta el trabajo'],'I love my job',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','trabajo de lunes a viernes',array['trabajo los lunes','trabajo de martes a viernes','trabajamos de lunes a viernes'],'I work Monday to Friday',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','estoy buscando un nuevo trabajo',array['busco trabajo','tengo nuevo trabajo','estoy en un trabajo'],'I am looking for a new job',18),
    (v_lesson_id,'speaking','Say "I love my job" in Spanish.','Me encanta mi trabajo',array[]::text[],'Me encanta mi trabajo',19),
    (v_lesson_id,'speaking','Say "I work from 9 to 5" in Spanish.','Trabajo de nueve a cinco',array[]::text[],'Trabajo de nueve a cinco',20),
    (v_lesson_id,'fill_blank','Complete: "Trabajo ___ casa." (from home)','desde',array['de','en','por'],'from',21),
    (v_lesson_id,'fill_blank','Complete: "Estoy ___ un trabajo nuevo." (looking for a new job)','buscando',array['buscar','mirando','encontrando'],'looking for',22);

  -- =================== A2.6 DIRECTIONS ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Directions', 'Ask for and give directions in Spanish.', 'A2', 6)
  returning id into v_course_id;

  -- Lesson 1: direction vocab
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Directions — Lesson 1', 'Left, right, straight ahead.', 'vocabulary', 1, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "to the right"?','a la derecha',array['a la izquierda','recto','arriba'],'To the right [deh-REH-chah]',1),
    (v_lesson_id,'multiple_choice','How do you say "to the left"?','a la izquierda',array['a la derecha','adelante','abajo'],'To the left [ees-KYEHR-dah]',2),
    (v_lesson_id,'multiple_choice','How do you say "straight ahead"?','todo recto',array['todo derecho (LatAm)','adelante','arriba'],'Straight ahead (Spain) [TOH-doh REHK-toh]',3),
    (v_lesson_id,'multiple_choice','How do you say "near"?','cerca',array['lejos','aquí','allí'],'Near [SEHR-kah]',4),
    (v_lesson_id,'multiple_choice','How do you say "far"?','lejos',array['cerca','allí','arriba'],'Far [LEH-hohs]',5),
    (v_lesson_id,'multiple_choice','How do you say "here"?','aquí',array['allí','allá','ahí'],'Here [ah-KEE]',6),
    (v_lesson_id,'multiple_choice','How do you say "there"?','allí',array['aquí','acá','ahí también'],'There [ah-YEE]',7),
    (v_lesson_id,'multiple_choice','How do you say "the corner"?','la esquina',array['el rincón','la curva','el ángulo'],'Corner (street) [ehs-KEE-nah]',8),
    (v_lesson_id,'multiple_choice','How do you say "the street"?','la calle',array['la avenida','el camino','la vía'],'Street [KAH-yeh]',9),
    (v_lesson_id,'multiple_choice','How do you say "the avenue"?','la avenida',array['la calle','el bulevar','el camino'],'Avenue [ah-beh-NEE-dah]',10),
    (v_lesson_id,'multiple_choice','How do you say "the square (plaza)"?','la plaza',array['el parque','la zona','el centro'],'Square [PLAH-sah]',11),
    (v_lesson_id,'multiple_choice','How do you say "the traffic light"?','el semáforo',array['el signo','la luz','el aviso'],'Traffic light [seh-MAH-foh-roh]',12),
    (v_lesson_id,'multiple_choice','How do you say "to cross"?','cruzar',array['pasar','andar','girar'],'To cross [kroo-SAHR]',13),
    (v_lesson_id,'multiple_choice','How do you say "to turn"?','girar',array['volver','doblar también','tornar'],'To turn [hee-RAHR]',14),
    (v_lesson_id,'multiple_choice','How do you say "to follow / continue"?','seguir',array['continuar también','andar','ir'],'To follow [seh-GHEER]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','gire a la derecha',array['gire a la izquierda','siga recto','vaya derecho'],'Turn right',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','está muy lejos',array['está muy cerca','no está lejos','está aquí'],'It is very far',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','en la esquina',array['en la avenida','en la plaza','en la calle'],'On the corner',18),
    (v_lesson_id,'speaking','Say "Turn right" in Spanish.','Gire a la derecha',array[]::text[],'Gire a la derecha',19),
    (v_lesson_id,'speaking','Say "Go straight ahead" in Spanish.','Siga todo recto',array[]::text[],'Siga todo recto',20),
    (v_lesson_id,'fill_blank','Complete: "Gire a la ___" (Turn left.)','izquierda',array['derecha','recta','calle'],'left',21),
    (v_lesson_id,'fill_blank','Complete: "Está muy ___" (It is very near.)','cerca',array['lejos','allí','calle'],'near',22);

  -- Lesson 2: asking for directions
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Directions — Lesson 2', 'Ask politely and understand replies.', 'phrases', 2, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you ask "Excuse me, where is...?"','Disculpe, ¿dónde está...?',array['Perdón, ¿cómo está...?','Por favor, ¿dónde es?','Disculpe, ¿dónde es?'],'Excuse me, where is...?',1),
    (v_lesson_id,'multiple_choice','How do you say "How do I get to...?"','¿Cómo llego a...?',array['¿Cómo voy a...?','¿Dónde voy?','¿Cuál camino?'],'How do I get to...? [YEH-goh]',2),
    (v_lesson_id,'multiple_choice','How do you say "Is it far from here?"','¿Está lejos de aquí?',array['¿Cerca aquí?','¿Está aquí lejos?','¿De aquí lejos?'],'Is it far from here?',3),
    (v_lesson_id,'multiple_choice','How do you say "Is it nearby?"','¿Está cerca?',array['¿Cerca?','¿Está aquí?','¿Cómo cerca?'],'Is it nearby?',4),
    (v_lesson_id,'multiple_choice','How do you say "next to the bank"?','al lado del banco',array['en lado del banco','junto banco también','sobre el banco'],'Next to the bank',5),
    (v_lesson_id,'multiple_choice','How do you say "in front of the church"?','enfrente de la iglesia',array['frente de la iglesia también','en frente la iglesia','adelante iglesia'],'In front of the church [ehn-FREHN-teh]',6),
    (v_lesson_id,'multiple_choice','How do you say "behind the school"?','detrás de la escuela',array['atrás de la escuela','después de la escuela','tras la escuela también'],'Behind the school [deh-TRAHS]',7),
    (v_lesson_id,'multiple_choice','How do you say "between the bank and the park"?','entre el banco y el parque',array['en el banco y parque','dentro banco parque','intermedio banco'],'Between the bank and the park',8),
    (v_lesson_id,'multiple_choice','How do you say "on the second floor"?','en el segundo piso',array['en el dos piso','en piso dos','sobre segundo'],'On the second floor',9),
    (v_lesson_id,'multiple_choice','How do you say "Im lost"?','Estoy perdido',array['Soy perdido','Me perdí también','Yo perdido'],'I am lost [pehr-DEE-doh]',10),
    (v_lesson_id,'multiple_choice','How do you say "Can you repeat that?"','¿Puede repetirlo?',array['¿Repite, por favor?','¿Otra vez?','¿Me dice otra?'],'Can you repeat that?',11),
    (v_lesson_id,'multiple_choice','How do you say "I do not understand"?','No entiendo',array['No comprendo también','No sé','No conozco'],'I do not understand [ehn-TYEHN-doh]',12),
    (v_lesson_id,'multiple_choice','How do you say "Could you speak more slowly?"','¿Puede hablar más despacio?',array['¿Habla despacio?','¿Más lento?','¿Despacio?'],'Could you speak more slowly? [dehs-PAH-syoh]',13),
    (v_lesson_id,'multiple_choice','How do you say "Thank you for your help"?','Gracias por su ayuda',array['Gracias ayuda','Gracias para ayuda','Gracias por ayudar también'],'Thank you for your help',14),
    (v_lesson_id,'multiple_choice','Translate "Está a cinco minutos a pie."','It is five minutes on foot',array['It is five hours away','You can walk for five','Walking is five'],'It is five minutes on foot',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','¿dónde está el banco?',array['¿dónde está el parque?','¿cómo está el banco?','¿está el banco?'],'Where is the bank?',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','está al lado de la iglesia',array['está enfrente de la iglesia','está detrás de la iglesia','está cerca iglesia'],'It is next to the church',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','estoy perdido',array['estoy aquí','estoy listo','estoy lejos'],'I am lost',18),
    (v_lesson_id,'speaking','Say "Excuse me, where is the train station?" in Spanish.','Disculpe, ¿dónde está la estación de tren?',array[]::text[],'Disculpe, ¿dónde está la estación de tren?',19),
    (v_lesson_id,'speaking','Say "I am lost" in Spanish.','Estoy perdido',array[]::text[],'Estoy perdido',20),
    (v_lesson_id,'fill_blank','Complete: "Está al ___ del banco." (next to the bank)','lado',array['frente','detrás','dentro'],'side',21),
    (v_lesson_id,'fill_blank','Complete: "¿Cómo ___ al centro?" (How do I get to the center?)','llego',array['voy','soy','tengo'],'I get',22);

  -- Lesson 3: giving directions (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Directions — Lesson 3', 'Follow directions in conversation.', 'listening', 3, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "Take the first street on the right"?','Tome la primera calle a la derecha',array['Coge primera calle','Sigue por la primera','Va por la calle uno'],'Take the first street on the right',1),
    (v_lesson_id,'multiple_choice','How do you say "Continue for two blocks"?','Continúe dos cuadras',array['Sigue dos calles también','Va dos manzanas','Camina dos'],'Continue for two blocks (LatAm)',2),
    (v_lesson_id,'multiple_choice','How do you say "Walk for five minutes"?','Camine cinco minutos',array['Va cinco minutos','Anda cinco','Va por cinco'],'Walk for five minutes',3),
    (v_lesson_id,'multiple_choice','How do you say "Cross the bridge"?','Cruce el puente',array['Pasa el puente también','Camina puente','Sube puente'],'Cross the bridge [PWEHN-teh]',4),
    (v_lesson_id,'multiple_choice','How do you say "in the city center"?','en el centro de la ciudad',array['al centro ciudad','en el centro ciudad','en la mitad'],'In the city center',5),
    (v_lesson_id,'multiple_choice','How do you say "Look for the sign"?','Busque el cartel',array['Vea el cartel','Mire el cartel también','Encuentre cartel'],'Look for the sign [KAHR-tehl]',6),
    (v_lesson_id,'multiple_choice','How do you say "the map"?','el mapa',array['la mapa','el plano también','el dibujo'],'Map [MAH-pah]',7),
    (v_lesson_id,'multiple_choice','How do you say "GPS"?','el GPS',array['el navegador también','el sistema','el localizador'],'GPS',8),
    (v_lesson_id,'multiple_choice','How do you say "to follow the signs"?','seguir las señales',array['ver las señales','mirar señales','tomar señales'],'To follow the signs [seh-NYAH-lehs]',9),
    (v_lesson_id,'multiple_choice','How do you say "You cannot miss it"?','No tiene pérdida',array['No se pierde','No es difícil','No tiene problema'],'You cannot miss it',10),
    (v_lesson_id,'multiple_choice','How do you say "to drive south"?','conducir hacia el sur',array['ir al sur también','dirigirse sur','sur conducir'],'To drive south [SOOR]',11),
    (v_lesson_id,'multiple_choice','How do you say "north"?','norte',array['sur','este','oeste'],'North [NOHR-teh]',12),
    (v_lesson_id,'multiple_choice','How do you say "east"?','este',array['oeste','norte','sur'],'East [EHS-teh]',13),
    (v_lesson_id,'multiple_choice','How do you say "west"?','oeste',array['este','norte','sur'],'West [OH-ehs-teh]',14),
    (v_lesson_id,'multiple_choice','Translate "Siga recto hasta el semáforo, luego gire a la izquierda."','Go straight until the traffic light, then turn left',array['Turn left at the traffic light','Stop at the traffic light','Continue and turn right'],'Go straight to the traffic light, then turn left',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','tome la primera a la derecha',array['tome la primera a la izquierda','tome la segunda a la derecha','tomar la primera'],'Take the first on the right',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','está en el centro',array['está cerca del centro','está fuera del centro','centro es'],'It is in the center',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','no tiene pérdida',array['no tiene problema','no tiene mapa','no se pierde'],'You cannot miss it',18),
    (v_lesson_id,'speaking','Say "Cross the street and turn left" in Spanish.','Cruce la calle y gire a la izquierda',array[]::text[],'Cruce la calle y gire a la izquierda',19),
    (v_lesson_id,'speaking','Say "It is in the city center" in Spanish.','Está en el centro de la ciudad',array[]::text[],'Está en el centro de la ciudad',20),
    (v_lesson_id,'fill_blank','Complete: "Tome la ___ calle a la derecha." (the first street)','primera',array['segunda','tercera','última'],'first',21),
    (v_lesson_id,'fill_blank','Complete: "Siga ___ recto." (Go straight ahead.)','todo',array['toda','solo','muy'],'all (the way)',22);

  -- Lesson 4: practice giving + asking
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Directions — Lesson 4', 'Speak directions clearly out loud.', 'speaking', 4, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "Could you draw me a map?"','¿Puede dibujarme un mapa?',array['¿Dibujas un mapa?','¿Quiero un mapa?','¿Hay mapa?'],'Could you draw me a map?',1),
    (v_lesson_id,'multiple_choice','How do you say "Is there a bus stop nearby?"','¿Hay una parada de autobús cerca?',array['¿Está parada cerca?','¿Tienes parada?','¿Cerca parada?'],'Is there a bus stop nearby?',2),
    (v_lesson_id,'multiple_choice','How do you say "How long does it take by car?"','¿Cuánto se tarda en coche?',array['¿Cuánto en coche?','¿Qué tarda coche?','¿Cuánto tarde coche?'],'How long does it take by car?',3),
    (v_lesson_id,'multiple_choice','How do you say "I will follow the GPS"?','Voy a seguir el GPS',array['Sigo GPS','Tengo GPS','Voy con GPS'],'I will follow the GPS',4),
    (v_lesson_id,'multiple_choice','How do you say "Can I walk there?"','¿Puedo ir a pie?',array['¿Voy a pie?','¿A pie?','¿Camina?'],'Can I walk there? [ah PYEH]',5),
    (v_lesson_id,'multiple_choice','How do you say "the roundabout"?','la rotonda',array['el círculo','la glorieta también','el redondo'],'Roundabout [roh-TOHN-dah]',6),
    (v_lesson_id,'multiple_choice','How do you say "after the bridge"?','después del puente',array['tras el puente también','luego puente','sobre puente'],'After the bridge',7),
    (v_lesson_id,'multiple_choice','How do you say "the entrance is on the right"?','la entrada está a la derecha',array['está la entrada derecha','entrar a la derecha','la entrada al lado'],'The entrance is on the right',8),
    (v_lesson_id,'multiple_choice','How do you say "the exit is on the left"?','la salida está a la izquierda',array['salir izquierda','la salida izquierda','la salida derecha'],'The exit is on the left',9),
    (v_lesson_id,'multiple_choice','How do you say "ground floor"?','la planta baja',array['el piso bajo','el primer piso','la planta primera'],'Ground floor (Spain)',10),
    (v_lesson_id,'multiple_choice','How do you say "second floor (US 3rd)"?','el segundo piso',array['piso dos','la segunda planta','dos piso'],'Second floor',11),
    (v_lesson_id,'multiple_choice','How do you say "Go around the building"?','Rodee el edificio',array['Vaya alrededor del edificio','Vaya por el edificio','Edificio alrededor'],'Go around the building [roh-DEH-eh]',12),
    (v_lesson_id,'multiple_choice','How do you say "Park here"?','Aparque aquí',array['Estacione aquí (LatAm)','Para aquí','Pone aquí'],'Park here (Spain)',13),
    (v_lesson_id,'multiple_choice','How do you say "Take the elevator"?','Tome el ascensor',array['Coja el elevador (LatAm)','Sube ascensor','Vaya ascensor'],'Take the elevator (Spain) [ah-sehn-SOHR]',14),
    (v_lesson_id,'multiple_choice','Translate "El museo está justo al lado de la estación."','The museum is right next to the station',array['The museum is far from the station','The museum is in the station','You can take the station from the museum'],'The museum is right next to the station',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','está al final de la calle',array['está al inicio de la calle','está en medio de la calle','está al inicio'],'It is at the end of the street',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','puedo ir a pie',array['no puedo ir a pie','voy a pie','quiero ir a pie'],'I can walk there',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','rodee el edificio',array['rodea el edificio','rodean el edificio','la edificio rodee'],'Go around the building',18),
    (v_lesson_id,'speaking','Say "Can I walk there?" in Spanish.','¿Puedo ir a pie?',array[]::text[],'¿Puedo ir a pie?',19),
    (v_lesson_id,'speaking','Say "The entrance is on the right" in Spanish.','La entrada está a la derecha',array[]::text[],'La entrada está a la derecha',20),
    (v_lesson_id,'fill_blank','Complete: "La salida está a la ___" (The exit is on the left.)','izquierda',array['derecha','centro','encima'],'left',21),
    (v_lesson_id,'fill_blank','Complete: "Puedo ir a ___" (I can walk there.)','pie',array['mano','andar','andando'],'foot',22);

  -- =================== A2.7 FEELINGS ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Feelings', 'Express emotions and moods in Spanish.', 'A2', 7)
  returning id into v_course_id;

  -- Lesson 1: basic emotions
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Feelings — Lesson 1', 'Happy, sad, tired, angry.', 'vocabulary', 1, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "happy"?','feliz',array['triste','contento también','alegre también'],'Happy [feh-LEES]',1),
    (v_lesson_id,'multiple_choice','How do you say "sad"?','triste',array['feliz','enfadado','aburrido'],'Sad [TREES-teh]',2),
    (v_lesson_id,'multiple_choice','How do you say "tired"?','cansado',array['descansado','dormido','perezoso'],'Tired [kahn-SAH-doh]',3),
    (v_lesson_id,'multiple_choice','How do you say "angry"?','enfadado',array['enojado (LatAm)','enfermo','triste'],'Angry (Spain) [ehn-fah-DAH-doh]',4),
    (v_lesson_id,'multiple_choice','How do you say "happy / content"?','contento',array['contenido','contagioso','feliz también'],'Content [kohn-TEHN-toh]',5),
    (v_lesson_id,'multiple_choice','How do you say "nervous"?','nervioso',array['nervios','nerve','nervio'],'Nervous [nehr-BYOH-soh]',6),
    (v_lesson_id,'multiple_choice','How do you say "calm / relaxed"?','tranquilo',array['tranquilizado','calmado también','reposado'],'Calm [trahn-KEE-loh]',7),
    (v_lesson_id,'multiple_choice','How do you say "bored"?','aburrido',array['cansado','triste','perezoso'],'Bored [ah-boo-RREE-doh]',8),
    (v_lesson_id,'multiple_choice','How do you say "surprised"?','sorprendido',array['sorpresa','enfadado','alegre'],'Surprised [sohr-prehn-DEE-doh]',9),
    (v_lesson_id,'multiple_choice','How do you say "scared / afraid"?','asustado',array['miedoso','miedo','susto'],'Scared [ah-soos-TAH-doh]',10),
    (v_lesson_id,'multiple_choice','How do you say "worried"?','preocupado',array['ocupado','preocupar','procupado'],'Worried [preh-oh-koo-PAH-doh]',11),
    (v_lesson_id,'multiple_choice','How do you say "in love"?','enamorado',array['amor','enamorar','querido'],'In love [eh-nah-moh-RAH-doh]',12),
    (v_lesson_id,'multiple_choice','How do you say "proud"?','orgulloso',array['orgullo','soberbio','arrogante'],'Proud [ohr-goo-YOH-soh]',13),
    (v_lesson_id,'multiple_choice','How do you say "to feel"?','sentir / sentirse',array['ser','estar','tener'],'To feel [sehn-TEER]',14),
    (v_lesson_id,'multiple_choice','How do you say "embarrassed"?','avergonzado',array['vergüenza','rojo','tímido'],'Embarrassed [ah-behr-gohn-SAH-doh]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','estoy muy feliz',array['estoy muy triste','soy muy feliz','estoy muy cansado'],'I am very happy',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','está enfadado',array['está enfermo','está cansado','está enojado'],'He is angry',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','me siento nervioso',array['me siento nuevo','me siento cansado','me siento tranquilo'],'I feel nervous',18),
    (v_lesson_id,'speaking','Say "I am happy" in Spanish.','Estoy feliz',array[]::text[],'Estoy feliz',19),
    (v_lesson_id,'speaking','Say "I am tired" in Spanish.','Estoy cansado',array[]::text[],'Estoy cansado',20),
    (v_lesson_id,'fill_blank','Complete: "Estoy muy ___" (I am very happy.)','feliz',array['triste','enfadado','cansado'],'happy',21),
    (v_lesson_id,'fill_blank','Complete: "Me ___ triste hoy." (I feel sad today.)','siento',array['soy','estoy','tengo'],'I feel',22);

  -- Lesson 2: ser vs estar with feelings + why
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Feelings — Lesson 2', 'Why someone feels something.', 'phrases', 2, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','Which verb for temporary feelings?','estar',array['ser','tener','hacer'],'estar (states / feelings)',1),
    (v_lesson_id,'multiple_choice','Which is correct: "I am happy today"?','Estoy feliz hoy',array['Soy feliz hoy','Tengo feliz hoy','Hago feliz hoy'],'Use estar for today (temporary)',2),
    (v_lesson_id,'multiple_choice','Which is correct: "She is a happy person"?','Ella es una persona feliz',array['Ella está una persona','Ella tiene una persona','Ella hace una persona'],'Use ser for permanent trait',3),
    (v_lesson_id,'multiple_choice','How do you say "I am hungry" (literal: I have hunger)?','Tengo hambre',array['Estoy hambre','Soy hambre','Hago hambre'],'I am hungry (tener hambre)',4),
    (v_lesson_id,'multiple_choice','How do you say "I am thirsty"?','Tengo sed',array['Estoy sed','Soy sed','Hago sed'],'I am thirsty',5),
    (v_lesson_id,'multiple_choice','How do you say "I am sleepy"?','Tengo sueño',array['Estoy sueño','Soy sueño','Estoy soñando'],'I am sleepy [SWEH-nyoh]',6),
    (v_lesson_id,'multiple_choice','How do you say "I am afraid"?','Tengo miedo',array['Estoy miedo','Soy miedo','Doy miedo'],'I am afraid [MYEH-doh]',7),
    (v_lesson_id,'multiple_choice','How do you say "I am cold (person)"?','Tengo frío',array['Soy frío','Estoy frío','Hace frío (weather)'],'I am cold (person)',8),
    (v_lesson_id,'multiple_choice','How do you say "Why are you sad?" (informal)','¿Por qué estás triste?',array['¿Cómo eres triste?','¿Qué tristes?','¿Cuándo triste?'],'Why are you sad?',9),
    (v_lesson_id,'multiple_choice','How do you say "Because..."','Porque...',array['Por qué','Para que','Por que'],'Because (one word) [POHR-keh]',10),
    (v_lesson_id,'multiple_choice','Translate "Estoy contenta porque tengo vacaciones."','I am happy because I have vacation',array['I want a vacation','My vacation made me happy','My vacation is too short'],'I am happy because I have vacation',11),
    (v_lesson_id,'multiple_choice','How do you say "He makes me happy"?','Me hace feliz',array['Yo le feliz','Le hace feliz','Me da feliz'],'He makes me happy',12),
    (v_lesson_id,'multiple_choice','How do you say "Im in a good mood"?','Estoy de buen humor',array['Soy buen humor','Tengo buen humor','Estoy en humor bueno'],'Im in a good mood [oo-MOHR]',13),
    (v_lesson_id,'multiple_choice','How do you say "Im in a bad mood"?','Estoy de mal humor',array['Soy mal humor','Tengo mal humor','Mi humor está mal'],'Im in a bad mood',14),
    (v_lesson_id,'multiple_choice','Translate "Le tengo cariño."','I am fond of him/her',array['I love him a lot','I worry about him','I want to see him'],'I am fond of him/her [kah-REE-nyoh]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','tengo mucho miedo',array['tengo mucho frío','soy muy miedoso','no tengo miedo'],'I am very afraid',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','estoy de buen humor',array['estoy de mal humor','tengo buen humor','soy de buen humor'],'I am in a good mood',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','me hace feliz',array['me hace triste','le hace feliz','me hace ver'],'It / he makes me happy',18),
    (v_lesson_id,'speaking','Say "I am very happy because I am on vacation" in Spanish.','Estoy muy feliz porque estoy de vacaciones',array[]::text[],'Estoy muy feliz porque estoy de vacaciones',19),
    (v_lesson_id,'speaking','Say "I am sleepy" in Spanish.','Tengo sueño',array[]::text[],'Tengo sueño',20),
    (v_lesson_id,'fill_blank','Complete: "Estoy triste ___ está lloviendo." (because it is raining)','porque',array['por qué','para que','por'],'because',21),
    (v_lesson_id,'fill_blank','Complete: "___ mucho sueño." (I am very sleepy.)','Tengo',array['Soy','Estoy','Hago'],'I have',22);

  -- Lesson 3: physical reactions
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Feelings — Lesson 3', 'Listen for emotional reactions.', 'listening', 3, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "to cry"?','llorar',array['reír','sonreír','suspirar'],'To cry [yoh-RAHR]',1),
    (v_lesson_id,'multiple_choice','How do you say "to laugh"?','reír',array['llorar','sonreír','reírse también'],'To laugh [reh-EER]',2),
    (v_lesson_id,'multiple_choice','How do you say "to smile"?','sonreír',array['reír','sonrisa','sentir'],'To smile [sohn-reh-EER]',3),
    (v_lesson_id,'multiple_choice','How do you say "to sigh"?','suspirar',array['susurrar','sufrir','sumar'],'To sigh [soos-pee-RAHR]',4),
    (v_lesson_id,'multiple_choice','How do you say "to be moved (emotional)"?','emocionarse',array['emoción','emocional','emocionar'],'To be moved [eh-moh-syoh-NAHR-seh]',5),
    (v_lesson_id,'multiple_choice','How do you say "to get angry"?','enfadarse',array['enfadar','enojarse (LatAm)','molestarse'],'To get angry (Spain) [ehn-fah-DAHR-seh]',6),
    (v_lesson_id,'multiple_choice','How do you say "I am very excited"?','Estoy muy emocionado',array['Soy emocionado','Tengo emoción','Estoy muy emoción'],'I am very excited',7),
    (v_lesson_id,'multiple_choice','How do you say "I am disappointed"?','Estoy decepcionado',array['Soy decepcionado','Tengo decepción','Hago decepción'],'I am disappointed [deh-sehp-syoh-NAH-doh]',8),
    (v_lesson_id,'multiple_choice','How do you say "I miss you"?','Te echo de menos',array['Yo extraño (LatAm)','Te necesito','Te quiero'],'I miss you (Spain) [EH-choh deh MEH-nohs]',9),
    (v_lesson_id,'multiple_choice','How do you say "Cheer up!"?','¡Ánimo!',array['¡Vamos!','¡Suerte!','¡Vamos arriba!'],'Cheer up! [AH-nee-moh]',10),
    (v_lesson_id,'multiple_choice','How do you say "Dont worry"?','No te preocupes',array['No preocupes','No te preocupar','No tengas preocupado'],'Dont worry [preh-oh-KOO-pehs]',11),
    (v_lesson_id,'multiple_choice','How do you say "Im calm"?','Estoy tranquilo',array['Soy tranquilo también','Tengo tranquilo','Hago tranquilo'],'Im calm',12),
    (v_lesson_id,'multiple_choice','How do you say "Are you OK?"','¿Estás bien?',array['¿Eres bien?','¿Tienes bien?','¿Vas bien?'],'Are you OK?',13),
    (v_lesson_id,'multiple_choice','How do you say "Im fine, thanks"?','Estoy bien, gracias',array['Soy bien, gracias','Yo bien','Bien estoy gracias'],'Im fine, thanks',14),
    (v_lesson_id,'multiple_choice','Translate "Mi padre se emocionó mucho con la noticia."','My father was very moved by the news',array['My father told the news','My father gave the news','My father did not believe the news'],'My father was very moved by the news',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','te echo de menos',array['no te echo','te echo','te echamos de menos'],'I miss you',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','¡ánimo!',array['¡vamos!','¡adelante!','¡bien!'],'Cheer up!',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','no te preocupes',array['no te ocupes','sin preocupar','no preocupes'],'Dont worry',18),
    (v_lesson_id,'speaking','Say "I miss you" in Spanish.','Te echo de menos',array[]::text[],'Te echo de menos',19),
    (v_lesson_id,'speaking','Say "Dont worry" in Spanish.','No te preocupes',array[]::text[],'No te preocupes',20),
    (v_lesson_id,'fill_blank','Complete: "Te ___ de menos." (I miss you.)','echo',array['hago','tengo','soy'],'I throw / miss',21),
    (v_lesson_id,'fill_blank','Complete: "No te ___" (Dont worry.)','preocupes',array['preocupas','preocupar','ocupes'],'worry (imperative)',22);

  -- Lesson 4: speaking about emotions
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Feelings — Lesson 4', 'Talk openly about how you feel.', 'speaking', 4, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "I love you"?','Te quiero',array['Te amo (stronger / LatAm)','Yo amor','Me gustas'],'I love you (warm / casual)',1),
    (v_lesson_id,'multiple_choice','How do you say "I love you (deeply)"?','Te amo',array['Te quiero (everyday)','Yo amor','Tengo amor'],'I love you (deep) [ah-MOH]',2),
    (v_lesson_id,'multiple_choice','How do you say "I am scared of dogs"?','Tengo miedo a los perros',array['Soy miedo perros','Estoy miedo perros','Yo perros miedo'],'I am scared of dogs',3),
    (v_lesson_id,'multiple_choice','How do you say "It bothers me"?','Me molesta',array['Yo molesto','Me hace molesto','Tengo molesto'],'It bothers me [moh-LEHS-tah]',4),
    (v_lesson_id,'multiple_choice','How do you say "It makes me laugh"?','Me hace reír',array['Me hace risa','Yo me río','Yo le risa'],'It makes me laugh',5),
    (v_lesson_id,'multiple_choice','How do you say "Im exhausted"?','Estoy agotado',array['Soy agotado','Tengo agotado','Hago agotado'],'I am exhausted [ah-goh-TAH-doh]',6),
    (v_lesson_id,'multiple_choice','How do you say "Im stressed"?','Estoy estresado',array['Soy estresado','Tengo estrés también','Hago estrés'],'Im stressed',7),
    (v_lesson_id,'multiple_choice','How do you say "Im in love with..."','Estoy enamorado de...',array['Soy enamorado','Tengo amor','Voy a enamorar'],'Im in love with...',8),
    (v_lesson_id,'multiple_choice','How do you say "I feel grateful"?','Me siento agradecido',array['Yo agradecer','Soy agradecido','Tengo gracias'],'I feel grateful [ah-grah-deh-SEE-doh]',9),
    (v_lesson_id,'multiple_choice','How do you say "It is annoying"?','Es molesto',array['Es molestar','Hace molesto','Tiene molesto'],'It is annoying',10),
    (v_lesson_id,'multiple_choice','How do you say "It is fun"?','Es divertido',array['Hace diversión','Está divertido también','Es diversión'],'It is fun',11),
    (v_lesson_id,'multiple_choice','How do you say "How exciting!"?','¡Qué emocionante!',array['¡Cómo emoción!','¡Es emoción!','¡Muy emoción!'],'How exciting!',12),
    (v_lesson_id,'multiple_choice','How do you say "What a shame!"?','¡Qué pena!',array['¡Qué lástima también!','¡Qué dolor!','¡Qué malo!'],'What a shame!',13),
    (v_lesson_id,'multiple_choice','How do you say "Im sorry to hear that"?','Lo siento mucho',array['Sentido mucho','Yo siento eso','Tengo siento'],'Im sorry to hear that',14),
    (v_lesson_id,'multiple_choice','Translate "Cuando estoy nervioso, no puedo dormir."','When I am nervous, I cannot sleep',array['I sleep when nervous','I dream when nervous','I am tired when nervous'],'When I am nervous, I cannot sleep',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','estoy agotado',array['estoy enfadado','estoy aburrido','estoy ocupado'],'I am exhausted',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','me hace reír',array['me hace llorar','me hace ver','le hace reír'],'It makes me laugh',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','lo siento mucho',array['lo siento','siento mucho','tengo mucho'],'I am very sorry',18),
    (v_lesson_id,'speaking','Say "I love you" (warm) in Spanish.','Te quiero',array[]::text[],'Te quiero',19),
    (v_lesson_id,'speaking','Say "It makes me happy" in Spanish.','Me hace feliz',array[]::text[],'Me hace feliz',20),
    (v_lesson_id,'fill_blank','Complete: "Estoy ___ de Ana." (I am in love with Ana.)','enamorado',array['enamorada','amor','enamorar'],'in love (m.)',21),
    (v_lesson_id,'fill_blank','Complete: "Me ___ reír esa película." (That movie makes me laugh.)','hace',array['hago','haga','hizo'],'makes',22);

  -- =================== A2.8 CELEBRATIONS ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Celebrations', 'Birthdays, holidays and parties in Spanish.', 'A2', 8)
  returning id into v_course_id;

  -- Lesson 1: birthday + party basics
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Celebrations — Lesson 1', 'Birthdays and gifts.', 'vocabulary', 1, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "birthday"?','el cumpleaños',array['el aniversario','el día especial','la fiesta'],'Birthday [koom-pleh-AH-nyohs]',1),
    (v_lesson_id,'multiple_choice','How do you say "party"?','la fiesta',array['la celebración también','el evento','la diversión'],'Party [FYEHS-tah]',2),
    (v_lesson_id,'multiple_choice','How do you say "gift / present"?','el regalo',array['la sorpresa','el premio','el deseo'],'Gift [reh-GAH-loh]',3),
    (v_lesson_id,'multiple_choice','How do you say "cake"?','la tarta',array['el pastel (LatAm)','el bizcocho también','la torta también'],'Cake (Spain) [TAR-tah]',4),
    (v_lesson_id,'multiple_choice','How do you say "candle"?','la vela',array['la luz','el fuego','la lámpara'],'Candle [BEH-lah]',5),
    (v_lesson_id,'multiple_choice','How do you say "balloon"?','el globo',array['el balón','la pelota','el bulto'],'Balloon [GLOH-boh]',6),
    (v_lesson_id,'multiple_choice','How do you say "Happy birthday!"?','¡Feliz cumpleaños!',array['¡Feliz día!','¡Cumple feliz!','¡Mucha suerte!'],'Happy birthday!',7),
    (v_lesson_id,'multiple_choice','How do you say "Congratulations!"?','¡Felicidades!',array['¡Felicitaciones también!','¡Saludos!','¡Bienvenidos!'],'Congratulations! [feh-lee-see-DAH-dehs]',8),
    (v_lesson_id,'multiple_choice','How do you say "anniversary"?','el aniversario',array['el cumpleaños','la celebración','el día'],'Anniversary [ah-nee-behr-SAH-ryoh]',9),
    (v_lesson_id,'multiple_choice','How do you say "to celebrate"?','celebrar',array['festejar también','festejar','recordar'],'To celebrate [seh-leh-BRAHR]',10),
    (v_lesson_id,'multiple_choice','How do you say "to invite"?','invitar',array['llamar','convocar','llevar'],'To invite [een-bee-TAHR]',11),
    (v_lesson_id,'multiple_choice','How do you say "the invitation"?','la invitación',array['la llamada','el aviso','la nota'],'Invitation [een-bee-tah-SYOHN]',12),
    (v_lesson_id,'multiple_choice','How do you say "to give a gift"?','dar un regalo',array['regalar también','poner un regalo','hacer regalo'],'To give a gift',13),
    (v_lesson_id,'multiple_choice','How do you say "to blow out the candles"?','soplar las velas',array['apagar las velas también','soplar candles','soplar las velas grandes'],'To blow out the candles [soh-PLAHR]',14),
    (v_lesson_id,'multiple_choice','How do you say "to sing happy birthday"?','cantar cumpleaños feliz',array['decir feliz cumple','tocar canción','cantar feliz'],'To sing happy birthday',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','feliz cumpleaños',array['felicitaciones','feliz aniversario','feliz fiesta'],'Happy birthday',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','te traje un regalo',array['traje un regalo','tengo un regalo','te doy un regalo'],'I brought you a gift',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','vamos a celebrar',array['vamos celebrar','vamos a la fiesta','vamos al cumple'],'Lets celebrate',18),
    (v_lesson_id,'speaking','Say "Happy birthday!" in Spanish.','¡Feliz cumpleaños!',array[]::text[],'¡Feliz cumpleaños!',19),
    (v_lesson_id,'speaking','Say "Thanks for the gift" in Spanish.','Gracias por el regalo',array[]::text[],'Gracias por el regalo',20),
    (v_lesson_id,'fill_blank','Complete: "¡Feliz ___" (Happy birthday!)','cumpleaños',array['aniversario','día','fiesta'],'birthday',21),
    (v_lesson_id,'fill_blank','Complete: "Te traje un ___" (I brought you a gift.)','regalo',array['globo','tarta','vela'],'gift',22);

  -- Lesson 2: holidays
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Celebrations — Lesson 2', 'Christmas, New Year and other holidays.', 'phrases', 2, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "Christmas"?','la Navidad',array['Las Pascuas','Reyes','Nochebuena'],'Christmas [nah-bee-DAHD]',1),
    (v_lesson_id,'multiple_choice','How do you say "Christmas Eve"?','la Nochebuena',array['la Navidad','Nochevieja','la noche'],'Christmas Eve [noh-cheh-BWEH-nah]',2),
    (v_lesson_id,'multiple_choice','How do you say "New Year"?','el Año Nuevo',array['Nuevo año','El año primero','El año nuevo'],'New Year [AH-nyoh NWEH-boh]',3),
    (v_lesson_id,'multiple_choice','How do you say "New Years Eve" (Spain)?','la Nochevieja',array['Año Viejo','la Nochebuena','la noche'],'NYE (Spain) [noh-cheh-BYEH-hah]',4),
    (v_lesson_id,'multiple_choice','How do you say "Three Kings Day"?','el Día de Reyes',array['el día tres','el Día del Rey','el rey'],'Three Kings Day [REH-yehs]',5),
    (v_lesson_id,'multiple_choice','How do you say "Easter"?','la Pascua',array['la Pasarela','las Pascuas también','Semana Santa también'],'Easter [PAHS-kwah]',6),
    (v_lesson_id,'multiple_choice','How do you say "Holy Week"?','la Semana Santa',array['Semana de iglesia','Semana de Cristo','Semana de oración'],'Holy Week [seh-MAH-nah SAHN-tah]',7),
    (v_lesson_id,'multiple_choice','How do you say "Day of the Dead" (Mexico)?','el Día de los Muertos',array['el Día de los Santos','el Día de los Difuntos','el Día sin Vida'],'Day of the Dead [MWEHR-tohs]',8),
    (v_lesson_id,'multiple_choice','How do you say "Valentines Day"?','el Día de San Valentín',array['el Día de los enamorados también','el Día del amor','el San Valentín'],'Valentines Day',9),
    (v_lesson_id,'multiple_choice','How do you say "Mothers Day"?','el Día de la Madre',array['el Día Madre','Madres','el día materno'],'Mothers Day',10),
    (v_lesson_id,'multiple_choice','How do you say "Fathers Day"?','el Día del Padre',array['el Día Padre','el día paternal','el día papá'],'Fathers Day',11),
    (v_lesson_id,'multiple_choice','How do you say "to toast / cheer"?','brindar',array['brincar','brindis','beber'],'To toast [breen-DAHR]',12),
    (v_lesson_id,'multiple_choice','How do you say "fireworks"?','los fuegos artificiales',array['el fuego','las explosiones','la pirotecnia también'],'Fireworks [fweh-gohs ahr-tee-fee-SYAH-lehs]',13),
    (v_lesson_id,'multiple_choice','How do you say "Christmas tree"?','el árbol de Navidad',array['el árbol Navidad','el pino Navidad','el árbol navideño también'],'Christmas tree',14),
    (v_lesson_id,'multiple_choice','How do you say "Merry Christmas!"?','¡Feliz Navidad!',array['¡Feliz Año!','¡Feliz Pascua!','¡Felicidades Navidad!'],'Merry Christmas!',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','feliz navidad',array['feliz año','feliz cumpleaños','feliz día'],'Merry Christmas',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','vamos a celebrar el año nuevo',array['vamos a la fiesta','vamos al cumple','celebraremos navidad'],'Lets celebrate New Year',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','la semana santa es en abril',array['la navidad es en abril','la semana es en abril','semana santa en mayo'],'Holy Week is in April',18),
    (v_lesson_id,'speaking','Say "Merry Christmas!" in Spanish.','¡Feliz Navidad!',array[]::text[],'¡Feliz Navidad!',19),
    (v_lesson_id,'speaking','Say "Happy New Year!" in Spanish.','¡Feliz Año Nuevo!',array[]::text[],'¡Feliz Año Nuevo!',20),
    (v_lesson_id,'fill_blank','Complete: "¡Feliz ___ Nuevo!" (Happy New Year!)','Año',array['Día','Mes','Fin'],'Year',21),
    (v_lesson_id,'fill_blank','Complete: "El árbol de ___" (Christmas tree)','Navidad',array['Pascua','año','reyes'],'Christmas',22);

  -- Lesson 3: weddings + life events (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Celebrations — Lesson 3', 'Weddings, baby showers and life events.', 'listening', 3, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "wedding"?','la boda',array['el matrimonio también','la celebración','el novio'],'Wedding [BOH-dah]',1),
    (v_lesson_id,'multiple_choice','How do you say "groom / boyfriend"?','el novio',array['el marido','el esposo','el casado'],'Groom [NOH-byoh]',2),
    (v_lesson_id,'multiple_choice','How do you say "bride / girlfriend"?','la novia',array['la mujer','la esposa','la casada'],'Bride [NOH-byah]',3),
    (v_lesson_id,'multiple_choice','How do you say "to get married"?','casarse',array['casar','matrimoniar','enamorarse'],'To get married [kah-SAHR-seh]',4),
    (v_lesson_id,'multiple_choice','How do you say "honeymoon"?','la luna de miel',array['el viaje de boda','la miel','el viaje romántico'],'Honeymoon [LOO-nah deh MYEHL]',5),
    (v_lesson_id,'multiple_choice','How do you say "ring"?','el anillo',array['la cadena','el aro','el oro'],'Ring [ah-NEE-yoh]',6),
    (v_lesson_id,'multiple_choice','How do you say "baby shower"?','la baby shower / fiesta del bebé',array['la fiesta del nacimiento','la fiesta del agua','la noche del bebé'],'Baby shower',7),
    (v_lesson_id,'multiple_choice','How do you say "to graduate"?','graduarse',array['terminar la escuela','salir de la universidad','graduar'],'To graduate [grah-doo-AHR-seh]',8),
    (v_lesson_id,'multiple_choice','How do you say "the graduation"?','la graduación',array['la escuela final','el fin de estudio','la titulación'],'Graduation',9),
    (v_lesson_id,'multiple_choice','How do you say "to retire"?','jubilarse',array['retirarse','dejar trabajo','irse'],'To retire [hoo-bee-LAHR-seh]',10),
    (v_lesson_id,'multiple_choice','How do you say "funeral"?','el funeral',array['el entierro también','la muerte','el adiós'],'Funeral [foo-neh-RAHL]',11),
    (v_lesson_id,'multiple_choice','How do you say "to be born"?','nacer',array['salir','venir','crear'],'To be born [nah-SEHR]',12),
    (v_lesson_id,'multiple_choice','How do you say "the baptism"?','el bautismo',array['la confirmación','la iglesia','el rito'],'Baptism [bow-TEES-moh]',13),
    (v_lesson_id,'multiple_choice','How do you say "congratulations on your wedding"?','felicidades por tu boda',array['felicidades casado','felicidades novia','felicidades del matrimonio'],'Congratulations on your wedding',14),
    (v_lesson_id,'multiple_choice','Translate "Nos casamos el próximo verano."','We are getting married next summer',array['We will marry today','We got married','We are dating this summer'],'We are getting married next summer',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','vamos a casarnos',array['vamos a comer','vamos a la fiesta','nos casamos'],'We are getting married',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','su luna de miel es en italia',array['su viaje es en italia','están en italia','la boda en italia'],'Their honeymoon is in Italy',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','me gradué el año pasado',array['me gradué este año','me gradúo el año pasado','me graduaré'],'I graduated last year',18),
    (v_lesson_id,'speaking','Say "We are getting married next year" in Spanish.','Nos casamos el próximo año',array[]::text[],'Nos casamos el próximo año',19),
    (v_lesson_id,'speaking','Say "Congratulations on your graduation" in Spanish.','Felicidades por tu graduación',array[]::text[],'Felicidades por tu graduación',20),
    (v_lesson_id,'fill_blank','Complete: "Nos ___ el próximo año." (We are getting married next year.)','casamos',array['casa','casan','casaremos'],'we get married',21),
    (v_lesson_id,'fill_blank','Complete: "Felicidades ___ tu boda." (for your wedding)','por',array['para','de','con'],'for',22);

  -- Lesson 4: toasting and celebrating
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Celebrations — Lesson 4', 'Toasts, wishes and good vibes out loud.', 'speaking', 4, 15)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "Cheers!" with a drink?','¡Salud!',array['¡Brindar!','¡Felicidades!','¡Suerte!'],'Cheers! [sah-LOOD]',1),
    (v_lesson_id,'multiple_choice','How do you say "Lets toast!"?','¡Vamos a brindar!',array['¡Brindamos!','¡Brindis!','¡Vamos a salud!'],'Lets toast!',2),
    (v_lesson_id,'multiple_choice','How do you say "I wish you happiness"?','Te deseo felicidad',array['Yo deseo feliz','Te quiero feliz','Yo te feliz'],'I wish you happiness [deh-SEH-oh]',3),
    (v_lesson_id,'multiple_choice','How do you say "Best wishes"?','Mis mejores deseos',array['Mis deseos buenos','Buenos deseos','Deseos mejores'],'Best wishes',4),
    (v_lesson_id,'multiple_choice','How do you say "Hope you enjoy"?','Espero que disfrutes',array['Espero disfrutas','Quiero disfrutas','Te espero'],'Hope you enjoy [dees-FROO-tehs]',5),
    (v_lesson_id,'multiple_choice','How do you say "Many happy returns"?','Que cumplas muchos más',array['Cumple más','Muchos cumpleaños','Felicidades muchos'],'Many happy returns [KOOM-plahs]',6),
    (v_lesson_id,'multiple_choice','How do you say "Good luck"?','Buena suerte',array['Mucha suerte también','Suerte','Suerte buena'],'Good luck [SWEHR-teh]',7),
    (v_lesson_id,'multiple_choice','How do you say "Welcome to the party"?','Bienvenido a la fiesta',array['Bienvenido fiesta','Bienvenida fiesta','Bienvenidos a fiesta'],'Welcome to the party (m.)',8),
    (v_lesson_id,'multiple_choice','How do you say "Have a great time"?','Que lo pases muy bien',array['Pásalo bien','Pasarás bien','Tener buen tiempo'],'Have a great time',9),
    (v_lesson_id,'multiple_choice','How do you say "the host"?','el anfitrión',array['el dueño','el invitador','el organizador'],'Host [ahn-fee-TRYOHN]',10),
    (v_lesson_id,'multiple_choice','How do you say "the guest"?','el invitado',array['el visitante','el huésped también','el amigo'],'Guest [een-bee-TAH-doh]',11),
    (v_lesson_id,'multiple_choice','How do you say "cake with strawberries"?','tarta con fresas',array['tarta de manzana','tarta y fresas','torta con frutas'],'Cake with strawberries',12),
    (v_lesson_id,'multiple_choice','How do you say "Let me give you a hug"?','Déjame darte un abrazo',array['Te doy un abrazo','Yo abrazo','Abrázame'],'Let me give you a hug [ah-BRAH-soh]',13),
    (v_lesson_id,'multiple_choice','How do you say "Smile for the photo!"?','¡Sonríe para la foto!',array['¡Sonríes foto!','¡Mira foto!','¡Sonríe foto!'],'Smile for the photo!',14),
    (v_lesson_id,'multiple_choice','Translate "Brindemos por los novios."','Lets toast the newlyweds',array['Lets give them a gift','Lets dance for them','Lets congratulate them'],'Lets toast the newlyweds',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','¡salud!',array['¡vamos!','¡adelante!','¡brindis!'],'Cheers!',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','te deseo lo mejor',array['te quiero','te deseo bien','deseo lo mejor'],'I wish you the best',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','que lo pases bien',array['lo paso bien','pásalo bien','que pase bien'],'Have a good time',18),
    (v_lesson_id,'speaking','Say "Cheers!" in Spanish.','¡Salud!',array[]::text[],'¡Salud!',19),
    (v_lesson_id,'speaking','Say "I wish you happiness" in Spanish.','Te deseo felicidad',array[]::text[],'Te deseo felicidad',20),
    (v_lesson_id,'fill_blank','Complete: "Que ___ muchos más." (Many happy returns.)','cumplas',array['cumple','cumplir','cumplo'],'you turn (subjunctive)',21),
    (v_lesson_id,'fill_blank','Complete: "Te ___ felicidad." (I wish you happiness.)','deseo',array['quiero','tengo','soy'],'I wish',22);

end $$;

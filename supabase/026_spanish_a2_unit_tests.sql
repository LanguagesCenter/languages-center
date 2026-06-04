-- 026_spanish_a2_unit_tests.sql
-- Mirrors 019 (A1). Adds a Section Test (unit_test) at order_index = 9 for
-- every Spanish A2 section. Each test has 10 exercises (multiple_choice,
-- fill_blank, listening, speaking) that review the whole section.
-- Pass threshold (≥ 7 of 10) and XP (50) match A1.
-- Idempotent: drops any existing order_index = 9 lesson per A2 course first.

do $$
declare
  v_lang_id    bigint;
  v_course_id  bigint;
  v_lesson_id  bigint;
  v_section    text;
begin
  select id into v_lang_id from public.languages where code = 'spanish';

  for v_section in
    select title from public.courses
    where language_id = v_lang_id and cefr_level = 'A2'
    order by order_index
  loop
    select id into v_course_id from public.courses
      where language_id = v_lang_id and cefr_level = 'A2' and title = v_section;

    delete from public.lessons where course_id = v_course_id and order_index = 9;

    insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
    values (
      v_course_id,
      'Section Test: ' || v_section,
      'Review test for the whole ' || v_section || ' section. Pass with 7 or more out of 10 to earn 50 XP.',
      'unit_test',
      9,
      50
    )
    returning id into v_lesson_id;

    if v_section = 'Daily Routines' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "to wake up"?','despertarse',array['levantarse','acostarse','ducharse'],'to wake up',1),
        (v_lesson_id,'multiple_choice','What does "Me ducho cada mañana" mean?','I shower every morning',array['I wake up every morning','I sleep every morning','I run every morning'],'I shower every morning',2),
        (v_lesson_id,'multiple_choice','Which is reflexive?','Me levanto',array['Levantar','Levanto','Levante'],'I get up',3),
        (v_lesson_id,'multiple_choice','What does "por la mañana" mean?','in the morning',array['in the afternoon','at night','tomorrow'],'in the morning',4),
        (v_lesson_id,'fill_blank','Complete: "___ acuesto a las once." (I)','Me',array['Te','Se','Nos'],'I',5),
        (v_lesson_id,'fill_blank','Complete: "___ vistes rápido." (you)','Te',array['Me','Se','Os'],'you',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Me despierto a las seis',array['I get up at six','I wake up at six','I shower at six'],'I wake up at six',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Normalmente desayuno tostadas',array['I usually have toast for breakfast','I rarely eat toast','I never have breakfast'],'I usually have toast for breakfast',8),
        (v_lesson_id,'speaking','Say this aloud: "Me acuesto a las once." [meh ah-KWEHS-toh ah lahs OHN-seh]','Me acuesto a las once',array[]::text[],'I go to bed at eleven.',9),
        (v_lesson_id,'speaking','Say this aloud: "Trabajo todos los días." [trah-BAH-hoh TOH-dohs lohs DEE-ahs]','Trabajo todos los días',array[]::text[],'I work every day.',10);

    elsif v_section = 'Health & Body' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "the fever"?','la fiebre',array['la gripe','la tos','el dolor'],'the fever',1),
        (v_lesson_id,'multiple_choice','What does "Me duele la cabeza" mean?','My head hurts',array['I have a fever','My head is fine','I feel happy'],'My head hurts',2),
        (v_lesson_id,'multiple_choice','How do you say "I am sick"?','Estoy enfermo',array['Soy enfermo','Tengo enfermo','Estoy enfermedad'],'I am sick',3),
        (v_lesson_id,'multiple_choice','Which uses DOLER plural?','Me duelen los pies',array['Me duele los pies','Me duelo los pies','Me dueles los pies'],'My feet hurt',4),
        (v_lesson_id,'fill_blank','Complete: "Me ___ la garganta." (hurts)','duele',array['duelen','dolor','duela'],'hurts (singular)',5),
        (v_lesson_id,'fill_blank','Complete: "Estoy ___" (sick - m.)','enfermo',array['enferma','enfermos','enfermedad'],'sick (m.)',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Tengo gripe',array['I have a cold','I have flu','I have a cough'],'I have flu',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','¿Tiene algo para el dolor?',array['Where is the doctor?','Do you have something for pain?','How much does it cost?'],'Do you have something for pain?',8),
        (v_lesson_id,'speaking','Say this aloud: "Me siento mal." [meh SYEHN-toh mahl]','Me siento mal',array[]::text[],'I feel bad.',9),
        (v_lesson_id,'speaking','Say this aloud: "Necesito un médico." [neh-seh-SEE-toh oon MEH-dee-koh]','Necesito un médico',array[]::text[],'I need a doctor.',10);

    elsif v_section = 'Hobbies' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "to read"?','leer',array['pintar','viajar','tocar'],'to read',1),
        (v_lesson_id,'multiple_choice','What does "Me encanta cocinar" mean?','I love to cook',array['I cook well','I hate to cook','I want to cook'],'I love to cook',2),
        (v_lesson_id,'multiple_choice','Which verb is used for instruments?','tocar',array['jugar','hacer','practicar'],'to play (instrument)',3),
        (v_lesson_id,'multiple_choice','What does "en mi tiempo libre" mean?','in my free time',array['at work','at school','on vacation'],'in my free time',4),
        (v_lesson_id,'fill_blank','Complete: "Me ___ leer." (like)','gusta',array['gustan','gustar','gustas'],'I like',5),
        (v_lesson_id,'fill_blank','Complete: "Toco ___ guitarra." (the)','la',array['el','los','las'],'the (f.)',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Me gusta viajar',array['I like to travel','I have travelled','I will travel'],'I like to travel',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Salgo con mis amigos',array['I see my friends','I go out with my friends','I work with my friends'],'I go out with my friends',8),
        (v_lesson_id,'speaking','Say this aloud: "Mi hobby es la fotografía." [mee HOH-bee ehs lah foh-toh-grah-FEE-ah]','Mi hobby es la fotografía',array[]::text[],'My hobby is photography.',9),
        (v_lesson_id,'speaking','Say this aloud: "Veo películas." [BEH-oh peh-LEE-koo-lahs]','Veo películas',array[]::text[],'I watch films.',10);

    elsif v_section = 'Work & Jobs' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "engineer" (f.)?','ingeniera',array['ingeniero','ingenia','ingeniería'],'engineer (f.)',1),
        (v_lesson_id,'multiple_choice','What does "Trabajo en una oficina" mean?','I work in an office',array['I have an office','I want an office','I leave an office'],'I work in an office',2),
        (v_lesson_id,'multiple_choice','Which preposition for "work AS"?','de',array['en','con','para'],'as (a role)',3),
        (v_lesson_id,'multiple_choice','What does "el horario" mean?','the schedule',array['the salary','the office','the meeting'],'the schedule',4),
        (v_lesson_id,'fill_blank','Complete: "Soy ___" (engineer m. — no article)','ingeniero',array['un ingeniero','el ingeniero','ingeniería'],'engineer',5),
        (v_lesson_id,'fill_blank','Complete: "Tengo una ___ a las tres." (meeting)','reunión',array['reunir','horario','contrato'],'meeting',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Mi jefe es simpático',array['My boss is strict','My boss is nice','My boss is angry'],'My boss is nice',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Trabajo a tiempo completo',array['I work full time','I work part time','I work overtime'],'I work full time',8),
        (v_lesson_id,'speaking','Say this aloud: "Soy programadora." [SOY proh-grah-mah-DOH-rah]','Soy programadora',array[]::text[],'I am a programmer.',9),
        (v_lesson_id,'speaking','Say this aloud: "Tengo una entrevista mañana." [TEHN-goh OO-nah ehn-treh-BEES-tah mah-NYAH-nah]','Tengo una entrevista mañana',array[]::text[],'I have an interview tomorrow.',10);

    elsif v_section = 'Directions' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "to the right"?','a la derecha',array['a la izquierda','todo recto','en la esquina'],'to the right',1),
        (v_lesson_id,'multiple_choice','What does "Sigue todo recto" mean?','Keep going straight',array['Turn left','Cross the street','Turn at the corner'],'Keep going straight',2),
        (v_lesson_id,'multiple_choice','What is "next to"?','al lado de',array['cerca de','lejos de','enfrente de'],'next to',3),
        (v_lesson_id,'multiple_choice','Which contraction is correct?','del',array['de el','de la','d''el'],'of the',4),
        (v_lesson_id,'fill_blank','Complete: "___ todo recto." (Keep going)','Sigue',array['Gira','Cruza','Sal'],'Keep going (tú)',5),
        (v_lesson_id,'fill_blank','Complete: "Está cerca ___ parque." (of the)','del',array['de el','de la','en el'],'of the',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Cruza la calle',array['Walk on the street','Cross the street','Take the street'],'Cross the street',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','A unos cinco minutos',array['About five minutes away','About five kilometers','About five hours away'],'About five minutes away',8),
        (v_lesson_id,'speaking','Say this aloud: "Perdone, ¿dónde está el banco?" [pehr-DOH-neh DOHN-deh ehs-TAH ehl BAHN-koh]','Perdone, ¿dónde está el banco?',array[]::text[],'Excuse me, where is the bank?',9),
        (v_lesson_id,'speaking','Say this aloud: "Giro a la izquierda." [HEE-roh ah lah ees-KYEHR-dah]','Giro a la izquierda',array[]::text[],'I turn left.',10);

    elsif v_section = 'Feelings & Emotions' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "happy" (f.)?','contenta',array['contento','contento/a','contar'],'happy (f.)',1),
        (v_lesson_id,'multiple_choice','What does "Me siento triste" mean?','I feel sad',array['I am tired','I am angry','I am hungry'],'I feel sad',2),
        (v_lesson_id,'multiple_choice','Which verb is used for moods?','estar',array['ser','tener','hacer'],'to be (state)',3),
        (v_lesson_id,'multiple_choice','What does "porque" mean?','because',array['why','for','if'],'because',4),
        (v_lesson_id,'fill_blank','Complete: "Me ___ feliz." (I feel)','siento',array['sentido','sentiré','sintió'],'I feel',5),
        (v_lesson_id,'fill_blank','Complete: "Estoy ___ humor." (in a good)','de buen',array['en buen','con buen','a buen'],'in a good',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Estoy nervioso por el examen',array['I am ready for the exam','I am nervous about the exam','I am late for the exam'],'I am nervous about the exam',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Tengo miedo de los perros',array['I am afraid of dogs','I like dogs','I have a dog'],'I am afraid of dogs',8),
        (v_lesson_id,'speaking','Say this aloud: "Estoy un poco cansada." [ehs-TOY oon POH-koh kahn-SAH-dah]','Estoy un poco cansada',array[]::text[],'I am a little tired.',9),
        (v_lesson_id,'speaking','Say this aloud: "Me siento muy feliz." [meh SYEHN-toh mwee feh-LEES]','Me siento muy feliz',array[]::text[],'I feel very happy.',10);

    elsif v_section = 'Celebrations' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "birthday"?','cumpleaños',array['boda','fiesta','aniversario'],'birthday',1),
        (v_lesson_id,'multiple_choice','What does "¡Feliz Navidad!" mean?','Merry Christmas!',array['Happy birthday!','Congratulations!','Cheers!'],'Merry Christmas!',2),
        (v_lesson_id,'multiple_choice','How do you say "I''m going to throw a party"?','Voy a hacer una fiesta',array['Hago fiesta','Yo fiesta hago','Fiesta hago'],'I''m going to throw a party',3),
        (v_lesson_id,'multiple_choice','What does "invitar" mean?','to invite',array['to celebrate','to give','to attend'],'to invite',4),
        (v_lesson_id,'fill_blank','Complete: "Voy ___ celebrar." (to)','a',array['de','en','con'],'to (ir a + inf.)',5),
        (v_lesson_id,'fill_blank','Complete: "Compro un ___" (gift)','regalo',array['boda','fiesta','vela'],'gift',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Te invito a mi boda',array['I''m at your wedding','I''m inviting you to my wedding','I missed your wedding'],'I''m inviting you to my wedding',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Brindamos por los novios',array['We toast to the bride and groom','We dance to the bride and groom','We sing to the bride and groom'],'We toast to the bride and groom',8),
        (v_lesson_id,'speaking','Say this aloud: "¡Feliz cumpleaños!" [feh-LEES koom-pleh-AH-nyohs]','¡Feliz cumpleaños!',array[]::text[],'Happy birthday!',9),
        (v_lesson_id,'speaking','Say this aloud: "Vamos a bailar." [BAH-mohs ah bah-ee-LAR]','Vamos a bailar',array[]::text[],'We''re going to dance.',10);

    elsif v_section = 'Nature' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "the river"?','el río',array['el mar','el bosque','el lago'],'the river',1),
        (v_lesson_id,'multiple_choice','What does "El mar es más grande que el río" mean?','The sea is bigger than the river',array['The sea is smaller than the river','The sea is like the river','The sea is the river'],'The sea is bigger than the river',2),
        (v_lesson_id,'multiple_choice','How do you say "Let''s go hiking"?','Vamos a hacer senderismo',array['Vamos hike','Senderismo vamos','Senderismos hacemos'],'Let''s go hiking',3),
        (v_lesson_id,'multiple_choice','Which adjective is irregular comparative?','mejor',array['más bueno','muy bueno','bueno más'],'better',4),
        (v_lesson_id,'fill_blank','Complete: "Hay muchos ___" (trees)','árboles',array['árbol','árbola','arbóreas'],'trees',5),
        (v_lesson_id,'fill_blank','Complete: "Es ___ grande ___ el bosque." (as ... as)','tan / como',array['más / que','muy / como','mucho / que'],'as ... as',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Voy a la montaña',array['I''m going to the beach','I''m going to the mountain','I''m going to the river'],'I''m going to the mountain',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','El paisaje es precioso',array['The landscape is beautiful','The landscape is boring','The landscape is small'],'The landscape is beautiful',8),
        (v_lesson_id,'speaking','Say this aloud: "Camino por el bosque." [kah-MEE-noh pohr ehl BOHS-keh]','Camino por el bosque',array[]::text[],'I walk through the forest.',9),
        (v_lesson_id,'speaking','Say this aloud: "Me encanta el mar." [meh ehn-KAHN-tah ehl mahr]','Me encanta el mar',array[]::text[],'I love the sea.',10);

    elsif v_section = 'Sports' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "basketball"?','baloncesto',array['fútbol','tenis','natación'],'basketball',1),
        (v_lesson_id,'multiple_choice','What does "Juego al tenis los sábados" mean?','I play tennis on Saturdays',array['I watch tennis on Saturdays','I love tennis on Saturdays','I train tennis on Saturdays'],'I play tennis on Saturdays',2),
        (v_lesson_id,'multiple_choice','Which verb for "to swim" (as a sport)?','hacer natación',array['jugar natación','correr natación','tener natación'],'to do swimming',3),
        (v_lesson_id,'multiple_choice','What does "el partido" mean?','the match',array['the team','the player','the win'],'the match',4),
        (v_lesson_id,'fill_blank','Complete: "Juego ___ fútbol." (to)','al',array['en','con','de'],'to the (a + el)',5),
        (v_lesson_id,'fill_blank','Complete: "Mi ___ favorito es el tenis." (sport)','deporte',array['equipo','partido','jugador'],'sport',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Mi equipo gana mucho',array['My team wins a lot','My team loses a lot','My team is small'],'My team wins a lot',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Entreno dos veces a la semana',array['I train every day','I train twice a week','I train once a month'],'I train twice a week',8),
        (v_lesson_id,'speaking','Say this aloud: "Somos los campeones." [SOH-mohs lohs kahm-peh-OH-nehs]','Somos los campeones',array[]::text[],'We are the champions.',9),
        (v_lesson_id,'speaking','Say this aloud: "Hago deporte tres veces a la semana." [AH-goh deh-POHR-teh trehs BEH-sehs ah lah seh-MAH-nah]','Hago deporte tres veces a la semana',array[]::text[],'I do sport three times a week.',10);

    elsif v_section = 'Music' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "the song"?','la canción',array['el cantante','la banda','el concierto'],'the song',1),
        (v_lesson_id,'multiple_choice','What does "Sé tocar la guitarra" mean?','I know how to play the guitar',array['I want to play the guitar','I bought the guitar','I sold the guitar'],'I know how to play the guitar',2),
        (v_lesson_id,'multiple_choice','How do you say "I really like jazz"?','Me gusta mucho el jazz',array['Yo mucho gusto jazz','Mucho me gusta jazz','Jazz me gusta mucho'],'I really like jazz',3),
        (v_lesson_id,'multiple_choice','What does "la letra" mean?','the lyrics',array['the letter','the music','the rhythm'],'the lyrics',4),
        (v_lesson_id,'fill_blank','Complete: "___ tocar el piano." (I know how)','Sé',array['Se','Saber','Sabo'],'I know',5),
        (v_lesson_id,'fill_blank','Complete: "No me gusta ___ el reggaetón." (at all)','nada',array['mucho','un poco','siempre'],'at all',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Voy al concierto el sábado',array['I''m going to the concert on Saturday','I went to the concert on Saturday','I missed the concert on Saturday'],'I''m going to the concert on Saturday',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Pongo música cuando cocino',array['I put music on when I cook','I cook when I hear music','I sing when I cook'],'I put music on when I cook',8),
        (v_lesson_id,'speaking','Say this aloud: "Mi cantante favorito es español." [mee kahn-TAHN-teh fah-boh-REE-toh ehs ehs-pah-NYOHL]','Mi cantante favorito es español',array[]::text[],'My favorite singer is Spanish.',9),
        (v_lesson_id,'speaking','Say this aloud: "Compro dos entradas." [KOHM-proh dohs ehn-TRAH-dahs]','Compro dos entradas',array[]::text[],'I buy two tickets.',10);

    elsif v_section = 'Travel Planning' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "the flight"?','el vuelo',array['el viaje','el billete','el hotel'],'the flight',1),
        (v_lesson_id,'multiple_choice','What does "Hago la maleta" mean?','I pack my suitcase',array['I lose my suitcase','I carry my suitcase','I open my suitcase'],'I pack my suitcase',2),
        (v_lesson_id,'multiple_choice','How do you say "one-way ticket"?','sólo ida',array['ida y vuelta','sólo vuelta','un billete'],'one way',3),
        (v_lesson_id,'multiple_choice','What does "el destino" mean?','the destination',array['the budget','the itinerary','the passport'],'the destination',4),
        (v_lesson_id,'fill_blank','Complete: "Un billete ___ Madrid." (to)','para',array['en','de','con'],'to (destination)',5),
        (v_lesson_id,'fill_blank','Complete: "Voy a ___ un hotel." (book)','reservar',array['reserva','reservo','reservé'],'to book',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Su vuelo despega a las ocho',array['Your flight takes off at eight','Your flight arrives at eight','Your flight was at eight'],'Your flight takes off at eight',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Aquí está mi pasaporte',array['I lost my passport','Here is my passport','I need a passport'],'Here is my passport',8),
        (v_lesson_id,'speaking','Say this aloud: "Quiero un billete para Madrid." [KYEH-roh oon bee-YEH-teh PAH-rah mah-DREED]','Quiero un billete para Madrid',array[]::text[],'I want a ticket to Madrid.',9),
        (v_lesson_id,'speaking','Say this aloud: "Voy a reservar un hotel." [BOY ah rreh-sehr-BAR oon oh-TEHL]','Voy a reservar un hotel',array[]::text[],'I''m going to book a hotel.',10);

    elsif v_section = 'Restaurants' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "the bill"?','la cuenta',array['el menú','el plato','el camarero'],'the bill',1),
        (v_lesson_id,'multiple_choice','What does "La carta, por favor" mean?','The menu, please',array['The letter, please','The bill, please','The water, please'],'The menu, please',2),
        (v_lesson_id,'multiple_choice','Which is the starter?','de primero',array['de segundo','de postre','de beber'],'as a starter',3),
        (v_lesson_id,'multiple_choice','What does "sin queso" mean?','without cheese',array['with cheese','only cheese','more cheese'],'without cheese',4),
        (v_lesson_id,'fill_blank','Complete: "¿Me ___ el menú?" (could you bring)','trae',array['traer','traigo','traes'],'bring (usted)',5),
        (v_lesson_id,'fill_blank','Complete: "Una mesa ___ dos." (for)','para',array['por','a','de'],'for',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','La comida estaba deliciosa',array['The food was delicious','The food was bad','The food was cold'],'The food was delicious',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','¿Qué van a tomar?',array['What time is it?','What are you going to have?','Where are you sitting?'],'What are you going to have?',8),
        (v_lesson_id,'speaking','Say this aloud: "La cuenta, por favor." [lah KWEHN-tah pohr fah-BOHR]','La cuenta, por favor',array[]::text[],'The bill, please.',9),
        (v_lesson_id,'speaking','Say this aloud: "Quiero la paella." [KYEH-roh lah pah-EH-yah]','Quiero la paella',array[]::text[],'I want the paella.',10);

    elsif v_section = 'School' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "homework"?','los deberes',array['el examen','la clase','la asignatura'],'homework',1),
        (v_lesson_id,'multiple_choice','What does "Aprobé el examen" mean?','I passed the exam',array['I failed the exam','I missed the exam','I took the exam'],'I passed the exam',2),
        (v_lesson_id,'multiple_choice','How do you say "I have to study"?','Tengo que estudiar',array['Yo estudiar tengo','Estudio que tener','Estudiar tengo'],'I have to study',3),
        (v_lesson_id,'multiple_choice','What does "el recreo" mean?','recess / break',array['the test','the school','the bus'],'recess',4),
        (v_lesson_id,'fill_blank','Complete: "Tengo ___ entregar el trabajo." (to)','que',array['de','para','en'],'to (obligation)',5),
        (v_lesson_id,'fill_blank','Complete: "Saqué un ___ en el examen." (an 8)','ocho',array['ochos','octavo','ochoo'],'eight',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Mi profesora es paciente',array['My teacher is impatient','My teacher is patient','My teacher is angry'],'My teacher is patient',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Suspendí matemáticas',array['I passed math','I failed math','I started math'],'I failed math',8),
        (v_lesson_id,'speaking','Say this aloud: "Tengo un examen mañana." [TEHN-goh oon ehk-SAH-mehn mah-NYAH-nah]','Tengo un examen mañana',array[]::text[],'I have an exam tomorrow.',9),
        (v_lesson_id,'speaking','Say this aloud: "Mi asignatura favorita es historia." [mee ah-seeg-nah-TOO-rah fah-boh-REE-tah ehs ees-TOH-ryah]','Mi asignatura favorita es historia',array[]::text[],'My favorite subject is history.',10);

    elsif v_section = 'Technology Basics' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "the password"?','la contraseña',array['el cargador','la pantalla','la batería'],'the password',1),
        (v_lesson_id,'multiple_choice','What does "No funciona el wifi" mean?','The wifi isn''t working',array['The wifi is fast','The wifi is free','I love the wifi'],'The wifi isn''t working',2),
        (v_lesson_id,'multiple_choice','How do you say "I can download"?','Puedo descargar',array['Descargo poder','Puedo descargo','Descargo puedo'],'I can download',3),
        (v_lesson_id,'multiple_choice','What does "el cargador" mean?','the charger',array['the screen','the battery','the message'],'the charger',4),
        (v_lesson_id,'fill_blank','Complete: "Mi móvil ___ se conecta." (not / won''t)','no',array['sí','muy','también'],'not / won''t',5),
        (v_lesson_id,'fill_blank','Complete: "Tengo que ___ la app." (update)','actualizar',array['actualizo','actualizado','actualizando'],'to update',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','La batería está baja',array['The battery is full','The battery is low','The battery is new'],'The battery is low',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','¿Me prestas tu cargador?',array['Where''s your charger?','Can you lend me your charger?','Is this your charger?'],'Can you lend me your charger?',8),
        (v_lesson_id,'speaking','Say this aloud: "Voy a reiniciar el ordenador." [BOY ah rreh-ee-nee-SYAR ehl ohr-deh-nah-DOHR]','Voy a reiniciar el ordenador',array[]::text[],'I''m going to restart the computer.',9),
        (v_lesson_id,'speaking','Say this aloud: "Mi móvil no funciona." [mee MOH-beel noh foon-SYOH-nah]','Mi móvil no funciona',array[]::text[],'My phone isn''t working.',10);

    elsif v_section = 'Social Media' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "to post"?','publicar',array['seguir','compartir','etiquetar'],'to post',1),
        (v_lesson_id,'multiple_choice','What does "Te sigo en Instagram" mean?','I follow you on Instagram',array['I unfollow you on Instagram','I see you on Instagram','I block you on Instagram'],'I follow you on Instagram',2),
        (v_lesson_id,'multiple_choice','How do you say "I''m posting now"?','Estoy publicando ahora',array['Yo publico ahora','Publicaré ahora','Publicado ahora'],'I''m posting now',3),
        (v_lesson_id,'multiple_choice','What does "el seguidor" mean?','the follower',array['the like','the post','the friend'],'the follower',4),
        (v_lesson_id,'fill_blank','Complete: "Sigo ___ mis amigos." (personal "a")','a',array['en','de','con'],'(personal a)',5),
        (v_lesson_id,'fill_blank','Complete: "Estoy escri___" (writing)','biendo',array['ando','iendo','endo'],'-iendo',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Subo una historia diaria',array['I upload a daily story','I never post','I delete stories daily'],'I upload a daily story',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Su vídeo se hizo viral',array['His video disappeared','His video went viral','His video failed'],'His video went viral',8),
        (v_lesson_id,'speaking','Say this aloud: "Comparto vídeos graciosos." [kohm-PAR-toh BEE-deh-ohs grah-SYOH-sohs]','Comparto vídeos graciosos',array[]::text[],'I share funny videos.',9),
        (v_lesson_id,'speaking','Say this aloud: "Etiqueta a tus amigos." [eh-tee-KEH-tah ah toos ah-MEE-gohs]','Etiqueta a tus amigos',array[]::text[],'Tag your friends.',10);
    end if;
  end loop;
end $$;

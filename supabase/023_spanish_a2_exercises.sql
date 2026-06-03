-- 023_spanish_a2_exercises.sql
-- Real A2 exercise content for Spanish, mirroring migration 016 for A1.
-- 15 A2 sections × 7 substantive lessons × 5 exercises = 525 exercises.
-- Each lesson keeps the same role: vocab MC, grammar fill-in, phrase MC,
-- listening, speaking, reading-comprehension on a short paragraph stored
-- in the lesson description, and writing (translation). Lesson 8 stays
-- as the podcast placeholder; teaching content (017-style), unit tests
-- (019-style) and conversation lessons (021-style) for A2 land in
-- follow-up migrations.
--
-- A1 review is woven into A2 exercises wherever it reinforces a A2 pattern
-- (greetings inside Restaurants, family inside Celebrations, colors inside
-- Clothes-related work answers, etc.) so learners keep their foundation.
--
-- Idempotent: clears the 7 substantive lessons of each A2 section before
-- inserting.

do $$
declare
  v_lang_id    bigint;
  v_course_id  bigint;
  v_l1 bigint; v_l2 bigint; v_l3 bigint; v_l4 bigint;
  v_l5 bigint; v_l6 bigint; v_l7 bigint; v_l8 bigint;
  v_podcast_title text := 'Coming Soon';
  v_podcast_desc  text := 'Premium podcast and video content for this topic will be available soon.';
begin
  select id into v_lang_id from public.languages where code = 'spanish';

  -- ============== A2.1 DAILY ROUTINES ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Daily Routines';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'Todos los días me levanto a las siete. Me ducho, desayuno café con leche y voy al trabajo en metro. Por la tarde estudio español y por la noche ceno con mi familia.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','How do you say "to wake up" (reflexive)?','despertarse',array['levantarse','dormirse','vestirse'],'To wake up [dehs-pehr-TAHR-seh]',1),
    (v_l1,'multiple_choice','How do you say "to get up"?','levantarse',array['despertarse','sentarse','llevarse'],'To get up',2),
    (v_l1,'multiple_choice','How do you say "to shower"?','ducharse',array['lavarse','bañarse','duchar'],'To shower',3),
    (v_l1,'multiple_choice','How do you say "to have breakfast"?','desayunar',array['cenar','comer','almorzar'],'To have breakfast',4),
    (v_l1,'multiple_choice','How do you say "to go to bed"?','acostarse',array['despertarse','sentarse','levantarse'],'To go to bed',5),
    (v_l2,'fill_blank','Complete: "Yo ___ a las siete." (I get up)','me levanto',array['levanto','se levanta','te levantas'],'Reflexive yo form',1),
    (v_l2,'fill_blank','Complete: "Tú ___ rápido." (You shower quickly)','te duchas',array['me ducho','se ducha','duchas'],'Reflexive tú form',2),
    (v_l2,'fill_blank','Complete: "Mi hermana ___ a las once." (goes to bed)','se acuesta',array['acuesta','te acuestas','me acuesto'],'Reflexive 3rd person',3),
    (v_l2,'fill_blank','Complete: "Nosotros ___ a las ocho." (have breakfast)','desayunamos',array['desayuno','desayuna','desayunan'],'Nosotros form',4),
    (v_l2,'fill_blank','Complete: "Después de comer, ___ la siesta." (I take)','duermo',array['hago','hago la siesta','tomo'],'duermo la siesta is also fine; standard answer',5),
    (v_l3,'multiple_choice','What does "todos los días" mean?','every day',array['some days','never','sometimes'],'Frequency',1),
    (v_l3,'multiple_choice','Translate "Después desayuno."','Then I have breakfast',array['Before breakfast','I am hungry','I do not eat'],'Sequencer',2),
    (v_l3,'multiple_choice','What does "antes de dormir" mean?','before sleeping',array['after sleeping','while sleeping','instead of sleeping'],'Time expression',3),
    (v_l3,'multiple_choice','Translate "Por la mañana voy al trabajo."','In the morning I go to work',array['I work all day','I leave work in the morning','I work at home'],'Daily routine',4),
    (v_l3,'multiple_choice','What does "los fines de semana" mean?','on weekends',array['during the week','every Monday','only Sunday'],'Frequency',5),
    (v_l4,'listening','Listen and pick the English meaning.','me levanto a las siete',array['I sleep at seven','I go to bed at seven','I get up at seven'],'I get up at seven',1),
    (v_l4,'listening','Listen and pick the English meaning.','me ducho rápido',array['I shower slowly','I shower quickly','I do not shower'],'I shower quickly',2),
    (v_l4,'listening','Listen and pick the English meaning.','desayuno café y pan',array['I have tea and bread','I have coffee and bread','I have coffee and cheese'],'I have coffee and bread',3),
    (v_l4,'listening','Listen and pick the English meaning.','voy al trabajo en metro',array['I drive to work','I take the metro to work','I walk to work'],'I take the metro to work',4),
    (v_l4,'listening','Listen and pick the English meaning.','me acuesto tarde',array['I go to bed late','I get up late','I sleep little'],'I go to bed late',5),
    (v_l5,'speaking','Say this aloud: "Me levanto a las siete."','Me levanto a las siete',array[]::text[],'I get up at seven.',1),
    (v_l5,'speaking','Say this aloud: "Desayuno café con leche."','Desayuno café con leche',array[]::text[],'I have coffee with milk for breakfast.',2),
    (v_l5,'speaking','Say this aloud: "Voy al trabajo en metro."','Voy al trabajo en metro',array[]::text[],'I go to work by metro.',3),
    (v_l5,'speaking','Say this aloud: "Por la tarde estudio español."','Por la tarde estudio español',array[]::text[],'In the afternoon I study Spanish.',4),
    (v_l5,'speaking','Say this aloud: "Me acuesto a las once."','Me acuesto a las once',array[]::text[],'I go to bed at eleven.',5),
    (v_l6,'multiple_choice','What time does the speaker get up?','7',array['8','9','10'],'Me levanto a las siete',1),
    (v_l6,'multiple_choice','What does the speaker have for breakfast?','Coffee with milk',array['Just water','Bread and cheese','Eggs'],'Café con leche',2),
    (v_l6,'multiple_choice','How does the speaker go to work?','By metro',array['By bus','On foot','By car'],'En metro',3),
    (v_l6,'multiple_choice','What does the speaker do in the afternoon?','Study Spanish',array['Work','Sleep','Watch TV'],'Estudio español',4),
    (v_l6,'multiple_choice','When does the speaker have dinner with family?','At night',array['In the morning','At noon','Never'],'Por la noche ceno con mi familia',5),
    (v_l7,'fill_blank','Translate to Spanish: "I get up at eight."','Me levanto a las ocho',array['Yo levanto a las ocho','Me levanto las ocho','Levantarme a las ocho'],'Reflexive',1),
    (v_l7,'fill_blank','Translate to Spanish: "I shower in the morning."','Me ducho por la mañana',array['Ducho a la mañana','Me ducho a las mañanas','Yo duchar por mañana'],'por la mañana',2),
    (v_l7,'fill_blank','Translate to Spanish: "I go to bed at eleven."','Me acuesto a las once',array['Acuesto a once','Me acuesto las once','Voy a la cama once'],'Reflexive',3),
    (v_l7,'fill_blank','Translate to Spanish: "Every day I study Spanish."','Todos los días estudio español',array['Cada día estudio español (also OK)','Estudio español días','Toda día estudio español'],'todos los días',4),
    (v_l7,'fill_blank','Translate to Spanish: "I have breakfast with my family."','Desayuno con mi familia',array['Yo desayuno familia','Desayunamos familia','Desayuno mi familia'],'con + family (A1 review)',5);

  -- ============== A2.2 HEALTH & BODY ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Health & Body';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'Hoy no me siento bien. Me duele la cabeza y tengo un poco de fiebre. Voy al médico por la tarde. Necesito una receta y descansar. Mañana espero estar mejor.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','How do you say "headache"?','dolor de cabeza',array['dolor de espalda','fiebre','gripe'],'A common ache',1),
    (v_l1,'multiple_choice','How do you say "fever"?','fiebre',array['frío','calor','tos'],'Symptom',2),
    (v_l1,'multiple_choice','How do you say "cough"?','tos',array['fiebre','gripe','dolor'],'Symptom',3),
    (v_l1,'multiple_choice','How do you say "prescription"?','receta',array['recibo','factura','medicina'],'Pharmacy',4),
    (v_l1,'multiple_choice','How do you say "back" (body part)?','espalda',array['estómago','garganta','pierna'],'Body part',5),
    (v_l2,'fill_blank','Complete: "Me ___ la cabeza." (hurts)','duele',array['duelo','duelen','duela'],'doler, singular',1),
    (v_l2,'fill_blank','Complete: "Me ___ los pies." (hurt)','duelen',array['duele','duelo','dolor'],'doler, plural',2),
    (v_l2,'fill_blank','Complete: "Tengo ___" (a cough)','tos',array['tose','toser','tosos'],'symptom',3),
    (v_l2,'fill_blank','Complete: "Estoy ___" (sick, m.)','enfermo',array['enferma','enfermos','enfermar'],'estar + state',4),
    (v_l2,'fill_blank','Complete: "Necesito ir al ___" (doctor)','médico',array['hospital (also OK)','farmacia','dentista'],'médico',5),
    (v_l3,'multiple_choice','What does "no me siento bien" mean?','I don''t feel well',array['I am tired','I am hungry','I am happy'],'A2 phrase',1),
    (v_l3,'multiple_choice','Translate "Tomo dos pastillas al día."','I take two pills a day',array['I bought two pills','I sell pills','I am two days late'],'A2 phrase',2),
    (v_l3,'multiple_choice','What does "estoy resfriado" mean?','I have a cold',array['I am warm','I am tired','I am hungry'],'A2 phrase',3),
    (v_l3,'multiple_choice','Translate "Me he caído."','I have fallen',array['I am falling','I will fall','I fell asleep'],'A2 perfect tense',4),
    (v_l3,'multiple_choice','What does "tener cuidado" mean?','to be careful',array['to be sick','to be lucky','to be on time'],'idiom',5),
    (v_l4,'listening','Listen and pick the English meaning.','me duele la cabeza',array['I am hungry','My head hurts','I am tired'],'My head hurts',1),
    (v_l4,'listening','Listen and pick the English meaning.','tengo fiebre',array['I have a cough','I have a fever','I have a cold'],'I have a fever',2),
    (v_l4,'listening','Listen and pick the English meaning.','necesito una receta',array['I need a recipe','I need a prescription','I need water'],'I need a prescription',3),
    (v_l4,'listening','Listen and pick the English meaning.','voy al médico mañana',array['I go to the doctor tomorrow','I went to the doctor','I am the doctor'],'I go to the doctor tomorrow',4),
    (v_l4,'listening','Listen and pick the English meaning.','no me siento bien',array['I feel well','I do not feel well','I am sitting'],'I don''t feel well',5),
    (v_l5,'speaking','Say this aloud: "Me duele mucho la cabeza."','Me duele mucho la cabeza',array[]::text[],'My head hurts a lot.',1),
    (v_l5,'speaking','Say this aloud: "Tengo fiebre y tos."','Tengo fiebre y tos',array[]::text[],'I have a fever and a cough.',2),
    (v_l5,'speaking','Say this aloud: "Necesito ver al médico."','Necesito ver al médico',array[]::text[],'I need to see the doctor.',3),
    (v_l5,'speaking','Say this aloud: "Estoy un poco resfriado."','Estoy un poco resfriado',array[]::text[],'I have a slight cold.',4),
    (v_l5,'speaking','Say this aloud: "Tomo medicina dos veces al día."','Tomo medicina dos veces al día',array[]::text[],'I take medicine twice a day.',5),
    (v_l6,'multiple_choice','How does the speaker feel?','Not well',array['Great','Tired but fine','Hungry'],'No me siento bien',1),
    (v_l6,'multiple_choice','What hurts?','Head',array['Stomach','Back','Throat'],'Me duele la cabeza',2),
    (v_l6,'multiple_choice','Does the speaker have a fever?','Yes, a little',array['No','High fever','Doesn''t know'],'Un poco de fiebre',3),
    (v_l6,'multiple_choice','When does the speaker go to the doctor?','In the afternoon',array['In the morning','At night','Tomorrow'],'Por la tarde',4),
    (v_l6,'multiple_choice','What does the speaker hope for tomorrow?','To be better',array['To work more','To travel','To eat'],'Espero estar mejor',5),
    (v_l7,'fill_blank','Translate to Spanish: "My head hurts."','Me duele la cabeza',array['Mi cabeza duele','Me duelo la cabeza','La cabeza me dolor'],'doler pattern',1),
    (v_l7,'fill_blank','Translate to Spanish: "I have a fever."','Tengo fiebre',array['Estoy fiebre','Hago fiebre','Soy fiebre'],'tener for symptoms',2),
    (v_l7,'fill_blank','Translate to Spanish: "I need to rest."','Necesito descansar',array['Necesito descanso','Yo descanso','Descansar yo'],'A2 phrase',3),
    (v_l7,'fill_blank','Translate to Spanish: "I take medicine twice a day."','Tomo medicina dos veces al día',array['Tomo dos pastillas','Tomo medicina cada dos','Tomo medicina dos día'],'A2 phrase',4),
    (v_l7,'fill_blank','Translate to Spanish: "I am sick today."','Hoy estoy enfermo',array['Hoy soy enfermo','Hoy tengo enfermo','Hoy estoy enfermos'],'estar + adj (A1 review)',5);

  -- ============== A2.3 HOBBIES ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Hobbies';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'En mi tiempo libre me gusta leer libros y escuchar música. Los sábados juego al fútbol con mis amigos. Mi hermana prefiere bailar. A veces vamos al cine juntos.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','How do you say "to read"?','leer',array['escribir','correr','escuchar'],'reading hobby',1),
    (v_l1,'multiple_choice','How do you say "to listen to music"?','escuchar música',array['ver música','oír música también','tocar música'],'listening hobby',2),
    (v_l1,'multiple_choice','How do you say "to play soccer"?','jugar al fútbol',array['tocar el fútbol','hacer fútbol','poner fútbol'],'sport',3),
    (v_l1,'multiple_choice','How do you say "to dance"?','bailar',array['cantar','beber','bañar'],'hobby',4),
    (v_l1,'multiple_choice','How do you say "to watch movies"?','ver películas',array['mirar películas también','ir al cine','filmar'],'hobby',5),
    (v_l2,'fill_blank','Complete: "Me ___ leer." (I like)','gusta',array['gustan','gusto','gustar'],'gustar singular verb',1),
    (v_l2,'fill_blank','Complete: "Me ___ los deportes." (I like, plural)','gustan',array['gusta','gusto','gustar'],'gustar plural',2),
    (v_l2,'fill_blank','Complete: "Juego ___ baloncesto." (basketball)','al',array['en','a','el'],'jugar a + sport',3),
    (v_l2,'fill_blank','Complete: "Toco ___ guitarra." (the guitar)','la',array['al','el','en'],'tocar + instrument',4),
    (v_l2,'fill_blank','Complete: "Prefiero ___ cine." (the cinema)','el',array['al','en','la'],'definite article',5),
    (v_l3,'multiple_choice','What does "tiempo libre" mean?','free time',array['vacation','weekend','schedule'],'A2 phrase',1),
    (v_l3,'multiple_choice','What does "salir con amigos" mean?','go out with friends',array['stay home','call friends','meet new friends'],'A2 phrase',2),
    (v_l3,'multiple_choice','Translate "A veces voy al cine."','Sometimes I go to the cinema',array['I always go to the cinema','I never go to the cinema','I go to the cinema today'],'Frequency',3),
    (v_l3,'multiple_choice','What does "me encanta" mean?','I love (it)',array['I like a little','I hate','I prefer'],'Stronger than gustar',4),
    (v_l3,'multiple_choice','Translate "Prefiero el cine al teatro."','I prefer the cinema to the theatre',array['I love the theatre','The cinema is good','I go to the theatre'],'preferir A a B',5),
    (v_l4,'listening','Listen and pick the English meaning.','me gusta leer',array['I prefer reading','I like reading','I do not read'],'I like reading',1),
    (v_l4,'listening','Listen and pick the English meaning.','escucho música cada día',array['I write music every day','I listen to music every day','I play music every day'],'I listen to music every day',2),
    (v_l4,'listening','Listen and pick the English meaning.','juego al fútbol los sábados',array['I play soccer on Saturdays','I watch soccer on Saturdays','I love soccer on Saturdays'],'I play soccer on Saturdays',3),
    (v_l4,'listening','Listen and pick the English meaning.','vamos al cine juntos',array['We go to the cinema together','We go to the cinema today','We meet at the cinema'],'We go to the cinema together',4),
    (v_l4,'listening','Listen and pick the English meaning.','prefiero bailar',array['I love to dance','I prefer to dance','I cannot dance'],'I prefer to dance',5),
    (v_l5,'speaking','Say this aloud: "Me gusta leer libros."','Me gusta leer libros',array[]::text[],'I like to read books.',1),
    (v_l5,'speaking','Say this aloud: "Juego al tenis los domingos."','Juego al tenis los domingos',array[]::text[],'I play tennis on Sundays.',2),
    (v_l5,'speaking','Say this aloud: "Mi hermana prefiere bailar."','Mi hermana prefiere bailar',array[]::text[],'My sister prefers to dance. (A1 review: hermana)',3),
    (v_l5,'speaking','Say this aloud: "Vamos al cine juntos."','Vamos al cine juntos',array[]::text[],'We go to the cinema together.',4),
    (v_l5,'speaking','Say this aloud: "Me encanta escuchar música."','Me encanta escuchar música',array[]::text[],'I love listening to music.',5),
    (v_l6,'multiple_choice','What does the speaker do in free time?','Read and listen to music',array['Cook and clean','Work and rest','Travel'],'Leer y escuchar música',1),
    (v_l6,'multiple_choice','What sport does the speaker play?','Soccer',array['Tennis','Basketball','Swimming'],'Fútbol',2),
    (v_l6,'multiple_choice','When does the speaker play soccer?','Saturdays',array['Sundays','Every day','Mondays'],'Los sábados',3),
    (v_l6,'multiple_choice','What does the sister prefer?','Dancing',array['Soccer','Music','Reading'],'Bailar',4),
    (v_l6,'multiple_choice','How often do they go to the cinema?','Sometimes',array['Always','Never','Daily'],'A veces',5),
    (v_l7,'fill_blank','Translate to Spanish: "I like reading."','Me gusta leer',array['Me gustan leer','Yo gusto leer','Me gusta leyendo'],'gustar + infinitive',1),
    (v_l7,'fill_blank','Translate to Spanish: "I play soccer."','Juego al fútbol',array['Yo jugar fútbol','Juego fútbol','Toco el fútbol'],'jugar a + sport',2),
    (v_l7,'fill_blank','Translate to Spanish: "I love music."','Me encanta la música',array['Yo amo música','Me encanta música','Quiero música'],'definite article',3),
    (v_l7,'fill_blank','Translate to Spanish: "I dance on Saturdays."','Bailo los sábados',array['Yo bailo sábado','Bailo en sábados','Bailo sábados'],'habitual los + day',4),
    (v_l7,'fill_blank','Translate to Spanish: "Sometimes I go to the cinema."','A veces voy al cine',array['Voy al cine a veces','Yo voy al cine','Algunas voces voy al cine'],'A veces',5);

  -- ============== A2.4 WORK & JOBS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Work & Jobs';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'Trabajo en una oficina en el centro. Empiezo a las nueve y termino a las seis. Mi jefe se llama Sr. Ruiz. Tengo una reunión importante el lunes con un cliente nuevo.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','How do you say "office"?','oficina',array['casa','tienda','escuela'],'workplace',1),
    (v_l1,'multiple_choice','How do you say "boss"?','jefe',array['cliente','empleado','obrero'],'workplace person',2),
    (v_l1,'multiple_choice','How do you say "meeting"?','reunión',array['fiesta','clase','cita'],'work event',3),
    (v_l1,'multiple_choice','How do you say "client"?','cliente',array['jefe','empleado','vecino'],'business person',4),
    (v_l1,'multiple_choice','How do you say "schedule" (work hours)?','horario',array['hora','tiempo','calendario'],'work hours',5),
    (v_l2,'fill_blank','Complete: "___ a las nueve." (I start)','Empiezo',array['Termino','Empieza','Empezamos'],'empezar yo form',1),
    (v_l2,'fill_blank','Complete: "Tú ___ a las seis." (finish)','terminas',array['termino','termina','terminan'],'terminar tú',2),
    (v_l2,'fill_blank','Complete: "Trabajo ___ una oficina." (in)','en',array['a','de','con'],'preposition',3),
    (v_l2,'fill_blank','Complete: "El jefe ___ Sr. Ruiz." (is called)','se llama',array['llama','llamarse','llamamos'],'llamarse',4),
    (v_l2,'fill_blank','Complete: "Tengo una reunión ___ lunes." (on Monday)','el',array['en','de','a'],'el + day for "on"',5),
    (v_l3,'multiple_choice','What does "estar de vacaciones" mean?','to be on vacation',array['to be at work','to be tired','to be home'],'A2 phrase',1),
    (v_l3,'multiple_choice','Translate "Trabajo desde casa."','I work from home',array['I work at the office','I am tired','I leave home'],'A2 phrase',2),
    (v_l3,'multiple_choice','What does "ganar dinero" mean?','to earn money',array['to spend money','to lose money','to borrow money'],'A2 phrase',3),
    (v_l3,'multiple_choice','What does "buscar trabajo" mean?','to look for a job',array['to lose a job','to like a job','to start a job'],'A2 phrase',4),
    (v_l3,'multiple_choice','Translate "Mi compañera es simpática."','My colleague is nice',array['My friend is sad','My family is here','My boss is strict'],'colleague',5),
    (v_l4,'listening','Listen and pick the English meaning.','trabajo en una oficina',array['I sleep in an office','I work in an office','I clean an office'],'I work in an office',1),
    (v_l4,'listening','Listen and pick the English meaning.','empiezo a las nueve',array['I finish at nine','I start at nine','I am at nine'],'I start at nine',2),
    (v_l4,'listening','Listen and pick the English meaning.','tengo una reunión importante',array['I have an important meeting','I have a friendly meeting','I had a meeting'],'I have an important meeting',3),
    (v_l4,'listening','Listen and pick the English meaning.','mi jefe es estricto',array['My boss is strict','My boss is nice','My boss is funny'],'My boss is strict',4),
    (v_l4,'listening','Listen and pick the English meaning.','busco un trabajo nuevo',array['I love my job','I am looking for a new job','I have a new job'],'I am looking for a new job',5),
    (v_l5,'speaking','Say this aloud: "Trabajo en una oficina."','Trabajo en una oficina',array[]::text[],'I work in an office.',1),
    (v_l5,'speaking','Say this aloud: "Empiezo a las nueve."','Empiezo a las nueve',array[]::text[],'I start at nine.',2),
    (v_l5,'speaking','Say this aloud: "Tengo una reunión a las tres."','Tengo una reunión a las tres',array[]::text[],'I have a meeting at three. (A1 review: tres)',3),
    (v_l5,'speaking','Say this aloud: "Mi jefe se llama Sr. Ruiz."','Mi jefe se llama Sr. Ruiz',array[]::text[],'My boss is called Mr. Ruiz.',4),
    (v_l5,'speaking','Say this aloud: "Trabajo desde casa los viernes."','Trabajo desde casa los viernes',array[]::text[],'I work from home on Fridays.',5),
    (v_l6,'multiple_choice','Where does the speaker work?','In an office downtown',array['At home','In a shop','At school'],'En una oficina en el centro',1),
    (v_l6,'multiple_choice','What time does the speaker start?','9',array['8','10','7'],'Empiezo a las nueve',2),
    (v_l6,'multiple_choice','What time does the speaker finish?','6',array['5','7','8'],'Termino a las seis',3),
    (v_l6,'multiple_choice','What is the boss''s name?','Mr. Ruiz',array['Mr. García','Mr. López','Mr. Pérez'],'Sr. Ruiz',4),
    (v_l6,'multiple_choice','When is the important meeting?','Monday',array['Tuesday','Friday','Today'],'El lunes',5),
    (v_l7,'fill_blank','Translate to Spanish: "I work in an office."','Trabajo en una oficina',array['Yo trabajo oficina','Trabajo de una oficina','Trabajamos en oficina'],'preposition',1),
    (v_l7,'fill_blank','Translate to Spanish: "I start work at eight."','Empiezo a trabajar a las ocho',array['Empiezo trabajar las ocho','Yo trabajo a ocho','Empiezo a las ocho a trabajar'],'a + infinitive',2),
    (v_l7,'fill_blank','Translate to Spanish: "I have a meeting today."','Tengo una reunión hoy',array['Yo reunión hoy','Tengo reunión hoy','Tengo un reunión hoy'],'tener',3),
    (v_l7,'fill_blank','Translate to Spanish: "My boss is named García."','Mi jefe se llama García',array['Mi jefe nombre García','Yo jefe García','Mi jefe es García'],'llamarse',4),
    (v_l7,'fill_blank','Translate to Spanish: "I work from home on Fridays."','Trabajo desde casa los viernes',array['Trabajo de casa viernes','Yo casa viernes trabajo','Trabajamos casa viernes'],'desde + place; los + day',5);

  -- ============== A2.5 DIRECTIONS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Directions';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'Sigue todo recto y gira a la derecha en el semáforo. El museo está al lado del banco, enfrente de la plaza. No está lejos, solo cinco minutos a pie.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','How do you say "to the right"?','a la derecha',array['a la izquierda','recto','arriba'],'direction',1),
    (v_l1,'multiple_choice','How do you say "to the left"?','a la izquierda',array['a la derecha','adelante','abajo'],'direction',2),
    (v_l1,'multiple_choice','How do you say "straight ahead"?','todo recto',array['adelante','arriba','siempre'],'direction',3),
    (v_l1,'multiple_choice','How do you say "the corner"?','la esquina',array['el rincón','la curva','el ángulo'],'street feature',4),
    (v_l1,'multiple_choice','How do you say "the traffic light"?','el semáforo',array['el signo','la luz','la señal'],'street feature',5),
    (v_l2,'fill_blank','Complete: "Sigue ___ recto." (all)','todo',array['toda','muy','solo'],'todo recto',1),
    (v_l2,'fill_blank','Complete: "Gira ___ la derecha." (to)','a',array['en','de','para'],'a la derecha',2),
    (v_l2,'fill_blank','Complete: "El banco está ___ del museo." (next to)','al lado',array['enfrente','detrás','dentro'],'al lado de',3),
    (v_l2,'fill_blank','Complete: "El museo está ___ del banco." (in front of)','enfrente',array['al lado','dentro','encima'],'enfrente de',4),
    (v_l2,'fill_blank','Complete: "Está a cinco minutos ___ pie." (on)','a',array['en','de','con'],'a pie',5),
    (v_l3,'multiple_choice','Translate "¿Dónde está el banco?"','Where is the bank?',array['Where is the bus?','How is the bank?','When is the bank?'],'A2 question',1),
    (v_l3,'multiple_choice','Translate "¿Cómo llego a la plaza?"','How do I get to the plaza?',array['How is the plaza?','Where is the plaza?','When is the plaza?'],'A2 question',2),
    (v_l3,'multiple_choice','What does "está cerca" mean?','it is nearby',array['it is far','it is closed','it is open'],'distance',3),
    (v_l3,'multiple_choice','What does "está lejos" mean?','it is far',array['it is near','it is closed','it is busy'],'distance',4),
    (v_l3,'multiple_choice','Translate "Cruza la calle."','Cross the street',array['Walk the street','Take the street','Stop at the street'],'imperative',5),
    (v_l4,'listening','Listen and pick the English meaning.','gira a la derecha',array['Turn left','Turn right','Go straight'],'Turn right',1),
    (v_l4,'listening','Listen and pick the English meaning.','sigue todo recto',array['Continue straight','Go back','Stop here'],'Continue straight',2),
    (v_l4,'listening','Listen and pick the English meaning.','está cerca de aquí',array['It is far from here','It is near here','It is open here'],'It is near here',3),
    (v_l4,'listening','Listen and pick the English meaning.','enfrente del banco',array['behind the bank','in front of the bank','next to the bank'],'in front of the bank',4),
    (v_l4,'listening','Listen and pick the English meaning.','cinco minutos a pie',array['five minutes by car','five minutes on foot','fifty minutes on foot'],'five minutes on foot',5),
    (v_l5,'speaking','Say this aloud: "¿Cómo llego al museo?"','¿Cómo llego al museo?',array[]::text[],'How do I get to the museum?',1),
    (v_l5,'speaking','Say this aloud: "Gira a la derecha."','Gira a la derecha',array[]::text[],'Turn right.',2),
    (v_l5,'speaking','Say this aloud: "Sigue todo recto dos calles."','Sigue todo recto dos calles',array[]::text[],'Continue straight for two streets. (A1 review: dos)',3),
    (v_l5,'speaking','Say this aloud: "Está al lado del banco."','Está al lado del banco',array[]::text[],'It is next to the bank.',4),
    (v_l5,'speaking','Say this aloud: "Cinco minutos a pie."','Cinco minutos a pie',array[]::text[],'Five minutes on foot.',5),
    (v_l6,'multiple_choice','What direction should you turn at the traffic light?','Right',array['Left','Straight','Back'],'Gira a la derecha',1),
    (v_l6,'multiple_choice','Where is the museum?','Next to the bank',array['Behind the bank','Far from the bank','Inside the bank'],'Al lado del banco',2),
    (v_l6,'multiple_choice','What is in front of the museum?','The plaza',array['The bank','A street','A park'],'Enfrente de la plaza',3),
    (v_l6,'multiple_choice','How far is the museum?','5 minutes on foot',array['10 minutes by car','15 minutes by bus','Very far'],'Cinco minutos a pie',4),
    (v_l6,'multiple_choice','Is it far?','No',array['Yes, very','Yes, a little','Only by car'],'No está lejos',5),
    (v_l7,'fill_blank','Translate to Spanish: "Turn left."','Gira a la izquierda',array['Gira la izquierda','Va a izquierda','Gira de izquierda'],'imperative',1),
    (v_l7,'fill_blank','Translate to Spanish: "Continue straight."','Sigue todo recto',array['Sigue recto siempre','Sigue todo','Continúa derecho (LatAm)'],'todo recto',2),
    (v_l7,'fill_blank','Translate to Spanish: "It is near."','Está cerca',array['Es cerca','Está cerca de','Tiene cerca'],'estar for location',3),
    (v_l7,'fill_blank','Translate to Spanish: "How do I get there?"','¿Cómo llego ahí?',array['¿Cómo llegamos?','¿Cómo es ahí?','¿Dónde llego ahí?'],'A2 question',4),
    (v_l7,'fill_blank','Translate to Spanish: "Cross the street."','Cruza la calle',array['Camina la calle','Sigue la calle','Pasa la calle'],'imperative',5);

  -- ============== A2.6 FEELINGS & EMOTIONS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Feelings & Emotions';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'Hoy me siento muy contento porque es mi cumpleaños. Mi madre está orgullosa y mi hermano está un poco nervioso por el examen. A veces estoy triste, pero hoy todo va bien.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','How do you say "happy"?','feliz',array['triste','enfadado','cansado'],'emotion',1),
    (v_l1,'multiple_choice','How do you say "sad"?','triste',array['feliz','contento','tranquilo'],'emotion',2),
    (v_l1,'multiple_choice','How do you say "angry"?','enfadado',array['cansado','contento','aburrido'],'emotion (Spain)',3),
    (v_l1,'multiple_choice','How do you say "nervous"?','nervioso',array['tranquilo','feliz','enfermo'],'emotion',4),
    (v_l1,'multiple_choice','How do you say "proud"?','orgulloso',array['orgullo','contento','feliz'],'emotion',5),
    (v_l2,'fill_blank','Complete: "Yo ___ contento." (I am)','estoy',array['soy','tengo','va'],'estar + emotion',1),
    (v_l2,'fill_blank','Complete: "Ella ___ cansada." (is)','está',array['es','tiene','va'],'estar + emotion',2),
    (v_l2,'fill_blank','Complete: "Me ___ feliz hoy." (I feel)','siento',array['sentir','siente','sentimos'],'sentirse yo',3),
    (v_l2,'fill_blank','Complete: "¿Cómo ___ sientes?" (do you feel)','te',array['me','se','nos'],'reflexive',4),
    (v_l2,'fill_blank','Complete: "Estoy ___ por mi familia." (proud, m.)','orgulloso',array['orgullosa','orgullosos','orgullo'],'gender agreement',5),
    (v_l3,'multiple_choice','What does "me siento bien" mean?','I feel well',array['I sit well','I am alone','I am tired'],'A2 phrase',1),
    (v_l3,'multiple_choice','Translate "Estoy de buen humor."','I am in a good mood',array['I have humor','I am at work','I am hungry'],'A2 phrase',2),
    (v_l3,'multiple_choice','What does "tener miedo" mean?','to be afraid',array['to be late','to be lucky','to be ready'],'tener idiom',3),
    (v_l3,'multiple_choice','Translate "Estoy preocupado por el examen."','I am worried about the exam',array['I am happy about the exam','I have an exam tomorrow','I forgot the exam'],'A2 phrase',4),
    (v_l3,'multiple_choice','What does "estar enamorado" mean?','to be in love',array['to be sick','to be home','to be sad'],'estar + state',5),
    (v_l4,'listening','Listen and pick the English meaning.','estoy muy contento hoy',array['I am very tired today','I am very happy today','I am very angry today'],'I am very happy today',1),
    (v_l4,'listening','Listen and pick the English meaning.','me siento triste',array['I feel happy','I feel sad','I feel tired'],'I feel sad',2),
    (v_l4,'listening','Listen and pick the English meaning.','está muy nerviosa',array['She is very nervous','She is very calm','She is very angry'],'She is very nervous',3),
    (v_l4,'listening','Listen and pick the English meaning.','tengo miedo',array['I am hot','I am afraid','I am hungry'],'I am afraid',4),
    (v_l4,'listening','Listen and pick the English meaning.','estoy orgulloso de mi hijo',array['I am proud of my son','I am tired of my son','I am with my son'],'I am proud of my son (A1 review: hijo)',5),
    (v_l5,'speaking','Say this aloud: "Estoy muy contento."','Estoy muy contento',array[]::text[],'I am very happy.',1),
    (v_l5,'speaking','Say this aloud: "Me siento un poco triste."','Me siento un poco triste',array[]::text[],'I feel a little sad.',2),
    (v_l5,'speaking','Say this aloud: "Estoy nervioso por el examen."','Estoy nervioso por el examen',array[]::text[],'I am nervous about the exam.',3),
    (v_l5,'speaking','Say this aloud: "Tengo miedo de los perros."','Tengo miedo de los perros',array[]::text[],'I am afraid of dogs. (A1 review: perros)',4),
    (v_l5,'speaking','Say this aloud: "Estoy orgulloso de mi familia."','Estoy orgulloso de mi familia',array[]::text[],'I am proud of my family.',5),
    (v_l6,'multiple_choice','How does the speaker feel today?','Very happy',array['Sad','Tired','Angry'],'Muy contento',1),
    (v_l6,'multiple_choice','Why is the speaker happy?','It''s their birthday',array['Vacation','New job','Won a prize'],'Es mi cumpleaños',2),
    (v_l6,'multiple_choice','How does the mother feel?','Proud',array['Worried','Sad','Tired'],'Está orgullosa',3),
    (v_l6,'multiple_choice','How does the brother feel?','A little nervous',array['Very happy','Very angry','Calm'],'Un poco nervioso',4),
    (v_l6,'multiple_choice','Why is the brother nervous?','Because of the exam',array['Because of the birthday','Because of the family','Because of the weather'],'Por el examen',5),
    (v_l7,'fill_blank','Translate to Spanish: "I am happy."','Estoy contento',array['Soy contento','Tengo contento','Estoy contenta (f.)'],'estar + emotion',1),
    (v_l7,'fill_blank','Translate to Spanish: "I feel sad today."','Me siento triste hoy',array['Yo triste hoy','Estoy sentido triste','Hoy soy triste'],'sentirse',2),
    (v_l7,'fill_blank','Translate to Spanish: "She is nervous."','Está nerviosa',array['Es nerviosa','Tiene nervioso','Está nervioso (m.)'],'gender agreement',3),
    (v_l7,'fill_blank','Translate to Spanish: "I am afraid."','Tengo miedo',array['Estoy miedo','Soy miedo','Hago miedo'],'tener miedo idiom',4),
    (v_l7,'fill_blank','Translate to Spanish: "I am in a good mood."','Estoy de buen humor',array['Tengo buen humor','Soy buen humor','Estoy buen humor'],'A2 idiom',5);

  -- ============== A2.7 CELEBRATIONS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Celebrations';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'El sábado es el cumpleaños de mi madre. Vamos a hacer una fiesta grande en casa. Voy a comprar un regalo y una tarta. Mis hermanos van a ayudar con la comida.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','How do you say "birthday"?','cumpleaños',array['Navidad','boda','fiesta'],'celebration',1),
    (v_l1,'multiple_choice','How do you say "party"?','fiesta',array['cumpleaños','boda','regalo'],'celebration',2),
    (v_l1,'multiple_choice','How do you say "gift"?','regalo',array['fiesta','tarta','vela'],'celebration',3),
    (v_l1,'multiple_choice','How do you say "wedding"?','boda',array['cumpleaños','Navidad','fiesta'],'celebration',4),
    (v_l1,'multiple_choice','How do you say "Christmas"?','Navidad',array['Pascua','año nuevo','cumpleaños'],'holiday',5),
    (v_l2,'fill_blank','Complete: "___ a hacer una fiesta." (We are going)','Vamos',array['Voy','Vais','Van'],'ir a + infinitive future',1),
    (v_l2,'fill_blank','Complete: "Yo ___ a comprar un regalo." (am going)','voy',array['vas','va','vamos'],'ir a + infinitive',2),
    (v_l2,'fill_blank','Complete: "Ella ___ a venir mañana." (is going to)','va',array['voy','vas','van'],'ir a + infinitive 3rd person',3),
    (v_l2,'fill_blank','Complete: "Tú ___ a celebrar." (are going to)','vas',array['voy','va','van'],'ir a + infinitive tú',4),
    (v_l2,'fill_blank','Complete: "El cumpleaños ___ Ana es mañana." (of)','de',array['a','en','para'],'possession de',5),
    (v_l3,'multiple_choice','Translate "¡Feliz cumpleaños!"','Happy birthday!',array['Merry Christmas!','Happy New Year!','Congratulations!'],'wish',1),
    (v_l3,'multiple_choice','Translate "¡Felicidades!"','Congratulations!',array['Goodbye!','Welcome!','See you!'],'wish',2),
    (v_l3,'multiple_choice','What does "soplar las velas" mean?','to blow out the candles',array['to light candles','to buy candles','to count candles'],'A2 phrase',3),
    (v_l3,'multiple_choice','Translate "Vamos a brindar."','Let''s toast',array['Let''s eat','Let''s leave','Let''s sing'],'A2 phrase',4),
    (v_l3,'multiple_choice','What does "hacer una fiesta" mean?','to throw a party',array['to attend a party','to leave a party','to like a party'],'A2 phrase',5),
    (v_l4,'listening','Listen and pick the English meaning.','feliz cumpleaños',array['Merry Christmas','Happy birthday','Happy new year'],'Happy birthday',1),
    (v_l4,'listening','Listen and pick the English meaning.','vamos a hacer una fiesta',array['We had a party','We are going to throw a party','We want a party'],'We are going to throw a party',2),
    (v_l4,'listening','Listen and pick the English meaning.','te traje un regalo',array['I want a gift','I brought you a gift','I sold a gift'],'I brought you a gift',3),
    (v_l4,'listening','Listen and pick the English meaning.','mi cumpleaños es en mayo',array['My birthday is in May','My birthday is in March','My birthday is today'],'My birthday is in May (A1 review)',4),
    (v_l4,'listening','Listen and pick the English meaning.','felices fiestas',array['Happy holidays','Sad holidays','Long holidays'],'Happy holidays',5),
    (v_l5,'speaking','Say this aloud: "¡Feliz cumpleaños!"','¡Feliz cumpleaños!',array[]::text[],'Happy birthday!',1),
    (v_l5,'speaking','Say this aloud: "Vamos a hacer una fiesta el sábado."','Vamos a hacer una fiesta el sábado',array[]::text[],'We are going to throw a party on Saturday.',2),
    (v_l5,'speaking','Say this aloud: "Te he traído un regalo."','Te he traído un regalo',array[]::text[],'I have brought you a gift.',3),
    (v_l5,'speaking','Say this aloud: "Felices fiestas."','Felices fiestas',array[]::text[],'Happy holidays.',4),
    (v_l5,'speaking','Say this aloud: "Vamos a brindar por ti."','Vamos a brindar por ti',array[]::text[],'Let''s toast to you.',5),
    (v_l6,'multiple_choice','Whose birthday is it?','The mother''s',array['The brother''s','The speaker''s','The father''s'],'Cumpleaños de mi madre',1),
    (v_l6,'multiple_choice','When is the party?','Saturday',array['Sunday','Friday','Today'],'El sábado',2),
    (v_l6,'multiple_choice','Where will the party be?','At home',array['At a restaurant','At a hotel','Outdoors'],'En casa',3),
    (v_l6,'multiple_choice','What is the speaker going to buy?','A gift and a cake',array['Just a gift','Just a cake','Drinks'],'Un regalo y una tarta',4),
    (v_l6,'multiple_choice','Who will help with the food?','The siblings',array['The mother','Friends','Neighbors'],'Mis hermanos van a ayudar (A1 review: hermanos)',5),
    (v_l7,'fill_blank','Translate to Spanish: "Happy birthday!"','¡Feliz cumpleaños!',array['¡Feliz cumple!','¡Felicidades cumpleaños!','¡Feliz día!'],'standard wish',1),
    (v_l7,'fill_blank','Translate to Spanish: "We are going to throw a party."','Vamos a hacer una fiesta',array['Hacemos una fiesta','Vamos hacer fiesta','Voy a hacer una fiesta'],'ir a + infinitive',2),
    (v_l7,'fill_blank','Translate to Spanish: "My birthday is in May."','Mi cumpleaños es en mayo',array['Mi cumpleaños está en mayo','Yo cumpleaños mayo','Mi cumple mayo'],'A1 review',3),
    (v_l7,'fill_blank','Translate to Spanish: "I brought you a gift."','Te traje un regalo',array['Yo traje regalo','Yo regalo traje','Te dio un regalo'],'preterite + IO pronoun',4),
    (v_l7,'fill_blank','Translate to Spanish: "Happy holidays."','Felices fiestas',array['Feliz fiestas','Felicidades fiestas','Fiesta feliz'],'standard plural greeting',5);

  -- ============== A2.8 NATURE ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Nature';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'Cerca de mi casa hay un bosque muy grande con muchos árboles. También hay un río y una montaña pequeña. Los fines de semana voy a la playa con mis amigos. Me encanta la naturaleza.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','How do you say "tree"?','árbol',array['flor','río','planta'],'nature',1),
    (v_l1,'multiple_choice','How do you say "river"?','río',array['mar','lago','playa'],'water',2),
    (v_l1,'multiple_choice','How do you say "mountain"?','montaña',array['colina','árbol','bosque'],'landscape',3),
    (v_l1,'multiple_choice','How do you say "beach"?','playa',array['mar','río','lago'],'coastline',4),
    (v_l1,'multiple_choice','How do you say "forest"?','bosque',array['montaña','jardín','parque'],'landscape',5),
    (v_l2,'fill_blank','Complete: "___ un bosque cerca." (There is)','Hay',array['Está','Es','Tiene'],'haber impersonal',1),
    (v_l2,'fill_blank','Complete: "___ muchos árboles." (There are)','Hay',array['Son','Están','Tienen'],'haber for both sing/pl',2),
    (v_l2,'fill_blank','Complete: "Vivo ___ una montaña." (near)','cerca de',array['lejos','al lado','dentro'],'cerca de',3),
    (v_l2,'fill_blank','Complete: "La playa ___ lejos." (is)','está',array['es','tiene','hay'],'estar for location',4),
    (v_l2,'fill_blank','Complete: "Me gusta ___ naturaleza." (the)','la',array['el','los','las'],'definite article',5),
    (v_l3,'multiple_choice','What does "ir de excursión" mean?','to go hiking / on an outing',array['to go to a store','to take a nap','to stay home'],'A2 phrase',1),
    (v_l3,'multiple_choice','Translate "Me encanta la naturaleza."','I love nature',array['I have nature','I see nature','I hate nature'],'encantar',2),
    (v_l3,'multiple_choice','What does "el paisaje" mean?','the landscape',array['the village','the city','the weather'],'A2 vocab',3),
    (v_l3,'multiple_choice','Translate "Hace mucho calor en la playa."','It is very hot at the beach',array['It rains at the beach','It is windy at the beach','I am at the beach'],'A1 review + nature',4),
    (v_l3,'multiple_choice','What does "proteger el medio ambiente" mean?','to protect the environment',array['to clean the house','to study nature','to plant trees'],'A2 abstract',5),
    (v_l4,'listening','Listen and pick the English meaning.','hay un bosque cerca',array['There is a forest nearby','There is a beach nearby','There is a town nearby'],'There is a forest nearby',1),
    (v_l4,'listening','Listen and pick the English meaning.','voy a la playa los sábados',array['I go to the beach on Sundays','I go to the beach on Saturdays','I went to the beach'],'I go to the beach on Saturdays',2),
    (v_l4,'listening','Listen and pick the English meaning.','me gusta la montaña',array['I like the river','I like the mountain','I like the sea'],'I like the mountain',3),
    (v_l4,'listening','Listen and pick the English meaning.','hay muchos árboles',array['There are many flowers','There are many trees','There are many birds'],'There are many trees',4),
    (v_l4,'listening','Listen and pick the English meaning.','hace sol hoy',array['It is sunny today','It is windy today','It is cold today'],'It is sunny today (A1 review)',5),
    (v_l5,'speaking','Say this aloud: "Me encanta la naturaleza."','Me encanta la naturaleza',array[]::text[],'I love nature.',1),
    (v_l5,'speaking','Say this aloud: "Voy a la playa los fines de semana."','Voy a la playa los fines de semana',array[]::text[],'I go to the beach on weekends.',2),
    (v_l5,'speaking','Say this aloud: "Hay un río cerca de mi casa."','Hay un río cerca de mi casa',array[]::text[],'There is a river near my house.',3),
    (v_l5,'speaking','Say this aloud: "Las montañas son muy bonitas."','Las montañas son muy bonitas',array[]::text[],'The mountains are very pretty.',4),
    (v_l5,'speaking','Say this aloud: "Vamos a hacer una excursión al bosque."','Vamos a hacer una excursión al bosque',array[]::text[],'We are going on a hike in the forest.',5),
    (v_l6,'multiple_choice','What is near the speaker''s house?','A big forest',array['A small forest','A small city','A lake'],'Bosque grande',1),
    (v_l6,'multiple_choice','What other natural features are nearby?','A river and a small mountain',array['A river and a lake','A beach and a mountain','Only a river'],'Río y montaña',2),
    (v_l6,'multiple_choice','Where does the speaker go on weekends?','The beach',array['The mountain','The river','The forest'],'A la playa',3),
    (v_l6,'multiple_choice','Who does the speaker go with?','Friends',array['Family','Alone','Brother'],'Con mis amigos',4),
    (v_l6,'multiple_choice','What does the speaker think of nature?','Loves it',array['Hates it','Is bored by it','Is afraid of it'],'Me encanta la naturaleza',5),
    (v_l7,'fill_blank','Translate to Spanish: "There are many trees."','Hay muchos árboles',array['Son muchos árboles','Están muchos árboles','Tienen muchos árboles'],'haber + noun',1),
    (v_l7,'fill_blank','Translate to Spanish: "The beach is beautiful."','La playa es bonita',array['La playa está bonita','La playa son bonita','El playa es bonito'],'ser for trait',2),
    (v_l7,'fill_blank','Translate to Spanish: "I love the mountains."','Me encantan las montañas',array['Me encanta las montañas','Yo amo las montañas','Me gusta las montañas'],'encantar plural',3),
    (v_l7,'fill_blank','Translate to Spanish: "I go hiking on Sundays."','Voy de excursión los domingos',array['Voy de excursión domingos','Yo excursión domingos','Hago excursión domingo'],'A2 idiom',4),
    (v_l7,'fill_blank','Translate to Spanish: "It is sunny at the beach."','Hace sol en la playa',array['Es sol en la playa','Hay sol en la playa','Está sol en la playa'],'A1 review',5);

  -- ============== A2.9 SPORTS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Sports';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'Hago deporte tres veces a la semana. Los lunes juego al baloncesto con mis amigos y los miércoles voy al gimnasio. También me gusta correr los sábados por la mañana.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','How do you say "soccer"?','fútbol',array['baloncesto','tenis','natación'],'sport',1),
    (v_l1,'multiple_choice','How do you say "basketball"?','baloncesto',array['fútbol','tenis','golf'],'sport (Spain)',2),
    (v_l1,'multiple_choice','How do you say "swimming"?','natación',array['ciclismo','correr','tenis'],'sport',3),
    (v_l1,'multiple_choice','How do you say "cycling"?','ciclismo',array['natación','correr','tenis'],'sport',4),
    (v_l1,'multiple_choice','How do you say "to run"?','correr',array['caminar','nadar','saltar'],'verb',5),
    (v_l2,'fill_blank','Complete: "Juego ___ fútbol." (soccer)','al',array['en','a','el'],'jugar a + sport',1),
    (v_l2,'fill_blank','Complete: "___ deporte tres veces a la semana." (I do)','Hago',array['Tengo','Voy','Soy'],'hacer deporte',2),
    (v_l2,'fill_blank','Complete: "Mi hermano ___ al tenis." (plays)','juega',array['juego','jugamos','jugar'],'jugar 3rd person',3),
    (v_l2,'fill_blank','Complete: "Nosotros ___ los sábados." (run)','corremos',array['corre','corro','corren'],'correr nosotros',4),
    (v_l2,'fill_blank','Complete: "Voy ___ gimnasio." (to the)','al',array['a la','en','para'],'al = a + el',5),
    (v_l3,'multiple_choice','Translate "Voy al gimnasio."','I go to the gym',array['I am at the gym','I love the gym','I work at the gym'],'A2 phrase',1),
    (v_l3,'multiple_choice','What does "estar en forma" mean?','to be in shape',array['to be tired','to be late','to be ready'],'A2 idiom',2),
    (v_l3,'multiple_choice','Translate "Hago ejercicio cada día."','I exercise every day',array['I am sick every day','I work every day','I sleep every day'],'A2 phrase',3),
    (v_l3,'multiple_choice','What does "ganar un partido" mean?','to win a match',array['to lose a match','to play a match','to watch a match'],'A2 phrase',4),
    (v_l3,'multiple_choice','Translate "Me gusta el deporte."','I like sports',array['I do sport','I hate sport','I want sport'],'gustar + sport (A1 review)',5),
    (v_l4,'listening','Listen and pick the English meaning.','juego al fútbol los lunes',array['I play soccer on Mondays','I watched soccer on Sunday','I will play soccer'],'I play soccer on Mondays',1),
    (v_l4,'listening','Listen and pick the English meaning.','voy al gimnasio',array['I go to the gym','I left the gym','I am at the gym'],'I go to the gym',2),
    (v_l4,'listening','Listen and pick the English meaning.','hago natación dos veces a la semana',array['I swim twice a week','I swim every day','I will swim'],'I swim twice a week',3),
    (v_l4,'listening','Listen and pick the English meaning.','me gusta correr',array['I like to walk','I like to run','I hate running'],'I like to run',4),
    (v_l4,'listening','Listen and pick the English meaning.','el partido es a las cinco',array['The match is at five','The match was at five','The match was today'],'The match is at five (A1 review: cinco)',5),
    (v_l5,'speaking','Say this aloud: "Juego al fútbol los sábados."','Juego al fútbol los sábados',array[]::text[],'I play soccer on Saturdays.',1),
    (v_l5,'speaking','Say this aloud: "Voy al gimnasio dos veces a la semana."','Voy al gimnasio dos veces a la semana',array[]::text[],'I go to the gym twice a week.',2),
    (v_l5,'speaking','Say this aloud: "Me gusta correr por la mañana."','Me gusta correr por la mañana',array[]::text[],'I like to run in the morning.',3),
    (v_l5,'speaking','Say this aloud: "Hago deporte para estar en forma."','Hago deporte para estar en forma',array[]::text[],'I do sports to stay in shape.',4),
    (v_l5,'speaking','Say this aloud: "Mi equipo ganó el partido."','Mi equipo ganó el partido',array[]::text[],'My team won the match.',5),
    (v_l6,'multiple_choice','How often does the speaker exercise?','3 times a week',array['Every day','Once a week','Only weekends'],'Tres veces a la semana',1),
    (v_l6,'multiple_choice','What does the speaker do on Mondays?','Play basketball',array['Soccer','Swim','Run'],'Baloncesto',2),
    (v_l6,'multiple_choice','Who does the speaker play basketball with?','Friends',array['Family','Brother','Alone'],'Con mis amigos',3),
    (v_l6,'multiple_choice','What does the speaker do on Wednesdays?','Goes to the gym',array['Plays soccer','Runs','Stays home'],'Voy al gimnasio',4),
    (v_l6,'multiple_choice','When does the speaker run?','Saturday mornings',array['Friday nights','Sunday mornings','Every day'],'Sábados por la mañana',5),
    (v_l7,'fill_blank','Translate to Spanish: "I play soccer."','Juego al fútbol',array['Yo juego fútbol','Toco el fútbol','Juego del fútbol'],'jugar al + sport',1),
    (v_l7,'fill_blank','Translate to Spanish: "I go to the gym."','Voy al gimnasio',array['Voy a el gimnasio','Yo al gimnasio voy','Soy al gimnasio'],'a + el = al',2),
    (v_l7,'fill_blank','Translate to Spanish: "I exercise every day."','Hago ejercicio cada día',array['Yo ejercicio cada día','Hago ejercicio días','Hago ejercicio el día'],'hacer ejercicio',3),
    (v_l7,'fill_blank','Translate to Spanish: "I like to run."','Me gusta correr',array['Yo gusto correr','Me gustan correr','Me gusta corriendo'],'gustar + infinitive',4),
    (v_l7,'fill_blank','Translate to Spanish: "My team won."','Mi equipo ganó',array['Mi equipo gana','Mi equipo gano','Mi equipo ganamos'],'preterite 3rd person',5);

  -- ============== A2.10 MUSIC ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Music';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'Me encanta la música rock y el pop. Toco la guitarra desde hace cinco años. Mi grupo favorito es Maná y mi canción favorita es Rayando el sol. Mañana voy a un concierto con mi hermana.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','How do you say "singer"?','cantante',array['canción','grupo','banda'],'music person',1),
    (v_l1,'multiple_choice','How do you say "song"?','canción',array['cantante','grupo','letra'],'music',2),
    (v_l1,'multiple_choice','How do you say "band/group"?','grupo',array['cantante','concierto','canción'],'music',3),
    (v_l1,'multiple_choice','How do you say "concert"?','concierto',array['canción','grupo','álbum'],'event',4),
    (v_l1,'multiple_choice','How do you say "guitar"?','guitarra',array['piano','batería','violín'],'instrument',5),
    (v_l2,'fill_blank','Complete: "Toco ___ guitarra." (the)','la',array['al','el','en'],'tocar + instrument',1),
    (v_l2,'fill_blank','Complete: "Toco el piano ___ hace cinco años." (for)','desde',array['por','a','en'],'desde hace',2),
    (v_l2,'fill_blank','Complete: "Me gusta ___ música rock." (the)','la',array['el','un','una'],'definite article',3),
    (v_l2,'fill_blank','Complete: "Mi canción ___ es esta." (favorite)','favorita',array['favorito','favoritos','favoritas'],'gender agreement',4),
    (v_l2,'fill_blank','Complete: "Vamos ___ concierto." (to the)','al',array['a','en','para'],'al',5),
    (v_l3,'multiple_choice','Translate "Me encanta esa canción."','I love that song',array['I hate that song','I write that song','I sing that song'],'encantar',1),
    (v_l3,'multiple_choice','What does "subir el volumen" mean?','to turn up the volume',array['to lower the volume','to mute','to play music'],'A2 phrase',2),
    (v_l3,'multiple_choice','Translate "Toco la guitarra desde hace dos años."','I have been playing the guitar for two years',array['I played the guitar two years ago','I want to learn guitar','I play guitar two years from now'],'desde hace',3),
    (v_l3,'multiple_choice','What does "un concierto en vivo" mean?','a live concert',array['a recorded concert','a free concert','an outdoor concert'],'A2 phrase',4),
    (v_l3,'multiple_choice','Translate "¿Qué tipo de música te gusta?"','What kind of music do you like?',array['Which song is yours?','When do you sing?','Do you play music?'],'A2 question',5),
    (v_l4,'listening','Listen and pick the English meaning.','me encanta la música',array['I hate music','I love music','I make music'],'I love music',1),
    (v_l4,'listening','Listen and pick the English meaning.','toco la guitarra',array['I play the guitar','I sing','I dance'],'I play the guitar',2),
    (v_l4,'listening','Listen and pick the English meaning.','voy a un concierto',array['I am at a concert','I am going to a concert','I left the concert'],'I am going to a concert',3),
    (v_l4,'listening','Listen and pick the English meaning.','mi canción favorita',array['my favorite song','my favorite singer','my favorite band'],'my favorite song',4),
    (v_l4,'listening','Listen and pick the English meaning.','tengo dos hermanas',array['I have two sisters','I have two brothers','I am two'],'I have two sisters (A1 review)',5),
    (v_l5,'speaking','Say this aloud: "Me encanta la música rock."','Me encanta la música rock',array[]::text[],'I love rock music.',1),
    (v_l5,'speaking','Say this aloud: "Toco la guitarra."','Toco la guitarra',array[]::text[],'I play the guitar.',2),
    (v_l5,'speaking','Say this aloud: "Voy a un concierto mañana."','Voy a un concierto mañana',array[]::text[],'I am going to a concert tomorrow.',3),
    (v_l5,'speaking','Say this aloud: "Mi grupo favorito es Coldplay."','Mi grupo favorito es Coldplay',array[]::text[],'My favorite band is Coldplay.',4),
    (v_l5,'speaking','Say this aloud: "¿Qué tipo de música te gusta?"','¿Qué tipo de música te gusta?',array[]::text[],'What kind of music do you like?',5),
    (v_l6,'multiple_choice','What music does the speaker love?','Rock and pop',array['Only rock','Classical','Jazz'],'Rock y pop',1),
    (v_l6,'multiple_choice','How long has the speaker played guitar?','5 years',array['2 years','10 years','1 year'],'Cinco años',2),
    (v_l6,'multiple_choice','What is the speaker''s favorite band?','Maná',array['Coldplay','U2','The Beatles'],'Maná',3),
    (v_l6,'multiple_choice','What is the favorite song?','Rayando el sol',array['Color esperanza','Bailar','La camisa negra'],'Rayando el sol',4),
    (v_l6,'multiple_choice','Who is the speaker going to the concert with?','Sister',array['Friend','Brother','Alone'],'Con mi hermana (A1 review)',5),
    (v_l7,'fill_blank','Translate to Spanish: "I love rock music."','Me encanta la música rock',array['Yo amo música rock','Me gusta rock','Yo encanto música'],'encantar + def article',1),
    (v_l7,'fill_blank','Translate to Spanish: "I play the piano."','Toco el piano',array['Juego al piano','Yo piano toco','Toco al piano'],'tocar + def article',2),
    (v_l7,'fill_blank','Translate to Spanish: "I am going to a concert."','Voy a un concierto',array['Estoy a un concierto','Yo concierto voy','Voy concierto'],'ir a + indefinite',3),
    (v_l7,'fill_blank','Translate to Spanish: "My favorite song is this."','Mi canción favorita es esta',array['Mi canción favorito es esta','Mi canción favorita está esta','Mi favorita canción es esta'],'gender agreement + ser',4),
    (v_l7,'fill_blank','Translate to Spanish: "I have been playing for five years."','Toco desde hace cinco años',array['Toco por cinco años','Toco hace cinco años','Toco cinco años desde'],'desde hace',5);

  -- ============== A2.11 TRAVEL PLANNING ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Travel Planning';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'En verano voy de vacaciones a Italia con mi familia. Ya he reservado el vuelo y el hotel. Vamos a llevar dos maletas y una mochila. El viaje dura dos semanas.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','How do you say "flight"?','vuelo',array['hotel','tren','viaje'],'travel',1),
    (v_l1,'multiple_choice','How do you say "hotel"?','hotel',array['casa','hostal','vuelo'],'lodging',2),
    (v_l1,'multiple_choice','How do you say "reservation"?','reserva',array['recibo','factura','plan'],'travel',3),
    (v_l1,'multiple_choice','How do you say "luggage"?','equipaje',array['maleta','mochila','bolsa'],'travel',4),
    (v_l1,'multiple_choice','How do you say "vacation"?','vacaciones',array['fiesta','viaje','descanso'],'time off',5),
    (v_l2,'fill_blank','Complete: "Voy ___ vacaciones a Italia." (on)','de',array['a','en','para'],'idiom de vacaciones',1),
    (v_l2,'fill_blank','Complete: "He ___ el vuelo." (reserved)','reservado',array['reservar','reservé','reserva'],'present perfect',2),
    (v_l2,'fill_blank','Complete: "Voy a ___ dos maletas." (take)','llevar',array['traer','venir','llevo'],'llevar = to take with',3),
    (v_l2,'fill_blank','Complete: "El viaje ___ dos semanas." (lasts)','dura',array['duran','durar','dura un'],'durar',4),
    (v_l2,'fill_blank','Complete: "Vamos ___ avión." (by)','en',array['a','de','con'],'en + transport',5),
    (v_l3,'multiple_choice','Translate "Hacer la maleta."','to pack the suitcase',array['to buy a suitcase','to lose a suitcase','to find a suitcase'],'A2 idiom',1),
    (v_l3,'multiple_choice','What does "billete de ida y vuelta" mean?','round-trip ticket',array['one-way ticket','first class ticket','child ticket'],'travel vocab',2),
    (v_l3,'multiple_choice','Translate "Pasar la aduana."','to go through customs',array['to lose your passport','to buy gifts','to take photos'],'A2 idiom',3),
    (v_l3,'multiple_choice','What does "reservar una habitación" mean?','to book a room',array['to clean a room','to leave a room','to share a room'],'A2 phrase',4),
    (v_l3,'multiple_choice','Translate "Me gustaría viajar a Madrid."','I would like to travel to Madrid',array['I traveled to Madrid','I live in Madrid','I will travel to Madrid'],'conditional polite',5),
    (v_l4,'listening','Listen and pick the English meaning.','voy de vacaciones a italia',array['I went on vacation','I am going on vacation to Italy','I want to go to Italy'],'I am going on vacation to Italy',1),
    (v_l4,'listening','Listen and pick the English meaning.','he reservado el hotel',array['I will book the hotel','I have booked the hotel','I cancelled the hotel'],'I have booked the hotel',2),
    (v_l4,'listening','Listen and pick the English meaning.','llevo dos maletas',array['I take two suitcases','I have two backpacks','I lost two suitcases'],'I take two suitcases',3),
    (v_l4,'listening','Listen and pick the English meaning.','el vuelo dura tres horas',array['The flight lasts three hours','The flight is at three','The flight is delayed'],'The flight lasts three hours',4),
    (v_l4,'listening','Listen and pick the English meaning.','viajo con mi familia',array['I travel alone','I travel with my family','I travel for work'],'I travel with my family (A1 review)',5),
    (v_l5,'speaking','Say this aloud: "Voy de vacaciones en julio."','Voy de vacaciones en julio',array[]::text[],'I''m going on vacation in July.',1),
    (v_l5,'speaking','Say this aloud: "He reservado un hotel."','He reservado un hotel',array[]::text[],'I have booked a hotel.',2),
    (v_l5,'speaking','Say this aloud: "Quiero un billete de ida y vuelta."','Quiero un billete de ida y vuelta',array[]::text[],'I want a round-trip ticket.',3),
    (v_l5,'speaking','Say this aloud: "Mi vuelo sale a las nueve."','Mi vuelo sale a las nueve',array[]::text[],'My flight leaves at nine.',4),
    (v_l5,'speaking','Say this aloud: "Me gustaría viajar a México."','Me gustaría viajar a México',array[]::text[],'I would like to travel to Mexico.',5),
    (v_l6,'multiple_choice','When does the speaker travel?','Summer',array['Winter','Spring','Autumn'],'En verano',1),
    (v_l6,'multiple_choice','Where is the speaker going?','Italy',array['Mexico','France','Spain'],'A Italia',2),
    (v_l6,'multiple_choice','Has the flight been booked?','Yes',array['Not yet','No, cancelled','Booking next week'],'He reservado el vuelo',3),
    (v_l6,'multiple_choice','What luggage will they take?','Two suitcases and a backpack',array['One suitcase','Three suitcases','Only a backpack'],'Dos maletas y una mochila',4),
    (v_l6,'multiple_choice','How long is the trip?','2 weeks',array['1 week','3 weeks','1 month'],'Dos semanas',5),
    (v_l7,'fill_blank','Translate to Spanish: "I am going on vacation."','Voy de vacaciones',array['Voy a vacaciones','Yo vacaciones','Estoy vacaciones'],'de vacaciones',1),
    (v_l7,'fill_blank','Translate to Spanish: "I have booked a hotel."','He reservado un hotel',array['Yo reservar hotel','Reservé un hotel ayer','Reservaré un hotel'],'present perfect',2),
    (v_l7,'fill_blank','Translate to Spanish: "I want a round-trip ticket."','Quiero un billete de ida y vuelta',array['Quiero un billete ida vuelta','Yo billete ida y vuelta','Quiero el billete ir y volver'],'A2 phrase',3),
    (v_l7,'fill_blank','Translate to Spanish: "The flight lasts two hours."','El vuelo dura dos horas',array['El vuelo lleva dos horas','El vuelo está dos horas','El vuelo es dos horas'],'durar',4),
    (v_l7,'fill_blank','Translate to Spanish: "I travel with my family."','Viajo con mi familia',array['Yo viaje familia','Viajo familia','Voy con familia'],'preposition con (A1 review)',5);

  -- ============== A2.12 RESTAURANTS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Restaurants';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'El camarero nos trae el menú. De primer plato pido una sopa y de segundo, pollo con patatas. Mi amigo prefiere ensalada. Al final pedimos la cuenta y dejamos propina.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','How do you say "waiter"?','camarero',array['cliente','cocinero','jefe'],'restaurant person (Spain)',1),
    (v_l1,'multiple_choice','How do you say "menu"?','menú',array['plato','carta también','cuenta'],'restaurant doc',2),
    (v_l1,'multiple_choice','How do you say "dish/course"?','plato',array['menú','cuenta','propina'],'food item',3),
    (v_l1,'multiple_choice','How do you say "the bill"?','la cuenta',array['el menú','el plato','el camarero'],'restaurant',4),
    (v_l1,'multiple_choice','How do you say "tip"?','propina',array['precio','cuenta','dinero'],'restaurant',5),
    (v_l2,'fill_blank','Complete: "Quisiera ___ ensalada." (a, f.)','una',array['un','la','el'],'indefinite article f.',1),
    (v_l2,'fill_blank','Complete: "De primer plato ___ sopa." (I order)','pido',array['pedimos','piden','pide'],'pedir yo',2),
    (v_l2,'fill_blank','Complete: "La cuenta, ___ favor." (please)','por',array['de','a','para'],'por favor',3),
    (v_l2,'fill_blank','Complete: "Mi amigo ___ ensalada." (prefers)','prefiere',array['prefieren','prefero','prefiero'],'preferir 3rd',4),
    (v_l2,'fill_blank','Complete: "Dejamos ___ propina." (a)','una',array['un','la','el'],'una propina',5),
    (v_l3,'multiple_choice','Translate "¿Qué van a tomar?"','What are you going to have?',array['What time is it?','What is your name?','Where are you?'],'restaurant question',1),
    (v_l3,'multiple_choice','What does "estar a dieta" mean?','to be on a diet',array['to be hungry','to be full','to be sober'],'A2 idiom',2),
    (v_l3,'multiple_choice','Translate "La cuenta, por favor."','The bill, please',array['The menu, please','The dish, please','The water, please'],'A1+A2',3),
    (v_l3,'multiple_choice','What does "tener buena pinta" mean?','to look good (food)',array['to be cold','to be cheap','to be far away'],'A2 idiom',4),
    (v_l3,'multiple_choice','Translate "Está rico."','It is delicious',array['It is expensive','It is hot','It is cold'],'A2 phrase',5),
    (v_l4,'listening','Listen and pick the English meaning.','quisiera una ensalada',array['I want a salad','I would like a salad','I love salad'],'I would like a salad (polite)',1),
    (v_l4,'listening','Listen and pick the English meaning.','la cuenta por favor',array['The bill please','The menu please','Tea please'],'The bill, please',2),
    (v_l4,'listening','Listen and pick the English meaning.','de primer plato pido sopa',array['I order soup as a starter','I cooked soup','I want bread'],'I order soup as a starter',3),
    (v_l4,'listening','Listen and pick the English meaning.','está muy rico',array['It is very cheap','It is very delicious','It is very expensive'],'It is very delicious',4),
    (v_l4,'listening','Listen and pick the English meaning.','quiero agua sin gas',array['I want sparkling water','I want still water','I do not want water'],'I want still water (A1 review: agua)',5),
    (v_l5,'speaking','Say this aloud: "Quisiera una sopa, por favor."','Quisiera una sopa, por favor',array[]::text[],'I would like a soup, please.',1),
    (v_l5,'speaking','Say this aloud: "La cuenta, por favor."','La cuenta, por favor',array[]::text[],'The bill, please.',2),
    (v_l5,'speaking','Say this aloud: "¿Qué recomienda?"','¿Qué recomienda?',array[]::text[],'What do you recommend?',3),
    (v_l5,'speaking','Say this aloud: "Está muy rico."','Está muy rico',array[]::text[],'It is very delicious.',4),
    (v_l5,'speaking','Say this aloud: "Sin azúcar, por favor."','Sin azúcar, por favor',array[]::text[],'No sugar, please.',5),
    (v_l6,'multiple_choice','Who brings the menu?','The waiter',array['The chef','The friend','The owner'],'El camarero',1),
    (v_l6,'multiple_choice','What does the speaker order as a starter?','Soup',array['Salad','Chicken','Fish'],'Sopa',2),
    (v_l6,'multiple_choice','What does the speaker have as a second course?','Chicken with potatoes',array['Salad','Fish','Pasta'],'Pollo con patatas',3),
    (v_l6,'multiple_choice','What does the friend prefer?','Salad',array['Chicken','Soup','Steak'],'Ensalada',4),
    (v_l6,'multiple_choice','What do they leave at the end?','A tip',array['The receipt','A complaint','A card'],'Propina',5),
    (v_l7,'fill_blank','Translate to Spanish: "I would like a coffee."','Quisiera un café',array['Quiero un café','Yo café','Me un café'],'polite quisiera',1),
    (v_l7,'fill_blank','Translate to Spanish: "The bill, please."','La cuenta, por favor',array['El recibo, por favor','La cuenta favor','La cuenta de favor'],'restaurant phrase',2),
    (v_l7,'fill_blank','Translate to Spanish: "It is very delicious."','Está muy rico',array['Es muy rico','Está muy ricos','Es muy ricos'],'estar with state',3),
    (v_l7,'fill_blank','Translate to Spanish: "I am on a diet."','Estoy a dieta',array['Soy a dieta','Tengo dieta','Hago dieta'],'A2 idiom',4),
    (v_l7,'fill_blank','Translate to Spanish: "I want water."','Quiero agua',array['Yo agua quiero','Quiero el agua','Tengo agua'],'A1 review',5);

  -- ============== A2.13 SCHOOL ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'School';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'Estudio en la universidad. Mi asignatura favorita es historia. Tengo clase de lunes a viernes por la mañana. Mañana tengo un examen importante, así que esta noche voy a estudiar mucho.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','How do you say "teacher" (Spain, university)?','profesor',array['maestro','alumno','jefe'],'school person',1),
    (v_l1,'multiple_choice','How do you say "class"?','clase',array['escuela','tarea','examen'],'school',2),
    (v_l1,'multiple_choice','How do you say "exam"?','examen',array['clase','tarea','libro'],'school',3),
    (v_l1,'multiple_choice','How do you say "homework"?','tarea',array['examen','clase','prueba'],'school',4),
    (v_l1,'multiple_choice','How do you say "subject"?','asignatura',array['libro','clase','escuela'],'school (Spain)',5),
    (v_l2,'fill_blank','Complete: "___ historia en la universidad." (I study)','Estudio',array['Estudia','Estudiamos','Estudias'],'estudiar yo',1),
    (v_l2,'fill_blank','Complete: "Tengo clase ___ las nueve." (at)','a',array['en','de','para'],'a + time',2),
    (v_l2,'fill_blank','Complete: "Mi asignatura ___ es historia." (favorite, f.)','favorita',array['favorito','favoritos','favoritas'],'gender agreement',3),
    (v_l2,'fill_blank','Complete: "Voy a ___ mucho para el examen." (study)','estudiar',array['estudio','estudia','estudiamos'],'ir a + infinitive',4),
    (v_l2,'fill_blank','Complete: "Estudio ___ universidad." (at the)','en la',array['a la','en el','de la'],'en + def article',5),
    (v_l3,'multiple_choice','Translate "Apruebo el examen."','I pass the exam',array['I fail the exam','I take the exam','I postpone the exam'],'A2 verb',1),
    (v_l3,'multiple_choice','What does "sacar buena nota" mean?','to get a good grade',array['to take notes','to take a break','to give a class'],'A2 idiom',2),
    (v_l3,'multiple_choice','Translate "Hago los deberes."','I do the homework',array['I have homework','I want homework','I forgot the homework'],'Spain: deberes',3),
    (v_l3,'multiple_choice','What does "ir a clase" mean?','to go to class',array['to leave class','to skip class','to teach class'],'A2 phrase',4),
    (v_l3,'multiple_choice','Translate "El profesor explica la lección."','The teacher explains the lesson',array['The teacher writes the lesson','The student writes the lesson','The teacher misses the lesson'],'A2 sentence',5),
    (v_l4,'listening','Listen and pick the English meaning.','estudio en la universidad',array['I work at the university','I study at the university','I left the university'],'I study at the university',1),
    (v_l4,'listening','Listen and pick the English meaning.','tengo un examen mañana',array['I have an exam tomorrow','I had an exam yesterday','I always have exams'],'I have an exam tomorrow',2),
    (v_l4,'listening','Listen and pick the English meaning.','mi asignatura favorita es historia',array['My favorite subject is math','My favorite subject is history','I do not like history'],'My favorite subject is history',3),
    (v_l4,'listening','Listen and pick the English meaning.','hago los deberes por la tarde',array['I do homework in the afternoon','I do homework at night','I do not do homework'],'I do homework in the afternoon',4),
    (v_l4,'listening','Listen and pick the English meaning.','la clase empieza a las nueve',array['Class ends at nine','Class starts at nine','Class is short'],'Class starts at nine (A1 review: nueve)',5),
    (v_l5,'speaking','Say this aloud: "Estudio español."','Estudio español',array[]::text[],'I study Spanish.',1),
    (v_l5,'speaking','Say this aloud: "Tengo un examen el lunes."','Tengo un examen el lunes',array[]::text[],'I have an exam on Monday.',2),
    (v_l5,'speaking','Say this aloud: "Mi profesor es muy bueno."','Mi profesor es muy bueno',array[]::text[],'My teacher is very good.',3),
    (v_l5,'speaking','Say this aloud: "Voy a la universidad por la mañana."','Voy a la universidad por la mañana',array[]::text[],'I go to university in the morning.',4),
    (v_l5,'speaking','Say this aloud: "Saqué buena nota en el examen."','Saqué buena nota en el examen',array[]::text[],'I got a good grade on the exam.',5),
    (v_l6,'multiple_choice','Where does the speaker study?','At the university',array['At a school','At home','At work'],'En la universidad',1),
    (v_l6,'multiple_choice','What is the speaker''s favorite subject?','History',array['Math','Science','Art'],'Historia',2),
    (v_l6,'multiple_choice','When does the speaker have class?','Monday to Friday',array['Only Monday','Saturday and Sunday','Every day'],'De lunes a viernes',3),
    (v_l6,'multiple_choice','When is the exam?','Tomorrow',array['Today','Next week','Yesterday'],'Mañana',4),
    (v_l6,'multiple_choice','What will the speaker do tonight?','Study a lot',array['Sleep early','Go out','Watch TV'],'Voy a estudiar mucho',5),
    (v_l7,'fill_blank','Translate to Spanish: "I study at the university."','Estudio en la universidad',array['Estudio a la universidad','Yo universidad estudio','Voy a la universidad'],'estudiar en',1),
    (v_l7,'fill_blank','Translate to Spanish: "I have an exam tomorrow."','Tengo un examen mañana',array['Yo examen mañana','Tengo examen mañana','Yo tengo el examen mañana también'],'tener',2),
    (v_l7,'fill_blank','Translate to Spanish: "I do my homework."','Hago los deberes',array['Yo deberes hago','Hago tarea','Tengo deberes'],'Spain Spanish',3),
    (v_l7,'fill_blank','Translate to Spanish: "I got a good grade."','Saqué buena nota',array['Tomé buena nota','Yo nota buena','Saqué bueno nota'],'preterite',4),
    (v_l7,'fill_blank','Translate to Spanish: "Class starts at nine."','La clase empieza a las nueve',array['La clase es a las nueve','La clase comienza nueve','La clase está a las nueve'],'empezar + a las (A1 review)',5);

  -- ============== A2.14 TECHNOLOGY BASICS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Technology Basics';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'Uso el ordenador todos los días para trabajar. También miro mi móvil constantemente. Reviso el correo electrónico por la mañana. A veces tengo que cambiar la contraseña por seguridad.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','How do you say "computer" (Spain)?','ordenador',array['computadora (LatAm)','laptop','pantalla'],'tech',1),
    (v_l1,'multiple_choice','How do you say "mobile phone" (Spain)?','móvil',array['celular (LatAm)','teléfono','reloj'],'tech',2),
    (v_l1,'multiple_choice','How do you say "email"?','correo electrónico',array['mensaje','llamada','carta'],'tech',3),
    (v_l1,'multiple_choice','How do you say "password"?','contraseña',array['código','clave también','llave'],'tech security',4),
    (v_l1,'multiple_choice','How do you say "internet"?','internet',array['intranet','online','red'],'tech',5),
    (v_l2,'fill_blank','Complete: "___ el ordenador todos los días." (I use)','Uso',array['Usa','Usamos','Usan'],'usar yo',1),
    (v_l2,'fill_blank','Complete: "Reviso ___ correo electrónico." (the, m.)','el',array['la','los','las'],'def article',2),
    (v_l2,'fill_blank','Complete: "Tengo que ___ la contraseña." (change)','cambiar',array['cambia','cambio','cambié'],'tener que + inf',3),
    (v_l2,'fill_blank','Complete: "Mi hermano ___ su móvil." (uses)','usa',array['uso','usamos','usan'],'usar 3rd',4),
    (v_l2,'fill_blank','Complete: "Trabajo ___ ordenador." (with)','con',array['en','de','a'],'con',5),
    (v_l3,'multiple_choice','Translate "Mandar un mensaje."','to send a message',array['to read a message','to delete a message','to receive a message'],'A2 phrase',1),
    (v_l3,'multiple_choice','What does "descargar una aplicación" mean?','to download an app',array['to delete an app','to share an app','to like an app'],'A2 tech',2),
    (v_l3,'multiple_choice','Translate "No tengo cobertura."','I have no signal',array['I have no time','I have no charger','I have no battery'],'A2 idiom',3),
    (v_l3,'multiple_choice','What does "se ha quedado sin batería" mean?','it ran out of battery',array['it is fully charged','it is new','it does not work'],'A2 phrase',4),
    (v_l3,'multiple_choice','Translate "Conéctate al wifi."','Connect to the wifi',array['Disconnect from wifi','Find the wifi password','Buy a wifi router'],'imperative',5),
    (v_l4,'listening','Listen and pick the English meaning.','uso el ordenador',array['I broke the computer','I use the computer','I bought a computer'],'I use the computer',1),
    (v_l4,'listening','Listen and pick the English meaning.','reviso el correo electrónico',array['I write an email','I check email','I delete email'],'I check email',2),
    (v_l4,'listening','Listen and pick the English meaning.','mi móvil no tiene batería',array['My phone is new','My phone is out of battery','My phone is broken'],'My phone is out of battery',3),
    (v_l4,'listening','Listen and pick the English meaning.','no me funciona el wifi',array['The wifi is fast','The wifi does not work for me','I have wifi at home'],'The wifi does not work for me',4),
    (v_l4,'listening','Listen and pick the English meaning.','tengo que cambiar mi contraseña',array['I have to change my password','I forgot my password','I share my password'],'I have to change my password',5),
    (v_l5,'speaking','Say this aloud: "Uso el ordenador todos los días."','Uso el ordenador todos los días',array[]::text[],'I use the computer every day.',1),
    (v_l5,'speaking','Say this aloud: "Mi móvil no tiene batería."','Mi móvil no tiene batería',array[]::text[],'My mobile is out of battery.',2),
    (v_l5,'speaking','Say this aloud: "¿Cuál es la contraseña del wifi?"','¿Cuál es la contraseña del wifi?',array[]::text[],'What is the wifi password?',3),
    (v_l5,'speaking','Say this aloud: "Tengo que mandar un correo."','Tengo que mandar un correo',array[]::text[],'I have to send an email.',4),
    (v_l5,'speaking','Say this aloud: "Hoy hace mucho calor."','Hoy hace mucho calor',array[]::text[],'It is very hot today. (A1 review)',5),
    (v_l6,'multiple_choice','How often does the speaker use the computer?','Every day',array['Once a week','Never','Sometimes'],'Todos los días',1),
    (v_l6,'multiple_choice','How often does the speaker check their phone?','Constantly',array['Once a day','Once a week','Never'],'Constantemente',2),
    (v_l6,'multiple_choice','When does the speaker check email?','In the morning',array['At night','In the afternoon','Never'],'Por la mañana',3),
    (v_l6,'multiple_choice','What does the speaker sometimes change?','The password',array['The computer','The phone','The wifi'],'La contraseña',4),
    (v_l6,'multiple_choice','Why does the speaker change the password?','For security',array['For fun','By accident','For the boss'],'Por seguridad',5),
    (v_l7,'fill_blank','Translate to Spanish: "I use the computer every day."','Uso el ordenador todos los días',array['Uso computadora todos días','Yo usar ordenador','Uso ordenador todos los días'],'def article + frequency',1),
    (v_l7,'fill_blank','Translate to Spanish: "My phone is out of battery."','Mi móvil no tiene batería',array['Mi móvil sin batería','Mi celular no batería','Mi móvil está sin batería (also OK)'],'tener',2),
    (v_l7,'fill_blank','Translate to Spanish: "I have to change my password."','Tengo que cambiar mi contraseña',array['Yo cambio contraseña','Tengo cambiar contraseña','Debo cambio contraseña'],'tener que + inf',3),
    (v_l7,'fill_blank','Translate to Spanish: "I check email in the morning."','Reviso el correo por la mañana',array['Reviso correo a la mañana','Yo correo por mañana','Reviso el correo en mañana'],'por la mañana (A1 review)',4),
    (v_l7,'fill_blank','Translate to Spanish: "What is the wifi password?"','¿Cuál es la contraseña del wifi?',array['¿Qué es la contraseña wifi?','¿Cuál contraseña wifi?','¿Cuál es contraseña de wifi?'],'cuál es',5);

  -- ============== A2.15 SOCIAL MEDIA ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Social Media';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'Uso las redes sociales todos los días. Suelo publicar fotos de mis viajes en Instagram y sigo a mis amigos. A veces comento sus publicaciones. No me gusta pasar mucho tiempo en el móvil.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','How do you say "social media"?','redes sociales',array['medios sociales','red social','social media en español'],'tech',1),
    (v_l1,'multiple_choice','How do you say "to post"?','publicar',array['compartir también','postear (slang)','enviar'],'social verb',2),
    (v_l1,'multiple_choice','How do you say "to follow (someone)"?','seguir',array['mirar','observar','encontrar'],'social verb',3),
    (v_l1,'multiple_choice','How do you say "to comment"?','comentar',array['hablar','decir','opinar'],'social verb',4),
    (v_l1,'multiple_choice','How do you say "photo"?','foto',array['vídeo','imagen','dibujo'],'media',5),
    (v_l2,'fill_blank','Complete: "Uso ___ redes sociales." (the, pl.)','las',array['los','la','el'],'def article f.pl',1),
    (v_l2,'fill_blank','Complete: "Suelo ___ fotos." (post)','publicar',array['publica','publico','publican'],'soler + infinitive',2),
    (v_l2,'fill_blank','Complete: "Sigo ___ mis amigos." (personal a)','a',array['de','en','con'],'personal a',3),
    (v_l2,'fill_blank','Complete: "Comento ___ publicaciones." (their)','sus',array['su','tus','mis'],'possessive',4),
    (v_l2,'fill_blank','Complete: "No me gusta ___ mucho tiempo." (to spend)','pasar',array['paso','pasa','pasamos'],'gustar + infinitive',5),
    (v_l3,'multiple_choice','Translate "Subir una foto."','to upload a photo',array['to lower a photo','to share a photo','to delete a photo'],'A2 phrase',1),
    (v_l3,'multiple_choice','What does "dar me gusta" mean?','to like (a post)',array['to share a post','to comment','to follow'],'A2 idiom',2),
    (v_l3,'multiple_choice','Translate "Tengo muchos seguidores."','I have many followers',array['I have many friends','I follow many people','I like many things'],'A2 vocab',3),
    (v_l3,'multiple_choice','What does "estar en línea" mean?','to be online',array['to be in a line','to be busy','to be on the phone'],'A2 phrase',4),
    (v_l3,'multiple_choice','Translate "Hago una historia."','I make a story (post)',array['I tell a story','I write a story','I read a story'],'A2 social',5),
    (v_l4,'listening','Listen and pick the English meaning.','uso las redes sociales todos los días',array['I use social media every day','I use social media on weekends','I do not use social media'],'I use social media every day',1),
    (v_l4,'listening','Listen and pick the English meaning.','publico fotos en instagram',array['I save photos on Instagram','I post photos on Instagram','I delete photos on Instagram'],'I post photos on Instagram',2),
    (v_l4,'listening','Listen and pick the English meaning.','sigo a muchos amigos',array['I follow many friends','I see many friends','I have many friends'],'I follow many friends',3),
    (v_l4,'listening','Listen and pick the English meaning.','comento sus publicaciones',array['I share their posts','I comment on their posts','I read their posts'],'I comment on their posts',4),
    (v_l4,'listening','Listen and pick the English meaning.','tengo veinte años',array['I am twenty','I have twenty','I am 12'],'I am twenty (A1 review)',5),
    (v_l5,'speaking','Say this aloud: "Uso Instagram todos los días."','Uso Instagram todos los días',array[]::text[],'I use Instagram every day.',1),
    (v_l5,'speaking','Say this aloud: "Publico fotos de mis viajes."','Publico fotos de mis viajes',array[]::text[],'I post photos of my trips.',2),
    (v_l5,'speaking','Say this aloud: "Sigo a muchos amigos."','Sigo a muchos amigos',array[]::text[],'I follow many friends.',3),
    (v_l5,'speaking','Say this aloud: "¿Cuántos seguidores tienes?"','¿Cuántos seguidores tienes?',array[]::text[],'How many followers do you have?',4),
    (v_l5,'speaking','Say this aloud: "No me gusta pasar mucho tiempo en el móvil."','No me gusta pasar mucho tiempo en el móvil',array[]::text[],'I do not like to spend a lot of time on the phone.',5),
    (v_l6,'multiple_choice','How often does the speaker use social media?','Every day',array['Once a week','Rarely','Never'],'Todos los días',1),
    (v_l6,'multiple_choice','What does the speaker usually post?','Travel photos',array['Memes','Videos of food','Music'],'Fotos de mis viajes',2),
    (v_l6,'multiple_choice','Which platform does the speaker use?','Instagram',array['Twitter','TikTok','LinkedIn'],'En Instagram',3),
    (v_l6,'multiple_choice','What does the speaker do with friends'' posts?','Sometimes comments',array['Always likes','Never sees','Shares always'],'A veces comento',4),
    (v_l6,'multiple_choice','What does the speaker dislike?','Spending lots of time on the phone',array['Posting photos','Following friends','Reading comments'],'No me gusta pasar mucho tiempo en el móvil',5),
    (v_l7,'fill_blank','Translate to Spanish: "I use social media every day."','Uso las redes sociales todos los días',array['Yo redes sociales todos los días','Uso redes sociales cada día','Uso las redes sociales día'],'def article + frequency',1),
    (v_l7,'fill_blank','Translate to Spanish: "I post photos."','Publico fotos',array['Yo fotos publico','Subo fotos','Publico foto'],'simple verb',2),
    (v_l7,'fill_blank','Translate to Spanish: "I follow my friends."','Sigo a mis amigos',array['Sigo mis amigos','Yo sigo amigos','Sigo de mis amigos'],'personal a',3),
    (v_l7,'fill_blank','Translate to Spanish: "I have many followers."','Tengo muchos seguidores',array['Tengo mucho seguidores','Yo muchos seguidores','Tengo seguidores muchos'],'agreement',4),
    (v_l7,'fill_blank','Translate to Spanish: "I am tired."','Estoy cansado',array['Soy cansado','Tengo cansado','Hago cansado'],'estar + adj (A1 review)',5);

end $$;

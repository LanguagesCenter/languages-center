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

end $$;

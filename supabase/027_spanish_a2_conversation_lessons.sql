-- 027_spanish_a2_conversation_lessons.sql
-- Replaces lesson 8 of every Spanish A2 section (currently the "Coming Soon"
-- podcast placeholder) with a CONVERSATION INTERPRETATION lesson.
--
-- Each lesson 8 contains:
--   - A short realistic dialogue or scenario that uses all the vocabulary
--     and grammar from lessons 1-7 of the same section
--   - 6 comprehension exercises mixing multiple_choice, true/false
--     (rendered as multiple_choice with True/False), and short-answer
--     fill_blank questions about the dialogue
--
-- The dialogue is stored in the existing `dialogue` jsonb column so
-- LessonClient renders it with the existing TTS / reveal-translation UI.
-- The type column is set to 'conversation' (added by migration 021).
-- Idempotent: rewrites lesson 8 and deletes/recreates its exercises.

do $$
declare
  v_lang_id   bigint;
  v_course_id bigint;
  v_l8        bigint;
begin
  select id into v_lang_id from public.languages where code = 'spanish';

  -- ============== A2.1 DAILY ROUTINES ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Daily Routines';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Daily Routines — Conversation Practice',
    description = 'Listen to two colleagues comparing their morning routines, then answer the comprehension questions.',
    intro = 'Two colleagues meet at the coffee machine and compare their morning routines. Use everything you learned about reflexive verbs and time expressions to follow along.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Ana","spanish":"Buenos días, Carlos. ¡Qué cansada estoy!","english":"Good morning, Carlos. I''m so tired!"},
      {"speaker":"Carlos","spanish":"¿A qué hora te despiertas?","english":"What time do you wake up?"},
      {"speaker":"Ana","spanish":"Me despierto a las seis y media. Después me ducho y desayuno tostadas.","english":"I wake up at six thirty. Then I shower and have toast for breakfast."},
      {"speaker":"Carlos","spanish":"Yo me levanto a las siete. Normalmente desayuno solo café.","english":"I get up at seven. I usually only have coffee for breakfast."},
      {"speaker":"Ana","spanish":"¿Cómo vas al trabajo?","english":"How do you go to work?"},
      {"speaker":"Carlos","spanish":"Voy en metro. Empiezo a las nueve.","english":"I go by metro. I start at nine."},
      {"speaker":"Ana","spanish":"Yo empiezo a las ocho. Por eso estoy tan cansada.","english":"I start at eight. That''s why I''m so tired."},
      {"speaker":"Carlos","spanish":"Pero terminas pronto, ¿no?","english":"But you finish early, right?"},
      {"speaker":"Ana","spanish":"Sí, a las cuatro. Luego voy al gimnasio.","english":"Yes, at four. Then I go to the gym."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','What time does Ana wake up?','6:30',array['7:00','8:00','5:30'],'Me despierto a las seis y media',1),
    (v_l8,'multiple_choice','What does Ana have for breakfast?','Toast',array['Only coffee','Cereal','Nothing'],'Desayuno tostadas',2),
    (v_l8,'multiple_choice','How does Carlos get to work?','By metro',array['By bus','By car','On foot'],'Voy en metro',3),
    (v_l8,'multiple_choice','True or false: Ana finishes work at 4 PM.','True',array['False'],'Sí, a las cuatro',4),
    (v_l8,'fill_blank','Complete: "Yo ____ a las siete." (I get up — Carlos''s line)','me levanto',array['me despierto','me ducho','me acuesto'],'I get up',5),
    (v_l8,'multiple_choice','What does Ana do after work?','Goes to the gym',array['Goes home','Visits Carlos','Sleeps'],'Luego voy al gimnasio',6);

  -- ============== A2.2 HEALTH & BODY ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Health & Body';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Health & Body — Conversation Practice',
    description = 'A patient visits the doctor with classic A2 symptoms. Follow the consultation and answer the questions.',
    intro = 'A doctor''s consultation that uses DOLER, TENER + symptom and ESTAR + adjective. Pay attention to the symptoms and the doctor''s advice.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Médica","spanish":"Buenos días. ¿Qué le pasa?","english":"Good morning. What''s wrong with you?"},
      {"speaker":"Paciente","spanish":"Hace tres días que me siento muy mal.","english":"I''ve been feeling very bad for three days."},
      {"speaker":"Médica","spanish":"¿Qué le duele exactamente?","english":"What hurts exactly?"},
      {"speaker":"Paciente","spanish":"Me duele mucho la garganta y la cabeza.","english":"My throat and head hurt a lot."},
      {"speaker":"Médica","spanish":"¿Tiene fiebre?","english":"Do you have a fever?"},
      {"speaker":"Paciente","spanish":"Sí, treinta y nueve grados. También estoy muy cansado.","english":"Yes, thirty-nine degrees. I''m also very tired."},
      {"speaker":"Médica","spanish":"Es una gripe. Le receto unas pastillas y un jarabe.","english":"It''s the flu. I''ll prescribe you some pills and a syrup."},
      {"speaker":"Paciente","spanish":"¿Tomo las pastillas tres veces al día?","english":"Do I take the pills three times a day?"},
      {"speaker":"Médica","spanish":"Sí, después de comer. Y descanse en casa.","english":"Yes, after eating. And rest at home."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','How long has the patient felt bad?','Three days',array['Three weeks','One day','Two months'],'Hace tres días',1),
    (v_l8,'multiple_choice','What hurts the patient?','Throat and head',array['Throat and stomach','Head and feet','Eyes and back'],'la garganta y la cabeza',2),
    (v_l8,'multiple_choice','What is the patient''s temperature?','39 degrees',array['37 degrees','38 degrees','40 degrees'],'treinta y nueve grados',3),
    (v_l8,'multiple_choice','True or false: The doctor says it''s a cold (resfriado).','False',array['True'],'Es una gripe',4),
    (v_l8,'fill_blank','Complete: "Me ____ la garganta." (hurts — singular)','duele',array['duelen','dolor','duela'],'hurts',5),
    (v_l8,'multiple_choice','When does the patient take the pills?','After eating',array['Before sleeping','Only in the morning','With water'],'después de comer',6);

  -- ============== A2.3 HOBBIES ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Hobbies';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Hobbies — Conversation Practice',
    description = 'Two friends compare what they like to do in their free time.',
    intro = 'A conversation between two students at a café. They use ME GUSTA, ME ENCANTA and PREFIERO with infinitives.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Sofía","spanish":"¿Qué te gusta hacer en tu tiempo libre?","english":"What do you like to do in your free time?"},
      {"speaker":"David","spanish":"Sobre todo me encanta cocinar. Y los fines de semana toco la guitarra.","english":"Above all I love to cook. And on weekends I play the guitar."},
      {"speaker":"Sofía","spanish":"¡Qué bien! Yo prefiero leer.","english":"How nice! I prefer to read."},
      {"speaker":"David","spanish":"¿Qué tipo de libros?","english":"What kind of books?"},
      {"speaker":"Sofía","spanish":"Sobre todo novelas. También me gusta viajar.","english":"Above all novels. I also like to travel."},
      {"speaker":"David","spanish":"¿Haces deporte?","english":"Do you do any sport?"},
      {"speaker":"Sofía","spanish":"Sí, salgo a correr tres veces a la semana.","english":"Yes, I go out running three times a week."},
      {"speaker":"David","spanish":"Yo detesto correr. Prefiero ver películas.","english":"I hate to run. I prefer to watch films."},
      {"speaker":"Sofía","spanish":"Cada uno tiene su estilo.","english":"Everyone has their style."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','What does David love to do?','Cook',array['Read','Run','Travel'],'me encanta cocinar',1),
    (v_l8,'multiple_choice','What instrument does David play?','Guitar',array['Piano','Violin','Drums'],'toco la guitarra',2),
    (v_l8,'multiple_choice','What kind of books does Sofía read?','Novels',array['Poetry','Cookbooks','Comics'],'Sobre todo novelas',3),
    (v_l8,'multiple_choice','True or false: David likes to run.','False',array['True'],'Yo detesto correr',4),
    (v_l8,'fill_blank','Complete: "Salgo a ____ tres veces a la semana." (run)','correr',array['correo','corres','corro'],'to run',5),
    (v_l8,'multiple_choice','What does David prefer instead of running?','Watching films',array['Cooking','Playing music','Reading'],'Prefiero ver películas',6);

  -- ============== A2.4 WORK & JOBS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Work & Jobs';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Work & Jobs — Conversation Practice',
    description = 'A job interview at a Spanish tech company. Listen and answer.',
    intro = 'A brief job interview using profession nouns, TRABAJAR DE / EN, schedule expressions and ESTAR + adjective for feelings.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Entrevistadora","spanish":"Buenos días. ¿En qué trabaja ahora?","english":"Good morning. What do you do now?"},
      {"speaker":"Candidato","spanish":"Soy programador en una pequeña empresa.","english":"I am a programmer at a small company."},
      {"speaker":"Entrevistadora","spanish":"¿Cuál es su horario actual?","english":"What is your current schedule?"},
      {"speaker":"Candidato","spanish":"De nueve a seis, a tiempo completo.","english":"From nine to six, full time."},
      {"speaker":"Entrevistadora","spanish":"¿Por qué quiere cambiar de trabajo?","english":"Why do you want to change jobs?"},
      {"speaker":"Candidato","spanish":"Busco un puesto con más responsabilidad.","english":"I''m looking for a position with more responsibility."},
      {"speaker":"Entrevistadora","spanish":"Aquí va a trabajar en un equipo grande. ¿Le gusta?","english":"Here you''ll work on a big team. Do you like that?"},
      {"speaker":"Candidato","spanish":"Sí, me encanta. En mi trabajo actual soy responsable de pocas personas.","english":"Yes, I love it. In my current job I''m in charge of few people."},
      {"speaker":"Entrevistadora","spanish":"Perfecto. Le envío un correo la próxima semana.","english":"Perfect. I''ll send you an email next week."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','What is the candidate''s current profession?','Programmer',array['Engineer','Designer','Teacher'],'Soy programador',1),
    (v_l8,'multiple_choice','What is his current schedule?','9 to 6 full time',array['9 to 5 part time','Variable hours','Night shifts'],'De nueve a seis, a tiempo completo',2),
    (v_l8,'multiple_choice','Why does he want to change jobs?','For more responsibility',array['For more money','For shorter hours','For a closer office'],'con más responsabilidad',3),
    (v_l8,'multiple_choice','True or false: He''s in charge of many people now.','False',array['True'],'soy responsable de pocas personas',4),
    (v_l8,'fill_blank','Complete: "Soy ____ en una pequeña empresa." (programmer)','programador',array['programadora','programar','programa'],'programmer (m.)',5),
    (v_l8,'multiple_choice','When will the interviewer reply?','Next week',array['Tomorrow','In one month','Today'],'la próxima semana',6);

  -- ============== A2.5 DIRECTIONS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Directions';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Directions — Conversation Practice',
    description = 'A tourist asks a local how to get to the train station.',
    intro = 'A tourist needs to find the train station. The local uses commands (gira, sigue, cruza) and prepositions of place (al lado de, enfrente de).',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Turista","spanish":"Perdone, ¿cómo llego a la estación de tren?","english":"Excuse me, how do I get to the train station?"},
      {"speaker":"Local","spanish":"Es bastante fácil. Sigue todo recto por esta calle.","english":"It''s pretty easy. Keep going straight on this street."},
      {"speaker":"Turista","spanish":"¿Y luego?","english":"And then?"},
      {"speaker":"Local","spanish":"En el segundo semáforo, gira a la derecha.","english":"At the second traffic light, turn right."},
      {"speaker":"Turista","spanish":"¿Es lejos?","english":"Is it far?"},
      {"speaker":"Local","spanish":"No, a unos diez minutos a pie. Cruza la plaza grande.","english":"No, about ten minutes on foot. Cross the big square."},
      {"speaker":"Turista","spanish":"¿La estación está en la plaza?","english":"Is the station on the square?"},
      {"speaker":"Local","spanish":"No, está enfrente del museo, al lado de un café.","english":"No, it''s across from the museum, next to a café."},
      {"speaker":"Turista","spanish":"Muchas gracias, muy amable.","english":"Thank you very much, very kind."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','Where does the tourist want to go?','The train station',array['The museum','The plaza','The café'],'la estación de tren',1),
    (v_l8,'multiple_choice','At which traffic light does the tourist turn?','The second',array['The first','The third','The fourth'],'En el segundo semáforo',2),
    (v_l8,'multiple_choice','In which direction does the tourist turn?','Right',array['Left','Around','Straight'],'gira a la derecha',3),
    (v_l8,'multiple_choice','How long does it take on foot?','About 10 minutes',array['About 5 minutes','About 20 minutes','About 1 hour'],'a unos diez minutos a pie',4),
    (v_l8,'fill_blank','Complete: "Cruza la ____ grande." (square)','plaza',array['calle','avenida','rotonda'],'square',5),
    (v_l8,'multiple_choice','Where is the station?','Across from the museum',array['Inside the plaza','Behind the café','In the museum'],'enfrente del museo',6);

  -- ============== A2.6 FEELINGS & EMOTIONS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Feelings & Emotions';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Feelings & Emotions — Conversation Practice',
    description = 'Two friends check in on each other''s feelings after a long week.',
    intro = 'A check-in conversation between two friends. ESTAR + adjective, SENTIRSE, PORQUE, and frequency adverbs are everywhere.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Lucía","spanish":"Hola, Pedro. ¿Cómo te sientes hoy?","english":"Hi, Pedro. How do you feel today?"},
      {"speaker":"Pedro","spanish":"Hoy estoy de mal humor.","english":"Today I''m in a bad mood."},
      {"speaker":"Lucía","spanish":"¿Por qué? ¿Qué te pasa?","english":"Why? What''s wrong?"},
      {"speaker":"Pedro","spanish":"Tengo mucho trabajo y estoy nervioso por una reunión importante.","english":"I have a lot of work and I''m nervous about an important meeting."},
      {"speaker":"Lucía","spanish":"Tranquilo, todo va a salir bien.","english":"Calm down, everything will go well."},
      {"speaker":"Pedro","spanish":"Gracias. ¿Y tú? ¿Cómo estás?","english":"Thanks. And you? How are you?"},
      {"speaker":"Lucía","spanish":"Hoy estoy muy contenta. Mañana salgo de vacaciones.","english":"Today I''m very happy. Tomorrow I leave on holiday."},
      {"speaker":"Pedro","spanish":"¡Qué suerte! Yo siempre estoy cansado los viernes.","english":"How lucky! I''m always tired on Fridays."},
      {"speaker":"Lucía","spanish":"Tienes que descansar este fin de semana.","english":"You have to rest this weekend."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','How does Pedro feel today?','In a bad mood',array['Very happy','Excited','Relaxed'],'estoy de mal humor',1),
    (v_l8,'multiple_choice','Why is Pedro nervous?','An important meeting',array['An exam','A trip','A date'],'una reunión importante',2),
    (v_l8,'multiple_choice','How does Lucía feel today?','Very happy',array['Tired','Sad','Worried'],'estoy muy contenta',3),
    (v_l8,'multiple_choice','True or false: Lucía is going on vacation tomorrow.','True',array['False'],'Mañana salgo de vacaciones',4),
    (v_l8,'fill_blank','Complete: "Estoy ____ por la reunión." (nervous)','nervioso',array['nerviosa','nervios','nerviosos'],'nervous (m.)',5),
    (v_l8,'multiple_choice','When is Pedro usually tired?','Fridays',array['Mondays','Weekends','Every day'],'siempre estoy cansado los viernes',6);

  -- ============== A2.7 CELEBRATIONS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Celebrations';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Celebrations — Conversation Practice',
    description = 'Two friends plan a surprise birthday party.',
    intro = 'A planning conversation full of IR A + INFINITIVE for near-future plans, and the key celebration vocabulary.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Marta","spanish":"El sábado es el cumpleaños de Laura.","english":"Saturday is Laura''s birthday."},
      {"speaker":"Jorge","spanish":"¿Vamos a hacer una fiesta sorpresa?","english":"Are we going to throw a surprise party?"},
      {"speaker":"Marta","spanish":"Sí. Vamos a invitar a veinte amigos.","english":"Yes. We''re going to invite twenty friends."},
      {"speaker":"Jorge","spanish":"Yo voy a preparar la comida.","english":"I''ll prepare the food."},
      {"speaker":"Marta","spanish":"Perfecto. Yo voy a comprar la tarta y los regalos.","english":"Perfect. I''ll buy the cake and the gifts."},
      {"speaker":"Jorge","spanish":"¿A qué hora empieza?","english":"What time does it start?"},
      {"speaker":"Marta","spanish":"A las nueve. Va a haber música y vamos a bailar hasta tarde.","english":"At nine. There''s going to be music and we''ll dance until late."},
      {"speaker":"Jorge","spanish":"¡Va a ser genial!","english":"It''s going to be great!"},
      {"speaker":"Marta","spanish":"Sí. ¡Y Laura no sabe nada!","english":"Yes. And Laura doesn''t know a thing!"}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','Whose birthday is it?','Laura''s',array['Marta''s','Jorge''s','Pedro''s"'],'el cumpleaños de Laura',1),
    (v_l8,'multiple_choice','What kind of party is it?','A surprise party',array['A small dinner','A birthday brunch','A picnic'],'una fiesta sorpresa',2),
    (v_l8,'multiple_choice','How many guests are invited?','20',array['10','15','30'],'veinte amigos',3),
    (v_l8,'multiple_choice','Who is buying the cake?','Marta',array['Jorge','Laura','Pedro'],'Yo voy a comprar la tarta',4),
    (v_l8,'fill_blank','Complete: "Vamos ____ bailar hasta tarde." (to)','a',array['de','en','con'],'to (ir a + inf.)',5),
    (v_l8,'multiple_choice','True or false: Laura knows about the party.','False',array['True'],'Laura no sabe nada',6);

  -- ============== A2.8 NATURE ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Nature';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Nature — Conversation Practice',
    description = 'Two friends plan a weekend trip to the mountains.',
    intro = 'A weekend-trip conversation with comparatives, prepositions of place and lots of nature vocab.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Elena","spanish":"¿Quieres ir a la montaña este fin de semana?","english":"Do you want to go to the mountain this weekend?"},
      {"speaker":"Iván","spanish":"Sí, me encanta hacer senderismo.","english":"Yes, I love hiking."},
      {"speaker":"Elena","spanish":"Hay un parque nacional con un lago precioso.","english":"There''s a national park with a beautiful lake."},
      {"speaker":"Iván","spanish":"¿Está lejos?","english":"Is it far?"},
      {"speaker":"Elena","spanish":"A dos horas en coche. El paisaje es más bonito que en la playa.","english":"Two hours by car. The landscape is prettier than at the beach."},
      {"speaker":"Iván","spanish":"¿Hay un bosque grande?","english":"Is there a big forest?"},
      {"speaker":"Elena","spanish":"Sí, enorme. Y muchos animales protegidos.","english":"Yes, huge. And many protected animals."},
      {"speaker":"Iván","spanish":"¿Podemos acampar?","english":"Can we camp?"},
      {"speaker":"Elena","spanish":"Sí, hay una zona al lado del río.","english":"Yes, there''s an area next to the river."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','Where do they want to go?','The mountain',array['The beach','The city','The desert'],'a la montaña',1),
    (v_l8,'multiple_choice','What activity does Iván love?','Hiking',array['Swimming','Skiing','Cycling'],'hacer senderismo',2),
    (v_l8,'multiple_choice','How far is the park by car?','2 hours',array['1 hour','4 hours','6 hours'],'A dos horas en coche',3),
    (v_l8,'multiple_choice','True or false: Elena says the landscape is prettier than at the beach.','True',array['False'],'más bonito que en la playa',4),
    (v_l8,'fill_blank','Complete: "Podemos acampar al lado ____ río." (of the)','del',array['de la','de el','del las'],'of the',5),
    (v_l8,'multiple_choice','What is at the park besides the lake and forest?','Protected animals',array['A restaurant','A village','A castle'],'muchos animales protegidos',6);

  -- ============== A2.9 SPORTS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Sports';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Sports — Conversation Practice',
    description = 'A reporter interviews a young basketball player after a championship match.',
    intro = 'A post-match sports interview. Look for JUGAR A + sport, ENTRENAR, GANAR / PERDER and team vocabulary.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Periodista","spanish":"¡Felicidades por el partido!","english":"Congratulations on the match!"},
      {"speaker":"Jugadora","spanish":"Gracias. Estoy muy contenta.","english":"Thanks. I''m very happy."},
      {"speaker":"Periodista","spanish":"Marcaste muchos puntos hoy.","english":"You scored many points today."},
      {"speaker":"Jugadora","spanish":"Sí, ganamos por veinte puntos.","english":"Yes, we won by twenty points."},
      {"speaker":"Periodista","spanish":"¿Cuántas veces entrenas a la semana?","english":"How many times a week do you train?"},
      {"speaker":"Jugadora","spanish":"Entreno cinco veces a la semana en el gimnasio.","english":"I train five times a week at the gym."},
      {"speaker":"Periodista","spanish":"¿Y los partidos?","english":"And the matches?"},
      {"speaker":"Jugadora","spanish":"Jugamos al baloncesto los sábados.","english":"We play basketball on Saturdays."},
      {"speaker":"Periodista","spanish":"¡Son los campeones de la liga!","english":"You''re the league champions!"}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','What sport does she play?','Basketball',array['Football','Tennis','Volleyball'],'Jugamos al baloncesto',1),
    (v_l8,'multiple_choice','By how many points did her team win?','20',array['10','15','30'],'ganamos por veinte puntos',2),
    (v_l8,'multiple_choice','How often does she train?','5 times a week',array['2 times a week','3 times a week','Every day'],'cinco veces a la semana',3),
    (v_l8,'multiple_choice','Where does she train?','At the gym',array['At the stadium','At home','At the park'],'en el gimnasio',4),
    (v_l8,'fill_blank','Complete: "Jugamos ____ baloncesto." (to the / at)','al',array['en','con','de'],'to the (a + el)',5),
    (v_l8,'multiple_choice','True or false: They are the league champions.','True',array['False'],'Son los campeones de la liga',6);

  -- ============== A2.10 MUSIC ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Music';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Music — Conversation Practice',
    description = 'Two friends compare music tastes and plan to attend a concert.',
    intro = 'A music conversation that uses GUSTAR + MUCHO / UN POCO / NADA, SABER + INFINITIVE, and concert vocabulary.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Carla","spanish":"¿Te gusta la música clásica?","english":"Do you like classical music?"},
      {"speaker":"Bruno","spanish":"Me gusta un poco. Prefiero el rock.","english":"I like it a little. I prefer rock."},
      {"speaker":"Carla","spanish":"A mí me encanta el flamenco. ¿Sabes tocar algún instrumento?","english":"I love flamenco. Do you know how to play any instrument?"},
      {"speaker":"Bruno","spanish":"Sé tocar la guitarra desde niño.","english":"I''ve played the guitar since I was a kid."},
      {"speaker":"Carla","spanish":"¡Qué bien! Yo no sé tocar nada.","english":"How nice! I can''t play anything."},
      {"speaker":"Bruno","spanish":"Pero cantas bien, ¿no?","english":"But you sing well, right?"},
      {"speaker":"Carla","spanish":"Más o menos. Oye, ¿vas al concierto de Rosalía?","english":"More or less. Hey, are you going to the Rosalía concert?"},
      {"speaker":"Bruno","spanish":"Sí, ya compré dos entradas.","english":"Yes, I already bought two tickets."},
      {"speaker":"Carla","spanish":"¡Genial! Vamos juntos.","english":"Great! Let''s go together."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','What music does Bruno prefer?','Rock',array['Classical','Flamenco','Pop'],'Prefiero el rock',1),
    (v_l8,'multiple_choice','What music does Carla love?','Flamenco',array['Reggaeton','Jazz','Rock'],'me encanta el flamenco',2),
    (v_l8,'multiple_choice','What instrument does Bruno play?','Guitar',array['Piano','Drums','Violin'],'Sé tocar la guitarra',3),
    (v_l8,'multiple_choice','True or false: Carla knows how to play an instrument.','False',array['True'],'Yo no sé tocar nada',4),
    (v_l8,'fill_blank','Complete: "Ya ____ dos entradas." (I bought)','compré',array['compra','compro','compraba'],'I bought',5),
    (v_l8,'multiple_choice','Whose concert are they going to?','Rosalía',array['Bad Bunny','Vetusta Morla','Manu Chao'],'el concierto de Rosalía',6);

  -- ============== A2.11 TRAVEL PLANNING ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Travel Planning';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Travel Planning — Conversation Practice',
    description = 'A customer books a trip at a travel agency in Madrid.',
    intro = 'A travel-agency exchange with IR A + INFINITIVE, PARA + destination, and all the booking vocabulary.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Cliente","spanish":"Buenos días. Quiero reservar un vuelo a Roma.","english":"Good morning. I want to book a flight to Rome."},
      {"speaker":"Agente","spanish":"¿Para cuándo?","english":"For when?"},
      {"speaker":"Cliente","spanish":"Para el quince de julio.","english":"For July fifteenth."},
      {"speaker":"Agente","spanish":"¿De ida y vuelta?","english":"Round trip?"},
      {"speaker":"Cliente","spanish":"Sí, vuelvo el día veintidós.","english":"Yes, I return on the 22nd."},
      {"speaker":"Agente","spanish":"¿Cuántas personas?","english":"How many people?"},
      {"speaker":"Cliente","spanish":"Dos. También necesito un hotel cerca del centro.","english":"Two. I also need a hotel near the centre."},
      {"speaker":"Agente","spanish":"Tengo uno con desayuno por ochenta euros la noche.","english":"I have one with breakfast for eighty euros a night."},
      {"speaker":"Cliente","spanish":"Perfecto. Lo reservo.","english":"Perfect. I''ll book it."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','Where is the customer flying to?','Rome',array['Madrid','Paris','London'],'un vuelo a Roma',1),
    (v_l8,'multiple_choice','What date does the trip start?','July 15',array['July 22','June 15','August 5'],'el quince de julio',2),
    (v_l8,'multiple_choice','When does the customer return?','July 22',array['July 15','July 30','August 1'],'vuelvo el día veintidós',3),
    (v_l8,'multiple_choice','How many people are traveling?','2',array['1','3','4'],'Dos',4),
    (v_l8,'fill_blank','Complete: "Un hotel cerca ____ centro." (of the)','del',array['de la','de el','en el'],'of the',5),
    (v_l8,'multiple_choice','How much is the hotel per night?','80 euros',array['100 euros','50 euros','120 euros'],'ochenta euros la noche',6);

  -- ============== A2.12 RESTAURANTS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Restaurants';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Restaurants — Conversation Practice',
    description = 'A couple orders a Spanish menu del día at a restaurant.',
    intro = 'A classic restaurant exchange: the menú del día, de primero / de segundo / de postre, and the bill.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Camarero","spanish":"Buenas tardes. ¿Tienen reserva?","english":"Good afternoon. Do you have a reservation?"},
      {"speaker":"Cliente","spanish":"Sí, una mesa para dos a nombre de López.","english":"Yes, a table for two under López."},
      {"speaker":"Camarero","spanish":"Por aquí. Aquí está la carta.","english":"This way. Here is the menu."},
      {"speaker":"Clienta","spanish":"De primero quiero la ensalada.","english":"As a starter I want the salad."},
      {"speaker":"Cliente","spanish":"Para mí, sopa. De segundo, paella, por favor.","english":"For me, soup. As a main, paella, please."},
      {"speaker":"Camarero","spanish":"¿Y para beber?","english":"And to drink?"},
      {"speaker":"Clienta","spanish":"Una botella de agua sin gas.","english":"A bottle of still water."},
      {"speaker":"Cliente","spanish":"Y una copa de vino tinto.","english":"And a glass of red wine."},
      {"speaker":"Camarero","spanish":"Perfecto. ¿Quieren postre?","english":"Perfect. Would you like dessert?"},
      {"speaker":"Cliente","spanish":"De postre, helado para los dos. Y la cuenta, por favor.","english":"For dessert, ice cream for both. And the bill, please."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','How many people is the table for?','2',array['1','3','4'],'una mesa para dos',1),
    (v_l8,'multiple_choice','What does the female customer order as a starter?','Salad',array['Soup','Bread','Cheese'],'De primero quiero la ensalada',2),
    (v_l8,'multiple_choice','What does the male customer order as a main?','Paella',array['Salad','Steak','Fish'],'De segundo, paella',3),
    (v_l8,'multiple_choice','True or false: They order sparkling water.','False',array['True'],'agua sin gas',4),
    (v_l8,'fill_blank','Complete: "Una copa ____ vino tinto." (of)','de',array['en','para','con'],'of',5),
    (v_l8,'multiple_choice','What do they order for dessert?','Ice cream',array['Cake','Fruit','Coffee'],'helado para los dos',6);

  -- ============== A2.13 SCHOOL ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'School';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'School — Conversation Practice',
    description = 'Two students compare their school day.',
    intro = 'A student-to-student chat about subjects, exams and homework. Lots of TENER QUE, EMPEZAR / TERMINAR and grades.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Marta","spanish":"¿Cuál es tu asignatura favorita?","english":"What''s your favorite subject?"},
      {"speaker":"Diego","spanish":"Mi favorita es la historia. ¿Y la tuya?","english":"Mine is history. And yours?"},
      {"speaker":"Marta","spanish":"A mí me gusta más el inglés.","english":"I prefer English."},
      {"speaker":"Diego","spanish":"¿Tienes muchos deberes hoy?","english":"Do you have a lot of homework today?"},
      {"speaker":"Marta","spanish":"Sí, tengo que estudiar para un examen de matemáticas.","english":"Yes, I have to study for a math exam."},
      {"speaker":"Diego","spanish":"¿Cuándo es?","english":"When is it?"},
      {"speaker":"Marta","spanish":"El viernes. Necesito sacar buena nota.","english":"Friday. I need to get a good grade."},
      {"speaker":"Diego","spanish":"En el último examen saqué un nueve.","english":"On the last exam I got a nine."},
      {"speaker":"Marta","spanish":"¡Qué bien! Yo suspendí.","english":"How great! I failed."},
      {"speaker":"Diego","spanish":"Tranquila. Te ayudo a estudiar.","english":"Don''t worry. I''ll help you study."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','What is Diego''s favorite subject?','History',array['English','Math','Science'],'Mi favorita es la historia',1),
    (v_l8,'multiple_choice','What is Marta''s favorite subject?','English',array['History','Math','Art'],'me gusta más el inglés',2),
    (v_l8,'multiple_choice','When is the math exam?','Friday',array['Monday','Wednesday','Tomorrow'],'El viernes',3),
    (v_l8,'multiple_choice','What grade did Diego get on the last exam?','9',array['7','10','8'],'saqué un nueve',4),
    (v_l8,'fill_blank','Complete: "Tengo ____ estudiar." (have to)','que',array['de','en','para'],'have to',5),
    (v_l8,'multiple_choice','True or false: Marta failed her last exam.','True',array['False'],'Yo suspendí',6);

  -- ============== A2.14 TECHNOLOGY BASICS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Technology Basics';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Technology Basics — Conversation Practice',
    description = 'A customer brings a broken laptop to a small tech shop.',
    intro = 'A short tech-support exchange. Watch for NO FUNCIONA, PUEDO + INFINITIVE and the most common device nouns.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Cliente","spanish":"Hola, mi ordenador no funciona.","english":"Hi, my computer isn''t working."},
      {"speaker":"Técnico","spanish":"¿Cuál es el problema?","english":"What''s the problem?"},
      {"speaker":"Cliente","spanish":"La pantalla está negra y no puedo encenderlo.","english":"The screen is black and I can''t turn it on."},
      {"speaker":"Técnico","spanish":"¿La batería está cargada?","english":"Is the battery charged?"},
      {"speaker":"Cliente","spanish":"Creo que sí, pero el cargador es nuevo.","english":"I think so, but the charger is new."},
      {"speaker":"Técnico","spanish":"A veces los cargadores nuevos no funcionan bien.","english":"Sometimes new chargers don''t work well."},
      {"speaker":"Cliente","spanish":"¿Cuánto cuesta repararlo?","english":"How much does it cost to repair it?"},
      {"speaker":"Técnico","spanish":"Unos cincuenta euros. Lo tengo listo mañana.","english":"About fifty euros. I''ll have it ready tomorrow."},
      {"speaker":"Cliente","spanish":"Perfecto. Vuelvo mañana por la tarde.","english":"Perfect. I''ll come back tomorrow afternoon."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','What device is broken?','A computer',array['A phone','A tablet','A TV'],'mi ordenador no funciona',1),
    (v_l8,'multiple_choice','What is the visible problem?','The screen is black',array['Battery won''t charge','No internet','Sound is broken'],'La pantalla está negra',2),
    (v_l8,'multiple_choice','True or false: The customer believes the battery is charged.','True',array['False'],'Creo que sí',3),
    (v_l8,'multiple_choice','How much will the repair cost?','About 50 euros',array['About 100 euros','About 20 euros','About 200 euros'],'Unos cincuenta euros',4),
    (v_l8,'fill_blank','Complete: "Mi ordenador no ____" (works)','funciona',array['funciono','funcionas','funcionar'],'works',5),
    (v_l8,'multiple_choice','When will the customer come back?','Tomorrow afternoon',array['Tomorrow morning','Today','Next week'],'mañana por la tarde',6);

  -- ============== A2.15 SOCIAL MEDIA ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Social Media';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Social Media — Conversation Practice',
    description = 'Two friends compare their social-media habits.',
    intro = 'A capstone A2 conversation that uses the present continuous (ESTAR + -ANDO/-IENDO), all the social-media verbs, and frequency adverbs.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Sara","spanish":"¿Qué estás haciendo?","english":"What are you doing?"},
      {"speaker":"Hugo","spanish":"Estoy publicando una foto en Instagram.","english":"I''m posting a photo on Instagram."},
      {"speaker":"Sara","spanish":"¿Cuántos seguidores tienes?","english":"How many followers do you have?"},
      {"speaker":"Hugo","spanish":"Unos mil. Subo una historia cada día.","english":"About a thousand. I upload a story every day."},
      {"speaker":"Sara","spanish":"Yo prefiero TikTok. Comparto vídeos graciosos.","english":"I prefer TikTok. I share funny videos."},
      {"speaker":"Hugo","spanish":"¿Te sigo?","english":"Shall I follow you?"},
      {"speaker":"Sara","spanish":"Sí, etiqueta a tus amigos también.","english":"Yes, tag your friends too."},
      {"speaker":"Hugo","spanish":"A veces paso demasiado tiempo en las redes.","english":"Sometimes I spend too much time on social networks."},
      {"speaker":"Sara","spanish":"Yo también. Intento no usarlo antes de dormir.","english":"Me too. I try not to use it before sleeping."},
      {"speaker":"Hugo","spanish":"Buena idea. Voy a hacer lo mismo.","english":"Good idea. I''m going to do the same."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','What is Hugo doing?','Posting a photo',array['Watching a video','Sending a message','Writing a comment'],'Estoy publicando una foto',1),
    (v_l8,'multiple_choice','Which network does Hugo use?','Instagram',array['TikTok','Twitter','Facebook'],'una foto en Instagram',2),
    (v_l8,'multiple_choice','Which network does Sara prefer?','TikTok',array['Instagram','YouTube','Facebook'],'Yo prefiero TikTok',3),
    (v_l8,'multiple_choice','How many followers does Hugo have?','About 1000',array['About 100','About 5000','About 10'],'Unos mil',4),
    (v_l8,'fill_blank','Complete: "Estoy publi____" (-ing form)','cando',array['ado','iendo','ido'],'-ando (posting)',5),
    (v_l8,'multiple_choice','True or false: Sara tries not to use her phone before sleeping.','True',array['False'],'Intento no usarlo antes de dormir',6);

end $$;

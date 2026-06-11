-- 036_placement_exam_v2.sql
-- Rebuild Spanish A1/A2 placement exams with the new format:
--   - 1 reading passage + 3 comprehension MC questions
--   - 5 vocabulary MC (full-sentence context)
--   - 5 dialogue completion (user types the missing line)
--   - 10 listening (audio plays a Spanish sentence; user types a Spanish response)
--   - 10 speaking (English topic prompt; user records a monologue; AI grades transcript)
--   - 10 writing (English prompts; user writes Spanish; AI grades)
-- Pass mark is 75% (enforced in app code).
--
-- Bank size: 2-3x what's needed per category, so each attempt randomly
-- selects a fresh subset. AI-graded responses are stored per-question with
-- score (0-10) and brief feedback in placement_exam_attempt_responses.
--
-- Idempotent.

-- ============== SCHEMA: reading passages ==============
create table if not exists public.placement_exam_reading_passages (
  id bigint generated always as identity primary key,
  language_id bigint not null references public.languages(id) on delete cascade,
  level text not null check (level in ('A1','A2','B1','B2','C1')),
  -- The Spanish passage shown to the candidate before the 3 MC questions.
  passage text not null,
  -- 3 questions, each {question, correct_answer, wrong_answers: [a,b,c]}.
  comprehension_questions jsonb not null,
  created_at timestamptz default now()
);
create index if not exists idx_placement_passages_lang_level
  on public.placement_exam_reading_passages(language_id, level);

alter table public.placement_exam_reading_passages enable row level security;
drop policy if exists "Reading passages are readable by authenticated users"
  on public.placement_exam_reading_passages;
create policy "Reading passages are readable by authenticated users"
  on public.placement_exam_reading_passages for select
  to authenticated
  using (true);

-- ============== SCHEMA: extend questions table ==============
-- New categories: reading (the post-passage MC), dialogue, plus existing four.
-- We widen the category constraint and add columns used by the new question types.
alter table public.placement_exam_questions
  drop constraint if exists placement_exam_questions_category_check;
alter table public.placement_exam_questions
  add constraint placement_exam_questions_category_check
  check (category in ('reading','vocabulary','dialogue','listening','speaking','writing'));

alter table public.placement_exam_questions
  add column if not exists topic_prompt text;
alter table public.placement_exam_questions
  add column if not exists dialogue_lines jsonb;
alter table public.placement_exam_questions
  add column if not exists context_sentence text;

-- ============== SCHEMA: extend attempts ==============
alter table public.placement_exam_attempts
  add column if not exists reading_score int not null default 0;
alter table public.placement_exam_attempts
  add column if not exists dialogue_score int not null default 0;

-- ============== SCHEMA: per-question response storage ==============
create table if not exists public.placement_exam_attempt_responses (
  id bigint generated always as identity primary key,
  attempt_id uuid not null references public.placement_exam_attempts(id) on delete cascade,
  -- nullable: reading-passage MC responses use passage_question_index instead
  question_id bigint references public.placement_exam_questions(id) on delete set null,
  passage_id bigint references public.placement_exam_reading_passages(id) on delete set null,
  passage_question_index int,
  category text not null check (category in ('reading','vocabulary','dialogue','listening','speaking','writing')),
  user_response text not null default '',
  score int not null default 0 check (score between 0 and 10),
  feedback text,
  created_at timestamptz default now()
);
create index if not exists idx_attempt_responses_attempt
  on public.placement_exam_attempt_responses(attempt_id);

alter table public.placement_exam_attempt_responses enable row level security;
drop policy if exists "Users see their own attempt responses"
  on public.placement_exam_attempt_responses;
create policy "Users see their own attempt responses"
  on public.placement_exam_attempt_responses for select
  using (
    exists (
      select 1 from public.placement_exam_attempts a
      where a.id = attempt_id and a.user_id = auth.uid()
    )
  );
drop policy if exists "Users can insert their own attempt responses"
  on public.placement_exam_attempt_responses;
create policy "Users can insert their own attempt responses"
  on public.placement_exam_attempt_responses for insert
  with check (
    exists (
      select 1 from public.placement_exam_attempts a
      where a.id = attempt_id and a.user_id = auth.uid()
    )
  );

-- ============== SEED: clear old A1/A2 + reseed ==============
do $$
declare
  v_lang_id bigint;
begin
  select id into v_lang_id from public.languages where code = 'spanish';
  if v_lang_id is null then raise exception 'Spanish language not found'; end if;

  delete from public.placement_exam_questions where language_id = v_lang_id and level in ('A1','A2');
  delete from public.placement_exam_reading_passages where language_id = v_lang_id and level in ('A1','A2');

  -- =========================================================
  -- A1 — READING PASSAGES (3 total: pick 1 per attempt)
  -- =========================================================
  insert into public.placement_exam_reading_passages (language_id, level, passage, comprehension_questions) values
  (v_lang_id,'A1',
   'Me llamo Sofía y tengo veinticinco años. Vivo en Madrid con mi familia. Soy estudiante de medicina. Por la mañana voy a la universidad en autobús y por la tarde estudio en la biblioteca. Me gusta el café con leche y los churros. Los fines de semana visito a mis abuelos en el campo.',
   '[
     {"question":"¿Cuántos años tiene Sofía?","correct_answer":"Veinticinco años","wrong_answers":["Quince años","Treinta años","Cincuenta años"]},
     {"question":"¿Cómo va Sofía a la universidad?","correct_answer":"En autobús","wrong_answers":["En coche","En tren","A pie"]},
     {"question":"¿A quién visita los fines de semana?","correct_answer":"A sus abuelos","wrong_answers":["A sus amigos","A sus padres","A sus hermanos"]}
   ]'::jsonb),
  (v_lang_id,'A1',
   'Hola, soy Marco. Vivo en Barcelona y trabajo en un restaurante pequeño cerca de la playa. Mi familia es grande: tengo dos hermanas y un hermano. Los domingos comemos paella en casa de mi madre. Por la noche me gusta escuchar música y leer libros. Mañana es mi cumpleaños y voy a celebrar con mis amigos.',
   '[
     {"question":"¿Dónde trabaja Marco?","correct_answer":"En un restaurante","wrong_answers":["En la playa","En una tienda","En una escuela"]},
     {"question":"¿Cuántos hermanos tiene en total?","correct_answer":"Tres","wrong_answers":["Dos","Uno","Cuatro"]},
     {"question":"¿Qué va a hacer mañana?","correct_answer":"Celebrar su cumpleaños","wrong_answers":["Trabajar en el restaurante","Ir a la playa","Visitar a su madre"]}
   ]'::jsonb),
  (v_lang_id,'A1',
   'Mi amiga Laura es profesora de inglés. Tiene treinta años y vive en un apartamento pequeño en el centro de Sevilla. Tiene un gato negro que se llama Luna. Por la mañana Laura toma té con tostadas. Le gusta caminar por el parque y comprar flores los sábados. En verano viaja a la playa con su novio.',
   '[
     {"question":"¿Qué hace Laura?","correct_answer":"Es profesora de inglés","wrong_answers":["Es estudiante","Es doctora","Es cocinera"]},
     {"question":"¿De qué color es su gato?","correct_answer":"Negro","wrong_answers":["Blanco","Gris","Marrón"]},
     {"question":"¿Qué bebe por la mañana?","correct_answer":"Té","wrong_answers":["Café","Agua","Zumo"]}
   ]'::jsonb);

  -- =========================================================
  -- A1 — VOCABULARY (10 in bank, pick 5)
  -- All full sentence context. Pick the word that completes the sentence.
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, order_index) values
  (v_lang_id,'A1','vocabulary','Por la mañana, mi padre toma _____ con leche.','café',array['silla','sol','perro'],1),
  (v_lang_id,'A1','vocabulary','Mi hermana tiene un perro y un _____ blanco.','gato',array['libro','árbol','agua'],2),
  (v_lang_id,'A1','vocabulary','Hoy hace mucho frío, voy a llevar mi _____ azul.','abrigo',array['zapato','agua','flor'],3),
  (v_lang_id,'A1','vocabulary','¿Qué hora es? Son las tres de la _____.','tarde',array['casa','semana','mesa'],4),
  (v_lang_id,'A1','vocabulary','En el desayuno como pan con _____ y un huevo.','queso',array['silla','ventana','árbol'],5),
  (v_lang_id,'A1','vocabulary','Mi abuela vive en una casa muy _____.','grande',array['rápido','triste','barato'],6),
  (v_lang_id,'A1','vocabulary','Voy al supermercado para comprar fruta y _____.','verduras',array['libros','zapatos','sillas'],7),
  (v_lang_id,'A1','vocabulary','Mi madre trabaja en un _____ como médica.','hospital',array['restaurante','cine','parque'],8),
  (v_lang_id,'A1','vocabulary','Los sábados juego al fútbol con mis _____.','amigos',array['libros','clases','zapatos'],9),
  (v_lang_id,'A1','vocabulary','Tengo mucha sed, quiero un vaso de _____.','agua',array['pan','queso','sol'],10);

  -- =========================================================
  -- A1 — DIALOGUE COMPLETION (10 in bank, pick 5)
  -- dialogue_lines = [{speaker, text}, ...] with last line missing.
  -- correct_answer = one acceptable typed Spanish response (used as reference for AI grading).
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, dialogue_lines, order_index) values
  (v_lang_id,'A1','dialogue','Complete the dialogue with an appropriate Spanish response.','Me llamo Ana',array[]::text[],
    '[{"speaker":"A","text":"¡Hola! ¿Cómo te llamas?"},{"speaker":"B","text":"___"}]'::jsonb,11),
  (v_lang_id,'A1','dialogue','Complete the dialogue with an appropriate Spanish response.','Tengo veinte años',array[]::text[],
    '[{"speaker":"A","text":"¿Cuántos años tienes?"},{"speaker":"B","text":"___"}]'::jsonb,12),
  (v_lang_id,'A1','dialogue','Complete the dialogue with an appropriate Spanish response.','Soy de España',array[]::text[],
    '[{"speaker":"A","text":"¿De dónde eres?"},{"speaker":"B","text":"___"}]'::jsonb,13),
  (v_lang_id,'A1','dialogue','Complete the dialogue with an appropriate Spanish response.','Estoy bien gracias',array[]::text[],
    '[{"speaker":"A","text":"¿Cómo estás hoy?"},{"speaker":"B","text":"___"}]'::jsonb,14),
  (v_lang_id,'A1','dialogue','Complete the dialogue with an appropriate Spanish response.','Son las ocho',array[]::text[],
    '[{"speaker":"A","text":"¿Qué hora es?"},{"speaker":"B","text":"___"}]'::jsonb,15),
  (v_lang_id,'A1','dialogue','Complete the dialogue with an appropriate Spanish response.','Me gusta la pizza',array[]::text[],
    '[{"speaker":"A","text":"¿Qué comida te gusta?"},{"speaker":"B","text":"___"}]'::jsonb,16),
  (v_lang_id,'A1','dialogue','Complete the dialogue with an appropriate Spanish response.','Vivo en Madrid',array[]::text[],
    '[{"speaker":"A","text":"¿Dónde vives?"},{"speaker":"B","text":"___"}]'::jsonb,17),
  (v_lang_id,'A1','dialogue','Complete the dialogue with an appropriate Spanish response.','Tengo dos hermanos',array[]::text[],
    '[{"speaker":"A","text":"¿Cuántos hermanos tienes?"},{"speaker":"B","text":"___"}]'::jsonb,18),
  (v_lang_id,'A1','dialogue','Complete the dialogue with an appropriate Spanish response.','Hasta mañana',array[]::text[],
    '[{"speaker":"A","text":"Bueno, nos vemos."},{"speaker":"B","text":"___"}]'::jsonb,19),
  (v_lang_id,'A1','dialogue','Complete the dialogue with an appropriate Spanish response.','Quiero un café por favor',array[]::text[],
    '[{"speaker":"Camarero","text":"¿Qué desea tomar?"},{"speaker":"Cliente","text":"___"}]'::jsonb,20);

  -- =========================================================
  -- A1 — LISTENING (20 in bank, pick 10)
  -- TTS reads question (Spanish prompt). User types a Spanish response.
  -- correct_answer = one acceptable response, used as reference for AI grading.
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, order_index) values
  (v_lang_id,'A1','listening','Hola, ¿cómo te llamas?','Me llamo Ana',array[]::text[],21),
  (v_lang_id,'A1','listening','¿De dónde eres?','Soy de España',array[]::text[],22),
  (v_lang_id,'A1','listening','¿Cuántos años tienes?','Tengo veinte años',array[]::text[],23),
  (v_lang_id,'A1','listening','¿Qué hora es?','Son las nueve de la mañana',array[]::text[],24),
  (v_lang_id,'A1','listening','¿Dónde vives?','Vivo en Barcelona',array[]::text[],25),
  (v_lang_id,'A1','listening','¿Qué te gusta comer?','Me gusta la paella',array[]::text[],26),
  (v_lang_id,'A1','listening','¿Tienes hermanos?','Sí, tengo dos hermanos',array[]::text[],27),
  (v_lang_id,'A1','listening','¿Cómo está el tiempo hoy?','Hace mucho sol',array[]::text[],28),
  (v_lang_id,'A1','listening','¿Qué haces los fines de semana?','Salgo con mis amigos',array[]::text[],29),
  (v_lang_id,'A1','listening','¿A qué hora te levantas?','Me levanto a las siete',array[]::text[],30),
  (v_lang_id,'A1','listening','¿Trabajas o estudias?','Soy estudiante',array[]::text[],31),
  (v_lang_id,'A1','listening','¿Cuál es tu color favorito?','Mi color favorito es el azul',array[]::text[],32),
  (v_lang_id,'A1','listening','¿Qué día es hoy?','Hoy es martes',array[]::text[],33),
  (v_lang_id,'A1','listening','¿Tienes un animal en casa?','Sí, tengo un gato',array[]::text[],34),
  (v_lang_id,'A1','listening','¿Qué desayunas normalmente?','Desayuno café y tostadas',array[]::text[],35),
  (v_lang_id,'A1','listening','¿Cuál es tu estación favorita?','Mi estación favorita es el verano',array[]::text[],36),
  (v_lang_id,'A1','listening','¿Cómo vienes a clase?','Vengo en autobús',array[]::text[],37),
  (v_lang_id,'A1','listening','¿Cuándo es tu cumpleaños?','Mi cumpleaños es en mayo',array[]::text[],38),
  (v_lang_id,'A1','listening','¿Qué deportes te gustan?','Me gusta el fútbol',array[]::text[],39),
  (v_lang_id,'A1','listening','¿Estás cansado hoy?','No, estoy bien',array[]::text[],40);

  -- =========================================================
  -- A1 — SPEAKING (20 in bank, pick 10)
  -- topic_prompt is the English instruction shown on screen.
  -- correct_answer is a brief reference outline used by the AI grader.
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, topic_prompt, order_index) values
  (v_lang_id,'A1','speaking','Speak in Spanish about yourself.','Name, age, where you live and study/work',array[]::text[],
   'Introduce yourself. Say your name, your age, where you are from and where you live. Speak for 1-2 minutes.',41),
  (v_lang_id,'A1','speaking','Describe your family in Spanish.','Members of family with simple descriptions',array[]::text[],
   'Describe your family. Talk about how many people are in your family and what they are like. Speak for 1-2 minutes.',42),
  (v_lang_id,'A1','speaking','Talk about your daily routine in Spanish.','Wake up, eat, work/study, evening',array[]::text[],
   'Describe a typical day in your life. What do you do in the morning, afternoon and evening? Speak for 1-2 minutes.',43),
  (v_lang_id,'A1','speaking','Describe your house or apartment in Spanish.','Rooms, what they look like',array[]::text[],
   'Describe where you live. What rooms does it have? What do you like about it? Speak for 1-2 minutes.',44),
  (v_lang_id,'A1','speaking','Talk about your hobbies in Spanish.','Activities you like, when you do them',array[]::text[],
   'Talk about your hobbies and free-time activities. What do you like to do? Speak for 1-2 minutes.',45),
  (v_lang_id,'A1','speaking','Describe your favourite food in Spanish.','Dish name, ingredients, why you like it',array[]::text[],
   'Describe your favourite food or meal. What is it and why do you like it? Speak for 1-2 minutes.',46),
  (v_lang_id,'A1','speaking','Talk about a friend in Spanish.','Name, age, what they are like',array[]::text[],
   'Describe a close friend. Say their name, age and what they are like. Speak for 1-2 minutes.',47),
  (v_lang_id,'A1','speaking','Describe the weather where you live in Spanish.','Seasons, temperature, what you wear',array[]::text[],
   'Describe the weather where you live across the four seasons. Speak for 1-2 minutes.',48),
  (v_lang_id,'A1','speaking','Talk about your studies or job in Spanish.','What you do, where, what hours',array[]::text[],
   'Talk about your studies or your job. What do you do? Where do you go? Speak for 1-2 minutes.',49),
  (v_lang_id,'A1','speaking','Describe your hometown in Spanish.','Name, size, what there is to do',array[]::text[],
   'Describe your hometown. What is it called, what is it like, what is there to do? Speak for 1-2 minutes.',50),
  (v_lang_id,'A1','speaking','Talk about what you eat in a typical day in Spanish.','Breakfast, lunch and dinner',array[]::text[],
   'Describe what you eat in a typical day: breakfast, lunch and dinner. Speak for 1-2 minutes.',51),
  (v_lang_id,'A1','speaking','Describe your favourite sport in Spanish.','Sport name, when, with whom',array[]::text[],
   'Talk about a sport or activity you like to watch or play. Speak for 1-2 minutes.',52),
  (v_lang_id,'A1','speaking','Talk about a holiday or trip you went on in Spanish.','Where, when, what you did',array[]::text[],
   'Describe a holiday or short trip. Where did you go? What did you do? Speak for 1-2 minutes.',53),
  (v_lang_id,'A1','speaking','Talk about clothes you wear in Spanish.','Items, colours, when',array[]::text[],
   'Describe the clothes you usually wear. Speak for 1-2 minutes.',54),
  (v_lang_id,'A1','speaking','Describe your weekend in Spanish.','Saturday and Sunday activities',array[]::text[],
   'Describe what you usually do on Saturdays and Sundays. Speak for 1-2 minutes.',55),
  (v_lang_id,'A1','speaking','Talk about a person you admire in Spanish.','Who, why, what they do',array[]::text[],
   'Talk about someone in your family or a friend that you admire and why. Speak for 1-2 minutes.',56),
  (v_lang_id,'A1','speaking','Describe a typical breakfast in your country in Spanish.','Food, drinks',array[]::text[],
   'Describe a typical breakfast in your country. Speak for 1-2 minutes.',57),
  (v_lang_id,'A1','speaking','Talk about your favourite music in Spanish.','Genre, artists, when you listen',array[]::text[],
   'Talk about the music you like. Speak for 1-2 minutes.',58),
  (v_lang_id,'A1','speaking','Describe how you go to work or school in Spanish.','Transport, time, route',array[]::text[],
   'Describe how you go to work or school each day. Speak for 1-2 minutes.',59),
  (v_lang_id,'A1','speaking','Talk about your favourite season in Spanish.','Season, weather, activities',array[]::text[],
   'Talk about which season of the year you like best and why. Speak for 1-2 minutes.',60);

  -- =========================================================
  -- A1 — WRITING (20 in bank, pick 10)
  -- English prompt → user writes 2-3 Spanish sentences. Progressive complexity.
  -- correct_answer is a brief reference outline used by the AI grader.
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, order_index) values
  (v_lang_id,'A1','writing','Write 2-3 Spanish sentences introducing yourself (name, age, country).','Hola, me llamo X. Tengo X años. Soy de X.',array[]::text[],61),
  (v_lang_id,'A1','writing','Write 2-3 Spanish sentences about your family.','Mention how many people are in your family and a few names',array[]::text[],62),
  (v_lang_id,'A1','writing','Write 2-3 Spanish sentences describing your house or flat.','Rooms it has, what you like',array[]::text[],63),
  (v_lang_id,'A1','writing','Write 2-3 Spanish sentences about what you ate yesterday.','Breakfast, lunch and dinner with simple foods',array[]::text[],64),
  (v_lang_id,'A1','writing','Write 2-3 Spanish sentences describing the weather today.','Hace/Está + sun, rain, cold, hot',array[]::text[],65),
  (v_lang_id,'A1','writing','Write 2-3 Spanish sentences about your hobbies.','Activities you do in your free time',array[]::text[],66),
  (v_lang_id,'A1','writing','Write 2-3 Spanish sentences describing your best friend.','Name, age, what they are like',array[]::text[],67),
  (v_lang_id,'A1','writing','Write 2-3 Spanish sentences about your daily routine in the morning.','Wake up, breakfast, leave the house',array[]::text[],68),
  (v_lang_id,'A1','writing','Write 2-3 Spanish sentences about a typical Saturday.','What you do on Saturday',array[]::text[],69),
  (v_lang_id,'A1','writing','Write 2-3 Spanish sentences about your favourite restaurant.','Name, type of food, why you like it',array[]::text[],70),
  (v_lang_id,'A1','writing','Write 2-3 Spanish sentences describing a friend''s family.','Members, ages, what they do',array[]::text[],71),
  (v_lang_id,'A1','writing','Write 2-3 Spanish sentences about what clothes you wear in winter.','Items, colour, why',array[]::text[],72),
  (v_lang_id,'A1','writing','Write 2-3 Spanish sentences about a city you would like to visit.','Name, country, what there is',array[]::text[],73),
  (v_lang_id,'A1','writing','Write 2-3 Spanish sentences about your favourite drink.','Drink, when you drink it',array[]::text[],74),
  (v_lang_id,'A1','writing','Write 2-3 Spanish sentences ordering food at a restaurant.','Quiero..., por favor, gracias',array[]::text[],75),
  (v_lang_id,'A1','writing','Write 2-3 Spanish sentences about your favourite season and why.','Season, weather, activity',array[]::text[],76),
  (v_lang_id,'A1','writing','Write 2-3 Spanish sentences inviting a friend to a party.','Day, time, place',array[]::text[],77),
  (v_lang_id,'A1','writing','Write 2-3 Spanish sentences describing a typical breakfast.','Coffee, bread, fruit etc.',array[]::text[],78),
  (v_lang_id,'A1','writing','Write 2-3 Spanish sentences about your country.','Capital, language, food',array[]::text[],79),
  (v_lang_id,'A1','writing','Write 2-3 Spanish sentences saying what you do in the evening.','Dinner, TV, family, sleep',array[]::text[],80);

  -- =========================================================
  -- A2 — READING PASSAGES (3 total)
  -- =========================================================
  insert into public.placement_exam_reading_passages (language_id, level, passage, comprehension_questions) values
  (v_lang_id,'A2',
   'El año pasado mi amiga Elena y yo decidimos hacer un viaje a Granada porque nunca habíamos visitado la Alhambra. Reservamos un hotel pequeño cerca del centro y compramos las entradas por internet. Llegamos un viernes por la tarde después de cinco horas en tren. El sábado nos levantamos muy temprano para visitar el palacio: era impresionante. Por la tarde dimos un paseo por el barrio del Albaicín y cenamos tapas en un bar tradicional. El domingo, antes de volver, compramos algunos recuerdos para nuestras familias.',
   '[
     {"question":"¿Por qué decidieron viajar a Granada?","correct_answer":"Para visitar la Alhambra","wrong_answers":["Para ver a un familiar","Para asistir a un concierto","Para hacer un curso"]},
     {"question":"¿Cómo llegaron a Granada?","correct_answer":"En tren","wrong_answers":["En avión","En coche","En autobús"]},
     {"question":"¿Qué hicieron antes de volver?","correct_answer":"Compraron recuerdos","wrong_answers":["Visitaron otro museo","Comieron en otro bar","Caminaron por el río"]}
   ]'::jsonb),
  (v_lang_id,'A2',
   'Me llamo Pablo y trabajo como recepcionista en un hotel del centro de Valencia. Empecé el trabajo hace dos años, justo después de terminar mis estudios. Antes de este puesto, había trabajado en un café durante el verano. Mi horario no es siempre fácil porque a veces tengo que hacer turnos de noche, pero me gusta conocer a personas de muchos países. La semana pasada vinieron unos turistas japoneses que no hablaban español; intenté ayudarles en inglés y todo salió bien. Cuando termino el trabajo, suelo ir al gimnasio y luego ceno en casa con mi pareja.',
   '[
     {"question":"¿Cuánto tiempo lleva Pablo en este trabajo?","correct_answer":"Dos años","wrong_answers":["Seis meses","Cinco años","Diez años"]},
     {"question":"¿Qué hizo antes de ser recepcionista?","correct_answer":"Trabajó en un café","wrong_answers":["Estudió en el extranjero","Vivió en Japón","Enseñó inglés"]},
     {"question":"¿Qué hace después del trabajo normalmente?","correct_answer":"Va al gimnasio y cena en casa","wrong_answers":["Sale con sus amigos a un bar","Estudia japonés","Va al cine con su pareja"]}
   ]'::jsonb),
  (v_lang_id,'A2',
   'Hace unos meses cambié de piso porque el antiguo estaba demasiado lejos del centro. Ahora vivo en un apartamento luminoso con dos balcones y una cocina nueva. Lo encontré gracias a una compañera de trabajo que conocía al propietario. El alquiler es un poco más caro, pero ahora voy a la oficina en bicicleta y tardo solo quince minutos. Los fines de semana invito a mis amigos a cenar; nos gusta cocinar juntos y después ver una película. Si pudiera, viviría aquí muchos años.',
   '[
     {"question":"¿Por qué cambió de piso?","correct_answer":"Porque el anterior estaba lejos del centro","wrong_answers":["Porque era muy caro","Porque era muy ruidoso","Porque era pequeño"]},
     {"question":"¿Cómo encontró el apartamento nuevo?","correct_answer":"Por una compañera de trabajo","wrong_answers":["Por internet","Por una agencia","Por un anuncio en la calle"]},
     {"question":"¿Cómo va al trabajo ahora?","correct_answer":"En bicicleta","wrong_answers":["A pie","En coche","En metro"]}
   ]'::jsonb);

  -- =========================================================
  -- A2 — VOCABULARY (10 in bank)
  -- Full-sentence context, noticeably more complex than A1.
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, order_index) values
  (v_lang_id,'A2','vocabulary','Aunque estaba muy cansado, mi hermano _____ trabajando hasta tarde.','siguió',array['empezó','perdió','llamó'],1),
  (v_lang_id,'A2','vocabulary','Cuando era niño, _____ los veranos en casa de mis abuelos.','pasaba',array['paso','pasaré','pasé'],2),
  (v_lang_id,'A2','vocabulary','El médico me recomendó que _____ menos café y más agua.','bebiera',array['bebía','bebo','beberé'],3),
  (v_lang_id,'A2','vocabulary','Si tuviera más tiempo libre, _____ aprender a tocar el piano.','me gustaría',array['me gusta','me gustó','me gustaba'],4),
  (v_lang_id,'A2','vocabulary','Tengo una reunión a las nueve, así que tengo que _____ temprano.','levantarme',array['acostarme','sentarme','quedarme'],5),
  (v_lang_id,'A2','vocabulary','Después de un día muy largo, no había _____ a la cama.','llegado',array['llegando','llegar','llegará'],6),
  (v_lang_id,'A2','vocabulary','No me gusta este restaurante porque la comida está _____ de sal.','llena',array['lleno','llenas','llenos'],7),
  (v_lang_id,'A2','vocabulary','Mi profesora habla muy rápido y a veces no _____ todo lo que dice.','entiendo',array['entender','entendido','entiendes'],8),
  (v_lang_id,'A2','vocabulary','Por favor, _____ la ventana, hace mucho calor aquí.','abre',array['abierto','abriendo','abrir'],9),
  (v_lang_id,'A2','vocabulary','Mi vecina es muy amable; siempre me _____ con las bolsas pesadas.','ayuda',array['ayudo','ayudaba','ayudaré'],10);

  -- =========================================================
  -- A2 — DIALOGUE COMPLETION (10 in bank)
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, dialogue_lines, order_index) values
  (v_lang_id,'A2','dialogue','Complete the dialogue with an appropriate Spanish response.','Fui a la playa con mis amigos',array[]::text[],
   '[{"speaker":"A","text":"¿Qué hiciste el fin de semana pasado?"},{"speaker":"B","text":"___"}]'::jsonb,11),
  (v_lang_id,'A2','dialogue','Complete the dialogue with an appropriate Spanish response.','Sí, claro, te recomiendo el pescado',array[]::text[],
   '[{"speaker":"Cliente","text":"¿Podría usted recomendarme un plato?"},{"speaker":"Camarero","text":"___"}]'::jsonb,12),
  (v_lang_id,'A2','dialogue','Complete the dialogue with an appropriate Spanish response.','Me duele mucho la cabeza',array[]::text[],
   '[{"speaker":"Médico","text":"Buenos días, ¿qué le pasa?"},{"speaker":"Paciente","text":"___"}]'::jsonb,13),
  (v_lang_id,'A2','dialogue','Complete the dialogue with an appropriate Spanish response.','Lo siento, ya tengo planes',array[]::text[],
   '[{"speaker":"A","text":"¿Quieres venir conmigo al cine esta noche?"},{"speaker":"B","text":"___"}]'::jsonb,14),
  (v_lang_id,'A2','dialogue','Complete the dialogue with an appropriate Spanish response.','El próximo tren sale a las diez',array[]::text[],
   '[{"speaker":"Viajero","text":"Perdone, ¿cuándo sale el próximo tren a Sevilla?"},{"speaker":"Empleado","text":"___"}]'::jsonb,15),
  (v_lang_id,'A2','dialogue','Complete the dialogue with an appropriate Spanish response.','Sí, está al lado del banco',array[]::text[],
   '[{"speaker":"Turista","text":"Disculpe, ¿hay una farmacia por aquí cerca?"},{"speaker":"Local","text":"___"}]'::jsonb,16),
  (v_lang_id,'A2','dialogue','Complete the dialogue with an appropriate Spanish response.','No, todavía no he terminado',array[]::text[],
   '[{"speaker":"Jefe","text":"¿Ya has acabado el informe?"},{"speaker":"Empleado","text":"___"}]'::jsonb,17),
  (v_lang_id,'A2','dialogue','Complete the dialogue with an appropriate Spanish response.','Prefiero la habitación con vistas al mar',array[]::text[],
   '[{"speaker":"Recepcionista","text":"¿Cuál de las dos habitaciones prefiere?"},{"speaker":"Huésped","text":"___"}]'::jsonb,18),
  (v_lang_id,'A2','dialogue','Complete the dialogue with an appropriate Spanish response.','Vale, te llamo cuando llegue',array[]::text[],
   '[{"speaker":"A","text":"Avísame cuando estés en casa, por favor."},{"speaker":"B","text":"___"}]'::jsonb,19),
  (v_lang_id,'A2','dialogue','Complete the dialogue with an appropriate Spanish response.','Hace dos años que vivo aquí',array[]::text[],
   '[{"speaker":"A","text":"¿Cuánto tiempo llevas viviendo en esta ciudad?"},{"speaker":"B","text":"___"}]'::jsonb,20);

  -- =========================================================
  -- A2 — LISTENING (20 in bank)
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, order_index) values
  (v_lang_id,'A2','listening','¿Qué hiciste el fin de semana pasado?','El sábado fui al cine y el domingo descansé en casa',array[]::text[],21),
  (v_lang_id,'A2','listening','¿Has viajado alguna vez al extranjero?','Sí, he viajado a Francia e Italia',array[]::text[],22),
  (v_lang_id,'A2','listening','¿Qué tipo de música escuchabas cuando eras adolescente?','Escuchaba sobre todo rock y pop',array[]::text[],23),
  (v_lang_id,'A2','listening','¿Cómo era tu primera escuela?','Era una escuela pequeña con muchos árboles',array[]::text[],24),
  (v_lang_id,'A2','listening','¿Qué planes tienes para el verano?','Voy a viajar a la costa con mi familia',array[]::text[],25),
  (v_lang_id,'A2','listening','¿Te gustaría vivir en otra ciudad?','Me gustaría vivir en Madrid algún día',array[]::text[],26),
  (v_lang_id,'A2','listening','¿Cuánto tiempo llevas estudiando español?','Llevo dos años estudiando español',array[]::text[],27),
  (v_lang_id,'A2','listening','¿Qué hiciste ayer después del trabajo?','Fui al gimnasio y cené con mi pareja',array[]::text[],28),
  (v_lang_id,'A2','listening','¿Recuerdas un viaje especial que hayas hecho?','Recuerdo un viaje a la playa el año pasado',array[]::text[],29),
  (v_lang_id,'A2','listening','¿Qué problema tuviste la última vez que viajaste?','Perdí mi maleta en el aeropuerto',array[]::text[],30),
  (v_lang_id,'A2','listening','¿Qué consejo le darías a alguien que aprende español?','Le diría que practique todos los días',array[]::text[],31),
  (v_lang_id,'A2','listening','¿Cómo celebrabas tu cumpleaños cuando eras niño?','Lo celebraba con una fiesta en casa',array[]::text[],32),
  (v_lang_id,'A2','listening','¿Qué te gusta hacer en tu tiempo libre?','Me gusta leer y salir con amigos',array[]::text[],33),
  (v_lang_id,'A2','listening','¿Qué desayunaste esta mañana?','Desayuné café con leche y una tostada',array[]::text[],34),
  (v_lang_id,'A2','listening','¿Has trabajado alguna vez en un restaurante?','Sí, trabajé como camarera en verano',array[]::text[],35),
  (v_lang_id,'A2','listening','¿Cómo era el tiempo el fin de semana pasado?','Hizo mucho frío y estuvo lloviendo',array[]::text[],36),
  (v_lang_id,'A2','listening','¿Qué deportes practicabas en la escuela?','Jugaba al baloncesto y nadaba',array[]::text[],37),
  (v_lang_id,'A2','listening','¿Cuál es tu plato favorito y cómo se prepara?','Mi plato favorito es la paella, se hace con arroz y mariscos',array[]::text[],38),
  (v_lang_id,'A2','listening','¿Qué harías si ganaras la lotería?','Compraría una casa y viajaría por el mundo',array[]::text[],39),
  (v_lang_id,'A2','listening','¿Por qué decidiste aprender español?','Decidí aprenderlo porque quiero viajar por Latinoamérica',array[]::text[],40);

  -- =========================================================
  -- A2 — SPEAKING (20 in bank)
  -- 2-3 min monologues.
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, topic_prompt, order_index) values
  (v_lang_id,'A2','speaking','Describe a memorable trip you took in Spanish.','Where, when, what you did, how you felt',array[]::text[],
   'Describe a trip or holiday you remember well. Where did you go, what did you do and how did you feel? Speak for 2-3 minutes.',41),
  (v_lang_id,'A2','speaking','Describe your studies or career so far in Spanish.','What you studied, where you have worked, future plans',array[]::text[],
   'Talk about your studies and your work so far. What have you studied, where have you worked, what are your plans? Speak for 2-3 minutes.',42),
  (v_lang_id,'A2','speaking','Compare life in a big city and in a small town in Spanish.','At least two contrasts and your preference',array[]::text[],
   'Compare life in a big city with life in a small town. Mention advantages, disadvantages and your preference. Speak for 2-3 minutes.',43),
  (v_lang_id,'A2','speaking','Describe your perfect weekend in Spanish.','Friday evening to Sunday with activities',array[]::text[],
   'Describe your ideal weekend from Friday evening to Sunday night. Speak for 2-3 minutes.',44),
  (v_lang_id,'A2','speaking','Talk about a problem you solved recently in Spanish.','The problem, what you did, the outcome',array[]::text[],
   'Talk about a problem you had recently and how you solved it. Speak for 2-3 minutes.',45),
  (v_lang_id,'A2','speaking','Describe your favourite restaurant in Spanish.','Name, location, dishes, atmosphere, why you like it',array[]::text[],
   'Describe a restaurant you really like. Talk about the food, the atmosphere and why you return. Speak for 2-3 minutes.',46),
  (v_lang_id,'A2','speaking','Talk about how technology has changed your life in Spanish.','Phone, internet, work, family',array[]::text[],
   'Talk about how technology has changed your daily life. Speak for 2-3 minutes.',47),
  (v_lang_id,'A2','speaking','Describe a film or series you enjoyed in Spanish.','Title, plot, characters, your opinion',array[]::text[],
   'Describe a film or series you enjoyed recently. Speak for 2-3 minutes.',48),
  (v_lang_id,'A2','speaking','Talk about your country in Spanish.','Capital, food, traditions, climate',array[]::text[],
   'Talk about your country: its capital, traditions, food and climate. Speak for 2-3 minutes.',49),
  (v_lang_id,'A2','speaking','Describe a goal you have for the next year in Spanish.','The goal, why it matters, how you''ll achieve it',array[]::text[],
   'Describe a personal goal for the next twelve months. Why is it important and how will you achieve it? Speak for 2-3 minutes.',50),
  (v_lang_id,'A2','speaking','Talk about a person who has been important in your life in Spanish.','Who they are, why they matter, an example',array[]::text[],
   'Talk about someone who has been important in your life and why. Speak for 2-3 minutes.',51),
  (v_lang_id,'A2','speaking','Describe a routine you would like to change in Spanish.','What you do now, why, what you want to do',array[]::text[],
   'Describe a habit or routine you would like to change and explain why. Speak for 2-3 minutes.',52),
  (v_lang_id,'A2','speaking','Talk about a celebration in your country in Spanish.','Holiday name, when, what people do',array[]::text[],
   'Describe an important festival or holiday in your country. Speak for 2-3 minutes.',53),
  (v_lang_id,'A2','speaking','Describe the best teacher you have ever had in Spanish.','Subject, personality, why they were special',array[]::text[],
   'Talk about the best teacher you ever had and why. Speak for 2-3 minutes.',54),
  (v_lang_id,'A2','speaking','Talk about advantages and disadvantages of working from home in Spanish.','At least two pros and two cons',array[]::text[],
   'Discuss the advantages and disadvantages of working from home. Speak for 2-3 minutes.',55),
  (v_lang_id,'A2','speaking','Describe how you spend a typical Sunday in Spanish.','Morning, afternoon, evening',array[]::text[],
   'Describe what a typical Sunday looks like for you. Speak for 2-3 minutes.',56),
  (v_lang_id,'A2','speaking','Talk about a sport or activity you used to do as a child in Spanish.','Activity, when, with whom, why you stopped',array[]::text[],
   'Talk about a sport or activity you used to do as a child but no longer do. Speak for 2-3 minutes.',57),
  (v_lang_id,'A2','speaking','Describe what you would change about your hometown in Spanish.','At least two changes and why',array[]::text[],
   'Describe two or three things you would change about your hometown and why. Speak for 2-3 minutes.',58),
  (v_lang_id,'A2','speaking','Talk about a book you have read recently in Spanish.','Title, author, what it is about, your opinion',array[]::text[],
   'Talk about a book or article you have read recently. Speak for 2-3 minutes.',59),
  (v_lang_id,'A2','speaking','Describe your favourite season and what you do during it in Spanish.','Season, weather, activities, why',array[]::text[],
   'Describe your favourite season of the year and how you spend it. Speak for 2-3 minutes.',60);

  -- =========================================================
  -- A2 — WRITING (20 in bank), 3-4 sentences, increasing complexity
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, order_index) values
  (v_lang_id,'A2','writing','Write 3-4 Spanish sentences describing what you did last weekend.','Saturday and Sunday with simple past',array[]::text[],61),
  (v_lang_id,'A2','writing','Write 3-4 Spanish sentences about your studies and your plans for next year.','Use present and future',array[]::text[],62),
  (v_lang_id,'A2','writing','Write 3-4 Spanish sentences comparing your current and previous home.','Use comparatives and "antes/ahora"',array[]::text[],63),
  (v_lang_id,'A2','writing','Write a 3-4 sentence email inviting a friend to your birthday party.','Date, time, place, polite closing',array[]::text[],64),
  (v_lang_id,'A2','writing','Write 3-4 Spanish sentences describing how you usually go to work or school.','Time, transport, route',array[]::text[],65),
  (v_lang_id,'A2','writing','Write 3-4 Spanish sentences about a trip you took recently.','Where, with whom, what you did',array[]::text[],66),
  (v_lang_id,'A2','writing','Write 3-4 Spanish sentences explaining a typical breakfast in your country.','Foods, drinks, time, location',array[]::text[],67),
  (v_lang_id,'A2','writing','Write 3-4 Spanish sentences describing a problem you had with a bus, train or flight.','What happened, what you did',array[]::text[],68),
  (v_lang_id,'A2','writing','Write a 3-4 sentence email to a hotel asking about availability for two nights.','Polite, dates, requirements',array[]::text[],69),
  (v_lang_id,'A2','writing','Write 3-4 Spanish sentences talking about advantages and disadvantages of city life.','At least one of each',array[]::text[],70),
  (v_lang_id,'A2','writing','Write 3-4 Spanish sentences describing what you would do if you had a free day tomorrow.','Use conditional/future',array[]::text[],71),
  (v_lang_id,'A2','writing','Write a 3-4 sentence post-card message from a holiday.','Greeting, location, activity, sign-off',array[]::text[],72),
  (v_lang_id,'A2','writing','Write 3-4 Spanish sentences describing a memorable meal.','When, where, with whom, what',array[]::text[],73),
  (v_lang_id,'A2','writing','Write 3-4 Spanish sentences explaining your morning routine, with two specific times.','Times, actions',array[]::text[],74),
  (v_lang_id,'A2','writing','Write 3-4 Spanish sentences giving simple advice to a friend visiting your city.','Use "deberías" or imperatives',array[]::text[],75),
  (v_lang_id,'A2','writing','Write a 3-4 sentence complaint about a hotel room.','Polite, the problem, what you want',array[]::text[],76),
  (v_lang_id,'A2','writing','Write 3-4 Spanish sentences talking about a job you would like in the future.','Job, why, what is needed',array[]::text[],77),
  (v_lang_id,'A2','writing','Write 3-4 Spanish sentences describing the worst weather you remember.','When, where, what happened',array[]::text[],78),
  (v_lang_id,'A2','writing','Write 3-4 Spanish sentences explaining why you started learning Spanish.','Motivation, when, plans',array[]::text[],79),
  (v_lang_id,'A2','writing','Write 3-4 Spanish sentences describing a typical family meal at your home.','Day, food, who is there',array[]::text[],80);

end $$;

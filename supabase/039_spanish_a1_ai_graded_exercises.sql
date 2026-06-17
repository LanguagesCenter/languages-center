-- 039_spanish_a1_ai_graded_exercises.sql
-- Updates every Spanish A1 lesson (15 sections × 7 teaching lessons) so the
-- listening / speaking / writing exercises run through the AI grader. Each
-- lesson 1-7 gets exactly one listening, one speaking and one writing
-- exercise in the new format. Prompts scale by section tier:
--
--   sections  1-5  (Greetings, Numbers, Colors, Family, Food)
--                  — very simple, 1 sentence target
--   sections  6-10 (Time, Weather, Shopping, Animals, Body Parts)
--                  — slightly longer, 1-2 sentences
--   sections 11-15 (Clothes, House & Home, Transport, Days & Months, Basic Verbs)
--                  — 2 full sentences target
--
-- Exercise-format conventions adopted here so the LessonClient can
-- distinguish the new flow from legacy MC/repeat-the-phrase rows:
--
--   listening (typed response, AI-graded):
--     type             = 'listening'
--     question         = the Spanish sentence the TTS reads aloud
--     correct_answer   = a reference Spanish response (for AI context)
--     wrong_answers    = ARRAY[]::text[]   ← empty signals "typed", not MC
--
--   speaking (monologue, AI-graded):
--     type             = 'speaking'
--     question         = English topic prompt shown to the candidate
--     correct_answer   = '' (empty) ← signals topic mode, not "repeat phrase"
--     wrong_answers    = ARRAY[]::text[]
--
--   writing (typed response, AI-graded):
--     type             = 'writing'
--     question         = English prompt
--     correct_answer   = brief reference outline
--     wrong_answers    = ARRAY[]::text[]
--
-- Idempotent — re-running deletes the A1 lesson's listening/speaking/writing
-- rows for lessons 1-7 and reseeds them.

-- ============== SCHEMA: add 'writing' to the exercises check ==============
alter table public.exercises drop constraint if exists exercises_type_check;
alter table public.exercises
  add constraint exercises_type_check
  check (type in (
    'multiple_choice','fill_blank','matching',
    'listening','speaking','writing'
  ));

-- ============== SEED ==============
do $$
declare
  v_lang_id   bigint;
  v_course_id bigint;
  v_lesson_id bigint;

  -- A1 sections in their canonical 1..15 order (matches 015_spanish_restructure_15x8.sql)
  section_names text[] := array[
    'Greetings','Numbers','Colors','Family','Food',
    'Time','Weather','Shopping','Animals','Body Parts',
    'Clothes','House & Home','Transport','Days & Months','Basic Verbs'
  ];

  -- 7 writing prompts per section, indexed [section_idx][lesson_idx 1..7].
  -- The English text becomes the question shown to the candidate.
  writing_prompts text[][] := array[
    -- 1: Greetings (tier 1)
    array['Write a greeting in Spanish for the morning.',
          'Write how you would say "Good evening" in Spanish.',
          'Write a goodbye in Spanish.',
          'Write a sentence introducing yourself by name.',
          'Write a sentence asking someone how they are.',
          'Write how you would say "Pleased to meet you" in Spanish.',
          'Write one polite greeting you could use with a stranger.'],
    -- 2: Numbers
    array['Write your age in a Spanish sentence.',
          'Write the numbers from one to three in Spanish.',
          'Write how many brothers or sisters you have.',
          'Write a sentence with a phone number in Spanish.',
          'Write the year you were born in Spanish.',
          'Write how many days are in a week in Spanish.',
          'Write the number 10 in Spanish.'],
    -- 3: Colors
    array['Write the color of the sky in Spanish.',
          'Write what color grass is in Spanish.',
          'Write your favorite color in a sentence.',
          'Write the color of a banana in Spanish.',
          'Write the color of an apple in Spanish.',
          'Write one sentence with two colors in it.',
          'Write the color of your shirt today.'],
    -- 4: Family
    array['Write a sentence about your mother.',
          'Write a sentence saying if you have brothers.',
          'Write a sentence about your father.',
          'Write a sentence about your grandparents.',
          'Write the name of one family member.',
          'Write how many people are in your family.',
          'Write a sentence with the word "familia" in it.'],
    -- 5: Food
    array['Write what you ate today in Spanish.',
          'Write a sentence about your favorite food.',
          'Write what you drink in the morning.',
          'Write a Spanish sentence asking for water.',
          'Write a sentence with the word "pan".',
          'Write what fruit you like.',
          'Write a sentence about cheese in Spanish.'],
    -- 6: Time (tier 2)
    array['Write what time you wake up. Use 1-2 sentences.',
          'Write what you do in the afternoon. 1-2 sentences.',
          'Write what time you eat lunch.',
          'Write a sentence saying what time it is right now.',
          'Write what time you go to bed and why.',
          'Write 1-2 sentences about your morning schedule.',
          'Write the days of the week you work or study.'],
    -- 7: Weather
    array['Describe the weather today in Spanish. 1-2 sentences.',
          'Write what you wear when it is cold. 1-2 sentences.',
          'Write a sentence about your favorite season.',
          'Write a Spanish sentence about a sunny day.',
          'Describe last weekend''s weather in 1-2 sentences.',
          'Write 1-2 sentences about rain in Spanish.',
          'Write what season you like and why.'],
    -- 8: Shopping
    array['Write what you bought last weekend. 1-2 sentences.',
          'Write a Spanish sentence asking the price of something.',
          'Write 1-2 sentences about your favorite store.',
          'Write a sentence ordering a coffee at a café.',
          'Write what fruit you buy at the market. 1-2 sentences.',
          'Write what you need from the supermarket today.',
          'Write a polite sentence to thank a shop assistant.'],
    -- 9: Animals
    array['Write what animals you like. 1-2 sentences.',
          'Write a sentence describing a dog or a cat.',
          'Write about an animal you saw recently. 1-2 sentences.',
          'Write your favorite animal and one fact about it.',
          'Write a sentence about a pet you have or want.',
          'Write 1-2 sentences about a zoo animal.',
          'Write a sentence with the word "perro" in it.'],
    -- 10: Body Parts
    array['Write what body parts you use to walk. 1-2 sentences.',
          'Write what hurts when you are sick. 1-2 sentences.',
          'Write a sentence describing your hair.',
          'Write a Spanish sentence about your eyes.',
          'Write 1-2 sentences about how you feel today.',
          'Write a sentence saying something hurts.',
          'Write a sentence with the word "cabeza" in it.'],
    -- 11: Clothes (tier 3)
    array['Describe what you are wearing right now in two full sentences.',
          'Write two sentences about what clothes you wear in winter.',
          'Write two sentences about your favorite outfit and when you wear it.',
          'Write two sentences about clothes you wear to work or school.',
          'Write two sentences about a shop where you buy clothes.',
          'Write two sentences about your favorite color of clothing.',
          'Write two sentences about clothes you wear on the weekend.'],
    -- 12: House & Home
    array['Describe your house in two full sentences.',
          'Write two sentences about your favorite room.',
          'Write two sentences about your bedroom.',
          'Write two sentences about the kitchen in your house.',
          'Write two sentences about something you have at home.',
          'Write two sentences about where you live.',
          'Write two sentences about your neighborhood.'],
    -- 13: Transport
    array['Write two sentences about how you get to work or school.',
          'Write two sentences about a recent trip.',
          'Write two sentences about your favorite way to travel.',
          'Write two sentences about a city you would like to visit.',
          'Write two sentences about taking the bus or train.',
          'Write two sentences about a road trip you took.',
          'Write two sentences about an airport visit.'],
    -- 14: Days & Months
    array['Write two sentences about what you do on weekends.',
          'Write two sentences saying when your birthday is.',
          'Write two sentences about your typical week.',
          'Write two sentences about your favorite month and why.',
          'Write two sentences about a holiday you celebrate.',
          'Write two sentences about Monday mornings.',
          'Write two sentences about what season we are in.'],
    -- 15: Basic Verbs
    array['Write two sentences about what you do every morning.',
          'Write two sentences about your daily routine.',
          'Write two sentences about what you eat and drink in a day.',
          'Write two sentences about what you do after work or school.',
          'Write two sentences about your hobbies.',
          'Write two sentences about your family using common verbs.',
          'Write two sentences about your favorite activity.']
  ];

  -- Speaking topic prompts (English) — drive the monologue recorder.
  speaking_prompts text[][] := array[
    -- 1: Greetings
    array['Greet someone in Spanish and say your name. Speak two sentences.',
          'Tell someone "Good morning" and ask how they are. Two sentences.',
          'Introduce yourself and say where you are from. Two sentences.',
          'Say goodbye and tell someone you will see them tomorrow. Two sentences.',
          'Greet a teacher politely and say your name. Two sentences.',
          'Say hello and ask someone their name. Two sentences.',
          'Welcome a guest to your home in Spanish. Two sentences.'],
    -- 2: Numbers
    array['Say your age and ask someone their age in Spanish. Two sentences.',
          'Count from one to ten in Spanish.',
          'Say your phone number aloud in Spanish.',
          'Say how many brothers and sisters you have. Two sentences.',
          'Say the year you were born and the year right now. Two sentences.',
          'Say how many people are in your family. Two sentences.',
          'Count the days of the week aloud in Spanish.'],
    -- 3: Colors
    array['Name three colors you see right now. Two sentences.',
          'Describe the colors of your clothes today. Two sentences.',
          'Tell me your favorite color and one thing that is that color. Two sentences.',
          'Describe a rainbow in Spanish. Two sentences.',
          'Say the color of the sky and the color of grass. Two sentences.',
          'Describe the colors in your bedroom. Two sentences.',
          'Tell me two colors you do not like and why. Two sentences.'],
    -- 4: Family
    array['Introduce your family in Spanish. Two sentences.',
          'Describe your mother in Spanish. Two sentences.',
          'Describe your father in Spanish. Two sentences.',
          'Say how many siblings you have and their names. Two sentences.',
          'Tell me about your grandparents. Two sentences.',
          'Say who lives in your house. Two sentences.',
          'Talk about a family member you are close to. Two sentences.'],
    -- 5: Food
    array['Tell me what you usually eat for breakfast. Two sentences.',
          'Describe your favorite meal. Two sentences.',
          'Order a drink at a café in Spanish. Two sentences.',
          'Tell me what fruit you like and why. Two sentences.',
          'Talk about what you ate yesterday. Two sentences.',
          'Describe a typical dinner at home. Two sentences.',
          'Talk about a food you do not like. Two sentences.'],
    -- 6: Time (tier 2)
    array['Tell me what time you wake up and what you do first. 2-3 sentences.',
          'Tell me what time you eat lunch and with whom. 2-3 sentences.',
          'Tell me what time it is now and what you usually do at this hour.',
          'Describe your morning schedule in 2-3 sentences.',
          'Say what time you go to bed and why. 2-3 sentences.',
          'Tell me which day of the week is your favorite. 2-3 sentences.',
          'Describe what you do on a typical evening. 2-3 sentences.'],
    -- 7: Weather
    array['Describe today''s weather and what you are wearing. 2-3 sentences.',
          'Tell me about the weather in your hometown. 2-3 sentences.',
          'Say what you like to do when it rains. 2-3 sentences.',
          'Describe your favorite season and why. 2-3 sentences.',
          'Tell me about the worst weather you remember. 2-3 sentences.',
          'Describe a sunny day in Spanish. 2-3 sentences.',
          'Talk about what you wear in summer. 2-3 sentences.'],
    -- 8: Shopping
    array['Tell me what you bought recently and where. 2-3 sentences.',
          'Order a coffee and something to eat at a café. 2-3 sentences.',
          'Tell me about your favorite store. 2-3 sentences.',
          'Ask a shopkeeper for the price of something. 2-3 sentences.',
          'Describe what you need from the supermarket. 2-3 sentences.',
          'Talk about how you pay when you shop. 2-3 sentences.',
          'Say what gift you would buy for a friend. 2-3 sentences.'],
    -- 9: Animals
    array['Talk about your favorite animal. 2-3 sentences.',
          'Describe a pet you have or want. 2-3 sentences.',
          'Tell me about an animal you saw recently. 2-3 sentences.',
          'Describe a dog and a cat. 2-3 sentences.',
          'Talk about which animals live near where you live. 2-3 sentences.',
          'Describe an animal from the zoo. 2-3 sentences.',
          'Say which animals you would not want as pets. 2-3 sentences.'],
    -- 10: Body Parts
    array['Describe how you feel today. 2-3 sentences.',
          'Say what body parts hurt when you exercise. 2-3 sentences.',
          'Describe your hair and your eyes. 2-3 sentences.',
          'Talk about what you do when you have a headache. 2-3 sentences.',
          'Tell me what you use to walk and to write. 2-3 sentences.',
          'Describe what you do when you feel tired. 2-3 sentences.',
          'Talk about how to stay healthy. 2-3 sentences.'],
    -- 11: Clothes (tier 3)
    array['Describe what you are wearing right now in detail. 3-4 sentences.',
          'Tell me about your favorite outfit and when you wear it. 3-4 sentences.',
          'Describe the clothes you wear in winter and in summer. 3-4 sentences.',
          'Talk about a shop where you buy clothes. 3-4 sentences.',
          'Describe what you wear to work or school. 3-4 sentences.',
          'Tell me about your favorite shoes. 3-4 sentences.',
          'Describe the clothes a friend wears. 3-4 sentences.'],
    -- 12: House & Home
    array['Describe your house or apartment in detail. 3-4 sentences.',
          'Describe your favorite room and why. 3-4 sentences.',
          'Tell me about your bedroom. 3-4 sentences.',
          'Talk about the kitchen in your home. 3-4 sentences.',
          'Describe where you live and the neighborhood. 3-4 sentences.',
          'Tell me what you would change about your home. 3-4 sentences.',
          'Describe a typical Saturday at home. 3-4 sentences.'],
    -- 13: Transport
    array['Describe how you get to work or school every day. 3-4 sentences.',
          'Tell me about a recent trip. 3-4 sentences.',
          'Describe a city you would like to visit and how to get there. 3-4 sentences.',
          'Talk about your favorite way to travel. 3-4 sentences.',
          'Describe a difficult journey you remember. 3-4 sentences.',
          'Tell me about taking the bus or the train in your city. 3-4 sentences.',
          'Describe an airport you have been to. 3-4 sentences.'],
    -- 14: Days & Months
    array['Describe what you usually do on weekends. 3-4 sentences.',
          'Tell me about your typical week. 3-4 sentences.',
          'Talk about your birthday month and why you like it. 3-4 sentences.',
          'Describe an important holiday in your country. 3-4 sentences.',
          'Tell me about your favorite day of the week. 3-4 sentences.',
          'Describe what you did last weekend. 3-4 sentences.',
          'Talk about your plans for the next weekend. 3-4 sentences.'],
    -- 15: Basic Verbs
    array['Describe your daily routine in 3-4 sentences.',
          'Tell me about what you do every morning. 3-4 sentences.',
          'Describe your evening routine. 3-4 sentences.',
          'Talk about your hobbies and free time. 3-4 sentences.',
          'Describe a typical Saturday using common verbs. 3-4 sentences.',
          'Tell me what you and your family do together. 3-4 sentences.',
          'Describe your favorite activity in detail. 3-4 sentences.']
  ];

  -- Listening: the Spanish text that the TTS reads aloud, then user types
  -- a Spanish response. correct_answer = a reference response used as
  -- grading context (not shown to the user).
  listening_audio text[][] := array[
    -- 1: Greetings
    array['Hola, ¿cómo te llamas?',
          'Buenos días. ¿Cómo estás hoy?',
          'Adiós, hasta mañana.',
          'Mucho gusto. Soy Ana.',
          'Hola. ¿De dónde eres?',
          'Buenas tardes, ¿qué tal?',
          'Encantado. ¿Tú eres nuevo?'],
    -- 2: Numbers
    array['¿Cuántos años tienes?',
          'Cuenta hasta tres en español.',
          '¿Cuántos hermanos tienes?',
          'Dime tu número de teléfono.',
          '¿En qué año naciste?',
          '¿Cuántos días hay en una semana?',
          'Cuenta hasta diez.'],
    -- 3: Colors
    array['¿Cuál es tu color favorito?',
          '¿De qué color es el cielo?',
          'Dime tres colores en español.',
          '¿De qué color es una manzana?',
          '¿Qué color te gusta llevar?',
          '¿De qué color es tu camisa hoy?',
          'Nombra un color de la bandera de tu país.'],
    -- 4: Family
    array['¿Tienes hermanos?',
          '¿Cómo se llama tu madre?',
          'Háblame de tu familia.',
          '¿Cuántas personas viven en tu casa?',
          '¿Cómo son tus abuelos?',
          '¿Tienes hijos o sobrinos?',
          '¿Quién es tu mejor amigo en la familia?'],
    -- 5: Food
    array['¿Qué te gusta comer?',
          '¿Qué desayunas normalmente?',
          'Dime tu plato favorito.',
          '¿Qué bebes por la mañana?',
          '¿Comes mucha fruta?',
          '¿Te gusta el queso?',
          'Dime un postre que te guste.'],
    -- 6: Time
    array['¿A qué hora te levantas?',
          '¿Qué haces por la tarde?',
          '¿A qué hora comes?',
          '¿Qué hora es ahora?',
          '¿A qué hora te acuestas?',
          'Dime tres cosas que haces por la mañana.',
          '¿Qué día es hoy?'],
    -- 7: Weather
    array['¿Cómo está el tiempo hoy?',
          '¿Qué llevas puesto cuando hace frío?',
          '¿Cuál es tu estación favorita?',
          '¿Te gusta la lluvia?',
          'Háblame del tiempo de este fin de semana.',
          '¿Hace sol en tu ciudad?',
          '¿Qué tiempo prefieres para salir?'],
    -- 8: Shopping
    array['¿Qué quieres comprar?',
          'Buenos días, ¿qué desea tomar?',
          '¿Cuánto cuesta esto?',
          '¿Dónde vas de compras normalmente?',
          '¿Necesitas algo del supermercado?',
          '¿Pagas con tarjeta o en efectivo?',
          '¿Qué regalo le comprarías a tu amigo?'],
    -- 9: Animals
    array['¿Tienes una mascota?',
          'Háblame de tu animal favorito.',
          '¿Has visto un animal interesante hoy?',
          '¿Te gustan los perros o los gatos?',
          'Dime un animal que vive en tu ciudad.',
          '¿Qué animal te da miedo?',
          '¿Conoces un animal grande?'],
    -- 10: Body Parts
    array['¿Te duele la cabeza?',
          '¿Cómo te sientes hoy?',
          'Dime una parte del cuerpo.',
          '¿Qué usas para escribir?',
          'Háblame de tu pelo.',
          '¿Te duele algo después de caminar?',
          '¿Cómo cuidas tu salud?'],
    -- 11: Clothes
    array['¿Qué llevas puesto hoy?',
          'Háblame de tu ropa favorita.',
          '¿Qué te pones en invierno?',
          '¿Dónde compras tu ropa?',
          '¿Llevas zapatos cómodos?',
          '¿Qué te pones para una fiesta?',
          'Describe la ropa de un amigo.'],
    -- 12: House & Home
    array['¿Cómo es tu casa?',
          'Háblame de tu cuarto favorito.',
          '¿Vives en una casa o un apartamento?',
          '¿Cómo es tu cocina?',
          '¿Te gusta tu barrio?',
          'Describe tu dormitorio.',
          '¿Qué te gustaría cambiar de tu casa?'],
    -- 13: Transport
    array['¿Cómo vienes a clase?',
          'Háblame de un viaje reciente.',
          '¿Cómo prefieres viajar?',
          '¿A qué ciudad te gustaría ir?',
          '¿Usas mucho el transporte público?',
          'Cuéntame un viaje difícil que recuerdes.',
          '¿Conoces algún aeropuerto?'],
    -- 14: Days & Months
    array['¿Qué haces los fines de semana?',
          '¿Cuándo es tu cumpleaños?',
          '¿Cuál es tu día favorito y por qué?',
          'Háblame de un día festivo en tu país.',
          '¿Qué planes tienes para el sábado?',
          '¿Qué hiciste el lunes pasado?',
          '¿En qué mes estamos?'],
    -- 15: Basic Verbs
    array['¿Qué haces todos los días?',
          'Háblame de tu rutina matinal.',
          '¿A qué hora cenas normalmente?',
          '¿Qué haces antes de dormir?',
          '¿Cuáles son tus pasatiempos?',
          '¿Qué te gusta hacer los domingos?',
          'Cuéntame una actividad que disfrutas.']
  ];

  -- Reference Spanish responses used as context to the AI grader (not shown
  -- to the candidate). Indexed [section_idx][lesson_idx].
  listening_reference text[][] := array[
    -- 1
    array['Me llamo Ana y mucho gusto.',
          'Buenos días, estoy bien gracias.',
          'Adiós, hasta mañana.',
          'Encantado, yo soy David.',
          'Soy de México.',
          'Buenas tardes, todo bien.',
          'Sí, soy nuevo aquí.'],
    -- 2
    array['Tengo veinte años.',
          'Uno, dos, tres.',
          'Tengo dos hermanos.',
          'Mi número es uno dos tres.',
          'Nací en el año dos mil.',
          'Hay siete días en una semana.',
          'Uno, dos, tres, cuatro, cinco, seis, siete, ocho, nueve, diez.'],
    -- 3
    array['Mi color favorito es el azul.',
          'El cielo es azul.',
          'Rojo, verde y amarillo.',
          'Una manzana es roja.',
          'Me gusta el negro.',
          'Mi camisa es blanca.',
          'Mi bandera tiene rojo y blanco.'],
    -- 4
    array['Sí, tengo dos hermanos.',
          'Mi madre se llama María.',
          'Mi familia es pequeña pero unida.',
          'Vivimos cinco personas en casa.',
          'Mis abuelos son muy amables.',
          'No tengo hijos.',
          'Mi hermana es mi mejor amiga.'],
    -- 5
    array['Me gusta la pizza.',
          'Desayuno café y tostadas.',
          'Mi plato favorito es la paella.',
          'Bebo café por la mañana.',
          'Sí, como mucha fruta.',
          'Sí, me encanta el queso.',
          'Me gusta el chocolate.'],
    -- 6
    array['Me levanto a las siete.',
          'Por la tarde estudio en casa.',
          'Como a la una y media.',
          'Son las tres de la tarde.',
          'Me acuesto a las once de la noche.',
          'Me ducho, desayuno y voy a trabajar.',
          'Hoy es martes.'],
    -- 7
    array['Hoy hace sol y calor.',
          'Cuando hace frío llevo un abrigo.',
          'Mi estación favorita es el verano.',
          'Sí, me gusta la lluvia a veces.',
          'Este fin de semana va a llover.',
          'Sí, hace mucho sol en mi ciudad.',
          'Prefiero un día soleado y fresco.'],
    -- 8
    array['Quiero comprar un libro nuevo.',
          'Quiero un café con leche, por favor.',
          'Cuesta diez euros.',
          'Voy de compras al centro comercial.',
          'Necesito pan y leche.',
          'Pago con tarjeta normalmente.',
          'Le compraría un libro.'],
    -- 9
    array['Sí, tengo un gato pequeño.',
          'Mi animal favorito es el perro.',
          'Sí, vi un pájaro hoy.',
          'Me gustan más los perros.',
          'En mi ciudad viven palomas.',
          'Me dan miedo las arañas.',
          'Conozco al elefante, es muy grande.'],
    -- 10
    array['No, me siento bien.',
          'Hoy me siento cansado.',
          'La cabeza es una parte del cuerpo.',
          'Uso las manos para escribir.',
          'Mi pelo es corto y negro.',
          'Sí, me duelen los pies.',
          'Como bien y duermo ocho horas.'],
    -- 11
    array['Llevo unos pantalones y una camiseta azul.',
          'Mi ropa favorita es cómoda y sencilla.',
          'En invierno llevo un abrigo y una bufanda.',
          'Compro mi ropa en tiendas pequeñas.',
          'Sí, llevo zapatos muy cómodos.',
          'Me pongo un vestido elegante.',
          'Mi amigo lleva ropa deportiva.'],
    -- 12
    array['Mi casa es pequeña pero acogedora.',
          'Mi cuarto favorito es la sala.',
          'Vivo en un apartamento.',
          'Mi cocina es luminosa y nueva.',
          'Sí, mi barrio es muy tranquilo.',
          'Mi dormitorio es pequeño y blanco.',
          'Me gustaría una cocina más grande.'],
    -- 13
    array['Vengo en autobús todos los días.',
          'El mes pasado viajé a la playa.',
          'Prefiero viajar en tren.',
          'Me gustaría ir a Madrid.',
          'Sí, uso el metro a diario.',
          'Una vez perdí el avión.',
          'Conozco el aeropuerto de mi ciudad.'],
    -- 14
    array['Los fines de semana salgo con amigos.',
          'Mi cumpleaños es el quince de mayo.',
          'Mi día favorito es el viernes.',
          'Celebramos la Navidad en familia.',
          'El sábado voy al cine.',
          'El lunes pasado trabajé mucho.',
          'Estamos en el mes de junio.'],
    -- 15
    array['Todos los días estudio y trabajo.',
          'Por la mañana desayuno y me ducho.',
          'Ceno a las nueve normalmente.',
          'Antes de dormir leo un libro.',
          'Mis pasatiempos son la música y el deporte.',
          'Los domingos descanso con mi familia.',
          'Disfruto mucho pintando los fines de semana.']
  ];

  i int;
  lesson_idx int;
begin
  select id into v_lang_id from public.languages where code = 'spanish';
  if v_lang_id is null then raise exception 'Spanish language not found'; end if;

  for i in 1..array_length(section_names, 1) loop
    select id into v_course_id
    from public.courses
    where language_id = v_lang_id
      and cefr_level = 'A1'
      and title = section_names[i]
    limit 1;

    if v_course_id is null then continue; end if;

    for lesson_idx in 1..7 loop
      select id into v_lesson_id
      from public.lessons
      where course_id = v_course_id
        and order_index = lesson_idx
      limit 1;

      if v_lesson_id is null then continue; end if;

      -- Replace the existing speaking / listening / writing rows on this
      -- lesson with the new AI-graded versions. MC + fill_blank + matching
      -- exercises are left untouched.
      delete from public.exercises
      where lesson_id = v_lesson_id
        and type in ('listening','speaking','writing');

      insert into public.exercises
        (lesson_id, type, question, correct_answer, wrong_answers, order_index)
      values
        (v_lesson_id, 'writing',
         writing_prompts[i][lesson_idx],
         '',
         array[]::text[],
         100),
        (v_lesson_id, 'speaking',
         speaking_prompts[i][lesson_idx],
         '',
         array[]::text[],
         101),
        (v_lesson_id, 'listening',
         listening_audio[i][lesson_idx],
         listening_reference[i][lesson_idx],
         array[]::text[],
         102);
    end loop;
  end loop;
end $$;

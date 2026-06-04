-- 029_spanish_a1_conversation_complete.sql
-- Self-contained replacement for migrations 021 + 028.
--
-- Use this if lesson 8 of A1 still shows the "Coming Soon - Premium podcast
-- and video content" placeholder text. Running 028 alone does not fix that
-- because 028 only updates the comprehension exercises — it expects lesson 8
-- to already be a 'conversation' lesson with the dialogue attached (which is
-- what 021 sets up).
--
-- This migration does everything in one file:
--   1. Ensures the lessons.type check constraint includes 'conversation' and
--      'unit_test' (no-op if it already does).
--   2. For every Spanish A1 section, rewrites lesson 8:
--        type         = 'conversation'
--        title        = '<Section> — Conversation Practice'
--        description  = friendly summary of the dialogue
--        intro        = framing text shown before the dialogue plays
--        vocab_items  = []  (the dialogue does the teaching)
--        grammar_note = null
--        dialogue     = realistic dialogue using vocab from lessons 1-7
--   3. Deletes any existing exercises on lesson 8 and inserts 6 new
--      comprehension exercises (mix of multiple_choice, true/false rendered
--      as multiple_choice, and fill_blank short-answer).
--
-- Fully idempotent.

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
  v_l8        bigint;
begin
  select id into v_lang_id from public.languages where code = 'spanish';

  -- ============== A1.1 GREETINGS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Greetings';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Greetings — Conversation Practice',
    description = 'Listen to two strangers meeting for the first time, then answer the comprehension questions.',
    intro = 'Two people meet for the first time and exchange names and where they''re from. Use what you learned about greetings and introductions to follow along.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Carlos","spanish":"¡Hola! Buenos días.","english":"Hi! Good morning."},
      {"speaker":"Ana","spanish":"¡Hola! Buenos días. ¿Cómo te llamas?","english":"Hi! Good morning. What is your name?"},
      {"speaker":"Carlos","spanish":"Me llamo Carlos. ¿Y tú?","english":"My name is Carlos. And you?"},
      {"speaker":"Ana","spanish":"Soy Ana. Mucho gusto.","english":"I am Ana. Pleased to meet you."},
      {"speaker":"Carlos","spanish":"Encantado. ¿De dónde eres?","english":"Nice to meet you. Where are you from?"},
      {"speaker":"Ana","spanish":"Soy de Madrid. Hasta luego.","english":"I am from Madrid. See you later."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','What is the man''s name?','Carlos',array['Pedro','Luis','Antonio'],'Me llamo Carlos',1),
    (v_l8,'multiple_choice','Where is Ana from?','Madrid',array['Barcelona','Sevilla','Mexico'],'Soy de Madrid',2),
    (v_l8,'multiple_choice','What time of day is it?','Morning',array['Afternoon','Evening','Night'],'Buenos días',3),
    (v_l8,'multiple_choice','True or false: Carlos and Ana are friends from before.','False',array['True'],'They meet for the first time and exchange names',4),
    (v_l8,'fill_blank','Complete Ana''s reply: "____ Ana." (I am)','Soy',array['Me llamo','Llamarse','Es'],'I am Ana',5),
    (v_l8,'multiple_choice','How does Carlos respond to "Mucho gusto"?','Encantado',array['Adiós','Gracias','Tengo hambre'],'Encantado',6);

  -- ============== A1.2 NUMBERS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Numbers';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Numbers — Conversation Practice',
    description = 'Two people meet and share their ages and how many siblings they have.',
    intro = 'A short small-talk conversation about ages and family counts. Listen for the numbers.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Lucía","spanish":"Hola, buenas tardes. ¿Cómo estás?","english":"Hi, good afternoon. How are you?"},
      {"speaker":"Diego","spanish":"Bien, gracias. ¿Cuántos años tienes?","english":"Fine, thanks. How old are you?"},
      {"speaker":"Lucía","spanish":"Tengo veintidós años. ¿Y tú?","english":"I am twenty-two. And you?"},
      {"speaker":"Diego","spanish":"Yo tengo diecinueve.","english":"I am nineteen."},
      {"speaker":"Lucía","spanish":"¿Tienes hermanos?","english":"Do you have siblings?"},
      {"speaker":"Diego","spanish":"Sí, tengo dos. Hasta luego.","english":"Yes, I have two. See you later."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','How old is Lucía?','22',array['12','20','29'],'Tengo veintidós años',1),
    (v_l8,'multiple_choice','How old is Diego?','19',array['9','29','12'],'Tengo diecinueve',2),
    (v_l8,'multiple_choice','How many siblings does Diego have?','2',array['1','3','none'],'Tengo dos',3),
    (v_l8,'multiple_choice','True or false: Diego is older than Lucía.','False',array['True'],'Lucía 22, Diego 19',4),
    (v_l8,'fill_blank','Complete Lucía''s line: "Tengo ____ años." (twenty-two)','veintidós',array['veintidos','veinte y dos','veinte-dos'],'twenty-two',5),
    (v_l8,'multiple_choice','How does Lucía start the conversation?','Buenas tardes',array['Buenos días','Buenas noches','Adiós'],'Good afternoon',6);

  -- ============== A1.3 COLORS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Colors';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Colors — Conversation Practice',
    description = 'Two friends compare the colors of their shirts.',
    intro = 'Listen as Mateo and Sofía talk about their favorite colors and how many shirts they own. Combines colors with the numbers and greetings from earlier sections.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Mateo","spanish":"Hola Sofía. Mira mi camisa.","english":"Hi Sofía. Look at my shirt."},
      {"speaker":"Sofía","spanish":"¡Qué bonita! ¿De qué color es?","english":"How pretty! What color is it?"},
      {"speaker":"Mateo","spanish":"Es azul. Tengo tres camisas azules.","english":"It is blue. I have three blue shirts."},
      {"speaker":"Sofía","spanish":"A mí me gusta el rojo.","english":"I like red."},
      {"speaker":"Mateo","spanish":"¿Cuántas tienes?","english":"How many do you have?"},
      {"speaker":"Sofía","spanish":"Dos rojas y una verde.","english":"Two red and one green."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','What color is Mateo''s shirt?','Blue',array['Red','Green','Black'],'Es azul',1),
    (v_l8,'multiple_choice','How many blue shirts does Mateo have?','3',array['2','1','5'],'Tres camisas azules',2),
    (v_l8,'multiple_choice','What color does Sofía like best?','Red',array['Blue','Green','Yellow'],'Me gusta el rojo',3),
    (v_l8,'multiple_choice','True or false: Sofía has more red shirts than green.','True',array['False'],'Dos rojas y una verde',4),
    (v_l8,'fill_blank','Complete Sofía''s line: "Dos rojas y una ____" (green)','verde',array['verdes','verda','vverde'],'green',5),
    (v_l8,'multiple_choice','How many shirts do Mateo and Sofía have in total?','6',array['5','4','7'],'3 (Mateo) + 2 + 1 (Sofía)',6);

  -- ============== A1.4 FAMILY ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Family';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Family — Conversation Practice',
    description = 'Two friends talk about their families.',
    intro = 'A conversation that uses family members along with names, ages and basic greetings from earlier sections.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Pablo","spanish":"Hola. Mi familia es grande. Tengo dos hermanos y una hermana.","english":"Hi. My family is big. I have two brothers and a sister."},
      {"speaker":"Marta","spanish":"¿Cómo se llama tu hermana?","english":"What is your sister''s name?"},
      {"speaker":"Pablo","spanish":"Se llama Carmen. Tiene quince años.","english":"Her name is Carmen. She is fifteen."},
      {"speaker":"Marta","spanish":"¿Y tu madre?","english":"And your mother?"},
      {"speaker":"Pablo","spanish":"Mi madre se llama Ana. Mi padre se llama Luis.","english":"My mother is named Ana. My father is named Luis."},
      {"speaker":"Marta","spanish":"Yo soy hija única.","english":"I am an only child."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','How many brothers does Pablo have?','2',array['1','3','none'],'Dos hermanos',1),
    (v_l8,'multiple_choice','How old is Pablo''s sister?','15',array['5','25','50'],'Tiene quince años',2),
    (v_l8,'multiple_choice','What is Pablo''s mother called?','Ana',array['Carmen','Marta','Lucía'],'Mi madre se llama Ana',3),
    (v_l8,'multiple_choice','True or false: Marta is an only child.','True',array['False'],'Soy hija única',4),
    (v_l8,'fill_blank','Complete Pablo''s line: "Mi padre se ____ Luis." (is named)','llama',array['llamo','llamas','llamamos'],'is named',5),
    (v_l8,'multiple_choice','What is the sister''s name?','Carmen',array['Ana','Marta','Lucía'],'Se llama Carmen',6);

  -- ============== A1.5 FOOD ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Food';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Food — Conversation Practice',
    description = 'Two friends decide what to eat.',
    intro = 'A short food conversation. Uses food vocab plus tener hambre / quiero from earlier lessons.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Ana","spanish":"Tengo hambre. ¿Qué quieres comer?","english":"I am hungry. What do you want to eat?"},
      {"speaker":"David","spanish":"Quiero pan con queso.","english":"I want bread with cheese."},
      {"speaker":"Ana","spanish":"Yo quiero una manzana y un café.","english":"I want an apple and a coffee."},
      {"speaker":"David","spanish":"¿Café con leche?","english":"Coffee with milk?"},
      {"speaker":"Ana","spanish":"Sí, gracias. ¡Tengo mucha sed también!","english":"Yes, thanks. I''m very thirsty too!"},
      {"speaker":"David","spanish":"Quiero agua, por favor.","english":"I want water, please."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','What does David want to eat?','Bread with cheese',array['An apple','Coffee','Soup'],'Quiero pan con queso',1),
    (v_l8,'multiple_choice','What does Ana want to eat?','An apple',array['Bread','Cheese','Soup'],'Una manzana',2),
    (v_l8,'multiple_choice','What does Ana want to drink?','Coffee with milk',array['Water','Tea','Wine'],'Café con leche',3),
    (v_l8,'multiple_choice','True or false: David wants wine.','False',array['True'],'Quiero agua, por favor',4),
    (v_l8,'fill_blank','Complete Ana''s line: "____ hambre." (I am hungry)','Tengo',array['Soy','Estoy','Hay'],'I have hunger',5),
    (v_l8,'multiple_choice','Why does Ana ask David what he wants?','She is hungry',array['She is thirsty only','She is bored','She is tired'],'Tengo hambre',6);

  -- ============== A1.6 TIME ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Time';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Time — Conversation Practice',
    description = 'Two friends compare their afternoon schedules.',
    intro = 'A quick check-in about times and a class today. Uses time expressions plus tener / ir from earlier.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Eva","spanish":"Hola, ¿qué hora es?","english":"Hi, what time is it?"},
      {"speaker":"Luis","spanish":"Son las tres de la tarde.","english":"It is three in the afternoon."},
      {"speaker":"Eva","spanish":"Tengo clase a las cuatro.","english":"I have class at four."},
      {"speaker":"Luis","spanish":"¿Qué día?","english":"What day?"},
      {"speaker":"Eva","spanish":"Hoy. Lunes.","english":"Today. Monday."},
      {"speaker":"Luis","spanish":"Yo no tengo clase hoy. Tengo clase mañana.","english":"I don''t have class today. I have class tomorrow."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','What time is it?','3 PM',array['3 AM','4 PM','1 PM'],'Son las tres de la tarde',1),
    (v_l8,'multiple_choice','What time does Eva''s class start?','4',array['3','5','8'],'A las cuatro',2),
    (v_l8,'multiple_choice','What day is it?','Monday',array['Sunday','Tuesday','Friday'],'Hoy. Lunes',3),
    (v_l8,'multiple_choice','True or false: Luis has class today.','False',array['True'],'No tengo clase hoy',4),
    (v_l8,'fill_blank','Complete Luis''s line: "Tengo clase ____" (tomorrow)','mañana',array['hoy','ayer','tarde'],'tomorrow',5),
    (v_l8,'multiple_choice','Whose class is sooner — Eva''s or Luis''s?','Eva''s',array['Luis''s','Both today','Both tomorrow'],'Eva: today 4 PM; Luis: tomorrow',6);

  -- ============== A1.7 WEATHER ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Weather';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Weather — Conversation Practice',
    description = 'Two friends talk about the weather and a hot drink.',
    intro = 'A cold-day conversation combining weather phrases with food (coffee) from earlier sections.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Carmen","spanish":"Hoy hace mucho frío.","english":"Today it is very cold."},
      {"speaker":"Tomás","spanish":"Sí, hace cinco grados. Tengo frío.","english":"Yes, it is five degrees. I am cold."},
      {"speaker":"Carmen","spanish":"¿Quieres un café caliente?","english":"Do you want a hot coffee?"},
      {"speaker":"Tomás","spanish":"Sí, por favor. Mañana va a llover.","english":"Yes, please. Tomorrow it''s going to rain."},
      {"speaker":"Carmen","spanish":"¡Qué frío hace en invierno!","english":"It''s so cold in winter!"},
      {"speaker":"Tomás","spanish":"Yo prefiero el verano.","english":"I prefer summer."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','How is the weather today?','Very cold',array['Very hot','Sunny','Windy'],'Hace mucho frío',1),
    (v_l8,'multiple_choice','What is the temperature?','5 degrees',array['15 degrees','25 degrees','-5 degrees'],'Cinco grados',2),
    (v_l8,'multiple_choice','What does Carmen offer Tomás?','A hot coffee',array['Cold water','Soup','Tea'],'Un café caliente',3),
    (v_l8,'multiple_choice','True or false: It is going to rain tomorrow.','True',array['False'],'Mañana va a llover',4),
    (v_l8,'fill_blank','Complete Tomás''s line: "Yo prefiero el ____" (summer)','verano',array['invierno','otoño','primavera'],'summer',5),
    (v_l8,'multiple_choice','Why does Carmen offer hot coffee?','Because it is cold',array['Because it is raining','Because it is hot','Because it is morning'],'Hace mucho frío',6);

  -- ============== A1.8 SHOPPING ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Shopping';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Shopping — Conversation Practice',
    description = 'A customer buys two shirts at a shop.',
    intro = 'A short exchange at the till. Brings together shopping phrases, colors and numbers.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Cliente","spanish":"Hola, quiero comprar dos camisas.","english":"Hi, I want to buy two shirts."},
      {"speaker":"Vendedora","spanish":"¿De qué color?","english":"What color?"},
      {"speaker":"Cliente","spanish":"Una blanca y una negra. ¿Cuánto cuestan?","english":"One white and one black. How much are they?"},
      {"speaker":"Vendedora","spanish":"Veinte euros.","english":"Twenty euros."},
      {"speaker":"Cliente","spanish":"Pago con tarjeta, por favor.","english":"I''ll pay by card, please."},
      {"speaker":"Vendedora","spanish":"Aquí tiene. Hasta luego.","english":"Here you are. See you later."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','How many shirts does the customer want?','2',array['1','3','5'],'Dos camisas',1),
    (v_l8,'multiple_choice','What colors does the customer choose?','White and black',array['White and blue','Red and black','Black and green'],'Una blanca y una negra',2),
    (v_l8,'multiple_choice','How much do they cost in total?','20 euros',array['10 euros','25 euros','30 euros'],'Veinte euros',3),
    (v_l8,'multiple_choice','True or false: The customer pays in cash.','False',array['True'],'Pago con tarjeta',4),
    (v_l8,'fill_blank','Complete the customer''s line: "Pago con ____" (card)','tarjeta',array['efectivo','cheque','monedas'],'card',5),
    (v_l8,'multiple_choice','How does the seller say goodbye?','Hasta luego',array['Buenos días','Mucho gusto','¿Cómo estás?'],'See you later',6);

  -- ============== A1.9 ANIMALS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Animals';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Animals — Conversation Practice',
    description = 'Two friends compare their pets.',
    intro = 'A pet-themed conversation that combines animals with colors and numbers.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Sara","spanish":"¿Tienes mascotas?","english":"Do you have any pets?"},
      {"speaker":"Hugo","spanish":"Sí, tengo un perro y dos gatos.","english":"Yes, I have a dog and two cats."},
      {"speaker":"Sara","spanish":"¿De qué color son?","english":"What color are they?"},
      {"speaker":"Hugo","spanish":"El perro es marrón y los gatos son negros.","english":"The dog is brown and the cats are black."},
      {"speaker":"Sara","spanish":"¡Qué bonitos! Yo tengo un pájaro azul.","english":"How cute! I have a blue bird."},
      {"speaker":"Hugo","spanish":"Me gustan mucho los pájaros.","english":"I really like birds."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','How many pets does Hugo have in total?','3',array['2','4','5'],'Un perro y dos gatos',1),
    (v_l8,'multiple_choice','What color is the dog?','Brown',array['Black','White','Gray'],'El perro es marrón',2),
    (v_l8,'multiple_choice','What color are the cats?','Black',array['Brown','White','Gray'],'Los gatos son negros',3),
    (v_l8,'multiple_choice','True or false: Sara has a green bird.','False',array['True'],'Tengo un pájaro azul',4),
    (v_l8,'fill_blank','Complete Hugo''s line: "Me ____ los pájaros." (I like)','gustan',array['gusta','gustamos','gustáis'],'I like (pl.)',5),
    (v_l8,'multiple_choice','How does Hugo feel about birds?','He really likes them',array['He doesn''t like them','He has many','He has none'],'Me gustan mucho los pájaros',6);

  -- ============== A1.10 BODY PARTS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Body Parts';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Body Parts — Conversation Practice',
    description = 'A friend asks where it hurts.',
    intro = 'Describing aches and a small fever — combines body parts with tener / no me siento bien.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Pedro","spanish":"Hola, no me siento bien.","english":"Hi, I don''t feel well."},
      {"speaker":"María","spanish":"¿Qué te duele?","english":"What hurts?"},
      {"speaker":"Pedro","spanish":"Me duele la cabeza y los ojos.","english":"My head and eyes hurt."},
      {"speaker":"María","spanish":"¿Tienes fiebre?","english":"Do you have a fever?"},
      {"speaker":"Pedro","spanish":"Sí, un poco. Necesito un médico.","english":"Yes, a little. I need a doctor."},
      {"speaker":"María","spanish":"Voy contigo al médico.","english":"I''ll go with you to the doctor."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','How does Pedro feel?','Unwell',array['Great','Tired but fine','Happy'],'No me siento bien',1),
    (v_l8,'multiple_choice','What hurts Pedro?','Head and eyes',array['Head and stomach','Hands and feet','Back'],'Me duele la cabeza y los ojos',2),
    (v_l8,'multiple_choice','How much fever does Pedro have?','A little',array['None','A lot','Doesn''t know'],'Sí, un poco',3),
    (v_l8,'multiple_choice','True or false: Pedro wants to go to the doctor alone.','False',array['True'],'María: Voy contigo al médico',4),
    (v_l8,'fill_blank','Complete Pedro''s line: "Necesito un ____" (doctor)','médico',array['medico','medicina','medical'],'doctor',5),
    (v_l8,'multiple_choice','Who is going with Pedro to the doctor?','María',array['No one','His brother','His father'],'Voy contigo al médico',6);

  -- ============== A1.11 CLOTHES ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Clothes';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Clothes — Conversation Practice',
    description = 'Two friends compare what they''re wearing.',
    intro = 'Quick outfit comparison combining clothes vocab with colors from earlier sections.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Inés","spanish":"¿Qué llevas hoy?","english":"What are you wearing today?"},
      {"speaker":"Jorge","spanish":"Llevo una camisa blanca y pantalones negros.","english":"I''m wearing a white shirt and black trousers."},
      {"speaker":"Inés","spanish":"¿Y zapatos?","english":"And shoes?"},
      {"speaker":"Jorge","spanish":"Zapatos marrones. ¿Y tú?","english":"Brown shoes. And you?"},
      {"speaker":"Inés","spanish":"Un vestido rojo y un sombrero negro.","english":"A red dress and a black hat."},
      {"speaker":"Jorge","spanish":"¡Qué bonito!","english":"How pretty!"}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','What color is Jorge''s shirt?','White',array['Black','Blue','Red'],'Una camisa blanca',1),
    (v_l8,'multiple_choice','What color are Jorge''s trousers?','Black',array['White','Blue','Brown'],'Pantalones negros',2),
    (v_l8,'multiple_choice','What color are Jorge''s shoes?','Brown',array['Black','White','Red'],'Zapatos marrones',3),
    (v_l8,'multiple_choice','True or false: Inés wears a black dress.','False',array['True'],'Un vestido rojo',4),
    (v_l8,'fill_blank','Complete Inés''s line: "Un sombrero ____" (black)','negro',array['blanco','rojo','marrón'],'black',5),
    (v_l8,'multiple_choice','What is Jorge''s reaction to Inés''s outfit?','He likes it',array['He dislikes it','He doesn''t notice','He laughs'],'¡Qué bonito!',6);

  -- ============== A1.12 HOUSE & HOME ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'House & Home';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'House & Home — Conversation Practice',
    description = 'A friend describes her house and family.',
    intro = 'A short house-and-family conversation that uses rooms, numbers, and family vocab.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Laura","spanish":"Mi casa es grande. Tiene cuatro habitaciones.","english":"My house is big. It has four rooms."},
      {"speaker":"Roberto","spanish":"¿Dónde vives?","english":"Where do you live?"},
      {"speaker":"Laura","spanish":"Vivo en Madrid. Con mi madre y mi hermana.","english":"I live in Madrid. With my mother and my sister."},
      {"speaker":"Roberto","spanish":"¿Cuántos baños?","english":"How many bathrooms?"},
      {"speaker":"Laura","spanish":"Dos baños. Y una cocina grande.","english":"Two bathrooms. And a big kitchen."},
      {"speaker":"Roberto","spanish":"¡Qué bonito!","english":"How nice!"}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','How many rooms does the house have?','4',array['2','3','5'],'Cuatro habitaciones',1),
    (v_l8,'multiple_choice','Where does Laura live?','Madrid',array['Barcelona','Mexico','Sevilla'],'Vivo en Madrid',2),
    (v_l8,'multiple_choice','Who does Laura live with?','Mother and sister',array['Father and brother','Friends','Alone'],'Con mi madre y mi hermana',3),
    (v_l8,'multiple_choice','True or false: The house has 3 bathrooms.','False',array['True'],'Dos baños',4),
    (v_l8,'fill_blank','Complete Laura''s line: "Una ____ grande." (kitchen)','cocina',array['casa','baño','sala'],'kitchen',5),
    (v_l8,'multiple_choice','How does Laura describe her house?','Big',array['Small','Old','New'],'Mi casa es grande',6);

  -- ============== A1.13 TRANSPORT ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Transport';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Transport — Conversation Practice',
    description = 'Two colleagues compare how they get to work.',
    intro = 'A quick chat about commuting. Combines transport vocab with time and numbers.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Elena","spanish":"¿Cómo vas al trabajo?","english":"How do you go to work?"},
      {"speaker":"Pablo","spanish":"Voy en autobús. ¿Y tú?","english":"I go by bus. And you?"},
      {"speaker":"Elena","spanish":"Yo voy en bicicleta.","english":"I go by bicycle."},
      {"speaker":"Pablo","spanish":"¿Cuánto tiempo tarda?","english":"How long does it take?"},
      {"speaker":"Elena","spanish":"Veinte minutos. Salgo a las ocho.","english":"Twenty minutes. I leave at eight."},
      {"speaker":"Pablo","spanish":"Yo salgo a las siete y media.","english":"I leave at half past seven."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','How does Pablo go to work?','By bus',array['By car','By bicycle','On foot'],'Voy en autobús',1),
    (v_l8,'multiple_choice','How does Elena go to work?','By bicycle',array['By bus','By car','By train'],'Voy en bicicleta',2),
    (v_l8,'multiple_choice','How long does Elena''s commute take?','20 minutes',array['30 minutes','10 minutes','1 hour'],'Veinte minutos',3),
    (v_l8,'multiple_choice','True or false: Pablo leaves home earlier than Elena.','True',array['False'],'Pablo 7:30, Elena 8',4),
    (v_l8,'fill_blank','Complete Pablo''s line: "Yo salgo a las siete y ____" (half)','media',array['cuarto','treinta','medio'],'half',5),
    (v_l8,'multiple_choice','What time does Elena leave?','8',array['7','9','10'],'A las ocho',6);

  -- ============== A1.14 DAYS & MONTHS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Days & Months';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Days & Months — Conversation Practice',
    description = 'Two friends compare birthdays.',
    intro = 'A short conversation about today''s day and birthdays. Uses days, months, and basic numbers.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Clara","spanish":"¿Qué día es hoy?","english":"What day is today?"},
      {"speaker":"Iván","spanish":"Hoy es viernes.","english":"Today is Friday."},
      {"speaker":"Clara","spanish":"¿Y tu cumpleaños?","english":"And your birthday?"},
      {"speaker":"Iván","spanish":"Es el quince de mayo. ¿Y el tuyo?","english":"It''s May 15. And yours?"},
      {"speaker":"Clara","spanish":"El diez de enero.","english":"January 10."},
      {"speaker":"Iván","spanish":"¡Pronto! Sólo dos meses.","english":"Soon! Only two months."}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','What day of the week is it?','Friday',array['Monday','Saturday','Wednesday'],'Hoy es viernes',1),
    (v_l8,'multiple_choice','When is Iván''s birthday?','May 15',array['March 15','May 5','January 15'],'El quince de mayo',2),
    (v_l8,'multiple_choice','When is Clara''s birthday?','January 10',array['October 1','January 20','June 10'],'El diez de enero',3),
    (v_l8,'multiple_choice','True or false: Iván''s birthday is sooner than Clara''s.','False',array['True'],'Clara''s is sooner — solo dos meses',4),
    (v_l8,'fill_blank','Complete Iván''s line: "Sólo dos ____" (months)','meses',array['mes','años','semanas'],'months',5),
    (v_l8,'multiple_choice','How many months until the closer birthday?','2',array['1','3','6'],'Sólo dos meses',6);

  -- ============== A1.15 BASIC VERBS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Basic Verbs';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set
    type = 'conversation',
    title = 'Basic Verbs — Conversation Practice',
    description = 'Two students introduce themselves.',
    intro = 'A capstone conversation that uses every core verb you''ve met: ser, estar, tener, ir, hacer. Plus vocab from every earlier A1 section.',
    vocab_items = '[]'::jsonb,
    grammar_note = null,
    dialogue = '[
      {"speaker":"Daniel","spanish":"Hola. Soy estudiante. Tengo veinte años.","english":"Hi. I''m a student. I''m twenty."},
      {"speaker":"Marina","spanish":"Mucho gusto. ¿De dónde eres?","english":"Pleased to meet you. Where are you from?"},
      {"speaker":"Daniel","spanish":"Soy de México. Vivo en Madrid con mi familia.","english":"I''m from Mexico. I live in Madrid with my family."},
      {"speaker":"Marina","spanish":"¿Vas a la universidad?","english":"Do you go to university?"},
      {"speaker":"Daniel","spanish":"Sí, voy todos los días por la mañana.","english":"Yes, I go every day in the morning."},
      {"speaker":"Marina","spanish":"Yo también. ¡Hasta mañana!","english":"Me too. See you tomorrow!"}
    ]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','What is Daniel''s occupation?','Student',array['Teacher','Doctor','Engineer'],'Soy estudiante',1),
    (v_l8,'multiple_choice','How old is Daniel?','20',array['12','22','30'],'Tengo veinte años',2),
    (v_l8,'multiple_choice','Where is Daniel from?','Mexico',array['Spain','Argentina','Cuba'],'Soy de México',3),
    (v_l8,'multiple_choice','True or false: Daniel lives in Madrid alone.','False',array['True'],'Vivo en Madrid con mi familia',4),
    (v_l8,'fill_blank','Complete Daniel''s line: "____ a la universidad." (I go)','Voy',array['Vas','Va','Vamos'],'I go',5),
    (v_l8,'multiple_choice','When does Daniel go to the university?','Every morning',array['Every afternoon','Only on weekends','Never'],'Todos los días por la mañana',6);

end $$;

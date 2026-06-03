-- 021_spanish_a1_conversation_lessons.sql
-- Replaces lesson 8 of every Spanish A1 section (currently the "Coming Soon"
-- podcast placeholder) with a CONVERSATION INTERPRETATION lesson.
--
-- Each section's lesson 8 now contains:
--   - a short native-style dialogue between two speakers, written using only
--     vocabulary the learner has met in earlier lessons of the same section
--     (and earlier sections for sections 2+)
--   - 5 multiple-choice comprehension questions about the dialogue
--
-- The dialogue is stored in the existing `dialogue` jsonb column, so the
-- teaching-phase walkthrough in LessonClient renders it with TTS play
-- buttons automatically. After the dialogue phase, the user answers the
-- 5 comprehension questions.
--
-- Schema: adds 'conversation' to the lesson type check.
-- Idempotent.

alter table public.lessons drop constraint if exists lessons_type_check;
alter table public.lessons
  add constraint lessons_type_check
  check (type in ('vocabulary','grammar','phrases','listening','speaking','reading','writing','podcast','unit_test','conversation'));

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
    (v_l8,'multiple_choice','What does Ana say right after introducing herself?','Pleased to meet you',array['See you later','Good night','I am tired'],'Mucho gusto',4),
    (v_l8,'multiple_choice','How does Carlos respond to "Mucho gusto"?','Nice to meet you (m.)',array['Goodbye','Thank you','I am hungry'],'Encantado',5);

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
    (v_l8,'multiple_choice','What time of day is it?','Afternoon',array['Morning','Night','Midnight'],'Buenas tardes',4),
    (v_l8,'multiple_choice','How is Diego feeling?','Fine',array['Tired','Bad','Hungry'],'Bien, gracias',5);

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
    (v_l8,'multiple_choice','What color does Sofía like?','Red',array['Blue','Green','Yellow'],'Me gusta el rojo',3),
    (v_l8,'multiple_choice','How many red shirts does Sofía have?','2',array['1','3','5'],'Dos rojas',4),
    (v_l8,'multiple_choice','How many green shirts does Sofía have?','1',array['2','3','none'],'Una verde',5);

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
    (v_l8,'multiple_choice','What is the sister''s name?','Carmen',array['Ana','Marta','Lucía'],'Se llama Carmen',3),
    (v_l8,'multiple_choice','What is Pablo''s father called?','Luis',array['Carlos','Pablo','Diego'],'Mi padre se llama Luis',4),
    (v_l8,'multiple_choice','Does Marta have siblings?','No, she is an only child',array['Yes, two','Yes, one','Yes, three'],'Soy hija única',5);

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
    (v_l8,'multiple_choice','What does Ana want to drink?','Coffee with milk',array['Water','Tea','Wine'],'Un café con leche',3),
    (v_l8,'multiple_choice','What does David want to drink?','Water',array['Coffee','Milk','Tea'],'Quiero agua',4),
    (v_l8,'multiple_choice','How does Ana feel?','Hungry and thirsty',array['Tired','Happy','Sad'],'Tengo hambre / sed',5);

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
    (v_l8,'multiple_choice','Does Luis have class today?','No',array['Yes','Only later','Only in the morning'],'No tengo clase hoy',4),
    (v_l8,'multiple_choice','When does Luis have class?','Tomorrow',array['Today','Yesterday','Next week'],'Tengo clase mañana',5);

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
    (v_l8,'multiple_choice','What is tomorrow''s forecast?','Rain',array['Snow','Sun','Wind'],'Mañana va a llover',4),
    (v_l8,'multiple_choice','Which season does Tomás prefer?','Summer',array['Winter','Spring','Autumn'],'Prefiero el verano',5);

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
    (v_l8,'multiple_choice','How much do they cost?','20 euros',array['10 euros','25 euros','30 euros'],'Veinte euros',3),
    (v_l8,'multiple_choice','How does the customer pay?','By card',array['In cash','With check','In coins'],'Pago con tarjeta',4),
    (v_l8,'multiple_choice','How does the seller say goodbye?','See you later',array['Good morning','Pleased to meet you','How are you?'],'Hasta luego',5);

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
    (v_l8,'multiple_choice','What pet does Sara have?','A blue bird',array['A red bird','A blue fish','A green parrot'],'Un pájaro azul',4),
    (v_l8,'multiple_choice','What does Hugo say about birds?','He really likes them',array['He has many','He has none','He prefers cats'],'Me gustan mucho los pájaros',5);

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
    (v_l8,'multiple_choice','Does Pedro have a fever?','Yes, a little',array['No','High fever','He doesn''t know'],'Sí, un poco',3),
    (v_l8,'multiple_choice','What does Pedro need?','A doctor',array['Medicine','Water','To rest'],'Necesito un médico',4),
    (v_l8,'multiple_choice','What does María offer to do?','Go with him to the doctor',array['Call the doctor','Give him medicine','Leave him alone'],'Voy contigo al médico',5);

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
    (v_l8,'multiple_choice','What is Inés wearing?','A red dress',array['A black dress','A red shirt','Black trousers'],'Un vestido rojo',4),
    (v_l8,'multiple_choice','What color is Inés''s hat?','Black',array['Red','Brown','White'],'Un sombrero negro',5);

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
    (v_l8,'multiple_choice','How many bathrooms?','2',array['1','3','4'],'Dos baños',4),
    (v_l8,'multiple_choice','How is the kitchen?','Big',array['Small','New','Old'],'Una cocina grande',5);

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
    (v_l8,'multiple_choice','What time does Elena leave?','8',array['7','9','10'],'A las ocho',4),
    (v_l8,'multiple_choice','What time does Pablo leave?','7:30',array['8:30','7:00','8:00'],'A las siete y media',5);

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
    (v_l8,'multiple_choice','Whose birthday is sooner?','Clara''s',array['Iván''s','Both on the same day','Neither'],'¡Pronto! Sólo dos meses',4),
    (v_l8,'multiple_choice','How many months until the closer birthday?','2',array['1','3','6'],'Sólo dos meses',5);

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
    (v_l8,'multiple_choice','Where does Daniel live now?','Madrid',array['Mexico City','Barcelona','Sevilla'],'Vivo en Madrid',4),
    (v_l8,'multiple_choice','When does Daniel go to the university?','Every morning',array['Every afternoon','Only on weekends','Never'],'Todos los días por la mañana',5);

end $$;

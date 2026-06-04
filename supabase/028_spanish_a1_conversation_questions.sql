-- 028_spanish_a1_conversation_questions.sql
-- Brings A1 lesson 8 (conversation practice) into line with A2 lesson 8.
--
-- Migration 021 already replaced every A1 section's lesson 8 with a
-- conversation dialogue plus 5 multiple-choice comprehension questions.
-- The newer A2 pattern (migration 027) uses 6 questions per section,
-- mixing multiple_choice, true/false rendered as MC, and fill_blank
-- short-answer. This migration upgrades A1 to the same shape, leaving
-- the dialogues from 021 unchanged.
--
-- For each A1 section it:
--   1. Deletes the existing exercises for lesson 8.
--   2. Inserts 6 new comprehension exercises in the A2 mix.
--
-- Idempotent: deletes + re-inserts on every run.

do $$
declare
  v_lang_id   bigint;
  v_course_id bigint;
  v_l8        bigint;
begin
  select id into v_lang_id from public.languages where code = 'spanish';

  -- ============== A1.1 GREETINGS ==============
  -- Dialogue: Carlos & Ana introduce themselves, exchange greetings,
  -- Ana is from Madrid.
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Greetings';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','What is the man''s name?','Carlos',array['Pedro','Luis','Antonio'],'Me llamo Carlos',1),
    (v_l8,'multiple_choice','Where is Ana from?','Madrid',array['Barcelona','Sevilla','Mexico'],'Soy de Madrid',2),
    (v_l8,'multiple_choice','What time of day is it?','Morning',array['Afternoon','Evening','Night'],'Buenos días',3),
    (v_l8,'multiple_choice','True or false: Carlos and Ana are friends from before.','False',array['True'],'They meet for the first time and exchange names',4),
    (v_l8,'fill_blank','Complete Ana''s reply: "____ Ana." (My name is)','Soy',array['Me llamo','Llamarse','Es'],'I am Ana',5),
    (v_l8,'multiple_choice','How does Carlos respond to "Mucho gusto"?','Encantado',array['Adiós','Gracias','Tengo hambre'],'Encantado',6);

  -- ============== A1.2 NUMBERS ==============
  -- Dialogue: Lucía (22) and Diego (19) compare ages and siblings.
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Numbers';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','How old is Lucía?','22',array['12','20','29'],'Tengo veintidós años',1),
    (v_l8,'multiple_choice','How old is Diego?','19',array['9','29','12'],'Tengo diecinueve',2),
    (v_l8,'multiple_choice','How many siblings does Diego have?','2',array['1','3','none'],'Tengo dos',3),
    (v_l8,'multiple_choice','True or false: Diego is older than Lucía.','False',array['True'],'Lucía 22, Diego 19',4),
    (v_l8,'fill_blank','Complete Lucía''s line: "Tengo ____ años." (twenty-two)','veintidós',array['veintidos','veinte y dos','veinte-dos'],'twenty-two',5),
    (v_l8,'multiple_choice','How does Lucía start the conversation?','Buenas tardes',array['Buenos días','Buenas noches','Adiós'],'Good afternoon',6);

  -- ============== A1.3 COLORS ==============
  -- Dialogue: Mateo (3 blue shirts) and Sofía (2 red, 1 green) talk shirts.
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Colors';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','What color is Mateo''s shirt?','Blue',array['Red','Green','Black'],'Es azul',1),
    (v_l8,'multiple_choice','How many blue shirts does Mateo have?','3',array['2','1','5'],'Tres camisas azules',2),
    (v_l8,'multiple_choice','What color does Sofía like best?','Red',array['Blue','Green','Yellow'],'Me gusta el rojo',3),
    (v_l8,'multiple_choice','True or false: Sofía has more red shirts than green.','True',array['False'],'Dos rojas y una verde',4),
    (v_l8,'fill_blank','Complete Sofía''s line: "Dos rojas y una ____" (green)','verde',array['verdes','verda','vverde'],'green',5),
    (v_l8,'multiple_choice','How many shirts do Mateo and Sofía have in total?','6',array['5','4','7'],'3 (Mateo) + 2 + 1 (Sofía)',6);

  -- ============== A1.4 FAMILY ==============
  -- Dialogue: Pablo has 2 brothers + sister Carmen (15). Mother Ana, father
  -- Luis. Marta is an only child.
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Family';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','How many brothers does Pablo have?','2',array['1','3','none'],'Dos hermanos',1),
    (v_l8,'multiple_choice','How old is Pablo''s sister?','15',array['5','25','50'],'Tiene quince años',2),
    (v_l8,'multiple_choice','What is Pablo''s mother called?','Ana',array['Carmen','Marta','Lucía'],'Mi madre se llama Ana',3),
    (v_l8,'multiple_choice','True or false: Marta is an only child.','True',array['False'],'Soy hija única',4),
    (v_l8,'fill_blank','Complete Pablo''s line: "Mi padre se ____ Luis." (is named)','llama',array['llamo','llamas','llamamos'],'is named',5),
    (v_l8,'multiple_choice','What is the sister''s name?','Carmen',array['Ana','Marta','Lucía'],'Se llama Carmen',6);

  -- ============== A1.5 FOOD ==============
  -- Dialogue: Ana wants apple + coffee with milk. David wants bread with
  -- cheese + water. Both are hungry / thirsty.
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Food';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','What does David want to eat?','Bread with cheese',array['An apple','Coffee','Soup'],'Quiero pan con queso',1),
    (v_l8,'multiple_choice','What does Ana want to eat?','An apple',array['Bread','Cheese','Soup'],'Una manzana',2),
    (v_l8,'multiple_choice','What does Ana want to drink?','Coffee with milk',array['Water','Tea','Wine'],'Café con leche',3),
    (v_l8,'multiple_choice','True or false: David wants wine.','False',array['True'],'Quiero agua, por favor',4),
    (v_l8,'fill_blank','Complete Ana''s line: "____ hambre." (I am hungry)','Tengo',array['Soy','Estoy','Hay'],'I have hunger',5),
    (v_l8,'multiple_choice','Why does Ana ask David what he wants?','She is hungry',array['She is thirsty only','She is bored','She is tired'],'Tengo hambre',6);

  -- ============== A1.6 TIME ==============
  -- Dialogue: 3 PM Monday. Eva has class at 4 today. Luis has class
  -- tomorrow, not today.
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Time';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','What time is it?','3 PM',array['3 AM','4 PM','1 PM'],'Son las tres de la tarde',1),
    (v_l8,'multiple_choice','What time does Eva''s class start?','4',array['3','5','8'],'A las cuatro',2),
    (v_l8,'multiple_choice','What day is it?','Monday',array['Sunday','Tuesday','Friday'],'Hoy. Lunes',3),
    (v_l8,'multiple_choice','True or false: Luis has class today.','False',array['True'],'No tengo clase hoy',4),
    (v_l8,'fill_blank','Complete Luis''s line: "Tengo clase ____" (tomorrow)','mañana',array['hoy','ayer','tarde'],'tomorrow',5),
    (v_l8,'multiple_choice','Whose class is sooner — Eva''s or Luis''s?','Eva''s',array['Luis''s','Both today','Both tomorrow'],'Eva: today 4 PM; Luis: tomorrow',6);

  -- ============== A1.7 WEATHER ==============
  -- Dialogue: Cold day, 5 degrees. Carmen offers hot coffee. Tomorrow rain.
  -- Tomás prefers summer.
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Weather';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','How is the weather today?','Very cold',array['Very hot','Sunny','Windy'],'Hace mucho frío',1),
    (v_l8,'multiple_choice','What is the temperature?','5 degrees',array['15 degrees','25 degrees','-5 degrees'],'Cinco grados',2),
    (v_l8,'multiple_choice','What does Carmen offer Tomás?','A hot coffee',array['Cold water','Soup','Tea'],'Un café caliente',3),
    (v_l8,'multiple_choice','True or false: It is going to rain tomorrow.','True',array['False'],'Mañana va a llover',4),
    (v_l8,'fill_blank','Complete Tomás''s line: "Yo prefiero el ____" (summer)','verano',array['invierno','otoño','primavera'],'summer',5),
    (v_l8,'multiple_choice','Why does Carmen offer hot coffee?','Because it is cold',array['Because it is raining','Because it is hot','Because it is morning'],'Hace mucho frío',6);

  -- ============== A1.8 SHOPPING ==============
  -- Dialogue: Customer buys 1 white + 1 black shirt for 20 euros, pays by card.
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Shopping';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','How many shirts does the customer want?','2',array['1','3','5'],'Dos camisas',1),
    (v_l8,'multiple_choice','What colors does the customer choose?','White and black',array['White and blue','Red and black','Black and green'],'Una blanca y una negra',2),
    (v_l8,'multiple_choice','How much do they cost in total?','20 euros',array['10 euros','25 euros','30 euros'],'Veinte euros',3),
    (v_l8,'multiple_choice','True or false: The customer pays in cash.','False',array['True'],'Pago con tarjeta',4),
    (v_l8,'fill_blank','Complete the customer''s line: "Pago con ____" (card)','tarjeta',array['efectivo','cheque','monedas'],'card',5),
    (v_l8,'multiple_choice','How does the seller say goodbye?','Hasta luego',array['Buenos días','Mucho gusto','¿Cómo estás?'],'See you later',6);

  -- ============== A1.9 ANIMALS ==============
  -- Dialogue: Hugo has 1 brown dog + 2 black cats. Sara has 1 blue bird.
  -- Hugo likes birds a lot.
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Animals';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','How many pets does Hugo have in total?','3',array['2','4','5'],'Un perro y dos gatos',1),
    (v_l8,'multiple_choice','What color is the dog?','Brown',array['Black','White','Gray'],'El perro es marrón',2),
    (v_l8,'multiple_choice','What color are the cats?','Black',array['Brown','White','Gray'],'Los gatos son negros',3),
    (v_l8,'multiple_choice','True or false: Sara has a green bird.','False',array['True'],'Tengo un pájaro azul',4),
    (v_l8,'fill_blank','Complete Hugo''s line: "Me ____ los pájaros." (I like)','gustan',array['gusta','gustamos','gustáis'],'I like (pl.)',5),
    (v_l8,'multiple_choice','How does Hugo feel about birds?','He really likes them',array['He doesn''t like them','He has many','He has none'],'Me gustan mucho los pájaros',6);

  -- ============== A1.10 BODY PARTS ==============
  -- Dialogue: Pedro feels unwell. Head and eyes hurt. Has a little fever.
  -- Needs a doctor. María offers to go with him.
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Body Parts';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','How does Pedro feel?','Unwell',array['Great','Tired but fine','Happy'],'No me siento bien',1),
    (v_l8,'multiple_choice','What hurts Pedro?','Head and eyes',array['Head and stomach','Hands and feet','Back'],'Me duele la cabeza y los ojos',2),
    (v_l8,'multiple_choice','How much fever does Pedro have?','A little',array['None','A lot','Doesn''t know'],'Sí, un poco',3),
    (v_l8,'multiple_choice','True or false: Pedro wants to go to the doctor alone.','False',array['True'],'María: Voy contigo al médico',4),
    (v_l8,'fill_blank','Complete Pedro''s line: "Necesito un ____" (doctor)','médico',array['medico','medicina','medical'],'doctor',5),
    (v_l8,'multiple_choice','Who is going with Pedro to the doctor?','María',array['No one','His brother','His father'],'Voy contigo al médico',6);

  -- ============== A1.11 CLOTHES ==============
  -- Dialogue: Jorge wears white shirt, black trousers, brown shoes. Inés
  -- wears red dress + black hat.
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Clothes';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','What color is Jorge''s shirt?','White',array['Black','Blue','Red'],'Una camisa blanca',1),
    (v_l8,'multiple_choice','What color are Jorge''s trousers?','Black',array['White','Blue','Brown'],'Pantalones negros',2),
    (v_l8,'multiple_choice','What color are Jorge''s shoes?','Brown',array['Black','White','Red'],'Zapatos marrones',3),
    (v_l8,'multiple_choice','True or false: Inés wears a black dress.','False',array['True'],'Un vestido rojo',4),
    (v_l8,'fill_blank','Complete Inés''s line: "Un sombrero ____" (black)','negro',array['blanco','rojo','marrón'],'black',5),
    (v_l8,'multiple_choice','What is Jorge''s reaction to Inés''s outfit?','He likes it',array['He dislikes it','He doesn''t notice','He laughs'],'¡Qué bonito!',6);

  -- ============== A1.12 HOUSE & HOME ==============
  -- Dialogue: Laura lives in Madrid with mother and sister. House has 4
  -- rooms, 2 bathrooms, big kitchen.
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'House & Home';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','How many rooms does the house have?','4',array['2','3','5'],'Cuatro habitaciones',1),
    (v_l8,'multiple_choice','Where does Laura live?','Madrid',array['Barcelona','Mexico','Sevilla'],'Vivo en Madrid',2),
    (v_l8,'multiple_choice','Who does Laura live with?','Mother and sister',array['Father and brother','Friends','Alone'],'Con mi madre y mi hermana',3),
    (v_l8,'multiple_choice','True or false: The house has 3 bathrooms.','False',array['True'],'Dos baños',4),
    (v_l8,'fill_blank','Complete Laura''s line: "Una ____ grande." (kitchen)','cocina',array['casa','baño','sala'],'kitchen',5),
    (v_l8,'multiple_choice','How does Laura describe her house?','Big',array['Small','Old','New'],'Mi casa es grande',6);

  -- ============== A1.13 TRANSPORT ==============
  -- Dialogue: Pablo by bus, Elena by bike (20 min). Elena leaves at 8,
  -- Pablo at 7:30.
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Transport';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','How does Pablo go to work?','By bus',array['By car','By bicycle','On foot'],'Voy en autobús',1),
    (v_l8,'multiple_choice','How does Elena go to work?','By bicycle',array['By bus','By car','By train'],'Voy en bicicleta',2),
    (v_l8,'multiple_choice','How long does Elena''s commute take?','20 minutes',array['30 minutes','10 minutes','1 hour'],'Veinte minutos',3),
    (v_l8,'multiple_choice','True or false: Pablo leaves home earlier than Elena.','True',array['False'],'Pablo 7:30, Elena 8',4),
    (v_l8,'fill_blank','Complete Pablo''s line: "Yo salgo a las siete y ____" (half)','media',array['cuarto','treinta','medio'],'half',5),
    (v_l8,'multiple_choice','What time does Elena leave?','8',array['7','9','10'],'A las ocho',6);

  -- ============== A1.14 DAYS & MONTHS ==============
  -- Dialogue: Friday today. Iván''s birthday May 15, Clara''s January 10.
  -- Clara''s is sooner — only two months.
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Days & Months';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','What day of the week is it?','Friday',array['Monday','Saturday','Wednesday'],'Hoy es viernes',1),
    (v_l8,'multiple_choice','When is Iván''s birthday?','May 15',array['March 15','May 5','January 15'],'El quince de mayo',2),
    (v_l8,'multiple_choice','When is Clara''s birthday?','January 10',array['October 1','January 20','June 10'],'El diez de enero',3),
    (v_l8,'multiple_choice','True or false: Iván''s birthday is sooner than Clara''s.','False',array['True'],'Clara''s is sooner — solo dos meses',4),
    (v_l8,'fill_blank','Complete Iván''s line: "Sólo dos ____" (months)','meses',array['mes','años','semanas'],'months',5),
    (v_l8,'multiple_choice','How many months until the closer birthday?','2',array['1','3','6'],'Sólo dos meses',6);

  -- ============== A1.15 BASIC VERBS ==============
  -- Dialogue: Daniel is a 20-year-old student from Mexico, lives in Madrid
  -- with family, goes to university every morning.
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Basic Verbs';
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l8,'multiple_choice','What is Daniel''s occupation?','Student',array['Teacher','Doctor','Engineer'],'Soy estudiante',1),
    (v_l8,'multiple_choice','How old is Daniel?','20',array['12','22','30'],'Tengo veinte años',2),
    (v_l8,'multiple_choice','Where is Daniel from?','Mexico',array['Spain','Argentina','Cuba'],'Soy de México',3),
    (v_l8,'multiple_choice','True or false: Daniel lives in Madrid alone.','False',array['True'],'Vivo en Madrid con mi familia',4),
    (v_l8,'fill_blank','Complete Daniel''s line: "____ a la universidad." (I go)','Voy',array['Vas','Va','Vamos'],'I go',5),
    (v_l8,'multiple_choice','When does Daniel go to the university?','Every morning',array['Every afternoon','Only on weekends','Never'],'Todos los días por la mañana',6);

end $$;

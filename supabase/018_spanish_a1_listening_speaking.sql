-- 018_spanish_a1_listening_speaking.sql
-- Ensures every substantive A1 lesson has at least 2 listening + 2 speaking
-- exercises. Lessons 4 (Listening) and 5 (Speaking) already meet the bar.
-- This migration adds 2 listening + 2 speaking exercises (at order_index
-- 6..9) to lessons 1, 2, 3, 6, 7 of every A1 section.
--
-- 15 sections x 5 lessons x 4 added exercises = 300 new exercises.
-- Idempotent: deletes only exercises at order_index >= 6 on those lessons
-- before reinserting.

do $$
declare
  v_lang_id   bigint;
  v_course_id bigint;
  v_l1 bigint; v_l2 bigint; v_l3 bigint;
  v_l6 bigint; v_l7 bigint;
begin
  select id into v_lang_id from public.languages where code = 'spanish';

  -- ====== A1.1 GREETINGS ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Greetings';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','Hola',array['Goodbye','Thank you','Please'],'Hello',6),
    (v_l1,'listening','Listen and pick the English meaning.','Buenos días',array['Good night','See you later','Pleased to meet you'],'Good morning',7),
    (v_l1,'speaking','Say this aloud: "Hola." [OH-lah]','Hola',array[]::text[],'Hello',8),
    (v_l1,'speaking','Say this aloud: "Adiós." [ah-DYOHS]','Adiós',array[]::text[],'Goodbye',9),
    (v_l2,'listening','Listen and pick the English meaning.','¿Cómo estás?',array['How are you? (formal)','What is your name?','Where are you from?'],'How are you? (informal)',6),
    (v_l2,'listening','Listen and pick the English meaning.','¿Cómo está usted?',array['How are you? (informal)','What is your name?','How old are you?'],'How are you? (formal)',7),
    (v_l2,'speaking','Say this aloud: "Yo soy Carlos." [yoh SOY KAR-lohs]','Yo soy Carlos',array[]::text[],'I am Carlos.',8),
    (v_l2,'speaking','Say this aloud: "¿Cómo está usted?" [KOH-moh ehs-TAH oos-TEHD]','¿Cómo está usted?',array[]::text[],'How are you? (formal)',9),
    (v_l3,'listening','Listen and pick the English meaning.','Mucho gusto',array['Goodbye','Thank you','Please'],'Pleased to meet you',6),
    (v_l3,'listening','Listen and pick the English meaning.','Hasta luego',array['Good morning','Pleased to meet you','How are you?'],'See you later',7),
    (v_l3,'speaking','Say this aloud: "Encantado." [ehn-kahn-TAH-doh]','Encantado',array[]::text[],'Pleased to meet you (m.)',8),
    (v_l3,'speaking','Say this aloud: "Bien, gracias." [BYEHN GRAH-syahs]','Bien, gracias',array[]::text[],'Fine, thanks.',9),
    (v_l6,'listening','Listen and pick the English meaning.','Soy de Madrid',array['I live in Madrid','I love Madrid','I go to Madrid'],'I am from Madrid',6),
    (v_l6,'listening','Listen and pick the English meaning.','Me llamo Ana',array['I call Ana','Ana calls me','I see Ana'],'My name is Ana',7),
    (v_l6,'speaking','Say this aloud: "Soy de México." [SOY deh MEH-hee-koh]','Soy de México',array[]::text[],'I am from Mexico.',8),
    (v_l6,'speaking','Say this aloud: "¿De dónde eres?" [deh DOHN-deh EH-rehs]','¿De dónde eres?',array[]::text[],'Where are you from?',9),
    (v_l7,'listening','Listen and pick the English meaning.','Querido Juan',array['Dear John','Goodbye John','Thank you John'],'Dear Juan',6),
    (v_l7,'listening','Listen and pick the English meaning.','Un saludo',array['A goodbye','A friend','A greeting'],'Best wishes',7),
    (v_l7,'speaking','Say this aloud: "Querida Ana." [keh-REE-dah AH-nah]','Querida Ana',array[]::text[],'Dear Ana.',8),
    (v_l7,'speaking','Say this aloud: "Un saludo." [oon sah-LOO-doh]','Un saludo',array[]::text[],'Best wishes.',9);

  -- ====== A1.2 NUMBERS ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Numbers';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','cinco',array['fifteen','fifty','five hundred'],'five',6),
    (v_l1,'listening','Listen and pick the English meaning.','diez',array['twelve','two','one hundred'],'ten',7),
    (v_l1,'speaking','Say this aloud: "tres." [TREHS]','tres',array[]::text[],'three',8),
    (v_l1,'speaking','Say this aloud: "diez." [DYEHS]','diez',array[]::text[],'ten',9),
    (v_l2,'listening','Listen and pick the English meaning.','un libro',array['one book (f.)','two books','the book'],'one book',6),
    (v_l2,'listening','Listen and pick the English meaning.','una manzana',array['the apple','one apple (m.)','two apples'],'one apple',7),
    (v_l2,'speaking','Say this aloud: "Tengo dos perros." [TEHN-goh dohs PEH-rrohs]','Tengo dos perros',array[]::text[],'I have two dogs.',8),
    (v_l2,'speaking','Say this aloud: "una mesa." [OO-nah MEH-sah]','una mesa',array[]::text[],'one table',9),
    (v_l3,'listening','Listen and pick the English meaning.','¿Cuántos años tienes?',array['How are you?','Where do you live?','How much does it cost?'],'How old are you?',6),
    (v_l3,'listening','Listen and pick the English meaning.','Son las cinco',array['It is fifteen','I have five','It is five o''clock'],'It is five o''clock',7),
    (v_l3,'speaking','Say this aloud: "Tengo veinte años." [TEHN-goh BEHN-teh AH-nyohs]','Tengo veinte años',array[]::text[],'I am twenty years old.',8),
    (v_l3,'speaking','Say this aloud: "¿Cuánto cuesta?" [KWAHN-toh KWEHS-tah]','¿Cuánto cuesta?',array[]::text[],'How much does it cost?',9),
    (v_l6,'listening','Listen and pick the English meaning.','Hay veinte estudiantes',array['I have 20 students','There are 20 students','I see 20 students'],'There are 20 students',6),
    (v_l6,'listening','Listen and pick the English meaning.','Tengo treinta años',array['I have 13 things','I am 30 years old','I have 30 dogs'],'I am 30 years old',7),
    (v_l6,'speaking','Say this aloud: "Tengo tres libros." [TEHN-goh trehs LEE-brohs]','Tengo tres libros',array[]::text[],'I have three books.',8),
    (v_l6,'speaking','Say this aloud: "Mi número es ocho." [mee NOO-meh-roh ehs OH-choh]','Mi número es ocho',array[]::text[],'My number is eight.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Cuesta diez euros',array['I have 10 euros','It costs 10 euros','Ten more euros'],'It costs 10 euros',6),
    (v_l7,'listening','Listen and pick the English meaning.','A las dos',array['It is 2 o''clock','At 2 o''clock','I have 2 things'],'At 2 o''clock',7),
    (v_l7,'speaking','Say this aloud: "Son las cinco." [sohn lahs SEEN-koh]','Son las cinco',array[]::text[],'It is 5 o''clock.',8),
    (v_l7,'speaking','Say this aloud: "Cuesta cien euros." [KWEHS-tah SYEHN EH-oo-rohs]','Cuesta cien euros',array[]::text[],'It costs 100 euros.',9);

  -- ====== A1.3 COLORS ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Colors';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','rojo',array['blue','green','yellow'],'red',6),
    (v_l1,'listening','Listen and pick the English meaning.','amarillo',array['orange','red','black'],'yellow',7),
    (v_l1,'speaking','Say this aloud: "azul." [ah-SOOL]','azul',array[]::text[],'blue',8),
    (v_l1,'speaking','Say this aloud: "verde." [BEHR-deh]','verde',array[]::text[],'green',9),
    (v_l2,'listening','Listen and pick the English meaning.','La casa es blanca',array['I want a white house','The house is white','The house is mine'],'The house is white',6),
    (v_l2,'listening','Listen and pick the English meaning.','Los zapatos son negros',array['I need black shoes','The shoes are black','I see black shoes'],'The shoes are black',7),
    (v_l2,'speaking','Say this aloud: "La casa es roja." [lah KAH-sah ehs ROH-hah]','La casa es roja',array[]::text[],'The house is red.',8),
    (v_l2,'speaking','Say this aloud: "Los gatos son negros." [lohs GAH-tohs sohn NEH-grohs]','Los gatos son negros',array[]::text[],'The cats are black.',9),
    (v_l3,'listening','Listen and pick the English meaning.','¿De qué color es?',array['What color is it?','What is its size?','What color do you like?'],'What color is it?',6),
    (v_l3,'listening','Listen and pick the English meaning.','Me gusta el azul',array['I see blue','I want blue','I like blue'],'I like blue',7),
    (v_l3,'speaking','Say this aloud: "Mi color favorito es el azul." [mee koh-LOHR fah-boh-REE-toh ehs ehl ah-SOOL]','Mi color favorito es el azul',array[]::text[],'My favorite color is blue.',8),
    (v_l3,'speaking','Say this aloud: "¿De qué color es?" [deh keh koh-LOHR ehs]','¿De qué color es?',array[]::text[],'What color is it?',9),
    (v_l6,'listening','Listen and pick the English meaning.','Tengo una casa blanca',array['I want a white house','I have a white house','I live in a white house'],'I have a white house',6),
    (v_l6,'listening','Listen and pick the English meaning.','Mi gato es negro',array['My dog is black','My cat is white','My cat is black'],'My cat is black',7),
    (v_l6,'speaking','Say this aloud: "Mi coche es rojo." [mee KOH-cheh ehs ROH-hoh]','Mi coche es rojo',array[]::text[],'My car is red.',8),
    (v_l6,'speaking','Say this aloud: "Las flores son amarillas." [lahs FLOH-rehs sohn ah-mah-REE-yahs]','Las flores son amarillas',array[]::text[],'The flowers are yellow.',9),
    (v_l7,'listening','Listen and pick the English meaning.','La pared es verde',array['The plant is green','The wall is green','The plant is in the wall'],'The wall is green',6),
    (v_l7,'listening','Listen and pick the English meaning.','Mi camisa es azul',array['My shirt is yellow','My pants are blue','My shirt is blue'],'My shirt is blue',7),
    (v_l7,'speaking','Say this aloud: "El cielo es azul." [ehl SYEH-loh ehs ah-SOOL]','El cielo es azul',array[]::text[],'The sky is blue.',8),
    (v_l7,'speaking','Say this aloud: "Me gusta el verde." [meh GOOS-tah ehl BEHR-deh]','Me gusta el verde',array[]::text[],'I like green.',9);

  -- ====== A1.4 FAMILY ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Family';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','madre',array['father','sister','grandmother'],'mother',6),
    (v_l1,'listening','Listen and pick the English meaning.','hermano',array['sister','cousin','uncle'],'brother',7),
    (v_l1,'speaking','Say this aloud: "padre." [PAH-dreh]','padre',array[]::text[],'father',8),
    (v_l1,'speaking','Say this aloud: "hermana." [ehr-MAH-nah]','hermana',array[]::text[],'sister',9),
    (v_l2,'listening','Listen and pick the English meaning.','mi madre',array['your mother','my father','my sister'],'my mother',6),
    (v_l2,'listening','Listen and pick the English meaning.','tu padre',array['my father','your father','your mother'],'your father',7),
    (v_l2,'speaking','Say this aloud: "Mi madre es Ana." [mee MAH-dreh ehs AH-nah]','Mi madre es Ana',array[]::text[],'My mother is Ana.',8),
    (v_l2,'speaking','Say this aloud: "Mis hermanos." [mees ehr-MAH-nohs]','Mis hermanos',array[]::text[],'My siblings.',9),
    (v_l3,'listening','Listen and pick the English meaning.','¿Tienes hermanos?',array['Are you a sibling?','Do you have siblings?','Where is your brother?'],'Do you have siblings?',6),
    (v_l3,'listening','Listen and pick the English meaning.','Mi familia es grande',array['I love my family','My family is small','My family is big'],'My family is big',7),
    (v_l3,'speaking','Say this aloud: "Tengo dos hermanas." [TEHN-goh dohs ehr-MAH-nahs]','Tengo dos hermanas',array[]::text[],'I have two sisters.',8),
    (v_l3,'speaking','Say this aloud: "Soy hijo único." [SOY EE-hoh OO-nee-koh]','Soy hijo único',array[]::text[],'I am an only child.',9),
    (v_l6,'listening','Listen and pick the English meaning.','Mi madre se llama Carmen',array['My mother is called Carmen','My friend Carmen','I am called Carmen'],'My mother is called Carmen',6),
    (v_l6,'listening','Listen and pick the English meaning.','Vivimos juntos',array['We meet up','We live together','We work together'],'We live together',7),
    (v_l6,'speaking','Say this aloud: "Mi familia es pequeña." [mee fah-MEE-lyah ehs peh-KEH-nyah]','Mi familia es pequeña',array[]::text[],'My family is small.',8),
    (v_l6,'speaking','Say this aloud: "Mi padre se llama Luis." [mee PAH-dreh seh YAH-mah LWEES]','Mi padre se llama Luis',array[]::text[],'My father is called Luis.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Mi padre es médico',array['My father is a teacher','My father is a doctor','My father has a doctor'],'My father is a doctor',6),
    (v_l7,'listening','Listen and pick the English meaning.','Vivimos en Madrid',array['We are in Madrid','We live in Madrid','We work in Madrid'],'We live in Madrid',7),
    (v_l7,'speaking','Say this aloud: "Tengo un hermano y una hermana." [TEHN-goh oon ehr-MAH-noh ee OO-nah ehr-MAH-nah]','Tengo un hermano y una hermana',array[]::text[],'I have a brother and a sister.',8),
    (v_l7,'speaking','Say this aloud: "Mi familia es grande." [mee fah-MEE-lyah ehs GRAHN-deh]','Mi familia es grande',array[]::text[],'My family is big.',9);

  -- ====== A1.5 FOOD ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Food';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','pan',array['rice','water','cheese'],'bread',6),
    (v_l1,'listening','Listen and pick the English meaning.','agua',array['milk','wine','oil'],'water',7),
    (v_l1,'speaking','Say this aloud: "leche." [LEH-cheh]','leche',array[]::text[],'milk',8),
    (v_l1,'speaking','Say this aloud: "queso." [KEH-soh]','queso',array[]::text[],'cheese',9),
    (v_l2,'listening','Listen and pick the English meaning.','el pan',array['a bread','some bread','the bread'],'the bread',6),
    (v_l2,'listening','Listen and pick the English meaning.','una manzana',array['the apple','an apple','two apples'],'an apple',7),
    (v_l2,'speaking','Say this aloud: "Me gusta el café." [meh GOOS-tah ehl kah-FEH]','Me gusta el café',array[]::text[],'I like coffee.',8),
    (v_l2,'speaking','Say this aloud: "Quiero una manzana." [KYEH-roh OO-nah mahn-SAH-nah]','Quiero una manzana',array[]::text[],'I want an apple.',9),
    (v_l3,'listening','Listen and pick the English meaning.','Tengo hambre',array['I am thirsty','I am tired','I am hungry'],'I am hungry',6),
    (v_l3,'listening','Listen and pick the English meaning.','Buen provecho',array['Good morning','Enjoy your meal','See you later'],'Enjoy your meal',7),
    (v_l3,'speaking','Say this aloud: "Tengo sed." [TEHN-goh SEHD]','Tengo sed',array[]::text[],'I am thirsty.',8),
    (v_l3,'speaking','Say this aloud: "La cuenta, por favor." [lah KWEHN-tah pohr fah-VOHR]','La cuenta, por favor',array[]::text[],'The bill, please.',9),
    (v_l6,'listening','Listen and pick the English meaning.','Desayuno pan con queso',array['I have bread for dinner','I have bread with cheese for breakfast','I have cheese with milk'],'I have bread with cheese for breakfast',6),
    (v_l6,'listening','Listen and pick the English meaning.','Bebo mucha agua',array['I drink a lot of milk','I drink a lot of water','I want a lot of water'],'I drink a lot of water',7),
    (v_l6,'speaking','Say this aloud: "Como una manzana." [KOH-moh OO-nah mahn-SAH-nah]','Como una manzana',array[]::text[],'I eat an apple.',8),
    (v_l6,'speaking','Say this aloud: "Para cenar, sopa." [PAH-rah seh-NAHR SOH-pah]','Para cenar, sopa',array[]::text[],'For dinner, soup.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Quiero un café con leche',array['I want a tea with milk','I want a coffee with milk','I drink coffee with milk'],'I want a coffee with milk',6),
    (v_l7,'listening','Listen and pick the English meaning.','La sopa está caliente',array['The soup is cold','The soup is hot','The soup is here'],'The soup is hot',7),
    (v_l7,'speaking','Say this aloud: "Me gusta el pan fresco." [meh GOOS-tah ehl PAHN FREHS-koh]','Me gusta el pan fresco',array[]::text[],'I like fresh bread.',8),
    (v_l7,'speaking','Say this aloud: "Bebo agua durante el día." [BEH-boh AH-gwah doo-RAHN-teh ehl DEE-ah]','Bebo agua durante el día',array[]::text[],'I drink water during the day.',9);

  -- ====== A1.6 TIME ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Time';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','hora',array['day','year','month'],'hour',6),
    (v_l1,'listening','Listen and pick the English meaning.','semana',array['year','day','month'],'week',7),
    (v_l1,'speaking','Say this aloud: "día." [DEE-ah]','día',array[]::text[],'day',8),
    (v_l1,'speaking','Say this aloud: "año." [AH-nyoh]','año',array[]::text[],'year',9),
    (v_l2,'listening','Listen and pick the English meaning.','Son las tres',array['It is 1 o''clock','It is 3 o''clock','I have 3'],'It is 3 o''clock',6),
    (v_l2,'listening','Listen and pick the English meaning.','Es la una',array['It is 11','It is 1 o''clock','I see one'],'It is 1 o''clock',7),
    (v_l2,'speaking','Say this aloud: "Son las cinco y media." [sohn lahs SEEN-koh ee MEH-dyah]','Son las cinco y media',array[]::text[],'It is 5:30.',8),
    (v_l2,'speaking','Say this aloud: "Es la una en punto." [ehs lah OO-nah ehn POON-toh]','Es la una en punto',array[]::text[],'It is 1 o''clock sharp.',9),
    (v_l3,'listening','Listen and pick the English meaning.','¿Qué hora es?',array['What time is it?','What day is it?','How are you?'],'What time is it?',6),
    (v_l3,'listening','Listen and pick the English meaning.','A las diez',array['At 10','I have 10','It is 10'],'At 10',7),
    (v_l3,'speaking','Say this aloud: "A las ocho de la mañana." [ah lahs OH-choh deh lah mah-NYAH-nah]','A las ocho de la mañana',array[]::text[],'At 8 in the morning.',8),
    (v_l3,'speaking','Say this aloud: "Por la noche." [pohr lah NOH-cheh]','Por la noche',array[]::text[],'At night.',9),
    (v_l6,'listening','Listen and pick the English meaning.','Tengo una reunión a las diez',array['I have a class at 10','I have a meeting at 10','I have a coffee at 10'],'I have a meeting at 10',6),
    (v_l6,'listening','Listen and pick the English meaning.','Por la tarde voy al gimnasio',array['In the morning I go to the gym','In the afternoon I go to the gym','At night I go to the gym'],'In the afternoon I go to the gym',7),
    (v_l6,'speaking','Say this aloud: "Hoy es martes." [oy ehs MAR-tehs]','Hoy es martes',array[]::text[],'Today is Tuesday.',8),
    (v_l6,'speaking','Say this aloud: "Ceno a las nueve." [SEH-noh ah lahs NWEH-beh]','Ceno a las nueve',array[]::text[],'I have dinner at 9.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Hoy es lunes',array['Yesterday was Monday','Today is Monday','Tomorrow is Monday'],'Today is Monday',6),
    (v_l7,'listening','Listen and pick the English meaning.','Son las ocho de la mañana',array['It is 8 PM','It is 8 AM','I get up at 8'],'It is 8 AM',7),
    (v_l7,'speaking','Say this aloud: "Tengo clase a las nueve." [TEHN-goh KLAH-seh ah lahs NWEH-beh]','Tengo clase a las nueve',array[]::text[],'I have class at 9.',8),
    (v_l7,'speaking','Say this aloud: "Por la mañana." [pohr lah mah-NYAH-nah]','Por la mañana',array[]::text[],'In the morning.',9);

  -- ====== A1.7 WEATHER ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Weather';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','Hace sol',array['It is cold','It is sunny','It is hot'],'It is sunny',6),
    (v_l1,'listening','Listen and pick the English meaning.','Hace frío',array['It is hot','It is cold','It is rainy'],'It is cold',7),
    (v_l1,'speaking','Say this aloud: "Llueve mucho." [YWEH-beh MOO-choh]','Llueve mucho',array[]::text[],'It rains a lot.',8),
    (v_l1,'speaking','Say this aloud: "Hace calor." [AH-seh kah-LOHR]','Hace calor',array[]::text[],'It is hot.',9),
    (v_l2,'listening','Listen and pick the English meaning.','Está nublado',array['It is raining','It is sunny','It is cloudy'],'It is cloudy',6),
    (v_l2,'listening','Listen and pick the English meaning.','Hay viento',array['There is fog','There is wind','There is snow'],'There is wind',7),
    (v_l2,'speaking','Say this aloud: "Tengo frío." [TEHN-goh FREE-oh]','Tengo frío',array[]::text[],'I am cold.',8),
    (v_l2,'speaking','Say this aloud: "Llueve hoy." [YWEH-beh OY]','Llueve hoy',array[]::text[],'It rains today.',9),
    (v_l3,'listening','Listen and pick the English meaning.','¿Qué tiempo hace?',array['What time is it?','What is the weather like?','How are you?'],'What is the weather like?',6),
    (v_l3,'listening','Listen and pick the English meaning.','Hace buen tiempo',array['The weather is bad','The weather is nice','I have good weather'],'The weather is nice',7),
    (v_l3,'speaking','Say this aloud: "Hace buen tiempo hoy." [AH-seh BWEHN TYEHM-poh OY]','Hace buen tiempo hoy',array[]::text[],'The weather is nice today.',8),
    (v_l3,'speaking','Say this aloud: "Tengo calor." [TEHN-goh kah-LOHR]','Tengo calor',array[]::text[],'I am hot.',9),
    (v_l6,'listening','Listen and pick the English meaning.','La temperatura es de treinta grados',array['The temperature is 13','The temperature is 30','The temperature is 3'],'The temperature is 30 degrees',6),
    (v_l6,'listening','Listen and pick the English meaning.','Mañana va a llover',array['Yesterday it rained','It is raining now','Tomorrow it will rain'],'Tomorrow it will rain',7),
    (v_l6,'speaking','Say this aloud: "Me gusta el verano." [meh GOOS-tah ehl beh-RAH-noh]','Me gusta el verano',array[]::text[],'I like summer.',8),
    (v_l6,'speaking','Say this aloud: "Hoy hace mucho sol." [oy AH-seh MOO-choh SOHL]','Hoy hace mucho sol',array[]::text[],'It is very sunny today.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Va a nevar',array['It rained','It is going to snow','It is hot'],'It is going to snow',6),
    (v_l7,'listening','Listen and pick the English meaning.','En invierno hace frío',array['In summer it is cold','In winter it is hot','In winter it is cold'],'In winter it is cold',7),
    (v_l7,'speaking','Say this aloud: "Hoy llueve mucho." [oy YWEH-beh MOO-choh]','Hoy llueve mucho',array[]::text[],'Today it rains a lot.',8),
    (v_l7,'speaking','Say this aloud: "Mañana va a llover." [mah-NYAH-nah bah ah yoh-BEHR]','Mañana va a llover',array[]::text[],'Tomorrow it will rain.',9);

  -- ====== A1.8 SHOPPING ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Shopping';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','tienda',array['street','price','money'],'shop',6),
    (v_l1,'listening','Listen and pick the English meaning.','dinero',array['shop','expensive','cheap'],'money',7),
    (v_l1,'speaking','Say this aloud: "comprar." [kohm-PRAHR]','comprar',array[]::text[],'to buy',8),
    (v_l1,'speaking','Say this aloud: "barato." [bah-RAH-toh]','barato',array[]::text[],'cheap',9),
    (v_l2,'listening','Listen and pick the English meaning.','¿Cuánto cuesta?',array['What is it called?','How much does it cost?','Where is it?'],'How much does it cost?',6),
    (v_l2,'listening','Listen and pick the English meaning.','Son diez euros',array['I have 10 euros','It is 10 euros','It cost 10 euros yesterday'],'It is 10 euros',7),
    (v_l2,'speaking','Say this aloud: "Pago con tarjeta." [PAH-goh kohn tahr-HEH-tah]','Pago con tarjeta',array[]::text[],'I pay by card.',8),
    (v_l2,'speaking','Say this aloud: "¿Cuánto cuestan?" [KWAHN-toh KWEHS-tahn]','¿Cuánto cuestan?',array[]::text[],'How much do they cost?',9),
    (v_l3,'listening','Listen and pick the English meaning.','Quiero esto',array['I want this','I have this','I see this'],'I want this',6),
    (v_l3,'listening','Listen and pick the English meaning.','Es muy caro',array['It is very cheap','It is very expensive','It is very nice'],'It is very expensive',7),
    (v_l3,'speaking','Say this aloud: "Aquí tiene." [ah-KEE TYEH-neh]','Aquí tiene',array[]::text[],'Here you go.',8),
    (v_l3,'speaking','Say this aloud: "Quiero esto, por favor." [KYEH-roh EHS-toh pohr fah-VOHR]','Quiero esto, por favor',array[]::text[],'I want this, please.',9),
    (v_l6,'listening','Listen and pick the English meaning.','Voy a la tienda con mi madre',array['I want to go to the shop','I go to the shop with my mother','My mother is at the shop'],'I go to the shop with my mother',6),
    (v_l6,'listening','Listen and pick the English meaning.','Compramos pan y leche',array['We sell bread and milk','We want bread and milk','We buy bread and milk'],'We buy bread and milk',7),
    (v_l6,'speaking','Say this aloud: "Pagamos con tarjeta." [pah-GAH-mohs kohn tahr-HEH-tah]','Pagamos con tarjeta',array[]::text[],'We pay by card.',8),
    (v_l6,'speaking','Say this aloud: "La tienda está cerca." [lah TYEHN-dah ehs-TAH SEHR-kah]','La tienda está cerca',array[]::text[],'The shop is near.',9),
    (v_l7,'listening','Listen and pick the English meaning.','¿Aceptan tarjeta?',array['Do you have a card?','Do you accept cards?','Where is the card?'],'Do you accept cards?',6),
    (v_l7,'listening','Listen and pick the English meaning.','¿Tiene cambio?',array['Do you have change?','Do you have time?','Do you have it?'],'Do you have change?',7),
    (v_l7,'speaking','Say this aloud: "Hola, quiero comprar pan." [OH-lah KYEH-roh kohm-PRAHR PAHN]','Hola, quiero comprar pan',array[]::text[],'Hi, I want to buy bread.',8),
    (v_l7,'speaking','Say this aloud: "Gracias, hasta luego." [GRAH-syahs AHS-tah LWEH-goh]','Gracias, hasta luego',array[]::text[],'Thanks, see you later.',9);

  -- ====== A1.9 ANIMALS ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Animals';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','perro',array['cat','bird','horse'],'dog',6),
    (v_l1,'listening','Listen and pick the English meaning.','gato',array['dog','bird','fish'],'cat',7),
    (v_l1,'speaking','Say this aloud: "pájaro." [PAH-hah-roh]','pájaro',array[]::text[],'bird',8),
    (v_l1,'speaking','Say this aloud: "caballo." [kah-BAH-yoh]','caballo',array[]::text[],'horse',9),
    (v_l2,'listening','Listen and pick the English meaning.','el perro',array['the dog','a dog','two dogs'],'the dog',6),
    (v_l2,'listening','Listen and pick the English meaning.','una gata',array['a male cat','a female cat','the cat'],'a female cat',7),
    (v_l2,'speaking','Say this aloud: "Tengo un perro." [TEHN-goh oon PEH-rroh]','Tengo un perro',array[]::text[],'I have a dog.',8),
    (v_l2,'speaking','Say this aloud: "La gata es negra." [lah GAH-tah ehs NEH-grah]','La gata es negra',array[]::text[],'The cat is black.',9),
    (v_l3,'listening','Listen and pick the English meaning.','¿Tienes mascota?',array['Are you a pet?','Do you have a pet?','Where is your pet?'],'Do you have a pet?',6),
    (v_l3,'listening','Listen and pick the English meaning.','Me gustan los gatos',array['I like dogs','I like cats','I have cats'],'I like cats',7),
    (v_l3,'speaking','Say this aloud: "Tengo miedo a los perros." [TEHN-goh MYEH-doh ah lohs PEH-rrohs]','Tengo miedo a los perros',array[]::text[],'I am afraid of dogs.',8),
    (v_l3,'speaking','Say this aloud: "Mi gato es bonito." [mee GAH-toh ehs boh-NEE-toh]','Mi gato es bonito',array[]::text[],'My cat is cute.',9),
    (v_l6,'listening','Listen and pick the English meaning.','Mi perro es muy grande',array['My cat is small','My dog is very big','My dog is small'],'My dog is very big',6),
    (v_l6,'listening','Listen and pick the English meaning.','Los gatos son negros',array['The cats are small','The cats are black','The dogs are black'],'The cats are black',7),
    (v_l6,'speaking','Say this aloud: "Tengo un pájaro azul." [TEHN-goh oon PAH-hah-roh ah-SOOL]','Tengo un pájaro azul',array[]::text[],'I have a blue bird.',8),
    (v_l6,'speaking','Say this aloud: "Me gustan los animales." [meh GOOS-tahn lohs ah-nee-MAH-lehs]','Me gustan los animales',array[]::text[],'I like animals.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Tengo un gato',array['I want a cat','I see a cat','I have a cat'],'I have a cat',6),
    (v_l7,'listening','Listen and pick the English meaning.','Me encantan los perros',array['I like dogs a bit','I love dogs','I have many dogs'],'I love dogs',7),
    (v_l7,'speaking','Say this aloud: "Mi perro se llama Max." [mee PEH-rroh seh YAH-mah MAHKS]','Mi perro se llama Max',array[]::text[],'My dog is called Max.',8),
    (v_l7,'speaking','Say this aloud: "No tengo mascota." [noh TEHN-goh mahs-KOH-tah]','No tengo mascota',array[]::text[],'I do not have a pet.',9);

  -- ====== A1.10 BODY PARTS ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Body Parts';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','cabeza',array['hand','foot','arm'],'head',6),
    (v_l1,'listening','Listen and pick the English meaning.','mano',array['foot','head','arm'],'hand',7),
    (v_l1,'speaking','Say this aloud: "ojo." [OH-hoh]','ojo',array[]::text[],'eye',8),
    (v_l1,'speaking','Say this aloud: "pie." [PYEH]','pie',array[]::text[],'foot',9),
    (v_l2,'listening','Listen and pick the English meaning.','Me duele la cabeza',array['I have a head','My head hurts','I want my head'],'My head hurts',6),
    (v_l2,'listening','Listen and pick the English meaning.','Me duelen los pies',array['My foot hurts','My feet hurt','I have feet'],'My feet hurt',7),
    (v_l2,'speaking','Say this aloud: "Me duele la espalda." [meh DWEH-leh lah ehs-PAHL-dah]','Me duele la espalda',array[]::text[],'My back hurts.',8),
    (v_l2,'speaking','Say this aloud: "Tengo los ojos azules." [TEHN-goh lohs OH-hohs ah-SOO-lehs]','Tengo los ojos azules',array[]::text[],'I have blue eyes.',9),
    (v_l3,'listening','Listen and pick the English meaning.','No me siento bien',array['I do not see well','I do not feel well','I do not have anything'],'I do not feel well',6),
    (v_l3,'listening','Listen and pick the English meaning.','Tengo fiebre',array['I am tired','I am hot','I have a fever'],'I have a fever',7),
    (v_l3,'speaking','Say this aloud: "Necesito un médico." [neh-seh-SEE-toh oon MEH-dee-koh]','Necesito un médico',array[]::text[],'I need a doctor.',8),
    (v_l3,'speaking','Say this aloud: "Me duele el estómago." [meh DWEH-leh ehl ehs-TOH-mah-goh]','Me duele el estómago',array[]::text[],'My stomach hurts.',9),
    (v_l6,'listening','Listen and pick the English meaning.','Tengo dos ojos verdes',array['I have green eyes','I have green hair','I have a green dress'],'I have two green eyes',6),
    (v_l6,'listening','Listen and pick the English meaning.','Mis manos son pequeñas',array['My hands are small','My feet are small','My hand is big'],'My hands are small',7),
    (v_l6,'speaking','Say this aloud: "Mi pelo es negro." [mee PEH-loh ehs NEH-groh]','Mi pelo es negro',array[]::text[],'My hair is black.',8),
    (v_l6,'speaking','Say this aloud: "Voy al médico mañana." [BOY ahl MEH-dee-koh mah-NYAH-nah]','Voy al médico mañana',array[]::text[],'I go to the doctor tomorrow.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Necesito descansar',array['I need water','I need to rest','I need help'],'I need to rest',6),
    (v_l7,'listening','Listen and pick the English meaning.','Tengo dolor de cabeza',array['My head is big','I have a headache','I want a head'],'I have a headache',7),
    (v_l7,'speaking','Say this aloud: "Me duelen los pies." [meh DWEH-lehn lohs PYEHS]','Me duelen los pies',array[]::text[],'My feet hurt.',8),
    (v_l7,'speaking','Say this aloud: "Me lavo las manos." [meh LAH-boh lahs MAH-nohs]','Me lavo las manos',array[]::text[],'I wash my hands.',9);

  -- ====== A1.11 CLOTHES ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Clothes';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','camisa',array['skirt','trousers','dress'],'shirt',6),
    (v_l1,'listening','Listen and pick the English meaning.','zapatos',array['hat','jacket','dress'],'shoes',7),
    (v_l1,'speaking','Say this aloud: "vestido." [behs-TEE-doh]','vestido',array[]::text[],'dress',8),
    (v_l1,'speaking','Say this aloud: "pantalones." [pahn-tah-LOH-nehs]','pantalones',array[]::text[],'trousers',9),
    (v_l2,'listening','Listen and pick the English meaning.','Llevo una camisa',array['I want a shirt','I am wearing a shirt','I sell a shirt'],'I am wearing a shirt',6),
    (v_l2,'listening','Listen and pick the English meaning.','Me pongo los zapatos',array['I take off shoes','I put on shoes','I buy shoes'],'I put on shoes',7),
    (v_l2,'speaking','Say this aloud: "Llevo una camisa azul." [YEH-boh OO-nah kah-MEE-sah ah-SOOL]','Llevo una camisa azul',array[]::text[],'I am wearing a blue shirt.',8),
    (v_l2,'speaking','Say this aloud: "Me pongo la chaqueta." [meh POHN-goh lah chah-KEH-tah]','Me pongo la chaqueta',array[]::text[],'I put on the jacket.',9),
    (v_l3,'listening','Listen and pick the English meaning.','¿Qué llevas?',array['What is your name?','What are you wearing?','What do you want?'],'What are you wearing?',6),
    (v_l3,'listening','Listen and pick the English meaning.','Me queda bien',array['It is mine','It fits me well','I want it'],'It fits me well',7),
    (v_l3,'speaking','Say this aloud: "¿Puedo probármelo?" [PWEH-doh proh-BAHR-meh-loh]','¿Puedo probármelo?',array[]::text[],'Can I try it on?',8),
    (v_l3,'speaking','Say this aloud: "Necesito una talla más grande." [neh-seh-SEE-toh OO-nah TAH-yah mahs GRAHN-deh]','Necesito una talla más grande',array[]::text[],'I need a bigger size.',9),
    (v_l6,'listening','Listen and pick the English meaning.','Llevo una camisa blanca',array['I want a white shirt','I am wearing a white shirt','I sell a white shirt'],'I am wearing a white shirt',6),
    (v_l6,'listening','Listen and pick the English meaning.','Mis zapatos son nuevos',array['My shoes are old','My shoes are new','I want new shoes'],'My shoes are new',7),
    (v_l6,'speaking','Say this aloud: "Hace frío, llevo abrigo." [AH-seh FREE-oh YEH-boh ah-BREE-goh]','Hace frío, llevo abrigo',array[]::text[],'It is cold, I wear a coat.',8),
    (v_l6,'speaking','Say this aloud: "Mi sombrero es rojo." [mee sohm-BREH-roh ehs ROH-hoh]','Mi sombrero es rojo',array[]::text[],'My hat is red.',9),
    (v_l7,'listening','Listen and pick the English meaning.','¿Qué talla usas?',array['What is your size?','How are you?','Where do you live?'],'What size do you wear?',6),
    (v_l7,'listening','Listen and pick the English meaning.','Me gusta tu vestido',array['I like your dress','I have your dress','I want your dress'],'I like your dress',7),
    (v_l7,'speaking','Say this aloud: "Llevo zapatos negros." [YEH-boh sah-PAH-tohs NEH-grohs]','Llevo zapatos negros',array[]::text[],'I am wearing black shoes.',8),
    (v_l7,'speaking','Say this aloud: "Me pongo la camisa." [meh POHN-goh lah kah-MEE-sah]','Me pongo la camisa',array[]::text[],'I put on the shirt.',9);

  -- ====== A1.12 HOUSE & HOME ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'House & Home';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','casa',array['kitchen','room','table'],'house',6),
    (v_l1,'listening','Listen and pick the English meaning.','cocina',array['bedroom','bathroom','living room'],'kitchen',7),
    (v_l1,'speaking','Say this aloud: "baño." [BAH-nyoh]','baño',array[]::text[],'bathroom',8),
    (v_l1,'speaking','Say this aloud: "dormitorio." [dohr-mee-TOH-ryoh]','dormitorio',array[]::text[],'bedroom',9),
    (v_l2,'listening','Listen and pick the English meaning.','Hay tres habitaciones',array['I have 3 rooms','There are 3 rooms','I want 3 rooms'],'There are 3 rooms',6),
    (v_l2,'listening','Listen and pick the English meaning.','Vivo en una casa',array['I am in a house','I live in a house','I want a house'],'I live in a house',7),
    (v_l2,'speaking','Say this aloud: "Hay un baño." [I oon BAH-nyoh]','Hay un baño',array[]::text[],'There is a bathroom.',8),
    (v_l2,'speaking','Say this aloud: "La cocina es grande." [lah koh-SEE-nah ehs GRAHN-deh]','La cocina es grande',array[]::text[],'The kitchen is big.',9),
    (v_l3,'listening','Listen and pick the English meaning.','¿Dónde vives?',array['How do you live?','Where do you live?','When do you live?'],'Where do you live?',6),
    (v_l3,'listening','Listen and pick the English meaning.','Vivo con mi familia',array['I live alone','I live with my family','I live with friends'],'I live with my family',7),
    (v_l3,'speaking','Say this aloud: "Bienvenido a mi casa." [byehn-beh-NEE-doh ah mee KAH-sah]','Bienvenido a mi casa',array[]::text[],'Welcome to my house.',8),
    (v_l3,'speaking','Say this aloud: "Mi casa es grande." [mee KAH-sah ehs GRAHN-deh]','Mi casa es grande',array[]::text[],'My house is big.',9),
    (v_l6,'listening','Listen and pick the English meaning.','Mi casa tiene cuatro habitaciones',array['My house has 4 rooms','My house is 4','I have 4 houses'],'My house has 4 rooms',6),
    (v_l6,'listening','Listen and pick the English meaning.','Vivo aquí con mi familia',array['I live here with friends','I live here with my family','My family lives there'],'I live here with my family',7),
    (v_l6,'speaking','Say this aloud: "La sala es bonita." [lah SAH-lah ehs boh-NEE-tah]','La sala es bonita',array[]::text[],'The living room is pretty.',8),
    (v_l6,'speaking','Say this aloud: "Me gusta mucho mi casa." [meh GOOS-tah MOO-choh mee KAH-sah]','Me gusta mucho mi casa',array[]::text[],'I really like my house.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Vivo en Madrid',array['I am from Madrid','I live in Madrid','I work in Madrid'],'I live in Madrid',6),
    (v_l7,'listening','Listen and pick the English meaning.','La cocina es nueva',array['The kitchen is old','The kitchen is new','I want a new kitchen'],'The kitchen is new',7),
    (v_l7,'speaking','Say this aloud: "Hay un jardín." [I oon hahr-DEEN]','Hay un jardín',array[]::text[],'There is a garden.',8),
    (v_l7,'speaking','Say this aloud: "Vivimos en un piso." [bee-BEE-mohs ehn oon PEE-soh]','Vivimos en un piso',array[]::text[],'We live in an apartment.',9);

  -- ====== A1.13 TRANSPORT ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Transport';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','coche',array['bus','train','plane'],'car',6),
    (v_l1,'listening','Listen and pick the English meaning.','tren',array['plane','bus','car'],'train',7),
    (v_l1,'speaking','Say this aloud: "autobús." [ow-toh-BOOS]','autobús',array[]::text[],'bus',8),
    (v_l1,'speaking','Say this aloud: "bicicleta." [bee-see-KLEH-tah]','bicicleta',array[]::text[],'bicycle',9),
    (v_l2,'listening','Listen and pick the English meaning.','Voy en autobús',array['I have a bus','I go by bus','I want a bus'],'I go by bus',6),
    (v_l2,'listening','Listen and pick the English meaning.','Voy a pie',array['I go fast','I go on foot','I go by car'],'I go on foot',7),
    (v_l2,'speaking','Say this aloud: "Voy al trabajo en tren." [BOY ahl trah-BAH-hoh ehn TREHN]','Voy al trabajo en tren',array[]::text[],'I go to work by train.',8),
    (v_l2,'speaking','Say this aloud: "Vamos en coche." [BAH-mohs ehn KOH-cheh]','Vamos en coche',array[]::text[],'We go by car.',9),
    (v_l3,'listening','Listen and pick the English meaning.','¿A qué hora sale?',array['Where does it go?','What time does it leave?','How much is it?'],'What time does it leave?',6),
    (v_l3,'listening','Listen and pick the English meaning.','Necesito un taxi',array['I see a taxi','I want a taxi','I need a taxi'],'I need a taxi',7),
    (v_l3,'speaking','Say this aloud: "Un billete a Madrid." [oon bee-YEH-teh ah mah-DREED]','Un billete a Madrid',array[]::text[],'A ticket to Madrid.',8),
    (v_l3,'speaking','Say this aloud: "De ida y vuelta." [deh EE-dah ee BWEHL-tah]','De ida y vuelta',array[]::text[],'Round trip.',9),
    (v_l6,'listening','Listen and pick the English meaning.','Voy al trabajo en autobús',array['I drive to work','I go to work by bus','I see the bus at work'],'I go to work by bus',6),
    (v_l6,'listening','Listen and pick the English meaning.','El viaje dura veinte minutos',array['The trip costs 20','The trip takes 20 min','I travel for 20'],'The trip takes 20 minutes',7),
    (v_l6,'speaking','Say this aloud: "Voy en bicicleta." [BOY ehn bee-see-KLEH-tah]','Voy en bicicleta',array[]::text[],'I go by bicycle.',8),
    (v_l6,'speaking','Say this aloud: "Nunca tomo el avión." [NOON-kah TOH-moh ehl ah-BYOHN]','Nunca tomo el avión',array[]::text[],'I never take the plane.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Voy a pie',array['I go by foot','I go by car','I go fast'],'I go on foot',6),
    (v_l7,'listening','Listen and pick the English meaning.','Tomo el metro',array['I take the metro','I drive a car','I see the metro'],'I take the metro',7),
    (v_l7,'speaking','Say this aloud: "Voy al trabajo en metro." [BOY ahl trah-BAH-hoh ehn MEH-troh]','Voy al trabajo en metro',array[]::text[],'I go to work by metro.',8),
    (v_l7,'speaking','Say this aloud: "Prefiero el tren." [preh-FYEH-roh ehl TREHN]','Prefiero el tren',array[]::text[],'I prefer the train.',9);

  -- ====== A1.14 DAYS & MONTHS ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Days & Months';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','lunes',array['Tuesday','Sunday','Friday'],'Monday',6),
    (v_l1,'listening','Listen and pick the English meaning.','viernes',array['Friday','Thursday','Wednesday'],'Friday',7),
    (v_l1,'speaking','Say this aloud: "domingo." [doh-MEEN-goh]','domingo',array[]::text[],'Sunday',8),
    (v_l1,'speaking','Say this aloud: "enero." [eh-NEH-roh]','enero',array[]::text[],'January',9),
    (v_l2,'listening','Listen and pick the English meaning.','Hoy es martes',array['Yesterday was Tuesday','Today is Tuesday','Tomorrow is Tuesday'],'Today is Tuesday',6),
    (v_l2,'listening','Listen and pick the English meaning.','En enero hace frío',array['In January it is hot','In January it is cold','In July it is cold'],'In January it is cold',7),
    (v_l2,'speaking','Say this aloud: "El sábado voy al cine." [ehl SAH-bah-doh BOY ahl SEE-neh]','El sábado voy al cine',array[]::text[],'On Saturday I go to the cinema.',8),
    (v_l2,'speaking','Say this aloud: "En mayo hace calor." [ehn MAH-yoh AH-seh kah-LOHR]','En mayo hace calor',array[]::text[],'In May it is hot.',9),
    (v_l3,'listening','Listen and pick the English meaning.','¿Cuándo es tu cumpleaños?',array['What is your name?','When is your birthday?','How old are you?'],'When is your birthday?',6),
    (v_l3,'listening','Listen and pick the English meaning.','Es el quince de mayo',array['It is May 15','It is March 15','It is May 5'],'It is May 15',7),
    (v_l3,'speaking','Say this aloud: "Mi cumpleaños es en julio." [mee koom-pleh-AH-nyohs ehs ehn HOO-lyoh]','Mi cumpleaños es en julio',array[]::text[],'My birthday is in July.',8),
    (v_l3,'speaking','Say this aloud: "El fin de semana." [ehl feen deh seh-MAH-nah]','El fin de semana',array[]::text[],'The weekend.',9),
    (v_l6,'listening','Listen and pick the English meaning.','El sábado voy al cine',array['On Friday I go to the cinema','On Saturday I go to the cinema','I love the cinema'],'On Saturday I go to the cinema',6),
    (v_l6,'listening','Listen and pick the English meaning.','Mi día favorito es el viernes',array['I work on Fridays','My favorite day is Friday','I rest on Fridays'],'My favorite day is Friday',7),
    (v_l6,'speaking','Say this aloud: "Mi cumpleaños es en mayo." [mee koom-pleh-AH-nyohs ehs ehn MAH-yoh]','Mi cumpleaños es en mayo',array[]::text[],'My birthday is in May.',8),
    (v_l6,'speaking','Say this aloud: "Los domingos descanso." [lohs doh-MEEN-gohs dehs-KAHN-soh]','Los domingos descanso',array[]::text[],'On Sundays I rest.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Hoy es viernes',array['Today is Friday','Today is Thursday','Today is Saturday'],'Today is Friday',6),
    (v_l7,'listening','Listen and pick the English meaning.','Diciembre es muy frío',array['December is very hot','December is very cold','December is very nice'],'December is very cold',7),
    (v_l7,'speaking','Say this aloud: "El sábado voy de compras." [ehl SAH-bah-doh BOY deh KOHM-prahs]','El sábado voy de compras',array[]::text[],'On Saturday I go shopping.',8),
    (v_l7,'speaking','Say this aloud: "Hoy es lunes." [oy ehs LOO-nehs]','Hoy es lunes',array[]::text[],'Today is Monday.',9);

  -- ====== A1.15 BASIC VERBS ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Basic Verbs';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','Yo soy',array['I am (state)','I am (essence)','I have'],'I am (essence/identity)',6),
    (v_l1,'listening','Listen and pick the English meaning.','Yo tengo',array['I have','I am','I go'],'I have',7),
    (v_l1,'speaking','Say this aloud: "Estoy bien." [ehs-TOY BYEHN]','Estoy bien',array[]::text[],'I am fine.',8),
    (v_l1,'speaking','Say this aloud: "Voy al trabajo." [BOY ahl trah-BAH-hoh]','Voy al trabajo',array[]::text[],'I go to work.',9),
    (v_l2,'listening','Listen and pick the English meaning.','Tú eres',array['You have','You are','You go'],'You are',6),
    (v_l2,'listening','Listen and pick the English meaning.','Ella tiene',array['She has','She is','She goes'],'She has',7),
    (v_l2,'speaking','Say this aloud: "Yo soy estudiante." [yoh SOY ehs-too-DYAHN-teh]','Yo soy estudiante',array[]::text[],'I am a student.',8),
    (v_l2,'speaking','Say this aloud: "Hago la tarea." [AH-goh lah tah-REH-ah]','Hago la tarea',array[]::text[],'I do my homework.',9),
    (v_l3,'listening','Listen and pick the English meaning.','Tengo hambre',array['I am thirsty','I am hungry','I am tired'],'I am hungry',6),
    (v_l3,'listening','Listen and pick the English meaning.','Estoy en casa',array['I am at school','I am at home','I am tired'],'I am at home',7),
    (v_l3,'speaking','Say this aloud: "Soy de España." [SOY deh ehs-PAH-nyah]','Soy de España',array[]::text[],'I am from Spain.',8),
    (v_l3,'speaking','Say this aloud: "Tengo veinte años." [TEHN-goh BEHN-teh AH-nyohs]','Tengo veinte años',array[]::text[],'I am 20 years old.',9),
    (v_l6,'listening','Listen and pick the English meaning.','Yo soy estudiante',array['I am a teacher','I am a student','I am a doctor'],'I am a student',6),
    (v_l6,'listening','Listen and pick the English meaning.','Voy a la universidad',array['I am at university','I want a university','I go to university'],'I go to university',7),
    (v_l6,'speaking','Say this aloud: "Tengo veinte años." [TEHN-goh BEHN-teh AH-nyohs]','Tengo veinte años',array[]::text[],'I am twenty.',8),
    (v_l6,'speaking','Say this aloud: "Vivo en Madrid con mi familia." [BEE-boh ehn mah-DREED kohn mee fah-MEE-lyah]','Vivo en Madrid con mi familia',array[]::text[],'I live in Madrid with my family.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Estoy cansado',array['I am hungry','I am tired','I am sleeping'],'I am tired (m.)',6),
    (v_l7,'listening','Listen and pick the English meaning.','Voy a la escuela',array['I am at school','I want a school','I go to school'],'I go to school',7),
    (v_l7,'speaking','Say this aloud: "Hago ejercicio cada día." [AH-goh eh-hehr-SEE-syoh KAH-dah DEE-ah]','Hago ejercicio cada día',array[]::text[],'I exercise every day.',8),
    (v_l7,'speaking','Say this aloud: "Tengo un hermano." [TEHN-goh oon ehr-MAH-noh]','Tengo un hermano',array[]::text[],'I have a brother.',9);

end $$;

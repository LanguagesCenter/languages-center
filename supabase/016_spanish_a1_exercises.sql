-- 016_spanish_a1_exercises.sql
-- Real exercise content for Spanish A1, new 15×8 structure.
-- 15 sections × 7 substantive lessons × 5 exercises = 525 exercises.
-- Lesson 8 (Podcast) gets a "Coming Soon" placeholder title + description.
--
-- Idempotent: clears existing A1 exercises before inserting.

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

  -- ============== A1.1 GREETINGS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Greetings';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'Hola, me llamo Ana. Soy de Madrid. Tengo veinte años. Vivo con mi familia en una casa pequeña. Mucho gusto.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','How do you say "Hello" in Spanish?','Hola',array['Adiós','Gracias','Por favor'],'Hello [OH-lah]',1),
    (v_l1,'multiple_choice','How do you say "Goodbye" in Spanish?','Adiós',array['Hola','Buenos días','Por favor'],'Goodbye [ah-DYOHS]',2),
    (v_l1,'multiple_choice','How do you say "Thank you" in Spanish?','Gracias',array['De nada','Hola','Sí'],'Thank you [GRAH-syahs]',3),
    (v_l1,'multiple_choice','How do you say "Good morning" in Spanish?','Buenos días',array['Buenas noches','Buenas tardes','Hasta luego'],'Good morning [BWEH-nohs DEE-ahs]',4),
    (v_l1,'multiple_choice','How do you say "Please" in Spanish?','Por favor',array['Gracias','De nada','Lo siento'],'Please [pohr fah-VOHR]',5),
    (v_l2,'fill_blank','Complete: "Me ___ Ana." (My name is Ana.)','llamo',array['llamas','llama','llamamos'],'I call myself (llamarse, 1st person)',1),
    (v_l2,'fill_blank','Complete: "¿Cómo ___ llamas?" (Whats your name?)','te',array['me','se','nos'],'yourself (reflexive)',2),
    (v_l2,'fill_blank','Complete: "Yo ___ de España." (I am from Spain.)','soy',array['estoy','tengo','es'],'I am (ser, origin)',3),
    (v_l2,'fill_blank','Complete: "Ella ___ Carmen." (She is named Carmen.)','se llama',array['me llamo','te llamas','se llaman'],'she is called',4),
    (v_l2,'fill_blank','Complete: "Mucho ___" (Pleased to meet you.)','gusto',array['gracias','adiós','hola'],'pleasure',5),
    (v_l3,'multiple_choice','What does "¿Cómo estás?" mean?','How are you? (informal)',array['Whats your name?','Where are you from?','How old are you?'],'How are you? [KOH-moh ehs-TAHS]',1),
    (v_l3,'multiple_choice','What does "Bien, gracias" mean?','Fine, thank you',array['Goodbye, thanks','Hello, please','See you later'],'Fine, thank you',2),
    (v_l3,'multiple_choice','What does "Hasta luego" mean?','See you later',array['Good morning','Pleased to meet you','How are you?'],'See you later [AHS-tah LWEH-goh]',3),
    (v_l3,'multiple_choice','What does "¿De dónde eres?" mean?','Where are you from?',array['Whats your name?','How old are you?','Where do you live?'],'Where are you from? [deh DOHN-deh EH-rehs]',4),
    (v_l3,'multiple_choice','What does "Mucho gusto" mean?','Pleased to meet you',array['Thank you very much','Good morning','See you tomorrow'],'Pleased to meet you [MOO-choh GOOS-toh]',5),
    (v_l4,'listening','Listen and pick the English meaning.','Buenos días',array['Good night','See you later','Pleased to meet you'],'Good morning',1),
    (v_l4,'listening','Listen and pick the English meaning.','¿Cómo te llamas?',array['How old are you?','Where are you from?','How are you?'],'Whats your name?',2),
    (v_l4,'listening','Listen and pick the English meaning.','Hasta mañana',array['Until later','Hello','Good evening'],'See you tomorrow',3),
    (v_l4,'listening','Listen and pick the English meaning.','Me llamo Ana',array['I am Ana''s friend','I see Ana','I know Ana'],'My name is Ana',4),
    (v_l4,'listening','Listen and pick the English meaning.','Encantado',array['I am tired','I am happy','Excuse me'],'Pleased to meet you (m.)',5),
    (v_l5,'speaking','Say this aloud: "Hola, ¿cómo estás?" [OH-lah KOH-moh ehs-TAHS]','Hola, ¿cómo estás?',array[]::text[],'Hello, how are you?',1),
    (v_l5,'speaking','Say this aloud: "Me llamo Carlos." [meh YAH-moh KAR-lohs]','Me llamo Carlos',array[]::text[],'My name is Carlos.',2),
    (v_l5,'speaking','Say this aloud: "Soy de México." [SOY deh MEH-hee-koh]','Soy de México',array[]::text[],'I am from Mexico.',3),
    (v_l5,'speaking','Say this aloud: "Mucho gusto." [MOO-choh GOOS-toh]','Mucho gusto',array[]::text[],'Pleased to meet you.',4),
    (v_l5,'speaking','Say this aloud: "Hasta luego." [AHS-tah LWEH-goh]','Hasta luego',array[]::text[],'See you later.',5),
    (v_l6,'multiple_choice','Read the paragraph. What is the speakers name?','Ana',array['Carmen','Sofía','Lucía'],'Hola, me llamo Ana...',1),
    (v_l6,'multiple_choice','Where is the speaker from?','Madrid',array['Barcelona','Sevilla','Valencia'],'Soy de Madrid',2),
    (v_l6,'multiple_choice','How old is the speaker?','Twenty',array['Twelve','Thirty','Twenty-one'],'Tengo veinte años',3),
    (v_l6,'multiple_choice','Who does the speaker live with?','Her family',array['Her friends','Her dog','Alone'],'Vivo con mi familia',4),
    (v_l6,'multiple_choice','How does the paragraph end?','Mucho gusto',array['Adiós','Gracias','Hasta luego'],'Mucho gusto (ending)',5),
    (v_l7,'fill_blank','Translate to Spanish: "Hello."','Hola',array['Adiós','Gracias','Buenos'],'Hello',1),
    (v_l7,'fill_blank','Translate to Spanish: "My name is Pedro."','Me llamo Pedro',array['Yo llamo Pedro','Soy llamo Pedro','Mi llamo Pedro'],'My name is Pedro',2),
    (v_l7,'fill_blank','Translate to Spanish: "I am from Spain."','Soy de España',array['Estoy de España','Voy de España','Tengo España'],'I am from Spain',3),
    (v_l7,'fill_blank','Translate to Spanish: "How are you?"','¿Cómo estás?',array['¿Cómo te llamas?','¿De dónde eres?','¿Cuántos años?'],'How are you?',4),
    (v_l7,'fill_blank','Translate to Spanish: "See you tomorrow."','Hasta mañana',array['Hasta luego','Adiós','Buenas noches'],'See you tomorrow',5);

  -- ============== A1.2 NUMBERS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Numbers';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'En mi clase hay veinte estudiantes. Tengo tres libros y cinco bolígrafos. Mi número de teléfono empieza con seis. Yo tengo treinta años.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','What is "one" in Spanish?','uno',array['dos','tres','diez'],'One [OO-noh]',1),
    (v_l1,'multiple_choice','What is "five" in Spanish?','cinco',array['quince','cincuenta','cien'],'Five [SEEN-koh]',2),
    (v_l1,'multiple_choice','What is "ten" in Spanish?','diez',array['doce','once','dos'],'Ten [DYEHS]',3),
    (v_l1,'multiple_choice','What is "twenty" in Spanish?','veinte',array['doce','dos','dieciséis'],'Twenty [BEHN-teh]',4),
    (v_l1,'multiple_choice','What is "one hundred" in Spanish?','cien',array['mil','ciento','uno'],'One hundred [SYEHN]',5),
    (v_l2,'fill_blank','Complete: "Tengo ___ años." (I am 5 years old.)','cinco',array['cinca','cincos','cincuenta'],'five',1),
    (v_l2,'fill_blank','Complete: "Hay ___ libros." (There are 2 books.)','dos',array['dos libros','doce','dos los'],'two',2),
    (v_l2,'fill_blank','Complete: "Son las ___" (It is 3 oclock.)','tres',array['tre','trece','treinta'],'three',3),
    (v_l2,'fill_blank','Complete: "Tengo ___ hermanos." (I have 4 brothers.)','cuatro',array['cuatros','catorce','cuarenta'],'four',4),
    (v_l2,'fill_blank','Complete: "Cuesta ___ euros." (It costs 10 euros.)','diez',array['dies','doce','dos'],'ten',5),
    (v_l3,'multiple_choice','What does "¿Cuántos años tienes?" mean?','How old are you?',array['How many books do you have?','How are you?','Whats your name?'],'How old are you?',1),
    (v_l3,'multiple_choice','What does "Tengo veinte años" mean?','I am 20 years old',array['I have 20 brothers','I live for 20 years','I count to 20'],'I am 20 years old',2),
    (v_l3,'multiple_choice','What does "¿Cuánto cuesta?" mean?','How much does it cost?',array['How many?','How old?','How big?'],'How much does it cost?',3),
    (v_l3,'multiple_choice','What does "Son las cinco" mean?','It is five oclock',array['I have five','Five things','Number five'],'It is five oclock',4),
    (v_l3,'multiple_choice','What does "Número de teléfono" mean?','Phone number',array['House number','Day number','Year number'],'Phone number',5),
    (v_l4,'listening','Listen and pick the English meaning.','Tengo treinta años',array['I have 13 dogs','I am 13','I have 30 books'],'I am 30 years old',1),
    (v_l4,'listening','Listen and pick the English meaning.','Hay quince personas',array['There are 50 people','There are 5 people','There are 15 things'],'There are 15 people',2),
    (v_l4,'listening','Listen and pick the English meaning.','Son las dos',array['I have 2','It is 2 oclock','Two of them'],'It is 2 oclock',3),
    (v_l4,'listening','Listen and pick the English meaning.','Cuesta diez euros',array['Ten things cost','I have 10 euros','I sold for 10'],'It costs 10 euros',4),
    (v_l4,'listening','Listen and pick the English meaning.','Mi número es cien',array['My number is 1','My number is 1000','Number one hundred is mine'],'My number is 100',5),
    (v_l5,'speaking','Say this aloud: "Tengo veinte años." [TEHN-goh BEHN-teh AH-nyohs]','Tengo veinte años',array[]::text[],'I am 20 years old.',1),
    (v_l5,'speaking','Say this aloud: "Hay diez libros." [I dyehs LEE-brohs]','Hay diez libros',array[]::text[],'There are 10 books.',2),
    (v_l5,'speaking','Say this aloud: "Son las cinco." [sohn lahs SEEN-koh]','Son las cinco',array[]::text[],'It is five oclock.',3),
    (v_l5,'speaking','Say this aloud: "Cuesta cien euros." [KWEHS-tah SYEHN EH-oo-rohs]','Cuesta cien euros',array[]::text[],'It costs one hundred euros.',4),
    (v_l5,'speaking','Say this aloud: "Mi número es ocho." [mee NOO-meh-roh ehs OH-choh]','Mi número es ocho',array[]::text[],'My number is eight.',5),
    (v_l6,'multiple_choice','How many students are in the class?','Twenty',array['Twelve','Two','Two hundred'],'veinte estudiantes',1),
    (v_l6,'multiple_choice','How many books does the speaker have?','Three',array['Five','Thirty','Thirteen'],'tres libros',2),
    (v_l6,'multiple_choice','How many pens does the speaker have?','Five',array['Three','Six','Fifteen'],'cinco bolígrafos',3),
    (v_l6,'multiple_choice','What number does the phone start with?','Six',array['Sixteen','Sixty','Three'],'empieza con seis',4),
    (v_l6,'multiple_choice','How old is the speaker?','Thirty',array['Thirteen','Three','Twenty'],'tengo treinta años',5),
    (v_l7,'fill_blank','Translate to Spanish: "I am 5 years old."','Tengo cinco años',array['Soy cinco años','Estoy cinco años','Cinco años yo'],'I am 5 years old',1),
    (v_l7,'fill_blank','Translate to Spanish: "There are 10 books."','Hay diez libros',array['Tengo diez libros','Hay dies libros','Diez libros está'],'There are 10 books',2),
    (v_l7,'fill_blank','Translate to Spanish: "It is 2 oclock."','Son las dos',array['Es las dos','Son los dos','Es dos'],'It is 2 oclock',3),
    (v_l7,'fill_blank','Translate to Spanish: "How much does it cost?"','¿Cuánto cuesta?',array['¿Cómo cuesta?','¿Cuánto es?','¿Qué cuesta?'],'How much does it cost?',4),
    (v_l7,'fill_blank','Translate to Spanish: "My number is 100."','Mi número es cien',array['Mi numero es cien','Mi número son cien','Mi número es ciento'],'My number is 100',5);

  -- ============== A1.3 COLORS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Colors';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'Mi color favorito es el azul. Tengo una casa blanca y un coche rojo. Mi gato es negro. En primavera, las flores son amarillas y rosas.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','What is "red" in Spanish?','rojo',array['rosa','azul','verde'],'Red [ROH-hoh]',1),
    (v_l1,'multiple_choice','What is "blue" in Spanish?','azul',array['negro','blanco','rojo'],'Blue [ah-SOOL]',2),
    (v_l1,'multiple_choice','What is "green" in Spanish?','verde',array['gris','azul','rojo'],'Green [BEHR-deh]',3),
    (v_l1,'multiple_choice','What is "yellow" in Spanish?','amarillo',array['naranja','rosa','marrón'],'Yellow [ah-mah-REE-yoh]',4),
    (v_l1,'multiple_choice','What is "black" in Spanish?','negro',array['blanco','gris','marrón'],'Black [NEH-groh]',5),
    (v_l2,'fill_blank','Complete: "La casa es ___" (The house is white.)','blanca',array['blanco','blancos','blancas'],'white (f.sg, agrees with casa)',1),
    (v_l2,'fill_blank','Complete: "Los zapatos son ___" (The shoes are black.)','negros',array['negro','negra','negras'],'black (m.pl)',2),
    (v_l2,'fill_blank','Complete: "El coche ___ rojo." (The car is red.)','es',array['está','tiene','son'],'is (ser, color)',3),
    (v_l2,'fill_blank','Complete: "Las flores son ___" (The flowers are red.)','rojas',array['rojo','rojos','roja'],'red (f.pl, agrees with flores)',4),
    (v_l2,'fill_blank','Complete: "Mi camisa ___ azul." (My shirt is blue.)','es',array['está','tiene','son'],'is',5),
    (v_l3,'multiple_choice','What does "¿De qué color es?" mean?','What color is it?',array['Where is the color?','What is your favorite?','How is the color?'],'What color is it?',1),
    (v_l3,'multiple_choice','What does "Mi color favorito" mean?','My favorite color',array['My many colors','The color of mine','I like color'],'My favorite color',2),
    (v_l3,'multiple_choice','What does "Me gusta el rojo" mean?','I like red',array['I am red','I see red','I have red'],'I like red',3),
    (v_l3,'multiple_choice','What does "La pared es blanca" mean?','The wall is white',array['I paint walls','The white house','I have a wall'],'The wall is white',4),
    (v_l3,'multiple_choice','What does "Un coche verde" mean?','A green car',array['A red car','My green house','Green cars'],'A green car',5),
    (v_l4,'listening','Listen and pick the English meaning.','El cielo es azul',array['The grass is green','The sky is blue','My eyes are blue'],'The sky is blue',1),
    (v_l4,'listening','Listen and pick the English meaning.','La manzana es roja',array['I eat an apple','The apple is sweet','The apple is red'],'The apple is red',2),
    (v_l4,'listening','Listen and pick the English meaning.','Mi gato es negro',array['I have a black cat','My cat is small','My cat is happy'],'My cat is black',3),
    (v_l4,'listening','Listen and pick the English meaning.','Las flores son amarillas',array['The flowers smell','The flowers are yellow','I like flowers'],'The flowers are yellow',4),
    (v_l4,'listening','Listen and pick the English meaning.','Quiero una camisa verde',array['I want a black shirt','I want a green shirt','I like green'],'I want a green shirt',5),
    (v_l5,'speaking','Say this aloud: "Mi color favorito es el azul." [mee koh-LOHR fah-boh-REE-toh ehs ehl ah-SOOL]','Mi color favorito es el azul',array[]::text[],'My favorite color is blue.',1),
    (v_l5,'speaking','Say this aloud: "La casa es blanca." [lah KAH-sah ehs BLAHN-kah]','La casa es blanca',array[]::text[],'The house is white.',2),
    (v_l5,'speaking','Say this aloud: "El coche es rojo." [ehl KOH-cheh ehs ROH-hoh]','El coche es rojo',array[]::text[],'The car is red.',3),
    (v_l5,'speaking','Say this aloud: "Los zapatos son negros." [lohs sah-PAH-tohs sohn NEH-grohs]','Los zapatos son negros',array[]::text[],'The shoes are black.',4),
    (v_l5,'speaking','Say this aloud: "Las flores son amarillas." [lahs FLOH-rehs sohn ah-mah-REE-yahs]','Las flores son amarillas',array[]::text[],'The flowers are yellow.',5),
    (v_l6,'multiple_choice','What is the speakers favorite color?','Blue',array['Red','Green','Yellow'],'mi color favorito es el azul',1),
    (v_l6,'multiple_choice','What color is the house?','White',array['Blue','Red','Black'],'casa blanca',2),
    (v_l6,'multiple_choice','What color is the car?','Red',array['White','Black','Blue'],'coche rojo',3),
    (v_l6,'multiple_choice','What color is the cat?','Black',array['White','Yellow','Pink'],'gato es negro',4),
    (v_l6,'multiple_choice','What colors are the spring flowers?','Yellow and pink',array['Red and white','Blue and green','Black and gray'],'flores son amarillas y rosas',5),
    (v_l7,'fill_blank','Translate to Spanish: "My shirt is blue."','Mi camisa es azul',array['Mi camisa está azul','Mi camisa azul','Mi camisa son azul'],'My shirt is blue',1),
    (v_l7,'fill_blank','Translate to Spanish: "The house is white."','La casa es blanca',array['La casa está blanca','La casa son blanca','La casa es blanco'],'The house is white',2),
    (v_l7,'fill_blank','Translate to Spanish: "I like green."','Me gusta el verde',array['Yo gusta verde','Me gusta verde','Me gustan el verde'],'I like green',3),
    (v_l7,'fill_blank','Translate to Spanish: "The flowers are yellow."','Las flores son amarillas',array['Las flores están amarillas','Las flores es amarillas','Los flores son amarillos'],'The flowers are yellow',4),
    (v_l7,'fill_blank','Translate to Spanish: "What color is it?"','¿De qué color es?',array['¿Qué color tiene?','¿Cómo es el color?','¿Cuál color es?'],'What color is it?',5);

  -- ============== A1.4 FAMILY ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Family';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'Mi familia es pequeña. Mi madre se llama Carmen y mi padre se llama Luis. Tengo un hermano y una hermana. Mi hermano tiene quince años. Vivimos juntos en Sevilla.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','What is "mother" in Spanish?','madre',array['padre','hermana','abuela'],'Mother [MAH-dreh]',1),
    (v_l1,'multiple_choice','What is "father" in Spanish?','padre',array['madre','hermano','hijo'],'Father [PAH-dreh]',2),
    (v_l1,'multiple_choice','What is "brother" in Spanish?','hermano',array['hermana','primo','tío'],'Brother [ehr-MAH-noh]',3),
    (v_l1,'multiple_choice','What is "sister" in Spanish?','hermana',array['hermano','prima','tía'],'Sister [ehr-MAH-nah]',4),
    (v_l1,'multiple_choice','What is "son" in Spanish?','hijo',array['hija','hermano','padre'],'Son [EE-hoh]',5),
    (v_l2,'fill_blank','Complete: "___ madre es buena." (My mother is good.)','Mi',array['Mí','Me','Yo'],'My (possessive)',1),
    (v_l2,'fill_blank','Complete: "___ padre es alto." (Your father is tall.)','Tu',array['Tú','Te','Mi'],'Your (informal)',2),
    (v_l2,'fill_blank','Complete: "Tengo ___ hermana." (I have a sister.)','una',array['un','la','el'],'a (f.)',3),
    (v_l2,'fill_blank','Complete: "Mis padres ___ aquí." (My parents are here.)','están',array['son','tienen','es'],'are (estar, location)',4),
    (v_l2,'fill_blank','Complete: "Tengo dos ___" (I have two brothers.)','hermanos',array['hermana','hermanas','hermano'],'brothers',5),
    (v_l3,'multiple_choice','What does "¿Tienes hermanos?" mean?','Do you have siblings?',array['Are you a sibling?','Do you know my brother?','Where are your siblings?'],'Do you have siblings?',1),
    (v_l3,'multiple_choice','What does "Mi madre se llama Ana" mean?','My mother is called Ana',array['My mother knows Ana','I call my mother Ana','Ana is my mother''s friend'],'My mother is called Ana',2),
    (v_l3,'multiple_choice','What does "Mi padre tiene cincuenta años" mean?','My father is 50 years old',array['My father has 50 things','My father lived 50 years ago','My father is 5'],'My father is 50 years old',3),
    (v_l3,'multiple_choice','What does "Vivimos juntos" mean?','We live together',array['We are together','We go together','We see together'],'We live together',4),
    (v_l3,'multiple_choice','What does "Mi familia es grande" mean?','My family is big',array['My family is here','My family is good','My family is mine'],'My family is big',5),
    (v_l4,'listening','Listen and pick the English meaning.','Tengo dos hermanas',array['I have two cats','I am two','I have two sisters'],'I have two sisters',1),
    (v_l4,'listening','Listen and pick the English meaning.','Mi madre es profesora',array['My mother is a teacher','My mother is a doctor','My mother is at school'],'My mother is a teacher',2),
    (v_l4,'listening','Listen and pick the English meaning.','Mi familia vive en Madrid',array['My family is from Madrid','My family lives in Madrid','I visit my family in Madrid'],'My family lives in Madrid',3),
    (v_l4,'listening','Listen and pick the English meaning.','Mi abuela tiene ochenta años',array['My grandmother is 18','My grandfather is 80','My grandmother is 80'],'My grandmother is 80',4),
    (v_l4,'listening','Listen and pick the English meaning.','Mi hermano es alto',array['My brother is tall','My brother is happy','My brother is young'],'My brother is tall',5),
    (v_l5,'speaking','Say this aloud: "Mi madre se llama Carmen." [mee MAH-dreh seh YAH-mah KAR-mehn]','Mi madre se llama Carmen',array[]::text[],'My mother is called Carmen.',1),
    (v_l5,'speaking','Say this aloud: "Tengo un hermano." [TEHN-goh oon ehr-MAH-noh]','Tengo un hermano',array[]::text[],'I have a brother.',2),
    (v_l5,'speaking','Say this aloud: "Mi familia es pequeña." [mee fah-MEE-lyah ehs peh-KEH-nyah]','Mi familia es pequeña',array[]::text[],'My family is small.',3),
    (v_l5,'speaking','Say this aloud: "Mi padre es médico." [mee PAH-dreh ehs MEH-dee-koh]','Mi padre es médico',array[]::text[],'My father is a doctor.',4),
    (v_l5,'speaking','Say this aloud: "Vivimos en Madrid." [bee-BEE-mohs ehn mah-DREED]','Vivimos en Madrid',array[]::text[],'We live in Madrid.',5),
    (v_l6,'multiple_choice','Is the speakers family big or small?','Small',array['Big','Very big','Average'],'familia es pequeña',1),
    (v_l6,'multiple_choice','What is the mothers name?','Carmen',array['Ana','Luisa','María'],'mi madre se llama Carmen',2),
    (v_l6,'multiple_choice','What is the fathers name?','Luis',array['Luis Carlos','Pedro','Carmen'],'mi padre se llama Luis',3),
    (v_l6,'multiple_choice','How many siblings does the speaker have?','Two (a brother and a sister)',array['One','Three','None'],'un hermano y una hermana',4),
    (v_l6,'multiple_choice','Where do they live?','Sevilla',array['Madrid','Barcelona','Granada'],'vivimos juntos en Sevilla',5),
    (v_l7,'fill_blank','Translate to Spanish: "My mother is called Ana."','Mi madre se llama Ana',array['Mi madre llama Ana','Madre se llama Ana','Mi madre es Ana'],'My mother is called Ana',1),
    (v_l7,'fill_blank','Translate to Spanish: "I have a brother and a sister."','Tengo un hermano y una hermana',array['Tengo hermano y hermana','Tengo una hermano y un hermana','Soy un hermano y una hermana'],'I have a brother and a sister',2),
    (v_l7,'fill_blank','Translate to Spanish: "My family is big."','Mi familia es grande',array['Mi familia está grande','Mi familia son grande','Mi familia gran'],'My family is big',3),
    (v_l7,'fill_blank','Translate to Spanish: "My father is a doctor."','Mi padre es médico',array['Mi padre está médico','Mi padre es un médico (also OK)','Mi padre médico'],'My father is a doctor (default no article)',4),
    (v_l7,'fill_blank','Translate to Spanish: "We live in Madrid."','Vivimos en Madrid',array['Vivimos a Madrid','Vivimos con Madrid','Vivos en Madrid'],'We live in Madrid',5);

  -- ============== A1.5 FOOD ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Food';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'Por la mañana, desayuno pan con queso y un café. Al mediodía como ensalada y pollo. Para cenar, prefiero sopa y fruta. Bebo mucha agua durante el día.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','What is "bread" in Spanish?','pan',array['pasta','papa','pera'],'Bread [PAHN]',1),
    (v_l1,'multiple_choice','What is "water" in Spanish?','agua',array['aceite','azúcar','aire'],'Water [AH-gwah]',2),
    (v_l1,'multiple_choice','What is "milk" in Spanish?','leche',array['lechuga','licor','laca'],'Milk [LEH-cheh]',3),
    (v_l1,'multiple_choice','What is "cheese" in Spanish?','queso',array['queja','quemar','queso azul'],'Cheese [KEH-soh]',4),
    (v_l1,'multiple_choice','What is "apple" in Spanish?','manzana',array['plátano','mañana','melón'],'Apple [mahn-SAH-nah]',5),
    (v_l2,'fill_blank','Complete: "Quiero ___ pan." (I want bread.)','el',array['un (also OK; el preferred here)','la','los'],'the / some (mass)',1),
    (v_l2,'fill_blank','Complete: "Como ___ manzana." (I eat an apple.)','una',array['un','la','las'],'an (f.)',2),
    (v_l2,'fill_blank','Complete: "Bebo ___ agua." (I drink water.)','el',array['la (article often dropped: bebo agua)','los','las'],'the (mass noun)',3),
    (v_l2,'fill_blank','Complete: "Compro ___ patatas." (I buy potatoes.)','las',array['los','la','el'],'the (f.pl)',4),
    (v_l2,'fill_blank','Complete: "Tengo ___" (I am hungry.)','hambre',array['hambriento','hambres','hambrar'],'hunger (tener idiom)',5),
    (v_l3,'multiple_choice','What does "Tengo hambre" mean?','I am hungry',array['I am thirsty','I am tired','I am late'],'I am hungry',1),
    (v_l3,'multiple_choice','What does "¿Qué quieres comer?" mean?','What do you want to eat?',array['What is for dinner?','Where do you eat?','Are you hungry?'],'What do you want to eat?',2),
    (v_l3,'multiple_choice','What does "Buen provecho" mean?','Enjoy your meal',array['Good morning','Thank you','See you later'],'Enjoy your meal',3),
    (v_l3,'multiple_choice','What does "La comida está rica" mean?','The food is delicious',array['The food is bad','I want food','Food is here'],'The food is delicious',4),
    (v_l3,'multiple_choice','What does "Un café, por favor" mean?','A coffee, please',array['I like coffee','Tea or coffee','I drank coffee'],'A coffee, please',5),
    (v_l4,'listening','Listen and pick the English meaning.','Quiero agua, por favor',array['I want milk, please','I want water, please','I have water'],'I want water, please',1),
    (v_l4,'listening','Listen and pick the English meaning.','Como pan con queso',array['I eat bread with cheese','I cook bread','I want cheese'],'I eat bread with cheese',2),
    (v_l4,'listening','Listen and pick the English meaning.','Tengo mucha hambre',array['I am very tired','I am very hungry','I am very thirsty'],'I am very hungry',3),
    (v_l4,'listening','Listen and pick the English meaning.','La sopa está caliente',array['The soup is cold','The soup is salty','The soup is hot'],'The soup is hot',4),
    (v_l4,'listening','Listen and pick the English meaning.','Me gusta la fruta',array['I have fruit','I like fruit','I buy fruit'],'I like fruit',5),
    (v_l5,'speaking','Say this aloud: "Tengo hambre." [TEHN-goh AHM-breh]','Tengo hambre',array[]::text[],'I am hungry.',1),
    (v_l5,'speaking','Say this aloud: "Quiero un café." [KYEH-roh oon kah-FEH]','Quiero un café',array[]::text[],'I want a coffee.',2),
    (v_l5,'speaking','Say this aloud: "Me gusta el pan." [meh GOOS-tah ehl PAHN]','Me gusta el pan',array[]::text[],'I like bread.',3),
    (v_l5,'speaking','Say this aloud: "Bebo agua." [BEH-boh AH-gwah]','Bebo agua',array[]::text[],'I drink water.',4),
    (v_l5,'speaking','Say this aloud: "Buen provecho." [BWEHN proh-BEH-choh]','Buen provecho',array[]::text[],'Enjoy your meal.',5),
    (v_l6,'multiple_choice','What does the speaker have for breakfast?','Bread with cheese and coffee',array['Just coffee','Soup and fruit','Salad and chicken'],'desayuno pan con queso y un café',1),
    (v_l6,'multiple_choice','What does the speaker have for lunch?','Salad and chicken',array['Bread and cheese','Soup and fruit','Just water'],'como ensalada y pollo',2),
    (v_l6,'multiple_choice','What does the speaker prefer for dinner?','Soup and fruit',array['Salad and chicken','Bread and water','Coffee and milk'],'cenar, prefiero sopa y fruta',3),
    (v_l6,'multiple_choice','What does the speaker drink a lot of?','Water',array['Coffee','Milk','Wine'],'bebo mucha agua',4),
    (v_l6,'multiple_choice','When does the speaker have breakfast?','In the morning',array['At noon','At night','In the afternoon'],'por la mañana, desayuno',5),
    (v_l7,'fill_blank','Translate to Spanish: "I want a coffee."','Quiero un café',array['Yo quiero café','Quiero el café','Quero un café'],'I want a coffee',1),
    (v_l7,'fill_blank','Translate to Spanish: "I am hungry."','Tengo hambre',array['Estoy hambre','Soy hambre','Tengo hambriento'],'I am hungry',2),
    (v_l7,'fill_blank','Translate to Spanish: "I like bread."','Me gusta el pan',array['Yo gusto pan','Me gusta pan','Me gustan el pan'],'I like bread',3),
    (v_l7,'fill_blank','Translate to Spanish: "I drink water."','Bebo agua',array['Tomo agua (also OK)','Yo bebe agua','Bebamos agua'],'I drink water',4),
    (v_l7,'fill_blank','Translate to Spanish: "The food is delicious."','La comida está rica',array['La comida es rica (acceptable)','La comida ricos','La comida está ricos'],'The food is delicious (estar with state)',5);

  -- ============== A1.6 TIME ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Time';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'Hoy es martes. Son las nueve de la mañana. Tengo una reunión a las diez. Por la tarde voy al gimnasio. Por la noche ceno a las nueve.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','What is "hour" in Spanish?','hora',array['horror','ahora','horno'],'Hour [OH-rah]',1),
    (v_l1,'multiple_choice','What is "day" in Spanish?','día',array['dios','dia (no accent)','año'],'Day [DEE-ah]',2),
    (v_l1,'multiple_choice','What is "week" in Spanish?','semana',array['mes','siempre','semáforo'],'Week [seh-MAH-nah]',3),
    (v_l1,'multiple_choice','What is "month" in Spanish?','mes',array['mas','mar','mesa'],'Month [MEHS]',4),
    (v_l1,'multiple_choice','What is "year" in Spanish?','año',array['ano','agua','antes'],'Year [AH-nyoh]',5),
    (v_l2,'fill_blank','Complete: "___ las tres." (It is 3 oclock.)','Son',array['Es','Está','Tiene'],'It is (3+, plural)',1),
    (v_l2,'fill_blank','Complete: "Es ___ una." (It is 1 oclock.)','la',array['las','el','los'],'the (1 is singular)',2),
    (v_l2,'fill_blank','Complete: "Tengo clase ___ las ocho." (at 8.)','a',array['en','de','para'],'at (time)',3),
    (v_l2,'fill_blank','Complete: "Hoy ___ martes." (Today is Tuesday.)','es',array['está','son','tiene'],'is (ser, days)',4),
    (v_l2,'fill_blank','Complete: "Son las nueve ___ la mañana." (in the morning)','de',array['en','por','a'],'in (de la mañana)',5),
    (v_l3,'multiple_choice','What does "¿Qué hora es?" mean?','What time is it?',array['What day is it?','What is your name?','How are you?'],'What time is it?',1),
    (v_l3,'multiple_choice','What does "Son las tres" mean?','It is 3 oclock',array['I have 3','Three of them','3 days'],'It is 3 oclock',2),
    (v_l3,'multiple_choice','What does "Hoy es lunes" mean?','Today is Monday',array['Today I work','I love Mondays','Yesterday was Monday'],'Today is Monday',3),
    (v_l3,'multiple_choice','What does "Por la mañana" mean?','In the morning',array['Tomorrow','In the afternoon','At night'],'In the morning',4),
    (v_l3,'multiple_choice','What does "Es muy tarde" mean?','It is very late',array['It is early','It is good','It is mine'],'It is very late',5),
    (v_l4,'listening','Listen and pick the English meaning.','Son las cinco',array['It is 15','It is 5 oclock','I have 5'],'It is 5 oclock',1),
    (v_l4,'listening','Listen and pick the English meaning.','Hoy es viernes',array['Yesterday was Friday','Today is Friday','Tomorrow is Friday'],'Today is Friday',2),
    (v_l4,'listening','Listen and pick the English meaning.','Por la noche',array['In the morning','In the afternoon','At night'],'At night',3),
    (v_l4,'listening','Listen and pick the English meaning.','¿Qué hora es?',array['What is your name?','What time is it?','What day is it?'],'What time is it?',4),
    (v_l4,'listening','Listen and pick the English meaning.','Tengo clase a las ocho',array['I have class at 8','I have 8 classes','My class lasts 8 hours'],'I have class at 8',5),
    (v_l5,'speaking','Say this aloud: "¿Qué hora es?" [keh OH-rah ehs]','¿Qué hora es?',array[]::text[],'What time is it?',1),
    (v_l5,'speaking','Say this aloud: "Son las cinco." [sohn lahs SEEN-koh]','Son las cinco',array[]::text[],'It is 5 oclock.',2),
    (v_l5,'speaking','Say this aloud: "Hoy es lunes." [oy ehs LOO-nehs]','Hoy es lunes',array[]::text[],'Today is Monday.',3),
    (v_l5,'speaking','Say this aloud: "Es la una de la tarde." [ehs lah OO-nah deh lah TAR-deh]','Es la una de la tarde',array[]::text[],'It is 1 PM.',4),
    (v_l5,'speaking','Say this aloud: "Mañana es sábado." [mah-NYAH-nah ehs SAH-bah-doh]','Mañana es sábado',array[]::text[],'Tomorrow is Saturday.',5),
    (v_l6,'multiple_choice','What day is it today?','Tuesday',array['Monday','Wednesday','Friday'],'hoy es martes',1),
    (v_l6,'multiple_choice','What time is it in the morning?','9 AM',array['10 AM','8 AM','7 AM'],'son las nueve de la mañana',2),
    (v_l6,'multiple_choice','What time is the meeting?','10',array['9','11','12'],'reunión a las diez',3),
    (v_l6,'multiple_choice','Where does the speaker go in the afternoon?','The gym',array['Work','Home','School'],'por la tarde voy al gimnasio',4),
    (v_l6,'multiple_choice','When does the speaker have dinner?','9 PM',array['7 PM','10 PM','8 PM'],'ceno a las nueve',5),
    (v_l7,'fill_blank','Translate to Spanish: "What time is it?"','¿Qué hora es?',array['¿Cuánto es?','¿Cuál hora?','¿Qué horas?'],'What time is it?',1),
    (v_l7,'fill_blank','Translate to Spanish: "It is 8 oclock."','Son las ocho',array['Es las ocho','Es ocho','Son los ocho'],'It is 8 oclock',2),
    (v_l7,'fill_blank','Translate to Spanish: "Today is Monday."','Hoy es lunes',array['Hoy está lunes','Hoy son lunes','El día es lunes'],'Today is Monday',3),
    (v_l7,'fill_blank','Translate to Spanish: "In the morning."','Por la mañana',array['En la mañana (also OK in LatAm)','Para mañana','A la mañana'],'In the morning',4),
    (v_l7,'fill_blank','Translate to Spanish: "I have class at 10."','Tengo clase a las diez',array['Tengo clase en diez','Tengo clase las diez','Tengo clase de diez'],'I have class at 10',5);

  -- ============== A1.7 WEATHER ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Weather';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'Hoy hace mucho sol. La temperatura es de treinta grados. No llueve y no hay viento. Mañana va a llover. Me gusta el verano porque hace calor.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','What is "sun" in Spanish?','sol',array['sal','suelo','sólo'],'Sun [SOHL]',1),
    (v_l1,'multiple_choice','What is "rain" in Spanish?','lluvia',array['llanto','lleva','lágrima'],'Rain [YOO-byah]',2),
    (v_l1,'multiple_choice','What is "snow" in Spanish?','nieve',array['nueve','nube','nada'],'Snow [NYEH-beh]',3),
    (v_l1,'multiple_choice','What is "cold" in Spanish?','frío',array['fresco','frente','fruta'],'Cold [FREE-oh]',4),
    (v_l1,'multiple_choice','What is "hot" (weather) in Spanish?','calor',array['caliente','color','callado'],'Heat [kah-LOHR]',5),
    (v_l2,'fill_blank','Complete: "___ sol hoy." (It is sunny today.)','Hace',array['Hay','Es','Está'],'(hacer + weather noun)',1),
    (v_l2,'fill_blank','Complete: "___ frío en invierno." (It is cold in winter.)','Hace',array['Es','Está','Tiene'],'(hace + frío)',2),
    (v_l2,'fill_blank','Complete: "___ mucho viento." (It is very windy.)','Hace',array['Hay','Es','Está'],'(hace + viento)',3),
    (v_l2,'fill_blank','Complete: "Hoy ___" (Today it is raining.)','llueve',array['llover','lluvia','llovió'],'(impersonal verb)',4),
    (v_l2,'fill_blank','Complete: "El cielo ___ azul." (The sky is blue.)','es',array['está','tiene','son'],'is (ser, color)',5),
    (v_l3,'multiple_choice','What does "¿Qué tiempo hace?" mean?','What is the weather like?',array['What time is it?','How are you?','How is it going?'],'What is the weather like?',1),
    (v_l3,'multiple_choice','What does "Hace sol" mean?','It is sunny',array['I am sunny','The sun is here','I see the sun'],'It is sunny',2),
    (v_l3,'multiple_choice','What does "Tengo frío" mean?','I am cold (person)',array['It is cold','I have a cold','I am sick'],'I am cold (person)',3),
    (v_l3,'multiple_choice','What does "Está nublado" mean?','It is cloudy',array['It is raining','It is foggy','It is windy'],'It is cloudy',4),
    (v_l3,'multiple_choice','What does "Hace buen tiempo" mean?','The weather is nice',array['The weather is bad','I have time','I am on time'],'The weather is nice',5),
    (v_l4,'listening','Listen and pick the English meaning.','Hace mucho calor',array['It is very cold','It is very hot','I am very tired'],'It is very hot',1),
    (v_l4,'listening','Listen and pick the English meaning.','Llueve mucho hoy',array['It is windy today','It is raining a lot today','It is sunny today'],'It is raining a lot today',2),
    (v_l4,'listening','Listen and pick the English meaning.','Hace viento',array['It is sunny','It is windy','It is snowing'],'It is windy',3),
    (v_l4,'listening','Listen and pick the English meaning.','El cielo está despejado',array['The sky is clear','The sky is cloudy','I love the sky'],'The sky is clear',4),
    (v_l4,'listening','Listen and pick the English meaning.','Tengo frío',array['I am sick','I am hungry','I am cold'],'I am cold',5),
    (v_l5,'speaking','Say this aloud: "Hace mucho sol." [AH-seh MOO-choh SOHL]','Hace mucho sol',array[]::text[],'It is very sunny.',1),
    (v_l5,'speaking','Say this aloud: "Tengo frío." [TEHN-goh FREE-oh]','Tengo frío',array[]::text[],'I am cold.',2),
    (v_l5,'speaking','Say this aloud: "Está lloviendo." [ehs-TAH yoh-BYEHN-doh]','Está lloviendo',array[]::text[],'It is raining.',3),
    (v_l5,'speaking','Say this aloud: "Hace buen tiempo." [AH-seh BWEHN TYEHM-poh]','Hace buen tiempo',array[]::text[],'The weather is nice.',4),
    (v_l5,'speaking','Say this aloud: "Mañana va a nevar." [mah-NYAH-nah bah ah neh-BAHR]','Mañana va a nevar',array[]::text[],'Tomorrow it will snow.',5),
    (v_l6,'multiple_choice','What is the weather today?','Sunny',array['Cloudy','Raining','Snowing'],'hoy hace mucho sol',1),
    (v_l6,'multiple_choice','What is the temperature?','30 degrees',array['13 degrees','3 degrees','20 degrees'],'temperatura es de treinta grados',2),
    (v_l6,'multiple_choice','Is it raining today?','No',array['Yes','Sometimes','Yesterday'],'no llueve',3),
    (v_l6,'multiple_choice','What is the weather tomorrow?','Going to rain',array['Snowing','Sunny','Windy'],'mañana va a llover',4),
    (v_l6,'multiple_choice','What season does the speaker like?','Summer',array['Winter','Autumn','Spring'],'me gusta el verano',5),
    (v_l7,'fill_blank','Translate to Spanish: "It is sunny."','Hace sol',array['Está sol','Es sol','Tiene sol'],'It is sunny',1),
    (v_l7,'fill_blank','Translate to Spanish: "I am cold."','Tengo frío',array['Estoy frío','Soy frío','Hay frío'],'I am cold (person)',2),
    (v_l7,'fill_blank','Translate to Spanish: "It is raining."','Llueve',array['Está lluvia','Hay lluvia (also OK as noun)','Lluvia'],'It is raining',3),
    (v_l7,'fill_blank','Translate to Spanish: "Today the weather is nice."','Hoy hace buen tiempo',array['Hoy es buen tiempo','Hoy está buen tiempo','Hoy bien tiempo'],'Today the weather is nice',4),
    (v_l7,'fill_blank','Translate to Spanish: "Tomorrow it will snow."','Mañana va a nevar',array['Mañana nieva','Mañana nevar','Mañana nieve'],'Tomorrow it will snow',5);

  -- ============== A1.8 SHOPPING ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Shopping';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'Voy a la tienda con mi madre. Compramos pan, leche y manzanas. El pan cuesta dos euros. Pagamos con tarjeta. La tienda está cerca de mi casa.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','What is "store" in Spanish?','tienda',array['ventana','tarde','tarea'],'Store [TYEHN-dah]',1),
    (v_l1,'multiple_choice','What is "to buy" in Spanish?','comprar',array['vender','pagar','comer'],'To buy [kohm-PRAHR]',2),
    (v_l1,'multiple_choice','What is "money" in Spanish?','dinero',array['dinámico','dentro','dirección'],'Money [dee-NEH-roh]',3),
    (v_l1,'multiple_choice','What is "price" in Spanish?','precio',array['precioso','pregunta','presente'],'Price [PREH-syoh]',4),
    (v_l1,'multiple_choice','What is "expensive" in Spanish?','caro',array['barato','cariño','calor'],'Expensive [KAH-roh]',5),
    (v_l2,'fill_blank','Complete: "___ cuesta?" (How much does it cost?)','Cuánto',array['Cuál','Cómo','Qué'],'how much',1),
    (v_l2,'fill_blank','Complete: "Quiero ___ pan." (I want to buy bread.)','comprar',array['compro','compré','compras'],'to buy (infinitive)',2),
    (v_l2,'fill_blank','Complete: "Pago ___ tarjeta." (I pay by card.)','con',array['en','de','a'],'with',3),
    (v_l2,'fill_blank','Complete: "Es muy ___" (It is very expensive.)','caro',array['cara','caros','baratos'],'expensive (m.sg)',4),
    (v_l2,'fill_blank','Complete: "Cuesta diez ___" (It costs 10 euros.)','euros',array['euro','dólar','peso'],'euros',5),
    (v_l3,'multiple_choice','What does "¿Cuánto cuesta?" mean?','How much does it cost?',array['How are you?','Where is it?','Whats your name?'],'How much does it cost?',1),
    (v_l3,'multiple_choice','What does "Es muy caro" mean?','It is very expensive',array['It is very cheap','It is very big','It is mine'],'It is very expensive',2),
    (v_l3,'multiple_choice','What does "Pago con tarjeta" mean?','I pay by card',array['I have a card','My card is here','I want a card'],'I pay by card',3),
    (v_l3,'multiple_choice','What does "Voy a la tienda" mean?','I am going to the store',array['I am at the store','I love the store','The store is open'],'I am going to the store',4),
    (v_l3,'multiple_choice','What does "Quiero esto" mean?','I want this',array['I have this','I see this','I make this'],'I want this',5),
    (v_l4,'listening','Listen and pick the English meaning.','¿Cuánto cuesta el pan?',array['Where is the bread?','How much does the bread cost?','Do you have bread?'],'How much does the bread cost?',1),
    (v_l4,'listening','Listen and pick the English meaning.','Quiero comprar leche',array['I want to drink milk','I want to sell milk','I want to buy milk'],'I want to buy milk',2),
    (v_l4,'listening','Listen and pick the English meaning.','Es muy barato',array['It is very expensive','It is very cheap','It is very big'],'It is very cheap',3),
    (v_l4,'listening','Listen and pick the English meaning.','¿Tiene cambio?',array['Do you have change?','Do you have time?','Do you have it?'],'Do you have change?',4),
    (v_l4,'listening','Listen and pick the English meaning.','Pago en efectivo',array['I pay by card','I pay in cash','I have no money'],'I pay in cash',5),
    (v_l5,'speaking','Say this aloud: "¿Cuánto cuesta?" [KWAHN-toh KWEHS-tah]','¿Cuánto cuesta?',array[]::text[],'How much does it cost?',1),
    (v_l5,'speaking','Say this aloud: "Quiero comprar pan." [KYEH-roh kohm-PRAHR PAHN]','Quiero comprar pan',array[]::text[],'I want to buy bread.',2),
    (v_l5,'speaking','Say this aloud: "Es muy caro." [ehs MWEE KAH-roh]','Es muy caro',array[]::text[],'It is very expensive.',3),
    (v_l5,'speaking','Say this aloud: "Pago con tarjeta." [PAH-goh kohn tahr-HEH-tah]','Pago con tarjeta',array[]::text[],'I pay by card.',4),
    (v_l5,'speaking','Say this aloud: "Gracias, hasta luego." [GRAH-syahs AHS-tah LWEH-goh]','Gracias, hasta luego',array[]::text[],'Thanks, see you later.',5),
    (v_l6,'multiple_choice','Who does the speaker go shopping with?','Mother',array['Father','Sister','Friend'],'voy a la tienda con mi madre',1),
    (v_l6,'multiple_choice','What do they buy?','Bread, milk, apples',array['Cheese and water','Soup and chicken','Salad'],'compramos pan, leche y manzanas',2),
    (v_l6,'multiple_choice','How much does the bread cost?','2 euros',array['12 euros','20 euros','5 euros'],'pan cuesta dos euros',3),
    (v_l6,'multiple_choice','How do they pay?','By card',array['In cash','With check','They do not pay'],'pagamos con tarjeta',4),
    (v_l6,'multiple_choice','Where is the store?','Near my house',array['Far from my house','At the school','In the city center'],'tienda está cerca de mi casa',5),
    (v_l7,'fill_blank','Translate to Spanish: "How much does it cost?"','¿Cuánto cuesta?',array['¿Cuánto es?','¿Cómo cuesta?','¿Qué cuesta?'],'How much does it cost?',1),
    (v_l7,'fill_blank','Translate to Spanish: "I want to buy bread."','Quiero comprar pan',array['Yo quiero pan','Quiero comprar el pan (also OK)','Compro pan'],'I want to buy bread',2),
    (v_l7,'fill_blank','Translate to Spanish: "It is very cheap."','Es muy barato',array['Está muy barato','Hay muy barato','Tiene barato'],'It is very cheap',3),
    (v_l7,'fill_blank','Translate to Spanish: "I pay by card."','Pago con tarjeta',array['Pago en tarjeta','Pago de tarjeta','Pago a tarjeta'],'I pay by card',4),
    (v_l7,'fill_blank','Translate to Spanish: "Do you have change?"','¿Tiene cambio?',array['¿Tienes cambias?','¿Tiene cambia?','¿Hay cambio?'],'Do you have change? (formal)',5);

  -- ============== A1.9 ANIMALS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Animals';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'En mi casa vive un perro y dos gatos. El perro se llama Max y es muy grande. Los gatos son pequeños y negros. También tengo un pájaro azul. Me gustan mucho los animales.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','What is "dog" in Spanish?','perro',array['gato','pájaro','pez'],'Dog [PEH-rroh]',1),
    (v_l1,'multiple_choice','What is "cat" in Spanish?','gato',array['perro','pato','rato'],'Cat [GAH-toh]',2),
    (v_l1,'multiple_choice','What is "bird" in Spanish?','pájaro',array['pez','pelo','pato'],'Bird [PAH-hah-roh]',3),
    (v_l1,'multiple_choice','What is "fish" (animal) in Spanish?','pez',array['pescado (food)','pollo','pan'],'Fish (live) [PEHS]',4),
    (v_l1,'multiple_choice','What is "horse" in Spanish?','caballo',array['cabello (hair)','camello','cabra'],'Horse [kah-BAH-yoh]',5),
    (v_l2,'fill_blank','Complete: "Tengo ___ perro." (I have a dog.)','un',array['una','el','la'],'a (m.)',1),
    (v_l2,'fill_blank','Complete: "Mi ___ es negro." (My cat is black.)','gato',array['gata (only if female)','gatos','gates'],'cat',2),
    (v_l2,'fill_blank','Complete: "Los pájaros ___ pequeños." (The birds are small.)','son',array['está','están','es'],'are (ser, trait)',3),
    (v_l2,'fill_blank','Complete: "Veo ___ caballos." (I see the horses.)','los',array['las','el','la'],'the (m.pl)',4),
    (v_l2,'fill_blank','Complete: "Tengo ___ perro y ___ gato." (a dog and a cat)','un / un',array['un / una','una / un','el / el'],'a / a',5),
    (v_l3,'multiple_choice','What does "¿Tienes mascotas?" mean?','Do you have pets?',array['Are you a pet?','Do you like pets?','Where are pets?'],'Do you have pets?',1),
    (v_l3,'multiple_choice','What does "Me gustan los gatos" mean?','I like cats',array['I am a cat','I see cats','Cats like me'],'I like cats',2),
    (v_l3,'multiple_choice','What does "Mi perro se llama Max" mean?','My dog is called Max',array['I call my dog','Max calls my dog','I see Max'],'My dog is called Max',3),
    (v_l3,'multiple_choice','What does "El gato duerme" mean?','The cat is sleeping',array['The cat is eating','The cat is here','The cat is mine'],'The cat is sleeping',4),
    (v_l3,'multiple_choice','What does "Los animales son bonitos" mean?','Animals are pretty',array['I love animals','Animals are here','I see animals'],'Animals are pretty',5),
    (v_l4,'listening','Listen and pick the English meaning.','Tengo un perro grande',array['I have a big cat','I have a big dog','I want a big dog'],'I have a big dog',1),
    (v_l4,'listening','Listen and pick the English meaning.','Mi gato es negro',array['My dog is black','My cat is white','My cat is black'],'My cat is black',2),
    (v_l4,'listening','Listen and pick the English meaning.','Me gustan los pájaros',array['I like fish','I like birds','I have birds'],'I like birds',3),
    (v_l4,'listening','Listen and pick the English meaning.','Los caballos son rápidos',array['Horses are slow','Horses are fast','Horses are tall'],'Horses are fast',4),
    (v_l4,'listening','Listen and pick the English meaning.','No tengo mascota',array['I have a pet','I want a pet','I do not have a pet'],'I do not have a pet',5),
    (v_l5,'speaking','Say this aloud: "Tengo un perro." [TEHN-goh oon PEH-rroh]','Tengo un perro',array[]::text[],'I have a dog.',1),
    (v_l5,'speaking','Say this aloud: "Me gustan los gatos." [meh GOOS-tahn lohs GAH-tohs]','Me gustan los gatos',array[]::text[],'I like cats.',2),
    (v_l5,'speaking','Say this aloud: "Mi perro es grande." [mee PEH-rroh ehs GRAHN-deh]','Mi perro es grande',array[]::text[],'My dog is big.',3),
    (v_l5,'speaking','Say this aloud: "El pájaro canta." [ehl PAH-hah-roh KAHN-tah]','El pájaro canta',array[]::text[],'The bird sings.',4),
    (v_l5,'speaking','Say this aloud: "Los animales son bonitos." [lohs ah-nee-MAH-lehs sohn boh-NEE-tohs]','Los animales son bonitos',array[]::text[],'Animals are pretty.',5),
    (v_l6,'multiple_choice','How many cats does the speaker have?','Two',array['One','Three','None'],'dos gatos',1),
    (v_l6,'multiple_choice','What is the dogs name?','Max',array['Luna','Coco','Lola'],'el perro se llama Max',2),
    (v_l6,'multiple_choice','How is the dog described?','Big',array['Small','Old','Sick'],'es muy grande',3),
    (v_l6,'multiple_choice','What color are the cats?','Black',array['White','Brown','Gray'],'gatos son pequeños y negros',4),
    (v_l6,'multiple_choice','What color is the bird?','Blue',array['Yellow','Green','Red'],'pájaro azul',5),
    (v_l7,'fill_blank','Translate to Spanish: "I have a dog."','Tengo un perro',array['Yo perro tengo','Tengo el perro','Soy un perro'],'I have a dog',1),
    (v_l7,'fill_blank','Translate to Spanish: "I like cats."','Me gustan los gatos',array['Yo gusto gatos','Me gusta los gatos','Me gusto gatos'],'I like cats',2),
    (v_l7,'fill_blank','Translate to Spanish: "My dog is big."','Mi perro es grande',array['Mi perro está grande','Mi perro grande es','Mi perro es gran'],'My dog is big',3),
    (v_l7,'fill_blank','Translate to Spanish: "The cat is black."','El gato es negro',array['El gato está negro','El gata es negro','La gato es negro'],'The cat is black',4),
    (v_l7,'fill_blank','Translate to Spanish: "I do not have a pet."','No tengo mascota',array['No tengo una mascota (also OK)','No tener mascota','Yo no mascota'],'I do not have a pet',5);

  -- ============== A1.10 BODY PARTS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Body Parts';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'Tengo dos ojos verdes y el pelo negro. Mis manos son pequeñas. Hoy me duele la cabeza. Voy al médico mañana. Necesito descansar.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','What is "head" in Spanish?','cabeza',array['cabello','cara','cuello'],'Head [kah-BEH-sah]',1),
    (v_l1,'multiple_choice','What is "eye" in Spanish?','ojo',array['oreja','oído','onza'],'Eye [OH-hoh]',2),
    (v_l1,'multiple_choice','What is "hand" in Spanish?','mano',array['mañana','manzana','mar'],'Hand [MAH-noh]',3),
    (v_l1,'multiple_choice','What is "foot" in Spanish?','pie',array['piel','pero','poco'],'Foot [PYEH]',4),
    (v_l1,'multiple_choice','What is "arm" in Spanish?','brazo',array['barba','beso','brisa'],'Arm [BRAH-soh]',5),
    (v_l2,'fill_blank','Complete: "Me ___ la cabeza." (My head hurts.)','duele',array['duelo','duelen','dolor'],'hurts (singular)',1),
    (v_l2,'fill_blank','Complete: "Me ___ los pies." (My feet hurt.)','duelen',array['duele','duelo','dolor'],'hurt (plural)',2),
    (v_l2,'fill_blank','Complete: "Tengo dos ___" (I have two eyes.)','ojos',array['ojo','oreja','ojas'],'eyes',3),
    (v_l2,'fill_blank','Complete: "Mi pelo ___ negro." (My hair is black.)','es',array['está','tiene','son'],'is (ser, color)',4),
    (v_l2,'fill_blank','Complete: "Lavo ___ manos." (I wash my hands — Spanish uses article)','las',array['mis','los','la'],'the (body part)',5),
    (v_l3,'multiple_choice','What does "Me duele la cabeza" mean?','My head hurts',array['I love my head','My head is big','I shake my head'],'My head hurts',1),
    (v_l3,'multiple_choice','What does "Tengo los ojos azules" mean?','I have blue eyes',array['I see blue','I want blue','I am blue'],'I have blue eyes',2),
    (v_l3,'multiple_choice','What does "Lava las manos" mean?','Wash your hands',array['I see hands','Your hands are clean','Hand me that'],'Wash your hands (cmd)',3),
    (v_l3,'multiple_choice','What does "Tengo dolor de estómago" mean?','I have a stomachache',array['I have a stomach','I am hungry','My stomach is here'],'I have a stomachache',4),
    (v_l3,'multiple_choice','What does "Mi nariz" mean?','My nose',array['My mouth','My hair','My ear'],'My nose',5),
    (v_l4,'listening','Listen and pick the English meaning.','Me duele la cabeza',array['I am hungry','My head hurts','I love my head'],'My head hurts',1),
    (v_l4,'listening','Listen and pick the English meaning.','Tengo los ojos verdes',array['I have green eyes','I see green','My eyes are tired'],'I have green eyes',2),
    (v_l4,'listening','Listen and pick the English meaning.','Mi mano derecha',array['My right hand','My left hand','My right foot'],'My right hand',3),
    (v_l4,'listening','Listen and pick the English meaning.','Necesito descansar',array['I need to rest','I need water','I need food'],'I need to rest',4),
    (v_l4,'listening','Listen and pick the English meaning.','Voy al médico',array['I am the doctor','I go to the doctor','I work at the doctors'],'I go to the doctor',5),
    (v_l5,'speaking','Say this aloud: "Me duele la cabeza." [meh DWEH-leh lah kah-BEH-sah]','Me duele la cabeza',array[]::text[],'My head hurts.',1),
    (v_l5,'speaking','Say this aloud: "Tengo los ojos azules." [TEHN-goh lohs OH-hohs ah-SOO-lehs]','Tengo los ojos azules',array[]::text[],'I have blue eyes.',2),
    (v_l5,'speaking','Say this aloud: "Lavo las manos." [LAH-boh lahs MAH-nohs]','Lavo las manos',array[]::text[],'I wash my hands.',3),
    (v_l5,'speaking','Say this aloud: "Voy al médico." [BOY ahl MEH-dee-koh]','Voy al médico',array[]::text[],'I go to the doctor.',4),
    (v_l5,'speaking','Say this aloud: "Necesito descansar." [neh-seh-SEE-toh dehs-kahn-SAHR]','Necesito descansar',array[]::text[],'I need to rest.',5),
    (v_l6,'multiple_choice','What color are the speakers eyes?','Green',array['Blue','Brown','Black'],'dos ojos verdes',1),
    (v_l6,'multiple_choice','What color is the speakers hair?','Black',array['Brown','Blond','Red'],'pelo negro',2),
    (v_l6,'multiple_choice','How are the speakers hands?','Small',array['Big','Strong','Cold'],'manos son pequeñas',3),
    (v_l6,'multiple_choice','What hurts today?','The head',array['The stomach','The eyes','The hand'],'me duele la cabeza',4),
    (v_l6,'multiple_choice','Where will the speaker go tomorrow?','The doctor',array['The store','School','Work'],'voy al médico mañana',5),
    (v_l7,'fill_blank','Translate to Spanish: "My head hurts."','Me duele la cabeza',array['Me duelo la cabeza','Mi cabeza duele','La cabeza duele me'],'My head hurts',1),
    (v_l7,'fill_blank','Translate to Spanish: "I have green eyes."','Tengo los ojos verdes',array['Tengo verdes ojos','Tengo ojos verdes (also OK)','Soy ojos verdes'],'I have green eyes (definite article preferred)',2),
    (v_l7,'fill_blank','Translate to Spanish: "I wash my hands."','Me lavo las manos',array['Yo lavo mis manos','Lavo las manos (also OK if context clear)','Yo lavo mano'],'I wash my hands (reflexive)',3),
    (v_l7,'fill_blank','Translate to Spanish: "I need to rest."','Necesito descansar',array['Necesito descanso','Yo descanso','Necesito a descansar'],'I need to rest',4),
    (v_l7,'fill_blank','Translate to Spanish: "I go to the doctor."','Voy al médico',array['Yo voy a médico','Voy a el médico','Voy en médico'],'I go to the doctor',5);

  -- ============== A1.11 CLOTHES ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Clothes';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'Hoy llevo una camisa blanca y unos pantalones negros. Mis zapatos son nuevos. Hace frío, así que también llevo una chaqueta. Mi sombrero es rojo.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','What is "shirt" in Spanish?','camisa',array['camiseta (t-shirt)','cama','calle'],'Shirt [kah-MEE-sah]',1),
    (v_l1,'multiple_choice','What is "trousers / pants" in Spanish?','pantalones',array['zapatos','sombrero','manga'],'Trousers [pahn-tah-LOH-nehs]',2),
    (v_l1,'multiple_choice','What is "shoes" in Spanish?','zapatos',array['pies','pantalones','sandalias'],'Shoes [sah-PAH-tohs]',3),
    (v_l1,'multiple_choice','What is "dress" in Spanish?','vestido',array['vestir','vista','viste'],'Dress [behs-TEE-doh]',4),
    (v_l1,'multiple_choice','What is "hat" in Spanish?','sombrero',array['sombra','sombrilla','sombría'],'Hat [sohm-BREH-roh]',5),
    (v_l2,'fill_blank','Complete: "Me ___ los zapatos." (I put on my shoes.)','pongo',array['poner','pone','ponemos'],'I put on (ponerse)',1),
    (v_l2,'fill_blank','Complete: "___ una camisa azul." (I am wearing a blue shirt.)','Llevo',array['Lleva','Llevan','Llevar'],'I wear / am wearing',2),
    (v_l2,'fill_blank','Complete: "Mis zapatos ___ nuevos." (My shoes are new.)','son',array['está','están','es'],'are (ser, trait)',3),
    (v_l2,'fill_blank','Complete: "Llevo un ___ rojo." (a red hat)','sombrero',array['sombreros','sombrera','sombrería'],'hat',4),
    (v_l2,'fill_blank','Complete: "Una ___ negra." (A black dress.)','falda',array['vestido (m.)','pantalón','sombrero'],'skirt (f.)',5),
    (v_l3,'multiple_choice','What does "¿Qué llevas?" mean?','What are you wearing?',array['What do you have?','Where do you go?','How are you?'],'What are you wearing?',1),
    (v_l3,'multiple_choice','What does "Me pongo la chaqueta" mean?','I put on the jacket',array['I take off the jacket','I want a jacket','I have a jacket'],'I put on the jacket',2),
    (v_l3,'multiple_choice','What does "Mis zapatos son nuevos" mean?','My shoes are new',array['I buy new shoes','My shoes are old','I want shoes'],'My shoes are new',3),
    (v_l3,'multiple_choice','What does "Me gusta tu camisa" mean?','I like your shirt',array['I want a shirt','You have a shirt','My shirt is here'],'I like your shirt',4),
    (v_l3,'multiple_choice','What does "Hace frío, llevo abrigo" mean?','It is cold, I wear a coat',array['I have a cold coat','My coat is cold','It is cold without a coat'],'It is cold, I wear a coat',5),
    (v_l4,'listening','Listen and pick the English meaning.','Llevo una camisa azul',array['I want a blue shirt','I am wearing a blue shirt','I see a blue shirt'],'I am wearing a blue shirt',1),
    (v_l4,'listening','Listen and pick the English meaning.','Mis pantalones son negros',array['My shoes are black','My pants are black','I want black pants'],'My pants are black',2),
    (v_l4,'listening','Listen and pick the English meaning.','Me pongo los zapatos',array['I take off shoes','I put on the shoes','I buy shoes'],'I put on the shoes',3),
    (v_l4,'listening','Listen and pick the English meaning.','¿Qué talla?',array['What price?','What color?','What size?'],'What size?',4),
    (v_l4,'listening','Listen and pick the English meaning.','El sombrero es rojo',array['The hat is red','The hat is mine','I have a hat'],'The hat is red',5),
    (v_l5,'speaking','Say this aloud: "Llevo una camisa blanca." [YEH-boh OO-nah kah-MEE-sah BLAHN-kah]','Llevo una camisa blanca',array[]::text[],'I am wearing a white shirt.',1),
    (v_l5,'speaking','Say this aloud: "Me pongo los zapatos." [meh POHN-goh lohs sah-PAH-tohs]','Me pongo los zapatos',array[]::text[],'I put on the shoes.',2),
    (v_l5,'speaking','Say this aloud: "Mis pantalones son nuevos." [mees pahn-tah-LOH-nehs sohn NWEH-bohs]','Mis pantalones son nuevos',array[]::text[],'My trousers are new.',3),
    (v_l5,'speaking','Say this aloud: "Hace frío, llevo abrigo." [AH-seh FREE-oh YEH-boh ah-BREE-goh]','Hace frío, llevo abrigo',array[]::text[],'It is cold, I wear a coat.',4),
    (v_l5,'speaking','Say this aloud: "¿Qué talla tiene?" [keh TAH-yah TYEH-neh]','¿Qué talla tiene?',array[]::text[],'What size do you have?',5),
    (v_l6,'multiple_choice','What color is the shirt?','White',array['Black','Blue','Red'],'camisa blanca',1),
    (v_l6,'multiple_choice','What color are the trousers?','Black',array['White','Blue','Brown'],'pantalones negros',2),
    (v_l6,'multiple_choice','How are the shoes described?','New',array['Old','Big','Brown'],'mis zapatos son nuevos',3),
    (v_l6,'multiple_choice','Why does the speaker wear a jacket?','Because it is cold',array['Because it is hot','Because it is raining','For fashion'],'hace frío, así que también llevo una chaqueta',4),
    (v_l6,'multiple_choice','What color is the hat?','Red',array['Black','Blue','White'],'sombrero es rojo',5),
    (v_l7,'fill_blank','Translate to Spanish: "I am wearing a white shirt."','Llevo una camisa blanca',array['Pongo una camisa blanca','Llevo un camisa blanca','Estoy una camisa blanca'],'I am wearing a white shirt',1),
    (v_l7,'fill_blank','Translate to Spanish: "My shoes are new."','Mis zapatos son nuevos',array['Mis zapatos están nuevos','Mi zapatos son nuevos','Mis zapatos es nuevos'],'My shoes are new',2),
    (v_l7,'fill_blank','Translate to Spanish: "I put on the jacket."','Me pongo la chaqueta',array['Me pone la chaqueta','Yo pongo la chaqueta','Pongo me la chaqueta'],'I put on the jacket',3),
    (v_l7,'fill_blank','Translate to Spanish: "I like your hat."','Me gusta tu sombrero',array['Yo gusta tu sombrero','Me gusta tu sombreros','Me gustan tu sombrero'],'I like your hat',4),
    (v_l7,'fill_blank','Translate to Spanish: "What size?"','¿Qué talla?',array['¿Cuál tamaño?','¿Qué precio?','¿Qué número?'],'What size?',5);

  -- ============== A1.12 HOUSE & HOME ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'House & Home';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'Mi casa es grande. Tiene cuatro habitaciones, una cocina y dos baños. La sala está en el primer piso. Vivo aquí con mi familia. Me gusta mucho mi casa.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','What is "house" in Spanish?','casa',array['cama','cara','calle'],'House [KAH-sah]',1),
    (v_l1,'multiple_choice','What is "kitchen" in Spanish?','cocina',array['cocinar','cama','baño'],'Kitchen [koh-SEE-nah]',2),
    (v_l1,'multiple_choice','What is "bathroom" in Spanish?','baño',array['banco','bañar','baile'],'Bathroom [BAH-nyoh]',3),
    (v_l1,'multiple_choice','What is "bedroom" in Spanish?','dormitorio',array['dormir','día','sala'],'Bedroom [dohr-mee-TOH-ryoh]',4),
    (v_l1,'multiple_choice','What is "living room" in Spanish?','sala',array['sal','silla','calle'],'Living room [SAH-lah]',5),
    (v_l2,'fill_blank','Complete: "___ tres habitaciones." (There are 3 rooms.)','Hay',array['Es','Son','Está'],'There are (hay)',1),
    (v_l2,'fill_blank','Complete: "Vivo ___ una casa." (I live in a house.)','en',array['a','de','con'],'in',2),
    (v_l2,'fill_blank','Complete: "La cocina ___ grande." (The kitchen is big.)','es',array['está','tiene','son'],'is (ser, trait)',3),
    (v_l2,'fill_blank','Complete: "Mi casa ___ cuatro habitaciones." (has 4 rooms)','tiene',array['es','está','hay'],'has',4),
    (v_l2,'fill_blank','Complete: "El baño está ___ el dormitorio." (next to the bedroom)','al lado de',array['debajo de','encima de','a'],'next to',5),
    (v_l3,'multiple_choice','What does "¿Dónde vives?" mean?','Where do you live?',array['Where are you?','Where do you go?','How do you live?'],'Where do you live?',1),
    (v_l3,'multiple_choice','What does "Mi casa es grande" mean?','My house is big',array['My house is small','I want a big house','I have a house'],'My house is big',2),
    (v_l3,'multiple_choice','What does "Tengo tres habitaciones" mean?','I have 3 rooms',array['I have 3 houses','3 doors','3 friends'],'I have 3 rooms',3),
    (v_l3,'multiple_choice','What does "La cocina está aquí" mean?','The kitchen is here',array['I cook here','The kitchen is big','I am in the kitchen'],'The kitchen is here',4),
    (v_l3,'multiple_choice','What does "Bienvenido a mi casa" mean?','Welcome to my house',array['I am at home','I love my house','See my house'],'Welcome to my house',5),
    (v_l4,'listening','Listen and pick the English meaning.','Mi casa es pequeña',array['I have a small house','My house is big','My house is small'],'My house is small',1),
    (v_l4,'listening','Listen and pick the English meaning.','Hay dos baños',array['I have 2 bathrooms','There are 2 bathrooms','I want 2 bathrooms'],'There are 2 bathrooms',2),
    (v_l4,'listening','Listen and pick the English meaning.','La cocina está ahí',array['The kitchen is here','The kitchen is there','I cook there'],'The kitchen is there',3),
    (v_l4,'listening','Listen and pick the English meaning.','Vivo en un apartamento',array['I live in a house','I live in an apartment','My apartment is big'],'I live in an apartment',4),
    (v_l4,'listening','Listen and pick the English meaning.','Mi dormitorio es azul',array['My bedroom is blue','My bedroom is small','I love my bedroom'],'My bedroom is blue',5),
    (v_l5,'speaking','Say this aloud: "Mi casa es grande." [mee KAH-sah ehs GRAHN-deh]','Mi casa es grande',array[]::text[],'My house is big.',1),
    (v_l5,'speaking','Say this aloud: "Vivo en Madrid." [BEE-boh ehn mah-DREED]','Vivo en Madrid',array[]::text[],'I live in Madrid.',2),
    (v_l5,'speaking','Say this aloud: "Tengo tres habitaciones." [TEHN-goh trehs ah-bee-tah-SYOH-nehs]','Tengo tres habitaciones',array[]::text[],'I have 3 rooms.',3),
    (v_l5,'speaking','Say this aloud: "La cocina es nueva." [lah koh-SEE-nah ehs NWEH-bah]','La cocina es nueva',array[]::text[],'The kitchen is new.',4),
    (v_l5,'speaking','Say this aloud: "Bienvenido a mi casa." [byehn-beh-NEE-doh ah mee KAH-sah]','Bienvenido a mi casa',array[]::text[],'Welcome to my house.',5),
    (v_l6,'multiple_choice','Is the house big or small?','Big',array['Small','Medium','Tiny'],'mi casa es grande',1),
    (v_l6,'multiple_choice','How many rooms does it have?','Four',array['Three','Two','Five'],'cuatro habitaciones',2),
    (v_l6,'multiple_choice','How many bathrooms?','Two',array['One','Three','Four'],'dos baños',3),
    (v_l6,'multiple_choice','Where is the living room?','First floor',array['Second floor','Ground floor','Basement'],'sala está en el primer piso',4),
    (v_l6,'multiple_choice','Who does the speaker live with?','Family',array['Alone','Friends','Parents only'],'vivo aquí con mi familia',5),
    (v_l7,'fill_blank','Translate to Spanish: "My house is big."','Mi casa es grande',array['Mi casa está grande','Mi casas es grande','Mi casa son grande'],'My house is big',1),
    (v_l7,'fill_blank','Translate to Spanish: "I live in Madrid."','Vivo en Madrid',array['Vivo a Madrid','Vivo de Madrid','Yo vive en Madrid'],'I live in Madrid',2),
    (v_l7,'fill_blank','Translate to Spanish: "There are 3 rooms."','Hay tres habitaciones',array['Tengo tres habitaciones (also OK)','Son tres habitaciones','Es tres habitaciones'],'There are 3 rooms',3),
    (v_l7,'fill_blank','Translate to Spanish: "The kitchen is new."','La cocina es nueva',array['La cocina está nueva','La cocina son nueva','El cocina es nuevo'],'The kitchen is new',4),
    (v_l7,'fill_blank','Translate to Spanish: "Welcome to my house."','Bienvenido a mi casa',array['Bienvenida mi casa','Bienvenido en mi casa','Bienvenido mi casa'],'Welcome to my house (m.)',5);

  -- ============== A1.13 TRANSPORT ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Transport';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'Cada día voy al trabajo en autobús. El viaje dura veinte minutos. Mi hermano va en coche. Mi padre prefiere ir en bicicleta. Nunca tomo el avión.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','What is "car" in Spanish (Spain)?','coche',array['carro (LatAm)','cocho','cosa'],'Car (Spain) [KOH-cheh]',1),
    (v_l1,'multiple_choice','What is "bus" in Spanish?','autobús',array['avión','auto','automóvil'],'Bus [ow-toh-BOOS]',2),
    (v_l1,'multiple_choice','What is "train" in Spanish?','tren',array['tranvía','tres','tarde'],'Train [TREHN]',3),
    (v_l1,'multiple_choice','What is "plane" in Spanish?','avión',array['aire','avenida','aeropuerto'],'Plane [ah-BYOHN]',4),
    (v_l1,'multiple_choice','What is "bicycle" in Spanish?','bicicleta',array['biblioteca','botella','bici (short)'],'Bicycle [bee-see-KLEH-tah]',5),
    (v_l2,'fill_blank','Complete: "Voy ___ autobús." (by bus)','en',array['a','de','con'],'by (in)',1),
    (v_l2,'fill_blank','Complete: "Voy ___ trabajo." (to work)','al',array['a la','en','de'],'to the (a + el)',2),
    (v_l2,'fill_blank','Complete: "Tomo el ___" (I take the train.)','tren',array['trenes','trena','treno'],'train',3),
    (v_l2,'fill_blank','Complete: "Mi padre ___ en coche." (goes by car)','va',array['voy','vamos','van'],'goes (3rd sg)',4),
    (v_l2,'fill_blank','Complete: "El viaje ___ veinte minutos." (takes / lasts)','dura',array['duran','durar','duré'],'lasts (durar)',5),
    (v_l3,'multiple_choice','What does "¿Cómo vas al trabajo?" mean?','How do you go to work?',array['Where do you work?','When do you work?','Why do you work?'],'How do you go to work?',1),
    (v_l3,'multiple_choice','What does "Voy en bicicleta" mean?','I go by bicycle',array['I see a bicycle','I have a bicycle','I want a bicycle'],'I go by bicycle',2),
    (v_l3,'multiple_choice','What does "El tren está atrasado" mean?','The train is late',array['The train is here','I miss the train','The train is mine'],'The train is late',3),
    (v_l3,'multiple_choice','What does "Tomo el avión a Madrid" mean?','I take the plane to Madrid',array['I see a plane in Madrid','I live in Madrid','Madrid has planes'],'I take the plane to Madrid',4),
    (v_l3,'multiple_choice','What does "Necesito un taxi" mean?','I need a taxi',array['I see a taxi','I drive a taxi','I want a taxi'],'I need a taxi',5),
    (v_l4,'listening','Listen and pick the English meaning.','Voy en autobús',array['I take a taxi','I go by bus','I see a bus'],'I go by bus',1),
    (v_l4,'listening','Listen and pick the English meaning.','El tren sale a las ocho',array['The train arrives at 8','The train leaves at 8','The train costs 8'],'The train leaves at 8',2),
    (v_l4,'listening','Listen and pick the English meaning.','Mi coche es nuevo',array['I want a car','My car is new','My car is old'],'My car is new',3),
    (v_l4,'listening','Listen and pick the English meaning.','¿Dónde está el metro?',array['Where is the metro?','Where is my house?','Where do you live?'],'Where is the metro?',4),
    (v_l4,'listening','Listen and pick the English meaning.','Voy a pie',array['I go by bike','I go on foot','I go by car'],'I go on foot',5),
    (v_l5,'speaking','Say this aloud: "Voy al trabajo en autobús." [BOY ahl trah-BAH-hoh ehn ow-toh-BOOS]','Voy al trabajo en autobús',array[]::text[],'I go to work by bus.',1),
    (v_l5,'speaking','Say this aloud: "Tomo el tren." [TOH-moh ehl TREHN]','Tomo el tren',array[]::text[],'I take the train.',2),
    (v_l5,'speaking','Say this aloud: "Necesito un taxi." [neh-seh-SEE-toh oon TAHK-see]','Necesito un taxi',array[]::text[],'I need a taxi.',3),
    (v_l5,'speaking','Say this aloud: "Mi coche es rojo." [mee KOH-cheh ehs ROH-hoh]','Mi coche es rojo',array[]::text[],'My car is red.',4),
    (v_l5,'speaking','Say this aloud: "Voy en bicicleta." [BOY ehn bee-see-KLEH-tah]','Voy en bicicleta',array[]::text[],'I go by bicycle.',5),
    (v_l6,'multiple_choice','How does the speaker go to work?','By bus',array['By car','By bicycle','By plane'],'voy al trabajo en autobús',1),
    (v_l6,'multiple_choice','How long does the trip take?','20 minutes',array['10 minutes','30 minutes','an hour'],'el viaje dura veinte minutos',2),
    (v_l6,'multiple_choice','How does the brother get around?','By car',array['By bus','By bicycle','On foot'],'mi hermano va en coche',3),
    (v_l6,'multiple_choice','How does the father prefer to go?','By bicycle',array['By bus','By car','By train'],'mi padre prefiere ir en bicicleta',4),
    (v_l6,'multiple_choice','Does the speaker ever take a plane?','No',array['Yes, always','Sometimes','Yes, every week'],'nunca tomo el avión',5),
    (v_l7,'fill_blank','Translate to Spanish: "I go by bus."','Voy en autobús',array['Voy con autobús','Voy a autobús','Yo va en autobús'],'I go by bus',1),
    (v_l7,'fill_blank','Translate to Spanish: "I take the train."','Tomo el tren',array['Cojo el tren (also OK in Spain)','Tomo un tren (also OK)','Toma el tren'],'I take the train',2),
    (v_l7,'fill_blank','Translate to Spanish: "I need a taxi."','Necesito un taxi',array['Necesito el taxi','Quiero un taxi (also OK)','Tengo un taxi'],'I need a taxi',3),
    (v_l7,'fill_blank','Translate to Spanish: "My car is red."','Mi coche es rojo',array['Mi coche está rojo','Mi carro es rojo (LatAm)','Mi coche son rojo'],'My car is red',4),
    (v_l7,'fill_blank','Translate to Spanish: "I go on foot."','Voy a pie',array['Voy en pie','Voy con pie','Voy por pie'],'I go on foot',5);

  -- ============== A1.14 DAYS & MONTHS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Days & Months';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'Mi cumpleaños es en mayo. El sábado voy al cine con mis amigos. El domingo descanso en casa. Mi día favorito es el viernes. Diciembre es muy frío.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','What is "Monday" in Spanish?','lunes',array['martes','luna','lunar'],'Monday [LOO-nehs]',1),
    (v_l1,'multiple_choice','What is "Friday" in Spanish?','viernes',array['jueves','viejo','víspera'],'Friday [BYEHR-nehs]',2),
    (v_l1,'multiple_choice','What is "Sunday" in Spanish?','domingo',array['sábado','dominio','dormir'],'Sunday [doh-MEEN-goh]',3),
    (v_l1,'multiple_choice','What is "January" in Spanish?','enero',array['junio','energía','año'],'January [eh-NEH-roh]',4),
    (v_l1,'multiple_choice','What is "May" in Spanish?','mayo',array['marzo','mayor','marrón'],'May [MAH-yoh]',5),
    (v_l2,'fill_blank','Complete: "Hoy ___ jueves." (Today is Thursday.)','es',array['está','son','tiene'],'is (ser, day)',1),
    (v_l2,'fill_blank','Complete: "Mi cumpleaños es ___ junio." (in June)','en',array['a','de','para'],'in (month)',2),
    (v_l2,'fill_blank','Complete: "___ sábado voy al cine." (On Saturday I go)','El',array['En','A','De'],'(On + day = el + day)',3),
    (v_l2,'fill_blank','Complete: "Los ___ trabajo." (On Mondays I work.)','lunes',array['lunas','luneso','luns'],'Mondays (lunes is invariable)',4),
    (v_l2,'fill_blank','Complete: "Diciembre es muy ___" (very cold)','frío',array['fría','frío de','calor'],'cold (m.)',5),
    (v_l3,'multiple_choice','What does "¿Qué día es hoy?" mean?','What day is it today?',array['What time is it?','How are you today?','What is today like?'],'What day is it today?',1),
    (v_l3,'multiple_choice','What does "Mi cumpleaños es en mayo" mean?','My birthday is in May',array['I was born in May','My birthday party','Today is May'],'My birthday is in May',2),
    (v_l3,'multiple_choice','What does "El sábado voy al parque" mean?','On Saturday I go to the park',array['I love Saturdays','Saturday is here','I am at the park'],'On Saturday I go to the park',3),
    (v_l3,'multiple_choice','What does "Hoy es martes" mean?','Today is Tuesday',array['Yesterday was Tuesday','Tomorrow is Tuesday','I love Tuesdays'],'Today is Tuesday',4),
    (v_l3,'multiple_choice','What does "El mes de julio" mean?','The month of July',array['I love July','In July','July is hot'],'The month of July',5),
    (v_l4,'listening','Listen and pick the English meaning.','Hoy es viernes',array['Yesterday was Friday','Today is Friday','Tomorrow is Friday'],'Today is Friday',1),
    (v_l4,'listening','Listen and pick the English meaning.','Mi cumpleaños es en agosto',array['I was born in August','My birthday is in August','August is hot'],'My birthday is in August',2),
    (v_l4,'listening','Listen and pick the English meaning.','El lunes voy al médico',array['I went to the doctor Monday','On Monday I go to the doctor','I love Mondays'],'On Monday I go to the doctor',3),
    (v_l4,'listening','Listen and pick the English meaning.','Diciembre es frío',array['December is cold','December is hot','I love December'],'December is cold',4),
    (v_l4,'listening','Listen and pick the English meaning.','Los domingos descanso',array['I work on Sundays','On Sundays I rest','I love Sundays'],'On Sundays I rest',5),
    (v_l5,'speaking','Say this aloud: "Hoy es lunes." [oy ehs LOO-nehs]','Hoy es lunes',array[]::text[],'Today is Monday.',1),
    (v_l5,'speaking','Say this aloud: "Mi cumpleaños es en mayo." [mee koom-pleh-AH-nyohs ehs ehn MAH-yoh]','Mi cumpleaños es en mayo',array[]::text[],'My birthday is in May.',2),
    (v_l5,'speaking','Say this aloud: "El sábado voy al cine." [ehl SAH-bah-doh BOY ahl SEE-neh]','El sábado voy al cine',array[]::text[],'On Saturday I go to the cinema.',3),
    (v_l5,'speaking','Say this aloud: "Los domingos descanso." [lohs doh-MEEN-gohs dehs-KAHN-soh]','Los domingos descanso',array[]::text[],'On Sundays I rest.',4),
    (v_l5,'speaking','Say this aloud: "Diciembre es frío." [dee-SYEHM-breh ehs FREE-oh]','Diciembre es frío',array[]::text[],'December is cold.',5),
    (v_l6,'multiple_choice','When is the speakers birthday?','In May',array['In June','In July','In March'],'mi cumpleaños es en mayo',1),
    (v_l6,'multiple_choice','What does the speaker do on Saturday?','Goes to the cinema',array['Goes to the park','Rests at home','Works'],'el sábado voy al cine',2),
    (v_l6,'multiple_choice','What does the speaker do on Sunday?','Rests at home',array['Goes shopping','Goes to school','Visits family'],'el domingo descanso en casa',3),
    (v_l6,'multiple_choice','What is the speakers favorite day?','Friday',array['Monday','Saturday','Sunday'],'mi día favorito es el viernes',4),
    (v_l6,'multiple_choice','What month is very cold?','December',array['August','March','May'],'diciembre es muy frío',5),
    (v_l7,'fill_blank','Translate to Spanish: "Today is Monday."','Hoy es lunes',array['Hoy está lunes','Hoy son lunes','Hoy lunes'],'Today is Monday',1),
    (v_l7,'fill_blank','Translate to Spanish: "My birthday is in May."','Mi cumpleaños es en mayo',array['Mi cumpleaños está en mayo','Mi cumpleaños es a mayo','Mi cumpleaños en mayo es'],'My birthday is in May',2),
    (v_l7,'fill_blank','Translate to Spanish: "On Saturday I go shopping."','El sábado voy de compras',array['En sábado voy de compras','El sábado voy a compras','El sábado yo compras'],'On Saturday I go shopping',3),
    (v_l7,'fill_blank','Translate to Spanish: "On Sundays I rest."','Los domingos descanso',array['En domingos descanso','El domingo descanso (single Sun.)','Los domingos descansamos'],'On Sundays I rest (habitual)',4),
    (v_l7,'fill_blank','Translate to Spanish: "December is cold."','Diciembre es frío',array['Diciembre está frío','Diciembre hace frío (also OK)','Diciembre son frío'],'December is cold',5);

  -- ============== A1.15 BASIC VERBS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Basic Verbs';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;
  update public.lessons set description = E'Yo soy estudiante. Tengo veinte años. Vivo en Madrid con mi familia. Estudio español todos los días. Voy a la universidad por la mañana.' where id = v_l6;
  update public.lessons set title = v_podcast_title, description = v_podcast_desc where id = v_l8;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l4,v_l5,v_l6,v_l7);
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'multiple_choice','What is "to be" (permanent) in Spanish?','ser',array['estar','tener','ir'],'To be (essence) [SEHR]',1),
    (v_l1,'multiple_choice','What is "to be" (state/location) in Spanish?','estar',array['ser','tener','ir'],'To be (state) [ehs-TAHR]',2),
    (v_l1,'multiple_choice','What is "to have" in Spanish?','tener',array['haber','tomar','tirar'],'To have [teh-NEHR]',3),
    (v_l1,'multiple_choice','What is "to go" in Spanish?','ir',array['ser','venir','irse'],'To go [EER]',4),
    (v_l1,'multiple_choice','What is "to do / make" in Spanish?','hacer',array['hablar','ir','haber'],'To do / make [ah-SEHR]',5),
    (v_l2,'fill_blank','Complete: "Yo ___ estudiante." (I am a student.)','soy',array['estoy','soy un (also OK)','es'],'I am (ser, profession)',1),
    (v_l2,'fill_blank','Complete: "Tú ___ en casa." (You are at home.)','estás',array['eres','tienes','vas'],'You are (estar, location)',2),
    (v_l2,'fill_blank','Complete: "Él ___ veinte años." (He is 20.)','tiene',array['es','está','va'],'He has (age = tener)',3),
    (v_l2,'fill_blank','Complete: "Nosotros ___ al cine." (We go to the cinema.)','vamos',array['van','voy','vais'],'we go',4),
    (v_l2,'fill_blank','Complete: "Yo ___ la tarea." (I do the homework.)','hago',array['hace','hacer','hagamos'],'I do',5),
    (v_l3,'multiple_choice','What does "Soy de España" mean?','I am from Spain',array['I love Spain','I see Spain','I have Spain'],'I am from Spain',1),
    (v_l3,'multiple_choice','What does "Estoy cansado" mean?','I am tired',array['I am a tired person','I see tired people','I rest'],'I am tired',2),
    (v_l3,'multiple_choice','What does "Tengo hambre" mean?','I am hungry',array['I have a stomach','I want food','I eat'],'I am hungry',3),
    (v_l3,'multiple_choice','What does "Voy al trabajo" mean?','I go to work',array['I am at work','I want work','I love work'],'I go to work',4),
    (v_l3,'multiple_choice','What does "Hago la cena" mean?','I make dinner',array['I have dinner','I want dinner','I eat dinner'],'I make dinner',5),
    (v_l4,'listening','Listen and pick the English meaning.','Soy profesor',array['I am a doctor','I am a teacher','I want to teach'],'I am a teacher',1),
    (v_l4,'listening','Listen and pick the English meaning.','Estoy en casa',array['I am at school','I am at home','I am tired'],'I am at home',2),
    (v_l4,'listening','Listen and pick the English meaning.','Tengo un perro',array['I have a cat','I have a dog','I want a dog'],'I have a dog',3),
    (v_l4,'listening','Listen and pick the English meaning.','Voy al cine',array['I go to the cinema','I am at the cinema','I love the cinema'],'I go to the cinema',4),
    (v_l4,'listening','Listen and pick the English meaning.','Hago ejercicio',array['I do exercise','I want exercise','I am tired'],'I do exercise',5),
    (v_l5,'speaking','Say this aloud: "Yo soy estudiante." [yoh soy ehs-too-DYAHN-teh]','Yo soy estudiante',array[]::text[],'I am a student.',1),
    (v_l5,'speaking','Say this aloud: "Estoy bien." [ehs-TOY BYEHN]','Estoy bien',array[]::text[],'I am fine.',2),
    (v_l5,'speaking','Say this aloud: "Tengo un coche." [TEHN-goh oon KOH-cheh]','Tengo un coche',array[]::text[],'I have a car.',3),
    (v_l5,'speaking','Say this aloud: "Voy al supermercado." [BOY ahl soo-pehr-mehr-KAH-doh]','Voy al supermercado',array[]::text[],'I go to the supermarket.',4),
    (v_l5,'speaking','Say this aloud: "Hago la tarea." [AH-goh lah tah-REH-ah]','Hago la tarea',array[]::text[],'I do the homework.',5),
    (v_l6,'multiple_choice','What is the speakers occupation?','Student',array['Teacher','Doctor','Engineer'],'soy estudiante',1),
    (v_l6,'multiple_choice','How old is the speaker?','20',array['12','22','30'],'tengo veinte años',2),
    (v_l6,'multiple_choice','Where does the speaker live?','Madrid',array['Barcelona','Sevilla','Valencia'],'vivo en Madrid',3),
    (v_l6,'multiple_choice','What does the speaker do every day?','Studies Spanish',array['Goes to work','Plays sports','Watches TV'],'estudio español todos los días',4),
    (v_l6,'multiple_choice','When does the speaker go to university?','In the morning',array['In the afternoon','At night','Never'],'voy a la universidad por la mañana',5),
    (v_l7,'fill_blank','Translate to Spanish: "I am a student."','Soy estudiante',array['Estoy estudiante','Yo soy un estudiante (also OK)','Soy un estudiante (also OK)'],'I am a student',1),
    (v_l7,'fill_blank','Translate to Spanish: "I am tired."','Estoy cansado',array['Soy cansado','Tengo cansado','Estar cansado'],'I am tired (estar)',2),
    (v_l7,'fill_blank','Translate to Spanish: "I have a brother."','Tengo un hermano',array['Yo hermano','Tengo el hermano','Soy un hermano'],'I have a brother',3),
    (v_l7,'fill_blank','Translate to Spanish: "I go to school."','Voy a la escuela',array['Voy a escuela','Yo va a la escuela','Voy en la escuela'],'I go to school',4),
    (v_l7,'fill_blank','Translate to Spanish: "I do my homework."','Hago la tarea',array['Hago el tarea','Yo hace la tarea','Hago los deberes (Spain — also OK)'],'I do my homework',5);

end $$;

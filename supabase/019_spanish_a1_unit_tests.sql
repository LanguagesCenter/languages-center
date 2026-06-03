-- 019_spanish_a1_unit_tests.sql
-- Adds a Section Test (unit test) after the last lesson of every Spanish A1 section.
--
-- Schema: extends lessons.type to allow 'unit_test'.
-- Content: per section creates a new lesson at order_index = 9 with
--   type='unit_test', title='Section Test: <section>', xp_reward=50,
--   plus 10 exercises (mix of multiple_choice, fill_blank, listening,
--   speaking) that review the whole section.
-- LessonClient will render type='unit_test' lessons with a pass/fail
-- summary (>=7 correct = passed) and a retake button.

alter table public.lessons drop constraint if exists lessons_type_check;
alter table public.lessons
  add constraint lessons_type_check
  check (type in ('vocabulary','grammar','phrases','listening','speaking','reading','writing','podcast','unit_test'));

do $$
declare
  v_lang_id    bigint;
  v_course_id  bigint;
  v_lesson_id  bigint;
  v_section    text;
begin
  select id into v_lang_id from public.languages where code = 'spanish';

  for v_section in
    select title from public.courses
    where language_id = v_lang_id and cefr_level = 'A1'
    order by order_index
  loop
    select id into v_course_id from public.courses
      where language_id = v_lang_id and cefr_level = 'A1' and title = v_section;

    -- Idempotent: drop the existing test lesson (cascades to its exercises).
    delete from public.lessons where course_id = v_course_id and order_index = 9;

    insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
    values (
      v_course_id,
      'Section Test: ' || v_section,
      'Review test for the whole ' || v_section || ' section. Pass with 7 or more out of 10 to earn 50 XP.',
      'unit_test',
      9,
      50
    )
    returning id into v_lesson_id;

    -- 10 exercises per test, content is section-specific below.
    if v_section = 'Greetings' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','How do you say "Hello"?','Hola',array['Adiós','Gracias','Sí'],'Hello',1),
        (v_lesson_id,'multiple_choice','How do you say "Good morning"?','Buenos días',array['Buenas noches','Buenas tardes','Hasta luego'],'Good morning',2),
        (v_lesson_id,'multiple_choice','What does "Mucho gusto" mean?','Pleased to meet you',array['Thank you','See you later','Where are you from?'],'Pleased to meet you',3),
        (v_lesson_id,'multiple_choice','Which is the formal "you"?','usted',array['tú','vosotros','yo'],'usted',4),
        (v_lesson_id,'fill_blank','Complete: "Me ___ Ana." (My name is Ana.)','llamo',array['llamas','llama','llaman'],'I call myself',5),
        (v_lesson_id,'fill_blank','Complete: "Soy ___ España." (I am from Spain.)','de',array['en','con','a'],'from',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Hasta luego',array['Hello','Pleased to meet you','How are you?'],'See you later',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','¿De dónde eres?',array['What is your name?','Where are you from?','How are you?'],'Where are you from?',8),
        (v_lesson_id,'speaking','Say this aloud: "Mucho gusto." [MOO-choh GOOS-toh]','Mucho gusto',array[]::text[],'Pleased to meet you.',9),
        (v_lesson_id,'speaking','Say this aloud: "Soy de México." [SOY deh MEH-hee-koh]','Soy de México',array[]::text[],'I am from Mexico.',10);

    elsif v_section = 'Numbers' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "five"?','cinco',array['quince','cien','cincuenta'],'five',1),
        (v_lesson_id,'multiple_choice','What is "twenty"?','veinte',array['doce','dos','diez'],'twenty',2),
        (v_lesson_id,'multiple_choice','What is "one hundred"?','cien',array['mil','ciento','uno'],'one hundred',3),
        (v_lesson_id,'multiple_choice','Translate "Tengo veinte años."','I am 20 years old',array['I have 20 brothers','I count to 20','I bought 20'],'I am 20 years old',4),
        (v_lesson_id,'fill_blank','Complete: "Tengo ___ años." (5 years)','cinco',array['cinca','quince','cinco años'],'five',5),
        (v_lesson_id,'fill_blank','Complete: "Son las ___" (3 o''clock)','tres',array['tre','trece','treinta'],'three',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','diez',array['twelve','two','ten'],'ten',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','¿Cuánto cuesta?',array['What is your age?','How much does it cost?','What time?'],'How much does it cost?',8),
        (v_lesson_id,'speaking','Say this aloud: "Tengo veinte años." [TEHN-goh BEHN-teh AH-nyohs]','Tengo veinte años',array[]::text[],'I am 20.',9),
        (v_lesson_id,'speaking','Say this aloud: "Son las cinco." [sohn lahs SEEN-koh]','Son las cinco',array[]::text[],'It is 5 o''clock.',10);

    elsif v_section = 'Colors' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "red"?','rojo',array['azul','verde','negro'],'red',1),
        (v_lesson_id,'multiple_choice','What is "white"?','blanco',array['negro','gris','marrón'],'white',2),
        (v_lesson_id,'multiple_choice','Translate "El cielo es azul."','The sky is blue',array['I want a blue sky','My eyes are blue','The sky is gray'],'The sky is blue',3),
        (v_lesson_id,'multiple_choice','Which color does NOT change for gender?','verde',array['rojo','blanco','negro'],'verde (invariable)',4),
        (v_lesson_id,'fill_blank','Complete: "La casa es ___" (white)','blanca',array['blanco','blancas','blancos'],'white (f.sg)',5),
        (v_lesson_id,'fill_blank','Complete: "Las flores son ___" (red)','rojas',array['rojo','rojos','roja'],'red (f.pl)',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','amarillo',array['orange','red','yellow'],'yellow',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Me gusta el azul',array['I like green','I like blue','I like red'],'I like blue',8),
        (v_lesson_id,'speaking','Say this aloud: "Mi coche es rojo." [mee KOH-cheh ehs ROH-hoh]','Mi coche es rojo',array[]::text[],'My car is red.',9),
        (v_lesson_id,'speaking','Say this aloud: "Las flores son amarillas." [lahs FLOH-rehs sohn ah-mah-REE-yahs]','Las flores son amarillas',array[]::text[],'The flowers are yellow.',10);

    elsif v_section = 'Family' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "mother"?','madre',array['padre','hermana','abuela'],'mother',1),
        (v_lesson_id,'multiple_choice','What is "brother"?','hermano',array['hijo','tío','primo'],'brother',2),
        (v_lesson_id,'multiple_choice','Translate "Mi familia es grande."','My family is big',array['I love my family','My family is here','My family is mine'],'My family is big',3),
        (v_lesson_id,'multiple_choice','What does "mis" mean?','my (plural)',array['my (sg)','your (sg)','his'],'my (plural)',4),
        (v_lesson_id,'fill_blank','Complete: "___ madre se llama Ana." (My)','Mi',array['Mí','Mis','Yo'],'My (sg)',5),
        (v_lesson_id,'fill_blank','Complete: "Tengo ___ hermana." (a sister)','una',array['un','la','el'],'a (f.)',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Mi madre se llama Carmen',array['My friend Carmen','I am called Carmen','My mother is called Carmen'],'My mother is called Carmen',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Tengo dos hermanos',array['I have two friends','I have two siblings','I am two'],'I have two siblings',8),
        (v_lesson_id,'speaking','Say this aloud: "Tengo un hermano y una hermana." [TEHN-goh oon ehr-MAH-noh ee OO-nah ehr-MAH-nah]','Tengo un hermano y una hermana',array[]::text[],'I have a brother and a sister.',9),
        (v_lesson_id,'speaking','Say this aloud: "Mi familia es pequeña." [mee fah-MEE-lyah ehs peh-KEH-nyah]','Mi familia es pequeña',array[]::text[],'My family is small.',10);

    elsif v_section = 'Food' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "bread"?','pan',array['queso','leche','agua'],'bread',1),
        (v_lesson_id,'multiple_choice','What is "water"?','agua',array['aceite','azúcar','aire'],'water',2),
        (v_lesson_id,'multiple_choice','What does "Tengo hambre" mean?','I am hungry',array['I am thirsty','I am tired','I have food'],'I am hungry',3),
        (v_lesson_id,'multiple_choice','What does "Buen provecho" mean?','Enjoy your meal',array['Good morning','Thank you','Good luck'],'Enjoy your meal',4),
        (v_lesson_id,'fill_blank','Complete: "Quiero ___ manzana." (an apple)','una',array['un','la','las'],'a (f.)',5),
        (v_lesson_id,'fill_blank','Complete: "Tengo ___" (I am thirsty.)','sed',array['hambre','sueño','frío'],'thirst',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Quiero un café',array['I have coffee','I want a coffee','I make coffee'],'I want a coffee',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','La cuenta, por favor',array['The card, please','The bill, please','The menu, please'],'The bill, please',8),
        (v_lesson_id,'speaking','Say this aloud: "Tengo hambre." [TEHN-goh AHM-breh]','Tengo hambre',array[]::text[],'I am hungry.',9),
        (v_lesson_id,'speaking','Say this aloud: "Me gusta el pan." [meh GOOS-tah ehl PAHN]','Me gusta el pan',array[]::text[],'I like bread.',10);

    elsif v_section = 'Time' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "hour"?','hora',array['día','año','semana'],'hour',1),
        (v_lesson_id,'multiple_choice','What does "¿Qué hora es?" mean?','What time is it?',array['What day is it?','How are you?','Where are you?'],'What time is it?',2),
        (v_lesson_id,'multiple_choice','How do you say "It is 1 o''clock"?','Es la una',array['Son las uno','Es uno','Son la una'],'It is 1',3),
        (v_lesson_id,'multiple_choice','What does "por la mañana" mean?','in the morning',array['tomorrow','in the afternoon','at noon'],'in the morning',4),
        (v_lesson_id,'fill_blank','Complete: "___ las tres." (It is 3.)','Son',array['Es','Está','Tiene'],'Are (plural)',5),
        (v_lesson_id,'fill_blank','Complete: "Tengo clase ___ las ocho." (at 8)','a',array['en','de','para'],'at (time)',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Son las cinco',array['It is 15','I have 5','It is 5 o''clock'],'It is 5 o''clock',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Hoy es lunes',array['Today is Monday','Yesterday was Monday','Tomorrow is Monday'],'Today is Monday',8),
        (v_lesson_id,'speaking','Say this aloud: "¿Qué hora es?" [keh OH-rah ehs]','¿Qué hora es?',array[]::text[],'What time is it?',9),
        (v_lesson_id,'speaking','Say this aloud: "Son las cinco." [sohn lahs SEEN-koh]','Son las cinco',array[]::text[],'It is 5 o''clock.',10);

    elsif v_section = 'Weather' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','How do you say "It is sunny"?','Hace sol',array['Es sol','Hay sol','Tiene sol'],'It is sunny',1),
        (v_lesson_id,'multiple_choice','What is "rain"?','lluvia',array['nieve','viento','calor'],'rain',2),
        (v_lesson_id,'multiple_choice','What does "Tengo frío" mean?','I am cold',array['It is cold','I have a cold','I am sick'],'I am cold (person)',3),
        (v_lesson_id,'multiple_choice','How do you say "It is cloudy"?','Está nublado',array['Hace nublado','Hay nublado','Es nublado'],'It is cloudy (estar+adj)',4),
        (v_lesson_id,'fill_blank','Complete: "___ sol hoy." (It is sunny)','Hace',array['Es','Está','Hay'],'(hacer + weather)',5),
        (v_lesson_id,'fill_blank','Complete: "Mañana va a ___" (rain)','llover',array['lluvia','llueve','llovía'],'to rain',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Hace mucho calor',array['It is very cold','It is very hot','I am hungry'],'It is very hot',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Llueve mucho',array['It is windy','It rains a lot','It is sunny'],'It rains a lot',8),
        (v_lesson_id,'speaking','Say this aloud: "Hoy hace sol." [oy AH-seh SOHL]','Hoy hace sol',array[]::text[],'Today it is sunny.',9),
        (v_lesson_id,'speaking','Say this aloud: "Tengo frío." [TEHN-goh FREE-oh]','Tengo frío',array[]::text[],'I am cold.',10);

    elsif v_section = 'Shopping' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "shop"?','tienda',array['precio','dinero','calle'],'shop',1),
        (v_lesson_id,'multiple_choice','What does "¿Cuánto cuesta?" mean?','How much does it cost?',array['What is it?','Where is it?','How are you?'],'How much does it cost?',2),
        (v_lesson_id,'multiple_choice','What is "cheap"?','barato',array['caro','barata','barril'],'cheap',3),
        (v_lesson_id,'multiple_choice','What does "Pago con tarjeta" mean?','I pay by card',array['I want a card','My card is here','I have a card'],'I pay by card',4),
        (v_lesson_id,'fill_blank','Complete: "Es muy ___" (expensive)','caro',array['barato','grande','poco'],'expensive',5),
        (v_lesson_id,'fill_blank','Complete: "Quiero ___ pan." (to buy)','comprar',array['vender','pagar','tener'],'to buy',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','¿Cuánto cuesta?',array['Where is it?','How much does it cost?','What is your name?'],'How much does it cost?',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Pago con tarjeta',array['I want a card','I pay by card','I have change'],'I pay by card',8),
        (v_lesson_id,'speaking','Say this aloud: "¿Cuánto cuesta?" [KWAHN-toh KWEHS-tah]','¿Cuánto cuesta?',array[]::text[],'How much is it?',9),
        (v_lesson_id,'speaking','Say this aloud: "Quiero comprar pan." [KYEH-roh kohm-PRAHR PAHN]','Quiero comprar pan',array[]::text[],'I want to buy bread.',10);

    elsif v_section = 'Animals' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "dog"?','perro',array['gato','pájaro','pez'],'dog',1),
        (v_lesson_id,'multiple_choice','What is "cat"?','gato',array['perro','pato','rato'],'cat',2),
        (v_lesson_id,'multiple_choice','What does "¿Tienes mascota?" mean?','Do you have a pet?',array['Are you a pet?','Do you like pets?','Where are pets?'],'Do you have a pet?',3),
        (v_lesson_id,'multiple_choice','What does "Me gustan los gatos" mean?','I like cats',array['I want cats','I have cats','I see cats'],'I like cats',4),
        (v_lesson_id,'fill_blank','Complete: "Tengo ___ perro." (a)','un',array['una','el','la'],'a (m.)',5),
        (v_lesson_id,'fill_blank','Complete: "Me ___ los pájaros." (I like)','gustan',array['gusta','gustamos','gustáis'],'I like (pl.)',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Mi perro es grande',array['My dog is small','My cat is big','My dog is big'],'My dog is big',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','No tengo mascota',array['I have a pet','I want a pet','I do not have a pet'],'I do not have a pet',8),
        (v_lesson_id,'speaking','Say this aloud: "Tengo un perro." [TEHN-goh oon PEH-rroh]','Tengo un perro',array[]::text[],'I have a dog.',9),
        (v_lesson_id,'speaking','Say this aloud: "Me gustan los gatos." [meh GOOS-tahn lohs GAH-tohs]','Me gustan los gatos',array[]::text[],'I like cats.',10);

    elsif v_section = 'Body Parts' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "head"?','cabeza',array['mano','pie','ojo'],'head',1),
        (v_lesson_id,'multiple_choice','What is "hand"?','mano',array['pie','brazo','dedo'],'hand',2),
        (v_lesson_id,'multiple_choice','What does "Me duele la cabeza" mean?','My head hurts',array['I love my head','My head is here','I have a head'],'My head hurts',3),
        (v_lesson_id,'multiple_choice','Which uses doler (singular)?','Me duele',array['Me duelen','Me dolor','Me duele los'],'singular hurts',4),
        (v_lesson_id,'fill_blank','Complete: "Me ___ los pies." (hurt)','duelen',array['duele','duela','dolor'],'hurt (plural)',5),
        (v_lesson_id,'fill_blank','Complete: "Tengo dos ___" (eyes)','ojos',array['ojo','oreja','ojas'],'eyes',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Me duele la cabeza',array['I am hungry','My head hurts','I want my head'],'My head hurts',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Necesito un médico',array['I see the doctor','I am the doctor','I need a doctor'],'I need a doctor',8),
        (v_lesson_id,'speaking','Say this aloud: "Me duele la espalda." [meh DWEH-leh lah ehs-PAHL-dah]','Me duele la espalda',array[]::text[],'My back hurts.',9),
        (v_lesson_id,'speaking','Say this aloud: "Tengo los ojos azules." [TEHN-goh lohs OH-hohs ah-SOO-lehs]','Tengo los ojos azules',array[]::text[],'I have blue eyes.',10);

    elsif v_section = 'Clothes' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "shirt"?','camisa',array['pantalones','zapatos','vestido'],'shirt',1),
        (v_lesson_id,'multiple_choice','What is "shoes"?','zapatos',array['sombrero','vestido','pantalones'],'shoes',2),
        (v_lesson_id,'multiple_choice','What does "Llevo una camisa" mean?','I am wearing a shirt',array['I want a shirt','I see a shirt','I sell a shirt'],'I am wearing a shirt',3),
        (v_lesson_id,'multiple_choice','What does "Me queda bien" mean?','It fits me well',array['I want it','It is mine','It is new'],'It fits me well',4),
        (v_lesson_id,'fill_blank','Complete: "Me ___ los zapatos." (I put on)','pongo',array['poner','pone','quito'],'I put on',5),
        (v_lesson_id,'fill_blank','Complete: "Mis zapatos ___ nuevos." (are)','son',array['es','están','están'],'are (ser, trait)',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Llevo una camisa blanca',array['I want a white shirt','I am wearing a white shirt','I see a white shirt'],'I am wearing a white shirt',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','¿Qué talla usas?',array['What is your name?','What size do you wear?','How are you?'],'What size do you wear?',8),
        (v_lesson_id,'speaking','Say this aloud: "Llevo zapatos negros." [YEH-boh sah-PAH-tohs NEH-grohs]','Llevo zapatos negros',array[]::text[],'I am wearing black shoes.',9),
        (v_lesson_id,'speaking','Say this aloud: "Me pongo la chaqueta." [meh POHN-goh lah chah-KEH-tah]','Me pongo la chaqueta',array[]::text[],'I put on the jacket.',10);

    elsif v_section = 'House & Home' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "house"?','casa',array['cama','calle','cara'],'house',1),
        (v_lesson_id,'multiple_choice','What is "kitchen"?','cocina',array['baño','sala','dormitorio'],'kitchen',2),
        (v_lesson_id,'multiple_choice','What does "Hay tres habitaciones" mean?','There are 3 rooms',array['I have 3 rooms','I want 3 rooms','3 rooms are mine'],'There are 3 rooms',3),
        (v_lesson_id,'multiple_choice','What does "Vivo en Madrid" mean?','I live in Madrid',array['I am in Madrid','I love Madrid','I go to Madrid'],'I live in Madrid',4),
        (v_lesson_id,'fill_blank','Complete: "Vivo ___ una casa." (in)','en',array['a','de','con'],'in',5),
        (v_lesson_id,'fill_blank','Complete: "Mi casa ___ cuatro habitaciones." (has)','tiene',array['es','está','hay'],'has',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Mi casa es grande',array['My house is small','My house is big','I want a big house'],'My house is big',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Vivo con mi familia',array['I live alone','I live with my family','I live with friends'],'I live with my family',8),
        (v_lesson_id,'speaking','Say this aloud: "Vivo en Madrid." [BEE-boh ehn mah-DREED]','Vivo en Madrid',array[]::text[],'I live in Madrid.',9),
        (v_lesson_id,'speaking','Say this aloud: "Hay tres habitaciones." [I trehs ah-bee-tah-SYOH-nehs]','Hay tres habitaciones',array[]::text[],'There are 3 rooms.',10);

    elsif v_section = 'Transport' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "car" (Spain)?','coche',array['carro','tren','autobús'],'car (Spain)',1),
        (v_lesson_id,'multiple_choice','What is "train"?','tren',array['avión','autobús','tranvía'],'train',2),
        (v_lesson_id,'multiple_choice','What does "Voy en autobús" mean?','I go by bus',array['I see a bus','I have a bus','I want a bus'],'I go by bus',3),
        (v_lesson_id,'multiple_choice','How do you say "round trip"?','ida y vuelta',array['ir y volver','dos viajes','de vuelta'],'round trip',4),
        (v_lesson_id,'fill_blank','Complete: "Voy ___ tren." (by)','en',array['a','de','con'],'by',5),
        (v_lesson_id,'fill_blank','Complete: "Un billete ___ Madrid." (to)','a',array['en','de','con'],'to',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Tomo el metro',array['I take the train','I take the metro','I see the metro'],'I take the metro',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','¿A qué hora sale?',array['Where does it go?','What time does it leave?','How much is it?'],'What time does it leave?',8),
        (v_lesson_id,'speaking','Say this aloud: "Voy al trabajo en autobús." [BOY ahl trah-BAH-hoh ehn ow-toh-BOOS]','Voy al trabajo en autobús',array[]::text[],'I go to work by bus.',9),
        (v_lesson_id,'speaking','Say this aloud: "Necesito un taxi." [neh-seh-SEE-toh oon TAHK-see]','Necesito un taxi',array[]::text[],'I need a taxi.',10);

    elsif v_section = 'Days & Months' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','What is "Monday"?','lunes',array['martes','luna','línea'],'Monday',1),
        (v_lesson_id,'multiple_choice','What is "January"?','enero',array['febrero','marzo','julio'],'January',2),
        (v_lesson_id,'multiple_choice','What does "Mi cumpleaños es en mayo" mean?','My birthday is in May',array['I love May','In May I am born','I see my birthday'],'My birthday is in May',3),
        (v_lesson_id,'multiple_choice','How do you say "on Saturday"?','el sábado',array['en sábado','de sábado','sábado de'],'on Saturday',4),
        (v_lesson_id,'fill_blank','Complete: "Hoy ___ jueves." (is)','es',array['está','son','tiene'],'is (ser, day)',5),
        (v_lesson_id,'fill_blank','Complete: "Mi cumpleaños es ___ junio." (in)','en',array['a','de','para'],'in (month)',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Hoy es viernes',array['Today is Friday','Today is Saturday','Today is Thursday'],'Today is Friday',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Diciembre es muy frío',array['December is very hot','December is very cold','December is very pretty'],'December is very cold',8),
        (v_lesson_id,'speaking','Say this aloud: "Hoy es lunes." [oy ehs LOO-nehs]','Hoy es lunes',array[]::text[],'Today is Monday.',9),
        (v_lesson_id,'speaking','Say this aloud: "Mi cumpleaños es en mayo." [mee koom-pleh-AH-nyohs ehs ehn MAH-yoh]','Mi cumpleaños es en mayo',array[]::text[],'My birthday is in May.',10);

    elsif v_section = 'Basic Verbs' then
      insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
        (v_lesson_id,'multiple_choice','Which verb is for permanent identity?','ser',array['estar','tener','ir'],'ser',1),
        (v_lesson_id,'multiple_choice','Which verb is for current state?','estar',array['ser','tener','ir'],'estar',2),
        (v_lesson_id,'multiple_choice','What does "Tengo hambre" mean?','I am hungry',array['I want food','I have food','I am tired'],'I am hungry',3),
        (v_lesson_id,'multiple_choice','Translate "Voy al trabajo."','I go to work',array['I am at work','I want work','I love work'],'I go to work',4),
        (v_lesson_id,'fill_blank','Complete: "Yo ___ estudiante." (I am)','soy',array['estoy','es','tengo'],'I am (ser)',5),
        (v_lesson_id,'fill_blank','Complete: "Él ___ veinte años." (has)','tiene',array['es','está','va'],'has (age)',6),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Estoy cansado',array['I am tired','I am hungry','I am a tired person'],'I am tired',7),
        (v_lesson_id,'listening','Listen and pick the English meaning.','Hago ejercicio',array['I have exercise','I do exercise','I want exercise'],'I do exercise',8),
        (v_lesson_id,'speaking','Say this aloud: "Soy de España." [SOY deh ehs-PAH-nyah]','Soy de España',array[]::text[],'I am from Spain.',9),
        (v_lesson_id,'speaking','Say this aloud: "Voy a la escuela." [BOY ah lah ehs-KWEH-lah]','Voy a la escuela',array[]::text[],'I go to school.',10);
    end if;
  end loop;
end $$;

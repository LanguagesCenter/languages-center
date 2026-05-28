-- 010_spanish_a1_real_content.sql
-- Real Spanish A1 lesson content + A1 article.
-- Idempotent: re-running deletes Spanish A1 then reseeds.
-- A2, B1, B2, C1 keep their existing templated content until later migrations.
--
-- Per lesson: 10 vocab MC + 5 phrase MC + 3 listening + 2 speaking + 2 fill_blank.

do $$
declare
  v_lang_id  bigint;
  v_course_id bigint;
  v_lesson_id bigint;
begin
  select id into v_lang_id from public.languages where code = 'spanish';
  if v_lang_id is null then
    raise exception 'Spanish language not found in public.languages';
  end if;

  -- Replace only A1 — leaves A2..C1 templated content alone.
  delete from public.courses  where language_id = v_lang_id and cefr_level = 'A1';
  delete from public.articles where language_id = v_lang_id and level = 'A1';

  -- =================== A1.1 GREETINGS ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Greetings', 'Common Spanish greetings, farewells, and introductions.', 'A1', 1)
  returning id into v_course_id;

  -- Lesson 1: core greetings vocabulary
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Greetings — Lesson 1', 'Hello, goodbye, and the basics.', 'vocabulary', 1, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "Hello" in Spanish?','Hola',array['Adiós','Gracias','Sí'],'Hello [OH-lah]',1),
    (v_lesson_id,'multiple_choice','How do you say "Goodbye" in Spanish?','Adiós',array['Hola','Bien','Por favor'],'Goodbye [ah-DYOHS]',2),
    (v_lesson_id,'multiple_choice','How do you say "Thank you" in Spanish?','Gracias',array['De nada','Hola','No'],'Thank you [GRAH-syahs]',3),
    (v_lesson_id,'multiple_choice','How do you say "Please" in Spanish?','Por favor',array['Gracias','De nada','Sí'],'Please [pohr fah-VOHR]',4),
    (v_lesson_id,'multiple_choice','How do you say "Yes" in Spanish?','Sí',array['No','Hola','Mal'],'Yes [SEE]',5),
    (v_lesson_id,'multiple_choice','How do you say "No" in Spanish?','No',array['Sí','Bien','Hola'],'No [NOH]',6),
    (v_lesson_id,'multiple_choice','How do you say "Good morning" in Spanish?','Buenos días',array['Buenas tardes','Buenas noches','Hasta luego'],'Good morning [BWEH-nohs DEE-ahs]',7),
    (v_lesson_id,'multiple_choice','How do you say "Good night" in Spanish?','Buenas noches',array['Buenos días','Buenas tardes','Hola'],'Good night [BWEH-nahs NOH-chehs]',8),
    (v_lesson_id,'multiple_choice','How do you say "You are welcome" in Spanish?','De nada',array['Gracias','Por favor','Adiós'],'You are welcome [deh NAH-dah]',9),
    (v_lesson_id,'multiple_choice','How do you say "Well / Fine" in Spanish?','Bien',array['Mal','Sí','No'],'Well / Fine [BYEHN]',10),
    (v_lesson_id,'multiple_choice','How would you ask "How are you?" informally in Spanish?','¿Cómo estás?',array['¿Cómo te llamas?','¿De dónde eres?','¿Qué tal?'],'How are you? [KOH-moh ehs-TAHS]',11),
    (v_lesson_id,'multiple_choice','How do you say "See you later"?','Hasta luego',array['Buenos días','Mucho gusto','Encantado'],'See you later [AHS-tah LWEH-goh]',12),
    (v_lesson_id,'multiple_choice','How do you say "Nice to meet you" (m.)?','Encantado',array['Mucho gusto','De nada','Hola'],'Nice to meet you [ehn-kahn-TAH-doh]',13),
    (v_lesson_id,'multiple_choice','How do you say "Good afternoon"?','Buenas tardes',array['Buenos días','Buenas noches','Hasta mañana'],'Good afternoon [BWEH-nahs TAR-dehs]',14),
    (v_lesson_id,'multiple_choice','Translate "Mucho gusto" into English.','Pleased to meet you',array['Good evening','See you tomorrow','Thank you very much'],'Mucho gusto [MOO-choh GOOS-toh]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','Hola',array['Adiós','Gracias','Bien'],'Hello',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','Buenos días',array['Buenas noches','Hasta luego','Por favor'],'Good morning',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','Gracias',array['Por favor','De nada','Sí'],'Thank you',18),
    (v_lesson_id,'speaking','Say "Hello" in Spanish.','Hola',array[]::text[],'Hola [OH-lah]',19),
    (v_lesson_id,'speaking','Say "Thank you" in Spanish.','Gracias',array[]::text[],'Gracias [GRAH-syahs]',20),
    (v_lesson_id,'fill_blank','Complete: "___, ¿cómo estás?" (Hello, how are you?)','Hola',array['Adiós','Gracias','Bien'],'Hello',21),
    (v_lesson_id,'fill_blank','Complete: "Muy bien, ___." (Very well, thanks.)','gracias',array['adiós','hola','por favor'],'thanks',22);

  -- Lesson 2: introductions
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Greetings — Lesson 2', 'Names, introductions and small talk.', 'phrases', 2, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you ask "What is your name?" informally?','¿Cómo te llamas?',array['¿De dónde eres?','¿Cómo estás?','¿Qué tal?'],'What is your name? [KOH-moh teh YAH-mahs]',1),
    (v_lesson_id,'multiple_choice','How do you say "My name is..."?','Me llamo...',array['Te llamas...','Soy de...','Mucho gusto'],'My name is... [meh YAH-moh]',2),
    (v_lesson_id,'multiple_choice','How do you ask "Where are you from?" informally?','¿De dónde eres?',array['¿Cómo estás?','¿Cómo te llamas?','¿Qué tal?'],'Where are you from? [deh DOHN-deh EH-rehs]',3),
    (v_lesson_id,'multiple_choice','How do you say "I am from Spain"?','Soy de España',array['Me llamo España','Estoy en España','Voy a España'],'I am from Spain [SOY deh ehs-PAH-nyah]',4),
    (v_lesson_id,'multiple_choice','How do you say "Nice to meet you" (f.)?','Encantada',array['Encantado','Mucho','Gusto'],'Nice to meet you (f.) [ehn-kahn-TAH-dah]',5),
    (v_lesson_id,'multiple_choice','How do you say "Likewise"?','Igualmente',array['Encantado','Por supuesto','Hasta luego'],'Likewise [ee-gwahl-MEHN-teh]',6),
    (v_lesson_id,'multiple_choice','How do you say "See you tomorrow"?','Hasta mañana',array['Hasta luego','Buenas noches','Adiós'],'See you tomorrow [AHS-tah mah-NYAH-nah]',7),
    (v_lesson_id,'multiple_choice','How do you say "How is it going?"','¿Qué tal?',array['¿Cómo te llamas?','¿De dónde eres?','¿Cuántos años?'],'How is it going? [keh TAHL]',8),
    (v_lesson_id,'multiple_choice','Translate "Me llamo Ana" into English.','My name is Ana',array['Ana calls me','I am called by Ana','Ana is here'],'My name is Ana',9),
    (v_lesson_id,'multiple_choice','Which is a formal greeting?','¿Cómo está usted?',array['¿Qué tal?','Hola','¿Cómo estás?'],'How are you? (formal) [KOH-moh ehs-TAH oos-TEHD]',10),
    (v_lesson_id,'multiple_choice','How would you greet a friend at 7 p.m.?','Buenas tardes',array['Buenos días','Buenas noches','Hasta luego'],'Good afternoon / evening',11),
    (v_lesson_id,'multiple_choice','How would you say "See you" (casually)?','Nos vemos',array['Mucho gusto','Encantado','Buenos días'],'See you [nohs BEH-mohs]',12),
    (v_lesson_id,'multiple_choice','Translate "Igualmente" into English.','Likewise',array['Sorry','Please','Welcome'],'Likewise',13),
    (v_lesson_id,'multiple_choice','How do you say "Have a good day"?','Que tengas un buen día',array['Buen provecho','Mucho gusto','Hasta pronto'],'Have a good day [keh TEHN-gahs oon BWEHN DEE-ah]',14),
    (v_lesson_id,'multiple_choice','How do you say "I am very well"?','Estoy muy bien',array['Soy muy bien','Estoy muy mal','Yo bien'],'I am very well [ehs-TOY mwee BYEHN]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','Me llamo Ana',array['Te llamas Ana','Soy de Ana','Mucho gusto'],'My name is Ana',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','¿De dónde eres?',array['¿Cómo estás?','¿Cómo te llamas?','¿Qué tal?'],'Where are you from?',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','Encantado',array['Igualmente','Mucho gusto','Hasta luego'],'Nice to meet you',18),
    (v_lesson_id,'speaking','Say "My name is Ana" in Spanish.','Me llamo Ana',array[]::text[],'Me llamo Ana [meh YAH-moh AH-nah]',19),
    (v_lesson_id,'speaking','Say "Nice to meet you" (m.) in Spanish.','Mucho gusto',array[]::text[],'Mucho gusto [MOO-choh GOOS-toh]',20),
    (v_lesson_id,'fill_blank','Complete: "Me ___ Carlos." (My name is Carlos.)','llamo',array['llamas','llama','llamamos'],'My name is Carlos',21),
    (v_lesson_id,'fill_blank','Complete: "Soy ___ México." (I am from Mexico.)','de',array['en','a','con'],'I am from Mexico',22);

  -- Lesson 3: listening focus
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Greetings — Lesson 3', 'Hear and recognise common greetings.', 'listening', 3, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','Which is the polite form of "you"?','usted',array['tú','vos','yo'],'You (formal) [oos-TEHD]',1),
    (v_lesson_id,'multiple_choice','How do you say "Until soon"?','Hasta pronto',array['Hasta nunca','Hasta el lunes','Hasta cuándo'],'See you soon [AHS-tah PROHN-toh]',2),
    (v_lesson_id,'multiple_choice','Which means "Welcome"?','Bienvenido',array['Bien hecho','Buen viaje','Buena suerte'],'Welcome [byehn-beh-NEE-doh]',3),
    (v_lesson_id,'multiple_choice','Translate "Buenas noches".','Good night',array['Good morning','Good afternoon','Goodbye'],'Good night',4),
    (v_lesson_id,'multiple_choice','How do you answer "¿Cómo estás?" with "fine"?','Estoy bien',array['Soy bien','Tengo bien','Hago bien'],'I am fine [ehs-TOY BYEHN]',5),
    (v_lesson_id,'multiple_choice','Which phrase says "Excuse me"?','Disculpe',array['Por favor','Lo siento','Adiós'],'Excuse me [dees-KOOL-peh]',6),
    (v_lesson_id,'multiple_choice','Which phrase says "I am sorry"?','Lo siento',array['Disculpe','Gracias','Por favor'],'I am sorry [loh SYEHN-toh]',7),
    (v_lesson_id,'multiple_choice','How do you say "What time is it?" (casual greeting context)','¿Qué hora es?',array['¿Qué día es?','¿Qué tal?','¿Cómo estás?'],'What time is it? [keh OH-rah ehs]',8),
    (v_lesson_id,'multiple_choice','Translate "Adiós, hasta luego".','Goodbye, see you later',array['Hello, my name is','Good night, sleep well','Welcome back home'],'Goodbye, see you later',9),
    (v_lesson_id,'multiple_choice','How do you say "I am from the United States"?','Soy de Estados Unidos',array['Estoy en Estados Unidos','Voy a Estados Unidos','Vengo Estados Unidos'],'I am from the United States',10),
    (v_lesson_id,'multiple_choice','How do you say "And you?"','¿Y tú?',array['¿Y yo?','¿Y él?','¿Y usted?'],'And you? [ee TOO]',11),
    (v_lesson_id,'multiple_choice','How do you say "Pleased to greet you"?','Encantado de saludarte',array['Encantado de comer','Encantado de viaje','Encantado de mañana'],'Pleased to greet you',12),
    (v_lesson_id,'multiple_choice','Which is informal "you"?','tú',array['usted','él','ellos'],'You (informal) [TOO]',13),
    (v_lesson_id,'multiple_choice','Translate "Buen día".','Good day',array['Good idea','Goodbye','Good luck'],'Good day [BWEHN DEE-ah]',14),
    (v_lesson_id,'multiple_choice','How would a clerk politely ask "How can I help you?"','¿En qué puedo ayudarle?',array['¿Cómo te llamas?','¿De dónde eres?','¿Qué quieres?'],'How can I help you? [ehn KEH PWEH-doh ah-yoo-DAHR-leh]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','Buenas tardes',array['Buenos días','Buenas noches','Hasta mañana'],'Good afternoon',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','¿Qué tal?',array['¿Cómo estás?','¿Cómo te llamas?','¿De dónde eres?'],'How is it going?',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','Hasta mañana',array['Hasta luego','Hasta pronto','Hasta el lunes'],'See you tomorrow',18),
    (v_lesson_id,'speaking','Say "How are you?" informally in Spanish.','¿Cómo estás?',array[]::text[],'¿Cómo estás? [KOH-moh ehs-TAHS]',19),
    (v_lesson_id,'speaking','Say "I am from Spain" in Spanish.','Soy de España',array[]::text[],'Soy de España [SOY deh ehs-PAH-nyah]',20),
    (v_lesson_id,'fill_blank','Complete: "¿___ estás?" (How are you?)','Cómo',array['Qué','Dónde','Cuándo'],'How',21),
    (v_lesson_id,'fill_blank','Complete: "Hasta ___" (See you later)','luego',array['siempre','mucho','poco'],'later',22);

  -- Lesson 4: speaking practice
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Greetings — Lesson 4', 'Speak greetings out loud.', 'speaking', 4, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','Which is a polite farewell?','Que tenga un buen día',array['Buen provecho','Salud','Felicidades'],'Have a good day (formal)',1),
    (v_lesson_id,'multiple_choice','Translate "Salud" when said at a sneeze.','Bless you',array['Goodbye','Welcome','Please'],'Bless you [sah-LOOD]',2),
    (v_lesson_id,'multiple_choice','How do you wish someone "Good luck"?','Buena suerte',array['Buen viaje','Buen provecho','Buen día'],'Good luck [BWEH-nah SWEHR-teh]',3),
    (v_lesson_id,'multiple_choice','How do you wish someone "Have a good trip"?','Buen viaje',array['Buen provecho','Buena suerte','Buenas tardes'],'Have a good trip [BWEHN BYAH-heh]',4),
    (v_lesson_id,'multiple_choice','How do you say "Enjoy your meal"?','Buen provecho',array['Buen viaje','Bienvenido','Buenas noches'],'Enjoy your meal [BWEHN proh-BEH-choh]',5),
    (v_lesson_id,'multiple_choice','How do you say "Congratulations"?','Felicidades',array['Saludos','Bienvenida','Hasta luego'],'Congratulations [feh-lee-see-DAH-dehs]',6),
    (v_lesson_id,'multiple_choice','How do you politely say "Excuse me, sir"?','Disculpe, señor',array['Hola, señor','Adiós, señor','Gracias, señor'],'Excuse me, sir',7),
    (v_lesson_id,'multiple_choice','Translate "Saludos" as a sign-off.','Greetings / Regards',array['Goodbye','Sorry','Thanks'],'Greetings [sah-LOO-dohs]',8),
    (v_lesson_id,'multiple_choice','Which means "See you on Monday"?','Hasta el lunes',array['Hasta mañana','Hasta luego','Hasta nunca'],'See you on Monday [AHS-tah ehl LOO-nehs]',9),
    (v_lesson_id,'multiple_choice','How do you say "Have a good weekend"?','Buen fin de semana',array['Buen día','Buen viaje','Buena tarde'],'Have a good weekend',10),
    (v_lesson_id,'multiple_choice','Translate "Ciao" in casual Spanish usage.','See you / Bye',array['Hello','Please','Thanks'],'See you / Bye [CHOW]',11),
    (v_lesson_id,'multiple_choice','How do you say "Take care"?','Cuídate',array['Cuento','Cuanto','Cuándo'],'Take care [KWEE-dah-teh]',12),
    (v_lesson_id,'multiple_choice','How do you formally say "Take care"?','Cuídese',array['Cuídate','Cuídelos','Cuídala'],'Take care (formal) [KWEE-deh-seh]',13),
    (v_lesson_id,'multiple_choice','Translate "Bienvenida".','Welcome (f.)',array['Goodbye','Cheers','Sorry'],'Welcome (f.) [byehn-beh-NEE-dah]',14),
    (v_lesson_id,'multiple_choice','How do you toast "Cheers"?','Salud',array['Buen viaje','Felicidades','Buenas noches'],'Cheers [sah-LOOD]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','Cuídate',array['Cuídese','Disculpe','Bienvenido'],'Take care',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','Buen viaje',array['Buen provecho','Buena suerte','Buenas tardes'],'Have a good trip',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','Felicidades',array['Saludos','Bienvenido','Encantado'],'Congratulations',18),
    (v_lesson_id,'speaking','Say "Have a good day" formally in Spanish.','Que tenga un buen día',array[]::text[],'Que tenga un buen día [keh TEHN-gah oon BWEHN DEE-ah]',19),
    (v_lesson_id,'speaking','Say "Take care" informally in Spanish.','Cuídate',array[]::text[],'Cuídate [KWEE-dah-teh]',20),
    (v_lesson_id,'fill_blank','Complete: "Buen ___" (Enjoy your meal)','provecho',array['viaje','suerte','día'],'Have a good meal',21),
    (v_lesson_id,'fill_blank','Complete: "Hasta el ___" (See you on Monday)','lunes',array['martes','viernes','sábado'],'Monday',22);

  -- =================== A1.2 NUMBERS ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Numbers', 'Count and use Spanish numbers in everyday situations.', 'A1', 2)
  returning id into v_course_id;

  -- Lesson 1: 1-10
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Numbers — Lesson 1', 'Numbers one through ten.', 'vocabulary', 1, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','What is "one" in Spanish?','uno',array['dos','tres','seis'],'One [OO-noh]',1),
    (v_lesson_id,'multiple_choice','What is "two" in Spanish?','dos',array['doce','diez','uno'],'Two [DOHS]',2),
    (v_lesson_id,'multiple_choice','What is "three" in Spanish?','tres',array['trece','treinta','dos'],'Three [TREHS]',3),
    (v_lesson_id,'multiple_choice','What is "four" in Spanish?','cuatro',array['catorce','cuarenta','cinco'],'Four [KWAH-troh]',4),
    (v_lesson_id,'multiple_choice','What is "five" in Spanish?','cinco',array['cien','quince','cincuenta'],'Five [SEEN-koh]',5),
    (v_lesson_id,'multiple_choice','What is "six" in Spanish?','seis',array['siete','sesenta','dieciséis'],'Six [SEHS]',6),
    (v_lesson_id,'multiple_choice','What is "seven" in Spanish?','siete',array['setenta','seis','ocho'],'Seven [SYEH-teh]',7),
    (v_lesson_id,'multiple_choice','What is "eight" in Spanish?','ocho',array['ochenta','dieciocho','nueve'],'Eight [OH-choh]',8),
    (v_lesson_id,'multiple_choice','What is "nine" in Spanish?','nueve',array['noventa','diecinueve','diez'],'Nine [NWEH-beh]',9),
    (v_lesson_id,'multiple_choice','What is "ten" in Spanish?','diez',array['doce','dos','once'],'Ten [DYEHS]',10),
    (v_lesson_id,'multiple_choice','Translate "tres".','three',array['four','six','thirteen'],'Three',11),
    (v_lesson_id,'multiple_choice','Translate "ocho".','eight',array['nine','eighty','eighteen'],'Eight',12),
    (v_lesson_id,'multiple_choice','Translate "siete".','seven',array['six','seventeen','seventy'],'Seven',13),
    (v_lesson_id,'multiple_choice','Which number comes after "cuatro"?','cinco',array['tres','seis','diez'],'Five',14),
    (v_lesson_id,'multiple_choice','Which number comes before "siete"?','seis',array['ocho','cinco','siete'],'Six',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','cinco',array['cuatro','quince','cincuenta'],'Five',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','nueve',array['nuevo','noventa','diecinueve'],'Nine',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','dos',array['doce','tres','diez'],'Two',18),
    (v_lesson_id,'speaking','Say "five" in Spanish.','cinco',array[]::text[],'cinco [SEEN-koh]',19),
    (v_lesson_id,'speaking','Say "ten" in Spanish.','diez',array[]::text[],'diez [DYEHS]',20),
    (v_lesson_id,'fill_blank','Complete: "uno, dos, ___, cuatro"','tres',array['cinco','seis','diez'],'three',21),
    (v_lesson_id,'fill_blank','Complete: "siete, ocho, ___, diez"','nueve',array['seis','once','siete'],'nine',22);

  -- Lesson 2: 11-20
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Numbers — Lesson 2', 'Numbers eleven through twenty.', 'vocabulary', 2, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','What is "eleven" in Spanish?','once',array['doce','diez','onze'],'Eleven [OHN-seh]',1),
    (v_lesson_id,'multiple_choice','What is "twelve" in Spanish?','doce',array['dos','diez','docena'],'Twelve [DOH-seh]',2),
    (v_lesson_id,'multiple_choice','What is "thirteen" in Spanish?','trece',array['treinta','tres','tercero'],'Thirteen [TREH-seh]',3),
    (v_lesson_id,'multiple_choice','What is "fourteen" in Spanish?','catorce',array['cuarenta','cuatro','catorceavo'],'Fourteen [kah-TOHR-seh]',4),
    (v_lesson_id,'multiple_choice','What is "fifteen" in Spanish?','quince',array['cincuenta','cinco','quinto'],'Fifteen [KEEN-seh]',5),
    (v_lesson_id,'multiple_choice','What is "sixteen" in Spanish?','dieciséis',array['sesenta','seis','seismil'],'Sixteen [dyeh-see-SEHS]',6),
    (v_lesson_id,'multiple_choice','What is "seventeen" in Spanish?','diecisiete',array['setenta','siete','décimo'],'Seventeen [dyeh-see-SYEH-teh]',7),
    (v_lesson_id,'multiple_choice','What is "eighteen" in Spanish?','dieciocho',array['ochenta','ocho','décimo'],'Eighteen [dyeh-SYOH-choh]',8),
    (v_lesson_id,'multiple_choice','What is "nineteen" in Spanish?','diecinueve',array['noventa','nueve','novecientos'],'Nineteen [dyeh-see-NWEH-beh]',9),
    (v_lesson_id,'multiple_choice','What is "twenty" in Spanish?','veinte',array['dos','doce','dieciocho'],'Twenty [BEHN-teh]',10),
    (v_lesson_id,'multiple_choice','Translate "catorce".','fourteen',array['four','forty','forty-four'],'Fourteen',11),
    (v_lesson_id,'multiple_choice','Translate "veinte".','twenty',array['two','twelve','two hundred'],'Twenty',12),
    (v_lesson_id,'multiple_choice','Which comes after "quince"?','dieciséis',array['catorce','diecisiete','veinte'],'Sixteen',13),
    (v_lesson_id,'multiple_choice','Which is the largest number?','veinte',array['quince','diecisiete','dieciocho'],'Twenty',14),
    (v_lesson_id,'multiple_choice','Which is the smallest number?','once',array['quince','veinte','diecinueve'],'Eleven',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','quince',array['cinco','cincuenta','quinto'],'Fifteen',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','dieciocho',array['ocho','ochenta','dieciséis'],'Eighteen',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','veinte',array['veintiuno','treinta','viento'],'Twenty',18),
    (v_lesson_id,'speaking','Say "fifteen" in Spanish.','quince',array[]::text[],'quince [KEEN-seh]',19),
    (v_lesson_id,'speaking','Say "twenty" in Spanish.','veinte',array[]::text[],'veinte [BEHN-teh]',20),
    (v_lesson_id,'fill_blank','Complete: "doce, trece, ___, quince"','catorce',array['diez','dieciséis','cuatro'],'fourteen',21),
    (v_lesson_id,'fill_blank','Complete: "dieciocho, ___, veinte"','diecinueve',array['diecisiete','veintiuno','quince'],'nineteen',22);

  -- Lesson 3: tens 20-100
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Numbers — Lesson 3', 'Tens, hundreds and listening for prices.', 'listening', 3, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','What is "thirty" in Spanish?','treinta',array['trece','tres','trescientos'],'Thirty [TREHN-tah]',1),
    (v_lesson_id,'multiple_choice','What is "forty" in Spanish?','cuarenta',array['catorce','cuatro','cuarto'],'Forty [kwah-REHN-tah]',2),
    (v_lesson_id,'multiple_choice','What is "fifty" in Spanish?','cincuenta',array['quinientos','quince','cinco'],'Fifty [seen-KWEHN-tah]',3),
    (v_lesson_id,'multiple_choice','What is "sixty" in Spanish?','sesenta',array['seiscientos','dieciséis','seis'],'Sixty [seh-SEHN-tah]',4),
    (v_lesson_id,'multiple_choice','What is "seventy" in Spanish?','setenta',array['setecientos','diecisiete','siete'],'Seventy [seh-TEHN-tah]',5),
    (v_lesson_id,'multiple_choice','What is "eighty" in Spanish?','ochenta',array['ochocientos','dieciocho','ocho'],'Eighty [oh-CHEHN-tah]',6),
    (v_lesson_id,'multiple_choice','What is "ninety" in Spanish?','noventa',array['novecientos','diecinueve','nueve'],'Ninety [noh-BEHN-tah]',7),
    (v_lesson_id,'multiple_choice','What is "one hundred" in Spanish?','cien',array['mil','ciento','sien'],'One hundred [SYEHN]',8),
    (v_lesson_id,'multiple_choice','What is "one thousand"?','mil',array['cien','millón','milla'],'One thousand [MEEL]',9),
    (v_lesson_id,'multiple_choice','Translate "veintiuno".','twenty-one',array['eleven','two','two hundred one'],'Twenty-one [behn-tee-OO-noh]',10),
    (v_lesson_id,'multiple_choice','Translate "treinta y dos".','thirty-two',array['twenty-three','three hundred two','thirteen'],'Thirty-two',11),
    (v_lesson_id,'multiple_choice','How much is "cincuenta euros"?','50 euros',array['15 euros','500 euros','5 euros'],'Fifty euros',12),
    (v_lesson_id,'multiple_choice','Which is bigger?','noventa',array['ochenta','setenta','sesenta'],'Ninety > eighty',13),
    (v_lesson_id,'multiple_choice','How do you say "two hundred"?','doscientos',array['dos cien','doscien','dos cientas'],'Two hundred [dohs-SYEHN-tohs]',14),
    (v_lesson_id,'multiple_choice','How do you say "one million"?','un millón',array['un mil','un cien','un milla'],'One million [oon mee-YOHN]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','cincuenta',array['cinco','quince','sesenta'],'Fifty',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','setenta',array['siete','setecientos','sesenta'],'Seventy',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','cien euros',array['mil euros','ciento euros','sien euros'],'One hundred euros',18),
    (v_lesson_id,'speaking','Say "thirty" in Spanish.','treinta',array[]::text[],'treinta [TREHN-tah]',19),
    (v_lesson_id,'speaking','Say "one hundred" in Spanish.','cien',array[]::text[],'cien [SYEHN]',20),
    (v_lesson_id,'fill_blank','Complete: "veinte, treinta, ___, cincuenta"','cuarenta',array['cincuenta','sesenta','catorce'],'forty',21),
    (v_lesson_id,'fill_blank','Complete: "noventa, ___, ciento diez"','cien',array['nueve','mil','sien'],'one hundred',22);

  -- Lesson 4: numbers in context (age, price, time)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Numbers — Lesson 4', 'Use numbers for age, prices and quantity.', 'speaking', 4, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you ask "How old are you?" informally?','¿Cuántos años tienes?',array['¿Cuánto cuesta?','¿Qué hora es?','¿Cuántas veces?'],'How old are you? [KWAHN-tohs AH-nyohs TYEH-nehs]',1),
    (v_lesson_id,'multiple_choice','How do you say "I am 25 years old"?','Tengo veinticinco años',array['Soy veinticinco años','Estoy veinticinco años','Hago veinticinco años'],'I am 25 years old',2),
    (v_lesson_id,'multiple_choice','How do you say "How much does it cost?"','¿Cuánto cuesta?',array['¿Cuántos años?','¿Cuándo es?','¿Cuál es?'],'How much does it cost? [KWAHN-toh KWEHS-tah]',3),
    (v_lesson_id,'multiple_choice','How do you say "It costs ten euros"?','Cuesta diez euros',array['Es diez euros','Tiene diez euros','Hace diez euros'],'It costs ten euros',4),
    (v_lesson_id,'multiple_choice','Which is "first"?','primero',array['uno','principal','primario'],'First [pree-MEH-roh]',5),
    (v_lesson_id,'multiple_choice','Which is "second"?','segundo',array['dos','siguiente','secundario'],'Second [seh-GOON-doh]',6),
    (v_lesson_id,'multiple_choice','Which is "third"?','tercero',array['tres','triple','tercio'],'Third [tehr-SEH-roh]',7),
    (v_lesson_id,'multiple_choice','How do you say "the phone number"?','el número de teléfono',array['el teléfono numero','la teléfono número','el numero teléfono'],'The phone number',8),
    (v_lesson_id,'multiple_choice','How do you say "Half"?','medio',array['mitad','partido','pequeño'],'Half [MEH-dyoh]',9),
    (v_lesson_id,'multiple_choice','Translate "Mil cien".','One thousand one hundred',array['Eleven hundred dollars','One hundred','One million'],'1100',10),
    (v_lesson_id,'multiple_choice','How do you say "How many people?"','¿Cuántas personas?',array['¿Cuántos años?','¿Cuánto cuesta?','¿Qué hora?'],'How many people? [KWAHN-tahs pehr-SOH-nahs]',11),
    (v_lesson_id,'multiple_choice','Translate "Treinta minutos".','Thirty minutes',array['Three minutes','Thirteen minutes','Three hundred minutes'],'Thirty minutes',12),
    (v_lesson_id,'multiple_choice','How do you say "Two coffees, please"?','Dos cafés, por favor',array['Dos café, por favor','Dos cafées, por favor','Doses cafés, por favor'],'Two coffees, please',13),
    (v_lesson_id,'multiple_choice','How do you say "I have three brothers"?','Tengo tres hermanos',array['Soy tres hermanos','Hago tres hermanos','Voy tres hermanos'],'I have three brothers',14),
    (v_lesson_id,'multiple_choice','How would you express "around 20"?','unos veinte',array['un veinte','el veinte','los veinte'],'About twenty [OO-nohs BEHN-teh]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','tengo veinte años',array['tengo veinte hijos','tengo veinte cafés','tengo veinte años'],'I am 20 years old',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','cuesta cinco euros',array['cuesta quince euros','cuesta cincuenta euros','tiene cinco euros'],'It costs five euros',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','el número siete',array['el numero siete','el setenta','el siete'],'Number seven',18),
    (v_lesson_id,'speaking','Say "I am thirty years old" in Spanish.','Tengo treinta años',array[]::text[],'Tengo treinta años [TEHN-goh TREHN-tah AH-nyohs]',19),
    (v_lesson_id,'speaking','Say "How much does it cost?" in Spanish.','¿Cuánto cuesta?',array[]::text[],'¿Cuánto cuesta? [KWAHN-toh KWEHS-tah]',20),
    (v_lesson_id,'fill_blank','Complete: "Tengo ___ años." (I am 18 years old)','dieciocho',array['ocho','ochenta','ochocientos'],'eighteen',21),
    (v_lesson_id,'fill_blank','Complete: "Cuesta ___ euros." (It costs 50 euros)','cincuenta',array['quince','cinco','quinientos'],'fifty',22);

  -- =================== A1.3 COLORS ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Colors', 'Name the colors and describe what you see in Spanish.', 'A1', 3)
  returning id into v_course_id;

  -- Lesson 1: primary colors
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Colors — Lesson 1', 'Primary colors and basics.', 'vocabulary', 1, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "red" in Spanish?','rojo',array['rosa','negro','verde'],'Red [ROH-hoh]',1),
    (v_lesson_id,'multiple_choice','How do you say "blue" in Spanish?','azul',array['amarillo','blanco','azulejo'],'Blue [ah-SOOL]',2),
    (v_lesson_id,'multiple_choice','How do you say "yellow" in Spanish?','amarillo',array['azul','naranja','amargo'],'Yellow [ah-mah-REE-yoh]',3),
    (v_lesson_id,'multiple_choice','How do you say "green" in Spanish?','verde',array['gris','blanco','verdura'],'Green [BEHR-deh]',4),
    (v_lesson_id,'multiple_choice','How do you say "black" in Spanish?','negro',array['blanco','marrón','noche'],'Black [NEH-groh]',5),
    (v_lesson_id,'multiple_choice','How do you say "white" in Spanish?','blanco',array['negro','rojo','blando'],'White [BLAHN-koh]',6),
    (v_lesson_id,'multiple_choice','How do you say "orange (color)" in Spanish?','naranja',array['rojo','amarillo','marrón'],'Orange [nah-RAHN-hah]',7),
    (v_lesson_id,'multiple_choice','How do you say "purple"?','morado',array['marrón','rosa','moreno'],'Purple [moh-RAH-doh]',8),
    (v_lesson_id,'multiple_choice','How do you say "pink"?','rosa',array['rojo','morado','rosado'],'Pink [ROH-sah]',9),
    (v_lesson_id,'multiple_choice','How do you say "gray"?','gris',array['negro','blanco','grueso'],'Gray [GREES]',10),
    (v_lesson_id,'multiple_choice','Translate "marrón".','brown',array['black','blue','pink'],'Brown [mah-RROHN]',11),
    (v_lesson_id,'multiple_choice','Translate "color".','color',array['cool','colorful','curious'],'Color [koh-LOHR]',12),
    (v_lesson_id,'multiple_choice','What color is "el sol"?','amarillo',array['azul','verde','blanco'],'Yellow (the sun)',13),
    (v_lesson_id,'multiple_choice','What color is "la hierba"?','verde',array['rojo','azul','marrón'],'Green (the grass)',14),
    (v_lesson_id,'multiple_choice','What color is "la nieve"?','blanca',array['negra','azul','roja'],'White (snow, f.)',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','rojo',array['rosa','negro','rico'],'Red',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','azul',array['amarillo','azulejo','blanco'],'Blue',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','verde',array['verdura','viento','viejo'],'Green',18),
    (v_lesson_id,'speaking','Say "red" in Spanish.','rojo',array[]::text[],'rojo [ROH-hoh]',19),
    (v_lesson_id,'speaking','Say "blue" in Spanish.','azul',array[]::text[],'azul [ah-SOOL]',20),
    (v_lesson_id,'fill_blank','Complete: "El cielo es ___" (The sky is blue.)','azul',array['rojo','verde','negro'],'blue',21),
    (v_lesson_id,'fill_blank','Complete: "La manzana es ___" (The apple is red.)','roja',array['azul','verde','blanca'],'red (f.)',22);

  -- Lesson 2: agreement (-o/-a)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Colors — Lesson 2', 'Gender agreement with colors.', 'grammar', 2, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','"The red car" — el coche...','rojo',array['roja','rojos','rojas'],'Red (m. singular)',1),
    (v_lesson_id,'multiple_choice','"The red house" — la casa...','roja',array['rojo','rojos','rojas'],'Red (f. singular)',2),
    (v_lesson_id,'multiple_choice','"The yellow flowers" — las flores...','amarillas',array['amarillo','amarillos','amarilla'],'Yellow (f. plural)',3),
    (v_lesson_id,'multiple_choice','"The black shoes" — los zapatos...','negros',array['negro','negra','negras'],'Black (m. plural)',4),
    (v_lesson_id,'multiple_choice','"The white dress" — el vestido...','blanco',array['blanca','blancos','blancas'],'White (m. singular)',5),
    (v_lesson_id,'multiple_choice','Which colors do NOT change for gender?','azul, verde, gris',array['rojo, blanco','negro, amarillo','rosa, morado'],'Colors ending in -e or consonant',6),
    (v_lesson_id,'multiple_choice','"The blue cars" — los coches...','azules',array['azul','azulos','azula'],'Blue (plural)',7),
    (v_lesson_id,'multiple_choice','"The green plants" — las plantas...','verdes',array['verde','verdos','verdas'],'Green (plural)',8),
    (v_lesson_id,'multiple_choice','"The gray cats" — los gatos...','grises',array['gris','grisos','grisas'],'Gray (plural)',9),
    (v_lesson_id,'multiple_choice','"A black coat" — un abrigo...','negro',array['negra','negros','negras'],'Black (m.)',10),
    (v_lesson_id,'multiple_choice','"A pink shirt" — una camisa...','rosa',array['roso','rosas','rosos'],'Pink (rosa is invariable)',11),
    (v_lesson_id,'multiple_choice','"The brown dog" — el perro...','marrón',array['marrona','marrones','marrónes'],'Brown (m. singular)',12),
    (v_lesson_id,'multiple_choice','"The orange juice" — el zumo de...','naranja',array['naranjo','naranjas','naranjos'],'Orange (invariable)',13),
    (v_lesson_id,'multiple_choice','How do you say "light blue"?','azul claro',array['azul oscuro','azul brillante','azul fuerte'],'Light blue',14),
    (v_lesson_id,'multiple_choice','How do you say "dark green"?','verde oscuro',array['verde claro','verde fuerte','verde nuevo'],'Dark green',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','la casa blanca',array['el coche blanco','las casas blancas','la casa negra'],'The white house',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','los zapatos negros',array['las zapatas negras','el zapato negro','los zapatos morados'],'The black shoes',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','azul oscuro',array['azul claro','verde oscuro','rojo oscuro'],'Dark blue',18),
    (v_lesson_id,'speaking','Say "The red house" in Spanish.','La casa roja',array[]::text[],'La casa roja [lah KAH-sah ROH-hah]',19),
    (v_lesson_id,'speaking','Say "Yellow flowers" in Spanish.','Flores amarillas',array[]::text[],'Flores amarillas [FLOH-rehs ah-mah-REE-yahs]',20),
    (v_lesson_id,'fill_blank','Complete: "El gato ___" (The black cat)','negro',array['negra','negros','negras'],'black',21),
    (v_lesson_id,'fill_blank','Complete: "Las flores ___" (The white flowers)','blancas',array['blanco','blanca','blancos'],'white (f. pl.)',22);

  -- Lesson 3: describing things
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Colors — Lesson 3', 'Listen and recognise color descriptions.', 'listening', 3, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','What color is "el limón"?','amarillo',array['verde','rojo','naranja'],'Yellow (lemon)',1),
    (v_lesson_id,'multiple_choice','What color is "el plátano"?','amarillo',array['marrón','verde','rojo'],'Yellow (banana)',2),
    (v_lesson_id,'multiple_choice','What color is "el chocolate"?','marrón',array['negro','rojo','amarillo'],'Brown (chocolate)',3),
    (v_lesson_id,'multiple_choice','What color is "el café"?','marrón',array['negro','blanco','rojo'],'Brown (coffee)',4),
    (v_lesson_id,'multiple_choice','How do you ask "What color is it?"','¿De qué color es?',array['¿Qué es de color?','¿De color qué?','¿Cuál color?'],'What color is it? [deh KEH koh-LOHR ehs]',5),
    (v_lesson_id,'multiple_choice','Translate "Mi favorito es el verde."','My favorite is green',array['I like green','Green is good','I have green'],'My favorite is green',6),
    (v_lesson_id,'multiple_choice','Translate "Me gusta el azul."','I like blue',array['I am blue','I have blue','I want blue'],'I like blue',7),
    (v_lesson_id,'multiple_choice','How do you say "a colorful dress"?','un vestido colorido',array['un vestido color','un vestido colorful','un vestido colorado'],'A colorful dress [koh-loh-REE-doh]',8),
    (v_lesson_id,'multiple_choice','What color is "el océano"?','azul',array['verde','blanco','gris'],'Blue (ocean)',9),
    (v_lesson_id,'multiple_choice','What color is "la luna"?','blanca',array['amarilla','azul','negra'],'White (moon, f.)',10),
    (v_lesson_id,'multiple_choice','What color is "el fuego"?','rojo',array['azul','negro','verde'],'Red (fire)',11),
    (v_lesson_id,'multiple_choice','What color is "la noche"?','negra',array['blanca','amarilla','azul'],'Black (night, f.)',12),
    (v_lesson_id,'multiple_choice','How do you say "colorless"?','incoloro',array['sin color','no color','descolor'],'Colorless [een-koh-LOH-roh]',13),
    (v_lesson_id,'multiple_choice','What color is "el mar"?','azul',array['verde','marrón','rosa'],'Blue (sea)',14),
    (v_lesson_id,'multiple_choice','Translate "El semáforo está en rojo."','The traffic light is red',array['The traffic is heavy','The light is on','The signal is green'],'The traffic light is red',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','el coche es rojo',array['el coche es rosa','el coche está rojo','la casa es roja'],'The car is red',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','la flor amarilla',array['la flor naranja','las flores amarillas','el flor amarillo'],'The yellow flower',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','verde claro',array['verde oscuro','verdura','claro verde'],'Light green',18),
    (v_lesson_id,'speaking','Say "I like the color blue" in Spanish.','Me gusta el color azul',array[]::text[],'Me gusta el color azul',19),
    (v_lesson_id,'speaking','Say "The house is white" in Spanish.','La casa es blanca',array[]::text[],'La casa es blanca',20),
    (v_lesson_id,'fill_blank','Complete: "El sol es ___" (The sun is yellow.)','amarillo',array['blanco','rojo','verde'],'yellow',21),
    (v_lesson_id,'fill_blank','Complete: "Mi color favorito es el ___" (My favorite color is blue.)','azul',array['rosa','gris','verde'],'blue',22);

  -- Lesson 4: speaking + favourite color
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Colors — Lesson 4', 'Talk about your favorite colors.', 'speaking', 4, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you ask "What is your favorite color?"','¿Cuál es tu color favorito?',array['¿Qué color?','¿Cómo es el color?','¿Te gusta el color?'],'What is your favorite color? [KWAHL ehs too koh-LOHR fah-boh-REE-toh]',1),
    (v_lesson_id,'multiple_choice','How do you say "My favorite color is..."','Mi color favorito es...',array['Mi favorito color...','El color mí favorito...','Me color favorito...'],'My favorite color is...',2),
    (v_lesson_id,'multiple_choice','Which means "I love red"?','Me encanta el rojo',array['Yo amo rojo','Me gusta roja','Tengo rojo'],'I love red [meh ehn-KAHN-tah ehl ROH-hoh]',3),
    (v_lesson_id,'multiple_choice','How do you say "I do not like brown"?','No me gusta el marrón',array['Yo no marrón','No tengo marrón','Marrón no'],'I do not like brown',4),
    (v_lesson_id,'multiple_choice','Translate "Prefiero el verde."','I prefer green',array['I have green','I want green','I see green'],'I prefer green [preh-FYEH-roh]',5),
    (v_lesson_id,'multiple_choice','How do you say "the shirt is green"?','la camisa es verde',array['la camisa está verde','la camisa va verde','la camisa tiene verde'],'The shirt is green',6),
    (v_lesson_id,'multiple_choice','How do you say "to paint"?','pintar',array['pelear','pisar','pegar'],'To paint [peen-TAHR]',7),
    (v_lesson_id,'multiple_choice','Translate "El cielo está gris hoy."','The sky is gray today',array['The sea is calm','The day is sunny','The sky is blue'],'The sky is gray today',8),
    (v_lesson_id,'multiple_choice','How do you say "Wear something colorful"?','Lleva algo colorido',array['Tener color','Vestir color','Sacar color'],'Wear something colorful',9),
    (v_lesson_id,'multiple_choice','What color do you mix to get green?','azul y amarillo',array['rojo y azul','blanco y negro','rojo y amarillo'],'Blue and yellow',10),
    (v_lesson_id,'multiple_choice','What color do you mix to get orange?','rojo y amarillo',array['azul y rojo','blanco y rojo','amarillo y azul'],'Red and yellow',11),
    (v_lesson_id,'multiple_choice','What color do you mix to get purple?','rojo y azul',array['rojo y amarillo','azul y verde','blanco y rojo'],'Red and blue',12),
    (v_lesson_id,'multiple_choice','How do you say "to color / to dye"?','colorear',array['comer','correr','cortar'],'To color [koh-loh-reh-AHR]',13),
    (v_lesson_id,'multiple_choice','How do you say "a colorful party"?','una fiesta colorida',array['una fiesta colorado','una fiesta de color','una colorada fiesta'],'A colorful party',14),
    (v_lesson_id,'multiple_choice','Translate "Los niños pintan con colores."','The children paint with colors',array['The children eat colors','The children look at colors','The boys speak about colors'],'The children paint with colors',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','mi color favorito es el azul',array['mi color favorito es el rosa','me gusta el azul','el azul es mi color'],'My favorite color is blue',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','prefiero el verde',array['prefiero el rojo','prefiero verde','prefiero la verdura'],'I prefer green',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','no me gusta el negro',array['me gusta el negro','no me gusta el negro','no tengo negro'],'I do not like black',18),
    (v_lesson_id,'speaking','Say "My favorite color is red" in Spanish.','Mi color favorito es el rojo',array[]::text[],'Mi color favorito es el rojo',19),
    (v_lesson_id,'speaking','Say "I like blue and green" in Spanish.','Me gustan el azul y el verde',array[]::text[],'Me gustan el azul y el verde',20),
    (v_lesson_id,'fill_blank','Complete: "Mi color ___ es el rojo." (My favorite color is red.)','favorito',array['favorita','famoso','feliz'],'favorite',21),
    (v_lesson_id,'fill_blank','Complete: "El azul y el ___ hacen verde." (Blue and yellow make green.)','amarillo',array['rojo','blanco','morado'],'yellow',22);

  -- =================== A1.4 FAMILY ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Family', 'Talk about your family members in Spanish.', 'A1', 4)
  returning id into v_course_id;

  -- Lesson 1: nuclear family
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Family — Lesson 1', 'Parents, siblings and children.', 'vocabulary', 1, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "mother" in Spanish?','madre',array['padre','hermana','abuela'],'Mother [MAH-dreh]',1),
    (v_lesson_id,'multiple_choice','How do you say "father" in Spanish?','padre',array['madre','hermano','tío'],'Father [PAH-dreh]',2),
    (v_lesson_id,'multiple_choice','How do you say "brother"?','hermano',array['hermana','primo','hijo'],'Brother [ehr-MAH-noh]',3),
    (v_lesson_id,'multiple_choice','How do you say "sister"?','hermana',array['hermano','prima','tía'],'Sister [ehr-MAH-nah]',4),
    (v_lesson_id,'multiple_choice','How do you say "son"?','hijo',array['hija','primo','padre'],'Son [EE-hoh]',5),
    (v_lesson_id,'multiple_choice','How do you say "daughter"?','hija',array['hijo','hermana','tía'],'Daughter [EE-hah]',6),
    (v_lesson_id,'multiple_choice','How do you say "family"?','familia',array['amigos','famoso','feria'],'Family [fah-MEE-lyah]',7),
    (v_lesson_id,'multiple_choice','How do you say "parents"?','padres',array['hermanos','primos','abuelos'],'Parents [PAH-drehs]',8),
    (v_lesson_id,'multiple_choice','How do you say "children" (sons/daughters)?','hijos',array['hijas','niños','chicos'],'Children [EE-hohs]',9),
    (v_lesson_id,'multiple_choice','How do you say "baby"?','bebé',array['niño','niña','joven'],'Baby [beh-BEH]',10),
    (v_lesson_id,'multiple_choice','How do you say "I have two brothers"?','Tengo dos hermanos',array['Soy dos hermanos','Tener dos hermanos','Hay dos hermanos míos'],'I have two brothers',11),
    (v_lesson_id,'multiple_choice','How do you say "my sister"?','mi hermana',array['mí hermana','me hermana','la mi hermana'],'My sister [mee ehr-MAH-nah]',12),
    (v_lesson_id,'multiple_choice','How do you say "your father" (informal)?','tu padre',array['su padre','tú padre','el tu padre'],'Your father [too PAH-dreh]',13),
    (v_lesson_id,'multiple_choice','Translate "Mi madre se llama Carmen."','My mother is named Carmen',array['I call my mother Carmen','Carmen calls my mother','My mother is Carmen'],'My mother is named Carmen',14),
    (v_lesson_id,'multiple_choice','Translate "Es mi hijo."','He is my son',array['It is my hijo','She is my son','He is my brother'],'He is my son',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','madre',array['padre','tarde','tarde'],'Mother',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','mi hermano',array['mi hermana','mis hermanos','mí hermano'],'My brother',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','tengo una hija',array['tengo un hijo','tienes una hija','no tengo hijo'],'I have a daughter',18),
    (v_lesson_id,'speaking','Say "my mother" in Spanish.','mi madre',array[]::text[],'mi madre [mee MAH-dreh]',19),
    (v_lesson_id,'speaking','Say "I have a brother" in Spanish.','Tengo un hermano',array[]::text[],'Tengo un hermano [TEHN-goh oon ehr-MAH-noh]',20),
    (v_lesson_id,'fill_blank','Complete: "Mi ___ se llama Juan." (My father is named Juan)','padre',array['madre','hermana','tía'],'father',21),
    (v_lesson_id,'fill_blank','Complete: "Tengo dos ___" (I have two siblings)','hermanos',array['hermanas','hijos','padres'],'brothers/siblings',22);

  -- Lesson 2: extended family
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Family — Lesson 2', 'Grandparents, aunts, uncles and cousins.', 'vocabulary', 2, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "grandfather"?','abuelo',array['abuela','tío','padrino'],'Grandfather [ah-BWEH-loh]',1),
    (v_lesson_id,'multiple_choice','How do you say "grandmother"?','abuela',array['abuelo','tía','madrina'],'Grandmother [ah-BWEH-lah]',2),
    (v_lesson_id,'multiple_choice','How do you say "uncle"?','tío',array['tía','primo','sobrino'],'Uncle [TEE-oh]',3),
    (v_lesson_id,'multiple_choice','How do you say "aunt"?','tía',array['tío','prima','sobrina'],'Aunt [TEE-ah]',4),
    (v_lesson_id,'multiple_choice','How do you say "cousin (m.)"?','primo',array['prima','primero','primario'],'Cousin (m.) [PREE-moh]',5),
    (v_lesson_id,'multiple_choice','How do you say "cousin (f.)"?','prima',array['primo','primera','prima donna'],'Cousin (f.) [PREE-mah]',6),
    (v_lesson_id,'multiple_choice','How do you say "nephew"?','sobrino',array['sobrina','primo','suegro'],'Nephew [soh-BREE-noh]',7),
    (v_lesson_id,'multiple_choice','How do you say "niece"?','sobrina',array['sobrino','prima','suegra'],'Niece [soh-BREE-nah]',8),
    (v_lesson_id,'multiple_choice','How do you say "husband"?','esposo',array['esposa','marino','marido también'],'Husband [ehs-POH-soh]',9),
    (v_lesson_id,'multiple_choice','How do you say "wife"?','esposa',array['esposo','marina','espuma'],'Wife [ehs-POH-sah]',10),
    (v_lesson_id,'multiple_choice','How do you say "grandchildren"?','nietos',array['hijos','sobrinos','primos'],'Grandchildren [NYEH-tohs]',11),
    (v_lesson_id,'multiple_choice','How do you say "father-in-law"?','suegro',array['suegra','padrastro','tío'],'Father-in-law [SWEH-groh]',12),
    (v_lesson_id,'multiple_choice','How do you say "mother-in-law"?','suegra',array['suegro','madrastra','tía'],'Mother-in-law [SWEH-grah]',13),
    (v_lesson_id,'multiple_choice','Translate "mis abuelos".','my grandparents',array['my parents','my grandfathers','my cousins'],'My grandparents',14),
    (v_lesson_id,'multiple_choice','Translate "mi prima Ana".','my cousin Ana (f.)',array['my first Ana','my niece Ana','my aunt Ana'],'My cousin Ana (f.)',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','mi abuela',array['mi abuelo','mis abuelos','mi suegra'],'My grandmother',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','tengo dos primos',array['tengo dos primas','tengo dos hijos','tienes dos primos'],'I have two cousins',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','mi tía Marta',array['mi tío Marta','mi prima Marta','mi madre Marta'],'My aunt Marta',18),
    (v_lesson_id,'speaking','Say "my grandfather" in Spanish.','mi abuelo',array[]::text[],'mi abuelo [mee ah-BWEH-loh]',19),
    (v_lesson_id,'speaking','Say "I have three cousins" in Spanish.','Tengo tres primos',array[]::text[],'Tengo tres primos',20),
    (v_lesson_id,'fill_blank','Complete: "Mi ___ se llama Pedro." (My uncle is named Pedro.)','tío',array['tía','primo','sobrino'],'uncle',21),
    (v_lesson_id,'fill_blank','Complete: "Los padres de mi padre son mis ___" (My fathers parents are my grandparents)','abuelos',array['tíos','primos','padres'],'grandparents',22);

  -- Lesson 3: describing family
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Family — Lesson 3', 'Listen to descriptions of family members.', 'listening', 3, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','Translate "Mi familia es grande."','My family is big',array['My family is small','My family is here','My family is good'],'My family is big',1),
    (v_lesson_id,'multiple_choice','Translate "Es muy joven."','He/She is very young',array['He/She is very old','He/She is here','He/She lives'],'He/She is very young [HOH-behn]',2),
    (v_lesson_id,'multiple_choice','How do you say "He is tall"?','Es alto',array['Está alto','Tiene alto','Hace alto'],'He is tall [AHL-toh]',3),
    (v_lesson_id,'multiple_choice','How do you say "She is short"?','Es baja',array['Está baja','Es bajo','Está bajo'],'She is short [BAH-hah]',4),
    (v_lesson_id,'multiple_choice','How do you say "old (person)"?','mayor',array['vieja','antiguo','grande'],'Older / elderly [mah-YOHR]',5),
    (v_lesson_id,'multiple_choice','How do you say "younger sister"?','hermana menor',array['hermana mayor','hermanita','hermana pequeño'],'Younger sister [ehr-MAH-nah meh-NOHR]',6),
    (v_lesson_id,'multiple_choice','How do you say "older brother"?','hermano mayor',array['hermano menor','hermano grande','hermano viejo'],'Older brother',7),
    (v_lesson_id,'multiple_choice','Translate "Mi padre es muy alto."','My father is very tall',array['My father is very kind','My father is very old','My father is very rich'],'My father is very tall',8),
    (v_lesson_id,'multiple_choice','How do you say "How many siblings do you have?"','¿Cuántos hermanos tienes?',array['¿Cuántos años tienes?','¿Cuánto cuesta?','¿Cuál es tu hermano?'],'How many siblings do you have?',9),
    (v_lesson_id,'multiple_choice','How do you say "I am the only child"?','Soy hijo único',array['Estoy solo','Soy uno solo','Tengo un hijo'],'I am the only child [oh-NEE-koh]',10),
    (v_lesson_id,'multiple_choice','How do you say "He looks like his father"?','Se parece a su padre',array['Es como su padre','Hace su padre','Mira a su padre'],'He looks like his father [seh pah-REH-seh]',11),
    (v_lesson_id,'multiple_choice','Translate "Vivo con mis padres."','I live with my parents',array['I love my parents','I see my parents','I call my parents'],'I live with my parents',12),
    (v_lesson_id,'multiple_choice','Translate "Mi abuela cocina muy bien."','My grandmother cooks very well',array['My grandmother is well','My grandmother is good','My grandmother eats well'],'My grandmother cooks very well',13),
    (v_lesson_id,'multiple_choice','How do you say "my husband"?','mi marido',array['mi maridos','el marido','mi esposo (also valid)'],'My husband [mah-REE-doh]',14),
    (v_lesson_id,'multiple_choice','How do you say "my wife"?','mi mujer',array['mi mujeres','la mujer','mi esposa (also valid)'],'My wife [moo-HEHR]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','tengo una familia grande',array['tengo una familia pequeña','tienes una familia grande','no tengo familia'],'I have a big family',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','mi hermano mayor',array['mi hermana mayor','mi hermano menor','mi hermano vivo'],'My older brother',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','soy hijo único',array['soy hijo nuevo','soy hijo bueno','somos hijos únicos'],'I am the only child',18),
    (v_lesson_id,'speaking','Say "My family is big" in Spanish.','Mi familia es grande',array[]::text[],'Mi familia es grande',19),
    (v_lesson_id,'speaking','Say "I have two sisters" in Spanish.','Tengo dos hermanas',array[]::text[],'Tengo dos hermanas',20),
    (v_lesson_id,'fill_blank','Complete: "Mi hermana es ___" (My sister is young.)','joven',array['vieja','alta','grande'],'young',21),
    (v_lesson_id,'fill_blank','Complete: "Mi abuelo es ___" (My grandfather is older.)','mayor',array['menor','grande','alto'],'older',22);

  -- Lesson 4: speaking about family
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Family — Lesson 4', 'Introduce your family out loud.', 'speaking', 4, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "This is my mother"?','Esta es mi madre',array['Este es mi madre','Ese es mi madre','Esto es mi madre'],'This is my mother',1),
    (v_lesson_id,'multiple_choice','How do you say "This is my father"?','Este es mi padre',array['Esta es mi padre','Ese es mi padre','Esto es mi padre'],'This is my father',2),
    (v_lesson_id,'multiple_choice','How do you say "I love my family"?','Quiero a mi familia',array['Tengo a mi familia','Estoy mi familia','Hago mi familia'],'I love my family [KYEH-roh]',3),
    (v_lesson_id,'multiple_choice','How do you say "I miss my mother"?','Echo de menos a mi madre',array['Tengo menos mi madre','Soy menos mi madre','Falto mi madre'],'I miss my mother [EH-choh deh MEH-nohs]',4),
    (v_lesson_id,'multiple_choice','How do you say "my family lives in Madrid"?','mi familia vive en Madrid',array['mi familia es en Madrid','mi familia está Madrid','mi familia tiene Madrid'],'My family lives in Madrid',5),
    (v_lesson_id,'multiple_choice','How do you say "I visit my grandparents on Sundays"?','Visito a mis abuelos los domingos',array['Veo mi abuelo los domingos','Voy mis abuelos domingos','Estoy a mis abuelos domingos'],'I visit my grandparents on Sundays',6),
    (v_lesson_id,'multiple_choice','How do you say "We are a big family"?','Somos una familia grande',array['Tenemos familia grande','Estamos familia grande','Hacemos familia grande'],'We are a big family',7),
    (v_lesson_id,'multiple_choice','How do you say "Are you married?" (informal)','¿Estás casado?',array['¿Eres casado?','¿Tienes casado?','¿Vas casado?'],'Are you married? [kah-SAH-doh]',8),
    (v_lesson_id,'multiple_choice','How do you say "I am single"?','Soy soltero',array['Estoy soltero','Tengo soltero','Vivo soltero'],'I am single [sohl-TEH-roh]',9),
    (v_lesson_id,'multiple_choice','How do you say "I have a son and a daughter"?','Tengo un hijo y una hija',array['Soy un hijo y una hija','Hay un hijo y una hija','Está un hijo y una hija'],'I have a son and a daughter',10),
    (v_lesson_id,'multiple_choice','How do you say "My family is from Mexico"?','Mi familia es de México',array['Mi familia está México','Mi familia tiene México','Mi familia hace México'],'My family is from Mexico',11),
    (v_lesson_id,'multiple_choice','How do you say "We get along well"?','Nos llevamos bien',array['Nos llevamos','Llevamos bien','Llevamos a bien'],'We get along well [nohs yeh-BAH-mohs BYEHN]',12),
    (v_lesson_id,'multiple_choice','How do you say "Family is important"?','La familia es importante',array['La familia tiene importante','La familia hace importante','La familia está importante'],'Family is important',13),
    (v_lesson_id,'multiple_choice','How do you say "my dear family"?','mi querida familia',array['mi querer familia','mi familia querer','mi quería familia'],'My dear family [keh-REE-dah]',14),
    (v_lesson_id,'multiple_choice','How do you say "twin"?','gemelo',array['mellizo / gemelo','primo','doble'],'Twin [heh-MEH-loh]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','esta es mi madre',array['este es mi padre','esa es mi madre','esto es mi madre'],'This is my mother',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','quiero a mi familia',array['quiero mi familia','tengo a mi familia','quiero a mi padre'],'I love my family',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','somos cuatro en la familia',array['somos cuatros en la familia','soy cuatro en la familia','son cuatro en la familia'],'We are four in the family',18),
    (v_lesson_id,'speaking','Say "This is my mother" in Spanish.','Esta es mi madre',array[]::text[],'Esta es mi madre',19),
    (v_lesson_id,'speaking','Say "I love my family" in Spanish.','Quiero a mi familia',array[]::text[],'Quiero a mi familia',20),
    (v_lesson_id,'fill_blank','Complete: "___ es mi padre." (This is my father.)','Este',array['Esta','Esto','Esos'],'this (m.)',21),
    (v_lesson_id,'fill_blank','Complete: "Quiero ___ mi familia." (I love my family.)','a',array['de','en','con'],'(personal a)',22);

  -- =================== A1.5 FOOD ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Food', 'Talk about food, drinks and meals in Spanish.', 'A1', 5)
  returning id into v_course_id;

  -- Lesson 1: basic foods
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Food — Lesson 1', 'Bread, water, fruit and basics.', 'vocabulary', 1, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "bread"?','pan',array['pasta','papa','pera'],'Bread [PAHN]',1),
    (v_lesson_id,'multiple_choice','How do you say "water"?','agua',array['aceite','azúcar','aire'],'Water [AH-gwah]',2),
    (v_lesson_id,'multiple_choice','How do you say "milk"?','leche',array['licor','lechuga','laca'],'Milk [LEH-cheh]',3),
    (v_lesson_id,'multiple_choice','How do you say "cheese"?','queso',array['queja','queso azul','queja'],'Cheese [KEH-soh]',4),
    (v_lesson_id,'multiple_choice','How do you say "apple"?','manzana',array['mañana','plátano','melón'],'Apple [mahn-SAH-nah]',5),
    (v_lesson_id,'multiple_choice','How do you say "chicken"?','pollo',array['polvo','pelo','polo'],'Chicken [POH-yoh]',6),
    (v_lesson_id,'multiple_choice','How do you say "rice"?','arroz',array['atrás','arroyo','asado'],'Rice [ah-RROHS]',7),
    (v_lesson_id,'multiple_choice','How do you say "soup"?','sopa',array['ropa','sapo','copa'],'Soup [SOH-pah]',8),
    (v_lesson_id,'multiple_choice','How do you say "salad"?','ensalada',array['ensaladera','salada','salado'],'Salad [ehn-sah-LAH-dah]',9),
    (v_lesson_id,'multiple_choice','How do you say "coffee"?','café',array['te','cacao','azúcar'],'Coffee [kah-FEH]',10),
    (v_lesson_id,'multiple_choice','How do you say "tea"?','té',array['café','agua','leche'],'Tea [TEH]',11),
    (v_lesson_id,'multiple_choice','How do you say "fruit"?','fruta',array['frito','frente','flor'],'Fruit [FROO-tah]',12),
    (v_lesson_id,'multiple_choice','How do you say "vegetable"?','verdura',array['verde','vendaje','verdad'],'Vegetable [behr-DOO-rah]',13),
    (v_lesson_id,'multiple_choice','How do you say "meat"?','carne',array['cartel','carro','cariño'],'Meat [KAHR-neh]',14),
    (v_lesson_id,'multiple_choice','How do you say "fish (as food)"?','pescado',array['pez','pez vivo','pegado'],'Fish (food) [pehs-KAH-doh]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','un café, por favor',array['un té, por favor','una cerveza, por favor','un agua, por favor'],'A coffee, please',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','quiero pollo',array['quiero pan','quiero polo','quiero queso'],'I want chicken',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','sopa de verduras',array['sopa de pollo','sopa de pescado','copa de verduras'],'Vegetable soup',18),
    (v_lesson_id,'speaking','Say "I want water, please" in Spanish.','Quiero agua, por favor',array[]::text[],'Quiero agua, por favor',19),
    (v_lesson_id,'speaking','Say "I like apples" in Spanish.','Me gustan las manzanas',array[]::text[],'Me gustan las manzanas',20),
    (v_lesson_id,'fill_blank','Complete: "Quiero un ___ con leche." (I want a coffee with milk.)','café',array['té','agua','pan'],'coffee',21),
    (v_lesson_id,'fill_blank','Complete: "Como una ___ roja." (I eat a red apple.)','manzana',array['mañana','naranja','sandía'],'apple',22);

  -- Lesson 2: meals & ordering
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Food — Lesson 2', 'Meals and ordering at a restaurant.', 'phrases', 2, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "breakfast"?','el desayuno',array['la comida','la cena','la merienda'],'Breakfast [deh-sah-YOO-noh]',1),
    (v_lesson_id,'multiple_choice','How do you say "lunch"?','la comida',array['el desayuno','la cena','el almuerzo (Latin America)'],'Lunch (Spain) [koh-MEE-dah]',2),
    (v_lesson_id,'multiple_choice','How do you say "dinner"?','la cena',array['la comida','el desayuno','el postre'],'Dinner [SEH-nah]',3),
    (v_lesson_id,'multiple_choice','How do you say "I am hungry"?','Tengo hambre',array['Estoy hambre','Soy hambre','Quiero hambre'],'I am hungry [TEHN-goh AHM-breh]',4),
    (v_lesson_id,'multiple_choice','How do you say "I am thirsty"?','Tengo sed',array['Estoy sed','Soy sed','Quiero sed'],'I am thirsty [TEHN-goh SEHD]',5),
    (v_lesson_id,'multiple_choice','How do you say "the menu"?','la carta',array['el menú','el papel','la lista'],'The menu [LAH KAHR-tah]',6),
    (v_lesson_id,'multiple_choice','How do you say "the bill"?','la cuenta',array['el cuento','el precio','la cuentita'],'The bill [LAH KWEHN-tah]',7),
    (v_lesson_id,'multiple_choice','How do you order: "I would like..."?','Quisiera...',array['Queremos','Querer','Quería'],'I would like... [kee-SYEH-rah]',8),
    (v_lesson_id,'multiple_choice','How do you say "Enjoy your meal"?','Buen provecho',array['Buen viaje','Buen tiempo','Buen día'],'Enjoy your meal [BWEHN proh-BEH-choh]',9),
    (v_lesson_id,'multiple_choice','Translate "Una mesa para dos, por favor."','A table for two, please',array['Two coffees, please','A drink for two, please','A meal for two, please'],'A table for two, please',10),
    (v_lesson_id,'multiple_choice','How do you say "delicious"?','delicioso',array['rico también','sabroso también','bueno'],'Delicious [deh-lee-SYOH-soh]',11),
    (v_lesson_id,'multiple_choice','How do you say "spicy"?','picante',array['picado','picazón','salado'],'Spicy [pee-KAHN-teh]',12),
    (v_lesson_id,'multiple_choice','How do you say "sweet"?','dulce',array['salado','amargo','agrio'],'Sweet [DOOL-seh]',13),
    (v_lesson_id,'multiple_choice','How do you say "salty"?','salado',array['dulce','amargo','picante'],'Salty [sah-LAH-doh]',14),
    (v_lesson_id,'multiple_choice','How do you say "the dessert"?','el postre',array['el plato','el pan','el principio'],'The dessert [POHS-treh]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','la cuenta, por favor',array['la carta, por favor','la copa, por favor','el café, por favor'],'The bill, please',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','tengo mucha hambre',array['tengo mucha sed','tengo mucha prisa','no tengo hambre'],'I am very hungry',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','el desayuno está listo',array['la cena está lista','el desayuno es listo','el desayuno está aquí'],'Breakfast is ready',18),
    (v_lesson_id,'speaking','Say "I am hungry" in Spanish.','Tengo hambre',array[]::text[],'Tengo hambre',19),
    (v_lesson_id,'speaking','Say "The bill, please" in Spanish.','La cuenta, por favor',array[]::text[],'La cuenta, por favor',20),
    (v_lesson_id,'fill_blank','Complete: "Quisiera ___ ensalada." (I would like a salad.)','una',array['un','el','la'],'a (f.)',21),
    (v_lesson_id,'fill_blank','Complete: "Tengo ___" (I am thirsty.)','sed',array['hambre','sueño','frío'],'thirst',22);

  -- Lesson 3: at the market (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Food — Lesson 3', 'Listen to conversations at the market.', 'listening', 3, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "tomato"?','tomate',array['tornado','tomar','toma'],'Tomato [toh-MAH-teh]',1),
    (v_lesson_id,'multiple_choice','How do you say "potato" (Spain)?','patata',array['papa','patético','plátano'],'Potato (Spain) [pah-TAH-tah]',2),
    (v_lesson_id,'multiple_choice','How do you say "potato" (Latin America)?','papa',array['patata','pampa','poco'],'Potato (LatAm) [PAH-pah]',3),
    (v_lesson_id,'multiple_choice','How do you say "onion"?','cebolla',array['cebra','cebada','cabello'],'Onion [seh-BOH-yah]',4),
    (v_lesson_id,'multiple_choice','How do you say "garlic"?','ajo',array['ojo','aja','algo'],'Garlic [AH-hoh]',5),
    (v_lesson_id,'multiple_choice','How do you say "egg"?','huevo',array['hielo','hierba','hueco'],'Egg [WEH-boh]',6),
    (v_lesson_id,'multiple_choice','How do you say "butter"?','mantequilla',array['margarina','manteca también','manzana'],'Butter [mahn-teh-KEE-yah]',7),
    (v_lesson_id,'multiple_choice','How do you say "sugar"?','azúcar',array['arroz','aceite','salsa'],'Sugar [ah-SOO-kahr]',8),
    (v_lesson_id,'multiple_choice','How do you say "salt"?','sal',array['sol','seda','sed'],'Salt [SAHL]',9),
    (v_lesson_id,'multiple_choice','How do you say "oil"?','aceite',array['agua','aceituna','ácido'],'Oil [ah-SEY-teh]',10),
    (v_lesson_id,'multiple_choice','How do you say "lemon"?','limón',array['lima','melón','limpio'],'Lemon [lee-MOHN]',11),
    (v_lesson_id,'multiple_choice','How do you say "orange (fruit)"?','naranja',array['mandarina','manzana','melón'],'Orange (fruit) [nah-RAHN-hah]',12),
    (v_lesson_id,'multiple_choice','How do you say "banana"?','plátano',array['banana también','platillo','planta'],'Banana [PLAH-tah-noh]',13),
    (v_lesson_id,'multiple_choice','How do you say "grapes"?','uvas',array['olivas','ubres','vacas'],'Grapes [OO-bahs]',14),
    (v_lesson_id,'multiple_choice','Translate "Un kilo de manzanas."','One kilo of apples',array['One pound of apples','A kilo of oranges','One bag of apples'],'One kilo of apples',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','un kilo de tomates',array['un kilo de patatas','medio kilo de tomates','kilo tomates'],'One kilo of tomatoes',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','¿cuánto cuesta el pollo?',array['¿cuánto cuesta el pan?','¿cuánto cuesta el queso?','¿dónde está el pollo?'],'How much does the chicken cost?',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','no tenemos huevos',array['no tenemos hierba','no tenemos hijos','tenemos huevos'],'We do not have eggs',18),
    (v_lesson_id,'speaking','Say "I want two apples" in Spanish.','Quiero dos manzanas',array[]::text[],'Quiero dos manzanas',19),
    (v_lesson_id,'speaking','Say "How much do the tomatoes cost?" in Spanish.','¿Cuánto cuestan los tomates?',array[]::text[],'¿Cuánto cuestan los tomates?',20),
    (v_lesson_id,'fill_blank','Complete: "Un kilo de ___" (One kilo of potatoes.)','patatas',array['plátanos','peras','peces'],'potatoes',21),
    (v_lesson_id,'fill_blank','Complete: "Necesito sal y ___" (I need salt and sugar.)','azúcar',array['aceite','arroz','agua'],'sugar',22);

  -- Lesson 4: speaking + preferences
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Food — Lesson 4', 'Talk about your food preferences.', 'speaking', 4, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "I like fish"?','Me gusta el pescado',array['Yo gusto el pescado','Tengo gusto pescado','Me gusta pescado'],'I like fish',1),
    (v_lesson_id,'multiple_choice','How do you say "I do not like onions"?','No me gustan las cebollas',array['No gusto cebollas','No me gusta cebollas','Yo no cebollas'],'I do not like onions',2),
    (v_lesson_id,'multiple_choice','How do you say "I am vegetarian"?','Soy vegetariano',array['Estoy vegetariano','Tengo vegetariano','Yo vegetariano'],'I am vegetarian [beh-heh-tah-RYAH-noh]',3),
    (v_lesson_id,'multiple_choice','How do you say "I am allergic to peanuts"?','Soy alérgico a los cacahuetes',array['Estoy alérgico cacahuetes','Tengo alergias cacahuetes','Yo alergia cacahuetes'],'I am allergic to peanuts',4),
    (v_lesson_id,'multiple_choice','How do you say "very tasty"?','muy rico',array['mucha sabrosa','mucho rica','muy rica también'],'Very tasty [REE-koh]',5),
    (v_lesson_id,'multiple_choice','Translate "El pan está duro."','The bread is hard',array['The bread is hot','The bread is soft','The bread is dry'],'The bread is hard',6),
    (v_lesson_id,'multiple_choice','Translate "La sopa está fría."','The soup is cold',array['The soup is hot','The soup is salty','The soup is sweet'],'The soup is cold',7),
    (v_lesson_id,'multiple_choice','Translate "Me encanta el chocolate."','I love chocolate',array['I like chocolate a little','I have chocolate','I want chocolate'],'I love chocolate',8),
    (v_lesson_id,'multiple_choice','How do you say "Cheers!" before drinking?','¡Salud!',array['¡Bienvenido!','¡Buen viaje!','¡Felicidades!'],'Cheers! [sah-LOOD]',9),
    (v_lesson_id,'multiple_choice','How do you say "I am full"?','Estoy lleno',array['Soy lleno','Tengo lleno','Estoy llenado'],'I am full [YEH-noh]',10),
    (v_lesson_id,'multiple_choice','How do you say "the waiter"?','el camarero',array['el cocinero','el mesero también','el cliente'],'The waiter [kah-mah-REH-roh]',11),
    (v_lesson_id,'multiple_choice','How do you say "to drink"?','beber',array['ver','volver','vender'],'To drink [beh-BEHR]',12),
    (v_lesson_id,'multiple_choice','How do you say "to eat"?','comer',array['correr','coger','copiar'],'To eat [koh-MEHR]',13),
    (v_lesson_id,'multiple_choice','How do you say "a glass of wine"?','una copa de vino',array['un vaso de vino','una taza de vino','una copa vino'],'A glass of wine [KOH-pah deh BEE-noh]',14),
    (v_lesson_id,'multiple_choice','How do you say "a bottle of water"?','una botella de agua',array['un vaso de agua','una taza de agua','una agua de botella'],'A bottle of water [boh-TEH-yah]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','me gusta el queso',array['no me gusta el queso','me gustan los quesos','me gusta el peso'],'I like cheese',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','soy vegetariana',array['soy vegetariano','soy vegano','soy vegetal'],'I am vegetarian (f.)',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','la comida está deliciosa',array['la comida está lista','la cena está deliciosa','la comida es deliciosa'],'The food is delicious',18),
    (v_lesson_id,'speaking','Say "I like chicken" in Spanish.','Me gusta el pollo',array[]::text[],'Me gusta el pollo',19),
    (v_lesson_id,'speaking','Say "I am vegetarian" in Spanish.','Soy vegetariano',array[]::text[],'Soy vegetariano',20),
    (v_lesson_id,'fill_blank','Complete: "Me ___ las manzanas." (I like apples.)','gustan',array['gusta','gustamos','gustáis'],'I like (plural object)',21),
    (v_lesson_id,'fill_blank','Complete: "Estoy ___" (I am full.)','lleno',array['llena','llover','lleno de'],'full (m.)',22);

  -- =================== A1.6 TIME ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Time', 'Tell time, days, months and dates in Spanish.', 'A1', 6)
  returning id into v_course_id;

  -- Lesson 1: time units
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Time — Lesson 1', 'Hour, minute, day, week, month, year.', 'vocabulary', 1, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "hour"?','hora',array['ahora','hora también','horror'],'Hour [OH-rah]',1),
    (v_lesson_id,'multiple_choice','How do you say "minute"?','minuto',array['momento','menudo','muy'],'Minute [mee-NOO-toh]',2),
    (v_lesson_id,'multiple_choice','How do you say "second"?','segundo',array['siguiente','seguro','segundo plato'],'Second [seh-GOON-doh]',3),
    (v_lesson_id,'multiple_choice','How do you say "day"?','día',array['días','noche','semana'],'Day [DEE-ah]',4),
    (v_lesson_id,'multiple_choice','How do you say "week"?','semana',array['mañana','semaná','siempre'],'Week [seh-MAH-nah]',5),
    (v_lesson_id,'multiple_choice','How do you say "month"?','mes',array['mas','año','medio'],'Month [MEHS]',6),
    (v_lesson_id,'multiple_choice','How do you say "year"?','año',array['ano','anos','agua'],'Year [AH-nyoh]',7),
    (v_lesson_id,'multiple_choice','How do you say "today"?','hoy',array['ayer','mañana','aquí'],'Today [OY]',8),
    (v_lesson_id,'multiple_choice','How do you say "tomorrow"?','mañana',array['hoy','ayer','manaña'],'Tomorrow [mah-NYAH-nah]',9),
    (v_lesson_id,'multiple_choice','How do you say "yesterday"?','ayer',array['hoy','mañana','aller'],'Yesterday [ah-YEHR]',10),
    (v_lesson_id,'multiple_choice','How do you say "morning"?','la mañana',array['la tarde','la noche','el día'],'Morning [mah-NYAH-nah]',11),
    (v_lesson_id,'multiple_choice','How do you say "afternoon"?','la tarde',array['la mañana','la noche','el mediodía'],'Afternoon [TAR-deh]',12),
    (v_lesson_id,'multiple_choice','How do you say "night"?','la noche',array['la tarde','la mañana','la luna'],'Night [NOH-cheh]',13),
    (v_lesson_id,'multiple_choice','How do you say "noon"?','el mediodía',array['la media','el medio','medianoche'],'Noon [meh-dyoh-DEE-ah]',14),
    (v_lesson_id,'multiple_choice','How do you say "midnight"?','la medianoche',array['el mediodía','la media luna','la nochecita'],'Midnight [meh-dyah-NOH-cheh]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','un día',array['una vez','un mes','un año'],'A day',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','esta semana',array['este mes','esta mañana','esta tarde'],'This week',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','hasta mañana',array['hasta ayer','hasta luego','hasta hoy'],'See you tomorrow',18),
    (v_lesson_id,'speaking','Say "today" in Spanish.','hoy',array[]::text[],'hoy [OY]',19),
    (v_lesson_id,'speaking','Say "this week" in Spanish.','esta semana',array[]::text[],'esta semana [EHS-tah seh-MAH-nah]',20),
    (v_lesson_id,'fill_blank','Complete: "Hoy es un buen ___" (Today is a good day.)','día',array['días','año','mes'],'day',21),
    (v_lesson_id,'fill_blank','Complete: "El ___ tiene cuatro semanas." (A month has four weeks.)','mes',array['año','día','noche'],'month',22);

  -- Lesson 2: days of the week
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Time — Lesson 2', 'Days of the week and months.', 'vocabulary', 2, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "Monday"?','lunes',array['martes','luna','muñeca'],'Monday [LOO-nehs]',1),
    (v_lesson_id,'multiple_choice','How do you say "Tuesday"?','martes',array['lunes','miércoles','marzo'],'Tuesday [MAR-tehs]',2),
    (v_lesson_id,'multiple_choice','How do you say "Wednesday"?','miércoles',array['martes','jueves','mil'],'Wednesday [MYEHR-koh-lehs]',3),
    (v_lesson_id,'multiple_choice','How do you say "Thursday"?','jueves',array['viernes','miércoles','julio'],'Thursday [HWEH-behs]',4),
    (v_lesson_id,'multiple_choice','How do you say "Friday"?','viernes',array['jueves','sábado','víspera'],'Friday [BYEHR-nehs]',5),
    (v_lesson_id,'multiple_choice','How do you say "Saturday"?','sábado',array['domingo','viernes','sabor'],'Saturday [SAH-bah-doh]',6),
    (v_lesson_id,'multiple_choice','How do you say "Sunday"?','domingo',array['sábado','dominio','don'],'Sunday [doh-MEEN-goh]',7),
    (v_lesson_id,'multiple_choice','How do you say "January"?','enero',array['febrero','marzo','energía'],'January [eh-NEH-roh]',8),
    (v_lesson_id,'multiple_choice','How do you say "March"?','marzo',array['mayo','marso','martes'],'March [MAR-soh]',9),
    (v_lesson_id,'multiple_choice','How do you say "May"?','mayo',array['marzo','julio','maya'],'May [MAH-yoh]',10),
    (v_lesson_id,'multiple_choice','How do you say "July"?','julio',array['junio','juego','julieta'],'July [HOO-lyoh]',11),
    (v_lesson_id,'multiple_choice','How do you say "October"?','octubre',array['noviembre','ocho','ocasión'],'October [ohk-TOO-breh]',12),
    (v_lesson_id,'multiple_choice','How do you say "December"?','diciembre',array['noviembre','dieciséis','difícil'],'December [dee-SYEHM-breh]',13),
    (v_lesson_id,'multiple_choice','Translate "el fin de semana".','the weekend',array['the end of the week','the next week','the bad week'],'The weekend [feen deh seh-MAH-nah]',14),
    (v_lesson_id,'multiple_choice','How do you say "every Monday"?','todos los lunes',array['cada lunes','en lunes','el lunes'],'Every Monday',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','el viernes por la noche',array['el sábado por la noche','el viernes por la tarde','el viernes por la mañana'],'Friday night',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','en enero',array['en marzo','en febrero','en abril'],'In January',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','el primer día',array['el último día','el primer mes','el próximo día'],'The first day',18),
    (v_lesson_id,'speaking','Say "Sunday" in Spanish.','domingo',array[]::text[],'domingo [doh-MEEN-goh]',19),
    (v_lesson_id,'speaking','Say "the weekend" in Spanish.','el fin de semana',array[]::text[],'el fin de semana',20),
    (v_lesson_id,'fill_blank','Complete: "Lunes, martes, ___" (Monday, Tuesday, Wednesday)','miércoles',array['jueves','viernes','sábado'],'Wednesday',21),
    (v_lesson_id,'fill_blank','Complete: "Mi cumpleaños es en ___" (My birthday is in May.)','mayo',array['marzo','martes','mañana'],'May',22);

  -- Lesson 3: telling time
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Time — Lesson 3', 'Tell the time on a clock.', 'listening', 3, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you ask "What time is it?"','¿Qué hora es?',array['¿Cuánto es?','¿Cómo está la hora?','¿Cuándo es?'],'What time is it? [keh OH-rah ehs]',1),
    (v_lesson_id,'multiple_choice','How do you say "It is one oclock"?','Es la una',array['Es las uno','Son la una','Son las uno'],'It is one oclock [ehs lah OO-nah]',2),
    (v_lesson_id,'multiple_choice','How do you say "It is two oclock"?','Son las dos',array['Es las dos','Son la dos','Es la dos'],'It is two oclock [sohn lahs DOHS]',3),
    (v_lesson_id,'multiple_choice','How do you say "half past three"?','las tres y media',array['las tres y mitad','las tres media','las tres con media'],'Half past three [tres ee MEH-dyah]',4),
    (v_lesson_id,'multiple_choice','How do you say "quarter past four"?','las cuatro y cuarto',array['las cuatro y quince','las cuatro quince','las cuatro y cuarta'],'Quarter past four [KWAH-troh ee KWAR-toh]',5),
    (v_lesson_id,'multiple_choice','How do you say "quarter to five"?','las cinco menos cuarto',array['las cinco menos quince','cuarto para las cinco','las cinco para cuarto'],'Quarter to five',6),
    (v_lesson_id,'multiple_choice','How do you say "at 9 in the morning"?','a las nueve de la mañana',array['en las nueve mañana','a nueve mañana','para las nueve mañana'],'At 9 in the morning',7),
    (v_lesson_id,'multiple_choice','How do you say "at noon"?','al mediodía',array['en mediodía','a mediodía también','en medio'],'At noon [ahl meh-dyoh-DEE-ah]',8),
    (v_lesson_id,'multiple_choice','Translate "Son las diez de la noche."','It is 10 at night',array['It is 10 in the morning','It is 10 hours','It will be 10'],'It is 10 PM',9),
    (v_lesson_id,'multiple_choice','How do you ask "What time does it start?"','¿A qué hora empieza?',array['¿Cuándo es la hora?','¿Cuál es la hora?','¿Qué hora empieza?'],'What time does it start?',10),
    (v_lesson_id,'multiple_choice','How do you say "early"?','temprano',array['tarde','pronto también','tiempo'],'Early [tehm-PRAH-noh]',11),
    (v_lesson_id,'multiple_choice','How do you say "late"?','tarde',array['temprano','tardanza','tardado'],'Late [TAR-deh]',12),
    (v_lesson_id,'multiple_choice','How do you say "now"?','ahora',array['hora','ahorita','ahorrar'],'Now [ah-OH-rah]',13),
    (v_lesson_id,'multiple_choice','How do you say "later"?','más tarde',array['menos tarde','tarde','después también'],'Later [mahs TAR-deh]',14),
    (v_lesson_id,'multiple_choice','Translate "Llego en cinco minutos."','I arrive in five minutes',array['I leave in five minutes','I have five minutes','I am five minutes early'],'I arrive in five minutes',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','son las tres y media',array['son las tres y cuarto','es la tres y media','son las trece y media'],'It is half past three',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','a las ocho de la mañana',array['a las ocho de la noche','a las ocho de la tarde','las ocho mañana'],'At 8 in the morning',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','llego tarde',array['llego temprano','llego pronto','llego luego'],'I arrive late',18),
    (v_lesson_id,'speaking','Say "What time is it?" in Spanish.','¿Qué hora es?',array[]::text[],'¿Qué hora es?',19),
    (v_lesson_id,'speaking','Say "It is half past two" in Spanish.','Son las dos y media',array[]::text[],'Son las dos y media',20),
    (v_lesson_id,'fill_blank','Complete: "Son las ___ y cuarto." (It is quarter past four.)','cuatro',array['cinco','cuatros','cuarto'],'four',21),
    (v_lesson_id,'fill_blank','Complete: "Llego ___ a las nueve." (I arrive at 9.)','a',array['en','de','por'],'at',22);

  -- Lesson 4: speaking about routines (time)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Time — Lesson 4', 'Schedules and daily times spoken aloud.', 'speaking', 4, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "every day"?','todos los días',array['cada día también','día por día','los días'],'Every day [TOH-dohs lohs DEE-ahs]',1),
    (v_lesson_id,'multiple_choice','How do you say "sometimes"?','a veces',array['siempre','nunca','una vez'],'Sometimes [ah BEH-sehs]',2),
    (v_lesson_id,'multiple_choice','How do you say "always"?','siempre',array['nunca','casi','a menudo'],'Always [SYEHM-preh]',3),
    (v_lesson_id,'multiple_choice','How do you say "never"?','nunca',array['siempre','jamás también','ninguno'],'Never [NOON-kah]',4),
    (v_lesson_id,'multiple_choice','How do you say "often"?','a menudo',array['poco','de vez en cuando','a veces'],'Often [ah meh-NOO-doh]',5),
    (v_lesson_id,'multiple_choice','Translate "Me levanto a las siete."','I get up at seven',array['I sleep at seven','I leave at seven','I am at seven'],'I get up at seven',6),
    (v_lesson_id,'multiple_choice','Translate "Trabajo de lunes a viernes."','I work Monday to Friday',array['I worked on Monday Friday','I work on Mondays only','I will work Monday Friday'],'I work Monday to Friday',7),
    (v_lesson_id,'multiple_choice','How do you say "the next day"?','el día siguiente',array['el día seguido','el próximo día','el día siguiendo'],'The next day [el DEE-ah see-GYEHN-teh]',8),
    (v_lesson_id,'multiple_choice','How do you say "last week"?','la semana pasada',array['la semana siguiente','la semana próxima','la semana antes'],'Last week [pah-SAH-dah]',9),
    (v_lesson_id,'multiple_choice','How do you say "next month"?','el mes que viene',array['el mes pasado','el mes adelante','el próximo mes también'],'Next month [meh keh BYEH-neh]',10),
    (v_lesson_id,'multiple_choice','How do you say "in two hours"?','en dos horas',array['dentro dos horas','para dos horas','con dos horas'],'In two hours [ehn dohs OH-rahs]',11),
    (v_lesson_id,'multiple_choice','How do you say "How long?"','¿Cuánto tiempo?',array['¿Qué tiempo?','¿Cuándo tiempo?','¿Cuál tiempo?'],'How long? [KWAHN-toh TYEHM-poh]',12),
    (v_lesson_id,'multiple_choice','Translate "Hace dos años."','Two years ago',array['Two years from now','For two years','Twice a year'],'Two years ago',13),
    (v_lesson_id,'multiple_choice','Translate "Desde hace tres meses."','For three months (up to now)',array['Three months ago','In three months','Until three months'],'For three months',14),
    (v_lesson_id,'multiple_choice','How do you say "What day is it today?"','¿Qué día es hoy?',array['¿Cuándo es hoy?','¿Qué es hoy?','¿Cómo día es hoy?'],'What day is it today?',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','todos los días',array['todas las noches','toda la semana','cada año'],'Every day',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','el mes que viene',array['el mes pasado','la semana que viene','el día que viene'],'Next month',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','trabajo de lunes a viernes',array['trabajo el lunes','trabajo en viernes','trabajamos de lunes a viernes'],'I work Monday to Friday',18),
    (v_lesson_id,'speaking','Say "I get up at seven" in Spanish.','Me levanto a las siete',array[]::text[],'Me levanto a las siete',19),
    (v_lesson_id,'speaking','Say "I always work on Mondays" in Spanish.','Siempre trabajo los lunes',array[]::text[],'Siempre trabajo los lunes',20),
    (v_lesson_id,'fill_blank','Complete: "___ ceno a las nueve." (I always have dinner at nine.)','Siempre',array['Nunca','A veces','Mañana'],'always',21),
    (v_lesson_id,'fill_blank','Complete: "Hace dos ___" (Two years ago.)','años',array['ano','meses','días'],'years',22);

  -- =================== A1.7 WEATHER ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Weather', 'Describe weather and seasons in Spanish.', 'A1', 7)
  returning id into v_course_id;

  -- Lesson 1: basic weather
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Weather — Lesson 1', 'Sunny, rainy, hot, cold.', 'vocabulary', 1, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "It is sunny"?','Hace sol',array['Hay sol','Está sol','Es sol'],'It is sunny [AH-seh SOHL]',1),
    (v_lesson_id,'multiple_choice','How do you say "It is raining"?','Llueve',array['Lloviendo','Lluvia','Llover'],'It is raining [YWEH-beh]',2),
    (v_lesson_id,'multiple_choice','How do you say "It is snowing"?','Nieva',array['Nieve','Nevando','Nevar'],'It is snowing [NYEH-bah]',3),
    (v_lesson_id,'multiple_choice','How do you say "It is hot"?','Hace calor',array['Es calor','Está calor','Tiene calor'],'It is hot [AH-seh kah-LOHR]',4),
    (v_lesson_id,'multiple_choice','How do you say "It is cold"?','Hace frío',array['Es frío','Está frío','Tiene frío'],'It is cold [AH-seh FREE-oh]',5),
    (v_lesson_id,'multiple_choice','How do you say "wind"?','viento',array['vino','viaje','vidrio'],'Wind [BYEHN-toh]',6),
    (v_lesson_id,'multiple_choice','How do you say "rain (noun)"?','la lluvia',array['el llover','la llover','la lluvioso'],'Rain [YOO-byah]',7),
    (v_lesson_id,'multiple_choice','How do you say "snow (noun)"?','la nieve',array['el nieve','el nevar','la nevazón'],'Snow [NYEH-beh]',8),
    (v_lesson_id,'multiple_choice','How do you say "cloudy"?','nublado',array['nubla','nublo','nuboso también'],'Cloudy [noo-BLAH-doh]',9),
    (v_lesson_id,'multiple_choice','How do you say "clear (sky)"?','despejado',array['claro','descubierto','despierto'],'Clear [dehs-peh-HAH-doh]',10),
    (v_lesson_id,'multiple_choice','How do you say "storm"?','tormenta',array['tornado también','tempo','tormento'],'Storm [tohr-MEHN-tah]',11),
    (v_lesson_id,'multiple_choice','How do you say "fog"?','niebla',array['nieve','nube','nuca'],'Fog [NYEH-blah]',12),
    (v_lesson_id,'multiple_choice','How do you say "lightning"?','el relámpago',array['el trueno','el rayo también','la luz'],'Lightning [reh-LAHM-pah-goh]',13),
    (v_lesson_id,'multiple_choice','How do you say "thunder"?','el trueno',array['el relámpago','el ruido','el truenazo'],'Thunder [TRWEH-noh]',14),
    (v_lesson_id,'multiple_choice','How do you say "temperature"?','la temperatura',array['el termómetro','la temperada','el tempo'],'Temperature [tehm-peh-rah-TOO-rah]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','hace mucho frío',array['hace mucho calor','hace mucho sol','tengo mucho frío'],'It is very cold',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','llueve mucho',array['nieva mucho','llueve poco','llover mucho'],'It rains a lot',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','está nublado',array['está despejado','hace nube','están nublados'],'It is cloudy',18),
    (v_lesson_id,'speaking','Say "It is sunny" in Spanish.','Hace sol',array[]::text[],'Hace sol [AH-seh SOHL]',19),
    (v_lesson_id,'speaking','Say "It is raining" in Spanish.','Llueve',array[]::text[],'Llueve [YWEH-beh]',20),
    (v_lesson_id,'fill_blank','Complete: "Hace ___ hoy." (It is hot today.)','calor',array['frío','sol','viento'],'hot',21),
    (v_lesson_id,'fill_blank','Complete: "Hoy ___ mucho." (It is raining a lot today.)','llueve',array['nieva','sol','viento'],'it rains',22);

  -- Lesson 2: seasons
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Weather — Lesson 2', 'Seasons and climate.', 'vocabulary', 2, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "spring"?','la primavera',array['el verano','el otoño','el invierno'],'Spring [pree-mah-BEH-rah]',1),
    (v_lesson_id,'multiple_choice','How do you say "summer"?','el verano',array['el invierno','el otoño','la primavera'],'Summer [beh-RAH-noh]',2),
    (v_lesson_id,'multiple_choice','How do you say "autumn / fall"?','el otoño',array['el invierno','el verano','la primavera'],'Autumn [oh-TOH-nyoh]',3),
    (v_lesson_id,'multiple_choice','How do you say "winter"?','el invierno',array['el otoño','el verano','la primavera'],'Winter [een-BYEHR-noh]',4),
    (v_lesson_id,'multiple_choice','How do you say "the season"?','la estación',array['la temporada también','el tiempo','el clima'],'The season [ehs-tah-SYOHN]',5),
    (v_lesson_id,'multiple_choice','Translate "Hace calor en verano."','It is hot in summer',array['It is cold in summer','It rains in summer','I am hot in summer'],'It is hot in summer',6),
    (v_lesson_id,'multiple_choice','Translate "Nieva en invierno."','It snows in winter',array['It rains in winter','It is cold in winter','It is sunny in winter'],'It snows in winter',7),
    (v_lesson_id,'multiple_choice','How do you say "the weather is nice"?','hace buen tiempo',array['hace mal tiempo','está buen tiempo','es buen tiempo'],'The weather is nice [BWEHN TYEHM-poh]',8),
    (v_lesson_id,'multiple_choice','How do you say "the weather is bad"?','hace mal tiempo',array['hace buen tiempo','está mal tiempo','es mal tiempo'],'The weather is bad',9),
    (v_lesson_id,'multiple_choice','How do you ask "What is the weather like?"','¿Qué tiempo hace?',array['¿Cómo está el tiempo?','¿Cuál es el tiempo?','¿Qué hace el tiempo?'],'What is the weather like?',10),
    (v_lesson_id,'multiple_choice','How do you say "umbrella"?','el paraguas',array['el sombrero','la sombrilla','el paraguas roto'],'Umbrella [pah-RAH-gwahs]',11),
    (v_lesson_id,'multiple_choice','How do you say "coat"?','el abrigo',array['la chaqueta','el suéter','la camisa'],'Coat [ah-BREE-goh]',12),
    (v_lesson_id,'multiple_choice','How do you say "sunglasses"?','las gafas de sol',array['los lentes (LatAm)','los anteojos (LatAm)','las gafas'],'Sunglasses [GAH-fahs deh SOHL]',13),
    (v_lesson_id,'multiple_choice','How do you say "scarf"?','la bufanda',array['el bufete','la banda','la bocina'],'Scarf [boo-FAHN-dah]',14),
    (v_lesson_id,'multiple_choice','Translate "Llueve mucho en otoño."','It rains a lot in autumn',array['It rains a little in autumn','It is sunny in autumn','It is windy in autumn'],'It rains a lot in autumn',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','en verano',array['en invierno','en otoño','en primavera'],'In summer',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','hace buen tiempo',array['hace mal tiempo','hace frío','hace sol'],'The weather is nice',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','necesito un paraguas',array['necesito un abrigo','necesito una bufanda','necesito gafas'],'I need an umbrella',18),
    (v_lesson_id,'speaking','Say "It is cold in winter" in Spanish.','Hace frío en invierno',array[]::text[],'Hace frío en invierno',19),
    (v_lesson_id,'speaking','Say "What is the weather like?" in Spanish.','¿Qué tiempo hace?',array[]::text[],'¿Qué tiempo hace?',20),
    (v_lesson_id,'fill_blank','Complete: "Nieva en ___" (It snows in winter.)','invierno',array['verano','otoño','primavera'],'winter',21),
    (v_lesson_id,'fill_blank','Complete: "Hace ___ tiempo." (The weather is nice.)','buen',array['mal','bueno','malo'],'good (apocopated)',22);

  -- Lesson 3: weather forecast (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Weather — Lesson 3', 'Understand a simple forecast.', 'listening', 3, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "tomorrow it will rain"?','Mañana va a llover',array['Mañana llover','Mañana llovió','Mañana es lluvia'],'Tomorrow it will rain',1),
    (v_lesson_id,'multiple_choice','How do you say "today there is a storm"?','Hoy hay tormenta',array['Hoy es tormenta','Hoy hace tormenta','Hoy está tormenta'],'Today there is a storm',2),
    (v_lesson_id,'multiple_choice','How do you say "It is twenty degrees"?','Hace veinte grados',array['Son veinte grados también','Es veinte grados','Tiene veinte grados'],'It is 20 degrees [GRAH-dohs]',3),
    (v_lesson_id,'multiple_choice','How do you say "below zero"?','bajo cero',array['cero abajo','de cero','menos cero'],'Below zero [BAH-hoh SEH-roh]',4),
    (v_lesson_id,'multiple_choice','How do you say "humid"?','húmedo',array['mojado','seco','helado'],'Humid [OO-meh-doh]',5),
    (v_lesson_id,'multiple_choice','How do you say "dry"?','seco',array['húmedo','mojado','suelto'],'Dry [SEH-koh]',6),
    (v_lesson_id,'multiple_choice','How do you say "warm"?','templado',array['cálido también','tibio','tempo'],'Warm [tehm-PLAH-doh]',7),
    (v_lesson_id,'multiple_choice','How do you say "freezing"?','helado',array['frío','frigorífico','frescos'],'Freezing [eh-LAH-doh]',8),
    (v_lesson_id,'multiple_choice','Translate "El cielo está despejado."','The sky is clear',array['The sky is cloudy','The day is bad','The night is dark'],'The sky is clear',9),
    (v_lesson_id,'multiple_choice','Translate "Va a hacer sol mañana."','It is going to be sunny tomorrow',array['It will rain tomorrow','It is sunny today','It was sunny yesterday'],'It is going to be sunny tomorrow',10),
    (v_lesson_id,'multiple_choice','How do you say "It is windy"?','Hace viento',array['Es viento','Está viento','Tiene viento'],'It is windy [AH-seh BYEHN-toh]',11),
    (v_lesson_id,'multiple_choice','How do you say "the forecast"?','el pronóstico',array['la profecía','el promedio','el pronto'],'The forecast [proh-NOHS-tee-koh]',12),
    (v_lesson_id,'multiple_choice','How do you say "I am cold"?','Tengo frío',array['Soy frío','Estoy frío','Hace frío'],'I am cold (person) [TEHN-goh FREE-oh]',13),
    (v_lesson_id,'multiple_choice','How do you say "I am hot"?','Tengo calor',array['Soy calor','Estoy calor','Hace calor'],'I am hot (person)',14),
    (v_lesson_id,'multiple_choice','Translate "El clima es agradable."','The climate is pleasant',array['The climate is bad','The climate is hot','The climate is humid'],'The climate is pleasant',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','mañana va a llover',array['mañana va a nevar','hoy llueve','ayer llovió'],'Tomorrow it will rain',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','hace veinte grados',array['hace doce grados','son veinte grados','hace veintidós grados'],'It is 20 degrees',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','tengo frío',array['tengo calor','tengo sed','tengo hambre'],'I am cold',18),
    (v_lesson_id,'speaking','Say "I am cold" in Spanish.','Tengo frío',array[]::text[],'Tengo frío',19),
    (v_lesson_id,'speaking','Say "It is going to rain tomorrow" in Spanish.','Mañana va a llover',array[]::text[],'Mañana va a llover',20),
    (v_lesson_id,'fill_blank','Complete: "Hace ___ grados." (It is 30 degrees.)','treinta',array['trece','treinta y','tres'],'thirty',21),
    (v_lesson_id,'fill_blank','Complete: "Hoy hay ___" (Today there is fog.)','niebla',array['nieve','viento','lluvia'],'fog',22);

  -- Lesson 4: weather conversation
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Weather — Lesson 4', 'Chat about the weather.', 'speaking', 4, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "What a nice day!"','¡Qué buen día!',array['¡Qué día buen!','¡Cómo buen día!','¡Cuál día bueno!'],'What a nice day!',1),
    (v_lesson_id,'multiple_choice','How do you say "It is raining cats and dogs"?','Llueve a cántaros',array['Llueve a gatos','Llueve mucho perros','Llueve canta'],'It is pouring [KAHN-tah-rohs]',2),
    (v_lesson_id,'multiple_choice','How do you ask "Is it going to snow?"','¿Va a nevar?',array['¿Nieva va?','¿Es nevar?','¿Nevará va?'],'Is it going to snow?',3),
    (v_lesson_id,'multiple_choice','How do you say "I prefer summer"?','Prefiero el verano',array['Prefero el verano','Preferir verano','Yo prefiero verano'],'I prefer summer',4),
    (v_lesson_id,'multiple_choice','How do you say "It is cool / chilly"?','Hace fresco',array['Está fresco','Es fresco','Tiene fresco'],'It is cool [FREHS-koh]',5),
    (v_lesson_id,'multiple_choice','How do you say "Take a coat"?','Lleva un abrigo',array['Toma abrigo','Coge un abrigo también','Pone un abrigo'],'Take a coat',6),
    (v_lesson_id,'multiple_choice','How do you say "It looks like rain"?','Parece que va a llover',array['Es lluvia','Mira lluvia','Quiere llover'],'It looks like rain',7),
    (v_lesson_id,'multiple_choice','How do you say "the weather changes"?','el tiempo cambia',array['el tiempo es','el tiempo va','el tiempo hace'],'The weather changes',8),
    (v_lesson_id,'multiple_choice','How do you say "drizzle"?','llovizna',array['lluvia','llanto','lloro'],'Drizzle [yoh-BEES-nah]',9),
    (v_lesson_id,'multiple_choice','How do you say "hail"?','granizo',array['granito','granuja','grande'],'Hail [grah-NEE-soh]',10),
    (v_lesson_id,'multiple_choice','Translate "Hace un día estupendo."','It is a wonderful day',array['It is a normal day','It is a bad day','It is an empty day'],'It is a wonderful day',11),
    (v_lesson_id,'multiple_choice','How do you say "the wind is strong"?','el viento es fuerte',array['el viento está fuerte también','el viento tiene fuerte','el viento hace fuerte'],'The wind is strong',12),
    (v_lesson_id,'multiple_choice','How do you say "muggy"?','bochornoso',array['caliente','vapor','muggy'],'Muggy [boh-chohr-NOH-soh]',13),
    (v_lesson_id,'multiple_choice','Translate "Está empezando a llover."','It is starting to rain',array['It just rained','It rained yesterday','It will not rain'],'It is starting to rain',14),
    (v_lesson_id,'multiple_choice','How do you say "I love sunny days"?','Me encantan los días soleados',array['Me gusta días soleados','Yo amo soleados','Quiero días soleados'],'I love sunny days',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','prefiero el verano',array['prefiero el invierno','prefiero el otoño','prefiero la primavera'],'I prefer summer',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','va a nevar mañana',array['va a llover mañana','nevó ayer','va a hacer sol'],'It is going to snow tomorrow',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','hace fresco',array['hace frío','hace calor','hace seco'],'It is cool',18),
    (v_lesson_id,'speaking','Say "I prefer winter" in Spanish.','Prefiero el invierno',array[]::text[],'Prefiero el invierno',19),
    (v_lesson_id,'speaking','Say "What a nice day!" in Spanish.','¡Qué buen día!',array[]::text[],'¡Qué buen día!',20),
    (v_lesson_id,'fill_blank','Complete: "Prefiero el ___" (I prefer summer.)','verano',array['invierno','otoño','primavera'],'summer',21),
    (v_lesson_id,'fill_blank','Complete: "¡Qué ___ día!" (What a nice day!)','buen',array['bueno','mal','muy'],'good (apocopated)',22);

  -- =================== A1.8 SHOPPING ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Shopping', 'Buy, pay and ask about prices in Spanish.', 'A1', 8)
  returning id into v_course_id;

  -- Lesson 1: store + money vocabulary
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Shopping — Lesson 1', 'Store, money and price basics.', 'vocabulary', 1, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "store / shop"?','la tienda',array['el tendero','el mercado','la tarjeta'],'Store [TYEHN-dah]',1),
    (v_lesson_id,'multiple_choice','How do you say "to buy"?','comprar',array['vender','pagar','llevar'],'To buy [kohm-PRAHR]',2),
    (v_lesson_id,'multiple_choice','How do you say "to sell"?','vender',array['comprar','pagar','ver'],'To sell [behn-DEHR]',3),
    (v_lesson_id,'multiple_choice','How do you say "money"?','dinero',array['precio','cambio','euros'],'Money [dee-NEH-roh]',4),
    (v_lesson_id,'multiple_choice','How do you say "price"?','precio',array['precioso','dinero','pesado'],'Price [PREH-syoh]',5),
    (v_lesson_id,'multiple_choice','How do you say "expensive"?','caro',array['barato','cariño','carro'],'Expensive [KAH-roh]',6),
    (v_lesson_id,'multiple_choice','How do you say "cheap"?','barato',array['caro','bajo','barril'],'Cheap [bah-RAH-toh]',7),
    (v_lesson_id,'multiple_choice','How do you say "discount"?','descuento',array['recuento','cuento','descontento'],'Discount [dehs-KWEHN-toh]',8),
    (v_lesson_id,'multiple_choice','How do you say "card"?','tarjeta',array['carta','tarjet','tarea'],'Card [tahr-HEH-tah]',9),
    (v_lesson_id,'multiple_choice','How do you say "cash"?','efectivo',array['efecto','efectivamente','dinero'],'Cash [eh-fehk-TEE-boh]',10),
    (v_lesson_id,'multiple_choice','How do you say "receipt"?','recibo',array['recibir','recipiente','reciclar'],'Receipt [reh-SEE-boh]',11),
    (v_lesson_id,'multiple_choice','How do you say "market"?','el mercado',array['la marca','el merc','la merced'],'Market [mehr-KAH-doh]',12),
    (v_lesson_id,'multiple_choice','How do you say "bag"?','la bolsa',array['la bolla','la bola','el bolso'],'Bag [BOHL-sah]',13),
    (v_lesson_id,'multiple_choice','How do you say "to pay"?','pagar',array['pegar','pasar','plegar'],'To pay [pah-GAHR]',14),
    (v_lesson_id,'multiple_choice','How do you say "the change (money back)"?','el cambio',array['la moneda','el dinero','la vuelta también'],'The change [KAHM-byoh]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','¿cuánto cuesta?',array['¿cuántos años?','¿cuándo?','¿cuál es?'],'How much does it cost?',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','pago con tarjeta',array['pago en efectivo','pagar con tarjeta','pagaré con tarjeta'],'I pay by card',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','es muy caro',array['es muy barato','no es caro','está muy caro'],'It is very expensive',18),
    (v_lesson_id,'speaking','Say "How much does it cost?" in Spanish.','¿Cuánto cuesta?',array[]::text[],'¿Cuánto cuesta?',19),
    (v_lesson_id,'speaking','Say "I pay by card" in Spanish.','Pago con tarjeta',array[]::text[],'Pago con tarjeta',20),
    (v_lesson_id,'fill_blank','Complete: "Quiero ___" (I want to buy.)','comprar',array['vender','pagar','tener'],'to buy',21),
    (v_lesson_id,'fill_blank','Complete: "Es muy ___" (It is very expensive.)','caro',array['barato','grande','poco'],'expensive',22);

  -- Lesson 2: clothes
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Shopping — Lesson 2', 'Clothes, sizes and trying things on.', 'phrases', 2, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "shirt"?','la camisa',array['la camiseta','la chaqueta','la falda'],'Shirt [kah-MEE-sah]',1),
    (v_lesson_id,'multiple_choice','How do you say "trousers / pants"?','los pantalones',array['los zapatos','los calcetines','los abrigos'],'Trousers [pahn-tah-LOH-nehs]',2),
    (v_lesson_id,'multiple_choice','How do you say "skirt"?','la falda',array['el vestido','la camisa','el sombrero'],'Skirt [FAHL-dah]',3),
    (v_lesson_id,'multiple_choice','How do you say "dress"?','el vestido',array['la falda','la camisa','la chaqueta'],'Dress [behs-TEE-doh]',4),
    (v_lesson_id,'multiple_choice','How do you say "shoes"?','los zapatos',array['las botas','las medias','los pies'],'Shoes [sah-PAH-tohs]',5),
    (v_lesson_id,'multiple_choice','How do you say "jacket"?','la chaqueta',array['el abrigo','la camisa','el suéter'],'Jacket [chah-KEH-tah]',6),
    (v_lesson_id,'multiple_choice','How do you say "hat"?','el sombrero',array['la gorra','el casco','la sombra'],'Hat [sohm-BREH-roh]',7),
    (v_lesson_id,'multiple_choice','How do you say "size (clothing)"?','la talla',array['el tamaño','la talla grande','la talla mediana'],'Size [TAH-yah]',8),
    (v_lesson_id,'multiple_choice','How do you say "small (size)"?','pequeño',array['poco','chico también','pero pequeño'],'Small [peh-KEH-nyoh]',9),
    (v_lesson_id,'multiple_choice','How do you say "medium (size)"?','mediano',array['mediana','medio','mejor'],'Medium [meh-DYAH-noh]',10),
    (v_lesson_id,'multiple_choice','How do you say "large (size)"?','grande',array['grandeza','grandísimo','gran'],'Large [GRAHN-deh]',11),
    (v_lesson_id,'multiple_choice','How do you ask "Can I try it on?"','¿Puedo probármelo?',array['¿Puedo verlo?','¿Puedo comprarlo?','¿Puedo llevarlo?'],'Can I try it on? [PWEH-doh proh-BAHR-meh-loh]',12),
    (v_lesson_id,'multiple_choice','How do you say "the dressing room"?','el probador',array['la prueba','la habitación','el cuarto'],'The dressing room [proh-bah-DOHR]',13),
    (v_lesson_id,'multiple_choice','How do you say "It fits me"?','Me queda bien',array['Me caigo bien','Me gusta','Me sirve'],'It fits me [meh KEH-dah BYEHN]',14),
    (v_lesson_id,'multiple_choice','How do you say "It is too tight"?','Está muy apretado',array['Es muy estrecho','Hay aprieto','Tiene aprieto'],'It is too tight [ah-preh-TAH-doh]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','¿qué talla usas?',array['¿qué tienes?','¿qué tela usas?','¿qué talla tiene?'],'What size do you use?',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','me queda bien',array['me queda mal','me cae bien','me gusta bien'],'It fits me',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','quiero probarme la falda',array['quiero comprar la falda','quiero la falda','quiero probarme la camisa'],'I want to try on the skirt',18),
    (v_lesson_id,'speaking','Say "Can I try it on?" in Spanish.','¿Puedo probármelo?',array[]::text[],'¿Puedo probármelo?',19),
    (v_lesson_id,'speaking','Say "It fits me well" in Spanish.','Me queda bien',array[]::text[],'Me queda bien',20),
    (v_lesson_id,'fill_blank','Complete: "Uso la talla ___" (I wear medium.)','mediana',array['grande','pequeña','grandes'],'medium',21),
    (v_lesson_id,'fill_blank','Complete: "Me queda muy ___" (It fits me very well.)','bien',array['mal','grande','poco'],'well',22);

  -- Lesson 3: bargaining (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Shopping — Lesson 3', 'Bargaining, paying and getting change.', 'listening', 3, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "Do you have a smaller size?"','¿Tienes una talla más pequeña?',array['¿Hay otra talla?','¿Es otra talla?','¿Cuál es la talla?'],'Do you have a smaller size?',1),
    (v_lesson_id,'multiple_choice','How do you say "Do you accept cards?"','¿Aceptan tarjetas?',array['¿Tienen tarjetas?','¿Usan tarjetas?','¿Aceptan tarjeta?'],'Do you accept cards?',2),
    (v_lesson_id,'multiple_choice','How do you say "Can I have a discount?"','¿Me hace un descuento?',array['¿Tiene descuento?','¿Hay descuento?','¿Me cuenta menos?'],'Can I have a discount?',3),
    (v_lesson_id,'multiple_choice','Translate "Aquí tiene su cambio."','Here is your change',array['Here is your card','Here is your bag','Here is your bill'],'Here is your change',4),
    (v_lesson_id,'multiple_choice','How do you say "It is on sale"?','Está en oferta',array['Es en oferta','Tiene oferta','Hay oferta'],'It is on sale [oh-FEHR-tah]',5),
    (v_lesson_id,'multiple_choice','How do you say "free / gratis"?','gratis',array['gratos','grato','gracias'],'Free [GRAH-tees]',6),
    (v_lesson_id,'multiple_choice','How do you say "two for one"?','dos por uno',array['dos al uno','dos en uno','dos por dos'],'Two for one',7),
    (v_lesson_id,'multiple_choice','How do you say "I will take it"?','Me lo llevo',array['Lo compro','Lo tomo','Lo voy'],'I will take it [meh loh YEH-boh]',8),
    (v_lesson_id,'multiple_choice','How do you ask "How much in total?"','¿Cuánto es en total?',array['¿Cuánto cuesta total?','¿Cuál es total?','¿Cuánto el total?'],'How much in total?',9),
    (v_lesson_id,'multiple_choice','Translate "Son cincuenta euros."','It is fifty euros',array['It costs five euros','I have fifty euros','Fifty euros each'],'It is fifty euros',10),
    (v_lesson_id,'multiple_choice','How do you say "out of stock"?','agotado',array['acabado','listo','vendido'],'Out of stock [ah-goh-TAH-doh]',11),
    (v_lesson_id,'multiple_choice','How do you say "Can I return this?"','¿Puedo devolver esto?',array['¿Puedo cambiar?','¿Puedo regresar?','¿Puedo dar esto?'],'Can I return this? [deh-bohl-BEHR]',12),
    (v_lesson_id,'multiple_choice','How do you say "the receipt"?','el ticket',array['el papel','el recibo también','el dinero'],'Receipt [TEE-keht]',13),
    (v_lesson_id,'multiple_choice','How do you say "Anything else?"','¿Algo más?',array['¿Cómo más?','¿Cuánto más?','¿Algo otro?'],'Anything else? [AHL-goh MAHS]',14),
    (v_lesson_id,'multiple_choice','How do you say "No, that is all"?','No, eso es todo',array['No, todo está','No es esto','No, todo es'],'No, that is all',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','aceptamos tarjeta',array['aceptamos cheques','aceptamos efectivo','no aceptamos tarjeta'],'We accept cards',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','está en oferta',array['no está en oferta','está caro','está abierto'],'It is on sale',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','me lo llevo',array['me lo tomo','no me lo llevo','me lo dejo'],'I will take it',18),
    (v_lesson_id,'speaking','Say "Do you accept cards?" in Spanish.','¿Aceptan tarjetas?',array[]::text[],'¿Aceptan tarjetas?',19),
    (v_lesson_id,'speaking','Say "I will take it" in Spanish.','Me lo llevo',array[]::text[],'Me lo llevo',20),
    (v_lesson_id,'fill_blank','Complete: "Aquí tiene su ___" (Here is your change.)','cambio',array['recibo','tarjeta','dinero'],'change',21),
    (v_lesson_id,'fill_blank','Complete: "Está en ___" (It is on sale.)','oferta',array['venta','barato','descuento'],'sale',22);

  -- Lesson 4: speaking at the cash register
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Shopping — Lesson 4', 'Speak through a checkout interaction.', 'speaking', 4, 10)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "I am looking for..."','Estoy buscando...',array['Estoy mirando','Estoy comprando','Estoy buscar'],'I am looking for... [bus-KAHN-doh]',1),
    (v_lesson_id,'multiple_choice','How do you say "Can you help me?"','¿Me puede ayudar?',array['¿Ayudas?','¿Me ayuda?','¿Puede ayuda?'],'Can you help me? [ah-yoo-DAHR]',2),
    (v_lesson_id,'multiple_choice','How do you say "Just looking, thanks"?','Solo estoy mirando, gracias',array['Solo veo, gracias','Solo busco, gracias','Solo aquí, gracias'],'Just looking, thanks',3),
    (v_lesson_id,'multiple_choice','How do you say "Do you have this in red?"','¿Tienes esto en rojo?',array['¿Hay esto rojo?','¿Tiene rojo esto?','¿Tienes esto rojos?'],'Do you have this in red?',4),
    (v_lesson_id,'multiple_choice','How do you say "Where is the cash register?"','¿Dónde está la caja?',array['¿Cómo está la caja?','¿Dónde es caja?','¿Cuál es la caja?'],'Where is the cash register? [KAH-hah]',5),
    (v_lesson_id,'multiple_choice','How do you say "Open / Closed"?','Abierto / Cerrado',array['Listo / No listo','Activo / Inactivo','Sí / No'],'Open / Closed [ah-BYEHR-toh / seh-RRAH-doh]',6),
    (v_lesson_id,'multiple_choice','How do you say "What time do you close?"','¿A qué hora cierran?',array['¿Cuándo cierra?','¿Cuál hora cierran?','¿Qué hora?'],'What time do you close?',7),
    (v_lesson_id,'multiple_choice','How do you say "the bakery"?','la panadería',array['la pastelería','el panadero','el pan'],'Bakery [pah-nah-deh-REE-ah]',8),
    (v_lesson_id,'multiple_choice','How do you say "the pharmacy"?','la farmacia',array['el farmacéutico','la farmacéutica','el doctor'],'Pharmacy [fahr-MAH-syah]',9),
    (v_lesson_id,'multiple_choice','How do you say "the supermarket"?','el supermercado',array['el mercado','el centro','el mercadillo'],'Supermarket [soo-pehr-mehr-KAH-doh]',10),
    (v_lesson_id,'multiple_choice','How do you say "Excuse me, where is...?"','Disculpe, ¿dónde está...?',array['Perdón, ¿qué está?','¿Dónde es?','Por favor, ¿cómo está?'],'Excuse me, where is...?',11),
    (v_lesson_id,'multiple_choice','How do you say "next to..."?','al lado de...',array['en lado de','sobre','enfrente de'],'Next to... [ahl LAH-doh deh]',12),
    (v_lesson_id,'multiple_choice','How do you say "I would like a coffee, please"?','Quisiera un café, por favor',array['Queremos un café','Quiero un café','Tomo un café'],'I would like a coffee, please',13),
    (v_lesson_id,'multiple_choice','How do you say "Keep the change"?','Quédese con el cambio',array['Lleva el cambio','Tome el cambio','Guarde el cambio'],'Keep the change [KEH-deh-seh kohn ehl KAHM-byoh]',14),
    (v_lesson_id,'multiple_choice','How do you say "Thanks, see you tomorrow"?','Gracias, hasta mañana',array['Gracias, adiós','Gracias, hasta luego','Gracias, hola'],'Thanks, see you tomorrow',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','¿me puede ayudar?',array['¿me puede ver?','¿puede ayudar?','¿me dice?'],'Can you help me?',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','solo estoy mirando',array['solo estoy comprando','solo estoy aquí','estoy solo mirando'],'I am just looking',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','¿a qué hora cierran?',array['¿a qué hora abren?','¿qué hora es?','¿cuándo cierran?'],'What time do you close?',18),
    (v_lesson_id,'speaking','Say "I am looking for a shirt" in Spanish.','Estoy buscando una camisa',array[]::text[],'Estoy buscando una camisa',19),
    (v_lesson_id,'speaking','Say "Can you help me, please?" in Spanish.','¿Me puede ayudar, por favor?',array[]::text[],'¿Me puede ayudar, por favor?',20),
    (v_lesson_id,'fill_blank','Complete: "Estoy ___" (I am looking for...)','buscando',array['mirando','comprando','vendiendo'],'looking for',21),
    (v_lesson_id,'fill_blank','Complete: "¿Dónde está la ___?" (Where is the cash register?)','caja',array['cuenta','tarjeta','bolsa'],'cash register',22);

  -- =================== A1 ARTICLE ===================
  insert into public.articles (language_id, slug, title, title_english, level, reading_minutes, content_target, content_english, order_index)
  values (
    v_lang_id,
    'a1-un-dia-en-el-mercado',
    'Un día en el mercado',
    'A Day at the Market',
    'A1',
    2,
    E'Es sábado por la mañana. Hace sol y no llueve. Ana va al mercado con su madre. En el mercado hay muchas tiendas y mucha gente.\n\nAna compra dos manzanas rojas, un kilo de tomates y un poco de queso. Su madre compra pan y leche. También compran pescado para la cena.\n\n— ¿Cuánto cuesta? — pregunta Ana.\n— Son diez euros — dice el vendedor.\n\nAna paga con tarjeta y dice gracias. El vendedor sonríe y le da una bolsa grande. Ahora pueden volver a casa. Hoy van a comer una sopa de verduras y una ensalada con tomate. ¡Qué buen día!',
    E'It is Saturday morning. It is sunny and it is not raining. Ana goes to the market with her mother. At the market there are many stores and many people.\n\nAna buys two red apples, a kilo of tomatoes and a little cheese. Her mother buys bread and milk. They also buy fish for dinner.\n\n"How much does it cost?" asks Ana.\n"It is ten euros," says the seller.\n\nAna pays with a card and says thank you. The seller smiles and gives her a big bag. Now they can go home. Today they are going to eat vegetable soup and a salad with tomato. What a nice day!',
    1
  );

end $$;

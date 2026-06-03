-- 017_spanish_a1_teaching.sql
-- Adds a teaching phase to every Spanish A1 lesson so users LEARN before they test.
--
-- Schema: adds 4 columns to public.lessons:
--   intro          text          — short framing for the lesson
--   vocab_items    jsonb         — array of {word, phonetic, english, example_es, example_en}
--   dialogue       jsonb         — array of {speaker, spanish, english}
--   grammar_note   text          — short note on the grammar pattern of the lesson
--
-- Content: populates these fields for all 15 A1 sections × 7 substantive lessons
-- (lesson 8 stays as the podcast placeholder; no teaching content needed there).
-- Pair this migration with the LessonClient UI update that walks intro → vocab →
-- dialogue → grammar → exercises.

alter table public.lessons add column if not exists intro text;
alter table public.lessons add column if not exists vocab_items jsonb default '[]'::jsonb;
alter table public.lessons add column if not exists dialogue jsonb default '[]'::jsonb;
alter table public.lessons add column if not exists grammar_note text;

do $$
declare
  v_lang_id    bigint;
  v_course_id  bigint;
  v_l1 bigint; v_l2 bigint; v_l3 bigint; v_l4 bigint;
  v_l5 bigint; v_l6 bigint; v_l7 bigint;
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

  update public.lessons set
    intro = 'In this lesson you will learn how to greet people in Spanish at different times of the day, plus the most common words to say hello and goodbye.',
    vocab_items = '[
      {"word":"Hola","phonetic":"[OH-lah]","english":"Hello / Hi","example_es":"¡Hola, María!","example_en":"Hi, María!"},
      {"word":"Buenos días","phonetic":"[BWEH-nohs DEE-ahs]","english":"Good morning","example_es":"Buenos días, profesor.","example_en":"Good morning, teacher."},
      {"word":"Buenas tardes","phonetic":"[BWEH-nahs TAR-dehs]","english":"Good afternoon","example_es":"Buenas tardes, señora.","example_en":"Good afternoon, ma''am."},
      {"word":"Buenas noches","phonetic":"[BWEH-nahs NOH-chehs]","english":"Good evening / Good night","example_es":"Buenas noches, papá.","example_en":"Good night, dad."},
      {"word":"Adiós","phonetic":"[ah-DYOHS]","english":"Goodbye","example_es":"Adiós, hasta mañana.","example_en":"Goodbye, see you tomorrow."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Ana","spanish":"¡Hola, Carlos!","english":"Hi, Carlos!"},
      {"speaker":"Carlos","spanish":"¡Buenos días, Ana! ¿Cómo estás?","english":"Good morning, Ana! How are you?"},
      {"speaker":"Ana","spanish":"Muy bien, gracias. ¿Y tú?","english":"Very well, thanks. And you?"},
      {"speaker":"Carlos","spanish":"Bien también. ¡Hasta luego!","english":"Good too. See you later!"}
    ]'::jsonb,
    grammar_note = 'Spanish greetings change with the time of day: buenos días (morning), buenas tardes (afternoon), buenas noches (evening / night). Note that buenas is feminine plural because tardes and noches are feminine nouns.'
  where id = v_l1;

  update public.lessons set
    intro = 'Spanish has two ways to say "you": informal tú (with friends, family, kids) and formal usted (with strangers, elders, work). Each one changes the verb.',
    vocab_items = '[
      {"word":"tú","phonetic":"[TOO]","english":"you (informal)","example_es":"¿Cómo estás (tú)?","example_en":"How are you?"},
      {"word":"usted","phonetic":"[oos-TEHD]","english":"you (formal)","example_es":"¿Cómo está usted?","example_en":"How are you, sir/ma''am?"},
      {"word":"señor","phonetic":"[seh-NYOHR]","english":"Sir / Mr.","example_es":"Buenos días, señor.","example_en":"Good morning, sir."},
      {"word":"señora","phonetic":"[seh-NYOH-rah]","english":"Ma''am / Mrs.","example_es":"Buenas tardes, señora.","example_en":"Good afternoon, ma''am."},
      {"word":"¿Cómo está?","phonetic":"[KOH-moh ehs-TAH]","english":"How are you? (formal)","example_es":"Disculpe, ¿cómo está?","example_en":"Excuse me, how are you?"}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Pedro","spanish":"Buenos días, señor García.","english":"Good morning, Mr. García."},
      {"speaker":"Sr. García","spanish":"Buenos días, Pedro. ¿Cómo está usted?","english":"Good morning, Pedro. How are you?"},
      {"speaker":"Pedro","spanish":"Muy bien, gracias. ¿Y usted?","english":"Very well, thank you. And you?"},
      {"speaker":"Sr. García","spanish":"Bien, gracias. Hasta luego.","english":"Fine, thanks. See you later."}
    ]'::jsonb,
    grammar_note = 'With tú the verb estás ends in -ás: ¿Cómo estás? With usted the verb está ends in -á: ¿Cómo está? Use tú with people your age or younger; use usted with adults you don''t know well or in professional settings.'
  where id = v_l2;

  update public.lessons set
    intro = 'These are the everyday phrases native speakers use to start and end a conversation. Knowing them makes you sound natural from day one.',
    vocab_items = '[
      {"word":"¿Cómo estás?","phonetic":"[KOH-moh ehs-TAHS]","english":"How are you?","example_es":"Hola, ¿cómo estás?","example_en":"Hi, how are you?"},
      {"word":"Bien, gracias","phonetic":"[BYEHN GRAH-syahs]","english":"Fine, thanks","example_es":"Bien, gracias. ¿Y tú?","example_en":"Fine, thanks. And you?"},
      {"word":"Mucho gusto","phonetic":"[MOO-choh GOOS-toh]","english":"Pleased to meet you","example_es":"Mucho gusto, soy Ana.","example_en":"Pleased to meet you, I''m Ana."},
      {"word":"Encantado","phonetic":"[ehn-kahn-TAH-doh]","english":"Nice to meet you (m.)","example_es":"Encantado de conocerte.","example_en":"Nice to meet you."},
      {"word":"Hasta luego","phonetic":"[AHS-tah LWEH-goh]","english":"See you later","example_es":"Hasta luego, Marta.","example_en":"See you later, Marta."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Luis","spanish":"Hola, soy Luis. ¿Y tú?","english":"Hi, I''m Luis. And you?"},
      {"speaker":"Sara","spanish":"Soy Sara. Mucho gusto.","english":"I''m Sara. Pleased to meet you."},
      {"speaker":"Luis","spanish":"Encantado. ¿Cómo estás?","english":"Nice to meet you. How are you?"},
      {"speaker":"Sara","spanish":"Bien, gracias. ¡Hasta luego!","english":"Good, thanks. See you later!"}
    ]'::jsonb,
    grammar_note = 'Encantado / encantada changes form by gender: men say encantado, women say encantada. Mucho gusto is gender-neutral so it''s safe to use either way.'
  where id = v_l3;

  update public.lessons set
    intro = 'Greetings sound a little different when spoken quickly. In this lesson you will train your ear to recognize them in real conversation.',
    vocab_items = '[
      {"word":"¡Hola!","phonetic":"[OH-lah]","english":"Hi!","example_es":"¡Hola, ¿qué tal?","example_en":"Hi, how''s it going?"},
      {"word":"¿Qué tal?","phonetic":"[keh TAHL]","english":"How''s it going?","example_es":"¡Hola! ¿Qué tal?","example_en":"Hi! How''s it going?"},
      {"word":"Muy bien","phonetic":"[mwee BYEHN]","english":"Very well","example_es":"Muy bien, gracias.","example_en":"Very well, thanks."},
      {"word":"Más o menos","phonetic":"[MAHS oh MEH-nohs]","english":"So-so","example_es":"Más o menos, cansado.","example_en":"So-so, tired."},
      {"word":"Nos vemos","phonetic":"[nohs BEH-mohs]","english":"See you","example_es":"Nos vemos mañana.","example_en":"See you tomorrow."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Marta","spanish":"¡Hola! ¿Qué tal?","english":"Hi! How''s it going?"},
      {"speaker":"Diego","spanish":"Más o menos, cansado. ¿Y tú?","english":"So-so, tired. And you?"},
      {"speaker":"Marta","spanish":"Muy bien, gracias.","english":"Very well, thanks."},
      {"speaker":"Diego","spanish":"Bueno, nos vemos.","english":"OK, see you."}
    ]'::jsonb,
    grammar_note = 'Spanish vowels are short and clean: a, e, i, o, u always sound the same. Listen for that crisp ¡o-la! rather than the English "oh-luh" sound — every vowel is pronounced fully.'
  where id = v_l4;

  update public.lessons set
    intro = 'Now it''s your turn to speak. The key to clear Spanish is rolling each vowel cleanly and stressing the right syllable. The stressed syllable is shown in CAPITALS in the phonetic guide.',
    vocab_items = '[
      {"word":"Hola","phonetic":"[OH-lah]","english":"Hello","example_es":"Hola, soy Ana.","example_en":"Hi, I''m Ana."},
      {"word":"Buenos días","phonetic":"[BWEH-nohs DEE-ahs]","english":"Good morning","example_es":"Buenos días a todos.","example_en":"Good morning everyone."},
      {"word":"Mucho gusto","phonetic":"[MOO-choh GOOS-toh]","english":"Pleased to meet you","example_es":"Mucho gusto, Pedro.","example_en":"Pleased to meet you, Pedro."},
      {"word":"Gracias","phonetic":"[GRAH-syahs]","english":"Thank you","example_es":"Muchas gracias.","example_en":"Thank you very much."},
      {"word":"Hasta mañana","phonetic":"[AHS-tah mah-NYAH-nah]","english":"See you tomorrow","example_es":"Hasta mañana, Juan.","example_en":"See you tomorrow, Juan."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"You","spanish":"Hola, soy [your name].","english":"Hi, I''m [your name]."},
      {"speaker":"Partner","spanish":"Mucho gusto. Soy Lucía.","english":"Pleased to meet you. I''m Lucía."},
      {"speaker":"You","spanish":"Encantado, Lucía.","english":"Nice to meet you, Lucía."},
      {"speaker":"Partner","spanish":"¡Hasta mañana!","english":"See you tomorrow!"}
    ]'::jsonb,
    grammar_note = 'In Spanish, most words ending in a vowel, -n, or -s are stressed on the second-to-last syllable: HO-la, MU-cho, BUE-nos. Words ending in other consonants stress the last syllable: us-TED, se-ÑOR.'
  where id = v_l5;

  update public.lessons set
    intro = 'In the dialogue below, Ana introduces herself to a new neighbor. Read carefully, then answer the comprehension questions.',
    vocab_items = '[
      {"word":"me llamo","phonetic":"[meh YAH-moh]","english":"my name is","example_es":"Me llamo Ana.","example_en":"My name is Ana."},
      {"word":"vivo en","phonetic":"[BEE-boh ehn]","english":"I live in","example_es":"Vivo en Madrid.","example_en":"I live in Madrid."},
      {"word":"tengo","phonetic":"[TEHN-goh]","english":"I have / I am (age)","example_es":"Tengo veinte años.","example_en":"I am 20 years old."},
      {"word":"vecino","phonetic":"[beh-SEE-noh]","english":"neighbor","example_es":"Es mi nuevo vecino.","example_en":"He is my new neighbor."},
      {"word":"mucho gusto","phonetic":"[MOO-choh GOOS-toh]","english":"pleased to meet you","example_es":"Mucho gusto, Ana.","example_en":"Pleased to meet you, Ana."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Ana","spanish":"Hola, me llamo Ana. Soy tu nueva vecina.","english":"Hi, my name is Ana. I''m your new neighbor."},
      {"speaker":"Pablo","spanish":"Mucho gusto, Ana. Yo soy Pablo.","english":"Pleased to meet you, Ana. I''m Pablo."},
      {"speaker":"Ana","spanish":"¿De dónde eres, Pablo?","english":"Where are you from, Pablo?"},
      {"speaker":"Pablo","spanish":"Soy de Sevilla, pero vivo aquí.","english":"I''m from Seville, but I live here."}
    ]'::jsonb,
    grammar_note = 'Soy de + place = "I am from + place". Vivo en + place = "I live in + place". The first describes origin, the second describes where you live now.'
  where id = v_l6;

  update public.lessons set
    intro = 'Now you''ll practice writing greetings yourself. Pay attention to the punctuation: Spanish uses inverted ¿ and ¡ at the start of questions and exclamations.',
    vocab_items = '[
      {"word":"¿...?","phonetic":"[inverted question mark]","english":"question marks","example_es":"¿Cómo estás?","example_en":"How are you?"},
      {"word":"¡...!","phonetic":"[inverted exclamation]","english":"exclamation marks","example_es":"¡Hola!","example_en":"Hi!"},
      {"word":"Querido / Querida","phonetic":"[keh-REE-doh]","english":"Dear (m./f.)","example_es":"Querido Juan,","example_en":"Dear Juan,"},
      {"word":"Un saludo","phonetic":"[oon sah-LOO-doh]","english":"Best wishes","example_es":"Un saludo, Ana.","example_en":"Best wishes, Ana."},
      {"word":"firma","phonetic":"[FEER-mah]","english":"signature","example_es":"Pon tu firma aquí.","example_en":"Put your signature here."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Note from Ana","spanish":"¡Hola, Pablo!","english":"Hi, Pablo!"},
      {"speaker":"","spanish":"¿Cómo estás? Espero que bien.","english":"How are you? I hope well."},
      {"speaker":"","spanish":"Nos vemos pronto.","english":"See you soon."},
      {"speaker":"","spanish":"Un saludo, Ana","english":"Best wishes, Ana"}
    ]'::jsonb,
    grammar_note = 'Spanish opens questions and exclamations with inverted marks: ¿Cómo estás? / ¡Hola! Type them with Alt+Shift+? and Alt+Shift+1 on Mac, or hold the ? / ! key on mobile.'
  where id = v_l7;

  -- ============== A1.2 NUMBERS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Numbers';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'You will learn the Spanish numbers from 1 to 10 — the foundation for telling age, time, prices and quantities.',
    vocab_items = '[
      {"word":"uno","phonetic":"[OO-noh]","english":"one","example_es":"Tengo uno.","example_en":"I have one."},
      {"word":"dos","phonetic":"[DOHS]","english":"two","example_es":"Hay dos libros.","example_en":"There are two books."},
      {"word":"tres","phonetic":"[TREHS]","english":"three","example_es":"Son las tres.","example_en":"It''s three o''clock."},
      {"word":"cuatro","phonetic":"[KWAH-troh]","english":"four","example_es":"Tengo cuatro hermanos.","example_en":"I have four brothers."},
      {"word":"diez","phonetic":"[DYEHS]","english":"ten","example_es":"Diez euros, por favor.","example_en":"Ten euros, please."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Maestra","spanish":"Vamos a contar. Uno, dos, tres…","english":"Let''s count. One, two, three..."},
      {"speaker":"Niños","spanish":"Cuatro, cinco, seis, siete.","english":"Four, five, six, seven."},
      {"speaker":"Maestra","spanish":"¡Muy bien! ¿Y después?","english":"Very good! And after that?"},
      {"speaker":"Niños","spanish":"Ocho, nueve, diez.","english":"Eight, nine, ten."}
    ]'::jsonb,
    grammar_note = 'Uno changes to un before a masculine noun: un libro (one book). Before a feminine noun it becomes una: una mesa (one table). Numbers two and up don''t change for gender: dos libros, dos mesas.'
  where id = v_l1;

  update public.lessons set
    intro = 'In Spanish, the number one changes shape depending on the noun that follows. Other numbers stay the same. This lesson focuses on that pattern.',
    vocab_items = '[
      {"word":"un libro","phonetic":"[oon LEE-broh]","english":"one book","example_es":"Quiero un libro.","example_en":"I want one book."},
      {"word":"una mesa","phonetic":"[OO-nah MEH-sah]","english":"one table","example_es":"Hay una mesa.","example_en":"There is one table."},
      {"word":"dos perros","phonetic":"[dohs PEH-rrohs]","english":"two dogs","example_es":"Tengo dos perros.","example_en":"I have two dogs."},
      {"word":"tres gatos","phonetic":"[trehs GAH-tohs]","english":"three cats","example_es":"Veo tres gatos.","example_en":"I see three cats."},
      {"word":"cuántos","phonetic":"[KWAHN-tohs]","english":"how many","example_es":"¿Cuántos años tienes?","example_en":"How old are you?"}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Cliente","spanish":"Quiero un café y dos panes.","english":"I want one coffee and two breads."},
      {"speaker":"Camarero","spanish":"¿Solo un café?","english":"Just one coffee?"},
      {"speaker":"Cliente","spanish":"Sí, y una manzana también.","english":"Yes, and one apple too."},
      {"speaker":"Camarero","spanish":"Muy bien. Son cinco euros.","english":"Very good. That''s five euros."}
    ]'::jsonb,
    grammar_note = 'The number uno (1) becomes un before masculine nouns and una before feminine nouns. All other numbers keep their form: dos amigos, dos amigas — the noun shows gender, not the number.'
  where id = v_l2;

  update public.lessons set
    intro = 'These are the most useful number phrases: asking ages, prices, and quantities. Use them anywhere you need to count or measure.',
    vocab_items = '[
      {"word":"¿Cuántos años tienes?","phonetic":"[KWAHN-tohs AH-nyohs TYEH-nehs]","english":"How old are you?","example_es":"¿Cuántos años tienes, Ana?","example_en":"How old are you, Ana?"},
      {"word":"Tengo X años","phonetic":"[TEHN-goh X AH-nyohs]","english":"I am X years old","example_es":"Tengo veinte años.","example_en":"I am 20 years old."},
      {"word":"¿Cuánto cuesta?","phonetic":"[KWAHN-toh KWEHS-tah]","english":"How much does it cost?","example_es":"¿Cuánto cuesta el pan?","example_en":"How much does the bread cost?"},
      {"word":"Son las X","phonetic":"[sohn lahs X]","english":"It''s X o''clock","example_es":"Son las cinco.","example_en":"It''s 5 o''clock."},
      {"word":"número de teléfono","phonetic":"[NOO-meh-roh deh teh-LEH-foh-noh]","english":"phone number","example_es":"Dame tu número de teléfono.","example_en":"Give me your phone number."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Sara","spanish":"Hola, ¿cuántos años tienes?","english":"Hi, how old are you?"},
      {"speaker":"Tomás","spanish":"Tengo dieciocho. ¿Y tú?","english":"I''m eighteen. And you?"},
      {"speaker":"Sara","spanish":"Yo tengo veinte. ¿Qué hora es?","english":"I''m twenty. What time is it?"},
      {"speaker":"Tomás","spanish":"Son las seis.","english":"It''s six o''clock."}
    ]'::jsonb,
    grammar_note = 'Spanish uses tener (to have) for age, not ser (to be): Tengo veinte años, literally "I have twenty years". Saying soy veinte would sound very strange.'
  where id = v_l3;

  update public.lessons set
    intro = 'Numbers come at you fast in real life — prices, times, addresses. This lesson trains you to catch them in spoken Spanish.',
    vocab_items = '[
      {"word":"once","phonetic":"[OHN-seh]","english":"eleven","example_es":"Son las once.","example_en":"It''s eleven o''clock."},
      {"word":"doce","phonetic":"[DOH-seh]","english":"twelve","example_es":"Tengo doce.","example_en":"I have twelve."},
      {"word":"quince","phonetic":"[KEEN-seh]","english":"fifteen","example_es":"Tengo quince años.","example_en":"I''m fifteen."},
      {"word":"veinte","phonetic":"[BEHN-teh]","english":"twenty","example_es":"Cuesta veinte euros.","example_en":"It costs twenty euros."},
      {"word":"cien","phonetic":"[SYEHN]","english":"one hundred","example_es":"Cien euros, por favor.","example_en":"One hundred euros, please."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Anuncio","spanish":"Tren a Madrid, andén número doce.","english":"Train to Madrid, platform number twelve."},
      {"speaker":"Viajero","spanish":"¿Doce? Pero yo tengo el quince.","english":"Twelve? But I have number fifteen."},
      {"speaker":"Anuncio","spanish":"Andén quince: tren a Barcelona.","english":"Platform fifteen: train to Barcelona."},
      {"speaker":"Viajero","spanish":"Ese es el mío. ¡Gracias!","english":"That''s mine. Thanks!"}
    ]'::jsonb,
    grammar_note = 'Numbers 11–15 are single words: once, doce, trece, catorce, quince. From 16 onwards they''re built as "ten + and + unit": dieciséis (10+6), diecisiete (10+7).'
  where id = v_l4;

  update public.lessons set
    intro = 'Saying numbers clearly is essential at restaurants, train stations, and on the phone. Focus on stressing each syllable cleanly.',
    vocab_items = '[
      {"word":"Tengo veinte años","phonetic":"[TEHN-goh BEHN-teh AH-nyohs]","english":"I''m twenty","example_es":"Tengo veinte años exactos.","example_en":"I''m exactly twenty."},
      {"word":"Cuesta diez euros","phonetic":"[KWEHS-tah DYEHS EH-oo-rohs]","english":"It costs 10 euros","example_es":"El menú cuesta diez euros.","example_en":"The set menu is ten euros."},
      {"word":"Son las tres","phonetic":"[sohn lahs TREHS]","english":"It''s 3 o''clock","example_es":"Son las tres en punto.","example_en":"It''s 3 o''clock sharp."},
      {"word":"Mi número es","phonetic":"[mee NOO-meh-roh ehs]","english":"My number is","example_es":"Mi número es seis-ocho-cero.","example_en":"My number is 680."},
      {"word":"cero","phonetic":"[SEH-roh]","english":"zero","example_es":"El número cero.","example_en":"The number zero."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"You","spanish":"Hola, ¿cuánto cuesta?","english":"Hi, how much is it?"},
      {"speaker":"Tienda","spanish":"Cuesta veinte euros.","english":"It costs twenty euros."},
      {"speaker":"You","spanish":"¿Veinte? ¿Acepta tarjeta?","english":"Twenty? Do you take card?"},
      {"speaker":"Tienda","spanish":"Sí, claro. Aquí tiene.","english":"Yes, of course. Here you go."}
    ]'::jsonb,
    grammar_note = 'For phone numbers, Spanish speakers usually pair the digits in twos: 6-12-34-56 reads "seis, doce, treinta y cuatro, cincuenta y seis", not digit by digit.'
  where id = v_l5;

  update public.lessons set
    intro = 'Read the short text about a Spanish classroom. Notice how numbers are woven into real sentences.',
    vocab_items = '[
      {"word":"clase","phonetic":"[KLAH-seh]","english":"class","example_es":"Mi clase es grande.","example_en":"My class is big."},
      {"word":"estudiante","phonetic":"[ehs-too-DYAHN-teh]","english":"student","example_es":"Soy estudiante.","example_en":"I am a student."},
      {"word":"libro","phonetic":"[LEE-broh]","english":"book","example_es":"Tengo dos libros.","example_en":"I have two books."},
      {"word":"hay","phonetic":"[I]","english":"there is / there are","example_es":"Hay diez estudiantes.","example_en":"There are ten students."},
      {"word":"empezar","phonetic":"[ehm-peh-SAHR]","english":"to start","example_es":"Empieza a las nueve.","example_en":"It starts at nine."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"En mi clase hay veinte estudiantes.","english":"In my class there are twenty students."},
      {"speaker":"","spanish":"Tengo tres libros y cinco bolígrafos.","english":"I have three books and five pens."},
      {"speaker":"","spanish":"Mi número de teléfono empieza con seis.","english":"My phone number starts with six."},
      {"speaker":"","spanish":"Yo tengo treinta años.","english":"I am thirty years old."}
    ]'::jsonb,
    grammar_note = 'Hay (pronounced like "eye") is the impersonal form of haber and means "there is" or "there are". It''s the same word whether singular or plural: Hay un libro / Hay tres libros.'
  where id = v_l6;

  update public.lessons set
    intro = 'Now you write the numbers in real sentences. Match the rhythm: number + noun, and don''t forget gender agreement on uno.',
    vocab_items = '[
      {"word":"un, una","phonetic":"[oon / OO-nah]","english":"one (m./f.)","example_es":"un libro, una mesa","example_en":"one book, one table"},
      {"word":"euros","phonetic":"[EH-oo-rohs]","english":"euros","example_es":"diez euros","example_en":"ten euros"},
      {"word":"años","phonetic":"[AH-nyohs]","english":"years","example_es":"veinte años","example_en":"twenty years"},
      {"word":"a las...","phonetic":"[ah lahs]","english":"at (a time)","example_es":"a las cinco","example_en":"at five o''clock"},
      {"word":"empezar a las","phonetic":"[ehm-peh-SAHR ah lahs]","english":"to start at","example_es":"Empieza a las dos.","example_en":"It starts at two."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Models","spanish":"Tengo veinte años.","english":"I am 20 years old."},
      {"speaker":"","spanish":"Cuesta diez euros.","english":"It costs 10 euros."},
      {"speaker":"","spanish":"Son las tres.","english":"It''s 3 o''clock."},
      {"speaker":"","spanish":"Hay cinco libros.","english":"There are 5 books."}
    ]'::jsonb,
    grammar_note = 'When writing time: it''s singular for one (Es la una) and plural for two and up (Son las dos, Son las cinco). The article matches: la for one, las for plural.'
  where id = v_l7;

  -- ============== A1.3 COLORS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Colors';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'Colors describe everything around us. You''ll learn the main colors and how to use them in simple sentences like "the sky is blue".',
    vocab_items = '[
      {"word":"rojo","phonetic":"[ROH-hoh]","english":"red","example_es":"Un coche rojo.","example_en":"A red car."},
      {"word":"azul","phonetic":"[ah-SOOL]","english":"blue","example_es":"El cielo es azul.","example_en":"The sky is blue."},
      {"word":"verde","phonetic":"[BEHR-deh]","english":"green","example_es":"Hierba verde.","example_en":"Green grass."},
      {"word":"amarillo","phonetic":"[ah-mah-REE-yoh]","english":"yellow","example_es":"El sol es amarillo.","example_en":"The sun is yellow."},
      {"word":"negro","phonetic":"[NEH-groh]","english":"black","example_es":"Un gato negro.","example_en":"A black cat."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Niña","spanish":"Mira, mamá, ¡el cielo es azul!","english":"Look, mom, the sky is blue!"},
      {"speaker":"Mamá","spanish":"Sí, y las hojas son verdes.","english":"Yes, and the leaves are green."},
      {"speaker":"Niña","spanish":"Mi camisa es roja, ¿verdad?","english":"My shirt is red, right?"},
      {"speaker":"Mamá","spanish":"Sí, y tu sombrero es amarillo.","english":"Yes, and your hat is yellow."}
    ]'::jsonb,
    grammar_note = 'In Spanish, colors come AFTER the noun, not before: el libro rojo (the red book), not el rojo libro. Most colors change form to match the noun''s gender and number — you''ll learn that in the next lesson.'
  where id = v_l1;

  update public.lessons set
    intro = 'Here''s the rule that trips up English speakers: Spanish adjectives must agree with the noun in gender and number. A red car is rojo, but a red house is roja.',
    vocab_items = '[
      {"word":"rojo / roja","phonetic":"[ROH-hoh / ROH-hah]","english":"red (m./f.)","example_es":"libro rojo, casa roja","example_en":"red book, red house"},
      {"word":"blanco / blanca","phonetic":"[BLAHN-koh / BLAHN-kah]","english":"white (m./f.)","example_es":"perro blanco, pared blanca","example_en":"white dog, white wall"},
      {"word":"negro / negra","phonetic":"[NEH-groh / NEH-grah]","english":"black (m./f.)","example_es":"gato negro, mesa negra","example_en":"black cat, black table"},
      {"word":"verde","phonetic":"[BEHR-deh]","english":"green (both)","example_es":"árbol verde, planta verde","example_en":"green tree, green plant"},
      {"word":"azul","phonetic":"[ah-SOOL]","english":"blue (both)","example_es":"coche azul, falda azul","example_en":"blue car, blue skirt"}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Vendedor","spanish":"Tenemos zapatos negros y blancos.","english":"We have black and white shoes."},
      {"speaker":"Cliente","spanish":"¿Y la chaqueta? ¿Es roja?","english":"And the jacket? Is it red?"},
      {"speaker":"Vendedor","spanish":"Sí, esta chaqueta es roja.","english":"Yes, this jacket is red."},
      {"speaker":"Cliente","spanish":"Perfecto. La camisa azul también.","english":"Perfect. The blue shirt too."}
    ]'::jsonb,
    grammar_note = 'Colors ending in -o have four forms: rojo (m.sg), roja (f.sg), rojos (m.pl), rojas (f.pl). Colors ending in -e or a consonant (verde, azul, gris) only change for plural: verdes, azules, grises.'
  where id = v_l2;

  update public.lessons set
    intro = 'The most useful color phrases for daily conversation: asking about color, naming a favorite, and describing what you''re looking at.',
    vocab_items = '[
      {"word":"¿De qué color es?","phonetic":"[deh keh koh-LOHR ehs]","english":"What color is it?","example_es":"¿De qué color es tu coche?","example_en":"What color is your car?"},
      {"word":"Mi color favorito","phonetic":"[mee koh-LOHR fah-boh-REE-toh]","english":"My favorite color","example_es":"Mi color favorito es el azul.","example_en":"My favorite color is blue."},
      {"word":"Me gusta el verde","phonetic":"[meh GOOS-tah ehl BEHR-deh]","english":"I like green","example_es":"Me gusta mucho el verde.","example_en":"I really like green."},
      {"word":"claro / oscuro","phonetic":"[KLAH-roh / ohs-KOO-roh]","english":"light / dark","example_es":"Azul oscuro.","example_en":"Dark blue."},
      {"word":"el cielo","phonetic":"[ehl SYEH-loh]","english":"the sky","example_es":"El cielo está gris hoy.","example_en":"The sky is gray today."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Tina","spanish":"¿Cuál es tu color favorito?","english":"What''s your favorite color?"},
      {"speaker":"Hugo","spanish":"El verde. ¿Y el tuyo?","english":"Green. And yours?"},
      {"speaker":"Tina","spanish":"Me gusta el azul oscuro.","english":"I like dark blue."},
      {"speaker":"Hugo","spanish":"¡Como el cielo de noche!","english":"Like the night sky!"}
    ]'::jsonb,
    grammar_note = 'To talk about a color in general, Spanish uses the masculine article: el rojo, el azul, el verde — "(the color) red", "(the color) blue". Me gusta el rojo = "I like (the color) red".'
  where id = v_l3;

  update public.lessons set
    intro = 'Hearing colors quickly takes practice — they often blend with the noun. Sharpen your ear with these examples.',
    vocab_items = '[
      {"word":"rosa","phonetic":"[ROH-sah]","english":"pink","example_es":"Una flor rosa.","example_en":"A pink flower."},
      {"word":"naranja","phonetic":"[nah-RAHN-hah]","english":"orange","example_es":"Una camiseta naranja.","example_en":"An orange t-shirt."},
      {"word":"gris","phonetic":"[GREES]","english":"gray","example_es":"El cielo está gris.","example_en":"The sky is gray."},
      {"word":"marrón","phonetic":"[mah-RROHN]","english":"brown","example_es":"Zapatos marrones.","example_en":"Brown shoes."},
      {"word":"morado","phonetic":"[moh-RAH-doh]","english":"purple","example_es":"Una flor morada.","example_en":"A purple flower."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Niño","spanish":"¿Dónde está mi sombrero?","english":"Where is my hat?"},
      {"speaker":"Madre","spanish":"¿Cuál? ¿El gris o el marrón?","english":"Which one? The gray or the brown?"},
      {"speaker":"Niño","spanish":"El marrón. Y mis zapatos rosas.","english":"The brown one. And my pink shoes."},
      {"speaker":"Madre","spanish":"Aquí están, debajo de la mesa.","english":"Here they are, under the table."}
    ]'::jsonb,
    grammar_note = 'Some colors don''t change at all because they''re named after objects: rosa (rose), naranja (orange the fruit), violeta (violet). You always say camisa rosa, no matter the gender.'
  where id = v_l4;

  update public.lessons set
    intro = 'Time to speak colors aloud. Pay attention to the rolled R in rojo and the double L in amarillo — they''re soft, like a Y.',
    vocab_items = '[
      {"word":"Mi coche es rojo","phonetic":"[mee KOH-cheh ehs ROH-hoh]","english":"My car is red","example_es":"Mi coche es rojo brillante.","example_en":"My car is bright red."},
      {"word":"La casa es blanca","phonetic":"[lah KAH-sah ehs BLAHN-kah]","english":"The house is white","example_es":"La casa es blanca y grande.","example_en":"The house is white and big."},
      {"word":"Los zapatos son negros","phonetic":"[lohs sah-PAH-tohs sohn NEH-grohs]","english":"The shoes are black","example_es":"Los zapatos son negros nuevos.","example_en":"The shoes are new and black."},
      {"word":"Me gusta el azul","phonetic":"[meh GOOS-tah ehl ah-SOOL]","english":"I like blue","example_es":"Me gusta el azul del mar.","example_en":"I like the blue of the sea."},
      {"word":"amarillo","phonetic":"[ah-mah-REE-yoh]","english":"yellow","example_es":"Las flores son amarillas.","example_en":"The flowers are yellow."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"You","spanish":"Mi coche es rojo.","english":"My car is red."},
      {"speaker":"Friend","spanish":"¡Qué bonito! El mío es azul.","english":"How pretty! Mine is blue."},
      {"speaker":"You","spanish":"Me gusta el azul también.","english":"I like blue too."},
      {"speaker":"Friend","spanish":"Pero prefiero el verde.","english":"But I prefer green."}
    ]'::jsonb,
    grammar_note = 'The double LL in amarillo, llamo, lluvia is pronounced like English Y in "yes" in most of the Spanish-speaking world. In parts of Argentina and Uruguay it sounds like SH.'
  where id = v_l5;

  update public.lessons set
    intro = 'Read this short description and notice how the colors agree with the nouns they describe.',
    vocab_items = '[
      {"word":"favorito / favorita","phonetic":"[fah-boh-REE-toh]","english":"favorite","example_es":"Mi color favorito.","example_en":"My favorite color."},
      {"word":"casa","phonetic":"[KAH-sah]","english":"house","example_es":"Una casa blanca.","example_en":"A white house."},
      {"word":"coche","phonetic":"[KOH-cheh]","english":"car","example_es":"Un coche rojo.","example_en":"A red car."},
      {"word":"primavera","phonetic":"[pree-mah-BEH-rah]","english":"spring","example_es":"En primavera hay flores.","example_en":"In spring there are flowers."},
      {"word":"flores","phonetic":"[FLOH-rehs]","english":"flowers","example_es":"Flores amarillas y rosas.","example_en":"Yellow and pink flowers."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Mi color favorito es el azul.","english":"My favorite color is blue."},
      {"speaker":"","spanish":"Tengo una casa blanca y un coche rojo.","english":"I have a white house and a red car."},
      {"speaker":"","spanish":"Mi gato es negro.","english":"My cat is black."},
      {"speaker":"","spanish":"En primavera, las flores son amarillas y rosas.","english":"In spring, the flowers are yellow and pink."}
    ]'::jsonb,
    grammar_note = 'Spanish often uses the definite article (el, la, los, las) where English uses none: Me gusta el azul = "I like blue". Las flores son amarillas = "Flowers are yellow".'
  where id = v_l6;

  update public.lessons set
    intro = 'Now you write color sentences. Remember: the color comes AFTER the noun and agrees with it in gender and number.',
    vocab_items = '[
      {"word":"el / la","phonetic":"[ehl / lah]","english":"the (m./f.)","example_es":"el coche, la casa","example_en":"the car, the house"},
      {"word":"un / una","phonetic":"[oon / OO-nah]","english":"a (m./f.)","example_es":"un coche, una casa","example_en":"a car, a house"},
      {"word":"son","phonetic":"[sohn]","english":"are (plural)","example_es":"Las flores son rojas.","example_en":"The flowers are red."},
      {"word":"es","phonetic":"[ehs]","english":"is","example_es":"El cielo es azul.","example_en":"The sky is blue."},
      {"word":"y","phonetic":"[EE]","english":"and","example_es":"verde y azul","example_en":"green and blue"}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Models","spanish":"Mi casa es blanca.","english":"My house is white."},
      {"speaker":"","spanish":"El coche es rojo.","english":"The car is red."},
      {"speaker":"","spanish":"Las flores son amarillas.","english":"The flowers are yellow."},
      {"speaker":"","spanish":"Me gusta el azul.","english":"I like blue."}
    ]'::jsonb,
    grammar_note = 'Word order: ARTICLE + NOUN + es/son + COLOR. La casa (article+noun) + es (is) + blanca (color). Don''t forget: the color matches the noun''s gender (-o/-a) and number (-s).'
  where id = v_l7;

  -- ============== A1.4 FAMILY ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Family';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'Family vocabulary is one of the first things you''ll need in any language. This lesson covers parents, siblings, and children.',
    vocab_items = '[
      {"word":"madre","phonetic":"[MAH-dreh]","english":"mother","example_es":"Mi madre es alta.","example_en":"My mother is tall."},
      {"word":"padre","phonetic":"[PAH-dreh]","english":"father","example_es":"Mi padre trabaja.","example_en":"My father works."},
      {"word":"hermano","phonetic":"[ehr-MAH-noh]","english":"brother","example_es":"Tengo un hermano.","example_en":"I have a brother."},
      {"word":"hermana","phonetic":"[ehr-MAH-nah]","english":"sister","example_es":"Mi hermana se llama Ana.","example_en":"My sister is called Ana."},
      {"word":"hijo / hija","phonetic":"[EE-hoh / EE-hah]","english":"son / daughter","example_es":"Tengo un hijo y una hija.","example_en":"I have a son and a daughter."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Lara","spanish":"¿Tienes hermanos?","english":"Do you have siblings?"},
      {"speaker":"Mateo","spanish":"Sí, un hermano y una hermana.","english":"Yes, one brother and one sister."},
      {"speaker":"Lara","spanish":"¿Cómo se llama tu hermana?","english":"What''s your sister''s name?"},
      {"speaker":"Mateo","spanish":"Se llama Lucía. Tiene diez años.","english":"Her name is Lucía. She''s ten."}
    ]'::jsonb,
    grammar_note = 'Family words follow the gender rule: hijo (son) is masculine, hija (daughter) feminine. The plural padres can mean "fathers" but is most commonly used for "parents". Same for hermanos = brothers OR brothers and sisters together.'
  where id = v_l1;

  update public.lessons set
    intro = 'To talk about your family, you need possessive words: mi (my), tu (your), su (his/her/their). They come BEFORE the noun.',
    vocab_items = '[
      {"word":"mi","phonetic":"[MEE]","english":"my","example_es":"Mi madre se llama Ana.","example_en":"My mother is named Ana."},
      {"word":"tu","phonetic":"[TOO]","english":"your (informal)","example_es":"¿Cómo se llama tu padre?","example_en":"What is your father called?"},
      {"word":"su","phonetic":"[SOO]","english":"his / her / their","example_es":"Su hermano vive en Madrid.","example_en":"His brother lives in Madrid."},
      {"word":"nuestro / nuestra","phonetic":"[NWEHS-troh]","english":"our","example_es":"Nuestra familia es grande.","example_en":"Our family is big."},
      {"word":"mis / tus / sus","phonetic":"[mees / toos / soos]","english":"plural forms","example_es":"Mis hermanos viven aquí.","example_en":"My siblings live here."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Pedro","spanish":"¿Cómo se llama tu madre?","english":"What''s your mother''s name?"},
      {"speaker":"Sara","spanish":"Mi madre se llama Carmen.","english":"My mother''s name is Carmen."},
      {"speaker":"Pedro","spanish":"¿Y tus hermanos?","english":"And your siblings?"},
      {"speaker":"Sara","spanish":"Mis hermanos se llaman Pablo y Eva.","english":"My siblings are Pablo and Eva."}
    ]'::jsonb,
    grammar_note = 'Possessives match the number of the noun, not the owner: mi hermano (one brother) but mis hermanos (several siblings). They don''t change for gender: mi madre AND mi padre both use mi.'
  where id = v_l2;

  update public.lessons set
    intro = 'These are the everyday phrases you''ll use to describe and ask about families.',
    vocab_items = '[
      {"word":"Mi familia es","phonetic":"[mee fah-MEE-lyah ehs]","english":"My family is","example_es":"Mi familia es grande.","example_en":"My family is big."},
      {"word":"se llama","phonetic":"[seh YAH-mah]","english":"is called","example_es":"Mi padre se llama Luis.","example_en":"My father is called Luis."},
      {"word":"¿Tienes hermanos?","phonetic":"[TYEH-nehs ehr-MAH-nohs]","english":"Do you have siblings?","example_es":"¿Tienes hermanos o eres hijo único?","example_en":"Do you have siblings or are you an only child?"},
      {"word":"hijo único","phonetic":"[EE-hoh OO-nee-koh]","english":"only child","example_es":"Soy hijo único.","example_en":"I''m an only child."},
      {"word":"Vivimos en","phonetic":"[bee-BEE-mohs ehn]","english":"We live in","example_es":"Vivimos en Madrid.","example_en":"We live in Madrid."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Ana","spanish":"Mi familia es grande. Somos cinco.","english":"My family is big. We''re five."},
      {"speaker":"Luis","spanish":"¡Cinco! ¿Tienes muchos hermanos?","english":"Five! Do you have many siblings?"},
      {"speaker":"Ana","spanish":"Sí, tres hermanas. ¿Y tú?","english":"Yes, three sisters. And you?"},
      {"speaker":"Luis","spanish":"Yo soy hijo único.","english":"I''m an only child."}
    ]'::jsonb,
    grammar_note = 'When counting family members, Spanish uses Somos + number: Somos cinco = "We are five (in the family)". The verb ser (somos = "we are") naturally fits this counting context.'
  where id = v_l3;

  update public.lessons set
    intro = 'Listen for the family vocab in real spoken sentences. Native speakers often shorten "mi madre" to almost "mma-dre" — train your ear.',
    vocab_items = '[
      {"word":"abuelo / abuela","phonetic":"[ah-BWEH-loh / ah-BWEH-lah]","english":"grandfather / grandmother","example_es":"Mi abuela cocina bien.","example_en":"My grandmother cooks well."},
      {"word":"tío / tía","phonetic":"[TEE-oh / TEE-ah]","english":"uncle / aunt","example_es":"Mi tío Carlos.","example_en":"My uncle Carlos."},
      {"word":"primo / prima","phonetic":"[PREE-moh / PREE-mah]","english":"cousin (m./f.)","example_es":"Tengo muchos primos.","example_en":"I have many cousins."},
      {"word":"viejo / viejos","phonetic":"[BYEH-hoh]","english":"old","example_es":"Mis abuelos son viejos.","example_en":"My grandparents are old."},
      {"word":"vive en","phonetic":"[BEE-beh ehn]","english":"lives in","example_es":"Mi tía vive en Sevilla.","example_en":"My aunt lives in Seville."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Mateo","spanish":"Mis abuelos viven en Granada.","english":"My grandparents live in Granada."},
      {"speaker":"Sofía","spanish":"¿Y tus primos?","english":"And your cousins?"},
      {"speaker":"Mateo","spanish":"Tengo cinco primos en Sevilla.","english":"I have five cousins in Seville."},
      {"speaker":"Sofía","spanish":"Yo solo tengo dos: un primo y una prima.","english":"I only have two: one cousin (m.) and one cousin (f.)."}
    ]'::jsonb,
    grammar_note = 'Spanish has many word pairs that just swap -o for -a to change gender: tío/tía, primo/prima, abuelo/abuela. When you don''t know the gender of a group, use the masculine: primos can mean all-male cousins OR mixed cousins.'
  where id = v_l4;

  update public.lessons set
    intro = 'It''s your turn to introduce your family aloud. Use the patterns Mi + relative + se llama + name.',
    vocab_items = '[
      {"word":"Mi madre se llama","phonetic":"[mee MAH-dreh seh YAH-mah]","english":"My mother is called","example_es":"Mi madre se llama María.","example_en":"My mother is called María."},
      {"word":"Tengo un hermano","phonetic":"[TEHN-goh oon ehr-MAH-noh]","english":"I have a brother","example_es":"Tengo un hermano y una hermana.","example_en":"I have one brother and one sister."},
      {"word":"Mi padre es","phonetic":"[mee PAH-dreh ehs]","english":"My father is","example_es":"Mi padre es médico.","example_en":"My father is a doctor."},
      {"word":"Vivimos juntos","phonetic":"[bee-BEE-mohs HOON-tohs]","english":"We live together","example_es":"Vivimos juntos en Madrid.","example_en":"We live together in Madrid."},
      {"word":"Mi familia es pequeña","phonetic":"[mee fah-MEE-lyah ehs peh-KEH-nyah]","english":"My family is small","example_es":"Mi familia es pequeña pero feliz.","example_en":"My family is small but happy."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"You","spanish":"Mi familia es pequeña.","english":"My family is small."},
      {"speaker":"","spanish":"Tengo un hermano y una hermana.","english":"I have one brother and one sister."},
      {"speaker":"","spanish":"Mi madre se llama Ana.","english":"My mother is called Ana."},
      {"speaker":"","spanish":"Vivimos juntos en Madrid.","english":"We live together in Madrid."}
    ]'::jsonb,
    grammar_note = 'Notice how saying someone''s profession or relationship usually skips the article: Mi padre es médico (not un médico). The article appears only when adding details: Mi padre es un médico famoso (a famous doctor).'
  where id = v_l5;

  update public.lessons set
    intro = 'Read about a typical Spanish family. Notice the rhythm of subject + verb + family member, with possessives marking who belongs to whom.',
    vocab_items = '[
      {"word":"se llama","phonetic":"[seh YAH-mah]","english":"is called","example_es":"Mi madre se llama Carmen.","example_en":"My mother is called Carmen."},
      {"word":"juntos / juntas","phonetic":"[HOON-tohs]","english":"together","example_es":"Vivimos juntos.","example_en":"We live together."},
      {"word":"pequeña","phonetic":"[peh-KEH-nyah]","english":"small (f.)","example_es":"Una familia pequeña.","example_en":"A small family."},
      {"word":"quince","phonetic":"[KEEN-seh]","english":"fifteen","example_es":"Mi hermano tiene quince años.","example_en":"My brother is fifteen."},
      {"word":"Sevilla","phonetic":"[seh-BEE-yah]","english":"Seville","example_es":"Vivimos en Sevilla.","example_en":"We live in Seville."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Mi familia es pequeña.","english":"My family is small."},
      {"speaker":"","spanish":"Mi madre se llama Carmen y mi padre se llama Luis.","english":"My mother is named Carmen and my father is named Luis."},
      {"speaker":"","spanish":"Tengo un hermano y una hermana.","english":"I have a brother and a sister."},
      {"speaker":"","spanish":"Vivimos juntos en Sevilla.","english":"We live together in Sevilla."}
    ]'::jsonb,
    grammar_note = 'Vivimos en + place is one of the most common patterns: vivir (to live) + en (in) + city/country. Note: vivir uses ser/estar style — no "I am living", just vivo, vives, vive…'
  where id = v_l6;

  update public.lessons set
    intro = 'Practice writing about your own family. Watch the possessive: mi for one item, mis for several.',
    vocab_items = '[
      {"word":"Tengo","phonetic":"[TEHN-goh]","english":"I have","example_es":"Tengo un hermano.","example_en":"I have a brother."},
      {"word":"un / una","phonetic":"[oon / OO-nah]","english":"a (m./f.)","example_es":"un hermano, una hermana","example_en":"a brother, a sister"},
      {"word":"se llama","phonetic":"[seh YAH-mah]","english":"is called","example_es":"Mi padre se llama Juan.","example_en":"My father is called Juan."},
      {"word":"Vivo con","phonetic":"[BEE-boh kohn]","english":"I live with","example_es":"Vivo con mis padres.","example_en":"I live with my parents."},
      {"word":"hermanos","phonetic":"[ehr-MAH-nohs]","english":"siblings","example_es":"Tengo dos hermanos.","example_en":"I have two siblings."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Models","spanish":"Tengo un hermano y una hermana.","english":"I have a brother and a sister."},
      {"speaker":"","spanish":"Mi madre se llama Ana.","english":"My mother is called Ana."},
      {"speaker":"","spanish":"Mi familia es grande.","english":"My family is big."},
      {"speaker":"","spanish":"Vivimos en Madrid.","english":"We live in Madrid."}
    ]'::jsonb,
    grammar_note = 'Don''t use the personal a before family relationships in possession statements: Tengo un hermano (correct), not Tengo a un hermano. The personal a appears with direct objects: Veo a mi hermano (I see my brother).'
  where id = v_l7;

  -- ============== A1.5 FOOD ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Food';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'These are the basic foods you''ll need to order, buy, or simply enjoy a Spanish meal.',
    vocab_items = '[
      {"word":"pan","phonetic":"[PAHN]","english":"bread","example_es":"Quiero pan.","example_en":"I want bread."},
      {"word":"agua","phonetic":"[AH-gwah]","english":"water","example_es":"Un vaso de agua.","example_en":"A glass of water."},
      {"word":"leche","phonetic":"[LEH-cheh]","english":"milk","example_es":"Café con leche.","example_en":"Coffee with milk."},
      {"word":"queso","phonetic":"[KEH-soh]","english":"cheese","example_es":"Un sándwich de queso.","example_en":"A cheese sandwich."},
      {"word":"manzana","phonetic":"[mahn-SAH-nah]","english":"apple","example_es":"Una manzana roja.","example_en":"A red apple."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Hijo","spanish":"Mamá, tengo hambre.","english":"Mom, I''m hungry."},
      {"speaker":"Madre","spanish":"¿Quieres pan con queso?","english":"Do you want bread with cheese?"},
      {"speaker":"Hijo","spanish":"Sí, y una manzana también.","english":"Yes, and an apple too."},
      {"speaker":"Madre","spanish":"Aquí tienes. ¡Buen provecho!","english":"Here you are. Enjoy your meal!"}
    ]'::jsonb,
    grammar_note = 'Most Spanish food nouns ending in -o are masculine (el queso, el pan) and those ending in -a are feminine (la leche, la manzana). El agua looks feminine but uses el to avoid two A''s clashing — it''s still grammatically feminine: el agua fría.'
  where id = v_l1;

  update public.lessons set
    intro = 'Spanish uses the definite article (el, la, los, las) more than English does. Learn when each one appears with food.',
    vocab_items = '[
      {"word":"el","phonetic":"[EHL]","english":"the (m. singular)","example_es":"el pan","example_en":"the bread"},
      {"word":"la","phonetic":"[LAH]","english":"the (f. singular)","example_es":"la leche","example_en":"the milk"},
      {"word":"los","phonetic":"[LOHS]","english":"the (m. plural)","example_es":"los plátanos","example_en":"the bananas"},
      {"word":"las","phonetic":"[LAHS]","english":"the (f. plural)","example_es":"las manzanas","example_en":"the apples"},
      {"word":"un / una","phonetic":"[oon / OO-nah]","english":"a (m./f.)","example_es":"un café, una manzana","example_en":"a coffee, an apple"}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Camarero","spanish":"¿Qué desea?","english":"What would you like?"},
      {"speaker":"Cliente","spanish":"Un café y una tostada.","english":"A coffee and a piece of toast."},
      {"speaker":"Camarero","spanish":"¿Le gusta el queso?","english":"Do you like cheese?"},
      {"speaker":"Cliente","spanish":"Sí, me encantan los quesos españoles.","english":"Yes, I love Spanish cheeses."}
    ]'::jsonb,
    grammar_note = 'When talking about food in general (likes/dislikes), Spanish requires the definite article: Me gusta el pan (I like bread). When ordering one specific item, use un/una: Quiero un café (I want a coffee).'
  where id = v_l2;

  update public.lessons set
    intro = 'These are the phrases you''ll hear and use every day at meals, in cafés, and at the dinner table.',
    vocab_items = '[
      {"word":"Tengo hambre","phonetic":"[TEHN-goh AHM-breh]","english":"I''m hungry","example_es":"Tengo mucha hambre.","example_en":"I''m very hungry."},
      {"word":"Tengo sed","phonetic":"[TEHN-goh SEHD]","english":"I''m thirsty","example_es":"Tengo sed, quiero agua.","example_en":"I''m thirsty, I want water."},
      {"word":"Me gusta","phonetic":"[meh GOOS-tah]","english":"I like","example_es":"Me gusta el café.","example_en":"I like coffee."},
      {"word":"Quiero","phonetic":"[KYEH-roh]","english":"I want","example_es":"Quiero una manzana.","example_en":"I want an apple."},
      {"word":"Buen provecho","phonetic":"[BWEHN proh-BEH-choh]","english":"Enjoy your meal","example_es":"¡Buen provecho a todos!","example_en":"Enjoy, everyone!"}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Padre","spanish":"¡A comer! Buen provecho.","english":"Time to eat! Enjoy."},
      {"speaker":"Hijo","spanish":"Tengo mucha hambre.","english":"I''m very hungry."},
      {"speaker":"Padre","spanish":"¿Te gusta la sopa?","english":"Do you like the soup?"},
      {"speaker":"Hijo","spanish":"Sí, me gusta mucho.","english":"Yes, I like it a lot."}
    ]'::jsonb,
    grammar_note = 'Spanish uses tener (to have) for hunger and thirst: Tengo hambre (literally "I have hunger"), Tengo sed ("I have thirst"). English uses "to be" for these, but in Spanish that would sound very strange.'
  where id = v_l3;

  update public.lessons set
    intro = 'Practice catching food-related phrases at native speed — at restaurants, you''ll need to hear "what would you like?" without missing a beat.',
    vocab_items = '[
      {"word":"¿Qué desea?","phonetic":"[keh deh-SEH-ah]","english":"What would you like?","example_es":"¿Qué desea de beber?","example_en":"What would you like to drink?"},
      {"word":"para beber","phonetic":"[PAH-rah beh-BEHR]","english":"to drink","example_es":"¿Y para beber?","example_en":"And to drink?"},
      {"word":"caliente","phonetic":"[kah-LYEHN-teh]","english":"hot","example_es":"La sopa está caliente.","example_en":"The soup is hot."},
      {"word":"frío / fría","phonetic":"[FREE-oh]","english":"cold","example_es":"Agua fría, por favor.","example_en":"Cold water, please."},
      {"word":"la cuenta","phonetic":"[lah KWEHN-tah]","english":"the bill","example_es":"La cuenta, por favor.","example_en":"The bill, please."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Camarero","spanish":"Buenas tardes. ¿Qué desea?","english":"Good afternoon. What would you like?"},
      {"speaker":"Cliente","spanish":"Una sopa caliente, por favor.","english":"A hot soup, please."},
      {"speaker":"Camarero","spanish":"¿Y para beber?","english":"And to drink?"},
      {"speaker":"Cliente","spanish":"Agua fría. Y la cuenta después.","english":"Cold water. And the bill afterwards."}
    ]'::jsonb,
    grammar_note = 'The polite formal form is ¿Qué desea? (What would you like?), using usted endings. The informal version with a friend would be ¿Qué quieres? — note the same -es ending that goes with tú.'
  where id = v_l4;

  update public.lessons set
    intro = 'Train your mouth on common food phrases. Try ordering as if you''re at a Spanish café right now.',
    vocab_items = '[
      {"word":"Quiero un café","phonetic":"[KYEH-roh oon kah-FEH]","english":"I want a coffee","example_es":"Quiero un café con leche.","example_en":"I want a coffee with milk."},
      {"word":"Me gusta el pan","phonetic":"[meh GOOS-tah ehl PAHN]","english":"I like bread","example_es":"Me gusta el pan fresco.","example_en":"I like fresh bread."},
      {"word":"Tengo hambre","phonetic":"[TEHN-goh AHM-breh]","english":"I''m hungry","example_es":"Tengo mucha hambre.","example_en":"I''m very hungry."},
      {"word":"La cuenta, por favor","phonetic":"[lah KWEHN-tah pohr fah-BOHR]","english":"The bill, please","example_es":"La cuenta, por favor.","example_en":"The bill, please."},
      {"word":"Gracias","phonetic":"[GRAH-syahs]","english":"Thank you","example_es":"Muchas gracias.","example_en":"Thank you very much."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"You","spanish":"Buenos días. Un café, por favor.","english":"Good morning. A coffee, please."},
      {"speaker":"Camarero","spanish":"¿Con leche o solo?","english":"With milk or black?"},
      {"speaker":"You","spanish":"Con leche.","english":"With milk."},
      {"speaker":"Camarero","spanish":"Aquí tiene.","english":"Here you are."}
    ]'::jsonb,
    grammar_note = 'Spanish C before E or I sounds like "S" in Latin America and like "TH" (English "th" in "think") in most of Spain. So café sounds the same everywhere, but cinco varies regionally.'
  where id = v_l5;

  update public.lessons set
    intro = 'Read this account of one person''s daily meals. Track what they eat at breakfast, lunch, and dinner.',
    vocab_items = '[
      {"word":"desayuno","phonetic":"[deh-sah-YOO-noh]","english":"breakfast","example_es":"El desayuno es importante.","example_en":"Breakfast is important."},
      {"word":"mediodía","phonetic":"[meh-dyoh-DEE-ah]","english":"noon","example_es":"Como al mediodía.","example_en":"I eat at noon."},
      {"word":"ensalada","phonetic":"[ehn-sah-LAH-dah]","english":"salad","example_es":"Una ensalada verde.","example_en":"A green salad."},
      {"word":"sopa","phonetic":"[SOH-pah]","english":"soup","example_es":"Sopa caliente.","example_en":"Hot soup."},
      {"word":"durante el día","phonetic":"[doo-RAHN-teh ehl DEE-ah]","english":"during the day","example_es":"Bebo agua durante el día.","example_en":"I drink water during the day."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Por la mañana, desayuno pan con queso y un café.","english":"In the morning, I have bread with cheese and a coffee."},
      {"speaker":"","spanish":"Al mediodía como ensalada y pollo.","english":"At noon I eat salad and chicken."},
      {"speaker":"","spanish":"Para cenar, prefiero sopa y fruta.","english":"For dinner, I prefer soup and fruit."},
      {"speaker":"","spanish":"Bebo mucha agua durante el día.","english":"I drink a lot of water during the day."}
    ]'::jsonb,
    grammar_note = 'Spanish has three meal verbs: desayunar (to have breakfast), comer (to have lunch / to eat), cenar (to have dinner). You don''t say "I have breakfast" — you just say desayuno (I breakfast).'
  where id = v_l6;

  update public.lessons set
    intro = 'Time to write your own food sentences. Use Quiero for orders, Me gusta for preferences, and Tengo hambre/sed for hunger/thirst.',
    vocab_items = '[
      {"word":"Quiero","phonetic":"[KYEH-roh]","english":"I want","example_es":"Quiero pan y agua.","example_en":"I want bread and water."},
      {"word":"Me gusta","phonetic":"[meh GOOS-tah]","english":"I like","example_es":"Me gusta el café.","example_en":"I like coffee."},
      {"word":"Como","phonetic":"[KOH-moh]","english":"I eat","example_es":"Como una manzana.","example_en":"I eat an apple."},
      {"word":"Bebo","phonetic":"[BEH-boh]","english":"I drink","example_es":"Bebo agua.","example_en":"I drink water."},
      {"word":"con / sin","phonetic":"[kohn / seen]","english":"with / without","example_es":"Café con leche, sin azúcar.","example_en":"Coffee with milk, without sugar."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Models","spanish":"Quiero un café con leche.","english":"I want a coffee with milk."},
      {"speaker":"","spanish":"Me gusta el pan fresco.","english":"I like fresh bread."},
      {"speaker":"","spanish":"Tengo mucha hambre.","english":"I''m very hungry."},
      {"speaker":"","spanish":"Bebo agua durante el día.","english":"I drink water during the day."}
    ]'::jsonb,
    grammar_note = 'Spanish verb endings tell you who is doing the action: como (I eat), comes (you eat), come (he/she eats). The pronoun yo, tú, él is usually dropped because the ending already shows who.'
  where id = v_l7;

  -- ============== A1.6 TIME ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Time';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'In this lesson you''ll learn the basic time vocabulary — hour, minute, day, week, year — that you''ll use in every conversation.',
    vocab_items = '[
      {"word":"hora","phonetic":"[OH-rah]","english":"hour","example_es":"Una hora más.","example_en":"One more hour."},
      {"word":"minuto","phonetic":"[mee-NOO-toh]","english":"minute","example_es":"Cinco minutos, por favor.","example_en":"Five minutes, please."},
      {"word":"día","phonetic":"[DEE-ah]","english":"day","example_es":"Un buen día.","example_en":"A good day."},
      {"word":"semana","phonetic":"[seh-MAH-nah]","english":"week","example_es":"Esta semana.","example_en":"This week."},
      {"word":"año","phonetic":"[AH-nyoh]","english":"year","example_es":"Este año.","example_en":"This year."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Lola","spanish":"¿Cuántas horas trabajas al día?","english":"How many hours do you work per day?"},
      {"speaker":"Iván","spanish":"Ocho horas, cinco días a la semana.","english":"Eight hours, five days a week."},
      {"speaker":"Lola","spanish":"¡Es mucho!","english":"That''s a lot!"},
      {"speaker":"Iván","spanish":"Sí, pero solo once meses al año.","english":"Yes, but only eleven months a year."}
    ]'::jsonb,
    grammar_note = 'Note the watch-out: día ends in -a but it''s masculine: el día, un buen día. Año has an ñ — don''t confuse with ano (without ñ), which means something else entirely.'
  where id = v_l1;

  update public.lessons set
    intro = 'Telling time in Spanish has one rule that surprises learners: use es la for one o''clock, but son las for everything else.',
    vocab_items = '[
      {"word":"Es la una","phonetic":"[ehs lah OO-nah]","english":"It''s 1 o''clock","example_es":"Es la una de la tarde.","example_en":"It''s 1 PM."},
      {"word":"Son las dos","phonetic":"[sohn lahs DOHS]","english":"It''s 2 o''clock","example_es":"Son las dos en punto.","example_en":"It''s 2 o''clock sharp."},
      {"word":"y media","phonetic":"[ee MEH-dyah]","english":"and a half","example_es":"Son las tres y media.","example_en":"It''s half past three."},
      {"word":"y cuarto","phonetic":"[ee KWAR-toh]","english":"and a quarter","example_es":"Son las cuatro y cuarto.","example_en":"It''s quarter past four."},
      {"word":"menos cuarto","phonetic":"[MEH-nohs KWAR-toh]","english":"quarter to","example_es":"Son las cinco menos cuarto.","example_en":"It''s quarter to five."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Pasajero","spanish":"¿Qué hora es?","english":"What time is it?"},
      {"speaker":"Empleado","spanish":"Son las tres y media.","english":"It''s half past three."},
      {"speaker":"Pasajero","spanish":"¿A qué hora sale el tren?","english":"What time does the train leave?"},
      {"speaker":"Empleado","spanish":"A las cuatro menos cuarto.","english":"At quarter to four."}
    ]'::jsonb,
    grammar_note = 'For one o''clock, the hour is singular (la una), so the verb is too: Es la una. For 2-12, the hours are plural (las dos, las tres…), so it''s Son las dos. The article matches: la for 1, las for the rest.'
  where id = v_l2;

  update public.lessons set
    intro = 'These are the conversational time phrases you''ll use to ask, plan, and refer to the time of day.',
    vocab_items = '[
      {"word":"¿Qué hora es?","phonetic":"[keh OH-rah ehs]","english":"What time is it?","example_es":"¿Qué hora es ya?","example_en":"What time is it now?"},
      {"word":"A las cinco","phonetic":"[ah lahs SEEN-koh]","english":"At 5 o''clock","example_es":"Nos vemos a las cinco.","example_en":"See you at five."},
      {"word":"por la mañana","phonetic":"[pohr lah mah-NYAH-nah]","english":"in the morning","example_es":"Trabajo por la mañana.","example_en":"I work in the morning."},
      {"word":"por la tarde","phonetic":"[pohr lah TAR-deh]","english":"in the afternoon","example_es":"Estudio por la tarde.","example_en":"I study in the afternoon."},
      {"word":"por la noche","phonetic":"[pohr lah NOH-cheh]","english":"at night","example_es":"Duermo por la noche.","example_en":"I sleep at night."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Ana","spanish":"¿Qué haces por la mañana?","english":"What do you do in the morning?"},
      {"speaker":"Beto","spanish":"Trabajo de ocho a dos.","english":"I work from eight to two."},
      {"speaker":"Ana","spanish":"¿Y por la tarde?","english":"And in the afternoon?"},
      {"speaker":"Beto","spanish":"Estudio español a las cinco.","english":"I study Spanish at five."}
    ]'::jsonb,
    grammar_note = 'When telling "at what time", Spanish uses a las + time: a las cinco (at five). When talking about a part of the day, use por la + time-of-day: por la mañana (in the morning).'
  where id = v_l3;

  update public.lessons set
    intro = 'Train your ear for spoken time announcements — stations, alarms, appointments — where you only have one chance to catch the hour.',
    vocab_items = '[
      {"word":"en punto","phonetic":"[ehn POON-toh]","english":"on the dot / sharp","example_es":"Son las tres en punto.","example_en":"It''s 3 sharp."},
      {"word":"tarde","phonetic":"[TAR-deh]","english":"late","example_es":"Es tarde.","example_en":"It''s late."},
      {"word":"temprano","phonetic":"[tehm-PRAH-noh]","english":"early","example_es":"Es muy temprano.","example_en":"It''s very early."},
      {"word":"ya","phonetic":"[YAH]","english":"already / now","example_es":"Ya es la hora.","example_en":"It''s already time."},
      {"word":"mediodía / medianoche","phonetic":"[meh-dyoh-DEE-ah / meh-dyah-NOH-cheh]","english":"noon / midnight","example_es":"A mediodía como.","example_en":"At noon I eat."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Anuncio","spanish":"El tren de las doce sale en cinco minutos.","english":"The twelve o''clock train leaves in five minutes."},
      {"speaker":"Pasajero","spanish":"¡Es tarde! Corre.","english":"It''s late! Run."},
      {"speaker":"Compañero","spanish":"Son las doce menos cinco. ¡Vamos!","english":"It''s five to twelve. Let''s go!"},
      {"speaker":"Anuncio","spanish":"Última llamada, andén tres.","english":"Last call, platform three."}
    ]'::jsonb,
    grammar_note = 'Time announcements often use de la mañana (AM), de la tarde (until ~7 PM), de la noche (PM). So "8 in the morning" = a las ocho de la mañana, and "8 at night" = a las ocho de la noche.'
  where id = v_l4;

  update public.lessons set
    intro = 'Practice saying times out loud. Native speakers don''t use "ten past" or "twenty to" — they just say the hour and the minutes.',
    vocab_items = '[
      {"word":"Son las cinco","phonetic":"[sohn lahs SEEN-koh]","english":"It''s 5 o''clock","example_es":"Son las cinco de la tarde.","example_en":"It''s 5 PM."},
      {"word":"Es la una","phonetic":"[ehs lah OO-nah]","english":"It''s 1 o''clock","example_es":"Es la una en punto.","example_en":"It''s 1 sharp."},
      {"word":"A las ocho","phonetic":"[ah lahs OH-choh]","english":"At 8","example_es":"Empieza a las ocho.","example_en":"It starts at 8."},
      {"word":"y diez","phonetic":"[ee DYEHS]","english":"ten past","example_es":"Son las dos y diez.","example_en":"It''s ten past two."},
      {"word":"menos veinte","phonetic":"[MEH-nohs BEHN-teh]","english":"twenty to","example_es":"Son las tres menos veinte.","example_en":"It''s twenty to three."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"You","spanish":"¿A qué hora es la clase?","english":"What time is the class?"},
      {"speaker":"Profe","spanish":"A las nueve y media.","english":"At 9:30."},
      {"speaker":"You","spanish":"¿Por la mañana?","english":"In the morning?"},
      {"speaker":"Profe","spanish":"Sí, a las nueve y media de la mañana.","english":"Yes, at 9:30 AM."}
    ]'::jsonb,
    grammar_note = 'Past 30 minutes, Spanish counts down to the next hour using menos: 2:40 = las tres menos veinte (twenty to three). This feels strange in English but is the standard pattern in most of the Spanish-speaking world.'
  where id = v_l5;

  update public.lessons set
    intro = 'Read about a typical workday. Notice how times anchor each activity throughout the text.',
    vocab_items = '[
      {"word":"hoy","phonetic":"[OY]","english":"today","example_es":"Hoy es lunes.","example_en":"Today is Monday."},
      {"word":"reunión","phonetic":"[reh-oo-NYOHN]","english":"meeting","example_es":"Tengo una reunión.","example_en":"I have a meeting."},
      {"word":"gimnasio","phonetic":"[heem-NAH-syoh]","english":"gym","example_es":"Voy al gimnasio.","example_en":"I go to the gym."},
      {"word":"ceno","phonetic":"[SEH-noh]","english":"I have dinner","example_es":"Ceno tarde.","example_en":"I have dinner late."},
      {"word":"voy","phonetic":"[BOY]","english":"I go","example_es":"Voy a casa.","example_en":"I go home."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Hoy es martes.","english":"Today is Tuesday."},
      {"speaker":"","spanish":"Son las nueve de la mañana. Tengo una reunión a las diez.","english":"It''s 9 AM. I have a meeting at 10."},
      {"speaker":"","spanish":"Por la tarde voy al gimnasio.","english":"In the afternoon I go to the gym."},
      {"speaker":"","spanish":"Por la noche ceno a las nueve.","english":"At night I have dinner at 9."}
    ]'::jsonb,
    grammar_note = 'Hoy es + day works like "today is": Hoy es lunes (Today is Monday). Use the simple present — no article in front of the day, because the day is acting like a complement, not a noun.'
  where id = v_l6;

  update public.lessons set
    intro = 'Write about your own day. Use a las for specific times and por la for times of day.',
    vocab_items = '[
      {"word":"Son las / Es la","phonetic":"[sohn lahs / ehs lah]","english":"It''s (time)","example_es":"Son las tres.","example_en":"It''s three."},
      {"word":"A las","phonetic":"[ah lahs]","english":"at (time)","example_es":"A las cinco.","example_en":"At five."},
      {"word":"por la mañana","phonetic":"[pohr lah mah-NYAH-nah]","english":"in the morning","example_es":"Estudio por la mañana.","example_en":"I study in the morning."},
      {"word":"de la tarde","phonetic":"[deh lah TAR-deh]","english":"in the afternoon (with time)","example_es":"A las cuatro de la tarde.","example_en":"At 4 PM."},
      {"word":"Hoy es","phonetic":"[oy ehs]","english":"Today is","example_es":"Hoy es viernes.","example_en":"Today is Friday."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Models","spanish":"Hoy es lunes.","english":"Today is Monday."},
      {"speaker":"","spanish":"Son las ocho de la mañana.","english":"It''s 8 AM."},
      {"speaker":"","spanish":"Tengo clase a las nueve.","english":"I have class at 9."},
      {"speaker":"","spanish":"Por la noche, ceno con mi familia.","english":"At night, I have dinner with my family."}
    ]'::jsonb,
    grammar_note = 'Don''t mix por la and de la. Por la mañana = "in the morning" (general). De la mañana attaches to a specific time: a las ocho de la mañana = "at 8 in the morning".'
  where id = v_l7;

  -- ============== A1.7 WEATHER ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Weather';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'Talking about the weather is the universal small-talk topic. You''ll learn how to describe sun, rain, cold, heat, and snow.',
    vocab_items = '[
      {"word":"sol","phonetic":"[SOHL]","english":"sun","example_es":"Hace sol hoy.","example_en":"It''s sunny today."},
      {"word":"lluvia","phonetic":"[YOO-byah]","english":"rain","example_es":"Mucha lluvia.","example_en":"A lot of rain."},
      {"word":"frío","phonetic":"[FREE-oh]","english":"cold","example_es":"Hace frío.","example_en":"It''s cold."},
      {"word":"calor","phonetic":"[kah-LOHR]","english":"heat","example_es":"Hace calor.","example_en":"It''s hot."},
      {"word":"nieve","phonetic":"[NYEH-beh]","english":"snow","example_es":"Hay nieve.","example_en":"There''s snow."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Niño","spanish":"¡Hace sol hoy!","english":"It''s sunny today!"},
      {"speaker":"Madre","spanish":"Sí, pero hace frío.","english":"Yes, but it''s cold."},
      {"speaker":"Niño","spanish":"Mañana, ¿hay nieve?","english":"Tomorrow, is there snow?"},
      {"speaker":"Madre","spanish":"Tal vez. La lluvia llega esta noche.","english":"Maybe. The rain arrives tonight."}
    ]'::jsonb,
    grammar_note = 'Spanish has three main weather verbs: hacer (to do/make), hay (there is), and llover/nevar (to rain/snow). Hace sol (it makes sun), hay nieve (there is snow), llueve (it rains).'
  where id = v_l1;

  update public.lessons set
    intro = 'The trickiest weather grammar: Spanish uses three different verbs (hacer, hay, estar) depending on what you''re describing.',
    vocab_items = '[
      {"word":"Hace + noun","phonetic":"[AH-seh]","english":"It is + weather","example_es":"Hace sol / Hace frío","example_en":"It''s sunny / It''s cold"},
      {"word":"Hay + noun","phonetic":"[I]","english":"There is + weather","example_es":"Hay nubes / Hay viento","example_en":"There are clouds / There''s wind"},
      {"word":"Está + adj","phonetic":"[ehs-TAH]","english":"It is + adj","example_es":"Está nublado.","example_en":"It''s cloudy."},
      {"word":"Llueve","phonetic":"[YWEH-beh]","english":"It rains","example_es":"Llueve mucho hoy.","example_en":"It''s raining a lot today."},
      {"word":"Nieva","phonetic":"[NYEH-bah]","english":"It snows","example_es":"Nieva en diciembre.","example_en":"It snows in December."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"A","spanish":"¿Qué tiempo hace?","english":"What''s the weather like?"},
      {"speaker":"B","spanish":"Hace mucho calor.","english":"It''s very hot."},
      {"speaker":"A","spanish":"¿Y mañana? ¿Está nublado?","english":"And tomorrow? Is it cloudy?"},
      {"speaker":"B","spanish":"No, pero hay viento.","english":"No, but it''s windy."}
    ]'::jsonb,
    grammar_note = 'Choose by what follows: noun → use hacer or hay (hace sol, hay nubes); adjective → use estar (está soleado). And single verbs for rain/snow: llueve, nieva.'
  where id = v_l2;

  update public.lessons set
    intro = 'These phrases come up daily — how is the weather, do I need a coat, will it rain?',
    vocab_items = '[
      {"word":"¿Qué tiempo hace?","phonetic":"[keh TYEHM-poh AH-seh]","english":"What''s the weather like?","example_es":"¿Qué tiempo hace hoy?","example_en":"What''s the weather today?"},
      {"word":"Hace buen tiempo","phonetic":"[AH-seh BWEHN TYEHM-poh]","english":"The weather is good","example_es":"Hoy hace buen tiempo.","example_en":"The weather is good today."},
      {"word":"Hace mal tiempo","phonetic":"[AH-seh MAHL TYEHM-poh]","english":"The weather is bad","example_es":"Hace mal tiempo, no salgo.","example_en":"Weather''s bad, I''m not going out."},
      {"word":"Tengo frío","phonetic":"[TEHN-goh FREE-oh]","english":"I''m cold","example_es":"Tengo mucho frío.","example_en":"I''m very cold."},
      {"word":"Tengo calor","phonetic":"[TEHN-goh kah-LOHR]","english":"I''m hot","example_es":"Tengo calor, abre la ventana.","example_en":"I''m hot, open the window."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Mar","spanish":"¡Qué calor! ¿Quieres ir a la playa?","english":"It''s so hot! Do you want to go to the beach?"},
      {"speaker":"Lía","spanish":"Sí, pero esta tarde llueve.","english":"Yes, but this afternoon it rains."},
      {"speaker":"Mar","spanish":"¿En serio? ¡Hace tan buen tiempo!","english":"Really? The weather''s so nice!"},
      {"speaker":"Lía","spanish":"Mira el cielo, ya hay nubes.","english":"Look at the sky, there are already clouds."}
    ]'::jsonb,
    grammar_note = 'There''s a key distinction: HACE frío = "it''s cold (weather)", TENGO frío = "I''m cold (person)". Same for calor. The weather uses hace; people use tener.'
  where id = v_l3;

  update public.lessons set
    intro = 'Weather forecasts come at you fast. This lesson tunes your ear for the most common spoken weather phrases.',
    vocab_items = '[
      {"word":"está nublado","phonetic":"[ehs-TAH noo-BLAH-doh]","english":"it''s cloudy","example_es":"Hoy está nublado.","example_en":"Today is cloudy."},
      {"word":"despejado","phonetic":"[dehs-peh-HAH-doh]","english":"clear (sky)","example_es":"El cielo está despejado.","example_en":"The sky is clear."},
      {"word":"va a llover","phonetic":"[bah ah yoh-BEHR]","english":"it''s going to rain","example_es":"Mañana va a llover.","example_en":"Tomorrow it''s going to rain."},
      {"word":"tormenta","phonetic":"[tohr-MEHN-tah]","english":"storm","example_es":"Hay una tormenta.","example_en":"There''s a storm."},
      {"word":"grados","phonetic":"[GRAH-dohs]","english":"degrees","example_es":"Treinta grados hoy.","example_en":"Thirty degrees today."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Anuncio","spanish":"En Madrid, treinta grados y sol.","english":"In Madrid, thirty degrees and sun."},
      {"speaker":"","spanish":"En Barcelona, está nublado.","english":"In Barcelona, it''s cloudy."},
      {"speaker":"","spanish":"En el norte, va a llover esta tarde.","english":"In the north, it''s going to rain this afternoon."},
      {"speaker":"","spanish":"Mañana, mucho frío en toda España.","english":"Tomorrow, a lot of cold all over Spain."}
    ]'::jsonb,
    grammar_note = 'For future weather, Spanish often uses va a + infinitive instead of the full future tense: va a llover (it''s going to rain), va a hacer frío (it''s going to be cold).'
  where id = v_l4;

  update public.lessons set
    intro = 'Saying the weather aloud is great practice for vowel rhythm. Notice how stress lands clearly on each syllable.',
    vocab_items = '[
      {"word":"Hace mucho sol","phonetic":"[AH-seh MOO-choh SOHL]","english":"It''s very sunny","example_es":"Hoy hace mucho sol.","example_en":"Today it''s very sunny."},
      {"word":"Llueve","phonetic":"[YWEH-beh]","english":"It''s raining","example_es":"Llueve sin parar.","example_en":"It''s raining non-stop."},
      {"word":"Tengo frío","phonetic":"[TEHN-goh FREE-oh]","english":"I''m cold","example_es":"Tengo mucho frío.","example_en":"I''m very cold."},
      {"word":"Hace buen tiempo","phonetic":"[AH-seh BWEHN TYEHM-poh]","english":"Nice weather","example_es":"Hoy hace buen tiempo.","example_en":"The weather is nice today."},
      {"word":"Va a nevar","phonetic":"[bah ah neh-BAHR]","english":"It''s going to snow","example_es":"Mañana va a nevar.","example_en":"Tomorrow it''s going to snow."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"You","spanish":"¡Hace mucho frío hoy!","english":"It''s very cold today!"},
      {"speaker":"Amigo","spanish":"Sí, y va a nevar.","english":"Yes, and it''s going to snow."},
      {"speaker":"You","spanish":"Tengo mucho frío.","english":"I''m very cold."},
      {"speaker":"Amigo","spanish":"Yo también. Vamos a casa.","english":"Me too. Let''s go home."}
    ]'::jsonb,
    grammar_note = 'Spanish frío has a written accent on the í because we stress that vowel: FRÍ-oh, two syllables. Without the accent, frio would just be one syllable.'
  where id = v_l5;

  update public.lessons set
    intro = 'Read the forecast and pick out the temperature, conditions, and what tomorrow holds.',
    vocab_items = '[
      {"word":"hoy","phonetic":"[OY]","english":"today","example_es":"Hoy hace sol.","example_en":"Today is sunny."},
      {"word":"temperatura","phonetic":"[tehm-peh-rah-TOO-rah]","english":"temperature","example_es":"La temperatura sube.","example_en":"The temperature rises."},
      {"word":"viento","phonetic":"[BYEHN-toh]","english":"wind","example_es":"No hay viento.","example_en":"There''s no wind."},
      {"word":"verano","phonetic":"[beh-RAH-noh]","english":"summer","example_es":"En verano hace calor.","example_en":"In summer it''s hot."},
      {"word":"porque","phonetic":"[POHR-keh]","english":"because","example_es":"Me gusta porque hace sol.","example_en":"I like it because it''s sunny."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Hoy hace mucho sol.","english":"Today it''s very sunny."},
      {"speaker":"","spanish":"La temperatura es de treinta grados.","english":"The temperature is 30 degrees."},
      {"speaker":"","spanish":"No llueve y no hay viento.","english":"It''s not raining and there''s no wind."},
      {"speaker":"","spanish":"Mañana va a llover.","english":"Tomorrow it''s going to rain."}
    ]'::jsonb,
    grammar_note = 'Spanish often connects sentences with porque (because) without commas: Me gusta el verano porque hace calor. English would need a comma; Spanish often skips it.'
  where id = v_l6;

  update public.lessons set
    intro = 'Try writing a weather diary. Pick today, tomorrow, and a season — what verbs do you need for each?',
    vocab_items = '[
      {"word":"Hace + noun","phonetic":"[AH-seh]","english":"It is (weather)","example_es":"Hace sol.","example_en":"It''s sunny."},
      {"word":"Está + adj","phonetic":"[ehs-TAH]","english":"It is (cloudy etc.)","example_es":"Está nublado.","example_en":"It''s cloudy."},
      {"word":"Llueve / Nieva","phonetic":"[YWEH-beh / NYEH-bah]","english":"It rains / snows","example_es":"Hoy llueve.","example_en":"Today it rains."},
      {"word":"Va a + inf","phonetic":"[bah ah]","english":"is going to","example_es":"Va a llover.","example_en":"It''s going to rain."},
      {"word":"en verano / invierno","phonetic":"[ehn beh-RAH-noh / een-BYEHR-noh]","english":"in summer / winter","example_es":"En verano hace calor.","example_en":"In summer it''s hot."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Models","spanish":"Hoy hace mucho sol.","english":"Today it''s very sunny."},
      {"speaker":"","spanish":"Mañana va a llover.","english":"Tomorrow it''s going to rain."},
      {"speaker":"","spanish":"En invierno nieva.","english":"In winter it snows."},
      {"speaker":"","spanish":"Tengo frío en diciembre.","english":"I''m cold in December."}
    ]'::jsonb,
    grammar_note = 'Seasons in Spanish are lowercase, unlike days and months in some languages: verano, otoño, invierno, primavera. They take en for "in": en verano, en otoño.'
  where id = v_l7;

  -- ============== A1.8 SHOPPING ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Shopping';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'These are the basic shopping words for stores, prices, and money. Master them and you can shop anywhere.',
    vocab_items = '[
      {"word":"tienda","phonetic":"[TYEHN-dah]","english":"shop / store","example_es":"Voy a la tienda.","example_en":"I''m going to the shop."},
      {"word":"comprar","phonetic":"[kohm-PRAHR]","english":"to buy","example_es":"Quiero comprar pan.","example_en":"I want to buy bread."},
      {"word":"dinero","phonetic":"[dee-NEH-roh]","english":"money","example_es":"No tengo dinero.","example_en":"I have no money."},
      {"word":"precio","phonetic":"[PREH-syoh]","english":"price","example_es":"¿Cuál es el precio?","example_en":"What''s the price?"},
      {"word":"caro / barato","phonetic":"[KAH-roh / bah-RAH-toh]","english":"expensive / cheap","example_es":"Es caro pero bonito.","example_en":"It''s expensive but pretty."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Cliente","spanish":"¿Dónde está la tienda de pan?","english":"Where''s the bread shop?"},
      {"speaker":"Vecino","spanish":"Está aquí cerca, en la esquina.","english":"It''s nearby, on the corner."},
      {"speaker":"Cliente","spanish":"¿Es cara?","english":"Is it expensive?"},
      {"speaker":"Vecino","spanish":"No, es muy barata.","english":"No, it''s very cheap."}
    ]'::jsonb,
    grammar_note = 'Tienda de + noun creates a compound: tienda de pan (bread shop), tienda de ropa (clothing store), tienda de música (music shop).'
  where id = v_l1;

  update public.lessons set
    intro = 'Asking prices is the most useful skill at any market or shop. Learn the question pattern and a few key answers.',
    vocab_items = '[
      {"word":"¿Cuánto cuesta?","phonetic":"[KWAHN-toh KWEHS-tah]","english":"How much does it cost?","example_es":"¿Cuánto cuesta el pan?","example_en":"How much is the bread?"},
      {"word":"¿Cuánto es?","phonetic":"[KWAHN-toh ehs]","english":"How much is it?","example_es":"¿Cuánto es en total?","example_en":"How much in total?"},
      {"word":"Son ... euros","phonetic":"[sohn ... EH-oo-rohs]","english":"It''s ... euros","example_es":"Son diez euros.","example_en":"That''s ten euros."},
      {"word":"con tarjeta / en efectivo","phonetic":"[kohn tahr-HEH-tah / ehn eh-fehk-TEE-boh]","english":"by card / in cash","example_es":"Pago con tarjeta.","example_en":"I pay by card."},
      {"word":"cambio","phonetic":"[KAHM-byoh]","english":"change","example_es":"¿Tiene cambio?","example_en":"Do you have change?"}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Cajera","spanish":"Buenas tardes. ¿Es todo?","english":"Good afternoon. Is that all?"},
      {"speaker":"Cliente","spanish":"Sí. ¿Cuánto es?","english":"Yes. How much is it?"},
      {"speaker":"Cajera","spanish":"Son diez euros con cincuenta.","english":"That''s 10 euros 50."},
      {"speaker":"Cliente","spanish":"Pago con tarjeta.","english":"I''ll pay by card."}
    ]'::jsonb,
    grammar_note = 'Cuesta (it costs) is singular — for one item. For more than one, use cuestan: ¿Cuánto cuestan las manzanas? Both items have the same root: cost-.'
  where id = v_l2;

  update public.lessons set
    intro = 'These polite phrases will get you through any Spanish-speaking shop, from a market stall to a big store.',
    vocab_items = '[
      {"word":"Quiero esto","phonetic":"[KYEH-roh EHS-toh]","english":"I want this","example_es":"Quiero esto, por favor.","example_en":"I want this, please."},
      {"word":"¿Tiene ...?","phonetic":"[TYEH-neh]","english":"Do you have ...?","example_es":"¿Tiene leche?","example_en":"Do you have milk?"},
      {"word":"Más barato","phonetic":"[MAHS bah-RAH-toh]","english":"cheaper","example_es":"¿Tiene algo más barato?","example_en":"Do you have something cheaper?"},
      {"word":"Otro / Otra","phonetic":"[OH-troh / OH-trah]","english":"another","example_es":"Quiero otro café.","example_en":"I want another coffee."},
      {"word":"Aquí tiene","phonetic":"[ah-KEE TYEH-neh]","english":"Here you go","example_es":"Aquí tiene su cambio.","example_en":"Here''s your change."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Cliente","spanish":"¿Tiene este libro en español?","english":"Do you have this book in Spanish?"},
      {"speaker":"Librero","spanish":"Sí, aquí tiene.","english":"Yes, here you go."},
      {"speaker":"Cliente","spanish":"¿Cuánto cuesta?","english":"How much is it?"},
      {"speaker":"Librero","spanish":"Quince euros.","english":"Fifteen euros."}
    ]'::jsonb,
    grammar_note = 'Spanish demonstratives change with the noun: este libro (m.), esta camisa (f.), estos zapatos (m.pl), estas flores (f.pl). Esto is neutral, used when the noun isn''t named.'
  where id = v_l3;

  update public.lessons set
    intro = 'At the cash register, listen for prices and questions about your payment method. Speed matters.',
    vocab_items = '[
      {"word":"Aceptamos","phonetic":"[ah-sehp-TAH-mohs]","english":"We accept","example_es":"Aceptamos tarjeta.","example_en":"We accept card."},
      {"speaker":"","word":"recibo","phonetic":"[reh-SEE-boh]","english":"receipt","example_es":"¿Quiere el recibo?","example_en":"Do you want the receipt?"},
      {"word":"bolsa","phonetic":"[BOHL-sah]","english":"bag","example_es":"¿Necesita bolsa?","example_en":"Do you need a bag?"},
      {"word":"oferta","phonetic":"[oh-FEHR-tah]","english":"sale / offer","example_es":"Está en oferta.","example_en":"It''s on sale."},
      {"word":"descuento","phonetic":"[dehs-KWEHN-toh]","english":"discount","example_es":"Hay un descuento.","example_en":"There''s a discount."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Cajera","spanish":"Son veinte euros.","english":"That''s twenty euros."},
      {"speaker":"Cliente","spanish":"¿Aceptan tarjeta?","english":"Do you take card?"},
      {"speaker":"Cajera","spanish":"Sí. ¿Necesita bolsa?","english":"Yes. Do you need a bag?"},
      {"speaker":"Cliente","spanish":"No, gracias. ¿Y el recibo?","english":"No, thanks. And the receipt?"}
    ]'::jsonb,
    grammar_note = 'Spanish stores use formal usted by default with customers: ¿Quiere usted bolsa? You''ll hear endings like quiere, necesita, acepta — these are the usted forms.'
  where id = v_l4;

  update public.lessons set
    intro = 'Practice the polite shop interactions. Confidence comes from a few solid phrases said cleanly.',
    vocab_items = '[
      {"word":"¿Cuánto cuesta?","phonetic":"[KWAHN-toh KWEHS-tah]","english":"How much?","example_es":"¿Cuánto cuesta esto?","example_en":"How much is this?"},
      {"word":"Quiero comprar","phonetic":"[KYEH-roh kohm-PRAHR]","english":"I want to buy","example_es":"Quiero comprar pan.","example_en":"I want to buy bread."},
      {"word":"Es muy caro","phonetic":"[ehs MWEE KAH-roh]","english":"It''s very expensive","example_es":"Es muy caro para mí.","example_en":"It''s too expensive for me."},
      {"word":"Pago con tarjeta","phonetic":"[PAH-goh kohn tahr-HEH-tah]","english":"I pay by card","example_es":"Pago con tarjeta, gracias.","example_en":"I''ll pay by card, thanks."},
      {"word":"Hasta luego","phonetic":"[AHS-tah LWEH-goh]","english":"See you later","example_es":"Gracias, hasta luego.","example_en":"Thanks, see you later."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"You","spanish":"Hola, ¿cuánto cuesta?","english":"Hi, how much is it?"},
      {"speaker":"Vendedor","spanish":"Cinco euros.","english":"Five euros."},
      {"speaker":"You","spanish":"Vale, pago con tarjeta.","english":"OK, I''ll pay by card."},
      {"speaker":"Vendedor","spanish":"Aquí tiene. Gracias.","english":"Here you are. Thanks."}
    ]'::jsonb,
    grammar_note = 'Vale (literally "it''s worth") is the most common Spanish word for "OK" in Spain. In Latin America you''ll hear bueno, dale, listo. All work as confirmation.'
  where id = v_l5;

  update public.lessons set
    intro = 'A short story of a Saturday market trip. Notice how the speaker uses different verbs to describe each step.',
    vocab_items = '[
      {"word":"voy a","phonetic":"[BOY ah]","english":"I go to","example_es":"Voy a la tienda.","example_en":"I go to the shop."},
      {"word":"con","phonetic":"[kohn]","english":"with","example_es":"Voy con mi madre.","example_en":"I go with my mother."},
      {"word":"cerca de","phonetic":"[SEHR-kah deh]","english":"near","example_es":"Cerca de mi casa.","example_en":"Near my house."},
      {"word":"compramos","phonetic":"[kohm-PRAH-mohs]","english":"we buy","example_es":"Compramos fruta.","example_en":"We buy fruit."},
      {"word":"pagamos","phonetic":"[pah-GAH-mohs]","english":"we pay","example_es":"Pagamos en efectivo.","example_en":"We pay in cash."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Voy a la tienda con mi madre.","english":"I go to the shop with my mother."},
      {"speaker":"","spanish":"Compramos pan, leche y manzanas.","english":"We buy bread, milk and apples."},
      {"speaker":"","spanish":"El pan cuesta dos euros.","english":"The bread costs two euros."},
      {"speaker":"","spanish":"Pagamos con tarjeta. La tienda está cerca de mi casa.","english":"We pay by card. The shop is near my house."}
    ]'::jsonb,
    grammar_note = 'Ir a + place becomes voy a + place (I go to + place). The contraction al (= a + el) only happens with masculine articles: voy al mercado (a + el mercado), but voy a la tienda stays separate.'
  where id = v_l6;

  update public.lessons set
    intro = 'Write your own shopping conversation. Use Spanish punctuation: ¿ at the start of questions and the regular ? at the end.',
    vocab_items = '[
      {"word":"¿Cuánto cuesta?","phonetic":"[KWAHN-toh KWEHS-tah]","english":"How much?","example_es":"¿Cuánto cuesta este libro?","example_en":"How much is this book?"},
      {"word":"Quiero comprar","phonetic":"[KYEH-roh kohm-PRAHR]","english":"I want to buy","example_es":"Quiero comprar leche.","example_en":"I want to buy milk."},
      {"word":"por favor","phonetic":"[pohr fah-BOHR]","english":"please","example_es":"Un café, por favor.","example_en":"A coffee, please."},
      {"word":"gracias","phonetic":"[GRAH-syahs]","english":"thank you","example_es":"Muchas gracias.","example_en":"Thanks a lot."},
      {"word":"tarjeta","phonetic":"[tahr-HEH-tah]","english":"card","example_es":"Pago con tarjeta.","example_en":"I pay by card."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Models","spanish":"Hola, quiero comprar pan.","english":"Hi, I want to buy bread."},
      {"speaker":"","spanish":"¿Cuánto cuesta?","english":"How much does it cost?"},
      {"speaker":"","spanish":"Pago con tarjeta, por favor.","english":"I''ll pay by card, please."},
      {"speaker":"","spanish":"Gracias, hasta luego.","english":"Thanks, see you later."}
    ]'::jsonb,
    grammar_note = 'Polite shopping phrases always need por favor at the end. It''s not optional like English "please" — it''s expected in every formal request.'
  where id = v_l7;

  -- ============== A1.9 ANIMALS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Animals';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'Pets and farm animals are everyday vocabulary. This lesson covers the most common ones you''ll hear in real conversation.',
    vocab_items = '[
      {"word":"perro","phonetic":"[PEH-rroh]","english":"dog","example_es":"Mi perro es grande.","example_en":"My dog is big."},
      {"word":"gato","phonetic":"[GAH-toh]","english":"cat","example_es":"Tengo un gato.","example_en":"I have a cat."},
      {"word":"pájaro","phonetic":"[PAH-hah-roh]","english":"bird","example_es":"Un pájaro canta.","example_en":"A bird sings."},
      {"word":"pez","phonetic":"[PEHS]","english":"fish (live)","example_es":"Un pez azul.","example_en":"A blue fish."},
      {"word":"caballo","phonetic":"[kah-BAH-yoh]","english":"horse","example_es":"Un caballo blanco.","example_en":"A white horse."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Bea","spanish":"Mira mi perro nuevo.","english":"Look at my new dog."},
      {"speaker":"Tom","spanish":"¡Qué bonito! ¿Cómo se llama?","english":"How cute! What''s his name?"},
      {"speaker":"Bea","spanish":"Se llama Luna. Es muy joven.","english":"Her name is Luna. She''s very young."},
      {"speaker":"Tom","spanish":"Yo tengo un gato negro.","english":"I have a black cat."}
    ]'::jsonb,
    grammar_note = 'Most animal names have a feminine form: perro/perra, gato/gata, caballo/yegua. When you don''t know the sex, use the masculine: Tengo un perro can refer to either a male or female dog.'
  where id = v_l1;

  update public.lessons set
    intro = 'Most Spanish nouns ending in -o are masculine and most ending in -a are feminine. Animals follow this rule cleanly.',
    vocab_items = '[
      {"word":"el perro","phonetic":"[ehl PEH-rroh]","english":"the dog","example_es":"El perro come.","example_en":"The dog eats."},
      {"word":"la perra","phonetic":"[lah PEH-rrah]","english":"the female dog","example_es":"La perra duerme.","example_en":"The female dog sleeps."},
      {"word":"el gato","phonetic":"[ehl GAH-toh]","english":"the cat","example_es":"El gato juega.","example_en":"The cat plays."},
      {"word":"la gata","phonetic":"[lah GAH-tah]","english":"the female cat","example_es":"La gata duerme.","example_en":"The female cat sleeps."},
      {"word":"los / las","phonetic":"[lohs / lahs]","english":"the (plural)","example_es":"los perros / las gatas","example_en":"the dogs / the female cats"}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Niña","spanish":"¿Es un perro o una perra?","english":"Is it a (male) dog or a (female) dog?"},
      {"speaker":"Padre","spanish":"Es una perra. Se llama Lila.","english":"It''s a female dog. Her name is Lila."},
      {"speaker":"Niña","spanish":"¿Y el gato?","english":"And the cat?"},
      {"speaker":"Padre","spanish":"El gato es macho. Se llama Tom.","english":"The cat is male. His name is Tom."}
    ]'::jsonb,
    grammar_note = 'Some animal names don''t change: el pez (the fish), la rana (the frog) — gender is fixed regardless of the actual animal. Add macho (male) or hembra (female) when you need to specify.'
  where id = v_l2;

  update public.lessons set
    intro = 'Real conversations about pets and animals. Practice expressing what you have, what you like, and what scares you.',
    vocab_items = '[
      {"word":"Tengo un perro","phonetic":"[TEHN-goh oon PEH-rroh]","english":"I have a dog","example_es":"Tengo un perro pequeño.","example_en":"I have a small dog."},
      {"word":"Me gustan los gatos","phonetic":"[meh GOOS-tahn lohs GAH-tohs]","english":"I like cats","example_es":"Me gustan mucho los gatos.","example_en":"I really like cats."},
      {"word":"¿Tienes mascota?","phonetic":"[TYEH-nehs mahs-KOH-tah]","english":"Do you have a pet?","example_es":"¿Tienes mascota en casa?","example_en":"Do you have a pet at home?"},
      {"word":"mascota","phonetic":"[mahs-KOH-tah]","english":"pet","example_es":"Mi mascota es un gato.","example_en":"My pet is a cat."},
      {"word":"miedo","phonetic":"[MYEH-doh]","english":"fear","example_es":"Tengo miedo a los perros.","example_en":"I''m afraid of dogs."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Eli","spanish":"¿Tienes mascota?","english":"Do you have a pet?"},
      {"speaker":"Dan","spanish":"Sí, tengo dos gatos.","english":"Yes, I have two cats."},
      {"speaker":"Eli","spanish":"¡Me encantan los gatos!","english":"I love cats!"},
      {"speaker":"Dan","spanish":"Yo tengo miedo a los perros grandes.","english":"I''m afraid of big dogs."}
    ]'::jsonb,
    grammar_note = 'Me gusta vs me gustan: use gusta with a singular thing (Me gusta el gato), and gustan with plural (Me gustan los gatos). The verb agrees with what is liked, not with you.'
  where id = v_l3;

  update public.lessons set
    intro = 'Listen for what kind of animal someone has, and how it''s described. Adjectives can flip meaning fast.',
    vocab_items = '[
      {"word":"grande","phonetic":"[GRAHN-deh]","english":"big","example_es":"Un perro grande.","example_en":"A big dog."},
      {"word":"pequeño / pequeña","phonetic":"[peh-KEH-nyoh]","english":"small","example_es":"Un gato pequeño.","example_en":"A small cat."},
      {"word":"bonito / bonita","phonetic":"[boh-NEE-toh]","english":"cute / pretty","example_es":"Un pájaro bonito.","example_en":"A pretty bird."},
      {"word":"viejo / vieja","phonetic":"[BYEH-hoh]","english":"old","example_es":"Mi perro es viejo.","example_en":"My dog is old."},
      {"word":"joven","phonetic":"[HOH-behn]","english":"young","example_es":"Mi gato es joven.","example_en":"My cat is young."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"A","spanish":"Mi nuevo perro es muy pequeño.","english":"My new dog is very small."},
      {"speaker":"B","spanish":"¿Es joven o viejo?","english":"Is it young or old?"},
      {"speaker":"A","spanish":"Tiene seis meses. Es muy bonito.","english":"He''s six months old. He''s very cute."},
      {"speaker":"B","spanish":"Yo prefiero los perros grandes.","english":"I prefer big dogs."}
    ]'::jsonb,
    grammar_note = 'Grande shortens to gran when it goes BEFORE the noun: un gran perro (a great dog) — meaning "great", not "big". After the noun it keeps its full form and means "big": un perro grande.'
  where id = v_l4;

  update public.lessons set
    intro = 'Practice introducing your animal and describing it out loud — pet talk is universal small talk.',
    vocab_items = '[
      {"word":"Tengo un perro","phonetic":"[TEHN-goh oon PEH-rroh]","english":"I have a dog","example_es":"Tengo un perro marrón.","example_en":"I have a brown dog."},
      {"word":"Se llama","phonetic":"[seh YAH-mah]","english":"is called","example_es":"Se llama Toby.","example_en":"His name is Toby."},
      {"word":"Es muy joven","phonetic":"[ehs MWEE HOH-behn]","english":"He''s very young","example_es":"Tiene dos años.","example_en":"He''s two years old."},
      {"word":"Me gustan","phonetic":"[meh GOOS-tahn]","english":"I like (plural)","example_es":"Me gustan los animales.","example_en":"I like animals."},
      {"word":"No tengo mascota","phonetic":"[noh TEHN-goh mahs-KOH-tah]","english":"I don''t have a pet","example_es":"No tengo mascota en casa.","example_en":"I don''t have a pet at home."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"You","spanish":"Tengo un perro pequeño.","english":"I have a small dog."},
      {"speaker":"Friend","spanish":"¿Cómo se llama?","english":"What''s his name?"},
      {"speaker":"You","spanish":"Se llama Max. Es muy joven.","english":"His name is Max. He''s very young."},
      {"speaker":"Friend","spanish":"¡Qué bonito!","english":"How cute!"}
    ]'::jsonb,
    grammar_note = 'The double R in perro is rolled — vibrating the tongue against the roof of the mouth. The single R in pero (but) is just one tap. Mix them up and the word changes meaning!'
  where id = v_l5;

  update public.lessons set
    intro = 'Read about a household full of animals. See how the speaker uses different verbs to describe and possess.',
    vocab_items = '[
      {"word":"vive","phonetic":"[BEE-beh]","english":"lives","example_es":"Vive con mi familia.","example_en":"She lives with my family."},
      {"word":"se llama","phonetic":"[seh YAH-mah]","english":"is called","example_es":"Se llama Max.","example_en":"His name is Max."},
      {"word":"grande","phonetic":"[GRAHN-deh]","english":"big","example_es":"Es muy grande.","example_en":"He''s very big."},
      {"word":"también","phonetic":"[tahm-BYEHN]","english":"also","example_es":"También tengo un pájaro.","example_en":"I also have a bird."},
      {"word":"me gustan","phonetic":"[meh GOOS-tahn]","english":"I like (plural)","example_es":"Me gustan los animales.","example_en":"I like animals."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"En mi casa vive un perro y dos gatos.","english":"In my house there''s one dog and two cats."},
      {"speaker":"","spanish":"El perro se llama Max y es muy grande.","english":"The dog is named Max and he''s very big."},
      {"speaker":"","spanish":"Los gatos son pequeños y negros.","english":"The cats are small and black."},
      {"speaker":"","spanish":"También tengo un pájaro azul.","english":"I also have a blue bird."}
    ]'::jsonb,
    grammar_note = 'En mi casa vive + animal works for naming what lives somewhere. Note the verb is singular vive even though more pets might follow — Spanish often agrees only with the first noun mentioned.'
  where id = v_l6;

  update public.lessons set
    intro = 'Time to write your own pet introduction. Pick an animal, give it a name and a color, and describe it in two or three sentences.',
    vocab_items = '[
      {"word":"Tengo un / una","phonetic":"[TEHN-goh oon / OO-nah]","english":"I have a (m./f.)","example_es":"Tengo un perro.","example_en":"I have a dog."},
      {"word":"Es","phonetic":"[ehs]","english":"is (essence)","example_es":"Es marrón.","example_en":"It''s brown."},
      {"word":"Mi perro","phonetic":"[mee PEH-rroh]","english":"My dog","example_es":"Mi perro es joven.","example_en":"My dog is young."},
      {"word":"Me gustan los","phonetic":"[meh GOOS-tahn lohs]","english":"I like (pl.)","example_es":"Me gustan los gatos.","example_en":"I like cats."},
      {"word":"Vive en","phonetic":"[BEE-beh ehn]","english":"lives in","example_es":"Vive en el jardín.","example_en":"He lives in the garden."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Models","spanish":"Tengo un gato. Se llama Mochi.","english":"I have a cat. His name is Mochi."},
      {"speaker":"","spanish":"Es pequeño y negro.","english":"He''s small and black."},
      {"speaker":"","spanish":"Vive en mi casa con mi familia.","english":"He lives in my house with my family."},
      {"speaker":"","spanish":"Me encantan los gatos.","english":"I love cats."}
    ]'::jsonb,
    grammar_note = 'Me encanta(n) is a stronger version of me gusta: literally "it enchants me", colloquially "I love it". Same agreement: encanta with singular, encantan with plural.'
  where id = v_l7;

  -- ============== A1.10 BODY PARTS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Body Parts';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'You''ll learn the main parts of the body — head, eyes, hands, feet, arms — so you can describe yourself or explain where something hurts.',
    vocab_items = '[
      {"word":"cabeza","phonetic":"[kah-BEH-sah]","english":"head","example_es":"Me toco la cabeza.","example_en":"I touch my head."},
      {"word":"ojo","phonetic":"[OH-hoh]","english":"eye","example_es":"Tengo los ojos azules.","example_en":"I have blue eyes."},
      {"word":"mano","phonetic":"[MAH-noh]","english":"hand","example_es":"Mi mano derecha.","example_en":"My right hand."},
      {"word":"pie","phonetic":"[PYEH]","english":"foot","example_es":"Me lavo los pies.","example_en":"I wash my feet."},
      {"word":"brazo","phonetic":"[BRAH-soh]","english":"arm","example_es":"Levanta el brazo.","example_en":"Raise your arm."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Niño","spanish":"¿Qué es esto?","english":"What is this?"},
      {"speaker":"Profe","spanish":"Eso es la mano.","english":"That is the hand."},
      {"speaker":"Niño","spanish":"¿Y esto?","english":"And this?"},
      {"speaker":"Profe","spanish":"Eso es el pie.","english":"That is the foot."}
    ]'::jsonb,
    grammar_note = 'Mano ends in -o but is feminine: la mano, mi mano. It''s one of the few exceptions to the -o = masculine rule. Pie is irregular plural: el pie / los pies.'
  where id = v_l1;

  update public.lessons set
    intro = 'When something hurts, Spanish doesn''t say "my head hurts" — it says "me duele la cabeza" (it pains me, the head). Learn this pattern.',
    vocab_items = '[
      {"word":"Me duele","phonetic":"[meh DWEH-leh]","english":"hurts me (sg)","example_es":"Me duele la cabeza.","example_en":"My head hurts."},
      {"word":"Me duelen","phonetic":"[meh DWEH-lehn]","english":"hurt me (pl)","example_es":"Me duelen los pies.","example_en":"My feet hurt."},
      {"word":"Te duele","phonetic":"[teh DWEH-leh]","english":"hurts you","example_es":"¿Te duele algo?","example_en":"Does something hurt you?"},
      {"word":"el dolor","phonetic":"[ehl doh-LOHR]","english":"the pain","example_es":"Un dolor fuerte.","example_en":"A strong pain."},
      {"word":"todo el cuerpo","phonetic":"[TOH-doh ehl KWEHR-poh]","english":"the whole body","example_es":"Me duele todo el cuerpo.","example_en":"My whole body hurts."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Madre","spanish":"¿Estás bien? ¿Te duele algo?","english":"Are you OK? Does something hurt?"},
      {"speaker":"Hijo","spanish":"Me duele la cabeza.","english":"My head hurts."},
      {"speaker":"Madre","spanish":"¿Y los ojos?","english":"And the eyes?"},
      {"speaker":"Hijo","spanish":"Sí, también me duelen los ojos.","english":"Yes, my eyes hurt too."}
    ]'::jsonb,
    grammar_note = 'Doler works like gustar: the body part is the subject, you are the object. Me duele LA cabeza, not MI cabeza — Spanish uses the definite article (the) with body parts, never the possessive (my).'
  where id = v_l2;

  update public.lessons set
    intro = 'Common phrases for the doctor, the pharmacy, or just telling a friend you don''t feel well.',
    vocab_items = '[
      {"word":"No me siento bien","phonetic":"[noh meh SYEHN-toh BYEHN]","english":"I don''t feel well","example_es":"No me siento bien hoy.","example_en":"I don''t feel well today."},
      {"word":"Tengo fiebre","phonetic":"[TEHN-goh FYEH-breh]","english":"I have a fever","example_es":"Tengo mucha fiebre.","example_en":"I have a high fever."},
      {"word":"Necesito un médico","phonetic":"[neh-seh-SEE-toh oon MEH-dee-koh]","english":"I need a doctor","example_es":"Necesito un médico ya.","example_en":"I need a doctor now."},
      {"word":"medicina","phonetic":"[meh-dee-SEE-nah]","english":"medicine","example_es":"Tomo medicina.","example_en":"I take medicine."},
      {"word":"descansar","phonetic":"[dehs-kahn-SAHR]","english":"to rest","example_es":"Necesito descansar.","example_en":"I need to rest."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Médica","spanish":"¿Qué le pasa?","english":"What''s wrong?"},
      {"speaker":"Paciente","spanish":"Me duele mucho la cabeza.","english":"My head hurts a lot."},
      {"speaker":"Médica","spanish":"¿Tiene fiebre?","english":"Do you have a fever?"},
      {"speaker":"Paciente","spanish":"Sí, un poco. No me siento bien.","english":"Yes, a little. I don''t feel well."}
    ]'::jsonb,
    grammar_note = 'In Spanish, you say "I have fever" (tengo fiebre), not "I am feverish". Many ailments use tener: tener tos (cough), tener gripe (the flu), tener dolor de... (pain in...).'
  where id = v_l3;

  update public.lessons set
    intro = 'Listen to people describing pain or discomfort. Catch the body part and decide if it''s singular or plural — that changes the verb.',
    vocab_items = '[
      {"word":"estómago","phonetic":"[ehs-TOH-mah-goh]","english":"stomach","example_es":"Me duele el estómago.","example_en":"My stomach hurts."},
      {"word":"espalda","phonetic":"[ehs-PAHL-dah]","english":"back","example_es":"Me duele la espalda.","example_en":"My back hurts."},
      {"word":"garganta","phonetic":"[gahr-GAHN-tah]","english":"throat","example_es":"Tengo dolor de garganta.","example_en":"I have a sore throat."},
      {"word":"oreja / oído","phonetic":"[oh-REH-hah / oh-EE-doh]","english":"ear / inner ear","example_es":"Me duele el oído.","example_en":"My ear hurts."},
      {"word":"dolor","phonetic":"[doh-LOHR]","english":"pain","example_es":"Un dolor fuerte.","example_en":"A strong pain."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Padre","spanish":"¿Qué te pasa?","english":"What''s wrong with you?"},
      {"speaker":"Hija","spanish":"Me duele el estómago.","english":"My stomach hurts."},
      {"speaker":"Padre","spanish":"¿Y la garganta?","english":"And your throat?"},
      {"speaker":"Hija","spanish":"También. Tengo dolor de garganta.","english":"That too. I have a sore throat."}
    ]'::jsonb,
    grammar_note = 'There are two words for "ear": oreja (the outer ear, what you see) and oído (the inner ear, what hears). When something hurts inside your ear, it''s oído.'
  where id = v_l4;

  update public.lessons set
    intro = 'Pronounce body part phrases clearly — especially the LE sound in duele and the rolled R in dolor.',
    vocab_items = '[
      {"word":"Me duele la cabeza","phonetic":"[meh DWEH-leh lah kah-BEH-sah]","english":"My head hurts","example_es":"Me duele mucho la cabeza.","example_en":"My head really hurts."},
      {"word":"Tengo dolor de espalda","phonetic":"[TEHN-goh doh-LOHR deh ehs-PAHL-dah]","english":"I have back pain","example_es":"Tengo dolor de espalda hoy.","example_en":"I have back pain today."},
      {"word":"Mis ojos","phonetic":"[mees OH-hohs]","english":"My eyes","example_es":"Mis ojos son verdes.","example_en":"My eyes are green."},
      {"word":"Lavarse las manos","phonetic":"[lah-BAHR-seh lahs MAH-nohs]","english":"to wash hands","example_es":"Me lavo las manos.","example_en":"I wash my hands."},
      {"word":"Voy al médico","phonetic":"[BOY ahl MEH-dee-koh]","english":"I go to the doctor","example_es":"Voy al médico mañana.","example_en":"I go to the doctor tomorrow."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"You","spanish":"Me duele la cabeza.","english":"My head hurts."},
      {"speaker":"Amigo","spanish":"¿Necesitas medicina?","english":"Do you need medicine?"},
      {"speaker":"You","spanish":"No, necesito descansar.","english":"No, I need to rest."},
      {"speaker":"Amigo","spanish":"OK, hasta mañana.","english":"OK, see you tomorrow."}
    ]'::jsonb,
    grammar_note = 'Reflexive verbs use me/te/se: me lavo (I wash myself), me peino (I comb my hair), me ducho (I shower). Spanish doesn''t add "myself" — the me already shows the action returns to you.'
  where id = v_l5;

  update public.lessons set
    intro = 'A short text describing what hurts and where the speaker goes. Notice the build-up of small symptoms.',
    vocab_items = '[
      {"word":"dos ojos verdes","phonetic":"[dohs OH-hohs BEHR-dehs]","english":"two green eyes","example_es":"Tengo dos ojos verdes.","example_en":"I have two green eyes."},
      {"word":"pelo negro","phonetic":"[PEH-loh NEH-groh]","english":"black hair","example_es":"Mi pelo es negro.","example_en":"My hair is black."},
      {"word":"manos","phonetic":"[MAH-nohs]","english":"hands","example_es":"Mis manos son pequeñas.","example_en":"My hands are small."},
      {"word":"voy al médico","phonetic":"[BOY ahl MEH-dee-koh]","english":"I go to the doctor","example_es":"Voy al médico mañana.","example_en":"I go to the doctor tomorrow."},
      {"word":"necesito descansar","phonetic":"[neh-seh-SEE-toh dehs-kahn-SAHR]","english":"I need to rest","example_es":"Necesito descansar mucho.","example_en":"I need to rest a lot."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Tengo dos ojos verdes y el pelo negro.","english":"I have two green eyes and black hair."},
      {"speaker":"","spanish":"Mis manos son pequeñas.","english":"My hands are small."},
      {"speaker":"","spanish":"Hoy me duele la cabeza.","english":"Today my head hurts."},
      {"speaker":"","spanish":"Voy al médico mañana. Necesito descansar.","english":"I go to the doctor tomorrow. I need to rest."}
    ]'::jsonb,
    grammar_note = 'Voy al médico literally means "I go to the doctor" but is often used like "I''m going to the doctor". Spanish present tense is wider than English — it can mean now, regularly, or in the near future.'
  where id = v_l6;

  update public.lessons set
    intro = 'Write a short description of yourself using body part vocabulary — eyes, hair, hands, and one thing that hurts.',
    vocab_items = '[
      {"word":"Tengo los ojos","phonetic":"[TEHN-goh lohs OH-hohs]","english":"I have eyes","example_es":"Tengo los ojos azules.","example_en":"I have blue eyes."},
      {"word":"Mi pelo es","phonetic":"[mee PEH-loh ehs]","english":"My hair is","example_es":"Mi pelo es largo.","example_en":"My hair is long."},
      {"word":"Me duele","phonetic":"[meh DWEH-leh]","english":"... hurts me","example_es":"Me duele la espalda.","example_en":"My back hurts."},
      {"word":"largo / corto","phonetic":"[LAR-goh / KOHR-toh]","english":"long / short","example_es":"Pelo largo y rizado.","example_en":"Long, curly hair."},
      {"word":"Necesito","phonetic":"[neh-seh-SEE-toh]","english":"I need","example_es":"Necesito agua.","example_en":"I need water."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Models","spanish":"Tengo los ojos verdes.","english":"I have green eyes."},
      {"speaker":"","spanish":"Mi pelo es negro y corto.","english":"My hair is black and short."},
      {"speaker":"","spanish":"Hoy me duele la cabeza.","english":"Today my head hurts."},
      {"speaker":"","spanish":"Necesito descansar.","english":"I need to rest."}
    ]'::jsonb,
    grammar_note = 'For physical description, Spanish uses tener: Tengo los ojos verdes (I have green eyes), not soy ojos verdes. For more permanent traits like hair, both ser and tener work: Mi pelo es / Tengo el pelo.'
  where id = v_l7;

  -- ============== A1.11 CLOTHES ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Clothes';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'These are the essential clothing words you''ll use every day or in any clothing store.',
    vocab_items = '[
      {"word":"camisa","phonetic":"[kah-MEE-sah]","english":"shirt","example_es":"Una camisa azul.","example_en":"A blue shirt."},
      {"word":"pantalones","phonetic":"[pahn-tah-LOH-nehs]","english":"trousers","example_es":"Pantalones negros.","example_en":"Black trousers."},
      {"word":"zapatos","phonetic":"[sah-PAH-tohs]","english":"shoes","example_es":"Mis zapatos nuevos.","example_en":"My new shoes."},
      {"word":"vestido","phonetic":"[behs-TEE-doh]","english":"dress","example_es":"Un vestido rojo.","example_en":"A red dress."},
      {"word":"chaqueta","phonetic":"[chah-KEH-tah]","english":"jacket","example_es":"Una chaqueta de cuero.","example_en":"A leather jacket."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Marta","spanish":"¡Qué bonita tu camisa!","english":"What a pretty shirt!"},
      {"speaker":"Eva","spanish":"Gracias. Es nueva.","english":"Thanks. It''s new."},
      {"speaker":"Marta","spanish":"¿Y los zapatos?","english":"And the shoes?"},
      {"speaker":"Eva","spanish":"También. Hoy llevo todo nuevo.","english":"Also. Today I''m wearing all new things."}
    ]'::jsonb,
    grammar_note = 'Pantalones is always plural in Spanish, even for one pair: unos pantalones (a pair of trousers). Same with gafas (glasses) and tijeras (scissors).'
  where id = v_l1;

  update public.lessons set
    intro = 'Two verbs for "wearing": llevar (to wear / to have on) and ponerse (to put on). Each handles a slightly different moment.',
    vocab_items = '[
      {"word":"Llevo","phonetic":"[YEH-boh]","english":"I''m wearing","example_es":"Llevo una camisa azul.","example_en":"I''m wearing a blue shirt."},
      {"word":"Me pongo","phonetic":"[meh POHN-goh]","english":"I put on","example_es":"Me pongo los zapatos.","example_en":"I put on my shoes."},
      {"word":"Me quito","phonetic":"[meh KEE-toh]","english":"I take off","example_es":"Me quito la chaqueta.","example_en":"I take off the jacket."},
      {"word":"talla","phonetic":"[TAH-yah]","english":"size","example_es":"¿Qué talla usa?","example_en":"What size do you wear?"},
      {"word":"probarse","phonetic":"[proh-BAHR-seh]","english":"to try on","example_es":"Quiero probarme esto.","example_en":"I want to try this on."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Vendedora","spanish":"¿Qué talla usa?","english":"What size do you wear?"},
      {"speaker":"Cliente","spanish":"Talla M. ¿Puedo probármelo?","english":"Size M. Can I try it on?"},
      {"speaker":"Vendedora","spanish":"Claro. ¿Qué se va a poner debajo?","english":"Of course. What will you wear under it?"},
      {"speaker":"Cliente","spanish":"Una camisa blanca.","english":"A white shirt."}
    ]'::jsonb,
    grammar_note = 'Llevar describes what you''re currently wearing (a state). Ponerse is the action of putting clothes on. Use ponerse for getting dressed, llevar for "I''m wearing".'
  where id = v_l2;

  update public.lessons set
    intro = 'Key phrases for describing outfits or shopping for clothes.',
    vocab_items = '[
      {"word":"¿Qué llevas?","phonetic":"[keh YEH-bahs]","english":"What are you wearing?","example_es":"¿Qué llevas hoy?","example_en":"What are you wearing today?"},
      {"word":"Me gusta tu","phonetic":"[meh GOOS-tah too]","english":"I like your","example_es":"Me gusta tu vestido.","example_en":"I like your dress."},
      {"word":"Es bonito","phonetic":"[ehs boh-NEE-toh]","english":"It''s pretty","example_es":"Es muy bonito.","example_en":"It''s very pretty."},
      {"word":"Necesito una talla","phonetic":"[neh-seh-SEE-toh OO-nah TAH-yah]","english":"I need a size","example_es":"Necesito una talla más pequeña.","example_en":"I need a smaller size."},
      {"word":"Me queda bien","phonetic":"[meh KEH-dah BYEHN]","english":"It fits me well","example_es":"Me queda muy bien.","example_en":"It fits me very well."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Sara","spanish":"¡Qué bonito tu vestido!","english":"What a pretty dress!"},
      {"speaker":"Lía","spanish":"Gracias. Me queda muy bien.","english":"Thanks. It fits me well."},
      {"speaker":"Sara","spanish":"¿Es nuevo?","english":"Is it new?"},
      {"speaker":"Lía","spanish":"Sí, lo compré ayer.","english":"Yes, I bought it yesterday."}
    ]'::jsonb,
    grammar_note = 'Quedar means "to fit / suit": Me queda bien (it fits me well), te queda mal (it doesn''t suit you). Works like gustar — the clothes are the subject.'
  where id = v_l3;

  update public.lessons set
    intro = 'Listening practice with clothing colors and sizes — the kind of details that change fast in a store.',
    vocab_items = '[
      {"word":"falda","phonetic":"[FAHL-dah]","english":"skirt","example_es":"Una falda azul.","example_en":"A blue skirt."},
      {"word":"sombrero","phonetic":"[sohm-BREH-roh]","english":"hat","example_es":"Un sombrero rojo.","example_en":"A red hat."},
      {"word":"abrigo","phonetic":"[ah-BREE-goh]","english":"coat","example_es":"Un abrigo de invierno.","example_en":"A winter coat."},
      {"word":"corto / largo","phonetic":"[KOHR-toh / LAR-goh]","english":"short / long","example_es":"Una falda corta.","example_en":"A short skirt."},
      {"word":"nuevo / viejo","phonetic":"[NWEH-boh / BYEH-hoh]","english":"new / old","example_es":"Zapatos viejos.","example_en":"Old shoes."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Cliente","spanish":"¿Tiene esta falda en azul?","english":"Do you have this skirt in blue?"},
      {"speaker":"Vendedor","spanish":"Sí, en talla S y M.","english":"Yes, in sizes S and M."},
      {"speaker":"Cliente","spanish":"Talla M, por favor.","english":"Size M, please."},
      {"speaker":"Vendedor","spanish":"Aquí tiene. El probador está al fondo.","english":"Here you are. The dressing room is at the back."}
    ]'::jsonb,
    grammar_note = 'When asking about availability use ¿Tiene esto en + color/size?: ¿Tiene esto en azul? (Do you have this in blue?), ¿Tiene esto en talla M?'
  where id = v_l4;

  update public.lessons set
    intro = 'Practice describing what you''re wearing today out loud — pick three items, three colors, and one size.',
    vocab_items = '[
      {"word":"Hoy llevo","phonetic":"[OY YEH-boh]","english":"Today I''m wearing","example_es":"Hoy llevo una camisa.","example_en":"Today I''m wearing a shirt."},
      {"word":"Mis zapatos","phonetic":"[mees sah-PAH-tohs]","english":"My shoes","example_es":"Mis zapatos son negros.","example_en":"My shoes are black."},
      {"word":"con / sin","phonetic":"[kohn / seen]","english":"with / without","example_es":"Pantalones con bolsillos.","example_en":"Trousers with pockets."},
      {"word":"Me pongo","phonetic":"[meh POHN-goh]","english":"I put on","example_es":"Me pongo el abrigo.","example_en":"I put on the coat."},
      {"word":"Es de","phonetic":"[ehs deh]","english":"It''s made of","example_es":"Es de algodón.","example_en":"It''s cotton."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"You","spanish":"Hoy llevo una camisa blanca.","english":"Today I''m wearing a white shirt."},
      {"speaker":"","spanish":"Y unos pantalones negros.","english":"And black trousers."},
      {"speaker":"","spanish":"Mis zapatos son nuevos.","english":"My shoes are new."},
      {"speaker":"","spanish":"Hace frío, me pongo la chaqueta.","english":"It''s cold, I''m putting on the jacket."}
    ]'::jsonb,
    grammar_note = 'Spanish pairs colors and clothing in agreement: una camisa BLANCA (f.), unos pantalones NEGROS (m.pl). Always check the noun''s gender to set the color''s ending.'
  where id = v_l5;

  update public.lessons set
    intro = 'A quick read about today''s outfit. Spot the colors, the textures, and the temperature clue.',
    vocab_items = '[
      {"word":"camisa blanca","phonetic":"[kah-MEE-sah BLAHN-kah]","english":"white shirt","example_es":"Llevo una camisa blanca.","example_en":"I''m wearing a white shirt."},
      {"word":"pantalones negros","phonetic":"[pahn-tah-LOH-nehs NEH-grohs]","english":"black trousers","example_es":"Mis pantalones son negros.","example_en":"My trousers are black."},
      {"word":"zapatos nuevos","phonetic":"[sah-PAH-tohs NWEH-bohs]","english":"new shoes","example_es":"Llevo zapatos nuevos.","example_en":"I''m wearing new shoes."},
      {"word":"así que","phonetic":"[ah-SEE keh]","english":"so","example_es":"Hace frío, así que llevo abrigo.","example_en":"It''s cold, so I''m wearing a coat."},
      {"word":"sombrero rojo","phonetic":"[sohm-BREH-roh ROH-hoh]","english":"red hat","example_es":"Mi sombrero es rojo.","example_en":"My hat is red."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Hoy llevo una camisa blanca y unos pantalones negros.","english":"Today I''m wearing a white shirt and black trousers."},
      {"speaker":"","spanish":"Mis zapatos son nuevos.","english":"My shoes are new."},
      {"speaker":"","spanish":"Hace frío, así que también llevo una chaqueta.","english":"It''s cold, so I''m also wearing a jacket."},
      {"speaker":"","spanish":"Mi sombrero es rojo.","english":"My hat is red."}
    ]'::jsonb,
    grammar_note = 'Así que (so / therefore) connects cause and effect: Hace frío, así que llevo abrigo (It''s cold, so I''m wearing a coat).'
  where id = v_l6;

  update public.lessons set
    intro = 'Write a description of your favorite outfit. Use llevar for what''s on and colors that agree in gender and number.',
    vocab_items = '[
      {"word":"Llevo","phonetic":"[YEH-boh]","english":"I wear","example_es":"Llevo una camisa azul.","example_en":"I''m wearing a blue shirt."},
      {"word":"Es de","phonetic":"[ehs deh]","english":"It''s (made of)","example_es":"Es de algodón.","example_en":"It''s cotton."},
      {"word":"Me gusta","phonetic":"[meh GOOS-tah]","english":"I like","example_es":"Me gusta este vestido.","example_en":"I like this dress."},
      {"word":"Mi favorito","phonetic":"[mee fah-boh-REE-toh]","english":"My favorite","example_es":"Mi color favorito es el rojo.","example_en":"My favorite color is red."},
      {"word":"Talla","phonetic":"[TAH-yah]","english":"Size","example_es":"Talla M, por favor.","example_en":"Size M, please."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Models","spanish":"Mi camisa favorita es azul.","english":"My favorite shirt is blue."},
      {"speaker":"","spanish":"Llevo pantalones negros y zapatos nuevos.","english":"I wear black trousers and new shoes."},
      {"speaker":"","spanish":"Mi talla es M.","english":"My size is M."},
      {"speaker":"","spanish":"Me gusta llevar ropa cómoda.","english":"I like to wear comfortable clothes."}
    ]'::jsonb,
    grammar_note = 'For "my favorite" + noun, Spanish puts the adjective AFTER: mi color favorito (my favorite color), mi camisa favorita (my favorite shirt). Note the agreement with the noun''s gender.'
  where id = v_l7;

  -- ============== A1.12 HOUSE & HOME ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'House & Home';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'Learn the names of the main rooms in any Spanish-speaking home.',
    vocab_items = '[
      {"word":"casa","phonetic":"[KAH-sah]","english":"house","example_es":"Mi casa es grande.","example_en":"My house is big."},
      {"word":"cocina","phonetic":"[koh-SEE-nah]","english":"kitchen","example_es":"La cocina es nueva.","example_en":"The kitchen is new."},
      {"word":"baño","phonetic":"[BAH-nyoh]","english":"bathroom","example_es":"El baño está aquí.","example_en":"The bathroom is here."},
      {"word":"dormitorio","phonetic":"[dohr-mee-TOH-ryoh]","english":"bedroom","example_es":"Mi dormitorio es azul.","example_en":"My bedroom is blue."},
      {"word":"sala","phonetic":"[SAH-lah]","english":"living room","example_es":"La sala es grande.","example_en":"The living room is big."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Anfitrión","spanish":"Bienvenido a mi casa.","english":"Welcome to my house."},
      {"speaker":"Invitado","spanish":"Gracias. ¡Es muy bonita!","english":"Thanks. It''s very pretty!"},
      {"speaker":"Anfitrión","spanish":"La cocina está aquí, y el baño allí.","english":"The kitchen is here, and the bathroom is over there."},
      {"speaker":"Invitado","spanish":"Me encanta tu sala.","english":"I love your living room."}
    ]'::jsonb,
    grammar_note = 'Aquí (here) vs allí (there): aquí is right next to you, allí is far. Ahí (without accent, with i) is somewhere in between — closer than allí.'
  where id = v_l1;

  update public.lessons set
    intro = 'Hay is one of the most useful Spanish words: it means "there is" or "there are" without changing form.',
    vocab_items = '[
      {"word":"hay","phonetic":"[I]","english":"there is / there are","example_es":"Hay tres habitaciones.","example_en":"There are 3 rooms."},
      {"word":"habitación","phonetic":"[ah-bee-tah-SYOHN]","english":"room","example_es":"Una habitación grande.","example_en":"A big room."},
      {"word":"en","phonetic":"[ehn]","english":"in","example_es":"Vivo en una casa.","example_en":"I live in a house."},
      {"word":"piso","phonetic":"[PEE-soh]","english":"apartment / floor","example_es":"En el primer piso.","example_en":"On the first floor."},
      {"word":"al lado de","phonetic":"[ahl LAH-doh deh]","english":"next to","example_es":"Al lado del baño.","example_en":"Next to the bathroom."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Visitante","spanish":"¿Cuántas habitaciones hay?","english":"How many rooms are there?"},
      {"speaker":"Dueña","spanish":"Hay tres: dos dormitorios y una sala.","english":"There are three: two bedrooms and a living room."},
      {"speaker":"Visitante","spanish":"¿Y el baño?","english":"And the bathroom?"},
      {"speaker":"Dueña","spanish":"El baño está al lado del dormitorio.","english":"The bathroom is next to the bedroom."}
    ]'::jsonb,
    grammar_note = 'Hay never changes for singular or plural: hay un libro (there is a book), hay tres libros (there are three books). Don''t confuse with es/son (is/are), which describes specific things.'
  where id = v_l2;

  update public.lessons set
    intro = 'Talking about where you live and what your home is like — the most common small-talk topic after weather.',
    vocab_items = '[
      {"word":"Vivo en","phonetic":"[BEE-boh ehn]","english":"I live in","example_es":"Vivo en Madrid.","example_en":"I live in Madrid."},
      {"word":"con mi familia","phonetic":"[kohn mee fah-MEE-lyah]","english":"with my family","example_es":"Vivo con mi familia.","example_en":"I live with my family."},
      {"word":"un apartamento","phonetic":"[oon ah-pahr-tah-MEHN-toh]","english":"an apartment","example_es":"Vivo en un apartamento.","example_en":"I live in an apartment."},
      {"word":"jardín","phonetic":"[hahr-DEEN]","english":"garden","example_es":"La casa tiene jardín.","example_en":"The house has a garden."},
      {"word":"primer piso","phonetic":"[pree-MEHR PEE-soh]","english":"first floor","example_es":"En el primer piso.","example_en":"On the first floor."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Pablo","spanish":"¿Dónde vives?","english":"Where do you live?"},
      {"speaker":"Sara","spanish":"Vivo en Madrid, en un apartamento.","english":"I live in Madrid, in an apartment."},
      {"speaker":"Pablo","spanish":"¿Es grande?","english":"Is it big?"},
      {"speaker":"Sara","spanish":"Bastante. Tiene tres habitaciones.","english":"Quite. It has three rooms."}
    ]'::jsonb,
    grammar_note = 'Spanish uses tener for what a house has, not haber: La casa tiene jardín (The house has a garden). Hay un jardín = "There IS a garden", but the house possesses with tener.'
  where id = v_l3;

  update public.lessons set
    intro = 'Listening for room locations, sizes, and counts is essential for any home tour or apartment hunt.',
    vocab_items = '[
      {"word":"comedor","phonetic":"[koh-meh-DOHR]","english":"dining room","example_es":"El comedor es grande.","example_en":"The dining room is big."},
      {"word":"terraza","phonetic":"[teh-RRAH-sah]","english":"terrace","example_es":"Hay una terraza.","example_en":"There''s a terrace."},
      {"word":"cerca / lejos","phonetic":"[SEHR-kah / LEH-hohs]","english":"close / far","example_es":"Cerca del centro.","example_en":"Close to the center."},
      {"word":"alquilar","phonetic":"[ahl-kee-LAHR]","english":"to rent","example_es":"Alquilo un piso.","example_en":"I rent an apartment."},
      {"word":"ventana","phonetic":"[behn-TAH-nah]","english":"window","example_es":"Una ventana grande.","example_en":"A big window."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Agente","spanish":"El piso tiene tres habitaciones y un baño.","english":"The apartment has three rooms and one bathroom."},
      {"speaker":"Cliente","spanish":"¿Y la cocina?","english":"And the kitchen?"},
      {"speaker":"Agente","spanish":"Cocina con terraza y comedor grande.","english":"Kitchen with terrace and big dining room."},
      {"speaker":"Cliente","spanish":"¿Está cerca del metro?","english":"Is it near the metro?"}
    ]'::jsonb,
    grammar_note = 'Cerca de = close to, lejos de = far from. Both need de before the place: cerca del centro (close to the center), lejos de aquí (far from here).'
  where id = v_l4;

  update public.lessons set
    intro = 'Talk about your home aloud. Use Vivo en + place and Mi casa tiene + features.',
    vocab_items = '[
      {"word":"Mi casa","phonetic":"[mee KAH-sah]","english":"My house","example_es":"Mi casa es grande.","example_en":"My house is big."},
      {"word":"Vivo en Madrid","phonetic":"[BEE-boh ehn mah-DREED]","english":"I live in Madrid","example_es":"Vivo en Madrid desde 2020.","example_en":"I''ve lived in Madrid since 2020."},
      {"word":"Tengo dos dormitorios","phonetic":"[TEHN-goh dohs dohr-mee-TOH-ryohs]","english":"I have two bedrooms","example_es":"Tengo dos dormitorios pequeños.","example_en":"I have two small bedrooms."},
      {"word":"La cocina es nueva","phonetic":"[lah koh-SEE-nah ehs NWEH-bah]","english":"The kitchen is new","example_es":"La cocina es nueva y bonita.","example_en":"The kitchen is new and pretty."},
      {"word":"Bienvenido","phonetic":"[byehn-beh-NEE-doh]","english":"Welcome","example_es":"Bienvenido a mi casa.","example_en":"Welcome to my house."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"You","spanish":"Vivo en un apartamento pequeño.","english":"I live in a small apartment."},
      {"speaker":"Friend","spanish":"¿Cuántas habitaciones tiene?","english":"How many rooms does it have?"},
      {"speaker":"You","spanish":"Tiene dos. Y una terraza.","english":"It has two. And a terrace."},
      {"speaker":"Friend","spanish":"Suena perfecto.","english":"Sounds perfect."}
    ]'::jsonb,
    grammar_note = 'Use the same verb forms for ages of buildings as for people: La casa es nueva (the house is new), un piso viejo (an old apartment). Adjectives agree with the noun.'
  where id = v_l5;

  update public.lessons set
    intro = 'Read about a typical Spanish home. Count the rooms and notice where the speaker lives.',
    vocab_items = '[
      {"word":"grande","phonetic":"[GRAHN-deh]","english":"big","example_es":"Una casa grande.","example_en":"A big house."},
      {"word":"cuatro habitaciones","phonetic":"[KWAH-troh ah-bee-tah-SYOH-nehs]","english":"four rooms","example_es":"Cuatro habitaciones nuevas.","example_en":"Four new rooms."},
      {"word":"dos baños","phonetic":"[dohs BAH-nyohs]","english":"two bathrooms","example_es":"Dos baños grandes.","example_en":"Two big bathrooms."},
      {"word":"primer piso","phonetic":"[pree-MEHR PEE-soh]","english":"first floor","example_es":"En el primer piso.","example_en":"On the first floor."},
      {"word":"Vivo aquí","phonetic":"[BEE-boh ah-KEE]","english":"I live here","example_es":"Vivo aquí con mi familia.","example_en":"I live here with my family."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Mi casa es grande.","english":"My house is big."},
      {"speaker":"","spanish":"Tiene cuatro habitaciones, una cocina y dos baños.","english":"It has four rooms, a kitchen and two bathrooms."},
      {"speaker":"","spanish":"La sala está en el primer piso.","english":"The living room is on the first floor."},
      {"speaker":"","spanish":"Vivo aquí con mi familia. Me gusta mucho mi casa.","english":"I live here with my family. I really like my house."}
    ]'::jsonb,
    grammar_note = 'For ordinal numbers: primer, segundo, tercer (1st, 2nd, 3rd). Primer and tercer drop the -o before masculine singular nouns: el primer piso, but la primera planta.'
  where id = v_l6;

  update public.lessons set
    intro = 'Write a short description of where you live. Mention the city, the size, and one feature you like.',
    vocab_items = '[
      {"word":"Vivo en","phonetic":"[BEE-boh ehn]","english":"I live in","example_es":"Vivo en Sevilla.","example_en":"I live in Seville."},
      {"word":"Mi casa tiene","phonetic":"[mee KAH-sah TYEH-neh]","english":"My house has","example_es":"Mi casa tiene jardín.","example_en":"My house has a garden."},
      {"word":"con","phonetic":"[kohn]","english":"with","example_es":"Vivo con mi familia.","example_en":"I live with my family."},
      {"word":"Me gusta","phonetic":"[meh GOOS-tah]","english":"I like","example_es":"Me gusta mi cocina.","example_en":"I like my kitchen."},
      {"word":"Bienvenido a mi casa","phonetic":"[byehn-beh-NEE-doh]","english":"Welcome to my house","example_es":"¡Bienvenido a mi casa!","example_en":"Welcome to my house!"}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Models","spanish":"Vivo en Madrid en un piso pequeño.","english":"I live in Madrid in a small apartment."},
      {"speaker":"","spanish":"Mi casa tiene dos dormitorios.","english":"My house has two bedrooms."},
      {"speaker":"","spanish":"Me gusta mucho mi cocina.","english":"I really like my kitchen."},
      {"speaker":"","spanish":"Vivo con mi familia.","english":"I live with my family."}
    ]'::jsonb,
    grammar_note = 'Spanish uses vivir en for "to live in" — never vivir a. The preposition en marks the location: Vivo en Madrid, vivo en una casa.'
  where id = v_l7;

  -- ============== A1.13 TRANSPORT ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Transport';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'Learn the main words for getting around — car, bus, train, plane, bicycle.',
    vocab_items = '[
      {"word":"coche","phonetic":"[KOH-cheh]","english":"car (Spain)","example_es":"Mi coche es rojo.","example_en":"My car is red."},
      {"word":"autobús","phonetic":"[ow-toh-BOOS]","english":"bus","example_es":"Tomo el autobús.","example_en":"I take the bus."},
      {"word":"tren","phonetic":"[TREHN]","english":"train","example_es":"El tren llega.","example_en":"The train arrives."},
      {"word":"avión","phonetic":"[ah-BYOHN]","english":"plane","example_es":"Un avión grande.","example_en":"A big plane."},
      {"word":"bicicleta","phonetic":"[bee-see-KLEH-tah]","english":"bicycle","example_es":"Voy en bicicleta.","example_en":"I go by bike."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Mariana","spanish":"¿Cómo vas al trabajo?","english":"How do you go to work?"},
      {"speaker":"Hugo","spanish":"En autobús, ¿y tú?","english":"By bus, and you?"},
      {"speaker":"Mariana","spanish":"En coche.","english":"By car."},
      {"speaker":"Hugo","spanish":"Yo prefiero la bicicleta.","english":"I prefer the bike."}
    ]'::jsonb,
    grammar_note = 'In Spain coche is "car", in Latin America carro or auto. Tomar el bus / autobús is "to catch the bus"; coger el bus works in Spain but means something rude in some LatAm countries — use tomar there.'
  where id = v_l1;

  update public.lessons set
    intro = 'When you say "I go by car", Spanish uses ir en + transport. Master this pattern and you can describe any journey.',
    vocab_items = '[
      {"word":"Voy en coche","phonetic":"[BOY ehn KOH-cheh]","english":"I go by car","example_es":"Voy en coche al trabajo.","example_en":"I go to work by car."},
      {"word":"Vamos en tren","phonetic":"[BAH-mohs ehn TREHN]","english":"We go by train","example_es":"Vamos en tren a Sevilla.","example_en":"We go to Seville by train."},
      {"word":"a pie","phonetic":"[ah PYEH]","english":"on foot","example_es":"Voy a pie.","example_en":"I go on foot."},
      {"word":"al trabajo","phonetic":"[ahl trah-BAH-hoh]","english":"to work","example_es":"Voy al trabajo en tren.","example_en":"I go to work by train."},
      {"word":"a la escuela","phonetic":"[ah lah ehs-KWEH-lah]","english":"to school","example_es":"Va a la escuela en autobús.","example_en":"He goes to school by bus."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Mamá","spanish":"¿Cómo vas a la escuela?","english":"How do you go to school?"},
      {"speaker":"Hijo","spanish":"Voy en bicicleta.","english":"I go by bike."},
      {"speaker":"Mamá","spanish":"¿Y tu hermana?","english":"And your sister?"},
      {"speaker":"Hijo","spanish":"Ella va a pie.","english":"She goes on foot."}
    ]'::jsonb,
    grammar_note = 'Spanish uses en for most transport (en coche, en tren) but a pie or a caballo for "on foot" or "on horseback". The exception is a pie = on foot, an idiom.'
  where id = v_l2;

  update public.lessons set
    intro = 'Useful travel phrases for stations, ticket counters, and asking directions.',
    vocab_items = '[
      {"word":"un billete","phonetic":"[oon bee-YEH-teh]","english":"a ticket","example_es":"Un billete a Madrid.","example_en":"A ticket to Madrid."},
      {"word":"¿A qué hora sale?","phonetic":"[ah keh OH-rah SAH-leh]","english":"What time does it leave?","example_es":"¿A qué hora sale el tren?","example_en":"What time does the train leave?"},
      {"word":"ida y vuelta","phonetic":"[EE-dah ee BWEHL-tah]","english":"round trip","example_es":"Un billete de ida y vuelta.","example_en":"A round-trip ticket."},
      {"word":"andén","phonetic":"[ahn-DEHN]","english":"platform","example_es":"Andén número cinco.","example_en":"Platform number five."},
      {"word":"Necesito un taxi","phonetic":"[neh-seh-SEE-toh oon TAHK-see]","english":"I need a taxi","example_es":"Necesito un taxi al aeropuerto.","example_en":"I need a taxi to the airport."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Viajero","spanish":"Un billete a Sevilla, por favor.","english":"A ticket to Seville, please."},
      {"speaker":"Cajera","spanish":"¿De ida o de ida y vuelta?","english":"One way or round trip?"},
      {"speaker":"Viajero","spanish":"De ida y vuelta. ¿A qué hora sale?","english":"Round trip. What time does it leave?"},
      {"speaker":"Cajera","spanish":"A las diez, andén tres.","english":"At ten, platform three."}
    ]'::jsonb,
    grammar_note = 'Un billete (Spain) and un boleto (LatAm) both mean ticket. For a flight or train, you''ll always need to specify ida (one-way) or ida y vuelta (round-trip).'
  where id = v_l3;

  update public.lessons set
    intro = 'Listening practice for station announcements, timetables, and travel small talk.',
    vocab_items = '[
      {"word":"sale a las","phonetic":"[SAH-leh ah lahs]","english":"leaves at","example_es":"Sale a las ocho.","example_en":"It leaves at eight."},
      {"word":"llega a las","phonetic":"[YEH-gah ah lahs]","english":"arrives at","example_es":"Llega a las diez.","example_en":"It arrives at ten."},
      {"word":"el metro","phonetic":"[ehl MEH-troh]","english":"the metro","example_es":"Tomo el metro.","example_en":"I take the metro."},
      {"word":"está atrasado","phonetic":"[ehs-TAH ah-trah-SAH-doh]","english":"is late","example_es":"El tren está atrasado.","example_en":"The train is late."},
      {"word":"siguiente","phonetic":"[see-GYEHN-teh]","english":"next","example_es":"El siguiente tren.","example_en":"The next train."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Anuncio","spanish":"El tren a Madrid sale a las once.","english":"The train to Madrid leaves at eleven."},
      {"speaker":"Pasajero","spanish":"¿En qué andén?","english":"On which platform?"},
      {"speaker":"Anuncio","spanish":"Andén siete. El tren está atrasado.","english":"Platform seven. The train is late."},
      {"speaker":"Pasajero","spanish":"¿Cuánto?","english":"How long?"}
    ]'::jsonb,
    grammar_note = 'For arrivals and departures: salir (to leave) vs llegar (to arrive). The train SALE at one time and LLEGA at another.'
  where id = v_l4;

  update public.lessons set
    intro = 'Saying how you travel out loud — practice the ir + en + transport pattern.',
    vocab_items = '[
      {"word":"Voy en autobús","phonetic":"[BOY ehn ow-toh-BOOS]","english":"I go by bus","example_es":"Voy en autobús al trabajo.","example_en":"I go to work by bus."},
      {"word":"Tomo el tren","phonetic":"[TOH-moh ehl TREHN]","english":"I take the train","example_es":"Tomo el tren a las ocho.","example_en":"I take the train at eight."},
      {"word":"Necesito un taxi","phonetic":"[neh-seh-SEE-toh oon TAHK-see]","english":"I need a taxi","example_es":"Necesito un taxi ya.","example_en":"I need a taxi now."},
      {"word":"Mi coche","phonetic":"[mee KOH-cheh]","english":"My car","example_es":"Mi coche es nuevo.","example_en":"My car is new."},
      {"word":"Voy a pie","phonetic":"[BOY ah PYEH]","english":"I walk","example_es":"Voy a pie al centro.","example_en":"I walk to the center."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"You","spanish":"Voy al trabajo en bicicleta.","english":"I go to work by bike."},
      {"speaker":"Friend","spanish":"¿Y cuando llueve?","english":"And when it rains?"},
      {"speaker":"You","spanish":"Tomo el metro.","english":"I take the metro."},
      {"speaker":"Friend","spanish":"Buena idea.","english":"Good idea."}
    ]'::jsonb,
    grammar_note = 'Voy is from ir (to go). Three super-common forms: voy (I go), vas (you go), va (he/she/it goes). They cover most everyday conversation.'
  where id = v_l5;

  update public.lessons set
    intro = 'A short text about a daily commute. See how the speaker uses different transports for different family members.',
    vocab_items = '[
      {"word":"cada día","phonetic":"[KAH-dah DEE-ah]","english":"every day","example_es":"Cada día voy en autobús.","example_en":"Every day I go by bus."},
      {"word":"el viaje","phonetic":"[ehl BYAH-heh]","english":"the trip","example_es":"El viaje es corto.","example_en":"The trip is short."},
      {"word":"dura","phonetic":"[DOO-rah]","english":"lasts","example_es":"Dura veinte minutos.","example_en":"It lasts twenty minutes."},
      {"word":"prefiere","phonetic":"[preh-FYEH-reh]","english":"prefers","example_es":"Prefiere ir en bici.","example_en":"He prefers to go by bike."},
      {"word":"nunca","phonetic":"[NOON-kah]","english":"never","example_es":"Nunca tomo el avión.","example_en":"I never take the plane."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Cada día voy al trabajo en autobús.","english":"Every day I go to work by bus."},
      {"speaker":"","spanish":"El viaje dura veinte minutos.","english":"The trip takes twenty minutes."},
      {"speaker":"","spanish":"Mi hermano va en coche.","english":"My brother goes by car."},
      {"speaker":"","spanish":"Mi padre prefiere ir en bicicleta. Nunca tomo el avión.","english":"My father prefers to go by bike. I never take the plane."}
    ]'::jsonb,
    grammar_note = 'Dura comes from durar (to last). Useful for talking about travel: El viaje dura una hora (The trip lasts an hour). Use the same verb for movies or songs.'
  where id = v_l6;

  update public.lessons set
    intro = 'Write about your daily commute. Use ir en for the transport and time expressions to anchor the routine.',
    vocab_items = '[
      {"word":"Voy en","phonetic":"[BOY ehn]","english":"I go by","example_es":"Voy en tren.","example_en":"I go by train."},
      {"word":"al trabajo","phonetic":"[ahl trah-BAH-hoh]","english":"to work","example_es":"Voy al trabajo.","example_en":"I go to work."},
      {"word":"dura","phonetic":"[DOO-rah]","english":"lasts","example_es":"Dura una hora.","example_en":"It lasts an hour."},
      {"word":"todos los días","phonetic":"[TOH-dohs lohs DEE-ahs]","english":"every day","example_es":"Trabajo todos los días.","example_en":"I work every day."},
      {"word":"prefiero","phonetic":"[preh-FYEH-roh]","english":"I prefer","example_es":"Prefiero el tren.","example_en":"I prefer the train."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Models","spanish":"Voy al trabajo en metro.","english":"I go to work by metro."},
      {"speaker":"","spanish":"El viaje dura treinta minutos.","english":"The trip lasts 30 minutes."},
      {"speaker":"","spanish":"Prefiero el metro al coche.","english":"I prefer the metro to the car."},
      {"speaker":"","spanish":"Los fines de semana voy en bicicleta.","english":"On weekends I go by bike."}
    ]'::jsonb,
    grammar_note = 'Preferir A más que B is one way to say "prefer A over B". Simpler: just say Prefiero el metro, no need to specify the alternative.'
  where id = v_l7;

  -- ============== A1.14 DAYS & MONTHS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Days & Months';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'Learn the seven days of the week and a few key months. Spanish doesn''t capitalize them, unlike English.',
    vocab_items = '[
      {"word":"lunes","phonetic":"[LOO-nehs]","english":"Monday","example_es":"Hoy es lunes.","example_en":"Today is Monday."},
      {"word":"viernes","phonetic":"[BYEHR-nehs]","english":"Friday","example_es":"El viernes voy al cine.","example_en":"On Friday I go to the cinema."},
      {"word":"domingo","phonetic":"[doh-MEEN-goh]","english":"Sunday","example_es":"Los domingos descanso.","example_en":"On Sundays I rest."},
      {"word":"enero","phonetic":"[eh-NEH-roh]","english":"January","example_es":"En enero hace frío.","example_en":"In January it''s cold."},
      {"word":"mayo","phonetic":"[MAH-yoh]","english":"May","example_es":"Mi cumpleaños es en mayo.","example_en":"My birthday is in May."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Ana","spanish":"¿Qué día es hoy?","english":"What day is today?"},
      {"speaker":"Beto","spanish":"Hoy es martes.","english":"Today is Tuesday."},
      {"speaker":"Ana","spanish":"¿Y mañana?","english":"And tomorrow?"},
      {"speaker":"Beto","spanish":"Mañana es miércoles.","english":"Tomorrow is Wednesday."}
    ]'::jsonb,
    grammar_note = 'Days and months in Spanish are lowercase: lunes, enero. They''re also all masculine: el lunes, el lunes próximo. Days don''t change in plural: el lunes, los lunes (with article change only).'
  where id = v_l1;

  update public.lessons set
    intro = 'To say "on Monday" Spanish uses el + day. For "on Mondays" (habit) it''s los + day. No de or a needed.',
    vocab_items = '[
      {"word":"el lunes","phonetic":"[ehl LOO-nehs]","english":"on Monday","example_es":"El lunes voy al médico.","example_en":"On Monday I''m going to the doctor."},
      {"word":"los lunes","phonetic":"[lohs LOO-nehs]","english":"on Mondays","example_es":"Los lunes trabajo.","example_en":"On Mondays I work."},
      {"word":"en mayo","phonetic":"[ehn MAH-yoh]","english":"in May","example_es":"En mayo hace calor.","example_en":"In May it''s hot."},
      {"word":"Hoy es","phonetic":"[OY ehs]","english":"Today is","example_es":"Hoy es jueves.","example_en":"Today is Thursday."},
      {"word":"Mañana es","phonetic":"[mah-NYAH-nah ehs]","english":"Tomorrow is","example_es":"Mañana es sábado.","example_en":"Tomorrow is Saturday."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Pepe","spanish":"¿Trabajas los sábados?","english":"Do you work on Saturdays?"},
      {"speaker":"Lina","spanish":"No, los sábados descanso.","english":"No, on Saturdays I rest."},
      {"speaker":"Pepe","spanish":"¿Y el lunes?","english":"And on Monday?"},
      {"speaker":"Lina","spanish":"El lunes empiezo a las nueve.","english":"On Monday I start at nine."}
    ]'::jsonb,
    grammar_note = 'For habitual actions (every Monday), use los lunes. For a specific day (this Monday), use el lunes. The article tells the difference.'
  where id = v_l2;

  update public.lessons set
    intro = 'Phrases for birthdays, weekends, and scheduling — the everyday currency of daily planning.',
    vocab_items = '[
      {"word":"Mi cumpleaños es","phonetic":"[mee koom-pleh-AH-nyohs ehs]","english":"My birthday is","example_es":"Mi cumpleaños es en julio.","example_en":"My birthday is in July."},
      {"word":"fin de semana","phonetic":"[feen deh seh-MAH-nah]","english":"weekend","example_es":"El fin de semana descanso.","example_en":"On the weekend I rest."},
      {"word":"Hoy es","phonetic":"[OY ehs]","english":"Today is","example_es":"Hoy es viernes.","example_en":"Today is Friday."},
      {"word":"este lunes","phonetic":"[EHS-teh LOO-nehs]","english":"this Monday","example_es":"Voy este lunes.","example_en":"I go this Monday."},
      {"word":"a mediados de","phonetic":"[ah meh-DYAH-dohs deh]","english":"in the middle of","example_es":"A mediados de junio.","example_en":"In mid-June."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Tina","spanish":"¿Cuándo es tu cumpleaños?","english":"When is your birthday?"},
      {"speaker":"Iván","spanish":"Es el quince de mayo.","english":"It''s May 15th."},
      {"speaker":"Tina","spanish":"¡Pronto! ¿Hacemos algo el viernes?","english":"Soon! Shall we do something on Friday?"},
      {"speaker":"Iván","spanish":"Sí, este viernes va perfecto.","english":"Yes, this Friday works perfectly."}
    ]'::jsonb,
    grammar_note = 'Dates use el + day + de + month: el 15 de mayo (May 15th). The order is opposite of English; the article el covers "the".'
  where id = v_l3;

  update public.lessons set
    intro = 'Listening for days and dates in scheduling conversations — practice catching them in normal speech.',
    vocab_items = '[
      {"word":"jueves","phonetic":"[HWEH-behs]","english":"Thursday","example_es":"El jueves trabajo.","example_en":"On Thursday I work."},
      {"word":"febrero","phonetic":"[feh-BREH-roh]","english":"February","example_es":"En febrero hace frío.","example_en":"In February it''s cold."},
      {"word":"agosto","phonetic":"[ah-GOHS-toh]","english":"August","example_es":"En agosto, vacaciones.","example_en":"In August, vacation."},
      {"word":"diciembre","phonetic":"[dee-SYEHM-breh]","english":"December","example_es":"En diciembre nieva.","example_en":"In December it snows."},
      {"word":"ayer / mañana","phonetic":"[ah-YEHR / mah-NYAH-nah]","english":"yesterday / tomorrow","example_es":"Ayer fui al cine.","example_en":"Yesterday I went to the cinema."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Médica","spanish":"¿Puede venir el jueves?","english":"Can you come on Thursday?"},
      {"speaker":"Paciente","spanish":"¿Qué día es el jueves?","english":"What day is Thursday?"},
      {"speaker":"Médica","spanish":"El siete de febrero.","english":"February 7th."},
      {"speaker":"Paciente","spanish":"Perfecto, hasta el jueves.","english":"Perfect, see you Thursday."}
    ]'::jsonb,
    grammar_note = 'Mañana means both "tomorrow" (noun) and "morning" (la mañana). Context tells which: Mañana voy = tomorrow I go; Por la mañana voy = in the morning I go.'
  where id = v_l4;

  update public.lessons set
    intro = 'Practice pronouncing days, dates, and birthday phrases out loud.',
    vocab_items = '[
      {"word":"Hoy es lunes","phonetic":"[OY ehs LOO-nehs]","english":"Today is Monday","example_es":"Hoy es lunes, voy a clase.","example_en":"Today is Monday, I go to class."},
      {"word":"Mi cumpleaños es en mayo","phonetic":"[mee koom-pleh-AH-nyohs ehs ehn MAH-yoh]","english":"My birthday is in May","example_es":"Mi cumpleaños es en mayo.","example_en":"My birthday is in May."},
      {"word":"El sábado voy al cine","phonetic":"[ehl SAH-bah-doh BOY ahl SEE-neh]","english":"On Saturday I go to the cinema","example_es":"El sábado voy al cine.","example_en":"On Saturday I go to the cinema."},
      {"word":"Los domingos descanso","phonetic":"[lohs doh-MEEN-gohs dehs-KAHN-soh]","english":"On Sundays I rest","example_es":"Los domingos descanso en casa.","example_en":"On Sundays I rest at home."},
      {"word":"Diciembre es frío","phonetic":"[dee-SYEHM-breh ehs FREE-oh]","english":"December is cold","example_es":"Diciembre es frío y oscuro.","example_en":"December is cold and dark."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"You","spanish":"Hoy es viernes.","english":"Today is Friday."},
      {"speaker":"Friend","spanish":"¡Bien! ¿Plan para el sábado?","english":"Nice! Plan for Saturday?"},
      {"speaker":"You","spanish":"El sábado voy al cine.","english":"On Saturday I go to the cinema."},
      {"speaker":"Friend","spanish":"Yo descanso los domingos.","english":"I rest on Sundays."}
    ]'::jsonb,
    grammar_note = 'Watch stress: SÁ-ba-do (Saturday) carries the accent on the A. Other days are stressed on the second-to-last syllable: LU-nes, MAR-tes, JUE-ves.'
  where id = v_l5;

  update public.lessons set
    intro = 'Read about a typical week: routine days, weekends, and favorite seasons.',
    vocab_items = '[
      {"word":"cumpleaños","phonetic":"[koom-pleh-AH-nyohs]","english":"birthday","example_es":"Mi cumpleaños.","example_en":"My birthday."},
      {"word":"el sábado","phonetic":"[ehl SAH-bah-doh]","english":"on Saturday","example_es":"El sábado voy al cine.","example_en":"On Saturday I go to the cinema."},
      {"word":"descanso","phonetic":"[dehs-KAHN-soh]","english":"I rest","example_es":"Los domingos descanso.","example_en":"On Sundays I rest."},
      {"word":"día favorito","phonetic":"[DEE-ah fah-boh-REE-toh]","english":"favorite day","example_es":"Mi día favorito.","example_en":"My favorite day."},
      {"word":"muy frío","phonetic":"[MWEE FREE-oh]","english":"very cold","example_es":"Diciembre es muy frío.","example_en":"December is very cold."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Mi cumpleaños es en mayo.","english":"My birthday is in May."},
      {"speaker":"","spanish":"El sábado voy al cine con mis amigos.","english":"On Saturday I go to the cinema with my friends."},
      {"speaker":"","spanish":"El domingo descanso en casa.","english":"On Sunday I rest at home."},
      {"speaker":"","spanish":"Mi día favorito es el viernes. Diciembre es muy frío.","english":"My favorite day is Friday. December is very cold."}
    ]'::jsonb,
    grammar_note = 'Use mis amigos (my friends, plural) when talking about a group. The possessive mis matches the noun in number, not in gender.'
  where id = v_l6;

  update public.lessons set
    intro = 'Write about your favorite day, your birthday month, and one weekend activity.',
    vocab_items = '[
      {"word":"Hoy es","phonetic":"[OY ehs]","english":"Today is","example_es":"Hoy es jueves.","example_en":"Today is Thursday."},
      {"word":"Mi cumpleaños","phonetic":"[mee koom-pleh-AH-nyohs]","english":"My birthday","example_es":"Mi cumpleaños es en abril.","example_en":"My birthday is in April."},
      {"word":"El + day","phonetic":"[ehl ...]","english":"On + day","example_es":"El sábado voy al cine.","example_en":"On Saturday I go to the cinema."},
      {"word":"Los + day-s","phonetic":"[lohs ...]","english":"On + days","example_es":"Los lunes trabajo.","example_en":"On Mondays I work."},
      {"word":"En + month","phonetic":"[ehn ...]","english":"In + month","example_es":"En diciembre nieva.","example_en":"In December it snows."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Models","spanish":"Hoy es lunes.","english":"Today is Monday."},
      {"speaker":"","spanish":"Mi cumpleaños es en marzo.","english":"My birthday is in March."},
      {"speaker":"","spanish":"El sábado voy de compras.","english":"On Saturday I go shopping."},
      {"speaker":"","spanish":"Los domingos descanso en casa.","english":"On Sundays I rest at home."}
    ]'::jsonb,
    grammar_note = 'Spanish dates write the day before the month: 15/05/2026 = May 15, 2026 (NOT November). This affects calendars, forms, and reading dates aloud.'
  where id = v_l7;

  -- ============== A1.15 BASIC VERBS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A1' and title = 'Basic Verbs';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'Five verbs do most of the work in beginner Spanish: ser (to be), estar (to be), tener (to have), ir (to go), hacer (to do).',
    vocab_items = '[
      {"word":"ser","phonetic":"[SEHR]","english":"to be (essence)","example_es":"Yo soy estudiante.","example_en":"I am a student."},
      {"word":"estar","phonetic":"[ehs-TAHR]","english":"to be (state)","example_es":"Estoy cansado.","example_en":"I''m tired."},
      {"word":"tener","phonetic":"[teh-NEHR]","english":"to have","example_es":"Tengo un coche.","example_en":"I have a car."},
      {"word":"ir","phonetic":"[EER]","english":"to go","example_es":"Voy al cine.","example_en":"I go to the cinema."},
      {"word":"hacer","phonetic":"[ah-SEHR]","english":"to do / make","example_es":"Hago la cena.","example_en":"I make dinner."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Eva","spanish":"¿Cómo estás?","english":"How are you?"},
      {"speaker":"Tomás","spanish":"Bien, gracias. Soy Tomás.","english":"Fine, thanks. I''m Tomás."},
      {"speaker":"Eva","spanish":"Yo voy al café. ¿Vienes?","english":"I''m going to the café. Are you coming?"},
      {"speaker":"Tomás","spanish":"Sí, tengo tiempo.","english":"Yes, I have time."}
    ]'::jsonb,
    grammar_note = 'Ser and estar both mean "to be" but cover different territory. Ser is for identity and traits (Soy alto, I''m tall). Estar is for states and locations (Estoy en casa, I''m at home).'
  where id = v_l1;

  update public.lessons set
    intro = 'Learn the yo (I), tú (you), and él / ella (he / she) forms of the five essential verbs. These are the building blocks of every Spanish sentence.',
    vocab_items = '[
      {"word":"soy / eres / es","phonetic":"[SOY / EH-rehs / EHS]","english":"I am / you are / he-she is","example_es":"Soy estudiante.","example_en":"I''m a student."},
      {"word":"estoy / estás / está","phonetic":"[ehs-TOY / ehs-TAHS / ehs-TAH]","english":"forms of estar","example_es":"Estoy bien.","example_en":"I''m fine."},
      {"word":"tengo / tienes / tiene","phonetic":"[TEHN-goh / TYEH-nehs / TYEH-neh]","english":"forms of tener","example_es":"Tengo un perro.","example_en":"I have a dog."},
      {"word":"voy / vas / va","phonetic":"[BOY / BAHS / BAH]","english":"forms of ir","example_es":"Voy al cine.","example_en":"I go to the cinema."},
      {"word":"hago / haces / hace","phonetic":"[AH-goh / AH-sehs / AH-seh]","english":"forms of hacer","example_es":"Hago café.","example_en":"I make coffee."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"A","spanish":"Yo soy profesor. ¿Tú qué eres?","english":"I''m a teacher. What are you?"},
      {"speaker":"B","spanish":"Soy estudiante. Tengo veinte años.","english":"I''m a student. I''m twenty."},
      {"speaker":"A","spanish":"¿Y qué haces hoy?","english":"And what are you doing today?"},
      {"speaker":"B","spanish":"Voy a la biblioteca.","english":"I''m going to the library."}
    ]'::jsonb,
    grammar_note = 'Spanish verb endings show who is doing the action, so you can usually drop the pronoun: Soy = I am, eres = you are, es = he/she is. The endings -o, -es, -e tell you the subject.'
  where id = v_l2;

  update public.lessons set
    intro = 'These mini-sentences with the five core verbs are the bread and butter of conversation.',
    vocab_items = '[
      {"word":"Soy de","phonetic":"[SOY deh]","english":"I''m from","example_es":"Soy de Madrid.","example_en":"I''m from Madrid."},
      {"word":"Estoy bien","phonetic":"[ehs-TOY BYEHN]","english":"I''m fine","example_es":"Hoy estoy muy bien.","example_en":"Today I''m really well."},
      {"word":"Tengo hambre","phonetic":"[TEHN-goh AHM-breh]","english":"I''m hungry","example_es":"Tengo mucha hambre.","example_en":"I''m very hungry."},
      {"word":"Voy al trabajo","phonetic":"[BOY ahl trah-BAH-hoh]","english":"I go to work","example_es":"Voy al trabajo en bici.","example_en":"I go to work by bike."},
      {"word":"Hago ejercicio","phonetic":"[AH-goh eh-hehr-SEE-syoh]","english":"I exercise","example_es":"Hago ejercicio cada día.","example_en":"I exercise every day."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Lía","spanish":"¿De dónde eres?","english":"Where are you from?"},
      {"speaker":"Pablo","spanish":"Soy de Granada.","english":"I''m from Granada."},
      {"speaker":"Lía","spanish":"¿Y qué haces aquí?","english":"And what are you doing here?"},
      {"speaker":"Pablo","spanish":"Voy a una conferencia.","english":"I''m going to a conference."}
    ]'::jsonb,
    grammar_note = 'Ser for origin: Soy de + place (Soy de México). Estar for current location: Estoy en + place (Estoy en Madrid). Both translate as "to be" but they''re NOT interchangeable.'
  where id = v_l3;

  update public.lessons set
    intro = 'These five verbs sound very similar in fast speech. Train your ear to catch the right form.',
    vocab_items = '[
      {"word":"somos / sois / son","phonetic":"[SOH-mohs / SOYS / SOHN]","english":"we are / you all are / they are","example_es":"Somos amigos.","example_en":"We''re friends."},
      {"word":"estamos / estáis / están","phonetic":"[ehs-TAH-mohs]","english":"forms of estar (plural)","example_es":"Estamos en casa.","example_en":"We''re at home."},
      {"word":"tenemos / tenéis / tienen","phonetic":"[teh-NEH-mohs]","english":"forms of tener (plural)","example_es":"Tenemos tiempo.","example_en":"We have time."},
      {"word":"vamos / vais / van","phonetic":"[BAH-mohs]","english":"forms of ir (plural)","example_es":"Vamos al cine.","example_en":"We''re going to the cinema."},
      {"word":"hacemos / hacéis / hacen","phonetic":"[ah-SEH-mohs]","english":"forms of hacer (plural)","example_es":"Hacemos la cena.","example_en":"We make dinner."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Madre","spanish":"¿Dónde están los niños?","english":"Where are the kids?"},
      {"speaker":"Padre","spanish":"Están en el parque.","english":"They''re in the park."},
      {"speaker":"Madre","spanish":"¿Y qué hacen?","english":"And what are they doing?"},
      {"speaker":"Padre","spanish":"Juegan al fútbol.","english":"They''re playing football."}
    ]'::jsonb,
    grammar_note = 'The we form often ends in -mos: somos, estamos, tenemos, vamos, hacemos. The they form usually ends in -n: son, están, tienen, van, hacen. These patterns repeat across hundreds of verbs.'
  where id = v_l4;

  update public.lessons set
    intro = 'Practice speaking with the five workhorses. Pay attention to clear vowels and the verb endings.',
    vocab_items = '[
      {"word":"Yo soy de","phonetic":"[yoh SOY deh]","english":"I''m from","example_es":"Yo soy de Perú.","example_en":"I''m from Peru."},
      {"word":"Estoy cansado","phonetic":"[ehs-TOY kahn-SAH-doh]","english":"I''m tired","example_es":"Estoy muy cansado hoy.","example_en":"I''m very tired today."},
      {"word":"Tengo veinte años","phonetic":"[TEHN-goh BEHN-teh AH-nyohs]","english":"I''m twenty","example_es":"Tengo veinte años en mayo.","example_en":"I''ll be twenty in May."},
      {"word":"Voy a casa","phonetic":"[BOY ah KAH-sah]","english":"I go home","example_es":"Voy a casa después.","example_en":"I go home afterwards."},
      {"word":"Hago la cena","phonetic":"[AH-goh lah SEH-nah]","english":"I make dinner","example_es":"Hago la cena los lunes.","example_en":"I make dinner on Mondays."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"You","spanish":"Soy estudiante.","english":"I''m a student."},
      {"speaker":"","spanish":"Estoy bien hoy.","english":"I''m well today."},
      {"speaker":"","spanish":"Tengo un hermano.","english":"I have a brother."},
      {"speaker":"","spanish":"Voy a clase a las nueve.","english":"I go to class at nine."}
    ]'::jsonb,
    grammar_note = 'In Spanish, the YO ending for the present is -o for most verbs: hablo, como, vivo, hago, voy (irregular). The pattern -o gives you a quick way to spot the I form.'
  where id = v_l5;

  update public.lessons set
    intro = 'Read a short self-introduction that uses all five core verbs. See them in action together.',
    vocab_items = '[
      {"word":"soy estudiante","phonetic":"[SOY ehs-too-DYAHN-teh]","english":"I''m a student","example_es":"Yo soy estudiante.","example_en":"I am a student."},
      {"word":"tengo veinte años","phonetic":"[TEHN-goh BEHN-teh AH-nyohs]","english":"I''m 20","example_es":"Tengo veinte años.","example_en":"I''m 20 years old."},
      {"word":"vivo en","phonetic":"[BEE-boh ehn]","english":"I live in","example_es":"Vivo en Madrid.","example_en":"I live in Madrid."},
      {"word":"estudio español","phonetic":"[ehs-TOO-dyoh ehs-pah-NYOHL]","english":"I study Spanish","example_es":"Estudio español cada día.","example_en":"I study Spanish every day."},
      {"word":"voy a la universidad","phonetic":"[BOY ah lah oo-nee-behr-see-DAHD]","english":"I go to university","example_es":"Voy a la universidad.","example_en":"I go to university."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Yo soy estudiante.","english":"I am a student."},
      {"speaker":"","spanish":"Tengo veinte años.","english":"I am twenty."},
      {"speaker":"","spanish":"Vivo en Madrid con mi familia.","english":"I live in Madrid with my family."},
      {"speaker":"","spanish":"Estudio español todos los días. Voy a la universidad por la mañana.","english":"I study Spanish every day. I go to university in the morning."}
    ]'::jsonb,
    grammar_note = 'Notice how the speaker leaves out yo most of the time. Spanish verbs already show who, so the pronoun is optional and only added for emphasis: YO soy estudiante (I [emphasis] am a student).'
  where id = v_l6;

  update public.lessons set
    intro = 'Write a short paragraph about yourself. Try to use all five verbs: ser, estar, tener, ir, hacer.',
    vocab_items = '[
      {"word":"Soy + identity","phonetic":"[SOY]","english":"I am","example_es":"Soy profesora.","example_en":"I am a teacher."},
      {"word":"Estoy + state","phonetic":"[ehs-TOY]","english":"I am (state)","example_es":"Estoy cansada.","example_en":"I''m tired."},
      {"word":"Tengo + possession","phonetic":"[TEHN-goh]","english":"I have","example_es":"Tengo dos hijos.","example_en":"I have two kids."},
      {"word":"Voy + a + place","phonetic":"[BOY ah]","english":"I go to","example_es":"Voy al trabajo.","example_en":"I go to work."},
      {"word":"Hago + activity","phonetic":"[AH-goh]","english":"I do","example_es":"Hago ejercicio.","example_en":"I exercise."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Models","spanish":"Soy estudiante de inglés.","english":"I am an English student."},
      {"speaker":"","spanish":"Tengo veinticinco años.","english":"I''m 25."},
      {"speaker":"","spanish":"Voy a clase los lunes.","english":"I go to class on Mondays."},
      {"speaker":"","spanish":"Hago la tarea por la noche.","english":"I do homework at night."}
    ]'::jsonb,
    grammar_note = 'Spanish writers love to chain short sentences with these five verbs. They cover identity (ser), state (estar), possession (tener), motion (ir) and action (hacer) — that''s most of basic communication.'
  where id = v_l7;

end $$;

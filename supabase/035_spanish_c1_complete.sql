-- 035_spanish_c1_complete.sql
-- Full Spanish C1 curriculum. Mirrors the A1/A2/B1/B2 pattern exactly:
-- teaching phase on lessons 1-7, 5 substantive exercises per lesson,
-- listening + speaking additions on lessons 1/2/3/6/7, conversation
-- dialogue at lesson 8 with 6 comprehension questions, and a unit test
-- at lesson 9.
--
-- C1 sections (created as skeletons by migration 015):
--   Idioms & Expressions, Advanced Grammar, Formal Writing, Debate &
--   Discussion, Native Content, Academic Language, Professional
--   Communication, Cultural Nuance, Rhetoric & Persuasion, Advanced
--   Literature, Complex Grammar Structures, Regional Dialects, Slang &
--   Informal Language, Translation Skills, Language Teaching
--
-- C1 grammar coverage: advanced subjunctive (pluperfect, sequence of
-- tenses), complex passive constructions, register switching (formal
-- vs informal), nominalization, advanced connectors and discourse
-- markers, idiomatic structures, complex relative clauses.
--
-- Idempotent.

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
  v_l1 bigint; v_l2 bigint; v_l3 bigint; v_l4 bigint;
  v_l5 bigint; v_l6 bigint; v_l7 bigint; v_l8 bigint;
  v_lesson_id bigint;
begin
  select id into v_lang_id from public.languages where code = 'spanish';

  -- ===========================================================
  -- C1.1 IDIOMS & EXPRESSIONS
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'C1' and title = 'Idioms & Expressions';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='Spanish is rich in idioms about everyday life. Mastering them signals true proficiency. Many use body parts: "estar hasta las narices" (to be fed up).',
    vocab_items='[{"spanish":"estar hasta las narices","english":"to be fed up"},{"spanish":"meter la pata","english":"to put one''s foot in it"},{"spanish":"tomar el pelo","english":"to pull someone''s leg"},{"spanish":"echar una mano","english":"to lend a hand"},{"spanish":"costar un ojo de la cara","english":"to cost an arm and a leg"},{"spanish":"no tener pelos en la lengua","english":"to speak one''s mind"},{"spanish":"dar en el clavo","english":"to hit the nail on the head"},{"spanish":"hablar por los codos","english":"to talk one''s head off"}]'::jsonb,
    dialogue='[{"speaker":"Marta","spanish":"Estoy hasta las narices del tráfico.","english":"I''m fed up with the traffic."},{"speaker":"Pablo","spanish":"Y eso que viajaste en metro hoy.","english":"And that''s despite the fact you took the metro today."}]'::jsonb,
    grammar_note='"Y eso que + indicative" = "and that''s despite the fact that...". A nuanced concessive structure showing surprise that something is the case.'
  where id = v_l1;

  update public.lessons set
    intro='Animal idioms paint vivid pictures: "ser un lince" (to be a lynx = clever), "tener vista de águila" (eagle eyes).',
    vocab_items='[{"spanish":"ser un lince","english":"to be sharp/clever"},{"spanish":"tener vista de águila","english":"to have eagle eyes"},{"spanish":"estar como una cabra","english":"to be crazy"},{"spanish":"comer como una lima","english":"to eat like a horse"},{"spanish":"ser una rata","english":"to be a miser"},{"spanish":"llorar como una magdalena","english":"to cry like a baby"},{"spanish":"dormir como un tronco","english":"to sleep like a log"},{"spanish":"trabajar como una mula","english":"to work like a mule"}]'::jsonb,
    dialogue='[{"speaker":"Ana","spanish":"Anoche dormí como un tronco.","english":"Last night I slept like a log."},{"speaker":"Juan","spanish":"Ojalá yo hubiera podido dormir así.","english":"I wish I could have slept like that."}]'::jsonb,
    grammar_note='"Ojalá + pluperfect subjunctive" = wishes about the unrealized past: "ojalá hubiera podido" = "I wish I had been able to". Compare with "ojalá pudiera" (present wish).'
  where id = v_l2;

  update public.lessons set
    intro='Color idioms reveal cultural attitudes: "ponerse rojo" (to blush), "estar en blanco" (to be blank).',
    vocab_items='[{"spanish":"ponerse rojo","english":"to blush"},{"spanish":"estar en blanco","english":"to draw a blank"},{"spanish":"verlo todo negro","english":"to see things bleakly"},{"spanish":"tener mal humor de perros","english":"to be in a foul mood"},{"spanish":"verde de envidia","english":"green with envy"},{"spanish":"el príncipe azul","english":"prince charming"},{"spanish":"la oveja negra","english":"the black sheep"},{"spanish":"sangre azul","english":"blue blood"}]'::jsonb,
    dialogue='[{"speaker":"Sara","spanish":"Cuando se lo dije, se puso rojo como un tomate.","english":"When I told him, he blushed like a tomato."}]'::jsonb,
    grammar_note='"Ponerse + adjective" = change of state: "ponerse rojo", "ponerse triste", "ponerse nervioso". Distinct from "estar" (state) or "ser" (essence).'
  where id = v_l3;

  update public.lessons set
    intro='Food idioms abound: "estar en su salsa" (in one''s element), "ser pan comido" (a piece of cake).',
    vocab_items='[{"spanish":"estar en su salsa","english":"to be in one''s element"},{"spanish":"ser pan comido","english":"to be a piece of cake"},{"spanish":"importar un pepino","english":"to not care a bit"},{"spanish":"darle calabazas","english":"to reject (a suitor)"},{"spanish":"ser la leche","english":"to be incredible (good or bad)"},{"spanish":"montar un pollo","english":"to make a scene"},{"spanish":"ponerse las botas","english":"to stuff oneself"},{"spanish":"mandar a freír espárragos","english":"to tell someone to get lost"}]'::jsonb,
    dialogue='[{"speaker":"Lucía","spanish":"El examen fue pan comido.","english":"The exam was a piece of cake."},{"speaker":"Mario","spanish":"Para ti, que llevas meses estudiando.","english":"For you, who''ve been studying for months."}]'::jsonb,
    grammar_note='"Llevar + time + gerund" = "to have been + V-ing for + time": "llevo meses estudiando" = "I''ve been studying for months". Equivalent to "hace meses que estudio".'
  where id = v_l4;

  update public.lessons set
    intro='Weather idioms: "llover a cántaros" (to rain buckets), "hacer un sol de justicia" (to be blazing hot).',
    vocab_items='[{"spanish":"llover a cántaros","english":"to pour rain"},{"spanish":"hacer un sol de justicia","english":"to be blazing hot"},{"spanish":"caer chuzos de punta","english":"to rain cats and dogs"},{"spanish":"estar como unas pascuas","english":"to be over the moon"},{"spanish":"hacer un frío que pela","english":"to be freezing cold"},{"spanish":"haber moros en la costa","english":"to be danger nearby"},{"spanish":"a buenas horas, mangas verdes","english":"too little, too late"},{"spanish":"a otro perro con ese hueso","english":"don''t pull my leg"}]'::jsonb,
    dialogue='[{"speaker":"Eva","spanish":"Está lloviendo a cántaros.","english":"It''s pouring rain."},{"speaker":"Tomás","spanish":"Y yo sin paraguas.","english":"And me without an umbrella."}]'::jsonb,
    grammar_note='Elliptical exclamations: "Y yo sin paraguas" — incomplete sentences imply a verb ("estoy", "voy"). Very common in spoken Spanish.'
  where id = v_l5;

  update public.lessons set
    intro='Listen to native speakers using idioms. The challenge is recognizing them in fast speech.',
    vocab_items='[{"spanish":"el refrán","english":"saying/proverb"},{"spanish":"la expresión","english":"expression"},{"spanish":"la frase hecha","english":"set phrase"},{"spanish":"el modismo","english":"idiom"},{"spanish":"coloquial","english":"colloquial"},{"spanish":"informal","english":"informal"},{"spanish":"reconocer","english":"to recognize"}]'::jsonb,
    dialogue='[{"speaker":"Amigo 1","spanish":"Mi jefe es la leche, ayer me dio plantón.","english":"My boss is unbelievable, yesterday he stood me up."},{"speaker":"Amigo 2","spanish":"Vaya, qué cara más dura tiene.","english":"Wow, what nerve he has."}]'::jsonb,
    grammar_note='"Dar plantón" = to stand someone up. "Tener cara dura" = to have nerve/audacity. "Vaya" as interjection expresses surprise or commentary.'
  where id = v_l6;

  update public.lessons set
    intro='Write a paragraph weaving in idioms. The trick is integration: use them naturally, not mechanically.',
    vocab_items='[{"spanish":"integrar","english":"to integrate"},{"spanish":"natural","english":"natural"},{"spanish":"forzado","english":"forced"},{"spanish":"el contexto","english":"context"},{"spanish":"apropiado","english":"appropriate"},{"spanish":"el registro","english":"register"},{"spanish":"matizar","english":"to nuance"}]'::jsonb,
    dialogue='[{"speaker":"Texto","spanish":"Después de meses trabajando como una mula, por fin podía ponerme las botas en las vacaciones.","english":"After months of working like a mule, I could finally stuff myself on vacation."},{"speaker":"Texto","spanish":"Mi hermana, que es un lince para los descuentos, encontró un viaje a precio de saldo.","english":"My sister, who''s sharp at finding discounts, found a trip at a bargain price."}]'::jsonb,
    grammar_note='"A precio de saldo" = "at a bargain price". Another colloquial expression worth noting: "estar de saldo" = "to be on clearance".'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What does "estar hasta las narices" mean?','to be fed up',array['to have a cold','to be very tall','to be near'],'fed up',1),
  (v_l1,'multiple_choice','What does "meter la pata" mean?','to mess up',array['to walk','to step','to enter'],'mess up',2),
  (v_l1,'fill_blank','Complete: "Y eso ____ viajaste en metro." (despite that fact)','que',array['cuando','aunque','si'],'and despite (y eso que)',3),
  (v_l1,'multiple_choice','What does "dar en el clavo" mean?','to hit the nail on the head',array['to use a hammer','to fix something','to nail it (literal)'],'hit the nail on the head',4),
  (v_l1,'multiple_choice','What does "echar una mano" mean?','to lend a hand',array['to throw a hand','to wash hands','to raise hands'],'lend a hand',5),
  (v_l2,'multiple_choice','What does "ser un lince" mean?','to be sharp/clever',array['to be a wildcat','to be cold','to be silent'],'to be clever',1),
  (v_l2,'multiple_choice','What does "dormir como un tronco" mean?','to sleep deeply',array['to sleep standing','to sleep little','to sleep alone'],'sleep like a log',2),
  (v_l2,'fill_blank','Complete: "Ojalá yo ____ podido dormir así." (had — pluperf subj)','hubiera',array['había','habría','habré'],'had (subj)',3),
  (v_l2,'multiple_choice','What does "comer como una lima" mean?','to eat a lot',array['to eat little','to eat slowly','to eat noisily'],'eat like a horse',4),
  (v_l2,'multiple_choice','What does "estar como una cabra" mean?','to be crazy',array['to be stubborn','to be playful','to be hungry'],'be crazy',5),
  (v_l3,'multiple_choice','What does "ponerse rojo" mean?','to blush',array['to wear red','to get angry','to bleed'],'blush',1),
  (v_l3,'multiple_choice','What does "verde de envidia" mean?','green with envy',array['greenish','jealous of greenery','envious of green'],'green with envy',2),
  (v_l3,'fill_blank','Complete: "Se ____ rojo." (became)','puso',array['fue','estuvo','estaba'],'became',3),
  (v_l3,'multiple_choice','What does "la oveja negra" mean?','the black sheep',array['a black animal','a dark figure','a hidden member'],'black sheep',4),
  (v_l3,'multiple_choice','What does "el príncipe azul" mean?','prince charming',array['blue prince (literal)','a fictional prince','sad prince'],'prince charming',5),
  (v_l4,'multiple_choice','What does "ser pan comido" mean?','to be a piece of cake',array['to be edible','to be hungry','to be tasty'],'piece of cake',1),
  (v_l4,'multiple_choice','What does "importar un pepino" mean?','to not care a bit',array['to import vegetables','to care a lot','to care a little'],'not care',2),
  (v_l4,'fill_blank','Complete: "Llevo meses ____" (studying)','estudiando',array['estudiado','estudiar','estudio'],'studying (gerund)',3),
  (v_l4,'multiple_choice','What does "ponerse las botas" mean?','to stuff oneself',array['to wear boots','to walk far','to leave'],'stuff oneself',4),
  (v_l4,'multiple_choice','What does "darle calabazas" mean?','to reject (a suitor)',array['to give pumpkins','to share food','to celebrate Halloween'],'reject suitor',5),
  (v_l5,'multiple_choice','What does "llover a cántaros" mean?','to pour rain',array['to sprinkle','to mist','to drizzle'],'pour rain',1),
  (v_l5,'multiple_choice','What does "a buenas horas, mangas verdes" mean?','too little, too late',array['perfect timing','right on time','early bird'],'too little too late',2),
  (v_l5,'fill_blank','Complete: "Y yo ____ paraguas." (without)','sin',array['con','sin que','en'],'without (ellipsis)',3),
  (v_l5,'multiple_choice','What does "hacer un sol de justicia" mean?','to be blazing hot',array['to be sunny','to be warm','to be pleasant'],'blazing hot',4),
  (v_l5,'multiple_choice','What does "a otro perro con ese hueso" mean?','don''t pull my leg',array['feed another dog','share with others','give to charity'],'don''t pull my leg',5),
  (v_l6,'multiple_choice','What does "dar plantón" mean?','to stand someone up',array['to plant a tree','to give a plant','to upright someone'],'stand someone up',1),
  (v_l6,'multiple_choice','What does "tener cara dura" mean?','to have nerve',array['to have hard skin','to be ugly','to look stern'],'have nerve',2),
  (v_l6,'fill_blank','Complete: "Mi jefe es la ____" (incredible)','leche',array['leche (incorrect)','cosa','onda'],'incredible',3),
  (v_l6,'multiple_choice','What is "modismo"?','idiom',array['modesty','modulation','module'],'idiom',4),
  (v_l6,'multiple_choice','What does "vaya" express here?','surprise/commentary',array['ordering "go!"','farewell','disagreement'],'expressive interjection',5),
  (v_l7,'multiple_choice','What does "a precio de saldo" mean?','at a bargain price',array['at retail price','at a high price','at no price'],'bargain price',1),
  (v_l7,'multiple_choice','What does "trabajar como una mula" mean?','to work very hard',array['to work like an animal','to work slowly','to work alone'],'work like a mule',2),
  (v_l7,'fill_blank','Complete: "Por fin podía ____ las botas." (stuff oneself - infinitive)','ponerme',array['poner','pongo','puesto'],'stuff myself',3),
  (v_l7,'multiple_choice','What is "register" (language)?','el registro',array['la pista','el carnet','la entrada'],'register',4),
  (v_l7,'multiple_choice','What does "natural" mean here?','genuine/unforced',array['biological','national','nominal'],'genuine',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Estoy hasta las narices del tráfico',array['Y eso que viajaste en metro','He tenido un día horrible','El metro es lento'],'I''m fed up with the traffic',6),
  (v_l1,'listening','What did you hear?','Y eso que viajaste en metro hoy',array['Estoy hasta las narices','El tráfico es terrible','El metro es eficiente'],'And that''s despite the fact you took the metro today',7),
  (v_l1,'speaking','Say this aloud: "Estoy hasta las narices del tráfico."','Estoy hasta las narices del tráfico',array[]::text[],'I''m fed up with the traffic.',8),
  (v_l1,'speaking','Say this aloud: "Dio en el clavo con su respuesta."','Dio en el clavo con su respuesta',array[]::text[],'He hit the nail on the head with his answer.',9),
  (v_l2,'listening','What did you hear?','Anoche dormí como un tronco',array['Ojalá yo hubiera podido','Trabajé como una mula','Estoy como una cabra'],'Last night I slept like a log',6),
  (v_l2,'listening','What did you hear?','Ojalá yo hubiera podido dormir así',array['Anoche dormí como un tronco','Trabajé hasta tarde','Necesito descansar'],'I wish I could have slept like that',7),
  (v_l2,'speaking','Say this aloud: "Anoche dormí como un tronco."','Anoche dormí como un tronco',array[]::text[],'Last night I slept like a log.',8),
  (v_l2,'speaking','Say this aloud: "Mi hermano es un lince."','Mi hermano es un lince',array[]::text[],'My brother is sharp.',9),
  (v_l3,'listening','What did you hear?','Cuando se lo dije, se puso rojo como un tomate',array['Estaba verde de envidia','Llegó a la fiesta tarde','Se rio sin parar'],'When I told him, he blushed like a tomato',6),
  (v_l3,'listening','What did you hear?','se puso rojo como un tomate',array['se puso verde de envidia','se puso pálido','se puso furioso'],'he blushed like a tomato',7),
  (v_l3,'speaking','Say this aloud: "Se puso rojo como un tomate."','Se puso rojo como un tomate',array[]::text[],'He blushed like a tomato.',8),
  (v_l3,'speaking','Say this aloud: "Es la oveja negra de la familia."','Es la oveja negra de la familia',array[]::text[],'He''s the black sheep of the family.',9),
  (v_l6,'listening','What did you hear?','Mi jefe es la leche, ayer me dio plantón',array['Tiene mucha cara dura','El plantón fue intencional','Tenemos una reunión'],'My boss is unbelievable, yesterday he stood me up',6),
  (v_l6,'listening','What did you hear?','Vaya, qué cara más dura tiene',array['Mi jefe me dio plantón','Es la leche','Tiene mucho descaro'],'Wow, what nerve he has',7),
  (v_l6,'speaking','Say this aloud: "Mi jefe es la leche."','Mi jefe es la leche',array[]::text[],'My boss is unbelievable.',8),
  (v_l6,'speaking','Say this aloud: "Qué cara más dura tiene."','Qué cara más dura tiene',array[]::text[],'What nerve he has.',9),
  (v_l7,'listening','What did you hear?','Después de meses trabajando como una mula',array['Por fin podía ponerme las botas','Mi hermana es un lince','Encontró un viaje barato'],'After months of working like a mule',6),
  (v_l7,'listening','What did you hear?','encontró un viaje a precio de saldo',array['encontró un descuento enorme','encontró una oferta única','encontró un destino caro'],'she found a trip at a bargain price',7),
  (v_l7,'speaking','Say this aloud: "Por fin podía ponerme las botas."','Por fin podía ponerme las botas',array[]::text[],'I could finally stuff myself.',8),
  (v_l7,'speaking','Say this aloud: "A precio de saldo."','A precio de saldo',array[]::text[],'At a bargain price.',9);

  update public.lessons set type='conversation', title='Idioms & Expressions — Conversation Practice',
    description='Two friends chat using lots of idioms.',
    intro='Marta and Pablo catch up over coffee.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Marta","spanish":"Estoy hasta las narices del trabajo. Llevo meses trabajando como una mula.","english":"I''m fed up with work. I''ve been working like a mule for months."},{"speaker":"Pablo","spanish":"Ojalá hubieras pedido vacaciones antes. Ahora pareces a punto de estar como una cabra.","english":"I wish you had asked for vacation sooner. Now you look like you''re about to go crazy."},{"speaker":"Marta","spanish":"Mi jefe es la leche. Ayer me dio plantón en una reunión clave.","english":"My boss is unbelievable. Yesterday he stood me up at a key meeting."},{"speaker":"Pablo","spanish":"Vaya cara más dura. ¿Le diste calabazas a su propuesta?","english":"What nerve. Did you reject his proposal?"},{"speaker":"Marta","spanish":"Casi le mando a freír espárragos, pero me mordí la lengua.","english":"I almost told him to get lost, but I bit my tongue."},{"speaker":"Pablo","spanish":"Bueno, ahora vámonos a ponernos las botas a ese restaurante nuevo.","english":"Well, now let''s go stuff ourselves at that new restaurant."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','How does Marta feel about work?','Fed up — working like a mule for months',array['Happy and energized','Indifferent','Nostalgic'],'hasta las narices, como una mula',1),
  (v_l8,'multiple_choice','Pablo''s wish?','That she had asked for vacation sooner',array['That she had quit','That she had complained','That she had done nothing'],'ojalá hubieras pedido vacaciones',2),
  (v_l8,'multiple_choice','What did her boss do?','Stood her up at a key meeting',array['Fired her','Gave her a raise','Apologized'],'me dio plantón',3),
  (v_l8,'multiple_choice','Marta''s near-reaction?','Almost told him to get lost',array['Almost punched him','Almost cried','Almost laughed'],'casi le mando a freír espárragos',4),
  (v_l8,'fill_blank','Complete: "Ojalá ____ pedido vacaciones." (had — subj)','hubieras',array['habías','habrías','has'],'had (subj)',5),
  (v_l8,'multiple_choice','What''s the plan now?','Stuff themselves at a new restaurant',array['Go home and rest','Go to therapy','Plan a strike'],'ponernos las botas',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Idioms & Expressions', 'Review test for the Idioms & Expressions section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What does "estar hasta las narices" mean?','to be fed up',array['to be ill','to be very tall','to be near'],'fed up',1),
  (v_lesson_id,'multiple_choice','What does "ser pan comido" mean?','to be a piece of cake',array['to be edible','to be hungry','to be tasty'],'piece of cake',2),
  (v_lesson_id,'multiple_choice','What does "llover a cántaros" mean?','to pour rain',array['to drizzle','to snow','to thunder'],'pour rain',3),
  (v_lesson_id,'multiple_choice','What does "dar plantón" mean?','to stand someone up',array['to plant something','to upright someone','to give plants'],'stand someone up',4),
  (v_lesson_id,'fill_blank','Complete: "Ojalá ____ pedido ayuda antes." (had — subj)','hubieras',array['habías','habrías','has'],'had (subj)',5),
  (v_lesson_id,'fill_blank','Complete: "Llevo años ____" (working)','trabajando',array['trabajado','trabajar','trabaje'],'working (gerund)',6),
  (v_lesson_id,'listening','What did you hear?','Por fin podía ponerme las botas en las vacaciones',array['Estoy hasta las narices','Ojalá hubiera podido descansar','Trabajé como una mula'],'Finally I could stuff myself on vacation',7),
  (v_lesson_id,'listening','What did you hear?','Mi jefe es la leche, ayer me dio plantón',array['Tengo un día horrible','Vaya cara dura','Estoy harto del trabajo'],'My boss is unbelievable, yesterday he stood me up',8),
  (v_lesson_id,'speaking','Say this aloud: "Estoy hasta las narices."','Estoy hasta las narices',array[]::text[],'I''m fed up.',9),
  (v_lesson_id,'speaking','Say this aloud: "Por fin pude ponerme las botas."','Por fin pude ponerme las botas',array[]::text[],'I finally got to stuff myself.',10);

  -- ===========================================================
  -- C1.2 ADVANCED GRAMMAR
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'C1' and title = 'Advanced Grammar';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='Sequence of tenses in subjunctive: when the main verb is in past/conditional, the subordinate uses imperfect subjunctive. Master "quería que vinieras" not "quería que vengas".',
    vocab_items='[{"spanish":"la concordancia","english":"agreement"},{"spanish":"la consecutio temporum","english":"sequence of tenses"},{"spanish":"la subordinada","english":"subordinate clause"},{"spanish":"la principal","english":"main clause"},{"spanish":"el modo","english":"mood"},{"spanish":"el tiempo verbal","english":"verb tense"},{"spanish":"regir","english":"to govern"},{"spanish":"depender de","english":"to depend on"},{"spanish":"imponer","english":"to impose"},{"spanish":"la restricción","english":"restriction"}]'::jsonb,
    dialogue='[{"speaker":"Profesor","spanish":"Si dices "quería que vengas", el oyente percibe una incongruencia temporal.","english":"If you say ''quería que vengas'', the listener perceives a temporal incongruity."},{"speaker":"Alumna","spanish":"¿Por qué exactamente?","english":"Why exactly?"},{"speaker":"Profesor","spanish":"Porque "quería" pide imperfecto: "que vinieras".","english":"Because ''quería'' requires the imperfect: ''que vinieras''."}]'::jsonb,
    grammar_note='Sequence of tenses: past main → past subjunctive subordinate ("quería que vinieras"); present main → present subjunctive ("quiero que vengas"). The mismatch sounds ungrammatical.'
  where id = v_l1;

  update public.lessons set
    intro='The future subjunctive ("viniere", "fuere") survives in legal Spanish and frozen phrases like "sea como fuere" (be that as it may).',
    vocab_items='[{"spanish":"sea como fuere","english":"be that as it may"},{"spanish":"pase lo que pasare","english":"come what may"},{"spanish":"adonde fueres haz lo que vieres","english":"when in Rome..."},{"spanish":"fuere quien fuere","english":"whoever it may be"},{"spanish":"el futuro de subjuntivo","english":"future subjunctive"},{"spanish":"arcaico","english":"archaic"},{"spanish":"el ámbito jurídico","english":"legal domain"},{"spanish":"vigente","english":"in force"},{"spanish":"fosilizado","english":"fossilized"}]'::jsonb,
    dialogue='[{"speaker":"Lingüista","spanish":"Aunque sea arcaico, el futuro de subjuntivo aparece en proverbios y en la legislación.","english":"Although it''s archaic, the future subjunctive appears in proverbs and in legislation."}]'::jsonb,
    grammar_note='"Aunque sea arcaico" — present subjunctive concession. The future subjunctive itself ("fuere", "viniere") forms by replacing the final -a/-an of the imperfect subjunctive -ra form with -e/-en.'
  where id = v_l2;

  update public.lessons set
    intro='Compound subjunctive forms: "haya hablado" (perfect subj), "hubiera hablado" (pluperfect subj). Use them for completed actions in subjunctive contexts.',
    vocab_items='[{"spanish":"el subjuntivo perfecto","english":"perfect subjunctive"},{"spanish":"el pluscuamperfecto de subjuntivo","english":"pluperfect subjunctive"},{"spanish":"la acción anterior","english":"prior action"},{"spanish":"el aspecto","english":"aspect"},{"spanish":"completado","english":"completed"},{"spanish":"hipotético","english":"hypothetical"}]'::jsonb,
    dialogue='[{"speaker":"Hablante 1","spanish":"Espero que ya haya llegado.","english":"I hope he has already arrived."},{"speaker":"Hablante 2","spanish":"Si hubiera salido a tiempo, sí.","english":"If he had left on time, yes."}]'::jsonb,
    grammar_note='"Haya + past participle" expresses completed action in present subjunctive contexts: "espero que haya llegado". "Hubiera + past participle" for past hypotheticals: "si hubiera salido".'
  where id = v_l3;

  update public.lessons set
    intro='Passive voice variants: "ser + past participle" (true passive), "estar + past participle" (resultant state), passive "se".',
    vocab_items='[{"spanish":"la voz pasiva","english":"passive voice"},{"spanish":"la pasiva refleja","english":"reflexive passive"},{"spanish":"el agente","english":"agent"},{"spanish":"el complemento agente","english":"agent complement"},{"spanish":"la atribución","english":"attribution"},{"spanish":"el resultado","english":"result"},{"spanish":"omitir","english":"to omit"},{"spanish":"explícito","english":"explicit"}]'::jsonb,
    dialogue='[{"speaker":"Profesora","spanish":"La novela fue escrita por Cervantes (verdadera pasiva) vs La novela está escrita (estado resultante).","english":"The novel was written by Cervantes (true passive) vs The novel is written (resultant state)."}]'::jsonb,
    grammar_note='Three passive options: 1) "ser" + ppt + "por" (formal, agent explicit), 2) "estar" + ppt (no agent, focus on state), 3) "se" + verb (general/impersonal). Choose based on emphasis.'
  where id = v_l4;

  update public.lessons set
    intro='Relative clauses with prepositions: "el libro del que te hablé" (the book I told you about). Spanish often requires more prepositions than English.',
    vocab_items='[{"spanish":"el pronombre relativo","english":"relative pronoun"},{"spanish":"el cual / la cual","english":"which (formal)"},{"spanish":"cuyo / cuya","english":"whose"},{"spanish":"al cual / a la cual","english":"to which"},{"spanish":"con el cual","english":"with which"},{"spanish":"sin el cual","english":"without which"},{"spanish":"por lo cual","english":"for which reason"}]'::jsonb,
    dialogue='[{"speaker":"Conferenciante","spanish":"El autor cuya obra estudiamos hoy es relativamente desconocido.","english":"The author whose work we''re studying today is relatively unknown."}]'::jsonb,
    grammar_note='"Cuyo/a/os/as" = "whose". Agrees with the noun it modifies, not with the possessor: "el autor cuya OBRA" (cuya agrees with obra, fem sing).'
  where id = v_l5;

  update public.lessons set
    intro='Listen to a grammar podcast. Hosts explain rules with examples — focus on the analytical vocabulary.',
    vocab_items='[{"spanish":"el podcast","english":"podcast"},{"spanish":"el episodio","english":"episode"},{"spanish":"el ejemplo","english":"example"},{"spanish":"ilustrar","english":"to illustrate"},{"spanish":"clarificar","english":"to clarify"},{"spanish":"la regla","english":"rule"},{"spanish":"la excepción","english":"exception"}]'::jsonb,
    dialogue='[{"speaker":"Presentadora","spanish":"Hoy abordaremos una construcción que confunde incluso a los hablantes nativos.","english":"Today we will address a construction that confuses even native speakers."},{"speaker":"Presentadora","spanish":"Se trata del subjuntivo en oraciones independientes.","english":"It''s about the subjunctive in independent clauses."}]'::jsonb,
    grammar_note='"Se trata de + noun" = "it''s about + noun". Common podcast/academic discourse marker for topic introduction.'
  where id = v_l6;

  update public.lessons set
    intro='Write analyzing a grammatical pattern. Use precise terminology and clear examples.',
    vocab_items='[{"spanish":"analizar","english":"to analyze"},{"spanish":"sintáctico","english":"syntactic"},{"spanish":"semántico","english":"semantic"},{"spanish":"pragmático","english":"pragmatic"},{"spanish":"distinguir","english":"to distinguish"},{"spanish":"el matiz","english":"nuance"},{"spanish":"el contraste","english":"contrast"},{"spanish":"contrastar","english":"to contrast"}]'::jsonb,
    dialogue='[{"speaker":"Texto","spanish":"Conviene distinguir entre "porque" causal y "para que" final, dos conectores cuyo uso varía radicalmente.","english":"It is appropriate to distinguish between causal ''porque'' and final ''para que'', two connectors whose use varies radically."}]'::jsonb,
    grammar_note='"Conviene + infinitive" = "it is appropriate/wise to + verb". A neutral, slightly formal alternative to "se debe" or "hay que".'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "sequence of tenses"?','la consecutio temporum',array['la sintaxis','la concordancia','el aspecto'],'sequence of tenses',1),
  (v_l1,'multiple_choice','What does past main verb require in subjunctive?','imperfect subjunctive',array['present subjunctive','future subjunctive','perfect subjunctive'],'past triggers imperfect subj',2),
  (v_l1,'fill_blank','Complete: "Quería que ____" (you came — imperf subj)','vinieras',array['vengas','venías','vendrías'],'came (subj)',3),
  (v_l1,'multiple_choice','What does "regir" mean (gram)?','to govern (a tense/mood)',array['to register','to refrain','to retain'],'to govern',4),
  (v_l1,'multiple_choice','What is "main clause"?','la principal',array['la subordinada','la coordinada','la independiente'],'main clause',5),
  (v_l2,'multiple_choice','What does "sea como fuere" mean?','be that as it may',array['be what it is','it''ll be what it''ll be','be careful'],'be that as it may',1),
  (v_l2,'multiple_choice','Where is future subjunctive still active?','legal/fixed phrases',array['everyday speech','radio news','informal chat'],'fossilized contexts',2),
  (v_l2,'fill_blank','Complete: "Pase lo que ____" (may happen — fut subj)','pasare',array['pase','pasa','pasaba'],'may happen (fut subj)',3),
  (v_l2,'multiple_choice','What does "vigente" mean?','in force',array['vigilant','vital','vivid'],'in force',4),
  (v_l2,'multiple_choice','What does "fosilizado" mean?','fossilized (preserved unchanged)',array['fossilized (geology)','foolish','focused'],'fossilized',5),
  (v_l3,'multiple_choice','What does "haya llegado" express?','completed action in subj',array['ongoing action','future action','hypothetical action'],'present subj perfect',1),
  (v_l3,'multiple_choice','What is "hubiera salido"?','pluperfect subjunctive',array['present perfect','past perfect','future perfect'],'pluperf subj',2),
  (v_l3,'fill_blank','Complete: "Espero que ya ____ llegado." (has — subj)','haya',array['ha','había','habrá'],'has (subj)',3),
  (v_l3,'multiple_choice','What does "completado" mean?','completed',array['complicated','complemented','composed'],'completed',4),
  (v_l3,'multiple_choice','What is "anterior" (gram)?','prior',array['anterior (body)','front','back'],'prior',5),
  (v_l4,'multiple_choice','True passive structure?','ser + past participle',array['estar + past participle','se + verb','tener + past participle'],'ser passive',1),
  (v_l4,'multiple_choice','What is "agent complement"?','el complemento agente',array['el complemento directo','el complemento indirecto','el sujeto'],'agent complement',2),
  (v_l4,'fill_blank','Complete: "La novela ____ escrita por Cervantes." (was)','fue',array['estuvo','está','era'],'was (true passive)',3),
  (v_l4,'multiple_choice','What does "estar + ppt" emphasize?','resultant state',array['action','agent','time'],'resultant state',4),
  (v_l4,'multiple_choice','What is "pasiva refleja"?','reflexive passive (se)',array['true passive','double passive','no passive'],'pasiva refleja',5),
  (v_l5,'multiple_choice','What does "cuyo" mean?','whose',array['who','which','what'],'whose',1),
  (v_l5,'multiple_choice','"Cuyo" agrees with what?','the modified noun',array['the possessor','the verb','itself'],'agrees with noun',2),
  (v_l5,'fill_blank','Complete: "El autor ____ obra estudiamos." (whose - fem)','cuya',array['cuyo','cuyas','cuyos'],'whose (fem)',3),
  (v_l5,'multiple_choice','What is "el cual"?','which (formal)',array['which (informal)','what','that'],'el cual (formal)',4),
  (v_l5,'multiple_choice','What does "por lo cual" mean?','for which reason',array['by the which','for the cause','because'],'for which reason',5),
  (v_l6,'multiple_choice','What does "se trata de" mean?','it''s about',array['it''s treated','it deals (with people)','it''s drawn'],'it''s about',1),
  (v_l6,'multiple_choice','What does "abordar" mean?','to address (a topic)',array['to abort','to absorb','to abandon'],'to address',2),
  (v_l6,'fill_blank','Complete: "Una construcción que ____ a los nativos." (confuses)','confunde',array['confundía','confundirá','confunda'],'confuses',3),
  (v_l6,'multiple_choice','What does "ilustrar" mean?','to illustrate',array['to illuminate','to insult','to install'],'to illustrate',4),
  (v_l6,'multiple_choice','What is "rule" (gram)?','la regla',array['la ley','la norma (synonym)','la directriz'],'rule',5),
  (v_l7,'multiple_choice','What does "conviene + inf" mean?','it is appropriate to',array['it agrees with','it convenes','it conveys'],'it is appropriate',1),
  (v_l7,'multiple_choice','What is "nuance"?','el matiz',array['el matar','el matado','el matraz'],'nuance',2),
  (v_l7,'fill_blank','Complete: "____ distinguir entre los dos." (it''s appropriate)','Conviene',array['Conviene (incorrect)','Concierne','Continúa'],'it''s appropriate',3),
  (v_l7,'multiple_choice','What does "pragmático" mean?','pragmatic',array['practical (only)','prosaic','programmatic'],'pragmatic',4),
  (v_l7,'multiple_choice','What does "contrastar" mean?','to contrast',array['to contradict','to construct','to contain'],'to contrast',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Si dices "quería que vengas", el oyente percibe una incongruencia',array['Quería pide imperfecto','La concordancia falla','Los tiempos importan'],'If you say ''quería que vengas'', the listener perceives an incongruity',6),
  (v_l1,'listening','What did you hear?','Quería pide imperfecto: que vinieras',array['Quiero pide presente','La principal rige','El subjuntivo varía'],'Quería requires imperfect: que vinieras',7),
  (v_l1,'speaking','Say this aloud: "Quería que vinieras."','Quería que vinieras',array[]::text[],'I wanted you to come.',8),
  (v_l1,'speaking','Say this aloud: "Quiero que vengas."','Quiero que vengas',array[]::text[],'I want you to come.',9),
  (v_l2,'listening','What did you hear?','Aunque sea arcaico, el futuro de subjuntivo aparece en proverbios',array['Sea como fuere','Vigente en legislación','En el ámbito jurídico'],'Although it''s archaic, the future subjunctive appears in proverbs',6),
  (v_l2,'listening','What did you hear?','aparece en proverbios y en la legislación',array['aparece en chat','aparece en TV','aparece en clase'],'appears in proverbs and in legislation',7),
  (v_l2,'speaking','Say this aloud: "Sea como fuere, hay que decidir."','Sea como fuere, hay que decidir',array[]::text[],'Be that as it may, we must decide.',8),
  (v_l2,'speaking','Say this aloud: "Es una forma arcaica."','Es una forma arcaica',array[]::text[],'It''s an archaic form.',9),
  (v_l3,'listening','What did you hear?','Espero que ya haya llegado',array['Si hubiera salido a tiempo','La acción se completó','Esperamos sentados'],'I hope he has already arrived',6),
  (v_l3,'listening','What did you hear?','Si hubiera salido a tiempo, sí',array['Espero que haya llegado','La acción anterior','Es un hipotético'],'If he had left on time, yes',7),
  (v_l3,'speaking','Say this aloud: "Espero que ya haya llegado."','Espero que ya haya llegado',array[]::text[],'I hope he has already arrived.',8),
  (v_l3,'speaking','Say this aloud: "Si hubiera salido antes."','Si hubiera salido antes',array[]::text[],'If he had left earlier.',9),
  (v_l6,'listening','What did you hear?','Hoy abordaremos una construcción que confunde incluso a los hablantes nativos',array['Se trata del subjuntivo','Las reglas son claras','El podcast termina ya'],'Today we will address a construction that confuses even native speakers',6),
  (v_l6,'listening','What did you hear?','Se trata del subjuntivo en oraciones independientes',array['Hoy abordaremos una construcción','Confunde a los nativos','El episodio es largo'],'It''s about the subjunctive in independent clauses',7),
  (v_l6,'speaking','Say this aloud: "Se trata del subjuntivo."','Se trata del subjuntivo',array[]::text[],'It''s about the subjunctive.',8),
  (v_l6,'speaking','Say this aloud: "Hoy abordaremos una construcción complicada."','Hoy abordaremos una construcción complicada',array[]::text[],'Today we''ll address a complicated construction.',9),
  (v_l7,'listening','What did you hear?','Conviene distinguir entre "porque" causal y "para que" final',array['Dos conectores cuyo uso varía','Es un contraste sintáctico','El matiz es importante'],'It is appropriate to distinguish between causal ''porque'' and final ''para que''',6),
  (v_l7,'listening','What did you hear?','dos conectores cuyo uso varía radicalmente',array['conviene distinguirlos','el contraste es claro','los matices importan'],'two connectors whose use varies radically',7),
  (v_l7,'speaking','Say this aloud: "Conviene distinguir los matices."','Conviene distinguir los matices',array[]::text[],'It''s appropriate to distinguish the nuances.',8),
  (v_l7,'speaking','Say this aloud: "Dos conectores cuyo uso varía."','Dos conectores cuyo uso varía',array[]::text[],'Two connectors whose use varies.',9);

  update public.lessons set type='conversation', title='Advanced Grammar — Conversation Practice',
    description='Two linguists discuss a tricky rule.',
    intro='Carla and Esteban prepare a workshop.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Carla","spanish":"¿Cómo explicamos el contraste entre indicativo y subjuntivo en "aunque"?","english":"How do we explain the contrast between indicative and subjunctive in ''aunque''?"},{"speaker":"Esteban","spanish":"Sea como fuere, el ejemplo más claro es: "aunque llueve, salgo" vs "aunque llueva, salgo".","english":"Be that as it may, the clearest example is: ''aunque llueve, salgo'' vs ''aunque llueva, salgo''."},{"speaker":"Carla","spanish":"Conviene matizar que el indicativo presenta un hecho y el subjuntivo, una posibilidad.","english":"It''s appropriate to nuance that the indicative presents a fact and the subjunctive a possibility."},{"speaker":"Esteban","spanish":"Y si el alumno preguntara por qué, le diríamos: "el subjuntivo expresa información no asertada".","english":"And if the student asked why, we''d say: ''the subjunctive expresses non-asserted information''."},{"speaker":"Carla","spanish":"Bien. La clave es que comprendan el matiz, no que memoricen reglas.","english":"Right. The key is that they understand the nuance, not memorize rules."},{"speaker":"Esteban","spanish":"De acuerdo. Cuando hayan asimilado eso, lo demás vendrá solo.","english":"Agreed. When they''ve assimilated that, the rest will come on its own."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','What''s the contrast they discuss?','Indicative vs subjunctive in "aunque"',array['Preterite vs imperfect','Ser vs estar','Por vs para'],'aunque + ind/subj',1),
  (v_l8,'multiple_choice','Indicative in "aunque llueve"?','Presents a fact',array['Presents a possibility','Presents a doubt','Presents a wish'],'fact = indicative',2),
  (v_l8,'multiple_choice','Subjunctive in "aunque llueva"?','Presents a possibility',array['Presents a fact','Presents a doubt','Presents a wish'],'possibility = subj',3),
  (v_l8,'multiple_choice','Their pedagogical priority?','Understanding nuance over memorizing',array['Memorizing rules','Drilling exercises','Translating'],'understand nuance',4),
  (v_l8,'fill_blank','Complete: "Si el alumno ____ por qué." (asked — subj)','preguntara',array['preguntó','pregunta','preguntará'],'asked (subj)',5),
  (v_l8,'multiple_choice','When does the rest come?','When they''ve assimilated this',array['When they finish the book','When they pass exams','When they study more'],'cuando hayan asimilado',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Advanced Grammar', 'Review test for the Advanced Grammar section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','Past main + subj subordinate uses?','imperfect subjunctive',array['present subjunctive','future subjunctive','infinitive'],'sequence of tenses',1),
  (v_lesson_id,'multiple_choice','What does "cuyo" mean?','whose',array['who','which','what'],'whose',2),
  (v_lesson_id,'multiple_choice','True passive structure?','ser + ppt + por',array['estar + ppt','se + verb','tener + ppt'],'true passive',3),
  (v_lesson_id,'multiple_choice','What does "sea como fuere" mean?','be that as it may',array['be careful','it depends','be patient'],'be that as it may',4),
  (v_lesson_id,'fill_blank','Complete: "Quería que ____ a tiempo." (he came — subj)','viniera',array['venga','venía','vendría'],'came (subj)',5),
  (v_lesson_id,'fill_blank','Complete: "Espero que ya ____ llegado." (has — subj)','haya',array['ha','había','habrá'],'has (subj)',6),
  (v_lesson_id,'listening','What did you hear?','Conviene distinguir entre "porque" causal y "para que" final',array['Si hubiera salido a tiempo','Es una forma arcaica','Espero que haya llegado'],'It is appropriate to distinguish between causal ''porque'' and final ''para que''',7),
  (v_lesson_id,'listening','What did you hear?','Aunque sea arcaico, el futuro de subjuntivo aparece en proverbios',array['Se trata del subjuntivo','La concordancia falla','El aspecto importa'],'Although it''s archaic, the future subjunctive appears in proverbs',8),
  (v_lesson_id,'speaking','Say this aloud: "Quería que vinieras."','Quería que vinieras',array[]::text[],'I wanted you to come.',9),
  (v_lesson_id,'speaking','Say this aloud: "El autor cuya obra estudiamos."','El autor cuya obra estudiamos',array[]::text[],'The author whose work we study.',10);

  -- ===========================================================
  -- C1.3 FORMAL WRITING
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'C1' and title = 'Formal Writing';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='Formal Spanish writing requires careful register: avoid contractions, slang, and personal interjections. Master "el presente que suscribe" (the undersigned).',
    vocab_items='[{"spanish":"el escrito","english":"written document"},{"spanish":"el redactor","english":"writer"},{"spanish":"el destinatario","english":"recipient"},{"spanish":"el remitente","english":"sender"},{"spanish":"el cuerpo","english":"body (of text)"},{"spanish":"el encabezado","english":"heading"},{"spanish":"la firma","english":"signature"},{"spanish":"adjuntar","english":"to attach"},{"spanish":"acreditar","english":"to certify"},{"spanish":"el presente que suscribe","english":"the undersigned"}]'::jsonb,
    dialogue='[{"speaker":"Carta","spanish":"Estimado Sr. Pérez: por la presente me dirijo a usted para solicitar...","english":"Dear Mr. Pérez: by the present (letter) I address you to request..."}]'::jsonb,
    grammar_note='Formal opening formulae: "Estimado/a + name", "Por la presente", "Tengo a bien comunicarle". Always use "usted" and the formal register throughout.'
  where id = v_l1;

  update public.lessons set
    intro='Connectors give formal text its structure. Master "no obstante", "por consiguiente", "en consecuencia", "asimismo".',
    vocab_items='[{"spanish":"no obstante","english":"however"},{"spanish":"sin embargo","english":"nevertheless"},{"spanish":"por consiguiente","english":"consequently"},{"spanish":"en consecuencia","english":"as a result"},{"spanish":"asimismo","english":"likewise"},{"spanish":"por otra parte","english":"on the other hand"},{"spanish":"en cuanto a","english":"as for"},{"spanish":"con respecto a","english":"regarding"},{"spanish":"a propósito de","english":"apropos of"},{"spanish":"a fin de","english":"in order to"}]'::jsonb,
    dialogue='[{"speaker":"Memorando","spanish":"Las ventas aumentaron un quince por ciento. No obstante, los gastos también se incrementaron.","english":"Sales increased by fifteen percent. However, expenses also increased."}]'::jsonb,
    grammar_note='"No obstante" is more formal than "pero" or "sin embargo". Used at sentence start, followed by comma. Subtle preference: "no obstante" for stronger contrast.'
  where id = v_l2;

  update public.lessons set
    intro='Nominalization: turning verbs into nouns is the hallmark of formal Spanish. "Decidió" → "tomó la decisión de". "Anunciaron" → "se efectuó el anuncio".',
    vocab_items='[{"spanish":"la nominalización","english":"nominalization"},{"spanish":"sustantivar","english":"to nominalize"},{"spanish":"la realización","english":"realization/execution"},{"spanish":"la ejecución","english":"execution"},{"spanish":"el otorgamiento","english":"granting"},{"spanish":"la implementación","english":"implementation"},{"spanish":"la dilucidación","english":"clarification"},{"spanish":"el cumplimiento","english":"fulfillment"}]'::jsonb,
    dialogue='[{"speaker":"Informe","spanish":"Se procedió a la implementación de las medidas correctivas.","english":"The implementation of corrective measures was carried out."}]'::jsonb,
    grammar_note='"Se procedió a + noun" = "the [noun] was carried out". Maximally nominalized formal style: instead of "implementaron las medidas", write "se procedió a la implementación".'
  where id = v_l3;

  update public.lessons set
    intro='Hedging and politeness: formal writing softens claims with "convendría", "cabría", "sería oportuno".',
    vocab_items='[{"spanish":"el matiz","english":"nuance"},{"spanish":"matizar","english":"to nuance"},{"spanish":"convendría","english":"it would be advisable"},{"spanish":"sería oportuno","english":"it would be opportune"},{"spanish":"cabría señalar","english":"it would be worth noting"},{"spanish":"a juicio del autor","english":"in the author''s view"},{"spanish":"presuntamente","english":"allegedly"},{"spanish":"hipotéticamente","english":"hypothetically"}]'::jsonb,
    dialogue='[{"speaker":"Informe","spanish":"Convendría reconsiderar el plan de acción a la luz de los nuevos datos.","english":"It would be advisable to reconsider the action plan in light of the new data."}]'::jsonb,
    grammar_note='Conditional for hedging: "convendría", "sería oportuno", "cabría". The conditional creates polite distance from a direct claim.'
  where id = v_l4;

  update public.lessons set
    intro='Quoting and citing: formal writing demands proper attribution. "Según afirma...", "tal como sostiene...".',
    vocab_items='[{"spanish":"la cita","english":"quotation"},{"spanish":"citar","english":"to cite"},{"spanish":"según afirma","english":"as states"},{"spanish":"tal como sostiene","english":"as maintains"},{"spanish":"en palabras de","english":"in the words of"},{"spanish":"a juicio de","english":"in the judgment of"},{"spanish":"la fuente","english":"source"},{"spanish":"reproducir","english":"to reproduce"},{"spanish":"parafrasear","english":"to paraphrase"}]'::jsonb,
    dialogue='[{"speaker":"Ensayo","spanish":"Tal como sostiene el filósofo, "la libertad sin responsabilidad deviene caos".","english":"As the philosopher maintains, ''freedom without responsibility becomes chaos''."}]'::jsonb,
    grammar_note='"Devenir + noun" = "to become + noun" (formal, literary). Less common than "convertirse en" or "volverse" but elegant in academic writing.'
  where id = v_l5;

  update public.lessons set
    intro='Listen to formal correspondence read aloud. The reader''s tone is measured, neutral.',
    vocab_items='[{"spanish":"la correspondencia","english":"correspondence"},{"spanish":"comunicar","english":"to communicate"},{"spanish":"informar","english":"to inform"},{"spanish":"notificar","english":"to notify"},{"spanish":"requerir","english":"to require"},{"spanish":"al respecto","english":"in this regard"}]'::jsonb,
    dialogue='[{"speaker":"Lector","spanish":"Por la presente, nos complace comunicarle que su solicitud ha sido aprobada.","english":"By the present, we are pleased to inform you that your application has been approved."},{"speaker":"Lector","spanish":"Al respecto, le rogamos confirme su asistencia a la mayor brevedad.","english":"In this regard, we kindly ask you to confirm your attendance at your earliest convenience."}]'::jsonb,
    grammar_note='"Le rogamos confirme..." — omitting "que" before subjunctive is a formal/legal register feature: "le rogamos confirme" instead of "le rogamos que confirme".'
  where id = v_l6;

  update public.lessons set
    intro='Write a formal complaint letter. Structure: opening, statement of facts, claim, requested action, closing.',
    vocab_items='[{"spanish":"la queja formal","english":"formal complaint"},{"spanish":"interponer una reclamación","english":"to file a claim"},{"spanish":"a continuación","english":"below/next"},{"spanish":"expone","english":"sets forth (legal)"},{"spanish":"solicita","english":"requests"},{"spanish":"sin perjuicio de","english":"without prejudice to"},{"spanish":"atentamente","english":"sincerely"}]'::jsonb,
    dialogue='[{"speaker":"Carta","spanish":"Don Juan Pérez, con DNI 12345678A, EXPONE: Que el servicio recibido no se ajusta a lo contratado. SOLICITA: La devolución íntegra del importe.","english":"Mr. Juan Pérez, with ID 12345678A, STATES: That the service received does not match what was contracted. REQUESTS: The full refund of the amount."}]'::jsonb,
    grammar_note='Spanish formal complaints use a fixed structure with capitalized verb labels: "EXPONE" (the facts), "SOLICITA" (the request). A bureaucratic convention.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "the undersigned"?','el presente que suscribe',array['el presidente','el subscritor','el suscriptor'],'the undersigned',1),
  (v_l1,'multiple_choice','What is "recipient"?','el destinatario',array['el remitente','el receptor (general)','el regalo'],'recipient',2),
  (v_l1,'fill_blank','Complete: "Por la ____ me dirijo a usted." (present letter)','presente',array['pasada','última','primera'],'present (letter)',3),
  (v_l1,'multiple_choice','What is "to attach"?','adjuntar',array['ajustar','arrojar','aprobar'],'to attach',4),
  (v_l1,'multiple_choice','What does "Estimado/a + name" function as?','formal salutation',array['informal greeting','title','closing'],'formal salutation',5),
  (v_l2,'multiple_choice','What does "no obstante" mean?','however',array['notably','nonetheless (only)','nonetheless (always)'],'however',1),
  (v_l2,'multiple_choice','What does "asimismo" mean?','likewise',array['anyway','already','always'],'likewise',2),
  (v_l2,'fill_blank','Complete: "Por ____, los gastos aumentaron." (consequently)','consiguiente',array['conveniente','contiguo','consecuente'],'consequently',3),
  (v_l2,'multiple_choice','What does "a fin de" mean?','in order to',array['at the end','aside','about'],'in order to',4),
  (v_l2,'multiple_choice','What does "en cuanto a" mean?','as for / regarding',array['as much as','as soon as','as long as'],'as for',5),
  (v_l3,'multiple_choice','What is "implementation"?','la implementación',array['la implication','la impresión','la imposición'],'implementation',1),
  (v_l3,'multiple_choice','What does "se procedió a" mean?','was carried out',array['proceeded with caution','came after','approached'],'was carried out',2),
  (v_l3,'fill_blank','Complete: "Se procedió ____ la implementación." (to)','a',array['de','con','en'],'to',3),
  (v_l3,'multiple_choice','What is "fulfillment"?','el cumplimiento',array['el completamiento','el complemento','el complimiento'],'fulfillment',4),
  (v_l3,'multiple_choice','What is "execution"?','la ejecución',array['la elección','la ejemplificación','la ejercitación'],'execution',5),
  (v_l4,'multiple_choice','What does "convendría" mean?','it would be advisable',array['it would be convenient','it would arrive','it would summon'],'advisable',1),
  (v_l4,'multiple_choice','What does "presuntamente" mean?','allegedly',array['presumably','presciently','presently'],'allegedly',2),
  (v_l4,'fill_blank','Complete: "____ reconsiderar el plan." (it would be advisable)','Convendría',array['Conviene','Convino','Convenir'],'would be advisable',3),
  (v_l4,'multiple_choice','What does "a juicio del autor" mean?','in the author''s view',array['at the author''s judgment (court)','for the author''s opinion','against the author'],'in the author''s view',4),
  (v_l4,'multiple_choice','What is "to nuance"?','matizar',array['matar','mascar','meter'],'to nuance',5),
  (v_l5,'multiple_choice','What does "tal como sostiene" mean?','as maintains',array['so as to support','such as supporting','that is sustaining'],'as maintains',1),
  (v_l5,'multiple_choice','What does "devenir + noun" mean?','to become + noun',array['to devalue','to develop','to deviate'],'to become',2),
  (v_l5,'fill_blank','Complete: "Tal ____ sostiene el filósofo." (as)','como',array['cual','quien','que'],'as',3),
  (v_l5,'multiple_choice','What is "to paraphrase"?','parafrasear',array['parar','parecer','partir'],'to paraphrase',4),
  (v_l5,'multiple_choice','What does "a juicio de" mean?','in the judgment of',array['according to court','for the sake of','at the cost of'],'in the judgment of',5),
  (v_l6,'multiple_choice','What does "le rogamos confirme" use?','subjunctive without "que"',array['indicative with "que"','infinitive','imperative'],'rogar + bare subj',1),
  (v_l6,'multiple_choice','What does "al respecto" mean?','in this regard',array['with respect','at last','beforehand'],'in this regard',2),
  (v_l6,'fill_blank','Complete: "Le rogamos ____ su asistencia." (confirms — bare subj)','confirme',array['confirma','confirmar','confirmará'],'confirm (bare subj)',3),
  (v_l6,'multiple_choice','What does "notificar" mean?','to notify',array['to notice','to nominate','to nourish'],'to notify',4),
  (v_l6,'multiple_choice','What does "nos complace" mean?','we are pleased',array['we please','it pleases','they please'],'we are pleased',5),
  (v_l7,'multiple_choice','What does "EXPONE" mean (legal)?','sets forth',array['exposes','explains','expands'],'sets forth',1),
  (v_l7,'multiple_choice','What does "SOLICITA" mean (legal)?','requests',array['demands','requires','reclaims'],'requests',2),
  (v_l7,'fill_blank','Complete: "____ perjuicio de otras acciones." (without)','Sin',array['Por','En','Con'],'without prejudice',3),
  (v_l7,'multiple_choice','What does "atentamente" mean?','sincerely',array['attentively','currently','attentively (only)'],'sincerely (closing)',4),
  (v_l7,'multiple_choice','What does "el importe" mean?','the amount (money)',array['the import','the importance','the impression'],'the amount',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Estimado Sr. Pérez: por la presente me dirijo a usted para solicitar',array['Saludos cordiales','Atentamente','Querido amigo'],'Dear Mr. Pérez: by the present I address you to request',6),
  (v_l1,'listening','What did you hear?','por la presente me dirijo a usted',array['por correo electrónico','por teléfono','por mensaje'],'by the present (letter) I address you',7),
  (v_l1,'speaking','Say this aloud: "Por la presente me dirijo a usted."','Por la presente me dirijo a usted',array[]::text[],'By the present I address you.',8),
  (v_l1,'speaking','Say this aloud: "Estimado Sr. Pérez."','Estimado Sr. Pérez',array[]::text[],'Dear Mr. Pérez.',9),
  (v_l2,'listening','What did you hear?','Las ventas aumentaron un quince por ciento. No obstante, los gastos también se incrementaron',array['Sin embargo, las ventas crecieron','Por consiguiente, hubo beneficio','En consecuencia, todo va bien'],'Sales increased by 15%. However, expenses also increased',6),
  (v_l2,'listening','What did you hear?','los gastos también se incrementaron',array['los beneficios crecieron','los ingresos bajaron','los costes son estables'],'expenses also increased',7),
  (v_l2,'speaking','Say this aloud: "No obstante, los gastos aumentaron."','No obstante, los gastos aumentaron',array[]::text[],'However, expenses increased.',8),
  (v_l2,'speaking','Say this aloud: "Asimismo, se incrementaron los costes."','Asimismo, se incrementaron los costes',array[]::text[],'Likewise, costs increased.',9),
  (v_l3,'listening','What did you hear?','Se procedió a la implementación de las medidas correctivas',array['Las medidas se implementaron','Se aprobaron las medidas','Se decidió actuar'],'The implementation of corrective measures was carried out',6),
  (v_l3,'listening','What did you hear?','de las medidas correctivas',array['de las medidas preventivas','de las medidas alternativas','de las medidas iniciales'],'of corrective measures',7),
  (v_l3,'speaking','Say this aloud: "Se procedió a la implementación."','Se procedió a la implementación',array[]::text[],'The implementation was carried out.',8),
  (v_l3,'speaking','Say this aloud: "Las medidas correctivas son necesarias."','Las medidas correctivas son necesarias',array[]::text[],'Corrective measures are necessary.',9),
  (v_l6,'listening','What did you hear?','Por la presente, nos complace comunicarle que su solicitud ha sido aprobada',array['Al respecto, le rogamos','A la mayor brevedad','Atentamente'],'By the present, we are pleased to inform you that your application has been approved',6),
  (v_l6,'listening','What did you hear?','le rogamos confirme su asistencia a la mayor brevedad',array['nos complace comunicarle','su solicitud ha sido','a su disposición'],'we kindly ask you to confirm your attendance at your earliest convenience',7),
  (v_l6,'speaking','Say this aloud: "Le rogamos confirme su asistencia."','Le rogamos confirme su asistencia',array[]::text[],'We kindly ask you to confirm your attendance.',8),
  (v_l6,'speaking','Say this aloud: "Nos complace comunicarle."','Nos complace comunicarle',array[]::text[],'We are pleased to inform you.',9),
  (v_l7,'listening','What did you hear?','Don Juan Pérez, con DNI 12345678A, EXPONE',array['Que el servicio recibido','No se ajusta a lo contratado','SOLICITA la devolución'],'Mr. Juan Pérez, with ID 12345678A, STATES',6),
  (v_l7,'listening','What did you hear?','SOLICITA: La devolución íntegra del importe',array['EXPONE los hechos','Acredita la situación','Atentamente'],'REQUESTS: The full refund of the amount',7),
  (v_l7,'speaking','Say this aloud: "Solicita la devolución íntegra del importe."','Solicita la devolución íntegra del importe',array[]::text[],'He requests the full refund of the amount.',8),
  (v_l7,'speaking','Say this aloud: "Sin perjuicio de otras acciones legales."','Sin perjuicio de otras acciones legales',array[]::text[],'Without prejudice to other legal actions.',9);

  update public.lessons set type='conversation', title='Formal Writing — Conversation Practice',
    description='Two colleagues review a formal letter.',
    intro='Ana and Roberto draft a complaint together.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Ana","spanish":"¿Has terminado el borrador de la reclamación?","english":"Have you finished the draft of the complaint?"},{"speaker":"Roberto","spanish":"Sí. Empieza con "Estimado Sr. Director: por la presente...".","english":"Yes. It starts with ''Dear Mr. Director: by the present...''."},{"speaker":"Ana","spanish":"Bien. No obstante, convendría matizar el tono.","english":"Good. However, it would be advisable to nuance the tone."},{"speaker":"Roberto","spanish":"De acuerdo. Cambiaré "exigimos" por "solicitamos".","english":"Agreed. I''ll change ''we demand'' to ''we request''."},{"speaker":"Ana","spanish":"Asimismo, le rogamos al final que confirme la recepción.","english":"Likewise, kindly ask him at the end to confirm receipt."},{"speaker":"Roberto","spanish":"Tal como sugieres. Cerraré con "Atentamente, el presente que suscribe".","english":"As you suggest. I''ll close with ''Sincerely, the undersigned''."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','How does the letter open?','Dear Mr. Director: by the present...',array['Hi there','To whom it may concern','Hey, listen up'],'Estimado Sr. Director: por la presente',1),
  (v_l8,'multiple_choice','Ana''s suggestion?','To nuance the tone',array['To shorten it','To translate it','To delete it'],'matizar el tono',2),
  (v_l8,'multiple_choice','What change does Roberto make?','"exigimos" → "solicitamos"',array['"escribimos" → "decimos"','"queremos" → "necesitamos"','"vemos" → "miramos"'],'exigimos → solicitamos',3),
  (v_l8,'multiple_choice','What''s the closing request?','Confirm receipt',array['Send a check','Visit the office','Call back'],'confirme la recepción',4),
  (v_l8,'fill_blank','Complete: "____ rogamos confirme la recepción." (we)','Le',array['Lo','La','Les'],'we kindly ask him (le)',5),
  (v_l8,'multiple_choice','Closing line?','Sincerely, the undersigned',array['Best wishes','Cheers','See you'],'Atentamente, el presente que suscribe',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Formal Writing', 'Review test for the Formal Writing section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "the undersigned"?','el presente que suscribe',array['el presidente','el subscritor','el suscriptor'],'the undersigned',1),
  (v_lesson_id,'multiple_choice','What does "no obstante" mean?','however',array['notably','always','already'],'however',2),
  (v_lesson_id,'multiple_choice','What is "implementation"?','la implementación',array['la implication','la impresión','la imposición'],'implementation',3),
  (v_lesson_id,'multiple_choice','What does "convendría" mean?','it would be advisable',array['it would be convenient','it would arrive','it would summon'],'advisable',4),
  (v_lesson_id,'fill_blank','Complete: "Le rogamos ____ su asistencia." (confirm — bare subj)','confirme',array['confirma','confirmar','confirmará'],'confirm (bare subj)',5),
  (v_lesson_id,'fill_blank','Complete: "____ perjuicio de otras acciones." (without)','Sin',array['Por','En','Con'],'without prejudice',6),
  (v_lesson_id,'listening','What did you hear?','Se procedió a la implementación de las medidas correctivas',array['Estimado Sr. Pérez','Por la presente','Le rogamos confirme'],'The implementation of corrective measures was carried out',7),
  (v_lesson_id,'listening','What did you hear?','nos complace comunicarle que su solicitud ha sido aprobada',array['Su solicitud está pendiente','Su asistencia es obligatoria','Por la presente le notificamos'],'we are pleased to inform you that your application has been approved',8),
  (v_lesson_id,'speaking','Say this aloud: "Por la presente me dirijo a usted."','Por la presente me dirijo a usted',array[]::text[],'By the present I address you.',9),
  (v_lesson_id,'speaking','Say this aloud: "Atentamente, el presente que suscribe."','Atentamente, el presente que suscribe',array[]::text[],'Sincerely, the undersigned.',10);

  -- ===========================================================
  -- C1.4 DEBATE & DISCUSSION
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'C1' and title = 'Debate & Discussion';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='Stating opinions with authority: "desde mi punto de vista", "a mi modo de ver", "en mi opinión". Each carries a slightly different tone.',
    vocab_items='[{"spanish":"el debate","english":"debate"},{"spanish":"la discusión","english":"discussion"},{"spanish":"el argumento","english":"argument"},{"spanish":"argumentar","english":"to argue"},{"spanish":"sostener","english":"to maintain"},{"spanish":"desde mi punto de vista","english":"from my point of view"},{"spanish":"a mi modo de ver","english":"to my way of seeing"},{"spanish":"en mi opinión","english":"in my opinion"},{"spanish":"opinar","english":"to opine"},{"spanish":"manifestar","english":"to state"}]'::jsonb,
    dialogue='[{"speaker":"Debatiente A","spanish":"A mi modo de ver, la regulación es la única vía.","english":"To my way of seeing, regulation is the only path."},{"speaker":"Debatiente B","spanish":"Permíteme discrepar.","english":"Allow me to disagree."}]'::jsonb,
    grammar_note='"Permíteme + infinitive" = "allow me to + verb". Polite formality in debate. Combined with the imperative tú of "permitir", it sets a measured tone.'
  where id = v_l1;

  update public.lessons set
    intro='Disagreeing politely: "discrepo en lo siguiente", "no comparto del todo", "matizaría que...".',
    vocab_items='[{"spanish":"discrepar","english":"to disagree"},{"spanish":"no comparto","english":"I don''t share"},{"spanish":"matizar","english":"to nuance"},{"spanish":"rebatir","english":"to refute"},{"spanish":"objetar","english":"to object"},{"spanish":"poner en duda","english":"to question"},{"spanish":"cuestionar","english":"to question"},{"spanish":"contradecir","english":"to contradict"}]'::jsonb,
    dialogue='[{"speaker":"Crítica","spanish":"No comparto del todo esa premisa: convendría matizar el punto sobre los costes.","english":"I don''t entirely share that premise: it would be advisable to nuance the point about costs."}]'::jsonb,
    grammar_note='"No comparto del todo" = "I don''t entirely share". Softens disagreement. "Del todo" with negation means "entirely/completely".'
  where id = v_l2;

  update public.lessons set
    intro='Conceding and counterattacking: "es cierto que... no obstante", "puede que tengas razón, pero...".',
    vocab_items='[{"spanish":"conceder","english":"to concede"},{"spanish":"reconocer","english":"to acknowledge"},{"spanish":"es cierto que","english":"it is true that"},{"spanish":"puede que","english":"it may be that"},{"spanish":"si bien","english":"although"},{"spanish":"aun así","english":"even so"},{"spanish":"a pesar de ello","english":"despite this"},{"spanish":"sin embargo","english":"however"}]'::jsonb,
    dialogue='[{"speaker":"Debatiente","spanish":"Si bien es cierto que el coste es elevado, no por ello deja de ser necesario.","english":"Although it is true that the cost is high, that does not make it any less necessary."}]'::jsonb,
    grammar_note='"No por ello + verb" = "that doesn''t mean + verb". Compact concessive structure: "no por ello deja de ser necesario" = "it''s still necessary nonetheless".'
  where id = v_l3;

  update public.lessons set
    intro='Strong arguments: "es indiscutible que", "queda demostrado que", "no cabe duda de que".',
    vocab_items='[{"spanish":"indiscutible","english":"indisputable"},{"spanish":"queda demostrado","english":"it is demonstrated"},{"spanish":"no cabe duda","english":"there is no doubt"},{"spanish":"evidente","english":"evident"},{"spanish":"contundente","english":"forceful"},{"spanish":"irrebatible","english":"irrefutable"},{"spanish":"reforzar","english":"to reinforce"},{"spanish":"el argumento de peso","english":"weighty argument"}]'::jsonb,
    dialogue='[{"speaker":"Orador","spanish":"No cabe duda de que sin inversión no habrá innovación.","english":"There is no doubt that without investment there will be no innovation."}]'::jsonb,
    grammar_note='"No cabe duda de que + indicative" = "there is no doubt that...". Note the "de que" — a common error is to drop the "de" ("dequeísmo"/"queísmo").'
  where id = v_l4;

  update public.lessons set
    intro='Asking for clarification: "¿podrías concretar?", "¿qué quieres decir exactamente?", "¿podrías ilustrarlo con un ejemplo?".',
    vocab_items='[{"spanish":"concretar","english":"to specify"},{"spanish":"aclarar","english":"to clarify"},{"spanish":"ilustrar","english":"to illustrate"},{"spanish":"profundizar","english":"to deepen"},{"spanish":"el ejemplo concreto","english":"specific example"},{"spanish":"la matización","english":"qualification"},{"spanish":"el contexto","english":"context"},{"spanish":"la implicación","english":"implication"}]'::jsonb,
    dialogue='[{"speaker":"Moderadora","spanish":"¿Podría usted concretar a qué se refiere con "modelo alternativo"?","english":"Could you specify what you mean by ''alternative model''?"}]'::jsonb,
    grammar_note='"A qué se refiere con + noun" = "what they mean by + noun". Indirect question + "se refiere con" structure for asking about reference/meaning.'
  where id = v_l5;

  update public.lessons set
    intro='Listen to a TV debate. The exchanges are fast, with overlaps and interruptions. Pick out the main arguments.',
    vocab_items='[{"spanish":"el debate televisivo","english":"TV debate"},{"spanish":"el moderador","english":"moderator"},{"spanish":"interrumpir","english":"to interrupt"},{"spanish":"intervenir","english":"to intervene"},{"spanish":"el turno","english":"turn"},{"spanish":"la réplica","english":"reply"},{"spanish":"la contrarréplica","english":"counter-reply"}]'::jsonb,
    dialogue='[{"speaker":"Moderadora","spanish":"Por favor, respeten el turno. Don Carlos, su réplica.","english":"Please respect the turn. Mr. Carlos, your reply."},{"speaker":"Carlos","spanish":"Gracias. Tal como decía mi oponente, conviene matizar dos puntos.","english":"Thank you. As my opponent was saying, it''s appropriate to nuance two points."}]'::jsonb,
    grammar_note='"Tal como decía + subject" = "as + subject was saying". The imperfect captures the ongoing/recent nature of the prior speaker''s argument.'
  where id = v_l6;

  update public.lessons set
    intro='Write a position paper: state thesis, present arguments, anticipate counter-arguments, refute, conclude.',
    vocab_items='[{"spanish":"la tesis","english":"thesis"},{"spanish":"la postura","english":"position"},{"spanish":"el contraargumento","english":"counter-argument"},{"spanish":"prever","english":"to anticipate"},{"spanish":"refutar","english":"to refute"},{"spanish":"concluir","english":"to conclude"},{"spanish":"en suma","english":"in sum"},{"spanish":"para finalizar","english":"to conclude"}]'::jsonb,
    dialogue='[{"speaker":"Ensayo","spanish":"Mi tesis sostiene que la educación es la mejor inversión social. Podrían objetar que es lenta, pero los datos avalan su eficacia.","english":"My thesis maintains that education is the best social investment. One could object that it''s slow, but the data backs its effectiveness."}]'::jsonb,
    grammar_note='"Podrían objetar que" = "one could object that". Anticipating counter-arguments with conditional preempts opposition. Standard rhetorical move.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What does "a mi modo de ver" mean?','to my way of seeing',array['to my mode','at my fashion','to my mood'],'to my way of seeing',1),
  (v_l1,'multiple_choice','What is "argument"?','el argumento',array['el algoritmo','el augurio','el agumento'],'argument',2),
  (v_l1,'fill_blank','Complete: "Permíteme ____" (disagree)','discrepar',array['discrepando','discrepado','discrepo'],'to disagree (inf)',3),
  (v_l1,'multiple_choice','What does "sostener" mean (debate)?','to maintain (a position)',array['to sustain (physical)','to support (object)','to hold (object)'],'to maintain',4),
  (v_l1,'multiple_choice','What does "manifestar" mean?','to state',array['to manifest (physical)','to manage','to manhandle'],'to state',5),
  (v_l2,'multiple_choice','What does "no comparto del todo" mean?','I don''t entirely share',array['I never share','I don''t share at all','I share part'],'don''t entirely share',1),
  (v_l2,'multiple_choice','What does "rebatir" mean?','to refute',array['to rebate','to rebel','to rebuild'],'to refute',2),
  (v_l2,'fill_blank','Complete: "Convendría ____ el punto." (nuance — inf)','matizar',array['matizando','matizado','matizo'],'to nuance',3),
  (v_l2,'multiple_choice','What does "objetar" mean?','to object',array['to obey','to obtain','to omit'],'to object',4),
  (v_l2,'multiple_choice','What does "cuestionar" mean?','to question (challenge)',array['to ask a question','to interrogate (police)','to inquire'],'to question',5),
  (v_l3,'multiple_choice','What does "si bien" mean?','although',array['if well','if good','well if'],'although',1),
  (v_l3,'multiple_choice','What does "aun así" mean?','even so',array['even if','as long as','since'],'even so',2),
  (v_l3,'fill_blank','Complete: "No por ello ____ de ser necesario." (it stops)','deja',array['dejaba','dejaría','deje'],'stops',3),
  (v_l3,'multiple_choice','What does "puede que" mean?','it may be that',array['may you','perhaps yes','probably not'],'it may be that',4),
  (v_l3,'multiple_choice','What does "a pesar de ello" mean?','despite this',array['for that reason','because of it','due to this'],'despite this',5),
  (v_l4,'multiple_choice','What does "indiscutible" mean?','indisputable',array['indirect','indistinct','indecent'],'indisputable',1),
  (v_l4,'multiple_choice','What does "no cabe duda" mean?','there is no doubt',array['it doesn''t fit','it doesn''t fall','it doesn''t lead'],'no doubt',2),
  (v_l4,'fill_blank','Complete: "No cabe duda ____ esto es vital." (that)','de que',array['que','del que','en que'],'de que (no dequeísmo)',3),
  (v_l4,'multiple_choice','What does "contundente" mean?','forceful',array['continued','contingent','contagious'],'forceful',4),
  (v_l4,'multiple_choice','What does "irrebatible" mean?','irrefutable',array['irregular','irrelevant','irreverent'],'irrefutable',5),
  (v_l5,'multiple_choice','What does "concretar" mean?','to specify',array['to construct','to congregate','to contract'],'to specify',1),
  (v_l5,'multiple_choice','What does "profundizar" mean?','to deepen',array['to professionalize','to profile','to project'],'to deepen',2),
  (v_l5,'fill_blank','Complete: "¿A qué se ____ con eso?" (refer)','refiere',array['refiero','referimos','refería'],'refers',3),
  (v_l5,'multiple_choice','What does "ilustrar" mean here?','to illustrate (with example)',array['to illuminate','to insult','to install'],'to illustrate',4),
  (v_l5,'multiple_choice','What does "la implicación" mean?','implication',array['implication (only legal)','implementation','impression'],'implication',5),
  (v_l6,'multiple_choice','What is "TV debate"?','el debate televisivo',array['el debate de TV','el televisado debate','el debate famoso'],'TV debate',1),
  (v_l6,'multiple_choice','What is "reply" (in debate)?','la réplica',array['la copia','la duplicación','la repetición'],'reply',2),
  (v_l6,'fill_blank','Complete: "Tal como ____ mi oponente." (was saying)','decía',array['dijo','dice','dirá'],'was saying',3),
  (v_l6,'multiple_choice','What does "interrumpir" mean?','to interrupt',array['to interpret','to interview','to introduce'],'to interrupt',4),
  (v_l6,'multiple_choice','What is "turn" (speaking)?','el turno',array['el truco','el túnel','el turbio'],'turn',5),
  (v_l7,'multiple_choice','What does "podrían objetar que" mean?','one could object that',array['they would object that','they must object','they did object'],'one could object',1),
  (v_l7,'multiple_choice','What does "avalar" mean?','to back/endorse',array['to avoid','to abandon','to advance'],'to endorse',2),
  (v_l7,'fill_blank','Complete: "Para ____, concluyo que." (finalize)','finalizar',array['final','finales','finalmente'],'to conclude (inf)',3),
  (v_l7,'multiple_choice','What is "thesis"?','la tesis',array['la postura','el tema','el título'],'thesis',4),
  (v_l7,'multiple_choice','What is "counter-argument"?','el contraargumento',array['el contraataque','el contraste','el contradicho'],'counter-argument',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','A mi modo de ver, la regulación es la única vía',array['Permíteme discrepar','En mi opinión, el debate sigue','Desde mi punto de vista'],'To my way of seeing, regulation is the only path',6),
  (v_l1,'listening','What did you hear?','Permíteme discrepar',array['Permíteme discrepar (synonym)','Estoy de acuerdo','Tienes razón'],'Allow me to disagree',7),
  (v_l1,'speaking','Say this aloud: "A mi modo de ver, la regulación es la única vía."','A mi modo de ver, la regulación es la única vía',array[]::text[],'To my way of seeing, regulation is the only path.',8),
  (v_l1,'speaking','Say this aloud: "Permíteme discrepar."','Permíteme discrepar',array[]::text[],'Allow me to disagree.',9),
  (v_l2,'listening','What did you hear?','No comparto del todo esa premisa',array['Convendría matizar el punto','Estoy de acuerdo','La premisa es válida'],'I don''t entirely share that premise',6),
  (v_l2,'listening','What did you hear?','convendría matizar el punto sobre los costes',array['convendría rechazar la propuesta','convendría aceptar el plan','convendría debatir más'],'it would be advisable to nuance the point about costs',7),
  (v_l2,'speaking','Say this aloud: "No comparto del todo esa premisa."','No comparto del todo esa premisa',array[]::text[],'I don''t entirely share that premise.',8),
  (v_l2,'speaking','Say this aloud: "Convendría matizar el punto."','Convendría matizar el punto',array[]::text[],'It would be advisable to nuance the point.',9),
  (v_l3,'listening','What did you hear?','Si bien es cierto que el coste es elevado',array['no por ello deja de ser necesario','el coste es exagerado','el coste es razonable'],'Although it is true that the cost is high',6),
  (v_l3,'listening','What did you hear?','no por ello deja de ser necesario',array['si bien es cierto','el coste es elevado','aun así, es viable'],'that does not make it any less necessary',7),
  (v_l3,'speaking','Say this aloud: "Si bien es cierto, no por ello es menos necesario."','Si bien es cierto, no por ello es menos necesario',array[]::text[],'Although it''s true, it''s no less necessary.',8),
  (v_l3,'speaking','Say this aloud: "Aun así, sigo creyendo en la idea."','Aun así, sigo creyendo en la idea',array[]::text[],'Even so, I still believe in the idea.',9),
  (v_l6,'listening','What did you hear?','Por favor, respeten el turno. Don Carlos, su réplica',array['Tal como decía mi oponente','Conviene matizar dos puntos','Gracias por la palabra'],'Please respect the turn. Mr. Carlos, your reply',6),
  (v_l6,'listening','What did you hear?','Tal como decía mi oponente, conviene matizar dos puntos',array['Respeten el turno','La réplica está cerrada','El debate continúa'],'As my opponent was saying, it''s appropriate to nuance two points',7),
  (v_l6,'speaking','Say this aloud: "Tal como decía mi oponente."','Tal como decía mi oponente',array[]::text[],'As my opponent was saying.',8),
  (v_l6,'speaking','Say this aloud: "Por favor, respeten el turno."','Por favor, respeten el turno',array[]::text[],'Please respect the turn.',9),
  (v_l7,'listening','What did you hear?','Mi tesis sostiene que la educación es la mejor inversión social',array['Podrían objetar que es lenta','Los datos avalan su eficacia','En suma, debemos invertir'],'My thesis maintains that education is the best social investment',6),
  (v_l7,'listening','What did you hear?','los datos avalan su eficacia',array['los datos cuestionan su eficacia','los datos contradicen mi tesis','los datos faltan'],'the data backs its effectiveness',7),
  (v_l7,'speaking','Say this aloud: "Mi tesis sostiene que la educación es la mejor inversión."','Mi tesis sostiene que la educación es la mejor inversión',array[]::text[],'My thesis maintains that education is the best investment.',8),
  (v_l7,'speaking','Say this aloud: "Los datos avalan mi conclusión."','Los datos avalan mi conclusión',array[]::text[],'The data backs my conclusion.',9);

  update public.lessons set type='conversation', title='Debate & Discussion — Conversation Practice',
    description='Two debaters spar over policy.',
    intro='Elena and Pablo on opposite sides of a debate.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Elena","spanish":"A mi modo de ver, la regulación del mercado es indispensable.","english":"To my way of seeing, market regulation is indispensable."},{"speaker":"Pablo","spanish":"Permíteme discrepar. La regulación excesiva ahoga la innovación.","english":"Allow me to disagree. Excessive regulation stifles innovation."},{"speaker":"Elena","spanish":"Si bien es cierto que hay riesgos, no por ello debemos dejar al mercado solo.","english":"Although it''s true there are risks, that doesn''t mean we should leave the market alone."},{"speaker":"Pablo","spanish":"No cabe duda de que la libre competencia genera más valor a largo plazo.","english":"There is no doubt that free competition generates more value long-term."},{"speaker":"Elena","spanish":"Podrían objetar que la libre competencia produce monopolios.","english":"One could object that free competition produces monopolies."},{"speaker":"Pablo","spanish":"En suma, convendría buscar un equilibrio, no un extremo.","english":"In sum, it would be advisable to seek balance, not an extreme."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','Elena''s thesis?','Market regulation is indispensable',array['Markets are bad','Regulation always works','Both extremes are good'],'la regulación del mercado',1),
  (v_l8,'multiple_choice','Pablo''s response?','Excessive regulation stifles innovation',array['Regulation is good','Innovation needs regulation','Markets need control'],'la regulación excesiva ahoga la innovación',2),
  (v_l8,'multiple_choice','Elena''s concession + counterattack?','Risks exist but markets need oversight',array['Risks justify deregulation','Markets are perfect','Regulation kills business'],'no por ello debemos dejar al mercado solo',3),
  (v_l8,'multiple_choice','Pablo''s strongest argument?','Free competition generates value long-term',array['Regulation always fails','Markets are fair','Innovation requires chaos'],'libre competencia genera valor',4),
  (v_l8,'fill_blank','Complete: "Podrían ____ que produce monopolios." (object — cond)','objetar',array['objetan','objeté','objetando'],'object (cond)',5),
  (v_l8,'multiple_choice','Pablo''s final position?','Seek balance, not an extreme',array['Pure free market','Pure regulation','No oversight at all'],'buscar un equilibrio',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Debate & Discussion', 'Review test for the Debate & Discussion section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What does "a mi modo de ver" mean?','to my way of seeing',array['to my mode','at my fashion','to my mood'],'to my way of seeing',1),
  (v_lesson_id,'multiple_choice','What does "no comparto del todo" mean?','I don''t entirely share',array['I never share','I don''t share at all','I share part'],'don''t entirely share',2),
  (v_lesson_id,'multiple_choice','What does "no cabe duda" mean?','there is no doubt',array['it doesn''t fit','it doesn''t fall','it doesn''t lead'],'no doubt',3),
  (v_lesson_id,'multiple_choice','What does "si bien" mean?','although',array['if well','if good','well if'],'although',4),
  (v_lesson_id,'fill_blank','Complete: "No cabe duda ____ esto es vital." (that)','de que',array['que','del que','en que'],'de que',5),
  (v_lesson_id,'fill_blank','Complete: "Podrían ____ que es lenta." (object — cond)','objetar',array['objetan','objeté','objetando'],'object',6),
  (v_lesson_id,'listening','What did you hear?','A mi modo de ver, la regulación es la única vía',array['Permíteme discrepar','No comparto del todo','Convendría matizar'],'To my way of seeing, regulation is the only path',7),
  (v_lesson_id,'listening','What did you hear?','los datos avalan su eficacia',array['Si bien es cierto','No cabe duda','Por favor, respeten el turno'],'the data backs its effectiveness',8),
  (v_lesson_id,'speaking','Say this aloud: "Permíteme discrepar."','Permíteme discrepar',array[]::text[],'Allow me to disagree.',9),
  (v_lesson_id,'speaking','Say this aloud: "No cabe duda de que es vital."','No cabe duda de que es vital',array[]::text[],'There''s no doubt it''s vital.',10);

  -- ===========================================================
  -- C1.5 NATIVE CONTENT
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'C1' and title = 'Native Content';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='Spanish-language film: Almodóvar, del Toro, Cuarón. Each director has distinctive vocabulary and themes.',
    vocab_items='[{"spanish":"el cineasta","english":"filmmaker"},{"spanish":"la película","english":"film"},{"spanish":"el director","english":"director"},{"spanish":"el guion","english":"script"},{"spanish":"el reparto","english":"cast"},{"spanish":"el protagonista","english":"protagonist"},{"spanish":"la cinematografía","english":"cinematography"},{"spanish":"el largometraje","english":"feature-length film"},{"spanish":"el cortometraje","english":"short film"},{"spanish":"taquillazo","english":"box-office hit"}]'::jsonb,
    dialogue='[{"speaker":"Crítica","spanish":"Almodóvar, cuyo estilo se reconoce a la primera, vuelve con un melodrama exquisito.","english":"Almodóvar, whose style is recognized at first glance, returns with an exquisite melodrama."}]'::jsonb,
    grammar_note='"A la primera" = "at first glance/first try". "A la X" with ordinal numbers: "a la segunda" (on the second try), "a la mínima" (at the slightest provocation).'
  where id = v_l1;

  update public.lessons set
    intro='Spanish TV series have gone global: "La Casa de Papel", "Élite", "Vis a Vis". Master the streaming vocabulary.',
    vocab_items='[{"spanish":"la serie","english":"series"},{"spanish":"la temporada","english":"season"},{"spanish":"el episodio","english":"episode"},{"spanish":"el capítulo","english":"chapter (episode)"},{"spanish":"la trama","english":"plot"},{"spanish":"el desenlace","english":"resolution/ending"},{"spanish":"el giro argumental","english":"plot twist"},{"spanish":"engancharse","english":"to get hooked"},{"spanish":"el atracón","english":"binge"},{"spanish":"el spoiler","english":"spoiler"}]'::jsonb,
    dialogue='[{"speaker":"Fan","spanish":"Me enganché tanto que vi toda la temporada del tirón.","english":"I got so hooked I watched the whole season in one go."}]'::jsonb,
    grammar_note='"Del tirón" = "in one go/in one shot". A colloquial expression. Similar: "de un tirón", "de una".'
  where id = v_l2;

  update public.lessons set
    intro='Music: Spanish pop, flamenco, reguetón. Each genre has its own slang and aesthetic.',
    vocab_items='[{"spanish":"el cantante","english":"singer"},{"spanish":"el grupo","english":"band"},{"spanish":"el álbum","english":"album"},{"spanish":"el sencillo","english":"single"},{"spanish":"la letra","english":"lyrics"},{"spanish":"el reguetón","english":"reggaeton"},{"spanish":"el pop","english":"pop"},{"spanish":"el flamenco","english":"flamenco"},{"spanish":"el éxito","english":"hit"},{"spanish":"sonar","english":"to play (music)"}]'::jsonb,
    dialogue='[{"speaker":"DJ","spanish":"Esta canción está sonando en todas las emisoras.","english":"This song is playing on every station."}]'::jsonb,
    grammar_note='"Estar + gerund" present progressive: "está sonando" emphasizes the ongoing widespread phenomenon. Simple present "suena" would be neutral.'
  where id = v_l3;

  update public.lessons set
    intro='Spanish-language podcasts cover everything from politics to true crime. Podcast vocabulary.',
    vocab_items='[{"spanish":"el podcast","english":"podcast"},{"spanish":"el oyente","english":"listener"},{"spanish":"el episodio","english":"episode"},{"spanish":"la suscripción","english":"subscription"},{"spanish":"la descarga","english":"download"},{"spanish":"el invitado","english":"guest"},{"spanish":"la entrevista","english":"interview"},{"spanish":"el monólogo","english":"monologue"},{"spanish":"el debate","english":"debate"},{"spanish":"recomendar","english":"to recommend"}]'::jsonb,
    dialogue='[{"speaker":"Presentadora","spanish":"Hoy contamos con un invitado de excepción.","english":"Today we have an exceptional guest."}]'::jsonb,
    grammar_note='"Contar con + noun/person" = "to have + noun/person" (in a positive sense): "contamos con tu apoyo" = "we have your support". Used to express having something valuable.'
  where id = v_l4;

  update public.lessons set
    intro='Social media in Spanish: el tuit, el reel, el directo. Native speakers blend English borrowings with Spanish.',
    vocab_items='[{"spanish":"el tuit","english":"tweet"},{"spanish":"el directo","english":"livestream"},{"spanish":"el reel","english":"reel"},{"spanish":"viralizar","english":"to make viral"},{"spanish":"el meme","english":"meme"},{"spanish":"el hashtag","english":"hashtag"},{"spanish":"el seguidor","english":"follower"},{"spanish":"compartir","english":"to share"},{"spanish":"comentar","english":"to comment"},{"spanish":"silenciar","english":"to mute"}]'::jsonb,
    dialogue='[{"speaker":"Influencer","spanish":"Voy a hacer un directo esta tarde para los que se hayan apuntado.","english":"I''m going to do a livestream this afternoon for those who have signed up."}]'::jsonb,
    grammar_note='"Para los que + present subjunctive" = "for those who...": "para los que se hayan apuntado". Subjunctive because the set of people is not yet defined.'
  where id = v_l5;

  update public.lessons set
    intro='Listen to a native Spanish podcast snippet. Speakers talk fast, with regional accent.',
    vocab_items='[{"spanish":"el ritmo","english":"pace"},{"spanish":"el acento","english":"accent"},{"spanish":"la entonación","english":"intonation"},{"spanish":"hablar rápido","english":"to speak fast"},{"spanish":"farfullar","english":"to mumble"},{"spanish":"vocalizar","english":"to enunciate"},{"spanish":"el coloquialismo","english":"colloquialism"}]'::jsonb,
    dialogue='[{"speaker":"Locutor","spanish":"Hostia, qué pasada lo del partido, ¿no? Vamos, que ni en Hollywood se habría imaginado.","english":"Whoa, what a thing about the match, right? I mean, not even Hollywood could have imagined it."}]'::jsonb,
    grammar_note='"Hostia" (vulgar interjection) and "qué pasada" (what a thing/wow) are common colloquialisms. "Vamos, que..." = "I mean..." for clarification.'
  where id = v_l6;

  update public.lessons set
    intro='Write a review of a Spanish-language film/series. Use evaluative vocabulary natively.',
    vocab_items='[{"spanish":"la reseña","english":"review"},{"spanish":"valorar","english":"to evaluate"},{"spanish":"recomendar","english":"to recommend"},{"spanish":"desaconsejar","english":"to advise against"},{"spanish":"original","english":"original"},{"spanish":"predecible","english":"predictable"},{"spanish":"emotivo","english":"emotional"},{"spanish":"hilarante","english":"hilarious"},{"spanish":"conmovedor","english":"moving"}]'::jsonb,
    dialogue='[{"speaker":"Reseña","spanish":"Una película conmovedora cuyo guion, aunque previsible, brilla por las interpretaciones.","english":"A moving film whose script, although predictable, shines thanks to the performances."}]'::jsonb,
    grammar_note='"Brillar por + noun" = "to shine for/thanks to + noun" — but also ironically, "brilla por su ausencia" = "is conspicuous by its absence".'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "filmmaker"?','el cineasta',array['el cinético','el actor','el director (only)'],'filmmaker',1),
  (v_l1,'multiple_choice','What does "a la primera" mean?','at first glance / first try',array['firstly','before all','at one'],'at first glance',2),
  (v_l1,'fill_blank','Complete: "Almodóvar, ____ estilo se reconoce." (whose - masc)','cuyo',array['cuya','cuyos','cuyas'],'whose (masc)',3),
  (v_l1,'multiple_choice','What is "feature-length film"?','el largometraje',array['el cortometraje','el largometro','el filme'],'feature film',4),
  (v_l1,'multiple_choice','What is "box-office hit"?','el taquillazo',array['el taquilla','el ticket','el éxito'],'box-office hit',5),
  (v_l2,'multiple_choice','What is "plot twist"?','el giro argumental',array['el giro de plot','la trama vuelta','el cambio de plot'],'plot twist',1),
  (v_l2,'multiple_choice','What does "engancharse" mean?','to get hooked',array['to grab','to hang','to engage'],'get hooked',2),
  (v_l2,'fill_blank','Complete: "La vi toda ____ tirón." (in one go)','del',array['de','en','con'],'in one go',3),
  (v_l2,'multiple_choice','What is "binge"?','el atracón',array['el ataque','el atajo','el atraco'],'binge',4),
  (v_l2,'multiple_choice','What does "el desenlace" mean?','resolution/ending',array['enlace','knot','knot (only)'],'resolution',5),
  (v_l3,'multiple_choice','What is "single" (music)?','el sencillo',array['el simple','el unico','el sentido'],'single',1),
  (v_l3,'multiple_choice','What does "sonar" mean here?','to play (music)',array['to sound (like)','to dream (sueñar)','to ring (phone only)'],'to play',2),
  (v_l3,'fill_blank','Complete: "Esta canción está ____" (playing)','sonando',array['sonado','sonar','sueno'],'playing (gerund)',3),
  (v_l3,'multiple_choice','What does "el éxito" mean here?','a hit (song)',array['success (only)','exit','exitement'],'hit',4),
  (v_l3,'multiple_choice','What is "lyrics"?','la letra',array['la lírica','la línea','la lengua'],'lyrics',5),
  (v_l4,'multiple_choice','What does "contar con" mean?','to have (s.t. valuable)',array['to count (numbers)','to tell (story)','to count with hands'],'to have',1),
  (v_l4,'multiple_choice','What is "listener"?','el oyente',array['el oidor','el ojos','el oído'],'listener',2),
  (v_l4,'fill_blank','Complete: "Contamos ____ tu apoyo." (with)','con',array['en','de','por'],'with',3),
  (v_l4,'multiple_choice','What is "interview"?','la entrevista',array['la entrada','la entrega','la enviada'],'interview',4),
  (v_l4,'multiple_choice','What does "de excepción" mean?','exceptional',array['except','excepted','exceptional (only)'],'exceptional',5),
  (v_l5,'multiple_choice','What is "livestream"?','el directo',array['el live','el directo (incorrect)','el corriente'],'livestream',1),
  (v_l5,'multiple_choice','What does "viralizar" mean?','to make viral',array['to viralize (incorrect)','to vary','to vacate'],'make viral',2),
  (v_l5,'fill_blank','Complete: "Para los que se ____ apuntado." (have — subj)','hayan',array['han','habrán','habían'],'have (subj)',3),
  (v_l5,'multiple_choice','What is "to mute"?','silenciar',array['silenciarse','silenciar (incorrect)','silencio'],'to mute',4),
  (v_l5,'multiple_choice','What does "apuntarse" mean?','to sign up',array['to point','to write down','to aim'],'sign up',5),
  (v_l6,'multiple_choice','What does "qué pasada" mean?','what a thing / wow',array['what happened','what passes','what passed'],'wow',1),
  (v_l6,'multiple_choice','What does "vamos, que" mean?','I mean...',array['let''s go that','we go because','we leave that'],'I mean',2),
  (v_l6,'fill_blank','Complete: "Ni en Hollywood se ____ imaginado." (would have — pluperf subj)','habría',array['había','haya','hubiera'],'would have (cond perf)',3),
  (v_l6,'multiple_choice','What does "farfullar" mean?','to mumble',array['to fart','to far','to fall'],'to mumble',4),
  (v_l6,'multiple_choice','What is "intonation"?','la entonación',array['la entrenación','la entrada','la entrega'],'intonation',5),
  (v_l7,'multiple_choice','What does "brillar por" mean here?','to shine thanks to',array['to shine for (cause)','to shine in (place)','to shine over'],'to shine thanks to',1),
  (v_l7,'multiple_choice','What does "previsible" mean?','predictable',array['provisional','prudent','primary'],'predictable',2),
  (v_l7,'fill_blank','Complete: "Brilla ____ las interpretaciones." (thanks to)','por',array['de','con','en'],'thanks to (por)',3),
  (v_l7,'multiple_choice','What does "conmovedor" mean?','moving (emotional)',array['comforting','combative','combining'],'moving',4),
  (v_l7,'multiple_choice','What does "hilarante" mean?','hilarious',array['hilarious (only)','hilly','helpful'],'hilarious',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Almodóvar, cuyo estilo se reconoce a la primera, vuelve con un melodrama exquisito',array['Un cineasta legendario','Su nueva película es buena','El reparto es excelente'],'Almodóvar, whose style is recognized at first glance, returns with an exquisite melodrama',6),
  (v_l1,'listening','What did you hear?','vuelve con un melodrama exquisito',array['vuelve con una comedia ligera','vuelve con un thriller intenso','vuelve con un documental'],'returns with an exquisite melodrama',7),
  (v_l1,'speaking','Say this aloud: "Su estilo se reconoce a la primera."','Su estilo se reconoce a la primera',array[]::text[],'His style is recognized at first glance.',8),
  (v_l1,'speaking','Say this aloud: "Un melodrama exquisito."','Un melodrama exquisito',array[]::text[],'An exquisite melodrama.',9),
  (v_l2,'listening','What did you hear?','Me enganché tanto que vi toda la temporada del tirón',array['Vi un capítulo','Esperé al siguiente','Me cansé pronto'],'I got so hooked I watched the whole season in one go',6),
  (v_l2,'listening','What did you hear?','del tirón',array['poco a poco','con calma','sin prisa'],'in one go',7),
  (v_l2,'speaking','Say this aloud: "Me enganché del tirón."','Me enganché del tirón',array[]::text[],'I got hooked in one go.',8),
  (v_l2,'speaking','Say this aloud: "Vi toda la temporada de un tirón."','Vi toda la temporada de un tirón',array[]::text[],'I watched the whole season in one go.',9),
  (v_l3,'listening','What did you hear?','Esta canción está sonando en todas las emisoras',array['Esta canción es famosa','Esta canción es nueva','Esta canción es antigua'],'This song is playing on every station',6),
  (v_l3,'listening','What did you hear?','en todas las emisoras',array['en pocas emisoras','en la televisión','en internet'],'on every station',7),
  (v_l3,'speaking','Say this aloud: "Esta canción está sonando en todos lados."','Esta canción está sonando en todos lados',array[]::text[],'This song is playing everywhere.',8),
  (v_l3,'speaking','Say this aloud: "Es un éxito en las emisoras."','Es un éxito en las emisoras',array[]::text[],'It''s a hit on the stations.',9),
  (v_l6,'listening','What did you hear?','Hostia, qué pasada lo del partido',array['Tremendo, qué partidazo','Vaya, qué bien jugó','El partido fue increíble'],'Whoa, what a thing about the match',6),
  (v_l6,'listening','What did you hear?','ni en Hollywood se habría imaginado',array['ni siquiera en cine','ni en sueños','ni el director'],'not even Hollywood could have imagined it',7),
  (v_l6,'speaking','Say this aloud: "Qué pasada lo del partido."','Qué pasada lo del partido',array[]::text[],'What a thing about the match.',8),
  (v_l6,'speaking','Say this aloud: "Ni en Hollywood se habría imaginado."','Ni en Hollywood se habría imaginado',array[]::text[],'Not even Hollywood could have imagined it.',9),
  (v_l7,'listening','What did you hear?','Una película conmovedora cuyo guion, aunque previsible, brilla por las interpretaciones',array['Una comedia ligera','Un thriller predecible','Un melodrama exquisito'],'A moving film whose script, although predictable, shines thanks to the performances',6),
  (v_l7,'listening','What did you hear?','brilla por las interpretaciones',array['brilla por su ausencia','brilla por el guion','brilla por la dirección'],'shines thanks to the performances',7),
  (v_l7,'speaking','Say this aloud: "Brilla por las interpretaciones."','Brilla por las interpretaciones',array[]::text[],'It shines thanks to the performances.',8),
  (v_l7,'speaking','Say this aloud: "Aunque previsible, es conmovedora."','Aunque previsible, es conmovedora',array[]::text[],'Although predictable, it''s moving.',9);

  update public.lessons set type='conversation', title='Native Content — Conversation Practice',
    description='Two friends discuss a Spanish series.',
    intro='Marina and Diego chat about a recent hit.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Marina","spanish":"¿Has visto la nueva temporada?","english":"Have you seen the new season?"},{"speaker":"Diego","spanish":"Sí. Me enganché tanto que la vi del tirón.","english":"Yes. I got so hooked I watched it in one go."},{"speaker":"Marina","spanish":"El giro argumental del capítulo cinco fue una pasada.","english":"The plot twist of episode five was incredible."},{"speaker":"Diego","spanish":"Hostia, sí. Ni en Hollywood se habría imaginado.","english":"Whoa, yes. Not even Hollywood could have imagined it."},{"speaker":"Marina","spanish":"Lo mejor es el reparto, cuyo trabajo brilla por las interpretaciones.","english":"The best part is the cast, whose work shines thanks to the performances."},{"speaker":"Diego","spanish":"De acuerdo. Aunque el guion sea previsible a ratos, vale mucho la pena.","english":"Agreed. Even if the script is predictable at times, it''s very much worth it."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','How did Diego watch?','In one go (del tirón)',array['Episode by episode','In two days','Skipping episodes'],'del tirón',1),
  (v_l8,'multiple_choice','What was incredible?','The plot twist of episode 5',array['The opening credits','The soundtrack','The first scene'],'el giro argumental del capítulo cinco',2),
  (v_l8,'multiple_choice','Diego''s exclamation?','Even Hollywood couldn''t have imagined it',array['It''s typical','It''s boring','It''s ordinary'],'ni en Hollywood se habría imaginado',3),
  (v_l8,'multiple_choice','Marina''s favorite element?','The cast and performances',array['Direction','Music','Costumes'],'el reparto brilla por las interpretaciones',4),
  (v_l8,'fill_blank','Complete: "Aunque el guion ____ previsible." (be — subj)','sea',array['es','será','era'],'be (subj)',5),
  (v_l8,'multiple_choice','Final verdict?','Worth it despite predictability',array['Not worth it','Perfect','Boring'],'vale mucho la pena',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Native Content', 'Review test for the Native Content section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "plot twist"?','el giro argumental',array['el giro de plot','la trama vuelta','el cambio de plot'],'plot twist',1),
  (v_lesson_id,'multiple_choice','What does "del tirón" mean?','in one go',array['from the pull','at once (only)','quickly'],'in one go',2),
  (v_lesson_id,'multiple_choice','What is "livestream"?','el directo',array['el live','el corriente','el inmediato'],'livestream',3),
  (v_lesson_id,'multiple_choice','What does "brillar por" + noun usually mean?','to shine thanks to',array['to shine for (cause)','to shine in (place)','to shine over'],'to shine thanks to',4),
  (v_lesson_id,'fill_blank','Complete: "Para los que se ____ apuntado." (have — subj)','hayan',array['han','habrán','habían'],'have (subj)',5),
  (v_lesson_id,'fill_blank','Complete: "Aunque el guion ____ previsible." (be — subj)','sea',array['es','será','era'],'be (subj)',6),
  (v_lesson_id,'listening','What did you hear?','Me enganché tanto que vi toda la temporada del tirón',array['La trama es predecible','El reparto es genial','El final me sorprendió'],'I got so hooked I watched the whole season in one go',7),
  (v_lesson_id,'listening','What did you hear?','Hostia, qué pasada lo del partido',array['Vaya, qué bien jugó','El partido fue largo','El equipo perdió'],'Whoa, what a thing about the match',8),
  (v_lesson_id,'speaking','Say this aloud: "Me enganché del tirón."','Me enganché del tirón',array[]::text[],'I got hooked in one go.',9),
  (v_lesson_id,'speaking','Say this aloud: "Brilla por las interpretaciones."','Brilla por las interpretaciones',array[]::text[],'It shines thanks to the performances.',10);

end $$;

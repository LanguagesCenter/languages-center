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

  -- ===========================================================
  -- C1.6 ACADEMIC LANGUAGE
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'C1' and title = 'Academic Language';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='Academic Spanish uses dense vocabulary: "el paradigma", "la cosmovisión", "la epistemología". Each carries specific theoretical weight.',
    vocab_items='[{"spanish":"el paradigma","english":"paradigm"},{"spanish":"la cosmovisión","english":"worldview"},{"spanish":"la epistemología","english":"epistemology"},{"spanish":"la metodología","english":"methodology"},{"spanish":"el marco teórico","english":"theoretical framework"},{"spanish":"la hipótesis","english":"hypothesis"},{"spanish":"el corpus","english":"corpus"},{"spanish":"la variable","english":"variable"},{"spanish":"el constructo","english":"construct"},{"spanish":"el supuesto","english":"assumption"}]'::jsonb,
    dialogue='[{"speaker":"Profesor","spanish":"Cada disciplina opera dentro de un paradigma cuyos supuestos delimitan lo investigable.","english":"Each discipline operates within a paradigm whose assumptions delimit what is investigable."}]'::jsonb,
    grammar_note='"Lo + adjective/participle" forms abstract nouns: "lo investigable" = "what is investigable / the investigable". Common in academic prose for hypotheticals.'
  where id = v_l1;

  update public.lessons set
    intro='Academic discourse markers: "cabe destacar", "es preciso señalar", "no resulta trivial".',
    vocab_items='[{"spanish":"cabe destacar","english":"it is worth noting"},{"spanish":"es preciso señalar","english":"it is necessary to point out"},{"spanish":"no resulta trivial","english":"it is not trivial"},{"spanish":"merece atención","english":"deserves attention"},{"spanish":"a tenor de","english":"in light of"},{"spanish":"en virtud de","english":"by virtue of"},{"spanish":"en aras de","english":"for the sake of"},{"spanish":"en consonancia con","english":"in line with"}]'::jsonb,
    dialogue='[{"speaker":"Texto académico","spanish":"En virtud de los datos recopilados, cabe destacar tres hallazgos principales.","english":"By virtue of the data collected, it is worth noting three main findings."}]'::jsonb,
    grammar_note='"En virtud de + noun" = "by virtue of + noun" (formal causal). "En aras de + noun" = "for the sake of + noun" (formal purpose). Both belong to elevated registers.'
  where id = v_l2;

  update public.lessons set
    intro='Citing sources academically: APA style in Spanish. Master "et al.", "ibid.", "op. cit.".',
    vocab_items='[{"spanish":"la cita","english":"citation"},{"spanish":"la referencia","english":"reference"},{"spanish":"el pie de página","english":"footnote"},{"spanish":"la nota al pie","english":"footnote"},{"spanish":"la bibliografía","english":"bibliography"},{"spanish":"la fuente primaria","english":"primary source"},{"spanish":"la fuente secundaria","english":"secondary source"},{"spanish":"el plagio","english":"plagiarism"},{"spanish":"el corpus textual","english":"text corpus"},{"spanish":"el análisis crítico","english":"critical analysis"}]'::jsonb,
    dialogue='[{"speaker":"Investigadora","spanish":"García et al. (2022) sostienen que la metodología cuantitativa, si bien rigurosa, presenta limitaciones.","english":"García et al. (2022) maintain that the quantitative methodology, while rigorous, presents limitations."}]'::jsonb,
    grammar_note='"Sostener que + indicative" = "to maintain that..." — assertion. Distinct from "sugerir que" + (often) subjunctive (suggestion).'
  where id = v_l3;

  update public.lessons set
    intro='Conference presentations: "agradezco la oportunidad", "como se observa", "permítanme una digresión".',
    vocab_items='[{"spanish":"el congreso","english":"conference"},{"spanish":"la ponencia","english":"presentation"},{"spanish":"el ponente","english":"presenter"},{"spanish":"el público","english":"audience"},{"spanish":"la mesa redonda","english":"round table"},{"spanish":"el coloquio","english":"colloquium"},{"spanish":"el simposio","english":"symposium"},{"spanish":"como se observa","english":"as observed"},{"spanish":"permítanme","english":"allow me (formal pl)"},{"spanish":"la diapositiva","english":"slide"}]'::jsonb,
    dialogue='[{"speaker":"Ponente","spanish":"Agradezco la oportunidad. Como se observa en la diapositiva, los resultados son contundentes.","english":"I thank you for the opportunity. As observed in the slide, the results are forceful."}]'::jsonb,
    grammar_note='"Permítanme + infinitive" = "allow me (plural formal) to + verb". Used to address an academic audience: "permítanme una digresión".'
  where id = v_l4;

  update public.lessons set
    intro='Critical thinking vocabulary: "matizar", "problematizar", "deconstruir", "interrogar (las premisas)".',
    vocab_items='[{"spanish":"matizar","english":"to nuance"},{"spanish":"problematizar","english":"to problematize"},{"spanish":"deconstruir","english":"to deconstruct"},{"spanish":"interrogar (las premisas)","english":"to interrogate (the premises)"},{"spanish":"cuestionar el supuesto","english":"to question the assumption"},{"spanish":"reconceptualizar","english":"to reconceptualize"},{"spanish":"abordar críticamente","english":"to address critically"},{"spanish":"poner en tela de juicio","english":"to call into question"}]'::jsonb,
    dialogue='[{"speaker":"Crítica","spanish":"Conviene poner en tela de juicio el supuesto de que el mercado se autorregula.","english":"It''s appropriate to call into question the assumption that the market self-regulates."}]'::jsonb,
    grammar_note='"Poner en tela de juicio + noun" = "to call into question". "Tela de juicio" comes from old legal proceedings — frozen idiom now used in serious contexts.'
  where id = v_l5;

  update public.lessons set
    intro='Listen to a university lecture. Professors use complex sentences, frequent qualifications.',
    vocab_items='[{"spanish":"la clase magistral","english":"lecture"},{"spanish":"el profesor titular","english":"tenured professor"},{"spanish":"el alumnado","english":"student body"},{"spanish":"el currículum","english":"curriculum"},{"spanish":"abordar","english":"to address"},{"spanish":"esbozar","english":"to outline"},{"spanish":"profundizar en","english":"to deepen"}]'::jsonb,
    dialogue='[{"speaker":"Catedrático","spanish":"En la sesión de hoy abordaremos un fenómeno cuyas implicaciones, lejos de ser triviales, han marcado el debate contemporáneo.","english":"In today''s session we will address a phenomenon whose implications, far from being trivial, have marked contemporary debate."}]'::jsonb,
    grammar_note='"Lejos de + infinitive" = "far from + V-ing": "lejos de ser triviales" = "far from being trivial". Creates strong contrastive emphasis.'
  where id = v_l6;

  update public.lessons set
    intro='Write an academic abstract. Five elements: context, problem, approach, results, contribution.',
    vocab_items='[{"spanish":"el resumen","english":"abstract"},{"spanish":"el problema","english":"problem"},{"spanish":"el enfoque","english":"approach"},{"spanish":"la contribución","english":"contribution"},{"spanish":"la aportación","english":"contribution"},{"spanish":"el aporte","english":"contribution (Latin Am.)"},{"spanish":"el alcance","english":"scope"},{"spanish":"la implicación","english":"implication"}]'::jsonb,
    dialogue='[{"speaker":"Resumen","spanish":"El presente trabajo examina, desde un enfoque cualitativo, las narrativas migratorias contemporáneas, aportando una nueva tipología.","english":"The present work examines, from a qualitative approach, contemporary migration narratives, contributing a new typology."}]'::jsonb,
    grammar_note='Gerunds for accompanying actions: "aportando una nueva tipología" = "contributing a new typology". This use ("aportar" as gerund-of-result) is academic shorthand.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "paradigm"?','el paradigma',array['el paragón','el paráclito','el pariente'],'paradigm',1),
  (v_l1,'multiple_choice','What is "worldview"?','la cosmovisión',array['el cosmos','la mundovisión','la cosmología'],'worldview',2),
  (v_l1,'fill_blank','Complete: "____ investigable depende del paradigma." (what''s)','Lo',array['El','La','Le'],'what''s investigable',3),
  (v_l1,'multiple_choice','What is "assumption" (academic)?','el supuesto',array['la suposición (only)','el suspenso','el suspiro'],'assumption',4),
  (v_l1,'multiple_choice','What is "theoretical framework"?','el marco teórico',array['el campo teórico','el mando teórico','el marco teorético'],'theoretical framework',5),
  (v_l2,'multiple_choice','What does "en virtud de" mean?','by virtue of',array['in virtue','with virtue','for virtue'],'by virtue of',1),
  (v_l2,'multiple_choice','What does "en aras de" mean?','for the sake of',array['in the aerial','about aria','at the area'],'for the sake of',2),
  (v_l2,'fill_blank','Complete: "Cabe ____ tres hallazgos." (note — inf)','destacar',array['destaco','destacaba','destacando'],'to note',3),
  (v_l2,'multiple_choice','What does "no resulta trivial" mean?','it is not trivial',array['it doesn''t result','it''s not real','it''s not visible'],'not trivial',4),
  (v_l2,'multiple_choice','What does "a tenor de" mean?','in light of',array['at the tenor of','about the tenor','for the tenor'],'in light of',5),
  (v_l3,'multiple_choice','What is "primary source"?','la fuente primaria',array['la fuente primera','el origen','el primero'],'primary source',1),
  (v_l3,'multiple_choice','What is "footnote"?','la nota al pie',array['la nota inferior','la nota debajo','la nota a pie'],'footnote',2),
  (v_l3,'fill_blank','Complete: "García et al. (2022) ____ que." (maintain)','sostienen',array['sostiene','sostuvieron','sostengan'],'maintain',3),
  (v_l3,'multiple_choice','What is "plagiarism"?','el plagio',array['la plaga','el plagioso','la plana'],'plagiarism',4),
  (v_l3,'multiple_choice','What is "text corpus"?','el corpus textual',array['el cuerpo textual','el corpus de texto','la colección'],'text corpus',5),
  (v_l4,'multiple_choice','What is "presenter" (academic)?','el ponente',array['el potente','el poniente','el portento'],'presenter',1),
  (v_l4,'multiple_choice','What does "como se observa" mean?','as observed',array['as one sees','as is seen by','as visible'],'as observed',2),
  (v_l4,'fill_blank','Complete: "____ una digresión." (allow me, formal pl)','Permítanme',array['Permítame','Permíteme','Permitan'],'allow me (formal pl)',3),
  (v_l4,'multiple_choice','What is "round table"?','la mesa redonda',array['la mesa circular','la mesa de redondo','el círculo de mesa'],'round table',4),
  (v_l4,'multiple_choice','What is "slide"?','la diapositiva',array['la diáfana','la diapasón','la diagonal'],'slide',5),
  (v_l5,'multiple_choice','What does "problematizar" mean?','to problematize',array['to solve a problem','to create problems','to anticipate problems'],'to problematize',1),
  (v_l5,'multiple_choice','What does "poner en tela de juicio" mean?','to call into question',array['to wear in court','to fabric judgment','to dress for trial'],'call into question',2),
  (v_l5,'fill_blank','Complete: "Conviene ____ las premisas." (interrogate — inf)','interrogar',array['interrogo','interrogaba','interrogando'],'to interrogate',3),
  (v_l5,'multiple_choice','What does "deconstruir" mean?','to deconstruct',array['to destruct','to dispel','to discard'],'to deconstruct',4),
  (v_l5,'multiple_choice','What does "reconceptualizar" mean?','to reconceptualize',array['to recapitulate','to recollect','to reorganize'],'reconceptualize',5),
  (v_l6,'multiple_choice','What is "lecture" (university)?','la clase magistral',array['la clase principal','la lección magistral','la conferencia'],'lecture',1),
  (v_l6,'multiple_choice','What does "esbozar" mean?','to outline',array['to splash','to sprawl','to spread'],'to outline',2),
  (v_l6,'fill_blank','Complete: "Lejos de ____ triviales." (be — inf)','ser',array['siendo','sido','es'],'be (inf)',3),
  (v_l6,'multiple_choice','What is "tenured professor"?','el profesor titular',array['el profesor pleno','el profesor titular (incorrect)','el catedrático (synonym)'],'tenured prof',4),
  (v_l6,'multiple_choice','What does "abordar" mean?','to address',array['to abort','to absorb','to abandon'],'to address',5),
  (v_l7,'multiple_choice','What is "approach" (research)?','el enfoque',array['el efecto','el ejemplo','el enfocado'],'approach',1),
  (v_l7,'multiple_choice','What is "contribution"?','la aportación',array['la aprobación','la aplicación','la apoyada'],'contribution',2),
  (v_l7,'fill_blank','Complete: "____ una nueva tipología." (contributing - gerund)','aportando',array['aportar','aportado','aporta'],'contributing',3),
  (v_l7,'multiple_choice','What is "scope"?','el alcance',array['el alcohol','el alce','el alcalde'],'scope',4),
  (v_l7,'multiple_choice','What does "el aporte" specifically mean?','contribution (Latin Am.)',array['the port','the carrier','the transport'],'contribution (LatAm)',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Cada disciplina opera dentro de un paradigma cuyos supuestos delimitan lo investigable',array['El marco teórico es vital','La cosmovisión cambia','La epistemología varía'],'Each discipline operates within a paradigm whose assumptions delimit what is investigable',6),
  (v_l1,'listening','What did you hear?','delimitan lo investigable',array['delimitan lo posible','delimitan lo válido','delimitan lo real'],'delimit what is investigable',7),
  (v_l1,'speaking','Say this aloud: "Lo investigable depende del paradigma."','Lo investigable depende del paradigma',array[]::text[],'What is investigable depends on the paradigm.',8),
  (v_l1,'speaking','Say this aloud: "Cada disciplina tiene sus supuestos."','Cada disciplina tiene sus supuestos',array[]::text[],'Each discipline has its assumptions.',9),
  (v_l2,'listening','What did you hear?','En virtud de los datos recopilados, cabe destacar tres hallazgos principales',array['Es preciso señalar el método','En aras de la rigurosidad','A tenor de los resultados'],'By virtue of the data collected, it is worth noting three main findings',6),
  (v_l2,'listening','What did you hear?','tres hallazgos principales',array['tres conclusiones','tres hipótesis','tres ejemplos'],'three main findings',7),
  (v_l2,'speaking','Say this aloud: "En virtud de los datos, cabe destacar tres hallazgos."','En virtud de los datos, cabe destacar tres hallazgos',array[]::text[],'By virtue of the data, it''s worth noting three findings.',8),
  (v_l2,'speaking','Say this aloud: "En aras de la claridad."','En aras de la claridad',array[]::text[],'For the sake of clarity.',9),
  (v_l3,'listening','What did you hear?','García et al. (2022) sostienen que la metodología cuantitativa presenta limitaciones',array['García et al. cuestionan el método','García et al. refutan la teoría','García et al. proponen otra'],'García et al. (2022) maintain that the quantitative methodology presents limitations',6),
  (v_l3,'listening','What did you hear?','si bien rigurosa, presenta limitaciones',array['si bien limitada, es válida','si bien útil, es lenta','si bien clara, es escueta'],'while rigorous, presents limitations',7),
  (v_l3,'speaking','Say this aloud: "García et al. sostienen que es rigurosa."','García et al. sostienen que es rigurosa',array[]::text[],'García et al. maintain that it''s rigorous.',8),
  (v_l3,'speaking','Say this aloud: "Si bien rigurosa, tiene limitaciones."','Si bien rigurosa, tiene limitaciones',array[]::text[],'While rigorous, it has limitations.',9),
  (v_l6,'listening','What did you hear?','En la sesión de hoy abordaremos un fenómeno cuyas implicaciones',array['lejos de ser triviales','han marcado el debate','el debate contemporáneo'],'In today''s session we will address a phenomenon whose implications',6),
  (v_l6,'listening','What did you hear?','lejos de ser triviales, han marcado el debate contemporáneo',array['son triviales y conocidas','no han influido en el debate','están sobreestimadas'],'far from being trivial, have marked contemporary debate',7),
  (v_l6,'speaking','Say this aloud: "Hoy abordaremos un fenómeno complejo."','Hoy abordaremos un fenómeno complejo',array[]::text[],'Today we''ll address a complex phenomenon.',8),
  (v_l6,'speaking','Say this aloud: "Lejos de ser triviales."','Lejos de ser triviales',array[]::text[],'Far from being trivial.',9),
  (v_l7,'listening','What did you hear?','El presente trabajo examina las narrativas migratorias contemporáneas',array['desde un enfoque cualitativo','aportando una nueva tipología','el análisis es crítico'],'The present work examines contemporary migration narratives',6),
  (v_l7,'listening','What did you hear?','aportando una nueva tipología',array['siguiendo el modelo clásico','rechazando la tradición','validando la teoría'],'contributing a new typology',7),
  (v_l7,'speaking','Say this aloud: "Desde un enfoque cualitativo."','Desde un enfoque cualitativo',array[]::text[],'From a qualitative approach.',8),
  (v_l7,'speaking','Say this aloud: "Aportando una nueva tipología."','Aportando una nueva tipología',array[]::text[],'Contributing a new typology.',9);

  update public.lessons set type='conversation', title='Academic Language — Conversation Practice',
    description='Two academics discuss a paper.',
    intro='Dra. Vega and Dr. Romero review a thesis.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Vega","spanish":"¿Qué le pareció el marco teórico de la tesis?","english":"What did you think of the thesis''s theoretical framework?"},{"speaker":"Romero","spanish":"Sólido. No obstante, conviene problematizar algunos supuestos.","english":"Solid. However, it''s appropriate to problematize some assumptions."},{"speaker":"Vega","spanish":"En virtud de los datos, cabe destacar la originalidad del aporte.","english":"By virtue of the data, it''s worth noting the originality of the contribution."},{"speaker":"Romero","spanish":"Cierto. Aunque, lejos de ser definitivo, abre nuevas preguntas.","english":"True. Although, far from being definitive, it opens new questions."},{"speaker":"Vega","spanish":"Permítame matizar: precisamente eso lo hace valioso.","english":"Allow me to nuance: that''s precisely what makes it valuable."},{"speaker":"Romero","spanish":"De acuerdo. Recomendaría aprobarla con nota sobresaliente.","english":"Agreed. I would recommend approving it with highest honors."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','What did Romero think of the framework?','Solid but with assumptions to problematize',array['Weak','Perfect','Outdated'],'sólido, pero conviene problematizar',1),
  (v_l8,'multiple_choice','What does Vega highlight?','Originality of contribution',array['Length','Style','References'],'la originalidad del aporte',2),
  (v_l8,'multiple_choice','Romero''s qualification?','It''s not definitive but opens questions',array['It''s definitive','It''s incomplete','It''s wrong'],'lejos de ser definitivo, abre preguntas',3),
  (v_l8,'multiple_choice','Vega''s response?','That openness is what makes it valuable',array['It should be definitive','Questions are weaknesses','It needs more work'],'precisamente eso lo hace valioso',4),
  (v_l8,'fill_blank','Complete: "Permítame ____" (nuance — inf)','matizar',array['matizo','matizado','matizando'],'to nuance',5),
  (v_l8,'multiple_choice','Romero''s recommendation?','Approve with highest honors',array['Reject','Request revisions','Approve barely'],'aprobarla con nota sobresaliente',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Academic Language', 'Review test for the Academic Language section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "paradigm"?','el paradigma',array['el paragón','el paráclito','el pariente'],'paradigm',1),
  (v_lesson_id,'multiple_choice','What does "en virtud de" mean?','by virtue of',array['in virtue','with virtue','for virtue'],'by virtue of',2),
  (v_lesson_id,'multiple_choice','What does "poner en tela de juicio" mean?','to call into question',array['to wear in court','to fabric judgment','to dress for trial'],'call into question',3),
  (v_lesson_id,'multiple_choice','What does "lejos de ser" mean?','far from being',array['near being','close to being','besides being'],'far from being',4),
  (v_lesson_id,'fill_blank','Complete: "Cabe ____ tres hallazgos." (note — inf)','destacar',array['destaco','destacaba','destacando'],'to note',5),
  (v_lesson_id,'fill_blank','Complete: "____ una nueva tipología." (contributing — gerund)','Aportando',array['Aportar','Aportado','Aporta'],'contributing',6),
  (v_lesson_id,'listening','What did you hear?','En virtud de los datos, cabe destacar tres hallazgos',array['García et al. sostienen','Si bien rigurosa','Lejos de ser triviales'],'By virtue of the data, it''s worth noting three findings',7),
  (v_lesson_id,'listening','What did you hear?','lejos de ser triviales, han marcado el debate',array['Las implicaciones son obvias','El paradigma cambia','La cosmovisión perdura'],'far from being trivial, they have marked the debate',8),
  (v_lesson_id,'speaking','Say this aloud: "En virtud de los datos."','En virtud de los datos',array[]::text[],'By virtue of the data.',9),
  (v_lesson_id,'speaking','Say this aloud: "Cabe destacar la originalidad del aporte."','Cabe destacar la originalidad del aporte',array[]::text[],'It''s worth noting the originality of the contribution.',10);

  -- ===========================================================
  -- C1.7 PROFESSIONAL COMMUNICATION
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'C1' and title = 'Professional Communication';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='Business emails: opening, request, justification, closing. Spanish professional email is more formal than English.',
    vocab_items='[{"spanish":"el correo electrónico","english":"email"},{"spanish":"el asunto","english":"subject"},{"spanish":"adjuntar","english":"to attach"},{"spanish":"reenviar","english":"to forward"},{"spanish":"con copia a","english":"with copy to"},{"spanish":"el destinatario","english":"recipient"},{"spanish":"a la atención de","english":"for the attention of"},{"spanish":"agradeceríamos","english":"we would appreciate"},{"spanish":"a la espera de su respuesta","english":"awaiting your response"},{"spanish":"reciba un cordial saludo","english":"receive a cordial greeting"}]'::jsonb,
    dialogue='[{"speaker":"Email","spanish":"Estimado Sr. Gómez: A la atención de su departamento, agradeceríamos confirmara la disponibilidad para la reunión.","english":"Dear Mr. Gómez: For the attention of your department, we would appreciate if you could confirm availability for the meeting."}]'::jsonb,
    grammar_note='"Agradeceríamos + bare subjunctive" = "we would appreciate if you...". Formal omission of "que": "agradeceríamos confirmara" instead of "agradeceríamos que confirmara".'
  where id = v_l1;

  update public.lessons set
    intro='Meetings: agenda, minutes, actions. Master the professional meeting vocabulary.',
    vocab_items='[{"spanish":"la reunión","english":"meeting"},{"spanish":"el orden del día","english":"agenda"},{"spanish":"el acta","english":"minutes"},{"spanish":"convocar","english":"to convene"},{"spanish":"el quórum","english":"quorum"},{"spanish":"someter a votación","english":"to put to a vote"},{"spanish":"la propuesta","english":"proposal"},{"spanish":"la acción","english":"action item"},{"spanish":"el responsable","english":"person responsible"},{"spanish":"el plazo","english":"deadline"}]'::jsonb,
    dialogue='[{"speaker":"Presidenta","spanish":"Se somete a votación la propuesta. Quienes estén a favor, levanten la mano.","english":"The proposal is put to a vote. Those in favor, raise your hand."}]'::jsonb,
    grammar_note='"Quienes + subjunctive" = "those who...": "quienes estén" — subjunctive because the set is open. Compare: "los que están" (defined set, indicative).'
  where id = v_l2;

  update public.lessons set
    intro='Negotiation Spanish: opening offers, counter-offers, conditions. "Estamos abiertos a", "consideraríamos", "bajo qué condiciones".',
    vocab_items='[{"spanish":"la negociación","english":"negotiation"},{"spanish":"negociar","english":"to negotiate"},{"spanish":"la oferta","english":"offer"},{"spanish":"la contraoferta","english":"counter-offer"},{"spanish":"la condición","english":"condition"},{"spanish":"estar abierto a","english":"to be open to"},{"spanish":"considerar","english":"to consider"},{"spanish":"el margen","english":"margin"},{"spanish":"ceder","english":"to yield"},{"spanish":"llegar a un acuerdo","english":"to reach an agreement"}]'::jsonb,
    dialogue='[{"speaker":"Negociador","spanish":"Estamos abiertos a renegociar, siempre que el plazo se mantenga.","english":"We are open to renegotiate, provided the deadline is kept."}]'::jsonb,
    grammar_note='"Siempre que + subjunctive" = "provided that...": "siempre que se mantenga". Conditional with subjunctive — distinct from "siempre que + indicative" = "every time that".'
  where id = v_l3;

  update public.lessons set
    intro='Presentations: introduction, body, conclusion. Professional Spanish presentations have a recognizable structure.',
    vocab_items='[{"spanish":"la presentación","english":"presentation"},{"spanish":"la diapositiva","english":"slide"},{"spanish":"el resumen ejecutivo","english":"executive summary"},{"spanish":"los puntos clave","english":"key points"},{"spanish":"el cierre","english":"closing"},{"spanish":"el rendimiento","english":"performance"},{"spanish":"el balance","english":"balance"},{"spanish":"la perspectiva","english":"outlook"},{"spanish":"la proyección","english":"projection"},{"spanish":"el escenario","english":"scenario"}]'::jsonb,
    dialogue='[{"speaker":"Presentadora","spanish":"En primer lugar, repasaré los resultados del trimestre. A continuación, expondré las proyecciones.","english":"First, I''ll review the quarterly results. Next, I''ll present the projections."}]'::jsonb,
    grammar_note='Structural connectors: "en primer lugar", "a continuación", "para concluir". These are essential for clear presentations and signal each move.'
  where id = v_l4;

  update public.lessons set
    intro='Performance reviews: feedback, goals, development. The vocabulary of constructive professional dialogue.',
    vocab_items='[{"spanish":"la evaluación","english":"evaluation"},{"spanish":"el feedback","english":"feedback"},{"spanish":"el desempeño","english":"performance"},{"spanish":"el área de mejora","english":"area for improvement"},{"spanish":"el objetivo","english":"objective"},{"spanish":"el desarrollo profesional","english":"professional development"},{"spanish":"reconocer","english":"to recognize"},{"spanish":"destacar","english":"to highlight"},{"spanish":"el plan de carrera","english":"career plan"}]'::jsonb,
    dialogue='[{"speaker":"Jefa","spanish":"Reconozco tu compromiso. Dicho esto, hay áreas de mejora que conviene abordar.","english":"I recognize your commitment. That said, there are areas for improvement that should be addressed."}]'::jsonb,
    grammar_note='"Dicho esto" = "that said" — a pivot phrase introducing the qualification or counterpoint. Standard in professional feedback delivery.'
  where id = v_l5;

  update public.lessons set
    intro='Listen to a business call. Note the formal register, polite hedging.',
    vocab_items='[{"spanish":"la llamada","english":"call"},{"spanish":"la videoconferencia","english":"video conference"},{"spanish":"conectarse","english":"to connect"},{"spanish":"silenciar el micro","english":"to mute the mic"},{"spanish":"compartir pantalla","english":"to share screen"},{"spanish":"ponerse al día","english":"to catch up"}]'::jsonb,
    dialogue='[{"speaker":"Caller A","spanish":"Buenos días. Antes de empezar, ¿podrían compartirnos los documentos del orden del día?","english":"Good morning. Before we start, could you share the agenda documents with us?"},{"speaker":"Caller B","spanish":"Por supuesto. Los recibirán en breves momentos.","english":"Of course. You''ll receive them shortly."}]'::jsonb,
    grammar_note='"En breves momentos" = "shortly/in a moment". More formal than "pronto" or "enseguida".'
  where id = v_l6;

  update public.lessons set
    intro='Write a project update. Three sections: progress, blockers, next steps.',
    vocab_items='[{"spanish":"la actualización","english":"update"},{"spanish":"el avance","english":"progress"},{"spanish":"el bloqueo","english":"blocker"},{"spanish":"los próximos pasos","english":"next steps"},{"spanish":"el hito","english":"milestone"},{"spanish":"el riesgo","english":"risk"},{"spanish":"mitigar","english":"to mitigate"},{"spanish":"el avance significativo","english":"significant progress"}]'::jsonb,
    dialogue='[{"speaker":"Actualización","spanish":"Hemos alcanzado el primer hito a tiempo. Cabe destacar que el riesgo identificado en el sprint anterior se ha mitigado satisfactoriamente.","english":"We''ve reached the first milestone on time. It''s worth noting that the risk identified in the previous sprint has been satisfactorily mitigated."}]'::jsonb,
    grammar_note='"Se ha mitigado satisfactoriamente" — adverb in -mente intensifies the participle. Adverbs in -mente are slightly formal markers in business writing.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "subject" (email)?','el asunto',array['el sujeto','el tema','el motivo'],'subject',1),
  (v_l1,'multiple_choice','What does "con copia a" mean?','with copy to (cc)',array['with carbon to','with copy from','with copy in'],'cc',2),
  (v_l1,'fill_blank','Complete: "Agradeceríamos ____ la disponibilidad." (you confirm — bare subj)','confirmara',array['confirma','confirmará','confirmando'],'confirm (bare subj)',3),
  (v_l1,'multiple_choice','What does "a la atención de" mean?','for the attention of',array['at the attention to','with the attention of','by the attention'],'attn',4),
  (v_l1,'multiple_choice','What is "reciba un cordial saludo"?','formal closing',array['informal closing','question','request'],'closing salutation',5),
  (v_l2,'multiple_choice','What is "minutes" (meeting)?','el acta',array['las actas (plural)','los apuntes','el record'],'minutes',1),
  (v_l2,'multiple_choice','What does "quórum" mean?','quorum',array['quartz','quotient','quote'],'quorum',2),
  (v_l2,'fill_blank','Complete: "Quienes ____ a favor." (are — subj)','estén',array['están','estuvieran','estuvo'],'are (subj — open set)',3),
  (v_l2,'multiple_choice','What is "agenda" (meeting)?','el orden del día',array['la agenda','el plan del día','el día de la orden'],'agenda',4),
  (v_l2,'multiple_choice','What does "someter a votación" mean?','to put to a vote',array['to subdue to vote','to vote for','to call to order'],'put to a vote',5),
  (v_l3,'multiple_choice','What is "counter-offer"?','la contraoferta',array['la contrapropuesta','la oferta alternativa','la oferta inversa'],'counter-offer',1),
  (v_l3,'multiple_choice','What does "siempre que" + subj mean?','provided that',array['always that','every time (synonym)','as long as ago'],'provided that',2),
  (v_l3,'fill_blank','Complete: "Siempre que el plazo se ____" (is kept — subj)','mantenga',array['mantiene','mantenía','mantendrá'],'is kept (subj)',3),
  (v_l3,'multiple_choice','What does "ceder" mean?','to yield (give in)',array['to cede (territory)','to send','to seal'],'to yield',4),
  (v_l3,'multiple_choice','What is "to reach an agreement"?','llegar a un acuerdo',array['venir a un acuerdo','llevar a un acuerdo','hacer un acuerdo'],'reach an agreement',5),
  (v_l4,'multiple_choice','What is "executive summary"?','el resumen ejecutivo',array['el sumario','el ejecutivo resumen','el resumen del CEO'],'executive summary',1),
  (v_l4,'multiple_choice','What does "a continuación" mean?','next',array['continually','continued','for example'],'next',2),
  (v_l4,'fill_blank','Complete: "En ____ lugar, repasaré." (first)','primer',array['primero','primera','primarios'],'first (apocopated)',3),
  (v_l4,'multiple_choice','What is "scenario" (forecast)?','el escenario',array['el escena','la escena','el escenificación'],'scenario',4),
  (v_l4,'multiple_choice','What is "projection"?','la proyección',array['la previsión','la profesión','la procesión'],'projection',5),
  (v_l5,'multiple_choice','What is "area for improvement"?','el área de mejora',array['el aspecto a mejorar','el campo mejorable','la zona mejorada'],'area for improvement',1),
  (v_l5,'multiple_choice','What does "dicho esto" mean?','that said',array['said this','this said','told this'],'that said',2),
  (v_l5,'fill_blank','Complete: "____ esto, hay áreas a mejorar." (that said)','Dicho',array['Diciendo','Dijo','Dice'],'that said',3),
  (v_l5,'multiple_choice','What is "performance" (work)?','el desempeño',array['el rendimiento (synonym)','el rendido','el desempeñado'],'performance',4),
  (v_l5,'multiple_choice','What is "career plan"?','el plan de carrera',array['el camino de carrera','el plan profesional','la carrera planificada'],'career plan',5),
  (v_l6,'multiple_choice','What is "video conference"?','la videoconferencia',array['la videollamada (synonym)','la confer-video','la sesión de vídeo'],'video conference',1),
  (v_l6,'multiple_choice','What is "to share screen"?','compartir pantalla',array['compartir la pantalla (incorrect)','presentar pantalla','mostrar pantalla'],'share screen',2),
  (v_l6,'fill_blank','Complete: "Los recibirán en ____ momentos." (brief)','breves',array['breve','brevemente','breviario'],'brief',3),
  (v_l6,'multiple_choice','What does "ponerse al día" mean?','to catch up',array['to put on the day','to wear today','to start the day'],'catch up',4),
  (v_l6,'multiple_choice','What is "to mute the mic"?','silenciar el micro',array['silencio el micro','mute el micro','callar el micro'],'mute the mic',5),
  (v_l7,'multiple_choice','What is "milestone"?','el hito',array['el hilo','el hito (incorrect)','el héroe'],'milestone',1),
  (v_l7,'multiple_choice','What does "mitigar" mean?','to mitigate',array['to migrate','to militate','to multiply'],'to mitigate',2),
  (v_l7,'fill_blank','Complete: "Se ha mitigado ____" (satisfactorily)','satisfactoriamente',array['satisfactorio','satisfacto','satisfacción'],'satisfactorily',3),
  (v_l7,'multiple_choice','What is "blocker" (project)?','el bloqueo',array['el bloque','el blocaje','el bloquero'],'blocker',4),
  (v_l7,'multiple_choice','What is "update"?','la actualización',array['la activación','la actitud','la acumulación'],'update',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Estimado Sr. Gómez: A la atención de su departamento',array['Agradeceríamos confirmara','La disponibilidad para la reunión','Un cordial saludo'],'Dear Mr. Gómez: For the attention of your department',6),
  (v_l1,'listening','What did you hear?','agradeceríamos confirmara la disponibilidad para la reunión',array['agradeceríamos un correo','agradeceríamos asistencia','agradeceríamos los documentos'],'we would appreciate if you could confirm availability for the meeting',7),
  (v_l1,'speaking','Say this aloud: "Agradeceríamos confirmara la disponibilidad."','Agradeceríamos confirmara la disponibilidad',array[]::text[],'We would appreciate if you could confirm availability.',8),
  (v_l1,'speaking','Say this aloud: "A la atención de su departamento."','A la atención de su departamento',array[]::text[],'For the attention of your department.',9),
  (v_l2,'listening','What did you hear?','Se somete a votación la propuesta',array['Quienes estén a favor','Levanten la mano','El acta queda firmada'],'The proposal is put to a vote',6),
  (v_l2,'listening','What did you hear?','Quienes estén a favor, levanten la mano',array['Quienes voten en contra','Quienes se abstengan','Los que estén presentes'],'Those in favor, raise your hand',7),
  (v_l2,'speaking','Say this aloud: "Se somete a votación la propuesta."','Se somete a votación la propuesta',array[]::text[],'The proposal is put to a vote.',8),
  (v_l2,'speaking','Say this aloud: "Quienes estén a favor, levanten la mano."','Quienes estén a favor, levanten la mano',array[]::text[],'Those in favor, raise your hand.',9),
  (v_l3,'listening','What did you hear?','Estamos abiertos a renegociar, siempre que el plazo se mantenga',array['Estamos cerrados a propuestas','Aceptamos cualquier condición','Necesitamos más tiempo'],'We are open to renegotiate, provided the deadline is kept',6),
  (v_l3,'listening','What did you hear?','siempre que el plazo se mantenga',array['siempre que el precio baje','siempre que los términos cambien','siempre que esto convenga'],'provided the deadline is kept',7),
  (v_l3,'speaking','Say this aloud: "Estamos abiertos a renegociar."','Estamos abiertos a renegociar',array[]::text[],'We are open to renegotiate.',8),
  (v_l3,'speaking','Say this aloud: "Siempre que el plazo se mantenga."','Siempre que el plazo se mantenga',array[]::text[],'Provided the deadline is kept.',9),
  (v_l6,'listening','What did you hear?','Antes de empezar, podrían compartirnos los documentos del orden del día',array['Por supuesto, ya los envío','Los recibirán en breves momentos','Comparto pantalla ahora'],'Before we start, could you share the agenda documents with us',6),
  (v_l6,'listening','What did you hear?','Los recibirán en breves momentos',array['Los envío más tarde','Ya están enviados','No los tengo aquí'],'You''ll receive them shortly',7),
  (v_l6,'speaking','Say this aloud: "Los recibirán en breves momentos."','Los recibirán en breves momentos',array[]::text[],'You''ll receive them shortly.',8),
  (v_l6,'speaking','Say this aloud: "Compartir pantalla, por favor."','Compartir pantalla, por favor',array[]::text[],'Share screen, please.',9),
  (v_l7,'listening','What did you hear?','Hemos alcanzado el primer hito a tiempo',array['El riesgo identificado se ha mitigado','El sprint anterior fue difícil','Los próximos pasos son claros'],'We''ve reached the first milestone on time',6),
  (v_l7,'listening','What did you hear?','el riesgo identificado en el sprint anterior se ha mitigado satisfactoriamente',array['hemos alcanzado el hito','los próximos pasos son','el avance es significativo'],'the risk identified in the previous sprint has been satisfactorily mitigated',7),
  (v_l7,'speaking','Say this aloud: "Hemos alcanzado el primer hito a tiempo."','Hemos alcanzado el primer hito a tiempo',array[]::text[],'We''ve reached the first milestone on time.',8),
  (v_l7,'speaking','Say this aloud: "El riesgo se ha mitigado satisfactoriamente."','El riesgo se ha mitigado satisfactoriamente',array[]::text[],'The risk has been satisfactorily mitigated.',9);

  update public.lessons set type='conversation', title='Professional Communication — Conversation Practice',
    description='Two colleagues in a video meeting.',
    intro='Sandra and Tomás review project status.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Sandra","spanish":"Buenos días. Antes de empezar, ¿podrías compartirnos los documentos del orden del día?","english":"Good morning. Before we start, could you share the agenda documents with us?"},{"speaker":"Tomás","spanish":"Por supuesto. Los recibirán en breves momentos.","english":"Of course. You''ll receive them shortly."},{"speaker":"Sandra","spanish":"Perfecto. Como avance, hemos alcanzado el primer hito a tiempo.","english":"Perfect. As progress, we''ve reached the first milestone on time."},{"speaker":"Tomás","spanish":"Dicho esto, hay un bloqueo en el módulo de pagos.","english":"That said, there''s a blocker in the payments module."},{"speaker":"Sandra","spanish":"Agradecería propusieras una solución antes del viernes.","english":"I''d appreciate if you proposed a solution before Friday."},{"speaker":"Tomás","spanish":"De acuerdo. Estamos abiertos a renegociar el alcance, siempre que el plazo se mantenga.","english":"Agreed. We''re open to renegotiate the scope, provided the deadline is kept."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','What does Sandra request first?','Agenda documents',array['Coffee','A meeting room','A team intro'],'documentos del orden del día',1),
  (v_l8,'multiple_choice','Status update?','First milestone reached on time',array['Project delayed','Milestone missed','Sprint failed'],'primer hito a tiempo',2),
  (v_l8,'multiple_choice','Tomás''s pivot?','There''s a blocker in the payments module',array['Everything is perfect','We need more people','Project is over'],'bloqueo en el módulo de pagos',3),
  (v_l8,'multiple_choice','Sandra''s deadline request?','Proposed solution by Friday',array['Resignation by Friday','Report by Monday','Email by today'],'antes del viernes',4),
  (v_l8,'fill_blank','Complete: "Agradecería ____ una solución." (proposed — bare subj)','propusieras',array['propones','proponías','propondrás'],'proposed (bare subj)',5),
  (v_l8,'multiple_choice','Tomás''s condition?','Renegotiate scope if deadline holds',array['Add team','Reduce scope unilaterally','Extend deadline'],'siempre que el plazo se mantenga',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Professional Communication', 'Review test for the Professional Communication section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What does "agradeceríamos + bare subj" form?','formal request',array['informal request','question','statement'],'formal request',1),
  (v_lesson_id,'multiple_choice','What does "quienes" + subj refer to?','those who (open set)',array['those who (defined)','those that exist','those alive'],'quienes (open set)',2),
  (v_lesson_id,'multiple_choice','What does "siempre que" + subj mean?','provided that',array['always that','every time','as long as ago'],'provided that',3),
  (v_lesson_id,'multiple_choice','What does "dicho esto" mean?','that said',array['said this','this said','told this'],'that said',4),
  (v_lesson_id,'fill_blank','Complete: "Quienes ____ a favor." (are — subj)','estén',array['están','estuvieran','estuvo'],'are (subj)',5),
  (v_lesson_id,'fill_blank','Complete: "Siempre que el plazo se ____" (is kept — subj)','mantenga',array['mantiene','mantendrá','mantenía'],'is kept (subj)',6),
  (v_lesson_id,'listening','What did you hear?','Agradeceríamos confirmara la disponibilidad',array['Agradeceríamos confirma','Agradeceríamos confirmando','Agradeceríamos confirmar'],'We would appreciate if you could confirm availability',7),
  (v_lesson_id,'listening','What did you hear?','Estamos abiertos a renegociar, siempre que el plazo se mantenga',array['Aceptamos sin condiciones','Cerramos negociación','Rechazamos la propuesta'],'We are open to renegotiate, provided the deadline is kept',8),
  (v_lesson_id,'speaking','Say this aloud: "Agradeceríamos confirmara la disponibilidad."','Agradeceríamos confirmara la disponibilidad',array[]::text[],'We''d appreciate if you confirmed availability.',9),
  (v_lesson_id,'speaking','Say this aloud: "Quienes estén a favor, levanten la mano."','Quienes estén a favor, levanten la mano',array[]::text[],'Those in favor, raise your hand.',10);

  -- ===========================================================
  -- C1.8 CULTURAL NUANCE
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'C1' and title = 'Cultural Nuance';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='Time and punctuality vary across Hispanic cultures. Argentina differs from Spain, which differs from Mexico. Context matters.',
    vocab_items='[{"spanish":"la puntualidad","english":"punctuality"},{"spanish":"impuntual","english":"unpunctual"},{"spanish":"con retraso","english":"late"},{"spanish":"de cortesía","english":"of courtesy"},{"spanish":"la hora española","english":"Spanish time (late)"},{"spanish":"el cuarto de hora","english":"quarter of an hour"},{"spanish":"el plantón","english":"stand-up"},{"spanish":"la sobremesa","english":"after-meal conversation"},{"spanish":"prolongarse","english":"to extend"}]'::jsonb,
    dialogue='[{"speaker":"Visitante","spanish":"¿A qué hora exactamente debo llegar a la cena?","english":"At what time exactly should I arrive for dinner?"},{"speaker":"Anfitrión","spanish":"Te dije las nueve, pero entiéndelo a la española: nueve y media, mejor.","english":"I said nine, but understand it in Spanish style: nine-thirty, better."}]'::jsonb,
    grammar_note='"A la + adjective" describes a manner: "a la española" (Spanish style), "a la francesa" (French style). Similar to "in the style of...".'
  where id = v_l1;

  update public.lessons set
    intro='Tú vs usted: when to use each. Generational, regional, and contextual variation.',
    vocab_items='[{"spanish":"el tuteo","english":"the use of tú"},{"spanish":"el ustedeo","english":"the use of usted"},{"spanish":"tutear","english":"to use tú"},{"spanish":"el voseo","english":"the use of vos (Arg/Uru)"},{"spanish":"la jerarquía","english":"hierarchy"},{"spanish":"el trato","english":"manner of address"},{"spanish":"la confianza","english":"informality"},{"spanish":"la distancia","english":"distance"},{"spanish":"el respeto","english":"respect"}]'::jsonb,
    dialogue='[{"speaker":"Profesora","spanish":"Aunque sea más joven, le hablo de usted por respeto.","english":"Even though he''s younger, I address him formally out of respect."}]'::jsonb,
    grammar_note='"Hablar de usted/tú" = "to address as usted/tú". "Hablar de + form" describes which pronoun you use with someone.'
  where id = v_l2;

  update public.lessons set
    intro='Hospitality customs: "tomar algo", "pasar a la mesa", "invitar". Specific cultural framing.',
    vocab_items='[{"spanish":"la hospitalidad","english":"hospitality"},{"spanish":"el anfitrión","english":"host"},{"spanish":"el invitado","english":"guest"},{"spanish":"invitar","english":"to invite (also: to treat)"},{"spanish":"tomar algo","english":"to have a drink/snack"},{"spanish":"pasar a la mesa","english":"to come to the table"},{"spanish":"el aperitivo","english":"appetizer"},{"spanish":"la sobremesa","english":"after-meal chat"},{"spanish":"la merienda","english":"afternoon snack"}]'::jsonb,
    dialogue='[{"speaker":"Anfitrión","spanish":"Sentaos y tomad lo que queráis. Hoy os invito yo.","english":"Sit down and have what you want. Today I''m treating."}]'::jsonb,
    grammar_note='"Invitar" has a special Hispanic meaning: to treat someone (pay for them). "Te invito" means "it''s on me". Don''t confuse with simple "to invite".'
  where id = v_l3;

  update public.lessons set
    intro='Compliments and accepting/refusing: Spanish-speakers often refuse compliments. "Qué va", "no es para tanto", "exageras".',
    vocab_items='[{"spanish":"el cumplido","english":"compliment"},{"spanish":"el piropo","english":"flirty compliment"},{"spanish":"halagar","english":"to flatter"},{"spanish":"qué va","english":"no way"},{"spanish":"no es para tanto","english":"it''s not that big a deal"},{"spanish":"exageras","english":"you exaggerate"},{"spanish":"ruborizarse","english":"to blush"},{"spanish":"avergonzar","english":"to embarrass"}]'::jsonb,
    dialogue='[{"speaker":"Amigo","spanish":"Hablas un español impecable.","english":"You speak impeccable Spanish."},{"speaker":"Ana","spanish":"Qué va, todavía me queda mucho por aprender.","english":"No way, I still have a lot to learn."}]'::jsonb,
    grammar_note='"Quedar + por + infinitive" = "to remain + to + verb": "me queda mucho por aprender" = "I have a lot left to learn". Useful for incomplete tasks.'
  where id = v_l4;

  update public.lessons set
    intro='Humor and irony: Spanish humor is direct, often self-deprecating. Mexican humor uses wordplay. Argentine humor is ironic.',
    vocab_items='[{"spanish":"el humor","english":"humor"},{"spanish":"la ironía","english":"irony"},{"spanish":"el sarcasmo","english":"sarcasm"},{"spanish":"la broma","english":"joke"},{"spanish":"el chiste","english":"joke (short)"},{"spanish":"el doble sentido","english":"double meaning"},{"spanish":"el juego de palabras","english":"wordplay"},{"spanish":"con sorna","english":"with mockery"},{"spanish":"reírse","english":"to laugh"},{"spanish":"tomarse a broma","english":"to take as a joke"}]'::jsonb,
    dialogue='[{"speaker":"Amigo","spanish":"Le dije que era el mejor — con sorna, claro.","english":"I told him he was the best — sarcastically, of course."}]'::jsonb,
    grammar_note='"Con sorna" = "with mockery/sarcasm". The Spanish term for this dry humor is "sorna". Often signals tone of voice that''s hard to detect in writing.'
  where id = v_l5;

  update public.lessons set
    intro='Listen to a casual conversation between Spanish speakers. Note implicit codes — tone, irony, pauses.',
    vocab_items='[{"spanish":"el matiz","english":"nuance"},{"spanish":"el tono","english":"tone"},{"spanish":"la entonación","english":"intonation"},{"spanish":"implícito","english":"implicit"},{"spanish":"sobreentender","english":"to understand implicitly"},{"spanish":"leer entre líneas","english":"to read between lines"}]'::jsonb,
    dialogue='[{"speaker":"Amigo 1","spanish":"Vino el jefe, "majísimo", como siempre.","english":"The boss came, "wonderful", as always."},{"speaker":"Amigo 2","spanish":"Ya, ya. Te entiendo perfectamente.","english":"Yeah, yeah. I get you perfectly."}]'::jsonb,
    grammar_note='Quotation marks around adjectives often signal irony: "majísimo" with quotes = the opposite. "Ya, ya" doubled means "I get it / message received" — implicit code.'
  where id = v_l6;

  update public.lessons set
    intro='Write a reflection on a cultural difference you''ve noticed. Use nuanced description.',
    vocab_items='[{"spanish":"la diferencia cultural","english":"cultural difference"},{"spanish":"la costumbre","english":"custom"},{"spanish":"el malentendido","english":"misunderstanding"},{"spanish":"chocar","english":"to clash"},{"spanish":"adaptarse","english":"to adapt"},{"spanish":"acostumbrarse","english":"to get used to"},{"spanish":"la mentalidad","english":"mentality"},{"spanish":"el estereotipo","english":"stereotype"}]'::jsonb,
    dialogue='[{"speaker":"Reflexión","spanish":"Lo que más me chocó al principio fue la sobremesa: una hora más conversando tras la comida, como mínimo.","english":"What shocked me most at first was the sobremesa: at least one more hour conversing after the meal."}]'::jsonb,
    grammar_note='"Lo que más me + verb + fue + noun" = "what + verb-ed me most was + noun". Sentence-initial focus for emotional impact.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "after-meal conversation"?','la sobremesa',array['el aperitivo','la merienda','la siesta'],'sobremesa',1),
  (v_l1,'multiple_choice','What does "a la española" mean?','Spanish style',array['to the Spanish (woman)','from Spanish','about Spain'],'Spanish style',2),
  (v_l1,'fill_blank','Complete: "Entiéndelo ____ española." (in style)','a la',array['en la','de la','con la'],'in style',3),
  (v_l1,'multiple_choice','What is "to extend (a meeting)"?','prolongarse',array['prolongar (transitive)','prolongado','progresar'],'to extend (reflex)',4),
  (v_l1,'multiple_choice','What is "the quarter of an hour"?','el cuarto de hora',array['la cuarta','el cuarto','el quart'],'quarter of an hour',5),
  (v_l2,'multiple_choice','What does "tutear" mean?','to use tú',array['to tutor','to tutelage','to take notes'],'use tú',1),
  (v_l2,'multiple_choice','What is "voseo"?','use of vos (Arg/Uru)',array['use of usted','use of vosotros','use of nosotros'],'voseo',2),
  (v_l2,'fill_blank','Complete: "Le ____ de usted por respeto." (speak)','hablo',array['hablaba','habló','hablaré'],'speak',3),
  (v_l2,'multiple_choice','What does "hablar de usted" mean?','to address as usted',array['to talk about you','to talk for you','to speak from you'],'address as usted',4),
  (v_l2,'multiple_choice','What is "manner of address"?','el trato',array['el truco','el trato (incorrect)','la trata'],'manner of address',5),
  (v_l3,'multiple_choice','What does "invitar" specially mean here?','to treat (pay)',array['to invite only','to send invitation','to make formal'],'to treat (pay)',1),
  (v_l3,'multiple_choice','What is "host"?','el anfitrión',array['el hostal','el huésped','el husmeador'],'host',2),
  (v_l3,'fill_blank','Complete: "Hoy os ____ yo." (treat — tú+pl)','invito',array['inviten','inviten (incorrect)','inviten'],'treat (yo)',3),
  (v_l3,'multiple_choice','What is "appetizer"?','el aperitivo',array['el apetito','el ápice','el apretón'],'appetizer',4),
  (v_l3,'multiple_choice','What is "afternoon snack"?','la merienda',array['el almuerzo','la cena','la siesta'],'afternoon snack',5),
  (v_l4,'multiple_choice','What does "qué va" mean?','no way',array['what goes','where to','what for'],'no way',1),
  (v_l4,'multiple_choice','What does "no es para tanto" mean?','it''s not that big a deal',array['it''s not enough','it''s not much','it''s not all'],'not that big a deal',2),
  (v_l4,'fill_blank','Complete: "Me ____ mucho por aprender." (remains)','queda',array['quedo','quedaba','quedará'],'remains',3),
  (v_l4,'multiple_choice','What is "compliment"?','el cumplido',array['el cumple','el complejo','el complot'],'compliment',4),
  (v_l4,'multiple_choice','What does "ruborizarse" mean?','to blush',array['to ruin','to revere','to remain'],'to blush',5),
  (v_l5,'multiple_choice','What does "con sorna" mean?','with mockery',array['with sorrow','with skill','with stretching'],'with mockery',1),
  (v_l5,'multiple_choice','What is "double meaning"?','el doble sentido',array['el sentido doble','el doble significado','el doble sentido (incorrect)'],'double meaning',2),
  (v_l5,'fill_blank','Complete: "Tomárselo a ____" (joke)','broma',array['broma (incorrect)','bromear','bromas'],'as joke',3),
  (v_l5,'multiple_choice','What is "wordplay"?','el juego de palabras',array['el juego de letras','el juego verbal','el truco'],'wordplay',4),
  (v_l5,'multiple_choice','What is "joke (short)"?','el chiste',array['la broma','el cuento','la sonrisa'],'short joke',5),
  (v_l6,'multiple_choice','What does "sobreentender" mean?','to understand implicitly',array['to over-understand','to understand more','to misunderstand'],'understand implicitly',1),
  (v_l6,'multiple_choice','Quotes around an adjective often signal what?','irony',array['emphasis','formality','title'],'irony',2),
  (v_l6,'fill_blank','Complete: "Vino el jefe, ____" (with ironic quotes)','majísimo',array['horrible','enfadado','genial'],'majísimo (ironic)',3),
  (v_l6,'multiple_choice','What does "ya, ya" doubled mean?','I get it / message received',array['yes, yes (literal)','already, already','done, done'],'I get it',4),
  (v_l6,'multiple_choice','What is "to read between lines"?','leer entre líneas',array['leer entre líneas (incorrect)','leer entre el texto','leer por encima'],'read between lines',5),
  (v_l7,'multiple_choice','What does "chocar" mean here?','to clash (culturally)',array['to crash (vehicle)','to chop','to choke'],'to clash',1),
  (v_l7,'multiple_choice','What is "stereotype"?','el estereotipo',array['el esteriotipo','el estereo','el esterotipo'],'stereotype',2),
  (v_l7,'fill_blank','Complete: "Lo que más me ____ fue la sobremesa." (shocked)','chocó',array['chocaba','choca','chocará'],'shocked',3),
  (v_l7,'multiple_choice','What is "to get used to"?','acostumbrarse',array['acostumbrar (transitive)','costumbre','costumbroso'],'get used to',4),
  (v_l7,'multiple_choice','What is "mentality"?','la mentalidad',array['la mentira','la mentalidad (incorrect)','la mente'],'mentality',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','A qué hora exactamente debo llegar a la cena',array['Te dije las nueve','Entiéndelo a la española','Nueve y media, mejor'],'At what time exactly should I arrive for dinner',6),
  (v_l1,'listening','What did you hear?','Entiéndelo a la española: nueve y media, mejor',array['Llega puntual','Llega tarde','Llega temprano'],'Understand it in Spanish style: nine-thirty, better',7),
  (v_l1,'speaking','Say this aloud: "Entiéndelo a la española."','Entiéndelo a la española',array[]::text[],'Understand it in Spanish style.',8),
  (v_l1,'speaking','Say this aloud: "Nueve y media, mejor."','Nueve y media, mejor',array[]::text[],'Nine-thirty, better.',9),
  (v_l2,'listening','What did you hear?','Aunque sea más joven, le hablo de usted por respeto',array['Tuteo a todos','Uso voseo aquí','El trato cambia'],'Even though he''s younger, I address him formally out of respect',6),
  (v_l2,'listening','What did you hear?','le hablo de usted por respeto',array['le hablo de tú por confianza','le hablo de vos por costumbre','no le hablo nunca'],'I address him formally out of respect',7),
  (v_l2,'speaking','Say this aloud: "Le hablo de usted por respeto."','Le hablo de usted por respeto',array[]::text[],'I address him as usted out of respect.',8),
  (v_l2,'speaking','Say this aloud: "Le hablo de tú por confianza."','Le hablo de tú por confianza',array[]::text[],'I address him as tú due to familiarity.',9),
  (v_l3,'listening','What did you hear?','Sentaos y tomad lo que queráis',array['Hoy os invito yo','El aperitivo está listo','Pasad a la mesa'],'Sit down and have what you want',6),
  (v_l3,'listening','What did you hear?','Hoy os invito yo',array['Hoy yo pago','Hoy es gratis','Hoy es vuestro'],'Today I''m treating',7),
  (v_l3,'speaking','Say this aloud: "Hoy os invito yo."','Hoy os invito yo',array[]::text[],'Today I''m treating.',8),
  (v_l3,'speaking','Say this aloud: "Pasemos a la mesa."','Pasemos a la mesa',array[]::text[],'Let''s go to the table.',9),
  (v_l6,'listening','What did you hear?','Vino el jefe, "majísimo", como siempre',array['Ya, ya. Te entiendo','El jefe es genial','Hubo mucha tensión'],'The boss came, "wonderful", as always',6),
  (v_l6,'listening','What did you hear?','Ya, ya. Te entiendo perfectamente',array['Vino el jefe','Como siempre, sí','No entiendo nada'],'Yeah, yeah. I get you perfectly',7),
  (v_l6,'speaking','Say this aloud: "Ya, ya, te entiendo."','Ya, ya, te entiendo',array[]::text[],'Yeah, yeah, I get you.',8),
  (v_l6,'speaking','Say this aloud: "Vino el jefe, "majísimo"."','Vino el jefe, "majísimo"',array[]::text[],'The boss came, "wonderful".',9),
  (v_l7,'listening','What did you hear?','Lo que más me chocó al principio fue la sobremesa',array['Una hora más conversando tras la comida','Como mínimo','Tras la comida'],'What shocked me most at first was the sobremesa',6),
  (v_l7,'listening','What did you hear?','una hora más conversando tras la comida, como mínimo',array['poco tiempo en la mesa','sin sobremesa','sin postres'],'at least one more hour conversing after the meal',7),
  (v_l7,'speaking','Say this aloud: "Lo que más me chocó fue la sobremesa."','Lo que más me chocó fue la sobremesa',array[]::text[],'What shocked me most was the sobremesa.',8),
  (v_l7,'speaking','Say this aloud: "Una hora conversando, como mínimo."','Una hora conversando, como mínimo',array[]::text[],'An hour conversing, at least.',9);

  update public.lessons set type='conversation', title='Cultural Nuance — Conversation Practice',
    description='Two friends discuss culture shock.',
    intro='Anna (an expat) talks with her local friend Lola.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Anna","spanish":"Llevo tres años aquí y todavía me cuesta acostumbrarme a la hora de la cena.","english":"I''ve been here three years and I still struggle to get used to dinner time."},{"speaker":"Lola","spanish":"Qué va. En tres años ya tienes que estar adaptada.","english":"No way. In three years you must already be adapted."},{"speaker":"Anna","spanish":"Y lo que más me chocó al principio fue la sobremesa.","english":"And what shocked me most at first was the sobremesa."},{"speaker":"Lola","spanish":"Sí, aquí prolongamos la comida una hora más, como mínimo.","english":"Yes, here we extend the meal at least one more hour."},{"speaker":"Anna","spanish":"Y aprendí a entender el tono — cuando alguien dice "majísimo" con sorna.","english":"And I learned to understand the tone — when someone says "wonderful" mockingly."},{"speaker":"Lola","spanish":"Ya, ya. Eso es señal de que has llegado de verdad.","english":"Yeah, yeah. That''s a sign you''ve truly arrived."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','How long has Anna been there?','Three years',array['One year','Five years','Ten years'],'tres años',1),
  (v_l8,'multiple_choice','What does she still struggle with?','Getting used to dinner time',array['The language','The food','The weather'],'la hora de la cena',2),
  (v_l8,'multiple_choice','Lola''s reaction?','Dismissive (qué va)',array['Sympathetic','Confused','Angry'],'qué va',3),
  (v_l8,'multiple_choice','What shocked Anna most?','The sobremesa',array['Punctuality','Music','Food spice'],'lo que más me chocó fue la sobremesa',4),
  (v_l8,'fill_blank','Complete: "Lo que más me ____ al principio." (shocked)','chocó',array['chocaba','choca','chocará'],'shocked',5),
  (v_l8,'multiple_choice','Lola''s closing assessment?','Sign Anna has truly arrived',array['Sign she''s still a tourist','Sign she should leave','Sign she''s lost'],'señal de que has llegado',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Cultural Nuance', 'Review test for the Cultural Nuance section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "sobremesa"?','after-meal conversation',array['table setting','appetizer','dessert'],'sobremesa',1),
  (v_lesson_id,'multiple_choice','What does "qué va" mean?','no way',array['what goes','where to','what for'],'no way',2),
  (v_lesson_id,'multiple_choice','What does "invitar" specially mean?','to treat (pay)',array['to invite only','to send invitation','to make formal'],'to treat',3),
  (v_lesson_id,'multiple_choice','What does "con sorna" mean?','with mockery',array['with sorrow','with skill','with stretching'],'with mockery',4),
  (v_lesson_id,'fill_blank','Complete: "Entiéndelo ____ española." (in style)','a la',array['en la','de la','con la'],'in style',5),
  (v_lesson_id,'fill_blank','Complete: "Lo que más me ____ fue la sobremesa." (shocked)','chocó',array['chocaba','choca','chocará'],'shocked',6),
  (v_lesson_id,'listening','What did you hear?','Hoy os invito yo',array['Aunque sea más joven','Le hablo de usted','La sobremesa es larga'],'Today I''m treating',7),
  (v_lesson_id,'listening','What did you hear?','Vino el jefe, "majísimo", como siempre',array['Te entiendo perfectamente','Ya, ya, ya','El jefe es agradable'],'The boss came, "wonderful", as always',8),
  (v_lesson_id,'speaking','Say this aloud: "Lo que más me chocó fue la sobremesa."','Lo que más me chocó fue la sobremesa',array[]::text[],'What shocked me most was the sobremesa.',9),
  (v_lesson_id,'speaking','Say this aloud: "Hoy os invito yo."','Hoy os invito yo',array[]::text[],'Today I''m treating.',10);

  -- ===========================================================
  -- C1.9 RHETORIC & PERSUASION
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'C1' and title = 'Rhetoric & Persuasion';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='Rhetorical figures: metaphor, simile, hyperbole. Master "es como si", "tan X como", "ni más ni menos".',
    vocab_items='[{"spanish":"la retórica","english":"rhetoric"},{"spanish":"la figura retórica","english":"rhetorical figure"},{"spanish":"la metáfora","english":"metaphor"},{"spanish":"el símil","english":"simile"},{"spanish":"la hipérbole","english":"hyperbole"},{"spanish":"la anáfora","english":"anaphora"},{"spanish":"la pregunta retórica","english":"rhetorical question"},{"spanish":"ni más ni menos","english":"no more no less"},{"spanish":"es como si","english":"it''s as if"},{"spanish":"tan X como Y","english":"as X as Y"}]'::jsonb,
    dialogue='[{"speaker":"Orador","spanish":"La libertad es como el aire: solo se nota cuando falta.","english":"Freedom is like air: you only notice it when it''s missing."}]'::jsonb,
    grammar_note='"Como + noun" forms a simile: "como el aire", "como la lluvia". The two terms must share a relevant quality — in this case, presence-when-absent.'
  where id = v_l1;

  update public.lessons set
    intro='Persuasion tactics: ethos, pathos, logos. Spanish rhetoric uses all three explicitly.',
    vocab_items='[{"spanish":"la persuasión","english":"persuasion"},{"spanish":"persuadir","english":"to persuade"},{"spanish":"convencer","english":"to convince"},{"spanish":"la credibilidad","english":"credibility"},{"spanish":"la emoción","english":"emotion"},{"spanish":"la razón","english":"reason"},{"spanish":"apelar a","english":"to appeal to"},{"spanish":"el llamamiento","english":"call/appeal"},{"spanish":"el sentido común","english":"common sense"}]'::jsonb,
    dialogue='[{"speaker":"Orador","spanish":"Apelo al sentido común de todos ustedes: no podemos quedarnos de brazos cruzados.","english":"I appeal to the common sense of all of you: we cannot stand by with arms crossed."}]'::jsonb,
    grammar_note='"Quedarse de brazos cruzados" = "to stand by idly". A vivid idiom. Variants: "no quedarse de brazos cruzados" = "to act/take action".'
  where id = v_l2;

  update public.lessons set
    intro='Speeches: opening, building, climax, closing. Famous Spanish-speaking orators.',
    vocab_items='[{"spanish":"el discurso","english":"speech"},{"spanish":"el orador","english":"orator"},{"spanish":"la oratoria","english":"oratory"},{"spanish":"la elocuencia","english":"eloquence"},{"spanish":"conmover","english":"to move (emotionally)"},{"spanish":"el clímax","english":"climax"},{"spanish":"culminar","english":"to culminate"},{"spanish":"arrancar","english":"to start (powerfully)"},{"spanish":"el público","english":"audience"},{"spanish":"cautivar","english":"to captivate"}]'::jsonb,
    dialogue='[{"speaker":"Crítica","spanish":"El discurso arrancó con una pregunta retórica que cautivó al público desde el primer instante.","english":"The speech opened with a rhetorical question that captivated the audience from the first instant."}]'::jsonb,
    grammar_note='"Desde el primer instante" = "from the first instant". Compare with "desde el principio" (from the beginning) — "instante" emphasizes immediacy.'
  where id = v_l3;

  update public.lessons set
    intro='Repetition for effect: anaphora, parallelism. "Hoy luchamos por X, hoy luchamos por Y, hoy luchamos por Z".',
    vocab_items='[{"spanish":"la repetición","english":"repetition"},{"spanish":"el paralelismo","english":"parallelism"},{"spanish":"insistir","english":"to insist"},{"spanish":"reiterar","english":"to reiterate"},{"spanish":"el énfasis","english":"emphasis"},{"spanish":"enfatizar","english":"to emphasize"},{"spanish":"machacar","english":"to drum in"},{"spanish":"el martilleo","english":"hammering"},{"spanish":"la cadencia","english":"cadence"}]'::jsonb,
    dialogue='[{"speaker":"Discurso","spanish":"Hoy luchamos por la libertad, hoy luchamos por la igualdad, hoy luchamos por la justicia.","english":"Today we fight for freedom, today we fight for equality, today we fight for justice."}]'::jsonb,
    grammar_note='Anaphora: repetition of the same words at the beginning of successive clauses. "Hoy luchamos..." repeated three times for emphatic effect.'
  where id = v_l4;

  update public.lessons set
    intro='Rhetorical questions: "¿acaso no merecemos...?", "¿quién no quisiera...?". They invite agreement without expecting answers.',
    vocab_items='[{"spanish":"la pregunta retórica","english":"rhetorical question"},{"spanish":"acaso","english":"perchance/by any chance"},{"spanish":"quién no","english":"who wouldn''t"},{"spanish":"merecer","english":"to deserve"},{"spanish":"el derecho","english":"right"},{"spanish":"la dignidad","english":"dignity"},{"spanish":"interpelar","english":"to interpellate (challenge)"},{"spanish":"sugerir","english":"to suggest"}]'::jsonb,
    dialogue='[{"speaker":"Orador","spanish":"¿Acaso no merecemos un futuro mejor? ¿Quién entre nosotros quisiera lo contrario?","english":"Do we not perchance deserve a better future? Who among us would want the contrary?"}]'::jsonb,
    grammar_note='"Acaso" precedes a question expressing rhetorical doubt. "Quién + conditional/imperfect subjunctive" forms emphatic rhetorical questions: "quién quisiera" (who would want).'
  where id = v_l5;

  update public.lessons set
    intro='Listen to a political speech. Notice the cadence, rises and falls, emotional peaks.',
    vocab_items='[{"spanish":"el discurso político","english":"political speech"},{"spanish":"la cadencia","english":"cadence"},{"spanish":"la pausa","english":"pause"},{"spanish":"el énfasis","english":"emphasis"},{"spanish":"el aplauso","english":"applause"},{"spanish":"la ovación","english":"ovation"},{"spanish":"el clímax","english":"climax"}]'::jsonb,
    dialogue='[{"speaker":"Orador","spanish":"Compañeros... hoy es un día histórico. Hoy decidimos quiénes queremos ser.","english":"Comrades... today is a historic day. Today we decide who we want to be."}]'::jsonb,
    grammar_note='"Quiénes queremos ser" — interrogative "quiénes" inside a declarative ("hoy decidimos quiénes..."). The accent on "quiénes" marks the embedded question.'
  where id = v_l6;

  update public.lessons set
    intro='Write a brief persuasive piece. Choose 2-3 rhetorical devices and apply them.',
    vocab_items='[{"spanish":"el texto persuasivo","english":"persuasive text"},{"spanish":"el manifiesto","english":"manifesto"},{"spanish":"la columna","english":"column"},{"spanish":"el editorial","english":"editorial"},{"spanish":"argumentar","english":"to argue"},{"spanish":"convencer","english":"to convince"},{"spanish":"la conclusión potente","english":"powerful conclusion"}]'::jsonb,
    dialogue='[{"speaker":"Editorial","spanish":"No podemos quedarnos de brazos cruzados. No podemos esperar a que otros decidan. No podemos permitirnos el lujo del silencio.","english":"We cannot stand by with arms crossed. We cannot wait for others to decide. We cannot afford the luxury of silence."}]'::jsonb,
    grammar_note='Triple anaphora: "no podemos... no podemos... no podemos...". Each iteration builds urgency. The triple structure is rhetorically standard.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "metaphor"?','la metáfora',array['la similitud','el símil','la analogía'],'metaphor',1),
  (v_l1,'multiple_choice','What is "simile"?','el símil',array['la metáfora','la similar','el simio'],'simile',2),
  (v_l1,'fill_blank','Complete: "La libertad es ____ el aire." (like)','como',array['así','tal','cual'],'like',3),
  (v_l1,'multiple_choice','What does "ni más ni menos" mean?','no more no less',array['neither nor','either or','more less'],'no more no less',4),
  (v_l1,'multiple_choice','What is "hyperbole"?','la hipérbole',array['la hipérbola','la hipocresía','la hipoteca'],'hyperbole',5),
  (v_l2,'multiple_choice','What does "apelar a" mean?','to appeal to',array['to appeal at','to appeal in','to appeal for'],'to appeal to',1),
  (v_l2,'multiple_choice','What does "quedarse de brazos cruzados" mean?','to stand by idly',array['to be in jail','to be lazy','to be tied up'],'stand by idly',2),
  (v_l2,'fill_blank','Complete: "Apelo ____ sentido común." (to the)','al',array['el','del','en el'],'to the',3),
  (v_l2,'multiple_choice','What is "credibility"?','la credibilidad',array['la credibilidad (incorrect)','la creencia','la credulidad'],'credibility',4),
  (v_l2,'multiple_choice','What is "common sense"?','el sentido común',array['el común sentido','el sentido normal','el sentido público'],'common sense',5),
  (v_l3,'multiple_choice','What does "arrancar" mean here?','to start (powerfully)',array['to uproot','to tear','to rip'],'to start',1),
  (v_l3,'multiple_choice','What does "cautivar" mean?','to captivate',array['to capture','to caution','to capitalize'],'captivate',2),
  (v_l3,'fill_blank','Complete: "Desde el ____ instante." (first)','primer',array['primero','primera','primarios'],'first (apocopated)',3),
  (v_l3,'multiple_choice','What is "orator"?','el orador',array['el ordenador','el orden','el orfanato'],'orator',4),
  (v_l3,'multiple_choice','What does "culminar" mean?','to culminate',array['to cultivate','to cumulate','to curl'],'culminate',5),
  (v_l4,'multiple_choice','What does "machacar" mean here?','to drum in (idea)',array['to smash physically','to mash','to crush'],'to drum in',1),
  (v_l4,'multiple_choice','What is "anaphora"?','la anáfora',array['la metáfora','la antítesis','la analogía'],'anaphora',2),
  (v_l4,'fill_blank','Complete: "____ luchamos por la libertad." (today)','Hoy',array['Hoy (incorrect)','Aquí','Ahí'],'today',3),
  (v_l4,'multiple_choice','What is "emphasis"?','el énfasis',array['el enfático','el ánfora','el éxtasis'],'emphasis',4),
  (v_l4,'multiple_choice','What is "to reiterate"?','reiterar',array['repetir (synonym)','recuperar','reciclar'],'to reiterate',5),
  (v_l5,'multiple_choice','What does "acaso" introduce?','rhetorical question',array['factual statement','order','wish'],'rhetorical question',1),
  (v_l5,'multiple_choice','What does "interpelar" mean?','to challenge (formal)',array['to interrupt','to intercept','to intercede'],'to challenge',2),
  (v_l5,'fill_blank','Complete: "Quién ____ lo contrario?" (would want — imperf subj)','quisiera',array['quiere','quería','querría'],'would want (subj)',3),
  (v_l5,'multiple_choice','What does "merecer" mean?','to deserve',array['to merge','to mercy','to mercerize'],'to deserve',4),
  (v_l5,'multiple_choice','What is "dignity"?','la dignidad',array['la digno','la digna','la dignación'],'dignity',5),
  (v_l6,'multiple_choice','What is "ovation"?','la ovación',array['la ovalada','la ovejera','la oveja'],'ovation',1),
  (v_l6,'multiple_choice','What does "compañeros" suggest in a speech?','comrades / fellow members',array['classmates only','employees only','strangers'],'comrades',2),
  (v_l6,'fill_blank','Complete: "Hoy decidimos ____ queremos ser." (who — embedded Q)','quiénes',array['quien','que','cual'],'who (embedded Q)',3),
  (v_l6,'multiple_choice','What does "histórico" mean here?','historic (significant)',array['historical (academic)','historian','history-related'],'historic',4),
  (v_l6,'multiple_choice','What is "applause"?','el aplauso',array['el alabar','el applauso','el apladar'],'applause',5),
  (v_l7,'multiple_choice','What is "manifesto"?','el manifiesto',array['la manifestación','el manífico','el manífaire'],'manifesto',1),
  (v_l7,'multiple_choice','What does "permitirse el lujo de" mean?','to afford the luxury of',array['to permit luxury','to live in luxury','to ask for luxury'],'afford luxury of',2),
  (v_l7,'fill_blank','Complete: "No podemos ____ a que otros decidan." (wait)','esperar',array['esperando','esperar (incorrect)','esperaba'],'wait',3),
  (v_l7,'multiple_choice','What''s triple anaphora?','same word x3 at clause start',array['three different words','rhyming x3','question x3'],'triple anaphora',4),
  (v_l7,'multiple_choice','What is "powerful conclusion"?','la conclusión potente',array['la conclusión final','la conclusión fuerte','la conclusión grande'],'powerful conclusion',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','La libertad es como el aire: solo se nota cuando falta',array['La libertad es preciosa','El aire es esencial','Solo lo notas al perderlo'],'Freedom is like air: you only notice it when it''s missing',6),
  (v_l1,'listening','What did you hear?','solo se nota cuando falta',array['solo se nota al respirar','siempre se nota','nunca se pierde'],'you only notice it when it''s missing',7),
  (v_l1,'speaking','Say this aloud: "La libertad es como el aire."','La libertad es como el aire',array[]::text[],'Freedom is like air.',8),
  (v_l1,'speaking','Say this aloud: "Solo se nota cuando falta."','Solo se nota cuando falta',array[]::text[],'You only notice it when it''s missing.',9),
  (v_l2,'listening','What did you hear?','Apelo al sentido común de todos ustedes',array['No podemos quedarnos de brazos cruzados','El llamamiento es urgente','La credibilidad importa'],'I appeal to the common sense of all of you',6),
  (v_l2,'listening','What did you hear?','no podemos quedarnos de brazos cruzados',array['debemos actuar','tenemos que pensar','vamos a esperar'],'we cannot stand by with arms crossed',7),
  (v_l2,'speaking','Say this aloud: "Apelo al sentido común."','Apelo al sentido común',array[]::text[],'I appeal to common sense.',8),
  (v_l2,'speaking','Say this aloud: "No podemos quedarnos de brazos cruzados."','No podemos quedarnos de brazos cruzados',array[]::text[],'We cannot stand by with arms crossed.',9),
  (v_l3,'listening','What did you hear?','El discurso arrancó con una pregunta retórica',array['Que cautivó al público','Desde el primer instante','Una metáfora poderosa'],'The speech opened with a rhetorical question',6),
  (v_l3,'listening','What did you hear?','desde el primer instante',array['desde el principio','desde el final','desde el comienzo'],'from the first instant',7),
  (v_l3,'speaking','Say this aloud: "Arrancó con una pregunta retórica."','Arrancó con una pregunta retórica',array[]::text[],'It opened with a rhetorical question.',8),
  (v_l3,'speaking','Say this aloud: "Cautivó al público desde el primer instante."','Cautivó al público desde el primer instante',array[]::text[],'It captivated the audience from the first instant.',9),
  (v_l6,'listening','What did you hear?','Compañeros... hoy es un día histórico',array['Hoy decidimos quiénes queremos ser','El día de la victoria','El momento ha llegado'],'Comrades... today is a historic day',6),
  (v_l6,'listening','What did you hear?','Hoy decidimos quiénes queremos ser',array['Hoy luchamos por todo','El futuro nos llama','El pasado nos une'],'Today we decide who we want to be',7),
  (v_l6,'speaking','Say this aloud: "Hoy es un día histórico."','Hoy es un día histórico',array[]::text[],'Today is a historic day.',8),
  (v_l6,'speaking','Say this aloud: "Hoy decidimos quiénes queremos ser."','Hoy decidimos quiénes queremos ser',array[]::text[],'Today we decide who we want to be.',9),
  (v_l7,'listening','What did you hear?','No podemos quedarnos de brazos cruzados. No podemos esperar a que otros decidan',array['No podemos permitir el silencio','El momento de actuar es ahora','Hoy luchamos por todo'],'We cannot stand by. We cannot wait for others to decide',6),
  (v_l7,'listening','What did you hear?','No podemos permitirnos el lujo del silencio',array['No podemos esperar más','No podemos quedarnos quietos','No podemos faltar'],'We cannot afford the luxury of silence',7),
  (v_l7,'speaking','Say this aloud: "No podemos quedarnos de brazos cruzados."','No podemos quedarnos de brazos cruzados',array[]::text[],'We cannot stand by idly.',8),
  (v_l7,'speaking','Say this aloud: "No podemos permitirnos el lujo del silencio."','No podemos permitirnos el lujo del silencio',array[]::text[],'We cannot afford the luxury of silence.',9);

  update public.lessons set type='conversation', title='Rhetoric & Persuasion — Conversation Practice',
    description='A speechwriter coaches a candidate.',
    intro='Marisa helps Javier prepare a speech.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Marisa","spanish":"Arranca con una pregunta retórica. Algo que cautive al público desde el primer instante.","english":"Open with a rhetorical question. Something that captivates the audience from the first instant."},{"speaker":"Javier","spanish":"¿Algo así como "¿acaso no merecemos un futuro mejor?"?","english":"Something like "do we not deserve a better future?"?"},{"speaker":"Marisa","spanish":"Justo. Y después aplicas anáfora: hoy luchamos por X, hoy luchamos por Y.","english":"Exactly. And then you apply anaphora: today we fight for X, today we fight for Y."},{"speaker":"Javier","spanish":"¿Y la metáfora? Quiero comparar la justicia con el aire.","english":"And the metaphor? I want to compare justice to air."},{"speaker":"Marisa","spanish":"La justicia es como el aire: solo se nota cuando falta. Funciona.","english":"Justice is like air: you only notice it when it''s missing. It works."},{"speaker":"Javier","spanish":"Y cierro con un llamamiento: no podemos quedarnos de brazos cruzados.","english":"And I close with a call: we cannot stand by with arms crossed."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','How should the speech open?','With a rhetorical question',array['With a statistic','With a thank-you','With a quote'],'pregunta retórica',1),
  (v_l8,'multiple_choice','What rhetorical figure follows?','Anaphora',array['Metaphor','Simile','Hyperbole'],'anáfora',2),
  (v_l8,'multiple_choice','Javier''s metaphor?','Compare justice to air',array['Compare freedom to bread','Compare hope to fire','Compare truth to light'],'comparar la justicia con el aire',3),
  (v_l8,'multiple_choice','Marisa''s verdict on the metaphor?','It works',array['It''s weak','It''s overused','It''s wrong'],'funciona',4),
  (v_l8,'fill_blank','Complete: "Acaso no ____ un futuro mejor." (deserve)','merecemos',array['merecíamos','merecimos','merezcamos'],'deserve',5),
  (v_l8,'multiple_choice','Speech closing?','Call to action: no idleness',array['Personal anecdote','Thank-you','Joke'],'no podemos quedarnos de brazos cruzados',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Rhetoric & Persuasion', 'Review test for the Rhetoric & Persuasion section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "metaphor"?','la metáfora',array['la similitud','el símil','la analogía'],'metaphor',1),
  (v_lesson_id,'multiple_choice','What does "apelar a" mean?','to appeal to',array['to appeal at','to appeal in','to appeal for'],'appeal to',2),
  (v_lesson_id,'multiple_choice','What does "quedarse de brazos cruzados" mean?','to stand by idly',array['to be in jail','to be lazy','to be tied up'],'stand by idly',3),
  (v_lesson_id,'multiple_choice','What is "anaphora"?','la anáfora',array['la metáfora','la antítesis','la analogía'],'anaphora',4),
  (v_lesson_id,'fill_blank','Complete: "La libertad es ____ el aire." (like)','como',array['así','tal','cual'],'like',5),
  (v_lesson_id,'fill_blank','Complete: "Quién ____ lo contrario?" (would want — subj)','quisiera',array['quiere','quería','querría'],'would want (subj)',6),
  (v_lesson_id,'listening','What did you hear?','La libertad es como el aire: solo se nota cuando falta',array['No podemos quedarnos de brazos','Hoy es un día histórico','El discurso arrancó con'],'Freedom is like air: you only notice it when it''s missing',7),
  (v_lesson_id,'listening','What did you hear?','No podemos quedarnos de brazos cruzados',array['Acaso no merecemos','Hoy luchamos por todo','Apelo al sentido común'],'We cannot stand by with arms crossed',8),
  (v_lesson_id,'speaking','Say this aloud: "Apelo al sentido común."','Apelo al sentido común',array[]::text[],'I appeal to common sense.',9),
  (v_lesson_id,'speaking','Say this aloud: "La libertad es como el aire."','La libertad es como el aire',array[]::text[],'Freedom is like air.',10);

  -- ===========================================================
  -- C1.10 ADVANCED LITERATURE
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'C1' and title = 'Advanced Literature';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='Spanish Golden Age literature: Cervantes, Lope de Vega, Quevedo. Key concepts: el Siglo de Oro, la picaresca.',
    vocab_items='[{"spanish":"el Siglo de Oro","english":"the Golden Age"},{"spanish":"la novela picaresca","english":"picaresque novel"},{"spanish":"el conceptismo","english":"conceptismo"},{"spanish":"el culteranismo","english":"culteranismo (gongorism)"},{"spanish":"la sátira","english":"satire"},{"spanish":"la parodia","english":"parody"},{"spanish":"el hidalgo","english":"low nobleman"},{"spanish":"el ingenioso","english":"the ingenious one"},{"spanish":"la caballería","english":"chivalry"}]'::jsonb,
    dialogue='[{"speaker":"Profesor","spanish":"Cervantes, cuya obra cumbre es "El Quijote", parodió las novelas de caballería.","english":"Cervantes, whose masterpiece is ''Don Quixote'', parodied chivalric novels."}]'::jsonb,
    grammar_note='"Cuya obra cumbre" = "whose masterpiece". "Cumbre" as adjective means "supreme/peak". The agreement: "cuya" (fem) + "obra cumbre" (fem).'
  where id = v_l1;

  update public.lessons set
    intro='Magical realism: García Márquez, Allende, Carpentier. Hallmark of Latin American letters.',
    vocab_items='[{"spanish":"el realismo mágico","english":"magical realism"},{"spanish":"el boom latinoamericano","english":"the Latin American boom"},{"spanish":"lo real maravilloso","english":"the marvelous real"},{"spanish":"el linaje","english":"lineage"},{"spanish":"la saga familiar","english":"family saga"},{"spanish":"el destino","english":"destiny"},{"spanish":"la cosmovisión","english":"worldview"},{"spanish":"la oralidad","english":"orality"},{"spanish":"sobrenatural","english":"supernatural"}]'::jsonb,
    dialogue='[{"speaker":"Crítica","spanish":"En "Cien años de soledad", la familia Buendía está condenada a un destino del cual no puede escapar.","english":"In ''One Hundred Years of Solitude'', the Buendía family is condemned to a destiny from which it cannot escape."}]'::jsonb,
    grammar_note='"Del cual / de la cual" — formal relative pronoun for prepositional objects. "Del cual no puede escapar" = "from which it cannot escape".'
  where id = v_l2;

  update public.lessons set
    intro='Poetry: el romance, el soneto, el haiku. Spanish poetry has a rich metrical tradition.',
    vocab_items='[{"spanish":"el poema","english":"poem"},{"spanish":"el verso","english":"verse/line"},{"spanish":"la estrofa","english":"stanza"},{"spanish":"la rima","english":"rhyme"},{"spanish":"el metro","english":"meter"},{"spanish":"el endecasílabo","english":"hendecasyllable"},{"spanish":"el soneto","english":"sonnet"},{"spanish":"el romance","english":"ballad"},{"spanish":"el haiku","english":"haiku"}]'::jsonb,
    dialogue='[{"speaker":"Profesor","spanish":"El soneto consta de catorce versos endecasílabos distribuidos en dos cuartetos y dos tercetos.","english":"The sonnet consists of fourteen hendecasyllabic verses distributed in two quatrains and two tercets."}]'::jsonb,
    grammar_note='"Constar de + noun" = "to consist of + noun". Useful for describing composition: "el libro consta de tres partes".'
  where id = v_l3;

  update public.lessons set
    intro='Literary analysis: narrator, plot, character, theme, motif. Spanish has its own analytical vocabulary.',
    vocab_items='[{"spanish":"el narrador","english":"narrator"},{"spanish":"la trama","english":"plot"},{"spanish":"el personaje","english":"character"},{"spanish":"el tema","english":"theme"},{"spanish":"el motivo","english":"motif"},{"spanish":"la atmósfera","english":"atmosphere"},{"spanish":"el simbolismo","english":"symbolism"},{"spanish":"el desdoblamiento","english":"split (of self)"},{"spanish":"el monólogo interior","english":"interior monologue"}]'::jsonb,
    dialogue='[{"speaker":"Analista","spanish":"El narrador omnisciente nos ofrece acceso a la psique del protagonista mediante el monólogo interior.","english":"The omniscient narrator offers us access to the protagonist''s psyche through interior monologue."}]'::jsonb,
    grammar_note='"Mediante + noun" = "through/by means of + noun". More formal than "por medio de" or "con". Common in academic literary criticism.'
  where id = v_l4;

  update public.lessons set
    intro='Contemporary novels: from "Boom" to post-boom. Roberto Bolaño, Almudena Grandes, Javier Marías.',
    vocab_items='[{"spanish":"el postboom","english":"post-boom"},{"spanish":"la novela negra","english":"crime/noir novel"},{"spanish":"la novela histórica","english":"historical novel"},{"spanish":"la autoficción","english":"autofiction"},{"spanish":"el ensayo literario","english":"literary essay"},{"spanish":"el premio","english":"award"},{"spanish":"el Cervantes","english":"the Cervantes Prize"},{"spanish":"el galardonado","english":"the awardee"}]'::jsonb,
    dialogue='[{"speaker":"Reseña","spanish":"Bolaño, galardonado postmortem con varios premios, dejó una obra inacabada de proporciones míticas.","english":"Bolaño, awarded posthumously with various prizes, left an unfinished work of mythical proportions."}]'::jsonb,
    grammar_note='"Postmortem" = "after death" (Latin). Used in Spanish without modification. Compare: "póstumo/a" (Spanish adjective for the same idea).'
  where id = v_l5;

  update public.lessons set
    intro='Listen to a literary lecture. The professor reads excerpts and analyzes them.',
    vocab_items='[{"spanish":"el fragmento","english":"fragment"},{"spanish":"el extracto","english":"excerpt"},{"spanish":"recitar","english":"to recite"},{"spanish":"declamar","english":"to declaim"},{"spanish":"la prosa","english":"prose"},{"spanish":"la cadencia","english":"cadence"},{"spanish":"el ritmo","english":"rhythm"}]'::jsonb,
    dialogue='[{"speaker":"Profesora","spanish":"Escuchen este fragmento: "En un lugar de la Mancha, de cuyo nombre no quiero acordarme...".","english":"Listen to this fragment: ''In a place of La Mancha, whose name I do not wish to remember...''."},{"speaker":"Profesora","spanish":"La cadencia anuncia el tono burlesco de toda la obra.","english":"The cadence announces the burlesque tone of the entire work."}]'::jsonb,
    grammar_note='"De cuyo nombre no quiero acordarme" — relative clause with preposition: "de" + "cuyo" + noun. The "no quiero" with subjunctive ("acordarme") shows narrative agency.'
  where id = v_l6;

  update public.lessons set
    intro='Write a brief literary analysis. Choose a passage, identify devices, explain their effect.',
    vocab_items='[{"spanish":"el análisis literario","english":"literary analysis"},{"spanish":"identificar","english":"to identify"},{"spanish":"justificar","english":"to justify"},{"spanish":"el efecto","english":"effect"},{"spanish":"el recurso","english":"device"},{"spanish":"la influencia","english":"influence"},{"spanish":"contextualizar","english":"to contextualize"}]'::jsonb,
    dialogue='[{"speaker":"Análisis","spanish":"García Márquez emplea la prolepsis al revelar, desde la primera línea, que el coronel iba a recordar aquella tarde frente al pelotón de fusilamiento.","english":"García Márquez employs prolepsis by revealing, from the first line, that the colonel was going to remember that afternoon facing the firing squad."}]'::jsonb,
    grammar_note='"Iba a + infinitive" = "was going to + verb". The imperfect of "ir" + "a" + infinitive expresses future in the past. Iconic opening of "Cien años de soledad".'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "Golden Age"?','el Siglo de Oro',array['el Siglo Dorado','el Siglo Oro','el Era de Oro'],'Golden Age',1),
  (v_l1,'multiple_choice','What does "parodiar" mean?','to parody',array['to participate','to parade','to part'],'to parody',2),
  (v_l1,'fill_blank','Complete: "Cervantes, ____ obra cumbre es El Quijote." (whose - fem)','cuya',array['cuyo','cuyas','cuyos'],'whose (fem)',3),
  (v_l1,'multiple_choice','What is "picaresque novel"?','la novela picaresca',array['la picaresque novel','la novela del pícaro','la novela picaresca (incorrect)'],'picaresque novel',4),
  (v_l1,'multiple_choice','What does "ingenioso" mean?','ingenious',array['ingenuous','indigenous','industrious'],'ingenious',5),
  (v_l2,'multiple_choice','What is "magical realism"?','el realismo mágico',array['el mágico realismo','el real mágico','el realismo de magia'],'magical realism',1),
  (v_l2,'multiple_choice','What is "the Boom"?','el boom latinoamericano',array['el explosion','el boom de Latinoamérica','el boom de Latin Am'],'the boom',2),
  (v_l2,'fill_blank','Complete: "Un destino del ____ no puede escapar." (which)','cual',array['que','quien','el que'],'which (formal)',3),
  (v_l2,'multiple_choice','What is "lineage"?','el linaje',array['el linage','el lino','el liñe'],'lineage',4),
  (v_l2,'multiple_choice','What does "sobrenatural" mean?','supernatural',array['supersonic','superfluous','supplementary'],'supernatural',5),
  (v_l3,'multiple_choice','How many verses in a sonnet?','14',array['12','16','10'],'14 verses',1),
  (v_l3,'multiple_choice','What is "stanza"?','la estrofa',array['el verso','el metro','la rima'],'stanza',2),
  (v_l3,'fill_blank','Complete: "El soneto ____ de catorce versos." (consists)','consta',array['contiene','tiene','es'],'consists',3),
  (v_l3,'multiple_choice','What is "ballad"?','el romance',array['el balada','el roman','el cantar'],'ballad',4),
  (v_l3,'multiple_choice','What is "hendecasyllable"?','el endecasílabo',array['el dodecasílabo','el heptasílabo','el octosílabo'],'hendecasyllable',5),
  (v_l4,'multiple_choice','What is "narrator"?','el narrador',array['el contador','el cuentista','el novelista'],'narrator',1),
  (v_l4,'multiple_choice','What is "interior monologue"?','el monólogo interior',array['el diálogo interior','el monólogo interno','el soliloquio'],'interior monologue',2),
  (v_l4,'fill_blank','Complete: "Acceso ____ el monólogo." (through)','mediante',array['por','con','en'],'through',3),
  (v_l4,'multiple_choice','What is "motif"?','el motivo',array['el motor','el moto','el motivado'],'motif',4),
  (v_l4,'multiple_choice','What is "split (of self)"?','el desdoblamiento',array['el doble','el doblado','el desdoble'],'split of self',5),
  (v_l5,'multiple_choice','What is "noir novel"?','la novela negra',array['la noir','la novela de crimen','la novela detective'],'noir novel',1),
  (v_l5,'multiple_choice','What is "autofiction"?','la autoficción',array['la autobiografía','la autocrítica','la autoficcionalización'],'autofiction',2),
  (v_l5,'fill_blank','Complete: "Galardonado ____ con varios premios." (posthumously - Latin)','postmortem',array['postal','poste','posterior'],'posthumously',3),
  (v_l5,'multiple_choice','What is "the Cervantes Prize"?','el Cervantes',array['el Premio Cervantes (synonym)','el Cervantino','el Cervantísimo'],'Cervantes Prize',4),
  (v_l5,'multiple_choice','What is "awardee"?','el galardonado',array['el premiador','el premiero','el galardón'],'awardee',5),
  (v_l6,'multiple_choice','What is "fragment"?','el fragmento',array['el fragmente','el flecho','el fracaso'],'fragment',1),
  (v_l6,'multiple_choice','What does "declamar" mean?','to declaim',array['to declare','to declass','to decimate'],'to declaim',2),
  (v_l6,'fill_blank','Complete: "De ____ nombre no quiero acordarme." (whose)','cuyo',array['cuya','cuyas','cuyos'],'whose (masc)',3),
  (v_l6,'multiple_choice','What does "burlesco" mean?','burlesque',array['burlap','burning','bursting'],'burlesque',4),
  (v_l6,'multiple_choice','What is "rhythm"?','el ritmo',array['el rito','el rítmico','el remo'],'rhythm',5),
  (v_l7,'multiple_choice','What is "prolepsis"?','flash-forward narration',array['flashback','digression','dialogue'],'prolepsis',1),
  (v_l7,'multiple_choice','What does "iba a + inf" mean?','was going to + verb',array['went to + verb','has gone to + verb','goes to + verb'],'was going to',2),
  (v_l7,'fill_blank','Complete: "El coronel ____ a recordar aquella tarde." (was going)','iba',array['fue','va','vaya'],'was going',3),
  (v_l7,'multiple_choice','What is "device" (literary)?','el recurso',array['el dispositivo','el aparato','el medio'],'literary device',4),
  (v_l7,'multiple_choice','What does "contextualizar" mean?','to contextualize',array['to contradict','to contemplate','to contemporize'],'contextualize',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Cervantes, cuya obra cumbre es "El Quijote", parodió las novelas de caballería',array['Cervantes inventó el género','El Siglo de Oro empieza','El hidalgo es protagonista'],'Cervantes, whose masterpiece is ''Don Quixote'', parodied chivalric novels',6),
  (v_l1,'listening','What did you hear?','parodió las novelas de caballería',array['imitó las novelas históricas','tradujo las novelas francesas','escribió novelas serias'],'parodied chivalric novels',7),
  (v_l1,'speaking','Say this aloud: "Cervantes parodió las novelas de caballería."','Cervantes parodió las novelas de caballería',array[]::text[],'Cervantes parodied chivalric novels.',8),
  (v_l1,'speaking','Say this aloud: "Su obra cumbre es El Quijote."','Su obra cumbre es El Quijote',array[]::text[],'His masterpiece is Don Quixote.',9),
  (v_l2,'listening','What did you hear?','En "Cien años de soledad", la familia Buendía está condenada a un destino del cual no puede escapar',array['El realismo mágico domina','La saga familiar perdura','Los Buendía son legendarios'],'In ''One Hundred Years of Solitude'', the Buendía family is condemned to a destiny from which it cannot escape',6),
  (v_l2,'listening','What did you hear?','un destino del cual no puede escapar',array['un destino que pueden cambiar','un destino del que escapan','un destino impredecible'],'a destiny from which it cannot escape',7),
  (v_l2,'speaking','Say this aloud: "Un destino del cual no puede escapar."','Un destino del cual no puede escapar',array[]::text[],'A destiny from which it cannot escape.',8),
  (v_l2,'speaking','Say this aloud: "Los Buendía están condenados."','Los Buendía están condenados',array[]::text[],'The Buendía are condemned.',9),
  (v_l3,'listening','What did you hear?','El soneto consta de catorce versos endecasílabos',array['Distribuidos en dos cuartetos','Y dos tercetos','El metro es fijo'],'The sonnet consists of fourteen hendecasyllabic verses',6),
  (v_l3,'listening','What did you hear?','distribuidos en dos cuartetos y dos tercetos',array['organizados en tres estrofas','divididos en cuatro partes','dispuestos en pareados'],'distributed in two quatrains and two tercets',7),
  (v_l3,'speaking','Say this aloud: "El soneto consta de catorce versos."','El soneto consta de catorce versos',array[]::text[],'The sonnet consists of fourteen verses.',8),
  (v_l3,'speaking','Say this aloud: "Dos cuartetos y dos tercetos."','Dos cuartetos y dos tercetos',array[]::text[],'Two quatrains and two tercets.',9),
  (v_l6,'listening','What did you hear?','En un lugar de la Mancha, de cuyo nombre no quiero acordarme',array['Aquí comienza la novela','El narrador es anónimo','La Mancha es regional'],'In a place of La Mancha, whose name I do not wish to remember',6),
  (v_l6,'listening','What did you hear?','La cadencia anuncia el tono burlesco de toda la obra',array['El ritmo es serio','La prosa es densa','El metro varía'],'The cadence announces the burlesque tone of the entire work',7),
  (v_l6,'speaking','Say this aloud: "En un lugar de la Mancha."','En un lugar de la Mancha',array[]::text[],'In a place of La Mancha.',8),
  (v_l6,'speaking','Say this aloud: "De cuyo nombre no quiero acordarme."','De cuyo nombre no quiero acordarme',array[]::text[],'Whose name I do not wish to remember.',9),
  (v_l7,'listening','What did you hear?','García Márquez emplea la prolepsis al revelar, desde la primera línea',array['Que el coronel iba a recordar','Aquella tarde frente al pelotón','El motivo dominante'],'García Márquez employs prolepsis by revealing, from the first line',6),
  (v_l7,'listening','What did you hear?','el coronel iba a recordar aquella tarde frente al pelotón de fusilamiento',array['el coronel recordó','el coronel olvidó','el coronel describió'],'the colonel was going to remember that afternoon facing the firing squad',7),
  (v_l7,'speaking','Say this aloud: "Iba a recordar aquella tarde."','Iba a recordar aquella tarde',array[]::text[],'He was going to remember that afternoon.',8),
  (v_l7,'speaking','Say this aloud: "García Márquez emplea la prolepsis."','García Márquez emplea la prolepsis',array[]::text[],'García Márquez employs prolepsis.',9);

  update public.lessons set type='conversation', title='Advanced Literature — Conversation Practice',
    description='Two literature students compare authors.',
    intro='Andrés and Lucía prep for a comparative essay.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Andrés","spanish":"¿Comparas a Cervantes con García Márquez?","english":"Are you comparing Cervantes to García Márquez?"},{"speaker":"Lucía","spanish":"Sí. Ambos juegan con el narrador. Cervantes lo hace mediante la metaficción; García Márquez, mediante la prolepsis.","english":"Yes. Both play with the narrator. Cervantes does so through metafiction; García Márquez, through prolepsis."},{"speaker":"Andrés","spanish":"Y los temas: la búsqueda, el destino del cual no se puede escapar.","english":"And the themes: the search, destiny from which one cannot escape."},{"speaker":"Lucía","spanish":"Asimismo, ambos transforman la realidad — uno con la parodia, el otro con lo real maravilloso.","english":"Likewise, both transform reality — one through parody, the other through the marvelous real."},{"speaker":"Andrés","spanish":"Cervantes, cuya influencia es incalculable, prefigura a todo el Boom.","english":"Cervantes, whose influence is incalculable, prefigures the entire Boom."},{"speaker":"Lucía","spanish":"Exacto. La literatura hispanoamericana sería impensable sin él.","english":"Exactly. Spanish-American literature would be unthinkable without him."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','Whom are they comparing?','Cervantes and García Márquez',array['Lope and Quevedo','Borges and Cortázar','Allende and Bolaño'],'Cervantes con García Márquez',1),
  (v_l8,'multiple_choice','Cervantes''s technique?','Metafiction',array['Prolepsis','Stream of consciousness','Internal monologue'],'metaficción',2),
  (v_l8,'multiple_choice','García Márquez''s technique?','Prolepsis',array['Metafiction','Allegory','Hyperbole'],'prolepsis',3),
  (v_l8,'multiple_choice','Shared theme?','Search, destiny one cannot escape',array['Love','War','Politics'],'búsqueda, destino',4),
  (v_l8,'fill_blank','Complete: "Cervantes, ____ influencia es incalculable." (whose - fem)','cuya',array['cuyo','cuyas','cuyos'],'whose (fem)',5),
  (v_l8,'multiple_choice','Lucía''s conclusion?','LatAm literature unthinkable without Cervantes',array['Cervantes is overrated','García Márquez is greater','Both are equal'],'sería impensable sin él',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Advanced Literature', 'Review test for the Advanced Literature section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "Golden Age"?','el Siglo de Oro',array['el Siglo Dorado','el Siglo Oro','el Era de Oro'],'Golden Age',1),
  (v_lesson_id,'multiple_choice','What is "magical realism"?','el realismo mágico',array['el mágico realismo','el real mágico','el realismo de magia'],'magical realism',2),
  (v_lesson_id,'multiple_choice','How many verses in a sonnet?','14',array['12','16','10'],'14 verses',3),
  (v_lesson_id,'multiple_choice','What is "prolepsis"?','flash-forward narration',array['flashback','digression','dialogue'],'prolepsis',4),
  (v_lesson_id,'fill_blank','Complete: "Cervantes, ____ obra cumbre es El Quijote." (whose - fem)','cuya',array['cuyo','cuyas','cuyos'],'whose (fem)',5),
  (v_lesson_id,'fill_blank','Complete: "Un destino del ____ no puede escapar." (which - formal)','cual',array['que','quien','el que'],'which (formal)',6),
  (v_lesson_id,'listening','What did you hear?','El coronel iba a recordar aquella tarde frente al pelotón de fusilamiento',array['Cervantes parodió las novelas','El soneto consta de versos','La Mancha es la región'],'The colonel was going to remember that afternoon facing the firing squad',7),
  (v_lesson_id,'listening','What did you hear?','En un lugar de la Mancha, de cuyo nombre no quiero acordarme',array['Aquí comienza el cuento','El narrador es omnisciente','La Mancha es regional'],'In a place of La Mancha, whose name I do not wish to remember',8),
  (v_lesson_id,'speaking','Say this aloud: "Iba a recordar aquella tarde."','Iba a recordar aquella tarde',array[]::text[],'He was going to remember that afternoon.',9),
  (v_lesson_id,'speaking','Say this aloud: "Su obra cumbre es El Quijote."','Su obra cumbre es El Quijote',array[]::text[],'His masterpiece is Don Quixote.',10);

  -- ===========================================================
  -- C1.11 COMPLEX GRAMMAR STRUCTURES
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'C1' and title = 'Complex Grammar Structures';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='Cleft sentences: "fue Juan quien lo hizo" instead of "Juan lo hizo". They emphasize specific elements.',
    vocab_items='[{"spanish":"la oración hendida","english":"cleft sentence"},{"spanish":"el énfasis","english":"emphasis"},{"spanish":"focalizar","english":"to focalize"},{"spanish":"destacar","english":"to highlight"},{"spanish":"resaltar","english":"to bring out"},{"spanish":"el sujeto","english":"subject"},{"spanish":"el predicado","english":"predicate"}]'::jsonb,
    dialogue='[{"speaker":"Profesora","spanish":"Fue Juan quien lo hizo es enfático, frente a "Juan lo hizo", neutro.","english":"''Fue Juan quien lo hizo'' is emphatic, versus ''Juan lo hizo'', neutral."}]'::jsonb,
    grammar_note='Cleft "fue X quien/lo que Y": split a sentence to focus on X. The verb "fue/es" agrees with the focalized element: "fui yo quien lo dijo".'
  where id = v_l1;

  update public.lessons set
    intro='Conditional types beyond the basics: "como + subjunctive" for warning, "de + infinitive" for hypothetical.',
    vocab_items='[{"speaker":"el condicional","english":"conditional"},{"spanish":"la oración condicional","english":"conditional sentence"},{"spanish":"la prótasis","english":"protasis (if-clause)"},{"spanish":"la apódosis","english":"apodosis (then-clause)"},{"spanish":"la advertencia","english":"warning"},{"spanish":"como","english":"if (warning)"},{"spanish":"de","english":"if (formal)"}]'::jsonb,
    dialogue='[{"speaker":"Padre","spanish":"Como no estudies, suspenderás. (advertencia)","english":"If you don''t study, you''ll fail. (warning)"},{"speaker":"Periodista","spanish":"De no haberse retrasado el avión, habríamos llegado a tiempo.","english":"If the plane hadn''t been delayed, we would have arrived on time."}]'::jsonb,
    grammar_note='"Como + subjunctive" = warning conditional: "como llegues tarde..." (if you arrive late, [consequence]). "De + infinitive" = formal/literary conditional.'
  where id = v_l2;

  update public.lessons set
    intro='Subjunctive in concessive clauses: "por más que", "por mucho que", "por X que sea/fuera".',
    vocab_items='[{"spanish":"por más que","english":"however much"},{"spanish":"por mucho que","english":"as much as"},{"spanish":"por poco que","english":"however little"},{"spanish":"por X que sea","english":"however X (it/he/she) may be"},{"spanish":"a pesar de que","english":"despite the fact that"},{"spanish":"aun cuando","english":"even when"},{"spanish":"si bien","english":"although"}]'::jsonb,
    dialogue='[{"speaker":"Hablante","spanish":"Por más que insistas, no cambiaré de opinión.","english":"However much you insist, I won''t change my mind."}]'::jsonb,
    grammar_note='"Por más que + subjunctive" = concessive — emphasizes the futility of insistence. The action in subjunctive is conceded but doesn''t affect the outcome.'
  where id = v_l3;

  update public.lessons set
    intro='Pronouns of result and complement: "lo cual" (which referring back), "ello" (it/that — neuter).',
    vocab_items='[{"spanish":"lo cual","english":"which (referring back)"},{"spanish":"ello","english":"it (neuter)"},{"spanish":"esto/eso/aquello","english":"this/that/that (far)"},{"spanish":"lo que","english":"what (relative)"},{"spanish":"cuanto","english":"all that"},{"spanish":"todo lo que","english":"everything that"}]'::jsonb,
    dialogue='[{"speaker":"Hablante","spanish":"Llegó tarde, lo cual molestó a todos.","english":"He arrived late, which annoyed everyone."}]'::jsonb,
    grammar_note='"Lo cual" refers to a whole previous clause or event, never to a single noun. Distinct from "el cual / la cual" which refers to a specific masc/fem noun.'
  where id = v_l4;

  update public.lessons set
    intro='Periphrastic verb constructions: "venir a + inf" (come to/end up), "ir a + inf" (be about to), "echar a + inf" (start to).',
    vocab_items='[{"spanish":"la perífrasis verbal","english":"verbal periphrasis"},{"spanish":"venir a + inf","english":"to come to / end up"},{"spanish":"echar a + inf","english":"to start to"},{"spanish":"acabar de + inf","english":"to have just"},{"spanish":"romper a + inf","english":"to burst into"},{"spanish":"llegar a + inf","english":"to manage to"},{"spanish":"dar por + ppt","english":"to consider as"}]'::jsonb,
    dialogue='[{"speaker":"Narradora","spanish":"Cuando le dieron la noticia, rompió a llorar.","english":"When they gave her the news, she burst into tears."}]'::jsonb,
    grammar_note='"Romper a + infinitive" = "to burst into V-ing", especially for sudden emotional reactions: "romper a llorar" (burst into tears), "romper a reír" (burst into laughter).'
  where id = v_l5;

  update public.lessons set
    intro='Listen to nuanced grammar in context. The challenge is hearing subtle distinctions in fast speech.',
    vocab_items='[{"spanish":"la sutileza","english":"subtlety"},{"spanish":"detectar","english":"to detect"},{"spanish":"distinguir","english":"to distinguish"},{"spanish":"agudo","english":"sharp (ear)"},{"spanish":"matizado","english":"nuanced"},{"spanish":"el contraste mínimo","english":"minimal contrast"}]'::jsonb,
    dialogue='[{"speaker":"Hablante 1","spanish":"Fue él quien me lo dijo, lo cual me sorprendió.","english":"It was he who told me, which surprised me."},{"speaker":"Hablante 2","spanish":"Por más que lo niegue, todos lo saben.","english":"However much he denies it, everyone knows."}]'::jsonb,
    grammar_note='Combinations: cleft sentence + "lo cual" + "por más que" — three advanced structures in succession. Native-like spontaneous use requires practice.'
  where id = v_l6;

  update public.lessons set
    intro='Write applying three advanced structures in one paragraph. Practice fluent combination.',
    vocab_items='[{"spanish":"combinar","english":"to combine"},{"spanish":"integrar","english":"to integrate"},{"spanish":"naturalidad","english":"naturalness"},{"spanish":"fluido","english":"fluid"},{"spanish":"el dominio","english":"mastery"}]'::jsonb,
    dialogue='[{"speaker":"Texto","spanish":"Como no llegues a tiempo, te perderás el inicio, lo cual sería una pena. Por más que digan que no importa, los primeros minutos son decisivos.","english":"If you don''t arrive on time, you''ll miss the start, which would be a shame. However much they say it doesn''t matter, the first minutes are decisive."}]'::jsonb,
    grammar_note='Triple advanced structure: "como + subj" (warning) → "lo cual + cond" (referring back) → "por más que + subj" (concessive). Native fluency packs these naturally.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "cleft sentence"?','la oración hendida',array['la oración cleft','la oración partida','la oración rota'],'cleft sentence',1),
  (v_l1,'multiple_choice','What does "focalizar" mean?','to focalize (focus)',array['to focus a camera','to find','to forecast'],'to focalize',2),
  (v_l1,'fill_blank','Complete: "____ Juan quien lo hizo." (it was)','Fue',array['Era','Es','Será'],'it was',3),
  (v_l1,'multiple_choice','Cleft sentence purpose?','emphasis on a specific element',array['neutral statement','question','command'],'emphasis',4),
  (v_l1,'multiple_choice','What is "predicate"?','el predicado',array['el predicador','el predicamento','el predicción'],'predicate',5),
  (v_l2,'multiple_choice','What does "como + subj" express?','warning conditional',array['result','time','manner'],'warning',1),
  (v_l2,'multiple_choice','What does "de + inf" as conditional do?','formal/literary if',array['informal if','question','command'],'formal if',2),
  (v_l2,'fill_blank','Complete: "____ no estudies, suspenderás." (if — warning)','Como',array['Si','Cuando','Aunque'],'if (warning)',3),
  (v_l2,'multiple_choice','What is "protasis"?','the if-clause',array['the then-clause','the result','the cause'],'if-clause',4),
  (v_l2,'multiple_choice','What does "advertencia" mean?','warning',array['advertisement','adventure','advice'],'warning',5),
  (v_l3,'multiple_choice','What does "por más que" mean?','however much',array['for more than','because more than','besides more than'],'however much',1),
  (v_l3,'multiple_choice','What does "por más que + subj" express?','concession (futility)',array['cause','time','result'],'concession',2),
  (v_l3,'fill_blank','Complete: "Por más que ____, no cambiaré." (insist — subj)','insistas',array['insistes','insistirás','insistías'],'insist (subj)',3),
  (v_l3,'multiple_choice','What does "aun cuando" mean?','even when',array['still when','again when','yet when'],'even when',4),
  (v_l3,'multiple_choice','What does "a pesar de que" mean?','despite the fact that',array['for sorrow that','of weight that','for him that'],'despite that',5),
  (v_l4,'multiple_choice','What does "lo cual" refer to?','whole previous clause',array['a specific noun','a person','a future event'],'whole clause',1),
  (v_l4,'multiple_choice','What is "ello" used for?','neuter abstract reference',array['masculine specific','feminine specific','plural'],'neuter ref',2),
  (v_l4,'fill_blank','Complete: "Llegó tarde, ____ molestó a todos." (which)','lo cual',array['que','el cual','lo que'],'which (back ref)',3),
  (v_l4,'multiple_choice','What is "cuanto"?','all that',array['quantum','quantity','question'],'all that',4),
  (v_l4,'multiple_choice','What does "esto/eso/aquello" measure?','spatial distance',array['time only','number','formality'],'spatial distance',5),
  (v_l5,'multiple_choice','What does "romper a + inf" mean?','to burst into V-ing',array['to break to V','to break with V','to break for V'],'burst into V-ing',1),
  (v_l5,'multiple_choice','What does "acabar de + inf" mean?','to have just V-ed',array['to finish V-ing','to start V-ing','to stop V-ing'],'have just',2),
  (v_l5,'fill_blank','Complete: "____ a llorar al saber la noticia." (burst into)','Rompió',array['Comenzó','Empezó','Inició'],'burst into',3),
  (v_l5,'multiple_choice','What is "verbal periphrasis"?','la perífrasis verbal',array['la perífrasis (only)','el perífrasis','la circumlocución'],'verbal periphrasis',4),
  (v_l5,'multiple_choice','What does "venir a + inf" express?','come to / end up',array['come for V-ing','come with V-ing','come from V-ing'],'end up',5),
  (v_l6,'multiple_choice','What is "subtlety"?','la sutileza',array['la sutil','el sutil','la sutileza (incorrect)'],'subtlety',1),
  (v_l6,'multiple_choice','What does "agudo" mean (ear)?','sharp',array['acute pain','high (sound)','small'],'sharp',2),
  (v_l6,'fill_blank','Complete: "Por más que lo ____" (denies — subj)','niegue',array['niega','negaba','negará'],'denies (subj)',3),
  (v_l6,'multiple_choice','What does "detectar" mean?','to detect',array['to defect','to deflect','to deflate'],'to detect',4),
  (v_l6,'multiple_choice','What does "matizado" mean?','nuanced',array['matched','mature','massive'],'nuanced',5),
  (v_l7,'multiple_choice','What is "naturalness"?','la naturalidad',array['la naturaleza','la natalidad','la nostalgia'],'naturalness',1),
  (v_l7,'multiple_choice','What does "fluido" mean?','fluid (style)',array['fluffy','flushed','floated'],'fluid',2),
  (v_l7,'fill_blank','Complete: "Como no ____ a tiempo, te perderás." (arrive — subj warning)','llegues',array['llegas','llegarás','llegabas'],'arrive (subj warning)',3),
  (v_l7,'multiple_choice','What is "mastery"?','el dominio',array['el doménico','el domingo','el dominador'],'mastery',4),
  (v_l7,'multiple_choice','What does "integrar" mean here?','to integrate (smoothly)',array['to interrogate','to interrupt','to introspect'],'to integrate',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Fue Juan quien lo hizo es enfático',array['Juan lo hizo es neutro','La oración es hendida','El énfasis es claro'],'It was Juan who did it is emphatic',6),
  (v_l1,'listening','What did you hear?','frente a "Juan lo hizo", neutro',array['frente a la oración pasada','frente al ejemplo simple','frente a la versión larga'],'versus ''Juan lo hizo'', neutral',7),
  (v_l1,'speaking','Say this aloud: "Fue Juan quien lo hizo."','Fue Juan quien lo hizo',array[]::text[],'It was Juan who did it.',8),
  (v_l1,'speaking','Say this aloud: "Fui yo quien lo dijo."','Fui yo quien lo dijo',array[]::text[],'It was I who said it.',9),
  (v_l2,'listening','What did you hear?','Como no estudies, suspenderás',array['Si estudias, aprobarás','Aunque estudies, perderás','Cuando estudies, sabrás'],'If you don''t study, you''ll fail',6),
  (v_l2,'listening','What did you hear?','De no haberse retrasado el avión, habríamos llegado a tiempo',array['Si el avión no se retrasa','Aunque el avión se retrase','Cuando el avión llega'],'If the plane hadn''t been delayed, we would have arrived on time',7),
  (v_l2,'speaking','Say this aloud: "Como no estudies, suspenderás."','Como no estudies, suspenderás',array[]::text[],'If you don''t study, you''ll fail.',8),
  (v_l2,'speaking','Say this aloud: "De no haberse retrasado, habríamos llegado."','De no haberse retrasado, habríamos llegado',array[]::text[],'If it hadn''t been delayed, we would have arrived.',9),
  (v_l3,'listening','What did you hear?','Por más que insistas, no cambiaré de opinión',array['Aunque insistas, sí','Por mucho que pidas, no','Si insistes, lo haré'],'However much you insist, I won''t change my mind',6),
  (v_l3,'listening','What did you hear?','no cambiaré de opinión',array['cambiaré mi mente','tendré que pensarlo','lo consideraré'],'I won''t change my mind',7),
  (v_l3,'speaking','Say this aloud: "Por más que insistas, no cambiaré."','Por más que insistas, no cambiaré',array[]::text[],'However much you insist, I won''t change.',8),
  (v_l3,'speaking','Say this aloud: "Por poco que sepas, basta."','Por poco que sepas, basta',array[]::text[],'However little you know, it''s enough.',9),
  (v_l6,'listening','What did you hear?','Fue él quien me lo dijo, lo cual me sorprendió',array['Por más que lo niegue','Todos lo saben ya','Yo no lo dije'],'It was he who told me, which surprised me',6),
  (v_l6,'listening','What did you hear?','Por más que lo niegue, todos lo saben',array['Aunque lo niega, todos saben','Si lo niega, alguien sabe','Como niegue, perderá'],'However much he denies it, everyone knows',7),
  (v_l6,'speaking','Say this aloud: "Fue él quien me lo dijo, lo cual me sorprendió."','Fue él quien me lo dijo, lo cual me sorprendió',array[]::text[],'It was he who told me, which surprised me.',8),
  (v_l6,'speaking','Say this aloud: "Por más que lo niegue, todos lo saben."','Por más que lo niegue, todos lo saben',array[]::text[],'However much he denies it, everyone knows.',9),
  (v_l7,'listening','What did you hear?','Como no llegues a tiempo, te perderás el inicio',array['lo cual sería una pena','Por más que digan que no importa','los primeros minutos son decisivos'],'If you don''t arrive on time, you''ll miss the start',6),
  (v_l7,'listening','What did you hear?','Por más que digan que no importa, los primeros minutos son decisivos',array['Como te apures, llegarás','El inicio es lo más interesante','Llegar tarde está mal'],'However much they say it doesn''t matter, the first minutes are decisive',7),
  (v_l7,'speaking','Say this aloud: "Como no llegues a tiempo, te perderás el inicio."','Como no llegues a tiempo, te perderás el inicio',array[]::text[],'If you don''t arrive on time, you''ll miss the start.',8),
  (v_l7,'speaking','Say this aloud: "Los primeros minutos son decisivos."','Los primeros minutos son decisivos',array[]::text[],'The first minutes are decisive.',9);

  update public.lessons set type='conversation', title='Complex Grammar Structures — Conversation Practice',
    description='Two students argue using advanced grammar.',
    intro='Sara and Pablo discuss a deadline.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Sara","spanish":"Fue Marta quien propuso adelantar la entrega, lo cual no me parece justo.","english":"It was Marta who proposed bringing forward the deadline, which doesn''t seem fair to me."},{"speaker":"Pablo","spanish":"Por más que protestes, ya está decidido.","english":"However much you protest, it''s already decided."},{"speaker":"Sara","spanish":"Como no me dejen tiempo suficiente, presentaré algo flojo.","english":"If they don''t give me enough time, I''ll submit something weak."},{"speaker":"Pablo","spanish":"De no entregar a tiempo, perderemos el contrato. Es así de sencillo.","english":"If we don''t submit on time, we lose the contract. It''s that simple."},{"speaker":"Sara","spanish":"Por poco que me esfuerce, terminaré algo, pero la calidad sufrirá.","english":"However little I try, I''ll finish something, but the quality will suffer."},{"speaker":"Pablo","spanish":"Mira, Sara, lo cual nos lleva al problema real: necesitamos más recursos.","english":"Look, Sara, which brings us to the real problem: we need more resources."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','Who proposed the early deadline?','Marta',array['Sara','Pablo','The boss'],'fue Marta quien propuso',1),
  (v_l8,'multiple_choice','Pablo''s response to protest?','It''s already decided',array['Try harder','We''ll see','Submit later'],'ya está decidido',2),
  (v_l8,'multiple_choice','Sara''s warning?','Submission will be weak',array['She''ll quit','She''ll be late','She''ll resign'],'presentaré algo flojo',3),
  (v_l8,'multiple_choice','What''s at stake per Pablo?','The contract',array['Their jobs','Their reputation','Their bonuses'],'perderemos el contrato',4),
  (v_l8,'fill_blank','Complete: "Por más que ____" (you protest — subj)','protestes',array['protestas','protestarás','protestabas'],'protest (subj)',5),
  (v_l8,'multiple_choice','Pablo''s pivot at the end?','The real problem is resources',array['Sara is wrong','He''s quitting','He needs help'],'necesitamos más recursos',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Complex Grammar Structures', 'Review test for the Complex Grammar Structures section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What does "como + subj" express?','warning conditional',array['result','time','manner'],'warning',1),
  (v_lesson_id,'multiple_choice','What does "por más que" + subj mean?','however much (concession)',array['for more than','because more','besides more'],'however much',2),
  (v_lesson_id,'multiple_choice','What does "lo cual" refer to?','whole previous clause',array['a specific noun','a person','a future event'],'whole clause',3),
  (v_lesson_id,'multiple_choice','What does "romper a + inf" mean?','to burst into V-ing',array['to break to V','to break with V','to break for V'],'burst into V-ing',4),
  (v_lesson_id,'fill_blank','Complete: "Como no ____ a tiempo." (arrive — subj)','llegues',array['llegas','llegarás','llegabas'],'arrive (subj)',5),
  (v_lesson_id,'fill_blank','Complete: "____ Juan quien lo hizo." (it was)','Fue',array['Era','Es','Será'],'it was',6),
  (v_lesson_id,'listening','What did you hear?','Por más que insistas, no cambiaré de opinión',array['Fue él quien me lo dijo','Como no estudies, suspenderás','Llegó tarde, lo cual molestó'],'However much you insist, I won''t change my mind',7),
  (v_lesson_id,'listening','What did you hear?','De no haberse retrasado el avión, habríamos llegado a tiempo',array['Por más que insistas','Lo cual me sorprendió','Fue él quien lo dijo'],'If the plane hadn''t been delayed, we would have arrived on time',8),
  (v_lesson_id,'speaking','Say this aloud: "Fue Juan quien lo hizo."','Fue Juan quien lo hizo',array[]::text[],'It was Juan who did it.',9),
  (v_lesson_id,'speaking','Say this aloud: "Por más que insistas, no cambiaré."','Por más que insistas, no cambiaré',array[]::text[],'However much you insist, I won''t change.',10);

  -- ===========================================================
  -- C1.12 REGIONAL DIALECTS
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'C1' and title = 'Regional Dialects';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='Castilian (Spain): distinctive "vosotros" forms, "z/c" pronunciation as θ, vocabulary like "ordenador" (computer).',
    vocab_items='[{"spanish":"el ordenador","english":"computer (Spain)"},{"spanish":"el coche","english":"car (Spain)"},{"spanish":"el móvil","english":"mobile phone (Spain)"},{"spanish":"vale","english":"OK (Spain)"},{"spanish":"el chaval","english":"kid (Spain)"},{"spanish":"el tío","english":"guy (Spain)"},{"spanish":"la pasta","english":"money (Spain)"},{"spanish":"currar","english":"to work (Spain)"},{"spanish":"el ceceo","english":"distinción c/z = θ"}]'::jsonb,
    dialogue='[{"speaker":"Madrileño","spanish":"Tío, vale, currar mucho y la pasta se va volando.","english":"Dude, OK, work a lot and the money flies away."}]'::jsonb,
    grammar_note='"Tío/tía" — Madrid filler for friends. "Vale" pervasive as "OK". The Castilian "z" pronounced /θ/ (as in English "thin") is iconic.'
  where id = v_l1;

  update public.lessons set
    intro='Mexican Spanish: distinctive vocabulary like "carro" (car), "manejar" (to drive), "platicar" (to chat).',
    vocab_items='[{"spanish":"el carro","english":"car (Mexico)"},{"spanish":"manejar","english":"to drive (Mexico)"},{"spanish":"platicar","english":"to chat (Mexico)"},{"spanish":"el celular","english":"mobile phone (LatAm)"},{"spanish":"la computadora","english":"computer (LatAm)"},{"spanish":"el camión","english":"bus (Mexico)"},{"spanish":"ahorita","english":"right now (Mex.)"},{"spanish":"órale","english":"come on / wow (Mex.)"},{"spanish":"chido","english":"cool (Mex.)"}]'::jsonb,
    dialogue='[{"speaker":"Mexicana","spanish":"Órale, vente al carro, ahorita platicamos.","english":"Come on, get in the car, we''ll chat right now."}]'::jsonb,
    grammar_note='"Ahorita" — flexible Mexican adverb. Can mean "right now", "in a moment", "earlier today", depending on tone. Context-dependent in a way Iberian Spanish isn''t.'
  where id = v_l2;

  update public.lessons set
    intro='Argentine Spanish: voseo (vos sos in place of tú eres), "sh" pronunciation of "ll/y", lunfardo slang.',
    vocab_items='[{"spanish":"vos","english":"you (Arg./Uru.)"},{"spanish":"sos","english":"you are (vos)"},{"spanish":"tenés","english":"you have (vos)"},{"spanish":"querés","english":"you want (vos)"},{"spanish":"che","english":"hey/dude (Arg.)"},{"spanish":"boludo","english":"dude/idiot (Arg.)"},{"spanish":"el lunfardo","english":"Buenos Aires slang"},{"spanish":"el laburo","english":"work (lunfardo)"},{"spanish":"morfar","english":"to eat (lunfardo)"}]'::jsonb,
    dialogue='[{"speaker":"Porteño","spanish":"Che, vos sabés que mañana laburás temprano, ¿no?","english":"Hey, you know you work early tomorrow, right?"}]'::jsonb,
    grammar_note='Voseo conjugation: "vos sos" (you are), "vos tenés" (you have), "vos querés" (you want). Stress pattern differs from "tú" — "vos" forms keep stress on the final syllable.'
  where id = v_l3;

  update public.lessons set
    intro='Caribbean Spanish (Cuba, PR, DR): "s" aspiration, "r → l" in PR, distinctive musicality.',
    vocab_items='[{"spanish":"qué bolá","english":"what''s up (Cuba)"},{"spanish":"asere","english":"buddy (Cuba)"},{"spanish":"chévere","english":"cool (Caribbean)"},{"spanish":"el tigueraje","english":"street-smarts (DR)"},{"spanish":"el jeva","english":"girlfriend (Caribbean)"},{"spanish":"la guagua","english":"bus (Cuba/PR/Canary Isles)"},{"spanish":"la chamba","english":"job (also Mex.)"}]'::jsonb,
    dialogue='[{"speaker":"Cubana","spanish":"Asere, qué bolá, ¿cómo va todo?","english":"Buddy, what''s up, how''s everything going?"}]'::jsonb,
    grammar_note='Caribbean "s" aspiration: final and pre-consonantal "s" often becomes /h/ or disappears: "estás" → "ehtá" or "etá". Hallmark of Caribbean phonology.'
  where id = v_l4;

  update public.lessons set
    intro='Andean Spanish (Peru, Bolivia, Ecuador): conservative grammar, slower pace, indigenous loanwords like "guagua" (baby in Quechua areas).',
    vocab_items='[{"spanish":"la guagua","english":"baby (Andean) / bus (Cuban)"},{"spanish":"el ñoqui","english":"freeloader (Argentine origin)"},{"spanish":"el cabro","english":"kid (Chile)"},{"spanish":"la pituca","english":"upscale girl (Peru)"},{"spanish":"el huevón","english":"dude (Chile/Peru)"},{"spanish":"la pichanga","english":"casual game (Peru)"}]'::jsonb,
    dialogue='[{"speaker":"Peruana","spanish":"El cabro chico es bien pituca, no juega pichanga.","english":"The little kid is real upper-class, doesn''t play street ball."}]'::jsonb,
    grammar_note='"Bien + adjective" intensifier — Andean usage: "bien pituca" = "really upper-class". A general LatAm structure but especially common in the Andes.'
  where id = v_l5;

  update public.lessons set
    intro='Listen to speakers from three regions. Train your ear to identify regional features quickly.',
    vocab_items='[{"spanish":"el origen","english":"origin"},{"spanish":"la procedencia","english":"provenance"},{"spanish":"identificar","english":"to identify"},{"spanish":"el rasgo","english":"feature"},{"spanish":"característico","english":"characteristic"},{"spanish":"reconocer","english":"to recognize"}]'::jsonb,
    dialogue='[{"speaker":"Madrileño","spanish":"Tío, currar es lo único que hacemos.","english":"Dude, working is all we do."},{"speaker":"Porteño","spanish":"Che, vos también laburás demasiado, boludo.","english":"Hey, you also work too much, dude."},{"speaker":"Mexicano","spanish":"Pues sí, manejo dos horas para chambear, está cabrón.","english":"Well yeah, I drive two hours to work, it''s rough."}]'::jsonb,
    grammar_note='Same idea, three regions: "currar" (Sp.) / "laburar" (Arg.) / "chambear" (Mex.) — all mean "to work". Lexical regional variation in everyday concepts.'
  where id = v_l6;

  update public.lessons set
    intro='Write describing your experience with regional variation. Reflect on which features charm you or confuse you.',
    vocab_items='[{"spanish":"el dialecto","english":"dialect"},{"spanish":"la variedad","english":"variety"},{"spanish":"la pronunciación","english":"pronunciation"},{"spanish":"el léxico","english":"lexicon"},{"spanish":"adaptar el oído","english":"to attune the ear"},{"spanish":"chocar","english":"to clash"}]'::jsonb,
    dialogue='[{"speaker":"Reflexión","spanish":"Lo que más me costó al llegar a Argentina fue acostumbrarme al voseo. Pasaron meses hasta que "vos sos" me sonó natural.","english":"What was hardest for me on arriving in Argentina was getting used to voseo. Months passed until ''vos sos'' sounded natural to me."}]'::jsonb,
    grammar_note='"Pasaron meses hasta que + indicative" = "months passed until + clause". The indicative because the event in subordinate is realized.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "computer" (Spain)?','el ordenador',array['la computadora','el computer','el cómputo'],'computer (Sp.)',1),
  (v_l1,'multiple_choice','What does "currar" mean?','to work (Spain)',array['to currate','to courier','to court'],'to work',2),
  (v_l1,'fill_blank','Complete: "____ es la pasta." (where)','Dónde',array['Cuándo','Cómo','Cuál'],'where (Spain)',3),
  (v_l1,'multiple_choice','What does "vale" mean (Spain)?','OK',array['valid','value','vacant'],'OK',4),
  (v_l1,'multiple_choice','What is "kid" (Spain colloq.)?','el chaval',array['el chico','el niño','el muchacho'],'kid (Sp.)',5),
  (v_l2,'multiple_choice','What is "car" (Mexico)?','el carro',array['el coche','el auto','el vehículo'],'car (Mex.)',1),
  (v_l2,'multiple_choice','What does "chido" mean?','cool (Mexico)',array['chubby','small','cheap'],'cool (Mex.)',2),
  (v_l2,'fill_blank','Complete: "____ vente al carro." (Come on)','Órale',array['Híjole','Sale','Andale'],'come on (Mex.)',3),
  (v_l2,'multiple_choice','What does "platicar" mean?','to chat (Mex.)',array['to plate','to plot','to plat'],'to chat',4),
  (v_l2,'multiple_choice','What does "ahorita" mean?','context-dependent (now / soon / earlier)',array['exactly now','exactly later','exactly yesterday'],'ahorita (flexible)',5),
  (v_l3,'multiple_choice','What is "vos" used for?','you (Arg./Uru.)',array['you all','you (formal)','you (plural)'],'vos',1),
  (v_l3,'multiple_choice','"Vos sos" =?','you are',array['you have','you do','you go'],'vos sos = you are',2),
  (v_l3,'fill_blank','Complete: "Vos ____ temprano." (work — vos)','laburás',array['laburas','laburaste','laburabas'],'work (vos)',3),
  (v_l3,'multiple_choice','What is "boludo" in Argentina?','dude/idiot (close friends only)',array['anyone','enemy','stranger'],'boludo',4),
  (v_l3,'multiple_choice','What is "lunfardo"?','Buenos Aires slang',array['Argentine literature','tango music','Argentine grammar'],'lunfardo',5),
  (v_l4,'multiple_choice','What does "qué bolá" mean (Cuba)?','what''s up',array['what''s in the ball','what''s big','what''s done'],'what''s up',1),
  (v_l4,'multiple_choice','What does "chévere" mean?','cool (Caribbean)',array['cheerful','cheesy','cherished'],'cool',2),
  (v_l4,'fill_blank','Complete: "Asere, qué ____" (what''s up)','bolá',array['onda','tal','pasa'],'what''s up (Cuban)',3),
  (v_l4,'multiple_choice','What is "guagua" (Caribbean)?','bus',array['baby','dog','train'],'bus (Caribbean)',4),
  (v_l4,'multiple_choice','Caribbean phonology: final "s" becomes?','/h/ or disappears',array['/k/','/p/','/t/'],'s-aspiration',5),
  (v_l5,'multiple_choice','What is "guagua" (Andean)?','baby',array['bus','train','car'],'baby (Andean)',1),
  (v_l5,'multiple_choice','What does "pituca" mean (Peru)?','upscale girl',array['short woman','strict teacher','small business'],'upscale girl',2),
  (v_l5,'fill_blank','Complete: "El cabro chico es ____" (kid — Chile)','cabro',array['cabro (incorrect)','chico','niño'],'kid (Chile)',3),
  (v_l5,'multiple_choice','What does "huevón" mean (Chile/Peru)?','dude (vulgar)',array['large egg','huge','full'],'huevón',4),
  (v_l5,'multiple_choice','What''s "pichanga" (Peru)?','casual game',array['large party','political march','elderly woman'],'pichanga',5),
  (v_l6,'multiple_choice','Three regional verbs for "work"?','currar / laburar / chambear',array['trabajar / hacer / construir','servir / dirigir / dirigir','formar / pasar / venir'],'work (Sp./Arg./Mex.)',1),
  (v_l6,'multiple_choice','What is "feature"?','el rasgo',array['el rango','el ruego','el rastro'],'feature',2),
  (v_l6,'fill_blank','Complete: "Pues sí, ____ dos horas para chambear." (I drive — Mex.)','manejo',array['conduzco','manejaba','maneje'],'drive (Mex.)',3),
  (v_l6,'multiple_choice','What does "está cabrón" mean (Mex.)?','it''s rough/intense',array['it''s a goat','it''s a stab','it''s a stone'],'it''s rough',4),
  (v_l6,'multiple_choice','What does "procedencia" mean?','provenance/origin',array['procedure','procession','process'],'provenance',5),
  (v_l7,'multiple_choice','What is "dialect"?','el dialecto',array['el diabólico','el dialéctico','el digno'],'dialect',1),
  (v_l7,'multiple_choice','What is "lexicon"?','el léxico',array['el lectivo','el leche','el lecho'],'lexicon',2),
  (v_l7,'fill_blank','Complete: "Pasaron meses hasta que vos sos me ____ natural." (sounded)','sonó',array['sonaba','sonara','sonará'],'sounded',3),
  (v_l7,'multiple_choice','What does "adaptar el oído" mean?','to attune the ear',array['to adopt the year','to plug ears','to adapt the audio'],'attune the ear',4),
  (v_l7,'multiple_choice','What is "variety" (linguistic)?','la variedad',array['la variación','la variante','la varios'],'variety',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Tío, vale, currar mucho y la pasta se va volando',array['Trabaja mucho y gana poco','La pasta es lo importante','El dinero rinde'],'Dude, OK, work a lot and the money flies away',6),
  (v_l1,'listening','What did you hear?','la pasta se va volando',array['el dinero se acaba','la comida vuela','el sueldo aumenta'],'the money flies away',7),
  (v_l1,'speaking','Say this aloud: "Tío, vale, currar mucho."','Tío, vale, currar mucho',array[]::text[],'Dude, OK, work a lot.',8),
  (v_l1,'speaking','Say this aloud: "La pasta se va volando."','La pasta se va volando',array[]::text[],'The money flies away.',9),
  (v_l2,'listening','What did you hear?','Órale, vente al carro, ahorita platicamos',array['Apúrate, ya nos vamos','El carro está afuera','Vamos a platicar mañana'],'Come on, get in the car, we''ll chat right now',6),
  (v_l2,'listening','What did you hear?','ahorita platicamos',array['ahorita nos vemos','ahorita comemos','ahorita salimos'],'we''ll chat right now',7),
  (v_l2,'speaking','Say this aloud: "Órale, vente al carro."','Órale, vente al carro',array[]::text[],'Come on, get in the car.',8),
  (v_l2,'speaking','Say this aloud: "Ahorita platicamos."','Ahorita platicamos',array[]::text[],'We''ll chat right now.',9),
  (v_l3,'listening','What did you hear?','Che, vos sabés que mañana laburás temprano',array['Vos no tenés tiempo','Mañana vos te quedás','Boludo, vos sabés todo'],'Hey, you know you work early tomorrow',6),
  (v_l3,'listening','What did you hear?','vos sabés que mañana laburás',array['vos tenés que dormir','vos podés descansar','vos vas a la fiesta'],'you know you work tomorrow',7),
  (v_l3,'speaking','Say this aloud: "Vos sabés que mañana laburás temprano."','Vos sabés que mañana laburás temprano',array[]::text[],'You know you work early tomorrow.',8),
  (v_l3,'speaking','Say this aloud: "Che, boludo, andá."','Che, boludo, andá',array[]::text[],'Hey, dude, go.',9),
  (v_l6,'listening','What did you hear?','Tío, currar es lo único que hacemos',array['Che, vos también laburás','Pues sí, manejo dos horas','Aquí está la pasta'],'Dude, working is all we do',6),
  (v_l6,'listening','What did you hear?','Pues sí, manejo dos horas para chambear',array['Tío, currar mucho','Che, laburás demasiado','Está bien duro'],'Well yeah, I drive two hours to work',7),
  (v_l6,'speaking','Say this aloud: "Currar es lo único que hacemos."','Currar es lo único que hacemos',array[]::text[],'Working is all we do.',8),
  (v_l6,'speaking','Say this aloud: "Manejo dos horas para chambear."','Manejo dos horas para chambear',array[]::text[],'I drive two hours to work.',9),
  (v_l7,'listening','What did you hear?','Lo que más me costó al llegar a Argentina fue acostumbrarme al voseo',array['Pasaron meses hasta que sonó natural','Vos sos es complicado','El acento fue lo difícil'],'What was hardest for me on arriving in Argentina was getting used to voseo',6),
  (v_l7,'listening','What did you hear?','Pasaron meses hasta que "vos sos" me sonó natural',array['Pasó un año','Lo aprendí rápido','Nunca me acostumbré'],'Months passed until ''vos sos'' sounded natural to me',7),
  (v_l7,'speaking','Say this aloud: "Lo que más me costó fue acostumbrarme al voseo."','Lo que más me costó fue acostumbrarme al voseo',array[]::text[],'What was hardest was getting used to voseo.',8),
  (v_l7,'speaking','Say this aloud: "Pasaron meses hasta que me sonó natural."','Pasaron meses hasta que me sonó natural',array[]::text[],'Months passed until it sounded natural.',9);

  update public.lessons set type='conversation', title='Regional Dialects — Conversation Practice',
    description='Three friends from different countries chat.',
    intro='Carlos (Mexico), Lucía (Argentina), and Marcos (Spain) catch up.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Carlos","spanish":"Órale, qué onda. ¿Cómo van las cosas en España?","english":"Hey, what''s up. How are things in Spain?"},{"speaker":"Marcos","spanish":"Tío, currando mucho. La pasta se va volando aquí.","english":"Dude, working hard. The money flies away here."},{"speaker":"Lucía","spanish":"Che, vos también te quejás. Acá en Buenos Aires igual: laburo todos los días.","english":"Hey, you also complain. Here in Buenos Aires same: I work every day."},{"speaker":"Carlos","spanish":"Y manejo dos horas pa chambear. Está cabrón.","english":"And I drive two hours to work. It''s rough."},{"speaker":"Marcos","spanish":"Lo curioso es que decimos lo mismo, pero en tres idiomas.","english":"What''s curious is that we say the same thing, but in three languages."},{"speaker":"Lucía","spanish":"Por más que cambien las palabras, la queja es universal.","english":"However much the words change, the complaint is universal."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','How does Marcos describe his Spanish life?','Working hard, money flies',array['Vacationing','Studying','Resting'],'currando, la pasta se va volando',1),
  (v_l8,'multiple_choice','Lucía''s situation in BA?','Working every day',array['Studying','Traveling','Vacationing'],'laburo todos los días',2),
  (v_l8,'multiple_choice','Carlos''s commute?','Two hours to work',array['Five minutes','Hour','Walking distance'],'manejo dos horas',3),
  (v_l8,'multiple_choice','Marcos''s observation?','Same idea in three regional Spanishes',array['One is correct','They''re different complaints','He can''t understand them'],'decimos lo mismo, pero en tres idiomas',4),
  (v_l8,'fill_blank','Complete: "Por más que ____ las palabras." (change — subj)','cambien',array['cambian','cambiarán','cambiaban'],'change (subj)',5),
  (v_l8,'multiple_choice','Lucía''s closing thought?','The complaint is universal',array['Complaints differ','Spanish is the same','Words don''t matter'],'la queja es universal',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Regional Dialects', 'Review test for the Regional Dialects section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "computer" (Spain)?','el ordenador',array['la computadora','el computer','el cómputo'],'computer (Sp.)',1),
  (v_lesson_id,'multiple_choice','"Vos sos" means what?','you are (Arg./Uru.)',array['you have','you do','you go'],'vos sos',2),
  (v_lesson_id,'multiple_choice','What is "car" (Mexico)?','el carro',array['el coche','el auto','el vehículo'],'car (Mex.)',3),
  (v_lesson_id,'multiple_choice','Three regional verbs for "work"?','currar / laburar / chambear',array['trabajar / hacer / construir','servir / dirigir / dirigir','formar / pasar / venir'],'work x3',4),
  (v_lesson_id,'fill_blank','Complete: "Vos ____ temprano." (work — vos)','laburás',array['laburas','laburaste','laburabas'],'work (vos)',5),
  (v_lesson_id,'fill_blank','Complete: "Por más que ____ las palabras." (change — subj)','cambien',array['cambian','cambiarán','cambiaban'],'change (subj)',6),
  (v_lesson_id,'listening','What did you hear?','Órale, vente al carro, ahorita platicamos',array['Tío, vale, currar','Che, vos sabés','Asere, qué bolá'],'Come on, get in the car, we''ll chat right now',7),
  (v_lesson_id,'listening','What did you hear?','Che, vos sabés que mañana laburás temprano',array['Órale, hoy chambeamos','Tío, mañana currás','Asere, mañana tienes'],'Hey, you know you work early tomorrow',8),
  (v_lesson_id,'speaking','Say this aloud: "Vos sos, tenés y querés."','Vos sos, tenés y querés',array[]::text[],'You are, you have, and you want (vos).',9),
  (v_lesson_id,'speaking','Say this aloud: "Tío, currar es lo único que hacemos."','Tío, currar es lo único que hacemos',array[]::text[],'Dude, working is all we do.',10);

  -- ===========================================================
  -- C1.13 SLANG & INFORMAL LANGUAGE
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'C1' and title = 'Slang & Informal Language';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='General Spanish slang: words used informally across regions. "Molar" (to be cool), "guay" (cool), "flipar" (to freak out).',
    vocab_items='[{"spanish":"molar","english":"to be cool (Spain)"},{"spanish":"guay","english":"cool (Spain)"},{"spanish":"flipar","english":"to freak out / be amazed"},{"spanish":"alucinar","english":"to be amazed"},{"spanish":"petar","english":"to break down (machine)"},{"spanish":"el rollo","english":"the deal / thing"},{"spanish":"el follón","english":"the mess"},{"spanish":"el chollo","english":"the bargain"},{"spanish":"la chapuza","english":"the botched job"}]'::jsonb,
    dialogue='[{"speaker":"Joven","spanish":"Esa peli mola, te vas a flipar.","english":"That movie''s cool, you''re going to freak out."}]'::jsonb,
    grammar_note='"Molar" conjugates like "gustar": "me mola" = "I like it/it''s cool to me". "Flipar" intransitive: "flipo con esto" = "I''m amazed by this".'
  where id = v_l1;

  update public.lessons set
    intro='Filler words and discourse markers: "o sea", "vamos a ver", "es que", "pues nada".',
    vocab_items='[{"spanish":"o sea","english":"I mean"},{"spanish":"vamos a ver","english":"let''s see"},{"spanish":"es que","english":"it''s just that"},{"spanish":"pues nada","english":"well then / anyway"},{"spanish":"en plan","english":"like (filler)"},{"spanish":"tipo","english":"like (filler)"},{"spanish":"rollo","english":"like / sort of"},{"spanish":"a ver","english":"let''s see"}]'::jsonb,
    dialogue='[{"speaker":"Joven 1","spanish":"O sea, en plan, no sé, es que me mola, ¿sabes?","english":"I mean, like, I don''t know, it''s just that I like it, you know?"}]'::jsonb,
    grammar_note='"En plan" — peninsular filler for "like" / "kind of". Overused by younger generations to the point of mockery. Use sparingly.'
  where id = v_l2;

  update public.lessons set
    intro='Reactions and exclamations: "qué fuerte", "qué pasada", "menudo", "vaya".',
    vocab_items='[{"spanish":"qué fuerte","english":"how intense / wow"},{"spanish":"qué pasada","english":"what a thing / wow"},{"spanish":"menudo","english":"what a (ironic)"},{"spanish":"vaya","english":"wow / oh well"},{"spanish":"jolín","english":"darn (euphemism)"},{"spanish":"madre mía","english":"oh my (mother)"},{"spanish":"ostras","english":"oysters (=darn)"},{"spanish":"hala","english":"wow / go on"}]'::jsonb,
    dialogue='[{"speaker":"Joven","spanish":"¿Te enteraste? ¡Qué fuerte! Menudo follón.","english":"Did you hear? How intense! What a mess."}]'::jsonb,
    grammar_note='"Menudo + noun" expresses irony/intensity: "menudo follón" = "what a mess". The adjective "menudo" normally means "small/tiny" but here flips ironically.'
  where id = v_l3;

  update public.lessons set
    intro='Mild expletives (vulgar territory — use cautiously): "joder", "hostia", "coño". Context-dependent intensity.',
    vocab_items='[{"spanish":"joder","english":"darn (vulgar)"},{"spanish":"hostia","english":"wow / darn (vulgar)"},{"spanish":"coño","english":"darn (vulgar)"},{"spanish":"jolines","english":"darn (mild)"},{"spanish":"miércoles","english":"miercoles (=mierda, euphemism)"},{"spanish":"caracoles","english":"darn (mild)"},{"spanish":"qué leches","english":"what the heck (vulgar)"}]'::jsonb,
    dialogue='[{"speaker":"Hablante","spanish":"¡Hostia, qué tarde es! Me piro.","english":"Wow, it''s so late! I''m leaving."}]'::jsonb,
    grammar_note='"Pirarse" = "to leave / split". Informal. "Me piro" = "I''m out of here". Equivalent to "me largo" or "me voy". Spanish casual register.'
  where id = v_l4;

  update public.lessons set
    intro='Digital/online slang: "tt" (todito), "tqm" (te quiero mucho), "xq" (porque). WhatsApp Spanish.',
    vocab_items='[{"spanish":"tqm","english":"i love you (text shorthand)"},{"spanish":"xq","english":"because (text)"},{"spanish":"q tal","english":"how''s it going (text)"},{"spanish":"ntp","english":"don''t worry (no te preocupes)"},{"spanish":"finde","english":"weekend (=fin de semana)"},{"spanish":"depre","english":"depressed (depresión)"},{"spanish":"profe","english":"teacher (profesor)"},{"spanish":"compi","english":"buddy (compañero)"}]'::jsonb,
    dialogue='[{"speaker":"Mensaje","spanish":"Compi, q tal el finde. tqm, ntp por lo de ayer.","english":"Buddy, how''s the weekend. love you, don''t worry about yesterday."}]'::jsonb,
    grammar_note='Abbreviation rules: drop vowels ("xq" = "porque"), shorten compound words ("finde" = "fin de semana"), use single-letter substitutions ("q" = "que").'
  where id = v_l5;

  update public.lessons set
    intro='Listen to native young speakers. Recognize the slang and read the tone.',
    vocab_items='[{"spanish":"la jerga","english":"slang"},{"spanish":"el argot","english":"argot/slang"},{"spanish":"informal","english":"informal"},{"spanish":"coloquial","english":"colloquial"},{"spanish":"el registro coloquial","english":"colloquial register"},{"spanish":"vulgar","english":"vulgar"}]'::jsonb,
    dialogue='[{"speaker":"Joven 1","spanish":"O sea, fui al concierto y flipé en colores.","english":"I mean, I went to the concert and totally freaked out."},{"speaker":"Joven 2","spanish":"Hala, qué pasada. ¿Estuvo guay?","english":"Wow, what a thing. Was it cool?"}]'::jsonb,
    grammar_note='"Flipar en colores" = intensified "flipar" — "to totally freak out". Adding "en colores" / "en mil colores" amplifies the surprise/excitement.'
  where id = v_l6;

  update public.lessons set
    intro='Write a casual chat exchange. Use natural slang without overdoing it.',
    vocab_items='[{"spanish":"el chat","english":"chat"},{"spanish":"natural","english":"natural"},{"spanish":"forzado","english":"forced"},{"spanish":"colega","english":"buddy"},{"spanish":"el mensaje","english":"message"},{"spanish":"el grupo","english":"group"}]'::jsonb,
    dialogue='[{"speaker":"Chat","spanish":"Tía, q tal? Es que ayer salí con los compis y flipé. Madre mía la noche. Quedamos este finde?","english":"Girl, how''s it going? Yesterday I went out with the buddies and freaked out. Oh my, what a night. Hang out this weekend?"}]'::jsonb,
    grammar_note='"Quedar" in slang = "to make plans / meet up": "¿quedamos?" = "shall we hang out?". Different from "quedar" = "to remain".'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What does "molar" mean (Spain)?','to be cool',array['to mole','to bother','to count'],'to be cool',1),
  (v_l1,'multiple_choice','What does "flipar" mean?','to freak out / be amazed',array['to flip a coin','to skip','to flop'],'freak out',2),
  (v_l1,'fill_blank','Complete: "Esa peli ____" (is cool — gusta-like)','mola',array['molas','molamos','mole'],'is cool',3),
  (v_l1,'multiple_choice','What is "follón"?','mess',array['follower','folklore','folly'],'mess',4),
  (v_l1,'multiple_choice','What is "chollo"?','bargain',array['chollo (incorrect)','choli','chofer'],'bargain',5),
  (v_l2,'multiple_choice','What does "o sea" mean?','I mean',array['oh see','o seer','o sea (incorrect)'],'I mean',1),
  (v_l2,'multiple_choice','What does "en plan" mean (filler)?','like / kind of',array['in plan','at plan','for plan'],'like (filler)',2),
  (v_l2,'fill_blank','Complete: "____ que me mola." (it''s just)','Es',array['Por','Por es','Para'],'it''s just',3),
  (v_l2,'multiple_choice','What does "pues nada" mean?','well then / anyway',array['then nothing','for nothing','because nothing'],'well anyway',4),
  (v_l2,'multiple_choice','What does "tipo" mean (filler)?','like (filler)',array['type only','sort only','typo'],'like (filler)',5),
  (v_l3,'multiple_choice','What does "qué fuerte" mean?','how intense / wow',array['how strong (literal)','how tough','how hard'],'wow',1),
  (v_l3,'multiple_choice','What does "menudo + noun" express?','irony/intensity',array['size','quantity','time'],'menudo (ironic)',2),
  (v_l3,'fill_blank','Complete: "____ follón." (what a)','Menudo',array['Pequeño','Poco','Solo'],'what a (ironic)',3),
  (v_l3,'multiple_choice','What is "jolín"?','darn (euphemism)',array['darn (vulgar)','party','joke'],'darn (mild)',4),
  (v_l3,'multiple_choice','What is "hala"?','wow / go on',array['hello (Arabic)','halal','halt'],'wow / go on',5),
  (v_l4,'multiple_choice','What does "pirarse" mean?','to leave (informal)',array['to pirate','to peer','to pile'],'to leave',1),
  (v_l4,'multiple_choice','What is "miércoles" used as?','euphemism for "mierda"',array['Wednesday only','Mercury','Mercurio'],'euphemism',2),
  (v_l4,'fill_blank','Complete: "Me ____" (I''m leaving — pirarse)','piro',array['piro (incorrect)','piras','piran'],'I''m leaving',3),
  (v_l4,'multiple_choice','What is "qué leches"?','what the heck (vulgar)',array['what milk','what cars','what kale'],'what the heck',4),
  (v_l4,'multiple_choice','How vulgar is "joder"?','vulgar (but mild in casual use)',array['polite','formal','academic'],'vulgar',5),
  (v_l5,'multiple_choice','What does "tqm" mean?','i love you (text)',array['thanks queen ma''am','too quick man','to question me'],'i love you',1),
  (v_l5,'multiple_choice','What does "finde" mean?','weekend',array['find','finder','fender'],'weekend',2),
  (v_l5,'fill_blank','Complete: "____ por lo de ayer." (don''t worry — text)','ntp',array['tqm','xq','q tal'],'don''t worry',3),
  (v_l5,'multiple_choice','What does "profe" mean?','teacher (slang)',array['professional','profession','proficient'],'teacher (slang)',4),
  (v_l5,'multiple_choice','What does "compi" mean?','buddy (slang)',array['computer','comply','compile'],'buddy (slang)',5),
  (v_l6,'multiple_choice','What does "flipar en colores" mean?','to totally freak out',array['to flip colors','to color-flip','to see colors'],'totally freak out',1),
  (v_l6,'multiple_choice','What is "argot"?','argot/slang',array['argument','argentine','aristocrat'],'argot/slang',2),
  (v_l6,'fill_blank','Complete: "Fui al concierto y ____ en colores." (freaked out)','flipé',array['flipo','flipaba','fliparé'],'freaked out',3),
  (v_l6,'multiple_choice','What does "guay" mean?','cool (Spain)',array['weed','waterway','guayaba'],'cool',4),
  (v_l6,'multiple_choice','What is "colloquial register"?','el registro coloquial',array['el régimen colloquial','el coloquio formal','el registro normal'],'colloquial register',5),
  (v_l7,'multiple_choice','What does "quedar" mean in slang?','to make plans / hang out',array['to remain','to stay','to be left'],'hang out',1),
  (v_l7,'multiple_choice','What is "colega"?','buddy',array['colleague (formal)','college','cologne'],'buddy',2),
  (v_l7,'fill_blank','Complete: "____ este finde?" (shall we hang)','Quedamos',array['Quedan','Quede','Quedó'],'we hang out',3),
  (v_l7,'multiple_choice','What does "tía" mean (slang)?','girl / dudette',array['aunt only','aunt (formal)','elder'],'girl (slang)',4),
  (v_l7,'multiple_choice','What does "forzado" mean here?','forced (unnatural)',array['fortified','formed','forged'],'forced',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Esa peli mola, te vas a flipar',array['Es una buena película','La película es aburrida','Te va a gustar'],'That movie''s cool, you''re going to freak out',6),
  (v_l1,'listening','What did you hear?','te vas a flipar',array['te vas a aburrir','te vas a reír','te vas a sorprender'],'you''re going to freak out',7),
  (v_l1,'speaking','Say this aloud: "Esa peli mola un montón."','Esa peli mola un montón',array[]::text[],'That movie is super cool.',8),
  (v_l1,'speaking','Say this aloud: "Vas a flipar con esto."','Vas a flipar con esto',array[]::text[],'You''re going to freak out at this.',9),
  (v_l2,'listening','What did you hear?','O sea, en plan, no sé, es que me mola, sabes',array['Me gusta mucho la peli','Es interesante el tema','No tengo opinión'],'I mean, like, I don''t know, it''s just that I like it, you know',6),
  (v_l2,'listening','What did you hear?','es que me mola, sabes',array['no me convence','no estoy seguro','no entiendo bien'],'it''s just that I like it, you know',7),
  (v_l2,'speaking','Say this aloud: "O sea, en plan, no sé."','O sea, en plan, no sé',array[]::text[],'I mean, like, I don''t know.',8),
  (v_l2,'speaking','Say this aloud: "Es que me mola, sabes."','Es que me mola, sabes',array[]::text[],'It''s just that I like it, you know.',9),
  (v_l3,'listening','What did you hear?','Te enteraste? Qué fuerte! Menudo follón',array['Vaya lío','Qué pasada','Vaya rollo'],'Did you hear? How intense! What a mess',6),
  (v_l3,'listening','What did you hear?','Menudo follón',array['Vaya lío','Qué desastre','Qué problema'],'What a mess',7),
  (v_l3,'speaking','Say this aloud: "Qué fuerte, menudo follón."','Qué fuerte, menudo follón',array[]::text[],'How intense, what a mess.',8),
  (v_l3,'speaking','Say this aloud: "Vaya rollo, qué pasada."','Vaya rollo, qué pasada',array[]::text[],'What a deal, what a thing.',9),
  (v_l6,'listening','What did you hear?','O sea, fui al concierto y flipé en colores',array['Hala, qué pasada','Estuvo guay','Me lo pasé bomba'],'I mean, I went to the concert and totally freaked out',6),
  (v_l6,'listening','What did you hear?','Estuvo guay',array['Estuvo mal','Estuvo aburrido','Estuvo regular'],'Was it cool',7),
  (v_l6,'speaking','Say this aloud: "Fui al concierto y flipé."','Fui al concierto y flipé',array[]::text[],'I went to the concert and freaked out.',8),
  (v_l6,'speaking','Say this aloud: "Hala, qué pasada."','Hala, qué pasada',array[]::text[],'Wow, what a thing.',9),
  (v_l7,'listening','What did you hear?','Tía, q tal? Es que ayer salí con los compis y flipé',array['Madre mía la noche','Quedamos este finde','Tqm, te echo de menos'],'Girl, how''s it going? Yesterday I went out with the buddies and freaked out',6),
  (v_l7,'listening','What did you hear?','Madre mía la noche. Quedamos este finde?',array['Hala qué pasada','Vaya rollo','Qué follón'],'Oh my, what a night. Hang out this weekend?',7),
  (v_l7,'speaking','Say this aloud: "Tía, qué tal el finde?"','Tía, qué tal el finde?',array[]::text[],'Girl, how''s the weekend?',8),
  (v_l7,'speaking','Say this aloud: "Quedamos este finde?"','Quedamos este finde?',array[]::text[],'Shall we hang out this weekend?',9);

  update public.lessons set type='conversation', title='Slang & Informal Language — Conversation Practice',
    description='Two friends gossip casually.',
    intro='Marta and Lucía catch up over text.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Marta","spanish":"Tía, qué tal el finde? Me enteré de lo de Pablo. Qué fuerte.","english":"Girl, how''s the weekend? I heard about Pablo. How intense."},{"speaker":"Lucía","spanish":"Madre mía, menudo follón. O sea, no me lo esperaba.","english":"Oh my, what a mess. I mean, I didn''t expect it."},{"speaker":"Marta","spanish":"Yo flipé en colores. ¿Y tú?","english":"I totally freaked out. And you?"},{"speaker":"Lucía","spanish":"Pues nada, tipo, alucinada. Es que era todo muy raro.","english":"Well anyway, like, amazed. It''s just that it was all very weird."},{"speaker":"Marta","spanish":"Hala. Bueno, quedamos pronto y nos lo cuentas todo. Tqm.","english":"Wow. Well, let''s hang out soon and you''ll tell us everything. Love you."},{"speaker":"Lucía","spanish":"Vale, ntp por lo de ayer. Hablamos este finde.","english":"OK, don''t worry about yesterday. We''ll talk this weekend."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','What did Marta hear about?','Pablo (something intense)',array['A wedding','A vacation','A movie'],'me enteré de lo de Pablo',1),
  (v_l8,'multiple_choice','Lucía''s reaction phrase?','Madre mía, what a mess',array['Whatever, no big deal','Cool, when''s the party','Sorry, I''m busy'],'madre mía, menudo follón',2),
  (v_l8,'multiple_choice','Marta''s intensifier?','I totally freaked out',array['I''m fine','I''m angry','I''m sad'],'flipé en colores',3),
  (v_l8,'multiple_choice','Lucía''s state?','Amazed (alucinada)',array['Annoyed','Bored','Energetic'],'alucinada',4),
  (v_l8,'fill_blank','Complete: "____ pronto y nos lo cuentas." (hang out)','Quedamos',array['Quedan','Quede','Quedó'],'hang out',5),
  (v_l8,'multiple_choice','Lucía''s text closing?','OK, don''t worry, weekend talk',array['No, never','Don''t bother me','I''m busy'],'vale, ntp, hablamos este finde',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Slang & Informal Language', 'Review test for the Slang & Informal Language section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What does "molar" mean (Spain)?','to be cool',array['to mole','to bother','to count'],'to be cool',1),
  (v_lesson_id,'multiple_choice','What does "menudo + noun" express?','irony/intensity',array['size','quantity','time'],'menudo (ironic)',2),
  (v_lesson_id,'multiple_choice','What does "tqm" mean?','i love you (text)',array['thanks queen','too quick','to question me'],'i love you',3),
  (v_lesson_id,'multiple_choice','What does "flipar en colores" mean?','to totally freak out',array['to flip colors','to color-flip','to see colors'],'totally freak out',4),
  (v_lesson_id,'fill_blank','Complete: "Esa peli ____" (is cool)','mola',array['molas','molamos','mole'],'is cool',5),
  (v_lesson_id,'fill_blank','Complete: "____ este finde?" (shall we hang)','Quedamos',array['Quedan','Quede','Quedó'],'we hang out',6),
  (v_lesson_id,'listening','What did you hear?','O sea, fui al concierto y flipé en colores',array['Esa peli mola','Qué fuerte, menudo follón','Tía, qué tal el finde'],'I mean, I went to the concert and totally freaked out',7),
  (v_lesson_id,'listening','What did you hear?','Tía, q tal? Es que ayer salí con los compis',array['Hala qué pasada','Madre mía la noche','Qué fuerte el tema'],'Girl, how''s it going? Yesterday I went out with the buddies',8),
  (v_lesson_id,'speaking','Say this aloud: "Tía, qué tal el finde?"','Tía, qué tal el finde?',array[]::text[],'Girl, how''s the weekend?',9),
  (v_lesson_id,'speaking','Say this aloud: "Flipé en colores."','Flipé en colores',array[]::text[],'I totally freaked out.',10);

  -- ===========================================================
  -- C1.14 TRANSLATION SKILLS
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'C1' and title = 'Translation Skills';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='Literal vs free translation. Master "traducción literal" vs "traducción libre". When to favor which.',
    vocab_items='[{"spanish":"la traducción","english":"translation"},{"spanish":"traducir","english":"to translate"},{"spanish":"la lengua de partida","english":"source language"},{"spanish":"la lengua de llegada","english":"target language"},{"spanish":"literal","english":"literal"},{"spanish":"libre","english":"free"},{"spanish":"el equivalente","english":"equivalent"},{"spanish":"el calco","english":"calque/loan translation"},{"spanish":"el préstamo","english":"loanword"},{"spanish":"la adaptación","english":"adaptation"}]'::jsonb,
    dialogue='[{"speaker":"Traductora","spanish":"Para textos legales, prefiero la traducción literal. Para literatura, libre.","english":"For legal texts, I prefer literal translation. For literature, free."}]'::jsonb,
    grammar_note='"Para + noun, prefiero + noun" — preference construction. The "para" introduces the use case; the comma is essential for flow.'
  where id = v_l1;

  update public.lessons set
    intro='False friends: words that look the same but mean different things. "Embarazada" ≠ "embarrassed".',
    vocab_items='[{"spanish":"el falso amigo","english":"false friend"},{"spanish":"embarazada","english":"pregnant (NOT embarrassed)"},{"spanish":"avergonzada","english":"embarrassed"},{"spanish":"actualmente","english":"currently (NOT actually)"},{"spanish":"en realidad","english":"actually"},{"spanish":"sensible","english":"sensitive (NOT sensible)"},{"spanish":"sensato","english":"sensible"},{"spanish":"asistir","english":"to attend (NOT assist)"},{"spanish":"ayudar","english":"to help/assist"},{"spanish":"el éxito","english":"success (NOT exit)"}]'::jsonb,
    dialogue='[{"speaker":"Profesor","spanish":"Cuidado: "embarazada" significa "pregnant", no "embarrassed".","english":"Careful: ''embarazada'' means ''pregnant'', not ''embarrassed''."}]'::jsonb,
    grammar_note='"Significar" vs "querer decir": "significar" = official meaning; "querer decir" = "to mean" in conversation. Both translate as "to mean".'
  where id = v_l2;

  update public.lessons set
    intro='Idiomatic translation: idioms need cultural equivalence, not literal rendering. "It''s raining cats and dogs" = "llueve a cántaros".',
    vocab_items='[{"spanish":"el modismo","english":"idiom"},{"spanish":"la expresión idiomática","english":"idiomatic expression"},{"spanish":"el equivalente cultural","english":"cultural equivalent"},{"spanish":"intraducible","english":"untranslatable"},{"spanish":"la equivalencia","english":"equivalence"},{"spanish":"el sentido","english":"sense"},{"spanish":"el matiz","english":"nuance"},{"spanish":"el registro","english":"register"}]'::jsonb,
    dialogue='[{"speaker":"Traductora","spanish":""It''s raining cats and dogs" no se traduce literalmente, sino como "llueve a cántaros".","english":"''It''s raining cats and dogs'' is not translated literally, but as ''llueve a cántaros''."}]'::jsonb,
    grammar_note='"No X sino Y" = "not X but rather Y" — strong contrastive structure. "No literalmente sino como" pattern frequent in translation studies.'
  where id = v_l3;

  update public.lessons set
    intro='Untranslatable concepts: "sobremesa", "duende", "saudade" (PT). Cultural concepts demand explanation.',
    vocab_items='[{"spanish":"intraducible","english":"untranslatable"},{"spanish":"el concepto cultural","english":"cultural concept"},{"spanish":"la explicación","english":"explanation"},{"spanish":"la nota del traductor","english":"translator''s note"},{"spanish":"contextualizar","english":"to contextualize"},{"spanish":"perder en la traducción","english":"to lose in translation"},{"spanish":"preservar","english":"to preserve"}]'::jsonb,
    dialogue='[{"speaker":"Traductora","spanish":"Algunas palabras son intraducibles. La "sobremesa", por ejemplo, requiere una nota explicativa.","english":"Some words are untranslatable. ''Sobremesa'', for example, requires an explanatory note."}]'::jsonb,
    grammar_note='"Requerir + noun" = "to require + noun". Formal alternative to "necesitar". In translation studies, "requerir" sounds more academic.'
  where id = v_l4;

  update public.lessons set
    intro='Technology in translation: CAT tools, machine translation, post-editing. The modern translator''s ecosystem.',
    vocab_items='[{"spanish":"la traducción automática","english":"machine translation"},{"spanish":"la memoria de traducción","english":"translation memory"},{"spanish":"la posedición","english":"post-editing"},{"spanish":"la herramienta CAT","english":"CAT tool"},{"spanish":"el glosario","english":"glossary"},{"spanish":"la terminología","english":"terminology"},{"spanish":"la coherencia","english":"consistency"},{"spanish":"automatizar","english":"to automate"}]'::jsonb,
    dialogue='[{"speaker":"Traductora","spanish":"Uso la traducción automática como borrador y luego la postedito.","english":"I use machine translation as a draft and then post-edit it."}]'::jsonb,
    grammar_note='"Usar X como Y" = "to use X as Y": "usar la traducción como borrador". Common construction for repurposing tools.'
  where id = v_l5;

  update public.lessons set
    intro='Listen to a translator''s commentary. Hear how they verbalize choices and compromises.',
    vocab_items='[{"spanish":"el comentario","english":"commentary"},{"spanish":"la decisión","english":"decision"},{"spanish":"justificar","english":"to justify"},{"spanish":"la pérdida","english":"loss"},{"spanish":"el compromiso","english":"compromise"},{"spanish":"asumir","english":"to assume"}]'::jsonb,
    dialogue='[{"speaker":"Traductora","spanish":"Aquí opté por sacrificar la rima en aras de preservar el sentido.","english":"Here I chose to sacrifice the rhyme for the sake of preserving the meaning."}]'::jsonb,
    grammar_note='"Optar por + infinitive" = "to choose to + verb". More formal than "decidir" or "elegir". Common in academic and professional decision narratives.'
  where id = v_l6;

  update public.lessons set
    intro='Write a translation comparison. Compare two versions of the same source text, justify which works better.',
    vocab_items='[{"spanish":"la comparación","english":"comparison"},{"spanish":"comparar","english":"to compare"},{"spanish":"la versión","english":"version"},{"spanish":"la fidelidad","english":"fidelity"},{"spanish":"la fluidez","english":"fluency"},{"spanish":"el estilo","english":"style"},{"spanish":"la elección","english":"choice"}]'::jsonb,
    dialogue='[{"speaker":"Análisis","spanish":"La primera versión es más literal pero pierde fluidez; la segunda fluye, aunque a costa de cierta fidelidad léxica.","english":"The first version is more literal but loses fluency; the second flows, although at the cost of some lexical fidelity."}]'::jsonb,
    grammar_note='"A costa de + noun" = "at the cost of + noun". Standard in trade-off analysis: "a costa de la fidelidad", "a costa del tiempo".'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "source language"?','la lengua de partida',array['la lengua de origen (synonym)','la lengua original','la lengua materna'],'source language',1),
  (v_l1,'multiple_choice','What is "loanword"?','el préstamo',array['el calco','la adaptación','el equivalente'],'loanword',2),
  (v_l1,'fill_blank','Complete: "____ textos legales, prefiero literal." (for)','Para',array['Por','En','De'],'for',3),
  (v_l1,'multiple_choice','What is "calque"?','el calco',array['el préstamo','la adaptación','la equivalencia'],'calque',4),
  (v_l1,'multiple_choice','What is "target language"?','la lengua de llegada',array['la lengua final','la lengua destino','la lengua objetivo'],'target language',5),
  (v_l2,'multiple_choice','What does "embarazada" mean?','pregnant',array['embarrassed','occupied','imprisoned'],'pregnant',1),
  (v_l2,'multiple_choice','What does "actualmente" mean?','currently',array['actually','effectively','really'],'currently',2),
  (v_l2,'fill_blank','Complete: "____ no significa "sensible"." (sensible)','sensible',array['sensible (incorrect)','sentido','sensitivo'],'sensible',3),
  (v_l2,'multiple_choice','What does "asistir" mean?','to attend',array['to assist (always)','to help (always)','to attest'],'to attend',4),
  (v_l2,'multiple_choice','What does "éxito" mean?','success',array['exit','exodus','exact'],'success',5),
  (v_l3,'multiple_choice','How is "raining cats and dogs" translated?','llueve a cántaros',array['lloviendo perros y gatos','llueven perros y gatos','está lloviendo mucho'],'literal x: idiomatic translation',1),
  (v_l3,'multiple_choice','What is "untranslatable"?','intraducible',array['intraductible','indecible','incompatible'],'untranslatable',2),
  (v_l3,'fill_blank','Complete: "No literalmente ____ como "llueve a cántaros"." (but rather)','sino',array['pero','sino que','si no'],'but rather',3),
  (v_l3,'multiple_choice','What is "cultural equivalent"?','el equivalente cultural',array['la cultura equivalente','el cultural equivalente','el equivalente de cultura'],'cultural equivalent',4),
  (v_l3,'multiple_choice','What is "nuance"?','el matiz',array['el matar','el mátalas','el mátalo'],'nuance',5),
  (v_l4,'multiple_choice','What is "translator''s note"?','la nota del traductor',array['la nota traductora','la nota al traductor','la traducción nota'],'translator''s note',1),
  (v_l4,'multiple_choice','What does "preservar" mean?','to preserve',array['to present','to preside','to prevail'],'to preserve',2),
  (v_l4,'fill_blank','Complete: "Sobremesa ____ una nota explicativa." (requires)','requiere',array['requiero','requería','requería'],'requires',3),
  (v_l4,'multiple_choice','What does "perder en la traducción" mean?','to lose in translation',array['to perish translating','to translate poorly','to fail translation'],'lose in translation',4),
  (v_l4,'multiple_choice','What is "cultural concept"?','el concepto cultural',array['el cultural concepto','el concepto de cultura','el concepto culturalmente'],'cultural concept',5),
  (v_l5,'multiple_choice','What is "machine translation"?','la traducción automática',array['la traducción de máquina','la traducción mecánica','la auto-traducción'],'machine translation',1),
  (v_l5,'multiple_choice','What is "post-editing"?','la posedición',array['la edición posterior','la edición pos','la pos-edición'],'post-editing',2),
  (v_l5,'fill_blank','Complete: "Uso la traducción automática ____ borrador." (as)','como',array['así','según','contra'],'as',3),
  (v_l5,'multiple_choice','What is "consistency"?','la coherencia',array['la consistencia (incorrect)','la consciencia','la conexión'],'consistency',4),
  (v_l5,'multiple_choice','What is "glossary"?','el glosario',array['el glosado','el glosa','la glos'],'glossary',5),
  (v_l6,'multiple_choice','What does "optar por + inf" mean?','to choose to V',array['to opt around','to opt with','to opt over'],'to choose to',1),
  (v_l6,'multiple_choice','What is "compromise"?','el compromiso',array['el compromiser','el compromise','el compras'],'compromise',2),
  (v_l6,'fill_blank','Complete: "Opté ____ sacrificar la rima." (for)','por',array['de','con','en'],'for',3),
  (v_l6,'multiple_choice','What does "asumir" mean?','to assume (responsibility)',array['to assert','to assist','to assess'],'to assume',4),
  (v_l6,'multiple_choice','What does "justificar" mean?','to justify',array['to justice','to justify (incorrect)','to justess'],'to justify',5),
  (v_l7,'multiple_choice','What is "fidelity"?','la fidelidad',array['la fidelidad (incorrect)','la fideli','la fidelidad (only person)'],'fidelity',1),
  (v_l7,'multiple_choice','What is "fluency"?','la fluidez',array['la fluencia','la fluidez (incorrect)','la fluido'],'fluency',2),
  (v_l7,'fill_blank','Complete: "____ costa de cierta fidelidad." (at the)','A',array['Por','Con','En'],'at the cost of',3),
  (v_l7,'multiple_choice','What is "comparison"?','la comparación',array['la compara','la comparada','la comparación (incorrect)'],'comparison',4),
  (v_l7,'multiple_choice','What is "choice"?','la elección',array['la elegancia','la electa','el elegir'],'choice',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Para textos legales, prefiero la traducción literal',array['Para literatura, libre','Las herramientas CAT ayudan','La equivalencia es vital'],'For legal texts, I prefer literal translation',6),
  (v_l1,'listening','What did you hear?','Para literatura, libre',array['Para textos científicos, libre','Para textos técnicos, literal','Para todo, libre'],'For literature, free',7),
  (v_l1,'speaking','Say this aloud: "Para textos legales, prefiero la traducción literal."','Para textos legales, prefiero la traducción literal',array[]::text[],'For legal texts, I prefer literal translation.',8),
  (v_l1,'speaking','Say this aloud: "Para literatura, libre."','Para literatura, libre',array[]::text[],'For literature, free.',9),
  (v_l2,'listening','What did you hear?','Cuidado: "embarazada" significa "pregnant", no "embarrassed"',array['Cuidado con los falsos amigos','Embarazada es pregnant','No es embarrassed'],'Careful: ''embarazada'' means ''pregnant'', not ''embarrassed''',6),
  (v_l2,'listening','What did you hear?','significa "pregnant", no "embarrassed"',array['significa pregnant pero también embarrassed','significa embarrassed','significa avergonzada'],'means ''pregnant'', not ''embarrassed''',7),
  (v_l2,'speaking','Say this aloud: "Embarazada significa pregnant, no embarrassed."','Embarazada significa pregnant, no embarrassed',array[]::text[],'Embarazada means pregnant, not embarrassed.',8),
  (v_l2,'speaking','Say this aloud: "Cuidado con los falsos amigos."','Cuidado con los falsos amigos',array[]::text[],'Beware of false friends.',9),
  (v_l3,'listening','What did you hear?','"It''s raining cats and dogs" no se traduce literalmente, sino como "llueve a cántaros"',array['Es un idiomatismo común','No se puede traducir','Los idiomas difieren'],'''It''s raining cats and dogs'' is not translated literally, but as ''llueve a cántaros''',6),
  (v_l3,'listening','What did you hear?','sino como "llueve a cántaros"',array['sino como "llueve mucho"','sino como "está lloviendo"','sino como "diluvia"'],'but as ''llueve a cántaros''',7),
  (v_l3,'speaking','Say this aloud: "No literalmente, sino como llueve a cántaros."','No literalmente, sino como llueve a cántaros',array[]::text[],'Not literally, but as llueve a cántaros.',8),
  (v_l3,'speaking','Say this aloud: "El equivalente cultural es la clave."','El equivalente cultural es la clave',array[]::text[],'The cultural equivalent is the key.',9),
  (v_l6,'listening','What did you hear?','Aquí opté por sacrificar la rima en aras de preservar el sentido',array['Elegí la fidelidad','La fluidez es la clave','Decidí ser literal'],'Here I chose to sacrifice the rhyme for the sake of preserving the meaning',6),
  (v_l6,'listening','What did you hear?','en aras de preservar el sentido',array['en favor de la rima','a costa del sentido','sin perder fidelidad'],'for the sake of preserving the meaning',7),
  (v_l6,'speaking','Say this aloud: "Opté por sacrificar la rima."','Opté por sacrificar la rima',array[]::text[],'I chose to sacrifice the rhyme.',8),
  (v_l6,'speaking','Say this aloud: "En aras de preservar el sentido."','En aras de preservar el sentido',array[]::text[],'For the sake of preserving the meaning.',9),
  (v_l7,'listening','What did you hear?','La primera versión es más literal pero pierde fluidez',array['La segunda fluye','A costa de la fidelidad','La elección depende'],'The first version is more literal but loses fluency',6),
  (v_l7,'listening','What did you hear?','aunque a costa de cierta fidelidad léxica',array['sin perder fidelidad','con fidelidad total','manteniendo el matiz'],'although at the cost of some lexical fidelity',7),
  (v_l7,'speaking','Say this aloud: "La segunda fluye, aunque a costa de la fidelidad."','La segunda fluye, aunque a costa de la fidelidad',array[]::text[],'The second flows, although at the cost of fidelity.',8),
  (v_l7,'speaking','Say this aloud: "A costa de cierta fidelidad léxica."','A costa de cierta fidelidad léxica',array[]::text[],'At the cost of some lexical fidelity.',9);

  update public.lessons set type='conversation', title='Translation Skills — Conversation Practice',
    description='Two translators discuss a project.',
    intro='Carmen and Diego review a passage together.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Carmen","spanish":"¿Cómo tradujiste "It''s raining cats and dogs"?","english":"How did you translate ''It''s raining cats and dogs''?"},{"speaker":"Diego","spanish":"Como "llueve a cántaros". No literalmente, sino con el equivalente cultural.","english":"As ''llueve a cántaros''. Not literally, but with the cultural equivalent."},{"speaker":"Carmen","spanish":"Bien. Y para "embarrassed", supongo que no usaste "embarazada".","english":"Good. And for ''embarrassed'', I assume you didn''t use ''embarazada''."},{"speaker":"Diego","spanish":"Qué va. Falso amigo clásico. Usé "avergonzado".","english":"No way. Classic false friend. I used ''avergonzado''."},{"speaker":"Carmen","spanish":"En este poema, opté por sacrificar la rima en aras de preservar el sentido.","english":"In this poem, I chose to sacrifice the rhyme for the sake of preserving the meaning."},{"speaker":"Diego","spanish":"Es lo mejor. La fidelidad léxica a costa del sentido no merece la pena.","english":"It''s the best. Lexical fidelity at the cost of meaning isn''t worth it."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','How did Diego translate "raining cats and dogs"?','llueve a cántaros',array['lloviendo gatos y perros','llueven gatos','llovizna intenso'],'llueve a cántaros',1),
  (v_l8,'multiple_choice','What''s wrong with "embarazada" for "embarrassed"?','It means pregnant',array['It''s outdated','It''s vulgar','It''s correct'],'embarazada = pregnant',2),
  (v_l8,'multiple_choice','Diego''s choice for "embarrassed"?','avergonzado',array['embarazado','vergonzoso','tímido'],'avergonzado',3),
  (v_l8,'multiple_choice','Carmen''s decision in the poem?','Sacrifice rhyme to preserve meaning',array['Preserve rhyme above all','Translate literally','Skip the poem'],'sacrificar la rima',4),
  (v_l8,'fill_blank','Complete: "Opté ____ sacrificar la rima." (for)','por',array['de','con','en'],'for',5),
  (v_l8,'multiple_choice','Diego''s principle?','Lexical fidelity at meaning''s cost not worth it',array['Always literal','Always free','Never sacrifice'],'a costa del sentido no merece la pena',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Translation Skills', 'Review test for the Translation Skills section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "source language"?','la lengua de partida',array['la lengua final','la lengua materna','la lengua objetivo'],'source language',1),
  (v_lesson_id,'multiple_choice','What does "embarazada" mean?','pregnant',array['embarrassed','occupied','imprisoned'],'pregnant',2),
  (v_lesson_id,'multiple_choice','What does "actualmente" mean?','currently',array['actually','effectively','really'],'currently',3),
  (v_lesson_id,'multiple_choice','What is "machine translation"?','la traducción automática',array['la traducción de máquina','la traducción mecánica','la auto-traducción'],'machine translation',4),
  (v_lesson_id,'fill_blank','Complete: "No literalmente ____ como cántaros." (but rather)','sino',array['pero','sino que','si no'],'but rather',5),
  (v_lesson_id,'fill_blank','Complete: "Opté ____ sacrificar la rima." (for)','por',array['de','con','en'],'for',6),
  (v_lesson_id,'listening','What did you hear?','En aras de preservar el sentido',array['A costa de la fidelidad','Para textos legales prefiero literal','La equivalencia cultural es clave'],'For the sake of preserving the meaning',7),
  (v_lesson_id,'listening','What did you hear?','"It''s raining cats and dogs" no se traduce literalmente, sino como "llueve a cántaros"',array['Embarazada no significa embarrassed','Actualmente no significa actually','La traducción automática es útil'],'''It''s raining cats and dogs'' is not translated literally, but as ''llueve a cántaros''',8),
  (v_lesson_id,'speaking','Say this aloud: "Para textos legales, prefiero la traducción literal."','Para textos legales, prefiero la traducción literal',array[]::text[],'For legal texts, I prefer literal translation.',9),
  (v_lesson_id,'speaking','Say this aloud: "Opté por sacrificar la rima en aras del sentido."','Opté por sacrificar la rima en aras del sentido',array[]::text[],'I chose to sacrifice the rhyme for the sake of the meaning.',10);

  -- ===========================================================
  -- C1.15 LANGUAGE TEACHING
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'C1' and title = 'Language Teaching';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='Teaching methodologies: gramatical-translation, audiolingual, communicative. Spanish as a Foreign Language (ELE).',
    vocab_items='[{"spanish":"la didáctica","english":"didactics"},{"spanish":"la metodología","english":"methodology"},{"spanish":"el método comunicativo","english":"communicative method"},{"spanish":"el ELE","english":"ELE (Sp. as Foreign Lg.)"},{"spanish":"el alumnado","english":"student body"},{"spanish":"el aprendizaje","english":"learning"},{"spanish":"la adquisición","english":"acquisition"},{"spanish":"el input","english":"input"},{"spanish":"el output","english":"output"},{"spanish":"la interlengua","english":"interlanguage"}]'::jsonb,
    dialogue='[{"speaker":"Profesor","spanish":"El método comunicativo prioriza el uso real sobre el dominio gramatical aislado.","english":"The communicative method prioritizes real use over isolated grammatical mastery."}]'::jsonb,
    grammar_note='"Priorizar X sobre Y" = "to prioritize X over Y". Useful construction for stating pedagogical values: "priorizamos el fondo sobre la forma".'
  where id = v_l1;

  update public.lessons set
    intro='Lesson planning: objectives, content, activities, assessment. The architecture of effective teaching.',
    vocab_items='[{"spanish":"la planificación","english":"planning"},{"spanish":"la unidad didáctica","english":"didactic unit"},{"spanish":"los objetivos","english":"objectives"},{"spanish":"los contenidos","english":"contents"},{"spanish":"las actividades","english":"activities"},{"spanish":"la evaluación","english":"assessment"},{"spanish":"la secuencia didáctica","english":"didactic sequence"},{"spanish":"la práctica controlada","english":"controlled practice"},{"spanish":"la práctica libre","english":"free practice"}]'::jsonb,
    dialogue='[{"speaker":"Profesora","spanish":"Diseña la secuencia de modo que cada actividad active lo aprendido en la anterior.","english":"Design the sequence so each activity activates what was learned in the previous one."}]'::jsonb,
    grammar_note='"De modo que + subjunctive" = "so that...": "de modo que cada actividad active". Purpose clause requiring subjunctive — variant of "para que".'
  where id = v_l2;

  update public.lessons set
    intro='Classroom management: instructions, transitions, corrections. The teacher''s linguistic toolkit.',
    vocab_items='[{"spanish":"la gestión de aula","english":"classroom management"},{"spanish":"la instrucción","english":"instruction"},{"spanish":"la transición","english":"transition"},{"spanish":"la corrección","english":"correction"},{"spanish":"el feedback","english":"feedback"},{"spanish":"la autocorrección","english":"self-correction"},{"spanish":"la corrección entre pares","english":"peer correction"},{"spanish":"el silencio","english":"silence"},{"spanish":"la espera","english":"wait time"}]'::jsonb,
    dialogue='[{"speaker":"Profesora","spanish":"En lugar de corregir directamente, pregunto: "¿Puedes reformularlo?". Suele funcionar.","english":"Instead of correcting directly, I ask: ''Can you rephrase it?''. It usually works."}]'::jsonb,
    grammar_note='"En lugar de + infinitive" = "instead of + V-ing": "en lugar de corregir". The "de" is essential — "en lugar que" doesn''t exist.'
  where id = v_l3;

  update public.lessons set
    intro='Error analysis: which errors matter, when to correct, how to correct. The pedagogy of error.',
    vocab_items='[{"spanish":"el error","english":"error"},{"spanish":"la equivocación","english":"slip"},{"spanish":"la falta","english":"mistake"},{"spanish":"el fosilizado","english":"fossilized error"},{"spanish":"sistemático","english":"systematic"},{"spanish":"esporádico","english":"sporadic"},{"spanish":"intervenir","english":"to intervene"},{"spanish":"la transferencia","english":"transfer (L1→L2)"},{"spanish":"la sobregeneralización","english":"overgeneralization"}]'::jsonb,
    dialogue='[{"speaker":"Profesora","spanish":"No todos los errores merecen corrección inmediata: los sistemáticos sí, los esporádicos pueden esperar.","english":"Not all errors deserve immediate correction: systematic ones yes, sporadic ones can wait."}]'::jsonb,
    grammar_note='"No todos + plural noun + verb" = "not all + noun + verb". Compare with "ninguno" (none). "No todos los errores" preserves the partial scope.'
  where id = v_l4;

  update public.lessons set
    intro='Motivation and learner autonomy: how to foster engagement and self-directed learning.',
    vocab_items='[{"spanish":"la motivación","english":"motivation"},{"spanish":"intrínseco","english":"intrinsic"},{"spanish":"extrínseco","english":"extrinsic"},{"spanish":"la autonomía","english":"autonomy"},{"spanish":"el aprendizaje autónomo","english":"autonomous learning"},{"spanish":"fomentar","english":"to foster"},{"spanish":"empoderar","english":"to empower"},{"spanish":"el reto","english":"challenge"},{"spanish":"la curiosidad","english":"curiosity"}]'::jsonb,
    dialogue='[{"speaker":"Profesora","spanish":"Lo crucial es fomentar la curiosidad: si el alumno se pregunta "por qué", está aprendiendo de verdad.","english":"What''s crucial is to foster curiosity: if the student asks ''why'', they''re really learning."}]'::jsonb,
    grammar_note='"Lo crucial es + infinitive" = "what''s crucial is to + verb". The neuter "lo + adjective" turns the adjective into an abstract subject.'
  where id = v_l5;

  update public.lessons set
    intro='Listen to a teacher training session. Note the technical vocabulary used by experienced teachers.',
    vocab_items='[{"spanish":"la formación docente","english":"teacher training"},{"spanish":"el formador","english":"trainer"},{"spanish":"compartir","english":"to share"},{"spanish":"la experiencia","english":"experience"},{"spanish":"el desafío","english":"challenge"},{"spanish":"la práctica reflexiva","english":"reflective practice"}]'::jsonb,
    dialogue='[{"speaker":"Formadora","spanish":"Lo que diferencia a un buen profesor de uno excelente es la práctica reflexiva: revisar cada clase y preguntarse qué pudo mejorarse.","english":"What distinguishes a good teacher from an excellent one is reflective practice: reviewing each class and asking what could have been improved."}]'::jsonb,
    grammar_note='"Qué pudo mejorarse" = "what could be improved (in retrospect)". The "pudo" + reflexive infinitive expresses a possibility about a past situation.'
  where id = v_l6;

  update public.lessons set
    intro='Write a brief lesson plan. Three sections: warm-up, focus, practice. Half a page.',
    vocab_items='[{"spanish":"el plan de clase","english":"lesson plan"},{"spanish":"el calentamiento","english":"warm-up"},{"spanish":"el foco","english":"focus"},{"spanish":"la práctica","english":"practice"},{"spanish":"el cierre","english":"closing"},{"spanish":"la duración","english":"duration"},{"spanish":"los materiales","english":"materials"}]'::jsonb,
    dialogue='[{"speaker":"Plan","spanish":"Objetivo: que los alumnos usen el subjuntivo en consejos. Calentamiento: lluvia de ideas (5 min). Foco: presentar el patrón (10 min). Práctica: rol-play en parejas (15 min).","english":"Objective: that students use subjunctive in advice. Warm-up: brainstorming (5 min). Focus: present the pattern (10 min). Practice: pair role-play (15 min)."}]'::jsonb,
    grammar_note='"Que + subjunctive" introducing objectives: "objetivo: que los alumnos usen". Standard pedagogical phrasing for learning targets.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "ELE"?','Spanish as a Foreign Language',array['Spanish for Children','Spanish Elementary','Spanish Listening'],'ELE',1),
  (v_l1,'multiple_choice','What is "interlanguage"?','la interlengua',array['la lengua entre','el lenguaje internacional','la lengua intermedia'],'interlanguage',2),
  (v_l1,'fill_blank','Complete: "Prioriza el uso real ____ el dominio." (over)','sobre',array['en','de','para'],'over',3),
  (v_l1,'multiple_choice','What is "acquisition"?','la adquisición',array['la adquisicón','la adquisición (incorrect)','la adopción'],'acquisition',4),
  (v_l1,'multiple_choice','What is "student body"?','el alumnado',array['los alumnos (only)','el alumno','la alumna'],'student body',5),
  (v_l2,'multiple_choice','What is "didactic unit"?','la unidad didáctica',array['la unidad de didactic','la lección plana','la sección'],'didactic unit',1),
  (v_l2,'multiple_choice','What follows "de modo que"?','subjunctive',array['indicative','infinitive','imperative'],'de modo que + subj',2),
  (v_l2,'fill_blank','Complete: "De modo que cada actividad ____" (activates — subj)','active',array['activa','activaba','activará'],'activates (subj)',3),
  (v_l2,'multiple_choice','What is "controlled practice"?','la práctica controlada',array['la práctica con control','la práctica precisa','la práctica regulada'],'controlled practice',4),
  (v_l2,'multiple_choice','What is "free practice"?','la práctica libre',array['la práctica libre (incorrect)','la práctica abierta','la práctica gratis'],'free practice',5),
  (v_l3,'multiple_choice','What does "en lugar de" mean?','instead of',array['in the place','in lieu','in the location'],'instead of',1),
  (v_l3,'multiple_choice','What is "peer correction"?','la corrección entre pares',array['la corrección por pares','la corrección de iguales','la corrección par'],'peer correction',2),
  (v_l3,'fill_blank','Complete: "En lugar ____ corregir." (of)','de',array['en','para','por'],'of',3),
  (v_l3,'multiple_choice','What does "reformular" mean?','to rephrase',array['to reformulate (math)','to refer','to refresh'],'to rephrase',4),
  (v_l3,'multiple_choice','What is "wait time"?','la espera',array['el tiempo','la hora','la pausa'],'wait time',5),
  (v_l4,'multiple_choice','What is "fossilized error"?','el fosilizado',array['el fósil','el fosilizar','el fosilato'],'fossilized error',1),
  (v_l4,'multiple_choice','What is "overgeneralization"?','la sobregeneralización',array['la sobrenarración','la sobrecarga','la sobreabundancia'],'overgeneralization',2),
  (v_l4,'fill_blank','Complete: "No todos ____ errores merecen corrección." (the)','los',array['las','de','el'],'the',3),
  (v_l4,'multiple_choice','What is "transfer" (L1→L2)?','la transferencia',array['la transferida','la transferir','la transfusión'],'transfer',4),
  (v_l4,'multiple_choice','What is "sporadic"?','esporádico',array['esporádico (incorrect)','espontáneo','sporadico'],'sporadic',5),
  (v_l5,'multiple_choice','What is "intrinsic"?','intrínseco',array['interno','intrínseco (incorrect)','intrínsico'],'intrinsic',1),
  (v_l5,'multiple_choice','What is "autonomy"?','la autonomía',array['la autonomía (incorrect)','el autónomo','la autonomidad'],'autonomy',2),
  (v_l5,'fill_blank','Complete: "____ crucial es fomentar la curiosidad." (what is)','Lo',array['El','La','Lo (incorrect)'],'what is',3),
  (v_l5,'multiple_choice','What does "fomentar" mean?','to foster',array['to phone','to fold','to forge'],'to foster',4),
  (v_l5,'multiple_choice','What does "empoderar" mean?','to empower',array['to empire','to employ','to empty'],'to empower',5),
  (v_l6,'multiple_choice','What is "teacher training"?','la formación docente',array['la formación profesoral','la formación del docente','la formación maestra'],'teacher training',1),
  (v_l6,'multiple_choice','What is "reflective practice"?','la práctica reflexiva',array['la práctica reflexa','la práctica refleja','la práctica de reflexión'],'reflective practice',2),
  (v_l6,'fill_blank','Complete: "Preguntarse qué ____ mejorarse." (could - retrospective)','pudo',array['pudo (incorrect)','pueda','podrá'],'could (retrospective)',3),
  (v_l6,'multiple_choice','What is "trainer"?','el formador',array['el formato','el formatador','el formador (incorrect)'],'trainer',4),
  (v_l6,'multiple_choice','What is "challenge"?','el desafío',array['el desafiar','el desafiado','el desafiamiento'],'challenge',5),
  (v_l7,'multiple_choice','What is "warm-up"?','el calentamiento',array['el caliente','el calentar','el caldo'],'warm-up',1),
  (v_l7,'multiple_choice','What is "closing"?','el cierre',array['el cerrar','el cerrado','el cerco'],'closing',2),
  (v_l7,'fill_blank','Complete: "Objetivo: que los alumnos ____ el subjuntivo." (use — subj)','usen',array['usan','usaron','usarán'],'use (subj)',3),
  (v_l7,'multiple_choice','What is "duration"?','la duración',array['la durabilidad','la duradera','la dura'],'duration',4),
  (v_l7,'multiple_choice','What is "materials"?','los materiales',array['los materias','las materiales','el material (singular)'],'materials',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','El método comunicativo prioriza el uso real sobre el dominio gramatical aislado',array['La metodología es flexible','El input es prioritario','La práctica es esencial'],'The communicative method prioritizes real use over isolated grammatical mastery',6),
  (v_l1,'listening','What did you hear?','sobre el dominio gramatical aislado',array['sobre la gramática integrada','sobre el vocabulario','sobre la lectura'],'over isolated grammatical mastery',7),
  (v_l1,'speaking','Say this aloud: "El método comunicativo prioriza el uso real."','El método comunicativo prioriza el uso real',array[]::text[],'The communicative method prioritizes real use.',8),
  (v_l1,'speaking','Say this aloud: "Sobre el dominio gramatical aislado."','Sobre el dominio gramatical aislado',array[]::text[],'Over isolated grammatical mastery.',9),
  (v_l2,'listening','What did you hear?','Diseña la secuencia de modo que cada actividad active lo aprendido en la anterior',array['Las actividades fluyen','La práctica es necesaria','El cierre es importante'],'Design the sequence so each activity activates what was learned in the previous one',6),
  (v_l2,'listening','What did you hear?','de modo que cada actividad active lo aprendido',array['para que cada actividad practique','con el fin de que cada actividad refuerce','de modo que cada lección termine'],'so each activity activates what was learned',7),
  (v_l2,'speaking','Say this aloud: "De modo que cada actividad active lo aprendido."','De modo que cada actividad active lo aprendido',array[]::text[],'So each activity activates what was learned.',8),
  (v_l2,'speaking','Say this aloud: "Diseña la secuencia con cuidado."','Diseña la secuencia con cuidado',array[]::text[],'Design the sequence carefully.',9),
  (v_l3,'listening','What did you hear?','En lugar de corregir directamente, pregunto: "¿Puedes reformularlo?". Suele funcionar',array['La autocorrección es clave','El silencio importa','El feedback es vital'],'Instead of correcting directly, I ask: ''Can you rephrase it?''. It usually works',6),
  (v_l3,'listening','What did you hear?','suele funcionar',array['suele fallar','siempre funciona','nunca funciona'],'it usually works',7),
  (v_l3,'speaking','Say this aloud: "En lugar de corregir, pregunto: puedes reformularlo?"','En lugar de corregir, pregunto: puedes reformularlo?',array[]::text[],'Instead of correcting, I ask: can you rephrase it?',8),
  (v_l3,'speaking','Say this aloud: "Suele funcionar."','Suele funcionar',array[]::text[],'It usually works.',9),
  (v_l6,'listening','What did you hear?','Lo que diferencia a un buen profesor de uno excelente es la práctica reflexiva',array['La formación es continua','El docente debe reflexionar','La experiencia importa'],'What distinguishes a good teacher from an excellent one is reflective practice',6),
  (v_l6,'listening','What did you hear?','revisar cada clase y preguntarse qué pudo mejorarse',array['preparar cada clase','reflexionar sobre el resultado','escuchar a los alumnos'],'reviewing each class and asking what could have been improved',7),
  (v_l6,'speaking','Say this aloud: "La práctica reflexiva diferencia al docente excelente."','La práctica reflexiva diferencia al docente excelente',array[]::text[],'Reflective practice distinguishes the excellent teacher.',8),
  (v_l6,'speaking','Say this aloud: "Preguntarse qué pudo mejorarse."','Preguntarse qué pudo mejorarse',array[]::text[],'Asking what could have been improved.',9),
  (v_l7,'listening','What did you hear?','Objetivo: que los alumnos usen el subjuntivo en consejos',array['Lluvia de ideas (5 min)','Presentar el patrón (10 min)','Rol-play en parejas (15 min)'],'Objective: that students use subjunctive in advice',6),
  (v_l7,'listening','What did you hear?','Práctica: rol-play en parejas (15 min)',array['Calentamiento: lluvia de ideas','Foco: presentar el patrón','Cierre: revisión'],'Practice: pair role-play (15 min)',7),
  (v_l7,'speaking','Say this aloud: "Objetivo: que los alumnos usen el subjuntivo."','Objetivo: que los alumnos usen el subjuntivo',array[]::text[],'Objective: that students use the subjunctive.',8),
  (v_l7,'speaking','Say this aloud: "Calentamiento: lluvia de ideas."','Calentamiento: lluvia de ideas',array[]::text[],'Warm-up: brainstorming.',9);

  update public.lessons set type='conversation', title='Language Teaching — Conversation Practice',
    description='Two teachers compare strategies.',
    intro='Inés and Daniel debrief after class.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Inés","spanish":"¿Cómo te fue la clase de hoy?","english":"How did your class go today?"},{"speaker":"Daniel","spanish":"Bien. Apliqué el método comunicativo: priorizar el uso real sobre la gramática aislada.","english":"Well. I applied the communicative method: prioritize real use over isolated grammar."},{"speaker":"Inés","spanish":"¿Y la corrección? Yo, en lugar de corregir directamente, pregunto si pueden reformularlo.","english":"And correction? I, instead of correcting directly, ask if they can rephrase it."},{"speaker":"Daniel","spanish":"Suele funcionar. Y diseñé la secuencia de modo que cada actividad activara lo aprendido en la anterior.","english":"It usually works. And I designed the sequence so each activity activated what was learned in the previous one."},{"speaker":"Inés","spanish":"Lo crucial es fomentar la curiosidad. Si el alumno se pregunta por qué, está aprendiendo de verdad.","english":"What''s crucial is to foster curiosity. If the student asks why, they''re really learning."},{"speaker":"Daniel","spanish":"De acuerdo. La práctica reflexiva nos hará a todos mejores docentes.","english":"Agreed. Reflective practice will make us all better teachers."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','Daniel''s method?','Communicative — real use over isolated grammar',array['Grammar-translation','Audiolingual','Silent way'],'método comunicativo',1),
  (v_l8,'multiple_choice','Inés''s correction technique?','Ask students to rephrase',array['Correct directly','Ignore errors','Mark everything'],'preguntar si pueden reformularlo',2),
  (v_l8,'multiple_choice','Daniel''s sequence design?','Each activity builds on previous',array['Random order','Difficulty descending','Same level throughout'],'de modo que cada actividad activara',3),
  (v_l8,'multiple_choice','Inés''s pedagogical principle?','Foster curiosity',array['Drill grammar','Memorize vocabulary','Translate texts'],'fomentar la curiosidad',4),
  (v_l8,'fill_blank','Complete: "De modo que cada actividad ____ lo aprendido." (activated — subj)','activara',array['activa','activaba','activará'],'activated (subj)',5),
  (v_l8,'multiple_choice','Daniel''s conclusion?','Reflective practice will make all better teachers',array['Teaching is innate','Methods don''t matter','Experience is enough'],'la práctica reflexiva nos hará mejores',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Language Teaching', 'Review test for the Language Teaching section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "ELE"?','Spanish as a Foreign Language',array['Spanish for Children','Spanish Elementary','Spanish Listening'],'ELE',1),
  (v_lesson_id,'multiple_choice','What follows "de modo que"?','subjunctive',array['indicative','infinitive','imperative'],'de modo que + subj',2),
  (v_lesson_id,'multiple_choice','What does "en lugar de" mean?','instead of',array['in the place','in lieu','in the location'],'instead of',3),
  (v_lesson_id,'multiple_choice','What does "fomentar" mean?','to foster',array['to phone','to fold','to forge'],'to foster',4),
  (v_lesson_id,'fill_blank','Complete: "Que los alumnos ____ el subjuntivo." (use — subj)','usen',array['usan','usaron','usarán'],'use (subj)',5),
  (v_lesson_id,'fill_blank','Complete: "____ crucial es fomentar la curiosidad." (what''s)','Lo',array['El','La','Le'],'what''s',6),
  (v_lesson_id,'listening','What did you hear?','El método comunicativo prioriza el uso real sobre el dominio gramatical aislado',array['La gestión de aula es vital','La autocorrección es clave','La motivación importa'],'The communicative method prioritizes real use over isolated grammatical mastery',7),
  (v_lesson_id,'listening','What did you hear?','En lugar de corregir directamente, pregunto si pueden reformularlo',array['Lo crucial es fomentar la curiosidad','La práctica reflexiva diferencia','Objetivo: que los alumnos usen'],'Instead of correcting directly, I ask if they can rephrase it',8),
  (v_lesson_id,'speaking','Say this aloud: "Priorizar el uso real sobre la gramática aislada."','Priorizar el uso real sobre la gramática aislada',array[]::text[],'Prioritize real use over isolated grammar.',9),
  (v_lesson_id,'speaking','Say this aloud: "Lo crucial es fomentar la curiosidad."','Lo crucial es fomentar la curiosidad',array[]::text[],'What''s crucial is to foster curiosity.',10);

end $$;

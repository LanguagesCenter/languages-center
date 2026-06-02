-- 014_spanish_c1_real_content.sql
-- Real Spanish C1 lesson content + the C1 article.
-- Idempotent: re-running deletes Spanish C1 + C1 article and reseeds.
-- A1 (010), A2 (011), B1 (012), B2 (013) stay on their current content.
--
-- C1 introduces: full subjunctive mastery (imperfect, present perfect,
-- pluperfect subjunctive: hubiera + participle), conditional perfect
-- (habría + participle), sequence of tenses, reported speech with
-- shifted tenses, complex conjunctions requiring subjunctive
-- (a no ser que, con tal de que, siempre y cuando, en cuanto),
-- relative pronouns (cuyo, quien, lo cual), refined connectors
-- (por consiguiente, no obstante, asimismo, en cuanto a),
-- highly idiomatic expressions and register-specific vocabulary.

do $$
declare
  v_lang_id   bigint;
  v_course_id bigint;
  v_lesson_id bigint;
begin
  select id into v_lang_id from public.languages where code = 'spanish';
  if v_lang_id is null then
    raise exception 'Spanish language not found in public.languages';
  end if;

  delete from public.courses  where language_id = v_lang_id and cefr_level = 'C1';
  delete from public.articles where language_id = v_lang_id and level = 'C1';

  -- =================== C1.1 IDIOMS & EXPRESSIONS ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Idioms & Expressions', 'Master colorful Spanish idioms and figurative expressions.', 'C1', 1)
  returning id into v_course_id;

  -- Lesson 1: common idioms
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Idioms — Lesson 1', 'Everyday idioms native speakers use.', 'vocabulary', 1, 30)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','What does "costar un ojo de la cara" mean?','to be very expensive',array['to be painful','to lose an eye','to be cheap'],'To cost an arm and a leg (lit: cost an eye of the face)',1),
    (v_lesson_id,'multiple_choice','What does "tomar el pelo" mean?','to pull someones leg',array['to brush hair','to grab hair','to take someone seriously'],'To pull someones leg (lit: take the hair)',2),
    (v_lesson_id,'multiple_choice','What does "dar en el clavo" mean?','to hit the nail on the head',array['to hammer in a nail','to nail a target','to miss the point'],'To hit the nail on the head (lit: give on the nail)',3),
    (v_lesson_id,'multiple_choice','What does "echar una mano" mean?','to lend a hand',array['to throw a hand','to wave','to shake hands'],'To lend a hand (lit: throw a hand)',4),
    (v_lesson_id,'multiple_choice','What does "tirar la toalla" mean?','to give up',array['to throw a towel','to do laundry','to dry off'],'To throw in the towel (give up)',5),
    (v_lesson_id,'multiple_choice','What does "no tener pelos en la lengua" mean?','to speak ones mind bluntly',array['to be hairless','to lie','to be quiet'],'To not mince words (lit: no hairs on the tongue)',6),
    (v_lesson_id,'multiple_choice','What does "ser pan comido" mean?','to be a piece of cake (easy)',array['to be hungry','to be filling','to be already eaten'],'A piece of cake (lit: eaten bread)',7),
    (v_lesson_id,'multiple_choice','What does "estar en las nubes" mean?','to have ones head in the clouds',array['to be flying','to be cloudy','to be far away'],'Head in the clouds (daydreaming)',8),
    (v_lesson_id,'multiple_choice','What does "hablar por los codos" mean?','to talk a lot / non-stop',array['to talk with elbows','to gesture','to talk quietly'],'To talk non-stop (lit: speak through the elbows)',9),
    (v_lesson_id,'multiple_choice','What does "meter la pata" mean?','to put your foot in it / make a blunder',array['to put a paw','to step on someone','to walk in mud'],'To screw up (lit: stick the paw in)',10),
    (v_lesson_id,'multiple_choice','What does "ponerse las pilas" mean?','to get going / get serious',array['to put on batteries','to charge a phone','to wake up'],'To buckle down (lit: put your batteries in)',11),
    (v_lesson_id,'multiple_choice','What does "ir al grano" mean?','to get to the point',array['to go to the grain','to eat seeds','to walk slowly'],'To get to the point (lit: go to the grain)',12),
    (v_lesson_id,'multiple_choice','What does "estar como pez en el agua" mean?','to be in ones element',array['to be wet','to be swimming','to be a fish'],'Like a fish in water (in your element)',13),
    (v_lesson_id,'multiple_choice','What does "tener mala pata" mean?','to have bad luck',array['to have a bad leg','to be a bad person','to be unlucky in love'],'To have bad luck (lit: have a bad paw)',14),
    (v_lesson_id,'multiple_choice','What does "estar hasta las narices" mean?','to be fed up',array['to have a stuffy nose','to be tall','to be tired'],'Fed up (lit: up to the noses)',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','me costó un ojo de la cara',array['me costó mucho dinero','me costó un riñón','me costó la cara'],'It cost me an arm and a leg',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','no te tomes el pelo',array['no me tomes el pelo','no te peines','no te pelo'],'Dont let yourself be fooled',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','vamos al grano',array['vamos al grano grande','vamos rápido','vamos al punto'],'Lets get to the point',18),
    (v_lesson_id,'speaking','Say "It was a piece of cake" in Spanish.','Fue pan comido',array[]::text[],'Fue pan comido',19),
    (v_lesson_id,'speaking','Say "Lets get to the point" in Spanish.','Vamos al grano',array[]::text[],'Vamos al grano',20),
    (v_lesson_id,'fill_blank','Complete: "Me costó un ___ de la cara." (eye)','ojo',array['pelo','clavo','grano'],'eye',21),
    (v_lesson_id,'fill_blank','Complete: "Hay que ponerse las ___" (batteries — get going)','pilas',array['piernas','manos','botas'],'batteries',22);

  -- Lesson 2: emotional / situational idioms
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Idioms — Lesson 2', 'Idioms for emotions and social situations.', 'phrases', 2, 30)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','What does "estar de mala leche" mean?','to be in a bad mood',array['to have bad milk','to be sick','to be tired'],'In a bad mood (vulgar, lit: of bad milk)',1),
    (v_lesson_id,'multiple_choice','What does "ser uña y carne" mean?','to be very close (friends)',array['to be one body','to be related','to fight a lot'],'Thick as thieves (lit: nail and flesh)',2),
    (v_lesson_id,'multiple_choice','What does "tirar la casa por la ventana" mean?','to spare no expense / go all out',array['to throw out furniture','to remodel','to move'],'To go all out (lit: throw the house out the window)',3),
    (v_lesson_id,'multiple_choice','What does "no pegar ojo" mean?','to not sleep a wink',array['to not hit eye','to be blind','to be tired'],'To not sleep a wink (lit: not stick eye)',4),
    (v_lesson_id,'multiple_choice','What does "estar entre la espada y la pared" mean?','to be between a rock and a hard place',array['to be in a fight','to be cornered physically','to be in danger'],'Between a rock and a hard place (lit: sword and wall)',5),
    (v_lesson_id,'multiple_choice','What does "tener la sartén por el mango" mean?','to be in control / call the shots',array['to be cooking','to hold a pan','to be in the kitchen'],'To be in control (lit: hold the pan by the handle)',6),
    (v_lesson_id,'multiple_choice','What does "buscarle tres pies al gato" mean?','to overcomplicate things',array['to find a cat','to look under things','to be picky'],'To overcomplicate (lit: find three feet on a cat)',7),
    (v_lesson_id,'multiple_choice','What does "dar gato por liebre" mean?','to deceive / pass something fake as real',array['to give a cat','to swap pets','to trade animals'],'To deceive (lit: give cat for hare)',8),
    (v_lesson_id,'multiple_choice','What does "ser la oveja negra" mean?','to be the black sheep',array['to be a black animal','to be different','to be alone'],'To be the black sheep',9),
    (v_lesson_id,'multiple_choice','What does "matar dos pájaros de un tiro" mean?','to kill two birds with one stone',array['to be a hunter','to kill animals','to shoot a gun'],'Kill two birds with one stone (lit: with one shot)',10),
    (v_lesson_id,'multiple_choice','What does "tener la cabeza en otro sitio" mean?','to have ones mind elsewhere',array['to have a misplaced head','to be confused','to be lost'],'Have your mind elsewhere',11),
    (v_lesson_id,'multiple_choice','What does "no dar palo al agua" mean?','to be lazy / not lift a finger',array['to swim','to fish','to be busy'],'Not lift a finger (lit: not give stick to water)',12),
    (v_lesson_id,'multiple_choice','What does "llover a cántaros" mean?','to rain cats and dogs / pour',array['to rain water','to rain heavily','to rain little'],'To pour (lit: rain by jugfuls)',13),
    (v_lesson_id,'multiple_choice','What does "ponerse rojo como un tomate" mean?','to blush deeply',array['to be a tomato','to be red','to be angry'],'To blush like a tomato',14),
    (v_lesson_id,'multiple_choice','What does "estar como una cabra" mean?','to be crazy / nuts',array['to be like a goat','to climb','to be agile'],'To be crazy (lit: like a goat)',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','está de mala leche hoy',array['está de buena leche','tiene mala leche','está mal hoy'],'Hes in a bad mood today',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','somos uña y carne',array['somos amigos','somos hermanos','somos íntimos'],'We are very close',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','no pegué ojo anoche',array['no dormí anoche','no pude dormir anoche','no abrí ojo anoche'],'I did not sleep a wink last night',18),
    (v_lesson_id,'speaking','Say "She is between a rock and a hard place" in Spanish.','Está entre la espada y la pared',array[]::text[],'Está entre la espada y la pared',19),
    (v_lesson_id,'speaking','Say "I killed two birds with one stone" in Spanish.','Maté dos pájaros de un tiro',array[]::text[],'Maté dos pájaros de un tiro',20),
    (v_lesson_id,'fill_blank','Complete: "Llovió a ___" (jugfuls — cats and dogs)','cántaros',array['cubos','baldes','gotas'],'jugfuls',21),
    (v_lesson_id,'fill_blank','Complete: "Está como una ___" (goat — crazy)','cabra',array['vaca','rata','oveja'],'goat',22);

  -- Lesson 3: idioms in context (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Idioms — Lesson 3', 'Recognize idioms in real conversations.', 'listening', 3, 30)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','Translate "Me ha tomado el pelo durante meses."','He has been pulling my leg for months',array['He has cut my hair for months','He has been mean for months','He took my hair'],'He has been deceiving me for months',1),
    (v_lesson_id,'multiple_choice','Translate "Tienes que ponerte las pilas si quieres aprobar."','You have to get going if you want to pass',array['Put batteries in if you want to pass','You have batteries for the exam','Charge up if you want to pass'],'You have to buckle down if you want to pass',2),
    (v_lesson_id,'multiple_choice','Translate "Esa casa cuesta un ojo de la cara."','That house costs an arm and a leg',array['That house has eyes','That house has a face','That house has a price'],'That house costs a fortune',3),
    (v_lesson_id,'multiple_choice','Translate "Me echó una mano cuando lo necesitaba."','He gave me a hand when I needed it',array['He threw a hand at me','He waved at me','He shook my hand'],'He helped me when I needed it',4),
    (v_lesson_id,'multiple_choice','Translate "No te andes con rodeos, ve al grano."','Stop beating around the bush, get to the point',array['Do not walk in circles','Go to the corn','Do not eat grain'],'Stop beating around the bush, get to the point',5),
    (v_lesson_id,'multiple_choice','Translate "Estaba en las nubes durante toda la clase."','He had his head in the clouds during the whole class',array['He was in the sky','He was flying','He was happy'],'He was daydreaming during the whole class',6),
    (v_lesson_id,'multiple_choice','How would you say "I am fed up" using an idiom?','Estoy hasta las narices',array['Estoy en la nariz','Estoy con la nariz','Estoy de nariz'],'Up to the nose (fed up)',7),
    (v_lesson_id,'multiple_choice','Translate "Después del examen me caí de cansado."','After the exam I was exhausted',array['I fell from tiredness','I got tired falling','I sat down'],'After the exam I was exhausted (idiom)',8),
    (v_lesson_id,'multiple_choice','What does "andarse con pies de plomo" mean?','to tread carefully',array['to walk in lead shoes','to have heavy feet','to be slow'],'To tread carefully (lit: walk with lead feet)',9),
    (v_lesson_id,'multiple_choice','What does "echar leña al fuego" mean?','to add fuel to the fire',array['to start a fire','to burn wood','to be hot'],'To add fuel to the fire',10),
    (v_lesson_id,'multiple_choice','What does "estar en la luna" mean?','to be distracted / out of it',array['to be on the moon','to be far','to be lonely'],'To be distracted (lit: on the moon)',11),
    (v_lesson_id,'multiple_choice','What does "tener mucha cara" mean?','to be cheeky / have a lot of nerve',array['to have a big face','to be ugly','to be brave'],'To be cheeky (lit: have a lot of face)',12),
    (v_lesson_id,'multiple_choice','What does "ser un cero a la izquierda" mean?','to be a nobody',array['to be number zero','to be on the left','to be last'],'To be a nobody (lit: zero to the left)',13),
    (v_lesson_id,'multiple_choice','What does "hacer la vista gorda" mean?','to turn a blind eye',array['to look big','to ignore','to wear glasses'],'To turn a blind eye',14),
    (v_lesson_id,'multiple_choice','What does "estar al pie del cañón" mean?','to be on duty / at ones post',array['to be at a foot of a cannon','to be ready to fight','to be active'],'To be on duty (lit: at the cannons foot)',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','ese tío tiene mucha cara',array['ese tío tiene cara','ese tío es muy caradura','ese tío tiene cara grande'],'That guy has a lot of nerve',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','no le eches leña al fuego',array['no le eches gasolina','no le eches agua','no le eches leña'],'Dont add fuel to the fire',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','siempre hace la vista gorda',array['siempre tiene la vista gorda','siempre ignora','hace la vista grande'],'He always turns a blind eye',18),
    (v_lesson_id,'speaking','Say "Stop beating around the bush" in Spanish.','Deja de andarte con rodeos',array[]::text[],'Deja de andarte con rodeos',19),
    (v_lesson_id,'speaking','Say "He helped me when I needed it" with an idiom in Spanish.','Me echó una mano cuando lo necesitaba',array[]::text[],'Me echó una mano cuando lo necesitaba',20),
    (v_lesson_id,'fill_blank','Complete: "Hace la ___ gorda." (turns a blind eye)','vista',array['cara','ojo','mirada'],'sight',21),
    (v_lesson_id,'fill_blank','Complete: "Anda con pies de ___" (lead — carefully)','plomo',array['hierro','piedra','goma'],'lead',22);

  -- Lesson 4: regional idioms + speaking
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Idioms — Lesson 4', 'Regional flavors and using idioms out loud.', 'speaking', 4, 30)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','In Mexico, "¡Qué padre!" means...','How cool!',array['Whats a dad','How is the father','Like a father'],'How cool! (Mexican slang)',1),
    (v_lesson_id,'multiple_choice','In Spain, "¡Mola!" means...','Cool! / Awesome!',array['It bothers','It grinds','It pleases'],'Cool! (Spain slang)',2),
    (v_lesson_id,'multiple_choice','In Argentina, "¡Qué quilombo!" means...','What a mess!',array['What a party','What a noise','What a fight'],'What a mess! (Argentina)',3),
    (v_lesson_id,'multiple_choice','In Colombia, "¡Chévere!" means...','Cool / Great!',array['Sour','Hot','Old'],'Cool! (Colombia/Caribbean)',4),
    (v_lesson_id,'multiple_choice','In Chile, "¿Cachai?" means...','Get it? / You know?',array['Do you fish','Do you catch','Take it'],'Get it? (Chilean)',5),
    (v_lesson_id,'multiple_choice','In Peru, "¡Qué chévere!" or "¡Qué bacán!" means...','How cool!',array['How tall','How bad','How nice'],'How cool! (Peru)',6),
    (v_lesson_id,'multiple_choice','In Spain, "currar" means...','to work (slang)',array['to run','to cure','to study'],'To work (Spain slang)',7),
    (v_lesson_id,'multiple_choice','In Mexico, "chamba" means...','job / work',array['party','food','friend'],'Job (Mexico slang)',8),
    (v_lesson_id,'multiple_choice','In Spain, "vale" means...','OK / alright',array['it costs','its worth','to value'],'OK (Spain, also "its worth")',9),
    (v_lesson_id,'multiple_choice','In Argentina, "che" is used like...','hey / dude (filler)',array['cheese','Chef','quickly'],'Hey/dude (Argentina, like "buddy")',10),
    (v_lesson_id,'multiple_choice','How do you say "no big deal" colloquially?','no pasa nada',array['no es grande','no problema','no es nada grande'],'No problem / no big deal',11),
    (v_lesson_id,'multiple_choice','How do you say "Whats up?" colloquially in Spain?','¿Qué pasa? / ¿Qué tal?',array['¿Qué hay?','¿Cómo está?','¿Cómo va?'],'Whats up?',12),
    (v_lesson_id,'multiple_choice','How do you say "totally / for sure"?','totalmente',array['del todo también','sin duda también','seguramente'],'Totally / for sure',13),
    (v_lesson_id,'multiple_choice','How do you say "Are you kidding me?"','¿Me estás vacilando?',array['¿Me tomas el pelo? también','¿Bromeas?','All correct'],'Are you kidding me?',14),
    (v_lesson_id,'multiple_choice','How do you use "guay" (Spain)?','to mean "cool"',array['to greet','to mean very','to mean little'],'Cool (Spain, neutral slang)',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','¡qué chévere!',array['¡qué padre!','¡qué bacán!','¡qué bueno!'],'How cool!',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','tengo mucho que currar',array['tengo mucho que correr','tengo mucho que cocinar','tengo mucha chamba'],'I have a lot of work',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','vale, hasta mañana',array['bien, hasta mañana','ok, hasta mañana','vale, hasta luego'],'OK, see you tomorrow',18),
    (v_lesson_id,'speaking','Say "How cool!" in casual Spanish.','¡Qué guay!',array[]::text[],'¡Qué guay!',19),
    (v_lesson_id,'speaking','Say "I have a lot of work" using slang.','Tengo mucho que currar',array[]::text[],'Tengo mucho que currar',20),
    (v_lesson_id,'fill_blank','Complete: "¡Qué ___!" (cool, Spain slang)','guay',array['mola','padre','chévere'],'cool',21),
    (v_lesson_id,'fill_blank','Complete: "Tengo mucha ___" (work, Mexico)','chamba',array['curro','trabajo','chambar'],'work',22);

  -- =================== C1.2 ADVANCED GRAMMAR ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Advanced Grammar', 'Master the subjunctive, conditionals and reported speech.', 'C1', 2)
  returning id into v_course_id;

  -- Lesson 1: imperfect subjunctive (all uses)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Grammar — Lesson 1', 'Imperfect subjunctive in every context.', 'grammar', 1, 30)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','Conjugate "I would do" — yo + hacer (conditional)','haría',array['hago','hice','hiciera'],'I would do [ah-REE-ah]',1),
    (v_lesson_id,'multiple_choice','Conjugate imperfect subjunctive: "if I had" — yo + tener','tuviera',array['tengo','tuve','tendría'],'If I had (imperfect subj.)',2),
    (v_lesson_id,'multiple_choice','Conjugate: "if she came" — ella + venir','viniera',array['viene','vino','vendría'],'If she came (imperfect subj.)',3),
    (v_lesson_id,'multiple_choice','Conjugate: "if you (informal) knew" — tú + saber','supieras',array['sabes','supiste','sabrías'],'If you knew (imperfect subj.)',4),
    (v_lesson_id,'multiple_choice','Conjugate: "if we did" — nosotros + hacer','hiciéramos',array['hacemos','hicimos','haríamos'],'If we did (imperfect subj.)',5),
    (v_lesson_id,'multiple_choice','Conjugate: "if they were" — ellos + ser','fueran',array['son','fueron','serían'],'If they were (imperfect subj.)',6),
    (v_lesson_id,'multiple_choice','Translate "Si tuviera dinero, viajaría más."','If I had money, I would travel more',array['I have money to travel','I had money and traveled','I will have money'],'If I had money, I would travel more',7),
    (v_lesson_id,'multiple_choice','Translate "Si fueras a Madrid, te encantaría."','If you went to Madrid, you would love it',array['You went to Madrid','You will love Madrid','Madrid loves you'],'If you went to Madrid, you would love it',8),
    (v_lesson_id,'multiple_choice','Which is correct for "I wanted them to come"?','Quería que vinieran',array['Quería que venían','Quería que vendrían','Quería que vendrán'],'Wanted + imperfect subj. for past action',9),
    (v_lesson_id,'multiple_choice','Which follows "Ojalá" + imperfect subj.?','Ojalá pudiera',array['Ojalá puedo','Ojalá podré','Ojalá podía'],'Ojalá (I wish) + imperfect subj. = wish for unlikely',10),
    (v_lesson_id,'multiple_choice','Translate "Ojalá tuviera tiempo."','I wish I had time',array['I have time','I will have time','Hopefully I have time'],'I wish I had time (counterfactual)',11),
    (v_lesson_id,'multiple_choice','Which is correct: "como si + ?"','como si fuera',array['como si es','como si será','como si era'],'As if + imperfect subj. (counterfactual)',12),
    (v_lesson_id,'multiple_choice','Translate "Habla como si supiera todo."','He talks as if he knew everything',array['He talks knowing everything','He will know everything','He talks because he knows'],'He talks as if he knew everything',13),
    (v_lesson_id,'multiple_choice','Translate "Era imposible que ganaran."','It was impossible for them to win',array['They won impossible','It is impossible to win','They will not win'],'It was impossible for them to win',14),
    (v_lesson_id,'multiple_choice','Translate "Me sorprendió que dijera eso."','It surprised me that he said that',array['I surprised him','He surprised me','He will say that'],'It surprised me that he said that',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','si tuviera tiempo, lo haría',array['si tengo tiempo lo hago','si tuviera tiempo lo hago','si tendría tiempo lo haría'],'If I had time, I would do it',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','ojalá pudiera ir',array['ojalá puedo ir','ojalá podré ir','ojalá iría'],'I wish I could go',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','habla como si supiera',array['habla porque sabe','habla como sabe','habla como si supiera todo'],'He talks as if he knew',18),
    (v_lesson_id,'speaking','Say "If I were richer, I would buy a house" in Spanish.','Si fuera más rico, compraría una casa',array[]::text[],'Si fuera más rico, compraría una casa',19),
    (v_lesson_id,'speaking','Say "I wish I had more time" in Spanish.','Ojalá tuviera más tiempo',array[]::text[],'Ojalá tuviera más tiempo',20),
    (v_lesson_id,'fill_blank','Complete: "Si yo ___ tú, lo haría." (were)','fuera',array['soy','fui','era'],'were (imp. subj.)',21),
    (v_lesson_id,'fill_blank','Complete: "Ojalá ___ saber la verdad." (could)','pudiera',array['puedo','podría','podía'],'could (imp. subj.)',22);

  -- Lesson 2: pluperfect subjunctive + conditional perfect
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Grammar — Lesson 2', 'Pluperfect subjunctive and conditional perfect.', 'grammar', 2, 30)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','Conjugate: "I had done" (subj.) — yo + haber + hacer','hubiera hecho',array['había hecho','he hecho','habría hecho'],'Pluperfect subj.: hubiera + participle',1),
    (v_lesson_id,'multiple_choice','Conjugate: "I would have done" — yo + haber + hacer','habría hecho',array['había hecho','hube hecho','hubiera hecho (subj.)'],'Conditional perfect: habría + participle',2),
    (v_lesson_id,'multiple_choice','Translate "Si hubiera estudiado, habría aprobado."','If I had studied, I would have passed',array['If I study, I will pass','I studied and passed','I should study'],'If I had studied, I would have passed (third conditional)',3),
    (v_lesson_id,'multiple_choice','Translate "Si me lo hubieras dicho, lo habría hecho."','If you had told me, I would have done it',array['If you tell me, I will do it','You told me and I did it','You will tell me'],'If you had told me, I would have done it',4),
    (v_lesson_id,'multiple_choice','Translate "Habría preferido quedarme."','I would have preferred to stay',array['I prefer to stay','I will prefer to stay','I had preferred to stay'],'I would have preferred to stay',5),
    (v_lesson_id,'multiple_choice','Translate "Si lo hubiera sabido, no habría venido."','If I had known, I would not have come',array['I know now','I came knowing','I will know'],'If I had known, I would not have come',6),
    (v_lesson_id,'multiple_choice','Which is the pluperfect subjunctive of "venir" (yo)?','hubiera venido',array['había venido','vine','habría venido (cond.)'],'I had come (subj.)',7),
    (v_lesson_id,'multiple_choice','Which is the pluperfect indicative of "venir" (yo)?','había venido',array['hubiera venido (subj.)','vine','habría venido (cond.)'],'I had come (indicative)',8),
    (v_lesson_id,'multiple_choice','When do you use "habría + participle"?','for "would have done"',array['for "had done"','for past actions','for present actions'],'Conditional perfect (would have)',9),
    (v_lesson_id,'multiple_choice','When do you use "hubiera + participle"?','after "si" in counterfactual past',array['in the present','in the future','in commands'],'Pluperfect subj. in si-clauses (past hypothetical)',10),
    (v_lesson_id,'multiple_choice','Translate "Ojalá no hubiera dicho eso."','I wish I had not said that',array['I wish I do not say that','I will not say that','I did not say that'],'I wish I had not said that',11),
    (v_lesson_id,'multiple_choice','Translate "Era una lástima que se hubieran ido."','It was a pity they had left',array['They will leave','They are leaving','It is a pity'],'It was a pity they had left',12),
    (v_lesson_id,'multiple_choice','Translate "Si hubiera tenido tiempo, te habría llamado."','If I had had time, I would have called you',array['I have time to call','I called you with time','I will call you'],'If I had had time, I would have called you',13),
    (v_lesson_id,'multiple_choice','Translate "No me sorprende que hayan llegado tarde."','It does not surprise me that they have arrived late',array['They were late','I am late','They surprised me'],'Pres. perf. subj.: that they have arrived late',14),
    (v_lesson_id,'multiple_choice','Which is correct: "I am glad you have come" — Me alegro de que...','hayas venido',array['has venido','viniste','vendrás'],'Pres. perf. subj.: hayas venido',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','si hubiera sabido habría venido',array['si sé vengo','si sabía venía','si supiera vendría'],'If I had known, I would have come',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','ojalá no hubiera dicho eso',array['ojalá no digo eso','ojalá no diría eso','ojalá no dijera eso'],'I wish I had not said that',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','me alegro de que hayas venido',array['me alegro que vienes','me alegro que viniste','me alegré que vinieras'],'Im glad you have come',18),
    (v_lesson_id,'speaking','Say "If I had studied more, I would have passed" in Spanish.','Si hubiera estudiado más, habría aprobado',array[]::text[],'Si hubiera estudiado más, habría aprobado',19),
    (v_lesson_id,'speaking','Say "Im glad you have come" in Spanish.','Me alegro de que hayas venido',array[]::text[],'Me alegro de que hayas venido',20),
    (v_lesson_id,'fill_blank','Complete: "Si lo ___ sabido, te lo habría dicho." (had)','hubiera',array['había','he','habré'],'had (plup. subj.)',21),
    (v_lesson_id,'fill_blank','Complete: "Te ___ llamado antes." (would have)','habría',array['había','he','hubiera'],'would have',22);

  -- Lesson 3: reported speech + sequence of tenses
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Grammar — Lesson 3', 'Reported speech and tense agreement.', 'listening', 3, 30)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','Direct: "Voy al cine." Reported: "Dijo que ___ al cine."','iba',array['voy','va','iría'],'present → imperfect in reported speech',1),
    (v_lesson_id,'multiple_choice','Direct: "Iré mañana." Reported: "Dijo que ___ al día siguiente."','iría',array['va','iba','vaya'],'future → conditional',2),
    (v_lesson_id,'multiple_choice','Direct: "Vine ayer." Reported: "Dijo que ___ el día anterior."','había venido',array['vino','ha venido','venía'],'preterite → pluperfect',3),
    (v_lesson_id,'multiple_choice','Direct: "Ven aquí." Reported: "Me dijo que ___ allí."','fuera',array['voy','iría','vaya'],'imperative → past subj.',4),
    (v_lesson_id,'multiple_choice','Direct: "¿Estás bien?" Reported: "Me preguntó si ___ bien."','estaba',array['estoy','estaría','esté'],'present → imperfect in indirect Qs',5),
    (v_lesson_id,'multiple_choice','Translate "Me dijo que no podía venir."','He told me he could not come',array['He told me to not come','He could not tell me','He cannot come'],'He told me he could not come',6),
    (v_lesson_id,'multiple_choice','Translate "Le pedí que me ayudara."','I asked him to help me',array['I help him','I asked him for help','I will ask him'],'I asked him to help me (imp. subj. after past tense)',7),
    (v_lesson_id,'multiple_choice','Translate "Nos contó que había viajado mucho."','He told us that he had traveled a lot',array['He travels with us','He will tell us','He told us to travel'],'He told us that he had traveled a lot',8),
    (v_lesson_id,'multiple_choice','Which connector means "however / nevertheless"?','no obstante',array['por consiguiente (therefore)','asimismo (likewise)','en cuanto a'],'However / nevertheless',9),
    (v_lesson_id,'multiple_choice','Which connector means "therefore / consequently"?','por consiguiente',array['no obstante','asimismo','sin embargo (however)'],'Therefore / consequently',10),
    (v_lesson_id,'multiple_choice','Which connector means "likewise / similarly"?','asimismo',array['no obstante','en cuanto a','por consiguiente'],'Likewise / similarly',11),
    (v_lesson_id,'multiple_choice','Which connector means "with respect to / regarding"?','en cuanto a',array['no obstante','asimismo','con tal de que'],'With respect to / regarding',12),
    (v_lesson_id,'multiple_choice','"Provided that / as long as" + subj. =','con tal de que',array['siempre y cuando también','a condición de que también','All correct'],'Provided that + subj.',13),
    (v_lesson_id,'multiple_choice','"Unless" + subj. =','a no ser que',array['a menos que también','salvo que también','All correct'],'Unless + subj.',14),
    (v_lesson_id,'multiple_choice','Translate "Te ayudaré con tal de que me lo pidas."','I will help you provided that you ask me',array['Help me if I ask','I will ask you for help','I have helped you'],'I will help you provided that you ask',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','dijo que vendría al día siguiente',array['dijo que vino al día siguiente','dice que vendrá mañana','dijo que viniera'],'He said he would come the next day',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','me pidió que le ayudara',array['me pidió ayuda','me pide ayudar','me pidió ayudo'],'He asked me to help him',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','no obstante, lo hizo',array['sin embargo lo hizo','obstante lo hizo','en cuanto a esto'],'Nevertheless, he did it',18),
    (v_lesson_id,'speaking','Say "He told me he would arrive late" in Spanish.','Me dijo que llegaría tarde',array[]::text[],'Me dijo que llegaría tarde',19),
    (v_lesson_id,'speaking','Say "Provided that you study, you will pass" in Spanish.','Con tal de que estudies, aprobarás',array[]::text[],'Con tal de que estudies, aprobarás',20),
    (v_lesson_id,'fill_blank','Complete: "A no ser que ___ pronto..." (you arrive)','llegues',array['llegas','llegarás','llegabas'],'you arrive (subj.)',21),
    (v_lesson_id,'fill_blank','Complete: "En ___ a este tema..." (regarding)','cuanto',array['cuando','cuanto a','respecto'],'extent / regards',22);

  -- Lesson 4: relative pronouns + nuances (speaking)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Grammar — Lesson 4', 'Relative pronouns and refined nuance.', 'speaking', 4, 30)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','Which relative pronoun means "whose"?','cuyo / cuya',array['que','quien','el que'],'Whose [KOO-yoh]',1),
    (v_lesson_id,'multiple_choice','Which is "who" referring to a person (subject)?','quien',array['que también (most common)','cuyo','el cual'],'Who (person, after preposition or comma)',2),
    (v_lesson_id,'multiple_choice','Translate "El hombre cuya hija vino es mi amigo."','The man whose daughter came is my friend',array['The man came with his daughter','My friend came with the man','The friend has a daughter'],'The man whose daughter came is my friend',3),
    (v_lesson_id,'multiple_choice','Translate "Mi vecino, quien es ingeniero, viaja mucho."','My neighbor, who is an engineer, travels a lot',array['My engineer neighbor traveled','My neighbor travels and is engineer','My engineer travels'],'My neighbor, who is an engineer, travels a lot',4),
    (v_lesson_id,'multiple_choice','"Lo cual" refers to...','a whole idea (not a noun)',array['a specific person','a specific thing','a place'],'Lo cual = "which" (refers to clause)',5),
    (v_lesson_id,'multiple_choice','Translate "Llegó tarde, lo cual me molestó."','He arrived late, which bothered me',array['He bothered me at lateness','He arrived bothered','I bothered him'],'He arrived late, which bothered me',6),
    (v_lesson_id,'multiple_choice','"Donde" introduces clauses about...','places',array['people','time','reasons'],'Where (places)',7),
    (v_lesson_id,'multiple_choice','"Cuando" introduces clauses about...','time',array['places','people','reasons'],'When (time)',8),
    (v_lesson_id,'multiple_choice','"Como" can introduce...','manner / way',array['places','time','people'],'How / manner',9),
    (v_lesson_id,'multiple_choice','Translate "Hazlo como te dije."','Do it the way I told you',array['Do it because I told you','Do it as I said','Do as you wish'],'Do it the way I told you',10),
    (v_lesson_id,'multiple_choice','"En cuanto" (as soon as) + future event uses...','subjunctive',array['indicative','infinitive','conditional'],'En cuanto + subj. for future',11),
    (v_lesson_id,'multiple_choice','Translate "Te llamaré en cuanto llegue."','I will call you as soon as I arrive',array['I called when I arrived','I will call but I will not arrive','I arrive and call'],'I will call you as soon as I arrive (subj.)',12),
    (v_lesson_id,'multiple_choice','"Antes de que" always takes...','subjunctive',array['indicative','infinitive','conditional'],'Before + subj. always',13),
    (v_lesson_id,'multiple_choice','Translate "Vete antes de que llegue mi padre."','Leave before my father arrives',array['You left before my father','My father left before','My father will arrive'],'Leave before my father arrives (subj.)',14),
    (v_lesson_id,'multiple_choice','Translate "Mi hermano, a quien no veía hace años, vino ayer."','My brother, whom I had not seen in years, came yesterday',array['I saw my brother years ago','My brother had not come','I saw my brother yesterday'],'My brother, whom I had not seen in years, came yesterday',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','el hombre cuya hija vino',array['el hombre con la hija','el hombre que tiene hija','el hombre cuya hija viene'],'The man whose daughter came',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','te llamaré en cuanto llegue',array['te llamaré cuando llegue','te llamaré cuando llegué','te llamaré en cuanto llegué'],'Ill call you as soon as I arrive',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','vete antes de que llegue',array['vete antes que llega','vete antes de que llegó','antes de llegar vete'],'Leave before he arrives',18),
    (v_lesson_id,'speaking','Say "My friend, whose name is Ana, is here" in Spanish.','Mi amiga, cuyo nombre es Ana, está aquí',array[]::text[],'Mi amiga, cuyo nombre es Ana, está aquí',19),
    (v_lesson_id,'speaking','Say "I will call you as soon as I get home" in Spanish.','Te llamaré en cuanto llegue a casa',array[]::text[],'Te llamaré en cuanto llegue a casa',20),
    (v_lesson_id,'fill_blank','Complete: "El libro ___ autor murió." (whose)','cuyo',array['quien','que','el cual'],'whose',21),
    (v_lesson_id,'fill_blank','Complete: "Vete antes de que ___" (he arrives)','llegue',array['llega','llegará','llegó'],'arrives (subj.)',22);

  -- =================== C1.3 FORMAL WRITING ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Formal Writing', 'Academic and professional writing register in Spanish.', 'C1', 3)
  returning id into v_course_id;

  -- Lesson 1: register + vocabulary
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Formal Writing — Lesson 1', 'Choose the right formal register.', 'vocabulary', 1, 30)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','Formal version of "ayudar"?','asistir',array['echar una mano','dar mano','aydar'],'To assist (formal)',1),
    (v_lesson_id,'multiple_choice','Formal version of "decir"?','manifestar',array['hablar','contar','platicar'],'To state (formal) [mah-nee-fehs-TAHR]',2),
    (v_lesson_id,'multiple_choice','Formal version of "empezar"?','comenzar',array['empezar (already neutral)','iniciar también','arrancar (colloquial)'],'To commence (formal)',3),
    (v_lesson_id,'multiple_choice','Formal version of "terminar"?','concluir',array['acabar','dejar','parar'],'To conclude (formal)',4),
    (v_lesson_id,'multiple_choice','Formal version of "hacer un estudio"?','realizar un estudio',array['hacer una investigación','llevar a cabo un estudio también','All correct (realizar / llevar a cabo)'],'To conduct a study',5),
    (v_lesson_id,'multiple_choice','How do you write "Dear Mr/Ms" formally?','Estimado/a Sr./Sra.',array['Querido','Hola','Saludos a'],'Dear (formal)',6),
    (v_lesson_id,'multiple_choice','How do you close a very formal letter?','Le saluda atentamente',array['Hasta luego','Saludos','Adiós'],'Yours sincerely (very formal)',7),
    (v_lesson_id,'multiple_choice','Formal "to think / to consider"?','considerar',array['pensar','creer','opinar'],'To consider [kohn-see-deh-RAHR]',8),
    (v_lesson_id,'multiple_choice','Formal "to give (a reason)"?','aducir',array['dar','poner','exponer también'],'To adduce / put forward',9),
    (v_lesson_id,'multiple_choice','Formal "to mention"?','mencionar',array['decir','hablar','citar'],'To mention',10),
    (v_lesson_id,'multiple_choice','Formal "to highlight"?','destacar',array['enfatizar también','subrayar','resaltar también'],'To highlight / emphasize',11),
    (v_lesson_id,'multiple_choice','Formal "to set out / present"?','exponer',array['mostrar','presentar','colocar'],'To set out / present (formal)',12),
    (v_lesson_id,'multiple_choice','Formal "to acknowledge / recognize"?','reconocer',array['admitir también','aceptar','admisión'],'To acknowledge',13),
    (v_lesson_id,'multiple_choice','Formal "to refer to (a topic)"?','referirse a',array['hablar de','tocar','tratar'],'To refer to',14),
    (v_lesson_id,'multiple_choice','Formal "in this respect"?','al respecto',array['sobre eso','en eso','con eso'],'In this respect [ahl rrehs-PEHK-toh]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','estimado señor garcía',array['querido señor garcía','hola señor garcía','sr. garcía'],'Dear Mr. García',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','le saluda atentamente',array['saludos atentamente','un saludo','atentamente'],'Yours sincerely',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','quisiera manifestar mi interés',array['quiero decir mi interés','manifestar mi interés','tengo interés en'],'I would like to state my interest',18),
    (v_lesson_id,'speaking','Say "I would like to state that..." formally in Spanish.','Quisiera manifestar que...',array[]::text[],'Quisiera manifestar que...',19),
    (v_lesson_id,'speaking','Say "Yours sincerely" in Spanish.','Le saluda atentamente',array[]::text[],'Le saluda atentamente',20),
    (v_lesson_id,'fill_blank','Complete: "___ Sr. Pérez:" (Dear)','Estimado',array['Querido','Hola','Saludos'],'Dear (formal)',21),
    (v_lesson_id,'fill_blank','Complete: "Le saluda ___" (sincerely)','atentamente',array['amistosamente','seriamente','formalmente'],'sincerely',22);

  -- Lesson 2: connectors + argument structure
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Formal Writing — Lesson 2', 'Structure paragraphs and arguments.', 'grammar', 2, 30)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','To open a paragraph: "First of all..."','En primer lugar...',array['Primero (informal)','Para empezar también','All correct'],'First of all',1),
    (v_lesson_id,'multiple_choice','To add a point: "Furthermore..."','Asimismo...',array['Además también','Por otra parte','All correct'],'Furthermore / likewise',2),
    (v_lesson_id,'multiple_choice','To contrast: "However..."','Sin embargo...',array['No obstante también','Por el contrario','All correct'],'However / nevertheless',3),
    (v_lesson_id,'multiple_choice','To conclude: "In conclusion..."','En conclusión...',array['Para concluir también','En resumen','All correct'],'In conclusion',4),
    (v_lesson_id,'multiple_choice','To exemplify: "For instance..."','Por ejemplo...',array['A modo de ejemplo también','Como ejemplo también','All correct'],'For instance',5),
    (v_lesson_id,'multiple_choice','To explain cause: "due to the fact that..."','debido a que...',array['porque (informal)','dado que también','All correct (debido a / dado que)'],'Due to the fact that',6),
    (v_lesson_id,'multiple_choice','To express result: "consequently"','por consiguiente',array['así que (informal)','por lo tanto también','All correct'],'Consequently',7),
    (v_lesson_id,'multiple_choice','To rephrase: "in other words..."','es decir...',array['o sea (informal)','en otras palabras también','All correct'],'In other words',8),
    (v_lesson_id,'multiple_choice','To concede: "It is true that... however..."','Si bien es cierto que..., no obstante...',array['Aunque es cierto pero','Cierto es que pero','Es verdad pero'],'It is true that..., however... (formal concession)',9),
    (v_lesson_id,'multiple_choice','To restate: "to put it briefly..."','en pocas palabras',array['en breve también','para resumir también','All correct'],'In brief',10),
    (v_lesson_id,'multiple_choice','To add evidence: "according to research..."','según los estudios',array['según indica la investigación también','de acuerdo con las investigaciones','All correct'],'According to research',11),
    (v_lesson_id,'multiple_choice','To hedge: "it could be argued that..."','podría argumentarse que',array['se podría decir que también','cabe argumentar que también','All correct'],'It could be argued that',12),
    (v_lesson_id,'multiple_choice','To reinforce: "without a doubt..."','sin lugar a dudas',array['sin duda alguna también','indudablemente también','All correct'],'Without a doubt',13),
    (v_lesson_id,'multiple_choice','To dismiss: "it goes without saying..."','huelga decir que',array['no hace falta decir también','va sin decir','All correct (huelga / no hace falta)'],'It goes without saying [WEHL-gah]',14),
    (v_lesson_id,'multiple_choice','Translate "Cabe destacar la importancia del tema."','It is worth highlighting the importance of the topic',array['I highlighted the topic','The topic is important to me','The topic has importance'],'It is worth highlighting the importance of the topic',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','en primer lugar es importante',array['en primer término','primero es importante','primero, es importante'],'First of all, it is important',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','por consiguiente, debemos actuar',array['por lo tanto debemos','así que actuar','consecuentemente actuemos'],'Consequently, we must act',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','cabe destacar que',array['hay que destacar','cabe decir','vale destacar'],'It is worth highlighting that',18),
    (v_lesson_id,'speaking','Say "In conclusion, the data is clear" formally in Spanish.','En conclusión, los datos son claros',array[]::text[],'En conclusión, los datos son claros',19),
    (v_lesson_id,'speaking','Say "It is worth highlighting that..." in Spanish.','Cabe destacar que...',array[]::text[],'Cabe destacar que...',20),
    (v_lesson_id,'fill_blank','Complete: "En ___ lugar..." (first)','primer',array['primero','un','primera'],'first',21),
    (v_lesson_id,'fill_blank','Complete: "Por ___, hay que actuar." (consequently)','consiguiente',array['eso','tanto','lo'],'consequently',22);

  -- Lesson 3: hedging + nominalization (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Formal Writing — Lesson 3', 'Hedge claims and use noun-heavy academic style.', 'listening', 3, 30)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','Hedge: "It seems that..."','Parece que...',array['Yo creer','Se ve que','Tal vez'],'It seems that [pah-REH-seh]',1),
    (v_lesson_id,'multiple_choice','Hedge: "It is likely that..."','Es probable que... (+ subj.)',array['Probable que','Es probable','Probablemente'],'It is likely that + subj.',2),
    (v_lesson_id,'multiple_choice','Hedge: "It tends to..."','Tiende a...',array['Va a','Suele también','All correct (tender a / soler)'],'It tends to',3),
    (v_lesson_id,'multiple_choice','Hedge: "It can be observed that..."','Cabe observar que...',array['Se puede ver','Hay que ver','Observamos que'],'It can be observed that (very formal)',4),
    (v_lesson_id,'multiple_choice','Nominalize "she analyzed the data" formally','el análisis de los datos',array['datos analizados','analizada los datos','la análisis'],'The analysis of the data (nominalization)',5),
    (v_lesson_id,'multiple_choice','Nominalize "they decided"','la decisión',array['decisivo','decidir','decidido'],'The decision',6),
    (v_lesson_id,'multiple_choice','Nominalize "we discovered"','el descubrimiento',array['descubierto','descubrir','descubrido'],'The discovery',7),
    (v_lesson_id,'multiple_choice','Formal "to study (in depth)"','profundizar en',array['estudiar profundo','estudiar mucho','ir profundo'],'To delve into [proh-foon-dee-SAHR]',8),
    (v_lesson_id,'multiple_choice','Formal "to address (a topic)"','abordar',array['atacar','tratar también','tocar (informal)'],'To address (a topic) [ah-bohr-DAHR]',9),
    (v_lesson_id,'multiple_choice','Formal "to overcome (a challenge)"','superar',array['vencer también','pasar','ganarse'],'To overcome [soo-peh-RAHR]',10),
    (v_lesson_id,'multiple_choice','Formal "to imply"','implicar',array['significar también','suponer también','All correct'],'To imply [eem-plee-KAHR]',11),
    (v_lesson_id,'multiple_choice','Formal "to derive from"','derivar de',array['venir de (informal)','salir de','originarse en también'],'To derive from',12),
    (v_lesson_id,'multiple_choice','Formal "to constitute"','constituir',array['ser','formar','componer también'],'To constitute [kohns-tee-too-EER]',13),
    (v_lesson_id,'multiple_choice','Formal "framework (theoretical)"','el marco teórico',array['marco de teoría','la teoría marco','la base'],'Theoretical framework [MAHR-koh]',14),
    (v_lesson_id,'multiple_choice','Translate "Cabe señalar que el fenómeno presenta múltiples facetas."','It is worth pointing out that the phenomenon presents multiple facets',array['The phenomenon is multifaceted','It is many faceted','The thing has facets'],'It is worth pointing out that the phenomenon presents multiple facets',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','cabe señalar que',array['hay que decir que','cabe decir que','vale señalar'],'It is worth pointing out that',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','es probable que ocurra',array['probable que ocurre','es probable ocurre','va a ocurrir probablemente'],'It is likely to happen',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','el marco teórico es claro',array['la teoría es clara','el marco de teoría es claro','el contexto teórico'],'The theoretical framework is clear',18),
    (v_lesson_id,'speaking','Say "It can be observed that..." formally in Spanish.','Cabe observar que...',array[]::text[],'Cabe observar que...',19),
    (v_lesson_id,'speaking','Say "The analysis of the data shows..." in Spanish.','El análisis de los datos muestra...',array[]::text[],'El análisis de los datos muestra...',20),
    (v_lesson_id,'fill_blank','Complete: "Cabe ___ que..." (point out)','señalar',array['decir','hablar','contar'],'point out',21),
    (v_lesson_id,'fill_blank','Complete: "Es probable que ___" (it happens)','ocurra',array['ocurre','ocurrirá','ocurría'],'happens (subj.)',22);

  -- Lesson 4: writing essays (speaking)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Formal Writing — Lesson 4', 'Write and read essays out loud.', 'speaking', 4, 30)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "thesis statement"?','la tesis principal',array['la idea principal también','la afirmación tesis','la idea central también'],'Thesis statement',1),
    (v_lesson_id,'multiple_choice','How do you say "introduction"?','la introducción',array['el comienzo','el inicio','la apertura'],'Introduction [een-troh-dook-SYOHN]',2),
    (v_lesson_id,'multiple_choice','How do you say "body (of essay)"?','el cuerpo',array['el contenido','el desarrollo también','la sustancia'],'Body (of essay)',3),
    (v_lesson_id,'multiple_choice','How do you say "conclusion"?','la conclusión',array['el final','el cierre también','el desenlace'],'Conclusion [kohn-kloo-SYOHN]',4),
    (v_lesson_id,'multiple_choice','How do you say "citation / quote"?','la cita',array['la mención','la referencia','el cito'],'Citation / quote [SEE-tah]',5),
    (v_lesson_id,'multiple_choice','How do you say "to cite (a source)"?','citar',array['mencionar','copiar','referir'],'To cite [see-TAHR]',6),
    (v_lesson_id,'multiple_choice','How do you say "footnote"?','la nota al pie',array['la nota','el comentario','la observación'],'Footnote [NOH-tah ahl PYEH]',7),
    (v_lesson_id,'multiple_choice','How do you say "bibliography"?','la bibliografía',array['las referencias también','las fuentes también','All correct'],'Bibliography [bee-blyoh-grah-FEE-ah]',8),
    (v_lesson_id,'multiple_choice','How do you say "to paraphrase"?','parafrasear',array['decir otra vez','volver a decir','reformular también'],'To paraphrase [pah-rah-frah-seh-AHR]',9),
    (v_lesson_id,'multiple_choice','How do you say "plagiarism"?','el plagio',array['la copia','el robo','el plagiar'],'Plagiarism [PLAH-hyoh]',10),
    (v_lesson_id,'multiple_choice','How do you say "first draft"?','el primer borrador',array['la primera versión','el borrador','el primer escrito'],'First draft [boh-rrah-DOHR]',11),
    (v_lesson_id,'multiple_choice','How do you say "to revise / edit"?','revisar',array['cambiar','corregir también','editar también'],'To revise [reh-bee-SAHR]',12),
    (v_lesson_id,'multiple_choice','How do you say "final version"?','la versión definitiva',array['la última versión también','la versión final','All correct'],'Final version',13),
    (v_lesson_id,'multiple_choice','How do you say "concise"?','conciso',array['breve','corto','exacto'],'Concise [kohn-SEE-soh]',14),
    (v_lesson_id,'multiple_choice','Translate "El presente ensayo aborda la cuestión del cambio climático."','This essay addresses the question of climate change',array['Climate change is the present','The essay changes climate','The change is essay'],'This essay addresses the question of climate change',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','el presente ensayo aborda',array['este ensayo aborda','el ensayo presenta','el presente ensayo tratará'],'This essay addresses',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','según el autor',array['de acuerdo al autor','según el escritor','según el ensayo'],'According to the author',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','en conclusión los datos demuestran',array['en conclusión los datos muestran','en resumen los datos demuestran','en conclusión los datos prueban'],'In conclusion, the data demonstrate',18),
    (v_lesson_id,'speaking','Say "This essay addresses an urgent topic" in Spanish.','El presente ensayo aborda un tema urgente',array[]::text[],'El presente ensayo aborda un tema urgente',19),
    (v_lesson_id,'speaking','Say "I need to revise the first draft" in Spanish.','Necesito revisar el primer borrador',array[]::text[],'Necesito revisar el primer borrador',20),
    (v_lesson_id,'fill_blank','Complete: "El presente ensayo ___" (addresses)','aborda',array['toca','habla','dice'],'addresses',21),
    (v_lesson_id,'fill_blank','Complete: "Hay que evitar el ___" (plagiarism)','plagio',array['copia','robo','plagiar'],'plagiarism',22);

  -- =================== C1.4 DEBATE & DISCUSSION ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Debate & Discussion', 'Argue, concede and persuade in Spanish.', 'C1', 4)
  returning id into v_course_id;

  -- Lesson 1: stating opinions strongly
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Debate — Lesson 1', 'Express strong opinions with nuance.', 'vocabulary', 1, 30)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "I am of the opinion that..."?','Soy de la opinión de que...',array['Tengo la opinión','Mi opinión','Yo opinión'],'I am of the opinion that...',1),
    (v_lesson_id,'multiple_choice','How do you say "I firmly believe that..."?','Creo firmemente que...',array['Yo creer firme','Tengo creencia firme','Estoy seguro que también'],'I firmly believe that...',2),
    (v_lesson_id,'multiple_choice','How do you say "Without any doubt..."?','Sin lugar a dudas...',array['Sin duda alguna también','Indudablemente también','All correct'],'Without any doubt',3),
    (v_lesson_id,'multiple_choice','How do you say "It is obvious that..."?','Es evidente que...',array['Es obvio que también','Está claro que también','All correct'],'It is obvious that...',4),
    (v_lesson_id,'multiple_choice','How do you say "I beg to differ"?','Permítame discrepar',array['No estoy de acuerdo','Yo discrepo','Discordo'],'I beg to differ [dees-kreh-PAHR]',5),
    (v_lesson_id,'multiple_choice','How do you say "Allow me to disagree"?','Permítame discrepar',array['Déjame discrepar también','Me permite discrepar','Discrepo si me permite'],'Allow me to disagree (formal)',6),
    (v_lesson_id,'multiple_choice','How do you say "From my perspective..."?','Desde mi perspectiva...',array['En mi vista','De mi parte','En mi opinión también'],'From my perspective',7),
    (v_lesson_id,'multiple_choice','How do you say "There is no doubt that..."?','No cabe duda de que...',array['No hay duda','Sin duda','All correct'],'There is no doubt that... [KAH-beh]',8),
    (v_lesson_id,'multiple_choice','How do you say "If I may say so..."?','Si me permite decirlo...',array['Si puedo decir','Si yo decir','Si me permita decir'],'If I may say so',9),
    (v_lesson_id,'multiple_choice','How do you say "With all due respect..."?','Con todo el respeto',array['Con respeto','Respetando','Con permiso'],'With all due respect',10),
    (v_lesson_id,'multiple_choice','How do you say "Pardon me, but..."?','Disculpe, pero...',array['Perdón pero','Perdóneme pero también','All correct'],'Pardon me, but...',11),
    (v_lesson_id,'multiple_choice','How do you say "I would like to add that..."?','Quisiera añadir que...',array['Me gustaría añadir también','Yo añadir','All correct (quisiera / me gustaría)'],'I would like to add that...',12),
    (v_lesson_id,'multiple_choice','How do you say "Let me clarify..."?','Permítame aclarar',array['Déjame aclarar también','Yo aclaro','Voy a aclarar'],'Let me clarify [ah-klah-RAHR]',13),
    (v_lesson_id,'multiple_choice','How do you say "Im inclined to think that..."?','Me inclino a pensar que...',array['Yo pensar','Mi inclinación es pensar','Yo me inclino'],'Im inclined to think that...',14),
    (v_lesson_id,'multiple_choice','How do you say "I beg to differ on that point"?','Permítame discrepar en ese punto',array['Yo discrepo','Disculpe discrepar','No estoy en ese punto'],'I beg to differ on that point',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','desde mi perspectiva',array['en mi opinión','desde mi vista','en mi perspectiva'],'From my perspective',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','con todo el respeto',array['con respeto','respetando','con permiso'],'With all due respect',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','permítame discrepar',array['permíteme discrepar','déjame discrepar','perdón discrepar'],'Allow me to disagree',18),
    (v_lesson_id,'speaking','Say "From my perspective, this is the right answer" in Spanish.','Desde mi perspectiva, esta es la respuesta correcta',array[]::text[],'Desde mi perspectiva, esta es la respuesta correcta',19),
    (v_lesson_id,'speaking','Say "With all due respect, I disagree" in Spanish.','Con todo el respeto, no estoy de acuerdo',array[]::text[],'Con todo el respeto, no estoy de acuerdo',20),
    (v_lesson_id,'fill_blank','Complete: "Sin lugar a ___" (without a doubt)','dudas',array['duda','sin','dudoso'],'doubts',21),
    (v_lesson_id,'fill_blank','Complete: "Permítame ___" (disagree)','discrepar',array['discordar','desacordar','no acordar'],'disagree',22);

  -- Lesson 2: concession + counter-argument
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Debate — Lesson 2', 'Concede points and counter-argue.', 'phrases', 2, 30)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you concede: "Granted, but..."?','Cierto, pero...',array['Es cierto pero también','Sí, pero','All correct'],'Granted, but...',1),
    (v_lesson_id,'multiple_choice','How do you say "Although I admit that..."?','Aunque admito que...',array['Aunque acepte','Aceptando','Si acepto'],'Although I admit that... (+ indic./subj.)',2),
    (v_lesson_id,'multiple_choice','How do you say "Even if that were true..."?','Aun si eso fuera cierto...',array['Aunque cierto','Si es cierto','Aun cierto'],'Even if that were true... (subj.)',3),
    (v_lesson_id,'multiple_choice','How do you say "I see your point, but..."?','Entiendo su punto, pero...',array['Veo su punto pero','Comprendo su idea pero','All correct'],'I see your point, but...',4),
    (v_lesson_id,'multiple_choice','How do you say "Let us not forget that..."?','No olvidemos que...',array['No olvide','No olvidar','Hay que no olvidar'],'Let us not forget that...',5),
    (v_lesson_id,'multiple_choice','How do you say "On the contrary..."?','Por el contrario...',array['Al contrario también','Contrariamente también','All correct'],'On the contrary',6),
    (v_lesson_id,'multiple_choice','How do you say "Quite the opposite..."?','Todo lo contrario...',array['Justo lo contrario también','Contrario','All correct'],'Quite the opposite',7),
    (v_lesson_id,'multiple_choice','How do you rebut: "I am afraid you are mistaken"?','Me temo que se equivoca',array['Tengo miedo que','Yo creer que','Discúlpeme'],'Im afraid you are mistaken (formal)',8),
    (v_lesson_id,'multiple_choice','How do you say "That is not entirely accurate"?','Eso no es del todo exacto',array['Eso es inexacto','Eso no es bien','Eso no es verdad'],'Thats not entirely accurate',9),
    (v_lesson_id,'multiple_choice','How do you say "Lets stick to the facts"?','Atengámonos a los hechos',array['Vamos a los hechos','Solo hechos','Hechos solamente'],'Lets stick to the facts [ah-tehn-GAH-mohs]',10),
    (v_lesson_id,'multiple_choice','How do you say "to refute an argument"?','refutar un argumento',array['negar un argumento','rechazar argumento','contradecir argumento'],'To refute an argument [reh-foo-TAHR]',11),
    (v_lesson_id,'multiple_choice','How do you say "to backtrack"?','retractarse',array['volver atrás','negar','rectificar también'],'To backtrack [reh-trahk-TAHR-seh]',12),
    (v_lesson_id,'multiple_choice','How do you say "to compromise / reach middle ground"?','llegar a un punto medio',array['comprometerse también','encontrar acuerdo','All correct'],'To reach middle ground',13),
    (v_lesson_id,'multiple_choice','How do you say "to play devils advocate"?','hacer de abogado del diablo',array['ser el diablo','jugar al diablo','ser malo'],'To play devils advocate (idiom)',14),
    (v_lesson_id,'multiple_choice','Translate "Si bien comparto su preocupación, no comparto su solución."','While I share your concern, I do not share your solution',array['I share your solution','I do not share concerns','I share solutions'],'While I share your concern, I do not share your solution',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','me temo que se equivoca',array['tengo miedo que se equivoca','me temo que está mal','me parece que se equivoca'],'Im afraid you are mistaken',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','no olvidemos que',array['no olvides que','no olvidar que','recordemos que'],'Lets not forget that',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','por el contrario',array['al contrario','contrariamente','todo lo contrario'],'On the contrary',18),
    (v_lesson_id,'speaking','Say "Im afraid you are mistaken" formally in Spanish.','Me temo que se equivoca',array[]::text[],'Me temo que se equivoca',19),
    (v_lesson_id,'speaking','Say "Lets stick to the facts" in Spanish.','Atengámonos a los hechos',array[]::text[],'Atengámonos a los hechos',20),
    (v_lesson_id,'fill_blank','Complete: "Me ___ que se equivoca." (Im afraid)','temo',array['miedo','asusto','espero'],'fear',21),
    (v_lesson_id,'fill_blank','Complete: "Por el ___ , es cierto." (contrary)','contrario',array['otro','revés','contrarrestrar'],'contrary',22);

  -- Lesson 3: rhetorical strategies (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Debate — Lesson 3', 'Use rhetoric: questions, analogies, calls to action.', 'listening', 3, 30)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you ask a rhetorical question?','¿Acaso no es evidente?',array['¿Realmente no es evidente?','¿Es evidente o no?','¿Tal vez no es evidente?'],'Isnt it obvious? [ah-KAH-soh]',1),
    (v_lesson_id,'multiple_choice','How do you say "What would happen if..."?','¿Qué pasaría si...?',array['¿Qué pasa si?','¿Qué pasó si?','¿Qué será si?'],'What would happen if... (conditional)',2),
    (v_lesson_id,'multiple_choice','How do you say "Imagine for a moment..."?','Imagine por un momento...',array['Yo imagino','Imagina por un momento (informal)','Pensemos por momento'],'Imagine for a moment (formal)',3),
    (v_lesson_id,'multiple_choice','How do you say "Let us suppose that..."?','Supongamos que...',array['Vamos a suponer','Si suponemos','All correct'],'Let us suppose that... (+ subj. often)',4),
    (v_lesson_id,'multiple_choice','How do you say "as a metaphor..."?','a modo de metáfora',array['como metáfora también','en metáfora','con metáfora'],'As a metaphor',5),
    (v_lesson_id,'multiple_choice','How do you say "It is like..."?','Es como...',array['Es igual a','Es semejante a también','Se asemeja a también'],'It is like... (analogy)',6),
    (v_lesson_id,'multiple_choice','How do you say "we cannot afford to..."?','no podemos permitirnos...',array['no permitimos','no nos permite','no estamos permitidos'],'We cannot afford to... [pehr-mee-TEER-nohs]',7),
    (v_lesson_id,'multiple_choice','How do you say "the time has come to..."?','ha llegado el momento de...',array['es la hora para también','ha llegado la hora de también','All correct'],'The time has come to...',8),
    (v_lesson_id,'multiple_choice','How do you say "what is at stake is..."?','lo que está en juego es...',array['lo que en juego','lo que se juega','lo que pasa es'],'What is at stake is... [HWEH-goh]',9),
    (v_lesson_id,'multiple_choice','How do you say "this affects all of us"?','esto nos afecta a todos',array['esto afecta todos','todos nos afecta','esto afecta a nosotros'],'This affects all of us',10),
    (v_lesson_id,'multiple_choice','How do you say "the consequences would be devastating"?','las consecuencias serían devastadoras',array['las consecuencias son malas','la consecuencia es grave','las consecuencias serán devastadoras'],'The consequences would be devastating',11),
    (v_lesson_id,'multiple_choice','How do you say "let us reflect on..."?','reflexionemos sobre...',array['pensemos sobre','consideremos','All correct'],'Let us reflect on...',12),
    (v_lesson_id,'multiple_choice','How do you say "we must act now"?','hay que actuar ahora',array['debemos actuar ahora también','tenemos que actuar ahora también','All correct'],'We must act now',13),
    (v_lesson_id,'multiple_choice','How do you say "appealing to common sense"?','apelando al sentido común',array['hablando del sentido común','con el sentido común','sentido común'],'Appealing to common sense [ah-peh-LAHN-doh]',14),
    (v_lesson_id,'multiple_choice','Translate "Si no actuamos ahora, ¿quién lo hará por nosotros?"','If we do not act now, who will do it for us?',array['We must act','Who acts for us','We are acting now'],'If we do not act now, who will do it for us?',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','¿acaso no es evidente?',array['¿es evidente?','¿no es evidente?','¿realmente es evidente?'],'Isnt it obvious?',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','ha llegado el momento de actuar',array['ha llegado la hora de actuar','llegó el momento de actuar','es el momento de actuar'],'The time has come to act',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','lo que está en juego es importante',array['lo que en juego es importante','lo que se juega','el juego es importante'],'What is at stake is important',18),
    (v_lesson_id,'speaking','Say "The time has come to act" in Spanish.','Ha llegado el momento de actuar',array[]::text[],'Ha llegado el momento de actuar',19),
    (v_lesson_id,'speaking','Say "What is at stake is our future" in Spanish.','Lo que está en juego es nuestro futuro',array[]::text[],'Lo que está en juego es nuestro futuro',20),
    (v_lesson_id,'fill_blank','Complete: "Ha llegado el ___ de actuar." (moment)','momento',array['tiempo','hora','día'],'moment',21),
    (v_lesson_id,'fill_blank','Complete: "Lo que está en ___ es claro." (at stake)','juego',array['juego','riesgo','peligro'],'play / stake',22);

  -- Lesson 4: closing arguments (speaking)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Debate — Lesson 4', 'Conclude and persuade in conversation.', 'speaking', 4, 30)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "In summary..."?','En síntesis...',array['En resumen también','Resumiendo también','All correct'],'In summary [SEEN-teh-sees]',1),
    (v_lesson_id,'multiple_choice','How do you say "To wrap up..."?','Para concluir...',array['Para terminar también','Para cerrar','All correct'],'To wrap up',2),
    (v_lesson_id,'multiple_choice','How do you say "the key point is..."?','el punto clave es...',array['el punto principal también','la idea fundamental también','All correct'],'The key point is...',3),
    (v_lesson_id,'multiple_choice','How do you say "we must keep in mind that..."?','hay que tener en cuenta que...',array['debemos considerar también','no olvidemos también','All correct'],'We must keep in mind that...',4),
    (v_lesson_id,'multiple_choice','How do you say "Im open to debate"?','Estoy abierto al debate',array['Yo abierto al debate','Soy abierto al debate','Tengo abierto al debate'],'Im open to debate',5),
    (v_lesson_id,'multiple_choice','How do you say "to agree to disagree"?','aceptar que no estamos de acuerdo',array['acordamos no acordar','no acordar','desacuerdo'],'To agree to disagree',6),
    (v_lesson_id,'multiple_choice','How do you say "thank you for listening"?','gracias por escucharme',array['gracias por escuchar también','gracias por su atención también','All correct'],'Thank you for listening',7),
    (v_lesson_id,'multiple_choice','How do you say "any final thoughts?"?','¿alguna idea final?',array['¿últimas ideas?','¿algo más?','¿alguna conclusión?'],'Any final thoughts?',8),
    (v_lesson_id,'multiple_choice','How do you say "I rest my case"?','Mi argumento está claro',array['Caso cerrado','Tengo razón','He terminado'],'I rest my case (rendered idiom)',9),
    (v_lesson_id,'multiple_choice','How do you say "Im willing to listen"?','Estoy dispuesto a escuchar',array['Quiero escuchar','Voy a escuchar','Yo escucho'],'Im willing to listen [dees-PWEHS-toh]',10),
    (v_lesson_id,'multiple_choice','How do you say "I respect your opinion"?','Respeto su opinión',array['Yo respetar','Tengo respeto','Soy respetuoso'],'I respect your opinion',11),
    (v_lesson_id,'multiple_choice','How do you say "Lets continue the conversation"?','Sigamos la conversación',array['Continuemos también','Sigamos hablando','All correct'],'Lets continue the conversation',12),
    (v_lesson_id,'multiple_choice','How do you say "Im looking forward to hearing more"?','Tengo ganas de escuchar más',array['Quiero escuchar más','Voy a escuchar más','Yo escuchar más'],'Im looking forward to hearing more',13),
    (v_lesson_id,'multiple_choice','How do you say "let it be on record that..."?','que conste que...',array['que se diga','que se sepa','quede claro'],'Let it be on record that... [KOHNS-teh]',14),
    (v_lesson_id,'multiple_choice','Translate "Por todo lo expuesto, considero que es imprescindible actuar."','For all the above, I consider it essential to act',array['Above all, we must act','I think we acted','It is impossible to act'],'For all the above, I consider it essential to act',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','en síntesis',array['en suma','en resumen','en conclusión'],'In summary',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','gracias por escucharme',array['gracias por venir','gracias por la atención','muchas gracias'],'Thank you for listening',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','respeto su opinión',array['respeto la opinión','tengo respeto','le respeto'],'I respect your opinion',18),
    (v_lesson_id,'speaking','Say "In summary, we must act now" in Spanish.','En síntesis, debemos actuar ahora',array[]::text[],'En síntesis, debemos actuar ahora',19),
    (v_lesson_id,'speaking','Say "I respect your opinion" formally in Spanish.','Respeto su opinión',array[]::text[],'Respeto su opinión',20),
    (v_lesson_id,'fill_blank','Complete: "En ___, esto es vital." (synthesis)','síntesis',array['resumen','suma','total'],'synthesis',21),
    (v_lesson_id,'fill_blank','Complete: "Estoy ___ a escuchar." (willing)','dispuesto',array['listo','listo a','queriendo'],'willing',22);

  -- =================== C1.5 NATIVE CONTENT ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Native Content', 'Understand native Spanish at full speed: news, films, podcasts.', 'C1', 5)
  returning id into v_course_id;

  -- Lesson 1: regional variations
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Native Content — Lesson 1', 'Regional accents and dialects.', 'vocabulary', 1, 30)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','In Spain "vosotros" is used for...','informal plural you',array['formal singular','they (m.)','we'],'You all (informal, Spain only)',1),
    (v_lesson_id,'multiple_choice','In Latin America, plural "you" (formal & informal) is...','ustedes',array['vosotros','vos','vosotras'],'You all (LatAm — replaces vosotros)',2),
    (v_lesson_id,'multiple_choice','In Argentina and Uruguay, "tú" is replaced by...','vos',array['ustedes','vosotros','usted'],'Vos (voseo) — Argentina, Uruguay, Central Am.',3),
    (v_lesson_id,'multiple_choice','How does "vos" affect verb conjugation? — "you eat"','vos comés',array['tú comes','vos come','vos comen'],'Voseo: vos comés (stress shift)',4),
    (v_lesson_id,'multiple_choice','In Spain, "z" and "ce/ci" are pronounced...','like English "th"',array['like "s"','like "k"','like "ch"'],'Spanish "ceceo/distinción" (Madrid, central Spain)',5),
    (v_lesson_id,'multiple_choice','In LatAm and southern Spain, "z" and "ce/ci" are...','pronounced like "s"','seseo',array['like "th"','like "ts"','silent'],'Seseo — LatAm and southern Spain',6),
    (v_lesson_id,'multiple_choice','In Argentina, "ll" and "y" sound like...','"sh" / "zh"',array['"y"','"l"','"j"'],'Yeísmo rehilado (Argentine sh-sound)',7),
    (v_lesson_id,'multiple_choice','In Mexico, "ahorita" means...','any moment from "right now" to "later"',array['always now','never','in the future for sure'],'Ambiguous "soon" (Mexican Spanish)',8),
    (v_lesson_id,'multiple_choice','In Spain, "ordenador" / in LatAm...','computadora',array['ordenador (same)','comput','computa'],'Computer — different words',9),
    (v_lesson_id,'multiple_choice','In Spain "móvil" / in Mexico, Argentina, etc...','celular',array['móvil (same)','telefonino','phone'],'Mobile phone — celular (LatAm)',10),
    (v_lesson_id,'multiple_choice','In Spain "coche" / in many parts of LatAm...','carro',array['auto también (especially Argentina)','machine','vehiculo'],'Car — carro / auto (LatAm)',11),
    (v_lesson_id,'multiple_choice','In Spain "patata" / in LatAm...','papa',array['patata (same)','pomo','batata'],'Potato — papa (LatAm)',12),
    (v_lesson_id,'multiple_choice','In Spain "jugo de naranja" — what about...','In LatAm same; in Spain "zumo de naranja"',array['Both use jugo','Both use zumo','None use these'],'Orange juice — zumo (Spain) / jugo (LatAm)',13),
    (v_lesson_id,'multiple_choice','In Mexico "¡Órale!" expresses...','encouragement / surprise',array['anger','sadness','boredom'],'Wow / come on (Mexico)',14),
    (v_lesson_id,'multiple_choice','In Argentina, "boludo" can mean...','dude (close friends) or idiot (insult)',array['always idiot','always friend','child'],'Dude/idiot — context-dependent (Argentina)',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','vos sabés que sí',array['tú sabes que sí','vos sabes que sí','usted sabe que sí'],'You know it (voseo)',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','¿qué hacés che?',array['¿qué haces che?','¿qué hace usted?','¿qué hacéis?'],'What are you doing, dude? (Argentine)',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','ahorita lo hago',array['ahora lo hago','después lo hago','en seguida lo hago'],'Ill do it (right now-ish) (Mexican)',18),
    (v_lesson_id,'speaking','Say "What are you up to?" in Argentine Spanish.','¿Qué hacés vos?',array[]::text[],'¿Qué hacés vos?',19),
    (v_lesson_id,'speaking','Say "Right now-ish" in Mexican Spanish.','Ahorita',array[]::text[],'Ahorita',20),
    (v_lesson_id,'fill_blank','Complete: "Vos ___ argentino." (you are)','sos',array['eres','es','sois'],'are (voseo)',21),
    (v_lesson_id,'fill_blank','Complete: "Quiero un ___ de naranja." (Spain: juice)','zumo',array['jugo','agua','licor'],'juice (Spain)',22);

  -- Lesson 2: media language (TV / film)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Native Content — Lesson 2', 'Films, TV shows and pop culture.', 'phrases', 2, 30)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "to binge-watch"?','ver de una sentada',array['ver maratón','ver de tirón también','All correct'],'To binge-watch',1),
    (v_lesson_id,'multiple_choice','How do you say "plot twist"?','un giro inesperado',array['un giro de trama','un cambio de trama también','All correct'],'Plot twist',2),
    (v_lesson_id,'multiple_choice','How do you say "TV series / show"?','la serie',array['el programa de TV','la temporada','el episodio'],'Series [SEH-ryeh]',3),
    (v_lesson_id,'multiple_choice','How do you say "season"?','la temporada',array['la estación (season of year)','la serie','el periodo'],'Season (TV) [tehm-poh-RAH-dah]',4),
    (v_lesson_id,'multiple_choice','How do you say "episode"?','el episodio',array['el capítulo también','el chapter','la sesión'],'Episode [eh-pee-SOH-dyoh]',5),
    (v_lesson_id,'multiple_choice','How do you say "main role / leading role"?','el papel protagonista',array['el papel principal también','el rol principal','All correct'],'Leading role [pah-PEHL]',6),
    (v_lesson_id,'multiple_choice','How do you say "soundtrack"?','la banda sonora',array['la música','el sonido','la pista de sonido'],'Soundtrack',7),
    (v_lesson_id,'multiple_choice','How do you say "subtitles"?','los subtítulos',array['los textos','los rótulos también','los letreros'],'Subtitles [soob-TEE-too-lohs]',8),
    (v_lesson_id,'multiple_choice','How do you say "dubbed"?','doblado',array['traducido','duplicado','dubbing'],'Dubbed [doh-BLAH-doh]',9),
    (v_lesson_id,'multiple_choice','How do you say "original version (subtitled)"?','versión original (subtitulada)',array['versión nueva','versión doblada','versión clásica'],'Original version (VO)',10),
    (v_lesson_id,'multiple_choice','How do you say "to stream"?','ver en streaming',array['ver online','tomar streaming','ver en directo'],'To stream',11),
    (v_lesson_id,'multiple_choice','How do you say "I cant get hooked on it"?','No me engancha',array['No me gusta','No me atrapa también','No me llama'],'I cant get hooked on it [ehn-GAHN-chah]',12),
    (v_lesson_id,'multiple_choice','How do you say "spoiler alert"?','aviso de spoilers',array['spoiler','sorpresa','revelación'],'Spoiler alert',13),
    (v_lesson_id,'multiple_choice','How do you say "to release (a film)"?','estrenar',array['lanzar también','sacar','dar a conocer'],'To release / premiere [ehs-treh-NAHR]',14),
    (v_lesson_id,'multiple_choice','How do you say "premiere"?','el estreno',array['el lanzamiento también','la apertura','la primera'],'Premiere [ehs-TREH-noh]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','vi toda la temporada de una sentada',array['vi toda la serie de un tirón','vi todos los capítulos','vi un episodio'],'I binged the whole season in one go',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','prefiero ver en versión original',array['prefiero la versión doblada','prefiero subtítulos','prefiero ver original'],'I prefer to watch in original version',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','no me hagas spoilers',array['no spoilers','sin spoilers','no me digas el final'],'Dont spoil it for me',18),
    (v_lesson_id,'speaking','Say "I binge-watched the whole season" in Spanish.','Me vi toda la temporada de una sentada',array[]::text[],'Me vi toda la temporada de una sentada',19),
    (v_lesson_id,'speaking','Say "I prefer the original version" in Spanish.','Prefiero la versión original',array[]::text[],'Prefiero la versión original',20),
    (v_lesson_id,'fill_blank','Complete: "La ___ sonora es genial." (soundtrack)','banda',array['música','melodía','pista'],'band',21),
    (v_lesson_id,'fill_blank','Complete: "El ___ es esta noche." (premiere)','estreno',array['lanzamiento','final','final'],'premiere',22);

  -- Lesson 3: news + politics speech (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Native Content — Lesson 3', 'Understand fast news and political speech.', 'listening', 3, 30)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "to announce officially"?','anunciar oficialmente',array['decir oficial','informar formal','declarar también'],'To announce officially',1),
    (v_lesson_id,'multiple_choice','How do you say "press release"?','el comunicado de prensa',array['la nota de prensa también','el aviso','la información'],'Press release [koh-moo-nee-KAH-doh]',2),
    (v_lesson_id,'multiple_choice','How do you say "rally / public gathering"?','la concentración',array['la manifestación también','la junta','la reunión'],'Rally [kohn-sehn-trah-SYOHN]',3),
    (v_lesson_id,'multiple_choice','How do you say "to be in office"?','estar en el cargo',array['ocupar el cargo también','estar en el poder también','All correct'],'To be in office',4),
    (v_lesson_id,'multiple_choice','How do you say "to call an election"?','convocar elecciones',array['llamar elecciones','tener elecciones','programar elecciones'],'To call an election [kohn-boh-KAHR]',5),
    (v_lesson_id,'multiple_choice','How do you say "polls (data) suggest..."?','las encuestas sugieren...',array['las encuestas dicen también','los sondeos sugieren también','All correct'],'Polls suggest...',6),
    (v_lesson_id,'multiple_choice','How do you say "to win by a landslide"?','ganar por amplia mayoría',array['ganar por mucho','ganar fácil','arrasar también'],'To win by a landslide [ahm-PLYAH]',7),
    (v_lesson_id,'multiple_choice','How do you say "to step down / resign"?','dimitir',array['renunciar también','dejar el cargo también','All correct'],'To step down [dee-mee-TEER]',8),
    (v_lesson_id,'multiple_choice','How do you say "scandal-ridden"?','salpicado por escándalos',array['lleno de escándalos','con escándalos','escandalero'],'Scandal-ridden [sahl-pee-KAH-doh]',9),
    (v_lesson_id,'multiple_choice','How do you say "to issue a statement"?','emitir un comunicado',array['hacer una declaración también','dar un comunicado también','All correct'],'To issue a statement [eh-mee-TEER]',10),
    (v_lesson_id,'multiple_choice','How do you say "off the record"?','extraoficialmente',array['fuera del registro','sin registro','privado'],'Off the record [ehks-trah-oh-fee-syahl-MEHN-teh]',11),
    (v_lesson_id,'multiple_choice','How do you say "to leak (information)"?','filtrar',array['fugar','salir','escapar'],'To leak [feel-TRAHR]',12),
    (v_lesson_id,'multiple_choice','How do you say "tax evasion"?','la evasión fiscal',array['evasión de impuestos también','fraude fiscal también','All correct'],'Tax evasion [eh-bah-SYOHN fees-KAHL]',13),
    (v_lesson_id,'multiple_choice','How do you say "amid controversy"?','en medio de la polémica',array['en la polémica','con polémica','entre polémica'],'Amid controversy [poh-LEH-mee-kah]',14),
    (v_lesson_id,'multiple_choice','Translate "El presidente anunció su dimisión en medio de la polémica."','The president announced his resignation amid controversy',array['He fought the controversy','He stayed in office','He created controversy'],'The president announced his resignation amid controversy',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','las encuestas sugieren un cambio',array['las encuestas dicen un cambio','los sondeos sugieren un cambio','las encuestas son un cambio'],'Polls suggest a change',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','dimitió en medio de la polémica',array['renunció en polémica','dimitió por polémica','dimitió por escándalos'],'He resigned amid controversy',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','filtraron información confidencial',array['publicaron información','perdieron información','fugaron información'],'They leaked confidential information',18),
    (v_lesson_id,'speaking','Say "Polls suggest a change of government" in Spanish.','Las encuestas sugieren un cambio de gobierno',array[]::text[],'Las encuestas sugieren un cambio de gobierno',19),
    (v_lesson_id,'speaking','Say "He resigned amid controversy" in Spanish.','Dimitió en medio de la polémica',array[]::text[],'Dimitió en medio de la polémica',20),
    (v_lesson_id,'fill_blank','Complete: "En medio de la ___" (controversy)','polémica',array['discusión','crítica','queja'],'controversy',21),
    (v_lesson_id,'fill_blank','Complete: "Las ___ sugieren un cambio." (polls)','encuestas',array['preguntas','noticias','votos'],'polls',22);

  -- Lesson 4: native-speed conversation (speaking)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Native Content — Lesson 4', 'Sound natural at full speed.', 'speaking', 4, 30)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','Casual filler: "you know"','¿sabes? / ¿viste?',array['¿sabias?','¿conoces?','¿entiendes?'],'You know? (filler, ¿viste? in Argentina)',1),
    (v_lesson_id,'multiple_choice','Casual filler: "like / kinda"','tipo / como',array['similar','así así','parecer'],'Like / kinda (very common filler)',2),
    (v_lesson_id,'multiple_choice','Casual filler: "anyway"','en fin / total',array['ya','entonces','de todos modos también'],'Anyway (en fin / total / de todos modos)',3),
    (v_lesson_id,'multiple_choice','Casual: "um / well..."','este... / pues...',array['eh','um','así'],'Well... (Spanish hesitation)',4),
    (v_lesson_id,'multiple_choice','Casual: "yeah, sure!"','¡claro que sí!',array['¡claro!','¡cómo no!','All correct'],'Yeah, sure!',5),
    (v_lesson_id,'multiple_choice','How do you say "no way!" (disbelief)?','¡no me digas!',array['¡no puede ser!','¡imposible!','All correct'],'No way! (disbelief)',6),
    (v_lesson_id,'multiple_choice','How do you express surprise: "really?!"','¿en serio?',array['¿de verdad?','¿no?','All correct'],'Really?!',7),
    (v_lesson_id,'multiple_choice','How do you say "thats crazy!"?','¡qué locura!',array['¡qué loco!','¡es loco!','¡qué pasada!'],'Thats crazy! [loh-KOO-rah]',8),
    (v_lesson_id,'multiple_choice','How do you say "for real / really"?','de verdad',array['en serio también','realmente','All correct'],'Really / for real',9),
    (v_lesson_id,'multiple_choice','How do you say "youre kidding"?','estás de broma',array['bromeas también','me tomas el pelo','All correct'],'Youre kidding',10),
    (v_lesson_id,'multiple_choice','How do you express disgust?','¡qué asco!',array['¡puaj!','¡guácala! (Mexico)','All correct'],'Yuck! [AHS-koh]',11),
    (v_lesson_id,'multiple_choice','How do you express awe / impressive?','¡qué pasada! (Spain)',array['¡qué bárbaro!','¡qué padre! (Mex.)','All correct'],'Awesome! (Spain colloquial)',12),
    (v_lesson_id,'multiple_choice','How do you say "tell me about it (I know!)"?','¡a quién se lo dices!',array['¡a mí me lo dices a mí!','¡yo sé!','Both first two'],'Tell me about it! (idiom)',13),
    (v_lesson_id,'multiple_choice','How do you say "lets cut to the chase"?','vayamos al grano',array['vamos al grano también','dejemos las vueltas','All correct'],'Lets cut to the chase',14),
    (v_lesson_id,'multiple_choice','Translate "En fin, lo que te quería decir es que ya estoy harto."','Anyway, what I wanted to tell you is that Im fed up',array['I have nothing to say','I am tired','I want to talk'],'Anyway, what I wanted to tell you is that Im fed up',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','en fin, qué te iba a decir',array['en serio qué te iba a decir','total qué decirte','en fin qué iba a decir'],'Anyway, what I was about to say',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','¡no me digas!',array['¡no puede ser!','¡imposible!','¡me dices!'],'No way!',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','¡qué pasada!',array['¡qué loco!','¡qué bárbaro!','¡qué padre!'],'Awesome!',18),
    (v_lesson_id,'speaking','Say "No way, really?!" in Spanish.','¡No me digas! ¿En serio?',array[]::text[],'¡No me digas! ¿En serio?',19),
    (v_lesson_id,'speaking','Say "Anyway, lets cut to the chase" in Spanish.','En fin, vayamos al grano',array[]::text[],'En fin, vayamos al grano',20),
    (v_lesson_id,'fill_blank','Complete: "En ___, ya da igual." (anyway)','fin',array['serio','verdad','total'],'end / anyway',21),
    (v_lesson_id,'fill_blank','Complete: "¡Qué ___!" (awesome, Spain)','pasada',array['loco','padre','bárbaro'],'awesome',22);

  -- =================== C1 ARTICLE ===================
  insert into public.articles (language_id, slug, title, title_english, level, reading_minutes, content_target, content_english, order_index)
  values (
    v_lang_id,
    'c1-el-espanol-en-el-mundo',
    'El español en el mundo: unidad y diversidad',
    'Spanish in the World: Unity and Diversity',
    'C1',
    4,
    E'El español es, hoy en día, una de las lenguas más habladas del planeta. Con más de quinientos millones de hablantes nativos repartidos por más de veinte países, se ha convertido en una auténtica lengua global, presente tanto en el ámbito político y económico como en la cultura popular y las industrias creativas.\n\nSin embargo, cabría preguntarse hasta qué punto puede hablarse de un solo español. Si bien es cierto que la norma escrita resulta sorprendentemente homogénea —gracias, en buena medida, al trabajo de la Real Academia Española y las academias hermanas de América—, la realidad oral es muchísimo más rica y variada. Desde el voseo argentino hasta el seseo andaluz, pasando por el uso de "ustedes" como única forma de plural en Latinoamérica, las variaciones afectan a la pronunciación, al léxico y, en ocasiones, incluso a la gramática.\n\nA pesar de esta diversidad, la inteligibilidad mutua entre hablantes de distintas regiones se mantiene notablemente alta. Un madrileño y una bogotana, por ejemplo, pueden conversar sin grandes dificultades, aunque tarden unos minutos en acostumbrarse a los giros propios del otro. No obstante, los matices regionales son tan numerosos que ningún diccionario logra recogerlos todos.\n\nEn cuanto al futuro de la lengua, los expertos coinciden en que el español seguirá expandiéndose, sobre todo en Estados Unidos, donde el número de hispanohablantes no deja de aumentar. Asimismo, el peso del español en internet, el cine y la música contribuirá a consolidar su prestigio internacional.\n\nEn definitiva, el español es una lengua que se nutre de su pluralidad. Su fuerza no reside en la uniformidad, sino, paradójicamente, en la convivencia de tantas voces distintas bajo un mismo techo lingüístico.',
    E'Spanish is, today, one of the most widely spoken languages on the planet. With more than five hundred million native speakers spread across more than twenty countries, it has become a truly global language, present in the political and economic spheres as well as in popular culture and the creative industries.\n\nNevertheless, one might wonder to what extent we can really speak of a single Spanish. While it is true that the written norm is surprisingly homogeneous — largely thanks to the work of the Royal Spanish Academy and its sister academies in the Americas — the spoken reality is far richer and more varied. From Argentine voseo to Andalusian seseo, through the use of "ustedes" as the sole plural form in Latin America, variations affect pronunciation, vocabulary and, on occasion, even grammar.\n\nDespite this diversity, mutual intelligibility between speakers of different regions remains remarkably high. A Madrid native and a Bogotá native, for example, can converse without major difficulties, though they may need a few minutes to get used to each others turns of phrase. Nevertheless, the regional nuances are so numerous that no dictionary manages to capture them all.\n\nRegarding the future of the language, experts agree that Spanish will continue to expand, especially in the United States, where the number of Spanish speakers keeps growing. Likewise, Spanishs weight on the internet, in cinema and in music will help to consolidate its international prestige.\n\nUltimately, Spanish is a language that thrives on its plurality. Its strength does not lie in uniformity but, paradoxically, in the coexistence of so many distinct voices under a single linguistic roof.',
    1
  );

end $$;

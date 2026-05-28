-- 013_spanish_b2_real_content.sql
-- Real Spanish B2 lesson content (no B2 article per spec — A1/B1/C1 only).
-- Idempotent: re-running deletes Spanish B2 and reseeds.
-- A1 (010), A2 (011), B1 (012) and C1 stay on their current content.
--
-- B2 introduces: past subjunctive (-ra/-se), conditional perfect,
-- passive voice (ser + participle, se + verb), reported speech,
-- pluperfect, advanced connectors (a pesar de que, en cuanto a),
-- and abstract/professional vocabulary.

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

  delete from public.courses where language_id = v_lang_id and cefr_level = 'B2';

  -- =================== B2.1 POLITICS ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Politics', 'Discuss government, elections and political debate in Spanish.', 'B2', 1)
  returning id into v_course_id;

  -- Lesson 1: political vocab
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Politics — Lesson 1', 'Government, elections and parties.', 'vocabulary', 1, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "democracy"?','la democracia',array['la república','el estado','el régimen'],'Democracy [deh-moh-KRAH-syah]',1),
    (v_lesson_id,'multiple_choice','How do you say "election"?','la elección',array['las elecciones (plural)','el voto','la votación también'],'Election [eh-lehk-SYOHN]',2),
    (v_lesson_id,'multiple_choice','How do you say "to vote"?','votar',array['elegir también','dar voto','ejercer'],'To vote [boh-TAHR]',3),
    (v_lesson_id,'multiple_choice','How do you say "candidate"?','el candidato',array['el político','el electo','el elegido'],'Candidate [kahn-dee-DAH-toh]',4),
    (v_lesson_id,'multiple_choice','How do you say "political party"?','el partido político',array['la política','el grupo','la facción'],'Political party [pahr-TEE-doh]',5),
    (v_lesson_id,'multiple_choice','How do you say "the left (wing)"?','la izquierda',array['el lado','el partido','la derecha'],'The left [ees-KYEHR-dah]',6),
    (v_lesson_id,'multiple_choice','How do you say "the right (wing)"?','la derecha',array['el centro','la mano','la izquierda'],'The right [deh-REH-chah]',7),
    (v_lesson_id,'multiple_choice','How do you say "minister"?','el ministro',array['el presidente','el secretario','el ministerio'],'Minister [mee-NEES-troh]',8),
    (v_lesson_id,'multiple_choice','How do you say "parliament"?','el parlamento',array['el congreso (LatAm)','la cámara','las cortes'],'Parliament [pahr-lah-MEHN-toh]',9),
    (v_lesson_id,'multiple_choice','How do you say "law"?','la ley',array['la regla','el código','la norma'],'Law [LAY]',10),
    (v_lesson_id,'multiple_choice','How do you say "human rights"?','los derechos humanos',array['los derechos civiles','los derechos','derechos del hombre'],'Human rights [deh-REH-chohs oo-MAH-nohs]',11),
    (v_lesson_id,'multiple_choice','How do you say "reform"?','la reforma',array['el cambio','la mejora','la modificación'],'Reform [reh-FOHR-mah]',12),
    (v_lesson_id,'multiple_choice','How do you say "protest / demonstration"?','la manifestación',array['la protesta también','la huelga','la concentración'],'Demonstration [mah-nee-fehs-tah-SYOHN]',13),
    (v_lesson_id,'multiple_choice','How do you say "citizen"?','el ciudadano',array['el habitante','el ciudad','el civil'],'Citizen [syoo-dah-DAH-noh]',14),
    (v_lesson_id,'multiple_choice','How do you say "constitution"?','la constitución',array['la ley','el código','el estatuto'],'Constitution [kohns-tee-too-SYOHN]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','las elecciones son el domingo',array['la elección es domingo','las elecciones son lunes','el domingo voto'],'The elections are on Sunday',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','el partido de izquierda ganó',array['el partido de derecha ganó','la izquierda ganó','el partido perdió'],'The left-wing party won',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','hay una manifestación en el centro',array['hay una protesta en el centro','está una manifestación','manifestación cerca'],'There is a demonstration in the center',18),
    (v_lesson_id,'speaking','Say "I vote in every election" in Spanish.','Voto en cada elección',array[]::text[],'Voto en cada elección',19),
    (v_lesson_id,'speaking','Say "Human rights are universal" in Spanish.','Los derechos humanos son universales',array[]::text[],'Los derechos humanos son universales',20),
    (v_lesson_id,'fill_blank','Complete: "Las ___ son el domingo." (elections)','elecciones',array['elección','votos','votaciones'],'elections',21),
    (v_lesson_id,'fill_blank','Complete: "Los derechos ___" (human rights)','humanos',array['humanas','humano','de hombre'],'human',22);

  -- Lesson 2: debating political issues
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Politics — Lesson 2', 'Debate political issues with subjunctive.', 'grammar', 2, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','Which mood follows "Es necesario que..."?','el subjuntivo',array['el indicativo','el imperativo','el infinitivo'],'Subjunctive after impersonal expressions',1),
    (v_lesson_id,'multiple_choice','Conjugate: "It is necessary that we vote" — Es necesario que ___ (votar)','votemos',array['votamos','votáramos','votaremos'],'Subjunctive: votemos',2),
    (v_lesson_id,'multiple_choice','Conjugate: "I want the government to change" — Quiero que el gobierno ___ (cambiar)','cambie',array['cambia','cambió','cambiaba'],'Subj: cambie',3),
    (v_lesson_id,'multiple_choice','Conjugate: "Its important that you (informal) participate" — Es importante que tú ___ (participar)','participes',array['participas','participabas','participarás'],'Subj: participes',4),
    (v_lesson_id,'multiple_choice','How do you say "It is fundamental that..."?','Es fundamental que...',array['Es fundamental','Es fundamentalmente','Fundamental que'],'It is fundamental that... (+ subjunctive)',5),
    (v_lesson_id,'multiple_choice','How do you say "I doubt that..." (+ subj.)?','Dudo que...',array['Dudo','Tengo dudas','Yo dudar'],'I doubt that... [DOO-doh keh]',6),
    (v_lesson_id,'multiple_choice','Conjugate: "I doubt he will come" — Dudo que él ___ (venir)','venga',array['viene','vino','vendrá'],'Subj: venga',7),
    (v_lesson_id,'multiple_choice','How do you say "as long as..."?','siempre que...',array['cuando también','mientras que','tanto que'],'As long as... (+ subj.)',8),
    (v_lesson_id,'multiple_choice','How do you say "in spite of (the fact that)..."?','a pesar de que...',array['aunque también','sin embargo','no obstante'],'In spite of [ah peh-SAHR deh]',9),
    (v_lesson_id,'multiple_choice','How do you say "we need to take action"?','tenemos que actuar',array['hay que actuar también','debemos tomar acción','vamos actuar'],'We need to take action [ahk-too-AHR]',10),
    (v_lesson_id,'multiple_choice','How do you say "to be against (something)"?','estar en contra de',array['estar contra','no acuerdo','oponer'],'To be against',11),
    (v_lesson_id,'multiple_choice','How do you say "to be in favor of"?','estar a favor de',array['estar para','estar con','apoyar también'],'To be in favor of',12),
    (v_lesson_id,'multiple_choice','How do you say "corruption"?','la corrupción',array['el escándalo','el robo','la fraude'],'Corruption [koh-rroop-SYOHN]',13),
    (v_lesson_id,'multiple_choice','How do you say "transparency"?','la transparencia',array['la claridad','el cristal','la honestidad'],'Transparency [trahns-pah-REHN-syah]',14),
    (v_lesson_id,'multiple_choice','Translate "Es fundamental que la prensa sea libre."','It is fundamental that the press be free',array['The press is free','The press will be free','The press must be free'],'It is fundamental that the press be free (subj.)',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','es importante que votes',array['es importante votar','importante votes','es importante que voten'],'Its important that you vote',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','estoy en contra de esa ley',array['estoy a favor de esa ley','estoy contra esa ley','no estoy contra la ley'],'I am against that law',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','dudo que el gobierno cambie',array['dudo el gobierno cambia','el gobierno no cambia','espero que cambie'],'I doubt the government will change',18),
    (v_lesson_id,'speaking','Say "Its important that we all participate" in Spanish.','Es importante que todos participemos',array[]::text[],'Es importante que todos participemos',19),
    (v_lesson_id,'speaking','Say "I am against corruption" in Spanish.','Estoy en contra de la corrupción',array[]::text[],'Estoy en contra de la corrupción',20),
    (v_lesson_id,'fill_blank','Complete: "Es importante que tú ___" (you vote)','votes',array['votas','votaste','votarás'],'you vote (subj.)',21),
    (v_lesson_id,'fill_blank','Complete: "Estoy en contra ___ esa ley." (of)','de',array['con','para','a'],'of',22);

  -- Lesson 3: news headlines (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Politics — Lesson 3', 'Listen to political news headlines.', 'listening', 3, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "to announce"?','anunciar',array['decir','informar','publicar'],'To announce [ah-noon-SYAHR]',1),
    (v_lesson_id,'multiple_choice','How do you say "to negotiate"?','negociar',array['hablar','tratar','intercambiar'],'To negotiate [neh-goh-SYAHR]',2),
    (v_lesson_id,'multiple_choice','How do you say "agreement / accord"?','el acuerdo',array['el pacto también','el contrato','la decisión'],'Agreement [ah-KWEHR-doh]',3),
    (v_lesson_id,'multiple_choice','How do you say "treaty"?','el tratado',array['el contrato','el acuerdo internacional','el pacto'],'Treaty [trah-TAH-doh]',4),
    (v_lesson_id,'multiple_choice','How do you say "summit"?','la cumbre',array['la reunión','la conferencia','el encuentro'],'Summit [KOOM-breh]',5),
    (v_lesson_id,'multiple_choice','How do you say "to face / confront"?','enfrentarse a',array['confrontar también','encarar','luchar contra'],'To face [ehn-frehn-TAHR-seh]',6),
    (v_lesson_id,'multiple_choice','How do you say "crisis"?','la crisis',array['el problema','el conflicto','la dificultad'],'Crisis [KREE-sees]',7),
    (v_lesson_id,'multiple_choice','How do you say "scandal"?','el escándalo',array['el problema','la controversia','la polémica'],'Scandal [ehs-KAHN-dah-loh]',8),
    (v_lesson_id,'multiple_choice','How do you say "to resign"?','dimitir',array['renunciar también','dejar','abandonar'],'To resign [dee-mee-TEER]',9),
    (v_lesson_id,'multiple_choice','How do you say "spokesperson"?','el portavoz',array['el voz','el representante','el hablante'],'Spokesperson [pohr-tah-BOHS]',10),
    (v_lesson_id,'multiple_choice','How do you say "to declare"?','declarar',array['decir','anunciar','expresar'],'To declare [deh-klah-RAHR]',11),
    (v_lesson_id,'multiple_choice','How do you say "to deny"?','negar',array['rechazar','rehusar','no decir'],'To deny [neh-GAHR]',12),
    (v_lesson_id,'multiple_choice','How do you say "to support (a policy)"?','apoyar',array['sostener también','soportar (= tolerate)','sustentar'],'To support [ah-poh-YAHR]',13),
    (v_lesson_id,'multiple_choice','How do you say "to criticize"?','criticar',array['atacar','quejarse','censurar'],'To criticize [kree-tee-KAHR]',14),
    (v_lesson_id,'multiple_choice','Translate "Según los expertos, la crisis durará varios meses."','According to the experts, the crisis will last several months',array['Experts deny the crisis','The crisis is ending','The crisis lasted months'],'According to the experts, the crisis will last several months',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','el presidente anunció reformas',array['el presidente anuncia reformas','el presidente quiere reformas','las reformas son anunciadas'],'The president announced reforms',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','el ministro dimitió',array['el ministro fue elegido','el ministro habló','la ministra dimitió'],'The minister resigned',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','llegaron a un acuerdo',array['llegaron al hotel','llegaron tarde','llegaron a un pacto'],'They reached an agreement',18),
    (v_lesson_id,'speaking','Say "The government announced new laws" in Spanish.','El gobierno anunció nuevas leyes',array[]::text[],'El gobierno anunció nuevas leyes',19),
    (v_lesson_id,'speaking','Say "We need transparency in politics" in Spanish.','Necesitamos transparencia en la política',array[]::text[],'Necesitamos transparencia en la política',20),
    (v_lesson_id,'fill_blank','Complete: "El presidente ___ reformas." (announced)','anunció',array['anuncia','anunciaba','anunciará'],'announced',21),
    (v_lesson_id,'fill_blank','Complete: "Llegaron a un ___" (agreement)','acuerdo',array['acuerdo grande','pacto','convenio'],'agreement',22);

  -- Lesson 4: speaking about politics
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Politics — Lesson 4', 'Argue your political views respectfully.', 'speaking', 4, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "Personally I believe..."?','Personalmente, creo...',array['Yo creer','Personal yo','En persona'],'Personally I believe...',1),
    (v_lesson_id,'multiple_choice','How do you say "I would never..."?','Yo nunca...',array['Yo no nunca','Nunca yo','Ninguno yo'],'I would never...',2),
    (v_lesson_id,'multiple_choice','How do you say "Its high time that..."?','Ya es hora de que... (+ subj.)',array['Es hora','Ya hora','La hora de'],'Its high time that... [oh-rah deh keh]',3),
    (v_lesson_id,'multiple_choice','How do you say "to be polarized"?','estar polarizado',array['polarizar','separado','dividido también'],'To be polarized [poh-lah-ree-SAH-doh]',4),
    (v_lesson_id,'multiple_choice','How do you say "to compromise (politically)"?','llegar a un compromiso',array['comprometerse','hacer un trato también','ceder también'],'To compromise [kohm-proh-MEE-soh]',5),
    (v_lesson_id,'multiple_choice','How do you say "from a political point of view"?','desde el punto de vista político',array['del lado político','en política','en perspectiva política'],'From a political point of view',6),
    (v_lesson_id,'multiple_choice','How do you say "the welfare state"?','el estado del bienestar',array['estado de bien','el bienestar nacional','el estado social'],'Welfare state [byehn-ehs-TAHR]',7),
    (v_lesson_id,'multiple_choice','How do you say "freedom of speech"?','la libertad de expresión',array['libertad de hablar','libre de hablar','la libertad civil'],'Freedom of speech [lee-behr-TAHD]',8),
    (v_lesson_id,'multiple_choice','How do you say "civil rights"?','los derechos civiles',array['derechos cívicos','derechos sociales','derechos humanos también'],'Civil rights',9),
    (v_lesson_id,'multiple_choice','How do you say "to vote for someone"?','votar por alguien',array['votar a alguien también','elegir a alguien','dar voto a'],'To vote for someone',10),
    (v_lesson_id,'multiple_choice','How do you say "to abstain"?','abstenerse',array['no votar','rechazar','negar'],'To abstain [ahbs-teh-NEHR-seh]',11),
    (v_lesson_id,'multiple_choice','How do you say "majority"?','la mayoría',array['la mayor parte','el más','los más'],'Majority [mah-yoh-REE-ah]',12),
    (v_lesson_id,'multiple_choice','How do you say "minority"?','la minoría',array['la menor parte','los pocos','el menos'],'Minority [mee-noh-REE-ah]',13),
    (v_lesson_id,'multiple_choice','How do you say "to put yourself in someone elses shoes"?','ponerse en el lugar del otro',array['ser otra persona','cambiar lugar','tener empatía'],'To put yourself in someones shoes',14),
    (v_lesson_id,'multiple_choice','Translate "A pesar de que no estoy de acuerdo, respeto su opinión."','Although I disagree, I respect his opinion',array['I agree with his opinion','I respect his decision','I do not respect him'],'Although I disagree, I respect his opinion',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','personalmente, creo que es injusto',array['personalmente, creo que es justo','en persona creo','yo creer es injusto'],'Personally, I believe its unjust',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','ya es hora de que actuemos',array['ya es hora actuamos','ya es la hora','es hora de actuar'],'Its high time we acted',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','la libertad de expresión es fundamental',array['libertad de hablar es fundamental','la libertad es fundamental','la expresión es importante'],'Freedom of speech is fundamental',18),
    (v_lesson_id,'speaking','Say "Personally, I am in favor of reform" in Spanish.','Personalmente, estoy a favor de la reforma',array[]::text[],'Personalmente, estoy a favor de la reforma',19),
    (v_lesson_id,'speaking','Say "Freedom of speech is non-negotiable" in Spanish.','La libertad de expresión es innegociable',array[]::text[],'La libertad de expresión es innegociable',20),
    (v_lesson_id,'fill_blank','Complete: "Ya es hora de que ___" (we act)','actuemos',array['actuamos','actuábamos','actuaremos'],'we act (subj.)',21),
    (v_lesson_id,'fill_blank','Complete: "A pesar ___ que no acuerdo." (of (the fact))','de',array['a','con','para'],'of',22);

  -- =================== B2.2 TECHNOLOGY ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Technology', 'Talk about software, AI and digital life in Spanish.', 'B2', 2)
  returning id into v_course_id;

  -- Lesson 1: tech vocab
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Technology — Lesson 1', 'Devices, software and the internet.', 'vocabulary', 1, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "technology"?','la tecnología',array['la tecnológico','la maquina','la innovación'],'Technology [tehk-noh-loh-HEE-ah]',1),
    (v_lesson_id,'multiple_choice','How do you say "smartphone / mobile (Spain)"?','el móvil',array['el celular (LatAm)','el smartphone','el teléfono'],'Mobile (Spain) [MOH-beel]',2),
    (v_lesson_id,'multiple_choice','How do you say "computer (Spain)"?','el ordenador',array['la computadora (LatAm)','el ordenado','la computa'],'Computer (Spain) [ohr-deh-nah-DOHR]',3),
    (v_lesson_id,'multiple_choice','How do you say "app / application"?','la aplicación',array['la app también','el programa','el aplicativo'],'App [ah-plee-kah-SYOHN]',4),
    (v_lesson_id,'multiple_choice','How do you say "software"?','el software',array['los programas también','el soft','el sistema'],'Software [SOHFT-wehr]',5),
    (v_lesson_id,'multiple_choice','How do you say "hardware"?','el hardware',array['las piezas','el hard','la máquina'],'Hardware [HARD-wehr]',6),
    (v_lesson_id,'multiple_choice','How do you say "artificial intelligence"?','la inteligencia artificial',array['IA (abbrev.)','inteligencia digital','la AI'],'AI [ah-ee] / [een-teh-lee-HEHN-syah]',7),
    (v_lesson_id,'multiple_choice','How do you say "algorithm"?','el algoritmo',array['el algoritm','el algo','el método'],'Algorithm [ahl-goh-REET-moh]',8),
    (v_lesson_id,'multiple_choice','How do you say "data"?','los datos',array['la data también','la información','los archivos'],'Data [DAH-tohs]',9),
    (v_lesson_id,'multiple_choice','How do you say "privacy"?','la privacidad',array['lo privado','el privado','la privacy'],'Privacy [pree-bah-see-DAHD]',10),
    (v_lesson_id,'multiple_choice','How do you say "cybersecurity"?','la ciberseguridad',array['la seguridad cibernética','la seguridad digital también','seguridad de cyber'],'Cybersecurity [see-behr-seh-goo-ree-DAHD]',11),
    (v_lesson_id,'multiple_choice','How do you say "to program / code"?','programar',array['codificar','escribir código','desarrollar también'],'To program [proh-grah-MAHR]',12),
    (v_lesson_id,'multiple_choice','How do you say "code (programming)"?','el código',array['la programación','el program','el soft'],'Code [KOH-dee-goh]',13),
    (v_lesson_id,'multiple_choice','How do you say "cloud (computing)"?','la nube',array['el cloud','la nubes','el aire'],'Cloud [NOO-beh]',14),
    (v_lesson_id,'multiple_choice','How do you say "to download"?','descargar',array['cargar (= upload)','bajar también','tomar'],'To download [dehs-kahr-GAHR]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','descargué la aplicación',array['cargué la aplicación','descargo la aplicación','descargaré la app'],'I downloaded the app',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','la nube es muy útil',array['las nubes son útiles','la nube no es útil','la nube es muy buena'],'The cloud is very useful',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','la inteligencia artificial cambia todo',array['la IA cambia algo','la inteligencia artificial es nueva','la AI cambia todo'],'AI changes everything',18),
    (v_lesson_id,'speaking','Say "I downloaded a new app" in Spanish.','Descargué una aplicación nueva',array[]::text[],'Descargué una aplicación nueva',19),
    (v_lesson_id,'speaking','Say "Privacy on the internet is important" in Spanish.','La privacidad en internet es importante',array[]::text[],'La privacidad en internet es importante',20),
    (v_lesson_id,'fill_blank','Complete: "Tengo que ___ la aplicación." (download)','descargar',array['cargar','subir','poner'],'download',21),
    (v_lesson_id,'fill_blank','Complete: "Trabajo con inteligencia ___" (artificial)','artificial',array['digital','natural','humana'],'artificial',22);

  -- Lesson 2: passive voice + se impersonal
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Technology — Lesson 2', 'Passive voice and impersonal "se".', 'grammar', 2, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "It is said that..."?','Se dice que...',array['Es dicho que','Dicen que también','Se decir que'],'It is said that... (impersonal se)',1),
    (v_lesson_id,'multiple_choice','How do you say "Spanish is spoken here"?','Aquí se habla español',array['Aquí habla español','El español aquí','Se hablar español aquí'],'Spanish is spoken here (impersonal se)',2),
    (v_lesson_id,'multiple_choice','Which is passive: "the email was sent"?','El correo fue enviado',array['Enviaron el correo','El correo es enviar','El correo se envió también'],'Passive: ser + participle',3),
    (v_lesson_id,'multiple_choice','Which is passive: "the app was created in Spain"?','La aplicación fue creada en España',array['Crearon la app en España','La aplicación se crea','La app se creó también'],'Passive: fue + participle',4),
    (v_lesson_id,'multiple_choice','How do you say "Many emails are sent every day"?','Se envían muchos correos cada día',array['Envían muchos correos','Se envía muchos correos','Muchos correos enviar'],'Many emails are sent every day',5),
    (v_lesson_id,'multiple_choice','How do you say "the website was hacked"?','La página web fue hackeada',array['Hackearon la página web también','La página fue hack','La página hackeó'],'The website was hacked',6),
    (v_lesson_id,'multiple_choice','How do you say "to update (a system)"?','actualizar',array['poner al día también','renovar','modernizar'],'To update [ahk-too-ah-lee-SAHR]',7),
    (v_lesson_id,'multiple_choice','How do you say "update (the noun)"?','la actualización',array['la actualizar','el update','el cambio'],'Update [ahk-too-ah-lee-sah-SYOHN]',8),
    (v_lesson_id,'multiple_choice','How do you say "password"?','la contraseña',array['el password','la clave también','el código'],'Password [kohn-trah-SEH-nyah]',9),
    (v_lesson_id,'multiple_choice','How do you say "virus (computer)"?','el virus',array['el malware también','el infectado','el dañino'],'Virus [BEE-roos]',10),
    (v_lesson_id,'multiple_choice','How do you say "to hack"?','hackear',array['piratear también','penetrar','infiltrar'],'To hack [hah-keh-AHR]',11),
    (v_lesson_id,'multiple_choice','How do you say "user"?','el usuario',array['el cliente','el persona','el users'],'User [oo-soo-AH-ryoh]',12),
    (v_lesson_id,'multiple_choice','How do you say "to log in"?','iniciar sesión',array['conectarse también','entrar','firmar'],'To log in [see-SYOHN]',13),
    (v_lesson_id,'multiple_choice','How do you say "to log out"?','cerrar sesión',array['salir también','desconectarse','terminar'],'To log out [seh-RRAHR]',14),
    (v_lesson_id,'multiple_choice','Translate "La aplicación fue creada por dos estudiantes."','The app was created by two students',array['Two students used the app','The app needs students','Students need apps'],'The app was created by two students (passive)',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','se dice que es muy útil',array['dicen que es útil','se dice útil','se decir útil'],'It is said that it is very useful',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','la aplicación fue creada en españa',array['la app es creada en españa','crearon la app','la aplicación se creó'],'The app was created in Spain',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','tengo que actualizar el software',array['tengo que cambiar el software','voy a actualizar el software','actualicé el software'],'I have to update the software',18),
    (v_lesson_id,'speaking','Say "Spanish is spoken in Mexico" in Spanish.','En México se habla español',array[]::text[],'En México se habla español',19),
    (v_lesson_id,'speaking','Say "The app was downloaded by millions" in Spanish.','La aplicación fue descargada por millones',array[]::text[],'La aplicación fue descargada por millones',20),
    (v_lesson_id,'fill_blank','Complete: "Aquí ___ habla español." (impersonal se)','se',array['lo','le','la'],'(impersonal se)',21),
    (v_lesson_id,'fill_blank','Complete: "La app fue ___ por dos amigos." (created)','creada',array['crear','crear','creado'],'created (f. participle)',22);

  -- Lesson 3: tech debates (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Technology — Lesson 3', 'Listen to discussions about tech impact.', 'listening', 3, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "to depend on (technology)"?','depender de',array['depender en','contar de','necesitar de'],'To depend on [deh-pehn-DEHR]',1),
    (v_lesson_id,'multiple_choice','How do you say "to be addicted to"?','ser adicto a',array['estar adicto a también','tener adicción a también','enviciarse'],'To be addicted to [ah-DEEK-toh]',2),
    (v_lesson_id,'multiple_choice','How do you say "screen time"?','el tiempo de pantalla',array['hora de pantalla','tiempo pantalla','el screen time'],'Screen time [PAHN-tah-yah]',3),
    (v_lesson_id,'multiple_choice','How do you say "to scroll"?','desplazarse',array['scrollear (Spanglish)','rodar','pasar'],'To scroll [dehs-plah-SAHR-seh]',4),
    (v_lesson_id,'multiple_choice','How do you say "to share (on social media)"?','compartir',array['publicar','postear (Spanglish)','poner'],'To share [kohm-pahr-TEER]',5),
    (v_lesson_id,'multiple_choice','How do you say "to go viral"?','hacerse viral',array['ser viral','volverse viral también','llegar viral'],'To go viral [bee-RAHL]',6),
    (v_lesson_id,'multiple_choice','How do you say "fake news"?','las noticias falsas',array['fake news (Spanglish)','noticias engañosas también','noticias mentirosas'],'Fake news',7),
    (v_lesson_id,'multiple_choice','How do you say "to verify (information)"?','verificar',array['comprobar también','confirmar','validar'],'To verify [beh-ree-fee-KAHR]',8),
    (v_lesson_id,'multiple_choice','How do you say "the digital divide"?','la brecha digital',array['la diferencia digital','el espacio digital','el divide'],'Digital divide [BREH-chah]',9),
    (v_lesson_id,'multiple_choice','How do you say "automation"?','la automatización',array['la automación','los robots','el auto'],'Automation [ow-toh-mah-tee-sah-SYOHN]',10),
    (v_lesson_id,'multiple_choice','How do you say "to replace (jobs)"?','reemplazar',array['sustituir también','cambiar','tomar lugar'],'To replace [reh-ehm-plah-SAHR]',11),
    (v_lesson_id,'multiple_choice','How do you say "ethics"?','la ética',array['la moral','la moralidad','los principios'],'Ethics [EH-tee-kah]',12),
    (v_lesson_id,'multiple_choice','How do you say "bias (in AI)"?','el sesgo',array['el prejuicio también','la inclinación','el lado'],'Bias [SEHS-goh]',13),
    (v_lesson_id,'multiple_choice','How do you say "to innovate"?','innovar',array['inventar','crear','renovar'],'To innovate [een-noh-BAHR]',14),
    (v_lesson_id,'multiple_choice','Translate "La inteligencia artificial podría reemplazar muchos empleos."','Artificial intelligence could replace many jobs',array['AI replaces jobs','AI replaced jobs','AI needs jobs'],'AI could replace many jobs',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','paso demasiado tiempo en el móvil',array['paso tiempo en el móvil','no paso tiempo en el móvil','pasaba tiempo en el móvil'],'I spend too much time on my phone',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','el video se hizo viral',array['el video es viral','el video se hace viral','los videos son virales'],'The video went viral',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','las noticias falsas son un problema',array['las noticias son un problema','noticias falsas problema','las falsas son problemas'],'Fake news is a problem',18),
    (v_lesson_id,'speaking','Say "I spend too much time on social media" in Spanish.','Paso demasiado tiempo en las redes sociales',array[]::text[],'Paso demasiado tiempo en las redes sociales',19),
    (v_lesson_id,'speaking','Say "AI is changing the world" in Spanish.','La inteligencia artificial está cambiando el mundo',array[]::text[],'La inteligencia artificial está cambiando el mundo',20),
    (v_lesson_id,'fill_blank','Complete: "El video se hizo ___" (viral)','viral',array['vital','virtual','vista'],'viral',21),
    (v_lesson_id,'fill_blank','Complete: "Soy adicto ___ móvil." (to)','al',array['en','de','con'],'to the',22);

  -- Lesson 4: speaking about technology
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Technology — Lesson 4', 'Share your tech opinions out loud.', 'speaking', 4, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "Tech has changed our lives"?','La tecnología ha cambiado nuestras vidas',array['Tecnología cambió vidas','Cambia vidas la tecnología','La tecnología cambia vida'],'Tech has changed our lives (present perfect)',1),
    (v_lesson_id,'multiple_choice','How do you say "to keep up with (tech)"?','estar al día con',array['mantenerse al día con también','seguir actualizado','no perder'],'To keep up with [ahl DEE-ah]',2),
    (v_lesson_id,'multiple_choice','How do you say "user-friendly"?','fácil de usar',array['amigable al usuario','user friendly','del usuario fácil'],'User-friendly',3),
    (v_lesson_id,'multiple_choice','How do you say "the digital age"?','la era digital',array['la edad digital también','el tiempo digital','el siglo digital'],'The digital age [EH-rah]',4),
    (v_lesson_id,'multiple_choice','How do you say "to disconnect (from tech)"?','desconectarse',array['desenchufar','salir','dejar'],'To disconnect [dehs-koh-nehk-TAHR-seh]',5),
    (v_lesson_id,'multiple_choice','How do you say "Im sick of social media"?','Estoy harto de las redes sociales',array['Yo cansado redes','Soy harto','Tengo harto redes'],'Im sick of social media [AHR-toh]',6),
    (v_lesson_id,'multiple_choice','How do you say "double-edged sword"?','un arma de doble filo',array['una espada doble','un arma con dos lados','la moneda con dos caras'],'Double-edged sword [DOH-bleh FEE-loh]',7),
    (v_lesson_id,'multiple_choice','How do you say "Were too dependent on..."?','Dependemos demasiado de...',array['Somos dependientes demasiado','Tenemos dependencia','Estamos demasiado dependientes'],'Were too dependent on...',8),
    (v_lesson_id,'multiple_choice','How do you say "to scroll mindlessly"?','desplazarse sin pensar',array['rodar sin pensar','scrollear sin pensar','desplazar pensar'],'To scroll mindlessly',9),
    (v_lesson_id,'multiple_choice','How do you say "to set limits"?','poner límites',array['hacer límites','dar límites','limitar también'],'To set limits',10),
    (v_lesson_id,'multiple_choice','How do you say "a digital detox"?','una desintoxicación digital',array['un detox digital','una limpieza digital','el descanso digital también'],'A digital detox',11),
    (v_lesson_id,'multiple_choice','How do you say "to keep in touch"?','mantenerse en contacto',array['quedar en contacto','seguir en contacto también','tener contacto'],'To keep in touch [kohn-TAHK-toh]',12),
    (v_lesson_id,'multiple_choice','How do you say "Without tech, we couldnt..."?','Sin tecnología, no podríamos...',array['Sin la tecnología, no podemos','No podríamos sin tecnología también','Sin tecnología no podemos'],'Without tech, we couldnt... (conditional)',13),
    (v_lesson_id,'multiple_choice','How do you say "to embrace innovation"?','abrazar la innovación',array['adoptar la innovación también','tomar la innovación','dar la bienvenida a'],'To embrace innovation',14),
    (v_lesson_id,'multiple_choice','Translate "Si no hubiera redes sociales, viviríamos mejor."','If there were no social media, we would live better',array['Without social media we live','Social media is bad','We need social media'],'If there were no social media, we would live better (past subj + conditional)',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','estoy harto de las redes',array['estoy contento con las redes','soy harto de redes','tengo harto'],'Im sick of social media',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','dependemos demasiado del móvil',array['no dependemos del móvil','dependemos del móvil','somos dependientes del móvil'],'Were too dependent on our phones',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','un arma de doble filo',array['un arma','una espada','un cuchillo de filo'],'A double-edged sword',18),
    (v_lesson_id,'speaking','Say "Im sick of social media" in Spanish.','Estoy harto de las redes sociales',array[]::text[],'Estoy harto de las redes sociales',19),
    (v_lesson_id,'speaking','Say "AI is a double-edged sword" in Spanish.','La IA es un arma de doble filo',array[]::text[],'La IA es un arma de doble filo',20),
    (v_lesson_id,'fill_blank','Complete: "Dependemos ___ del móvil." (too much)','demasiado',array['mucho','poco','siempre'],'too much',21),
    (v_lesson_id,'fill_blank','Complete: "Si no ___ redes sociales..." (there were no)','hubiera',array['hubo','había','hay'],'there were (past subj.)',22);

  -- =================== B2.3 PHILOSOPHY ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Philosophy', 'Discuss ideas, ethics and meaning in Spanish.', 'B2', 3)
  returning id into v_course_id;

  -- Lesson 1: philosophy vocab
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Philosophy — Lesson 1', 'Ethics, truth and knowledge.', 'vocabulary', 1, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "philosophy"?','la filosofía',array['la sabiduría','la ciencia','la ideología'],'Philosophy [fee-loh-soh-FEE-ah]',1),
    (v_lesson_id,'multiple_choice','How do you say "ethics"?','la ética',array['la moral','la moralidad','el deber'],'Ethics [EH-tee-kah]',2),
    (v_lesson_id,'multiple_choice','How do you say "morals"?','la moral',array['la ética también','los valores','la decencia'],'Morals [moh-RAHL]',3),
    (v_lesson_id,'multiple_choice','How do you say "truth"?','la verdad',array['la realidad','la cierto','el verídico'],'Truth [behr-DAHD]',4),
    (v_lesson_id,'multiple_choice','How do you say "lie"?','la mentira',array['el engaño','la falsedad también','el cuento'],'Lie [mehn-TEE-rah]',5),
    (v_lesson_id,'multiple_choice','How do you say "freedom"?','la libertad',array['la independencia','la libre','la soltura'],'Freedom [lee-behr-TAHD]',6),
    (v_lesson_id,'multiple_choice','How do you say "justice"?','la justicia',array['el derecho','la equidad','la rectitud'],'Justice [hoos-TEE-syah]',7),
    (v_lesson_id,'multiple_choice','How do you say "equality"?','la igualdad',array['lo igual','la equiparación','la equidad también'],'Equality [ee-gwahl-DAHD]',8),
    (v_lesson_id,'multiple_choice','How do you say "knowledge"?','el conocimiento',array['la sabiduría','el saber también','la información'],'Knowledge [koh-noh-see-MYEHN-toh]',9),
    (v_lesson_id,'multiple_choice','How do you say "wisdom"?','la sabiduría',array['el conocimiento','la inteligencia','la mente'],'Wisdom [sah-bee-doo-REE-ah]',10),
    (v_lesson_id,'multiple_choice','How do you say "existence"?','la existencia',array['la presencia','el ser','la vida'],'Existence [ehk-sees-TEHN-syah]',11),
    (v_lesson_id,'multiple_choice','How do you say "meaning / sense"?','el sentido',array['la significación','el propósito','el porqué'],'Meaning [sehn-TEE-doh]',12),
    (v_lesson_id,'multiple_choice','How do you say "purpose"?','el propósito',array['el objetivo también','la meta','la razón'],'Purpose [proh-POH-see-toh]',13),
    (v_lesson_id,'multiple_choice','How do you say "thought / thinking"?','el pensamiento',array['la idea','la opinión','la creencia'],'Thought [pehn-sah-MYEHN-toh]',14),
    (v_lesson_id,'multiple_choice','How do you say "reason / reasoning"?','la razón',array['la lógica','el motivo','el sentido'],'Reason [rah-SOHN]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','la libertad es fundamental',array['la libertad es básica','la libertad es importante','libertad fundamental'],'Freedom is fundamental',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','el sentido de la vida',array['el significado de la vida también','el propósito de la vida','el sentido de la muerte'],'The meaning of life',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','la verdad es relativa',array['la realidad es relativa','la verdad es real','la mentira es relativa'],'Truth is relative',18),
    (v_lesson_id,'speaking','Say "Freedom is essential to humanity" in Spanish.','La libertad es esencial para la humanidad',array[]::text[],'La libertad es esencial para la humanidad',19),
    (v_lesson_id,'speaking','Say "Knowledge is power" in Spanish.','El conocimiento es poder',array[]::text[],'El conocimiento es poder',20),
    (v_lesson_id,'fill_blank','Complete: "El ___ de la vida." (meaning)','sentido',array['propósito','sentir','sense'],'meaning',21),
    (v_lesson_id,'fill_blank','Complete: "La ___ es fundamental." (freedom)','libertad',array['libre','justicia','igualdad'],'freedom',22);

  -- Lesson 2: abstract concepts + opposing pairs
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Philosophy — Lesson 2', 'Virtue, vice and abstract concepts.', 'phrases', 2, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "logic"?','la lógica',array['la razón','el sentido','la lógica formal'],'Logic [LOH-hee-kah]',1),
    (v_lesson_id,'multiple_choice','How do you say "virtue"?','la virtud',array['la bondad','el bien','la pureza'],'Virtue [beer-TOOD]',2),
    (v_lesson_id,'multiple_choice','How do you say "vice"?','el vicio',array['la maldad','el pecado','la vicio'],'Vice [BEE-syoh]',3),
    (v_lesson_id,'multiple_choice','How do you say "soul"?','el alma',array['el espíritu también','el ser','la mente'],'Soul [AHL-mah]',4),
    (v_lesson_id,'multiple_choice','How do you say "consciousness / awareness"?','la conciencia',array['la conscient','la mente','el conocer'],'Consciousness [kohn-SYEHN-syah]',5),
    (v_lesson_id,'multiple_choice','How do you say "reality"?','la realidad',array['la verdad','la vida','el real'],'Reality [reh-ah-lee-DAHD]',6),
    (v_lesson_id,'multiple_choice','How do you say "perception"?','la percepción',array['la vista','el sentir','la idea'],'Perception [pehr-sehp-SYOHN]',7),
    (v_lesson_id,'multiple_choice','How do you say "doubt"?','la duda',array['la incertidumbre','el dudoso','la pregunta'],'Doubt [DOO-dah]',8),
    (v_lesson_id,'multiple_choice','How do you say "certainty"?','la certeza',array['la seguridad','lo cierto','la verdad'],'Certainty [sehr-TEH-sah]',9),
    (v_lesson_id,'multiple_choice','How do you say "good (the moral good)"?','el bien',array['lo bueno','la bondad','el bueno'],'The (moral) good [BYEHN]',10),
    (v_lesson_id,'multiple_choice','How do you say "evil"?','el mal',array['lo malo','la maldad','el malo'],'Evil [MAHL]',11),
    (v_lesson_id,'multiple_choice','How do you say "to question (something)"?','cuestionar',array['preguntar','dudar','interrogar'],'To question [kwehs-tyoh-NAHR]',12),
    (v_lesson_id,'multiple_choice','How do you say "to reflect (think deeply)"?','reflexionar',array['pensar','meditar también','considerar'],'To reflect [reh-flehk-syoh-NAHR]',13),
    (v_lesson_id,'multiple_choice','How do you say "to ponder"?','meditar',array['considerar también','pensar profundamente','contemplar'],'To ponder [meh-dee-TAHR]',14),
    (v_lesson_id,'multiple_choice','How do you say "free will"?','el libre albedrío',array['la libertad','el libre','la voluntad'],'Free will [lee-breh ahl-beh-DREE-oh]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','el bien y el mal',array['lo bueno y malo','los buenos y malos','el bueno y el malo'],'Good and evil',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','la conciencia humana',array['la consciente humana','la ciencia humana','la mente humana'],'Human consciousness',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','tenemos libre albedrío',array['tenemos libertad','no tenemos libertad','somos libres'],'We have free will',18),
    (v_lesson_id,'speaking','Say "Good and evil are subjective concepts" in Spanish.','El bien y el mal son conceptos subjetivos',array[]::text[],'El bien y el mal son conceptos subjetivos',19),
    (v_lesson_id,'speaking','Say "I question many things" in Spanish.','Cuestiono muchas cosas',array[]::text[],'Cuestiono muchas cosas',20),
    (v_lesson_id,'fill_blank','Complete: "El ___ y el mal." (the good)','bien',array['bueno','bondad','buen'],'good (noun)',21),
    (v_lesson_id,'fill_blank','Complete: "La ___ humana." (human consciousness)','conciencia',array['conciente','ciencia','mente'],'consciousness',22);

  -- Lesson 3: famous philosophers + ideas (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Philosophy — Lesson 3', 'Discuss philosophical ideas.', 'listening', 3, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "school of thought"?','la corriente de pensamiento',array['la escuela de pensar','la idea','la corriente'],'School of thought [koh-RRYEHN-teh]',1),
    (v_lesson_id,'multiple_choice','How do you say "to argue (in philosophy)"?','argumentar',array['discutir','debatir también','argumento'],'To argue (a point) [ahr-goo-mehn-TAHR]',2),
    (v_lesson_id,'multiple_choice','How do you say "premise"?','la premisa',array['la base','el principio','la idea'],'Premise [preh-MEE-sah]',3),
    (v_lesson_id,'multiple_choice','How do you say "conclusion"?','la conclusión',array['el final','el resultado','la decisión'],'Conclusion [kohn-kloo-SYOHN]',4),
    (v_lesson_id,'multiple_choice','How do you say "dialectic"?','la dialéctica',array['el diálogo','la dialectica','la conversación'],'Dialectic [dyah-LEHK-tee-kah]',5),
    (v_lesson_id,'multiple_choice','How do you say "essence"?','la esencia',array['el ser','lo esencial','el contenido'],'Essence [eh-SEHN-syah]',6),
    (v_lesson_id,'multiple_choice','How do you say "to contradict"?','contradecir',array['negar','oponerse','contrario'],'To contradict [kohn-trah-deh-SEER]',7),
    (v_lesson_id,'multiple_choice','How do you say "absolute truth"?','la verdad absoluta',array['la verdad total','la pura verdad','la verdad completa'],'Absolute truth [ahb-soh-LOO-tah]',8),
    (v_lesson_id,'multiple_choice','How do you say "relative"?','relativo',array['comparativo','relacionado','relacional'],'Relative [reh-lah-TEE-boh]',9),
    (v_lesson_id,'multiple_choice','How do you say "to interpret"?','interpretar',array['traducir','entender','explicar'],'To interpret [een-tehr-preh-TAHR]',10),
    (v_lesson_id,'multiple_choice','Translate "Pienso, luego existo." (Descartes)','I think, therefore I am',array['I think and I am','I think because I am','I am because I think'],'I think, therefore I am [LWEH-goh]',11),
    (v_lesson_id,'multiple_choice','How do you say "existentialism"?','el existencialismo',array['el existencialism','la existencia','el ser'],'Existentialism [ehk-sees-tehn-syah-LEES-moh]',12),
    (v_lesson_id,'multiple_choice','How do you say "to doubt everything"?','dudar de todo',array['dudar todo','tener duda de todo','dudar con todo'],'To doubt everything',13),
    (v_lesson_id,'multiple_choice','How do you say "Socrates"?','Sócrates',array['Sokrates','Soccrates','Socratic'],'Socrates [SOH-krah-tehs]',14),
    (v_lesson_id,'multiple_choice','Translate "Solo sé que no sé nada."','I only know that I know nothing',array['I know nothing','I know one thing','I know everything'],'I only know that I know nothing (Socratic)',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','pienso luego existo',array['existo luego pienso','pienso entonces soy','pienso luego soy'],'I think therefore I am',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','la verdad es relativa',array['la verdad es absoluta','la verdad es subjetiva','la realidad es relativa'],'Truth is relative',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','solo sé que no sé nada',array['no sé nada','sé que no sé','solo no sé nada'],'I only know that I know nothing',18),
    (v_lesson_id,'speaking','Say "I think, therefore I am" in Spanish.','Pienso, luego existo',array[]::text[],'Pienso, luego existo',19),
    (v_lesson_id,'speaking','Say "Truth is relative" in Spanish.','La verdad es relativa',array[]::text[],'La verdad es relativa',20),
    (v_lesson_id,'fill_blank','Complete: "Pienso, ___ existo." (therefore)','luego',array['así','pero','por'],'therefore',21),
    (v_lesson_id,'fill_blank','Complete: "Solo sé que no sé ___" (nothing)','nada',array['algo','todo','poco'],'nothing',22);

  -- Lesson 4: speaking about deep questions
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Philosophy — Lesson 4', 'Discuss the big questions out loud.', 'speaking', 4, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "What is the meaning of life?"','¿Cuál es el sentido de la vida?',array['¿Qué sentido tiene la vida?','¿El sentido cuál?','¿Qué vida sentido?'],'What is the meaning of life?',1),
    (v_lesson_id,'multiple_choice','How do you say "Does free will exist?"','¿Existe el libre albedrío?',array['¿Hay libre albedrío?','¿Existir libre?','¿Es libre albedrío?'],'Does free will exist?',2),
    (v_lesson_id,'multiple_choice','How do you say "to ask oneself"?','preguntarse',array['preguntar','dudar','cuestionar'],'To ask oneself [preh-goon-TAHR-seh]',3),
    (v_lesson_id,'multiple_choice','How do you say "as far as I know"?','que yo sepa',array['según mi conocimiento','en mi opinión','hasta donde sé'],'As far as I know (+ subj.)',4),
    (v_lesson_id,'multiple_choice','How do you say "it depends on..."?','depende de...',array['dependiente de','depender de','según...'],'It depends on... [deh-PEHN-deh]',5),
    (v_lesson_id,'multiple_choice','How do you say "there is no easy answer"?','no hay una respuesta fácil',array['no es una respuesta fácil','no tiene respuesta fácil','no hay respuesta'],'There is no easy answer',6),
    (v_lesson_id,'multiple_choice','How do you say "to give meaning to"?','dar sentido a',array['darle significado','poner sentido','tener sentido'],'To give meaning to',7),
    (v_lesson_id,'multiple_choice','How do you say "if I were you..."?','si yo fuera tú...',array['si fui tú','si soy tú','si era tú'],'If I were you (past subj.)',8),
    (v_lesson_id,'multiple_choice','How do you say "to face a dilemma"?','enfrentarse a un dilema',array['enfrentar un dilema también','tener un dilema','encontrar dilema'],'To face a dilemma [dee-LEH-mah]',9),
    (v_lesson_id,'multiple_choice','How do you say "Its a paradox"?','Es una paradoja',array['Es un paradox','Es paradoja','Es la paradoja'],'Its a paradox [pah-rah-DOH-hah]',10),
    (v_lesson_id,'multiple_choice','How do you say "everything is connected"?','todo está conectado',array['todo conectado','está todo conectado también','todo es conectado'],'Everything is connected',11),
    (v_lesson_id,'multiple_choice','How do you say "the universe"?','el universo',array['el cosmos también','el mundo','la galaxia'],'The universe [oo-nee-BEHR-soh]',12),
    (v_lesson_id,'multiple_choice','How do you say "death"?','la muerte',array['lo mortal','el fin','la final'],'Death [MWEHR-teh]',13),
    (v_lesson_id,'multiple_choice','How do you say "afterlife"?','el más allá',array['la vida después también','el cielo','el otro mundo'],'Afterlife [mahs ah-YAH]',14),
    (v_lesson_id,'multiple_choice','Translate "Si pudiera, viajaría en el tiempo para entender mejor el mundo."','If I could, I would travel through time to better understand the world',array['I will travel in time','I want to travel through time','Time travel exists'],'If I could, I would travel through time (past subj + conditional)',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','¿cuál es el sentido de la vida?',array['¿qué es la vida?','¿el sentido es vida?','¿qué sentido tiene?'],'What is the meaning of life?',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','no hay una respuesta fácil',array['hay una respuesta','no hay respuesta','no es fácil la respuesta'],'There is no easy answer',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','todo está conectado',array['nada está conectado','está todo desconectado','todo conecta'],'Everything is connected',18),
    (v_lesson_id,'speaking','Say "What is the meaning of life?" in Spanish.','¿Cuál es el sentido de la vida?',array[]::text[],'¿Cuál es el sentido de la vida?',19),
    (v_lesson_id,'speaking','Say "If I were you, I would think more about it" in Spanish.','Si yo fuera tú, lo pensaría más',array[]::text[],'Si yo fuera tú, lo pensaría más',20),
    (v_lesson_id,'fill_blank','Complete: "Si yo ___ tú..." (were)','fuera',array['fui','soy','era'],'were (past subj.)',21),
    (v_lesson_id,'fill_blank','Complete: "¿Cuál es el ___ de la vida?" (meaning)','sentido',array['significado','sentir','sense'],'meaning',22);

  -- =================== B2.4 LITERATURE ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Literature', 'Talk about books, poetry and literary techniques.', 'B2', 4)
  returning id into v_course_id;

  -- Lesson 1: literary vocab
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Literature — Lesson 1', 'Genres, authors and storytelling.', 'vocabulary', 1, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "literature"?','la literatura',array['las letras también','los libros','la lectura'],'Literature [lee-teh-rah-TOO-rah]',1),
    (v_lesson_id,'multiple_choice','How do you say "novel"?','la novela',array['el libro','el cuento','la historia'],'Novel [noh-BEH-lah]',2),
    (v_lesson_id,'multiple_choice','How do you say "poetry"?','la poesía',array['el poema (one poem)','la lírica','la rima'],'Poetry [poh-eh-SEE-ah]',3),
    (v_lesson_id,'multiple_choice','How do you say "poem"?','el poema',array['la poesía (general)','el verso','la rima'],'Poem [poh-EH-mah]',4),
    (v_lesson_id,'multiple_choice','How do you say "short story"?','el cuento',array['la cuenta','la narración corta también','la historia corta'],'Short story [KWEHN-toh]',5),
    (v_lesson_id,'multiple_choice','How do you say "essay (literary)"?','el ensayo',array['el artículo','el texto','la prosa'],'Essay [ehn-SAH-yoh]',6),
    (v_lesson_id,'multiple_choice','How do you say "author"?','el autor',array['el escritor también','el creador','el writer'],'Author [ow-TOHR]',7),
    (v_lesson_id,'multiple_choice','How do you say "character (in story)"?','el personaje',array['el carácter (= personality)','la persona','el actor'],'Character [pehr-soh-NAH-heh]',8),
    (v_lesson_id,'multiple_choice','How do you say "plot"?','la trama',array['la historia','el argumento también','la línea'],'Plot [TRAH-mah]',9),
    (v_lesson_id,'multiple_choice','How do you say "chapter"?','el capítulo',array['la sección','la parte','el episodio'],'Chapter [kah-PEE-too-loh]',10),
    (v_lesson_id,'multiple_choice','How do you say "genre"?','el género',array['el estilo','el tipo','la categoría'],'Genre [HEH-neh-roh]',11),
    (v_lesson_id,'multiple_choice','How do you say "fiction"?','la ficción',array['la imaginación','la fantasía','lo ficticio'],'Fiction [feek-SYOHN]',12),
    (v_lesson_id,'multiple_choice','How do you say "non-fiction"?','la no ficción',array['la realidad','los hechos','la verdad'],'Non-fiction',13),
    (v_lesson_id,'multiple_choice','How do you say "narrator"?','el narrador',array['el autor','el cuentista','el narrating'],'Narrator [nah-rrah-DOHR]',14),
    (v_lesson_id,'multiple_choice','How do you say "biography"?','la biografía',array['la historia personal','la vida','la autobiografía (auto-)'],'Biography [byoh-grah-FEE-ah]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','me encanta la poesía',array['me gusta la poesía','no me gusta la poesía','escribo poesía'],'I love poetry',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','leí una novela increíble',array['leí un cuento increíble','leo una novela','leeré una novela'],'I read an amazing novel',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','el personaje principal es complejo',array['el personaje secundario es complejo','el carácter principal es complejo','los personajes son complejos'],'The main character is complex',18),
    (v_lesson_id,'speaking','Say "Im reading a Spanish novel" in Spanish.','Estoy leyendo una novela española',array[]::text[],'Estoy leyendo una novela española',19),
    (v_lesson_id,'speaking','Say "Poetry is a beautiful art" in Spanish.','La poesía es un arte hermoso',array[]::text[],'La poesía es un arte hermoso',20),
    (v_lesson_id,'fill_blank','Complete: "El ___ principal es complejo." (character)','personaje',array['carácter','persona','autor'],'character',21),
    (v_lesson_id,'fill_blank','Complete: "El primer ___ del libro." (chapter)','capítulo',array['página','parte','sección'],'chapter',22);

  -- Lesson 2: literary techniques
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Literature — Lesson 2', 'Metaphor, symbolism and analysis.', 'phrases', 2, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "metaphor"?','la metáfora',array['el símil','la comparación','la metafísica'],'Metaphor [meh-TAH-foh-rah]',1),
    (v_lesson_id,'multiple_choice','How do you say "simile"?','el símil',array['la metáfora','la comparación también','la imagen'],'Simile [SEE-meel]',2),
    (v_lesson_id,'multiple_choice','How do you say "symbolism"?','el simbolismo',array['el símbolo','los símbolos','la simbólica'],'Symbolism [seem-boh-LEES-moh]',3),
    (v_lesson_id,'multiple_choice','How do you say "verse"?','el verso',array['la línea','la estrofa','el poema'],'Verse [BEHR-soh]',4),
    (v_lesson_id,'multiple_choice','How do you say "stanza"?','la estrofa',array['el verso','el párrafo','la línea'],'Stanza [ehs-TROH-fah]',5),
    (v_lesson_id,'multiple_choice','How do you say "rhyme"?','la rima',array['la métrica','el ritmo','la rítmica'],'Rhyme [REE-mah]',6),
    (v_lesson_id,'multiple_choice','How do you say "to analyze"?','analizar',array['estudiar','examinar','revisar'],'To analyze [ah-nah-lee-SAHR]',7),
    (v_lesson_id,'multiple_choice','How do you say "to interpret"?','interpretar',array['traducir','entender','descifrar'],'To interpret [een-tehr-preh-TAHR]',8),
    (v_lesson_id,'multiple_choice','How do you say "deep meaning"?','el significado profundo',array['el sentido profundo también','la idea profunda','el significado interno'],'Deep meaning [proh-FOON-doh]',9),
    (v_lesson_id,'multiple_choice','How do you say "theme"?','el tema',array['el sujeto','la temática','el asunto también'],'Theme [TEH-mah]',10),
    (v_lesson_id,'multiple_choice','How do you say "imagery"?','las imágenes',array['las imáginas','la imagery','los dibujos'],'Imagery (literary)',11),
    (v_lesson_id,'multiple_choice','How do you say "to evoke"?','evocar',array['llamar','recordar','despertar'],'To evoke [eh-boh-KAHR]',12),
    (v_lesson_id,'multiple_choice','How do you say "irony"?','la ironía',array['el sarcasmo','la burla','el ironic'],'Irony [ee-roh-NEE-ah]',13),
    (v_lesson_id,'multiple_choice','How do you say "tragedy"?','la tragedia',array['el drama','la desgracia','el tragico'],'Tragedy [trah-HEH-dyah]',14),
    (v_lesson_id,'multiple_choice','How do you say "comedy"?','la comedia',array['el humor','el chiste','la comicidad'],'Comedy [koh-MEH-dyah]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','el poema usa muchas metáforas',array['el poema tiene metáforas','el poema usa imágenes','los poemas usan metáforas'],'The poem uses many metaphors',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','el tema principal es el amor',array['el tema es el amor','los temas son el amor','el amor es el tema'],'The main theme is love',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','es una tragedia clásica',array['es una comedia clásica','es un drama','es una tragedia moderna'],'It is a classical tragedy',18),
    (v_lesson_id,'speaking','Say "I love the imagery in this poem" in Spanish.','Me encantan las imágenes de este poema',array[]::text[],'Me encantan las imágenes de este poema',19),
    (v_lesson_id,'speaking','Say "The author uses many metaphors" in Spanish.','El autor usa muchas metáforas',array[]::text[],'El autor usa muchas metáforas',20),
    (v_lesson_id,'fill_blank','Complete: "El tema ___ es el amor." (main)','principal',array['primero','grande','famoso'],'main',21),
    (v_lesson_id,'fill_blank','Complete: "El poema usa muchas ___" (metaphors)','metáforas',array['símiles','símbolos','imágenes'],'metaphors',22);

  -- Lesson 3: famous works (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Literature — Lesson 3', 'Famous Hispanic authors and works.', 'listening', 3, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','Who wrote "Don Quijote"?','Miguel de Cervantes',array['Gabriel García Márquez','Federico García Lorca','Pablo Neruda'],'Cervantes (Spain)',1),
    (v_lesson_id,'multiple_choice','Who wrote "Cien años de soledad"?','Gabriel García Márquez',array['Cervantes','Borges','Neruda'],'García Márquez (Colombia)',2),
    (v_lesson_id,'multiple_choice','Where was Borges from?','Argentina',array['España','México','Chile'],'Borges — Argentina',3),
    (v_lesson_id,'multiple_choice','How do you say "Nobel Prize"?','el Premio Nobel',array['el Nobel','el Premio','el Nobel Premio'],'Nobel Prize',4),
    (v_lesson_id,'multiple_choice','How do you say "magical realism"?','el realismo mágico',array['la magia real','el mágico real','el real mágico'],'Magical realism [reh-ah-LEES-moh MAH-hee-koh]',5),
    (v_lesson_id,'multiple_choice','How do you say "Generation of 27 (Spanish lit movement)"?','la Generación del 27',array['la Generación 27','la Generación del veinte','el grupo del 27'],'Generation of 27',6),
    (v_lesson_id,'multiple_choice','How do you say "Hispanic literature"?','la literatura hispana',array['la literatura española','la literatura del español','las letras hispanas también'],'Hispanic literature',7),
    (v_lesson_id,'multiple_choice','How do you say "to be inspired by"?','inspirarse en',array['inspirar de','tomar inspiración','copiar de'],'To be inspired by [eens-pee-RAHR-seh]',8),
    (v_lesson_id,'multiple_choice','How do you say "masterpiece"?','la obra maestra',array['la obra magna también','el clásico','la obra de arte'],'Masterpiece [MAHS-trah]',9),
    (v_lesson_id,'multiple_choice','How do you say "to publish"?','publicar',array['imprimir','editar','sacar'],'To publish [poo-blee-KAHR]',10),
    (v_lesson_id,'multiple_choice','How do you say "edition"?','la edición',array['el edición','la imprenta','la publicación'],'Edition [eh-dee-SYOHN]',11),
    (v_lesson_id,'multiple_choice','How do you say "translation"?','la traducción',array['el traductor','la traducer','el lenguaje'],'Translation [trah-dook-SYOHN]',12),
    (v_lesson_id,'multiple_choice','How do you say "censored"?','censurado',array['prohibido','silenciado','censurada'],'Censored (m.) [sehn-soo-RAH-doh]',13),
    (v_lesson_id,'multiple_choice','How do you say "anthology"?','la antología',array['la colección','el libro','las obras'],'Anthology [ahn-toh-loh-HEE-ah]',14),
    (v_lesson_id,'multiple_choice','Translate "García Márquez es considerado uno de los mejores escritores del siglo XX."','García Márquez is considered one of the best writers of the 20th century',array['García Márquez writes the best','García Márquez wrote the best','He writes best'],'García Márquez is considered one of the best writers of the 20th century',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','el realismo mágico es famoso',array['el realismo es famoso','el realismo mágico es nuevo','la magia es famosa'],'Magical realism is famous',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','cervantes escribió don quijote',array['cervantes leyó don quijote','don quijote escribió a cervantes','cervantes escribe don quijote'],'Cervantes wrote Don Quijote',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','ganó el premio nobel',array['ganaba el premio nobel','ganará el nobel','ganó nobel'],'He won the Nobel Prize',18),
    (v_lesson_id,'speaking','Say "García Márquez won the Nobel Prize" in Spanish.','García Márquez ganó el Premio Nobel',array[]::text[],'García Márquez ganó el Premio Nobel',19),
    (v_lesson_id,'speaking','Say "Don Quijote is a masterpiece" in Spanish.','Don Quijote es una obra maestra',array[]::text[],'Don Quijote es una obra maestra',20),
    (v_lesson_id,'fill_blank','Complete: "Ganó el Premio ___" (Nobel)','Nobel',array['Mejor','Grande','Único'],'Nobel',21),
    (v_lesson_id,'fill_blank','Complete: "Es una obra ___" (masterpiece)','maestra',array['maestro','grande','famosa'],'master (f.)',22);

  -- Lesson 4: literary discussion (speaking)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Literature — Lesson 4', 'Discuss what you read out loud.', 'speaking', 4, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "to recommend a book"?','recomendar un libro',array['sugerir un libro también','aconsejar un libro','dar un libro'],'To recommend a book [reh-koh-mehn-DAHR]',1),
    (v_lesson_id,'multiple_choice','How do you say "Im hooked on this book"?','Estoy enganchado a este libro',array['Yo enganchar libro','Tengo enganchado','Soy enganchado'],'Im hooked on this book [ehn-gahn-CHAH-doh]',2),
    (v_lesson_id,'multiple_choice','How do you say "I cannot put it down"?','No puedo dejarlo',array['No quiero dejarlo','No puedo dejar','No lo dejo'],'I cannot put it down',3),
    (v_lesson_id,'multiple_choice','How do you say "the ending was surprising"?','el final fue sorprendente',array['el final es sorpresa','el final fue sorprendido','el sorpresa fue final'],'The ending was surprising [sohr-prehn-DEHN-teh]',4),
    (v_lesson_id,'multiple_choice','How do you say "spoiler"?','el spoiler',array['la sorpresa','el destripe (slang)','spoiler también'],'Spoiler [SPOH-ee-lehr]',5),
    (v_lesson_id,'multiple_choice','How do you say "no spoilers, please"?','no me hagas spoilers, por favor',array['no spoilers','sin spoilers','no quiero spoiler'],'No spoilers, please',6),
    (v_lesson_id,'multiple_choice','How do you say "I identify with the protagonist"?','Me identifico con el protagonista',array['Yo identifico con','Yo soy igual','Estoy con el protagonista'],'I identify with the protagonist [proh-tah-goh-NEES-tah]',7),
    (v_lesson_id,'multiple_choice','How do you say "antagonist"?','el antagonista',array['el villano también','el enemigo','el opositor'],'Antagonist [ahn-tah-goh-NEES-tah]',8),
    (v_lesson_id,'multiple_choice','How do you say "Lets talk about the book"?','Hablemos del libro',array['Vamos a hablar libro','Hablamos libro','Habla del libro'],'Lets talk about the book',9),
    (v_lesson_id,'multiple_choice','How do you say "the author criticizes society"?','el autor critica la sociedad',array['el autor crítica de sociedad','el autor está crítica','autor sociedad critica'],'The author criticizes society',10),
    (v_lesson_id,'multiple_choice','How do you say "a page-turner"?','no se puede dejar',array['cuesta dejar','imposible dejar','un buen libro'],'A page-turner (idiom)',11),
    (v_lesson_id,'multiple_choice','How do you say "predictable"?','predecible',array['predecida','predeciendo','predicho'],'Predictable [preh-deh-SEE-bleh]',12),
    (v_lesson_id,'multiple_choice','How do you say "complex characters"?','personajes complejos',array['personajes difíciles','los personajes complicados','characters complejos'],'Complex characters',13),
    (v_lesson_id,'multiple_choice','How do you say "to capture (an audience)"?','cautivar',array['atrapar también','encantar','seducir'],'To captivate [kow-tee-BAHR]',14),
    (v_lesson_id,'multiple_choice','Translate "Si quisieras leer un clásico, te recomendaría Cien años de soledad."','If you wanted to read a classic, I would recommend One Hundred Years of Solitude',array['I read One Hundred Years of Solitude','You should read this','Cien años is classic'],'If you wanted to read a classic, I would recommend One Hundred Years of Solitude (past subj + conditional)',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','estoy enganchado a este libro',array['me gusta este libro','no puedo dejar este libro','estoy leyendo este libro'],'Im hooked on this book',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','el final fue sorprendente',array['el final fue triste','el final no fue sorpresa','el final fue inesperado también'],'The ending was surprising',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','te recomendaría este libro',array['te recomiendo este libro','te recomienden este libro','te recomendé este libro'],'I would recommend this book',18),
    (v_lesson_id,'speaking','Say "I cannot put this book down" in Spanish.','No puedo dejar este libro',array[]::text[],'No puedo dejar este libro',19),
    (v_lesson_id,'speaking','Say "I would recommend it to anyone" in Spanish.','Se lo recomendaría a cualquiera',array[]::text[],'Se lo recomendaría a cualquiera',20),
    (v_lesson_id,'fill_blank','Complete: "Estoy ___ a este libro." (hooked)','enganchado',array['enganchar','engancho','enganchada'],'hooked (m.)',21),
    (v_lesson_id,'fill_blank','Complete: "Te ___ este libro." (I would recommend)','recomendaría',array['recomiendo','recomendé','recomendaba'],'I would recommend',22);

  -- =================== B2.5 BUSINESS ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Business', 'Companies, deals and the workplace in Spanish.', 'B2', 5)
  returning id into v_course_id;

  -- Lesson 1: business vocab
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Business — Lesson 1', 'Companies, clients and markets.', 'vocabulary', 1, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "company / firm"?','la empresa',array['la compañía también','el negocio','la corporación'],'Company [ehm-PREH-sah]',1),
    (v_lesson_id,'multiple_choice','How do you say "business (activity)"?','el negocio',array['la empresa','el trabajo','el comercio'],'Business [neh-GOH-syoh]',2),
    (v_lesson_id,'multiple_choice','How do you say "market"?','el mercado',array['la tienda','el sector','el comercio'],'Market [mehr-KAH-doh]',3),
    (v_lesson_id,'multiple_choice','How do you say "client"?','el cliente',array['el comprador','el comprador también','el consumidor también'],'Client [KLYEHN-teh]',4),
    (v_lesson_id,'multiple_choice','How do you say "supplier"?','el proveedor',array['el vendedor','el distribuidor también','el productor'],'Supplier [proh-beh-eh-DOHR]',5),
    (v_lesson_id,'multiple_choice','How do you say "competition (rival)"?','la competencia',array['el rival','los competidores','la batalla'],'Competition [kohm-peh-TEHN-syah]',6),
    (v_lesson_id,'multiple_choice','How do you say "profit / earnings"?','las ganancias',array['los beneficios también','el provecho','las profits'],'Profit [gah-NAHN-syahs]',7),
    (v_lesson_id,'multiple_choice','How do you say "loss"?','las pérdidas',array['los perdidos','las pierde','el daño'],'Loss [PEHR-dee-dahs]',8),
    (v_lesson_id,'multiple_choice','How do you say "investment"?','la inversión',array['el invertir','la inversión grande','la inversión empresarial'],'Investment [een-behr-SYOHN]',9),
    (v_lesson_id,'multiple_choice','How do you say "shareholder"?','el accionista',array['el dueño','el inversor','el propietario'],'Shareholder [ahk-syoh-NEES-tah]',10),
    (v_lesson_id,'multiple_choice','How do you say "board of directors"?','la junta directiva',array['el consejo de administración también','la directiva','la mesa directiva'],'Board of directors [HOON-tah dee-rehk-TEE-bah]',11),
    (v_lesson_id,'multiple_choice','How do you say "strategy"?','la estrategia',array['el plan','el método','la táctica'],'Strategy [ehs-trah-TEH-hyah]',12),
    (v_lesson_id,'multiple_choice','How do you say "brand"?','la marca',array['la firma','el logo','el nombre'],'Brand [MAHR-kah]',13),
    (v_lesson_id,'multiple_choice','How do you say "sales"?','las ventas',array['la venta (singular)','los vendidos','las salidas'],'Sales [BEHN-tahs]',14),
    (v_lesson_id,'multiple_choice','How do you say "marketing"?','el marketing',array['la mercadotecnia también','el comercio','la publicidad'],'Marketing [MAHR-keh-teen]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','la empresa tiene mucho éxito',array['la compañía tiene éxito','la empresa es exitosa','las empresas tienen éxito'],'The company is very successful',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','nuestras ventas han aumentado',array['nuestras ventas aumentaron','las ventas aumentan','las ventas han aumentado'],'Our sales have increased',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','la competencia es feroz',array['la competencia es dura','la competencia es buena','la competencia es feroz también'],'The competition is fierce',18),
    (v_lesson_id,'speaking','Say "Our company is the leader in the market" in Spanish.','Nuestra empresa es líder en el mercado',array[]::text[],'Nuestra empresa es líder en el mercado',19),
    (v_lesson_id,'speaking','Say "Sales increased this year" in Spanish.','Las ventas aumentaron este año',array[]::text[],'Las ventas aumentaron este año',20),
    (v_lesson_id,'fill_blank','Complete: "Nuestras ___ aumentaron." (sales)','ventas',array['venta','compras','negocios'],'sales',21),
    (v_lesson_id,'fill_blank','Complete: "Tenemos una ___ fuerte." (brand)','marca',array['empresa','compañía','firma'],'brand',22);

  -- Lesson 2: business communication
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Business — Lesson 2', 'Meetings, negotiations and emails.', 'phrases', 2, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you start a formal email?','Estimado/a Sr./Sra...',array['Hola','Querido','Buenos días, persona'],'Dear Sir/Madam [ehs-tee-MAH-doh]',1),
    (v_lesson_id,'multiple_choice','How do you end a formal email?','Atentamente',array['Adiós','Hasta luego','Un saludo'],'Sincerely [ah-tehn-tah-MEHN-teh]',2),
    (v_lesson_id,'multiple_choice','How do you say "to confirm"?','confirmar',array['decir sí','aceptar','asegurar'],'To confirm [kohn-feer-MAHR]',3),
    (v_lesson_id,'multiple_choice','How do you say "to attach (a file)"?','adjuntar',array['poner','enviar con','añadir'],'To attach [ahd-hoon-TAHR]',4),
    (v_lesson_id,'multiple_choice','How do you say "attached file"?','el archivo adjunto',array['el archivo','el archivo añadido','el documento'],'Attached file [ahd-HOON-toh]',5),
    (v_lesson_id,'multiple_choice','How do you say "to schedule a meeting"?','programar una reunión',array['agendar (LatAm)','planear una reunión','reunir'],'To schedule a meeting [proh-grah-MAHR]',6),
    (v_lesson_id,'multiple_choice','How do you say "to cancel"?','cancelar',array['anular también','quitar','dejar'],'To cancel [kahn-seh-LAHR]',7),
    (v_lesson_id,'multiple_choice','How do you say "to postpone"?','aplazar',array['posponer también','retrasar','dejar para después'],'To postpone [ah-plah-SAHR]',8),
    (v_lesson_id,'multiple_choice','How do you say "to deliver (a project)"?','entregar',array['dar','llevar','dejar'],'To deliver [ehn-treh-GAHR]',9),
    (v_lesson_id,'multiple_choice','How do you say "deadline / due date"?','la fecha de entrega',array['la fecha límite también','el plazo también','el día final'],'Deadline [FEH-chah deh ehn-TREH-gah]',10),
    (v_lesson_id,'multiple_choice','How do you say "to negotiate (a deal)"?','negociar',array['discutir','hablar','tratar'],'To negotiate [neh-goh-SYAHR]',11),
    (v_lesson_id,'multiple_choice','How do you say "to close a deal"?','cerrar un trato',array['terminar trato','firmar trato','hacer trato'],'To close a deal [seh-RRAHR oon TRAH-toh]',12),
    (v_lesson_id,'multiple_choice','How do you say "to sign a contract"?','firmar un contrato',array['cerrar un contrato','escribir un contrato','poner contrato'],'To sign a contract [feer-MAHR]',13),
    (v_lesson_id,'multiple_choice','How do you say "best regards"?','un cordial saludo',array['atentamente también','con saludo','el saludo'],'Best regards [kohr-DYAHL sah-LOO-doh]',14),
    (v_lesson_id,'multiple_choice','Translate "Adjunto el informe que me solicitó."','I am attaching the report you requested',array['I sent the report','I will attach the report','I attached the report yesterday'],'I am attaching the report you requested',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','tenemos una reunión a las diez',array['tenemos reunión a las once','tenemos una junta a las diez','la reunión es a las diez'],'We have a meeting at ten',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','adjunto el archivo',array['envío el archivo','tengo el archivo','attached el archivo'],'Im attaching the file',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','necesito cancelar la reunión',array['necesito posponer la reunión','quiero cancelar la reunión','necesito una reunión'],'I need to cancel the meeting',18),
    (v_lesson_id,'speaking','Say "I would like to schedule a meeting" in Spanish.','Me gustaría programar una reunión',array[]::text[],'Me gustaría programar una reunión',19),
    (v_lesson_id,'speaking','Say "I am attaching the document" in Spanish.','Adjunto el documento',array[]::text[],'Adjunto el documento',20),
    (v_lesson_id,'fill_blank','Complete: "Le envío el archivo ___" (attached)','adjunto',array['enviado','agregado','añadido'],'attached',21),
    (v_lesson_id,'fill_blank','Complete: "Quiero ___ un contrato." (sign)','firmar',array['cerrar','escribir','poner'],'to sign',22);

  -- Lesson 3: startups + entrepreneurship (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Business — Lesson 3', 'Startups, financing and risk.', 'listening', 3, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "entrepreneur"?','el emprendedor',array['el empresario','el dueño','el inversor'],'Entrepreneur [ehm-prehn-deh-DOHR]',1),
    (v_lesson_id,'multiple_choice','How do you say "startup (new company)"?','la startup',array['la empresa nueva','la nueva empresa','la start'],'Startup',2),
    (v_lesson_id,'multiple_choice','How do you say "to launch (a product)"?','lanzar',array['sacar','presentar','tirar'],'To launch [lahn-SAHR]',3),
    (v_lesson_id,'multiple_choice','How do you say "to fund / finance"?','financiar',array['pagar','dar dinero','invertir'],'To fund [fee-nahn-SYAHR]',4),
    (v_lesson_id,'multiple_choice','How do you say "investor"?','el inversor',array['el inversionista (LatAm)','el accionista','el comprador'],'Investor (Spain) [een-behr-SOHR]',5),
    (v_lesson_id,'multiple_choice','How do you say "growth"?','el crecimiento',array['el aumento','el desarrollo','el incremento'],'Growth [kreh-see-MYEHN-toh]',6),
    (v_lesson_id,'multiple_choice','How do you say "to expand"?','expandirse',array['crecer','aumentar','ampliarse también'],'To expand [ehks-pahn-DEER-seh]',7),
    (v_lesson_id,'multiple_choice','How do you say "risk"?','el riesgo',array['el peligro','la posibilidad','la apuesta'],'Risk [RYEHS-goh]',8),
    (v_lesson_id,'multiple_choice','How do you say "to take risks"?','asumir riesgos',array['tomar riesgos también','correr riesgos también','dar riesgos'],'To take risks [ah-soo-MEER]',9),
    (v_lesson_id,'multiple_choice','How do you say "to bankrupt"?','quebrar',array['arruinarse también','fallar','perder todo'],'To go bankrupt [keh-BRAHR]',10),
    (v_lesson_id,'multiple_choice','How do you say "to succeed"?','tener éxito',array['ser exitoso','triunfar','ganar'],'To succeed [EHK-see-toh]',11),
    (v_lesson_id,'multiple_choice','How do you say "to fail"?','fracasar',array['fallar también','no tener éxito','perder'],'To fail [frah-kah-SAHR]',12),
    (v_lesson_id,'multiple_choice','How do you say "business plan"?','el plan de negocio',array['el plan empresarial','el plan de empresa','el plano'],'Business plan',13),
    (v_lesson_id,'multiple_choice','How do you say "innovative product"?','producto innovador',array['producto nuevo','producto innovado','producto innovative'],'Innovative product [een-noh-bah-DOHR]',14),
    (v_lesson_id,'multiple_choice','Translate "Si tuviera más capital, expandiría el negocio."','If I had more capital, I would expand the business',array['I will expand the business','Im expanding the business','I expanded the business'],'If I had more capital, I would expand the business (past subj + cond.)',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','quiero lanzar mi propia empresa',array['quiero crear mi empresa','voy a lanzar mi empresa','quiero comprar empresa'],'I want to launch my own business',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','buscamos inversores',array['buscamos clientes','tenemos inversores','buscaremos inversores'],'We are looking for investors',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','la empresa quebró',array['la empresa cerró','la empresa fracasó también','la empresa tuvo éxito'],'The company went bankrupt',18),
    (v_lesson_id,'speaking','Say "I want to launch my own startup" in Spanish.','Quiero lanzar mi propia startup',array[]::text[],'Quiero lanzar mi propia startup',19),
    (v_lesson_id,'speaking','Say "We need to take more risks" in Spanish.','Tenemos que asumir más riesgos',array[]::text[],'Tenemos que asumir más riesgos',20),
    (v_lesson_id,'fill_blank','Complete: "Quiero ___ mi empresa." (launch)','lanzar',array['comprar','vender','cerrar'],'to launch',21),
    (v_lesson_id,'fill_blank','Complete: "Si ___ más dinero..." (I had)','tuviera',array['tengo','tuve','tenía'],'I had (past subj.)',22);

  -- Lesson 4: business presentation (speaking)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Business — Lesson 4', 'Give a pitch or presentation.', 'speaking', 4, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "Good morning, everyone"?','Buenos días a todos',array['Hola a todos','Buen día todos','Saludos a todos'],'Good morning, everyone',1),
    (v_lesson_id,'multiple_choice','How do you say "Thank you for your attention"?','Gracias por su atención',array['Gracias por escuchar','Gracias por venir','Muchas gracias atención'],'Thank you for your attention',2),
    (v_lesson_id,'multiple_choice','How do you say "Today I would like to talk about..."?','Hoy me gustaría hablar de...',array['Hoy quiero hablar de','Hoy hablo de','Hoy voy a hablar de también'],'Today I would like to talk about...',3),
    (v_lesson_id,'multiple_choice','How do you say "in summary"?','en resumen',array['para resumir también','en sumario','breve'],'In summary [reh-SOO-mehn]',4),
    (v_lesson_id,'multiple_choice','How do you say "Are there any questions?"','¿Alguna pregunta?',array['¿Hay preguntas también?','¿Preguntas?','¿Cuál pregunta?'],'Any questions? [ahl-GOO-nah]',5),
    (v_lesson_id,'multiple_choice','How do you say "Let me explain..."?','Permítame explicar...',array['Déjame explicar también','Yo explicar','Para explicar'],'Let me explain... [pehr-MEE-tah-meh]',6),
    (v_lesson_id,'multiple_choice','How do you say "according to our data"?','según nuestros datos',array['en nuestros datos','con nuestros datos','de nuestros datos'],'According to our data',7),
    (v_lesson_id,'multiple_choice','How do you say "the results show that..."?','los resultados muestran que...',array['los resultados dicen','los resultados son','los resultados enseñan'],'The results show that...',8),
    (v_lesson_id,'multiple_choice','How do you say "let me give you an example"?','le pongo un ejemplo',array['déjame un ejemplo','dar un ejemplo','le doy ejemplo'],'Let me give you an example',9),
    (v_lesson_id,'multiple_choice','How do you say "to highlight / emphasize"?','destacar',array['enfatizar también','subrayar','resaltar'],'To highlight [dehs-tah-KAHR]',10),
    (v_lesson_id,'multiple_choice','How do you say "the bottom line is..."?','en definitiva',array['al final','en conclusión también','para acabar'],'The bottom line / definitively',11),
    (v_lesson_id,'multiple_choice','How do you say "competitive advantage"?','la ventaja competitiva',array['ventaja de competir','la ventaja','la competidor'],'Competitive advantage [behn-TAH-hah]',12),
    (v_lesson_id,'multiple_choice','How do you say "ROI (return on investment)"?','el retorno de la inversión',array['el ROI','el regreso','el dinero'],'ROI [reh-TOHR-noh]',13),
    (v_lesson_id,'multiple_choice','How do you say "to scale (a business)"?','escalar',array['crecer','aumentar','escalonar'],'To scale [ehs-kah-LAHR]',14),
    (v_lesson_id,'multiple_choice','Translate "Si me lo permite, le explico la estrategia."','If you allow me, I will explain the strategy',array['I will explain the strategy','Allow me to be explained','You explain the strategy'],'If you allow me, I will explain the strategy',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','buenos días a todos',array['hola a todos','buenas tardes a todos','buen día a todos'],'Good morning, everyone',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','según nuestros datos',array['en nuestros datos','con nuestros datos','para nuestros datos'],'According to our data',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','gracias por su atención',array['gracias por venir','gracias por escuchar','muchas gracias atención'],'Thank you for your attention',18),
    (v_lesson_id,'speaking','Say "Today I would like to talk about our strategy" in Spanish.','Hoy me gustaría hablar de nuestra estrategia',array[]::text[],'Hoy me gustaría hablar de nuestra estrategia',19),
    (v_lesson_id,'speaking','Say "Thank you for your attention" in Spanish.','Gracias por su atención',array[]::text[],'Gracias por su atención',20),
    (v_lesson_id,'fill_blank','Complete: "Gracias por su ___" (attention)','atención',array['atender','venir','escuchar'],'attention',21),
    (v_lesson_id,'fill_blank','Complete: "En ___, nuestras ventas crecieron." (summary)','resumen',array['final','definitiva','total'],'summary',22);

  -- =================== B2.6 SCIENCE ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Science', 'Discuss biology, physics, medicine and discoveries in Spanish.', 'B2', 6)
  returning id into v_course_id;

  -- Lesson 1: scientific vocab
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Science — Lesson 1', 'Disciplines and the scientific method.', 'vocabulary', 1, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "science"?','la ciencia',array['la conocimiento','el conocer','el saber'],'Science [SYEHN-syah]',1),
    (v_lesson_id,'multiple_choice','How do you say "scientist"?','el científico',array['el sabio','el investigador también','el profesor'],'Scientist [syehn-TEE-fee-koh]',2),
    (v_lesson_id,'multiple_choice','How do you say "experiment"?','el experimento',array['la prueba','el test','el ensayo'],'Experiment [ehks-peh-ree-MEHN-toh]',3),
    (v_lesson_id,'multiple_choice','How do you say "hypothesis"?','la hipótesis',array['la teoría','la idea','la suposición'],'Hypothesis [ee-POH-teh-sees]',4),
    (v_lesson_id,'multiple_choice','How do you say "theory"?','la teoría',array['la hipótesis','el concepto','la idea'],'Theory [teh-oh-REE-ah]',5),
    (v_lesson_id,'multiple_choice','How do you say "research"?','la investigación',array['el estudio también','el experimento','el research'],'Research [een-behs-tee-gah-SYOHN]',6),
    (v_lesson_id,'multiple_choice','How do you say "discovery"?','el descubrimiento',array['la invención','el hallazgo también','el encuentro'],'Discovery [dehs-koo-bree-MYEHN-toh]',7),
    (v_lesson_id,'multiple_choice','How do you say "biology"?','la biología',array['la biología celular','el biology','la naturaleza'],'Biology [byoh-loh-HEE-ah]',8),
    (v_lesson_id,'multiple_choice','How do you say "chemistry"?','la química',array['la chemistry','el químico','las sustancias'],'Chemistry [KEE-mee-kah]',9),
    (v_lesson_id,'multiple_choice','How do you say "physics"?','la física',array['lo físico','el cuerpo','la naturaleza'],'Physics [FEE-see-kah]',10),
    (v_lesson_id,'multiple_choice','How do you say "medicine"?','la medicina',array['la salud','la doctor','el remedio'],'Medicine [meh-dee-SEE-nah]',11),
    (v_lesson_id,'multiple_choice','How do you say "vaccine"?','la vacuna',array['la inyección','el remedio','la cura'],'Vaccine [bah-KOO-nah]',12),
    (v_lesson_id,'multiple_choice','How do you say "disease / illness"?','la enfermedad',array['el síntoma','el malestar','la dolencia'],'Disease [ehn-fehr-meh-DAHD]',13),
    (v_lesson_id,'multiple_choice','How do you say "cell"?','la célula',array['el átomo','la molécula','el organismo'],'Cell [SEH-loo-lah]',14),
    (v_lesson_id,'multiple_choice','How do you say "organism"?','el organismo',array['el ser','el cuerpo','la criatura'],'Organism [ohr-gah-NEES-moh]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','la teoría de la evolución',array['la teoría de la relatividad','la idea de la evolución','la evolución teórica'],'The theory of evolution',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','la vacuna fue descubierta',array['la vacuna se descubrió','descubrieron la vacuna','la vacuna es nueva'],'The vaccine was discovered',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','los científicos investigan',array['los científicos descubrieron','los investigadores están','la ciencia investiga'],'Scientists are researching',18),
    (v_lesson_id,'speaking','Say "Scientists are looking for a cure" in Spanish.','Los científicos buscan una cura',array[]::text[],'Los científicos buscan una cura',19),
    (v_lesson_id,'speaking','Say "I love biology" in Spanish.','Me encanta la biología',array[]::text[],'Me encanta la biología',20),
    (v_lesson_id,'fill_blank','Complete: "La ___ de la evolución." (theory)','teoría',array['hipótesis','idea','concepto'],'theory',21),
    (v_lesson_id,'fill_blank','Complete: "Estudio ___" (medicine)','medicina',array['ciencia','química','física'],'medicine',22);

  -- Lesson 2: research process + verbs
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Science — Lesson 2', 'How research works: verbs and steps.', 'phrases', 2, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "to research"?','investigar',array['estudiar','examinar','investigarse'],'To research [een-behs-tee-GAHR]',1),
    (v_lesson_id,'multiple_choice','How do you say "to discover"?','descubrir',array['encontrar','hallar también','revelar'],'To discover [dehs-koo-BREER]',2),
    (v_lesson_id,'multiple_choice','How do you say "to prove / demonstrate"?','demostrar',array['probar también','mostrar','enseñar'],'To prove [deh-mohs-TRAHR]',3),
    (v_lesson_id,'multiple_choice','How do you say "to refute"?','refutar',array['negar','desmentir también','rechazar'],'To refute [reh-foo-TAHR]',4),
    (v_lesson_id,'multiple_choice','How do you say "to publish (a paper)"?','publicar',array['imprimir','editar','sacar'],'To publish [poo-blee-KAHR]',5),
    (v_lesson_id,'multiple_choice','How do you say "scientific journal"?','la revista científica',array['el periódico de ciencia','el journal','la publicación científica'],'Scientific journal [reh-BEES-tah]',6),
    (v_lesson_id,'multiple_choice','How do you say "peer review"?','la revisión por pares',array['la revisión de pares','la revisión académica','la evaluación'],'Peer review [reh-bee-SYOHN]',7),
    (v_lesson_id,'multiple_choice','How do you say "data analysis"?','el análisis de datos',array['el análisis datos','el estudio de datos','el data análisis'],'Data analysis [ah-NAH-lee-sees]',8),
    (v_lesson_id,'multiple_choice','How do you say "result"?','el resultado',array['la consecuencia','el final','el resulta'],'Result [reh-sool-TAH-doh]',9),
    (v_lesson_id,'multiple_choice','How do you say "to confirm a hypothesis"?','confirmar una hipótesis',array['probar una hipótesis','demostrar una hipótesis también','aprobar una hipótesis'],'To confirm a hypothesis',10),
    (v_lesson_id,'multiple_choice','How do you say "evidence"?','la evidencia',array['la prueba también','el dato','la información'],'Evidence [eh-bee-DEHN-syah]',11),
    (v_lesson_id,'multiple_choice','How do you say "to fund (research)"?','financiar',array['pagar también','dar dinero','soportar'],'To fund [fee-nahn-SYAHR]',12),
    (v_lesson_id,'multiple_choice','How do you say "laboratory"?','el laboratorio',array['el lab','la sala','el centro'],'Laboratory [lah-boh-rah-TOH-ryoh]',13),
    (v_lesson_id,'multiple_choice','How do you say "to observe"?','observar',array['mirar','ver','notar'],'To observe [ohb-sehr-BAHR]',14),
    (v_lesson_id,'multiple_choice','Translate "Los científicos han demostrado que el cambio climático es real."','Scientists have proven that climate change is real',array['Scientists believe climate change','Scientists need climate change','Climate change exists'],'Scientists have proven that climate change is real',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','han descubierto un nuevo planeta',array['descubrieron un nuevo planeta','han descubierto un nuevo planeta también','descubren un nuevo planeta'],'They have discovered a new planet',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','publicaron los resultados',array['publican los resultados','publicarán los resultados','publicaban los resultados'],'They published the results',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','la hipótesis se confirmó',array['la hipótesis se rechazó','la hipótesis se confirma','la teoría se confirmó'],'The hypothesis was confirmed',18),
    (v_lesson_id,'speaking','Say "We need to verify these results" in Spanish.','Necesitamos verificar estos resultados',array[]::text[],'Necesitamos verificar estos resultados',19),
    (v_lesson_id,'speaking','Say "The hypothesis was confirmed" in Spanish.','La hipótesis fue confirmada',array[]::text[],'La hipótesis fue confirmada',20),
    (v_lesson_id,'fill_blank','Complete: "La hipótesis fue ___" (confirmed)','confirmada',array['confirma','confirmar','confirmó'],'confirmed (f.)',21),
    (v_lesson_id,'fill_blank','Complete: "Trabajo en un ___" (laboratory)','laboratorio',array['hospital','oficina','salón'],'laboratory',22);

  -- Lesson 3: physics & the universe (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Science — Lesson 3', 'Universe, gravity and energy.', 'listening', 3, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "universe"?','el universo',array['el cosmos también','el espacio','el mundo'],'Universe [oo-nee-BEHR-soh]',1),
    (v_lesson_id,'multiple_choice','How do you say "galaxy"?','la galaxia',array['las estrellas','el sistema','el galaxy'],'Galaxy [gah-LAHK-syah]',2),
    (v_lesson_id,'multiple_choice','How do you say "star"?','la estrella',array['el astro','el sol','el cielo'],'Star [ehs-TREH-yah]',3),
    (v_lesson_id,'multiple_choice','How do you say "planet"?','el planeta',array['la tierra','el mundo','el planet'],'Planet [plah-NEH-tah]',4),
    (v_lesson_id,'multiple_choice','How do you say "gravity"?','la gravedad',array['la fuerza','la pesantez','la gravity'],'Gravity [grah-beh-DAHD]',5),
    (v_lesson_id,'multiple_choice','How do you say "energy"?','la energía',array['el poder','la fuerza','el vigor'],'Energy [eh-nehr-HEE-ah]',6),
    (v_lesson_id,'multiple_choice','How do you say "matter (physics)"?','la materia',array['la sustancia','el material','la cuestión'],'Matter [mah-TEH-ryah]',7),
    (v_lesson_id,'multiple_choice','How do you say "atom"?','el átomo',array['la molécula','la partícula','la célula'],'Atom [AH-toh-moh]',8),
    (v_lesson_id,'multiple_choice','How do you say "particle"?','la partícula',array['el átomo','la pieza','el bit'],'Particle [pahr-TEE-koo-lah]',9),
    (v_lesson_id,'multiple_choice','How do you say "Big Bang"?','el Big Bang',array['la gran explosión','la explosión grande','el origen'],'Big Bang',10),
    (v_lesson_id,'multiple_choice','How do you say "speed of light"?','la velocidad de la luz',array['la luz veloz','la velocidad luz','la fast light'],'Speed of light [beh-loh-see-DAHD deh lah LOOS]',11),
    (v_lesson_id,'multiple_choice','How do you say "black hole"?','el agujero negro',array['el hoyo negro también','el espacio negro','el ojo negro'],'Black hole [ah-goo-HEH-roh]',12),
    (v_lesson_id,'multiple_choice','How do you say "relativity"?','la relatividad',array['lo relativo','la relación','el relativismo'],'Relativity [reh-lah-tee-bee-DAHD]',13),
    (v_lesson_id,'multiple_choice','How do you say "renewable energy"?','la energía renovable',array['la energía limpia también','la energía sostenible','la energy renewable'],'Renewable energy',14),
    (v_lesson_id,'multiple_choice','Translate "La teoría de la relatividad de Einstein cambió la física."','Einsteins theory of relativity changed physics',array['Einstein changed physics','Relativity is Einsteins','Physics changed relativity'],'Einsteins theory of relativity changed physics',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','el universo es enorme',array['el universo es grande','el cosmos es enorme','el espacio es enorme'],'The universe is enormous',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','la velocidad de la luz',array['la luz es rápida','la velocidad luz','la fast light'],'The speed of light',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','los agujeros negros son misteriosos',array['los agujeros son misteriosos','el agujero negro es misterioso','los agujeros negros son grandes'],'Black holes are mysterious',18),
    (v_lesson_id,'speaking','Say "The universe is full of mysteries" in Spanish.','El universo está lleno de misterios',array[]::text[],'El universo está lleno de misterios',19),
    (v_lesson_id,'speaking','Say "Renewable energy is the future" in Spanish.','La energía renovable es el futuro',array[]::text[],'La energía renovable es el futuro',20),
    (v_lesson_id,'fill_blank','Complete: "La velocidad de la ___" (light)','luz',array['estrella','sol','planeta'],'light',21),
    (v_lesson_id,'fill_blank','Complete: "Un agujero ___" (black)','negro',array['oscuro','grande','profundo'],'black',22);

  -- Lesson 4: science discussion (speaking)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Science — Lesson 4', 'Discuss scientific topics out loud.', 'speaking', 4, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "Im fascinated by science"?','Me fascina la ciencia',array['Soy fascinado','Tengo ciencia fascinante','Me gusta la ciencia'],'Im fascinated by science [fah-SEE-nah]',1),
    (v_lesson_id,'multiple_choice','How do you say "controversial topic"?','tema controvertido',array['tema discutido','tema polémico también','tema problemático'],'Controversial topic [kohn-troh-behr-TEE-doh]',2),
    (v_lesson_id,'multiple_choice','How do you say "ethical question"?','cuestión ética',array['pregunta ética','cuestión ética también','dilema ético'],'Ethical question [EH-tee-kah]',3),
    (v_lesson_id,'multiple_choice','How do you say "to revolutionize"?','revolucionar',array['cambiar','transformar también','revolutionize'],'To revolutionize [reh-boh-loo-syoh-NAHR]',4),
    (v_lesson_id,'multiple_choice','How do you say "stem cells"?','las células madre',array['las cells madre','las células stem','las células nuevas'],'Stem cells [SEH-loo-lahs MAH-dreh]',5),
    (v_lesson_id,'multiple_choice','How do you say "genetic engineering"?','la ingeniería genética',array['ingeniería de genes','la genetic','la genética'],'Genetic engineering [een-heh-nyeh-REE-ah]',6),
    (v_lesson_id,'multiple_choice','How do you say "cloning"?','la clonación',array['el clonar','la clonación humana','la copia'],'Cloning [kloh-nah-SYOHN]',7),
    (v_lesson_id,'multiple_choice','How do you say "to question (ethics)"?','cuestionar',array['preguntar','dudar','interrogar'],'To question [kwehs-tyoh-NAHR]',8),
    (v_lesson_id,'multiple_choice','How do you say "Im skeptical"?','Soy escéptico',array['Estoy escéptico','Tengo escéptico','Yo escéptico'],'Im skeptical [ehs-SEHP-tee-koh]',9),
    (v_lesson_id,'multiple_choice','How do you say "scientific consensus"?','el consenso científico',array['acuerdo científico','la opinión científica','la verdad científica'],'Scientific consensus [kohn-SEHN-soh]',10),
    (v_lesson_id,'multiple_choice','How do you say "to revolutionize medicine"?','revolucionar la medicina',array['cambiar la medicina','transformar la medicina','medicina nueva'],'To revolutionize medicine',11),
    (v_lesson_id,'multiple_choice','How do you say "limit of science"?','los límites de la ciencia',array['el límite de ciencia','los límites científicos también','la ciencia limitada'],'The limits of science',12),
    (v_lesson_id,'multiple_choice','How do you say "to advance / progress"?','avanzar',array['progresar también','adelantar','seguir'],'To advance [ah-bahn-SAHR]',13),
    (v_lesson_id,'multiple_choice','How do you say "without research, there is no progress"?','sin investigación no hay progreso',array['no progreso sin research','sin ciencia no hay nada','no hay sin investigar'],'Without research, there is no progress',14),
    (v_lesson_id,'multiple_choice','Translate "Aunque la ciencia avanza rápidamente, todavía hay misterios por resolver."','Although science advances rapidly, there are still mysteries to solve',array['Science cannot solve mysteries','Mysteries advance science','Science is slow'],'Although science advances rapidly, there are still mysteries to solve',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','me fascina la ciencia',array['me gusta la ciencia','soy fascinado por la ciencia','la ciencia me gusta'],'Im fascinated by science',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','soy escéptico al respecto',array['soy escéptico','estoy escéptico al respecto','tengo dudas'],'Im skeptical about it',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','la ciencia avanza rápidamente',array['la ciencia avanza','la ciencia es rápida','los avances científicos'],'Science advances rapidly',18),
    (v_lesson_id,'speaking','Say "Im fascinated by science" in Spanish.','Me fascina la ciencia',array[]::text[],'Me fascina la ciencia',19),
    (v_lesson_id,'speaking','Say "Science cannot answer everything" in Spanish.','La ciencia no puede responderlo todo',array[]::text[],'La ciencia no puede responderlo todo',20),
    (v_lesson_id,'fill_blank','Complete: "Me ___ la ciencia." (Im fascinated by)','fascina',array['gusta','interesa','encanta'],'fascinates me',21),
    (v_lesson_id,'fill_blank','Complete: "Soy ___ al respecto." (skeptical)','escéptico',array['cierto','seguro','optimista'],'skeptical',22);

  -- =================== B2.7 ARTS ===================
  insert into public.courses (language_id, title, description, cefr_level, order_index)
  values (v_lang_id, 'Arts', 'Painting, sculpture and artistic movements in Spanish.', 'B2', 7)
  returning id into v_course_id;

  -- Lesson 1: art vocab
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Arts — Lesson 1', 'Painting, sculpture and galleries.', 'vocabulary', 1, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "art"?','el arte',array['las artes','el artístico','la artes'],'Art [AR-teh]',1),
    (v_lesson_id,'multiple_choice','How do you say "painting (an artwork)"?','el cuadro',array['la pintura también','la imagen','el dibujo'],'Painting [KWAH-droh]',2),
    (v_lesson_id,'multiple_choice','How do you say "painting (the activity)"?','la pintura',array['el cuadro','el pintar','la imagen'],'Painting (activity) [peen-TOO-rah]',3),
    (v_lesson_id,'multiple_choice','How do you say "sculpture"?','la escultura',array['la estatua','el monumento','el bronce'],'Sculpture [ehs-kool-TOO-rah]',4),
    (v_lesson_id,'multiple_choice','How do you say "museum"?','el museo',array['la galería','la exposición','el centro de arte'],'Museum [moo-SEH-oh]',5),
    (v_lesson_id,'multiple_choice','How do you say "gallery"?','la galería',array['el museo','la sala','la exhibición'],'Gallery [gah-leh-REE-ah]',6),
    (v_lesson_id,'multiple_choice','How do you say "exhibition"?','la exposición',array['la muestra también','la presentación','la exhibición también'],'Exhibition [ehks-poh-see-SYOHN]',7),
    (v_lesson_id,'multiple_choice','How do you say "artwork / piece"?','la obra',array['la pieza','el trabajo','la creación'],'Artwork [OH-brah]',8),
    (v_lesson_id,'multiple_choice','How do you say "artist"?','el artista',array['el creador','el pintor','el escultor'],'Artist [ahr-TEES-tah]',9),
    (v_lesson_id,'multiple_choice','How do you say "style"?','el estilo',array['la manera','el modo','la corriente'],'Style [ehs-TEE-loh]',10),
    (v_lesson_id,'multiple_choice','How do you say "technique"?','la técnica',array['el método','la forma','el truco'],'Technique [TEHK-nee-kah]',11),
    (v_lesson_id,'multiple_choice','How do you say "oil painting (medium)"?','el óleo',array['el aceite','la pintura al óleo también','el oil'],'Oil painting [OH-leh-oh]',12),
    (v_lesson_id,'multiple_choice','How do you say "watercolor"?','la acuarela',array['el agua','la acrílica','el watercolor'],'Watercolor [ah-kwah-REH-lah]',13),
    (v_lesson_id,'multiple_choice','How do you say "abstract (art)"?','abstracto',array['concreto','representativo','figurativo'],'Abstract (m.) [ahbs-TRAHK-toh]',14),
    (v_lesson_id,'multiple_choice','How do you say "realistic"?','realista',array['real','figurativo también','clásico'],'Realistic [reh-ah-LEES-tah]',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','este cuadro es de picasso',array['esta obra es de picasso','este cuadro es de goya','este cuadro fue de picasso'],'This painting is by Picasso',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','vamos al museo',array['vamos a la galería','vamos al exhibition','iremos al museo'],'Lets go to the museum',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','prefiero el arte abstracto',array['prefiero el arte realista','me gusta el abstracto','me gusta arte'],'I prefer abstract art',18),
    (v_lesson_id,'speaking','Say "I love modern art" in Spanish.','Me encanta el arte moderno',array[]::text[],'Me encanta el arte moderno',19),
    (v_lesson_id,'speaking','Say "Lets visit the museum tomorrow" in Spanish.','Visitemos el museo mañana',array[]::text[],'Visitemos el museo mañana',20),
    (v_lesson_id,'fill_blank','Complete: "Es un ___ de Picasso." (painting)','cuadro',array['museo','arte','escultura'],'painting',21),
    (v_lesson_id,'fill_blank','Complete: "Prefiero el arte ___" (abstract)','abstracto',array['real','clásico','antiguo'],'abstract',22);

  -- Lesson 2: art movements
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Arts — Lesson 2', 'Art movements and history.', 'phrases', 2, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "Renaissance"?','el Renacimiento',array['el Resurgimiento','la Renaissance','la nueva era'],'Renaissance [reh-nah-see-MYEHN-toh]',1),
    (v_lesson_id,'multiple_choice','How do you say "Baroque"?','el Barroco',array['el Barocco','el Brillante','el Decorado'],'Baroque [bah-RROH-koh]',2),
    (v_lesson_id,'multiple_choice','How do you say "Impressionism"?','el Impresionismo',array['la Impresión','el Impresionista','el impresionant'],'Impressionism [eem-preh-syoh-NEES-moh]',3),
    (v_lesson_id,'multiple_choice','How do you say "Cubism"?','el Cubismo',array['el Cuadro','el Cubist','los Cubos'],'Cubism [koo-BEES-moh]',4),
    (v_lesson_id,'multiple_choice','How do you say "Surrealism"?','el Surrealismo',array['el Surrealismo','el Sueño','el Surreal'],'Surrealism [soo-rreh-ah-LEES-moh]',5),
    (v_lesson_id,'multiple_choice','How do you say "avant-garde"?','la vanguardia',array['la avant-garde','la nueva','la innovación'],'Avant-garde [bahn-GWAR-dyah]',6),
    (v_lesson_id,'multiple_choice','Who painted "Guernica"?','Pablo Picasso',array['Salvador Dalí','Francisco de Goya','Diego Velázquez'],'Picasso painted Guernica',7),
    (v_lesson_id,'multiple_choice','Who painted "The Persistence of Memory"?','Salvador Dalí',array['Pablo Picasso','Joan Miró','Frida Kahlo'],'Dalí — Persistence of Memory',8),
    (v_lesson_id,'multiple_choice','Who was Frida Kahlo?','una pintora mexicana',array['una pintora española','una escultora','una arquitecta'],'Mexican painter [pin-TOH-rah]',9),
    (v_lesson_id,'multiple_choice','Who painted "Las Meninas"?','Diego Velázquez',array['Pablo Picasso','Goya','El Greco'],'Velázquez — Las Meninas',10),
    (v_lesson_id,'multiple_choice','How do you say "self-portrait"?','el autorretrato',array['el autoretrato','el retrato propio','el self retrato'],'Self-portrait [ow-toh-rreh-TRAH-toh]',11),
    (v_lesson_id,'multiple_choice','How do you say "portrait"?','el retrato',array['la imagen','la foto','la pintura'],'Portrait [reh-TRAH-toh]',12),
    (v_lesson_id,'multiple_choice','How do you say "landscape (painting)"?','el paisaje',array['el panorama','la vista','el paisajismo'],'Landscape [pay-SAH-heh]',13),
    (v_lesson_id,'multiple_choice','How do you say "still life"?','la naturaleza muerta',array['la cosa quieta','el cuadro de cosas','el bodegón también'],'Still life',14),
    (v_lesson_id,'multiple_choice','Translate "El Guernica de Picasso simboliza el horror de la guerra."','Picassos Guernica symbolizes the horror of war',array['Picasso painted war','Guernica is a war','War symbolizes Picasso'],'Picassos Guernica symbolizes the horror of war',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','el cubismo fue revolucionario',array['el cubismo es revolucionario','el cubismo fue importante','el cubismo era nuevo'],'Cubism was revolutionary',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','dalí pintó sueños',array['picasso pintó sueños','dalí pintaba sueños','dalí pinta sueños'],'Dalí painted dreams',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','el renacimiento cambió el arte',array['el barroco cambió el arte','el renacimiento es arte','el renacimiento cambia el arte'],'The Renaissance changed art',18),
    (v_lesson_id,'speaking','Say "Picasso is one of my favorite artists" in Spanish.','Picasso es uno de mis artistas favoritos',array[]::text[],'Picasso es uno de mis artistas favoritos',19),
    (v_lesson_id,'speaking','Say "The Renaissance was a fascinating period" in Spanish.','El Renacimiento fue un período fascinante',array[]::text[],'El Renacimiento fue un período fascinante',20),
    (v_lesson_id,'fill_blank','Complete: "Pablo Picasso fundó el ___" (Cubism)','Cubismo',array['Surrealismo','Realismo','Impresionismo'],'Cubism',21),
    (v_lesson_id,'fill_blank','Complete: "Un ___ de Frida Kahlo." (self-portrait)','autorretrato',array['retrato','paisaje','cuadro'],'self-portrait',22);

  -- Lesson 3: visiting a museum (listening)
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Arts — Lesson 3', 'Visit a museum and discuss the art.', 'listening', 3, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "admission ticket"?','la entrada',array['el ticket','el boleto (LatAm)','el billete'],'Admission ticket [ehn-TRAH-dah]',1),
    (v_lesson_id,'multiple_choice','How do you say "guided tour"?','la visita guiada',array['el tour guiado','la guía','el recorrido'],'Guided tour [GEE-ah-dah]',2),
    (v_lesson_id,'multiple_choice','How do you say "audio guide"?','la audioguía',array['el audio','la guía de audio','el audio guide'],'Audio guide [ow-dyoh-GEE-ah]',3),
    (v_lesson_id,'multiple_choice','How do you say "to be impressed"?','quedar impresionado',array['estar impresionado también','ser impresionado','tener impresionado'],'To be impressed [eem-preh-syoh-NAH-doh]',4),
    (v_lesson_id,'multiple_choice','How do you say "to take ones breath away"?','dejar sin aliento',array['quitar aliento','impresionar mucho','dejarse'],'To take breath away [ah-LYEHN-toh]',5),
    (v_lesson_id,'multiple_choice','How do you say "to wander around"?','pasear',array['caminar','andar','pasear por'],'To wander around [pah-seh-AHR]',6),
    (v_lesson_id,'multiple_choice','How do you say "this piece moves me"?','esta obra me conmueve',array['esta obra me toca','esta obra me hace sentir','esta obra mueve'],'This piece moves me [kohn-MWEH-beh]',7),
    (v_lesson_id,'multiple_choice','How do you say "it leaves me cold"?','me deja frío',array['me deja indiferente también','no me toca','no me importa'],'It leaves me cold (idiom)',8),
    (v_lesson_id,'multiple_choice','How do you say "Whats the meaning of this?"','¿Cuál es el significado de esto?',array['¿Qué significa esto?','¿Cuál es el sentido?','¿Qué es esto?'],'Whats the meaning of this?',9),
    (v_lesson_id,'multiple_choice','How do you say "to capture (a moment)"?','capturar',array['atrapar','tomar','fijar'],'To capture [kahp-too-RAHR]',10),
    (v_lesson_id,'multiple_choice','How do you say "controversial work"?','obra controvertida',array['obra polémica también','obra discutida','obra problemática'],'Controversial work',11),
    (v_lesson_id,'multiple_choice','How do you say "to be inspired by..."?','inspirarse en...',array['estar inspirado por','inspirarse de','tomar inspiración'],'To be inspired by... [eens-pee-RAHR-seh]',12),
    (v_lesson_id,'multiple_choice','How do you say "to interpret art"?','interpretar el arte',array['traducir el arte','entender el arte','leer el arte'],'To interpret art',13),
    (v_lesson_id,'multiple_choice','How do you say "the colors are vibrant"?','los colores son vibrantes',array['los colores son fuertes','los colores son vivos también','los colores son brillantes'],'The colors are vibrant [bee-BRAHN-tehs]',14),
    (v_lesson_id,'multiple_choice','Translate "Esta obra me dejó sin palabras."','This piece left me speechless',array['I left without words','This piece is mine','I forgot the piece'],'This piece left me speechless',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','esta obra me conmueve',array['esta obra me gusta','esta pieza me conmueve','la obra me conmueve'],'This piece moves me',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','los colores son vibrantes',array['los colores son vivos','los colores son fuertes','los colores son lindos'],'The colors are vibrant',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','tengo entradas para el museo',array['compré entradas para el museo','quiero entradas para el museo','tendré entradas museo'],'I have tickets for the museum',18),
    (v_lesson_id,'speaking','Say "I would like to take the guided tour" in Spanish.','Me gustaría hacer la visita guiada',array[]::text[],'Me gustaría hacer la visita guiada',19),
    (v_lesson_id,'speaking','Say "This piece moves me deeply" in Spanish.','Esta obra me conmueve profundamente',array[]::text[],'Esta obra me conmueve profundamente',20),
    (v_lesson_id,'fill_blank','Complete: "Compré una ___ para el museo." (ticket)','entrada',array['boleto','ticket','billete'],'ticket (Spain)',21),
    (v_lesson_id,'fill_blank','Complete: "Esta obra me ___ profundamente." (moves me)','conmueve',array['toca','mueve','impresiona'],'moves me',22);

  -- Lesson 4: speaking about art
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Arts — Lesson 4', 'Share your taste in art out loud.', 'speaking', 4, 25)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
    (v_lesson_id,'multiple_choice','How do you say "Im an art lover"?','Soy aficionado al arte',array['Soy fanático del arte','Tengo amor al arte','Yo arte amor'],'Im an art lover [ah-fee-syoh-NAH-doh]',1),
    (v_lesson_id,'multiple_choice','How do you say "I dont understand modern art"?','No entiendo el arte moderno',array['Yo no entender','No comprendo arte moderno también','No me gusta moderno'],'I dont understand modern art',2),
    (v_lesson_id,'multiple_choice','How do you say "Art is subjective"?','El arte es subjetivo',array['Arte subjetivo','Es subjetivo arte','El arte es relativo'],'Art is subjective [soob-heh-TEE-boh]',3),
    (v_lesson_id,'multiple_choice','How do you say "in the eye of the beholder"?','para gustos los colores',array['en el ojo del que mira','según mire','depende del ojo'],'In the eye of the beholder (idiom)',4),
    (v_lesson_id,'multiple_choice','How do you say "to develop a taste for..."?','aficionarse a...',array['gustarse','tener gusto','desarrollar gusto'],'To develop a taste for... [ah-fee-syoh-NAHR-seh]',5),
    (v_lesson_id,'multiple_choice','How do you say "I disagree with..."?','No estoy de acuerdo con...',array['Yo no acuerdo','Soy contrario a','Estoy contra'],'I disagree with...',6),
    (v_lesson_id,'multiple_choice','How do you say "creativity"?','la creatividad',array['lo creativo','el creator','la creativa'],'Creativity [kreh-ah-tee-bee-DAHD]',7),
    (v_lesson_id,'multiple_choice','How do you say "to express emotions"?','expresar emociones',array['mostrar emoción','dar emociones','tener emociones'],'To express emotions',8),
    (v_lesson_id,'multiple_choice','How do you say "Im an amateur painter"?','Soy pintor aficionado',array['Soy amateur pintor','Yo pintar amateur','Pinto como amateur'],'Im an amateur painter',9),
    (v_lesson_id,'multiple_choice','How do you say "I paint in my free time"?','Pinto en mi tiempo libre',array['Yo pinto tiempo','Hago pintura libre','Pinto cuando puedo'],'I paint in my free time',10),
    (v_lesson_id,'multiple_choice','How do you say "to commission a painting"?','encargar un cuadro',array['ordenar un cuadro','pedir un cuadro','mandar un cuadro'],'To commission a painting [ehn-kahr-GAHR]',11),
    (v_lesson_id,'multiple_choice','How do you say "art world"?','el mundo del arte',array['el arte mundial','el mundo artístico también','el mundo arte'],'Art world',12),
    (v_lesson_id,'multiple_choice','How do you say "to be famous (artist)"?','ser famoso',array['ser conocido también','tener fama','estar famoso'],'To be famous [fah-MOH-soh]',13),
    (v_lesson_id,'multiple_choice','How do you say "to make money from art"?','vivir del arte',array['ganar con arte','hacer dinero arte','ganarse la vida con el arte también'],'To make a living from art',14),
    (v_lesson_id,'multiple_choice','Translate "Si tuviera más tiempo, pintaría más a menudo."','If I had more time, I would paint more often',array['I paint often','I will paint more','I painted often'],'If I had more time, I would paint more often (past subj + cond.)',15),
    (v_lesson_id,'listening','Listen and choose what you heard.','soy aficionado al arte',array['soy fanático del arte','me gusta el arte','tengo afición por el arte'],'Im an art lover',16),
    (v_lesson_id,'listening','Listen and choose what you heard.','el arte es subjetivo',array['el arte es relativo','el arte es bonito','el arte es subjetiva'],'Art is subjective',17),
    (v_lesson_id,'listening','Listen and choose what you heard.','pinto en mi tiempo libre',array['pintaba en mi tiempo libre','pintaré en mi tiempo libre','pinto cuando puedo'],'I paint in my free time',18),
    (v_lesson_id,'speaking','Say "Im fascinated by surrealism" in Spanish.','Me fascina el surrealismo',array[]::text[],'Me fascina el surrealismo',19),
    (v_lesson_id,'speaking','Say "Art expresses what words cannot" in Spanish.','El arte expresa lo que las palabras no pueden',array[]::text[],'El arte expresa lo que las palabras no pueden',20),
    (v_lesson_id,'fill_blank','Complete: "Soy aficionado ___ arte." (to)','al',array['del','el','con'],'to the',21),
    (v_lesson_id,'fill_blank','Complete: "El arte es ___" (subjective)','subjetivo',array['objetivo','relativo','bonito'],'subjective',22);

end $$;

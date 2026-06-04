-- 025_spanish_a2_listening_speaking.sql
-- Mirrors 018 (A1). Adds 2 listening + 2 speaking exercises (order_index
-- 6..9) to lessons 1, 2, 3, 6, 7 of every A2 section. Lessons 4 (Listening)
-- and 5 (Speaking) already focus on those skills.
-- 15 sections × 5 lessons × 4 added exercises = 300 new exercises.
-- Idempotent: deletes exercises at order_index >= 6 on those lessons first.

do $$
declare
  v_lang_id   bigint;
  v_course_id bigint;
  v_l1 bigint; v_l2 bigint; v_l3 bigint;
  v_l6 bigint; v_l7 bigint;
begin
  select id into v_lang_id from public.languages where code = 'spanish';

  -- ====== A2.1 DAILY ROUTINES ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Daily Routines';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','Me ducho cada mañana',array['I wake up every morning','I shower every morning','I get up every morning'],'I shower every morning',6),
    (v_l1,'listening','Listen and pick the English meaning.','Me acuesto a las once',array['I get up at eleven','I go to bed at eleven','I wake up at eleven'],'I go to bed at eleven',7),
    (v_l1,'speaking','Say this aloud: "Me levanto a las siete." [meh leh-BAHN-toh ah lahs SYEH-teh]','Me levanto a las siete',array[]::text[],'I get up at seven.',8),
    (v_l1,'speaking','Say this aloud: "Desayuno café." [deh-sah-YOO-noh kah-FEH]','Desayuno café',array[]::text[],'I have coffee for breakfast.',9),
    (v_l2,'listening','Listen and pick the English meaning.','Me visto rápido',array['I shower quickly','I get dressed quickly','I sleep quickly'],'I get dressed quickly',6),
    (v_l2,'listening','Listen and pick the English meaning.','Nos acostamos tarde',array['We get up late','We go to bed late','We have dinner late'],'We go to bed late',7),
    (v_l2,'speaking','Say this aloud: "Me lavo la cara." [meh LAH-boh lah KAH-rah]','Me lavo la cara',array[]::text[],'I wash my face.',8),
    (v_l2,'speaking','Say this aloud: "Se viste rápido." [seh BEES-teh RAH-pee-doh]','Se viste rápido',array[]::text[],'He gets dressed quickly.',9),
    (v_l3,'listening','Listen and pick the English meaning.','Normalmente me acuesto pronto',array['I rarely go to bed early','I usually go to bed early','I never sleep early'],'I usually go to bed early',6),
    (v_l3,'listening','Listen and pick the English meaning.','Por la tarde estudio',array['In the morning I study','In the afternoon I study','At night I study'],'In the afternoon I study',7),
    (v_l3,'speaking','Say this aloud: "Todos los días trabajo." [TOH-dohs lohs DEE-ahs trah-BAH-hoh]','Todos los días trabajo',array[]::text[],'Every day I work.',8),
    (v_l3,'speaking','Say this aloud: "Antes de salir desayuno." [AHN-tehs deh sah-LEER deh-sah-YOO-noh]','Antes de salir desayuno',array[]::text[],'Before going out I have breakfast.',9),
    (v_l6,'listening','Listen and pick the English meaning.','Primero me ducho',array['First I have breakfast','First I shower','First I sleep'],'First I shower',6),
    (v_l6,'listening','Listen and pick the English meaning.','El fin de semana descanso',array['On weekends I rest','On weekends I work','On weekends I run'],'On weekends I rest',7),
    (v_l6,'speaking','Say this aloud: "Mi rutina es simple." [mee rroo-TEE-nah ehs SEEM-pleh]','Mi rutina es simple',array[]::text[],'My routine is simple.',8),
    (v_l6,'speaking','Say this aloud: "Luego desayuno." [LWEH-goh deh-sah-YOO-noh]','Luego desayuno',array[]::text[],'Then I have breakfast.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Trabajo en casa cada día',array['I rest at home every day','I work at home every day','I cook at home every day'],'I work at home every day',6),
    (v_l7,'listening','Listen and pick the English meaning.','Después salgo a correr',array['Afterwards I go out to run','Afterwards I cook','Afterwards I sleep'],'Afterwards I go out to run',7),
    (v_l7,'speaking','Say this aloud: "Me acuesto temprano." [meh ah-KWEHS-toh tehm-PRAH-noh]','Me acuesto temprano',array[]::text[],'I go to bed early.',8),
    (v_l7,'speaking','Say this aloud: "Cada noche leo." [KAH-dah NOH-cheh LEH-oh]','Cada noche leo',array[]::text[],'Each night I read.',9);

  -- ====== A2.2 HEALTH & BODY ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Health & Body';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','Tengo fiebre',array['I have a cold','I have a fever','I have flu'],'I have a fever',6),
    (v_l1,'listening','Listen and pick the English meaning.','Necesito una pastilla',array['I want a pill','I take a pill','I need a pill'],'I need a pill',7),
    (v_l1,'speaking','Say this aloud: "Voy al médico." [BOY ahl MEH-dee-koh]','Voy al médico',array[]::text[],'I go to the doctor.',8),
    (v_l1,'speaking','Say this aloud: "Tomo una pastilla." [TOH-moh OO-nah pahs-TEE-yah]','Tomo una pastilla',array[]::text[],'I take a pill.',9),
    (v_l2,'listening','Listen and pick the English meaning.','Me duele la garganta',array['My head hurts','My throat hurts','My stomach hurts'],'My throat hurts',6),
    (v_l2,'listening','Listen and pick the English meaning.','Me duelen los pies',array['My feet hurt','My hands hurt','My eyes hurt'],'My feet hurt',7),
    (v_l2,'speaking','Say this aloud: "Me siento mal." [meh SYEHN-toh mahl]','Me siento mal',array[]::text[],'I feel bad.',8),
    (v_l2,'speaking','Say this aloud: "Me duele el estómago." [meh DWEH-leh ehl ehs-TOH-mah-goh]','Me duele el estómago',array[]::text[],'My stomach hurts.',9),
    (v_l3,'listening','Listen and pick the English meaning.','Estoy resfriado',array['I have a cold','I have a fever','I have a cough'],'I have a cold',6),
    (v_l3,'listening','Listen and pick the English meaning.','¿Tiene algo para el dolor?',array['Do you have something for the pain?','Where is the medicine?','How much is it?'],'Do you have something for the pain?',7),
    (v_l3,'speaking','Say this aloud: "Necesito un médico." [neh-seh-SEE-toh oon MEH-dee-koh]','Necesito un médico',array[]::text[],'I need a doctor.',8),
    (v_l3,'speaking','Say this aloud: "Cuídate." [KWEE-dah-teh]','Cuídate',array[]::text[],'Take care.',9),
    (v_l6,'listening','Listen and pick the English meaning.','El médico me receta un jarabe',array['The doctor gives me an injection','The doctor prescribes me a syrup','The doctor takes a sample'],'The doctor prescribes me a syrup',6),
    (v_l6,'listening','Listen and pick the English meaning.','Quiero mejorarme pronto',array['I want to rest','I want to get better soon','I want to leave soon'],'I want to get better soon',7),
    (v_l6,'speaking','Say this aloud: "Tengo consulta hoy." [TEHN-goh kohn-SOOL-tah oy]','Tengo consulta hoy',array[]::text[],'I have an appointment today.',8),
    (v_l6,'speaking','Say this aloud: "Tengo varios síntomas." [TEHN-goh BAH-ryohs SEEN-toh-mahs]','Tengo varios síntomas',array[]::text[],'I have several symptoms.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Hace dos días que estoy enfermo',array['I have been sick for two days','I am sick tomorrow','I was sick two weeks ago'],'I''ve been sick for two days',6),
    (v_l7,'listening','Listen and pick the English meaning.','Hoy me siento mejor',array['Today I feel worse','Today I feel better','Today I feel tired'],'Today I feel better',7),
    (v_l7,'speaking','Say this aloud: "Todavía me duele la cabeza." [toh-dah-BEE-ah meh DWEH-leh lah kah-BEH-sah]','Todavía me duele la cabeza',array[]::text[],'My head still hurts.',8),
    (v_l7,'speaking','Say this aloud: "Estoy un poco mareado." [ehs-TOY oon POH-koh mah-reh-AH-doh]','Estoy un poco mareado',array[]::text[],'I am a little dizzy.',9);

  -- ====== A2.3 HOBBIES ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Hobbies';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','Me gusta leer novelas',array['I write novels','I like to read novels','I sell novels'],'I like to read novels',6),
    (v_l1,'listening','Listen and pick the English meaning.','Toco la guitarra',array['I play the guitar','I sell the guitar','I buy the guitar'],'I play the guitar',7),
    (v_l1,'speaking','Say this aloud: "Cocino comida italiana." [koh-SEE-noh koh-MEE-dah ee-tah-LYAH-nah]','Cocino comida italiana',array[]::text[],'I cook Italian food.',8),
    (v_l1,'speaking','Say this aloud: "Me encanta viajar." [meh ehn-KAHN-tah byah-HAR]','Me encanta viajar',array[]::text[],'I love to travel.',9),
    (v_l2,'listening','Listen and pick the English meaning.','Prefiero leer',array['I prefer to dance','I prefer to read','I prefer to cook'],'I prefer to read',6),
    (v_l2,'listening','Listen and pick the English meaning.','No me gusta correr',array['I don''t like to run','I love to run','I like to walk'],'I don''t like to run',7),
    (v_l2,'speaking','Say this aloud: "Me encanta cocinar." [meh ehn-KAHN-tah koh-see-NAR]','Me encanta cocinar',array[]::text[],'I love to cook.',8),
    (v_l2,'speaking','Say this aloud: "Detesto bailar." [deh-TEHS-toh bah-ee-LAR]','Detesto bailar',array[]::text[],'I hate to dance.',9),
    (v_l3,'listening','Listen and pick the English meaning.','En mi tiempo libre leo',array['In my free time I sing','In my free time I read','In my free time I run'],'In my free time I read',6),
    (v_l3,'listening','Listen and pick the English meaning.','Salgo con mis amigos',array['I work with my friends','I go out with my friends','I live with my friends'],'I go out with my friends',7),
    (v_l3,'speaking','Say this aloud: "Los fines de semana nado." [lohs FEE-nehs deh seh-MAH-nah NAH-doh]','Los fines de semana nado',array[]::text[],'On weekends I swim.',8),
    (v_l3,'speaking','Say this aloud: "Me gusta el deporte al aire libre." [meh GOOS-tah ehl deh-POHR-teh ahl AH-ee-reh LEE-breh]','Me gusta el deporte al aire libre',array[]::text[],'I like outdoor sport.',9),
    (v_l6,'listening','Listen and pick the English meaning.','Pienso que los hobbies son importantes',array['I think hobbies are boring','I think hobbies are important','I think hobbies are expensive'],'I think hobbies are important',6),
    (v_l6,'listening','Listen and pick the English meaning.','Sobre todo me gusta la fotografía',array['I never like photography','Above all I like photography','I sometimes like photography'],'Above all I like photography',7),
    (v_l6,'speaking','Say this aloud: "Mi hobby es la fotografía." [mee HOH-bee ehs lah foh-toh-grah-FEE-ah]','Mi hobby es la fotografía',array[]::text[],'My hobby is photography.',8),
    (v_l6,'speaking','Say this aloud: "Además toco el piano." [ah-deh-MAHS TOH-koh ehl PYAH-noh]','Además toco el piano',array[]::text[],'Besides, I play the piano.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Pinto cuando puedo',array['I read when I can','I paint when I can','I write when I can'],'I paint when I can',6),
    (v_l7,'listening','Listen and pick the English meaning.','Durante las vacaciones viajo',array['On weekends I travel','During holidays I travel','At night I travel'],'During holidays I travel',7),
    (v_l7,'speaking','Say this aloud: "Viajo mucho." [byah-HOH MOO-choh]','Viajo mucho',array[]::text[],'I travel a lot.',8),
    (v_l7,'speaking','Say this aloud: "Veo películas." [BEH-oh peh-LEE-koo-lahs]','Veo películas',array[]::text[],'I watch films.',9);

  -- ====== A2.4 WORK & JOBS ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Work & Jobs';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','Soy ingeniera',array['I am a doctor','I am an engineer','I am a teacher'],'I am an engineer',6),
    (v_l1,'listening','Listen and pick the English meaning.','Mi jefe es simpático',array['My boss is strict','My boss is nice','My boss is young'],'My boss is nice',7),
    (v_l1,'speaking','Say this aloud: "Trabajo de camarero." [trah-BAH-hoh deh kah-mah-REH-roh]','Trabajo de camarero',array[]::text[],'I work as a waiter.',8),
    (v_l1,'speaking','Say this aloud: "Mi hermana es médica." [mee ehr-MAH-nah ehs MEH-dee-kah]','Mi hermana es médica',array[]::text[],'My sister is a doctor.',9),
    (v_l2,'listening','Listen and pick the English meaning.','Trabajo en una oficina',array['I work at a school','I work in an office','I work at home'],'I work in an office',6),
    (v_l2,'listening','Listen and pick the English meaning.','Mi horario es de nueve a cinco',array['My schedule is 9 to 5','My break is 9 to 5','My salary is 9 to 5'],'My schedule is from 9 to 5',7),
    (v_l2,'speaking','Say this aloud: "Es una empresa grande." [ehs OO-nah ehm-PREH-sah GRAHN-deh]','Es una empresa grande',array[]::text[],'It''s a big company.',8),
    (v_l2,'speaking','Say this aloud: "Trabajo de ingeniero." [trah-BAH-hoh deh een-heh-NYEH-roh]','Trabajo de ingeniero',array[]::text[],'I work as an engineer.',9),
    (v_l3,'listening','Listen and pick the English meaning.','Tengo una reunión a las tres',array['I have a break at three','I have a meeting at three','I have lunch at three'],'I have a meeting at three',6),
    (v_l3,'listening','Listen and pick the English meaning.','¿Puedes enviar el correo?',array['Can you read the email?','Can you delete the email?','Can you send the email?'],'Can you send the email?',7),
    (v_l3,'speaking','Say this aloud: "Lo envío ahora." [loh ehn-BEE-oh ah-OH-rah]','Lo envío ahora',array[]::text[],'I''ll send it now.',8),
    (v_l3,'speaking','Say this aloud: "El cliente está esperando." [ehl klee-EHN-teh ehs-TAH ehs-peh-RAHN-doh]','El cliente está esperando',array[]::text[],'The client is waiting.',9),
    (v_l6,'listening','Listen and pick the English meaning.','Estoy contenta con mi trabajo',array['I''m bored with my job','I''m happy with my job','I''m worried about my job'],'I am happy with my job',6),
    (v_l6,'listening','Listen and pick the English meaning.','Soy responsable del equipo',array['I''m looking for a team','I''m in charge of the team','I''m leaving the team'],'I am in charge of the team',7),
    (v_l6,'speaking','Say this aloud: "Trabajo a tiempo completo." [trah-BAH-hoh ah TYEHM-poh kohm-PLEH-toh]','Trabajo a tiempo completo',array[]::text[],'I work full time.',8),
    (v_l6,'speaking','Say this aloud: "Tengo un puesto nuevo." [TEHN-goh oon PWEHS-toh NWEH-boh]','Tengo un puesto nuevo',array[]::text[],'I have a new position.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Busco trabajo',array['I have a job','I''m looking for work','I''m leaving work'],'I''m looking for work',6),
    (v_l7,'listening','Listen and pick the English meaning.','Tengo una entrevista mañana',array['I have a meeting tomorrow','I have an interview tomorrow','I have a class tomorrow'],'I have an interview tomorrow',7),
    (v_l7,'speaking','Say this aloud: "Envío mi currículum." [ehn-BEE-oh mee koo-RREE-koo-loom]','Envío mi currículum',array[]::text[],'I send my resumé.',8),
    (v_l7,'speaking','Say this aloud: "El ambiente es bueno." [ehl ahm-BYEHN-teh ehs BWEH-noh]','El ambiente es bueno',array[]::text[],'The atmosphere is good.',9);

  -- ====== A2.5 DIRECTIONS ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Directions';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','Gira a la derecha',array['Turn left','Turn right','Go straight'],'Turn right',6),
    (v_l1,'listening','Listen and pick the English meaning.','Sigue todo recto',array['Keep going straight','Turn at the corner','Cross the street'],'Keep going straight',7),
    (v_l1,'speaking','Say this aloud: "A la izquierda." [ah lah ees-KYEHR-dah]','A la izquierda',array[]::text[],'To the left.',8),
    (v_l1,'speaking','Say this aloud: "En el semáforo gira." [ehn ehl seh-MAH-foh-roh HEE-rah]','En el semáforo gira',array[]::text[],'At the traffic light, turn.',9),
    (v_l2,'listening','Listen and pick the English meaning.','Vivo cerca del parque',array['I work near the park','I live near the park','I run near the park'],'I live near the park',6),
    (v_l2,'listening','Listen and pick the English meaning.','Al lado del banco hay un café',array['Across from the bank there''s a café','Behind the bank there''s a café','Next to the bank there''s a café'],'Next to the bank there''s a café',7),
    (v_l2,'speaking','Say this aloud: "Está lejos de aquí." [ehs-TAH LEH-hohs deh ah-KEE]','Está lejos de aquí',array[]::text[],'It''s far from here.',8),
    (v_l2,'speaking','Say this aloud: "Entre el banco y el café." [EHN-treh ehl BAHN-koh ee ehl kah-FEH]','Entre el banco y el café',array[]::text[],'Between the bank and the café.',9),
    (v_l3,'listening','Listen and pick the English meaning.','¿Cómo llego a la estación?',array['Where is the station?','How do I get to the station?','How far is the station?'],'How do I get to the station?',6),
    (v_l3,'listening','Listen and pick the English meaning.','A unos cinco minutos a pie',array['About five minutes on foot','About five kilometers','About five hours by bus'],'About five minutes on foot',7),
    (v_l3,'speaking','Say this aloud: "Cruza la calle." [KROO-sah lah KAH-yeh]','Cruza la calle',array[]::text[],'Cross the street.',8),
    (v_l3,'speaking','Say this aloud: "Vamos a pie." [BAH-mohs ah PYEH]','Vamos a pie',array[]::text[],'Let''s walk.',9),
    (v_l6,'listening','Listen and pick the English meaning.','Verás el museo enfrente del parque',array['You''ll see the museum behind the park','You''ll see the museum across from the park','You''ll see the museum next to the bank'],'You''ll see the museum across from the park',6),
    (v_l6,'listening','Listen and pick the English meaning.','Camina dos manzanas todo recto',array['Walk three blocks left','Walk two blocks straight','Walk two streets right'],'Walk two blocks straight',7),
    (v_l6,'speaking','Say this aloud: "Es el edificio grande." [ehs ehl eh-dee-FEE-syoh GRAHN-deh]','Es el edificio grande',array[]::text[],'It''s the big building.',8),
    (v_l6,'speaking','Say this aloud: "Toma la salida del metro." [TOH-mah lah sah-LEE-dah dehl MEH-troh]','Toma la salida del metro',array[]::text[],'Take the metro exit.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Camino diez minutos',array['I walk ten kilometers','I walk ten minutes','I run ten minutes'],'I walk ten minutes',6),
    (v_l7,'listening','Listen and pick the English meaning.','Llego al parque',array['I arrive at the park','I leave the park','I cross the park'],'I arrive at the park',7),
    (v_l7,'speaking','Say this aloud: "Cruzo el puente." [KROO-soh ehl PWEHN-teh]','Cruzo el puente',array[]::text[],'I cross the bridge.',8),
    (v_l7,'speaking','Say this aloud: "Sigo recto." [SEE-goh RREHK-toh]','Sigo recto',array[]::text[],'I keep going straight.',9);

  -- ====== A2.6 FEELINGS & EMOTIONS ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Feelings & Emotions';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','Estoy contenta hoy',array['I am tired today','I am happy today','I am sad today'],'I am happy today',6),
    (v_l1,'listening','Listen and pick the English meaning.','Está triste',array['He/she is sad','He/she is angry','He/she is tired'],'He/she is sad',7),
    (v_l1,'speaking','Say this aloud: "Estoy muy enfadado." [ehs-TOY mwee ehn-fah-DAH-doh]','Estoy muy enfadado',array[]::text[],'I am very angry.',8),
    (v_l1,'speaking','Say this aloud: "Estoy nervioso por el examen." [ehs-TOY nehr-BYOH-soh pohr ehl ehk-SAH-mehn]','Estoy nervioso por el examen',array[]::text[],'I am nervous about the exam.',9),
    (v_l2,'listening','Listen and pick the English meaning.','Me siento bien',array['I feel bad','I feel well','I feel sick'],'I feel well',6),
    (v_l2,'listening','Listen and pick the English meaning.','Me siento preocupado',array['I feel worried','I feel happy','I feel relaxed'],'I feel worried',7),
    (v_l2,'speaking','Say this aloud: "Me siento muy feliz." [meh SYEHN-toh mwee feh-LEES]','Me siento muy feliz',array[]::text[],'I feel very happy.',8),
    (v_l2,'speaking','Say this aloud: "Ella se siente preocupada." [EH-yah seh SYEHN-teh preh-oh-koo-PAH-dah]','Ella se siente preocupada',array[]::text[],'She feels worried.',9),
    (v_l3,'listening','Listen and pick the English meaning.','¿Qué te pasa?',array['What''s your name?','What''s wrong?','Where are you going?'],'What''s wrong?',6),
    (v_l3,'listening','Listen and pick the English meaning.','Estoy de mal humor',array['I''m in a good mood','I''m in a bad mood','I''m really tired'],'I''m in a bad mood',7),
    (v_l3,'speaking','Say this aloud: "Estoy un poco cansada." [ehs-TOY oon POH-koh kahn-SAH-dah]','Estoy un poco cansada',array[]::text[],'I am a little tired.',8),
    (v_l3,'speaking','Say this aloud: "Hoy estoy de buen humor." [oy ehs-TOY deh bwehn oo-MOHR]','Hoy estoy de buen humor',array[]::text[],'Today I am in a good mood.',9),
    (v_l6,'listening','Listen and pick the English meaning.','El viernes está feliz',array['On Friday she is sad','On Friday she is happy','On Friday she is tired'],'On Friday she is happy',6),
    (v_l6,'listening','Listen and pick the English meaning.','Está nerviosa por una reunión',array['She''s excited about a trip','She''s nervous about a meeting','She''s late for a class'],'She''s nervous about a meeting',7),
    (v_l6,'speaking','Say this aloud: "El lunes estoy cansada." [ehl LOO-nehs ehs-TOY kahn-SAH-dah]','El lunes estoy cansada',array[]::text[],'On Monday I am tired.',8),
    (v_l6,'speaking','Say this aloud: "Siempre estoy contenta los sábados." [SYEHM-preh ehs-TOY kohn-TEHN-tah lohs SAH-bah-dohs]','Siempre estoy contenta los sábados',array[]::text[],'I''m always happy on Saturdays.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Mañana voy a estar feliz',array['Tomorrow I''m going to be happy','Yesterday I was happy','Today I''m happy'],'Tomorrow I''m going to be happy',6),
    (v_l7,'listening','Listen and pick the English meaning.','Raramente estoy enfadado',array['I am rarely angry','I am often angry','I am always angry'],'I am rarely angry',7),
    (v_l7,'speaking','Say this aloud: "Estoy cansado a menudo." [ehs-TOY kahn-SAH-doh ah meh-NOO-doh]','Estoy cansado a menudo',array[]::text[],'I am often tired.',8),
    (v_l7,'speaking','Say this aloud: "Ayer estaba triste." [ah-YEHR ehs-TAH-bah TREES-teh]','Ayer estaba triste',array[]::text[],'Yesterday I was sad.',9);

  -- ====== A2.7 CELEBRATIONS ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Celebrations';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','Mi cumpleaños es en mayo',array['My birthday is in May','My birthday is in March','My birthday is on Monday'],'My birthday is in May',6),
    (v_l1,'listening','Listen and pick the English meaning.','Te invito a mi fiesta',array['I''m going to my party','I''m inviting you to my party','I''m leaving your party'],'I''m inviting you to my party',7),
    (v_l1,'speaking','Say this aloud: "Compro un regalo." [KOHM-proh oon rreh-GAH-loh]','Compro un regalo',array[]::text[],'I buy a gift.',8),
    (v_l1,'speaking','Say this aloud: "Vamos a una fiesta." [BAH-mohs ah OO-nah FYEHS-tah]','Vamos a una fiesta',array[]::text[],'We''re going to a party.',9),
    (v_l2,'listening','Listen and pick the English meaning.','Voy a hacer una fiesta',array['I''m going to a party','I''m going to throw a party','I''m leaving the party'],'I''m going to throw a party',6),
    (v_l2,'listening','Listen and pick the English meaning.','Vamos a bailar',array['We''re going to sing','We''re going to dance','We''re going to eat'],'We''re going to dance',7),
    (v_l2,'speaking','Say this aloud: "Voy a celebrar." [BOY ah seh-leh-BRAR]','Voy a celebrar',array[]::text[],'I''m going to celebrate.',8),
    (v_l2,'speaking','Say this aloud: "Preparo la comida." [preh-PAH-roh lah koh-MEE-dah]','Preparo la comida',array[]::text[],'I prepare the food.',9),
    (v_l3,'listening','Listen and pick the English meaning.','¡Feliz Navidad a todos!',array['Happy birthday everyone!','Merry Christmas everyone!','Happy New Year everyone!'],'Merry Christmas everyone!',6),
    (v_l3,'listening','Listen and pick the English meaning.','Vamos a brindar',array['Let''s make a toast','Let''s sing','Let''s cut the cake'],'Let''s make a toast',7),
    (v_l3,'speaking','Say this aloud: "¡Felicidades por la boda!" [feh-lee-see-DAH-dehs pohr lah BOH-dah]','¡Felicidades por la boda!',array[]::text[],'Congratulations on the wedding!',8),
    (v_l3,'speaking','Say this aloud: "La tarta está deliciosa." [lah TAR-tah ehs-TAH deh-lee-SYOH-sah]','La tarta está deliciosa',array[]::text[],'The cake is delicious.',9),
    (v_l6,'listening','Listen and pick the English meaning.','Carlos organiza una fiesta sorpresa',array['Carlos is at a surprise party','Carlos is organizing a surprise party','Carlos is missing a surprise party'],'Carlos is organizing a surprise party',6),
    (v_l6,'listening','Listen and pick the English meaning.','Todos se divierten mucho',array['Everyone is bored','Everyone has a lot of fun','Everyone goes home'],'Everyone has a lot of fun',7),
    (v_l6,'speaking','Say this aloud: "Voy a recordar esta noche." [BOY ah rreh-kohr-DAR EHS-tah NOH-cheh]','Voy a recordar esta noche',array[]::text[],'I''m going to remember tonight.',8),
    (v_l6,'speaking','Say this aloud: "Vamos a abrir regalos." [BAH-mohs ah ah-BREER rreh-GAH-lohs]','Vamos a abrir regalos',array[]::text[],'We''re going to open gifts.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Vamos a bailar hasta tarde',array['We''re going to dance until late','We''re going to leave early','We''re going to sleep late'],'We''re going to dance until late',6),
    (v_l7,'listening','Listen and pick the English meaning.','Voy a llevar un regalo',array['I''m going to bring a gift','I''m going to take a gift','I''m going to buy a gift'],'I''m going to bring a gift',7),
    (v_l7,'speaking','Say this aloud: "Vamos a cantar feliz cumpleaños." [BAH-mohs ah kahn-TAR feh-LEES koom-pleh-AH-nyohs]','Vamos a cantar feliz cumpleaños',array[]::text[],'We''re going to sing happy birthday.',8),
    (v_l7,'speaking','Say this aloud: "Empieza a las nueve." [ehm-PYEH-sah ah lahs NWEH-beh]','Empieza a las nueve',array[]::text[],'It starts at nine.',9);

  -- ====== A2.8 NATURE ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Nature';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','Vivo cerca del mar',array['I live near the river','I live near the sea','I live near the mountain'],'I live near the sea',6),
    (v_l1,'listening','Listen and pick the English meaning.','El árbol es alto',array['The tree is tall','The tree is short','The tree is wide'],'The tree is tall',7),
    (v_l1,'speaking','Say this aloud: "Camino por el bosque." [kah-MEE-noh pohr ehl BOHS-keh]','Camino por el bosque',array[]::text[],'I walk through the forest.',8),
    (v_l1,'speaking','Say this aloud: "Subo la montaña." [SOO-boh lah mohn-TAH-nyah]','Subo la montaña',array[]::text[],'I climb the mountain.',9),
    (v_l2,'listening','Listen and pick the English meaning.','El mar es más grande que el río',array['The sea is smaller than the river','The sea is bigger than the river','The sea is as big as the river'],'The sea is bigger than the river',6),
    (v_l2,'listening','Listen and pick the English meaning.','La lluvia es peor que la nieve',array['Rain is worse than snow','Rain is better than snow','Rain is like snow'],'Rain is worse than snow',7),
    (v_l2,'speaking','Say this aloud: "Es más tranquila que el mar." [ehs MAHS trahn-KEE-lah keh ehl mahr]','Es más tranquila que el mar',array[]::text[],'It''s more peaceful than the sea.',8),
    (v_l2,'speaking','Say this aloud: "Ningún sitio es tan bonito como el bosque." [neen-GOON SEE-tyoh ehs tahn boh-NEE-toh KOH-moh ehl BOHS-keh]','Ningún sitio es tan bonito como el bosque',array[]::text[],'No place is as pretty as the forest.',9),
    (v_l3,'listening','Listen and pick the English meaning.','Vamos a hacer senderismo',array['Let''s go camping','Let''s go hiking','Let''s go swimming'],'Let''s go hiking',6),
    (v_l3,'listening','Listen and pick the English meaning.','El paisaje es precioso',array['The atmosphere is beautiful','The landscape is beautiful','The forest is beautiful'],'The landscape is beautiful',7),
    (v_l3,'speaking','Say this aloud: "Acampamos cerca del lago." [ah-kahm-PAH-mohs SEHR-kah dehl LAH-goh]','Acampamos cerca del lago',array[]::text[],'We camp near the lake.',8),
    (v_l3,'speaking','Say this aloud: "Amo la naturaleza." [AH-moh lah nah-too-rah-LEH-sah]','Amo la naturaleza',array[]::text[],'I love nature.',9),
    (v_l6,'listening','Listen and pick the English meaning.','Es un espacio protegido',array['It''s a private area','It''s a protected area','It''s a public area'],'It''s a protected area',6),
    (v_l6,'listening','Listen and pick the English meaning.','Visitamos el parque cada año',array['We visit the park sometimes','We visit the park every year','We visit the park rarely'],'We visit the park every year',7),
    (v_l6,'speaking','Say this aloud: "Hay un río muy importante." [I oon RREE-oh mwee eem-pohr-TAHN-teh]','Hay un río muy importante',array[]::text[],'There is a very important river.',8),
    (v_l6,'speaking','Say this aloud: "Es un parque famoso." [ehs oon PAR-keh fah-MOH-soh]','Es un parque famoso',array[]::text[],'It''s a famous park.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Mi lugar favorito es la playa',array['My favorite place is the beach','My favorite place is the forest','My favorite place is the mountain'],'My favorite place is the beach',6),
    (v_l7,'listening','Listen and pick the English meaning.','Voy a menudo en verano',array['I never go in summer','I go often in summer','I go in winter'],'I go often in summer',7),
    (v_l7,'speaking','Say this aloud: "El lugar es muy tranquilo." [ehl loo-GAR ehs mwee trahn-KEE-loh]','El lugar es muy tranquilo',array[]::text[],'The place is very peaceful.',8),
    (v_l7,'speaking','Say this aloud: "Hay árboles y flores." [I AR-boh-lehs ee FLOH-rehs]','Hay árboles y flores',array[]::text[],'There are trees and flowers.',9);

  -- ====== A2.9 SPORTS ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Sports';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','El fútbol es muy popular',array['Football is very popular','Tennis is very popular','Basketball is very popular'],'Football is very popular',6),
    (v_l1,'listening','Listen and pick the English meaning.','Me gusta el ciclismo',array['I like swimming','I like cycling','I like running'],'I like cycling',7),
    (v_l1,'speaking','Say this aloud: "Juego al baloncesto." [HWEH-goh ahl bah-lohn-SEHS-toh]','Juego al baloncesto',array[]::text[],'I play basketball.',8),
    (v_l1,'speaking','Say this aloud: "Practico natación." [prahk-TEE-koh nah-tah-SYOHN]','Practico natación',array[]::text[],'I do swimming.',9),
    (v_l2,'listening','Listen and pick the English meaning.','Juego al fútbol los domingos',array['I play football on Sundays','I watch football on Sundays','I miss football on Sundays'],'I play football on Sundays',6),
    (v_l2,'listening','Listen and pick the English meaning.','Entreno los martes',array['I rest on Tuesdays','I train on Tuesdays','I leave on Tuesdays'],'I train on Tuesdays',7),
    (v_l2,'speaking','Say this aloud: "Mi equipo es bueno." [mee eh-KEE-poh ehs BWEH-noh]','Mi equipo es bueno',array[]::text[],'My team is good.',8),
    (v_l2,'speaking','Say this aloud: "Practico tenis." [prahk-TEE-koh TEH-nees]','Practico tenis',array[]::text[],'I practice tennis.',9),
    (v_l3,'listening','Listen and pick the English meaning.','Mi equipo gana mucho',array['My team wins a lot','My team loses a lot','My team trains a lot'],'My team wins a lot',6),
    (v_l3,'listening','Listen and pick the English meaning.','Hoy hay un partido',array['Today there is a match','Today is a holiday','Today we train'],'Today there is a match',7),
    (v_l3,'speaking','Say this aloud: "Somos los campeones." [SOH-mohs lohs kahm-peh-OH-nehs]','Somos los campeones',array[]::text[],'We are the champions.',8),
    (v_l3,'speaking','Say this aloud: "Perdimos el partido." [pehr-DEE-mohs ehl pahr-TEE-doh]','Perdimos el partido',array[]::text[],'We lost the match.',9),
    (v_l6,'listening','Listen and pick the English meaning.','Sergio entrena cinco días a la semana',array['Sergio rests five days a week','Sergio trains five days a week','Sergio runs five days a week'],'Sergio trains five days a week',6),
    (v_l6,'listening','Listen and pick the English meaning.','Va al gimnasio a levantar pesas',array['He goes to the gym to lift weights','He goes to the park to lift weights','He goes to the pool to lift weights'],'He goes to the gym to lift weights',7),
    (v_l6,'speaking','Say this aloud: "Hay un campeonato pronto." [I oon kahm-peh-oh-NAH-toh PROHN-toh]','Hay un campeonato pronto',array[]::text[],'There''s a championship soon.',8),
    (v_l6,'speaking','Say this aloud: "Mi entrenador es estricto." [mee ehn-treh-nah-DOHR ehs ehs-TREEK-toh]','Mi entrenador es estricto',array[]::text[],'My coach is strict.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Juego desde niño',array['I''ve played since I was a kid','I started playing yesterday','I never played as a kid'],'I''ve played since I was a kid',6),
    (v_l7,'listening','Listen and pick the English meaning.','Compito en torneos pequeños',array['I never compete','I compete in small tournaments','I watch tournaments'],'I compete in small tournaments',7),
    (v_l7,'speaking','Say this aloud: "Entreno todas las semanas." [ehn-TREH-noh TOH-dahs lahs seh-MAH-nahs]','Entreno todas las semanas',array[]::text[],'I train every week.',8),
    (v_l7,'speaking','Say this aloud: "Mi deporte favorito es el tenis." [mee deh-POHR-teh fah-boh-REE-toh ehs ehl TEH-nees]','Mi deporte favorito es el tenis',array[]::text[],'My favorite sport is tennis.',9);

  -- ====== A2.10 MUSIC ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Music';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','Me gusta esta canción',array['I don''t like this song','I like this song','I wrote this song'],'I like this song',6),
    (v_l1,'listening','Listen and pick the English meaning.','Voy al concierto',array['I''m going to the concert','I''m leaving the concert','I''m playing at the concert'],'I''m going to the concert',7),
    (v_l1,'speaking','Say this aloud: "Es mi cantante favorito." [ehs mee kahn-TAHN-teh fah-boh-REE-toh]','Es mi cantante favorito',array[]::text[],'He is my favorite singer.',8),
    (v_l1,'speaking','Say this aloud: "Es una banda nueva." [ehs OO-nah BAHN-dah NWEH-bah]','Es una banda nueva',array[]::text[],'It''s a new band.',9),
    (v_l2,'listening','Listen and pick the English meaning.','Me gusta mucho el jazz',array['I don''t like jazz','I really like jazz','I sometimes like jazz'],'I really like jazz',6),
    (v_l2,'listening','Listen and pick the English meaning.','Sé tocar la guitarra',array['I want to play the guitar','I know how to play the guitar','I sold my guitar'],'I know how to play the guitar',7),
    (v_l2,'speaking','Say this aloud: "Quiero aprender piano." [KYEH-roh ah-prehn-DEHR PYAH-noh]','Quiero aprender piano',array[]::text[],'I want to learn piano.',8),
    (v_l2,'speaking','Say this aloud: "No me gusta nada el reggaetón." [noh meh GOOS-tah NAH-dah ehl rreh-geh-TOHN]','No me gusta nada el reggaetón',array[]::text[],'I don''t like reggaeton at all.',9),
    (v_l3,'listening','Listen and pick the English meaning.','Pongo música cuando cocino',array['I cook while listening to music','I sing while I cook','I play music while I cook'],'I put music on when I cook',6),
    (v_l3,'listening','Listen and pick the English meaning.','La letra es bonita',array['The lyrics are pretty','The music is loud','The singer is famous'],'The lyrics are pretty',7),
    (v_l3,'speaking','Say this aloud: "Compro dos entradas." [KOHM-proh dohs ehn-TRAH-dahs]','Compro dos entradas',array[]::text[],'I buy two tickets.',8),
    (v_l3,'speaking','Say this aloud: "Me encanta el ritmo." [meh ehn-KAHN-tah ehl RREET-moh]','Me encanta el ritmo',array[]::text[],'I love the rhythm.',9),
    (v_l6,'listening','Listen and pick the English meaning.','Lanzaron su primer disco hace cinco años',array['They sold their first album five years ago','They released their first album five years ago','They lost their first album'],'They released their first album five years ago',6),
    (v_l6,'listening','Listen and pick the English meaning.','Actúan en grandes festivales',array['They perform at big festivals','They visit big festivals','They organize festivals'],'They perform at big festivals',7),
    (v_l6,'speaking','Say this aloud: "Es una banda muy famosa." [ehs OO-nah BAHN-dah mwee fah-MOH-sah]','Es una banda muy famosa',array[]::text[],'It''s a very famous band.',8),
    (v_l6,'speaking','Say this aloud: "Su éxito más grande." [soo EHK-see-toh MAHS GRAHN-deh]','Su éxito más grande',array[]::text[],'Their biggest hit.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Me encanta escucharlos',array['I never listen to them','I love listening to them','I rarely listen to them'],'I love listening to them',6),
    (v_l7,'listening','Listen and pick the English meaning.','Te los recomiendo mucho',array['I really recommend them to you','I am them','I sing them to you'],'I really recommend them to you',7),
    (v_l7,'speaking','Say this aloud: "Tiene tres álbumes." [TYEH-neh trehs AHL-boo-mehs]','Tiene tres álbumes',array[]::text[],'They have three albums.',8),
    (v_l7,'speaking','Say this aloud: "Mi banda favorita." [mee BAHN-dah fah-boh-REE-tah]','Mi banda favorita',array[]::text[],'My favorite band.',9);

  -- ====== A2.11 TRAVEL PLANNING ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Travel Planning';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','El vuelo sale a las nueve',array['The flight leaves at nine','The flight arrives at nine','The flight is delayed'],'The flight leaves at nine',6),
    (v_l1,'listening','Listen and pick the English meaning.','Hago la maleta',array['I open my suitcase','I pack my suitcase','I close my suitcase'],'I pack my suitcase',7),
    (v_l1,'speaking','Say this aloud: "Voy a reservar un hotel." [BOY ah rreh-sehr-BAR oon oh-TEHL]','Voy a reservar un hotel',array[]::text[],'I''m going to book a hotel.',8),
    (v_l1,'speaking','Say this aloud: "Compro un billete de tren." [KOHM-proh oon bee-YEH-teh deh trehn]','Compro un billete de tren',array[]::text[],'I buy a train ticket.',9),
    (v_l2,'listening','Listen and pick the English meaning.','Un billete sólo de ida',array['A round-trip ticket','A one-way ticket','A free ticket'],'A one-way ticket',6),
    (v_l2,'listening','Listen and pick the English meaning.','Voy a viajar este verano',array['I''m going to travel this summer','I traveled last summer','I never travel in summer'],'I''m going to travel this summer',7),
    (v_l2,'speaking','Say this aloud: "Un billete para Madrid." [oon bee-YEH-teh PAH-rah mah-DREED]','Un billete para Madrid',array[]::text[],'A ticket to Madrid.',8),
    (v_l2,'speaking','Say this aloud: "¿Cuál es su destino?" [KWAHL ehs soo dehs-TEE-noh]','¿Cuál es su destino?',array[]::text[],'What is your destination?',9),
    (v_l3,'listening','Listen and pick the English meaning.','Quiero hacer una reserva',array['I want to cancel a reservation','I want to make a reservation','I have no reservation'],'I want to make a reservation',6),
    (v_l3,'listening','Listen and pick the English meaning.','Aquí está mi pasaporte',array['I lost my passport','Here is my passport','I need a passport'],'Here is my passport',7),
    (v_l3,'speaking','Say this aloud: "La habitación 305." [lah ah-bee-tah-SYOHN trehs SEH-roh SEEN-koh]','La habitación 305',array[]::text[],'Room 305.',8),
    (v_l3,'speaking','Say this aloud: "Pido la llave de mi habitación." [PEE-doh lah YAH-beh deh mee ah-bee-tah-SYOHN]','Pido la llave de mi habitación',array[]::text[],'I ask for the key to my room.',9),
    (v_l6,'listening','Listen and pick the English meaning.','Va a visitar tres ciudades',array['She''s going to visit three cities','She visited three cities','She lives in three cities'],'She''s going to visit three cities',6),
    (v_l6,'listening','Listen and pick the English meaning.','Mi presupuesto es de mil euros',array['I have no budget','My budget is 1000 euros','My budget is 100 euros'],'My budget is 1000 euros',7),
    (v_l6,'speaking','Say this aloud: "Me alojo en un hostal." [meh ah-LOH-hoh ehn oon ohs-TAHL]','Me alojo en un hostal',array[]::text[],'I stay at a hostel.',8),
    (v_l6,'speaking','Say this aloud: "Mi itinerario está listo." [mee ee-tee-neh-RAH-ryoh ehs-TAH LEES-toh]','Mi itinerario está listo',array[]::text[],'My itinerary is ready.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Voy con mi pareja durante diez días',array['I''m going with my partner for ten days','I''m going alone for ten days','My partner is going for ten days'],'I''m going with my partner for ten days',6),
    (v_l7,'listening','Listen and pick the English meaning.','Vamos a quedarnos en hoteles pequeños',array['We''re going to stay in small hotels','We''re going to stay in big hotels','We''re going to stay at home'],'We''re going to stay in small hotels',7),
    (v_l7,'speaking','Say this aloud: "Este verano viajo a México." [EHS-teh beh-RAH-noh byah-HOH ah MEH-hee-koh]','Este verano viajo a México',array[]::text[],'This summer I travel to Mexico.',8),
    (v_l7,'speaking','Say this aloud: "Voy a quedarme en un hotel." [BOY ah keh-DAR-meh ehn oon oh-TEHL]','Voy a quedarme en un hotel',array[]::text[],'I''m going to stay in a hotel.',9);

  -- ====== A2.12 RESTAURANTS ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Restaurants';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','La cuenta, por favor',array['The menu, please','The bill, please','The water, please'],'The bill, please',6),
    (v_l1,'listening','Listen and pick the English meaning.','Hoy es paella valenciana',array['Today it''s Valencian paella','Yesterday was Valencian paella','Tomorrow is Valencian paella'],'Today it''s Valencian paella',7),
    (v_l1,'speaking','Say this aloud: "Una mesa para dos." [OO-nah MEH-sah PAH-rah dohs]','Una mesa para dos',array[]::text[],'A table for two.',8),
    (v_l1,'speaking','Say this aloud: "Dejo una propina." [DEH-hoh OO-nah proh-PEE-nah]','Dejo una propina',array[]::text[],'I leave a tip.',9),
    (v_l2,'listening','Listen and pick the English meaning.','¿Me trae agua?',array['Can you bring me water?','Can you bring me wine?','Can you bring me bread?'],'Could you bring me water?',6),
    (v_l2,'listening','Listen and pick the English meaning.','Para mí, una ensalada',array['For me, a soup','For me, a salad','For me, pasta'],'For me, a salad',7),
    (v_l2,'speaking','Say this aloud: "Quiero un café, por favor." [KYEH-roh oon kah-FEH pohr fah-BOHR]','Quiero un café, por favor',array[]::text[],'I want a coffee, please.',8),
    (v_l2,'speaking','Say this aloud: "Una pizza sin queso." [OO-nah PEET-sah seen KEH-soh]','Una pizza sin queso',array[]::text[],'A pizza without cheese.',9),
    (v_l3,'listening','Listen and pick the English meaning.','De primero, sopa',array['As a dessert, soup','As a main, soup','As a starter, soup'],'As a starter, soup',6),
    (v_l3,'listening','Listen and pick the English meaning.','Una copa de vino tinto',array['A bottle of red wine','A glass of red wine','A glass of white wine'],'A glass of red wine',7),
    (v_l3,'speaking','Say this aloud: "¿Tienen pan sin gluten?" [TYEH-nehn pahn seen GLOO-tehn]','¿Tienen pan sin gluten?',array[]::text[],'Do you have gluten-free bread?',8),
    (v_l3,'speaking','Say this aloud: "La cuenta, por favor." [lah KWEHN-tah pohr fah-BOHR]','La cuenta, por favor',array[]::text[],'The bill, please.',9),
    (v_l6,'listening','Listen and pick the English meaning.','La comida estaba deliciosa',array['The food was delicious','The food was cold','The food was expensive'],'The food was delicious',6),
    (v_l6,'listening','Listen and pick the English meaning.','Voy a volver pronto',array['I''m going to leave soon','I''m going to come back soon','I''m going to stay long'],'I''m going to come back soon',7),
    (v_l6,'speaking','Say this aloud: "El ambiente era muy agradable." [ehl ahm-BYEHN-teh EH-rah mwee ah-grah-DAH-bleh]','El ambiente era muy agradable',array[]::text[],'The atmosphere was very pleasant.',8),
    (v_l6,'speaking','Say this aloud: "El precio es razonable." [ehl PREH-syoh ehs rrah-soh-NAH-bleh]','El precio es razonable',array[]::text[],'The price is reasonable.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Te lo recomiendo',array['I bought it for you','I recommend it to you','I cooked it for you'],'I recommend it to you',6),
    (v_l7,'listening','Listen and pick the English meaning.','Volveré con mi familia',array['I''ll come back with my family','I''ll go home alone','I''m leaving my family'],'I''ll come back with my family',7),
    (v_l7,'speaking','Say this aloud: "Es bastante barato." [ehs bahs-TAHN-teh bah-RAH-toh]','Es bastante barato',array[]::text[],'It''s pretty cheap.',8),
    (v_l7,'speaking','Say this aloud: "Es un poco caro." [ehs oon POH-koh KAH-roh]','Es un poco caro',array[]::text[],'It''s a little expensive.',9);

  -- ====== A2.13 SCHOOL ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'School';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','Mi asignatura favorita es historia',array['My favorite subject is math','My favorite subject is history','My favorite subject is English'],'My favorite subject is history',6),
    (v_l1,'listening','Listen and pick the English meaning.','Tengo un examen mañana',array['I have an exam today','I have an exam tomorrow','I have no exam'],'I have an exam tomorrow',7),
    (v_l1,'speaking','Say this aloud: "Hago los deberes en casa." [AH-goh lohs deh-BEH-rehs ehn KAH-sah]','Hago los deberes en casa',array[]::text[],'I do my homework at home.',8),
    (v_l1,'speaking','Say this aloud: "Aprobé el examen." [ah-proh-BEH ehl ehk-SAH-mehn]','Aprobé el examen',array[]::text[],'I passed the exam.',9),
    (v_l2,'listening','Listen and pick the English meaning.','Tengo que estudiar',array['I want to study','I have to study','I refuse to study'],'I have to study',6),
    (v_l2,'listening','Listen and pick the English meaning.','Tengo que entregar el trabajo',array['I have to start the assignment','I have to hand in the assignment','I have to read the assignment'],'I have to hand in the assignment',7),
    (v_l2,'speaking','Say this aloud: "Estudio matemáticas." [ehs-TOO-dyoh mah-teh-MAH-tee-kahs]','Estudio matemáticas',array[]::text[],'I study math.',8),
    (v_l2,'speaking','Say this aloud: "Aprendo español." [ah-PREHN-doh ehs-pah-NYOHL]','Aprendo español',array[]::text[],'I''m learning Spanish.',9),
    (v_l3,'listening','Listen and pick the English meaning.','En el recreo juego con mis amigos',array['At recess I play with my friends','In class I play with my friends','After school I play with my friends'],'At recess I play with my friends',6),
    (v_l3,'listening','Listen and pick the English meaning.','Saqué buena nota',array['I failed','I got a good grade','I lost my notebook'],'I got a good grade',7),
    (v_l3,'speaking','Say this aloud: "La clase empieza a las nueve." [lah KLAH-seh ehm-PYEH-sah ah lahs NWEH-beh]','La clase empieza a las nueve',array[]::text[],'Class starts at nine.',8),
    (v_l3,'speaking','Say this aloud: "Hoy mi horario es duro." [oy mee oh-RAH-ryoh ehs DOO-roh]','Hoy mi horario es duro',array[]::text[],'Today my schedule is tough.',9),
    (v_l6,'listening','Listen and pick the English meaning.','Va al instituto en autobús',array['He goes to high school by car','He goes to high school by bus','He goes to high school on foot'],'He goes to high school by bus',6),
    (v_l6,'listening','Listen and pick the English meaning.','Hace los deberes en grupo',array['He does homework alone','He does homework in a group','He never does homework'],'He does homework in a group',7),
    (v_l6,'speaking','Say this aloud: "Como un bocadillo en el recreo." [KOH-moh oon boh-kah-DEE-yoh ehn ehl rreh-KREH-oh]','Como un bocadillo en el recreo',array[]::text[],'I eat a sandwich at recess.',8),
    (v_l6,'speaking','Say this aloud: "Sé mucha historia." [seh MOO-chah ees-TOH-ryah]','Sé mucha historia',array[]::text[],'I know a lot of history.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Estudio en la biblioteca durante dos horas',array['I study at the library for two hours','I study at home for two hours','I study at school for two hours'],'I study at the library for two hours',6),
    (v_l7,'listening','Listen and pick the English meaning.','El viernes salgo pronto',array['On Friday I leave late','On Friday I get out early','On Friday I stay all day'],'On Friday I get out early',7),
    (v_l7,'speaking','Say this aloud: "Voy al colegio en bicicleta." [BOY ahl koh-LEH-hyoh ehn bee-see-KLEH-tah]','Voy al colegio en bicicleta',array[]::text[],'I go to school by bike.',8),
    (v_l7,'speaking','Say this aloud: "Tengo poco trabajo." [TEHN-goh POH-koh trah-BAH-hoh]','Tengo poco trabajo',array[]::text[],'I have little work.',9);

  -- ====== A2.14 TECHNOLOGY BASICS ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Technology Basics';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','Mi móvil es nuevo',array['My phone is broken','My phone is new','My phone is old'],'My phone is new',6),
    (v_l1,'listening','Listen and pick the English meaning.','¿Cuál es la contraseña?',array['Where is the password?','What''s the password?','Why is the password?'],'What''s the password?',7),
    (v_l1,'speaking','Say this aloud: "Trabajo en mi ordenador." [trah-BAH-hoh ehn mee ohr-deh-nah-DOHR]','Trabajo en mi ordenador',array[]::text[],'I work on my computer.',8),
    (v_l1,'speaking','Say this aloud: "Descargo una aplicación nueva." [dehs-KAR-goh OO-nah ah-plee-kah-SYOHN NWEH-bah]','Descargo una aplicación nueva',array[]::text[],'I download a new app.',9),
    (v_l2,'listening','Listen and pick the English meaning.','No funciona el wifi',array['The wifi is fast','The wifi isn''t working','The wifi is free'],'The wifi isn''t working',6),
    (v_l2,'listening','Listen and pick the English meaning.','Voy a reiniciar el ordenador',array['I''m going to buy a computer','I''m going to restart the computer','I''m going to sell the computer'],'I''m going to restart the computer',7),
    (v_l2,'speaking','Say this aloud: "Puedo descargar la app." [PWEH-doh dehs-kahr-GAR lah ahp]','Puedo descargar la app',array[]::text[],'I can download the app.',8),
    (v_l2,'speaking','Say this aloud: "Tengo un problema con el móvil." [TEHN-goh oon proh-BLEH-mah kohn ehl MOH-beel]','Tengo un problema con el móvil',array[]::text[],'I have a problem with my phone.',9),
    (v_l3,'listening','Listen and pick the English meaning.','Reinicia el móvil',array['Buy a new phone','Restart the phone','Sell the phone'],'Restart the phone',6),
    (v_l3,'listening','Listen and pick the English meaning.','Tengo que actualizar la app',array['I have to delete the app','I have to update the app','I have to download the app'],'I have to update the app',7),
    (v_l3,'speaking','Say this aloud: "Borro la foto." [BOH-rroh lah FOH-toh]','Borro la foto',array[]::text[],'I delete the photo.',8),
    (v_l3,'speaking','Say this aloud: "Descargo una película." [dehs-KAR-goh OO-nah peh-LEE-koo-lah]','Descargo una película',array[]::text[],'I download a movie.',9),
    (v_l6,'listening','Listen and pick the English meaning.','Pasa cinco horas al día en aplicaciones',array['She spends one hour a day on apps','She spends five hours a day on apps','She spends ten hours a day on apps'],'She spends five hours a day on apps',6),
    (v_l6,'listening','Listen and pick the English meaning.','Sus padres se preocupan',array['Her parents are happy','Her parents worry','Her parents don''t care'],'Her parents worry',7),
    (v_l6,'speaking','Say this aloud: "Es adicta a las redes." [ehs ah-DEEK-tah ah lahs RREH-dehs]','Es adicta a las redes',array[]::text[],'She''s addicted to social networks.',8),
    (v_l6,'speaking','Say this aloud: "No puede dejar el móvil." [noh PWEH-deh deh-HAR ehl MOH-beel]','No puede dejar el móvil',array[]::text[],'She can''t put down her phone.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Uso mi móvil para todo',array['I use my phone for nothing','I use my phone for everything','I never use my phone'],'I use my phone for everything',6),
    (v_l7,'listening','Listen and pick the English meaning.','Intento no usarlo antes de dormir',array['I try not to use it before sleeping','I always use it before sleeping','I use it only at night'],'I try not to use it before sleeping',7),
    (v_l7,'speaking','Say this aloud: "Uso internet todos los días." [OO-soh een-tehr-NEHT TOH-dohs lohs DEE-ahs]','Uso internet todos los días',array[]::text[],'I use the internet every day.',8),
    (v_l7,'speaking','Say this aloud: "A veces juego en línea." [ah BEH-sehs HWEH-goh ehn LEE-neh-ah]','A veces juego en línea',array[]::text[],'Sometimes I play online.',9);

  -- ====== A2.15 SOCIAL MEDIA ======
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Social Media';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  delete from public.exercises where lesson_id in (v_l1,v_l2,v_l3,v_l6,v_l7) and order_index >= 6;
  insert into public.exercises (lesson_id,type,question,correct_answer,wrong_answers,translation,order_index) values
    (v_l1,'listening','Listen and pick the English meaning.','Te sigo en Instagram',array['I follow you on Instagram','I unfollow you on Instagram','I block you on Instagram'],'I follow you on Instagram',6),
    (v_l1,'listening','Listen and pick the English meaning.','Subo una foto',array['I delete a photo','I upload a photo','I send a photo'],'I upload a photo',7),
    (v_l1,'speaking','Say this aloud: "Tengo muchos likes." [TEHN-goh MOO-chohs LAH-eeks]','Tengo muchos likes',array[]::text[],'I have many likes.',8),
    (v_l1,'speaking','Say this aloud: "Comparto el vídeo." [kohm-PAR-toh ehl BEE-deh-oh]','Comparto el vídeo',array[]::text[],'I share the video.',9),
    (v_l2,'listening','Listen and pick the English meaning.','Estoy publicando una foto',array['I''m looking at a photo','I''m posting a photo','I''m deleting a photo'],'I''m posting a photo',6),
    (v_l2,'listening','Listen and pick the English meaning.','Tengo mil seguidores',array['I have one follower','I have one thousand followers','I have one hundred followers'],'I have a thousand followers',7),
    (v_l2,'speaking','Say this aloud: "Estoy mirando un vídeo." [ehs-TOY mee-RAHN-doh oon BEE-deh-oh]','Estoy mirando un vídeo',array[]::text[],'I''m watching a video.',8),
    (v_l2,'speaking','Say this aloud: "Dejo un comentario." [DEH-hoh oon koh-mehn-TAH-ryoh]','Dejo un comentario',array[]::text[],'I leave a comment.',9),
    (v_l3,'listening','Listen and pick the English meaning.','Subo una historia diaria',array['I upload a story daily','I never post','I follow a daily account'],'I upload a daily story',6),
    (v_l3,'listening','Listen and pick the English meaning.','Mi perfil es público',array['My profile is private','My profile is public','My profile is closed'],'My profile is public',7),
    (v_l3,'speaking','Say this aloud: "Etiqueta a tus amigos." [eh-tee-KEH-tah ah toos ah-MEE-gohs]','Etiqueta a tus amigos',array[]::text[],'Tag your friends.',8),
    (v_l3,'speaking','Say this aloud: "Dejé de seguir a esa cuenta." [deh-HEH deh seh-GEER ah EH-sah KWEHN-tah]','Dejé de seguir a esa cuenta',array[]::text[],'I unfollowed that account.',9),
    (v_l6,'listening','Listen and pick the English meaning.','Pasó tres días sin redes sociales',array['She spent three days without social media','She spent three weeks without social media','She spent three hours without social media'],'She spent three days without social media',6),
    (v_l6,'listening','Listen and pick the English meaning.','Recomienda a sus amigos hacer lo mismo',array['She tells her friends to stop','She recommends her friends do the same','She doesn''t talk to her friends'],'She recommends her friends do the same',7),
    (v_l6,'speaking','Say this aloud: "Me sentí libre." [meh sehn-TEE LEE-breh]','Me sentí libre',array[]::text[],'I felt free.',8),
    (v_l6,'speaking','Say this aloud: "Perdía mucho tiempo." [pehr-DEE-ah MOO-choh TYEHM-poh]','Perdía mucho tiempo',array[]::text[],'I was wasting a lot of time.',9),
    (v_l7,'listening','Listen and pick the English meaning.','Reviso mis redes sociales dos horas al día',array['I check my social media twice a year','I check my social media two hours a day','I check my social media on weekends'],'I check my social networks two hours a day',6),
    (v_l7,'listening','Listen and pick the English meaning.','Intento publicar una vez al día',array['I try to post once a day','I never post','I post twice a day'],'I try to post once a day',7),
    (v_l7,'speaking','Say this aloud: "Sigo a varios cantantes." [SEE-goh ah BAH-ryohs kahn-TAHN-tehs]','Sigo a varios cantantes',array[]::text[],'I follow several singers.',8),
    (v_l7,'speaking','Say this aloud: "Sobre todo uso Instagram." [SOH-breh TOH-doh OO-soh een-stah-GRAHM]','Sobre todo uso Instagram',array[]::text[],'Above all I use Instagram.',9);

end $$;

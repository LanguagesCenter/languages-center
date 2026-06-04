-- 024_spanish_a2_teaching.sql
-- Adds a teaching phase to every Spanish A2 lesson so users LEARN before they test.
-- Mirrors 017 (A1). Populates intro, vocab_items, dialogue, grammar_note for
-- all 15 A2 sections × 7 substantive lessons (lessons 1-7). Lesson 8 is
-- handled separately in 027 (conversation lessons).

do $$
declare
  v_lang_id    bigint;
  v_course_id  bigint;
  v_l1 bigint; v_l2 bigint; v_l3 bigint; v_l4 bigint;
  v_l5 bigint; v_l6 bigint; v_l7 bigint;
begin
  select id into v_lang_id from public.languages where code = 'spanish';

  -- ============== A2.1 DAILY ROUTINES ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Daily Routines';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'In this lesson you will learn the core verbs used to describe a daily routine in Spanish, from waking up to going to bed.',
    vocab_items = '[
      {"word":"despertarse","phonetic":"[dehs-pehr-TAR-seh]","english":"to wake up","example_es":"Me despierto a las siete.","example_en":"I wake up at seven."},
      {"word":"levantarse","phonetic":"[leh-bahn-TAR-seh]","english":"to get up","example_es":"Me levanto temprano.","example_en":"I get up early."},
      {"word":"ducharse","phonetic":"[doo-CHAR-seh]","english":"to shower","example_es":"Me ducho cada mañana.","example_en":"I shower every morning."},
      {"word":"desayunar","phonetic":"[deh-sah-yoo-NAR]","english":"to have breakfast","example_es":"Desayuno café con leche.","example_en":"I have coffee with milk for breakfast."},
      {"word":"acostarse","phonetic":"[ah-kohs-TAR-seh]","english":"to go to bed","example_es":"Me acuesto a las once.","example_en":"I go to bed at eleven."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Marta","spanish":"¿A qué hora te despiertas?","english":"What time do you wake up?"},
      {"speaker":"Luis","spanish":"Me despierto a las seis y media.","english":"I wake up at six thirty."},
      {"speaker":"Marta","spanish":"¿Te duchas por la mañana?","english":"Do you shower in the morning?"},
      {"speaker":"Luis","spanish":"Sí, y después desayuno.","english":"Yes, and then I have breakfast."}
    ]'::jsonb,
    grammar_note = 'Daily-routine verbs are usually reflexive in Spanish: the action turns back on the subject. Add me / te / se / nos / os / se before the verb: yo me ducho, tú te duchas, él se ducha.'
  where id = v_l1;

  update public.lessons set
    intro = 'Reflexive pronouns (me, te, se, nos, os, se) are the heart of daily-routine grammar. Master them and you can describe almost any morning in Spanish.',
    vocab_items = '[
      {"word":"me","phonetic":"[meh]","english":"myself","example_es":"Me lavo la cara.","example_en":"I wash my face."},
      {"word":"te","phonetic":"[teh]","english":"yourself","example_es":"¿Te vistes ahora?","example_en":"Are you getting dressed now?"},
      {"word":"se","phonetic":"[seh]","english":"himself / herself / yourself (formal)","example_es":"Ella se peina.","example_en":"She combs her hair."},
      {"word":"nos","phonetic":"[nohs]","english":"ourselves","example_es":"Nos acostamos tarde.","example_en":"We go to bed late."},
      {"word":"vestirse","phonetic":"[behs-TEER-seh]","english":"to get dressed","example_es":"Me visto rápido.","example_en":"I get dressed quickly."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Padre","spanish":"¡Niños, levantaos!","english":"Kids, get up!"},
      {"speaker":"Ana","spanish":"Ya me levanto, papá.","english":"I''m getting up now, Dad."},
      {"speaker":"Padre","spanish":"¿Os habéis duchado?","english":"Have you showered?"},
      {"speaker":"Ana","spanish":"Yo me ducho ahora, mi hermano se viste.","english":"I''m showering now, my brother is getting dressed."}
    ]'::jsonb,
    grammar_note = 'Reflexive pronoun + conjugated verb. Yo me, tú te, él/ella/usted se, nosotros nos, vosotros os, ellos/ustedes se. The pronoun goes BEFORE the verb in normal sentences.'
  where id = v_l2;

  update public.lessons set
    intro = 'Time expressions stitch a daily routine together. Learn how to say "in the morning", "every day", "before" and "after" so your day flows naturally.',
    vocab_items = '[
      {"word":"todos los días","phonetic":"[TOH-dohs lohs DEE-ahs]","english":"every day","example_es":"Trabajo todos los días.","example_en":"I work every day."},
      {"word":"por la mañana","phonetic":"[pohr lah mah-NYAH-nah]","english":"in the morning","example_es":"Estudio por la mañana.","example_en":"I study in the morning."},
      {"word":"antes de","phonetic":"[AHN-tehs deh]","english":"before","example_es":"Desayuno antes de salir.","example_en":"I have breakfast before going out."},
      {"word":"después de","phonetic":"[dehs-PWEHS deh]","english":"after","example_es":"Leo después de cenar.","example_en":"I read after having dinner."},
      {"word":"normalmente","phonetic":"[nohr-mahl-MEHN-teh]","english":"usually","example_es":"Normalmente me acuesto pronto.","example_en":"I usually go to bed early."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Sara","spanish":"¿Qué haces todos los días?","english":"What do you do every day?"},
      {"speaker":"Mateo","spanish":"Por la mañana estudio. Por la tarde trabajo.","english":"In the morning I study. In the afternoon I work."},
      {"speaker":"Sara","spanish":"¿Y antes de dormir?","english":"And before sleeping?"},
      {"speaker":"Mateo","spanish":"Normalmente leo después de cenar.","english":"I usually read after having dinner."}
    ]'::jsonb,
    grammar_note = 'Use por la mañana / por la tarde / por la noche for general parts of the day. Use de la mañana / de la tarde when giving a clock time: a las seis de la mañana = at six in the morning.'
  where id = v_l3;

  update public.lessons set
    intro = 'Listening to a daily routine trains your ear for reflexive verbs and time expressions. Focus on me / te / se and the verb ending.',
    vocab_items = '[
      {"word":"temprano","phonetic":"[tehm-PRAH-noh]","english":"early","example_es":"Me levanto temprano.","example_en":"I get up early."},
      {"word":"tarde","phonetic":"[TAR-deh]","english":"late","example_es":"Llego tarde al trabajo.","example_en":"I arrive late to work."},
      {"word":"empezar","phonetic":"[ehm-peh-SAR]","english":"to start","example_es":"Empiezo a las nueve.","example_en":"I start at nine."},
      {"word":"terminar","phonetic":"[tehr-mee-NAR]","english":"to finish","example_es":"Termino a las cinco.","example_en":"I finish at five."},
      {"word":"a veces","phonetic":"[ah BEH-sehs]","english":"sometimes","example_es":"A veces ceno tarde.","example_en":"Sometimes I have dinner late."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Eva","spanish":"¿Empiezas temprano?","english":"Do you start early?"},
      {"speaker":"Juan","spanish":"Empiezo a las ocho. Termino a las cinco.","english":"I start at eight. I finish at five."},
      {"speaker":"Eva","spanish":"A veces yo trabajo tarde.","english":"Sometimes I work late."},
      {"speaker":"Juan","spanish":"Yo también, pero normalmente no.","english":"Me too, but usually not."}
    ]'::jsonb,
    grammar_note = 'Empezar and terminar are common time-routine verbs. Empezar is stem-changing (e → ie): empiezo, empiezas, empieza. Terminar is regular: termino, terminas, termina.'
  where id = v_l4;

  update public.lessons set
    intro = 'Say a full routine aloud in Spanish. Focus on smooth reflexive pronouns: me LE-van-to, me DU-cho, me ACUES-to.',
    vocab_items = '[
      {"word":"Me levanto a las siete","phonetic":"[meh leh-BAHN-toh ah lahs SYEH-teh]","english":"I get up at seven","example_es":"Me levanto a las siete y desayuno.","example_en":"I get up at seven and have breakfast."},
      {"word":"Me ducho rápido","phonetic":"[meh DOO-choh RAH-pee-doh]","english":"I shower quickly","example_es":"Me ducho rápido y salgo.","example_en":"I shower quickly and leave."},
      {"word":"Voy al trabajo","phonetic":"[BOY ahl trah-BAH-hoh]","english":"I go to work","example_es":"Voy al trabajo en metro.","example_en":"I go to work by subway."},
      {"word":"Vuelvo a casa","phonetic":"[BWEHL-boh ah KAH-sah]","english":"I come home","example_es":"Vuelvo a casa a las seis.","example_en":"I come home at six."},
      {"word":"Me acuesto a las once","phonetic":"[meh ah-KWEHS-toh ah lahs OHN-seh]","english":"I go to bed at eleven","example_es":"Me acuesto a las once cada noche.","example_en":"I go to bed at eleven each night."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Laura","spanish":"Cuéntame tu día.","english":"Tell me about your day."},
      {"speaker":"Carlos","spanish":"Me levanto a las siete, me ducho y desayuno.","english":"I get up at seven, shower and have breakfast."},
      {"speaker":"Laura","spanish":"¿Y luego?","english":"And then?"},
      {"speaker":"Carlos","spanish":"Voy al trabajo y vuelvo a casa a las seis.","english":"I go to work and come home at six."}
    ]'::jsonb,
    grammar_note = 'Volver (to come back) is stem-changing (o → ue): vuelvo, vuelves, vuelve, volvemos, volvéis, vuelven. Acostarse follows the same pattern: me acuesto, te acuestas, se acuesta.'
  where id = v_l5;

  update public.lessons set
    intro = 'Read a short paragraph about Marta''s typical day. Pay attention to reflexive verbs and time markers.',
    vocab_items = '[
      {"word":"primero","phonetic":"[pree-MEH-roh]","english":"first","example_es":"Primero me ducho.","example_en":"First I shower."},
      {"word":"luego","phonetic":"[LWEH-goh]","english":"then","example_es":"Luego desayuno.","example_en":"Then I have breakfast."},
      {"word":"finalmente","phonetic":"[fee-nahl-MEHN-teh]","english":"finally","example_es":"Finalmente me acuesto.","example_en":"Finally I go to bed."},
      {"word":"la rutina","phonetic":"[lah roo-TEE-nah]","english":"the routine","example_es":"Mi rutina es simple.","example_en":"My routine is simple."},
      {"word":"el fin de semana","phonetic":"[ehl feen deh seh-MAH-nah]","english":"the weekend","example_es":"El fin de semana descanso.","example_en":"On the weekend I rest."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Me llamo Marta. Mi rutina es así:","english":"My name is Marta. My routine is like this:"},
      {"speaker":"Texto","spanish":"Primero me despierto a las siete y me ducho.","english":"First I wake up at seven and shower."},
      {"speaker":"Texto","spanish":"Luego desayuno y voy al trabajo en autobús.","english":"Then I have breakfast and go to work by bus."},
      {"speaker":"Texto","spanish":"Finalmente vuelvo a casa, ceno y me acuesto a las once.","english":"Finally I come home, have dinner and go to bed at eleven."}
    ]'::jsonb,
    grammar_note = 'Sequencing words (primero, luego, después, finalmente) make a paragraph flow. They are not verbs — they just introduce the next action. Use them every time you describe a routine.'
  where id = v_l6;

  update public.lessons set
    intro = 'Now write your own daily routine in Spanish. Use reflexive verbs and sequencing words to build a paragraph.',
    vocab_items = '[
      {"word":"escribir","phonetic":"[ehs-kree-BEER]","english":"to write","example_es":"Voy a escribir mi rutina.","example_en":"I''m going to write my routine."},
      {"word":"mi día","phonetic":"[mee DEE-ah]","english":"my day","example_es":"Mi día empieza pronto.","example_en":"My day starts early."},
      {"word":"cada","phonetic":"[KAH-dah]","english":"each / every","example_es":"Cada noche leo.","example_en":"Each night I read."},
      {"word":"después","phonetic":"[dehs-PWEHS]","english":"afterwards","example_es":"Después salgo a correr.","example_en":"Afterwards I go out to run."},
      {"word":"en casa","phonetic":"[ehn KAH-sah]","english":"at home","example_es":"Trabajo en casa.","example_en":"I work at home."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Modelo","spanish":"Me levanto a las ocho y me ducho.","english":"I get up at eight and shower."},
      {"speaker":"Modelo","spanish":"Después desayuno tostadas y café.","english":"Afterwards I have toast and coffee."},
      {"speaker":"Modelo","spanish":"Trabajo en casa cada día.","english":"I work at home every day."},
      {"speaker":"Modelo","spanish":"Por la noche ceno y me acuesto temprano.","english":"At night I have dinner and go to bed early."}
    ]'::jsonb,
    grammar_note = 'When writing, use connectors (y, pero, también, luego) to link short sentences into a paragraph. Spanish word order is usually subject — verb — object, but the subject is often dropped because the verb ending already shows who acts.'
  where id = v_l7;

  -- ============== A2.2 HEALTH & BODY ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Health & Body';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'Build the health vocabulary you need at the doctor: pain words, common illnesses, and the most useful nouns.',
    vocab_items = '[
      {"word":"el dolor","phonetic":"[ehl doh-LOHR]","english":"the pain","example_es":"Tengo un dolor de cabeza.","example_en":"I have a headache."},
      {"word":"la fiebre","phonetic":"[lah FYEH-breh]","english":"the fever","example_es":"Tengo fiebre.","example_en":"I have a fever."},
      {"word":"la gripe","phonetic":"[lah GREE-peh]","english":"the flu","example_es":"Estoy con gripe.","example_en":"I have the flu."},
      {"word":"el médico","phonetic":"[ehl MEH-dee-koh]","english":"the doctor","example_es":"Voy al médico mañana.","example_en":"I go to the doctor tomorrow."},
      {"word":"la pastilla","phonetic":"[lah pahs-TEE-yah]","english":"the pill","example_es":"Tomo una pastilla.","example_en":"I take a pill."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Paciente","spanish":"Buenos días. No me siento bien.","english":"Good morning. I don''t feel well."},
      {"speaker":"Médico","spanish":"¿Qué le duele?","english":"What hurts you?"},
      {"speaker":"Paciente","spanish":"Tengo un dolor de cabeza y fiebre.","english":"I have a headache and a fever."},
      {"speaker":"Médico","spanish":"Tome una pastilla y descanse.","english":"Take a pill and rest."}
    ]'::jsonb,
    grammar_note = 'Use TENER for symptoms: tengo fiebre, tengo gripe, tengo tos. Use ESTAR with adjectives: estoy enfermo, estoy mareado, estoy cansado.'
  where id = v_l1;

  update public.lessons set
    intro = 'The verb DOLER means "to hurt". It works like GUSTAR: me duele + singular part, me duelen + plural parts.',
    vocab_items = '[
      {"word":"me duele","phonetic":"[meh DWEH-leh]","english":"it hurts me","example_es":"Me duele la espalda.","example_en":"My back hurts."},
      {"word":"me duelen","phonetic":"[meh DWEH-lehn]","english":"they hurt me","example_es":"Me duelen los pies.","example_en":"My feet hurt."},
      {"word":"la garganta","phonetic":"[lah gahr-GAHN-tah]","english":"the throat","example_es":"Me duele la garganta.","example_en":"My throat hurts."},
      {"word":"el estómago","phonetic":"[ehl ehs-TOH-mah-goh]","english":"the stomach","example_es":"Me duele el estómago.","example_en":"My stomach hurts."},
      {"word":"sentirse","phonetic":"[sehn-TEER-seh]","english":"to feel","example_es":"Me siento mal.","example_en":"I feel bad."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Amigo","spanish":"¿Cómo te sientes?","english":"How do you feel?"},
      {"speaker":"Tú","spanish":"Me siento fatal. Me duele la cabeza.","english":"I feel terrible. My head hurts."},
      {"speaker":"Amigo","spanish":"¿Y los ojos también?","english":"And your eyes too?"},
      {"speaker":"Tú","spanish":"Sí, me duelen mucho los ojos.","english":"Yes, my eyes really hurt."}
    ]'::jsonb,
    grammar_note = 'DOLER agrees with the body part, not the person: ME duele LA cabeza (1 thing → duele), ME duelen LOS pies (2 things → duelen). The body part takes the article (la, los), never "mi/mis".'
  where id = v_l2;

  update public.lessons set
    intro = 'These are the phrases you will use most when speaking about health: at the pharmacy, with a doctor, or just chatting with friends.',
    vocab_items = '[
      {"word":"Necesito un médico","phonetic":"[neh-seh-SEE-toh oon MEH-dee-koh]","english":"I need a doctor","example_es":"Necesito un médico urgentemente.","example_en":"I need a doctor urgently."},
      {"word":"Estoy resfriado","phonetic":"[ehs-TOY rrehs-fryah-doh]","english":"I have a cold","example_es":"Estoy resfriado desde ayer.","example_en":"I''ve had a cold since yesterday."},
      {"word":"¿Tiene algo para…?","phonetic":"[TYEH-neh AHL-goh PAH-rah]","english":"Do you have something for…?","example_es":"¿Tiene algo para el dolor?","example_en":"Do you have something for pain?"},
      {"word":"Cuídate","phonetic":"[KWEE-dah-teh]","english":"Take care","example_es":"Cuídate mucho.","example_en":"Take good care."},
      {"word":"descansar","phonetic":"[dehs-kahn-SAR]","english":"to rest","example_es":"Necesito descansar.","example_en":"I need to rest."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Cliente","spanish":"Buenas tardes. ¿Tiene algo para el dolor de cabeza?","english":"Good afternoon. Do you have something for a headache?"},
      {"speaker":"Farmacéutico","spanish":"Sí, estas pastillas son muy buenas.","english":"Yes, these pills are very good."},
      {"speaker":"Cliente","spanish":"¿Cuántas tomo al día?","english":"How many do I take a day?"},
      {"speaker":"Farmacéutico","spanish":"Dos, después de comer. Cuídate.","english":"Two, after eating. Take care."}
    ]'::jsonb,
    grammar_note = 'For pharmacy / doctor phrases, use the polite usted form: tome (take), descanse (rest), cuídese. With friends switch to tú: toma, descansa, cuídate.'
  where id = v_l3;

  update public.lessons set
    intro = 'Train your ear for health vocabulary in connected speech: symptoms, instructions and short pharmacy exchanges.',
    vocab_items = '[
      {"word":"tos","phonetic":"[tohs]","english":"cough","example_es":"Tengo mucha tos.","example_en":"I have a bad cough."},
      {"word":"mareado","phonetic":"[mah-reh-AH-doh]","english":"dizzy","example_es":"Estoy mareado.","example_en":"I am dizzy."},
      {"word":"jarabe","phonetic":"[hah-RAH-beh]","english":"syrup","example_es":"Toma este jarabe.","example_en":"Take this syrup."},
      {"word":"receta","phonetic":"[rreh-SEH-tah]","english":"prescription","example_es":"Necesito una receta.","example_en":"I need a prescription."},
      {"word":"farmacia","phonetic":"[fahr-MAH-syah]","english":"pharmacy","example_es":"La farmacia está cerca.","example_en":"The pharmacy is nearby."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Madre","spanish":"¿Tienes tos?","english":"Do you have a cough?"},
      {"speaker":"Niño","spanish":"Sí, y estoy mareado.","english":"Yes, and I''m dizzy."},
      {"speaker":"Madre","spanish":"Vamos a la farmacia a comprar jarabe.","english":"Let''s go to the pharmacy to buy syrup."},
      {"speaker":"Niño","spanish":"Vale, gracias.","english":"OK, thanks."}
    ]'::jsonb,
    grammar_note = 'When listening, focus on the verb TENER + symptom and ESTAR + adjective. These are the two key patterns in health Spanish.'
  where id = v_l4;

  update public.lessons set
    intro = 'Practice saying common health phrases out loud. Use the verb DOLER carefully with the right article.',
    vocab_items = '[
      {"word":"Me duele la cabeza","phonetic":"[meh DWEH-leh lah kah-BEH-sah]","english":"My head hurts","example_es":"Hoy me duele la cabeza.","example_en":"My head hurts today."},
      {"word":"Tengo fiebre","phonetic":"[TEHN-goh FYEH-breh]","english":"I have a fever","example_es":"Tengo fiebre desde ayer.","example_en":"I''ve had a fever since yesterday."},
      {"word":"Necesito una pastilla","phonetic":"[neh-seh-SEE-toh OO-nah pahs-TEE-yah]","english":"I need a pill","example_es":"Necesito una pastilla para el dolor.","example_en":"I need a pill for pain."},
      {"word":"Estoy cansado","phonetic":"[ehs-TOY kahn-SAH-doh]","english":"I am tired","example_es":"Estoy cansado hoy.","example_en":"I am tired today."},
      {"word":"Voy al médico","phonetic":"[BOY ahl MEH-dee-koh]","english":"I go to the doctor","example_es":"Mañana voy al médico.","example_en":"Tomorrow I go to the doctor."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Tú","spanish":"Me duele mucho la espalda.","english":"My back hurts a lot."},
      {"speaker":"Amiga","spanish":"¿Has ido al médico?","english":"Have you gone to the doctor?"},
      {"speaker":"Tú","spanish":"Voy al médico mañana por la mañana.","english":"I go to the doctor tomorrow morning."},
      {"speaker":"Amiga","spanish":"Cuídate, descansa hoy.","english":"Take care, rest today."}
    ]'::jsonb,
    grammar_note = 'When saying ESTAR + adjective, the adjective agrees with the speaker: a woman says estoy cansadA, a man says estoy cansadO.'
  where id = v_l5;

  update public.lessons set
    intro = 'Read about Andrea''s visit to the doctor. Notice how she describes her symptoms and what the doctor says back.',
    vocab_items = '[
      {"word":"el síntoma","phonetic":"[ehl SEEN-toh-mah]","english":"the symptom","example_es":"Tengo varios síntomas.","example_en":"I have several symptoms."},
      {"word":"la consulta","phonetic":"[lah kohn-SOOL-tah]","english":"the appointment","example_es":"Tengo consulta hoy.","example_en":"I have an appointment today."},
      {"word":"recetar","phonetic":"[rreh-seh-TAR]","english":"to prescribe","example_es":"El médico me receta un jarabe.","example_en":"The doctor prescribes me a syrup."},
      {"word":"hasta","phonetic":"[AHS-tah]","english":"until","example_es":"Toma las pastillas hasta el viernes.","example_en":"Take the pills until Friday."},
      {"word":"mejorarse","phonetic":"[meh-hoh-RAR-seh]","english":"to get better","example_es":"Quiero mejorarme pronto.","example_en":"I want to get better soon."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Hoy Andrea tiene consulta porque está enferma.","english":"Today Andrea has an appointment because she is sick."},
      {"speaker":"Texto","spanish":"Le duele la garganta y tiene fiebre.","english":"Her throat hurts and she has a fever."},
      {"speaker":"Texto","spanish":"El médico le receta un jarabe y le dice: descansa.","english":"The doctor prescribes her a syrup and says: rest."},
      {"speaker":"Texto","spanish":"Andrea quiere mejorarse pronto.","english":"Andrea wants to get better soon."}
    ]'::jsonb,
    grammar_note = 'LE is the indirect-object pronoun for "to him/her/you (formal)". El médico LE receta = the doctor prescribes (to) her. It goes before the conjugated verb.'
  where id = v_l6;

  update public.lessons set
    intro = 'Now write about a health situation. Combine TENER + symptom, ESTAR + adjective and DOLER + body part.',
    vocab_items = '[
      {"word":"hace dos días","phonetic":"[AH-seh dohs DEE-ahs]","english":"two days ago","example_es":"Estoy enfermo hace dos días.","example_en":"I''ve been sick for two days."},
      {"word":"todavía","phonetic":"[toh-dah-BEE-ah]","english":"still","example_es":"Todavía me duele la cabeza.","example_en":"My head still hurts."},
      {"word":"un poco","phonetic":"[oon POH-koh]","english":"a little","example_es":"Estoy un poco mareado.","example_en":"I am a little dizzy."},
      {"word":"mejor","phonetic":"[meh-HOHR]","english":"better","example_es":"Hoy me siento mejor.","example_en":"Today I feel better."},
      {"word":"peor","phonetic":"[peh-OHR]","english":"worse","example_es":"Ayer me sentí peor.","example_en":"Yesterday I felt worse."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Modelo","spanish":"Hace dos días que estoy enfermo.","english":"I''ve been sick for two days."},
      {"speaker":"Modelo","spanish":"Me duele la garganta y tengo fiebre.","english":"My throat hurts and I have a fever."},
      {"speaker":"Modelo","spanish":"Tomo pastillas pero todavía me siento mal.","english":"I take pills but I still feel bad."},
      {"speaker":"Modelo","spanish":"Mañana voy al médico para mejorarme.","english":"Tomorrow I go to the doctor to get better."}
    ]'::jsonb,
    grammar_note = 'PARA + infinitive expresses purpose: voy al médico PARA mejorarme = I go to the doctor IN ORDER TO get better. Very useful when writing reasons.'
  where id = v_l7;

  -- ============== A2.3 HOBBIES ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Hobbies';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'Learn the verbs Spanish speakers use to talk about hobbies and free-time activities.',
    vocab_items = '[
      {"word":"leer","phonetic":"[leh-EHR]","english":"to read","example_es":"Me gusta leer novelas.","example_en":"I like to read novels."},
      {"word":"pintar","phonetic":"[peen-TAR]","english":"to paint","example_es":"Pinto los fines de semana.","example_en":"I paint on weekends."},
      {"word":"cocinar","phonetic":"[koh-see-NAR]","english":"to cook","example_es":"Cocino comida italiana.","example_en":"I cook Italian food."},
      {"word":"viajar","phonetic":"[byah-HAR]","english":"to travel","example_es":"Me encanta viajar.","example_en":"I love to travel."},
      {"word":"tocar","phonetic":"[toh-KAR]","english":"to play (an instrument)","example_es":"Toco la guitarra.","example_en":"I play the guitar."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Eva","spanish":"¿Qué te gusta hacer?","english":"What do you like to do?"},
      {"speaker":"Tomás","spanish":"Me gusta leer y cocinar.","english":"I like to read and cook."},
      {"speaker":"Eva","spanish":"¿Y los fines de semana?","english":"And on weekends?"},
      {"speaker":"Tomás","spanish":"Pinto o toco la guitarra.","english":"I paint or play the guitar."}
    ]'::jsonb,
    grammar_note = 'TOCAR is used for musical instruments: toco el piano. For sports use JUGAR A: juego al tenis. Don''t mix them up — a Spanish speaker never "plays" the guitar with jugar.'
  where id = v_l1;

  update public.lessons set
    intro = 'Use ME GUSTA + infinitive to say "I like to…". This is the core hobby grammar.',
    vocab_items = '[
      {"word":"me gusta + inf.","phonetic":"[meh GOOS-tah]","english":"I like to…","example_es":"Me gusta nadar.","example_en":"I like to swim."},
      {"word":"me encanta","phonetic":"[meh ehn-KAHN-tah]","english":"I love…","example_es":"Me encanta cocinar.","example_en":"I love to cook."},
      {"word":"no me gusta","phonetic":"[noh meh GOOS-tah]","english":"I don''t like","example_es":"No me gusta correr.","example_en":"I don''t like to run."},
      {"word":"prefiero","phonetic":"[preh-FYEH-roh]","english":"I prefer","example_es":"Prefiero leer.","example_en":"I prefer to read."},
      {"word":"detesto","phonetic":"[deh-TEHS-toh]","english":"I hate","example_es":"Detesto bailar.","example_en":"I hate to dance."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Ana","spanish":"¿Te gusta bailar?","english":"Do you like to dance?"},
      {"speaker":"Luis","spanish":"No me gusta. Prefiero cantar.","english":"I don''t like it. I prefer to sing."},
      {"speaker":"Ana","spanish":"¿Te gusta más leer o ver películas?","english":"Do you prefer reading or watching movies?"},
      {"speaker":"Luis","spanish":"Me encanta leer.","english":"I love to read."}
    ]'::jsonb,
    grammar_note = 'GUSTAR works backward in Spanish: ME gusta LEER literally means "reading is pleasing TO me". After me gusta, use the INFINITIVE (the -ar / -er / -ir form), not the conjugated verb.'
  where id = v_l2;

  update public.lessons set
    intro = 'Common phrases for chatting about hobbies, free time and weekends.',
    vocab_items = '[
      {"word":"en mi tiempo libre","phonetic":"[ehn mee TYEHM-poh LEE-breh]","english":"in my free time","example_es":"En mi tiempo libre leo.","example_en":"In my free time I read."},
      {"word":"los fines de semana","phonetic":"[lohs FEE-nehs deh seh-MAH-nah]","english":"on weekends","example_es":"Los fines de semana nado.","example_en":"On weekends I swim."},
      {"word":"¿Qué haces?","phonetic":"[keh AH-sehs]","english":"What do you do?","example_es":"¿Qué haces hoy?","example_en":"What are you doing today?"},
      {"word":"con mis amigos","phonetic":"[kohn mees ah-MEE-gohs]","english":"with my friends","example_es":"Salgo con mis amigos.","example_en":"I go out with my friends."},
      {"word":"al aire libre","phonetic":"[ahl AH-ee-reh LEE-breh]","english":"outdoors","example_es":"Me gusta el deporte al aire libre.","example_en":"I like outdoor sport."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Mia","spanish":"¿Qué haces los fines de semana?","english":"What do you do on weekends?"},
      {"speaker":"Pablo","spanish":"En mi tiempo libre salgo con mis amigos.","english":"In my free time I go out with my friends."},
      {"speaker":"Mia","spanish":"¿Adónde vais?","english":"Where do you (pl.) go?"},
      {"speaker":"Pablo","spanish":"Al cine, o hacemos deporte al aire libre.","english":"To the cinema, or we play sport outdoors."}
    ]'::jsonb,
    grammar_note = 'SALIR (to go out) is irregular only in yo: salgo, sales, sale, salimos, salís, salen. Salir CON = go out with. Salir A = go out to (a place).'
  where id = v_l3;

  update public.lessons set
    intro = 'Listening practice: native speakers describe their hobbies and weekend plans.',
    vocab_items = '[
      {"word":"jugar","phonetic":"[hoo-GAR]","english":"to play","example_es":"Juego al baloncesto.","example_en":"I play basketball."},
      {"word":"correr","phonetic":"[koh-RREHR]","english":"to run","example_es":"Corro en el parque.","example_en":"I run in the park."},
      {"word":"montar","phonetic":"[mohn-TAR]","english":"to ride","example_es":"Monto en bicicleta.","example_en":"I ride a bicycle."},
      {"word":"escuchar música","phonetic":"[ehs-koo-CHAR MOO-see-kah]","english":"to listen to music","example_es":"Escucho música clásica.","example_en":"I listen to classical music."},
      {"word":"hacer deporte","phonetic":"[ah-SEHR deh-POHR-teh]","english":"to do sport","example_es":"Hago deporte tres veces a la semana.","example_en":"I do sport three times a week."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Marta","spanish":"¿Haces deporte?","english":"Do you do sport?"},
      {"speaker":"Jorge","spanish":"Corro y monto en bicicleta.","english":"I run and ride a bike."},
      {"speaker":"Marta","spanish":"¿También juegas al fútbol?","english":"Do you also play football?"},
      {"speaker":"Jorge","spanish":"No, prefiero escuchar música.","english":"No, I prefer to listen to music."}
    ]'::jsonb,
    grammar_note = 'JUGAR is irregular (u → ue): juego, juegas, juega, jugamos, jugáis, juegan. Always say JUGAR AL + sport: jugar al fútbol, jugar al tenis.'
  where id = v_l4;

  update public.lessons set
    intro = 'Practice saying your hobbies out loud. Combine me gusta with the infinitive.',
    vocab_items = '[
      {"word":"Me gusta la música","phonetic":"[meh GOOS-tah lah MOO-see-kah]","english":"I like music","example_es":"Me gusta la música pop.","example_en":"I like pop music."},
      {"word":"Toco la guitarra","phonetic":"[TOH-koh lah gee-TAH-rrah]","english":"I play the guitar","example_es":"Toco la guitarra desde niño.","example_en":"I''ve played guitar since I was a kid."},
      {"word":"Juego al fútbol","phonetic":"[HWEH-goh ahl FOOT-bohl]","english":"I play football","example_es":"Juego al fútbol los domingos.","example_en":"I play football on Sundays."},
      {"word":"Veo películas","phonetic":"[BEH-oh peh-LEE-koo-lahs]","english":"I watch films","example_es":"Veo películas españolas.","example_en":"I watch Spanish films."},
      {"word":"Me encanta cocinar","phonetic":"[meh ehn-KAHN-tah koh-see-NAR]","english":"I love to cook","example_es":"Me encanta cocinar para mi familia.","example_en":"I love to cook for my family."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Tú","spanish":"En mi tiempo libre toco la guitarra.","english":"In my free time I play the guitar."},
      {"speaker":"Amiga","spanish":"¡Qué bien! ¿Tocas también el piano?","english":"How nice! Do you play the piano too?"},
      {"speaker":"Tú","spanish":"No, pero me encanta cantar.","english":"No, but I love to sing."},
      {"speaker":"Amiga","spanish":"Yo prefiero ver películas.","english":"I prefer to watch films."}
    ]'::jsonb,
    grammar_note = 'When you list multiple verbs in sequence, you can keep them all as infinitives: Me gusta LEER, COCINAR y VIAJAR.'
  where id = v_l5;

  update public.lessons set
    intro = 'Read a short profile of someone''s hobbies. Then you''ll write your own.',
    vocab_items = '[
      {"word":"el hobby","phonetic":"[ehl HOH-bee]","english":"the hobby","example_es":"Mi hobby es la fotografía.","example_en":"My hobby is photography."},
      {"word":"la fotografía","phonetic":"[lah foh-toh-grah-FEE-ah]","english":"photography","example_es":"Estudio fotografía.","example_en":"I study photography."},
      {"word":"sobre todo","phonetic":"[SOH-breh TOH-doh]","english":"above all","example_es":"Me gusta sobre todo el cine.","example_en":"I like cinema above all."},
      {"word":"además","phonetic":"[ah-deh-MAHS]","english":"besides","example_es":"Además toco el piano.","example_en":"Besides, I play the piano."},
      {"word":"interesante","phonetic":"[een-teh-reh-SAHN-teh]","english":"interesting","example_es":"Es muy interesante.","example_en":"It is very interesting."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Me llamo Diego y tengo veintiocho años.","english":"My name is Diego and I am twenty-eight."},
      {"speaker":"Texto","spanish":"En mi tiempo libre me gusta sobre todo la fotografía.","english":"In my free time I like photography above all."},
      {"speaker":"Texto","spanish":"Además toco la guitarra los fines de semana.","english":"Besides, I play guitar on weekends."},
      {"speaker":"Texto","spanish":"Pienso que los hobbies son muy importantes.","english":"I think hobbies are very important."}
    ]'::jsonb,
    grammar_note = 'Sobre todo and además are very common connectors for opinion and listing. Use them to make a paragraph feel like real Spanish writing.'
  where id = v_l6;

  update public.lessons set
    intro = 'Write three sentences about your hobbies in Spanish. Use connectors like además and sobre todo.',
    vocab_items = '[
      {"word":"sobre","phonetic":"[SOH-breh]","english":"about","example_es":"Escribo sobre mis hobbies.","example_en":"I write about my hobbies."},
      {"word":"interesarse","phonetic":"[een-teh-reh-SAR-seh]","english":"to be interested","example_es":"Me intereso por la música.","example_en":"I''m interested in music."},
      {"word":"durante","phonetic":"[doo-RAHN-teh]","english":"during","example_es":"Durante las vacaciones viajo.","example_en":"During holidays I travel."},
      {"word":"cuando puedo","phonetic":"[KWAHN-doh PWEH-doh]","english":"when I can","example_es":"Pinto cuando puedo.","example_en":"I paint when I can."},
      {"word":"mucho","phonetic":"[MOO-choh]","english":"a lot","example_es":"Viajo mucho.","example_en":"I travel a lot."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Modelo","spanish":"En mi tiempo libre me encanta leer.","english":"In my free time I love to read."},
      {"speaker":"Modelo","spanish":"Además toco el piano cuando puedo.","english":"Besides, I play the piano when I can."},
      {"speaker":"Modelo","spanish":"Sobre todo me gusta viajar durante las vacaciones.","english":"Above all I like to travel during holidays."},
      {"speaker":"Modelo","spanish":"No me gusta hacer deporte, pero veo películas.","english":"I don''t like to do sport, but I watch films."}
    ]'::jsonb,
    grammar_note = 'PERO joins two contrasting ideas. SINO is for "but rather" after a negative: No me gusta correr SINO nadar = I don''t like to run BUT RATHER swim.'
  where id = v_l7;

  -- ============== A2.4 WORK & JOBS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Work & Jobs';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'Learn the most common Spanish job names. Most have a masculine and feminine form.',
    vocab_items = '[
      {"word":"profesor / profesora","phonetic":"[proh-feh-SOHR / proh-feh-SOH-rah]","english":"teacher","example_es":"Mi madre es profesora.","example_en":"My mother is a teacher."},
      {"word":"médico / médica","phonetic":"[MEH-dee-koh / MEH-dee-kah]","english":"doctor","example_es":"Carlos es médico.","example_en":"Carlos is a doctor."},
      {"word":"ingeniero / ingeniera","phonetic":"[een-heh-NYEH-roh / een-heh-NYEH-rah]","english":"engineer","example_es":"Soy ingeniera.","example_en":"I am an engineer."},
      {"word":"camarero / camarera","phonetic":"[kah-mah-REH-roh / kah-mah-REH-rah]","english":"waiter / waitress","example_es":"Trabajo de camarero.","example_en":"I work as a waiter."},
      {"word":"jefe / jefa","phonetic":"[HEH-feh / HEH-fah]","english":"boss","example_es":"Mi jefe es simpático.","example_en":"My boss is nice."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Sara","spanish":"¿En qué trabajas?","english":"What do you do for work?"},
      {"speaker":"Pedro","spanish":"Soy ingeniero.","english":"I am an engineer."},
      {"speaker":"Sara","spanish":"¿Y tu hermana?","english":"And your sister?"},
      {"speaker":"Pedro","spanish":"Mi hermana es médica.","english":"My sister is a doctor."}
    ]'::jsonb,
    grammar_note = 'When stating a profession with SER, NEVER use the article "un / una": Soy profesor (NOT "Soy un profesor"). But you do use the article when describing: Soy UN profesor BUENO = I am a good teacher.'
  where id = v_l1;

  update public.lessons set
    intro = 'TRABAJAR (to work) is the main verb here. Combine it with the right preposition: trabajar EN (a place), trabajar DE / COMO (a role).',
    vocab_items = '[
      {"word":"trabajar","phonetic":"[trah-bah-HAR]","english":"to work","example_es":"Trabajo en una oficina.","example_en":"I work in an office."},
      {"word":"trabajar de","phonetic":"[trah-bah-HAR deh]","english":"to work as","example_es":"Trabajo de profesor.","example_en":"I work as a teacher."},
      {"word":"la oficina","phonetic":"[lah oh-fee-SEE-nah]","english":"the office","example_es":"Estoy en la oficina.","example_en":"I''m at the office."},
      {"word":"la empresa","phonetic":"[lah ehm-PREH-sah]","english":"the company","example_es":"Es una empresa grande.","example_en":"It''s a big company."},
      {"word":"el horario","phonetic":"[ehl oh-RAH-ryoh]","english":"the schedule","example_es":"Mi horario es de 9 a 5.","example_en":"My schedule is from 9 to 5."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Eva","spanish":"¿Dónde trabajas?","english":"Where do you work?"},
      {"speaker":"Mario","spanish":"Trabajo en una empresa de tecnología.","english":"I work in a tech company."},
      {"speaker":"Eva","spanish":"¿Y de qué?","english":"And as what?"},
      {"speaker":"Mario","spanish":"De ingeniero. Mi horario es de 9 a 6.","english":"As an engineer. My schedule is from 9 to 6."}
    ]'::jsonb,
    grammar_note = 'TRABAJAR EN = work IN a place. TRABAJAR DE = work AS a role. TRABAJAR CON = work WITH (people / tools).'
  where id = v_l2;

  update public.lessons set
    intro = 'These workplace phrases will get you through a meeting, a phone call or a coffee with colleagues.',
    vocab_items = '[
      {"word":"la reunión","phonetic":"[lah rreh-oo-NYOHN]","english":"the meeting","example_es":"Tengo una reunión a las tres.","example_en":"I have a meeting at three."},
      {"word":"¿Puedes…?","phonetic":"[PWEH-dehs]","english":"Can you…?","example_es":"¿Puedes enviar el correo?","example_en":"Can you send the email?"},
      {"word":"el correo","phonetic":"[ehl koh-RREH-oh]","english":"the email","example_es":"Recibo muchos correos.","example_en":"I get many emails."},
      {"word":"enviar","phonetic":"[ehn-byahr]","english":"to send","example_es":"Envío un mensaje.","example_en":"I send a message."},
      {"word":"el cliente","phonetic":"[ehl klee-EHN-teh]","english":"the client","example_es":"El cliente está esperando.","example_en":"The client is waiting."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Jefa","spanish":"¿Puedes enviar el correo al cliente?","english":"Can you send the email to the client?"},
      {"speaker":"Tú","spanish":"Sí, lo envío ahora.","english":"Yes, I''ll send it now."},
      {"speaker":"Jefa","spanish":"Gracias. Tenemos una reunión a las cuatro.","english":"Thanks. We have a meeting at four."},
      {"speaker":"Tú","spanish":"Perfecto, hasta luego.","english":"Perfect, see you later."}
    ]'::jsonb,
    grammar_note = 'LO / LA replace masculine / feminine direct objects: el correo → LO envío (I send IT). la carta → LA escribo (I write IT). The pronoun goes BEFORE the conjugated verb.'
  where id = v_l3;

  update public.lessons set
    intro = 'Listen to short workplace exchanges and pick out the key job vocabulary.',
    vocab_items = '[
      {"word":"el sueldo","phonetic":"[ehl SWEHL-doh]","english":"the salary","example_es":"Mi sueldo es bueno.","example_en":"My salary is good."},
      {"word":"el contrato","phonetic":"[ehl kohn-TRAH-toh]","english":"the contract","example_es":"Firmo el contrato hoy.","example_en":"I sign the contract today."},
      {"word":"a tiempo completo","phonetic":"[ah TYEHM-poh kohm-PLEH-toh]","english":"full time","example_es":"Trabajo a tiempo completo.","example_en":"I work full time."},
      {"word":"a tiempo parcial","phonetic":"[ah TYEHM-poh pahr-SYAHL]","english":"part time","example_es":"Estudio y trabajo a tiempo parcial.","example_en":"I study and work part time."},
      {"word":"vacaciones","phonetic":"[bah-kah-SYOH-nehs]","english":"holidays","example_es":"Tengo veinte días de vacaciones.","example_en":"I have twenty days of holiday."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Lucía","spanish":"¿Trabajas a tiempo completo?","english":"Do you work full time?"},
      {"speaker":"Iván","spanish":"Sí, y tengo veinte días de vacaciones.","english":"Yes, and I have twenty days of holiday."},
      {"speaker":"Lucía","spanish":"¿Es buen sueldo?","english":"Is it a good salary?"},
      {"speaker":"Iván","spanish":"Sí, pero el horario es largo.","english":"Yes, but the hours are long."}
    ]'::jsonb,
    grammar_note = 'Spanish drops the article in BUEN sueldo (good salary) when the adjective comes before. Bueno → buen / Malo → mal before masculine singular nouns.'
  where id = v_l4;

  update public.lessons set
    intro = 'Say the most useful work phrases out loud. Get comfortable introducing yourself professionally.',
    vocab_items = '[
      {"word":"Soy profesora","phonetic":"[SOY proh-feh-SOH-rah]","english":"I am a teacher","example_es":"Soy profesora de inglés.","example_en":"I am an English teacher."},
      {"word":"Trabajo en una oficina","phonetic":"[trah-BAH-hoh ehn OO-nah oh-fee-SEE-nah]","english":"I work in an office","example_es":"Trabajo en una oficina pequeña.","example_en":"I work in a small office."},
      {"word":"Mi jefe se llama Pedro","phonetic":"[mee HEH-feh seh YAH-mah PEH-droh]","english":"My boss is named Pedro","example_es":"Mi jefe se llama Pedro y es muy simpático.","example_en":"My boss is named Pedro and is very nice."},
      {"word":"Tengo una reunión a las tres","phonetic":"[TEHN-goh OO-nah rreh-oo-NYOHN ah lahs trehs]","english":"I have a meeting at three","example_es":"Tengo una reunión a las tres con el cliente.","example_en":"I have a meeting at three with the client."},
      {"word":"Termino a las seis","phonetic":"[tehr-MEE-noh ah lahs SEH-ees]","english":"I finish at six","example_es":"Normalmente termino a las seis.","example_en":"I normally finish at six."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Tú","spanish":"Soy ingeniero. Trabajo en una empresa grande.","english":"I am an engineer. I work at a big company."},
      {"speaker":"Amigo","spanish":"¿Y cómo es tu jefa?","english":"And what is your boss like?"},
      {"speaker":"Tú","spanish":"Mi jefa es muy simpática.","english":"My boss is very nice."},
      {"speaker":"Amigo","spanish":"¿A qué hora terminas?","english":"What time do you finish?"},
      {"speaker":"Tú","spanish":"Termino a las seis.","english":"I finish at six."}
    ]'::jsonb,
    grammar_note = 'When describing a person, use SER + adjective: mi jefa ES simpática. The adjective agrees in gender and number with the subject.'
  where id = v_l5;

  update public.lessons set
    intro = 'Read a short job profile. Notice the structure: name → role → place → schedule → feeling about the job.',
    vocab_items = '[
      {"word":"el puesto","phonetic":"[ehl PWEHS-toh]","english":"the position","example_es":"Tengo un puesto nuevo.","example_en":"I have a new position."},
      {"word":"el departamento","phonetic":"[ehl deh-pahr-tah-MEHN-toh]","english":"the department","example_es":"Trabajo en el departamento de ventas.","example_en":"I work in the sales department."},
      {"word":"responsable","phonetic":"[rrehs-pohn-SAH-bleh]","english":"responsible","example_es":"Soy responsable del equipo.","example_en":"I am in charge of the team."},
      {"word":"contento","phonetic":"[kohn-TEHN-toh]","english":"happy","example_es":"Estoy contento con mi trabajo.","example_en":"I am happy with my job."},
      {"word":"cambiar","phonetic":"[kahm-BYAHR]","english":"to change","example_es":"Quiero cambiar de trabajo.","example_en":"I want to change jobs."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Me llamo Laura y trabajo en una empresa de moda.","english":"My name is Laura and I work at a fashion company."},
      {"speaker":"Texto","spanish":"Mi puesto es de diseñadora y soy responsable del equipo.","english":"My position is designer and I am in charge of the team."},
      {"speaker":"Texto","spanish":"Trabajo a tiempo completo, de nueve a seis.","english":"I work full time, from nine to six."},
      {"speaker":"Texto","spanish":"Estoy contenta con mi trabajo.","english":"I am happy with my job."}
    ]'::jsonb,
    grammar_note = 'Estoy contento / contenta agrees with the speaker. SER + happy is not natural in Spanish — happiness is a state → use ESTAR.'
  where id = v_l6;

  update public.lessons set
    intro = 'Now write four sentences about your real or imaginary job in Spanish.',
    vocab_items = '[
      {"word":"buscar","phonetic":"[boos-KAR]","english":"to look for","example_es":"Busco trabajo.","example_en":"I''m looking for work."},
      {"word":"el currículum","phonetic":"[ehl koo-RREE-koo-loom]","english":"the resumé","example_es":"Envío mi currículum.","example_en":"I send my resumé."},
      {"word":"la entrevista","phonetic":"[lah ehn-treh-BEES-tah]","english":"the interview","example_es":"Tengo una entrevista mañana.","example_en":"I have an interview tomorrow."},
      {"word":"el ambiente","phonetic":"[ehl ahm-BYEHN-teh]","english":"the atmosphere","example_es":"El ambiente es bueno.","example_en":"The atmosphere is good."},
      {"word":"el / la colega","phonetic":"[ehl/lah koh-LEH-gah]","english":"colleague","example_es":"Mis colegas son simpáticos.","example_en":"My colleagues are nice."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Modelo","spanish":"Soy programadora y trabajo en una empresa de software.","english":"I am a programmer and I work at a software company."},
      {"speaker":"Modelo","spanish":"Mi horario es de nueve a cinco.","english":"My schedule is from nine to five."},
      {"speaker":"Modelo","spanish":"Mis colegas son simpáticos y el ambiente es bueno.","english":"My colleagues are nice and the atmosphere is good."},
      {"speaker":"Modelo","spanish":"Estoy contenta con mi trabajo.","english":"I am happy with my job."}
    ]'::jsonb,
    grammar_note = 'When ending an opinion paragraph, ESTOY CONTENTO/A CON + noun is a high-frequency, natural closing in Spanish.'
  where id = v_l7;

  -- ============== A2.5 DIRECTIONS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Directions';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'Learn the core direction words. Right, left, straight, corner, traffic light — these few words unlock every Spanish map.',
    vocab_items = '[
      {"word":"a la derecha","phonetic":"[ah lah deh-REH-chah]","english":"to the right","example_es":"Gira a la derecha.","example_en":"Turn right."},
      {"word":"a la izquierda","phonetic":"[ah lah ees-KYEHR-dah]","english":"to the left","example_es":"Gira a la izquierda.","example_en":"Turn left."},
      {"word":"todo recto","phonetic":"[TOH-doh RREHK-toh]","english":"straight ahead","example_es":"Sigue todo recto.","example_en":"Keep going straight."},
      {"word":"la esquina","phonetic":"[lah ehs-KEE-nah]","english":"the corner","example_es":"En la esquina hay un banco.","example_en":"There''s a bank on the corner."},
      {"word":"el semáforo","phonetic":"[ehl seh-MAH-foh-roh]","english":"the traffic light","example_es":"En el semáforo, gira.","example_en":"At the traffic light, turn."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Turista","spanish":"Perdón, ¿dónde está el banco?","english":"Excuse me, where is the bank?"},
      {"speaker":"Local","spanish":"Sigue todo recto.","english":"Keep going straight."},
      {"speaker":"Turista","spanish":"¿Y luego?","english":"And then?"},
      {"speaker":"Local","spanish":"En el semáforo, gira a la derecha.","english":"At the traffic light, turn right."}
    ]'::jsonb,
    grammar_note = 'When giving directions to a stranger, use the polite USTED command form: gire, siga, cruce. With friends use the tú form: gira, sigue, cruza.'
  where id = v_l1;

  update public.lessons set
    intro = 'Learn the prepositions of place: cerca, lejos, al lado de, enfrente de. Combine with a noun to locate anything.',
    vocab_items = '[
      {"word":"cerca de","phonetic":"[SEHR-kah deh]","english":"near","example_es":"Vivo cerca del parque.","example_en":"I live near the park."},
      {"word":"lejos de","phonetic":"[LEH-hohs deh]","english":"far from","example_es":"Está lejos de aquí.","example_en":"It''s far from here."},
      {"word":"al lado de","phonetic":"[ahl LAH-doh deh]","english":"next to","example_es":"Al lado del banco hay un café.","example_en":"Next to the bank there''s a café."},
      {"word":"enfrente de","phonetic":"[ehn-FREHN-teh deh]","english":"across from","example_es":"Enfrente de la iglesia.","example_en":"Across from the church."},
      {"word":"entre","phonetic":"[EHN-treh]","english":"between","example_es":"Entre el banco y el café.","example_en":"Between the bank and the café."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Ana","spanish":"¿Dónde está tu casa?","english":"Where is your house?"},
      {"speaker":"Luis","spanish":"Cerca del parque, al lado del supermercado.","english":"Near the park, next to the supermarket."},
      {"speaker":"Ana","spanish":"¿Lejos del centro?","english":"Far from the centre?"},
      {"speaker":"Luis","spanish":"No, está entre el centro y la estación.","english":"No, it''s between the centre and the station."}
    ]'::jsonb,
    grammar_note = 'DE + EL contracts to DEL: cerca DE EL parque → cerca DEL parque. This is one of only two contractions in Spanish (the other is A + EL = AL).'
  where id = v_l2;

  update public.lessons set
    intro = 'Common phrases for asking and giving directions, with verbs like seguir, girar, cruzar.',
    vocab_items = '[
      {"word":"¿Cómo llego a…?","phonetic":"[KOH-moh YEH-goh ah]","english":"How do I get to…?","example_es":"¿Cómo llego a la estación?","example_en":"How do I get to the station?"},
      {"word":"Sigue","phonetic":"[SEE-geh]","english":"Keep going","example_es":"Sigue todo recto.","example_en":"Keep going straight."},
      {"word":"Cruza","phonetic":"[KROO-sah]","english":"Cross","example_es":"Cruza la calle.","example_en":"Cross the street."},
      {"word":"a unos minutos","phonetic":"[ah OO-nohs mee-NOO-tohs]","english":"a few minutes away","example_es":"Está a unos minutos a pie.","example_en":"It''s a few minutes on foot."},
      {"word":"a pie","phonetic":"[ah PYEH]","english":"on foot","example_es":"Vamos a pie.","example_en":"Let''s walk."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Turista","spanish":"¿Cómo llego a la estación?","english":"How do I get to the station?"},
      {"speaker":"Local","spanish":"Sigue todo recto y cruza la plaza.","english":"Keep going straight and cross the square."},
      {"speaker":"Turista","spanish":"¿Está lejos?","english":"Is it far?"},
      {"speaker":"Local","spanish":"No, a unos cinco minutos a pie.","english":"No, about five minutes on foot."}
    ]'::jsonb,
    grammar_note = 'A UNOS / UNAS + number = roughly / about that many. A unos cinco minutos = about five minutes. A unas dos manzanas = about two blocks.'
  where id = v_l3;

  update public.lessons set
    intro = 'Listening to directions is the moment you find out if you''re really following Spanish. Focus on imperatives and prepositions.',
    vocab_items = '[
      {"word":"la calle","phonetic":"[lah KAH-yeh]","english":"the street","example_es":"La calle Mayor está cerca.","example_en":"Mayor Street is nearby."},
      {"word":"la avenida","phonetic":"[lah ah-beh-NEE-dah]","english":"the avenue","example_es":"En la avenida grande.","example_en":"On the big avenue."},
      {"word":"el cruce","phonetic":"[ehl KROO-seh]","english":"the crossing","example_es":"En el cruce, gira.","example_en":"At the crossing, turn."},
      {"word":"la rotonda","phonetic":"[lah rroh-TOHN-dah]","english":"the roundabout","example_es":"En la rotonda toma la primera salida.","example_en":"At the roundabout take the first exit."},
      {"word":"la salida","phonetic":"[lah sah-LEE-dah]","english":"the exit","example_es":"Toma la segunda salida.","example_en":"Take the second exit."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Voz","spanish":"En la rotonda, toma la primera salida.","english":"At the roundabout, take the first exit."},
      {"speaker":"Voz","spanish":"Sigue por la avenida principal.","english":"Keep going on the main avenue."},
      {"speaker":"Voz","spanish":"En el cruce, gira a la izquierda.","english":"At the crossing, turn left."},
      {"speaker":"Voz","spanish":"Tu destino está a la derecha.","english":"Your destination is on the right."}
    ]'::jsonb,
    grammar_note = 'TOMAR (to take) is also used for transport and routes: tomar el autobús (take the bus), tomar la primera salida (take the first exit).'
  where id = v_l4;

  update public.lessons set
    intro = 'Practice asking for and giving directions out loud. Be polite — start with "perdone" or "perdona".',
    vocab_items = '[
      {"word":"Perdone","phonetic":"[pehr-DOH-neh]","english":"Excuse me (formal)","example_es":"Perdone, ¿el banco?","example_en":"Excuse me, the bank?"},
      {"word":"¿Dónde está…?","phonetic":"[DOHN-deh ehs-TAH]","english":"Where is…?","example_es":"¿Dónde está la farmacia?","example_en":"Where is the pharmacy?"},
      {"word":"Está lejos","phonetic":"[ehs-TAH LEH-hohs]","english":"It''s far","example_es":"Está bastante lejos.","example_en":"It''s pretty far."},
      {"word":"Está aquí mismo","phonetic":"[ehs-TAH ah-KEE MEES-moh]","english":"It''s right here","example_es":"Está aquí mismo, a la derecha.","example_en":"It''s right here, on the right."},
      {"word":"Gracias","phonetic":"[GRAH-syahs]","english":"Thank you","example_es":"Muchas gracias, muy amable.","example_en":"Thanks very much, very kind."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Tú","spanish":"Perdone, ¿dónde está la farmacia?","english":"Excuse me, where is the pharmacy?"},
      {"speaker":"Señora","spanish":"Está aquí mismo, a la derecha.","english":"It''s right here, on the right."},
      {"speaker":"Tú","spanish":"Muchas gracias.","english":"Thanks very much."},
      {"speaker":"Señora","spanish":"De nada.","english":"You''re welcome."}
    ]'::jsonb,
    grammar_note = 'Use ESTAR (not ser) for location: la farmacia ESTÁ aquí. Location is a position, not an identity, so it takes ESTAR.'
  where id = v_l5;

  update public.lessons set
    intro = 'Read a short paragraph with directions from a metro to a museum. Map out the route in your head.',
    vocab_items = '[
      {"word":"el museo","phonetic":"[ehl moo-SEH-oh]","english":"the museum","example_es":"El museo es famoso.","example_en":"The museum is famous."},
      {"word":"la salida del metro","phonetic":"[lah sah-LEE-dah dehl MEH-troh]","english":"the metro exit","example_es":"Toma la salida del metro.","example_en":"Take the metro exit."},
      {"word":"manzana","phonetic":"[mahn-SAH-nah]","english":"block","example_es":"Camina dos manzanas.","example_en":"Walk two blocks."},
      {"word":"verás","phonetic":"[beh-RAHS]","english":"you''ll see","example_es":"Verás un edificio amarillo.","example_en":"You''ll see a yellow building."},
      {"word":"el edificio","phonetic":"[ehl eh-dee-FEE-syoh]","english":"the building","example_es":"Es el edificio grande.","example_en":"It''s the big building."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Para llegar al museo, sal de la salida sur del metro.","english":"To get to the museum, take the south metro exit."},
      {"speaker":"Texto","spanish":"Camina dos manzanas todo recto por la calle Mayor.","english":"Walk two blocks straight on Mayor Street."},
      {"speaker":"Texto","spanish":"En el cruce con la avenida del Sol, gira a la derecha.","english":"At the crossing with Sol Avenue, turn right."},
      {"speaker":"Texto","spanish":"Verás el museo enfrente del parque.","english":"You''ll see the museum across from the park."}
    ]'::jsonb,
    grammar_note = 'PARA + infinitive is used for purpose: PARA LLEGAR al museo = in order to get to the museum. It''s the most common way to express "to / in order to" in Spanish.'
  where id = v_l6;

  update public.lessons set
    intro = 'Now write three sentences of directions from your home to a familiar place. Use giro / sigo / cruzo (yo form) or commands.',
    vocab_items = '[
      {"word":"camino","phonetic":"[kah-MEE-noh]","english":"I walk","example_es":"Camino diez minutos.","example_en":"I walk ten minutes."},
      {"word":"giro","phonetic":"[HEE-roh]","english":"I turn","example_es":"Giro a la derecha.","example_en":"I turn right."},
      {"word":"sigo","phonetic":"[SEE-goh]","english":"I keep going","example_es":"Sigo recto.","example_en":"I keep going straight."},
      {"word":"cruzo","phonetic":"[KROO-soh]","english":"I cross","example_es":"Cruzo el puente.","example_en":"I cross the bridge."},
      {"word":"llego","phonetic":"[YEH-goh]","english":"I arrive","example_es":"Llego al parque.","example_en":"I arrive at the park."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Modelo","spanish":"Salgo de casa y camino diez minutos.","english":"I leave home and walk ten minutes."},
      {"speaker":"Modelo","spanish":"Sigo recto por la calle del Sol.","english":"I keep going straight on Sol Street."},
      {"speaker":"Modelo","spanish":"En la esquina giro a la derecha.","english":"At the corner I turn right."},
      {"speaker":"Modelo","spanish":"Llego al parque enfrente del museo.","english":"I arrive at the park across from the museum."}
    ]'::jsonb,
    grammar_note = 'SEGUIR (to keep going) is irregular: sigo, sigues, sigue, seguimos, seguís, siguen. Notice the YO form (sigo) drops the U.'
  where id = v_l7;

  -- ============== A2.6 FEELINGS & EMOTIONS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Feelings & Emotions';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'Learn the core feeling adjectives so you can talk about your mood in Spanish.',
    vocab_items = '[
      {"word":"contento / contenta","phonetic":"[kohn-TEHN-toh]","english":"happy","example_es":"Estoy contenta hoy.","example_en":"I am happy today."},
      {"word":"triste","phonetic":"[TREES-teh]","english":"sad","example_es":"Está triste.","example_en":"He/she is sad."},
      {"word":"enfadado / enfadada","phonetic":"[ehn-fah-DAH-doh]","english":"angry","example_es":"Estoy muy enfadado.","example_en":"I am very angry."},
      {"word":"nervioso / nerviosa","phonetic":"[nehr-BYOH-soh]","english":"nervous","example_es":"Estoy nervioso por el examen.","example_en":"I am nervous about the exam."},
      {"word":"cansado / cansada","phonetic":"[kahn-SAH-doh]","english":"tired","example_es":"Estoy cansada hoy.","example_en":"I am tired today."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Lola","spanish":"¿Cómo estás hoy?","english":"How are you today?"},
      {"speaker":"Iván","spanish":"Estoy un poco triste.","english":"I am a little sad."},
      {"speaker":"Lola","spanish":"¿Por qué?","english":"Why?"},
      {"speaker":"Iván","spanish":"Mi perro está enfermo.","english":"My dog is sick."}
    ]'::jsonb,
    grammar_note = 'Feeling adjectives agree with the speaker''s gender: a man says contentO, cansadO; a woman says contentA, cansadA. Use ESTAR (not ser) because moods are temporary states.'
  where id = v_l1;

  update public.lessons set
    intro = 'SENTIRSE (to feel) is a reflexive verb that pairs with adjectives or adverbs.',
    vocab_items = '[
      {"word":"sentirse","phonetic":"[sehn-TEER-seh]","english":"to feel","example_es":"Me siento bien.","example_en":"I feel well."},
      {"word":"me siento bien","phonetic":"[meh SYEHN-toh BYEHN]","english":"I feel well","example_es":"Hoy me siento bien.","example_en":"Today I feel well."},
      {"word":"me siento mal","phonetic":"[meh SYEHN-toh mahl]","english":"I feel bad","example_es":"Me siento mal por él.","example_en":"I feel bad for him."},
      {"word":"feliz","phonetic":"[feh-LEES]","english":"happy","example_es":"Me siento muy feliz.","example_en":"I feel very happy."},
      {"word":"preocupado","phonetic":"[preh-oh-koo-PAH-doh]","english":"worried","example_es":"Me siento preocupado.","example_en":"I feel worried."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Ana","spanish":"¿Cómo te sientes?","english":"How do you feel?"},
      {"speaker":"Mario","spanish":"Me siento feliz, gracias.","english":"I feel happy, thanks."},
      {"speaker":"Ana","spanish":"¿Y tu hermana?","english":"And your sister?"},
      {"speaker":"Mario","spanish":"Ella se siente preocupada.","english":"She feels worried."}
    ]'::jsonb,
    grammar_note = 'SENTIRSE is stem-changing (e → ie) and reflexive: me siento, te sientes, se siente, nos sentimos, os sentís, se sienten. The reflexive pronoun ALWAYS comes before the conjugated verb.'
  where id = v_l2;

  update public.lessons set
    intro = 'Asking how someone feels — and saying why — is the heart of small talk in Spanish.',
    vocab_items = '[
      {"word":"¿Qué te pasa?","phonetic":"[keh teh PAH-sah]","english":"What''s wrong?","example_es":"¿Qué te pasa hoy?","example_en":"What''s wrong today?"},
      {"word":"porque","phonetic":"[POHR-keh]","english":"because","example_es":"Estoy triste porque llueve.","example_en":"I am sad because it''s raining."},
      {"word":"un poco","phonetic":"[oon POH-koh]","english":"a little","example_es":"Estoy un poco cansada.","example_en":"I am a little tired."},
      {"word":"de mal humor","phonetic":"[deh mahl oo-MOHR]","english":"in a bad mood","example_es":"Estoy de mal humor.","example_en":"I am in a bad mood."},
      {"word":"de buen humor","phonetic":"[deh bwehn oo-MOHR]","english":"in a good mood","example_es":"Hoy estoy de buen humor.","example_en":"Today I am in a good mood."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Eva","spanish":"¿Qué te pasa?","english":"What''s wrong?"},
      {"speaker":"Sofía","spanish":"Estoy de mal humor porque llueve.","english":"I am in a bad mood because it''s raining."},
      {"speaker":"Eva","spanish":"Yo estoy de buen humor.","english":"I am in a good mood."},
      {"speaker":"Sofía","spanish":"Tú siempre estás feliz.","english":"You''re always happy."}
    ]'::jsonb,
    grammar_note = 'PORQUE (one word, no accent) means "because". POR QUÉ (two words, accent) means "why?". Don''t mix them up.'
  where id = v_l3;

  update public.lessons set
    intro = 'Train your ear for emotional vocabulary in connected speech.',
    vocab_items = '[
      {"word":"emocionado","phonetic":"[eh-moh-syoh-NAH-doh]","english":"excited","example_es":"Estoy muy emocionado.","example_en":"I am very excited."},
      {"word":"aburrido","phonetic":"[ah-boo-RREE-doh]","english":"bored","example_es":"Estoy aburrida en casa.","example_en":"I am bored at home."},
      {"word":"sorprendido","phonetic":"[sohr-prehn-DEE-doh]","english":"surprised","example_es":"Está sorprendido.","example_en":"He is surprised."},
      {"word":"tranquilo","phonetic":"[trahn-KEE-loh]","english":"calm","example_es":"Estoy tranquila.","example_en":"I am calm."},
      {"word":"asustado","phonetic":"[ah-soos-TAH-doh]","english":"scared","example_es":"El niño está asustado.","example_en":"The child is scared."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Inés","spanish":"¿Estás emocionada por el viaje?","english":"Are you excited about the trip?"},
      {"speaker":"Tú","spanish":"Sí, muy emocionada.","english":"Yes, very excited."},
      {"speaker":"Inés","spanish":"Yo estoy un poco asustada de volar.","english":"I am a little scared of flying."},
      {"speaker":"Tú","spanish":"Tranquila, todo va a salir bien.","english":"Calm down, it will all go well."}
    ]'::jsonb,
    grammar_note = 'ESTAR + past participle (emocionado, sorprendido, asustado) describes a current emotional state. The participle ends in -ado for -ar verbs and -ido for -er / -ir verbs.'
  where id = v_l4;

  update public.lessons set
    intro = 'Say how you feel and why. Use ESTAR + adjective and PORQUE for the reason.',
    vocab_items = '[
      {"word":"Estoy contento","phonetic":"[ehs-TOY kohn-TEHN-toh]","english":"I am happy","example_es":"Estoy contento porque es viernes.","example_en":"I am happy because it''s Friday."},
      {"word":"Estoy nervioso","phonetic":"[ehs-TOY nehr-BYOH-soh]","english":"I am nervous","example_es":"Estoy nervioso por la entrevista.","example_en":"I am nervous about the interview."},
      {"word":"Me siento bien","phonetic":"[meh SYEHN-toh BYEHN]","english":"I feel well","example_es":"Hoy me siento bien.","example_en":"Today I feel well."},
      {"word":"Tengo miedo","phonetic":"[TEHN-goh MYEH-doh]","english":"I am afraid","example_es":"Tengo miedo de los perros.","example_en":"I am afraid of dogs."},
      {"word":"Estoy de buen humor","phonetic":"[ehs-TOY deh bwehn oo-MOHR]","english":"I am in a good mood","example_es":"Hoy estoy de buen humor.","example_en":"Today I am in a good mood."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Tú","spanish":"Hoy estoy de buen humor.","english":"Today I am in a good mood."},
      {"speaker":"Amigo","spanish":"¿Por qué?","english":"Why?"},
      {"speaker":"Tú","spanish":"Porque es viernes y mañana viajo.","english":"Because it''s Friday and tomorrow I travel."},
      {"speaker":"Amigo","spanish":"Yo también estoy contento.","english":"I am happy too."}
    ]'::jsonb,
    grammar_note = 'TENER + MIEDO / SUEÑO / FRÍO / CALOR / HAMBRE / SED uses tener instead of estar. These are all physical / emotional sensations expressed as "having" something in Spanish.'
  where id = v_l5;

  update public.lessons set
    intro = 'Read about Marina''s emotional week — happy days, sad days, and reasons for both.',
    vocab_items = '[
      {"word":"una semana","phonetic":"[OO-nah seh-MAH-nah]","english":"a week","example_es":"Esta semana fue larga.","example_en":"This week was long."},
      {"word":"el lunes","phonetic":"[ehl LOO-nehs]","english":"Monday","example_es":"El lunes estoy cansada.","example_en":"On Monday I am tired."},
      {"word":"el viernes","phonetic":"[ehl BYEHR-nehs]","english":"Friday","example_es":"El viernes estoy feliz.","example_en":"On Friday I am happy."},
      {"word":"a veces","phonetic":"[ah BEH-sehs]","english":"sometimes","example_es":"A veces me siento triste.","example_en":"Sometimes I feel sad."},
      {"word":"siempre","phonetic":"[SYEHM-preh]","english":"always","example_es":"Siempre estoy contenta los sábados.","example_en":"I''m always happy on Saturdays."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Marina tiene una semana llena de emociones.","english":"Marina has a week full of emotions."},
      {"speaker":"Texto","spanish":"El lunes está cansada y un poco triste.","english":"On Monday she is tired and a little sad."},
      {"speaker":"Texto","spanish":"El miércoles está nerviosa por una reunión importante.","english":"On Wednesday she is nervous about an important meeting."},
      {"speaker":"Texto","spanish":"Pero el viernes está feliz porque sale con sus amigas.","english":"But on Friday she is happy because she''s going out with her friends."}
    ]'::jsonb,
    grammar_note = 'Days of the week take the article EL: el lunes, el martes. To say "on Mondays" (every Monday) use LOS lunes.'
  where id = v_l6;

  update public.lessons set
    intro = 'Write four sentences about how you feel today and why.',
    vocab_items = '[
      {"word":"hoy","phonetic":"[oy]","english":"today","example_es":"Hoy estoy bien.","example_en":"Today I am well."},
      {"word":"ayer","phonetic":"[ah-YEHR]","english":"yesterday","example_es":"Ayer estaba triste.","example_en":"Yesterday I was sad."},
      {"word":"mañana","phonetic":"[mah-NYAH-nah]","english":"tomorrow","example_es":"Mañana voy a estar feliz.","example_en":"Tomorrow I''m going to be happy."},
      {"word":"a menudo","phonetic":"[ah meh-NOO-doh]","english":"often","example_es":"Estoy cansado a menudo.","example_en":"I am often tired."},
      {"word":"raramente","phonetic":"[rrah-rah-MEHN-teh]","english":"rarely","example_es":"Raramente estoy enfadado.","example_en":"I am rarely angry."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Modelo","spanish":"Hoy me siento muy bien.","english":"Today I feel very good."},
      {"speaker":"Modelo","spanish":"Estoy contenta porque hace sol.","english":"I am happy because it''s sunny."},
      {"speaker":"Modelo","spanish":"A veces estoy nerviosa antes del trabajo.","english":"Sometimes I am nervous before work."},
      {"speaker":"Modelo","spanish":"Raramente me siento triste.","english":"I rarely feel sad."}
    ]'::jsonb,
    grammar_note = 'Frequency adverbs (siempre, a menudo, a veces, raramente, nunca) usually come BEFORE the verb or AT THE END of the sentence. Both positions are correct.'
  where id = v_l7;

  -- ============== A2.7 CELEBRATIONS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Celebrations';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'Learn the words for birthdays, weddings, parties and the gifts that go with them.',
    vocab_items = '[
      {"word":"el cumpleaños","phonetic":"[ehl koom-pleh-AH-nyohs]","english":"birthday","example_es":"Mi cumpleaños es en mayo.","example_en":"My birthday is in May."},
      {"word":"la fiesta","phonetic":"[lah FYEHS-tah]","english":"the party","example_es":"Vamos a una fiesta.","example_en":"We''re going to a party."},
      {"word":"la boda","phonetic":"[lah BOH-dah]","english":"the wedding","example_es":"Asisto a una boda.","example_en":"I''m attending a wedding."},
      {"word":"el regalo","phonetic":"[ehl rreh-GAH-loh]","english":"the gift","example_es":"Compro un regalo.","example_en":"I buy a gift."},
      {"word":"invitar","phonetic":"[een-bee-TAR]","english":"to invite","example_es":"Te invito a mi fiesta.","example_en":"I''m inviting you to my party."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Sara","spanish":"¿Cuándo es tu cumpleaños?","english":"When is your birthday?"},
      {"speaker":"Marco","spanish":"El doce de junio. Hago una fiesta.","english":"June twelfth. I''m throwing a party."},
      {"speaker":"Sara","spanish":"¡Genial! ¿Me invitas?","english":"Great! Are you inviting me?"},
      {"speaker":"Marco","spanish":"Por supuesto. Trae un regalo pequeño.","english":"Of course. Bring a small gift."}
    ]'::jsonb,
    grammar_note = 'For dates use EL + day + DE + month: el doce DE junio = June 12th. Months are not capitalized in Spanish.'
  where id = v_l1;

  update public.lessons set
    intro = 'IR A + INFINITIVE is the easy near-future. Use it to say what you are GOING TO do at a celebration.',
    vocab_items = '[
      {"word":"voy a","phonetic":"[BOY ah]","english":"I''m going to","example_es":"Voy a hacer una fiesta.","example_en":"I''m going to throw a party."},
      {"word":"vamos a","phonetic":"[BAH-mohs ah]","english":"we''re going to","example_es":"Vamos a bailar.","example_en":"We''re going to dance."},
      {"word":"celebrar","phonetic":"[seh-leh-BRAR]","english":"to celebrate","example_es":"Vamos a celebrar.","example_en":"We''re going to celebrate."},
      {"word":"organizar","phonetic":"[ohr-gah-nee-SAR]","english":"to organize","example_es":"Voy a organizar la fiesta.","example_en":"I''m going to organize the party."},
      {"word":"preparar","phonetic":"[preh-pah-RAR]","english":"to prepare","example_es":"Preparo la comida.","example_en":"I prepare the food."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Eva","spanish":"¿Qué vais a hacer este finde?","english":"What are you (pl.) going to do this weekend?"},
      {"speaker":"Pablo","spanish":"Vamos a celebrar el cumpleaños de Ana.","english":"We''re going to celebrate Ana''s birthday."},
      {"speaker":"Eva","spanish":"¿Quién organiza la fiesta?","english":"Who is organizing the party?"},
      {"speaker":"Pablo","spanish":"Yo voy a preparar la comida.","english":"I''m going to prepare the food."}
    ]'::jsonb,
    grammar_note = 'IR A + INFINITIVE = "to be going to". Forms: voy a, vas a, va a, vamos a, vais a, van a. Use it for plans, not for predictions.'
  where id = v_l2;

  update public.lessons set
    intro = 'Phrases for the big celebrations: birthdays, weddings, Christmas, New Year''s.',
    vocab_items = '[
      {"word":"¡Feliz cumpleaños!","phonetic":"[feh-LEES koom-pleh-AH-nyohs]","english":"Happy birthday!","example_es":"¡Feliz cumpleaños, abuela!","example_en":"Happy birthday, grandma!"},
      {"word":"¡Felicidades!","phonetic":"[feh-lee-see-DAH-dehs]","english":"Congratulations!","example_es":"¡Felicidades por la boda!","example_en":"Congratulations on the wedding!"},
      {"word":"¡Feliz Navidad!","phonetic":"[feh-LEES nah-bee-DAHD]","english":"Merry Christmas!","example_es":"¡Feliz Navidad a todos!","example_en":"Merry Christmas everyone!"},
      {"word":"brindar","phonetic":"[breen-DAR]","english":"to toast","example_es":"Vamos a brindar.","example_en":"Let''s make a toast."},
      {"word":"el pastel / la tarta","phonetic":"[ehl pahs-TEHL / lah TAR-tah]","english":"cake","example_es":"La tarta está deliciosa.","example_en":"The cake is delicious."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Todos","spanish":"¡Feliz cumpleaños, María!","english":"Happy birthday, María!"},
      {"speaker":"María","spanish":"¡Gracias! ¿Cortamos la tarta?","english":"Thanks! Shall we cut the cake?"},
      {"speaker":"Padre","spanish":"Primero brindamos. ¡Salud!","english":"First we toast. Cheers!"},
      {"speaker":"Todos","spanish":"¡Salud!","english":"Cheers!"}
    ]'::jsonb,
    grammar_note = 'Many holiday phrases use the FELIZ pattern: Feliz cumpleaños, Feliz Navidad, Feliz Año Nuevo. FELICIDADES (plural) is for accomplishments — a graduation, a wedding, a new job.'
  where id = v_l3;

  update public.lessons set
    intro = 'Listen to short clips from a real Spanish-speaking party. Catch the key vocabulary.',
    vocab_items = '[
      {"word":"los invitados","phonetic":"[lohs een-bee-TAH-dohs]","english":"the guests","example_es":"Los invitados llegan a las ocho.","example_en":"The guests arrive at eight."},
      {"word":"la decoración","phonetic":"[lah deh-koh-rah-SYOHN]","english":"the decoration","example_es":"La decoración es bonita.","example_en":"The decoration is pretty."},
      {"word":"bailar","phonetic":"[bah-ee-LAR]","english":"to dance","example_es":"Vamos a bailar toda la noche.","example_en":"We''re going to dance all night."},
      {"word":"la música","phonetic":"[lah MOO-see-kah]","english":"the music","example_es":"La música está alta.","example_en":"The music is loud."},
      {"word":"divertirse","phonetic":"[dee-behr-TEER-seh]","english":"to have fun","example_es":"Nos divertimos mucho.","example_en":"We have a lot of fun."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Anfitriona","spanish":"¡Bienvenidos, invitados!","english":"Welcome, guests!"},
      {"speaker":"Amigo","spanish":"La decoración es preciosa.","english":"The decoration is beautiful."},
      {"speaker":"Anfitriona","spanish":"¿Bailamos?","english":"Shall we dance?"},
      {"speaker":"Amigo","spanish":"¡Vamos! Me divierto mucho aquí.","english":"Let''s go! I''m having a lot of fun here."}
    ]'::jsonb,
    grammar_note = 'DIVERTIRSE (to have fun) is reflexive AND stem-changing (e → ie): me divierto, te diviertes, se divierte, nos divertimos, os divertís, se divierten.'
  where id = v_l4;

  update public.lessons set
    intro = 'Say party phrases aloud — congratulations, toasts, and invitations.',
    vocab_items = '[
      {"word":"¡Feliz cumpleaños!","phonetic":"[feh-LEES koom-pleh-AH-nyohs]","english":"Happy birthday!","example_es":"¡Feliz cumpleaños, amigo!","example_en":"Happy birthday, friend!"},
      {"word":"¡Salud!","phonetic":"[sah-LOOD]","english":"Cheers!","example_es":"¡Salud, por nosotros!","example_en":"Cheers, to us!"},
      {"word":"Te invito a mi fiesta","phonetic":"[teh een-BEE-toh ah mee FYEHS-tah]","english":"I invite you to my party","example_es":"Te invito a mi fiesta el sábado.","example_en":"I invite you to my party on Saturday."},
      {"word":"Voy a comprar un regalo","phonetic":"[BOY ah kohm-PRAR oon rreh-GAH-loh]","english":"I''m going to buy a gift","example_es":"Voy a comprar un regalo bonito.","example_en":"I''m going to buy a nice gift."},
      {"word":"¡Felicidades!","phonetic":"[feh-lee-see-DAH-dehs]","english":"Congratulations!","example_es":"¡Felicidades por tu boda!","example_en":"Congratulations on your wedding!"}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Tú","spanish":"Te invito a mi cumpleaños el sábado.","english":"I invite you to my birthday on Saturday."},
      {"speaker":"Amiga","spanish":"¡Genial! ¿Llevo un regalo?","english":"Great! Should I bring a gift?"},
      {"speaker":"Tú","spanish":"Sí, pero pequeño. ¡Va a haber tarta!","english":"Yes, but small. There''s going to be cake!"},
      {"speaker":"Amiga","spanish":"¡Salud, por la fiesta!","english":"Cheers, to the party!"}
    ]'::jsonb,
    grammar_note = 'HAY (there is / there are) becomes VA A HABER for "there is going to be". Notice you only conjugate VA, not HABER.'
  where id = v_l5;

  update public.lessons set
    intro = 'Read about Carlos''s perfect surprise party — guests, food, music and gifts.',
    vocab_items = '[
      {"word":"sorpresa","phonetic":"[sohr-PREH-sah]","english":"surprise","example_es":"Es una fiesta sorpresa.","example_en":"It''s a surprise party."},
      {"word":"la cena","phonetic":"[lah SEH-nah]","english":"dinner","example_es":"Preparamos una cena especial.","example_en":"We prepare a special dinner."},
      {"word":"la cumpleañera","phonetic":"[lah koom-pleh-ah-NYEH-rah]","english":"birthday girl","example_es":"La cumpleañera está feliz.","example_en":"The birthday girl is happy."},
      {"word":"abrir regalos","phonetic":"[ah-BREER rreh-GAH-lohs]","english":"to open gifts","example_es":"Vamos a abrir regalos.","example_en":"We''re going to open gifts."},
      {"word":"recordar","phonetic":"[rreh-kohr-DAR]","english":"to remember","example_es":"Voy a recordar esta noche.","example_en":"I''m going to remember tonight."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Carlos organiza una fiesta sorpresa para Lucía.","english":"Carlos is organizing a surprise party for Lucía."},
      {"speaker":"Texto","spanish":"Invita a veinte amigos y prepara una cena especial.","english":"He invites twenty friends and prepares a special dinner."},
      {"speaker":"Texto","spanish":"Cuando Lucía entra, todos gritan: ¡Felicidades!","english":"When Lucía enters, everyone shouts: Congratulations!"},
      {"speaker":"Texto","spanish":"La cumpleañera abre los regalos y todos se divierten mucho.","english":"The birthday girl opens the gifts and everyone has a lot of fun."}
    ]'::jsonb,
    grammar_note = 'CUANDO (when, no accent) introduces a time clause: cuando Lucía entra... = when Lucía enters... CUÁNDO (with accent) is the question: ¿cuándo entra?'
  where id = v_l6;

  update public.lessons set
    intro = 'Write four sentences about a real or invented celebration. Use IR A + infinitive for plans.',
    vocab_items = '[
      {"word":"el sábado","phonetic":"[ehl SAH-bah-doh]","english":"Saturday","example_es":"El sábado es la fiesta.","example_en":"Saturday is the party."},
      {"word":"a las nueve","phonetic":"[ah lahs NWEH-beh]","english":"at nine","example_es":"Empieza a las nueve.","example_en":"It starts at nine."},
      {"word":"con mis amigos","phonetic":"[kohn mees ah-MEE-gohs]","english":"with my friends","example_es":"Voy con mis amigos.","example_en":"I''m going with my friends."},
      {"word":"vamos a cantar","phonetic":"[BAH-mohs ah kahn-TAR]","english":"we''re going to sing","example_es":"Vamos a cantar feliz cumpleaños.","example_en":"We''re going to sing happy birthday."},
      {"word":"hasta tarde","phonetic":"[AHS-tah TAR-deh]","english":"until late","example_es":"La fiesta va hasta tarde.","example_en":"The party goes until late."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Modelo","spanish":"El sábado es el cumpleaños de mi mejor amigo.","english":"Saturday is my best friend''s birthday."},
      {"speaker":"Modelo","spanish":"Vamos a hacer una fiesta sorpresa en su casa.","english":"We''re going to throw a surprise party at his house."},
      {"speaker":"Modelo","spanish":"Voy a llevar un regalo y una tarta de chocolate.","english":"I''m going to bring a gift and a chocolate cake."},
      {"speaker":"Modelo","spanish":"Vamos a bailar hasta tarde.","english":"We''re going to dance until late."}
    ]'::jsonb,
    grammar_note = 'For "best friend" use MEJOR AMIGO (m.) or MEJOR AMIGA (f.). MEJOR is the irregular comparative of BUENO — it doesn''t become "más bueno".'
  where id = v_l7;

  -- ============== A2.8 NATURE ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Nature';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'The basic words of the natural world: tree, river, mountain, sea, forest.',
    vocab_items = '[
      {"word":"el árbol","phonetic":"[ehl AR-bohl]","english":"the tree","example_es":"El árbol es alto.","example_en":"The tree is tall."},
      {"word":"el río","phonetic":"[ehl RREE-oh]","english":"the river","example_es":"El río pasa por la ciudad.","example_en":"The river goes through the city."},
      {"word":"la montaña","phonetic":"[lah mohn-TAH-nyah]","english":"the mountain","example_es":"Subo la montaña.","example_en":"I climb the mountain."},
      {"word":"el mar","phonetic":"[ehl mahr]","english":"the sea","example_es":"Vivo cerca del mar.","example_en":"I live near the sea."},
      {"word":"el bosque","phonetic":"[ehl BOHS-keh]","english":"the forest","example_es":"Camino por el bosque.","example_en":"I walk through the forest."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Marco","spanish":"¿Adónde vas de vacaciones?","english":"Where are you going on holiday?"},
      {"speaker":"Lola","spanish":"Voy a la montaña.","english":"I''m going to the mountain."},
      {"speaker":"Marco","spanish":"¿Hay un bosque allí?","english":"Is there a forest there?"},
      {"speaker":"Lola","spanish":"Sí, y un río muy bonito.","english":"Yes, and a very pretty river."}
    ]'::jsonb,
    grammar_note = 'EL MAR is usually masculine, but LA MAR is also accepted especially in poetry and in some regions. Stick with EL MAR for everyday Spanish.'
  where id = v_l1;

  update public.lessons set
    intro = 'Comparatives let you compare two things in nature: MÁS / MENOS … QUE.',
    vocab_items = '[
      {"word":"más … que","phonetic":"[MAHS keh]","english":"more … than","example_es":"El mar es más grande que el río.","example_en":"The sea is bigger than the river."},
      {"word":"menos … que","phonetic":"[MEH-nohs keh]","english":"less … than","example_es":"La colina es menos alta que la montaña.","example_en":"The hill is less tall than the mountain."},
      {"word":"tan … como","phonetic":"[tahn KOH-moh]","english":"as … as","example_es":"El bosque es tan grande como el parque.","example_en":"The forest is as big as the park."},
      {"word":"mejor que","phonetic":"[meh-HOHR keh]","english":"better than","example_es":"El mar es mejor que la piscina.","example_en":"The sea is better than the pool."},
      {"word":"peor que","phonetic":"[peh-OHR keh]","english":"worse than","example_es":"La lluvia es peor que la nieve.","example_en":"Rain is worse than snow."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Eva","spanish":"¿Te gusta más el mar o la montaña?","english":"Do you like the sea or the mountain more?"},
      {"speaker":"Hugo","spanish":"La montaña. Es más tranquila que el mar.","english":"The mountain. It''s more peaceful than the sea."},
      {"speaker":"Eva","spanish":"Yo prefiero el mar. Es más divertido.","english":"I prefer the sea. It''s more fun."},
      {"speaker":"Hugo","spanish":"Para mí, ningún sitio es tan bonito como el bosque.","english":"For me, no place is as pretty as the forest."}
    ]'::jsonb,
    grammar_note = 'MEJOR and PEOR are irregular comparatives. Don''t say "más bueno" or "más malo" — say MEJOR / PEOR.'
  where id = v_l2;

  update public.lessons set
    intro = 'Useful phrases for talking about nature, hiking, and outdoor plans.',
    vocab_items = '[
      {"word":"hacer senderismo","phonetic":"[ah-SEHR sehn-deh-REES-moh]","english":"to go hiking","example_es":"Vamos a hacer senderismo.","example_en":"Let''s go hiking."},
      {"word":"acampar","phonetic":"[ah-kahm-PAR]","english":"to camp","example_es":"Acampamos cerca del lago.","example_en":"We camp near the lake."},
      {"word":"el paisaje","phonetic":"[ehl pah-ee-SAH-heh]","english":"the landscape","example_es":"El paisaje es precioso.","example_en":"The landscape is beautiful."},
      {"word":"la naturaleza","phonetic":"[lah nah-too-rah-LEH-sah]","english":"nature","example_es":"Amo la naturaleza.","example_en":"I love nature."},
      {"word":"al aire libre","phonetic":"[ahl AH-ee-reh LEE-breh]","english":"outdoors","example_es":"Me encanta estar al aire libre.","example_en":"I love being outdoors."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Tomás","spanish":"¿Hacemos senderismo el sábado?","english":"Shall we go hiking on Saturday?"},
      {"speaker":"Clara","spanish":"¡Sí! El paisaje en otoño es precioso.","english":"Yes! The landscape in autumn is beautiful."},
      {"speaker":"Tomás","spanish":"¿También podemos acampar?","english":"Can we also camp?"},
      {"speaker":"Clara","spanish":"Perfecto. Amo la naturaleza al aire libre.","english":"Perfect. I love nature outdoors."}
    ]'::jsonb,
    grammar_note = 'HACER + activity is a very common pattern: hacer senderismo, hacer surf, hacer deporte. Always conjugate HACER, the activity word stays unchanged.'
  where id = v_l3;

  update public.lessons set
    intro = 'Listen to short descriptions of natural places — beaches, mountains, parks.',
    vocab_items = '[
      {"word":"la playa","phonetic":"[lah PLAH-yah]","english":"the beach","example_es":"La playa es larga.","example_en":"The beach is long."},
      {"word":"la arena","phonetic":"[lah ah-REH-nah]","english":"the sand","example_es":"La arena está caliente.","example_en":"The sand is hot."},
      {"word":"las olas","phonetic":"[lahs OH-lahs]","english":"the waves","example_es":"Las olas son grandes hoy.","example_en":"The waves are big today."},
      {"word":"el parque nacional","phonetic":"[ehl PAR-keh nah-syoh-NAHL]","english":"the national park","example_es":"Visitamos el parque nacional.","example_en":"We visit the national park."},
      {"word":"el lago","phonetic":"[ehl LAH-goh]","english":"the lake","example_es":"Nado en el lago.","example_en":"I swim in the lake."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Voz","spanish":"La playa de Tarifa es muy popular.","english":"Tarifa beach is very popular."},
      {"speaker":"Voz","spanish":"La arena es blanca y las olas son grandes.","english":"The sand is white and the waves are big."},
      {"speaker":"Voz","spanish":"Hay un parque nacional cerca con un lago.","english":"There''s a national park nearby with a lake."},
      {"speaker":"Voz","spanish":"Muchos turistas visitan la zona en verano.","english":"Many tourists visit the area in summer."}
    ]'::jsonb,
    grammar_note = 'HAY (there is / there are) is invariable: hay un lago, hay dos parques, hay muchos turistas. It never takes a plural form.'
  where id = v_l4;

  update public.lessons set
    intro = 'Say comparisons aloud — what you prefer between two natural places.',
    vocab_items = '[
      {"word":"Prefiero la montaña","phonetic":"[preh-FYEH-roh lah mohn-TAH-nyah]","english":"I prefer the mountain","example_es":"Prefiero la montaña al mar.","example_en":"I prefer the mountain to the sea."},
      {"word":"Me gusta nadar","phonetic":"[meh GOOS-tah nah-DAR]","english":"I like to swim","example_es":"Me gusta nadar en el mar.","example_en":"I like to swim in the sea."},
      {"word":"Vamos a la playa","phonetic":"[BAH-mohs ah lah PLAH-yah]","english":"We''re going to the beach","example_es":"En verano vamos a la playa.","example_en":"In summer we go to the beach."},
      {"word":"El paisaje es bonito","phonetic":"[ehl pah-ee-SAH-heh ehs boh-NEE-toh]","english":"The landscape is pretty","example_es":"El paisaje aquí es bonito.","example_en":"The landscape here is pretty."},
      {"word":"Hay muchos árboles","phonetic":"[I MOO-chohs AR-boh-lehs]","english":"There are many trees","example_es":"Hay muchos árboles en el bosque.","example_en":"There are many trees in the forest."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Tú","spanish":"Prefiero la montaña al mar.","english":"I prefer the mountain to the sea."},
      {"speaker":"Amigo","spanish":"¿Por qué?","english":"Why?"},
      {"speaker":"Tú","spanish":"Hay muchos árboles y el aire es puro.","english":"There are many trees and the air is clean."},
      {"speaker":"Amigo","spanish":"Para mí, el mar es mejor.","english":"For me, the sea is better."}
    ]'::jsonb,
    grammar_note = 'PREFERIR A is the structure for "prefer X over Y": prefiero el mar A la montaña = I prefer the sea OVER the mountain.'
  where id = v_l5;

  update public.lessons set
    intro = 'Read a short description of a Spanish national park.',
    vocab_items = '[
      {"word":"protegido","phonetic":"[proh-teh-HEE-doh]","english":"protected","example_es":"Es un espacio protegido.","example_en":"It''s a protected area."},
      {"word":"el animal","phonetic":"[ehl ah-nee-MAHL]","english":"the animal","example_es":"Hay muchos animales aquí.","example_en":"There are many animals here."},
      {"word":"la planta","phonetic":"[lah PLAHN-tah]","english":"the plant","example_es":"Las plantas son verdes.","example_en":"The plants are green."},
      {"word":"famoso","phonetic":"[fah-MOH-soh]","english":"famous","example_es":"Es un parque famoso.","example_en":"It''s a famous park."},
      {"word":"visitar","phonetic":"[bee-see-TAR]","english":"to visit","example_es":"Visitamos el parque cada año.","example_en":"We visit the park every year."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"El Parque Nacional de Doñana está en el sur de España.","english":"Doñana National Park is in the south of Spain."},
      {"speaker":"Texto","spanish":"Es un espacio protegido con muchas plantas y animales.","english":"It''s a protected area with many plants and animals."},
      {"speaker":"Texto","spanish":"Hay un río importante y un bosque enorme.","english":"There''s an important river and a huge forest."},
      {"speaker":"Texto","spanish":"Cada año miles de turistas visitan el parque.","english":"Every year thousands of tourists visit the park."}
    ]'::jsonb,
    grammar_note = 'Numbers above 1,000 use MIL (1,000), MILES DE (thousands of). Note: MILES DE turistas, never "mil de turistas".'
  where id = v_l6;

  update public.lessons set
    intro = 'Write four sentences about a natural place you love.',
    vocab_items = '[
      {"word":"mi lugar favorito","phonetic":"[mee loo-GAR fah-boh-REE-toh]","english":"my favorite place","example_es":"Mi lugar favorito es la playa.","example_en":"My favorite place is the beach."},
      {"word":"cerca de","phonetic":"[SEHR-kah deh]","english":"near","example_es":"Está cerca de mi casa.","example_en":"It''s near my house."},
      {"word":"voy a menudo","phonetic":"[BOY ah meh-NOO-doh]","english":"I go often","example_es":"Voy a menudo en verano.","example_en":"I go often in summer."},
      {"word":"hay","phonetic":"[I]","english":"there is / are","example_es":"Hay árboles y flores.","example_en":"There are trees and flowers."},
      {"word":"tranquilo","phonetic":"[trahn-KEE-loh]","english":"peaceful","example_es":"El lugar es muy tranquilo.","example_en":"The place is very peaceful."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Modelo","spanish":"Mi lugar favorito es un bosque cerca de mi pueblo.","english":"My favorite place is a forest near my town."},
      {"speaker":"Modelo","spanish":"Voy a menudo en otoño.","english":"I go often in autumn."},
      {"speaker":"Modelo","spanish":"Hay muchos árboles y un pequeño río.","english":"There are many trees and a small river."},
      {"speaker":"Modelo","spanish":"Es un lugar muy tranquilo.","english":"It''s a very peaceful place."}
    ]'::jsonb,
    grammar_note = 'Adjectives normally come AFTER the noun in Spanish: un bosque GRANDE, un río PEQUEÑO. A few common adjectives (gran, buen, mal) come before for emphasis.'
  where id = v_l7;

  -- ============== A2.9 SPORTS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Sports';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'Learn the names of the most popular Spanish sports.',
    vocab_items = '[
      {"word":"el fútbol","phonetic":"[ehl FOOT-bohl]","english":"football","example_es":"El fútbol es muy popular.","example_en":"Football is very popular."},
      {"word":"el baloncesto","phonetic":"[ehl bah-lohn-SEHS-toh]","english":"basketball","example_es":"Juego al baloncesto.","example_en":"I play basketball."},
      {"word":"el tenis","phonetic":"[ehl TEH-nees]","english":"tennis","example_es":"Veo el tenis en la tele.","example_en":"I watch tennis on TV."},
      {"word":"la natación","phonetic":"[lah nah-tah-SYOHN]","english":"swimming","example_es":"Practico natación.","example_en":"I do swimming."},
      {"word":"el ciclismo","phonetic":"[ehl see-KLEES-moh]","english":"cycling","example_es":"Me gusta el ciclismo.","example_en":"I like cycling."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Eva","spanish":"¿Qué deporte te gusta?","english":"What sport do you like?"},
      {"speaker":"Marco","spanish":"Me gusta el fútbol y el tenis.","english":"I like football and tennis."},
      {"speaker":"Eva","spanish":"¿Practicas alguno?","english":"Do you do any?"},
      {"speaker":"Marco","spanish":"Sí, juego al tenis los sábados.","english":"Yes, I play tennis on Saturdays."}
    ]'::jsonb,
    grammar_note = 'Sports usually take the masculine article: EL fútbol, EL tenis, EL baloncesto. Exceptions: LA natación, LA gimnasia.'
  where id = v_l1;

  update public.lessons set
    intro = 'JUGAR A is for sports with rules and balls. HACER is for individual activities like running and swimming.',
    vocab_items = '[
      {"word":"jugar al fútbol","phonetic":"[hoo-GAR ahl FOOT-bohl]","english":"to play football","example_es":"Juego al fútbol los domingos.","example_en":"I play football on Sundays."},
      {"word":"hacer natación","phonetic":"[ah-SEHR nah-tah-SYOHN]","english":"to swim (as a sport)","example_es":"Hago natación dos veces a la semana.","example_en":"I swim twice a week."},
      {"word":"practicar","phonetic":"[prahk-tee-KAR]","english":"to practice","example_es":"Practico tenis.","example_en":"I practice tennis."},
      {"word":"entrenar","phonetic":"[ehn-treh-NAR]","english":"to train","example_es":"Entreno los martes.","example_en":"I train on Tuesdays."},
      {"word":"el equipo","phonetic":"[ehl eh-KEE-poh]","english":"the team","example_es":"Mi equipo es bueno.","example_en":"My team is good."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Ana","spanish":"¿Juegas al baloncesto?","english":"Do you play basketball?"},
      {"speaker":"Iván","spanish":"Sí, en un equipo. Entreno los martes y jueves.","english":"Yes, on a team. I train Tuesdays and Thursdays."},
      {"speaker":"Ana","spanish":"¿Y tu hermana?","english":"And your sister?"},
      {"speaker":"Iván","spanish":"Ella hace natación.","english":"She swims."}
    ]'::jsonb,
    grammar_note = 'JUGAR is irregular (u → ue): juego, juegas, juega, jugamos, jugáis, juegan. PRACTICAR and ENTRENAR are regular -ar verbs.'
  where id = v_l2;

  update public.lessons set
    intro = 'Phrases to talk about your favorite sport, your team, and how often you train.',
    vocab_items = '[
      {"word":"el partido","phonetic":"[ehl pahr-TEE-doh]","english":"the match","example_es":"Hoy hay un partido.","example_en":"There''s a match today."},
      {"word":"ganar","phonetic":"[gah-NAR]","english":"to win","example_es":"Mi equipo gana mucho.","example_en":"My team wins a lot."},
      {"word":"perder","phonetic":"[pehr-DEHR]","english":"to lose","example_es":"Perdimos el partido.","example_en":"We lost the match."},
      {"word":"el campeón","phonetic":"[ehl kahm-peh-OHN]","english":"the champion","example_es":"Somos los campeones.","example_en":"We are the champions."},
      {"word":"dos veces a la semana","phonetic":"[dohs BEH-sehs ah lah seh-MAH-nah]","english":"twice a week","example_es":"Entreno dos veces a la semana.","example_en":"I train twice a week."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Hugo","spanish":"¿Ganaste el partido?","english":"Did you win the match?"},
      {"speaker":"Tú","spanish":"Sí, somos los campeones.","english":"Yes, we are the champions."},
      {"speaker":"Hugo","spanish":"¿Cuántas veces entrenáis?","english":"How often do you train?"},
      {"speaker":"Tú","spanish":"Dos veces a la semana.","english":"Twice a week."}
    ]'::jsonb,
    grammar_note = 'PERDER is stem-changing (e → ie): pierdo, pierdes, pierde, perdemos, perdéis, pierden. Don''t confuse PERDER (to lose) with PERDER algo (to miss something).'
  where id = v_l3;

  update public.lessons set
    intro = 'Listen to short clips from a sports conversation.',
    vocab_items = '[
      {"word":"el gol","phonetic":"[ehl gohl]","english":"the goal","example_es":"¡Qué gol!","example_en":"What a goal!"},
      {"word":"marcar","phonetic":"[mahr-KAR]","english":"to score","example_es":"Marcó dos goles.","example_en":"He scored two goals."},
      {"word":"el estadio","phonetic":"[ehl ehs-TAH-dyoh]","english":"the stadium","example_es":"Voy al estadio.","example_en":"I go to the stadium."},
      {"word":"el árbitro","phonetic":"[ehl AR-bee-troh]","english":"the referee","example_es":"El árbitro pita.","example_en":"The referee blows the whistle."},
      {"word":"el aficionado","phonetic":"[ehl ah-fee-syoh-NAH-doh]","english":"the fan","example_es":"Los aficionados gritan.","example_en":"The fans shout."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Periodista","spanish":"El partido fue increíble.","english":"The match was incredible."},
      {"speaker":"Jugador","spanish":"Marqué dos goles. ¡Ganamos!","english":"I scored two goals. We won!"},
      {"speaker":"Periodista","spanish":"¿Cómo está el equipo?","english":"How is the team?"},
      {"speaker":"Jugador","spanish":"Somos los campeones de la liga.","english":"We are the league champions."}
    ]'::jsonb,
    grammar_note = 'In sports talk you''ll hear the preterite (past) very often: marqué, gané, perdí. Don''t worry about full conjugation yet — just recognize these forms.'
  where id = v_l4;

  update public.lessons set
    intro = 'Say which sports you play, watch, and prefer. Be ready to back it up with how often.',
    vocab_items = '[
      {"word":"Juego al tenis","phonetic":"[HWEH-goh ahl TEH-nees]","english":"I play tennis","example_es":"Juego al tenis los sábados.","example_en":"I play tennis on Saturdays."},
      {"word":"Hago deporte","phonetic":"[AH-goh deh-POHR-teh]","english":"I do sport","example_es":"Hago deporte tres veces a la semana.","example_en":"I do sport three times a week."},
      {"word":"Mi equipo favorito","phonetic":"[mee eh-KEE-poh fah-boh-REE-toh]","english":"My favorite team","example_es":"Mi equipo favorito es el Barça.","example_en":"My favorite team is Barça."},
      {"word":"Veo el partido","phonetic":"[BEH-oh ehl pahr-TEE-doh]","english":"I watch the match","example_es":"Veo el partido en la tele.","example_en":"I watch the match on TV."},
      {"word":"Entreno duro","phonetic":"[ehn-TREH-noh DOO-roh]","english":"I train hard","example_es":"Entreno duro todos los días.","example_en":"I train hard every day."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Tú","spanish":"Mi equipo favorito es el Real Madrid.","english":"My favorite team is Real Madrid."},
      {"speaker":"Amigo","spanish":"¿Ves todos los partidos?","english":"Do you watch all the matches?"},
      {"speaker":"Tú","spanish":"Veo el partido cada domingo en la tele.","english":"I watch the match every Sunday on TV."},
      {"speaker":"Amigo","spanish":"Yo prefiero jugar al baloncesto.","english":"I prefer to play basketball."}
    ]'::jsonb,
    grammar_note = 'VER is irregular only in yo: veo, ves, ve, vemos, veis, ven. Use it for both watching sport and seeing in general.'
  where id = v_l5;

  update public.lessons set
    intro = 'Read about Sergio''s weekly training routine.',
    vocab_items = '[
      {"word":"el gimnasio","phonetic":"[ehl heem-NAH-syoh]","english":"the gym","example_es":"Voy al gimnasio.","example_en":"I go to the gym."},
      {"word":"el entrenador","phonetic":"[ehl ehn-treh-nah-DOHR]","english":"the coach","example_es":"Mi entrenador es estricto.","example_en":"My coach is strict."},
      {"word":"correr","phonetic":"[koh-RREHR]","english":"to run","example_es":"Corro diez kilómetros.","example_en":"I run ten kilometers."},
      {"word":"levantar pesas","phonetic":"[leh-bahn-TAR PEH-sahs]","english":"to lift weights","example_es":"Levanto pesas en el gimnasio.","example_en":"I lift weights at the gym."},
      {"word":"el campeonato","phonetic":"[ehl kahm-peh-oh-NAH-toh]","english":"the championship","example_es":"Hay un campeonato pronto.","example_en":"There''s a championship soon."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Sergio entrena cinco días a la semana.","english":"Sergio trains five days a week."},
      {"speaker":"Texto","spanish":"Por la mañana corre diez kilómetros en el parque.","english":"In the morning he runs ten kilometers in the park."},
      {"speaker":"Texto","spanish":"Por la tarde va al gimnasio a levantar pesas.","english":"In the afternoon he goes to the gym to lift weights."},
      {"speaker":"Texto","spanish":"Su entrenador dice que está listo para el campeonato.","english":"His coach says he is ready for the championship."}
    ]'::jsonb,
    grammar_note = 'IR A + INFINITIVE expresses purpose with movement verbs: va al gimnasio A LEVANTAR pesas = he goes to the gym TO lift weights.'
  where id = v_l6;

  update public.lessons set
    intro = 'Write four sentences about a sport you play or follow.',
    vocab_items = '[
      {"word":"mi deporte favorito","phonetic":"[mee deh-POHR-teh fah-boh-REE-toh]","english":"my favorite sport","example_es":"Mi deporte favorito es el fútbol.","example_en":"My favorite sport is football."},
      {"word":"desde niño","phonetic":"[DEHS-deh NEE-nyoh]","english":"since I was a kid","example_es":"Juego desde niño.","example_en":"I''ve been playing since I was a kid."},
      {"word":"con mis amigos","phonetic":"[kohn mees ah-MEE-gohs]","english":"with my friends","example_es":"Juego con mis amigos.","example_en":"I play with my friends."},
      {"word":"todas las semanas","phonetic":"[TOH-dahs lahs seh-MAH-nahs]","english":"every week","example_es":"Entreno todas las semanas.","example_en":"I train every week."},
      {"word":"competir","phonetic":"[kohm-peh-TEER]","english":"to compete","example_es":"Compito en torneos pequeños.","example_en":"I compete in small tournaments."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Modelo","spanish":"Mi deporte favorito es el tenis.","english":"My favorite sport is tennis."},
      {"speaker":"Modelo","spanish":"Juego desde niño con mi padre.","english":"I''ve played since I was a kid with my dad."},
      {"speaker":"Modelo","spanish":"Entreno dos veces a la semana en el club.","english":"I train twice a week at the club."},
      {"speaker":"Modelo","spanish":"A veces compito en torneos pequeños.","english":"Sometimes I compete in small tournaments."}
    ]'::jsonb,
    grammar_note = 'COMPETIR is stem-changing (e → i): compito, compites, compite, competimos, competís, compiten.'
  where id = v_l7;

  -- ============== A2.10 MUSIC ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Music';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'Music vocabulary covers songs, instruments, bands and concerts.',
    vocab_items = '[
      {"word":"la canción","phonetic":"[lah kahn-SYOHN]","english":"the song","example_es":"Me gusta esta canción.","example_en":"I like this song."},
      {"word":"el cantante / la cantante","phonetic":"[ehl/lah kahn-TAHN-teh]","english":"singer","example_es":"Es mi cantante favorito.","example_en":"He is my favorite singer."},
      {"word":"la banda","phonetic":"[lah BAHN-dah]","english":"the band","example_es":"Es una banda nueva.","example_en":"It''s a new band."},
      {"word":"el instrumento","phonetic":"[ehl een-stroo-MEHN-toh]","english":"the instrument","example_es":"¿Tocas algún instrumento?","example_en":"Do you play any instrument?"},
      {"word":"el concierto","phonetic":"[ehl kohn-SYEHR-toh]","english":"the concert","example_es":"Voy al concierto.","example_en":"I''m going to the concert."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Eva","spanish":"¿Cuál es tu canción favorita?","english":"What''s your favorite song?"},
      {"speaker":"Luis","spanish":"Me gusta una canción de una banda española.","english":"I like a song from a Spanish band."},
      {"speaker":"Eva","spanish":"¿Vas a algún concierto?","english":"Are you going to any concert?"},
      {"speaker":"Luis","spanish":"Sí, voy a uno el sábado.","english":"Yes, I''m going to one on Saturday."}
    ]'::jsonb,
    grammar_note = 'CANTANTE is one word for both genders — only the article changes: el cantante (m.), la cantante (f.). Same with PIANISTA, GUITARRISTA, ARTISTA.'
  where id = v_l1;

  update public.lessons set
    intro = 'Use GUSTAR + MUCHO / UN POCO to express how much you like music.',
    vocab_items = '[
      {"word":"me gusta mucho","phonetic":"[meh GOOS-tah MOO-choh]","english":"I really like","example_es":"Me gusta mucho el jazz.","example_en":"I really like jazz."},
      {"word":"me gusta un poco","phonetic":"[meh GOOS-tah oon POH-koh]","english":"I like a little","example_es":"Me gusta un poco el rock.","example_en":"I like rock a little."},
      {"word":"no me gusta nada","phonetic":"[noh meh GOOS-tah NAH-dah]","english":"I don''t like at all","example_es":"No me gusta nada el reggaetón.","example_en":"I don''t like reggaeton at all."},
      {"word":"saber tocar","phonetic":"[sah-BEHR toh-KAR]","english":"to know how to play","example_es":"Sé tocar la guitarra.","example_en":"I know how to play the guitar."},
      {"word":"aprender","phonetic":"[ah-prehn-DEHR]","english":"to learn","example_es":"Quiero aprender piano.","example_en":"I want to learn piano."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Mia","spanish":"¿Te gusta el jazz?","english":"Do you like jazz?"},
      {"speaker":"Pablo","spanish":"Sí, me gusta mucho.","english":"Yes, I really like it."},
      {"speaker":"Mia","spanish":"¿Sabes tocar algún instrumento?","english":"Do you know how to play any instrument?"},
      {"speaker":"Pablo","spanish":"Sé tocar un poco el piano.","english":"I can play a little piano."}
    ]'::jsonb,
    grammar_note = 'SABER + INFINITIVE = to know HOW to do something. SÉ tocar = I know how to play. SABER is irregular in yo: sé, sabes, sabe, sabemos, sabéis, saben.'
  where id = v_l2;

  update public.lessons set
    intro = 'Practical phrases for music — buying concert tickets, asking about songs, comparing styles.',
    vocab_items = '[
      {"word":"la entrada","phonetic":"[lah ehn-TRAH-dah]","english":"the ticket","example_es":"Compro dos entradas.","example_en":"I buy two tickets."},
      {"word":"la letra","phonetic":"[lah LEH-trah]","english":"the lyrics","example_es":"La letra es bonita.","example_en":"The lyrics are pretty."},
      {"word":"el ritmo","phonetic":"[ehl RREET-moh]","english":"the rhythm","example_es":"Me encanta el ritmo.","example_en":"I love the rhythm."},
      {"word":"el estilo","phonetic":"[ehl ehs-TEE-loh]","english":"the style","example_es":"¿Cuál es tu estilo favorito?","example_en":"What''s your favorite style?"},
      {"word":"poner música","phonetic":"[poh-NEHR MOO-see-kah]","english":"to put on music","example_es":"Pongo música cuando cocino.","example_en":"I put music on when I cook."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Tú","spanish":"¿Qué estilo de música te gusta?","english":"What music style do you like?"},
      {"speaker":"Eva","spanish":"El pop, sobre todo por la letra.","english":"Pop, especially for the lyrics."},
      {"speaker":"Tú","spanish":"¿Compraste entradas para el concierto?","english":"Did you buy tickets for the concert?"},
      {"speaker":"Eva","spanish":"Sí, dos. ¡Vamos juntas!","english":"Yes, two. We''re going together!"}
    ]'::jsonb,
    grammar_note = 'PONER (to put) is irregular in yo: pongo. Use it for putting music on, putting clothes on, setting a table — pongo música, me pongo la chaqueta, pongo la mesa.'
  where id = v_l3;

  update public.lessons set
    intro = 'Hear native speakers describe their musical tastes.',
    vocab_items = '[
      {"word":"el rock","phonetic":"[ehl rrohk]","english":"rock","example_es":"Escucho rock.","example_en":"I listen to rock."},
      {"word":"el pop","phonetic":"[ehl pohp]","english":"pop","example_es":"El pop es muy popular.","example_en":"Pop is very popular."},
      {"word":"la música clásica","phonetic":"[lah MOO-see-kah KLAH-see-kah]","english":"classical music","example_es":"Me gusta la música clásica.","example_en":"I like classical music."},
      {"word":"el reggaetón","phonetic":"[ehl rreh-geh-TOHN]","english":"reggaeton","example_es":"En la fiesta ponen reggaetón.","example_en":"At the party they play reggaeton."},
      {"word":"el flamenco","phonetic":"[ehl flah-MEHN-koh]","english":"flamenco","example_es":"El flamenco es de España.","example_en":"Flamenco is from Spain."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Voz","spanish":"Yo escucho rock y pop, pero no me gusta el reggaetón.","english":"I listen to rock and pop, but I don''t like reggaeton."},
      {"speaker":"Voz","spanish":"En España el flamenco es muy importante.","english":"In Spain flamenco is very important."},
      {"speaker":"Voz","spanish":"Mis padres prefieren la música clásica.","english":"My parents prefer classical music."},
      {"speaker":"Voz","spanish":"Cada uno tiene su estilo.","english":"Everyone has their style."}
    ]'::jsonb,
    grammar_note = 'CADA UNO / CADA UNA = each one / everyone. CADA never changes for plural. CADA día = every day. CADA año = every year.'
  where id = v_l4;

  update public.lessons set
    intro = 'Say music phrases out loud. Talk about styles and instruments.',
    vocab_items = '[
      {"word":"Me encanta esta canción","phonetic":"[meh ehn-KAHN-tah EHS-tah kahn-SYOHN]","english":"I love this song","example_es":"Me encanta esta canción de salsa.","example_en":"I love this salsa song."},
      {"word":"Toco la guitarra","phonetic":"[TOH-koh lah gee-TAH-rrah]","english":"I play the guitar","example_es":"Toco la guitarra desde los doce años.","example_en":"I''ve played guitar since I was twelve."},
      {"word":"Voy al concierto","phonetic":"[BOY ahl kohn-SYEHR-toh]","english":"I''m going to the concert","example_es":"Esta noche voy al concierto.","example_en":"Tonight I''m going to the concert."},
      {"word":"Mi cantante favorito","phonetic":"[mee kahn-TAHN-teh fah-boh-REE-toh]","english":"My favorite singer","example_es":"Mi cantante favorito es español.","example_en":"My favorite singer is Spanish."},
      {"word":"Pongo música","phonetic":"[POHN-goh MOO-see-kah]","english":"I put on music","example_es":"Pongo música por la mañana.","example_en":"I put on music in the morning."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Tú","spanish":"Mi cantante favorito es Rosalía.","english":"My favorite singer is Rosalía."},
      {"speaker":"Amigo","spanish":"¡A mí también me gusta!","english":"I like her too!"},
      {"speaker":"Tú","spanish":"¿Vas a su concierto?","english":"Are you going to her concert?"},
      {"speaker":"Amigo","spanish":"Sí, ya tengo la entrada.","english":"Yes, I already have the ticket."}
    ]'::jsonb,
    grammar_note = 'YA = "already". YA TENGO = I already have. YA is one of the most common words in conversational Spanish.'
  where id = v_l5;

  update public.lessons set
    intro = 'Read about a young Spanish band that started in a garage.',
    vocab_items = '[
      {"word":"empezar","phonetic":"[ehm-peh-SAR]","english":"to start","example_es":"La banda empezó en 2015.","example_en":"The band started in 2015."},
      {"word":"el disco","phonetic":"[ehl DEES-koh]","english":"the album","example_es":"Lanzaron su primer disco.","example_en":"They released their first album."},
      {"word":"famoso","phonetic":"[fah-MOH-soh]","english":"famous","example_es":"Es una banda muy famosa.","example_en":"It''s a very famous band."},
      {"word":"el éxito","phonetic":"[ehl EHK-see-toh]","english":"the hit / success","example_es":"Su éxito más grande.","example_en":"Their biggest hit."},
      {"word":"actuar","phonetic":"[ahk-TWAR]","english":"to perform","example_es":"Actúan en Madrid.","example_en":"They perform in Madrid."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"La banda Los Vivos empezó en un garaje de Madrid.","english":"The band Los Vivos started in a garage in Madrid."},
      {"speaker":"Texto","spanish":"Lanzaron su primer disco hace cinco años.","english":"They released their first album five years ago."},
      {"speaker":"Texto","spanish":"Ahora son muy famosos y tienen muchos éxitos.","english":"Now they are very famous and have many hits."},
      {"speaker":"Texto","spanish":"Este verano actúan en grandes festivales.","english":"This summer they perform at big festivals."}
    ]'::jsonb,
    grammar_note = 'HACE + period of time = "ago": hace cinco años = five years ago. HACE never changes form for this meaning.'
  where id = v_l6;

  update public.lessons set
    intro = 'Write four sentences about a band or singer you love.',
    vocab_items = '[
      {"word":"se llama","phonetic":"[seh YAH-mah]","english":"is called","example_es":"Mi banda favorita se llama…","example_en":"My favorite band is called…"},
      {"word":"de origen","phonetic":"[deh oh-REE-hehn]","english":"of origin","example_es":"Una banda de origen español.","example_en":"A band of Spanish origin."},
      {"word":"escucharlos","phonetic":"[ehs-koo-CHAR-lohs]","english":"to listen to them","example_es":"Me encanta escucharlos.","example_en":"I love listening to them."},
      {"word":"el álbum","phonetic":"[ehl AHL-boom]","english":"the album","example_es":"Tiene tres álbumes.","example_en":"They have three albums."},
      {"word":"recomendar","phonetic":"[rreh-koh-mehn-DAR]","english":"to recommend","example_es":"Te los recomiendo.","example_en":"I recommend them to you."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Modelo","spanish":"Mi banda favorita se llama Vetusta Morla.","english":"My favorite band is called Vetusta Morla."},
      {"speaker":"Modelo","spanish":"Es una banda de origen español.","english":"It''s a band of Spanish origin."},
      {"speaker":"Modelo","spanish":"Me encanta escucharlos cuando viajo en tren.","english":"I love listening to them when I travel by train."},
      {"speaker":"Modelo","spanish":"Te los recomiendo mucho.","english":"I really recommend them to you."}
    ]'::jsonb,
    grammar_note = 'TE LOS RECOMIENDO = I recommend them TO YOU. TE = to you, LOS = them. Two pronouns can stack before the verb: te los, te lo, me las.'
  where id = v_l7;

  -- ============== A2.11 TRAVEL PLANNING ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Travel Planning';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'Vocabulary for booking a trip: flights, hotels, tickets and luggage.',
    vocab_items = '[
      {"word":"el vuelo","phonetic":"[ehl BWEH-loh]","english":"the flight","example_es":"El vuelo sale a las nueve.","example_en":"The flight leaves at nine."},
      {"word":"el hotel","phonetic":"[ehl oh-TEHL]","english":"the hotel","example_es":"El hotel está cerca del centro.","example_en":"The hotel is near the centre."},
      {"word":"el billete","phonetic":"[ehl bee-YEH-teh]","english":"the ticket","example_es":"Compro un billete de tren.","example_en":"I buy a train ticket."},
      {"word":"la maleta","phonetic":"[lah mah-LEH-tah]","english":"the suitcase","example_es":"Hago la maleta.","example_en":"I pack my suitcase."},
      {"word":"reservar","phonetic":"[rreh-sehr-BAR]","english":"to book","example_es":"Voy a reservar un hotel.","example_en":"I''m going to book a hotel."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Iván","spanish":"Voy a reservar un hotel en Barcelona.","english":"I''m going to book a hotel in Barcelona."},
      {"speaker":"Lola","spanish":"¿Cuándo viajas?","english":"When are you traveling?"},
      {"speaker":"Iván","spanish":"El veinte de julio. Ya compré el billete.","english":"July 20th. I already bought the ticket."},
      {"speaker":"Lola","spanish":"Yo tengo que hacer la maleta todavía.","english":"I still have to pack my suitcase."}
    ]'::jsonb,
    grammar_note = 'HACER LA MALETA = literally "to make the suitcase" = to pack. This is a fixed expression — don''t say "empaquetar".'
  where id = v_l1;

  update public.lessons set
    intro = 'IR A + INFINITIVE is the easy near-future. Pair it with PARA + destination.',
    vocab_items = '[
      {"word":"voy a viajar","phonetic":"[BOY ah byah-HAR]","english":"I''m going to travel","example_es":"Voy a viajar este verano.","example_en":"I''m going to travel this summer."},
      {"word":"para","phonetic":"[PAH-rah]","english":"for / to (destination)","example_es":"Un billete para Madrid.","example_en":"A ticket to Madrid."},
      {"word":"de ida y vuelta","phonetic":"[deh EE-dah ee BWEHL-tah]","english":"round trip","example_es":"Un billete de ida y vuelta.","example_en":"A round-trip ticket."},
      {"word":"sólo ida","phonetic":"[SOH-loh EE-dah]","english":"one way","example_es":"Un billete sólo de ida.","example_en":"A one-way ticket."},
      {"word":"el destino","phonetic":"[ehl dehs-TEE-noh]","english":"the destination","example_es":"¿Cuál es tu destino?","example_en":"What is your destination?"}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Agente","spanish":"¿Cuál es su destino?","english":"What is your destination?"},
      {"speaker":"Cliente","spanish":"Quiero un billete para París.","english":"I want a ticket to Paris."},
      {"speaker":"Agente","spanish":"¿De ida y vuelta?","english":"Round trip?"},
      {"speaker":"Cliente","spanish":"Sólo ida, por favor.","english":"One way, please."}
    ]'::jsonb,
    grammar_note = 'PARA + place = destination ("to" a place). PARA + time = deadline ("by" a time). PARA Madrid = to Madrid. PARA el lunes = by Monday.'
  where id = v_l2;

  update public.lessons set
    intro = 'High-frequency phrases at an airport, train station, or hotel reception.',
    vocab_items = '[
      {"word":"hacer una reserva","phonetic":"[ah-SEHR OO-nah rreh-SEHR-bah]","english":"to make a booking","example_es":"Quiero hacer una reserva.","example_en":"I want to make a booking."},
      {"word":"la recepción","phonetic":"[lah rreh-sehp-SYOHN]","english":"the reception","example_es":"Voy a la recepción.","example_en":"I go to the reception."},
      {"word":"el pasaporte","phonetic":"[ehl pah-sah-POHR-teh]","english":"the passport","example_es":"Aquí está mi pasaporte.","example_en":"Here is my passport."},
      {"word":"la llave","phonetic":"[lah YAH-beh]","english":"the key","example_es":"Pido la llave de mi habitación.","example_en":"I ask for the key to my room."},
      {"word":"la habitación","phonetic":"[lah ah-bee-tah-SYOHN]","english":"the room","example_es":"La habitación 305.","example_en":"Room 305."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Recepcionista","spanish":"Buenas tardes, ¿tiene una reserva?","english":"Good afternoon, do you have a reservation?"},
      {"speaker":"Tú","spanish":"Sí, a nombre de López. Aquí mi pasaporte.","english":"Yes, under López. Here is my passport."},
      {"speaker":"Recepcionista","spanish":"Su habitación es la 305. Aquí la llave.","english":"Your room is 305. Here is the key."},
      {"speaker":"Tú","spanish":"Gracias.","english":"Thank you."}
    ]'::jsonb,
    grammar_note = 'A NOMBRE DE = under the name of. Used for reservations: una reserva a nombre de García. Very useful at hotels, restaurants and airlines.'
  where id = v_l3;

  update public.lessons set
    intro = 'Listen to typical travel-agency conversations.',
    vocab_items = '[
      {"word":"el aeropuerto","phonetic":"[ehl ah-eh-roh-PWEHR-toh]","english":"the airport","example_es":"Voy al aeropuerto en taxi.","example_en":"I go to the airport by taxi."},
      {"word":"la puerta de embarque","phonetic":"[lah PWEHR-tah deh ehm-BAR-keh]","english":"the boarding gate","example_es":"Mi puerta de embarque es la 12.","example_en":"My boarding gate is 12."},
      {"word":"facturar","phonetic":"[fahk-too-RAR]","english":"to check in (luggage)","example_es":"Facturo dos maletas.","example_en":"I check in two suitcases."},
      {"word":"despegar","phonetic":"[dehs-peh-GAR]","english":"to take off","example_es":"El avión despega a las ocho.","example_en":"The plane takes off at eight."},
      {"word":"aterrizar","phonetic":"[ah-teh-rree-SAR]","english":"to land","example_es":"Aterrizamos a las diez.","example_en":"We land at ten."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Voz","spanish":"Su vuelo a Madrid despega a las ocho.","english":"Your flight to Madrid takes off at eight."},
      {"speaker":"Voz","spanish":"Por favor, facture sus maletas ahora.","english":"Please check in your luggage now."},
      {"speaker":"Voz","spanish":"La puerta de embarque es la doce.","english":"The boarding gate is twelve."},
      {"speaker":"Voz","spanish":"Aterrizamos en Madrid a las diez en punto.","english":"We land in Madrid at ten sharp."}
    ]'::jsonb,
    grammar_note = 'EN PUNTO = on the dot / exactly. A las diez EN PUNTO = at exactly ten o''clock.'
  where id = v_l4;

  update public.lessons set
    intro = 'Practice booking and asking for travel info out loud.',
    vocab_items = '[
      {"word":"Quiero reservar un vuelo","phonetic":"[KYEH-roh rreh-sehr-BAR oon BWEH-loh]","english":"I want to book a flight","example_es":"Quiero reservar un vuelo a Roma.","example_en":"I want to book a flight to Rome."},
      {"word":"Necesito un hotel","phonetic":"[neh-seh-SEE-toh oon oh-TEHL]","english":"I need a hotel","example_es":"Necesito un hotel barato.","example_en":"I need a cheap hotel."},
      {"word":"¿Cuánto cuesta?","phonetic":"[KWAHN-toh KWEHS-tah]","english":"How much is it?","example_es":"¿Cuánto cuesta el billete?","example_en":"How much is the ticket?"},
      {"word":"¿A qué hora sale?","phonetic":"[ah keh OH-rah SAH-leh]","english":"What time does it leave?","example_es":"¿A qué hora sale el tren?","example_en":"What time does the train leave?"},
      {"word":"Aquí mi pasaporte","phonetic":"[ah-KEE mee pah-sah-POHR-teh]","english":"Here is my passport","example_es":"Aquí mi pasaporte y mi billete.","example_en":"Here is my passport and ticket."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Tú","spanish":"Quiero reservar un vuelo a Roma.","english":"I want to book a flight to Rome."},
      {"speaker":"Agente","spanish":"¿Para cuándo?","english":"For when?"},
      {"speaker":"Tú","spanish":"Para el cinco de julio.","english":"For July fifth."},
      {"speaker":"Agente","spanish":"De acuerdo. ¿Sólo ida?","english":"Alright. One way only?"}
    ]'::jsonb,
    grammar_note = 'PARA CUÁNDO? = for when? PARA + day/date is the planning preposition: para el lunes, para el cinco de julio.'
  where id = v_l5;

  update public.lessons set
    intro = 'Read Carla''s travel-planning blog entry.',
    vocab_items = '[
      {"word":"el itinerario","phonetic":"[ehl ee-tee-neh-RAH-ryoh]","english":"the itinerary","example_es":"Mi itinerario está listo.","example_en":"My itinerary is ready."},
      {"word":"organizar el viaje","phonetic":"[ohr-gah-nee-SAR ehl BYAH-heh]","english":"to plan the trip","example_es":"Estoy organizando el viaje.","example_en":"I''m planning the trip."},
      {"word":"alojarse","phonetic":"[ah-loh-HAR-seh]","english":"to stay","example_es":"Me alojo en un hostal.","example_en":"I stay at a hostel."},
      {"word":"visitar","phonetic":"[bee-see-TAR]","english":"to visit","example_es":"Voy a visitar tres ciudades.","example_en":"I''m going to visit three cities."},
      {"word":"el presupuesto","phonetic":"[ehl preh-soo-PWEHS-toh]","english":"the budget","example_es":"Mi presupuesto es de mil euros.","example_en":"My budget is one thousand euros."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Carla está organizando su viaje por España.","english":"Carla is planning her trip around Spain."},
      {"speaker":"Texto","spanish":"Va a visitar Madrid, Sevilla y Barcelona en dos semanas.","english":"She''s going to visit Madrid, Seville and Barcelona in two weeks."},
      {"speaker":"Texto","spanish":"En cada ciudad se aloja en un hostal pequeño.","english":"In each city she stays at a small hostel."},
      {"speaker":"Texto","spanish":"Su presupuesto es de mil euros para todo.","english":"Her budget is one thousand euros for everything."}
    ]'::jsonb,
    grammar_note = 'EN CADA + place = in each. EN CADA ciudad = in each city. EN CADA país = in each country. CADA never changes form.'
  where id = v_l6;

  update public.lessons set
    intro = 'Write four sentences planning your next trip.',
    vocab_items = '[
      {"word":"este verano","phonetic":"[EHS-teh beh-RAH-noh]","english":"this summer","example_es":"Este verano viajo a México.","example_en":"This summer I travel to Mexico."},
      {"word":"voy a viajar","phonetic":"[BOY ah byah-HAR]","english":"I''m going to travel","example_es":"Voy a viajar a Japón.","example_en":"I''m going to travel to Japan."},
      {"word":"durante","phonetic":"[doo-RAHN-teh]","english":"during / for","example_es":"Durante dos semanas.","example_en":"For two weeks."},
      {"word":"con mi pareja","phonetic":"[kohn mee pah-REH-hah]","english":"with my partner","example_es":"Viajo con mi pareja.","example_en":"I travel with my partner."},
      {"word":"voy a quedarme","phonetic":"[BOY ah keh-DAR-meh]","english":"I''m going to stay","example_es":"Voy a quedarme en un hotel.","example_en":"I''m going to stay in a hotel."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Modelo","spanish":"Este verano voy a viajar a Italia.","english":"This summer I''m going to travel to Italy."},
      {"speaker":"Modelo","spanish":"Voy con mi pareja durante diez días.","english":"I''m going with my partner for ten days."},
      {"speaker":"Modelo","spanish":"Vamos a visitar Roma, Florencia y Venecia.","english":"We''re going to visit Rome, Florence and Venice."},
      {"speaker":"Modelo","spanish":"Vamos a quedarnos en hoteles pequeños.","english":"We''re going to stay in small hotels."}
    ]'::jsonb,
    grammar_note = 'When IR A + INFINITIVE includes a reflexive verb, the pronoun (me/te/se/nos/os/se) usually attaches to the infinitive: voy a quedarME, va a levantarSE. You can also place it before: ME voy a quedar.'
  where id = v_l7;

  -- ============== A2.12 RESTAURANTS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Restaurants';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'Core restaurant vocabulary so you can sit down, order and pay.',
    vocab_items = '[
      {"word":"el menú","phonetic":"[ehl meh-NOO]","english":"the menu","example_es":"¿Me trae el menú?","example_en":"Could you bring me the menu?"},
      {"word":"el camarero / la camarera","phonetic":"[ehl/lah kah-mah-REH-roh]","english":"waiter / waitress","example_es":"El camarero es amable.","example_en":"The waiter is friendly."},
      {"word":"el plato","phonetic":"[ehl PLAH-toh]","english":"the dish","example_es":"Este plato es delicioso.","example_en":"This dish is delicious."},
      {"word":"la cuenta","phonetic":"[lah KWEHN-tah]","english":"the bill","example_es":"La cuenta, por favor.","example_en":"The bill, please."},
      {"word":"la propina","phonetic":"[lah proh-PEE-nah]","english":"the tip","example_es":"Dejo una propina.","example_en":"I leave a tip."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Cliente","spanish":"Hola, una mesa para dos, por favor.","english":"Hi, a table for two, please."},
      {"speaker":"Camarera","spanish":"Por aquí. Aquí está el menú.","english":"This way. Here is the menu."},
      {"speaker":"Cliente","spanish":"Gracias. ¿Cuál es el plato del día?","english":"Thanks. What''s the dish of the day?"},
      {"speaker":"Camarera","spanish":"Hoy es paella valenciana.","english":"Today it''s Valencian paella."}
    ]'::jsonb,
    grammar_note = 'In Spain you often hear ¿ME TRAE…? (could you bring me…?) — this uses the polite usted form of TRAER. Outside Spain, ¿ME TRAES…? with tú is also common.'
  where id = v_l1;

  update public.lessons set
    intro = 'QUERER + noun and TRAER are the verbs you''ll hear and use most when ordering.',
    vocab_items = '[
      {"word":"quiero","phonetic":"[KYEH-roh]","english":"I want","example_es":"Quiero un café, por favor.","example_en":"I want a coffee, please."},
      {"word":"traer","phonetic":"[trah-EHR]","english":"to bring","example_es":"¿Me trae agua?","example_en":"Could you bring me water?"},
      {"word":"recomendar","phonetic":"[rreh-koh-mehn-DAR]","english":"to recommend","example_es":"¿Qué me recomienda?","example_en":"What do you recommend?"},
      {"word":"para mí","phonetic":"[PAH-rah mee]","english":"for me","example_es":"Para mí, una ensalada.","example_en":"For me, a salad."},
      {"word":"sin","phonetic":"[seen]","english":"without","example_es":"Una pizza sin queso.","example_en":"A pizza without cheese."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Camarero","spanish":"¿Qué van a tomar?","english":"What are you going to have?"},
      {"speaker":"Tú","spanish":"Para mí, una ensalada sin tomate.","english":"For me, a salad without tomato."},
      {"speaker":"Amiga","spanish":"Yo quiero la paella.","english":"I want the paella."},
      {"speaker":"Camarero","spanish":"¿Y para beber?","english":"And to drink?"}
    ]'::jsonb,
    grammar_note = 'TOMAR is used for both eating AND drinking in restaurants: ¿qué vas a tomar? = what are you going to have? (food or drink).'
  where id = v_l2;

  update public.lessons set
    intro = 'Phrases for the full restaurant journey: from "table for two" to "the bill, please".',
    vocab_items = '[
      {"word":"Una mesa para dos","phonetic":"[OO-nah MEH-sah PAH-rah dohs]","english":"A table for two","example_es":"Una mesa para dos, por favor.","example_en":"A table for two, please."},
      {"word":"¿Tienen…?","phonetic":"[TYEH-nehn]","english":"Do you have…?","example_es":"¿Tienen pan sin gluten?","example_en":"Do you have gluten-free bread?"},
      {"word":"de primero","phonetic":"[deh pree-MEH-roh]","english":"as a starter","example_es":"De primero, sopa.","example_en":"As a starter, soup."},
      {"word":"de segundo","phonetic":"[deh seh-GOON-doh]","english":"as a main","example_es":"De segundo, pescado.","example_en":"As a main, fish."},
      {"word":"la cuenta, por favor","phonetic":"[lah KWEHN-tah pohr fah-BOHR]","english":"the bill, please","example_es":"La cuenta, por favor.","example_en":"The bill, please."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Tú","spanish":"De primero, ensalada. De segundo, pollo.","english":"As a starter, salad. As a main, chicken."},
      {"speaker":"Camarero","spanish":"¿Para beber?","english":"To drink?"},
      {"speaker":"Tú","spanish":"Una copa de vino tinto.","english":"A glass of red wine."},
      {"speaker":"Camarero","spanish":"Muy bien.","english":"Very well."}
    ]'::jsonb,
    grammar_note = 'A Spanish meal usually has DE PRIMERO (starter), DE SEGUNDO (main) and DE POSTRE (dessert). This is the menú del día format.'
  where id = v_l3;

  update public.lessons set
    intro = 'Listen to a typical restaurant exchange between waiter and guests.',
    vocab_items = '[
      {"word":"la reserva","phonetic":"[lah rreh-SEHR-bah]","english":"the reservation","example_es":"Tengo una reserva.","example_en":"I have a reservation."},
      {"word":"a las ocho","phonetic":"[ah lahs OH-choh]","english":"at eight","example_es":"A las ocho de la tarde.","example_en":"At eight in the evening."},
      {"word":"el postre","phonetic":"[ehl POHS-treh]","english":"the dessert","example_es":"De postre, helado.","example_en":"For dessert, ice cream."},
      {"word":"el agua con gas","phonetic":"[ehl AH-gwah kohn gahs]","english":"sparkling water","example_es":"Una botella de agua con gas.","example_en":"A bottle of sparkling water."},
      {"word":"la copa","phonetic":"[lah KOH-pah]","english":"the glass (wine)","example_es":"Una copa de vino.","example_en":"A glass of wine."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Camarero","spanish":"Buenas noches. ¿Tienen reserva?","english":"Good evening. Do you have a reservation?"},
      {"speaker":"Cliente","spanish":"Sí, a nombre de Ruiz, a las ocho.","english":"Yes, under Ruiz, at eight."},
      {"speaker":"Camarero","spanish":"Síganme, por favor.","english":"Follow me, please."},
      {"speaker":"Cliente","spanish":"De primero queremos una ensalada para compartir.","english":"As a starter we want a salad to share."}
    ]'::jsonb,
    grammar_note = 'PARA COMPARTIR = to share. PARA + INFINITIVE always = "to / in order to". Very common in restaurant talk.'
  where id = v_l4;

  update public.lessons set
    intro = 'Practice ordering food and asking for the bill out loud.',
    vocab_items = '[
      {"word":"Quiero la paella","phonetic":"[KYEH-roh lah pah-EH-yah]","english":"I want the paella","example_es":"Quiero la paella de mariscos.","example_en":"I want the seafood paella."},
      {"word":"Una mesa para dos","phonetic":"[OO-nah MEH-sah PAH-rah dohs]","english":"A table for two","example_es":"Una mesa para dos en la terraza.","example_en":"A table for two on the terrace."},
      {"word":"¿Me trae la carta?","phonetic":"[meh TRAH-eh lah KAR-tah]","english":"Could you bring me the menu?","example_es":"¿Me trae la carta, por favor?","example_en":"Could you bring me the menu, please?"},
      {"word":"La cuenta","phonetic":"[lah KWEHN-tah]","english":"The bill","example_es":"La cuenta, cuando pueda.","example_en":"The bill, whenever you can."},
      {"word":"Estaba delicioso","phonetic":"[ehs-TAH-bah deh-lee-SYOH-soh]","english":"It was delicious","example_es":"Todo estaba delicioso.","example_en":"Everything was delicious."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Tú","spanish":"Una mesa para dos, por favor.","english":"A table for two, please."},
      {"speaker":"Camarera","spanish":"¿Dentro o en la terraza?","english":"Inside or on the terrace?"},
      {"speaker":"Tú","spanish":"En la terraza.","english":"On the terrace."},
      {"speaker":"Camarera","spanish":"Aquí la carta.","english":"Here is the menu."}
    ]'::jsonb,
    grammar_note = 'LA CARTA (the menu, food/drink list) vs EL MENÚ (the fixed menu/set meal). Both are used, but CARTA is more common in Spain.'
  where id = v_l5;

  update public.lessons set
    intro = 'Read a short review of a Madrid restaurant.',
    vocab_items = '[
      {"word":"el restaurante","phonetic":"[ehl rrehs-tau-RAHN-teh]","english":"the restaurant","example_es":"El restaurante está en el centro.","example_en":"The restaurant is in the centre."},
      {"word":"la comida","phonetic":"[lah koh-MEE-dah]","english":"the food","example_es":"La comida es excelente.","example_en":"The food is excellent."},
      {"word":"el ambiente","phonetic":"[ehl ahm-BYEHN-teh]","english":"the atmosphere","example_es":"El ambiente es agradable.","example_en":"The atmosphere is pleasant."},
      {"word":"el precio","phonetic":"[ehl PREH-syoh]","english":"the price","example_es":"El precio es razonable.","example_en":"The price is reasonable."},
      {"word":"volver","phonetic":"[bohl-BEHR]","english":"to come back","example_es":"Voy a volver pronto.","example_en":"I''m going to come back soon."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Anoche cené en un restaurante nuevo en Madrid.","english":"Last night I had dinner at a new restaurant in Madrid."},
      {"speaker":"Texto","spanish":"La comida estaba deliciosa y el ambiente era muy agradable.","english":"The food was delicious and the atmosphere was very pleasant."},
      {"speaker":"Texto","spanish":"El camarero fue muy amable con nosotros.","english":"The waiter was very kind to us."},
      {"speaker":"Texto","spanish":"El precio es razonable. Voy a volver pronto.","english":"The price is reasonable. I''m going to come back soon."}
    ]'::jsonb,
    grammar_note = 'Notice the past tenses: estaba (imperfect, ongoing), fue (preterite, single action), era (imperfect, description). Don''t worry — just recognize them when reading.'
  where id = v_l6;

  update public.lessons set
    intro = 'Write a four-sentence review of a restaurant you''ve been to.',
    vocab_items = '[
      {"word":"el camarero amable","phonetic":"[ehl kah-mah-REH-roh ah-MAH-bleh]","english":"the friendly waiter","example_es":"El camarero amable nos atendió.","example_en":"The friendly waiter served us."},
      {"word":"recomendar","phonetic":"[rreh-koh-mehn-DAR]","english":"to recommend","example_es":"Te lo recomiendo.","example_en":"I recommend it to you."},
      {"word":"caro","phonetic":"[KAH-roh]","english":"expensive","example_es":"Es un poco caro.","example_en":"It''s a little expensive."},
      {"word":"barato","phonetic":"[bah-RAH-toh]","english":"cheap","example_es":"Es bastante barato.","example_en":"It''s pretty cheap."},
      {"word":"volveré","phonetic":"[bohl-beh-REH]","english":"I''ll come back","example_es":"Volveré con mi familia.","example_en":"I''ll come back with my family."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Modelo","spanish":"Comí en un restaurante italiano cerca de mi casa.","english":"I ate at an Italian restaurant near my home."},
      {"speaker":"Modelo","spanish":"La pasta estaba deliciosa y la pizza también.","english":"The pasta was delicious and the pizza too."},
      {"speaker":"Modelo","spanish":"El camarero fue muy amable y no era caro.","english":"The waiter was very kind and it wasn''t expensive."},
      {"speaker":"Modelo","spanish":"Volveré pronto con mi familia.","english":"I''ll come back soon with my family."}
    ]'::jsonb,
    grammar_note = 'VOLVERÉ is the simple future of VOLVER: volveré, volverás, volverá, volveremos, volveréis, volverán. Use it for promises and predictions.'
  where id = v_l7;

  -- ============== A2.13 SCHOOL ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'School';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'Core school vocabulary — subjects, teachers, exams and homework.',
    vocab_items = '[
      {"word":"el profesor / la profesora","phonetic":"[ehl/lah proh-feh-SOHR]","english":"teacher","example_es":"Mi profesora es paciente.","example_en":"My teacher is patient."},
      {"word":"la asignatura","phonetic":"[lah ah-seeg-nah-TOO-rah]","english":"the subject","example_es":"Mi asignatura favorita es historia.","example_en":"My favorite subject is history."},
      {"word":"el examen","phonetic":"[ehl ehk-SAH-mehn]","english":"the exam","example_es":"Tengo un examen mañana.","example_en":"I have an exam tomorrow."},
      {"word":"los deberes","phonetic":"[lohs deh-BEH-rehs]","english":"the homework","example_es":"Hago los deberes en casa.","example_en":"I do my homework at home."},
      {"word":"aprobar","phonetic":"[ah-proh-BAR]","english":"to pass","example_es":"Aprobé el examen.","example_en":"I passed the exam."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Madre","spanish":"¿Tienes deberes hoy?","english":"Do you have homework today?"},
      {"speaker":"Hijo","spanish":"Sí, de matemáticas y de historia.","english":"Yes, math and history."},
      {"speaker":"Madre","spanish":"¿Y el examen de inglés?","english":"And the English exam?"},
      {"speaker":"Hijo","spanish":"Aprobé. Saqué un ocho.","english":"I passed. I got an eight."}
    ]'::jsonb,
    grammar_note = 'Spanish grades are usually out of 10: aprobado is 5+, notable is 7+, sobresaliente is 9+. SACAR + grade = to get a grade: saqué un ocho.'
  where id = v_l1;

  update public.lessons set
    intro = 'TENER QUE + INFINITIVE means "to have to". The most useful obligation phrase in school Spanish.',
    vocab_items = '[
      {"word":"tener que","phonetic":"[teh-NEHR keh]","english":"to have to","example_es":"Tengo que estudiar.","example_en":"I have to study."},
      {"word":"estudiar","phonetic":"[ehs-too-DYAR]","english":"to study","example_es":"Estudio matemáticas.","example_en":"I study math."},
      {"word":"aprender","phonetic":"[ah-prehn-DEHR]","english":"to learn","example_es":"Aprendo español.","example_en":"I''m learning Spanish."},
      {"word":"entregar","phonetic":"[ehn-treh-GAR]","english":"to hand in","example_es":"Tengo que entregar el trabajo.","example_en":"I have to hand in the assignment."},
      {"word":"el trabajo","phonetic":"[ehl trah-BAH-hoh]","english":"the assignment","example_es":"El trabajo es para el lunes.","example_en":"The assignment is for Monday."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Sofía","spanish":"¿Qué tienes que hacer esta noche?","english":"What do you have to do tonight?"},
      {"speaker":"Pablo","spanish":"Tengo que estudiar para el examen de mañana.","english":"I have to study for tomorrow''s exam."},
      {"speaker":"Sofía","spanish":"¿Y el trabajo de historia?","english":"And the history assignment?"},
      {"speaker":"Pablo","spanish":"Lo tengo que entregar el viernes.","english":"I have to hand it in on Friday."}
    ]'::jsonb,
    grammar_note = 'TENER QUE + INFINITIVE is the obligation pattern: tengo QUE estudiar = I have to study. Don''t forget the QUE.'
  where id = v_l2;

  update public.lessons set
    intro = 'Phrases for life at school: in class, at the cafeteria, after the bell.',
    vocab_items = '[
      {"word":"el recreo","phonetic":"[ehl rreh-KREH-oh]","english":"recess / break","example_es":"En el recreo juego con mis amigos.","example_en":"At recess I play with my friends."},
      {"word":"la clase","phonetic":"[lah KLAH-seh]","english":"the class","example_es":"La clase empieza a las nueve.","example_en":"Class starts at nine."},
      {"word":"el horario","phonetic":"[ehl oh-RAH-ryoh]","english":"the schedule","example_es":"Hoy mi horario es duro.","example_en":"Today my schedule is tough."},
      {"word":"la nota","phonetic":"[lah NOH-tah]","english":"the grade","example_es":"Saqué buena nota.","example_en":"I got a good grade."},
      {"word":"suspender","phonetic":"[soos-pehn-DEHR]","english":"to fail","example_es":"Suspendí matemáticas.","example_en":"I failed math."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Iván","spanish":"¿Tienes clase ahora?","english":"Do you have class now?"},
      {"speaker":"Eva","spanish":"Sí, de física. Después tengo recreo.","english":"Yes, physics. After I have recess."},
      {"speaker":"Iván","spanish":"¿Sacaste buena nota en el examen?","english":"Did you get a good grade on the exam?"},
      {"speaker":"Eva","spanish":"Sí, un nueve.","english":"Yes, a nine."}
    ]'::jsonb,
    grammar_note = 'APROBAR (to pass) vs SUSPENDER (to fail). Both are common in Spanish school slang.'
  where id = v_l3;

  update public.lessons set
    intro = 'Listen to school-day conversations between teens and teachers.',
    vocab_items = '[
      {"word":"el alumno / la alumna","phonetic":"[ehl/lah ah-LOOM-noh]","english":"student","example_es":"Los alumnos están en clase.","example_en":"The students are in class."},
      {"word":"el cuaderno","phonetic":"[ehl kwah-DEHR-noh]","english":"the notebook","example_es":"Abro mi cuaderno.","example_en":"I open my notebook."},
      {"word":"la mochila","phonetic":"[lah moh-CHEE-lah]","english":"the backpack","example_es":"Mi mochila está llena.","example_en":"My backpack is full."},
      {"word":"prestar","phonetic":"[prehs-TAR]","english":"to lend","example_es":"¿Me prestas un boli?","example_en":"Can you lend me a pen?"},
      {"word":"el boli","phonetic":"[ehl BOH-lee]","english":"the pen","example_es":"Necesito un boli.","example_en":"I need a pen."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Profesora","spanish":"Abrid los cuadernos en la página 25.","english":"Open your notebooks to page 25."},
      {"speaker":"Alumno","spanish":"¿Me prestas un boli?","english":"Can you lend me a pen?"},
      {"speaker":"Alumna","spanish":"Sí, toma.","english":"Yes, here."},
      {"speaker":"Profesora","spanish":"Hoy tenemos examen sorpresa.","english":"Today we have a surprise exam."}
    ]'::jsonb,
    grammar_note = 'ABRID is the vosotros command (in Spain) — used when speaking to a group of friends or students. The form is the infinitive minus -r plus -d: abrir → abrid.'
  where id = v_l4;

  update public.lessons set
    intro = 'Say school phrases out loud — schedule, subjects, exams.',
    vocab_items = '[
      {"word":"Tengo clase de matemáticas","phonetic":"[TEHN-goh KLAH-seh deh mah-teh-MAH-tee-kahs]","english":"I have math class","example_es":"Tengo clase de matemáticas a las diez.","example_en":"I have math class at ten."},
      {"word":"Mi asignatura favorita","phonetic":"[mee ah-seeg-nah-TOO-rah fah-boh-REE-tah]","english":"My favorite subject","example_es":"Mi asignatura favorita es arte.","example_en":"My favorite subject is art."},
      {"word":"Tengo que estudiar","phonetic":"[TEHN-goh keh ehs-too-DYAR]","english":"I have to study","example_es":"Tengo que estudiar para el examen.","example_en":"I have to study for the exam."},
      {"word":"Aprobé el examen","phonetic":"[ah-proh-BEH ehl ehk-SAH-mehn]","english":"I passed the exam","example_es":"Aprobé el examen con un ocho.","example_en":"I passed the exam with an eight."},
      {"word":"Mi profesora es buena","phonetic":"[mee proh-feh-SOH-rah ehs BWEH-nah]","english":"My teacher is good","example_es":"Mi profesora es buena y simpática.","example_en":"My teacher is good and nice."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Tú","spanish":"Mi asignatura favorita es historia.","english":"My favorite subject is history."},
      {"speaker":"Amigo","spanish":"¿Tienes muchos deberes hoy?","english":"Do you have a lot of homework today?"},
      {"speaker":"Tú","spanish":"Sí, tengo que estudiar para el examen del viernes.","english":"Yes, I have to study for Friday''s exam."},
      {"speaker":"Amigo","spanish":"Yo también. ¡Buena suerte!","english":"Me too. Good luck!"}
    ]'::jsonb,
    grammar_note = 'BUENA SUERTE = good luck. ¡Suerte! by itself also means "good luck!" in casual Spanish.'
  where id = v_l5;

  update public.lessons set
    intro = 'Read about Pablo''s typical school day.',
    vocab_items = '[
      {"word":"el instituto","phonetic":"[ehl een-stee-TOO-toh]","english":"high school","example_es":"Voy al instituto en autobús.","example_en":"I go to high school by bus."},
      {"word":"el bocadillo","phonetic":"[ehl boh-kah-DEE-yoh]","english":"the sandwich","example_es":"Como un bocadillo en el recreo.","example_en":"I eat a sandwich at recess."},
      {"word":"saber","phonetic":"[sah-BEHR]","english":"to know","example_es":"Sé mucha historia.","example_en":"I know a lot of history."},
      {"word":"el grupo","phonetic":"[ehl GROO-poh]","english":"the group","example_es":"Estudio en grupo.","example_en":"I study in a group."},
      {"word":"finalmente","phonetic":"[fee-nahl-MEHN-teh]","english":"finally","example_es":"Finalmente vuelvo a casa.","example_en":"Finally I come home."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Pablo va al instituto cada día en autobús.","english":"Pablo goes to high school every day by bus."},
      {"speaker":"Texto","spanish":"Su asignatura favorita es la historia.","english":"His favorite subject is history."},
      {"speaker":"Texto","spanish":"En el recreo come un bocadillo y juega al fútbol.","english":"At recess he eats a sandwich and plays football."},
      {"speaker":"Texto","spanish":"Por la tarde hace los deberes en grupo con sus amigos.","english":"In the afternoon he does his homework in a group with his friends."}
    ]'::jsonb,
    grammar_note = 'EN GRUPO = in a group. EN PAREJA = in a pair. EN EQUIPO = as a team. These prepositional phrases never need an article.'
  where id = v_l6;

  update public.lessons set
    intro = 'Write four sentences about your typical school or study day.',
    vocab_items = '[
      {"word":"voy al colegio","phonetic":"[BOY ahl koh-LEH-hyoh]","english":"I go to school","example_es":"Voy al colegio en bicicleta.","example_en":"I go to school by bike."},
      {"word":"empieza a las","phonetic":"[ehm-PYEH-sah ah lahs]","english":"starts at","example_es":"Empieza a las ocho y media.","example_en":"It starts at 8:30."},
      {"word":"durante","phonetic":"[doo-RAHN-teh]","english":"during / for","example_es":"Estudio durante dos horas.","example_en":"I study for two hours."},
      {"word":"en la biblioteca","phonetic":"[ehn lah bee-blyoh-TEH-kah]","english":"in the library","example_es":"Estudio en la biblioteca.","example_en":"I study in the library."},
      {"word":"el viernes","phonetic":"[ehl BYEHR-nehs]","english":"Friday","example_es":"El viernes salgo pronto.","example_en":"On Friday I get out early."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Modelo","spanish":"Voy al colegio en bicicleta a las ocho.","english":"I go to school by bike at eight."},
      {"speaker":"Modelo","spanish":"Mi asignatura favorita es la biología.","english":"My favorite subject is biology."},
      {"speaker":"Modelo","spanish":"Por la tarde estudio en la biblioteca durante dos horas.","english":"In the afternoon I study at the library for two hours."},
      {"speaker":"Modelo","spanish":"El viernes salgo pronto porque tengo poco trabajo.","english":"On Friday I get out early because I have little work."}
    ]'::jsonb,
    grammar_note = 'POCO (little, not much) and MUCHO (a lot) are adjectives — they agree with the noun: POCO trabajo, POCA tarea, POCOS deberes, POCAS notas.'
  where id = v_l7;

  -- ============== A2.14 TECHNOLOGY BASICS ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Technology Basics';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'The most useful tech words for everyday Spanish — phone, computer, internet.',
    vocab_items = '[
      {"word":"el móvil","phonetic":"[ehl MOH-beel]","english":"the mobile phone","example_es":"Mi móvil es nuevo.","example_en":"My phone is new."},
      {"word":"el ordenador","phonetic":"[ehl ohr-deh-nah-DOHR]","english":"the computer","example_es":"Trabajo en mi ordenador.","example_en":"I work on my computer."},
      {"word":"internet","phonetic":"[een-tehr-NEHT]","english":"internet","example_es":"No hay internet aquí.","example_en":"There''s no internet here."},
      {"word":"la contraseña","phonetic":"[lah kohn-trah-SEH-nyah]","english":"the password","example_es":"¿Cuál es la contraseña?","example_en":"What''s the password?"},
      {"word":"la aplicación","phonetic":"[lah ah-plee-kah-SYOHN]","english":"the app","example_es":"Descargo una aplicación nueva.","example_en":"I download a new app."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Pablo","spanish":"¿Tienes wifi en casa?","english":"Do you have wifi at home?"},
      {"speaker":"Eva","spanish":"Sí. La contraseña está en la puerta.","english":"Yes. The password is on the door."},
      {"speaker":"Pablo","spanish":"¿Y una aplicación para el metro?","english":"And an app for the metro?"},
      {"speaker":"Eva","spanish":"Descarga la app oficial, es gratis.","english":"Download the official app, it''s free."}
    ]'::jsonb,
    grammar_note = 'In Latin America "el ordenador" is more commonly "la computadora". Both are correct; the rest of tech vocabulary is identical.'
  where id = v_l1;

  update public.lessons set
    intro = 'PODER (can) + INFINITIVE is the everyday way to ask permission and describe what you''re able to do.',
    vocab_items = '[
      {"word":"poder","phonetic":"[poh-DEHR]","english":"can","example_es":"Puedo descargar la app.","example_en":"I can download the app."},
      {"word":"¿Puedo…?","phonetic":"[PWEH-doh]","english":"Can I…?","example_es":"¿Puedo usar tu ordenador?","example_en":"Can I use your computer?"},
      {"word":"funcionar","phonetic":"[foon-syoh-NAR]","english":"to work / function","example_es":"No funciona el wifi.","example_en":"The wifi isn''t working."},
      {"word":"el problema","phonetic":"[ehl proh-BLEH-mah]","english":"the problem","example_es":"Tengo un problema con el móvil.","example_en":"I have a problem with my phone."},
      {"word":"reiniciar","phonetic":"[rreh-ee-nee-SYAR]","english":"to restart","example_es":"Voy a reiniciar el ordenador.","example_en":"I''m going to restart the computer."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Tú","spanish":"No funciona mi móvil.","english":"My phone isn''t working."},
      {"speaker":"Amigo","spanish":"¿Puedes reiniciarlo?","english":"Can you restart it?"},
      {"speaker":"Tú","spanish":"Ya lo hice, pero sigue igual.","english":"I already did, but it''s still the same."},
      {"speaker":"Amigo","spanish":"Llévalo a una tienda.","english":"Take it to a shop."}
    ]'::jsonb,
    grammar_note = 'PODER is stem-changing (o → ue): puedo, puedes, puede, podemos, podéis, pueden. It''s the most common modal verb in Spanish.'
  where id = v_l2;

  update public.lessons set
    intro = 'Phrases for asking about wifi, fixing things, and using apps.',
    vocab_items = '[
      {"word":"No funciona","phonetic":"[noh foon-SYOH-nah]","english":"It''s not working","example_es":"No funciona mi cargador.","example_en":"My charger isn''t working."},
      {"word":"¿Cuál es la contraseña?","phonetic":"[KWAHL ehs lah kohn-trah-SEH-nyah]","english":"What''s the password?","example_es":"¿Cuál es la contraseña del wifi?","example_en":"What''s the wifi password?"},
      {"word":"descargar","phonetic":"[dehs-kahr-GAR]","english":"to download","example_es":"Descargo una película.","example_en":"I download a movie."},
      {"word":"actualizar","phonetic":"[ahk-twah-lee-SAR]","english":"to update","example_es":"Tengo que actualizar la app.","example_en":"I have to update the app."},
      {"word":"borrar","phonetic":"[boh-RRAR]","english":"to delete","example_es":"Borro la foto.","example_en":"I delete the photo."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Tú","spanish":"¿Cuál es la contraseña del wifi?","english":"What''s the wifi password?"},
      {"speaker":"Camarero","spanish":"Está en la pared.","english":"It''s on the wall."},
      {"speaker":"Tú","spanish":"Mi móvil no se conecta.","english":"My phone won''t connect."},
      {"speaker":"Camarero","spanish":"Reinicia el móvil.","english":"Restart the phone."}
    ]'::jsonb,
    grammar_note = 'CONECTARSE (to connect) is reflexive in tech contexts: mi móvil NO SE conecta = my phone won''t connect. The reflexive shows the device acting on itself.'
  where id = v_l3;

  update public.lessons set
    intro = 'Listen to tech-support and friend-to-friend tech conversations.',
    vocab_items = '[
      {"word":"la batería","phonetic":"[lah bah-teh-REE-ah]","english":"the battery","example_es":"La batería está baja.","example_en":"The battery is low."},
      {"word":"el cargador","phonetic":"[ehl kahr-gah-DOHR]","english":"the charger","example_es":"¿Tienes un cargador?","example_en":"Do you have a charger?"},
      {"word":"la pantalla","phonetic":"[lah pahn-TAH-yah]","english":"the screen","example_es":"La pantalla está rota.","example_en":"The screen is broken."},
      {"word":"el mensaje","phonetic":"[ehl mehn-SAH-heh]","english":"the message","example_es":"Recibí un mensaje.","example_en":"I got a message."},
      {"word":"enviar","phonetic":"[ehn-byahr]","english":"to send","example_es":"Envío un mensaje.","example_en":"I send a message."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Eva","spanish":"Mi batería está baja.","english":"My battery is low."},
      {"speaker":"Luis","spanish":"Aquí tienes un cargador.","english":"Here''s a charger."},
      {"speaker":"Eva","spanish":"Gracias. Tengo que enviar un mensaje importante.","english":"Thanks. I need to send an important message."},
      {"speaker":"Luis","spanish":"¿La pantalla funciona bien?","english":"Is the screen working OK?"}
    ]'::jsonb,
    grammar_note = 'Many tech nouns are feminine because of their endings: la pantalla, la batería, la aplicación. Memorize the article with the noun.'
  where id = v_l4;

  update public.lessons set
    intro = 'Practice common tech phrases out loud, especially asking for help.',
    vocab_items = '[
      {"word":"¿Me prestas tu cargador?","phonetic":"[meh PREHS-tahs too kahr-gah-DOHR]","english":"Can you lend me your charger?","example_es":"¿Me prestas tu cargador, por favor?","example_en":"Can you lend me your charger, please?"},
      {"word":"Mi móvil no funciona","phonetic":"[mee MOH-beel noh foon-SYOH-nah]","english":"My phone isn''t working","example_es":"Mi móvil no funciona desde ayer.","example_en":"My phone hasn''t worked since yesterday."},
      {"word":"Estoy descargando","phonetic":"[ehs-TOY dehs-kahr-GAHN-doh]","english":"I''m downloading","example_es":"Estoy descargando la actualización.","example_en":"I''m downloading the update."},
      {"word":"Tengo wifi","phonetic":"[TEHN-goh WEE-fee]","english":"I have wifi","example_es":"Tengo wifi en casa.","example_en":"I have wifi at home."},
      {"word":"Manda un mensaje","phonetic":"[MAHN-dah oon mehn-SAH-heh]","english":"Send a message","example_es":"Manda un mensaje cuando llegues.","example_en":"Send a message when you arrive."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Tú","spanish":"¿Me prestas tu cargador?","english":"Can you lend me your charger?"},
      {"speaker":"Amiga","spanish":"Claro, está en la mochila.","english":"Of course, it''s in my backpack."},
      {"speaker":"Tú","spanish":"Mi batería está al uno por ciento.","english":"My battery is at one percent."},
      {"speaker":"Amiga","spanish":"¡Rápido!","english":"Quick!"}
    ]'::jsonb,
    grammar_note = 'AL + percentage describes a level: al 50% (al cincuenta por ciento). For decimals use "coma": 7,5 (siete coma cinco).'
  where id = v_l5;

  update public.lessons set
    intro = 'Read a short article about a teen who is glued to her phone.',
    vocab_items = '[
      {"word":"el teléfono","phonetic":"[ehl teh-LEH-foh-noh]","english":"the phone","example_es":"Siempre mira el teléfono.","example_en":"She is always looking at the phone."},
      {"word":"adicto","phonetic":"[ah-DEEK-toh]","english":"addicted","example_es":"Es adicta a las redes.","example_en":"She''s addicted to social networks."},
      {"word":"las horas","phonetic":"[lahs OH-rahs]","english":"the hours","example_es":"Pasa muchas horas en línea.","example_en":"She spends many hours online."},
      {"word":"sin parar","phonetic":"[seen pah-RAR]","english":"non-stop","example_es":"Habla sin parar.","example_en":"She talks non-stop."},
      {"word":"preocuparse","phonetic":"[preh-oh-koo-PAR-seh]","english":"to worry","example_es":"Sus padres se preocupan.","example_en":"Her parents worry."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Marta tiene quince años y siempre mira el móvil.","english":"Marta is fifteen and always looks at her phone."},
      {"speaker":"Texto","spanish":"Pasa cinco horas al día en aplicaciones de redes sociales.","english":"She spends five hours a day on social media apps."},
      {"speaker":"Texto","spanish":"Sus padres se preocupan porque no estudia lo suficiente.","english":"Her parents worry because she doesn''t study enough."},
      {"speaker":"Texto","spanish":"Marta dice que no puede dejar el móvil.","english":"Marta says she can''t put down her phone."}
    ]'::jsonb,
    grammar_note = 'LO SUFICIENTE = enough (as a noun). With verbs use SUFICIENTE without LO: no come SUFICIENTE = doesn''t eat enough.'
  where id = v_l6;

  update public.lessons set
    intro = 'Write four sentences about how you use technology.',
    vocab_items = '[
      {"word":"uso mi móvil","phonetic":"[OO-soh mee MOH-beel]","english":"I use my phone","example_es":"Uso mi móvil para todo.","example_en":"I use my phone for everything."},
      {"word":"para","phonetic":"[PAH-rah]","english":"for","example_es":"Para escuchar música.","example_en":"For listening to music."},
      {"word":"todos los días","phonetic":"[TOH-dohs lohs DEE-ahs]","english":"every day","example_es":"Uso internet todos los días.","example_en":"I use the internet every day."},
      {"word":"a veces","phonetic":"[ah BEH-sehs]","english":"sometimes","example_es":"A veces juego en línea.","example_en":"Sometimes I play online."},
      {"word":"intento","phonetic":"[een-TEHN-toh]","english":"I try","example_es":"Intento no usarlo demasiado.","example_en":"I try not to use it too much."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Modelo","spanish":"Uso mi móvil todos los días para escuchar música.","english":"I use my phone every day to listen to music."},
      {"speaker":"Modelo","spanish":"Tengo aplicaciones para estudiar y para chatear.","english":"I have apps for studying and for chatting."},
      {"speaker":"Modelo","spanish":"A veces juego en línea con amigos.","english":"Sometimes I play online with friends."},
      {"speaker":"Modelo","spanish":"Intento no usarlo antes de dormir.","english":"I try not to use it before sleeping."}
    ]'::jsonb,
    grammar_note = 'PARA + INFINITIVE is the simplest way to give a purpose: uso el móvil PARA escuchar = I use the phone TO listen.'
  where id = v_l7;

  -- ============== A2.15 SOCIAL MEDIA ==============
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'A2' and title = 'Social Media';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;

  update public.lessons set
    intro = 'Social media vocabulary — posting, following, sharing, liking.',
    vocab_items = '[
      {"word":"publicar","phonetic":"[poo-blee-KAR]","english":"to post","example_es":"Publico fotos.","example_en":"I post photos."},
      {"word":"seguir","phonetic":"[seh-GEER]","english":"to follow","example_es":"Te sigo en Instagram.","example_en":"I follow you on Instagram."},
      {"word":"compartir","phonetic":"[kohm-pahr-TEER]","english":"to share","example_es":"Comparto el vídeo.","example_en":"I share the video."},
      {"word":"el like","phonetic":"[ehl LAH-eek]","english":"the like","example_es":"Tengo muchos likes.","example_en":"I have many likes."},
      {"word":"la foto","phonetic":"[lah FOH-toh]","english":"the photo","example_es":"Subo una foto.","example_en":"I upload a photo."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Mia","spanish":"¿Me sigues en TikTok?","english":"Do you follow me on TikTok?"},
      {"speaker":"Bruno","spanish":"Sí, te sigo. Tienes muchos likes.","english":"Yes, I follow you. You have many likes."},
      {"speaker":"Mia","spanish":"¿Compartes mis vídeos?","english":"Do you share my videos?"},
      {"speaker":"Bruno","spanish":"Claro, el último era muy gracioso.","english":"Of course, the last one was very funny."}
    ]'::jsonb,
    grammar_note = 'SEGUIR is stem-changing (e → i) and irregular yo: sigo, sigues, sigue, seguimos, seguís, siguen. Same pattern when talking about a feed: sigo a alguien (with personal "a").'
  where id = v_l1;

  update public.lessons set
    intro = 'PRESENT CONTINUOUS — ESTAR + verb -ANDO/-IENDO — is constant on social media.',
    vocab_items = '[
      {"word":"estoy publicando","phonetic":"[ehs-TOY poo-blee-KAHN-doh]","english":"I''m posting","example_es":"Estoy publicando una foto ahora.","example_en":"I''m posting a photo now."},
      {"word":"estoy mirando","phonetic":"[ehs-TOY mee-RAHN-doh]","english":"I''m watching","example_es":"Estoy mirando un vídeo.","example_en":"I''m watching a video."},
      {"word":"estoy escribiendo","phonetic":"[ehs-TOY ehs-kree-BYEHN-doh]","english":"I''m writing","example_es":"Estoy escribiendo un comentario.","example_en":"I''m writing a comment."},
      {"word":"el comentario","phonetic":"[ehl koh-mehn-TAH-ryoh]","english":"the comment","example_es":"Dejo un comentario.","example_en":"I leave a comment."},
      {"word":"el seguidor","phonetic":"[ehl seh-gee-DOHR]","english":"the follower","example_es":"Tengo mil seguidores.","example_en":"I have a thousand followers."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Carla","spanish":"¿Qué estás haciendo?","english":"What are you doing?"},
      {"speaker":"Tú","spanish":"Estoy publicando una historia.","english":"I''m posting a story."},
      {"speaker":"Carla","spanish":"Yo estoy escribiendo un comentario.","english":"I''m writing a comment."},
      {"speaker":"Tú","spanish":"¿Cuántos seguidores tienes ya?","english":"How many followers do you have already?"}
    ]'::jsonb,
    grammar_note = 'ESTAR + GERUNDIO: -ar verbs → -ando (hablando), -er / -ir verbs → -iendo (comiendo, escribiendo). Use it for actions happening right now.'
  where id = v_l2;

  update public.lessons set
    intro = 'Phrases for everyday social media interactions.',
    vocab_items = '[
      {"word":"subir","phonetic":"[soo-BEER]","english":"to upload","example_es":"Subo fotos de viaje.","example_en":"I upload travel photos."},
      {"word":"etiquetar","phonetic":"[eh-tee-keh-TAR]","english":"to tag","example_es":"Etiqueta a tus amigos.","example_en":"Tag your friends."},
      {"word":"dejar de seguir","phonetic":"[deh-HAR deh seh-GEER]","english":"to unfollow","example_es":"Dejé de seguir a esa cuenta.","example_en":"I unfollowed that account."},
      {"word":"el perfil","phonetic":"[ehl pehr-FEEL]","english":"the profile","example_es":"Mi perfil es público.","example_en":"My profile is public."},
      {"word":"la historia","phonetic":"[lah ees-TOH-ryah]","english":"the story","example_es":"Subo una historia diaria.","example_en":"I upload a daily story."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Tú","spanish":"¿Subes muchas historias?","english":"Do you upload many stories?"},
      {"speaker":"Mia","spanish":"Sí, una al día.","english":"Yes, one a day."},
      {"speaker":"Tú","spanish":"Tu perfil es muy bonito.","english":"Your profile is really nice."},
      {"speaker":"Mia","spanish":"Gracias. Etiqueta a tus amigos.","english":"Thanks. Tag your friends."}
    ]'::jsonb,
    grammar_note = 'When you "follow", "tag" or "block" a person, Spanish uses the personal A: sigo A Marta, etiqueta A tus amigos.'
  where id = v_l3;

  update public.lessons set
    intro = 'Listen to short conversations about TikTok, Instagram and influencers.',
    vocab_items = '[
      {"word":"viral","phonetic":"[bee-RAHL]","english":"viral","example_es":"El vídeo se hizo viral.","example_en":"The video went viral."},
      {"word":"la cuenta","phonetic":"[lah KWEHN-tah]","english":"the account","example_es":"Tengo una cuenta privada.","example_en":"I have a private account."},
      {"word":"el influencer","phonetic":"[ehl een-floo-EHN-sehr]","english":"the influencer","example_es":"Es un influencer famoso.","example_en":"He''s a famous influencer."},
      {"word":"reaccionar","phonetic":"[rreh-ahk-syoh-NAR]","english":"to react","example_es":"Reacciono a los vídeos.","example_en":"I react to videos."},
      {"word":"el vídeo","phonetic":"[ehl BEE-deh-oh]","english":"the video","example_es":"Veo vídeos cortos.","example_en":"I watch short videos."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Voz","spanish":"Su vídeo de baile se hizo viral en una semana.","english":"His dance video went viral in one week."},
      {"speaker":"Voz","spanish":"Ahora es un influencer con un millón de seguidores.","english":"Now he''s an influencer with a million followers."},
      {"speaker":"Voz","spanish":"Muchas marcas le mandan productos gratis.","english":"Many brands send him free products."},
      {"speaker":"Voz","spanish":"Su vida en redes parece perfecta.","english":"His life on the networks looks perfect."}
    ]'::jsonb,
    grammar_note = 'HACERSE VIRAL = to go viral. HACERSE + adjective means "to become" (a change of state): hacerse rico = to become rich.'
  where id = v_l4;

  update public.lessons set
    intro = 'Practice social media phrases out loud — accounts, posts and reactions.',
    vocab_items = '[
      {"word":"Sígueme en Instagram","phonetic":"[SEE-geh-meh ehn een-stah-GRAHM]","english":"Follow me on Instagram","example_es":"Sígueme en Instagram, mi usuario es @ana.","example_en":"Follow me on Instagram, my handle is @ana."},
      {"word":"Subo fotos cada día","phonetic":"[SOO-boh FOH-tohs KAH-dah DEE-ah]","english":"I upload photos every day","example_es":"Subo fotos cada día a mi historia.","example_en":"I upload photos every day to my story."},
      {"word":"Tengo muchos seguidores","phonetic":"[TEHN-goh MOO-chohs seh-gee-DOH-rehs]","english":"I have many followers","example_es":"Tengo muchos seguidores ahora.","example_en":"I have many followers now."},
      {"word":"Comparto vídeos","phonetic":"[kohm-PAR-toh BEE-deh-ohs]","english":"I share videos","example_es":"Comparto vídeos graciosos.","example_en":"I share funny videos."},
      {"word":"Doy likes","phonetic":"[DOY LAH-eeks]","english":"I give likes","example_es":"Doy likes a los vídeos de viaje.","example_en":"I give likes to travel videos."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Tú","spanish":"Sígueme en TikTok, mi usuario es @lucas.","english":"Follow me on TikTok, my handle is @lucas."},
      {"speaker":"Eva","spanish":"Vale, ya te sigo.","english":"OK, I''m following you now."},
      {"speaker":"Tú","spanish":"Subo vídeos de cocina cada día.","english":"I upload cooking videos every day."},
      {"speaker":"Eva","spanish":"Voy a dar like a todos.","english":"I''m going to like all of them."}
    ]'::jsonb,
    grammar_note = 'DAR LIKE A + thing or person = to like something. DAR (irregular yo: doy) is the verb for "to give" — it works for likes, gracias, advice, and many fixed expressions.'
  where id = v_l5;

  update public.lessons set
    intro = 'Read about Ana, a teenager who decided to take a social media break.',
    vocab_items = '[
      {"word":"decidir","phonetic":"[deh-see-DEER]","english":"to decide","example_es":"Decidí dejar el móvil.","example_en":"I decided to put down my phone."},
      {"word":"sin","phonetic":"[seen]","english":"without","example_es":"Una semana sin redes.","example_en":"One week without networks."},
      {"word":"sentirse libre","phonetic":"[sehn-TEER-seh LEE-breh]","english":"to feel free","example_es":"Me sentí libre.","example_en":"I felt free."},
      {"word":"perder el tiempo","phonetic":"[pehr-DEHR ehl TYEHM-poh]","english":"to waste time","example_es":"Perdía mucho tiempo.","example_en":"I was wasting a lot of time."},
      {"word":"recomendar","phonetic":"[rreh-koh-mehn-DAR]","english":"to recommend","example_es":"Lo recomiendo a todos.","example_en":"I recommend it to everyone."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Texto","spanish":"Ana decidió pasar una semana sin redes sociales.","english":"Ana decided to spend a week without social media."},
      {"speaker":"Texto","spanish":"Al principio, fue difícil porque siempre quería mirar el móvil.","english":"At first, it was hard because she always wanted to check her phone."},
      {"speaker":"Texto","spanish":"Pero después de tres días se sintió libre y feliz.","english":"But after three days she felt free and happy."},
      {"speaker":"Texto","spanish":"Ahora recomienda a sus amigos hacer lo mismo.","english":"Now she recommends her friends do the same."}
    ]'::jsonb,
    grammar_note = 'AL PRINCIPIO = at first. DESPUÉS DE + period of time = after that period. Both are essential connectors for telling a story.'
  where id = v_l6;

  update public.lessons set
    intro = 'Write four sentences about your social media habits.',
    vocab_items = '[
      {"word":"mis redes sociales","phonetic":"[mees RREH-dehs soh-syah-LEHS]","english":"my social networks","example_es":"Reviso mis redes sociales por la mañana.","example_en":"I check my social networks in the morning."},
      {"word":"al día","phonetic":"[ahl DEE-ah]","english":"a day","example_es":"Las uso dos horas al día.","example_en":"I use them two hours a day."},
      {"word":"sobre todo","phonetic":"[SOH-breh TOH-doh]","english":"above all","example_es":"Sobre todo Instagram.","example_en":"Above all Instagram."},
      {"word":"a mis amigos","phonetic":"[ah mees ah-MEE-gohs]","english":"my friends","example_es":"Sigo a mis amigos.","example_en":"I follow my friends."},
      {"word":"intento publicar","phonetic":"[een-TEHN-toh poo-blee-KAR]","english":"I try to post","example_es":"Intento publicar una vez al día.","example_en":"I try to post once a day."}
    ]'::jsonb,
    dialogue = '[
      {"speaker":"Modelo","spanish":"Reviso mis redes sociales dos horas al día.","english":"I check my social networks two hours a day."},
      {"speaker":"Modelo","spanish":"Sobre todo uso Instagram y TikTok.","english":"Above all I use Instagram and TikTok."},
      {"speaker":"Modelo","spanish":"Sigo a mis amigos y a varios cantantes.","english":"I follow my friends and several singers."},
      {"speaker":"Modelo","spanish":"Intento publicar una vez al día.","english":"I try to post once a day."}
    ]'::jsonb,
    grammar_note = 'VARIOS / VARIAS = several. It''s a quantifier like ALGUNOS / ALGUNAS but a bit larger. Use it before a plural noun: varios cantantes, varias amigas.'
  where id = v_l7;

end $$;

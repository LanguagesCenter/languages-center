-- 045_spanish_lessons_more_exercises.sql
-- Bulk up every Spanish lesson with extra level-appropriate exercises, with
-- the biggest bump on lessons 1 & 2 (vocabulary + grammar) since those felt
-- shortest.
--
-- Per lesson type, we add:
--   vocabulary lessons: +6 exercises (mix of MC + fill-blank)
--   grammar lessons:    +6 exercises (mix of MC + fill-blank)
--   phrases lessons:    +3 dialogue/fill-blank exercises
--   listening lessons:  +2 additional MC listening
--   speaking lessons:   +2 additional speaking (1 repeat + 1 topic)
--   reading lessons:    +1 additional comprehension MC on the same passage
--   writing lessons:    +1 additional writing prompt
--
-- All fillers go in with order_index >= 200 so they're easy to recognise
-- and re-run. (Display order is randomised at runtime; order_index just
-- keeps the rows uniquely indexed within their lesson and gives us a
-- clean idempotency sentinel.)
--
-- Idempotent: re-running drops all order_index >= 200 rows and reseeds.

-- ============== Wipe previous fillers (idempotency) ==============
do $$
declare
  v_lang_id bigint;
begin
  select id into v_lang_id from public.languages where code = 'spanish';
  if v_lang_id is null then raise exception 'Spanish language not found'; end if;

  delete from public.exercises e
  using public.lessons l, public.courses c
  where e.lesson_id = l.id
    and l.course_id = c.id
    and c.language_id = v_lang_id
    and e.order_index >= 200;
end $$;

-- ============== Insert fresh fillers ==============
do $$
declare
  v_lang_id   bigint;
  v_lesson_id bigint;
  v_level     text;
  i           int;

  -- =================================================================
  -- PER-LEVEL CONTENT TEMPLATES
  -- =================================================================

  ---------- A1 ----------
  a1_vocab_mc_q text[]   := array[
    'What does "casa" mean in English?',
    'What does "agua" mean in English?',
    'Which Spanish word means "school"?',
    'Which Spanish word means "friend"?'
  ];
  a1_vocab_mc_a text[]   := array['house','water','escuela','amigo'];
  a1_vocab_mc_w text[][] := array[
    array['car','book','chair'],
    array['wine','bread','milk'],
    array['iglesia','tienda','calle'],
    array['hermano','padre','abuelo']
  ];
  a1_vocab_fb_q text[]   := array[
    'Complete: "Por la mañana tomo un ____" (coffee)',
    'Complete: "Tengo dos ____" (siblings, plural)'
  ];
  a1_vocab_fb_a text[]   := array['café','hermanos'];

  a1_grammar_mc_q text[] := array[
    'Pick the correct article: "____ casa es bonita."',
    'Pick the correct verb: "Yo ____ español." (speak)',
    'Pick the correct verb: "Tú ____ feliz hoy." (be — temporary)',
    'Pick the correct pronoun: "____ vivo en Madrid."'
  ];
  a1_grammar_mc_a text[] := array['La','hablo','estás','Yo'];
  a1_grammar_mc_w text[][] := array[
    array['El','Los','Las'],
    array['hablas','habla','hablan'],
    array['eres','ser','estar'],
    array['Tú','Él','Ella']
  ];
  a1_grammar_fb_q text[] := array[
    'Complete: "Ella ____ una estudiante." (be — identity)',
    'Complete: "Nosotros ____ en Madrid." (live, present)'
  ];
  a1_grammar_fb_a text[] := array['es','vivimos'];

  a1_phrases_q text[] := array[
    'Complete the dialogue: "A: Buenos días. B: ____, ¿qué desea?"',
    'Complete the dialogue: "A: ¿Cómo te llamas? B: ____ Carlos."',
    'Complete the dialogue: "A: Gracias. B: ____."'
  ];
  a1_phrases_a text[] := array['Buenos días','Me llamo','De nada'];

  a1_listen_extra_q text[] := array['What did you hear?','What did the speaker say?'];
  a1_listen_extra_a text[] := array['Hace mucho calor hoy.','Mi familia vive en Sevilla.'];
  a1_listen_extra_w text[][] := array[
    array['Hace mucho frío hoy.','Hace mucho viento hoy.','Hace mucho sol hoy.'],
    array['Mi familia visita Sevilla.','Mi amiga vive en Sevilla.','Mi familia vivía en Sevilla.']
  ];

  a1_speak_repeat_extra text[] := array['Hace mucho calor en verano.'];
  a1_speak_topic_extra  text[] := array['Talk briefly about the weather where you live. Two short sentences in Spanish.'];

  a1_reading_extra_q text   := '¿Dónde vive Marta?';
  a1_reading_extra_a text   := 'En Barcelona';
  a1_reading_extra_w text[] := array['En Madrid','En Sevilla','En el campo'];

  a1_writing_extra_prompt text := 'Write 2 short Spanish sentences about your favourite food.';

  ---------- A2 ----------
  a2_vocab_mc_q text[]   := array[
    'What does "desayuno" mean?',
    'What does "viajar" mean?',
    'Which Spanish word means "boss"?',
    'Which Spanish word means "weekend"?'
  ];
  a2_vocab_mc_a text[]   := array['breakfast','to travel','jefe','fin de semana'];
  a2_vocab_mc_w text[][] := array[
    array['lunch','dinner','snack'],
    array['to swim','to study','to write'],
    array['empleado','vecino','cliente'],
    array['día festivo','vacaciones','semana']
  ];
  a2_vocab_fb_q text[]   := array[
    'Complete: "Mi hermano ____ inglés en una escuela." (teaches)',
    'Complete: "Necesito comprar ____ y leche en el supermercado." (bread)'
  ];
  a2_vocab_fb_a text[]   := array['enseña','pan'];

  a2_grammar_mc_q text[] := array[
    'Pick the correct preterite: "Ayer yo ____ al cine." (went)',
    'Pick the correct imperfect: "De niño ____ mucho." (played)',
    'Pick the correct form: "Vamos a ____ pronto." (eat)',
    'Pick the reflexive: "Por la mañana ____ a las siete." (I wake up)'
  ];
  a2_grammar_mc_a text[] := array['fui','jugaba','comer','me despierto'];
  a2_grammar_mc_w text[][] := array[
    array['voy','fue','iba'],
    array['jugué','juego','jugaré'],
    array['comemos','comer (incorrect)','comí'],
    array['despierto','me despertaba','despertarse']
  ];
  a2_grammar_fb_q text[] := array[
    'Complete: "El año pasado ____ en una empresa internacional." (I worked)',
    'Complete: "Cuando era pequeño, mis padres ____ todos los días." (worked, imperfect)'
  ];
  a2_grammar_fb_a text[] := array['trabajé','trabajaban'];

  a2_phrases_q text[] := array[
    'Complete the dialogue: "Médico: ¿Qué le pasa? Paciente: Me ____ la cabeza."',
    'Complete the dialogue: "Camarero: ¿Algo más? Cliente: ____, gracias."',
    'Complete the dialogue: "A: Lo siento mucho. B: No ____, no te preocupes."'
  ];
  a2_phrases_a text[] := array['duele','Nada más','pasa nada'];

  a2_listen_extra_q text[] := array['What did you hear?','What did the speaker say?'];
  a2_listen_extra_a text[] := array['Ayer fui al gimnasio y luego cené en casa.','Me gustaría aprender a cocinar comida italiana.'];
  a2_listen_extra_w text[][] := array[
    array['Hoy voy al gimnasio y luego ceno en casa.','Mañana iré al gimnasio y luego cenaré fuera.','Ayer fui al gimnasio pero no cené nada.'],
    array['Me gusta cocinar comida italiana.','Me gustaba aprender comida italiana.','Quisiera enseñar comida italiana.']
  ];

  a2_speak_repeat_extra text[] := array['La semana pasada fui al cine con mis amigos.'];
  a2_speak_topic_extra  text[] := array['Talk about a place you visited recently. Three sentences in Spanish, using past tense.'];

  a2_reading_extra_q text   := '¿Qué hizo el protagonista en su nueva empresa?';
  a2_reading_extra_a text   := 'Conoció a gente de muchos países';
  a2_reading_extra_w text[] := array['Aprendió a dibujar','Estudió un máster','Cambió de ciudad'];

  a2_writing_extra_prompt text := 'Write 3 Spanish sentences describing your favourite weekend activities. Use a connector like "y" or "porque".';

  ---------- B1 ----------
  b1_vocab_mc_q text[]   := array[
    'What does "imprescindible" mean?',
    'What does "ahorrar" mean?',
    'Which Spanish word means "to plan"?',
    'Which Spanish word means "trustworthy"?'
  ];
  b1_vocab_mc_a text[]   := array['essential','to save (money)','planificar','fiable'];
  b1_vocab_mc_w text[][] := array[
    array['impossible','impressive','important'],
    array['to spend','to lend','to lose'],
    array['plantar','platicar','plagiar'],
    array['fiable (incorrect)','famoso','feliz']
  ];
  b1_vocab_fb_q text[]   := array[
    'Complete: "Para sacar buenas notas, hay que ____ con regularidad." (study)',
    'Complete: "Mi jefa me ha ____ un aumento." (granted)'
  ];
  b1_vocab_fb_a text[]   := array['estudiar','concedido'];

  b1_grammar_mc_q text[] := array[
    'Pick the subjunctive: "Espero que ____ buen tiempo." (it is)',
    'Pick the conditional: "Si tuviera tiempo, ____ más libros." (I would read)',
    'Pick the present perfect: "Esta semana ____ tres exámenes." (I have had)',
    'Pick the imperfect subjunctive: "El profesor pidió que ____ silencio." (we keep)'
  ];
  b1_grammar_mc_a text[] := array['haga','leería','he tenido','guardáramos'];
  b1_grammar_mc_w text[][] := array[
    array['hace','hacía','haría'],
    array['leeré','leería (incorrect)','leía'],
    array['tuve','tenía','tendré'],
    array['guardamos','guardáramos (incorrect)','guardábamos']
  ];
  b1_grammar_fb_q text[] := array[
    'Complete: "Si ____ más tiempo, viajaría más." (I had — imperf subjunctive)',
    'Complete: "Te recomiendo que ____ pronto." (you arrive — present subjunctive)'
  ];
  b1_grammar_fb_a text[] := array['tuviera','llegues'];

  b1_phrases_q text[] := array[
    'Complete: "Recepcionista: ¿Cuántas noches? Huésped: ____ noches, por favor." (three)',
    'Complete the dialogue: "A: Qué pena que no puedas venir. B: ____, será otra vez."',
    'Complete: "A: ¿Cómo te fue el examen? B: ____ que bien, salí satisfecho." (creo)'
  ];
  b1_phrases_a text[] := array['Tres','No te preocupes','Creo'];

  b1_listen_extra_q text[] := array['What did you hear?','What opinion did the speaker express?'];
  b1_listen_extra_a text[] := array['Aunque me cansa, sigo trabajando porque me apasiona.','Creo que viajar es la mejor manera de aprender un idioma.'];
  b1_listen_extra_w text[][] := array[
    array['Aunque me apasiona, dejo de trabajar porque me cansa.','Como me cansa, voy a dejar de trabajar.','Aunque me cansa, viajo porque me apasiona.'],
    array['Pienso que viajar no ayuda a aprender un idioma.','Creo que estudiar es la mejor manera de viajar.','Viajar no es la mejor manera de practicar.']
  ];

  b1_speak_repeat_extra text[] := array['Aunque me cuesta mucho, sigo intentando hablar español cada día.'];
  b1_speak_topic_extra  text[] := array['Talk about a goal you would achieve if you had more free time. Four sentences using conditional tense.'];

  b1_reading_extra_q text   := '¿Qué hacen los gobiernos regionales para responder al fenómeno?';
  b1_reading_extra_a text   := 'Ofrecen incentivos para que regresen';
  b1_reading_extra_w text[] := array['Imponen multas a los emigrantes','Prohíben el regreso','No hacen nada'];

  b1_writing_extra_prompt text := 'Write 4 Spanish sentences arguing whether young people should travel before settling down. Include at least one connector (porque / sin embargo / por eso).';

  ---------- B2 ----------
  b2_vocab_mc_q text[]   := array[
    'What does "contundente" mean?',
    'What does "soslayar" mean?',
    'Which Spanish word means "to undertake"?',
    'Which Spanish word means "regulation"?'
  ];
  b2_vocab_mc_a text[]   := array['forceful','to sidestep','emprender','regulación'];
  b2_vocab_mc_w text[][] := array[
    array['continuous','convincing','contingent'],
    array['to soak','to settle','to summon'],
    array['emprenderse','emparentar','empedrar'],
    array['regulacion (incorrect)','regla','regulado']
  ];
  b2_vocab_fb_q text[]   := array[
    'Complete: "Cabe ____ que las consecuencias son graves." (highlight)',
    'Complete: "El gobierno aprobó la ley a pesar de la ____ de la oposición." (opposition)'
  ];
  b2_vocab_fb_a text[]   := array['destacar','oposición'];

  b2_grammar_mc_q text[] := array[
    'Pick the right form: "Si hubiera estudiado más, ____ aprobado." (I would have)',
    'Pick the right tense: "Cuando ____ los resultados, te aviso." (I have — present subjunctive)',
    'Pick the right form: "Aunque ____ difícil, lo intentaré." (it is — concessive subjunctive)',
    'Pick the right impersonal: "____ poder votar a partir de los 16 años." (one should)'
  ];
  b2_grammar_mc_a text[] := array['habría','tenga','sea','Debería']::text[];
  b2_grammar_mc_w text[][] := array[
    array['había','habré','hubiera (incorrect)'],
    array['tengo','tendré','tenía'],
    array['es','será','era'],
    array['Debe','Debió','Debió de']
  ];
  b2_grammar_fb_q text[] := array[
    'Complete: "Por más que ____ , no cambiará de opinión." (you insist — subjunctive)',
    'Complete: "No me extraña que ____ enfadado: llevan semanas con retraso." (he is — subjunctive)'
  ];
  b2_grammar_fb_a text[] := array['insistas','esté'];

  b2_phrases_q text[] := array[
    'Complete: "Cliente: Llevo días sin internet. Agente: Lo ____ mucho, ahora mismo lo solucionamos." (apologise)',
    'Complete: "Director: Quiero felicitarles. Empleado: ____ a usted, jefe." (gracias)',
    'Complete the formal dialogue: "Le ____ que confirme su asistencia." (we kindly ask — bare subj)'
  ];
  b2_phrases_a text[] := array['siento','Gracias','rogamos'];

  b2_listen_extra_q text[] := array['What did you hear?','What position did the speaker take?'];
  b2_listen_extra_a text[] := array['No obstante los avances, persisten desigualdades importantes en la sociedad.','Cabe destacar que el debate sobre la inmigración requiere matices, no eslóganes.'];
  b2_listen_extra_w text[][] := array[
    array['Gracias a los avances, han desaparecido las desigualdades.','Los avances no afectan a las desigualdades en absoluto.','Sin avances no existirían desigualdades.'],
    array['El debate sobre la inmigración debe simplificarse.','La inmigración no merece debate alguno.','Los eslóganes resuelven el debate sobre la inmigración.']
  ];

  b2_speak_repeat_extra text[] := array['No obstante el progreso, persisten desigualdades sociales que merecen atención urgente.'];
  b2_speak_topic_extra  text[] := array['Defend or attack a recent government decision in 5 sentences. Use no obstante, por consiguiente or cabe destacar and subjunctive.'];

  b2_reading_extra_q text   := '¿Qué predice el autor sobre el debate de la IA generativa?';
  b2_reading_extra_a text   := 'Que se prolongará durante años';
  b2_reading_extra_w text[] := array['Que se resolverá pronto','Que desaparecerá rápido','Que terminará en una prohibición global'];

  b2_writing_extra_prompt text := 'Write 5 Spanish sentences arguing whether companies should share profits with all employees. Use subjunctive and a connector like no obstante or cabe destacar.';

  ---------- C1 ----------
  c1_vocab_mc_q text[]   := array[
    'What does "soslayar" mean?',
    'What does "deslumbrante" mean?',
    'Which Spanish phrase means "for the sake of"?',
    'Which Spanish phrase means "in light of"?'
  ];
  c1_vocab_mc_a text[]   := array['to sidestep','dazzling','en aras de','a tenor de'];
  c1_vocab_mc_w text[][] := array[
    array['to soak','to settle','to summon'],
    array['disappointing','disgusting','dishonest'],
    array['por consiguiente','no obstante','cabe destacar'],
    array['de tenor','con tenor','para tenor']
  ];
  c1_vocab_fb_q text[]   := array[
    'Complete: "Su discurso fue tan ____ que disipó todas las dudas." (forceful)',
    'Complete: "Cabe ____ la importancia de matizar siempre los argumentos." (highlight)'
  ];
  c1_vocab_fb_a text[]   := array['contundente','destacar'];

  c1_grammar_mc_q text[] := array[
    'Pick the conditional perfect: "De haberlo sabido, no ____ ido." (I would have)',
    'Pick the right cleft form: "____ Juan quien lo dijo." (it was)',
    'Pick the right pronoun: "El autor ____ obra estudiamos hoy." (whose)',
    'Pick the right concessive: "Por más que ____ , no cambiará." (you insist — subjunctive)'
  ];
  c1_grammar_mc_a text[] := array['habría','Fue','cuya','insistas'];
  c1_grammar_mc_w text[][] := array[
    array['hubiera','había','habré'],
    array['Era','Es','Será'],
    array['cuyo','cuyas','cuyos'],
    array['insistes','insistirás','insistías']
  ];
  c1_grammar_fb_q text[] := array[
    'Complete: "De ____ sabido antes, habría tomado otra decisión." (having)',
    'Complete: "Lejos de ____ triviales, las implicaciones son graves." (be — infinitive)'
  ];
  c1_grammar_fb_a text[] := array['haberlo','ser'];

  c1_phrases_q text[] := array[
    'Complete the formal dialogue: "Le ____ confirme su asistencia a la mayor brevedad." (we kindly ask — bare subj)',
    'Complete: "Cabe ____ la importancia de matizar siempre los argumentos." (highlight — inf)',
    'Complete: "Permítame ____. Si bien es cierto, no por ello debemos aceptarlo sin más." (discrepar)'
  ];
  c1_phrases_a text[] := array['rogamos','destacar','discrepar'];

  c1_listen_extra_q text[] := array['What did you hear?','What rhetorical move did the speaker make?'];
  c1_listen_extra_a text[] := array['De haberse aprobado entonces, la reforma habría transformado el sistema educativo.','Cabe señalar que, lejos de ser un fenómeno marginal, la desinformación es estructural.'];
  c1_listen_extra_w text[][] := array[
    array['De haberse rechazado entonces, el sistema habría mejorado.','Aunque se apruebe ahora, la reforma será insuficiente.','Si se aprobara ahora, transformaría el sistema.'],
    array['Cabe ignorar que la desinformación es marginal.','La desinformación es solo coyuntural y aislada.','Sin desinformación no habría debate público.']
  ];

  c1_speak_repeat_extra text[] := array['De haberse aprobado entonces, aquella reforma habría modificado profundamente el sistema educativo de varias generaciones.'];
  c1_speak_topic_extra  text[] := array['Argue what would have changed in your country had a recent reform been approved a decade earlier. 6-7 sentences using conditional perfect and subjunctive.'];

  c1_reading_extra_q text   := '¿Qué naturaleza tiene hoy el debate, según el autor?';
  c1_reading_extra_a text   := 'Es a la vez cultural y simbólico, no solo técnico';
  c1_reading_extra_w text[] := array['Es exclusivamente técnico','Es estrictamente económico','Está prácticamente resuelto en lo académico'];

  c1_writing_extra_prompt text := 'Write 7-8 Spanish sentences in formal register on whether contemporary democracies are equipped to face long-term challenges. Use no obstante, asimismo and cabe señalar plus subjunctive and conditional perfect.';

  ---------------- ACTIVE BUFFERS (filled per level in the loop) ----------------
  cur_vocab_mc_q text[]; cur_vocab_mc_a text[]; cur_vocab_mc_w text[][];
  cur_vocab_fb_q text[]; cur_vocab_fb_a text[];
  cur_grammar_mc_q text[]; cur_grammar_mc_a text[]; cur_grammar_mc_w text[][];
  cur_grammar_fb_q text[]; cur_grammar_fb_a text[];
  cur_phrases_q text[]; cur_phrases_a text[];
  cur_listen_extra_q text[]; cur_listen_extra_a text[]; cur_listen_extra_w text[][];
  cur_speak_repeat_extra text[]; cur_speak_topic_extra text[];
  cur_reading_extra_q text; cur_reading_extra_a text; cur_reading_extra_w text[];
  cur_writing_extra_prompt text;
begin
  select id into v_lang_id from public.languages where code = 'spanish';
  if v_lang_id is null then raise exception 'Spanish language not found'; end if;

  for v_level in select unnest(array['A1','A2','B1','B2','C1']) loop
    -- Bind level templates
    case v_level
      when 'A1' then
        cur_vocab_mc_q := a1_vocab_mc_q; cur_vocab_mc_a := a1_vocab_mc_a; cur_vocab_mc_w := a1_vocab_mc_w;
        cur_vocab_fb_q := a1_vocab_fb_q; cur_vocab_fb_a := a1_vocab_fb_a;
        cur_grammar_mc_q := a1_grammar_mc_q; cur_grammar_mc_a := a1_grammar_mc_a; cur_grammar_mc_w := a1_grammar_mc_w;
        cur_grammar_fb_q := a1_grammar_fb_q; cur_grammar_fb_a := a1_grammar_fb_a;
        cur_phrases_q := a1_phrases_q; cur_phrases_a := a1_phrases_a;
        cur_listen_extra_q := a1_listen_extra_q; cur_listen_extra_a := a1_listen_extra_a; cur_listen_extra_w := a1_listen_extra_w;
        cur_speak_repeat_extra := a1_speak_repeat_extra; cur_speak_topic_extra := a1_speak_topic_extra;
        cur_reading_extra_q := a1_reading_extra_q; cur_reading_extra_a := a1_reading_extra_a; cur_reading_extra_w := a1_reading_extra_w;
        cur_writing_extra_prompt := a1_writing_extra_prompt;
      when 'A2' then
        cur_vocab_mc_q := a2_vocab_mc_q; cur_vocab_mc_a := a2_vocab_mc_a; cur_vocab_mc_w := a2_vocab_mc_w;
        cur_vocab_fb_q := a2_vocab_fb_q; cur_vocab_fb_a := a2_vocab_fb_a;
        cur_grammar_mc_q := a2_grammar_mc_q; cur_grammar_mc_a := a2_grammar_mc_a; cur_grammar_mc_w := a2_grammar_mc_w;
        cur_grammar_fb_q := a2_grammar_fb_q; cur_grammar_fb_a := a2_grammar_fb_a;
        cur_phrases_q := a2_phrases_q; cur_phrases_a := a2_phrases_a;
        cur_listen_extra_q := a2_listen_extra_q; cur_listen_extra_a := a2_listen_extra_a; cur_listen_extra_w := a2_listen_extra_w;
        cur_speak_repeat_extra := a2_speak_repeat_extra; cur_speak_topic_extra := a2_speak_topic_extra;
        cur_reading_extra_q := a2_reading_extra_q; cur_reading_extra_a := a2_reading_extra_a; cur_reading_extra_w := a2_reading_extra_w;
        cur_writing_extra_prompt := a2_writing_extra_prompt;
      when 'B1' then
        cur_vocab_mc_q := b1_vocab_mc_q; cur_vocab_mc_a := b1_vocab_mc_a; cur_vocab_mc_w := b1_vocab_mc_w;
        cur_vocab_fb_q := b1_vocab_fb_q; cur_vocab_fb_a := b1_vocab_fb_a;
        cur_grammar_mc_q := b1_grammar_mc_q; cur_grammar_mc_a := b1_grammar_mc_a; cur_grammar_mc_w := b1_grammar_mc_w;
        cur_grammar_fb_q := b1_grammar_fb_q; cur_grammar_fb_a := b1_grammar_fb_a;
        cur_phrases_q := b1_phrases_q; cur_phrases_a := b1_phrases_a;
        cur_listen_extra_q := b1_listen_extra_q; cur_listen_extra_a := b1_listen_extra_a; cur_listen_extra_w := b1_listen_extra_w;
        cur_speak_repeat_extra := b1_speak_repeat_extra; cur_speak_topic_extra := b1_speak_topic_extra;
        cur_reading_extra_q := b1_reading_extra_q; cur_reading_extra_a := b1_reading_extra_a; cur_reading_extra_w := b1_reading_extra_w;
        cur_writing_extra_prompt := b1_writing_extra_prompt;
      when 'B2' then
        cur_vocab_mc_q := b2_vocab_mc_q; cur_vocab_mc_a := b2_vocab_mc_a; cur_vocab_mc_w := b2_vocab_mc_w;
        cur_vocab_fb_q := b2_vocab_fb_q; cur_vocab_fb_a := b2_vocab_fb_a;
        cur_grammar_mc_q := b2_grammar_mc_q; cur_grammar_mc_a := b2_grammar_mc_a; cur_grammar_mc_w := b2_grammar_mc_w;
        cur_grammar_fb_q := b2_grammar_fb_q; cur_grammar_fb_a := b2_grammar_fb_a;
        cur_phrases_q := b2_phrases_q; cur_phrases_a := b2_phrases_a;
        cur_listen_extra_q := b2_listen_extra_q; cur_listen_extra_a := b2_listen_extra_a; cur_listen_extra_w := b2_listen_extra_w;
        cur_speak_repeat_extra := b2_speak_repeat_extra; cur_speak_topic_extra := b2_speak_topic_extra;
        cur_reading_extra_q := b2_reading_extra_q; cur_reading_extra_a := b2_reading_extra_a; cur_reading_extra_w := b2_reading_extra_w;
        cur_writing_extra_prompt := b2_writing_extra_prompt;
      when 'C1' then
        cur_vocab_mc_q := c1_vocab_mc_q; cur_vocab_mc_a := c1_vocab_mc_a; cur_vocab_mc_w := c1_vocab_mc_w;
        cur_vocab_fb_q := c1_vocab_fb_q; cur_vocab_fb_a := c1_vocab_fb_a;
        cur_grammar_mc_q := c1_grammar_mc_q; cur_grammar_mc_a := c1_grammar_mc_a; cur_grammar_mc_w := c1_grammar_mc_w;
        cur_grammar_fb_q := c1_grammar_fb_q; cur_grammar_fb_a := c1_grammar_fb_a;
        cur_phrases_q := c1_phrases_q; cur_phrases_a := c1_phrases_a;
        cur_listen_extra_q := c1_listen_extra_q; cur_listen_extra_a := c1_listen_extra_a; cur_listen_extra_w := c1_listen_extra_w;
        cur_speak_repeat_extra := c1_speak_repeat_extra; cur_speak_topic_extra := c1_speak_topic_extra;
        cur_reading_extra_q := c1_reading_extra_q; cur_reading_extra_a := c1_reading_extra_a; cur_reading_extra_w := c1_reading_extra_w;
        cur_writing_extra_prompt := c1_writing_extra_prompt;
    end case;

    -- ---------------- VOCABULARY lessons (lesson 1) ----------------
    for v_lesson_id in
      select l.id from public.lessons l
      join public.courses c on c.id = l.course_id
      where c.language_id = v_lang_id and c.cefr_level = v_level
        and l.type = 'vocabulary'
    loop
      for i in 1..array_length(cur_vocab_mc_q, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (
          v_lesson_id, 'multiple_choice',
          cur_vocab_mc_q[i], cur_vocab_mc_a[i],
          array[cur_vocab_mc_w[i][1], cur_vocab_mc_w[i][2], cur_vocab_mc_w[i][3]]::text[],
          200 + i
        );
      end loop;
      for i in 1..array_length(cur_vocab_fb_q, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (
          v_lesson_id, 'fill_blank',
          cur_vocab_fb_q[i], cur_vocab_fb_a[i], array[]::text[],
          210 + i
        );
      end loop;
    end loop;

    -- ---------------- GRAMMAR lessons (lesson 2) ----------------
    for v_lesson_id in
      select l.id from public.lessons l
      join public.courses c on c.id = l.course_id
      where c.language_id = v_lang_id and c.cefr_level = v_level
        and l.type = 'grammar'
    loop
      for i in 1..array_length(cur_grammar_mc_q, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (
          v_lesson_id, 'multiple_choice',
          cur_grammar_mc_q[i], cur_grammar_mc_a[i],
          array[cur_grammar_mc_w[i][1], cur_grammar_mc_w[i][2], cur_grammar_mc_w[i][3]]::text[],
          200 + i
        );
      end loop;
      for i in 1..array_length(cur_grammar_fb_q, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (
          v_lesson_id, 'fill_blank',
          cur_grammar_fb_q[i], cur_grammar_fb_a[i], array[]::text[],
          210 + i
        );
      end loop;
    end loop;

    -- ---------------- PHRASES lessons (lesson 3) ----------------
    for v_lesson_id in
      select l.id from public.lessons l
      join public.courses c on c.id = l.course_id
      where c.language_id = v_lang_id and c.cefr_level = v_level
        and l.type = 'phrases'
    loop
      for i in 1..array_length(cur_phrases_q, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (
          v_lesson_id, 'fill_blank',
          cur_phrases_q[i], cur_phrases_a[i], array[]::text[],
          200 + i
        );
      end loop;
    end loop;

    -- ---------------- LISTENING lessons (lesson 4) ----------------
    for v_lesson_id in
      select l.id from public.lessons l
      join public.courses c on c.id = l.course_id
      where c.language_id = v_lang_id and c.cefr_level = v_level
        and l.type = 'listening'
    loop
      for i in 1..array_length(cur_listen_extra_q, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (
          v_lesson_id, 'listening',
          cur_listen_extra_q[i], cur_listen_extra_a[i],
          array[cur_listen_extra_w[i][1], cur_listen_extra_w[i][2], cur_listen_extra_w[i][3]]::text[],
          200 + i
        );
      end loop;
    end loop;

    -- ---------------- SPEAKING lessons (lesson 5) ----------------
    for v_lesson_id in
      select l.id from public.lessons l
      join public.courses c on c.id = l.course_id
      where c.language_id = v_lang_id and c.cefr_level = v_level
        and l.type = 'speaking'
    loop
      for i in 1..array_length(cur_speak_repeat_extra, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (
          v_lesson_id, 'speaking',
          'Say this aloud: "' || cur_speak_repeat_extra[i] || '"',
          cur_speak_repeat_extra[i], array[]::text[],
          200 + i
        );
      end loop;
      for i in 1..array_length(cur_speak_topic_extra, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (
          v_lesson_id, 'speaking',
          cur_speak_topic_extra[i], '', array[]::text[],
          210 + i
        );
      end loop;
    end loop;

    -- ---------------- READING lessons (lesson 6) ----------------
    -- One additional comprehension MC on the existing passage. We pull
    -- the passage text from any existing reading exercise (the question
    -- column carries it) so this stays in sync with migration 044.
    for v_lesson_id in
      select l.id from public.lessons l
      join public.courses c on c.id = l.course_id
      where c.language_id = v_lang_id and c.cefr_level = v_level
        and l.type = 'reading'
    loop
      declare
        v_passage text;
      begin
        select substring(e.question from 'Lee el siguiente texto y responde:\n\n(.*?)\n\nPregunta:')
        into v_passage
        from public.exercises e
        where e.lesson_id = v_lesson_id
          and e.question like 'Lee el siguiente texto y responde:%'
        order by e.order_index
        limit 1;

        if v_passage is not null then
          insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
          values (
            v_lesson_id, 'multiple_choice',
            E'Lee el siguiente texto y responde:\n\n' || v_passage || E'\n\nPregunta: ' || cur_reading_extra_q,
            cur_reading_extra_a,
            array[cur_reading_extra_w[1], cur_reading_extra_w[2], cur_reading_extra_w[3]]::text[],
            200
          );
        end if;
      end;
    end loop;

    -- ---------------- WRITING lessons (lesson 7) ----------------
    for v_lesson_id in
      select l.id from public.lessons l
      join public.courses c on c.id = l.course_id
      where c.language_id = v_lang_id and c.cefr_level = v_level
        and l.type = 'writing'
    loop
      insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
      values (
        v_lesson_id, 'writing',
        cur_writing_extra_prompt, '', array[]::text[],
        200
      );
    end loop;
  end loop;
end $$;

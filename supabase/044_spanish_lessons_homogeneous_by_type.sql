-- 044_spanish_lessons_homogeneous_by_type.sql
-- Each Spanish lesson (lessons 1-7 of every section, every CEFR level)
-- should now contain exercises that match its labelled type field. Earlier
-- migrations 039-043 added one writing / one speaking / one listening
-- exercise to EVERY lesson regardless of its type, which left vocabulary,
-- grammar and phrases lessons holding off-type rows. This migration:
--
--   PHASE 1: Removes off-type exercises so each lesson only keeps the
--            ones that match its type.
--   PHASE 2: Re-seeds the listening, speaking, writing and reading
--            lessons with a clean, type-consistent set of 3-4 exercises
--            using level-appropriate templates. Variety within the type
--            is preserved (e.g. listening lessons mix MC and typed
--            responses; speaking lessons mix repeat-phrase and topic
--            monologue).
--
-- Lesson 8 (podcast / conversation) and lesson 9 (unit_test) are NOT
-- touched — they're designed as multi-skill summary lessons.
--
-- Idempotent. Re-running deletes and re-inserts on lessons 4-7.

-- =====================================================================
-- PHASE 1 — Drop off-type exercises across all Spanish lessons.
-- =====================================================================
do $$
declare
  v_lang_id bigint;
begin
  select id into v_lang_id from public.languages where code = 'spanish';
  if v_lang_id is null then raise exception 'Spanish language not found'; end if;

  -- Vocabulary / grammar / phrases lessons keep only MC / fill_blank /
  -- matching. The listening / speaking / writing rows added in 039-043
  -- are removed.
  delete from public.exercises e
  using public.lessons l, public.courses c
  where e.lesson_id = l.id
    and l.course_id = c.id
    and c.language_id = v_lang_id
    and l.type in ('vocabulary','grammar','phrases')
    and e.type in ('listening','speaking','writing');

  -- Listening lessons keep only listening exercises.
  delete from public.exercises e
  using public.lessons l, public.courses c
  where e.lesson_id = l.id
    and l.course_id = c.id
    and c.language_id = v_lang_id
    and l.type = 'listening'
    and e.type <> 'listening';

  -- Speaking lessons keep only speaking exercises.
  delete from public.exercises e
  using public.lessons l, public.courses c
  where e.lesson_id = l.id
    and l.course_id = c.id
    and c.language_id = v_lang_id
    and l.type = 'speaking'
    and e.type <> 'speaking';

  -- Writing lessons keep only writing exercises.
  delete from public.exercises e
  using public.lessons l, public.courses c
  where e.lesson_id = l.id
    and l.course_id = c.id
    and c.language_id = v_lang_id
    and l.type = 'writing'
    and e.type <> 'writing';

  -- Reading lessons are completely regenerated below — wipe.
  delete from public.exercises e
  using public.lessons l, public.courses c
  where e.lesson_id = l.id
    and l.course_id = c.id
    and c.language_id = v_lang_id
    and l.type = 'reading';

  -- Also wipe the on-type exercises on listening/speaking/writing
  -- lessons so the re-seed below isn't duplicated.
  delete from public.exercises e
  using public.lessons l, public.courses c
  where e.lesson_id = l.id
    and l.course_id = c.id
    and c.language_id = v_lang_id
    and l.type in ('listening','speaking','writing');
end $$;

-- =====================================================================
-- PHASE 2 — Re-seed listening / speaking / writing / reading lessons.
--
-- Templates live per CEFR level. Within each level we insert the same
-- set of 3-4 exercises into every section's lesson of that type. The
-- exercises are level-appropriate; sections are differentiated mainly
-- by the surrounding teaching content (intro / vocab / dialogue),
-- not by exercise text.
-- =====================================================================

do $$
declare
  v_lang_id   bigint;
  v_course_id bigint;
  v_lesson_id bigint;

  -- Per-level CONTENT TEMPLATES ---------------------------------------

  -- LISTENING templates: 3 MC + 1 typed per lesson.
  --   MC rows:    correct_answer is the Spanish phrase the TTS reads;
  --               wrong_answers are decoys; question is the user prompt.
  --   Typed row:  question is the Spanish audio text; correct_answer is
  --               a reference response; wrong_answers is empty.

  -- A1 listening
  a1_listen_mc_q text[]   := array['What did you hear?','What greeting did you hear?','What number did you hear?'];
  a1_listen_mc_a text[]   := array['Me llamo Ana y tengo veinte años.','Buenos días, ¿cómo estás?','Tengo veinticinco años.'];
  a1_listen_mc_w text[][] := array[
    array['Te llamas Ana y tengo veinte años.','Me llama Ana y tiene veinte años.','Me llamo Pedro y tengo veinte años.'],
    array['Buenas noches, ¿cómo estás?','Buenos días, hasta luego.','Hola, ¿cómo te llamas?'],
    array['Tengo quince años.','Tenemos veinte años.','Tienes veinticinco años.']
  ];
  a1_listen_typed_q  text := 'Háblame de tu rutina diaria en pocas frases.';
  a1_listen_typed_a  text := 'Me levanto a las siete, desayuno y voy al trabajo.';

  -- A2 listening
  a2_listen_mc_q text[]   := array['What did you hear?','What question did you hear?','What did the speaker say?'];
  a2_listen_mc_a text[]   := array['Ayer fui al cine con mis amigos.','¿Qué hiciste el fin de semana pasado?','Mi familia es bastante grande y muy unida.'];
  a2_listen_mc_w text[][] := array[
    array['Hoy voy al cine con mis amigos.','Ayer fui al cine con mi familia.','Mañana iré al cine con mis amigos.'],
    array['¿Qué haces el fin de semana?','¿Qué harás el fin de semana?','¿Dónde estuviste el fin de semana?'],
    array['Mi familia es muy pequeña y poco unida.','Mi casa es bastante grande y muy luminosa.','Mis amigos son muy graciosos y muy alegres.']
  ];
  a2_listen_typed_q  text := 'Cuéntame qué hiciste ayer y cómo te sentiste al final del día.';
  a2_listen_typed_a  text := 'Ayer trabajé mucho y por la tarde fui a correr. Al final del día me sentí cansado pero contento.';

  -- B1 listening
  b1_listen_mc_q text[]   := array['What did you hear?','What opinion was expressed?','What was the speaker''s main point?'];
  b1_listen_mc_a text[]   := array['Aunque me gusta la ciudad, prefiero vivir en el campo.','Creo que las redes sociales han cambiado nuestras vidas para siempre.','Si tuviera más tiempo, viajaría por toda Sudamérica.'];
  b1_listen_mc_w text[][] := array[
    array['Aunque me gusta el campo, prefiero vivir en la ciudad.','Como me gusta la ciudad, vivo en el campo.','Aunque no me gusta la ciudad, vivo en ella.'],
    array['Pienso que las redes sociales no han cambiado nada.','Creo que las redes nos cambiarán dentro de poco.','Las redes apenas afectan nuestra vida diaria.'],
    array['Si tengo más tiempo, viajo por Sudamérica.','Cuando tuviera más tiempo, viajé por Sudamérica.','Aunque tenga más tiempo, no viajaría a Sudamérica.']
  ];
  b1_listen_typed_q  text := 'Aunque me encanta viajar, este año he decidido quedarme en casa porque necesito ahorrar. ¿Qué opinas?';
  b1_listen_typed_a  text := 'Me parece una decisión sensata; ahorrar ahora te dará más libertad después. Yo haría lo mismo si estuviera en tu lugar.';

  -- B2 listening
  b2_listen_mc_q text[]   := array['What did you hear?','What attitude does the speaker show?','What argument did the speaker make?'];
  b2_listen_mc_a text[]   := array['No obstante el progreso tecnológico, persisten muchas desigualdades sociales.','Cabe destacar que la educación pública sigue siendo la base de cualquier democracia sana.','Si hubiéramos actuado antes, habríamos evitado gran parte de la crisis ambiental.'];
  b2_listen_mc_w text[][] := array[
    array['Gracias al progreso tecnológico, han desaparecido las desigualdades.','El progreso tecnológico solo afecta a una minoría privilegiada.','Sin progreso tecnológico no habría desigualdades sociales.'],
    array['La educación privada es la base de toda democracia.','La educación apenas influye en la salud democrática.','Solo la educación universitaria importa para la democracia.'],
    array['Si actuamos ahora, evitaremos la crisis ambiental.','Aunque hubiéramos actuado, la crisis era inevitable.','Si actuáramos pronto, evitaríamos la próxima crisis.']
  ];
  b2_listen_typed_q  text := 'Algunos expertos sostienen que la educación a distancia ha llegado para quedarse; otros piensan que solo es un parche temporal. ¿Cuál es tu postura?';
  b2_listen_typed_a  text := 'Creo que ha llegado para quedarse, no obstante necesita reformas. Cabe destacar que la educación presencial sigue siendo esencial para el aprendizaje social.';

  -- C1 listening
  c1_listen_mc_q text[]   := array['What did you hear?','What rhetorical move did the speaker make?','What implicit claim does this contain?'];
  c1_listen_mc_a text[]   := array['Cabe señalar que, lejos de ser un fenómeno marginal, la desinformación se ha convertido en estructura.','Asimismo, conviene matizar que ninguna ley, por estricta que sea, sustituye el criterio del ciudadano.','De haberse aprobado entonces, la reforma habría modificado profundamente el sistema educativo.'];
  c1_listen_mc_w text[][] := array[
    array['Cabe negar que la desinformación sea un fenómeno marginal.','La desinformación sigue siendo un fenómeno marginal sin importancia.','Cabe destacar que la desinformación es solo coyuntural.'],
    array['Cualquier ley estricta sustituye el criterio del ciudadano.','El criterio del ciudadano nunca debe sustituir a la ley.','Ninguna ley es necesaria si el ciudadano tiene criterio.'],
    array['De haberse rechazado entonces, el sistema educativo habría mejorado mucho.','Aprobada entonces, la reforma no habría cambiado el sistema.','Si se aprueba ahora, la reforma transformará el sistema.']
  ];
  c1_listen_typed_q  text := 'Una catedrática afirmó que la libertad académica se mide por lo que un Estado permite que se publique sobre él, no por lo que dice tolerar. ¿Cómo interpretas su matiz?';
  c1_listen_typed_a  text := 'Insinúa que la libertad declarada vale poco si la libertad efectiva está condicionada. No obstante, su comparación reduce la libertad académica al criterio gubernamental, ignorando otros factores institucionales que también la limitan.';

  -- SPEAKING templates: 2 repeat-phrase + 2 topic per lesson.
  --   Repeat:  question = "Say this aloud: '[phrase]'"; correct_answer = phrase
  --   Topic:   question = English instruction; correct_answer = ''
  a1_speak_repeat_phrases text[] := array['Hola, me llamo Ana y soy de México.','Tengo veinte años y vivo con mi familia.'];
  a1_speak_topics         text[] := array['Greet someone and introduce yourself. Speak two short Spanish sentences.','Talk about your daily routine in two short sentences.'];

  a2_speak_repeat_phrases text[] := array['Ayer fui al supermercado y compré pan y leche.','Mi familia es grande y vivimos en una casa con jardín.'];
  a2_speak_topics         text[] := array['Describe what you did last weekend. Three sentences in Spanish, using past tense.','Talk about your typical morning routine. Three sentences in Spanish.'];

  b1_speak_repeat_phrases text[] := array['Aunque me gusta mucho viajar, este año prefiero quedarme y ahorrar para el futuro.','Si tuviera más tiempo libre, aprendería a tocar la guitarra y haría más deporte.'];
  b1_speak_topics         text[] := array['Talk about a goal you want to achieve in the next year. Four sentences with an opinion.','Describe a place you would like to visit and why. Four sentences using conditional or future tense.'];

  b2_speak_repeat_phrases text[] := array['No obstante el progreso, persisten desigualdades; cabe destacar que la educación sigue siendo clave para reducirlas.','Si hubiéramos actuado antes, habríamos evitado gran parte de la crisis; por consiguiente, ahora debemos planificar a largo plazo.'];
  b2_speak_topics         text[] := array['Argue for or against a social policy you care about. Five sentences using sin embargo or no obstante and subjunctive where appropriate.','Discuss a current global issue and propose a solution. Five sentences using por consiguiente or cabe destacar.'];

  c1_speak_repeat_phrases text[] := array['Cabe señalar que, lejos de ser marginal, la desinformación se ha convertido en estructura sistémica que condiciona el debate público.','De haberse aprobado entonces, aquella reforma habría modificado profundamente el sistema, asimismo habría adelantado debates que hoy seguimos posponiendo.'];
  c1_speak_topics         text[] := array['Critically analyse a current geopolitical issue and its long-term implications. Six to eight sentences using advanced connectors and subjunctive.','Discuss whether artificial intelligence will reshape the humanities, defending a clear stance. Six to eight sentences with rhetorical sophistication.'];

  -- WRITING templates: 3 prompts per lesson.
  a1_writing_prompts text[] := array[
    'Write 2 short Spanish sentences introducing yourself.',
    'Write 2 short Spanish sentences about your family.',
    'Write 2 short Spanish sentences about what you do every morning.'
  ];
  a2_writing_prompts text[] := array[
    'Write 3 Spanish sentences about what you did last weekend, using past tense.',
    'Write 3 Spanish sentences comparing your weekday and weekend routines.',
    'Write a 3-sentence email inviting a friend to dinner this Saturday.'
  ];
  b1_writing_prompts text[] := array[
    'Write 4 Spanish sentences giving your opinion on remote work. Include at least one connector (sin embargo / además / por eso).',
    'Write 4 Spanish sentences about a goal you have for the next year, using future tense.',
    'Write 4 Spanish sentences comparing two cities or countries you know.'
  ];
  b2_writing_prompts text[] := array[
    'Write 5 Spanish sentences debating a current social issue. Use subjunctive and at least one connector (no obstante / por consiguiente / cabe destacar).',
    'Write 5 Spanish sentences arguing for or against a proposed policy. Acknowledge a counterargument.',
    'Write 5 Spanish sentences analysing the long-term effects of a recent change in your country. Use sophisticated vocabulary.'
  ];
  c1_writing_prompts text[] := array[
    'Write 7-8 Spanish sentences critically analysing a current global issue. Use subjunctive, conditional perfect (habría + past participle) and at least two advanced connectors.',
    'Write 7-8 Spanish sentences in formal register on the ethics of a contemporary technology. Use no obstante, asimismo and cabe señalar.',
    'Write 7-8 Spanish sentences arguing what would have happened had a major historical event unfolded differently. Use subjunctive and conditional perfect throughout.'
  ];

  -- READING templates: per level, one passage + 3 comprehension MC.
  -- The passage is included inside each exercise question so the user
  -- always sees it (avoids shuffle / skip-teaching issues).
  a1_reading_passage text := E'Me llamo Marta. Tengo veinticinco años y vivo en Barcelona. Por la mañana voy al trabajo en autobús y por la tarde estudio inglés. Los fines de semana visito a mis padres en el campo y como con ellos.';
  a1_reading_q text[]     := array['¿Cuántos años tiene Marta?','¿Cómo va Marta al trabajo?','¿A quién visita los fines de semana?'];
  a1_reading_a text[]     := array['Veinticinco','En autobús','A sus padres'];
  a1_reading_w text[][]   := array[
    array['Quince','Treinta','Cincuenta'],
    array['En coche','A pie','En tren'],
    array['A sus hermanos','A sus amigos','A su pareja']
  ];

  a2_reading_passage text := E'El verano pasado decidí cambiar de trabajo. Antes trabajaba en una oficina muy pequeña y me sentía aburrido. Encontré un puesto en una empresa internacional con muchas oportunidades de viajar. Aunque al principio fue difícil, ahora estoy contento porque he aprendido mucho y he conocido a gente de varios países.';
  a2_reading_q text[]     := array['¿Por qué cambió de trabajo?','¿Cómo es la nueva empresa?','¿Cómo se siente ahora?'];
  a2_reading_a text[]     := array['Porque se sentía aburrido','Internacional, con muchos viajes','Contento porque ha aprendido mucho'];
  a2_reading_w text[][]   := array[
    array['Porque ganaba poco','Porque cambió de ciudad','Porque tuvo una discusión'],
    array['Pequeña y local','Muy estricta y aburrida','Familiar y pequeña'],
    array['Estresado y triste','Indiferente','Decepcionado']
  ];

  b1_reading_passage text := E'Cada vez más jóvenes españoles deciden estudiar o trabajar en el extranjero al terminar la universidad. Las razones son variadas: muchos buscan mejores salarios, otros quieren aprender un idioma o vivir nuevas experiencias culturales. Sin embargo, esta tendencia preocupa a algunos expertos, que temen una pérdida de talento difícil de recuperar. Por eso, varios gobiernos regionales han empezado a ofrecer incentivos para que estos jóvenes regresen a España después de unos años fuera.';
  b1_reading_q text[]     := array['¿Por qué muchos jóvenes españoles se van al extranjero?','¿Qué preocupa a los expertos?','¿Qué hacen algunos gobiernos para responder a este fenómeno?'];
  b1_reading_a text[]     := array['Buscan mejores salarios y nuevas experiencias','Una pérdida de talento difícil de recuperar','Ofrecen incentivos para que regresen'];
  b1_reading_w text[][]   := array[
    array['Porque no encuentran ningún trabajo','Porque no quieren vivir con su familia','Porque los obligan sus universidades'],
    array['El exceso de competencia entre jóvenes','La falta de interés por aprender idiomas','La saturación de las universidades'],
    array['Suben los impuestos a los emigrantes','Prohíben salir del país','No hacen nada al respecto']
  ];

  b2_reading_passage text := E'La inteligencia artificial generativa ha llegado al mundo creativo con una rapidez inesperada. Algunos artistas la ven como una herramienta más, comparable al ordenador en su día; otros, en cambio, denuncian que abarata la producción cultural y devalúa el trabajo humano. La discusión no es meramente económica: cuando un texto o una imagen generados por una máquina cumplen los criterios de calidad tradicionales, se ven afectadas categorías tan fundamentales como la autoría, la originalidad y la noción misma de arte. Es probable que el debate se prolongue durante años.';
  b2_reading_q text[]     := array['¿Cómo ven algunos artistas la inteligencia artificial generativa?','¿Por qué la discusión no es solo económica, según el texto?','¿Qué predice el autor sobre el debate?'];
  b2_reading_a text[]     := array['Como una herramienta más, comparable al ordenador','Porque afecta la autoría, originalidad y noción de arte','Que se prolongará durante años'];
  b2_reading_w text[][]   := array[
    array['Como un sustituto definitivo del artista','Como una moda pasajera sin importancia','Como una herramienta hostil que hay que prohibir'],
    array['Porque solo afecta a los grandes museos','Porque los precios suben más rápido que la inflación','Porque la tecnología es siempre neutra'],
    array['Que se cerrará en pocos meses','Que perderá interés rápidamente','Que terminará con la regulación de la IA por ley']
  ];

  c1_reading_passage text := E'La discusión sobre el modelo de "ciudad de los quince minutos" lleva décadas formulándose en círculos urbanísticos, pero sólo en los últimos años ha encontrado un eco político serio. Sus defensores sostienen que tener escuelas, trabajo, comercio y ocio a un cuarto de hora a pie o en bicicleta reduce emisiones, mejora la salud pública y devuelve a las calles una sociabilidad que la motorización masiva había arrinconado. Sus detractores, sin embargo, han abierto un frente inesperado: parte de la oposición ha visto en estas medidas un intento velado de restringir la libertad de movimiento, e incluso ha vinculado el modelo con teorías conspirativas. El debate, por tanto, ya no es solamente técnico, sino profundamente cultural y simbólico.';
  c1_reading_q text[]     := array['Según los defensores, ¿qué ventajas ofrece este modelo?','¿Qué argumento inesperado han usado algunos detractores?','¿Qué naturaleza tiene hoy el debate, según el autor?'];
  c1_reading_a text[]     := array['Menos emisiones, mejor salud pública y más sociabilidad','Lo presentan como una restricción encubierta de la libertad','Es a la vez cultural y simbólico, no solo técnico'];
  c1_reading_w text[][]   := array[
    array['Mayor crecimiento económico y más vehículos privados','Más oficinas en el centro y menos parques','Más rascacielos y menos comercio local'],
    array['Lo apoyan sin reservas','Lo consideran demasiado caro técnicamente','Solo lo critican los técnicos municipales'],
    array['Es exclusivamente técnico','Es exclusivamente económico','Está prácticamente cerrado en los foros académicos']
  ];

  -- Loop variables
  v_level    text;
  i          int;
  j          int;

  -- Per-level container variables (filled in the case block below)
  cur_listen_mc_q   text[];
  cur_listen_mc_a   text[];
  cur_listen_mc_w   text[][];
  cur_listen_typed_q text;
  cur_listen_typed_a text;
  cur_speak_repeat  text[];
  cur_speak_topics  text[];
  cur_writing       text[];
  cur_reading_p     text;
  cur_reading_q     text[];
  cur_reading_a     text[];
  cur_reading_w     text[][];
begin
  select id into v_lang_id from public.languages where code = 'spanish';
  if v_lang_id is null then raise exception 'Spanish language not found'; end if;

  for v_level in select unnest(array['A1','A2','B1','B2','C1']) loop
    -- Bind per-level templates
    case v_level
      when 'A1' then
        cur_listen_mc_q := a1_listen_mc_q;
        cur_listen_mc_a := a1_listen_mc_a;
        cur_listen_mc_w := a1_listen_mc_w;
        cur_listen_typed_q := a1_listen_typed_q;
        cur_listen_typed_a := a1_listen_typed_a;
        cur_speak_repeat  := a1_speak_repeat_phrases;
        cur_speak_topics  := a1_speak_topics;
        cur_writing       := a1_writing_prompts;
        cur_reading_p     := a1_reading_passage;
        cur_reading_q     := a1_reading_q;
        cur_reading_a     := a1_reading_a;
        cur_reading_w     := a1_reading_w;
      when 'A2' then
        cur_listen_mc_q := a2_listen_mc_q;
        cur_listen_mc_a := a2_listen_mc_a;
        cur_listen_mc_w := a2_listen_mc_w;
        cur_listen_typed_q := a2_listen_typed_q;
        cur_listen_typed_a := a2_listen_typed_a;
        cur_speak_repeat  := a2_speak_repeat_phrases;
        cur_speak_topics  := a2_speak_topics;
        cur_writing       := a2_writing_prompts;
        cur_reading_p     := a2_reading_passage;
        cur_reading_q     := a2_reading_q;
        cur_reading_a     := a2_reading_a;
        cur_reading_w     := a2_reading_w;
      when 'B1' then
        cur_listen_mc_q := b1_listen_mc_q;
        cur_listen_mc_a := b1_listen_mc_a;
        cur_listen_mc_w := b1_listen_mc_w;
        cur_listen_typed_q := b1_listen_typed_q;
        cur_listen_typed_a := b1_listen_typed_a;
        cur_speak_repeat  := b1_speak_repeat_phrases;
        cur_speak_topics  := b1_speak_topics;
        cur_writing       := b1_writing_prompts;
        cur_reading_p     := b1_reading_passage;
        cur_reading_q     := b1_reading_q;
        cur_reading_a     := b1_reading_a;
        cur_reading_w     := b1_reading_w;
      when 'B2' then
        cur_listen_mc_q := b2_listen_mc_q;
        cur_listen_mc_a := b2_listen_mc_a;
        cur_listen_mc_w := b2_listen_mc_w;
        cur_listen_typed_q := b2_listen_typed_q;
        cur_listen_typed_a := b2_listen_typed_a;
        cur_speak_repeat  := b2_speak_repeat_phrases;
        cur_speak_topics  := b2_speak_topics;
        cur_writing       := b2_writing_prompts;
        cur_reading_p     := b2_reading_passage;
        cur_reading_q     := b2_reading_q;
        cur_reading_a     := b2_reading_a;
        cur_reading_w     := b2_reading_w;
      when 'C1' then
        cur_listen_mc_q := c1_listen_mc_q;
        cur_listen_mc_a := c1_listen_mc_a;
        cur_listen_mc_w := c1_listen_mc_w;
        cur_listen_typed_q := c1_listen_typed_q;
        cur_listen_typed_a := c1_listen_typed_a;
        cur_speak_repeat  := c1_speak_repeat_phrases;
        cur_speak_topics  := c1_speak_topics;
        cur_writing       := c1_writing_prompts;
        cur_reading_p     := c1_reading_passage;
        cur_reading_q     := c1_reading_q;
        cur_reading_a     := c1_reading_a;
        cur_reading_w     := c1_reading_w;
    end case;

    ------------------------------------------------------------------
    -- LISTENING lessons (lesson.type = 'listening')
    ------------------------------------------------------------------
    for v_lesson_id in
      select l.id
      from public.lessons l
      join public.courses c on c.id = l.course_id
      where c.language_id = v_lang_id
        and c.cefr_level  = v_level
        and l.type = 'listening'
    loop
      -- 3 MC listening
      for i in 1..array_length(cur_listen_mc_q, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (
          v_lesson_id, 'listening',
          cur_listen_mc_q[i],
          cur_listen_mc_a[i],
          array[cur_listen_mc_w[i][1], cur_listen_mc_w[i][2], cur_listen_mc_w[i][3]]::text[],
          i
        );
      end loop;
      -- 1 typed-response listening
      insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
      values (
        v_lesson_id, 'listening',
        cur_listen_typed_q,
        cur_listen_typed_a,
        array[]::text[],
        array_length(cur_listen_mc_q, 1) + 1
      );
    end loop;

    ------------------------------------------------------------------
    -- SPEAKING lessons
    ------------------------------------------------------------------
    for v_lesson_id in
      select l.id
      from public.lessons l
      join public.courses c on c.id = l.course_id
      where c.language_id = v_lang_id
        and c.cefr_level  = v_level
        and l.type = 'speaking'
    loop
      -- 2 repeat-phrase speaking
      for i in 1..array_length(cur_speak_repeat, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (
          v_lesson_id, 'speaking',
          'Say this aloud: "' || cur_speak_repeat[i] || '"',
          cur_speak_repeat[i],
          array[]::text[],
          i
        );
      end loop;
      -- 2 topic-monologue speaking
      for i in 1..array_length(cur_speak_topics, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (
          v_lesson_id, 'speaking',
          cur_speak_topics[i],
          '',
          array[]::text[],
          array_length(cur_speak_repeat, 1) + i
        );
      end loop;
    end loop;

    ------------------------------------------------------------------
    -- WRITING lessons
    ------------------------------------------------------------------
    for v_lesson_id in
      select l.id
      from public.lessons l
      join public.courses c on c.id = l.course_id
      where c.language_id = v_lang_id
        and c.cefr_level  = v_level
        and l.type = 'writing'
    loop
      for i in 1..array_length(cur_writing, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (
          v_lesson_id, 'writing',
          cur_writing[i],
          '',
          array[]::text[],
          i
        );
      end loop;
    end loop;

    ------------------------------------------------------------------
    -- READING lessons — passage + comprehension MC.
    -- Each exercise question carries the passage so the candidate
    -- always sees it, regardless of question order or whether they
    -- skipped the teaching phase.
    ------------------------------------------------------------------
    for v_lesson_id in
      select l.id
      from public.lessons l
      join public.courses c on c.id = l.course_id
      where c.language_id = v_lang_id
        and c.cefr_level  = v_level
        and l.type = 'reading'
    loop
      for i in 1..array_length(cur_reading_q, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (
          v_lesson_id, 'multiple_choice',
          E'Lee el siguiente texto y responde:\n\n' || cur_reading_p || E'\n\nPregunta: ' || cur_reading_q[i],
          cur_reading_a[i],
          array[cur_reading_w[i][1], cur_reading_w[i][2], cur_reading_w[i][3]]::text[],
          i
        );
      end loop;
    end loop;
  end loop;
end $$;

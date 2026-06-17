-- 040_spanish_a2_ai_graded_exercises.sql
-- Same shape as 039 but for every Spanish A2 lesson (15 sections × 7
-- teaching lessons). Each lesson gets one writing, one speaking and one
-- typed-listening exercise that all flow through the AI grader and the
-- instant-feedback panel.
--
-- A2 difficulty (vs A1):
--   - Writing tier 1 (sections 1-5):  2 sentences min, past+present tense
--   - Writing tier 2 (sections 6-10): 2-3 sentences with a connector
--                                     (pero / y / también / porque)
--   - Writing tier 3 (sections 11-15): 3 sentences min, past tense required
--   - Speaking tier 1: 3 sentences
--   - Speaking tier 2: 3-4 sentences
--   - Speaking tier 3: 4-5 sentences
--   - Listening prompts use compound sentences and past-tense questions
--
-- The schema constraint already allows 'writing' from migration 039, so
-- this file only seeds content.
--
-- Idempotent.

do $$
declare
  v_lang_id   bigint;
  v_course_id bigint;
  v_lesson_id bigint;

  -- A2 sections, canonical order from 015_spanish_restructure_15x8.sql
  section_names text[] := array[
    'Daily Routines','Health & Body','Hobbies','Work & Jobs','Directions',
    'Feelings & Emotions','Celebrations','Nature','Sports','Music',
    'Travel Planning','Restaurants','School','Technology Basics','Social Media'
  ];

  -- 7 writing prompts per section, indexed [section_idx][lesson_idx 1..7]
  writing_prompts text[][] := array[
    -- 1: Daily Routines (tier 1)
    array['Describe what you did yesterday morning. Write 2 sentences.',
          'Write about your morning routine using past tense. 2 sentences.',
          'Describe what you usually do after work or school. 2 sentences.',
          'Write what you ate for dinner last night. 2 sentences.',
          'Describe your last weekend in 2 sentences.',
          'Write about your typical evening. 2 sentences.',
          'Write 2 sentences about what you did this morning before class.'],
    -- 2: Health & Body
    array['Describe what you do to stay healthy. 2 sentences.',
          'Write about the last time you went to the doctor. 2 sentences.',
          'Describe how you exercise. 2 sentences.',
          'Write about a time you were sick. 2 sentences.',
          'Describe your sleep habits. 2 sentences.',
          'Write 2 sentences about a healthy breakfast you had recently.',
          'Describe how you take care of your body. 2 sentences.'],
    -- 3: Hobbies
    array['Describe your favorite hobby. 2 sentences.',
          'Write about a hobby you started recently. 2 sentences.',
          'Describe what you did last weekend for fun. 2 sentences.',
          'Write about a hobby you want to try. 2 sentences.',
          'Describe a hobby you used to do as a child. 2 sentences.',
          'Write 2 sentences about how often you do your hobby.',
          'Describe a hobby a friend of yours has. 2 sentences.'],
    -- 4: Work & Jobs
    array['Describe your job or what you study. 2 sentences.',
          'Write about your ideal job. 2 sentences.',
          'Describe what you did at work or school yesterday. 2 sentences.',
          'Write 2 sentences about your colleagues or classmates.',
          'Describe your work schedule. 2 sentences.',
          'Write about a job you had before. 2 sentences.',
          'Describe a job you would never do and why. 2 sentences.'],
    -- 5: Directions
    array['Write directions from your home to a shop. 2 sentences.',
          'Describe how to get to your school or office. 2 sentences.',
          'Write about the last time you got lost. 2 sentences.',
          'Describe a place near your house. 2 sentences.',
          'Write 2 sentences asking for directions politely.',
          'Describe how to get to a park near you. 2 sentences.',
          'Write 2 sentences about a city you can navigate well.'],
    -- 6: Feelings & Emotions (tier 2)
    array['Describe how you felt yesterday and why. Use 2-3 sentences and the word "porque".',
          'Write about a happy memory. 2-3 sentences with "y" or "también".',
          'Describe a time you were nervous. 2-3 sentences using "pero".',
          'Write about what makes you laugh. 2-3 sentences with a connector.',
          'Describe a recent disappointment. 2-3 sentences using "porque".',
          'Write 2-3 sentences about what relaxes you, using "y" or "también".',
          'Describe how you feel about your weekend plans. 2-3 sentences.'],
    -- 7: Celebrations
    array['Describe your last birthday. 2-3 sentences with a connector.',
          'Write about a holiday you celebrate in your country. 2-3 sentences.',
          'Describe a wedding or party you attended. 2-3 sentences.',
          'Write 2-3 sentences about your favorite celebration and why.',
          'Describe how you celebrated last New Year. 2-3 sentences.',
          'Write about a family tradition. 2-3 sentences with a connector.',
          'Describe a gift you gave or received recently. 2-3 sentences.'],
    -- 8: Nature
    array['Describe a beautiful place in nature you know. 2-3 sentences with "y".',
          'Write about your favorite outdoor activity. 2-3 sentences.',
          'Describe the last time you walked in a park. 2-3 sentences.',
          'Write 2-3 sentences about an animal you saw in the wild.',
          'Describe the weather changes in your region. 2-3 sentences.',
          'Write about a hike or walk you took. 2-3 sentences.',
          'Describe a flower or tree you like. 2-3 sentences with a connector.'],
    -- 9: Sports
    array['Describe a sport you play or watch. 2-3 sentences with "porque".',
          'Write about an athlete you admire. 2-3 sentences.',
          'Describe a recent sports event you saw. 2-3 sentences.',
          'Write 2-3 sentences about your favorite team and why.',
          'Describe how you exercise during the week. 2-3 sentences.',
          'Write about a sport you would like to learn. 2-3 sentences.',
          'Describe a sport you played as a child. 2-3 sentences with a connector.'],
    -- 10: Music
    array['Describe your favorite music genre. 2-3 sentences with a connector.',
          'Write about the last concert you attended. 2-3 sentences.',
          'Describe a song that means a lot to you. 2-3 sentences.',
          'Write 2-3 sentences about a musician you like and why.',
          'Describe how often you listen to music. 2-3 sentences.',
          'Write about an instrument you play or want to learn. 2-3 sentences.',
          'Describe music you listened to as a teenager. 2-3 sentences.'],
    -- 11: Travel Planning (tier 3, past tense required, 3 sentences min)
    array['Describe a trip you took last year. Write 3 sentences in the past tense.',
          'Write about a destination you visited and what you did there. 3 sentences in past tense.',
          'Describe the last time you used a plane or train. 3 sentences.',
          'Write 3 sentences in past tense about a hotel you stayed in.',
          'Describe a problem you had while traveling. 3 sentences in past tense.',
          'Write about a holiday you enjoyed and why. 3 sentences in past tense.',
          'Describe a trip you took with family or friends. 3 sentences in past tense.'],
    -- 12: Restaurants
    array['Describe the last time you ate at a restaurant. 3 sentences in past tense.',
          'Write 3 sentences about a memorable meal you had.',
          'Describe a restaurant you visited recently. 3 sentences in past tense.',
          'Write about a dish you tried for the first time. 3 sentences in past tense.',
          'Describe a dinner with friends or family. 3 sentences in past tense.',
          'Write 3 sentences about a bad experience at a restaurant.',
          'Describe a typical lunch you had last week. 3 sentences in past tense.'],
    -- 13: School
    array['Describe your first day of school. 3 sentences in past tense.',
          'Write about a teacher you remember well. 3 sentences in past tense.',
          'Describe an exam you took recently. 3 sentences in past tense.',
          'Write 3 sentences about a class you enjoyed as a child.',
          'Describe a friend you met at school. 3 sentences in past tense.',
          'Write about a difficult lesson you learned. 3 sentences in past tense.',
          'Describe a school trip you went on. 3 sentences in past tense.'],
    -- 14: Technology Basics
    array['Describe how technology helped you last week. 3 sentences in past tense.',
          'Write about an app you started using recently. 3 sentences in past tense.',
          'Describe a problem you had with your phone or computer. 3 sentences in past tense.',
          'Write 3 sentences about the last time you fixed something with technology.',
          'Describe a device you bought this year. 3 sentences in past tense.',
          'Write about how you used the internet yesterday. 3 sentences in past tense.',
          'Describe an online service you found useful recently. 3 sentences in past tense.'],
    -- 15: Social Media
    array['Describe how you used social media yesterday. 3 sentences in past tense.',
          'Write 3 sentences about a post or video you saw recently.',
          'Describe a friend you reconnected with online. 3 sentences in past tense.',
          'Write about something you learned from social media. 3 sentences in past tense.',
          'Describe a time you took a break from social media. 3 sentences in past tense.',
          'Write 3 sentences about a person you follow online and why.',
          'Describe a trend you noticed recently on social media. 3 sentences in past tense.']
  ];

  -- 7 speaking topic prompts per section
  speaking_prompts text[][] := array[
    -- 1: Daily Routines (tier 1, 3 sentences)
    array['Talk about your typical morning. Speak three sentences in Spanish.',
          'Describe what you did yesterday from morning to night. Three sentences.',
          'Tell me how your weekend routine differs from weekdays. Three sentences.',
          'Describe what you eat in a typical day. Three sentences.',
          'Talk about what you usually do after dinner. Three sentences.',
          'Describe your routine before bed. Three sentences.',
          'Tell me what you did this morning before coming here. Three sentences.'],
    -- 2: Health & Body
    array['Tell me what you do to stay healthy. Three sentences.',
          'Describe the last time you were sick. Three sentences.',
          'Talk about your favorite way to exercise. Three sentences.',
          'Describe how you sleep at night. Three sentences.',
          'Tell me about a healthy meal you had recently. Three sentences.',
          'Describe what you do when you have a headache. Three sentences.',
          'Talk about your visit to the doctor or dentist. Three sentences.'],
    -- 3: Hobbies
    array['Describe your favorite hobby and how often you do it. Three sentences.',
          'Talk about a hobby you started recently. Three sentences.',
          'Describe what you did for fun last weekend. Three sentences.',
          'Tell me about a hobby you would like to try. Three sentences.',
          'Talk about a hobby you had as a child. Three sentences.',
          'Describe a hobby that you share with a friend. Three sentences.',
          'Tell me about something creative you like to do. Three sentences.'],
    -- 4: Work & Jobs
    array['Describe what you do at work or school. Three sentences.',
          'Tell me about your ideal job. Three sentences.',
          'Describe your work schedule. Three sentences.',
          'Talk about a colleague or classmate you like. Three sentences.',
          'Tell me what you did at work yesterday. Three sentences.',
          'Describe the work you did in your first job. Three sentences.',
          'Talk about a job you would never want and why. Three sentences.'],
    -- 5: Directions
    array['Describe how to get from your home to the supermarket. Three sentences.',
          'Tell me about the last time you got lost. Three sentences.',
          'Describe a part of your city you know well. Three sentences.',
          'Explain how to reach your school or office. Three sentences.',
          'Tell me about a building near your house. Three sentences.',
          'Describe a place that is hard to find. Three sentences.',
          'Tell me how you usually find your way in a new city. Three sentences.'],
    -- 6: Feelings & Emotions (tier 2, 3-4 sentences)
    array['Tell me about something that made you happy last week. 3-4 sentences.',
          'Describe a time you felt proud of yourself. 3-4 sentences.',
          'Talk about something that worries you these days. 3-4 sentences.',
          'Describe how you feel about your job or studies. 3-4 sentences.',
          'Tell me about a moment that made you laugh. 3-4 sentences.',
          'Describe what you do when you feel sad. 3-4 sentences.',
          'Talk about a person who makes you feel calm. 3-4 sentences.'],
    -- 7: Celebrations
    array['Describe your last birthday and what you did. 3-4 sentences.',
          'Talk about a special holiday in your country. 3-4 sentences.',
          'Describe a wedding or party you remember. 3-4 sentences.',
          'Tell me about a family tradition. 3-4 sentences.',
          'Describe how you celebrated last New Year. 3-4 sentences.',
          'Talk about a gift that meant a lot to you. 3-4 sentences.',
          'Tell me about a small celebration you enjoyed recently. 3-4 sentences.'],
    -- 8: Nature
    array['Describe a place in nature that you love. 3-4 sentences.',
          'Talk about your favorite outdoor activity. 3-4 sentences.',
          'Describe a walk in the park you took recently. 3-4 sentences.',
          'Tell me about an animal you saw in the wild. 3-4 sentences.',
          'Describe the weather and seasons where you live. 3-4 sentences.',
          'Talk about a mountain, river or lake you visited. 3-4 sentences.',
          'Describe how nature changes near you across the year. 3-4 sentences.'],
    -- 9: Sports
    array['Talk about a sport you play or watch often. 3-4 sentences.',
          'Describe an athlete you admire and why. 3-4 sentences.',
          'Tell me about a sports event you watched recently. 3-4 sentences.',
          'Describe your favorite team. 3-4 sentences.',
          'Talk about how you exercise in a typical week. 3-4 sentences.',
          'Describe a sport you would like to learn. 3-4 sentences.',
          'Tell me about a sport you played as a child. 3-4 sentences.'],
    -- 10: Music
    array['Describe your favorite kind of music. 3-4 sentences.',
          'Talk about the last concert you went to. 3-4 sentences.',
          'Describe a song that is important to you. 3-4 sentences.',
          'Tell me about a musician you really like. 3-4 sentences.',
          'Describe how often you listen to music and where. 3-4 sentences.',
          'Talk about an instrument you play or would like to play. 3-4 sentences.',
          'Describe the music you listened to as a teenager. 3-4 sentences.'],
    -- 11: Travel Planning (tier 3, 4-5 sentences)
    array['Talk about your last vacation. 4-5 sentences using past tense.',
          'Describe a city you visited and what you did there. 4-5 sentences.',
          'Tell me about a trip you took with friends or family. 4-5 sentences.',
          'Describe a hotel you stayed in. 4-5 sentences in past tense.',
          'Talk about a problem you had while traveling and how you solved it. 4-5 sentences.',
          'Describe your dream trip and why it appeals to you. 4-5 sentences.',
          'Tell me about a place you would visit again. 4-5 sentences in past tense.'],
    -- 12: Restaurants
    array['Talk about a restaurant you like and what you usually order. 4-5 sentences.',
          'Describe the last time you ate dinner with friends. 4-5 sentences in past tense.',
          'Tell me about a dish that surprised you. 4-5 sentences in past tense.',
          'Describe a bad experience at a restaurant. 4-5 sentences in past tense.',
          'Talk about a typical meal in your country. 4-5 sentences.',
          'Tell me about ordering food when you traveled. 4-5 sentences in past tense.',
          'Describe a memorable lunch from last month. 4-5 sentences in past tense.'],
    -- 13: School
    array['Describe a typical day at school or university. 4-5 sentences.',
          'Tell me about a teacher who influenced you. 4-5 sentences in past tense.',
          'Describe an exam or project you remember. 4-5 sentences in past tense.',
          'Talk about a friend you met at school. 4-5 sentences in past tense.',
          'Describe a school trip you went on. 4-5 sentences in past tense.',
          'Tell me about a difficult subject you studied. 4-5 sentences in past tense.',
          'Describe your school uniform or daily clothes. 4-5 sentences.'],
    -- 14: Technology Basics
    array['Describe how technology helps you in daily life. 4-5 sentences.',
          'Talk about your phone and the apps you use most. 4-5 sentences.',
          'Tell me about a problem you had with technology last month. 4-5 sentences.',
          'Describe a website or service you discovered recently. 4-5 sentences.',
          'Talk about a piece of technology you would like to buy. 4-5 sentences.',
          'Describe how the internet has changed your work or studies. 4-5 sentences.',
          'Tell me about the last time you fixed a technical problem. 4-5 sentences.'],
    -- 15: Social Media
    array['Talk about which social media platforms you use and why. 4-5 sentences.',
          'Describe a post or video that you saw recently. 4-5 sentences in past tense.',
          'Tell me about a person you follow online. 4-5 sentences.',
          'Describe a time you took a break from social media. 4-5 sentences in past tense.',
          'Talk about something you learned online recently. 4-5 sentences.',
          'Describe the pros and cons of social media in your life. 4-5 sentences.',
          'Tell me about how social media affects your generation. 4-5 sentences.']
  ];

  -- Spanish audio the TTS will read; user types a Spanish reply (1-2 sentences)
  listening_audio text[][] := array[
    -- 1: Daily Routines
    array['¿Qué hiciste ayer por la mañana?',
          'Cuéntame tu rutina diaria en pocas frases.',
          '¿A qué hora te acostaste anoche y por qué?',
          '¿Qué desayunaste hoy y a qué hora?',
          'Háblame de tu fin de semana pasado.',
          '¿Cómo es tu día normal entre semana?',
          'Cuéntame qué hiciste antes de venir aquí.'],
    -- 2: Health & Body
    array['¿Qué haces para mantenerte sano?',
          'Cuéntame la última vez que estuviste enfermo.',
          '¿Cuántas veces a la semana haces ejercicio?',
          '¿Cómo dormiste anoche y por qué?',
          'Háblame de una comida saludable que comiste recientemente.',
          '¿Qué haces cuando te duele la cabeza?',
          'Cuéntame tu última visita al médico.'],
    -- 3: Hobbies
    array['¿Cuál es tu pasatiempo favorito y cuándo lo haces?',
          'Cuéntame un pasatiempo nuevo que empezaste.',
          '¿Qué hiciste el fin de semana pasado por diversión?',
          'Háblame de un pasatiempo que te gustaría probar.',
          'Cuéntame un pasatiempo que tenías de niño.',
          '¿Compartes algún pasatiempo con tus amigos?',
          'Háblame de algo creativo que te guste hacer.'],
    -- 4: Work & Jobs
    array['¿En qué trabajas o qué estudias?',
          'Cuéntame cómo fue tu día de trabajo ayer.',
          '¿Cómo es tu horario laboral?',
          'Háblame de un compañero de trabajo que aprecias.',
          'Cuéntame tu primer trabajo.',
          '¿Cuál sería tu trabajo ideal?',
          'Háblame de un trabajo que no harías nunca.'],
    -- 5: Directions
    array['¿Cómo llego desde aquí al supermercado?',
          'Cuéntame la última vez que te perdiste.',
          'Háblame de un lugar de tu ciudad que conoces bien.',
          'Explícame cómo llegar a tu casa.',
          '¿Qué edificios importantes hay cerca de tu casa?',
          'Háblame de un sitio difícil de encontrar.',
          '¿Cómo te orientas en una ciudad nueva?'],
    -- 6: Feelings & Emotions
    array['¿Cómo te sentiste la semana pasada?',
          'Cuéntame un momento en el que te sentiste muy orgulloso.',
          '¿Qué te preocupa últimamente y por qué?',
          'Háblame de algo que te hizo reír recientemente.',
          'Cuéntame qué haces cuando estás triste.',
          '¿Qué persona te transmite tranquilidad?',
          'Háblame de cómo te sientes hoy y por qué.'],
    -- 7: Celebrations
    array['Cuéntame cómo fue tu último cumpleaños.',
          '¿Cómo celebras la Navidad o una fiesta importante en tu familia?',
          'Háblame de una boda o fiesta que recuerdas.',
          '¿Tienes alguna tradición familiar importante?',
          'Cuéntame qué hiciste en Año Nuevo.',
          'Háblame de un regalo especial que recibiste o diste.',
          'Cuéntame una celebración pequeña que disfrutaste recientemente.'],
    -- 8: Nature
    array['¿Cuál es tu lugar favorito en la naturaleza?',
          'Cuéntame un paseo por el parque que diste hace poco.',
          'Háblame de un animal que viste fuera de la ciudad.',
          '¿Cómo cambian las estaciones donde vives?',
          'Cuéntame una excursión a la montaña, río o lago.',
          'Háblame de una flor o un árbol que te guste.',
          '¿Pasas mucho tiempo al aire libre? Cuéntame.'],
    -- 9: Sports
    array['¿Qué deportes practicas o ves?',
          'Cuéntame un evento deportivo que viste recientemente.',
          'Háblame de tu deportista favorito y por qué te gusta.',
          '¿Cómo haces ejercicio durante la semana?',
          'Cuéntame un deporte que practicabas de niño.',
          '¿Qué deporte te gustaría aprender y por qué?',
          'Háblame de tu equipo favorito y de su último partido.'],
    -- 10: Music
    array['¿Qué tipo de música te gusta y por qué?',
          'Cuéntame el último concierto al que fuiste.',
          'Háblame de una canción importante para ti.',
          '¿Hay un músico que te marcó? Cuéntame.',
          '¿Cuándo y dónde escuchas música normalmente?',
          'Háblame de un instrumento que tocas o quieres aprender.',
          '¿Qué música te gustaba de adolescente?'],
    -- 11: Travel Planning
    array['¿Adónde viajaste el verano pasado y qué hiciste allí?',
          'Cuéntame un viaje que te marcó.',
          '¿Cómo fue el último hotel donde te alojaste?',
          'Háblame de un problema que tuviste viajando.',
          '¿Cuál es tu destino soñado y por qué?',
          'Cuéntame un viaje que harías otra vez.',
          'Háblame de un transporte público que usaste en otro país.'],
    -- 12: Restaurants
    array['Cuéntame la última vez que cenaste fuera.',
          '¿Cuál es tu restaurante favorito y por qué?',
          'Háblame de un plato que probaste por primera vez.',
          'Cuéntame una mala experiencia en un restaurante.',
          '¿Qué pediste la última vez que comiste con amigos?',
          'Háblame de una comida típica de tu país.',
          'Cuéntame cómo es comer fuera en tu ciudad.'],
    -- 13: School
    array['Cuéntame tu primer día de escuela.',
          'Háblame de un profesor que recuerdas bien.',
          '¿Cómo fue un examen reciente que hiciste?',
          'Cuéntame un viaje escolar que recuerdas.',
          'Háblame de una asignatura que te costaba.',
          '¿Quién fue tu mejor amigo del colegio?',
          'Cuéntame cómo era tu uniforme o la ropa que llevabas a clase.'],
    -- 14: Technology Basics
    array['¿Cómo te ayuda la tecnología en tu día a día?',
          'Cuéntame una aplicación nueva que descargaste.',
          'Háblame de un problema técnico que tuviste el mes pasado.',
          '¿Qué dispositivo te gustaría comprar y por qué?',
          'Cuéntame la última vez que arreglaste algo tecnológico.',
          'Háblame de cómo usas internet para estudiar o trabajar.',
          '¿Hay alguna página web que uses cada día? Cuéntame.'],
    -- 15: Social Media
    array['¿Cuánto tiempo pasas en las redes sociales al día?',
          'Cuéntame una publicación que viste recientemente.',
          'Háblame de una persona que sigues online y por qué.',
          'Cuéntame una vez que te alejaste de las redes sociales.',
          '¿Qué aprendiste hace poco en internet?',
          'Háblame de los pros y contras de las redes sociales.',
          'Cuéntame cómo afectan las redes sociales a tu generación.']
  ];

  -- Reference Spanish responses given to the AI grader as context
  listening_reference text[][] := array[
    -- 1
    array['Ayer por la mañana me levanté tarde y desayuné un café.',
          'Cada mañana me ducho, desayuno y voy al trabajo.',
          'Me acosté a las once porque estaba muy cansado.',
          'Hoy desayuné tostadas y café a las ocho.',
          'El fin de semana pasado fui al cine y descansé en casa.',
          'Entre semana trabajo por la mañana y estudio por la tarde.',
          'Antes de venir me preparé un café y leí las noticias.'],
    -- 2
    array['Camino media hora cada día y como sano.',
          'La semana pasada tuve gripe y descansé dos días.',
          'Hago ejercicio tres veces a la semana en el gimnasio.',
          'Anoche dormí bien porque no usé el móvil antes de dormir.',
          'Ayer comí pollo a la plancha con verduras.',
          'Cuando me duele la cabeza tomo un té y descanso.',
          'Fui al médico la semana pasada por una revisión.'],
    -- 3
    array['Mi pasatiempo favorito es leer; lo hago todas las noches.',
          'Empecé a aprender guitarra el mes pasado.',
          'El sábado pasado salí a correr con mis amigos.',
          'Me gustaría probar la fotografía algún día.',
          'De niño jugaba al fútbol en el parque.',
          'Comparto la cocina con mi pareja los fines de semana.',
          'Me gusta dibujar cuando tengo tiempo libre.'],
    -- 4
    array['Soy diseñador gráfico y trabajo en una agencia pequeña.',
          'Ayer terminé un proyecto importante para un cliente.',
          'Trabajo de nueve a cinco con una hora para comer.',
          'Mi compañera Laura siempre me ayuda con los plazos.',
          'Mi primer trabajo fue camarero en un restaurante.',
          'Mi trabajo ideal sería viajar y escribir reportajes.',
          'Nunca trabajaría limpiando rascacielos porque tengo vértigo.'],
    -- 5
    array['Sigues recto dos calles y giras a la derecha; está al lado del banco.',
          'La última vez me perdí en Barcelona buscando una cafetería.',
          'Conozco bien el centro histórico de mi ciudad.',
          'Mi casa está cerca del parque, a diez minutos del metro.',
          'Cerca de mi casa hay una farmacia y una panadería.',
          'Hay un café escondido en una calle estrecha que es difícil de encontrar.',
          'Uso el mapa del móvil cuando estoy en una ciudad nueva.'],
    -- 6
    array['La semana pasada me sentí cansada porque trabajé mucho.',
          'Me sentí muy orgulloso cuando aprobé el examen.',
          'Últimamente me preocupa el trabajo porque hay muchos cambios.',
          'Mi amigo me hizo reír mucho con un chiste el sábado.',
          'Cuando estoy triste escucho música y salgo a caminar.',
          'Mi pareja me transmite mucha calma con su forma de ser.',
          'Hoy me siento bien porque dormí mucho anoche.'],
    -- 7
    array['Mi último cumpleaños lo celebré con amigos en un restaurante.',
          'Celebramos la Navidad con toda la familia y comemos juntos.',
          'Fui a la boda de mi prima el verano pasado; fue preciosa.',
          'Cada domingo comemos en casa de mis abuelos, es una tradición.',
          'Pasé Año Nuevo con mis amigos viendo los fuegos artificiales.',
          'Me regalaron un libro que llevaba meses buscando.',
          'La semana pasada celebré con mi pareja nuestro aniversario.'],
    -- 8
    array['Mi lugar favorito es una playa cerca de mi pueblo.',
          'Hace poco paseé por el parque del Retiro durante una hora.',
          'Vi un ciervo en la sierra el verano pasado.',
          'Donde vivo, el invierno es frío y el verano caluroso.',
          'Fui de excursión a la montaña con mi familia el mes pasado.',
          'Me encantan los girasoles porque parece que sonríen.',
          'Sí, paso mucho tiempo al aire libre los fines de semana.'],
    -- 9
    array['Juego al baloncesto los jueves con un grupo de amigos.',
          'Vi la final de la Champions con mi padre el sábado pasado.',
          'Admiro mucho a Rafa Nadal porque trabaja muy duro.',
          'Voy al gimnasio tres días y corro los fines de semana.',
          'De niño jugaba al fútbol todos los días después de clase.',
          'Me gustaría aprender a esquiar el próximo invierno.',
          'Mi equipo favorito ganó el partido del fin de semana por dos a uno.'],
    -- 10
    array['Me gusta la música indie porque las letras son interesantes.',
          'El último concierto al que fui fue de Vetusta Morla en marzo.',
          'Una canción importante para mí es "Hoy" de Gloria Estefan.',
          'Me marcó mucho David Bowie por su forma de cambiar de estilo.',
          'Escucho música en el coche y mientras cocino.',
          'Toco un poco el piano y quiero aprender la batería.',
          'De adolescente escuchaba pop y rock alternativo.'],
    -- 11
    array['El verano pasado viajé a Italia y visité Roma y Florencia.',
          'Hace dos años hicimos un viaje a Japón que nos cambió la vida.',
          'El último hotel era pequeño pero muy acogedor.',
          'Perdí mi maleta en el aeropuerto y tardó tres días en aparecer.',
          'Mi destino soñado es Nueva Zelanda por su naturaleza.',
          'Volvería a Lisboa porque la comida y la gente me encantaron.',
          'En París cogí el metro todos los días para moverme por la ciudad.'],
    -- 12
    array['Anoche cené en un restaurante italiano cerca de casa.',
          'Mi restaurante favorito es un sitio japonés con buen sushi.',
          'Probé los caracoles por primera vez en un viaje a Francia.',
          'Una vez la comida llegó muy fría y la cuenta era incorrecta.',
          'La última vez pedimos paella y compartimos un postre.',
          'Una comida típica de mi país es la tortilla de patatas.',
          'En mi ciudad hay muchas tapas y la gente come fuera a menudo.'],
    -- 13
    array['Mi primer día de escuela lloré mucho pero hice un amigo enseguida.',
          'Recuerdo a la profesora Marta porque siempre nos motivaba.',
          'El último examen de matemáticas me costó pero aprobé.',
          'Fui a una excursión a un museo de ciencias en secundaria.',
          'La química me costaba mucho y tuve que estudiar extra.',
          'Mi mejor amigo del colegio se llama Javier; seguimos en contacto.',
          'En mi escuela llevábamos jersey azul y pantalón gris.'],
    -- 14
    array['Uso el móvil para todo: trabajo, compras y mensajes.',
          'La semana pasada descargué una aplicación para aprender idiomas.',
          'Mi ordenador se rompió el mes pasado y tuve que repararlo.',
          'Me gustaría comprar unos auriculares con cancelación de ruido.',
          'Ayer arreglé la conexión wifi reiniciando el router.',
          'Uso internet para investigar y para tomar clases online.',
          'Visito una web de recetas casi todos los días.'],
    -- 15
    array['Paso una hora al día más o menos en redes sociales.',
          'Vi un vídeo de cocina muy divertido en Instagram ayer.',
          'Sigo a una fotógrafa porque comparte fotos increíbles de viajes.',
          'En enero estuve dos semanas sin redes sociales y descansé bien.',
          'En internet aprendí a hacer pan casero la semana pasada.',
          'Las redes ayudan a estar conectado pero a veces quitan tiempo.',
          'Las redes sociales influyen mucho en cómo nos comunicamos hoy.']
  ];

  i int;
  lesson_idx int;
begin
  select id into v_lang_id from public.languages where code = 'spanish';
  if v_lang_id is null then raise exception 'Spanish language not found'; end if;

  for i in 1..array_length(section_names, 1) loop
    select id into v_course_id
    from public.courses
    where language_id = v_lang_id
      and cefr_level = 'A2'
      and title = section_names[i]
    limit 1;

    if v_course_id is null then continue; end if;

    for lesson_idx in 1..7 loop
      select id into v_lesson_id
      from public.lessons
      where course_id = v_course_id
        and order_index = lesson_idx
      limit 1;

      if v_lesson_id is null then continue; end if;

      delete from public.exercises
      where lesson_id = v_lesson_id
        and type in ('listening','speaking','writing');

      insert into public.exercises
        (lesson_id, type, question, correct_answer, wrong_answers, order_index)
      values
        (v_lesson_id, 'writing',
         writing_prompts[i][lesson_idx],
         '',
         array[]::text[],
         100),
        (v_lesson_id, 'speaking',
         speaking_prompts[i][lesson_idx],
         '',
         array[]::text[],
         101),
        (v_lesson_id, 'listening',
         listening_audio[i][lesson_idx],
         listening_reference[i][lesson_idx],
         array[]::text[],
         102);
    end loop;
  end loop;
end $$;

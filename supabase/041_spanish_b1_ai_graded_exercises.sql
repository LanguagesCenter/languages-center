-- 041_spanish_b1_ai_graded_exercises.sql
-- Same shape as 039 (A1) and 040 (A2) but for every Spanish B1 lesson
-- (15 sections × 7 teaching lessons). Each lesson's listening / speaking /
-- writing rows are deleted and reseeded in the AI-graded format that
-- LessonClient already supports — writing prompt + topic-mode speaking +
-- typed-response listening with empty wrong_answers.
--
-- B1 difficulty bumps vs A2:
--   Writing tier 1 (sections 1-5):  3 sentences with an opinion
--   Writing tier 2 (sections 6-10): 3-4 sentences with future tense
--   Writing tier 3 (sections 11-15): 4 sentences, comparison or argument
--   Speaking tier 1: 4 sentences | tier 2: 4-5 | tier 3: 5-6
--   Listening audio uses compound / complex sentences and mini-dialogues;
--   the user types a 2-3 sentence reply demonstrating comprehension of
--   nuance, not just literal meaning.
--
-- Schema constraint already accepts 'writing' from 039.
-- Idempotent.

do $$
declare
  v_lang_id   bigint;
  v_course_id bigint;
  v_lesson_id bigint;

  -- B1 sections, canonical order from 015_spanish_restructure_15x8.sql
  section_names text[] := array[
    'Travel & Tourism','News & Media','Environment','Relationships','Culture & Traditions',
    'Money & Banking','Education','Politics Basics','Food & Cooking','Art & Literature',
    'Health & Medicine','Business Basics','Sports & Fitness','Music & Entertainment','Science Basics'
  ];

  -- 7 writing prompts per section [section_idx][lesson_idx 1..7]
  writing_prompts text[][] := array[
    -- 1: Travel & Tourism (tier 1, 3 sentences with an opinion)
    array['Do you prefer travelling alone or with friends? Write 3 sentences with your opinion.',
          'Is mass tourism good or bad for cities? Write 3 sentences explaining your view.',
          'Describe a destination you would recommend and why. 3 sentences with your opinion.',
          'Write 3 sentences arguing for or against all-inclusive resorts.',
          'Is it better to plan a trip or be spontaneous? 3 sentences with your view.',
          'Write 3 sentences about whether budget airlines have improved travel.',
          'Should tourists learn the local language? 3 sentences with your opinion.'],
    -- 2: News & Media
    array['How do you mostly get your news today? Write 3 sentences with your opinion.',
          'Are traditional newspapers still relevant? 3 sentences explaining your view.',
          'Write 3 sentences on whether the news makes us more anxious.',
          'Do you trust online news more or less than TV news? 3 sentences with your opinion.',
          'Is short-form video changing journalism for the better? 3 sentences with your view.',
          'Write 3 sentences about a news story you remember well and why it stayed with you.',
          'Should social media platforms label fake news? 3 sentences with your opinion.'],
    -- 3: Environment
    array['What is the biggest environmental problem in your country? 3 sentences with your view.',
          'Are individuals or governments more responsible for climate change? 3 sentences.',
          'Write 3 sentences on whether plastic should be banned in supermarkets.',
          'Is renewable energy realistic for every country? 3 sentences with your opinion.',
          'Should cities limit cars in the centre? 3 sentences with your opinion.',
          'Write 3 sentences about a small environmental change you have made.',
          'Are electric cars really a solution? 3 sentences with your view.'],
    -- 4: Relationships
    array['Is it better to have many friends or a few close ones? 3 sentences with your view.',
          'Has social media changed friendships for the better? 3 sentences with your opinion.',
          'Write 3 sentences about whether long-distance friendships work.',
          'Should couples share all their finances? 3 sentences with your opinion.',
          'Is it important to live with someone before marriage? 3 sentences with your view.',
          'Write 3 sentences about what makes a good friend.',
          'Should families eat dinner together every day? 3 sentences with your opinion.'],
    -- 5: Culture & Traditions
    array['What tradition from your country do you feel most proud of? 3 sentences with your opinion.',
          'Are old traditions still useful today? 3 sentences with your view.',
          'Write 3 sentences about a foreign tradition you admire.',
          'Should children learn folk music or modern music first? 3 sentences with your opinion.',
          'Has globalisation hurt local cultures? 3 sentences with your view.',
          'Write 3 sentences about a festival in your country and your opinion of it.',
          'Are wedding traditions changing in your country? 3 sentences with your opinion.'],
    -- 6: Money & Banking (tier 2, 3-4 sentences with future tense)
    array['How do you think you will manage your money in five years? 3-4 sentences using future tense.',
          'Will cash disappear in your country? 3-4 sentences using future tense.',
          'Write 3-4 sentences about how you plan to save for a big purchase, using future tense.',
          'How will online banking change in the next ten years? 3-4 sentences.',
          'Will young people in the future buy houses or rent forever? 3-4 sentences using future tense.',
          'Write 3-4 sentences about a financial habit you want to start, using future tense.',
          'Will cryptocurrencies become normal money one day? 3-4 sentences using future tense.'],
    -- 7: Education
    array['How will universities change in the next decade? 3-4 sentences using future tense.',
          'Write 3-4 sentences about a course you plan to take and what you hope to gain.',
          'Will online classes replace classrooms? 3-4 sentences using future tense.',
          'How do you think AI will affect schools? 3-4 sentences using future tense.',
          'Write 3-4 sentences about your educational plans for the next two years.',
          'Will children still need to learn handwriting in the future? 3-4 sentences.',
          'How will language learning change in the next ten years? 3-4 sentences using future tense.'],
    -- 8: Politics Basics
    array['How do you think your country will change in the next 5 years? 3-4 sentences using future tense.',
          'Will young people vote more or less in the future? 3-4 sentences with your view.',
          'Write 3-4 sentences about a political change you would like to see in the next decade.',
          'Will protest movements be more effective in the future? 3-4 sentences using future tense.',
          'Write 3-4 sentences about an upcoming election in any country and what you predict.',
          'How will social media affect politics in the future? 3-4 sentences using future tense.',
          'Will international cooperation increase or decrease? 3-4 sentences using future tense.'],
    -- 9: Food & Cooking
    array['What food trends do you think will be popular next year? 3-4 sentences using future tense.',
          'Will more people cook at home in the future? 3-4 sentences with your view.',
          'Write 3-4 sentences about a recipe you plan to try and what you expect.',
          'Will plant-based diets become the norm? 3-4 sentences using future tense.',
          'Write 3-4 sentences about a healthy habit you will start with food.',
          'How will restaurants change after the pandemic? 3-4 sentences using future tense.',
          'Will lab-grown meat ever be accepted? 3-4 sentences with your view.'],
    -- 10: Art & Literature
    array['Will people still read printed books in 20 years? 3-4 sentences using future tense.',
          'Write 3-4 sentences about an art form you plan to explore in the next year.',
          'How will AI-generated art change traditional artists? 3-4 sentences using future tense.',
          'Will poetry survive in a world of short videos? 3-4 sentences with your view.',
          'Write 3-4 sentences about a museum you plan to visit and why.',
          'Will streaming change the way novelists write? 3-4 sentences using future tense.',
          'How will writers earn money in the future? 3-4 sentences using future tense.'],
    -- 11: Health & Medicine (tier 3, 4 sentences, comparison or argument)
    array['Compare public and private healthcare systems you know. Write 4 sentences.',
          'Argue for or against requiring sports for children at school. 4 sentences.',
          'Compare modern medicine with traditional remedies. 4 sentences.',
          'Should mental health be treated like physical health? Make an argument in 4 sentences.',
          'Compare healthcare in two countries you know. 4 sentences.',
          'Argue for or against alternative therapies (acupuncture, herbal medicine). 4 sentences.',
          'Compare working from home vs the office for health. 4 sentences.'],
    -- 12: Business Basics
    array['Compare working for a big company vs a small one. 4 sentences.',
          'Argue for or against a four-day work week. 4 sentences.',
          'Compare starting your own business vs being employed. 4 sentences.',
          'Should companies prioritise profit or social responsibility? 4 sentences making an argument.',
          'Compare two leadership styles you have seen. 4 sentences.',
          'Argue for or against unpaid internships. 4 sentences.',
          'Compare traditional offices vs remote teams. 4 sentences.'],
    -- 13: Sports & Fitness
    array['Compare team sports vs individual sports. 4 sentences.',
          'Argue for or against the use of technology in refereeing. 4 sentences.',
          'Compare two famous athletes and their impact on their sport. 4 sentences.',
          'Should children specialise early in one sport? 4 sentences making an argument.',
          'Compare gym workouts vs outdoor exercise. 4 sentences.',
          'Argue for or against banning extreme sports. 4 sentences.',
          'Compare professional and amateur leagues you know. 4 sentences.'],
    -- 14: Music & Entertainment
    array['Compare live concerts and recorded music. 4 sentences.',
          'Argue for or against streaming services paying artists more. 4 sentences.',
          'Compare two music genres you enjoy. 4 sentences.',
          'Should awards like the Grammys still matter? Make an argument in 4 sentences.',
          'Compare cinemas with home streaming. 4 sentences.',
          'Argue for or against censorship in music lyrics. 4 sentences.',
          'Compare two films or series you have watched recently. 4 sentences.'],
    -- 15: Science Basics
    array['Compare scientific progress and ethical concerns in 4 sentences.',
          'Argue for or against more public funding for space exploration. 4 sentences.',
          'Compare the role of scientists and politicians in pandemic decisions. 4 sentences.',
          'Should gene editing be allowed in humans? 4 sentences making an argument.',
          'Compare progress in renewable energy across two countries you know. 4 sentences.',
          'Argue for or against banning animal testing for cosmetics. 4 sentences.',
          'Compare science journalism in newspapers vs social media. 4 sentences.']
  ];

  -- 7 speaking topic prompts per section
  speaking_prompts text[][] := array[
    -- 1: Travel & Tourism (tier 1, 4 sentences)
    array['Talk about a trip you would recommend and why. Four sentences.',
          'Describe your opinion on mass tourism. Four sentences.',
          'Talk about how you prefer to travel and why. Four sentences.',
          'Describe an unforgettable hotel or hostel experience. Four sentences.',
          'Talk about whether tourists should learn the local language. Four sentences.',
          'Describe an underrated destination you know. Four sentences.',
          'Talk about a travel mistake you made and what you learned. Four sentences.'],
    -- 2: News & Media
    array['Describe how you get your news and your opinion of those sources. Four sentences.',
          'Talk about a news story that affected you. Four sentences.',
          'Describe your view on fake news. Four sentences.',
          'Talk about journalism in your country today. Four sentences.',
          'Describe how short videos are changing the news. Four sentences.',
          'Talk about a podcast or newsletter you trust and why. Four sentences.',
          'Describe whether you trust traditional or online news more. Four sentences.'],
    -- 3: Environment
    array['Talk about the biggest environmental issue where you live. Four sentences.',
          'Describe a habit you changed for the environment. Four sentences.',
          'Talk about whether governments or individuals must lead. Four sentences.',
          'Describe your view on electric cars. Four sentences.',
          'Talk about plastic waste in your daily life. Four sentences.',
          'Describe how recycling works (or fails) in your city. Four sentences.',
          'Talk about a project that gives you hope for the planet. Four sentences.'],
    -- 4: Relationships
    array['Describe what makes a good friend for you. Four sentences.',
          'Talk about a long-distance friendship you maintain. Four sentences.',
          'Describe how dating has changed in your generation. Four sentences.',
          'Talk about your view on living with someone before marriage. Four sentences.',
          'Describe how family roles have changed since your grandparents. Four sentences.',
          'Talk about a friend who has influenced you and how. Four sentences.',
          'Describe your opinion on group chats and family communication. Four sentences.'],
    -- 5: Culture & Traditions
    array['Describe a tradition from your country and what it means. Four sentences.',
          'Talk about a foreign tradition you admire. Four sentences.',
          'Describe whether old traditions are still useful. Four sentences.',
          'Talk about a festival you attended recently. Four sentences.',
          'Describe how globalisation affects local cultures. Four sentences.',
          'Talk about a tradition you would like to start in your family. Four sentences.',
          'Describe a wedding or birthday tradition in your country. Four sentences.'],
    -- 6: Money & Banking (tier 2, 4-5 sentences with future / conditional)
    array['Talk about how you will save money next year. 4-5 sentences using future tense.',
          'Describe what you would do if you suddenly had a lot of money. 4-5 sentences.',
          'Talk about whether cash will disappear. 4-5 sentences using future tense.',
          'Describe your plans for retirement. 4-5 sentences using future or conditional.',
          'Talk about a financial mistake you would never make again. 4-5 sentences.',
          'Describe how banking apps have changed your life. 4-5 sentences.',
          'Talk about whether you would invest in cryptocurrencies and why. 4-5 sentences.'],
    -- 7: Education
    array['Talk about what you will study or learn this year. 4-5 sentences using future tense.',
          'Describe how schools should change in your country. 4-5 sentences.',
          'Talk about online vs in-person learning. 4-5 sentences.',
          'Describe a course you would take if you had unlimited time. 4-5 sentences using conditional.',
          'Talk about a teacher who changed how you see the world. 4-5 sentences.',
          'Describe how AI will affect your studies or job. 4-5 sentences using future tense.',
          'Talk about what skills children should learn first. 4-5 sentences.'],
    -- 8: Politics Basics
    array['Talk about what you would change first in your country. 4-5 sentences using conditional.',
          'Describe how political news affects you. 4-5 sentences.',
          'Talk about whether you will vote in the next election. 4-5 sentences using future tense.',
          'Describe a politician you respect and why. 4-5 sentences.',
          'Talk about how social media is changing politics. 4-5 sentences.',
          'Describe what international cooperation should look like. 4-5 sentences.',
          'Talk about a protest or movement you find important. 4-5 sentences.'],
    -- 9: Food & Cooking
    array['Talk about a recipe you will try this month. 4-5 sentences using future tense.',
          'Describe how cooking habits will change in the future. 4-5 sentences using future tense.',
          'Talk about your view on vegetarian or vegan diets. 4-5 sentences.',
          'Describe a dish you would cook for someone special. 4-5 sentences using conditional.',
          'Talk about food waste in your home and how to reduce it. 4-5 sentences.',
          'Describe a food trend you find interesting. 4-5 sentences.',
          'Talk about a market or food shop you love and why. 4-5 sentences.'],
    -- 10: Art & Literature
    array['Talk about an author or artist you would like to meet. 4-5 sentences using conditional.',
          'Describe a book you plan to read this year. 4-5 sentences using future tense.',
          'Talk about AI-generated art and your opinion on it. 4-5 sentences.',
          'Describe an exhibition or play you would recommend. 4-5 sentences.',
          'Talk about how reading changes the way you think. 4-5 sentences.',
          'Describe a painting or photograph that affected you. 4-5 sentences.',
          'Talk about whether children should be encouraged to read more. 4-5 sentences.'],
    -- 11: Health & Medicine (tier 3, 5-6 sentences)
    array['Compare public and private healthcare from your experience. 5-6 sentences.',
          'Argue for or against sports being compulsory in schools. 5-6 sentences.',
          'Talk about how the pandemic changed how we see health. 5-6 sentences.',
          'Compare traditional remedies and modern medicine. 5-6 sentences.',
          'Argue for or against treating mental health like physical health. 5-6 sentences.',
          'Compare healthcare in two countries you know. 5-6 sentences.',
          'Talk about whether health apps actually help people stay healthier. 5-6 sentences.'],
    -- 12: Business Basics
    array['Compare working for a big company and a small one. 5-6 sentences.',
          'Argue for or against the four-day work week. 5-6 sentences.',
          'Compare two leadership styles you have experienced. 5-6 sentences.',
          'Talk about your dream business and how you would run it. 5-6 sentences.',
          'Argue for or against unpaid internships in your field. 5-6 sentences.',
          'Compare remote teams with office teams. 5-6 sentences.',
          'Talk about how customer service has changed in your country. 5-6 sentences.'],
    -- 13: Sports & Fitness
    array['Compare team sports and individual sports for personal growth. 5-6 sentences.',
          'Argue for or against using technology in refereeing. 5-6 sentences.',
          'Compare two famous athletes and their impact. 5-6 sentences.',
          'Talk about your ideal fitness routine and the reasoning behind it. 5-6 sentences.',
          'Argue for or against banning extreme sports. 5-6 sentences.',
          'Compare professional and amateur leagues you follow. 5-6 sentences.',
          'Talk about how sports unite or divide communities. 5-6 sentences.'],
    -- 14: Music & Entertainment
    array['Compare live concerts and streaming music. 5-6 sentences.',
          'Argue for or against streaming platforms paying artists more. 5-6 sentences.',
          'Compare two music genres you enjoy. 5-6 sentences.',
          'Talk about a film or series that influenced your thinking. 5-6 sentences.',
          'Argue for or against censorship in music lyrics. 5-6 sentences.',
          'Compare cinema and home streaming. 5-6 sentences.',
          'Talk about how festivals shape music culture today. 5-6 sentences.'],
    -- 15: Science Basics
    array['Compare scientific progress and ethical concerns. 5-6 sentences.',
          'Argue for or against more funding for space exploration. 5-6 sentences.',
          'Compare how scientists and politicians communicate during a crisis. 5-6 sentences.',
          'Talk about whether gene editing should be allowed in humans. 5-6 sentences.',
          'Argue for or against animal testing in cosmetics. 5-6 sentences.',
          'Compare two countries on renewable energy progress. 5-6 sentences.',
          'Talk about how science news should be presented to the public. 5-6 sentences.']
  ];

  -- Spanish audio (compound sentences / mini-dialogues), user types 2-3
  -- sentence Spanish reply demonstrating comprehension of nuance.
  listening_audio text[][] := array[
    -- 1: Travel & Tourism
    array['Aunque me encanta viajar, este verano he decidido quedarme en casa porque necesito ahorrar. ¿Qué opinas de hacer turismo en tu propio país?',
          'Mi amigo Pablo dice que el turismo masivo está arruinando algunas ciudades europeas. ¿Estás de acuerdo y por qué?',
          'La última vez que viajé al extranjero perdí la maleta y tuve que comprar ropa allí. ¿Te ha pasado algo parecido alguna vez?',
          'Algunas personas prefieren los viajes organizados y otras prefieren improvisar. ¿Qué tipo de viajero eres tú y por qué?',
          'Cada vez más jóvenes hacen turismo de mochilero por meses enteros. ¿Te parece una buena idea o una pérdida de tiempo?',
          'Los hoteles boutique son más caros pero ofrecen una experiencia personal. ¿Crees que vale la pena pagar más?',
          'En muchos destinos los turistas ya superan en número a los habitantes. ¿Qué soluciones propondrías?'],
    -- 2: News & Media
    array['Mi padre todavía compra el periódico cada mañana mientras yo solo leo noticias en el móvil. ¿Qué prefieres tú y por qué?',
          'Ayer vi un titular muy sensacionalista que después resultó ser falso. ¿Cómo distingues una noticia fiable de una falsa?',
          'Los podcasts informativos están creciendo mucho. ¿Escuchas alguno y qué te parecen comparados con la radio?',
          'Mi prima trabaja como periodista y dice que las redes han cambiado totalmente su trabajo. ¿Cómo crees que ha cambiado?',
          'Cada vez más noticias se consumen en vídeos de un minuto. ¿Crees que esto ayuda o perjudica al periodismo?',
          'En tu país, ¿la gente confía en los medios públicos o privados? ¿Por qué?',
          'Algunos canales muestran solo malas noticias. ¿Crees que eso afecta nuestra forma de ver el mundo?'],
    -- 3: Environment
    array['Mi familia ha empezado a reciclar mucho más este año, aunque al principio nos costó. ¿Cómo se recicla en tu casa?',
          'Algunos científicos dicen que aún podemos evitar lo peor del cambio climático si actuamos ya. ¿Eres optimista o pesimista al respecto?',
          'La ciudad donde vivo va a prohibir los coches diésel en el centro. ¿Qué te parece esa medida?',
          'Mucha gente piensa que las soluciones individuales no cambian nada y solo los gobiernos pueden hacer algo. ¿Compartes esa opinión?',
          'Las marcas de ropa están empezando a usar materiales reciclados. ¿Te fijas en esto cuando compras ropa?',
          'En algunos países cobran por las bolsas de plástico en el supermercado. ¿Crees que es una medida eficaz?',
          'Los coches eléctricos son más limpios, pero las baterías generan otro problema. ¿Cuál crees que es la solución?'],
    -- 4: Relationships
    array['Mi mejor amiga se mudó al extranjero hace un año y mantenemos el contacto sobre todo por videollamada. ¿Crees que las amistades a distancia pueden ser fuertes?',
          'Hoy en día mucha gente conoce a su pareja por aplicaciones. ¿Qué opinas de las relaciones que empiezan así?',
          'En mi familia hacemos una comida grande cada domingo y eso nos une mucho. ¿Tu familia tiene alguna costumbre así?',
          'Algunos padres son muy estrictos con las redes sociales de sus hijos. ¿Cómo crees que deberían gestionarlo?',
          'Mi compañero de piso y yo discutimos a veces por las tareas. ¿Cómo sueles resolver tus desacuerdos con la gente?',
          'Cada vez más parejas deciden no casarse. ¿Crees que el matrimonio sigue siendo importante?',
          'Una buena amiga me ayudó mucho cuando perdí mi trabajo. ¿Qué hace que una persona sea un buen amigo?'],
    -- 5: Culture & Traditions
    array['En mi familia celebramos un día especial que viene de mis abuelos. ¿Tienes alguna tradición familiar interesante?',
          'En los últimos años, muchas fiestas tradicionales se han modernizado. ¿Crees que eso las mejora o las arruina?',
          'Cuando viajé a otro país, una costumbre me sorprendió mucho. ¿Te ha pasado algo similar en algún viaje?',
          'Algunos países tienen festivales muy ruidosos y largos. ¿Te gustan ese tipo de celebraciones?',
          'La cocina tradicional de mi región está perdiendo popularidad entre los jóvenes. ¿Qué se podría hacer para conservarla?',
          'Los matrimonios entre culturas son cada vez más comunes. ¿Crees que enriquecen o complican la vida familiar?',
          'Cada generación crea sus propias tradiciones. ¿Qué tradición nueva ves entre los jóvenes de tu país?'],
    -- 6: Money & Banking
    array['Mi banco va a cerrar la sucursal de mi barrio el año que viene. ¿Cómo crees que afectará a los mayores que no usan internet?',
          'Cada vez más tiendas no aceptan dinero en efectivo. ¿Te parece bien esta tendencia?',
          'Estoy ahorrando para comprar mi primera casa pero los precios siguen subiendo. ¿Qué consejo me darías?',
          'Mucha gente joven invierte en criptomonedas sin entender bien los riesgos. ¿Qué opinas sobre esto?',
          'Los bancos cobran cada vez más comisiones. ¿Crees que las cuentas online sin comisiones son una solución?',
          'Mi sobrino acaba de pedir un préstamo para estudiar fuera. ¿Te parece bien empezar tu vida adulta con deudas?',
          'Algunas personas usan aplicaciones para controlar cada gasto. ¿Crees que vale la pena hacerlo?'],
    -- 7: Education
    array['Mi hija dice que sus profesores ya usan inteligencia artificial para preparar las clases. ¿Te parece bien o te preocupa?',
          'Algunas universidades ofrecen ahora títulos cien por cien online. ¿Crees que tendrán el mismo valor que los presenciales?',
          'En mi país los estudiantes tienen demasiados exámenes. ¿Cómo es en el tuyo?',
          'Cada vez más adultos vuelven a estudiar después de los cuarenta. ¿Lo harías tú? ¿En qué?',
          'Muchos padres pagan clases privadas además del colegio. ¿Crees que es necesario?',
          'Algunos países dan ordenadores a todos los niños del colegio. ¿Te parece una buena inversión?',
          'Una amiga profesora dice que los alumnos cada vez leen menos libros completos. ¿A qué crees que se debe?'],
    -- 8: Politics Basics
    array['En las próximas elecciones, mucha gente joven dice que no piensa votar. ¿Qué opinas tú?',
          'Las redes sociales están cambiando la política rápidamente. ¿Crees que para mejor o para peor?',
          'Mi primo participó en una manifestación el sábado pasado. ¿Has participado tú alguna vez en una protesta?',
          'Algunos países exigen que los políticos publiquen sus ingresos. ¿Te parece una buena idea?',
          'El debate político está cada vez más polarizado. ¿Cómo crees que se podría arreglar esto?',
          'Los líderes deberían comunicar mejor sus decisiones. ¿Qué falta hoy en la comunicación política?',
          'En tu país, ¿la gente confía en sus instituciones? ¿Por qué?'],
    -- 9: Food & Cooking
    array['Últimamente he reducido la carne en mi dieta porque me preocupa el medio ambiente. ¿Has cambiado tus hábitos alimentarios?',
          'Mi abuela cocinaba todos los platos desde cero, pero hoy poca gente lo hace. ¿Crees que estamos perdiendo esa costumbre?',
          'Pedir comida a domicilio es muy cómodo pero también muy caro. ¿Lo haces a menudo?',
          'En los supermercados aparecen muchos productos veganos nuevos. ¿Crees que esta tendencia se mantendrá?',
          'Una amiga mía ha empezado a cultivar verduras en su balcón. ¿Lo harías tú?',
          'Cada vez se desperdicia más comida en los hogares. ¿Cómo se podría reducir?',
          'Algunos restaurantes ofrecen menús sin desperdicio. ¿Te parece una buena idea?'],
    -- 10: Art & Literature
    array['Una aplicación nueva genera poemas con inteligencia artificial en segundos. ¿Crees que eso es realmente arte?',
          'Mi padre me regaló una novela que tardé tres meses en terminar pero me marcó mucho. ¿Hay algún libro así para ti?',
          'Muchos museos están digitalizando sus colecciones para que cualquiera las vea online. ¿Crees que eso reemplaza la visita real?',
          'Una exposición en mi ciudad mezcla pintura clásica con realidad virtual. ¿Te llamaría la atención algo así?',
          'Cada vez más jóvenes leen libros en el móvil. ¿Crees que tiene la misma experiencia que un libro de papel?',
          'Algunos autores famosos publican primero por entregas en internet. ¿Te parece una buena estrategia?',
          'El teatro independiente cada vez tiene menos público. ¿Cómo se podría apoyar?'],
    -- 11: Health & Medicine
    array['Después de la pandemia, mucha gente prioriza más la salud mental. ¿Crees que eso es un cambio duradero o pasajero?',
          'En mi país hay que esperar mucho para una cita médica pública. ¿Cómo funciona en el tuyo?',
          'Una vecina mía usa una pulsera que le mide la salud cada minuto. ¿Crees que esto cambia realmente la vida de la gente?',
          'Algunos países permiten comprar antibióticos sin receta. ¿Qué opinas de esa política?',
          'Una amiga prefiere la medicina tradicional china a la convencional. ¿Tienes alguna experiencia con tratamientos alternativos?',
          'En los hospitales públicos faltan recursos pero los profesionales son excelentes. ¿Cómo crees que se debería mejorar el sistema?',
          'Mi compañera de trabajo dice que el ejercicio le ha cambiado la vida más que cualquier medicina. ¿Qué piensas de esto?'],
    -- 12: Business Basics
    array['Mi empresa acaba de implantar la semana de cuatro días y todo el mundo está más motivado. ¿Crees que funcionaría en cualquier sector?',
          'Una startup tecnológica de mi ciudad ha quebrado en menos de un año. ¿Por qué crees que fracasan tantas startups?',
          'Mi jefa pidió que volviéramos a la oficina cuatro días por semana. ¿Cómo te sentirías si te lo pidieran a ti?',
          'Algunas empresas comparten sus beneficios con todos los empleados. ¿Crees que es justo o crea problemas?',
          'Muchos jóvenes prefieren ser autónomos antes que trabajar para alguien. ¿Por qué crees que ocurre eso?',
          'Una marca grande está acusada de no pagar bien a sus trabajadores en otros países. ¿Hasta qué punto te influye eso al comprar?',
          'Las reuniones de trabajo cada vez son más largas y menos productivas. ¿Cómo se podrían mejorar?'],
    -- 13: Sports & Fitness
    array['El VAR está cambiando el fútbol y a muchos aficionados no les gusta. ¿Qué opinas tú de esa tecnología?',
          'Una vecina mía corre maratones a los sesenta años. ¿Hasta qué edad crees que se pueden hacer deportes intensos?',
          'Cada vez más jóvenes hacen deportes en grupo solo por las redes sociales. ¿Crees que cambia el significado del deporte?',
          'Mi hijo quiere especializarse en un solo deporte desde los ocho años. ¿Es buena idea o demasiado pronto?',
          'Los grandes campeonatos generan mucho dinero pero también mucha controversia. ¿Crees que vale la pena organizarlos?',
          'Una amiga prefiere hacer ejercicio en casa con vídeos online. ¿Te parece tan efectivo como el gimnasio?',
          'En los Juegos Olímpicos cada vez aparecen deportes nuevos. ¿Qué deporte añadirías tú?'],
    -- 14: Music & Entertainment
    array['Muchos músicos famosos ya no ganan dinero con discos, solo con conciertos. ¿Cómo crees que afecta a la calidad de la música?',
          'Un amigo solo escucha música en streaming y ya no compra discos. ¿Crees que el formato físico desaparecerá?',
          'Hay series que se ven en pocos días y se olvidan rápido. ¿Crees que esto pasa con la música también?',
          'Algunas plataformas crean listas de reproducción con inteligencia artificial. ¿Te fías de sus recomendaciones?',
          'Mucha gente ya no va al cine porque tiene todo en casa. ¿Crees que los cines van a sobrevivir?',
          'Una cantante muy joven se ha hecho famosa de un día para otro en TikTok. ¿Crees que ese éxito puede durar?',
          'Los festivales de música cada vez son más caros pero siguen llenándose. ¿Por qué crees que ocurre eso?'],
    -- 15: Science Basics
    array['Los científicos avisan de una nueva pandemia y muchos políticos no les escuchan. ¿Por qué crees que ocurre esto?',
          'Una empresa privada ha lanzado un cohete al espacio sin ayuda pública. ¿Te parece bien que el espacio se privatice?',
          'Algunos avances en genética podrían curar enfermedades hereditarias. ¿Te parece bien modificar genes humanos?',
          'Una vecina mía no cree en muchos descubrimientos científicos recientes. ¿Cómo se podría mejorar la comunicación de la ciencia?',
          'En las redes sociales circula mucha información científica falsa. ¿Cómo distingues lo que es fiable?',
          'Los científicos jóvenes tienen contratos precarios y muchos emigran. ¿Cómo se podría retener el talento?',
          'Algunos países invierten muy poco en investigación. ¿Cómo afecta eso a su futuro?']
  ];

  -- Reference Spanish responses given to the AI grader as context
  listening_reference text[][] := array[
    -- 1
    array['A mí me parece bien explorar tu propio país; yo descubrí mucho cuando hice una ruta por el norte.',
          'Estoy bastante de acuerdo: en mi ciudad los precios han subido por el turismo y muchos vecinos se han marchado.',
          'Sí, una vez me robaron el pasaporte y aprendí a llevar siempre copias y dinero separado.',
          'Yo prefiero improvisar porque me gustan las sorpresas, aunque a veces sale un poco más caro.',
          'Creo que viajar como mochilero te enseña mucho, sobre todo cuando eres joven y tienes tiempo.',
          'Solo si el hotel ofrece algo realmente distinto; si no, prefiero gastar en experiencias locales.',
          'Limitar el número de visitantes y subir los impuestos turísticos en temporada alta podría ayudar.'],
    -- 2
    array['Yo leo casi todo en el móvil, pero los domingos compro el periódico en papel; es más relajado.',
          'Comparo siempre la noticia en dos o tres medios distintos y miro quién la firma.',
          'Sí, escucho podcasts mientras voy al trabajo; aprendo más que con las noticias clásicas.',
          'Creo que ahora un periodista debe pensar como editor y como influencer al mismo tiempo.',
          'Los vídeos cortos enganchan, pero a veces simplifican demasiado los temas complejos.',
          'En mi país la gente confía más en los medios privados, aunque depende mucho de la edad.',
          'Sí, el sesgo negativo nos hace pensar que todo va mal cuando no siempre es así.'],
    -- 3
    array['Reciclamos vidrio, plástico y orgánico, pero a veces dudo si estoy separando bien los envases.',
          'Soy más bien optimista: hay mucha gente joven implicada y la tecnología avanza rápido.',
          'Me parece bien, aunque deberían mejorar el transporte público a la vez para que sea realista.',
          'Pienso que los dos deben actuar juntos; los gobiernos marcan reglas y los ciudadanos las hacemos viables.',
          'Sí, me fijo cada vez más, aunque a veces es difícil saber si la marca dice la verdad.',
          'Funciona en parte: muchos llevamos bolsa propia, pero todavía hay demasiado plástico en otros productos.',
          'Necesitamos un buen plan para reciclar las baterías y diversificar las fuentes de energía.'],
    -- 4
    array['Sí, mantenemos largas videollamadas cada semana y, aunque no es lo mismo, la amistad se mantiene fuerte.',
          'Conozco varias parejas que empezaron así y funcionan bien, pero también hay que filtrar mucho al principio.',
          'En mi casa intentamos cenar juntos al menos tres veces por semana; es nuestro momento clave.',
          'Hablar mucho con los hijos y poner límites razonables es más efectivo que prohibir todo.',
          'Suelo intentar hablarlo con calma; si me enfado en el momento, mejor lo dejo para más tarde.',
          'Sí, sigue siendo importante para muchos, aunque cada vez convivir antes es más normal.',
          'Para mí un buen amigo es alguien que escucha sin juzgar y aparece cuando peor lo estás pasando.'],
    -- 5
    array['Sí, cada Navidad cocinamos juntos una receta que viene de mi abuela; nos une cada año.',
          'Depende: si moderniza con respeto está bien, pero si se pierde el sentido original, no merece la pena.',
          'En Japón me sorprendió mucho el silencio en el transporte público, fue una lección de respeto.',
          'No me gusta el ruido excesivo, pero entiendo que para mucha gente es parte de la magia.',
          'Sería buena idea enseñar las recetas en las escuelas y publicarlas online para los jóvenes.',
          'Yo creo que enriquecen, aunque al principio cuesta entender las diferencias culturales.',
          'Los jóvenes celebran fechas como Halloween que antes no se celebraban; las tradiciones cambian con el tiempo.'],
    -- 6
    array['Para los mayores será un problema serio; deberían mantener al menos cajeros con personal.',
          'Me parece mal porque excluye a personas mayores y a quienes no tienen acceso digital.',
          'Te diría que sigas ahorrando poco a poco y mires zonas un poco más alejadas del centro.',
          'Yo no invertiría sin entender bien el riesgo; algunas personas pierden todo en poco tiempo.',
          'Sí, las cuentas online sin comisiones son una buena alternativa para muchos.',
          'A veces no queda otra, pero conviene calcular bien cuánto se podrá devolver cada mes.',
          'A mí me ayudó mucho usar una aplicación así durante seis meses; aprendí a priorizar gastos.'],
    -- 7
    array['Me parece bien si se usa para ayudar al profesor, pero no para sustituir su criterio.',
          'Podrán tener el mismo valor si la universidad es seria y los exámenes están bien controlados.',
          'Aquí también tenemos muchos exámenes, especialmente en bachillerato; me parece excesivo.',
          'Sí, me gustaría estudiar fotografía o algo creativo para equilibrar mi trabajo actual.',
          'No siempre es necesario; mejor invertir tiempo de calidad con los hijos en casa.',
          'Sí, siempre que se enseñe a usarlos con responsabilidad y no solo para jugar.',
          'Los móviles, las redes sociales y la falta de tiempo para leer son factores importantes.'],
    -- 8
    array['Es una pena, porque si los jóvenes no votan, las políticas no piensan en ellos.',
          'Creo que para peor en general; el debate se ha vuelto demasiado superficial.',
          'Sí, una vez me manifesté por el cambio climático y fue una experiencia muy potente.',
          'Sería una medida muy positiva; aumentaría la confianza en las instituciones.',
          'Necesitamos enseñar pensamiento crítico desde la escuela para reducir la polarización.',
          'Falta empatía y transparencia; muchos políticos hablan sin pensar en quién les escucha.',
          'En mi país la confianza ha bajado mucho porque hubo varios escándalos recientes.'],
    -- 9
    array['Sí, ahora como menos carne y más verduras; me siento con más energía y más responsable.',
          'Sí, estamos perdiendo esa costumbre, sobre todo entre semana, por la falta de tiempo.',
          'No mucho, intento cocinar más en casa porque al final pedir cada día sale muy caro.',
          'Creo que se mantendrá, pero algunos productos demasiado procesados no son tan sanos como parecen.',
          'Sí, me gustaría intentarlo para tener tomates y hierbas frescas para cocinar.',
          'Podríamos planificar mejor las compras y aprovechar las sobras para nuevas recetas.',
          'Me parece excelente; reducir desperdicio debería ser una prioridad en toda la hostelería.'],
    -- 10
    array['Para mí no es lo mismo; la IA puede imitar la forma pero le falta la intención humana.',
          'Sí, "Cien años de soledad" me cambió la forma de ver la familia y el tiempo.',
          'Ayuda mucho para personas que no pueden viajar, pero la visita real tiene otra magia.',
          'Me llamaría mucho la atención; mezclar lo clásico y lo nuevo puede atraer a más gente.',
          'En el móvil leo bien artículos cortos, pero para una novela larga sigo prefiriendo el papel.',
          'Sí, así crean comunidad y reciben opiniones antes de publicar el libro completo.',
          'Reducir el precio de las entradas y promover obras en escuelas e institutos podría ayudar.'],
    -- 11
    array['Creo que es un cambio duradero; ahora hablar de terapia es mucho menos tabú que antes.',
          'En mi país también esperamos mucho, especialmente para especialistas; faltan recursos.',
          'Puede ayudar a detectar problemas a tiempo, pero también genera demasiada ansiedad por los datos.',
          'No me parece bien; el uso indebido de antibióticos crea resistencias muy peligrosas.',
          'Yo probé la acupuntura para el dolor de espalda y, sorprendentemente, me ayudó bastante.',
          'Habría que aumentar el presupuesto y mejorar las condiciones de los profesionales sanitarios.',
          'Estoy muy de acuerdo: ejercicio, descanso y dieta hacen más por la salud que muchos medicamentos.'],
    -- 12
    array['Creo que puede funcionar en muchos sectores si las empresas planifican bien las tareas.',
          'Suele faltar un plan financiero realista y a veces confunden hipótesis con demanda real.',
          'Yo intentaría negociar dos días en casa porque me concentro mucho mejor sin interrupciones.',
          'Es justo si se hace con criterios claros; aumenta el compromiso del equipo.',
          'Creo que buscan más libertad y la posibilidad de elegir cómo organizar su tiempo.',
          'Me influye bastante; intento elegir marcas que tratan bien a sus trabajadores.',
          'Podríamos limitar las reuniones a treinta minutos y enviar resúmenes por escrito al final.'],
    -- 13
    array['A mí me parece bien si se usa con moderación; lo importante es no romper el ritmo del partido.',
          'Yo creo que casi sin límite, mientras se haga con preparación y revisiones médicas regulares.',
          'Hay un poco de las dos cosas; lo positivo es que motiva a más gente a moverse.',
          'Me parece demasiado pronto; los niños necesitan probar varios deportes para desarrollarse mejor.',
          'Tienen impacto cultural pero a menudo dejan deudas a las ciudades; habría que organizarlos mejor.',
          'Para algunas personas funciona perfectamente; lo importante es ser constante.',
          'Yo añadiría el ajedrez, porque trabaja la mente y une a personas muy distintas.'],
    -- 14
    array['Si los conciertos pagan más, los artistas hacen mejores espectáculos pero las entradas suben.',
          'No del todo, pero los discos físicos se convertirán en objetos de coleccionista.',
          'Sí, vivimos en una cultura de novedad continua y poco se queda en la memoria colectiva.',
          'A veces acierta y otras no; suele ofrecerme cosas demasiado parecidas a lo que ya escucho.',
          'Creo que sobrevivirán los cines con buena oferta y experiencia, no los grandes y vacíos.',
          'Si solo depende de una red social, no; necesita evolucionar su sonido para durar.',
          'La gente busca experiencias compartidas en directo, sobre todo después de la pandemia.'],
    -- 15
    array['Falta confianza y comunicación; los políticos deberían escuchar más a los expertos.',
          'Me parece bien si está regulado, pero no si el espacio se convierte en negocio sin reglas claras.',
          'Para curar enfermedades graves, sí; para mejorar cualidades estéticas, claramente no.',
          'Habría que hablar más en lenguaje sencillo y dar acceso a fuentes fiables.',
          'Comparo con artículos académicos cuando puedo y busco fuentes serias, no influencers.',
          'Necesitamos mejorar contratos y financiación pública para retener a los investigadores.',
          'Si no se invierte, se pierden talentos y se depende de descubrimientos extranjeros.']
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
      and cefr_level = 'B1'
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

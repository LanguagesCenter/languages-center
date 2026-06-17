-- 042_spanish_b2_ai_graded_exercises.sql
-- Same shape as 039/040/041 but for every Spanish B2 lesson (15 sections
-- × 7 teaching lessons). Each lesson's listening / speaking / writing rows
-- are deleted and reseeded in the AI-graded format LessonClient already
-- supports — writing prompt + topic-mode speaking + typed-response
-- listening with empty wrong_answers.
--
-- B2 difficulty bumps vs B1:
--   Writing tier 1 (sections 1-5):  4 sentences with a clear argument
--   Writing tier 2 (sections 6-10): 4-5 sentences acknowledging a counterargument
--   Writing tier 3 (sections 11-15): 5 sentences with subjunctive required
--   Speaking tier 1: 5 sentences | tier 2: 5-6 | tier 3: 6-7
--     (must use connectors such as no obstante / por consiguiente /
--      cabe destacar / sin embargo, and subjunctive where appropriate)
--   Listening audio is a short monologue or debate excerpt;
--   candidate types 3-4 sentences analysing the speaker's attitude and
--   implied meaning, not just summarising.
--
-- Schema constraint already accepts 'writing' from 039.
-- Idempotent.

do $$
declare
  v_lang_id   bigint;
  v_course_id bigint;
  v_lesson_id bigint;

  -- B2 sections, canonical order from 015_spanish_restructure_15x8.sql
  section_names text[] := array[
    'Politics & Society','Technology & Innovation','Philosophy & Ethics','Literature & Poetry',
    'Business & Economics','Science & Research','Arts & Culture','Media & Journalism',
    'Law & Justice','History','Psychology','Architecture','Fashion & Design',
    'Sports Analysis','Environmental Issues'
  ];

  -- 7 writing prompts per section [section_idx][lesson_idx 1..7]
  writing_prompts text[][] := array[
    -- 1: Politics & Society (tier 1, 4 sentences with a clear argument)
    array['Argue for or against the obligation to vote. Write 4 sentences making a clear argument.',
          'Make an argument about whether democracy is in crisis today. 4 sentences.',
          'Defend a position on whether political parties still represent voters. 4 sentences.',
          'Argue for or against lowering the voting age to 16. 4 sentences.',
          'Take a clear position on the role of NGOs in modern democracies. 4 sentences.',
          'Defend or attack the use of referendums to decide complex issues. 4 sentences.',
          'Argue whether civic education should be a school priority. 4 sentences with a clear stance.'],
    -- 2: Technology & Innovation
    array['Argue for or against algorithmic recommendation systems. 4 sentences with a clear stance.',
          'Make an argument about whether AI will replace creative professions. 4 sentences.',
          'Defend a position on facial recognition in public spaces. 4 sentences.',
          'Argue for or against a tax on robots that replace workers. 4 sentences.',
          'Take a clear position on whether smartphones make us less productive. 4 sentences.',
          'Argue whether innovation should always be regulated by governments. 4 sentences.',
          'Defend or attack the idea that tech companies should be broken up. 4 sentences.'],
    -- 3: Philosophy & Ethics
    array['Argue whether lying is sometimes justified. 4 sentences with a clear stance.',
          'Make an argument on whether free will really exists. 4 sentences.',
          'Defend or attack the idea that money buys happiness. 4 sentences.',
          'Argue for or against capital punishment from an ethical standpoint. 4 sentences.',
          'Take a clear position on whether we have moral duties towards animals. 4 sentences.',
          'Argue whether tradition or progress should guide our decisions. 4 sentences.',
          'Defend or attack the view that all opinions deserve equal respect. 4 sentences.'],
    -- 4: Literature & Poetry
    array['Argue whether literature can still change the world. 4 sentences with a clear stance.',
          'Make an argument about whether poetry is dying. 4 sentences.',
          'Defend a position on translating classic works for modern readers. 4 sentences.',
          'Argue for or against teaching only national authors in schools. 4 sentences.',
          'Take a clear position on whether genre fiction is real literature. 4 sentences.',
          'Argue whether authors must take political positions. 4 sentences.',
          'Defend or attack the rise of audiobooks compared to reading. 4 sentences.'],
    -- 5: Business & Economics
    array['Argue for or against universal basic income. 4 sentences with a clear stance.',
          'Make an argument about whether shareholders or employees should come first. 4 sentences.',
          'Defend a position on raising the minimum wage in your country. 4 sentences.',
          'Argue for or against high taxation on luxury goods. 4 sentences.',
          'Take a clear position on whether globalisation has hurt small businesses. 4 sentences.',
          'Argue whether economic growth should be limited for climate reasons. 4 sentences.',
          'Defend or attack the gig economy as a model for the future. 4 sentences.'],
    -- 6: Science & Research (tier 2, 4-5 sentences acknowledging a counterargument)
    array['Discuss public funding for space exploration; acknowledge a counterargument. 4-5 sentences.',
          'Debate gene editing in humans presenting both sides. 4-5 sentences.',
          'Discuss whether scientific journals should be free to read. Acknowledge a counter view. 4-5 sentences.',
          'Argue for or against animal testing, recognising the opposing position. 4-5 sentences.',
          'Discuss whether scientists should also be activists. Address a counterargument. 4-5 sentences.',
          'Debate the dependence of research on private companies. Both sides. 4-5 sentences.',
          'Discuss the value of basic vs applied research, acknowledging both views. 4-5 sentences.'],
    -- 7: Arts & Culture
    array['Discuss public funding of the arts; acknowledge a counterargument. 4-5 sentences.',
          'Debate whether museums should return colonial artefacts. Both sides. 4-5 sentences.',
          'Discuss the role of cultural festivals in the economy. Counter view too. 4-5 sentences.',
          'Argue for or against subsidised theatre tickets. Acknowledge a counterargument. 4-5 sentences.',
          'Discuss the impact of streaming on cinemas, both sides. 4-5 sentences.',
          'Debate whether modern art is overrated. Address a counter view. 4-5 sentences.',
          'Discuss whether children should learn an instrument at school. Counter view too. 4-5 sentences.'],
    -- 8: Media & Journalism
    array['Discuss press freedom in your country; acknowledge a counterargument. 4-5 sentences.',
          'Debate the responsibility of social platforms for misinformation. Both sides. 4-5 sentences.',
          'Discuss whether anonymous sources are essential to journalism. Counter view too. 4-5 sentences.',
          'Argue for or against paywalls on quality news; recognise the opposing view. 4-5 sentences.',
          'Discuss the effect of "infotainment" on real news. Both sides. 4-5 sentences.',
          'Debate whether journalists should reveal their personal opinions. 4-5 sentences both sides.',
          'Discuss the role of citizen journalism today. Acknowledge a counterargument. 4-5 sentences.'],
    -- 9: Law & Justice
    array['Discuss restorative vs punitive justice. Acknowledge a counterargument. 4-5 sentences.',
          'Debate the right to be forgotten on the internet. Both sides. 4-5 sentences.',
          'Discuss whether juries should be replaced by professional judges. Counter view too. 4-5 sentences.',
          'Argue for or against drug decriminalisation, recognising the opposing view. 4-5 sentences.',
          'Discuss the prison system in your country. Acknowledge a counter view. 4-5 sentences.',
          'Debate whether minor crimes deserve fines instead of prison. Both sides. 4-5 sentences.',
          'Discuss the use of expert witnesses in trials. Counter view too. 4-5 sentences.'],
    -- 10: History
    array['Discuss whether history is rewritten by the winners. Counter view too. 4-5 sentences.',
          'Debate the removal of controversial statues. Both sides. 4-5 sentences.',
          'Discuss the importance of teaching colonial history. Acknowledge a counterargument. 4-5 sentences.',
          'Argue for or against using history to make political points. Both sides. 4-5 sentences.',
          'Discuss whether historical novels are accurate. Counter view too. 4-5 sentences.',
          'Debate the role of museums in preserving difficult history. Both sides. 4-5 sentences.',
          'Discuss whether we learn from history. Acknowledge a counterargument. 4-5 sentences.'],
    -- 11: Psychology (tier 3, 5 sentences with subjunctive required)
    array['Write 5 sentences about what society would be like if mental health were prioritised, using subjunctive.',
          'Discuss what schools should do so that children develop emotional intelligence. 5 sentences with subjunctive.',
          'Argue what we would change if we recognised stress as a serious illness. 5 sentences with subjunctive.',
          'Write 5 sentences on whether psychology should be taught from primary school. Use subjunctive.',
          'Discuss what would happen if every workplace had a mental health policy. 5 sentences with subjunctive.',
          'Argue what governments should do to reduce loneliness. 5 sentences with subjunctive.',
          'Write 5 sentences on what we could do so that therapy were accessible to all. Subjunctive required.'],
    -- 12: Architecture
    array['Write 5 sentences on what cities should do so that they were greener. Use subjunctive.',
          'Discuss what would change if all new buildings had to be sustainable. 5 sentences with subjunctive.',
          'Argue what authorities should do to protect historic centres. 5 sentences with subjunctive.',
          'Write 5 sentences on what we would gain if cars were banned from city centres. Subjunctive.',
          'Discuss what your city should do so that it had more public spaces. 5 sentences with subjunctive.',
          'Argue what should be done to make housing affordable. 5 sentences with subjunctive.',
          'Write 5 sentences on what the ideal neighbourhood would have. Use subjunctive.'],
    -- 13: Fashion & Design
    array['Write 5 sentences on what would happen if fast fashion were banned. Use subjunctive.',
          'Discuss what brands should do so that production were more ethical. 5 sentences with subjunctive.',
          'Argue what we would change if consumers truly cared about origins. 5 sentences with subjunctive.',
          'Write 5 sentences on what design education should include. Use subjunctive.',
          'Discuss what consumers should demand so that fashion were more sustainable. 5 sentences with subjunctive.',
          'Argue what would improve if luxury brands had to pay fair wages. 5 sentences with subjunctive.',
          'Write 5 sentences on what we should do so that clothes lasted longer. Use subjunctive.'],
    -- 14: Sports Analysis
    array['Write 5 sentences on what would change if every sport had equal pay for men and women. Subjunctive.',
          'Discuss what federations should do so that there were less doping. 5 sentences with subjunctive.',
          'Argue what would happen if amateur sports received more public funding. 5 sentences with subjunctive.',
          'Write 5 sentences on what should be done so that all children could play sports. Subjunctive.',
          'Discuss what clubs should do so that their fans behaved better. 5 sentences with subjunctive.',
          'Argue what we would gain if sports leaders prioritised health over profit. 5 sentences with subjunctive.',
          'Write 5 sentences on what should change so that referees were respected. Use subjunctive.'],
    -- 15: Environmental Issues
    array['Write 5 sentences on what governments should do to address climate change. Use subjunctive.',
          'Discuss what would happen if every household had to recycle by law. 5 sentences with subjunctive.',
          'Argue what should change so that public transport were truly attractive. 5 sentences with subjunctive.',
          'Write 5 sentences on what we would gain if cities had more green spaces. Use subjunctive.',
          'Discuss what companies should do so that they reduced emissions. 5 sentences with subjunctive.',
          'Argue what would happen if everyone consumed local products. 5 sentences with subjunctive.',
          'Write 5 sentences on what schools should teach so that future generations were greener. Subjunctive.']
  ];

  -- 7 speaking topic prompts per section
  speaking_prompts text[][] := array[
    -- 1: Politics & Society (tier 1, 5 sentences with sophisticated connectors)
    array['Discuss the state of democracy in your country today. 5 sentences with sin embargo or no obstante.',
          'Debate whether political parties still represent voters. 5 sentences with por consiguiente.',
          'Talk about a social issue you would prioritise. 5 sentences with cabe destacar.',
          'Argue for or against compulsory voting. 5 sentences with sophisticated connectors.',
          'Discuss the role of NGOs in modern democracies. 5 sentences.',
          'Debate whether referendums are good for democracy. 5 sentences.',
          'Talk about civic education and why it matters. 5 sentences.'],
    -- 2: Technology & Innovation
    array['Talk about how AI will reshape your profession. 5 sentences with por consiguiente.',
          'Discuss whether algorithms manipulate our choices. 5 sentences with sin embargo.',
          'Debate the privacy implications of facial recognition. 5 sentences.',
          'Argue for or against a tax on technology that replaces jobs. 5 sentences.',
          'Talk about a recent innovation that surprised you. 5 sentences.',
          'Discuss whether tech companies have too much power. 5 sentences.',
          'Debate whether smartphones are making us less focused. 5 sentences.'],
    -- 3: Philosophy & Ethics
    array['Discuss whether lying is sometimes justified. 5 sentences with cabe destacar.',
          'Argue your position on free will. 5 sentences using subjunctive.',
          'Debate whether money buys happiness. 5 sentences with sin embargo.',
          'Talk about a moral dilemma you have faced. 5 sentences.',
          'Discuss whether animals have rights similar to humans. 5 sentences.',
          'Argue whether tradition should ever override progress. 5 sentences.',
          'Debate whether all opinions deserve respect. 5 sentences.'],
    -- 4: Literature & Poetry
    array['Talk about a writer who shaped your thinking. 5 sentences.',
          'Discuss whether poetry still matters in the age of social media. 5 sentences.',
          'Debate translating classics for modern readers. 5 sentences with por consiguiente.',
          'Argue whether schools should teach only national authors. 5 sentences.',
          'Talk about a book you would have written differently. 5 sentences with subjunctive.',
          'Discuss whether authors should take public stances. 5 sentences.',
          'Compare audiobooks and reading for understanding. 5 sentences.'],
    -- 5: Business & Economics
    array['Argue for or against universal basic income. 5 sentences with no obstante.',
          'Talk about a business model you admire. 5 sentences.',
          'Discuss whether minimum wage should be raised in your country. 5 sentences with por consiguiente.',
          'Argue about taxation on luxury goods. 5 sentences.',
          'Talk about whether globalisation has helped or hurt your country. 5 sentences.',
          'Discuss the trade-off between growth and environmental limits. 5 sentences.',
          'Debate whether the gig economy is the future of work. 5 sentences.'],
    -- 6: Science & Research (tier 2, 5-6 sentences)
    array['Discuss public funding for space exploration. 5-6 sentences using no obstante and por consiguiente.',
          'Debate gene editing in humans presenting both sides. 5-6 sentences with cabe destacar.',
          'Talk about a scientific discovery that you find amazing. 5-6 sentences.',
          'Argue whether scientists should engage in activism. 5-6 sentences with sin embargo.',
          'Discuss the role of private money in research. 5-6 sentences.',
          'Debate whether scientific journals should be free to read. 5-6 sentences.',
          'Talk about basic vs applied research. 5-6 sentences.'],
    -- 7: Arts & Culture
    array['Discuss public funding of the arts. 5-6 sentences with cabe destacar and sin embargo.',
          'Debate whether museums should return colonial artefacts. 5-6 sentences.',
          'Talk about the role of cultural festivals in your city. 5-6 sentences.',
          'Argue for or against subsidising theatre tickets. 5-6 sentences.',
          'Discuss the impact of streaming on cinemas. 5-6 sentences with por consiguiente.',
          'Debate whether modern art is overrated. 5-6 sentences.',
          'Argue whether all children should learn an instrument. 5-6 sentences.'],
    -- 8: Media & Journalism
    array['Discuss press freedom in your country. 5-6 sentences with no obstante.',
          'Debate the responsibility of platforms for misinformation. 5-6 sentences with por consiguiente.',
          'Talk about a journalist or media you trust and why. 5-6 sentences.',
          'Argue for or against paywalls on quality news. 5-6 sentences.',
          'Discuss the effect of infotainment on real news. 5-6 sentences with sin embargo.',
          'Debate whether journalists should share opinions publicly. 5-6 sentences.',
          'Talk about citizen journalism and its limits. 5-6 sentences with cabe destacar.'],
    -- 9: Law & Justice
    array['Discuss restorative vs punitive justice. 5-6 sentences with no obstante.',
          'Debate the right to be forgotten online. 5-6 sentences with por consiguiente.',
          'Talk about whether juries should be replaced by judges. 5-6 sentences.',
          'Argue for or against drug decriminalisation. 5-6 sentences with sin embargo.',
          'Discuss the prison system in your country. 5-6 sentences with cabe destacar.',
          'Debate whether minor crimes deserve fines instead of prison. 5-6 sentences.',
          'Talk about expert witnesses in trials. 5-6 sentences.'],
    -- 10: History
    array['Discuss whether history is written by the winners. 5-6 sentences with sin embargo.',
          'Debate the removal of controversial statues. 5-6 sentences with cabe destacar.',
          'Talk about a historical figure you would meet. 5-6 sentences using subjunctive.',
          'Argue whether teaching colonial history is essential. 5-6 sentences with por consiguiente.',
          'Discuss whether historical novels mislead readers. 5-6 sentences.',
          'Debate the role of museums in preserving difficult history. 5-6 sentences.',
          'Argue whether we really learn from history. 5-6 sentences.'],
    -- 11: Psychology (tier 3, 6-7 sentences with subjunctive)
    array['Discuss what society would gain if mental health were prioritised. 6-7 sentences using subjunctive.',
          'Talk about what schools should do so that children develop emotional intelligence. 6-7 sentences with subjunctive.',
          'Argue what would change if we treated stress as a serious illness. 6-7 sentences with subjunctive.',
          'Discuss whether psychology should be taught from primary school. 6-7 sentences with subjunctive.',
          'Argue what would happen if every workplace had a mental health policy. 6-7 sentences.',
          'Talk about what governments should do to fight loneliness. 6-7 sentences using subjunctive.',
          'Discuss what we could do so that therapy were truly accessible. 6-7 sentences with subjunctive.'],
    -- 12: Architecture
    array['Discuss what cities should do so that they were greener. 6-7 sentences with subjunctive.',
          'Argue what would change if all new buildings had to be sustainable. 6-7 sentences with subjunctive.',
          'Talk about what authorities should do to protect historic centres. 6-7 sentences with subjunctive.',
          'Discuss what we would gain if cars were banned from city centres. 6-7 sentences.',
          'Argue what your city should do so that it had more public spaces. 6-7 sentences with subjunctive.',
          'Talk about what should be done to make housing affordable. 6-7 sentences with subjunctive.',
          'Discuss the ideal neighbourhood and what it would have. 6-7 sentences using subjunctive.'],
    -- 13: Fashion & Design
    array['Talk about what would happen if fast fashion were banned. 6-7 sentences with subjunctive.',
          'Discuss what brands should do so that production were more ethical. 6-7 sentences.',
          'Argue what we would change if consumers truly cared about origins. 6-7 sentences with subjunctive.',
          'Discuss what design education should include. 6-7 sentences.',
          'Argue what consumers should demand so that fashion were sustainable. 6-7 sentences with subjunctive.',
          'Talk about what would improve if luxury brands paid fair wages. 6-7 sentences with subjunctive.',
          'Argue what we should do so that clothes lasted longer. 6-7 sentences with subjunctive.'],
    -- 14: Sports Analysis
    array['Discuss what would change if every sport had equal pay for men and women. 6-7 sentences with subjunctive.',
          'Argue what federations should do so that there were less doping. 6-7 sentences with subjunctive.',
          'Talk about what would happen if amateur sports received more public funding. 6-7 sentences.',
          'Discuss what should be done so that all children could play sports. 6-7 sentences with subjunctive.',
          'Argue what clubs should do so that their fans behaved better. 6-7 sentences with subjunctive.',
          'Talk about what we would gain if leaders prioritised health over profit. 6-7 sentences with subjunctive.',
          'Discuss what should change so that referees were respected. 6-7 sentences with subjunctive.'],
    -- 15: Environmental Issues
    array['Talk about what governments should do to address climate change. 6-7 sentences with subjunctive and connectors.',
          'Discuss what would happen if every household had to recycle by law. 6-7 sentences with subjunctive.',
          'Argue what should change so that public transport were truly attractive. 6-7 sentences with subjunctive.',
          'Discuss what we would gain if cities had more green spaces. 6-7 sentences.',
          'Argue what companies should do so that they reduced emissions. 6-7 sentences with subjunctive.',
          'Talk about what would happen if everyone consumed local products. 6-7 sentences with subjunctive.',
          'Discuss what schools should teach so that future generations were greener. 6-7 sentences with subjunctive.']
  ];

  -- Spanish audio: short monologues / debate excerpts. User analyses
  -- speaker attitude and implied meaning in 3-4 Spanish sentences.
  listening_audio text[][] := array[
    -- 1: Politics & Society
    array['Algunos políticos afirman que la abstención no es indiferencia, sino una forma legítima de protesta cuando los partidos dejan de representar a la gente. ¿Cómo interpretas esa idea?',
          'Una conocida activista dice que la democracia no muere de un golpe, sino de mil pequeñas concesiones cotidianas. ¿Qué crees que quiere decir realmente?',
          'En un debate reciente, un periodista insinuó que la polarización no es un accidente, sino el modelo de negocio de muchos medios. ¿Cómo valoras esa afirmación?',
          'Una socióloga sostiene que bajar la edad de voto a dieciséis años obligaría a los partidos a renovarse o desaparecer. ¿Qué opinas de su análisis?',
          'Un alcalde comentó que las ONG han sustituido al Estado en muchos barrios olvidados. ¿Crees que se trata de un elogio o de una crítica?',
          'Un constitucionalista advierte que los referéndums simplifican preguntas que son inherentemente complejas. ¿Estás de acuerdo con su preocupación?',
          'Un profesor de instituto dice que sin educación cívica no hay democracia, solo costumbre. ¿Cómo entiendes esa afirmación tan tajante?'],
    -- 2: Technology & Innovation
    array['Un experto en ética digital advirtió que los algoritmos no nos muestran lo que necesitamos saber, sino lo que nos mantiene enganchados. ¿Qué te parece su denuncia?',
          'En una entrevista, una ingeniera dijo que la IA hará a los profesionales mediocres irrelevantes y a los buenos profesionales aún mejores. ¿Cómo interpretas esa afirmación?',
          'Una abogada sostiene que el reconocimiento facial en espacios públicos cambia silenciosamente la relación entre el ciudadano y el Estado. ¿Qué implica realmente?',
          'Un economista propuso un impuesto a las máquinas que sustituyan a trabajadores; sus colegas lo acusan de frenar la innovación. ¿De qué lado te pones y por qué?',
          'Una pediatra advirtió que el problema no es la pantalla, sino lo que dejamos de hacer mientras la miramos. ¿Cómo entiendes ese matiz?',
          'Un fundador de una empresa tecnológica admitió que ya no controla lo que su plataforma hace con los datos. ¿Cómo valoras esa confesión?',
          'Una investigadora dijo que las "smart cities" son menos inteligentes y más vigiladas de lo que parece. ¿Crees que exagera o tiene razón?'],
    -- 3: Philosophy & Ethics
    array['Un filósofo afirmó que mentir para no herir no siempre es lo más ético, porque infantiliza al otro. ¿Cómo interpretas su crítica?',
          'En una clase, una profesora dijo que el libre albedrío es probablemente una ilusión útil. ¿Qué entiendes por esa expresión?',
          'Un escritor sostuvo que el dinero compra tiempo, y el tiempo es lo que más se parece a la felicidad. ¿Cómo evalúas ese argumento?',
          'Un jurista declaró que la pena de muerte dice más del Estado que del condenado. ¿Qué quiere decir realmente?',
          'Una activista por los derechos de los animales dijo que el "amor a la mascota" oculta una hipocresía moral cómoda. ¿Estás de acuerdo con su provocación?',
          'Un sociólogo argumentó que respetar la tradición no es lo mismo que aceptarla acríticamente. ¿Por qué crees que hace esa distinción?',
          'Un crítico afirmó que decir que todas las opiniones merecen respeto es, en realidad, no respetar ninguna. ¿Cómo interpretas su provocación?'],
    -- 4: Literature & Poetry
    array['Una novelista dijo que los libros no cambian el mundo, pero sí cambian a quienes después intentan cambiarlo. ¿Cómo interpretas esa idea?',
          'Un poeta sostuvo que la poesía no muere; simplemente cambia de barrio y de soporte. ¿Crees que tiene razón?',
          'Una traductora afirmó que traducir un clásico es traicionarlo creativamente. ¿Qué quiere decir?',
          'Un profesor universitario dijo que enseñar solo autores nacionales empobrece a los estudiantes. ¿Qué quiere defender realmente?',
          'Un editor declaró que la literatura de género no necesita justificarse ante nadie. ¿Cómo interpretas su tono?',
          'Una autora admitió que mantenerse al margen de la política le parece imposible y, además, deshonesto. ¿Qué crees que implica?',
          'Un crítico literario opinó que el audiolibro no rivaliza con la lectura, sino con el silencio del coche. ¿Qué te parece su matiz?'],
    -- 5: Business & Economics
    array['Un economista dijo que la renta básica universal no soluciona problemas, sino que cambia las preguntas que nos hacemos. ¿Cómo interpretas eso?',
          'Una CEO admitió que poner a los accionistas siempre primero es, a largo plazo, malo para la empresa misma. ¿Qué quiere decir?',
          'Un sindicalista sostuvo que subir el salario mínimo no destruye empleo: cambia quién paga el coste de ese empleo. ¿Cómo interpretas esa afirmación?',
          'Un empresario afirmó que los impuestos al lujo no son redistribución, sino marketing político. ¿Qué crees que insinúa?',
          'Una empresaria local declaró que la globalización ha matado más oficios artesanos que cualquier crisis. ¿Estás de acuerdo con su tono?',
          'Un economista sostuvo que el crecimiento infinito en un planeta finito ya no es una opinión, es una imposibilidad física. ¿Qué piensas?',
          'Un trabajador autónomo dijo que la "economía de plataformas" le da libertad, pero también soledad. ¿Cómo interpretas ese contraste?'],
    -- 6: Science & Research
    array['Una astrónoma argumentó que invertir en espacio es ridículo cuando hay tanta pobreza, pero también que abandonar la curiosidad nos empobrece más. ¿Cómo entiendes esa tensión?',
          'Una bióloga dijo que la edición genética podría salvarnos o convertirnos en algo que ya no reconoceríamos. ¿Cómo evalúas su advertencia?',
          'Un editor científico sostuvo que cobrar por leer ciencia financiada con dinero público es una doble factura para el ciudadano. ¿Qué te parece su crítica?',
          'Un investigador admitió que sin animales de laboratorio muchos avances serían imposibles, pero que justificar todo en nombre del progreso es peligroso. ¿Cómo interpretas su matiz?',
          'Una científica afirmó que pedirnos no opinar en público es pedirnos que no seamos ciudadanos. ¿Qué quiere decir?',
          'Un decano dijo que la dependencia de fondos privados ya determina qué se investiga y qué no. ¿Qué implica esa afirmación?',
          'Una física aseguró que sin ciencia básica no hay tecnología real, solo aplicaciones de ideas viejas. ¿Cómo entiendes su argumento?'],
    -- 7: Arts & Culture
    array['Un director artístico dijo que financiar la cultura con dinero público no es un capricho sino una decisión sobre qué tipo de país queremos ser. ¿Qué te parece su argumento?',
          'Una curadora afirmó que devolver objetos coloniales no es perder colección, es ganar legitimidad. ¿Cómo interpretas su postura?',
          'Un economista dijo que los festivales atraen mucho dinero pero también demasiada gentrificación. ¿Qué tensión describe?',
          'Un actor de teatro sostuvo que subvencionar entradas no es paternalismo, es supervivencia del oficio. ¿Cómo entiendes eso?',
          'Una crítica afirmó que el streaming no mata los cines: los obliga a reinventarse o desaparecer. ¿Qué implica realmente?',
          'Un coleccionista dijo que mucha "arte conceptual" cobra más por la idea que por el trabajo. ¿Cómo interpretas su crítica?',
          'Una profesora insistió en que aprender música mejora competencias que ni el sistema ni los padres reconocen. ¿Por qué crees que insiste en este punto?'],
    -- 8: Media & Journalism
    array['Una directora de un periódico dijo que la libertad de prensa se mide en lo que un Gobierno permite que le critiquen, no en lo que dice tolerar. ¿Cómo interpretas su provocación?',
          'Un experto en redes afirmó que pedir a las plataformas que moderen contenidos es pedirles que se controlen a sí mismas, lo cual no funciona. ¿Qué quiere decir?',
          'Una periodista sostuvo que sin fuentes anónimas no habría investigaciones serias, aunque eso tenga un coste para la verificación. ¿Cómo evalúas su argumento?',
          'Un editor digital dijo que los muros de pago dividen a los lectores en bien informados y desinformados. ¿Qué denuncia realmente?',
          'Un crítico cultural sostuvo que mezclar noticias y entretenimiento erosiona la confianza incluso en lo serio. ¿Cómo interpretas ese efecto?',
          'Una columnista dijo que disimular las opiniones propias engaña más al lector que mostrarlas. ¿Qué quiere defender?',
          'Una reportera afirmó que el periodismo ciudadano completa, pero nunca sustituye, al periodismo profesional. ¿Por qué insiste en esta distinción?'],
    -- 9: Law & Justice
    array['Una jueza sostuvo que la justicia restaurativa no es debilidad, sino la única que reduce realmente la reincidencia. ¿Cómo evalúas su argumento?',
          'Un abogado afirmó que el "derecho al olvido" digital choca con la memoria democrática. ¿Qué tensión describe?',
          'Una juez popular dijo que reemplazar los jurados por jueces sería ganar técnica y perder legitimidad. ¿Qué matiz quiere transmitir?',
          'Una activista sostuvo que despenalizar las drogas no es promoverlas, sino dejar de castigar a los más vulnerables. ¿Cómo interpretas su provocación?',
          'Un director de prisiones dijo que su sistema sirve para castigar pero no para reinsertar. ¿Qué crees que está admitiendo?',
          'Una jurista afirmó que sustituir cárcel por multas para delitos menores libera recursos para los casos graves. ¿Estás de acuerdo con su lógica?',
          'Un fiscal dijo que los peritos se han convertido en jueces invisibles de muchos juicios. ¿Qué riesgo está señalando?'],
    -- 10: History
    array['Una historiadora declaró que la historia no la escriben siempre los vencedores, sino los más constantes en publicar. ¿Cómo interpretas ese matiz?',
          'Un alcalde dijo que retirar estatuas no es borrar la historia, sino dejar de celebrarla en público. ¿Qué quiere defender?',
          'Una profesora afirmó que no enseñar el pasado colonial es educar ciudadanos a medias. ¿Por qué crees que lo plantea así?',
          'Un político usó un episodio histórico para justificar una ley actual; varios historiadores lo criticaron. ¿Qué problema ven?',
          'Una novelista dijo que la novela histórica miente para decir verdades que el documento ignora. ¿Cómo entiendes esa idea?',
          'Una curadora sostuvo que mostrar la historia incómoda es más educativo que esconderla por respeto. ¿Qué argumenta?',
          'Un divulgador dijo que repetimos los errores del pasado porque solo recordamos las anécdotas. ¿Qué quiere alertar?'],
    -- 11: Psychology
    array['Una psicóloga sostuvo que si tratáramos la salud mental como la física, muchas crisis se evitarían antes de explotar. ¿Qué implica esa comparación?',
          'Un profesor dijo que enseñar inteligencia emocional debería ser tan obligatorio como las matemáticas. ¿Cómo evalúas su propuesta?',
          'Un médico afirmó que llamar al estrés "parte del trabajo" es una forma cómoda de negar una enfermedad real. ¿Qué denuncia?',
          'Una pedagoga sostuvo que si la psicología entrara en primaria, criaríamos otra clase de adultos. ¿Qué supone esa idea?',
          'Un consultor laboral admitió que las políticas de salud mental existen sobre el papel pero rara vez se aplican. ¿Qué problema describe?',
          'Una socióloga afirmó que la soledad es la pandemia silenciosa que los gobiernos prefieren no nombrar. ¿Por qué crees que insiste en este punto?',
          'Una terapeuta dijo que el acceso a la terapia depende todavía demasiado del código postal. ¿Cómo interpretas su queja?'],
    -- 12: Architecture
    array['Un arquitecto afirmó que las ciudades verdes no son las que plantan árboles, sino las que cambian el modelo de movilidad. ¿Cómo interpretas su matiz?',
          'Un urbanista dijo que obligar a construir sostenible encarecerá las obras a corto plazo pero ahorrará millones en una generación. ¿Qué argumenta?',
          'Una conservacionista sostuvo que proteger un centro histórico no es congelarlo, sino enseñarle a respirar. ¿Cómo entiendes esa imagen?',
          'Un alcalde dijo que prohibir coches en el centro no recorta libertad, sino que la devuelve a los peatones. ¿Qué replantea con esto?',
          'Una urbanista afirmó que la falta de espacios públicos explica más conflictos vecinales que cualquier ley. ¿Por qué lo plantea así?',
          'Un investigador sostuvo que sin política pública firme la vivienda nunca volverá a ser asequible. ¿Qué descarta como solución?',
          'Una arquitecta dijo que el barrio ideal es aquel donde puedes envejecer sin tener que mudarte. ¿Cómo interpretas esa idea?'],
    -- 13: Fashion & Design
    array['Una diseñadora dijo que la moda rápida es barata para el consumidor y carísima para el planeta. ¿Qué tensión describe?',
          'Una activista sostuvo que las marcas hablan de sostenibilidad pero siguen produciendo cincuenta colecciones al año. ¿Qué denuncia?',
          'Un consultor afirmó que si los consumidores supieran realmente dónde se hace su ropa, muchas marcas quebrarían. ¿Cómo entiendes su crítica?',
          'Una profesora de diseño dijo que enseñar diseño sin enseñar ética es como enseñar medicina sin pacientes. ¿Qué analogía propone?',
          'Una compradora declaró que prefiere pagar el doble por la mitad de ropa, pero que dura cinco veces más. ¿Cómo valoras su criterio?',
          'Un crítico afirmó que el lujo deja de serlo cuando se construye sobre salarios injustos. ¿Qué redefinición propone?',
          'Una sastra afirmó que cuando aprendamos a reparar la ropa, dejaremos de necesitar tantas marcas. ¿Cómo interpretas su esperanza?'],
    -- 14: Sports Analysis
    array['Una jugadora sostuvo que si los premios fueran iguales para hombres y mujeres, el deporte ganaría también en credibilidad. ¿Cómo entiendes su argumento?',
          'Un médico deportivo afirmó que mientras el doping siga siendo más lucrativo que la honestidad, no se erradicará. ¿Qué denuncia realmente?',
          'Un entrenador dijo que el deporte amateur sostiene al profesional, y no al revés, y debería financiarse así. ¿Qué replantea con esto?',
          'Un pediatra sostuvo que ningún niño debería quedarse fuera del deporte por falta de dinero. ¿Cómo interpretas su exigencia?',
          'Un sociólogo afirmó que los clubes responden al comportamiento de sus aficionados solo cuando hay sanciones. ¿Qué problema señala?',
          'Una directora deportiva dijo que cuando los dirigentes priorizan la salud, la economía del club también mejora. ¿Cómo evalúas su lógica?',
          'Un árbitro sostuvo que el respeto al árbitro se enseña antes en casa que en la cancha. ¿Qué responsabilidad reparte así?'],
    -- 15: Environmental Issues
    array['Un científico del clima afirmó que la inacción ya cuesta más que la transición; el debate sobre el coste es político, no técnico. ¿Cómo interpretas esa idea?',
          'Una funcionaria sostuvo que si reciclar fuera obligatorio para todos los hogares, las plantas de tratamiento mejorarían rápidamente. ¿Qué supone con eso?',
          'Un urbanista dijo que el transporte público no atrae usuarios por más limpio que sea, sino por más frecuente y barato. ¿Cómo interpretas su crítica?',
          'Una bióloga afirmó que las zonas verdes urbanas no son ornamento, sino infraestructura. ¿Qué replantea con esta palabra?',
          'Un consultor sostuvo que las empresas reducen emisiones solo cuando el coste del carbono es real para ellas. ¿Qué denuncia?',
          'Una nutricionista dijo que consumir local cambia la dieta pero también la economía rural. ¿Cómo evalúas su matiz?',
          'Una maestra afirmó que sin educación ambiental temprana, ninguna ley tendrá efecto duradero. ¿Qué te parece su diagnóstico?']
  ];

  -- Reference Spanish responses for AI grading context (3-4 sentences,
  -- analytical, not summarising)
  listening_reference text[][] := array[
    -- 1
    array['Comparto en parte esa idea, sin embargo abstenerse rara vez se entiende como mensaje; suele leerse como desinterés. Lo realmente útil sería votar en blanco o crear nuevas opciones políticas.',
          'Creo que apunta a la erosión silenciosa de la democracia: pequeñas cesiones que parecen inofensivas terminan vaciando las instituciones. Es una advertencia inteligente, aunque algo apocalíptica.',
          'Me parece una crítica acertada. Cuando el conflicto vende, los medios no tienen incentivos para moderar el tono; eso explica buena parte del clima actual.',
          'No estoy convencido. Bajar la edad podría rejuvenecer el debate, pero no garantiza más calidad si la educación cívica sigue siendo débil.',
          'Lo entiendo más como una crítica: significa que el Estado ha fallado y la sociedad civil tapa el hueco, lo cual no debería ser sostenible.',
          'Comparto su preocupación. Los referéndums simplifican preguntas complejas en sí o no, y eso facilita la manipulación.',
          'Es una formulación dura pero acertada: sin formación cívica, votar se convierte en un acto reflejo. La democracia necesita ciudadanos, no espectadores.'],
    -- 2
    array['Su denuncia me parece fundada. Las plataformas optimizan tiempo de uso, no calidad de la información, y eso distorsiona nuestro acceso a lo importante.',
          'Su afirmación me parece exagerada en lo positivo, pero acertada en lo competitivo: quienes ya tienen criterio aprovecharán mejor la herramienta.',
          'Implica una vigilancia normalizada que casi nadie cuestiona. Cambia la relación con el Estado porque convierte el espacio público en un espacio observado.',
          'Me posiciono a favor de algún tipo de gravamen. Si una empresa se ahorra mano de obra, debería contribuir a financiar la transición laboral.',
          'Es un matiz muy útil. El daño no está solo en la pantalla, sino en lo que no hacemos: dormir, conversar, aburrirnos creativamente.',
          'Es una confesión preocupante. Si ni los fundadores entienden el comportamiento de sus plataformas, los reguladores tienen muy pocas opciones.',
          'No creo que exagere. "Smart city" suele ser un eslogan que enmascara un modelo de datos del que los ciudadanos no son dueños.'],
    -- 3
    array['Su crítica me parece interesante. Mentir por compasión a veces protege al que miente, no al otro; tratar al adulto como adulto es un acto de respeto.',
          'Entiendo que es una ilusión necesaria para vivir socialmente, aunque empíricamente nuestras decisiones estén condicionadas por mil factores.',
          'El argumento es matizado: el dinero no da felicidad pero compra tiempo, y disponer de tu tiempo se acerca mucho a la libertad y al bienestar.',
          'Insinúa que el Estado se rebaja al mismo nivel del delito: pierde autoridad moral al matar, aunque sea legalmente.',
          'Su provocación es incómoda pero útil. Adoramos a unos animales mientras toleramos el sufrimiento sistemático de otros sin pestañear.',
          'Distingue obediencia ciega y respeto activo: aceptar una tradición debería ser una decisión informada, no una inercia.',
          'Su provocación señala que el "respeto universal" puede ser una forma cómoda de relativismo, donde nada se discute y todo se tolera.'],
    -- 4
    array['Su tono me parece más realista que pesimista: los libros no transforman directamente la realidad, pero sí a quienes después la transforman.',
          'Comparto su esperanza. La poesía ha cambiado de formato (canciones, vídeos, redes), pero la necesidad de leer y crear poesía persiste.',
          'Defiende una idea muy moderna de la traducción: ser fiel al original implica recrearlo, no copiarlo literalmente.',
          'Quiere defender la apertura cultural: leer solo lo propio reduce la mirada y empobrece la comprensión del mundo.',
          'Su tono es desafiante, casi enfadado. Da por hecho que la literatura de género debe disculparse, y rechaza esa exigencia.',
          'Implica que en una sociedad polarizada, el silencio del autor también es una posición política, queriéndolo o no.',
          'Matiza con elegancia: el audiolibro no compite con la lectura concentrada, sino con momentos en los que antes no leíamos nada.'],
    -- 5
    array['Su lectura me parece sutil. La renta básica obliga a repensar el trabajo, la dignidad y la productividad, más que a "solucionar" la pobreza.',
          'Admite que la presión por resultados trimestrales acaba dañando a la empresa a largo plazo; es una crítica desde dentro del propio sistema.',
          'Su argumento es claro: el coste del salario digno se redistribuye, no desaparece, y la productividad suele compensarlo a medio plazo.',
          'Insinúa que ese tipo de impuesto se usa como gesto político más que como política redistributiva real.',
          'Su tono es bastante crítico. Habla con dolor de oficios desaparecidos y describe la globalización como un proceso desigual.',
          'Comparto su análisis: tratar el crecimiento infinito como inevitable contradice los límites físicos del planeta.',
          'Su contraste me parece honesto. La libertad de elegir horarios convive con la falta de redes laborales y de protección social.'],
    -- 6
    array['Plantea una tensión auténtica: cuesta justificar el gasto en lo lejano, pero abandonar la curiosidad nos hace más pequeños como especie.',
          'Su advertencia me parece prudente. La tecnología avanza más rápido que el consenso ético, y eso siempre acaba teniendo consecuencias.',
          'Su crítica es contundente y justa: pagar dos veces por la misma ciencia es indefendible si lo público financió la investigación.',
          'Reconoce ambas verdades a la vez: hay avances que dependieron del modelo animal, pero "el progreso" no puede ser un cheque en blanco.',
          'Defiende que su silencio sería antidemocrático; los expertos también son ciudadanos y deben ser escuchados públicamente.',
          'Implica que la agenda científica se está privatizando, dejando temas socialmente cruciales sin financiación.',
          'Su argumento es sólido: sin investigación básica, las aplicaciones nuevas se vuelven imposibles a medio plazo.'],
    -- 7
    array['Define la cultura como una elección política, no como un gasto superfluo; me parece una manera valiente de defender el presupuesto.',
          'Postula que devolver objetos coloniales no es perder, es recuperar respetabilidad; aporta una mirada postcolonial muy actual.',
          'Describe la dualidad de los festivales: dinamizan la economía pero también encarecen los barrios y desplazan a los vecinos.',
          'Defiende la subvención como inversión cultural, no como caridad; sin público diverso, el teatro se vuelve elitista y muere.',
          'Implica que sobrevivirán los cines que ofrezcan algo que el streaming no da: experiencia colectiva, calidad técnica, programación cuidada.',
          'Su crítica es punzante pero generalista; hay arte conceptual flojo, sí, pero también obras que justifican plenamente su precio.',
          'Insiste porque la música desarrolla habilidades transversales (memoria, paciencia, escucha) que ningún examen mide directamente.'],
    -- 8
    array['Su provocación distingue libertad real de libertad declarada; en muchos países hay leyes liberales pero presión política sobre los medios.',
          'Quiere decir que la autorregulación es estructuralmente ineficaz; los reguladores externos tendrán que intervenir tarde o temprano.',
          'Reconoce un dilema profesional auténtico: sin anonimato no hay periodismo de investigación, pero la verificación se complica.',
          'Denuncia una fractura informativa: quien puede pagar accede a buen periodismo, quien no, queda atrapado en lo gratuito y manipulable.',
          'Describe un efecto contagio: el descrédito empieza en los formatos sensacionalistas y se traslada a todo el sector.',
          'Defiende la transparencia: declarar las opiniones permite al lector contextualizar mejor las informaciones que recibe.',
          'Distingue dos lógicas profesionales: el periodismo ciudadano aporta inmediatez, pero no sustituye el rigor del trabajo profesional.'],
    -- 9
    array['Su argumento se apoya en evidencia empírica; los modelos restaurativos reducen reincidencia y reparan a la víctima.',
          'Apunta a una contradicción real: proteger la privacidad puede borrar también responsabilidades públicas que la sociedad necesita recordar.',
          'Su matiz reconoce dos valores en conflicto: precisión técnica frente a participación ciudadana en la justicia.',
          'Defiende un cambio de enfoque: tratar el consumo como problema sanitario y no penal, sobre todo en colectivos vulnerables.',
          'Está reconociendo un fracaso institucional: la prisión castiga, pero no logra el objetivo declarado de reinserción.',
          'Sus argumentos son razonables si se acompañan de servicios alternativos (multas proporcionales, trabajo comunitario, apoyo psicosocial).',
          'Señala una opacidad inquietante: si nadie escruta a los peritos, su autoridad técnica puede sustituir el debate jurídico.'],
    -- 10
    array['Matiza un cliché: no siempre la escribe el vencedor militar, sino quien más persistentemente publica y enseña su versión.',
          'Defiende un equilibrio: la historia se conserva en libros y museos, no en pedestales del espacio público.',
          'Lo plantea así porque ignorar el colonialismo simplifica la identidad nacional y dificulta entender los conflictos actuales.',
          'Critican el uso instrumental de la historia: simplificar el pasado para justificar decisiones del presente es una manipulación.',
          'Entiendo que la novela histórica trabaja con conjeturas plausibles, abre preguntas que el documento, por su sequedad, ignora.',
          'Argumenta que esconder lo incómodo no protege, anestesia; los museos deben asumir un rol incómodo si quieren ser útiles.',
          'Alerta sobre el riesgo del olvido selectivo: si solo recordamos lo pintoresco, no aprendemos nada estructural.'],
    -- 11
    array['Su comparación implica que la prevención es mucho más barata y humana que la intervención de urgencia, también en salud mental.',
          'Su propuesta me parece sensata si se forma adecuadamente al profesorado; sin ello, la asignatura quedaría en buena intención.',
          'Denuncia una normalización dañina: el estrés crónico se ha banalizado y eso impide tratarlo como problema médico real.',
          'Supone una transformación cultural profunda; criaríamos adultos con más herramientas para gestionar conflictos y relaciones.',
          'Describe la brecha entre discurso y práctica: las políticas existen pero se quedan en la página y no llegan al día a día.',
          'Insiste porque la soledad afecta a la salud, a la productividad y al tejido social, y aún se trata como un asunto privado.',
          'Su queja tiene base: la sanidad pública debería incluir terapia accesible para que el acceso no dependa del bolsillo.'],
    -- 12
    array['Su matiz es importante: plantar árboles es solo el síntoma; lo estructural es repensar cómo se mueven las personas en la ciudad.',
          'Argumenta con visión de futuro: cualquier sobrecoste inicial se amortiza con menor consumo energético y mejor salud pública.',
          'Defiende una conservación viva, no museística; el centro histórico debe permitir vida cotidiana, no solo turismo.',
          'Replantea la palabra "libertad": la libertad real puede ser caminar sin contaminación, no aparcar donde sea.',
          'Lo plantea así porque sin espacios públicos, los conflictos se trasladan al portal y al patio interior.',
          'Descarta el mercado puro como solución; sin políticas firmes, la vivienda seguirá siendo un activo financiero, no un derecho.',
          'Una idea muy bonita: barrios que envejecen contigo significan diseño accesible, comercio cercano y comunidad estable.'],
    -- 13
    array['Describe una externalización del coste: el consumidor paga poco porque pagan el trabajador y el planeta.',
          'Denuncia el "greenwashing": el marketing avanza más rápido que las prácticas reales de producción.',
          'Critica la opacidad de la cadena de suministro; transparencia plena cambiaría los hábitos de compra.',
          'La analogía es contundente y precisa: diseñar afecta a personas, así que enseñar diseño sin ética es irresponsable.',
          'Su criterio combina sostenibilidad y economía: gastar más por prenda es razonable si la prenda dura mucho más.',
          'Redefine el lujo como dignidad productiva, no como precio elevado; un cambio cultural necesario.',
          'Su esperanza apunta a una habilidad casi olvidada; saber reparar reduciría drásticamente nuestro consumo de moda.'],
    -- 14
    array['Su argumento une justicia y rendimiento; igualar premios no es solo ético, también atrae más talento y patrocinio.',
          'Denuncia un incentivo perverso: mientras el doping pague, ninguna regla sola lo erradicará.',
          'Replantea la base del deporte: lo amateur es el semillero, sin él el profesional pierde calidad y arraigo social.',
          'Su exigencia es elemental: el acceso al deporte infantil debe garantizarse como un servicio público.',
          'Señala que sin sanciones reales y educativas, los clubes solo reaccionan ante el escándalo, no ante el problema.',
          'Su lógica encadena salud y economía: cuidar a los deportistas reduce lesiones, prolonga carreras y mejora resultados.',
          'Reparte la responsabilidad: la cultura del respeto comienza fuera del campo, en la casa y en la escuela.'],
    -- 15
    array['Su idea desmonta un debate falso: lo caro no es actuar, es no actuar; lo que discutimos es realmente quién paga.',
          'Supone que con presión social y normativa, el sistema de tratamiento crecería rápido para responder a la demanda.',
          'Su crítica reorienta la prioridad: no basta con vehículos limpios; el transporte necesita ser frecuente y asequible.',
          'Reformula el verde urbano como infraestructura indispensable: regula temperatura, absorbe agua y mejora la salud mental.',
          'Denuncia que sin precio real al carbono, las empresas externalizan el impacto y la sociedad paga la factura.',
          'Su matiz me parece justo; consumir local rebalancea la economía rural, además de reducir transporte.',
          'Su diagnóstico es preciso: sin formación temprana, las leyes ambientales se aplican mal y se respetan menos.']
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
      and cefr_level = 'B2'
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

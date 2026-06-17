-- 043_spanish_c1_ai_graded_exercises.sql
-- Same shape as 039/040/041/042 but for every Spanish C1 lesson (15
-- sections × 7 teaching lessons). Each lesson's listening / speaking /
-- writing rows are deleted and reseeded in the AI-graded format the
-- LessonClient already supports.
--
-- C1 difficulty bumps vs B2:
--   Writing tier 1 (sections 1-5):  5 sentences in formal register
--   Writing tier 2 (sections 6-10): 6 sentences with advanced connectors
--                                   (no obstante, asimismo, cabe señalar)
--   Writing tier 3 (sections 11-15): 7-8 sentences using subjunctive
--                                    AND conditional perfect (habría + ppt)
--   Speaking tier 1: 6 sentences | tier 2: 6-7 | tier 3: 7-8
--     Must demonstrate near-native fluency, idiomatic expressions, and
--     mastery of register, rhetoric and discourse markers.
--   Listening audio is near-native speed monologue / news / debate;
--   candidate types a 4-5 sentence Spanish response critically engaging
--   with implicit meaning, tone, bias and register shifts.
--
-- Schema constraint already accepts 'writing' from 039.
-- Idempotent.

do $$
declare
  v_lang_id   bigint;
  v_course_id bigint;
  v_lesson_id bigint;

  -- C1 sections, canonical order from 015_spanish_restructure_15x8.sql
  section_names text[] := array[
    'Idioms & Expressions','Advanced Grammar','Formal Writing','Debate & Discussion','Native Content',
    'Academic Language','Professional Communication','Cultural Nuance','Rhetoric & Persuasion',
    'Advanced Literature','Complex Grammar Structures','Regional Dialects','Slang & Informal Language',
    'Translation Skills','Language Teaching'
  ];

  -- 7 writing prompts per section [section_idx][lesson_idx 1..7]
  writing_prompts text[][] := array[
    -- 1: Idioms & Expressions (tier 1, 5 sentences, formal register)
    array['Write 5 sentences in formal register on whether idiomatic competence should be a marker of true bilingualism.',
          'In a formal tone, write 5 sentences analysing the cultural depth carried by Spanish proverbs.',
          'Write 5 sentences arguing in formal register whether idioms are best learned in context or explicitly taught.',
          'Critically evaluate, in 5 formal sentences, the loss of idiom in modern Spanish journalism.',
          'In a formal register, write 5 sentences on how regional idioms enrich or fragment a shared linguistic identity.',
          'Write 5 sentences in formal register reflecting on the use of "frases hechas" in academic writing.',
          'Analyse, in 5 formal sentences, whether AI translators will eventually master idiomatic Spanish.'],
    -- 2: Advanced Grammar
    array['Write 5 sentences in formal register on whether prescriptive grammar still matters in modern Spanish.',
          'Critically evaluate, in 5 formal sentences, the use of subjunctive among younger Spanish speakers.',
          'In a formal tone, write 5 sentences on the disappearance of the future subjunctive from everyday speech.',
          'Write 5 sentences in formal register on whether grammar should be taught descriptively or prescriptively.',
          'Analyse, in 5 formal sentences, how social media is reshaping written Spanish grammar.',
          'Write 5 formal sentences on the pedagogical challenge of teaching ser vs estar to advanced learners.',
          'Critically evaluate, in 5 formal sentences, the role of dictation in modern grammar instruction.'],
    -- 3: Formal Writing
    array['Write 5 sentences in formal register evaluating the role of formal Spanish in international diplomacy.',
          'In a formal tone, write 5 sentences on whether emails have replaced the formal letter for good.',
          'Critically evaluate, in 5 formal sentences, the influence of English business jargon on Spanish corporate writing.',
          'Write 5 formal sentences on the place of register in academic publication.',
          'In formal register, write 5 sentences on whether plain-language movements have improved or weakened legal writing.',
          'Write 5 sentences in formal register on the cultural weight of "usted" in professional correspondence.',
          'Critically evaluate, in 5 formal sentences, the disappearance of formal Spanish among young professionals.'],
    -- 4: Debate & Discussion
    array['Write 5 sentences in formal register on whether debate skills should be taught in every school.',
          'In a formal tone, write 5 sentences arguing whether televised debates educate or polarise voters.',
          'Critically evaluate, in 5 formal sentences, the role of moderators in political debates.',
          'Write 5 sentences in formal register on whether online comment sections constitute genuine debate.',
          'In formal register, write 5 sentences on the disappearance of long-form debate in mass media.',
          'Write 5 formal sentences on the role of silence and pause as rhetorical resources in debate.',
          'Critically evaluate, in 5 formal sentences, the value of cross-party debate clubs at university.'],
    -- 5: Native Content
    array['Write 5 sentences in formal register evaluating the importance of consuming native content for advanced learners.',
          'In a formal tone, write 5 sentences on whether dubbed series harm or help language acquisition.',
          'Critically evaluate, in 5 formal sentences, the explosion of Spanish-language podcasts in recent years.',
          'Write 5 formal sentences on the cultural impact of Latin American streaming originals worldwide.',
          'In formal register, write 5 sentences on the difficulty of understanding regional Spanish accents on TV.',
          'Write 5 sentences in formal register on whether subtitles delay or accelerate fluency.',
          'Critically evaluate, in 5 formal sentences, the role of YouTube creators in shaping modern Spanish usage.'],
    -- 6: Academic Language (tier 2, 6 sentences with no obstante/asimismo/cabe señalar)
    array['Write 6 sentences on academic neutrality, using "no obstante", "asimismo" and "cabe señalar".',
          'Critically evaluate the use of jargon in academic Spanish in 6 sentences with the connectors no obstante / asimismo / cabe señalar.',
          'In academic register, write 6 sentences on whether open access damages traditional publishers; include the three connectors.',
          'Write 6 sentences on the pressure to publish in English among Spanish-speaking academics; use no obstante, asimismo, cabe señalar.',
          'Critically evaluate, in 6 sentences, the role of peer review in modern science; include the three connectors.',
          'In academic register, write 6 sentences on the rise of preprint servers; use no obstante, asimismo, cabe señalar.',
          'Write 6 sentences on academic writing classes for non-native Spanish speakers; include the three connectors.'],
    -- 7: Professional Communication
    array['Write 6 sentences in formal register on whether brevity is undervalued in professional emails; use no obstante, asimismo, cabe señalar.',
          'Critically evaluate, in 6 sentences, the impact of remote work on professional Spanish; include the three connectors.',
          'In formal register, write 6 sentences on the proper use of "usted" in modern Spanish workplaces; use the three connectors.',
          'Write 6 sentences on whether English business jargon should be resisted in Spanish offices; use no obstante, asimismo, cabe señalar.',
          'Critically evaluate, in 6 sentences, the role of LinkedIn writing in professional identity; include the three connectors.',
          'In formal register, write 6 sentences on how to deliver difficult feedback in Spanish; use no obstante, asimismo, cabe señalar.',
          'Write 6 sentences in formal register on cross-cultural professional communication; include the three connectors.'],
    -- 8: Cultural Nuance
    array['Write 6 sentences on whether cultural nuance can ever be fully taught; use no obstante, asimismo, cabe señalar.',
          'Critically evaluate, in 6 sentences, the role of cultural intelligence in international business; include the three connectors.',
          'In a formal tone, write 6 sentences on whether globalisation flattens cultural nuance; use no obstante, asimismo, cabe señalar.',
          'Write 6 sentences on the role of humour as a cultural marker in Spanish; include the three connectors.',
          'Critically evaluate, in 6 sentences, the difficulty of conveying irony across cultures; use no obstante, asimismo, cabe señalar.',
          'In formal register, write 6 sentences on cultural code-switching among bilinguals; include the three connectors.',
          'Write 6 sentences on the cultural depth of Spanish family vocabulary; use no obstante, asimismo, cabe señalar.'],
    -- 9: Rhetoric & Persuasion
    array['Write 6 sentences on the ethics of rhetorical manipulation; use no obstante, asimismo, cabe señalar.',
          'Critically evaluate, in 6 sentences, classical rhetoric''s relevance to modern campaigns; include the three connectors.',
          'In a formal tone, write 6 sentences on whether emotional appeals undermine reasoned debate; use the three connectors.',
          'Write 6 sentences on the role of narrative in political persuasion; include no obstante, asimismo, cabe señalar.',
          'Critically evaluate, in 6 sentences, the difference between persuasion and propaganda; include the three connectors.',
          'In formal register, write 6 sentences on whether brevity is the soul of persuasion today; use the three connectors.',
          'Write 6 sentences on the persuasive power of silence and pause; include no obstante, asimismo, cabe señalar.'],
    -- 10: Advanced Literature
    array['Write 6 sentences on whether literary canon is a tool of cultural power; use no obstante, asimismo, cabe señalar.',
          'Critically evaluate, in 6 sentences, the role of magical realism today; include the three connectors.',
          'In a formal tone, write 6 sentences on the politics of translation in Latin American literature; use the three connectors.',
          'Write 6 sentences on whether contemporary novels can match the cultural weight of the Boom generation; include the three connectors.',
          'Critically evaluate, in 6 sentences, the renewal of poetry by digital platforms; use no obstante, asimismo, cabe señalar.',
          'In formal register, write 6 sentences on the future of long-form fiction in the attention economy; include the three connectors.',
          'Write 6 sentences on the ethics of biographers writing about living subjects; use no obstante, asimismo, cabe señalar.'],
    -- 11: Complex Grammar Structures (tier 3, 7-8 sentences with subjunctive + conditional perfect)
    array['Write 7-8 sentences on how Spanish would have evolved had Latin America gained independence later; use subjunctive and "habría + past participle".',
          'In 7-8 sentences, argue what Spanish syntax would have looked like had the Royal Spanish Academy never existed; use subjunctive and conditional perfect.',
          'Write 7-8 sentences on how literacy would have progressed had education been free since the nineteenth century; subjunctive + conditional perfect.',
          'In 7-8 sentences, discuss what would have happened if the subjunctive had disappeared from Spanish, using subjunctive and conditional perfect.',
          'Write 7-8 sentences on what would have changed had the printing press arrived earlier in Spanish-speaking America; subjunctive + conditional perfect.',
          'In 7-8 sentences, argue what the language would have lost had Cervantes never written; use subjunctive and conditional perfect.',
          'Write 7-8 sentences on how Spanish would have spread had Spain lost the colonial wars; subjunctive + conditional perfect required.'],
    -- 12: Regional Dialects
    array['Write 7-8 sentences on how Spanish would have evolved had no standard variety been imposed; use subjunctive and conditional perfect.',
          'In 7-8 sentences, argue what would have happened if Andalusian Spanish had become the prestige variety; subjunctive + conditional perfect.',
          'Write 7-8 sentences on what would have changed had Rioplatense voseo become the norm worldwide; subjunctive + conditional perfect.',
          'In 7-8 sentences, discuss what Spanish would have lost had regional dialects been suppressed harder; subjunctive + conditional perfect.',
          'Write 7-8 sentences on how identity would have been shaped had local words replaced peninsular ones; subjunctive + conditional perfect.',
          'In 7-8 sentences, argue what would have happened if Mexican Spanish dominated all media in the Americas; subjunctive + conditional perfect.',
          'Write 7-8 sentences on how Spanish would have integrated indigenous languages had policy been different; subjunctive + conditional perfect.'],
    -- 13: Slang & Informal Language
    array['Write 7-8 sentences on how Spanish would have changed had youth slang spread faster before social media; subjunctive + conditional perfect.',
          'In 7-8 sentences, argue what would have happened if school had embraced informal Spanish; subjunctive + conditional perfect.',
          'Write 7-8 sentences on how Spanish would sound today had reggaetón never become mainstream; subjunctive + conditional perfect.',
          'In 7-8 sentences, discuss what would have changed had English loanwords been banned from Spanish; subjunctive + conditional perfect.',
          'Write 7-8 sentences on how slang would have developed had the Internet never existed; subjunctive + conditional perfect.',
          'In 7-8 sentences, argue what would have happened if RAE had recognised every slang term immediately; subjunctive + conditional perfect.',
          'Write 7-8 sentences on how Spanish humour would have evolved had television been the only mass medium; subjunctive + conditional perfect.'],
    -- 14: Translation Skills
    array['Write 7-8 sentences on what literature would have lost had nobody translated García Márquez; subjunctive + conditional perfect.',
          'In 7-8 sentences, argue what would have happened if machine translation had arrived a century earlier; subjunctive + conditional perfect.',
          'Write 7-8 sentences on how international diplomacy would have changed had interpreters been better paid; subjunctive + conditional perfect.',
          'In 7-8 sentences, discuss what publishing would look like had every book been translated immediately; subjunctive + conditional perfect.',
          'Write 7-8 sentences on what cinema would have lost had subtitles been forbidden; subjunctive + conditional perfect.',
          'In 7-8 sentences, argue what would have happened if professional translators had unionised earlier; subjunctive + conditional perfect.',
          'Write 7-8 sentences on how poetry translation would have evolved had AI tools matured; subjunctive + conditional perfect.'],
    -- 15: Language Teaching
    array['Write 7-8 sentences on what Spanish teaching would look like had communicative methodology never appeared; subjunctive + conditional perfect.',
          'In 7-8 sentences, argue what would have happened if schools had taught Spanish through immersion only; subjunctive + conditional perfect.',
          'Write 7-8 sentences on how literacy in Spanish would have spread had public radio invested more in education; subjunctive + conditional perfect.',
          'In 7-8 sentences, discuss what teacher training would look like had universities prioritised it; subjunctive + conditional perfect.',
          'Write 7-8 sentences on what would have happened if AI tutors had replaced live teachers a decade ago; subjunctive + conditional perfect.',
          'In 7-8 sentences, argue what we would have learned faster had grammar been taught later; subjunctive + conditional perfect.',
          'Write 7-8 sentences on how language teaching would have evolved had governments invested in bilingual education; subjunctive + conditional perfect.']
  ];

  -- 7 speaking topic prompts per section
  speaking_prompts text[][] := array[
    -- 1: Idioms & Expressions (tier 1, 6 sentences with idiomatic mastery)
    array['Discuss whether mastery of idioms defines true fluency. 6 sentences, formal register and at least one Spanish idiom.',
          'Talk about a Spanish idiom that fascinated you and what it reveals. 6 sentences with sophisticated vocabulary.',
          'Discuss how to teach idioms without making them feel artificial. 6 sentences in formal register.',
          'Argue whether journalists should use idioms or avoid them. 6 sentences with idiomatic language.',
          'Talk about regional Spanish idioms that confused you abroad. 6 sentences with rhetorical flair.',
          'Discuss the disappearance of certain "refranes" in modern Spanish. 6 sentences in academic register.',
          'Talk about whether AI translators can ever master Spanish idioms. 6 sentences using sophisticated connectors.'],
    -- 2: Advanced Grammar
    array['Discuss whether prescriptive grammar still matters in modern Spanish. 6 sentences in formal register.',
          'Argue whether young Spanish speakers use less subjunctive and what it implies. 6 sentences with precise vocabulary.',
          'Talk about the future subjunctive: relic or potential resource. 6 sentences with rhetorical density.',
          'Discuss descriptive vs prescriptive grammar pedagogy. 6 sentences in academic register.',
          'Talk about how social media is reshaping written Spanish. 6 sentences with cultural awareness.',
          'Discuss teaching ser vs estar to advanced learners. 6 sentences with examples.',
          'Argue the place of dictation in advanced grammar classes. 6 sentences with idiomatic mastery.'],
    -- 3: Formal Writing
    array['Discuss the importance of formal Spanish in international diplomacy. 6 sentences in formal register.',
          'Talk about whether emails have killed the formal letter. 6 sentences with discourse markers.',
          'Discuss the influence of English business jargon on Spanish corporate writing. 6 sentences in formal register.',
          'Argue about register in academic publication. 6 sentences with sophistication.',
          'Talk about plain-language reform in legal Spanish. 6 sentences with idiomatic mastery.',
          'Discuss the cultural weight of "usted" in professional Spanish today. 6 sentences in formal register.',
          'Talk about whether formal Spanish is disappearing among young professionals. 6 sentences with cultural depth.'],
    -- 4: Debate & Discussion
    array['Discuss whether debate skills should be taught in every school. 6 sentences with rhetorical density.',
          'Argue whether televised debates educate or polarise. 6 sentences in formal register.',
          'Talk about the role of moderators in political debate. 6 sentences with precise vocabulary.',
          'Discuss whether online comments are real debate or noise. 6 sentences in academic register.',
          'Talk about the disappearance of long-form debate in mass media. 6 sentences with rhetorical flair.',
          'Discuss silence and pause as debate strategies. 6 sentences in formal register.',
          'Talk about the value of cross-party university debate clubs. 6 sentences in formal register.'],
    -- 5: Native Content
    array['Discuss the role of native content in achieving fluency. 6 sentences in formal register.',
          'Talk about whether dubbed series help or hurt learners. 6 sentences with sophisticated vocabulary.',
          'Discuss the explosion of Spanish-language podcasts. 6 sentences in formal register.',
          'Talk about the cultural impact of Latin American streaming originals. 6 sentences with rhetorical flair.',
          'Discuss the difficulty of regional Spanish accents on TV. 6 sentences with cultural awareness.',
          'Argue whether subtitles delay or accelerate fluency. 6 sentences in academic register.',
          'Talk about how YouTube creators shape modern Spanish usage. 6 sentences with idiomatic mastery.'],
    -- 6: Academic Language (tier 2, 6-7 sentences with no obstante / asimismo / cabe señalar)
    array['Discuss the limits of academic neutrality. 6-7 sentences using no obstante, asimismo and cabe señalar.',
          'Talk about jargon in academic Spanish; pros and cons. 6-7 sentences with the three connectors.',
          'Discuss whether open access damages traditional publishers. 6-7 sentences with the three connectors.',
          'Argue the pressure to publish in English among Hispanic academics. 6-7 sentences with the three connectors.',
          'Discuss the role of peer review in modern science. 6-7 sentences in academic register.',
          'Talk about the rise of preprint servers. 6-7 sentences with sophisticated discourse markers.',
          'Discuss writing classes for non-native Spanish-speaking academics. 6-7 sentences with the three connectors.'],
    -- 7: Professional Communication
    array['Discuss whether brevity is undervalued in professional emails. 6-7 sentences using no obstante, asimismo, cabe señalar.',
          'Talk about how remote work has reshaped professional Spanish. 6-7 sentences with the three connectors.',
          'Discuss the proper use of "usted" in modern Spanish workplaces. 6-7 sentences with the three connectors.',
          'Argue whether English business jargon should be resisted. 6-7 sentences with the three connectors.',
          'Talk about LinkedIn writing as professional identity. 6-7 sentences with discourse markers.',
          'Discuss how to deliver difficult feedback in Spanish. 6-7 sentences in formal register.',
          'Talk about cross-cultural professional communication. 6-7 sentences with the three connectors.'],
    -- 8: Cultural Nuance
    array['Discuss whether cultural nuance can be fully taught. 6-7 sentences using no obstante, asimismo, cabe señalar.',
          'Talk about cultural intelligence in international business. 6-7 sentences in formal register.',
          'Discuss whether globalisation flattens cultural nuance. 6-7 sentences with the three connectors.',
          'Talk about humour as a cultural marker in Spanish. 6-7 sentences with sophisticated examples.',
          'Discuss the difficulty of conveying irony across cultures. 6-7 sentences with the three connectors.',
          'Talk about cultural code-switching in bilinguals. 6-7 sentences with cultural depth.',
          'Discuss the cultural weight of Spanish family vocabulary. 6-7 sentences with discourse markers.'],
    -- 9: Rhetoric & Persuasion
    array['Discuss the ethics of rhetorical manipulation. 6-7 sentences with the three connectors.',
          'Talk about classical rhetoric in modern campaigns. 6-7 sentences in formal register.',
          'Discuss whether emotional appeals undermine reasoned debate. 6-7 sentences with discourse markers.',
          'Talk about the role of narrative in political persuasion. 6-7 sentences with the three connectors.',
          'Discuss the difference between persuasion and propaganda. 6-7 sentences in academic register.',
          'Argue whether brevity is the soul of persuasion today. 6-7 sentences with rhetorical flair.',
          'Talk about the persuasive power of silence and pause. 6-7 sentences with the three connectors.'],
    -- 10: Advanced Literature
    array['Discuss whether the literary canon is a tool of cultural power. 6-7 sentences in formal register.',
          'Talk about magical realism and its place today. 6-7 sentences with the three connectors.',
          'Discuss the politics of translating Latin American literature. 6-7 sentences with cultural depth.',
          'Argue whether contemporary novels can match the Boom generation. 6-7 sentences with discourse markers.',
          'Talk about digital platforms renewing poetry. 6-7 sentences with the three connectors.',
          'Discuss the future of long-form fiction in the attention economy. 6-7 sentences with idiomatic mastery.',
          'Talk about the ethics of biographers writing about living subjects. 6-7 sentences with discourse markers.'],
    -- 11: Complex Grammar Structures (tier 3, 7-8 sentences with subjunctive + conditional perfect)
    array['Discuss how Spanish would have evolved had Latin America gained independence later. 7-8 sentences using subjunctive and conditional perfect.',
          'Argue what Spanish syntax would have looked like had the RAE never existed. 7-8 sentences with subjunctive and habría + ppt.',
          'Discuss what literacy in Spanish would have looked like had education been free in the 19th century. 7-8 sentences.',
          'Talk about what would have happened if the subjunctive had disappeared. 7-8 sentences with subjunctive and conditional perfect.',
          'Discuss what would have changed had the printing press arrived earlier in Latin America. 7-8 sentences.',
          'Argue what the language would have lost had Cervantes never written. 7-8 sentences with subjunctive and conditional perfect.',
          'Discuss how Spanish would have spread had Spain lost its colonial wars. 7-8 sentences.'],
    -- 12: Regional Dialects
    array['Discuss how Spanish would have evolved without a standard variety. 7-8 sentences with subjunctive and conditional perfect.',
          'Argue what would have happened if Andalusian Spanish had become prestige. 7-8 sentences.',
          'Discuss what would have changed had Rioplatense voseo become global. 7-8 sentences with subjunctive and conditional perfect.',
          'Talk about what Spanish would have lost had regional dialects been suppressed harder. 7-8 sentences.',
          'Discuss how identity would have been shaped had local words replaced peninsular ones. 7-8 sentences.',
          'Argue what would have happened if Mexican Spanish dominated media in the Americas. 7-8 sentences.',
          'Discuss how Spanish would have integrated indigenous languages with different policy. 7-8 sentences.'],
    -- 13: Slang & Informal Language
    array['Discuss how Spanish slang would have evolved without social media. 7-8 sentences with subjunctive and conditional perfect.',
          'Argue what would have happened if schools had embraced informal Spanish. 7-8 sentences.',
          'Discuss how Spanish would sound today had reggaetón never become mainstream. 7-8 sentences.',
          'Talk about what would have changed had English loanwords been banned from Spanish. 7-8 sentences.',
          'Discuss how slang would have developed had the Internet never existed. 7-8 sentences with subjunctive and conditional perfect.',
          'Argue what would have happened if RAE had recognised every slang term immediately. 7-8 sentences.',
          'Discuss how Spanish humour would have evolved had TV been the only mass medium. 7-8 sentences.'],
    -- 14: Translation Skills
    array['Discuss what literature would have lost had nobody translated García Márquez. 7-8 sentences with subjunctive and conditional perfect.',
          'Argue what would have happened if machine translation had arrived a century earlier. 7-8 sentences.',
          'Discuss how diplomacy would have changed had interpreters been better paid. 7-8 sentences.',
          'Talk about what publishing would look like had every book been translated immediately. 7-8 sentences.',
          'Discuss what cinema would have lost had subtitles been forbidden. 7-8 sentences with subjunctive and conditional perfect.',
          'Argue what would have happened if translators had unionised earlier. 7-8 sentences.',
          'Discuss how poetry translation would have evolved with mature AI tools earlier. 7-8 sentences.'],
    -- 15: Language Teaching
    array['Discuss what Spanish teaching would look like had communicative methodology never appeared. 7-8 sentences with subjunctive and conditional perfect.',
          'Argue what would have happened if schools had taught Spanish through immersion only. 7-8 sentences.',
          'Discuss how literacy in Spanish would have spread had public radio invested more in education. 7-8 sentences.',
          'Talk about what teacher training would look like had universities prioritised it. 7-8 sentences.',
          'Discuss what would have happened if AI tutors had replaced live teachers a decade ago. 7-8 sentences.',
          'Argue what we would have learned faster had grammar been taught later in the curriculum. 7-8 sentences.',
          'Discuss how language teaching would have evolved had governments invested heavily in bilingual education. 7-8 sentences.']
  ];

  -- Spanish audio: near-native speed monologue / news / debate.
  -- User types 4-5 sentence response critically engaging with implicit
  -- meaning, tone, bias and register shifts.
  listening_audio text[][] := array[
    -- 1: Idioms & Expressions
    array['Una lingüista comentó en la radio que el día que el español pierda sus refranes será cuando deje de pensar por sí mismo. ¿Qué crees que insinúa con esa imagen tan tajante?',
          'En un debate académico, un profesor afirmó que las "frases hechas" son la huella digital de una cultura, no un adorno literario. ¿Hasta qué punto te convence su tesis?',
          'Un periodista veterano dijo, casi con sarcasmo, que la prensa actual se ha vuelto alérgica a los modismos por miedo a parecer poco profesional. ¿Cómo interpretas ese tono?',
          'Una traductora literaria admitió en una entrevista que un buen traductor no traduce idiomas, traduce intuiciones culturales. ¿Qué consecuencia práctica tiene esa afirmación?',
          'En una conferencia, una filóloga sostuvo que las variantes regionales del español enriquecen el idioma, pero también fragmentan la conciencia común. ¿Detectas alguna ambigüedad deliberada en su postura?',
          'Un escritor reciente afirmó que escribir hoy sin "frases hechas" es como cocinar sin sal: técnicamente posible, gastronómicamente triste. ¿Cómo valoras la fuerza retórica de su comparación?',
          'Una experta en IA dijo que las máquinas traducirán cualquier cosa salvo el chiste, porque el humor es un idioma propio. ¿Crees que está exagerando o tocando un punto serio?'],
    -- 2: Advanced Grammar
    array['Un académico de la RAE comentó con cierta resignación que la gramática prescriptiva ha pasado de ser ley a ser sugerencia. ¿Qué tono percibes y qué postula realmente?',
          'Una profesora universitaria afirmó que los jóvenes no usan menos subjuntivo, sino que lo usan en contextos distintos a los que la norma describe. ¿Cómo evalúas su matiz?',
          'Un lingüista dijo, no sin nostalgia, que el futuro de subjuntivo es como un fósil hermoso que ya nadie sabe pronunciar. ¿Qué actitud transmite con esa metáfora?',
          'Una pedagoga sostuvo que enseñar gramática descriptiva es más honesto, pero también más exigente para el profesor. ¿Qué tensión introduce ese matiz?',
          'Un sociolingüista observó que las redes están democratizando el español pero también empobreciendo su variedad sintáctica. ¿Detectas alguna paradoja en esa observación?',
          'Una profesora de ELE confesó que la diferencia entre ser y estar la sigue explicando "a oído" porque ninguna regla lo cubre todo. ¿Cómo interpretas ese reconocimiento?',
          'En una mesa redonda, una académica insistió en que renunciar al dictado fue un error pedagógico que aún pagamos. ¿Cómo valoras la fuerza de su afirmación?'],
    -- 3: Formal Writing
    array['Una diplomática señaló que el español formal sigue siendo el último refugio de la diplomacia multilateral. ¿Qué problema deja entrever esa frase?',
          'Un consultor afirmó, con cierta ironía, que el correo electrónico ha enterrado la carta formal y, con ella, la elegancia institucional. ¿Cómo lees su tono?',
          'Una traductora corporativa dijo que cada vez encuentra más calcos del inglés en los informes de empresas españolas. ¿Qué cambio cultural describe en realidad?',
          'Un editor académico sostuvo que la mezcla de registros en las tesis denota más prisa que descuido. ¿Qué matiz introduce su análisis?',
          'Una jurista declaró que la "lectura fácil" en el derecho es un avance ético, no una pérdida de rigor. ¿Cómo refutarías a quien diga lo contrario?',
          'Un consultor de comunicación afirmó que evitar el "usted" en la oficina es signo de cercanía, pero también de informalidad excesiva. ¿Detectas alguna contradicción?',
          'Una sociolingüista sostuvo que el español formal está siendo arrinconado por la prisa, no por las modas. ¿Qué implicación social tiene ese diagnóstico?'],
    -- 4: Debate & Discussion
    array['Un profesor afirmó que debatir en la escuela debería ser tan obligatorio como las matemáticas porque enseña a pensar antes que a hablar. ¿Cómo valoras el orden que propone?',
          'Una politóloga sostuvo que los debates televisados no informan, espectacularizan; el formato premia el golpe, no el argumento. ¿Qué tensión describe?',
          'Un moderador veterano dijo, con sorna, que su trabajo se ha reducido a evitar interrupciones, no a profundizar en el debate. ¿Qué crítica más amplia esconde?',
          'Una socióloga comentó que las redes generan ruido, no debate; en pocas plataformas se construye un argumento completo. ¿Cómo interpretas su distinción?',
          'Un crítico mediático afirmó que el formato largo de debate ha desaparecido porque la atención del público ya no lo sostiene. ¿De quién es realmente la culpa, según implica?',
          'Una académica recordó que el silencio en un debate puede ser más persuasivo que cualquier réplica. ¿Qué presupone esa afirmación?',
          'Una rectora dijo que los clubes de debate entre alumnos de partidos rivales son la mejor escuela cívica que existe. ¿Cómo evalúas su entusiasmo?'],
    -- 5: Native Content
    array['Un profesor de ELE comentó que hasta no consumir contenido nativo, ningún alumno alcanza la fluidez real, por avanzado que parezca. ¿Cómo entiendes esa exigencia?',
          'Una traductora audiovisual sostuvo que el doblaje protege al espectador pero hipoteca al estudiante de idiomas. ¿Qué dilema describe?',
          'Un crítico digital afirmó que el auge del podcast en español es un renacimiento del oído, en un mundo dominado por la pantalla. ¿Cómo valoras esa lectura cultural?',
          'Una productora dijo que las series latinoamericanas viajan más lejos que cualquier ministerio de cultura. ¿Qué tipo de poder describe en realidad?',
          'Un periodista comentó, casi con humor, que entender el chileno hablado rápido es un nivel C2 que ningún examen evalúa. ¿Qué problema señala con ironía?',
          'Una pedagoga sostuvo que los subtítulos pueden ser muleta o trampolín, según cómo se usen. ¿Cómo interpretas esa imagen?',
          'Un sociolingüista afirmó que los creadores de YouTube están dictando el español neutro de la próxima generación. ¿Te parece una buena noticia o una preocupación?'],
    -- 6: Academic Language
    array['Una profesora universitaria sostuvo que la neutralidad académica es un mito útil pero peligroso porque oculta los presupuestos del investigador. ¿Cómo interpretas su provocación?',
          'Un editor académico afirmó que la jerga no es siempre opacidad: a veces es precisión que los profanos confunden con humo. ¿Qué tensión describe?',
          'Una bibliotecaria sostuvo que el open access redistribuye el saber pero también desestabiliza el modelo económico que lo sostiene. ¿Cómo evalúas esa paradoja?',
          'Una académica chilena dijo que publicar en inglés es hoy una condición sine qua non para existir académicamente, aunque eso empobrezca el debate en español. ¿Qué denuncia?',
          'Un experto en metaciencia sostuvo que el peer review es un mecanismo lento que, sin embargo, sigue siendo el menos malo. ¿Cómo entiendes esa concesión?',
          'Una investigadora afirmó que los servidores de preimpresión aceleran la ciencia pero también propagan errores no corregidos. ¿Qué tensión describe?',
          'Un coordinador de doctorado sostuvo que la escritura académica debería enseñarse explícitamente desde el primer año. ¿Por qué crees que insiste en este punto?'],
    -- 7: Professional Communication
    array['Una directora ejecutiva afirmó que la brevedad en los correos profesionales es señal de respeto al tiempo del lector. ¿Hasta qué punto compartes su postura?',
          'Una consultora dijo que el teletrabajo ha reescrito las reglas no escritas del español laboral, especialmente en la formalidad. ¿Qué cambio cultural intuyes?',
          'Un empresario veterano sostuvo que perder el "usted" en la oficina ha rebajado las jerarquías pero también ha aumentado la confusión. ¿Cómo evalúas su lectura?',
          'Una experta en comunicación corporativa criticó la invasión de "engagement", "feedback" y "stakeholders" en el español de negocios. ¿Qué problema cultural describe?',
          'Un director de marca dijo que LinkedIn ha convertido el español profesional en marketing personal continuo. ¿Cómo interpretas su tono?',
          'Una coach laboral sostuvo que dar malas noticias en español requiere más cuidado que en inglés porque la cultura espera más rodeo. ¿Estás de acuerdo?',
          'Un consultor internacional afirmó que la comunicación entre culturas hispanohablantes es a veces más compleja que con angloparlantes. ¿Por qué crees que lo plantea así?'],
    -- 8: Cultural Nuance
    array['Una antropóloga sostuvo que el matiz cultural no se enseña: se aprende viviendo, fallando y rectificando. ¿Cómo evalúas el rigor de esa idea?',
          'Una consultora intercultural afirmó que la inteligencia cultural se está convirtiendo en la habilidad más rentable del siglo XXI. ¿Qué cambio anuncia?',
          'Un sociólogo dijo, casi con melancolía, que la globalización no destruye las culturas, las exporta sin contexto. ¿Qué matiz crítico introduce?',
          'Un humorista español señaló que el humor es la última frontera que un extranjero atraviesa al aprender un idioma. ¿Cómo interpretas esa afirmación?',
          'Una traductora literaria sostuvo que la ironía es lo primero que se pierde en cualquier traducción al español. ¿Por qué crees que ocurre eso?',
          'Una bilingüe colombiana afirmó que cambiar de idioma es cambiar de personalidad, no solo de lengua. ¿Hasta qué punto coincide con tu experiencia?',
          'Una antropóloga dijo que el español tiene más palabras para el parentesco que la mayoría de idiomas, y eso revela una cultura. ¿Cómo amplías esa observación?'],
    -- 9: Rhetoric & Persuasion
    array['Un filósofo afirmó que toda persuasión bordea la manipulación; la línea ética la marca el respeto a la autonomía del otro. ¿Cómo valoras su criterio?',
          'Una profesora de comunicación dijo que la retórica clásica sigue gobernando las campañas modernas, aunque con disfraz tecnológico. ¿Qué continuidad subraya?',
          'Una analista política sostuvo que apelar a la emoción no es manipular, siempre que los datos también estén presentes. ¿Qué condición plantea?',
          'Una escritora dijo que la narrativa siempre vence al dato, aunque el dato esté de su lado. ¿Cómo interpretas su pesimismo elegante?',
          'Un crítico mediático afirmó que la diferencia entre persuasión y propaganda está en si te permite cambiar de opinión después. ¿Cómo evalúas ese criterio?',
          'Una oradora veterana dijo que la persuasión moderna se reduce a captar la atención cinco segundos más que el rival. ¿Qué crítica formula?',
          'Un experto en retórica afirmó que el silencio bien colocado convence más que diez argumentos juntos. ¿Por qué crees que insiste en esto?'],
    -- 10: Advanced Literature
    array['Una catedrática afirmó que el canon literario es un acto de poder cultural, no un descubrimiento natural de la calidad. ¿Cómo interpretas esa tesis?',
          'Un escritor latinoamericano sostuvo que el realismo mágico se ha convertido en cliché exportable más que en estética viva. ¿Qué denuncia?',
          'Una traductora afirmó que traducir literatura latinoamericana es traducir también su política, queriendo o no. ¿Qué implicación ética sugiere?',
          'Un crítico literario dijo que ninguna generación posterior al Boom ha alcanzado su peso simbólico, aunque haya alcanzado su técnica. ¿Cómo evalúas esa distinción?',
          'Una poeta sostuvo que las redes han revitalizado la poesía y la han banalizado a partes iguales. ¿Cómo entiendes esa paradoja?',
          'Un editor afirmó que la novela larga sobrevivirá, pero solo en lectores dispuestos a perder eficiencia. ¿Qué cambio cultural describe?',
          'Una biógrafa dijo que escribir sobre personas vivas exige una ética distinta a la del historiador. ¿Por qué insiste en esa distinción?'],
    -- 11: Complex Grammar Structures
    array['Un lingüista comentó que si las independencias hispanoamericanas hubieran llegado más tarde, el español habría desarrollado normas más fragmentadas pero también más estables localmente. ¿Cómo valoras esa hipótesis?',
          'Una académica sostuvo que sin la RAE, la sintaxis del español se habría diversificado mucho más rápido, aunque también se habría perdido cohesión escrita. ¿Qué tensión describe?',
          'Un historiador afirmó que si la educación gratuita hubiera llegado en el siglo XIX, la alfabetización en español habría sido masiva mucho antes. ¿Qué consecuencia política implica?',
          'Un gramático dijo, con humor, que si el subjuntivo hubiera desaparecido, habríamos perdido medio Cervantes y todo Borges. ¿Cómo entiendes esa hipérbole?',
          'Una historiadora del libro sostuvo que si la imprenta hubiera llegado antes a América, las literaturas locales habrían ganado peso frente a la metrópoli. ¿Qué cambio cultural sugiere?',
          'Un crítico afirmó que sin Cervantes el español habría tenido novela, pero no su novela; habría sido otro idioma. ¿Cómo valoras esa idea?',
          'Una historiadora dijo que si España hubiera perdido las guerras coloniales antes, el español probablemente no sería hoy la segunda lengua materna del mundo. ¿Qué supone esa afirmación?'],
    -- 12: Regional Dialects
    array['Un lingüista sostuvo que sin variedad estándar el español habría florecido en docenas de dialectos paralelos, igual de legítimos. ¿Cómo evalúas esa hipótesis?',
          'Una sociolingüista afirmó que si el andaluz hubiera sido el prestigio peninsular, las "s" finales y los plurales habrían reescrito toda la enseñanza. ¿Qué cambio cultural implica?',
          'Un experto en variedades del español dijo que si el voseo rioplatense se hubiera globalizado, "tú eres" sería hoy una rareza. ¿Cómo interpretas su provocación?',
          'Una activista lingüística sostuvo que si los dialectos hubieran sido suprimidos con más fuerza, el español de hoy sería más homogéneo pero infinitamente más pobre. ¿Qué denuncia?',
          'Un sociolingüista afirmó que si el léxico local hubiera ocupado más espacio en la prensa, la identidad regional habría tenido otro peso en política. ¿Cómo entiendes esa relación?',
          'Un crítico cultural dijo que si el mexicano hubiera dominado los medios, el continente entero hablaría con cadencia chilanga sin darse cuenta. ¿Qué exagera, qué intuye?',
          'Una lingüista indigenista sostuvo que con una política diferente, el español habría absorbido mucho más léxico de las lenguas originarias, enriqueciéndose enormemente. ¿Qué pérdida lamenta?'],
    -- 13: Slang & Informal Language
    array['Un lingüista afirmó que sin redes sociales el argot juvenil habría tardado décadas en cruzar océanos, no semanas. ¿Cómo evalúas el alcance de esa afirmación?',
          'Una pedagoga sostuvo que si la escuela hubiera abierto sus puertas al argot, los alumnos habrían sentido que el aula también era su lengua. ¿Qué cambio educativo implica?',
          'Un musicólogo dijo que sin reggaetón, el español global habría sonado bastante distinto y con menos ritmo caribeño. ¿Cómo interpretas esa observación?',
          'Un purista afirmó que si los anglicismos hubieran sido prohibidos, el español habría sobrevivido pero habría perdido capacidad de innovación rápida. ¿Cómo valoras su matiz?',
          'Un sociolingüista dijo que sin Internet, el argot habría seguido viviendo, pero solo en la calle de cada barrio. ¿Qué cambio describe?',
          'Una académica afirmó que si la RAE hubiera reconocido cada término popular al instante, el diccionario habría perdido autoridad. ¿Qué dilema institucional plantea?',
          'Un crítico de cultura popular sostuvo que sin televisión, el humor hispanohablante se habría quedado regional y fragmentario. ¿Qué cambio anticipa?'],
    -- 14: Translation Skills
    array['Una crítica literaria afirmó que sin la traducción al inglés, García Márquez habría sido un fenómeno latinoamericano, no global. ¿Cómo valoras su afirmación?',
          'Un experto en traducción automática dijo que si las máquinas hubieran madurado un siglo antes, el oficio del traductor literario habría tenido que reinventarse mucho antes. ¿Qué cambio anticipa?',
          'Un diplomático sostuvo que si los intérpretes hubieran sido mejor pagados, también habrían sido mejor formados y los conflictos habrían sido menos. ¿Cómo evalúas esa cadena causal?',
          'Una editora afirmó que si cada libro se hubiera traducido al instante, el mercado se habría democratizado, pero los lectores habrían perdido la noción de espera. ¿Qué pérdida cultural sugiere?',
          'Un cineasta dijo que sin subtítulos el cine extranjero habría seguido siendo nicho, no fenómeno popular. ¿Cómo entiendes su afirmación?',
          'Una sindicalista afirmó que si los traductores se hubieran sindicalizado antes, hoy no estarían cobrando como en los años noventa. ¿Qué denuncia?',
          'Un poeta dijo que si la IA hubiera madurado antes, la traducción poética habría llegado al gran público, aunque acompañada de pérdidas evidentes. ¿Cómo valoras esa concesión?'],
    -- 15: Language Teaching
    array['Un profesor afirmó que sin la metodología comunicativa, todavía estaríamos enseñando español como si fuera latín. ¿Qué cambio histórico describe?',
          'Una pedagoga dijo que si las escuelas hubieran apostado por la inmersión total, la calidad de aprendizaje habría sido muy superior, aunque más excluyente al inicio. ¿Qué tensión plantea?',
          'Un divulgador afirmó que si la radio pública hubiera invertido más en alfabetización, comunidades enteras habrían accedido al español culto sin pasar por la escuela formal. ¿Qué oportunidad describe?',
          'Una decana sostuvo que si la formación docente hubiera sido prioridad universitaria, la enseñanza del español habría dado un salto generacional. ¿Cómo evalúas esa lectura?',
          'Un experto en IA educativa dijo que si los tutores artificiales hubieran reemplazado a los profesores hace una década, habríamos descubierto rápido que la fluidez es relación, no solo información. ¿Cómo entiendes esa idea?',
          'Una profesora veterana afirmó que si la gramática se hubiera enseñado más tarde, los alumnos habrían hablado antes y mejor. ¿Por qué crees que insiste en este orden?',
          'Un ministro de educación dijo que si los gobiernos hubieran invertido seriamente en bilingüismo, la región entera habría sido más competitiva en el mundo. ¿Qué oportunidad lamenta perdida?']
  ];

  -- Reference Spanish responses for AI grading context (4-5 sentences,
  -- critical engagement with implicit meaning / tone / register / bias)
  listening_reference text[][] := array[
    -- 1
    array['Insinúa que el refranero no es ornamento, sino estructura cognitiva: perderlo equivaldría a perder los atajos colectivos para razonar sobre la vida. Su afirmación, aun siendo tajante, apunta a un fenómeno real: cuando una cultura abandona sus dichos, suele empobrecer también su pensamiento cotidiano.',
          'Me convence en parte. Las "frases hechas" condensan visiones del mundo y muestran cómo cierta comunidad ha resuelto, durante siglos, las preguntas esenciales. No obstante, llamarlas "huella digital" puede sonar excesivo si olvidamos que también son patrimonio cambiante, no estático.',
          'Su tono es irónico y, en el fondo, crítico: reprocha al periodismo actual una pulcritud excesiva que se confunde con seriedad. Cabe destacar que esa supuesta neutralidad puede ser, en realidad, una forma de no comprometerse con la cultura que se cuenta.',
          'Implica que la traducción no es transferencia lingüística sino cultural; el traductor opera sobre intuiciones que rara vez aparecen en los diccionarios. La consecuencia práctica es que la formación de traductores debería incluir más antropología y menos lexicografía mecánica.',
          'Detecto una ambigüedad estudiada: defiende las variantes regionales pero sugiere que diluyen una identidad común. Es una postura típicamente filológica: respetar la diversidad sin renunciar a la idea de un español compartido. Su elegancia está justamente en no resolver del todo la tensión.',
          'La comparación es eficaz por su tono cotidiano: equipara la lengua a la cocina, donde la falta de sal arruina el conjunto sin destruirlo. Su fuerza retórica reside en convertir un fenómeno literario en un asunto sensorial y comprensible para cualquiera.',
          'Está tocando un punto serio. El humor depende de connotaciones, ritmo y referencias compartidas que las máquinas todavía no jerarquizan bien. Su afirmación, lejos de ser exagerada, anticipa probablemente la última frontera real de la traducción automática.'],
    -- 2
    array['Percibo cierta resignación combinada con realismo: reconoce que la norma ya no se impone, solo orienta. Cabe destacar que esto no implica caos, sino una redistribución de la autoridad lingüística entre instituciones, medios y hablantes.',
          'Su matiz me parece muy fino. No se trata de pérdida sino de desplazamiento: los jóvenes usan el subjuntivo en otros contextos, sobre todo emocionales. No obstante, ese cambio probablemente reescribirá lo que mañana llamemos "uso correcto".',
          'Transmite una mezcla de admiración y melancolía profesional: el futuro de subjuntivo, dice, sobrevive como reliquia hermosa pero inerte. Asimismo, esa imagen del fósil sugiere que su valor es ya más estético que comunicativo.',
          'Introduce una tensión pedagógica importante: la gramática descriptiva es más honesta pero exige más reflexión del profesor, que pierde su papel de árbitro. Cabe señalar que muchos profesores prefieren la comodidad de la norma, aunque sea simplificadora.',
          'La paradoja es clara: la red multiplica producción escrita y, a la vez, estrecha la variedad sintáctica al imponer formatos cortos. No obstante, hay quien defendería que esa concisión también genera nuevas riquezas en otros niveles.',
          'Reconoce que ninguna explicación formal cubre todos los matices y que la enseñanza acaba siendo, en parte, un trabajo de oído. Asimismo, ese reconocimiento es valioso porque desmitifica la gramática como ciencia exacta.',
          'Su afirmación es contundente y nostálgica a la vez. El dictado entrenaba ortografía, atención y memoria fonológica; su abandono ha empobrecido herramientas básicas. Cabe señalar, sin embargo, que recuperarlo sin actualizarlo sería igualmente un error.'],
    -- 3
    array['Deja entrever que el español formal sobrevive sobre todo por inercia institucional, no por vitalidad real. Cabe destacar que esto plantea la duda de cuánto durará si las propias cancillerías empiezan a renunciar a ese registro.',
          'Su tono es a la vez irónico y nostálgico; lamenta la pérdida de la carta formal como ritual cultural y no solo como soporte. Asimismo, sugiere que la velocidad ha desplazado a la ceremonia, sin que hayamos calibrado bien el coste.',
          'Describe la anglización profunda del español corporativo: no son préstamos puntuales, sino estructuras pensadas en inglés y traducidas mecánicamente. No obstante, parte de la responsabilidad recae en las propias escuelas de negocios.',
          'Introduce un matiz importante: la prisa académica explica mejor la mezcla de registros que la falta de formación. Cabe señalar que esa observación señala un problema sistémico, no individual.',
          'Refutaría diciendo que la "lectura fácil" no diluye el rigor, sino que lo somete a una prueba ética: si el ciudadano no puede entender la norma, el derecho deja de funcionar. Asimismo, claridad y rigor no son enemigos, sino aliados naturales.',
          'Hay una tensión: la cercanía moderna conviene a la cultura de equipo pero erosiona ciertos marcadores de respeto. Cabe destacar que la solución suele estar en mantener "usted" para externos y "tú" para internos, como muchos despachos jurídicos siguen haciendo.',
          'Implica que el problema no es generacional sino económico-cultural: producimos más rápido, no más mal, y eso desplaza la lengua cuidada. Cabe señalar que recuperar tiempo es, en este caso, recuperar registro.'],
    -- 4
    array['Plantea un orden interesante: el debate enseña primero a pensar, después a hablar; la fluencia sin reflexión es elocuencia vacía. Cabe destacar que este enfoque desplazaría el énfasis tradicional en la oratoria pura.',
          'Describe una tensión estructural: el formato favorece el espectáculo, premia interrupciones y soundbites; el argumento largo queda fuera. No obstante, hay precedentes televisivos exitosos que demuestran que se puede educar y entretener a la vez.',
          'Esconde una crítica al sistema: el moderador ha quedado reducido a árbitro de turnos, sin capacidad real de aportar profundidad. Cabe señalar que esto descarga la responsabilidad sobre los políticos, exonerando a los formatos.',
          'Distingue ruido y debate: lo primero es reacción visceral, lo segundo construcción reflexiva. Asimismo, su análisis sugiere que muy pocas plataformas premian la conversación larga y elaborada.',
          'Insinúa una responsabilidad compartida: el público no exige formatos largos y los medios no se atreven a ofrecerlos. Cabe destacar que esa retroalimentación negativa empobrece la cultura cívica con el tiempo.',
          'Presupone que el silencio comunica posición, dominio del tema y respeto al interlocutor. Asimismo, esa idea retoma una tradición clásica que la cultura mediática actual tiende a olvidar.',
          'Su entusiasmo me parece justificado: pocos espacios obligan a defender una postura contraria a la propia con argumentos. No obstante, esta práctica requiere madurez institucional y compromiso docente sostenido.'],
    -- 5
    array['Su exigencia desplaza el centro de gravedad del aprendizaje: la fluidez no se adquiere en el aula, se valida fuera. Cabe destacar que esta postura interpela el papel del profesor, que pasa de proveer contenido a curar caminos.',
          'Describe un dilema interesante: el doblaje hace el cine accesible pero priva al espectador del español original. Asimismo, los estudiantes pierden una fuente de exposición masiva muy difícil de sustituir.',
          'Sugiere un renacimiento auditivo en una época visual. No obstante, conviene matizar que muchos podcasts solo transponen el formato radio, sin explotar las posibilidades del nuevo soporte.',
          'Describe un poder simbólico que los Estados subestiman: la cultura popular exportada construye imagen país sin presupuesto público. Cabe señalar que muchos gobiernos no han entendido aún ese activo.',
          'Su ironía esconde una crítica seria: los exámenes oficiales rara vez evalúan la comprensión real del español rápido y regional. Asimismo, esto crea un desfase entre certificación y competencia comunicativa.',
          'La imagen es exacta: usados con criterio, los subtítulos refuerzan el oído; usados como muleta, lo bloquean. Cabe destacar que la diferencia depende en gran medida de la motivación del aprendiente.',
          'No es una buena ni mala noticia, sino un cambio: los creadores se están convirtiendo en referentes lingüísticos sin formación filológica. Cabe señalar que esto puede empobrecer ciertos registros, pero también introducir innovaciones interesantes.'],
    -- 6
    array['Su provocación señala una verdad incómoda: pretender neutralidad permite no examinar los propios presupuestos. Cabe destacar que reconocer la posición del investigador es más riguroso que esconderla detrás de un lenguaje impersonal.',
          'Su tensión es real. La jerga puede ser precisión técnica o muro contra los profanos; depende del contexto. Asimismo, distinguir ambos usos es responsabilidad de la propia comunidad académica.',
          'Su paradoja es certera: democratiza acceso pero rompe el modelo financiero. No obstante, parte del problema es que ese modelo ya estaba caduco, no que el open access lo destruya.',
          'Denuncia una globalización académica con efectos colaterales: el inglés se impone como condición de visibilidad y empobrece el debate en lenguas locales. Cabe señalar que muchas universidades no incentivan publicar en español de forma seria.',
          'La concesión es prudente: el peer review tiene fallos visibles, pero ninguna alternativa supera su filtro colectivo. Asimismo, conviene reformarlo, no abandonarlo.',
          'Describe una tensión clara: velocidad frente a verificación. No obstante, los preprints están aquí para quedarse; el reto es enseñar al público a leerlos con criterio.',
          'Insiste porque la escritura académica se aprende imitando, y sin enseñanza explícita los doctorandos reproducen vicios. Cabe destacar que una buena formación temprana ahorra años de correcciones después.'],
    -- 7
    array['Comparto su postura. La brevedad cuidada es un acto de respeto y eficacia, no falta de educación. Cabe destacar que muchas culturas asocian brevedad a frialdad; ahí reside la dificultad.',
          'Intuye un cambio cultural profundo: la informalidad del teletrabajo está erosionando registros que antes sostenía el espacio físico. No obstante, ese cambio puede ser una oportunidad para repensar la jerarquía.',
          'Su lectura es ambivalente: gana cercanía pero pierde claridad de roles. Asimismo, muchas empresas ahora viven una etapa de improvisación social que requerirá nuevas normas explícitas.',
          'Describe una colonización lingüística que afecta también al pensamiento: importar las palabras es importar las categorías. Cabe señalar que esto empobrece el debate corporativo en español.',
          'Su tono es crítico. LinkedIn fuerza una performance permanente que poco tiene que ver con la profesionalidad real. Asimismo, la frontera entre marketing personal y reflexión profesional se ha desdibujado.',
          'Estoy de acuerdo en que el español laboral exige más rodeo cultural, especialmente en jerarquías formales. Cabe destacar que ser directo sin parecer brusco es una habilidad muy entrenable.',
          'Lo plantea así porque dentro del mundo hispanohablante coexisten registros, normas de cortesía y ritmos negociadores muy distintos. Cabe señalar que asumir homogeneidad es una de las trampas más comunes.'],
    -- 8
    array['Su rigor es alto. La inteligencia cultural se construye con experiencia y reflexión sostenida; no se transmite en un curso. Cabe destacar que esto desafía a la formación corporativa cortoplacista.',
          'Anuncia un cambio de paradigma: las habilidades duras se automatizan, las blandas se vuelven escasas y costosas. Asimismo, esta tendencia favorece a quienes hayan vivido entre culturas.',
          'Su matiz crítico apunta a la descontextualización: cuando una cultura viaja sin su tejido, se vuelve caricatura. Cabe señalar que la responsabilidad recae también sobre los receptores que la consumen sin profundidad.',
          'Su afirmación es exacta: el humor es la última frontera porque requiere referencias compartidas, oído fonético y conocimiento histórico. Asimismo, dominarlo es lo que separa un nivel C1 alto de un C2 cómodo.',
          'Ocurre porque la ironía vive de matices entonativos y culturales muy locales que el papel borra. Cabe destacar que algunos traductores experimentan con paratextos o notas para conservarla, con resultados desiguales.',
          'Mi experiencia confirma su intuición: cambio de idioma se acompaña de un ligero cambio de personalidad social, especialmente en humor y emoción. No obstante, esto no implica una doble identidad, sino registros distintos.',
          'Su observación se podría ampliar al léxico afectivo y al de comida: el español codifica matices que otras lenguas resuelven con perífrasis. Cabe señalar que esto revela una cultura organizada alrededor de la familia y la mesa.'],
    -- 9
    array['Su criterio es elegante y rigoroso. La autonomía del oyente marca la frontera ética: si la persuasión se basa en evidencia y razones, no la viola; si la elude, la cruza. Cabe destacar que muchas campañas modernas operan precisamente en esa zona gris.',
          'Subraya una continuidad inquietante: las herramientas son nuevas, pero las estrategias son antiguas. Asimismo, eso sugiere que la educación en retórica clásica sigue siendo una defensa eficaz contra la manipulación.',
          'Plantea una condición sensata: emoción y razón no se excluyen si la primera no oculta a la segunda. No obstante, en la práctica muchas campañas ofrecen solo emoción.',
          'Su pesimismo es elegante porque reconoce el poder narrativo sin renunciar al dato. Cabe destacar que su frase implica que un buen comunicador científico debe ser también un buen narrador.',
          'El criterio es atractivo: la propaganda cierra el debate, la persuasión lo abre. Asimismo, distinguir ambas en tiempo real exige educación cívica sostenida.',
          'Formula una crítica al ecosistema de la atención: en ese marco, la profundidad se vuelve desventaja competitiva. Cabe señalar que sin contramedidas culturales, la persuasión seria se marginalizará aún más.',
          'Insiste porque el silencio comunica seguridad, dominio del tema y respeto al interlocutor. Asimismo, en una cultura mediática hiperverbal, callar bien es ya una excentricidad poderosa.'],
    -- 10
    array['Su tesis señala un fenómeno real: el canon no se descubre, se construye, y reproduce relaciones de poder editoriales y académicas. Cabe destacar que esto no invalida las obras, pero relativiza su prestigio absoluto.',
          'Denuncia una folclorización: lo que fue innovación radical hoy se vende como sello de exportación. Asimismo, esa simplificación afecta a la nueva generación de autores latinoamericanos.',
          'Sugiere que el traductor no puede esconder su mirada política; sus decisiones léxicas son ya posicionamientos. Cabe señalar que esto exige más reflexión ética en la formación profesional.',
          'Distingue técnica y peso simbólico: la nueva generación escribe bien, pero falta un proyecto generacional comparable al Boom. Asimismo, esto puede deberse al cambio del mercado editorial.',
          'La paradoja es real. Las redes acercan la poesía a millones, pero también la convierten en producto efímero. Cabe destacar que estos dos efectos coexisten y obligan a redefinir qué entendemos por "buena poesía".',
          'Describe un cambio cultural: leer en profundidad implica renunciar a la eficiencia, y eso ya es contracultural. No obstante, los lectores comprometidos no desaparecen, solo se vuelven minoría más visible.',
          'Insiste en la distinción porque el biógrafo opera sobre una vida en curso, con consecuencias inmediatas. Asimismo, esa ética requiere una doble fidelidad: a la verdad y al respeto a la persona.'],
    -- 11
    array['Su hipótesis es plausible. Una independencia tardía habría dado más tiempo a consolidar normas locales antes de la influencia masiva del inglés. Cabe destacar, no obstante, que también podría haber producido aún más fragmentación.',
          'La tensión descrita es real. Sin RAE habríamos tenido más diversidad pero menos cohesión escrita, y la enseñanza global del español habría sido logísticamente más compleja. Asimismo, esa cohesión es lo que sostiene hoy industrias editoriales y mediáticas continentales.',
          'Implica una consecuencia política poderosa: la alfabetización temprana habría modificado la participación democrática durante un siglo. Cabe señalar que eso seguramente habría reducido brechas que aún hoy padecemos.',
          'La hipérbole revela un dato técnico: sin subjuntivo se pierden matices de irrealidad, deseo y duda. Asimismo, la literatura más sutil dejaría de poder expresar ciertos pliegues internos.',
          'Sugiere un cambio cultural notable: literaturas locales habrían ganado peso editorial antes y la dependencia de la metrópoli habría sido menor. Cabe destacar que la imprenta no solo difunde, también legitima.',
          'Valoro la idea porque señala un hecho real: Cervantes redefinió la prosa, el humor, la voz narrativa. Sin él, otros lo habrían intentado, pero el español habría seguido otro itinerario.',
          'Supone reconocer que la geopolítica determinó la difusión lingüística. Asimismo, esto invita a no leer la expansión del español como simple éxito intrínseco del idioma.'],
    -- 12
    array['Es plausible. Sin variedad estándar habríamos tenido más dialectos paralelos, todos legítimos, pero menos transmisión rápida entre comunidades. Cabe destacar que esto habría planteado retos serios a la enseñanza y los medios.',
          'Implica un cambio mayúsculo: las "s" finales, los plurales y la aspiración habrían reescrito tanto la fonética como la ortografía. Asimismo, la sensación de prestigio asociada hoy al castellano del centro se habría desplazado.',
          'Su provocación me parece útil. Si el voseo hubiera sido la norma global, lo que hoy llamamos "tuteo" sería el rasgo regional. Cabe señalar que esto recuerda lo arbitrario que es el prestigio lingüístico.',
          'Denuncia una pérdida que pocas veces se mide. La supresión más dura habría producido un idioma cohesionado pero monocromo. Asimismo, los dialectos almacenan léxico que ningún diccionario único puede sostener.',
          'La relación es real. El léxico local es identidad: nombrar las cosas con palabras propias refuerza la pertenencia regional y, con ella, la presencia política. Cabe destacar que esta dimensión rara vez se discute en debates lingüísticos.',
          'Exagera un poco pero acierta en el fondo. La cadencia chilanga impone ritmo, vocabulario y expresiones; las series mexicanas ya influyen en jóvenes de toda la región. Asimismo, esa "neutralización" tiene también costes culturales.',
          'Lamenta una oportunidad perdida. El español habría sido aún más rico léxica y conceptualmente si las lenguas originarias hubieran sido reconocidas en igualdad. Cabe señalar que aún hoy se podrían dar pasos en esa dirección.'],
    -- 13
    array['Su afirmación es acertada. Sin redes, una expresión madrileña habría tardado años en llegar a Buenos Aires; ahora basta un viral. Cabe destacar que esto produce un argot común que era impensable hace una década.',
          'Describe un cambio educativo profundo. Reconocer el argot escolar habría reducido la sensación de exclusión que sienten muchos alumnos. Asimismo, también plantea el riesgo de "academizar" lo que vive de su carácter espontáneo.',
          'Es cierto. El reggaetón ha aportado vocabulario, ritmo y léxico afectivo que ya forman parte del español global. Sin él, otra música ocuparía ese lugar, pero el efecto léxico habría sido distinto.',
          'Su matiz es justo: prohibir anglicismos no salva un idioma, lo empobrece. Asimismo, la salud de una lengua se mide por su capacidad de absorber sin perder identidad.',
          'Describe una vida más fragmentada del argot: cada barrio con su jerga, sin gran circulación nacional. Cabe destacar que esto habría conservado más diversidad léxica pero limitado el sentimiento de comunidad joven panhispánica.',
          'Plantea un dilema institucional real. Reconocer todo al instante haría la norma indistinguible del uso, y la propia idea de "diccionario" perdería su función orientadora. No obstante, demorar demasiado también deslegitima a la RAE.',
          'Es plausible. Sin la difusión nacional de la televisión, el humor habría seguido siendo regional, con menos referentes compartidos. Cabe señalar que esto habría afectado también la unidad cultural moderna.'],
    -- 14
    array['Su afirmación es plausible pero matizable. Sin traducción al inglés, su impacto global habría sido menor, pero el realismo mágico ya tenía circuito propio. Cabe destacar, además, que el premio Nobel habría dependido mucho más de los lectores en español.',
          'Anticipa un cambio profundo. La maduración temprana de la traducción automática habría obligado a redefinir el oficio hace cien años, no ahora. Asimismo, probablemente habríamos perdido toda una generación de traductores literarios formados artesanalmente.',
          'La cadena causal es discutible pero interesante. Mejor formación reduce errores en cumbres, y eso baja la temperatura de conflictos. Cabe señalar, no obstante, que muchos conflictos modernos exceden el alcance de cualquier intérprete.',
          'Sugiere una pérdida cultural muy real: la espera era parte de la experiencia lectora, y eliminarla habría reducido la jerarquía de atención. Asimismo, la traducción tardía mantenía cierta diversidad temporal entre culturas.',
          'Su afirmación es exacta. El subtítulo permitió que el cine extranjero saliera del nicho cultural. Cabe destacar que también acostumbró al espectador a escuchar otros idiomas, lo cual ha tenido beneficios pedagógicos enormes.',
          'Denuncia una asimetría persistente: la traducción está mejor reconocida culturalmente que económicamente. Asimismo, sin sindicalización, los honorarios apenas han subido durante décadas.',
          'La concesión me parece honesta: la IA democratiza la traducción poética, pero las pérdidas son evidentes en ritmo y connotación. Cabe destacar que muchos lectores las aceptarán a cambio de acceso, lo cual reabre un viejo debate ético.'],
    -- 15
    array['Describe un cambio histórico importante. La comunicación, no la gramática aislada, transformó la enseñanza moderna del español. Cabe destacar que el peso de esa metodología sigue vigente aunque ya esté en revisión.',
          'Su tensión es real. La inmersión total produce mejor competencia pero excluye a quienes no pueden acceder a entornos suficientemente densos en español. Asimismo, mezclar inmersión con apoyo metalingüístico parece hoy más realista.',
          'Describe una oportunidad histórica perdida. La radio pública alfabetizó países enteros en otros idiomas; en español no se aprovechó al mismo nivel. Cabe señalar que esta lección sigue siendo válida para la radio digital actual.',
          'Comparto su lectura. La calidad docente determina mucho más que el currículum; sin formación seria, cualquier reforma se queda en papel. Cabe destacar que esa inversión universitaria suele ser políticamente poco visible.',
          'Su idea es lúcida. La fluidez se construye en relación, no solo recibiendo información; un tutor de IA por sí solo no replica esa dimensión. Asimismo, lo más probable es que el futuro sea híbrido, no excluyente.',
          'Insiste porque la gramática enseñada demasiado pronto frena la producción oral; aprender a hablar primero y formalizar después produce hablantes más espontáneos. Cabe señalar que esta intuición está bien documentada en la pedagogía moderna.',
          'Lamenta una oportunidad económica y cultural perdida. Una región genuinamente bilingüe habría tenido mejor acceso a mercados, ciencia y diplomacia. Asimismo, aún se está a tiempo de empezar a invertir en serio.']
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
      and cefr_level = 'C1'
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

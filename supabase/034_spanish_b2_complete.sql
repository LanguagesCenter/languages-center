-- 034_spanish_b2_complete.sql
-- Full Spanish B2 curriculum. Mirrors the A1/A2/B1 pattern exactly:
-- teaching phase on lessons 1-7, 5 substantive exercises per lesson,
-- listening + speaking additions on lessons 1/2/3/6/7, conversation
-- dialogue at lesson 8 with 6 comprehension questions, and a unit test
-- at lesson 9.
--
-- B2 sections (created as skeletons by migration 015):
--   Politics & Society, Technology & Innovation, Philosophy & Ethics,
--   Literature & Poetry, Business & Economics, Science & Research,
--   Arts & Culture, Media & Journalism, Law & Justice, History,
--   Psychology, Architecture, Fashion & Design, Sports Analysis,
--   Environmental Issues
--
-- B2 grammar coverage: imperfect subjunctive in relative clauses,
-- conditional perfect, si-clauses (type 2 + type 3), subjunctive after
-- expressions of emotion, reported speech with tense shifting,
-- aunque + indicative vs subjunctive, more advanced lo + adjective.
--
-- Idempotent.

alter table public.lessons drop constraint if exists lessons_type_check;
alter table public.lessons
  add constraint lessons_type_check
  check (type in (
    'vocabulary','grammar','phrases','listening','speaking',
    'reading','writing','podcast','unit_test','conversation'
  ));

do $$
declare
  v_lang_id   bigint;
  v_course_id bigint;
  v_l1 bigint; v_l2 bigint; v_l3 bigint; v_l4 bigint;
  v_l5 bigint; v_l6 bigint; v_l7 bigint; v_l8 bigint;
  v_lesson_id bigint;
begin
  select id into v_lang_id from public.languages where code = 'spanish';

  -- ===========================================================
  -- B2.1 POLITICS & SOCIETY
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B2' and title = 'Politics & Society';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set intro='B2 political and social vocabulary.',
    vocab_items='[{"word":"la desigualdad","phonetic":"[deh-see-gwahl-DAHD]","english":"inequality","example_es":"La desigualdad es un problema estructural.","example_en":"Inequality is a structural problem."},{"word":"el discurso político","phonetic":"[dees-KOOR-soh poh-LEE-tee-koh]","english":"political discourse","example_es":"El discurso político se ha radicalizado.","example_en":"Political discourse has become radicalised."},{"word":"la ciudadanía","phonetic":"[syoo-dah-dah-NEE-ah]","english":"citizenry","example_es":"La ciudadanía exige cambios.","example_en":"The citizenry demands changes."},{"word":"la cohesión social","phonetic":"[koh-eh-SYOHN soh-SYAHL]","english":"social cohesion","example_es":"La cohesión social está en peligro.","example_en":"Social cohesion is at risk."}]'::jsonb,
    dialogue='[{"speaker":"Ana","spanish":"La desigualdad crece año tras año.","english":"Inequality grows year on year."},{"speaker":"Luis","spanish":"Es preocupante. La ciudadanía está cansada.","english":"It''s worrying. The citizenry is tired."},{"speaker":"Ana","spanish":"Sin cohesión social, será difícil avanzar.","english":"Without social cohesion, it will be hard to move forward."}]'::jsonb,
    grammar_note='B2 introduces "ser + past participle" passive: "ha sido radicalizado" / "se ha radicalizado". Both work, but the "se" form is more common in spoken Spanish.'
  where id = v_l1;

  update public.lessons set intro='Imperfect subjunctive in relative clauses.',
    vocab_items='[{"word":"que respetara","phonetic":"[keh rrehs-peh-TAH-rah]","english":"that respected","example_es":"Busco un líder que respetara las normas.","example_en":"I''m looking for a leader that respected the rules."},{"word":"hubiera sido","phonetic":"[oo-BYEH-rah SEE-doh]","english":"would have been","example_es":"Hubiera sido distinto con otro gobierno.","example_en":"It would have been different with another government."},{"word":"de haberlo sabido","phonetic":"[deh ah-BEHR-loh sah-BEE-doh]","english":"had I known","example_es":"De haberlo sabido, no habría votado así.","example_en":"Had I known, I wouldn''t have voted that way."},{"word":"como si","phonetic":"[KOH-moh see]","english":"as if","example_es":"Habla como si tuviera todas las respuestas.","example_en":"He speaks as if he had all the answers."}]'::jsonb,
    dialogue='[{"speaker":"Eva","spanish":"De haberlo sabido, habría votado distinto.","english":"Had I known, I would have voted differently."},{"speaker":"Iván","spanish":"Habla como si tuviera todas las respuestas.","english":"He speaks as if he had all the answers."},{"speaker":"Eva","spanish":"Necesitamos líderes que escucharan a la ciudadanía.","english":"We need leaders who listened to the citizenry."}]'::jsonb,
    grammar_note='Past conditional "habría + participle" with "de + infinitive": "De haberlo sabido, habría votado..." A signature B2 structure for regret about the past.'
  where id = v_l2;

  update public.lessons set intro='Phrases for political debate.',
    vocab_items='[{"word":"poner en cuestión","phonetic":"[poh-NEHR ehn kwehs-TYOHN]","english":"to call into question","example_es":"Esto pone en cuestión su credibilidad.","example_en":"This calls his credibility into question."},{"word":"un punto de inflexión","phonetic":"[POON-toh deh een-flehk-SYOHN]","english":"a turning point","example_es":"Fue un punto de inflexión histórico.","example_en":"It was a historic turning point."},{"word":"a la luz de","phonetic":"[ah lah loos deh]","english":"in light of","example_es":"A la luz de los datos, debemos actuar.","example_en":"In light of the data, we must act."},{"word":"de cara a","phonetic":"[deh KAH-rah ah]","english":"with a view to","example_es":"De cara a las elecciones, hay tensión.","example_en":"With a view to the elections, there''s tension."}]'::jsonb,
    dialogue='[{"speaker":"Marta","spanish":"Esto pone en cuestión todo el sistema.","english":"This calls the whole system into question."},{"speaker":"Pedro","spanish":"A la luz de los datos, es difícil discrepar.","english":"In light of the data, it''s hard to disagree."},{"speaker":"Marta","spanish":"De cara a las elecciones, esto será decisivo.","english":"With a view to the elections, this will be decisive."}]'::jsonb,
    grammar_note='"A la luz de" and "de cara a" are B2 connectors common in journalism and formal debate. Memorise as fixed blocks.'
  where id = v_l3;

  update public.lessons set intro='Listen to a parliamentary debate excerpt.',
    vocab_items='[{"word":"la enmienda","phonetic":"[ehn-MYEHN-dah]","english":"amendment","example_es":"Presentamos una enmienda al texto.","example_en":"We submitted an amendment to the text."},{"word":"el portavoz","phonetic":"[pohr-tah-BOHS]","english":"spokesperson","example_es":"El portavoz aclaró la postura.","example_en":"The spokesperson clarified the position."},{"word":"votar a favor","phonetic":"[boh-TAR ah fah-BOHR]","english":"to vote in favour","example_es":"Nuestro grupo votará a favor.","example_en":"Our group will vote in favour."},{"word":"la abstención","phonetic":"[ahbs-tehn-SYOHN]","english":"abstention","example_es":"La abstención fue significativa.","example_en":"Abstention was significant."}]'::jsonb,
    dialogue='[{"speaker":"Portavoz","spanish":"Presentamos una enmienda al artículo tercero.","english":"We submit an amendment to article three."},{"speaker":"Portavoz","spanish":"Nuestro grupo votará a favor de la reforma.","english":"Our group will vote in favour of the reform."},{"speaker":"Portavoz","spanish":"La abstención de otros partidos resulta sorprendente.","english":"The abstention of other parties is surprising."}]'::jsonb,
    grammar_note='Parliamentary register uses third-person plural "presentamos / votaremos" rhetorically — speaking for the party. Standard B2 listening territory.'
  where id = v_l4;

  update public.lessons set intro='Express nuanced political views.',
    vocab_items='[{"word":"Comparto la idea de que","phonetic":"[kohm-PAR-toh lah ee-DEH-ah]","english":"I share the idea that","example_es":"Comparto la idea de que hay que reformar.","example_en":"I share the idea that we must reform."},{"word":"matizar","phonetic":"[mah-tee-SAR]","english":"to qualify / nuance","example_es":"Hay que matizar esa afirmación.","example_en":"That statement needs qualifying."},{"word":"discrepar","phonetic":"[dees-kreh-PAR]","english":"to disagree","example_es":"Discrepo en ese punto.","example_en":"I disagree on that point."},{"word":"sin perjuicio de","phonetic":"[seen pehr-HWEE-syoh deh]","english":"without prejudice to","example_es":"Sin perjuicio de lo dicho, hay matices.","example_en":"Without prejudice to what was said, there are nuances."}]'::jsonb,
    dialogue='[{"speaker":"Tú","spanish":"Comparto la idea de que el sistema necesita reformarse.","english":"I share the idea that the system needs reform."},{"speaker":"Persona","spanish":"Pero hay que matizar.","english":"But it needs qualifying."},{"speaker":"Tú","spanish":"Por supuesto. Discrepo solo en los plazos.","english":"Of course. I only disagree on the timeline."}]'::jsonb,
    grammar_note='"Discrepar EN/DE" — disagree on a point. Different from "no estar de acuerdo CON" — disagree with a person. B2 register distinction.'
  where id = v_l5;

  update public.lessons set intro='Read an opinion column.',
    vocab_items='[{"word":"la coyuntura","phonetic":"[koh-yoon-TOO-rah]","english":"current situation","example_es":"En la coyuntura actual, todo es incierto.","example_en":"In the current situation, everything is uncertain."},{"word":"el escenario","phonetic":"[eh-seh-NAH-ryoh]","english":"scenario","example_es":"Hay varios escenarios posibles.","example_en":"There are several possible scenarios."},{"word":"poner de manifiesto","phonetic":"[poh-NEHR deh mah-nee-FYEHS-toh]","english":"to highlight","example_es":"La crisis pone de manifiesto las grietas.","example_en":"The crisis highlights the cracks."},{"word":"el malestar","phonetic":"[mah-lehs-TAR]","english":"discontent","example_es":"Crece el malestar entre los jóvenes.","example_en":"Discontent grows among young people."}]'::jsonb,
    dialogue='[{"speaker":"Texto","spanish":"La coyuntura actual pone de manifiesto un malestar profundo entre la ciudadanía.","english":"The current situation highlights a deep discontent in the citizenry."},{"speaker":"Texto","spanish":"Si los partidos no respondieran, el escenario podría agravarse.","english":"If the parties didn''t respond, the scenario could worsen."},{"speaker":"Texto","spanish":"De cara a las próximas elecciones, la izquierda y la derecha buscan reposicionarse.","english":"With a view to the next elections, the left and right are repositioning."}]'::jsonb,
    grammar_note='Si + imperfect subjunctive + conditional describes hypothetical present consequences: "Si no respondieran, el escenario podría agravarse." Classic B2 structure.'
  where id = v_l6;

  update public.lessons set intro='Write a political opinion paragraph.',
    vocab_items='[{"word":"sostengo que","phonetic":"[sohs-TEHN-goh keh]","english":"I maintain that","example_es":"Sostengo que es necesario reformar.","example_en":"I maintain that reform is necessary."},{"word":"resulta evidente","phonetic":"[rreh-SOOL-tah eh-bee-DEHN-teh]","english":"it''s evident","example_es":"Resulta evidente que hay un problema.","example_en":"It''s evident that there''s a problem."},{"word":"a mi juicio","phonetic":"[ah mee HWEE-syoh]","english":"in my judgment","example_es":"A mi juicio, el debate fue superficial.","example_en":"In my judgment, the debate was superficial."},{"word":"en definitiva","phonetic":"[ehn deh-fee-nee-TEE-bah]","english":"ultimately","example_es":"En definitiva, hay que actuar.","example_en":"Ultimately, we must act."}]'::jsonb,
    dialogue='[{"speaker":"Modelo","spanish":"Sostengo que las instituciones necesitan una reforma profunda.","english":"I maintain that institutions need profound reform."},{"speaker":"Modelo","spanish":"A mi juicio, los políticos actuales no se atreven a hacerla.","english":"In my judgment, current politicians don''t dare to do it."},{"speaker":"Modelo","spanish":"En definitiva, sin valentía política no habrá cambio.","english":"Ultimately, without political courage there will be no change."}]'::jsonb,
    grammar_note='"No habrá cambio" — future of "haber" used as "there will be". Negative form: "no habrá" without article. Compare "tener" which always needs an object.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "inequality"?','la desigualdad',array['el discurso','la ciudadanía','la cohesión'],'inequality',1),
  (v_l1,'fill_blank','Complete: "Sin ____ social, será difícil." (cohesion)','cohesión',array['desigualdad','ciudadanía','discurso'],'cohesion',2),
  (v_l1,'multiple_choice','What does "el discurso político" mean?','political discourse',array['political party','political system','political climate'],'political discourse',3),
  (v_l1,'listening','What did you hear?','La desigualdad crece año tras año',array['Es preocupante','La ciudadanía está cansada','Será difícil avanzar'],'Inequality grows year on year',4),
  (v_l1,'speaking','Say this aloud: "La cohesión social está en peligro."','La cohesión social está en peligro',array[]::text[],'Social cohesion is at risk.',5),
  (v_l2,'multiple_choice','What is the imperfect subjunctive of "respetar" (3rd)?','respetara',array['respeta','respetará','respetó'],'that respected',1),
  (v_l2,'fill_blank','Complete: "De ____ sabido, no habría votado así." (had it)','haberlo',array['saberlo','tenerlo','quererlo'],'had I known',2),
  (v_l2,'multiple_choice','What does "como si tuviera" mean?','as if he had',array['since he had','because he had','when he had'],'as if he had',3),
  (v_l2,'listening','What did you hear?','Habla como si tuviera todas las respuestas',array['De haberlo sabido, habría votado distinto','Necesitamos líderes que escucharan','Hubiera sido distinto'],'He speaks as if he had all the answers',4),
  (v_l2,'speaking','Say this aloud: "De haberlo sabido, habría votado distinto."','De haberlo sabido, habría votado distinto',array[]::text[],'Had I known, I would have voted differently.',5),
  (v_l3,'multiple_choice','How to say "in light of"?','a la luz de',array['de cara a','por culpa de','en cuestión'],'in light of',1),
  (v_l3,'fill_blank','Complete: "Fue un ____ de inflexión histórico." (turning point)','punto',array['cambio','sitio','momento'],'point',2),
  (v_l3,'multiple_choice','What does "de cara a" mean?','with a view to',array['against','despite','in light of'],'with a view to',3),
  (v_l3,'listening','What did you hear?','A la luz de los datos, es difícil discrepar',array['Esto pone en cuestión todo el sistema','De cara a las elecciones será decisivo','Fue un punto de inflexión'],'In light of the data, it''s hard to disagree',4),
  (v_l3,'speaking','Say this aloud: "A la luz de los datos, debemos actuar."','A la luz de los datos, debemos actuar',array[]::text[],'In light of the data, we must act.',5),
  (v_l4,'multiple_choice','What is "amendment"?','la enmienda',array['la abstención','el portavoz','el discurso'],'amendment',1),
  (v_l4,'fill_blank','Complete: "Nuestro grupo ____ a favor." (will vote)','votará',array['vota','votó','votaría'],'will vote',2),
  (v_l4,'multiple_choice','What does "portavoz" mean?','spokesperson',array['minister','candidate','citizen'],'spokesperson',3),
  (v_l4,'listening','What did you hear?','Presentamos una enmienda al artículo tercero',array['Nuestro grupo votará a favor','La abstención resulta sorprendente','El portavoz aclaró la postura'],'We submit an amendment to article three',4),
  (v_l4,'speaking','Say this aloud: "Nuestro grupo votará a favor."','Nuestro grupo votará a favor',array[]::text[],'Our group will vote in favour.',5),
  (v_l5,'multiple_choice','How to say "to qualify / nuance"?','matizar',array['discrepar','compartir','poner'],'to qualify',1),
  (v_l5,'fill_blank','Complete: "____ en ese punto." (I disagree)','Discrepo',array['Comparto','Matizo','Apoyo'],'I disagree',2),
  (v_l5,'multiple_choice','What does "sin perjuicio de" mean?','without prejudice to',array['without doubt','without question','without a doubt'],'without prejudice to',3),
  (v_l5,'listening','What did you hear?','Comparto la idea de que el sistema necesita reformarse',array['Pero hay que matizar','Discrepo solo en los plazos','Por supuesto'],'I share the idea that the system needs reform',4),
  (v_l5,'speaking','Say this aloud: "Hay que matizar esa afirmación."','Hay que matizar esa afirmación',array[]::text[],'That statement needs qualifying.',5),
  (v_l6,'multiple_choice','What is "current situation"?','la coyuntura',array['el escenario','el malestar','la grieta'],'current situation',1),
  (v_l6,'fill_blank','Complete: "Pone de ____ las grietas." (highlights)','manifiesto',array['relieve','evidencia','claro'],'highlights',2),
  (v_l6,'multiple_choice','What does "malestar" mean?','discontent',array['relief','hope','peace'],'discontent',3),
  (v_l6,'listening','What did you hear?','Si los partidos no respondieran, el escenario podría agravarse',array['La coyuntura actual pone de manifiesto un malestar','De cara a las próximas elecciones','La izquierda y la derecha buscan reposicionarse'],'If the parties didn''t respond, the scenario could worsen',4),
  (v_l6,'speaking','Say this aloud: "Crece el malestar entre los jóvenes."','Crece el malestar entre los jóvenes',array[]::text[],'Discontent grows among young people.',5),
  (v_l7,'multiple_choice','How to say "I maintain that"?','sostengo que',array['resulta evidente','a mi juicio','en definitiva'],'I maintain that',1),
  (v_l7,'fill_blank','Complete: "A mi ____, fue superficial." (judgment)','juicio',array['idea','manera','opinión'],'judgment',2),
  (v_l7,'multiple_choice','What does "en definitiva" mean?','ultimately',array['for example','however','suddenly'],'ultimately',3),
  (v_l7,'listening','What did you hear?','Sostengo que las instituciones necesitan una reforma profunda',array['A mi juicio, los políticos no se atreven','En definitiva, sin valentía política','Resulta evidente que hay un problema'],'I maintain that institutions need profound reform',4),
  (v_l7,'speaking','Say this aloud: "En definitiva, hay que actuar."','En definitiva, hay que actuar',array[]::text[],'Ultimately, we must act.',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','La cohesión social está en peligro',array['La desigualdad crece año tras año','El discurso político se ha radicalizado','La ciudadanía exige cambios'],'Social cohesion is at risk',6),
  (v_l1,'listening','What did you hear?','El discurso político se ha radicalizado',array['La desigualdad es un problema estructural','La cohesión social está en peligro','La ciudadanía exige cambios'],'Political discourse has become radicalised',7),
  (v_l1,'speaking','Say this aloud: "La desigualdad es un problema estructural."','La desigualdad es un problema estructural',array[]::text[],'Inequality is a structural problem.',8),
  (v_l1,'speaking','Say this aloud: "La ciudadanía exige cambios."','La ciudadanía exige cambios',array[]::text[],'The citizenry demands changes.',9),
  (v_l2,'listening','What did you hear?','Necesitamos líderes que escucharan a la ciudadanía',array['Hubiera sido distinto','De haberlo sabido habría votado distinto','Habla como si tuviera todas las respuestas'],'We need leaders who listened to the citizenry',6),
  (v_l2,'listening','What did you hear?','Hubiera sido distinto con otro gobierno',array['De haberlo sabido','Habla como si tuviera','Necesitamos líderes'],'It would have been different with another government',7),
  (v_l2,'speaking','Say this aloud: "Hubiera sido distinto con otro gobierno."','Hubiera sido distinto con otro gobierno',array[]::text[],'It would have been different with another government.',8),
  (v_l2,'speaking','Say this aloud: "Habla como si tuviera todas las respuestas."','Habla como si tuviera todas las respuestas',array[]::text[],'He speaks as if he had all the answers.',9),
  (v_l3,'listening','What did you hear?','Esto pone en cuestión todo el sistema',array['A la luz de los datos','De cara a las elecciones','Fue un punto de inflexión'],'This calls the whole system into question',6),
  (v_l3,'listening','What did you hear?','De cara a las elecciones, esto será decisivo',array['A la luz de los datos','Esto pone en cuestión','Fue un punto de inflexión'],'With a view to the elections, this will be decisive',7),
  (v_l3,'speaking','Say this aloud: "Esto pone en cuestión su credibilidad."','Esto pone en cuestión su credibilidad',array[]::text[],'This calls his credibility into question.',8),
  (v_l3,'speaking','Say this aloud: "Fue un punto de inflexión histórico."','Fue un punto de inflexión histórico',array[]::text[],'It was a historic turning point.',9),
  (v_l6,'listening','What did you hear?','La coyuntura actual pone de manifiesto un malestar profundo',array['Si los partidos no respondieran','De cara a las próximas elecciones','La izquierda y la derecha'],'The current situation highlights a deep discontent',6),
  (v_l6,'listening','What did you hear?','La izquierda y la derecha buscan reposicionarse',array['La coyuntura actual','Si los partidos no respondieran','El escenario podría agravarse'],'The left and right are repositioning',7),
  (v_l6,'speaking','Say this aloud: "La crisis pone de manifiesto las grietas."','La crisis pone de manifiesto las grietas',array[]::text[],'The crisis highlights the cracks.',8),
  (v_l6,'speaking','Say this aloud: "Hay varios escenarios posibles."','Hay varios escenarios posibles',array[]::text[],'There are several possible scenarios.',9),
  (v_l7,'listening','What did you hear?','A mi juicio, los políticos actuales no se atreven a hacerla',array['Sostengo que las instituciones necesitan una reforma profunda','En definitiva, sin valentía política no habrá cambio','Resulta evidente que hay un problema'],'In my judgment, current politicians don''t dare to do it',6),
  (v_l7,'listening','What did you hear?','Resulta evidente que hay un problema',array['A mi juicio','En definitiva','Sostengo que'],'It''s evident that there''s a problem',7),
  (v_l7,'speaking','Say this aloud: "Resulta evidente que hay un problema."','Resulta evidente que hay un problema',array[]::text[],'It''s evident that there''s a problem.',8),
  (v_l7,'speaking','Say this aloud: "A mi juicio, el debate fue superficial."','A mi juicio, el debate fue superficial',array[]::text[],'In my judgment, the debate was superficial.',9);

  update public.lessons set type='conversation', title='Politics & Society — Conversation Practice',
    description='Two friends debate the state of politics over coffee.',
    intro='Ana and Luis trade nuanced views on inequality and the political class.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Ana","spanish":"La coyuntura actual pone de manifiesto un malestar profundo.","english":"The current situation highlights a deep discontent."},{"speaker":"Luis","spanish":"Sostengo que la desigualdad es la raíz del problema.","english":"I maintain that inequality is the root of the problem."},{"speaker":"Ana","spanish":"De acuerdo, aunque hay que matizar. No todo se debe a lo económico.","english":"Agreed, although it needs qualifying. Not everything is about the economy."},{"speaker":"Luis","spanish":"A mi juicio, los políticos hablan como si tuvieran las soluciones, pero no las tienen.","english":"In my judgment, politicians speak as if they had the solutions, but they don''t."},{"speaker":"Ana","spanish":"De haberlo sabido la ciudadanía, no habría votado así.","english":"Had the citizenry known, they wouldn''t have voted that way."},{"speaker":"Luis","spanish":"En definitiva, sin valentía política, no habrá cambio.","english":"Ultimately, without political courage there will be no change."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','What does Luis say is the root problem?','Inequality',array['Corruption','Education','Media'],'Sostengo que la desigualdad es la raíz del problema',1),
  (v_l8,'multiple_choice','Does Ana agree fully?','No, with qualification',array['Yes, completely','No, totally','She''s undecided'],'De acuerdo, aunque hay que matizar',2),
  (v_l8,'multiple_choice','What does Luis say politicians do?','Speak as if they had solutions',array['Tell the truth','Refuse to speak','Listen to citizens'],'hablan como si tuvieran las soluciones',3),
  (v_l8,'multiple_choice','True or false: Luis is optimistic about change.','False',array['True'],'sin valentía política, no habrá cambio',4),
  (v_l8,'fill_blank','Complete: "De ____ sabido la ciudadanía..." (had they)','haberlo',array['saberlo','tenerlo','quererlo'],'had they known',5),
  (v_l8,'multiple_choice','Ana''s key nuance?','Not everything is about the economy',array['Politicians are right','Citizens are wrong','Nothing matters'],'No todo se debe a lo económico',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Politics & Society', 'Review test for the Politics & Society section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "inequality"?','la desigualdad',array['la cohesión','la ciudadanía','el discurso'],'inequality',1),
  (v_lesson_id,'multiple_choice','Past conditional of "votar" (I)?','habría votado',array['voté','votaba','votaría'],'I would have voted',2),
  (v_lesson_id,'multiple_choice','What does "matizar" mean?','to qualify',array['to disagree','to agree','to argue'],'to qualify',3),
  (v_lesson_id,'multiple_choice','True/false: "como si" triggers imperfect subjunctive.','True',array['False'],'como si tuviera',4),
  (v_lesson_id,'fill_blank','Complete: "De ____ sabido." (had I)','haberlo',array['saberlo','tenerlo','quererlo'],'had I known',5),
  (v_lesson_id,'fill_blank','Complete: "A mi ____" (judgment)','juicio',array['idea','opinión','manera'],'judgment',6),
  (v_lesson_id,'listening','What did you hear?','La desigualdad crece año tras año',array['Esto pone en cuestión todo el sistema','Sostengo que las instituciones necesitan reforma','Crece el malestar entre los jóvenes'],'Inequality grows year on year',7),
  (v_lesson_id,'listening','What did you hear?','En definitiva, sin valentía política no habrá cambio',array['A mi juicio el debate fue superficial','Hubiera sido distinto','La coyuntura actual'],'Ultimately, without political courage there will be no change',8),
  (v_lesson_id,'speaking','Say this aloud: "De haberlo sabido, habría votado distinto."','De haberlo sabido, habría votado distinto',array[]::text[],'Had I known, I would have voted differently.',9),
  (v_lesson_id,'speaking','Say this aloud: "Resulta evidente que hay un problema."','Resulta evidente que hay un problema',array[]::text[],'It''s evident that there''s a problem.',10);

  -- ===========================================================
  -- B2.2 TECHNOLOGY & INNOVATION
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B2' and title = 'Technology & Innovation';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set intro='Technology vocabulary at B2.',
    vocab_items='[{"word":"la inteligencia artificial","phonetic":"[een-teh-lee-HEHN-syah ahr-tee-fee-SYAHL]","english":"artificial intelligence","example_es":"La inteligencia artificial transforma todo.","example_en":"AI is transforming everything."},{"word":"el algoritmo","phonetic":"[ahl-goh-REET-moh]","english":"algorithm","example_es":"El algoritmo decide qué vemos.","example_en":"The algorithm decides what we see."},{"word":"la innovación","phonetic":"[een-noh-bah-SYOHN]","english":"innovation","example_es":"La innovación impulsa la economía.","example_en":"Innovation drives the economy."},{"word":"prescindir de","phonetic":"[prehs-seen-DEER]","english":"to do without","example_es":"No podemos prescindir de la tecnología.","example_en":"We can''t do without technology."}]'::jsonb,
    dialogue='[{"speaker":"Eva","spanish":"Ya no podemos prescindir de la inteligencia artificial.","english":"We can no longer do without AI."},{"speaker":"Diego","spanish":"Los algoritmos deciden por nosotros.","english":"Algorithms decide for us."},{"speaker":"Eva","spanish":"Eso plantea preguntas éticas serias.","english":"That raises serious ethical questions."}]'::jsonb,
    grammar_note='"Prescindir DE" — to do without. Always with "de", never alone: "prescindir de X". Compare with "evitar" which takes no preposition.'
  where id = v_l1;
  update public.lessons set intro='Future perfect and conditional perfect.',
    vocab_items='[{"word":"habrá cambiado","phonetic":"[ah-BRAH kahm-BYAH-doh]","english":"will have changed","example_es":"En diez años todo habrá cambiado.","example_en":"In ten years everything will have changed."},{"word":"habría sido","phonetic":"[ah-BREE-ah SEE-doh]","english":"would have been","example_es":"Sin internet, habría sido imposible.","example_en":"Without internet, it would have been impossible."},{"word":"de aquí a","phonetic":"[deh ah-KEE ah]","english":"from now until","example_es":"De aquí a cinco años.","example_en":"From now until five years from now."},{"word":"para entonces","phonetic":"[PAH-rah ehn-TOHN-sehs]","english":"by then","example_es":"Para entonces ya habremos terminado.","example_en":"By then we''ll have finished."}]'::jsonb,
    dialogue='[{"speaker":"Marco","spanish":"De aquí a diez años, los coches autónomos serán la norma.","english":"From now until ten years, self-driving cars will be the norm."},{"speaker":"Lucía","spanish":"Para entonces, mucha gente habrá perdido su trabajo.","english":"By then, many people will have lost their jobs."},{"speaker":"Marco","spanish":"Sin reformas, habría sido un desastre.","english":"Without reforms, it would have been a disaster."}]'::jsonb,
    grammar_note='Future perfect "habrá + participle" describes future completion: "habrá cambiado" = "will have changed". Used with "para entonces" / "de aquí a + time".'
  where id = v_l2;
  update public.lessons set intro='Phrases about technology debates.',
    vocab_items='[{"word":"sacar provecho de","phonetic":"[sah-KAR proh-BEH-choh]","english":"to take advantage of","example_es":"Hay que sacar provecho de la tecnología.","example_en":"We have to take advantage of technology."},{"word":"a costa de","phonetic":"[ah KOHS-tah deh]","english":"at the cost of","example_es":"Avance a costa de la privacidad.","example_en":"Progress at the cost of privacy."},{"word":"poner en riesgo","phonetic":"[poh-NEHR ehn RRYEHS-goh]","english":"to put at risk","example_es":"Pone en riesgo nuestros datos.","example_en":"It puts our data at risk."},{"word":"una espada de doble filo","phonetic":"[ehs-PAH-dah deh DOH-bleh FEE-loh]","english":"a double-edged sword","example_es":"La IA es una espada de doble filo.","example_en":"AI is a double-edged sword."}]'::jsonb,
    dialogue='[{"speaker":"Ana","spanish":"La IA es una espada de doble filo.","english":"AI is a double-edged sword."},{"speaker":"Pedro","spanish":"Sacar provecho sí, pero no a costa de la privacidad.","english":"Take advantage yes, but not at the cost of privacy."},{"speaker":"Ana","spanish":"Pone en riesgo nuestros datos personales.","english":"It puts our personal data at risk."}]'::jsonb,
    grammar_note='"A costa de" — at the cost of (figurative). "Al coste de" — at the cost of (literal price). Be careful with the distinction.'
  where id = v_l3;
  update public.lessons set intro='Listen to a tech debate.',
    vocab_items='[{"word":"la brecha digital","phonetic":"[BREH-chah dee-hee-TAHL]","english":"digital divide","example_es":"La brecha digital sigue creciendo.","example_en":"The digital divide keeps growing."},{"word":"ciberseguridad","phonetic":"[see-behr-seh-goo-ree-DAHD]","english":"cybersecurity","example_es":"Invertimos en ciberseguridad.","example_en":"We invest in cybersecurity."},{"word":"el escepticismo","phonetic":"[ehs-sehp-tee-SEES-moh]","english":"scepticism","example_es":"Existe escepticismo entre los expertos.","example_en":"There''s scepticism among experts."},{"word":"el avance vertiginoso","phonetic":"[ah-BAHN-seh behr-tee-hee-NOH-soh]","english":"vertiginous progress","example_es":"El avance vertiginoso de la IA.","example_en":"The vertiginous progress of AI."}]'::jsonb,
    dialogue='[{"speaker":"Locutor","spanish":"La brecha digital sigue siendo un problema enorme.","english":"The digital divide is still an enormous problem."},{"speaker":"Locutor","spanish":"Crece el escepticismo ante el avance vertiginoso de la IA.","english":"Scepticism is growing in the face of AI''s vertiginous progress."},{"speaker":"Locutor","spanish":"Las empresas invierten más en ciberseguridad que nunca.","english":"Companies invest more in cybersecurity than ever."}]'::jsonb,
    grammar_note='"Ante" (formal) = "in the face of" / "before". More formal than "frente a" but interchangeable in writing.'
  where id = v_l4;
  update public.lessons set intro='Discuss technology fluently.',
    vocab_items='[{"word":"Estoy a favor de","phonetic":"[ehs-TOY ah fah-BOHR]","english":"I''m in favour of","example_es":"Estoy a favor de la IA bien regulada.","example_en":"I''m in favour of well-regulated AI."},{"word":"Me preocupa que","phonetic":"[meh preh-oh-KOO-pah keh]","english":"I''m worried that","example_es":"Me preocupa que perdamos privacidad.","example_en":"I''m worried we''ll lose privacy."},{"word":"sin perder de vista","phonetic":"[seen pehr-DEHR deh BEES-tah]","english":"without losing sight of","example_es":"Sin perder de vista los riesgos.","example_en":"Without losing sight of the risks."},{"word":"buscar un equilibrio","phonetic":"[boos-KAR oon eh-kee-LEE-bryoh]","english":"to find a balance","example_es":"Hay que buscar un equilibrio.","example_en":"We have to find a balance."}]'::jsonb,
    dialogue='[{"speaker":"Tú","spanish":"Estoy a favor de la IA, pero me preocupa que perdamos privacidad.","english":"I''m in favour of AI, but I''m worried we''ll lose privacy."},{"speaker":"Persona","spanish":"Equilibrio, ¿no?","english":"Balance, right?"},{"speaker":"Tú","spanish":"Exacto. Sin perder de vista los riesgos.","english":"Exactly. Without losing sight of the risks."}]'::jsonb,
    grammar_note='"Me preocupa que" + present subjunctive — concern about a possibility: "me preocupa que perdamos", "me preocupa que sea tarde".'
  where id = v_l5;
  update public.lessons set intro='Read about the ethics of automation.',
    vocab_items='[{"word":"la automatización","phonetic":"[ow-toh-mah-tee-sah-SYOHN]","english":"automation","example_es":"La automatización elimina empleos.","example_en":"Automation eliminates jobs."},{"word":"desplazar","phonetic":"[dehs-plah-SAR]","english":"to displace","example_es":"La IA desplaza a muchos trabajadores.","example_en":"AI displaces many workers."},{"word":"recualificar","phonetic":"[rreh-kwah-lee-fee-KAR]","english":"to reskill","example_es":"Hay que recualificar a la población.","example_en":"We have to reskill the population."},{"word":"el dilema ético","phonetic":"[dee-LEH-mah EH-tee-koh]","english":"ethical dilemma","example_es":"Plantea un dilema ético complejo.","example_en":"It poses a complex ethical dilemma."}]'::jsonb,
    dialogue='[{"speaker":"Texto","spanish":"La automatización masiva desplaza a millones de trabajadores.","english":"Mass automation displaces millions of workers."},{"speaker":"Texto","spanish":"Recualificar a la población se ha convertido en una prioridad urgente.","english":"Reskilling the population has become an urgent priority."},{"speaker":"Texto","spanish":"Sin embargo, plantea un dilema ético complejo: ¿quién paga el coste de la transición?","english":"However, it poses a complex ethical dilemma: who pays the transition cost?"}]'::jsonb,
    grammar_note='"Convertirse en" = "to become" (after a process). Compare "hacerse" (gradual change) vs "ponerse" (temporary change of state).'
  where id = v_l6;
  update public.lessons set intro='Write an opinion essay on tech.',
    vocab_items='[{"word":"cabe destacar","phonetic":"[KAH-beh dehs-tah-KAR]","english":"it''s worth noting","example_es":"Cabe destacar el rápido avance.","example_en":"It''s worth noting the rapid progress."},{"word":"a tal punto que","phonetic":"[ah tahl POON-toh keh]","english":"to such an extent that","example_es":"A tal punto que ya no podemos prescindir.","example_en":"To such an extent that we can no longer do without it."},{"word":"sin lugar a dudas","phonetic":"[seen loo-GAR ah DOO-dahs]","english":"without a doubt","example_es":"Sin lugar a dudas, cambiará el futuro.","example_en":"Without a doubt, it will change the future."},{"word":"a la larga","phonetic":"[ah lah LAR-gah]","english":"in the long run","example_es":"A la larga, los beneficios pesarán más.","example_en":"In the long run, the benefits will outweigh."}]'::jsonb,
    dialogue='[{"speaker":"Modelo","spanish":"Cabe destacar el avance vertiginoso de la inteligencia artificial.","english":"It''s worth noting the vertiginous progress of AI."},{"speaker":"Modelo","spanish":"Ha llegado a tal punto que ya no podemos prescindir de ella.","english":"It has reached such an extent that we can no longer do without it."},{"speaker":"Modelo","spanish":"Sin lugar a dudas, a la larga, los beneficios pesarán más que los riesgos.","english":"Without a doubt, in the long run, the benefits will outweigh the risks."}]'::jsonb,
    grammar_note='"Cabe + infinitive" — formal "it''s appropriate / worth doing X". "Cabe destacar", "cabe señalar", "cabe preguntarse". Essay register.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "algorithm"?','el algoritmo',array['la innovación','la IA','la brecha'],'algorithm',1),
  (v_l1,'fill_blank','Complete: "No podemos ____ de la tecnología." (do without)','prescindir',array['gozar','dudar','prescindible'],'do without',2),
  (v_l1,'multiple_choice','What does "innovación" mean?','innovation',array['imitation','installation','intelligence'],'innovation',3),
  (v_l1,'listening','What did you hear?','Los algoritmos deciden por nosotros',array['Ya no podemos prescindir de la inteligencia artificial','Eso plantea preguntas éticas serias','La innovación impulsa la economía'],'Algorithms decide for us',4),
  (v_l1,'speaking','Say this aloud: "No podemos prescindir de la tecnología."','No podemos prescindir de la tecnología',array[]::text[],'We can''t do without technology.',5),
  (v_l2,'multiple_choice','Future perfect of "cambiar" (he/she)?','habrá cambiado',array['cambiará','cambió','cambiaba'],'will have changed',1),
  (v_l2,'fill_blank','Complete: "Para ____ ya habremos terminado." (then)','entonces',array['ahora','antes','luego'],'then',2),
  (v_l2,'multiple_choice','What does "de aquí a diez años" mean?','from now until ten years','ten years ago','for ten years','in ten years exactly','from now until ten years',3),
  (v_l2,'listening','What did you hear?','Sin reformas, habría sido un desastre',array['De aquí a diez años, los coches autónomos','Para entonces, mucha gente habrá perdido','Mucha gente habrá perdido su trabajo'],'Without reforms, it would have been a disaster',4),
  (v_l2,'speaking','Say this aloud: "Para entonces ya habremos terminado."','Para entonces ya habremos terminado',array[]::text[],'By then we''ll have finished.',5),
  (v_l3,'multiple_choice','How to say "a double-edged sword"?','una espada de doble filo',array['sacar provecho','a costa de','poner en riesgo'],'double-edged sword',1),
  (v_l3,'fill_blank','Complete: "Avance a ____ de la privacidad." (at the cost)','costa',array['favor','contra','través'],'at the cost',2),
  (v_l3,'multiple_choice','What does "sacar provecho" mean?','to take advantage',array['to put at risk','to lose','to deny'],'to take advantage',3),
  (v_l3,'listening','What did you hear?','La IA es una espada de doble filo',array['Sacar provecho sí, pero no a costa de la privacidad','Pone en riesgo nuestros datos personales','Hay que sacar provecho de la tecnología'],'AI is a double-edged sword',4),
  (v_l3,'speaking','Say this aloud: "Pone en riesgo nuestros datos."','Pone en riesgo nuestros datos',array[]::text[],'It puts our data at risk.',5),
  (v_l4,'multiple_choice','What is "digital divide"?','la brecha digital',array['la ciberseguridad','el escepticismo','el avance vertiginoso'],'digital divide',1),
  (v_l4,'fill_blank','Complete: "Invertimos en ____" (cybersecurity)','ciberseguridad',array['escepticismo','brecha','avance'],'cybersecurity',2),
  (v_l4,'multiple_choice','What does "escepticismo" mean?','scepticism',array['enthusiasm','panic','silence'],'scepticism',3),
  (v_l4,'listening','What did you hear?','Crece el escepticismo ante el avance vertiginoso de la IA',array['La brecha digital sigue siendo un problema enorme','Las empresas invierten más en ciberseguridad','El avance vertiginoso de la IA'],'Scepticism is growing in the face of AI''s vertiginous progress',4),
  (v_l4,'speaking','Say this aloud: "Las empresas invierten en ciberseguridad."','Las empresas invierten en ciberseguridad',array[]::text[],'Companies invest in cybersecurity.',5),
  (v_l5,'multiple_choice','How to say "I''m worried that we''ll lose"?','Me preocupa que perdamos',array['Estoy a favor de','Sin perder de vista','Buscar un equilibrio'],'I''m worried we''ll lose',1),
  (v_l5,'fill_blank','Complete: "Hay que buscar un ____" (balance)','equilibrio',array['riesgo','provecho','manera'],'balance',2),
  (v_l5,'multiple_choice','What does "sin perder de vista" mean?','without losing sight of',array['without doubt','without fear','without thought'],'without losing sight of',3),
  (v_l5,'listening','What did you hear?','Sin perder de vista los riesgos',array['Estoy a favor de la IA bien regulada','Me preocupa que perdamos privacidad','Hay que buscar un equilibrio'],'Without losing sight of the risks',4),
  (v_l5,'speaking','Say this aloud: "Me preocupa que perdamos privacidad."','Me preocupa que perdamos privacidad',array[]::text[],'I''m worried we''ll lose privacy.',5),
  (v_l6,'multiple_choice','What is "automation"?','la automatización',array['la innovación','la inteligencia','la brecha'],'automation',1),
  (v_l6,'fill_blank','Complete: "Hay que ____ a la población." (reskill)','recualificar',array['desplazar','prescindir','sacar'],'reskill',2),
  (v_l6,'multiple_choice','What does "dilema ético" mean?','ethical dilemma',array['ethical principle','technical issue','political debate'],'ethical dilemma',3),
  (v_l6,'listening','What did you hear?','La automatización masiva desplaza a millones de trabajadores',array['Recualificar a la población se ha convertido en prioridad','Plantea un dilema ético complejo','¿Quién paga el coste de la transición?'],'Mass automation displaces millions of workers',4),
  (v_l6,'speaking','Say this aloud: "Plantea un dilema ético complejo."','Plantea un dilema ético complejo',array[]::text[],'It poses a complex ethical dilemma.',5),
  (v_l7,'multiple_choice','How to say "it''s worth noting"?','cabe destacar',array['a tal punto que','sin lugar a dudas','a la larga'],'it''s worth noting',1),
  (v_l7,'fill_blank','Complete: "Sin ____ a dudas." (place)','lugar',array['costa','vista','duda'],'without a doubt (lit.)',2),
  (v_l7,'multiple_choice','What does "a la larga" mean?','in the long run',array['in the short term','quickly','later'],'in the long run',3),
  (v_l7,'listening','What did you hear?','Cabe destacar el avance vertiginoso de la inteligencia artificial',array['Ha llegado a tal punto','Sin lugar a dudas','A la larga los beneficios pesarán más'],'It''s worth noting the vertiginous progress of AI',4),
  (v_l7,'speaking','Say this aloud: "A la larga, los beneficios pesarán más."','A la larga, los beneficios pesarán más',array[]::text[],'In the long run, the benefits will outweigh.',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','La inteligencia artificial transforma todo',array['El algoritmo decide qué vemos','La innovación impulsa la economía','No podemos prescindir de la tecnología'],'AI is transforming everything',6),
  (v_l1,'listening','What did you hear?','El algoritmo decide qué vemos',array['La inteligencia artificial transforma todo','La innovación impulsa la economía','No podemos prescindir'],'The algorithm decides what we see',7),
  (v_l1,'speaking','Say this aloud: "La inteligencia artificial transforma todo."','La inteligencia artificial transforma todo',array[]::text[],'AI is transforming everything.',8),
  (v_l1,'speaking','Say this aloud: "La innovación impulsa la economía."','La innovación impulsa la economía',array[]::text[],'Innovation drives the economy.',9),
  (v_l2,'listening','What did you hear?','En diez años todo habrá cambiado',array['Para entonces ya habremos terminado','De aquí a cinco años','Sin internet, habría sido imposible'],'In ten years everything will have changed',6),
  (v_l2,'listening','What did you hear?','Sin internet, habría sido imposible',array['En diez años todo habrá cambiado','Para entonces','De aquí a cinco años'],'Without internet, it would have been impossible',7),
  (v_l2,'speaking','Say this aloud: "En diez años todo habrá cambiado."','En diez años todo habrá cambiado',array[]::text[],'In ten years everything will have changed.',8),
  (v_l2,'speaking','Say this aloud: "De aquí a cinco años."','De aquí a cinco años',array[]::text[],'From now until five years.',9),
  (v_l3,'listening','What did you hear?','Hay que sacar provecho de la tecnología',array['Avance a costa de la privacidad','Pone en riesgo nuestros datos','La IA es una espada de doble filo'],'We have to take advantage of technology',6),
  (v_l3,'listening','What did you hear?','Pone en riesgo nuestros datos personales',array['Hay que sacar provecho','La IA es una espada','Avance a costa'],'It puts our personal data at risk',7),
  (v_l3,'speaking','Say this aloud: "La IA es una espada de doble filo."','La IA es una espada de doble filo',array[]::text[],'AI is a double-edged sword.',8),
  (v_l3,'speaking','Say this aloud: "No a costa de la privacidad."','No a costa de la privacidad',array[]::text[],'Not at the cost of privacy.',9),
  (v_l6,'listening','What did you hear?','Recualificar a la población se ha convertido en una prioridad urgente',array['La automatización elimina empleos','Plantea un dilema ético complejo','¿Quién paga el coste de la transición?'],'Reskilling the population has become an urgent priority',6),
  (v_l6,'listening','What did you hear?','¿Quién paga el coste de la transición?',array['La automatización elimina empleos','La IA desplaza a muchos trabajadores','Recualificar a la población'],'Who pays the transition cost?',7),
  (v_l6,'speaking','Say this aloud: "La IA desplaza a muchos trabajadores."','La IA desplaza a muchos trabajadores',array[]::text[],'AI displaces many workers.',8),
  (v_l6,'speaking','Say this aloud: "Hay que recualificar a la población."','Hay que recualificar a la población',array[]::text[],'We have to reskill the population.',9),
  (v_l7,'listening','What did you hear?','Ha llegado a tal punto que ya no podemos prescindir de ella',array['Cabe destacar el avance','Sin lugar a dudas','A la larga los beneficios pesarán'],'It has reached such an extent that we can no longer do without it',6),
  (v_l7,'listening','What did you hear?','Sin lugar a dudas, cambiará el futuro',array['Cabe destacar','A tal punto que','A la larga'],'Without a doubt, it will change the future',7),
  (v_l7,'speaking','Say this aloud: "Cabe destacar el rápido avance."','Cabe destacar el rápido avance',array[]::text[],'It''s worth noting the rapid progress.',8),
  (v_l7,'speaking','Say this aloud: "Sin lugar a dudas, cambiará el futuro."','Sin lugar a dudas, cambiará el futuro',array[]::text[],'Without a doubt, it will change the future.',9);

  update public.lessons set type='conversation', title='Technology & Innovation — Conversation Practice',
    description='Two friends debate AI and its consequences.',
    intro='Eva and Diego discuss the impact of AI on jobs and privacy.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Eva","spanish":"De aquí a diez años, la IA habrá cambiado todo.","english":"From now until ten years, AI will have changed everything."},{"speaker":"Diego","spanish":"Me preocupa que mucha gente pierda su trabajo.","english":"I''m worried many people will lose their jobs."},{"speaker":"Eva","spanish":"Sí, pero también podemos sacar provecho. Es una espada de doble filo.","english":"Yes, but we can also take advantage. It''s a double-edged sword."},{"speaker":"Diego","spanish":"Sin perder de vista los riesgos. La privacidad es lo primero.","english":"Without losing sight of the risks. Privacy comes first."},{"speaker":"Eva","spanish":"Sin lugar a dudas, hay que buscar un equilibrio.","english":"Without a doubt, we have to find a balance."},{"speaker":"Diego","spanish":"A la larga, lo importante es no prescindir de nuestros valores.","english":"In the long run, what matters is not to do without our values."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','How long until AI will have changed everything (per Eva)?','10 years',array['5 years','15 years','immediately'],'De aquí a diez años, la IA habrá cambiado todo',1),
  (v_l8,'multiple_choice','What worries Diego?','Job losses',array['Privacy only','Costs','Inequality'],'Me preocupa que mucha gente pierda su trabajo',2),
  (v_l8,'multiple_choice','How does Eva describe AI?','A double-edged sword',array['A blessing','A curse','A trend'],'una espada de doble filo',3),
  (v_l8,'multiple_choice','True or false: Diego prioritises privacy.','True',array['False'],'La privacidad es lo primero',4),
  (v_l8,'fill_blank','Complete: "Sin ____ de vista los riesgos." (losing)','perder',array['saber','mirar','tener'],'losing sight of',5),
  (v_l8,'multiple_choice','Diego''s long-run priority?','Not abandoning values',array['Maximum profit','Stopping AI','Job creation'],'A la larga, lo importante es no prescindir de nuestros valores',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Technology & Innovation', 'Review test for the Technology & Innovation section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "algorithm"?','el algoritmo',array['la innovación','la IA','la brecha'],'algorithm',1),
  (v_lesson_id,'multiple_choice','Future perfect of "perder" (3rd p)?','habrá perdido',array['perderá','perdió','perdería'],'will have lost',2),
  (v_lesson_id,'multiple_choice','What does "a costa de" mean?','at the cost of',array['in favour of','despite','for'],'at the cost of',3),
  (v_lesson_id,'multiple_choice','True/false: "me preocupa que" triggers subjunctive.','True',array['False'],'me preocupa que perdamos',4),
  (v_lesson_id,'fill_blank','Complete: "Cabe ____ el avance." (to highlight)','destacar',array['señalar','marcar','tomar'],'to highlight',5),
  (v_lesson_id,'fill_blank','Complete: "Sin lugar a ____" (doubts)','dudas',array['costas','vistas','manera'],'sin lugar a dudas',6),
  (v_lesson_id,'listening','What did you hear?','La IA es una espada de doble filo',array['Los algoritmos deciden por nosotros','No podemos prescindir de la tecnología','La innovación impulsa la economía'],'AI is a double-edged sword',7),
  (v_lesson_id,'listening','What did you hear?','Sin lugar a dudas, cambiará el futuro',array['Cabe destacar el avance','A la larga los beneficios pesarán','A tal punto que ya no podemos prescindir'],'Without a doubt, it will change the future',8),
  (v_lesson_id,'speaking','Say this aloud: "Me preocupa que perdamos privacidad."','Me preocupa que perdamos privacidad',array[]::text[],'I''m worried we''ll lose privacy.',9),
  (v_lesson_id,'speaking','Say this aloud: "Cabe destacar el avance vertiginoso."','Cabe destacar el avance vertiginoso',array[]::text[],'It''s worth noting the vertiginous progress.',10);

  -- ===========================================================
  -- B2.3 PHILOSOPHY & ETHICS
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B2' and title = 'Philosophy & Ethics';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set intro='Philosophy and ethics vocabulary.',
    vocab_items='[{"word":"la moral","phonetic":"[moh-RAHL]","english":"morality","example_es":"La moral varía entre culturas.","example_en":"Morality varies across cultures."},{"word":"el dilema","phonetic":"[dee-LEH-mah]","english":"dilemma","example_es":"Es un dilema clásico.","example_en":"It''s a classic dilemma."},{"word":"el libre albedrío","phonetic":"[LEE-breh ahl-beh-DREE-oh]","english":"free will","example_es":"El libre albedrío sigue debatiéndose.","example_en":"Free will is still debated."},{"word":"justificar","phonetic":"[hoos-tee-fee-KAR]","english":"to justify","example_es":"¿Cómo se justifica una guerra?","example_en":"How do you justify a war?"}]'::jsonb,
    dialogue='[{"speaker":"Ana","spanish":"¿Crees que tenemos libre albedrío?","english":"Do you believe we have free will?"},{"speaker":"Luis","spanish":"Es un dilema clásico de la filosofía.","english":"It''s a classic philosophical dilemma."},{"speaker":"Ana","spanish":"La moral depende mucho del contexto.","english":"Morality depends a lot on context."}]'::jsonb,
    grammar_note='"Seguir + gerundio" = "to keep / continue doing": "sigue debatiéndose", "sigue creciendo". Common B2 construction.'
  where id = v_l1;
  update public.lessons set intro='Hypothetical structures with subjunctive.',
    vocab_items='[{"word":"si pudiera","phonetic":"[see poo-DYEH-rah]","english":"if I could","example_es":"Si pudiera elegir, cambiaría el sistema.","example_en":"If I could choose, I''d change the system."},{"word":"si hubiera","phonetic":"[see oo-BYEH-rah]","english":"if I had","example_es":"Si hubiera nacido en otro siglo.","example_en":"If I had been born in another century."},{"word":"sería preferible","phonetic":"[seh-REE-ah preh-feh-REE-bleh]","english":"it would be preferable","example_es":"Sería preferible no juzgar.","example_en":"It would be preferable not to judge."},{"word":"hipotéticamente","phonetic":"[ee-poh-TEH-tee-kah-MEHN-teh]","english":"hypothetically","example_es":"Hipotéticamente, todo es posible.","example_en":"Hypothetically, everything is possible."}]'::jsonb,
    dialogue='[{"speaker":"Eva","spanish":"Si pudiera vivir en otra época, elegiría la Ilustración.","english":"If I could live in another era, I''d choose the Enlightenment."},{"speaker":"Iván","spanish":"Hipotéticamente, ¿qué cambiarías?","english":"Hypothetically, what would you change?"},{"speaker":"Eva","spanish":"Sería preferible no juzgar antes de saber.","english":"It would be preferable not to judge before knowing."}]'::jsonb,
    grammar_note='"Si pudiera + conditional" / "si hubiera + past conditional" — second and third conditional. Hallmark B2 hypothetical structures.'
  where id = v_l2;
  update public.lessons set intro='Phrases for moral arguments.',
    vocab_items='[{"word":"desde un punto de vista ético","phonetic":"[POON-toh deh BEES-tah]","english":"from an ethical standpoint","example_es":"Desde un punto de vista ético, es inaceptable.","example_en":"From an ethical standpoint, it''s unacceptable."},{"word":"el fin no justifica los medios","phonetic":"[ehl feen]","english":"the end doesn''t justify the means","example_es":"El fin no justifica los medios.","example_en":"The end doesn''t justify the means."},{"word":"el imperativo","phonetic":"[eem-peh-rah-TEE-boh]","english":"imperative","example_es":"Es un imperativo moral ayudar.","example_en":"It''s a moral imperative to help."},{"word":"sin caer en","phonetic":"[seen kah-EHR ehn]","english":"without falling into","example_es":"Sin caer en el cinismo.","example_en":"Without falling into cynicism."}]'::jsonb,
    dialogue='[{"speaker":"Marta","spanish":"Desde un punto de vista ético, no podemos aceptar la tortura.","english":"From an ethical standpoint, we can''t accept torture."},{"speaker":"Pedro","spanish":"Aunque el fin sea bueno, no justifica los medios.","english":"Even if the end is good, it doesn''t justify the means."},{"speaker":"Marta","spanish":"Exacto. Es un imperativo moral.","english":"Exactly. It''s a moral imperative."}]'::jsonb,
    grammar_note='"Aunque + subjunctive" = "even if (hypothetical)": "aunque sea bueno". "Aunque + indicative" = "although (factual)". Subtle but B2-essential.'
  where id = v_l3;
  update public.lessons set intro='Listen to a philosophy lecture excerpt.',
    vocab_items='[{"word":"el utilitarismo","phonetic":"[oo-tee-lee-tah-REES-moh]","english":"utilitarianism","example_es":"El utilitarismo busca el mayor bien.","example_en":"Utilitarianism seeks the greatest good."},{"word":"el deontologismo","phonetic":"[deh-ohn-toh-loh-HEES-moh]","english":"deontology","example_es":"Para el deontologismo, los principios son absolutos.","example_en":"For deontology, principles are absolute."},{"word":"la consecuencia","phonetic":"[kohn-seh-KWEHN-syah]","english":"consequence","example_es":"Cada acción tiene consecuencias.","example_en":"Every action has consequences."},{"word":"el deber","phonetic":"[deh-BEHR]","english":"duty","example_es":"Cumplir con el deber moral.","example_en":"To fulfill moral duty."}]'::jsonb,
    dialogue='[{"speaker":"Profesor","spanish":"El utilitarismo evalúa una acción por sus consecuencias.","english":"Utilitarianism evaluates an action by its consequences."},{"speaker":"Profesor","spanish":"En cambio, el deontologismo prioriza el deber sobre las consecuencias.","english":"By contrast, deontology prioritises duty over consequences."},{"speaker":"Profesor","spanish":"Cada teoría plantea un dilema distinto.","english":"Each theory poses a different dilemma."}]'::jsonb,
    grammar_note='"En cambio" = "by contrast / on the other hand". A B2 connector with subtle nuance — softer than "sin embargo".'
  where id = v_l4;
  update public.lessons set intro='Defend a philosophical position.',
    vocab_items='[{"word":"Defiendo la idea de que","phonetic":"[deh-FYEHN-doh]","english":"I defend the idea that","example_es":"Defiendo la idea de que somos libres.","example_en":"I defend the idea that we are free."},{"word":"se podría argumentar","phonetic":"[seh poh-DREE-ah ahr-goo-mehn-TAR]","english":"it could be argued","example_es":"Se podría argumentar lo contrario.","example_en":"It could be argued otherwise."},{"word":"poner sobre la mesa","phonetic":"[poh-NEHR SOH-breh lah MEH-sah]","english":"to put on the table","example_es":"Pongo sobre la mesa otra perspectiva.","example_en":"I put another perspective on the table."},{"word":"rebatir","phonetic":"[rreh-bah-TEER]","english":"to refute","example_es":"Es difícil rebatir ese argumento.","example_en":"It''s hard to refute that argument."}]'::jsonb,
    dialogue='[{"speaker":"Tú","spanish":"Defiendo la idea de que el libre albedrío existe.","english":"I defend the idea that free will exists."},{"speaker":"Persona","spanish":"Se podría argumentar lo contrario, ¿no?","english":"It could be argued otherwise, no?"},{"speaker":"Tú","spanish":"Pongo sobre la mesa otra perspectiva, pero es difícil rebatir la experiencia subjetiva.","english":"I put another perspective on the table, but subjective experience is hard to refute."}]'::jsonb,
    grammar_note='"Se podría + infinitive" — impersonal conditional: "it could be done". Useful for hypothetical formal discussion.'
  where id = v_l5;
  update public.lessons set intro='Read a short philosophical text.',
    vocab_items='[{"word":"la conciencia","phonetic":"[kohn-SYEHN-syah]","english":"consciousness","example_es":"La conciencia es un misterio.","example_en":"Consciousness is a mystery."},{"word":"el determinismo","phonetic":"[deh-tehr-mee-NEES-moh]","english":"determinism","example_es":"El determinismo niega el libre albedrío.","example_en":"Determinism denies free will."},{"word":"imprescindible","phonetic":"[eem-prehs-seen-DEE-bleh]","english":"essential","example_es":"La ética es imprescindible.","example_en":"Ethics is essential."},{"word":"a fin de cuentas","phonetic":"[ah feen deh KWEHN-tahs]","english":"at the end of the day","example_es":"A fin de cuentas, decidimos nosotros.","example_en":"At the end of the day, we decide."}]'::jsonb,
    dialogue='[{"speaker":"Texto","spanish":"El debate entre libre albedrío y determinismo lleva siglos sin resolverse.","english":"The debate between free will and determinism has gone unresolved for centuries."},{"speaker":"Texto","spanish":"La ética sigue siendo imprescindible, independientemente de la respuesta.","english":"Ethics remains essential, regardless of the answer."},{"speaker":"Texto","spanish":"A fin de cuentas, vivimos como si fuéramos libres, y eso ya dice mucho.","english":"At the end of the day, we live as if we were free, and that already says a lot."}]'::jsonb,
    grammar_note='"Llevar + time + sin + infinitive" = "has gone X long without doing Y": "lleva siglos sin resolverse". Great B2 phrase.'
  where id = v_l6;
  update public.lessons set intro='Write a short philosophical essay.',
    vocab_items='[{"word":"plantearse","phonetic":"[plahn-teh-AR-seh]","english":"to wonder / pose to oneself","example_es":"Hay que plantearse preguntas difíciles.","example_en":"We have to ask ourselves hard questions."},{"word":"profundizar","phonetic":"[proh-foon-dee-SAR]","english":"to go deeper","example_es":"Conviene profundizar en el tema.","example_en":"It''s worth going deeper into the topic."},{"word":"en último término","phonetic":"[ehn OOL-tee-moh TEHR-mee-noh]","english":"ultimately","example_es":"En último término, nadie sabe.","example_en":"Ultimately, no one knows."},{"word":"abordar","phonetic":"[ah-bohr-DAR]","english":"to address","example_es":"Abordamos el problema con cuidado.","example_en":"We address the problem carefully."}]'::jsonb,
    dialogue='[{"speaker":"Modelo","spanish":"La filosofía nos obliga a plantearnos preguntas que evitamos en lo cotidiano.","english":"Philosophy forces us to ask ourselves questions we avoid in daily life."},{"speaker":"Modelo","spanish":"Conviene profundizar en cuestiones de ética antes de juzgar.","english":"It''s worth going deeper into ethical questions before judging."},{"speaker":"Modelo","spanish":"En último término, la reflexión nos hace más humanos.","english":"Ultimately, reflection makes us more human."}]'::jsonb,
    grammar_note='"Convenir + infinitive" = "it''s advisable / worth doing X". Impersonal use: "conviene profundizar", "conviene esperar". B2 essay register.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "free will"?','el libre albedrío',array['la moral','el dilema','la conciencia'],'free will',1),
  (v_l1,'fill_blank','Complete: "La ____ varía entre culturas." (morality)','moral',array['ética','virtud','justicia'],'morality',2),
  (v_l1,'multiple_choice','What does "justificar" mean?','to justify',array['to deny','to forgive','to repeat'],'to justify',3),
  (v_l1,'listening','What did you hear?','La moral depende mucho del contexto',array['¿Crees que tenemos libre albedrío?','Es un dilema clásico','La moral varía entre culturas'],'Morality depends a lot on context',4),
  (v_l1,'speaking','Say this aloud: "El libre albedrío sigue debatiéndose."','El libre albedrío sigue debatiéndose',array[]::text[],'Free will is still debated.',5),
  (v_l2,'multiple_choice','How to say "if I could"?','si pudiera',array['si tuviera','si fuera','si hubiera'],'if I could',1),
  (v_l2,'fill_blank','Complete: "Si ____ nacido en otro siglo." (had I)','hubiera',array['pudiera','fuera','tuviera'],'had I',2),
  (v_l2,'multiple_choice','What does "hipotéticamente" mean?','hypothetically',array['definitely','rarely','obviously'],'hypothetically',3),
  (v_l2,'listening','What did you hear?','Si pudiera vivir en otra época, elegiría la Ilustración',array['Hipotéticamente, ¿qué cambiarías?','Sería preferible no juzgar antes de saber','Si hubiera nacido en otro siglo'],'If I could live in another era, I''d choose the Enlightenment',4),
  (v_l2,'speaking','Say this aloud: "Sería preferible no juzgar."','Sería preferible no juzgar',array[]::text[],'It would be preferable not to judge.',5),
  (v_l3,'multiple_choice','How to say "from an ethical standpoint"?','desde un punto de vista ético',array['el fin justifica los medios','el imperativo','sin caer en'],'from an ethical standpoint',1),
  (v_l3,'fill_blank','Complete: "Es un ____ moral ayudar." (imperative)','imperativo',array['dilema','deber','principio'],'imperative',2),
  (v_l3,'multiple_choice','What does "sin caer en el cinismo" mean?','without falling into cynicism',array['without being noble','without being right','without giving up'],'without falling into cynicism',3),
  (v_l3,'listening','What did you hear?','Aunque el fin sea bueno, no justifica los medios',array['Desde un punto de vista ético','Es un imperativo moral','El fin no justifica los medios'],'Even if the end is good, it doesn''t justify the means',4),
  (v_l3,'speaking','Say this aloud: "El fin no justifica los medios."','El fin no justifica los medios',array[]::text[],'The end doesn''t justify the means.',5),
  (v_l4,'multiple_choice','What is "utilitarianism"?','el utilitarismo',array['el deontologismo','el determinismo','el imperativo'],'utilitarianism',1),
  (v_l4,'fill_blank','Complete: "Cumplir con el ____ moral." (duty)','deber',array['principio','dilema','dilemna'],'duty',2),
  (v_l4,'multiple_choice','What does "en cambio" mean?','by contrast',array['for example','therefore','suddenly'],'by contrast',3),
  (v_l4,'listening','What did you hear?','Cada teoría plantea un dilema distinto',array['El utilitarismo evalúa una acción por sus consecuencias','El deontologismo prioriza el deber','Cada acción tiene consecuencias'],'Each theory poses a different dilemma',4),
  (v_l4,'speaking','Say this aloud: "El utilitarismo busca el mayor bien."','El utilitarismo busca el mayor bien',array[]::text[],'Utilitarianism seeks the greatest good.',5),
  (v_l5,'multiple_choice','How to say "it could be argued"?','se podría argumentar',array['defiendo la idea de que','pongo sobre la mesa','rebatir'],'it could be argued',1),
  (v_l5,'fill_blank','Complete: "____ sobre la mesa otra perspectiva." (I put)','Pongo',array['Rebato','Defiendo','Argumenta'],'I put on the table',2),
  (v_l5,'multiple_choice','What does "rebatir" mean?','to refute',array['to defend','to ignore','to repeat'],'to refute',3),
  (v_l5,'listening','What did you hear?','Defiendo la idea de que el libre albedrío existe',array['Se podría argumentar lo contrario','Pongo sobre la mesa otra perspectiva','Es difícil rebatir ese argumento'],'I defend the idea that free will exists',4),
  (v_l5,'speaking','Say this aloud: "Se podría argumentar lo contrario."','Se podría argumentar lo contrario',array[]::text[],'It could be argued otherwise.',5),
  (v_l6,'multiple_choice','What is "consciousness"?','la conciencia',array['el determinismo','el utilitarismo','el deber'],'consciousness',1),
  (v_l6,'fill_blank','Complete: "La ética es ____" (essential)','imprescindible',array['imposible','probable','urgente'],'essential',2),
  (v_l6,'multiple_choice','What does "a fin de cuentas" mean?','at the end of the day',array['next week','first of all','suddenly'],'at the end of the day',3),
  (v_l6,'listening','What did you hear?','El debate lleva siglos sin resolverse',array['La ética sigue siendo imprescindible','Vivimos como si fuéramos libres','El determinismo niega el libre albedrío'],'The debate has gone unresolved for centuries',4),
  (v_l6,'speaking','Say this aloud: "Vivimos como si fuéramos libres."','Vivimos como si fuéramos libres',array[]::text[],'We live as if we were free.',5),
  (v_l7,'multiple_choice','How to say "to ask ourselves"?','plantearnos',array['profundizar','abordar','convenir'],'to ask ourselves',1),
  (v_l7,'fill_blank','Complete: "____ profundizar en el tema." (it''s worth)','Conviene',array['Permite','Prohíbe','Demuestra'],'it''s worth',2),
  (v_l7,'multiple_choice','What does "abordar" mean?','to address',array['to abort','to argue','to assist'],'to address',3),
  (v_l7,'listening','What did you hear?','En último término, la reflexión nos hace más humanos',array['La filosofía nos obliga a plantearnos preguntas','Conviene profundizar en cuestiones de ética','La filosofía nos obliga'],'Ultimately, reflection makes us more human',4),
  (v_l7,'speaking','Say this aloud: "Conviene profundizar en el tema."','Conviene profundizar en el tema',array[]::text[],'It''s worth going deeper into the topic.',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Es un dilema clásico de la filosofía',array['¿Crees que tenemos libre albedrío?','La moral varía entre culturas','¿Cómo se justifica una guerra?'],'It''s a classic philosophical dilemma',6),
  (v_l1,'listening','What did you hear?','El libre albedrío sigue debatiéndose',array['Es un dilema clásico','La moral varía','¿Cómo se justifica?'],'Free will is still debated',7),
  (v_l1,'speaking','Say this aloud: "Es un dilema clásico."','Es un dilema clásico',array[]::text[],'It''s a classic dilemma.',8),
  (v_l1,'speaking','Say this aloud: "¿Cómo se justifica una guerra?"','¿Cómo se justifica una guerra?',array[]::text[],'How do you justify a war?',9),
  (v_l2,'listening','What did you hear?','Si hubiera nacido en otro siglo',array['Si pudiera elegir','Sería preferible no juzgar','Hipotéticamente, todo es posible'],'If I had been born in another century',6),
  (v_l2,'listening','What did you hear?','Hipotéticamente, todo es posible',array['Si pudiera elegir','Si hubiera nacido','Sería preferible no juzgar'],'Hypothetically, everything is possible',7),
  (v_l2,'speaking','Say this aloud: "Si hubiera nacido en otro siglo."','Si hubiera nacido en otro siglo',array[]::text[],'If I had been born in another century.',8),
  (v_l2,'speaking','Say this aloud: "Si pudiera elegir, cambiaría el sistema."','Si pudiera elegir, cambiaría el sistema',array[]::text[],'If I could choose, I''d change the system.',9),
  (v_l3,'listening','What did you hear?','Es un imperativo moral ayudar',array['Sin caer en el cinismo','Desde un punto de vista ético','El fin no justifica los medios'],'It''s a moral imperative to help',6),
  (v_l3,'listening','What did you hear?','Sin caer en el cinismo',array['Es un imperativo moral','Aunque el fin sea bueno','Desde un punto de vista ético'],'Without falling into cynicism',7),
  (v_l3,'speaking','Say this aloud: "Desde un punto de vista ético, es inaceptable."','Desde un punto de vista ético, es inaceptable',array[]::text[],'From an ethical standpoint, it''s unacceptable.',8),
  (v_l3,'speaking','Say this aloud: "Sin caer en el cinismo."','Sin caer en el cinismo',array[]::text[],'Without falling into cynicism.',9),
  (v_l6,'listening','What did you hear?','La ética sigue siendo imprescindible',array['El debate lleva siglos sin resolverse','Vivimos como si fuéramos libres','El determinismo niega el libre albedrío'],'Ethics remains essential',6),
  (v_l6,'listening','What did you hear?','A fin de cuentas, decidimos nosotros',array['La conciencia es un misterio','La ética sigue siendo imprescindible','Vivimos como si fuéramos libres'],'At the end of the day, we decide',7),
  (v_l6,'speaking','Say this aloud: "A fin de cuentas, decidimos nosotros."','A fin de cuentas, decidimos nosotros',array[]::text[],'At the end of the day, we decide.',8),
  (v_l6,'speaking','Say this aloud: "La conciencia es un misterio."','La conciencia es un misterio',array[]::text[],'Consciousness is a mystery.',9),
  (v_l7,'listening','What did you hear?','Conviene profundizar en cuestiones de ética antes de juzgar',array['La filosofía nos obliga a plantearnos preguntas','En último término, la reflexión nos hace más humanos','Abordamos el problema con cuidado'],'It''s worth going deeper into ethical questions before judging',6),
  (v_l7,'listening','What did you hear?','La filosofía nos obliga a plantearnos preguntas',array['Conviene profundizar','En último término','Abordamos el problema'],'Philosophy forces us to ask ourselves questions',7),
  (v_l7,'speaking','Say this aloud: "Abordamos el problema con cuidado."','Abordamos el problema con cuidado',array[]::text[],'We address the problem carefully.',8),
  (v_l7,'speaking','Say this aloud: "En último término, nadie sabe."','En último término, nadie sabe',array[]::text[],'Ultimately, no one knows.',9);

  update public.lessons set type='conversation', title='Philosophy & Ethics — Conversation Practice',
    description='Two friends discuss free will and morality.',
    intro='Ana and Luis explore whether free will exists.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Ana","spanish":"¿Crees de verdad que tenemos libre albedrío?","english":"Do you really believe we have free will?"},{"speaker":"Luis","spanish":"Hipotéticamente, sí. Pero el determinismo es un argumento fuerte.","english":"Hypothetically, yes. But determinism is a strong argument."},{"speaker":"Ana","spanish":"Se podría argumentar que vivimos como si fuéramos libres, y eso basta.","english":"It could be argued that we live as if we were free, and that''s enough."},{"speaker":"Luis","spanish":"Si pudiera demostrarlo, ya lo habrían demostrado los filósofos.","english":"If it could be proved, philosophers would already have proved it."},{"speaker":"Ana","spanish":"A fin de cuentas, la ética sigue siendo imprescindible.","english":"At the end of the day, ethics remains essential."},{"speaker":"Luis","spanish":"En eso estamos de acuerdo, sin caer en el cinismo.","english":"On that we agree, without falling into cynicism."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','What does Luis say about free will?','Hypothetically yes',array['Definitely yes','Definitely no','He has no opinion'],'Hipotéticamente, sí',1),
  (v_l8,'multiple_choice','Ana''s argument?','We live as if we were free, that''s enough',array['Free will is proved','Determinism wins','Ethics doesn''t matter'],'vivimos como si fuéramos libres, y eso basta',2),
  (v_l8,'multiple_choice','True or false: Luis thinks philosophers have proved free will.','False',array['True'],'Si pudiera demostrarlo, ya lo habrían demostrado',3),
  (v_l8,'multiple_choice','What is essential according to Ana?','Ethics',array['Free will','Determinism','Philosophy'],'la ética sigue siendo imprescindible',4),
  (v_l8,'fill_blank','Complete: "Si ____ demostrarlo." (it could)','pudiera',array['fuera','hubiera','tuviera'],'it could',5),
  (v_l8,'multiple_choice','What do they agree on at the end?','Avoiding cynicism',array['Free will exists','Determinism is right','Philosophy is useless'],'sin caer en el cinismo',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Philosophy & Ethics', 'Review test for the Philosophy & Ethics section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "free will"?','el libre albedrío',array['la moral','el dilema','el deber'],'free will',1),
  (v_lesson_id,'multiple_choice','Imperfect subjunctive of "ser" (we)?','fuéramos',array['somos','éramos','seríamos'],'we were (subj)',2),
  (v_lesson_id,'multiple_choice','What does "aunque + subj" mean?','even if (hypothetical)',array['although (factual)','because','despite'],'even if',3),
  (v_lesson_id,'multiple_choice','True/false: "convenir + inf" expresses advisability.','True',array['False'],'conviene profundizar',4),
  (v_lesson_id,'fill_blank','Complete: "A fin de ____" (end of the day)','cuentas',array['vista','manera','contexto'],'at the end',5),
  (v_lesson_id,'fill_blank','Complete: "Se ____ argumentar lo contrario." (it could)','podría',array['puede','pudiera','poder'],'it could',6),
  (v_lesson_id,'listening','What did you hear?','La moral varía entre culturas',array['Es un dilema clásico de la filosofía','El libre albedrío sigue debatiéndose','¿Cómo se justifica una guerra?'],'Morality varies across cultures',7),
  (v_lesson_id,'listening','What did you hear?','Vivimos como si fuéramos libres',array['La ética sigue siendo imprescindible','El determinismo niega el libre albedrío','La conciencia es un misterio'],'We live as if we were free',8),
  (v_lesson_id,'speaking','Say this aloud: "Si pudiera elegir, cambiaría el sistema."','Si pudiera elegir, cambiaría el sistema',array[]::text[],'If I could choose, I''d change the system.',9),
  (v_lesson_id,'speaking','Say this aloud: "A fin de cuentas, la ética es imprescindible."','A fin de cuentas, la ética es imprescindible',array[]::text[],'At the end of the day, ethics is essential.',10);

end $$;

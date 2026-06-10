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

  -- ===========================================================
  -- B2.4 LITERATURE & POETRY
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B2' and title = 'Literature & Poetry';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set intro='Literary vocabulary at B2.',
    vocab_items='[{"word":"el verso","phonetic":"[BEHR-soh]","english":"verse","example_es":"Cada verso esconde un sentido.","example_en":"Each verse hides a meaning."},{"word":"la metáfora","phonetic":"[meh-TAH-foh-rah]","english":"metaphor","example_es":"Una metáfora poderosa.","example_en":"A powerful metaphor."},{"word":"el narrador","phonetic":"[nah-rrah-DOHR]","english":"narrator","example_es":"El narrador es poco fiable.","example_en":"The narrator is unreliable."},{"word":"trasfondo","phonetic":"[trahs-FOHN-doh]","english":"backdrop","example_es":"El trasfondo histórico es clave.","example_en":"The historical backdrop is key."}]'::jsonb,
    dialogue='[{"speaker":"Eva","spanish":"Cada verso esconde una metáfora.","english":"Each verse hides a metaphor."},{"speaker":"Luis","spanish":"El narrador es poco fiable.","english":"The narrator is unreliable."},{"speaker":"Eva","spanish":"Eso enriquece la lectura.","english":"That enriches the reading."}]'::jsonb,
    grammar_note='"Poco + adjective" softens a negative: "poco fiable" = "unreliable" (rather than "muy poco fiable"). B2 register.'
  where id = v_l1;
  update public.lessons set intro='Subjunctive after expressions of emotion.',
    vocab_items='[{"word":"me sorprende que","phonetic":"[meh sohr-PREHN-deh keh]","english":"it surprises me that","example_es":"Me sorprende que escriba así.","example_en":"It surprises me that he writes that way."},{"word":"lamento que","phonetic":"[lah-MEHN-toh keh]","english":"I regret that","example_es":"Lamento que sea tan corto.","example_en":"I regret that it''s so short."},{"word":"qué pena que","phonetic":"[keh PEH-nah keh]","english":"what a pity that","example_es":"Qué pena que muriera joven.","example_en":"What a pity he died young."},{"word":"resulta increíble que","phonetic":"[rreh-SOOL-tah]","english":"it''s incredible that","example_es":"Resulta increíble que sea su primer libro.","example_en":"It''s incredible that this is his first book."}]'::jsonb,
    dialogue='[{"speaker":"Ana","spanish":"Me sorprende que aún no haya ganado un premio.","english":"It surprises me he hasn''t won a prize yet."},{"speaker":"Marco","spanish":"Lamento que sus libros no se traduzcan más.","english":"I regret that his books aren''t translated more."},{"speaker":"Ana","spanish":"Qué pena que muriera joven.","english":"What a pity he died young."}]'::jsonb,
    grammar_note='Expressions of emotion trigger subjunctive: "me sorprende QUE haya", "lamento QUE sea", "qué pena QUE muriera". A B2 cornerstone.'
  where id = v_l2;
  update public.lessons set intro='Phrases for literary discussion.',
    vocab_items='[{"word":"está bien logrado","phonetic":"[ehs-TAH byehn loh-GRAH-doh]","english":"it''s well done","example_es":"El final está muy bien logrado.","example_en":"The ending is very well done."},{"word":"deja huella","phonetic":"[DEH-hah WEH-yah]","english":"leaves a mark","example_es":"Es un libro que deja huella.","example_en":"It''s a book that leaves a mark."},{"word":"se hace pesado","phonetic":"[seh AH-seh peh-SAH-doh]","english":"becomes tedious","example_es":"La trama se hace pesada.","example_en":"The plot becomes tedious."},{"word":"a mitad de camino","phonetic":"[ah mee-TAHD deh kah-MEE-noh]","english":"halfway through","example_es":"Abandoné a mitad de camino.","example_en":"I gave up halfway through."}]'::jsonb,
    dialogue='[{"speaker":"Marta","spanish":"El final está muy bien logrado.","english":"The ending is very well done."},{"speaker":"Pedro","spanish":"Para mí, la trama se hace pesada a mitad de camino.","english":"For me, the plot becomes tedious halfway through."},{"speaker":"Marta","spanish":"Pero deja huella.","english":"But it leaves a mark."}]'::jsonb,
    grammar_note='"Hacerse + adjective" = "to become" (gradual): "se hace pesado", "se hace difícil". Different from "ponerse" (sudden change).'
  where id = v_l3;
  update public.lessons set intro='Listen to a book review podcast.',
    vocab_items='[{"word":"la prosa","phonetic":"[PROH-sah]","english":"prose","example_es":"Una prosa cuidadísima.","example_en":"Extremely careful prose."},{"word":"sorprender al lector","phonetic":"[sohr-prehn-DEHR]","english":"to surprise the reader","example_es":"El giro sorprende al lector.","example_en":"The twist surprises the reader."},{"word":"un golpe maestro","phonetic":"[GOHL-peh mah-EHS-troh]","english":"a masterstroke","example_es":"El final es un golpe maestro.","example_en":"The ending is a masterstroke."},{"word":"polémica","phonetic":"[poh-LEH-mee-kah]","english":"controversy","example_es":"La novela generó polémica.","example_en":"The novel sparked controversy."}]'::jsonb,
    dialogue='[{"speaker":"Locutor","spanish":"La nueva novela de Vila-Matas presenta una prosa cuidadísima.","english":"Vila-Matas''s new novel features extremely careful prose."},{"speaker":"Locutor","spanish":"El giro final es un golpe maestro que sorprende al lector.","english":"The final twist is a masterstroke that surprises the reader."},{"speaker":"Locutor","spanish":"No falta polémica: el autor cuestiona la propia narración.","english":"Controversy isn''t lacking: the author questions narration itself."}]'::jsonb,
    grammar_note='"-ísimo/-ísima" intensifier: "cuidadísima" = "extremely careful". Adds emphasis without "muy". B2 essential.'
  where id = v_l4;
  update public.lessons set intro='Discuss a book you admire.',
    vocab_items='[{"word":"Me marcó profundamente","phonetic":"[meh mahr-KOH]","english":"It deeply marked me","example_es":"Me marcó profundamente este libro.","example_en":"This book deeply marked me."},{"word":"Lo releo cada año","phonetic":"[loh rreh-LEH-oh]","english":"I reread it every year","example_es":"Lo releo cada año.","example_en":"I reread it every year."},{"word":"Es de obligada lectura","phonetic":"[ohb-lee-GAH-dah]","english":"It''s essential reading","example_es":"Es de obligada lectura.","example_en":"It''s essential reading."},{"word":"un clásico moderno","phonetic":"[KLAH-see-koh moh-DEHR-noh]","english":"a modern classic","example_es":"Se ha vuelto un clásico moderno.","example_en":"It has become a modern classic."}]'::jsonb,
    dialogue='[{"speaker":"Tú","spanish":"Cien años de soledad me marcó profundamente.","english":"One Hundred Years of Solitude deeply marked me."},{"speaker":"Amigo","spanish":"¿Lo recomendarías?","english":"Would you recommend it?"},{"speaker":"Tú","spanish":"Es de obligada lectura. Lo releo cada cinco años.","english":"It''s essential reading. I reread it every five years."}]'::jsonb,
    grammar_note='"Volverse + adjective/noun" = "to become" (slower, often permanent change): "se ha vuelto un clásico". Compare with "convertirse en" (active process).'
  where id = v_l5;
  update public.lessons set intro='Read a literary essay extract.',
    vocab_items='[{"word":"el simbolismo","phonetic":"[seem-boh-LEES-moh]","english":"symbolism","example_es":"El simbolismo es denso.","example_en":"The symbolism is dense."},{"word":"contrastar","phonetic":"[kohn-trahs-TAR]","english":"to contrast","example_es":"Contrasta luz y sombra.","example_en":"It contrasts light and shadow."},{"word":"a través de","phonetic":"[ah trah-BEHS deh]","english":"through","example_es":"A través de la metáfora.","example_en":"Through metaphor."},{"word":"perdurar","phonetic":"[pehr-doo-RAR]","english":"to endure","example_es":"Su obra perdurará en el tiempo.","example_en":"His work will endure over time."}]'::jsonb,
    dialogue='[{"speaker":"Texto","spanish":"A través de un simbolismo denso, García Lorca contrasta vida y muerte.","english":"Through dense symbolism, García Lorca contrasts life and death."},{"speaker":"Texto","spanish":"Su obra perdurará porque toca lo universal.","english":"His work will endure because it touches the universal."},{"speaker":"Texto","spanish":"Resulta imposible separarlo de su época histórica.","english":"It''s impossible to separate him from his historical era."}]'::jsonb,
    grammar_note='"Resulta + adjective" = "it turns out to be / proves" (formal): "resulta imposible", "resulta evidente". Common in essay register.'
  where id = v_l6;
  update public.lessons set intro='Write a short book review.',
    vocab_items='[{"word":"sin caer en clichés","phonetic":"[seen kah-EHR]","english":"without falling into clichés","example_es":"Aborda el amor sin caer en clichés.","example_en":"It addresses love without falling into clichés."},{"word":"a primera vista","phonetic":"[ah pree-MEH-rah BEES-tah]","english":"at first glance","example_es":"A primera vista parece simple.","example_en":"At first glance it seems simple."},{"word":"capa de significado","phonetic":"[KAH-pah]","english":"layer of meaning","example_es":"Cada lectura revela otra capa de significado.","example_en":"Each reading reveals another layer of meaning."},{"word":"recomendable","phonetic":"[rreh-koh-mehn-DAH-bleh]","english":"recommendable","example_es":"Una novela altamente recomendable.","example_en":"A highly recommendable novel."}]'::jsonb,
    dialogue='[{"speaker":"Modelo","spanish":"A primera vista parece una novela simple, pero esconde varias capas de significado.","english":"At first glance it seems a simple novel, but it hides several layers of meaning."},{"speaker":"Modelo","spanish":"La autora aborda temas universales sin caer en clichés.","english":"The author addresses universal themes without falling into clichés."},{"speaker":"Modelo","spanish":"Altamente recomendable para cualquier lector exigente.","english":"Highly recommendable for any demanding reader."}]'::jsonb,
    grammar_note='"Altamente + adjective" = formal intensifier: "altamente recomendable", "altamente improbable". More elevated than "muy".'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "verse"?','el verso',array['la metáfora','el narrador','el trasfondo'],'verse',1),
  (v_l1,'fill_blank','Complete: "El narrador es ____ fiable." (un-)','poco',array['muy','nada','algo'],'unreliable',2),
  (v_l1,'multiple_choice','What does "trasfondo" mean?','backdrop',array['translator','foreground','prologue'],'backdrop',3),
  (v_l1,'listening','What did you hear?','El narrador es poco fiable',array['Cada verso esconde un sentido','Una metáfora poderosa','El trasfondo histórico es clave'],'The narrator is unreliable',4),
  (v_l1,'speaking','Say this aloud: "Una metáfora poderosa."','Una metáfora poderosa',array[]::text[],'A powerful metaphor.',5),
  (v_l2,'multiple_choice','What follows "me sorprende que"?','subjunctive',array['indicative','preterite','imperfect'],'subjunctive',1),
  (v_l2,'fill_blank','Complete: "Lamento que ____ tan corto." (it''s - subj)','sea',array['es','era','será'],'be (subj)',2),
  (v_l2,'multiple_choice','What does "qué pena que" mean?','what a pity that',array['what a joy that','what a doubt that','what an idea that'],'what a pity that',3),
  (v_l2,'listening','What did you hear?','Me sorprende que aún no haya ganado un premio',array['Lamento que sus libros no se traduzcan','Qué pena que muriera joven','Resulta increíble que sea su primer libro'],'It surprises me he hasn''t won a prize yet',4),
  (v_l2,'speaking','Say this aloud: "Qué pena que muriera joven."','Qué pena que muriera joven',array[]::text[],'What a pity he died young.',5),
  (v_l3,'multiple_choice','How to say "it leaves a mark"?','deja huella',array['está bien logrado','se hace pesado','a mitad de camino'],'leaves a mark',1),
  (v_l3,'fill_blank','Complete: "Abandoné a ____ de camino." (halfway)','mitad',array['mediados','medio','poco'],'halfway',2),
  (v_l3,'multiple_choice','What does "se hace pesado" mean?','becomes tedious',array['gets heavy','breaks down','speeds up'],'becomes tedious',3),
  (v_l3,'listening','What did you hear?','El final está muy bien logrado',array['La trama se hace pesada a mitad de camino','Es un libro que deja huella','Abandoné a mitad de camino'],'The ending is very well done',4),
  (v_l3,'speaking','Say this aloud: "Es un libro que deja huella."','Es un libro que deja huella',array[]::text[],'It''s a book that leaves a mark.',5),
  (v_l4,'multiple_choice','What is "prose"?','la prosa',array['el verso','la trama','el simbolismo'],'prose',1),
  (v_l4,'fill_blank','Complete: "Es un ____ maestro." (stroke)','golpe',array['libro','final','autor'],'masterstroke',2),
  (v_l4,'multiple_choice','What does "polémica" mean?','controversy',array['praise','translation','review'],'controversy',3),
  (v_l4,'listening','What did you hear?','El giro final es un golpe maestro que sorprende al lector',array['Una prosa cuidadísima','El autor cuestiona la propia narración','La novela generó polémica'],'The final twist is a masterstroke that surprises the reader',4),
  (v_l4,'speaking','Say this aloud: "Una prosa cuidadísima."','Una prosa cuidadísima',array[]::text[],'Extremely careful prose.',5),
  (v_l5,'multiple_choice','How to say "essential reading"?','de obligada lectura',array['me marcó profundamente','un clásico moderno','lo releo cada año'],'essential reading',1),
  (v_l5,'fill_blank','Complete: "Se ha ____ un clásico moderno." (become)','vuelto',array['hecho','convertido','puesto'],'become',2),
  (v_l5,'multiple_choice','What does "me marcó profundamente" mean?','It deeply marked me',array['I deeply marked it','It marked me lightly','I deeply forgot it'],'It deeply marked me',3),
  (v_l5,'listening','What did you hear?','Es de obligada lectura. Lo releo cada cinco años',array['Cien años de soledad me marcó profundamente','¿Lo recomendarías?','Se ha vuelto un clásico moderno'],'It''s essential reading. I reread it every five years',4),
  (v_l5,'speaking','Say this aloud: "Lo releo cada año."','Lo releo cada año',array[]::text[],'I reread it every year.',5),
  (v_l6,'multiple_choice','What is "symbolism"?','el simbolismo',array['el simbolismo magistral','la metáfora','el verso'],'symbolism',1),
  (v_l6,'fill_blank','Complete: "Su obra ____ en el tiempo." (will endure)','perdurará',array['acabará','crecerá','viajará'],'will endure',2),
  (v_l6,'multiple_choice','What does "contrastar" mean?','to contrast',array['to compare','to confuse','to confirm'],'to contrast',3),
  (v_l6,'listening','What did you hear?','A través de un simbolismo denso, García Lorca contrasta vida y muerte',array['Su obra perdurará porque toca lo universal','Resulta imposible separarlo de su época histórica','Toca lo universal'],'Through dense symbolism, García Lorca contrasts life and death',4),
  (v_l6,'speaking','Say this aloud: "Su obra perdurará en el tiempo."','Su obra perdurará en el tiempo',array[]::text[],'His work will endure over time.',5),
  (v_l7,'multiple_choice','How to say "at first glance"?','a primera vista',array['sin caer en clichés','capa de significado','recomendable'],'at first glance',1),
  (v_l7,'fill_blank','Complete: "Cada lectura revela otra ____ de significado." (layer)','capa',array['página','línea','idea'],'layer',2),
  (v_l7,'multiple_choice','What does "altamente recomendable" mean?','highly recommendable',array['lightly recommendable','barely recommendable','controversial'],'highly recommendable',3),
  (v_l7,'listening','What did you hear?','A primera vista parece una novela simple, pero esconde varias capas de significado',array['La autora aborda temas universales sin caer en clichés','Altamente recomendable para cualquier lector exigente','Una novela altamente recomendable'],'At first glance it seems a simple novel, but it hides several layers of meaning',4),
  (v_l7,'speaking','Say this aloud: "Aborda temas universales sin caer en clichés."','Aborda temas universales sin caer en clichés',array[]::text[],'It addresses universal themes without falling into clichés.',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Cada verso esconde un sentido',array['Una metáfora poderosa','El trasfondo histórico es clave','El narrador es poco fiable'],'Each verse hides a meaning',6),
  (v_l1,'listening','What did you hear?','El trasfondo histórico es clave',array['Cada verso esconde un sentido','Una metáfora poderosa','El narrador es poco fiable'],'The historical backdrop is key',7),
  (v_l1,'speaking','Say this aloud: "El trasfondo histórico es clave."','El trasfondo histórico es clave',array[]::text[],'The historical backdrop is key.',8),
  (v_l1,'speaking','Say this aloud: "Cada verso esconde un sentido."','Cada verso esconde un sentido',array[]::text[],'Each verse hides a meaning.',9),
  (v_l2,'listening','What did you hear?','Resulta increíble que sea su primer libro',array['Me sorprende que escriba así','Lamento que sea tan corto','Qué pena que muriera joven'],'It''s incredible that this is his first book',6),
  (v_l2,'listening','What did you hear?','Lamento que sus libros no se traduzcan más',array['Me sorprende que aún no haya ganado','Qué pena que muriera joven','Resulta increíble'],'I regret that his books aren''t translated more',7),
  (v_l2,'speaking','Say this aloud: "Resulta increíble que sea su primer libro."','Resulta increíble que sea su primer libro',array[]::text[],'It''s incredible that this is his first book.',8),
  (v_l2,'speaking','Say this aloud: "Lamento que sea tan corto."','Lamento que sea tan corto',array[]::text[],'I regret that it''s so short.',9),
  (v_l3,'listening','What did you hear?','Pero deja huella',array['El final está muy bien logrado','La trama se hace pesada','Abandoné a mitad de camino'],'But it leaves a mark',6),
  (v_l3,'listening','What did you hear?','La trama se hace pesada',array['El final está muy bien logrado','Es un libro que deja huella','Abandoné a mitad de camino'],'The plot becomes tedious',7),
  (v_l3,'speaking','Say this aloud: "La trama se hace pesada."','La trama se hace pesada',array[]::text[],'The plot becomes tedious.',8),
  (v_l3,'speaking','Say this aloud: "Abandoné a mitad de camino."','Abandoné a mitad de camino',array[]::text[],'I gave up halfway through.',9),
  (v_l6,'listening','What did you hear?','Su obra perdurará porque toca lo universal',array['A través de un simbolismo denso','Resulta imposible separarlo de su época','García Lorca contrasta vida y muerte'],'His work will endure because it touches the universal',6),
  (v_l6,'listening','What did you hear?','Resulta imposible separarlo de su época histórica',array['A través de un simbolismo denso','Su obra perdurará','García Lorca contrasta'],'It''s impossible to separate him from his historical era',7),
  (v_l6,'speaking','Say this aloud: "El simbolismo es denso."','El simbolismo es denso',array[]::text[],'The symbolism is dense.',8),
  (v_l6,'speaking','Say this aloud: "A través de la metáfora."','A través de la metáfora',array[]::text[],'Through metaphor.',9),
  (v_l7,'listening','What did you hear?','La autora aborda temas universales sin caer en clichés',array['A primera vista parece una novela simple','Cada lectura revela otra capa de significado','Altamente recomendable'],'The author addresses universal themes without falling into clichés',6),
  (v_l7,'listening','What did you hear?','Altamente recomendable para cualquier lector exigente',array['Aborda temas universales','A primera vista parece simple','Esconde varias capas'],'Highly recommendable for any demanding reader',7),
  (v_l7,'speaking','Say this aloud: "Cada lectura revela otra capa de significado."','Cada lectura revela otra capa de significado',array[]::text[],'Each reading reveals another layer of meaning.',8),
  (v_l7,'speaking','Say this aloud: "Altamente recomendable."','Altamente recomendable',array[]::text[],'Highly recommendable.',9);

  update public.lessons set type='conversation', title='Literature & Poetry — Conversation Practice',
    description='Two literature lovers debate a recent novel.',
    intro='Eva and Marco discuss Vila-Matas''s newest book.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Eva","spanish":"¿Qué te pareció la nueva de Vila-Matas?","english":"What did you think of Vila-Matas''s latest?"},{"speaker":"Marco","spanish":"Una prosa cuidadísima, aunque la trama se hace pesada a mitad de camino.","english":"Extremely careful prose, although the plot becomes tedious halfway through."},{"speaker":"Eva","spanish":"Me sorprende que digas eso. El giro final es un golpe maestro.","english":"It surprises me you''d say that. The final twist is a masterstroke."},{"speaker":"Marco","spanish":"Lo admito, el final está bien logrado. Pero el narrador es poco fiable.","english":"I admit, the ending is well done. But the narrator is unreliable."},{"speaker":"Eva","spanish":"Exacto, eso enriquece la lectura. Capa tras capa de significado.","english":"Exactly, that enriches the reading. Layer after layer of meaning."},{"speaker":"Marco","spanish":"Altamente recomendable, pero no para todos.","english":"Highly recommendable, but not for everyone."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','How does Marco describe the prose?','Extremely careful',array['Boring','Sloppy','Brief'],'Una prosa cuidadísima',1),
  (v_l8,'multiple_choice','When does the plot become tedious for Marco?','Halfway through',array['From the start','At the end','Never'],'la trama se hace pesada a mitad de camino',2),
  (v_l8,'multiple_choice','How does Eva describe the final twist?','A masterstroke',array['Predictable','Confusing','Bad'],'un golpe maestro',3),
  (v_l8,'multiple_choice','True or false: Marco finds the narrator unreliable.','True',array['False'],'el narrador es poco fiable',4),
  (v_l8,'fill_blank','Complete: "Me ____ que digas eso." (it surprises me)','sorprende',array['lamenta','encanta','molesta'],'it surprises me',5),
  (v_l8,'multiple_choice','Marco''s final verdict?','Highly recommendable but not for everyone',array['Terrible','Perfect','Boring'],'Altamente recomendable, pero no para todos',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Literature & Poetry', 'Review test for the Literature & Poetry section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "metaphor"?','la metáfora',array['el verso','el narrador','el trasfondo'],'metaphor',1),
  (v_lesson_id,'multiple_choice','"Me sorprende que" triggers...','subjunctive',array['preterite','imperfect','indicative'],'subjunctive',2),
  (v_lesson_id,'multiple_choice','What does "perdurar" mean?','to endure',array['to perish','to publish','to plagiarise'],'to endure',3),
  (v_lesson_id,'multiple_choice','True/false: "altamente recomendable" = highly recommendable (formal).','True',array['False'],'altamente = formal intensifier',4),
  (v_lesson_id,'fill_blank','Complete: "Resulta ____ que sea su primer libro." (incredible)','increíble',array['posible','difícil','evidente'],'incredible',5),
  (v_lesson_id,'fill_blank','Complete: "A primera ____" (glance)','vista',array['mirada','mirando','ojo'],'glance',6),
  (v_lesson_id,'listening','What did you hear?','Es un libro que deja huella',array['El final está muy bien logrado','La trama se hace pesada','Abandoné a mitad de camino'],'It''s a book that leaves a mark',7),
  (v_lesson_id,'listening','What did you hear?','Su obra perdurará porque toca lo universal',array['A través de un simbolismo denso','García Lorca contrasta vida y muerte','Resulta imposible separarlo'],'His work will endure because it touches the universal',8),
  (v_lesson_id,'speaking','Say this aloud: "Qué pena que muriera joven."','Qué pena que muriera joven',array[]::text[],'What a pity he died young.',9),
  (v_lesson_id,'speaking','Say this aloud: "Aborda temas universales sin caer en clichés."','Aborda temas universales sin caer en clichés',array[]::text[],'It addresses universal themes without falling into clichés.',10);

  -- ===========================================================
  -- B2.5 BUSINESS & ECONOMICS
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B2' and title = 'Business & Economics';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set intro='Business and economics vocabulary at B2.',
    vocab_items='[{"word":"el mercado","phonetic":"[mehr-KAH-doh]","english":"market","example_es":"El mercado está volátil.","example_en":"The market is volatile."},{"word":"la inflación","phonetic":"[een-flah-SYOHN]","english":"inflation","example_es":"La inflación afecta a todos.","example_en":"Inflation affects everyone."},{"word":"el déficit","phonetic":"[DEH-fee-seet]","english":"deficit","example_es":"El déficit público creció.","example_en":"The public deficit grew."},{"word":"la inversión","phonetic":"[een-behr-SYOHN]","english":"investment","example_es":"Necesitamos más inversión.","example_en":"We need more investment."}]'::jsonb,
    dialogue='[{"speaker":"Ana","spanish":"El mercado está muy volátil últimamente.","english":"The market has been very volatile lately."},{"speaker":"Luis","spanish":"La inflación complica todo.","english":"Inflation complicates everything."},{"speaker":"Ana","spanish":"Sin inversión, será difícil recuperarnos.","english":"Without investment, it will be hard to recover."}]'::jsonb,
    grammar_note='"Últimamente" placed at the end or mid-sentence: "está volátil últimamente". Don''t use "recientemente" — that''s more like "recently in a specific past event".'
  where id = v_l1;
  update public.lessons set intro='Conditional perfect and si-clauses for finance.',
    vocab_items='[{"word":"habríamos evitado","phonetic":"[ah-BREE-ah-mohs eh-bee-TAH-doh]","english":"we would have avoided","example_es":"Habríamos evitado la crisis.","example_en":"We would have avoided the crisis."},{"word":"si hubieran intervenido","phonetic":"[see oo-BYEH-rahn]","english":"if they had intervened","example_es":"Si hubieran intervenido antes...","example_en":"If they had intervened earlier..."},{"word":"a tiempo","phonetic":"[ah TYEHM-poh]","english":"in time","example_es":"No actuaron a tiempo.","example_en":"They didn''t act in time."},{"word":"diversificar","phonetic":"[dee-behr-see-fee-KAR]","english":"to diversify","example_es":"Diversificar la cartera reduce riesgos.","example_en":"Diversifying the portfolio reduces risk."}]'::jsonb,
    dialogue='[{"speaker":"Eva","spanish":"Si hubieran intervenido a tiempo, habríamos evitado la crisis.","english":"If they had intervened in time, we would have avoided the crisis."},{"speaker":"Iván","spanish":"Por eso conviene diversificar la cartera.","english":"That''s why it''s wise to diversify the portfolio."},{"speaker":"Eva","spanish":"Sí, no poner todos los huevos en una cesta.","english":"Yes, don''t put all your eggs in one basket."}]'::jsonb,
    grammar_note='Third conditional: "si + hubiera/hubieran + participle, habría/habríamos + participle". Standard B2 for counterfactual past.'
  where id = v_l2;
  update public.lessons set intro='Phrases for business meetings.',
    vocab_items='[{"word":"cifras récord","phonetic":"[SEE-frahs RREH-kohrd]","english":"record figures","example_es":"Alcanzamos cifras récord.","example_en":"We hit record figures."},{"word":"recortar gastos","phonetic":"[rreh-kohr-TAR GAHS-tohs]","english":"to cut expenses","example_es":"Hay que recortar gastos.","example_en":"We have to cut expenses."},{"word":"a corto plazo","phonetic":"[ah KOHR-toh PLAH-soh]","english":"short-term","example_es":"A corto plazo, perderemos.","example_en":"Short-term, we''ll lose."},{"word":"rentable","phonetic":"[rrehn-TAH-bleh]","english":"profitable","example_es":"El proyecto es rentable.","example_en":"The project is profitable."}]'::jsonb,
    dialogue='[{"speaker":"Marta","spanish":"Este trimestre alcanzamos cifras récord.","english":"This quarter we hit record figures."},{"speaker":"Pedro","spanish":"Aun así, hay que recortar gastos.","english":"Even so, we have to cut expenses."},{"speaker":"Marta","spanish":"A corto plazo duele, pero será rentable.","english":"Short-term it hurts, but it will be profitable."}]'::jsonb,
    grammar_note='"Aun así" = "even so / still". Two words. Don''t confuse with "aún así" (= "even still", much rarer).'
  where id = v_l3;
  update public.lessons set intro='Listen to a financial news broadcast.',
    vocab_items='[{"word":"la bolsa","phonetic":"[BOHL-sah]","english":"stock exchange","example_es":"La bolsa subió tres puntos.","example_en":"The exchange rose three points."},{"word":"el PIB","phonetic":"[peh ee beh]","english":"GDP","example_es":"El PIB creció un 2%.","example_en":"GDP grew 2%."},{"word":"el desempleo","phonetic":"[deh-sehm-PLEH-oh]","english":"unemployment","example_es":"El desempleo baja.","example_en":"Unemployment is falling."},{"word":"la prima de riesgo","phonetic":"[PREE-mah deh RRYEHS-goh]","english":"risk premium","example_es":"La prima de riesgo se disparó.","example_en":"The risk premium spiked."}]'::jsonb,
    dialogue='[{"speaker":"Locutor","spanish":"La bolsa cerró con una subida del tres por ciento.","english":"The exchange closed up three percent."},{"speaker":"Locutor","spanish":"El PIB creció un dos por ciento en el último trimestre.","english":"GDP grew two percent in the last quarter."},{"speaker":"Locutor","spanish":"El desempleo continúa su tendencia a la baja.","english":"Unemployment continues its downward trend."}]'::jsonb,
    grammar_note='"Tendencia a la baja / al alza" = "downward / upward trend". Common in financial news.'
  where id = v_l4;
  update public.lessons set intro='Discuss your finances or job.',
    vocab_items='[{"word":"Trabajo en una multinacional","phonetic":"[mool-tee-nah-syoh-NAHL]","english":"I work at a multinational","example_es":"Trabajo en una multinacional desde hace años.","example_en":"I''ve worked at a multinational for years."},{"word":"Mi sector","phonetic":"[mee sehk-TOHR]","english":"My sector","example_es":"Mi sector está en crecimiento.","example_en":"My sector is growing."},{"word":"Diversifico mis ahorros","phonetic":"[ah-OH-rrohs]","english":"I diversify my savings","example_es":"Diversifico mis ahorros entre fondos y depósitos.","example_en":"I diversify my savings between funds and deposits."},{"word":"Buscar oportunidades","phonetic":"[ohp-pohr-too-nee-DAH-dehs]","english":"to look for opportunities","example_es":"Siempre busco oportunidades nuevas.","example_en":"I''m always looking for new opportunities."}]'::jsonb,
    dialogue='[{"speaker":"Tú","spanish":"Trabajo en una multinacional desde hace cinco años.","english":"I''ve worked at a multinational for five years."},{"speaker":"Persona","spanish":"¿En qué sector?","english":"In what sector?"},{"speaker":"Tú","spanish":"En tecnología. Mi sector está en crecimiento y diversifico mis ahorros.","english":"In tech. My sector is growing and I diversify my savings."}]'::jsonb,
    grammar_note='"Desde hace + time" = "for / since X time" (still ongoing). Equivalent to "llevo + time + sin/gerund". Use either.'
  where id = v_l5;
  update public.lessons set intro='Read a financial column.',
    vocab_items='[{"word":"un ciclo expansivo","phonetic":"[ehks-pahn-SEE-boh]","english":"an expansionary cycle","example_es":"Estamos en un ciclo expansivo.","example_en":"We are in an expansionary cycle."},{"word":"contracción","phonetic":"[kohn-trahk-SYOHN]","english":"contraction","example_es":"La contracción duró dos años.","example_en":"The contraction lasted two years."},{"word":"el banco central","phonetic":"[BAHN-koh sehn-TRAHL]","english":"central bank","example_es":"El banco central subió los tipos.","example_en":"The central bank raised rates."},{"word":"controlar la inflación","phonetic":"[een-flah-SYOHN]","english":"to control inflation","example_es":"Buscan controlar la inflación.","example_en":"They aim to control inflation."}]'::jsonb,
    dialogue='[{"speaker":"Texto","spanish":"Tras dos años de contracción, la economía entra en un ciclo expansivo.","english":"After two years of contraction, the economy enters an expansionary cycle."},{"speaker":"Texto","spanish":"El banco central subió los tipos de interés para controlar la inflación.","english":"The central bank raised interest rates to control inflation."},{"speaker":"Texto","spanish":"Los analistas prevén un PIB del tres por ciento el año que viene.","english":"Analysts forecast a 3% GDP next year."}]'::jsonb,
    grammar_note='"Prever" (irregular: preveo, prevés, prevé, prevemos, preveis, prevén) — to forecast / foresee. B2 essential in financial Spanish.'
  where id = v_l6;
  update public.lessons set intro='Write a business email.',
    vocab_items='[{"word":"Estimados señores","phonetic":"[ehs-tee-MAH-dohs seh-NYOH-rehs]","english":"Dear sirs/madams","example_es":"Estimados señores: les escribo para...","example_en":"Dear sirs/madams, I''m writing to..."},{"word":"adjuntar","phonetic":"[ahd-hoon-TAR]","english":"to attach","example_es":"Adjunto el informe anual.","example_en":"I''m attaching the annual report."},{"word":"a su disposición","phonetic":"[ah soo dees-poh-see-SYOHN]","english":"at your disposal","example_es":"Quedo a su disposición.","example_en":"I remain at your disposal."},{"word":"un cordial saludo","phonetic":"[kohr-DYAHL]","english":"kind regards","example_es":"Un cordial saludo.","example_en":"Kind regards."}]'::jsonb,
    dialogue='[{"speaker":"Modelo","spanish":"Estimados señores: les escribo para confirmar nuestra reunión del próximo lunes.","english":"Dear sirs: I''m writing to confirm our meeting next Monday."},{"speaker":"Modelo","spanish":"Adjunto el informe anual con las cifras del último trimestre.","english":"I''m attaching the annual report with last quarter''s figures."},{"speaker":"Modelo","spanish":"Quedo a su disposición. Un cordial saludo.","english":"I remain at your disposal. Kind regards."}]'::jsonb,
    grammar_note='Formal Spanish letter / email register: "Estimados señores" or "Estimado/a + name" → body → "Quedo a su disposición" → "Un cordial saludo" / "Atentamente".'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "deficit"?','el déficit',array['el mercado','la inflación','la inversión'],'deficit',1),
  (v_l1,'fill_blank','Complete: "La ____ afecta a todos." (inflation)','inflación',array['inversión','bolsa','contracción'],'inflation',2),
  (v_l1,'multiple_choice','What does "volátil" mean?','volatile',array['stable','rising','falling'],'volatile',3),
  (v_l1,'listening','What did you hear?','Sin inversión, será difícil recuperarnos',array['El mercado está volátil','La inflación complica todo','La inversión es clave'],'Without investment, it will be hard to recover',4),
  (v_l1,'speaking','Say this aloud: "El mercado está muy volátil."','El mercado está muy volátil',array[]::text[],'The market is very volatile.',5),
  (v_l2,'multiple_choice','Conditional perfect (we, avoid)?','habríamos evitado',array['evitamos','evitaríamos','evitaríamos haber'],'we would have avoided',1),
  (v_l2,'fill_blank','Complete: "Si ____ intervenido a tiempo." (they had)','hubieran',array['habrían','han','habían'],'they had (subj)',2),
  (v_l2,'multiple_choice','What does "diversificar" mean?','to diversify',array['to concentrate','to invest','to ruin'],'to diversify',3),
  (v_l2,'listening','What did you hear?','Si hubieran intervenido a tiempo, habríamos evitado la crisis',array['Diversificar la cartera reduce riesgos','No actuaron a tiempo','No poner todos los huevos en una cesta'],'If they had intervened in time, we would have avoided the crisis',4),
  (v_l2,'speaking','Say this aloud: "Diversificar la cartera reduce riesgos."','Diversificar la cartera reduce riesgos',array[]::text[],'Diversifying the portfolio reduces risks.',5),
  (v_l3,'multiple_choice','How to say "record figures"?','cifras récord',array['recortar gastos','a corto plazo','rentable'],'record figures',1),
  (v_l3,'fill_blank','Complete: "Aun ____, hay que recortar." (so)','así',array['si','sin','siempre'],'even so',2),
  (v_l3,'multiple_choice','What does "rentable" mean?','profitable',array['rented','reliable','risky'],'profitable',3),
  (v_l3,'listening','What did you hear?','Este trimestre alcanzamos cifras récord',array['Aun así, hay que recortar gastos','A corto plazo duele, pero será rentable','Hay que recortar gastos'],'This quarter we hit record figures',4),
  (v_l3,'speaking','Say this aloud: "Hay que recortar gastos."','Hay que recortar gastos',array[]::text[],'We have to cut expenses.',5),
  (v_l4,'multiple_choice','What is "stock exchange"?','la bolsa',array['el PIB','el desempleo','la prima'],'stock exchange',1),
  (v_l4,'fill_blank','Complete: "El ____ creció un 2%." (GDP)','PIB',array['déficit','interés','riesgo'],'GDP',2),
  (v_l4,'multiple_choice','What does "tendencia a la baja" mean?','downward trend',array['upward trend','stable trend','sudden change'],'downward trend',3),
  (v_l4,'listening','What did you hear?','El desempleo continúa su tendencia a la baja',array['La bolsa cerró con una subida del tres por ciento','El PIB creció un dos por ciento','La prima de riesgo se disparó'],'Unemployment continues its downward trend',4),
  (v_l4,'speaking','Say this aloud: "La bolsa subió tres puntos."','La bolsa subió tres puntos',array[]::text[],'The exchange rose three points.',5),
  (v_l5,'multiple_choice','How to say "I''ve worked at a multinational for years"?','Trabajo en una multinacional desde hace años',array['Mi sector está en crecimiento','Diversifico mis ahorros','Siempre busco oportunidades'],'I''ve worked at a multinational for years',1),
  (v_l5,'fill_blank','Complete: "Diversifico mis ____" (savings)','ahorros',array['cifras','riesgos','sectores'],'savings',2),
  (v_l5,'multiple_choice','What does "Mi sector está en crecimiento" mean?','My sector is growing',array['My sector is dying','My sector is small','My sector is global'],'My sector is growing',3),
  (v_l5,'listening','What did you hear?','En tecnología. Mi sector está en crecimiento',array['Trabajo en una multinacional desde hace cinco años','¿En qué sector?','Diversifico mis ahorros'],'In tech. My sector is growing',4),
  (v_l5,'speaking','Say this aloud: "Diversifico mis ahorros entre fondos y depósitos."','Diversifico mis ahorros entre fondos y depósitos',array[]::text[],'I diversify my savings between funds and deposits.',5),
  (v_l6,'multiple_choice','What is "expansionary cycle"?','un ciclo expansivo',array['una contracción','el banco central','la inflación'],'expansionary cycle',1),
  (v_l6,'fill_blank','Complete: "El banco central subió los ____" (rates)','tipos',array['precios','cifras','impuestos'],'rates',2),
  (v_l6,'multiple_choice','What does "prever" mean?','to forecast',array['to provide','to prevent','to procure'],'to forecast',3),
  (v_l6,'listening','What did you hear?','Los analistas prevén un PIB del tres por ciento el año que viene',array['Tras dos años de contracción','El banco central subió los tipos','Buscan controlar la inflación'],'Analysts forecast a 3% GDP next year',4),
  (v_l6,'speaking','Say this aloud: "Buscan controlar la inflación."','Buscan controlar la inflación',array[]::text[],'They aim to control inflation.',5),
  (v_l7,'multiple_choice','How to start a formal letter?','Estimados señores',array['Hola','¡Buenas!','Adjunto'],'Dear sirs/madams',1),
  (v_l7,'fill_blank','Complete: "Quedo a su ____" (disposal)','disposición',array['servicio','vista','espera'],'disposal',2),
  (v_l7,'multiple_choice','What does "adjunto" mean here?','I''m attaching',array['I''m sending','I''m receiving','I''m signing'],'I''m attaching',3),
  (v_l7,'listening','What did you hear?','Adjunto el informe anual con las cifras del último trimestre',array['Estimados señores: les escribo para confirmar nuestra reunión','Quedo a su disposición','Un cordial saludo'],'I''m attaching the annual report with last quarter''s figures',4),
  (v_l7,'speaking','Say this aloud: "Un cordial saludo."','Un cordial saludo',array[]::text[],'Kind regards.',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','El déficit público creció',array['El mercado está volátil','La inflación afecta a todos','Necesitamos más inversión'],'The public deficit grew',6),
  (v_l1,'listening','What did you hear?','Necesitamos más inversión',array['El mercado está volátil','La inflación afecta a todos','El déficit público'],'We need more investment',7),
  (v_l1,'speaking','Say this aloud: "La inflación complica todo."','La inflación complica todo',array[]::text[],'Inflation complicates everything.',8),
  (v_l1,'speaking','Say this aloud: "El mercado está volátil."','El mercado está volátil',array[]::text[],'The market is volatile.',9),
  (v_l2,'listening','What did you hear?','No actuaron a tiempo',array['Si hubieran intervenido','Habríamos evitado la crisis','Por eso conviene diversificar'],'They didn''t act in time',6),
  (v_l2,'listening','What did you hear?','No poner todos los huevos en una cesta',array['Si hubieran intervenido','Habríamos evitado','Por eso conviene diversificar'],'Don''t put all your eggs in one basket',7),
  (v_l2,'speaking','Say this aloud: "Si hubieran intervenido a tiempo."','Si hubieran intervenido a tiempo',array[]::text[],'If they had intervened in time.',8),
  (v_l2,'speaking','Say this aloud: "Habríamos evitado la crisis."','Habríamos evitado la crisis',array[]::text[],'We would have avoided the crisis.',9),
  (v_l3,'listening','What did you hear?','A corto plazo, perderemos',array['Alcanzamos cifras récord','Hay que recortar gastos','El proyecto es rentable'],'Short-term, we''ll lose',6),
  (v_l3,'listening','What did you hear?','El proyecto es rentable',array['Cifras récord','Recortar gastos','A corto plazo'],'The project is profitable',7),
  (v_l3,'speaking','Say this aloud: "A corto plazo duele, pero será rentable."','A corto plazo duele, pero será rentable',array[]::text[],'Short-term it hurts, but it will be profitable.',8),
  (v_l3,'speaking','Say this aloud: "Alcanzamos cifras récord."','Alcanzamos cifras récord',array[]::text[],'We hit record figures.',9),
  (v_l6,'listening','What did you hear?','El banco central subió los tipos de interés para controlar la inflación',array['Tras dos años de contracción','Los analistas prevén un PIB del tres por ciento','La economía entra en un ciclo expansivo'],'The central bank raised interest rates to control inflation',6),
  (v_l6,'listening','What did you hear?','La economía entra en un ciclo expansivo',array['Tras dos años de contracción','El banco central subió los tipos','Los analistas prevén'],'The economy enters an expansionary cycle',7),
  (v_l6,'speaking','Say this aloud: "Estamos en un ciclo expansivo."','Estamos en un ciclo expansivo',array[]::text[],'We are in an expansionary cycle.',8),
  (v_l6,'speaking','Say this aloud: "La contracción duró dos años."','La contracción duró dos años',array[]::text[],'The contraction lasted two years.',9),
  (v_l7,'listening','What did you hear?','Estimados señores: les escribo para confirmar nuestra reunión del próximo lunes',array['Adjunto el informe anual','Quedo a su disposición','Un cordial saludo'],'Dear sirs: I''m writing to confirm our meeting next Monday',6),
  (v_l7,'listening','What did you hear?','Quedo a su disposición',array['Estimados señores','Adjunto el informe','Un cordial saludo'],'I remain at your disposal',7),
  (v_l7,'speaking','Say this aloud: "Adjunto el informe anual."','Adjunto el informe anual',array[]::text[],'I''m attaching the annual report.',8),
  (v_l7,'speaking','Say this aloud: "Quedo a su disposición."','Quedo a su disposición',array[]::text[],'I remain at your disposal.',9);

  update public.lessons set type='conversation', title='Business & Economics — Conversation Practice',
    description='Two colleagues review a quarter.',
    intro='Ana and Luis discuss results and strategy.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Ana","spanish":"¿Has visto las cifras del trimestre?","english":"Have you seen the quarterly figures?"},{"speaker":"Luis","spanish":"Sí, récord. Pero la inflación complica todo.","english":"Yes, record. But inflation complicates everything."},{"speaker":"Ana","spanish":"Si el banco central no subiera los tipos, sería peor.","english":"If the central bank didn''t raise rates, it would be worse."},{"speaker":"Luis","spanish":"Si hubieran intervenido antes, habríamos evitado parte del problema.","english":"If they had intervened earlier, we would have avoided part of the problem."},{"speaker":"Ana","spanish":"A corto plazo duele, pero a la larga es rentable diversificar.","english":"Short-term it hurts, but long-term it''s profitable to diversify."},{"speaker":"Luis","spanish":"Por eso buscamos oportunidades en otros mercados.","english":"That''s why we''re looking for opportunities in other markets."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','How are the figures?','Record',array['Disappointing','Stable','Average'],'récord',1),
  (v_l8,'multiple_choice','What complicates things?','Inflation',array['Deflation','Recession','War'],'la inflación complica todo',2),
  (v_l8,'multiple_choice','Luis''s counterfactual?','If they had intervened earlier, we would have avoided part',array['Nothing could have helped','Nothing was wrong','It was inevitable'],'Si hubieran intervenido antes, habríamos evitado',3),
  (v_l8,'multiple_choice','True or false: Ana favors diversification.','True',array['False'],'a la larga es rentable diversificar',4),
  (v_l8,'fill_blank','Complete: "Si el banco central no ____ los tipos." (raised - subj)','subiera',array['subió','sube','subirá'],'raised (subj)',5),
  (v_l8,'multiple_choice','Luis''s strategy?','Look for opportunities in other markets',array['Stay in current market','Stop investing','Quit'],'buscamos oportunidades en otros mercados',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Business & Economics', 'Review test for the Business & Economics section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "investment"?','la inversión',array['el déficit','la bolsa','el mercado'],'investment',1),
  (v_lesson_id,'multiple_choice','Third conditional structure?','si hubieran + habríamos',array['si tuvieran + tendríamos','si pueden + podemos','si fueran + serían'],'past unreal',2),
  (v_lesson_id,'multiple_choice','What does "rentable" mean?','profitable',array['renewable','reliable','recyclable'],'profitable',3),
  (v_lesson_id,'multiple_choice','True/false: "desde hace + time" = "for X time" still ongoing.','True',array['False'],'desde hace = for X time (ongoing)',4),
  (v_lesson_id,'fill_blank','Complete: "Aun ____, hay que recortar." (so)','así',array['si','sin','luego'],'even so',5),
  (v_lesson_id,'fill_blank','Complete: "Quedo a su ____" (disposal)','disposición',array['vista','espera','servicio'],'disposal',6),
  (v_lesson_id,'listening','What did you hear?','La bolsa cerró con una subida del tres por ciento',array['El PIB creció un dos por ciento','El desempleo continúa su tendencia a la baja','La prima de riesgo se disparó'],'The exchange closed up 3%',7),
  (v_lesson_id,'listening','What did you hear?','Habríamos evitado la crisis',array['Diversificar la cartera reduce riesgos','No actuaron a tiempo','Si hubieran intervenido'],'We would have avoided the crisis',8),
  (v_lesson_id,'speaking','Say this aloud: "Hay que recortar gastos."','Hay que recortar gastos',array[]::text[],'We have to cut expenses.',9),
  (v_lesson_id,'speaking','Say this aloud: "Diversificar la cartera reduce riesgos."','Diversificar la cartera reduce riesgos',array[]::text[],'Diversifying the portfolio reduces risks.',10);

  -- ===========================================================
  -- B2.6 SCIENCE & RESEARCH
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B2' and title = 'Science & Research';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='Scientific Spanish builds on Latin/Greek roots familiar from English. Master "hipótesis", "experimento", "investigación" and the formal voice used in academic writing.',
    vocab_items='[{"spanish":"la investigación","english":"research"},{"spanish":"el experimento","english":"experiment"},{"spanish":"la hipótesis","english":"hypothesis"},{"spanish":"la teoría","english":"theory"},{"spanish":"el laboratorio","english":"laboratory"},{"spanish":"la muestra","english":"sample"},{"spanish":"los resultados","english":"results"},{"spanish":"comprobar","english":"to verify"},{"spanish":"descubrir","english":"to discover"},{"spanish":"el descubrimiento","english":"discovery"}]'::jsonb,
    dialogue='[{"speaker":"Profesor","spanish":"Nuestra hipótesis se confirmó con los resultados del experimento.","english":"Our hypothesis was confirmed by the experimental results."},{"speaker":"Estudiante","spanish":"¿Y qué pasos seguirán ahora?","english":"And what steps will you take now?"},{"speaker":"Profesor","spanish":"Publicaremos los hallazgos en una revista revisada por pares.","english":"We will publish the findings in a peer-reviewed journal."}]'::jsonb,
    grammar_note='Academic Spanish prefers the impersonal "se": "se observó", "se concluyó", "se ha demostrado". This passive construction avoids first person and projects objectivity.'
  where id = v_l1;

  update public.lessons set
    intro='The scientific method follows universal steps: "observar", "formular una hipótesis", "experimentar", "analizar", "concluir". Each verb has a noun form used in reports.',
    vocab_items='[{"spanish":"el método científico","english":"scientific method"},{"spanish":"la observación","english":"observation"},{"spanish":"el análisis","english":"analysis"},{"spanish":"analizar","english":"to analyze"},{"spanish":"la conclusión","english":"conclusion"},{"spanish":"medir","english":"to measure"},{"spanish":"la medición","english":"measurement"},{"spanish":"el dato","english":"data point"},{"spanish":"la variable","english":"variable"},{"spanish":"el control","english":"control"}]'::jsonb,
    dialogue='[{"speaker":"Investigadora","spanish":"Si midiéramos esa variable con más precisión, los resultados serían más fiables.","english":"If we measured that variable more precisely, the results would be more reliable."},{"speaker":"Colega","spanish":"Necesitamos un grupo de control mayor.","english":"We need a larger control group."}]'::jsonb,
    grammar_note='Conditional sentences in research: "si midiéramos... serían" (type 2, hypothetical present). Imperfect subjunctive + simple conditional is the workhorse of scientific speculation.'
  where id = v_l2;

  update public.lessons set
    intro='Reading scientific papers requires command of academic discourse markers: "no obstante", "en consecuencia", "por lo tanto", "cabe destacar".',
    vocab_items='[{"spanish":"el artículo científico","english":"scientific paper"},{"spanish":"el resumen","english":"abstract"},{"spanish":"la introducción","english":"introduction"},{"spanish":"la metodología","english":"methodology"},{"spanish":"los hallazgos","english":"findings"},{"spanish":"la discusión","english":"discussion"},{"spanish":"la bibliografía","english":"bibliography"},{"spanish":"citar","english":"to cite"},{"spanish":"revisado por pares","english":"peer-reviewed"},{"spanish":"el factor de impacto","english":"impact factor"}]'::jsonb,
    dialogue='[{"speaker":"Autor","spanish":"Cabe destacar que los resultados contradicen estudios previos.","english":"It is worth noting that the results contradict prior studies."},{"speaker":"Revisor","spanish":"Por lo tanto, hace falta replicar el experimento.","english":"Therefore, the experiment needs to be replicated."}]'::jsonb,
    grammar_note='"Cabe + infinitive" = "it is worth/fitting to...". A highly formal construction. "Cabe destacar", "cabe señalar", "cabe preguntarse" are essential academic phrases.'
  where id = v_l3;

  update public.lessons set
    intro='Biology vocabulary: cells, organisms, evolution, DNA. Spanish uses many international terms but with Spanish stress patterns.',
    vocab_items='[{"spanish":"la célula","english":"cell"},{"spanish":"el organismo","english":"organism"},{"spanish":"la evolución","english":"evolution"},{"spanish":"el ADN","english":"DNA"},{"spanish":"el gen","english":"gene"},{"spanish":"la especie","english":"species"},{"spanish":"el ecosistema","english":"ecosystem"},{"spanish":"la biodiversidad","english":"biodiversity"},{"spanish":"reproducirse","english":"to reproduce"},{"spanish":"adaptarse","english":"to adapt"}]'::jsonb,
    dialogue='[{"speaker":"Bióloga","spanish":"Las especies que no se adaptan a su entorno tienden a extinguirse.","english":"Species that don''t adapt to their environment tend to go extinct."}]'::jsonb,
    grammar_note='Reflexive verbs for biological processes: "reproducirse", "adaptarse", "extinguirse", "desarrollarse". The "se" indicates the action happens within or to the subject itself.'
  where id = v_l4;

  update public.lessons set
    intro='Physics and chemistry vocabulary. The Spanish "átomo", "molécula", "energía" sound nearly identical to English; mastering the surrounding grammar matters more.',
    vocab_items='[{"spanish":"la física","english":"physics"},{"spanish":"la química","english":"chemistry"},{"spanish":"el átomo","english":"atom"},{"spanish":"la molécula","english":"molecule"},{"spanish":"la energía","english":"energy"},{"spanish":"la materia","english":"matter"},{"spanish":"la velocidad","english":"speed"},{"spanish":"la fuerza","english":"force"},{"spanish":"la masa","english":"mass"},{"spanish":"la reacción","english":"reaction"}]'::jsonb,
    dialogue='[{"speaker":"Profesora","spanish":"La energía no se crea ni se destruye, solo se transforma.","english":"Energy is neither created nor destroyed, only transformed."}]'::jsonb,
    grammar_note='"Ni... ni..." = "neither... nor...". Pairs well with "no" before the verb: "no se crea ni se destruye". Common in formal/scientific statements.'
  where id = v_l5;

  update public.lessons set
    intro='Listen to a research presentation. Speakers use formal academic Spanish with passive constructions and discourse markers.',
    vocab_items='[{"spanish":"presentar","english":"to present"},{"spanish":"la conferencia","english":"conference"},{"spanish":"el ponente","english":"presenter"},{"spanish":"el resumen ejecutivo","english":"executive summary"},{"spanish":"plantear","english":"to pose (a question)"},{"spanish":"abordar","english":"to address (a topic)"},{"spanish":"profundizar en","english":"to delve into"}]'::jsonb,
    dialogue='[{"speaker":"Ponente","spanish":"En este estudio se aborda la cuestión del cambio climático desde una perspectiva interdisciplinar.","english":"In this study, the question of climate change is addressed from an interdisciplinary perspective."},{"speaker":"Ponente","spanish":"Se plantea la hipótesis de que la deforestación acelera el calentamiento.","english":"The hypothesis is posed that deforestation accelerates warming."}]'::jsonb,
    grammar_note='Impersonal "se": "se aborda", "se plantea". Standard in academic Spanish to convey objectivity without naming an agent.'
  where id = v_l6;

  update public.lessons set
    intro='Write a research abstract. The abstract follows a fixed structure: context, objective, method, results, conclusion. Each sentence should be precise.',
    vocab_items='[{"spanish":"el objetivo","english":"objective"},{"spanish":"la metodología","english":"methodology"},{"spanish":"los resultados","english":"results"},{"spanish":"las conclusiones","english":"conclusions"},{"spanish":"las palabras clave","english":"keywords"},{"spanish":"demostrar","english":"to demonstrate"},{"spanish":"evidenciar","english":"to evidence"},{"spanish":"sugerir","english":"to suggest"}]'::jsonb,
    dialogue='[{"speaker":"Resumen","spanish":"El presente estudio tuvo como objetivo evaluar el impacto de la contaminación en la fauna marina.","english":"The present study aimed to evaluate the impact of pollution on marine fauna."},{"speaker":"Resumen","spanish":"Los resultados sugieren que la exposición prolongada reduce la reproducción.","english":"Results suggest that prolonged exposure reduces reproduction."}]'::jsonb,
    grammar_note='Academic abstracts use the preterit ("tuvo como objetivo", "se observó") for the study itself, and the present ("los resultados sugieren") for current findings.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "research"?','la investigación',array['el descubrimiento','la teoría','el experimento'],'research',1),
  (v_l1,'multiple_choice','What is "hypothesis"?','la hipótesis',array['la conclusión','la muestra','la teoría'],'hypothesis',2),
  (v_l1,'fill_blank','Complete: "Se ____ los resultados." (it was observed)','observaron',array['observa','observamos','observaban'],'were observed',3),
  (v_l1,'multiple_choice','What does "comprobar" mean?','to verify',array['to compare','to compose','to compete'],'to verify',4),
  (v_l1,'fill_blank','Complete: "Se ha ____ que la teoría es válida." (demonstrated)','demostrado',array['demuestrado','demostrando','demostrar'],'demonstrated',5),
  (v_l2,'multiple_choice','What is "variable"?','la variable',array['el dato','el control','la medición'],'variable',1),
  (v_l2,'multiple_choice','Second conditional structure?','si midiéramos + serían',array['si midimos + son','si medir + sería','si medimos + serán'],'hypothetical present',2),
  (v_l2,'fill_blank','Complete: "Si ____ más datos, sería mejor." (we had - imperf subj)','tuviéramos',array['tenemos','tendríamos','tuvimos'],'we had (subj)',3),
  (v_l2,'multiple_choice','What does "analizar" mean?','to analyze',array['to announce','to annotate','to annul'],'to analyze',4),
  (v_l2,'multiple_choice','What is "data point"?','el dato',array['la fecha','el dado','la duda'],'data point',5),
  (v_l3,'multiple_choice','What is "abstract" (paper)?','el resumen',array['la introducción','la conclusión','el resultado'],'abstract',1),
  (v_l3,'fill_blank','Complete: "____ destacar la importancia del estudio." (It''s worth)','Cabe',array['Hay','Es','Va'],'it is worth',2),
  (v_l3,'multiple_choice','What does "peer-reviewed" translate to?','revisado por pares',array['revisado por jefes','revisado por autores','revisado por dueños'],'peer-reviewed',3),
  (v_l3,'multiple_choice','What does "por lo tanto" mean?','therefore',array['however','meanwhile','despite'],'therefore',4),
  (v_l3,'fill_blank','Complete: "Cabe ____ que no hay datos." (note)','señalar',array['señalando','señalo','señalado'],'to note',5),
  (v_l4,'multiple_choice','What is "cell"?','la célula',array['la cédula','la celebra','la celda'],'cell',1),
  (v_l4,'multiple_choice','What is "species"?','la especie',array['el espacio','la especia','el espécimen'],'species',2),
  (v_l4,'fill_blank','Complete: "Las especies se ____ a su entorno." (adapt)','adaptan',array['adapta','adaptamos','adapté'],'adapt',3),
  (v_l4,'multiple_choice','What does "extinguirse" mean?','to go extinct',array['to extinguish (a fire)','to expire','to exist'],'to go extinct',4),
  (v_l4,'multiple_choice','What is "DNA"?','el ADN',array['el ARN','el ATP','el AMP'],'DNA',5),
  (v_l5,'multiple_choice','What is "force"?','la fuerza',array['la masa','la energía','la velocidad'],'force',1),
  (v_l5,'multiple_choice','What does "ni... ni..." mean?','neither... nor...',array['either... or...','both... and...','not only... but...'],'neither... nor...',2),
  (v_l5,'fill_blank','Complete: "La energía no se ____ ni se destruye." (creates)','crea',array['crear','creó','creará'],'creates',3),
  (v_l5,'multiple_choice','What is "speed"?','la velocidad',array['la vejez','la vereda','la verdad'],'speed',4),
  (v_l5,'multiple_choice','What does "se transforma" mean?','it transforms (itself)',array['transforms them','it has transformed','it will transform'],'it transforms',5),
  (v_l6,'multiple_choice','What does "abordar" mean?','to address (a topic)',array['to abort','to absorb','to abandon'],'to address',1),
  (v_l6,'multiple_choice','What does "plantear" mean?','to pose (a question)',array['to plant','to plan','to plane'],'to pose',2),
  (v_l6,'fill_blank','Complete: "Se ____ la hipótesis de que..." (poses)','plantea',array['plantear','planteado','planteo'],'poses',3),
  (v_l6,'multiple_choice','What is "presenter"?','el ponente',array['el potente','el poniente','el portento'],'presenter',4),
  (v_l6,'fill_blank','Complete: "Se ____ el problema desde una perspectiva nueva." (addresses)','aborda',array['abordar','abordado','abordo'],'addresses',5),
  (v_l7,'multiple_choice','What is "objective"?','el objetivo',array['el objeto','la objeción','el obrero'],'objective',1),
  (v_l7,'multiple_choice','What is "conclusion"?','la conclusión',array['la concesión','la conexión','la confusión'],'conclusion',2),
  (v_l7,'fill_blank','Complete: "El estudio ____ como objetivo evaluar..." (had)','tuvo',array['tiene','tendrá','tenía'],'had',3),
  (v_l7,'multiple_choice','What does "sugerir" mean?','to suggest',array['to summarize','to support','to surge'],'to suggest',4),
  (v_l7,'multiple_choice','What does "evidenciar" mean?','to evidence',array['to evade','to envision','to envy'],'to evidence',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Nuestra hipótesis se confirmó con los resultados',array['Publicaremos los hallazgos','El laboratorio está cerrado','El método científico'],'Our hypothesis was confirmed by the results',6),
  (v_l1,'listening','What did you hear?','Publicaremos los hallazgos en una revista revisada por pares',array['Nuestra hipótesis se confirmó','El experimento falló','La muestra fue pequeña'],'We''ll publish in a peer-reviewed journal',7),
  (v_l1,'speaking','Say this aloud: "Se ha demostrado la teoría."','Se ha demostrado la teoría',array[]::text[],'The theory has been demonstrated.',8),
  (v_l1,'speaking','Say this aloud: "Nuestra hipótesis se confirmó."','Nuestra hipótesis se confirmó',array[]::text[],'Our hypothesis was confirmed.',9),
  (v_l2,'listening','What did you hear?','Si midiéramos esa variable con más precisión',array['Necesitamos un grupo de control','Los datos son fiables','El control es esencial'],'If we measured that variable more precisely',6),
  (v_l2,'listening','What did you hear?','Necesitamos un grupo de control mayor',array['Si midiéramos la variable','Los resultados serían fiables','La variable es importante'],'We need a larger control group',7),
  (v_l2,'speaking','Say this aloud: "Si tuviéramos más datos, sería mejor."','Si tuviéramos más datos, sería mejor',array[]::text[],'If we had more data, it would be better.',8),
  (v_l2,'speaking','Say this aloud: "Necesitamos un grupo de control."','Necesitamos un grupo de control',array[]::text[],'We need a control group.',9),
  (v_l3,'listening','What did you hear?','Cabe destacar que los resultados contradicen estudios previos',array['Por lo tanto, hace falta replicar','El factor de impacto es alto','La metodología es rigurosa'],'It is worth noting the results contradict prior studies',6),
  (v_l3,'listening','What did you hear?','Por lo tanto, hace falta replicar el experimento',array['Cabe destacar los resultados','El artículo es nuevo','La bibliografía es completa'],'Therefore, the experiment needs replication',7),
  (v_l3,'speaking','Say this aloud: "Cabe destacar este hallazgo."','Cabe destacar este hallazgo',array[]::text[],'It is worth noting this finding.',8),
  (v_l3,'speaking','Say this aloud: "Por lo tanto, hace falta replicar."','Por lo tanto, hace falta replicar',array[]::text[],'Therefore, replication is needed.',9),
  (v_l6,'listening','What did you hear?','En este estudio se aborda la cuestión del cambio climático',array['Se plantea la hipótesis','La conferencia es interdisciplinar','El ponente es famoso'],'In this study, the question of climate change is addressed',6),
  (v_l6,'listening','What did you hear?','Se plantea la hipótesis de que la deforestación acelera el calentamiento',array['Se aborda la cuestión','La perspectiva es interdisciplinar','El estudio es nuevo'],'The hypothesis is posed that deforestation accelerates warming',7),
  (v_l6,'speaking','Say this aloud: "Se aborda la cuestión desde una perspectiva nueva."','Se aborda la cuestión desde una perspectiva nueva',array[]::text[],'The issue is addressed from a new perspective.',8),
  (v_l6,'speaking','Say this aloud: "Se plantea una hipótesis."','Se plantea una hipótesis',array[]::text[],'A hypothesis is posed.',9),
  (v_l7,'listening','What did you hear?','El presente estudio tuvo como objetivo evaluar el impacto de la contaminación',array['Los resultados sugieren','La muestra es amplia','Las palabras clave son'],'The present study aimed to evaluate the impact of pollution',6),
  (v_l7,'listening','What did you hear?','Los resultados sugieren que la exposición prolongada reduce la reproducción',array['El estudio tuvo como objetivo','El impacto es positivo','La fauna se adapta'],'Results suggest prolonged exposure reduces reproduction',7),
  (v_l7,'speaking','Say this aloud: "El estudio tuvo como objetivo evaluar el impacto."','El estudio tuvo como objetivo evaluar el impacto',array[]::text[],'The study aimed to evaluate the impact.',8),
  (v_l7,'speaking','Say this aloud: "Los resultados sugieren un cambio."','Los resultados sugieren un cambio',array[]::text[],'The results suggest a change.',9);

  update public.lessons set type='conversation', title='Science & Research — Conversation Practice',
    description='Two researchers discuss a project.',
    intro='Dr. Pérez and Dr. Soto compare findings.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Pérez","spanish":"¿Has visto el artículo de Nature de este mes?","english":"Have you seen this month''s Nature paper?"},{"speaker":"Soto","spanish":"Sí, cabe destacar que su metodología es más rigurosa que la nuestra.","english":"Yes, it is worth noting their methodology is more rigorous than ours."},{"speaker":"Pérez","spanish":"Si replicáramos su estudio con nuestra muestra, ¿obtendríamos los mismos resultados?","english":"If we replicated their study with our sample, would we get the same results?"},{"speaker":"Soto","spanish":"Probablemente no. La biodiversidad de la zona es muy distinta.","english":"Probably not. The biodiversity of the area is very different."},{"speaker":"Pérez","spanish":"Por lo tanto, conviene presentar nuestros hallazgos como complementarios.","english":"Therefore, we should present our findings as complementary."},{"speaker":"Soto","spanish":"De acuerdo. Empezaré a redactar el resumen mañana.","english":"Agreed. I''ll start drafting the abstract tomorrow."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','What did Pérez read?','A Nature paper',array['A book','A blog','A newspaper'],'el artículo de Nature',1),
  (v_l8,'multiple_choice','Soto''s observation about the paper?','Their methodology is more rigorous',array['Their methodology is worse','Their results are wrong','Their team is smaller'],'su metodología es más rigurosa',2),
  (v_l8,'multiple_choice','Would replicating yield the same results?','Probably not — biodiversity is different',array['Yes, exactly the same','Yes, but smaller','It''s impossible to know'],'la biodiversidad es distinta',3),
  (v_l8,'multiple_choice','How will they present findings?','As complementary',array['As contradictory','As superior','As preliminary'],'como complementarios',4),
  (v_l8,'fill_blank','Complete: "Si ____ su estudio..." (replicated - subj)','replicáramos',array['replicamos','replicaríamos','replicaron'],'replicated',5),
  (v_l8,'multiple_choice','What will Soto do next?','Start drafting the abstract',array['Run a new experiment','Email the authors','Cancel the project'],'redactar el resumen',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Science & Research', 'Review test for the Science & Research section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "discovery"?','el descubrimiento',array['la descomposición','la decisión','el desarrollo'],'discovery',1),
  (v_lesson_id,'multiple_choice','What does "cabe destacar" mean?','it is worth noting',array['it is forbidden','it is required','it is impossible'],'cabe destacar',2),
  (v_lesson_id,'multiple_choice','What is "peer-reviewed"?','revisado por pares',array['revisado por jefes','revisado por autores','revisado por dueños'],'peer-reviewed',3),
  (v_lesson_id,'multiple_choice','True/false: "se observó" is impersonal passive.','True',array['False'],'impersonal se',4),
  (v_lesson_id,'fill_blank','Complete: "Si ____ más, sabríamos." (we knew - subj)','supiéramos',array['sabemos','sabríamos','sabíamos'],'we knew (subj)',5),
  (v_lesson_id,'fill_blank','Complete: "La energía no se ____ ni se destruye." (creates)','crea',array['crear','creó','creará'],'creates',6),
  (v_lesson_id,'listening','What did you hear?','Cabe destacar la importancia de este hallazgo',array['Se aborda la cuestión','Si midiéramos con más precisión','Los resultados sugieren'],'It is worth noting the importance of this finding',7),
  (v_lesson_id,'listening','What did you hear?','Las especies que no se adaptan tienden a extinguirse',array['La biodiversidad disminuye','El ADN cambia','El ecosistema se altera'],'Species that don''t adapt tend to go extinct',8),
  (v_lesson_id,'speaking','Say this aloud: "Se ha demostrado la hipótesis."','Se ha demostrado la hipótesis',array[]::text[],'The hypothesis has been demonstrated.',9),
  (v_lesson_id,'speaking','Say this aloud: "Cabe destacar este resultado."','Cabe destacar este resultado',array[]::text[],'It is worth noting this result.',10);

  -- ===========================================================
  -- B2.7 ARTS & CULTURE
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B2' and title = 'Arts & Culture';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='Visual arts vocabulary in Spanish has rich Italian and French borrowings. Master "lienzo", "pincel", "óleo" alongside "obra maestra" and "exposición".',
    vocab_items='[{"spanish":"la obra de arte","english":"work of art"},{"spanish":"la obra maestra","english":"masterpiece"},{"spanish":"el lienzo","english":"canvas"},{"spanish":"el pincel","english":"brush"},{"spanish":"el óleo","english":"oil paint"},{"spanish":"la acuarela","english":"watercolor"},{"spanish":"la escultura","english":"sculpture"},{"spanish":"el museo","english":"museum"},{"spanish":"la galería","english":"gallery"},{"spanish":"la exposición","english":"exhibition"}]'::jsonb,
    dialogue='[{"speaker":"Visitante","spanish":"¿Cuál es la obra maestra de esta exposición?","english":"Which is the masterpiece of this exhibition?"},{"speaker":"Guía","spanish":"Sin duda, el óleo de Velázquez al fondo de la sala.","english":"Without doubt, the Velázquez oil at the back of the room."}]'::jsonb,
    grammar_note='Superlatives with "sin duda": "sin duda alguna", "sin lugar a dudas". Common emphatic phrases in critical discourse.'
  where id = v_l1;

  update public.lessons set
    intro='Art movements: "el Renacimiento", "el Barroco", "el Impresionismo", "el Cubismo". The "el" article is used with movements.',
    vocab_items='[{"spanish":"el Renacimiento","english":"the Renaissance"},{"spanish":"el Barroco","english":"the Baroque"},{"spanish":"el Impresionismo","english":"Impressionism"},{"spanish":"el Cubismo","english":"Cubism"},{"spanish":"el Surrealismo","english":"Surrealism"},{"spanish":"el estilo","english":"style"},{"spanish":"la corriente","english":"current/movement"},{"spanish":"la influencia","english":"influence"},{"spanish":"el movimiento","english":"movement"},{"spanish":"vanguardista","english":"avant-garde"}]'::jsonb,
    dialogue='[{"speaker":"Profesor","spanish":"Picasso, aunque empezó en el realismo, fundó el Cubismo.","english":"Picasso, although he started in realism, founded Cubism."},{"speaker":"Alumna","spanish":"¿De quién recibió más influencia?","english":"From whom did he receive the most influence?"}]'::jsonb,
    grammar_note='"Aunque + indicative" = "although + factual". "Aunque + subjunctive" = "even if + hypothetical". "Aunque empezó" is a fact; "aunque empezara" would be hypothetical.'
  where id = v_l2;

  update public.lessons set
    intro='Music vocabulary: instruments, genres, performance. Spanish distinguishes "interpretar" (to perform) from "tocar" (to play an instrument).',
    vocab_items='[{"spanish":"la música clásica","english":"classical music"},{"spanish":"la sinfonía","english":"symphony"},{"spanish":"la ópera","english":"opera"},{"spanish":"el compositor","english":"composer"},{"spanish":"el director de orquesta","english":"orchestra conductor"},{"spanish":"interpretar","english":"to perform"},{"spanish":"la melodía","english":"melody"},{"spanish":"el ritmo","english":"rhythm"},{"spanish":"la armonía","english":"harmony"},{"spanish":"componer","english":"to compose"}]'::jsonb,
    dialogue='[{"speaker":"Crítico","spanish":"La orquesta interpretó la sinfonía con una sensibilidad excepcional.","english":"The orchestra performed the symphony with exceptional sensitivity."}]'::jsonb,
    grammar_note='"Con + abstract noun" replaces adverbs in literary Spanish: "con sensibilidad" = "sensitively", "con maestría" = "masterfully", "con elegancia" = "elegantly".'
  where id = v_l3;

  update public.lessons set
    intro='Theater and cinema: scripts, directors, actors, scenes. "El guión" (script) is essential.',
    vocab_items='[{"spanish":"el teatro","english":"theater"},{"spanish":"el cine","english":"cinema"},{"spanish":"la obra (de teatro)","english":"play"},{"spanish":"la película","english":"film"},{"spanish":"el guión","english":"script"},{"spanish":"el director","english":"director"},{"spanish":"el actor","english":"actor"},{"spanish":"la actriz","english":"actress"},{"spanish":"el papel","english":"role"},{"spanish":"el estreno","english":"premiere"}]'::jsonb,
    dialogue='[{"speaker":"Crítica","spanish":"El estreno fue tan emotivo que el público aplaudió diez minutos.","english":"The premiere was so emotional that the audience applauded for ten minutes."}]'::jsonb,
    grammar_note='"Tan + adjective + que..." = "so... that...": "tan emotivo que aplaudieron". Use "tanto/a + noun + que" for nouns: "tanto talento que ganó".'
  where id = v_l4;

  update public.lessons set
    intro='Dance and folklore: traditional dances express cultural identity. Spanish has "el flamenco", "el tango", "la salsa", "la bachata".',
    vocab_items='[{"spanish":"la danza","english":"dance (art form)"},{"spanish":"el baile","english":"dance (social)"},{"spanish":"el flamenco","english":"flamenco"},{"spanish":"el tango","english":"tango"},{"spanish":"el folklore","english":"folklore"},{"spanish":"la tradición","english":"tradition"},{"spanish":"el ritmo","english":"rhythm"},{"spanish":"el zapateado","english":"footwork (flamenco)"},{"spanish":"la coreografía","english":"choreography"},{"spanish":"la pasión","english":"passion"}]'::jsonb,
    dialogue='[{"speaker":"Bailarín","spanish":"El flamenco es tanto un baile como una expresión cultural.","english":"Flamenco is both a dance and a cultural expression."}]'::jsonb,
    grammar_note='"Tanto... como..." = "both... and...": "tanto el arte como la música" = "both art and music". Distinct from "tan... como" (comparison of equality).'
  where id = v_l5;

  update public.lessons set
    intro='Art criticism listening: critics use formal Spanish full of literary adjectives. Listen for tone — appreciative or scathing.',
    vocab_items='[{"spanish":"la crítica","english":"criticism/review"},{"spanish":"el crítico","english":"critic"},{"spanish":"elogiar","english":"to praise"},{"spanish":"criticar","english":"to criticize"},{"spanish":"reseñar","english":"to review"},{"spanish":"deslumbrante","english":"dazzling"},{"spanish":"mediocre","english":"mediocre"},{"spanish":"innovador","english":"innovative"},{"spanish":"convencional","english":"conventional"}]'::jsonb,
    dialogue='[{"speaker":"Crítica","spanish":"La interpretación fue deslumbrante, aunque el director optara por un ritmo más lento del esperado.","english":"The performance was dazzling, even though the director opted for a slower tempo than expected."},{"speaker":"Crítica","spanish":"Una obra que sin duda marcará la temporada.","english":"A work that without doubt will mark the season."}]'::jsonb,
    grammar_note='"Aunque + subjunctive (optara)" = "even though/even if" with concessive force. Implies the choice is debatable. With indicative ("aunque optó") it would simply state the fact.'
  where id = v_l6;

  update public.lessons set
    intro='Write a museum review. Structure: opening hook, description, critical assessment, recommendation.',
    vocab_items='[{"spanish":"la reseña","english":"review"},{"spanish":"recomendar","english":"to recommend"},{"spanish":"impresionante","english":"impressive"},{"spanish":"la colección","english":"collection"},{"spanish":"merecer la pena","english":"to be worth it"},{"spanish":"acudir","english":"to attend"},{"spanish":"el público","english":"audience"},{"spanish":"la propuesta","english":"proposal/offering"}]'::jsonb,
    dialogue='[{"speaker":"Reseña","spanish":"La colección del Prado, sin lugar a dudas, merece la pena visitarla aunque sea brevemente.","english":"The Prado collection, without a doubt, is worth visiting even if briefly."},{"speaker":"Reseña","spanish":"Una propuesta cultural imprescindible.","english":"An essential cultural offering."}]'::jsonb,
    grammar_note='"Aunque sea + adjective/adverb" = "even if only/even briefly". A common concessive idiom in recommendations.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "masterpiece"?','la obra maestra',array['la obra de arte','la exposición','la galería'],'masterpiece',1),
  (v_l1,'multiple_choice','What is "canvas"?','el lienzo',array['el pincel','el óleo','el marco'],'canvas',2),
  (v_l1,'fill_blank','Complete: "Sin ____ alguna, es Velázquez." (doubt)','duda',array['idea','pena','prisa'],'doubt',3),
  (v_l1,'multiple_choice','What does "óleo" mean?','oil paint',array['watercolor','sculpture','frame'],'oil paint',4),
  (v_l1,'multiple_choice','What is "exhibition"?','la exposición',array['la expansión','la explicación','la expresión'],'exhibition',5),
  (v_l2,'multiple_choice','What is "Renaissance"?','el Renacimiento',array['el Romanticismo','el Realismo','el Barroco'],'Renaissance',1),
  (v_l2,'multiple_choice','What does "vanguardista" mean?','avant-garde',array['traditional','conservative','classical'],'avant-garde',2),
  (v_l2,'fill_blank','Complete: "Aunque ____ en realismo, fundó el Cubismo." (started — fact)','empezó',array['empezara','empezaría','empieza'],'started (fact)',3),
  (v_l2,'multiple_choice','"Aunque + subjunctive" expresses?','even if (hypothetical)',array['although (factual)','because (factual)','since (factual)'],'even if',4),
  (v_l2,'multiple_choice','What is "influence"?','la influencia',array['la independencia','la inflación','la insolencia'],'influence',5),
  (v_l3,'multiple_choice','What is "composer"?','el compositor',array['el director','el intérprete','el músico'],'composer',1),
  (v_l3,'multiple_choice','What does "interpretar" mean?','to perform',array['to interpret (translate)','to inspect','to inherit'],'to perform',2),
  (v_l3,'fill_blank','Complete: "Tocó la pieza con ____" (sensitivity)','sensibilidad',array['sensible','sensibles','sensiblemente'],'sensitivity',3),
  (v_l3,'multiple_choice','What is "symphony"?','la sinfonía',array['la sintonía','la simetría','la sincronía'],'symphony',4),
  (v_l3,'multiple_choice','What is "harmony"?','la armonía',array['el ritmo','la melodía','la sinfonía'],'harmony',5),
  (v_l4,'multiple_choice','What is "premiere"?','el estreno',array['el ensayo','el cartel','el papel'],'premiere',1),
  (v_l4,'multiple_choice','What is "script"?','el guión',array['el guía','el guiso','el gusto'],'script',2),
  (v_l4,'fill_blank','Complete: "Fue ____ emotivo que aplaudieron." (so)','tan',array['tanto','muy','mucho'],'so (+ adj)',3),
  (v_l4,'multiple_choice','What is "role" (in a play)?','el papel',array['el ruedo','el real','el resto'],'role',4),
  (v_l4,'multiple_choice','What does "tanto X que Y" mean?','so much X that Y',array['as much X as Y','more X than Y','either X or Y'],'so much X that Y',5),
  (v_l5,'multiple_choice','What is "flamenco footwork"?','el zapateado',array['el zapato','el zafarrancho','el zaguán'],'footwork',1),
  (v_l5,'multiple_choice','What does "tanto... como..." mean?','both... and...',array['so... as...','more... than...','either... or...'],'both... and...',2),
  (v_l5,'fill_blank','Complete: "El flamenco es ____ baile ____ expresión cultural." (both, and)','tanto',array['tan','así','aún'],'both (... as)',3),
  (v_l5,'multiple_choice','What is "choreography"?','la coreografía',array['la cardiografía','la cartografía','la criptografía'],'choreography',4),
  (v_l5,'multiple_choice','What does "el baile" refer to?','social/popular dance',array['art-form dance','ballroom only','folk only'],'social dance',5),
  (v_l6,'multiple_choice','What does "deslumbrante" mean?','dazzling',array['disappointing','disgusting','dishonest'],'dazzling',1),
  (v_l6,'multiple_choice','What does "elogiar" mean?','to praise',array['to elaborate','to elapse','to elect'],'to praise',2),
  (v_l6,'fill_blank','Complete: "Aunque ____ por un ritmo lento." (opted — subj)','optara',array['optó','opta','optaría'],'opted (subj)',3),
  (v_l6,'multiple_choice','What is "innovative"?','innovador',array['imitador','iniciador','iluminador'],'innovative',4),
  (v_l6,'multiple_choice','What is "mediocre"?','mediocre',array['mediano','medieval','meditativo'],'mediocre',5),
  (v_l7,'multiple_choice','What does "merecer la pena" mean?','to be worth it',array['to be a pity','to deserve pity','to be in pain'],'to be worth it',1),
  (v_l7,'multiple_choice','What does "acudir" mean?','to attend',array['to accuse','to acquire','to admit'],'to attend',2),
  (v_l7,'fill_blank','Complete: "Aunque ____ brevemente." (be — subj, "even if briefly")','sea',array['es','será','fue'],'be (subj)',3),
  (v_l7,'multiple_choice','What is "review"?','la reseña',array['la receta','la represa','la rasante'],'review',4),
  (v_l7,'multiple_choice','What does "imprescindible" mean?','essential',array['important','impressive','impossible'],'essential',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Cuál es la obra maestra de esta exposición',array['El óleo de Velázquez','La galería está cerrada','La acuarela del fondo'],'Which is the masterpiece of this exhibition',6),
  (v_l1,'listening','What did you hear?','Sin duda, el óleo de Velázquez al fondo',array['La obra maestra está allí','La galería abre temprano','El lienzo es enorme'],'Without doubt, the Velázquez oil at the back',7),
  (v_l1,'speaking','Say this aloud: "Sin duda es la obra maestra."','Sin duda es la obra maestra',array[]::text[],'Without doubt it''s the masterpiece.',8),
  (v_l1,'speaking','Say this aloud: "El óleo está al fondo."','El óleo está al fondo',array[]::text[],'The oil is at the back.',9),
  (v_l2,'listening','What did you hear?','Picasso, aunque empezó en el realismo, fundó el Cubismo',array['El Surrealismo influyó en él','El Barroco lo inspiró','Recibió la influencia de Dalí'],'Picasso, although he started in realism, founded Cubism',6),
  (v_l2,'listening','What did you hear?','De quién recibió más influencia',array['Aunque empezó en realismo','Fundó el Cubismo','El estilo vanguardista'],'From whom did he receive the most influence',7),
  (v_l2,'speaking','Say this aloud: "Aunque empezó en realismo, fundó el Cubismo."','Aunque empezó en realismo, fundó el Cubismo',array[]::text[],'Although he started in realism, he founded Cubism.',8),
  (v_l2,'speaking','Say this aloud: "Recibió influencia del Surrealismo."','Recibió influencia del Surrealismo',array[]::text[],'He received influence from Surrealism.',9),
  (v_l3,'listening','What did you hear?','La orquesta interpretó la sinfonía con una sensibilidad excepcional',array['El compositor era joven','El director era estricto','La armonía era perfecta'],'The orchestra performed the symphony with exceptional sensitivity',6),
  (v_l3,'listening','What did you hear?','con una sensibilidad excepcional',array['con maestría absoluta','con elegancia austera','con ritmo intenso'],'with exceptional sensitivity',7),
  (v_l3,'speaking','Say this aloud: "Tocó con sensibilidad excepcional."','Tocó con sensibilidad excepcional',array[]::text[],'He played with exceptional sensitivity.',8),
  (v_l3,'speaking','Say this aloud: "El compositor era genial."','El compositor era genial',array[]::text[],'The composer was a genius.',9),
  (v_l6,'listening','What did you hear?','La interpretación fue deslumbrante',array['Aunque el director optara por un ritmo lento','Una obra mediocre','Marcará la temporada'],'The performance was dazzling',6),
  (v_l6,'listening','What did you hear?','Una obra que sin duda marcará la temporada',array['La interpretación fue deslumbrante','El ritmo fue lento','El director optó por'],'A work that without doubt will mark the season',7),
  (v_l6,'speaking','Say this aloud: "Una interpretación deslumbrante."','Una interpretación deslumbrante',array[]::text[],'A dazzling performance.',8),
  (v_l6,'speaking','Say this aloud: "Marcará la temporada."','Marcará la temporada',array[]::text[],'It will mark the season.',9),
  (v_l7,'listening','What did you hear?','La colección del Prado merece la pena visitarla aunque sea brevemente',array['Una propuesta imprescindible','Sin lugar a dudas','La galería abre tarde'],'The Prado collection is worth visiting even briefly',6),
  (v_l7,'listening','What did you hear?','Una propuesta cultural imprescindible',array['La colección merece la pena','Aunque sea brevemente','Sin lugar a dudas'],'An essential cultural offering',7),
  (v_l7,'speaking','Say this aloud: "Merece la pena visitarla."','Merece la pena visitarla',array[]::text[],'It''s worth visiting.',8),
  (v_l7,'speaking','Say this aloud: "Una propuesta imprescindible."','Una propuesta imprescindible',array[]::text[],'An essential offering.',9);

  update public.lessons set type='conversation', title='Arts & Culture — Conversation Practice',
    description='Two friends discuss an exhibition.',
    intro='Marta and David visit the museum.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Marta","spanish":"¿Has visto la nueva exposición de Sorolla?","english":"Have you seen the new Sorolla exhibition?"},{"speaker":"David","spanish":"Sí, los óleos son deslumbrantes. Sin duda, una obra maestra del Impresionismo español.","english":"Yes, the oil paintings are dazzling. Without doubt, a masterpiece of Spanish Impressionism."},{"speaker":"Marta","spanish":"Aunque la crítica no la elogió tanto como esperaba.","english":"Although critics didn''t praise it as much as I expected."},{"speaker":"David","spanish":"La crítica es subjetiva. Yo la encontré tan emotiva que volvería mañana.","english":"Criticism is subjective. I found it so moving I would go again tomorrow."},{"speaker":"Marta","spanish":"Tanto la luz como el color son extraordinarios.","english":"Both the light and the color are extraordinary."},{"speaker":"David","spanish":"Merece la pena visitarla aunque sea por segunda vez.","english":"It''s worth visiting even if for a second time."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','Whose exhibition is it?','Sorolla',array['Velázquez','Picasso','Goya'],'la exposición de Sorolla',1),
  (v_l8,'multiple_choice','David''s opinion of the oils?','Dazzling',array['Mediocre','Conventional','Disappointing'],'deslumbrantes',2),
  (v_l8,'multiple_choice','What does Marta say about critics?','They didn''t praise as much as expected',array['They loved it','They ignored it','They wrote nothing'],'la crítica no la elogió tanto',3),
  (v_l8,'multiple_choice','David''s response?','Criticism is subjective; he''d return tomorrow',array['Critics are always right','He won''t go back','He hated it'],'la crítica es subjetiva',4),
  (v_l8,'fill_blank','Complete: "Tanto la luz ____ el color." (and)','como',array['así','tal','que'],'as',5),
  (v_l8,'multiple_choice','Why visit again?','It''s worth it even for a second time',array['First time wasn''t enough','To buy something','For free entry'],'aunque sea por segunda vez',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Arts & Culture', 'Review test for the Arts & Culture section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "Cubism"?','el Cubismo',array['el Realismo','el Romanticismo','el Surrealismo'],'Cubism',1),
  (v_lesson_id,'multiple_choice','"Aunque + indicative" vs subjunctive?','indicative = fact, subjunctive = hypothetical',array['Always the same','Indicative is wrong','Subjunctive is wrong'],'aunque mode',2),
  (v_lesson_id,'multiple_choice','What is "premiere"?','el estreno',array['el ensayo','el guión','el papel'],'premiere',3),
  (v_lesson_id,'multiple_choice','"Tanto X como Y" means?','both X and Y',array['so much X that Y','more X than Y','either X or Y'],'both X and Y',4),
  (v_lesson_id,'fill_blank','Complete: "Aunque ____ brevemente." (be — subj)','sea',array['es','fue','será'],'be (subj)',5),
  (v_lesson_id,'fill_blank','Complete: "Sin ____ alguna." (doubt)','duda',array['idea','prisa','pena'],'doubt',6),
  (v_lesson_id,'listening','What did you hear?','Sin duda es una obra maestra',array['El Cubismo es vanguardista','La interpretación fue deslumbrante','Merece la pena visitar'],'Without doubt it''s a masterpiece',7),
  (v_lesson_id,'listening','What did you hear?','Aunque empezó en el realismo, fundó el Cubismo',array['La crítica fue dura','El museo está cerrado','El estreno fue ayer'],'Although he started in realism, he founded Cubism',8),
  (v_lesson_id,'speaking','Say this aloud: "Merece la pena visitarla."','Merece la pena visitarla',array[]::text[],'It''s worth visiting.',9),
  (v_lesson_id,'speaking','Say this aloud: "Una obra maestra del Impresionismo."','Una obra maestra del Impresionismo',array[]::text[],'A masterpiece of Impressionism.',10);

  -- ===========================================================
  -- B2.8 MEDIA & JOURNALISM
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B2' and title = 'Media & Journalism';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='News vocabulary: "el periódico" (newspaper), "el reportaje" (report), "la noticia" (news item). Spanish journalism uses dense nominalizations.',
    vocab_items='[{"spanish":"el periódico","english":"newspaper"},{"spanish":"la noticia","english":"news item"},{"spanish":"el reportaje","english":"report"},{"spanish":"el titular","english":"headline"},{"spanish":"el periodista","english":"journalist"},{"spanish":"informar","english":"to inform"},{"spanish":"la fuente","english":"source"},{"spanish":"el medio","english":"medium/outlet"},{"spanish":"la prensa","english":"the press"},{"spanish":"el redactor","english":"editor (writer)"}]'::jsonb,
    dialogue='[{"speaker":"Lectora","spanish":"¿De qué medio es esta noticia?","english":"Which outlet is this news from?"},{"speaker":"Lector","spanish":"De El País. Las fuentes parecen fiables.","english":"From El País. The sources seem reliable."}]'::jsonb,
    grammar_note='"Parecer + adjective" describes appearance/impression: "parece fiable" = "seems reliable". The adjective agrees with the subject.'
  where id = v_l1;

  update public.lessons set
    intro='Reported speech in news: when a journalist quotes, tenses shift. "Dijo que iba" instead of "dijo: voy". Master the back-shift.',
    vocab_items='[{"spanish":"declarar","english":"to declare"},{"spanish":"afirmar","english":"to affirm"},{"spanish":"negar","english":"to deny"},{"spanish":"confirmar","english":"to confirm"},{"spanish":"desmentir","english":"to refute"},{"spanish":"el portavoz","english":"spokesperson"},{"spanish":"la rueda de prensa","english":"press conference"},{"spanish":"según","english":"according to"},{"spanish":"asegurar","english":"to assure"},{"spanish":"manifestar","english":"to state"}]'::jsonb,
    dialogue='[{"speaker":"Reportero","spanish":"El ministro declaró que estaba evaluando la situación.","english":"The minister declared he was evaluating the situation."},{"speaker":"Reportero","spanish":"Negó que hubiera ocultado información.","english":"He denied he had concealed information."}]'::jsonb,
    grammar_note='Reported speech back-shift: present → imperfect ("estoy" → "estaba"), perfect → pluperfect ("he ocultado" → "hubiera ocultado"). After "negar que", always subjunctive.'
  where id = v_l2;

  update public.lessons set
    intro='Press freedom and ethics: censorship, freedom of expression, fake news. Spanish has "noticias falsas" or the anglicism "fake news".',
    vocab_items='[{"spanish":"la libertad de prensa","english":"press freedom"},{"spanish":"la censura","english":"censorship"},{"spanish":"la libertad de expresión","english":"freedom of expression"},{"spanish":"las noticias falsas","english":"fake news"},{"spanish":"la desinformación","english":"misinformation"},{"spanish":"verificar","english":"to verify"},{"spanish":"la ética periodística","english":"journalistic ethics"},{"spanish":"el sesgo","english":"bias"},{"spanish":"la imparcialidad","english":"impartiality"},{"spanish":"objetivo","english":"objective"}]'::jsonb,
    dialogue='[{"speaker":"Editorialista","spanish":"Sin libertad de prensa, la democracia se debilita.","english":"Without press freedom, democracy weakens."}]'::jsonb,
    grammar_note='"Sin + noun" forms condition-like phrases: "sin libertad" = "without freedom" (implying consequence). Often paired with present-tense consequence: "sin X, Y ocurre".'
  where id = v_l3;

  update public.lessons set
    intro='Social media has transformed journalism. New vocabulary for digital platforms.',
    vocab_items='[{"spanish":"las redes sociales","english":"social media"},{"spanish":"viral","english":"viral"},{"spanish":"el tuit","english":"tweet"},{"spanish":"compartir","english":"to share"},{"spanish":"el seguidor","english":"follower"},{"spanish":"el influencer","english":"influencer"},{"spanish":"el algoritmo","english":"algorithm"},{"spanish":"la burbuja informativa","english":"information bubble"},{"spanish":"viralizar","english":"to make viral"},{"spanish":"hacerse viral","english":"to go viral"}]'::jsonb,
    dialogue='[{"speaker":"Analista","spanish":"El vídeo se hizo viral antes de que se verificaran los hechos.","english":"The video went viral before the facts were verified."}]'::jsonb,
    grammar_note='"Antes de que + subjunctive" = "before + clause". Always subjunctive after "antes de que": "antes de que llegues", "antes de que se verificaran".'
  where id = v_l4;

  update public.lessons set
    intro='Investigative journalism: "el periodismo de investigación" exposes corruption, abuse. Strong, formal verbs.',
    vocab_items='[{"spanish":"investigar","english":"to investigate"},{"spanish":"denunciar","english":"to denounce"},{"spanish":"el escándalo","english":"scandal"},{"spanish":"destapar","english":"to uncover"},{"spanish":"el caso","english":"case"},{"spanish":"la corrupción","english":"corruption"},{"spanish":"la trama","english":"plot/scheme"},{"spanish":"implicar","english":"to implicate"},{"spanish":"la filtración","english":"leak"},{"spanish":"el informante","english":"informant"}]'::jsonb,
    dialogue='[{"speaker":"Periodista","spanish":"Tras meses de investigación, conseguimos destapar la trama.","english":"After months of investigation, we managed to uncover the scheme."}]'::jsonb,
    grammar_note='"Conseguir + infinitive" = "to manage to + verb". Stronger than "poder" — emphasizes effort and success.'
  where id = v_l5;

  update public.lessons set
    intro='Radio news listening: news broadcasts are dense and formal. Listen for key dates, figures, names.',
    vocab_items='[{"spanish":"la emisora","english":"radio station"},{"spanish":"emitir","english":"to broadcast"},{"spanish":"la cobertura","english":"coverage"},{"spanish":"el corresponsal","english":"correspondent"},{"spanish":"en directo","english":"live"},{"spanish":"el boletín","english":"bulletin"},{"spanish":"transmitir","english":"to transmit/broadcast"}]'::jsonb,
    dialogue='[{"speaker":"Locutor","spanish":"Buenos días, les ofrecemos un avance de los titulares de hoy.","english":"Good morning, here''s a preview of today''s headlines."},{"speaker":"Locutor","spanish":"Conectamos en directo con nuestra corresponsal en Madrid.","english":"We connect live with our correspondent in Madrid."}]'::jsonb,
    grammar_note='Broadcast formulae: "les ofrecemos", "conectamos en directo", "a continuación". Use "ustedes" for the polite plural addressed to the audience.'
  where id = v_l6;

  update public.lessons set
    intro='Write a news article opening. Structure: lead (the 5 Ws), context, quote, analysis.',
    vocab_items='[{"spanish":"el lead","english":"lead (opening)"},{"spanish":"el cuerpo (del artículo)","english":"article body"},{"spanish":"la cita","english":"quotation"},{"spanish":"contextualizar","english":"to contextualize"},{"spanish":"datar","english":"to date"},{"spanish":"el suceso","english":"event/incident"},{"spanish":"acontecer","english":"to occur (formal)"},{"spanish":"el hecho","english":"fact"}]'::jsonb,
    dialogue='[{"speaker":"Artículo","spanish":"Madrid, lunes — el presidente anunció ayer una serie de reformas económicas que entrarán en vigor a principios del próximo año.","english":"Madrid, Monday — the president announced yesterday a series of economic reforms that will take effect at the beginning of next year."},{"speaker":"Artículo","spanish":"Según fuentes del gobierno, el paquete incluye recortes y nuevas inversiones.","english":"According to government sources, the package includes cuts and new investments."}]'::jsonb,
    grammar_note='News lead format: place, date, em-dash, then content. "Entrarán en vigor" = "will take effect" — a fixed legal/journalistic phrase.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "headline"?','el titular',array['el reportaje','la noticia','la fuente'],'headline',1),
  (v_l1,'multiple_choice','What is "source" (info)?','la fuente',array['la fonte','el manantial','el origen'],'source',2),
  (v_l1,'fill_blank','Complete: "Las fuentes ____ fiables." (seem)','parecen',array['parece','parecemos','parecían'],'seem',3),
  (v_l1,'multiple_choice','What is "press"?','la prensa',array['la prisa','la presa','el preso'],'press',4),
  (v_l1,'multiple_choice','What is "editor (writer)"?','el redactor',array['el lector','el dictador','el director'],'editor',5),
  (v_l2,'multiple_choice','What does "desmentir" mean?','to refute',array['to dismiss','to dismay','to dispatch'],'to refute',1),
  (v_l2,'multiple_choice','What follows "negar que"?','subjunctive',array['indicative','infinitive','conditional'],'negar que + subj',2),
  (v_l2,'fill_blank','Complete: "Negó que ____ información." (had concealed — pluperf subj)','hubiera ocultado',array['ocultó','había ocultado','ha ocultado'],'had concealed (subj)',3),
  (v_l2,'multiple_choice','What is "press conference"?','la rueda de prensa',array['la rueda libre','la prensa de prensa','la conferencia escrita'],'press conference',4),
  (v_l2,'multiple_choice','What does "según" mean?','according to',array['without','before','during'],'according to',5),
  (v_l3,'multiple_choice','What is "censorship"?','la censura',array['la sentencia','el centro','la severidad'],'censorship',1),
  (v_l3,'multiple_choice','What is "bias"?','el sesgo',array['el seso','el sello','el seto'],'bias',2),
  (v_l3,'fill_blank','Complete: "____ libertad de prensa, la democracia se debilita." (Without)','Sin',array['Con','Por','Tras'],'without',3),
  (v_l3,'multiple_choice','What is "fake news"?','las noticias falsas',array['las falsas noticias','las nuevas noticias','las viejas noticias'],'fake news',4),
  (v_l3,'multiple_choice','What does "imparcialidad" mean?','impartiality',array['inability','impatience','immortality'],'impartiality',5),
  (v_l4,'multiple_choice','What does "hacerse viral" mean?','to go viral',array['to make a virus','to view virally','to vacate viral'],'to go viral',1),
  (v_l4,'multiple_choice','What follows "antes de que"?','subjunctive',array['indicative','infinitive','conditional'],'antes de que + subj',2),
  (v_l4,'fill_blank','Complete: "Antes de que se ____ los hechos." (verified — imperf subj)','verificaran',array['verifican','verificaron','verificarían'],'verified (subj)',3),
  (v_l4,'multiple_choice','What is "follower"?','el seguidor',array['el seguido','el segundo','el seguro'],'follower',4),
  (v_l4,'multiple_choice','What is "information bubble"?','la burbuja informativa',array['la bola informativa','la bolsa informativa','la bomba informativa'],'information bubble',5),
  (v_l5,'multiple_choice','What does "destapar" mean?','to uncover',array['to deepen','to destabilize','to detach'],'to uncover',1),
  (v_l5,'multiple_choice','What is "scheme/plot"?','la trama',array['la tarima','la rama','la cama'],'scheme',2),
  (v_l5,'fill_blank','Complete: "____ destapar la trama." (we managed to)','Conseguimos',array['Pudimos','Quisimos','Sabíamos'],'we managed to',3),
  (v_l5,'multiple_choice','What does "denunciar" mean?','to denounce',array['to demand','to depart','to depend'],'to denounce',4),
  (v_l5,'multiple_choice','What is "informant"?','el informante',array['el informador','el inflado','el inflexible'],'informant',5),
  (v_l6,'multiple_choice','What is "live (broadcast)"?','en directo',array['en derecho','en directa','al directo'],'live',1),
  (v_l6,'multiple_choice','What is "correspondent"?','el corresponsal',array['el corresponder','el corresponsable','el correspondiente'],'correspondent',2),
  (v_l6,'fill_blank','Complete: "Les ____ un avance." (we offer — formal pl.)','ofrecemos',array['ofrezco','ofreces','ofrecen'],'we offer',3),
  (v_l6,'multiple_choice','What is "bulletin"?','el boletín',array['el bote','el bolso','el botín'],'bulletin',4),
  (v_l6,'multiple_choice','What is "coverage"?','la cobertura',array['la cubierta','la cobardía','la cobranza'],'coverage',5),
  (v_l7,'multiple_choice','What does "entrar en vigor" mean?','to take effect',array['to enter forcefully','to enter the office','to enter the gym'],'to take effect',1),
  (v_l7,'multiple_choice','What does "acontecer" mean?','to occur (formal)',array['to account','to accuse','to acknowledge'],'to occur',2),
  (v_l7,'fill_blank','Complete: "____ fuentes del gobierno." (according to)','Según',array['Sin','Sobre','Salvo'],'according to',3),
  (v_l7,'multiple_choice','What is "quotation"?','la cita',array['la ciudad','la cifra','la civilización'],'quotation',4),
  (v_l7,'multiple_choice','What is "fact"?','el hecho',array['el techo','el dicho','el lecho'],'fact',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','De qué medio es esta noticia',array['Las fuentes parecen fiables','Es de El País','El titular es claro'],'Which outlet is this news from',6),
  (v_l1,'listening','What did you hear?','Las fuentes parecen fiables',array['De qué medio es','Es de El País','El reportaje es largo'],'The sources seem reliable',7),
  (v_l1,'speaking','Say this aloud: "Las fuentes parecen fiables."','Las fuentes parecen fiables',array[]::text[],'The sources seem reliable.',8),
  (v_l1,'speaking','Say this aloud: "El titular es claro."','El titular es claro',array[]::text[],'The headline is clear.',9),
  (v_l2,'listening','What did you hear?','El ministro declaró que estaba evaluando la situación',array['Negó que hubiera ocultado','La rueda de prensa fue corta','El portavoz no asistió'],'The minister declared he was evaluating the situation',6),
  (v_l2,'listening','What did you hear?','Negó que hubiera ocultado información',array['Declaró que estaba evaluando','Confirmó las acusaciones','Desmintió las cifras'],'He denied he had concealed information',7),
  (v_l2,'speaking','Say this aloud: "Declaró que estaba evaluando."','Declaró que estaba evaluando',array[]::text[],'He declared he was evaluating.',8),
  (v_l2,'speaking','Say this aloud: "Negó que hubiera ocultado información."','Negó que hubiera ocultado información',array[]::text[],'He denied he had concealed information.',9),
  (v_l3,'listening','What did you hear?','Sin libertad de prensa, la democracia se debilita',array['La censura es necesaria','El sesgo es inevitable','La imparcialidad cuesta'],'Without press freedom, democracy weakens',6),
  (v_l3,'listening','What did you hear?','la democracia se debilita',array['la democracia se fortalece','la democracia se renueva','la democracia se transforma'],'democracy weakens',7),
  (v_l3,'speaking','Say this aloud: "Sin libertad de prensa, la democracia se debilita."','Sin libertad de prensa, la democracia se debilita',array[]::text[],'Without press freedom, democracy weakens.',8),
  (v_l3,'speaking','Say this aloud: "El sesgo es inevitable."','El sesgo es inevitable',array[]::text[],'Bias is inevitable.',9),
  (v_l6,'listening','What did you hear?','Buenos días, les ofrecemos un avance de los titulares',array['Conectamos en directo','El boletín comienza ya','La cobertura es completa'],'Good morning, here''s a preview of headlines',6),
  (v_l6,'listening','What did you hear?','Conectamos en directo con nuestra corresponsal en Madrid',array['Les ofrecemos un avance','El boletín finaliza','La emisora abre'],'We connect live with our correspondent in Madrid',7),
  (v_l6,'speaking','Say this aloud: "Les ofrecemos los titulares."','Les ofrecemos los titulares',array[]::text[],'Here are the headlines.',8),
  (v_l6,'speaking','Say this aloud: "Conectamos en directo."','Conectamos en directo',array[]::text[],'We connect live.',9),
  (v_l7,'listening','What did you hear?','Madrid, lunes — el presidente anunció ayer una serie de reformas económicas',array['Según fuentes del gobierno','El paquete incluye recortes','Entrarán en vigor a principios'],'Madrid, Monday — the president announced economic reforms',6),
  (v_l7,'listening','What did you hear?','Según fuentes del gobierno, el paquete incluye recortes y nuevas inversiones',array['El presidente anunció reformas','Entrarán en vigor','Madrid, lunes'],'According to government sources, the package includes cuts and new investments',7),
  (v_l7,'speaking','Say this aloud: "Entrarán en vigor el próximo año."','Entrarán en vigor el próximo año',array[]::text[],'They will take effect next year.',8),
  (v_l7,'speaking','Say this aloud: "Según fuentes del gobierno."','Según fuentes del gobierno',array[]::text[],'According to government sources.',9);

  update public.lessons set type='conversation', title='Media & Journalism — Conversation Practice',
    description='Two journalists discuss a story.',
    intro='Carmen and Pablo review a breaking news piece.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Carmen","spanish":"¿Has verificado las fuentes del reportaje?","english":"Have you verified the sources of the report?"},{"speaker":"Pablo","spanish":"Sí, tres fuentes independientes confirmaron los hechos.","english":"Yes, three independent sources confirmed the facts."},{"speaker":"Carmen","spanish":"El portavoz declaró ayer que negaba toda implicación.","english":"The spokesperson declared yesterday that he denied any involvement."},{"speaker":"Pablo","spanish":"Pero, según un informante, hubo filtraciones desde dentro.","english":"But, according to an informant, there were leaks from within."},{"speaker":"Carmen","spanish":"Tenemos que publicar antes de que se haga viral por otro medio.","english":"We have to publish before it goes viral through another outlet."},{"speaker":"Pablo","spanish":"De acuerdo. Sin la verificación rigurosa, no podemos arriesgar nuestra credibilidad.","english":"Agreed. Without rigorous verification, we can''t risk our credibility."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','How many sources confirmed the facts?','Three independent sources',array['One','Two','Five'],'tres fuentes independientes',1),
  (v_l8,'multiple_choice','What did the spokesperson declare?','He denied any involvement',array['He confirmed involvement','He resigned','He had no comment'],'negaba toda implicación',2),
  (v_l8,'multiple_choice','What did the informant say?','There were leaks from within',array['There was no story','Everyone was lying','The case was closed'],'hubo filtraciones desde dentro',3),
  (v_l8,'multiple_choice','Why the urgency?','Before it goes viral elsewhere',array['Before the deadline','Before the editor gets angry','Before the office closes'],'antes de que se haga viral',4),
  (v_l8,'fill_blank','Complete: "Antes de que se ____ viral." (becomes — subj)','haga',array['hace','hizo','hará'],'becomes (subj)',5),
  (v_l8,'multiple_choice','Why verify rigorously?','Can''t risk credibility',array['It''s required by law','To get more clicks','To delay publication'],'no podemos arriesgar nuestra credibilidad',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Media & Journalism', 'Review test for the Media & Journalism section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "headline"?','el titular',array['la noticia','la fuente','el reportaje'],'headline',1),
  (v_lesson_id,'multiple_choice','What follows "negar que"?','subjunctive',array['indicative','infinitive','imperative'],'negar que + subj',2),
  (v_lesson_id,'multiple_choice','What follows "antes de que"?','subjunctive',array['indicative','infinitive','imperative'],'antes de que + subj',3),
  (v_lesson_id,'multiple_choice','What is "bias"?','el sesgo',array['la censura','la imparcialidad','la objetividad'],'bias',4),
  (v_lesson_id,'fill_blank','Complete: "Negó que ____ información." (had concealed — pluperf subj)','hubiera ocultado',array['ocultó','había ocultado','oculta'],'had concealed',5),
  (v_lesson_id,'fill_blank','Complete: "____ fuentes oficiales." (according to)','Según',array['Sin','Sobre','Tras'],'according to',6),
  (v_lesson_id,'listening','What did you hear?','Antes de que se haga viral por otro medio',array['Las fuentes son fiables','La rueda de prensa fue corta','El boletín comienza'],'Before it goes viral through another outlet',7),
  (v_lesson_id,'listening','What did you hear?','Conectamos en directo con nuestra corresponsal',array['Les ofrecemos un avance','El paquete incluye recortes','La emisora cierra'],'We connect live with our correspondent',8),
  (v_lesson_id,'speaking','Say this aloud: "Las fuentes parecen fiables."','Las fuentes parecen fiables',array[]::text[],'The sources seem reliable.',9),
  (v_lesson_id,'speaking','Say this aloud: "Entrarán en vigor el próximo año."','Entrarán en vigor el próximo año',array[]::text[],'They will take effect next year.',10);

  -- ===========================================================
  -- B2.9 LAW & JUSTICE
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B2' and title = 'Law & Justice';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='Spanish legal vocabulary draws from Roman law. Key terms: "el derecho" (law/right), "la ley" (statute), "el juez" (judge).',
    vocab_items='[{"spanish":"el derecho","english":"law/right"},{"spanish":"la ley","english":"statute/law"},{"spanish":"el juez","english":"judge"},{"spanish":"el abogado","english":"lawyer"},{"spanish":"el tribunal","english":"court"},{"spanish":"el caso","english":"case"},{"spanish":"la justicia","english":"justice"},{"spanish":"la sentencia","english":"sentence/verdict"},{"spanish":"la demanda","english":"lawsuit"},{"spanish":"el acusado","english":"defendant"}]'::jsonb,
    dialogue='[{"speaker":"Abogado","spanish":"El tribunal dictará sentencia el próximo mes.","english":"The court will hand down a sentence next month."},{"speaker":"Cliente","spanish":"¿Cuáles son las probabilidades a nuestro favor?","english":"What are the odds in our favor?"}]'::jsonb,
    grammar_note='"Dictar sentencia" = "to hand down a verdict". A fixed legal collocation. Other useful ones: "dictar una ley", "dictar normas".'
  where id = v_l1;

  update public.lessons set
    intro='Crimes and penalties: "el delito" (crime), "el robo" (theft), "el fraude" (fraud). The penalty system: "la multa", "la cárcel".',
    vocab_items='[{"spanish":"el delito","english":"crime"},{"spanish":"el robo","english":"theft"},{"spanish":"el fraude","english":"fraud"},{"spanish":"la estafa","english":"scam"},{"spanish":"el homicidio","english":"homicide"},{"spanish":"la multa","english":"fine"},{"spanish":"la cárcel","english":"prison"},{"spanish":"la condena","english":"conviction/sentence"},{"spanish":"el culpable","english":"the guilty party"},{"spanish":"el inocente","english":"the innocent party"}]'::jsonb,
    dialogue='[{"speaker":"Fiscal","spanish":"Solicito una condena de diez años de cárcel.","english":"I request a sentence of ten years in prison."},{"speaker":"Defensa","spanish":"Mi cliente es inocente, no hay pruebas suficientes.","english":"My client is innocent, there is insufficient evidence."}]'::jsonb,
    grammar_note='"No hay + noun + suficiente" = "there isn''t enough...". The adjective agrees with the noun: "pruebas suficientes" (fem pl).'
  where id = v_l2;

  update public.lessons set
    intro='Rights and constitutions: human rights, fundamental rights, the constitution as supreme law.',
    vocab_items='[{"spanish":"los derechos humanos","english":"human rights"},{"spanish":"la constitución","english":"constitution"},{"spanish":"el ciudadano","english":"citizen"},{"spanish":"el deber","english":"duty"},{"spanish":"la libertad","english":"freedom"},{"spanish":"la igualdad","english":"equality"},{"spanish":"el privilegio","english":"privilege"},{"spanish":"vulnerar","english":"to violate"},{"spanish":"amparar","english":"to protect (legally)"},{"spanish":"reclamar","english":"to claim"}]'::jsonb,
    dialogue='[{"speaker":"Activista","spanish":"La constitución ampara el derecho a la libertad de expresión.","english":"The constitution protects the right to freedom of expression."}]'::jsonb,
    grammar_note='"Amparar" = "to protect under (the law)". Distinct from "proteger" (general protection). Frequent in legal Spanish: "la ley ampara a los menores".'
  where id = v_l3;

  update public.lessons set
    intro='Trial vocabulary: prosecution, defense, jury, witness. Spanish courts have "el jurado popular" in some criminal cases.',
    vocab_items='[{"spanish":"el juicio","english":"trial"},{"spanish":"el fiscal","english":"prosecutor"},{"spanish":"la defensa","english":"defense"},{"spanish":"el jurado","english":"jury"},{"spanish":"el testigo","english":"witness"},{"spanish":"declarar","english":"to testify"},{"spanish":"la prueba","english":"proof/evidence"},{"spanish":"el veredicto","english":"verdict"},{"spanish":"absuelto","english":"acquitted"},{"spanish":"culpable","english":"guilty"}]'::jsonb,
    dialogue='[{"speaker":"Juez","spanish":"El jurado declaró al acusado culpable por unanimidad.","english":"The jury declared the defendant guilty unanimously."}]'::jsonb,
    grammar_note='"Declarar + a + person + adjective" = "to declare somebody...". The personal "a" is required when the direct object is a specific person: "declaró al acusado culpable".'
  where id = v_l4;

  update public.lessons set
    intro='Civil vs criminal law distinctions: "derecho civil" handles property, family, contracts; "derecho penal" handles crimes.',
    vocab_items='[{"spanish":"el derecho civil","english":"civil law"},{"spanish":"el derecho penal","english":"criminal law"},{"spanish":"el contrato","english":"contract"},{"spanish":"firmar","english":"to sign"},{"spanish":"la propiedad","english":"property"},{"spanish":"la herencia","english":"inheritance"},{"spanish":"el divorcio","english":"divorce"},{"spanish":"la custodia","english":"custody"},{"spanish":"el alquiler","english":"rent"},{"spanish":"el arrendador","english":"landlord"}]'::jsonb,
    dialogue='[{"speaker":"Abogada","spanish":"Si hubiera firmado el contrato, no habría tenido este problema.","english":"If she had signed the contract, she wouldn''t have had this problem."}]'::jsonb,
    grammar_note='Third conditional revisited: "si hubiera firmado, no habría tenido" — past unreal. Both clauses use compound forms (pluperfect subjunctive + conditional perfect).'
  where id = v_l5;

  update public.lessons set
    intro='Listen to a courtroom exchange. Note the formal register used by lawyers and judges.',
    vocab_items='[{"spanish":"señoría","english":"Your Honor"},{"spanish":"objetar","english":"to object"},{"spanish":"el interrogatorio","english":"questioning"},{"spanish":"el alegato","english":"plea/argument"},{"spanish":"la audiencia","english":"hearing"},{"spanish":"el recurso","english":"appeal"},{"spanish":"apelar","english":"to appeal"}]'::jsonb,
    dialogue='[{"speaker":"Abogado","spanish":"Señoría, objeto a esa pregunta — es irrelevante.","english":"Your Honor, I object to that question — it is irrelevant."},{"speaker":"Juez","spanish":"Objeción aceptada. La defensa puede continuar.","english":"Objection sustained. The defense may continue."}]'::jsonb,
    grammar_note='Courtroom formulae: "señoría", "objeto a + complement", "objeción aceptada/rechazada", "no más preguntas".'
  where id = v_l6;

  update public.lessons set
    intro='Write a legal complaint (a "queja formal"). Structure: facts, applicable law, request.',
    vocab_items='[{"spanish":"la queja","english":"complaint"},{"spanish":"interponer","english":"to file (a complaint)"},{"spanish":"el incumplimiento","english":"breach"},{"spanish":"exigir","english":"to demand"},{"spanish":"el plazo","english":"deadline"},{"spanish":"resolver","english":"to resolve"},{"spanish":"la indemnización","english":"compensation"},{"spanish":"la reclamación","english":"claim"}]'::jsonb,
    dialogue='[{"speaker":"Carta","spanish":"Por la presente, interpongo una reclamación formal por incumplimiento de contrato.","english":"By the present (letter), I file a formal claim for breach of contract."},{"speaker":"Carta","spanish":"Exijo una indemnización en un plazo de quince días.","english":"I demand compensation within fifteen days."}]'::jsonb,
    grammar_note='"Por la presente" = "by the present (letter)" — a fixed opening for formal legal correspondence. "En un plazo de + duration" = "within X time".'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "judge"?','el juez',array['el jurado','el fiscal','el abogado'],'judge',1),
  (v_l1,'multiple_choice','What is "lawsuit"?','la demanda',array['la sentencia','la deuda','la denuncia'],'lawsuit',2),
  (v_l1,'fill_blank','Complete: "El tribunal ____ sentencia." (will hand down)','dictará',array['dirá','dará','dejará'],'will hand down',3),
  (v_l1,'multiple_choice','What is "defendant"?','el acusado',array['el acusador','el acudido','el aceptado'],'defendant',4),
  (v_l1,'multiple_choice','What does "el derecho" mean (singular)?','law/right',array['the duty','the case','the court'],'law/right',5),
  (v_l2,'multiple_choice','What is "fraud"?','el fraude',array['el robo','la estafa','el delito'],'fraud',1),
  (v_l2,'multiple_choice','What is "fine"?','la multa',array['la cárcel','la condena','la culpa'],'fine',2),
  (v_l2,'fill_blank','Complete: "No hay pruebas ____" (sufficient)','suficientes',array['suficiente','suficientement','suficient'],'sufficient (fem pl)',3),
  (v_l2,'multiple_choice','What is "homicide"?','el homicidio',array['el holocausto','el homenaje','el horario'],'homicide',4),
  (v_l2,'multiple_choice','What does "la estafa" mean?','scam',array['stamp','stable','stage'],'scam',5),
  (v_l3,'multiple_choice','What does "amparar" mean?','to protect (legally)',array['to embrace','to amend','to amplify'],'to protect (legally)',1),
  (v_l3,'multiple_choice','What does "vulnerar" mean?','to violate',array['to vulgarize','to vacate','to vanish'],'to violate',2),
  (v_l3,'fill_blank','Complete: "La constitución ____ el derecho." (protects)','ampara',array['amparar','amparado','amparo'],'protects',3),
  (v_l3,'multiple_choice','What is "duty"?','el deber',array['el dueño','el dedo','el dato'],'duty',4),
  (v_l3,'multiple_choice','What is "equality"?','la igualdad',array['la libertad','la lealtad','la liviandad'],'equality',5),
  (v_l4,'multiple_choice','What is "jury"?','el jurado',array['el jefe','el juez','el justo'],'jury',1),
  (v_l4,'multiple_choice','What is "witness"?','el testigo',array['el testimonio','el técnico','el tendero'],'witness',2),
  (v_l4,'fill_blank','Complete: "Declaró ____ acusado culpable." (the - personal a)','al',array['el','a','del'],'the (personal a)',3),
  (v_l4,'multiple_choice','What does "absuelto" mean?','acquitted',array['absent','absolute','absurd'],'acquitted',4),
  (v_l4,'multiple_choice','What is "verdict"?','el veredicto',array['la sentencia','el veneno','la verdad'],'verdict',5),
  (v_l5,'multiple_choice','What is "contract"?','el contrato',array['el contraste','el control','el contorno'],'contract',1),
  (v_l5,'multiple_choice','What does "third conditional" use?','si hubiera + habría',array['si tuviera + tendría','si tiene + tendrá','si tuviera + tendrá'],'past unreal',2),
  (v_l5,'fill_blank','Complete: "Si ____ firmado el contrato." (had — pluperf subj)','hubiera',array['había','habría','habrá'],'had (subj)',3),
  (v_l5,'multiple_choice','What is "custody"?','la custodia',array['la curia','la cuesta','la cultura'],'custody',4),
  (v_l5,'multiple_choice','What is "inheritance"?','la herencia',array['la heredad','la frenesí','la herida'],'inheritance',5),
  (v_l6,'multiple_choice','How to address a judge?','Señoría',array['Excelencia','Majestad','Don'],'Your Honor',1),
  (v_l6,'multiple_choice','What does "objetar" mean?','to object',array['to obey','to observe','to obtain'],'to object',2),
  (v_l6,'fill_blank','Complete: "Objeción ____" (sustained)','aceptada',array['rechazada','negada','vetada'],'sustained',3),
  (v_l6,'multiple_choice','What is "appeal"?','el recurso',array['el remate','el rescate','el rebote'],'appeal',4),
  (v_l6,'multiple_choice','What is "hearing"?','la audiencia',array['la audacia','la audición','la auditoría'],'hearing',5),
  (v_l7,'multiple_choice','What does "interponer" mean?','to file (a complaint)',array['to interrupt','to intercede','to invent'],'to file',1),
  (v_l7,'multiple_choice','What is "compensation"?','la indemnización',array['la identificación','la indemnidad','la indignación'],'compensation',2),
  (v_l7,'fill_blank','Complete: "En un ____ de quince días." (deadline)','plazo',array['plano','plato','plazo'],'deadline',3),
  (v_l7,'multiple_choice','What does "exigir" mean?','to demand',array['to exit','to exile','to exhale'],'to demand',4),
  (v_l7,'multiple_choice','What does "por la presente" mean?','by the present (letter)',array['for the present (now)','through the present','by this person'],'by the present (letter)',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','El tribunal dictará sentencia el próximo mes',array['Las probabilidades a nuestro favor','El juez es severo','El caso es complejo'],'The court will hand down a sentence next month',6),
  (v_l1,'listening','What did you hear?','Cuáles son las probabilidades a nuestro favor',array['El tribunal dictará sentencia','El juez decide hoy','La demanda fue desestimada'],'What are the odds in our favor',7),
  (v_l1,'speaking','Say this aloud: "El tribunal dictará sentencia."','El tribunal dictará sentencia',array[]::text[],'The court will hand down a sentence.',8),
  (v_l1,'speaking','Say this aloud: "Las probabilidades son buenas."','Las probabilidades son buenas',array[]::text[],'The odds are good.',9),
  (v_l2,'listening','What did you hear?','Solicito una condena de diez años de cárcel',array['Mi cliente es inocente','No hay pruebas suficientes','La multa es alta'],'I request a sentence of ten years in prison',6),
  (v_l2,'listening','What did you hear?','Mi cliente es inocente, no hay pruebas suficientes',array['Solicito una condena','La multa es elevada','El fraude es claro'],'My client is innocent, there is insufficient evidence',7),
  (v_l2,'speaking','Say this aloud: "Mi cliente es inocente."','Mi cliente es inocente',array[]::text[],'My client is innocent.',8),
  (v_l2,'speaking','Say this aloud: "No hay pruebas suficientes."','No hay pruebas suficientes',array[]::text[],'There''s insufficient evidence.',9),
  (v_l3,'listening','What did you hear?','La constitución ampara el derecho a la libertad de expresión',array['Vulnerar los derechos','Reclamar igualdad','Amparar la libertad'],'The constitution protects the right to freedom of expression',6),
  (v_l3,'listening','What did you hear?','el derecho a la libertad de expresión',array['el derecho a la igualdad','el derecho al voto','el derecho a la propiedad'],'the right to freedom of expression',7),
  (v_l3,'speaking','Say this aloud: "La constitución ampara este derecho."','La constitución ampara este derecho',array[]::text[],'The constitution protects this right.',8),
  (v_l3,'speaking','Say this aloud: "Nadie puede vulnerar la ley."','Nadie puede vulnerar la ley',array[]::text[],'No one can violate the law.',9),
  (v_l6,'listening','What did you hear?','Señoría, objeto a esa pregunta — es irrelevante',array['Objeción aceptada','La defensa puede continuar','El testigo declaró'],'Your Honor, I object to that question — it is irrelevant',6),
  (v_l6,'listening','What did you hear?','Objeción aceptada. La defensa puede continuar',array['Señoría, objeto','La pregunta es relevante','No más preguntas'],'Objection sustained. The defense may continue',7),
  (v_l6,'speaking','Say this aloud: "Señoría, objeto a esa pregunta."','Señoría, objeto a esa pregunta',array[]::text[],'Your Honor, I object to that question.',8),
  (v_l6,'speaking','Say this aloud: "Objeción aceptada."','Objeción aceptada',array[]::text[],'Objection sustained.',9),
  (v_l7,'listening','What did you hear?','Por la presente, interpongo una reclamación formal por incumplimiento de contrato',array['Exijo una indemnización','El plazo es de quince días','El contrato fue firmado'],'I file a formal claim for breach of contract',6),
  (v_l7,'listening','What did you hear?','Exijo una indemnización en un plazo de quince días',array['Por la presente, interpongo','El contrato es válido','La queja fue resuelta'],'I demand compensation within fifteen days',7),
  (v_l7,'speaking','Say this aloud: "Por la presente, interpongo una reclamación."','Por la presente, interpongo una reclamación',array[]::text[],'I hereby file a claim.',8),
  (v_l7,'speaking','Say this aloud: "Exijo una indemnización."','Exijo una indemnización',array[]::text[],'I demand compensation.',9);

  update public.lessons set type='conversation', title='Law & Justice — Conversation Practice',
    description='Lawyer-client consultation.',
    intro='Sr. García meets with his lawyer to discuss a case.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"García","spanish":"Mi vecino ha incumplido el contrato de alquiler. ¿Qué puedo hacer?","english":"My neighbor has breached the rental contract. What can I do?"},{"speaker":"Abogada","spanish":"Si hubiera firmado un contrato más detallado, ya tendríamos pruebas claras.","english":"If you had signed a more detailed contract, we would already have clear evidence."},{"speaker":"García","spanish":"¿Puedo interponer una demanda?","english":"Can I file a lawsuit?"},{"speaker":"Abogada","spanish":"Sí. La ley ampara su derecho a reclamar. Necesitaremos testigos.","english":"Yes. The law protects your right to claim. We''ll need witnesses."},{"speaker":"García","spanish":"¿Cuándo dictaría sentencia el tribunal?","english":"When would the court hand down a sentence?"},{"speaker":"Abogada","spanish":"Si todo va bien, en un plazo de seis meses.","english":"If all goes well, within six months."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','What did García''s neighbor do?','Breached the rental contract',array['Sold the property','Moved out','Died'],'incumplido el contrato',1),
  (v_l8,'multiple_choice','What would have helped?','A more detailed contract',array['A different judge','A different lawyer','A longer lease'],'un contrato más detallado',2),
  (v_l8,'multiple_choice','What does the law do?','Protects his right to claim',array['Forbids the lawsuit','Limits his options','Requires waiting'],'ampara su derecho a reclamar',3),
  (v_l8,'multiple_choice','What does he need?','Witnesses',array['Money','A new contract','Police reports'],'testigos',4),
  (v_l8,'fill_blank','Complete: "Si ____ firmado un contrato." (had — subj)','hubiera',array['había','habría','habrá'],'had (subj)',5),
  (v_l8,'multiple_choice','Estimated timeframe?','Within six months',array['Within one month','Within a year','Within two years'],'en un plazo de seis meses',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Law & Justice', 'Review test for the Law & Justice section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "verdict"?','el veredicto',array['la sentencia','la condena','la denuncia'],'verdict',1),
  (v_lesson_id,'multiple_choice','What does "dictar sentencia" mean?','to hand down a sentence',array['to dictate a letter','to dictate the rules','to dictate orders'],'dictar sentencia',2),
  (v_lesson_id,'multiple_choice','What is "scam"?','la estafa',array['el fraude','el robo','la falsificación'],'scam',3),
  (v_lesson_id,'multiple_choice','Third conditional structure?','si hubiera + habría',array['si tuviera + tendría','si fuera + sería','si pudiera + podría'],'past unreal',4),
  (v_lesson_id,'fill_blank','Complete: "El jurado declaró ____ acusado culpable." (the - personal a)','al',array['el','a','del'],'personal a',5),
  (v_lesson_id,'fill_blank','Complete: "____ la presente, interpongo." (By)','Por',array['Para','Con','Sin'],'by',6),
  (v_lesson_id,'listening','What did you hear?','Señoría, objeto a esa pregunta',array['El tribunal dictará sentencia','Objeción aceptada','La defensa continúa'],'Your Honor, I object to that question',7),
  (v_lesson_id,'listening','What did you hear?','Si hubiera firmado un contrato más detallado',array['No hay pruebas suficientes','La constitución ampara','El plazo es corto'],'If he had signed a more detailed contract',8),
  (v_lesson_id,'speaking','Say this aloud: "El tribunal dictará sentencia."','El tribunal dictará sentencia',array[]::text[],'The court will hand down a sentence.',9),
  (v_lesson_id,'speaking','Say this aloud: "Exijo una indemnización."','Exijo una indemnización',array[]::text[],'I demand compensation.',10);

  -- ===========================================================
  -- B2.10 HISTORY
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B2' and title = 'History';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='Historical eras: "la Antigüedad", "la Edad Media", "el Renacimiento", "la Edad Moderna", "la Edad Contemporánea". Each era has signature events.',
    vocab_items='[{"spanish":"la Antigüedad","english":"Antiquity"},{"spanish":"la Edad Media","english":"the Middle Ages"},{"spanish":"el Renacimiento","english":"the Renaissance"},{"spanish":"la Ilustración","english":"the Enlightenment"},{"spanish":"el imperio","english":"empire"},{"spanish":"el siglo","english":"century"},{"spanish":"la época","english":"era/epoch"},{"spanish":"la civilización","english":"civilization"},{"spanish":"el reino","english":"kingdom"},{"spanish":"la dinastía","english":"dynasty"}]'::jsonb,
    dialogue='[{"speaker":"Profesor","spanish":"La Edad Media duró aproximadamente mil años.","english":"The Middle Ages lasted approximately one thousand years."},{"speaker":"Estudiante","spanish":"¿Cuándo terminó exactamente?","english":"When exactly did it end?"}]'::jsonb,
    grammar_note='Spanish dates often use "del siglo X al siglo Y": "del siglo V al siglo XV" — Roman numerals are standard for centuries.'
  where id = v_l1;

  update public.lessons set
    intro='Wars and revolutions: history is shaped by conflict and rebellion. Master "la guerra", "la revolución", "la batalla".',
    vocab_items='[{"spanish":"la guerra","english":"war"},{"spanish":"la batalla","english":"battle"},{"spanish":"la revolución","english":"revolution"},{"spanish":"el conflicto","english":"conflict"},{"spanish":"la independencia","english":"independence"},{"spanish":"la conquista","english":"conquest"},{"spanish":"el ejército","english":"army"},{"spanish":"derrotar","english":"to defeat"},{"spanish":"vencer","english":"to overcome"},{"spanish":"rendirse","english":"to surrender"}]'::jsonb,
    dialogue='[{"speaker":"Historiador","spanish":"Si Napoleón no hubiera invadido Rusia, la historia europea habría sido distinta.","english":"If Napoleon hadn''t invaded Russia, European history would have been different."}]'::jsonb,
    grammar_note='Third conditional applied to history: "si no hubiera invadido, habría sido distinta". Essential for historical analysis and counterfactual reasoning.'
  where id = v_l2;

  update public.lessons set
    intro='Historical figures: kings, conquerors, revolutionaries. Spanish uses titles like "el rey", "el emperador", "el caudillo".',
    vocab_items='[{"spanish":"el rey","english":"king"},{"spanish":"la reina","english":"queen"},{"spanish":"el emperador","english":"emperor"},{"spanish":"el conquistador","english":"conqueror"},{"spanish":"el dictador","english":"dictator"},{"spanish":"el líder","english":"leader"},{"spanish":"el héroe","english":"hero"},{"spanish":"el traidor","english":"traitor"},{"spanish":"reinar","english":"to reign"},{"spanish":"gobernar","english":"to govern"}]'::jsonb,
    dialogue='[{"speaker":"Profesora","spanish":"Isabel I, conocida como la Católica, reinó junto a Fernando.","english":"Isabel I, known as the Catholic, reigned alongside Fernando."}]'::jsonb,
    grammar_note='"Conocido/a como..." = "known as...". Apposition for nicknames or titles: "Alejandro, conocido como Magno". The participle agrees with the noun.'
  where id = v_l3;

  update public.lessons set
    intro='Spanish colonial history: "el descubrimiento de América" in 1492 changed the world.',
    vocab_items='[{"spanish":"el descubrimiento","english":"discovery"},{"spanish":"la colonia","english":"colony"},{"spanish":"colonizar","english":"to colonize"},{"spanish":"la metrópoli","english":"metropolis (mother country)"},{"spanish":"los indígenas","english":"indigenous peoples"},{"spanish":"el mestizaje","english":"miscegenation"},{"spanish":"la corona","english":"the crown"},{"spanish":"el virrey","english":"viceroy"},{"spanish":"el galeón","english":"galleon"},{"spanish":"el oro","english":"gold"}]'::jsonb,
    dialogue='[{"speaker":"Profesor","spanish":"La llegada de Colón a América en 1492 marcó el inicio de una nueva era.","english":"The arrival of Columbus in America in 1492 marked the beginning of a new era."}]'::jsonb,
    grammar_note='Dates as ordinal phrases: "en mil cuatrocientos noventa y dos" or simply "en 1492". For centuries, "en el siglo XV" = "in the 15th century".'
  where id = v_l4;

  update public.lessons set
    intro='20th century: world wars, dictatorships, cold war, democracy. Spanish history includes the Civil War and Franco''s dictatorship.',
    vocab_items='[{"spanish":"la guerra mundial","english":"world war"},{"spanish":"la dictadura","english":"dictatorship"},{"spanish":"la democracia","english":"democracy"},{"spanish":"la transición","english":"transition"},{"spanish":"el régimen","english":"regime"},{"spanish":"el exilio","english":"exile"},{"spanish":"la represión","english":"repression"},{"spanish":"la guerra fría","english":"cold war"},{"spanish":"el muro","english":"wall"},{"spanish":"el bloque","english":"bloc"}]'::jsonb,
    dialogue='[{"speaker":"Historiador","spanish":"La transición española es considerada un modelo de paso pacífico a la democracia.","english":"The Spanish transition is considered a model of peaceful transition to democracy."}]'::jsonb,
    grammar_note='"Ser considerado/a + noun/adjective" = "to be considered...". Passive structure common in academic history: "es considerada un modelo".'
  where id = v_l5;

  update public.lessons set
    intro='Listen to a history documentary narration. The narrator''s voice is formal and uses preterit + imperfect deliberately.',
    vocab_items='[{"spanish":"el documental","english":"documentary"},{"spanish":"narrar","english":"to narrate"},{"spanish":"el testimonio","english":"testimony"},{"spanish":"el archivo","english":"archive"},{"spanish":"el legado","english":"legacy"},{"spanish":"perdurar","english":"to endure"},{"spanish":"transcurrir","english":"to pass (time)"}]'::jsonb,
    dialogue='[{"speaker":"Narrador","spanish":"Mientras la peste asolaba Europa, Asia transcurría una era de relativa estabilidad.","english":"While the plague devastated Europe, Asia was passing through an era of relative stability."},{"speaker":"Narrador","spanish":"El legado de aquella época perdura hasta hoy.","english":"The legacy of that era endures to this day."}]'::jsonb,
    grammar_note='"Mientras + imperfect" sets parallel actions: "mientras la peste asolaba... Asia transcurría". Sustained narrative use of the imperfect.'
  where id = v_l6;

  update public.lessons set
    intro='Write a historical essay paragraph. Structure: thesis, evidence, analysis. Use connectors like "asimismo", "por consiguiente".',
    vocab_items='[{"spanish":"el ensayo","english":"essay"},{"spanish":"asimismo","english":"likewise"},{"spanish":"por consiguiente","english":"consequently"},{"spanish":"en cambio","english":"on the other hand"},{"spanish":"a diferencia de","english":"unlike"},{"spanish":"a pesar de","english":"despite"},{"spanish":"a raíz de","english":"as a result of"}]'::jsonb,
    dialogue='[{"speaker":"Ensayo","spanish":"La Revolución Francesa transformó Europa. Asimismo, sus ideas inspiraron movimientos independentistas en América.","english":"The French Revolution transformed Europe. Likewise, its ideas inspired independence movements in America."},{"speaker":"Ensayo","spanish":"A raíz de aquellos acontecimientos, el mapa político cambió radicalmente.","english":"As a result of those events, the political map changed radically."}]'::jsonb,
    grammar_note='"A raíz de + noun" = "as a result of...". Causal connector specific to literary/academic style. Stronger and more elegant than "debido a".'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "the Middle Ages"?','la Edad Media',array['la Antigüedad','la Edad Moderna','la Ilustración'],'Middle Ages',1),
  (v_l1,'multiple_choice','What is "century"?','el siglo',array['el sigilo','el silbo','el sino'],'century',2),
  (v_l1,'fill_blank','Complete: "Del siglo V ____ siglo XV." (to the)','al',array['el','a','de'],'to the',3),
  (v_l1,'multiple_choice','What is "kingdom"?','el reino',array['el reinado','el rey','el rumbo'],'kingdom',4),
  (v_l1,'multiple_choice','What is "dynasty"?','la dinastía',array['la diadema','la diáfana','la disnea'],'dynasty',5),
  (v_l2,'multiple_choice','What is "battle"?','la batalla',array['la guerra','el combate','el conflicto'],'battle',1),
  (v_l2,'multiple_choice','What does "derrotar" mean?','to defeat',array['to derail','to derive','to deride'],'to defeat',2),
  (v_l2,'fill_blank','Complete: "Si no ____ invadido Rusia." (had — subj)','hubiera',array['había','habría','hubo'],'had (subj)',3),
  (v_l2,'multiple_choice','What does "rendirse" mean?','to surrender',array['to render','to repeat','to revere'],'to surrender',4),
  (v_l2,'multiple_choice','What is "army"?','el ejército',array['la armada','la milicia','el escuadrón'],'army',5),
  (v_l3,'multiple_choice','What is "queen"?','la reina',array['la rana','la rama','la riña'],'queen',1),
  (v_l3,'multiple_choice','What does "reinar" mean?','to reign',array['to refrain','to remain','to retain'],'to reign',2),
  (v_l3,'fill_blank','Complete: "Isabel I, ____ como la Católica." (known)','conocida',array['conocido','conocer','conozco'],'known (fem)',3),
  (v_l3,'multiple_choice','What is "traitor"?','el traidor',array['el héroe','el tirano','el tutor'],'traitor',4),
  (v_l3,'multiple_choice','What does "gobernar" mean?','to govern',array['to gobble','to gather','to gain'],'to govern',5),
  (v_l4,'multiple_choice','What is "viceroy"?','el virrey',array['el rey','el virgen','el viraje'],'viceroy',1),
  (v_l4,'multiple_choice','What is "colony"?','la colonia',array['la corona','la columna','la cortina'],'colony',2),
  (v_l4,'fill_blank','Complete: "En ____ siglo XV." (the)','el',array['el','la','del'],'the',3),
  (v_l4,'multiple_choice','What does "mestizaje" refer to?','miscegenation',array['mastery','message','meeting'],'miscegenation',4),
  (v_l4,'multiple_choice','What is "gold"?','el oro',array['el ora','el aro','el orto'],'gold',5),
  (v_l5,'multiple_choice','What is "dictatorship"?','la dictadura',array['la dirección','la disciplina','la dictador'],'dictatorship',1),
  (v_l5,'multiple_choice','What is "exile"?','el exilio',array['el éxito','el exceso','el exilo'],'exile',2),
  (v_l5,'fill_blank','Complete: "La transición es ____ un modelo." (considered)','considerada',array['considerado','considera','considerar'],'considered (fem)',3),
  (v_l5,'multiple_choice','What is "wall"?','el muro',array['el moro','el muerto','el muelle'],'wall',4),
  (v_l5,'multiple_choice','What does "bloque" mean here?','political bloc',array['block (concrete)','block (street)','block (computer)'],'bloc',5),
  (v_l6,'multiple_choice','What does "perdurar" mean?','to endure',array['to perdure','to perform','to perish'],'to endure',1),
  (v_l6,'multiple_choice','What does "transcurrir" mean?','to pass (time)',array['to transmit','to transform','to translate'],'to pass (time)',2),
  (v_l6,'fill_blank','Complete: "____ la peste asolaba Europa." (While)','Mientras',array['Mientras','Aunque','Cuando'],'while',3),
  (v_l6,'multiple_choice','What is "legacy"?','el legado',array['el lago','el legal','el ligado'],'legacy',4),
  (v_l6,'multiple_choice','What is "archive"?','el archivo',array['el arcaico','el armario','el arpón'],'archive',5),
  (v_l7,'multiple_choice','What does "asimismo" mean?','likewise',array['anyway','always','already'],'likewise',1),
  (v_l7,'multiple_choice','What does "a raíz de" mean?','as a result of',array['at the root of','at the heart of','at the edge of'],'as a result of',2),
  (v_l7,'fill_blank','Complete: "Por ____, el mapa cambió." (consequently)','consiguiente',array['conviniente','contiguo','consecuente'],'consequently',3),
  (v_l7,'multiple_choice','What does "a diferencia de" mean?','unlike',array['a difference of','at the difference','about the difference'],'unlike',4),
  (v_l7,'multiple_choice','What is "essay"?','el ensayo',array['el examen','el estudio','el escrito'],'essay',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','La Edad Media duró aproximadamente mil años',array['La Antigüedad terminó','El Renacimiento comenzó','La Ilustración llegó'],'The Middle Ages lasted approximately one thousand years',6),
  (v_l1,'listening','What did you hear?','Cuándo terminó exactamente',array['La Edad Media duró','El siglo XV fue clave','La dinastía cayó'],'When exactly did it end',7),
  (v_l1,'speaking','Say this aloud: "Del siglo V al siglo XV."','Del siglo V al siglo XV',array[]::text[],'From the 5th to the 15th century.',8),
  (v_l1,'speaking','Say this aloud: "La Edad Media duró mil años."','La Edad Media duró mil años',array[]::text[],'The Middle Ages lasted one thousand years.',9),
  (v_l2,'listening','What did you hear?','Si Napoleón no hubiera invadido Rusia, la historia europea habría sido distinta',array['La batalla fue decisiva','El ejército se rindió','La conquista fracasó'],'If Napoleon hadn''t invaded Russia, European history would have been different',6),
  (v_l2,'listening','What did you hear?','la historia europea habría sido distinta',array['la historia americana cambió','la historia mundial siguió','la historia china continuó'],'European history would have been different',7),
  (v_l2,'speaking','Say this aloud: "Si no hubiera invadido, la historia sería distinta."','Si no hubiera invadido, la historia sería distinta',array[]::text[],'If he hadn''t invaded, history would be different.',8),
  (v_l2,'speaking','Say this aloud: "El ejército se rindió."','El ejército se rindió',array[]::text[],'The army surrendered.',9),
  (v_l3,'listening','What did you hear?','Isabel I, conocida como la Católica, reinó junto a Fernando',array['Carlos V reinó después','Felipe II expandió el imperio','Alfonso X era el Sabio'],'Isabel I, known as the Catholic, reigned alongside Fernando',6),
  (v_l3,'listening','What did you hear?','conocida como la Católica',array['conocido como el Sabio','llamada la Loca','reconocida la Grande'],'known as the Catholic',7),
  (v_l3,'speaking','Say this aloud: "Isabel I reinó junto a Fernando."','Isabel I reinó junto a Fernando',array[]::text[],'Isabel I reigned alongside Fernando.',8),
  (v_l3,'speaking','Say this aloud: "Conocida como la Católica."','Conocida como la Católica',array[]::text[],'Known as the Catholic.',9),
  (v_l6,'listening','What did you hear?','Mientras la peste asolaba Europa, Asia transcurría una era de relativa estabilidad',array['El legado de aquella época','El descubrimiento de América','La revolución industrial'],'While the plague devastated Europe, Asia was passing through an era of stability',6),
  (v_l6,'listening','What did you hear?','El legado de aquella época perdura hasta hoy',array['Mientras la peste asolaba','La estabilidad fue relativa','El documental concluyó'],'The legacy of that era endures to this day',7),
  (v_l6,'speaking','Say this aloud: "El legado perdura hasta hoy."','El legado perdura hasta hoy',array[]::text[],'The legacy endures to this day.',8),
  (v_l6,'speaking','Say this aloud: "Mientras tanto, en Asia, transcurría la paz."','Mientras tanto, en Asia, transcurría la paz',array[]::text[],'Meanwhile, in Asia, peace was passing.',9),
  (v_l7,'listening','What did you hear?','La Revolución Francesa transformó Europa',array['Asimismo, sus ideas inspiraron','A raíz de aquellos acontecimientos','El mapa político cambió'],'The French Revolution transformed Europe',6),
  (v_l7,'listening','What did you hear?','A raíz de aquellos acontecimientos, el mapa político cambió radicalmente',array['La Revolución Francesa transformó','Asimismo, sus ideas','Por consiguiente, todo cambió'],'As a result of those events, the political map changed radically',7),
  (v_l7,'speaking','Say this aloud: "A raíz de aquellos acontecimientos."','A raíz de aquellos acontecimientos',array[]::text[],'As a result of those events.',8),
  (v_l7,'speaking','Say this aloud: "Asimismo, inspiró otros movimientos."','Asimismo, inspiró otros movimientos',array[]::text[],'Likewise, it inspired other movements.',9);

  update public.lessons set type='conversation', title='History — Conversation Practice',
    description='Two students discuss a history exam.',
    intro='Marta and Lucía review for their finals.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Marta","spanish":"¿Has estudiado la Transición española?","english":"Have you studied the Spanish Transition?"},{"speaker":"Lucía","spanish":"Sí. Es considerada un modelo de paso pacífico a la democracia.","english":"Yes. It''s considered a model of peaceful transition to democracy."},{"speaker":"Marta","spanish":"Si Franco no hubiera muerto en 1975, ¿habría sido distinto?","english":"If Franco hadn''t died in 1975, would it have been different?"},{"speaker":"Lucía","spanish":"Sin duda. A raíz de su muerte, comenzó todo el proceso.","english":"Without doubt. As a result of his death, the whole process began."},{"speaker":"Marta","spanish":"Asimismo, la Constitución del 78 fue clave.","english":"Likewise, the 1978 Constitution was key."},{"speaker":"Lucía","spanish":"Por consiguiente, hoy somos una democracia consolidada.","english":"Consequently, today we are a consolidated democracy."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','What is the Transición considered?','A model of peaceful transition to democracy',array['A failed experiment','A military coup','A continuation of Franco'],'modelo de paso pacífico',1),
  (v_l8,'multiple_choice','What if Franco hadn''t died in 1975?','It would have been different',array['Nothing would change','It''d be the same','Spain would still be a dictatorship'],'habría sido distinto',2),
  (v_l8,'multiple_choice','What triggered the process?','Franco''s death',array['The 1936 war','The 1978 constitution','EU membership'],'a raíz de su muerte',3),
  (v_l8,'multiple_choice','What was key besides Franco''s death?','The 1978 Constitution',array['NATO membership','The Olympics','The EU'],'la Constitución del 78',4),
  (v_l8,'fill_blank','Complete: "A ____ de su muerte." (As a result)','raíz',array['causa','pesar','través'],'as a result',5),
  (v_l8,'multiple_choice','Today''s political reality?','Consolidated democracy',array['Failing state','Dictatorship','Monarchy only'],'democracia consolidada',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: History', 'Review test for the History section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "the Middle Ages"?','la Edad Media',array['la Antigüedad','el Renacimiento','la Ilustración'],'Middle Ages',1),
  (v_lesson_id,'multiple_choice','Third conditional structure?','si hubiera + habría',array['si tuviera + tendría','si fuera + sería','si pudiera + podría'],'past unreal',2),
  (v_lesson_id,'multiple_choice','What is "dictatorship"?','la dictadura',array['la democracia','la dirección','la disciplina'],'dictatorship',3),
  (v_lesson_id,'multiple_choice','What does "a raíz de" mean?','as a result of',array['at the root of','at the heart of','at the edge of'],'as a result of',4),
  (v_lesson_id,'fill_blank','Complete: "Si Napoleón no ____ invadido Rusia." (had — subj)','hubiera',array['había','habría','hubo'],'had (subj)',5),
  (v_lesson_id,'fill_blank','Complete: "____ la peste asolaba Europa." (While)','Mientras',array['Cuando','Aunque','Donde'],'while',6),
  (v_lesson_id,'listening','What did you hear?','El legado de aquella época perdura hasta hoy',array['Mientras la peste asolaba','A raíz de su muerte','Asimismo, las ideas inspiraron'],'The legacy of that era endures to this day',7),
  (v_lesson_id,'listening','What did you hear?','Es considerada un modelo de paso pacífico a la democracia',array['La transición fue corta','Franco murió en 1975','El mapa cambió'],'It''s considered a model of peaceful transition to democracy',8),
  (v_lesson_id,'speaking','Say this aloud: "La transición es un modelo."','La transición es un modelo',array[]::text[],'The transition is a model.',9),
  (v_lesson_id,'speaking','Say this aloud: "Si Franco no hubiera muerto."','Si Franco no hubiera muerto',array[]::text[],'If Franco hadn''t died.',10);

  -- ===========================================================
  -- B2.11 PSYCHOLOGY
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B2' and title = 'Psychology';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='Emotions vocabulary at B2 nuance: "la ansiedad", "el estrés", "la culpa", "la vergüenza". Spanish allows complex emotional descriptions.',
    vocab_items='[{"spanish":"la emoción","english":"emotion"},{"spanish":"el sentimiento","english":"feeling"},{"spanish":"la ansiedad","english":"anxiety"},{"spanish":"el estrés","english":"stress"},{"spanish":"la culpa","english":"guilt"},{"spanish":"la vergüenza","english":"shame"},{"spanish":"el orgullo","english":"pride"},{"spanish":"la angustia","english":"anguish"},{"spanish":"la alegría","english":"joy"},{"spanish":"la tristeza","english":"sadness"}]'::jsonb,
    dialogue='[{"speaker":"Paciente","spanish":"Me da vergüenza pedir ayuda.","english":"It embarrasses me to ask for help."},{"speaker":"Terapeuta","spanish":"Es natural. Reconocer la vulnerabilidad requiere mucho coraje.","english":"That''s natural. Acknowledging vulnerability requires a lot of courage."}]'::jsonb,
    grammar_note='"Me da + emotion + infinitive" = "It gives me + emotion to + verb": "me da vergüenza pedir", "me da rabia esperar". A common structure for emotional reactions.'
  where id = v_l1;

  update public.lessons set
    intro='Mental health terminology: depression, anxiety, therapy. Spanish has direct cognates but also unique terms.',
    vocab_items='[{"spanish":"la salud mental","english":"mental health"},{"spanish":"la depresión","english":"depression"},{"spanish":"el trastorno","english":"disorder"},{"spanish":"la terapia","english":"therapy"},{"spanish":"el psicólogo","english":"psychologist"},{"spanish":"el psiquiatra","english":"psychiatrist"},{"spanish":"el diagnóstico","english":"diagnosis"},{"spanish":"el tratamiento","english":"treatment"},{"spanish":"la consulta","english":"consultation"},{"spanish":"el bienestar","english":"well-being"}]'::jsonb,
    dialogue='[{"speaker":"Paciente","spanish":"Quisiera que mi terapeuta me ayudara a entenderme mejor.","english":"I would like my therapist to help me understand myself better."}]'::jsonb,
    grammar_note='"Quisiera que + imperfect subjunctive" = polite "I would like + clause". The imperfect subjunctive softens the request: "quisiera que me ayudara".'
  where id = v_l2;

  update public.lessons set
    intro='Cognition and the mind: memory, attention, learning. Spanish "la mente" vs "el cerebro" (mind vs brain).',
    vocab_items='[{"spanish":"la mente","english":"mind"},{"spanish":"el cerebro","english":"brain"},{"spanish":"la memoria","english":"memory"},{"spanish":"la atención","english":"attention"},{"spanish":"el aprendizaje","english":"learning"},{"spanish":"el comportamiento","english":"behavior"},{"spanish":"la conducta","english":"conduct"},{"spanish":"el hábito","english":"habit"},{"spanish":"consciente","english":"conscious"},{"spanish":"inconsciente","english":"unconscious"}]'::jsonb,
    dialogue='[{"speaker":"Investigadora","spanish":"Lo más interesante es cómo la mente procesa la información de forma inconsciente.","english":"What''s most interesting is how the mind processes information unconsciously."}]'::jsonb,
    grammar_note='"Lo + adjective + es...": "lo más interesante es...", "lo curioso es...". This neuter construction turns adjectives into abstract subjects.'
  where id = v_l3;

  update public.lessons set
    intro='Personality and traits: Spanish "la personalidad" describes the broad construct. Specific traits: "extrovertido", "introvertido", "empático".',
    vocab_items='[{"spanish":"la personalidad","english":"personality"},{"spanish":"el carácter","english":"character"},{"spanish":"el rasgo","english":"trait"},{"spanish":"extrovertido","english":"extroverted"},{"spanish":"introvertido","english":"introverted"},{"spanish":"empático","english":"empathetic"},{"spanish":"asertivo","english":"assertive"},{"spanish":"impulsivo","english":"impulsive"},{"spanish":"perfeccionista","english":"perfectionist"},{"spanish":"resiliente","english":"resilient"}]'::jsonb,
    dialogue='[{"speaker":"Psicóloga","spanish":"Las personas resilientes superan adversidades sin que ello les afecte profundamente.","english":"Resilient people overcome adversity without it affecting them deeply."}]'::jsonb,
    grammar_note='"Sin que + subjunctive" = "without (something happening)": "sin que les afecte". Always subjunctive after "sin que".'
  where id = v_l4;

  update public.lessons set
    intro='Therapy techniques: cognitive behavioral therapy, mindfulness, exposure. Many Spanish terms are anglicisms or direct translations.',
    vocab_items='[{"spanish":"la terapia cognitivo-conductual","english":"cognitive behavioral therapy"},{"spanish":"la atención plena","english":"mindfulness"},{"spanish":"la meditación","english":"meditation"},{"spanish":"el autocuidado","english":"self-care"},{"spanish":"el patrón","english":"pattern"},{"spanish":"identificar","english":"to identify"},{"spanish":"gestionar","english":"to manage"},{"spanish":"afrontar","english":"to face"},{"spanish":"la estrategia","english":"strategy"},{"spanish":"el progreso","english":"progress"}]'::jsonb,
    dialogue='[{"speaker":"Terapeuta","spanish":"Lo importante es identificar los patrones negativos para poder gestionarlos.","english":"What''s important is to identify the negative patterns in order to manage them."}]'::jsonb,
    grammar_note='"Para poder + infinitive" = "to be able to + verb". Adds "the ability to" to a purpose clause: "para gestionar" → "para poder gestionar".'
  where id = v_l5;

  update public.lessons set
    intro='Listen to a therapy session excerpt. The therapist uses gentle questions and reflective listening.',
    vocab_items='[{"spanish":"el sesión","english":"session"},{"spanish":"escuchar","english":"to listen"},{"spanish":"reflexionar","english":"to reflect"},{"spanish":"validar","english":"to validate"},{"spanish":"sentirse","english":"to feel"},{"spanish":"compartir","english":"to share"}]'::jsonb,
    dialogue='[{"speaker":"Terapeuta","spanish":"Cuando dices que te sientes vacía, ¿qué crees que la causa?","english":"When you say you feel empty, what do you think causes it?"},{"speaker":"Paciente","spanish":"No lo sé. Me preocupa que sea algo más profundo.","english":"I don''t know. It worries me that it might be something deeper."}]'::jsonb,
    grammar_note='"Me preocupa que + subjunctive" = "It worries me that...". After expressions of emotion ("me preocupa", "me alegra", "me sorprende"), always subjunctive.'
  where id = v_l6;

  update public.lessons set
    intro='Write a reflection on emotional growth. Use first person, introspective tone.',
    vocab_items='[{"spanish":"el crecimiento personal","english":"personal growth"},{"spanish":"el autoconocimiento","english":"self-knowledge"},{"spanish":"reconocer","english":"to recognize"},{"spanish":"superar","english":"to overcome"},{"spanish":"transformar","english":"to transform"},{"spanish":"la madurez","english":"maturity"},{"spanish":"madurar","english":"to mature"},{"spanish":"aceptarse","english":"to accept oneself"}]'::jsonb,
    dialogue='[{"speaker":"Diario","spanish":"He aprendido que aceptarse a uno mismo es el primer paso para crecer.","english":"I''ve learned that accepting oneself is the first step to grow."},{"speaker":"Diario","spanish":"Si me hubiera escuchado antes, habría sufrido menos.","english":"If I had listened to myself sooner, I would have suffered less."}]'::jsonb,
    grammar_note='"Uno mismo" = "oneself" — reflexive reference distinct from "se". Used after prepositions: "a uno mismo", "de uno mismo", "para uno mismo".'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "anxiety"?','la ansiedad',array['la angustia','la alegría','la apatía'],'anxiety',1),
  (v_l1,'multiple_choice','What is "shame"?','la vergüenza',array['la culpa','la tristeza','el miedo'],'shame',2),
  (v_l1,'fill_blank','Complete: "Me ____ vergüenza pedir ayuda." (gives)','da',array['dar','daba','dará'],'gives',3),
  (v_l1,'multiple_choice','What is "pride"?','el orgullo',array['la alegría','el ánimo','el orquídeo'],'pride',4),
  (v_l1,'multiple_choice','What does "coraje" mean?','courage',array['cordial','correct','corner'],'courage',5),
  (v_l2,'multiple_choice','What is "disorder"?','el trastorno',array['el traspaso','el trapiche','el tránsito'],'disorder',1),
  (v_l2,'multiple_choice','What is "diagnosis"?','el diagnóstico',array['el diagrama','la diagonal','la dieta'],'diagnosis',2),
  (v_l2,'fill_blank','Complete: "Quisiera que me ____ mejor." (helped — subj)','ayudara',array['ayudaría','ayudaba','ayuda'],'helped (subj)',3),
  (v_l2,'multiple_choice','What is "well-being"?','el bienestar',array['el bienvenido','el bien hablado','el bien'],'well-being',4),
  (v_l2,'multiple_choice','What does "psiquiatra" specialize in?','medical mental health (MD)',array['talk therapy only','child play only','dream analysis only'],'psychiatrist',5),
  (v_l3,'multiple_choice','What is "habit"?','el hábito',array['el habla','el hábitat','el habitante'],'habit',1),
  (v_l3,'multiple_choice','What does "lo más interesante" mean?','what''s most interesting',array['the most interesting one (man)','the most interesting (thing — concrete)','more interesting'],'what''s most interesting',2),
  (v_l3,'fill_blank','Complete: "____ más interesante es..." (What''s)','Lo',array['El','La','Le'],'what''s',3),
  (v_l3,'multiple_choice','What is "behavior"?','el comportamiento',array['el complemento','el comportón','el compromiso'],'behavior',4),
  (v_l3,'multiple_choice','What is "learning"?','el aprendizaje',array['el aprendiz','la aprehensión','la aprobación'],'learning',5),
  (v_l4,'multiple_choice','What does "resiliente" mean?','resilient',array['restless','resilient (incorrect)','reliable'],'resilient',1),
  (v_l4,'multiple_choice','What does "sin que" require?','subjunctive',array['indicative','infinitive','conditional'],'sin que + subj',2),
  (v_l4,'fill_blank','Complete: "Sin que ____ profundamente." (affects — subj)','afecte',array['afecta','afectó','afectaría'],'affects (subj)',3),
  (v_l4,'multiple_choice','What is "trait"?','el rasgo',array['el rango','el ramo','el raso'],'trait',4),
  (v_l4,'multiple_choice','What does "empático" mean?','empathetic',array['empiric','emphatic','empty'],'empathetic',5),
  (v_l5,'multiple_choice','What is "mindfulness"?','la atención plena',array['la atención completa','la plenitud atenta','la atención profunda'],'mindfulness',1),
  (v_l5,'multiple_choice','What does "gestionar" mean?','to manage',array['to gesture','to gestate','to germinate'],'to manage',2),
  (v_l5,'fill_blank','Complete: "Para ____ gestionarlos." (be able to)','poder',array['puedes','pude','podido'],'be able to',3),
  (v_l5,'multiple_choice','What is "pattern"?','el patrón',array['el patriota','el padrino','el padre'],'pattern',4),
  (v_l5,'multiple_choice','What does "afrontar" mean?','to face',array['to affront','to affront (insult)','to afford'],'to face',5),
  (v_l6,'multiple_choice','What follows "me preocupa que"?','subjunctive',array['indicative','infinitive','conditional'],'me preocupa que + subj',1),
  (v_l6,'multiple_choice','What is "session"?','la sesión',array['la session','el sesión','la cesión'],'session',2),
  (v_l6,'fill_blank','Complete: "Me preocupa que ____ algo más profundo." (might be — subj)','sea',array['es','era','será'],'might be (subj)',3),
  (v_l6,'multiple_choice','What does "reflexionar" mean?','to reflect',array['to refresh','to refuse','to refuel'],'to reflect',4),
  (v_l6,'multiple_choice','What does "validar" mean here?','to validate (feelings)',array['to verify (a ticket)','to evaluate','to vacate'],'to validate',5),
  (v_l7,'multiple_choice','What is "self-knowledge"?','el autoconocimiento',array['el autorespeto','el autocontrol','el autismo'],'self-knowledge',1),
  (v_l7,'multiple_choice','What does "aceptarse" mean?','to accept oneself',array['to accept others','to be accepted','to accept fate'],'to accept oneself',2),
  (v_l7,'fill_blank','Complete: "Aceptarse a uno ____" (oneself)','mismo',array['mismos','solo','propio'],'oneself',3),
  (v_l7,'multiple_choice','What is "maturity"?','la madurez',array['la modestia','la moderación','la madeja'],'maturity',4),
  (v_l7,'multiple_choice','What does "superar" mean?','to overcome',array['to supervise','to surpass (only)','to suppress'],'to overcome',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Me da vergüenza pedir ayuda',array['Es natural','Reconocer la vulnerabilidad','Mucho coraje'],'It embarrasses me to ask for help',6),
  (v_l1,'listening','What did you hear?','Reconocer la vulnerabilidad requiere mucho coraje',array['Me da vergüenza','Es natural sentirlo','Es difícil pedir'],'Acknowledging vulnerability requires a lot of courage',7),
  (v_l1,'speaking','Say this aloud: "Me da vergüenza pedir ayuda."','Me da vergüenza pedir ayuda',array[]::text[],'It embarrasses me to ask for help.',8),
  (v_l1,'speaking','Say this aloud: "Reconocer la vulnerabilidad requiere coraje."','Reconocer la vulnerabilidad requiere coraje',array[]::text[],'Acknowledging vulnerability requires courage.',9),
  (v_l2,'listening','What did you hear?','Quisiera que mi terapeuta me ayudara a entenderme mejor',array['Necesito un diagnóstico','El tratamiento es largo','El bienestar mejora'],'I would like my therapist to help me understand myself better',6),
  (v_l2,'listening','What did you hear?','a entenderme mejor',array['a sentirme mejor','a conocerme mejor','a sanarme rápido'],'to understand myself better',7),
  (v_l2,'speaking','Say this aloud: "Quisiera que me ayudara más."','Quisiera que me ayudara más',array[]::text[],'I would like him/her to help me more.',8),
  (v_l2,'speaking','Say this aloud: "Necesito una consulta."','Necesito una consulta',array[]::text[],'I need a consultation.',9),
  (v_l3,'listening','What did you hear?','Lo más interesante es cómo la mente procesa la información de forma inconsciente',array['El cerebro es complejo','La memoria falla','La atención se pierde'],'What''s most interesting is how the mind processes information unconsciously',6),
  (v_l3,'listening','What did you hear?','de forma inconsciente',array['de forma consciente','de manera lenta','de modo rápido'],'unconsciously',7),
  (v_l3,'speaking','Say this aloud: "Lo más interesante es esto."','Lo más interesante es esto',array[]::text[],'What''s most interesting is this.',8),
  (v_l3,'speaking','Say this aloud: "La mente procesa información."','La mente procesa información',array[]::text[],'The mind processes information.',9),
  (v_l6,'listening','What did you hear?','Cuando dices que te sientes vacía, qué crees que la causa',array['Me preocupa que sea profundo','Necesito reflexionar más','No lo sé del todo'],'When you say you feel empty, what do you think causes it',6),
  (v_l6,'listening','What did you hear?','Me preocupa que sea algo más profundo',array['Cuando dices que te sientes','Necesito un diagnóstico','La sesión es larga'],'It worries me that it might be something deeper',7),
  (v_l6,'speaking','Say this aloud: "Me preocupa que sea algo más profundo."','Me preocupa que sea algo más profundo',array[]::text[],'It worries me that it might be something deeper.',8),
  (v_l6,'speaking','Say this aloud: "Me siento vacía."','Me siento vacía',array[]::text[],'I feel empty.',9),
  (v_l7,'listening','What did you hear?','He aprendido que aceptarse a uno mismo es el primer paso para crecer',array['Si me hubiera escuchado antes','Habría sufrido menos','El crecimiento es lento'],'I''ve learned that accepting oneself is the first step to grow',6),
  (v_l7,'listening','What did you hear?','Si me hubiera escuchado antes, habría sufrido menos',array['He aprendido a aceptarme','Aceptarse es el primer paso','Crecer requiere tiempo'],'If I had listened to myself sooner, I would have suffered less',7),
  (v_l7,'speaking','Say this aloud: "Aceptarse a uno mismo es el primer paso."','Aceptarse a uno mismo es el primer paso',array[]::text[],'Accepting oneself is the first step.',8),
  (v_l7,'speaking','Say this aloud: "Si me hubiera escuchado antes."','Si me hubiera escuchado antes',array[]::text[],'If I had listened to myself sooner.',9);

  update public.lessons set type='conversation', title='Psychology — Conversation Practice',
    description='A therapy session in progress.',
    intro='Sara meets with her therapist Dr. López.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Sara","spanish":"Esta semana me ha dado mucha ansiedad volver al trabajo.","english":"This week, going back to work has given me a lot of anxiety."},{"speaker":"López","spanish":"Lo más importante es identificar qué patrones te lo provocan.","english":"What''s most important is to identify which patterns trigger it."},{"speaker":"Sara","spanish":"Me preocupa que no pueda gestionar el estrés sola.","english":"It worries me that I can''t manage the stress alone."},{"speaker":"López","spanish":"No estás sola. Si hubieras pedido ayuda antes, habríamos avanzado más.","english":"You''re not alone. If you had asked for help sooner, we would have made more progress."},{"speaker":"Sara","spanish":"Me da vergüenza reconocer mis límites.","english":"It embarrasses me to acknowledge my limits."},{"speaker":"López","spanish":"Reconocerlos es un signo de madurez, no de debilidad.","english":"Recognizing them is a sign of maturity, not weakness."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','What gives Sara anxiety?','Going back to work',array['Leaving work','Therapy itself','Her family'],'volver al trabajo',1),
  (v_l8,'multiple_choice','What does López prioritize?','Identifying triggering patterns',array['Prescribing medication','Avoidance','Ignoring symptoms'],'identificar qué patrones',2),
  (v_l8,'multiple_choice','Sara''s worry?','She can''t manage stress alone',array['She''s being judged','Therapy is failing','She''s incurable'],'no pueda gestionar el estrés sola',3),
  (v_l8,'multiple_choice','López''s response (counterfactual)?','If she had asked sooner, they''d have progressed more',array['Nothing could have helped','She should give up','It''s her fault'],'si hubieras pedido ayuda antes',4),
  (v_l8,'fill_blank','Complete: "Me ____ vergüenza reconocer límites." (gives)','da',array['dar','daba','dará'],'gives',5),
  (v_l8,'multiple_choice','What does López say acknowledging limits is?','A sign of maturity',array['A weakness','A failure','A surrender'],'signo de madurez',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Psychology', 'Review test for the Psychology section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "anxiety"?','la ansiedad',array['la angustia','la apatía','la atención'],'anxiety',1),
  (v_lesson_id,'multiple_choice','What follows "me preocupa que"?','subjunctive',array['indicative','infinitive','imperative'],'me preocupa que + subj',2),
  (v_lesson_id,'multiple_choice','What follows "sin que"?','subjunctive',array['indicative','infinitive','imperative'],'sin que + subj',3),
  (v_lesson_id,'multiple_choice','What is "mindfulness"?','la atención plena',array['la atención completa','la atención profunda','la atención total'],'mindfulness',4),
  (v_lesson_id,'fill_blank','Complete: "Quisiera que me ____ mejor." (helped — subj)','ayudara',array['ayudaría','ayuda','ayudaba'],'helped (subj)',5),
  (v_lesson_id,'fill_blank','Complete: "Lo ____ interesante es..." (most)','más',array['mucho','muy','tanto'],'most',6),
  (v_lesson_id,'listening','What did you hear?','Me preocupa que sea algo más profundo',array['Me da vergüenza','Lo más interesante es','Necesito reflexionar'],'It worries me that it might be something deeper',7),
  (v_lesson_id,'listening','What did you hear?','Aceptarse a uno mismo es el primer paso para crecer',array['Si me hubiera escuchado antes','He aprendido mucho','Crecer requiere tiempo'],'Accepting oneself is the first step to grow',8),
  (v_lesson_id,'speaking','Say this aloud: "Me da vergüenza pedir ayuda."','Me da vergüenza pedir ayuda',array[]::text[],'It embarrasses me to ask for help.',9),
  (v_lesson_id,'speaking','Say this aloud: "Lo más importante es identificar los patrones."','Lo más importante es identificar los patrones',array[]::text[],'What''s most important is identifying the patterns.',10);

  -- ===========================================================
  -- B2.12 ARCHITECTURE
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B2' and title = 'Architecture';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='Architectural elements: "la fachada", "la columna", "la cúpula". Spanish architecture has rich Moorish and Gothic traditions.',
    vocab_items='[{"spanish":"el edificio","english":"building"},{"spanish":"la fachada","english":"facade"},{"spanish":"la columna","english":"column"},{"spanish":"la cúpula","english":"dome"},{"spanish":"el arco","english":"arch"},{"spanish":"la bóveda","english":"vault"},{"spanish":"el techo","english":"ceiling/roof"},{"spanish":"el suelo","english":"floor"},{"spanish":"la pared","english":"wall"},{"spanish":"el ladrillo","english":"brick"}]'::jsonb,
    dialogue='[{"speaker":"Guía","spanish":"Esta cúpula barroca es la más alta de la ciudad.","english":"This baroque dome is the tallest in the city."}]'::jsonb,
    grammar_note='"La más + adjective + de + place" = "the most + adj + of + place". Superlative construction with "de" for the scope.'
  where id = v_l1;

  update public.lessons set
    intro='Architectural styles: "el románico", "el gótico", "el mudéjar", "el modernismo". Spain has examples of nearly every style.',
    vocab_items='[{"spanish":"el románico","english":"Romanesque"},{"spanish":"el gótico","english":"Gothic"},{"spanish":"el mudéjar","english":"Mudejar"},{"spanish":"el modernismo","english":"Art Nouveau (Modernismo)"},{"spanish":"el estilo","english":"style"},{"spanish":"el ornamento","english":"ornament"},{"spanish":"la simetría","english":"symmetry"},{"spanish":"la proporción","english":"proportion"},{"spanish":"el conjunto","english":"ensemble"},{"spanish":"la influencia","english":"influence"}]'::jsonb,
    dialogue='[{"speaker":"Profesora","spanish":"Gaudí, aunque trabajara dentro del modernismo, creó un estilo propio.","english":"Gaudí, although he worked within Modernismo, created his own style."}]'::jsonb,
    grammar_note='"Aunque + imperfect subjunctive" = "even though/although (it could be argued)". Adds nuance — suggests his style transcended the movement.'
  where id = v_l2;

  update public.lessons set
    intro='Famous Spanish architects: Gaudí, Calatrava, Moneo. Spain produces world-renowned designers.',
    vocab_items='[{"spanish":"el arquitecto","english":"architect"},{"spanish":"diseñar","english":"to design"},{"spanish":"el diseño","english":"design"},{"spanish":"el proyecto","english":"project"},{"spanish":"construir","english":"to build"},{"spanish":"la construcción","english":"construction"},{"spanish":"el plano","english":"floor plan"},{"spanish":"la maqueta","english":"model"},{"spanish":"la obra","english":"work (architecture)"},{"spanish":"el legado","english":"legacy"}]'::jsonb,
    dialogue='[{"speaker":"Crítica","spanish":"La Sagrada Familia, diseñada por Gaudí, sigue construyéndose más de un siglo después.","english":"The Sagrada Familia, designed by Gaudí, is still being built more than a century later."}]'::jsonb,
    grammar_note='"Seguir + gerund" = "to keep + verb-ing": "sigue construyéndose" = "keeps being built". Indicates continuous progressive action.'
  where id = v_l3;

  update public.lessons set
    intro='Urban planning: streets, squares, parks, neighborhoods. Spanish city centers feature "las plazas" prominently.',
    vocab_items='[{"spanish":"el urbanismo","english":"urban planning"},{"spanish":"la ciudad","english":"city"},{"spanish":"el barrio","english":"neighborhood"},{"spanish":"la plaza","english":"square"},{"spanish":"la calle","english":"street"},{"spanish":"la avenida","english":"avenue"},{"spanish":"el parque","english":"park"},{"spanish":"peatonal","english":"pedestrian"},{"spanish":"el centro histórico","english":"historic center"},{"spanish":"la zona","english":"zone"}]'::jsonb,
    dialogue='[{"speaker":"Urbanista","spanish":"Peatonalizar el centro mejoraría la calidad de vida de los residentes.","english":"Pedestrianizing the center would improve residents'' quality of life."}]'::jsonb,
    grammar_note='"Peatonalizar" exemplifies Spanish''s productive "-izar" suffix for forming verbs from nouns/adjectives: "modernizar", "industrializar", "globalizar".'
  where id = v_l4;

  update public.lessons set
    intro='Sustainability in architecture: green buildings, materials, energy efficiency.',
    vocab_items='[{"spanish":"sostenible","english":"sustainable"},{"spanish":"la sostenibilidad","english":"sustainability"},{"spanish":"la eficiencia energética","english":"energy efficiency"},{"spanish":"renovable","english":"renewable"},{"spanish":"el material","english":"material"},{"spanish":"la madera","english":"wood"},{"spanish":"el acero","english":"steel"},{"spanish":"el hormigón","english":"concrete"},{"spanish":"el vidrio","english":"glass"},{"spanish":"reciclar","english":"to recycle"}]'::jsonb,
    dialogue='[{"speaker":"Arquitecto","spanish":"Diseñamos para que el edificio consuma la menor energía posible.","english":"We design so that the building consumes the least energy possible."}]'::jsonb,
    grammar_note='"Para que + subjunctive" = "so that...". Purpose clause requiring subjunctive: "para que consuma" = "so that it consumes".'
  where id = v_l5;

  update public.lessons set
    intro='Listen to an architect describe a project. Note the technical vocabulary and visual descriptions.',
    vocab_items='[{"spanish":"el encargo","english":"commission"},{"spanish":"el cliente","english":"client"},{"spanish":"la propuesta","english":"proposal"},{"spanish":"el espacio","english":"space"},{"spanish":"la luz natural","english":"natural light"},{"spanish":"la ventilación","english":"ventilation"},{"spanish":"integrar","english":"to integrate"}]'::jsonb,
    dialogue='[{"speaker":"Arquitecto","spanish":"El cliente nos pidió un espacio que integrara luz natural y ventilación cruzada.","english":"The client asked us for a space that would integrate natural light and cross ventilation."},{"speaker":"Arquitecto","spanish":"Diseñamos una fachada acristalada orientada al sur.","english":"We designed a glazed facade facing south."}]'::jsonb,
    grammar_note='"Nos pidió que/un... que + subjunctive": "nos pidió un espacio que integrara". The relative clause uses subjunctive because the space is not yet specified/existing.'
  where id = v_l6;

  update public.lessons set
    intro='Write a description of an iconic building. Use vivid adjectives and structural details.',
    vocab_items='[{"spanish":"el monumento","english":"monument"},{"spanish":"emblemático","english":"emblematic"},{"spanish":"impresionante","english":"impressive"},{"spanish":"la altura","english":"height"},{"spanish":"el material","english":"material"},{"spanish":"reflejar","english":"to reflect"},{"spanish":"destacar","english":"to stand out"},{"spanish":"caracterizarse por","english":"to be characterized by"}]'::jsonb,
    dialogue='[{"speaker":"Descripción","spanish":"El Guggenheim de Bilbao, obra emblemática de Frank Gehry, se caracteriza por sus formas onduladas de titanio.","english":"The Guggenheim of Bilbao, an emblematic work of Frank Gehry, is characterized by its wavy titanium forms."},{"speaker":"Descripción","spanish":"Destaca por su impacto visual y por haber revitalizado toda una ciudad.","english":"It stands out for its visual impact and for having revitalized an entire city."}]'::jsonb,
    grammar_note='"Por haber + past participle" = "for having + V-ed". Replaces "porque + past tense" with a more elegant nominal structure: "por haber revitalizado".'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "dome"?','la cúpula',array['la columna','la bóveda','el arco'],'dome',1),
  (v_l1,'multiple_choice','What is "facade"?','la fachada',array['la fanfarria','la fascia','la facción'],'facade',2),
  (v_l1,'fill_blank','Complete: "La cúpula es la más alta ____ ciudad." (of the)','de la',array['del','en la','por la'],'of the',3),
  (v_l1,'multiple_choice','What is "vault"?','la bóveda',array['la bobina','la bota','la boca'],'vault',4),
  (v_l1,'multiple_choice','What is "brick"?','el ladrillo',array['el listón','el lazo','el lance'],'brick',5),
  (v_l2,'multiple_choice','What is "Mudejar"?','el mudéjar',array['el moderno','el monástico','el mongol'],'Mudejar',1),
  (v_l2,'multiple_choice','What is "Modernismo"?','Art Nouveau (Spanish)',array['Modern style (any)','Modernization','Avant-garde art'],'Modernismo',2),
  (v_l2,'fill_blank','Complete: "Aunque ____ dentro del modernismo." (worked — subj)','trabajara',array['trabajó','trabaja','trabajaría'],'worked (subj)',3),
  (v_l2,'multiple_choice','What is "symmetry"?','la simetría',array['la similitud','la semejanza','la sintonía'],'symmetry',4),
  (v_l2,'multiple_choice','What is "Romanesque"?','el románico',array['el romántico','el roma','el rumano'],'Romanesque',5),
  (v_l3,'multiple_choice','What is "floor plan"?','el plano',array['el plan','el planeta','el plantío'],'floor plan',1),
  (v_l3,'multiple_choice','What does "seguir + gerund" mean?','to keep + V-ing',array['to follow + V-ing','to chase + V-ing','to seek + V-ing'],'to keep V-ing',2),
  (v_l3,'fill_blank','Complete: "La Sagrada Familia sigue ____" (being built)','construyéndose',array['construido','construyendo','construye'],'being built',3),
  (v_l3,'multiple_choice','What is "model" (architectural)?','la maqueta',array['la maquinaria','la máquina','la maraca'],'model',4),
  (v_l3,'multiple_choice','What does "diseñar" mean?','to design',array['to discern','to dismiss','to dispense'],'to design',5),
  (v_l4,'multiple_choice','What is "neighborhood"?','el barrio',array['el barril','el barranco','el bario'],'neighborhood',1),
  (v_l4,'multiple_choice','What does "peatonal" mean?','pedestrian',array['perpendicular','peripheral','permanent'],'pedestrian',2),
  (v_l4,'fill_blank','Complete: "____ el centro mejoraría la vida." (To pedestrianize)','Peatonalizar',array['Peatonalizando','Peatonalizado','Peatonalice'],'to pedestrianize',3),
  (v_l4,'multiple_choice','What is "avenue"?','la avenida',array['la aventura','la advenida','la advertencia'],'avenue',4),
  (v_l4,'multiple_choice','What is "historic center"?','el centro histórico',array['el centro histórico (incorrect)','el centro antiguo','el centro viejo'],'historic center',5),
  (v_l5,'multiple_choice','What is "sustainable"?','sostenible',array['soportable','sosegable','sospechable'],'sustainable',1),
  (v_l5,'multiple_choice','What follows "para que"?','subjunctive',array['indicative','infinitive','imperative'],'para que + subj',2),
  (v_l5,'fill_blank','Complete: "Para que el edificio ____ poca energía." (consumes — subj)','consuma',array['consume','consumirá','consumió'],'consumes (subj)',3),
  (v_l5,'multiple_choice','What is "concrete"?','el hormigón',array['el hierro','el hornillo','el hostal'],'concrete',4),
  (v_l5,'multiple_choice','What is "wood"?','la madera',array['la madeja','la matera','la malla'],'wood',5),
  (v_l6,'multiple_choice','What is "commission"?','el encargo',array['el encanto','el encierro','el encore'],'commission',1),
  (v_l6,'multiple_choice','What is "natural light"?','la luz natural',array['la luz del día','la luz solar','la luz blanca'],'natural light',2),
  (v_l6,'fill_blank','Complete: "Un espacio que ____ luz natural." (would integrate — subj)','integrara',array['integra','integraba','integraría'],'integrate (subj)',3),
  (v_l6,'multiple_choice','What is "proposal"?','la propuesta',array['la propaganda','la propiedad','la propinada'],'proposal',4),
  (v_l6,'multiple_choice','What does "orientada al sur" mean?','facing south',array['oriented to summer','arranged to suit','open to source'],'facing south',5),
  (v_l7,'multiple_choice','What does "emblemático" mean?','emblematic',array['emblazoned','empathic','embodied'],'emblematic',1),
  (v_l7,'multiple_choice','What does "caracterizarse por" mean?','to be characterized by',array['to make a character','to act as','to play a role'],'to be characterized by',2),
  (v_l7,'fill_blank','Complete: "Por ____ revitalizado la ciudad." (having)','haber',array['haya','habiendo','había'],'having',3),
  (v_l7,'multiple_choice','What is "monument"?','el monumento',array['el monstruo','el momento','el montículo'],'monument',4),
  (v_l7,'multiple_choice','What does "destacar" mean?','to stand out',array['to detach','to destroy','to depart'],'to stand out',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Esta cúpula barroca es la más alta de la ciudad',array['La fachada es impresionante','El arco es enorme','El edificio es nuevo'],'This baroque dome is the tallest in the city',6),
  (v_l1,'listening','What did you hear?','la más alta de la ciudad',array['la más alta del mundo','la más alta del barrio','la más alta del país'],'the tallest in the city',7),
  (v_l1,'speaking','Say this aloud: "Es la cúpula más alta de la ciudad."','Es la cúpula más alta de la ciudad',array[]::text[],'It''s the tallest dome in the city.',8),
  (v_l1,'speaking','Say this aloud: "La fachada es impresionante."','La fachada es impresionante',array[]::text[],'The facade is impressive.',9),
  (v_l2,'listening','What did you hear?','Gaudí, aunque trabajara dentro del modernismo, creó un estilo propio',array['Su influencia perdura','La simetría no le importaba','El románico era anterior'],'Gaudí, although he worked within Modernismo, created his own style',6),
  (v_l2,'listening','What did you hear?','creó un estilo propio',array['siguió el estilo común','imitó a sus maestros','rechazó el modernismo'],'created his own style',7),
  (v_l2,'speaking','Say this aloud: "Creó un estilo propio."','Creó un estilo propio',array[]::text[],'He created his own style.',8),
  (v_l2,'speaking','Say this aloud: "Aunque trabajara dentro del modernismo."','Aunque trabajara dentro del modernismo',array[]::text[],'Although he worked within Modernismo.',9),
  (v_l3,'listening','What did you hear?','La Sagrada Familia, diseñada por Gaudí, sigue construyéndose más de un siglo después',array['El plano es complejo','La construcción es lenta','La maqueta está en el museo'],'The Sagrada Familia, designed by Gaudí, is still being built more than a century later',6),
  (v_l3,'listening','What did you hear?','sigue construyéndose',array['está terminada','fue destruida','será demolida'],'is still being built',7),
  (v_l3,'speaking','Say this aloud: "Sigue construyéndose hoy."','Sigue construyéndose hoy',array[]::text[],'It''s still being built today.',8),
  (v_l3,'speaking','Say this aloud: "Diseñada por Gaudí."','Diseñada por Gaudí',array[]::text[],'Designed by Gaudí.',9),
  (v_l6,'listening','What did you hear?','El cliente nos pidió un espacio que integrara luz natural y ventilación cruzada',array['Diseñamos una fachada acristalada','El proyecto es complejo','El presupuesto es alto'],'The client asked us for a space that would integrate natural light and cross ventilation',6),
  (v_l6,'listening','What did you hear?','Diseñamos una fachada acristalada orientada al sur',array['Integramos luz natural','El espacio es amplio','La ventilación es excelente'],'We designed a glazed facade facing south',7),
  (v_l6,'speaking','Say this aloud: "Un espacio con mucha luz natural."','Un espacio con mucha luz natural',array[]::text[],'A space with lots of natural light.',8),
  (v_l6,'speaking','Say this aloud: "Una fachada orientada al sur."','Una fachada orientada al sur',array[]::text[],'A facade facing south.',9),
  (v_l7,'listening','What did you hear?','El Guggenheim de Bilbao, obra emblemática de Frank Gehry',array['Sus formas onduladas de titanio','Destaca por su impacto visual','Revitalizó toda una ciudad'],'The Guggenheim of Bilbao, an emblematic work of Frank Gehry',6),
  (v_l7,'listening','What did you hear?','Destaca por su impacto visual y por haber revitalizado toda una ciudad',array['Su impacto cultural fue enorme','Por haber sido emblemático','Por haber influido en otros'],'It stands out for its visual impact and for having revitalized an entire city',7),
  (v_l7,'speaking','Say this aloud: "Destaca por su impacto visual."','Destaca por su impacto visual',array[]::text[],'It stands out for its visual impact.',8),
  (v_l7,'speaking','Say this aloud: "Por haber revitalizado la ciudad."','Por haber revitalizado la ciudad',array[]::text[],'For having revitalized the city.',9);

  update public.lessons set type='conversation', title='Architecture — Conversation Practice',
    description='Two architects discuss a design.',
    intro='Marina and Roberto review a competition entry.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Marina","spanish":"¿Has visto la propuesta para el nuevo museo?","english":"Have you seen the proposal for the new museum?"},{"speaker":"Roberto","spanish":"Sí. La fachada acristalada es emblemática, casi al estilo de Gehry.","english":"Yes. The glass facade is emblematic, almost in the Gehry style."},{"speaker":"Marina","spanish":"Y se caracteriza por una eficiencia energética excepcional.","english":"And it''s characterized by exceptional energy efficiency."},{"speaker":"Roberto","spanish":"Diseñaron para que el edificio consuma muy poca energía.","english":"They designed so the building consumes very little energy."},{"speaker":"Marina","spanish":"Aunque el presupuesto sea ajustado, vale la pena el riesgo.","english":"Even if the budget is tight, the risk is worth it."},{"speaker":"Roberto","spanish":"Sin duda. Por haber innovado, destacará en el concurso.","english":"Without doubt. For having innovated, it will stand out in the competition."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','What kind of facade is it?','Glazed (glass)',array['Brick','Stone','Concrete'],'fachada acristalada',1),
  (v_l8,'multiple_choice','Whose style does it resemble?','Gehry',array['Gaudí','Calatrava','Moneo'],'al estilo de Gehry',2),
  (v_l8,'multiple_choice','Key sustainability feature?','Exceptional energy efficiency',array['Wood materials','Underground location','Solar-only power'],'eficiencia energética excepcional',3),
  (v_l8,'multiple_choice','Marina''s reservation?','Tight budget',array['Bad location','Wrong style','Too small'],'el presupuesto sea ajustado',4),
  (v_l8,'fill_blank','Complete: "Aunque el presupuesto ____ ajustado." (be — subj)','sea',array['es','será','era'],'be (subj)',5),
  (v_l8,'multiple_choice','Why will it stand out?','For having innovated',array['For being cheap','For being copied','For following trends'],'por haber innovado',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Architecture', 'Review test for the Architecture section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "dome"?','la cúpula',array['la bóveda','la columna','el arco'],'dome',1),
  (v_lesson_id,'multiple_choice','What follows "para que"?','subjunctive',array['indicative','infinitive','imperative'],'para que + subj',2),
  (v_lesson_id,'multiple_choice','What is "sustainable"?','sostenible',array['soportable','sosegable','sospechable'],'sustainable',3),
  (v_lesson_id,'multiple_choice','What does "seguir + gerund" mean?','to keep + V-ing',array['to follow + V-ing','to chase + V-ing','to seek + V-ing'],'to keep V-ing',4),
  (v_lesson_id,'fill_blank','Complete: "Un espacio que ____ luz natural." (would integrate — subj)','integrara',array['integra','integraba','integraría'],'integrate (subj)',5),
  (v_lesson_id,'fill_blank','Complete: "Por ____ revitalizado la ciudad." (having)','haber',array['haya','habiendo','había'],'having',6),
  (v_lesson_id,'listening','What did you hear?','La Sagrada Familia, diseñada por Gaudí, sigue construyéndose',array['El cliente nos pidió un espacio','Destaca por su impacto visual','Esta cúpula barroca'],'The Sagrada Familia, designed by Gaudí, is still being built',7),
  (v_lesson_id,'listening','What did you hear?','Por haber innovado, destacará en el concurso',array['Aunque el presupuesto sea ajustado','La fachada acristalada','Eficiencia energética excepcional'],'For having innovated, it will stand out in the competition',8),
  (v_lesson_id,'speaking','Say this aloud: "Una fachada emblemática."','Una fachada emblemática',array[]::text[],'An emblematic facade.',9),
  (v_lesson_id,'speaking','Say this aloud: "Diseñada para ser sostenible."','Diseñada para ser sostenible',array[]::text[],'Designed to be sustainable.',10);

  -- ===========================================================
  -- B2.13 FASHION & DESIGN
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B2' and title = 'Fashion & Design';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='Fashion industry vocabulary: "la moda", "el diseñador", "la colección". Spanish borrows many French terms.',
    vocab_items='[{"spanish":"la moda","english":"fashion"},{"spanish":"el diseñador","english":"designer"},{"spanish":"la colección","english":"collection"},{"spanish":"la pasarela","english":"runway"},{"spanish":"el desfile","english":"fashion show"},{"spanish":"la modelo","english":"model (fashion)"},{"spanish":"la tendencia","english":"trend"},{"spanish":"la temporada","english":"season"},{"spanish":"el atuendo","english":"outfit"},{"spanish":"la prenda","english":"garment"}]'::jsonb,
    dialogue='[{"speaker":"Crítica","spanish":"La nueva colección sorprende por su atrevimiento.","english":"The new collection surprises with its boldness."}]'::jsonb,
    grammar_note='"Sorprender por + noun" = "to surprise with/by + noun". The preposition "por" introduces the cause of the reaction.'
  where id = v_l1;

  update public.lessons set
    intro='Materials and textures: "el algodón", "la seda", "el cuero". Texture vocabulary enables precise critical commentary.',
    vocab_items='[{"spanish":"el algodón","english":"cotton"},{"spanish":"la seda","english":"silk"},{"spanish":"el cuero","english":"leather"},{"spanish":"el lino","english":"linen"},{"spanish":"la lana","english":"wool"},{"spanish":"el sintético","english":"synthetic"},{"spanish":"la textura","english":"texture"},{"spanish":"suave","english":"soft"},{"spanish":"áspero","english":"rough"},{"spanish":"resistente","english":"resistant"}]'::jsonb,
    dialogue='[{"speaker":"Diseñadora","spanish":"Elijo seda para que el vestido fluya con el movimiento.","english":"I choose silk so the dress flows with movement."}]'::jsonb,
    grammar_note='"Para que + subjunctive" again: "para que el vestido fluya". Reinforces the purpose-clause subjunctive learned in B2.12.'
  where id = v_l2;

  update public.lessons set
    intro='Style and aesthetics: minimalist, maximalist, classic, avant-garde. Adjective use is rich in fashion criticism.',
    vocab_items='[{"spanish":"el estilo","english":"style"},{"spanish":"minimalista","english":"minimalist"},{"spanish":"clásico","english":"classic"},{"spanish":"elegante","english":"elegant"},{"spanish":"sofisticado","english":"sophisticated"},{"spanish":"atrevido","english":"bold"},{"spanish":"discreto","english":"understated"},{"spanish":"llamativo","english":"eye-catching"},{"spanish":"original","english":"original"},{"spanish":"vanguardista","english":"avant-garde"}]'::jsonb,
    dialogue='[{"speaker":"Editora","spanish":"Lo elegante nunca pasa de moda; lo llamativo, sí.","english":"What''s elegant never goes out of style; what''s eye-catching does."}]'::jsonb,
    grammar_note='"Lo + adjective" as abstract noun: "lo elegante" = "what is elegant", "lo llamativo" = "what is eye-catching". Used to discuss categories of qualities.'
  where id = v_l3;

  update public.lessons set
    intro='Spanish designers: Balenciaga, Loewe, Carolina Herrera. Spain has a distinguished design tradition.',
    vocab_items='[{"spanish":"el legado","english":"legacy"},{"spanish":"la influencia","english":"influence"},{"spanish":"la maestría","english":"mastery"},{"spanish":"reinventar","english":"to reinvent"},{"spanish":"la herencia","english":"heritage"},{"spanish":"la sastrería","english":"tailoring"},{"spanish":"la alta costura","english":"haute couture"},{"spanish":"el prêt-à-porter","english":"ready-to-wear"},{"spanish":"la firma","english":"label/brand"},{"spanish":"el logotipo","english":"logo"}]'::jsonb,
    dialogue='[{"speaker":"Crítica","spanish":"Balenciaga, conocido por su maestría en la sastrería, reinventó la silueta femenina.","english":"Balenciaga, known for his mastery in tailoring, reinvented the female silhouette."}]'::jsonb,
    grammar_note='"Conocido por + noun" = "known for + noun". Common in artist/designer descriptions: "conocido por su maestría", "famosa por su estilo".'
  where id = v_l4;

  update public.lessons set
    intro='Sustainable fashion: "moda sostenible". Ethical production, second-hand, slow fashion.',
    vocab_items='[{"spanish":"la moda sostenible","english":"sustainable fashion"},{"spanish":"la moda rápida","english":"fast fashion"},{"spanish":"la moda lenta","english":"slow fashion"},{"spanish":"de segunda mano","english":"second-hand"},{"spanish":"ético","english":"ethical"},{"spanish":"el residuo","english":"waste"},{"spanish":"el impacto ambiental","english":"environmental impact"},{"spanish":"la cadena de producción","english":"production chain"},{"spanish":"transparente","english":"transparent"},{"spanish":"el consumidor","english":"consumer"}]'::jsonb,
    dialogue='[{"speaker":"Activista","spanish":"Si los consumidores exigieran transparencia, las marcas tendrían que adaptarse.","english":"If consumers demanded transparency, brands would have to adapt."}]'::jsonb,
    grammar_note='Second conditional in social critique: "si exigieran, tendrían" — hypothetical present argument for change. The imperfect subjunctive expresses unrealized scenarios.'
  where id = v_l5;

  update public.lessons set
    intro='Listen to a fashion show commentary. Notice the rapid description and evaluative adjectives.',
    vocab_items='[{"spanish":"el comentarista","english":"commentator"},{"spanish":"la pasarela","english":"runway"},{"spanish":"el conjunto","english":"outfit/ensemble"},{"spanish":"el corte","english":"cut"},{"spanish":"la silueta","english":"silhouette"},{"spanish":"la paleta de colores","english":"color palette"},{"spanish":"deslumbrar","english":"to dazzle"}]'::jsonb,
    dialogue='[{"speaker":"Comentarista","spanish":"En la pasarela, un conjunto deslumbrante: silueta minimalista, paleta de colores neutros, corte impecable.","english":"On the runway, a dazzling outfit: minimalist silhouette, neutral color palette, impeccable cut."},{"speaker":"Comentarista","spanish":"Sin duda, una propuesta que marcará la temporada.","english":"Without doubt, a proposal that will mark the season."}]'::jsonb,
    grammar_note='Telegraphic descriptive style in fashion reporting: nouns and adjectives strung together without verbs: "silueta minimalista, paleta neutra, corte impecable".'
  where id = v_l6;

  update public.lessons set
    intro='Write a personal style description. Talk about your wardrobe choices and aesthetic preferences.',
    vocab_items='[{"spanish":"el armario","english":"wardrobe"},{"spanish":"el básico","english":"basic (item)"},{"spanish":"combinar","english":"to combine"},{"spanish":"el accesorio","english":"accessory"},{"spanish":"la comodidad","english":"comfort"},{"spanish":"la versatilidad","english":"versatility"},{"spanish":"identificarse con","english":"to identify with"},{"spanish":"el ícono de estilo","english":"style icon"}]'::jsonb,
    dialogue='[{"speaker":"Bloguera","spanish":"Mi armario está lleno de básicos versátiles que combino según el día.","english":"My wardrobe is full of versatile basics that I combine according to the day."},{"speaker":"Bloguera","spanish":"Me identifico con un estilo minimalista, sin que ello signifique aburrido.","english":"I identify with a minimalist style, without it meaning boring."}]'::jsonb,
    grammar_note='"Sin que + subjunctive" + neuter "ello": "sin que ello signifique" = "without it meaning". "Ello" refers back to an abstract concept (here, the minimalist style).'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "fashion show"?','el desfile',array['la moda','la colección','la pasarela'],'fashion show',1),
  (v_l1,'multiple_choice','What is "garment"?','la prenda',array['la prensa','la prima','la pradera'],'garment',2),
  (v_l1,'fill_blank','Complete: "Sorprende ____ su atrevimiento." (with)','por',array['con','para','de'],'with',3),
  (v_l1,'multiple_choice','What is "trend"?','la tendencia',array['la tendinitis','la tendencia (incorrect)','la tendinosa'],'trend',4),
  (v_l1,'multiple_choice','What is "runway"?','la pasarela',array['la pasada','la pasajera','la pasamanería'],'runway',5),
  (v_l2,'multiple_choice','What is "silk"?','la seda',array['la sedición','la cedida','la sed'],'silk',1),
  (v_l2,'multiple_choice','What is "leather"?','el cuero',array['el cubo','el cumbre','el cubre'],'leather',2),
  (v_l2,'fill_blank','Complete: "Para que ____ con el movimiento." (flows — subj)','fluya',array['fluye','fluyó','fluiría'],'flows (subj)',3),
  (v_l2,'multiple_choice','What is "wool"?','la lana',array['la liana','la luna','la lazada'],'wool',4),
  (v_l2,'multiple_choice','What does "áspero" mean?','rough',array['asparagus','aspect','aspire'],'rough',5),
  (v_l3,'multiple_choice','What does "lo elegante" mean?','what is elegant',array['the elegant one (man)','the elegant (thing — concrete)','more elegant'],'what is elegant',1),
  (v_l3,'multiple_choice','What does "atrevido" mean?','bold',array['attractive','adventurous (only travel)','attentive'],'bold',2),
  (v_l3,'fill_blank','Complete: "____ llamativo pasa de moda." (What''s)','Lo',array['El','La','Le'],'what''s',3),
  (v_l3,'multiple_choice','What is "understated"?','discreto',array['concreto','correcto','colecto'],'understated',4),
  (v_l3,'multiple_choice','What does "sofisticado" mean?','sophisticated',array['suffocated','sufficient','sustained'],'sophisticated',5),
  (v_l4,'multiple_choice','What is "haute couture"?','la alta costura',array['la moda alta','el alto vestir','la alta calidad'],'haute couture',1),
  (v_l4,'multiple_choice','What does "reinventar" mean?','to reinvent',array['to reinstall','to repeat','to remember'],'to reinvent',2),
  (v_l4,'fill_blank','Complete: "Balenciaga, ____ por su maestría." (known)','conocido',array['conocida','conoce','conociendo'],'known (masc)',3),
  (v_l4,'multiple_choice','What is "label/brand"?','la firma',array['la firmamento','la finca','la firmeza'],'label/brand',4),
  (v_l4,'multiple_choice','What is "heritage"?','la herencia',array['la herida','la hermandad','la herrería'],'heritage',5),
  (v_l5,'multiple_choice','What is "fast fashion"?','la moda rápida',array['la moda lenta','la moda sostenible','la moda corriente'],'fast fashion',1),
  (v_l5,'multiple_choice','Second conditional structure?','si exigieran + tendrían',array['si exigen + tienen','si exigirán + tendrán','si exigieran + tienen'],'present hypothetical',2),
  (v_l5,'fill_blank','Complete: "Si los consumidores ____ transparencia." (demanded — subj)','exigieran',array['exigen','exigirían','exigieron'],'demanded (subj)',3),
  (v_l5,'multiple_choice','What is "waste"?','el residuo',array['el residuo (incorrect)','el restaurar','el reparto'],'waste',4),
  (v_l5,'multiple_choice','What does "ético" mean?','ethical',array['ethnic','etiquette','ethereal'],'ethical',5),
  (v_l6,'multiple_choice','What is "silhouette"?','la silueta',array['la silla','la siesta','la sílaba'],'silhouette',1),
  (v_l6,'multiple_choice','What is "color palette"?','la paleta de colores',array['la pala de colores','la planta de colores','la paleta cromática (incorrect)'],'color palette',2),
  (v_l6,'fill_blank','Complete: "Un conjunto ____" (dazzling)','deslumbrante',array['deslumbrado','deslumbrar','deslumbrando'],'dazzling',3),
  (v_l6,'multiple_choice','What is "cut" (clothing)?','el corte',array['el cortejo','el cortes','el cortijo'],'cut',4),
  (v_l6,'multiple_choice','What does "impecable" mean?','impeccable',array['imposible','impactante','imperceptible'],'impeccable',5),
  (v_l7,'multiple_choice','What is "wardrobe"?','el armario',array['el armadillo','el arma','el armado'],'wardrobe',1),
  (v_l7,'multiple_choice','What is "versatility"?','la versatilidad',array['la verticalidad','la veracidad','la velocidad'],'versatility',2),
  (v_l7,'fill_blank','Complete: "Sin que ____ aburrido." (it means — subj)','signifique',array['significa','significaba','significaría'],'means (subj)',3),
  (v_l7,'multiple_choice','What does "combinar" mean?','to combine',array['to commemorate','to comment','to commit'],'to combine',4),
  (v_l7,'multiple_choice','What does "identificarse con" mean?','to identify with',array['to be identified by','to identify (someone)','to be identical'],'to identify with',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','La nueva colección sorprende por su atrevimiento',array['La pasarela está llena','El desfile fue corto','La temporada termina'],'The new collection surprises with its boldness',6),
  (v_l1,'listening','What did you hear?','por su atrevimiento',array['por su elegancia','por su clasicismo','por su discreción'],'with its boldness',7),
  (v_l1,'speaking','Say this aloud: "La colección sorprende por su atrevimiento."','La colección sorprende por su atrevimiento',array[]::text[],'The collection surprises with its boldness.',8),
  (v_l1,'speaking','Say this aloud: "Marca la tendencia de la temporada."','Marca la tendencia de la temporada',array[]::text[],'It sets the trend for the season.',9),
  (v_l2,'listening','What did you hear?','Elijo seda para que el vestido fluya con el movimiento',array['Prefiero algodón resistente','El cuero es elegante','La lana es cálida'],'I choose silk so the dress flows with movement',6),
  (v_l2,'listening','What did you hear?','para que el vestido fluya',array['para que el vestido brille','para que el vestido caiga','para que el vestido luzca'],'so the dress flows',7),
  (v_l2,'speaking','Say this aloud: "Elijo seda por su textura."','Elijo seda por su textura',array[]::text[],'I choose silk for its texture.',8),
  (v_l2,'speaking','Say this aloud: "Para que fluya con el movimiento."','Para que fluya con el movimiento',array[]::text[],'So it flows with movement.',9),
  (v_l3,'listening','What did you hear?','Lo elegante nunca pasa de moda; lo llamativo, sí',array['Lo minimalista es atemporal','Lo clásico es seguro','Lo vanguardista arriesga'],'What''s elegant never goes out of style; what''s eye-catching does',6),
  (v_l3,'listening','What did you hear?','Lo llamativo pasa de moda',array['Lo elegante perdura','Lo clásico vuelve','Lo nuevo sorprende'],'What''s eye-catching goes out of style',7),
  (v_l3,'speaking','Say this aloud: "Lo elegante nunca pasa de moda."','Lo elegante nunca pasa de moda',array[]::text[],'What''s elegant never goes out of style.',8),
  (v_l3,'speaking','Say this aloud: "Prefiero un estilo discreto."','Prefiero un estilo discreto',array[]::text[],'I prefer an understated style.',9),
  (v_l6,'listening','What did you hear?','silueta minimalista, paleta de colores neutros, corte impecable',array['silueta clásica','paleta vibrante','corte tradicional'],'minimalist silhouette, neutral color palette, impeccable cut',6),
  (v_l6,'listening','What did you hear?','una propuesta que marcará la temporada',array['un atuendo emblemático','una colección audaz','un desfile inolvidable'],'a proposal that will mark the season',7),
  (v_l6,'speaking','Say this aloud: "Una silueta minimalista."','Una silueta minimalista',array[]::text[],'A minimalist silhouette.',8),
  (v_l6,'speaking','Say this aloud: "Marca la temporada."','Marca la temporada',array[]::text[],'It marks the season.',9),
  (v_l7,'listening','What did you hear?','Mi armario está lleno de básicos versátiles que combino según el día',array['Identificarse con un estilo','Sin que ello signifique aburrido','Me gusta lo minimalista'],'My wardrobe is full of versatile basics I combine according to the day',6),
  (v_l7,'listening','What did you hear?','Me identifico con un estilo minimalista, sin que ello signifique aburrido',array['Mi armario está lleno','Los básicos son versátiles','Combinar es difícil'],'I identify with a minimalist style, without it meaning boring',7),
  (v_l7,'speaking','Say this aloud: "Combino los básicos según el día."','Combino los básicos según el día',array[]::text[],'I combine the basics according to the day.',8),
  (v_l7,'speaking','Say this aloud: "Me identifico con un estilo minimalista."','Me identifico con un estilo minimalista',array[]::text[],'I identify with a minimalist style.',9);

  update public.lessons set type='conversation', title='Fashion & Design — Conversation Practice',
    description='Two friends discuss a fashion show.',
    intro='Laura and Sofía review the Madrid Fashion Week.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Laura","spanish":"¿Viste la pasarela de Madrid Fashion Week?","english":"Did you see the Madrid Fashion Week runway?"},{"speaker":"Sofía","spanish":"Sí. La colección de Loewe me deslumbró por su maestría en la sastrería.","english":"Yes. The Loewe collection dazzled me with its mastery in tailoring."},{"speaker":"Laura","spanish":"Y la apuesta por materiales sostenibles fue impresionante.","english":"And the commitment to sustainable materials was impressive."},{"speaker":"Sofía","spanish":"Si los consumidores exigiéramos transparencia, todas las firmas se adaptarían.","english":"If consumers demanded transparency, all brands would adapt."},{"speaker":"Laura","spanish":"Sin duda. Lo importante es que destacan por haber innovado, no por copiar.","english":"Without doubt. The important thing is that they stand out for having innovated, not for copying."},{"speaker":"Sofía","spanish":"Aunque sea un solo desfile, marcó la tendencia de la temporada.","english":"Even if just one show, it set the trend of the season."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','Whose collection dazzled Sofía?','Loewe',array['Balenciaga','Carolina Herrera','Zara'],'la colección de Loewe',1),
  (v_l8,'multiple_choice','What was impressive besides design?','Sustainable materials',array['Low prices','Loud music','Famous guests'],'materiales sostenibles',2),
  (v_l8,'multiple_choice','Sofía''s social critique?','If consumers demanded transparency, brands would adapt',array['Consumers are powerless','Brands ignore demands','Transparency is impossible'],'si los consumidores exigiéramos',3),
  (v_l8,'multiple_choice','Why do they stand out?','For having innovated',array['For being cheap','For being famous','For copying trends'],'por haber innovado',4),
  (v_l8,'fill_blank','Complete: "Aunque ____ un solo desfile." (be — subj)','sea',array['es','será','era'],'be (subj)',5),
  (v_l8,'multiple_choice','What did the show set?','The trend of the season',array['A new price point','A scandal','A controversy'],'la tendencia de la temporada',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Fashion & Design', 'Review test for the Fashion & Design section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "fashion show"?','el desfile',array['la moda','la pasarela','la colección'],'fashion show',1),
  (v_lesson_id,'multiple_choice','What does "para que" require?','subjunctive',array['indicative','infinitive','imperative'],'para que + subj',2),
  (v_lesson_id,'multiple_choice','What is "haute couture"?','la alta costura',array['la moda alta','el alto vestir','la alta calidad'],'haute couture',3),
  (v_lesson_id,'multiple_choice','Second conditional structure?','si exigieran + tendrían',array['si exigen + tienen','si exigirán + tendrán','si exigieran + tienen'],'present hypothetical',4),
  (v_lesson_id,'fill_blank','Complete: "Sin que ____ aburrido." (it means — subj)','signifique',array['significa','significaba','significaría'],'means (subj)',5),
  (v_lesson_id,'fill_blank','Complete: "Lo ____ nunca pasa de moda." (elegant)','elegante',array['elegantes','elegancia','elegir'],'elegant',6),
  (v_lesson_id,'listening','What did you hear?','Si los consumidores exigieran transparencia, las marcas tendrían que adaptarse',array['La moda sostenible avanza','Los residuos disminuyen','El impacto es alto'],'If consumers demanded transparency, brands would have to adapt',7),
  (v_lesson_id,'listening','What did you hear?','silueta minimalista, paleta de colores neutros, corte impecable',array['Por su atrevimiento','La maestría en sastrería','Marca la tendencia'],'minimalist silhouette, neutral color palette, impeccable cut',8),
  (v_lesson_id,'speaking','Say this aloud: "La colección sorprende por su atrevimiento."','La colección sorprende por su atrevimiento',array[]::text[],'The collection surprises with its boldness.',9),
  (v_lesson_id,'speaking','Say this aloud: "Una silueta minimalista impecable."','Una silueta minimalista impecable',array[]::text[],'An impeccable minimalist silhouette.',10);

  -- ===========================================================
  -- B2.14 SPORTS ANALYSIS
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B2' and title = 'Sports Analysis';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='Sports analysis vocabulary: "el partido", "el equipo", "el rendimiento". Sports Spanish is fast-paced and metaphor-rich.',
    vocab_items='[{"spanish":"el partido","english":"match/game"},{"spanish":"el equipo","english":"team"},{"spanish":"el jugador","english":"player"},{"spanish":"el entrenador","english":"coach"},{"spanish":"el árbitro","english":"referee"},{"spanish":"el rendimiento","english":"performance"},{"spanish":"la actuación","english":"performance (act)"},{"spanish":"el marcador","english":"scoreboard"},{"spanish":"empatar","english":"to draw/tie"},{"spanish":"ganar","english":"to win"}]'::jsonb,
    dialogue='[{"speaker":"Comentarista","spanish":"El equipo local ha tenido un rendimiento por debajo de las expectativas.","english":"The home team has had a performance below expectations."}]'::jsonb,
    grammar_note='"Por debajo/encima de + noun" = "below/above + noun". Used for measurements, expectations, standards: "por debajo de la media", "por encima de cero".'
  where id = v_l1;

  update public.lessons set
    intro='Tactics and strategy: "la táctica", "la estrategia", "la formación". Football/soccer dominates Spanish sports vocabulary.',
    vocab_items='[{"spanish":"la táctica","english":"tactics"},{"spanish":"la estrategia","english":"strategy"},{"spanish":"la formación","english":"formation"},{"spanish":"el ataque","english":"attack"},{"spanish":"la defensa","english":"defense"},{"spanish":"el contraataque","english":"counterattack"},{"spanish":"el pase","english":"pass"},{"spanish":"el tiro","english":"shot"},{"spanish":"el gol","english":"goal"},{"spanish":"el portero","english":"goalkeeper"}]'::jsonb,
    dialogue='[{"speaker":"Entrenador","spanish":"Si hubiéramos atacado por las bandas, habríamos creado más ocasiones.","english":"If we had attacked down the flanks, we would have created more chances."}]'::jsonb,
    grammar_note='Third conditional in sports post-match: "si hubiéramos atacado, habríamos creado". Sports commentary lives in counterfactuals.'
  where id = v_l2;

  update public.lessons set
    intro='Statistics and analytics: modern sports analysis is data-driven. "Las estadísticas", "los datos", "los promedios".',
    vocab_items='[{"spanish":"la estadística","english":"statistic"},{"spanish":"los datos","english":"data"},{"spanish":"el promedio","english":"average"},{"spanish":"el porcentaje","english":"percentage"},{"spanish":"la posesión","english":"possession"},{"spanish":"el remate","english":"shot (on goal)"},{"spanish":"la efectividad","english":"effectiveness"},{"spanish":"el análisis","english":"analysis"},{"spanish":"medir","english":"to measure"},{"spanish":"superar","english":"to surpass"}]'::jsonb,
    dialogue='[{"speaker":"Analista","spanish":"El equipo superó el setenta por ciento de posesión en el segundo tiempo.","english":"The team exceeded seventy percent possession in the second half."}]'::jsonb,
    grammar_note='Percentages in Spanish: "el X por ciento" (literally "the X per hundred"). Always preceded by the article "el": "el setenta por ciento".'
  where id = v_l3;

  update public.lessons set
    intro='Athletes and training: "el atleta", "el deportista", "entrenar". Discussion of physical conditioning.',
    vocab_items='[{"spanish":"el atleta","english":"athlete"},{"spanish":"el deportista","english":"sportsperson"},{"spanish":"entrenar","english":"to train"},{"spanish":"el entrenamiento","english":"training"},{"spanish":"la preparación física","english":"physical preparation"},{"spanish":"la resistencia","english":"endurance"},{"spanish":"la fuerza","english":"strength"},{"spanish":"la velocidad","english":"speed"},{"spanish":"la lesión","english":"injury"},{"spanish":"recuperarse","english":"to recover"}]'::jsonb,
    dialogue='[{"speaker":"Médico","spanish":"Le recomiendo que no fuerce la lesión, podría agravarse.","english":"I recommend that you don''t strain the injury, it could worsen."}]'::jsonb,
    grammar_note='"Recomendar que + subjunctive" = "to recommend that...". After verbs of recommendation/advice ("recomendar", "aconsejar", "sugerir"), always subjunctive.'
  where id = v_l4;

  update public.lessons set
    intro='Competitions: "los Juegos Olímpicos", "el Mundial", "la Liga". Major events and rankings.',
    vocab_items='[{"spanish":"los Juegos Olímpicos","english":"Olympic Games"},{"spanish":"el Mundial","english":"World Cup"},{"spanish":"la Liga","english":"League"},{"spanish":"el campeonato","english":"championship"},{"spanish":"la final","english":"final"},{"spanish":"la semifinal","english":"semifinal"},{"spanish":"la medalla","english":"medal"},{"spanish":"el podio","english":"podium"},{"spanish":"el ranking","english":"ranking"},{"spanish":"clasificarse","english":"to qualify"}]'::jsonb,
    dialogue='[{"speaker":"Comentarista","spanish":"España se clasificó para la final tras ganar la semifinal por dos a cero.","english":"Spain qualified for the final after winning the semifinal two to zero."}]'::jsonb,
    grammar_note='Scores: "por X a Y" — "ganar por dos a cero". The preposition "por" is essential for scorelines.'
  where id = v_l5;

  update public.lessons set
    intro='Listen to a post-match analysis. Hosts use rapid Spanish full of metaphor and emphasis.',
    vocab_items='[{"spanish":"el análisis post-partido","english":"post-match analysis"},{"spanish":"destacar","english":"to highlight"},{"spanish":"el momento clave","english":"key moment"},{"spanish":"el punto de inflexión","english":"turning point"},{"spanish":"la actuación destacada","english":"standout performance"},{"spanish":"merecido","english":"deserved"}]'::jsonb,
    dialogue='[{"speaker":"Analista","spanish":"El gol del minuto sesenta fue el punto de inflexión del partido.","english":"The goal at minute sixty was the turning point of the match."},{"speaker":"Analista","spanish":"Aunque el rival tuviera más posesión, la victoria fue merecida.","english":"Even though the rival had more possession, the victory was deserved."}]'::jsonb,
    grammar_note='"Aunque + imperfect subjunctive" again: "aunque tuviera más posesión". Concessive — acknowledges but counters: "even if it was true that... the conclusion stands".'
  where id = v_l6;

  update public.lessons set
    intro='Write a sports column. Express opinion with authority. Use evaluative adjectives and clear structure.',
    vocab_items='[{"spanish":"la columna","english":"column"},{"spanish":"opinar","english":"to opine"},{"spanish":"argumentar","english":"to argue"},{"spanish":"convincente","english":"convincing"},{"spanish":"decepcionante","english":"disappointing"},{"spanish":"prometedor","english":"promising"},{"spanish":"sobresaliente","english":"outstanding"},{"spanish":"lamentable","english":"lamentable"}]'::jsonb,
    dialogue='[{"speaker":"Columna","spanish":"Lo más decepcionante no fue la derrota, sino la falta de actitud.","english":"The most disappointing thing wasn''t the defeat, but the lack of attitude."},{"speaker":"Columna","spanish":"Si el equipo no recupera la ilusión, será una temporada perdida.","english":"If the team doesn''t recover the spirit, it''ll be a lost season."}]'::jsonb,
    grammar_note='"No fue X, sino Y" = "it wasn''t X, but rather Y". Strong contrastive structure for editorializing.'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "coach"?','el entrenador',array['el jugador','el árbitro','el ojeador'],'coach',1),
  (v_l1,'multiple_choice','What does "empatar" mean?','to draw/tie',array['to defeat','to dominate','to demoralize'],'to draw/tie',2),
  (v_l1,'fill_blank','Complete: "Un rendimiento por ____ de las expectativas." (below)','debajo',array['encima','arriba','abajo'],'below',3),
  (v_l1,'multiple_choice','What is "performance" (general)?','el rendimiento',array['el rendido','el rendimiento (incorrect)','el renunciar'],'performance',4),
  (v_l1,'multiple_choice','What is "scoreboard"?','el marcador',array['el márgen','el marca','el marchador'],'scoreboard',5),
  (v_l2,'multiple_choice','What is "counterattack"?','el contraataque',array['el contraste','el contrato','el contraproducente'],'counterattack',1),
  (v_l2,'multiple_choice','Third conditional structure?','si hubiéramos + habríamos',array['si tuviéramos + tendríamos','si pudiéramos + podríamos','si fuéramos + seríamos'],'past unreal',2),
  (v_l2,'fill_blank','Complete: "Si ____ atacado por las bandas." (had — pluperf subj)','hubiéramos',array['habíamos','habríamos','habremos'],'had (subj)',3),
  (v_l2,'multiple_choice','What is "goalkeeper"?','el portero',array['el portador','el porteño','el porte'],'goalkeeper',4),
  (v_l2,'multiple_choice','What is "formation"?','la formación',array['la forma','la formula','la fortaleza'],'formation',5),
  (v_l3,'multiple_choice','What is "possession"?','la posesión',array['la postura','la posición','la posibilidad'],'possession',1),
  (v_l3,'multiple_choice','What is "average"?','el promedio',array['el promenado','el promotor','el promiscuo'],'average',2),
  (v_l3,'fill_blank','Complete: "____ setenta por ciento." (the)','el',array['un','del','al'],'the',3),
  (v_l3,'multiple_choice','What is "effectiveness"?','la efectividad',array['la efervescencia','la eficacia (synonym)','la efigie'],'effectiveness',4),
  (v_l3,'multiple_choice','What does "superar" mean here?','to exceed',array['to surpass (only people)','to suffer','to summarize'],'to exceed',5),
  (v_l4,'multiple_choice','What is "endurance"?','la resistencia',array['la persistencia','la resistencia (incorrect)','la asistencia'],'endurance',1),
  (v_l4,'multiple_choice','What follows "recomendar que"?','subjunctive',array['indicative','infinitive','imperative'],'recomendar que + subj',2),
  (v_l4,'fill_blank','Complete: "Le recomiendo que no ____ la lesión." (forces — subj)','fuerce',array['fuerza','forzó','forzaba'],'forces (subj)',3),
  (v_l4,'multiple_choice','What is "injury"?','la lesión',array['la lección','la legión','la lesa'],'injury',4),
  (v_l4,'multiple_choice','What does "recuperarse" mean?','to recover',array['to recur','to recoup','to record'],'to recover',5),
  (v_l5,'multiple_choice','What is "World Cup"?','el Mundial',array['el Internacional','el Universal','el Continental'],'World Cup',1),
  (v_l5,'multiple_choice','What is "medal"?','la medalla',array['la moneda','la mascota','la maleta'],'medal',2),
  (v_l5,'fill_blank','Complete: "Ganar ____ dos a cero." (by)','por',array['con','para','de'],'by',3),
  (v_l5,'multiple_choice','What does "clasificarse" mean?','to qualify',array['to classify','to claim','to clarify'],'to qualify',4),
  (v_l5,'multiple_choice','What is "podium"?','el podio',array['el pódium','el podiatra','el podio (incorrect)'],'podium',5),
  (v_l6,'multiple_choice','What is "turning point"?','el punto de inflexión',array['el punto crítico','el punto medio','el punto final'],'turning point',1),
  (v_l6,'multiple_choice','What does "merecido" mean?','deserved',array['merciful','merry','mercurial'],'deserved',2),
  (v_l6,'fill_blank','Complete: "Aunque ____ más posesión." (had — subj)','tuviera',array['tuvo','tiene','tendría'],'had (subj)',3),
  (v_l6,'multiple_choice','What does "destacar" mean here?','to highlight',array['to destabilize','to detail','to detain'],'to highlight',4),
  (v_l6,'multiple_choice','What is "key moment"?','el momento clave',array['el momento crucial (synonym)','el momento crítico','el momento culminante'],'key moment',5),
  (v_l7,'multiple_choice','What does "decepcionante" mean?','disappointing',array['deceptive','decisive','decorative'],'disappointing',1),
  (v_l7,'multiple_choice','What does "no X sino Y" mean?','not X but rather Y',array['neither X nor Y','either X or Y','both X and Y'],'not X but rather Y',2),
  (v_l7,'fill_blank','Complete: "No fue la derrota, ____ la actitud." (but rather)','sino',array['pero','sino que','si no'],'but rather',3),
  (v_l7,'multiple_choice','What does "prometedor" mean?','promising',array['promising (only people)','prominent','prompted'],'promising',4),
  (v_l7,'multiple_choice','What does "lamentable" mean?','lamentable',array['laminated','laughable','lateral'],'lamentable',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','El equipo local ha tenido un rendimiento por debajo de las expectativas',array['El árbitro fue cuestionado','El marcador no refleja','El partido fue intenso'],'The home team has had a performance below expectations',6),
  (v_l1,'listening','What did you hear?','por debajo de las expectativas',array['por encima de la media','al margen del partido','dentro de lo esperado'],'below expectations',7),
  (v_l1,'speaking','Say this aloud: "Un rendimiento por debajo de las expectativas."','Un rendimiento por debajo de las expectativas',array[]::text[],'A performance below expectations.',8),
  (v_l1,'speaking','Say this aloud: "El equipo local empató."','El equipo local empató',array[]::text[],'The home team drew.',9),
  (v_l2,'listening','What did you hear?','Si hubiéramos atacado por las bandas, habríamos creado más ocasiones',array['El portero estaba seguro','La defensa cedió','El árbitro no vio nada'],'If we had attacked down the flanks, we would have created more chances',6),
  (v_l2,'listening','What did you hear?','habríamos creado más ocasiones',array['habríamos marcado más goles','habríamos ganado el partido','habríamos dominado el juego'],'we would have created more chances',7),
  (v_l2,'speaking','Say this aloud: "Si hubiéramos atacado por las bandas."','Si hubiéramos atacado por las bandas',array[]::text[],'If we had attacked down the flanks.',8),
  (v_l2,'speaking','Say this aloud: "Habríamos creado más ocasiones."','Habríamos creado más ocasiones',array[]::text[],'We would have created more chances.',9),
  (v_l3,'listening','What did you hear?','El equipo superó el setenta por ciento de posesión en el segundo tiempo',array['Los datos son claros','La efectividad fue baja','El promedio no engaña'],'The team exceeded seventy percent possession in the second half',6),
  (v_l3,'listening','What did you hear?','el setenta por ciento de posesión',array['el ochenta por ciento de remates','el sesenta por ciento de pases','el cincuenta por ciento de aciertos'],'seventy percent possession',7),
  (v_l3,'speaking','Say this aloud: "El equipo superó el setenta por ciento de posesión."','El equipo superó el setenta por ciento de posesión',array[]::text[],'The team exceeded seventy percent possession.',8),
  (v_l3,'speaking','Say this aloud: "Los datos respaldan el análisis."','Los datos respaldan el análisis',array[]::text[],'The data backs up the analysis.',9),
  (v_l6,'listening','What did you hear?','El gol del minuto sesenta fue el punto de inflexión del partido',array['La defensa fue clave','El portero brilló','El árbitro decidió'],'The goal at minute sixty was the turning point of the match',6),
  (v_l6,'listening','What did you hear?','Aunque el rival tuviera más posesión, la victoria fue merecida',array['El partido fue parejo','El marcador no engaña','La actuación fue brillante'],'Even though the rival had more possession, the victory was deserved',7),
  (v_l6,'speaking','Say this aloud: "Fue el punto de inflexión."','Fue el punto de inflexión',array[]::text[],'It was the turning point.',8),
  (v_l6,'speaking','Say this aloud: "La victoria fue merecida."','La victoria fue merecida',array[]::text[],'The victory was deserved.',9),
  (v_l7,'listening','What did you hear?','Lo más decepcionante no fue la derrota, sino la falta de actitud',array['El equipo perdió en casa','El entrenador renunció','La afición se enojó'],'The most disappointing thing wasn''t the defeat, but the lack of attitude',6),
  (v_l7,'listening','What did you hear?','Si el equipo no recupera la ilusión, será una temporada perdida',array['Lo más decepcionante fue la derrota','La falta de actitud sorprendió','El próximo partido es clave'],'If the team doesn''t recover the spirit, it''ll be a lost season',7),
  (v_l7,'speaking','Say this aloud: "No fue la derrota, sino la actitud."','No fue la derrota, sino la actitud',array[]::text[],'It wasn''t the defeat, but the attitude.',8),
  (v_l7,'speaking','Say this aloud: "Una temporada perdida."','Una temporada perdida',array[]::text[],'A lost season.',9);

  update public.lessons set type='conversation', title='Sports Analysis — Conversation Practice',
    description='Two analysts discuss a football match.',
    intro='Carlos and Diego review the post-match.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Carlos","spanish":"¿Cómo viste el partido de anoche?","english":"How did you see last night''s match?"},{"speaker":"Diego","spanish":"Decepcionante. Un rendimiento por debajo de las expectativas.","english":"Disappointing. A performance below expectations."},{"speaker":"Carlos","spanish":"Si hubieran atacado por las bandas, habrían creado más ocasiones.","english":"If they had attacked down the flanks, they would have created more chances."},{"speaker":"Diego","spanish":"Aunque tuvieron el setenta por ciento de posesión, no remataron a portería.","english":"Although they had seventy percent possession, they didn''t shoot at goal."},{"speaker":"Carlos","spanish":"Lo más preocupante no fue la derrota, sino la falta de actitud.","english":"The most worrying thing wasn''t the defeat, but the lack of attitude."},{"speaker":"Diego","spanish":"Recomiendo que el entrenador hable claro con la plantilla.","english":"I recommend that the coach speak frankly with the squad."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','How does Diego rate the match?','Disappointing — below expectations',array['Excellent','Average','Outstanding'],'decepcionante',1),
  (v_l8,'multiple_choice','Carlos''s tactical critique?','Should have attacked the flanks',array['Should have played defensively','Should have changed the goalkeeper','Should have substituted earlier'],'atacar por las bandas',2),
  (v_l8,'multiple_choice','What stat did they have?','70% possession',array['80% pass accuracy','60% shots on target','50% set pieces'],'setenta por ciento de posesión',3),
  (v_l8,'multiple_choice','Diego''s deepest concern?','Lack of attitude, not the defeat itself',array['The injuries','The crowd','The referee'],'la falta de actitud',4),
  (v_l8,'fill_blank','Complete: "Recomiendo que el entrenador ____ claro." (speaks — subj)','hable',array['habla','hablará','hablaba'],'speaks (subj)',5),
  (v_l8,'multiple_choice','What does Diego recommend?','Coach speaks frankly with the squad',array['Fire the coach','Sell players','Cancel the season'],'hable claro con la plantilla',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Sports Analysis', 'Review test for the Sports Analysis section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "coach"?','el entrenador',array['el jugador','el portero','el árbitro'],'coach',1),
  (v_lesson_id,'multiple_choice','Third conditional structure?','si hubiéramos + habríamos',array['si tuviéramos + tendríamos','si fuéramos + seríamos','si pudiéramos + podríamos'],'past unreal',2),
  (v_lesson_id,'multiple_choice','What follows "recomendar que"?','subjunctive',array['indicative','infinitive','imperative'],'recomendar que + subj',3),
  (v_lesson_id,'multiple_choice','What does "no X sino Y" mean?','not X but rather Y',array['neither X nor Y','both X and Y','either X or Y'],'no X sino Y',4),
  (v_lesson_id,'fill_blank','Complete: "Si ____ atacado más." (had — subj)','hubiéramos',array['habíamos','habríamos','habremos'],'had (subj)',5),
  (v_lesson_id,'fill_blank','Complete: "____ setenta por ciento." (the)','el',array['un','del','al'],'the',6),
  (v_lesson_id,'listening','What did you hear?','Habríamos creado más ocasiones',array['Un rendimiento por debajo','El equipo superó el setenta','La victoria fue merecida'],'We would have created more chances',7),
  (v_lesson_id,'listening','What did you hear?','Lo más decepcionante no fue la derrota, sino la falta de actitud',array['Aunque tuviera más posesión','El gol del minuto sesenta','El punto de inflexión'],'The most disappointing thing wasn''t the defeat, but the lack of attitude',8),
  (v_lesson_id,'speaking','Say this aloud: "Un rendimiento por debajo de las expectativas."','Un rendimiento por debajo de las expectativas',array[]::text[],'A performance below expectations.',9),
  (v_lesson_id,'speaking','Say this aloud: "La victoria fue merecida."','La victoria fue merecida',array[]::text[],'The victory was deserved.',10);

  -- ===========================================================
  -- B2.15 ENVIRONMENTAL ISSUES
  -- ===========================================================
  select id into v_course_id from public.courses where language_id = v_lang_id and cefr_level = 'B2' and title = 'Environmental Issues';
  select id into v_l1 from public.lessons where course_id = v_course_id and order_index = 1;
  select id into v_l2 from public.lessons where course_id = v_course_id and order_index = 2;
  select id into v_l3 from public.lessons where course_id = v_course_id and order_index = 3;
  select id into v_l4 from public.lessons where course_id = v_course_id and order_index = 4;
  select id into v_l5 from public.lessons where course_id = v_course_id and order_index = 5;
  select id into v_l6 from public.lessons where course_id = v_course_id and order_index = 6;
  select id into v_l7 from public.lessons where course_id = v_course_id and order_index = 7;
  select id into v_l8 from public.lessons where course_id = v_course_id and order_index = 8;

  update public.lessons set
    intro='Climate change vocabulary: "el cambio climático", "el calentamiento global", "el efecto invernadero". Essential terms for environmental discourse.',
    vocab_items='[{"spanish":"el cambio climático","english":"climate change"},{"spanish":"el calentamiento global","english":"global warming"},{"spanish":"el efecto invernadero","english":"greenhouse effect"},{"spanish":"el carbono","english":"carbon"},{"spanish":"las emisiones","english":"emissions"},{"spanish":"el dióxido de carbono","english":"CO2"},{"spanish":"el combustible fósil","english":"fossil fuel"},{"spanish":"el deshielo","english":"melting (ice)"},{"spanish":"la sequía","english":"drought"},{"spanish":"la inundación","english":"flood"}]'::jsonb,
    dialogue='[{"speaker":"Científico","spanish":"Si no reducimos las emisiones, el calentamiento global se acelerará.","english":"If we don''t reduce emissions, global warming will accelerate."}]'::jsonb,
    grammar_note='First conditional (real future): "si no reducimos, se acelerará". For likely or possible futures, use present + future indicative.'
  where id = v_l1;

  update public.lessons set
    intro='Pollution and contamination: air, water, soil. Spanish "la contaminación" is the master term.',
    vocab_items='[{"spanish":"la contaminación","english":"pollution"},{"spanish":"contaminar","english":"to pollute"},{"spanish":"el contaminante","english":"pollutant"},{"spanish":"el aire","english":"air"},{"spanish":"el agua","english":"water"},{"spanish":"el suelo","english":"soil"},{"spanish":"el vertido","english":"spill"},{"spanish":"los residuos","english":"waste"},{"spanish":"tóxico","english":"toxic"},{"spanish":"perjudicial","english":"harmful"}]'::jsonb,
    dialogue='[{"speaker":"Activista","spanish":"Es vital que se regule el vertido de residuos tóxicos.","english":"It is vital that the spill of toxic waste be regulated."}]'::jsonb,
    grammar_note='"Es vital/importante/necesario que + subjunctive" = "it is vital/important/necessary that...". Always subjunctive after impersonal expressions of necessity.'
  where id = v_l2;

  update public.lessons set
    intro='Biodiversity and conservation: species, habitats, ecosystems. "La biodiversidad" is the cornerstone term.',
    vocab_items='[{"spanish":"la biodiversidad","english":"biodiversity"},{"spanish":"el ecosistema","english":"ecosystem"},{"spanish":"el hábitat","english":"habitat"},{"spanish":"la especie","english":"species"},{"spanish":"en peligro de extinción","english":"endangered"},{"spanish":"proteger","english":"to protect"},{"spanish":"la conservación","english":"conservation"},{"spanish":"la reserva natural","english":"nature reserve"},{"spanish":"el parque nacional","english":"national park"},{"spanish":"la fauna","english":"fauna"}]'::jsonb,
    dialogue='[{"speaker":"Bióloga","spanish":"El lince ibérico, en peligro de extinción, ha sido objeto de un programa de recuperación.","english":"The Iberian lynx, endangered, has been the subject of a recovery program."}]'::jsonb,
    grammar_note='"Ser objeto de + noun" = "to be the subject of + noun". Formal passive equivalent: "ha sido objeto de un programa" = "has been subject to a program".'
  where id = v_l3;

  update public.lessons set
    intro='Renewable energy: solar, wind, hydro. Spain is a leader in renewables.',
    vocab_items='[{"spanish":"la energía renovable","english":"renewable energy"},{"spanish":"la energía solar","english":"solar energy"},{"spanish":"la energía eólica","english":"wind energy"},{"spanish":"la energía hidráulica","english":"hydroelectric energy"},{"spanish":"el panel solar","english":"solar panel"},{"spanish":"el aerogenerador","english":"wind turbine"},{"spanish":"la red eléctrica","english":"electrical grid"},{"spanish":"sostenible","english":"sustainable"},{"spanish":"la transición energética","english":"energy transition"},{"spanish":"limpio","english":"clean"}]'::jsonb,
    dialogue='[{"speaker":"Ingeniera","spanish":"España ya genera más del cincuenta por ciento de su electricidad a partir de renovables.","english":"Spain already generates more than fifty percent of its electricity from renewables."}]'::jsonb,
    grammar_note='"A partir de + noun" = "starting from / based on + noun". Common in technical and economic Spanish: "a partir de renovables", "a partir de datos".'
  where id = v_l4;

  update public.lessons set
    intro='Activism and policy: protests, agreements, regulations. The vocabulary of environmental action.',
    vocab_items='[{"spanish":"el activismo","english":"activism"},{"spanish":"la protesta","english":"protest"},{"spanish":"manifestarse","english":"to demonstrate"},{"spanish":"el acuerdo","english":"agreement"},{"spanish":"la regulación","english":"regulation"},{"spanish":"la política ambiental","english":"environmental policy"},{"spanish":"el impuesto al carbono","english":"carbon tax"},{"spanish":"el desarrollo sostenible","english":"sustainable development"},{"spanish":"la concienciación","english":"awareness"},{"spanish":"movilizarse","english":"to mobilize"}]'::jsonb,
    dialogue='[{"speaker":"Activista","spanish":"Es hora de que los gobiernos actúen con la urgencia que esto exige.","english":"It''s time for governments to act with the urgency this demands."}]'::jsonb,
    grammar_note='"Es hora de que + subjunctive" = "it''s time + clause": "es hora de que actúen". Variant of "ya va siendo hora" — both require subjunctive.'
  where id = v_l5;

  update public.lessons set
    intro='Listen to an environmental documentary segment. Hear how scientists describe climate impact.',
    vocab_items='[{"spanish":"el documental","english":"documentary"},{"spanish":"el impacto","english":"impact"},{"spanish":"alarmante","english":"alarming"},{"spanish":"irreversible","english":"irreversible"},{"spanish":"el ritmo","english":"pace"},{"spanish":"acelerar","english":"to accelerate"},{"spanish":"frenar","english":"to slow/stop"}]'::jsonb,
    dialogue='[{"speaker":"Narrador","spanish":"El ritmo del deshielo es alarmante: si no frenamos las emisiones, los efectos serán irreversibles.","english":"The pace of melting is alarming: if we don''t slow emissions, the effects will be irreversible."},{"speaker":"Narrador","spanish":"De seguir así, perderemos especies que jamás recuperaremos.","english":"If things continue this way, we will lose species we will never recover."}]'::jsonb,
    grammar_note='"De + infinitive" = condition equivalent to "si + clause": "de seguir así" = "si seguimos así". A more elegant, literary alternative to "si".'
  where id = v_l6;

  update public.lessons set
    intro='Write an opinion piece on climate change. Take a position, support with evidence, propose action.',
    vocab_items='[{"spanish":"el llamamiento","english":"call (to action)"},{"spanish":"reclamar","english":"to demand"},{"spanish":"la responsabilidad","english":"responsibility"},{"spanish":"la urgencia","english":"urgency"},{"spanish":"la solución","english":"solution"},{"spanish":"el reto","english":"challenge"},{"spanish":"afrontar","english":"to face"},{"spanish":"posponer","english":"to postpone"}]'::jsonb,
    dialogue='[{"speaker":"Opinión","spanish":"El cambio climático es el mayor reto de nuestra generación. No podemos seguir posponiendo decisiones.","english":"Climate change is the greatest challenge of our generation. We cannot keep postponing decisions."},{"speaker":"Opinión","spanish":"Es imprescindible que actuemos ya, con la valentía que el momento exige.","english":"It is essential that we act now, with the courage the moment demands."}]'::jsonb,
    grammar_note='"Es imprescindible que + subjunctive" reinforces yet another impersonal expression of necessity. "Imprescindible" is stronger than "necesario".'
  where id = v_l7;

  delete from public.exercises where lesson_id in (v_l1, v_l2, v_l3, v_l4, v_l5, v_l6, v_l7);
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'multiple_choice','What is "global warming"?','el calentamiento global',array['el cambio climático','el efecto invernadero','el clima global'],'global warming',1),
  (v_l1,'multiple_choice','What is "drought"?','la sequía',array['la sequedad','la inundación','la helada'],'drought',2),
  (v_l1,'fill_blank','Complete: "Si no ____ las emisiones, se acelerará." (we reduce)','reducimos',array['reduciríamos','reduciéramos','reducir'],'reduce',3),
  (v_l1,'multiple_choice','What is "fossil fuel"?','el combustible fósil',array['el combustible solar','el combustible natural','el combustible verde'],'fossil fuel',4),
  (v_l1,'multiple_choice','What does "deshielo" mean?','melting (ice)',array['hailing','hardening','heating'],'melting ice',5),
  (v_l2,'multiple_choice','What is "spill"?','el vertido',array['el vertedero','el verso','el vertigo'],'spill',1),
  (v_l2,'multiple_choice','What does "perjudicial" mean?','harmful',array['perfect','peculiar','perpendicular'],'harmful',2),
  (v_l2,'fill_blank','Complete: "Es vital que se ____ el vertido." (regulates — subj)','regule',array['regula','reguló','regulará'],'regulates (subj)',3),
  (v_l2,'multiple_choice','What is "pollutant"?','el contaminante',array['el contaminado','el contagiado','el conteniente'],'pollutant',4),
  (v_l2,'multiple_choice','What does "tóxico" mean?','toxic',array['toxic (only chem)','tropical','tactile'],'toxic',5),
  (v_l3,'multiple_choice','What is "endangered"?','en peligro de extinción',array['en pérdida de población','en peligro absoluto','en riesgo total'],'endangered',1),
  (v_l3,'multiple_choice','What is "nature reserve"?','la reserva natural',array['el parque natural','la reserva nacional','la zona protegida'],'nature reserve',2),
  (v_l3,'fill_blank','Complete: "Ha sido ____ de un programa." (subject)','objeto',array['sujeto','tema','asunto'],'subject',3),
  (v_l3,'multiple_choice','What is "habitat"?','el hábitat',array['la habitación','el hábito','el habitante'],'habitat',4),
  (v_l3,'multiple_choice','What is "fauna"?','la fauna',array['la flora','la fanfarria','la falda'],'fauna',5),
  (v_l4,'multiple_choice','What is "wind energy"?','la energía eólica',array['la energía solar','la energía hidráulica','la energía nuclear'],'wind energy',1),
  (v_l4,'multiple_choice','What is "wind turbine"?','el aerogenerador',array['el aeroplano','el aeropuerto','el aerodinámico'],'wind turbine',2),
  (v_l4,'fill_blank','Complete: "____ partir de renovables." (starting from)','A',array['De','En','Por'],'starting from',3),
  (v_l4,'multiple_choice','What is "electrical grid"?','la red eléctrica',array['la red de cables','la red distribuidora','la red conectada'],'grid',4),
  (v_l4,'multiple_choice','What does "limpio" mean here?','clean',array['cleanly','clear','climate'],'clean',5),
  (v_l5,'multiple_choice','What does "manifestarse" mean?','to demonstrate',array['to manifest','to maintain','to maneuver'],'to demonstrate',1),
  (v_l5,'multiple_choice','What is "carbon tax"?','el impuesto al carbono',array['el impuesto del carbono','el impuesto verde','el impuesto sucio'],'carbon tax',2),
  (v_l5,'fill_blank','Complete: "Es hora de que los gobiernos ____" (act — subj)','actúen',array['actúan','actuaron','actuarán'],'act (subj)',3),
  (v_l5,'multiple_choice','What is "awareness"?','la concienciación',array['la conciencia (synonym)','la conclusión','la confirmación'],'awareness',4),
  (v_l5,'multiple_choice','What does "movilizarse" mean?','to mobilize (oneself)',array['to mobilize others','to be mobile','to move'],'to mobilize',5),
  (v_l6,'multiple_choice','What does "alarmante" mean?','alarming',array['alarmed','aligned','alleged'],'alarming',1),
  (v_l6,'multiple_choice','What does "frenar" mean?','to slow/stop',array['to free','to fright','to flee'],'to slow',2),
  (v_l6,'fill_blank','Complete: "____ seguir así, perderemos especies." (If)','De',array['Si','En','Con'],'if (de + inf)',3),
  (v_l6,'multiple_choice','What does "irreversible" mean?','irreversible',array['irregular','irritable','irrelevant'],'irreversible',4),
  (v_l6,'multiple_choice','What does "acelerar" mean?','to accelerate',array['to accept','to access','to accuse'],'to accelerate',5),
  (v_l7,'multiple_choice','What does "imprescindible" mean?','essential',array['important','impressive','impossible'],'essential',1),
  (v_l7,'multiple_choice','What is "challenge"?','el reto',array['el resto','el retiro','el reposo'],'challenge',2),
  (v_l7,'fill_blank','Complete: "Es imprescindible que ____ ya." (we act — subj)','actuemos',array['actuamos','actuábamos','actuaremos'],'we act (subj)',3),
  (v_l7,'multiple_choice','What does "posponer" mean?','to postpone',array['to position','to possess','to potentiate'],'to postpone',4),
  (v_l7,'multiple_choice','What does "valentía" mean?','courage',array['validity','valuation','vacancy'],'courage',5);

  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l1,'listening','What did you hear?','Si no reducimos las emisiones, el calentamiento global se acelerará',array['El deshielo es alarmante','La sequía afecta el sur','La inundación destruyó cosechas'],'If we don''t reduce emissions, global warming will accelerate',6),
  (v_l1,'listening','What did you hear?','el calentamiento global se acelerará',array['la temperatura descenderá','el clima cambiará','el deshielo continuará'],'global warming will accelerate',7),
  (v_l1,'speaking','Say this aloud: "Si no reducimos las emisiones."','Si no reducimos las emisiones',array[]::text[],'If we don''t reduce emissions.',8),
  (v_l1,'speaking','Say this aloud: "El calentamiento global se acelerará."','El calentamiento global se acelerará',array[]::text[],'Global warming will accelerate.',9),
  (v_l2,'listening','What did you hear?','Es vital que se regule el vertido de residuos tóxicos',array['Es necesaria la educación','El aire está contaminado','El suelo es perjudicial'],'It is vital that the spill of toxic waste be regulated',6),
  (v_l2,'listening','What did you hear?','el vertido de residuos tóxicos',array['la contaminación del aire','las emisiones de carbono','los combustibles fósiles'],'the spill of toxic waste',7),
  (v_l2,'speaking','Say this aloud: "Es vital que se regule el vertido."','Es vital que se regule el vertido',array[]::text[],'It is vital that the spill be regulated.',8),
  (v_l2,'speaking','Say this aloud: "Los residuos son perjudiciales."','Los residuos son perjudiciales',array[]::text[],'Waste is harmful.',9),
  (v_l3,'listening','What did you hear?','El lince ibérico, en peligro de extinción, ha sido objeto de un programa de recuperación',array['La biodiversidad disminuye','El ecosistema se altera','La reserva natural está protegida'],'The Iberian lynx, endangered, has been the subject of a recovery program',6),
  (v_l3,'listening','What did you hear?','ha sido objeto de un programa de recuperación',array['ha sido cazado en exceso','ha sido protegido por ley','ha sido relocado de área'],'has been the subject of a recovery program',7),
  (v_l3,'speaking','Say this aloud: "El lince ibérico está en peligro de extinción."','El lince ibérico está en peligro de extinción',array[]::text[],'The Iberian lynx is endangered.',8),
  (v_l3,'speaking','Say this aloud: "Ha sido objeto de un programa de recuperación."','Ha sido objeto de un programa de recuperación',array[]::text[],'It has been the subject of a recovery program.',9),
  (v_l6,'listening','What did you hear?','El ritmo del deshielo es alarmante',array['si no frenamos las emisiones','los efectos serán irreversibles','perderemos especies'],'The pace of melting is alarming',6),
  (v_l6,'listening','What did you hear?','De seguir así, perderemos especies que jamás recuperaremos',array['Si frenamos a tiempo','El planeta se enfriará','La biodiversidad volverá'],'If things continue this way, we will lose species we will never recover',7),
  (v_l6,'speaking','Say this aloud: "De seguir así, perderemos especies."','De seguir así, perderemos especies',array[]::text[],'If things continue this way, we will lose species.',8),
  (v_l6,'speaking','Say this aloud: "El ritmo del deshielo es alarmante."','El ritmo del deshielo es alarmante',array[]::text[],'The pace of melting is alarming.',9),
  (v_l7,'listening','What did you hear?','El cambio climático es el mayor reto de nuestra generación',array['No podemos seguir posponiendo','Es imprescindible que actuemos','La valentía es necesaria'],'Climate change is the greatest challenge of our generation',6),
  (v_l7,'listening','What did you hear?','Es imprescindible que actuemos ya, con la valentía que el momento exige',array['El cambio climático es el reto','No podemos posponer','La responsabilidad es global'],'It is essential that we act now, with the courage the moment demands',7),
  (v_l7,'speaking','Say this aloud: "Es imprescindible que actuemos ya."','Es imprescindible que actuemos ya',array[]::text[],'It is essential that we act now.',8),
  (v_l7,'speaking','Say this aloud: "Con la valentía que el momento exige."','Con la valentía que el momento exige',array[]::text[],'With the courage the moment demands.',9);

  update public.lessons set type='conversation', title='Environmental Issues — Conversation Practice',
    description='Two activists discuss climate policy.',
    intro='Elena and Mateo meet at a climate forum.',
    vocab_items='[]'::jsonb, grammar_note=null,
    dialogue='[{"speaker":"Elena","spanish":"¿Has visto los datos del último informe sobre emisiones?","english":"Have you seen the data from the latest emissions report?"},{"speaker":"Mateo","spanish":"Sí. El ritmo del calentamiento es alarmante. De seguir así, los efectos serán irreversibles.","english":"Yes. The pace of warming is alarming. If things continue this way, the effects will be irreversible."},{"speaker":"Elena","spanish":"Es hora de que los gobiernos actúen con la urgencia que esto exige.","english":"It''s time for governments to act with the urgency this demands."},{"speaker":"Mateo","spanish":"Si no reducimos las emisiones, perderemos especies que jamás recuperaremos.","english":"If we don''t reduce emissions, we''ll lose species we will never recover."},{"speaker":"Elena","spanish":"Lo más urgente no es esperar acuerdos, sino movilizarnos ya.","english":"The most urgent thing isn''t to wait for agreements, but to mobilize now."},{"speaker":"Mateo","spanish":"De acuerdo. Es imprescindible que cada uno asuma su responsabilidad.","english":"Agreed. It is essential that each one assume their responsibility."}]'::jsonb
  where id = v_l8;
  delete from public.exercises where lesson_id = v_l8;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_l8,'multiple_choice','What did Elena and Mateo discuss?','The latest emissions report',array['A new agreement','A protest','A documentary'],'el último informe sobre emisiones',1),
  (v_l8,'multiple_choice','Mateo''s warning?','If things continue this way, effects will be irreversible',array['Things will improve','Everything is fine','Reports are exaggerated'],'los efectos serán irreversibles',2),
  (v_l8,'multiple_choice','What does Elena demand of governments?','Act with urgency',array['Cut taxes','Build more grids','Wait for consensus'],'actúen con urgencia',3),
  (v_l8,'multiple_choice','Mateo on biodiversity?','Lose species we''ll never recover',array['Species will adapt','Conservation is enough','Animals can migrate'],'perderemos especies',4),
  (v_l8,'fill_blank','Complete: "Es hora de que ____ con urgencia." (act — subj)','actúen',array['actúan','actuaron','actuarán'],'act (subj)',5),
  (v_l8,'multiple_choice','Elena''s proposal?','Mobilize now, don''t wait for agreements',array['Wait for international consensus','Trust governments','Stay silent'],'movilizarnos ya',6);

  delete from public.lessons where course_id = v_course_id and order_index = 9;
  insert into public.lessons (course_id, title, description, type, order_index, xp_reward)
  values (v_course_id, 'Section Test: Environmental Issues', 'Review test for the Environmental Issues section. Pass with 7 or more out of 10 to earn 50 XP.', 'unit_test', 9, 50)
  returning id into v_lesson_id;
  insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, translation, order_index) values
  (v_lesson_id,'multiple_choice','What is "global warming"?','el calentamiento global',array['el cambio climático','el efecto invernadero','el clima global'],'global warming',1),
  (v_lesson_id,'multiple_choice','What follows "es vital que"?','subjunctive',array['indicative','infinitive','imperative'],'es vital que + subj',2),
  (v_lesson_id,'multiple_choice','What is "endangered"?','en peligro de extinción',array['en pérdida de población','en peligro absoluto','en riesgo total'],'endangered',3),
  (v_lesson_id,'multiple_choice','What does "de + infinitive" express?','condition (= si + clause)',array['cause (= porque)','result (= entonces)','time (= cuando)'],'de + inf condition',4),
  (v_lesson_id,'fill_blank','Complete: "Es hora de que ____" (we act — subj)','actuemos',array['actuamos','actuábamos','actuaremos'],'we act (subj)',5),
  (v_lesson_id,'fill_blank','Complete: "____ seguir así, perderemos especies." (If — formal)','De',array['Si','Por','Con'],'if (de + inf)',6),
  (v_lesson_id,'listening','What did you hear?','El ritmo del deshielo es alarmante',array['Las emisiones bajaron','Los acuerdos avanzan','La biodiversidad mejora'],'The pace of melting is alarming',7),
  (v_lesson_id,'listening','What did you hear?','Es imprescindible que actuemos ya',array['Las emisiones siguen','Los gobiernos negocian','La ciudadanía es pasiva'],'It is essential that we act now',8),
  (v_lesson_id,'speaking','Say this aloud: "Es hora de que actúen los gobiernos."','Es hora de que actúen los gobiernos',array[]::text[],'It''s time for governments to act.',9),
  (v_lesson_id,'speaking','Say this aloud: "Es imprescindible que actuemos ya."','Es imprescindible que actuemos ya',array[]::text[],'It is essential that we act now.',10);

end $$;

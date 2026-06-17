-- 047_french_exercises.sql
-- Seed every French lesson with type-homogeneous, AI-graded exercises so the
-- course behaves identically to Spanish (after migrations 039/044/045).
-- Listening / speaking / writing exercises wire through the existing
-- /api/grade-lesson-response route, exactly as Spanish does — the route is
-- language-agnostic (it accepts the language slug in the body), so no
-- backend changes are needed.
--
-- Per lesson type, this migration inserts:
--   vocabulary lessons: 6 exercises (4 MC + 2 fill_blank) + 4 extra
--                       fillers at order_index >= 200 → ~10 total
--   grammar lessons:    6 exercises (4 MC + 2 fill_blank) + 4 fillers
--   phrases lessons:    4 dialogue fill_blank + 3 fillers
--   listening lessons:  3 MC listening + 1 typed-response + 2 fillers
--   speaking lessons:   2 repeat-phrase + 2 topic monologue + 2 fillers
--   reading lessons:    3 comprehension MC (passage embedded in question)
--                       + 1 extra MC at order_index 200
--   writing lessons:    3 writing prompts + 1 extra at order_index 200
--   unit_test lessons:  10 mixed MC + fill_blank
--
-- Levels A1 through C1 use level-tier templates. Per-section themes are
-- carried by the lesson title and the teaching content from 046; the
-- exercise pool is uniformly templated per (level, lesson_type), mirroring
-- the Spanish 044/045 approach.
--
-- Idempotent: re-running wipes and reseeds every exercise for French lessons.

do $$
declare
  v_lang_id   bigint;
begin
  select id into v_lang_id from public.languages where code = 'french';
  if v_lang_id is null then raise exception 'French language not found'; end if;

  -- Wipe every exercise belonging to a French lesson.
  delete from public.exercises e
  using public.lessons l, public.courses c
  where e.lesson_id = l.id
    and l.course_id = c.id
    and c.language_id = v_lang_id;
end $$;

-- ============== Seed fresh exercises ==============
do $$
declare
  v_lang_id   bigint;
  v_lesson_id bigint;
  v_level     text;
  i           int;

  -- =================================================================
  -- PER-LEVEL CONTENT TEMPLATES
  -- =================================================================

  ---------- LISTENING ----------
  a1_listen_mc_q text[]   := array['What did you hear?','What greeting did you hear?','What did the speaker say?'];
  a1_listen_mc_a text[]   := array['Bonjour, comment ça va?','Je m’appelle Marie et j’ai vingt ans.','Il fait beau aujourd’hui.'];
  a1_listen_mc_w text[][] := array[
    array['Bonsoir, comment ça va?','Bonjour, comment tu vas?','Salut, comment ça va?'],
    array['Tu t’appelles Marie et tu as vingt ans.','Je m’appelle Pierre et j’ai vingt ans.','Je m’appelle Marie mais j’ai trente ans.'],
    array['Il fait froid aujourd’hui.','Il pleut aujourd’hui.','Il fera beau demain.']
  ];
  a1_listen_typed_q text := 'Parle-moi de ta routine quotidienne en quelques phrases.';
  a1_listen_typed_a text := 'Je me lève à sept heures, je prends mon petit-déjeuner et je vais au travail.';

  a2_listen_mc_q text[]   := array['What did you hear?','What did the speaker ask?','What did the speaker say?'];
  a2_listen_mc_a text[]   := array['Hier, je suis allé au cinéma avec mes amis.','Qu’est-ce que tu as fait le week-end dernier?','Ma famille habite dans une grande maison avec un jardin.'];
  a2_listen_mc_w text[][] := array[
    array['Demain, j’irai au cinéma avec mes amis.','Hier, j’ai vu un film à la maison.','Hier, je suis allé au théâtre avec ma famille.'],
    array['Qu’est-ce que tu feras le week-end prochain?','Où es-tu allé le week-end dernier?','Avec qui as-tu passé le week-end?'],
    array['Ma famille habite dans un petit appartement sans jardin.','Mon amie habite dans une grande maison avec un jardin.','Ma famille habitait dans une maison à la campagne.']
  ];
  a2_listen_typed_q text := 'Raconte-moi ce que tu as fait hier et comment tu te sentais en fin de journée.';
  a2_listen_typed_a text := 'Hier j’ai travaillé toute la journée, puis je suis allé courir. En fin de journée j’étais fatigué mais content.';

  b1_listen_mc_q text[]   := array['What did you hear?','What opinion did the speaker express?','What was the speaker’s main point?'];
  b1_listen_mc_a text[]   := array['Cependant, je préfère vivre à la campagne plutôt qu’en ville.','À mon avis, les réseaux sociaux ont profondément changé nos vies.','Si j’avais plus de temps, je voyagerais à travers toute l’Amérique du Sud.'];
  b1_listen_mc_w text[][] := array[
    array['Cependant, je préfère vivre en ville plutôt qu’à la campagne.','Comme j’aime la ville, je vis à la campagne.','Bien que j’aime la ville, je n’y vis pas.'],
    array['À mon avis, les réseaux sociaux n’ont rien changé.','Je pense que les réseaux sociaux nous changeront bientôt.','Les réseaux sociaux n’affectent guère notre quotidien.'],
    array['Si j’ai plus de temps, je voyage en Amérique du Sud.','Quand j’avais plus de temps, j’ai voyagé en Amérique du Sud.','Bien que j’aie plus de temps, je ne voyagerais pas.']
  ];
  b1_listen_typed_q text := 'Bien que j’adore voyager, cette année j’ai décidé de rester chez moi pour économiser. Qu’en penses-tu?';
  b1_listen_typed_a text := 'Cela me paraît raisonnable; économiser maintenant te donnera plus de liberté plus tard. Je ferais la même chose à ta place.';

  b2_listen_mc_q text[]   := array['What did you hear?','What attitude does the speaker show?','What argument did the speaker make?'];
  b2_listen_mc_a text[]   := array['Toutefois, malgré les avancées, des inégalités sociales importantes persistent.','Soulignons que l’éducation publique demeure la base de toute démocratie en bonne santé.','Si nous avions agi plus tôt, nous aurions évité la majeure partie de la crise environnementale.'];
  b2_listen_mc_w text[][] := array[
    array['Grâce aux avancées, les inégalités ont disparu.','Les avancées ne touchent qu’une minorité privilégiée.','Sans avancées, il n’y aurait pas d’inégalités.'],
    array['L’éducation privée est la base de toute démocratie.','L’éducation n’a guère d’incidence sur la démocratie.','Seule l’éducation universitaire compte pour la démocratie.'],
    array['Si nous agissons maintenant, nous éviterons la crise.','Bien que nous ayons agi, la crise était inévitable.','Si nous agissions tôt, nous éviterions la prochaine crise.']
  ];
  b2_listen_typed_q text := 'Certains experts affirment que l’enseignement à distance est là pour durer; d’autres pensent que ce n’est qu’une parenthèse. Quelle est votre position?';
  b2_listen_typed_a text := 'Je pense qu’il est là pour durer, toutefois il a besoin de réformes profondes. Soulignons que l’enseignement présentiel reste essentiel à la dimension sociale de l’apprentissage.';

  c1_listen_mc_q text[]   := array['What did you hear?','What rhetorical move did the speaker make?','What implicit claim does this contain?'];
  c1_listen_mc_a text[]   := array['Il convient de souligner que, loin d’être marginale, la désinformation est devenue structurelle.','De même, aucune loi, aussi stricte soit-elle, ne saurait remplacer le discernement du citoyen.','Si elle avait été adoptée à l’époque, cette réforme aurait profondément modifié le système éducatif.'];
  c1_listen_mc_w text[][] := array[
    array['Il convient de nier que la désinformation soit marginale.','La désinformation reste un phénomène marginal sans importance.','Il convient de souligner que la désinformation n’est que conjoncturelle.'],
    array['Toute loi stricte remplace le discernement du citoyen.','Le discernement du citoyen ne doit jamais remplacer la loi.','Aucune loi n’est nécessaire si le citoyen a du discernement.'],
    array['Si elle avait été rejetée à l’époque, le système se serait amélioré.','Adoptée à l’époque, la réforme n’aurait rien changé.','Si elle est adoptée maintenant, la réforme transformera le système.']
  ];
  c1_listen_typed_q text := 'Une universitaire affirme que la liberté académique se mesure à ce qu’un État permet de publier sur lui, non à ce qu’il prétend tolérer. Comment interprétez-vous sa nuance?';
  c1_listen_typed_a text := 'Elle suggère que la liberté déclarée importe peu si la liberté effective est conditionnée. Toutefois, sa comparaison réduit la liberté académique au seul critère gouvernemental, négligeant d’autres facteurs institutionnels qui la limitent également.';

  ---------- SPEAKING ----------
  a1_speak_repeat_phrases text[] := array['Bonjour, je m’appelle Marie et je suis française.','J’ai vingt ans et j’habite à Paris avec ma famille.'];
  a1_speak_topics         text[] := array['Greet someone and introduce yourself. Speak two short French sentences.','Talk about your daily routine in two short French sentences.'];

  a2_speak_repeat_phrases text[] := array['Hier, je suis allé au supermarché et j’ai acheté du pain et du lait.','Ma famille est grande et nous habitons dans une maison avec un jardin.'];
  a2_speak_topics         text[] := array['Describe what you did last weekend. Three sentences in French, using past tense (passé composé).','Talk about your typical morning routine. Three sentences in French.'];

  b1_speak_repeat_phrases text[] := array['Bien que j’aime beaucoup voyager, cette année je préfère rester pour économiser pour l’avenir.','Si j’avais plus de temps libre, j’apprendrais à jouer du piano et je ferais davantage de sport.'];
  b1_speak_topics         text[] := array['Talk about a goal you want to achieve in the next year. Four sentences with an opinion.','Describe a place you would like to visit and why. Four sentences using conditional or future tense.'];

  b2_speak_repeat_phrases text[] := array['Toutefois, malgré les progrès, des inégalités persistent; soulignons que l’éducation reste la clé pour les réduire.','Si nous avions agi plus tôt, nous aurions évité la majeure partie de la crise; par conséquent, planifions désormais à long terme.'];
  b2_speak_topics         text[] := array['Argue for or against a social policy you care about. Five French sentences using toutefois or néanmoins and subjunctive where appropriate.','Discuss a current global issue and propose a solution. Five sentences using par conséquent or soulignons que.'];

  c1_speak_repeat_phrases text[] := array['Il convient de souligner que, loin d’être un phénomène marginal, la désinformation s’est imposée comme structure systémique du débat public.','Si elle avait été adoptée à l’époque, cette réforme aurait profondément modifié le système et anticipé des débats que nous repoussons aujourd’hui encore.'];
  c1_speak_topics         text[] := array['Critically analyse a current geopolitical issue and its long-term implications. Six to eight French sentences with advanced connectors and subjunctive.','Discuss whether artificial intelligence will reshape the humanities, defending a clear stance. Six to eight sentences with rhetorical sophistication.'];

  ---------- WRITING ----------
  a1_writing_prompts text[] := array[
    'Write 2 short French sentences introducing yourself.',
    'Write 2 short French sentences about your family.',
    'Write 2 short French sentences about what you do every morning.'
  ];
  a2_writing_prompts text[] := array[
    'Write 3 French sentences about what you did last weekend, using passé composé.',
    'Write 3 French sentences comparing your weekday and weekend routines.',
    'Write a 3-sentence email inviting a friend to dinner this Saturday.'
  ];
  b1_writing_prompts text[] := array[
    'Write 4 French sentences giving your opinion on remote work. Include at least one connector (cependant / de plus / parce que).',
    'Write 4 French sentences about a goal you have for the next year, using future tense.',
    'Write 4 French sentences comparing two cities or countries you know.'
  ];
  b2_writing_prompts text[] := array[
    'Write 5 French sentences debating a current social issue. Use subjunctive and at least one connector (toutefois / par conséquent / soulignons que).',
    'Write 5 French sentences arguing for or against a proposed policy. Acknowledge a counterargument.',
    'Write 5 French sentences analysing the long-term effects of a recent change in your country. Use sophisticated vocabulary.'
  ];
  c1_writing_prompts text[] := array[
    'Write 7-8 French sentences critically analysing a current global issue. Use subjunctive, conditional past (j’aurais + past participle) and at least two advanced connectors.',
    'Write 7-8 French sentences in formal register on the ethics of a contemporary technology. Use nonobstant, de même and il convient de.',
    'Write 7-8 French sentences arguing what would have happened had a major historical event unfolded differently. Use subjunctive and conditional past throughout.'
  ];

  ---------- READING ----------
  a1_reading_q text[]   := array['Quel âge a Sophie?','Comment Sophie va-t-elle au travail?','Que fait Sophie le week-end?'];
  a1_reading_a text[]   := array['Vingt-cinq ans','En bus','Elle rend visite à ses parents'];
  a1_reading_w text[][] := array[
    array['Quinze ans','Trente ans','Cinquante ans'],
    array['En voiture','À pied','En train'],
    array['Elle voyage à l’étranger','Elle travaille','Elle étudie']
  ];

  a2_reading_q text[]   := array['Pourquoi le protagoniste a-t-il changé de travail?','Comment est la nouvelle entreprise?','Comment se sent-il maintenant?'];
  a2_reading_a text[]   := array['Parce qu’il s’ennuyait','Internationale, avec des voyages','Content car il a appris beaucoup'];
  a2_reading_w text[][] := array[
    array['Parce qu’il gagnait peu','Parce qu’il a déménagé','Parce qu’il s’est disputé'],
    array['Petite et locale','Très stricte et ennuyeuse','Familiale et minuscule'],
    array['Stressé et triste','Indifférent','Déçu']
  ];

  b1_reading_q text[]   := array['Pourquoi de nombreux jeunes partent-ils à l’étranger?','Qu’est-ce qui inquiète les experts?','Que font certains gouvernements en réponse?'];
  b1_reading_a text[]   := array['Ils cherchent de meilleurs salaires et de nouvelles cultures','Une perte de talents difficile à compenser','Ils proposent des incitations au retour'];
  b1_reading_w text[][] := array[
    array['Parce qu’ils ne trouvent pas de travail','Parce qu’ils ne veulent pas vivre avec leur famille','Parce que leurs universités l’imposent'],
    array['La concurrence entre les jeunes','Le manque d’intérêt pour les langues','La surcharge des universités'],
    array['Ils augmentent les impôts des émigrés','Ils interdisent de quitter le pays','Ils ne font rien']
  ];

  b2_reading_q text[]   := array['Comment certains artistes voient-ils l’IA générative?','Pourquoi le débat n’est-il pas seulement économique?','Que prédit l’auteur sur le débat?'];
  b2_reading_a text[]   := array['Comme un outil de plus, comparable à l’ordinateur','Parce qu’elle remet en cause l’idée d’auteur et d’originalité','Qu’il se prolongera longtemps'];
  b2_reading_w text[][] := array[
    array['Comme un remplacement définitif des artistes','Comme un effet de mode sans importance','Comme un outil hostile à interdire'],
    array['Parce qu’il concerne seulement les grands musées','Parce que les prix augmentent','Parce que la technologie est neutre'],
    array['Qu’il se résoudra rapidement','Qu’il perdra vite de l’intérêt','Qu’il aboutira à une régulation immédiate']
  ];

  c1_reading_q text[]   := array['Selon les défenseurs, quels avantages offre ce modèle?','Quel argument inattendu certains détracteurs ont-ils utilisé?','Quelle est, selon l’auteur, la nature du débat aujourd’hui?'];
  c1_reading_a text[]   := array['Moins d’émissions, meilleure santé et plus de sociabilité','Ils y voient une restriction déguisée des libertés','Il est culturel et symbolique, pas seulement technique'];
  c1_reading_w text[][] := array[
    array['Croissance économique et plus de véhicules privés','Plus de bureaux au centre et moins de parcs','Plus de gratte-ciels et moins de commerces locaux'],
    array['Ils le soutiennent sans réserve','Ils le jugent trop coûteux techniquement','Seuls les techniciens municipaux le critiquent'],
    array['Il est exclusivement technique','Il est exclusivement économique','Il est pratiquement clos en milieu universitaire']
  ];

  ---------- VOCABULARY fillers per level ----------
  a1_vocab_mc_q text[]   := array['What does "bonjour" mean?','What does "merci" mean?','Which French word means "house"?','Which French word means "friend"?'];
  a1_vocab_mc_a text[]   := array['hello','thank you','maison','ami'];
  a1_vocab_mc_w text[][] := array[
    array['goodbye','please','sorry'],
    array['hello','please','sorry'],
    array['voiture','livre','chaise'],
    array['frère','père','grand-père']
  ];
  a1_vocab_fb_q text[]   := array['Complete: "Le matin, je bois un ____" (coffee)','Complete: "J’ai deux ____" (siblings, plural)'];
  a1_vocab_fb_a text[]   := array['café','frères'];

  a2_vocab_mc_q text[]   := array['What does "déjeuner" mean?','What does "voyager" mean?','Which French word means "boss"?','Which French word means "weekend"?'];
  a2_vocab_mc_a text[]   := array['to have lunch','to travel','patron','week-end'];
  a2_vocab_mc_w text[][] := array[
    array['breakfast','dinner','snack'],
    array['to swim','to study','to write'],
    array['employé','voisin','client'],
    array['jour férié','vacances','semaine']
  ];
  a2_vocab_fb_q text[]   := array['Complete: "Mon frère ____ l’anglais à l’école." (teaches)','Complete: "J’achète du ____ et du lait au supermarché." (bread)'];
  a2_vocab_fb_a text[]   := array['enseigne','pain'];

  b1_vocab_mc_q text[]   := array['What does "cependant" mean?','What does "économiser" mean?','Which French word means "to plan"?','Which French word means "reliable"?'];
  b1_vocab_mc_a text[]   := array['however','to save (money)','planifier','fiable'];
  b1_vocab_mc_w text[][] := array[
    array['therefore','also','because'],
    array['to spend','to lend','to lose'],
    array['planter','plaisanter','plonger'],
    array['fier','famous','heureux']
  ];
  b1_vocab_fb_q text[]   := array['Complete: "Pour réussir, il faut ____ régulièrement." (study)','Complete: "Ma chef m’a ____ une augmentation." (granted)'];
  b1_vocab_fb_a text[]   := array['étudier','accordé'];

  b2_vocab_mc_q text[]   := array['What does "toutefois" mean?','What does "souligner" mean?','Which French word means "to undertake"?','Which French word means "regulation"?'];
  b2_vocab_mc_a text[]   := array['however','to emphasise','entreprendre','réglementation'];
  b2_vocab_mc_w text[][] := array[
    array['continuously','convincingly','therefore'],
    array['to ignore','to apologise','to forget'],
    array['enrichir','engager','encadrer'],
    array['règle','régulé','réguler']
  ];
  b2_vocab_fb_q text[]   := array['Complete: "Il convient de ____ que les conséquences sont graves." (emphasise)','Complete: "Le gouvernement a adopté la loi malgré l’____ de l’opposition." (opposition)'];
  b2_vocab_fb_a text[]   := array['souligner','opposition'];

  c1_vocab_mc_q text[]   := array['What does "nonobstant" mean?','What does "étayer" mean?','Which French phrase means "in light of"?','Which French phrase means "as a result of"?'];
  c1_vocab_mc_a text[]   := array['notwithstanding','to substantiate','à la lumière de','en raison de'];
  c1_vocab_mc_w text[][] := array[
    array['nonetheless (only)','despite (only)','because of'],
    array['to soak','to settle','to summon'],
    array['à cause de','par conséquent','soulignons que'],
    array['à la lumière de','grâce à','malgré']
  ];
  c1_vocab_fb_q text[]   := array['Complete: "Son discours fut si ____ qu’il dissipa tous les doutes." (forceful)','Complete: "Il convient de ____ chaque argument avec rigueur." (substantiate)'];
  c1_vocab_fb_a text[]   := array['percutant','étayer'];

  ---------- GRAMMAR fillers per level ----------
  a1_grammar_mc_q text[] := array[
    'Pick the correct article: "____ maison est belle."',
    'Pick the correct verb: "Je ____ français." (speak)',
    'Pick the correct verb: "Tu ____ heureux." (be — temporary)',
    'Pick the correct pronoun: "____ habite à Paris." (I)'
  ];
  a1_grammar_mc_a text[] := array['La','parle','es','J''']::text[];
  a1_grammar_mc_w text[][] := array[
    array['Le','Les','L'''],
    array['parles','parle','parlent'],
    array['est','êtes','sommes'],
    array['Tu','Il','Elle']
  ];
  a1_grammar_fb_q text[] := array['Complete: "Elle ____ étudiante." (is)','Complete: "Nous ____ à Paris." (live)'];
  a1_grammar_fb_a text[] := array['est','habitons'];

  a2_grammar_mc_q text[] := array[
    'Pick the correct passé composé: "Hier, je ____ au cinéma." (went)',
    'Pick the correct imperfect: "Quand j''étais petit, je ____ beaucoup." (played)',
    'Pick the correct form: "Nous allons ____ bientôt." (eat)',
    'Pick the reflexive: "Le matin, je ____ à sept heures." (wake up)'
  ];
  a2_grammar_mc_a text[] := array['suis allé','jouais','manger','me lève'];
  a2_grammar_mc_w text[][] := array[
    array['vais','allais','irai'],
    array['joue','jouerai','j’ai joué'],
    array['mangeons','mangé','mangeait'],
    array['lève','me levais','se lever']
  ];
  a2_grammar_fb_q text[] := array['Complete: "L’année dernière, j’ai ____ dans une entreprise internationale." (worked)','Complete: "Quand j’étais petit, mes parents ____ chaque jour." (worked, imperfect)'];
  a2_grammar_fb_a text[] := array['travaillé','travaillaient'];

  b1_grammar_mc_q text[] := array[
    'Pick the subjunctive: "Il faut que tu ____ tôt." (arrive)',
    'Pick the conditional: "Si j’avais le temps, je ____ plus." (would read)',
    'Pick the present perfect: "Cette semaine, j’____ trois examens." (have had)',
    'Pick the imperfect subjunctive: "Il fallait qu’on ____ silence." (keep)'
  ];
  b1_grammar_mc_a text[] := array['arrives','lirais','ai eu','garde'];
  b1_grammar_mc_w text[][] := array[
    array['arrive','arrivais','arriverais'],
    array['lirai','lirais (incorrect)','lisais'],
    array['avais','aurai','eus'],
    array['gardait','gardera','garder']
  ];
  b1_grammar_fb_q text[] := array['Complete: "Si j’____ plus de temps, je voyagerais." (had — imperfect)','Complete: "Je te recommande de ____ tôt." (arrive — infinitive)'];
  b1_grammar_fb_a text[] := array['avais','arriver'];

  b2_grammar_mc_q text[] := array[
    'Pick the right form: "Si j’avais étudié, j’____ réussi." (would have)',
    'Pick the right form: "Quand tu ____ les résultats, préviens-moi." (have — subjunctive)',
    'Pick the right form: "Bien qu’il ____ difficile, je le ferai." (it is — subjunctive)',
    'Pick the right form: "____ pouvoir voter dès 16 ans." (one should)'
  ];
  b2_grammar_mc_a text[] := array['aurais','aies','soit','Il faudrait'];
  b2_grammar_mc_w text[][] := array[
    array['avais','aurai','eusse'],
    array['as','auras','avais'],
    array['est','était','sera'],
    array['Il a fallu','Il faut','Il fallait']
  ];
  b2_grammar_fb_q text[] := array['Complete: "Quoi que tu ____, il ne changera pas d’avis." (do — subjunctive)','Complete: "Je ne suis pas surpris qu’il ____ en colère." (be — subjunctive)'];
  b2_grammar_fb_a text[] := array['fasses','soit'];

  c1_grammar_mc_q text[] := array[
    'Pick the past conditional: "Si je l’avais su, je ne ____ pas venu." (would have)',
    'Pick the right cleft form: "____ Jean qui l’a dit." (it is)',
    'Pick the right pronoun: "L’auteur ____ œuvre nous étudions." (whose)',
    'Pick the right concessive: "Quoi que tu ____, je ne céderai pas." (do — subjunctive)'
  ];
  c1_grammar_mc_a text[] := array['serais','C’est','dont','fasses'];
  c1_grammar_mc_w text[][] := array[
    array['eus','aurais','serai'],
    array['Est','Sera','Était'],
    array['que','dont (incorrect)','duquel'],
    array['fais','fasses (incorrect)','feras']
  ];
  c1_grammar_fb_q text[] := array['Complete: "____ l’avoir su, j’aurais agi autrement." (had / having)','Complete: "Loin d’____ négligeables, ces enjeux sont décisifs." (be — infinitive)'];
  c1_grammar_fb_a text[] := array['Pour','être'];

  ---------- PHRASES fillers per level ----------
  a1_phrases_q text[] := array[
    'Complete the dialogue: "A: Bonjour. B: ____, comment allez-vous?"',
    'Complete the dialogue: "A: Comment tu t’appelles? B: Je ____ Carlos."',
    'Complete the dialogue: "A: Merci. B: ____."'
  ];
  a1_phrases_a text[] := array['Bonjour','m’appelle','De rien'];

  a2_phrases_q text[] := array[
    'Complete the dialogue: "Médecin: Qu’est-ce que vous avez? Patient: J’ai mal à la ____" (head)',
    'Complete the dialogue: "Serveur: Autre chose? Client: Non, ____, merci."',
    'Complete the dialogue: "A: Je suis désolé. B: Ce n’est pas ____ , ne t’en fais pas."'
  ];
  a2_phrases_a text[] := array['tête','plus','grave'];

  b1_phrases_q text[] := array[
    'Complete the dialogue: "Réceptionniste: Combien de nuits? Client: ____ nuits, s’il vous plaît." (three)',
    'Complete the dialogue: "A: Dommage que tu ne puisses pas venir. B: ____ , ce sera pour la prochaine fois." (don’t worry)',
    'Complete the dialogue: "A: Comment s’est passé l’examen? B: ____ que bien, je suis satisfait." (I think)'
  ];
  b1_phrases_a text[] := array['Trois','Ne t’inquiète pas','Je pense'];

  b2_phrases_q text[] := array[
    'Complete: "Client: Je suis sans Internet depuis des jours. Agent: Je vous prie de ____ , nous allons régler ça." (forgive me — formal)',
    'Complete: "Directeur: Je veux vous féliciter. Employé: ____ à vous, monsieur." (thanks)',
    'Complete the formal dialogue: "Nous vous ____ de bien vouloir confirmer votre présence." (kindly ask — formal)'
  ];
  b2_phrases_a text[] := array['m’excuser','Merci','prions'];

  c1_phrases_q text[] := array[
    'Complete the formal dialogue: "Veuillez ____ votre présence dans les meilleurs délais." (confirm)',
    'Complete: "Il ____ de souligner l’importance de nuancer chaque argument." (is appropriate)',
    'Complete: "Permettez-moi d’____ . Bien que ce soit vrai, ne nous résignons pas pour autant." (object/disagree)'
  ];
  c1_phrases_a text[] := array['confirmer','convient','objecter'];

  ---------- UNIT TEST templates per level (10 mixed exercises) ----------
  a1_unit_q text[] := array[
    'How do you say "hello" in French?',
    'What is the French word for "house"?',
    'Complete: "Je ____ français." (speak)',
    'Pick the correct article: "____ pomme est rouge."',
    'Complete: "Mon père et ____ mère." (my, fem.)',
    'How do you say "thank you"?',
    'What does "matin" mean?',
    'Complete: "Il fait ____" (cold)',
    'Pick the correct verb: "Nous ____ à Paris." (live)',
    'What does "vendredi" mean?'
  ];
  a1_unit_a text[] := array['Bonjour','maison','parle','La','ma','Merci','morning','froid','habitons','Friday'];
  a1_unit_w text[][] := array[
    array['Au revoir','Salut','Merci'],
    array['voiture','livre','chien'],
    array['parles','parle (incorrect)','parlent'],
    array['Le','Les','Un'],
    array['mon','mes','la'],
    array['Salut','Pardon','De rien'],
    array['evening','night','noon'],
    array['chaud','beau','mauvais'],
    array['habite','habitent','habitez'],
    array['Monday','Tuesday','Wednesday']
  ];

  a2_unit_q text[] := array[
    'How do you say "yesterday" in French?',
    'What is the passé composé of "aller" (1st person sing)?',
    'Complete: "Quand j’étais petit, je ____ au foot." (play, imperfect)',
    'Pick the right form: "Il faut que je ____ tôt." (sleep — subjunctive)',
    'What does "déjeuner" mean?',
    'Complete: "Je me ____ à 7h." (wake up)',
    'How do you say "weekend"?',
    'Pick the right form: "Hier, nous ____ au cinéma." (went)',
    'What does "souvent" mean?',
    'Complete: "Si tu veux, on ____ ensemble." (go, present)'
  ];
  a2_unit_a text[] := array['hier','suis allé','jouais','dorme','to have lunch','lève','week-end','sommes allés','often','va'];
  a2_unit_w text[][] := array[
    array['demain','aujourd’hui','maintenant'],
    array['allais','irai','aille'],
    array['joue','ai joué','jouerai'],
    array['dors','dormais','dormirai'],
    array['breakfast','dinner','snack'],
    array['couche','douche','mange'],
    array['vacation','holiday','week'],
    array['allions','iront','sommes allé'],
    array['always','rarely','never'],
    array['allons','iront','vais']
  ];

  b1_unit_q text[] := array[
    'How do you say "however" in French?',
    'Pick the subjunctive: "Je veux que tu ____ tôt." (arrive)',
    'Complete: "Si j’avais plus de temps, je ____ plus." (would read)',
    'What does "économiser" mean?',
    'Pick the connector that means "moreover": "Il pleut. ____, on reste."',
    'Complete: "Quand j’____ fini, je sortirai." (have, futur antérieur)',
    'What does "fiable" mean?',
    'Pick the conditional: "Si je gagnais, j’____ une maison." (would buy)',
    'What does "désormais" mean?',
    'Complete: "Bien que tu ____ raison, écoute-moi." (have — subjunctive)'
  ];
  b1_unit_a text[] := array['cependant','arrives','lirais','to save (money)','De plus','aurai','reliable','achèterais','from now on','aies'];
  b1_unit_w text[][] := array[
    array['donc','aussi','parce que'],
    array['arrive','arrivais','arriveras'],
    array['lirai','lisais','lirais (incorrect)'],
    array['to lend','to spend','to borrow'],
    array['Mais','Donc','Parce que'],
    array['ai','avais','aurai (incorrect)'],
    array['fragile','flexible','frequent'],
    array['achète','acheter','acheté'],
    array['for now','before','at last'],
    array['as','avais','aies (incorrect)']
  ];

  b2_unit_q text[] := array[
    'How do you say "consequently" in French?',
    'Complete: "Toutefois, malgré les avancées, des inégalités ____" (persist)',
    'Pick the right form: "Si nous avions agi plus tôt, nous ____ évité la crise." (would have)',
    'What does "souligner" mean?',
    'Pick the subjunctive: "Bien que ce ____ difficile, je le ferai." (be)',
    'Complete: "____, soulignons les progrès accomplis." (However)',
    'What does "enjeu" mean?',
    'Pick the right form: "Il faudrait que les acteurs ____." (play — subjunctive)',
    'What does "durable" mean?',
    'Pick the conditional past: "Sans ton aide, je n’____ pas réussi." (would have)'
  ];
  b2_unit_a text[] := array['par conséquent','persistent','aurions','to emphasise','soit','Cependant','issue / stake','jouent','sustainable','aurais'];
  b2_unit_w text[][] := array[
    array['cependant','pourtant','néanmoins'],
    array['persistaient','persisteront','persistèrent'],
    array['avons','aurons','avons eu'],
    array['to ignore','to apologise','to forget'],
    array['est','sera','était'],
    array['Donc','Alors','Mais'],
    array['proof','agreement','consequence'],
    array['joue','jouent (incorrect)','joueront'],
    array['fragile','immediate','expensive'],
    array['avais','aurai','eus']
  ];

  c1_unit_q text[] := array[
    'How do you say "notwithstanding" in French?',
    'Complete: "Il ____ de souligner l’importance de ce sujet." (is appropriate)',
    'Pick the conditional past: "Si elle avait été adoptée, la réforme ____ tout changé." (would have)',
    'What does "étayer" mean?',
    'Pick the right form: "Loin d’____ négligeables, ces enjeux sont majeurs." (be — infinitive)',
    'Complete: "C’est Marie ____ a tout organisé." (who — relative)',
    'What does "prépondérant" mean?',
    'Pick the right form: "Quoi qu’il ____, il échouera." (do — subjunctive)',
    'What does "appréhender" mean?',
    'Pick the right form: "____ tous les obstacles, il a réussi." (despite — formal)'
  ];
  c1_unit_a text[] := array['nonobstant','convient','aurait','to substantiate','être','qui','predominant','fasse','to grasp','Nonobstant'];
  c1_unit_w text[][] := array[
    array['cependant','pourtant','toutefois'],
    array['faut','semble','permet'],
    array['avait','aura','eut'],
    array['to settle','to summon','to soothe'],
    array['étant','sois','sont'],
    array['que','dont','où'],
    array['superficial','superficial (incorrect)','marginal'],
    array['fait','fera','ait fait'],
    array['to applaud','to alarm','to allege'],
    array['Malgré','Bien que','À cause de']
  ];

  -- Per-level active buffers
  cur_listen_mc_q text[]; cur_listen_mc_a text[]; cur_listen_mc_w text[][];
  cur_listen_typed_q text; cur_listen_typed_a text;
  cur_speak_repeat text[]; cur_speak_topics text[];
  cur_writing text[];
  cur_reading_p text;
  cur_reading_q text[]; cur_reading_a text[]; cur_reading_w text[][];
  cur_vocab_mc_q text[]; cur_vocab_mc_a text[]; cur_vocab_mc_w text[][];
  cur_vocab_fb_q text[]; cur_vocab_fb_a text[];
  cur_grammar_mc_q text[]; cur_grammar_mc_a text[]; cur_grammar_mc_w text[][];
  cur_grammar_fb_q text[]; cur_grammar_fb_a text[];
  cur_phrases_q text[]; cur_phrases_a text[];
  cur_unit_q text[]; cur_unit_a text[]; cur_unit_w text[][];
begin
  select id into v_lang_id from public.languages where code = 'french';

  for v_level in select unnest(array['A1','A2','B1','B2','C1']) loop
    case v_level
      when 'A1' then
        cur_listen_mc_q := a1_listen_mc_q; cur_listen_mc_a := a1_listen_mc_a; cur_listen_mc_w := a1_listen_mc_w;
        cur_listen_typed_q := a1_listen_typed_q; cur_listen_typed_a := a1_listen_typed_a;
        cur_speak_repeat := a1_speak_repeat_phrases; cur_speak_topics := a1_speak_topics;
        cur_writing := a1_writing_prompts;
        cur_reading_p := 'Je m''appelle Sophie. J''ai vingt-cinq ans et j''habite à Paris. Le matin, je vais au travail en bus. Le soir, j''étudie l''anglais. Le week-end, je rends visite à mes parents à la campagne.';
        cur_reading_q := a1_reading_q; cur_reading_a := a1_reading_a; cur_reading_w := a1_reading_w;
        cur_vocab_mc_q := a1_vocab_mc_q; cur_vocab_mc_a := a1_vocab_mc_a; cur_vocab_mc_w := a1_vocab_mc_w;
        cur_vocab_fb_q := a1_vocab_fb_q; cur_vocab_fb_a := a1_vocab_fb_a;
        cur_grammar_mc_q := a1_grammar_mc_q; cur_grammar_mc_a := a1_grammar_mc_a; cur_grammar_mc_w := a1_grammar_mc_w;
        cur_grammar_fb_q := a1_grammar_fb_q; cur_grammar_fb_a := a1_grammar_fb_a;
        cur_phrases_q := a1_phrases_q; cur_phrases_a := a1_phrases_a;
        cur_unit_q := a1_unit_q; cur_unit_a := a1_unit_a; cur_unit_w := a1_unit_w;
      when 'A2' then
        cur_listen_mc_q := a2_listen_mc_q; cur_listen_mc_a := a2_listen_mc_a; cur_listen_mc_w := a2_listen_mc_w;
        cur_listen_typed_q := a2_listen_typed_q; cur_listen_typed_a := a2_listen_typed_a;
        cur_speak_repeat := a2_speak_repeat_phrases; cur_speak_topics := a2_speak_topics;
        cur_writing := a2_writing_prompts;
        cur_reading_p := 'L''année dernière, j''ai changé de travail. Avant, je travaillais dans un petit bureau et je m''ennuyais. J''ai trouvé un poste dans une entreprise internationale qui offre des opportunités de voyage. Au début, c''était difficile, mais maintenant je suis content car j''ai appris beaucoup de choses.';
        cur_reading_q := a2_reading_q; cur_reading_a := a2_reading_a; cur_reading_w := a2_reading_w;
        cur_vocab_mc_q := a2_vocab_mc_q; cur_vocab_mc_a := a2_vocab_mc_a; cur_vocab_mc_w := a2_vocab_mc_w;
        cur_vocab_fb_q := a2_vocab_fb_q; cur_vocab_fb_a := a2_vocab_fb_a;
        cur_grammar_mc_q := a2_grammar_mc_q; cur_grammar_mc_a := a2_grammar_mc_a; cur_grammar_mc_w := a2_grammar_mc_w;
        cur_grammar_fb_q := a2_grammar_fb_q; cur_grammar_fb_a := a2_grammar_fb_a;
        cur_phrases_q := a2_phrases_q; cur_phrases_a := a2_phrases_a;
        cur_unit_q := a2_unit_q; cur_unit_a := a2_unit_a; cur_unit_w := a2_unit_w;
      when 'B1' then
        cur_listen_mc_q := b1_listen_mc_q; cur_listen_mc_a := b1_listen_mc_a; cur_listen_mc_w := b1_listen_mc_w;
        cur_listen_typed_q := b1_listen_typed_q; cur_listen_typed_a := b1_listen_typed_a;
        cur_speak_repeat := b1_speak_repeat_phrases; cur_speak_topics := b1_speak_topics;
        cur_writing := b1_writing_prompts;
        cur_reading_p := 'De plus en plus de jeunes décident d''étudier ou de travailler à l''étranger après leurs études. Les raisons sont variées: beaucoup cherchent de meilleurs salaires, d''autres veulent apprendre une langue ou découvrir une nouvelle culture. Cependant, cette tendance inquiète certains experts qui craignent une perte de talents difficile à compenser. C''est pourquoi plusieurs gouvernements ont commencé à proposer des incitations pour faire revenir ces jeunes.';
        cur_reading_q := b1_reading_q; cur_reading_a := b1_reading_a; cur_reading_w := b1_reading_w;
        cur_vocab_mc_q := b1_vocab_mc_q; cur_vocab_mc_a := b1_vocab_mc_a; cur_vocab_mc_w := b1_vocab_mc_w;
        cur_vocab_fb_q := b1_vocab_fb_q; cur_vocab_fb_a := b1_vocab_fb_a;
        cur_grammar_mc_q := b1_grammar_mc_q; cur_grammar_mc_a := b1_grammar_mc_a; cur_grammar_mc_w := b1_grammar_mc_w;
        cur_grammar_fb_q := b1_grammar_fb_q; cur_grammar_fb_a := b1_grammar_fb_a;
        cur_phrases_q := b1_phrases_q; cur_phrases_a := b1_phrases_a;
        cur_unit_q := b1_unit_q; cur_unit_a := b1_unit_a; cur_unit_w := b1_unit_w;
      when 'B2' then
        cur_listen_mc_q := b2_listen_mc_q; cur_listen_mc_a := b2_listen_mc_a; cur_listen_mc_w := b2_listen_mc_w;
        cur_listen_typed_q := b2_listen_typed_q; cur_listen_typed_a := b2_listen_typed_a;
        cur_speak_repeat := b2_speak_repeat_phrases; cur_speak_topics := b2_speak_topics;
        cur_writing := b2_writing_prompts;
        cur_reading_p := 'L''intelligence artificielle générative bouleverse le monde créatif avec une rapidité inattendue. Pour certains, ce n''est qu''un outil de plus, comparable à l''ordinateur en son temps; d''autres dénoncent un appauvrissement du travail humain. Le débat n''est pas uniquement économique: lorsque la machine produit des œuvres conformes aux standards de qualité, elle remet en cause l''idée même d''auteur et d''originalité. Il est probable que la discussion se prolonge encore longtemps.';
        cur_reading_q := b2_reading_q; cur_reading_a := b2_reading_a; cur_reading_w := b2_reading_w;
        cur_vocab_mc_q := b2_vocab_mc_q; cur_vocab_mc_a := b2_vocab_mc_a; cur_vocab_mc_w := b2_vocab_mc_w;
        cur_vocab_fb_q := b2_vocab_fb_q; cur_vocab_fb_a := b2_vocab_fb_a;
        cur_grammar_mc_q := b2_grammar_mc_q; cur_grammar_mc_a := b2_grammar_mc_a; cur_grammar_mc_w := b2_grammar_mc_w;
        cur_grammar_fb_q := b2_grammar_fb_q; cur_grammar_fb_a := b2_grammar_fb_a;
        cur_phrases_q := b2_phrases_q; cur_phrases_a := b2_phrases_a;
        cur_unit_q := b2_unit_q; cur_unit_a := b2_unit_a; cur_unit_w := b2_unit_w;
      when 'C1' then
        cur_listen_mc_q := c1_listen_mc_q; cur_listen_mc_a := c1_listen_mc_a; cur_listen_mc_w := c1_listen_mc_w;
        cur_listen_typed_q := c1_listen_typed_q; cur_listen_typed_a := c1_listen_typed_a;
        cur_speak_repeat := c1_speak_repeat_phrases; cur_speak_topics := c1_speak_topics;
        cur_writing := c1_writing_prompts;
        cur_reading_p := 'La discussion autour du modèle de la « ville du quart d''heure » se formule depuis des décennies dans les cercles urbanistiques. Elle n''a toutefois trouvé un véritable écho politique qu''au cours des dernières années. Ses défenseurs soulignent qu''avoir école, travail, commerces et loisirs à quinze minutes à pied réduit les émissions, améliore la santé publique et favorise une sociabilité que la motorisation massive avait reléguée. Pourtant, ses détracteurs ont ouvert un front inattendu: certains y voient une restriction déguisée de la liberté de mouvement, allant jusqu''à associer le modèle à des thèses conspirationnistes. Le débat dépasse donc le champ technique et devient profondément culturel et symbolique.';
        cur_reading_q := c1_reading_q; cur_reading_a := c1_reading_a; cur_reading_w := c1_reading_w;
        cur_vocab_mc_q := c1_vocab_mc_q; cur_vocab_mc_a := c1_vocab_mc_a; cur_vocab_mc_w := c1_vocab_mc_w;
        cur_vocab_fb_q := c1_vocab_fb_q; cur_vocab_fb_a := c1_vocab_fb_a;
        cur_grammar_mc_q := c1_grammar_mc_q; cur_grammar_mc_a := c1_grammar_mc_a; cur_grammar_mc_w := c1_grammar_mc_w;
        cur_grammar_fb_q := c1_grammar_fb_q; cur_grammar_fb_a := c1_grammar_fb_a;
        cur_phrases_q := c1_phrases_q; cur_phrases_a := c1_phrases_a;
        cur_unit_q := c1_unit_q; cur_unit_a := c1_unit_a; cur_unit_w := c1_unit_w;
    end case;

    ----------------------------------------------------------------
    -- LISTENING lessons (lesson 4) — 3 MC + 1 typed + 2 fillers
    ----------------------------------------------------------------
    for v_lesson_id in
      select l.id from public.lessons l
      join public.courses c on c.id = l.course_id
      where c.language_id = v_lang_id and c.cefr_level = v_level
        and l.type = 'listening'
    loop
      for i in 1..array_length(cur_listen_mc_q, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (v_lesson_id, 'listening', cur_listen_mc_q[i], cur_listen_mc_a[i],
          array[cur_listen_mc_w[i][1], cur_listen_mc_w[i][2], cur_listen_mc_w[i][3]]::text[],
          i);
      end loop;
      insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
      values (v_lesson_id, 'listening', cur_listen_typed_q, cur_listen_typed_a, array[]::text[],
        array_length(cur_listen_mc_q, 1) + 1);
      -- Fillers (2 extra MC) at 200+
      for i in 1..2 loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (v_lesson_id, 'listening',
          cur_listen_mc_q[((i - 1) % array_length(cur_listen_mc_q, 1)) + 1],
          cur_listen_mc_a[((i - 1) % array_length(cur_listen_mc_a, 1)) + 1],
          array[
            cur_listen_mc_w[((i - 1) % array_length(cur_listen_mc_w, 1)) + 1][1],
            cur_listen_mc_w[((i - 1) % array_length(cur_listen_mc_w, 1)) + 1][2],
            cur_listen_mc_w[((i - 1) % array_length(cur_listen_mc_w, 1)) + 1][3]
          ]::text[],
          200 + i);
      end loop;
    end loop;

    ----------------------------------------------------------------
    -- SPEAKING lessons (lesson 5) — 2 repeat + 2 topic + 2 fillers
    ----------------------------------------------------------------
    for v_lesson_id in
      select l.id from public.lessons l
      join public.courses c on c.id = l.course_id
      where c.language_id = v_lang_id and c.cefr_level = v_level
        and l.type = 'speaking'
    loop
      for i in 1..array_length(cur_speak_repeat, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (v_lesson_id, 'speaking',
          'Say this aloud: "' || cur_speak_repeat[i] || '"',
          cur_speak_repeat[i], array[]::text[], i);
      end loop;
      for i in 1..array_length(cur_speak_topics, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (v_lesson_id, 'speaking',
          cur_speak_topics[i], '', array[]::text[],
          array_length(cur_speak_repeat, 1) + i);
      end loop;
      -- Fillers (1 repeat + 1 topic) at 200+
      insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
      values (v_lesson_id, 'speaking',
        'Say this aloud: "' || cur_speak_repeat[1] || '"',
        cur_speak_repeat[1], array[]::text[], 200);
      insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
      values (v_lesson_id, 'speaking', cur_speak_topics[1], '', array[]::text[], 201);
    end loop;

    ----------------------------------------------------------------
    -- WRITING lessons (lesson 7) — 3 prompts + 1 filler
    ----------------------------------------------------------------
    for v_lesson_id in
      select l.id from public.lessons l
      join public.courses c on c.id = l.course_id
      where c.language_id = v_lang_id and c.cefr_level = v_level
        and l.type = 'writing'
    loop
      for i in 1..array_length(cur_writing, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (v_lesson_id, 'writing', cur_writing[i], '', array[]::text[], i);
      end loop;
      insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
      values (v_lesson_id, 'writing', cur_writing[1], '', array[]::text[], 200);
    end loop;

    ----------------------------------------------------------------
    -- READING lessons (lesson 6) — passage + 3 comprehension MC + 1 filler
    ----------------------------------------------------------------
    for v_lesson_id in
      select l.id from public.lessons l
      join public.courses c on c.id = l.course_id
      where c.language_id = v_lang_id and c.cefr_level = v_level
        and l.type = 'reading'
    loop
      for i in 1..array_length(cur_reading_q, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (v_lesson_id, 'multiple_choice',
          E'Lisez le texte suivant et répondez:\n\n' || cur_reading_p || E'\n\nQuestion: ' || cur_reading_q[i],
          cur_reading_a[i],
          array[cur_reading_w[i][1], cur_reading_w[i][2], cur_reading_w[i][3]]::text[],
          i);
      end loop;
      insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
      values (v_lesson_id, 'multiple_choice',
        E'Lisez le texte suivant et répondez:\n\n' || cur_reading_p || E'\n\nQuestion: ' || cur_reading_q[1],
        cur_reading_a[1],
        array[cur_reading_w[1][1], cur_reading_w[1][2], cur_reading_w[1][3]]::text[],
        200);
    end loop;

    ----------------------------------------------------------------
    -- VOCABULARY lessons (lesson 1) — 4 MC + 2 fill_blank + 4 fillers
    ----------------------------------------------------------------
    for v_lesson_id in
      select l.id from public.lessons l
      join public.courses c on c.id = l.course_id
      where c.language_id = v_lang_id and c.cefr_level = v_level
        and l.type = 'vocabulary'
    loop
      for i in 1..array_length(cur_vocab_mc_q, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (v_lesson_id, 'multiple_choice', cur_vocab_mc_q[i], cur_vocab_mc_a[i],
          array[cur_vocab_mc_w[i][1], cur_vocab_mc_w[i][2], cur_vocab_mc_w[i][3]]::text[], i);
      end loop;
      for i in 1..array_length(cur_vocab_fb_q, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (v_lesson_id, 'fill_blank', cur_vocab_fb_q[i], cur_vocab_fb_a[i], array[]::text[],
          array_length(cur_vocab_mc_q, 1) + i);
      end loop;
      -- Fillers at order_index 200+
      for i in 1..array_length(cur_vocab_mc_q, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (v_lesson_id, 'multiple_choice', cur_vocab_mc_q[i], cur_vocab_mc_a[i],
          array[cur_vocab_mc_w[i][1], cur_vocab_mc_w[i][2], cur_vocab_mc_w[i][3]]::text[],
          200 + i);
      end loop;
    end loop;

    ----------------------------------------------------------------
    -- GRAMMAR lessons (lesson 2) — 4 MC + 2 fill_blank + 4 fillers
    ----------------------------------------------------------------
    for v_lesson_id in
      select l.id from public.lessons l
      join public.courses c on c.id = l.course_id
      where c.language_id = v_lang_id and c.cefr_level = v_level
        and l.type = 'grammar'
    loop
      for i in 1..array_length(cur_grammar_mc_q, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (v_lesson_id, 'multiple_choice', cur_grammar_mc_q[i], cur_grammar_mc_a[i],
          array[cur_grammar_mc_w[i][1], cur_grammar_mc_w[i][2], cur_grammar_mc_w[i][3]]::text[], i);
      end loop;
      for i in 1..array_length(cur_grammar_fb_q, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (v_lesson_id, 'fill_blank', cur_grammar_fb_q[i], cur_grammar_fb_a[i], array[]::text[],
          array_length(cur_grammar_mc_q, 1) + i);
      end loop;
      for i in 1..array_length(cur_grammar_mc_q, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (v_lesson_id, 'multiple_choice', cur_grammar_mc_q[i], cur_grammar_mc_a[i],
          array[cur_grammar_mc_w[i][1], cur_grammar_mc_w[i][2], cur_grammar_mc_w[i][3]]::text[],
          200 + i);
      end loop;
    end loop;

    ----------------------------------------------------------------
    -- PHRASES lessons (lesson 3) — 3 dialogue fill_blank + 3 fillers
    ----------------------------------------------------------------
    for v_lesson_id in
      select l.id from public.lessons l
      join public.courses c on c.id = l.course_id
      where c.language_id = v_lang_id and c.cefr_level = v_level
        and l.type = 'phrases'
    loop
      for i in 1..array_length(cur_phrases_q, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (v_lesson_id, 'fill_blank', cur_phrases_q[i], cur_phrases_a[i], array[]::text[], i);
      end loop;
      for i in 1..array_length(cur_phrases_q, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (v_lesson_id, 'fill_blank', cur_phrases_q[i], cur_phrases_a[i], array[]::text[], 200 + i);
      end loop;
    end loop;

    ----------------------------------------------------------------
    -- UNIT TEST lessons (lesson 9) — 10 mixed MC + fill_blank
    ----------------------------------------------------------------
    for v_lesson_id in
      select l.id from public.lessons l
      join public.courses c on c.id = l.course_id
      where c.language_id = v_lang_id and c.cefr_level = v_level
        and l.type = 'unit_test'
    loop
      for i in 1..array_length(cur_unit_q, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (
          v_lesson_id,
          case when i % 2 = 0 then 'fill_blank' else 'multiple_choice' end,
          cur_unit_q[i],
          cur_unit_a[i],
          case when i % 2 = 0
            then array[]::text[]
            else array[cur_unit_w[i][1], cur_unit_w[i][2], cur_unit_w[i][3]]::text[]
          end,
          i
        );
      end loop;
    end loop;
  end loop;
end $$;

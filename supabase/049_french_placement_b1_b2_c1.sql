-- 049_french_placement_b1_b2_c1.sql
-- French B1/B2/C1 placement exams, mirroring the Spanish 037 seed.
-- Schema already exists from 036+037 (placement_exam_reading_passages,
-- placement_exam_questions, placement_exam_roleplays, etc.).
--
-- Per attempt:
--   1 reading passage (3 MC), 5 vocabulary, 5 dialogue completions,
--   3 roleplay dialogues, 10 writing.
-- Pass mark: 75% (enforced in app code).
--
-- Idempotent.

do $$
declare
  v_lang_id bigint;
begin
  select id into v_lang_id from public.languages where code = 'french';
  if v_lang_id is null then raise exception 'French language not found'; end if;

  delete from public.placement_exam_questions
    where language_id = v_lang_id and level in ('B1','B2','C1');
  delete from public.placement_exam_reading_passages
    where language_id = v_lang_id and level in ('B1','B2','C1');
  delete from public.placement_exam_roleplays
    where language_id = v_lang_id and level in ('B1','B2','C1');

  -- =========================================================
  -- B1 — READING PASSAGES (3, 150-200 words each)
  -- =========================================================
  insert into public.placement_exam_reading_passages (language_id, level, passage, comprehension_questions) values
  (v_lang_id,'B1',
   'L''été dernier, j''ai décidé de déménager à Lyon pour commencer un master en architecture. Avant ce voyage, j''avais toujours vécu chez mes parents dans un village près de Nantes, alors ce changement a été très important pour moi. J''ai trouvé un appartement partagé dans le centre avec deux étudiants italiens : au début nous communiquions en anglais, mais après quelques mois ils parlaient déjà français sans difficulté. Le plus difficile n''a pas été la langue mais m''habituer à vivre seul : cuisiner, faire les courses et organiser mon temps d''étude. Malgré tout, j''ai rencontré des gens formidables et j''ai beaucoup appris sur moi-même. Si je pouvais revenir en arrière, je referais tout cela sans hésiter.',
   '[
     {"question":"Pourquoi a-t-il déménagé à Lyon ?","correct_answer":"Pour étudier un master en architecture","wrong_answers":["Pour trouver du travail","Pour vivre avec ses parents","Pour enseigner l''anglais"]},
     {"question":"Comment communiquait-il au début avec ses colocataires ?","correct_answer":"En anglais","wrong_answers":["En italien","Seulement en français","Par écrit"]},
     {"question":"Qu''est-ce qui a été le plus difficile pour lui ?","correct_answer":"S''habituer à vivre seul","wrong_answers":["Apprendre l''italien","Trouver un appartement","Payer le loyer"]}
   ]'::jsonb),
  (v_lang_id,'B1',
   'Camille travaille comme infirmière depuis sept ans dans un hôpital de Bordeaux. Bien qu''elle aime son métier, elle se sent assez fatiguée ces derniers temps parce que les gardes de nuit sont de plus en plus fréquentes et elle n''a plus de temps pour ses loisirs. Il y a trois mois, elle a commencé des cours de peinture le samedi matin et, même si cela peut paraître étrange, elle dit que cette heure par semaine lui change tout le reste de ses journées. Son rêve est d''économiser assez d''argent pour faire un voyage au Japon, un pays qui la passionne depuis qu''elle a vu un documentaire sur Kyoto à l''université. Si tout va bien, elle partira l''automne prochain avec sa meilleure amie.',
   '[
     {"question":"Quel problème Camille a-t-elle ces derniers temps ?","correct_answer":"Elle fait beaucoup de gardes de nuit","wrong_answers":["Elle n''aime pas son travail","Elle n''a pas de collègues","Elle ne gagne pas assez d''argent"]},
     {"question":"Que fait-elle le samedi ?","correct_answer":"Des cours de peinture","wrong_answers":["Elle travaille en plus","Elle étudie le japonais","Elle rend visite à sa famille"]},
     {"question":"Quand prévoit-elle de partir au Japon ?","correct_answer":"L''automne prochain","wrong_answers":["Cet été","Dans quelques années","Elle n''a pas de date"]}
   ]'::jsonb),
  (v_lang_id,'B1',
   'Il y a trois ans, nous avons ouvert un petit café-librairie dans le vieux quartier de Strasbourg. L''idée est née un après-midi, quand mon compagnon et moi nous sommes rendu compte qu''il n''y avait aucun endroit confortable où prendre un café et lire pendant plusieurs heures. Au début, ça a été très compliqué : pendant les premiers mois, presque personne ne venait et nous avons pensé plusieurs fois à fermer. Cependant, nous avons décidé d''inviter des auteurs locaux à présenter leurs livres le jeudi soir et, petit à petit, les gens ont commencé à parler de nous. Aujourd''hui, nous avons des clients fidèles qui viennent chaque semaine et, le plus important, nous avons créé un espace où les gens se sentent comme chez eux.',
   '[
     {"question":"Pourquoi ont-ils décidé d''ouvrir le café-librairie ?","correct_answer":"Parce qu''il n''y avait pas d''endroit similaire dans le quartier","wrong_answers":["Parce qu''ils aimaient le vieux quartier","Parce qu''ils voulaient vendre des livres d''occasion","Parce qu''ils avaient hérité du local"]},
     {"question":"Qu''ont-ils fait pour attirer plus de monde ?","correct_answer":"Organiser des présentations de livres le jeudi","wrong_answers":["Baisser les prix","Ouvrir plus d''heures","Fermer le week-end"]},
     {"question":"Comment décrivent-ils le café aujourd''hui ?","correct_answer":"Un espace où les gens se sentent comme chez eux","wrong_answers":["Un commerce qui fermera bientôt","Un local seulement pour les auteurs","Un endroit ouvert uniquement le week-end"]}
   ]'::jsonb);

  -- =========================================================
  -- B1 — VOCABULARY (10 in bank, pick 5)
  -- Full-sentence context with B1 grammar (passé composé/imparfait, futur, basic subjunctive, conditional).
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, order_index) values
  (v_lang_id,'B1','vocabulary','Quand j''étais enfant, je ____ les étés chez mes grands-parents à la campagne.','passais',array['ai passé','passe','passerai'],1),
  (v_lang_id,'B1','vocabulary','Je suis content que tu ____ à la fête samedi soir.','viennes',array['viens','venais','viendras'],2),
  (v_lang_id,'B1','vocabulary','Si j''avais plus de temps libre, j''____ apprendre à jouer de la guitare.','aimerais',array['aime','ai aimé','aimerai'],3),
  (v_lang_id,'B1','vocabulary','Cela fait deux ans que j''____ le français, mais j''ai encore du mal à comprendre les accents.','apprends',array['apprenais','ai appris','apprendrai'],4),
  (v_lang_id,'B1','vocabulary','Le médecin m''a recommandé de ____ moins de café et plus d''eau.','boire',array['bois','bu','boirai'],5),
  (v_lang_id,'B1','vocabulary','Bien qu''il fût très fatigué, mon frère ____ à travailler jusqu''à tard.','a continué',array['a commencé','a perdu','a appelé'],6),
  (v_lang_id,'B1','vocabulary','Je ne me suis pas rendu compte ____ avoir perdu mes clés avant d''arriver à la maison.','d''',array['en','avec','par'],7),
  (v_lang_id,'B1','vocabulary','Après avoir beaucoup discuté, mes amis se sont enfin ____ sur la décision.','mis d''accord',array['fâchés','licenciés','débarrassés'],8),
  (v_lang_id,'B1','vocabulary','L''entreprise cherche un candidat qui ____ parfaitement l''anglais et l''allemand.','parle',array['parlait','parlera','parlé'],9),
  (v_lang_id,'B1','vocabulary','L''année dernière, ma famille ____ à Paris parce que mon père a changé de travail.','a déménagé',array['déménageait','déménage','déménagera'],10);

  -- =========================================================
  -- B1 — DIALOGUE COMPLETION (10 in bank, pick 5)
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, dialogue_lines, order_index) values
  (v_lang_id,'B1','dialogue','Complete the dialogue with an appropriate French response (2-3 sentences if possible).','Le week-end, je suis allé à Marseille avec ma copine. Nous avons visité le Vieux-Port et nous avons mangé dans un très bon petit restaurant près de la mer.',array[]::text[],
   '[{"speaker":"A","text":"Ça fait longtemps qu''on ne s''est pas vus. Comment vas-tu ?"},{"speaker":"B","text":"___"}]'::jsonb,11),
  (v_lang_id,'B1','dialogue','Complete the dialogue with an appropriate French response.','J''ai assez mal à la tête depuis hier et j''aimerais que vous me recommandiez quelque chose. Je me sens aussi un peu fatiguée.',array[]::text[],
   '[{"speaker":"Médecin","text":"Bonjour, en quoi puis-je vous aider ?"},{"speaker":"Patient","text":"___"}]'::jsonb,12),
  (v_lang_id,'B1','dialogue','Complete the dialogue with an appropriate French response.','Je suis vraiment désolé, mais j''ai déjà des projets pour samedi. Qu''est-ce que tu dirais si on se voyait dimanche après-midi ?',array[]::text[],
   '[{"speaker":"A","text":"Tu veux venir à un barbecue chez moi samedi ?"},{"speaker":"B","text":"___"}]'::jsonb,13),
  (v_lang_id,'B1','dialogue','Complete the dialogue with an appropriate French response.','Je voudrais prendre le menu du jour, s''il vous plaît. Pourriez-vous me dire ce que vous avez en entrée aujourd''hui ?',array[]::text[],
   '[{"speaker":"Serveur","text":"Bonsoir, vous avez choisi ?"},{"speaker":"Client","text":"___"}]'::jsonb,14),
  (v_lang_id,'B1','dialogue','Complete the dialogue with an appropriate French response.','Oui, bien sûr. Continuez tout droit pendant deux rues puis tournez à droite. La pharmacie est à côté de la banque.',array[]::text[],
   '[{"speaker":"Touriste","text":"Excusez-moi, pourriez-vous me dire comment aller à la pharmacie la plus proche ?"},{"speaker":"Habitant","text":"___"}]'::jsonb,15),
  (v_lang_id,'B1','dialogue','Complete the dialogue with an appropriate French response.','Je travaille depuis trois ans dans une entreprise de marketing. Avant cela, j''avais étudié le journalisme à l''université.',array[]::text[],
   '[{"speaker":"Recruteur","text":"Parlez-moi un peu de votre expérience professionnelle, s''il vous plaît."},{"speaker":"Candidat","text":"___"}]'::jsonb,16),
  (v_lang_id,'B1','dialogue','Complete the dialogue with an appropriate French response.','Non, je n''ai pas encore terminé le rapport. Je suis désolé, mais j''ai dû aider un autre collègue ce matin.',array[]::text[],
   '[{"speaker":"Chef","text":"As-tu déjà préparé le rapport que je t''ai demandé hier ?"},{"speaker":"Employé","text":"___"}]'::jsonb,17),
  (v_lang_id,'B1','dialogue','Complete the dialogue with an appropriate French response.','J''ai acheté cette chemise vendredi dernier et, quand je suis rentré chez moi, j''ai vu qu''elle était déchirée. Pourriez-vous me l''échanger ?',array[]::text[],
   '[{"speaker":"Client","text":"Bonjour, j''ai un problème avec un article."},{"speaker":"Vendeur","text":"___"}]'::jsonb,18),
  (v_lang_id,'B1','dialogue','Complete the dialogue with an appropriate French response.','Je préfère une chambre avec vue sur la mer, si possible. Combien coûterait le petit-déjeuner en supplément ?',array[]::text[],
   '[{"speaker":"Réceptionniste","text":"Nous avons une chambre double disponible. Que préférez-vous ?"},{"speaker":"Client","text":"___"}]'::jsonb,19),
  (v_lang_id,'B1','dialogue','Complete the dialogue with an appropriate French response.','J''ai étudié les lettres modernes parce que les langues et la littérature m''ont toujours fascinée. Ensuite, j''ai fait une formation en traduction.',array[]::text[],
   '[{"speaker":"A","text":"Pourquoi as-tu décidé d''étudier ce que tu fais ?"},{"speaker":"B","text":"___"}]'::jsonb,20);

  -- =========================================================
  -- B1 — WRITING (20 in bank, pick 10)
  -- 4-5 French sentences. Progressive complexity within the bank.
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, order_index) values
  (v_lang_id,'B1','writing','Write a 4-5 sentence French paragraph about a trip you took recently.','Where, when, with whom, what you did, how you felt',array[]::text[],21),
  (v_lang_id,'B1','writing','Write a 4-5 sentence French paragraph about a problem you solved at work or in your studies.','The problem, what you did, the result',array[]::text[],22),
  (v_lang_id,'B1','writing','Write a 4-5 sentence French paragraph comparing life in a big city with life in a small town.','At least two contrasts and your preference',array[]::text[],23),
  (v_lang_id,'B1','writing','Write a 4-5 sentence French email to a friend inviting them to your birthday celebration.','Date, time, place, what activity, polite close',array[]::text[],24),
  (v_lang_id,'B1','writing','Write a 4-5 sentence French paragraph about a goal you want to achieve in the next year.','The goal, why it matters, how you''ll work on it',array[]::text[],25),
  (v_lang_id,'B1','writing','Write a 4-5 sentence French paragraph about how technology has changed daily life.','At least two specific examples',array[]::text[],26),
  (v_lang_id,'B1','writing','Write a 4-5 sentence French paragraph describing a memorable meal.','When, where, with whom, what you ate, why it stood out',array[]::text[],27),
  (v_lang_id,'B1','writing','Write a 4-5 sentence French paragraph about what you would do if you won the lottery.','Use conditional forms',array[]::text[],28),
  (v_lang_id,'B1','writing','Write a 4-5 sentence French complaint to a hotel about a problem during your stay.','Polite tone, specific issue, requested action',array[]::text[],29),
  (v_lang_id,'B1','writing','Write a 4-5 sentence French paragraph explaining advantages and disadvantages of working from home.','At least one pro and one con',array[]::text[],30),
  (v_lang_id,'B1','writing','Write a 4-5 sentence French paragraph describing a person who has influenced you.','Who they are, why, an example',array[]::text[],31),
  (v_lang_id,'B1','writing','Write a 4-5 sentence French paragraph about a tradition or festival in your country.','Name, when, what people do, your opinion',array[]::text[],32),
  (v_lang_id,'B1','writing','Write a 4-5 sentence French paragraph narrating a misunderstanding you had abroad.','Where, what happened, how you resolved it',array[]::text[],33),
  (v_lang_id,'B1','writing','Write a 4-5 sentence French paragraph about a book or film that made you think.','Title, brief description, what you took away',array[]::text[],34),
  (v_lang_id,'B1','writing','Write a 4-5 sentence French paragraph about the best advice you have received.','Who, when, what advice, how it helped',array[]::text[],35),
  (v_lang_id,'B1','writing','Write a 4-5 sentence French paragraph explaining how to prepare a simple dish from your country.','Ingredients, steps, tips',array[]::text[],36),
  (v_lang_id,'B1','writing','Write a 4-5 sentence French paragraph about a change you would like to see in your city.','The change, why, possible impact',array[]::text[],37),
  (v_lang_id,'B1','writing','Write a 4-5 sentence French paragraph about a habit you would like to improve.','The habit, why it matters, your plan',array[]::text[],38),
  (v_lang_id,'B1','writing','Write a 4-5 sentence French paragraph describing your ideal job.','Type of work, schedule, environment, why',array[]::text[],39),
  (v_lang_id,'B1','writing','Write a 4-5 sentence French paragraph explaining why learning another language is useful.','Personal, professional and cultural reasons',array[]::text[],40);

  -- =========================================================
  -- B1 — ROLEPLAY TOPICS (10, pick 3)
  -- =========================================================
  insert into public.placement_exam_roleplays (language_id, level, topic_label, scenario, user_role, ai_role, ai_opener, target_exchanges) values
  (v_lang_id,'B1','Restaurant complaint',
   'Vous dînez dans un restaurant français. Le plat que vous avez commandé est arrivé froid et la boisson n''est pas celle que vous aviez demandée. Vous voulez régler la situation poliment.',
   'Client','Serveur',
   'Bonsoir, tout se passe bien avec votre repas ? Je vois que vous avez à peine touché à votre assiette.', 5),
  (v_lang_id,'B1','Hotel check-in',
   'Vous arrivez à un hôtel à Nice après un long vol. Vous avez une réservation, mais le réceptionniste ne la trouve pas dans le système.',
   'Voyageur','Réceptionniste',
   'Bonsoir, bienvenue à l''hôtel. Avez-vous une réservation à votre nom ?', 5),
  (v_lang_id,'B1','Asking directions',
   'Vous êtes perdu à Paris et vous voulez aller au musée d''Orsay. Vous demandez de l''aide à un habitant dans la rue.',
   'Touriste','Habitant',
   'En quoi puis-je vous aider ? Vous avez l''air un peu perdu.', 4),
  (v_lang_id,'B1','Job interview',
   'Vous passez un entretien informel pour un travail à temps partiel dans une librairie. Le recruteur est assez sympathique.',
   'Candidat','Recruteur',
   'Bonjour, ravi de vous rencontrer. Parlez-moi un peu de vous et de ce qui vous intéresse dans ce poste.', 6),
  (v_lang_id,'B1','Weekend plans',
   'Vous parlez avec un ami français pour organiser le week-end prochain. Vous voulez faire quelque chose d''amusant sans dépenser beaucoup d''argent.',
   'Ami','Ami',
   'Enfin vendredi ! Qu''est-ce qui te ferait plaisir ce week-end ?', 5),
  (v_lang_id,'B1','Complaint resolution',
   'Vous avez acheté une machine à laver il y a un mois et elle est tombée en panne. Vous appelez le service client pour réclamer.',
   'Client','Conseiller',
   'Service client, en quoi puis-je vous aider ?', 5),
  (v_lang_id,'B1','Doctor visit',
   'Vous allez chez le médecin parce que depuis plusieurs jours vous avez de la toux et mal à la gorge.',
   'Patient','Médecin',
   'Bonjour, entrez et asseyez-vous, je vous en prie. Dites-moi ce qui vous amène.', 5),
  (v_lang_id,'B1','Shopping return',
   'Vous avez acheté une chemise la semaine dernière et elle a rétréci au lavage alors que vous avez suivi les instructions. Vous allez en magasin pour la rendre.',
   'Client','Vendeuse',
   'Bonjour, je peux vous aider ?', 4),
  (v_lang_id,'B1','Travel booking',
   'Vous appelez une agence de voyages pour réserver un vol à Barcelone. Vous avez des dates flexibles et vous voulez voir les options.',
   'Client','Agent de voyages',
   'Agence Voyages du Soleil, bonjour. En quoi puis-je vous aider ?', 5),
  (v_lang_id,'B1','Apartment viewing',
   'Vous visitez un appartement à louer dans le centre-ville. La propriétaire vous fait visiter le logement.',
   'Locataire potentiel','Propriétaire',
   'Bienvenue. Entrez, je vous en prie. Que pensez-vous de l''appartement au premier coup d''œil ?', 5);

  -- =========================================================
  -- B2 — READING PASSAGES (3, 200-250 words)
  -- =========================================================
  insert into public.placement_exam_reading_passages (language_id, level, passage, comprehension_questions) values
  (v_lang_id,'B2',
   'Bien que l''on dise souvent que les réseaux sociaux ont rapproché les gens, de plus en plus d''études suggèrent le contraire. Un rapport récent de l''Université de Lille, fondé sur des entretiens menés auprès de plus de deux mille adolescents, conclut que les jeunes qui passent plus de cinq heures par jour connectés présentent des niveaux nettement plus élevés d''anxiété et de solitude. L''auteure principale de l''étude, la psychologue Isabelle Marot, met cependant en garde contre une lecture simpliste : la faute n''est pas à la technologie en elle-même, mais à l''usage passif que l''on en fait, c''est-à-dire passer des heures à observer la vie des autres sans interagir réellement avec personne. Lorsque les adolescents utilisent les réseaux pour créer du contenu, débattre ou organiser des activités hors ligne, les effets négatifs disparaissent presque totalement. La proposition de l''équipe de recherche est donc d''éduquer à un usage actif et critique plutôt que d''interdire l''accès, une solution qui, selon eux, ne ferait que déplacer le problème.',
   '[
     {"question":"Quelle est la conclusion principale de l''étude ?","correct_answer":"Plus d''heures connectés sont liées à plus d''anxiété et de solitude","wrong_answers":["Les réseaux rapprochent davantage les jeunes","Il n''y a aucun effet mesurable","La technologie est la seule responsable"]},
     {"question":"Selon Marot, quel type d''usage est problématique ?","correct_answer":"L''usage passif, sans interaction réelle","wrong_answers":["Tout usage en général","Seulement l''usage nocturne","L''usage pour organiser des sorties"]},
     {"question":"Que propose l''équipe de recherche ?","correct_answer":"Éduquer à un usage actif et critique","wrong_answers":["Interdire l''accès aux mineurs","Autoriser seulement l''usage scolaire","Limiter à une heure par jour par la loi"]}
   ]'::jsonb),
  (v_lang_id,'B2',
   'Il y a trois ans, après plus d''une décennie passée comme avocate dans un grand cabinet parisien, Marthe Lefèvre a pris une décision qui a surpris tous ceux qui la connaissaient : elle a quitté son poste, vendu son appartement et ouvert une petite boulangerie dans un village des Vosges. « Ce n''est pas que j''étais épuisée par les longues journées, même si cela m''a poussée à agir », explique-t-elle aujourd''hui. « Ce qui s''est passé était plus profond : j''avais cessé de me reconnaître dans le miroir. » Malgré les doutes initiaux et les commentaires de ceux qui pensaient que cela ne pourrait pas marcher, l''affaire tient grâce à une clientèle fidèle et à la vente en ligne dans les villages voisins. « Je gagne moins de la moitié qu''avant, mais pour la première fois depuis des années, je dors bien la nuit », ajoute-t-elle. Marthe reconnaît que son histoire n''est pas reproductible pour tout le monde, mais elle encourage ceux qui se sentent piégés à, au moins, se poser sérieusement les bonnes questions.',
   '[
     {"question":"Pourquoi Marthe a-t-elle quitté son métier d''avocate ?","correct_answer":"Parce qu''elle avait cessé de se reconnaître","wrong_answers":["Parce qu''elle a été licenciée","Parce qu''elle gagnait très peu","Parce qu''elle a déménagé à l''étranger"]},
     {"question":"Comment la boulangerie se maintient-elle économiquement ?","correct_answer":"Grâce à des clients fidèles et à la vente en ligne","wrong_answers":["Seulement avec des touristes","Avec des aides de l''État","En fermant plusieurs mois par an"]},
     {"question":"Quel conseil Marthe donne-t-elle aux autres ?","correct_answer":"Qu''ils se posent sérieusement les bonnes questions","wrong_answers":["Qu''ils quittent immédiatement leur travail","Qu''ils déménagent à la campagne","Qu''ils étudient la pâtisserie"]}
   ]'::jsonb),
  (v_lang_id,'B2',
   'Au cours de la dernière décennie, plusieurs villes européennes ont misé sur une réduction drastique du trafic dans leurs centres historiques. Strasbourg, en Alsace, est l''un des exemples les plus cités : depuis la fin des années quatre-vingt-dix, le cœur de la ville est presque entièrement interdit aux voitures. Les statistiques sont saisissantes : le nombre de victimes d''accidents de la route a chuté presque à zéro et les niveaux de pollution atmosphérique sont parmi les plus bas de la région. Cependant, tout le monde n''applaudit pas ce modèle. Des commerçants de la périphérie se plaignent de ce que la piétonnisation a déplacé la consommation vers des centres commerciaux situés hors du noyau urbain, et certains habitants âgés signalent qu''il est plus compliqué de recevoir des marchandises ou de gérer des urgences domestiques. Les techniciens municipaux reconnaissent ces tensions et soutiennent que le modèle requiert des ajustements constants, mais ils défendent que les bénéfices collectifs l''emportent largement sur les inconvénients individuels.',
   '[
     {"question":"Quel effet positif de la piétonnisation à Strasbourg est-il mis en avant ?","correct_answer":"Une chute presque totale des victimes d''accidents","wrong_answers":["Plus de voitures électriques","Plus de tourisme de masse","Plus de bureaux dans le centre"]},
     {"question":"Qui se plaint du modèle ?","correct_answer":"Les commerçants de la périphérie et certains habitants âgés","wrong_answers":["Les techniciens municipaux","Les chauffeurs de taxi","Les visiteurs étrangers"]},
     {"question":"Quelle position défendent les techniciens municipaux ?","correct_answer":"Que les bénéfices collectifs l''emportent sur les inconvénients individuels","wrong_answers":["Qu''il faut revenir en arrière","Que cela ne marche que dans les petites villes","Que c''est un échec à long terme"]}
   ]'::jsonb);

  -- =========================================================
  -- B2 — VOCABULARY (10 in bank)
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, order_index) values
  (v_lang_id,'B2','vocabulary','Nous cherchons un candidat qui ____ de l''expérience en gestion d''équipes internationales.','ait',array['a','aura','avait'],11),
  (v_lang_id,'B2','vocabulary','Si j''avais su ce qui allait se passer, je n''____ jamais accepté ce travail.','aurais',array['avais','aurai','avais eu'],12),
  (v_lang_id,'B2','vocabulary','Bien que cela ____ très difficile, elle n''a jamais renoncé à son rêve de devenir médecin.','soit',array['est','sera','serait'],13),
  (v_lang_id,'B2','vocabulary','La proposition a été rejetée ____ l''opposition de plusieurs membres du conseil.','en raison de',array['malgré','pour','à condition de'],14),
  (v_lang_id,'B2','vocabulary','Je vous remercie d''avoir ____ aussi aimable avec moi pendant ma visite.','été',array['été','étant','étiez'],15),
  (v_lang_id,'B2','vocabulary','Le directeur a insisté pour que tous les employés ____ à la réunion de lundi.','assistent',array['assistent','assisteront','assistaient'],16),
  (v_lang_id,'B2','vocabulary','Personne ne s''attendait à ce que le résultat ____ aussi serré à la fin du match.','soit',array['est','serait','sera'],17),
  (v_lang_id,'B2','vocabulary','Dès que j''____ les résultats, je t''appellerai pour te le dire.','aurai',array['ai','avais','aurais'],18),
  (v_lang_id,'B2','vocabulary','Cela ne m''étonne pas que son patron ____ en colère : ils ont des semaines de retard.','soit',array['est','était','sera'],19),
  (v_lang_id,'B2','vocabulary','Il est important que tu ____ le contrat avant de signer quoi que ce soit.','relises',array['relis','relisais','reliras'],20);

  -- =========================================================
  -- B2 — DIALOGUE COMPLETION (10 in bank)
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, dialogue_lines, order_index) values
  (v_lang_id,'B2','dialogue','Complete the dialogue with an appropriate French response (at least 2 full sentences).','Honnêtement, je ne suis pas tout à fait d''accord. Même si la proposition a des points intéressants, je pense que nous devrions analyser les conséquences à long terme.',array[]::text[],
   '[{"speaker":"Collègue","text":"J''ai revu ta proposition et elle me paraît très bonne, qu''en penses-tu ?"},{"speaker":"Toi","text":"___"}]'::jsonb,21),
  (v_lang_id,'B2','dialogue','Complete the dialogue with an appropriate French response.','Je suis vraiment désolée, mais le bruit est vraiment gênant et nous n''arrivons pas à nous reposer. Serait-il possible que vous baissiez la musique après vingt-trois heures ?',array[]::text[],
   '[{"speaker":"Voisin","text":"Bonjour, désolé pour l''heure, il y a un problème ?"},{"speaker":"Toi","text":"___"}]'::jsonb,22),
  (v_lang_id,'B2','dialogue','Complete the dialogue with an appropriate French response.','Cela fait plusieurs mois que je pense à changer de service. J''aimerais prendre plus de responsabilités et découvrir de nouveaux domaines.',array[]::text[],
   '[{"speaker":"Cheffe","text":"Je voulais te parler de ton évolution professionnelle. Comment te vois-tu dans un an ?"},{"speaker":"Employé","text":"___"}]'::jsonb,23),
  (v_lang_id,'B2','dialogue','Complete the dialogue with an appropriate French response.','Je comprends que ce soit une décision difficile, mais pour des raisons familiales je ne peux pas déménager dans une autre ville en ce moment. Nous pourrions peut-être chercher une autre solution.',array[]::text[],
   '[{"speaker":"Directeur","text":"L''entreprise a besoin que quelqu''un reprenne le bureau de Lyon. Nous te l''avons proposé."},{"speaker":"Toi","text":"___"}]'::jsonb,24),
  (v_lang_id,'B2','dialogue','Complete the dialogue with an appropriate French response.','Eh bien, je trouve qu''aujourd''hui on dépense trop en publicité et trop peu en formation. C''est pour cela que beaucoup d''employés se sentent bloqués.',array[]::text[],
   '[{"speaker":"Ami","text":"Comment vois-tu la situation de ton secteur ces derniers temps ?"},{"speaker":"Toi","text":"___"}]'::jsonb,25),
  (v_lang_id,'B2','dialogue','Complete the dialogue with an appropriate French response.','Je vous remercie beaucoup pour votre temps. Je suis très intéressé par le poste et j''attends de vos nouvelles dans les prochains jours.',array[]::text[],
   '[{"speaker":"Recruteur","text":"Bien, je crois que nous avons fait le tour. Avez-vous une dernière question ?"},{"speaker":"Candidat","text":"___"}]'::jsonb,26),
  (v_lang_id,'B2','dialogue','Complete the dialogue with an appropriate French response.','Je comprends, mais je vous rappelle que nous avons signé un contrat précis. Si nous ne parvenons pas à un accord raisonnable, je devrai consulter mon avocat.',array[]::text[],
   '[{"speaker":"Propriétaire","text":"Je regrette de vous annoncer que je dois augmenter votre loyer de quinze pour cent."},{"speaker":"Locataire","text":"___"}]'::jsonb,27),
  (v_lang_id,'B2','dialogue','Complete the dialogue with an appropriate French response.','Oui, bien sûr. J''ai beaucoup réfléchi à votre conseil et je pense que vous avez raison. Je vais m''inscrire au master, même si cela représente un effort financier important.',array[]::text[],
   '[{"speaker":"Professeure","text":"Il y a quelque temps, je t''avais recommandé de poursuivre tes études. As-tu pris une décision ?"},{"speaker":"Étudiant","text":"___"}]'::jsonb,28),
  (v_lang_id,'B2','dialogue','Complete the dialogue with an appropriate French response.','Honnêtement, je ne m''attendais pas à cette nouvelle. J''ai besoin de quelques jours pour y réfléchir et en parler avec ma famille avant de te répondre définitivement.',array[]::text[],
   '[{"speaker":"Ami","text":"On nous propose de monter le projet ensemble. Qu''est-ce que tu en penses ?"},{"speaker":"Toi","text":"___"}]'::jsonb,29),
  (v_lang_id,'B2','dialogue','Complete the dialogue with an appropriate French response.','Si cela ne tenait qu''à moi, je partirais vivre à l''étranger quelques années. Cependant, ce n''est pas si simple : il faut tenir compte du travail, de la famille et des études.',array[]::text[],
   '[{"speaker":"A","text":"Tu as déjà envisagé de vivre hors de France ?"},{"speaker":"B","text":"___"}]'::jsonb,30);

  -- =========================================================
  -- B2 — WRITING (20 in bank)
  -- 5-6 sentences. More abstract themes.
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, order_index) values
  (v_lang_id,'B2','writing','Write a 5-6 sentence French paragraph arguing for or against remote work for entry-level employees.','Take a clear position; at least two arguments and a counter-argument',array[]::text[],31),
  (v_lang_id,'B2','writing','Write a 5-6 sentence French paragraph describing a recent change in your country''s culture.','What changed, why, your opinion',array[]::text[],32),
  (v_lang_id,'B2','writing','Write a 5-6 sentence French formal letter requesting a refund from an online store.','Polite tone, specific facts, requested resolution',array[]::text[],33),
  (v_lang_id,'B2','writing','Write a 5-6 sentence French paragraph explaining the pros and cons of a four-day work week.','Concrete arguments, your conclusion',array[]::text[],34),
  (v_lang_id,'B2','writing','Write a 5-6 sentence French paragraph narrating a moment when you had to make a difficult decision.','Context, the dilemma, what you chose, what you learned',array[]::text[],35),
  (v_lang_id,'B2','writing','Write a 5-6 sentence French paragraph about how social media affects friendships today.','Both sides, concrete examples, your view',array[]::text[],36),
  (v_lang_id,'B2','writing','Write a 5-6 sentence French paragraph explaining whether universities should be free for everyone.','Take a position, justify with at least two arguments',array[]::text[],37),
  (v_lang_id,'B2','writing','Write a 5-6 sentence French paragraph about a film or book that changed how you see the world.','Title, what it changed, why',array[]::text[],38),
  (v_lang_id,'B2','writing','Write a 5-6 sentence French paragraph describing a current problem in your city and proposing a solution.','Problem, who is affected, your proposal',array[]::text[],39),
  (v_lang_id,'B2','writing','Write a 5-6 sentence French paragraph about whether tourism benefits or harms local communities.','At least one of each side, your conclusion',array[]::text[],40),
  (v_lang_id,'B2','writing','Write a 5-6 sentence French paragraph about a generational difference you have noticed.','Concrete example, why it exists, what you think',array[]::text[],41),
  (v_lang_id,'B2','writing','Write a 5-6 sentence French paragraph explaining how you handle disagreements at work or in your studies.','Strategy, an example, the result',array[]::text[],42),
  (v_lang_id,'B2','writing','Write a 5-6 sentence French paragraph about whether learning a second language should be compulsory in schools.','Take a position; justify with at least two arguments',array[]::text[],43),
  (v_lang_id,'B2','writing','Write a 5-6 sentence French paragraph describing what success means to you, beyond money.','Define, contrast with common views, give an example',array[]::text[],44),
  (v_lang_id,'B2','writing','Write a 5-6 sentence French paragraph narrating a misunderstanding caused by cultural differences.','Where, what happened, how you resolved it',array[]::text[],45),
  (v_lang_id,'B2','writing','Write a 5-6 sentence French paragraph about whether artificial intelligence will help or hurt your profession.','Specific examples, your stance',array[]::text[],46),
  (v_lang_id,'B2','writing','Write a 5-6 sentence French paragraph about an unwritten rule in your country that visitors should know.','The rule, why it exists, consequences of breaking it',array[]::text[],47),
  (v_lang_id,'B2','writing','Write a 5-6 sentence French paragraph about the role of public libraries today.','Are they still useful, why or why not, your conclusion',array[]::text[],48),
  (v_lang_id,'B2','writing','Write a 5-6 sentence French paragraph about a piece of advice you would give your younger self.','The advice, why, the situation that taught you',array[]::text[],49),
  (v_lang_id,'B2','writing','Write a 5-6 sentence French paragraph arguing whether grades reflect a student''s real ability.','Take a position, justify with concrete examples',array[]::text[],50);

  -- =========================================================
  -- B2 — ROLEPLAY TOPICS (10, pick 3)
  -- =========================================================
  insert into public.placement_exam_roleplays (language_id, level, topic_label, scenario, user_role, ai_role, ai_opener, target_exchanges) values
  (v_lang_id,'B2','Restaurant complaint',
   'Vous êtes au restaurant avec un client important. L''addition comporte une erreur visible et, en plus, on vous a servi un plat différent de celui que vous aviez commandé. Vous voulez régler la situation sans créer de tension devant le client.',
   'Client','Responsable',
   'Bonsoir, est-ce que tout vous convient ? Je voulais venir vous saluer personnellement.', 5),
  (v_lang_id,'B2','Hotel check-in',
   'Vous arrivez à un hôtel pour une conférence internationale. La chambre qui vous a été attribuée ne correspond pas à la catégorie que vous aviez réservée et vous avez besoin d''une solution avant de commencer vos réunions.',
   'Voyageur','Réceptionniste',
   'Bonsoir, bienvenue à l''hôtel. Je vois que vous avez une réservation chez nous. Souhaitez-vous que nous revoyions ensemble les détails ?', 6),
  (v_lang_id,'B2','Asking directions',
   'Vous êtes à Lyon et vous devez vous rendre à un entretien important. La batterie de votre téléphone s''épuise et vous devez demander à un habitant comment y aller et arriver à l''heure.',
   'Professionnel','Habitant',
   'Excusez-moi, vous avez l''air d''avoir besoin d''aide. En quoi puis-je vous orienter ?', 4),
  (v_lang_id,'B2','Job interview',
   'Vous passez un entretien pour un poste à responsabilités dans une entreprise internationale. Le recruteur pose des questions assez exigeantes sur votre carrière et votre manière de gérer les conflits.',
   'Candidat','Recruteuse',
   'Merci d''être venu. Pour commencer, j''aimerais que vous me racontiez ce qui vous a motivé à postuler à cette offre précisément.', 6),
  (v_lang_id,'B2','Weekend plans',
   'Vous discutez avec votre partenaire du week-end. Vous avez beaucoup de travail en attente, mais votre partenaire insiste pour faire une escapade. Vous voulez trouver un compromis qui marche pour vous deux.',
   'Partenaire','Partenaire',
   'Cela fait des semaines que nous ne sommes pas sortis de la ville. Tu n''aurais pas envie d''une petite escapade ce week-end ?', 5),
  (v_lang_id,'B2','Complaint resolution',
   'Vous avez souscrit un service internet pour votre entreprise, mais cela fait plus d''une semaine que vous n''avez pas de connexion stable. Vous avez besoin d''une solution immédiate parce que cela affecte le travail.',
   'Client entreprise','Conseiller',
   'Service entreprises, Jean à votre écoute. En quoi puis-je vous aider aujourd''hui ?', 6),
  (v_lang_id,'B2','Doctor visit',
   'Vous allez chez le médecin parce que depuis plusieurs mois vous souffrez de maux de tête récurrents. Vous voulez vous assurer qu''on vous fasse les examens adéquats et ne pas vous contenter d''une réponse vague.',
   'Patient','Médecin',
   'Bonjour. Je vois dans votre dossier que vous venez pour des maux de tête. Racontez-moi en détail, s''il vous plaît.', 5),
  (v_lang_id,'B2','Shopping return',
   'Vous avez acheté un appareil électroménager cher il y a six semaines et il est tombé en panne. Le magasin essaie de refuser le remboursement et de vous proposer une réparation qui prendrait deux mois.',
   'Client','Responsable',
   'Bonjour. Je vois que vous venez pour rendre un produit. Pouvez-vous m''expliquer quel a été le problème ?', 6),
  (v_lang_id,'B2','Travel booking',
   'Vous appelez une agence de voyages pour organiser un voyage de noces. Vous voulez quelque chose de mémorable mais dans un budget raisonnable et vous préférez éviter les destinations bondées.',
   'Client','Agent de voyages',
   'Agence Horizons du Monde, bonjour. Ma collègue m''a dit que vous organisez un voyage spécial. Racontez-moi.', 5),
  (v_lang_id,'B2','Apartment viewing',
   'Vous visitez un appartement à louer avec votre partenaire. Il vous intéresse, mais plusieurs détails importants (humidité, cuisine vétuste, charges élevées) doivent être éclaircis avant de vous engager.',
   'Locataire potentiel','Agent immobilier',
   'Entrez, entrez. Comme vous le voyez, l''appartement est très lumineux. Quelle est votre première impression ?', 5);

  -- =========================================================
  -- C1 — READING PASSAGES (3, 250-300 words)
  -- =========================================================
  insert into public.placement_exam_reading_passages (language_id, level, passage, comprehension_questions) values
  (v_lang_id,'C1',
   'Le débat sur l''intelligence artificielle générative a gagné le monde de la création littéraire avec une virulence inattendue. Éditeurs, auteurs et traducteurs se voient contraints, presque du jour au lendemain, de prendre parti dans une discussion dont nous n''avons pas encore mesuré toutes les implications. Pour les uns, l''IA n''est qu''un nouvel outil, comparable au traitement de texte en son temps : elle facilite les tâches mécaniques et libère du temps pour ce qui est véritablement créatif. Pour d''autres, en revanche, son irruption constitue une menace structurelle, car elle abaisse radicalement le coût de production des textes et, par voie de conséquence, dévalorise le métier humain. Il est cependant clair que le problème n''est pas seulement économique. Lorsqu''un texte généré par une machine satisfait aux critères de qualité de la prose traditionnelle, des catégories aussi fondamentales que l''auctorialité, l''originalité ou la notion même de littérature s''en trouvent affectées. Ceux qui minimisent le phénomène tendent à ignorer la vitesse à laquelle évolue la technologie ; ceux qui le dramatisent, à l''inverse, oublient souvent que les lecteurs continuent de chercher une voix reconnaissable. Il est probable, en définitive, que l''équilibre finisse par s''établir dans un espace intermédiaire, encore à délimiter, où les machines assumeront le gros des tâches répétitives et où les humains se concentreront sur ce qu''aucune statistique ne saurait reproduire : l''intention, le risque et le regard propre.',
   '[
     {"question":"Quelle position défendent ceux qui minimisent l''impact de l''IA ?","correct_answer":"Que ce n''est qu''un outil de plus, comme le traitement de texte","wrong_answers":["Qu''elle remplacera entièrement les auteurs","Qu''elle n''affectera que les traductions","Qu''elle détruira le métier éditorial"]},
     {"question":"Selon le texte, pourquoi le problème n''est-il pas uniquement économique ?","correct_answer":"Parce qu''il remet en question des catégories comme l''auctorialité et l''originalité","wrong_answers":["Parce que les lecteurs ne lisent plus","Parce que les machines n''écrivent pas encore","Parce que les éditeurs sont riches"]},
     {"question":"Quelle est la prévision de l''auteur ?","correct_answer":"Qu''on parviendra à un équilibre intermédiaire encore à définir","wrong_answers":["Que les machines remplaceront les humains","Que la technologie disparaîtra","Que les éditeurs interdiront l''IA"]}
   ]'::jsonb),
  (v_lang_id,'C1',
   'L''idée selon laquelle les villes devraient s''organiser autour des personnes, et non des voitures, est formulée depuis des décennies, mais ce n''est qu''au cours des dernières années qu''elle a trouvé un écho politique sérieux. Des modèles comme celui de la « ville du quart d''heure », popularisé à Paris, prétendent que la plupart des services quotidiens — écoles, travail, commerces, loisirs — se trouvent à un quart d''heure à pied ou à vélo du domicile. Ses défenseurs soutiennent qu''un tel modèle réduit drastiquement les émissions, améliore la santé publique et, par extension, restitue aux rues une sociabilité que la motorisation massive avait reléguée au second plan. Les détracteurs, en revanche, ont ouvert un front inattendu : une partie de l''opposition a vu dans ces mesures une tentative voilée de restreindre la liberté de circulation, et a même rapproché le modèle de théories conspirationnistes. Le débat n''est donc plus seulement technique, mais profondément culturel et symbolique. Quoi qu''il en soit, il est clair que les décisions urbanistiques prises dans les prochaines années conditionneront non seulement l''air que nous respirerons, mais aussi l''idée même de communauté que nous laisserons aux générations à venir.',
   '[
     {"question":"En quoi consiste la ville du quart d''heure ?","correct_answer":"Avoir les services quotidiens à quinze minutes à pied ou à vélo","wrong_answers":["Limiter le trafic pendant quinze minutes par jour","Fermer les villes quinze jours par an","Interdire les voitures à partir de quinze heures"]},
     {"question":"Quelle critique inattendue le modèle a-t-il reçue ?","correct_answer":"Qu''il serait une forme déguisée de restriction des libertés","wrong_answers":["Qu''il coûte trop cher","Qu''il ne marche que dans les villages","Qu''il augmente la pollution"]},
     {"question":"Quelle conclusion suggère l''auteur ?","correct_answer":"Les décisions urbanistiques marqueront aussi l''idée de communauté future","wrong_answers":["Le modèle est indéfendable","L''opposition a toujours raison","Le débat est purement technique"]}
   ]'::jsonb),
  (v_lang_id,'C1',
   'Je travaille depuis plusieurs années comme traductrice littéraire et, s''il fallait résumer le métier en une seule idée, je dirais qu''il consiste à perdre avec élégance. Nous perdons toujours quelque chose — un jeu de mots, une rime, une texture sonore — et notre travail, paradoxalement, se mesure à ce que nous parvenons à conserver malgré ces pertes. Quand j''ai commencé, je croyais naïvement qu''il existait une traduction optimale attendant d''être découverte. Aujourd''hui je pense l''inverse : chaque traduction est une hypothèse que le lecteur valide ou rejette, presque à son insu, par le seul fait de continuer à lire. Pour autant, il serait erroné de croire que ce scepticisme m''a conduite à l''indifférence. Au contraire : c''est précisément parce que je sais qu''aucune version n''est définitive que les détails m''obsèdent. Une virgule déplacée peut sauver ou détruire un rythme, un mot trop savant peut briser une atmosphère populaire soigneusement construite dans l''original. Le métier, en réalité, exige un mélange d''humilité et d''arrogance : humilité pour accepter que nous perdions, arrogance pour décider, au nom d''un auteur qui ne pourra nous contredire, quelles pertes sont tolérables.',
   '[
     {"question":"Comment l''auteure résume-t-elle la traduction littéraire ?","correct_answer":"Comme un métier qui consiste à perdre avec élégance","wrong_answers":["Comme une science exacte","Comme une perte de temps","Comme une transcription mécanique"]},
     {"question":"Quelle évolution personnelle décrit-elle ?","correct_answer":"De croire en une traduction optimale à la voir comme une hypothèse","wrong_answers":["De passionnée à indifférente","D''amateur à professionnelle","D''écrivaine à éditrice"]},
     {"question":"Quelles deux qualités le métier exige-t-il, selon elle ?","correct_answer":"Humilité et arrogance, en juste mesure","wrong_answers":["Seulement patience et discipline","Érudition et rapidité","Mémoire et oreille musicale"]}
   ]'::jsonb);

  -- =========================================================
  -- C1 — VOCABULARY (10 in bank)
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, order_index) values
  (v_lang_id,'C1','vocabulary','Il convient ____ souligner que les données disponibles sont encore loin d''être concluantes.','de',array['à','en','par'],51),
  (v_lang_id,'C1','vocabulary','Tu auras beau ____, tu ne parviendras pas à le faire changer d''avis sur ce sujet.','insister',array['insistes','insisté','insistant'],52),
  (v_lang_id,'C1','vocabulary','En vertu ____ accords signés, les deux parties s''engagent à respecter le calendrier.','des',array['aux','en','par'],53),
  (v_lang_id,'C1','vocabulary','____ je l''avais su plus tôt, j''aurais pris une décision très différente.','Si',array['Quand','Comme','Bien que'],54),
  (v_lang_id,'C1','vocabulary','Le directeur, ____ le parcours est largement reconnu, prendra ses fonctions la semaine prochaine.','dont',array['que','qui','où'],55),
  (v_lang_id,'C1','vocabulary','Loin d''____ triviales, les conséquences de cette décision ont marqué tout le débat.','être',array['étant','été','est'],56),
  (v_lang_id,'C1','vocabulary','Il conviendrait d''____ les risques en détail avant d''approuver le projet.','analyser',array['analysons','analysant','analysé'],57),
  (v_lang_id,'C1','vocabulary','Il n''en ____ pas moins une option légitime, même si certains ne le pensent pas.','reste',array['restait','restera','reste pas'],58),
  (v_lang_id,'C1','vocabulary','Bien que ce plan ne me ____ pas entièrement, je le défendrai en réunion.','convainque',array['convainc','convaincu','convaincra'],59),
  (v_lang_id,'C1','vocabulary','Son discours a été si convaincant qu''il a ____ tous les doutes qui subsistaient.','dissipé',array['disposé','dispersé','distingué'],60);

  -- =========================================================
  -- C1 — DIALOGUE COMPLETION (10 in bank)
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, dialogue_lines, order_index) values
  (v_lang_id,'C1','dialogue','Complete the dialogue with an appropriate French response (at least 2 sentences, sophisticated register).','Permettez-moi de ne pas partager votre avis. Si les données paraissent claires de prime abord, il convient de nuancer plusieurs hypothèses avant d''en tirer des conclusions aussi tranchées.',array[]::text[],
   '[{"speaker":"Collègue","text":"Les résultats sont évidents : il faut accroître l''investissement dans ce domaine."},{"speaker":"Toi","text":"___"}]'::jsonb,61),
  (v_lang_id,'C1','dialogue','Complete the dialogue with an appropriate French response.','Je comprends, mais je crains que cette décision n''engendre, à moyen terme, plus de problèmes qu''elle n''en résout. Peut-être conviendrait-il de la reconsidérer.',array[]::text[],
   '[{"speaker":"Directeur","text":"La décision est prise. À partir de lundi, nous appliquons la coupe budgétaire à tous les services."},{"speaker":"Toi","text":"___"}]'::jsonb,62),
  (v_lang_id,'C1','dialogue','Complete the dialogue with an appropriate French response.','Sans entrer dans les détails, cela fait longtemps que je remets en question ma trajectoire professionnelle. Le sentiment de stagner m''a poussé à explorer des options hors du secteur traditionnel.',array[]::text[],
   '[{"speaker":"Ami","text":"Cela fait des semaines que tu as l''air préoccupé. Quelque chose de sérieux ?"},{"speaker":"Toi","text":"___"}]'::jsonb,63),
  (v_lang_id,'C1','dialogue','Complete the dialogue with an appropriate French response.','Même si j''apprécie ton travail, je dois te signaler que la dernière proposition n''a pas été à la hauteur. Reprenons cela calmement dès que tu auras un moment.',array[]::text[],
   '[{"speaker":"Employée","text":"Es-tu satisfait de la manière dont avance le projet ces derniers temps ?"},{"speaker":"Toi","text":"___"}]'::jsonb,64),
  (v_lang_id,'C1','dialogue','Complete the dialogue with an appropriate French response.','Je comprends votre position, mais je tiens à rappeler que le contrat fixe clairement un délai différent. J''espère que nous trouverons une solution sans avoir à recourir à des mesures drastiques.',array[]::text[],
   '[{"speaker":"Avocat","text":"L''entreprise soutient que les circonstances ont changé et que le délai doit être révisé."},{"speaker":"Toi","text":"___"}]'::jsonb,65),
  (v_lang_id,'C1','dialogue','Complete the dialogue with an appropriate French response.','C''est une proposition intéressante, même si la viabilité financière soulève quelques doutes. Si nous pouvions la voir par écrit, je pourrais en discuter avec mon associé avant mercredi.',array[]::text[],
   '[{"speaker":"Investisseur","text":"Seriez-vous intéressé pour rejoindre le projet que je viens de vous exposer ?"},{"speaker":"Toi","text":"___"}]'::jsonb,66),
  (v_lang_id,'C1','dialogue','Complete the dialogue with an appropriate French response.','Je vous remercie vivement pour cette offre, cependant, à ce moment de ma vie, je préfère me concentrer sur des projets personnels. Peut-être pourrons-nous reprendre cette conversation plus tard.',array[]::text[],
   '[{"speaker":"Recruteur","text":"Nous serions ravis que vous rejoigniez notre équipe internationale. Qu''en pensez-vous ?"},{"speaker":"Toi","text":"___"}]'::jsonb,67),
  (v_lang_id,'C1','dialogue','Complete the dialogue with an appropriate French response.','J''ai du mal à croire que la solution consiste à continuer d''ignorer le problème. Si tu me permets, je pense que nous avons reporté cette conversation bien trop longtemps.',array[]::text[],
   '[{"speaker":"Partenaire","text":"On devrait peut-être laisser passer quelques mois avant de parler du déménagement."},{"speaker":"Toi","text":"___"}]'::jsonb,68),
  (v_lang_id,'C1','dialogue','Complete the dialogue with an appropriate French response.','Bien que je comprenne l''argument, j''estime que le risque de ne pas agir l''emporte largement sur les inconvénients d''agir maintenant. Il convient de prendre une décision dès que possible.',array[]::text[],
   '[{"speaker":"Collègue","text":"Nous devrions peut-être attendre le prochain trimestre avant de bouger."},{"speaker":"Toi","text":"___"}]'::jsonb,69),
  (v_lang_id,'C1','dialogue','Complete the dialogue with an appropriate French response.','Je vous remercie de votre franchise. Il est probable que la décision finale ne me revienne pas, mais je porterai vos arguments à la table lors de la réunion de jeudi.',array[]::text[],
   '[{"speaker":"Client","text":"J''espère que vous tiendrez compte de nos besoins avant de signer le contrat."},{"speaker":"Consultant","text":"___"}]'::jsonb,70);

  -- =========================================================
  -- C1 — WRITING (20 in bank)
  -- 6-8 sentences, more abstract/opinion-led.
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, order_index) values
  (v_lang_id,'C1','writing','Write a 6-8 sentence French paragraph taking a clear position on whether universities should be free at the point of use.','Thesis, two arguments, anticipate a counter-argument, conclusion',array[]::text[],71),
  (v_lang_id,'C1','writing','Write a 6-8 sentence French paragraph arguing for or against a wealth tax in your country.','Position, justifications, counter, conclusion',array[]::text[],72),
  (v_lang_id,'C1','writing','Write a 6-8 sentence French paragraph reflecting on what role artificial intelligence should play in education.','Concrete examples, balanced view',array[]::text[],73),
  (v_lang_id,'C1','writing','Write a 6-8 sentence French opinion column on whether social media should be regulated as traditional media is.','Position, two arguments, counter, conclusion',array[]::text[],74),
  (v_lang_id,'C1','writing','Write a 6-8 sentence French paragraph analysing a generational divide that you have observed.','Thesis, contrast, examples, implications',array[]::text[],75),
  (v_lang_id,'C1','writing','Write a 6-8 sentence French paragraph analysing the impact of mass tourism on a city you know well.','Specific city, pros and cons, recommendation',array[]::text[],76),
  (v_lang_id,'C1','writing','Write a 6-8 sentence French paragraph explaining why you would or would not move abroad permanently.','Position, three factors, conclusion',array[]::text[],77),
  (v_lang_id,'C1','writing','Write a 6-8 sentence French paragraph on whether literary translation can ever be fully faithful.','Take a clear stance with at least one concrete example',array[]::text[],78),
  (v_lang_id,'C1','writing','Write a 6-8 sentence French paragraph about whether public art should be funded by taxes.','Position, two arguments, counter, conclusion',array[]::text[],79),
  (v_lang_id,'C1','writing','Write a 6-8 sentence French paragraph arguing whether voting should be compulsory.','Position, justifications, counter, conclusion',array[]::text[],80),
  (v_lang_id,'C1','writing','Write a 6-8 sentence French paragraph on what defines a good political leader today.','Thesis, three qualities with brief defence',array[]::text[],81),
  (v_lang_id,'C1','writing','Write a 6-8 sentence French paragraph reflecting on whether the concept of national identity still makes sense.','Thesis, historical context, examples, conclusion',array[]::text[],82),
  (v_lang_id,'C1','writing','Write a 6-8 sentence French paragraph explaining the role of failure in personal growth, using one of your own experiences.','Personal narrative + insight + general claim',array[]::text[],83),
  (v_lang_id,'C1','writing','Write a 6-8 sentence French paragraph about whether reading classic literature is still relevant.','Thesis, two arguments, counter, conclusion',array[]::text[],84),
  (v_lang_id,'C1','writing','Write a 6-8 sentence French paragraph proposing a concrete reform to improve your country''s healthcare or education system.','Diagnosis, proposal, expected effects',array[]::text[],85),
  (v_lang_id,'C1','writing','Write a 6-8 sentence French paragraph on whether economic growth and environmental protection can coexist.','Position, examples, conclusion',array[]::text[],86),
  (v_lang_id,'C1','writing','Write a 6-8 sentence French paragraph about the difference between freedom and autonomy.','Definitions, contrast, example',array[]::text[],87),
  (v_lang_id,'C1','writing','Write a 6-8 sentence French paragraph taking a position on whether companies should disclose pay scales publicly.','Thesis, two arguments, counter, conclusion',array[]::text[],88),
  (v_lang_id,'C1','writing','Write a 6-8 sentence French paragraph analysing the ethical limits of journalism in covering private lives.','Thesis, concrete examples, conclusion',array[]::text[],89),
  (v_lang_id,'C1','writing','Write a 6-8 sentence French paragraph about what your country could learn from another country''s public policies.','Specific policy, why it works there, transferability',array[]::text[],90);

  -- =========================================================
  -- C1 — ROLEPLAY TOPICS (10, pick 3)
  -- =========================================================
  insert into public.placement_exam_roleplays (language_id, level, topic_label, scenario, user_role, ai_role, ai_opener, target_exchanges) values
  (v_lang_id,'C1','Restaurant complaint',
   'Vous êtes dans un restaurant gastronomique avec un client étranger que vous voulez impressionner. L''expérience a été décevante : un plat était mal préparé et le service a été négligé. Vous voulez exprimer votre mécontentement avec élégance, sans perdre votre sang-froid.',
   'Client','Maître d''hôtel',
   'Bonsoir, je suis le maître d''hôtel. Permettez-moi de m''approcher pour m''assurer que tout est à votre convenance.', 6),
  (v_lang_id,'C1','Hotel check-in',
   'Vous assistez à un congrès international et vous arrivez à l''hôtel après un vol retardé. La chambre que l''on vous attribue ne respecte pas les exigences contractuelles que vous aviez négociées avec l''organisation.',
   'Voyageur','Réceptionniste',
   'Bonsoir, bienvenue. Je vois que votre réservation fait partie du bloc du congrès. Puis-je avoir votre passeport pour confirmer tous les détails ?', 6),
  (v_lang_id,'C1','Asking directions',
   'Vous devez vous rendre à une conférence où vous donnerez une intervention. Les indications qu''on vous a données sont confuses et il vous reste très peu de temps. Vous demandez de l''aide à un passant pressé.',
   'Intervenant','Passant',
   'Excusez-moi, vous avez l''air pressé, en quoi puis-je vous aider ? Je n''ai pas beaucoup de temps, mais je vous écoute.', 4),
  (v_lang_id,'C1','Job interview',
   'Vous passez le dernier tour d''entretien pour un poste de direction internationale. Le recruteur pose des questions exigeantes sur votre parcours, votre manière d''affronter les conflits et votre vision à cinq ans.',
   'Candidat','Directeur général',
   'Ravi de vous rencontrer enfin en personne. Commençons par quelque chose de concret : racontez-moi un échec professionnel important et ce que vous en avez appris.', 6),
  (v_lang_id,'C1','Weekend plans',
   'Vous parlez avec un vieil ami avec qui vous n''avez quasiment plus le temps de vous voir. Vos priorités pour le week-end divergent et vous devez parvenir à un compromis qui satisfasse les deux.',
   'Ami','Ami',
   'Enfin un samedi où l''on coïncide. Mais je te préviens d''emblée : je ne suis pas du tout d''humeur compliquée, je sors d''une semaine impossible.', 5),
  (v_lang_id,'C1','Complaint resolution',
   'Votre entreprise a souscrit un service critique qui défaille de façon répétée. Vous avez une réunion avec le responsable commercial du fournisseur pour réclamer formellement et négocier des compensations.',
   'Client entreprise','Responsable commercial',
   'Je vous remercie d''avoir accepté de nous rencontrer en personne. Avant de commencer, pourriez-vous m''exposer en détail ce qui s''est passé ces dernières semaines ?', 6),
  (v_lang_id,'C1','Doctor visit',
   'Vous vous rendez à une consultation de suivi après plusieurs examens. Le médecin vous annonce une nouvelle inattendue et vous propose un traitement sur lequel vous avez de sérieux doutes.',
   'Patient','Spécialiste',
   'Bonjour. J''ai relu l''ensemble des examens et, avant de parler du traitement, je voulais vous demander comment vous vous sentez et quelles questions vous sont venues.', 6),
  (v_lang_id,'C1','Shopping return',
   'Vous avez acquis il y a plusieurs mois un objet d''une certaine valeur. Un défaut est apparu, qui n''est pas de votre fait, et le magasin refuse la reprise au motif que le délai de garantie a expiré.',
   'Client','Gérant',
   'Bonsoir. On m''a dit que vous insistez pour parler à la direction. Que se passe-t-il exactement ?', 6),
  (v_lang_id,'C1','Travel booking',
   'Vous organisez un voyage de plusieurs semaines en Amérique du Sud combinant travail et vacances. Vous avez besoin de conseils sur les destinations, la logistique et un budget réaliste.',
   'Client','Agent spécialisé',
   'Bonjour. Si j''ai bien compris, vous recherchez quelque chose de plus sur mesure qu''un forfait classique. Racontez-moi en détail ce que vous avez en tête.', 5),
  (v_lang_id,'C1','Apartment viewing',
   'Vous visitez un appartement de haut standing en vue de le louer. Plusieurs aspects pratiques et contractuels doivent être négociés avant de vous engager.',
   'Locataire potentiel','Agent immobilier',
   'Entrez, je vous en prie. C''est l''un des appartements les plus recherchés du quartier, vous imaginez donc que nous avons une certaine liste d''attente. Que souhaitez-vous voir en premier ?', 6);

end $$;

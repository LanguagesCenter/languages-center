-- 048_french_placement_a1_a2.sql
-- Seed French A1/A2 placement-exam content, mirroring the Spanish v2 structure:
--   - 3 reading passages per level + 3 comprehension MC questions each
--   - 10 vocabulary MC per level (full-sentence context; pick 5 per attempt)
--   - 10 dialogue completion per level (pick 5)
--   - 20 listening prompts per level (pick 10)
--   - 20 speaking topics per level (pick 10)
--   - 20 writing prompts per level (pick 10)
-- Pass mark is 75% (enforced in app code).
--
-- Schema is already defined in 036_placement_exam_v2.sql. This file only seeds.
-- Idempotent: deletes any existing French A1/A2 rows before re-inserting.

do $$
declare
  v_lang_id bigint;
begin
  select id into v_lang_id from public.languages where code = 'french';
  if v_lang_id is null then raise exception 'French language not found'; end if;

  delete from public.placement_exam_questions where language_id = v_lang_id and level in ('A1','A2');
  delete from public.placement_exam_reading_passages where language_id = v_lang_id and level in ('A1','A2');

  -- =========================================================
  -- A1 — READING PASSAGES (3 total: pick 1 per attempt)
  -- =========================================================
  insert into public.placement_exam_reading_passages (language_id, level, passage, comprehension_questions) values
  (v_lang_id,'A1',
   'Je m''appelle Sophie et j''ai vingt-cinq ans. J''habite à Paris avec ma famille. Je suis étudiante en médecine. Le matin, je vais à l''université en bus et l''après-midi, j''étudie à la bibliothèque. J''aime le café au lait et les croissants. Le week-end, je rends visite à mes grands-parents à la campagne.',
   '[
     {"question":"Quel âge a Sophie ?","correct_answer":"Vingt-cinq ans","wrong_answers":["Quinze ans","Trente ans","Cinquante ans"]},
     {"question":"Comment Sophie va-t-elle à l''université ?","correct_answer":"En bus","wrong_answers":["En voiture","En train","À pied"]},
     {"question":"Qui visite-t-elle le week-end ?","correct_answer":"Ses grands-parents","wrong_answers":["Ses amis","Ses parents","Ses frères"]}
   ]'::jsonb),
  (v_lang_id,'A1',
   'Bonjour, je suis Marc. J''habite à Marseille et je travaille dans un petit restaurant près de la plage. Ma famille est grande : j''ai deux sœurs et un frère. Le dimanche, nous mangeons du poisson chez ma mère. Le soir, j''aime écouter de la musique et lire des livres. Demain, c''est mon anniversaire et je vais faire la fête avec mes amis.',
   '[
     {"question":"Où travaille Marc ?","correct_answer":"Dans un restaurant","wrong_answers":["À la plage","Dans un magasin","Dans une école"]},
     {"question":"Combien de frères et sœurs a-t-il en tout ?","correct_answer":"Trois","wrong_answers":["Deux","Un","Quatre"]},
     {"question":"Que va-t-il faire demain ?","correct_answer":"Fêter son anniversaire","wrong_answers":["Travailler au restaurant","Aller à la plage","Rendre visite à sa mère"]}
   ]'::jsonb),
  (v_lang_id,'A1',
   'Mon amie Laure est professeur d''anglais. Elle a trente ans et elle habite dans un petit appartement au centre de Lyon. Elle a un chat noir qui s''appelle Lune. Le matin, Laure prend du thé avec des tartines. Elle aime se promener dans le parc et acheter des fleurs le samedi. En été, elle voyage à la mer avec son copain.',
   '[
     {"question":"Que fait Laure ?","correct_answer":"Elle est professeur d''anglais","wrong_answers":["Elle est étudiante","Elle est médecin","Elle est cuisinière"]},
     {"question":"De quelle couleur est son chat ?","correct_answer":"Noir","wrong_answers":["Blanc","Gris","Marron"]},
     {"question":"Que boit-elle le matin ?","correct_answer":"Du thé","wrong_answers":["Du café","De l''eau","Du jus"]}
   ]'::jsonb);

  -- =========================================================
  -- A1 — VOCABULARY (10 in bank, pick 5)
  -- Full-sentence MC. Choose the word that completes the sentence.
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, order_index) values
  (v_lang_id,'A1','vocabulary','Le matin, mon père prend un _____ au lait.','café',array['chaise','soleil','chien'],1),
  (v_lang_id,'A1','vocabulary','Ma sœur a un chien et un _____ blanc.','chat',array['livre','arbre','eau'],2),
  (v_lang_id,'A1','vocabulary','Aujourd''hui il fait très froid, je vais mettre mon _____ bleu.','manteau',array['chaussure','eau','fleur'],3),
  (v_lang_id,'A1','vocabulary','Quelle heure est-il ? Il est trois heures de l''_____.','après-midi',array['maison','semaine','table'],4),
  (v_lang_id,'A1','vocabulary','Au petit-déjeuner, je mange du pain avec du _____ et un œuf.','fromage',array['chaise','fenêtre','arbre'],5),
  (v_lang_id,'A1','vocabulary','Ma grand-mère habite dans une très _____ maison.','grande',array['rapide','triste','bon marché'],6),
  (v_lang_id,'A1','vocabulary','Je vais au supermarché pour acheter des fruits et des _____.','légumes',array['livres','chaussures','chaises'],7),
  (v_lang_id,'A1','vocabulary','Ma mère travaille dans un _____ comme médecin.','hôpital',array['restaurant','cinéma','parc'],8),
  (v_lang_id,'A1','vocabulary','Le samedi, je joue au foot avec mes _____.','amis',array['livres','cours','chaussures'],9),
  (v_lang_id,'A1','vocabulary','J''ai très soif, je veux un verre d''_____.','eau',array['pain','fromage','soleil'],10);

  -- =========================================================
  -- A1 — DIALOGUE COMPLETION (10 in bank, pick 5)
  -- dialogue_lines = [{speaker, text}, ...] with last line missing.
  -- correct_answer = one acceptable French response used as reference for the AI grader.
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, dialogue_lines, order_index) values
  (v_lang_id,'A1','dialogue','Complete the dialogue with an appropriate French response.','Je m''appelle Anne',array[]::text[],
    '[{"speaker":"A","text":"Salut ! Comment tu t''appelles ?"},{"speaker":"B","text":"___"}]'::jsonb,11),
  (v_lang_id,'A1','dialogue','Complete the dialogue with an appropriate French response.','J''ai vingt ans',array[]::text[],
    '[{"speaker":"A","text":"Quel âge as-tu ?"},{"speaker":"B","text":"___"}]'::jsonb,12),
  (v_lang_id,'A1','dialogue','Complete the dialogue with an appropriate French response.','Je viens de France',array[]::text[],
    '[{"speaker":"A","text":"D''où viens-tu ?"},{"speaker":"B","text":"___"}]'::jsonb,13),
  (v_lang_id,'A1','dialogue','Complete the dialogue with an appropriate French response.','Ça va bien, merci',array[]::text[],
    '[{"speaker":"A","text":"Comment ça va aujourd''hui ?"},{"speaker":"B","text":"___"}]'::jsonb,14),
  (v_lang_id,'A1','dialogue','Complete the dialogue with an appropriate French response.','Il est huit heures',array[]::text[],
    '[{"speaker":"A","text":"Quelle heure est-il ?"},{"speaker":"B","text":"___"}]'::jsonb,15),
  (v_lang_id,'A1','dialogue','Complete the dialogue with an appropriate French response.','J''aime la pizza',array[]::text[],
    '[{"speaker":"A","text":"Quelle nourriture aimes-tu ?"},{"speaker":"B","text":"___"}]'::jsonb,16),
  (v_lang_id,'A1','dialogue','Complete the dialogue with an appropriate French response.','J''habite à Paris',array[]::text[],
    '[{"speaker":"A","text":"Où habites-tu ?"},{"speaker":"B","text":"___"}]'::jsonb,17),
  (v_lang_id,'A1','dialogue','Complete the dialogue with an appropriate French response.','J''ai deux frères',array[]::text[],
    '[{"speaker":"A","text":"Combien de frères et sœurs as-tu ?"},{"speaker":"B","text":"___"}]'::jsonb,18),
  (v_lang_id,'A1','dialogue','Complete the dialogue with an appropriate French response.','À demain',array[]::text[],
    '[{"speaker":"A","text":"Bon, on se voit plus tard."},{"speaker":"B","text":"___"}]'::jsonb,19),
  (v_lang_id,'A1','dialogue','Complete the dialogue with an appropriate French response.','Je voudrais un café, s''il vous plaît',array[]::text[],
    '[{"speaker":"Serveur","text":"Que désirez-vous boire ?"},{"speaker":"Client","text":"___"}]'::jsonb,20);

  -- =========================================================
  -- A1 — LISTENING (20 in bank, pick 10)
  -- TTS reads question (short French prompt). User types a French response.
  -- correct_answer = one acceptable reference response for the AI grader.
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, order_index) values
  (v_lang_id,'A1','listening','Salut, comment tu t''appelles ?','Je m''appelle Anne',array[]::text[],21),
  (v_lang_id,'A1','listening','Tu viens d''où ?','Je viens de France',array[]::text[],22),
  (v_lang_id,'A1','listening','Quel âge as-tu ?','J''ai vingt ans',array[]::text[],23),
  (v_lang_id,'A1','listening','Quelle heure est-il ?','Il est neuf heures du matin',array[]::text[],24),
  (v_lang_id,'A1','listening','Où habites-tu ?','J''habite à Lyon',array[]::text[],25),
  (v_lang_id,'A1','listening','Qu''est-ce que tu aimes manger ?','J''aime les pâtes',array[]::text[],26),
  (v_lang_id,'A1','listening','Tu as des frères et sœurs ?','Oui, j''ai deux frères',array[]::text[],27),
  (v_lang_id,'A1','listening','Quel temps fait-il aujourd''hui ?','Il fait très beau',array[]::text[],28),
  (v_lang_id,'A1','listening','Qu''est-ce que tu fais le week-end ?','Je sors avec mes amis',array[]::text[],29),
  (v_lang_id,'A1','listening','À quelle heure te lèves-tu ?','Je me lève à sept heures',array[]::text[],30),
  (v_lang_id,'A1','listening','Tu travailles ou tu étudies ?','Je suis étudiant',array[]::text[],31),
  (v_lang_id,'A1','listening','Quelle est ta couleur préférée ?','Ma couleur préférée est le bleu',array[]::text[],32),
  (v_lang_id,'A1','listening','Quel jour sommes-nous aujourd''hui ?','Aujourd''hui, c''est mardi',array[]::text[],33),
  (v_lang_id,'A1','listening','Tu as un animal à la maison ?','Oui, j''ai un chat',array[]::text[],34),
  (v_lang_id,'A1','listening','Qu''est-ce que tu prends au petit-déjeuner ?','Je prends du café et des tartines',array[]::text[],35),
  (v_lang_id,'A1','listening','Quelle est ta saison préférée ?','Ma saison préférée est l''été',array[]::text[],36),
  (v_lang_id,'A1','listening','Comment viens-tu en cours ?','Je viens en bus',array[]::text[],37),
  (v_lang_id,'A1','listening','Quand est ton anniversaire ?','Mon anniversaire est en mai',array[]::text[],38),
  (v_lang_id,'A1','listening','Quels sports aimes-tu ?','J''aime le football',array[]::text[],39),
  (v_lang_id,'A1','listening','Tu es fatigué aujourd''hui ?','Non, ça va bien',array[]::text[],40);

  -- =========================================================
  -- A1 — SPEAKING (20 in bank, pick 10)
  -- topic_prompt is the English instruction shown on screen.
  -- correct_answer is a brief English reference outline used by the AI grader.
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, topic_prompt, order_index) values
  (v_lang_id,'A1','speaking','Speak in French about yourself.','Name, age, where you live and study/work',array[]::text[],
   'Introduce yourself in French. Say your name, your age, where you are from and where you live. Speak for 1-2 minutes.',41),
  (v_lang_id,'A1','speaking','Describe your family in French.','Members of family with simple descriptions',array[]::text[],
   'Describe your family in French. Talk about how many people are in your family and what they are like. Speak for 1-2 minutes.',42),
  (v_lang_id,'A1','speaking','Talk about your daily routine in French.','Wake up, eat, work/study, evening',array[]::text[],
   'Describe a typical day in your life in French. What do you do in the morning, afternoon and evening? Speak for 1-2 minutes.',43),
  (v_lang_id,'A1','speaking','Describe your house or apartment in French.','Rooms, what they look like',array[]::text[],
   'Describe where you live in French. What rooms does it have? What do you like about it? Speak for 1-2 minutes.',44),
  (v_lang_id,'A1','speaking','Talk about your hobbies in French.','Activities you like, when you do them',array[]::text[],
   'Talk about your hobbies and free-time activities in French. What do you like to do? Speak for 1-2 minutes.',45),
  (v_lang_id,'A1','speaking','Describe your favourite food in French.','Dish name, ingredients, why you like it',array[]::text[],
   'Describe your favourite food or meal in French. What is it and why do you like it? Speak for 1-2 minutes.',46),
  (v_lang_id,'A1','speaking','Talk about a friend in French.','Name, age, what they are like',array[]::text[],
   'Describe a close friend in French. Say their name, age and what they are like. Speak for 1-2 minutes.',47),
  (v_lang_id,'A1','speaking','Describe the weather where you live in French.','Seasons, temperature, what you wear',array[]::text[],
   'Describe the weather where you live across the four seasons, in French. Speak for 1-2 minutes.',48),
  (v_lang_id,'A1','speaking','Talk about your studies or job in French.','What you do, where, what hours',array[]::text[],
   'Talk about your studies or your job in French. What do you do? Where do you go? Speak for 1-2 minutes.',49),
  (v_lang_id,'A1','speaking','Describe your hometown in French.','Name, size, what there is to do',array[]::text[],
   'Describe your hometown in French. What is it called, what is it like, what is there to do? Speak for 1-2 minutes.',50),
  (v_lang_id,'A1','speaking','Talk about what you eat in a typical day in French.','Breakfast, lunch and dinner',array[]::text[],
   'Describe what you eat in a typical day in French: breakfast, lunch and dinner. Speak for 1-2 minutes.',51),
  (v_lang_id,'A1','speaking','Describe your favourite sport in French.','Sport name, when, with whom',array[]::text[],
   'Talk about a sport or activity you like to watch or play, in French. Speak for 1-2 minutes.',52),
  (v_lang_id,'A1','speaking','Talk about a holiday or trip you went on in French.','Where, when, what you did',array[]::text[],
   'Describe a holiday or short trip in French. Where did you go? What did you do? Speak for 1-2 minutes.',53),
  (v_lang_id,'A1','speaking','Talk about clothes you wear in French.','Items, colours, when',array[]::text[],
   'Describe the clothes you usually wear, in French. Speak for 1-2 minutes.',54),
  (v_lang_id,'A1','speaking','Describe your weekend in French.','Saturday and Sunday activities',array[]::text[],
   'Describe what you usually do on Saturdays and Sundays, in French. Speak for 1-2 minutes.',55),
  (v_lang_id,'A1','speaking','Talk about a person you admire in French.','Who, why, what they do',array[]::text[],
   'Talk about someone in your family or a friend that you admire and why, in French. Speak for 1-2 minutes.',56),
  (v_lang_id,'A1','speaking','Describe a typical breakfast in your country in French.','Food, drinks',array[]::text[],
   'Describe a typical breakfast in your country, in French. Speak for 1-2 minutes.',57),
  (v_lang_id,'A1','speaking','Talk about your favourite music in French.','Genre, artists, when you listen',array[]::text[],
   'Talk about the music you like, in French. Speak for 1-2 minutes.',58),
  (v_lang_id,'A1','speaking','Describe how you go to work or school in French.','Transport, time, route',array[]::text[],
   'Describe how you go to work or school each day, in French. Speak for 1-2 minutes.',59),
  (v_lang_id,'A1','speaking','Talk about your favourite season in French.','Season, weather, activities',array[]::text[],
   'Talk about which season of the year you like best and why, in French. Speak for 1-2 minutes.',60);

  -- =========================================================
  -- A1 — WRITING (20 in bank, pick 10)
  -- English prompt → user writes 2-3 French sentences.
  -- correct_answer is a brief reference outline used by the AI grader.
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, order_index) values
  (v_lang_id,'A1','writing','Write 2-3 French sentences introducing yourself (name, age, country).','Bonjour, je m''appelle X. J''ai X ans. Je viens de X.',array[]::text[],61),
  (v_lang_id,'A1','writing','Write 2-3 French sentences about your family.','Mention how many people are in your family and a few names',array[]::text[],62),
  (v_lang_id,'A1','writing','Write 2-3 French sentences describing your house or flat.','Rooms it has, what you like',array[]::text[],63),
  (v_lang_id,'A1','writing','Write 2-3 French sentences about what you ate yesterday.','Breakfast, lunch and dinner with simple foods',array[]::text[],64),
  (v_lang_id,'A1','writing','Write 2-3 French sentences describing the weather today.','Use "il fait" + beau, froid, chaud, pluie',array[]::text[],65),
  (v_lang_id,'A1','writing','Write 2-3 French sentences about your hobbies.','Activities you do in your free time',array[]::text[],66),
  (v_lang_id,'A1','writing','Write 2-3 French sentences describing your best friend.','Name, age, what they are like',array[]::text[],67),
  (v_lang_id,'A1','writing','Write 2-3 French sentences about your daily routine in the morning.','Wake up, breakfast, leave the house',array[]::text[],68),
  (v_lang_id,'A1','writing','Write 2-3 French sentences about a typical Saturday.','What you do on Saturday',array[]::text[],69),
  (v_lang_id,'A1','writing','Write 2-3 French sentences about your favourite restaurant.','Name, type of food, why you like it',array[]::text[],70),
  (v_lang_id,'A1','writing','Write 2-3 French sentences describing a friend''s family.','Members, ages, what they do',array[]::text[],71),
  (v_lang_id,'A1','writing','Write 2-3 French sentences about what clothes you wear in winter.','Items, colour, why',array[]::text[],72),
  (v_lang_id,'A1','writing','Write 2-3 French sentences about a city you would like to visit.','Name, country, what there is',array[]::text[],73),
  (v_lang_id,'A1','writing','Write 2-3 French sentences about your favourite drink.','Drink, when you drink it',array[]::text[],74),
  (v_lang_id,'A1','writing','Write 2-3 French sentences ordering food at a restaurant.','Je voudrais..., s''il vous plaît, merci',array[]::text[],75),
  (v_lang_id,'A1','writing','Write 2-3 French sentences about your favourite season and why.','Season, weather, activity',array[]::text[],76),
  (v_lang_id,'A1','writing','Write 2-3 French sentences inviting a friend to a party.','Day, time, place',array[]::text[],77),
  (v_lang_id,'A1','writing','Write 2-3 French sentences describing a typical breakfast.','Coffee, bread, fruit etc.',array[]::text[],78),
  (v_lang_id,'A1','writing','Write 2-3 French sentences about your country.','Capital, language, food',array[]::text[],79),
  (v_lang_id,'A1','writing','Write 2-3 French sentences saying what you do in the evening.','Dinner, TV, family, sleep',array[]::text[],80);

  -- =========================================================
  -- A2 — READING PASSAGES (3 total)
  -- =========================================================
  insert into public.placement_exam_reading_passages (language_id, level, passage, comprehension_questions) values
  (v_lang_id,'A2',
   'L''année dernière, mon amie Hélène et moi avons décidé de faire un voyage à Strasbourg parce que nous n''avions jamais visité la cathédrale. Nous avons réservé un petit hôtel près du centre et nous avons acheté les billets sur internet. Nous sommes arrivés un vendredi après-midi, après cinq heures de train. Le samedi, nous nous sommes levés très tôt pour visiter la cathédrale : c''était impressionnant. L''après-midi, nous nous sommes promenés dans le quartier de la Petite France et nous avons dîné dans une brasserie traditionnelle. Le dimanche, avant de rentrer, nous avons acheté quelques souvenirs pour nos familles.',
   '[
     {"question":"Pourquoi ont-elles décidé de voyager à Strasbourg ?","correct_answer":"Pour visiter la cathédrale","wrong_answers":["Pour voir un proche","Pour assister à un concert","Pour suivre un cours"]},
     {"question":"Comment sont-elles arrivées à Strasbourg ?","correct_answer":"En train","wrong_answers":["En avion","En voiture","En bus"]},
     {"question":"Qu''ont-elles fait avant de rentrer ?","correct_answer":"Elles ont acheté des souvenirs","wrong_answers":["Elles ont visité un autre musée","Elles ont mangé dans une autre brasserie","Elles se sont promenées au bord du fleuve"]}
   ]'::jsonb),
  (v_lang_id,'A2',
   'Je m''appelle Paul et je travaille comme réceptionniste dans un hôtel du centre de Bordeaux. J''ai commencé ce travail il y a deux ans, juste après avoir terminé mes études. Avant ce poste, j''avais travaillé dans un café pendant l''été. Mon emploi du temps n''est pas toujours facile parce que je dois parfois faire des nuits, mais j''aime rencontrer des gens de beaucoup de pays. La semaine dernière, des touristes japonais sont venus ; ils ne parlaient pas français et j''ai essayé de les aider en anglais. Quand je finis le travail, je vais souvent à la salle de sport et ensuite je dîne à la maison avec ma compagne.',
   '[
     {"question":"Depuis combien de temps Paul fait-il ce travail ?","correct_answer":"Deux ans","wrong_answers":["Six mois","Cinq ans","Dix ans"]},
     {"question":"Qu''a-t-il fait avant d''être réceptionniste ?","correct_answer":"Il a travaillé dans un café","wrong_answers":["Il a étudié à l''étranger","Il a vécu au Japon","Il a enseigné l''anglais"]},
     {"question":"Que fait-il normalement après le travail ?","correct_answer":"Il va à la salle de sport et dîne à la maison","wrong_answers":["Il sort avec ses amis dans un bar","Il étudie le japonais","Il va au cinéma avec sa compagne"]}
   ]'::jsonb),
  (v_lang_id,'A2',
   'Il y a quelques mois, j''ai changé d''appartement parce que l''ancien était trop loin du centre. Maintenant, j''habite dans un appartement lumineux avec deux balcons et une cuisine neuve. Je l''ai trouvé grâce à une collègue de travail qui connaissait le propriétaire. Le loyer est un peu plus cher, mais maintenant je vais au bureau à vélo et je mets seulement quinze minutes. Le week-end, j''invite mes amis à dîner ; nous aimons cuisiner ensemble et après regarder un film. Si je pouvais, je resterais ici pendant de nombreuses années.',
   '[
     {"question":"Pourquoi a-t-il changé d''appartement ?","correct_answer":"Parce que le précédent était loin du centre","wrong_answers":["Parce qu''il était trop cher","Parce qu''il était trop bruyant","Parce qu''il était petit"]},
     {"question":"Comment a-t-il trouvé le nouvel appartement ?","correct_answer":"Grâce à une collègue de travail","wrong_answers":["Sur internet","Par une agence","Par une annonce dans la rue"]},
     {"question":"Comment va-t-il au travail maintenant ?","correct_answer":"À vélo","wrong_answers":["À pied","En voiture","En métro"]}
   ]'::jsonb);

  -- =========================================================
  -- A2 — VOCABULARY (10 in bank)
  -- Full-sentence context, more complex than A1 (tense, gender, register).
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, order_index) values
  (v_lang_id,'A2','vocabulary','Bien qu''il fût très fatigué, mon frère _____ à travailler jusque tard.','a continué',array['a commencé','a perdu','a appelé'],1),
  (v_lang_id,'A2','vocabulary','Quand j''étais petit, je _____ les étés chez mes grands-parents.','passais',array['passe','passerai','ai passé'],2),
  (v_lang_id,'A2','vocabulary','Le médecin m''a recommandé de _____ moins de café et plus d''eau.','boire',array['buvais','bois','boirai'],3),
  (v_lang_id,'A2','vocabulary','Si j''avais plus de temps libre, j''_____ apprendre à jouer du piano.','aimerais',array['aime','ai aimé','aimais'],4),
  (v_lang_id,'A2','vocabulary','J''ai une réunion à neuf heures, donc je dois _____ tôt.','me lever',array['me coucher','m''asseoir','rester'],5),
  (v_lang_id,'A2','vocabulary','Après une très longue journée, je n''étais pas encore _____ au lit.','allé',array['allant','aller','ira'],6),
  (v_lang_id,'A2','vocabulary','Je n''aime pas ce restaurant parce que la nourriture est trop _____.','salée',array['salé','salées','salés'],7),
  (v_lang_id,'A2','vocabulary','Ma professeure parle très vite et parfois je ne _____ pas tout ce qu''elle dit.','comprends',array['comprendre','compris','comprenez'],8),
  (v_lang_id,'A2','vocabulary','S''il te plaît, _____ la fenêtre, il fait très chaud ici.','ouvre',array['ouvert','ouvrant','ouvrir'],9),
  (v_lang_id,'A2','vocabulary','Ma voisine est très gentille ; elle m''_____ toujours avec les sacs lourds.','aide',array['aidais','aidé','aiderai'],10);

  -- =========================================================
  -- A2 — DIALOGUE COMPLETION (10 in bank)
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, dialogue_lines, order_index) values
  (v_lang_id,'A2','dialogue','Complete the dialogue with an appropriate French response.','Je suis allé à la plage avec mes amis',array[]::text[],
   '[{"speaker":"A","text":"Qu''est-ce que tu as fait le week-end dernier ?"},{"speaker":"B","text":"___"}]'::jsonb,11),
  (v_lang_id,'A2','dialogue','Complete the dialogue with an appropriate French response.','Bien sûr, je vous recommande le poisson',array[]::text[],
   '[{"speaker":"Client","text":"Pourriez-vous me recommander un plat ?"},{"speaker":"Serveur","text":"___"}]'::jsonb,12),
  (v_lang_id,'A2','dialogue','Complete the dialogue with an appropriate French response.','J''ai très mal à la tête',array[]::text[],
   '[{"speaker":"Médecin","text":"Bonjour, qu''est-ce qui ne va pas ?"},{"speaker":"Patient","text":"___"}]'::jsonb,13),
  (v_lang_id,'A2','dialogue','Complete the dialogue with an appropriate French response.','Désolé, j''ai déjà des projets',array[]::text[],
   '[{"speaker":"A","text":"Tu veux venir au cinéma avec moi ce soir ?"},{"speaker":"B","text":"___"}]'::jsonb,14),
  (v_lang_id,'A2','dialogue','Complete the dialogue with an appropriate French response.','Le prochain train part à dix heures',array[]::text[],
   '[{"speaker":"Voyageur","text":"Excusez-moi, quand part le prochain train pour Lyon ?"},{"speaker":"Employé","text":"___"}]'::jsonb,15),
  (v_lang_id,'A2','dialogue','Complete the dialogue with an appropriate French response.','Oui, elle est à côté de la banque',array[]::text[],
   '[{"speaker":"Touriste","text":"Pardon, y a-t-il une pharmacie près d''ici ?"},{"speaker":"Habitant","text":"___"}]'::jsonb,16),
  (v_lang_id,'A2','dialogue','Complete the dialogue with an appropriate French response.','Non, je n''ai pas encore fini',array[]::text[],
   '[{"speaker":"Chef","text":"Tu as déjà terminé le rapport ?"},{"speaker":"Employé","text":"___"}]'::jsonb,17),
  (v_lang_id,'A2','dialogue','Complete the dialogue with an appropriate French response.','Je préfère la chambre avec vue sur la mer',array[]::text[],
   '[{"speaker":"Réceptionniste","text":"Laquelle des deux chambres préférez-vous ?"},{"speaker":"Client","text":"___"}]'::jsonb,18),
  (v_lang_id,'A2','dialogue','Complete the dialogue with an appropriate French response.','D''accord, je t''appelle quand j''arrive',array[]::text[],
   '[{"speaker":"A","text":"Préviens-moi quand tu es à la maison, s''il te plaît."},{"speaker":"B","text":"___"}]'::jsonb,19),
  (v_lang_id,'A2','dialogue','Complete the dialogue with an appropriate French response.','Ça fait deux ans que j''habite ici',array[]::text[],
   '[{"speaker":"A","text":"Depuis combien de temps habites-tu dans cette ville ?"},{"speaker":"B","text":"___"}]'::jsonb,20);

  -- =========================================================
  -- A2 — LISTENING (20 in bank)
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, order_index) values
  (v_lang_id,'A2','listening','Qu''est-ce que tu as fait le week-end dernier ?','Samedi, je suis allé au cinéma et dimanche, je me suis reposé à la maison',array[]::text[],21),
  (v_lang_id,'A2','listening','As-tu déjà voyagé à l''étranger ?','Oui, j''ai voyagé en Espagne et en Italie',array[]::text[],22),
  (v_lang_id,'A2','listening','Quel genre de musique écoutais-tu quand tu étais adolescent ?','J''écoutais surtout du rock et de la pop',array[]::text[],23),
  (v_lang_id,'A2','listening','Comment était ta première école ?','C''était une petite école avec beaucoup d''arbres',array[]::text[],24),
  (v_lang_id,'A2','listening','Quels sont tes projets pour l''été ?','Je vais voyager sur la côte avec ma famille',array[]::text[],25),
  (v_lang_id,'A2','listening','Aimerais-tu vivre dans une autre ville ?','J''aimerais vivre à Paris un jour',array[]::text[],26),
  (v_lang_id,'A2','listening','Depuis combien de temps étudies-tu le français ?','J''étudie le français depuis deux ans',array[]::text[],27),
  (v_lang_id,'A2','listening','Qu''est-ce que tu as fait hier après le travail ?','Je suis allé à la salle de sport et j''ai dîné avec ma compagne',array[]::text[],28),
  (v_lang_id,'A2','listening','Te souviens-tu d''un voyage spécial que tu as fait ?','Je me souviens d''un voyage à la plage l''année dernière',array[]::text[],29),
  (v_lang_id,'A2','listening','Quel problème as-tu eu la dernière fois que tu as voyagé ?','J''ai perdu ma valise à l''aéroport',array[]::text[],30),
  (v_lang_id,'A2','listening','Quel conseil donnerais-tu à quelqu''un qui apprend le français ?','Je lui dirais de pratiquer tous les jours',array[]::text[],31),
  (v_lang_id,'A2','listening','Comment fêtais-tu ton anniversaire quand tu étais enfant ?','Je le fêtais avec une fête à la maison',array[]::text[],32),
  (v_lang_id,'A2','listening','Qu''est-ce que tu aimes faire pendant ton temps libre ?','J''aime lire et sortir avec des amis',array[]::text[],33),
  (v_lang_id,'A2','listening','Qu''est-ce que tu as pris au petit-déjeuner ce matin ?','J''ai pris un café au lait et une tartine',array[]::text[],34),
  (v_lang_id,'A2','listening','As-tu déjà travaillé dans un restaurant ?','Oui, j''ai travaillé comme serveuse en été',array[]::text[],35),
  (v_lang_id,'A2','listening','Quel temps faisait-il le week-end dernier ?','Il a fait très froid et il a plu',array[]::text[],36),
  (v_lang_id,'A2','listening','Quels sports pratiquais-tu à l''école ?','Je jouais au basket et je nageais',array[]::text[],37),
  (v_lang_id,'A2','listening','Quel est ton plat préféré et comment le prépare-t-on ?','Mon plat préféré est le bœuf bourguignon, on le fait avec du bœuf et du vin rouge',array[]::text[],38),
  (v_lang_id,'A2','listening','Que ferais-tu si tu gagnais à la loterie ?','J''achèterais une maison et je voyagerais à travers le monde',array[]::text[],39),
  (v_lang_id,'A2','listening','Pourquoi as-tu décidé d''apprendre le français ?','J''ai décidé de l''apprendre parce que je veux voyager en France',array[]::text[],40);

  -- =========================================================
  -- A2 — SPEAKING (20 in bank)
  -- 2-3 min monologues.
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, topic_prompt, order_index) values
  (v_lang_id,'A2','speaking','Describe a memorable trip you took in French.','Where, when, what you did, how you felt',array[]::text[],
   'Describe a trip or holiday you remember well, in French. Where did you go, what did you do and how did you feel? Speak for 2-3 minutes.',41),
  (v_lang_id,'A2','speaking','Describe your studies or career so far in French.','What you studied, where you have worked, future plans',array[]::text[],
   'Talk about your studies and your work so far, in French. What have you studied, where have you worked, what are your plans? Speak for 2-3 minutes.',42),
  (v_lang_id,'A2','speaking','Compare life in a big city and in a small town in French.','At least two contrasts and your preference',array[]::text[],
   'Compare life in a big city with life in a small town, in French. Mention advantages, disadvantages and your preference. Speak for 2-3 minutes.',43),
  (v_lang_id,'A2','speaking','Describe your perfect weekend in French.','Friday evening to Sunday with activities',array[]::text[],
   'Describe your ideal weekend from Friday evening to Sunday night, in French. Speak for 2-3 minutes.',44),
  (v_lang_id,'A2','speaking','Talk about a problem you solved recently in French.','The problem, what you did, the outcome',array[]::text[],
   'Talk about a problem you had recently and how you solved it, in French. Speak for 2-3 minutes.',45),
  (v_lang_id,'A2','speaking','Describe your favourite restaurant in French.','Name, location, dishes, atmosphere, why you like it',array[]::text[],
   'Describe a restaurant you really like, in French. Talk about the food, the atmosphere and why you return. Speak for 2-3 minutes.',46),
  (v_lang_id,'A2','speaking','Talk about how technology has changed your life in French.','Phone, internet, work, family',array[]::text[],
   'Talk about how technology has changed your daily life, in French. Speak for 2-3 minutes.',47),
  (v_lang_id,'A2','speaking','Describe a film or series you enjoyed in French.','Title, plot, characters, your opinion',array[]::text[],
   'Describe a film or series you enjoyed recently, in French. Speak for 2-3 minutes.',48),
  (v_lang_id,'A2','speaking','Talk about your country in French.','Capital, food, traditions, climate',array[]::text[],
   'Talk about your country in French: its capital, traditions, food and climate. Speak for 2-3 minutes.',49),
  (v_lang_id,'A2','speaking','Describe a goal you have for the next year in French.','The goal, why it matters, how you''ll achieve it',array[]::text[],
   'Describe a personal goal for the next twelve months, in French. Why is it important and how will you achieve it? Speak for 2-3 minutes.',50),
  (v_lang_id,'A2','speaking','Talk about a person who has been important in your life in French.','Who they are, why they matter, an example',array[]::text[],
   'Talk about someone who has been important in your life and why, in French. Speak for 2-3 minutes.',51),
  (v_lang_id,'A2','speaking','Describe a routine you would like to change in French.','What you do now, why, what you want to do',array[]::text[],
   'Describe a habit or routine you would like to change and explain why, in French. Speak for 2-3 minutes.',52),
  (v_lang_id,'A2','speaking','Talk about a celebration in your country in French.','Holiday name, when, what people do',array[]::text[],
   'Describe an important festival or holiday in your country, in French. Speak for 2-3 minutes.',53),
  (v_lang_id,'A2','speaking','Describe the best teacher you have ever had in French.','Subject, personality, why they were special',array[]::text[],
   'Talk about the best teacher you ever had and why, in French. Speak for 2-3 minutes.',54),
  (v_lang_id,'A2','speaking','Talk about advantages and disadvantages of working from home in French.','At least two pros and two cons',array[]::text[],
   'Discuss the advantages and disadvantages of working from home, in French. Speak for 2-3 minutes.',55),
  (v_lang_id,'A2','speaking','Describe how you spend a typical Sunday in French.','Morning, afternoon, evening',array[]::text[],
   'Describe what a typical Sunday looks like for you, in French. Speak for 2-3 minutes.',56),
  (v_lang_id,'A2','speaking','Talk about a sport or activity you used to do as a child in French.','Activity, when, with whom, why you stopped',array[]::text[],
   'Talk about a sport or activity you used to do as a child but no longer do, in French. Speak for 2-3 minutes.',57),
  (v_lang_id,'A2','speaking','Describe what you would change about your hometown in French.','At least two changes and why',array[]::text[],
   'Describe two or three things you would change about your hometown and why, in French. Speak for 2-3 minutes.',58),
  (v_lang_id,'A2','speaking','Talk about a book you have read recently in French.','Title, author, what it is about, your opinion',array[]::text[],
   'Talk about a book or article you have read recently, in French. Speak for 2-3 minutes.',59),
  (v_lang_id,'A2','speaking','Describe your favourite season and what you do during it in French.','Season, weather, activities, why',array[]::text[],
   'Describe your favourite season of the year and how you spend it, in French. Speak for 2-3 minutes.',60);

  -- =========================================================
  -- A2 — WRITING (20 in bank), 3-4 sentences, increasing complexity
  -- =========================================================
  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, order_index) values
  (v_lang_id,'A2','writing','Write 3-4 French sentences describing what you did last weekend.','Saturday and Sunday with passé composé',array[]::text[],61),
  (v_lang_id,'A2','writing','Write 3-4 French sentences about your studies and your plans for next year.','Use present and futur proche/futur simple',array[]::text[],62),
  (v_lang_id,'A2','writing','Write 3-4 French sentences comparing your current and previous home.','Use comparatives and "avant/maintenant"',array[]::text[],63),
  (v_lang_id,'A2','writing','Write a 3-4 sentence email inviting a friend to your birthday party.','Date, time, place, polite closing',array[]::text[],64),
  (v_lang_id,'A2','writing','Write 3-4 French sentences describing how you usually go to work or school.','Time, transport, route',array[]::text[],65),
  (v_lang_id,'A2','writing','Write 3-4 French sentences about a trip you took recently.','Where, with whom, what you did',array[]::text[],66),
  (v_lang_id,'A2','writing','Write 3-4 French sentences explaining a typical breakfast in your country.','Foods, drinks, time, location',array[]::text[],67),
  (v_lang_id,'A2','writing','Write 3-4 French sentences describing a problem you had with a bus, train or flight.','What happened, what you did',array[]::text[],68),
  (v_lang_id,'A2','writing','Write a 3-4 sentence email to a hotel asking about availability for two nights.','Polite, dates, requirements',array[]::text[],69),
  (v_lang_id,'A2','writing','Write 3-4 French sentences talking about advantages and disadvantages of city life.','At least one of each',array[]::text[],70),
  (v_lang_id,'A2','writing','Write 3-4 French sentences describing what you would do if you had a free day tomorrow.','Use conditional/future',array[]::text[],71),
  (v_lang_id,'A2','writing','Write a 3-4 sentence post-card message from a holiday.','Greeting, location, activity, sign-off',array[]::text[],72),
  (v_lang_id,'A2','writing','Write 3-4 French sentences describing a memorable meal.','When, where, with whom, what',array[]::text[],73),
  (v_lang_id,'A2','writing','Write 3-4 French sentences explaining your morning routine, with two specific times.','Times, actions',array[]::text[],74),
  (v_lang_id,'A2','writing','Write 3-4 French sentences giving simple advice to a friend visiting your city.','Use "tu devrais" or imperatives',array[]::text[],75),
  (v_lang_id,'A2','writing','Write a 3-4 sentence complaint about a hotel room.','Polite, the problem, what you want',array[]::text[],76),
  (v_lang_id,'A2','writing','Write 3-4 French sentences talking about a job you would like in the future.','Job, why, what is needed',array[]::text[],77),
  (v_lang_id,'A2','writing','Write 3-4 French sentences describing the worst weather you remember.','When, where, what happened',array[]::text[],78),
  (v_lang_id,'A2','writing','Write 3-4 French sentences explaining why you started learning French.','Motivation, when, plans',array[]::text[],79),
  (v_lang_id,'A2','writing','Write 3-4 French sentences describing a typical family meal at your home.','Day, food, who is there',array[]::text[],80);

end $$;

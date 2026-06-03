-- 022_spanish_a2_placement_exam.sql
-- Seeds 40 Spanish A2 placement-exam questions.
-- Mirror of 020: 15 vocabulary + 10 listening + 8 speaking + 7 writing.
-- Mixes real A2-level material (daily routines, transport, health, work,
-- feelings, restaurants, technology) with a handful of A1 review items so
-- the test rewards a true foundation.
-- Idempotent: deletes any existing A2 Spanish questions before reseeding.

do $$
declare
  v_lang_id bigint;
begin
  select id into v_lang_id from public.languages where code = 'spanish';
  if v_lang_id is null then
    raise exception 'Spanish language not found';
  end if;

  delete from public.placement_exam_questions where language_id = v_lang_id and level = 'A2';

  insert into public.placement_exam_questions
    (language_id, level, category, question, correct_answer, wrong_answers, hint, order_index) values
    -- ---------- VOCABULARY (15) — A2 with some A1 review ----------
    (v_lang_id,'A2','vocabulary','What does "todos los días" mean?','Every day',array['Every week','Every Monday','Sometimes'],'Daily routine',1),
    (v_lang_id,'A2','vocabulary','How do you say "to wake up" (reflexive)?','despertarse',array['levantarse','dormirse','vestirse'],'Reflexive verb',2),
    (v_lang_id,'A2','vocabulary','What is "el desayuno"?','Breakfast',array['Lunch','Dinner','Snack'],'First meal',3),
    (v_lang_id,'A2','vocabulary','Which verb means "to feel"?','sentirse',array['sentar','soñar','seguir'],'Emotion',4),
    (v_lang_id,'A2','vocabulary','How do you say "headache"?','dolor de cabeza',array['dolor de espalda','fiebre','gripe'],'Symptom',5),
    (v_lang_id,'A2','vocabulary','What does "la reunión" mean?','The meeting',array['The party','The lunch','The class'],'Workplace',6),
    (v_lang_id,'A2','vocabulary','Which is "the train station"?','la estación de tren',array['el aeropuerto','la parada de autobús','el puerto'],'Travel',7),
    (v_lang_id,'A2','vocabulary','What does "alquilar" mean?','to rent',array['to buy','to sell','to lend'],'Verb',8),
    (v_lang_id,'A2','vocabulary','How do you say "to be tired" (with estar)?','estar cansado',array['ser cansado','tener cansado','hacer cansado'],'Use estar',9),
    (v_lang_id,'A2','vocabulary','What does "el menú del día" mean?','The daily set menu',array['The dessert','The drinks list','The wine list'],'Restaurant',10),
    -- A1 review:
    (v_lang_id,'A2','vocabulary','How do you say "hello"?','hola',array['adiós','gracias','sí'],'A1 review',11),
    (v_lang_id,'A2','vocabulary','How do you say "my brother"?','mi hermano',array['tu hermano','mi hermana','su hermano'],'A1 review — family',12),
    -- A2 connectors / function words:
    (v_lang_id,'A2','vocabulary','What does "porque" mean?','because',array['why','for','if'],'Connector',13),
    (v_lang_id,'A2','vocabulary','Which expresses frequency: "a menudo"?','often',array['never','always','rarely'],'Frequency',14),
    (v_lang_id,'A2','vocabulary','What does "la semana pasada" mean?','last week',array['next week','this week','tomorrow'],'Past time',15),
    -- ---------- LISTENING (10) ----------
    (v_lang_id,'A2','listening','Me levanto a las siete de la mañana.',array['I sleep at seven','I get up at seven in the morning','I leave at seven']::text[],'Daily routine',null,16),
    (v_lang_id,'A2','listening','Desayuno café con leche y una tostada.',array['I drink only water','I have coffee with milk and a piece of toast','I make breakfast for two']::text[],'Breakfast',null,17),
    (v_lang_id,'A2','listening','Me duele mucho la espalda.',array['My back hurts a lot','I have a headache','I feel tired']::text[],'Body',null,18),
    (v_lang_id,'A2','listening','¿A qué hora empieza la reunión?',array['Where is the meeting?','What time does the meeting start?','Who is in the meeting?']::text[],'Time + work',null,19),
    (v_lang_id,'A2','listening','Voy al trabajo en metro porque es más rápido.',array['I drive to work because it is faster','I take the metro to work because it is faster','I walk to work because it is faster']::text[],'Transport',null,20),
    (v_lang_id,'A2','listening','Me siento muy contento hoy.',array['I feel very tired today','I feel very happy today','I feel very angry today']::text[],'Feelings',null,21),
    (v_lang_id,'A2','listening','La semana pasada visité a mis abuelos.',array['Last week I visited my grandparents','Next week I will visit my grandparents','I always visit my grandparents']::text[],'Past + family',null,22),
    (v_lang_id,'A2','listening','Quiero reservar una mesa para dos.',array['I want to pay the bill','I want to reserve a table for two','I want to leave a tip']::text[],'Restaurant',null,23),
    (v_lang_id,'A2','listening','Necesito comprar un billete de ida y vuelta.',array['I need to buy a one-way ticket','I need to buy a round-trip ticket','I need to sell my ticket']::text[],'Travel',null,24),
    (v_lang_id,'A2','listening','Mi móvil no tiene batería.',array['My phone is out of battery','My phone is new','My phone is broken']::text[],'Technology',null,25),
    -- ---------- SPEAKING (8) ----------
    (v_lang_id,'A2','speaking','Say this phrase aloud: "Me levanto a las siete."','Me levanto a las siete',array[]::text[],'I get up at seven.',26),
    (v_lang_id,'A2','speaking','Say this phrase aloud: "Voy al trabajo en autobús."','Voy al trabajo en autobús',array[]::text[],'I go to work by bus.',27),
    (v_lang_id,'A2','speaking','Say this phrase aloud: "Me duele la cabeza."','Me duele la cabeza',array[]::text[],'My head hurts.',28),
    (v_lang_id,'A2','speaking','Say this phrase aloud: "¿Puede traerme la cuenta, por favor?"','¿Puede traerme la cuenta, por favor?',array[]::text[],'Can you bring me the bill, please?',29),
    (v_lang_id,'A2','speaking','Say this phrase aloud: "Estoy muy cansado hoy."','Estoy muy cansado hoy',array[]::text[],'I am very tired today.',30),
    (v_lang_id,'A2','speaking','Say this phrase aloud: "Ayer fui al cine con un amigo."','Ayer fui al cine con un amigo',array[]::text[],'Yesterday I went to the cinema with a friend.',31),
    (v_lang_id,'A2','speaking','Say this phrase aloud: "Me gustaría reservar una habitación."','Me gustaría reservar una habitación',array[]::text[],'I would like to reserve a room.',32),
    (v_lang_id,'A2','speaking','Say this phrase aloud: "No estoy de acuerdo contigo."','No estoy de acuerdo contigo',array[]::text[],'I do not agree with you.',33),
    -- ---------- WRITING (7) ----------
    (v_lang_id,'A2','writing','Translate to Spanish: "I get up at seven."','Me levanto a las siete',array[]::text[],'Use levantarse',34),
    (v_lang_id,'A2','writing','Translate to Spanish: "I go to work by bus."','Voy al trabajo en autobús',array[]::text[],'Use ir + en',35),
    (v_lang_id,'A2','writing','Translate to Spanish: "My back hurts."','Me duele la espalda',array[]::text[],'Use doler',36),
    (v_lang_id,'A2','writing','Translate to Spanish: "Yesterday I visited my mother."','Ayer visité a mi madre',array[]::text[],'Preterite + personal a',37),
    (v_lang_id,'A2','writing','Translate to Spanish: "I am very tired."','Estoy muy cansado',array[]::text[],'Use estar',38),
    (v_lang_id,'A2','writing','Translate to Spanish: "I want a coffee with milk."','Quiero un café con leche',array[]::text[],'Restaurant',39),
    (v_lang_id,'A2','writing','Translate to Spanish: "I have a meeting at three."','Tengo una reunión a las tres',array[]::text[],'Workplace + time',40);
end $$;

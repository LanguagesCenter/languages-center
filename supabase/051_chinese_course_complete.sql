-- 051_chinese_course_complete.sql
-- Build the complete Chinese (Mandarin, Simplified) course mirroring the
-- Spanish / French structure:
--   5 CEFR levels (A1-C1) × 15 sections × 9 lessons (8 teaching + 1 unit_test).
-- The Chinese language row already exists in public.languages (code 'chinese').
-- The speech layer already maps 'chinese' → 'zh-CN' in src/lib/speech.ts,
-- so the TTS / STT engines pick up zh-CN automatically for every lesson.
--
-- Mirroring the legacy naming used by Spanish + French:
--   - dialogue jsonb uses key "spanish" for the target-language string.
--   - vocab jsonb uses key "example_es" for the target-language example.
-- LessonClient.tsx still reads those keys (lib/learn.ts LessonDialogueLine).
-- The VALUES are real Chinese — stored under the historical key name.
--
-- Voice: zh-CN, already wired via SPEECH_LANG_CODES.
--
-- Idempotent: wipes any existing Chinese courses before reseeding.

alter table public.exercises drop constraint if exists exercises_type_check;
alter table public.exercises
  add constraint exercises_type_check
  check (type in ('multiple_choice','fill_blank','matching','listening','speaking','writing'));

alter table public.lessons drop constraint if exists lessons_type_check;
alter table public.lessons
  add constraint lessons_type_check
  check (type in (
    'vocabulary','grammar','phrases','listening','speaking',
    'reading','writing','podcast','unit_test','conversation'
  ));

-- ============== PHASE 1 + 2: Build the course skeleton ==============
do $$
declare
  v_lang_id   bigint;
  v_course_id bigint;
  v_level     text;
  v_section_en text;
  v_xp        int;
  v_idx       int;
  v_sections_en  text[];
  v_podcast_desc text;
  i int;

  -- English canonical section labels — same slugs Spanish + French use so the
  -- i18n layer (translateSectionTitle in src/lib/i18n.ts) translates them to
  -- whichever site language the user picked.
  a1_sections_en text[] := array[
    'Greetings','Numbers','Colors','Family','Food','Time','Weather','Shopping',
    'Animals','Body Parts','Clothes','House & Home','Transport','Days & Months','Basic Verbs'
  ];
  a2_sections_en text[] := array[
    'Daily Routines','Health & Body','Hobbies','Work & Jobs','Directions',
    'Feelings & Emotions','Celebrations','Nature','Sports','Music',
    'Travel Planning','Restaurants','School','Technology Basics','Social Media'
  ];
  b1_sections_en text[] := array[
    'Travel & Tourism','News & Media','Environment','Relationships','Culture & Traditions',
    'Money & Banking','Education','Politics Basics','Food & Cooking','Art & Literature',
    'Health & Medicine','Business Basics','Sports & Fitness','Music & Entertainment','Science Basics'
  ];
  b2_sections_en text[] := array[
    'Politics & Society','Technology & Innovation','Philosophy & Ethics','Literature & Poetry',
    'Business & Economics','Science & Research','Arts & Culture','Media & Journalism',
    'Law & Justice','History','Psychology','Architecture','Fashion & Design',
    'Sports Analysis','Environmental Issues'
  ];
  c1_sections_en text[] := array[
    'Idioms & Expressions','Advanced Grammar','Formal Writing','Debate & Discussion','Native Content',
    'Academic Language','Professional Communication','Cultural Nuance','Rhetoric & Persuasion',
    'Advanced Literature','Complex Grammar Structures','Regional Dialects','Slang & Informal Language',
    'Translation Skills','Language Teaching'
  ];

  -- Per-A1-section vocabulary (8 items each). 15 sections × 8 = 120 words.
  -- Phonetic is pinyin in brackets so the TeachingCard can show pronunciation.
  a1_vocab jsonb[] := array[
    -- 1: Greetings
    '[{"word":"你好","phonetic":"[nǐ hǎo]","english":"hello","example_es":"你好,我叫李明。","example_en":"Hello, my name is Li Ming."},
       {"word":"早上好","phonetic":"[zǎo shàng hǎo]","english":"good morning","example_es":"早上好,老师!","example_en":"Good morning, teacher!"},
       {"word":"谢谢","phonetic":"[xiè xiè]","english":"thank you","example_es":"谢谢你的帮助。","example_en":"Thank you for your help."},
       {"word":"再见","phonetic":"[zài jiàn]","english":"goodbye","example_es":"再见,明天见。","example_en":"Goodbye, see you tomorrow."},
       {"word":"晚安","phonetic":"[wǎn ān]","english":"good night","example_es":"妈妈,晚安。","example_en":"Good night, mom."},
       {"word":"是","phonetic":"[shì]","english":"yes / to be","example_es":"是的,我去。","example_en":"Yes, I will go."},
       {"word":"不","phonetic":"[bù]","english":"no / not","example_es":"我不喝咖啡。","example_en":"I don''t drink coffee."},
       {"word":"请","phonetic":"[qǐng]","english":"please","example_es":"请坐。","example_en":"Please sit down."}]'::jsonb,
    -- 2: Numbers
    '[{"word":"一","phonetic":"[yī]","english":"one","example_es":"我有一个哥哥。","example_en":"I have one older brother."},
       {"word":"二","phonetic":"[èr]","english":"two","example_es":"两杯咖啡,谢谢。","example_en":"Two coffees, please."},
       {"word":"三","phonetic":"[sān]","english":"three","example_es":"他有三个孩子。","example_en":"He has three children."},
       {"word":"四","phonetic":"[sì]","english":"four","example_es":"四元钱。","example_en":"Four yuan."},
       {"word":"五","phonetic":"[wǔ]","english":"five","example_es":"等五分钟。","example_en":"Wait five minutes."},
       {"word":"六","phonetic":"[liù]","english":"six","example_es":"现在六点。","example_en":"It is six o''clock."},
       {"word":"七","phonetic":"[qī]","english":"seven","example_es":"一周有七天。","example_en":"A week has seven days."},
       {"word":"八","phonetic":"[bā]","english":"eight","example_es":"八岁。","example_en":"Eight years old."}]'::jsonb,
    -- 3: Colors
    '[{"word":"红色","phonetic":"[hóng sè]","english":"red","example_es":"一辆红色的车。","example_en":"A red car."},
       {"word":"蓝色","phonetic":"[lán sè]","english":"blue","example_es":"天空是蓝色的。","example_en":"The sky is blue."},
       {"word":"绿色","phonetic":"[lǜ sè]","english":"green","example_es":"草是绿色的。","example_en":"The grass is green."},
       {"word":"黄色","phonetic":"[huáng sè]","english":"yellow","example_es":"一个黄色的柠檬。","example_en":"A yellow lemon."},
       {"word":"黑色","phonetic":"[hēi sè]","english":"black","example_es":"一只黑色的猫。","example_en":"A black cat."},
       {"word":"白色","phonetic":"[bái sè]","english":"white","example_es":"雪是白色的。","example_en":"Snow is white."},
       {"word":"粉色","phonetic":"[fěn sè]","english":"pink","example_es":"一朵粉色的花。","example_en":"A pink flower."},
       {"word":"橙色","phonetic":"[chéng sè]","english":"orange","example_es":"一个橙色的橘子。","example_en":"An orange tangerine."}]'::jsonb,
    -- 4: Family
    '[{"word":"爸爸","phonetic":"[bà ba]","english":"father","example_es":"我的爸爸很善良。","example_en":"My father is kind."},
       {"word":"妈妈","phonetic":"[mā ma]","english":"mother","example_es":"我的妈妈是医生。","example_en":"My mother is a doctor."},
       {"word":"哥哥","phonetic":"[gē ge]","english":"older brother","example_es":"我有一个哥哥。","example_en":"I have an older brother."},
       {"word":"姐姐","phonetic":"[jiě jie]","english":"older sister","example_es":"我姐姐十岁。","example_en":"My older sister is ten."},
       {"word":"弟弟","phonetic":"[dì di]","english":"younger brother","example_es":"我弟弟很聪明。","example_en":"My younger brother is smart."},
       {"word":"妹妹","phonetic":"[mèi mei]","english":"younger sister","example_es":"我的妹妹喜欢画画。","example_en":"My younger sister likes painting."},
       {"word":"爷爷","phonetic":"[yé ye]","english":"grandfather","example_es":"爷爷八十岁了。","example_en":"Grandpa is eighty."},
       {"word":"奶奶","phonetic":"[nǎi nai]","english":"grandmother","example_es":"奶奶做饭很好吃。","example_en":"Grandma cooks well."}]'::jsonb,
    -- 5: Food
    '[{"word":"米饭","phonetic":"[mǐ fàn]","english":"rice","example_es":"我吃米饭。","example_en":"I eat rice."},
       {"word":"水","phonetic":"[shuǐ]","english":"water","example_es":"一杯水。","example_en":"A glass of water."},
       {"word":"面条","phonetic":"[miàn tiáo]","english":"noodles","example_es":"我喜欢吃面条。","example_en":"I like noodles."},
       {"word":"肉","phonetic":"[ròu]","english":"meat","example_es":"我不吃肉。","example_en":"I don''t eat meat."},
       {"word":"苹果","phonetic":"[píng guǒ]","english":"apple","example_es":"一个红苹果。","example_en":"A red apple."},
       {"word":"鱼","phonetic":"[yú]","english":"fish","example_es":"今天吃鱼。","example_en":"Eating fish today."},
       {"word":"咖啡","phonetic":"[kā fēi]","english":"coffee","example_es":"一杯黑咖啡。","example_en":"A black coffee."},
       {"word":"茶","phonetic":"[chá]","english":"tea","example_es":"我喝绿茶。","example_en":"I drink green tea."}]'::jsonb,
    -- 6: Time
    '[{"word":"时间","phonetic":"[shí jiān]","english":"time","example_es":"现在几点?","example_en":"What time is it?"},
       {"word":"分钟","phonetic":"[fēn zhōng]","english":"minute","example_es":"五分钟。","example_en":"Five minutes."},
       {"word":"小时","phonetic":"[xiǎo shí]","english":"hour","example_es":"一个小时。","example_en":"One hour."},
       {"word":"天","phonetic":"[tiān]","english":"day","example_es":"今天是星期一。","example_en":"Today is Monday."},
       {"word":"早上","phonetic":"[zǎo shàng]","english":"morning","example_es":"我早上跑步。","example_en":"I run in the morning."},
       {"word":"晚上","phonetic":"[wǎn shàng]","english":"evening","example_es":"晚上我看书。","example_en":"In the evening I read."},
       {"word":"中午","phonetic":"[zhōng wǔ]","english":"noon","example_es":"我们中午吃饭。","example_en":"We eat at noon."},
       {"word":"半夜","phonetic":"[bàn yè]","english":"midnight","example_es":"半夜十二点。","example_en":"Midnight, twelve o''clock."}]'::jsonb,
    -- 7: Weather
    '[{"word":"太阳","phonetic":"[tài yáng]","english":"sun","example_es":"今天有太阳。","example_en":"It is sunny today."},
       {"word":"雨","phonetic":"[yǔ]","english":"rain","example_es":"外面下雨了。","example_en":"It is raining outside."},
       {"word":"雪","phonetic":"[xuě]","english":"snow","example_es":"冬天下雪。","example_en":"It snows in winter."},
       {"word":"风","phonetic":"[fēng]","english":"wind","example_es":"今天风很大。","example_en":"It is very windy today."},
       {"word":"热","phonetic":"[rè]","english":"hot","example_es":"今天很热。","example_en":"It is very hot today."},
       {"word":"冷","phonetic":"[lěng]","english":"cold","example_es":"冬天很冷。","example_en":"Winter is cold."},
       {"word":"云","phonetic":"[yún]","english":"cloud","example_es":"天上有很多云。","example_en":"There are many clouds in the sky."},
       {"word":"天气","phonetic":"[tiān qì]","english":"weather","example_es":"今天天气怎么样?","example_en":"How is the weather today?"}]'::jsonb,
    -- 8: Shopping
    '[{"word":"商店","phonetic":"[shāng diàn]","english":"shop / store","example_es":"商店开门了。","example_en":"The shop is open."},
       {"word":"价钱","phonetic":"[jià qián]","english":"price","example_es":"这个多少钱?","example_en":"How much is this?"},
       {"word":"买","phonetic":"[mǎi]","english":"to buy","example_es":"我想买一本书。","example_en":"I want to buy a book."},
       {"word":"付","phonetic":"[fù]","english":"to pay","example_es":"我用卡付钱。","example_en":"I pay by card."},
       {"word":"钱","phonetic":"[qián]","english":"money","example_es":"我有一点钱。","example_en":"I have a little money."},
       {"word":"元","phonetic":"[yuán]","english":"yuan / dollar","example_es":"十元钱。","example_en":"Ten yuan."},
       {"word":"市场","phonetic":"[shì chǎng]","english":"market","example_es":"我们去市场。","example_en":"We are going to the market."},
       {"word":"超市","phonetic":"[chāo shì]","english":"supermarket","example_es":"超市很大。","example_en":"The supermarket is big."}]'::jsonb,
    -- 9: Animals
    '[{"word":"狗","phonetic":"[gǒu]","english":"dog","example_es":"我的狗很可爱。","example_en":"My dog is cute."},
       {"word":"猫","phonetic":"[māo]","english":"cat","example_es":"猫在睡觉。","example_en":"The cat is sleeping."},
       {"word":"鸟","phonetic":"[niǎo]","english":"bird","example_es":"鸟在唱歌。","example_en":"A bird is singing."},
       {"word":"鱼","phonetic":"[yú]","english":"fish","example_es":"鱼在游泳。","example_en":"The fish is swimming."},
       {"word":"马","phonetic":"[mǎ]","english":"horse","example_es":"一匹白马。","example_en":"A white horse."},
       {"word":"牛","phonetic":"[niú]","english":"cow","example_es":"牛吃草。","example_en":"The cow eats grass."},
       {"word":"猪","phonetic":"[zhū]","english":"pig","example_es":"一只粉色的猪。","example_en":"A pink pig."},
       {"word":"兔子","phonetic":"[tù zi]","english":"rabbit","example_es":"灰色的兔子。","example_en":"A grey rabbit."}]'::jsonb,
    -- 10: Body Parts
    '[{"word":"头","phonetic":"[tóu]","english":"head","example_es":"我头疼。","example_en":"My head hurts."},
       {"word":"手","phonetic":"[shǒu]","english":"hand","example_es":"洗手。","example_en":"Wash your hands."},
       {"word":"脚","phonetic":"[jiǎo]","english":"foot","example_es":"我脚疼。","example_en":"My foot hurts."},
       {"word":"眼睛","phonetic":"[yǎn jīng]","english":"eye","example_es":"她的眼睛很大。","example_en":"Her eyes are big."},
       {"word":"嘴","phonetic":"[zuǐ]","english":"mouth","example_es":"张开嘴。","example_en":"Open your mouth."},
       {"word":"耳朵","phonetic":"[ěr duo]","english":"ear","example_es":"我耳朵不舒服。","example_en":"My ear is uncomfortable."},
       {"word":"胳膊","phonetic":"[gē bo]","english":"arm","example_es":"抬起胳膊。","example_en":"Raise your arms."},
       {"word":"腿","phonetic":"[tuǐ]","english":"leg","example_es":"我的腿断了。","example_en":"My leg is broken."}]'::jsonb,
    -- 11: Clothes
    '[{"word":"衬衫","phonetic":"[chèn shān]","english":"shirt","example_es":"一件白衬衫。","example_en":"A white shirt."},
       {"word":"裤子","phonetic":"[kù zi]","english":"trousers","example_es":"黑色的裤子。","example_en":"Black trousers."},
       {"word":"裙子","phonetic":"[qún zi]","english":"skirt / dress","example_es":"夏天的裙子。","example_en":"A summer dress."},
       {"word":"鞋","phonetic":"[xié]","english":"shoes","example_es":"新鞋。","example_en":"New shoes."},
       {"word":"外套","phonetic":"[wài tào]","english":"coat","example_es":"穿上外套。","example_en":"Put on your coat."},
       {"word":"帽子","phonetic":"[mào zi]","english":"hat","example_es":"一顶漂亮的帽子。","example_en":"A nice hat."},
       {"word":"袜子","phonetic":"[wà zi]","english":"socks","example_es":"一双袜子。","example_en":"A pair of socks."},
       {"word":"围巾","phonetic":"[wéi jīn]","english":"scarf","example_es":"红色的围巾。","example_en":"A red scarf."}]'::jsonb,
    -- 12: House & Home
    '[{"word":"房子","phonetic":"[fáng zi]","english":"house","example_es":"一座大房子。","example_en":"A big house."},
       {"word":"卧室","phonetic":"[wò shì]","english":"bedroom","example_es":"我的卧室很小。","example_en":"My bedroom is small."},
       {"word":"厨房","phonetic":"[chú fáng]","english":"kitchen","example_es":"漂亮的厨房。","example_en":"A beautiful kitchen."},
       {"word":"客厅","phonetic":"[kè tīng]","english":"living room","example_es":"客厅很明亮。","example_en":"The living room is bright."},
       {"word":"浴室","phonetic":"[yù shì]","english":"bathroom","example_es":"浴室刚装修过。","example_en":"The bathroom is newly renovated."},
       {"word":"花园","phonetic":"[huā yuán]","english":"garden","example_es":"花园里有花。","example_en":"There are flowers in the garden."},
       {"word":"门","phonetic":"[mén]","english":"door","example_es":"关门。","example_en":"Close the door."},
       {"word":"窗户","phonetic":"[chuāng hu]","english":"window","example_es":"打开窗户。","example_en":"Open the window."}]'::jsonb,
    -- 13: Transport
    '[{"word":"车","phonetic":"[chē]","english":"car","example_es":"我的车是红色的。","example_en":"My car is red."},
       {"word":"公共汽车","phonetic":"[gōng gòng qì chē]","english":"bus","example_es":"我坐公共汽车。","example_en":"I take the bus."},
       {"word":"火车","phonetic":"[huǒ chē]","english":"train","example_es":"火车八点开。","example_en":"The train leaves at eight."},
       {"word":"飞机","phonetic":"[fēi jī]","english":"plane","example_es":"飞机降落了。","example_en":"The plane has landed."},
       {"word":"自行车","phonetic":"[zì xíng chē]","english":"bicycle","example_es":"我骑自行车。","example_en":"I ride a bicycle."},
       {"word":"船","phonetic":"[chuán]","english":"boat","example_es":"湖上的船。","example_en":"A boat on the lake."},
       {"word":"地铁","phonetic":"[dì tiě]","english":"subway / metro","example_es":"地铁很快。","example_en":"The subway is fast."},
       {"word":"出租车","phonetic":"[chū zū chē]","english":"taxi","example_es":"叫一辆出租车。","example_en":"Call a taxi."}]'::jsonb,
    -- 14: Days & Months
    '[{"word":"星期一","phonetic":"[xīng qī yī]","english":"Monday","example_es":"星期一我工作。","example_en":"On Monday I work."},
       {"word":"星期二","phonetic":"[xīng qī èr]","english":"Tuesday","example_es":"星期二我们见面。","example_en":"We meet on Tuesday."},
       {"word":"星期三","phonetic":"[xīng qī sān]","english":"Wednesday","example_es":"下星期三。","example_en":"Next Wednesday."},
       {"word":"星期四","phonetic":"[xīng qī sì]","english":"Thursday","example_es":"星期四早上。","example_en":"Thursday morning."},
       {"word":"星期五","phonetic":"[xīng qī wǔ]","english":"Friday","example_es":"星期五晚上。","example_en":"Friday evening."},
       {"word":"星期六","phonetic":"[xīng qī liù]","english":"Saturday","example_es":"星期六我出去。","example_en":"On Saturday I go out."},
       {"word":"星期天","phonetic":"[xīng qī tiān]","english":"Sunday","example_es":"星期天和家人在一起。","example_en":"Sunday with family."},
       {"word":"一月","phonetic":"[yī yuè]","english":"January","example_es":"一月很冷。","example_en":"January is cold."}]'::jsonb,
    -- 15: Basic Verbs
    '[{"word":"是","phonetic":"[shì]","english":"to be","example_es":"我是学生。","example_en":"I am a student."},
       {"word":"有","phonetic":"[yǒu]","english":"to have","example_es":"我有一本书。","example_en":"I have a book."},
       {"word":"去","phonetic":"[qù]","english":"to go","example_es":"我去北京。","example_en":"I am going to Beijing."},
       {"word":"做","phonetic":"[zuò]","english":"to do","example_es":"我做运动。","example_en":"I do sports."},
       {"word":"说","phonetic":"[shuō]","english":"to say","example_es":"告诉我一切。","example_en":"Tell me everything."},
       {"word":"看","phonetic":"[kàn]","english":"to see / look","example_es":"我看见大海。","example_en":"I see the sea."},
       {"word":"知道","phonetic":"[zhī dào]","english":"to know","example_es":"我知道答案。","example_en":"I know the answer."},
       {"word":"能","phonetic":"[néng]","english":"can / be able to","example_es":"我能帮你。","example_en":"I can help you."}]'::jsonb
  ];

  -- Generic vocab item template for non-A1 levels.
  a2_vocab jsonb := '[{"word":"昨天","phonetic":"[zuó tiān]","english":"yesterday","example_es":"昨天我去看电影了。","example_en":"Yesterday I went to the cinema."},{"word":"明天","phonetic":"[míng tiān]","english":"tomorrow","example_es":"明天我工作。","example_en":"Tomorrow I work."},{"word":"总是","phonetic":"[zǒng shì]","english":"always","example_es":"我总是喝咖啡。","example_en":"I always drink coffee."},{"word":"经常","phonetic":"[jīng cháng]","english":"often","example_es":"我经常晚上出去。","example_en":"I often go out at night."},{"word":"午饭","phonetic":"[wǔ fàn]","english":"lunch","example_es":"我们中午吃午饭。","example_en":"We eat lunch at noon."},{"word":"旅行","phonetic":"[lǚ xíng]","english":"to travel","example_es":"我喜欢坐火车旅行。","example_en":"I like travelling by train."},{"word":"尝试","phonetic":"[cháng shì]","english":"to try","example_es":"我尝试新菜。","example_en":"I am trying a new dish."},{"word":"重要","phonetic":"[zhòng yào]","english":"important","example_es":"这对我很重要。","example_en":"This is important to me."}]'::jsonb;

  b1_vocab jsonb := '[{"word":"然而","phonetic":"[rán ér]","english":"however","example_es":"我喜欢咖啡,然而我喝得很少。","example_en":"I like coffee; however, I drink very little of it."},{"word":"尽管如此","phonetic":"[jǐn guǎn rú cǐ]","english":"nevertheless","example_es":"这很难,尽管如此我会努力。","example_en":"It is hard; nevertheless, I will try."},{"word":"项目","phonetic":"[xiàng mù]","english":"project","example_es":"我有一个新项目。","example_en":"I have a new project."},{"word":"未来","phonetic":"[wèi lái]","english":"future","example_es":"我考虑我的未来。","example_en":"I think about my future."},{"word":"投资","phonetic":"[tóu zī]","english":"to invest","example_es":"我在学习上投入时间。","example_en":"I invest time in my studies."},{"word":"成功","phonetic":"[chéng gōng]","english":"to succeed","example_es":"我想考试成功。","example_en":"I want to pass my exams."},{"word":"环境","phonetic":"[huán jìng]","english":"environment","example_es":"环境很脆弱。","example_en":"The environment is fragile."},{"word":"意见","phonetic":"[yì jiàn]","english":"opinion","example_es":"我认为这很公平。","example_en":"In my opinion, this is fair."}]'::jsonb;

  b2_vocab jsonb := '[{"word":"不过","phonetic":"[bú guò]","english":"however / nevertheless","example_es":"想法不错,不过太贵。","example_en":"The idea is good; however, it is too costly."},{"word":"因此","phonetic":"[yīn cǐ]","english":"consequently","example_es":"下雨了,因此我们留在家里。","example_en":"It is raining; consequently, we stay in."},{"word":"强调","phonetic":"[qiáng diào]","english":"to emphasise","example_es":"我强调这件事的重要性。","example_en":"I emphasise the importance of this matter."},{"word":"视角","phonetic":"[shì jiǎo]","english":"perspective","example_es":"从这个视角看,一切都不同。","example_en":"From this perspective, everything is different."},{"word":"议题","phonetic":"[yì tí]","english":"issue / agenda","example_es":"气候是一个重要议题。","example_en":"Climate is an important issue."},{"word":"可持续","phonetic":"[kě chí xù]","english":"sustainable","example_es":"可持续发展。","example_en":"Sustainable development."},{"word":"不可避免","phonetic":"[bù kě bì miǎn]","english":"inevitable","example_es":"变化是不可避免的。","example_en":"Change is inevitable."},{"word":"争议","phonetic":"[zhēng yì]","english":"controversy","example_es":"这个决定引起争议。","example_en":"This decision raises controversy."}]'::jsonb;

  c1_vocab jsonb := '[{"word":"尽管","phonetic":"[jǐn guǎn]","english":"notwithstanding","example_es":"尽管困难重重,他还是成功了。","example_en":"Notwithstanding the obstacles, he succeeded."},{"word":"应当","phonetic":"[yīng dāng]","english":"it is appropriate to / should","example_es":"应当慎重表达观点。","example_en":"One should express the view with care."},{"word":"佐证","phonetic":"[zuǒ zhèng]","english":"to substantiate","example_es":"我们需要佐证这个论点。","example_en":"We need to substantiate this argument."},{"word":"潜在","phonetic":"[qián zài]","english":"underlying / latent","example_es":"潜在的原因有很多。","example_en":"There are many underlying causes."},{"word":"主导","phonetic":"[zhǔ dǎo]","english":"predominant / leading","example_es":"扮演主导角色。","example_en":"To play a predominant role."},{"word":"领会","phonetic":"[lǐng huì]","english":"to grasp / comprehend","example_es":"必须领会问题的复杂性。","example_en":"The complexity of the issue must be grasped."},{"word":"事实上","phonetic":"[shì shí shàng]","english":"de facto / in fact","example_es":"这事实上已成为常态。","example_en":"This has, in fact, become the norm."},{"word":"范式","phonetic":"[fàn shì]","english":"paradigm","example_es":"一次范式的转变。","example_en":"A paradigm shift."}]'::jsonb;

  -- Per-level grammar_note text (reused across all 15 sections of that level).
  a1_grammar_note text := 'Chinese has no verb conjugation or grammatical gender. Subject pronouns: 我 wǒ (I), 你 nǐ (you), 他/她 tā (he/she), 我们 wǒmen (we), 你们 nǐmen (you plural), 他们 tāmen (they). Basic sentence order is Subject + Verb + Object (我 喝 茶 — I drink tea). The verb 是 shì links nouns (我 是 学生 — I am a student); it is NOT used before adjectives (我 很 高 — I am tall, literally "I very tall"). Negate verbs with 不 bù (不 喝 — don''t drink); negate 有 yǒu with 没 méi (没有 — don''t have).';
  a2_grammar_note text := 'Past actions take the aspect particle 了 le after the verb (我 吃 了 — I ate). The particle 过 guo marks experience (我 去过 北京 — I have been to Beijing). Ongoing actions use 在 zài before the verb or 正在 zhèngzài (我 在 学习 — I am studying). Future intentions use 要 yào (我 要 去 — I am going to go) or 会 huì (我 会 来 — I will come). Question particle 吗 ma turns a statement into a yes/no question (你 好 吗?).';
  b1_grammar_note text := 'Comparisons use 比 bǐ: 我 比 他 高 (I am taller than him). Connectors: 因为 yīnwèi … 所以 suǒyǐ … (because … therefore …); 虽然 suīrán … 但是 dànshì … (although … but …); 如果 rúguǒ … 就 jiù … (if … then …). Result complements attach to verbs (听 见 tīng-jiàn — to hear; 看 完 kàn-wán — to finish reading). The 把 bǎ structure foregrounds the object: 我 把 书 看 完 了 (I finished reading the book).';
  b2_grammar_note text := 'Passive voice with 被 bèi (书 被 我 看 完 了 — the book was finished by me). Concessive connectors 即使 jíshǐ … 也 yě … (even if …); 无论 wúlùn … 都 dōu … (no matter …); 不仅 bùjǐn … 而且 érqiě … (not only … but also …). Counterfactuals: 要不是 yàobúshì … 就 jiù … (if it weren''t for …). Topic-prominent restructuring: 这本书,我已经读过了 (this book, I have already read).';
  c1_grammar_note text := 'Advanced syntax: 之 zhī as classical possessive marker (民 之 心 — the heart of the people); 所 suǒ + verb as nominalisation (所 说 — that which is said); rhetorical 难道 nándào (do you really mean to say …?). Discourse markers: 综上所述 zōng shàng suǒ shù (in conclusion); 与此同时 yǔ cǐ tóng shí (meanwhile); 不容忽视 bù róng hū shì (cannot be overlooked); 由此可见 yóu cǐ kě jiàn (from this we can see). Formal register prefers 而 ér over 但是 dànshì for "but", and 则 zé over 就 jiù for "then".';

  -- Per-level dialogue jsonb (used as the lesson 3 "phrases" dialogue and as
  -- a richer dialogue for several other lesson types).
  a1_dialogue jsonb := '[{"speaker":"小红","spanish":"你好,你叫什么名字?","english":"Hello, what is your name?"},{"speaker":"小明","spanish":"我叫小明。你呢?","english":"My name is Xiao Ming. And you?"},{"speaker":"小红","spanish":"我叫小红。很高兴认识你。","english":"My name is Xiao Hong. Nice to meet you."},{"speaker":"小明","spanish":"我也很高兴认识你。","english":"Nice to meet you too."}]'::jsonb;
  a2_dialogue jsonb := '[{"speaker":"丽丽","spanish":"上周末你做什么了?","english":"What did you do last weekend?"},{"speaker":"大伟","spanish":"我和朋友一起去海边了,非常开心!","english":"I went to the seaside with friends, it was great!"},{"speaker":"丽丽","spanish":"你们坐火车还是开车?","english":"Did you go by train or by car?"},{"speaker":"大伟","spanish":"坐火车。又快又环保。","english":"By train. Fast and eco-friendly."}]'::jsonb;
  b1_dialogue jsonb := '[{"speaker":"苏菲","spanish":"然而,我觉得一个人旅行也很有意义。","english":"However, I think travelling alone is also meaningful."},{"speaker":"建国","spanish":"你说得对,不过要注意安全。","english":"You are right, but you have to be careful."},{"speaker":"苏菲","spanish":"如果我有更多时间,我就去东南亚走半年。","english":"If I had more time, I would travel through Southeast Asia for half a year."},{"speaker":"建国","spanish":"那是什么让你今年走不开?","english":"So what is holding you back this year?"}]'::jsonb;
  b2_dialogue jsonb := '[{"speaker":"教授","spanish":"不过,我怀疑这项政策从长远看是否有效。","english":"However, I doubt this policy will be effective in the long term."},{"speaker":"学生","spanish":"如果经济参与者不配合,什么也改变不了。","english":"If economic actors don''t cooperate, nothing will change."},{"speaker":"教授","spanish":"不过,我们应当强调过去十年所取得的进步。","english":"However, we should emphasise the progress made over the past ten years."},{"speaker":"学生","spanish":"确实如此,因此我们仍需保持谨慎。","english":"Indeed; consequently, we must remain cautious."}]'::jsonb;
  c1_dialogue jsonb := '[{"speaker":"教授","spanish":"尽管议题复杂,我们应当领会其潜在的核心问题。","english":"Notwithstanding the complexity of the topic, we should grasp its underlying core issues."},{"speaker":"学者","spanish":"请问您是否有佐证此分析的参考文献?","english":"May I ask whether you have references that substantiate this analysis?"},{"speaker":"教授","spanish":"当然有。建议您参阅近期发表在该学刊上的研究。","english":"Of course. I recommend you consult the recent studies published in that journal."},{"speaker":"学者","spanish":"非常感谢,我今晚就深入研读。","english":"Many thanks; I will study them in depth tonight."}]'::jsonb;

  -- Reading passages per level (used in lesson 6).
  a1_reading_passage text := '我叫苏菲。我今年二十五岁,住在北京。早上我坐公共汽车去上班。晚上我学英语。周末我回老家看爸爸妈妈。';
  a2_reading_passage text := '去年我换了工作。以前我在一家小公司上班,觉得很无聊。后来我找到了一家国际公司的工作,可以经常出差。刚开始很难,但是现在我很开心,因为我学到了很多东西。';
  b1_reading_passage text := '越来越多的年轻人毕业后选择去国外学习或者工作。原因有很多:有的人希望得到更高的工资,有的人想学习一门外语或者了解新的文化。然而,这种趋势也让一些专家担心,他们认为国家可能会失去重要的人才,很难弥补。因此,不少政府开始提供奖励,希望这些年轻人将来能回国工作。';
  b2_reading_passage text := '生成式人工智能正在以前所未有的速度改变创作领域。有些人认为这只是一种新工具,就像当年的电脑一样;另一些人则担心它会削弱人类劳动的价值。这场讨论不仅是经济层面的:当机器能够创作出符合质量标准的作品时,它也在挑战我们对"作者"和"原创性"的传统理解。可以预见,这场争论还将持续很长时间。';
  c1_reading_passage text := '"十五分钟城市"模式的讨论在城市规划领域已存在数十年,然而真正进入政治议程却是近几年的事。其支持者认为,把学校、工作、商店和娱乐设施都安排在步行十五分钟范围内,既能减少碳排放、改善公共健康,也能恢复因汽车主导的城市生活所失去的社群联系。然而,反对者从意想不到的角度发起了攻击:有人将该模式视为对个人出行自由的隐形限制,甚至将其与某些阴谋论联系起来。由此可见,这场争论早已超越技术层面,成为一场深层的文化与象征之争。';
begin
  select id into v_lang_id from public.languages where code = 'chinese';
  if v_lang_id is null then raise exception 'Chinese language not found in public.languages'; end if;

  -- Wipe any existing Chinese content so the migration is idempotent.
  delete from public.courses where language_id = v_lang_id;

  for v_idx in 1..5 loop
    case v_idx
      when 1 then v_level := 'A1'; v_sections_en := a1_sections_en; v_xp := 10;
      when 2 then v_level := 'A2'; v_sections_en := a2_sections_en; v_xp := 15;
      when 3 then v_level := 'B1'; v_sections_en := b1_sections_en; v_xp := 20;
      when 4 then v_level := 'B2'; v_sections_en := b2_sections_en; v_xp := 25;
      when 5 then v_level := 'C1'; v_sections_en := c1_sections_en; v_xp := 30;
    end case;

    for i in 1..15 loop
      v_section_en := v_sections_en[i];
      v_podcast_desc := case when i % 2 = 1
        then 'Listen to a short Chinese podcast about ' || v_section_en || '.'
        else 'Watch a short Chinese video about ' || v_section_en || '.'
      end;

      insert into public.courses (language_id, title, description, cefr_level, order_index)
      values (
        v_lang_id, v_section_en,
        'Build your ' || v_level || ' Chinese skills in ' || v_section_en || '.',
        v_level, i
      )
      returning id into v_course_id;

      -- 8 teaching lessons + 1 unit_test.
      insert into public.lessons (course_id, title, description, type, order_index, xp_reward) values
        (v_course_id, v_section_en || ' — Vocabulary',              'Learn key Chinese vocabulary for ' || v_section_en || '.',          'vocabulary', 1, v_xp),
        (v_course_id, v_section_en || ' — Grammar',                 'Practise the grammar patterns used in ' || v_section_en || '.',     'grammar',    2, v_xp),
        (v_course_id, v_section_en || ' — Phrases & Conversation',  'Common Chinese phrases for ' || v_section_en || '.',                'phrases',    3, v_xp),
        (v_course_id, v_section_en || ' — Listening',               'Listen and respond in Chinese about ' || v_section_en || '.',       'listening',  4, v_xp),
        (v_course_id, v_section_en || ' — Speaking',                'Speak in Chinese about ' || v_section_en || '.',                    'speaking',   5, v_xp),
        (v_course_id, v_section_en || ' — Reading & Comprehension', 'Read a short Chinese text on ' || v_section_en || '.',              'reading',    6, v_xp),
        (v_course_id, v_section_en || ' — Writing',                 'Write a short Chinese text about ' || v_section_en || '.',          'writing',    7, v_xp),
        (v_course_id, v_section_en || ' — Podcast / Video',         v_podcast_desc,                                                       'podcast',    8, v_xp),
        (v_course_id, 'Section Test: ' || v_section_en,             'Review test for ' || v_section_en || '. Pass with 7/10 to earn 50 XP.', 'unit_test', 9, 50);

      ----------------------------------------------------------------
      -- TEACHING CONTENT
      ----------------------------------------------------------------

      -- Lesson 1 (vocabulary)
      update public.lessons set
        intro = case v_level
          when 'A1' then '让我们学习与' || v_section_en || '相关的重要词汇。请大声朗读例句,熟悉中文发音。'
          else '让我们用' || v_level || '级别的实用词汇来谈论' || v_section_en || '以及更多话题。'
        end,
        vocab_items = case v_level
          when 'A1' then a1_vocab[i]
          when 'A2' then a2_vocab
          when 'B1' then b1_vocab
          when 'B2' then b2_vocab
          when 'C1' then c1_vocab
        end,
        dialogue = case v_level
          when 'A1' then a1_dialogue
          when 'A2' then a2_dialogue
          when 'B1' then b1_dialogue
          when 'B2' then b2_dialogue
          when 'C1' then c1_dialogue
        end,
        grammar_note = case v_level
          when 'A1' then a1_grammar_note
          when 'A2' then a2_grammar_note
          when 'B1' then b1_grammar_note
          when 'B2' then b2_grammar_note
          when 'C1' then c1_grammar_note
        end
      where course_id = v_course_id and order_index = 1;

      -- Lesson 2 (grammar)
      update public.lessons set
        intro = '让我们围绕' || v_section_en || ',练习' || v_level || '级别的语法。请仔细阅读例句。',
        grammar_note = case v_level
          when 'A1' then a1_grammar_note
          when 'A2' then a2_grammar_note
          when 'B1' then b1_grammar_note
          when 'B2' then b2_grammar_note
          when 'C1' then c1_grammar_note
        end,
        dialogue = case v_level
          when 'A1' then a1_dialogue
          when 'A2' then a2_dialogue
          when 'B1' then b1_dialogue
          when 'B2' then b2_dialogue
          when 'C1' then c1_dialogue
        end
      where course_id = v_course_id and order_index = 2;

      -- Lesson 3 (phrases)
      update public.lessons set
        intro = '我们来学习一些关于' || v_section_en || '的常用表达和一段简短对话。',
        dialogue = case v_level
          when 'A1' then a1_dialogue
          when 'A2' then a2_dialogue
          when 'B1' then b1_dialogue
          when 'B2' then b2_dialogue
          when 'C1' then c1_dialogue
        end
      where course_id = v_course_id and order_index = 3;

      -- Lesson 4 (listening)
      update public.lessons set
        intro = '让我们练习听力。仔细听,然后用中文回答。可以多听几遍。',
        dialogue = case v_level
          when 'A1' then a1_dialogue
          when 'A2' then a2_dialogue
          when 'B1' then b1_dialogue
          when 'B2' then b2_dialogue
          when 'C1' then c1_dialogue
        end
      where course_id = v_course_id and order_index = 4;

      -- Lesson 5 (speaking)
      update public.lessons set
        intro = '轮到你说了!打开麦克风,自然地用中文表达。'
      where course_id = v_course_id and order_index = 5;

      -- Lesson 6 (reading)
      update public.lessons set
        intro = case v_level
          when 'A1' then a1_reading_passage
          when 'A2' then a2_reading_passage
          when 'B1' then b1_reading_passage
          when 'B2' then b2_reading_passage
          when 'C1' then c1_reading_passage
        end
      where course_id = v_course_id and order_index = 6;

      -- Lesson 7 (writing)
      update public.lessons set
        intro = '现在练习写作。注意语法、用字以及词汇的多样性。'
      where course_id = v_course_id and order_index = 7;

      -- Lesson 8 (podcast / video)
      update public.lessons set
        intro = v_podcast_desc
      where course_id = v_course_id and order_index = 8;

    end loop;
  end loop;
end $$;

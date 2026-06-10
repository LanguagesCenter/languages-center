-- 032_articles_14_languages.sql
-- Real placeholder articles (3 per language) for the 14 languages added
-- in migration 006 / 007. The earlier seed put the same generic English
-- "Placeholder X text" string in BOTH content_target and content_english,
-- so the show-translation panel reads identical English on both sides.
-- This migration replaces those rows with actual target-language prose
-- plus a proper English translation.
--
-- Per language:
--   A1 ~80-100 target words  — introduction to language / culture
--   B1 ~150-200 target words — a cultural topic
--   C1 ~200-300 target words — a more advanced theme
--
-- Idempotent: deletes the language's existing articles before inserting.
-- Slug pattern: <language>-<topic>-<level> so the URLs are stable.

do $$
declare
  v_lang_id bigint;
begin
  -- =========================================================
  -- ITALIANO
  -- =========================================================
  select id into v_lang_id from public.languages where code = 'italian';
  if v_lang_id is not null then
    delete from public.articles where language_id = v_lang_id;
    insert into public.articles
      (language_id, slug, title, title_english, level, reading_minutes,
       content_target, content_english, order_index) values
    (v_lang_id, 'italian-saluti-a1',
     'Saluti dall''Italia', 'Greetings from Italy', 'A1', 2,
     'Ciao! Mi chiamo Marco e sono italiano. Vivo a Roma, la capitale d''Italia. In Italia diciamo "ciao" agli amici e "buongiorno" alle persone che non conosciamo bene. La mattina prendo un caffè e mangio un cornetto. A pranzo mangio la pasta. La sera vado al ristorante con la mia famiglia. L''italiano è una lingua bella e musicale. Mi piace molto la mia città. Roma ha molti monumenti antichi, come il Colosseo e la Fontana di Trevi. Vieni a visitare l''Italia!',
     'Hi! My name is Marco and I am Italian. I live in Rome, the capital of Italy. In Italy we say "ciao" to friends and "buongiorno" to people we don''t know well. In the morning I have a coffee and eat a croissant. For lunch I eat pasta. In the evening I go to a restaurant with my family. Italian is a beautiful and musical language. I really like my city. Rome has many ancient monuments, like the Colosseum and the Trevi Fountain. Come visit Italy!',
     1),
    (v_lang_id, 'italian-cibo-b1',
     'La cucina italiana', 'Italian cuisine', 'B1', 3,
     'La cucina italiana è famosa in tutto il mondo, ma molti stranieri non sanno che non esiste una sola cucina italiana: ogni regione ha i suoi piatti tipici. In Lombardia si mangia il risotto allo zafferano, in Liguria il pesto, in Emilia-Romagna i tortellini e in Campania la vera pizza napoletana. Anche il caffè ha le sue regole: in Italia il cappuccino si beve solo a colazione, mai dopo cena. La pasta si serve come primo piatto, prima del secondo di carne o di pesce. A tavola si parla molto, si ride e si beve un buon vino della zona. Mangiare in Italia non è solo nutrirsi, è un momento sociale importante che unisce la famiglia e gli amici intorno a sapori semplici ma curati.',
     'Italian cuisine is famous all over the world, but many foreigners don''t know that there isn''t a single Italian cuisine: every region has its own typical dishes. In Lombardy people eat saffron risotto, in Liguria pesto, in Emilia-Romagna tortellini, and in Campania the real Neapolitan pizza. Even coffee has its rules: in Italy cappuccino is drunk only at breakfast, never after dinner. Pasta is served as a first course, before the meat or fish second course. At the table people talk a lot, laugh and drink a good local wine. Eating in Italy is not just about feeding yourself; it is an important social moment that brings family and friends together around simple but well-prepared flavours.',
     2),
    (v_lang_id, 'italian-rinascimento-c1',
     'L''eredità del Rinascimento', 'The legacy of the Renaissance', 'C1', 5,
     'Il Rinascimento italiano, sviluppatosi tra il Trecento e il Cinquecento, rappresenta uno dei momenti più fecondi della storia culturale occidentale. Nato a Firenze sotto il patrocinio di famiglie come i Medici, e diffusosi poi a Roma, Venezia, Milano e Napoli, il movimento riscoprì gli ideali classici della Grecia antica e di Roma, ponendo l''uomo al centro dell''universo. Artisti come Leonardo da Vinci, Michelangelo e Raffaello non furono semplici pittori o scultori, ma intellettuali poliedrici che intrecciavano arte, scienza, anatomia e ingegneria. Allo stesso tempo, autori come Petrarca, Boccaccio e Machiavelli rinnovarono profondamente la letteratura e il pensiero politico. La rivoluzione rinascimentale non fu solo estetica: introdusse un nuovo metodo di osservazione del mondo che avrebbe preparato il terreno alla scienza moderna. Ancora oggi, percorrendo le strade di Firenze o ammirando la Cappella Sistina, è impossibile non avvertire l''eco di quell''epoca straordinaria, in cui la curiosità umana sembrava non avere limiti e la bellezza era considerata una via per comprendere il divino.',
     'The Italian Renaissance, which developed between the 14th and 16th centuries, represents one of the most fertile moments in Western cultural history. Born in Florence under the patronage of families like the Medici, and then spreading to Rome, Venice, Milan and Naples, the movement rediscovered the classical ideals of ancient Greece and Rome, placing humanity at the centre of the universe. Artists such as Leonardo da Vinci, Michelangelo and Raphael were not merely painters or sculptors, but multifaceted intellectuals who wove together art, science, anatomy and engineering. At the same time, writers like Petrarch, Boccaccio and Machiavelli profoundly renewed literature and political thought. The Renaissance revolution was not only aesthetic: it introduced a new method of observing the world that would lay the groundwork for modern science. Even today, walking the streets of Florence or admiring the Sistine Chapel, it is impossible not to feel the echo of that extraordinary era in which human curiosity seemed to know no limits and beauty was considered a path to understanding the divine.',
     3);
  end if;

  -- =========================================================
  -- PORTUGUÊS
  -- =========================================================
  select id into v_lang_id from public.languages where code = 'portuguese';
  if v_lang_id is not null then
    delete from public.articles where language_id = v_lang_id;
    insert into public.articles
      (language_id, slug, title, title_english, level, reading_minutes,
       content_target, content_english, order_index) values
    (v_lang_id, 'portuguese-ola-a1',
     'Olá do Brasil', 'Hello from Brazil', 'A1', 2,
     'Olá! Meu nome é Ana e eu sou brasileira. Eu moro no Rio de Janeiro, perto da praia. Todos os dias eu acordo cedo, tomo café com pão e vou para o trabalho. No Brasil, falamos português. Dizemos "oi" para os amigos e "bom dia" para as pessoas mais velhas. Eu gosto muito da minha cidade. O Rio tem montanhas, praias e muita música. Aos sábados eu encontro meus amigos na praia de Copacabana. Comemos açaí, bebemos suco de laranja e conversamos sobre futebol. Venha conhecer o Brasil, você vai gostar!',
     'Hello! My name is Ana and I am Brazilian. I live in Rio de Janeiro, near the beach. Every day I wake up early, have coffee with bread and go to work. In Brazil, we speak Portuguese. We say "hi" to friends and "good morning" to older people. I really like my city. Rio has mountains, beaches and lots of music. On Saturdays I meet my friends at Copacabana beach. We eat açaí, drink orange juice and talk about football. Come visit Brazil, you will love it!',
     1),
    (v_lang_id, 'portuguese-carnaval-b1',
     'O Carnaval brasileiro', 'Brazilian Carnival', 'B1', 3,
     'O Carnaval é a festa mais famosa do Brasil e acontece todos os anos em fevereiro ou março, antes da Quaresma. Embora muita gente pense apenas no Rio de Janeiro, cada região do país tem o seu próprio estilo. No Rio, as escolas de samba desfilam no Sambódromo com fantasias luxuosas, carros alegóricos e ritmo contagiante. Em Salvador, milhões de pessoas seguem trios elétricos pelas ruas dançando axé e samba-reggae. Já em Recife e Olinda, o frevo e o maracatu enchem as ladeiras coloniais de cores e energia. Mais do que uma festa, o Carnaval é uma expressão profunda da identidade brasileira, em que diferentes raças, classes e crenças se misturam por alguns dias em torno da música, da dança e do desejo de celebrar a vida.',
     'Carnival is the most famous celebration in Brazil and takes place every year in February or March, before Lent. Although many people think only of Rio de Janeiro, each region of the country has its own style. In Rio, samba schools parade in the Sambadrome with luxurious costumes, allegorical floats and contagious rhythms. In Salvador, millions of people follow electric trios through the streets, dancing axé and samba-reggae. In Recife and Olinda, frevo and maracatu fill the colonial slopes with colour and energy. More than a party, Carnival is a deep expression of Brazilian identity, in which different races, classes and beliefs mix for a few days around music, dance and the desire to celebrate life.',
     2),
    (v_lang_id, 'portuguese-literatura-c1',
     'A literatura lusófona', 'Lusophone literature', 'C1', 5,
     'Falar de literatura lusófona é entrar num universo onde uma mesma língua dá voz a continentes e experiências históricas distintas. Em Portugal, autores como Fernando Pessoa exploraram a multiplicidade do eu através dos seus heterónimos, enquanto José Saramago, vencedor do Nobel em 1998, construiu romances em que o realismo se mistura com a alegoria política. No Brasil, Machado de Assis criou no século XIX uma das obras mais sofisticadas da literatura mundial, antecipando técnicas modernistas com ironia e melancolia. Já Clarice Lispector, com a sua prosa introspectiva, transformou a língua portuguesa num instrumento de investigação filosófica. Nas antigas colónias africanas, escritores como Mia Couto, em Moçambique, e Pepetela, em Angola, reinventam o português com palavras das línguas locais, criando uma literatura híbrida, profundamente política e ao mesmo tempo lírica. Esta diversidade demonstra que o português é muito mais do que uma língua europeia: é um espaço de criação compartilhado por mais de duzentos milhões de falantes, cada um trazendo a sua história, as suas dores e as suas paisagens para dentro das palavras.',
     'To speak of Lusophone literature is to enter a universe where a single language gives voice to distinct continents and historical experiences. In Portugal, authors such as Fernando Pessoa explored the multiplicity of the self through his heteronyms, while José Saramago, the 1998 Nobel laureate, built novels in which realism is mixed with political allegory. In Brazil, Machado de Assis created in the 19th century one of the most sophisticated bodies of work in world literature, anticipating modernist techniques with irony and melancholy. Clarice Lispector, with her introspective prose, turned Portuguese into an instrument of philosophical investigation. In the former African colonies, writers such as Mia Couto in Mozambique and Pepetela in Angola reinvent Portuguese with words from local languages, creating a hybrid literature that is profoundly political and at the same time lyrical. This diversity shows that Portuguese is far more than a European language: it is a space of creation shared by more than two hundred million speakers, each bringing their history, their pain and their landscapes into the words.',
     3);
  end if;

  -- =========================================================
  -- РУССКИЙ
  -- =========================================================
  select id into v_lang_id from public.languages where code = 'russian';
  if v_lang_id is not null then
    delete from public.articles where language_id = v_lang_id;
    insert into public.articles
      (language_id, slug, title, title_english, level, reading_minutes,
       content_target, content_english, order_index) values
    (v_lang_id, 'russian-privet-a1',
     'Привет из России', 'Hello from Russia', 'A1', 2,
     'Привет! Меня зовут Анна, и я живу в Москве. Москва — это столица России. Каждое утро я пью чай и ем хлеб с маслом. Потом я еду на работу на метро. У меня есть собака, её зовут Шарик. Я люблю гулять с ней в парке. По выходным я хожу в гости к маме и папе. Мама готовит борщ и пельмени. Это очень вкусно. Зимой в Москве холодно и идёт снег, но летом тепло. Я люблю свою страну. Приезжай к нам в Россию!',
     'Hi! My name is Anna and I live in Moscow. Moscow is the capital of Russia. Every morning I drink tea and eat bread with butter. Then I go to work by metro. I have a dog, her name is Sharik. I like to walk with her in the park. On weekends I visit my mum and dad. Mum cooks borscht and pelmeni. It is very tasty. In winter Moscow is cold and it snows, but in summer it is warm. I love my country. Come visit us in Russia!',
     1),
    (v_lang_id, 'russian-kuhnya-b1',
     'Русская кухня', 'Russian cuisine', 'B1', 3,
     'Русская кухня очень разнообразна и тесно связана с климатом и историей страны. Поскольку зимы в России долгие и холодные, традиционная еда обычно сытная и согревающая. Классическое блюдо — это борщ, густой суп из свёклы, капусты и мяса, который подают со сметаной и чёрным хлебом. Другой популярный суп — щи. На второе часто едят пельмени, картофель с грибами или гречневую кашу. Очень важное место в культуре занимает чай: его пьют несколько раз в день, обычно с вареньем, мёдом или пирогами. На праздники готовят оливье — салат с овощами, мясом и майонезом. Каждый регион вносит свой вклад: в Сибири популярны рыба и дичь, на Кавказе — острые специи, а в южных регионах — фрукты и овощи. Русская кухня — это не просто еда, а способ собрать вокруг стола семью и друзей.',
     'Russian cuisine is very diverse and closely tied to the country''s climate and history. Because winters in Russia are long and cold, traditional food is usually hearty and warming. A classic dish is borscht, a thick soup made from beetroot, cabbage and meat, served with sour cream and black bread. Another popular soup is shchi. For the main course people often eat pelmeni, potatoes with mushrooms, or buckwheat porridge. Tea has a very important place in the culture: it is drunk several times a day, usually with jam, honey or pies. On holidays people prepare Olivier, a salad with vegetables, meat and mayonnaise. Each region contributes its own twist: in Siberia, fish and game are popular; in the Caucasus, hot spices; and in the southern regions, fruits and vegetables. Russian cuisine is not just food, but a way of gathering family and friends around the table.',
     2),
    (v_lang_id, 'russian-literatura-c1',
     'Литературное наследие России', 'Russia''s literary heritage', 'C1', 5,
     'Русская литература девятнадцатого века оказала колоссальное влияние на мировую культуру и до сих пор считается одной из вершин человеческой мысли. Произведения Александра Пушкина, Льва Толстого, Фёдора Достоевского, Антона Чехова и Николая Гоголя поднимают вопросы, которые остаются актуальными и в наши дни: природа добра и зла, свобода и ответственность, смысл страдания, столкновение традиции и современности. "Война и мир" Толстого — это не просто роман о наполеоновских войнах, а грандиозное исследование человеческой судьбы на фоне исторических событий. "Преступление и наказание" Достоевского заставляет читателя пережить мучительный путь сознания, ищущего искупления. Чехов создал новый тип драмы, в которой действие развивается не во внешних событиях, а в едва уловимых сдвигах настроения и в недосказанных словах. Двадцатый век принёс с собой новых гигантов: Анну Ахматову, Бориса Пастернака, Иосифа Бродского, Александра Солженицына. В сложных исторических условиях они продолжали отстаивать достоинство человеческого голоса. Сегодня знакомство с русской литературой — это не только эстетический опыт, но и важный ключ к пониманию того, как искусство может говорить о самых трудных вопросах эпохи.',
     'Nineteenth-century Russian literature had a colossal influence on world culture and is still considered one of the summits of human thought. The works of Alexander Pushkin, Leo Tolstoy, Fyodor Dostoevsky, Anton Chekhov and Nikolai Gogol raise questions that remain relevant today: the nature of good and evil, freedom and responsibility, the meaning of suffering, the clash between tradition and modernity. Tolstoy''s "War and Peace" is not just a novel about the Napoleonic wars but a grand investigation of human destiny against the backdrop of historical events. Dostoevsky''s "Crime and Punishment" makes the reader live through the tormented path of a consciousness searching for redemption. Chekhov created a new kind of drama in which action unfolds not in external events but in barely perceptible shifts of mood and in things left unsaid. The twentieth century brought new giants: Anna Akhmatova, Boris Pasternak, Joseph Brodsky, Alexander Solzhenitsyn. Under difficult historical conditions they continued to defend the dignity of the human voice. Today, becoming acquainted with Russian literature is not only an aesthetic experience but an important key to understanding how art can speak about the hardest questions of an era.',
     3);
  end if;

  -- =========================================================
  -- 日本語
  -- =========================================================
  select id into v_lang_id from public.languages where code = 'japanese';
  if v_lang_id is not null then
    delete from public.articles where language_id = v_lang_id;
    insert into public.articles
      (language_id, slug, title, title_english, level, reading_minutes,
       content_target, content_english, order_index) values
    (v_lang_id, 'japanese-konnichiwa-a1',
     'こんにちは、日本', 'Hello, Japan', 'A1', 2,
     'こんにちは。わたしの名前はゆかです。日本人です。東京に住んでいます。東京は日本の首都で、とても大きい町です。毎朝、わたしはコーヒーを飲んで、パンを食べます。それから電車で会社に行きます。仕事のあと、友だちと一緒に晩ご飯を食べます。日本の食べ物が好きです。特に寿司とラーメンが好きです。週末は公園を散歩したり、本を読んだりします。日本にはきれいな所がたくさんあります。ぜひ日本に来てください。',
     'Hello. My name is Yuka. I am Japanese. I live in Tokyo. Tokyo is the capital of Japan and a very big city. Every morning I drink coffee and eat bread. Then I go to my company by train. After work I have dinner with my friends. I like Japanese food. I especially like sushi and ramen. On weekends I walk in the park or read books. Japan has many beautiful places. Please come visit Japan!',
     1),
    (v_lang_id, 'japanese-sakura-b1',
     '桜の季節', 'The cherry blossom season', 'B1', 3,
     '日本の春の代表的な風景といえば、やはり桜です。桜の花は三月の終わりごろから四月のはじめにかけて咲き始め、二週間ほどで散ってしまいます。短い命ですが、その美しさは日本人の心に深い意味を持っています。古くから人々は桜の花の下で食べたり飲んだりする「お花見」を楽しんできました。会社の同僚や家族、友達と一緒に公園に集まり、料理を持ち寄って、ピンク色の花を見上げながら時間を過ごします。桜は単に美しい花というだけではなく、人生のはかなさや今この瞬間を大切にする気持ちの象徴でもあります。詩や音楽にもよく登場し、日本の文化を語るうえで欠かせない存在です。最近は外国からの観光客も増え、桜の名所はとてもにぎやかになりました。',
     'When people think of a typical spring scene in Japan, the first thing that comes to mind is the cherry blossom. The blossoms begin to bloom from the end of March into early April, and they fall after about two weeks. Although short-lived, their beauty holds deep meaning for the Japanese. Since ancient times, people have enjoyed "hanami" — eating and drinking under the cherry trees. Colleagues, families and friends gather in parks, bring food, and pass the time looking up at the pink flowers. Cherry blossoms are not merely beautiful flowers; they are also a symbol of life''s fragility and the value of the present moment. They appear often in poetry and music and are essential to any discussion of Japanese culture. Recently the number of foreign tourists has grown, and famous cherry blossom spots have become very lively.',
     2),
    (v_lang_id, 'japanese-biishiki-c1',
     '日本の美意識', 'Japanese aesthetic sensibility', 'C1', 5,
     '日本の伝統的な美意識を理解するためには、いくつかの重要な概念に触れる必要がある。代表的なものに「侘び寂び」がある。これは、不完全さや時の流れによって生まれる静かな美しさを尊ぶ感性であり、古びた茶碗や苔むした石、簡素な茶室などに見いだされる。完璧で派手なものよりも、控えめで余白のあるものに価値を見出すこの感覚は、千利休によって整えられた茶道の精神とも深く結びついている。また「物の哀れ」という言葉は、季節の移ろいや人の感情の細やかな揺れを慈しむ心を表し、平安文学、特に『源氏物語』にその源流が見られる。さらに「間」の概念は、音楽や建築、武道、書道にいたるまで、空白そのものに表現を見いだす日本独自の美学である。これらの考え方は、現代の建築家やデザイナー、世界中の芸術家にも大きな影響を与えてきた。日本の美意識は単なる装飾の理論ではなく、自然と人生に対する深い哲学であり、変化を受け入れ、消えゆくものの中に永遠を見ようとする姿勢にほかならない。',
     'To understand traditional Japanese aesthetic sensibility, one must engage with several key concepts. A representative one is "wabi-sabi" — a sensibility that cherishes the quiet beauty arising from imperfection and the passage of time, found in an old tea bowl, a moss-covered stone, or a simple tea room. The idea of valuing the modest and the unfilled over the perfect and ostentatious is deeply tied to the spirit of the tea ceremony as formalized by Sen no Rikyu. The phrase "mono no aware" expresses a tender awareness of the impermanence of the seasons and the subtle stirrings of human emotion; its source lies in Heian literature, especially "The Tale of Genji." The concept of "ma" — the appreciation of emptiness itself as expression — runs through Japanese music, architecture, martial arts and calligraphy as a uniquely Japanese aesthetic. These ideas have profoundly influenced modern architects, designers and artists around the world. Japanese aesthetics is not merely a theory of decoration; it is a deep philosophy of nature and life, an attitude that accepts change and seeks the eternal within things that fade away.',
     3);
  end if;

  -- =========================================================
  -- 한국어
  -- =========================================================
  select id into v_lang_id from public.languages where code = 'korean';
  if v_lang_id is not null then
    delete from public.articles where language_id = v_lang_id;
    insert into public.articles
      (language_id, slug, title, title_english, level, reading_minutes,
       content_target, content_english, order_index) values
    (v_lang_id, 'korean-annyeonghaseyo-a1',
     '안녕하세요, 한국', 'Hello, Korea', 'A1', 2,
     '안녕하세요. 제 이름은 민수입니다. 저는 한국 사람이에요. 서울에 살아요. 서울은 한국의 수도이고 아주 큰 도시예요. 아침에 저는 보통 빵과 우유를 먹어요. 회사에 지하철로 가요. 일이 끝나면 친구하고 같이 저녁을 먹어요. 저는 한국 음식을 좋아해요. 특히 김치찌개와 비빔밥을 좋아해요. 주말에는 공원을 걷거나 영화를 봐요. 한국에는 예쁜 곳이 많이 있어요. 한국에 꼭 와 보세요!',
     'Hello. My name is Minsu. I am Korean. I live in Seoul. Seoul is the capital of Korea and a very big city. In the morning I usually eat bread and milk. I go to my company by subway. When work is finished I have dinner with friends. I like Korean food. I especially like kimchi-jjigae and bibimbap. On weekends I walk in the park or watch movies. Korea has many beautiful places. Please come and visit Korea!',
     1),
    (v_lang_id, 'korean-eumsik-b1',
     '한국의 음식 문화', 'Korean food culture', 'B1', 3,
     '한국 음식은 단순한 끼니가 아니라 오랜 역사와 가족 문화를 담은 작품이라고 할 수 있습니다. 한국의 식탁에는 보통 밥과 국, 그리고 여러 가지 반찬이 함께 올라옵니다. 가장 대표적인 음식은 김치입니다. 김치는 배추나 무에 고춧가루, 마늘, 젓갈을 넣어 발효시킨 음식으로, 거의 모든 식사에 빠지지 않습니다. 또한 비빔밥, 불고기, 삼계탕 같은 요리도 외국 사람들에게 인기가 많습니다. 한국 사람들은 식사를 할 때 함께 나누어 먹는 것을 중요하게 생각합니다. 큰 그릇에서 음식을 덜어 먹고, 술을 따를 때는 두 손으로 잔을 잡거나 따라 줍니다. 이런 작은 행동에도 상대를 존중하는 마음이 담겨 있습니다. 최근에는 한국 음식이 세계 여러 나라에서 큰 사랑을 받고 있습니다.',
     'Korean food is not just a meal but a creation that carries a long history and family culture. A Korean table usually has rice, soup, and several side dishes together. The most representative food is kimchi. Kimchi is made by fermenting cabbage or radish with chili powder, garlic and salted seafood; it is almost never missing from a meal. Dishes such as bibimbap, bulgogi and samgyetang are also very popular among foreigners. Koreans place great importance on sharing meals together. People take food from large communal dishes, and when pouring alcohol they hold or pour the cup with both hands. Even these small gestures carry respect for the other person. Recently, Korean cuisine has been gaining tremendous love around the world.',
     2),
    (v_lang_id, 'korean-hanryu-c1',
     '한류와 세계', 'The Korean Wave and the world', 'C1', 5,
     '지난 이십 년 동안 한국의 대중문화는 놀라운 속도로 세계 무대에 진출하였다. 처음에는 드라마와 영화를 중심으로 아시아에서 인기를 얻기 시작하였으며, 이후에는 K팝이라는 음악 장르가 전 세계 청소년의 마음을 사로잡았다. 그러나 한류의 영향력은 단순히 음악이나 영상을 넘어, 한국어 학습 인구의 폭발적 증가, 한국 음식과 화장품의 세계화, 한국식 패션과 메이크업의 유행 등 광범위한 문화 현상으로 확장되었다. 이러한 흐름의 배경에는 단순히 운이나 우연이 아니라, 오랜 시간 축적된 콘텐츠 산업의 인프라, 정부의 문화 정책, 그리고 한국 사회 특유의 빠른 적응력과 완벽주의적 제작 방식이 있다. 봉준호 감독의 영화 <기생충>이 아카데미상을 수상하고, 방탄소년단이 유엔 총회에서 연설하며, 넷플릭스 시리즈 <오징어 게임>이 세계적인 화제가 된 사실은 우연의 결과가 아니다. 한류는 단순한 유행을 넘어, 한 나라가 자신의 이야기를 세계와 어떻게 나누어야 하는지를 보여 주는 흥미로운 사례라 할 수 있다.',
     'Over the past twenty years, Korean popular culture has stepped onto the world stage with remarkable speed. It first gained popularity in Asia through dramas and films, and later the genre known as K-pop captured the hearts of young people around the globe. But the influence of the Korean Wave has spread beyond music or video to a wide range of cultural phenomena: an explosive rise in the number of Korean learners, the globalization of Korean food and cosmetics, and the popularity of Korean fashion and make-up. Behind this current lies not luck or chance but the long-accumulated infrastructure of the Korean content industry, government cultural policy, and a uniquely Korean combination of fast adaptation and perfectionist production. The Academy Award for Bong Joon-ho''s "Parasite," BTS''s speech at the UN General Assembly, and the global sensation of the Netflix series "Squid Game" are not coincidences. The Korean Wave is more than a trend: it is an interesting case of how a country shares its own stories with the world.',
     3);
  end if;

  -- =========================================================
  -- 中文 (简体)
  -- =========================================================
  select id into v_lang_id from public.languages where code = 'chinese';
  if v_lang_id is not null then
    delete from public.articles where language_id = v_lang_id;
    insert into public.articles
      (language_id, slug, title, title_english, level, reading_minutes,
       content_target, content_english, order_index) values
    (v_lang_id, 'chinese-nihao-a1',
     '你好，中国', 'Hello, China', 'A1', 2,
     '你好！我叫李华，我是中国人。我住在北京。北京是中国的首都，是一个很大的城市。每天早上，我喝豆浆，吃包子。然后我坐地铁去公司上班。下班以后，我和朋友一起吃晚饭。我喜欢中国菜，特别喜欢饺子和麻婆豆腐。周末我常常去公园散步，或者跟家人聊天。北京有很多名胜古迹，比如长城和故宫。欢迎你来中国玩！',
     'Hello! My name is Li Hua, I am Chinese. I live in Beijing. Beijing is the capital of China, a very big city. Every morning I drink soy milk and eat baozi. Then I take the subway to my company. After work I have dinner with friends. I like Chinese food, especially dumplings and mapo tofu. On weekends I often walk in parks or chat with family. Beijing has many famous historical sites, such as the Great Wall and the Forbidden City. Welcome to visit China!',
     1),
    (v_lang_id, 'chinese-cha-b1',
     '中国的茶文化', 'Chinese tea culture', 'B1', 3,
     '在中国，茶不仅是一种饮品，更是一种深厚的文化。中国是世界上最早发现并使用茶叶的国家，已经有几千年的历史。从皇帝到普通人，大家都喜欢喝茶。中国的茶种类很多，常见的有绿茶、红茶、乌龙茶和普洱茶。每一种茶都有不同的味道和功能。绿茶清淡，常常在春天和夏天喝；红茶味道浓厚，适合冬天；乌龙茶口感丰富，是广东和福建人最喜欢的；普洱茶则越陈越香，很多人会收藏。在中国，喝茶也是一种社交方式。朋友见面、谈生意、招待客人，桌上都会有一壶热茶。喝茶的过程中，大家慢慢聊天，享受平静的时光。茶让人安静，也让人和人之间的距离更近。',
     'In China, tea is not only a drink but a deep cultural tradition. China is the country where tea was first discovered and used, with a history of several thousand years. From emperors to ordinary people, everyone enjoys tea. There are many kinds of Chinese tea, with green tea, black tea, oolong, and pu-erh being the most common. Each has its own taste and function. Green tea is light and often drunk in spring and summer; black tea is strong and suits winter; oolong has a rich taste and is loved in Guangdong and Fujian; pu-erh becomes more fragrant as it ages, and many people collect it. Tea is also a social activity. When friends meet, when business is discussed, when guests are received, a pot of hot tea is always on the table. While drinking, people chat slowly and enjoy a peaceful moment. Tea calms people, and it also brings them closer.',
     2),
    (v_lang_id, 'chinese-zhexue-c1',
     '中国哲学的三种声音', 'Three voices in Chinese philosophy', 'C1', 5,
     '中国古代的思想世界可以用三种声音来概括：儒家、道家和佛教。它们看似不同，却共同塑造了中国人对世界与自我的理解。儒家由孔子奠基，强调人与人之间的伦理关系，主张通过学习、礼仪和道德修养来建立一个有序、和谐的社会。在儒家眼中，家庭是社会的基础，孝顺、忠诚与仁爱是最重要的美德。道家则把目光投向自然。老子和庄子认为，真正的智慧在于「无为」，也就是顺应事物本身的节奏，而不是用力量去改变它。道家提醒人们，过度的欲望和人为的规则反而会让生命变得疲惫。佛教从印度传入后，与中国本土文化深度融合，形成了独特的禅宗。禅宗强调直接体悟，反对僵化的语言与教条，主张在日常生活中体验真理。这三种思想并非互相排斥，反而互补：儒家给予中国人责任感，道家给予自由，佛教给予内在的平静。直到今天，许多中国人仍然在这三种声音之间寻找属于自己的生活方式。',
     'The world of ancient Chinese thought can be summed up in three voices: Confucianism, Daoism and Buddhism. They appear different, yet together they shaped the Chinese understanding of the world and the self. Confucianism, founded by Confucius, emphasizes ethical relationships between people and seeks to build an orderly, harmonious society through study, ritual and moral cultivation. For Confucians, the family is the foundation of society, and filial piety, loyalty and benevolence are the highest virtues. Daoism turns its gaze to nature. Laozi and Zhuangzi held that true wisdom lies in "wu wei" — acting in accord with the rhythm of things rather than forcing them. Daoism reminds people that excessive desire and artificial rules in fact make life weary. After Buddhism arrived from India it merged deeply with native Chinese culture, giving rise to the distinctive Chan (Zen) school, which stresses direct insight, rejects rigid words and dogma, and seeks truth within everyday life. These three traditions are not mutually exclusive but complementary: Confucianism grants the Chinese a sense of responsibility, Daoism grants freedom, and Buddhism grants inner peace. To this day, many Chinese still search among these three voices for their own way of living.',
     3);
  end if;

  -- =========================================================
  -- العربية
  -- =========================================================
  select id into v_lang_id from public.languages where code = 'arabic';
  if v_lang_id is not null then
    delete from public.articles where language_id = v_lang_id;
    insert into public.articles
      (language_id, slug, title, title_english, level, reading_minutes,
       content_target, content_english, order_index) values
    (v_lang_id, 'arabic-marhaban-a1',
     'مرحباً بكم في العالم العربي', 'Welcome to the Arab world', 'A1', 2,
     'مرحباً! اسمي ليلى وأنا من المغرب. أعيش في مدينة الرباط، عاصمة المغرب. كل صباح أشرب القهوة وآكل الخبز مع زيت الزيتون. ثم أذهب إلى العمل بالحافلة. في العالم العربي نقول «مرحباً» للأصدقاء و«السلام عليكم» للأشخاص الكبار. أحب لغتي، اللغة العربية، لأنها لغة جميلة وموسيقية. في عطلة نهاية الأسبوع أزور عائلتي ونأكل الكسكس معاً. تعالوا لزيارة بلدي، سترون كرم الناس وجمال الطبيعة!',
     'Hello! My name is Layla and I am from Morocco. I live in the city of Rabat, the capital of Morocco. Every morning I drink coffee and eat bread with olive oil. Then I go to work by bus. In the Arab world we say "marhaban" to friends and "as-salamu alaykum" to older people. I love my language, Arabic, because it is a beautiful and musical language. On the weekend I visit my family and we eat couscous together. Come and visit my country — you will see the generosity of the people and the beauty of nature!',
     1),
    (v_lang_id, 'arabic-taeam-b1',
     'الطعام في العالم العربي', 'Food in the Arab world', 'B1', 3,
     'يتميز المطبخ العربي بتنوعه الكبير، لأنه يمتد من المغرب إلى الخليج، وكل منطقة لها مكوناتها وعاداتها. في بلاد الشام يشتهر الحمص والفلافل والمشاوي مع الخبز الطازج، بينما يقدم المغرب طبق الكسكس وطاجين اللحم بالخوخ والبرقوق. أما في مصر فالفول والكشري من أكثر الأطباق شعبية. في دول الخليج تكثر الأطباق الحارة كالكبسة والمندي. لا يكتمل المطبخ العربي بدون التمر والحلويات مثل البقلاوة والكنافة، خاصة في شهر رمضان عندما تجتمع العائلات حول مائدة الإفطار. ضيافة الطعام جزء أساسي من الثقافة العربية، فالضيف يستقبل بكل احترام ويقدم له أفضل ما في البيت. تناول الطعام في العالم العربي ليس مجرد وجبة، بل لحظة للقاء والتواصل بين الأهل والأصدقاء.',
     'Arab cuisine is distinguished by its great diversity, because it stretches from Morocco to the Gulf, and each region has its own ingredients and customs. In the Levant, hummus, falafel and grilled meats with fresh bread are famous; in Morocco, couscous and lamb tagine with prunes and plums are popular; in Egypt, ful and koshari are among the most beloved dishes; in the Gulf countries, spicy dishes like kabsa and mandi abound. The cuisine is incomplete without dates and sweets like baklava and knafeh, especially during Ramadan when families gather around the iftar table. Food hospitality is a fundamental part of Arab culture: a guest is received with full respect and offered the best of the household. Eating in the Arab world is not just a meal but a moment of meeting and connection between family and friends.',
     2),
    (v_lang_id, 'arabic-adab-c1',
     'الأدب العربي عبر التاريخ', 'Arabic literature through history', 'C1', 5,
     'يعد الأدب العربي واحداً من أعرق الآداب في العالم، إذ يمتد تاريخه لأكثر من خمسة عشر قرناً، ابتداءً من الشعر الجاهلي قبل ظهور الإسلام، مروراً بالعصر العباسي الذي شهد ازدهاراً غير مسبوق للفلسفة والأدب والعلوم، ووصولاً إلى الأدب العربي الحديث الذي شهد تحولات عميقة في القرنين التاسع عشر والعشرين. في العصر الكلاسيكي برز شعراء عظماء مثل المتنبي وأبو نواس وأبو العلاء المعري، إلى جانب نثر فلسفي ولغوي رفيع المستوى مثل أعمال الجاحظ. في العصر الحديث، عاش الأدب العربي تجديداً واسعاً مع روّاد النهضة، ثم مع كتّاب كبار كنجيب محفوظ الذي نال جائزة نوبل عام 1988 وقدّم للعالم رواية اجتماعية عميقة عن القاهرة وأهلها. ومن سوريا ولبنان والمغرب وفلسطين، خرجت أصوات شعرية وروائية قوية مثل أدونيس ومحمود درويش وغسان كنفاني وآسيا جبار، تطرح أسئلة عن الهوية، والحرية، والذاكرة، والمنفى. اليوم يواصل جيل جديد من الكتّاب العرب الكتابة بلغات متعددة وأنواع أدبية مختلفة، مؤكداً أن الأدب العربي ليس تراثاً متحفياً بل حركة حية تواكب أسئلة العالم المعاصر.',
     'Arabic literature is among the most ancient literatures in the world; its history extends over more than fifteen centuries, from pre-Islamic poetry, through the Abbasid era that witnessed an unprecedented flourishing of philosophy, literature and science, to modern Arabic literature, which has seen profound transformations in the nineteenth and twentieth centuries. In the classical age, great poets such as al-Mutanabbi, Abu Nuwas and al-Ma''arri stood out, alongside the refined philosophical and linguistic prose of al-Jahiz. In the modern era, Arabic literature underwent a wide renewal with the pioneers of the Nahda, and then with major writers such as Naguib Mahfouz, who won the Nobel Prize in 1988 and offered the world a deep social novel of Cairo and its people. From Syria, Lebanon, Morocco and Palestine, powerful voices in poetry and fiction emerged, such as Adonis, Mahmoud Darwish, Ghassan Kanafani and Assia Djebar, raising questions about identity, freedom, memory and exile. Today, a new generation of Arab writers continues to write in many languages and many genres, affirming that Arabic literature is not a museum heritage but a living movement that addresses the questions of the contemporary world.',
     3);
  end if;

  -- =========================================================
  -- हिन्दी
  -- =========================================================
  select id into v_lang_id from public.languages where code = 'hindi';
  if v_lang_id is not null then
    delete from public.articles where language_id = v_lang_id;
    insert into public.articles
      (language_id, slug, title, title_english, level, reading_minutes,
       content_target, content_english, order_index) values
    (v_lang_id, 'hindi-namaste-a1',
     'नमस्ते भारत', 'Hello India', 'A1', 2,
     'नमस्ते! मेरा नाम राहुल है और मैं भारतीय हूँ। मैं दिल्ली में रहता हूँ। दिल्ली भारत की राजधानी है और एक बहुत बड़ा शहर है। हर सुबह मैं चाय पीता हूँ और रोटी खाता हूँ। फिर मैं मेट्रो से दफ्तर जाता हूँ। काम के बाद मैं अपने दोस्तों के साथ खाना खाता हूँ। मुझे भारतीय खाना बहुत पसंद है, खासकर बिरयानी और समोसा। हफ्ते के अंत में मैं अपने परिवार से मिलता हूँ। भारत में बहुत सारी भाषाएँ और संस्कृतियाँ हैं। आप भी एक दिन भारत आइए।',
     'Hello! My name is Rahul and I am Indian. I live in Delhi. Delhi is the capital of India and a very big city. Every morning I drink tea and eat roti. Then I go to my office by metro. After work I eat with my friends. I really like Indian food, especially biryani and samosa. On weekends I visit my family. India has many languages and cultures. Please come to India one day too!',
     1),
    (v_lang_id, 'hindi-tyohaar-b1',
     'भारतीय त्यौहार', 'Indian festivals', 'B1', 3,
     'भारत में त्यौहारों का बहुत महत्व है क्योंकि वे केवल खुशियाँ मनाने का अवसर नहीं होते, बल्कि लोगों को आपस में जोड़ने का भी काम करते हैं। दिवाली, होली, ईद, क्रिसमस, गुरुपर्व और पोंगल जैसे पर्व अलग-अलग धर्मों और क्षेत्रों से आते हैं, लेकिन सब मिलकर एक ही भावना दिखाते हैं — परिवार और दोस्तों के साथ समय बिताना। दिवाली रोशनी का त्यौहार है, इसमें लोग अपने घर साफ करते हैं, दीये जलाते हैं और मिठाइयाँ बाँटते हैं। होली रंगों का त्यौहार है, जब बच्चे और बड़े मिलकर एक-दूसरे पर रंग डालते हैं और पुराने झगड़े भूल जाते हैं। ईद पर मुस्लिम परिवार सेवइयाँ बनाते हैं और सब मिलकर ख़ुशी मनाते हैं। ऐसे त्यौहारों के दौरान बाज़ार सज जाते हैं, लोग नए कपड़े पहनते हैं और घरों से खाने की महक आती है। यही विविधता भारत की असली पहचान है।',
     'In India, festivals carry great importance because they are not only an occasion to celebrate joy, they also bring people together. Festivals such as Diwali, Holi, Eid, Christmas, Gurpurab and Pongal come from different religions and regions, yet all of them express the same feeling — spending time with family and friends. Diwali is the festival of lights; people clean their homes, light lamps and share sweets. Holi is the festival of colours, when children and adults throw colours on each other and forget old quarrels. On Eid, Muslim families prepare sevai and celebrate together. During these festivals markets are decorated, people wear new clothes and the smell of food fills every home. This diversity is the true identity of India.',
     2),
    (v_lang_id, 'hindi-darshan-c1',
     'भारतीय दर्शन की धाराएँ', 'Currents of Indian philosophy', 'C1', 5,
     'भारतीय दर्शन एक प्राचीन और गहन परंपरा है, जिसकी जड़ें ऋग्वेद से लेकर आधुनिक विचारकों तक फैली हुई हैं। इसमें कई अलग-अलग धाराएँ शामिल हैं, जिनमें वेदांत, सांख्य, योग, न्याय, मीमांसा और वैशेषिक प्रमुख हैं। ये दर्शन केवल अमूर्त विचार नहीं हैं, बल्कि जीवन जीने का एक तरीका भी प्रस्तावित करते हैं। उदाहरण के लिए, अद्वैत वेदांत आदि शंकराचार्य द्वारा दिया गया विचार है, जिसके अनुसार आत्मा और परमात्मा एक ही हैं और जो हम संसार में देखते हैं, वह केवल एक तरह की माया है। दूसरी ओर, बौद्ध दर्शन हमें बताता है कि दुख का कारण इच्छा है और उसका समाधान आठ-गुना मार्ग में निहित है। जैन परंपरा अहिंसा और संयम पर बल देती है, जबकि भक्ति आंदोलन ने सरल भाषा और प्रेम के माध्यम से आम जनता तक आध्यात्मिक चेतना पहुँचाई। आधुनिक काल में स्वामी विवेकानंद, श्री अरबिंद और महात्मा गांधी जैसे विचारकों ने इन प्राचीन विचारों को सामाजिक न्याय, स्वतंत्रता और मानवीय गरिमा के सवालों से जोड़ा। आज भी भारतीय दर्शन यह सिखाता है कि सच्चा ज्ञान केवल किताबों में नहीं, बल्कि अनुभव, साधना और सेवा में मिलता है।',
     'Indian philosophy is an ancient and profound tradition, with roots extending from the Rigveda to modern thinkers. It contains many distinct currents, among them Vedanta, Samkhya, Yoga, Nyaya, Mimamsa and Vaisheshika. These philosophies are not only abstract ideas but also propose a way of living. For example, Advaita Vedanta, given by Adi Shankaracharya, holds that the individual soul and the supreme reality are one, and what we perceive in the world is a kind of illusion. Buddhist philosophy, on the other hand, teaches that the cause of suffering is desire, and its remedy lies in the Eightfold Path. The Jain tradition emphasizes non-violence and restraint, while the Bhakti movement brought spiritual consciousness to ordinary people through simple language and love. In modern times, thinkers such as Swami Vivekananda, Sri Aurobindo and Mahatma Gandhi connected these ancient ideas to questions of social justice, freedom and human dignity. Even today, Indian philosophy teaches that true knowledge is found not only in books but in experience, practice and service.',
     3);
  end if;

  -- =========================================================
  -- TÜRKÇE
  -- =========================================================
  select id into v_lang_id from public.languages where code = 'turkish';
  if v_lang_id is not null then
    delete from public.articles where language_id = v_lang_id;
    insert into public.articles
      (language_id, slug, title, title_english, level, reading_minutes,
       content_target, content_english, order_index) values
    (v_lang_id, 'turkish-merhaba-a1',
     'Merhaba Türkiye', 'Hello Turkey', 'A1', 2,
     'Merhaba! Adım Ayşe ve Türk''üm. İstanbul''da yaşıyorum. İstanbul Türkiye''nin en büyük şehridir. Sabahları çay içip simit yerim. Sonra metroyla işe giderim. Türkçede arkadaşlara "merhaba" deriz, yaşlılara ise "günaydın" diye selam veririz. Akşamları ailemle birlikte yemek yiyoruz. Türk yemeklerini çok severim, özellikle dolma ve baklava. Hafta sonu boğazda yürüyüş yaparım ya da arkadaşlarımla kahve içerim. İstanbul çok güzel bir şehirdir, Avrupa ve Asya bir araya gelir. Lütfen Türkiye''ye gelin!',
     'Hello! My name is Ayşe and I am Turkish. I live in Istanbul. Istanbul is the biggest city in Turkey. In the mornings I drink tea and eat simit. Then I go to work by metro. In Turkish we say "merhaba" to friends, and we greet elders with "günaydın." In the evenings I eat with my family. I love Turkish food, especially dolma and baklava. On weekends I take a walk along the Bosphorus or have coffee with friends. Istanbul is a beautiful city where Europe and Asia meet. Please come to Turkey!',
     1),
    (v_lang_id, 'turkish-mutfak-b1',
     'Türk mutfağı', 'Turkish cuisine', 'B1', 3,
     'Türk mutfağı yüzyıllar boyunca farklı kültürlerin etkisiyle şekillenmiş zengin bir mutfaktır. Osmanlı sarayının lezzetlerinden Anadolu''nun köy yemeklerine kadar uzanan bu geleneğin temelinde taze sebzeler, baharatlar, zeytinyağı ve hamur işleri yer alır. Kahvaltı Türkiye''de adeta bir ritüeldir: peynir, zeytin, domates, yumurta, bal ve elbette taze ekmek mutlaka sofrada bulunur. Öğlen ya da akşam yemeklerinde kebap, mantı, dolma, pilav ve çorba sıkça tercih edilir. Tatlılar ayrı bir dünyadır; baklava, künefe, sütlaç ve lokum sadece Türklerin değil, dünyanın birçok ülkesinin damak zevkini etkilemiştir. Yemek yemek Türkiye''de yalnızca karın doyurmak değil, aynı zamanda misafirperverliğin ifadesidir. Bir Türk evine konuk olduğunuzda boş bir tabakla ayrılmanız neredeyse imkânsızdır.',
     'Turkish cuisine is a rich culinary tradition shaped over centuries by many cultures. Stretching from the flavours of the Ottoman palace to the village dishes of Anatolia, this tradition is built on fresh vegetables, spices, olive oil and pastries. Breakfast in Turkey is almost a ritual: cheese, olives, tomato, eggs, honey and of course fresh bread are always on the table. For lunch or dinner, kebab, mantı, dolma, pilaf and soup are frequent choices. Desserts are a world of their own; baklava, künefe, rice pudding and lokum have influenced the palates not only of Turks but of many countries. Eating in Turkey is not simply about filling the stomach; it is also an expression of hospitality. When you are a guest in a Turkish home, leaving with an empty plate is almost impossible.',
     2),
    (v_lang_id, 'turkish-anadolu-c1',
     'Anadolu medeniyetleri', 'The civilizations of Anatolia', 'C1', 5,
     'Anadolu, binlerce yıldır insanlık tarihinin en zengin sahnelerinden biri olmuştur. Bu topraklarda Hititler, Frigler, Lidyalılar, Urartular, Yunanlar, Romalılar, Bizanslılar, Selçuklular ve Osmanlılar birbiri ardına devletler kurmuş; her biri dil, mimari ve düşünce alanında derin izler bırakmıştır. Çatalhöyük gibi neolitik yerleşimler, insanlığın tarımdan şehirleşmeye geçişinin en eski tanıklarındandır. Efes ve Bergama, antik dünyanın en görkemli kütüphane ve tiyatrolarına ev sahipliği yapmıştır. Konya, on üçüncü yüzyılda Mevlânâ''nın felsefesiyle uluslararası bir kültür merkezi olurken, İstanbul hem Doğu Roma''nın hem de Osmanlı''nın başkenti olarak iki ayrı imparatorluğa kimlik vermiştir. Bu çok katmanlı miras, modern Türkiye''nin yalnızca bir ulus-devlet değil, aynı zamanda farklı uygarlıkların izlerini taşıyan bir kültürel coğrafya olduğunu hatırlatır. Antik bir tapınağın yanındaki Selçuklu medresesi ya da Roma yolunda yükselen Osmanlı camisi, geçmişin bugünün içinde nasıl yaşamaya devam ettiğinin sessiz birer kanıtıdır. Anadolu''yu anlamak, sadece bir ülkeyi değil, medeniyetlerin nasıl birbirini beslediğini de anlamak demektir.',
     'For thousands of years Anatolia has been one of the richest stages of human history. On these lands the Hittites, Phrygians, Lydians, Urartians, Greeks, Romans, Byzantines, Seljuks and Ottomans founded states one after another, each leaving deep marks on language, architecture and thought. Neolithic settlements such as Çatalhöyük are among the earliest witnesses of humanity''s transition from agriculture to urban life. Ephesus and Pergamum hosted some of the most magnificent libraries and theatres of the ancient world. Konya, in the thirteenth century, became an international cultural centre through the philosophy of Rumi, while Istanbul, as the capital of both Eastern Rome and the Ottoman Empire, gave identity to two distinct empires. This multi-layered heritage reminds us that modern Turkey is not only a nation-state but also a cultural geography carrying the traces of many civilizations. A Seljuk madrasa next to an ancient temple, or an Ottoman mosque rising along a Roman road, is silent proof of how the past continues to live within the present. Understanding Anatolia means understanding not only a country but how civilizations have nourished one another.',
     3);
  end if;

  -- =========================================================
  -- TIẾNG VIỆT
  -- =========================================================
  select id into v_lang_id from public.languages where code = 'vietnamese';
  if v_lang_id is not null then
    delete from public.articles where language_id = v_lang_id;
    insert into public.articles
      (language_id, slug, title, title_english, level, reading_minutes,
       content_target, content_english, order_index) values
    (v_lang_id, 'vietnamese-xinchao-a1',
     'Xin chào Việt Nam', 'Hello Vietnam', 'A1', 2,
     'Xin chào! Tôi tên là Mai và tôi là người Việt Nam. Tôi sống ở Hà Nội. Hà Nội là thủ đô của Việt Nam và là một thành phố rất đẹp. Buổi sáng, tôi thường uống cà phê sữa đá và ăn phở. Sau đó, tôi đi làm bằng xe máy. Buổi tối, tôi ăn cơm với gia đình. Tôi rất thích món ăn Việt Nam, đặc biệt là bánh mì và bún bò. Vào cuối tuần, tôi đi dạo quanh Hồ Gươm hoặc đến quán cà phê với bạn bè. Việt Nam có nhiều cảnh đẹp và con người thân thiện. Hãy đến thăm Việt Nam nhé!',
     'Hello! My name is Mai and I am Vietnamese. I live in Hanoi. Hanoi is the capital of Vietnam and a very beautiful city. In the morning I usually have iced milk coffee and eat phở. Then I go to work by motorbike. In the evening I eat rice with my family. I really like Vietnamese food, especially bánh mì and bún bò. On weekends I walk around Hoan Kiem Lake or meet friends at a café. Vietnam has many beautiful sights and friendly people. Come visit Vietnam!',
     1),
    (v_lang_id, 'vietnamese-amthuc-b1',
     'Ẩm thực Việt Nam', 'Vietnamese cuisine', 'B1', 3,
     'Ẩm thực Việt Nam được biết đến trên toàn thế giới bởi sự tươi ngon, cân bằng và tinh tế. Khác với nhiều nền ẩm thực khác, người Việt rất ít khi sử dụng dầu mỡ nặng. Thay vào đó, họ ưu tiên rau thơm, các loại gia vị tự nhiên và phương pháp nấu nhẹ nhàng như luộc, hấp hoặc cuốn. Phở có lẽ là món ăn nổi tiếng nhất, với nước dùng được ninh nhiều giờ từ xương bò và một bó hành tươi. Ở miền Trung, người ta thích các món cay như bún bò Huế, trong khi miền Nam có vị ngọt hơn và sử dụng nhiều dừa. Một bữa cơm gia đình Việt thường có cơm trắng, một món mặn, một món rau và một bát canh. Đặc biệt, người Việt rất coi trọng việc ăn cùng nhau, nên bữa cơm không chỉ là dinh dưỡng mà còn là khoảnh khắc kết nối các thế hệ.',
     'Vietnamese cuisine is known around the world for its freshness, balance and refinement. Unlike many other cuisines, Vietnamese cooking rarely uses heavy oils. Instead, it favours fresh herbs, natural spices and gentle methods such as boiling, steaming or wrapping. Phở is perhaps the most famous dish, with a broth simmered for many hours from beef bones and a generous bunch of fresh herbs. In central Vietnam, people enjoy spicy dishes such as bún bò Huế, while southern Vietnamese cuisine is sweeter and uses a lot of coconut. A typical Vietnamese family meal includes white rice, a savoury dish, a vegetable dish and a bowl of soup. Most importantly, Vietnamese people place great value on eating together, so a meal is not only nutrition but also a moment of connection between generations.',
     2),
    (v_lang_id, 'vietnamese-lichsu-c1',
     'Lịch sử và bản sắc Việt Nam', 'History and identity of Vietnam', 'C1', 5,
     'Lịch sử Việt Nam là câu chuyện kéo dài hàng nghìn năm về sự khẳng định bản sắc trước những thế lực bên ngoài. Từ thời các vua Hùng dựng nước đến những cuộc kháng chiến chống ngoại xâm trong các thế kỷ tiếp theo, ý thức về độc lập đã trở thành một phần không thể tách rời của tâm hồn dân tộc. Trong suốt một nghìn năm Bắc thuộc, văn hóa Trung Hoa đã ảnh hưởng sâu sắc đến chữ viết, triết học và tổ chức nhà nước của Việt Nam, nhưng người Việt vẫn giữ được ngôn ngữ riêng và phong tục riêng. Đến thế kỷ 19 và 20, đất nước phải đối mặt với chế độ thực dân Pháp và sau đó là chiến tranh kéo dài, để lại những vết thương sâu sắc nhưng cũng nuôi dưỡng một ý chí phi thường. Ngày nay, Việt Nam đang chuyển mình mạnh mẽ về kinh tế, đồng thời cố gắng bảo tồn các giá trị văn hóa truyền thống như tôn trọng người lớn tuổi, lòng yêu nước và sự gắn bó gia đình. Việc hiểu lịch sử Việt Nam không chỉ là hiểu về quá khứ, mà còn giúp ta thấy được vì sao đất nước này, dù nhỏ về diện tích, lại sở hữu một sức sống bền bỉ và một bản sắc rất riêng giữa châu Á.',
     'The history of Vietnam is a story spanning thousands of years of asserting identity against outside forces. From the time of the Hùng kings who founded the state to the long series of resistance wars against foreign invaders, the consciousness of independence has become inseparable from the national soul. Over a thousand years of Northern domination, Chinese culture deeply influenced Vietnamese writing, philosophy and state organization, yet the Vietnamese kept their own language and customs. In the 19th and 20th centuries the country faced French colonial rule and then prolonged war, leaving deep wounds but also nurturing an extraordinary will. Today, Vietnam is undergoing a powerful economic transformation while striving to preserve traditional cultural values such as respect for elders, patriotism and family bonds. Understanding Vietnamese history is not only about the past; it also helps us see why this country, small in area, possesses a tenacious vitality and a very distinct identity within Asia.',
     3);
  end if;

  -- =========================================================
  -- বাংলা
  -- =========================================================
  select id into v_lang_id from public.languages where code = 'bengali';
  if v_lang_id is not null then
    delete from public.articles where language_id = v_lang_id;
    insert into public.articles
      (language_id, slug, title, title_english, level, reading_minutes,
       content_target, content_english, order_index) values
    (v_lang_id, 'bengali-namaskar-a1',
     'নমস্কার বাংলাদেশ', 'Hello Bangladesh', 'A1', 2,
     'নমস্কার! আমার নাম রিয়া। আমি বাংলাদেশের মেয়ে। আমি ঢাকায় থাকি। ঢাকা বাংলাদেশের রাজধানী এবং একটি বড় শহর। সকালে আমি চা খাই এবং পরোটা দিয়ে নাশতা করি। তারপর আমি বাসে অফিসে যাই। অফিসের পরে বন্ধুদের সঙ্গে খাবার খাই। আমার প্রিয় খাবার ভাত, মাছ এবং ডাল। শনিবার আমি বাজারে যাই এবং পরিবারের সঙ্গে সময় কাটাই। বাংলাদেশ একটি সুন্দর দেশ। এখানে অনেক নদী, মাঠ এবং সুন্দর মানুষ আছে। আপনি একদিন আমার দেশে আসুন।',
     'Hello! My name is Riya. I am a Bangladeshi girl. I live in Dhaka. Dhaka is the capital of Bangladesh and a big city. In the morning I drink tea and have breakfast with paratha. Then I go to the office by bus. After work I eat with friends. My favourite foods are rice, fish and dal. On Saturdays I go to the market and spend time with my family. Bangladesh is a beautiful country. There are many rivers, fields and kind people. Please come visit my country one day.',
     1),
    (v_lang_id, 'bengali-shahitto-b1',
     'বাংলা সাহিত্যের ঐতিহ্য', 'The tradition of Bengali literature', 'B1', 3,
     'বাংলা সাহিত্য এক হাজার বছরেরও পুরোনো একটি সমৃদ্ধ ঐতিহ্যের ধারক। মধ্যযুগে চর্যাপদ থেকে শুরু করে আধুনিক যুগে রবীন্দ্রনাথ ঠাকুর, কাজী নজরুল ইসলাম, বিভূতিভূষণ বন্দ্যোপাধ্যায় এবং তসলিমা নাসরিনের মতো লেখকেরা বাংলা ভাষাকে বিশ্ব দরবারে এক বিশেষ মর্যাদা দিয়েছেন। রবীন্দ্রনাথ ঠাকুর ১৯১৩ সালে এশিয়ার প্রথম নোবেল পুরস্কার পান। তাঁর কবিতা, গান এবং উপন্যাস বাঙালির আত্মপরিচয়কে নতুন রূপ দিয়েছে। নজরুল ইসলাম তাঁর বিদ্রোহী কবিতা দিয়ে সমাজের প্রতি প্রশ্ন তুলে ধরেছেন। শুধু কবিতা নয়, বাংলা সাহিত্যে ছোটগল্প এবং উপন্যাসেরও এক বিরাট ভাণ্ডার রয়েছে। আজকেও বাংলাদেশ ও পশ্চিমবঙ্গের তরুণ লেখকেরা নতুন কণ্ঠ যোগ করছেন। বইমেলা, পত্রিকা এবং অনলাইন সাহিত্য প্ল্যাটফর্মগুলো এই ভাষার জীবন্ত প্রবাহকে বহন করে চলেছে।',
     'Bengali literature is the bearer of a rich tradition more than a thousand years old. From the medieval Charyapada to modern figures such as Rabindranath Tagore, Kazi Nazrul Islam, Bibhutibhushan Bandyopadhyay and Taslima Nasrin, writers in Bengali have given the language a special place in the world. Rabindranath Tagore became the first Asian to receive the Nobel Prize in 1913. His poetry, songs and novels reshaped the self-image of Bengalis. Nazrul Islam, with his rebel poetry, raised piercing questions about society. It is not only poetry: Bengali literature also has a vast tradition of short stories and novels. Even today, young writers in Bangladesh and West Bengal are adding new voices. Book fairs, magazines and online literary platforms carry the living current of this language forward.',
     2),
    (v_lang_id, 'bengali-itihash-c1',
     'বাংলার ইতিহাস ও পরিচয়', 'History and identity of Bengal', 'C1', 5,
     'বাংলার ইতিহাস এক জটিল কিন্তু উজ্জ্বল ধারা, যেখানে বহু সভ্যতা ও জাতি একত্রিত হয়ে এই অঞ্চলের পরিচয় গড়ে তুলেছে। প্রাচীন কালে বঙ্গ ছিল একটি গুরুত্বপূর্ণ বাণিজ্যকেন্দ্র, যেখান থেকে নৌপথে চীন, রোমান সাম্রাজ্য এবং দক্ষিণ-পূর্ব এশিয়ার সঙ্গে যোগাযোগ ছিল। পরে পাল ও সেন রাজবংশগুলির অধীনে বৌদ্ধ ও হিন্দু সংস্কৃতি বিকশিত হয়। মধ্যযুগে মুসলিম শাসন এই অঞ্চলে একটি নতুন স্থাপত্য, সাহিত্য ও সঙ্গীতধারা নিয়ে আসে। আঠারো শতকে বাংলায় ব্রিটিশ ইস্ট ইন্ডিয়া কোম্পানির প্রবেশ ভারতবর্ষের ইতিহাসে একটি গভীর মোড় ঘোরায়। ঊনিশ শতকের বাংলার নবজাগরণ — রাজা রামমোহন রায়, বিদ্যাসাগর, রবীন্দ্রনাথ এবং বঙ্কিমচন্দ্রের নেতৃত্বে — পুরো উপমহাদেশকে চিন্তা, সাহিত্য এবং সামাজিক সংস্কারের নতুন পথ দেখায়। ১৯৪৭ এবং পরে ১৯৭১ সালে বাংলা ভাগ ও স্বাধীনতার আন্দোলন এই অঞ্চলের রাজনৈতিক মানচিত্র চিরতরে বদলে দেয়। আজ বাংলা ভাষা ভাষা-আন্দোলনের রক্ত দিয়ে জন্ম নেওয়া বাংলাদেশের জাতীয় গর্ব এবং পশ্চিমবঙ্গের সাংস্কৃতিক হৃদয়স্পন্দন। বাংলার ইতিহাস বুঝলে বোঝা যায়, কেন এই ভাষা ও এই অঞ্চল প্রতিরোধ, সৃষ্টিশীলতা এবং সহানুভূতির এক অসাধারণ মিশ্রণ।',
     'The history of Bengal is a complex but luminous current in which many civilizations and peoples have combined to shape the region''s identity. In ancient times Bengal was an important trading hub, with sea links to China, the Roman Empire and Southeast Asia. Later, under the Pala and Sena dynasties, Buddhist and Hindu cultures flourished. In the medieval period, Muslim rule brought a new architecture, literature and musical tradition to the region. In the 18th century the arrival of the British East India Company in Bengal turned the course of Indian history. The 19th-century Bengal Renaissance — led by Raja Ram Mohan Roy, Vidyasagar, Rabindranath and Bankim Chandra — showed the entire subcontinent new paths in thought, literature and social reform. The Partition of 1947 and the war of liberation in 1971 changed the political map of the region forever. Today the Bengali language, born of the blood of the Language Movement, is the national pride of Bangladesh and the cultural heartbeat of West Bengal. To understand Bengal''s history is to see why this language and this region remain an extraordinary mixture of resistance, creativity and compassion.',
     3);
  end if;

  -- =========================================================
  -- اُردُو
  -- =========================================================
  select id into v_lang_id from public.languages where code = 'urdu';
  if v_lang_id is not null then
    delete from public.articles where language_id = v_lang_id;
    insert into public.articles
      (language_id, slug, title, title_english, level, reading_minutes,
       content_target, content_english, order_index) values
    (v_lang_id, 'urdu-salam-a1',
     'السلام علیکم پاکستان', 'Greetings, Pakistan', 'A1', 2,
     'السلام علیکم! میرا نام علی ہے اور میں پاکستانی ہوں۔ میں لاہور میں رہتا ہوں۔ لاہور ایک خوبصورت اور پرانا شہر ہے۔ صبح میں چائے پیتا ہوں اور پراٹھا کھاتا ہوں۔ پھر میں بس سے دفتر جاتا ہوں۔ شام کو میں اپنے گھر والوں کے ساتھ کھانا کھاتا ہوں۔ مجھے کھانا بہت پسند ہے، خاص طور پر بریانی اور نہاری۔ ہفتے کے آخر میں میں دوستوں سے ملتا ہوں اور بازار جاتا ہوں۔ پاکستان میں مہمان نوازی بہت اہم ہے۔ آپ بھی ہمارے ملک تشریف لائیں۔',
     'Peace be upon you! My name is Ali and I am Pakistani. I live in Lahore. Lahore is a beautiful and old city. In the morning I drink tea and eat paratha. Then I go to the office by bus. In the evening I eat with my family. I love food, especially biryani and nihari. On the weekend I meet friends and go to the bazaar. Hospitality is very important in Pakistan. Please visit our country.',
     1),
    (v_lang_id, 'urdu-shairi-b1',
     'اُردو شاعری کی روایت', 'The tradition of Urdu poetry', 'B1', 3,
     'اُردو زبان کی پہچان اس کی شاعری سے بہت گہرا تعلق رکھتی ہے۔ اٹھارہویں صدی سے اب تک، اُردو شاعروں نے محبت، اللہ، انصاف اور انسانی درد کے موضوع پر شاندار اشعار لکھے ہیں۔ میر تقی میر کو اکثر اُردو غزل کا بادشاہ کہا جاتا ہے۔ غالب نے اپنے غموں کو فلسفیانہ گہرائی کے ساتھ بیان کیا اور آج بھی ان کے اشعار ہر تقریب میں سنائے جاتے ہیں۔ علامہ اقبال نے اپنی شاعری میں مسلم اُمہ کی بیداری کا پیغام دیا اور خوابوں سے قوم کو نئی منزل کی طرف اُٹھایا۔ فیض احمد فیض نے انقلاب اور انسانی حقوق کی بات کی۔ مشاعرہ ایک ایسی محفل ہے جہاں شاعر اپنے کلام پیش کرتے ہیں اور سامعین داد دیتے ہیں۔ آج کے دور میں بھی اُردو شاعری زندہ ہے۔ سوشل میڈیا، یوٹیوب اور کتابی شکل میں نئے شاعر سامنے آ رہے ہیں جو پرانے رنگ کو نئے انداز میں پیش کر رہے ہیں۔',
     'The identity of the Urdu language is deeply tied to its poetry. From the 18th century to today, Urdu poets have written magnificent verses on love, God, justice and human suffering. Mir Taqi Mir is often called the king of the Urdu ghazal. Ghalib expressed his sorrows with philosophical depth, and his couplets are still recited at every gathering. Allama Iqbal gave a message of awakening to the Muslim community through his poetry and lifted his nation from dreams toward a new destination. Faiz Ahmed Faiz spoke of revolution and human rights. The mushaira is a gathering where poets present their work and the audience offers praise. Even today Urdu poetry is alive. Through social media, YouTube and printed books, new poets are emerging who present the old colours in fresh ways.',
     2),
    (v_lang_id, 'urdu-tehzeeb-c1',
     'اُردو تہذیب اور ثقافت', 'Urdu civilization and culture', 'C1', 5,
     'اُردو تہذیب صدیوں کے تہذیبی اور لسانی اختلاط کا ثمرہ ہے، جس میں عربی، فارسی، ترکی اور مقامی ہندوستانی زبانوں کے رنگ ایک ساتھ گُندھے ہوئے ہیں۔ اس کی پیدائش دلی اور لکھنؤ کی شاہی محفلوں میں ہوئی، جہاں شاہی دربار، قہوہ خانے اور درگاہیں نہ صرف اقتدار کی بلکہ علم، شاعری اور موسیقی کی بھی مرکزیں تھیں۔ اٹھارہویں اور اُنیسویں صدی میں اُردو محض ایک زبان نہیں رہی، بلکہ زندگی گزارنے کا ایک طریقہ بن گئی۔ مہذب گفتگو، شائستہ آداب، نزاکت پسند لباس، خوش خوراکی اور شاعرانہ مزاج اس تہذیب کے بنیادی پہلو تھے۔ تقسیمِ ہند کے بعد یہ ثقافت پاکستان میں نئے سرے سے پھلتی پھولتی نظر آئی، خاص طور پر لاہور اور کراچی میں، جبکہ ہندوستان میں دلی، لکھنؤ، حیدرآباد اور مغربی بنگال کے کئی علاقوں میں اپنی جڑیں قائم رکھیں۔ آج کے دور میں اُردو تہذیب فلم، ٹی وی، ادب اور سوشل میڈیا کے ذریعے دنیا بھر تک پہنچ چکی ہے، چاہے وہ پاکستانی ڈرامے ہوں یا ہندوستانی شاعروں کے یوٹیوب چینل۔ اُردو تہذیب کی اصل خوبی اس کی شمولیت ہے: وہ کسی ایک قوم کی نہیں، بلکہ ہر اُس انسان کی ہے جو اس کی نزاکت، ادب اور سچائی سے محبت کرتا ہو۔',
     'Urdu civilization is the fruit of centuries of cultural and linguistic interweaving, in which the colours of Arabic, Persian, Turkish and indigenous Indian languages are braided together. It was born in the royal salons of Delhi and Lucknow, where the imperial court, coffee houses and Sufi shrines were centres not only of power but also of learning, poetry and music. In the 18th and 19th centuries Urdu became more than a language; it became a way of living. Civilized conversation, refined manners, elegant attire, fine taste in food, and a poetic temperament were the foundations of this culture. After the Partition of India, this civilization continued to flourish in Pakistan, especially in Lahore and Karachi, while in India it kept its roots in Delhi, Lucknow, Hyderabad and parts of West Bengal. In our own time, Urdu culture has reached the whole world through film, television, literature and social media — whether through Pakistani dramas or the YouTube channels of Indian poets. The true beauty of Urdu civilization is its inclusiveness: it does not belong to a single nation but to anyone who loves its grace, its literature and its truth.',
     3);
  end if;

  -- =========================================================
  -- BAHASA MELAYU
  -- =========================================================
  select id into v_lang_id from public.languages where code = 'malay';
  if v_lang_id is not null then
    delete from public.articles where language_id = v_lang_id;
    insert into public.articles
      (language_id, slug, title, title_english, level, reading_minutes,
       content_target, content_english, order_index) values
    (v_lang_id, 'malay-selamat-datang-a1',
     'Selamat datang ke Malaysia', 'Welcome to Malaysia', 'A1', 2,
     'Selamat datang! Nama saya Aishah dan saya orang Malaysia. Saya tinggal di Kuala Lumpur. Kuala Lumpur ialah ibu kota Malaysia dan sebuah bandar yang besar. Pada waktu pagi, saya minum teh tarik dan makan roti canai. Selepas itu, saya pergi ke pejabat dengan menggunakan LRT. Pada waktu malam, saya makan bersama keluarga. Saya suka makanan Malaysia, terutamanya nasi lemak dan laksa. Pada hujung minggu, saya pergi ke pasar dan berjumpa dengan kawan-kawan. Malaysia ialah sebuah negara yang aman dan penuh dengan pelbagai budaya. Sila datang melawat negara saya!',
     'Welcome! My name is Aishah and I am Malaysian. I live in Kuala Lumpur. Kuala Lumpur is the capital of Malaysia and a big city. In the morning I drink teh tarik and eat roti canai. Then I go to the office on the LRT. In the evening I eat with my family. I love Malaysian food, especially nasi lemak and laksa. On weekends I go to the market and meet my friends. Malaysia is a peaceful country full of many cultures. Please come and visit my country!',
     1),
    (v_lang_id, 'malay-makanan-b1',
     'Makanan Malaysia', 'Malaysian food', 'B1', 3,
     'Makanan Malaysia ialah cerminan kepada masyarakatnya yang berbilang kaum dan tradisi. Di setiap negeri terdapat hidangan istimewa yang menceritakan sejarah dan pengaruh budaya tempatan. Nasi lemak yang dianggap sebagai hidangan kebangsaan, biasanya disajikan dengan ikan bilis, kacang, telur, sambal dan timun. Roti canai pula menunjukkan pengaruh India yang kuat, manakala bakkutteh dan kuetiau menggambarkan warisan masyarakat Cina. Pelbagai jenis laksa boleh ditemui di setiap negeri: laksa Penang yang masam dan pedas, laksa Sarawak yang berasaskan rempah ratus, dan laksa Johor yang menggunakan mi spageti. Aspek penting dalam budaya makan di Malaysia ialah hubungannya dengan masyarakat. Orang Malaysia gemar makan bersama-sama di gerai, restoran terbuka dan pasar malam. Makanan menjadi medium yang mendekatkan orang Melayu, Cina, India dan kaum-kaum lain dalam satu meja dengan rasa hormat dan keramahan yang menjadi tanda pengenalan negara ini.',
     'Malaysian food reflects the country''s multi-ethnic, multi-traditional society. Each state has special dishes that tell the story of its history and local cultural influences. Nasi lemak, considered the national dish, is usually served with anchovies, peanuts, egg, sambal and cucumber. Roti canai shows a strong Indian influence, while bak kut teh and kuetiau reflect the heritage of the Chinese community. Several kinds of laksa can be found across the states: sour and spicy Penang laksa, the spice-based Sarawak laksa, and Johor laksa, which uses spaghetti noodles. An important aspect of Malaysian food culture is its link with community. Malaysians enjoy eating together at stalls, open-air restaurants and night markets. Food becomes a medium that brings Malays, Chinese, Indians and other communities to the same table with the respect and warmth that have become a hallmark of the nation.',
     2),
    (v_lang_id, 'malay-sejarah-c1',
     'Sejarah Tanah Melayu', 'History of the Malay Lands', 'C1', 5,
     'Sejarah Tanah Melayu ialah sebuah naratif yang luas dan berlapis-lapis, terbentuk daripada interaksi antara peradaban tempatan, agama besar dunia dan kuasa-kuasa luar. Sejak berkurun lamanya, kepulauan Melayu menjadi laluan perdagangan penting yang menghubungkan India, China dan Timur Tengah. Kerajaan-kerajaan awal seperti Srivijaya dan Majapahit meninggalkan kesan budaya dan politik yang mendalam di rantau ini. Kemudian, pada abad ke-15, Kesultanan Melaka muncul sebagai pusat perdagangan dan penyebaran Islam yang berpengaruh di Asia Tenggara. Kedatangan kuasa-kuasa Eropah — Portugis, Belanda dan akhirnya British — mengubah sepenuhnya struktur ekonomi dan sosial wilayah ini, terutamanya dengan pengenalan ekonomi getah dan bijih timah pada akhir abad ke-19. Pada abad ke-20, semangat nasionalisme tumbuh dengan kuat, membawa kepada kemerdekaan Persekutuan Tanah Melayu pada tahun 1957 dan pembentukan Malaysia pada tahun 1963. Sehingga kini, Tanah Melayu kekal sebagai sebuah masyarakat yang mengalami pelbagai dinamika antara warisan tradisional dan tuntutan moden, antara identiti bangsa Melayu dengan keragaman kaum yang menjadi tunggak kepada perpaduan negara. Memahami sejarah ini bererti memahami bagaimana sesebuah masyarakat boleh dibentuk daripada interaksi panjang antara tempat dan dunia, antara warisan dan perubahan.',
     'The history of the Malay lands is a vast, layered narrative shaped by interactions among local civilizations, the major world religions and outside powers. For many centuries the Malay archipelago was a crucial trade route linking India, China and the Middle East. Early kingdoms such as Srivijaya and Majapahit left deep cultural and political marks on the region. Then, in the 15th century, the Sultanate of Malacca emerged as an influential centre of trade and the spread of Islam in Southeast Asia. The arrival of European powers — the Portuguese, the Dutch and finally the British — completely altered the economic and social structure of the region, especially with the introduction of rubber and tin in the late 19th century. In the 20th century, nationalism grew strongly, leading to the independence of the Federation of Malaya in 1957 and the formation of Malaysia in 1963. Even today, the Malay lands remain a society negotiating between traditional heritage and modern demands, between Malay identity and the ethnic diversity that anchors national unity. To understand this history is to understand how a society can be shaped by long interactions between place and world, between heritage and change.',
     3);
  end if;

  -- =========================================================
  -- BAHASA INDONESIA
  -- =========================================================
  select id into v_lang_id from public.languages where code = 'indonesian';
  if v_lang_id is not null then
    delete from public.articles where language_id = v_lang_id;
    insert into public.articles
      (language_id, slug, title, title_english, level, reading_minutes,
       content_target, content_english, order_index) values
    (v_lang_id, 'indonesian-halo-a1',
     'Halo Indonesia', 'Hello Indonesia', 'A1', 2,
     'Halo! Nama saya Budi dan saya orang Indonesia. Saya tinggal di Jakarta. Jakarta adalah ibu kota Indonesia dan kota yang sangat besar. Pada pagi hari saya minum kopi dan makan nasi goreng. Setelah itu, saya pergi ke kantor naik bus. Pada malam hari saya makan bersama keluarga. Saya suka makanan Indonesia, terutama rendang dan sate. Pada akhir pekan saya bertemu teman di kafe atau jalan-jalan di pantai. Indonesia memiliki banyak pulau, pantai yang indah, dan budaya yang beragam. Datanglah ke Indonesia, Anda akan merasa sangat senang!',
     'Hello! My name is Budi and I am Indonesian. I live in Jakarta. Jakarta is the capital of Indonesia and a very big city. In the morning I drink coffee and eat nasi goreng. Then I take the bus to the office. In the evening I eat with my family. I love Indonesian food, especially rendang and satay. On weekends I meet friends at a café or walk on the beach. Indonesia has many islands, beautiful beaches and diverse cultures. Come to Indonesia, you will feel very happy!',
     1),
    (v_lang_id, 'indonesian-kuliner-b1',
     'Kuliner Indonesia', 'Indonesian cuisine', 'B1', 3,
     'Kuliner Indonesia merupakan salah satu yang paling beragam di Asia karena setiap pulau memiliki tradisi makanannya sendiri. Di Sumatera, masakan Padang seperti rendang dan gulai dikenal dengan rasa pedas dan kaya rempah. Di Jawa, nasi gudeg dari Yogyakarta dan rawon dari Surabaya menunjukkan rasa manis dan gurih yang khas. Bali memiliki babi guling dan ayam betutu, sementara Sulawesi terkenal dengan coto Makassar. Indonesia juga memiliki banyak jajanan kaki lima yang menjadi bagian penting dari kehidupan sehari-hari, seperti gorengan, bakso, soto dan martabak. Rempah-rempah Indonesia bahkan pernah menjadi penggerak utama perdagangan dunia ratusan tahun yang lalu. Makan di Indonesia bukan hanya soal mengisi perut; itu adalah cara untuk merayakan kebersamaan. Di banyak daerah, orang masih makan dengan tangan dari piring yang sama saat acara keluarga, sebuah tradisi yang mempererat hubungan antar generasi.',
     'Indonesian cuisine is one of the most diverse in Asia because each island has its own food tradition. In Sumatra, Padang cooking such as rendang and gulai is known for its spicy, richly seasoned flavours. In Java, Yogyakarta''s gudeg and Surabaya''s rawon offer distinctive sweet and savoury notes. Bali has babi guling and ayam betutu, while Sulawesi is famous for coto Makassar. Indonesia also has many street foods that are an essential part of everyday life, such as gorengan, bakso, soto and martabak. Indonesian spices were once the main driving force of world trade hundreds of years ago. Eating in Indonesia is not just about filling the stomach; it is a way of celebrating togetherness. In many regions people still eat with their hands from a shared plate at family events, a tradition that strengthens bonds between generations.',
     2),
    (v_lang_id, 'indonesian-keberagaman-c1',
     'Keberagaman Nusantara', 'The diversity of the archipelago', 'C1', 5,
     'Indonesia adalah negara kepulauan terbesar di dunia, terdiri dari lebih dari tujuh belas ribu pulau yang membentang dari Sabang sampai Merauke. Di dalam wilayah seluas itu hidup berbagai kelompok etnis dengan ratusan bahasa daerah, ratusan tradisi adat, dan beragam agama. Semboyan negara, "Bhinneka Tunggal Ika" — yang berarti berbeda-beda tetapi tetap satu — bukan hanya kalimat formal, melainkan kenyataan sehari-hari yang harus terus dinegosiasikan. Dari Aceh yang menjalankan syariat Islam, sampai Bali yang kaya dengan upacara Hindu, dari masyarakat adat Dayak di pedalaman Kalimantan, hingga komunitas peranakan Tionghoa di kota-kota besar, Indonesia menampilkan mosaik manusia yang luar biasa kompleks. Tantangan terbesar bagi Indonesia modern adalah menjaga keseimbangan antara keberagaman dan persatuan, terutama di era media sosial dan polarisasi politik. Ekonomi yang terus tumbuh, kota-kota yang berkembang pesat, dan generasi muda yang semakin global memberi tekanan baru pada nilai-nilai tradisional. Namun, sejarah menunjukkan bahwa kekuatan terbesar Indonesia justru terletak pada kemampuannya untuk menyerap pengaruh luar tanpa kehilangan jati dirinya. Mungkin di sinilah letak pelajaran yang dapat ditawarkan negeri ini kepada dunia: bahwa identitas tidak perlu seragam untuk menjadi bermakna, dan bahwa perbedaan, ketika dirawat dengan baik, dapat menjadi sumber kekuatan, bukan kelemahan.',
     'Indonesia is the largest archipelagic country in the world, made up of more than seventeen thousand islands stretching from Sabang to Merauke. Within this vast territory live many ethnic groups speaking hundreds of regional languages, with hundreds of customary traditions and many religions. The national motto, "Bhinneka Tunggal Ika" — meaning different but one — is not just a formal sentence but a daily reality that must be continuously negotiated. From Aceh, which follows Islamic law, to Bali, with its rich Hindu ceremonies; from the indigenous Dayak peoples of the Kalimantan interior to the Peranakan Chinese communities of the big cities, Indonesia presents an extraordinarily complex human mosaic. The greatest challenge for modern Indonesia is to maintain a balance between diversity and unity, especially in the age of social media and political polarization. A growing economy, rapidly expanding cities and an increasingly global youth bring new pressures on traditional values. Yet history shows that Indonesia''s greatest strength lies in its ability to absorb outside influences without losing its identity. Perhaps this is the lesson the country can offer the world: identity does not need to be uniform to be meaningful, and difference, when carefully tended, can become a source of strength rather than weakness.',
     3);
  end if;

end $$;

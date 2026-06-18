-- 052_chinese_exercises.sql
-- Seed every Chinese lesson with type-homogeneous, AI-graded exercises so
-- the course behaves identically to Spanish + French (migrations 039 / 044 /
-- 045 for Spanish, 047 for French).
--
-- Listening / speaking / writing exercises wire through the existing
-- /api/grade-lesson-response route. The route is language-agnostic — it
-- takes the language slug in the body, so no backend changes are needed.
--
-- Per lesson type, this migration inserts:
--   vocabulary lessons: 4 MC + 2 fill_blank base + 4 MC filler  (10 total)
--   grammar lessons:    4 MC + 2 fill_blank base + 4 MC filler  (10 total)
--   phrases lessons:    3 dialogue fill_blank base + 3 filler   ( 6 total)
--   listening lessons:  3 MC listening + 1 typed-response base + 2 filler
--   speaking lessons:   2 repeat-phrase + 2 topic monologue base + 2 filler
--   reading lessons:    3 comprehension MC base + 1 filler MC   ( 4 total)
--   writing lessons:    3 writing prompts base + 1 filler        ( 4 total)
--   unit_test lessons:  10 mixed MC + fill_blank
--
-- Levels A1 through C1 use level-tier templates. Per-section themes are
-- carried by lesson title + teaching content from 051; the exercise pool
-- is uniformly templated per (level, lesson_type), mirroring French 047.
--
-- Idempotent: re-running wipes and reseeds every exercise for Chinese lessons.

do $$
declare
  v_lang_id   bigint;
begin
  select id into v_lang_id from public.languages where code = 'chinese';
  if v_lang_id is null then raise exception 'Chinese language not found'; end if;

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

  ---------- LISTENING ----------
  a1_listen_mc_q text[]   := array['What did you hear?','What greeting did you hear?','What did the speaker say?'];
  a1_listen_mc_a text[]   := array['你好,你叫什么名字?','我叫小明,我二十岁。','今天天气很好。'];
  a1_listen_mc_w text[][] := array[
    array['你好,你住在哪里?','晚上好,你叫什么名字?','再见,你叫什么名字?'],
    array['你叫小明,你二十岁。','我叫小红,我二十岁。','我叫小明,我三十岁。'],
    array['今天天气很冷。','今天下雨了。','明天天气会很好。']
  ];
  a1_listen_typed_q text := '用几句话告诉我你的日常生活。';
  a1_listen_typed_a text := '我七点起床,吃早饭,然后去上班。';

  a2_listen_mc_q text[]   := array['What did you hear?','What did the speaker ask?','What did the speaker say?'];
  a2_listen_mc_a text[]   := array['昨天我和朋友去看电影了。','你上周末做了什么?','我家住在有花园的大房子里。'];
  a2_listen_mc_w text[][] := array[
    array['明天我要和朋友去看电影。','昨天我在家看了一部电影。','昨天我和家人去看戏剧了。'],
    array['你下周末要做什么?','你上周末去了哪里?','你和谁度过周末?'],
    array['我家住在没有花园的小公寓。','我朋友住在有花园的大房子里。','我家以前住在乡下的房子里。']
  ];
  a2_listen_typed_q text := '告诉我你昨天做了什么,以及一天结束时的感受。';
  a2_listen_typed_a text := '昨天我工作了一整天,然后去跑步。一天结束时我很累但很满足。';

  b1_listen_mc_q text[]   := array['What did you hear?','What opinion did the speaker express?','What was the speaker''s main point?'];
  b1_listen_mc_a text[]   := array['然而,我更喜欢住在乡下而不是城市。','在我看来,社交网络深刻地改变了我们的生活。','如果我有更多时间,我会游历整个南美洲。'];
  b1_listen_mc_w text[][] := array[
    array['然而,我更喜欢住在城市而不是乡下。','因为我喜欢城市,所以我住在乡下。','虽然我喜欢城市,我并不住在城市。'],
    array['在我看来,社交网络什么也没改变。','我觉得社交网络很快会改变我们。','社交网络几乎不影响我们的日常。'],
    array['如果我有更多时间,我去南美旅行。','当我有更多时间时,我去过南美。','虽然我有更多时间,我也不会旅行。']
  ];
  b1_listen_typed_q text := '虽然我很喜欢旅行,但今年我决定留在家里存钱。你怎么看?';
  b1_listen_typed_a text := '我觉得这很合理;现在存钱以后会有更多自由。如果是我,我也会这样做。';

  b2_listen_mc_q text[]   := array['What did you hear?','What attitude does the speaker show?','What argument did the speaker make?'];
  b2_listen_mc_a text[]   := array['不过,尽管有所进步,严重的社会不平等依然存在。','应当强调,公共教育仍然是健全民主的基础。','如果我们早点行动,本可以避免大部分的环境危机。'];
  b2_listen_mc_w text[][] := array[
    array['由于进步,不平等已经消失。','进步只惠及少数特权阶层。','没有进步,就不会有不平等。'],
    array['私立教育是民主的基础。','教育对民主几乎没有影响。','只有大学教育对民主重要。'],
    array['如果我们现在行动,就能避免危机。','虽然我们行动了,危机仍不可避免。','如果我们早点行动,就能避免下次危机。']
  ];
  b2_listen_typed_q text := '一些专家认为在线教学将长期存在;另一些人认为它只是过渡。你的立场是什么?';
  b2_listen_typed_a text := '我认为在线教学会长期存在,不过需要深度改革。应当强调,面对面教学对学习的社交维度仍然不可或缺。';

  c1_listen_mc_q text[]   := array['What did you hear?','What rhetorical move did the speaker make?','What implicit claim does this contain?'];
  c1_listen_mc_a text[]   := array['应当指出,虚假信息远非边缘现象,而是已成为结构性问题。','同样,再严格的法律也无法替代公民的判断力。','若当时通过这项改革,教育体系将发生深刻变化。'];
  c1_listen_mc_w text[][] := array[
    array['应当否认虚假信息是边缘现象。','虚假信息仍然是无关紧要的边缘现象。','应当指出虚假信息只是暂时的。'],
    array['任何严格的法律都能替代公民判断力。','公民的判断力永远不应该替代法律。','只要公民有判断力,就不需要任何法律。'],
    array['若当时被否决,体系会有所改善。','若当时通过,改革也不会带来任何改变。','若现在通过,改革将重塑体系。']
  ];
  c1_listen_typed_q text := '一位学者指出,学术自由的真正衡量标准是国家允许公开发表关于自身的什么,而非它声称容忍什么。你如何理解这一区分?';
  c1_listen_typed_a text := '她暗示,若实际自由受到限制,所宣称的自由几乎无意义。不过,她的对照将学术自由仅简化为政府层面的标准,忽略了其他同样限制学术自由的体制因素。';

  ---------- SPEAKING ----------
  a1_speak_repeat_phrases text[] := array['你好,我叫小红,我是中国人。','我今年二十岁,我和家人一起住在北京。'];
  a1_speak_topics         text[] := array['Greet someone and introduce yourself. Speak two short Chinese sentences.','Talk about your daily routine in two short Chinese sentences.'];

  a2_speak_repeat_phrases text[] := array['昨天我去超市买了面包和牛奶。','我家是大家庭,我们住在有花园的房子里。'];
  a2_speak_topics         text[] := array['Describe what you did last weekend. Three Chinese sentences using past markers (了 / 过).','Talk about your typical morning routine. Three Chinese sentences.'];

  b1_speak_repeat_phrases text[] := array['虽然我很喜欢旅行,但今年我宁愿留下来,为未来存钱。','如果我有更多空闲时间,我就学钢琴,也会多锻炼身体。'];
  b1_speak_topics         text[] := array['Talk about a goal you want to achieve in the next year. Four Chinese sentences expressing your opinion.','Describe a place you would like to visit and why. Four Chinese sentences using 如果 / 会 / 想.'];

  b2_speak_repeat_phrases text[] := array['不过,尽管取得了进步,不平等依然存在;应当强调,教育是解决这些问题的关键。','如果我们早点行动,本可以避免大部分危机;因此,我们必须从现在开始进行长期规划。'];
  b2_speak_topics         text[] := array['Argue for or against a social policy you care about. Five Chinese sentences using 不过 / 然而 and at least one connector.','Discuss a current global issue and propose a solution. Five sentences using 因此 / 应当强调.'];

  c1_speak_repeat_phrases text[] := array['应当指出,虚假信息远非个别现象,而已成为公共讨论的结构性特征。','若当时通过这项改革,教育体系将发生深刻变化,亦将预见到我们至今仍回避的诸多争论。'];
  c1_speak_topics         text[] := array['Critically analyse a current geopolitical issue and its long-term implications. Six to eight Chinese sentences with advanced connectors and formal register.','Discuss whether artificial intelligence will reshape the humanities, defending a clear stance. Six to eight sentences with rhetorical sophistication.'];

  ---------- WRITING ----------
  a1_writing_prompts text[] := array[
    'Write 2 short Chinese sentences introducing yourself.',
    'Write 2 short Chinese sentences about your family.',
    'Write 2 short Chinese sentences about what you do every morning.'
  ];
  a2_writing_prompts text[] := array[
    'Write 3 Chinese sentences about what you did last weekend, using past markers (了/过).',
    'Write 3 Chinese sentences comparing your weekday and weekend routines.',
    'Write a 3-sentence message inviting a friend to dinner this Saturday.'
  ];
  b1_writing_prompts text[] := array[
    'Write 4 Chinese sentences giving your opinion on remote work. Include at least one connector (然而 / 因为 / 不过).',
    'Write 4 Chinese sentences about a goal you have for the next year, using future markers (要 / 会).',
    'Write 4 Chinese sentences comparing two cities or countries you know, using 比.'
  ];
  b2_writing_prompts text[] := array[
    'Write 5 Chinese sentences debating a current social issue. Use at least one connector (不过 / 因此 / 应当强调).',
    'Write 5 Chinese sentences arguing for or against a proposed policy. Acknowledge a counterargument.',
    'Write 5 Chinese sentences analysing the long-term effects of a recent change in your country. Use sophisticated vocabulary.'
  ];
  c1_writing_prompts text[] := array[
    'Write 7-8 Chinese sentences critically analysing a current global issue. Use formal register and at least two advanced connectors (综上所述 / 与此同时 / 由此可见).',
    'Write 7-8 Chinese sentences in formal register on the ethics of a contemporary technology. Use 应当 and 不容忽视.',
    'Write 7-8 Chinese sentences arguing what would have happened had a major historical event unfolded differently. Use 若 / 倘若 / 不然.'
  ];

  ---------- READING ----------
  a1_reading_q text[]   := array['苏菲今年几岁?','苏菲怎么去上班?','周末她做什么?'];
  a1_reading_a text[]   := array['二十五岁','坐公共汽车','回家看父母'];
  a1_reading_w text[][] := array[
    array['十五岁','三十岁','五十岁'],
    array['开车','走路','坐火车'],
    array['出国旅行','上班','学习']
  ];

  a2_reading_q text[]   := array['作者为什么换工作?','新公司是什么样的?','他现在感觉怎么样?'];
  a2_reading_a text[]   := array['因为觉得无聊','是一家可以出差的国际公司','开心,因为学到了很多'];
  a2_reading_w text[][] := array[
    array['因为工资低','因为搬家了','因为吵架了'],
    array['很小,只做本地业务','非常严格无聊','像家一样,只有几个人'],
    array['压力大、心情不好','无所谓','失望']
  ];

  b1_reading_q text[]   := array['为什么许多年轻人出国?','专家担心什么?','一些政府的回应是什么?'];
  b1_reading_a text[]   := array['他们寻求更高的工资和新的文化','人才流失难以弥补','提供奖励吸引他们回国'];
  b1_reading_w text[][] := array[
    array['因为他们找不到工作','因为他们不想和家人住一起','因为大学要求他们出国'],
    array['年轻人之间的竞争','对外语缺乏兴趣','大学过载'],
    array['提高移民税','禁止离境','什么也不做']
  ];

  b2_reading_q text[]   := array['一些艺术家如何看待生成式人工智能?','为什么这场争论不只关乎经济?','作者对争论的走向有何预测?'];
  b2_reading_a text[]   := array['当作另一种工具,如同当年的电脑','因为它挑战了"作者"和"原创性"的概念','它将持续很长时间'];
  b2_reading_w text[][] := array[
    array['当作艺术家的彻底替代品','当作毫无意义的流行','当作应被禁止的敌对工具'],
    array['因为只涉及大型博物馆','因为价格上涨','因为技术是中性的'],
    array['它会迅速结束','它将很快失去关注','它会在短期内出台监管']
  ];

  c1_reading_q text[]   := array['根据支持者,该模式提供了哪些优势?','部分反对者提出了什么意想不到的论点?','作者认为如今这场争论的性质是什么?'];
  c1_reading_a text[]   := array['减少排放、改善健康、增加社群联系','他们将其视为对自由的隐形限制','文化与象征之争,不仅是技术问题'];
  c1_reading_w text[][] := array[
    array['经济增长和更多私人车辆','市中心更多办公楼、更少公园','更多摩天大楼、更少本地商店'],
    array['他们无保留地支持','他们认为它技术上过于昂贵','只有市政技术人员批评它'],
    array['完全是技术性的','完全是经济性的','在学术界已基本结束']
  ];

  ---------- VOCABULARY fillers per level ----------
  a1_vocab_mc_q text[]   := array['What does "你好" mean?','What does "谢谢" mean?','Which Chinese word means "house"?','Which Chinese word means "friend"?'];
  a1_vocab_mc_a text[]   := array['hello','thank you','房子','朋友'];
  a1_vocab_mc_w text[][] := array[
    array['goodbye','please','sorry'],
    array['hello','please','sorry'],
    array['车','书','椅子'],
    array['哥哥','爸爸','爷爷']
  ];
  a1_vocab_fb_q text[]   := array['Complete: "早上我喝一杯____" (coffee)','Complete: "我有两个____" (older brothers)'];
  a1_vocab_fb_a text[]   := array['咖啡','哥哥'];

  a2_vocab_mc_q text[]   := array['What does "午饭" mean?','What does "旅行" mean?','Which Chinese word means "boss"?','Which Chinese word means "weekend"?'];
  a2_vocab_mc_a text[]   := array['lunch','to travel','老板','周末'];
  a2_vocab_mc_w text[][] := array[
    array['breakfast','dinner','snack'],
    array['to swim','to study','to write'],
    array['员工','邻居','客户'],
    array['假日','假期','一周']
  ];
  a2_vocab_fb_q text[]   := array['Complete: "我哥哥在学校____英语。" (teaches)','Complete: "我去超市买____和牛奶。" (bread)'];
  a2_vocab_fb_a text[]   := array['教','面包'];

  b1_vocab_mc_q text[]   := array['What does "然而" mean?','What does "存钱" mean?','Which Chinese word means "to plan"?','Which Chinese word means "reliable"?'];
  b1_vocab_mc_a text[]   := array['however','to save money','计划','可靠'];
  b1_vocab_mc_w text[][] := array[
    array['therefore','also','because'],
    array['to spend','to lend','to lose'],
    array['计算','计较','计件'],
    array['可爱','可怕','可能']
  ];
  b1_vocab_fb_q text[]   := array['Complete: "要想成功,必须经常____。" (study)','Complete: "我的老板给我____了加薪。" (granted)'];
  b1_vocab_fb_a text[]   := array['学习','批准'];

  b2_vocab_mc_q text[]   := array['What does "不过" mean?','What does "强调" mean?','Which Chinese word means "to undertake"?','Which Chinese word means "regulation"?'];
  b2_vocab_mc_a text[]   := array['however','to emphasise','承担','法规'];
  b2_vocab_mc_w text[][] := array[
    array['continuously','convincingly','therefore'],
    array['to ignore','to apologise','to forget'],
    array['丰富','参与','管理'],
    array['规则','规定','规范']
  ];
  b2_vocab_fb_q text[]   := array['Complete: "应当____后果的严重性。" (emphasise)','Complete: "尽管反对派____,政府仍通过了法案。" (opposed)'];
  b2_vocab_fb_a text[]   := array['强调','反对'];

  c1_vocab_mc_q text[]   := array['What does "尽管" mean?','What does "佐证" mean?','Which Chinese phrase means "in light of"?','Which Chinese phrase means "as a result of"?'];
  c1_vocab_mc_a text[]   := array['notwithstanding','to substantiate','鉴于','由于'];
  c1_vocab_mc_w text[][] := array[
    array['nonetheless (only)','despite (only)','because of'],
    array['to soak','to settle','to summon'],
    array['因为','因此','应当强调'],
    array['鉴于','幸亏','尽管']
  ];
  c1_vocab_fb_q text[]   := array['Complete: "他的演讲非常____,消除了所有疑虑。" (compelling)','Complete: "应当严谨地____每一个论点。" (substantiate)'];
  c1_vocab_fb_a text[]   := array['有力','佐证'];

  ---------- GRAMMAR fillers per level ----------
  a1_grammar_mc_q text[] := array[
    'Pick the correct verb: "我____中文。" (speak)',
    'Pick the correct measure word: "一____书" (book)',
    'Pick the correct pronoun: "____住在北京。" (I)',
    'Pick the correct word for the question: "你叫____名字?"'
  ];
  a1_grammar_mc_a text[] := array['说','本','我','什么'];
  a1_grammar_mc_w text[][] := array[
    array['吃','看','喝'],
    array['个','张','只'],
    array['你','他','她'],
    array['谁','哪','怎么']
  ];
  a1_grammar_fb_q text[] := array['Complete: "她____学生。" (is)','Complete: "我们____北京。" (live in)'];
  a1_grammar_fb_a text[] := array['是','住在'];

  a2_grammar_mc_q text[] := array[
    'Pick the past marker: "昨天我吃____饭。" (le)',
    'Pick the experiential marker: "我去____北京。" (guo — have been)',
    'Pick the future marker: "我____去看电影。" (will / going to)',
    'Pick the right form: "她比我____。" (taller)'
  ];
  a2_grammar_mc_a text[] := array['了','过','要','高'];
  a2_grammar_mc_w text[][] := array[
    array['过','着','的'],
    array['了','着','的'],
    array['了','着','过'],
    array['很高','高了','的高']
  ];
  a2_grammar_fb_q text[] := array['Complete: "去年我在国际公司____工作。" (worked — le)','Complete: "我从来没____过日本。" (been to)'];
  a2_grammar_fb_a text[] := array['工作了','去'];

  b1_grammar_mc_q text[] := array[
    'Pick the right connector: "____下雨,我也去。" (even if)',
    'Pick the right conjunction: "我喜欢咖啡,____喝得很少。" (however)',
    'Pick the right structure: "我____书看完了。" (ba structure)',
    'Pick the right complement: "我听____她的话。" (heard / perceive)'
  ];
  b1_grammar_mc_a text[] := array['即使','然而','把','见'];
  b1_grammar_mc_w text[][] := array[
    array['因为','所以','虽然'],
    array['因为','所以','虽然'],
    array['被','在','给'],
    array['完','到','着']
  ];
  b1_grammar_fb_q text[] := array['Complete: "如果我____更多时间,我会去旅行。" (had)','Complete: "我建议你早一点____。" (arrive — infinitive)'];
  b1_grammar_fb_a text[] := array['有','到'];

  b2_grammar_mc_q text[] := array[
    'Pick the passive: "这本书____我读完了。" (was — by)',
    'Pick the right form: "无论____困难,我都坚持。" (how)',
    'Pick the right form: "不仅____,而且很贵。" (slow)',
    'Pick the right form: "要不是你____,我早就放弃了。" (had helped)'
  ];
  b2_grammar_mc_a text[] := array['被','多','慢','帮'];
  b2_grammar_mc_w text[][] := array[
    array['把','给','在'],
    array['什么','谁','哪'],
    array['快','好','差'],
    array['会','要','在']
  ];
  b2_grammar_fb_q text[] := array['Complete: "____你做什么,他都不会改变主意。" (no matter)','Complete: "即使下雨,我____会去。" (also / still)'];
  b2_grammar_fb_a text[] := array['无论','也'];

  c1_grammar_mc_q text[] := array[
    'Pick the formal form: "民____心" (of — classical)',
    'Pick the rhetorical word: "____他没看到吗?" (do you really mean)',
    'Pick the formal connector: "____上所述,我们应当谨慎。" (in conclusion)',
    'Pick the formal word: "此事不容____。" (be overlooked)'
  ];
  c1_grammar_mc_a text[] := array['之','难道','综','忽视'];
  c1_grammar_mc_w text[][] := array[
    array['的','所','以'],
    array['到底','简直','根本'],
    array['不','也','则'],
    array['注意','回避','在意']
  ];
  c1_grammar_fb_q text[] := array['Complete: "由此可____,问题的严重性不言而喻。" (see)','Complete: "____非偶然,而是必然。" (not — formal)'];
  c1_grammar_fb_a text[] := array['见','并'];

  ---------- PHRASES fillers per level ----------
  a1_phrases_q text[] := array[
    'Complete the dialogue: "A: 你好。B: ____,你好吗?"',
    'Complete the dialogue: "A: 你叫什么名字? B: 我____小明。"',
    'Complete the dialogue: "A: 谢谢。B: ____。"'
  ];
  a1_phrases_a text[] := array['你好','叫','不客气'];

  a2_phrases_q text[] := array[
    'Complete the dialogue: "医生:你哪里不舒服? 病人:我____疼。" (head)',
    'Complete the dialogue: "服务员:还要别的吗? 客人:不用了,____。" (thanks)',
    'Complete the dialogue: "A: 对不起。B: 没____,别担心。" (problem)'
  ];
  a2_phrases_a text[] := array['头','谢谢','关系'];

  b1_phrases_q text[] := array[
    'Complete the dialogue: "前台:住几个晚上? 客人:____晚,谢谢。" (three)',
    'Complete the dialogue: "A: 可惜你不能来。B: ____,下次吧。" (no worries)',
    'Complete the dialogue: "A: 考试怎么样? B: 我____考得不错。" (think)'
  ];
  b1_phrases_a text[] := array['三','没关系','觉得'];

  b2_phrases_q text[] := array[
    'Complete: "客户:我家断网好几天了。客服:请您____,我们马上处理。" (forgive me — formal)',
    'Complete: "经理:我要表扬你。员工:____您,经理。" (thank you — formal)',
    'Complete the formal dialogue: "敬请您____出席。" (kindly attend)'
  ];
  b2_phrases_a text[] := array['谅解','感谢','拨冗'];

  c1_phrases_q text[] := array[
    'Complete the formal dialogue: "敬请尽快____您的出席。" (confirm)',
    'Complete: "____指出,每个论点都应慎重斟酌。" (it is appropriate to)',
    'Complete: "请允许我____。虽然事实如此,我们仍不应放弃。" (object — formal)'
  ];
  c1_phrases_a text[] := array['确认','应当','提出异议'];

  ---------- UNIT TEST templates per level (10 mixed exercises) ----------
  a1_unit_q text[] := array[
    'How do you say "hello" in Chinese?',
    'What is the Chinese word for "house"?',
    'Complete: "我____中文。" (speak)',
    'Pick the correct measure word: "一____苹果"',
    'Complete: "我爸爸和我____妈。" (my, in spoken form)',
    'How do you say "thank you"?',
    'What does "早上" mean?',
    'Complete: "今天很____" (cold)',
    'Pick the correct verb: "我们____在北京。" (live)',
    'What does "星期五" mean?'
  ];
  a1_unit_a text[] := array['你好','房子','说','个','妈','谢谢','morning','冷','住','Friday'];
  a1_unit_w text[][] := array[
    array['再见','晚安','谢谢'],
    array['车','书','狗'],
    array['吃','看','喝'],
    array['张','本','只'],
    array['爸','哥','姐'],
    array['你好','对不起','不客气'],
    array['evening','night','noon'],
    array['热','好','坏'],
    array['住了','住过','住的'],
    array['Monday','Tuesday','Wednesday']
  ];

  a2_unit_q text[] := array[
    'How do you say "yesterday" in Chinese?',
    'Complete the past: "昨天我去看电影____。" (le)',
    'Complete: "我小时候经常____足球。" (play — past)',
    'Pick the right modal: "明天我____去北京。" (will / going to)',
    'What does "午饭" mean?',
    'Complete: "早上七点我____起床。" (get up)',
    'How do you say "weekend"?',
    'Pick the right form: "我们去过北京____" (le or guo?)',
    'What does "经常" mean?',
    'Complete: "如果你想,我们一起____。" (go)'
  ];
  a2_unit_a text[] := array['昨天','了','踢','要','lunch','起','周末','过','often','去'];
  a2_unit_w text[][] := array[
    array['明天','今天','现在'],
    array['过','着','的'],
    array['踢着','要踢','会踢'],
    array['了','过','着'],
    array['breakfast','dinner','snack'],
    array['睡','吃','看'],
    array['vacation','holiday','week'],
    array['了','着','在'],
    array['always','rarely','never'],
    array['吃','看','走']
  ];

  b1_unit_q text[] := array[
    'How do you say "however" in Chinese?',
    'Complete: "如果我有时间,我____读书。" (would — common form)',
    'Pick the connector: "____下雨,我也会去。" (even if)',
    'What does "存钱" mean?',
    'Pick the right structure: "我____书看完了。" (ba structure)',
    'Complete: "等我____完工作,就来。" (have — finish)',
    'What does "可靠" mean?',
    'Pick the comparative: "她____我高。" (than)',
    'What does "从此以后" mean?',
    'Complete: "虽然他____,但他不放弃。" (tired)'
  ];
  b1_unit_a text[] := array['然而','会','即使','to save money','把','做','reliable','比','from now on','累'];
  b1_unit_w text[][] := array[
    array['所以','也','因为'],
    array['有','是','在'],
    array['因为','所以','但是'],
    array['to lend','to spend','to borrow'],
    array['被','给','在'],
    array['做了','正做','做着'],
    array['fragile','flexible','frequent'],
    array['和','跟','给'],
    array['for now','before','at last'],
    array['饿','渴','热']
  ];

  b2_unit_q text[] := array[
    'How do you say "consequently" in Chinese?',
    'Complete: "尽管有进步,不平等仍然____。" (persists)',
    'Pick the right form: "如果我们早点行动,本可以____危机。" (avoided)',
    'What does "强调" mean?',
    'Pick the right structure: "这本书____我读完了。" (passive — by)',
    'Complete: "____,我们应当强调取得的成果。" (however)',
    'What does "议题" mean?',
    'Pick the right form: "无论____,他都不会改变。" (what)',
    'What does "可持续" mean?',
    'Pick the connector: "他不仅聪明,____很勤奋。" (also)'
  ];
  b2_unit_a text[] := array['因此','存在','避免','to emphasise','被','不过','issue','什么','sustainable','而且'];
  b2_unit_w text[][] := array[
    array['然而','不过','虽然'],
    array['消失','增加','减少'],
    array['得到','避免了','失去'],
    array['to ignore','to apologise','to forget'],
    array['把','给','在'],
    array['因此','所以','但是'],
    array['agreement','consequence','example'],
    array['谁','哪','怎么'],
    array['fragile','immediate','expensive'],
    array['也','或','即']
  ];

  c1_unit_q text[] := array[
    'How do you say "notwithstanding" in Chinese?',
    'Complete: "____指出这一问题的重要性。" (it is appropriate to)',
    'Pick the right form: "若当时通过,这项改革____带来深刻变化。" (would have)',
    'What does "佐证" mean?',
    'Pick the formal word: "民____心,不可违逆。" (of — classical)',
    'Complete: "由此可____,问题不容回避。" (see)',
    'What does "主导" mean?',
    'Pick the rhetorical question: "____他不知道吗?" (do you really mean)',
    'What does "领会" mean?',
    'Pick the formal connector: "____上所述,我们必须谨慎。" (in conclusion)'
  ];
  c1_unit_a text[] := array['尽管','应当','将','to substantiate','之','见','predominant','难道','to grasp','综'];
  c1_unit_w text[][] := array[
    array['然而','不过','虽然'],
    array['可以','必须','或许'],
    array['会','要','在'],
    array['to settle','to summon','to soothe'],
    array['的','所','以'],
    array['到','着','了'],
    array['superficial','marginal','minor'],
    array['到底','简直','根本'],
    array['to applaud','to alarm','to allege'],
    array['不','也','则']
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
  select id into v_lang_id from public.languages where code = 'chinese';

  for v_level in select unnest(array['A1','A2','B1','B2','C1']) loop
    case v_level
      when 'A1' then
        cur_listen_mc_q := a1_listen_mc_q; cur_listen_mc_a := a1_listen_mc_a; cur_listen_mc_w := a1_listen_mc_w;
        cur_listen_typed_q := a1_listen_typed_q; cur_listen_typed_a := a1_listen_typed_a;
        cur_speak_repeat := a1_speak_repeat_phrases; cur_speak_topics := a1_speak_topics;
        cur_writing := a1_writing_prompts;
        cur_reading_p := '我叫苏菲。我今年二十五岁,住在北京。早上我坐公共汽车去上班。晚上我学英语。周末我回老家看爸爸妈妈。';
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
        cur_reading_p := '去年我换了工作。以前我在一家小公司上班,觉得很无聊。后来我找到了一家国际公司的工作,可以经常出差。刚开始很难,但是现在我很开心,因为我学到了很多东西。';
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
        cur_reading_p := '越来越多的年轻人毕业后选择去国外学习或者工作。原因有很多:有的人希望得到更高的工资,有的人想学习一门外语或者了解新的文化。然而,这种趋势也让一些专家担心,他们认为国家可能会失去重要的人才,很难弥补。因此,不少政府开始提供奖励,希望这些年轻人将来能回国工作。';
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
        cur_reading_p := '生成式人工智能正在以前所未有的速度改变创作领域。有些人认为这只是一种新工具,就像当年的电脑一样;另一些人则担心它会削弱人类劳动的价值。这场讨论不仅是经济层面的:当机器能够创作出符合质量标准的作品时,它也在挑战我们对"作者"和"原创性"的传统理解。可以预见,这场争论还将持续很长时间。';
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
        cur_reading_p := '"十五分钟城市"模式的讨论在城市规划领域已存在数十年,然而真正进入政治议程却是近几年的事。其支持者认为,把学校、工作、商店和娱乐设施都安排在步行十五分钟范围内,既能减少碳排放、改善公共健康,也能恢复因汽车主导的城市生活所失去的社群联系。然而,反对者从意想不到的角度发起了攻击:有人将该模式视为对个人出行自由的隐形限制,甚至将其与某些阴谋论联系起来。由此可见,这场争论早已超越技术层面,成为一场深层的文化与象征之争。';
        cur_reading_q := c1_reading_q; cur_reading_a := c1_reading_a; cur_reading_w := c1_reading_w;
        cur_vocab_mc_q := c1_vocab_mc_q; cur_vocab_mc_a := c1_vocab_mc_a; cur_vocab_mc_w := c1_vocab_mc_w;
        cur_vocab_fb_q := c1_vocab_fb_q; cur_vocab_fb_a := c1_vocab_fb_a;
        cur_grammar_mc_q := c1_grammar_mc_q; cur_grammar_mc_a := c1_grammar_mc_a; cur_grammar_mc_w := c1_grammar_mc_w;
        cur_grammar_fb_q := c1_grammar_fb_q; cur_grammar_fb_a := c1_grammar_fb_a;
        cur_phrases_q := c1_phrases_q; cur_phrases_a := c1_phrases_a;
        cur_unit_q := c1_unit_q; cur_unit_a := c1_unit_a; cur_unit_w := c1_unit_w;
    end case;

    -- LISTENING (lesson 4) — 3 MC + 1 typed + 2 fillers
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

    -- SPEAKING (lesson 5) — 2 repeat + 2 topic + 2 fillers
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
      insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
      values (v_lesson_id, 'speaking',
        'Say this aloud: "' || cur_speak_repeat[1] || '"',
        cur_speak_repeat[1], array[]::text[], 200);
      insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
      values (v_lesson_id, 'speaking', cur_speak_topics[1], '', array[]::text[], 201);
    end loop;

    -- WRITING (lesson 7) — 3 prompts + 1 filler
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

    -- READING (lesson 6) — passage + 3 comprehension MC + 1 filler
    for v_lesson_id in
      select l.id from public.lessons l
      join public.courses c on c.id = l.course_id
      where c.language_id = v_lang_id and c.cefr_level = v_level
        and l.type = 'reading'
    loop
      for i in 1..array_length(cur_reading_q, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (v_lesson_id, 'multiple_choice',
          E'请阅读下文并回答问题:\n\n' || cur_reading_p || E'\n\n问题:' || cur_reading_q[i],
          cur_reading_a[i],
          array[cur_reading_w[i][1], cur_reading_w[i][2], cur_reading_w[i][3]]::text[],
          i);
      end loop;
      insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
      values (v_lesson_id, 'multiple_choice',
        E'请阅读下文并回答问题:\n\n' || cur_reading_p || E'\n\n问题:' || cur_reading_q[1],
        cur_reading_a[1],
        array[cur_reading_w[1][1], cur_reading_w[1][2], cur_reading_w[1][3]]::text[],
        200);
    end loop;

    -- VOCABULARY (lesson 1) — 4 MC + 2 fill_blank + 4 fillers
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
      for i in 1..array_length(cur_vocab_mc_q, 1) loop
        insert into public.exercises (lesson_id, type, question, correct_answer, wrong_answers, order_index)
        values (v_lesson_id, 'multiple_choice', cur_vocab_mc_q[i], cur_vocab_mc_a[i],
          array[cur_vocab_mc_w[i][1], cur_vocab_mc_w[i][2], cur_vocab_mc_w[i][3]]::text[],
          200 + i);
      end loop;
    end loop;

    -- GRAMMAR (lesson 2) — 4 MC + 2 fill_blank + 4 fillers
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

    -- PHRASES (lesson 3) — 3 dialogue fill_blank + 3 fillers
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

    -- UNIT TEST (lesson 9) — 10 mixed MC + fill_blank
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

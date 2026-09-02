import { createClient } from "@/lib/supabase/server";

// Traveler's Course data helpers. Keeps all traveler-DB queries in one
// place so the pages stay presentational.

export interface TravelerCourseSummary {
  id: number;
  city: string;
  country: string;
  slug: string; // url-safe
  description: string | null;
  coverImageUrl: string; // never null — we always fall back to a curated Unsplash URL
  orderIndex: number;
  lessonsTotal: number;
  lessonsCompleted: number;
  freePreviewCount: number; // how many of these lessons are free (is_premium=false)
  coords: [number, number]; // [lng, lat]
}

export interface TravelerLessonSummary {
  id: number;
  title: string;
  locationName: string;
  lessonType: "sign" | "conversation" | "cultural" | "mixed";
  orderIndex: number;
  xpReward: number;
  isPremium: boolean;
  completed: boolean;
}

// Coordinates + curated Unsplash cover for every city we ship. Keyed by
// the lowercase city name (matches what's in the DB). Adding a new city
// = one row here + one row in traveler_courses.
const CITY_META: Record<
  string,
  { coords: [number, number]; cover: string; countryCode: string }
> = {
  Madrid:         { coords: [-3.7038, 40.4168], cover: "https://images.unsplash.com/photo-1543783207-ec64e4d95325?w=1600&h=900&fit=crop&q=80", countryCode: "ES" },
  Barcelona:      { coords: [ 2.1734, 41.3851], cover: "https://images.unsplash.com/photo-1583422409516-2895a77efded?w=1600&h=900&fit=crop&q=80", countryCode: "ES" },
  "Mexico City":  { coords: [-99.1332, 19.4326], cover: "https://images.unsplash.com/photo-1518659526054-190340b32735?w=1600&h=900&fit=crop&q=80", countryCode: "MX" },
  "Buenos Aires": { coords: [-58.3816, -34.6037], cover: "https://images.unsplash.com/photo-1589909202802-8f4aadce1849?w=1600&h=900&fit=crop&q=80", countryCode: "AR" },
  Paris:          { coords: [ 2.3522, 48.8566], cover: "https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=1600&h=900&fit=crop&q=80", countryCode: "FR" },
  Lyon:           { coords: [ 4.8357, 45.7640], cover: "https://images.unsplash.com/photo-1524484485831-a92ffc0de03f?w=800", countryCode: "FR" },
  Montreal:       { coords: [-73.5673, 45.5017], cover: "https://images.unsplash.com/photo-1519178614-68673b201f36?w=1600&h=900&fit=crop&q=80", countryCode: "CA" },
};

// ISO 3166-1 alpha-2 codes of countries where each course language is
// spoken widely enough to justify highlighting on the map.
export const LANGUAGE_COUNTRY_CODES: Record<string, string[]> = {
  spanish: [
    "ES","MX","AR","CO","PE","VE","CL","EC","GT","CU","BO","DO","HN","PY","SV","NI","CR","PR","UY","GQ","PA",
  ],
  french: [
    "FR","CA","BE","CH","LU","MC","SN","CI","ML","BF","NE","GA","CG","CD","BJ","TG","MG","CM","HT","DJ","GN","VU",
  ],
};

export function cityToSlug(city: string): string {
  return city.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
}

function coverFor(city: string): string {
  return CITY_META[city]?.cover ?? "";
}

function coordsFor(city: string): [number, number] {
  return CITY_META[city]?.coords ?? [0, 0];
}

// Returns the traveler courses for the given language slug ("spanish" |
// "french"), each row enriched with lesson counts and (if the user is
// signed in) their completion count.
export async function getTravelerCoursesForLanguage(
  languageSlug: string,
): Promise<TravelerCourseSummary[]> {
  const supabase = await createClient();

  const { data: lang } = await supabase
    .from("languages")
    .select("id")
    .eq("code", languageSlug)
    .maybeSingle();
  if (!lang) return [];

  const { data: courses } = await supabase
    .from("traveler_courses")
    .select("id, city, country, description, cover_image_url, order_index")
    .eq("language_id", lang.id)
    .order("order_index");

  const courseRows = (courses ?? []) as Array<{
    id: number;
    city: string;
    country: string;
    description: string | null;
    cover_image_url: string | null;
    order_index: number;
  }>;
  if (courseRows.length === 0) return [];

  const courseIds = courseRows.map((c) => c.id);

  const { data: lessons } = await supabase
    .from("traveler_lessons")
    .select("id, traveler_course_id, is_premium")
    .in("traveler_course_id", courseIds);
  const lessonRows = (lessons ?? []) as Array<{
    id: number;
    traveler_course_id: number;
    is_premium: boolean;
  }>;

  const {
    data: { user },
  } = await supabase.auth.getUser();

  let completedSet = new Set<number>();
  if (user) {
    const { data: progress } = await supabase
      .from("traveler_progress")
      .select("traveler_lesson_id")
      .eq("user_id", user.id)
      .eq("completed", true)
      .in("traveler_lesson_id", lessonRows.map((l) => l.id));
    completedSet = new Set(
      (progress ?? []).map((p: { traveler_lesson_id: number }) => p.traveler_lesson_id),
    );
  }

  return courseRows.map((c) => {
    const courseLessons = lessonRows.filter((l) => l.traveler_course_id === c.id);
    const free = courseLessons.filter((l) => !l.is_premium).length;
    const completed = courseLessons.filter((l) => completedSet.has(l.id)).length;
    return {
      id: c.id,
      city: c.city,
      country: c.country,
      slug: cityToSlug(c.city),
      description: c.description,
      coverImageUrl: coverFor(c.city) || c.cover_image_url || "",
      orderIndex: c.order_index,
      lessonsTotal: courseLessons.length,
      lessonsCompleted: completed,
      freePreviewCount: free,
      coords: coordsFor(c.city),
    };
  });
}

// Returns a single traveler course looked up by (languageSlug, citySlug),
// plus its lessons in order and per-lesson completion state.
export async function getTravelerCourseByCitySlug(
  languageSlug: string,
  citySlug: string,
): Promise<{ course: TravelerCourseSummary; lessons: TravelerLessonSummary[] } | null> {
  const courses = await getTravelerCoursesForLanguage(languageSlug);
  const course = courses.find((c) => c.slug === citySlug);
  if (!course) return null;

  const supabase = await createClient();
  const { data: lessons } = await supabase
    .from("traveler_lessons")
    .select("id, title, location_name, lesson_type, order_index, xp_reward, is_premium")
    .eq("traveler_course_id", course.id)
    .order("order_index");
  const lessonRows = (lessons ?? []) as Array<{
    id: number;
    title: string;
    location_name: string;
    lesson_type: TravelerLessonSummary["lessonType"];
    order_index: number;
    xp_reward: number;
    is_premium: boolean;
  }>;

  const {
    data: { user },
  } = await supabase.auth.getUser();

  let completedSet = new Set<number>();
  if (user && lessonRows.length > 0) {
    const { data: progress } = await supabase
      .from("traveler_progress")
      .select("traveler_lesson_id")
      .eq("user_id", user.id)
      .eq("completed", true)
      .in("traveler_lesson_id", lessonRows.map((l) => l.id));
    completedSet = new Set(
      (progress ?? []).map((p: { traveler_lesson_id: number }) => p.traveler_lesson_id),
    );
  }

  return {
    course,
    lessons: lessonRows.map((l) => ({
      id: l.id,
      title: l.title,
      locationName: l.location_name,
      lessonType: l.lesson_type,
      orderIndex: l.order_index,
      xpReward: l.xp_reward,
      isPremium: l.is_premium,
      completed: completedSet.has(l.id),
    })),
  };
}

// Cover image lookup, exposed for the city-detail hero.
export function coverImageForCity(city: string): string {
  return coverFor(city);
}

// ============================================================
// Lesson content — used by /learn/[language]/travel/[city]/[lesson]
// ============================================================

// One content row rendered to a specific step in the lesson runner.
// The union mirrors the `content_type` values allowed in the
// traveler_lesson_content table (see 054_travelers_50_lessons.sql).

export interface SceneSection {
  kind: "scene";
  imageUrl: string | null;
  imageAlt: string | null;
  description: string | null; // 2nd-person immersive text
  stamp: string | null; // e.g. "MADRID"
  stampSublabel: string | null; // e.g. "MAD · BARAJAS T4"
}

export interface SignWord {
  text: string;
  phonetic: string | null;
  english: string | null;
  tip: string | null;
}

export interface SignSection {
  kind: "sign";
  imageUrl: string | null;
  imageAlt: string | null;
  style:
    | "airport_blue"
    | "menu_card"
    | "street"
    | "notice"
    | "neon"; // rendering variant
  title: string;
  subtitle: string | null;
  icon: string | null;
  note: string | null;
  words: SignWord[];
}

export interface Phrase {
  phrase: string;
  phonetic: string | null;
  english: string | null;
  tip: string | null;
  grammar: string | null;
}

export interface PhrasesSection {
  kind: "phrases";
  phrases: Phrase[];
  // Optional plain-English explanation of one structural feature that
  // ties the phrases together (verb tense, formality register, etc.).
  // Rendered as a small note above the phrase deck. Null for legacy
  // rows written before this field existed.
  grammarNote: string | null;
}

export interface DialogueLine {
  speaker: string;
  target: string; // Spanish or French line
  english: string;
}

export interface DialogueSection {
  kind: "dialogue";
  lines: DialogueLine[];
}

export type QuizType = "multiple_choice" | "fill_blank" | "listening";

export interface QuizQuestion {
  type: QuizType;
  question: string;
  correctAnswer: string;
  wrongAnswers: string[];
  translation: string | null;
  audioPrompt: string | null; // only for listening
}

export interface QuizSection {
  kind: "quiz";
  questions: QuizQuestion[];
}

export type LessonSection =
  | SceneSection
  | SignSection
  | PhrasesSection
  | DialogueSection
  | QuizSection;

export interface LessonContent {
  lesson: TravelerLessonSummary;
  courseCity: string;
  courseCountry: string;
  sections: LessonSection[];
  // The next lesson in the same course (by order_index) — used by the
  // completion screen for the "Continue Journey" CTA. Null if this is
  // the final lesson.
  nextLesson: {
    id: number;
    orderIndex: number;
    title: string;
    locationName: string;
    isPremium: boolean;
  } | null;
}

// Local shape for a raw content row. Kept internal to this module.
type RawContentRow = {
  content_type: string;
  content_order: number;
  image_url: string | null;
  image_alt: string | null;
  dialogue_lines: unknown;
  explanation_text: string | null;
  quiz_questions: unknown;
  data: unknown;
};

function asObject(value: unknown): Record<string, unknown> {
  return typeof value === "object" && value !== null
    ? (value as Record<string, unknown>)
    : {};
}
function asArray(value: unknown): unknown[] {
  return Array.isArray(value) ? value : [];
}
function asString(value: unknown, fallback = ""): string {
  return typeof value === "string" ? value : fallback;
}
function asStringOrNull(value: unknown): string | null {
  return typeof value === "string" && value.length > 0 ? value : null;
}

function normalizeSignStyle(v: unknown): SignSection["style"] {
  const allowed: SignSection["style"][] = [
    "airport_blue",
    "menu_card",
    "street",
    "notice",
    "neon",
  ];
  return allowed.includes(v as SignSection["style"])
    ? (v as SignSection["style"])
    : "notice";
}

function normalizeQuizType(v: unknown): QuizType {
  return v === "fill_blank" || v === "listening" ? v : "multiple_choice";
}

function normalizeSection(row: RawContentRow): LessonSection | null {
  const data = asObject(row.data);
  switch (row.content_type) {
    case "scene":
      return {
        kind: "scene",
        imageUrl: row.image_url,
        imageAlt: row.image_alt,
        description: row.explanation_text,
        stamp: asStringOrNull(data.stamp),
        stampSublabel: asStringOrNull(data.stampSublabel),
      };
    case "sign":
      return {
        kind: "sign",
        imageUrl: row.image_url,
        imageAlt: row.image_alt,
        style: normalizeSignStyle(data.style),
        title: asString(data.title, ""),
        subtitle: asStringOrNull(data.subtitle),
        icon: asStringOrNull(data.icon),
        note: asStringOrNull(data.note),
        words: asArray(data.words).map((w) => {
          const o = asObject(w);
          return {
            text: asString(o.text, ""),
            phonetic: asStringOrNull(o.phonetic),
            english: asStringOrNull(o.english),
            tip: asStringOrNull(o.tip),
          };
        }),
      };
    case "phrases":
      return {
        kind: "phrases",
        phrases: asArray(data.phrases).map((p) => {
          const o = asObject(p);
          return {
            phrase: asString(o.phrase, ""),
            phonetic: asStringOrNull(o.phonetic),
            english: asStringOrNull(o.english),
            tip: asStringOrNull(o.tip),
            grammar: asStringOrNull(o.grammar),
          };
        }),
        grammarNote: asStringOrNull(data.grammarNote),
      };
    case "dialogue":
      return {
        kind: "dialogue",
        lines: asArray(row.dialogue_lines).map((line) => {
          const o = asObject(line);
          // Legacy rows (from migration 053) used "spanish"/"french" keys;
          // new rows use "target". Support both so the runner works
          // regardless of which migration wrote the row.
          const target =
            asString(o.target, "") ||
            asString(o.spanish, "") ||
            asString(o.french, "");
          return {
            speaker: asString(o.speaker, ""),
            target,
            english: asString(o.english, ""),
          };
        }),
      };
    case "quiz":
      return {
        kind: "quiz",
        questions: asArray(row.quiz_questions).map((q) => {
          const o = asObject(q);
          return {
            type: normalizeQuizType(o.type),
            question: asString(o.question, ""),
            correctAnswer: asString(o.correct_answer, ""),
            wrongAnswers: asArray(o.wrong_answers).map((a) =>
              asString(a, ""),
            ),
            translation: asStringOrNull(o.translation),
            audioPrompt: asStringOrNull(o.audio_prompt),
          };
        }),
      };
    // Legacy 'image' + 'explanation' rows from migration 053 fold into a
    // synthetic scene so the runner can still render them.
    case "image":
      return {
        kind: "scene",
        imageUrl: row.image_url,
        imageAlt: row.image_alt,
        description: null,
        stamp: null,
        stampSublabel: null,
      };
    case "explanation":
      return {
        kind: "scene",
        imageUrl: null,
        imageAlt: null,
        description: row.explanation_text,
        stamp: null,
        stampSublabel: null,
      };
    default:
      return null;
  }
}

// Fetches a single lesson with its ordered content sections. Returns
// null when the (language, city, lesson) tuple doesn't resolve.
export async function getTravelerLessonWithContent(
  languageSlug: string,
  citySlug: string,
  lessonId: number,
): Promise<LessonContent | null> {
  const bundle = await getTravelerCourseByCitySlug(languageSlug, citySlug);
  if (!bundle) return null;

  const lesson = bundle.lessons.find((l) => l.id === lessonId);
  if (!lesson) return null;

  const supabase = await createClient();
  const { data } = await supabase
    .from("traveler_lesson_content")
    .select(
      "content_type, content_order, image_url, image_alt, dialogue_lines, explanation_text, quiz_questions, data",
    )
    .eq("traveler_lesson_id", lesson.id)
    .order("content_order");

  const rows = (data ?? []) as RawContentRow[];
  const sections = rows
    .map(normalizeSection)
    .filter((s): s is LessonSection => s !== null);

  const nextLessonRaw = bundle.lessons.find(
    (l) => l.orderIndex === lesson.orderIndex + 1,
  );
  const nextLesson = nextLessonRaw
    ? {
        id: nextLessonRaw.id,
        orderIndex: nextLessonRaw.orderIndex,
        title: nextLessonRaw.title,
        locationName: nextLessonRaw.locationName,
        isPremium: nextLessonRaw.isPremium,
      }
    : null;

  return {
    lesson,
    courseCity: bundle.course.city,
    courseCountry: bundle.course.country,
    sections,
    nextLesson,
  };
}

// Marks a lesson complete for the current user. Idempotent — safe to
// call after the completion screen has already run. Returns the number
// of newly-earned XP (0 if the lesson was already completed).
export async function completeTravelerLesson(
  lessonId: number,
): Promise<number> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return 0;

  const { data: lesson } = await supabase
    .from("traveler_lessons")
    .select("xp_reward")
    .eq("id", lessonId)
    .maybeSingle();
  const xp = (lesson as { xp_reward: number } | null)?.xp_reward ?? 0;

  const { data: existing } = await supabase
    .from("traveler_progress")
    .select("id, completed")
    .eq("user_id", user.id)
    .eq("traveler_lesson_id", lessonId)
    .maybeSingle();

  const wasAlreadyDone = !!(existing as { completed: boolean } | null)
    ?.completed;

  if (existing) {
    if (wasAlreadyDone) return 0;
    await supabase
      .from("traveler_progress")
      .update({ completed: true, completed_at: new Date().toISOString() })
      .eq("id", (existing as { id: string }).id);
  } else {
    await supabase.from("traveler_progress").insert({
      user_id: user.id,
      traveler_lesson_id: lessonId,
      completed: true,
      completed_at: new Date().toISOString(),
    });
  }
  return xp;
}

// Per-language count of completed traveler lessons for the current user.
// Returns `{}` if the user is signed out. Used by the homepage language
// cards to decide whether the Traveler's Course CTA says "Start Journey"
// or "Continue Journey".
export async function getTravelerCompletedCountsByLanguage(): Promise<
  Record<string, number>
> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return {};

  // One join query: progress → lesson → course → language.code. RLS
  // already restricts to own rows, but we keep the explicit user filter
  // for clarity and to survive any future policy changes.
  const { data } = await supabase
    .from("traveler_progress")
    .select(
      "traveler_lessons!inner(traveler_courses!inner(languages!inner(code)))",
    )
    .eq("user_id", user.id)
    .eq("completed", true);

  type Row = {
    traveler_lessons: {
      traveler_courses: {
        languages: { code: string };
      };
    };
  };

  const counts: Record<string, number> = {};
  for (const row of ((data ?? []) as unknown as Row[])) {
    const code = row?.traveler_lessons?.traveler_courses?.languages?.code;
    if (code) counts[code] = (counts[code] ?? 0) + 1;
  }
  return counts;
}

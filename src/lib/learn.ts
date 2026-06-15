import { createClient } from "@/lib/supabase/server";

export type LessonType =
  | "vocabulary"
  | "grammar"
  | "phrases"
  | "listening"
  | "speaking"
  | "reading"
  | "writing"
  | "podcast"
  | "unit_test"
  | "conversation";
export type ExerciseType = "multiple_choice" | "fill_blank" | "matching" | "listening" | "speaking";
export type CEFRLevel = "A1" | "A2" | "B1" | "B2" | "C1";

export const CEFR_LEVELS: readonly CEFRLevel[] = ["A1", "A2", "B1", "B2", "C1"] as const;

export const CEFR_LABEL: Record<CEFRLevel, string> = {
  A1: "Beginner",
  A2: "Elementary",
  B1: "Intermediate",
  B2: "Upper-Intermediate",
  C1: "Advanced",
};

// BCP-47 codes used for the Web Speech API (TTS + speech recognition).
export const SPEECH_LANG_CODES: Record<string, string> = {
  spanish: "es-ES",
  french: "fr-FR",
  german: "de-DE",
  greek: "el-GR",
  swedish: "sv-SE",
  danish: "da-DK",
  finnish: "fi-FI",
  albanian: "sq-AL",
  icelandic: "is-IS",
  faroese: "fo-FO",
  corsican: "it-IT", // Corsican has limited browser support; fall back to Italian.
  english: "en-US",
};

export interface DbLanguage {
  id: number;
  name: string;
  code: string;
  flag_emoji: string | null;
  difficulty_grammar: "Easy" | "Medium" | "Hard";
  difficulty_pronunciation: "Easy" | "Medium" | "Hard";
}

export interface DbCourse {
  id: number;
  language_id: number;
  title: string;
  description: string | null;
  cefr_level: CEFRLevel;
  order_index: number;
}

export interface LessonVocabItem {
  word: string;
  phonetic: string;
  english: string;
  example_es: string;
  example_en: string;
}

export interface LessonDialogueLine {
  speaker: string;
  spanish: string;
  english: string;
}

export interface DbLesson {
  id: number;
  course_id: number;
  title: string;
  description: string | null;
  type: LessonType;
  order_index: number;
  xp_reward: number;
  intro: string | null;
  vocab_items: LessonVocabItem[] | null;
  dialogue: LessonDialogueLine[] | null;
  grammar_note: string | null;
}

export interface DbExercise {
  id: number;
  lesson_id: number;
  type: ExerciseType;
  question: string;
  correct_answer: string;
  wrong_answers: string[];
  translation: string | null;
  order_index: number;
}

export interface DbUserStats {
  language_id: number;
  total_xp: number;
  current_streak: number;
  longest_streak: number;
  last_activity_date: string | null;
}

export interface DbUserProfile {
  user_id: string;
  total_xp: number;
  current_streak: number;
  longest_streak: number;
  last_activity_date: string | null;
}

/**
 * Returns the live current streak. The stored value only updates when the
 * user completes a lesson; if they skip days the column doesn't catch up
 * until the next completion. For display we decay it: if the last activity
 * was older than yesterday (UTC), the streak is broken and we show 0.
 *
 * `today` and `yesterday` are computed in UTC to match the write-side logic
 * in `learn-actions.ts` (which uses `Date.toISOString().slice(0, 10)`).
 */
export function liveCurrentStreak(
  storedStreak: number,
  lastActivityDate: string | null,
): number {
  if (!lastActivityDate) return 0;
  const today = new Date().toISOString().slice(0, 10);
  const yesterday = new Date(Date.now() - 86_400_000)
    .toISOString()
    .slice(0, 10);
  if (lastActivityDate === today || lastActivityDate === yesterday) {
    return storedStreak;
  }
  return 0;
}

export interface DbArticle {
  id: number;
  language_id: number;
  slug: string;
  title: string;
  title_english: string;
  level: CEFRLevel;
  reading_minutes: number;
  content_target: string;
  content_english: string;
  order_index: number;
}

export interface DbPodcast {
  id: number;
  language_id: number;
  title: string;
  description: string | null;
  duration_minutes: number;
  level: CEFRLevel;
  is_premium: boolean;
  order_index: number;
}

export interface DbVideo {
  id: number;
  language_id: number;
  title: string;
  description: string | null;
  duration_minutes: number;
  level: CEFRLevel;
  is_premium: boolean;
  order_index: number;
}

export interface SectionWithProgress extends DbCourse {
  lessonsTotal: number;
  lessonsCompleted: number;
  locked: boolean;
}

export interface CEFRLevelGroup {
  level: CEFRLevel;
  label: string;
  sections: SectionWithProgress[];
  lessonsTotal: number;
  lessonsCompleted: number;
}

export interface LessonWithStatus extends DbLesson {
  completed: boolean;
  locked: boolean;
}

export interface SectionWithLessons extends DbCourse {
  lessons: LessonWithStatus[];
}

export interface LanguageProgress {
  language: DbLanguage;
  totalLessons: number;
  completedLessons: number;
  progressPct: number;
  stats: DbUserStats | null;
}

export async function getLanguagesWithProgress(): Promise<LanguageProgress[]> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  // Join explicitly: languages <- courses <- lessons. Each child table is
  // pulled with pagination because Supabase's server-side row cap (default
  // 1000 via db.max_rows) overrides client-side .limit().
  const [languages, courses, lessons] = await Promise.all([
    fetchAllPaginated<DbLanguage>(supabase, "languages", "*"),
    fetchAllPaginated<{ id: number; language_id: number }>(
      supabase,
      "courses",
      "id, language_id",
    ),
    fetchAllPaginated<{ id: number; course_id: number }>(
      supabase,
      "lessons",
      "id, course_id",
    ),
  ]);

  console.log(
    "[getLanguagesWithProgress] fetched %d languages, %d courses, %d lessons",
    languages.length,
    courses.length,
    lessons.length,
  );

  if (languages.length === 0) return [];

  const courseToLanguage = new Map<number, number>();
  for (const c of courses) courseToLanguage.set(c.id, c.language_id);

  const lessonsByLanguage = new Map<number, number[]>();
  for (const l of lessons) {
    const langId = courseToLanguage.get(l.course_id);
    if (langId == null) continue;
    const arr = lessonsByLanguage.get(langId) ?? [];
    arr.push(l.id);
    lessonsByLanguage.set(langId, arr);
  }

  console.log(
    "[getLanguagesWithProgress] lesson counts per language:",
    languages.map((l) => `${l.code}=${lessonsByLanguage.get(l.id)?.length ?? 0}`).join(", "),
  );

  let completedLessonIds = new Set<number>();
  let statsByLang = new Map<number, DbUserStats>();

  if (user) {
    const { data: progressRows } = await supabase
      .from("user_progress")
      .select("lesson_id, completed")
      .eq("user_id", user.id)
      .eq("completed", true);
    completedLessonIds = new Set(
      (progressRows ?? []).map((r: { lesson_id: number }) => r.lesson_id),
    );

    const { data: statsRows } = await supabase
      .from("user_stats")
      .select("language_id, total_xp, current_streak, longest_streak, last_activity_date")
      .eq("user_id", user.id);
    statsByLang = new Map(
      (statsRows ?? []).map((s: DbUserStats) => [
        s.language_id,
        {
          ...s,
          current_streak: liveCurrentStreak(
            s.current_streak,
            s.last_activity_date,
          ),
        },
      ]),
    );
  }

  return languages.map((lang) => {
    const lessonIds = lessonsByLanguage.get(lang.id) ?? [];
    const completed = lessonIds.filter((id) => completedLessonIds.has(id)).length;
    const total = lessonIds.length;
    return {
      language: lang,
      totalLessons: total,
      completedLessons: completed,
      progressPct: total === 0 ? 0 : Math.round((completed / total) * 100),
      stats: statsByLang.get(lang.id) ?? null,
    };
  });
}

export async function getUserProfile(): Promise<DbUserProfile | null> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;
  const { data } = await supabase
    .from("user_profile")
    .select("*")
    .eq("user_id", user.id)
    .maybeSingle();
  const profile = (data as DbUserProfile) ?? null;
  if (!profile) return null;
  // Decay streak on read — see liveCurrentStreak doc above.
  return {
    ...profile,
    current_streak: liveCurrentStreak(
      profile.current_streak,
      profile.last_activity_date,
    ),
  };
}

export async function getLanguageBySlug(slug: string): Promise<DbLanguage | null> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("languages")
    .select("*")
    .eq("code", slug)
    .maybeSingle();
  return (data as DbLanguage) ?? null;
}

// Paginated fetcher. Supabase enforces a server-side row cap (default 1000)
// that overrides client-side .limit(). Pagination via .range() always works.
type SbClient = Awaited<ReturnType<typeof createClient>>;
async function fetchAllPaginated<T>(
  supabase: SbClient,
  table: string,
  columns: string,
): Promise<T[]> {
  const out: T[] = [];
  const pageSize = 1000;
  let from = 0;
  while (true) {
    const { data, error } = await supabase
      .from(table)
      .select(columns)
      .order("id")
      .range(from, from + pageSize - 1);
    if (error) throw error;
    const rows = (data as unknown as T[]) ?? [];
    out.push(...rows);
    if (rows.length < pageSize) break;
    from += pageSize;
  }
  return out;
}

// Lightweight version of getLanguagesWithProgress for pages that just need
// the catalogue (e.g. the homepage). Returns the rows in id order.
export async function getAllLanguages(): Promise<DbLanguage[]> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("languages")
    .select("*")
    .order("id");
  return (data as DbLanguage[]) ?? [];
}

/**
 * Set of language codes (slugs) the current user has at least one completed
 * lesson in. Used by homepage cards to decide between "Start learning X"
 * and "Continue learning X". Returns an empty set for unauthenticated
 * visitors so they always see "Start learning".
 */
export async function getLanguagesUserHasStarted(): Promise<Set<string>> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return new Set();

  const { data: progress } = await supabase
    .from("user_progress")
    .select("lesson_id")
    .eq("user_id", user.id)
    .eq("completed", true);
  const lessonIds = (progress ?? []).map(
    (p: { lesson_id: number }) => p.lesson_id,
  );
  if (lessonIds.length === 0) return new Set();

  const { data: lessons } = await supabase
    .from("lessons")
    .select("id, course_id")
    .in("id", lessonIds);
  const courseIds = Array.from(
    new Set((lessons ?? []).map((l: { course_id: number }) => l.course_id)),
  );
  if (courseIds.length === 0) return new Set();

  const { data: courses } = await supabase
    .from("courses")
    .select("id, language_id")
    .in("id", courseIds);
  const languageIds = Array.from(
    new Set(
      (courses ?? []).map((c: { language_id: number }) => c.language_id),
    ),
  );
  if (languageIds.length === 0) return new Set();

  const { data: languages } = await supabase
    .from("languages")
    .select("code")
    .in("id", languageIds);
  return new Set((languages ?? []).map((l: { code: string }) => l.code));
}

export interface LanguageWithLessonCount extends DbLanguage {
  lessonsTotal: number;
}

// Languages plus the real lesson count per language. No user-specific data.
// Used by the homepage so each card can show "X lessons" without forcing
// the visitor through auth.
//
// Joins languages <- courses <- lessons explicitly and counts in JS.
// Each table is fetched with an explicit .limit so Supabase's default
// 1000-row cap doesn't truncate lessons (a real risk now that we have
// 3000+ lessons across 26 languages).
export async function getLanguagesWithLessonCounts(): Promise<LanguageWithLessonCount[]> {
  const supabase = await createClient();
  const [langs, courses, lessons] = await Promise.all([
    fetchAllPaginated<DbLanguage>(supabase, "languages", "*"),
    fetchAllPaginated<{ id: number; language_id: number }>(
      supabase,
      "courses",
      "id, language_id",
    ),
    fetchAllPaginated<{ id: number; course_id: number }>(
      supabase,
      "lessons",
      "id, course_id",
    ),
  ]);

  console.log(
    "[getLanguagesWithLessonCounts] fetched %d languages, %d courses, %d lessons",
    langs.length,
    courses.length,
    lessons.length,
  );

  const courseToLanguage = new Map<number, number>();
  for (const c of courses) courseToLanguage.set(c.id, c.language_id);

  const counts = new Map<number, number>();
  for (const l of lessons) {
    const langId = courseToLanguage.get(l.course_id);
    if (langId == null) continue;
    counts.set(langId, (counts.get(langId) ?? 0) + 1);
  }

  console.log(
    "[getLanguagesWithLessonCounts] counts:",
    langs.map((l) => `${l.code}=${counts.get(l.id) ?? 0}`).join(", "),
  );

  return langs.map((lang) => ({
    ...lang,
    lessonsTotal: counts.get(lang.id) ?? 0,
  }));
}

// Build the full CEFR tree for a language. Each level groups its sections;
// each section knows its lesson totals and completion counts.
export async function getCEFRTreeForLanguage(
  languageId: number,
): Promise<CEFRLevelGroup[]> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data: courses } = await supabase
    .from("courses")
    .select("*")
    .eq("language_id", languageId)
    .order("cefr_level")
    .order("order_index");

  const courseIds = (courses ?? []).map((c: DbCourse) => c.id);
  const { data: lessons } = await supabase
    .from("lessons")
    .select("id, course_id")
    .in("course_id", courseIds.length ? courseIds : [-1]);

  let completedSet = new Set<number>();
  if (user) {
    const lessonIds = (lessons ?? []).map((l: { id: number }) => l.id);
    if (lessonIds.length > 0) {
      const { data: progress } = await supabase
        .from("user_progress")
        .select("lesson_id")
        .eq("user_id", user.id)
        .eq("completed", true)
        .in("lesson_id", lessonIds);
      completedSet = new Set(
        (progress ?? []).map((p: { lesson_id: number }) => p.lesson_id),
      );
    }
  }

  const lessonsByCourse = new Map<number, number[]>();
  for (const l of (lessons ?? []) as { id: number; course_id: number }[]) {
    const arr = lessonsByCourse.get(l.course_id) ?? [];
    arr.push(l.id);
    lessonsByCourse.set(l.course_id, arr);
  }

  // Compute sections with progress, ordered by CEFR then order_index.
  const sections: SectionWithProgress[] = ((courses as DbCourse[]) ?? []).map(
    (course) => {
      const lessonIds = lessonsByCourse.get(course.id) ?? [];
      const completed = lessonIds.filter((id) => completedSet.has(id)).length;
      return {
        ...course,
        lessonsTotal: lessonIds.length,
        lessonsCompleted: completed,
        locked: false, // computed below across CEFR levels
      };
    },
  );

  // Group by CEFR level
  const groups: CEFRLevelGroup[] = CEFR_LEVELS.map((level) => {
    const levelSections = sections
      .filter((s) => s.cefr_level === level)
      .sort((a, b) => a.order_index - b.order_index);
    const total = levelSections.reduce((sum, s) => sum + s.lessonsTotal, 0);
    const done = levelSections.reduce((sum, s) => sum + s.lessonsCompleted, 0);
    return {
      level,
      label: CEFR_LABEL[level],
      sections: levelSections,
      lessonsTotal: total,
      lessonsCompleted: done,
    };
  });

  // Lock progression: a level is unlocked when the previous level is fully
  // complete. Within an unlocked level all sections are accessible — we keep
  // the order suggestive but don't hard-lock.
  let prevLevelFullyComplete = true;
  for (const group of groups) {
    if (!prevLevelFullyComplete) {
      for (const section of group.sections) section.locked = true;
    }
    if (group.lessonsTotal === 0 || group.lessonsCompleted < group.lessonsTotal) {
      prevLevelFullyComplete = false;
    }
  }

  return groups;
}

export async function getSectionWithLessons(
  sectionId: number,
): Promise<{
  section: DbCourse;
  language: DbLanguage;
  lessons: LessonWithStatus[];
} | null> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data: section } = await supabase
    .from("courses")
    .select("*")
    .eq("id", sectionId)
    .maybeSingle();
  if (!section) return null;

  const { data: language } = await supabase
    .from("languages")
    .select("*")
    .eq("id", section.language_id)
    .maybeSingle();
  if (!language) return null;

  const { data: lessons } = await supabase
    .from("lessons")
    .select("*")
    .eq("course_id", sectionId)
    .order("order_index");

  let completedSet = new Set<number>();
  if (user) {
    const lessonIds = (lessons ?? []).map((l: DbLesson) => l.id);
    if (lessonIds.length > 0) {
      const { data: progress } = await supabase
        .from("user_progress")
        .select("lesson_id")
        .eq("user_id", user.id)
        .eq("completed", true)
        .in("lesson_id", lessonIds);
      completedSet = new Set(
        (progress ?? []).map((p: { lesson_id: number }) => p.lesson_id),
      );
    }
  }

  const sorted = ((lessons as DbLesson[]) ?? []).sort(
    (a, b) => a.order_index - b.order_index,
  );

  let prev = true; // first lesson is unlocked
  const withStatus: LessonWithStatus[] = sorted.map((lesson) => {
    const completed = completedSet.has(lesson.id);
    const locked = !prev && !completed;
    if (!completed && !locked) prev = false;
    if (completed) prev = true;
    return { ...lesson, completed, locked };
  });

  return {
    section: section as DbCourse,
    language: language as DbLanguage,
    lessons: withStatus,
  };
}

export async function getLessonWithExercises(lessonId: number): Promise<{
  lesson: DbLesson;
  course: DbCourse;
  language: DbLanguage;
  exercises: DbExercise[];
} | null> {
  const supabase = await createClient();
  const { data: lesson } = await supabase
    .from("lessons")
    .select("*")
    .eq("id", lessonId)
    .maybeSingle();
  if (!lesson) return null;

  const { data: course } = await supabase
    .from("courses")
    .select("*")
    .eq("id", lesson.course_id)
    .maybeSingle();
  if (!course) return null;

  const { data: language } = await supabase
    .from("languages")
    .select("*")
    .eq("id", course.language_id)
    .maybeSingle();
  if (!language) return null;

  const { data: exercises } = await supabase
    .from("exercises")
    .select("*")
    .eq("lesson_id", lessonId)
    .order("order_index");

  return {
    lesson: lesson as DbLesson,
    course: course as DbCourse,
    language: language as DbLanguage,
    exercises: (exercises as DbExercise[]) ?? [],
  };
}

export async function getLessonsCompletedThisWeek(): Promise<number> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return 0;

  const now = new Date();
  const dayOfWeek = now.getUTCDay();
  const monday = new Date(now);
  monday.setUTCDate(now.getUTCDate() - ((dayOfWeek + 6) % 7));
  monday.setUTCHours(0, 0, 0, 0);

  const { count } = await supabase
    .from("user_progress")
    .select("*", { count: "exact", head: true })
    .eq("user_id", user.id)
    .eq("completed", true)
    .gte("completed_at", monday.toISOString());

  return count ?? 0;
}

export async function getFirstIncompleteLessonId(
  languageId: number,
): Promise<number | null> {
  const tree = await getCEFRTreeForLanguage(languageId);
  for (const group of tree) {
    for (const section of group.sections) {
      if (section.locked) continue;
      if (section.lessonsCompleted >= section.lessonsTotal) continue;
      // Pull the first incomplete lesson in this section
      const supabase = await createClient();
      const {
        data: { user },
      } = await supabase.auth.getUser();
      const { data: lessons } = await supabase
        .from("lessons")
        .select("id, order_index")
        .eq("course_id", section.id)
        .order("order_index");
      if (!lessons || lessons.length === 0) continue;
      let completedSet = new Set<number>();
      if (user) {
        const { data: progress } = await supabase
          .from("user_progress")
          .select("lesson_id")
          .eq("user_id", user.id)
          .eq("completed", true)
          .in(
            "lesson_id",
            lessons.map((l: { id: number }) => l.id),
          );
        completedSet = new Set(
          (progress ?? []).map((p: { lesson_id: number }) => p.lesson_id),
        );
      }
      for (const l of lessons as { id: number }[]) {
        if (!completedSet.has(l.id)) return l.id;
      }
    }
  }
  return null;
}

export function getHighestReachedLevel(tree: CEFRLevelGroup[]): CEFRLevel {
  let highest: CEFRLevel = "A1";
  for (const group of tree) {
    if (group.lessonsCompleted > 0) highest = group.level;
  }
  return highest;
}

// -------- Articles --------

export async function getArticlesForLanguage(
  languageId: number,
): Promise<DbArticle[]> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("articles")
    .select("*")
    .eq("language_id", languageId)
    .order("order_index");
  return (data as DbArticle[]) ?? [];
}

export async function getArticleBySlug(
  languageId: number,
  slug: string,
): Promise<DbArticle | null> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("articles")
    .select("*")
    .eq("language_id", languageId)
    .eq("slug", slug)
    .maybeSingle();
  return (data as DbArticle) ?? null;
}

// -------- Podcasts & Videos --------

export async function getPodcastsForLanguage(
  languageId: number,
): Promise<DbPodcast[]> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("podcasts")
    .select("*")
    .eq("language_id", languageId)
    .order("order_index");
  return (data as DbPodcast[]) ?? [];
}

export async function getVideosForLanguage(
  languageId: number,
): Promise<DbVideo[]> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("videos")
    .select("*")
    .eq("language_id", languageId)
    .order("order_index");
  return (data as DbVideo[]) ?? [];
}

// Premium status. Reads the user's `is_premium` flag from Supabase Auth
// user_metadata — the same field the Stripe checkout/verify route writes
// and the same field every other premium gate checks. This is THE single
// source of truth for premium status; route all reads through here so a
// future move to a real subscriptions table touches one function instead
// of six.
export async function isCurrentUserPremium(): Promise<boolean> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return false;
  return user.user_metadata?.is_premium === true;
}

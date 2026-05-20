import { createClient } from "@/lib/supabase/server";

export type LessonType = "vocabulary" | "grammar" | "phrases" | "listening" | "speaking";
export type ExerciseType = "multiple_choice" | "fill_blank" | "matching" | "listening" | "speaking";

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
  order_index: number;
}

export interface DbLesson {
  id: number;
  course_id: number;
  title: string;
  description: string | null;
  type: LessonType;
  order_index: number;
  xp_reward: number;
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

export interface LessonWithStatus extends DbLesson {
  completed: boolean;
  locked: boolean;
}

export interface CourseWithLessons extends DbCourse {
  lessons: LessonWithStatus[];
}

export interface LanguageProgress {
  language: DbLanguage;
  totalLessons: number;
  completedLessons: number;
  progressPct: number;
  stats: DbUserStats | null;
}

const COURSE_TIER_ORDER = ["Beginner", "Intermediate", "Advanced"];

export async function getLanguagesWithProgress(): Promise<LanguageProgress[]> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data: languages } = await supabase
    .from("languages")
    .select("*")
    .order("id");

  if (!languages) return [];

  const { data: lessonCounts } = await supabase
    .from("lessons")
    .select("id, course_id, courses!inner(language_id)");

  const lessonsByLanguage = new Map<number, number[]>();
  for (const row of (lessonCounts ?? []) as Array<{
    id: number;
    courses: { language_id: number } | { language_id: number }[];
  }>) {
    const langId = Array.isArray(row.courses)
      ? row.courses[0]?.language_id
      : row.courses?.language_id;
    if (langId == null) continue;
    const arr = lessonsByLanguage.get(langId) ?? [];
    arr.push(row.id);
    lessonsByLanguage.set(langId, arr);
  }

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
      (statsRows ?? []).map((s: DbUserStats) => [s.language_id, s]),
    );
  }

  return (languages as DbLanguage[]).map((lang) => {
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
  return (data as DbUserProfile) ?? null;
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

export async function getCourseTreeForLanguage(
  languageId: number,
): Promise<CourseWithLessons[]> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data: courses } = await supabase
    .from("courses")
    .select("*")
    .eq("language_id", languageId)
    .order("order_index");

  const { data: lessons } = await supabase
    .from("lessons")
    .select("*")
    .in("course_id", (courses ?? []).map((c: DbCourse) => c.id))
    .order("order_index");

  let completedSet = new Set<number>();
  if (user) {
    const lessonIds = (lessons ?? []).map((l: DbLesson) => l.id);
    if (lessonIds.length > 0) {
      const { data: progress } = await supabase
        .from("user_progress")
        .select("lesson_id, completed")
        .eq("user_id", user.id)
        .in("lesson_id", lessonIds)
        .eq("completed", true);
      completedSet = new Set(
        (progress ?? []).map((p: { lesson_id: number }) => p.lesson_id),
      );
    }
  }

  const sortedCourses = [...((courses as DbCourse[]) ?? [])].sort((a, b) => {
    const aIdx = COURSE_TIER_ORDER.indexOf(a.title);
    const bIdx = COURSE_TIER_ORDER.indexOf(b.title);
    if (aIdx !== -1 && bIdx !== -1) return aIdx - bIdx;
    return a.order_index - b.order_index;
  });

  return sortedCourses.map((course, courseIdx) => {
    const courseLessons = ((lessons as DbLesson[]) ?? [])
      .filter((l) => l.course_id === course.id)
      .sort((a, b) => a.order_index - b.order_index);

    const prevCourseCompleted =
      courseIdx === 0
        ? true
        : (lessons as DbLesson[])
            .filter((l) => l.course_id === sortedCourses[courseIdx - 1].id)
            .every((l) => completedSet.has(l.id));

    let lockedSoFar = !prevCourseCompleted;
    const lessonsWithStatus: LessonWithStatus[] = courseLessons.map((lesson, lessonIdx) => {
      const completed = completedSet.has(lesson.id);
      const prevCompleted =
        lessonIdx === 0
          ? prevCourseCompleted
          : completedSet.has(courseLessons[lessonIdx - 1].id);
      const locked = lockedSoFar || (!prevCompleted && !completed);
      if (!completed && !locked) {
        lockedSoFar = true;
      }
      return { ...lesson, completed, locked };
    });

    return { ...course, lessons: lessonsWithStatus };
  });
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
  const tree = await getCourseTreeForLanguage(languageId);
  for (const course of tree) {
    for (const lesson of course.lessons) {
      if (!lesson.completed && !lesson.locked) return lesson.id;
    }
  }
  return null;
}

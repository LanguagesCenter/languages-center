"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export interface CompleteLessonResult {
  ok: boolean;
  xp_earned: number;
  already_completed: boolean;
  current_streak?: number;
  not_authenticated?: boolean;
  error?: string;
}

/**
 * Save a completed lesson: writes to user_progress, user_stats and
 * user_profile in order. Returns ok:false (with a clear `error`) if any
 * step fails; the caller can show the message and NOT auto-redirect.
 *
 * All work is done in JS via the supabase-js client — no dependency on
 * an RPC function existing in the DB.
 */
export async function completeLesson(
  lessonId: number,
  languageSlug: string,
): Promise<CompleteLessonResult> {
  const supabase = await createClient();

  // ---------- 0. Auth ----------
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return {
      ok: false,
      xp_earned: 0,
      already_completed: false,
      not_authenticated: true,
      error: "Sign in to save progress",
    };
  }

  // ---------- 1. Lesson + language metadata ----------
  // Tells us how much XP this lesson is worth and which language to credit.
  const { data: lesson, error: lessonErr } = await supabase
    .from("lessons")
    .select("id, xp_reward, course_id, courses!inner(language_id)")
    .eq("id", lessonId)
    .maybeSingle();

  if (lessonErr || !lesson) {
    console.error("[completeLesson] lesson lookup failed", lessonErr);
    return {
      ok: false,
      xp_earned: 0,
      already_completed: false,
      error: `Could not load lesson: ${lessonErr?.message ?? "not found"}`,
    };
  }

  const xpReward = (lesson as { xp_reward: number }).xp_reward;
  const courses = (lesson as unknown as {
    courses: { language_id: number } | { language_id: number }[];
  }).courses;
  const languageId = Array.isArray(courses) ? courses[0]?.language_id : courses?.language_id;
  if (typeof languageId !== "number") {
    return {
      ok: false,
      xp_earned: 0,
      already_completed: false,
      error: "Lesson is missing a language link",
    };
  }

  // ---------- 2. Has this lesson already been completed? ----------
  const { data: existing } = await supabase
    .from("user_progress")
    .select("completed")
    .eq("user_id", user.id)
    .eq("lesson_id", lessonId)
    .maybeSingle();
  const wasCompleted = existing?.completed === true;

  // ---------- 3. Upsert user_progress ----------
  const nowIso = new Date().toISOString();
  const { error: progressErr } = await supabase.from("user_progress").upsert(
    {
      user_id: user.id,
      lesson_id: lessonId,
      completed: true,
      score: xpReward,
      completed_at: nowIso,
    },
    { onConflict: "user_id,lesson_id" },
  );
  if (progressErr) {
    console.error("[completeLesson] user_progress upsert failed", progressErr);
    return {
      ok: false,
      xp_earned: 0,
      already_completed: wasCompleted,
      error: `Could not save lesson progress: ${progressErr.message}`,
    };
  }

  // If they'd already completed it before, don't award XP a second time —
  // but the progress row is still saved (completed_at refreshed).
  if (wasCompleted) {
    revalidatePath("/learn");
    revalidatePath(`/learn/${languageSlug}`);
    revalidatePath("/dashboard");
    return { ok: true, xp_earned: 0, already_completed: true };
  }

  // ---------- 4. Streak math ----------
  const today = nowIso.slice(0, 10); // YYYY-MM-DD
  const yesterday = new Date(Date.now() - 86_400_000).toISOString().slice(0, 10);

  function nextStreak(prevStreak: number, prevDate: string | null): number {
    if (!prevDate) return 1;
    if (prevDate === today) return prevStreak; // already updated today
    if (prevDate === yesterday) return prevStreak + 1;
    return 1;
  }

  // ---------- 5. Upsert user_stats (per language) ----------
  const { data: prevLangStats } = await supabase
    .from("user_stats")
    .select("total_xp, current_streak, longest_streak, last_activity_date")
    .eq("user_id", user.id)
    .eq("language_id", languageId)
    .maybeSingle();

  const langStreak = nextStreak(
    prevLangStats?.current_streak ?? 0,
    prevLangStats?.last_activity_date ?? null,
  );
  const langXp = (prevLangStats?.total_xp ?? 0) + xpReward;
  const langLongest = Math.max(prevLangStats?.longest_streak ?? 0, langStreak);

  const { error: statsErr } = await supabase.from("user_stats").upsert(
    {
      user_id: user.id,
      language_id: languageId,
      total_xp: langXp,
      current_streak: langStreak,
      longest_streak: langLongest,
      last_activity_date: today,
    },
    { onConflict: "user_id,language_id" },
  );
  if (statsErr) {
    console.error("[completeLesson] user_stats upsert failed", statsErr);
    return {
      ok: false,
      xp_earned: xpReward,
      already_completed: false,
      error: `Saved lesson but could not update stats: ${statsErr.message}`,
    };
  }

  // ---------- 6. Upsert user_profile (global XP + streak) ----------
  // user_profile is optional — if the table isn't installed yet we just
  // log and move on; the lesson + per-language stats are already saved.
  let globalStreak = langStreak;
  try {
    const { data: prevProfile } = await supabase
      .from("user_profile")
      .select("total_xp, current_streak, longest_streak, last_activity_date")
      .eq("user_id", user.id)
      .maybeSingle();

    globalStreak = nextStreak(
      prevProfile?.current_streak ?? 0,
      prevProfile?.last_activity_date ?? null,
    );
    const globalXp = (prevProfile?.total_xp ?? 0) + xpReward;
    const globalLongest = Math.max(prevProfile?.longest_streak ?? 0, globalStreak);

    const { error: profileErr } = await supabase.from("user_profile").upsert(
      {
        user_id: user.id,
        total_xp: globalXp,
        current_streak: globalStreak,
        longest_streak: globalLongest,
        last_activity_date: today,
        updated_at: nowIso,
      },
      { onConflict: "user_id" },
    );
    if (profileErr) {
      console.warn(
        "[completeLesson] user_profile upsert skipped:",
        profileErr.message,
      );
    }
  } catch (err) {
    console.warn("[completeLesson] user_profile not available:", err);
  }

  // ---------- 7. Revalidate cached pages ----------
  revalidatePath("/learn");
  revalidatePath(`/learn/${languageSlug}`);
  revalidatePath("/dashboard");

  console.log(
    "[completeLesson] saved lesson %d for user %s — +%d XP, lang streak %d",
    lessonId,
    user.id,
    xpReward,
    langStreak,
  );

  return {
    ok: true,
    xp_earned: xpReward,
    already_completed: false,
    current_streak: globalStreak,
  };
}

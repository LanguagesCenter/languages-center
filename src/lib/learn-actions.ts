"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export interface CompleteLessonResult {
  ok: boolean;
  xp_earned: number;
  already_completed: boolean;
  current_streak?: number;
  error?: string;
}

export async function completeLesson(
  lessonId: number,
  languageSlug: string,
): Promise<CompleteLessonResult> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return { ok: false, xp_earned: 0, already_completed: false, error: "Not signed in" };
  }

  const { data, error } = await supabase.rpc("complete_lesson", {
    p_lesson_id: lessonId,
  });

  if (error) {
    return {
      ok: false,
      xp_earned: 0,
      already_completed: false,
      error: error.message,
    };
  }

  const payload = data as {
    xp_earned: number;
    already_completed: boolean;
    current_streak?: number;
  };

  revalidatePath("/learn");
  revalidatePath(`/learn/${languageSlug}`);
  revalidatePath("/dashboard");

  return {
    ok: true,
    xp_earned: payload.xp_earned,
    already_completed: payload.already_completed,
    current_streak: payload.current_streak,
  };
}

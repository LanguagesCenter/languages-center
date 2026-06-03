import "server-only";
import { createClient } from "@/lib/supabase/server";
import type {
  PlacementQuestion,
  PlacementQuestionWithAnswer,
  PlacementAttempt,
} from "@/lib/placement-exam-types";

// Re-export the shared bits so existing server-side imports of these names
// from "@/lib/placement-exam" still work.
export {
  PASSING_PERCENTAGE,
  COOLDOWN_HOURS,
  EXAM_DURATION_SECONDS,
  cooldownRemainingMs,
} from "@/lib/placement-exam-types";
export type {
  ExamCategory,
  PlacementQuestion,
  PlacementQuestionWithAnswer,
  PlacementAttempt,
} from "@/lib/placement-exam-types";

/** Fetch questions WITH answers — used by server actions only. */
export async function getQuestionsWithAnswers(
  languageId: number,
  level: string,
): Promise<PlacementQuestionWithAnswer[]> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("placement_exam_questions")
    .select("*")
    .eq("language_id", languageId)
    .eq("level", level)
    .order("order_index");
  return (data ?? []) as PlacementQuestionWithAnswer[];
}

/** Fetch questions WITHOUT answers (shuffled options) for the client. */
export async function getQuestionsForClient(
  languageId: number,
  level: string,
): Promise<PlacementQuestion[]> {
  const rows = await getQuestionsWithAnswers(languageId, level);
  return rows.map((r) => {
    if (r.category === "vocabulary" || r.category === "listening") {
      const options = [r.correct_answer, ...r.wrong_answers];
      // Deterministic shuffle by question id so revisits look the same
      const shuffled = stableShuffle(options, r.id);
      return {
        id: r.id,
        category: r.category,
        question: r.question,
        options: shuffled,
        hint: r.hint,
        order_index: r.order_index,
      };
    }
    return {
      id: r.id,
      category: r.category,
      question: r.question,
      hint: r.hint,
      order_index: r.order_index,
    };
  });
}

function stableShuffle<T>(arr: T[], seed: number): T[] {
  const out = [...arr];
  let s = seed;
  for (let i = out.length - 1; i > 0; i--) {
    s = (s * 9301 + 49297) % 233280;
    const j = Math.floor((s / 233280) * (i + 1));
    [out[i], out[j]] = [out[j], out[i]];
  }
  return out;
}

export async function hasPaid(
  userId: string,
  languageId: number,
  level: string,
): Promise<boolean> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("placement_exam_payments")
    .select("id")
    .eq("user_id", userId)
    .eq("language_id", languageId)
    .eq("level", level)
    .limit(1);
  return (data?.length ?? 0) > 0;
}

export async function getLastAttempt(
  userId: string,
  languageId: number,
  level: string,
): Promise<PlacementAttempt | null> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("placement_exam_attempts")
    .select("*")
    .eq("user_id", userId)
    .eq("language_id", languageId)
    .eq("level", level)
    .order("completed_at", { ascending: false })
    .limit(1)
    .maybeSingle();
  return (data as PlacementAttempt | null) ?? null;
}

export async function getLanguageIdBySlug(slug: string): Promise<number | null> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("languages")
    .select("id")
    .eq("code", slug)
    .maybeSingle();
  return (data as { id: number } | null)?.id ?? null;
}

export async function getAllAttemptsForUser(userId: string): Promise<
  (PlacementAttempt & { language: { code: string; name: string } })[]
> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("placement_exam_attempts")
    .select("*, languages!inner(code, name)")
    .eq("user_id", userId)
    .order("completed_at", { ascending: false });
  return ((data ?? []) as Array<
    PlacementAttempt & {
      languages: { code: string; name: string } | { code: string; name: string }[];
    }
  >).map((row) => ({
    ...row,
    language: Array.isArray(row.languages) ? row.languages[0] : row.languages,
  }));
}

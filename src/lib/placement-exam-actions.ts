"use server";

import { createClient } from "@/lib/supabase/server";
import { isCurrentUserPremium } from "@/lib/learn";
import {
  EXAM_DURATION_SECONDS,
  PASSING_PERCENTAGE,
  getLanguageIdBySlug,
  getQuestionsWithAnswers,
  hasPaid,
  type ExamCategory,
} from "@/lib/placement-exam";

export interface ExamAnswer {
  question_id: number;
  answer: string; // user's typed/picked/transcribed answer
}

export interface SubmitResult {
  ok: boolean;
  attempt_id?: string;
  score_percentage?: number;
  passed?: boolean;
  vocabulary_score?: number;
  listening_score?: number;
  speaking_score?: number;
  writing_score?: number;
  error?: string;
}

function normalize(s: string): string {
  return s
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/[^a-z0-9 ]/g, "")
    .replace(/\s+/g, " ")
    .trim();
}

function matches(category: ExamCategory, expected: string, given: string): boolean {
  const a = normalize(expected);
  const b = normalize(given);
  if (!a) return false;
  if (a === b) return true;
  // Speaking + writing get fuzzier matching (the speech engine and typing
  // both produce minor variations of the same phrase).
  if (category === "speaking" || category === "writing") {
    return a.includes(b) || b.includes(a);
  }
  return false;
}

export async function submitPlacementExam(
  languageSlug: string,
  level: string,
  answers: ExamAnswer[],
  timeTakenSeconds: number,
): Promise<SubmitResult> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: "Not authenticated" };

  const languageId = await getLanguageIdBySlug(languageSlug);
  if (!languageId) return { ok: false, error: "Unknown language" };

  // Gate: user must be Premium OR have paid for this exam.
  const isPremium = await isCurrentUserPremium();
  const paid = isPremium || (await hasPaid(user.id, languageId, level));
  if (!paid) return { ok: false, error: "Payment required" };

  const questions = await getQuestionsWithAnswers(languageId, level);
  if (questions.length === 0) {
    return { ok: false, error: "Exam has no questions" };
  }
  const byId = new Map(questions.map((q) => [q.id, q]));
  const answerById = new Map(answers.map((a) => [a.question_id, a.answer]));

  const totals: Record<ExamCategory, { right: number; total: number }> = {
    vocabulary: { right: 0, total: 0 },
    listening: { right: 0, total: 0 },
    speaking: { right: 0, total: 0 },
    writing: { right: 0, total: 0 },
  };

  for (const q of questions) {
    totals[q.category].total += 1;
    const given = answerById.get(q.id) ?? "";
    if (matches(q.category, q.correct_answer, given)) {
      totals[q.category].right += 1;
    }
  }

  const totalQuestions = questions.length;
  const totalRight =
    totals.vocabulary.right +
    totals.listening.right +
    totals.speaking.right +
    totals.writing.right;
  const score = Math.round((totalRight / totalQuestions) * 100);
  const passed = score >= PASSING_PERCENTAGE;

  const pct = (cat: ExamCategory) =>
    totals[cat].total === 0
      ? 0
      : Math.round((totals[cat].right / totals[cat].total) * 100);

  const clampedTime = Math.max(0, Math.min(EXAM_DURATION_SECONDS, timeTakenSeconds));

  const { data: inserted, error } = await supabase
    .from("placement_exam_attempts")
    .insert({
      user_id: user.id,
      language_id: languageId,
      level,
      score_percentage: score,
      vocabulary_score: pct("vocabulary"),
      listening_score: pct("listening"),
      speaking_score: pct("speaking"),
      writing_score: pct("writing"),
      passed,
      time_taken_seconds: clampedTime,
    })
    .select("id")
    .maybeSingle();

  if (error) {
    return { ok: false, error: error.message };
  }

  return {
    ok: true,
    attempt_id: (inserted as { id: string } | null)?.id,
    score_percentage: score,
    passed,
    vocabulary_score: pct("vocabulary"),
    listening_score: pct("listening"),
    speaking_score: pct("speaking"),
    writing_score: pct("writing"),
  };
}

// Constants and types that need to be importable from BOTH server and client.
// Anything that pulls in @/lib/supabase/server (next/headers) lives in
// placement-exam.ts and stays server-only.

export const PASSING_PERCENTAGE = 50;
export const COOLDOWN_HOURS = 48;
export const EXAM_DURATION_SECONDS = 45 * 60;

export type ExamCategory = "vocabulary" | "listening" | "speaking" | "writing";

export interface PlacementQuestion {
  id: number;
  category: ExamCategory;
  question: string;
  options?: string[]; // only for vocabulary + listening
  hint: string | null;
  order_index: number;
}

export interface PlacementQuestionWithAnswer extends PlacementQuestion {
  correct_answer: string;
  wrong_answers: string[];
}

export interface PlacementAttempt {
  id: string;
  language_id: number;
  level: string;
  score_percentage: number;
  vocabulary_score: number;
  listening_score: number;
  speaking_score: number;
  writing_score: number;
  passed: boolean;
  completed_at: string;
  time_taken_seconds: number;
  last_attempt_at: string;
}

/** Returns milliseconds until cooldown expires, or 0 if no cooldown. */
export function cooldownRemainingMs(attempt: PlacementAttempt | null): number {
  if (!attempt) return 0;
  if (attempt.passed) return 0;
  const completedAt = new Date(attempt.completed_at).getTime();
  const expiresAt = completedAt + COOLDOWN_HOURS * 60 * 60 * 1000;
  return Math.max(0, expiresAt - Date.now());
}

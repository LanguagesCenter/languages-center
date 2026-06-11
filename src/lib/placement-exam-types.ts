// Constants and types that need to be importable from BOTH server and client.
// Anything that pulls in @/lib/supabase/server (next/headers) lives in
// placement-exam.ts and stays server-only.

export const PASSING_PERCENTAGE = 75;
export const COOLDOWN_HOURS = 48;
export const EXAM_DURATION_SECONDS = 45 * 60;

// Per-attempt question selection. The bank in the DB is 2-3x larger than this;
// we randomly pick this many per category each attempt.
export const PER_ATTEMPT = {
  reading_passage: 1,
  reading_questions: 3,
  vocabulary: 5,
  dialogue: 5,
  listening: 10,
  speaking: 10,
  writing: 10,
} as const;

export type ExamCategory =
  | "reading"
  | "vocabulary"
  | "dialogue"
  | "listening"
  | "speaking"
  | "writing";

export interface DialogueLine {
  speaker: string;
  text: string;
}

export interface ReadingPassageQuestion {
  question: string;
  correct_answer: string;
  wrong_answers: string[];
}

export interface ReadingPassage {
  id: number;
  passage: string;
  // Three MC questions, in order. The client shuffles options per question.
  questions: ReadingPassageQuestion[];
}

export interface PlacementQuestion {
  id: number;
  category: ExamCategory;
  question: string;
  // multiple-choice only (reading-passage Qs travel inside ReadingPassage,
  // so this field is reserved for vocabulary questions).
  options?: string[];
  // dialogue-completion only
  dialogue_lines?: DialogueLine[];
  // speaking only
  topic_prompt?: string;
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
  reading_score: number;
  vocabulary_score: number;
  dialogue_score: number;
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

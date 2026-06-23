// Constants and types that need to be importable from BOTH server and client.
// Anything that pulls in @/lib/supabase/server (next/headers) lives in
// placement-exam.ts and stays server-only.

export const PASSING_PERCENTAGE = 75;
export const COOLDOWN_HOURS = 48;
export const EXAM_DURATION_SECONDS = 45 * 60;

// Per-attempt question selection. The bank in the DB is 2-3x larger than this;
// we randomly pick this many per category each attempt.
//
// A1 and A2 use the listening + speaking format. B1/B2/C1 swap those two
// categories for three roleplay dialogues.
export const PER_ATTEMPT = {
  reading_passage: 1,
  reading_questions: 3,
  vocabulary: 5,
  dialogue: 5,
  listening: 10, // A1/A2 only
  speaking: 4, // A1/A2 only — was 10, reduced so 45 min is comfortable
  roleplay: 3, // B1/B2/C1 only
  writing: 4, // overridden per level by writingCountForLevel below
} as const;

/** Speaking question count (A1/A2 only; B1/B2/C1 use roleplays instead). */
export function speakingCountForLevel(_level: string): number {
  return 4;
}

/** Writing question count: 4 for A1/A2, 5 for B1/B2/C1. */
export function writingCountForLevel(level: string): number {
  return levelUsesRoleplay(level) ? 5 : 4;
}

export const ROLEPLAY_LEVELS: ReadonlyArray<string> = ["B1", "B2", "C1"];

export function levelUsesRoleplay(level: string): boolean {
  return ROLEPLAY_LEVELS.includes(level);
}

export type ExamCategory =
  | "reading"
  | "vocabulary"
  | "dialogue"
  | "listening"
  | "speaking"
  | "roleplay"
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
  roleplay_score: number;
  writing_score: number;
  passed: boolean;
  completed_at: string;
  time_taken_seconds: number;
  last_attempt_at: string;
}

/** One roleplay scenario from the bank. */
export interface RoleplayScenario {
  id: number;
  topic_label: string;
  scenario: string;
  user_role: string;
  ai_role: string;
  ai_opener: string;
  target_exchanges: number;
}

/** Returns milliseconds until cooldown expires, or 0 if no cooldown. */
export function cooldownRemainingMs(attempt: PlacementAttempt | null): number {
  if (!attempt) return 0;
  if (attempt.passed) return 0;
  const completedAt = new Date(attempt.completed_at).getTime();
  const expiresAt = completedAt + COOLDOWN_HOURS * 60 * 60 * 1000;
  return Math.max(0, expiresAt - Date.now());
}

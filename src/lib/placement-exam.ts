import "server-only";
import { createClient } from "@/lib/supabase/server";
import {
  PER_ATTEMPT,
  type ExamCategory,
  type PlacementQuestion,
  type PlacementAttempt,
  type ReadingPassage,
  type ReadingPassageQuestion,
  type DialogueLine,
} from "@/lib/placement-exam-types";

// Re-export shared bits so server-side imports keep working.
export {
  PASSING_PERCENTAGE,
  COOLDOWN_HOURS,
  EXAM_DURATION_SECONDS,
  PER_ATTEMPT,
  cooldownRemainingMs,
} from "@/lib/placement-exam-types";
export type {
  ExamCategory,
  PlacementQuestion,
  PlacementQuestionWithAnswer,
  PlacementAttempt,
  ReadingPassage,
  ReadingPassageQuestion,
  DialogueLine,
} from "@/lib/placement-exam-types";

/** Full payload returned to the client when starting an exam. */
export interface ExamPayload {
  passage: ReadingPassage;
  questions: PlacementQuestion[];
}

// Internal: full row coming back from Supabase. Wider than
// PlacementQuestionWithAnswer (nullable DB columns).
interface QuestionRow {
  id: number;
  category: ExamCategory;
  question: string;
  correct_answer: string;
  wrong_answers: string[];
  topic_prompt: string | null;
  dialogue_lines: DialogueLine[] | null;
  order_index: number;
}

function shuffle<T>(arr: T[]): T[] {
  const out = [...arr];
  for (let i = out.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [out[i], out[j]] = [out[j], out[i]];
  }
  return out;
}

function sampleN<T>(arr: T[], n: number): T[] {
  return shuffle(arr).slice(0, Math.min(n, arr.length));
}

/** Fetch every question (with answers) for a level. Server-only. */
async function fetchAllQuestions(
  languageId: number,
  level: string,
): Promise<QuestionRow[]> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("placement_exam_questions")
    .select(
      "id, category, question, correct_answer, wrong_answers, topic_prompt, dialogue_lines, order_index",
    )
    .eq("language_id", languageId)
    .eq("level", level)
    .order("order_index");
  return (data ?? []) as QuestionRow[];
}

/** Fetch reading passages for a level. */
async function fetchPassages(
  languageId: number,
  level: string,
): Promise<ReadingPassage[]> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("placement_exam_reading_passages")
    .select("id, passage, comprehension_questions")
    .eq("language_id", languageId)
    .eq("level", level);
  return ((data ?? []) as Array<{
    id: number;
    passage: string;
    comprehension_questions: ReadingPassageQuestion[];
  }>).map((row) => ({
    id: row.id,
    passage: row.passage,
    questions: row.comprehension_questions,
  }));
}

/** Build a fresh randomized exam payload. */
export async function buildExamPayload(
  languageId: number,
  level: string,
): Promise<ExamPayload | null> {
  const [allQuestions, allPassages] = await Promise.all([
    fetchAllQuestions(languageId, level),
    fetchPassages(languageId, level),
  ]);
  if (allQuestions.length === 0 || allPassages.length === 0) return null;

  const byCat = (cat: ExamCategory) =>
    allQuestions.filter((q) => q.category === cat);

  const vocab = sampleN(byCat("vocabulary"), PER_ATTEMPT.vocabulary);
  const dialogue = sampleN(byCat("dialogue"), PER_ATTEMPT.dialogue);
  const listening = sampleN(byCat("listening"), PER_ATTEMPT.listening);
  const speaking = sampleN(byCat("speaking"), PER_ATTEMPT.speaking);
  const writing = sampleN(byCat("writing"), PER_ATTEMPT.writing);

  const passage = sampleN(allPassages, 1)[0];

  // Order matters for the exam flow:
  //   1) Reading passage + comprehension (handled in the UI separately)
  //   2) Vocabulary (5)
  //   3) Dialogue (5)
  //   4) Listening (10)
  //   5) Speaking (10)
  //   6) Writing (10)
  const ordered = [...vocab, ...dialogue, ...listening, ...speaking, ...writing];
  const questions: PlacementQuestion[] = ordered.map((row) => stripAnswer(row));

  return { passage, questions };
}

function stripAnswer(row: QuestionRow): PlacementQuestion {
  const base: PlacementQuestion = {
    id: row.id,
    category: row.category,
    question: row.question,
    order_index: row.order_index,
  };
  if (row.category === "vocabulary") {
    const options = shuffle([row.correct_answer, ...row.wrong_answers]);
    base.options = options;
  } else if (row.category === "dialogue") {
    base.dialogue_lines = row.dialogue_lines ?? [];
  } else if (row.category === "speaking") {
    base.topic_prompt = row.topic_prompt ?? row.question;
  }
  return base;
}

/** Look up a single question with its answer (server-side scoring). */
export async function getQuestionWithAnswer(
  questionId: number,
): Promise<QuestionRow | null> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("placement_exam_questions")
    .select(
      "id, category, question, correct_answer, wrong_answers, topic_prompt, dialogue_lines, order_index",
    )
    .eq("id", questionId)
    .maybeSingle();
  return (data as QuestionRow | null) ?? null;
}

/** Look up a single reading passage. */
export async function getReadingPassage(
  passageId: number,
): Promise<ReadingPassage | null> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("placement_exam_reading_passages")
    .select("id, passage, comprehension_questions")
    .eq("id", passageId)
    .maybeSingle();
  if (!data) return null;
  const row = data as {
    id: number;
    passage: string;
    comprehension_questions: ReadingPassageQuestion[];
  };
  return {
    id: row.id,
    passage: row.passage,
    questions: row.comprehension_questions,
  };
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

/** One row in the post-exam review view. */
export interface ReviewItem {
  id: string;
  category: ExamCategory;
  /** The text shown to the candidate (full sentence stem or topic prompt). */
  prompt: string;
  /** Extra context: dialogue lines joined, passage text, or null. */
  context: string | null;
  /** User's typed/spoken response. */
  user_response: string;
  /** 0-10 grading. */
  score: number;
  /** AI feedback (or "Correct."/"Expected: …" for deterministic MC). */
  feedback: string | null;
  /** The expected MC answer (vocabulary + reading); null for AI-graded. */
  correct_answer: string | null;
}

/** Load all per-question responses for a single attempt, ordered logically. */
export async function getAttemptReview(
  attemptId: string,
  userId: string,
): Promise<ReviewItem[]> {
  const supabase = await createClient();

  // RLS guards this already, but double-check ownership server-side.
  const { data: attempt } = await supabase
    .from("placement_exam_attempts")
    .select("id, user_id")
    .eq("id", attemptId)
    .maybeSingle();
  if (!attempt || (attempt as { user_id: string }).user_id !== userId) {
    return [];
  }

  const { data: rows } = await supabase
    .from("placement_exam_attempt_responses")
    .select(
      "id, category, question_id, passage_id, passage_question_index, user_response, score, feedback, created_at",
    )
    .eq("attempt_id", attemptId)
    .order("created_at");
  const responseRows = (rows ?? []) as Array<{
    id: number;
    category: ExamCategory;
    question_id: number | null;
    passage_id: number | null;
    passage_question_index: number | null;
    user_response: string;
    score: number;
    feedback: string | null;
  }>;

  // Pull the question rows in one shot.
  const questionIds = Array.from(
    new Set(
      responseRows
        .map((r) => r.question_id)
        .filter((id): id is number => id != null),
    ),
  );
  const passageIds = Array.from(
    new Set(
      responseRows
        .map((r) => r.passage_id)
        .filter((id): id is number => id != null),
    ),
  );

  const [questionsResp, passagesResp] = await Promise.all([
    questionIds.length === 0
      ? Promise.resolve({ data: [] })
      : supabase
          .from("placement_exam_questions")
          .select(
            "id, category, question, correct_answer, topic_prompt, dialogue_lines",
          )
          .in("id", questionIds),
    passageIds.length === 0
      ? Promise.resolve({ data: [] })
      : supabase
          .from("placement_exam_reading_passages")
          .select("id, passage, comprehension_questions")
          .in("id", passageIds),
  ]);

  type Q = {
    id: number;
    category: ExamCategory;
    question: string;
    correct_answer: string;
    topic_prompt: string | null;
    dialogue_lines: Array<{ speaker: string; text: string }> | null;
  };
  type P = {
    id: number;
    passage: string;
    comprehension_questions: ReadingPassageQuestion[];
  };
  const qById = new Map(
    ((questionsResp.data ?? []) as Q[]).map((q) => [q.id, q]),
  );
  const pById = new Map(
    ((passagesResp.data ?? []) as P[]).map((p) => [p.id, p]),
  );

  // Logical display order: reading → vocab → dialogue → listening → speaking → writing.
  const order: ExamCategory[] = [
    "reading",
    "vocabulary",
    "dialogue",
    "listening",
    "speaking",
    "writing",
  ];

  const items: ReviewItem[] = responseRows.map((r) => {
    if (r.category === "reading" && r.passage_id != null) {
      const p = pById.get(r.passage_id);
      const idx = r.passage_question_index ?? 0;
      const cq = p?.comprehension_questions[idx];
      return {
        id: String(r.id),
        category: "reading",
        prompt: cq?.question ?? "(reading comprehension question)",
        context: p?.passage ?? null,
        user_response: r.user_response,
        score: r.score,
        feedback: r.feedback,
        correct_answer: cq?.correct_answer ?? null,
      };
    }
    const q = r.question_id != null ? qById.get(r.question_id) : null;
    let context: string | null = null;
    let prompt = q?.question ?? "(question)";
    if (q?.category === "dialogue" && q.dialogue_lines) {
      context = q.dialogue_lines
        .map((l) => `${l.speaker}: ${l.text === "___" ? "________" : l.text}`)
        .join("\n");
    } else if (q?.category === "speaking" && q.topic_prompt) {
      prompt = q.topic_prompt;
    }
    return {
      id: String(r.id),
      category: r.category,
      prompt,
      context,
      user_response: r.user_response,
      score: r.score,
      feedback: r.feedback,
      correct_answer:
        r.category === "vocabulary" ? q?.correct_answer ?? null : null,
    };
  });

  items.sort((a, b) => order.indexOf(a.category) - order.indexOf(b.category));
  return items;
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

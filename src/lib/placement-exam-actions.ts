"use server";

import { createClient } from "@/lib/supabase/server";
import { isCurrentUserPremium } from "@/lib/learn";
import {
  EXAM_DURATION_SECONDS,
  PASSING_PERCENTAGE,
  getLanguageIdBySlug,
  getQuestionWithAnswer,
  getReadingPassage,
  getRoleplayScenario,
  hasPaid,
  type ExamCategory,
} from "@/lib/placement-exam";
import { gradeResponse, type GradeType } from "@/lib/grade-response";

/** Per-question response sent up by the client. */
export interface ExamAnswer {
  question_id: number;
  answer: string;
}

/** Per-reading-passage-question response. */
export interface ReadingAnswer {
  passage_id: number;
  question_index: number;
  answer: string;
}

/** Full transcript for one of the three roleplay scenarios. */
export interface RoleplayTranscript {
  roleplay_id: number;
  /** Conversation log; AI's opener first, alternating thereafter. */
  turns: Array<{ role: "user" | "ai"; text: string }>;
}

export interface SubmitResult {
  ok: boolean;
  attempt_id?: string;
  score_percentage?: number;
  passed?: boolean;
  reading_score?: number;
  vocabulary_score?: number;
  dialogue_score?: number;
  listening_score?: number;
  speaking_score?: number;
  roleplay_score?: number;
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

function mcMatches(expected: string, given: string): boolean {
  const a = normalize(expected);
  const b = normalize(given);
  return a.length > 0 && a === b;
}

const GRADING_CONCURRENCY = 4;

async function gradeInParallel<T, R>(
  items: T[],
  worker: (item: T) => Promise<R>,
): Promise<R[]> {
  const out: R[] = new Array(items.length);
  let next = 0;
  async function run() {
    while (true) {
      const i = next++;
      if (i >= items.length) return;
      out[i] = await worker(items[i]);
    }
  }
  const workers = Array.from(
    { length: Math.min(GRADING_CONCURRENCY, items.length) },
    () => run(),
  );
  await Promise.all(workers);
  return out;
}

export async function submitPlacementExam(
  languageSlug: string,
  level: string,
  passageId: number,
  readingAnswers: ReadingAnswer[],
  answers: ExamAnswer[],
  roleplayTranscripts: RoleplayTranscript[],
  timeTakenSeconds: number,
): Promise<SubmitResult> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: "Not authenticated" };

  const languageId = await getLanguageIdBySlug(languageSlug);
  if (!languageId) return { ok: false, error: "Unknown language" };

  const isPremium = await isCurrentUserPremium();
  const paid = isPremium || (await hasPaid(user.id, languageId, level));
  if (!paid) return { ok: false, error: "Payment required" };

  const passage = await getReadingPassage(passageId);
  if (!passage) return { ok: false, error: "Reading passage missing" };

  // ---- Score reading passage (3 MC questions) ----
  const readingPerQuestion: Array<{
    score: number;
    feedback: string;
    question_index: number;
    user_response: string;
  }> = [];
  let readingRight = 0;
  for (let i = 0; i < passage.questions.length; i++) {
    const expected = passage.questions[i].correct_answer;
    const given =
      readingAnswers.find((a) => a.question_index === i)?.answer ?? "";
    const ok = mcMatches(expected, given);
    if (ok) readingRight += 1;
    readingPerQuestion.push({
      score: ok ? 10 : 0,
      feedback: ok ? "Correct." : `Expected: ${expected}`,
      question_index: i,
      user_response: given,
    });
  }
  const readingTotal = passage.questions.length;

  // ---- Fetch all answered question rows ----
  const questionIds = answers.map((a) => a.question_id);
  const rows = await Promise.all(
    questionIds.map((id) => getQuestionWithAnswer(id)),
  );
  const rowsById = new Map(
    rows.filter((r): r is NonNullable<typeof r> => r != null).map((r) => [r.id, r]),
  );

  // ---- Vocabulary (deterministic MC scoring) ----
  const vocab = answers
    .map((a) => ({ a, q: rowsById.get(a.question_id) }))
    .filter((x) => x.q && x.q.category === "vocabulary");
  const vocabPerQuestion = vocab.map(({ a, q }) => {
    const ok = mcMatches(q!.correct_answer, a.answer);
    return {
      question_id: q!.id,
      category: "vocabulary" as const,
      score: ok ? 10 : 0,
      feedback: ok ? "Correct." : `Expected: ${q!.correct_answer}`,
      user_response: a.answer,
    };
  });
  const vocabRight = vocabPerQuestion.filter((x) => x.score === 10).length;
  const vocabTotal = vocabPerQuestion.length;

  // ---- AI-graded categories ----
  type AIItem = {
    a: ExamAnswer;
    q: NonNullable<ReturnType<typeof rowsById.get>>;
    type: GradeType;
    promptForGrader: string;
  };
  const aiCats: ExamCategory[] = ["dialogue", "listening", "speaking", "writing"];
  const aiItems: AIItem[] = answers
    .map((a) => ({ a, q: rowsById.get(a.question_id) }))
    .filter((x): x is { a: ExamAnswer; q: NonNullable<typeof x.q> } =>
      x.q != null && (aiCats as string[]).includes(x.q.category),
    )
    .map(({ a, q }) => {
      let type: GradeType;
      let promptForGrader: string;
      if (q.category === "dialogue") {
        type = "dialogue";
        const lines = (q.dialogue_lines ?? []) as Array<{
          speaker: string;
          text: string;
        }>;
        const dialogueText = lines
          .map((l) => `${l.speaker}: ${l.text}`)
          .join("\n");
        promptForGrader = `Complete this dialogue. The candidate types the last line.\n\n${dialogueText}\n\nReference response: ${q.correct_answer}`;
      } else if (q.category === "listening") {
        type = "listening";
        const langTitle =
          languageSlug.charAt(0).toUpperCase() + languageSlug.slice(1);
        promptForGrader = `Audio prompt (${langTitle}): ${q.question}\nReference response: ${q.correct_answer}`;
      } else if (q.category === "speaking") {
        type = "speaking";
        promptForGrader = q.topic_prompt ?? q.question;
      } else {
        type = "writing";
        promptForGrader = q.question;
      }
      return { a, q, type, promptForGrader };
    });

  const aiResults = await gradeInParallel(aiItems, async (item) => {
    const result = await gradeResponse({
      prompt: item.promptForGrader,
      response: item.a.answer,
      level,
      type: item.type,
      language: languageSlug,
    });
    return { item, ...result };
  });

  // ---- Roleplay grading ----
  type RoleplayGraded = {
    roleplay_id: number;
    score: number;
    feedback: string;
    transcript: RoleplayTranscript["turns"];
  };
  const roleplayResults: RoleplayGraded[] = [];
  if (roleplayTranscripts.length > 0) {
    const scenariosNullable = await Promise.all(
      roleplayTranscripts.map((t) => getRoleplayScenario(t.roleplay_id)),
    );
    const scenarios = scenariosNullable.map((s, i) => ({
      transcript: roleplayTranscripts[i],
      scenario: s,
    }));
    const graded = await gradeInParallel(scenarios, async ({ transcript, scenario }) => {
      if (!scenario) {
        return {
          roleplay_id: transcript.roleplay_id,
          score: 0,
          feedback: "Roleplay scenario could not be found.",
          transcript: transcript.turns,
        };
      }
      const transcriptStr = transcript.turns
        .map((t) => `${t.role === "ai" ? "AI" : "User"}: ${t.text}`)
        .join("\n");
      const prompt = [
        `Roleplay topic: ${scenario.topic_label}`,
        `Scenario: ${scenario.scenario}`,
        `Candidate role: ${scenario.user_role}`,
        `AI role: ${scenario.ai_role}`,
        `Target user turns: ${scenario.target_exchanges}`,
        "",
        "Transcript:",
        transcriptStr,
      ].join("\n");
      const result = await gradeResponse({
        prompt,
        response: transcriptStr,
        level,
        type: "roleplay",
        language: languageSlug,
      });
      return {
        roleplay_id: transcript.roleplay_id,
        score: result.score,
        feedback: result.feedback,
        transcript: transcript.turns,
      };
    });
    roleplayResults.push(...graded);
  }
  const roleplaySum = roleplayResults.reduce((acc, r) => acc + r.score, 0);
  const roleplayCount = roleplayResults.length;

  type CatTotals = { sum: number; count: number };
  const catTotals: Record<ExamCategory, CatTotals> = {
    reading: { sum: readingRight * 10, count: readingTotal },
    vocabulary: { sum: vocabRight * 10, count: vocabTotal },
    dialogue: { sum: 0, count: 0 },
    listening: { sum: 0, count: 0 },
    speaking: { sum: 0, count: 0 },
    roleplay: { sum: roleplaySum, count: roleplayCount },
    writing: { sum: 0, count: 0 },
  };
  for (const r of aiResults) {
    const cat = r.item.q.category;
    catTotals[cat].sum += r.score;
    catTotals[cat].count += 1;
  }

  // ---- Compose overall score (each question worth 10, percentage across all) ----
  const totalSum =
    catTotals.reading.sum +
    catTotals.vocabulary.sum +
    catTotals.dialogue.sum +
    catTotals.listening.sum +
    catTotals.speaking.sum +
    catTotals.roleplay.sum +
    catTotals.writing.sum;
  const totalMax =
    (catTotals.reading.count +
      catTotals.vocabulary.count +
      catTotals.dialogue.count +
      catTotals.listening.count +
      catTotals.speaking.count +
      catTotals.roleplay.count +
      catTotals.writing.count) *
    10;
  const scorePct = totalMax > 0 ? Math.round((totalSum / totalMax) * 100) : 0;
  const passed = scorePct >= PASSING_PERCENTAGE;
  const catPct = (cat: ExamCategory) =>
    catTotals[cat].count === 0
      ? 0
      : Math.round((catTotals[cat].sum / (catTotals[cat].count * 10)) * 100);

  const clampedTime = Math.max(0, Math.min(EXAM_DURATION_SECONDS, timeTakenSeconds));

  // ---- Persist ----
  const { data: inserted, error } = await supabase
    .from("placement_exam_attempts")
    .insert({
      user_id: user.id,
      language_id: languageId,
      level,
      score_percentage: scorePct,
      reading_score: catPct("reading"),
      vocabulary_score: catPct("vocabulary"),
      dialogue_score: catPct("dialogue"),
      listening_score: catPct("listening"),
      speaking_score: catPct("speaking"),
      roleplay_score: catPct("roleplay"),
      writing_score: catPct("writing"),
      passed,
      time_taken_seconds: clampedTime,
    })
    .select("id")
    .maybeSingle();

  if (error) return { ok: false, error: error.message };
  const attemptId = (inserted as { id: string } | null)?.id;
  if (!attemptId) return { ok: false, error: "Could not record attempt" };

  // Best-effort per-question persistence (don't fail the whole submit on this).
  const responseRows: Array<Record<string, unknown>> = [];
  for (const r of readingPerQuestion) {
    responseRows.push({
      attempt_id: attemptId,
      question_id: null,
      passage_id: passage.id,
      passage_question_index: r.question_index,
      category: "reading",
      user_response: r.user_response,
      score: r.score,
      feedback: r.feedback,
    });
  }
  for (const r of vocabPerQuestion) {
    responseRows.push({
      attempt_id: attemptId,
      question_id: r.question_id,
      passage_id: null,
      passage_question_index: null,
      category: r.category,
      user_response: r.user_response,
      score: r.score,
      feedback: r.feedback,
    });
  }
  for (const r of aiResults) {
    responseRows.push({
      attempt_id: attemptId,
      question_id: r.item.q.id,
      passage_id: null,
      passage_question_index: null,
      category: r.item.q.category,
      user_response: r.item.a.answer,
      score: r.score,
      feedback: r.feedback,
    });
  }
  if (responseRows.length > 0) {
    const { error: respErr } = await supabase
      .from("placement_exam_attempt_responses")
      .insert(responseRows);
    if (respErr) {
      console.error("[placement-exam] response persistence failed:", respErr.message);
    }
  }

  if (roleplayResults.length > 0) {
    const { error: rpErr } = await supabase
      .from("placement_exam_attempt_roleplays")
      .insert(
        roleplayResults.map((r) => ({
          attempt_id: attemptId,
          roleplay_id: r.roleplay_id,
          transcript: r.transcript,
          score: r.score,
          feedback: r.feedback,
        })),
      );
    if (rpErr) {
      console.error(
        "[placement-exam] roleplay persistence failed:",
        rpErr.message,
      );
    }
  }

  return {
    ok: true,
    attempt_id: attemptId,
    score_percentage: scorePct,
    passed,
    reading_score: catPct("reading"),
    vocabulary_score: catPct("vocabulary"),
    dialogue_score: catPct("dialogue"),
    listening_score: catPct("listening"),
    speaking_score: catPct("speaking"),
    roleplay_score: catPct("roleplay"),
    writing_score: catPct("writing"),
  };
}

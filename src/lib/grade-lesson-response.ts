import "server-only";

// Server-only helper that grades a writing / speaking / listening response
// inside a lesson via the Anthropic Messages API. Designed to be reusable
// across all CEFR levels and any language.

export type LessonGradeType = "writing" | "speaking" | "listening";

export interface GradeLessonArgs {
  type: LessonGradeType;
  /** The exercise prompt the user was responding to. */
  prompt: string;
  /** Candidate's typed response or speech-to-text transcript. */
  response: string;
  /** CEFR target: A1 | A2 | B1 | B2 | C1. */
  level: string;
  /** Section name (e.g. "Greetings") — used for grading context. */
  section: string;
  /** 1-based lesson position inside its section. */
  lessonNumber: number;
  /** Target language slug (e.g. "spanish"). */
  language: string;
}

export interface GradeLessonResult {
  /** 0..10 integer. */
  score: number;
  /** Short paragraph of constructive feedback. */
  feedback: string;
  /** True when score >= 6 (the lesson pass mark). */
  passed: boolean;
  /** What a native speaker would write/say in the same situation. */
  correctedVersion: string;
  /** Short encouraging sentence ("Great effort!" etc.). */
  encouragement: string;
}

const ANTHROPIC_URL = "https://api.anthropic.com/v1/messages";
const MODEL = "claude-sonnet-4-6";
const PASS_MARK = 6;

function levelGuidance(level: string, language: string): string {
  const a2Connectors =
    language === "french"
      ? "et, mais, parce que, quand"
      : "porque, pero, cuando";
  const c1Markers =
    language === "french"
      ? "il convient de souligner, nonobstant, par ailleurs, de surcroît"
      : "cabe destacar, en virtud de, lejos de";
  switch (level.toUpperCase()) {
    case "A1":
      return [
        "Target level CEFR A1.",
        "Be lenient. Expect very short, simple sentences in the present tense, a basic vocabulary, and frequent errors.",
        "Reward any attempt that communicates the basic idea — small grammatical mistakes (gender, agreement, missing accents) should NOT drop the score below 6 if meaning is clear.",
      ].join(" ");
    case "A2":
      return [
        "Target level CEFR A2.",
        "Slightly stricter than A1. Expect connected sentences, basic past/future tenses, and a richer everyday vocabulary.",
        `Reward learners who use common connectors (${a2Connectors}) and attempt full sentences.`,
      ].join(" ");
    case "B1":
      return [
        "Target level CEFR B1.",
        "Intermediate. Expect paragraphs on familiar topics, past/imperfect contrasts, the present perfect, and basic subjunctive after expressions of wish or emotion.",
        "Expect the learner to express opinions with simple justifications. Score down if responses are A2-level for a B1 task.",
      ].join(" ");
    case "B2":
      return [
        "Target level CEFR B2.",
        "Upper intermediate. Expect detailed, clearly organised text on a wide range of topics, complex sentences, subjunctive in concessions and hypotheticals, type-2 and type-3 conditionals, and sophisticated connectors.",
        "Errors should not impede meaning. Vocabulary should be precise. Be more critical than at B1.",
      ].join(" ");
    case "C1":
      return [
        "Target level CEFR C1.",
        `Advanced. Expect nuanced, idiomatic, register-appropriate language with advanced subjunctive, complex passive constructions, cleft sentences, discourse markers (${c1Markers}...), and elegant rephrasing.`,
        "Grade strictly: errors should be rare and not affect clarity. Reward rhetorical sophistication and natural register.",
      ].join(" ");
    default:
      return "Grade for general accuracy and clarity.";
  }
}

function typeGuidance(type: LessonGradeType): string {
  switch (type) {
    case "writing":
      return [
        "The candidate wrote a short text in response to a prompt.",
        "Grade on (1) grammar accuracy weighted 40%, (2) vocabulary appropriateness for the target level weighted 30%, (3) task completion weighted 30%.",
        "Penalise responses written in the wrong language or that ignore the prompt.",
      ].join(" ");
    case "speaking":
      return [
        "The candidate's response is a speech-to-text transcript of a spoken answer.",
        "Transcription artefacts (missing accents, no punctuation, occasional missing or duplicated words) are expected — focus on grammar, vocabulary range, sentence variety, and fluency indicators rather than spelling.",
        "Grade on (1) grammar accuracy weighted 40%, (2) vocabulary appropriateness weighted 30%, (3) task completion weighted 30%.",
      ].join(" ");
    case "listening":
      return [
        "The candidate listened to a target-language audio prompt and typed a response.",
        "Grade primarily on comprehension (did the response engage with what was heard?) and on the grammatical and lexical quality of the reply for the level.",
      ].join(" ");
  }
}

function buildSystemPrompt(args: GradeLessonArgs): string {
  return [
    `You grade ${args.language.toLowerCase()} lesson responses.`,
    `Course context: section "${args.section}", lesson ${args.lessonNumber}.`,
    levelGuidance(args.level, args.language.toLowerCase()),
    typeGuidance(args.type),
    `Pass mark is ${PASS_MARK}/10.`,
    "",
    "Return STRICTLY a single JSON object on one line with this exact shape and no other text:",
    '{"score": <integer 0..10>, "feedback": "<2-3 short sentences in English: one specific praise, one specific area to improve>", "correctedVersion": "<what a native speaker would naturally write or say in the target language — 1-3 sentences>", "encouragement": "<one short upbeat sentence in English chosen from: \\"Great effort!\\", \\"You are making progress!\\", \\"Keep practising!\\", \\"Excellent work!\\", \\"Almost there!\\"; pick one that fits the score>"}',
    "",
    "Feedback rules:",
    "- Always be constructive and encouraging, even for low scores.",
    "- Be specific. Reference an actual word, tense, or structure from the response.",
    "- Do NOT include the score, the percentage, or the pass mark in the feedback string itself.",
    "- correctedVersion must be in the target language (NOT English). If the candidate's response is decent already, you may copy it lightly polished.",
    "",
    "Do NOT wrap the JSON in code fences. Return ONLY the object.",
  ].join("\n");
}

function buildUserPrompt(args: GradeLessonArgs): string {
  return [
    `Prompt shown to candidate:\n${args.prompt}`,
    "",
    `Candidate response:\n${args.response.trim() || "(empty)"}`,
  ].join("\n");
}

function clampScore(n: unknown): number {
  if (typeof n !== "number" || !Number.isFinite(n)) return 0;
  return Math.max(0, Math.min(10, Math.round(n)));
}

function asString(v: unknown, fallback: string): string {
  return typeof v === "string" && v.trim().length > 0 ? v.trim() : fallback;
}

function parseClaudeJson(text: string): GradeLessonResult | null {
  const match = text.match(/\{[\s\S]*\}/);
  if (!match) return null;
  try {
    const obj = JSON.parse(match[0]) as Record<string, unknown>;
    const score = clampScore(obj.score);
    return {
      score,
      feedback: asString(obj.feedback, "Keep going — you're learning."),
      passed: score >= PASS_MARK,
      correctedVersion: asString(obj.correctedVersion, ""),
      encouragement: asString(obj.encouragement, "Keep practising!"),
    };
  } catch {
    return null;
  }
}

/** Fallback used when the API key is missing or Claude is unreachable. */
function neutralResult(): GradeLessonResult {
  return {
    score: 5,
    feedback:
      "We couldn't auto-grade this response right now. A neutral score was recorded; please try again later for detailed feedback.",
    passed: false,
    correctedVersion: "",
    encouragement: "Keep practising!",
  };
}

export async function gradeLessonResponse(
  args: GradeLessonArgs,
): Promise<GradeLessonResult> {
  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) {
    console.error("[grade-lesson-response] ANTHROPIC_API_KEY is not set");
    return neutralResult();
  }
  if (!args.response.trim()) {
    return {
      score: 0,
      feedback: "No response was provided.",
      passed: false,
      correctedVersion: "",
      encouragement: "Have another go!",
    };
  }

  const res = await fetch(ANTHROPIC_URL, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      "x-api-key": apiKey,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({
      model: MODEL,
      max_tokens: 500,
      system: buildSystemPrompt(args),
      messages: [{ role: "user", content: buildUserPrompt(args) }],
    }),
  });

  if (!res.ok) {
    const errText = await res.text().catch(() => "");
    console.error(
      `[grade-lesson-response] Anthropic API ${res.status}: ${errText.slice(0, 300)}`,
    );
    return neutralResult();
  }

  const data = (await res.json()) as {
    content?: Array<{ type: string; text?: string }>;
  };
  const text =
    data.content?.find((b) => b.type === "text")?.text?.trim() ?? "";
  const parsed = parseClaudeJson(text);
  if (!parsed) {
    console.error(
      `[grade-lesson-response] Failed to parse output: ${text.slice(0, 200)}`,
    );
    return neutralResult();
  }
  return parsed;
}

export { PASS_MARK as LESSON_GRADING_PASS_MARK };

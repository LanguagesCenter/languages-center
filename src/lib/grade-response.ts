import "server-only";

// Server-only helper for AI grading. The /api/grade-response route delegates
// here, and server actions (placement-exam-actions) also call this directly so
// the request never round-trips through HTTP.

export type GradeType =
  | "writing"
  | "listening"
  | "speaking"
  | "dialogue"
  | "roleplay";

export interface GradeArgs {
  prompt: string;
  response: string;
  level: string;
  type: GradeType;
}

export interface GradeResult {
  score: number;
  feedback: string;
}

const ANTHROPIC_URL = "https://api.anthropic.com/v1/messages";
const MODEL = "claude-haiku-4-5-20251001";

function buildSystemPrompt(level: string, type: GradeType): string {
  const levelDesc =
    level === "A1"
      ? "CEFR A1: basic vocabulary, simple present-tense sentences, common nouns and verbs. Very common errors are expected and acceptable."
      : level === "A2"
        ? "CEFR A2: connected sentences, past/future tenses, common connectors (porque, pero, cuando). Some inaccuracy is fine if meaning is clear."
        : level === "B1"
          ? "CEFR B1: paragraphs on familiar topics, preterite/imperfect contrast, present perfect, basic subjunctive after expressions of wish/emotion. Reasonable accuracy expected."
          : level === "B2"
            ? "CEFR B2: clear, detailed text on a wide range of topics, complex sentences, subjunctive in many contexts (concessions, hypotheticals), conditionals types 2 and 3, sophisticated connectors. Few errors that impede meaning."
            : "CEFR C1: nuanced, idiomatic, register-appropriate Spanish. Advanced subjunctive, complex passive constructions, cleft sentences, discourse markers (cabe destacar, en virtud de), elegant rephrasing. Errors should be rare and not affect clarity.";

  const taskDesc: Record<GradeType, string> = {
    writing:
      "The candidate wrote a short Spanish text in response to an English prompt. Judge relevance to the prompt, grammatical accuracy, vocabulary range and clarity. Reward attempts that address the prompt even with minor errors.",
    listening:
      "The candidate heard a Spanish audio prompt and typed a Spanish response. Judge how well the response answers/reacts to the heard sentence, including grammatical accuracy and vocabulary appropriate to the level.",
    speaking:
      "You are reading a speech-to-text transcript of the candidate's spoken monologue on a topic. Transcription artefacts (punctuation, capitalisation, occasional missing words) are expected — focus on grammar, vocabulary range, fluency indicators (run-ons, hesitations transcribed as filler) and how thoroughly the topic was covered.",
    dialogue:
      "The candidate was shown a short Spanish dialogue with the last line missing, and typed a Spanish line to complete it. Judge whether the response is a plausible, grammatical reply and appropriate for the register.",
    roleplay:
      "The candidate carried out a multi-turn Spanish-language roleplay with an AI partner. You are given the full transcript (labelled AI: and User:). Judge ONLY the candidate's turns on grammar, vocabulary range, fluency, appropriateness to the situation and how well they advanced the conversation. Ignore minor typos and length below the level expectation.",
  };

  return [
    "You grade Spanish-language placement-exam responses.",
    `Target level: ${levelDesc}`,
    `Task type: ${taskDesc[type]}`,
    "",
    "Return strictly a single JSON object on one line with this shape:",
    '{"score": <integer 0..10>, "feedback": "<one short sentence in English, max 25 words>"}',
    "",
    "Score guidance:",
    "  0  — empty, off-topic, or in another language",
    "  1-3 — attempted but mostly incomprehensible or non-Spanish",
    "  4-5 — partly on-topic with major errors that obscure meaning",
    "  6-7 — on-topic, meaning is clear, level-appropriate errors",
    "  8-9 — fully on-topic, accurate grammar, level-appropriate range",
    "  10 — excellent for the target level: accurate, varied, idiomatic",
    "",
    "Do NOT include any other text — only the JSON object.",
  ].join("\n");
}

function buildUserPrompt(prompt: string, response: string): string {
  return [
    `Task prompt:\n${prompt}`,
    "",
    `Candidate response:\n${response.trim() || "(empty)"}`,
  ].join("\n");
}

function clampScore(n: unknown): number {
  if (typeof n !== "number" || !Number.isFinite(n)) return 0;
  return Math.max(0, Math.min(10, Math.round(n)));
}

function parseClaudeJson(text: string): GradeResult | null {
  const match = text.match(/\{[\s\S]*\}/);
  if (!match) return null;
  try {
    const obj = JSON.parse(match[0]) as { score?: unknown; feedback?: unknown };
    return {
      score: clampScore(obj.score),
      feedback:
        typeof obj.feedback === "string" && obj.feedback.trim().length > 0
          ? obj.feedback.trim()
          : "Graded.",
    };
  } catch {
    return null;
  }
}

export async function gradeResponse(args: GradeArgs): Promise<GradeResult> {
  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) {
    console.error("[grade-response] ANTHROPIC_API_KEY is not set");
    return {
      score: 0,
      feedback: "Grading is not configured. Please contact support.",
    };
  }

  const trimmed = args.response.trim();
  if (!trimmed) return { score: 0, feedback: "No response provided." };

  const res = await fetch(ANTHROPIC_URL, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      "x-api-key": apiKey,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({
      model: MODEL,
      max_tokens: 200,
      system: buildSystemPrompt(args.level, args.type),
      messages: [
        { role: "user", content: buildUserPrompt(args.prompt, args.response) },
      ],
    }),
  });

  if (!res.ok) {
    const errText = await res.text().catch(() => "");
    console.error(
      `[grade-response] Anthropic API ${res.status}: ${errText.slice(0, 300)}`,
    );
    return {
      score: 5,
      feedback:
        "Could not auto-grade this response. A neutral score was assigned.",
    };
  }

  const data = (await res.json()) as {
    content?: Array<{ type: string; text?: string }>;
  };
  const text =
    data.content?.find((b) => b.type === "text")?.text?.trim() ?? "";
  const parsed = parseClaudeJson(text);
  if (!parsed) {
    console.error(
      `[grade-response] Failed to parse Claude output: ${text.slice(0, 200)}`,
    );
    return {
      score: 5,
      feedback:
        "Could not auto-grade this response. A neutral score was assigned.",
    };
  }
  return parsed;
}

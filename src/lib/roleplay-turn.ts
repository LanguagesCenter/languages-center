import "server-only";

// Server-only helper that asks Claude for the next AI line in a placement
// exam roleplay. Used by /api/roleplay-turn and (potentially) directly from
// server actions.

export interface RoleplayHistoryItem {
  /** "user" = the candidate, "ai" = the simulated partner. */
  role: "user" | "ai";
  text: string;
}

export interface RoleplayTurnArgs {
  level: string; // "B1" | "B2" | "C1"
  topic: string; // short label, e.g. "Restaurant complaint"
  scenario: string; // Spanish setup paragraph
  user_role: string; // e.g. "Cliente"
  ai_role: string; // e.g. "Camarero"
  /** Conversation so far (AI's opener appears first; user's last turn last). */
  history: RoleplayHistoryItem[];
  /** Target number of USER turns before the AI winds the conversation down. */
  target_exchanges: number;
}

export interface RoleplayTurnResult {
  next_line: string;
  is_final: boolean;
}

const ANTHROPIC_URL = "https://api.anthropic.com/v1/messages";
const MODEL = "claude-haiku-4-5-20251001";

function levelStyle(level: string): string {
  switch (level) {
    case "B1":
      return "CEFR B1: clear, natural Spanish on familiar topics, mostly common vocabulary, present/preterite/imperfect, basic subjunctive.";
    case "B2":
      return "CEFR B2: fluent, detailed Spanish, sophisticated connectors, subjunctive in concessions and hypotheticals, conditionals, idiomatic phrases where natural.";
    case "C1":
      return "CEFR C1: nuanced, idiomatic, register-appropriate Spanish with elegant rephrasing, advanced subjunctive, discourse markers, light humor or rhetorical flourishes where the role permits.";
    default:
      return "CEFR A2: short connected sentences with common vocabulary and basic past/future tenses.";
  }
}

function buildSystemPrompt(args: RoleplayTurnArgs): string {
  const userTurns = args.history.filter((h) => h.role === "user").length;
  const remaining = Math.max(0, args.target_exchanges - userTurns);
  const closingHint =
    remaining <= 1
      ? "The candidate has nearly reached the target number of turns. Begin to wind the conversation down naturally: acknowledge what was said, summarise briefly, and offer a polite closing. After this line the conversation will end."
      : `The candidate still has roughly ${remaining} more turns. Keep the conversation going: react to their last message, add new information, ask a follow-up question. DO NOT close the conversation yet.`;

  return [
    `You are playing the role of ${args.ai_role} in a Spanish-language roleplay called "${args.topic}".`,
    `The candidate plays ${args.user_role}.`,
    `Scenario (in Spanish): ${args.scenario}`,
    "",
    `Speak ONLY in Spanish. Style: ${levelStyle(args.level)}`,
    "Stay in character at all times. Do not break the fourth wall, do not give meta-comments, do not grade or correct the candidate.",
    "Each turn must be a SHORT paragraph — 1 to 3 sentences. Use natural spoken Spanish appropriate to the role.",
    "Vary your turns: sometimes ask a question, sometimes share information, sometimes react with emotion, sometimes propose a compromise. Avoid sounding scripted.",
    closingHint,
    "",
    "Return ONLY a JSON object on one line with this exact shape:",
    '{"next_line": "<Spanish text>", "is_final": <true if you closed the conversation, otherwise false>}',
    "Do not wrap it in code fences. Do not include any other text.",
  ].join("\n");
}

function buildUserMessage(args: RoleplayTurnArgs): string {
  const transcript = args.history
    .map((h) => `${h.role === "ai" ? "AI" : "User"}: ${h.text}`)
    .join("\n");
  return `Transcript so far:\n${transcript}\n\nReply with your next line as ${args.ai_role}.`;
}

function parseTurnJson(text: string): RoleplayTurnResult | null {
  const m = text.match(/\{[\s\S]*\}/);
  if (!m) return null;
  try {
    const obj = JSON.parse(m[0]) as {
      next_line?: unknown;
      is_final?: unknown;
    };
    if (typeof obj.next_line !== "string") return null;
    return {
      next_line: obj.next_line.trim(),
      is_final: obj.is_final === true,
    };
  } catch {
    return null;
  }
}

export async function generateRoleplayTurn(
  args: RoleplayTurnArgs,
): Promise<RoleplayTurnResult> {
  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) {
    console.error("[roleplay-turn] ANTHROPIC_API_KEY is not set");
    return {
      next_line:
        "Lo siento, no puedo continuar la conversación en este momento.",
      is_final: true,
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
      max_tokens: 350,
      system: buildSystemPrompt(args),
      messages: [{ role: "user", content: buildUserMessage(args) }],
    }),
  });

  if (!res.ok) {
    const errText = await res.text().catch(() => "");
    console.error(
      `[roleplay-turn] Anthropic API ${res.status}: ${errText.slice(0, 300)}`,
    );
    return {
      next_line:
        "Disculpe, debemos terminar la conversación aquí por un problema técnico.",
      is_final: true,
    };
  }

  const data = (await res.json()) as {
    content?: Array<{ type: string; text?: string }>;
  };
  const text =
    data.content?.find((b) => b.type === "text")?.text?.trim() ?? "";
  const parsed = parseTurnJson(text);
  if (!parsed) {
    console.error(
      `[roleplay-turn] Failed to parse output: ${text.slice(0, 200)}`,
    );
    return {
      next_line:
        "Disculpe, debemos terminar la conversación aquí por un problema técnico.",
      is_final: true,
    };
  }

  // Force closure when the user is past the target — protect against models
  // that keep dragging the scene on.
  const userTurns = args.history.filter((h) => h.role === "user").length;
  if (userTurns >= args.target_exchanges) {
    parsed.is_final = true;
  }
  return parsed;
}

import { NextRequest } from "next/server";
import {
  generateRoleplayTurn,
  type RoleplayHistoryItem,
} from "@/lib/roleplay-turn";

// POST { level, topic, scenario, user_role, ai_role, history, target_exchanges }
//   -> { next_line: string, is_final: boolean }
//
// Requires ANTHROPIC_API_KEY.

export const runtime = "nodejs";

function asString(v: unknown): string | null {
  return typeof v === "string" && v.length > 0 ? v : null;
}

export async function POST(request: NextRequest) {
  let body: Record<string, unknown>;
  try {
    body = (await request.json()) as Record<string, unknown>;
  } catch {
    return Response.json({ error: "Invalid JSON body" }, { status: 400 });
  }

  const level = asString(body.level);
  const topic = asString(body.topic);
  const scenario = asString(body.scenario);
  const user_role = asString(body.user_role);
  const ai_role = asString(body.ai_role);
  const targetRaw = body.target_exchanges;
  const target_exchanges =
    typeof targetRaw === "number" && Number.isFinite(targetRaw) ? targetRaw : 5;
  const historyRaw = body.history;

  if (!level || !topic || !scenario || !user_role || !ai_role) {
    return Response.json(
      { error: "Missing level, topic, scenario, user_role or ai_role" },
      { status: 400 },
    );
  }
  if (!Array.isArray(historyRaw)) {
    return Response.json(
      { error: "history must be an array" },
      { status: 400 },
    );
  }

  const history: RoleplayHistoryItem[] = [];
  for (const raw of historyRaw) {
    if (
      typeof raw !== "object" ||
      raw === null ||
      typeof (raw as { role?: unknown }).role !== "string" ||
      typeof (raw as { text?: unknown }).text !== "string"
    ) {
      return Response.json(
        { error: "history items must be {role, text}" },
        { status: 400 },
      );
    }
    const role = (raw as { role: string }).role === "ai" ? "ai" : "user";
    history.push({ role, text: (raw as { text: string }).text });
  }

  const language = asString(body.language) ?? undefined;

  const result = await generateRoleplayTurn({
    level,
    topic,
    scenario,
    user_role,
    ai_role,
    history,
    target_exchanges: Math.max(3, Math.min(8, target_exchanges)),
    language,
  });
  return Response.json(result);
}

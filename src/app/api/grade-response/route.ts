import { NextRequest } from "next/server";
import { gradeResponse, type GradeType } from "@/lib/grade-response";

// Server-side grading via the Anthropic Messages API.
//   POST { prompt, response, level, type } -> { score: 0..10, feedback }
//
// Type accepts "writing" | "listening" | "speaking" | "dialogue".
// Requires ANTHROPIC_API_KEY in the environment.

export const runtime = "nodejs";

export async function POST(request: NextRequest) {
  let body: {
    prompt?: unknown;
    response?: unknown;
    level?: unknown;
    type?: unknown;
  };
  try {
    body = (await request.json()) as typeof body;
  } catch {
    return Response.json({ error: "Invalid JSON body" }, { status: 400 });
  }

  if (
    typeof body.prompt !== "string" ||
    typeof body.response !== "string" ||
    typeof body.level !== "string" ||
    typeof body.type !== "string"
  ) {
    return Response.json(
      { error: "Missing prompt, response, level or type" },
      { status: 400 },
    );
  }

  const allowed: GradeType[] = ["writing", "listening", "speaking", "dialogue"];
  if (!allowed.includes(body.type as GradeType)) {
    return Response.json(
      { error: `Unsupported type "${body.type}"` },
      { status: 400 },
    );
  }

  const result = await gradeResponse({
    prompt: body.prompt,
    response: body.response,
    level: body.level,
    type: body.type as GradeType,
  });
  return Response.json(result);
}

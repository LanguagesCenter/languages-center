import { NextRequest } from "next/server";
import { createClient } from "@/lib/supabase/server";
import {
  gradeLessonResponse,
  type GradeLessonArgs,
  type LessonGradeType,
} from "@/lib/grade-lesson-response";

// POST /api/grade-lesson-response
//   Required: { type, prompt, response, level, section, lessonNumber, language }
//   Optional: { lessonId, exerciseId } — when the client knows the IDs we
//   persist the row joined to lesson/exercise; otherwise the columns are NULL.
//
// Returns: { score, feedback, passed, correctedVersion, encouragement }
//
// Requires ANTHROPIC_API_KEY.

export const runtime = "nodejs";

const ALLOWED_TYPES: LessonGradeType[] = ["writing", "speaking", "listening"];

interface Body {
  type?: unknown;
  prompt?: unknown;
  response?: unknown;
  level?: unknown;
  section?: unknown;
  lessonNumber?: unknown;
  language?: unknown;
  lessonId?: unknown;
  exerciseId?: unknown;
}

function asString(v: unknown): string | null {
  return typeof v === "string" && v.length > 0 ? v : null;
}

export async function POST(request: NextRequest) {
  let body: Body;
  try {
    body = (await request.json()) as Body;
  } catch {
    return Response.json({ error: "Invalid JSON body" }, { status: 400 });
  }

  const type = asString(body.type);
  const prompt = asString(body.prompt);
  const response = typeof body.response === "string" ? body.response : null;
  const level = asString(body.level);
  const section = asString(body.section);
  const language = asString(body.language);
  const lessonNumberRaw = body.lessonNumber;

  if (
    !type ||
    !prompt ||
    response === null ||
    !level ||
    !section ||
    !language ||
    typeof lessonNumberRaw !== "number"
  ) {
    return Response.json(
      {
        error:
          "Missing or invalid fields: type, prompt, response, level, section, lessonNumber, language",
      },
      { status: 400 },
    );
  }

  if (!(ALLOWED_TYPES as string[]).includes(type)) {
    return Response.json(
      { error: `Unsupported type "${type}"` },
      { status: 400 },
    );
  }

  const args: GradeLessonArgs = {
    type: type as LessonGradeType,
    prompt,
    response,
    level,
    section,
    lessonNumber: lessonNumberRaw,
    language,
  };

  const result = await gradeLessonResponse(args);

  // Persist for the signed-in user. We never block the response on a write
  // failure — the grading is the user-visible product; storage is bookkeeping.
  try {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (user) {
      const lessonId =
        typeof body.lessonId === "number" ? body.lessonId : null;
      const exerciseId =
        typeof body.exerciseId === "number" ? body.exerciseId : null;
      const { error } = await supabase
        .from("lesson_graded_responses")
        .insert({
          user_id: user.id,
          lesson_id: lessonId,
          exercise_id: exerciseId,
          type: args.type,
          prompt: args.prompt,
          response: args.response,
          score: result.score,
          feedback: result.feedback,
          corrected_version: result.correctedVersion,
          encouragement: result.encouragement,
        });
      if (error) {
        console.warn(
          "[grade-lesson-response] persistence failed:",
          error.message,
        );
      }
    }
  } catch (err) {
    console.warn("[grade-lesson-response] persistence error:", err);
  }

  return Response.json(result);
}

import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";

// Smart-routing shim for the Spanish/French primary CTA. Spanish/French
// lead with the Traveler's Course now, but if the user has already made
// progress in the Fluency Course and NOT in the Traveler's Course we
// shouldn't yank them away from the course they're mid-way through.
//
//   • traveler progress OR no progress at all → /learn/[lang]/travel
//   • fluency progress only (no traveler progress) → /learn/[lang]
//   • anything else about auth is handled by the destination page
//     (e.g. /travel redirects to /login when signed out).
//
// This runs server-side on every click, so we always have a fresh view
// of the user's progress — no stale client state to worry about.

const SUPPORTED = new Set(["spanish", "french"]);

export async function GET(
  _req: Request,
  ctx: { params: Promise<{ language: string }> },
) {
  const { language } = await ctx.params;
  // Build URLs relative to the request so this works on preview, prod,
  // and local without hard-coding the origin.
  const url = new URL(_req.url);
  const travel = new URL(`/learn/${language}/travel`, url);
  const fluency = new URL(`/learn/${language}`, url);
  const marketing = new URL(`/languages/${language}`, url);

  // Other languages don't have a Traveler's Course — fall back to the
  // marketing overview, which is where the navbar used to send them.
  if (!SUPPORTED.has(language)) {
    return NextResponse.redirect(marketing);
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    // Anon → send to the marketing overview so they see the city grid +
    // sign-up CTA, not a bare login redirect.
    return NextResponse.redirect(marketing);
  }

  // Does the user have ANY completed traveler lesson in this language?
  const { data: travelerRows } = await supabase
    .from("traveler_progress")
    .select(
      "traveler_lesson_id, traveler_lessons!inner(traveler_courses!inner(languages!inner(code)))",
    )
    .eq("user_id", user.id)
    .eq("completed", true)
    .limit(200);
  const travelerCount = (travelerRows ?? []).filter((row) => {
    const r = row as unknown as {
      traveler_lessons: {
        traveler_courses: { languages: { code: string } };
      };
    };
    return r.traveler_lessons?.traveler_courses?.languages?.code === language;
  }).length;

  if (travelerCount > 0) {
    return NextResponse.redirect(travel);
  }

  // Any Fluency Course progress in this language?
  const { data: lang } = await supabase
    .from("languages")
    .select("id")
    .eq("code", language)
    .maybeSingle();
  if (lang) {
    const { count } = await supabase
      .from("user_progress")
      .select(
        "id, lessons!inner(section_id, sections!inner(course_id, courses!inner(language_id)))",
        { count: "exact", head: true },
      )
      .eq("user_id", user.id)
      .eq("completed", true)
      .eq("lessons.sections.courses.language_id", (lang as { id: number }).id);
    if ((count ?? 0) > 0) {
      return NextResponse.redirect(fluency);
    }
  }

  // No progress of either kind → default to the new primary track.
  return NextResponse.redirect(travel);
}

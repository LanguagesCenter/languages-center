import { NextRequest } from "next/server";
import { stripe } from "@/lib/stripe";
import { createClient } from "@/lib/supabase/server";
import { getLanguageIdBySlug } from "@/lib/placement-exam";

export async function POST(request: NextRequest) {
  const { session_id } = await request.json();
  if (!session_id) {
    return Response.json({ error: "Missing session_id" }, { status: 400 });
  }
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return Response.json({ error: "Not authenticated" }, { status: 401 });
  }

  const session = await stripe.checkout.sessions.retrieve(session_id);
  if (
    session.payment_status !== "paid" ||
    session.metadata?.supabase_user_id !== user.id ||
    session.metadata?.kind !== "placement_exam"
  ) {
    return Response.json({ error: "Payment not verified" }, { status: 400 });
  }

  const languageSlug = session.metadata?.language_slug ?? "spanish";
  const level = session.metadata?.level ?? "A1";

  const languageId = await getLanguageIdBySlug(languageSlug);
  if (!languageId) {
    return Response.json({ error: "Unknown language" }, { status: 400 });
  }

  // Insert payment row (idempotent on the unique session id via stripe_payment_id).
  const { error } = await supabase.from("placement_exam_payments").insert({
    user_id: user.id,
    language_id: languageId,
    level,
    stripe_payment_id: session.id,
  });
  // Ignore duplicate insertions (user refreshing the success page).
  if (error && !/duplicate|unique/i.test(error.message)) {
    return Response.json({ error: error.message }, { status: 500 });
  }

  return Response.json({ success: true });
}

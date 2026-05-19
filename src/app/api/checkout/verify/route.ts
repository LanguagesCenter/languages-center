import { NextRequest } from "next/server";
import { stripe } from "@/lib/stripe";
import { createClient } from "@/lib/supabase/server";

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
    session.metadata?.supabase_user_id !== user.id
  ) {
    return Response.json({ error: "Payment not verified" }, { status: 400 });
  }

  const { error } = await supabase.auth.updateUser({
    data: { is_premium: true, stripe_customer_id: session.customer },
  });

  if (error) {
    return Response.json({ error: error.message }, { status: 500 });
  }

  return Response.json({ success: true });
}

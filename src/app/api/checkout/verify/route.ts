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

  const session = await stripe.checkout.sessions.retrieve(session_id, {
    expand: ["subscription"],
  });

  if (session.metadata?.supabase_user_id !== user.id) {
    return Response.json({ error: "Session does not belong to user" }, { status: 400 });
  }

  // During a 7-day trial the checkout completes with no charge, so
  // payment_status is "no_payment_required". Accept that as long as the
  // subscription itself is active or trialing.
  const subscription =
    typeof session.subscription === "string"
      ? null
      : session.subscription;
  const validSubscriptionStatus =
    !subscription ||
    subscription.status === "trialing" ||
    subscription.status === "active";
  const validPaymentStatus =
    session.payment_status === "paid" ||
    session.payment_status === "no_payment_required";

  if (!validPaymentStatus || !validSubscriptionStatus) {
    return Response.json({ error: "Payment not verified" }, { status: 400 });
  }

  const { error } = await supabase.auth.updateUser({
    data: {
      is_premium: true,
      stripe_customer_id: session.customer,
      stripe_subscription_id: subscription?.id,
      subscription_status: subscription?.status ?? "active",
    },
  });

  if (error) {
    return Response.json({ error: error.message }, { status: 500 });
  }

  return Response.json({ success: true, trialing: subscription?.status === "trialing" });
}

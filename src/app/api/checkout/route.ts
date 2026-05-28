import { NextRequest } from "next/server";
import { stripe } from "@/lib/stripe";
import { createClient } from "@/lib/supabase/server";

type Plan = "monthly" | "yearly";

export async function POST(request: NextRequest) {
  try {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user) {
      return Response.json({ error: "Not authenticated" }, { status: 401 });
    }

    const body = (await request.json().catch(() => ({}))) as {
      plan?: Plan;
      withTrial?: boolean;
    };
    const plan: Plan = body.plan === "yearly" ? "yearly" : "monthly";
    // Trial is opt-in; the request must explicitly ask for it. Anything
    // else (missing, false, "false") starts billing immediately.
    const withTrial = body.withTrial === true;

    const priceId =
      plan === "yearly"
        ? process.env.STRIPE_YEARLY_PRICE_ID
        : process.env.STRIPE_PRICE_ID;

    if (!priceId) {
      return Response.json(
        { error: `Missing price ID for ${plan} plan` },
        { status: 500 },
      );
    }

    const origin = request.nextUrl.origin;

    const session = await stripe.checkout.sessions.create({
      customer_email: user.email,
      metadata: { supabase_user_id: user.id, plan, with_trial: String(withTrial) },
      line_items: [{ price: priceId, quantity: 1 }],
      mode: "subscription",
      subscription_data: {
        ...(withTrial ? { trial_period_days: 7 } : {}),
        metadata: { supabase_user_id: user.id, plan, with_trial: String(withTrial) },
      },
      success_url: `${origin}/checkout/success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${origin}/pricing`,
    });

    return Response.json({ url: session.url });
  } catch (err: unknown) {
    const message =
      err instanceof Error ? err.message : "An unexpected error occurred";
    console.error("Checkout error:", message);
    return Response.json({ error: message }, { status: 500 });
  }
}

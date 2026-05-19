import { NextRequest } from "next/server";
import { stripe } from "@/lib/stripe";
import { createClient } from "@/lib/supabase/server";

export async function POST(request: NextRequest) {
  try {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user) {
      return Response.json({ error: "Not authenticated" }, { status: 401 });
    }

    const origin = request.nextUrl.origin;

    const session = await stripe.checkout.sessions.create({
      customer_email: user.email,
      metadata: { supabase_user_id: user.id },
      line_items: [
        {
          price_data: {
            currency: "usd",
            product: process.env.STRIPE_PRICE_ID!,
            recurring: { interval: "month" },
            unit_amount: 999,
          },
          quantity: 1,
        },
      ],
      mode: "subscription",
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

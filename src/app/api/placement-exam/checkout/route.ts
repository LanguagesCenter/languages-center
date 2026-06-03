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

    const body = (await request.json().catch(() => ({}))) as {
      languageSlug?: string;
      level?: string;
    };
    const languageSlug = body.languageSlug ?? "spanish";
    const level = body.level ?? "A1";

    const origin = request.nextUrl.origin;
    const successUrl = `${origin}/learn/${languageSlug}/placement/${level.toLowerCase()}?paid=1&session_id={CHECKOUT_SESSION_ID}`;
    const cancelUrl = `${origin}/learn/${languageSlug}/placement/${level.toLowerCase()}`;

    const priceId = process.env.STRIPE_PLACEMENT_EXAM_PRICE_ID;
    // Prefer a configured Price; otherwise create an inline $2 line item.
    const lineItem = priceId
      ? { price: priceId, quantity: 1 }
      : {
          price_data: {
            currency: "usd",
            product_data: {
              name: `${languageSlug.charAt(0).toUpperCase() + languageSlug.slice(1)} ${level} Placement Exam`,
            },
            unit_amount: 99,
          },
          quantity: 1,
        };

    const session = await stripe.checkout.sessions.create({
      mode: "payment",
      customer_email: user.email,
      metadata: {
        supabase_user_id: user.id,
        language_slug: languageSlug,
        level,
        kind: "placement_exam",
      },
      line_items: [lineItem],
      success_url: successUrl,
      cancel_url: cancelUrl,
    });

    return Response.json({ url: session.url });
  } catch (err: unknown) {
    const message =
      err instanceof Error ? err.message : "An unexpected error occurred";
    console.error("Placement exam checkout error:", message);
    return Response.json({ error: message }, { status: 500 });
  }
}

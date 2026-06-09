import type { NextRequest } from "next/server";
import type Stripe from "stripe";
import { stripe } from "@/lib/stripe";
import { createAdminClient } from "@/lib/supabase/admin";

// Stripe signature verification needs the raw request body byte-for-byte,
// so we read it as text below. Force Node runtime — the Stripe SDK uses
// Node crypto primitives that aren't available on edge.
export const runtime = "nodejs";

const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

interface PremiumUpdate {
  is_premium?: boolean;
  subscription_status?: string;
  subscription_cancel_at?: string | null;
}

/**
 * Stripe webhook.
 *
 * Configure in Stripe dashboard → Developers → Webhooks → Add endpoint.
 * URL: https://your-domain/api/webhooks/stripe
 * Events to send:
 *   - customer.subscription.deleted
 *   - customer.subscription.updated
 *   - invoice.payment_failed
 * Copy the signing secret into the STRIPE_WEBHOOK_SECRET env var.
 *
 * Premium status (is_premium / subscription_status) lives in
 * auth.users.raw_user_meta_data — the same field every check site reads
 * via isCurrentUserPremium(). To find which user a Stripe customer maps
 * to we call the SECURITY DEFINER function find_user_by_stripe_customer
 * (see migration 031). Without that function this webhook can't locate
 * the user and will ack-and-ignore.
 */
export async function POST(req: NextRequest) {
  if (!webhookSecret) {
    console.error("[stripe-webhook] STRIPE_WEBHOOK_SECRET not set");
    return Response.json(
      { error: "Webhook secret not configured" },
      { status: 500 },
    );
  }

  const signature = req.headers.get("stripe-signature");
  if (!signature) {
    return Response.json({ error: "Missing signature" }, { status: 400 });
  }

  const rawBody = await req.text();

  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(rawBody, signature, webhookSecret);
  } catch (err) {
    const msg =
      err instanceof Error ? err.message : "Signature verification failed";
    console.warn("[stripe-webhook] bad signature:", msg);
    return Response.json({ error: msg }, { status: 400 });
  }

  const update = resolvePremiumUpdate(event);
  if (!update) {
    // Event type we don't act on — ack so Stripe stops retrying.
    return Response.json({ received: true, ignored: event.type });
  }

  const customerId = extractCustomerId(event);
  if (!customerId) {
    console.warn("[stripe-webhook] event has no customer:", event.type);
    return Response.json({ received: true });
  }

  const admin = createAdminClient();

  // Look up the Supabase user whose user_metadata.stripe_customer_id
  // matches. Function is SECURITY DEFINER → service-role only.
  const { data: userId, error: rpcErr } = await admin.rpc(
    "find_user_by_stripe_customer",
    { customer_id: customerId },
  );

  if (rpcErr) {
    console.error("[stripe-webhook] rpc lookup failed:", rpcErr);
    return Response.json(
      { error: "Customer lookup failed" },
      { status: 500 },
    );
  }
  if (!userId || typeof userId !== "string") {
    // Customer we don't have a Supabase user for. Ack so Stripe stops
    // retrying — there's nothing to update.
    console.warn(
      "[stripe-webhook] unknown Stripe customer (no Supabase user):",
      customerId,
    );
    return Response.json({ received: true, unknown_customer: customerId });
  }

  // Fetch the existing user_metadata so we don't blow away unrelated
  // fields (like full_name, stripe_customer_id itself).
  const { data: userResp, error: getErr } =
    await admin.auth.admin.getUserById(userId);

  if (getErr || !userResp?.user) {
    console.error("[stripe-webhook] could not fetch user:", userId, getErr);
    return Response.json({ error: "User lookup failed" }, { status: 500 });
  }

  const merged = {
    ...userResp.user.user_metadata,
    ...update,
  };

  const { error: updErr } = await admin.auth.admin.updateUserById(userId, {
    user_metadata: merged,
  });

  if (updErr) {
    console.error("[stripe-webhook] updateUser failed:", userId, updErr);
    return Response.json({ error: updErr.message }, { status: 500 });
  }

  console.log(
    "[stripe-webhook] %s applied to user %s:",
    event.type,
    userId,
    update,
  );

  return Response.json({ received: true });
}

function extractCustomerId(event: Stripe.Event): string | null {
  const obj = event.data.object as unknown as Record<string, unknown>;
  const c = obj["customer"];
  return typeof c === "string" ? c : null;
}

/**
 * Map a Stripe event into the user_metadata changes the webhook should
 * apply. Returns null if the event type isn't one we act on, so the
 * webhook can ack-and-ignore without touching the user row.
 */
function resolvePremiumUpdate(event: Stripe.Event): PremiumUpdate | null {
  switch (event.type) {
    case "customer.subscription.deleted":
      // Subscription fully ended (period over, or hard-cancelled).
      return {
        is_premium: false,
        subscription_status: "canceled",
        subscription_cancel_at: null,
      };

    case "customer.subscription.updated": {
      const sub = event.data.object as Stripe.Subscription;
      // Hard-fail states → revoke.
      if (
        sub.status === "canceled" ||
        sub.status === "past_due" ||
        sub.status === "unpaid" ||
        sub.status === "incomplete_expired"
      ) {
        return {
          is_premium: false,
          subscription_status: sub.status,
          subscription_cancel_at: null,
        };
      }
      // Still paying. Keep premium on but record whether they've asked
      // to cancel at period end, so the profile page can show
      // "Premium · canceling on YYYY-MM-DD".
      if (sub.status === "active" || sub.status === "trialing") {
        if (sub.cancel_at_period_end) {
          return {
            is_premium: true,
            subscription_status: "canceling",
            subscription_cancel_at:
              typeof sub.cancel_at === "number"
                ? new Date(sub.cancel_at * 1000).toISOString()
                : null,
          };
        }
        return {
          is_premium: true,
          subscription_status: sub.status,
          subscription_cancel_at: null,
        };
      }
      // Anything else (incomplete, paused) → just record the status.
      return { subscription_status: sub.status };
    }

    case "invoice.payment_failed": {
      const invoice = event.data.object as Stripe.Invoice;
      // Stripe retries failed invoices automatically. Only revoke once
      // it has given up (no further attempt scheduled).
      if (invoice.next_payment_attempt === null) {
        return { is_premium: false, subscription_status: "past_due" };
      }
      return null;
    }

    default:
      return null;
  }
}

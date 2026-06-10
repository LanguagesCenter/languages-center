import Stripe from "stripe";

// Surface a clear server-log warning when the secret key isn't configured.
// Without this, the first checkout attempt fails with an obscure Stripe SDK
// error and there's no easy way to tell from prod logs what's missing.
if (!process.env.STRIPE_SECRET_KEY) {
  console.warn(
    "[stripe] STRIPE_SECRET_KEY is not set — Stripe API calls will fail.",
  );
}

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY ?? "", {
  typescript: true,
});

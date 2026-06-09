import { createClient, type SupabaseClient } from "@supabase/supabase-js";

/**
 * Service-role Supabase client for server-only contexts (Stripe webhook,
 * cron jobs, anything that runs without a user session). Bypasses RLS and
 * can read/write auth.users via the admin API.
 *
 * NEVER use this client in code that runs in response to a user request
 * without first checking the request is from a trusted source — there is
 * no row-level security between this client and the database.
 *
 * Requires SUPABASE_SERVICE_ROLE_KEY (server-side env, not exposed to the
 * client). NEXT_PUBLIC_SUPABASE_URL is already public.
 */
export function createAdminClient(): SupabaseClient {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!url || !serviceKey) {
    throw new Error(
      "Supabase admin client requires NEXT_PUBLIC_SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY",
    );
  }
  return createClient(url, serviceKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
}

-- 031_stripe_webhook_user_lookup.sql
-- Lookup helper used by /api/webhooks/stripe to find the Supabase user
-- whose user_metadata.stripe_customer_id matches the customer ID on an
-- incoming Stripe event.
--
-- The webhook runs as service_role (no user session) so it can't go
-- through the normal auth.users → JWT path. This function does the
-- jsonb lookup in one round-trip and is granted only to service_role.
--
-- No new columns are needed — premium status (is_premium,
-- subscription_status, subscription_cancel_at) all live inside the
-- existing auth.users.raw_user_meta_data jsonb. The Stripe checkout
-- /verify route already writes stripe_customer_id there on a successful
-- checkout.

create or replace function public.find_user_by_stripe_customer(customer_id text)
returns uuid
language sql
security definer
set search_path = public, auth
as $$
  select id
  from auth.users
  where raw_user_meta_data->>'stripe_customer_id' = customer_id
  limit 1;
$$;

-- Lock the function down: only service_role (the webhook's admin client)
-- can execute. Authenticated and anon users have no business looking up
-- other users by Stripe customer ID.
revoke all on function public.find_user_by_stripe_customer(text) from public, anon, authenticated;
grant execute on function public.find_user_by_stripe_customer(text) to service_role;

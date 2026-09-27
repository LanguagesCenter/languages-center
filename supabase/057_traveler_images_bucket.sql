-- ============================================================
-- 057_traveler_images_bucket.sql
--
-- Create the 'traveler-images' Storage bucket that holds
-- permanent copies of every image the Adventure v2 generator
-- produces via Flux. Replicate delivery URLs expire in ~24h, so
-- we download each image and re-host it here immediately after
-- generation.
--
-- Path convention:
--   traveler-images/<city-slug>/L<order_index>.jpg
--
-- Public bucket: the `public=true` flag makes objects readable at
-- the /object/public/... URL without any additional storage.objects
-- RLS policies. Writes go through SUPABASE_SERVICE_ROLE_KEY which
-- bypasses RLS.
--
-- Safe to re-run.
-- ============================================================

INSERT INTO storage.buckets (id, name, public)
VALUES ('traveler-images', 'traveler-images', true)
ON CONFLICT (id) DO UPDATE SET public = true;

SELECT id, name, public, created_at
FROM storage.buckets
WHERE id = 'traveler-images';

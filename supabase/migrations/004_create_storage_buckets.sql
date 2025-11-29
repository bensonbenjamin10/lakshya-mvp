-- Storage Buckets Setup for Lakshya Institute
-- 
-- NOTE: This file documents the required storage buckets.
-- Storage buckets must be created manually in the Supabase Dashboard
-- as they cannot be created via SQL migrations.
--
-- Steps to create buckets:
-- 1. Go to Supabase Dashboard > Storage
-- 2. Create each bucket with the settings below
-- 3. Configure storage policies for public access (see below)

-- ============================================
-- REQUIRED STORAGE BUCKETS
-- ============================================

-- 1. avatars bucket
--    - Name: avatars
--    - Public: true (for public avatar URLs)
--    - File size limit: 5MB
--    - Allowed MIME types: image/jpeg, image/png, image/webp

-- 2. brochures bucket
--    - Name: brochures
--    - Public: true (for public brochure download URLs)
--    - File size limit: 10MB
--    - Allowed MIME types: application/pdf

-- 3. course-images bucket
--    - Name: course-images
--    - Public: true (for public course image URLs)
--    - File size limit: 5MB
--    - Allowed MIME types: image/jpeg, image/png, image/webp

-- ============================================
-- STORAGE POLICIES (RLS)
-- ============================================
-- These policies should be created in Supabase Dashboard > Storage > Policies

-- For avatars bucket:
-- Policy: Public read access
--   - Policy name: Public Avatar Read
--   - Operation: SELECT
--   - Target roles: anon, authenticated
--   - Policy definition: true

-- Policy: Authenticated users can upload their own avatar
--   - Policy name: Upload Own Avatar
--   - Operation: INSERT
--   - Target roles: authenticated
--   - Policy definition: bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text

-- Policy: Users can update their own avatar
--   - Policy name: Update Own Avatar
--   - Operation: UPDATE
--   - Target roles: authenticated
--   - Policy definition: bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text

-- Policy: Users can delete their own avatar
--   - Policy name: Delete Own Avatar
--   - Operation: DELETE
--   - Target roles: authenticated
--   - Policy definition: bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text

-- For brochures bucket:
-- Policy: Public read access
--   - Policy name: Public Brochure Read
--   - Operation: SELECT
--   - Target roles: anon, authenticated
--   - Policy definition: true

-- Policy: Admin/Faculty can upload brochures
--   - Policy name: Upload Brochures
--   - Operation: INSERT
--   - Target roles: authenticated
--   - Policy definition: bucket_id = 'brochures' AND EXISTS (
--       SELECT 1 FROM public.profiles 
--       WHERE id = auth.uid() AND role IN ('admin', 'faculty')
--     )

-- Policy: Admin/Faculty can update brochures
--   - Policy name: Update Brochures
--   - Operation: UPDATE
--   - Target roles: authenticated
--   - Policy definition: bucket_id = 'brochures' AND EXISTS (
--       SELECT 1 FROM public.profiles 
--       WHERE id = auth.uid() AND role IN ('admin', 'faculty')
--     )

-- Policy: Admin/Faculty can delete brochures
--   - Policy name: Delete Brochures
--   - Operation: DELETE
--   - Target roles: authenticated
--   - Policy definition: bucket_id = 'brochures' AND EXISTS (
--       SELECT 1 FROM public.profiles 
--       WHERE id = auth.uid() AND role IN ('admin', 'faculty')
--     )

-- For course-images bucket:
-- Policy: Public read access
--   - Policy name: Public Course Image Read
--   - Operation: SELECT
--   - Target roles: anon, authenticated
--   - Policy definition: true

-- Policy: Admin/Faculty can upload course images
--   - Policy name: Upload Course Images
--   - Operation: INSERT
--   - Target roles: authenticated
--   - Policy definition: bucket_id = 'course-images' AND EXISTS (
--       SELECT 1 FROM public.profiles 
--       WHERE id = auth.uid() AND role IN ('admin', 'faculty')
--     )

-- Policy: Admin/Faculty can update course images
--   - Policy name: Update Course Images
--   - Operation: UPDATE
--   - Target roles: authenticated
--   - Policy definition: bucket_id = 'course-images' AND EXISTS (
--       SELECT 1 FROM public.profiles 
--       WHERE id = auth.uid() AND role IN ('admin', 'faculty')
--     )

-- Policy: Admin/Faculty can delete course images
--   - Policy name: Delete Course Images
--   - Operation: DELETE
--   - Target roles: authenticated
--   - Policy definition: bucket_id = 'course-images' AND EXISTS (
--       SELECT 1 FROM public.profiles 
--       WHERE id = auth.uid() AND role IN ('admin', 'faculty')
--     )

-- ============================================
-- VERIFICATION
-- ============================================
-- After creating buckets and policies, verify:
-- 1. All three buckets exist and are public
-- 2. Public read policies are active
-- 3. Upload/update/delete policies work for authenticated users
-- 4. Test file uploads from the application



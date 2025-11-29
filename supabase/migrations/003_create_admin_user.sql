-- Grant admin privileges to benson@medpg.org
-- This migration sets the admin role for the specified email
-- 
-- NOTE: The user must first be created in Supabase Auth (either through registration
-- or via Supabase Dashboard > Authentication > Users > Add User)
-- After the user is created, run this migration to grant admin privileges

-- Update profile role to admin for benson@medpg.org
-- This will work if the user already exists in auth.users
UPDATE public.profiles
SET role = 'admin',
    updated_at = now()
WHERE email = 'benson@medpg.org';

-- If the profile doesn't exist yet, we need to create it
-- But we can only do this if the auth user exists
-- This is a fallback that will create the profile if auth user exists but profile doesn't
INSERT INTO public.profiles (id, email, full_name, role)
SELECT 
    id,
    email,
    COALESCE(raw_user_meta_data->>'full_name', 'Benson'),
    'admin'
FROM auth.users
WHERE email = 'benson@medpg.org'
    AND NOT EXISTS (
        SELECT 1 FROM public.profiles WHERE email = 'benson@medpg.org'
    );

-- Verify the admin was created/updated
SELECT 
    id,
    email,
    full_name,
    role,
    created_at,
    updated_at
FROM public.profiles
WHERE email = 'benson@medpg.org';


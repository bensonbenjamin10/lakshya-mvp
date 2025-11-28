# Supabase Migrations

This directory contains SQL migration files for the Lakshya Institute database.

## Migration Files

### 001_initial_schema.sql
Creates the core database schema:
- `profiles` table - Extended user profiles linked to Supabase Auth
- `courses` table - Course catalog
- `leads` table - Lead capture (no auth required)
- `enrollments` table - Student course enrollments

Also sets up:
- Row Level Security (RLS) policies
- Database triggers for auto-updating timestamps
- Trigger to create profile on user signup

### 002_seed_courses.sql
Seeds initial course data:
- ACCA course
- CA course
- CMA course
- B.Com & MBA course

## How to Apply Migrations

### Option 1: Supabase Dashboard
1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Copy and paste each migration file in order
4. Execute each migration

### Option 2: Supabase CLI
```bash
# Install Supabase CLI if not already installed
npm install -g supabase

# Link to your project
supabase link --project-ref your-project-ref

# Apply migrations
supabase db push
```

### Option 3: Using Supabase MCP Tools
The migrations can be applied using the Supabase MCP tools available in Cursor.

## Important Notes

- Migrations should be applied in order (001, then 002)
- The RLS policies ensure:
  - Public content (courses) is accessible without auth
  - Leads can be created without auth (zero friction)
  - Only staff (admin/faculty) can view leads
  - Students can only access their own data

## Testing

After applying migrations, verify:
1. All tables are created with correct structure
2. RLS policies are enabled
3. Initial course data is seeded
4. Profile creation trigger works on signup


-- Course Sections Migration
-- Adds support for grouping course modules into sections

-- ============================================
-- COURSE SECTIONS TABLE
-- ============================================
create table public.course_sections (
  id uuid default gen_random_uuid() primary key,
  course_id uuid references public.courses(id) on delete cascade not null,
  title text not null,
  description text,
  display_order int default 0,
  is_expanded boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ============================================
-- ADD SECTION_ID TO COURSE_MODULES
-- ============================================
alter table public.course_modules 
  add column if not exists section_id uuid references public.course_sections(id) on delete set null;

-- ============================================
-- INDEXES
-- ============================================
create index idx_course_sections_course_id on public.course_sections(course_id);
create index idx_course_sections_display_order on public.course_sections(course_id, display_order);
create index idx_course_modules_section_id on public.course_modules(section_id);

-- ============================================
-- ROW LEVEL SECURITY POLICIES
-- ============================================
alter table public.course_sections enable row level security;

-- Public can view sections for active courses
create policy "Public can view course sections"
  on public.course_sections for select
  using (
    exists (
      select 1 from public.courses
      where id = course_sections.course_id and is_active = true
    )
  );

-- Staff can manage course sections
create policy "Staff can manage course sections"
  on public.course_sections for all
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role in ('admin', 'faculty')
    )
  );

-- ============================================
-- TRIGGERS
-- ============================================
create trigger handle_updated_at_course_sections
  before update on public.course_sections
  for each row
  execute function public.handle_updated_at();


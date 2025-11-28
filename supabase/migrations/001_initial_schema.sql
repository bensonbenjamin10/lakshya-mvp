-- Initial database schema for Lakshya Institute
-- This migration creates all core tables and sets up Row Level Security

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- ============================================
-- PROFILES TABLE
-- ============================================
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  email text not null,
  full_name text,
  phone text,
  avatar_url text,
  role text not null default 'student' 
    check (role in ('student', 'faculty', 'admin')),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ============================================
-- COURSES TABLE
-- ============================================
create table public.courses (
  id uuid default gen_random_uuid() primary key,
  slug text unique not null,
  title text not null,
  description text,
  category text not null 
    check (category in ('acca', 'ca', 'cma', 'bcom_mba')),
  duration text,
  level text,
  highlights text[],
  image_url text,
  brochure_url text,
  is_popular boolean default false,
  is_active boolean default true,
  created_by uuid references public.profiles(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ============================================
-- LEADS TABLE
-- ============================================
create table public.leads (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  email text not null,
  phone text not null,
  country text,
  inquiry_type text not null 
    check (inquiry_type in ('course_inquiry', 'enrollment', 'brochure_request', 'general_contact')),
  course_id uuid references public.courses(id),
  message text,
  source text default 'website' 
    check (source in ('website', 'social_media', 'referral', 'advertisement', 'other')),
  status text default 'new' 
    check (status in ('new', 'contacted', 'qualified', 'converted', 'lost')),
  assigned_to uuid references public.profiles(id),
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ============================================
-- ENROLLMENTS TABLE
-- ============================================
create table public.enrollments (
  id uuid default gen_random_uuid() primary key,
  student_id uuid references public.profiles(id) not null,
  course_id uuid references public.courses(id) not null,
  status text default 'pending' 
    check (status in ('pending', 'active', 'completed', 'dropped')),
  enrolled_at timestamptz default now(),
  completed_at timestamptz,
  unique(student_id, course_id)
);

-- ============================================
-- INDEXES
-- ============================================
create index idx_leads_status on public.leads(status);
create index idx_leads_assigned_to on public.leads(assigned_to);
create index idx_leads_created_at on public.leads(created_at);
create index idx_courses_category on public.courses(category);
create index idx_courses_is_active on public.courses(is_active);
create index idx_enrollments_student_id on public.enrollments(student_id);
create index idx_enrollments_course_id on public.enrollments(course_id);

-- ============================================
-- ROW LEVEL SECURITY POLICIES
-- ============================================

-- Profiles: Public read, users can update own
alter table public.profiles enable row level security;

create policy "Public profiles are viewable by everyone"
  on public.profiles for select
  using (true);

create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Courses: Public read active courses, admin/faculty can manage
alter table public.courses enable row level security;

create policy "Active courses are viewable by everyone"
  on public.courses for select
  using (is_active = true);

create policy "Admin and faculty can manage courses"
  on public.courses for all
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role in ('admin', 'faculty')
    )
  );

-- Leads: Anyone can create, staff can view/update
alter table public.leads enable row level security;

create policy "Anyone can create leads"
  on public.leads for insert
  with check (true);

create policy "Staff can view leads"
  on public.leads for select
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role in ('admin', 'faculty')
    )
  );

create policy "Staff can update leads"
  on public.leads for update
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role in ('admin', 'faculty')
    )
  );

-- Enrollments: Students can view own, staff can view all
alter table public.enrollments enable row level security;

create policy "Students can view own enrollments"
  on public.enrollments for select
  using (auth.uid() = student_id);

create policy "Staff can view all enrollments"
  on public.enrollments for select
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role in ('admin', 'faculty')
    )
  );

create policy "Students can create own enrollments"
  on public.enrollments for insert
  with check (auth.uid() = student_id);

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to automatically create profile on signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, full_name)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', '')
  );
  return new;
end;
$$ language plpgsql security definer;

-- Trigger to create profile on signup
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Function to update updated_at timestamp
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Triggers for updated_at
create trigger set_updated_at_profiles
  before update on public.profiles
  for each row execute procedure public.handle_updated_at();

create trigger set_updated_at_courses
  before update on public.courses
  for each row execute procedure public.handle_updated_at();

create trigger set_updated_at_leads
  before update on public.leads
  for each row execute procedure public.handle_updated_at();


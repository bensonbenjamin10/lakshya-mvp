-- Payment System and Student Portal Migration
-- This migration adds payment support and student portal features

-- ============================================
-- PAYMENTS TABLE
-- ============================================
create table public.payments (
  id uuid default gen_random_uuid() primary key,
  enrollment_id uuid references public.enrollments(id) on delete set null,
  student_id uuid references public.profiles(id) not null,
  course_id uuid references public.courses(id) not null,
  amount decimal(10,2) not null,
  currency text default 'INR',
  payment_status text not null default 'pending'
    check (payment_status in ('pending', 'processing', 'completed', 'failed', 'refunded', 'cancelled')),
  payment_provider text not null 
    check (payment_provider in ('razorpay', 'revenuecat', 'manual')),
  payment_method text, -- card, upi, netbanking, etc.
  transaction_id text, -- provider transaction ID
  provider_order_id text, -- provider order ID
  payment_plan text check (payment_plan in ('full', 'installment_3', 'installment_6')),
  installment_number int, -- for installment payments
  metadata jsonb, -- provider-specific data
  failure_reason text,
  refund_amount decimal(10,2),
  refund_reason text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  completed_at timestamptz
);

-- ============================================
-- ENHANCE ENROLLMENTS TABLE
-- ============================================
alter table public.enrollments 
  add column if not exists payment_required boolean default true,
  add column if not exists payment_status text default 'pending'
    check (payment_status in ('pending', 'partial', 'paid', 'not_required')),
  add column if not exists progress_percentage decimal(5,2) default 0
    check (progress_percentage >= 0 and progress_percentage <= 100),
  add column if not exists last_accessed_at timestamptz;

-- ============================================
-- COURSE MODULES TABLE
-- ============================================
create table public.course_modules (
  id uuid default gen_random_uuid() primary key,
  course_id uuid references public.courses(id) on delete cascade not null,
  module_number int not null,
  title text not null,
  description text,
  type text not null 
    check (type in ('video', 'reading', 'assignment', 'quiz', 'live_session')),
  content_url text,
  duration_minutes int,
  is_required boolean default true,
  unlock_date timestamptz,
  display_order int default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(course_id, module_number)
);

-- ============================================
-- STUDENT PROGRESS TABLE
-- ============================================
create table public.student_progress (
  id uuid default gen_random_uuid() primary key,
  student_id uuid references public.profiles(id) on delete cascade not null,
  enrollment_id uuid references public.enrollments(id) on delete cascade not null,
  module_id uuid references public.course_modules(id) on delete cascade not null,
  status text not null default 'not_started'
    check (status in ('not_started', 'in_progress', 'completed')),
  completion_date timestamptz,
  time_spent_minutes int default 0,
  last_accessed_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(enrollment_id, module_id)
);

-- ============================================
-- INDEXES
-- ============================================
create index idx_payments_student_id on public.payments(student_id);
create index idx_payments_course_id on public.payments(course_id);
create index idx_payments_enrollment_id on public.payments(enrollment_id);
create index idx_payments_status on public.payments(payment_status);
create index idx_payments_transaction_id on public.payments(transaction_id);
create index idx_enrollments_payment_status on public.enrollments(payment_status);
create index idx_course_modules_course_id on public.course_modules(course_id);
create index idx_course_modules_display_order on public.course_modules(course_id, display_order);
create index idx_student_progress_student_id on public.student_progress(student_id);
create index idx_student_progress_enrollment_id on public.student_progress(enrollment_id);
create index idx_student_progress_module_id on public.student_progress(module_id);
create index idx_student_progress_status on public.student_progress(status);

-- ============================================
-- ROW LEVEL SECURITY POLICIES
-- ============================================

-- Payments: Students can view own payments, staff can view all
alter table public.payments enable row level security;

create policy "Students can view own payments"
  on public.payments for select
  using (auth.uid() = student_id);

create policy "Staff can view all payments"
  on public.payments for select
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role in ('admin', 'faculty')
    )
  );

create policy "Students can create own payments"
  on public.payments for insert
  with check (auth.uid() = student_id);

create policy "System can update payments"
  on public.payments for update
  using (true); -- Payments updated via webhooks/backend

-- Course Modules: Public read active modules, staff can manage
alter table public.course_modules enable row level security;

create policy "Public can view course modules"
  on public.course_modules for select
  using (
    exists (
      select 1 from public.courses
      where id = course_modules.course_id and is_active = true
    )
  );

create policy "Staff can manage course modules"
  on public.course_modules for all
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role in ('admin', 'faculty')
    )
  );

-- Student Progress: Students can view/manage own progress, staff can view all
alter table public.student_progress enable row level security;

create policy "Students can view own progress"
  on public.student_progress for select
  using (auth.uid() = student_id);

create policy "Students can update own progress"
  on public.student_progress for update
  using (auth.uid() = student_id);

create policy "Students can create own progress"
  on public.student_progress for insert
  with check (auth.uid() = student_id);

create policy "Staff can view all progress"
  on public.student_progress for select
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role in ('admin', 'faculty')
    )
  );

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to update enrollment progress percentage
create or replace function public.update_enrollment_progress()
returns trigger as $$
declare
  total_modules int;
  completed_modules int;
  new_progress decimal(5,2);
begin
  -- Get total required modules for the course
  select count(*) into total_modules
  from public.course_modules
  where course_id = (
    select course_id from public.enrollments where id = new.enrollment_id
  ) and is_required = true;

  -- Get completed modules for this enrollment
  select count(*) into completed_modules
  from public.student_progress
  where enrollment_id = new.enrollment_id
    and status = 'completed';

  -- Calculate progress percentage
  if total_modules > 0 then
    new_progress := (completed_modules::decimal / total_modules::decimal) * 100;
  else
    new_progress := 0;
  end if;

  -- Update enrollment progress
  update public.enrollments
  set progress_percentage = new_progress,
      last_accessed_at = now()
  where id = new.enrollment_id;

  return new;
end;
$$ language plpgsql security definer;

-- Trigger to update progress on student progress changes
create trigger update_enrollment_progress_trigger
  after insert or update on public.student_progress
  for each row
  execute function public.update_enrollment_progress();

-- Function to update updated_at timestamp
create trigger handle_updated_at_payments
  before update on public.payments
  for each row
  execute function public.handle_updated_at();

create trigger handle_updated_at_course_modules
  before update on public.course_modules
  for each row
  execute function public.handle_updated_at();

create trigger handle_updated_at_student_progress
  before update on public.student_progress
  for each row
  execute function public.handle_updated_at();


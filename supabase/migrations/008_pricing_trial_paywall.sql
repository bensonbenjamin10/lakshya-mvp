-- Pricing, Trial System, and Paywall Migration
-- Adds course pricing, free trial support, and module preview capabilities

-- ============================================
-- ENHANCE COURSES TABLE WITH PRICING
-- ============================================
alter table public.courses 
  add column if not exists price decimal(10,2) default 0,
  add column if not exists sale_price decimal(10,2),
  add column if not exists currency text default 'INR',
  add column if not exists free_trial_days int default 0,
  add column if not exists is_free boolean default false;

-- ============================================
-- ENHANCE COURSE MODULES WITH FREE PREVIEW
-- ============================================
alter table public.course_modules 
  add column if not exists is_free_preview boolean default false;

-- ============================================
-- ENHANCE ENROLLMENTS WITH TRIAL TRACKING
-- ============================================
alter table public.enrollments 
  add column if not exists trial_started_at timestamptz,
  add column if not exists trial_ends_at timestamptz;

-- ============================================
-- UPDATE EXISTING COURSES WITH DEFAULT PRICING
-- ============================================
-- Set default prices for existing courses (can be updated via admin)
update public.courses
set 
  price = case 
    when category = 'acca' then 150000.00
    when category = 'ca' then 125000.00
    when category = 'cma' then 100000.00
    when category = 'bcom_mba' then 75000.00
    else 50000.00
  end,
  free_trial_days = 7,
  is_free = false
where price is null or price = 0;

-- ============================================
-- SET FIRST MODULE OF EACH COURSE AS FREE PREVIEW
-- ============================================
update public.course_modules
set is_free_preview = true
where module_number = 1;

-- ============================================
-- FUNCTION TO CHECK IF TRIAL IS ACTIVE
-- ============================================
create or replace function public.is_trial_active(enrollment_id uuid)
returns boolean as $$
declare
  enrollment_record record;
begin
  select trial_ends_at, payment_status
  into enrollment_record
  from public.enrollments
  where id = enrollment_id;
  
  -- If payment is complete or not required, always return true
  if enrollment_record.payment_status in ('paid', 'not_required') then
    return true;
  end if;
  
  -- If no trial end date, trial hasn't started
  if enrollment_record.trial_ends_at is null then
    return false;
  end if;
  
  -- Check if trial is still active
  return now() < enrollment_record.trial_ends_at;
end;
$$ language plpgsql security definer;

-- ============================================
-- FUNCTION TO START FREE TRIAL
-- ============================================
create or replace function public.start_free_trial(
  p_enrollment_id uuid,
  p_trial_days int default 7
)
returns boolean as $$
begin
  update public.enrollments
  set 
    trial_started_at = now(),
    trial_ends_at = now() + (p_trial_days || ' days')::interval,
    status = 'active'
  where id = p_enrollment_id
    and trial_started_at is null; -- Only start if not already started
  
  return found;
end;
$$ language plpgsql security definer;

-- ============================================
-- FUNCTION TO GET COURSE ACCESS STATUS
-- ============================================
create or replace function public.get_course_access_status(p_enrollment_id uuid)
returns jsonb as $$
declare
  enrollment_record record;
  course_record record;
  result jsonb;
begin
  -- Get enrollment details
  select e.*, c.free_trial_days, c.price, c.is_free
  into enrollment_record
  from public.enrollments e
  join public.courses c on c.id = e.course_id
  where e.id = p_enrollment_id;
  
  if not found then
    return jsonb_build_object(
      'has_access', false,
      'reason', 'enrollment_not_found'
    );
  end if;
  
  -- Free course - always has access
  if enrollment_record.is_free or enrollment_record.price = 0 then
    return jsonb_build_object(
      'has_access', true,
      'access_type', 'free_course'
    );
  end if;
  
  -- Payment complete - full access
  if enrollment_record.payment_status in ('paid', 'not_required') then
    return jsonb_build_object(
      'has_access', true,
      'access_type', 'paid'
    );
  end if;
  
  -- Check trial status
  if enrollment_record.trial_ends_at is not null then
    if now() < enrollment_record.trial_ends_at then
      return jsonb_build_object(
        'has_access', true,
        'access_type', 'trial',
        'trial_ends_at', enrollment_record.trial_ends_at,
        'days_remaining', extract(day from (enrollment_record.trial_ends_at - now()))::int
      );
    else
      return jsonb_build_object(
        'has_access', false,
        'reason', 'trial_expired',
        'trial_ended_at', enrollment_record.trial_ends_at
      );
    end if;
  end if;
  
  -- No trial started and no payment
  return jsonb_build_object(
    'has_access', false,
    'reason', 'payment_required',
    'can_start_trial', enrollment_record.free_trial_days > 0,
    'trial_days_available', enrollment_record.free_trial_days
  );
end;
$$ language plpgsql security definer;

-- ============================================
-- INDEXES FOR NEW COLUMNS
-- ============================================
create index if not exists idx_courses_is_free on public.courses(is_free);
create index if not exists idx_courses_price on public.courses(price);
create index if not exists idx_course_modules_is_free_preview on public.course_modules(is_free_preview);
create index if not exists idx_enrollments_trial_ends_at on public.enrollments(trial_ends_at);



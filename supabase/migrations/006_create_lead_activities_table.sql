-- Create lead_activities table for tracking lead changes
-- This table tracks all changes to leads including status changes, assignments, notes updates, etc.

create table public.lead_activities (
  id uuid default gen_random_uuid() primary key,
  lead_id uuid references public.leads(id) on delete cascade not null,
  activity_type text not null
    check (activity_type in ('status_change', 'assignment', 'notes_update', 'created', 'other')),
  old_value text,
  new_value text,
  description text,
  created_by uuid references public.profiles(id),
  created_at timestamptz default now()
);

-- Indexes for performance
create index idx_lead_activities_lead_id on public.lead_activities(lead_id);
create index idx_lead_activities_created_at on public.lead_activities(created_at desc);
create index idx_lead_activities_activity_type on public.lead_activities(activity_type);

-- RLS Policies
alter table public.lead_activities enable row level security;

-- Admins and faculty can view all activities
create policy "Admins and faculty can view all activities"
  on public.lead_activities for select
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = (select auth.uid())
      and profiles.role in ('admin', 'faculty')
    )
  );

-- Admins and faculty can create activities
create policy "Admins and faculty can create activities"
  on public.lead_activities for insert
  with check (
    exists (
      select 1 from public.profiles
      where profiles.id = (select auth.uid())
      and profiles.role in ('admin', 'faculty')
    )
  );

-- Function to automatically create activity when lead status changes
create or replace function public.log_lead_status_change()
returns trigger as $$
begin
  if old.status is distinct from new.status then
    insert into public.lead_activities (
      lead_id,
      activity_type,
      old_value,
      new_value,
      description,
      created_by
    ) values (
      new.id,
      'status_change',
      old.status,
      new.status,
      'Status changed from ' || old.status || ' to ' || new.status,
      (select auth.uid())
    );
  end if;
  return new;
end;
$$ language plpgsql security definer;

-- Trigger for status changes
create trigger trigger_log_lead_status_change
  after update of status on public.leads
  for each row
  when (old.status is distinct from new.status)
  execute function public.log_lead_status_change();

-- Function to automatically create activity when lead assignment changes
create or replace function public.log_lead_assignment_change()
returns trigger as $$
declare
  old_name text;
  new_name text;
begin
  if old.assigned_to is distinct from new.assigned_to then
    -- Get profile names
    select coalesce(full_name, email) into old_name
    from public.profiles where id = old.assigned_to;
    
    select coalesce(full_name, email) into new_name
    from public.profiles where id = new.assigned_to;
    
    insert into public.lead_activities (
      lead_id,
      activity_type,
      old_value,
      new_value,
      description,
      created_by
    ) values (
      new.id,
      'assignment',
      old.assigned_to,
      new.assigned_to,
      case
        when old.assigned_to is null then 'Assigned to ' || coalesce(new_name, 'Unknown')
        when new.assigned_to is null then 'Unassigned from ' || coalesce(old_name, 'Unknown')
        else 'Reassigned from ' || coalesce(old_name, 'Unknown') || ' to ' || coalesce(new_name, 'Unknown')
      end,
      (select auth.uid())
    );
  end if;
  return new;
end;
$$ language plpgsql security definer;

-- Trigger for assignment changes
create trigger trigger_log_lead_assignment_change
  after update of assigned_to on public.leads
  for each row
  when (old.assigned_to is distinct from new.assigned_to)
  execute function public.log_lead_assignment_change();

-- Function to automatically create activity when lead notes change
create or replace function public.log_lead_notes_change()
returns trigger as $$
begin
  if old.notes is distinct from new.notes then
    insert into public.lead_activities (
      lead_id,
      activity_type,
      old_value,
      new_value,
      description,
      created_by
    ) values (
      new.id,
      'notes_update',
      old.notes,
      new.notes,
      case
        when old.notes is null then 'Notes added'
        when new.notes is null then 'Notes removed'
        else 'Notes updated'
      end,
      (select auth.uid())
    );
  end if;
  return new;
end;
$$ language plpgsql security definer;

-- Trigger for notes changes
create trigger trigger_log_lead_notes_change
  after update of notes on public.leads
  for each row
  when (old.notes is distinct from new.notes)
  execute function public.log_lead_notes_change();

-- Function to create activity when lead is created
create or replace function public.log_lead_created()
returns trigger as $$
begin
  insert into public.lead_activities (
    lead_id,
    activity_type,
    description,
    created_by
  ) values (
    new.id,
    'created',
    'Lead created from ' || new.source,
    null -- Created by anonymous/public user
  );
  return new;
end;
$$ language plpgsql security definer;

-- Trigger for lead creation
create trigger trigger_log_lead_created
  after insert on public.leads
  for each row
  execute function public.log_lead_created();


-- ============================================
-- ADD RICH CONTENT SUPPORT FOR MODULES
-- ============================================
-- Add content_body for storing Markdown/HTML content directly
-- Add content_type to distinguish between different content formats

alter table public.course_modules 
  add column if not exists content_body text,
  add column if not exists content_type text default 'url' 
    check (content_type in ('url', 'markdown', 'html'));

-- Add comments for documentation
comment on column public.course_modules.content_body is 'Rich text content stored as Markdown or HTML';
comment on column public.course_modules.content_type is 'Type of content: url (external link), markdown, or html';

-- Create index for efficient querying of reading modules
create index if not exists idx_course_modules_content_type 
  on public.course_modules(content_type) 
  where content_type is not null;


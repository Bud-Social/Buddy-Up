-- Landing-page contact + feature-suggestion forms (api/contact.ts, api/suggestion.ts).
-- Run once in the Supabase SQL editor for the project configured in Vercel
-- (same project as waitlist_entry). RLS is enabled with NO policies: the
-- anon key can do nothing; only the service-role key used by the Vercel
-- functions can insert/select.

create table if not exists public.contact_inquiry (
  id         bigint generated always as identity primary key,
  name       text        not null,
  email      text        not null,
  topic      text        not null default 'general',
  subject    text,
  message    text        not null,
  created_at timestamptz not null default now()
);

create table if not exists public.feature_suggestion (
  id          bigint generated always as identity primary key,
  title       text        not null,
  description text        not null,
  category    text        not null default 'other',
  email       text,
  name        text,
  status      text        not null default 'new',
  created_at  timestamptz not null default now()
);

alter table public.contact_inquiry    enable row level security;
alter table public.feature_suggestion enable row level security;

-- No policies are created on purpose (service-role key bypasses RLS).

-- Handy indexes for manual review in the Supabase dashboard.
create index if not exists contact_inquiry_created_at_idx
  on public.contact_inquiry (created_at desc);
create index if not exists feature_suggestion_status_created_idx
  on public.feature_suggestion (status, created_at desc);

-- Careers-page job applications (api/career.ts). Same RLS posture:
-- enabled, no policies, service-role key only.
create table if not exists public.career_application (
  id            bigint generated always as identity primary key,
  name          text        not null,
  email         text        not null,
  role          text        not null,
  portfolio_url text,
  resume_url    text,
  message       text        not null,
  status        text        not null default 'new',
  created_at    timestamptz not null default now()
);

alter table public.career_application enable row level security;

-- Resumes land in a PRIVATE `career-resumes` bucket (create it under
-- Storage with Private access; the service key bypasses bucket policies).
-- Only the storage path is stored on the row; review files in the
-- Supabase dashboard. Run once:
--   insert into storage.buckets (id, name, public) values
--     ('career-resumes', 'career-resumes', false)
--   on conflict (id) do nothing;

create index if not exists career_application_status_created_idx
  on public.career_application (status, created_at desc);

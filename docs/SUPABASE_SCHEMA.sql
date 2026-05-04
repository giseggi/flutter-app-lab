-- Shokuba MVP schema draft for Korean workers in Japan.
-- Run in a Supabase project SQL editor, then tighten policies for production.

create type board_kind as enum ('all', 'workplace', 'visa_labor', 'life');
create type report_target_type as enum ('post', 'comment');
create type report_status as enum ('open', 'reviewing', 'resolved', 'rejected');

create table public.companies (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email_domain text not null unique,
  industry text not null default '미설정',
  created_at timestamptz not null default now()
);

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  company_id uuid references public.companies(id),
  job_badge text not null default '미설정',
  created_at timestamptz not null default now()
);

create table public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  body text not null,
  board_kind board_kind not null default 'all',
  company_badge text not null default '인증된 회사',
  job_badge text not null default '미설정',
  comment_count integer not null default 0,
  reaction_count integer not null default 0,
  created_at timestamptz not null default now()
);

create table public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete cascade,
  body text not null,
  company_badge text not null default '인증된 회사',
  job_badge text not null default '미설정',
  created_at timestamptz not null default now()
);

create table public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  target_type report_target_type not null,
  target_id uuid not null,
  reason text not null,
  status report_status not null default 'open',
  created_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  email_domain text;
  resolved_company_id uuid;
begin
  email_domain := lower(split_part(new.email, '@', 2));

  insert into public.companies (name, email_domain)
  values (email_domain, email_domain)
  on conflict (email_domain) do update
    set email_domain = excluded.email_domain
  returning id into resolved_company_id;

  insert into public.profiles (id, company_id)
  values (new.id, resolved_company_id)
  on conflict (id) do nothing;

  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

alter table public.companies enable row level security;
alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.comments enable row level security;
alter table public.reports enable row level security;

create policy "authenticated users can read companies"
on public.companies for select
to authenticated
using (true);

create policy "users can read profiles"
on public.profiles for select
to authenticated
using (true);

create policy "users can manage own profile"
on public.profiles for all
to authenticated
using (id = auth.uid())
with check (id = auth.uid());

create policy "authenticated users can read posts"
on public.posts for select
to authenticated
using (true);

create policy "users can create own posts"
on public.posts for insert
to authenticated
with check (author_id = auth.uid());

create policy "users can update own posts"
on public.posts for update
to authenticated
using (author_id = auth.uid())
with check (author_id = auth.uid());

create policy "authenticated users can read comments"
on public.comments for select
to authenticated
using (true);

create policy "users can create own comments"
on public.comments for insert
to authenticated
with check (author_id = auth.uid());

create policy "users can create own reports"
on public.reports for insert
to authenticated
with check (reporter_id = auth.uid());

create policy "users can read own reports"
on public.reports for select
to authenticated
using (reporter_id = auth.uid());

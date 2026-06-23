-- In-app announcements shown as a banner on the Today screen.
-- Controlled remotely so messages can be pushed without an app release.

create table if not exists public.announcements (
  id         uuid primary key default gen_random_uuid(),
  body       text not null,
  link       text,
  link_label text,
  active     boolean not null default true,
  starts_at  timestamptz,
  ends_at    timestamptz,
  created_at timestamptz not null default now()
);

alter table public.announcements enable row level security;

create policy "Announcements are readable by authenticated users"
  on public.announcements for select
  to authenticated
  using (true);

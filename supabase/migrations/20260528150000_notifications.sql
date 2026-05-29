alter table public.profiles
  add column if not exists fcm_token text;

create table if not exists public.notifications (
  id         uuid        not null default gen_random_uuid() primary key,
  user_ids   uuid[]      not null default '{}',
  body       text        not null,
  link       text,
  created_at timestamptz not null default now()
);

alter table public.notifications enable row level security;

-- Move fcm_token out of profiles into a private table with strict RLS.
-- profiles is now readable by all authenticated users, so fcm_token must not live there.

create table public.device_tokens (
  user_id    uuid not null references public.profiles(id) on delete cascade primary key,
  fcm_token  text not null,
  updated_at timestamptz not null default now()
);

alter table public.device_tokens enable row level security;

create policy "Users can manage their own device token"
  on public.device_tokens
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Migrate existing tokens
insert into public.device_tokens (user_id, fcm_token)
select id, fcm_token
from public.profiles
where fcm_token is not null
on conflict (user_id) do nothing;

-- Remove from profiles
alter table public.profiles drop column if exists fcm_token;

-- Trigger to keep updated_at fresh
create trigger set_device_tokens_updated_at
  before update on public.device_tokens
  for each row execute function public.handle_updated_at();

-- Sapies — the game's reward currency.
-- Balance lives on profiles; sapie_harvests tracks how much of each day's
-- personal score has already been collected so a later, higher score only
-- tops up the difference. Harvest is server-side and reads the real score,
-- so the collectable amount can never be forged by the client.

alter table public.profiles
  add column if not exists sapies integer not null default 0;

create table public.sapie_harvests (
  user_id    uuid        not null references public.profiles(id) on delete cascade,
  date       date        not null,
  harvested  integer     not null default 0,
  updated_at timestamptz not null default now(),
  primary key (user_id, date)
);

alter table public.sapie_harvests enable row level security;

create policy "Users can read their own harvests"
  on public.sapie_harvests for select
  using (auth.uid() = user_id);

-- No insert/update/delete policies: only harvest_sapies (security definer)
-- writes this table.

-- Collect the uncollected part of a day's personal score. Idempotent within
-- the day: calling again once fully harvested collects 0.
create or replace function public.harvest_sapies(p_date date)
returns table (balance integer, collected integer)
language plpgsql security definer
set search_path = public
as $$
declare
  v_uid       uuid := auth.uid();
  v_score     integer;
  v_harvested integer;
  v_amount    integer;
begin
  if v_uid is null then
    raise exception 'not authenticated';
  end if;

  select personal_score into v_score
  from public.scores
  where user_id = v_uid and date = p_date;

  if v_score is null then
    return query select p.sapies, 0 from public.profiles p where p.id = v_uid;
    return;
  end if;

  select h.harvested into v_harvested
  from public.sapie_harvests h
  where h.user_id = v_uid and h.date = p_date;

  v_amount := greatest(0, v_score - coalesce(v_harvested, 0));

  if v_amount > 0 then
    insert into public.sapie_harvests (user_id, date, harvested, updated_at)
    values (v_uid, p_date, v_score, now())
    on conflict (user_id, date)
      do update set harvested = excluded.harvested, updated_at = now();

    update public.profiles set sapies = sapies + v_amount where id = v_uid;
  end if;

  return query select p.sapies, v_amount from public.profiles p where p.id = v_uid;
end;
$$;

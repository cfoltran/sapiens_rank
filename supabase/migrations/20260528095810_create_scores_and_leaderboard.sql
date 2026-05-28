-- Add latest_sync to profiles (tracks last backfilled date)
alter table public.profiles
  add column latest_sync date;

create table public.scores (
  id         uuid        not null default gen_random_uuid() primary key,
  user_id    uuid        not null references public.profiles on delete cascade,
  date       date        not null,
  score      smallint    not null check (score between 0 and 100),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  unique (user_id, date)
);

alter table public.scores enable row level security;

create policy "Users can read their own scores"
  on public.scores for select
  using (auth.uid() = user_id);

create policy "Users can upsert their own scores"
  on public.scores for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own scores"
  on public.scores for update
  using (auth.uid() = user_id);

create trigger set_scores_updated_at
  before update on public.scores
  for each row execute function public.handle_updated_at();

create table public.leaderboard (
  user_id      uuid     not null references public.profiles on delete cascade primary key,
  score        real     not null,
  rank_world   int,
  rank_country int,
  country      text,
  rank_delta   int      default 0, 
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

alter table public.leaderboard enable row level security;

create policy "Leaderboard is publicly readable"
  on public.leaderboard for select
  using (true);

create trigger set_leaderboard_updated_at
  before update on public.leaderboard
  for each row execute function public.handle_updated_at();

create or replace function public.refresh_leaderboard()
returns void language plpgsql security definer as $$
begin
  -- Step 1: upsert rolling 7-day averages
  insert into public.leaderboard (user_id, score, country, updated_at)
  select
    s.user_id,
    round(avg(s.score))::real,
    p.country,
    now()
  from public.scores s
  join public.profiles p on p.id = s.user_id
  where s.date >= current_date - interval '6 days'
  group by s.user_id, p.country
  on conflict (user_id) do update
    set score      = excluded.score,
        country    = excluded.country,
        rank_delta = public.leaderboard.rank_world  -- will be overwritten below
                     - (select rank() over (order by excluded.score desc)
                        from public.leaderboard limit 1),
        updated_at = excluded.updated_at;

  -- Step 2: world ranks
  update public.leaderboard l
  set rank_world = r.rk
  from (
    select user_id, rank() over (order by score desc) as rk
    from public.leaderboard
  ) r
  where l.user_id = r.user_id;

  -- Step 3: country ranks
  update public.leaderboard l
  set rank_country = r.rk
  from (
    select user_id, rank() over (partition by country order by score desc) as rk
    from public.leaderboard
  ) r
  where l.user_id = r.user_id;
end;
$$;

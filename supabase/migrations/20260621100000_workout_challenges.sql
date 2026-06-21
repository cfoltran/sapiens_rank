-- Workout challenges: a challenge where players race to cover a target distance
-- in a given sport, and the best time (= best pace) over that distance wins.

-- Raw distance-based workouts synced from HealthKit, one row per session.
create table public.workouts (
  id               uuid        not null default gen_random_uuid() primary key,
  user_id          uuid        not null references public.profiles(id) on delete cascade,
  type             text        not null check (type in ('running', 'walking', 'swimming', 'cycling')),
  started_at       timestamptz not null,
  distance_km      numeric,
  duration_seconds integer     not null check (duration_seconds > 0),
  kcal             integer,
  created_at       timestamptz not null default now(),
  unique (user_id, type, started_at)
);

alter table public.workouts enable row level security;

create policy "Users manage own workouts"
  on public.workouts for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create index on public.workouts (user_id, type, started_at);

-- Extend challenges with the workout flavour.
alter table public.challenges drop constraint if exists challenges_metric_check;

alter table public.challenges
  add column challenge_type     text    not null default 'score'
    check (challenge_type in ('score', 'workout')),
  add column workout_type       text
    check (workout_type in ('running', 'walking', 'swimming', 'cycling')),
  add column target_distance_km numeric;

-- Standings now handle both flavours behind one entry point.
-- Score challenges: average daily score, highest wins.
-- Workout challenges: best time over the target distance, lowest wins;
-- non-finishers rank below finishers, ordered by furthest distance reached.
-- Return shape gains 3 columns, so the old function must be dropped first
-- (create or replace cannot change a function's return type).
drop function if exists public.get_challenge_standings(uuid);

create or replace function public.get_challenge_standings(p_challenge_id uuid)
returns table (
  user_id          uuid,
  score            numeric,
  rank             bigint,
  duration_seconds integer,
  distance_km      numeric,
  completed        boolean
) language plpgsql stable security definer as $$
declare
  v_type text;
begin
  select challenge_type into v_type
  from public.challenges where id = p_challenge_id;

  if v_type = 'workout' then
    return query
    with c as (
      select workout_type, target_distance_km, starts_at,
             coalesce(ends_at, now()) as ends_at
      from public.challenges where id = p_challenge_id
    ),
    best as (
      select
        cp.user_id,
        min(w.duration_seconds) filter (
          where w.distance_km >= c.target_distance_km
        ) as dur,
        max(w.distance_km) as best_dist
      from public.challenge_participants cp
      cross join c
      left join public.workouts w
        on  w.user_id    = cp.user_id
        and w.type       = c.workout_type
        and w.started_at >= c.starts_at
        and w.started_at <  c.ends_at
      where cp.challenge_id = p_challenge_id
        and cp.status       = 'accepted'
      group by cp.user_id
    )
    select
      b.user_id,
      0::numeric as score,
      rank() over (
        order by (b.dur is null), b.dur asc, coalesce(b.best_dist, 0) desc
      ) as rank,
      b.dur                  as duration_seconds,
      b.best_dist            as distance_km,
      (b.dur is not null)    as completed
    from best b;
  else
    return query
    select
      cp.user_id,
      coalesce(round(avg(s.personal_score)::numeric, 1), 0) as score,
      rank() over (order by coalesce(avg(s.personal_score), 0) desc) as rank,
      null::integer as duration_seconds,
      null::numeric as distance_km,
      false         as completed
    from public.challenge_participants cp
    join public.challenges c on c.id = cp.challenge_id
    left join public.scores s
      on  s.user_id = cp.user_id
      and s.date   >= c.starts_at::date
      and s.date   <= coalesce(c.ends_at, now())::date
    where cp.challenge_id = p_challenge_id
      and cp.status       = 'accepted'
    group by cp.user_id;
  end if;
end;
$$;

-- Workout sessions (individual HealthKit workouts, persisted for challenge tracking)
create table public.workouts (
  id               uuid        not null default gen_random_uuid() primary key,
  user_id          uuid        not null references public.profiles(id) on delete cascade,
  date             date        not null,
  workout_type     text        not null,  -- 'running', 'cycling', etc. (lowercase)
  duration_minutes smallint    not null,
  distance_km      numeric(6, 3),
  kcal             smallint,
  started_at       timestamptz not null,
  created_at       timestamptz not null default now(),
  unique (user_id, started_at)
);

alter table public.workouts enable row level security;

create policy "Owner can manage own workouts"
  on public.workouts for all
  using  (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create index on public.workouts (user_id, date);
create index on public.workouts (user_id, workout_type, date);

-- Allow workout metric types and add optional goal columns
alter table public.challenges
  drop constraint challenges_metric_check;

alter table public.challenges
  add constraint challenges_metric_check
    check (metric in ('total', 'running', 'cycling')),
  add column goal_value numeric,   -- e.g. 10 for 10 km
  add column goal_unit  text;      -- 'km'

-- Updated standings: branches on metric type
create or replace function public.get_challenge_standings(p_challenge_id uuid)
returns table (user_id uuid, score numeric, rank bigint)
language sql stable security definer as $$
  select
    cp.user_id,
    case c.metric
      when 'total' then coalesce(round(avg(s.personal_score)::numeric, 1), 0)
      else              coalesce(round(sum(w.distance_km)::numeric, 2), 0)
    end as score,
    rank() over (
      order by case c.metric
        when 'total' then coalesce(avg(s.personal_score), 0)
        else              coalesce(sum(w.distance_km)::float8, 0)
      end desc
    ) as rank
  from public.challenge_participants cp
  join public.challenges c on c.id = cp.challenge_id
  left join public.scores s
    on  c.metric = 'total'
    and s.user_id = cp.user_id
    and s.date >= c.starts_at::date
    and s.date <= coalesce(c.ends_at, now())::date
  left join public.workouts w
    on  c.metric in ('running', 'cycling')
    and w.user_id      = cp.user_id
    and w.workout_type = c.metric
    and w.date >= c.starts_at::date
    and w.date <= coalesce(c.ends_at, now())::date
  where cp.challenge_id = p_challenge_id
    and cp.status       = 'accepted'
  group by cp.user_id, c.metric;
$$;

-- Close challenge early when a participant reaches the distance goal
create or replace function public.check_workout_goal()
returns trigger language plpgsql security definer as $$
declare
  v_challenge record;
  v_total     numeric;
begin
  for v_challenge in
    select c.id, c.metric, c.goal_value, c.starts_at
    from public.challenge_participants cp
    join public.challenges c on c.id = cp.challenge_id
    where cp.user_id   = new.user_id
      and cp.status    = 'accepted'
      and c.status     = 'live'
      and c.metric     = new.workout_type
      and c.goal_value is not null
  loop
    select coalesce(sum(distance_km), 0) into v_total
    from public.workouts
    where user_id      = new.user_id
      and workout_type = v_challenge.metric
      and date         >= v_challenge.starts_at::date;

    if v_total >= v_challenge.goal_value then
      update public.challenges
      set status    = 'done',
          winner_id = new.user_id,
          ends_at   = now()
      where id = v_challenge.id;
    end if;
  end loop;

  return new;
end;
$$;

create trigger workout_goal_check
  after insert on public.workouts
  for each row execute function public.check_workout_goal();

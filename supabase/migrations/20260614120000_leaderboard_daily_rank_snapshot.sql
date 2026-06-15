-- Option A: make rank_delta a real daily trend.
-- Previously rank_delta was the rank change since the *previous* refresh
-- (hourly cron), so for almost everyone it was 0 or noise. We now freeze a
-- per-day reference rank (rank_world_ref) once at midnight and compute
-- rank_delta against it, so the "trend" badge means "places gained today"
-- and stays stable between app opens during the day.

alter table public.leaderboard
  add column if not exists rank_world_ref int;

-- Seed the reference with the current rank so deltas start at 0, not garbage.
-- Guarded so re-running the migration never clobbers an in-progress day.
update public.leaderboard set rank_world_ref = rank_world
where rank_world_ref is null;

-- Freeze today's starting rank for everyone. Runs once a day, just after
-- midnight, before the :15 hourly refresh recomputes deltas against it.
create or replace function public.snapshot_leaderboard_ranks()
returns void language sql security definer as $$
  update public.leaderboard set rank_world_ref = rank_world;
$$;

-- refresh_leaderboard now computes rank_delta against the daily snapshot
-- instead of against the immediately previous refresh.
create or replace function public.refresh_leaderboard()
returns void language plpgsql security definer as $$
begin
  insert into public.leaderboard (user_id, score, country, updated_at)
  select
    u.user_id,
    (coalesce(sum(s.score), 0) / 7.0)::real,
    p.country,
    now()
  from (
    select user_id from public.leaderboard
    union
    select user_id from public.scores
    where date >= current_date - interval '6 days'
  ) u
  join public.profiles p on p.id = u.user_id
  left join public.scores s
    on s.user_id = u.user_id
   and s.date >= current_date - interval '6 days'
  group by u.user_id, p.country
  on conflict (user_id) do update
    set score      = excluded.score,
        country    = excluded.country,
        updated_at = excluded.updated_at;

  update public.leaderboard l
  set rank_world = r.rk,
      rank_delta = coalesce(l.rank_world_ref - r.rk, 0)
  from (
    select user_id,
           row_number() over (order by score desc, user_id) as rk
    from public.leaderboard
  ) r
  where l.user_id = r.user_id;

  update public.leaderboard l
  set rank_country = r.rk
  from (
    select user_id,
           row_number() over (partition by country order by score desc, user_id) as rk
    from public.leaderboard
  ) r
  where l.user_id = r.user_id;
end;
$$;

-- pg_cron upserts by job name, so this is safe to re-run.
select cron.schedule(
  'snapshot-leaderboard-ranks',
  '0 0 * * *',
  'select public.snapshot_leaderboard_ranks()'
);

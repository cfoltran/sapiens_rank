-- Fix refresh_leaderboard: the deployed version referenced a non-existent
-- leaderboard.name column (names come from the profiles join in the app).
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
        updated_at = excluded.updated_at;

  -- Step 2: world ranks — tiebreaker: earliest created_at wins
  update public.leaderboard l
  set rank_world = r.rk
  from (
    select user_id,
           row_number() over (order by score desc, created_at asc) as rk
    from public.leaderboard
  ) r
  where l.user_id = r.user_id;

  -- Step 3: country ranks — same tiebreaker
  update public.leaderboard l
  set rank_country = r.rk
  from (
    select user_id,
           row_number() over (partition by country order by score desc, created_at asc) as rk
    from public.leaderboard
  ) r
  where l.user_id = r.user_id;

  -- Step 4: rank_delta (previous rank_world - new rank_world, positive = moved up)
  update public.leaderboard l
  set rank_delta = coalesce(l.rank_world - r.rk, 0)
  from (
    select user_id,
           row_number() over (order by score desc, created_at asc) as rk
    from public.leaderboard
  ) r
  where l.user_id = r.user_id;
end;
$$;

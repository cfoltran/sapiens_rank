-- Leaderboard fairness rework:
-- 1. score = sum of last 7 days / 7 (missed days count as 0) so inactive
--    users decay naturally to 0 instead of keeping a frozen average.
-- 2. recompute everyone already on the board, not just recently active users.
-- 3. unrounded score + user_id tiebreaker replaces the created_at tiebreaker
--    that systematically favored older accounts.
-- Also fixes rank_delta being computed after rank_world was overwritten
-- (was always 0).
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
      rank_delta = coalesce(l.rank_world - r.rk, 0)
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

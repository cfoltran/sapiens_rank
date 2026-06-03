create or replace function public.get_challenge_standings(p_challenge_id uuid)
returns table (
  user_id  uuid,
  score    numeric,
  rank     bigint
) language sql stable security definer as $$
  select
    cp.user_id,
    coalesce(round(avg(s.personal_score)::numeric, 1), 0) as score,
    rank() over (order by coalesce(avg(s.personal_score), 0) desc) as rank
  from public.challenge_participants cp
  join public.challenges c on c.id = cp.challenge_id
  left join public.scores s
    on  s.user_id = cp.user_id
    and s.date >= c.starts_at::date
    and s.date <= coalesce(c.ends_at, now())::date
  where cp.challenge_id = p_challenge_id
    and cp.status       = 'accepted'
  group by cp.user_id;
$$;

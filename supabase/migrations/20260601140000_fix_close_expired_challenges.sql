create or replace function public.close_expired_challenges()
returns void language plpgsql security definer as $$
declare
  v_id        uuid;
  v_winner_id uuid;
begin
  for v_id in
    select id from public.challenges
    where status = 'live' and ends_at <= now()
  loop
    with top1 as (
      select user_id from public.get_challenge_standings(v_id) where rank = 1
    )
    select user_id into v_winner_id
    from top1
    where (select count(*) from top1) = 1
    limit 1;  -- null if tie (2+ players share rank 1)

    update public.challenges
    set status = 'done', winner_id = v_winner_id
    where id = v_id;
  end loop;
end;
$$;

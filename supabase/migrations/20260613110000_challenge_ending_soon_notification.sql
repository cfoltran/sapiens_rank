-- Notify participants 1h before a live challenge ends so they open the app.

alter table public.challenges
  add column if not exists ending_soon_notified_at timestamptz;

create or replace function public.notify_challenges_ending_soon()
returns void language plpgsql security definer as $$
declare
  v_challenge challenges%rowtype;
begin
  for v_challenge in
    select * from public.challenges
    where status = 'live'
      and ending_soon_notified_at is null
      and ends_at > now()
      and ends_at <= now() + interval '2 hour'
  loop
    insert into notifications (user_ids, body, link)
    select
      array_agg(user_id),
      'Challenge ends soon, open the app to update your score!',
      'challenge://' || v_challenge.id::text
    from public.challenge_participants
    where challenge_id = v_challenge.id
      and status = 'accepted';

    update public.challenges
    set ending_soon_notified_at = now()
    where id = v_challenge.id;
  end loop;
end;
$$;

select cron.schedule(
  'notify-challenges-ending-soon',
  '*/60 * * * *',
  'select public.notify_challenges_ending_soon()'
);

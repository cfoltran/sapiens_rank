-- Evening reminder to check today's SapiensScore.
-- Skip users who already opened the app today (latest_sync = current_date)
-- so we don't spam active users. Only target users with a device token.

create or replace function public.notify_evening_score()
returns void language plpgsql security definer as $$
declare
  v_ids uuid[];
begin
  select array_agg(distinct p.id) into v_ids
  from profiles p
  join device_tokens d on d.user_id = p.id
  where p.latest_sync is distinct from current_date;

  -- Never insert an empty array: the push function treats '{}' as broadcast-to-all.
  if v_ids is null then
    return;
  end if;

  insert into notifications (user_ids, body, link)
  values (
    v_ids,
    'Where do you stand today? 📊 Check your SapiensScore',
    'today://'
  );
end;
$$;

-- 21:00 UTC (evening in Europe). Adjust the hour to your main audience's timezone.
select cron.schedule(
  'notify-evening-score',
  '0 21 * * *',
  'select public.notify_evening_score()'
);

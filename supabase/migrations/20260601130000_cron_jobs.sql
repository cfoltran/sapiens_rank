create extension if not exists pg_cron with schema extensions;

grant usage on schema cron to postgres;
grant all privileges on all tables in schema cron to postgres;

-- Refresh leaderboard every hour (rolling 7-day averages + ranks)
select cron.schedule(
  'refresh-leaderboard',
  '15 * * * *',
  'select public.refresh_leaderboard()'
);

-- Close expired challenges every hour and notify participants
select cron.schedule(
  'close-expired-challenges',
  '45 * * * *',
  'select public.close_expired_challenges()'
);

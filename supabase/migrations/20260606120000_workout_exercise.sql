alter table public.profiles
  add column if not exists target_daily_exercise_minutes smallint default 30;

alter table public.daily_metrics
  add column if not exists exercise_minutes smallint;

alter table public.profiles
  add column target_steps        int,
  add column target_kcal         real,
  add column target_sleep_hours  real,
  add column target_stand_hours  smallint;

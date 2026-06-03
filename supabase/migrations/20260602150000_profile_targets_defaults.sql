alter table public.profiles
  alter column target_steps       set default 7000,
  alter column target_kcal        set default 380,
  alter column target_sleep_hours set default 7.0,
  alter column target_stand_hours set default 12;

update public.profiles set
  target_steps       = 7000,
  target_kcal        = 380,
  target_sleep_hours = 7.0,
  target_stand_hours = 12
where target_steps is null;
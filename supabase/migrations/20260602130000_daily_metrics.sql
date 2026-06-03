create table public.daily_metrics (
  user_id     uuid     not null references public.profiles on delete cascade,
  date        date     not null,
  sleep_hours real,
  steps       int,
  kcal        real,
  stand_hours smallint,
  hrv         real,
  resting_hr  real,
  primary key (user_id, date)
);

alter table public.daily_metrics enable row level security;

create policy "Users can manage their own metrics"
  on public.daily_metrics
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

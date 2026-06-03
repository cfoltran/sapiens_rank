alter table public.scores
  add column if not exists personal_score smallint check (personal_score between 0 and 100);

alter table public.daily_metrics
  drop column if exists personal_score;

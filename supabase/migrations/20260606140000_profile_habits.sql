alter table public.profiles
  add column if not exists height_cm smallint,
  add column if not exists weight_kg real,
  add column if not exists bmi_frequency text,
  add column if not exists smokes boolean,
  add column if not exists cigarettes_per_day smallint,
  add column if not exists drinks boolean,
  add column if not exists drinks_per_week smallint;

-- habits table already exists with correct schema and RLS policies.
-- Remove duplicate habits columns from the public profiles table.
alter table public.profiles
  drop column if exists height_cm,
  drop column if exists weight_kg,
  drop column if exists bmi_frequency,
  drop column if exists smokes,
  drop column if exists cigarettes_per_day,
  drop column if exists drinks,
  drop column if exists drinks_per_week;

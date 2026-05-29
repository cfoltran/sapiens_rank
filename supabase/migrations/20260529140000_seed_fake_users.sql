-- Public read: only authenticated users can read name + country of others.
-- age, onboarding_step, onboarding_done, latest_sync stay private (own row only).
-- RLS is row-level so we can't restrict columns here, but we expose a narrow view instead.
create policy "Authenticated users can read public profile fields"
  on public.profiles for select
  using (auth.role() = 'authenticated');

-- ── Fake auth users ───────────────────────────────────────────────────────────
-- Insert directly into auth.users so profiles FK constraint is satisfied.

insert into auth.users (
  id, instance_id, email, encrypted_password,
  email_confirmed_at, created_at, updated_at,
  raw_app_meta_data, raw_user_meta_data,
  is_super_admin, role, aud
)
values
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'leo.martin@fake.sapiens', '', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000000', 'sofia.chen@fake.sapiens', '', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000000', 'marcus.berg@fake.sapiens', '', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000000', 'amara.diallo@fake.sapiens', '', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000000', 'yuki.tanaka@fake.sapiens', '', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000000', 'noah.smith@fake.sapiens', '', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000000', 'elena.petrov@fake.sapiens', '', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000000', 'carlos.vega@fake.sapiens', '', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-000000000009', '00000000-0000-0000-0000-000000000000', 'priya.nair@fake.sapiens', '', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000000', 'luca.ferrari@fake.sapiens', '', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000000', 'aisha.hassan@fake.sapiens', '', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000000', 'tom.wheeler@fake.sapiens', '', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated', 'authenticated')
on conflict (id) do nothing;

-- ── Profiles ──────────────────────────────────────────────────────────────────

insert into public.profiles (id, name, age, country, onboarding_done)
values
  ('00000000-0000-0000-0000-000000000001', 'Léo Martin',    27, 'FR', true),
  ('00000000-0000-0000-0000-000000000002', 'Sofia Chen',    24, 'CN', true),
  ('00000000-0000-0000-0000-000000000003', 'Marcus Berg',   31, 'SE', true),
  ('00000000-0000-0000-0000-000000000004', 'Amara Diallo',  26, 'SN', true),
  ('00000000-0000-0000-0000-000000000005', 'Yuki Tanaka',   29, 'JP', true),
  ('00000000-0000-0000-0000-000000000006', 'Noah Smith',    33, 'US', true),
  ('00000000-0000-0000-0000-000000000007', 'Elena Petrov',  28, 'RU', true),
  ('00000000-0000-0000-0000-000000000008', 'Carlos Vega',   25, 'ES', true),
  ('00000000-0000-0000-0000-000000000009', 'Priya Nair',    30, 'IN', true),
  ('00000000-0000-0000-0000-000000000010', 'Luca Ferrari',  35, 'IT', true),
  ('00000000-0000-0000-0000-000000000011', 'Aisha Hassan',  23, 'NG', true),
  ('00000000-0000-0000-0000-000000000012', 'Tom Wheeler',   38, 'GB', true)
on conflict (id) do nothing;

-- ── Scores (last 7 days) ──────────────────────────────────────────────────────
-- Each fake user gets realistic daily scores so the leaderboard avg is meaningful.

insert into public.scores (user_id, date, score)
select u.id, current_date - n, u.base + floor(random() * 11 - 5)::int
from (
  values
    ('00000000-0000-0000-0000-000000000001'::uuid, 82),
    ('00000000-0000-0000-0000-000000000002'::uuid, 91),
    ('00000000-0000-0000-0000-000000000003'::uuid, 74),
    ('00000000-0000-0000-0000-000000000004'::uuid, 88),
    ('00000000-0000-0000-0000-000000000005'::uuid, 95),
    ('00000000-0000-0000-0000-000000000006'::uuid, 67),
    ('00000000-0000-0000-0000-000000000007'::uuid, 79),
    ('00000000-0000-0000-0000-000000000008'::uuid, 85),
    ('00000000-0000-0000-0000-000000000009'::uuid, 72),
    ('00000000-0000-0000-0000-000000000010'::uuid, 90),
    ('00000000-0000-0000-0000-000000000011'::uuid, 83),
    ('00000000-0000-0000-0000-000000000012'::uuid, 61)
) as u(id, base)
cross join generate_series(0, 6) as n
on conflict (user_id, date) do nothing;

-- ── Leaderboard ───────────────────────────────────────────────────────────────

select public.refresh_leaderboard();

-- Enums
create type public.guild_role    as enum ('leader', 'member');
create type public.attack_status as enum ('active', 'resolved', 'cancelled');
create type public.attack_metric as enum ('steps', 'sleep', 'calories', 'stand', 'hrv');

-- Guilds
create table public.guilds (
  id         uuid        not null default gen_random_uuid() primary key,
  name       text        not null unique,
  color      text        not null,
  created_by uuid        not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.guilds enable row level security;

create policy "Guilds are publicly readable"
  on public.guilds for select using (true);

-- Guild members
create table public.guild_members (
  guild_id  uuid              not null references public.guilds(id) on delete cascade,
  user_id   uuid              not null references public.profiles(id) on delete cascade,
  role      public.guild_role not null default 'member',
  joined_at timestamptz       not null default now(),
  primary key (guild_id, user_id)
);

alter table public.guild_members enable row level security;

create policy "Guild members are publicly readable"
  on public.guild_members for select using (true);

create policy "Users can join a guild"
  on public.guild_members for insert
  with check (auth.uid() = user_id);

create policy "Members can leave a guild"
  on public.guild_members for delete
  using (auth.uid() = user_id);

-- guild_members exists now, safe to reference in guilds policy
create policy "Authenticated users can create a guild"
  on public.guilds for insert
  with check (
    auth.uid() = created_by
    and not exists (
      select 1 from public.guild_members where user_id = auth.uid()
    )
  );

-- Territories (grid 12×18 = 216 cells, seeded below)
create table public.territories (
  id             uuid        not null default gen_random_uuid() primary key,
  grid_x         integer     not null,
  grid_y         integer     not null,
  owner_guild_id uuid        references public.guilds(id) on delete set null,
  conquered_at   timestamptz,
  unique (grid_x, grid_y)
);

alter table public.territories enable row level security;

create policy "Territories are publicly readable"
  on public.territories for select using (true);

-- Seed 12×18 grid (all neutral)
insert into public.territories (grid_x, grid_y)
select x, y
from generate_series(0, 11) as x,
     generate_series(0, 17) as y;

-- Attacks
create table public.attacks (
  id                uuid                 not null default gen_random_uuid() primary key,
  attacker_guild_id uuid                 not null references public.guilds(id) on delete cascade,
  defender_guild_id uuid                 references public.guilds(id) on delete cascade,
  territory_id      uuid                 not null references public.territories(id) on delete cascade,
  metric            public.attack_metric not null,
  starts_at         timestamptz          not null default now(),
  ends_at           timestamptz          not null,
  status            public.attack_status not null default 'active',
  attacker_score    numeric,
  defender_score    numeric,
  winner_guild_id   uuid                 references public.guilds(id) on delete set null,
  created_at        timestamptz          not null default now(),
  check (ends_at > starts_at)
);

alter table public.attacks enable row level security;

create policy "Attacks are publicly readable"
  on public.attacks for select using (true);

create policy "Guild members can create attacks"
  on public.attacks for insert
  with check (
    exists (
      select 1 from public.guild_members
      where guild_id = attacker_guild_id
        and user_id = auth.uid()
    )
  );

-- Indexes
create index on public.guild_members (user_id);
create index on public.territories (owner_guild_id);
create index on public.attacks (status, ends_at);
create index on public.attacks (attacker_guild_id);
create index on public.attacks (territory_id);

-- max_members: 5 base + 1 per territory owned
create or replace function public.guild_max_members(p_guild_id uuid)
returns integer language sql stable security definer as $$
  select 5 + count(*)::integer
  from public.territories
  where owner_guild_id = p_guild_id;
$$;

-- Enforce single guild membership per user
create or replace function public.check_single_guild_membership()
returns trigger language plpgsql as $$
begin
  if exists (
    select 1 from public.guild_members where user_id = new.user_id
  ) then
    raise exception 'User is already in a guild';
  end if;
  return new;
end;
$$;

create trigger guild_single_membership
  before insert on public.guild_members
  for each row execute function public.check_single_guild_membership();

-- Enforce member capacity on join
create or replace function public.check_guild_capacity()
returns trigger language plpgsql security definer as $$
declare
  v_member_count integer;
  v_max_members  integer;
begin
  select count(*) into v_member_count
  from public.guild_members
  where guild_id = new.guild_id;

  v_max_members := public.guild_max_members(new.guild_id);

  if v_member_count >= v_max_members then
    raise exception 'Guild is full (% / % members)', v_member_count, v_max_members;
  end if;

  return new;
end;
$$;

create trigger guild_capacity_check
  before insert on public.guild_members
  for each row execute function public.check_guild_capacity();

-- Validate attack: adjacency + max 1 active attack + cannot attack own territory
create or replace function public.check_attack_valid()
returns trigger language plpgsql security definer as $$
declare
  v_territory territories%rowtype;
  v_active    integer;
begin
  select * into v_territory from public.territories where id = new.territory_id;

  if v_territory.owner_guild_id = new.attacker_guild_id then
    raise exception 'Cannot attack your own territory';
  end if;

  -- defender_guild_id must match the territory's actual owner
  if new.defender_guild_id is distinct from v_territory.owner_guild_id then
    raise exception 'defender_guild_id does not match territory owner';
  end if;

  -- No concurrent attack on the same territory
  if exists (
    select 1 from public.attacks
    where territory_id = new.territory_id
      and status = 'active'
  ) then
    raise exception 'This territory is already under attack';
  end if;

  if not exists (
    select 1 from public.territories
    where owner_guild_id = new.attacker_guild_id
      and (
        (grid_x = v_territory.grid_x + 1 and grid_y = v_territory.grid_y) or
        (grid_x = v_territory.grid_x - 1 and grid_y = v_territory.grid_y) or
        (grid_x = v_territory.grid_x     and grid_y = v_territory.grid_y + 1) or
        (grid_x = v_territory.grid_x     and grid_y = v_territory.grid_y - 1)
      )
  ) then
    raise exception 'Target territory is not adjacent to your guild territory';
  end if;

  select count(*) into v_active
  from public.attacks
  where attacker_guild_id = new.attacker_guild_id
    and status = 'active';

  if v_active >= 1 then
    raise exception 'Your guild already has an active attack';
  end if;

  return new;
end;
$$;

create trigger attack_validation
  before insert on public.attacks
  for each row execute function public.check_attack_valid();

-- Resolve a single attack: sum metric from daily_metrics, transfer territory if attacker wins
create or replace function public.resolve_attack(p_attack_id uuid)
returns void language plpgsql security definer as $$
declare
  v_attack          attacks%rowtype;
  v_attacker_score  numeric := 0;
  v_defender_score  numeric := 0;
  v_winner_guild_id uuid;
  v_metric_col      text;
  v_sql             text;
begin
  select * into v_attack
  from public.attacks
  where id = p_attack_id and status = 'active';

  if not found then return; end if;

  v_metric_col := case v_attack.metric
    when 'steps'    then 'steps'
    when 'sleep'    then 'sleep_hours'
    when 'calories' then 'kcal'
    when 'stand'    then 'stand_hours'
    when 'hrv'      then 'hrv'
  end;

  v_sql := format(
    'select coalesce(sum(dm.%I), 0)
     from public.daily_metrics dm
     join public.guild_members gm on gm.user_id = dm.user_id
     where gm.guild_id = $1
       and dm.date >= $2::date
       and dm.date <= $3::date',
    v_metric_col
  );

  execute v_sql into v_attacker_score
    using v_attack.attacker_guild_id, v_attack.starts_at, v_attack.ends_at;

  if v_attack.defender_guild_id is not null then
    execute v_sql into v_defender_score
      using v_attack.defender_guild_id, v_attack.starts_at, v_attack.ends_at;
  end if;

  if v_attacker_score > v_defender_score then
    v_winner_guild_id := v_attack.attacker_guild_id;
  elsif v_defender_score > v_attacker_score then
    v_winner_guild_id := v_attack.defender_guild_id;
  else
    v_winner_guild_id := null; -- tie: defender keeps territory
  end if;

  if v_winner_guild_id = v_attack.attacker_guild_id then
    update public.territories
    set owner_guild_id = v_attack.attacker_guild_id,
        conquered_at   = now()
    where id = v_attack.territory_id;
  end if;

  update public.attacks
  set status          = 'resolved',
      attacker_score  = v_attacker_score,
      defender_score  = v_defender_score,
      winner_guild_id = v_winner_guild_id
  where id = p_attack_id;
end;
$$;

-- Resolve all expired attacks (called by cron)
create or replace function public.close_expired_attacks()
returns void language plpgsql security definer as $$
declare
  v_id uuid;
begin
  for v_id in
    select id from public.attacks
    where status = 'active' and ends_at <= now()
  loop
    perform public.resolve_attack(v_id);
  end loop;
end;
$$;

-- Auto-add creator as leader and claim a random neutral territory on guild creation
create or replace function public.on_guild_created()
returns trigger language plpgsql security definer as $$
declare
  v_territory_id uuid;
begin
  insert into public.guild_members (guild_id, user_id, role)
  values (new.id, new.created_by, 'leader');

  select id into v_territory_id
  from public.territories
  where owner_guild_id is null
  order by random()
  limit 1;

  if v_territory_id is not null then
    update public.territories
    set owner_guild_id = new.id,
        conquered_at   = now()
    where id = v_territory_id;
  end if;

  return new;
end;
$$;

create trigger guild_created
  after insert on public.guilds
  for each row execute function public.on_guild_created();

-- Cron: resolve expired attacks every 15 minutes
select cron.schedule(
  'resolve-expired-attacks',
  '*/15 * * * *',
  'select public.close_expired_attacks()'
);

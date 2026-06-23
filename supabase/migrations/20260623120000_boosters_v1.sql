create type public.booster_type as enum ('boost', 'surge', 'blitz');

alter table public.attacks
  add column booster public.booster_type null;

create or replace function public.booster_attacker_mult(
  p_booster public.booster_type
)
returns numeric
language sql immutable
as $$
  select case p_booster
    when 'boost'  then 1.05
    when 'surge'  then 1.15
    when 'blitz'  then 1.20
    else               1.0
  end;
$$;

create or replace function public.launch_attack(
  p_territory_id      uuid,
  p_defender_guild_id uuid,
  p_metric            public.attack_metric,
  p_ends_at           timestamptz,
  p_booster           public.booster_type default null
)
returns uuid
language plpgsql security definer
as $$
declare
  v_user_id      uuid := auth.uid();
  v_guild_id     uuid;
  v_booster_cost int;
  v_attack_id    uuid;
begin
  select guild_id into v_guild_id
  from public.guild_members
  where user_id = v_user_id;

  if v_guild_id is null then
    raise exception 'not_in_guild';
  end if;

  if p_booster is not null then
    v_booster_cost := case p_booster
      when 'boost' then 300
      when 'surge' then 500
      when 'blitz' then 900
    end;

    update public.profiles
    set sapies = sapies - v_booster_cost
    where id = v_user_id
      and sapies >= v_booster_cost;

    if not found then
      raise exception 'insufficient_sapies';
    end if;
  end if;

  insert into public.attacks (
    territory_id, attacker_guild_id, defender_guild_id, metric, ends_at, booster
  )
  values (
    p_territory_id, v_guild_id, p_defender_guild_id, p_metric, p_ends_at, p_booster
  )
  returning id into v_attack_id;

  return v_attack_id;
end;
$$;

create or replace function public.update_active_attack_scores()
returns void language plpgsql security definer as $$
declare
  v_attack   attacks%rowtype;
  v_attacker numeric;
  v_defender numeric;
  v_col      text;
  v_sql      text;
begin
  for v_attack in
    select * from public.attacks where status = 'active'
  loop
    v_col := case v_attack.metric
      when 'steps'    then 'steps'
      when 'sleep'    then 'sleep_hours'
      when 'calories' then 'kcal'
      when 'stand'    then 'stand_hours'
    end;

    v_sql := format(
      'select coalesce(sum(dm.%I), 0)
       from public.daily_metrics dm
       join public.guild_members gm on gm.user_id = dm.user_id
       where gm.guild_id = $1
         and dm.date >= $2::date
         and dm.date <= $3::date',
      v_col
    );

    execute v_sql into v_attacker
      using v_attack.attacker_guild_id, v_attack.starts_at, v_attack.ends_at;

    v_attacker := v_attacker * public.booster_attacker_mult(v_attack.booster);

    if v_attack.defender_guild_id is not null then
      execute v_sql into v_defender
        using v_attack.defender_guild_id, v_attack.starts_at, v_attack.ends_at;
    else
      v_defender := 0;
    end if;

    update public.attacks
    set attacker_score = v_attacker,
        defender_score = v_defender
    where id = v_attack.id;
  end loop;
end;
$$;

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

  v_attacker_score := v_attacker_score * public.booster_attacker_mult(v_attack.booster);

  if v_attack.defender_guild_id is not null then
    execute v_sql into v_defender_score
      using v_attack.defender_guild_id, v_attack.starts_at, v_attack.ends_at;
  end if;

  if v_attacker_score > v_defender_score then
    v_winner_guild_id := v_attack.attacker_guild_id;
  elsif v_defender_score > v_attacker_score then
    v_winner_guild_id := v_attack.defender_guild_id;
  else
    v_winner_guild_id := null;
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

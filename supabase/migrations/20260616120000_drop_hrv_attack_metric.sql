-- HRV is no longer a selectable attack metric. Drop 'hrv' from the
-- attack_metric enum and the metric->column maps in the resolution functions.
-- Postgres can't DROP an enum value in place, so recreate the type.

-- Any leftover hrv attacks fall back to 'steps' (none expected pre-launch).
update public.attacks set metric = 'steps' where metric::text = 'hrv';

alter type public.attack_metric rename to attack_metric_old;
create type public.attack_metric as enum ('steps', 'sleep', 'calories', 'stand');

alter table public.attacks
  alter column metric type public.attack_metric
  using metric::text::public.attack_metric;

drop type public.attack_metric_old;

create or replace function public.update_active_attack_scores()
returns void language plpgsql security definer as $$
declare
  v_attack     attacks%rowtype;
  v_attacker   numeric;
  v_defender   numeric;
  v_col        text;
  v_sql        text;
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

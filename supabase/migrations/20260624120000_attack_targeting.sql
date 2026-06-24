-- Pay 200 Sapies to pick the attack metric instead of the random roll.
-- The previous 5-arg launch_attack is dropped and recreated with a p_choose_metric
-- flag, so exactly one overload exists. Old clients that call without the flag still
-- resolve here via the default, keeping the rollout backward-compatible.

drop function if exists public.launch_attack(
  uuid,
  uuid,
  public.attack_metric,
  timestamptz,
  public.booster_type
);

create function public.launch_attack(
  p_territory_id      uuid,
  p_defender_guild_id uuid,
  p_metric            public.attack_metric,
  p_ends_at           timestamptz,
  p_booster           public.booster_type default null,
  p_choose_metric     boolean default false
)
returns uuid
language plpgsql security definer
as $$
declare
  v_user_id   uuid := auth.uid();
  v_guild_id  uuid;
  v_cost      int := 0;
  v_attack_id uuid;
begin
  select guild_id into v_guild_id
  from public.guild_members
  where user_id = v_user_id;

  if v_guild_id is null then
    raise exception 'not_in_guild';
  end if;

  if p_booster is not null then
    v_cost := v_cost + case p_booster
      when 'boost' then 300
      when 'surge' then 500
      when 'blitz' then 900
    end;
  end if;

  if p_choose_metric then
    v_cost := v_cost + 200;
  end if;

  if v_cost > 0 then
    update public.profiles
    set sapies = sapies - v_cost
    where id = v_user_id
      and sapies >= v_cost;

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

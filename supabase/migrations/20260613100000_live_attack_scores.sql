-- Recalculate scores for all currently active attacks from daily_metrics.
-- Called before resolving expired attacks so the BattleSheet always shows
-- up-to-date numbers during a fight.
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
      when 'hrv'      then 'hrv'
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

-- Plug live score refresh into the existing every-15-min cron.
create or replace function public.close_expired_attacks()
returns void language plpgsql security definer as $$
declare
  v_id uuid;
begin
  perform public.update_active_attack_scores();

  for v_id in
    select id from public.attacks
    where status = 'active' and ends_at <= now()
  loop
    perform public.resolve_attack(v_id);
  end loop;
end;
$$;

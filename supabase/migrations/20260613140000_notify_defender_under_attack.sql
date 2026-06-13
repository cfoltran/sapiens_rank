-- Also notify the defending guild when one of their territories is attacked.

create or replace function public.notify_guild_attack_launched()
returns trigger language plpgsql security definer as $$
declare
  v_attacker_name       text;
  v_attacker_guild_name text;
  v_member_ids          uuid[];
begin
  select name into v_attacker_name
  from profiles
  where id = NEW.created_by;

  -- Attacking guild: notify the other members.
  select array_agg(user_id) into v_member_ids
  from guild_members
  where guild_id = NEW.attacker_guild_id
    and user_id is distinct from NEW.created_by;

  if v_member_ids is not null then
    insert into notifications (user_ids, body, link)
    values (
      v_member_ids,
      coalesce(v_attacker_name, 'A guild member') || ' launched an attack ⚔️',
      'map://attack/' || NEW.id::text
    );
  end if;

  -- Defending guild: notify all members their territory is under attack.
  if NEW.defender_guild_id is not null then
    select name into v_attacker_guild_name
    from guilds
    where id = NEW.attacker_guild_id;

    select array_agg(user_id) into v_member_ids
    from guild_members
    where guild_id = NEW.defender_guild_id;

    if v_member_ids is not null then
      insert into notifications (user_ids, body, link)
      values (
        v_member_ids,
        '🛡️ ' || coalesce(v_attacker_guild_name, 'A rival guild') ||
          ' is attacking your territory! Defend it.',
        'map://attack/' || NEW.id::text
      );
    end if;
  end if;

  return NEW;
end;
$$;

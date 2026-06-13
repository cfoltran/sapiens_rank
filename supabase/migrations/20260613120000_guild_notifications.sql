-- Guild notifications: a member launches an attack, and territory won/lost.

-- Track who launched an attack so we can notify the rest of the guild.
alter table public.attacks
  add column if not exists created_by uuid references public.profiles(id) default auth.uid();

-- Notify the other members of the attacking guild when one of them attacks.
create or replace function public.notify_guild_attack_launched()
returns trigger language plpgsql security definer as $$
declare
  v_attacker_name text;
  v_member_ids    uuid[];
begin
  select name into v_attacker_name
  from profiles
  where id = NEW.created_by;

  select array_agg(user_id) into v_member_ids
  from guild_members
  where guild_id = NEW.attacker_guild_id
    and user_id is distinct from NEW.created_by;

  if v_member_ids is null then
    return NEW;
  end if;

  insert into notifications (user_ids, body, link)
  values (
    v_member_ids,
    coalesce(v_attacker_name, 'A guild member') || ' launched an attack ⚔️',
    'map://attack/' || NEW.id::text
  );

  return NEW;
end;
$$;

create trigger on_guild_attack_launched
  after insert on public.attacks
  for each row execute function public.notify_guild_attack_launched();

-- Notify both guilds when a resolved attack changes territory ownership.
create or replace function public.notify_territory_change()
returns trigger language plpgsql security definer as $$
declare
  v_attacker_name text;
  v_member_ids    uuid[];
begin
  if NEW.status != 'resolved' or OLD.status = 'resolved' then
    return NEW;
  end if;

  -- Territory only changes hands when the attacker wins.
  if NEW.winner_guild_id is distinct from NEW.attacker_guild_id then
    return NEW;
  end if;

  select name into v_attacker_name
  from guilds
  where id = NEW.attacker_guild_id;

  -- Attacking guild conquered a territory.
  select array_agg(user_id) into v_member_ids
  from guild_members
  where guild_id = NEW.attacker_guild_id;

  if v_member_ids is not null then
    insert into notifications (user_ids, body, link)
    values (
      v_member_ids,
      '🚩 Your guild conquered a new territory!',
      'map://'
    );
  end if;

  -- Defending guild lost a territory.
  if NEW.defender_guild_id is not null then
    select array_agg(user_id) into v_member_ids
    from guild_members
    where guild_id = NEW.defender_guild_id;

    if v_member_ids is not null then
      insert into notifications (user_ids, body, link)
      values (
        v_member_ids,
        '💔 ' || coalesce(v_attacker_name, 'A rival guild') || ' captured one of your territories',
        'map://'
      );
    end if;
  end if;

  return NEW;
end;
$$;

create trigger on_territory_change
  after update of status on public.attacks
  for each row execute function public.notify_territory_change();

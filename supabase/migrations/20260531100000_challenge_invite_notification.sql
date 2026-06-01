create or replace function notify_challenge_invite()
returns trigger language plpgsql security definer as $$
declare
  v_creator_name text;
begin
  if NEW.is_creator then
    return NEW;
  end if;

  select p.name into v_creator_name
  from challenge_participants cp
  join profiles p on p.id = cp.user_id
  where cp.challenge_id = NEW.challenge_id
    and cp.is_creator = true
  limit 1;

  insert into notifications (user_ids, body, link)
  values (
    array[NEW.user_id],
    coalesce(v_creator_name, 'A Sapien') || ' challenged you ⚔️',
    'challenge://' || NEW.challenge_id::text
  );

  return NEW;
end;
$$;

create trigger on_challenge_invite
  after insert on challenge_participants
  for each row execute function notify_challenge_invite();

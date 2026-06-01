create or replace function notify_challenge_done()
returns trigger language plpgsql security definer as $$
declare
  v_winner_name    text;
  v_participant_id uuid;
begin
  if NEW.status != 'done' or OLD.status = 'done' then
    return NEW;
  end if;

  if NEW.winner_id is not null then
    select name into v_winner_name
    from profiles
    where id = NEW.winner_id;
  end if;

  for v_participant_id in
    select user_id from challenge_participants
    where challenge_id = NEW.id and status = 'accepted'
  loop
    insert into notifications (user_ids, body, link)
    values (
      array[v_participant_id],
      case
        when NEW.winner_id is null
          then 'Challenge ended in a draw 🤝'
        when v_participant_id = NEW.winner_id
          then '🏆 You won the challenge!'
        else coalesce(v_winner_name, 'Your opponent') || ' won the challenge'
      end,
      'challenge://result/' || NEW.id::text
    );
  end loop;

  return NEW;
end;
$$;

create trigger on_challenge_done
  after update of status on challenges
  for each row execute function notify_challenge_done();

-- Trigger: refresh leaderboard when a new user's first score is inserted.
-- Fires only on INSERT (not UPDATE) so it doesn't run on every daily sync.

create or replace function public.on_first_score_inserted()
returns trigger
language plpgsql
security definer
as $$
begin
  -- Only refresh if this is truly the first score row for this user.
  if (select count(*) from public.scores where user_id = NEW.user_id) = 1 then
    perform public.refresh_leaderboard();
  end if;
  return NEW;
end;
$$;

create trigger refresh_leaderboard_on_first_score
  after insert on public.scores
  for each row
  execute function public.on_first_score_inserted();

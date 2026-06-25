-- Account deletion (delete_user → cascade to profiles) was blocked by two
-- foreign keys to profiles that had no ON DELETE action (defaulting to NO
-- ACTION). Both columns are nullable and only attribute authorship/outcome, so
-- the referenced rows should survive with the link detached.

alter table public.attacks
  drop constraint attacks_created_by_fkey,
  add constraint attacks_created_by_fkey
    foreign key (created_by) references public.profiles(id) on delete set null;

alter table public.challenges
  drop constraint challenges_winner_id_fkey,
  add constraint challenges_winner_id_fkey
    foreign key (winner_id) references public.profiles(id) on delete set null;

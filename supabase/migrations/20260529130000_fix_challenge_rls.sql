-- Fix infinite recursion in challenge_participants RLS policy.
-- The original policy did `exists (select 1 from challenge_participants ...)`
-- which re-triggers the same policy → infinite recursion.
-- Solution: a security-definer function that bypasses RLS for the lookup.

create or replace function public.is_challenge_participant(p_challenge_id uuid)
returns boolean language sql security definer stable as $$
  select exists (
    select 1 from public.challenge_participants
    where challenge_id = p_challenge_id
      and user_id = auth.uid()
  );
$$;

-- Re-create the policy without the self-referencing subquery
drop policy if exists "Participants can read challenge participants" on public.challenge_participants;

create policy "Participants can read challenge participants"
  on public.challenge_participants for select
  using (
    user_id = auth.uid()
    or public.is_challenge_participant(challenge_id)
  );

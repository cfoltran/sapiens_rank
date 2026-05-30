-- Enums
create type public.challenge_status   as enum ('pending', 'live', 'done', 'cancelled');
create type public.participant_status as enum ('invited', 'accepted', 'declined');

-- Challenges
create table public.challenges (
  id            uuid                    not null default gen_random_uuid() primary key,
  created_by    uuid                    not null references public.profiles(id) on delete cascade,
  metric        text                    not null default 'total' check (metric = 'total'),
  duration_days integer                 not null check (duration_days in (1, 3, 7, 30)),
  starts_at     timestamptz,
  ends_at       timestamptz,
  stake_icon    text,
  stake_label   text,
  status        public.challenge_status not null default 'pending',
  winner_id     uuid                    references public.profiles(id),
  created_at    timestamptz             not null default now()
);

alter table public.challenges enable row level security;

create policy "Authenticated users can create challenges"
  on public.challenges for insert
  with check (auth.uid() = created_by);

create policy "Creator can update their challenge"
  on public.challenges for update
  using (auth.uid() = created_by);

-- Participants
create table public.challenge_participants (
  id            uuid                      not null default gen_random_uuid() primary key,
  challenge_id  uuid                      not null references public.challenges(id) on delete cascade,
  user_id       uuid                      not null references public.profiles(id) on delete cascade,
  is_creator    boolean                   not null default false,
  status        public.participant_status not null default 'invited',
  invited_at    timestamptz               not null default now(),
  responded_at  timestamptz,
  unique (challenge_id, user_id)
);

alter table public.challenge_participants enable row level security;

create policy "Participants can read challenge participants"
  on public.challenge_participants for select
  using (
    user_id = auth.uid()
    or exists (
      select 1 from public.challenge_participants cp2
      where cp2.challenge_id = challenge_participants.challenge_id
        and cp2.user_id = auth.uid()
    )
  );

create policy "Creator can insert participants"
  on public.challenge_participants for insert
  with check (
    exists (
      select 1 from public.challenges
      where id = challenge_id
        and created_by = auth.uid()
    )
  );

create policy "Participant can update own status"
  on public.challenge_participants for update
  using (user_id = auth.uid());

-- Read policy on challenges (needs challenge_participants to exist first)
create policy "Participants can read their challenges"
  on public.challenges for select
  using (
    auth.uid() = created_by
    or exists (
      select 1 from public.challenge_participants
      where challenge_id = challenges.id
        and user_id = auth.uid()
    )
  );

-- Indexes
create index on public.challenge_participants (challenge_id);
create index on public.challenges (status, ends_at);

-- Auto-insert creator as accepted participant when a challenge is created
create or replace function public.add_creator_as_participant()
returns trigger language plpgsql security definer as $$
begin
  insert into public.challenge_participants (challenge_id, user_id, is_creator, status)
  values (new.id, new.created_by, true, 'accepted');
  return new;
end;
$$;

create trigger challenge_add_creator
  after insert on public.challenges
  for each row execute function public.add_creator_as_participant();

-- Block accepting a challenge that already started
create or replace function public.check_challenge_open()
returns trigger language plpgsql as $$
begin
  if new.status = 'accepted' then
    if (select status from public.challenges where id = new.challenge_id) != 'pending' then
      raise exception 'Challenge already started';
    end if;
  end if;
  return new;
end;
$$;

create trigger challenge_accept_guard
  before update of status on public.challenge_participants
  for each row execute function public.check_challenge_open();

-- Auto-start when all invited opponents have accepted
create or replace function public.maybe_start_challenge()
returns trigger language plpgsql security definer as $$
begin
  if new.status != 'accepted' or new.is_creator then
    return new;
  end if;

  if not exists (
    select 1 from public.challenges
    where id = new.challenge_id and status = 'pending'
  ) then
    return new;
  end if;

  -- Still waiting for someone
  if exists (
    select 1 from public.challenge_participants
    where challenge_id = new.challenge_id
      and is_creator = false
      and status = 'invited'
  ) then
    return new;
  end if;

  update public.challenges
  set status    = 'live',
      starts_at = now(),
      ends_at   = now() + (duration_days * interval '1 day')
  where id = new.challenge_id;

  return new;
end;
$$;

create trigger challenge_auto_start
  after update of status on public.challenge_participants
  for each row execute function public.maybe_start_challenge();

-- Current standings for a challenge
create or replace function public.get_challenge_standings(p_challenge_id uuid)
returns table (
  user_id  uuid,
  score    numeric,
  rank     bigint
) language sql stable security definer as $$
  select
    cp.user_id,
    coalesce(round(avg(s.score)::numeric, 1), 0) as score,
    rank() over (order by coalesce(avg(s.score), 0) desc) as rank
  from public.challenge_participants cp
  join public.challenges c on c.id = cp.challenge_id
  left join public.scores s
    on  s.user_id = cp.user_id
    and s.date >= c.starts_at::date
    and s.date <  coalesce(c.ends_at, now())::date
  where cp.challenge_id = p_challenge_id
    and cp.status       = 'accepted'
  group by cp.user_id;
$$;

-- Close expired challenges (called by pg_cron every hour)
create or replace function public.close_expired_challenges()
returns void language plpgsql security definer as $$
declare
  v_id        uuid;
  v_winner_id uuid;
begin
  for v_id in
    select id from public.challenges
    where status = 'live' and ends_at <= now()
  loop
    select user_id into v_winner_id
    from (
      select user_id, rank
      from public.get_challenge_standings(v_id)
      where rank = 1
    ) top
    having count(*) = 1;  -- null if tie

    update public.challenges
    set status = 'done', winner_id = v_winner_id
    where id = v_id;
  end loop;
end;
$$;

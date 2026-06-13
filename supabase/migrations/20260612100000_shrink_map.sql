-- Shrink the map from 12×18 (216 tiles) to 6×9 (54 tiles) — right-sized for
-- the current player base. Tiles can be added back later as the game grows.

-- Relocate owned territories that fall outside the new bounds onto a free
-- in-bounds tile so no guild loses territory (member capacity depends on it).
do $$
declare
  t record;
  v_free uuid;
begin
  for t in
    select * from public.territories
    where (grid_x > 5 or grid_y > 8)
      and owner_guild_id is not null
  loop
    select id into v_free
    from public.territories
    where grid_x <= 5 and grid_y <= 8
      and owner_guild_id is null
    order by random()
    limit 1;

    if v_free is not null then
      update public.territories
      set owner_guild_id = t.owner_guild_id,
          conquered_at   = t.conquered_at
      where id = v_free;
    end if;
  end loop;
end;
$$;

-- Drop out-of-bounds tiles (attacks referencing them cascade-delete).
delete from public.territories
where grid_x > 5 or grid_y > 8;

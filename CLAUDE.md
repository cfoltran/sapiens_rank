# SapiensRank

Flutter application to improve health. It's like Whoop but reverse:
1. Get people to use the app
2. They improve themselves through scores and challenges
3. Next: add a coach and wearable integrations (watch, wellbeing devices) to refine the score

Users earn a daily score (0–100) from Apple HealthKit data and compete on world and country leaderboards.

## Stack

- **Flutter** SDK ^3.11.4 + **Supabase** (Postgres + RLS)
- **State management**: flutter_bloc (Cubit pattern) for screens, Provider for AuthService
- **Routing**: go_router
- **Health data**: `health` package (Apple HealthKit)
- **Notifications**: Firebase Cloud Messaging

## Two-score system

There are two distinct scores, both out of 100, computed on-device from 6 HealthKit metrics:

| Metric   | Max pts | Global target |
|----------|---------|---------------|
| Sleep    | 25      | 7h            |
| Steps    | 22      | 7,000         |
| Calories | 18      | 380 kcal      |
| Stand    | 15      | 12h           |
| HRV      | 10      | 60 ms         |
| Exercise | 10      | 30 min        |

Each metric is scored as a 0–1 ratio against its target, multiplied by its max. Exercise minutes come from `APPLE_EXERCISE_TIME` (falling back to the larger of that and the summed workout durations), so effort lands even when no discrete `WORKOUT` sample does. Two redistributions keep the weights fair so no user is structurally penalised:
1. **Device gap** — when HRV and/or stand data is missing (e.g. Garmin users lack `APPLE_STAND_TIME`), the missing metric's points are spread proportionally across the others.
2. **Non-step cardio** — on days with cycling/swimming/rowing/elliptical workouts, the **steps** weight is cut by the share of active calories that came from those workouts and shifted onto calories + exercise. Steps only proxy movement for walking/running, so without this a cyclist/swimmer is double-penalised for effort the calories metric already rewards. A pure walking day has no shift.

Both preserve the 100-point total. **Sleep is never redistributed** — a missing sleep value just scores 0.

**Personal score** — computed with the user's own targets (`HealthTargets` from `profiles.target_*`), each metric hard-clamped 0–1. Shown in the Today ring, sparkline, delta, and profile chart. Stored in `scores.personal_score`.

**Global / ranking score** — computed with fixed universal targets (`HealthTargets.defaults`). Used for the leaderboard, world rank, and challenges. Stored in `scores.score`. Unlike the personal score, exceeding a **volume** target (steps, calories, exercise) earns bonus points with diminishing returns (`1 + 0.5·√(ratio−1)`, capped at 1.5× the metric's points at 2× target), so big training days are rewarded without one outlier day dominating. Sleep, stand and HRV stay hard-clamped (exceeding them isn't healthier). The daily global total is **not** capped at 100 — it's allowed up to 200 so a big training day rewards real output instead of being wasted. The personal score stays capped at 100.

`ScoreBreakdown.compute(snap, targets: targets)` → personal. `ScoreBreakdown.computeRanking(snap)` → global (`compute` with `rewardOvershoot: true`).

On launch: backfills missing days since `profiles.latest_sync` (capped at the last 7 days) from HealthKit, storing both scores. Setting `latest_sync` to null forces a full 7-day re-score on next open.

## Leaderboard (Supabase)

- `scores` table: one row per user per day — `score` (global) + `personal_score` (personal)
- `daily_metrics` table: raw HealthKit values (private, RLS per user) — used for future recalculation
- `leaderboard` table: sum of each user's last-7-days `score` / 7 (missed days count as 0, so inactive users decay toward 0) with `rank_world`, `rank_country`, `rank_delta`
- `refresh_leaderboard()` Postgres function: recomputes the score and ranks for **everyone on the board** (not just recently active users) via window functions; tiebreaker is unrounded score then `user_id` — called after every sync
- Challenges use `personal_score` via `get_challenge_standings()`
- Leaderboard is publicly readable, everything else is RLS-enforced

## Guilds & territory map

A team layer on top of the solo scores: users group into **guilds** that fight over a shared **hex map** of territories. Code lives in `lib/screens/guild/` (roster, create/join) and `lib/screens/map/` (the board + combat), backed by `GuildService` / `MapService` and the `20260610140000_guild_map.sql` migration.

**Guilds** (`guilds`, `guild_members`)
- A guild has a unique `name` and a `color` (used to tint its territories). Members have a `role` (`leader` | `member`); the creator becomes leader.
- Capacity = **5 base + 1 per territory owned** (`guild_max_members()`); a DB trigger enforces it, plus single-guild membership. Creating a guild also claims one random neutral territory (`on_guild_created`).
- `GuildCubit` → `GuildData` (guild, members, maxMembers, territoryCount, attackHistory). When the user has no guild it still loads `takenColors` so the create sheet can avoid duplicates.

**Map** (`territories`)
- A **6×9 grid** of hex tiles, one row per `(grid_x, grid_y)` (unique). `owner_guild_id` null = **neutral**. Adjacency is **4-neighbour on grid coords** (±1 in x or y), not true hex adjacency.
- `MapCubit` → `MapData` (territories, activeAttacks, myGuildId). `attackableTerritoryIds` is computed **client-side**: tiles adjacent to one you own, not already yours, not under attack — and empty while your guild already has an active attack (one at a time). Tap routing in `map_page.dart`: attackable tile → `AttackSheet`, tile under attack → `BattleSheet`, other → `TerritoryInfoSheet`, no guild → snackbar.

**Attacks / combat** (`attacks`)
- An attack picks a single **metric** (`steps` | `sleep` | `calories` | `stand`) and runs for a fixed **24h**. Attacking a guild-owned tile sets a `defender_guild_id`; a neutral tile has none (auto-claimed if unopposed).
- The winner is decided by **raw HealthKit volume**, not score: each side sums that metric across its members' `daily_metrics` over the window. This is distinct from the personal/global scores — it's a direct head-to-head total.
- Resolution is **server-side**, never on the client. A 15-min cron (`close_expired_attacks`) calls `update_active_attack_scores()` to keep live `attacker_score`/`defender_score` fresh for the `BattleSheet`, then `resolve_attack()` once `ends_at` passes: higher total wins and takes the territory (`conquered_at` set); a tie leaves the defender in place. A DB trigger validates adjacency + the one-active-attack rule on insert.

## Theme system

Use the `SrTheme` extension on `BuildContext` (`lib/common/theme/sr_theme.dart`) — always use `context.sr*` instead of raw `SrColors.*` so colors adapt between light and dark mode.

Key tokens:
- `context.srLime` — fills, rings, progress bars (electric lime on dark / `#c6f527` on light)
- `context.srLimeText` — lime text and icons (`#557a00` on light for readability)
- `context.srAmber`, `context.srRose` — secondary accents

`CustomPainter` has no BuildContext: pass colors as constructor parameters.

## Structure

```
lib/
  models/         # HealthTargets, LeaderboardEntry, ScoreBreakdown, guild_models (json_serializable)
  screens/        # onboarding, today, world, fight, home, profile, guild, map
  services/       # ScoreService, HealthService, AuthService, ProfileService, ChallengeService, GuildService, MapService
  common/
    theme/        # DkTheme, SrColors, SrTheme extension, skeletons
    data_state/   # DataState<T> wrapper (loading/error/data)
supabase/
  migrations/     # profiles, scores, leaderboard, FCM, challenges, daily_metrics, targets, guild_map
```

Architecture: UI → cubits/states → services → models

# Code rules

Don't do over commenting or section comments
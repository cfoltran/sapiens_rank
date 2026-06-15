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

Each metric is scored as a 0–1 ratio against its target, multiplied by its max. When HRV and/or stand data is missing (e.g. Garmin users lack `APPLE_STAND_TIME`), the missing metric's points are redistributed proportionally across the others so no user is structurally penalised by their device. **Sleep is never redistributed** — a missing sleep value just scores 0.

**Personal score** — computed with the user's own targets (`HealthTargets` from `profiles.target_*`), each metric hard-clamped 0–1. Shown in the Today ring, sparkline, delta, and profile chart. Stored in `scores.personal_score`.

**Global / ranking score** — computed with fixed universal targets (`HealthTargets.defaults`). Used for the leaderboard, world rank, and challenges. Stored in `scores.score`. Unlike the personal score, exceeding a **volume** target (steps, calories, exercise) earns bonus points with diminishing returns (`1 + 0.5·√(ratio−1)`, capped at 1.5× the metric's points at 2× target), so big training days are rewarded without one outlier day dominating. Sleep, stand and HRV stay hard-clamped (exceeding them isn't healthier). Total still capped at 100.

`ScoreBreakdown.compute(snap, targets: targets)` → personal. `ScoreBreakdown.computeRanking(snap)` → global (`compute` with `rewardOvershoot: true`).

On launch: backfills missing days since `profiles.latest_sync` (capped at the last 7 days) from HealthKit, storing both scores. Setting `latest_sync` to null forces a full 7-day re-score on next open.

## Leaderboard (Supabase)

- `scores` table: one row per user per day — `score` (global) + `personal_score` (personal)
- `daily_metrics` table: raw HealthKit values (private, RLS per user) — used for future recalculation
- `leaderboard` table: sum of each user's last-7-days `score` / 7 (missed days count as 0, so inactive users decay toward 0) with `rank_world`, `rank_country`, `rank_delta`
- `refresh_leaderboard()` Postgres function: recomputes the score and ranks for **everyone on the board** (not just recently active users) via window functions; tiebreaker is unrounded score then `user_id` — called after every sync
- Challenges use `personal_score` via `get_challenge_standings()`
- Leaderboard is publicly readable, everything else is RLS-enforced

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
  models/         # HealthTargets, LeaderboardEntry, ScoreBreakdown (json_serializable)
  screens/        # onboarding, today, world, fight, home, profile
  services/       # ScoreService, HealthService, AuthService, ProfileService, ChallengeService
  common/
    theme/        # DkTheme, SrColors, SrTheme extension, skeletons
    data_state/   # DataState<T> wrapper (loading/error/data)
supabase/
  migrations/     # profiles, scores, leaderboard, FCM, challenges, daily_metrics, targets
```

Architecture: UI → cubits/states → services → models

# Code rules

Don't do over commenting or section comments
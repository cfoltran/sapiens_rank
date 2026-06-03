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

There are two distinct scores, both out of 100, computed from the same 5 HealthKit metrics:

| Metric   | Max pts | Global target |
|----------|---------|---------------|
| Sleep    | 25      | 7h            |
| Steps    | 25      | 7,000         |
| Calories | 20      | 380 kcal      |
| Stand    | 15      | 12h           |
| HRV      | 15      | 60 ms         |

Each metric is clamped 0–1 then multiplied by its max. If HRV is unavailable, its 15 pts are redistributed across the other four metrics.

**Personal score** — computed on-device with the user's own targets (`HealthTargets` from `profiles.target_*`). Shown in the Today ring, sparkline, delta, and profile chart. Stored in `scores.personal_score`.

**Global score** — computed with fixed universal targets (`HealthTargets.defaults`). Used for the leaderboard, world rank, and challenges. Stored in `scores.score`.

`ScoreBreakdown.compute(snap, targets: targets)` → personal. `ScoreBreakdown.computeRanking(snap)` → global (alias with defaults).

On launch: backfills the last 7 missing days from HealthKit, storing both scores.

## Leaderboard (Supabase)

- `scores` table: one row per user per day — `score` (global) + `personal_score` (personal)
- `daily_metrics` table: raw HealthKit values (private, RLS per user) — used for future recalculation
- `leaderboard` table: 7-day rolling average of `score` with `rank_world`, `rank_country`, `rank_delta`
- `refresh_leaderboard()` Postgres function: recomputes ranks via window functions — called after every sync
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
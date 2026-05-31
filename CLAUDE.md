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

## Scoring algorithm (ScoreService)

Daily score out of 100, 5 metrics:

| Metric   | Max pts | Target   |
|----------|---------|----------|
| Sleep    | 25      | 8h       |
| Steps    | 25      | 10,000   |
| Calories | 20      | 750 kcal |
| Stand    | 15      | 12h      |
| HRV      | 15      | 60 bpm   |

Each metric is clamped 0–1 then multiplied by its max. If HRV is unavailable, its points are redistributed across the other metrics.

On launch: backfills the last 7 missing days from HealthKit.

## Leaderboard (Supabase)

- `scores` table: one score per user per day (unique constraint on user_id + date)
- `leaderboard` table: 7-day rolling average with `rank_world`, `rank_country`, `rank_delta`
- `refresh_leaderboard()` Postgres function: recomputes ranks via window functions — called after every sync
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
  screens/        # onboarding, today, world, fight, home, profile
  services/       # ScoreService, HealthService, AuthService, ChallengeService
  common/
    theme/        # DkTheme, SrColors, SrTheme extension, skeletons
    data_state/   # DataState<T> wrapper (loading/error/data)
supabase/
  migrations/     # 7 migrations (profiles, scores, leaderboard, FCM, challenges)
```

# Code rules

Don't do over commenting or section comments
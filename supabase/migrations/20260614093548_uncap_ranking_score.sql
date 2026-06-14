-- Ranking score (scores.score) is no longer capped at 100 per day: exceeding
-- volume targets (steps, kcal, exercise) now accumulates beyond 100 so big
-- training days reward output instead of being wasted. Per-metric diminishing
-- returns still bound each metric, so no single outlier metric can dominate.
-- personal_score stays 0-100 (measured against the user's own targets).
alter table public.scores
  drop constraint scores_score_check,
  add constraint scores_score_check check (score >= 0 and score <= 200);

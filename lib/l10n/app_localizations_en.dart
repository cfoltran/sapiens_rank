// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Sapiens Rank';

  @override
  String get nav_score => 'Score';

  @override
  String get nav_world => 'World';

  @override
  String get nav_challenge => 'Challenge';

  @override
  String get nav_battle => 'Battle';

  @override
  String get nav_guild => 'Guild';

  @override
  String get nav_map => 'Map';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get you => 'You';

  @override
  String get vs => 'VS';

  @override
  String get today_error => 'Could not load health data';

  @override
  String get today_ranking_soon => 'ranking soon...';

  @override
  String get today_world_rank => 'WORLD RANK';

  @override
  String get today_vs_yesterday => 'VS YESTERDAY';

  @override
  String get today_maxed => 'maxed';

  @override
  String get today_on_track => 'on track';

  @override
  String get today_push => 'push';

  @override
  String get today_activity => 'Today\'s Activity';

  @override
  String get today_min => 'min today';

  @override
  String get today_workout => 'workout';

  @override
  String get today_workouts => 'workouts';

  @override
  String today_sapies_harvested(int amount) {
    return '+$amount Sapies harvested';
  }

  @override
  String get sapies_title => 'Sapies';

  @override
  String get sapies_subtitle =>
      'Your in-game currency: earn it, spend it wisely.';

  @override
  String get sapies_earn_title => 'Earn every day';

  @override
  String get sapies_earn_body =>
      'Each day you sync your health data you earn Sapies. A perfect score gives you 100α.';

  @override
  String get sapies_spend_title => 'Power up attacks';

  @override
  String get sapies_spend_body =>
      'Spend Sapies on a booster when launching a guild attack:\nBoost +5% (300α)  •  Surge +15% (500α)  •  Blitz +20% (900α)';

  @override
  String get sapies_cta => 'Spend your Sapies  →';

  @override
  String get world_title => 'LEADERBOARD · LIVE';

  @override
  String get world_error => 'Could not load leaderboard';

  @override
  String get world_rank_col => 'RANK';

  @override
  String get world_trend_col => 'TREND';

  @override
  String world_gap(int count) {
    return '· · · $count sapiens · · ·';
  }

  @override
  String world_streak(int days) {
    return '${days}d streak';
  }

  @override
  String get world_ends_in => 'ends in';

  @override
  String get profile_title => 'PROFILE';

  @override
  String get profile_error => 'Could not load profile';

  @override
  String get profile_lifetime_avg => 'LIFETIME AVG';

  @override
  String get profile_wl => 'W / L';

  @override
  String get profile_streak => 'STREAK';

  @override
  String profile_streak_days(int days) {
    return '${days}d';
  }

  @override
  String get profile_trend => '30-DAY TREND';

  @override
  String get profile_points => 'POINTS';

  @override
  String get profile_targets => 'MY TARGETS';

  @override
  String get profile_edit => 'Edit →';

  @override
  String get profile_steps => 'Steps';

  @override
  String get profile_calories => 'Active kcal';

  @override
  String get profile_sleep => 'Sleep';

  @override
  String get profile_stand => 'Stand hours';

  @override
  String get profile_exercise => 'Exercise';

  @override
  String get profile_habits => 'HABITS';

  @override
  String get profile_smoking => 'Smoking';

  @override
  String get profile_alcohol => 'Alcohol';

  @override
  String get profile_not_set => 'Not set';

  @override
  String get profile_non_smoker => 'Non-smoker';

  @override
  String get profile_smoker => 'Smoker';

  @override
  String profile_cigarettes_per_day(int n) {
    return '$n/day';
  }

  @override
  String get profile_non_drinker => 'Non-drinker';

  @override
  String get profile_drinker => 'Drinker';

  @override
  String profile_drinks_per_week(int n) {
    return '$n/wk';
  }

  @override
  String get profile_body => 'BODY';

  @override
  String get profile_height => 'Height';

  @override
  String get profile_weight => 'Weight';

  @override
  String get profile_bmi => 'BMI';

  @override
  String get profile_bmi_underweight => 'Underweight';

  @override
  String get profile_bmi_healthy => 'Healthy';

  @override
  String get profile_bmi_overweight => 'Overweight';

  @override
  String get profile_bmi_obese => 'Obese';

  @override
  String get profile_theme_light => 'Light';

  @override
  String get profile_theme_system => 'System';

  @override
  String get profile_theme_dark => 'Dark';

  @override
  String get profile_contact => 'Contact us';

  @override
  String get profile_privacy => 'Privacy Policy';

  @override
  String get profile_terms => 'Terms & Conditions';

  @override
  String get profile_delete_account => 'Delete account';

  @override
  String get profile_delete_confirm_title => 'Delete your account?';

  @override
  String get profile_delete_confirm_body =>
      'All your data will be permanently deleted. This action cannot be undone.';

  @override
  String get profile_delete_button => 'Delete';

  @override
  String get profile_signout => 'Sign out';

  @override
  String get profile_signout_confirm => 'Sign out?';

  @override
  String challenge_title_live(int count) {
    return 'CHALLENGES · $count LIVE';
  }

  @override
  String get challenge_tab_live => 'Live';

  @override
  String challenge_tab_pending(int count) {
    return 'Pending · $count';
  }

  @override
  String get challenge_tab_history => 'History';

  @override
  String get challenge_new => 'New challenge';

  @override
  String get challenge_empty_live => 'No live challenges';

  @override
  String get challenge_empty_pending => 'No pending invites';

  @override
  String get challenge_empty_history => 'No challenges yet';

  @override
  String get challenge_score_label => 'SAPIENS SCORE';

  @override
  String get challenge_waiting => 'WAITING FOR ACCEPT';

  @override
  String get challenge_received => 'CHALLENGE RECEIVED';

  @override
  String challenge_you_challenged(String name) {
    return 'You challenged $name';
  }

  @override
  String challenge_opponent_challenged_you(String name) {
    return '$name challenged you';
  }

  @override
  String get challenge_accept => 'Accept';

  @override
  String challenge_vs(String name) {
    return 'vs $name';
  }

  @override
  String get challenge_draw => 'DRAW';

  @override
  String get challenge_won => 'WON';

  @override
  String get challenge_lost => 'LOST';

  @override
  String get challenge_winner_takes => 'WINNER TAKES';

  @override
  String get challenge_dnf => 'DNF';

  @override
  String get composer_pick_opponent => 'Pick opponent';

  @override
  String get composer_set_rules => 'Set the rules';

  @override
  String get composer_stake_reward => 'Stake a reward';

  @override
  String composer_players(int count) {
    return 'PLAYERS · $count';
  }

  @override
  String get composer_score_label => 'SCORE';

  @override
  String get composer_challenge_type => 'CHALLENGE TYPE';

  @override
  String get composer_type_score => 'Sapiens Score';

  @override
  String get composer_type_workout => 'Workout';

  @override
  String get composer_sport => 'SPORT';

  @override
  String get composer_distance => 'DISTANCE';

  @override
  String get composer_duration => 'DURATION';

  @override
  String get composer_duration_hint_workout => 'Time window to log your effort';

  @override
  String get composer_duration_hint_score => 'How long the score battle runs';

  @override
  String get composer_24h => '24h';

  @override
  String get composer_3d => '3 days';

  @override
  String get composer_1w => '1 week';

  @override
  String get composer_30d => '30 days';

  @override
  String get composer_custom_distance => '+ Custom';

  @override
  String get composer_distance_hint => 'e.g. 8';

  @override
  String get composer_stake_restaurant => 'If you win, I take you out';

  @override
  String get composer_stake_cinema => 'If you win, cinema on me';

  @override
  String get composer_stake_money => 'Money bet';

  @override
  String get composer_stake_custom => 'Custom stake';

  @override
  String get composer_stake_tap_amount => 'Tap to set amount';

  @override
  String get composer_stake_tap_write => 'Tap to write';

  @override
  String get composer_stake_hint_loser => 'e.g. loser buys drinks';

  @override
  String get composer_continue => 'Continue';

  @override
  String get composer_send => 'Send challenge ⚔️';

  @override
  String get composer_sent_title => 'Challenge sent';

  @override
  String composer_sent_subtitle(String name) {
    return '$name will be notified';
  }

  @override
  String get invite_title => 'Challenge Invite';

  @override
  String get invite_not_found => 'Challenge not found';

  @override
  String invite_challenged_you(String name) {
    return '$name challenged you!';
  }

  @override
  String get invite_if_accept => 'IF YOU ACCEPT AND WIN';

  @override
  String get invite_decline => 'Decline';

  @override
  String get invite_accept => 'Accept challenge ⚔️';

  @override
  String get invite_duration_day => '1 day';

  @override
  String get invite_duration_week => '1 week';

  @override
  String get invite_duration_month => '1 month';

  @override
  String invite_duration_days(int days) {
    return '$days days';
  }

  @override
  String get result_won => 'CHALLENGE WON';

  @override
  String get result_ended => 'CHALLENGE ENDED';

  @override
  String get result_victory => 'Victory.';

  @override
  String get result_draw => 'Draw.';

  @override
  String get result_defeated => 'Defeated.';

  @override
  String result_you_beat(String name) {
    return 'You beat $name';
  }

  @override
  String result_opponent_won(String name) {
    return '$name won';
  }

  @override
  String result_perfectly_matched(String name) {
    return 'You and $name are perfectly matched.';
  }

  @override
  String get result_avg_score => 'avg score';

  @override
  String result_points(int n) {
    return '$n point';
  }

  @override
  String result_points_plural(int n) {
    return '$n points';
  }

  @override
  String get result_split => 'SPLIT';

  @override
  String get result_you_take => 'YOU TAKE';

  @override
  String get result_they_take => 'THEY TAKE';

  @override
  String get result_reward_claimed => '✓ REWARD CLAIMED';

  @override
  String get result_claim_reward => 'Claim reward →';

  @override
  String get result_wallet_sent => 'Sent to your wallet · code ';

  @override
  String get result_rematch => 'Rematch ⚔️';

  @override
  String get result_not_found => 'Result not found';

  @override
  String get result_me => 'ME';

  @override
  String get map_no_guild => 'Join a guild to attack territories';

  @override
  String get map_error => 'Failed to load map';

  @override
  String get territory_members => 'MEMBERS';

  @override
  String get territory_no_members => 'No members found.';

  @override
  String get territory_load_error => 'Could not load members.';

  @override
  String get territory_unknown => 'Unknown';

  @override
  String get territory_just_claimed => 'just claimed';

  @override
  String territory_held_years(int n) {
    return 'for ${n}y';
  }

  @override
  String territory_held_months(int n) {
    return 'for ${n}mo';
  }

  @override
  String territory_held_days(int n) {
    return 'for ${n}d';
  }

  @override
  String territory_held_hours(int n) {
    return 'for ${n}h';
  }

  @override
  String get attack_claim_title => 'Claim neutral territory';

  @override
  String attack_guild_title(String guild) {
    return 'Attack $guild';
  }

  @override
  String get attack_rolling => 'Rolling your metric…';

  @override
  String get attack_neutral_hint => 'No defender, territory is yours in 24h.';

  @override
  String get attack_guild_hint =>
      'Your guild\'s total beats their guild\'s total.';

  @override
  String get attack_boost_section => 'BOOST YOUR ATTACK (OPTIONAL)';

  @override
  String get attack_none => 'None';

  @override
  String get attack_claim_btn => 'Claim';

  @override
  String get attack_launch_btn => 'Launch attack';

  @override
  String get battle_title => '⚔️  Battle in progress';

  @override
  String battle_subtitle(String metric) {
    return 'Most $metric logged wins this territory.';
  }

  @override
  String get battle_ending => 'Ending…';

  @override
  String battle_attacking_banner(String metric) {
    return '🗡️ Your guild is attacking, every $metric counts!';
  }

  @override
  String get battle_defending_banner =>
      '🛡️ Your guild is defending, hold the line!';

  @override
  String get battle_waiting => 'Waiting for the first score…';

  @override
  String battle_attacker_leading(String name) {
    return '$name is leading the assault';
  }

  @override
  String battle_defender_holding(String name) {
    return '$name is holding strong';
  }

  @override
  String get battle_attacker_fallback => 'Attacker';

  @override
  String get battle_unclaimed => 'Unclaimed';

  @override
  String get rules_title => 'How it works';

  @override
  String get rules_territories_title => 'Territories';

  @override
  String get rules_territories_body =>
      'The map is a grid of neutral territories. When you create a guild, you automatically claim one. Your guild\'s color marks everything you own.';

  @override
  String get rules_attacking_title => 'Attacking';

  @override
  String get rules_attacking_body =>
      'You can attack any territory adjacent to one you already own. The metric is drawn at random — a slot machine spins when you launch. Attacks last 24 hours. Only one attack at a time per guild.';

  @override
  String get rules_winners_title => 'How winners are decided';

  @override
  String get rules_winners_body =>
      'During the attack window, each guild\'s members sync their health data. The guild with the highest total on the drawn metric wins. Every member counts, even small contributions.';

  @override
  String get rules_tie_title => 'Tie rule';

  @override
  String get rules_tie_body =>
      'Equal totals? The defender keeps the territory. Attackers must outperform to conquer.';

  @override
  String get rules_boosters_title => 'Boosters';

  @override
  String get rules_boosters_body =>
      'Before launching, you can spend Sapies on a booster: Boost (+5%, 300α), Surge (+15%, 500α), or Blitz (+20%, 900α). The multiplier applies to your guild\'s total for that attack.';

  @override
  String get rules_slots_title => 'Guild slots';

  @override
  String get rules_slots_body =>
      'A new guild can hold 5 members. Each territory you conquer unlocks one more slot. Grow your territory to grow your team.';

  @override
  String get rules_solo_title => 'Solo players';

  @override
  String get rules_solo_body =>
      'You can claim neutral territories alone, but you can\'t attack guilds without joining one first. Solo players are \"guilds of 1\".';

  @override
  String get guild_title => 'GUILD';

  @override
  String get guild_error => 'Retry';

  @override
  String get guild_lone_wolf => 'You\'re a lone wolf';

  @override
  String get guild_lone_wolf_body =>
      'Join or create a guild to conquer territories and fight other guilds together.';

  @override
  String get guild_create_cta => 'Create a guild';

  @override
  String get guild_create_hint =>
      'You become leader, claim your first territory.';

  @override
  String get guild_join_cta => 'Join a guild';

  @override
  String get guild_join_hint =>
      'Find an existing guild and contribute immediately.';

  @override
  String get guild_members => 'MEMBERS';

  @override
  String get guild_leader => 'Leader';

  @override
  String get guild_attacks => 'RECENT ATTACKS';

  @override
  String get guild_attack_active => 'Active';

  @override
  String get guild_attack_tie => 'Tie';

  @override
  String get guild_attack_won => 'Won';

  @override
  String get guild_attack_lost => 'Lost';

  @override
  String get guild_leave_title => 'Leave guild?';

  @override
  String guild_leave_body(String name) {
    return 'You will leave $name. Your guild\'s territories remain.';
  }

  @override
  String get guild_leave_btn => 'Leave';

  @override
  String get guild_leave_error => 'Could not leave guild. Try again.';

  @override
  String get create_guild_title => 'Create a guild';

  @override
  String get create_guild_name_hint => 'Guild name';

  @override
  String get create_guild_color => 'COLOR';

  @override
  String get create_guild_btn => 'Create';

  @override
  String get join_guild_title => 'Join a guild';

  @override
  String get join_guild_search_hint => 'Search by name';

  @override
  String get join_guild_not_found => 'No guilds found';

  @override
  String get join_guild_btn => 'Join';

  @override
  String get update_title => 'Outdated Version';

  @override
  String get update_btn => 'Update';

  @override
  String get onboarding_welcome_headline => 'Improve together.';

  @override
  String get onboarding_welcome_subheadline => 'Become a best Sapiens.';

  @override
  String get onboarding_welcome_leaderboard => 'LIVE · WORLD LEADERBOARD';

  @override
  String get onboarding_welcome_body =>
      'We read your Health data and help you to progress.\nTakes 30 seconds.';

  @override
  String get onboarding_welcome_cta => 'Find my rank →';

  @override
  String get onboarding_welcome_login => 'I already have an account';

  @override
  String get onboarding_name_eyebrow => 'Identity check';

  @override
  String get onboarding_name_headline => 'What should the\nworld call you?';

  @override
  String get onboarding_name_hint_body =>
      'You can change it later. The leaderboard doesn\'t care, but your friends will.';

  @override
  String get onboarding_name_field_hint => 'First & last name';

  @override
  String get onboarding_name_cta => 'That\'s me →';

  @override
  String get onboarding_age_eyebrow => 'Calibration';

  @override
  String get onboarding_age_headline => 'How old are you?';

  @override
  String get onboarding_age_body =>
      'We\'ll baseline you against your cohort, not against 18-year-old triathletes.';

  @override
  String get onboarding_age_label => 'AGE';

  @override
  String get onboarding_age_cta => 'Continue →';

  @override
  String get onboarding_country_headline => 'Where do you challenge?';

  @override
  String get onboarding_country_subheadline => 'Plant your flag.';

  @override
  String get onboarding_country_body =>
      'You\'ll compete on both the global and country leaderboards.';

  @override
  String get onboarding_country_search => 'Search country...';

  @override
  String get onboarding_body_eyebrow => 'BODY';

  @override
  String get onboarding_body_headline => 'Body';

  @override
  String get onboarding_body_subheadline => 'composition.';

  @override
  String get onboarding_body_hint => 'Used to refine your personal score.';

  @override
  String get onboarding_body_cta => 'Continue →';

  @override
  String get onboarding_targets_eyebrow => 'SET THE BAR';

  @override
  String get onboarding_targets_headline => 'Pick the numbers';

  @override
  String get onboarding_targets_subheadline => 'you\'ll defend';

  @override
  String get onboarding_targets_daily => 'daily.';

  @override
  String get onboarding_targets_cta => 'Lock my targets →';

  @override
  String get onboarding_permission_headline => 'One permission. Worth it.';

  @override
  String get onboarding_permission_subheadline =>
      'Your Device knows\neverything.';

  @override
  String get onboarding_permission_body => 'We just do the math.';

  @override
  String get onboarding_permission_cta => 'Allow health access →';

  @override
  String get onboarding_permission_settings => 'Open Settings →';

  @override
  String get onboarding_permission_denied_body =>
      'Health access is required to compute your score. Open';

  @override
  String get onboarding_permission_denied_path =>
      'Settings → Health → Data Access';

  @override
  String get onboarding_permission_denied_enable =>
      'and enable all SapiensRank categories.';

  @override
  String get onboarding_permission_heart_rate => 'Heart Rate';

  @override
  String get onboarding_permission_heart_rate_sub => 'Resting + HRV';

  @override
  String get onboarding_permission_activity => 'Activity';

  @override
  String get onboarding_permission_activity_sub => 'Steps, distance, kcal';

  @override
  String get onboarding_permission_sleep => 'Sleep Analysis';

  @override
  String get onboarding_permission_sleep_sub => 'Stages, duration, score';

  @override
  String get onboarding_permission_stand => 'Stand Hours';

  @override
  String get onboarding_permission_stand_sub => 'Hours moved per day';

  @override
  String get onboarding_score_headline => 'Your first Sapiens Score.';

  @override
  String get onboarding_score_cta => 'See my rank? →';

  @override
  String get onboarding_auth_headline => 'Almost there.';

  @override
  String get onboarding_auth_subheadline => 'discover your ranking.';

  @override
  String get onboarding_auth_body =>
      'Create an account to discover your global ranking and keep your score.';

  @override
  String get onboarding_done_eyebrow => 'You\'re in.';

  @override
  String get onboarding_done_headline => 'Welcome to\nthe ranks,';

  @override
  String get onboarding_done_body =>
      'One leaderboard.\nToday is your chance to climb.';

  @override
  String get onboarding_done_cta => 'Enter the app →';

  @override
  String get onboarding_notif_headline => 'Last thing.';

  @override
  String get onboarding_notif_body =>
      'Daily score updates. Challenge invites. When a friend passes you, you\'ll know.';

  @override
  String get onboarding_notif_yes => 'Yes, keep me in the loop 🔔';

  @override
  String get onboarding_notif_skip => 'Not now';

  @override
  String get onboarding_notif_authorizing => 'Authorizing…';

  @override
  String get onboarding_notif_headline_prefix => 'Stay in the';

  @override
  String get onboarding_notif_headline_accent => 'challenge.';

  @override
  String get onboarding_notif_granted => 'Welcome to the ranks, Sapien. ✓';

  @override
  String get onboarding_auth_email => 'Continue with email';

  @override
  String get onboarding_auth_or => 'or';

  @override
  String get onboarding_score_not_bad => 'Not bad.';

  @override
  String get onboarding_score_above_avg =>
      'You\'re above average. But the world is bigger than average.';

  @override
  String get onboarding_sync_cta => 'See my score →';

  @override
  String get onboarding_sync_loading_label => 'READING YOUR DATA';

  @override
  String get onboarding_sync_loading_body => 'Pulling your\nhealth history.';

  @override
  String get onboarding_sync_done_label => 'ALL SYSTEMS GO';

  @override
  String get onboarding_sync_done_body => 'Data locked\nin.';

  @override
  String get onboarding_sync_done_cta => 'Let\'s rank.';

  @override
  String get onboarding_rank_live => 'World rank · live';

  @override
  String get onboarding_rank_calculating => 'Calculating world rank';

  @override
  String get onboarding_rank_in_world => 'in the world';

  @override
  String onboarding_rank_you_are(String firstName) {
    return '$firstName, you are';
  }

  @override
  String get onboarding_rank_higher_prefix => 'Higher than';

  @override
  String get onboarding_rank_higher_suffix => 'of Sapiens';

  @override
  String onboarding_rank_out_of(String count) {
    return 'Out of $count ranked today';
  }

  @override
  String get onboarding_rank_join => 'Join the leaderboard →';

  @override
  String get onboarding_rank_share => 'Share my rank';

  @override
  String get onboarding_bmi_frequency_question =>
      'How often do you want to update your weight?';

  @override
  String get onboarding_habits_do_you => 'Do you';

  @override
  String get onboarding_habits_score_hint =>
      'Affects your personal Sapiens Score.';

  @override
  String get onboarding_habits_no_impact => 'No impact on score';

  @override
  String get onboarding_habits_yes => 'Yes';

  @override
  String get onboarding_habits_quantity_impact =>
      'Affects score based on quantity';

  @override
  String get onboarding_habits_decline => 'I prefer not to say';

  @override
  String get onboarding_habits_still_affects => 'Still affects score';

  @override
  String get onboarding_smoking_verb => 'smoke?';

  @override
  String get onboarding_smoking_no => 'No, I don\'t smoke';

  @override
  String get onboarding_smoking_count => 'Cigarettes per day';

  @override
  String get onboarding_drinking_verb => 'drink?';

  @override
  String get onboarding_drinking_no => 'No, I don\'t drink';

  @override
  String get onboarding_drinking_count => 'Drinks per week';

  @override
  String get onboarding_targets_energy => 'Active energy';

  @override
  String get onboarding_privacy_body =>
      'Your data never leaves your phone. Only your';

  @override
  String get onboarding_privacy_accent => 'score and rank';

  @override
  String get onboarding_privacy_suffix =>
      'are uploaded — never the raw numbers.';
}

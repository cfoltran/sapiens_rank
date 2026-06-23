import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Sapiens Rank'**
  String get appName;

  /// No description provided for @nav_score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get nav_score;

  /// No description provided for @nav_world.
  ///
  /// In en, this message translates to:
  /// **'World'**
  String get nav_world;

  /// No description provided for @nav_challenge.
  ///
  /// In en, this message translates to:
  /// **'Challenge'**
  String get nav_challenge;

  /// No description provided for @nav_battle.
  ///
  /// In en, this message translates to:
  /// **'Battle'**
  String get nav_battle;

  /// No description provided for @nav_guild.
  ///
  /// In en, this message translates to:
  /// **'Guild'**
  String get nav_guild;

  /// No description provided for @nav_map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get nav_map;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @vs.
  ///
  /// In en, this message translates to:
  /// **'VS'**
  String get vs;

  /// No description provided for @today_error.
  ///
  /// In en, this message translates to:
  /// **'Could not load health data'**
  String get today_error;

  /// No description provided for @today_ranking_soon.
  ///
  /// In en, this message translates to:
  /// **'ranking soon...'**
  String get today_ranking_soon;

  /// No description provided for @today_world_rank.
  ///
  /// In en, this message translates to:
  /// **'WORLD RANK'**
  String get today_world_rank;

  /// No description provided for @today_vs_yesterday.
  ///
  /// In en, this message translates to:
  /// **'VS YESTERDAY'**
  String get today_vs_yesterday;

  /// No description provided for @today_maxed.
  ///
  /// In en, this message translates to:
  /// **'maxed'**
  String get today_maxed;

  /// No description provided for @today_on_track.
  ///
  /// In en, this message translates to:
  /// **'on track'**
  String get today_on_track;

  /// No description provided for @today_push.
  ///
  /// In en, this message translates to:
  /// **'push'**
  String get today_push;

  /// No description provided for @today_activity.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Activity'**
  String get today_activity;

  /// No description provided for @today_min.
  ///
  /// In en, this message translates to:
  /// **'min today'**
  String get today_min;

  /// No description provided for @today_workout.
  ///
  /// In en, this message translates to:
  /// **'workout'**
  String get today_workout;

  /// No description provided for @today_workouts.
  ///
  /// In en, this message translates to:
  /// **'workouts'**
  String get today_workouts;

  /// No description provided for @today_sapies_harvested.
  ///
  /// In en, this message translates to:
  /// **'+{amount} Sapies harvested'**
  String today_sapies_harvested(int amount);

  /// No description provided for @sapies_title.
  ///
  /// In en, this message translates to:
  /// **'Sapies'**
  String get sapies_title;

  /// No description provided for @sapies_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your in-game currency: earn it, spend it wisely.'**
  String get sapies_subtitle;

  /// No description provided for @sapies_earn_title.
  ///
  /// In en, this message translates to:
  /// **'Earn every day'**
  String get sapies_earn_title;

  /// No description provided for @sapies_earn_body.
  ///
  /// In en, this message translates to:
  /// **'Each day you sync your health data you earn Sapies. A perfect score gives you 100α.'**
  String get sapies_earn_body;

  /// No description provided for @sapies_spend_title.
  ///
  /// In en, this message translates to:
  /// **'Power up attacks'**
  String get sapies_spend_title;

  /// No description provided for @sapies_spend_body.
  ///
  /// In en, this message translates to:
  /// **'Spend Sapies on a booster when launching a guild attack:\nBoost +5% (300α)  •  Surge +15% (500α)  •  Blitz +20% (900α)'**
  String get sapies_spend_body;

  /// No description provided for @sapies_cta.
  ///
  /// In en, this message translates to:
  /// **'Spend your Sapies  →'**
  String get sapies_cta;

  /// No description provided for @world_title.
  ///
  /// In en, this message translates to:
  /// **'LEADERBOARD · LIVE'**
  String get world_title;

  /// No description provided for @world_error.
  ///
  /// In en, this message translates to:
  /// **'Could not load leaderboard'**
  String get world_error;

  /// No description provided for @world_rank_col.
  ///
  /// In en, this message translates to:
  /// **'RANK'**
  String get world_rank_col;

  /// No description provided for @world_trend_col.
  ///
  /// In en, this message translates to:
  /// **'TREND'**
  String get world_trend_col;

  /// No description provided for @world_gap.
  ///
  /// In en, this message translates to:
  /// **'· · · {count} sapiens · · ·'**
  String world_gap(int count);

  /// No description provided for @world_streak.
  ///
  /// In en, this message translates to:
  /// **'{days}d streak'**
  String world_streak(int days);

  /// No description provided for @world_ends_in.
  ///
  /// In en, this message translates to:
  /// **'ends in'**
  String get world_ends_in;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get profile_title;

  /// No description provided for @profile_error.
  ///
  /// In en, this message translates to:
  /// **'Could not load profile'**
  String get profile_error;

  /// No description provided for @profile_lifetime_avg.
  ///
  /// In en, this message translates to:
  /// **'LIFETIME AVG'**
  String get profile_lifetime_avg;

  /// No description provided for @profile_wl.
  ///
  /// In en, this message translates to:
  /// **'W / L'**
  String get profile_wl;

  /// No description provided for @profile_streak.
  ///
  /// In en, this message translates to:
  /// **'STREAK'**
  String get profile_streak;

  /// No description provided for @profile_streak_days.
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String profile_streak_days(int days);

  /// No description provided for @profile_trend.
  ///
  /// In en, this message translates to:
  /// **'30-DAY TREND'**
  String get profile_trend;

  /// No description provided for @profile_points.
  ///
  /// In en, this message translates to:
  /// **'POINTS'**
  String get profile_points;

  /// No description provided for @profile_targets.
  ///
  /// In en, this message translates to:
  /// **'MY TARGETS'**
  String get profile_targets;

  /// No description provided for @profile_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit →'**
  String get profile_edit;

  /// No description provided for @profile_steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get profile_steps;

  /// No description provided for @profile_calories.
  ///
  /// In en, this message translates to:
  /// **'Active kcal'**
  String get profile_calories;

  /// No description provided for @profile_sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get profile_sleep;

  /// No description provided for @profile_stand.
  ///
  /// In en, this message translates to:
  /// **'Stand hours'**
  String get profile_stand;

  /// No description provided for @profile_exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get profile_exercise;

  /// No description provided for @profile_habits.
  ///
  /// In en, this message translates to:
  /// **'HABITS'**
  String get profile_habits;

  /// No description provided for @profile_smoking.
  ///
  /// In en, this message translates to:
  /// **'Smoking'**
  String get profile_smoking;

  /// No description provided for @profile_alcohol.
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get profile_alcohol;

  /// No description provided for @profile_not_set.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get profile_not_set;

  /// No description provided for @profile_non_smoker.
  ///
  /// In en, this message translates to:
  /// **'Non-smoker'**
  String get profile_non_smoker;

  /// No description provided for @profile_smoker.
  ///
  /// In en, this message translates to:
  /// **'Smoker'**
  String get profile_smoker;

  /// No description provided for @profile_cigarettes_per_day.
  ///
  /// In en, this message translates to:
  /// **'{n}/day'**
  String profile_cigarettes_per_day(int n);

  /// No description provided for @profile_non_drinker.
  ///
  /// In en, this message translates to:
  /// **'Non-drinker'**
  String get profile_non_drinker;

  /// No description provided for @profile_drinker.
  ///
  /// In en, this message translates to:
  /// **'Drinker'**
  String get profile_drinker;

  /// No description provided for @profile_drinks_per_week.
  ///
  /// In en, this message translates to:
  /// **'{n}/wk'**
  String profile_drinks_per_week(int n);

  /// No description provided for @profile_body.
  ///
  /// In en, this message translates to:
  /// **'BODY'**
  String get profile_body;

  /// No description provided for @profile_height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get profile_height;

  /// No description provided for @profile_weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get profile_weight;

  /// No description provided for @profile_bmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get profile_bmi;

  /// No description provided for @profile_bmi_underweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get profile_bmi_underweight;

  /// No description provided for @profile_bmi_healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get profile_bmi_healthy;

  /// No description provided for @profile_bmi_overweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get profile_bmi_overweight;

  /// No description provided for @profile_bmi_obese.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get profile_bmi_obese;

  /// No description provided for @profile_theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get profile_theme_light;

  /// No description provided for @profile_theme_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get profile_theme_system;

  /// No description provided for @profile_theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get profile_theme_dark;

  /// No description provided for @profile_contact.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get profile_contact;

  /// No description provided for @profile_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profile_privacy;

  /// No description provided for @profile_terms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get profile_terms;

  /// No description provided for @profile_delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get profile_delete_account;

  /// No description provided for @profile_delete_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get profile_delete_confirm_title;

  /// No description provided for @profile_delete_confirm_body.
  ///
  /// In en, this message translates to:
  /// **'All your data will be permanently deleted. This action cannot be undone.'**
  String get profile_delete_confirm_body;

  /// No description provided for @profile_delete_button.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get profile_delete_button;

  /// No description provided for @profile_signout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profile_signout;

  /// No description provided for @profile_signout_confirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get profile_signout_confirm;

  /// No description provided for @challenge_title_live.
  ///
  /// In en, this message translates to:
  /// **'CHALLENGES · {count} LIVE'**
  String challenge_title_live(int count);

  /// No description provided for @challenge_tab_live.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get challenge_tab_live;

  /// No description provided for @challenge_tab_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending · {count}'**
  String challenge_tab_pending(int count);

  /// No description provided for @challenge_tab_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get challenge_tab_history;

  /// No description provided for @challenge_new.
  ///
  /// In en, this message translates to:
  /// **'New challenge'**
  String get challenge_new;

  /// No description provided for @challenge_empty_live.
  ///
  /// In en, this message translates to:
  /// **'No live challenges'**
  String get challenge_empty_live;

  /// No description provided for @challenge_empty_pending.
  ///
  /// In en, this message translates to:
  /// **'No pending invites'**
  String get challenge_empty_pending;

  /// No description provided for @challenge_empty_history.
  ///
  /// In en, this message translates to:
  /// **'No challenges yet'**
  String get challenge_empty_history;

  /// No description provided for @challenge_score_label.
  ///
  /// In en, this message translates to:
  /// **'SAPIENS SCORE'**
  String get challenge_score_label;

  /// No description provided for @challenge_waiting.
  ///
  /// In en, this message translates to:
  /// **'WAITING FOR ACCEPT'**
  String get challenge_waiting;

  /// No description provided for @challenge_received.
  ///
  /// In en, this message translates to:
  /// **'CHALLENGE RECEIVED'**
  String get challenge_received;

  /// No description provided for @challenge_you_challenged.
  ///
  /// In en, this message translates to:
  /// **'You challenged {name}'**
  String challenge_you_challenged(String name);

  /// No description provided for @challenge_opponent_challenged_you.
  ///
  /// In en, this message translates to:
  /// **'{name} challenged you'**
  String challenge_opponent_challenged_you(String name);

  /// No description provided for @challenge_accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get challenge_accept;

  /// No description provided for @challenge_vs.
  ///
  /// In en, this message translates to:
  /// **'vs {name}'**
  String challenge_vs(String name);

  /// No description provided for @challenge_draw.
  ///
  /// In en, this message translates to:
  /// **'DRAW'**
  String get challenge_draw;

  /// No description provided for @challenge_won.
  ///
  /// In en, this message translates to:
  /// **'WON'**
  String get challenge_won;

  /// No description provided for @challenge_lost.
  ///
  /// In en, this message translates to:
  /// **'LOST'**
  String get challenge_lost;

  /// No description provided for @challenge_winner_takes.
  ///
  /// In en, this message translates to:
  /// **'WINNER TAKES'**
  String get challenge_winner_takes;

  /// No description provided for @challenge_dnf.
  ///
  /// In en, this message translates to:
  /// **'DNF'**
  String get challenge_dnf;

  /// No description provided for @composer_pick_opponent.
  ///
  /// In en, this message translates to:
  /// **'Pick opponent'**
  String get composer_pick_opponent;

  /// No description provided for @composer_set_rules.
  ///
  /// In en, this message translates to:
  /// **'Set the rules'**
  String get composer_set_rules;

  /// No description provided for @composer_stake_reward.
  ///
  /// In en, this message translates to:
  /// **'Stake a reward'**
  String get composer_stake_reward;

  /// No description provided for @composer_players.
  ///
  /// In en, this message translates to:
  /// **'PLAYERS · {count}'**
  String composer_players(int count);

  /// No description provided for @composer_score_label.
  ///
  /// In en, this message translates to:
  /// **'SCORE'**
  String get composer_score_label;

  /// No description provided for @composer_challenge_type.
  ///
  /// In en, this message translates to:
  /// **'CHALLENGE TYPE'**
  String get composer_challenge_type;

  /// No description provided for @composer_type_score.
  ///
  /// In en, this message translates to:
  /// **'Sapiens Score'**
  String get composer_type_score;

  /// No description provided for @composer_type_workout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get composer_type_workout;

  /// No description provided for @composer_sport.
  ///
  /// In en, this message translates to:
  /// **'SPORT'**
  String get composer_sport;

  /// No description provided for @composer_distance.
  ///
  /// In en, this message translates to:
  /// **'DISTANCE'**
  String get composer_distance;

  /// No description provided for @composer_duration.
  ///
  /// In en, this message translates to:
  /// **'DURATION'**
  String get composer_duration;

  /// No description provided for @composer_duration_hint_workout.
  ///
  /// In en, this message translates to:
  /// **'Time window to log your effort'**
  String get composer_duration_hint_workout;

  /// No description provided for @composer_duration_hint_score.
  ///
  /// In en, this message translates to:
  /// **'How long the score battle runs'**
  String get composer_duration_hint_score;

  /// No description provided for @composer_24h.
  ///
  /// In en, this message translates to:
  /// **'24h'**
  String get composer_24h;

  /// No description provided for @composer_3d.
  ///
  /// In en, this message translates to:
  /// **'3 days'**
  String get composer_3d;

  /// No description provided for @composer_1w.
  ///
  /// In en, this message translates to:
  /// **'1 week'**
  String get composer_1w;

  /// No description provided for @composer_30d.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get composer_30d;

  /// No description provided for @composer_custom_distance.
  ///
  /// In en, this message translates to:
  /// **'+ Custom'**
  String get composer_custom_distance;

  /// No description provided for @composer_distance_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 8'**
  String get composer_distance_hint;

  /// No description provided for @composer_stake_restaurant.
  ///
  /// In en, this message translates to:
  /// **'If you win, I take you out'**
  String get composer_stake_restaurant;

  /// No description provided for @composer_stake_cinema.
  ///
  /// In en, this message translates to:
  /// **'If you win, cinema on me'**
  String get composer_stake_cinema;

  /// No description provided for @composer_stake_money.
  ///
  /// In en, this message translates to:
  /// **'Money bet'**
  String get composer_stake_money;

  /// No description provided for @composer_stake_custom.
  ///
  /// In en, this message translates to:
  /// **'Custom stake'**
  String get composer_stake_custom;

  /// No description provided for @composer_stake_tap_amount.
  ///
  /// In en, this message translates to:
  /// **'Tap to set amount'**
  String get composer_stake_tap_amount;

  /// No description provided for @composer_stake_tap_write.
  ///
  /// In en, this message translates to:
  /// **'Tap to write'**
  String get composer_stake_tap_write;

  /// No description provided for @composer_stake_hint_loser.
  ///
  /// In en, this message translates to:
  /// **'e.g. loser buys drinks'**
  String get composer_stake_hint_loser;

  /// No description provided for @composer_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get composer_continue;

  /// No description provided for @composer_send.
  ///
  /// In en, this message translates to:
  /// **'Send challenge ⚔️'**
  String get composer_send;

  /// No description provided for @composer_sent_title.
  ///
  /// In en, this message translates to:
  /// **'Challenge sent'**
  String get composer_sent_title;

  /// No description provided for @composer_sent_subtitle.
  ///
  /// In en, this message translates to:
  /// **'{name} will be notified'**
  String composer_sent_subtitle(String name);

  /// No description provided for @invite_title.
  ///
  /// In en, this message translates to:
  /// **'Challenge Invite'**
  String get invite_title;

  /// No description provided for @invite_not_found.
  ///
  /// In en, this message translates to:
  /// **'Challenge not found'**
  String get invite_not_found;

  /// No description provided for @invite_challenged_you.
  ///
  /// In en, this message translates to:
  /// **'{name} challenged you!'**
  String invite_challenged_you(String name);

  /// No description provided for @invite_if_accept.
  ///
  /// In en, this message translates to:
  /// **'IF YOU ACCEPT AND WIN'**
  String get invite_if_accept;

  /// No description provided for @invite_decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get invite_decline;

  /// No description provided for @invite_accept.
  ///
  /// In en, this message translates to:
  /// **'Accept challenge ⚔️'**
  String get invite_accept;

  /// No description provided for @invite_duration_day.
  ///
  /// In en, this message translates to:
  /// **'1 day'**
  String get invite_duration_day;

  /// No description provided for @invite_duration_week.
  ///
  /// In en, this message translates to:
  /// **'1 week'**
  String get invite_duration_week;

  /// No description provided for @invite_duration_month.
  ///
  /// In en, this message translates to:
  /// **'1 month'**
  String get invite_duration_month;

  /// No description provided for @invite_duration_days.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String invite_duration_days(int days);

  /// No description provided for @result_won.
  ///
  /// In en, this message translates to:
  /// **'CHALLENGE WON'**
  String get result_won;

  /// No description provided for @result_ended.
  ///
  /// In en, this message translates to:
  /// **'CHALLENGE ENDED'**
  String get result_ended;

  /// No description provided for @result_victory.
  ///
  /// In en, this message translates to:
  /// **'Victory.'**
  String get result_victory;

  /// No description provided for @result_draw.
  ///
  /// In en, this message translates to:
  /// **'Draw.'**
  String get result_draw;

  /// No description provided for @result_defeated.
  ///
  /// In en, this message translates to:
  /// **'Defeated.'**
  String get result_defeated;

  /// No description provided for @result_you_beat.
  ///
  /// In en, this message translates to:
  /// **'You beat {name}'**
  String result_you_beat(String name);

  /// No description provided for @result_opponent_won.
  ///
  /// In en, this message translates to:
  /// **'{name} won'**
  String result_opponent_won(String name);

  /// No description provided for @result_perfectly_matched.
  ///
  /// In en, this message translates to:
  /// **'You and {name} are perfectly matched.'**
  String result_perfectly_matched(String name);

  /// No description provided for @result_avg_score.
  ///
  /// In en, this message translates to:
  /// **'avg score'**
  String get result_avg_score;

  /// No description provided for @result_points.
  ///
  /// In en, this message translates to:
  /// **'{n} point'**
  String result_points(int n);

  /// No description provided for @result_points_plural.
  ///
  /// In en, this message translates to:
  /// **'{n} points'**
  String result_points_plural(int n);

  /// No description provided for @result_split.
  ///
  /// In en, this message translates to:
  /// **'SPLIT'**
  String get result_split;

  /// No description provided for @result_you_take.
  ///
  /// In en, this message translates to:
  /// **'YOU TAKE'**
  String get result_you_take;

  /// No description provided for @result_they_take.
  ///
  /// In en, this message translates to:
  /// **'THEY TAKE'**
  String get result_they_take;

  /// No description provided for @result_reward_claimed.
  ///
  /// In en, this message translates to:
  /// **'✓ REWARD CLAIMED'**
  String get result_reward_claimed;

  /// No description provided for @result_claim_reward.
  ///
  /// In en, this message translates to:
  /// **'Claim reward →'**
  String get result_claim_reward;

  /// No description provided for @result_wallet_sent.
  ///
  /// In en, this message translates to:
  /// **'Sent to your wallet · code '**
  String get result_wallet_sent;

  /// No description provided for @result_rematch.
  ///
  /// In en, this message translates to:
  /// **'Rematch ⚔️'**
  String get result_rematch;

  /// No description provided for @result_not_found.
  ///
  /// In en, this message translates to:
  /// **'Result not found'**
  String get result_not_found;

  /// No description provided for @result_me.
  ///
  /// In en, this message translates to:
  /// **'ME'**
  String get result_me;

  /// No description provided for @map_no_guild.
  ///
  /// In en, this message translates to:
  /// **'Join a guild to attack territories'**
  String get map_no_guild;

  /// No description provided for @map_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load map'**
  String get map_error;

  /// No description provided for @territory_members.
  ///
  /// In en, this message translates to:
  /// **'MEMBERS'**
  String get territory_members;

  /// No description provided for @territory_no_members.
  ///
  /// In en, this message translates to:
  /// **'No members found.'**
  String get territory_no_members;

  /// No description provided for @territory_load_error.
  ///
  /// In en, this message translates to:
  /// **'Could not load members.'**
  String get territory_load_error;

  /// No description provided for @territory_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get territory_unknown;

  /// No description provided for @territory_just_claimed.
  ///
  /// In en, this message translates to:
  /// **'just claimed'**
  String get territory_just_claimed;

  /// No description provided for @territory_held_years.
  ///
  /// In en, this message translates to:
  /// **'for {n}y'**
  String territory_held_years(int n);

  /// No description provided for @territory_held_months.
  ///
  /// In en, this message translates to:
  /// **'for {n}mo'**
  String territory_held_months(int n);

  /// No description provided for @territory_held_days.
  ///
  /// In en, this message translates to:
  /// **'for {n}d'**
  String territory_held_days(int n);

  /// No description provided for @territory_held_hours.
  ///
  /// In en, this message translates to:
  /// **'for {n}h'**
  String territory_held_hours(int n);

  /// No description provided for @attack_claim_title.
  ///
  /// In en, this message translates to:
  /// **'Claim neutral territory'**
  String get attack_claim_title;

  /// No description provided for @attack_guild_title.
  ///
  /// In en, this message translates to:
  /// **'Attack {guild}'**
  String attack_guild_title(String guild);

  /// No description provided for @attack_rolling.
  ///
  /// In en, this message translates to:
  /// **'Rolling your metric…'**
  String get attack_rolling;

  /// No description provided for @attack_neutral_hint.
  ///
  /// In en, this message translates to:
  /// **'No defender, territory is yours in 24h.'**
  String get attack_neutral_hint;

  /// No description provided for @attack_guild_hint.
  ///
  /// In en, this message translates to:
  /// **'Your guild\'s total beats their guild\'s total.'**
  String get attack_guild_hint;

  /// No description provided for @attack_boost_section.
  ///
  /// In en, this message translates to:
  /// **'BOOST YOUR ATTACK (OPTIONAL)'**
  String get attack_boost_section;

  /// No description provided for @attack_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get attack_none;

  /// No description provided for @attack_claim_btn.
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get attack_claim_btn;

  /// No description provided for @attack_launch_btn.
  ///
  /// In en, this message translates to:
  /// **'Launch attack'**
  String get attack_launch_btn;

  /// No description provided for @battle_title.
  ///
  /// In en, this message translates to:
  /// **'⚔️  Battle in progress'**
  String get battle_title;

  /// No description provided for @battle_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Most {metric} logged wins this territory.'**
  String battle_subtitle(String metric);

  /// No description provided for @battle_ending.
  ///
  /// In en, this message translates to:
  /// **'Ending…'**
  String get battle_ending;

  /// No description provided for @battle_attacking_banner.
  ///
  /// In en, this message translates to:
  /// **'🗡️ Your guild is attacking, every {metric} counts!'**
  String battle_attacking_banner(String metric);

  /// No description provided for @battle_defending_banner.
  ///
  /// In en, this message translates to:
  /// **'🛡️ Your guild is defending, hold the line!'**
  String get battle_defending_banner;

  /// No description provided for @battle_waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the first score…'**
  String get battle_waiting;

  /// No description provided for @battle_attacker_leading.
  ///
  /// In en, this message translates to:
  /// **'{name} is leading the assault'**
  String battle_attacker_leading(String name);

  /// No description provided for @battle_defender_holding.
  ///
  /// In en, this message translates to:
  /// **'{name} is holding strong'**
  String battle_defender_holding(String name);

  /// No description provided for @battle_attacker_fallback.
  ///
  /// In en, this message translates to:
  /// **'Attacker'**
  String get battle_attacker_fallback;

  /// No description provided for @battle_unclaimed.
  ///
  /// In en, this message translates to:
  /// **'Unclaimed'**
  String get battle_unclaimed;

  /// No description provided for @rules_title.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get rules_title;

  /// No description provided for @rules_territories_title.
  ///
  /// In en, this message translates to:
  /// **'Territories'**
  String get rules_territories_title;

  /// No description provided for @rules_territories_body.
  ///
  /// In en, this message translates to:
  /// **'The map is a grid of neutral territories. When you create a guild, you automatically claim one. Your guild\'s color marks everything you own.'**
  String get rules_territories_body;

  /// No description provided for @rules_attacking_title.
  ///
  /// In en, this message translates to:
  /// **'Attacking'**
  String get rules_attacking_title;

  /// No description provided for @rules_attacking_body.
  ///
  /// In en, this message translates to:
  /// **'You can attack any territory adjacent to one you already own. The metric is drawn at random — a slot machine spins when you launch. Attacks last 24 hours. Only one attack at a time per guild.'**
  String get rules_attacking_body;

  /// No description provided for @rules_winners_title.
  ///
  /// In en, this message translates to:
  /// **'How winners are decided'**
  String get rules_winners_title;

  /// No description provided for @rules_winners_body.
  ///
  /// In en, this message translates to:
  /// **'During the attack window, each guild\'s members sync their health data. The guild with the highest total on the drawn metric wins. Every member counts, even small contributions.'**
  String get rules_winners_body;

  /// No description provided for @rules_tie_title.
  ///
  /// In en, this message translates to:
  /// **'Tie rule'**
  String get rules_tie_title;

  /// No description provided for @rules_tie_body.
  ///
  /// In en, this message translates to:
  /// **'Equal totals? The defender keeps the territory. Attackers must outperform to conquer.'**
  String get rules_tie_body;

  /// No description provided for @rules_boosters_title.
  ///
  /// In en, this message translates to:
  /// **'Boosters'**
  String get rules_boosters_title;

  /// No description provided for @rules_boosters_body.
  ///
  /// In en, this message translates to:
  /// **'Before launching, you can spend Sapies on a booster: Boost (+5%, 300α), Surge (+15%, 500α), or Blitz (+20%, 900α). The multiplier applies to your guild\'s total for that attack.'**
  String get rules_boosters_body;

  /// No description provided for @rules_slots_title.
  ///
  /// In en, this message translates to:
  /// **'Guild slots'**
  String get rules_slots_title;

  /// No description provided for @rules_slots_body.
  ///
  /// In en, this message translates to:
  /// **'A new guild can hold 5 members. Each territory you conquer unlocks one more slot. Grow your territory to grow your team.'**
  String get rules_slots_body;

  /// No description provided for @rules_solo_title.
  ///
  /// In en, this message translates to:
  /// **'Solo players'**
  String get rules_solo_title;

  /// No description provided for @rules_solo_body.
  ///
  /// In en, this message translates to:
  /// **'You can claim neutral territories alone, but you can\'t attack guilds without joining one first. Solo players are \"guilds of 1\".'**
  String get rules_solo_body;

  /// No description provided for @guild_title.
  ///
  /// In en, this message translates to:
  /// **'GUILD'**
  String get guild_title;

  /// No description provided for @guild_error.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get guild_error;

  /// No description provided for @guild_lone_wolf.
  ///
  /// In en, this message translates to:
  /// **'You\'re a lone wolf'**
  String get guild_lone_wolf;

  /// No description provided for @guild_lone_wolf_body.
  ///
  /// In en, this message translates to:
  /// **'Join or create a guild to conquer territories and fight other guilds together.'**
  String get guild_lone_wolf_body;

  /// No description provided for @guild_create_cta.
  ///
  /// In en, this message translates to:
  /// **'Create a guild'**
  String get guild_create_cta;

  /// No description provided for @guild_create_hint.
  ///
  /// In en, this message translates to:
  /// **'You become leader, claim your first territory.'**
  String get guild_create_hint;

  /// No description provided for @guild_join_cta.
  ///
  /// In en, this message translates to:
  /// **'Join a guild'**
  String get guild_join_cta;

  /// No description provided for @guild_join_hint.
  ///
  /// In en, this message translates to:
  /// **'Find an existing guild and contribute immediately.'**
  String get guild_join_hint;

  /// No description provided for @guild_members.
  ///
  /// In en, this message translates to:
  /// **'MEMBERS'**
  String get guild_members;

  /// No description provided for @guild_leader.
  ///
  /// In en, this message translates to:
  /// **'Leader'**
  String get guild_leader;

  /// No description provided for @guild_attacks.
  ///
  /// In en, this message translates to:
  /// **'RECENT ATTACKS'**
  String get guild_attacks;

  /// No description provided for @guild_attack_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get guild_attack_active;

  /// No description provided for @guild_attack_tie.
  ///
  /// In en, this message translates to:
  /// **'Tie'**
  String get guild_attack_tie;

  /// No description provided for @guild_attack_won.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get guild_attack_won;

  /// No description provided for @guild_attack_lost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get guild_attack_lost;

  /// No description provided for @guild_leave_title.
  ///
  /// In en, this message translates to:
  /// **'Leave guild?'**
  String get guild_leave_title;

  /// No description provided for @guild_leave_body.
  ///
  /// In en, this message translates to:
  /// **'You will leave {name}. Your guild\'s territories remain.'**
  String guild_leave_body(String name);

  /// No description provided for @guild_leave_btn.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get guild_leave_btn;

  /// No description provided for @guild_leave_error.
  ///
  /// In en, this message translates to:
  /// **'Could not leave guild. Try again.'**
  String get guild_leave_error;

  /// No description provided for @create_guild_title.
  ///
  /// In en, this message translates to:
  /// **'Create a guild'**
  String get create_guild_title;

  /// No description provided for @create_guild_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Guild name'**
  String get create_guild_name_hint;

  /// No description provided for @create_guild_color.
  ///
  /// In en, this message translates to:
  /// **'COLOR'**
  String get create_guild_color;

  /// No description provided for @create_guild_btn.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create_guild_btn;

  /// No description provided for @join_guild_title.
  ///
  /// In en, this message translates to:
  /// **'Join a guild'**
  String get join_guild_title;

  /// No description provided for @join_guild_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get join_guild_search_hint;

  /// No description provided for @join_guild_not_found.
  ///
  /// In en, this message translates to:
  /// **'No guilds found'**
  String get join_guild_not_found;

  /// No description provided for @join_guild_btn.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join_guild_btn;

  /// No description provided for @update_title.
  ///
  /// In en, this message translates to:
  /// **'Outdated Version'**
  String get update_title;

  /// No description provided for @update_btn.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update_btn;

  /// No description provided for @onboarding_welcome_headline.
  ///
  /// In en, this message translates to:
  /// **'Improve together.'**
  String get onboarding_welcome_headline;

  /// No description provided for @onboarding_welcome_subheadline.
  ///
  /// In en, this message translates to:
  /// **'Become a best Sapiens.'**
  String get onboarding_welcome_subheadline;

  /// No description provided for @onboarding_welcome_leaderboard.
  ///
  /// In en, this message translates to:
  /// **'LIVE · WORLD LEADERBOARD'**
  String get onboarding_welcome_leaderboard;

  /// No description provided for @onboarding_welcome_body.
  ///
  /// In en, this message translates to:
  /// **'We read your Health data and help you to progress.\nTakes 30 seconds.'**
  String get onboarding_welcome_body;

  /// No description provided for @onboarding_welcome_cta.
  ///
  /// In en, this message translates to:
  /// **'Find my rank →'**
  String get onboarding_welcome_cta;

  /// No description provided for @onboarding_welcome_login.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get onboarding_welcome_login;

  /// No description provided for @onboarding_name_eyebrow.
  ///
  /// In en, this message translates to:
  /// **'Identity check'**
  String get onboarding_name_eyebrow;

  /// No description provided for @onboarding_name_headline.
  ///
  /// In en, this message translates to:
  /// **'What should the\nworld call you?'**
  String get onboarding_name_headline;

  /// No description provided for @onboarding_name_hint_body.
  ///
  /// In en, this message translates to:
  /// **'You can change it later. The leaderboard doesn\'t care, but your friends will.'**
  String get onboarding_name_hint_body;

  /// No description provided for @onboarding_name_field_hint.
  ///
  /// In en, this message translates to:
  /// **'First & last name'**
  String get onboarding_name_field_hint;

  /// No description provided for @onboarding_name_cta.
  ///
  /// In en, this message translates to:
  /// **'That\'s me →'**
  String get onboarding_name_cta;

  /// No description provided for @onboarding_age_eyebrow.
  ///
  /// In en, this message translates to:
  /// **'Calibration'**
  String get onboarding_age_eyebrow;

  /// No description provided for @onboarding_age_headline.
  ///
  /// In en, this message translates to:
  /// **'How old are you?'**
  String get onboarding_age_headline;

  /// No description provided for @onboarding_age_body.
  ///
  /// In en, this message translates to:
  /// **'We\'ll baseline you against your cohort, not against 18-year-old triathletes.'**
  String get onboarding_age_body;

  /// No description provided for @onboarding_age_label.
  ///
  /// In en, this message translates to:
  /// **'AGE'**
  String get onboarding_age_label;

  /// No description provided for @onboarding_age_cta.
  ///
  /// In en, this message translates to:
  /// **'Continue →'**
  String get onboarding_age_cta;

  /// No description provided for @onboarding_country_headline.
  ///
  /// In en, this message translates to:
  /// **'Where do you challenge?'**
  String get onboarding_country_headline;

  /// No description provided for @onboarding_country_subheadline.
  ///
  /// In en, this message translates to:
  /// **'Plant your flag.'**
  String get onboarding_country_subheadline;

  /// No description provided for @onboarding_country_body.
  ///
  /// In en, this message translates to:
  /// **'You\'ll compete on both the global and country leaderboards.'**
  String get onboarding_country_body;

  /// No description provided for @onboarding_country_search.
  ///
  /// In en, this message translates to:
  /// **'Search country...'**
  String get onboarding_country_search;

  /// No description provided for @onboarding_body_eyebrow.
  ///
  /// In en, this message translates to:
  /// **'BODY'**
  String get onboarding_body_eyebrow;

  /// No description provided for @onboarding_body_headline.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get onboarding_body_headline;

  /// No description provided for @onboarding_body_subheadline.
  ///
  /// In en, this message translates to:
  /// **'composition.'**
  String get onboarding_body_subheadline;

  /// No description provided for @onboarding_body_hint.
  ///
  /// In en, this message translates to:
  /// **'Used to refine your personal score.'**
  String get onboarding_body_hint;

  /// No description provided for @onboarding_body_cta.
  ///
  /// In en, this message translates to:
  /// **'Continue →'**
  String get onboarding_body_cta;

  /// No description provided for @onboarding_targets_eyebrow.
  ///
  /// In en, this message translates to:
  /// **'SET THE BAR'**
  String get onboarding_targets_eyebrow;

  /// No description provided for @onboarding_targets_headline.
  ///
  /// In en, this message translates to:
  /// **'Pick the numbers'**
  String get onboarding_targets_headline;

  /// No description provided for @onboarding_targets_subheadline.
  ///
  /// In en, this message translates to:
  /// **'you\'ll defend'**
  String get onboarding_targets_subheadline;

  /// No description provided for @onboarding_targets_daily.
  ///
  /// In en, this message translates to:
  /// **'daily.'**
  String get onboarding_targets_daily;

  /// No description provided for @onboarding_targets_cta.
  ///
  /// In en, this message translates to:
  /// **'Lock my targets →'**
  String get onboarding_targets_cta;

  /// No description provided for @onboarding_permission_headline.
  ///
  /// In en, this message translates to:
  /// **'One permission. Worth it.'**
  String get onboarding_permission_headline;

  /// No description provided for @onboarding_permission_subheadline.
  ///
  /// In en, this message translates to:
  /// **'Your Device knows\neverything.'**
  String get onboarding_permission_subheadline;

  /// No description provided for @onboarding_permission_body.
  ///
  /// In en, this message translates to:
  /// **'We just do the math.'**
  String get onboarding_permission_body;

  /// No description provided for @onboarding_permission_cta.
  ///
  /// In en, this message translates to:
  /// **'Allow health access →'**
  String get onboarding_permission_cta;

  /// No description provided for @onboarding_permission_settings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings →'**
  String get onboarding_permission_settings;

  /// No description provided for @onboarding_permission_denied_body.
  ///
  /// In en, this message translates to:
  /// **'Health access is required to compute your score. Open'**
  String get onboarding_permission_denied_body;

  /// No description provided for @onboarding_permission_denied_path.
  ///
  /// In en, this message translates to:
  /// **'Settings → Health → Data Access'**
  String get onboarding_permission_denied_path;

  /// No description provided for @onboarding_permission_denied_enable.
  ///
  /// In en, this message translates to:
  /// **'and enable all SapiensRank categories.'**
  String get onboarding_permission_denied_enable;

  /// No description provided for @onboarding_permission_heart_rate.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get onboarding_permission_heart_rate;

  /// No description provided for @onboarding_permission_heart_rate_sub.
  ///
  /// In en, this message translates to:
  /// **'Resting + HRV'**
  String get onboarding_permission_heart_rate_sub;

  /// No description provided for @onboarding_permission_activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get onboarding_permission_activity;

  /// No description provided for @onboarding_permission_activity_sub.
  ///
  /// In en, this message translates to:
  /// **'Steps, distance, kcal'**
  String get onboarding_permission_activity_sub;

  /// No description provided for @onboarding_permission_sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep Analysis'**
  String get onboarding_permission_sleep;

  /// No description provided for @onboarding_permission_sleep_sub.
  ///
  /// In en, this message translates to:
  /// **'Stages, duration, score'**
  String get onboarding_permission_sleep_sub;

  /// No description provided for @onboarding_permission_stand.
  ///
  /// In en, this message translates to:
  /// **'Stand Hours'**
  String get onboarding_permission_stand;

  /// No description provided for @onboarding_permission_stand_sub.
  ///
  /// In en, this message translates to:
  /// **'Hours moved per day'**
  String get onboarding_permission_stand_sub;

  /// No description provided for @onboarding_score_headline.
  ///
  /// In en, this message translates to:
  /// **'Your first Sapiens Score.'**
  String get onboarding_score_headline;

  /// No description provided for @onboarding_score_cta.
  ///
  /// In en, this message translates to:
  /// **'See my rank? →'**
  String get onboarding_score_cta;

  /// No description provided for @onboarding_auth_headline.
  ///
  /// In en, this message translates to:
  /// **'Almost there.'**
  String get onboarding_auth_headline;

  /// No description provided for @onboarding_auth_subheadline.
  ///
  /// In en, this message translates to:
  /// **'discover your ranking.'**
  String get onboarding_auth_subheadline;

  /// No description provided for @onboarding_auth_body.
  ///
  /// In en, this message translates to:
  /// **'Create an account to discover your global ranking and keep your score.'**
  String get onboarding_auth_body;

  /// No description provided for @onboarding_done_eyebrow.
  ///
  /// In en, this message translates to:
  /// **'You\'re in.'**
  String get onboarding_done_eyebrow;

  /// No description provided for @onboarding_done_headline.
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nthe ranks,'**
  String get onboarding_done_headline;

  /// No description provided for @onboarding_done_body.
  ///
  /// In en, this message translates to:
  /// **'One leaderboard.\nToday is your chance to climb.'**
  String get onboarding_done_body;

  /// No description provided for @onboarding_done_cta.
  ///
  /// In en, this message translates to:
  /// **'Enter the app →'**
  String get onboarding_done_cta;

  /// No description provided for @onboarding_notif_headline.
  ///
  /// In en, this message translates to:
  /// **'Last thing.'**
  String get onboarding_notif_headline;

  /// No description provided for @onboarding_notif_body.
  ///
  /// In en, this message translates to:
  /// **'Daily score updates. Challenge invites. When a friend passes you, you\'ll know.'**
  String get onboarding_notif_body;

  /// No description provided for @onboarding_notif_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes, keep me in the loop 🔔'**
  String get onboarding_notif_yes;

  /// No description provided for @onboarding_notif_skip.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get onboarding_notif_skip;

  /// No description provided for @onboarding_notif_authorizing.
  ///
  /// In en, this message translates to:
  /// **'Authorizing…'**
  String get onboarding_notif_authorizing;

  /// No description provided for @onboarding_notif_headline_prefix.
  ///
  /// In en, this message translates to:
  /// **'Stay in the'**
  String get onboarding_notif_headline_prefix;

  /// No description provided for @onboarding_notif_headline_accent.
  ///
  /// In en, this message translates to:
  /// **'challenge.'**
  String get onboarding_notif_headline_accent;

  /// No description provided for @onboarding_notif_granted.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the ranks, Sapien. ✓'**
  String get onboarding_notif_granted;

  /// No description provided for @onboarding_auth_email.
  ///
  /// In en, this message translates to:
  /// **'Continue with email'**
  String get onboarding_auth_email;

  /// No description provided for @onboarding_auth_or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get onboarding_auth_or;

  /// No description provided for @onboarding_score_not_bad.
  ///
  /// In en, this message translates to:
  /// **'Not bad.'**
  String get onboarding_score_not_bad;

  /// No description provided for @onboarding_score_above_avg.
  ///
  /// In en, this message translates to:
  /// **'You\'re above average. But the world is bigger than average.'**
  String get onboarding_score_above_avg;

  /// No description provided for @onboarding_sync_cta.
  ///
  /// In en, this message translates to:
  /// **'See my score →'**
  String get onboarding_sync_cta;

  /// No description provided for @onboarding_sync_loading_label.
  ///
  /// In en, this message translates to:
  /// **'READING YOUR DATA'**
  String get onboarding_sync_loading_label;

  /// No description provided for @onboarding_sync_loading_body.
  ///
  /// In en, this message translates to:
  /// **'Pulling your\nhealth history.'**
  String get onboarding_sync_loading_body;

  /// No description provided for @onboarding_sync_done_label.
  ///
  /// In en, this message translates to:
  /// **'ALL SYSTEMS GO'**
  String get onboarding_sync_done_label;

  /// No description provided for @onboarding_sync_done_body.
  ///
  /// In en, this message translates to:
  /// **'Data locked\nin.'**
  String get onboarding_sync_done_body;

  /// No description provided for @onboarding_sync_done_cta.
  ///
  /// In en, this message translates to:
  /// **'Let\'s rank.'**
  String get onboarding_sync_done_cta;

  /// No description provided for @onboarding_rank_live.
  ///
  /// In en, this message translates to:
  /// **'World rank · live'**
  String get onboarding_rank_live;

  /// No description provided for @onboarding_rank_calculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating world rank'**
  String get onboarding_rank_calculating;

  /// No description provided for @onboarding_rank_in_world.
  ///
  /// In en, this message translates to:
  /// **'in the world'**
  String get onboarding_rank_in_world;

  /// No description provided for @onboarding_rank_you_are.
  ///
  /// In en, this message translates to:
  /// **'{firstName}, you are'**
  String onboarding_rank_you_are(String firstName);

  /// No description provided for @onboarding_rank_higher_prefix.
  ///
  /// In en, this message translates to:
  /// **'Higher than'**
  String get onboarding_rank_higher_prefix;

  /// No description provided for @onboarding_rank_higher_suffix.
  ///
  /// In en, this message translates to:
  /// **'of Sapiens'**
  String get onboarding_rank_higher_suffix;

  /// No description provided for @onboarding_rank_out_of.
  ///
  /// In en, this message translates to:
  /// **'Out of {count} ranked today'**
  String onboarding_rank_out_of(String count);

  /// No description provided for @onboarding_rank_join.
  ///
  /// In en, this message translates to:
  /// **'Join the leaderboard →'**
  String get onboarding_rank_join;

  /// No description provided for @onboarding_rank_share.
  ///
  /// In en, this message translates to:
  /// **'Share my rank'**
  String get onboarding_rank_share;

  /// No description provided for @onboarding_bmi_frequency_question.
  ///
  /// In en, this message translates to:
  /// **'How often do you want to update your weight?'**
  String get onboarding_bmi_frequency_question;

  /// No description provided for @onboarding_habits_do_you.
  ///
  /// In en, this message translates to:
  /// **'Do you'**
  String get onboarding_habits_do_you;

  /// No description provided for @onboarding_habits_score_hint.
  ///
  /// In en, this message translates to:
  /// **'Affects your personal Sapiens Score.'**
  String get onboarding_habits_score_hint;

  /// No description provided for @onboarding_habits_no_impact.
  ///
  /// In en, this message translates to:
  /// **'No impact on score'**
  String get onboarding_habits_no_impact;

  /// No description provided for @onboarding_habits_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get onboarding_habits_yes;

  /// No description provided for @onboarding_habits_quantity_impact.
  ///
  /// In en, this message translates to:
  /// **'Affects score based on quantity'**
  String get onboarding_habits_quantity_impact;

  /// No description provided for @onboarding_habits_decline.
  ///
  /// In en, this message translates to:
  /// **'I prefer not to say'**
  String get onboarding_habits_decline;

  /// No description provided for @onboarding_habits_still_affects.
  ///
  /// In en, this message translates to:
  /// **'Still affects score'**
  String get onboarding_habits_still_affects;

  /// No description provided for @onboarding_smoking_verb.
  ///
  /// In en, this message translates to:
  /// **'smoke?'**
  String get onboarding_smoking_verb;

  /// No description provided for @onboarding_smoking_no.
  ///
  /// In en, this message translates to:
  /// **'No, I don\'t smoke'**
  String get onboarding_smoking_no;

  /// No description provided for @onboarding_smoking_count.
  ///
  /// In en, this message translates to:
  /// **'Cigarettes per day'**
  String get onboarding_smoking_count;

  /// No description provided for @onboarding_drinking_verb.
  ///
  /// In en, this message translates to:
  /// **'drink?'**
  String get onboarding_drinking_verb;

  /// No description provided for @onboarding_drinking_no.
  ///
  /// In en, this message translates to:
  /// **'No, I don\'t drink'**
  String get onboarding_drinking_no;

  /// No description provided for @onboarding_drinking_count.
  ///
  /// In en, this message translates to:
  /// **'Drinks per week'**
  String get onboarding_drinking_count;

  /// No description provided for @onboarding_targets_energy.
  ///
  /// In en, this message translates to:
  /// **'Active energy'**
  String get onboarding_targets_energy;

  /// No description provided for @onboarding_privacy_body.
  ///
  /// In en, this message translates to:
  /// **'Your data never leaves your phone. Only your'**
  String get onboarding_privacy_body;

  /// No description provided for @onboarding_privacy_accent.
  ///
  /// In en, this message translates to:
  /// **'score and rank'**
  String get onboarding_privacy_accent;

  /// No description provided for @onboarding_privacy_suffix.
  ///
  /// In en, this message translates to:
  /// **'are uploaded — never the raw numbers.'**
  String get onboarding_privacy_suffix;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

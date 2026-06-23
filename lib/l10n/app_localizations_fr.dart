// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Sapiens Rank';

  @override
  String get nav_score => 'Score';

  @override
  String get nav_world => 'Monde';

  @override
  String get nav_challenge => 'Défis';

  @override
  String get nav_battle => 'Combat';

  @override
  String get nav_guild => 'Guilde';

  @override
  String get nav_map => 'Carte';

  @override
  String get retry => 'Réessayer';

  @override
  String get cancel => 'Annuler';

  @override
  String get back => 'Retour';

  @override
  String get close => 'Fermer';

  @override
  String get ok => 'OK';

  @override
  String get you => 'Toi';

  @override
  String get vs => 'VS';

  @override
  String get today_error => 'Impossible de charger les données de santé';

  @override
  String get today_ranking_soon => 'classement bientôt...';

  @override
  String get today_world_rank => 'RANG MONDIAL';

  @override
  String get today_vs_yesterday => 'VS HIER';

  @override
  String get today_maxed => 'maxé';

  @override
  String get today_on_track => 'en bonne voie';

  @override
  String get today_push => 'pousse';

  @override
  String get today_activity => 'Activité du jour';

  @override
  String get today_min => 'min aujourd\'hui';

  @override
  String get today_workout => 'séance';

  @override
  String get today_workouts => 'séances';

  @override
  String today_sapies_harvested(int amount) {
    return '+$amount Sapies récoltés';
  }

  @override
  String get sapies_title => 'Sapies';

  @override
  String get sapies_subtitle =>
      'Ta monnaie de jeu : gagne-la, dépense-la avec soin.';

  @override
  String get sapies_earn_title => 'Gagne chaque jour';

  @override
  String get sapies_earn_body =>
      'Chaque jour où tu synchronises tes données de santé, tu gagnes des Sapies. Un score parfait te rapporte 100α.';

  @override
  String get sapies_spend_title => 'Booste tes attaques';

  @override
  String get sapies_spend_body =>
      'Dépense des Sapies sur un booster avant de lancer une attaque de guilde :\nBoost +5% (300α)  •  Surge +15% (500α)  •  Blitz +20% (900α)';

  @override
  String get sapies_cta => 'Dépenser mes Sapies  →';

  @override
  String get world_title => 'CLASSEMENT · EN DIRECT';

  @override
  String get world_error => 'Impossible de charger le classement';

  @override
  String get world_rank_col => 'RANG';

  @override
  String get world_trend_col => 'TENDANCE';

  @override
  String world_gap(int count) {
    return '· · · $count sapiens · · ·';
  }

  @override
  String world_streak(int days) {
    return '${days}j de suite';
  }

  @override
  String get world_ends_in => 'se termine dans';

  @override
  String get profile_title => 'PROFIL';

  @override
  String get profile_error => 'Impossible de charger le profil';

  @override
  String get profile_lifetime_avg => 'MOY. TOTALE';

  @override
  String get profile_wl => 'V / D';

  @override
  String get profile_streak => 'SÉRIE';

  @override
  String profile_streak_days(int days) {
    return '${days}j';
  }

  @override
  String get profile_trend => 'TENDANCE 30 JOURS';

  @override
  String get profile_points => 'POINTS';

  @override
  String get profile_targets => 'MES OBJECTIFS';

  @override
  String get profile_edit => 'Modifier →';

  @override
  String get profile_steps => 'Pas';

  @override
  String get profile_calories => 'Kcal actives';

  @override
  String get profile_sleep => 'Sommeil';

  @override
  String get profile_stand => 'Heures debout';

  @override
  String get profile_exercise => 'Exercice';

  @override
  String get profile_habits => 'HABITUDES';

  @override
  String get profile_smoking => 'Tabac';

  @override
  String get profile_alcohol => 'Alcool';

  @override
  String get profile_not_set => 'Non renseigné';

  @override
  String get profile_non_smoker => 'Non-fumeur';

  @override
  String get profile_smoker => 'Fumeur';

  @override
  String profile_cigarettes_per_day(int n) {
    return '$n/jour';
  }

  @override
  String get profile_non_drinker => 'Non-buveur';

  @override
  String get profile_drinker => 'Buveur';

  @override
  String profile_drinks_per_week(int n) {
    return '$n/sem.';
  }

  @override
  String get profile_body => 'CORPS';

  @override
  String get profile_height => 'Taille';

  @override
  String get profile_weight => 'Poids';

  @override
  String get profile_bmi => 'IMC';

  @override
  String get profile_bmi_underweight => 'Insuffisance pondérale';

  @override
  String get profile_bmi_healthy => 'Poids normal';

  @override
  String get profile_bmi_overweight => 'Surpoids';

  @override
  String get profile_bmi_obese => 'Obèse';

  @override
  String get profile_theme_light => 'Clair';

  @override
  String get profile_theme_system => 'Système';

  @override
  String get profile_theme_dark => 'Sombre';

  @override
  String get profile_contact => 'Nous contacter';

  @override
  String get profile_privacy => 'Politique de confidentialité';

  @override
  String get profile_terms => 'Conditions d\'utilisation';

  @override
  String get profile_delete_account => 'Supprimer le compte';

  @override
  String get profile_delete_confirm_title => 'Supprimer votre compte ?';

  @override
  String get profile_delete_confirm_body =>
      'Toutes vos données seront définitivement supprimées. Cette action est irréversible.';

  @override
  String get profile_delete_button => 'Supprimer';

  @override
  String get profile_signout => 'Se déconnecter';

  @override
  String get profile_signout_confirm => 'Se déconnecter ?';

  @override
  String challenge_title_live(int count) {
    return 'DÉFIS · $count EN COURS';
  }

  @override
  String get challenge_tab_live => 'En cours';

  @override
  String challenge_tab_pending(int count) {
    return 'En attente · $count';
  }

  @override
  String get challenge_tab_history => 'Historique';

  @override
  String get challenge_new => 'Nouveau défi';

  @override
  String get challenge_empty_live => 'Aucun défi en cours';

  @override
  String get challenge_empty_pending => 'Aucune invitation en attente';

  @override
  String get challenge_empty_history => 'Aucun défi pour l\'instant';

  @override
  String get challenge_score_label => 'SCORE SAPIENS';

  @override
  String get challenge_waiting => 'EN ATTENTE D\'ACCEPTATION';

  @override
  String get challenge_received => 'DÉFI REÇU';

  @override
  String challenge_you_challenged(String name) {
    return 'Tu as défié $name';
  }

  @override
  String challenge_opponent_challenged_you(String name) {
    return '$name t\'a défié';
  }

  @override
  String get challenge_accept => 'Accepter';

  @override
  String challenge_vs(String name) {
    return 'vs $name';
  }

  @override
  String get challenge_draw => 'ÉGALITÉ';

  @override
  String get challenge_won => 'GAGNÉ';

  @override
  String get challenge_lost => 'PERDU';

  @override
  String get challenge_winner_takes => 'LE GAGNANT PREND';

  @override
  String get challenge_dnf => 'ABANDON';

  @override
  String get composer_pick_opponent => 'Choisir l\'adversaire';

  @override
  String get composer_set_rules => 'Définir les règles';

  @override
  String get composer_stake_reward => 'Miser une récompense';

  @override
  String composer_players(int count) {
    return 'JOUEURS · $count';
  }

  @override
  String get composer_score_label => 'SCORE';

  @override
  String get composer_challenge_type => 'TYPE DE DÉFI';

  @override
  String get composer_type_score => 'Score Sapiens';

  @override
  String get composer_type_workout => 'Entraînement';

  @override
  String get composer_sport => 'SPORT';

  @override
  String get composer_distance => 'DISTANCE';

  @override
  String get composer_duration => 'DURÉE';

  @override
  String get composer_duration_hint_workout =>
      'Fenêtre de temps pour enregistrer ton effort';

  @override
  String get composer_duration_hint_score => 'Durée de la bataille de score';

  @override
  String get composer_24h => '24h';

  @override
  String get composer_3d => '3 jours';

  @override
  String get composer_1w => '1 semaine';

  @override
  String get composer_30d => '30 jours';

  @override
  String get composer_custom_distance => '+ Personnalisé';

  @override
  String get composer_distance_hint => 'ex. 8';

  @override
  String get composer_stake_restaurant => 'Si tu gagnes, je t\'invite au resto';

  @override
  String get composer_stake_cinema => 'Si tu gagnes, ciné à mes frais';

  @override
  String get composer_stake_money => 'Pari en argent';

  @override
  String get composer_stake_custom => 'Mise personnalisée';

  @override
  String get composer_stake_tap_amount => 'Appuyer pour définir le montant';

  @override
  String get composer_stake_tap_write => 'Appuyer pour écrire';

  @override
  String get composer_stake_hint_loser => 'ex. le perdant offre les boissons';

  @override
  String get composer_continue => 'Continuer';

  @override
  String get composer_send => 'Envoyer le défi ⚔️';

  @override
  String get composer_sent_title => 'Défi envoyé';

  @override
  String composer_sent_subtitle(String name) {
    return '$name sera notifié';
  }

  @override
  String get invite_title => 'Invitation au défi';

  @override
  String get invite_not_found => 'Défi introuvable';

  @override
  String invite_challenged_you(String name) {
    return '$name t\'a défié !';
  }

  @override
  String get invite_if_accept => 'SI TU ACCEPTES ET GAGNES';

  @override
  String get invite_decline => 'Refuser';

  @override
  String get invite_accept => 'Accepter le défi ⚔️';

  @override
  String get invite_duration_day => '1 jour';

  @override
  String get invite_duration_week => '1 semaine';

  @override
  String get invite_duration_month => '1 mois';

  @override
  String invite_duration_days(int days) {
    return '$days jours';
  }

  @override
  String get result_won => 'DÉFI REMPORTÉ';

  @override
  String get result_ended => 'DÉFI TERMINÉ';

  @override
  String get result_victory => 'Victoire.';

  @override
  String get result_draw => 'Égalité.';

  @override
  String get result_defeated => 'Défaite.';

  @override
  String result_you_beat(String name) {
    return 'Tu as battu $name';
  }

  @override
  String result_opponent_won(String name) {
    return '$name a gagné';
  }

  @override
  String result_perfectly_matched(String name) {
    return 'Toi et $name êtes parfaitement équilibrés.';
  }

  @override
  String get result_avg_score => 'score moy.';

  @override
  String result_points(int n) {
    return '$n point';
  }

  @override
  String result_points_plural(int n) {
    return '$n points';
  }

  @override
  String get result_split => 'PARTAGÉ';

  @override
  String get result_you_take => 'TU PRENDS';

  @override
  String get result_they_take => 'IL PREND';

  @override
  String get result_reward_claimed => '✓ RÉCOMPENSE RÉCLAMÉE';

  @override
  String get result_claim_reward => 'Réclamer la récompense →';

  @override
  String get result_wallet_sent => 'Envoyé dans ton portefeuille · code ';

  @override
  String get result_rematch => 'Revanche ⚔️';

  @override
  String get result_not_found => 'Résultat introuvable';

  @override
  String get result_me => 'MOI';

  @override
  String get map_no_guild => 'Rejoins une guilde pour attaquer des territoires';

  @override
  String get map_error => 'Impossible de charger la carte';

  @override
  String get territory_members => 'MEMBRES';

  @override
  String get territory_no_members => 'Aucun membre trouvé.';

  @override
  String get territory_load_error => 'Impossible de charger les membres.';

  @override
  String get territory_unknown => 'Inconnu';

  @override
  String get territory_just_claimed => 'vient d\'être conquis';

  @override
  String territory_held_years(int n) {
    return 'depuis ${n}a';
  }

  @override
  String territory_held_months(int n) {
    return 'depuis ${n}mo';
  }

  @override
  String territory_held_days(int n) {
    return 'depuis ${n}j';
  }

  @override
  String territory_held_hours(int n) {
    return 'depuis ${n}h';
  }

  @override
  String get attack_claim_title => 'Revendiquer le territoire neutre';

  @override
  String attack_guild_title(String guild) {
    return 'Attaquer $guild';
  }

  @override
  String get attack_rolling => 'Tirage de ta métrique…';

  @override
  String get attack_neutral_hint =>
      'Pas de défenseur, le territoire est à toi dans 24h.';

  @override
  String get attack_guild_hint =>
      'Le total de ta guilde doit battre celui de leur guilde.';

  @override
  String get attack_boost_section => 'BOOSTER TON ATTAQUE (OPTIONNEL)';

  @override
  String get attack_none => 'Aucun';

  @override
  String get attack_claim_btn => 'Revendiquer';

  @override
  String get attack_launch_btn => 'Lancer l\'attaque';

  @override
  String get battle_title => '⚔️  Bataille en cours';

  @override
  String battle_subtitle(String metric) {
    return 'Le plus grand total de $metric remporte ce territoire.';
  }

  @override
  String get battle_ending => 'Fin imminente…';

  @override
  String battle_attacking_banner(String metric) {
    return '🗡️ Ta guilde attaque, chaque $metric compte !';
  }

  @override
  String get battle_defending_banner =>
      '🛡️ Ta guilde défend, tiens la ligne !';

  @override
  String get battle_waiting => 'En attente du premier score…';

  @override
  String battle_attacker_leading(String name) {
    return '$name mène l\'assaut';
  }

  @override
  String battle_defender_holding(String name) {
    return '$name résiste';
  }

  @override
  String get battle_attacker_fallback => 'Attaquant';

  @override
  String get battle_unclaimed => 'Neutre';

  @override
  String get rules_title => 'Comment ça marche';

  @override
  String get rules_territories_title => 'Territoires';

  @override
  String get rules_territories_body =>
      'La carte est une grille de territoires neutres. En créant une guilde, tu en revendiques automatiquement un. La couleur de ta guilde marque tout ce que vous possédez.';

  @override
  String get rules_attacking_title => 'Attaquer';

  @override
  String get rules_attacking_body =>
      'Tu peux attaquer n\'importe quel territoire adjacent à l\'un des tiens. La métrique est tirée au sort — une machine à sous tourne au lancement. Les attaques durent 24 heures. Une seule attaque à la fois par guilde.';

  @override
  String get rules_winners_title => 'Comment les vainqueurs sont désignés';

  @override
  String get rules_winners_body =>
      'Pendant la fenêtre d\'attaque, les membres de chaque guilde synchronisent leurs données de santé. La guilde avec le total le plus élevé sur la métrique tirée gagne. Chaque membre compte, même les petites contributions.';

  @override
  String get rules_tie_title => 'Règle d\'égalité';

  @override
  String get rules_tie_body =>
      'Totaux identiques ? Le défenseur conserve le territoire. Les attaquants doivent surpasser pour conquérir.';

  @override
  String get rules_boosters_title => 'Boosters';

  @override
  String get rules_boosters_body =>
      'Avant de lancer, tu peux dépenser des Sapies sur un booster : Boost (+5%, 300α), Surge (+15%, 500α) ou Blitz (+20%, 900α). Le multiplicateur s\'applique au total de ta guilde pour cette attaque.';

  @override
  String get rules_slots_title => 'Places dans la guilde';

  @override
  String get rules_slots_body =>
      'Une nouvelle guilde peut accueillir 5 membres. Chaque territoire conquis débloque une place supplémentaire. Agrandis ton territoire pour agrandir ton équipe.';

  @override
  String get rules_solo_title => 'Joueurs solo';

  @override
  String get rules_solo_body =>
      'Tu peux revendiquer des territoires neutres seul, mais tu ne peux pas attaquer des guildes sans en rejoindre une d\'abord. Les joueurs solo sont des « guildes de 1 ».';

  @override
  String get guild_title => 'GUILDE';

  @override
  String get guild_error => 'Réessayer';

  @override
  String get guild_lone_wolf => 'Tu es un loup solitaire';

  @override
  String get guild_lone_wolf_body =>
      'Rejoins ou crée une guilde pour conquérir des territoires et combattre d\'autres guildes ensemble.';

  @override
  String get guild_create_cta => 'Créer une guilde';

  @override
  String get guild_create_hint =>
      'Tu deviens chef et revendiques ton premier territoire.';

  @override
  String get guild_join_cta => 'Rejoindre une guilde';

  @override
  String get guild_join_hint =>
      'Trouve une guilde existante et contribue immédiatement.';

  @override
  String get guild_members => 'MEMBRES';

  @override
  String get guild_leader => 'Chef';

  @override
  String get guild_attacks => 'ATTAQUES RÉCENTES';

  @override
  String get guild_attack_active => 'En cours';

  @override
  String get guild_attack_tie => 'Égalité';

  @override
  String get guild_attack_won => 'Gagnée';

  @override
  String get guild_attack_lost => 'Perdue';

  @override
  String get guild_leave_title => 'Quitter la guilde ?';

  @override
  String guild_leave_body(String name) {
    return 'Tu vas quitter $name. Les territoires de ta guilde restent.';
  }

  @override
  String get guild_leave_btn => 'Quitter';

  @override
  String get guild_leave_error => 'Impossible de quitter la guilde. Réessaie.';

  @override
  String get create_guild_title => 'Créer une guilde';

  @override
  String get create_guild_name_hint => 'Nom de la guilde';

  @override
  String get create_guild_color => 'COULEUR';

  @override
  String get create_guild_btn => 'Créer';

  @override
  String get join_guild_title => 'Rejoindre une guilde';

  @override
  String get join_guild_search_hint => 'Rechercher par nom';

  @override
  String get join_guild_not_found => 'Aucune guilde trouvée';

  @override
  String get join_guild_btn => 'Rejoindre';

  @override
  String get update_title => 'Version obsolète';

  @override
  String get update_btn => 'Mettre à jour';

  @override
  String get onboarding_welcome_headline => 'Progressez ensemble.';

  @override
  String get onboarding_welcome_subheadline => 'Devenez un meilleur Sapiens.';

  @override
  String get onboarding_welcome_leaderboard => 'EN DIRECT · CLASSEMENT MONDIAL';

  @override
  String get onboarding_welcome_body =>
      'On transforme tes données de santé en un jeu motivant';

  @override
  String get onboarding_welcome_cta => 'Trouver mon rang →';

  @override
  String get onboarding_welcome_login => 'J\'ai déjà un compte';

  @override
  String get onboarding_name_eyebrow => 'Vérification d\'identité';

  @override
  String get onboarding_name_headline => 'Comment le\nmonde doit t\'appeler ?';

  @override
  String get onboarding_name_hint_body =>
      'Tu pourras le changer plus tard. Le classement s\'en fiche, mais tes amis non.';

  @override
  String get onboarding_name_field_hint => 'Prénom & nom';

  @override
  String get onboarding_name_cta => 'C\'est moi →';

  @override
  String get onboarding_age_eyebrow => 'Calibration';

  @override
  String get onboarding_age_headline => 'Quel âge as-tu ?';

  @override
  String get onboarding_age_body =>
      'On te positionnera par rapport à ta tranche d\'âge, pas face à des triathlètes de 18 ans.';

  @override
  String get onboarding_age_label => 'ÂGE';

  @override
  String get onboarding_age_cta => 'Continuer →';

  @override
  String get onboarding_country_headline => 'Où tu relèves le défi ?';

  @override
  String get onboarding_country_subheadline => 'Plante ton drapeau.';

  @override
  String get onboarding_country_body =>
      'Tu concourras sur les classements mondial et national.';

  @override
  String get onboarding_country_search => 'Rechercher un pays...';

  @override
  String get onboarding_body_eyebrow => 'CORPS';

  @override
  String get onboarding_body_headline => 'Composition';

  @override
  String get onboarding_body_subheadline => 'corporelle.';

  @override
  String get onboarding_body_hint =>
      'Utilisé pour affiner ton score personnel.';

  @override
  String get onboarding_body_cta => 'Continuer →';

  @override
  String get onboarding_targets_eyebrow => 'FIXE LA BARRE';

  @override
  String get onboarding_targets_headline => 'Choisis les chiffres';

  @override
  String get onboarding_targets_subheadline => 'que tu défendras';

  @override
  String get onboarding_targets_daily => 'chaque jour.';

  @override
  String get onboarding_targets_cta => 'Verrouiller mes objectifs →';

  @override
  String get onboarding_permission_headline =>
      'Une autorisation. Ça vaut le coup.';

  @override
  String get onboarding_permission_subheadline => 'Ton appareil sait\ntout.';

  @override
  String get onboarding_permission_body => 'On fait juste les calculs.';

  @override
  String get onboarding_permission_cta => 'Autoriser l\'accès santé →';

  @override
  String get onboarding_permission_settings => 'Ouvrir les réglages →';

  @override
  String get onboarding_permission_denied_body =>
      'L\'accès à la santé est requis pour calculer ton score. Ouvre';

  @override
  String get onboarding_permission_denied_path =>
      'Réglages → Santé → Accès aux données';

  @override
  String get onboarding_permission_denied_enable =>
      'et active toutes les catégories SapiensRank.';

  @override
  String get onboarding_permission_heart_rate => 'Fréquence cardiaque';

  @override
  String get onboarding_permission_heart_rate_sub => 'Repos + VFC';

  @override
  String get onboarding_permission_activity => 'Activité';

  @override
  String get onboarding_permission_activity_sub => 'Pas, distance, kcal';

  @override
  String get onboarding_permission_sleep => 'Analyse du sommeil';

  @override
  String get onboarding_permission_sleep_sub => 'Phases, durée, score';

  @override
  String get onboarding_permission_stand => 'Heures debout';

  @override
  String get onboarding_permission_stand_sub => 'Heures bougées par jour';

  @override
  String get onboarding_score_headline => 'Ton premier score Sapiens.';

  @override
  String get onboarding_score_cta => 'Voir mon rang ? →';

  @override
  String get onboarding_auth_headline => 'Presque là.';

  @override
  String get onboarding_auth_subheadline => 'découvre ton classement.';

  @override
  String get onboarding_auth_body =>
      'Crée un compte pour découvrir ton classement mondial et conserver ton score.';

  @override
  String get onboarding_done_eyebrow => 'T\'es dans la place.';

  @override
  String get onboarding_done_headline => 'Bienvenue dans\nles rangs,';

  @override
  String get onboarding_done_body =>
      'Un seul classement.\nAujourd\'hui c\'est ta chance de grimper.';

  @override
  String get onboarding_done_cta => 'Entrer dans l\'app →';

  @override
  String get onboarding_notif_headline => 'Dernière chose.';

  @override
  String get onboarding_notif_body =>
      'Mises à jour quotidiennes du score. Invitations aux défis. Quand un ami te dépasse, tu le sauras.';

  @override
  String get onboarding_notif_yes => 'Oui, tiens-moi au courant 🔔';

  @override
  String get onboarding_notif_skip => 'Pas maintenant';

  @override
  String get onboarding_notif_authorizing => 'Autorisation…';

  @override
  String get onboarding_notif_headline_prefix => 'Reste dans le';

  @override
  String get onboarding_notif_headline_accent => 'challenge.';

  @override
  String get onboarding_notif_granted => 'Bienvenue dans les rangs, Sapien. ✓';

  @override
  String get onboarding_auth_email => 'Continuer avec l\'e-mail';

  @override
  String get onboarding_auth_or => 'ou';

  @override
  String get onboarding_score_not_bad => 'Pas mal.';

  @override
  String get onboarding_score_above_avg =>
      'Tu es au-dessus de la moyenne. Mais le monde est plus grand que la moyenne.';

  @override
  String get onboarding_sync_cta => 'Voir mon score →';

  @override
  String get onboarding_sync_loading_label => 'LECTURE DE TES DONNÉES';

  @override
  String get onboarding_sync_loading_body =>
      'Récupération de\nton historique santé.';

  @override
  String get onboarding_sync_done_label => 'TOUS SYSTÈMES OK';

  @override
  String get onboarding_sync_done_body => 'Données\nverrouillées.';

  @override
  String get onboarding_sync_done_cta => 'Au classement.';

  @override
  String get onboarding_rank_live => 'Rang mondial · en direct';

  @override
  String get onboarding_rank_calculating => 'Calcul du rang mondial';

  @override
  String get onboarding_rank_in_world => 'dans le monde';

  @override
  String onboarding_rank_you_are(String firstName) {
    return '$firstName, tu es';
  }

  @override
  String get onboarding_rank_higher_prefix => 'Mieux que';

  @override
  String get onboarding_rank_higher_suffix => 'des Sapiens';

  @override
  String onboarding_rank_out_of(String count) {
    return 'Sur $count classés aujourd\'hui';
  }

  @override
  String get onboarding_rank_join => 'Rejoindre le classement →';

  @override
  String get onboarding_rank_share => 'Partager mon rang';

  @override
  String get onboarding_bmi_frequency_question =>
      'À quelle fréquence veux-tu mettre à jour ton poids ?';

  @override
  String get onboarding_habits_do_you => 'Est-ce que tu';

  @override
  String get onboarding_habits_score_hint =>
      'Affecte ton score Sapiens personnel.';

  @override
  String get onboarding_habits_no_impact => 'Pas d\'impact sur le score';

  @override
  String get onboarding_habits_yes => 'Oui';

  @override
  String get onboarding_habits_quantity_impact =>
      'Affecte le score selon la quantité';

  @override
  String get onboarding_habits_decline => 'Je préfère ne pas dire';

  @override
  String get onboarding_habits_still_affects => 'Affecte quand même le score';

  @override
  String get onboarding_smoking_verb => 'fumes ?';

  @override
  String get onboarding_smoking_no => 'Non, je ne fume pas';

  @override
  String get onboarding_smoking_count => 'Cigarettes par jour';

  @override
  String get onboarding_drinking_verb => 'bois de l\'alcool ?';

  @override
  String get onboarding_drinking_no => 'Non, je ne bois pas';

  @override
  String get onboarding_drinking_count => 'Verres par semaine';

  @override
  String get onboarding_targets_energy => 'Énergie active';

  @override
  String get onboarding_privacy_body =>
      'Tes données ne quittent jamais ton téléphone. Seuls';

  @override
  String get onboarding_privacy_accent => 'score et rang';

  @override
  String get onboarding_privacy_suffix =>
      'sont uploadés — jamais les chiffres bruts.';
}

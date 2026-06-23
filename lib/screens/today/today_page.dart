import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/common/theme/today_skeleton.dart';
import 'package:sapiens_rank/common/widgets/sr_pill.dart';
import 'package:sapiens_rank/models/announcement.dart';
import 'package:sapiens_rank/screens/today/cubit/today_cubit.dart';
import 'package:sapiens_rank/screens/today/cubit/today_state.dart';
import 'package:sapiens_rank/screens/profile/profile_page.dart';
import 'package:sapiens_rank/screens/today/widgets/harvest_hero.dart';
import 'package:sapiens_rank/screens/today/widgets/sapie_coin.dart';
import 'package:sapiens_rank/screens/today/widgets/sapies_info_sheet.dart';
import 'package:sapiens_rank/screens/today/widgets/sparkline_chart.dart';
import 'package:sapiens_rank/services/health_service.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({
    super.key,
    this.onNavigateToWorld,
    this.onNavigateToBattle,
    this.onOpenLink,
  });

  final VoidCallback? onNavigateToWorld;
  final VoidCallback? onNavigateToBattle;
  final ValueChanged<String>? onOpenLink;

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  String? _openMetricKey;

  bool _walletBump = false;
  int _lastBalance = 0;
  bool _seenData = false;

  /// Reacts to a balance increase (a harvest landing) with the toast + bump.
  /// The first data emission only seeds [_lastBalance] so loads don't toast.
  void _onWalletChanged(TodayData data) {
    final delta = data.sapiesBalance - _lastBalance;
    final firstSight = !_seenData;
    _lastBalance = data.sapiesBalance;
    _seenData = true;
    if (firstSight || delta <= 0) return;

    // Slight delay so the coins appear to land before the wallet ticks up.
    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      _showHarvestToast(delta);
      setState(() => _walletBump = true);
      Future.delayed(const Duration(milliseconds: 520), () {
        if (mounted) setState(() => _walletBump = false);
      });
    });
  }

  void _showHarvestToast(int amount) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: SrColors.coin,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 2200),
          shape: const StadiumBorder(),
          width: 240,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SapieCoin(size: 16),
              const SizedBox(width: 8),
              Text(
                '+$amount Sapies harvested',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF15130F),
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TodayCubit()..load(),
      child: BlocConsumer<TodayCubit, DataState<TodayData>>(
        listenWhen: (_, curr) => curr.data != null,
        listener: (ctx, state) => _onWalletChanged(state.data!),
        builder: (ctx, state) {
          if (state.status == DataStatus.loading) {
            return const TodayLoadingSkeleton();
          }
          if (state.status == DataStatus.error) {
            return _ErrorBody(onRetry: () => ctx.read<TodayCubit>().load());
          }
          final data = state.data!;
          return _LoadedBody(
            data: data,
            balance: data.sapiesBalance,
            walletBump: _walletBump,
            harvestable: data.harvestable,
            onHarvest: () => ctx.read<TodayCubit>().harvest(),
            openMetricKey: _openMetricKey,
            onMetricTap: (key) => setState(
              () => _openMetricKey = _openMetricKey == key ? null : key,
            ),
            onRefresh: () => ctx.read<TodayCubit>().load(),
            onNavigateToWorld: widget.onNavigateToWorld,
            onNavigateToBattle: widget.onNavigateToBattle,
            announcements: data.announcements,
            onOpenLink: widget.onOpenLink,
            onDismissAnnouncement: (id) =>
                ctx.read<TodayCubit>().dismissAnnouncement(id),
          );
        },
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.srBg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Could not load health data',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: context.srTextMuted),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onRetry,
              child: Text(
                'Retry',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: SrColors.lime,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementBanner extends StatelessWidget {
  const _AnnouncementBanner({
    required this.announcement,
    required this.onDismiss,
    this.onOpenLink,
  });

  final Announcement announcement;
  final VoidCallback onDismiss;
  final ValueChanged<String>? onOpenLink;

  @override
  Widget build(BuildContext context) {
    final link = announcement.link;
    final tappable = link != null && onOpenLink != null;

    return GestureDetector(
      onTap: tappable ? () => onOpenLink!(link) : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        decoration: BoxDecoration(
          color: context.srAmber.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.srAmber.withAlpha(60)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.campaign_outlined, size: 18, color: context.srAmber),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.body,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: context.srText,
                      height: 1.35,
                    ),
                  ),
                  if (tappable) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          announcement.linkLabel ?? 'En savoir plus',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: context.srAmber,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 12,
                          color: context.srAmber,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: onDismiss,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.close, size: 16, color: context.srTextMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({
    required this.data,
    required this.balance,
    required this.walletBump,
    required this.harvestable,
    required this.onHarvest,
    required this.openMetricKey,
    required this.onMetricTap,
    required this.onRefresh,
    required this.announcements,
    required this.onDismissAnnouncement,
    this.onNavigateToWorld,
    this.onNavigateToBattle,
    this.onOpenLink,
  });

  final TodayData data;
  final int balance;
  final bool walletBump;
  final int harvestable;
  final VoidCallback onHarvest;
  final String? openMetricKey;
  final ValueChanged<String> onMetricTap;
  final Future<void> Function() onRefresh;
  final List<Announcement> announcements;
  final ValueChanged<String> onDismissAnnouncement;
  final VoidCallback? onNavigateToWorld;
  final VoidCallback? onNavigateToBattle;
  final ValueChanged<String>? onOpenLink;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom + 96.0;

    return Scaffold(
      backgroundColor: context.srBg,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: onRefresh,
          color: context.srLime,
          backgroundColor: context.srBgElev,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(18, 18, 18, bottomPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      ),
                      child: const SrPill(icon: Icons.person_outline),
                    ),
                    const Spacer(),
                    WalletPill(
                      balance: balance,
                      bump: walletBump,
                      onTap: () => SapiesInfoSheet.show(
                        context,
                        onNavigateToBattle: onNavigateToBattle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Center(
                  child: HarvestHero(
                    score: data.score,
                    harvestable: harvestable,
                    onHarvest: onHarvest,
                  ),
                ),
                const SizedBox(height: 10),
                _DeltaRow(
                  scoreDelta: data.scoreDelta,
                  history: data.scoreHistory,
                ),
                for (final a in announcements) ...[
                  const SizedBox(height: 16),
                  _AnnouncementBanner(
                    announcement: a,
                    onOpenLink: onOpenLink,
                    onDismiss: () => onDismissAnnouncement(a.id),
                  ),
                ],
                const SizedBox(height: 8),
                _RankTeaserCard(data: data, onTap: onNavigateToWorld),
                const SizedBox(height: 8),
                if (data.workouts.isNotEmpty) ...[
                  _WorkoutSection(
                    workouts: data.workouts,
                    dailyMinutes: data.dailyExerciseMinutes,
                    dailyTarget: data.dailyExerciseTarget,
                  ),
                  const SizedBox(height: 8),
                ],
                ...data.metrics.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _MetricCard(
                      metric: m,
                      isOpen: openMetricKey == m.key,
                      onTap: () => onMetricTap(m.key),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeltaRow extends StatelessWidget {
  const _DeltaRow({required this.scoreDelta, required this.history});

  final int scoreDelta;
  final List<int> history;

  @override
  Widget build(BuildContext context) {
    if (history.length < 2) return const SizedBox.shrink();

    final sign = scoreDelta >= 0 ? '+' : '';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$sign$scoreDelta',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: scoreDelta >= 0 ? SrColors.lime : SrColors.rose,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'VS YESTERDAY',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: context.srTextMuted,
                letterSpacing: 11 * 0.05,
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),
        Container(width: 1, height: 12, color: context.srLineStrong),
        const SizedBox(width: 14),
        SparklineChart(
          data: history,
          width: 84,
          height: 20,
          color: context.srLime,
        ),
      ],
    );
  }
}

class _RankTeaserCard extends StatelessWidget {
  const _RankTeaserCard({required this.data, this.onTap});

  final TodayData data;
  final VoidCallback? onTap;

  static String _fmtRank(int? rank) {
    if (rank == null) return '---';
    if (rank < 1000) return rank.toString();
    return '${rank ~/ 1000},${(rank % 1000).toString().padLeft(3, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.srBgElev,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: context.srLineStrong),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [SrColors.amber.withAlpha(34), Colors.transparent],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WORLD RANK',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: context.srTextDim,
                            letterSpacing: 10 * 0.18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '#',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                color: context.srTextMuted,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              _fmtRank(data.rankWorld),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: context.srText,
                                letterSpacing: 36 * -0.04,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (data.rankDelta != null && data.rankDelta != 0)
                              Text(
                                data.rankDelta! >= 0
                                    ? '↑${data.rankDelta}'
                                    : '↓${data.rankDelta!.abs()}',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: data.rankDelta! >= 0
                                      ? context.srLimeText
                                      : SrColors.rose,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          data.rankCountry != null
                              ? '${data.countryFlag} #${data.rankCountry}'
                              : '${data.countryFlag} ranking soon...',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: context.srTextMuted,
                            letterSpacing: 11 * 0.02,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: context.srTextMuted,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.metric,
    required this.isOpen,
    required this.onTap,
  });

  final TodayMetric metric;
  final bool isOpen;
  final VoidCallback onTap;

  static IconData _icon(String name) => switch (name) {
    'sleep' => Icons.bedtime,
    'steps' => Icons.directions_walk,
    'kcal' => Icons.local_fire_department,
    'stand' => Icons.accessibility_new,
    'hrv' => Icons.monitor_heart,
    'exercise' => Icons.fitness_center,
    _ => Icons.circle_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final pct = metric.progress;
    final limeColor = context.srLime;
    final barColor = pct >= 0.9
        ? limeColor
        : pct >= 0.6
        ? limeColor.withAlpha(204)
        : SrColors.amber;
    final statusLabel = metric.isMaxed
        ? 'maxed'
        : metric.isOnTrack
        ? 'on track'
        : 'push';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: context.srBgElev,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.srLine),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    _icon(metric.iconName),
                    color: context.srLimeText,
                    size: 18,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              metric.label,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: context.srText,
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '+${metric.contrib}',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: context.srText,
                                  ),
                                ),
                                Text(
                                  '/${metric.target}',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    color: context.srTextDim,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LayoutBuilder(
                          builder: (_, constraints) => Stack(
                            children: [
                              Container(
                                height: 4,
                                width: constraints.maxWidth,
                                decoration: BoxDecoration(
                                  color: context.srTintSm,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeOutCubic,
                                height: 4,
                                width:
                                    constraints.maxWidth * pct.clamp(0.0, 1.0),
                                decoration: BoxDecoration(
                                  color: barColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: isOpen
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(66, 0, 14, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    metric.rawLabel,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: context.srTextMuted,
                    ),
                  ),
                  Text(
                    statusLabel,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: context.srLimeText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutSection extends StatelessWidget {
  const _WorkoutSection({
    required this.workouts,
    required this.dailyMinutes,
    required this.dailyTarget,
  });

  final List<WorkoutEntry> workouts;
  final int dailyMinutes;
  final int dailyTarget;

  @override
  Widget build(BuildContext context) {
    final dailyPct = (dailyMinutes / dailyTarget).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: context.srBgElev,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.srLine),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Icon(Icons.bolt, color: context.srLimeText, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "Today's Activity",
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: context.srText,
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$dailyMinutes',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: context.srText,
                                  ),
                                ),
                                TextSpan(
                                  text: ' min today',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    color: context.srTextDim,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LayoutBuilder(
                        builder: (_, constraints) => Stack(
                          children: [
                            Container(
                              height: 4,
                              width: constraints.maxWidth,
                              decoration: BoxDecoration(
                                color: context.srTintSm,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOutCubic,
                              height: 4,
                              width: constraints.maxWidth * dailyPct,
                              decoration: BoxDecoration(
                                color: dailyPct >= 0.9
                                    ? context.srLime
                                    : dailyPct >= 0.6
                                    ? context.srLime.withAlpha(0xCC)
                                    : SrColors.amber,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.srLine),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${workouts.length} workout${workouts.length > 1 ? 's' : ''}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: context.srTextDim,
                    letterSpacing: 0.18 * 10,
                  ),
                ),
              ],
            ),
          ),
          ...workouts.map((w) => _WorkoutRow(workout: w)),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _WorkoutRow extends StatelessWidget {
  const _WorkoutRow({required this.workout});
  final WorkoutEntry workout;

  @override
  Widget build(BuildContext context) {
    final h = workout.startTime.hour;
    final m = workout.startTime.minute;
    final ampm = h < 12 ? 'AM' : 'PM';
    final hour = h % 12 == 0 ? 12 : h % 12;
    final timeStr = '$hour:${m.toString().padLeft(2, '0')}';

    final details = [
      '${workout.durationMinutes} min',
      if (workout.kcal > 0) '${workout.kcal} kcal',
      if (workout.distanceKm != null)
        '${workout.distanceKm!.toStringAsFixed(1)} km',
    ].join('  ·  ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Text(
                  timeStr,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: context.srText,
                  ),
                ),
                Text(
                  ampm,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 8,
                    color: context.srTextDim,
                    letterSpacing: 0.05 * 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 1.5,
            child: LayoutBuilder(
              builder: (_, c) => Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(height: 42, width: 1.5, color: context.srLine),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.srLime,
                      boxShadow: [
                        BoxShadow(
                          color: context.srLime.withAlpha(0x77),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(workout.icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.type,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.srText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  details,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: context.srTextMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

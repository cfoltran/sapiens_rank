import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/common/theme/today_skeleton.dart';
import 'package:sapiens_rank/screens/today/cubit/today_cubit.dart';
import 'package:sapiens_rank/screens/today/cubit/today_state.dart';
import 'package:sapiens_rank/screens/today/widgets/score_ring.dart';
import 'package:sapiens_rank/screens/today/widgets/sparkline_chart.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key, this.onNavigateToWorld});

  final VoidCallback? onNavigateToWorld;

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  String? _openMetricKey;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TodayCubit()..load(),
      child: BlocBuilder<TodayCubit, DataState<TodayData>>(
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
            openMetricKey: _openMetricKey,
            onMetricTap: (key) => setState(
              () => _openMetricKey = _openMetricKey == key ? null : key,
            ),
            onNavigateToWorld: widget.onNavigateToWorld,
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

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({
    required this.data,
    required this.openMetricKey,
    required this.onMetricTap,
    this.onNavigateToWorld,
  });

  final TodayData data;
  final String? openMetricKey;
  final ValueChanged<String> onMetricTap;
  final VoidCallback? onNavigateToWorld;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom + 96.0;

    return Scaffold(
      backgroundColor: context.srBg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(18, 4, 18, bottomPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: ScoreRing(score: data.score.toDouble())),
              const SizedBox(height: 10),
              _DeltaRow(
                scoreDelta: data.scoreDelta,
                history: data.scoreHistory,
              ),
              const SizedBox(height: 20),
              _RankTeaserCard(data: data, onTap: onNavigateToWorld),
              const SizedBox(height: 8),
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
          color: context.srLimeText,
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
                            if (data.rankDelta != null)
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
    _ => Icons.circle_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final pct = metric.progress;
    final limeColor = context.srLimeText;
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
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: context.srTintSm,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _icon(metric.iconName),
                      color: context.srLimeText,
                      size: 18,
                    ),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/screens/profile/cubit/profile_cubit.dart';
import 'package:sapiens_rank/screens/profile/cubit/profile_state.dart';
import 'package:sapiens_rank/services/auth_service.dart';
import 'package:sapiens_rank/services/health_targets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit()..load(),
      child: BlocBuilder<ProfileCubit, DataState<ProfileData>>(
        builder: (ctx, state) {
          if (state.status == DataStatus.loading) {
            return const _LoadingBody();
          }
          if (state.status == DataStatus.error || state.data == null) {
            return _ErrorBody(onRetry: () => ctx.read<ProfileCubit>().load());
          }
          return _LoadedBody(data: state.data!);
        },
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.srBg,
      body: Center(
        child: CircularProgressIndicator(color: context.srLime, strokeWidth: 2),
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
              'Could not load profile',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: context.srTextMuted,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onRetry,
              child: Text(
                'Retry',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.srLimeText,
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
  const _LoadedBody({required this.data});
  final ProfileData data;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom + 96.0;
    return Scaffold(
      backgroundColor: context.srBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(18, 4, 18, bottomPad),
          children: [
            Text(
              'PROFILE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: context.srTextDim,
                letterSpacing: 11 * 0.15,
              ),
            ),
            const SizedBox(height: 16),
            _IdentityCard(data: data),
            const SizedBox(height: 18),
            _TrendCard(data: data),
            const SizedBox(height: 18),
            _TargetsCard(data: data),
            const SizedBox(height: 18),
            _ThemeSelector(),
            const SizedBox(height: 18),
            _SignOutRow(),
          ],
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.data});
  final ProfileData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.srBgElev,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.srLime.withAlpha(68)),
        boxShadow: [
          BoxShadow(
            color: context.srLime.withAlpha(18),
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ProfileAvatar(data: data),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: context.srText,
                        letterSpacing: 22 * -0.02,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${data.handle} · ${data.joinedLabel}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        color: context.srTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ShareButton(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Container(height: 1, color: context.srLine),
          ),
          Row(
            children: [
              _StatCell(label: 'LIFETIME AVG', value: '${data.lifetimeAvg}'),
              _StatDivider(),
              _StatCell(label: 'W / L', value: '--'),
              _StatDivider(),
              _StatCell(
                label: 'STREAK',
                value: '${data.streak}d',
                accent: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.data});
  final ProfileData data;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.srLime, width: 2),
            boxShadow: [
              BoxShadow(
                color: context.srLime.withAlpha(50),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [SrColors.blue, SrColors.blueDeep],
              ),
            ),
            child: Center(
              child: Text(
                data.initials,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: SrColors.textInk,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: context.srBgElev,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(data.flag, style: const TextStyle(fontSize: 13)),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShareButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: context.srTintSm,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.srLineStrong),
      ),
      child: Icon(Icons.ios_share, color: context.srText, size: 17),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    this.accent = false,
  });
  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              color: context.srTextDim,
              letterSpacing: 9 * 0.15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: accent ? context.srLimeText : context.srText,
              letterSpacing: 22 * -0.03,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: context.srLine,
      margin: const EdgeInsets.only(right: 16),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.data});
  final ProfileData data;

  @override
  Widget build(BuildContext context) {
    final sign = data.trendDelta >= 0 ? '+' : '';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.srBgElev,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.srLineStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '30-DAY TREND',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: context.srTextDim,
                        letterSpacing: 10 * 0.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.trendLabel,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.srText,
                        letterSpacing: 18 * -0.02,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$sign${data.trendDelta.abs().toStringAsFixed(1)}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: data.trendDelta >= 0
                          ? context.srLimeText
                          : context.srRose,
                      letterSpacing: 24 * -0.03,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    'POINTS',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: context.srTextDim,
                      letterSpacing: 10 * 0.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (data.scoreHistory30d.length >= 2)
            _BigChart(entries: data.scoreHistory30d, windowDays: 30)
          else
            const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _BigChart extends StatelessWidget {
  const _BigChart({required this.entries, required this.windowDays});
  final List<(DateTime, int)> entries;
  final int windowDays;

  @override
  Widget build(BuildContext context) {
    final windowStart = DateTime.now().subtract(Duration(days: windowDays - 1));
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 100,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _BigChartPainter(
                entries: entries,
                windowStart: windowStart,
                windowDays: windowDays,
                limeColor: context.srLime,
                gridColor: context.srTintXs,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['${windowDays}d ago', '20d', '10d', 'today'].map((l) {
            return Text(
              l,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: context.srTextDim,
                letterSpacing: 9 * 0.1,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _BigChartPainter extends CustomPainter {
  const _BigChartPainter({
    required this.entries,
    required this.windowStart,
    required this.windowDays,
    required this.limeColor,
    required this.gridColor,
  });
  final List<(DateTime, int)> entries;
  final DateTime windowStart;
  final int windowDays;
  final Color limeColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.length < 2) return;

    final scores = entries.map((e) => e.$2).toList();
    final rawMin = scores.reduce((a, b) => a < b ? a : b).toDouble();
    final rawMax = scores.reduce((a, b) => a > b ? a : b).toDouble();
    final min = (rawMin - 5).clamp(0.0, 90.0);
    final max = (rawMax + 5).clamp(10.0, 100.0);
    final span = max - min == 0 ? 1.0 : max - min;

    final windowEnd = windowStart.add(Duration(days: windowDays - 1));
    final totalMs = windowEnd.difference(windowStart).inMilliseconds.toDouble();

    final pts = entries.map((e) {
      final date = e.$1;
      final score = e.$2;
      final dayMs = date.difference(windowStart).inMilliseconds.toDouble();
      final x = (dayMs / totalMs).clamp(0.0, 1.0) * size.width;
      final y = size.height - ((score - min) / span) * (size.height - 12) - 6;
      return Offset(x, y);
    }).toList();

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final p in [0.25, 0.5, 0.75]) {
      canvas.drawLine(
        Offset(0, size.height * p),
        Offset(size.width, size.height * p),
        gridPaint,
      );
    }

    final fillPath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final pt in pts.skip(1)) {
      fillPath.lineTo(pt.dx, pt.dy);
    }
    fillPath
      ..lineTo(pts.last.dx, size.height)
      ..lineTo(pts.first.dx, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [limeColor.withAlpha(77), limeColor.withAlpha(0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final pt in pts.skip(1)) {
      linePath.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = limeColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final last = pts.last;
    canvas.drawCircle(last, 8, Paint()..color = limeColor.withAlpha(51));
    canvas.drawCircle(last, 4, Paint()..color = limeColor);
  }

  @override
  bool shouldRepaint(_BigChartPainter old) =>
      old.entries != entries || old.limeColor != limeColor;
}

class _TargetsCard extends StatelessWidget {
  const _TargetsCard({required this.data});
  final ProfileData data;

  static const _metrics = [
    (key: 'steps', label: 'Steps', unit: '', icon: Icons.directions_walk),
    (
      key: 'kcal',
      label: 'Active kcal',
      unit: 'kcal',
      icon: Icons.local_fire_department,
    ),
    (key: 'sleep', label: 'Sleep', unit: 'h', icon: Icons.bedtime),
    (
      key: 'stand',
      label: 'Stand hours',
      unit: 'h',
      icon: Icons.accessibility_new,
    ),
  ];

  String _fmt(String key, HealthTargets t) => switch (key) {
    'steps' => _fmtSteps(t.steps),
    'kcal' => '${t.kcal.round()}',
    'sleep' => t.sleepHours.toStringAsFixed(1),
    'stand' => '${t.standHours}',
    _ => '',
  };

  static String _fmtSteps(int v) => v >= 1000
      ? '${v ~/ 1000},${(v % 1000).toString().padLeft(3, '0')}'
      : '$v';

  void _editTarget(BuildContext context, String key) {
    final cubit = context.read<ProfileCubit>();
    final targets = data.targets;
    final current = switch (key) {
      'steps' => targets.steps.toString(),
      'kcal' => targets.kcal.round().toString(),
      'sleep' => targets.sleepHours.toStringAsFixed(1),
      'stand' => targets.standHours.toString(),
      _ => '',
    };
    final label = _metrics.firstWhere((m) => m.key == key).label;
    final unit = _metrics.firstWhere((m) => m.key == key).unit;
    final ctrl = TextEditingController(text: current);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.srBgElev,
        title: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.srText,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          style: GoogleFonts.spaceGrotesk(fontSize: 18, color: context.srText),
          decoration: InputDecoration(
            suffixText: unit,
            suffixStyle: GoogleFonts.jetBrainsMono(color: context.srTextDim),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: context.srLine),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: context.srLime),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: context.srTextMuted)),
          ),
          TextButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text);
              if (v == null) return;
              final updated = switch (key) {
                'steps' => HealthTargets(
                  steps: v.round().clamp(1000, 30000),
                  kcal: targets.kcal,
                  sleepHours: targets.sleepHours,
                  standHours: targets.standHours,
                  hrv: targets.hrv,
                ),
                'kcal' => HealthTargets(
                  steps: targets.steps,
                  kcal: v.clamp(100, 2000),
                  sleepHours: targets.sleepHours,
                  standHours: targets.standHours,
                  hrv: targets.hrv,
                ),
                'sleep' => HealthTargets(
                  steps: targets.steps,
                  kcal: targets.kcal,
                  sleepHours: v.clamp(4, 12),
                  standHours: targets.standHours,
                  hrv: targets.hrv,
                ),
                'stand' => HealthTargets(
                  steps: targets.steps,
                  kcal: targets.kcal,
                  sleepHours: targets.sleepHours,
                  standHours: v.round().clamp(1, 24),
                  hrv: targets.hrv,
                ),
                _ => targets,
              };
              cubit.updateTargets(updated);
              Navigator.pop(ctx);
            },
            child: Text('Save', style: TextStyle(color: context.srLimeText)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.srBgElev,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.srLineStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MY TARGETS',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              color: context.srTextDim,
              letterSpacing: 10 * 0.15,
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < _metrics.length; i++) ...[
            if (i > 0) Divider(height: 1, color: context.srTintSm),
            GestureDetector(
              onTap: () => _editTarget(context, _metrics[i].key),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(_metrics[i].icon, size: 16, color: context.srLimeText),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _metrics[i].label,
                        style: tt.bodyMedium!.copyWith(
                          color: context.srTextMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${_fmt(_metrics[i].key, data.targets)} ${_metrics[i].unit}'
                          .trim(),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.srText,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: context.srTextDim,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final current = auth.themeMode;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.srTintXs,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.srLine),
      ),
      child: Row(
        children: [
          _ThemeOption(
            icon: Icons.light_mode_rounded,
            label: 'Light',
            selected: current == ThemeMode.light,
            onTap: () => auth.setThemeMode(ThemeMode.light),
          ),
          _ThemeOption(
            icon: Icons.phone_iphone_rounded,
            label: 'System',
            selected: current == ThemeMode.system,
            onTap: () => auth.setThemeMode(ThemeMode.system),
          ),
          _ThemeOption(
            icon: Icons.dark_mode_rounded,
            label: 'Dark',
            selected: current == ThemeMode.dark,
            onTap: () => auth.setThemeMode(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? context.srBgElev : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: selected ? Border.all(color: context.srLine) : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? context.srLimeText : context.srTextDim,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? context.srText : context.srTextDim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignOutRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    return GestureDetector(
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: context.srBgElev,
            title: Text('Sign out?', style: TextStyle(color: context.srText)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: context.srTextMuted),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(
                  'Sign out',
                  style: TextStyle(color: context.srRose),
                ),
              ),
            ],
          ),
        );
        if (confirmed == true) auth.signOut();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.srTintXs,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.srLine),
        ),
        child: Row(
          children: [
            Icon(Icons.logout, size: 18, color: context.srRose),
            const SizedBox(width: 12),
            Text(
              'Sign out',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: context.srRose,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

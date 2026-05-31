import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/screens/profile/cubit/profile_cubit.dart';
import 'package:sapiens_rank/screens/profile/cubit/profile_state.dart';
import 'package:sapiens_rank/services/auth_service.dart';

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
      backgroundColor: SrColors.bg,
      body: const Center(
        child: CircularProgressIndicator(color: SrColors.lime, strokeWidth: 2),
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
      backgroundColor: SrColors.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Could not load profile',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: SrColors.textMuted,
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
                  color: SrColors.lime,
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
      backgroundColor: SrColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(18, 4, 18, bottomPad),
          children: [
            // Header label
            Text(
              'PROFILE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: SrColors.textDim,
                letterSpacing: 11 * 0.15,
              ),
            ),
            const SizedBox(height: 16),

            // Identity card
            _IdentityCard(data: data),
            const SizedBox(height: 18),

            // 30-day trend
            _TrendCard(data: data),
            const SizedBox(height: 18),

            // Sign out
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
        color: SrColors.bgElev,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: SrColors.lime.withAlpha(68)),
        boxShadow: [
          BoxShadow(
            color: SrColors.lime.withAlpha(18),
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: avatar + info + share
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
                        color: SrColors.text,
                        letterSpacing: 22 * -0.02,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${data.handle} · ${data.joinedLabel}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        color: SrColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ShareButton(),
            ],
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Container(height: 1, color: SrColors.line),
          ),

          // Stats row
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
        // Lime ring
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: SrColors.lime, width: 2),
            boxShadow: [
              BoxShadow(
                color: SrColors.lime.withAlpha(50),
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
        // Flag badge
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: SrColors.bgElev,
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
        color: SrColors.tintSm,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SrColors.lineStrong),
      ),
      child: const Icon(Icons.ios_share, color: SrColors.text, size: 17),
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
              color: SrColors.textDim,
              letterSpacing: 9 * 0.15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: accent ? SrColors.lime : SrColors.text,
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
      color: SrColors.line,
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
        color: SrColors.bgElev,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: SrColors.lineStrong),
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
                        color: SrColors.textDim,
                        letterSpacing: 10 * 0.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.trendLabel,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: SrColors.text,
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
                          ? SrColors.lime
                          : SrColors.rose,
                      letterSpacing: 24 * -0.03,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    'POINTS',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: SrColors.textDim,
                      letterSpacing: 10 * 0.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (data.scoreHistory30d.length >= 2)
            _BigChart(data: data.scoreHistory30d)
          else
            const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _BigChart extends StatelessWidget {
  const _BigChart({required this.data});
  final List<int> data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 100,
          child: RepaintBoundary(
            child: CustomPaint(painter: _BigChartPainter(data: data)),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['30d ago', '20d', '10d', 'today'].map((l) {
            return Text(
              l,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: SrColors.textDim,
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
  const _BigChartPainter({required this.data});
  final List<int> data;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final rawMin = data.reduce((a, b) => a < b ? a : b).toDouble();
    final rawMax = data.reduce((a, b) => a > b ? a : b).toDouble();
    // Expand range a bit so the line isn't clipped
    final min = (rawMin - 5).clamp(0.0, 90.0);
    final max = (rawMax + 5).clamp(10.0, 100.0);
    final span = max - min == 0 ? 1.0 : max - min;

    final pts = List.generate(data.length, (i) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i] - min) / span) * (size.height - 12) - 6;
      return Offset(x, y);
    });

    // Grid lines
    final gridPaint = Paint()
      ..color = SrColors.tintXs
      ..strokeWidth = 1;
    for (final p in [0.25, 0.5, 0.75]) {
      final y = size.height * p;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Fill path
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
          colors: [SrColors.lime.withAlpha(77), SrColors.lime.withAlpha(0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final pt in pts.skip(1)) {
      linePath.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = SrColors.lime
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // End dot + pulse ring
    final last = pts.last;
    canvas.drawCircle(last, 8, Paint()..color = SrColors.lime.withAlpha(51));
    canvas.drawCircle(last, 4, Paint()..color = SrColors.lime);
  }

  @override
  bool shouldRepaint(_BigChartPainter old) => old.data != data;
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
            backgroundColor: SrColors.bgElev,
            title: Text('Sign out?', style: TextStyle(color: SrColors.text)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: SrColors.textMuted),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text('Sign out', style: TextStyle(color: SrColors.rose)),
              ),
            ],
          ),
        );
        if (confirmed == true) auth.signOut();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: SrColors.tintXs,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SrColors.line),
        ),
        child: Row(
          children: [
            const Icon(Icons.logout, size: 18, color: SrColors.rose),
            const SizedBox(width: 12),
            Text(
              'Sign out',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: SrColors.rose,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

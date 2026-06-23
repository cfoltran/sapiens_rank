import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/l10n/app_localizations.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/arena_button.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/onboarding_text.dart';

class DoneStep extends StatefulWidget {
  const DoneStep({super.key, required this.firstName, required this.onEnter});

  final String firstName;
  final VoidCallback onEnter;

  @override
  State<DoneStep> createState() => _DoneStepState();
}

class _DoneStepState extends State<DoneStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dotsCtrl;

  @override
  void initState() {
    super.initState();
    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _dotsCtrl.dispose();
    super.dispose();
  }

  String get _firstName {
    final first = widget.firstName.trim().split(' ').first;
    return first.isNotEmpty ? first : 'Sapien';
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final limeColor = context.srLime;
    return Scaffold(
      backgroundColor: context.srBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _dotsCtrl,
              builder: (_, _) => CustomPaint(
                painter: _DotsPainter(
                  tick: _dotsCtrl.value,
                  limeColor: limeColor,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OnboardingEyebrow(
                        AppLocalizations.of(context).onboarding_done_eyebrow,
                        color: SrColors.magenta,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        AppLocalizations.of(context).onboarding_done_headline,
                        textAlign: TextAlign.center,
                        style: tt.displayLarge!.copyWith(color: context.srText),
                      ),
                      Text(
                        '$_firstName.',
                        textAlign: TextAlign.center,
                        style: tt.displayLarge!.copyWith(
                          color: context.srLimeText,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context).onboarding_done_body,
                        textAlign: TextAlign.center,
                        style: tt.bodyLarge!.copyWith(
                          color: context.srTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 36),
                  child: ArenaButton(
                    label: AppLocalizations.of(context).onboarding_done_cta,
                    onTap: widget.onEnter,
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

class _DotsPainter extends CustomPainter {
  const _DotsPainter({required this.tick, required this.limeColor});
  final double tick;
  final Color limeColor;

  static final _dots = _generate();

  static List<({double x, double y, double size, double phase, bool isMagenta})>
  _generate() {
    final rng = Random(77);
    return List.generate(80, (_) {
      final r = rng.nextDouble();
      return (
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: rng.nextDouble() * 2 + 0.5,
        phase: rng.nextDouble() * 2 * pi,
        isMagenta: r > 0.85,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final d in _dots) {
      final opacity = (0.08 + 0.45 * (0.5 + 0.5 * sin(tick * 2 * pi + d.phase)))
          .clamp(0.0, 1.0);
      final color = d.isMagenta ? SrColors.magenta : limeColor;
      canvas.drawCircle(
        Offset(d.x * size.width, d.y * size.height),
        d.size,
        Paint()..color = color.withAlpha((opacity * 255).round()),
      );
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) =>
      old.tick != tick || old.limeColor != limeColor;
}

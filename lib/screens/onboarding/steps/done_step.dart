import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
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
    return Scaffold(
      backgroundColor: SrColors.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _dotsCtrl,
              builder: (_, _) =>
                  CustomPaint(painter: _DotsPainter(tick: _dotsCtrl.value)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _LogoMark(),
                      const SizedBox(height: 32),
                      const OnboardingEyebrow(
                        "You're in.",
                        color: SrColors.magenta,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Welcome to\nthe ranks,',
                        textAlign: TextAlign.center,
                        style: tt.displayLarge!.copyWith(color: SrColors.text),
                      ),
                      Text(
                        '$_firstName.',
                        textAlign: TextAlign.center,
                        style: tt.displayLarge!.copyWith(color: SrColors.lime),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '2.4M Sapiens. One leaderboard.\nToday is your chance to climb.',
                        textAlign: TextAlign.center,
                        style: tt.bodyLarge!.copyWith(
                          color: SrColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 36),
                  child: ArenaButton(
                    label: 'Enter the app →',
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

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: SrColors.lime,
        boxShadow: [
          BoxShadow(
            color: SrColors.lime.withAlpha(80),
            blurRadius: 32,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          'SR',
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.normal,
            letterSpacing: -1,
            color: SrColors.textInk,
          ),
        ),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  const _DotsPainter({required this.tick});
  final double tick;

  static final _dots = _generate();

  static List<({double x, double y, double size, double phase, Color color})>
  _generate() {
    final rng = Random(77);
    return List.generate(80, (_) {
      final r = rng.nextDouble();
      return (
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: rng.nextDouble() * 2 + 0.5,
        phase: rng.nextDouble() * 2 * pi,
        color: r > 0.85
            ? SrColors.magenta
            : r > 0.70
            ? SrColors.lime
            : Colors.white,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final d in _dots) {
      final opacity = (0.08 + 0.45 * (0.5 + 0.5 * sin(tick * 2 * pi + d.phase)))
          .clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(d.x * size.width, d.y * size.height),
        d.size,
        Paint()..color = d.color.withAlpha((opacity * 255).round()),
      );
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) => old.tick != tick;
}

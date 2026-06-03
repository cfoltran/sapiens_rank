import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/arena_button.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/onboarding_text.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/step_shell.dart';

class ScoreRevealStep extends StatefulWidget {
  const ScoreRevealStep({
    super.key,
    required this.firstName,
    required this.progress,
    required this.total,
    required this.score,
    required this.onNext,
  });

  final String firstName;
  final int progress;
  final int total;
  final int score;
  final VoidCallback onNext;

  @override
  State<ScoreRevealStep> createState() => _ScoreRevealStepState();
}

class _ScoreRevealStepState extends State<ScoreRevealStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scoreAnim;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _scoreAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutQuart);
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        setState(() => _done = true);
      }
    });
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _eyebrow {
    final first = widget.firstName.trim().split(' ').first;
    return first.isNotEmpty ? '$first, here it is' : 'Here it is';
  }

  @override
  Widget build(BuildContext context) {
    final limeColor = context.srLime;
    final trackColor = context.srTrack;

    return StepShell(
      progress: widget.progress,
      total: widget.total,
      footer: AnimatedOpacity(
        opacity: _done ? 1 : 0,
        duration: const Duration(milliseconds: 400),
        child: IgnorePointer(
          ignoring: !_done,
          child: ArenaButton(label: 'See my rank? →', onTap: widget.onNext),
        ),
      ),
      body: Column(
        children: [
          OnboardingEyebrow(_eyebrow),
          const SizedBox(height: 14),
          Text(
            'Your first Sapiens Score.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineLarge!.copyWith(color: context.srText),
          ),
          const SizedBox(height: 40),
          AnimatedBuilder(
            animation: _scoreAnim,
            builder: (_, _) => _BigRing(
              score: widget.score * _scoreAnim.value,
              target: widget.score.toDouble(),
              limeColor: limeColor,
              trackColor: trackColor,
            ),
          ),
          const SizedBox(height: 36),
          AnimatedOpacity(
            opacity: _done ? 1 : 0,
            duration: const Duration(milliseconds: 500),
            child: AnimatedSlide(
              offset: _done ? Offset.zero : const Offset(0, 0.3),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              child: const _DoneText(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BigRing extends StatelessWidget {
  const _BigRing({
    required this.score,
    required this.target,
    required this.limeColor,
    required this.trackColor,
  });

  final double score;
  final double target;
  final Color limeColor;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final fraction = (score / 100).clamp(0.0, 1.0);
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(260, 260),
            painter: _RingPainter(
              fraction: fraction,
              limeColor: limeColor,
              trackColor: trackColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SAPIENS SCORE',
                style: tt.labelMedium!.copyWith(
                  fontWeight: FontWeight.normal,
                  letterSpacing: 2.2,
                  color: context.srTextMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${score.round()}',
                style: tt.displayLarge!.copyWith(
                  fontSize: 96,
                  height: 1,
                  letterSpacing: 96 * -0.05,
                  color: context.srText,
                ),
              ),
              Text(
                '/ 100',
                style: tt.labelMedium!.copyWith(
                  fontWeight: FontWeight.normal,
                  color: context.srTextDim,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.fraction,
    required this.limeColor,
    required this.trackColor,
  });

  final double fraction;
  final Color limeColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeW = 18.0;
    final radius = (size.width - strokeW) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..color = trackColor,
    );

    if (fraction <= 0) return;

    final sweepAngle = 2 * pi * fraction;

    canvas.drawArc(
      rect,
      -pi / 2,
      sweepAngle,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW + 10
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: -pi / 2,
          endAngle: -pi / 2 + sweepAngle,
          colors: [limeColor.withAlpha(80), SrColors.magenta.withAlpha(80)],
        ).createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    canvas.drawArc(
      rect,
      -pi / 2,
      sweepAngle,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: -pi / 2,
          endAngle: -pi / 2 + sweepAngle,
          colors: [limeColor, SrColors.magenta],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction ||
      old.limeColor != limeColor ||
      old.trackColor != trackColor;
}

class _DoneText extends StatelessWidget {
  const _DoneText();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          'Not bad.',
          style: tt.titleLarge!.copyWith(color: context.srLimeText),
        ),
        const SizedBox(height: 6),
        Text(
          "You're above average. But the world is bigger than average.",
          textAlign: TextAlign.center,
          style: tt.labelMedium!.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: context.srTextMuted,
            letterSpacing: 0.6,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/arena_button.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/onboarding_text.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/step_shell.dart';

class RankRevealStep extends StatefulWidget {
  const RankRevealStep({
    super.key,
    required this.firstName,
    required this.countryCode,
    required this.progress,
    required this.total,
    required this.onNext,
  });

  final String firstName;
  final String countryCode;
  final int progress;
  final int total;
  final VoidCallback onNext;

  @override
  State<RankRevealStep> createState() => _RankRevealStepState();
}

enum _Phase { intro, counting, landed }

class _RankRevealStepState extends State<RankRevealStep>
    with TickerProviderStateMixin {
  static const _from = 24000;
  static const _to = 3;

  late final AnimationController _dotsCtrl;
  late final AnimationController _countCtrl;
  late final Animation<double> _countAnim;

  _Phase _phase = _Phase.intro;

  @override
  void initState() {
    super.initState();

    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _countCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _countAnim = CurvedAnimation(
      parent: _countCtrl,
      curve: Curves.easeOutQuart,
    );

    _countCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        setState(() => _phase = _Phase.landed);
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _phase = _Phase.counting);
        _countCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _dotsCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  int get _currentNumber {
    final v = _from - (_from - _to) * _countAnim.value;
    return v.round();
  }

  String get _firstName {
    final first = widget.firstName.trim().split(' ').first;
    return first.isNotEmpty ? first : 'You';
  }

  @override
  Widget build(BuildContext context) {
    final landed = _phase == _Phase.landed;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: SrColors.bg,
      body: Stack(
        children: [
          // Full-screen dot field
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _dotsCtrl,
              builder: (_, _) =>
                  CustomPaint(painter: _DotsPainter(tick: _dotsCtrl.value)),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress bar
                StepProgressDots(
                  progress: widget.progress,
                  total: widget.total,
                ),
                // Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        OnboardingEyebrow(
                          landed
                              ? 'World rank · live'
                              : 'Calculating world rank',
                          color: SrColors.magenta,
                        ),
                        if (landed) ...[
                          const SizedBox(height: 14),
                          _IntroText(firstName: _firstName),
                        ],
                        const SizedBox(height: 18),
                        AnimatedBuilder(
                          animation: _countAnim,
                          builder: (_, _) => _RankNumber(
                            number: _phase == _Phase.intro
                                ? _from
                                : _currentNumber,
                            isLanding: landed,
                          ),
                        ),
                        Text(
                          'in the world',
                          style: tt.labelMedium!.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: SrColors.textMuted,
                            letterSpacing: 1.2,
                          ),
                        ),
                        if (landed) ...[
                          const SizedBox(height: 28),
                          const _StatsCard(),
                          const SizedBox(height: 18),
                          _CountryCard(countryCode: widget.countryCode),
                        ],
                      ],
                    ),
                  ),
                ),
                // Footer
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 36),
                  child: AnimatedOpacity(
                    opacity: landed ? 1 : 0,
                    duration: const Duration(milliseconds: 400),
                    child: IgnorePointer(
                      ignoring: !landed,
                      child: Column(
                        children: [
                          ArenaButton(
                            label: 'Join the leaderboard →',
                            onTap: widget.onNext,
                            color: SrColors.magenta,
                          ),
                          const SizedBox(height: 8),
                          ArenaSecondaryButton(
                            label: 'Share my rank',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
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

class _IntroText extends StatelessWidget {
  const _IntroText({required this.firstName});
  final String firstName;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$firstName, you are',
      style: Theme.of(context).textTheme.titleLarge!.copyWith(
        fontWeight: FontWeight.w500,
        color: SrColors.textMuted,
      ),
    );
  }
}

class _RankNumber extends StatelessWidget {
  const _RankNumber({required this.number, required this.isLanding});
  final int number;
  final bool isLanding;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [SrColors.lime, SrColors.magenta],
      ).createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(
        '#${_format(number)}',
        style: Theme.of(context).textTheme.displayLarge!.copyWith(
          fontSize: 88,
          height: 1,
          letterSpacing: 88 * -0.06,
          color: Colors.white,
        ),
      ),
    );
  }

  static String _format(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0x14FF4D97),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x44FF4D97)),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: tt.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: SrColors.text,
                    ),
                    children: const [
                      TextSpan(text: 'Higher than '),
                      TextSpan(
                        text: '99.88%',
                        style: TextStyle(color: SrColors.magenta),
                      ),
                      TextSpan(text: ' of Sapiens'),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Out of 2,401,839 ranked today',
                  style: tt.labelSmall!.copyWith(
                    fontWeight: FontWeight.normal,
                    color: SrColors.textMuted,
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

class _CountryCard extends StatelessWidget {
  const _CountryCard({required this.countryCode});
  final String countryCode;

  static const _flags = {
    'FR': ('🇫🇷', 'France'),
    'US': ('🇺🇸', 'United States'),
    'GB': ('🇬🇧', 'United Kingdom'),
    'DE': ('🇩🇪', 'Germany'),
    'JP': ('🇯🇵', 'Japan'),
    'KR': ('🇰🇷', 'South Korea'),
    'IN': ('🇮🇳', 'India'),
    'BR': ('🇧🇷', 'Brazil'),
    'CA': ('🇨🇦', 'Canada'),
    'AU': ('🇦🇺', 'Australia'),
    'ES': ('🇪🇸', 'Spain'),
    'IT': ('🇮🇹', 'Italy'),
    'NL': ('🇳🇱', 'Netherlands'),
    'SE': ('🇸🇪', 'Sweden'),
    'NO': ('🇳🇴', 'Norway'),
    'CH': ('🇨🇭', 'Switzerland'),
    'BE': ('🇧🇪', 'Belgium'),
    'PT': ('🇵🇹', 'Portugal'),
    'AE': ('🇦🇪', 'UAE'),
    'SG': ('🇸🇬', 'Singapore'),
    'MX': ('🇲🇽', 'Mexico'),
    'CN': ('🇨🇳', 'China'),
  };

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final entry = _flags[countryCode] ?? ('🌍', 'Global');
    final flag = entry.$1;
    final name = entry.$2;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x0AFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SrColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'IN ${name.toUpperCase()}',
                style: tt.labelSmall!.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.normal,
                  color: SrColors.textDim,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                '#412',
                style: tt.titleSmall!.copyWith(color: SrColors.text),
              ),
            ],
          ),
        ],
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
    final rng = Random(42);
    return List.generate(90, (_) {
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
      final opacity = (0.1 + 0.5 * (0.5 + 0.5 * sin(tick * 2 * pi + d.phase)))
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

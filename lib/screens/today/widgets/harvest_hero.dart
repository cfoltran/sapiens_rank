import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/screens/today/widgets/sapie_coin.dart';
import 'package:sapiens_rank/screens/today/widgets/score_ring.dart';

/// The tappable Sapiens Score ring. Coins fill the inner disc with the day's
/// harvestable crop; tapping launches them toward the wallet and collects.
class HarvestHero extends StatefulWidget {
  const HarvestHero({
    super.key,
    required this.score,
    required this.harvestable,
    required this.onHarvest,
    this.size = 260,
  });

  final int score;
  final int harvestable;
  final VoidCallback onHarvest;
  final double size;

  @override
  State<HarvestHero> createState() => _HarvestHeroState();
}

class _HarvestHeroState extends State<HarvestHero>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _fly;
  List<_FlyingCoin> _coins = const [];

  bool get _canHarvest => widget.harvestable > 0;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _fly =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1100),
        )..addStatusListener((s) {
          if (s == AnimationStatus.completed) setState(() => _coins = const []);
        });
  }

  @override
  void dispose() {
    _pulse.dispose();
    _fly.dispose();
    super.dispose();
  }

  void _harvest() {
    if (!_canHarvest || _fly.isAnimating) return;
    HapticFeedback.mediumImpact();
    final rnd = Random();
    _coins = List.generate(
      14,
      (i) => _FlyingCoin(
        start: Offset(
          (rnd.nextDouble() - 0.5) * 60,
          30 + rnd.nextDouble() * 30,
        ),
        end: Offset(
          90 + (rnd.nextDouble() - 0.5) * 36,
          -widget.size * 0.9 - rnd.nextDouble() * 30,
        ),
        delay: rnd.nextDouble() * 0.16,
      ),
    );
    _fly.forward(from: 0);
    widget.onHarvest();
  }

  @override
  Widget build(BuildContext context) {
    final coinFill = (widget.harvestable / 100).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'SAPIENS SCORE',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: context.srTextMuted,
            letterSpacing: 10 * 0.18,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _harvest,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (_canHarvest)
                _PulseHalo(animation: _pulse, size: widget.size + 28),
              ScoreRing(
                score: widget.score.toDouble(),
                size: widget.size,
                coinFill: coinFill,
              ),
              if (_coins.isNotEmpty)
                AnimatedBuilder(
                  animation: _fly,
                  builder: (context, _) => Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      for (final c in _coins)
                        _FlyingCoinView(coin: c, progress: _fly.value),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (_canHarvest) ...[
          const SizedBox(height: 14),
          _HarvestButton(amount: widget.harvestable, onTap: _harvest),
        ],
      ],
    );
  }
}

class _PulseHalo extends StatelessWidget {
  const _PulseHalo({required this.animation, required this.size});

  final Animation<double> animation;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              SrColors.coin.withAlpha((40 + 30 * animation.value).round()),
              Colors.transparent,
            ],
            stops: const [0.62, 1.0],
          ),
        ),
      ),
    );
  }
}

class _FlyingCoinView extends StatelessWidget {
  const _FlyingCoinView({required this.coin, required this.progress});

  final _FlyingCoin coin;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final raw = ((progress - coin.delay) / (1 - coin.delay)).clamp(0.0, 1.0);
    if (raw <= 0) return const SizedBox.shrink();
    final pos = Curves.easeIn.transform(raw);
    final offset = Offset.lerp(coin.start, coin.end, pos)!;
    final opacity = raw < 0.15 ? raw / 0.15 : 1 - (raw - 0.15) / 0.85;
    final scale = raw < 0.15 ? 0.3 + raw / 0.15 * 0.85 : 1.15 - raw * 0.9;
    return Transform.translate(
      offset: offset,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: scale.clamp(0.2, 1.2),
          child: const SapieCoin(size: 18),
        ),
      ),
    );
  }
}

class _HarvestButton extends StatelessWidget {
  const _HarvestButton({required this.amount, required this.onTap});

  final int amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: SrColors.coin,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(color: SrColors.coin.withAlpha(0x66), blurRadius: 18),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SapieCoin(size: 16),
            const SizedBox(width: 7),
            Text(
              'Tap to harvest · +$amount',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF15130F),
                letterSpacing: -0.13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlyingCoin {
  const _FlyingCoin({
    required this.start,
    required this.end,
    required this.delay,
  });

  final Offset start;
  final Offset end;
  final double delay;
}

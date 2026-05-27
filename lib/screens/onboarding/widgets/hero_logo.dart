import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';

class HeroLogo extends StatefulWidget {
  const HeroLogo({super.key, this.size = 80});

  final double size;

  @override
  State<HeroLogo> createState() => _HeroLogoState();
}

class _HeroLogoState extends State<HeroLogo> with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final AnimationController _glowCtrl;
  late final Animation<double> _scale;
  late final Animation<double> _rotate;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _glowCtrl = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutBack),
    );

    _rotate = Tween<double>(begin: -8 * pi / 180, end: 0).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutBack),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );

    _entranceCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _glowCtrl.repeat(reverse: true);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _entranceCtrl.forward(),
    );
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final haloSize = s * 1.7;

    return SizedBox(
      width: haloSize,
      height: haloSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _glowCtrl,
            builder: (_, _) {
              final scale = 1.0 + _glowCtrl.value * 0.15;
              final opacity = _glowCtrl.isAnimating
                  ? (0.9 + _glowCtrl.value * 0.1)
                  : 0.0;
              return Transform.scale(
                scale: scale,
                child: RepaintBoundary(
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: haloSize,
                      height: haloSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: SrColors.lime.withAlpha(64),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _entranceCtrl,
            builder: (_, child) => Opacity(
              opacity: _opacity.value,
              child: Transform.scale(
                scale: _scale.value,
                child: Transform.rotate(angle: _rotate.value, child: child),
              ),
            ),
            child: _IconBox(size: s),
          ),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(102),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
          BoxShadow(color: SrColors.lime.withAlpha(51), blurRadius: 32),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.asset(
          'assets/images/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _AlphaFallback(size: size),
        ),
      ),
    );
  }
}

class _AlphaFallback extends StatelessWidget {
  const _AlphaFallback({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: SrColors.bgElev2,
      child: Center(
        child: Text(
          'α',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: size * 0.52,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            color: SrColors.lime,
          ),
        ),
      ),
    );
  }
}

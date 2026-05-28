import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';

/// Animated shimmer placeholder. Stretch-fills its parent when [width] is
/// omitted; use inside a constrained parent (Row, Column stretch, etc.).
class SrSkeleton extends StatefulWidget {
  const SrSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 10,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<SrSkeleton> createState() => _SrSkeletonState();
}

class _SrSkeletonState extends State<SrSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder:
          (context, _) => Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: LinearGradient(
                begin: Alignment(-1.5 + _ctrl.value * 3.5, 0),
                end: Alignment(-0.5 + _ctrl.value * 3.5, 0),
                colors: const [
                  SrColors.bgElev,
                  SrColors.bgElev2,
                  SrColors.bgElev,
                ],
              ),
            ),
          ),
    );
  }
}

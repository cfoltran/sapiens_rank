import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';

class SrSelectableCard extends StatelessWidget {
  const SrSelectableCard({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.child,
    this.accentColor,
    this.borderRadius = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.margin,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;
  final Color? accentColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? context.srLime;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: isSelected ? accent.withAlpha(26) : context.srTintXs,
          border: Border.all(color: isSelected ? accent : context.srLine),
        ),
        child: child,
      ),
    );
  }
}

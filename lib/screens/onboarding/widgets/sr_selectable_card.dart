import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';

class SrSelectableCard extends StatelessWidget {
  const SrSelectableCard({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.child,
    this.accentColor = SrColors.lime,
    this.borderRadius = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.margin,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;
  final Color accentColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: isSelected
              ? accentColor.withAlpha(26)
              : const Color(0x08FFFFFF),
          border: Border.all(color: isSelected ? accentColor : SrColors.line),
        ),
        child: child,
      ),
    );
  }
}

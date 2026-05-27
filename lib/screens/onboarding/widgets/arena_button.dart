import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';

class ArenaButton extends StatefulWidget {
  const ArenaButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
  });

  final String label;
  final VoidCallback? onTap;
  final Color? color;

  @override
  State<ArenaButton> createState() => _ArenaButtonState();
}

class _ArenaButtonState extends State<ArenaButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final color = widget.color ?? SrColors.lime;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      child: RepaintBoundary(
        child: AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.38,
          duration: const Duration(milliseconds: 200),
          child: AnimatedScale(
            scale: _pressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 24),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(100),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: color.withAlpha(51),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(color: color.withAlpha(33), blurRadius: 32),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  widget.label,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: SrColors.textInk,
                    letterSpacing: -0.16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ArenaSecondaryButton extends StatelessWidget {
  const ArenaSecondaryButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w500,
              color: SrColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

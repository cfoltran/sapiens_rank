import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';

class SrTextField extends StatelessWidget {
  const SrTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.style,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.autofocus = false,
    this.borderRadius = 16,
    this.borderColor,
    this.focusedBorderColor,
    this.contentPadding,
    this.prefixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool autofocus;
  final double borderRadius;

  /// Border color for enabled state. Defaults to [SrColors.lineStrong].
  final Color? borderColor;

  /// Border color when focused. Defaults to [SrColors.lime].
  final Color? focusedBorderColor;

  final EdgeInsetsGeometry? contentPadding;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final resolvedStyle = (style ?? tt.bodyLarge!).copyWith(
      color: SrColors.text,
    );
    final enabled = borderColor ?? SrColors.lineStrong;
    final focused = focusedBorderColor ?? SrColors.lime;
    final radius = BorderRadius.circular(borderRadius);

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      autocorrect: autocorrect,
      autofocus: autofocus,
      style: resolvedStyle,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: resolvedStyle.copyWith(color: SrColors.textDim),
        prefixIcon: prefixIcon,
        prefixIconConstraints: prefixIcon != null
            ? const BoxConstraints(minWidth: 0)
            : null,
        filled: true,
        fillColor: SrColors.tintXs,
        contentPadding:
            contentPadding ??
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: enabled),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: enabled),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: focused, width: 1.5),
        ),
      ),
    );
  }
}

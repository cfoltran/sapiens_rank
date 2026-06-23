import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';

enum SrPillSize { small, medium }

/// A fully-rounded pill with a transparent colored tint: [color] drives the
/// fill, border and (by default) the content. Pass [color] null for a neutral
/// elevated pill. Use [leading] for a custom icon widget (e.g. a coin).
///
/// Set [floating] for controls that hover over content (e.g. map overlays):
/// a translucent elevated fill and drop shadow replace the tint, while [color]
/// still drives the content color.
class SrPill extends StatelessWidget {
  const SrPill({
    super.key,
    this.label,
    this.color,
    this.icon,
    this.leading,
    this.trailing,
    this.textColor,
    this.size = SrPillSize.medium,
    this.floating = false,
  });

  final String? label;

  /// Tint for the fill, border and content. Null → neutral elevated treatment.
  final Color? color;

  final IconData? icon;

  /// Custom leading widget (e.g. a [SapieCoin]); takes precedence over [icon].
  final Widget? leading;

  /// Optional trailing widget (e.g. a chevron).
  final Widget? trailing;

  /// Overrides the content color when the tint shouldn't drive the text/icon.
  final Color? textColor;

  final SrPillSize size;

  /// Hovering control style: translucent elevated fill + drop shadow.
  final bool floating;

  @override
  Widget build(BuildContext context) {
    final dense = size == SrPillSize.small;
    final tint = color;
    final content = textColor ?? tint ?? context.srTextMuted;
    final bg = floating
        ? context.srBgElev.withAlpha(220)
        : tint?.withAlpha(0x1f) ?? context.srBgElev;
    final border = floating
        ? context.srLine
        : tint?.withAlpha(0x55) ?? context.srLineStrong;

    final hPad = dense ? 10.0 : 12.0;
    final vPad = dense ? 4.0 : 6.0;
    final fontSize = dense ? 11.0 : 13.0;
    final iconSize = dense ? 13.0 : 16.0;
    final gap = dense ? 5.0 : 6.0;

    final lead = leading ?? (icon != null ? Icon(icon, size: iconSize, color: content) : null);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: border),
        boxShadow: floating
            ? [
                BoxShadow(
                  color: context.srShadow,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?lead,
          if (lead != null && label != null) SizedBox(width: gap),
          if (label != null)
            Text(
              label!,
              style: GoogleFonts.jetBrainsMono(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: content,
              ),
            ),
          if (trailing != null) SizedBox(width: gap),
          ?trailing,
        ],
      ),
    );
  }
}

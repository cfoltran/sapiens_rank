import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';

class SrBottomSheet extends StatelessWidget {
  const SrBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 36),
  });

  final Widget child;
  final String? title;
  final EdgeInsets padding;

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    EdgeInsets padding = const EdgeInsets.fromLTRB(20, 0, 20, 36),
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          SrBottomSheet(title: title, padding: padding, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: context.srBgElev,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: context.srLineStrong)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: context.srLineStrong,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (title != null) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                title!,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.srText,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

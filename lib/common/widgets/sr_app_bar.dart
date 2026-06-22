import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';

class SrAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SrAppBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.srBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.srText),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        title,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          color: context.srTextDim,
          letterSpacing: 11 * 0.15,
        ),
      ),
    );
  }
}

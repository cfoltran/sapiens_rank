import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Arena text scale — Space Grotesk + JetBrains Mono.
///
/// Slot mapping:
///   displayLarge   44 w700 italic h:1.05 ls:-0.04em  big hero headings
///   displayMedium  40 w700 italic h:1.02 ls:-0.04em  section hero headings
///   headlineLarge  32 w700 italic h:1.1  ls:-0.04em
///   headlineMedium 28 w700 italic h:1.0  ls:-0.04em
///   titleLarge     22 w700 italic h:1.0  ls:-0.02em
///   titleMedium    20 w700
///   titleSmall     18 w700
///   bodyLarge      16        h:1.5
///   bodyMedium     14        h:1.5
///   bodySmall      12        h:1.4
///   labelLarge     15 w700                            button labels
///   labelMedium    11 w600 JetBrainsMono ls:0.18em   eyebrow / tags
///   labelSmall     10 w600 JetBrainsMono              small mono
abstract final class SrTextStyles {
  static TextTheme get textTheme => TextTheme(
    displayLarge: GoogleFonts.spaceGrotesk(
      fontSize: 44,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      height: 1.05,
      letterSpacing: 44 * -0.04,
    ),
    displayMedium: GoogleFonts.spaceGrotesk(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      height: 1.02,
      letterSpacing: 40 * -0.04,
    ),
    headlineLarge: GoogleFonts.spaceGrotesk(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      height: 1.1,
      letterSpacing: 32 * -0.04,
    ),
    headlineMedium: GoogleFonts.spaceGrotesk(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      height: 1.0,
      letterSpacing: 28 * -0.04,
    ),
    titleLarge: GoogleFonts.spaceGrotesk(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      height: 1.0,
      letterSpacing: 22 * -0.02,
    ),
    titleMedium: GoogleFonts.spaceGrotesk(
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
    titleSmall: GoogleFonts.spaceGrotesk(
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
    bodyLarge: GoogleFonts.spaceGrotesk(
      fontSize: 16,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.spaceGrotesk(
      fontSize: 14,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.spaceGrotesk(
      fontSize: 12,
      height: 1.4,
    ),
    labelLarge: GoogleFonts.spaceGrotesk(
      fontSize: 15,
      fontWeight: FontWeight.w700,
    ),
    labelMedium: GoogleFonts.jetBrainsMono(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 11 * 0.18,
    ),
    labelSmall: GoogleFonts.jetBrainsMono(
      fontSize: 10,
      fontWeight: FontWeight.w600,
    ),
  );
}

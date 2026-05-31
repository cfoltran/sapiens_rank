import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_text_styles.dart';

class DkTheme {
  static ThemeData dark() => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: SrColors.bg,
    textTheme: SrTextStyles.textTheme,
    colorScheme: const ColorScheme.dark(
      primary: SrColors.lime,
      secondary: SrColors.amber,
      surface: SrColors.bgElev,
      error: SrColors.error,
      onPrimary: SrColors.textInk,
      onSecondary: SrColors.textInk,
      onSurface: SrColors.text,
      onError: SrColors.text,
    ),
  );

  static ThemeData light() => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: SrColors.bgLight,
    textTheme: SrTextStyles.textTheme.apply(
      bodyColor: SrColors.textLight,
      displayColor: SrColors.textLight,
    ),
    colorScheme: const ColorScheme.light(
      primary: SrColors.limeLight,
      secondary: SrColors.amberLight,
      surface: SrColors.surfaceLight,
      surfaceContainerHighest: SrColors.surfaceLightElev,
      error: SrColors.roseLight,
      onPrimary: SrColors.textLight,
      onSecondary: SrColors.textLight,
      onSurface: SrColors.textLight,
      onError: SrColors.text,
      outline: SrColors.lineLight,
      outlineVariant: SrColors.lineStrongLight,
      shadow: SrColors.shadowLight,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: SrColors.surfaceLightElev,
    ),
    dividerColor: SrColors.lineLight,
  );
}

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
        textTheme: SrTextStyles.textTheme,
        colorScheme: const ColorScheme.light(
          primary: SrColors.lime,
          secondary: SrColors.amber,
          surface: SrColors.surfaceLight,
          error: SrColors.error,
          onPrimary: SrColors.textInk,
          onSecondary: SrColors.textInk,
          onSurface: SrColors.textInk,
          onError: SrColors.text,
        ),
      );
}

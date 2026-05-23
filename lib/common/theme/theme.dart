import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';

class DkTheme {
  static ThemeData light() {
    final colorScheme = SrLightColors();
    return ThemeData.from(
      colorScheme: ColorScheme(
        primary: colorScheme.primary500,
        secondary: colorScheme.secondary,
        surface: colorScheme.background,
        error: colorScheme.error500,
        onPrimary: colorScheme.textWhite,
        onSecondary: colorScheme.onSecondary,
        onSurface: colorScheme.onSurface,
        onError: colorScheme.textWhite,
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = SrDarkColors();
    return ThemeData.from(
      colorScheme: ColorScheme(
        primary: colorScheme.primary500,
        secondary: colorScheme.secondary,
        surface: colorScheme.background,
        error: colorScheme.error500,
        onPrimary: colorScheme.textWhite,
        onSecondary: colorScheme.onSecondary,
        onSurface: colorScheme.onSurface,
        onError: colorScheme.textWhite,
        brightness: Brightness.dark,
      ),
    );
  }
}

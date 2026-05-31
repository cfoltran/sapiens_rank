import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';

extension SrTheme on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get srBg => isDark ? SrColors.bg : SrColors.bgLight;
  Color get srBgElev => isDark ? SrColors.bgElev : SrColors.surfaceLight;
  Color get srBgElev2 => isDark ? SrColors.bgElev2 : SrColors.surfaceLightElev;

  Color get srText => isDark ? SrColors.text : SrColors.textLight;
  Color get srTextMuted =>
      isDark ? SrColors.textMuted : SrColors.textLightMuted;
  Color get srTextDim => isDark ? SrColors.textDim : SrColors.textLightDim;

  Color get srLine => isDark ? SrColors.line : SrColors.lineLight;
  Color get srLineStrong =>
      isDark ? SrColors.lineStrong : SrColors.lineStrongLight;

  Color get srTintXxs => isDark ? SrColors.tintXxs : SrColors.tintXxsDark;
  Color get srTintXs => isDark ? SrColors.tintXs : SrColors.tintXsDark;
  Color get srTintSm => isDark ? SrColors.tintSm : SrColors.tintSmDark;
  Color get srTintMd => isDark ? SrColors.tintMd : SrColors.tintMdDark;
  Color get srTintLg => isDark ? SrColors.tintLg : SrColors.tintLgDark;

  Color get srNavBg => isDark ? SrColors.navBg : SrColors.navBgLight;
  Color get srShadow => isDark ? SrColors.shadow : SrColors.shadowLight;
  Color get srBgElev2Fade =>
      isDark ? SrColors.bgElev2Fade : SrColors.bgElev2FadeLight;
  Color get srBgElev2Opaque =>
      isDark ? SrColors.bgElev2Opaque : SrColors.bgElev2OpaqueLight;

  /// Lime for text/icons on a surface background — bright in dark, deep in light.
  Color get srLimeText => isDark ? SrColors.lime : SrColors.limeDeep;

  /// Track color for rings/progress bars.
  Color get srTrack => isDark ? SrColors.tintSm : SrColors.tintSmDark;

  /// Tick/divider color.
  Color get srTick =>
      isDark ? Colors.white.withAlpha(38) : Colors.black.withAlpha(25);
}

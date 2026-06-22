import 'package:flutter/material.dart';

abstract final class SrColors {
  // Dark backgrounds
  static const bg = Color(0xFF15130F);
  static const bgElev = Color(0xFF1D1A14);
  static const bgElev2 = Color(0xFF26221A);

  // Light backgrounds — neutral grey-white base, white cards
  static const bgLight = Color(0xFFF3F3F1);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceLightElev = Color(0xFFFFFFFF);

  // Text — dark mode
  static const text = Color(0xFFF5F1E8);
  static const textMuted = Color(0x9EF5F1E8);
  static const textDim = Color(0x61F5F1E8);
  static const textInk = Color(0xFF15130F);

  // Text — light mode (warm ink #16140F)
  static const textLight = Color(0xFF16140F);
  static const textLightMuted = Color(0x8C16140F);
  static const textLightDim = Color(0x6116140F);

  // Lines — dark mode
  static const line = Color(0x12FFFFFF);
  static const lineStrong = Color(0x24FFFFFF);

  // Lines — light mode (warm ink base)
  static const lineLight = Color(0x1216140F);
  static const lineStrongLight = Color(0x1F16140F);

  // Tints — dark mode (white over dark)
  static const tintXxs = Color(0x05FFFFFF);
  static const tintXs = Color(0x08FFFFFF);
  static const tintSm = Color(0x0DFFFFFF);
  static const tintMd = Color(0x14FFFFFF);
  static const tintLg = Color(0x1FFFFFFF);

  // Tints — light mode (warm ink over light)
  static const tintXxsDark = Color(0x0316140F);
  static const tintXsDark = Color(0x0816140F);
  static const tintSmDark = Color(0x0D16140F);
  static const tintMdDark = Color(0x1416140F);
  static const tintLgDark = Color(0x2416140F);

  // Nav / shadow
  static const navBg = Color(0x991D1A14);
  static const navBgLight = Color(0xAAFFFFFF);
  static const shadow = Color(0x80000000);
  static const shadowLight = Color(0x1A000000);
  static const bgElev2Fade = Color(0xD926221A);
  static const bgElev2Opaque = Color(0xFA26221A);
  static const bgElev2FadeLight = Color(0xD9FFFFFF);
  static const bgElev2OpaqueLight = Color(0xFAFFFFFF);

  // Lime — dark mode
  static const lime = Color(0xFFD9FF3D);
  static const limeDeep = Color(0xFFA7D80A);

  // Lime — light mode
  static const limeLight = Color(0xFFC6F527); // fills, rings, progress bars
  static const limeLightText = Color(0xFF557A00); // text/icons on light
  static const limeLightDeep = Color(0xFF3F5400); // deepest green

  // Lime tints (dark mode)
  static const limeSubtle = Color(0x14D9FF3D);
  static const limeFaint = Color(0x1AD9FF3D);
  static const limeBorder = Color(0x40D9FF3D);
  static const limeBorderStrong = Color(0x66D9FF3D);

  // Amber
  static const amber = Color(0xFFF0A64A);
  static const amberLight = Color(0xFFE8902F);

  // Sapie coin — warm brass gold, distinct from amber
  static const coin = Color(0xFFE0A72E);
  static const coinLight = Color(0xFFF4CF6A);
  static const coinDeep = Color(0xFFA9741A);

  // Rose
  static const rose = Color(0xFFFF6B7A);
  static const roseLight = Color(0xFFE0414F);

  // Blue
  static const blue = Color(0xFF7CB6FF);
  static const blueLight = Color(0xFF2F6FD6);

  // Magenta
  static const magenta = Color(0xFFFF4D97);
  static const magentaSubtle = Color(0x14FF4D97);
  static const magentaFaint = Color(0x1AFF4D97);
  static const magentaBorder = Color(0x44FF4D97);
  static const magentaGlow = Color(0x22FF4D97);

  // Cyan
  static const cyan = Color(0xFF5CE1FF);
  static const cyanSubtle = Color(0x0D5CE1FF);
  static const cyanBorder = Color(0x335CE1FF);

  // Podium
  static const silver = Color(0xFFE0D5B8);
  static const silverLight = Color(0xFFA89A7C);
  static const bronze = Color(0xFFC47A1F);

  // Status
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFFF6B7A);

  // Misc palette colors (avatar, etc.)
  static const blueDeep = Color(0xFF4A7EAF);
  static const violet = Color(0xFFC5A3FF);
  static const mint = Color(0xFF9BE7C4);
  static const gold = Color(0xFFFFB84A);
  static const ice = Color(0xFF7CE5FF);
  static const coral = Color(0xFFFF9B7A);
  static const lavender = Color(0xFFB5A8FF);
  static const yellow = Color(0xFFF5D76E);
  static const pink = Color(0xFFFF7AD9);
  static const sand = Color(0xFFE0D5B8);

  static const List<Color> avatarPalette = [
    rose,
    blue,
    amber,
    violet,
    mint,
    gold,
    ice,
    coral,
    lime,
    lavender,
    yellow,
    pink,
  ];
}

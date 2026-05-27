import 'package:flutter/material.dart';

abstract final class SrColors {
  // Surfaces
  static const bg = Color(0xFF15130F);
  static const bgElev = Color(0xFF1D1A14);
  static const bgElev2 = Color(0xFF26221A);

  // Accents
  static const lime = Color(0xFFD9FF3D);
  static const limeDeep = Color(0xFFA7D80A);
  static const amber = Color(0xFFF0A64A);
  static const rose = Color(0xFFFF6B7A);
  static const magenta = Color(0xFFFF4D97);
  static const cyan = Color(0xFF5CE1FF);

  // Text (on dark)
  static const text = Color(0xFFF5F1E8);
  static const textMuted = Color(0x9EF5F1E8); // 62%
  static const textDim = Color(0x61F5F1E8); // 38%
  static const textInk = Color(0xFF15130F); // on lime

  // Borders
  static const line = Color(0x12FFFFFF); // 7%
  static const lineStrong = Color(0x24FFFFFF); // 14%

  // Status
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFFF6B7A);
}

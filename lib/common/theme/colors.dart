import 'package:flutter/material.dart';

class SrColor extends Color {
  const SrColor._(super.value);
}

abstract class SrColors {
  static SrColors of(BuildContext context) =>
      Theme.of(context).colorScheme.brightness == Brightness.dark
      ? SrDarkColors()
      : SrLightColors();

  SrColor get background;
  SrColor get shadow;

  SrColor get primary50;
  SrColor get primary500;
  SrColor get primary600;

  SrColor get secondary;
  SrColor get outline;

  SrColor get gray25;
  SrColor get gray50;
  SrColor get gray100;
  SrColor get gray200;
  SrColor get gray300;
  SrColor get gray400;
  SrColor get gray500;
  SrColor get gray600;
  SrColor get gray700;
  SrColor get gray800;
  SrColor get gray950;

  SrColor get white;

  SrColor get text;
  SrColor get textWhite;
  SrColor get textDark;

  SrColor get success50;
  SrColor get success300;
  SrColor get success500;
  SrColor get success600;
  SrColor get success700;

  SrColor get warning;
  SrColor get warning600;

  SrColor get error500;

  SrColor get onSecondary;
  SrColor get onSurface;
}

class SrLightColors extends SrColors {
  @override
  SrColor get background => const SrColor._(0xFFFCFCFD);
  @override
  SrColor get shadow => const SrColor._(0x1A000000);

  @override
  SrColor get primary50 => const SrColor._(0xFFF5F3FF);
  @override
  SrColor get primary500 => const SrColor._(0xFF8B5CF6);
  @override
  SrColor get primary600 => const SrColor._(0xFF7C3AED);

  @override
  SrColor get secondary => const SrColor._(0xFFEC4899);
  @override
  SrColor get outline => const SrColor._(0xFFE5E7EB);

  @override
  SrColor get white => const SrColor._(0xFFFFFFFF);

  @override
  SrColor get text => const SrColor._(0xFF1A1A1A);
  @override
  SrColor get textWhite => const SrColor._(0xFFFFFFFF);
  @override
  SrColor get textDark => const SrColor._(0xFF37474F);

  @override
  SrColor get success50 => const SrColor._(0xFFECFDF5);
  @override
  SrColor get success300 => const SrColor._(0xFF86EFAC);
  @override
  SrColor get success500 => const SrColor._(0xFF10B981);
  @override
  SrColor get success600 => const SrColor._(0xFF059669);
  @override
  SrColor get success700 => const SrColor._(0xFF047857);

  @override
  SrColor get warning => const SrColor._(0xFFFEF3C7);
  @override
  SrColor get warning600 => const SrColor._(0xFFF59E0B);

  @override
  SrColor get error500 => const SrColor._(0xFFEF4444);

  @override
  SrColor get onSecondary => const SrColor._(0xFFFFFFFF);
  @override
  SrColor get onSurface => const SrColor._(0xFF212121);

  @override
  SrColor get gray25 => const SrColor._(0xFFF9FAFB);
  @override
  SrColor get gray50 => const SrColor._(0xFFF3F4F6);
  @override
  SrColor get gray100 => const SrColor._(0xFFE5E7EB);
  @override
  SrColor get gray200 => const SrColor._(0xFFD1D5DB);
  @override
  SrColor get gray300 => const SrColor._(0xFF9CA3AF);
  @override
  SrColor get gray400 => const SrColor._(0xFF6B7280);
  @override
  SrColor get gray500 => const SrColor._(0xFF4B5563);
  @override
  SrColor get gray600 => const SrColor._(0xFF374151);
  @override
  SrColor get gray700 => const SrColor._(0xFF1F2937);
  @override
  SrColor get gray800 => const SrColor._(0xFF111827);
  @override
  SrColor get gray950 => const SrColor._(0xFF0B0E11);
}

class SrDarkColors extends SrColors {
  @override
  SrColor get background => const SrColor._(0xFF0C0A0F);
  @override
  SrColor get shadow => const SrColor._(0x33000000);

  @override
  SrColor get primary50 => const SrColor._(0xFF2E1065);
  @override
  SrColor get primary500 => const SrColor._(0xFF8B5CF6);
  @override
  SrColor get primary600 => const SrColor._(0xFF7C3AED);

  @override
  SrColor get secondary => const SrColor._(0xFFF472B6);
  @override
  SrColor get outline => const SrColor._(0xFF374151);

  @override
  SrColor get white => const SrColor._(0xFF1A1625);

  @override
  SrColor get text => const SrColor._(0xFFF8FAFC);
  @override
  SrColor get textWhite => const SrColor._(0xFF000000);
  @override
  SrColor get textDark => const SrColor._(0xFF94A3B8);

  @override
  SrColor get success50 => const SrColor._(0xFF022C22);
  @override
  SrColor get success300 => const SrColor._(0xFF34D399);
  @override
  SrColor get success500 => const SrColor._(0xFF10B981);
  @override
  SrColor get success600 => const SrColor._(0xFF059669);
  @override
  SrColor get success700 => const SrColor._(0xFF047857);

  @override
  SrColor get warning => const SrColor._(0xFF451A03);
  @override
  SrColor get warning600 => const SrColor._(0xFFF59E0B);

  @override
  SrColor get error500 => const SrColor._(0xFFF87171);

  @override
  SrColor get onSecondary => const SrColor._(0xFF000000);
  @override
  SrColor get onSurface => const SrColor._(0xFFE0E0E0);

  @override
  SrColor get gray25 => const SrColor._(0xFF1A1C1E);
  @override
  SrColor get gray50 => const SrColor._(0xFF2F3133);
  @override
  SrColor get gray100 => const SrColor._(0xFF46484A);
  @override
  SrColor get gray200 => const SrColor._(0xFF5F6164);
  @override
  SrColor get gray300 => const SrColor._(0xFF7C7E81);
  @override
  SrColor get gray400 => const SrColor._(0xFF97999C);
  @override
  SrColor get gray500 => const SrColor._(0xFFB3B5B9);
  @override
  SrColor get gray600 => const SrColor._(0xFFD1D3D7);
  @override
  SrColor get gray700 => const SrColor._(0xFFE1E3E6);
  @override
  SrColor get gray800 => const SrColor._(0xFFF0F2F5);
  @override
  SrColor get gray950 => const SrColor._(0xFFF7F9FA);
}

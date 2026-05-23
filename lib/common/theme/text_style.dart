import 'package:flutter/material.dart';

class DkTextStyle extends TextStyle {
  const DkTextStyle._({
    required double fontSize,
    required FontWeight weight,
    double? lineHeight,
    double? letter,
  }) : super(fontFamily: _familyName, fontWeight: weight, fontSize: fontSize);

  static const _familyName = 'Inter';

  static const _weightRegular = FontWeight.w400;
  static const _weightMedium = FontWeight.w500;
  static const _weightSemiBold = FontWeight.w600;
  static const _weightBold = FontWeight.w700;

  static const header1 = DkTextStyle._(
    fontSize: 48,
    lineHeight: 48,
    weight: _weightRegular,
    letter: 0.02,
  );

  static const header1Medium = DkTextStyle._(
    fontSize: 48,
    lineHeight: 48,
    weight: _weightMedium,
    letter: 0.02,
  );

  static const header1SemiBold = DkTextStyle._(
    fontSize: 48,
    lineHeight: 48,
    weight: _weightSemiBold,
    letter: 0.02,
  );

  static const header1Bold = DkTextStyle._(
    fontSize: 48,
    lineHeight: 48,
    weight: _weightBold,
    letter: 0.02,
  );

  static const header2 = DkTextStyle._(
    fontSize: 32,
    lineHeight: 32,
    weight: _weightBold,
    letter: 0.02,
  );

  static const header2Medium = DkTextStyle._(
    fontSize: 32,
    lineHeight: 32,
    weight: _weightBold,
    letter: 0.02,
  );

  static const header2Bold = DkTextStyle._(
    fontSize: 32,
    lineHeight: 32,
    weight: _weightBold,
    letter: 0.02,
  );

  static const header3 = DkTextStyle._(
    fontSize: 24,
    lineHeight: 24,
    weight: _weightRegular,
    letter: 0.02,
  );

  static const header3Medium = DkTextStyle._(
    fontSize: 24,
    lineHeight: 24,
    weight: _weightMedium,
    letter: 0.02,
  );

  static const header3SemiBold = DkTextStyle._(
    fontSize: 24,
    lineHeight: 24,
    weight: _weightSemiBold,
    letter: 0.02,
  );

  static const header4SemiBold = DkTextStyle._(
    fontSize: 20,
    lineHeight: 24,
    weight: _weightSemiBold,
    letter: 0.02,
  );

  static const header4Medium = DkTextStyle._(
    fontSize: 20,
    lineHeight: 24,
    weight: _weightMedium,
    letter: 0.02,
  );

  static const large = DkTextStyle._(
    fontSize: 18,
    lineHeight: 24,
    weight: _weightRegular,
    letter: 0.02,
  );

  static const largeSemiBold = DkTextStyle._(
    fontSize: 18,
    lineHeight: 24,
    weight: _weightSemiBold,
    letter: 0.02,
  );

  static const largeBold = DkTextStyle._(
    fontSize: 18,
    lineHeight: 24,
    weight: _weightBold,
    letter: 0.02,
  );

  static const paragraph = DkTextStyle._(
    fontSize: 16,
    lineHeight: 24,
    weight: _weightRegular,
    letter: 0.02,
  );

  static const paragraphMedium = DkTextStyle._(
    fontSize: 16,
    lineHeight: 24,
    weight: _weightMedium,
    letter: 0.02,
  );

  static const paragraphBold = DkTextStyle._(
    fontSize: 16,
    lineHeight: 24,
    weight: _weightBold,
    letter: 0.02,
  );

  static const subtitle = DkTextStyle._(
    fontSize: 12,
    lineHeight: 16,
    weight: _weightRegular,
    letter: 0.02,
  );

  static const subtitleSemiBold = DkTextStyle._(
    fontSize: 12,
    lineHeight: 16,
    weight: _weightSemiBold,
    letter: 0.02,
  );

  static const subtitleMedium = DkTextStyle._(
    fontSize: 12,
    lineHeight: 16,
    weight: _weightMedium,
    letter: 0.02,
  );

  static const smallSemiBold = DkTextStyle._(
    fontSize: 14,
    lineHeight: 24,
    weight: _weightSemiBold,
    letter: 0.02,
  );

  static const smallBold = DkTextStyle._(
    fontSize: 14,
    lineHeight: 24,
    weight: _weightBold,
    letter: 0.02,
  );

  static const small = DkTextStyle._(
    fontSize: 14,
    lineHeight: 24,
    weight: _weightRegular,
    letter: 0.02,
  );
}

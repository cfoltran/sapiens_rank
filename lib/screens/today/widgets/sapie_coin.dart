import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/common/widgets/sr_pill.dart';

/// A single Sapie coin — a gold piece struck with the logo α.
class SapieCoin extends StatelessWidget {
  const SapieCoin({super.key, this.size = 16});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: Alignment(-0.3, -0.44),
          radius: 0.95,
          colors: [
            Color(0xFFFFE9A8),
            Color(0xFFF1C14E),
            Color(0xFFCF9626),
            Color(0xFFA9741A),
          ],
          stops: [0.0, 0.4, 0.74, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x59462E08),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Transform.translate(
        offset: Offset(-size * 0.02, -size * 0.05),
        child: Text(
          'α',
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSerif(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.6,
            height: 1.0,
            color: const Color(0xFF7C5512),
          ),
        ),
      ),
    );
  }
}

/// Header pill showing the user's Sapie balance. Bumps on collect.
class WalletPill extends StatelessWidget {
  const WalletPill({
    super.key,
    required this.balance,
    this.bump = false,
    this.onTap,
  });

  final int balance;
  final bool bump;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: bump ? 1.18 : 1.0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutBack,
        child: SrPill(
          label: _formatBalance(balance),
          color: SrColors.coin,
          textColor: context.isDark ? SrColors.coinLight : SrColors.coinDeep,
          leading: const SapieCoin(size: 18),
        ),
      ),
    );
  }

  static String _formatBalance(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

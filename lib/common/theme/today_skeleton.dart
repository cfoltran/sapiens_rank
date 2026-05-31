import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/skeleton.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';

class TodayLoadingSkeleton extends StatelessWidget {
  const TodayLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom + 96.0;
    return Scaffold(
      backgroundColor: context.srBg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(18, 4, 18, bottomPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const SrSkeleton(width: 36, height: 14, borderRadius: 4),
                  const SizedBox(width: 8),
                  const SrSkeleton(width: 72, height: 14, borderRadius: 4),
                  const Spacer(),
                  SrSkeleton(width: 64, height: 26, borderRadius: 13),
                ],
              ),
              const SizedBox(height: 16),
              const Center(
                child: SrSkeleton(width: 220, height: 220, borderRadius: 110),
              ),
              const SizedBox(height: 10),
              const Center(
                child: SrSkeleton(width: 96, height: 18, borderRadius: 9),
              ),
              const SizedBox(height: 20),
              const SrSkeleton(height: 82, borderRadius: 16),
              const SizedBox(height: 8),
              for (int i = 0; i < 5; i++) ...[
                const SrSkeleton(height: 64, borderRadius: 14),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

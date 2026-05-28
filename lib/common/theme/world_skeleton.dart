import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/skeleton.dart';

class WorldLoadingSkeleton extends StatelessWidget {
  const WorldLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom + 96.0;
    return Scaffold(
      backgroundColor: SrColors.bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(18, 12, 18, bottomPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header skeleton
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SrSkeleton(width: 120, height: 10, borderRadius: 4),
                        SizedBox(height: 6),
                        SrSkeleton(width: 80, height: 28, borderRadius: 6),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      SrSkeleton(width: 88, height: 12, borderRadius: 4),
                      SizedBox(height: 4),
                      SrSkeleton(width: 72, height: 10, borderRadius: 4),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Filter chips skeleton
              Row(
                children: [
                  const SrSkeleton(width: 90, height: 32, borderRadius: 16),
                  const SizedBox(width: 8),
                  const SrSkeleton(width: 60, height: 32, borderRadius: 16),
                  const SizedBox(width: 8),
                  const SrSkeleton(width: 72, height: 32, borderRadius: 16),
                ],
              ),
              const SizedBox(height: 24),
              // Podium skeleton — three blocks aligned at bottom
              SizedBox(
                height: 200,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          SrSkeleton(width: 50, height: 50, borderRadius: 25),
                          SizedBox(height: 8),
                          SrSkeleton(height: 100, borderRadius: 14),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          SrSkeleton(width: 60, height: 60, borderRadius: 30),
                          SizedBox(height: 8),
                          SrSkeleton(height: 130, borderRadius: 14),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          SrSkeleton(width: 50, height: 50, borderRadius: 25),
                          SizedBox(height: 8),
                          SrSkeleton(height: 86, borderRadius: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Section labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  SrSkeleton(width: 36, height: 10, borderRadius: 4),
                  SrSkeleton(width: 40, height: 10, borderRadius: 4),
                ],
              ),
              const SizedBox(height: 10),
              // Row skeletons
              for (int i = 0; i < 8; i++) ...[
                Row(
                  children: const [
                    SrSkeleton(width: 28, height: 14, borderRadius: 4),
                    SizedBox(width: 10),
                    SrSkeleton(width: 36, height: 36, borderRadius: 18),
                    SizedBox(width: 12),
                    Expanded(child: SrSkeleton(height: 14, borderRadius: 4)),
                    SizedBox(width: 12),
                    SrSkeleton(width: 44, height: 18, borderRadius: 4),
                  ],
                ),
                const SizedBox(height: 14),
              ],
              // You card skeleton
              const SizedBox(height: 8),
              const SrSkeleton(height: 70, borderRadius: 18),
            ],
          ),
        ),
      ),
    );
  }
}

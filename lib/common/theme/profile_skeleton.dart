import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/skeleton.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/common/widgets/sr_app_bar.dart';

class ProfileLoadingSkeleton extends StatelessWidget {
  const ProfileLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom + 96.0;
    return Scaffold(
      backgroundColor: context.srBg,
      appBar: const SrAppBar(title: 'PROFILE'),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(18, 4, 18, bottomPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Identity card
              Row(
                children: const [
                  SrSkeleton(width: 68, height: 68, borderRadius: 34),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SrSkeleton(width: 140, height: 22, borderRadius: 6),
                        SizedBox(height: 8),
                        SrSkeleton(width: 100, height: 12, borderRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const SrSkeleton(height: 40, borderRadius: 8),
              const SizedBox(height: 18),
              const SrSkeleton(height: 180, borderRadius: 22),
              const SizedBox(height: 18),
              const SrSkeleton(height: 280, borderRadius: 22),
              const SizedBox(height: 18),
              const SrSkeleton(height: 140, borderRadius: 22),
              const SizedBox(height: 18),
              const SrSkeleton(height: 56, borderRadius: 16),
            ],
          ),
        ),
      ),
    );
  }
}

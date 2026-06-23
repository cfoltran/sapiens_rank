import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/skeleton.dart';

class ChallengeLoadingSkeleton extends StatelessWidget {
  const ChallengeLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
      children: [
        for (int i = 0; i < 3; i++) ...[
          const SrSkeleton(height: 220, borderRadius: 18),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

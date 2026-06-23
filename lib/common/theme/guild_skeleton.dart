import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/skeleton.dart';

class GuildLoadingSkeleton extends StatelessWidget {
  const GuildLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom + 16;
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(18, 0, 18, bottomPad),
      children: [
        const SrSkeleton(height: 94, borderRadius: 20),
        const SizedBox(height: 18),
        const SrSkeleton(height: 220, borderRadius: 16),
        const SizedBox(height: 18),
        const SrSkeleton(height: 160, borderRadius: 16),
      ],
    );
  }
}

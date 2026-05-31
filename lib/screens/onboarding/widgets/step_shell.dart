import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';

class StepShell extends StatelessWidget {
  const StepShell({
    super.key,
    required this.progress,
    required this.total,
    required this.body,
    this.footer,
  });

  final int progress;
  final int total;
  final Widget body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.srBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StepProgressDots(progress: progress, total: total),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 16),
                child: body,
              ),
            ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}

class StepProgressDots extends StatelessWidget {
  const StepProgressDots({
    super.key,
    required this.progress,
    required this.total,
  });

  final int progress;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: Row(
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: _Dot(index: i, progress: progress),
            ),
          ],
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.index, required this.progress});

  final int index;
  final int progress;

  @override
  Widget build(BuildContext context) {
    final isActive = index == progress;
    final isLit = index <= progress;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: isLit ? context.srLime : context.srTintXs,
        boxShadow: isActive
            ? [BoxShadow(color: context.srLime.withAlpha(136), blurRadius: 8)]
            : null,
      ),
    );
  }
}

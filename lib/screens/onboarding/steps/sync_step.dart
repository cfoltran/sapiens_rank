import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/arena_button.dart';
import 'package:sapiens_rank/services/health_service.dart';

class SyncStep extends StatefulWidget {
  const SyncStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  State<SyncStep> createState() => _SyncStepState();
}

class _SyncStepState extends State<SyncStep>
    with SingleTickerProviderStateMixin {
  List<({String label, String value, String icon})> _metrics = [];

  late final AnimationController _pulseCtrl;
  int _revealed = 0;
  bool _done = false;
  final List<Timer> _timers = [];

  void _startReveal(int count) {
    for (var i = 0; i < count; i++) {
      _timers.add(
        Timer(Duration(milliseconds: 400 + i * 350), () {
          if (mounted) setState(() => _revealed = i + 1);
        }),
      );
    }
    _timers.add(
      Timer(Duration(milliseconds: 400 + count * 350 + 400), () {
        if (mounted) setState(() => _done = true);
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    HealthService.instance.fetchSyncMetrics().then((metrics) {
      if (!mounted) return;
      setState(() => _metrics = metrics);
      _startReveal(metrics.length);
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SrColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 32, 22, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PulseRing(controller: _pulseCtrl, done: _done),
              const SizedBox(height: 32),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _done
                    ? _DoneHeadline(key: const ValueKey('done'))
                    : _LoadingHeadline(key: const ValueKey('loading')),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: _MetricList(metrics: _metrics, revealed: _revealed),
              ),
              AnimatedOpacity(
                opacity: _done ? 1 : 0,
                duration: const Duration(milliseconds: 400),
                child: IgnorePointer(
                  ignoring: !_done,
                  child: ArenaButton(
                    label: 'See my score →',
                    onTap: widget.onNext,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  const _PulseRing({required this.controller, required this.done});

  final AnimationController controller;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final t = controller.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? SrColors.lime.withAlpha(30)
                      : SrColors.cyan.withAlpha((12 + (t * 20).round())),
                  border: Border.all(
                    color: done
                        ? SrColors.lime.withAlpha(180)
                        : SrColors.cyan.withAlpha((80 + (t * 120).round())),
                    width: 1.5,
                  ),
                ),
              ),
              done
                  ? const Icon(
                      Icons.check_rounded,
                      color: SrColors.lime,
                      size: 28,
                    )
                  : SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: SrColors.cyan.withAlpha(
                          (160 + (t * 95).round()),
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}

class _LoadingHeadline extends StatelessWidget {
  const _LoadingHeadline({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'READING YOUR DATA',
          style: tt.labelSmall!.copyWith(
            color: SrColors.cyan,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pulling your\nhealth history.',
          style: tt.headlineLarge!.copyWith(
            fontSize: 36,
            height: 1.05,
            color: SrColors.text,
          ),
        ),
      ],
    );
  }
}

class _DoneHeadline extends StatelessWidget {
  const _DoneHeadline({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ALL SYSTEMS GO',
          style: tt.labelSmall!.copyWith(
            color: SrColors.lime,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: tt.headlineLarge!.copyWith(
              fontSize: 36,
              height: 1.05,
              color: SrColors.text,
            ),
            children: const [
              TextSpan(text: 'Data locked\nin. '),
              TextSpan(
                text: "Let's rank.",
                style: TextStyle(color: SrColors.lime),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricList extends StatelessWidget {
  const _MetricList({required this.metrics, required this.revealed});

  final List<({String label, String value, String icon})> metrics;
  final int revealed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < metrics.length; i++)
          _MetricRow(
            item: metrics[i],
            visible: i < revealed,
            isLast: i == metrics.length - 1,
          ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.item,
    required this.visible,
    required this.isLast,
  });

  final ({String label, String value, String icon}) item;
  final bool visible;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 350),
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 0.15),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Text(item.icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      style: tt.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: SrColors.textMuted,
                      ),
                    ),
                  ),
                  Text(
                    item.value,
                    style: tt.labelMedium!.copyWith(
                      fontSize: 13,
                      color: SrColors.text,
                    ),
                  ),
                ],
              ),
            ),
            if (!isLast) const Divider(height: 1, color: Color(0x0DFFFFFF)),
          ],
        ),
      ),
    );
  }
}

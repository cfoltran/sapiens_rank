import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sapiens_rank/common/helpers/guild_visuals.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/common/widgets/sr_bottom_sheet.dart';
import 'package:sapiens_rank/models/guild_models.dart';

class AttackSheet extends StatefulWidget {
  const AttackSheet({
    super.key,
    required this.territory,
    required this.onConfirm,
  });

  final Territory territory;
  final void Function({required AttackMetric metric, required DateTime endsAt})
  onConfirm;

  static Future<void> show(
    BuildContext context, {
    required Territory territory,
    required void Function({
      required AttackMetric metric,
      required DateTime endsAt,
    })
    onConfirm,
  }) {
    return SrBottomSheet.show(
      context: context,
      child: AttackSheet(territory: territory, onConfirm: onConfirm),
    );
  }

  @override
  State<AttackSheet> createState() => _AttackSheetState();
}

class _AttackSheetState extends State<AttackSheet> {
  AttackMetric _metric = AttackMetric.steps;
  bool _buttonPressed = false;

  static final _metrics = AttackMetric.values
      .where((m) => m != AttackMetric.hrv)
      .toList();

  @override
  Widget build(BuildContext context) {
    final owner = widget.territory.guilds?.name;
    final isNeutral = widget.territory.isNeutral;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isNeutral
                        ? 'Claim neutral territory'
                        : 'Attack ${owner ?? 'guild'}',
                    style: TextStyle(
                      color: context.srText,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isNeutral
                        ? 'No defender, territory is yours in 24h.'
                        : 'Your guild\'s total beats their guild\'s total.',
                    style: TextStyle(color: context.srTextMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Text(
                _metric.emoji,
                key: ValueKey(_metric),
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionLabel('METRIC'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _metrics.map((metric) {
            final selected = _metric == metric;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _metric = metric);
              },
              child: AnimatedScale(
                scale: selected ? 1.07 : 1.0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: _SelectableChip(
                  selected: selected,
                  child: Text(
                    '${metric.emoji} ${metric.label}',
                    style: TextStyle(
                      color: selected ? context.srLimeText : context.srText,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        Listener(
          onPointerDown: (_) => setState(() => _buttonPressed = true),
          onPointerUp: (_) => setState(() => _buttonPressed = false),
          onPointerCancel: (_) => setState(() => _buttonPressed = false),
          child: AnimatedScale(
            scale: _buttonPressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                  widget.onConfirm(
                    metric: _metric,
                    endsAt: DateTime.now().add(const Duration(hours: 24)),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: context.srLime,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isNeutral ? 'Claim' : 'Launch attack',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: context.srTextDim,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({required this.selected, required this.child});

  final bool selected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? context.srLime.withAlpha(30) : context.srBgElev2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? context.srLime : context.srLine,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: child,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
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

  @override
  State<AttackSheet> createState() => _AttackSheetState();
}

class _AttackSheetState extends State<AttackSheet> {
  AttackMetric _metric = AttackMetric.steps;
  int _durationHours = 24;
  bool _buttonPressed = false;

  static const _metrics = [
    (AttackMetric.steps, '👟', 'Steps'),
    (AttackMetric.sleep, '😴', 'Sleep'),
    (AttackMetric.calories, '🔥', 'Calories'),
    (AttackMetric.stand, '🧍', 'Stand'),
    (AttackMetric.hrv, '💓', 'HRV'),
  ];

  static const _durations = [24, 48, 72];

  @override
  Widget build(BuildContext context) {
    final owner = widget.territory.guilds?.name;
    final isNeutral = widget.territory.isNeutral;

    return Container(
      decoration: BoxDecoration(
        color: context.srBgElev,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.srLine,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
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
                          ? 'No defender — territory is yours if you post any data.'
                          : 'Your guild\'s total beats their guild\'s total.',
                      style: TextStyle(
                        color: context.srTextMuted,
                        fontSize: 13,
                      ),
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
                  _metrics.firstWhere((m) => m.$1 == _metric).$2,
                  key: ValueKey(_metric),
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'METRIC',
            style: TextStyle(
              color: context.srTextDim,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _metrics.map((entry) {
              final (metric, icon, label) = entry;
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? context.srLime.withAlpha(30)
                          : context.srBgElev2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? context.srLime : context.srLine,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      '$icon $label',
                      style: TextStyle(
                        color: selected ? context.srLimeText : context.srText,
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'DURATION',
            style: TextStyle(
              color: context.srTextDim,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: _durations.map((h) {
              final selected = _durationHours == h;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _durationHours = h);
                  },
                  child: AnimatedScale(
                    scale: selected ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: EdgeInsets.only(right: h != 72 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? context.srLime.withAlpha(30)
                            : context.srBgElev2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? context.srLime : context.srLine,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        '${h}h',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selected ? context.srLimeText : context.srText,
                          fontSize: 14,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
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
                      endsAt: DateTime.now().add(
                        Duration(hours: _durationHours),
                      ),
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
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/helpers/guild_visuals.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/common/widgets/sr_bottom_sheet.dart';
import 'package:sapiens_rank/models/booster.dart';
import 'package:sapiens_rank/models/guild_models.dart';
import 'package:sapiens_rank/screens/today/widgets/sapie_coin.dart';
import 'package:sapiens_rank/services/sapies_service.dart';

enum _Phase { choosing, spinning }

class AttackSheet extends StatefulWidget {
  const AttackSheet({
    super.key,
    required this.territory,
    required this.onConfirm,
  });

  final Territory territory;
  final void Function({
    required AttackMetric metric,
    required DateTime endsAt,
    BoosterType? booster,
    required bool chooseMetric,
  })
  onConfirm;

  static Future<void> show(
    BuildContext context, {
    required Territory territory,
    required void Function({
      required AttackMetric metric,
      required DateTime endsAt,
      BoosterType? booster,
      required bool chooseMetric,
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
  _Phase _phase = _Phase.choosing;
  BoosterType? _booster;
  bool _chooseMetric = false;
  AttackMetric? _chosenMetric;
  bool _buttonPressed = false;
  int _sapiesBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final wallet = await SapiesService.instance.load();
    if (mounted) setState(() => _sapiesBalance = wallet.balance);
  }

  int get _totalCost =>
      (_booster?.cost ?? 0) + (_chooseMetric ? kChooseMetricCost : 0);

  bool get _canLaunch {
    final ready = !_chooseMetric || _chosenMetric != null;
    return ready && _sapiesBalance >= _totalCost;
  }

  void _launch(AttackMetric metric) {
    Navigator.pop(context);
    widget.onConfirm(
      metric: metric,
      endsAt: DateTime.now().add(const Duration(hours: 24)),
      booster: _booster,
      chooseMetric: _chooseMetric,
    );
  }

  @override
  Widget build(BuildContext context) {
    final owner = widget.territory.guilds?.name;
    final isNeutral = widget.territory.isNeutral;
    final spinning = _phase == _Phase.spinning;

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
                    spinning
                        ? 'Rolling your metric…'
                        : isNeutral
                        ? 'No defender, territory is yours in 24h.'
                        : 'Your guild\'s total beats their guild\'s total.',
                    style: TextStyle(color: context.srTextMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              spinning ? '🎰' : (isNeutral ? '🏳️' : '⚔️'),
              style: const TextStyle(fontSize: 40),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AnimatedSize(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: spinning
              ? _SlotMachine(onSpinComplete: _launch)
              : _ChoosingBody(
                  booster: _booster,
                  chooseMetric: _chooseMetric,
                  chosenMetric: _chosenMetric,
                  sapiesBalance: _sapiesBalance,
                  onMetricModeChanged: (v) => setState(() {
                    _chooseMetric = v;
                    if (!v) _chosenMetric = null;
                  }),
                  onMetricChanged: (m) => setState(() => _chosenMetric = m),
                  onBoosterChanged: (b) => setState(() => _booster = b),
                ),
        ),
        const SizedBox(height: 28),
        AnimatedOpacity(
          opacity: spinning ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: IgnorePointer(
            ignoring: spinning,
            child: Listener(
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
                    onPressed: _canLaunch
                        ? () {
                            HapticFeedback.mediumImpact();
                            if (_chooseMetric) {
                              _launch(_chosenMetric!);
                            } else {
                              setState(() => _phase = _Phase.spinning);
                            }
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: context.srLime,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _totalCost > 0
                          ? '${isNeutral ? 'Claim' : 'Launch attack'} · $_totalCost α'
                          : (isNeutral ? 'Claim' : 'Launch attack'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

class _ChoosingBody extends StatelessWidget {
  const _ChoosingBody({
    required this.booster,
    required this.chooseMetric,
    required this.chosenMetric,
    required this.sapiesBalance,
    required this.onMetricModeChanged,
    required this.onMetricChanged,
    required this.onBoosterChanged,
  });

  final BoosterType? booster;
  final bool chooseMetric;
  final AttackMetric? chosenMetric;
  final int sapiesBalance;
  final void Function(bool) onMetricModeChanged;
  final void Function(AttackMetric) onMetricChanged;
  final void Function(BoosterType?) onBoosterChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('ATTACK METRIC'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _BoosterChip(
              label: '🎲 Random',
              selected: !chooseMetric,
              canAfford: true,
              onTap: () {
                HapticFeedback.selectionClick();
                onMetricModeChanged(false);
              },
            ),
            _BoosterChip(
              label: '🎯 Choose',
              cost: kChooseMetricCost,
              selected: chooseMetric,
              canAfford: sapiesBalance >= kChooseMetricCost,
              onTap: () {
                HapticFeedback.selectionClick();
                onMetricModeChanged(true);
              },
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: chooseMetric
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final m in AttackMetric.values)
                        _MetricChoice(
                          metric: m,
                          selected: chosenMetric == m,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onMetricChanged(m);
                          },
                        ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 20),
        _SectionLabel('BOOST YOUR ATTACK (OPTIONAL)'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _BoosterChip(
              label: 'None',
              selected: booster == null,
              canAfford: true,
              onTap: () {
                HapticFeedback.selectionClick();
                onBoosterChanged(null);
              },
            ),
            for (final type in BoosterType.values)
              _BoosterChip(
                label: '${type.emoji} ${type.displayName}',
                cost: type.cost,
                selected: booster == type,
                canAfford: sapiesBalance >= type.cost,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onBoosterChanged(booster == type ? null : type);
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _MetricChoice extends StatelessWidget {
  const _MetricChoice({
    required this.metric,
    required this.selected,
    required this.onTap,
  });

  final AttackMetric metric;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? context.srLime.withAlpha(28) : context.srBgElev2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? context.srLime : context.srLine,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(metric.emoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 7),
            Text(
              metric.label,
              style: TextStyle(
                color: selected ? context.srLimeText : context.srText,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotMachine extends StatefulWidget {
  const _SlotMachine({required this.onSpinComplete});

  final void Function(AttackMetric) onSpinComplete;

  @override
  State<_SlotMachine> createState() => _SlotMachineState();
}

class _SlotMachineState extends State<_SlotMachine> {
  late final FixedExtentScrollController _ctrl;

  static const _itemH = 64.0;

  int get _metricCount => AttackMetric.values.length;

  @override
  void initState() {
    super.initState();
    _ctrl = FixedExtentScrollController(initialItem: _metricCount * 50);
    WidgetsBinding.instance.addPostFrameCallback((_) => _spin());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _spin() async {
    HapticFeedback.lightImpact();

    final rnd = Random();
    final current = _ctrl.selectedItem;
    final target =
        current +
        _metricCount * (2 + rnd.nextInt(2)) +
        rnd.nextInt(_metricCount);

    await _ctrl.animateToItem(
      target,
      duration: Duration(milliseconds: 1400 + rnd.nextInt(300)),
      curve: Curves.easeOutCubic,
    );

    if (!mounted) return;
    HapticFeedback.heavyImpact();

    final metric = AttackMetric.values[_ctrl.selectedItem % _metricCount];
    widget.onSpinComplete(metric);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _itemH * 3,
      decoration: BoxDecoration(
        color: context.srBgElev2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.srLine),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          ListWheelScrollView.useDelegate(
            controller: _ctrl,
            itemExtent: _itemH,
            perspective: 0.002,
            diameterRatio: 3.0,
            physics: const NeverScrollableScrollPhysics(),
            onSelectedItemChanged: (_) => HapticFeedback.selectionClick(),
            childDelegate: ListWheelChildLoopingListDelegate(
              children: AttackMetric.values
                  .map((m) => _MetricCell(metric: m))
                  .toList(),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _itemH,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [context.srBgElev2, context.srBgElev2.withAlpha(0)],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: _itemH,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [context.srBgElev2, context.srBgElev2.withAlpha(0)],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Container(
                  height: _itemH,
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: context.srLime.withAlpha(90),
                        width: 1.5,
                      ),
                    ),
                    color: context.srLime.withAlpha(12),
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

class _MetricCell extends StatelessWidget {
  const _MetricCell({required this.metric});
  final AttackMetric metric;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(metric.emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 16),
        Text(
          metric.label,
          style: TextStyle(
            color: context.srText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
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

class _BoosterChip extends StatelessWidget {
  const _BoosterChip({
    required this.label,
    required this.selected,
    required this.canAfford,
    required this.onTap,
    this.cost,
  });

  final String label;
  final int? cost;
  final bool selected;
  final bool canAfford;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = canAfford || selected;
    return GestureDetector(
      onTap: canAfford ? onTap : null,
      child: AnimatedScale(
        scale: selected ? 1.07 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? SrColors.coin.withAlpha(28)
                : active
                ? context.srBgElev2
                : context.srBgElev2.withAlpha(120),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? SrColors.coin
                  : active
                  ? context.srLine
                  : context.srLine.withAlpha(60),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? context.isDark
                            ? SrColors.coinLight
                            : SrColors.coinDeep
                      : active
                      ? context.srText
                      : context.srTextDim,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              if (cost != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? SrColors.coin
                        : canAfford
                        ? SrColors.coin.withAlpha(30)
                        : context.srLine.withAlpha(60),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SapieCoin(size: 11),
                      const SizedBox(width: 3),
                      Text(
                        '$cost',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? const Color(0xFF15130F)
                              : canAfford
                              ? context.isDark
                                    ? SrColors.coinLight
                                    : SrColors.coinDeep
                              : context.srTextDim,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

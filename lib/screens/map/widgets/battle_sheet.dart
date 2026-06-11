import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/models/guild_models.dart';

const _metricInfo = {
  AttackMetric.steps: ('👟', 'steps'),
  AttackMetric.sleep: ('😴', 'sleep'),
  AttackMetric.calories: ('🔥', 'calories'),
  AttackMetric.stand: ('🧍', 'stand hours'),
  AttackMetric.hrv: ('💓', 'HRV'),
};

class BattleSheet extends StatefulWidget {
  const BattleSheet({
    super.key,
    required this.attack,
    required this.territory,
    required this.territories,
    required this.myGuildId,
  });

  final Attack attack;
  final Territory territory;
  final List<Territory> territories;
  final String? myGuildId;

  @override
  State<BattleSheet> createState() => _BattleSheetState();
}

class _BattleSheetState extends State<BattleSheet> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(minutes: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  TerritoryGuild? _guildById(String? id) {
    if (id == null) return null;
    for (final t in widget.territories) {
      if (t.guilds?.id == id) return t.guilds;
    }
    return null;
  }

  Color _guildColor(TerritoryGuild? guild, Color fallback) {
    if (guild == null) return fallback;
    return Color(int.parse('FF${guild.color.replaceAll('#', '')}', radix: 16));
  }

  String _formatRemaining(Duration d) {
    if (d.isNegative) return 'Ending…';
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return h > 0 ? '${h}h ${m}m left' : '${m}m left';
  }

  @override
  Widget build(BuildContext context) {
    final attack = widget.attack;
    final (emoji, metricLabel) = _metricInfo[attack.metric]!;
    final attacker = _guildById(attack.attackerGuildId);
    final defender = widget.territory.guilds;
    final attackerColor = _guildColor(attacker, context.srTextMuted);
    final defenderColor = _guildColor(defender, context.srTextMuted);
    final remaining = attack.endsAt.difference(DateTime.now());

    final isMyAttack = widget.myGuildId == attack.attackerGuildId;
    final isMyDefense =
        widget.myGuildId != null && widget.myGuildId == attack.defenderGuildId;

    final a = attack.attackerScore ?? 0;
    final d = attack.defenderScore ?? 0;
    final frac = (a + d) == 0 ? 0.5 : a / (a + d);

    return Container(
      decoration: BoxDecoration(
        color: context.srBgElev,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).padding.bottom + 32,
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
                      'Battle in progress',
                      style: TextStyle(
                        color: context.srText,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Most $metricLabel posted by ${_formatRemaining(remaining).toLowerCase()} wins this territory.',
                      style: TextStyle(
                        color: context.srTextMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(emoji, style: const TextStyle(fontSize: 40)),
            ],
          ),
          if (isMyAttack || isMyDefense) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.srLime.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.srLime),
              ),
              child: Text(
                isMyAttack
                    ? '🗡️ Your guild is attacking — every $metricLabel counts!'
                    : '🛡️ Your guild is defending — hold the line!',
                style: TextStyle(
                  color: context.srLimeText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _GuildLabel(
                  name: attacker?.name ?? 'Attacker',
                  color: attackerColor,
                  score: a,
                  alignEnd: false,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'VS',
                  style: TextStyle(
                    color: context.srTextDim,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Expanded(
                child: _GuildLabel(
                  name: defender?.name ?? 'Unclaimed',
                  color: defenderColor,
                  score: d,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TugOfWarBar(
            fraction: frac,
            attackerColor: attackerColor,
            defenderColor: defenderColor,
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.srBgElev2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.srLine),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: context.srTextMuted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _formatRemaining(remaining),
                    style: TextStyle(
                      color: context.srTextMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuildLabel extends StatelessWidget {
  const _GuildLabel({
    required this.name,
    required this.color,
    required this.score,
    required this.alignEnd,
  });

  final String name;
  final Color color;
  final double score;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!alignEnd) ...[_Dot(color: color), const SizedBox(width: 6)],
            Flexible(
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.srText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (alignEnd) ...[const SizedBox(width: 6), _Dot(color: color)],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          score.round().toString(),
          style: TextStyle(
            color: context.srTextMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _TugOfWarBar extends StatelessWidget {
  const _TugOfWarBar({
    required this.fraction,
    required this.attackerColor,
    required this.defenderColor,
  });

  final double fraction;
  final Color attackerColor;
  final Color defenderColor;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.5, end: fraction.clamp(0.05, 0.95)),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 14,
            child: Row(
              children: [
                Expanded(
                  flex: (value * 1000).round(),
                  child: ColoredBox(color: attackerColor),
                ),
                Container(width: 3, color: context.srBgElev),
                Expanded(
                  flex: ((1 - value) * 1000).round(),
                  child: ColoredBox(color: defenderColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

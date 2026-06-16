import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/helpers/guild_visuals.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/common/widgets/guild_avatar.dart';
import 'package:sapiens_rank/common/widgets/sr_bottom_sheet.dart';
import 'package:sapiens_rank/models/guild_models.dart';

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

  static Future<void> show(
    BuildContext context, {
    required Attack attack,
    required Territory territory,
    required List<Territory> territories,
    required String? myGuildId,
  }) {
    return SrBottomSheet.show(
      context: context,
      child: BattleSheet(
        attack: attack,
        territory: territory,
        territories: territories,
        myGuildId: myGuildId,
      ),
    );
  }

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

  String _formatRemaining(Duration d) {
    if (d.isNegative) return 'Ending…';
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final attack = widget.attack;
    final metricLabel = attack.metric.label;
    final attacker = _guildById(attack.attackerGuildId);
    final defender = widget.territory.guilds;
    final attackerColor = attacker != null
        ? guildColorFromHex(attacker.color)
        : context.srAmber;
    final defenderColor = defender != null
        ? guildColorFromHex(defender.color)
        : context.srTextMuted;
    final remaining = attack.endsAt.difference(DateTime.now());
    final isMyAttack = widget.myGuildId == attack.attackerGuildId;
    final isMyDefense =
        widget.myGuildId != null && widget.myGuildId == attack.defenderGuildId;
    final a = attack.attackerScore ?? 0;
    final d = attack.defenderScore ?? 0;
    final total = a + d;
    final frac = total == 0 ? 0.5 : a / total;
    final lead = total == 0
        ? 0
        : a > d
        ? 1
        : d > a
        ? -1
        : 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MetricHeader(
          emoji: attack.metric.emoji,
          metricLabel: metricLabel,
          remaining: _formatRemaining(remaining),
        ),
        if (isMyAttack || isMyDefense) ...[
          const SizedBox(height: 14),
          _MyGuildBanner(isAttacking: isMyAttack, metricLabel: metricLabel),
        ],
        const SizedBox(height: 24),
        _FaceOff(
          attackerName: attacker?.name ?? 'Attacker',
          attackerColor: attackerColor,
          attackerScore: a,
          attackerLeads: lead > 0,
          defenderName: defender?.name ?? 'Unclaimed',
          defenderColor: defenderColor,
          defenderScore: d,
          defenderLeads: lead < 0,
        ),
        const SizedBox(height: 18),
        _TugOfWarBar(
          fraction: frac,
          emoji: attack.metric.emoji,
          attackerColor: attackerColor,
          defenderColor: defenderColor,
        ),
        const SizedBox(height: 14),
        _LeadCaption(
          lead: lead,
          attackerName: attacker?.name ?? 'Attacker',
          defenderName: defender?.name ?? 'the defender',
          attackerColor: attackerColor,
          defenderColor: defenderColor,
        ),
      ],
    );
  }
}

class _MetricHeader extends StatelessWidget {
  const _MetricHeader({
    required this.emoji,
    required this.metricLabel,
    required this.remaining,
  });

  final String emoji;
  final String metricLabel;
  final String remaining;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚔️  Battle in progress',
                style: TextStyle(
                  color: context.srText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Most $metricLabel logged wins this territory.',
                style: TextStyle(color: context.srTextMuted, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _TimerChip(remaining: remaining),
      ],
    );
  }
}

class _TimerChip extends StatelessWidget {
  const _TimerChip({required this.remaining});
  final String remaining;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.srAmber.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.srAmber.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 13, color: context.srAmber),
          const SizedBox(width: 4),
          Text(
            remaining,
            style: TextStyle(
              color: context.srAmber,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MyGuildBanner extends StatelessWidget {
  const _MyGuildBanner({required this.isAttacking, required this.metricLabel});
  final bool isAttacking;
  final String metricLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.srLime.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.srLime.withAlpha(100)),
      ),
      child: Text(
        isAttacking
            ? '🗡️ Your guild is attacking, every $metricLabel counts!'
            : '🛡️ Your guild is defending, hold the line!',
        style: TextStyle(
          color: context.srLimeText,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FaceOff extends StatelessWidget {
  const _FaceOff({
    required this.attackerName,
    required this.attackerColor,
    required this.attackerScore,
    required this.attackerLeads,
    required this.defenderName,
    required this.defenderColor,
    required this.defenderScore,
    required this.defenderLeads,
  });

  final String attackerName;
  final Color attackerColor;
  final double attackerScore;
  final bool attackerLeads;
  final String defenderName;
  final Color defenderColor;
  final double defenderScore;
  final bool defenderLeads;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _GuildCard(
            name: attackerName,
            color: attackerColor,
            score: attackerScore,
            leading: attackerLeads,
            alignEnd: false,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.srBgElev2,
              border: Border.all(color: context.srLine),
            ),
            child: Text(
              'VS',
              style: TextStyle(
                color: context.srTextDim,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        Expanded(
          child: _GuildCard(
            name: defenderName,
            color: defenderColor,
            score: defenderScore,
            leading: defenderLeads,
            alignEnd: true,
          ),
        ),
      ],
    );
  }
}

class _GuildCard extends StatelessWidget {
  const _GuildCard({
    required this.name,
    required this.color,
    required this.score,
    required this.leading,
    required this.alignEnd,
  });

  final String name;
  final Color color;
  final double score;
  final bool leading;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Container(
          decoration: leading
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: color.withAlpha(120), blurRadius: 16),
                  ],
                )
              : null,
          child: GuildAvatar(color: color, initials: guildInitials(name)),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading && !alignEnd) ...[
              Icon(Icons.arrow_drop_up, color: color, size: 20),
            ],
            Text(
              score.round().toString(),
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (leading && alignEnd) ...[
              Icon(Icons.arrow_drop_up, color: color, size: 20),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          name,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          style: TextStyle(
            color: context.srTextMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TugOfWarBar extends StatelessWidget {
  const _TugOfWarBar({
    required this.fraction,
    required this.emoji,
    required this.attackerColor,
    required this.defenderColor,
  });

  final double fraction;
  final String emoji;
  final Color attackerColor;
  final Color defenderColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.5, end: fraction.clamp(0.08, 0.92)),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            final aPct = (value * 100).round();
            return Column(
              children: [
                SizedBox(
                  height: 34,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 8,
                        child: Container(
                          height: 18,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: context.srBg,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: context.srLine),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: (value * 1000).round(),
                                child: ColoredBox(color: attackerColor),
                              ),
                              Expanded(
                                flex: ((1 - value) * 1000).round(),
                                child: ColoredBox(color: defenderColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: -8,
                        left: (value * width - 17).clamp(0.0, width - 14),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$aPct%',
                      style: TextStyle(
                        color: attackerColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${100 - aPct}%',
                      style: TextStyle(
                        color: defenderColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _LeadCaption extends StatelessWidget {
  const _LeadCaption({
    required this.lead,
    required this.attackerName,
    required this.defenderName,
    required this.attackerColor,
    required this.defenderColor,
  });

  final int lead;
  final String attackerName;
  final String defenderName;
  final Color attackerColor;
  final Color defenderColor;

  @override
  Widget build(BuildContext context) {
    final String text;
    final Color color;
    if (lead == 0) {
      text = 'Waiting for the first score…';
      color = context.srTextMuted;
    } else if (lead > 0) {
      text = '$attackerName is leading the assault';
      color = attackerColor;
    } else {
      text = '$defenderName is holding strong';
      color = defenderColor;
    }
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
    );
  }
}

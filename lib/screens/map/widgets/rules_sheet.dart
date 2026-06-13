import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/common/widgets/sr_bottom_sheet.dart';

class RulesSheet extends StatelessWidget {
  const RulesSheet({super.key});

  static Future<void> show(BuildContext context) {
    return SrBottomSheet.show(
      context: context,
      title: 'How it works',
      child: const RulesSheet(),
    );
  }

  static const _rules = [
    (
      '🏰',
      'Territories',
      'The map is a grid of neutral territories. When you create a guild, you automatically claim one. Your guild\'s color marks everything you own.',
    ),
    (
      '⚔️',
      'Attacking',
      'You can attack any territory adjacent to one you already own. Pick a metric (steps, sleep…) and a duration (24h, 48h, 72h). Only one attack at a time per guild.',
    ),
    (
      '📊',
      'How winners are decided',
      'During the attack window, each guild\'s members sync their health data. The guild with the highest total wins, every member counts, even small contributions.',
    ),
    (
      '🤝',
      'Tie rule',
      'Equal totals? The defender keeps the territory. Attackers must outperform to conquer.',
    ),
    (
      '👥',
      'Guild slots',
      'A new guild can hold 5 members. Each territory you conquer unlocks one more slot. Grow your territory to grow your team.',
    ),
    (
      '🐺',
      'Solo players',
      'You can claim neutral territories alone, but you can\'t attack guilds without joining one first. Solo players are "guilds of 1".',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (icon, title, body) in _rules)
          _Rule(icon: icon, title: title, body: body),
      ],
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.icon, required this.title, required this.body});

  final String icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.srText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: TextStyle(
                    color: context.srTextMuted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

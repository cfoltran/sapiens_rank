import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/common/widgets/sr_bottom_sheet.dart';
import 'package:sapiens_rank/l10n/app_localizations.dart';

class RulesSheet extends StatelessWidget {
  const RulesSheet({super.key});

  static Future<void> show(BuildContext context) {
    return SrBottomSheet.show(
      context: context,
      title: AppLocalizations.of(context).rules_title,
      child: const RulesSheet(),
    );
  }

  List<(String, String, String)> _buildRules(BuildContext context) {
    final l = AppLocalizations.of(context);
    return [
      ('🏰', l.rules_territories_title, l.rules_territories_body),
      ('⚔️', l.rules_attacking_title, l.rules_attacking_body),
      ('📊', l.rules_winners_title, l.rules_winners_body),
      ('🤝', l.rules_tie_title, l.rules_tie_body),
      ('⚡', l.rules_boosters_title, l.rules_boosters_body),
      ('👥', l.rules_slots_title, l.rules_slots_body),
      ('🐺', l.rules_solo_title, l.rules_solo_body),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (icon, title, body) in _buildRules(context))
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

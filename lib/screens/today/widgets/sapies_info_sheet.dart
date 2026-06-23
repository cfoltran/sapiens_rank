import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/common/widgets/sr_bottom_sheet.dart';
import 'package:sapiens_rank/l10n/app_localizations.dart';
import 'package:sapiens_rank/screens/today/widgets/sapie_coin.dart';

class SapiesInfoSheet extends StatelessWidget {
  const SapiesInfoSheet({super.key, this.onNavigateToBattle});

  final VoidCallback? onNavigateToBattle;

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onNavigateToBattle,
  }) {
    return SrBottomSheet.show(
      context: context,
      child: SapiesInfoSheet(onNavigateToBattle: onNavigateToBattle),
    );
  }

  List<(String, String, String)> _buildItems(BuildContext context) {
    final l = AppLocalizations.of(context);
    return [
      ('📅', l.sapies_earn_title, l.sapies_earn_body),
      ('⚡', l.sapies_spend_title, l.sapies_spend_body),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SapieCoin(size: 28),
            const SizedBox(width: 10),
            Text(
              AppLocalizations.of(context).sapies_title,
              style: TextStyle(
                color: context.srText,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context).sapies_subtitle,
          style: TextStyle(color: context.srTextMuted, fontSize: 13),
        ),
        const SizedBox(height: 24),
        for (final (icon, title, body) in _buildItems(context))
          _InfoRow(icon: icon, title: title, body: body),
        if (onNavigateToBattle != null) ...[
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                onNavigateToBattle!();
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
                AppLocalizations.of(context).sapies_cta,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.title, required this.body});

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

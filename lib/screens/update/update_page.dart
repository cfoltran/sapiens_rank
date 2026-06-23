import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sapiens_rank/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

const playStoreUrl = '';
const appStoreUrl = 'https://apps.apple.com/fr/app/voxontop/id6753363277';

class UpdatePage extends StatelessWidget {
  const UpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final url = Platform.isAndroid ? playStoreUrl : appStoreUrl;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 24,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context).update_title),
            ElevatedButton(
              child: Text(AppLocalizations.of(context).update_btn),
              onPressed: () => _launchInBrowserView(Uri.parse(url)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchInBrowserView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagingService {
  MessagingService._();
  static final MessagingService instance = MessagingService._();

  final _messaging = FirebaseMessaging.instance;
  final _log = Logger('MessagingService');

  Future<bool> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (granted) await _saveToken();
      return granted;
    } catch (e) {
      _log.warning('requestPermission failed: $e');
      return false;
    }
  }

  /// Call on app launch — saves the token if granted, requests if not yet determined.
  Future<void> saveOrRequestToken() async {
    final settings = await _messaging.getNotificationSettings();
    switch (settings.authorizationStatus) {
      case AuthorizationStatus.notDetermined:
        await requestPermission();
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        await _saveToken();
      default:
        break;
    }
  }

  void listenForTokenRefresh() {
    _messaging.onTokenRefresh.listen((token) async {
      _log.info('FCM token refreshed');
      await _upsertToken(token);
    });
  }

  void initialize(
    BuildContext context, {
    required void Function(String challengeId) onChallengeInvite,
    required void Function(String challengeId) onChallengeResult,
  }) {
    _log.info('Initializing MessagingService');

    _messaging.getInitialMessage().then((message) {
      final link = message?.data['link'] as String?;
      if (link != null && context.mounted) {
        _log.info('Terminated state launch with link: $link');
        _handleLink(
          context,
          link,
          onChallengeInvite: onChallengeInvite,
          onChallengeResult: onChallengeResult,
        );
      }
    });

    FirebaseMessaging.onMessage.listen((message) {
      if (!context.mounted) return;
      final link = message.data['link'] as String?;
      final body =
          message.notification?.body ?? message.notification?.title ?? '';
      _log.info('Foreground message: ${message.messageId}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: SrColors.textInk,
          content: Text(body, style: const TextStyle(color: Colors.white)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
          action: link == null
              ? null
              : SnackBarAction(
                  label: 'View',
                  textColor: SrColors.lime,
                  onPressed: () {
                    if (context.mounted) {
                      _handleLink(
                        context,
                        link,
                        onChallengeInvite: onChallengeInvite,
                        onChallengeResult: onChallengeResult,
                      );
                    }
                  },
                ),
        ),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final link = message.data['link'] as String?;
      _log.info('Background open: ${message.messageId}');
      if (link != null && context.mounted) {
        _handleLink(
          context,
          link,
          onChallengeInvite: onChallengeInvite,
          onChallengeResult: onChallengeResult,
        );
      }
    });
  }

  void _handleLink(
    BuildContext context,
    String link, {
    required void Function(String) onChallengeInvite,
    required void Function(String) onChallengeResult,
  }) {
    final uri = Uri.parse(link);
    if (uri.scheme != 'challenge') return;
    if (uri.host == 'result' && uri.pathSegments.isNotEmpty) {
      onChallengeResult(uri.pathSegments.first);
    } else if (uri.host.isNotEmpty) {
      onChallengeInvite(uri.host);
    }
  }

  Future<void> _saveToken() async {
    try {
      if (Platform.isIOS) {
        await _messaging.getAPNSToken().timeout(
          const Duration(seconds: 10),
          onTimeout: () => null,
        );
      }
      final token = await _messaging.getToken();
      if (token == null) return;
      _log.info('FCM token obtained');
      await _upsertToken(token);
    } catch (e) {
      _log.warning('Failed to save FCM token: $e');
    }
  }

  Future<void> _upsertToken(String token) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await Supabase.instance.client.from('device_tokens').upsert({
        'user_id': uid,
        'fcm_token': token,
      });
    } catch (e) {
      _log.warning('Failed to upsert FCM token: $e');
    }
  }
}

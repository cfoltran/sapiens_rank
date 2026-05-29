import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _log = Logger('NotificationService');

  /// Requests push permission and stores the FCM token in the user's profile.
  /// Returns true if permission was granted.
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

  Future<void> _saveToken() async {
    try {
      if (Platform.isIOS) {
        await _messaging
            .getAPNSToken()
            .timeout(const Duration(seconds: 10), onTimeout: () => null);
      }
      final token = await _messaging.getToken();
      if (token == null) return;
      _log.info('FCM token obtained');
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) return;
      await Supabase.instance.client
          .from('device_tokens')
          .upsert({'user_id': uid, 'fcm_token': token});
    } catch (e) {
      _log.warning('Failed to save FCM token: $e');
    }
  }
}

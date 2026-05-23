// import 'dart:io';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:logging/logging.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:voxontop/screens/home/affirmation_deep_link_page.dart';

// class FirebaseMessagingService {
//   FirebaseMessagingService._privateConstructor();
//   static final FirebaseMessagingService _instance =
//       FirebaseMessagingService._privateConstructor();

//   static FirebaseMessagingService get instance => _instance;

//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   FirebaseMessaging get firebaseMessaging => _firebaseMessaging;
//   final logger = Logger('FirebaseMessagingService');

//   Future<String?> getDeviceToken() async {
//     NotificationSettings settings = await _firebaseMessaging
//         .requestPermission();

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       if (Platform.isIOS) {
//         final apnsToken = await _firebaseMessaging.getAPNSToken().timeout(
//           const Duration(seconds: 10),
//           onTimeout: () => null,
//         );

//         logger.info('APNS token: $apnsToken');
//       }

//       final token = await _firebaseMessaging.getToken();

//       if (token != null) {
//         logger.info('FCM token: $token');
//         storeTokenInSupabase(token);
//       }

//       return token;
//     } else {
//       logger.info('User declined or has not accepted permission');
//       return null;
//     }
//   }

//   void initialize(BuildContext context) {
//     logger.info('Initializing Firebase Messaging');

//     // App opened from terminated state
//     _firebaseMessaging.getInitialMessage().then((message) {
//       final link = message?.data['link'] as String?;
//       if (link != null && context.mounted) {
//         logger.info('Terminated state launch with link: $link');
//         _handleLink(context, link);
//       }
//     });

//     // Foreground message — show a snackbar instead of navigating immediately
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       final link = message.data['link'] as String?;
//       logger.info('Foreground message: ${message.messageId}');
//       if (link == null || !context.mounted) return;

//       final title = message.notification?.title;
//       final body = message.notification?.body;
//       final label = body ?? title;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(label ?? ''),
//           behavior: SnackBarBehavior.floating,
//           duration: const Duration(seconds: 5),
//           action: SnackBarAction(
//             label: 'Voir',
//             onPressed: () => _handleLink(context, link),
//           ),
//         ),
//       );
//     });

//     // App opened from background (notification tapped)
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       final link = message.data['link'] as String?;
//       logger.info('Background open: ${message.messageId}');
//       if (link != null && context.mounted) _handleLink(context, link);
//     });
//   }

//   void _handleLink(BuildContext context, String link) {
//     final uri = Uri.parse(link);
//     final segments = uri.pathSegments;

//     if (segments.length >= 2 && segments[0] == 'affirmation') {
//       final id = int.tryParse(segments[1]);
//       if (id != null) {
//         final openComments = segments.length >= 4 && segments[2] == 'comment';
//         showCupertinoSheet<void>(
//           context: context,
//           builder: (_) => AffirmationDeepLinkPage(
//             affirmationId: id,
//             openComments: openComments,
//           ),
//         );
//         return;
//       }
//     }

//     context.push(link);
//   }

//   Future<void> storeTokenInSupabase(String token) async {
//     final user = Supabase.instance.client.auth.currentUser;

//     if (user == null) {
//       logger.severe('User is not authenticated');
//       return;
//     }
//     try {
//       await Supabase.instance.client
//           .from('profiles')
//           .update({'fcm_token': token})
//           .eq('id', user.id);
//     } catch (e) {
//       logger.severe('Failed to store FCM token: $e');
//     }
//   }
// }

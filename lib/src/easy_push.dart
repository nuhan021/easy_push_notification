import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'models/easy_push_config.dart';
import '_firebase_service.dart';
import '_notification_service.dart';

// Background handler must be a top-level or static function
@pragma('vm:entry-point')
Future<void> easyPushBackgroundHandler(RemoteMessage message) async {
  // Firebase.initializeApp() is called in _FirebaseService.init in app isolate;
  // for safety, Firebase Messaging plugin handles background isolate init.
  final notif = message.notification;
  if (notif != null) {
    await NotificationService.I.show(
      title: notif.title ?? '',
      body: notif.body ?? '',
      payload: message.data['screen'] ?? message.data['payload'],
      imageUrl: notif.android?.imageUrl ?? notif.apple?.imageUrl,
    );
  }
}

class EasyPush {
  EasyPush._();
  static final EasyPush I = EasyPush._();

  EasyPushConfig _config = const EasyPushConfig();

  /// Call once during app startup (before runApp).
  Future<void> initialize(EasyPushConfig config) async {
    _config = config;

    await FirebaseService.I.init(
      requestIOSPermissions: _config.requestIOSPermissions,
    );

    await NotificationService.I.init(
      androidChannelId: _config.androidChannelId,
      androidChannelName: _config.androidChannelName,
      onTap: (payload) async {
        final cb = _config.onNotificationTap;
        if (cb != null) await cb(payload);
      },
    );

    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) async {
      if (!_config.showForegroundNotifications) return;
      final notif = message.notification;
      if (notif != null) {
        await NotificationService.I.show(
          title: notif.title ?? '',
          body: notif.body ?? '',
          payload: message.data['screen'] ?? message.data['payload'],
          imageUrl: notif.android?.imageUrl ?? notif.apple?.imageUrl,
        );
      }
    });

    // Background handler (app terminated/in background)
    FirebaseMessaging.onBackgroundMessage(easyPushBackgroundHandler);

    // Tap when app is in background and user opens from system tray
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      final payload = message.data['screen'] ?? message.data['payload'];
      final cb = _config.onNotificationTap;
      if (payload != null && cb != null) {
        await cb(payload);
      }
    });
  }

  /// Get current FCM token
  Future<String?> getToken() => FirebaseService.I.getToken();

  /// Listen for token refresh (also emits initial token once)
  Stream<String> get onTokenRefresh => FirebaseService.I.onTokenRefresh;

  /// Show a local notification manually
  Future<void> showLocal({
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
  }) async {
    await NotificationService.I.show(
      title: title,
      body: body,
      payload: payload,
      imageUrl: imageUrl,
    );
  }
}

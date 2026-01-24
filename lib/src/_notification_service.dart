import 'dart:io';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  NotificationService._();
  static final _instance = NotificationService._();
  static NotificationService get I => _instance;

  final _plugin = FlutterLocalNotificationsPlugin();
  late AndroidNotificationChannel _channel;

  Future<void> init({
    required String androidChannelId,
    required String androidChannelName,
    required void Function(String payload)? onTap,
  }) async {
    _channel = AndroidNotificationChannel(
      androidChannelId,
      androidChannelName,
      importance: Importance.high,
    );

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && onTap != null) onTap(payload);
      },
    );

    // Android channel creation (idempotent)
    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<void> show({
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
  }) async {
    BigPictureStyleInformation? bigPicture;
    DarwinNotificationDetails? iosDetails;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final path = await _downloadAndSaveFile(
          imageUrl,
          'notification_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        if (Platform.isAndroid) {
          bigPicture = BigPictureStyleInformation(
            FilePathAndroidBitmap(path),
            contentTitle: title,
            summaryText: body,
          );
        } else if (Platform.isIOS) {
          iosDetails = DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            attachments: [DarwinNotificationAttachment(path)],
          );
        }
      } catch (e) {
        // If image download fails, notification will show without image
        print('Failed to download notification image: $e');
      }
    }

    final android = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: bigPicture,
    );

    final ios = iosDetails ?? const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(android: android, iOS: ios);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/$fileName';
    final response = await http.get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}

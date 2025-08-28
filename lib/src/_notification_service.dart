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
    const initSettings = InitializationSettings(android: androidInit);

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

    if (imageUrl != null && imageUrl.isNotEmpty && Platform.isAndroid) {
      final path = await _downloadAndSaveFile(
        imageUrl,
        'big_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      bigPicture = BigPictureStyleInformation(
        FilePathAndroidBitmap(path),
        contentTitle: title,
        summaryText: body,
      );
    }

    final android = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: bigPicture,
    );

    final details = NotificationDetails(android: android);

    await _plugin.show(
      0,
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

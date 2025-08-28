import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  FirebaseService._();
  static final _instance = FirebaseService._();
  static FirebaseService get I => _instance;

  final _messaging = FirebaseMessaging.instance;
  final _tokenController = StreamController<String>.broadcast();

  Stream<String> get onTokenRefresh => _tokenController.stream;

  Future<void> init({bool requestIOSPermissions = true}) async {
    await Firebase.initializeApp();

    if (requestIOSPermissions) {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        provisional: false,
        criticalAlert: false,
        carPlay: false,
      );
    }

    // Emit initial token
    final token = await _messaging.getToken();
    if (token != null) _tokenController.add(token);

    // Listen token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _tokenController.add(newToken);
    });
  }

  Future<String?> getToken() => _messaging.getToken();
}

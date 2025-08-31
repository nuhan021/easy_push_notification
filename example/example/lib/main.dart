import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:easy_push_notification/easy_push_notification.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  EasyPush.I.initialize(EasyPushConfig());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Easy Push')),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Print FCM token
            ElevatedButton(
              onPressed: () async {
                final token = await EasyPush.I.getToken();
                print(token);
              },
              child: Text("Get FCM"),
            ),

            ElevatedButton(
              onPressed: () async {
                EasyPush.I.showLocal(
                  title: 'Local Notification',
                  body: 'Local Notification',
                );
              },
              child: Text('Send Local Notification'),
            ),
          ],
        ),
      ),
    );
  }
}

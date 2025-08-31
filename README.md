# Easy Push Notification

A simple and efficient Flutter package to handle push notifications using Firebase Cloud Messaging (FCM) for Android and iOS.

## Features

* Easy Firebase initialization
* Foreground & background notification handling
* Local notifications with optional image
* FCM token management
* Works on Android & iOS

## Getting Started

### Setup Process

1. Configure Firebase in your project.
2. Add dependencies in `pubspec.yaml`:

```yaml
firebase_core: ^4.0.0
easy_push_notification: ^0.0.1
```

3. **Android Setup** (`android/app/build.gradle.kts`):

* Add compile options:

```kotlin
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
    isCoreLibraryDesugaringEnabled = true
}
```

* Add dependencies:

```kotlin
dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.9.24")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

* Set `minSdk` and `ndkVersion` if needed:

```kotlin
defaultConfig {
    applicationId = "com.example.notification_test"
    minSdk = 23
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
}
```

4. **iOS Setup**:

* In `ios/Podfile`, enable platform version:

```ruby
platform :ios, '11.0'
```

* Enable notifications in Xcode:

    * Open `ios/Runner.xcworkspace`
    * Select Runner → Signing & Capabilities
    * Add Push Notifications
    * Add Background Modes → Remote Notifications

* Add FCM permission in `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

* Request permission in your app (handled automatically by the package).

## Usage
In `main.dart` initialize EasyPush:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_push_notification/easy_push_notification.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  EasyPush.I.initialize(EasyPushConfig()); // add this line

  runApp(const MyApp());
}
```

### Local Notification

```dart
ElevatedButton(
  onPressed: () {
    EasyPush.I.showLocal(
      title: 'Hello',
      body: 'Local test body',
      payload: 'home',
    );
  },
  child: const Text('Test Local Notification'),
)
```

### Initialize and Handle Notifications

```dart
await EasyPush.I.initialize(
  EasyPushConfig(
    androidChannelId: 'default_channel',
    androidChannelName: 'General Notifications',
    requestIOSPermissions: true,
    showForegroundNotifications: true,
    onNotificationTap: (payload) async {
      // Handle notification tap
    },
  ),
);
```

### Get FCM Token

```dart
final token = await EasyPush.I.getToken();
print('FCM Token: $token');
```

### Listen for Token Refresh

```dart
void initFCM() async {
  // First time getting a token
  final token = await EasyPush.I.getToken();
  if (token != null) {
    updateTokenToServer(token);
  }

  // If the token changes later, listen.
  EasyPush.I.onTokenRefresh.listen((newToken) {
    updateTokenToServer(newToken);
  });
}
```

## Example

Check the `/example` folder for a working demo project.

## License

MIT License

Copyright (c) 2025 Nuhan Chowdhury

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

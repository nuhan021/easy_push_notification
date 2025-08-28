class EasyPushConfig {
  const EasyPushConfig({
    this.androidChannelId = 'default_channel',
    this.androidChannelName = 'General Notifications',
    this.onNotificationTap,
    this.requestIOSPermissions = true,
    this.showForegroundNotifications = true,
  });

  /// Notification channel for Android
  final String androidChannelId;
  final String androidChannelName;

  /// Called when a user taps a notification.
  final Future<void> Function(String payload)? onNotificationTap;

  /// Whether to request iOS notification permissions during init.
  final bool requestIOSPermissions;

  /// Whether to show a local notification for foreground messages (iOS/Android).
  final bool showForegroundNotifications;
}

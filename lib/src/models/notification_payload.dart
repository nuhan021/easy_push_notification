class NotificationPayload {
  final String? title;
  final String? body;
  final String? imageUrl;
  final String? payload; // route/screen/deeplink

  const NotificationPayload({
    this.title,
    this.body,
    this.imageUrl,
    this.payload,
  });
}

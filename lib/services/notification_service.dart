import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInit = false;

  bool get isInit => _isInit;

  Future<void> initNotification() async {
    if (_isInit) return;
    const initSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );
    await notificationsPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails("channelId", "channelName",
            channelDescription: "channelDescription",
            importance: Importance.max,
            priority: Priority.high),
        iOS: DarwinNotificationDetails());
  }

  Future showNotification(
      {int id = 0, String? title, String? body, String? payload}) async {
    return notificationsPlugin.show(id, title, body, notificationDetails());
  }
  
}

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotif {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _plugin.initialize(initSettings);
  }

  static Future show(String title, String body) async {
    const android = AndroidNotificationDetails(
      'notif_channel',
      'Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _plugin.show(
      0,
      title,
      body,
      const NotificationDetails(android: android),
    );
  }
}

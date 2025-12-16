import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../firebase_options.dart';
import '../routes/routes.dart';
import 'package:flutter/material.dart';

// Navigator key global, agar bisa navigasi dari notifikasi
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'channel_id', 
    'GoBox Notifications',
    description: 'Channel for GoBox app notifications',
    importance: Importance.max,
  );

  static Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Android initialization
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        _handleNotificationClick(details.payload);
      },
    );

    // Register Android channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Request permission
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Foreground handler
    FirebaseMessaging.onMessage.listen(_onMessageReceived);

    // Tap notification handler
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationClick(message.data['type']);
      print("User clicked notification: ${message.data}");
    });

    // Optional: print FCM token
    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $token");
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print("Handling background message: ${message.messageId}");
  }

  static void _onMessageReceived(RemoteMessage message) {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: message.data['type'],
      );
    }

    // Optional: handle type immediately
    if (message.data['type'] == 'chat') {
      print("Pesan chat diterima: ${message.data['message']}");
    } else if (message.data['type'] == 'withdrawal') {
      print(
        "Status penarikan: ${message.data['status']} - Rp ${message.data['amount']}",
      );
    }
  }

  // Navigasi berdasarkan payload
  static void _handleNotificationClick(String? type) {
    if (type == 'chat') {
      navigatorKey.currentState?.pushNamed(AppRoutes.chat);
    } else if (type == 'withdrawal') {
      navigatorKey.currentState?.pushNamed(AppRoutes.penarikan);
    }
  }
}

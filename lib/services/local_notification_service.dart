import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LocalNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings: initSettings);
  }

  static Future<void> show(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'sentinel_fall_channel',       // channel ID
      'Fall Detection Alert',        // channel name
      channelDescription: 'Notifikasi deteksi jatuh dari SentinelAI',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _plugin.show(
      id: message.hashCode,
      title: message.notification?.title ?? '🚨 Fall Detected!',
      body: message.notification?.body ?? 'Seseorang terdeteksi jatuh.',
      notificationDetails: const NotificationDetails(android: androidDetails),
    );
  }
}
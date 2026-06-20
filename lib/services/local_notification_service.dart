import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart' show Color;

class LocalNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await _plugin.initialize(settings:  initSettings);

  // Buat channel dengan suara & getar emergency
  final androidChannel = AndroidNotificationChannel(
    'sentinel_fall_channel',
    'Fall Detection Alert',
    sound: RawResourceAndroidNotificationSound('alert'), // ← tanpa ekstensi
    description: 'Notifikasi deteksi jatuh dari SentinelAI',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]), // pola getar
    enableLights: true,
    ledColor: Color(0xFFFF0000), // LED merah
  );

  await _plugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);
}

  static Future<void> show(RemoteMessage message) async {
  final androidDetails = AndroidNotificationDetails(
    'sentinel_fall_channel',
    'Fall Detection Alert',
    channelDescription: 'Notifikasi deteksi jatuh dari SentinelAI',
    sound: RawResourceAndroidNotificationSound('alert'), // ← tambah ini
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
    fullScreenIntent: true,    // muncul walau HP terkunci
    enableLights: true,
    ledColor: const Color(0xFFFF0000),
    ledOnMs: 300,
    ledOffMs: 100,
  );

  await _plugin.show(
    id: message.hashCode,
    title: message.notification?.title ?? '🚨 Fall Detected!',
    body: message.notification?.body ?? 'Seseorang terdeteksi jatuh.',
    notificationDetails: NotificationDetails(android: androidDetails),
  );
}
}
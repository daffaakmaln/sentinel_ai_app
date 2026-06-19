import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> init(String jwtToken) async {
    // 1. Minta izin notifikasi
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      sound: true,
      badge: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) return;

    // 2. Ambil FCM token
    String? token = await _messaging.getToken();
    if (token != null) {
      await _sendTokenToBackend(token, jwtToken);
    }

    // 3. Refresh token otomatis jika berubah
    _messaging.onTokenRefresh.listen((newToken) {
      _sendTokenToBackend(newToken, jwtToken);
    });

    // 4. Handle notifikasi saat app FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground notification: ${message.notification?.title}');
      // Tampilkan local notification di sini (pakai flutter_local_notifications)
      _showLocalNotification(message);
    });

    // 5. Handle ketika user tap notifikasi (app di background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Opened from background: ${message.data}');
      // Navigasi ke halaman event tertentu jika perlu
    });
  }

  static Future<void> _sendTokenToBackend(String token, String jwtToken) async {
    await http.post(
      Uri.parse('http://localhost:3000/api/fcm-token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode({'fcm_token': token}),
    );
  }

  static void _showLocalNotification(RemoteMessage message) {
    // Implementasi flutter_local_notifications di sini
    
    // Lihat bagian 1c
  }
}
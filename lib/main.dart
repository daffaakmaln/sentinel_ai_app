import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sentinel_new_app/auth_pages/loginpage.dart';
import 'package:sentinel_new_app/auth_pages/registerpage.dart';
import 'package:sentinel_new_app/navbar/camera_page.dart';
import 'package:sentinel_new_app/pages/add_elderly.dart';
import 'package:sentinel_new_app/pages/detail_elderly.dart';
import 'package:sentinel_new_app/pages/edit_elderly.dart';
import 'package:sentinel_new_app/pages/homepage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sentinel_new_app/services/local_notification_service.dart';

// Handler untuk notifikasi saat app di background/terminated
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocalNotificationService.init(); // tambah ini
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sentinel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      initialRoute: '/',
      
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/register': (context) => const RegisterPage(),
        '/elderly/add': (context) => const AddElderlyPage(),
        '/elderly/detail': (context) => const ElderlyDetailPage(),
        '/elderly/edit': (context) => const ElderlyEditPage(),
        '/camera/status': (context) => const CameraStatusPage(),
      },
    );
  }
}
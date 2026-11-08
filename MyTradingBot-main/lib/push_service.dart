import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PushService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> initFirebase() async {
    try {
      await Firebase.initializeApp();
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          // await sendFcmTokenToServer(token, sessionToken);
        }
      }
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          showNotification(
            message.notification!.title ?? 'إشعار',
            message.notification!.body ?? '',
          );
        }
      });
    } catch (e) {
      print('❌ خطأ في تهيئة Firebase: $e');
    }
  }

  static Future<void> sendFcmTokenToServer(String token, String sessionToken) async {
    try {
      await http.post(
        Uri.parse('https://quotex.com/api/client/fcm-token'),
        headers: {
          'Authorization': 'Bearer $sessionToken',
          'Cookie': 'qtx_session_token=$sessionToken',
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10)',
          'Origin': 'https://quotex.com',
        },
        body: jsonEncode({'token': token}),
      );
    } catch (e) {
      print('❌ فشل إرسال توكن FCM: $e');
    }
  }

  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'alking_push_channel',
      'Alking Notifications',
      channelDescription: 'إشعارات التطبيق',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}

@pragma('vm:entry-point')
Future<void> pushBackgroundHandler(RemoteMessage message) async {}

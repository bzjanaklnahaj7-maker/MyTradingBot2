import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class BackgroundService {
  // 1. تهيئة خدمة الخلفية
  static Future<void> init() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'alking_foreground_service',
        channelName: 'Alking Bot Service',
        channelDescription: 'خدمة التداول الآلي في الخلفية',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  // 2. بدء الخدمة
  static Future<void> startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.restartService();
    } else {
      await FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: 'Alking يعمل 🟢',
        notificationText: 'البوت متصل بالسيرفر والتحليلات جارية...',
        callback: startCallback,
      );
    }
  }

  // 3. إيقاف الخدمة
  static Future<void> stopService() async {
    await FlutterForegroundTask.stopService();
  }
}

// دالة الاستدعاء (Callback) المطلوبة من مكتبة flutter_foreground_task
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // يتم استدعاؤها عند بدء الخدمة
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // يتم استدعاؤها دورياً (كل 5 ثوانٍ) - يمكن استخدامها لفحص السوق
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    // يتم استدعاؤها عند إيقاف الخدمة
  }
}

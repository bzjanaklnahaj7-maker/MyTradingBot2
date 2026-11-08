import 'package:flutter/services.dart';

class NativeBridgeService {
  static const MethodChannel _channel = MethodChannel('com.example.alking/native_bridge');

  // 1. جلب معلومات الجهاز (العلامة التجارية، الموديل، إلخ)
  Future<Map<String, dynamic>?> getDeviceInfo() async {
    try {
      final result = await _channel.invokeMethod('getDeviceInfo');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      return null;
    }
  }

  // 2. جلب معرف الأندرويد الفريد (Android ID)
  Future<String?> getAndroidId() async {
    try {
      final result = await _channel.invokeMethod('getAndroidId');
      return result;
    } catch (e) {
      return null;
    }
  }

  // 3. توليد UUID جديد
  Future<String?> generateUUID() async {
    try {
      final result = await _channel.invokeMethod('generateUUID');
      return result;
    } catch (e) {
      return null;
    }
  }

  // 4. التحقق من أن الجهاز حقيقي (ليس محاكياً)
  Future<bool> isPhysicalDevice() async {
    final info = await getDeviceInfo();
    return info?['isPhysicalDevice'] ?? false;
  }
}

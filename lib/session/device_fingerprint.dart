import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceFingerprint {
  static const String _keyDeviceId = 'qtx_device_id';

  Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? existingId = prefs.getString(_keyDeviceId);
    
    if (existingId != null && existingId.isNotEmpty) {
      return existingId;
    }
    
    // 🌟 توليد fingerprint حقيقي باستخدام device_info_plus
    final deviceInfo = DeviceInfoPlugin();
    String newId = "";
    try {
      final androidInfo = await deviceInfo.androidInfo;
      newId = "${androidInfo.id}-${androidInfo.model}-${androidInfo.brand}";
    } catch (e) {
      // إذا فشل (مثلاً على iOS)، استخدم قيمة عشوائية
      newId = DateTime.now().millisecondsSinceEpoch.toString();
    }
    
    await prefs.setString(_keyDeviceId, newId);
    return newId;
  }

  Future<void> clearDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDeviceId);
  }
}

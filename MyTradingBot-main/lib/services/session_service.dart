import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  // مفاتيح التخزين
  static const String _keyCookie = 'qtx_session_cookie';
  static const String _keyToken = 'qtx_session_token';
  static const String _keyAccountType = 'qtx_session_account_type';
  static const String _keyDeviceId = 'qtx_device_id';

  // 1. حفظ بيانات الجلسة
  Future<void> saveSession({
    required String cookie,
    required String token,
    required String accountType, // DEMO أو REAL
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCookie, cookie);
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyAccountType, accountType);
  }

  // 2. استرجاع الكوكيز
  Future<String?> getCookie() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCookie);
  }

  // 3. استرجاع التوكن
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // 4. استرجاع نوع الحساب
  Future<String?> getAccountType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccountType);
  }

  // 5. حذف الجلسة (عند تسجيل الخروج)
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCookie);
    await prefs.remove(_keyToken);
    await prefs.remove(_keyAccountType);
  }

  // 6. حفظ واسترجاع بصمة الجهاز (Device ID)
  Future<String?> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDeviceId);
  }

  Future<void> saveDeviceId(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDeviceId, deviceId);
  }
}

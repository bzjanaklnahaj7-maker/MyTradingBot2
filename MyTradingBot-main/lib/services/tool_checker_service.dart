import 'native_bridge_service.dart';

class ToolCheckerService {
  final NativeBridgeService _nativeBridge = NativeBridgeService();

  // 1. التحقق من سلامة البيئة (بدون حظر)
  // في التطبيق الأصلي، هذه الدالة تتحقق من الروت والمحاكي
  // لكننا هنا نعيد true دائماً للسماح بالعمل على جميع الأجهزة
  Future<bool> isEnvironmentSafe() async {
    return true;
  }

  // 2. التحقق من أن الجهاز حقيقي (ليس محاكياً)
  Future<bool> isPhysicalDevice() async {
    return await _nativeBridge.isPhysicalDevice();
  }

  // 3. جلب بصمة الجهاز الكاملة
  Future<Map<String, dynamic>?> getFullDeviceFingerprint() async {
    final info = await _nativeBridge.getDeviceInfo();
    final androidId = await _nativeBridge.getAndroidId();
    
    if (info != null) {
      info['androidId'] = androidId;
    }
    
    return info;
  }
}

import 'package:uuid/uuid.dart';
import 'session_service.dart';

class SafeDeviceService {
  final SessionService _sessionService = SessionService();

  // 1. توليد أو استرجاع بصمة الجهاز (UUID)
  Future<String> getOrCreateDeviceId() async {
    // محاولة استرجاع البصمة من التخزين المحلي
    String? existingId = await _sessionService.getDeviceId();
    
    if (existingId != null && existingId.isNotEmpty) {
      return existingId;
    }
    
    // إذا لم توجد، نقوم بتوليد بصمة جديدة (UUID v4)
    String newId = const Uuid().v4();
    await _sessionService.saveDeviceId(newId);
    return newId;
  }

  // 2. التحقق من أمان البيئة (محاكي/روت/تعديل)
  Future<bool> checkDeviceSecurity() async {
    try {
      // ملاحظة: التطبيق الأصلي يستخدم مكتبة libtoolChecker.so
      // في فلاتر، يمكننا استخدام حزم مثل safe_device أو root_checker
      // هنا نعيد true للسماح بالعمل على جميع الأجهزة (كما طلبت في البداية)
      return true;
    } catch (e) {
      return true;
    }
  }
}

class ErrorHandlerEngine {
  // 1. معالجة أخطاء فتح الصفقة
  static String handleTradeError(String errorCode) {
    switch (errorCode) {
      case 'pre_trade_failed':
        return '⚠️ فشل التحقق قبل الصفقة: قد يكون السعر تغير أو الحساب معلق.';
      case 'order_failed':
        return '❌ فشل فتح الصفقة: السيرفر رفض الأمر.';
      case 'insufficient_funds':
        return '💰 رصيد غير كافٍ لفتح الصفقة.';
      case 'asset_closed':
        return '⏰ الزوج مغلق حالياً، جرب زوجاً آخر.';
      default:
        return '⚠️ خطأ غير معروف أثناء فتح الصفقة: $errorCode';
    }
  }

  // 2. معالجة أخطاء الاتصال
  static String handleConnectionError(String errorCode) {
    switch (errorCode) {
      case 'websocket_failed':
        return '🔌 فشل الاتصال بالسيرفر، جاري إعادة المحاولة...';
      case 'websocket_closed_after_switch':
        return '🔄 انقطع الاتصال بعد تبديل الحساب، جاري إعادة الاتصال...';
      case 'unauthorized':
        return '🔐 الجلسة غير صالحة، يرجى تسجيل الدخول مرة أخرى.';
      default:
        return '⚠️ خطأ في الاتصال: $errorCode';
    }
  }

  // 3. معالجة أخطاء الجلسة
  static String handleSessionError(String errorCode) {
    switch (errorCode) {
      case 'empty_cookie':
        return '🍪 الكوكيز فارغة، يرجى إعادة تسجيل الدخول.';
      case 'ssid_not_found':
        return '🔑 لم يتم العثور على التوكن، يرجى تسجيل الدخول مرة أخرى.';
      default:
        return '⚠️ خطأ في الجلسة: $errorCode';
    }
  }
}

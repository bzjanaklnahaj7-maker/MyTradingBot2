class ExtendedApiEndpoints {
  // مسارات المستخدم والحساب
  static const String me = "/api/client/me";
  static const String register = "/api/client/register";
  static const String results = "/api/client/results";
  static const String fcmToken = "/api/client/fcm-token";
  
  // مسار الـ Digest المالي (الذي اكتشفناه في التقرير الأول)
  static const String cabinetsDigest = "/api/v1/cabinets/digest";
  
  // مسارات التداول المتقدمة
  static const String ordersOpen = "orders/open";
  static const String ordersClose = "orders/close";
  static const String ordersOpenedList = "orders/opened/list";
  static const String ordersClosedList = "orders/closed/list";
  
  // مسارات الشموع والأسعار
  static const String historyListV2 = "/history/list/v2";
  static const String quotesStream = "quotes/stream";
  static const String candles = "candles";
  
  // مسارات الإعدادات
  static const String settingsStore = "settings/store";
}

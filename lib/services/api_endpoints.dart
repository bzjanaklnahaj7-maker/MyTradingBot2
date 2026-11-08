class ApiEndpoints {
  // مسارات تسجيل الدخول والتداول
  static const String signIn = "/ar/sign-in";
  static const String trade = "/ar/trade";
  static const String demoTrade = "/ar/demo-trade";
  
  // مسارات الجلسات والملف الشخصي
  static const String profile = "/api/client/profile";
  static const String sessionsStart = "/api/client/sessions/start";
  
  // مسارات التداول والبيانات
  static const String trading = "/api/client/trading";
  static const String historyList = "/history/list/v2";
  
  // مسارات الإشعارات
  static const String notifications = "/api/client/notifications/";
}

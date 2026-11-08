import '../models/balance_model.dart';
import '../models/instrument_model.dart';

class SyncEngine {
  bool _isSyncing = false;
  
  // 1. مزامنة البيانات الأساسية
  Future<void> syncData({
    required Function onRequestBalance,
    required Function onRequestInstruments,
    required Function onRequestOpenOrders,
  }) async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      // طلب البيانات من السيرفر
      onRequestBalance();
      onRequestInstruments();
      onRequestOpenOrders();
    } finally {
      _isSyncing = false;
    }
  }

  // 2. مزامنة عند تبديل الحساب
  Future<void> syncOnAccountSwitch({
    required bool isDemo,
    required Function onSendAuthorization,
    required Function onRequestBalance,
  }) async {
    // إرسال التصريح بالحساب الجديد
    onSendAuthorization();
    
    // انتظار بسيط ليقوم السيرفر بتحديث الحالة
    await Future.delayed(const Duration(seconds: 1));
    
    // طلب الرصيد الجديد
    onRequestBalance();
  }

  // 3. التحقق من تحديث البيانات
  bool hasDataChanged({
    required BalanceModel? oldBalance,
    required BalanceModel? newBalance,
    required List<InstrumentModel>? oldInstruments,
    required List<InstrumentModel>? newInstruments,
  }) {
    // مقارنة الرصيد
    if (oldBalance?.realBalance != newBalance?.realBalance ||
        oldBalance?.demoBalance != newBalance?.demoBalance) {
      return true;
    }
    
    // مقارنة عدد الأزواج
    if (oldInstruments?.length != newInstruments?.length) {
      return true;
    }
    
    return false;
  }
}

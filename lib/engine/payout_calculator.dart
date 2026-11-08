class PayoutCalculator {
  // 1. حساب الأرباح الصافية بناءً على نسبة العائد
  // مثال: مبلغ 100$ ونسبة عائد 80% = ربح 80$
  static double calculateProfit(double amount, double payoutPercentage) {
    return amount * (payoutPercentage / 100.0);
  }

  // 2. حساب إجمالي المبلغ الذي سيُعاد للمستخدم في حال الربح
  // (المبلغ الأصلي + الربح)
  static double calculateTotalReturn(double amount, double payoutPercentage) {
    return amount + calculateProfit(amount, payoutPercentage);
  }

  // 3. حساب الخسارة (في حال خسر الصفقة، يخسر المبلغ كاملاً)
  static double calculateLoss(double amount) {
    return -amount;
  }

  // 4. تنسيق المبلغ ليظهر بشكل جميل (مثلاً 100.50)
  static String formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }
}

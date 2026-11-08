class BalanceModel {
  final double demoBalance;
  final double realBalance;
  final String accountType; // "DEMO" أو "REAL"

  BalanceModel({
    required this.demoBalance,
    required this.realBalance,
    required this.accountType,
  });

  // تحويل البيانات القادمة من السيرفر إلى كائن
  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    return BalanceModel(
      demoBalance: (json['demo_balance'] ?? 0.0).toDouble(),
      realBalance: (json['real_balance'] ?? 0.0).toDouble(),
      accountType: json['account_type']?.toString() ?? 'DEMO',
    );
  }

  // تحويل الكائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'demo_balance': demoBalance,
      'real_balance': realBalance,
      'account_type': accountType,
    };
  }
}

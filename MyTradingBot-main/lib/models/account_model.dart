class AccountModel {
  final double demoBalance;
  final double realBalance;
  final String accountType; // "DEMO" أو "REAL"
  final String currency;

  AccountModel({
    required this.demoBalance,
    required this.realBalance,
    required this.accountType,
    this.currency = 'USD',
  });

  // تحويل البيانات القادمة من السيرفر إلى كائن
  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      demoBalance: (json['demo_balance'] ?? json['demoBalance'] ?? 0.0).toDouble(),
      realBalance: (json['real_balance'] ?? json['realBalance'] ?? 0.0).toDouble(),
      accountType: json['account_type']?.toString() ?? 'DEMO',
      currency: json['currency']?.toString() ?? 'USD',
    );
  }

  // تحويل الكائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'demo_balance': demoBalance,
      'real_balance': realBalance,
      'account_type': accountType,
      'currency': currency,
    };
  }
}

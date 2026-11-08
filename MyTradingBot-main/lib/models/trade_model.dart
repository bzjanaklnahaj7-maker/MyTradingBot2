class TradeModel {
  final String orderId;
  final String assetId;
  final double amount;
  final String direction; // "call" أو "put"
  final int duration; // بالثواني
  final double profit;
  final String status; // "open" أو "closed"

  TradeModel({
    required this.orderId,
    required this.assetId,
    required this.amount,
    required this.direction,
    required this.duration,
    this.profit = 0.0,
    this.status = 'open',
  });

  // تحويل البيانات القادمة من السيرفر إلى كائن
  factory TradeModel.fromJson(Map<String, dynamic> json) {
    return TradeModel(
      orderId: json['order_id']?.toString() ?? '',
      assetId: json['asset']?.toString() ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      direction: json['direction']?.toString() ?? 'call',
      duration: json['duration'] ?? 60,
      profit: (json['profit'] ?? 0.0).toDouble(),
      status: json['status']?.toString() ?? 'open',
    );
  }

  // تحويل الكائن إلى JSON (لإرساله للسيرفر)
  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'asset': assetId,
      'amount': amount,
      'direction': direction,
      'duration': duration,
      'profit': profit,
      'status': status,
    };
  }
}

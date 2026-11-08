class InstrumentModel {
  final String assetId; // مثل EURUSD_otc
  final String name; // الاسم المعروض
  final double payout; // نسبة الربح (مثلاً 80.0)
  final bool isOpen; // هل الزوج متاح للتداول الآن؟

  InstrumentModel({
    required this.assetId,
    required this.name,
    required this.payout,
    required this.isOpen,
  });

  // تحويل البيانات القادمة من السيرفر إلى كائن
  factory InstrumentModel.fromJson(Map<String, dynamic> json) {
    return InstrumentModel(
      assetId: json['asset']?.toString() ?? '',
      name: json['name']?.toString() ?? json['asset']?.toString() ?? '',
      payout: (json['payout'] ?? 0.0).toDouble(),
      isOpen: json['is_open'] ?? json['isOpen'] ?? false,
    );
  }

  // تحويل الكائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'asset': assetId,
      'name': name,
      'payout': payout,
      'is_open': isOpen,
    };
  }
}

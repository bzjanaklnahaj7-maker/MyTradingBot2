import '../models/candle_model.dart';

class ChartEngine {
  final Map<String, List<CandleModel>> _candlesMap = {};

  // استقبال شمعة جديدة من السيرفر وتحديث الشارت
  void updateCandle(String assetId, Map<String, dynamic> candleData) {
    CandleModel newCandle = CandleModel(
      timestamp: (candleData['time'] ?? candleData['timestamp'] ?? DateTime.now().millisecondsSinceEpoch).toInt(),
      open: (candleData['open'] ?? 0.0).toDouble(),
      high: (candleData['high'] ?? 0.0).toDouble(),
      low: (candleData['low'] ?? 0.0).toDouble(),
      close: (candleData['close'] ?? 0.0).toDouble(),
    );

    if (!_candlesMap.containsKey(assetId)) {
      _candlesMap[assetId] = [];
    }

    List<CandleModel> assetCandles = _candlesMap[assetId]!;
    if (assetCandles.isEmpty || assetCandles.last.timestamp != newCandle.timestamp) {
      assetCandles.add(newCandle);
      if (assetCandles.length > 100) assetCandles.removeAt(0);
    } else {
      assetCandles[assetCandles.length - 1] = newCandle;
    }
  }

  List<CandleModel> getCandles(String assetId) => _candlesMap[assetId] ?? [];
}

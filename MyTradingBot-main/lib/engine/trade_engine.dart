import 'dart:math';
import '../models/trade_model.dart';
import 'payout_calculator.dart';

class TradeEngine {
  final Random _random = Random();
  
  double _baseAmount = 1.0;
  bool _isMartingale = false;
  double _currentAmount = 1.0;
  
  double _stopLossAmount = -50.0;
  double _stopProfitAmount = 100.0;
  double _totalProfitLoss = 0.0;
  
  List<TradeModel> openTrades = [];
  List<TradeModel> closedTrades = [];

  void setupBot({
    required double baseAmount,
    required bool isMartingale,
    required double stopLoss,
    required double stopProfit,
  }) {
    _baseAmount = baseAmount;
    _currentAmount = baseAmount;
    _isMartingale = isMartingale;
    _stopLossAmount = -stopLoss;
    _stopProfitAmount = stopProfit;
    _totalProfitLoss = 0.0;
  }

  TradeModel createNewTrade({
    required String assetId,
    required String direction,
    int duration = 300,
  }) {
    String orderId = DateTime.now().millisecondsSinceEpoch.toString();
    TradeModel newTrade = TradeModel(
      orderId: orderId,
      assetId: assetId,
      amount: _currentAmount,
      direction: direction,
      duration: duration,
      profit: 0.0,
      status: 'open',
    );
    openTrades.add(newTrade);
    return newTrade;
  }

  void processTradeResult(TradeModel trade, bool isWin, double payoutPercentage) {
    double profit;
    if (isWin) {
      profit = PayoutCalculator.calculateProfit(trade.amount, payoutPercentage);
      _currentAmount = _baseAmount;
    } else {
      profit = -trade.amount;
      if (_isMartingale) _currentAmount = _currentAmount * 2;
    }
    _totalProfitLoss += profit;

    TradeModel closed = TradeModel(
      orderId: trade.orderId,
      assetId: trade.assetId,
      amount: trade.amount,
      direction: trade.direction,
      duration: trade.duration,
      profit: profit,
      status: 'closed',
    );
    closedTrades.add(closed);
    openTrades.removeWhere((t) => t.orderId == trade.orderId);
  }

  bool shouldStopBot() {
    if (_totalProfitLoss <= _stopLossAmount) return true;
    if (_totalProfitLoss >= _stopProfitAmount) return true;
    return false;
  }

  double getTotalProfitLoss() => _totalProfitLoss;
  double getCurrentAmount() => _currentAmount;
}

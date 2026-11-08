import 'package:flutter/material.dart';
import '../models/trade_model.dart';

class HistoryView extends StatelessWidget {
  final List<TradeModel> openTrades;
  final List<TradeModel> closedTrades;

  const HistoryView({
    super.key,
    required this.openTrades,
    required this.closedTrades,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سجل الصفقات', style: TextStyle(color: Color(0xFFD4AF37))),
          centerTitle: true,
          backgroundColor: const Color(0xFF1A1A1A),
          bottom: const TabBar(
            indicatorColor: Color(0xFFD4AF37),
            labelColor: Color(0xFFD4AF37),
            tabs: [
              Tab(text: 'مفتوحة'),
              Tab(text: 'مغلقة'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTradesList(openTrades, 'لا توجد صفقات مفتوحة حالياً'),
            _buildTradesList(closedTrades, 'لا توجد صفقات مغلقة في السجل'),
          ],
        ),
      ),
    );
  }

  Widget _buildTradesList(List<TradeModel> trades, String emptyText) {
    if (trades.isEmpty) {
      return Center(child: Text(emptyText, style: const TextStyle(color: Colors.grey)));
    }
    
    return ListView.builder(
      itemCount: trades.length,
      itemBuilder: (context, index) {
        final trade = trades[index];
        bool isCall = trade.direction == 'call';
        
        return Card(
          color: const Color(0xFF1A1A1A),
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: Icon(
              isCall ? Icons.arrow_upward : Icons.arrow_downward,
              color: isCall ? Colors.green : Colors.red,
            ),
            title: Text('${trade.assetId} - \$${trade.amount}', 
              style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              'الربح: \$${trade.profit}',
              style: TextStyle(color: trade.profit >= 0 ? Colors.green : Colors.red),
            ),
            trailing: Text(trade.status, 
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        );
      },
    );
  }
}

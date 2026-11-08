import 'package:flutter/material.dart';
import '../models/instrument_model.dart';

class TradingDashboardScreen extends StatefulWidget {
  final List<InstrumentModel> availablePairs;
  final double currentBalance;
  final bool isConnected;
  final Function(bool isDemo, double amount, bool isMartingale, double stopLoss, double stopProfit, List<String> selectedPairs) onStartBot;
  final VoidCallback onStopBot;
  final VoidCallback onOpenChart;
  final List<String> logs;
  // 🌟 دالة جديدة لتبديل الحساب
  final Function(bool isDemo)? onSwitchAccount;

  const TradingDashboardScreen({
    super.key,
    required this.availablePairs,
    required this.currentBalance,
    required this.isConnected,
    required this.onStartBot,
    required this.onStopBot,
    required this.onOpenChart,
    required this.logs,
    this.onSwitchAccount,
  });

  @override
  State<TradingDashboardScreen> createState() => _TradingDashboardScreenState();
}

class _TradingDashboardScreenState extends State<TradingDashboardScreen> {
  bool isDemo = true;
  bool isMartingale = true;
  bool isBotRunning = false;
  double tradeAmount = 100.0;
  
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _stopLossController = TextEditingController(text: '3');
  final TextEditingController _stopProfitController = TextEditingController(text: '2');
  
  final Set<String> selectedPairs = {};
  final String _selectedStrategy = "استراتيجية البريكر بلوك";

  void _toggleBot() {
    if (selectedPairs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر زوجاً واحداً على الأقل!')),
      );
      return;
    }
    _showConfirmationDialog();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('تأكيد إعدادات التداول', style: TextStyle(color: Color(0xFFD4AF37))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الاستراتيجية: $_selectedStrategy', style: const TextStyle(color: Colors.white)),
              const Text('الفريم: 5 دقائق', style: TextStyle(color: Colors.white)),
              Text('الرصيد (${isDemo ? "DEMO" : "REAL"}): \$${widget.currentBalance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
              const Text('نسبة المخاطرة: 1%', style: TextStyle(color: Colors.white)),
              Text('مبلغ الصفقة: \$${tradeAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
              Text('المضاعفة: ${isMartingale ? "مفعلة" : "معطلة"}', style: const TextStyle(color: Colors.white)),
              Text('وقف الخسارة: ${_stopLossController.text} صفقات', style: const TextStyle(color: Colors.white)),
              Text('وقف الربح: ${_stopProfitController.text} صفقات', style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853)),
            onPressed: () {
              Navigator.pop(context);
              setState(() => isBotRunning = true);
              widget.onStartBot(
                isDemo, tradeAmount, isMartingale, 
                double.tryParse(_stopLossController.text) ?? 3.0,
                double.tryParse(_stopProfitController.text) ?? 2.0,
                selectedPairs.toList()
              );
            },
            child: const Text('تأكيد وبدء', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<InstrumentModel> filteredPairs = widget.availablePairs.where((p) {
      if (_searchController.text.isEmpty) return true;
      return p.assetId.toLowerCase().contains(_searchController.text.toLowerCase());
    }).toList();

    List<InstrumentModel> otcPairs = filteredPairs.where((p) => p.assetId.endsWith('_otc')).toList();
    List<InstrumentModel> stockPairs = filteredPairs.where((p) => !p.assetId.endsWith('_otc')).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF12161F),
      appBar: AppBar(
        title: const Text('التحكم الآلي', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF12161F),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                widget.isConnected ? 'Ping 🟢' : 'Ping 🔴',
                style: TextStyle(color: widget.isConnected ? Colors.green : Colors.red, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. شريط الحسابات والأرصدة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('REAL'),
                            selected: !isDemo,
                            selectedColor: Colors.green,
                            onSelected: (val) {
                              setState(() => isDemo = false);
                              // 🌟 استدعاء دالة تبديل الحساب
                              widget.onSwitchAccount?.call(false);
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('DEMO'),
                            selected: isDemo,
                            selectedColor: const Color(0xFFD4AF37),
                            onSelected: (val) {
                              setState(() => isDemo = true);
                              // 🌟 استدعاء دالة تبديل الحساب
                              widget.onSwitchAccount?.call(true);
                            },
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('السعر الحالي: 1.12012', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text('\$${widget.currentBalance.toStringAsFixed(2)}', 
                            style: const TextStyle(fontSize: 20, color: Color(0xFF00E5FF), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // 2. حقل البحث
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'بحث عن زوج (مثل: EUR)...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                  const SizedBox(height: 10),

                  // 3. تصفية الأزواج
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('اختر حتى 4 أزواج (${selectedPairs.length}/4)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFF00C853), borderRadius: BorderRadius.circular(5)),
                            child: Text('البورصة (${stockPairs.length})', style: const TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(5)),
                            child: Text('OTC (${otcPairs.length})', style: const TextStyle(color: Colors.black, fontSize: 10)),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 5),
                  
                  // 4. قائمة الأزواج
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView(
                      children: [
                        ...otcPairs.map((p) => _buildPairTile(p.assetId, p.payout)),
                        ...stockPairs.map((p) => _buildPairTile(p.assetId, p.payout)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 5. إعدادات المخاطرة
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('مبلغ الصفقة (\$):', style: TextStyle(color: Colors.white)),
                            Text('\$${tradeAmount.toStringAsFixed(1)}', style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Slider(
                          value: tradeAmount,
                          min: 1.0,
                          max: 500.0,
                          activeColor: const Color(0xFFD4AF37),
                          onChanged: (val) => setState(() => tradeAmount = val),
                        ),
                        SwitchListTile(
                          title: const Text('مضاعفة الخسارة (Martingale)', style: TextStyle(color: Colors.white, fontSize: 14)),
                          activeColor: const Color(0xFFD4AF37),
                          value: isMartingale,
                          onChanged: (val) => setState(() => isMartingale = val),
                          contentPadding: EdgeInsets.zero,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _stopLossController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(labelText: 'وقف الخسارة', labelStyle: TextStyle(color: Colors.grey), border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _stopProfitController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(labelText: 'وقف الربح', labelStyle: TextStyle(color: Colors.grey), border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 6. إعدادات التداول والاستراتيجية
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('⚙️ إعدادات التداول', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 14)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(5)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_selectedStrategy, style: const TextStyle(color: Colors.white, fontSize: 12)),
                              const Icon(Icons.arrow_drop_down, color: Colors.white),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '⚡ استراتيجية سريعة تلتقط الكسر المؤكد للمناطق القوية وتدخل مع الاتجاه فور تأكيده.',
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 7. مؤقت الشمعة
                  if (isBotRunning)
                    Container(
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: const Color(0xFFD4AF37)),
                      ),
                      child: const Column(
                        children: [
                          Text('مزامنة الدخول مع الشمعة', style: TextStyle(color: Color(0xFFD4AF37))),
                          SizedBox(height: 5),
                          Text('00:02:17', style: TextStyle(fontSize: 30, color: Colors.orange, fontWeight: FontWeight.bold)),
                          Text('يتم الانتظار حتى الاقتراب من إغلاق الشمعة...', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),

                  // 8. الأزرار
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: isBotRunning ? null : _toggleBot,
                    child: Text(isBotRunning ? 'جاري التداول...' : 'بدء التداول السريع 🚀', 
                      style: const TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853), 
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {}, 
                    child: const Text('التداول مع التعويض 🛡️', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD4AF37)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: widget.onOpenChart,
                    child: const Text('فتح شاشة الشارت المباشر 📈', 
                      style: TextStyle(fontSize: 16, color: Color(0xFFD4AF37))),
                  ),
                ],
              ),
            ),
          ),
          
          // 🌟 شاشة السجلات (Logs) في الأسفل
          Container(
            height: 100,
            padding: const EdgeInsets.all(8),
            color: Colors.black,
            child: ListView.builder(
              itemCount: widget.logs.length,
              itemBuilder: (context, index) {
                return Text(
                  widget.logs[index],
                  style: const TextStyle(fontSize: 10, color: Colors.greenAccent, fontFamily: 'monospace'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPairTile(String name, double payout) {
    return CheckboxListTile(
      dense: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 13)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
            child: Text('${payout.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.greenAccent, fontSize: 10)),
          ),
        ],
      ),
      value: selectedPairs.contains(name),
      activeColor: const Color(0xFFD4AF37),
      onChanged: (bool? value) {
        setState(() {
          if (value == true && selectedPairs.length < 4) {
            selectedPairs.add(name);
          } else if (value == false) {
            selectedPairs.remove(name);
          }
        });
      },
    );
  }
}

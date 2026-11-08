import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/app_config.dart';
import 'services/websocket_service.dart';
import 'services/api_service.dart';
import 'session/session_repository.dart';
import 'services/background_service.dart';
import 'session/device_fingerprint.dart';
import 'views/splash_view.dart';
import 'views/login_view.dart';
import 'views/trading_dashboard_screen.dart';
import 'views/charts_screen.dart';
import 'models/instrument_model.dart';
import 'engine/trade_engine.dart';
import 'engine/chart_engine.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.location.request();
  await Permission.notification.request();
  await BackgroundService.init();
  runApp(const AlkingApp());
}

class AlkingApp extends StatelessWidget {
  const AlkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF12161F),
        primaryColor: const Color(0xFFD4AF37),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          secondary: Color(0xFF00E5FF),
          surface: Color(0xFF1A1A1A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF12161F),
          foregroundColor: Color(0xFFD4AF37),
        ),
      ),
      home: const SplashView(nextScreen: MainWrapper()),
    );
  }
}

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  final WebsocketService _wsService = WebsocketService();
  final SessionRepository _sessionRepo = SessionRepository();
  final DeviceFingerprint _deviceFingerprint = DeviceFingerprint();
  final TradeEngine _tradeEngine = TradeEngine();
  final ChartEngine _chartEngine = ChartEngine();
  
  bool _isLoggedIn = false;
  bool _isConnected = false;
  double _currentBalance = 0.0;
  List<InstrumentModel> _availablePairs = [];
  List<String> _logs = [];
  
  String _sessionToken = "";
  String _fullCookie = "";
  Timer? _tradingTimer;
  bool _isBotRunning = false;
  bool _isDemo = true;

  @override
  void initState() {
    super.initState();
    
    _wsService.onLog = (msg) {
      if (mounted) setState(() => _logs.add(msg));
    };
    
    _wsService.onConnected = () {
      if (mounted) setState(() => _isConnected = true);
      _logs.add("✅ [CONNECTED] تم الاتصال بالسيرفر.");
      _logs.add("📤 [SEND] إرسال authorization...");
      _wsService.sendAuthorization(isDemo: _isDemo);
    };
    
    _wsService.onDisconnected = () {
      if (mounted) setState(() => _isConnected = false);
      _logs.add("❌ [DISCONNECTED] تم قطع الاتصال.");
    };
    
    _wsService.onEventReceived = (event, data) {
      _handleServerEvent(event, data);
    };
  }

  Future<void> _fetchBalance() async {
    double bal = await ApiService.getBalance(_sessionToken);
    if (mounted) setState(() => _currentBalance = bal);
  }

  void _handleServerEvent(String event, dynamic data) {
    _logs.add("📌 [EVENT]: $event | TYPE: ${data.runtimeType}");
    
    if (event == 'authorization') {
      if (data is Map && data['isSuccessful'] == true) {
        _logs.add("✅ تم تأكيد التصريح بنجاح! جاري طلب البيانات...");
        _wsService.requestInstruments();
        _fetchBalance();
      } else {
        _logs.add("❌ فشل التصريح: السيرفر رفض التوكن. البيانات: $data");
      }
    }
    else if (event == 'balance' || event == 'balance/list') {
      if (data is Map) {
        double bal = (data['demo'] ?? data['real'] ?? data['balance'] ?? 0.0).toDouble();
        if (mounted) setState(() => _currentBalance = bal);
      }
    } 
    else if (event == '' && data is List) {
      List<InstrumentModel> pairs = [];
      for (var item in data) {
        if (item is List && item.length > 2) {
          pairs.add(InstrumentModel(
            assetId: item[1].toString(), 
            name: item[2].toString(), 
            payout: 0.0,
            isOpen: true,
          ));
        }
      }
      if (mounted) setState(() => _availablePairs = pairs);
    }
    else if (event == 'orders/opened/list') {
      _logs.add("✅ تم فتح الصفقة بنجاح.");
    }
    else if (event == 'orders/closed/list') {
      if (data is List && data.isNotEmpty) {
        var closedOrder = data.first;
        double profit = (closedOrder['profit'] ?? 0.0).toDouble();
        bool isWin = profit > 0;
        _logs.add(isWin ? "✅ صفقة رابحة: +\$${profit.toStringAsFixed(2)}" : "❌ صفقة خاسرة: \$${profit.toStringAsFixed(2)}");
      }
    }
    else if (event == 'orders/error') {
      _logs.add("⚠️ خطأ في الصفقة: $data");
    }
    else if (event == 'authorization/reject' || event == '451') {
      _logs.add("❌ السيرفر رفض التصريح. تأكد من isDemo أو أعد سحب التوكن.");
    }
  }

  Future<void> _onLoginSuccess(String token, String fullCookie, bool isDemo) async {
    _sessionToken = token;
    _fullCookie = fullCookie;
    _isDemo = isDemo;
    
    String deviceId = await _deviceFingerprint.getOrCreateDeviceId();
    await _sessionRepo.saveSession(cookie: fullCookie, token: token, accountType: isDemo ? 'DEMO' : 'REAL');
    
    _wsService.connect(token, fullCookie, deviceId, isDemo: isDemo);
    
    setState(() => _isLoggedIn = true);
  }

  // 🌟 دالة جديدة لتبديل الحساب
  void _changeAccountType(bool isDemo) {
    _isDemo = isDemo;
    _logs.add("🔄 تم التبديل إلى ${isDemo ? 'DEMO' : 'REAL'}");
    if (_wsService.isConnected) {
      _wsService.sendAuthorization(isDemo: isDemo);
    }
  }

  void _startBot(bool isDemo, double amount, bool isMartingale, double stopLoss, double stopProfit, List<String> selectedPairs) {
    _isDemo = isDemo;
    _tradeEngine.setupBot(
      baseAmount: amount,
      isMartingale: isMartingale,
      stopLoss: stopLoss,
      stopProfit: stopProfit,
    );
    
    _isBotRunning = true;
    _logs.add("🚀 بدأ البوت (فريم 5 دقائق)...");

    _tradingTimer = Timer.periodic(const Duration(seconds: 300), (timer) async {
      if (!_isBotRunning) {
        timer.cancel();
        return;
      }

      if (_tradeEngine.shouldStopBot()) {
        _logs.add("🛑 تم إيقاف البوت: وصلنا لوقف الخسارة/الربح.");
        _stopBot();
        return;
      }

      if (selectedPairs.isEmpty) return;
      String pair = selectedPairs[DateTime.now().millisecondsSinceEpoch % selectedPairs.length];
      String action = DateTime.now().millisecondsSinceEpoch % 2 == 0 ? "call" : "put";
      
      var trade = _tradeEngine.createNewTrade(assetId: pair, direction: action);
      
      _logs.add("⚡ فتح صفقة: ${action.toUpperCase()} على $pair بمبلغ \$${trade.amount}");
      
      _wsService.openOrder(
        asset: pair,
        amount: trade.amount,
        action: action,
        isDemo: _isDemo,
      );
    });
  }

  void _stopBot() {
    _isBotRunning = false;
    _tradingTimer?.cancel();
    _wsService.disconnect();
    BackgroundService.stopService();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return LoginView(onLoginSuccess: _onLoginSuccess);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF12161F),
      appBar: AppBar(
        title: const Text('التحكم الآلي', style: TextStyle(color: Color(0xFFD4AF37))),
        centerTitle: true,
        backgroundColor: const Color(0xFF12161F),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt, color: Color(0xFFD4AF37)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => _LogConsoleView(logs: _logs),
              ));
            },
          ),
        ],
      ),
      body: TradingDashboardScreen(
        availablePairs: _availablePairs,
        currentBalance: _currentBalance,
        isConnected: _isConnected,
        onStartBot: _startBot,
        onStopBot: _stopBot,
        onOpenChart: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => ChartsScreen(
              assetId: 'EURUSD_otc',
              platformUrl: _isDemo ? 'https://quotex.com/ar/demo-trade' : 'https://quotex.com/ar/trade',
            ),
          ));
        },
        logs: _logs,
        // 🌟 تمرير دالة التبديل
        onSwitchAccount: _changeAccountType,
      ),
    );
  }
}

class _LogConsoleView extends StatelessWidget {
  final List<String> logs;

  const _LogConsoleView({required this.logs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجلات الاتصال (RAW)', style: TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: const Color(0xFF12161F),
      ),
      body: Container(
        color: Colors.black,
        child: ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                log,
                style: TextStyle(
                  color: log.contains('📥') ? Colors.greenAccent : 
                         log.contains('🚨') || log.contains('❌') ? Colors.redAccent : Colors.white70,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

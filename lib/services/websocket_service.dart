import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebsocketService {
  IO.Socket? _socket;
  bool _isConnected = false;
  String _token = "";
  String _fullCookie = "";
  String _deviceId = "";
  bool _isDemo = true;

  bool get isConnected => _isConnected;

  void Function(String event, dynamic data)? onEventReceived;
  void Function(String message)? onLog;
  void Function()? onConnected;
  void Function()? onDisconnected;

  void connect(String token, String fullCookie, String deviceId, {bool isDemo = true}) {
    _token = token;
    _fullCookie = fullCookie;
    _deviceId = deviceId;
    _isDemo = isDemo;

    try {
      onLog?.call("⏳ جاري الاتصال بسيرفر Quotex (Socket.IO)...");

      _socket = IO.io('https://ws2.quotex.com', 
        IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/socket.io/')
          .setQuery({'EIO': '4', 'transport': 'websocket'})
          .setExtraHeaders({
            'Cookie': _fullCookie,
            'User-Agent': 'Mozilla/5.0 (Linux; Android 12; Pixel 4 Build/SP2A.220505.008; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/95.0.4638.74 Mobile Safari/537.36',
          })
          .disableAutoConnect()
          .build()
      );

      _socket!.connect();

      _socket!.onConnect((_) {
        _isConnected = true;
        onLog?.call("✅ [CONNECTED] تم الاتصال بالسيرفر (Socket.IO).");
        onConnected?.call();
      });

      _socket!.onConnectError((error) {
        onLog?.call("🚨 [SOCKET_ERROR]: $error");
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        onLog?.call("⚠️ [DISCONNECTED] تم قطع الاتصال.");
        onDisconnected?.call();
      });

      // 🌟 استقبال كل الأحداث (بما فيها المصفوفة الخام)
      _socket!.onAny((event, data) {
        onLog?.call("📥 [EVENT]: $event | DATA: $data");
        onEventReceived?.call(event, data);
      });

    } catch (e) {
      onLog?.call("❌ فشل إنشاء الاتصال: $e");
    }
  }

  void sendEvent(String event, [dynamic data]) {
    if (_socket != null) {
      _socket!.emit(event, data);
    }
  }

  // 🌟 إرسال التصريح (بدون deviceCode)
  void sendAuthorization({required bool isDemo}) {
    _isDemo = isDemo;
    sendEvent('authorization', {
      "session": _token,
      "isDemo": isDemo ? 1 : 0,
      "tournamentId": 0,
    });
  }

  void requestInstruments({String asset = 'EURUSD_otc', int period = 60}) {
    sendEvent('instruments/update', {
      'asset': asset,
      'period': period,
    });
  }

  void openOrder({
    required String asset,
    required double amount,
    required String action,
    required bool isDemo,
  }) {
    final requestId = DateTime.now().millisecondsSinceEpoch;
    sendEvent('orders/open', {
      'asset': asset,
      'amount': amount,
      'time': 300,
      'action': action,
      'isDemo': isDemo ? 1 : 0,
      'tournamentId': 0,
      'requestId': requestId,
      'optionType': 1,
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
    onLog?.call("🛑 تم قطع الاتصال.");
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebsocketService {
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _isConnecting = false;
  String _token = "";
  String _fullCookie = "";
  String _deviceId = "";
  bool _isDemo = true; // 🌟 تخزين حالة الحساب

  void Function(String event, dynamic data)? onEventReceived;
  void Function(String message)? onLog;
  void Function()? onConnected;
  void Function()? onDisconnected;

  // 🌟 تعديل: استقبال isDemo
  void connect(String token, String fullCookie, String deviceId, {bool isDemo = true}) {
    _token = token;
    _fullCookie = fullCookie;
    _deviceId = deviceId;
    _isDemo = isDemo; // تخزين القيمة
    _isConnecting = true;

    try {
      onLog?.call("⏳ جاري الاتصال بسيرفر Quotex...");
      
      final uri = Uri.parse('wss://ws2.quotex.com/socket.io/?EIO=4&transport=websocket');
      
      _channel = IOWebSocketChannel.connect(
        uri,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10)',
          'Origin': 'https://quotex.com',
          'Cookie': _fullCookie,
        },
        pingInterval: const Duration(seconds: 25),
      );

      _channel!.stream.listen(
        (dynamic message) {
          String textMessage = "";
          if (message is String) {
            textMessage = message;
          } else if (message is List<int>) {
            try {
              textMessage = utf8.decode(message);
            } catch (e) {
              onLog?.call("⚠️ فشل فك تشفير رسالة ثنائية: $e");
              return;
            }
          }

          onLog?.call("📥 [RAW]: $textMessage");
          _handleMessage(textMessage);
        },
        onError: (error) {
          onLog?.call("🚨 [SOCKET_ERROR]: $error");
          _handleDisconnect();
        },
        onDone: () {
          onLog?.call("⚠️ تم إغلاق الاتصال. كود الإغلاق: ${_channel?.closeCode}");
          _handleDisconnect();
        },
      );

    } catch (e) {
      onLog?.call("❌ فشل إنشاء الاتصال: $e");
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _isConnecting = false;
    onDisconnected?.call();
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (!_isConnecting) {
        onLog?.call("🔄 جاري إعادة الاتصال...");
        connect(_token, _fullCookie, _deviceId, isDemo: _isDemo);
      }
    });
  }

  void _handleMessage(String message) {
    if (message.startsWith('0')) {
      _channel?.sink.add('40');
    } else if (message.startsWith('40')) {
      _isConnecting = false;
      onConnected?.call();
      _startHeartbeat();
    } else if (message == '2') {
      _channel?.sink.add('3');
    } else if (message.startsWith('42')) {
      try {
        String jsonString = message.substring(2);
        List<dynamic> parsed = jsonDecode(jsonString);
        if (parsed.isNotEmpty) {
          String event = parsed[0];
          dynamic data = parsed.length > 1 ? parsed[1] : null;
          onLog?.call("📌 [EVENT]: $event | DATA: $data");
          onEventReceived?.call(event, data);
        }
      } catch (e) {
        onLog?.call("⚠️ [PARSE_ERROR]: $e");
      }
    } 
    else if (message.startsWith('[')) {
      try {
        dynamic parsed = jsonDecode(message);
        if (parsed is List) {
           onLog?.call("📌 [RAW ARRAY]: استلام مصفوفة بيانات");
           onEventReceived?.call("", parsed);
        }
      } catch (e) {
         onLog?.call("⚠️ [PARSE_ERROR_ARRAY]: $e");
      }
    }
    else if (message.startsWith('451') || message.contains('authorization/reject')) {
      onLog?.call("❌ خطأ 451/رفض: السيرفر رفض التصريح. تأكد من التوكن أو isDemo.");
    }
  }

  void sendEvent(String event, [dynamic data]) {
    if (_channel != null) {
      List<dynamic> payload = data != null ? [event, data] : [event];
      String jsonString = jsonEncode(payload);
      _channel!.sink.add('42$jsonString');
    }
  }

  // 🌟 استخدام _isDemo في التصريح
  void sendAuthorization() {
    sendEvent('authorization', {
      "session": _token,
      "isDemo": _isDemo ? 1 : 0,
      "tournamentId": 0
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

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_channel != null) {
        sendEvent('tick');
      } else {
        timer.cancel();
      }
    });
  }

  void disconnect() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    onLog?.call("🛑 تم قطع الاتصال.");
  }
}

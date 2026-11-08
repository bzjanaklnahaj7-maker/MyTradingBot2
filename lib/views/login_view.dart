import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginView extends StatefulWidget {
  final Function(String token, String fullCookie, bool isDemo) onLoginSuccess;

  const LoginView({super.key, required this.onLoginSuccess});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  InAppWebViewController? _controller;

  Future<void> _extractTokenAndProceed(String currentUrl) async {
    try {
      // 🌟 1. تأخير 5 ثوانٍ (كما يفعل تطبيق صديقك)
      debugPrint("⏳ ننتظر 5 ثوانٍ لاستقرار الجلسة...");
      await Future.delayed(const Duration(seconds: 5));
      
      // 2. تحديد isDemo تلقائياً من الرابط
      bool isDemo = currentUrl.contains('/demo-trade');
      
      // 3. سحب الكوكيز
      final cookieManager = CookieManager.instance();
      
      await cookieManager.deleteCookie(
        url: WebUri('https://quotex.com'),
        name: 'i_need_to_call_flush_dummy',
      );
      
      List<Cookie> cookies = await cookieManager.getCookies(url: WebUri('https://quotex.com'));
      cookies.addAll(await cookieManager.getCookies(url: WebUri('https://quotex.com/ar/trade')));
      cookies.addAll(await cookieManager.getCookies(url: WebUri('https://quotex.com/ar/demo-trade')));
      
      String token = "";
      String fullCookie = "";
      
      for (var cookie in cookies) {
        String name = cookie.name.toLowerCase();
        fullCookie += "${cookie.name}=${cookie.value}; ";
        // البحث عن qtx_session_token أو ssid
        if (name.contains('session') || name.contains('token') || name.contains('ssid')) {
          token = cookie.value;
        }
      }
      
      debugPrint("========== 🍪 الكوكيز ==========");
      debugPrint("TOKEN: $token");
      debugPrint("FULL_COOKIE: $fullCookie");
      debugPrint("IS_DEMO: $isDemo");
      debugPrint("=================================");

      if (token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('qtx_session_token', token);
        await prefs.setString('full_cookie', fullCookie);
        
        widget.onLoginSuccess(token, fullCookie, isDemo); 
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⚠️ فشل سحب التوكن. تأكد من تسجيل الدخول.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ خطأ في سحب الجلسة: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول Quotex', style: TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: const Color(0xFF12161F),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.vpn_key, color: Color(0xFFD4AF37)),
            onPressed: () async {
              Uri? currentUrl = await _controller?.getUrl();
              if (currentUrl != null) await _extractTokenAndProceed(currentUrl.toString());
            },
            tooltip: "اتصال يدوي",
          ),
        ],
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri('https://quotex.com/ar/sign-in')),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false,
          javaScriptCanOpenWindowsAutomatically: true,
          supportMultipleWindows: true,
          domStorageEnabled: true,
          databaseEnabled: true,
          clearCache: false,
          incognito: false,
          useHybridComposition: true,
          userAgent: "Mozilla/5.0 (Linux; Android 12; Pixel 4 Build/SP2A.220505.008; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/95.0.4638.74 Mobile Safari/537.36",
        ),
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          return NavigationActionPolicy.ALLOW;
        },
        onCreateWindow: (controller, createWindowRequest) async {
          if (createWindowRequest.request.url != null) {
            controller.loadUrl(urlRequest: createWindowRequest.request);
          }
          return true;
        },
        onWebViewCreated: (webViewController) {
          _controller = webViewController;
        },
        onLoadStop: (controller, url) async {
          if (url != null) {
            String urlString = url.toString();
            if (urlString.contains('/trade') || urlString.contains('/demo-trade')) {
              // 🌟 استدعاء الدالة (التي تحتوي على التأخير 5 ثوانٍ)
              await _extractTokenAndProceed(urlString);
            }
          }
        },
      ),
    );
  }
}

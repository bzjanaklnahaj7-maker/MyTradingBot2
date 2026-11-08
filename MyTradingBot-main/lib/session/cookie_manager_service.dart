import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../core/app_config.dart';

class CookieManagerService extends StatefulWidget {
  final Function(String cookieHeader, String token) onCookiesExtracted;
  final VoidCallback onError;

  const CookieManagerService({
    super.key,
    required this.onCookiesExtracted,
    required this.onError,
  });

  @override
  State<CookieManagerService> createState() => _CookieManagerServiceState();
}

class _CookieManagerServiceState extends State<CookieManagerService> {
  InAppWebViewController? _controller;
  bool _isLoading = true;

  // دالة سحب الكوكيز
  Future<void> _extractCookies(String currentUrl) async {
    try {
      // تأخير بسيط لضمان استقرار الكوكيز
      await Future.delayed(const Duration(seconds: 5));

      CookieManager cookieManager = CookieManager.instance();
      
      // سحب الكوكيز من جميع النطاقات المحتملة
      List<Cookie> cookiesQuotex = await cookieManager.getCookies(url: WebUri('https://quotex.com'));
      List<Cookie> cookiesQx = await cookieManager.getCookies(url: WebUri('https://qxbroker.com'));
      
      List<Cookie> allCookies = [...cookiesQuotex, ...cookiesQx];

      String sessionToken = "";
      String allCookiesStr = "";
      
      for (var cookie in allCookies) {
        if (cookie.name != null && cookie.value != null) {
          allCookiesStr += "${cookie.name}=${cookie.value}; ";
          
          String name = cookie.name.toLowerCase();
          if (name == 'ssid' || name.contains('session') || name.contains('token')) {
            if (sessionToken.isEmpty) {
              sessionToken = cookie.value;
            }
          }
        }
      }

      if (sessionToken.isNotEmpty && allCookiesStr.isNotEmpty) {
        // تم سحب الكوكيز بنجاح، نرسلها للواجهة
        widget.onCookiesExtracted(allCookiesStr, sessionToken);
      } else {
        widget.onError();
      }
    } catch (e) {
      widget.onError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول Quotex', style: TextStyle(color: Color(0xFFD4AF37))),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.vpn_key, color: Color(0xFFD4AF37)),
            onPressed: () async {
              Uri? currentUrl = await _controller?.getUrl();
              if (currentUrl != null) _extractCookies(currentUrl.toString());
            },
            tooltip: "اتصال يدوي إجباري",
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri('${AppConfig.baseUrl}/ar/sign-in')),
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
              userAgent: AppConfig.userAgent, // استخدام البصمة الحقيقية
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
              setState(() => _isLoading = false);
              
              if (url != null) {
                if (url.toString().contains('/trade') || url.toString().contains('/demo-trade')) {
                  _extractCookies(url.toString());
                }
              }
            },
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
        ],
      ),
    );
  }
}

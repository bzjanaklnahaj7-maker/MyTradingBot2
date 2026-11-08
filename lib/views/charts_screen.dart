import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ChartsScreen extends StatelessWidget {
  final String assetId;
  // نمرر رابط المنصة بناءً على نوع الحساب
  final String platformUrl;

  const ChartsScreen({
    super.key,
    required this.assetId,
    required this.platformUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('منصة التداول', style: TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: const Color(0xFF12161F),
        centerTitle: true,
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(platformUrl)),
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
          userAgent: "Mozilla/5.0 (Linux; Android 11; RMX3261 Build/RP1A.201005.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.132 Mobile Safari/537.36",
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
      ),
    );
  }
}

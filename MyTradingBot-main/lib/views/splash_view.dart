import 'dart:async';
import 'package:flutter/material.dart';
import '../core/app_config.dart';

class SplashView extends StatefulWidget {
  final Widget nextScreen;
  const SplashView({super.key, required this.nextScreen});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => widget.nextScreen),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12161F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.monetization_on, size: 100, color: Color(0xFFD4AF37)),
            const SizedBox(height: 20),
            Text(
              AppConfig.appName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37), letterSpacing: 2),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Color(0xFFD4AF37)),
          ],
        ),
      ),
    );
  }
}

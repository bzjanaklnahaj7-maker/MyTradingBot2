import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<double> getBalance(String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://quotex.com/api/client/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Cookie': 'qtx_session_token=$token',
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10)',
          'Origin': 'https://quotex.com',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        double bal = (data['demo_balance'] ?? data['real_balance'] ?? data['balance'] ?? 0.0).toDouble();
        return bal;
      } else {
        return 0.0;
      }
    } catch (e) {
      return 0.0;
    }
  }
}

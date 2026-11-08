import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/balance_model.dart';
import '../models/instrument_model.dart';

class CacheManager {
  static const String _keyBalanceCache = 'ws_cache_balance_v1';
  static const String _keyInstrumentsCache = 'ws_cache_instruments_v1';

  // 1. حفظ الرصيد في الكاش
  Future<void> cacheBalance(BalanceModel balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBalanceCache, jsonEncode(balance.toJson()));
  }

  // 2. استرجاع الرصيد من الكاش
  Future<BalanceModel?> getCachedBalance() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonStr = prefs.getString(_keyBalanceCache);
    if (jsonStr != null) {
      return BalanceModel.fromJson(jsonDecode(jsonStr));
    }
    return null;
  }

  // 3. حفظ الأزواج في الكاش
  Future<void> cacheInstruments(List<InstrumentModel> instruments) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonList = instruments.map((i) => i.toJson()).toList();
    await prefs.setString(_keyInstrumentsCache, jsonEncode(jsonList));
  }

  // 4. استرجاع الأزواج من الكاش
  Future<List<InstrumentModel>> getCachedInstruments() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonStr = prefs.getString(_keyInstrumentsCache);
    if (jsonStr != null) {
      List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.map((json) => InstrumentModel.fromJson(json)).toList();
    }
    return [];
  }

  // 5. مسح الكاش بالكامل
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyBalanceCache);
    await prefs.remove(_keyInstrumentsCache);
  }
}

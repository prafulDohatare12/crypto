import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/prefs_keys.dart';
import '../api/coingecko_api.dart';
import '../models/holding.dart';

class PortfolioRepo {
  final CoinGeckoApi api;
  PortfolioRepo(this.api);

  Future<List<Holding>> loadPortfolio() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final s = sp.getString(PrefsKeys.portfolioJson);
      if (s == null) return [];
      return Holding.decodeList(s);
    } catch (e) {
      return [];
    }
  }

  Future<void> savePortfolio(List<Holding> list) async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(PrefsKeys.portfolioJson, Holding.encodeList(list));
    } catch (_) {}
  }

  Future<Map<String, double>> fetchPricesUSD(List<String> coinIds) async {
    final m = await api.getSimplePrices(coinIds);
    return m.map<String, double>(
      (k, v) => MapEntry(k, (v['usd'] as num).toDouble()),
    );
  }

  Future<void> cacheLastPrices(Map<String, double> prices) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(PrefsKeys.lastPricesJson, jsonEncode(prices));
  }

  Future<Map<String, double>> loadCachedPrices() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(PrefsKeys.lastPricesJson);
    if (s == null) return {};
    final m = Map<String, dynamic>.from(jsonDecode(s));
    return m.map<String, double>((k, v) => MapEntry(k, (v as num).toDouble()));
  }

  Future<Map<String, String>> fetchLogos(List<String> coinIds) async {
    return await api.getLogos(coinIds);
  }
}

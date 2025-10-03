import 'package:dio/dio.dart';

class CoinGeckoApi {
  final Dio _dio;
  CoinGeckoApi(Dio dio)
    : _dio = dio
        ..options = BaseOptions(baseUrl: 'https://api.coingecko.com/api/v3');

  Future<List<dynamic>> getCoinList() async {
    final res = await _dio.get('/coins/list');
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getSimplePrices(List<String> coinIds) async {
    if (coinIds.isEmpty) return {};
    final ids = coinIds.join(',');
    final res = await _dio.get(
      '/simple/price',
      queryParameters: {'ids': ids, 'vs_currencies': 'usd'},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, String>> getLogos(List<String> ids) async {
    if (ids.isEmpty) return {};
    final res = await _dio.get(
      '/coins/markets',
      queryParameters: {'vs_currency': 'usd', 'ids': ids.join(',')},
    );
    final list = res.data as List<dynamic>;
    final logos = <String, String>{};
    for (final c in list) {
      logos[c['id']] = c['image'];
    }
    return logos;
  }
}

import 'dart:convert';

class CoinMeta {
  final String id;
  final String symbol;
  final String name;

  CoinMeta({required this.id, required this.symbol, required this.name});

  factory CoinMeta.fromJson(Map<String, dynamic> j) =>
      CoinMeta(id: j['id'], symbol: j['symbol'], name: j['name']);

  Map<String, dynamic> toJson() => {'id': id, 'symbol': symbol, 'name': name};

  static String encodeList(List<CoinMeta> coins) =>
      jsonEncode(coins.map((e) => e.toJson()).toList());

  static List<CoinMeta> decodeList(String s) {
    final list = (jsonDecode(s) as List).cast<Map<String, dynamic>>();
    return list.map(CoinMeta.fromJson).toList();
  }
}

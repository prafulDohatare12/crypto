import 'dart:convert';

class Holding {
  final String coinId;
  final String symbol;
  final String name;
  final double qty;
  final String? logoUrl;

  Holding({
    required this.coinId,
    required this.symbol,
    required this.name,
    required this.qty,
    this.logoUrl,
  });

  Holding copyWith({double? qty, String? logoUrl}) => Holding(
    coinId: coinId,
    symbol: symbol,
    name: name,
    qty: qty ?? this.qty,
    logoUrl: logoUrl ?? this.logoUrl,
  );

  factory Holding.fromJson(Map<String, dynamic> j) => Holding(
    coinId: j['coinId'],
    symbol: j['symbol'],
    name: j['name'],
    qty: (j['qty'] as num).toDouble(),
    logoUrl: j['logoUrl'],
  );

  Map<String, dynamic> toJson() => {
    'coinId': coinId,
    'symbol': symbol,
    'name': name,
    'qty': qty,
    'logoUrl': logoUrl,
  };
  static String encodeList(List<Holding> list) {
    return jsonEncode(list.map((e) => e.toJson()).toList());
  }

  static List<Holding> decodeList(String s) {
    final raw = jsonDecode(s);
    if (raw is List) {
      return raw
          .map((e) => Holding.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return <Holding>[];
  }
}

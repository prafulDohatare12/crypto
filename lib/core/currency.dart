import 'package:intl/intl.dart';

final _usd = NumberFormat.simpleCurrency(name: 'USD');

String fmtUSD(num? v) => _usd.format((v ?? 0).toDouble());

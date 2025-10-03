import 'package:equatable/equatable.dart';
import '../../data/models/holding.dart';

enum PortfolioStatus { idle, loading, ready, refreshing, failed }

enum SortOption { name, value }

class PortfolioState extends Equatable {
  final PortfolioStatus status;
  final List<Holding> holdings;
  final Map<String, double> pricesUSD;
  final Map<String, double> previousPrices;
  final String error;
  final SortOption sortOption;

  const PortfolioState({
    this.status = PortfolioStatus.idle,
    this.holdings = const [],
    this.pricesUSD = const {},
    this.previousPrices = const {},
    this.error = '',
    this.sortOption = SortOption.name,
  });

  double get totalValue {
    double sum = 0;
    for (final h in holdings) {
      final p = pricesUSD[h.coinId] ?? 0;
      sum += h.qty * p;
    }
    return sum;
  }

  List<Holding> get sortedHoldings {
    final list = [...holdings];
    switch (sortOption) {
      case SortOption.name:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.value:
        list.sort((a, b) {
          final va = (pricesUSD[a.coinId] ?? 0) * a.qty;
          final vb = (pricesUSD[b.coinId] ?? 0) * b.qty;
          return vb.compareTo(va);
        });
        break;
    }
    return list;
  }

  PortfolioState copyWith({
    PortfolioStatus? status,
    List<Holding>? holdings,
    Map<String, double>? pricesUSD,
    Map<String, double>? previousPrices,
    String? error,
    SortOption? sortOption,
  }) => PortfolioState(
    status: status ?? this.status,
    holdings: holdings ?? this.holdings,
    pricesUSD: pricesUSD ?? this.pricesUSD,
    previousPrices: previousPrices ?? this.previousPrices,
    error: error ?? this.error,
    sortOption: sortOption ?? this.sortOption,
  );

  @override
  List<Object?> get props => [
    status,
    holdings,
    pricesUSD,
    previousPrices,
    error,
    sortOption,
  ];
}

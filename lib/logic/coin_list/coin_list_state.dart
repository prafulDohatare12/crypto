import 'package:crypto_portfolio/data/models/coinmetadata.dart';
import 'package:equatable/equatable.dart';

enum CoinListStatus { idle, loading, ready, failed }

class CoinListState extends Equatable {
  final CoinListStatus status;
  final List<CoinMeta> all;
  final List<CoinMeta> filtered;
  final String error;

  const CoinListState({
    this.status = CoinListStatus.idle,
    this.all = const [],
    this.filtered = const [],
    this.error = '',
  });

  CoinListState copyWith({
    CoinListStatus? status,
    List<CoinMeta>? all,
    List<CoinMeta>? filtered,
    String? error,
  }) => CoinListState(
    status: status ?? this.status,
    all: all ?? this.all,
    filtered: filtered ?? this.filtered,
    error: error ?? this.error,
  );

  @override
  List<Object?> get props => [status, all, filtered, error];
}

import 'package:equatable/equatable.dart';

abstract class CoinListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CoinListRequested extends CoinListEvent {}

class CoinSearchChanged extends CoinListEvent {
  final String query;
  CoinSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

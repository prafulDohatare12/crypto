import 'package:equatable/equatable.dart';
import '../../data/models/holding.dart';
import 'portfolio_state.dart';

abstract class PortfolioEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PortfolioLoaded extends PortfolioEvent {}

class PortfolioRefreshedPrices extends PortfolioEvent {}

class HoldingAddedOrUpdated extends PortfolioEvent {
  final Holding holding;
  HoldingAddedOrUpdated(this.holding);
  @override
  List<Object?> get props => [holding];
}

class HoldingRemoved extends PortfolioEvent {
  final String coinId;
  HoldingRemoved(this.coinId);
  @override
  List<Object?> get props => [coinId];
}

class PortfolioSortChanged extends PortfolioEvent {
  final SortOption option;
  PortfolioSortChanged(this.option);
  @override
  List<Object?> get props => [option];
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repo/portfolio_repo.dart';
import 'portfolio_event.dart';
import 'portfolio_state.dart';

class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final PortfolioRepo repo;
  PortfolioBloc(this.repo) : super(const PortfolioState()) {
    on<PortfolioLoaded>(_onLoaded);
    on<PortfolioRefreshedPrices>(_onRefresh);
    on<HoldingAddedOrUpdated>(_onAddOrUpdate);
    on<HoldingRemoved>(_onRemove);
    on<PortfolioSortChanged>(_onSortChanged);
  }

  Future<void> _onLoaded(
    PortfolioLoaded e,
    Emitter<PortfolioState> emit,
  ) async {
    emit(state.copyWith(status: PortfolioStatus.loading));
    try {
      final holdings = await repo.loadPortfolio();
      final cachedPrices = await repo.loadCachedPrices();
      emit(
        state.copyWith(
          status: PortfolioStatus.ready,
          holdings: holdings,
          pricesUSD: cachedPrices,
        ),
      );
      add(PortfolioRefreshedPrices());
    } catch (err) {
      emit(
        state.copyWith(status: PortfolioStatus.failed, error: err.toString()),
      );
    }
  }

  Future<void> _onRefresh(
    PortfolioRefreshedPrices e,
    Emitter<PortfolioState> emit,
  ) async {
    if (state.holdings.isEmpty) return;
    emit(state.copyWith(status: PortfolioStatus.refreshing));
    try {
      final ids = state.holdings.map((e) => e.coinId).toSet().toList();

      final newPrices = await repo.fetchPricesUSD(ids);
      final logos = await repo.fetchLogos(ids);

      emit(state.copyWith(previousPrices: state.pricesUSD));

      final updatedHoldings = state.holdings.map((h) {
        return h.copyWith(logoUrl: logos[h.coinId]);
      }).toList();

      await repo.savePortfolio(updatedHoldings);
      await repo.cacheLastPrices(newPrices);

      emit(
        state.copyWith(
          status: PortfolioStatus.ready,
          holdings: updatedHoldings,
          pricesUSD: newPrices,
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(status: PortfolioStatus.failed, error: err.toString()),
      );
    }
  }

  Future<void> _onAddOrUpdate(
    HoldingAddedOrUpdated e,
    Emitter<PortfolioState> emit,
  ) async {
    final existing = [...state.holdings];
    final idx = existing.indexWhere((h) => h.coinId == e.holding.coinId);
    if (idx >= 0) {
      existing[idx] = existing[idx].copyWith(qty: e.holding.qty);
    } else {
      existing.add(e.holding);
    }
    await repo.savePortfolio(existing);
    emit(state.copyWith(holdings: existing));
    add(PortfolioRefreshedPrices());
  }

  Future<void> _onRemove(HoldingRemoved e, Emitter<PortfolioState> emit) async {
    final updated = state.holdings.where((h) => h.coinId != e.coinId).toList();
    await repo.savePortfolio(updated);
    emit(state.copyWith(holdings: updated));
    add(PortfolioRefreshedPrices());
  }

  void _onSortChanged(PortfolioSortChanged e, Emitter<PortfolioState> emit) {
    emit(state.copyWith(sortOption: e.option));
  }
}

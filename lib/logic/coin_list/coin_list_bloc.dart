import 'dart:async';
import 'package:crypto_portfolio/data/models/coinmetadata.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/coin_repo.dart';
import 'coin_list_event.dart';
import 'coin_list_state.dart';

class CoinListBloc extends Bloc<CoinListEvent, CoinListState> {
  final CoinRepo repo;
  Timer? _debounce;

  CoinListBloc(this.repo) : super(const CoinListState()) {
    on<CoinListRequested>(_onRequested);
    on<CoinSearchChanged>(
      _onSearchChanged,
      transformer: _debounceTransformer(),
    );
  }

  Future<void> _onRequested(
    CoinListRequested e,
    Emitter<CoinListState> emit,
  ) async {
    emit(state.copyWith(status: CoinListStatus.loading));
    try {
      final list = await repo.loadOrFetchCatalog();
      emit(
        state.copyWith(
          status: CoinListStatus.ready,
          all: list,
          filtered: list.take(50).toList(),
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(status: CoinListStatus.failed, error: err.toString()),
      );
    }
  }

  EventTransformer<CoinSearchChanged>
  _debounceTransformer<T extends CoinSearchChanged>() {
    return (events, mapper) {
      return events.asyncExpand((event) {
        _debounce?.cancel();
        final controller = StreamController<CoinSearchChanged>();
        _debounce = Timer(const Duration(milliseconds: 250), () {
          controller.add(event);
          controller.close();
        });
        return controller.stream.asyncExpand(mapper);
      });
    };
  }

  Future<void> _onSearchChanged(
    CoinSearchChanged e,
    Emitter<CoinListState> emit,
  ) async {
    final q = e.query.trim().toLowerCase();
    if (q.isEmpty) {
      emit(state.copyWith(filtered: state.all.take(50).toList()));
      return;
    }

    final results = <CoinMeta>[];
    for (final c in state.all) {
      final sym = c.symbol.toLowerCase();
      final name = c.name.toLowerCase();
      if (sym.startsWith(q) || name.contains(q)) {
        results.add(c);
        if (results.length >= 50) break;
      }
    }
    emit(state.copyWith(filtered: results));
  }
}

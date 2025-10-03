import 'dart:async';
import 'package:crypto_portfolio/core/constant.dart';
import 'package:crypto_portfolio/core/currency.dart';
import 'package:crypto_portfolio/logic/portfolio/portfolio_bloc.dart';
import 'package:crypto_portfolio/logic/portfolio/portfolio_event.dart';
import 'package:crypto_portfolio/logic/portfolio/portfolio_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/holding_tile.dart';
import 'add_asset_sheet.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});
  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  Timer? _autoRefresh;

  @override
  void initState() {
    super.initState();
    context.read<PortfolioBloc>().add(PortfolioLoaded());
    _autoRefresh = Timer.periodic(const Duration(minutes: 3), (_) {
      if (mounted) {
        context.read<PortfolioBloc>().add(PortfolioRefreshedPrices());
      }
    });
  }

  @override
  void dispose() {
    _autoRefresh?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text(
          Constant.myPortfolio,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BlocListener<PortfolioBloc, PortfolioState>(
          listenWhen: (prev, curr) =>
              curr.status == PortfolioStatus.failed && curr.error.isNotEmpty,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("${Constant.error} ${state.error}"),
                backgroundColor: Colors.redAccent,
              ),
            );
          },
          child: BlocBuilder<PortfolioBloc, PortfolioState>(
            builder: (context, state) {
              if (state.status == PortfolioStatus.loading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              if (state.status == PortfolioStatus.failed) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        Constant.somethingWentWrong,
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => context.read<PortfolioBloc>().add(
                          PortfolioRefreshedPrices(),
                        ),
                        child: const Text(Constant.retry),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: Colors.blueAccent,
                onRefresh: () async => context.read<PortfolioBloc>().add(
                  PortfolioRefreshedPrices(),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 96),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [Colors.blueAccent, Colors.indigo.shade700],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            Constant.totalPortfolioValue,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            fmtUSD(state.totalValue),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.status == PortfolioStatus.refreshing
                                ? Constant.refreshingPrices
                                : Constant.upToDate,
                            style: const TextStyle(color: Colors.white60),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (state.holdings.isEmpty)
                      Column(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 90,
                            color: Colors.white54,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            Constant.noAssetsYet,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            Constant.tapToaddYourFirstCrypto,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      )
                    else
                      ...state.sortedHoldings.map(
                        (h) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: HoldingTile(
                            holding: h,
                            priceUSD: state.pricesUSD[h.coinId],
                            previousPrice: state.previousPrices[h.coinId],
                            onDelete: () => context.read<PortfolioBloc>().add(
                              HoldingRemoved(h.coinId),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (_) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, controller) => Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                controller: controller,
                child: const AddAssetSheet(),
              ),
            ),
          ),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(Constant.add, style: TextStyle(color: Colors.white)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

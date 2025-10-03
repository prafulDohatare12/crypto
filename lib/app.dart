import 'package:crypto_portfolio/core/constant.dart';
import 'package:crypto_portfolio/ui/portfolio/portfolio_page.dart';
import 'package:crypto_portfolio/ui/spalsh/spalsh_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/api/coingecko_api.dart';
import 'data/repo/coin_repo.dart';
import 'data/repo/portfolio_repo.dart';
import 'logic/coin_list/coin_list_bloc.dart';
import 'logic/portfolio/portfolio_bloc.dart';

class CryptoPortfolioApp extends StatelessWidget {
  const CryptoPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = Dio();
    final api = CoinGeckoApi(dio);
    final coinRepo = CoinRepo(api);
    final portfolioRepo = PortfolioRepo(api);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CoinListBloc(coinRepo)),
        BlocProvider(create: (_) => PortfolioBloc(portfolioRepo)),
      ],
      child: MaterialApp(
        title: Constant.cryptoPortfolio,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF3B82F6),
          useMaterial3: true,
        ),
        routes: {
          '/': (_) => const SplashPage(),
          '/portfolio': (_) => const PortfolioPage(),
        },
      ),
    );
  }
}

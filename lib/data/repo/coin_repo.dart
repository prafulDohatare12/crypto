import 'package:crypto_portfolio/data/models/coinmetadata.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/prefs_keys.dart';
import '../api/coingecko_api.dart';

class CoinRepo {
  final CoinGeckoApi api;
  CoinRepo(this.api);

  Future<List<CoinMeta>> loadOrFetchCatalog() async {
    final sp = await SharedPreferences.getInstance();
    final cached = sp.getString(PrefsKeys.coinCatalogJson);
    if (cached != null) {
      return CoinMeta.decodeList(cached);
    }

    final raw = await api.getCoinList();
    final list = raw
        .map(
          (e) => CoinMeta(
            id: e['id'],
            symbol: (e['symbol'] ?? '').toString(),
            name: (e['name'] ?? '').toString(),
          ),
        )
        .toList()
        .cast<CoinMeta>();
    await sp.setString(PrefsKeys.coinCatalogJson, CoinMeta.encodeList(list));
    return list;
  }

  Future<void> saveCatalog(List<CoinMeta> list) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(PrefsKeys.coinCatalogJson, CoinMeta.encodeList(list));
  }
}

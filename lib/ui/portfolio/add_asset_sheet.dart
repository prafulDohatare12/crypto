import 'package:crypto_portfolio/core/constant.dart';
import 'package:crypto_portfolio/data/models/holding.dart';
import 'package:crypto_portfolio/logic/coin_list/coin_list_bloc.dart';
import 'package:crypto_portfolio/logic/coin_list/coin_list_event.dart';
import 'package:crypto_portfolio/logic/coin_list/coin_list_state.dart';
import 'package:crypto_portfolio/logic/portfolio/portfolio_bloc.dart';
import 'package:crypto_portfolio/logic/portfolio/portfolio_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddAssetSheet extends StatefulWidget {
  const AddAssetSheet({super.key});

  @override
  State<AddAssetSheet> createState() => _AddAssetSheetState();
}

class _AddAssetSheetState extends State<AddAssetSheet> {
  final TextEditingController _search = TextEditingController();
  final TextEditingController _qty = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CoinListBloc>().add(CoinListRequested());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(Constant.add, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _search,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: Constant.searchCoinByNameOrSymbol,
                border: OutlineInputBorder(),
              ),
              onChanged: (v) =>
                  context.read<CoinListBloc>().add(CoinSearchChanged(v)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: BlocBuilder<CoinListBloc, CoinListState>(
                builder: (context, state) {
                  if (state.status == CoinListStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final list = state.filtered;
                  if (list.isEmpty) {
                    return const Center(child: Text(Constant.noResults));
                  }
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final c = list[i];
                      return ListTile(
                        title: Text('${c.name} (${c.symbol.toUpperCase()})'),
                        onTap: () {
                          _search.text =
                              '${c.name} (${c.symbol.toUpperCase()})';
                          _search.selection = TextSelection.collapsed(
                            offset: _search.text.length,
                          );
                          setState(() {
                            _selectedId = c.id;
                            _selectedName = c.name;
                            _selectedSymbol = c.symbol;
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _qty,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                hintText: Constant.quantity,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text(Constant.save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _selectedId;
  String? _selectedName;
  String? _selectedSymbol;

  void _save() {
    final id = _selectedId;
    final name = _selectedName;
    final symbol = _selectedSymbol;
    final qty = double.tryParse(_qty.text.trim());
    if (id == null || name == null || symbol == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(Constant.pleaseSelectACoin)));
      return;
    }
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Constant.enterAValidQuantity)),
      );
      return;
    }
    context.read<PortfolioBloc>().add(
      HoldingAddedOrUpdated(
        Holding(coinId: id, name: name, symbol: symbol, qty: qty),
      ),
    );
    Navigator.pop(context);
  }
}

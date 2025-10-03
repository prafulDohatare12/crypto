import 'package:flutter/material.dart';
import '../../core/currency.dart';
import '../../data/models/holding.dart';

class HoldingTile extends StatelessWidget {
  final Holding holding;
  final double? priceUSD;
  final double? previousPrice;
  final VoidCallback? onDelete;

  const HoldingTile({
    super.key,
    required this.holding,
    required this.priceUSD,
    this.previousPrice,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currentPrice = priceUSD ?? 0;
    final total = currentPrice * holding.qty;

    final old = previousPrice ?? currentPrice;
    final delta = currentPrice - old;

    Color deltaColor = Colors.grey;
    if (delta > 0) deltaColor = Colors.green;
    if (delta < 0) deltaColor = Colors.red;

    return Dismissible(
      key: ValueKey(holding.coinId),
      direction: onDelete == null
          ? DismissDirection.none
          : DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.redAccent,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: holding.logoUrl != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(holding.logoUrl!),
                  backgroundColor: Colors.transparent,
                )
              : CircleAvatar(child: Text(holding.symbol.toUpperCase()[0])),
          title: Text('${holding.name} (${holding.symbol.toUpperCase()})'),
          subtitle: Text(
            'Qty: ${holding.qty} • Price: ${fmtUSD(currentPrice)}',
            style: TextStyle(color: deltaColor),
          ),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                fmtUSD(total),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (delta != 0)
                Text(
                  delta > 0 ? '▲ ${fmtUSD(delta)}' : '▼ ${fmtUSD(delta.abs())}',
                  style: TextStyle(color: deltaColor, fontSize: 12),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

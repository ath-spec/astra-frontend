import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../stocks/data/stocks_models.dart';
import '../../../../stocks/data/stocks_providers.dart';
import '../../../data/mf_holdings_providers.dart';
import '../../../data/mf_transactions_models.dart';

/// Filter categories shown as chips on the Orders screen. A stock order and
/// an MF transaction are conceptually the same "thing happened" event, so
/// both sources are mapped into this shared set of categories.
enum OrderFeedFilter { all, buy, sip, sell, surplus }

/// Currently-selected filter chip on the Orders screen.
final ordersFeedFilterProvider =
    StateProvider<OrderFeedFilter>((ref) => OrderFeedFilter.all);

/// One row in the unified Orders feed — either a stock order or an MF
/// transaction, normalized to whatever [MfOrderItemCard] already expects.
class OrderFeedItem {
  const OrderFeedItem({
    required this.id,
    required this.date,
    required this.title,
    required this.typeLabel,
    required this.amount,
    required this.status,
    required this.category,
    required this.isExternal,
  });

  final String id;
  final DateTime date;
  final String title;
  final String typeLabel;
  final double amount;
  final String status;
  final OrderFeedFilter category;
  final bool isExternal;

  factory OrderFeedItem.fromStockOrder(StockOrderRecord order) {
    final isBuy = order.transactionType.toUpperCase() == 'BUY';
    final price = order.averagePrice > 0 ? order.averagePrice : order.price;
    final qty = order.filledQuantity > 0 ? order.filledQuantity : order.quantity;
    return OrderFeedItem(
      id: 'stock_${order.orderId}',
      date: order.timestamp,
      title: '${order.tradingSymbol} (${order.exchange})',
      typeLabel: order.transactionType,
      amount: price * (qty > 0 ? qty : 1),
      status: order.status,
      category: isBuy ? OrderFeedFilter.buy : OrderFeedFilter.sell,
      isExternal: false,
    );
  }

  factory OrderFeedItem.fromMfTransaction(MfTransaction txn) {
    final type = txn.transactionType.toUpperCase();
    final category = switch (type) {
      'SIP' => OrderFeedFilter.sip,
      'REDEEM' => OrderFeedFilter.surplus,
      _ => OrderFeedFilter.buy, // PURCHASE
    };
    return OrderFeedItem(
      id: 'mf_${txn.schemeCode}_${txn.transactionDateEpoch}',
      date: txn.transactionDate,
      title: txn.schemeName,
      typeLabel: type == 'PURCHASE' ? 'BUY' : type,
      amount: txn.amount,
      status: 'COMPLETE',
      category: category,
      isExternal: true,
    );
  }
}

/// Combines stock orders and MF transactions into a single, date-sorted
/// feed for the Orders screen.
final ordersFeedProvider = FutureProvider<List<OrderFeedItem>>((ref) async {
  final stockOrdersAsync = ref.watch(stocksOrdersProvider.future);
  final mfTxnsAsync = ref.watch(mfTransactionsProvider.future);

  final results = await Future.wait([stockOrdersAsync, mfTxnsAsync]);
  final stockOrders = results[0] as List<StockOrderRecord>;
  final mfTxns = results[1] as List<MfTransaction>;

  final items = <OrderFeedItem>[
    ...stockOrders.map(OrderFeedItem.fromStockOrder),
    ...mfTxns.map(OrderFeedItem.fromMfTransaction),
  ];
  items.sort((a, b) => b.date.compareTo(a.date));
  return items;
});

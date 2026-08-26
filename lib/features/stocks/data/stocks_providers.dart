import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/features/stocks/data/stocks_models.dart';
import 'package:astra_frontend/features/stocks/data/stocks_repository.dart';

final stocksRepositoryProvider = Provider<StocksRepository>((ref) {
  return StocksRepository(dioApiClient);
});

final stocksHoldingsProvider =
    FutureProvider<List<StockHoldingItem>>((ref) async {
  final repo = ref.watch(stocksRepositoryProvider);
  return repo.getHoldings();
});

final stocksOrdersProvider =
    FutureProvider<List<StockOrderRecord>>((ref) async {
  final repo = ref.watch(stocksRepositoryProvider);
  return repo.getOrders();
});

// ============================================================
// FILE: lib/features/transactions/data/transactions_repository.dart
// Wraps `GET /api/v1/analytics/spend/transactions`. The endpoint
// returns a flat, ungrouped, newest-first list; the date/category/
// merchant groupings served by this repository are all derived
// client-side from that raw list.
// ============================================================

import 'package:astra_frontend/core/network/api.dart';
import '../models/transaction_models.dart';

class TransactionsRepository {
  TransactionsRepository(this._client);

  final DioApiClient _client;

  /// Cache of the most recent unfiltered fetch, used so [fetchDetail] can
  /// look a transaction up by id without a dedicated by-id endpoint.
  List<TransactionItem>? _cache;

  /// Fetches transactions, optionally narrowed to one [category] or
  /// [merchant] (server-side filters). [days] defaults to 180 and is
  /// capped at 3650 by the backend.
  Future<List<TransactionItem>> fetchAll({String? category, String? merchant, int days = 180}) async {
    try {
      final response = await _client.dio.get(
        '/api/v1/analytics/spend/transactions',
        queryParameters: {
          if (category != null && category.isNotEmpty) 'category': category,
          if (merchant != null && merchant.isNotEmpty) 'merchant': merchant,
          'days': days,
        },
      );
      final items = _client
          .unwrapList(response.data as Map<String, dynamic>, TransactionListItem.fromJson)
          .map(TransactionItem.fromApiRow)
          .toList();
      if (category == null && merchant == null) {
        _cache = items;
      }
      return items;
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  Future<List<TransactionDateGroup>> fetchGrouped({String? category, String? merchant}) async {
    final items = await fetchAll(category: category, merchant: merchant);
    return _groupByDate(items);
  }

  Future<List<CategorySummary>> fetchCategories() async {
    final all = await fetchAll();
    final byCategory = <String, List<TransactionItem>>{};
    for (final t in all) {
      byCategory.putIfAbsent(t.category, () => []).add(t);
    }
    final summaries = byCategory.entries.map((e) {
      final total = e.value.fold<double>(0, (s, t) => s + t.amount);
      return CategorySummary(
        category: e.key,
        displayName: e.key,
        transactionCount: e.value.length,
        totalAmount: total,
      );
    }).toList();
    summaries.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return summaries;
  }

  Future<List<MerchantSummary>> fetchMerchants() async {
    final all = await fetchAll();
    final byMerchant = <String, List<TransactionItem>>{};
    for (final t in all) {
      byMerchant.putIfAbsent(t.merchant, () => []).add(t);
    }
    final summaries = byMerchant.entries.map((e) {
      final total = e.value.fold<double>(0, (s, t) => s + t.amount);
      return MerchantSummary(
        merchant: e.key,
        transactionCount: e.value.length,
        totalAmount: total,
      );
    }).toList();
    summaries.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return summaries;
  }

  /// Finds a transaction by id client-side. Returns null if it isn't in the
  /// cached/refetched list rather than fabricating a detail record.
  Future<TransactionDetail?> fetchDetail(String id) async {
    var all = _cache;
    if (all == null || all.every((t) => t.id != id)) {
      all = await fetchAll();
    }
    for (final item in all) {
      if (item.id == id) return TransactionDetail.fromItem(item);
    }
    return null;
  }

  List<TransactionDateGroup> _groupByDate(List<TransactionItem> items) {
    final sorted = [...items]..sort((a, b) => b.time.compareTo(a.time));
    final groups = <String, List<TransactionItem>>{};
    for (final item in sorted) {
      final key = '${item.time.year}-${item.time.month}-${item.time.day}';
      groups.putIfAbsent(key, () => []).add(item);
    }
    return groups.entries.map((e) {
      final total = e.value.fold<double>(0, (s, t) => s + (t.isDebit ? t.amount : -t.amount));
      return TransactionDateGroup(date: e.value.first.time, dailyTotal: total, items: e.value);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}

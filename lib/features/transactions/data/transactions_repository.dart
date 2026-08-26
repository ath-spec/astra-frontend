// ============================================================
// FILE: lib/features/transactions/data/transactions_repository.dart
// Mock data source for the Transactions feature. Generates a
// deterministic-looking set of transactions once, then serves
// filtered/grouped/paginated views over it — same async surface
// a real GET /v1/transactions repository would expose.
// ============================================================

import '../models/transaction_models.dart';

class TransactionsRepository {
  TransactionsRepository._();
  static final TransactionsRepository instance = TransactionsRepository._();

  List<TransactionItem>? _all;

  Future<List<TransactionItem>> fetchAll({String? category, String? merchant}) async {
    await Future.delayed(const Duration(milliseconds: 450));
    final all = _all ??= _generateMockTransactions();
    return all.where((t) {
      if (category != null && t.category != category) return false;
      if (merchant != null && t.merchant != merchant) return false;
      return true;
    }).toList();
  }

  Future<List<TransactionDateGroup>> fetchGrouped({String? category, String? merchant}) async {
    final items = await fetchAll(category: category, merchant: merchant);
    return _groupByDate(items);
  }

  Future<List<CategorySummary>> fetchCategories() async {
    await Future.delayed(const Duration(milliseconds: 350));
    final all = _all ??= _generateMockTransactions();
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
    await Future.delayed(const Duration(milliseconds: 350));
    final all = _all ??= _generateMockTransactions();
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

  Future<TransactionDetail> fetchDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final all = _all ??= _generateMockTransactions();
    final item = all.firstWhere((t) => t.id == id, orElse: () => all.first);
    return TransactionDetail(
      id: item.id,
      amount: item.amount,
      isDebit: item.isDebit,
      category: item.category,
      subcategory: null,
      description: '${item.title} purchase',
      merchantName: item.merchant,
      merchantCategory: item.category,
      transactionDate: item.time,
      referenceNumber: 'REF${item.id.padLeft(10, '0')}',
      accountNumberMasked: item.accountLast4 != null ? 'XXXXXX${item.accountLast4}' : null,
      bankName: item.bankName,
      status: item.status,
    );
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

  // ---------------------------------------------------------------
  // Dummy data generation. Field shapes mirror transaction_models.dart
  // 1:1 so a future `TransactionItem.fromJson(row)` drops in clean.
  // ---------------------------------------------------------------

  List<TransactionItem> _generateMockTransactions() {
    const merchants = <String, String>{
      'Zomato': 'Food & Dining',
      'Swiggy': 'Food & Dining',
      'Amazon': 'Shopping',
      'Flipkart': 'Shopping',
      'Uber': 'Transport',
      'Ola': 'Transport',
      'Netflix': 'Entertainment',
      'Spotify': 'Entertainment',
      'BESCOM': 'Bills & Utilities',
      'Airtel': 'Bills & Utilities',
      'Apollo Pharmacy': 'Health',
      'Decathlon': 'Shopping',
      'Starbucks': 'Food & Dining',
      'IRCTC': 'Transport',
    };

    final merchantNames = merchants.keys.toList();
    final now = DateTime.now();
    final items = <TransactionItem>[];

    var id = 1000;
    for (var dayOffset = 0; dayOffset < 45; dayOffset++) {
      final day = now.subtract(Duration(days: dayOffset));
      // 0-3 transactions a day, deterministic-ish via day-based pseudo-random.
      final txnCount = (dayOffset * 7) % 4;
      for (var i = 0; i < txnCount; i++) {
        final merchantIndex = (dayOffset * 3 + i * 5) % merchantNames.length;
        final merchant = merchantNames[merchantIndex];
        final category = merchants[merchant]!;
        final amount = (100 + ((dayOffset * 37 + i * 53) % 4500)).toDouble();
        final hour = 8 + ((dayOffset + i) % 13);
        id++;
        items.add(
          TransactionItem(
            id: id.toString(),
            title: merchant,
            subtitle: category,
            accountLast4: '482${(id % 3)}',
            bankName: id % 2 == 0 ? 'IDBI Bank' : 'HDFC Bank',
            time: DateTime(day.year, day.month, day.day, hour, (id * 7) % 60),
            amount: amount,
            isDebit: true,
            status: id % 23 == 0 ? TransactionStatus.pending : TransactionStatus.completed,
            category: category,
            merchant: merchant,
          ),
        );
      }
      // One salary credit a month.
      if (day.day == 1) {
        id++;
        items.add(
          TransactionItem(
            id: id.toString(),
            title: 'Salary Credit',
            subtitle: 'Income',
            accountLast4: '4821',
            bankName: 'IDBI Bank',
            time: DateTime(day.year, day.month, 1, 9, 0),
            amount: 85000,
            isDebit: false,
            status: TransactionStatus.completed,
            category: 'Income',
            merchant: 'Employer Pvt Ltd',
          ),
        );
      }
    }

    items.sort((a, b) => b.time.compareTo(a.time));
    return items;
  }
}

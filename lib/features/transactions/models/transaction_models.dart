// ============================================================
// FILE: lib/features/transactions/models/transaction_models.dart
// Transactions feature models, backed by
// GET /api/v1/analytics/spend/transactions.
// ============================================================

enum TransactionStatus { pending, completed, failed }

extension TransactionStatusX on TransactionStatus {
  static TransactionStatus fromString(String? value) {
    switch (value) {
      case 'pending':
        return TransactionStatus.pending;
      case 'failed':
        return TransactionStatus.failed;
      default:
        return TransactionStatus.completed;
    }
  }
}

/// Raw row as returned by `GET /api/v1/analytics/spend/transactions`.
/// `occurred_at` is epoch seconds (integer) — never an ISO string.
class TransactionListItem {
  final String id;
  final double amount;
  final bool isDebit; // type == "DEBIT" (vs "CREDIT")
  final String category;
  final String merchant;
  final DateTime occurredAt;

  const TransactionListItem({
    required this.id,
    required this.amount,
    required this.isDebit,
    required this.category,
    required this.merchant,
    required this.occurredAt,
  });

  factory TransactionListItem.fromJson(Map<String, dynamic> json) {
    final epochSeconds = (json['occurred_at'] as num?)?.toInt() ?? 0;
    return TransactionListItem(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      isDebit: (json['type'] as String? ?? 'DEBIT').toUpperCase() != 'CREDIT',
      category: json['category'] as String? ?? '',
      merchant: json['merchant'] as String? ?? '',
      occurredAt: DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000),
    );
  }
}

/// A single transaction row.
class TransactionItem {
  final String id;
  final String title; // merchant/payee display name
  final String subtitle; // category or description
  final String? accountLast4;
  final String? bankName;
  final DateTime time;
  final double amount;
  final bool isDebit;
  final TransactionStatus status;
  final String category;
  final String merchant;

  const TransactionItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.accountLast4,
    this.bankName,
    required this.time,
    required this.amount,
    required this.isDebit,
    required this.status,
    required this.category,
    required this.merchant,
  });

  /// Builds the UI-facing row from a raw `/analytics/spend/transactions` item.
  /// The endpoint has no title/subtitle/account/bank/status fields, so those
  /// are derived or left null — never fabricated.
  factory TransactionItem.fromApiRow(TransactionListItem raw) {
    return TransactionItem(
      id: raw.id,
      title: raw.merchant.isNotEmpty ? raw.merchant : raw.category,
      subtitle: raw.category,
      accountLast4: null,
      bankName: null,
      time: raw.occurredAt,
      amount: raw.amount,
      isDebit: raw.isDebit,
      status: TransactionStatus.completed,
      category: raw.category,
      merchant: raw.merchant,
    );
  }
}

/// A day's worth of transactions, pre-grouped for the date-grouped list.
class TransactionDateGroup {
  final DateTime date;
  final double dailyTotal;
  final List<TransactionItem> items;

  const TransactionDateGroup({
    required this.date,
    required this.dailyTotal,
    required this.items,
  });
}

/// Aggregate row for the "Categories" tab.
class CategorySummary {
  final String category;
  final String displayName;
  final int transactionCount;
  final double totalAmount;

  const CategorySummary({
    required this.category,
    required this.displayName,
    required this.transactionCount,
    required this.totalAmount,
  });
}

/// Aggregate row for the "Merchants" tab.
class MerchantSummary {
  final String merchant;
  final int transactionCount;
  final double totalAmount;

  const MerchantSummary({
    required this.merchant,
    required this.transactionCount,
    required this.totalAmount,
  });
}

/// Full detail record for a single transaction, shown on
/// TransactionDetailScreen.
class TransactionDetail {
  final String id;
  final double amount;
  final bool isDebit;
  final String category;
  final String? subcategory;
  final String? description;
  final String? merchantName;
  final String? merchantCategory;
  final DateTime transactionDate;
  final String? referenceNumber;
  final String? accountNumberMasked;
  final String? bankName;
  final TransactionStatus status;

  const TransactionDetail({
    required this.id,
    required this.amount,
    required this.isDebit,
    required this.category,
    this.subcategory,
    this.description,
    this.merchantName,
    this.merchantCategory,
    required this.transactionDate,
    this.referenceNumber,
    this.accountNumberMasked,
    this.bankName,
    required this.status,
  });

  /// There is no single-transaction-by-id endpoint. The detail screen finds
  /// the matching row client-side from an already-fetched list and derives
  /// the detail record from it — nothing here is fabricated.
  factory TransactionDetail.fromItem(TransactionItem item) {
    return TransactionDetail(
      id: item.id,
      amount: item.amount,
      isDebit: item.isDebit,
      category: item.category,
      subcategory: null,
      description: null,
      merchantName: item.merchant.isNotEmpty ? item.merchant : null,
      merchantCategory: item.category.isNotEmpty ? item.category : null,
      transactionDate: item.time,
      referenceNumber: null,
      accountNumberMasked: null,
      bankName: null,
      status: item.status,
    );
  }
}

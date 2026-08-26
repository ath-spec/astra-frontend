// ============================================================
// FILE: lib/features/transactions/models/transaction_models.dart
// Transactions feature models. Field names/json keys mirror the
// shape of a future GET /v1/transactions endpoint (paginated,
// filterable by category/merchant/month/year) so wiring a real
// API later only means replacing TransactionsRepository's bodies.
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

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? json['merchant_name'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? json['category_display_name'] as String? ?? '',
      accountLast4: json['account_last4'] as String?,
      bankName: json['bank_name'] as String?,
      time: DateTime.tryParse(json['transaction_time'] as String? ?? '') ?? DateTime.now(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      isDebit: (json['transaction_type'] as String? ?? 'debit') == 'debit',
      status: TransactionStatusX.fromString(json['status'] as String?),
      category: json['category'] as String? ?? '',
      merchant: json['merchant_name'] as String? ?? json['title'] as String? ?? '',
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

  factory CategorySummary.fromJson(Map<String, dynamic> json) {
    return CategorySummary(
      category: json['category'] as String? ?? '',
      displayName: json['display_name'] as String? ?? json['category'] as String? ?? '',
      transactionCount: json['transaction_count'] as int? ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
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

  factory MerchantSummary.fromJson(Map<String, dynamic> json) {
    return MerchantSummary(
      merchant: json['merchant'] as String? ?? '',
      transactionCount: json['transaction_count'] as int? ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
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

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    return TransactionDetail(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      isDebit: (json['transaction_type'] as String? ?? 'debit') == 'debit',
      category: json['category'] as String? ?? '',
      subcategory: json['subcategory'] as String?,
      description: json['description'] as String?,
      merchantName: json['merchant_name'] as String?,
      merchantCategory: json['merchant_category'] as String?,
      transactionDate: DateTime.tryParse(json['transaction_date'] as String? ?? '') ?? DateTime.now(),
      referenceNumber: json['reference_number'] as String?,
      accountNumberMasked: json['account_number_masked'] as String?,
      bankName: json['bank_name'] as String?,
      status: TransactionStatusX.fromString(json['status'] as String?),
    );
  }
}

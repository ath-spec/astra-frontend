// lib/models/category_summary.dart
class CategorySummary {
  final String categoryName;
  final String displayName;
  final String description;
  final double totalAmount;
  final double percentage;
  final int transactionCount;
  final double averageTransactionAmount;
  final String period;
  final List<CategoryTransaction> recentTransactions;
  final CategoryBreakdown breakdown;

  const CategorySummary({
    required this.categoryName,
    required this.displayName,
    required this.description,
    required this.totalAmount,
    required this.percentage,
    required this.transactionCount,
    required this.averageTransactionAmount,
    required this.period,
    required this.recentTransactions,
    required this.breakdown,
  });

  factory CategorySummary.fromJson(Map<String, dynamic> json) {
    return CategorySummary(
      categoryName: json['category_name'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      totalAmount: _toDouble(json['total_amount']),
      percentage: _toDouble(json['percentage']),
      transactionCount: json['transaction_count'] as int? ?? 0,
      averageTransactionAmount: _toDouble(json['average_transaction_amount']),
      period: json['period'] as String? ?? '',
      recentTransactions: (json['recent_transactions'] as List<dynamic>?)
          ?.map((e) => CategoryTransaction.fromJson(Map<String, dynamic>.from(e)))
          .toList() ?? [],
      breakdown: CategoryBreakdown.fromJson(Map<String, dynamic>.from(json['breakdown'] ?? {})),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'category_name': categoryName,
      'display_name': displayName,
      'description': description,
      'total_amount': totalAmount,
      'percentage': percentage,
      'transaction_count': transactionCount,
      'average_transaction_amount': averageTransactionAmount,
      'period': period,
      'recent_transactions': recentTransactions.map((e) => e.toJson()).toList(),
      'breakdown': breakdown.toJson(),
    };
  }
}

class CategoryTransaction {
  final String id;
  final String description;
  final String merchantName;
  final double amount;
  final String transactionTime;
  final String category;

  const CategoryTransaction({
    required this.id,
    required this.description,
    required this.merchantName,
    required this.amount,
    required this.transactionTime,
    required this.category,
  });

  factory CategoryTransaction.fromJson(Map<String, dynamic> json) {
    return CategoryTransaction(
      id: json['id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      merchantName: json['merchant_name'] as String? ?? '',
      amount: _toDouble(json['amount']),
      transactionTime: json['transaction_time'] as String? ?? '',
      category: json['category'] as String? ?? '',
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'merchant_name': merchantName,
      'amount': amount,
      'transaction_time': transactionTime,
      'category': category,
    };
  }
}

class CategoryBreakdown {
  final double monthlyAverage;
  final double weeklyAverage;
  final double dailyAverage;
  final double highestTransaction;
  final double lowestTransaction;
  final Map<String, double> monthlyTrend;

  const CategoryBreakdown({
    required this.monthlyAverage,
    required this.weeklyAverage,
    required this.dailyAverage,
    required this.highestTransaction,
    required this.lowestTransaction,
    required this.monthlyTrend,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      monthlyAverage: _toDouble(json['monthly_average']),
      weeklyAverage: _toDouble(json['weekly_average']),
      dailyAverage: _toDouble(json['daily_average']),
      highestTransaction: _toDouble(json['highest_transaction']),
      lowestTransaction: _toDouble(json['lowest_transaction']),
      monthlyTrend: Map<String, double>.from(
        (json['monthly_trend'] as Map<String, dynamic>? ?? {})
            .map((key, value) => MapEntry(key, _toDouble(value)))
      ),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'monthly_average': monthlyAverage,
      'weekly_average': weeklyAverage,
      'daily_average': dailyAverage,
      'highest_transaction': highestTransaction,
      'lowest_transaction': lowestTransaction,
      'monthly_trend': monthlyTrend,
    };
  }
}

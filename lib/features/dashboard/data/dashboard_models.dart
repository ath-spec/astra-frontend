// Typed models for the `/api/v1/dashboard/summary` backend API.

/// A single asset bucket (Mutual Funds, Stocks, Fixed Deposits) within the
/// dashboard summary. `investedValue`/`returnsAmount`/`returnsPct` are 0 for
/// buckets where they don't meaningfully apply.
class DashboardAssetBucket {
  const DashboardAssetBucket({
    required this.value,
    required this.investedValue,
    required this.returnsAmount,
    required this.returnsPct,
    required this.oneDayChangeAmount,
    required this.oneDayChangePct,
    required this.sharePct,
  });

  final double value;
  final double investedValue;
  final double returnsAmount;
  final double returnsPct;
  final double oneDayChangeAmount;
  final double oneDayChangePct;
  final double sharePct;

  static const empty = DashboardAssetBucket(
    value: 0,
    investedValue: 0,
    returnsAmount: 0,
    returnsPct: 0,
    oneDayChangeAmount: 0,
    oneDayChangePct: 0,
    sharePct: 0,
  );

  factory DashboardAssetBucket.fromJson(Map<String, dynamic> json) {
    return DashboardAssetBucket(
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      investedValue: (json['invested_value'] as num?)?.toDouble() ?? 0.0,
      returnsAmount: (json['returns_amount'] as num?)?.toDouble() ?? 0.0,
      returnsPct: (json['returns_pct'] as num?)?.toDouble() ?? 0.0,
      oneDayChangeAmount: (json['one_day_change_amount'] as num?)?.toDouble() ?? 0.0,
      oneDayChangePct: (json['one_day_change_pct'] as num?)?.toDouble() ?? 0.0,
      sharePct: (json['share_pct'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// The bank-balance bucket has no invested/returns concept (it's cash, not
/// an investment), so it's modelled separately from [DashboardAssetBucket].
class DashboardBankBalance {
  const DashboardBankBalance({
    required this.value,
    required this.sharePct,
    required this.oneDayChangeAmount,
    required this.oneDayChangePct,
  });

  final double value;
  final double sharePct;
  final double oneDayChangeAmount;
  final double oneDayChangePct;

  static const empty = DashboardBankBalance(
    value: 0,
    sharePct: 0,
    oneDayChangeAmount: 0,
    oneDayChangePct: 0,
  );

  factory DashboardBankBalance.fromJson(Map<String, dynamic> json) {
    return DashboardBankBalance(
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      sharePct: (json['share_pct'] as num?)?.toDouble() ?? 0.0,
      oneDayChangeAmount: (json['one_day_change_amount'] as num?)?.toDouble() ?? 0.0,
      oneDayChangePct: (json['one_day_change_pct'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DashboardSummary {
  const DashboardSummary({
    required this.totalWealth,
    required this.oneDayChangeAmount,
    required this.oneDayChangePct,
    required this.mutualFunds,
    required this.stocks,
    required this.fixedDeposits,
    required this.bankBalance,
  });

  final double totalWealth;
  final double oneDayChangeAmount;
  final double oneDayChangePct;
  final DashboardAssetBucket mutualFunds;
  final DashboardAssetBucket stocks;
  final DashboardAssetBucket fixedDeposits;
  final DashboardBankBalance bankBalance;

  static const empty = DashboardSummary(
    totalWealth: 0,
    oneDayChangeAmount: 0,
    oneDayChangePct: 0,
    mutualFunds: DashboardAssetBucket.empty,
    stocks: DashboardAssetBucket.empty,
    fixedDeposits: DashboardAssetBucket.empty,
    bankBalance: DashboardBankBalance.empty,
  );

  bool get mfConnected => mutualFunds.value > 0;
  bool get stocksConnected => stocks.value > 0;
  bool get fixedDepositsPresent => fixedDeposits.value > 0;
  bool get bankBalancePresent => bankBalance.value > 0;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalWealth: (json['total_wealth'] as num?)?.toDouble() ?? 0.0,
      oneDayChangeAmount: (json['one_day_change_amount'] as num?)?.toDouble() ?? 0.0,
      oneDayChangePct: (json['one_day_change_pct'] as num?)?.toDouble() ?? 0.0,
      mutualFunds: json['mutual_funds'] is Map<String, dynamic>
          ? DashboardAssetBucket.fromJson(json['mutual_funds'] as Map<String, dynamic>)
          : DashboardAssetBucket.empty,
      stocks: json['stocks'] is Map<String, dynamic>
          ? DashboardAssetBucket.fromJson(json['stocks'] as Map<String, dynamic>)
          : DashboardAssetBucket.empty,
      fixedDeposits: json['fixed_deposits'] is Map<String, dynamic>
          ? DashboardAssetBucket.fromJson(json['fixed_deposits'] as Map<String, dynamic>)
          : DashboardAssetBucket.empty,
      bankBalance: json['bank_balance'] is Map<String, dynamic>
          ? DashboardBankBalance.fromJson(json['bank_balance'] as Map<String, dynamic>)
          : DashboardBankBalance.empty,
    );
  }
}

/// A single point from `GET /api/v1/dashboard/growth`. Backend dates are
/// Unix epoch seconds (integers), not ISO strings — use [date] for a
/// [DateTime].
class DashboardGrowthPoint {
  const DashboardGrowthPoint({
    required this.dateEpoch,
    required this.totalWealth,
  });

  final int dateEpoch;
  final double totalWealth;

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(dateEpoch * 1000);

  factory DashboardGrowthPoint.fromJson(Map<String, dynamic> json) {
    return DashboardGrowthPoint(
      dateEpoch: (json['date'] as num?)?.toInt() ?? 0,
      totalWealth: (json['total_wealth'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

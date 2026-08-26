import 'package:astra_frontend/features/portfolio_analysis/models/portfolio_analysis_models.dart';

class VolatilityBucketData {
  final String label;
  final double amount;
  final double sharePct;

  const VolatilityBucketData({
    required this.label,
    required this.amount,
    required this.sharePct,
  });

  factory VolatilityBucketData.fromJson(Map<String, dynamic> json) {
    return VolatilityBucketData(
      label: json['label']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      sharePct: (json['share_pct'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SectorExposureData {
  final String sector;
  final double amount;
  final double percentage;

  const SectorExposureData({
    required this.sector,
    required this.amount,
    required this.percentage,
  });

  factory SectorExposureData.fromJson(Map<String, dynamic> json) {
    return SectorExposureData(
      sector: json['sector']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AllocationData {
  final AllocationLevel level;
  final String rawLevel;
  final double totalValue;
  final double equityAmount;
  final double debtAmount;
  final double otherAmount;
  final double equityPct;
  final double debtPct;
  final double otherPct;
  final List<VolatilityBucketData> volatilityBuckets;
  final List<SectorExposureData> sectorExposure;

  const AllocationData({
    required this.level,
    required this.rawLevel,
    required this.totalValue,
    required this.equityAmount,
    required this.debtAmount,
    required this.otherAmount,
    required this.equityPct,
    required this.debtPct,
    required this.otherPct,
    required this.volatilityBuckets,
    required this.sectorExposure,
  });

  static AllocationLevel parseLevel(String? val) {
    switch (val?.toUpperCase()) {
      case 'CONSERVATIVE':
        return AllocationLevel.conservative;
      case 'MODERATE_CONSERVATIVE':
        return AllocationLevel.moderateConservative;
      case 'BALANCED':
        return AllocationLevel.balanced;
      case 'AGGRESSIVE':
        return AllocationLevel.aggressive;
      case 'VERY_AGGRESSIVE':
      default:
        return AllocationLevel.veryAggressive;
    }
  }

  factory AllocationData.fromJson(Map<String, dynamic> json) {
    final rawLvl = json['level']?.toString() ?? 'BALANCED';
    final buckets = (json['volatility_buckets'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(VolatilityBucketData.fromJson)
            .toList() ??
        [];
    final sectors = (json['sector_exposure'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(SectorExposureData.fromJson)
            .toList() ??
        [];

    return AllocationData(
      level: parseLevel(rawLvl),
      rawLevel: rawLvl,
      totalValue: (json['total_value'] as num?)?.toDouble() ?? 0.0,
      equityAmount: (json['equity_amount'] as num?)?.toDouble() ?? 0.0,
      debtAmount: (json['debt_amount'] as num?)?.toDouble() ?? 0.0,
      otherAmount: (json['other_amount'] as num?)?.toDouble() ?? 0.0,
      equityPct: (json['equity_pct'] as num?)?.toDouble() ?? 0.0,
      debtPct: (json['debt_pct'] as num?)?.toDouble() ?? 0.0,
      otherPct: (json['other_pct'] as num?)?.toDouble() ?? 0.0,
      volatilityBuckets: buckets,
      sectorExposure: sectors,
    );
  }
}

class MonthlyInvestmentData {
  final String monthName;
  final String yearMonth;
  final double amount;
  final int orderCount;
  final bool hasInvestment;

  const MonthlyInvestmentData({
    required this.monthName,
    required this.yearMonth,
    required this.amount,
    required this.orderCount,
    required this.hasInvestment,
  });

  factory MonthlyInvestmentData.fromJson(Map<String, dynamic> json) {
    return MonthlyInvestmentData(
      monthName: json['month_name']?.toString() ?? '',
      yearMonth: json['year_month']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      orderCount: (json['order_count'] as num?)?.toInt() ?? 0,
      hasInvestment: json['has_investment'] == true,
    );
  }
}

class DisciplineData {
  final DisciplineLevel level;
  final String rawLevel;
  final double score;
  final int activeSegments;
  final double sipConsistencyPct;
  final int currentStreakMonths;
  final int missedMonths;
  final double avgMonthlyInvested;
  final double sipAutomationPct;
  final int activeMandatesCount;
  final List<MonthlyInvestmentData> monthlyHistory;

  const DisciplineData({
    required this.level,
    required this.rawLevel,
    required this.score,
    required this.activeSegments,
    required this.sipConsistencyPct,
    required this.currentStreakMonths,
    required this.missedMonths,
    required this.avgMonthlyInvested,
    required this.sipAutomationPct,
    required this.activeMandatesCount,
    required this.monthlyHistory,
  });

  static DisciplineLevel parseLevel(String? val) {
    switch (val?.toUpperCase()) {
      case 'POOR':
        return DisciplineLevel.poor;
      case 'GOOD':
        return DisciplineLevel.good;
      case 'EXCELLENT':
        return DisciplineLevel.excellent;
      case 'MODERATE':
      default:
        return DisciplineLevel.moderate;
    }
  }

  factory DisciplineData.fromJson(Map<String, dynamic> json) {
    final rawLvl = json['level']?.toString() ?? 'MODERATE';
    final history = (json['monthly_history'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(MonthlyInvestmentData.fromJson)
            .toList() ??
        [];

    return DisciplineData(
      level: parseLevel(rawLvl),
      rawLevel: rawLvl,
      score: (json['score'] as num?)?.toDouble() ?? 0.70,
      activeSegments: (json['active_segments'] as num?)?.toInt() ?? 2,
      sipConsistencyPct:
          (json['sip_consistency_pct'] as num?)?.toDouble() ?? 0.0,
      currentStreakMonths:
          (json['current_streak_months'] as num?)?.toInt() ?? 0,
      missedMonths: (json['missed_months'] as num?)?.toInt() ?? 0,
      avgMonthlyInvested:
          (json['avg_monthly_invested'] as num?)?.toDouble() ?? 0.0,
      sipAutomationPct: (json['sip_automation_pct'] as num?)?.toDouble() ?? 0.0,
      activeMandatesCount:
          (json['active_mandates_count'] as num?)?.toInt() ?? 0,
      monthlyHistory: history,
    );
  }
}

class BenchmarkData {
  final String name;
  final double benchmarkReturnPct;
  final double portfolioReturnPct;
  final double alphaPct;
  final bool beatingBenchmark;

  const BenchmarkData({
    required this.name,
    required this.benchmarkReturnPct,
    required this.portfolioReturnPct,
    required this.alphaPct,
    required this.beatingBenchmark,
  });

  factory BenchmarkData.fromJson(Map<String, dynamic> json) {
    return BenchmarkData(
      name: json['name']?.toString() ?? '',
      benchmarkReturnPct:
          (json['benchmark_return_pct'] as num?)?.toDouble() ?? 0.0,
      portfolioReturnPct:
          (json['portfolio_return_pct'] as num?)?.toDouble() ?? 0.0,
      alphaPct: (json['alpha_pct'] as num?)?.toDouble() ?? 0.0,
      beatingBenchmark: json['beating_benchmark'] == true,
    );
  }
}

class ExpensiveFundData {
  final String schemeCode;
  final String schemeName;
  final double expenseRatio;
  final double categoryAvgExpenseRatio;
  final double annualCostEstimate;
  final String recommendation;

  const ExpensiveFundData({
    required this.schemeCode,
    required this.schemeName,
    required this.expenseRatio,
    required this.categoryAvgExpenseRatio,
    required this.annualCostEstimate,
    required this.recommendation,
  });

  factory ExpensiveFundData.fromJson(Map<String, dynamic> json) {
    return ExpensiveFundData(
      schemeCode: json['scheme_code']?.toString() ?? '',
      schemeName: json['scheme_name']?.toString() ?? '',
      expenseRatio: (json['expense_ratio'] as num?)?.toDouble() ?? 0.0,
      categoryAvgExpenseRatio:
          (json['category_avg_expense_ratio'] as num?)?.toDouble() ?? 0.65,
      annualCostEstimate:
          (json['annual_cost_estimate'] as num?)?.toDouble() ?? 0.0,
      recommendation: json['recommendation']?.toString() ?? '',
    );
  }
}

class FundPerformanceData {
  final String schemeCode;
  final String schemeName;
  final double investedValue;
  final double currentValue;
  final double gainAmount;
  final double returnsPct;
  final String performanceRank;

  const FundPerformanceData({
    required this.schemeCode,
    required this.schemeName,
    required this.investedValue,
    required this.currentValue,
    required this.gainAmount,
    required this.returnsPct,
    required this.performanceRank,
  });

  factory FundPerformanceData.fromJson(Map<String, dynamic> json) {
    return FundPerformanceData(
      schemeCode: json['scheme_code']?.toString() ?? '',
      schemeName: json['scheme_name']?.toString() ?? '',
      investedValue: (json['invested_value'] as num?)?.toDouble() ?? 0.0,
      currentValue: (json['current_value'] as num?)?.toDouble() ?? 0.0,
      gainAmount: (json['gain_amount'] as num?)?.toDouble() ?? 0.0,
      returnsPct: (json['returns_pct'] as num?)?.toDouble() ?? 0.0,
      performanceRank: json['performance_rank']?.toString() ?? 'AVERAGE',
    );
  }
}

class PerformanceData {
  final PerformanceLevel level;
  final String rawLevel;
  final int activeSegments;
  final double totalInvested;
  final double totalCurrent;
  final double totalGainAmount;
  final double totalReturnPct;
  final double annualizedReturnPct;
  final List<BenchmarkData> benchmarks;
  final List<ExpensiveFundData> expensiveFunds;
  final List<FundPerformanceData> fundsPerformance;

  const PerformanceData({
    required this.level,
    required this.rawLevel,
    required this.activeSegments,
    required this.totalInvested,
    required this.totalCurrent,
    required this.totalGainAmount,
    required this.totalReturnPct,
    required this.annualizedReturnPct,
    required this.benchmarks,
    required this.expensiveFunds,
    required this.fundsPerformance,
  });

  static PerformanceLevel parseLevel(String? val) {
    switch (val?.toUpperCase()) {
      case 'SIGNIFICANTLY_BELOW':
        return PerformanceLevel.significantlyBelow;
      case 'BELOW_AVERAGE':
        return PerformanceLevel.belowAverage;
      case 'IN_LINE':
        return PerformanceLevel.inLine;
      case 'STRONG':
        return PerformanceLevel.strong;
      case 'VERY_STRONG':
      default:
        return PerformanceLevel.veryStrong;
    }
  }

  factory PerformanceData.fromJson(Map<String, dynamic> json) {
    final rawLvl = json['level']?.toString() ?? 'VERY_STRONG';
    final benchmarks = (json['benchmarks'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(BenchmarkData.fromJson)
            .toList() ??
        [];
    final expensive = (json['expensive_funds'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(ExpensiveFundData.fromJson)
            .toList() ??
        [];
    final funds = (json['funds_performance'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(FundPerformanceData.fromJson)
            .toList() ??
        [];

    return PerformanceData(
      level: parseLevel(rawLvl),
      rawLevel: rawLvl,
      activeSegments: (json['active_segments'] as num?)?.toInt() ?? 5,
      totalInvested: (json['total_invested'] as num?)?.toDouble() ?? 0.0,
      totalCurrent: (json['total_current'] as num?)?.toDouble() ?? 0.0,
      totalGainAmount: (json['total_gain_amount'] as num?)?.toDouble() ?? 0.0,
      totalReturnPct: (json['total_return_pct'] as num?)?.toDouble() ?? 0.0,
      annualizedReturnPct:
          (json['annualized_return_pct'] as num?)?.toDouble() ?? 0.0,
      benchmarks: benchmarks,
      expensiveFunds: expensive,
      fundsPerformance: funds,
    );
  }
}

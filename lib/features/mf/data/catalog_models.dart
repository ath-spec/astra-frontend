// Typed models for the /api/v1/catalog/* endpoints.

class CatalogFund {
  final String schemeCode;
  final String schemeName;
  final String amcName;
  final String isin;
  final String category;
  final String riskLevel;
  final double nav;
  final int navDateEpoch;
  final double expenseRatio;
  final double aum;
  final double minInvestment;
  final double minSipAmount;
  final double? returns1y;
  final double? returns3y;
  final double? returns5y;
  final String? benchmarkIndex;

  const CatalogFund({
    required this.schemeCode,
    required this.schemeName,
    required this.amcName,
    required this.isin,
    required this.category,
    required this.riskLevel,
    required this.nav,
    required this.navDateEpoch,
    required this.expenseRatio,
    required this.aum,
    required this.minInvestment,
    required this.minSipAmount,
    this.returns1y,
    this.returns3y,
    this.returns5y,
    this.benchmarkIndex,
  });

  factory CatalogFund.fromJson(Map<String, dynamic> json) {
    return CatalogFund(
      schemeCode: json['scheme_code']?.toString() ?? '',
      schemeName: json['scheme_name']?.toString() ?? '',
      amcName: json['amc_name']?.toString() ?? '',
      isin: json['isin']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      riskLevel: json['risk_level']?.toString() ?? 'Medium',
      nav: (json['nav'] as num?)?.toDouble() ?? 0.0,
      navDateEpoch: (json['nav_date'] as num?)?.toInt() ?? 0,
      expenseRatio: (json['expense_ratio'] as num?)?.toDouble() ?? 0.0,
      aum: (json['aum'] as num?)?.toDouble() ?? 0.0,
      minInvestment: (json['min_investment'] as num?)?.toDouble() ?? 500.0,
      minSipAmount: (json['min_sip_amount'] as num?)?.toDouble() ?? 500.0,
      returns1y: (json['returns_1y'] as num?)?.toDouble(),
      returns3y: (json['returns_3y'] as num?)?.toDouble(),
      returns5y: (json['returns_5y'] as num?)?.toDouble(),
      benchmarkIndex: json['benchmark_index']?.toString(),
    );
  }
}

class DistributionItemData {
  final String title;
  final double percentage;

  const DistributionItemData({
    required this.title,
    required this.percentage,
  });

  factory DistributionItemData.fromJson(Map<String, dynamic> json) {
    return DistributionItemData(
      title: json['title']?.toString() ?? '',
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AllocationBreakdownData {
  final double equityPct;
  final double debtPct;
  final double otherPct;
  final List<DistributionItemData> sectors;
  final List<DistributionItemData> topHoldings;

  const AllocationBreakdownData({
    required this.equityPct,
    required this.debtPct,
    required this.otherPct,
    required this.sectors,
    required this.topHoldings,
  });

  factory AllocationBreakdownData.fromJson(Map<String, dynamic> json) {
    final sectors = (json['sectors'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(DistributionItemData.fromJson)
            .toList() ??
        [];
    final holdings = (json['top_holdings'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(DistributionItemData.fromJson)
            .toList() ??
        [];

    return AllocationBreakdownData(
      equityPct: (json['equity_pct'] as num?)?.toDouble() ?? 100.0,
      debtPct: (json['debt_pct'] as num?)?.toDouble() ?? 0.0,
      otherPct: (json['other_pct'] as num?)?.toDouble() ?? 0.0,
      sectors: sectors,
      topHoldings: holdings,
    );
  }
}

class ChartPointData {
  final int dateEpoch;
  final double nav;

  const ChartPointData({
    required this.dateEpoch,
    required this.nav,
  });

  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch(dateEpoch * 1000);

  factory ChartPointData.fromJson(Map<String, dynamic> json) {
    return ChartPointData(
      dateEpoch: (json['date'] as num?)?.toInt() ?? 0,
      nav: (json['nav'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class UserHoldingData {
  final double unitsHeld;
  final double investedValue;
  final double currentValue;
  final double returnsPct;

  const UserHoldingData({
    required this.unitsHeld,
    required this.investedValue,
    required this.currentValue,
    required this.returnsPct,
  });

  factory UserHoldingData.fromJson(Map<String, dynamic> json) {
    return UserHoldingData(
      unitsHeld: (json['units_held'] as num?)?.toDouble() ?? 0.0,
      investedValue: (json['invested_value'] as num?)?.toDouble() ?? 0.0,
      currentValue: (json['current_value'] as num?)?.toDouble() ?? 0.0,
      returnsPct: (json['returns_pct'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DeepDiveData {
  final String primaryRole;
  final String secondaryRole;
  final String strengths;
  final String tradeOffs;
  final String contribution;

  const DeepDiveData({
    required this.primaryRole,
    required this.secondaryRole,
    required this.strengths,
    required this.tradeOffs,
    required this.contribution,
  });

  factory DeepDiveData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DeepDiveData(
        primaryRole: 'Core Growth',
        secondaryRole: 'Capital Preservation',
        strengths: 'Solid fundamentals and resilient market position.',
        tradeOffs: 'Moderate market beta.',
        contribution: 'Provides stability and steady compounding.',
      );
    }
    return DeepDiveData(
      primaryRole: json['primary_role']?.toString() ?? 'Core Growth',
      secondaryRole: json['secondary_role']?.toString() ?? 'Capital Preservation',
      strengths: json['strengths']?.toString() ?? '',
      tradeOffs: json['trade_offs']?.toString() ?? '',
      contribution: json['contribution']?.toString() ?? '',
    );
  }
}

class FundInsightsDetail {
  final bool isPositiveImpact;
  final String whyGetFund;
  final String suitableFor;
  final String avoidIf;
  final String impactText;
  final String whatItDoesRightNow;
  final String whatBuyingMoreWillDo;
  final List<double> currentValues;
  final List<double> projectedValues;

  const FundInsightsDetail({
    required this.isPositiveImpact,
    required this.whyGetFund,
    required this.suitableFor,
    required this.avoidIf,
    required this.impactText,
    required this.whatItDoesRightNow,
    required this.whatBuyingMoreWillDo,
    required this.currentValues,
    required this.projectedValues,
  });

  factory FundInsightsDetail.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const FundInsightsDetail(
        isPositiveImpact: true,
        whyGetFund: 'Provides risk-adjusted capital growth.',
        suitableFor: 'Long-term disciplined wealth accumulation.',
        avoidIf: 'Seeking immediate cash redemption.',
        impactText: 'Improves portfolio diversification.',
        whatItDoesRightNow: 'Provides market compounding and risk balance.',
        whatBuyingMoreWillDo: 'Accelerates capital growth with controlled volatility.',
        currentValues: [0.5, 0.4, 0.6, 0.3, 0.7, 0.4, 0.2],
        projectedValues: [0.7, 0.5, 0.7, 0.4, 0.7, 0.5, 0.3],
      );
    }
    final curr = (json['current_values'] as List?)?.map((e) => (e as num).toDouble()).toList() ?? [];
    final proj = (json['projected_values'] as List?)?.map((e) => (e as num).toDouble()).toList() ?? [];

    return FundInsightsDetail(
      isPositiveImpact: json['is_positive_impact'] == true,
      whyGetFund: json['why_get_fund']?.toString() ?? '',
      suitableFor: json['suitable_for']?.toString() ?? '',
      avoidIf: json['avoid_if']?.toString() ?? '',
      impactText: json['impact_text']?.toString() ?? '',
      whatItDoesRightNow: json['what_it_does_right_now']?.toString() ?? '',
      whatBuyingMoreWillDo: json['what_buying_more_will_do']?.toString() ?? '',
      currentValues: curr,
      projectedValues: proj,
    );
  }
}

class FundProfileDetail {
  final CatalogFund fund;
  final AllocationBreakdownData allocation;
  final List<ChartPointData> chartPoints;
  final DeepDiveData deepDive;
  final FundInsightsDetail insights;
  final UserHoldingData? userHolding;

  const FundProfileDetail({
    required this.fund,
    required this.allocation,
    required this.chartPoints,
    required this.deepDive,
    required this.insights,
    this.userHolding,
  });

  bool get hasUserHolding => userHolding != null;

  factory FundProfileDetail.fromJson(Map<String, dynamic> json) {
    final chartPts = (json['chart_points'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(ChartPointData.fromJson)
            .toList() ??
        [];
    final alloc = json['allocation'] is Map<String, dynamic>
        ? AllocationBreakdownData.fromJson(
            json['allocation'] as Map<String, dynamic>)
        : const AllocationBreakdownData(
            equityPct: 100, debtPct: 0, otherPct: 0, sectors: [], topHoldings: []);
    final holding = json['user_holding'] is Map<String, dynamic>
        ? UserHoldingData.fromJson(json['user_holding'] as Map<String, dynamic>)
        : null;

    final deepDive = DeepDiveData.fromJson(json['deep_dive'] as Map<String, dynamic>?);
    final insights = FundInsightsDetail.fromJson(json['insights'] as Map<String, dynamic>?);

    return FundProfileDetail(
      fund: CatalogFund.fromJson(json),
      allocation: alloc,
      chartPoints: chartPts,
      deepDive: deepDive,
      insights: insights,
      userHolding: holding,
    );
  }
}

class NfoItem {
  final String nfoId;
  final String schemeName;
  final String amcName;
  final String category;
  final int offerOpenEpoch;
  final int offerCloseEpoch;
  final double offerPrice;
  final double minInvestment;

  const NfoItem({
    required this.nfoId,
    required this.schemeName,
    required this.amcName,
    required this.category,
    required this.offerOpenEpoch,
    required this.offerCloseEpoch,
    required this.offerPrice,
    required this.minInvestment,
  });

  factory NfoItem.fromJson(Map<String, dynamic> json) {
    return NfoItem(
      nfoId: json['nfo_id']?.toString() ?? '',
      schemeName: json['scheme_name']?.toString() ?? '',
      amcName: json['amc_name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      offerOpenEpoch: (json['offer_open_date'] as num?)?.toInt() ?? 0,
      offerCloseEpoch: (json['offer_close_date'] as num?)?.toInt() ?? 0,
      offerPrice: (json['offer_price'] as num?)?.toDouble() ?? 10.0,
      minInvestment: (json['min_investment'] as num?)?.toDouble() ?? 500.0,
    );
  }
}

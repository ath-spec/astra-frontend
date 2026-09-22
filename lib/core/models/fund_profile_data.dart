import 'package:flutter/material.dart';
import 'fund_asset_allocation_data.dart';
export 'fund_asset_allocation_data.dart';

class FundProfileData {
  final String id;
  final String name;
  final String tags; // e.g. 'Equity • Value • Growth'
  final String logoText; // E.g. 'quant'
  
  final String riskLabel; // e.g. 'HIGH VOLATILITY FUND'
  final Color riskColor; // Red for high, green/gray for low
  
  final String returnPercentage; // e.g. '22.56%'
  final String returnDuration; // e.g. '3Y Annualised Return'
  final String comparisonText; // e.g. 'vs. 7.26% in Nifty 50 >'
  
  final List<double> chartDataPoints;
  final Color chartColor;
  
  final int sipAmount; // 10000
  final String sipDurationText; // '3 years'
  final String sipFinalAmount; // '₹5,17,681'
  final String sipReturnPercentage; // '(43.8%)'
  
  final String overviewText;
  
  final AssetAllocationData? assetAllocation;
  
  final FundInsightsData? insightsData;
  final InstrumentDeepDiveData? instrumentData;

  final double? nav;
  final double? expenseRatio;
  final double? aum;
  final double? minSipAmount;
  final double? minInvestment;
  final String? amcName;
  final String? fundManager;
  final String? exitLoad;

  const FundProfileData({
    required this.id,
    required this.name,
    required this.tags,
    required this.logoText,
    required this.riskLabel,
    required this.riskColor,
    required this.returnPercentage,
    required this.returnDuration,
    required this.comparisonText,
    required this.chartDataPoints,
    required this.chartColor,
    required this.sipAmount,
    required this.sipDurationText,
    required this.sipFinalAmount,
    required this.sipReturnPercentage,
    required this.overviewText,
    this.assetAllocation,
    this.insightsData,
    this.instrumentData,
    this.nav,
    this.expenseRatio,
    this.aum,
    this.minSipAmount,
    this.minInvestment,
    this.amcName,
    this.fundManager,
    this.exitLoad,
  });
}

class FundInsightsData {
  final bool isPositiveImpact;
  final String whyGetFund;
  final String suitableFor;
  final String avoidIf;
  final String impactText;
  final String whatItDoesRightNow;
  final String whatBuyingMoreWillDo;
  final List<double>? currentValues;
  final List<double>? projectedValues;

  const FundInsightsData({
    required this.isPositiveImpact,
    required this.whyGetFund,
    required this.suitableFor,
    required this.avoidIf,
    required this.impactText,
    this.whatItDoesRightNow = '',
    this.whatBuyingMoreWillDo = '',
    this.currentValues,
    this.projectedValues,
  });
}

class InstrumentDeepDiveData {
  final String primaryRole;
  final String secondaryRole;
  final String strengths;
  final String tradeOffs;

  const InstrumentDeepDiveData({
    required this.primaryRole,
    required this.secondaryRole,
    required this.strengths,
    required this.tradeOffs,
  });
}

import 'package:flutter/material.dart';

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
  });
}

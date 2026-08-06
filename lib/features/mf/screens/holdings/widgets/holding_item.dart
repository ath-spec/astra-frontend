import 'package:flutter/material.dart';

class HoldingDeepDiveData {
  final String primaryRole;
  final String secondaryRole;
  final String contribution;

  HoldingDeepDiveData({
    required this.primaryRole,
    required this.secondaryRole,
    required this.contribution,
  });
}

class HoldingItem {
  final String name;
  final String category;
  final double current;
  final double invested;
  final double returns;
  final double returnsPercent;
  final double oneDayChange;
  final double oneDayChangePercent;
  final double xirr;
  final String logoPath;
  final bool isSip;
  final HoldingDeepDiveData? deepDiveData;

  HoldingItem({
    required this.name,
    required this.category,
    required this.current,
    required this.invested,
    required this.returns,
    required this.returnsPercent,
    required this.oneDayChange,
    required this.oneDayChangePercent,
    required this.xirr,
    required this.logoPath,
    this.isSip = false,
    this.deepDiveData,
  });
}


final List<HoldingItem> mockHoldings = [
  HoldingItem(
    name: 'Canara Robeco Large Cap Fund',
    category: 'Equity • Large-Cap',
    current: 236538,
    invested: 225026,
    returns: 11511,
    returnsPercent: 5.11,
    oneDayChange: 1038,
    oneDayChangePercent: 0.44,
    xirr: 3.22,
    logoPath: 'lib/core/images/canara_robeco_logo.webp', // We will use a placeholder or generic icon if missing
    isSip: true,
    deepDiveData: HoldingDeepDiveData(
      primaryRole: 'Core Growth',
      secondaryRole: 'Capital Preservation',
      contribution: 'Provides stability and consistent growth by investing in established, large-cap companies. Acts as an anchor for the equity portion of your portfolio.',
    ),
  ),
  HoldingItem(
    name: 'Quantum Gold ETF FoF',
    category: 'Commodities • Precious Metals',
    current: 99025,
    invested: 65799,
    returns: 33225,
    returnsPercent: 50.49,
    oneDayChange: -632,
    oneDayChangePercent: -0.63,
    xirr: 39.38,
    logoPath: 'lib/core/images/quantum_logo.webp',
    deepDiveData: HoldingDeepDiveData(
      primaryRole: 'Inflation Defense',
      secondaryRole: 'Portfolio Diversifier',
      contribution: 'Hedges against inflation and market volatility. It typically moves inversely to equities, reducing overall portfolio risk during market downturns.',
    ),
  ),
  HoldingItem(
    name: 'Tata Gold ETF FoF',
    category: 'Debt • Corporate Bond',
    current: 9377,
    invested: 8923,
    returns: 454,
    returnsPercent: 5.09,
    oneDayChange: -6,
    oneDayChangePercent: -0.07,
    xirr: 8.79,
    logoPath: 'lib/core/images/tata_logo.webp',
    deepDiveData: HoldingDeepDiveData(
      primaryRole: 'Steady Income',
      secondaryRole: 'Capital Preservation',
      contribution: 'Generates predictable returns with lower volatility. Helps balance the higher risk from your equity investments.',
    ),
  ),
  HoldingItem(
    name: 'HDFC Silver ETF FoF',
    category: 'Global • Precious Metals',
    current: 184,
    invested: 249,
    returns: -65,
    returnsPercent: -26.22,
    oneDayChange: 0,
    oneDayChangePercent: -0.04,
    xirr: -43.9,
    logoPath: 'lib/core/images/hdfc_logo.webp',
    isSip: true,
    deepDiveData: HoldingDeepDiveData(
      primaryRole: 'Tactical Allocation',
      secondaryRole: 'Real Assets Exposure',
      contribution: 'Offers exposure to industrial demand and precious metals. It brings a high-risk, high-reward element to the commodity bucket.',
    ),
  ),
];

import 'package:flutter/material.dart';

class AssetAllocationData {
  final EquityAllocationData? equity;
  final DebtAllocationData? debt;
  final OtherAllocationData? others;

  const AssetAllocationData({
    this.equity,
    this.debt,
    this.others,
  });
}

class EquityAllocationData {
  final double totalPercentage;
  final double largeCapPercentage;
  final double midCapPercentage;
  final double smallCapPercentage;
  final List<DistributionItem> sectors;
  final List<DistributionItem> holdings;

  const EquityAllocationData({
    required this.totalPercentage,
    required this.largeCapPercentage,
    required this.midCapPercentage,
    required this.smallCapPercentage,
    required this.sectors,
    required this.holdings,
  });
}

class DebtAllocationData {
  final double totalPercentage;
  final List<DistributionItem> creditQuality;
  final List<DistributionItem> sectors;
  final List<DistributionItem> holdings;

  const DebtAllocationData({
    required this.totalPercentage,
    required this.creditQuality,
    required this.sectors,
    required this.holdings,
  });
}

class OtherAllocationData {
  final double totalPercentage;
  final List<DistributionItem> otherAllocation;
  final List<DistributionItem> holdings;

  const OtherAllocationData({
    required this.totalPercentage,
    required this.otherAllocation,
    required this.holdings,
  });
}

class DistributionItem {
  final String title;
  final String? subtitle;
  final double percentage;
  final IconData? icon;

  const DistributionItem({
    required this.title,
    this.subtitle,
    required this.percentage,
    this.icon,
  });
}

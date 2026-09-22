// Typed models for the /api/v1/watchlist endpoints.

class WatchlistItem {
  final String schemeCode;
  final String schemeName;
  final String amcName;
  final String category;
  final String riskLevel;
  final double nav;
  final double? returns1y;
  final int addedAtEpoch;

  const WatchlistItem({
    required this.schemeCode,
    required this.schemeName,
    required this.amcName,
    required this.category,
    required this.riskLevel,
    required this.nav,
    this.returns1y,
    required this.addedAtEpoch,
  });

  DateTime get addedAt =>
      DateTime.fromMillisecondsSinceEpoch(addedAtEpoch * 1000);

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    return WatchlistItem(
      schemeCode: json['scheme_code']?.toString() ?? '',
      schemeName: json['scheme_name']?.toString() ?? '',
      amcName: json['amc_name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      riskLevel: json['risk_level']?.toString() ?? 'Medium',
      nav: (json['nav'] as num?)?.toDouble() ?? 0.0,
      returns1y: (json['returns_1y'] as num?)?.toDouble(),
      addedAtEpoch: (json['added_at'] as num?)?.toInt() ?? 0,
    );
  }
}

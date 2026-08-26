// Typed models for the `/api/v1/mf/holdings` backend API.
import 'package:astra_frontend/core/utils/fund_name_formatter.dart';

class MfHoldingsSummary {
  const MfHoldingsSummary({
    required this.investedValue,
    required this.currentValue,
    required this.returnsAmount,
    required this.returnsPct,
    required this.xirrPct,
    required this.oneDayChangeAmount,
    required this.oneDayChangePct,
    required this.folioCount,
  });

  final double investedValue;
  final double currentValue;
  final double returnsAmount;
  final double returnsPct;
  final double xirrPct;
  final double oneDayChangeAmount;
  final double oneDayChangePct;
  final int folioCount;

  static const empty = MfHoldingsSummary(
    investedValue: 0,
    currentValue: 0,
    returnsAmount: 0,
    returnsPct: 0,
    xirrPct: 0,
    oneDayChangeAmount: 0,
    oneDayChangePct: 0,
    folioCount: 0,
  );

  factory MfHoldingsSummary.fromJson(Map<String, dynamic> json) {
    return MfHoldingsSummary(
      investedValue: (json['invested_value'] as num?)?.toDouble() ?? 0.0,
      currentValue: (json['current_value'] as num?)?.toDouble() ?? 0.0,
      returnsAmount: (json['returns_amount'] as num?)?.toDouble() ?? 0.0,
      returnsPct: (json['returns_pct'] as num?)?.toDouble() ?? 0.0,
      xirrPct: (json['xirr_pct'] as num?)?.toDouble() ?? 0.0,
      oneDayChangeAmount: (json['one_day_change_amount'] as num?)?.toDouble() ?? 0.0,
      oneDayChangePct: (json['one_day_change_pct'] as num?)?.toDouble() ?? 0.0,
      folioCount: (json['folio_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class MfFolio {
  const MfFolio({
    required this.folioNumber,
    required this.amcName,
    required this.schemeCode,
    required this.schemeName,
    required this.isin,
    required this.category,
    required this.planType,
    required this.isSip,
    required this.unitsHeld,
    required this.nav,
    required this.navDateEpoch,
    required this.investedValue,
    required this.currentValue,
    required this.returnsAmount,
    required this.returnsPct,
    required this.oneDayChangeAmount,
    required this.oneDayChangePct,
    required this.xirrPct,
    required this.firstPurchaseDateEpoch,
  });

  final String folioNumber;
  final String amcName;
  final String schemeCode;
  final String schemeName;
  final String isin;
  final String category;
  final String planType;
  final bool isSip;
  final double unitsHeld;
  final double nav;

  /// Epoch seconds (backend sends dates as Unix epoch integers, not ISO
  /// strings). Use [navDateTime] for a [DateTime].
  final int navDateEpoch;
  final double investedValue;
  final double currentValue;
  final double returnsAmount;
  final double returnsPct;
  final double oneDayChangeAmount;
  final double oneDayChangePct;
  final double xirrPct;

  /// Epoch seconds. Use [firstPurchaseDateTime] for a [DateTime].
  final int firstPurchaseDateEpoch;

  DateTime get navDateTime => DateTime.fromMillisecondsSinceEpoch(navDateEpoch * 1000);
  DateTime get firstPurchaseDateTime =>
      DateTime.fromMillisecondsSinceEpoch(firstPurchaseDateEpoch * 1000);
  String get cleanSchemeName => cleanFundName(schemeName);

  factory MfFolio.fromJson(Map<String, dynamic> json) {
    return MfFolio(
      folioNumber: json['folio_number']?.toString() ?? '',
      amcName: json['amc_name']?.toString() ?? '',
      schemeCode: json['scheme_code']?.toString() ?? '',
      schemeName: json['scheme_name']?.toString() ?? '',
      isin: json['isin']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      planType: json['plan_type']?.toString() ?? '',
      isSip: json['is_sip'] as bool? ?? false,
      unitsHeld: (json['units_held'] as num?)?.toDouble() ?? 0.0,
      nav: (json['nav'] as num?)?.toDouble() ?? 0.0,
      navDateEpoch: (json['nav_date'] as num?)?.toInt() ?? 0,
      investedValue: (json['invested_value'] as num?)?.toDouble() ?? 0.0,
      currentValue: (json['current_value'] as num?)?.toDouble() ?? 0.0,
      returnsAmount: (json['returns_amount'] as num?)?.toDouble() ?? 0.0,
      returnsPct: (json['returns_pct'] as num?)?.toDouble() ?? 0.0,
      oneDayChangeAmount: (json['one_day_change_amount'] as num?)?.toDouble() ?? 0.0,
      oneDayChangePct: (json['one_day_change_pct'] as num?)?.toDouble() ?? 0.0,
      xirrPct: (json['xirr_pct'] as num?)?.toDouble() ?? 0.0,
      firstPurchaseDateEpoch: (json['first_purchase_date'] as num?)?.toInt() ?? 0,
    );
  }
}

class MfHoldingsResponse {
  const MfHoldingsResponse({
    required this.summary,
    required this.folios,
  });

  final MfHoldingsSummary summary;
  final List<MfFolio> folios;

  static const empty = MfHoldingsResponse(
    summary: MfHoldingsSummary.empty,
    folios: [],
  );

  factory MfHoldingsResponse.fromJson(Map<String, dynamic> json) {
    final folios = json['folios'];
    return MfHoldingsResponse(
      summary: json['summary'] is Map<String, dynamic>
          ? MfHoldingsSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : MfHoldingsSummary.empty,
      folios: folios is List
          ? folios
              .whereType<Map<String, dynamic>>()
              .map(MfFolio.fromJson)
              .toList(growable: false)
          : const [],
    );
  }
}

import 'package:astra_frontend/features/mf/data/mf_holdings_models.dart';
import 'package:astra_frontend/features/stocks/data/stocks_models.dart';

class HoldingDeepDiveData {
  final String primaryRole;
  final String secondaryRole;
  final String contribution;

  const HoldingDeepDiveData({
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

  /// Which of the Equity/Debt/Global filter chips this holding belongs to.
  /// Derived from the backend's catalog `category` string via
  /// [filterBucketForCategory]; defaults to inferring from [category] for
  /// items constructed without it explicitly.
  final String filterBucket;

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
    String? filterBucket,
  }) : filterBucket = filterBucket ?? _inferFilterBucket(category);

  static String _inferFilterBucket(String category) {
    if (category.contains('Equity')) return 'Equity';
    if (category.contains('Debt')) return 'Debt';
    if (category.contains('Global')) return 'Global';
    return 'Equity';
  }

  /// Builds a [HoldingItem] from a real `/api/v1/mf/holdings` folio.
  factory HoldingItem.fromFolio(MfFolio folio) {
    return HoldingItem(
      name: folio.schemeName.isNotEmpty ? folio.schemeName : folio.amcName,
      category: folio.category,
      current: folio.currentValue,
      invested: folio.investedValue,
      returns: folio.returnsAmount,
      returnsPercent: folio.returnsPct,
      oneDayChange: folio.oneDayChangeAmount,
      oneDayChangePercent: folio.oneDayChangePct,
      xirr: folio.xirrPct,
      logoPath: logoPathForAmc(folio.amcName),
      isSip: folio.isSip,
      filterBucket: filterBucketForCategory(folio.category),
    );
  }

  /// Builds a [HoldingItem] from a real `/api/v1/stocks/holdings` demat entry.
  factory HoldingItem.fromStock(StockHoldingItem stock) {
    // XIRR is not available from the stocks endpoint directly;
    // use pnlPercentage as a reasonable proxy.
    return HoldingItem(
      name: stock.tradingSymbol,
      category: 'Equity - Stocks',
      current: stock.currentValue,
      invested: stock.investedValue,
      returns: stock.pnl,
      returnsPercent: stock.pnlPercentage,
      oneDayChange: stock.oneDayChangeAmount,
      oneDayChangePercent: stock.oneDayChangePct,
      xirr: stock.pnlPercentage,
      logoPath: logoPathForSymbol(stock.tradingSymbol),
      isSip: false,
      filterBucket: 'Equity',
    );
  }
}

/// Maps a backend catalog `category` (e.g. "Equity - Mid Cap",
/// "Hybrid - Balanced Advantage", "Debt - Liquid", "Other - Gold") to one of
/// the existing Equity/Debt/Global filter chips on the Holdings screen.
///
/// There's no server-provided "Global" category today, so — matching how
/// this screen's earlier mock data used "Global" for commodities/precious
/// metals — any "Other - *" category (e.g. gold) is bucketed under Global as
/// the closest fit for a catch-all/alternative-assets chip.
String filterBucketForCategory(String category) {
  if (category.startsWith('Equity')) return 'Equity';
  if (category.startsWith('Debt') || category.startsWith('Hybrid')) return 'Debt';
  if (category.startsWith('Other')) return 'Global';
  return 'Equity';
}

/// Client-side logo lookup by stock trading symbol.
String logoPathForSymbol(String symbol) {
  final s = symbol.toUpperCase();
  if (s.contains('HDFC')) return 'lib/core/images/hdfc_logo.webp';
  if (s.contains('ICICI')) return 'lib/core/images/icici.png';
  if (s.contains('TATA') || s.contains('TCS')) return 'lib/core/images/tata_logo.webp';
  return 'lib/core/images/icici.png'; // generic fallback
}

/// Client-side logo lookup by AMC name — no logo/icon data comes from the
/// backend. Falls back to a generic placeholder path when the AMC isn't
/// recognized (the list widgets currently render a generic icon regardless
/// of this path, so the fallback is inert rather than a broken image).
String logoPathForAmc(String amcName) {
  final lower = amcName.toLowerCase();
  if (lower.contains('hdfc')) return 'lib/core/images/hdfc_logo.webp';
  if (lower.contains('tata')) return 'lib/core/images/tata_logo.webp';
  if (lower.contains('quantum')) return 'lib/core/images/quantum_logo.webp';
  if (lower.contains('canara')) return 'lib/core/images/canara_robeco_logo.webp';
  if (lower.contains('icici')) return 'lib/core/images/icici.png';
  return 'lib/core/images/icici.png';
}

// Typed models for the /api/v1/stocks/* backend endpoints.

class StockHoldingItem {
  final String tradingSymbol;
  final String exchange;
  final String isin;
  final int quantity;
  final double averagePrice;
  final double lastPrice;
  final double closePrice;
  final double pnl;
  final double pnlPercentage;

  const StockHoldingItem({
    required this.tradingSymbol,
    required this.exchange,
    required this.isin,
    required this.quantity,
    required this.averagePrice,
    required this.lastPrice,
    required this.closePrice,
    required this.pnl,
    required this.pnlPercentage,
  });

  double get currentValue => quantity * lastPrice;
  double get investedValue => quantity * averagePrice;
  double get oneDayChangeAmount => quantity * (lastPrice - closePrice);
  double get oneDayChangePct =>
      closePrice > 0 ? ((lastPrice - closePrice) / closePrice) * 100 : 0.0;

  factory StockHoldingItem.fromJson(Map<String, dynamic> json) {
    return StockHoldingItem(
      tradingSymbol: json['trading_symbol']?.toString() ?? '',
      exchange: json['exchange']?.toString() ?? 'NSE',
      isin: json['isin']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      averagePrice: (json['average_price'] as num?)?.toDouble() ?? 0.0,
      lastPrice: (json['last_price'] as num?)?.toDouble() ?? 0.0,
      closePrice: (json['close_price'] as num?)?.toDouble() ?? 0.0,
      pnl: (json['pnl'] as num?)?.toDouble() ?? 0.0,
      pnlPercentage: (json['pnl_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class StockOrderRecord {
  final String orderId;
  final String tradingSymbol;
  final String exchange;
  final String transactionType;
  final String orderType;
  final int quantity;
  final int filledQuantity;
  final double price;
  final double averagePrice;
  final String status;
  final int timestampEpoch;

  const StockOrderRecord({
    required this.orderId,
    required this.tradingSymbol,
    required this.exchange,
    required this.transactionType,
    required this.orderType,
    required this.quantity,
    required this.filledQuantity,
    required this.price,
    required this.averagePrice,
    required this.status,
    required this.timestampEpoch,
  });

  DateTime get timestamp =>
      DateTime.fromMillisecondsSinceEpoch(timestampEpoch * 1000);

  factory StockOrderRecord.fromJson(Map<String, dynamic> json) {
    return StockOrderRecord(
      orderId: json['order_id']?.toString() ?? '',
      tradingSymbol: json['trading_symbol']?.toString() ?? '',
      exchange: json['exchange']?.toString() ?? 'NSE',
      transactionType: json['transaction_type']?.toString() ?? 'BUY',
      orderType: json['order_type']?.toString() ?? 'MARKET',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      filledQuantity: (json['filled_quantity'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      averagePrice: (json['average_price'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'COMPLETE',
      timestampEpoch: (json['timestamp'] as num?)?.toInt() ?? 0,
    );
  }
}

class StockChartPoint {
  final int timestamp;
  final double price;

  const StockChartPoint({required this.timestamp, required this.price});

  factory StockChartPoint.fromJson(Map<String, dynamic> json) {
    return StockChartPoint(
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class StockFundamentals {
  final double marketCap;
  final double peRatio;
  final double pbRatio;
  final double divYield;
  final double roe;
  final double high52W;
  final double low52W;

  const StockFundamentals({
    required this.marketCap,
    required this.peRatio,
    required this.pbRatio,
    required this.divYield,
    required this.roe,
    required this.high52W,
    required this.low52W,
  });

  factory StockFundamentals.fromJson(Map<String, dynamic> json) {
    return StockFundamentals(
      marketCap: (json['market_cap'] as num?)?.toDouble() ?? 0.0,
      peRatio: (json['pe_ratio'] as num?)?.toDouble() ?? 0.0,
      pbRatio: (json['pb_ratio'] as num?)?.toDouble() ?? 0.0,
      divYield: (json['div_yield'] as num?)?.toDouble() ?? 0.0,
      roe: (json['roe'] as num?)?.toDouble() ?? 0.0,
      high52W: (json['high_52w'] as num?)?.toDouble() ?? 0.0,
      low52W: (json['low_52w'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ShareholderInfo {
  final String title;
  final double percentage;

  const ShareholderInfo({required this.title, required this.percentage});

  factory ShareholderInfo.fromJson(Map<String, dynamic> json) {
    return ShareholderInfo(
      title: json['title']?.toString() ?? '',
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class StockShareholdingPattern {
  final List<ShareholderInfo> promoter;
  final List<ShareholderInfo> fii;
  final List<ShareholderInfo> dii;
  final List<ShareholderInfo> public;

  const StockShareholdingPattern({
    required this.promoter,
    required this.fii,
    required this.dii,
    required this.public,
  });

  factory StockShareholdingPattern.fromJson(Map<String, dynamic> json) {
    return StockShareholdingPattern(
      promoter: (json['promoter'] as List?)?.map((e) => ShareholderInfo.fromJson(e)).toList() ?? [],
      fii: (json['fii'] as List?)?.map((e) => ShareholderInfo.fromJson(e)).toList() ?? [],
      dii: (json['dii'] as List?)?.map((e) => ShareholderInfo.fromJson(e)).toList() ?? [],
      public: (json['public'] as List?)?.map((e) => ShareholderInfo.fromJson(e)).toList() ?? [],
    );
  }
}

class StockInstrumentDeepDive {
  final String primaryRole;
  final String secondaryRole;
  final List<String> strengths;
  final List<String> tradeOffs;

  const StockInstrumentDeepDive({
    required this.primaryRole,
    required this.secondaryRole,
    required this.strengths,
    required this.tradeOffs,
  });

  factory StockInstrumentDeepDive.fromJson(Map<String, dynamic> json) {
    return StockInstrumentDeepDive(
      primaryRole: json['primary_role']?.toString() ?? '',
      secondaryRole: json['secondary_role']?.toString() ?? '',
      strengths: (json['strengths'] as List?)?.map((e) => e.toString()).toList() ?? [],
      tradeOffs: (json['trade_offs'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class StockPortfolioInsights {
  final bool isPositiveImpact;
  final List<String> whyGetFund;
  final List<String> suitableFor;
  final List<String> avoidIf;
  final String impactText;
  final String whatItDoesRightNow;
  final String whatBuyingMoreWillDo;

  const StockPortfolioInsights({
    required this.isPositiveImpact,
    required this.whyGetFund,
    required this.suitableFor,
    required this.avoidIf,
    required this.impactText,
    required this.whatItDoesRightNow,
    required this.whatBuyingMoreWillDo,
  });

  factory StockPortfolioInsights.fromJson(Map<String, dynamic> json) {
    return StockPortfolioInsights(
      isPositiveImpact: json['is_positive_impact'] == true,
      whyGetFund: (json['why_get_fund'] as List?)?.map((e) => e.toString()).toList() ?? [],
      suitableFor: (json['suitable_for'] as List?)?.map((e) => e.toString()).toList() ?? [],
      avoidIf: (json['avoid_if'] as List?)?.map((e) => e.toString()).toList() ?? [],
      impactText: json['impact_text']?.toString() ?? '',
      whatItDoesRightNow: json['what_it_does_right_now']?.toString() ?? '',
      whatBuyingMoreWillDo: json['what_buying_more_will_do']?.toString() ?? '',
    );
  }
}

class StockQuote {
  final double lastPrice;
  final double open;
  final double high;
  final double low;
  final double close;
  final String exchange;
  final String isin;

  const StockQuote({
    required this.lastPrice,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.exchange = '',
    this.isin = '',
  });

  factory StockQuote.fromJson(Map<String, dynamic> json) {
    final ohlc = json['ohlc'] as Map<String, dynamic>? ?? {};
    return StockQuote(
      lastPrice: (json['last_price'] as num?)?.toDouble() ?? 0.0,
      open: (ohlc['open'] as num?)?.toDouble() ?? 0.0,
      high: (ohlc['high'] as num?)?.toDouble() ?? 0.0,
      low: (ohlc['low'] as num?)?.toDouble() ?? 0.0,
      close: (ohlc['close'] as num?)?.toDouble() ?? 0.0,
      exchange: json['exchange']?.toString() ?? '',
      isin: json['isin']?.toString() ?? '',
    );
  }
}

class StockProfileDetail {
  final StockQuote quote;
  final String companyName;
  final String sector;
  final String description;
  final List<StockChartPoint> chartPoints;
  final StockFundamentals fundamentals;
  final StockShareholdingPattern shareholdingPattern;
  final StockInstrumentDeepDive instrumentDeepDive;
  final StockPortfolioInsights portfolioInsights;

  const StockProfileDetail({
    required this.quote,
    required this.companyName,
    required this.sector,
    required this.description,
    required this.chartPoints,
    required this.fundamentals,
    required this.shareholdingPattern,
    required this.instrumentDeepDive,
    required this.portfolioInsights,
  });

  factory StockProfileDetail.fromJson(Map<String, dynamic> json) {
    return StockProfileDetail(
      quote: StockQuote.fromJson(json['quote'] as Map<String, dynamic>? ?? {}),
      companyName: json['company_name']?.toString() ?? '',
      sector: json['sector']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      chartPoints: (json['chart_points'] as List?)?.map((e) => StockChartPoint.fromJson(e)).toList() ?? [],
      fundamentals: StockFundamentals.fromJson(json['fundamentals'] as Map<String, dynamic>? ?? {}),
      shareholdingPattern: StockShareholdingPattern.fromJson(json['shareholding_pattern'] as Map<String, dynamic>? ?? {}),
      instrumentDeepDive: StockInstrumentDeepDive.fromJson(json['instrument_deep_dive'] as Map<String, dynamic>? ?? {}),
      portfolioInsights: StockPortfolioInsights.fromJson(json['portfolio_insights'] as Map<String, dynamic>? ?? {}),
    );
  }
}

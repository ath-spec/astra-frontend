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

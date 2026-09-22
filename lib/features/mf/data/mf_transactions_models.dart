// Typed models for the `/api/v1/mf/transactions` backend API.

class MfTransaction {
  const MfTransaction({
    required this.schemeCode,
    required this.schemeName,
    required this.transactionType,
    required this.transactionDateEpoch,
    required this.amount,
    required this.units,
    required this.price,
  });

  final String schemeCode;
  final String schemeName;

  /// One of `PURCHASE`, `SIP`, `REDEEM`.
  final String transactionType;

  /// Epoch seconds. Use [transactionDate] for a [DateTime].
  final int transactionDateEpoch;
  final double amount;
  final double units;
  final double price;

  DateTime get transactionDate =>
      DateTime.fromMillisecondsSinceEpoch(transactionDateEpoch * 1000);

  factory MfTransaction.fromJson(Map<String, dynamic> json) {
    return MfTransaction(
      schemeCode: json['scheme_code']?.toString() ?? '',
      schemeName: json['scheme_name']?.toString() ?? '',
      transactionType: json['transaction_type']?.toString() ?? 'PURCHASE',
      transactionDateEpoch: (json['transaction_date'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      units: (json['units'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

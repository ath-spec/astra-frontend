// Typed models for the `/api/v1/fd` backend endpoints.

class FDAccountItem {
  final String accountId;
  final String fdAccountNumber;
  final double principalAmount;
  final double interestRate;
  final int tenureMonths;
  final double maturityAmount;
  final int maturityDateEpoch;
  final String interestPayoutFrequency;
  final String status;

  const FDAccountItem({
    required this.accountId,
    required this.fdAccountNumber,
    required this.principalAmount,
    required this.interestRate,
    required this.tenureMonths,
    required this.maturityAmount,
    required this.maturityDateEpoch,
    required this.interestPayoutFrequency,
    required this.status,
  });

  DateTime get maturityDateTime =>
      DateTime.fromMillisecondsSinceEpoch(maturityDateEpoch * 1000);

  factory FDAccountItem.fromJson(Map<String, dynamic> json) {
    return FDAccountItem(
      accountId: json['account_id']?.toString() ?? '',
      fdAccountNumber: json['fd_account_number']?.toString() ?? '',
      principalAmount: (json['principal_amount'] as num?)?.toDouble() ?? 0.0,
      interestRate: (json['interest_rate'] as num?)?.toDouble() ?? 7.10,
      tenureMonths: (json['tenure_months'] as num?)?.toInt() ?? 12,
      maturityAmount: (json['maturity_amount'] as num?)?.toDouble() ?? 0.0,
      maturityDateEpoch: (json['maturity_date'] as num?)?.toInt() ?? 0,
      interestPayoutFrequency:
          json['interest_payout_frequency']?.toString() ?? 'ON_MATURITY',
      status: json['status']?.toString() ?? 'ACTIVE',
    );
  }
}

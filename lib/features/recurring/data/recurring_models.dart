// Typed models for the `/api/v1/payments` (mandates/recurring) backend API.
//
// All timestamp/date fields are transmitted as Unix epoch seconds (integers),
// not ISO/RFC3339 strings. Use [epochSecondsToDateTime] to convert to a
// [DateTime] for display formatting.

/// Converts an epoch-seconds value (as decoded from JSON — usually an `int`,
/// but tolerate `num`/numeric `String` just in case) into a [DateTime].
/// Returns `null` for `null`/missing/unparsable input.
DateTime? epochSecondsToDateTime(dynamic value) {
  if (value == null) return null;
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000);
  }
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) {
      return DateTime.fromMillisecondsSinceEpoch(parsed * 1000);
    }
  }
  return null;
}

class RecurringMandate {
  const RecurringMandate({
    required this.mandateId,
    required this.mandateType,
    required this.payeeName,
    this.payeeVpaOrId,
    this.category,
    this.bankName,
    required this.maxAmount,
    required this.frequency,
    required this.nextDebitDate,
    required this.status,
    this.approvedAt,
    this.createdAt,
  });

  final String mandateId;
  final String mandateType;
  final String payeeName;
  final String? payeeVpaOrId;
  final String? category;
  final String? bankName;
  final double maxAmount;
  final String frequency;
  /// Epoch seconds; nullable/omitted.
  final int? nextDebitDate;
  final String status;
  /// Epoch seconds; nullable/omitted.
  final int? approvedAt;
  /// Epoch seconds; always present.
  final int? createdAt;

  DateTime? get nextDebitDateTime => epochSecondsToDateTime(nextDebitDate);
  DateTime? get approvedAtDateTime => epochSecondsToDateTime(approvedAt);
  DateTime? get createdAtDateTime => epochSecondsToDateTime(createdAt);

  factory RecurringMandate.fromJson(Map<String, dynamic> json) {
    return RecurringMandate(
      mandateId: json['mandate_id']?.toString() ?? '',
      mandateType: json['mandate_type']?.toString() ?? 'UPI_AUTOPAY',
      payeeName: json['payee_name']?.toString() ?? '',
      payeeVpaOrId: json['payee_vpa_or_id']?.toString(),
      category: json['category']?.toString(),
      bankName: json['bank_name']?.toString(),
      maxAmount: (json['max_amount'] as num?)?.toDouble() ?? 0.0,
      frequency: json['frequency']?.toString() ?? 'MONTHLY',
      nextDebitDate: (json['next_debit_date'] as num?)?.toInt(),
      status: json['status']?.toString() ?? 'ACTIVE',
      approvedAt: (json['approved_at'] as num?)?.toInt(),
      createdAt: (json['created_at'] as num?)?.toInt(),
    );
  }
}

class MandateExecution {
  const MandateExecution({
    required this.scheduledDate,
    required this.amount,
    required this.status,
    this.failureReason,
    this.executedAt,
  });

  /// Epoch seconds.
  final int? scheduledDate;
  final double amount;
  final String status;
  final String? failureReason;
  /// Epoch seconds; nullable.
  final int? executedAt;

  DateTime? get scheduledDateTime => epochSecondsToDateTime(scheduledDate);
  DateTime? get executedAtDateTime => epochSecondsToDateTime(executedAt);

  factory MandateExecution.fromJson(Map<String, dynamic> json) {
    return MandateExecution(
      scheduledDate: (json['scheduled_date'] as num?)?.toInt(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? '',
      failureReason: json['failure_reason']?.toString(),
      executedAt: (json['executed_at'] as num?)?.toInt(),
    );
  }
}

class RecurringSummary {
  const RecurringSummary({
    required this.upcomingCount,
    required this.upcomingTotal,
    required this.overdueCount,
    required this.overdueTotal,
    required this.paidThisMonthCount,
    required this.paidThisMonthTotal,
  });

  final int upcomingCount;
  final double upcomingTotal;
  final int overdueCount;
  final double overdueTotal;
  final int paidThisMonthCount;
  final double paidThisMonthTotal;

  static const empty = RecurringSummary(
    upcomingCount: 0,
    upcomingTotal: 0,
    overdueCount: 0,
    overdueTotal: 0,
    paidThisMonthCount: 0,
    paidThisMonthTotal: 0,
  );

  factory RecurringSummary.fromJson(Map<String, dynamic> json) {
    return RecurringSummary(
      upcomingCount: (json['upcoming_count'] as num?)?.toInt() ?? 0,
      upcomingTotal: (json['upcoming_total'] as num?)?.toDouble() ?? 0.0,
      overdueCount: (json['overdue_count'] as num?)?.toInt() ?? 0,
      overdueTotal: (json['overdue_total'] as num?)?.toDouble() ?? 0.0,
      paidThisMonthCount: (json['paid_this_month_count'] as num?)?.toInt() ?? 0,
      paidThisMonthTotal: (json['paid_this_month_total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class MandateActionResult {
  const MandateActionResult({
    required this.mandateId,
    required this.status,
    required this.effectiveFrom,
  });

  final String mandateId;
  final String status;
  /// Epoch seconds.
  final int? effectiveFrom;

  DateTime? get effectiveFromDateTime => epochSecondsToDateTime(effectiveFrom);

  factory MandateActionResult.fromJson(Map<String, dynamic> json) {
    return MandateActionResult(
      mandateId: json['mandate_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      effectiveFrom: (json['effective_from'] as num?)?.toInt(),
    );
  }
}

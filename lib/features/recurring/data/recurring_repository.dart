import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/features/recurring/data/recurring_models.dart';

/// Wraps the `/api/v1/payments/*` (mandates/recurring) endpoints.
class RecurringRepository {
  const RecurringRepository(this._client);

  final DioApiClient _client;

  Future<List<RecurringMandate>> listMandates({String? statusFilter}) async {
    try {
      final response = await _client.dio.get(
        '/api/v1/payments/mandates',
        queryParameters: {
          if (statusFilter != null && statusFilter.isNotEmpty) 'status_filter': statusFilter,
        },
      );
      return _client.unwrapList(
        response.data as Map<String, dynamic>,
        RecurringMandate.fromJson,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  Future<RecurringSummary> summary() async {
    try {
      final response = await _client.dio.get('/api/v1/payments/mandates/summary');
      return _client.unwrap(
        response.data as Map<String, dynamic>,
        RecurringSummary.fromJson,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// [mandateStartDate] and [mandateEndDate] are Unix epoch seconds.
  Future<RecurringMandate> createMandate({
    String? bankAccountId,
    String? upiId,
    String? mandateType,
    required String payeeName,
    String? payeeVpaOrId,
    String? category,
    required double mandateAmount,
    required String mandateFrequency,
    required int mandateStartDate,
    int? mandateEndDate,
  }) async {
    try {
      final response = await _client.dio.post(
        '/api/v1/payments/mandates',
        data: {
          'bank_account_id': bankAccountId ?? '',
          'upi_id': upiId ?? '',
          'mandate_type': mandateType ?? 'UPI_AUTOPAY',
          'payee_name': payeeName,
          'payee_vpa_or_id': payeeVpaOrId ?? '',
          'category': category ?? '',
          'mandate_amount': mandateAmount,
          'mandate_frequency': mandateFrequency,
          'mandate_start_date': mandateStartDate,
          if (mandateEndDate != null) 'mandate_end_date': mandateEndDate,
        },
      );
      return _client.unwrap(
        response.data as Map<String, dynamic>,
        RecurringMandate.fromJson,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// [pauseUntilDate] is Unix epoch seconds (accepted but not enforced
  /// server-side).
  Future<MandateActionResult> mandateAction(
    String mandateId,
    String action, {
    int? pauseUntilDate,
  }) async {
    try {
      final response = await _client.dio.post(
        '/api/v1/payments/mandates/$mandateId/action',
        data: {
          'action': action,
          if (pauseUntilDate != null) 'pause_until_date': pauseUntilDate,
        },
      );
      return _client.unwrap(
        response.data as Map<String, dynamic>,
        MandateActionResult.fromJson,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  Future<List<MandateExecution>> history(String mandateId) async {
    try {
      final response = await _client.dio.get('/api/v1/payments/mandates/$mandateId/history');
      return _client.unwrapList(
        response.data as Map<String, dynamic>,
        MandateExecution.fromJson,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}

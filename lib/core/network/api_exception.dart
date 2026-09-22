/// Typed exception carrying a human-readable message extracted from a
/// backend error response (either the `/api/v1` envelope
/// `{"error": bool, "message": string, "data": ...}` or the auth-specific
/// shape `{"error": "<message>", "code": <int>}`), or from a network/Dio
/// failure that never reached the server.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

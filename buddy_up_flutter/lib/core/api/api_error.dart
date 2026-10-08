import 'package:dio/dio.dart';

/// Every API failure in this app is a `DioException` carrying the backend's
/// `{success, data, message, errors, pagination}` envelope — or a bare DRF body
/// (`{detail}` / `{errors}`) from the views that never adopted the envelope.
///
/// These three helpers read that envelope once so each surface shows the
/// *server's own* wording instead of a generic string. That matters most for
/// checkout: the backend rejects a short wallet with `Insufficient dumbbell
/// tokens.`, and a client that prints `DioException [bad response]` has thrown
/// away the only sentence the buyer needed.

/// HTTP status behind [error], or null when it never reached the server.
int? apiStatusCode(Object error) {
  if (error is DioException) return error.response?.statusCode;
  return null;
}

String _flattenErrors(Object? errors) {
  if (errors == null) return '';
  if (errors is List) {
    return errors.map((e) => '$e').where((e) => e.isNotEmpty).join(' ');
  }
  if (errors is Map) {
    return errors.entries
        .map((e) => '${e.key}: ${e.value is List ? (e.value as List).join(' ') : e.value}')
        .join(' ');
  }
  return '$errors';
}

/// Best-effort human message for a failed call, joined with an em dash.
///
/// Prefers `message` (the envelope every platform view returns), falls back to
/// `detail` (DRF) and then to a flattened `errors` map, so a field-level
/// validation failure still says which field failed.
String apiErrorMessage(Object error, {String fallback = 'Something went wrong.'}) {
  final body = error is DioException ? error.response?.data : null;
  if (body is Map) {
    final message = body['message'];
    final detail = body['detail'];
    final parts = [
      if (message is String && message.trim().isNotEmpty) message.trim(),
      if (detail is String && detail.trim().isNotEmpty) detail.trim(),
      _flattenErrors(body['errors']),
    ].where((p) => p.isNotEmpty);
    if (parts.isNotEmpty) return parts.join(' — ');
  }
  return fallback;
}

/// True when the admin guard rejected a non-staff session.
bool isAdminPrivilegeError(Object error) => apiStatusCode(error) == 403;
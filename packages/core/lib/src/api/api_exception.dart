/// Thrown for any non-2xx response. [message] is the server's own
/// human-readable `error` field where available, so error states can show
/// it directly (see section 34 of the product spec: every error needs a
/// useful, specific message and a recovery action).
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Thrown when a request never reaches the server at all (no connectivity,
/// server not running, DNS failure, etc.) — distinct from a server-returned
/// error so the UI can show a "Network unavailable" state instead of a
/// generic one.
class NetworkUnavailableException extends ApiException {
  NetworkUnavailableException() : super('Network unavailable. Check your connection and try again.');
}

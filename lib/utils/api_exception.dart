/// Structured API exception for better error handling
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String category;
  final String? endpoint;
  final Map<String, dynamic>? details;

  const ApiException({
    required this.statusCode,
    required this.message,
    required this.category,
    this.endpoint,
    this.details,
  });

  @override
  String toString() {
    return 'ApiException($statusCode): $message [${endpoint ?? 'unknown'}]';
  }

  /// Create from HTTP response
  factory ApiException.fromResponse({
    required int statusCode,
    required String endpoint,
    String? responseBody,
    Map<String, dynamic>? responseData,
  }) {
    String message;
    String category;
    Map<String, dynamic>? details;

    if (responseData != null) {
      message = responseData['error'] ?? responseData['message'] ?? 'Unknown error';
      category = _categorizeError(statusCode, message);
      details = responseData;
    } else {
      message = responseBody ?? 'HTTP $statusCode error';
      category = _categorizeError(statusCode, message);
    }

    return ApiException(
      statusCode: statusCode,
      message: message,
      category: category,
      endpoint: endpoint,
      details: details,
    );
  }

  /// Create from network/parsing errors
  factory ApiException.fromError({
    required String endpoint,
    required String error,
  }) {
    return ApiException(
      statusCode: 0, // Network/parsing error
      message: error,
      category: 'network_error',
      endpoint: endpoint,
    );
  }

  /// Categorize error for better handling
  static String _categorizeError(int statusCode, String message) {
    if (statusCode == 0) return 'network_error';
    if (statusCode >= 400 && statusCode < 500) {
      if (statusCode == 401) return 'authentication_error';
      if (statusCode == 403) return 'authorization_error';
      if (statusCode == 404) return 'not_found_error';
      if (statusCode == 409) return 'conflict_error';
      if (statusCode == 422) return 'validation_error';
      return 'client_error';
    }
    if (statusCode >= 500) return 'server_error';
    return 'unknown_error';
  }

  /// Check if this is a retryable error
  bool get isRetryable {
    return statusCode == 0 || // Network error
           statusCode == 408 || // Timeout
           statusCode == 429 || // Rate limit
           (statusCode >= 500 && statusCode < 600); // Server errors
  }

  /// Check if this is an authentication error
  bool get isAuthenticationError {
    return statusCode == 401 || category == 'authentication_error';
  }

  /// Check if this is an authorization error
  bool get isAuthorizationError {
    return statusCode == 403 || category == 'authorization_error';
  }
}

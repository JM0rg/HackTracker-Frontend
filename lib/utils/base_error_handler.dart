import 'api_exception.dart';

/// Base error handler with shared error patterns and utilities
abstract class BaseErrorHandler {
  // Shared error patterns that are common across all error handlers
  static const Map<String, String> _sharedErrorPatterns = {
    // Network errors
    'Network error': 'Network error. Please check your connection and try again.',
    'NetworkException': 'Network error. Please check your connection and try again.',
    'TimeoutException': 'Request timed out. Please check your connection and try again.',
    'timeout': 'Request timed out. Please check your connection and try again.',
    'Connection refused': 'Network error. Please check your connection and try again.',
    'Connection timeout': 'Network error. Please check your connection and try again.',
    'No internet connection': 'No internet connection. Please check your network and try again.',
    
    // Server errors
    'Service error occurred': 'A service error occurred. Please try again later.',
    'Internal server error': 'Server error. Please try again later.',
    'Server error': 'Server error. Please try again later.',
    '500': 'Server error. Please try again later.',
    '502': 'Server error. Please try again later.',
    '503': 'Server error. Please try again later.',
    '504': 'Server error. Please try again later.',
  };

  // Regex patterns for more precise matching
  static const Map<RegExp, String> _regexPatterns = {
    // Authentication errors - exact matches
    RegExp(r'^NotAuthorizedException$'): 'Please sign in again to continue.',
    RegExp(r'^UserNotAuthorizedException$'): 'You do not have permission to perform this action.',
    RegExp(r'^AuthSessionExpiredException$'): 'Your session has expired. Please sign in again.',
    RegExp(r'^TokenExpiredException$'): 'Your session has expired. Please sign in again.',
    
    // Network errors - more specific patterns
    RegExp(r'^NetworkException$'): 'Network error. Please check your connection and try again.',
    RegExp(r'^TimeoutException$'): 'Request timed out. Please check your connection and try again.',
    RegExp(r'^ConnectionException$'): 'Network error. Please check your connection and try again.',
    
    // Amplify errors - exact matches
    RegExp(r'^AmplifyAlreadyConfiguredException$'): 'Authentication service is already initialized.',
    RegExp(r'^AmplifyException$'): 'Service error occurred. Please try again.',
    RegExp(r'^ConfigurationException$'): 'Service configuration error. Please try again later.',
    RegExp(r'^StorageException$'): 'Data storage error. Please try again.',
    
    // HTTP status codes
    RegExp(r'^HTTP 401$'): 'Please sign in again to continue.',
    RegExp(r'^HTTP 403$'): 'You do not have permission to perform this action.',
    RegExp(r'^HTTP 404$'): 'The requested resource could not be found.',
    RegExp(r'^HTTP 409$'): 'This action conflicts with existing data. Please try again.',
    RegExp(r'^HTTP 422$'): 'Please check your input and try again.',
    RegExp(r'^HTTP 5\d\d$'): 'Server error. Please try again later.',
  };

  /// Handle ApiException with specific error categories
  static String getApiExceptionMessage(ApiException exception) {
    switch (exception.category) {
      case 'authentication_error':
        return 'Please sign in again to continue.';
      case 'authorization_error':
        return 'You do not have permission to perform this action.';
      case 'not_found_error':
        return 'The requested resource could not be found.';
      case 'validation_error':
        return 'Please check your input and try again.';
      case 'conflict_error':
        return 'This action conflicts with existing data. Please try again.';
      case 'network_error':
        return 'Network error. Please check your connection and try again.';
      case 'server_error':
        return 'Server error. Please try again later.';
      default:
        return exception.message.isNotEmpty 
            ? exception.message 
            : 'Something went wrong. Please try again.';
    }
  }

  /// Convert technical error messages to user-friendly ones using shared patterns
  static String getFriendlyErrorMessage(dynamic error, Map<String, String> customPatterns) {
    // Handle ApiException directly
    if (error is ApiException) {
      return getApiExceptionMessage(error);
    }
    
    final errorString = error.toString();
    
    // First, try regex patterns for exact matches
    for (final entry in _regexPatterns.entries) {
      if (entry.key.hasMatch(errorString)) {
        return entry.value;
      }
    }
    
    // Then try custom patterns (domain-specific)
    for (final entry in customPatterns.entries) {
      if (errorString.contains(entry.key)) {
        return entry.value;
      }
    }
    
    // Finally, try shared patterns
    for (final entry in _sharedErrorPatterns.entries) {
      if (errorString.contains(entry.key)) {
        return entry.value;
      }
    }
    
    // For any other errors, show a generic message
    return 'Something went wrong. Please try again.';
  }

  /// Check if error indicates a network connectivity issue
  static bool isNetworkError(dynamic error) {
    if (error is ApiException) {
      return error.category == 'network_error';
    }
    
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') || 
           errorString.contains('connection') || 
           errorString.contains('timeout') ||
           errorString.contains('offline');
  }

  /// Check if error indicates an authentication issue
  static bool isAuthenticationError(dynamic error) {
    if (error is ApiException) {
      return error.category == 'authentication_error';
    }
    
    final errorString = error.toString().toLowerCase();
    return errorString.contains('unauthorized') || 
           errorString.contains('authentication') ||
           errorString.contains('token') ||
           errorString.contains('session');
  }

  /// Check if error indicates an authorization issue
  static bool isAuthorizationError(dynamic error) {
    if (error is ApiException) {
      return error.category == 'authorization_error';
    }
    
    final errorString = error.toString().toLowerCase();
    return errorString.contains('forbidden') || 
           errorString.contains('authorization') ||
           errorString.contains('permission') ||
           errorString.contains('access denied');
  }
}

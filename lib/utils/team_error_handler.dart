import 'api_exception.dart';
import 'base_error_handler.dart';

/// Team error handling utilities
/// Contains logic for converting technical error messages to user-friendly ones
class TeamErrorHandler extends BaseErrorHandler {
  // Map of error patterns to user-friendly messages
  static const Map<String, String> _teamErrorPatterns = {
    // Network errors
    'Network error': 'Network error. Please check your connection and try again.',
    'NetworkException': 'Network error. Please check your connection and try again.',
    'TimeoutException': 'Request timed out. Please check your connection and try again.',
    'timeout': 'Request timed out. Please check your connection and try again.',
    'Connection': 'Network error. Please check your connection and try again.',
    
    // Authentication errors
    '401': 'Your session has expired. Please sign in again.',
    'Unauthorized': 'Your session has expired. Please sign in again.',
    'Authentication failed': 'Your session has expired. Please sign in again.',
    'Invalid token': 'Your session has expired. Please sign in again.',
    'Token expired': 'Your session has expired. Please sign in again.',
    
    // Permission errors
    '403': 'You don\'t have permission to perform this action.',
    'Forbidden': 'You don\'t have permission to perform this action.',
    'Access denied': 'You don\'t have permission to perform this action.',
    'Insufficient permissions': 'You don\'t have permission to perform this action.',
    
    // Not found errors
    '404': 'The requested resource was not found.',
    'Not found': 'The requested resource was not found.',
    'Team not found': 'This team no longer exists or you don\'t have access to it.',
    'User not found': 'User not found.',
    'Player not found': 'Player not found.',
    
    // Validation errors
    '400': 'Invalid request. Please check your input and try again.',
    'Bad Request': 'Invalid request. Please check your input and try again.',
    'Validation error': 'Invalid input. Please check your information and try again.',
    'Invalid parameter': 'Invalid input. Please check your information and try again.',
    'Missing required field': 'Please fill in all required fields.',
    
    // Conflict errors
    '409': 'This action conflicts with the current state. Please refresh and try again.',
    'Conflict': 'This action conflicts with the current state. Please refresh and try again.',
    'Already exists': 'This item already exists.',
    'Duplicate': 'This item already exists.',
    
    // Rate limiting
    '429': 'Too many requests. Please wait a moment and try again.',
    'Rate limit': 'Too many requests. Please wait a moment and try again.',
    'Too many requests': 'Too many requests. Please wait a moment and try again.',
    
    // Server errors
    '500': 'Server error occurred. Please try again later.',
    'Internal Server Error': 'Server error occurred. Please try again later.',
    'Service unavailable': 'Service temporarily unavailable. Please try again later.',
    '503': 'Service temporarily unavailable. Please try again later.',
    
    // Team-specific errors
    'Team name already exists': 'A team with this name already exists. Please choose a different name.',
    'Maximum team members reached': 'This team has reached the maximum number of members.',
    'Cannot remove last owner': 'Cannot remove the last owner from the team.',
    'Invalid team role': 'Invalid team role specified.',
    'Player already on team': 'This player is already on the team.',
    'Invite already exists': 'An invite for this email already exists.',
    'Invite expired': 'This invite has expired. Please request a new one.',
  };

  /// Convert technical error messages to user-friendly ones
  static String getFriendlyErrorMessage(dynamic error) {
    return BaseErrorHandler.getFriendlyErrorMessage(error, _teamErrorPatterns);
  }

  /// Check if error indicates a network connectivity issue
  static bool isNetworkError(dynamic error) {
    return BaseErrorHandler.isNetworkError(error);
  }

  /// Check if error indicates an authentication issue
  static bool isAuthError(dynamic error) {
    return BaseErrorHandler.isAuthenticationError(error);
  }

  /// Check if error indicates a permission issue
  static bool isPermissionError(dynamic error) {
    return BaseErrorHandler.isAuthorizationError(error);
  }

  /// Check if error indicates a validation issue
  static bool isValidationError(String error) {
    return error.contains('400') ||
           error.contains('Bad Request') ||
           error.contains('Validation error') ||
           error.contains('Invalid parameter') ||
           error.contains('Missing required field');
  }

  /// Get error category for analytics or logging
  static String getErrorCategory(String error) {
    if (isNetworkError(error)) return 'network';
    if (isAuthError(error)) return 'authentication';
    if (isPermissionError(error)) return 'permission';
    if (isValidationError(error)) return 'validation';
    if (error.contains('404') || error.contains('Not found')) return 'not_found';
    if (error.contains('409') || error.contains('Conflict')) return 'conflict';
    if (error.contains('429') || error.contains('Rate limit')) return 'rate_limit';
    if (error.contains('500') || error.contains('Internal Server Error')) return 'server_error';
    return 'unknown';
  }

  /// Get suggested action for the user based on error type
  static String getSuggestedAction(String error) {
    if (isNetworkError(error)) {
      return 'Check your internet connection and try again.';
    } else if (isAuthError(error)) {
      return 'Please sign in again.';
    } else if (isPermissionError(error)) {
      return 'Contact your team owner or administrator.';
    } else if (isValidationError(error)) {
      return 'Please check your input and try again.';
    } else if (error.contains('404') || error.contains('Not found')) {
      return 'The item may have been deleted or you may not have access to it.';
    } else if (error.contains('409') || error.contains('Conflict')) {
      return 'Refresh the page and try again.';
    } else if (error.contains('429') || error.contains('Rate limit')) {
      return 'Wait a few minutes before trying again.';
    } else {
      return 'Please try again or contact support if the problem continues.';
    }
  }
}

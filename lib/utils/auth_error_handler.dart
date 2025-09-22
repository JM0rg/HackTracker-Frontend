import 'api_exception.dart';
import 'base_error_handler.dart';

/// Authentication error handling utilities
/// Contains logic for converting technical error messages to user-friendly ones
class AuthErrorHandler extends BaseErrorHandler {
  // Authentication-specific error patterns
  static const Map<String, String> _authErrorPatterns = {
    // Authentication errors
    'Incorrect username or password': 'Invalid email or password. Please try again.',
    'User does not exist': 'No account found with this email address.',
    'User is not confirmed': 'Please verify your email before signing in.',
    'Password attempts exceeded': 'Too many failed login attempts. Please try again later.',
    'UsernameExistsException': 'An account with this email address already exists.',
    'InvalidPasswordException': 'Password must be 8+ characters with uppercase, lowercase, number & symbol.',
    'UserNotFoundException': 'No account found with this email address.',
    'NotAuthorizedException': 'Invalid email or password. Please try again.',
    'UserNotConfirmedException': 'Please verify your email before signing in.',
    
    // Verification errors
    'CodeMismatchException': 'Invalid verification code. Please check the code and try again.',
    'ExpiredCodeException': 'Verification code has expired. Please request a new code.',
    
    // Rate limiting errors
    'LimitExceededException': 'Too many requests. Please wait and try again.',
    'TooManyRequestsException': 'Too many requests. Please wait and try again.',
    
    // Service errors
    'InvalidParameterException': 'Invalid input. Please check your information and try again.',
    'ResourceNotFoundException': 'Service temporarily unavailable. Please try again later.',
    'InternalErrorException': 'Service error occurred. Please try again later.',
    'ServiceUnavailableException': 'Service temporarily unavailable. Please try again later.',
  };

  /// Convert technical error messages to user-friendly ones
  static String getFriendlyErrorMessage(dynamic error) {
    return BaseErrorHandler.getFriendlyErrorMessage(error, _authErrorPatterns);
  }

  /// Check if error indicates a network connectivity issue
  static bool isNetworkError(dynamic error) {
    return BaseErrorHandler.isNetworkError(error);
  }

  /// Check if error indicates user input validation issue
  static bool isValidationError(String error) {
    return error.contains('InvalidParameterException') ||
           error.contains('InvalidPasswordException') ||
           error.contains('CodeMismatchException') ||
           error.contains('Incorrect username or password');
  }

  /// Check if error indicates a rate limiting issue
  static bool isRateLimitError(String error) {
    return error.contains('LimitExceededException') ||
           error.contains('TooManyRequestsException') ||
           error.contains('Password attempts exceeded');
  }

  /// Check if error indicates account verification is needed
  static bool isVerificationError(String error) {
    return error.contains('User is not confirmed') ||
           error.contains('UserNotConfirmedException');
  }

  /// Get error category for analytics or logging
  static String getErrorCategory(String error) {
    if (isNetworkError(error)) return 'network';
    if (isValidationError(error)) return 'validation';
    if (isRateLimitError(error)) return 'rate_limit';
    if (isVerificationError(error)) return 'verification';
    return 'unknown';
  }

  /// Get suggested action for the user based on error type
  static String getSuggestedAction(String error) {
    if (isNetworkError(error)) {
      return 'Check your internet connection and try again.';
    } else if (isRateLimitError(error)) {
      return 'Wait a few minutes before trying again.';
    } else if (isVerificationError(error)) {
      return 'Check your email for a verification link.';
    } else if (error.contains('UsernameExistsException')) {
      return 'Try signing in instead, or use a different email address.';
    } else if (error.contains('User does not exist')) {
      return 'Check your email address or create a new account.';
    } else {
      return 'Please try again or contact support if the problem continues.';
    }
  }
}

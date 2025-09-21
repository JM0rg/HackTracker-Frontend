/// Authentication error handling utilities
/// Contains logic for converting technical error messages to user-friendly ones
class AuthErrorHandler {
  /// Convert technical error messages to user-friendly ones
  static String getFriendlyErrorMessage(String error) {
    if (error.contains('Incorrect username or password')) {
      return 'Invalid email or password. Please try again.';
    } else if (error.contains('User does not exist')) {
      return 'No account found with this email address.';
    } else if (error.contains('User is not confirmed')) {
      return 'Please verify your email before signing in.';
    } else if (error.contains('Password attempts exceeded')) {
      return 'Too many failed login attempts. Please try again later.';
    } else if (error.contains('Network error') || error.contains('NetworkException')) {
      return 'Network error. Please check your connection and try again.';
    } else if (error.contains('UsernameExistsException')) {
      return 'An account with this email address already exists.';
    } else if (error.contains('InvalidPasswordException')) {
      return 'Password must be 8+ characters with uppercase, lowercase, number & symbol.';
    } else if (error.contains('CodeMismatchException')) {
      return 'Invalid verification code. Please check the code and try again.';
    } else if (error.contains('ExpiredCodeException')) {
      return 'Verification code has expired. Please request a new code.';
    } else if (error.contains('LimitExceededException')) {
      return 'Too many requests. Please wait and try again.';
    } else if (error.contains('UserNotFoundException')) {
      return 'No account found with this email address.';
    } else if (error.contains('NotAuthorizedException')) {
      return 'Invalid email or password. Please try again.';
    } else if (error.contains('UserNotConfirmedException')) {
      return 'Please verify your email before signing in.';
    } else if (error.contains('TooManyRequestsException')) {
      return 'Too many requests. Please wait and try again.';
    } else if (error.contains('InvalidParameterException')) {
      return 'Invalid input. Please check your information and try again.';
    } else if (error.contains('ResourceNotFoundException')) {
      return 'Service temporarily unavailable. Please try again later.';
    } else if (error.contains('InternalErrorException')) {
      return 'Service error occurred. Please try again later.';
    } else if (error.contains('ServiceUnavailableException')) {
      return 'Service temporarily unavailable. Please try again later.';
    } else if (error.contains('TimeoutException') || error.contains('timeout')) {
      return 'Request timed out. Please check your connection and try again.';
    } else {
      // For any other errors, show a generic message
      return 'Something went wrong. Please try again.';
    }
  }

  /// Check if error indicates a network connectivity issue
  static bool isNetworkError(String error) {
    return error.contains('Network') || 
           error.contains('Connection') || 
           error.contains('timeout') ||
           error.contains('TimeoutException') ||
           error.contains('NetworkException');
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

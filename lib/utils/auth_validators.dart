/// Authentication validation utilities
/// Contains all validation logic for authentication forms
class AuthValidators {
  // Regular expressions
  static final RegExp _emailRegex = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");
  static final RegExp _passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).*$');

  // Validation constants
  static const int minPasswordLength = 8;

  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    
    final trimmedValue = value.trim();
    if (!_emailRegex.hasMatch(trimmedValue)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }

  /// Validates password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    
    if (value.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters';
    }
    
    if (!_passwordRegex.hasMatch(value)) {
      return 'Password must have uppercase, lowercase, number & symbol';
    }
    
    return null;
  }

  /// Validates password confirmation matches original password
  static String? validatePasswordConfirmation(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  /// Validates required text field (first name, last name, etc.)
  static String? validateRequiredText(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $fieldName';
    }
    
    return null;
  }


  /// Checks if email format is valid (without error message)
  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim());
  }

  /// Checks if password meets requirements (without error message)
  static bool isValidPassword(String password) {
    return password.length >= minPasswordLength && _passwordRegex.hasMatch(password);
  }

  /// Gets password strength as a percentage (0-100)
  static int getPasswordStrength(String password) {
    if (password.isEmpty) return 0;
    
    int strength = 0;
    
    // Length check (0-40 points)
    if (password.length >= minPasswordLength) {
      strength += 20;
      if (password.length >= 12) strength += 10;
      if (password.length >= 16) strength += 10;
    }
    
    // Character variety checks (15 points each)
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 15; // lowercase
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 15; // uppercase
    if (RegExp(r'\d').hasMatch(password)) strength += 15;    // numbers
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) strength += 15; // symbols (any non-alphanumeric)
    
    return strength.clamp(0, 100);
  }

  /// Gets password strength description
  static String getPasswordStrengthText(int strength) {
    if (strength < 25) return 'Weak';
    if (strength < 50) return 'Fair';
    if (strength < 75) return 'Good';
    return 'Strong';
  }

  /// Gets password strength color
  static int getPasswordStrengthColor(int strength) {
    if (strength < 25) return 0xFFFF4444; // Red
    if (strength < 50) return 0xFFFF8800; // Orange
    if (strength < 75) return 0xFFFFDD00; // Yellow
    return 0xFF00FF88; // Green
  }

  /// Validates form data for signup
  static Map<String, String?> validateSignupForm({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return {
      'firstName': validateRequiredText(firstName, 'first name'),
      'lastName': validateRequiredText(lastName, 'last name'),
      'email': validateEmail(email),
      'password': validatePassword(password),
      'confirmPassword': validatePasswordConfirmation(confirmPassword, password),
    };
  }

  /// Validates form data for login
  static Map<String, String?> validateLoginForm({
    required String email,
    required String password,
  }) {
    return {
      'email': validateEmail(email),
      'password': password.isEmpty ? 'Please enter your password' : null,
    };
  }

  /// Sanitizes email input (trims and converts to lowercase)
  static String sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  /// Sanitizes name input (trims and capitalizes first letter)
  static String sanitizeName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return trimmed;
    
    return trimmed.substring(0, 1).toUpperCase() + 
           (trimmed.length > 1 ? trimmed.substring(1).toLowerCase() : '');
  }
}

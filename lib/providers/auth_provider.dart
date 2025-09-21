import 'package:flutter/foundation.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../services/auth_service.dart';
import '../utils/auth_error_handler.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthUser? _currentUser;
  bool _isLoading = false;
  bool _isSignedIn = false;
  String? _error;
  Map<String, String>? _tokens;

  // Getters
  AuthUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isSignedIn => _isSignedIn;
  String? get error => _error;
  Map<String, String>? get tokens => _tokens;
  String? get userId => _currentUser?.userId;
  String? get accessToken => _tokens?['accessToken'];

  /// Initialize authentication state
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _authService.configureAmplify();
      await _checkAuthStatus();
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Check current authentication status
  Future<void> _checkAuthStatus() async {
    try {
      _isSignedIn = await _authService.isSignedIn();
      if (_isSignedIn) {
        _currentUser = await _authService.getCurrentUser();
        _tokens = await _authService.getTokens();
      } else {
        _currentUser = null;
        _tokens = null;
      }
      _clearError();
    } catch (e) {
      _setError('Failed to check auth status: $e');
      _isSignedIn = false;
      _currentUser = null;
      _tokens = null;
    }
  }

  /// Sign up a new user
  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    _setLoading(true);
    try {
      final result = await _authService.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      
      // In test environment, users are auto-confirmed and signed in
      if (result.isSignUpComplete) {
        await _checkAuthStatus();
      }
      
      _clearError();
      return result.isSignUpComplete;
    } catch (e) {
      _setError(AuthErrorHandler.getFriendlyErrorMessage(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }


  /// Sign in user
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final result = await _authService.signIn(
        email: email,
        password: password,
      );
      
      if (result.isSignedIn) {
        await _checkAuthStatus();
        _clearError();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(AuthErrorHandler.getFriendlyErrorMessage(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _currentUser = null;
      _tokens = null;
      _isSignedIn = false;
      _clearError();
    } catch (e) {
      _setError('Sign out failed: $e');
    } finally {
      _setLoading(false);
    }
  }


  /// Reset password
  Future<bool> resetPassword({required String email}) async {
    _setLoading(true);
    try {
      await _authService.resetPassword(email: email);
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to reset password: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Confirm password reset
  Future<bool> confirmResetPassword({
    required String email,
    required String newPassword,
    required String confirmationCode,
  }) async {
    _setLoading(true);
    try {
      await _authService.confirmResetPassword(
        email: email,
        newPassword: newPassword,
        confirmationCode: confirmationCode,
      );
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to confirm password reset: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

}

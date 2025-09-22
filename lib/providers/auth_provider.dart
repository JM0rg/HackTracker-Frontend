import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../utils/auth_error_handler.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  AuthUser? _currentUser;
  bool _isLoading = false;
  bool _isSignedIn = false;
  String? _error;
  Map<String, String>? _tokens;
  bool _isProfileValidating = false;
  
  // Profile validation retry management
  Timer? _profileValidationTimer;
  int _profileValidationAttempts = 0;
  static const int _maxProfileValidationAttempts = 10;
  static const Duration _profileValidationRetryInterval = Duration(seconds: 10);
  
  // Token refresh coordination to prevent concurrent refresh attempts
  bool _refreshInProgress = false;
  Completer<Map<String, String>?>? _refreshCompleter;
  
  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _idTokenKey = 'id_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';

  // Getters
  AuthUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isSignedIn => _isSignedIn;
  String? get error => _error;
  String? get userId => _currentUser?.userId;
  bool get isProfileValidating => _isProfileValidating;

  /// Get authorization header for API requests (safe, encapsulated)
  Future<String?> getAuthorizationHeader() async {
    final tokens = await _getTokensWithRefresh();
    final accessToken = tokens?['accessToken'];
    return accessToken != null ? 'Bearer $accessToken' : null;
  }

  /// Get ID token for email-based operations (safe, encapsulated)
  Future<String?> getIdToken() async {
    final tokens = await _getTokensWithRefresh();
    return tokens?['idToken'];
  }

  /// Check if user has valid authentication tokens
  Future<bool> hasValidTokens() async {
    final tokens = await _getTokensWithRefresh();
    return tokens != null && tokens['accessToken'] != null;
  }

  /// Get token expiry information for debugging (debug mode only)
  Map<String, dynamic>? getTokenInfo() {
    if (!kDebugMode) return null; // Only available in debug mode
    if (_tokens == null) return null;
    
    try {
      final accessToken = _tokens!['accessToken'];
      if (accessToken == null) return null;
      
      final parts = accessToken.split('.');
      if (parts.length != 3) return null;
      
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final payloadJson = jsonDecode(payload) as Map<String, dynamic>;
      
      final exp = payloadJson['exp'] as int?;
      if (exp == null) return null;
      
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();
      final timeUntilExpiry = expiry.difference(now);
      
      return {
        'expires_at': expiry.toIso8601String(),
        'expires_in_minutes': timeUntilExpiry.inMinutes,
        'is_expired': now.isAfter(expiry),
        'needs_refresh': now.isAfter(expiry.subtract(const Duration(minutes: 5))),
      };
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Auth: Error getting token info: $e');
      }
      return null;
    }
  }

  /// Initialize authentication state
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // Only configure Amplify if not already configured
      if (!Amplify.isConfigured) {
        await _authService.configureAmplify();
      } else if (kDebugMode) {
        print('✅ Auth: Amplify already configured, skipping configuration');
      }
      
      // Try to restore tokens from secure storage first
      await _restoreTokensFromStorage();
      
      await _checkAuthStatus();
    } catch (e) {
      _setError(AuthErrorHandler.getFriendlyErrorMessage(e.toString()));
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh session (re-fetch current user and tokens)
  Future<void> refreshSession() async {
    // Check if refresh is already in progress
    if (_refreshInProgress) {
      if (kDebugMode) {
        print('⏳ Auth: Token refresh already in progress, skipping session refresh');
      }
      return;
    }
    
    _refreshInProgress = true;
    try {
      if (kDebugMode) {
        print('🔄 Auth: Refreshing session...');
      }
      
      // Explicitly refresh tokens first
      final refreshedTokens = await _authService.refreshTokens();
      if (refreshedTokens != null) {
        _tokens = refreshedTokens;
        await _storeTokensSecurely(refreshedTokens);
        if (kDebugMode) {
          print('✅ Auth: Session refreshed successfully');
        }
      } else {
        if (kDebugMode) {
          print('❌ Auth: Failed to refresh tokens, checking auth status');
        }
        await _checkAuthStatus();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Auth: Error refreshing session: $e');
      }
      
      // Check if it's a refresh token expiry error
      final errorString = e.toString().toLowerCase();
      final isRefreshTokenExpired = errorString.contains('notauthorizedexception') ||
                                   errorString.contains('tokenexpiredexception') ||
                                   errorString.contains('invalid_grant') ||
                                   errorString.contains('refresh token') ||
                                   (errorString.contains('unauthorized') && errorString.contains('token'));
      
      if (isRefreshTokenExpired) {
        if (kDebugMode) {
          print('🚨 Auth: Refresh token expired during session refresh, forcing sign out');
        }
        await _handleRefreshTokenExpiry();
      } else {
        // For other errors, check auth status normally
        await _checkAuthStatus();
      }
    } finally {
      _refreshInProgress = false;
    }
  }

  /// Store tokens securely
  Future<void> _storeTokensSecurely(Map<String, String> tokens) async {
    try {
      await _secureStorage.write(key: _accessTokenKey, value: tokens['accessToken']);
      await _secureStorage.write(key: _idTokenKey, value: tokens['idToken']);
      if (tokens['refreshToken'] != null) {
        await _secureStorage.write(key: _refreshTokenKey, value: tokens['refreshToken']);
      }
      if (kDebugMode) {
        print('🔐 Auth: Tokens stored securely (including refresh token)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Auth: Failed to store tokens securely: $e');
      }
    }
  }

  /// Restore tokens from secure storage
  Future<void> _restoreTokensFromStorage() async {
    try {
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      final idToken = await _secureStorage.read(key: _idTokenKey);
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      
      if (accessToken != null && idToken != null) {
        _tokens = {
          'accessToken': accessToken,
          'idToken': idToken,
        };
        if (refreshToken != null) {
          _tokens!['refreshToken'] = refreshToken;
        }
        if (kDebugMode) {
          print('🔐 Auth: Tokens restored from secure storage (including refresh token)');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Auth: Failed to restore tokens from storage: $e');
      }
    }
  }

  /// Clear tokens from secure storage
  Future<void> _clearStoredTokens() async {
    try {
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _idTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _userIdKey);
      if (kDebugMode) {
        print('🔐 Auth: Tokens cleared from secure storage (including refresh token)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Auth: Failed to clear stored tokens: $e');
      }
    }
  }

  /// Decode JWT token payload
  Map<String, dynamic>? _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      return jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Check if tokens need refresh (with 5-minute buffer before expiry)
  bool _shouldRefreshTokens() {
    if (_tokens == null) return true;
    
    final accessToken = _tokens!['accessToken'];
    if (accessToken == null) return true;
    
    final payload = _decodeJwt(accessToken);
    if (payload == null) return true;
    
    // Get expiration time
    final exp = payload['exp'] as int?;
    if (exp == null) return true;
    
    // Convert to DateTime and check if expired (with 5-minute buffer)
    final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    final shouldRefresh = DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 5)));
    
    if (kDebugMode && shouldRefresh) {
      print('🔄 Auth: Access token expires at ${expiry.toIso8601String()}, refreshing now');
    }
    
    return shouldRefresh;
  }

  /// Get tokens with automatic refresh if needed
  Future<Map<String, String>?> _getTokensWithRefresh() async {
    if (_shouldRefreshTokens()) {
      // Check if refresh is already in progress
      if (_refreshInProgress && _refreshCompleter != null) {
        if (kDebugMode) {
          print('⏳ Auth: Token refresh already in progress, awaiting shared result...');
        }
        // Wait for the ongoing refresh to complete
        return await _refreshCompleter!.future;
      }
      
      _refreshInProgress = true;
      _refreshCompleter = Completer<Map<String, String>?>();
      
      try {
        if (kDebugMode) {
          print('🔄 Auth: Tokens need refresh, refreshing...');
        }
        
        final refreshedTokens = await _authService.refreshTokens();
        if (refreshedTokens != null) {
          _tokens = refreshedTokens;
          await _storeTokensSecurely(refreshedTokens);
          if (kDebugMode) {
            print('✅ Auth: Tokens refreshed successfully');
          }
          _refreshCompleter!.complete(refreshedTokens);
          return refreshedTokens;
        } else {
          if (kDebugMode) {
            print('❌ Auth: Token refresh returned null');
          }
          // If refresh returns null, force sign out
          await _handleRefreshTokenExpiry();
          _refreshCompleter!.complete(null);
          return null;
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Auth: Token refresh failed with error: $e');
        }
        
        // Check if it's a refresh token expiry error
        final errorString = e.toString().toLowerCase();
        final isRefreshTokenExpired = errorString.contains('notauthorizedexception') ||
                                     errorString.contains('tokenexpiredexception') ||
                                     errorString.contains('invalid_grant') ||
                                     errorString.contains('refresh token') ||
                                     (errorString.contains('unauthorized') && errorString.contains('token'));
        
        if (isRefreshTokenExpired) {
          if (kDebugMode) {
            print('🚨 Auth: Refresh token expired, forcing sign out');
          }
          await _handleRefreshTokenExpiry();
          _refreshCompleter!.complete(null);
          return null;
        } else {
          if (kDebugMode) {
            print('⚠️ Auth: Non-expiry refresh error, returning existing tokens');
          }
          // For other errors (network, etc.), return existing tokens
          _refreshCompleter!.complete(_tokens);
          return _tokens;
        }
      } finally {
        _refreshInProgress = false;
        _refreshCompleter = null;
      }
    }
    return _tokens;
  }

  /// Handle refresh token expiry by signing out with clear error message
  Future<void> _handleRefreshTokenExpiry() async {
    _setError(AuthErrorHandler.getFriendlyErrorMessage('AuthSessionExpiredException'));
    await signOut();
  }

  /// Check current authentication status
  Future<void> _checkAuthStatus() async {
    try {
      _isSignedIn = await _authService.isSignedIn();
      if (_isSignedIn) {
        _currentUser = await _authService.getCurrentUser();
        final freshTokens = await _authService.getTokens();
        
        if (freshTokens != null) {
          _tokens = freshTokens;
          // Store tokens securely for persistence
          await _storeTokensSecurely(freshTokens);
        }
        
        // Validate that user profile exists in DynamoDB
        if (_currentUser != null && _tokens != null) {
          await _validateUserProfile();
        }
      } else {
        _currentUser = null;
        _tokens = null;
        _isProfileValidating = false;
        // Clear stored tokens when not signed in
        await _clearStoredTokens();
      }
      _clearError();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Auth: Error checking auth status: $e');
      }
      
      // Only sign out if it's a session expiry error, not network/DynamoDB errors
      final errorString = e.toString().toLowerCase();
      final isSessionExpired = errorString.contains('session') && 
                              (errorString.contains('expired') || 
                               errorString.contains('invalid') ||
                               errorString.contains('unauthorized'));
      
      if (_isSignedIn && isSessionExpired) {
        if (kDebugMode) {
          print('🚨 Auth: Session expired, signing out');
        }
        await signOut();
      } else if (_isSignedIn) {
        if (kDebugMode) {
          print('⚠️ Auth: Non-session error, keeping user signed in: $e');
        }
        // For network/DynamoDB errors, just set error but don't sign out
        _setError('Temporary error checking auth status. Please try again.');
      } else {
        _setError(AuthErrorHandler.getFriendlyErrorMessage(e.toString()));
      }
    }
  }

  /// Validate user profile exists in DynamoDB with graceful retry logic
  Future<void> _validateUserProfile() async {
    if (_isProfileValidating) return; // Prevent concurrent validation
    
    _isProfileValidating = true;
    _updateState(profileValidating: true);
    
    try {
      bool profileValidated = false;
      
      // Try to validate profile with immediate retries (for new users, PostConfirmation might be delayed)
      for (int attempt = 0; attempt < 3; attempt++) {
        try {
          final userProfile = await ApiService.getUser(_currentUser!.userId, this);
          if (userProfile != null) {
            if (kDebugMode) {
              print('✅ Auth: User profile validated in DynamoDB (attempt ${attempt + 1})');
            }
            profileValidated = true;
            _profileValidationAttempts = 0; // Reset counter on success
            break;
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Auth: Attempt ${attempt + 1} failed to validate profile: $e');
          }
        }
        
        // Wait before retrying (only for attempts 1 and 2)
        if (attempt < 2) {
          await Future.delayed(Duration(seconds: attempt + 1));
        }
      }
      
      if (!profileValidated) {
        _profileValidationAttempts++;
        
        if (_profileValidationAttempts >= _maxProfileValidationAttempts) {
          // Max attempts reached, show user-friendly message instead of signing out
          if (kDebugMode) {
            print('🚨 Auth: Max profile validation attempts reached, showing user message');
          }
          _updateState(
            profileValidating: false,
            error: 'Still setting up your account. Please try refreshing or contact support if this continues.'
          );
          return;
        }
        
        // Schedule a retry using Timer (more reliable than Future.delayed)
        if (kDebugMode) {
          print('🚨 Auth: User profile not found in DynamoDB (attempt $_profileValidationAttempts/$_maxProfileValidationAttempts), scheduling retry');
        }
        
        _scheduleProfileValidationRetry();
        return;
      }
    } finally {
      _isProfileValidating = false;
      _updateState(profileValidating: false);
    }
  }

  /// Schedule a profile validation retry using Timer
  void _scheduleProfileValidationRetry() {
    // Cancel any existing timer
    _profileValidationTimer?.cancel();
    
    _profileValidationTimer = Timer(_profileValidationRetryInterval, () {
      // Only retry if still signed in and haven't exceeded max attempts
      if (_isSignedIn && _profileValidationAttempts < _maxProfileValidationAttempts) {
        if (kDebugMode) {
          print('🔄 Auth: Retrying profile validation (attempt $_profileValidationAttempts/$_maxProfileValidationAttempts)');
        }
        _validateUserProfile();
      }
    });
  }

  /// Cancel profile validation retry timer
  void _cancelProfileValidationRetry() {
    _profileValidationTimer?.cancel();
    _profileValidationTimer = null;
    _profileValidationAttempts = 0;
  }

  /// Manually retry profile validation (for user-initiated retry)
  Future<void> retryProfileValidation() async {
    if (_currentUser != null && _tokens != null) {
      _profileValidationAttempts = 0; // Reset attempt counter
      await _validateUserProfile();
    }
  }

  @override
  void dispose() {
    // Cancel any pending timers
    _cancelProfileValidationRetry();
    // Reset refresh coordination
    _refreshInProgress = false;
    _refreshCompleter?.complete(null);
    _refreshCompleter = null;
    super.dispose();
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
      
      // Handle different signup completion states
      if (result.isSignUpComplete) {
        // User is fully confirmed and signed in (test environment)
        await _checkAuthStatus();
        _clearError();
        return true;
      } else {
        // User needs email verification (production environment)
        _setError("Please verify your email before signing in.");
        return false;
      }
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
      if (kDebugMode) {
        print('🔐 AuthProvider: Initiating sign out...');
      }
      await _authService.signOut();
      if (kDebugMode) {
        print('🔐 AuthProvider: Amplify signOut completed');
      }
      _currentUser = null;
      _tokens = null;
      _isSignedIn = false;
      _isProfileValidating = false;
      if (kDebugMode) {
        print('🔐 AuthProvider: Local auth state cleared (user=null, tokens=null, isSignedIn=false)');
      }
      _clearError();
    } catch (e) {
      _setError(AuthErrorHandler.getFriendlyErrorMessage(e.toString()));
      if (kDebugMode) {
        print('❌ AuthProvider: Sign out failed: $e');
      }
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
      _setError(AuthErrorHandler.getFriendlyErrorMessage(e.toString()));
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
      _setError(AuthErrorHandler.getFriendlyErrorMessage(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _updateState(loading: loading);
  }

  void _setError(String error) {
    _updateState(error: error);
  }

  void _clearError() {
    _updateState(error: null);
  }

  /// Batch state updates to minimize notifyListeners() calls
  void _updateState({bool? loading, String? error, bool? profileValidating}) {
    bool hasChanges = false;
    
    if (loading != null && _isLoading != loading) {
      _isLoading = loading;
      hasChanges = true;
    }
    
    if (error != null && _error != error) {
      _error = error;
      hasChanges = true;
    } else if (error == null && _error != null) {
      _error = null;
      hasChanges = true;
    }
    
    if (profileValidating != null && _isProfileValidating != profileValidating) {
      _isProfileValidating = profileValidating;
      hasChanges = true;
    }
    
    if (hasChanges) {
      notifyListeners();
    }
  }

}

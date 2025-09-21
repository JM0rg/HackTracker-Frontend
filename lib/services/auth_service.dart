import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import '../amplifyconfiguration.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isConfigured = false;

  /// Initialize Amplify with Cognito
  Future<void> configureAmplify() async {
    if (_isConfigured) return;

    try {
      // Add Cognito Auth plugin
      await Amplify.addPlugin(AmplifyAuthCognito());
      
      // Configure Amplify (configuration is in amplifyconfiguration.dart)
      await Amplify.configure(amplifyconfig);
      
      _isConfigured = true;
      safePrint('Amplify configured successfully');
    } catch (e) {
      safePrint('Error configuring Amplify: $e');
      rethrow;
    }
  }

  /// Check if user is currently signed in
  Future<bool> isSignedIn() async {
    try {
      final result = await Amplify.Auth.getCurrentUser();
      return result.userId.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get current user information
  Future<AuthUser?> getCurrentUser() async {
    try {
      return await Amplify.Auth.getCurrentUser();
    } catch (e) {
      return null;
    }
  }

  /// Get current user's JWT tokens
  Future<Map<String, String>?> getTokens() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (session is CognitoAuthSession) {
        return {
          'accessToken': session.userPoolTokensResult.value.accessToken.raw,
          'idToken': session.userPoolTokensResult.value.idToken.raw,
        };
      }
      return null;
    } catch (e) {
      safePrint('Error getting tokens: $e');
      return null;
    }
  }

  /// Sign up a new user
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final result = await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(
          userAttributes: {
            AuthUserAttributeKey.email: email,
            AuthUserAttributeKey.givenName: firstName,
            AuthUserAttributeKey.familyName: lastName,
          },
        ),
      );
      return result;
    } catch (e) {
      safePrint('Error signing up: $e');
      rethrow;
    }
  }

  /// Confirm sign up with verification code
  Future<SignUpResult> confirmSignUp({
    required String email,
    required String confirmationCode,
  }) async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: email,
        confirmationCode: confirmationCode,
      );
      return result;
    } catch (e) {
      safePrint('Error confirming sign up: $e');
      rethrow;
    }
  }

  /// Sign in user
  Future<SignInResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: email,
        password: password,
      );
      return result;
    } catch (e) {
      safePrint('Error signing in: $e');
      rethrow;
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();
    } catch (e) {
      safePrint('Error signing out: $e');
      rethrow;
    }
  }

  /// Resend confirmation code
  Future<ResendSignUpCodeResult> resendSignUpCode({
    required String email,
  }) async {
    try {
      final result = await Amplify.Auth.resendSignUpCode(username: email);
      return result;
    } catch (e) {
      safePrint('Error resending confirmation code: $e');
      rethrow;
    }
  }

  /// Reset password
  Future<ResetPasswordResult> resetPassword({
    required String email,
  }) async {
    try {
      final result = await Amplify.Auth.resetPassword(username: email);
      return result;
    } catch (e) {
      safePrint('Error resetting password: $e');
      rethrow;
    }
  }

  /// Confirm password reset
  Future<void> confirmResetPassword({
    required String email,
    required String newPassword,
    required String confirmationCode,
  }) async {
    try {
      await Amplify.Auth.confirmResetPassword(
        username: email,
        newPassword: newPassword,
        confirmationCode: confirmationCode,
      );
    } catch (e) {
      safePrint('Error confirming password reset: $e');
      rethrow;
    }
  }
}

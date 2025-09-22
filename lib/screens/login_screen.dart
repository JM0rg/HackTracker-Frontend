import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/auth_validators.dart';
import '../utils/ui_helpers.dart';
import '../utils/theme_constants.dart';
import 'signup_screen.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.signIn(
      email: AuthValidators.sanitizeEmail(_emailController.text),
      password: _passwordController.text,
    );

    if (success && mounted) {
      // Navigate to dashboard on successful login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  void _navigateToSignup() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.bgPrimary,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Padding(
              padding: const EdgeInsets.all(UIHelpers.paddingLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Title
                  Text('HackTracker', style: ThemeConstants.headerLarge),
                  const SizedBox(height: UIHelpers.paddingSmall),
                  Text(
                    'Slowpitch Softball Stats',
                    style: ThemeConstants.subtitle.copyWith(fontFamily: 'Tektur'),
                  ),
                  const SizedBox(height: UIHelpers.paddingXLarge * 1.5),

                  // Login Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email Field
                        UIHelpers.buildTextFormField(
                          controller: _emailController,
                          labelText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email,
                          validator: AuthValidators.validateEmail,
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        UIHelpers.buildTextFormField(
                          controller: _passwordController,
                          labelText: 'Password',
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock,
                          suffixIcon: UIHelpers.buildPasswordToggle(
                            _obscurePassword,
                            () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Error Message
                        if (authProvider.error != null)
                          UIHelpers.buildErrorMessage(authProvider.error!),

                        // Sign In Button
                        UIHelpers.buildPrimaryButton(
                          text: 'Sign In',
                          onPressed: _handleSignIn,
                          isLoading: authProvider.isLoading,
                        ),
                        const SizedBox(height: 24),

                        // Sign Up Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(color: Color(0xFF888888)),
                            ),
                            GestureDetector(
                              onTap: _navigateToSignup,
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Color(0xFF00FF88),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Forgot Password Link
                        GestureDetector(
                          onTap: () {
                            // TODO: Implement forgot password flow
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Forgot password feature coming soon'),
                                backgroundColor: Color(0xFF333333),
                              ),
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color(0xFF888888),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

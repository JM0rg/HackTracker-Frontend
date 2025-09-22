import 'package:flutter/material.dart';

/// Centralized theme constants used throughout the app
class ThemeConstants {
  // Private constructor to prevent instantiation
  ThemeConstants._();

  // ============================
  // COLORS
  // ============================
  
  /// Primary colors
  static const Color primaryGreen = Color(0xFF00FF88);
  static const Color primaryBlue = Color(0xFF0088FF);
  static const Color primaryPink = Color(0xFFFF0088);
  static const Color primaryOrange = Color(0xFFFF8800);
  static const Color primaryPurple = Color(0xFF8800FF);
  static const Color primaryYellow = Color(0xFFFFFF00);
  static const Color primaryCyan = Color(0xFF00FFFF);
  static const Color primaryRed = Color(0xFFFF4444);
  
  /// Background colors
  static const Color bgPrimary = Color(0xFF121212);
  static const Color bgSecondary = Color(0xFF1E1E1E);
  static const Color bgTertiary = Color(0xFF2A2A2A);
  static const Color bgDark = Color(0xFF0A0A0A);
  static const Color bgBlack = Color(0xFF000000);
  
  /// Surface colors
  static const Color surfacePrimary = Color(0xFF1E1E1E);
  static const Color surfaceSecondary = Color(0xFF333333);
  static const Color surfaceTertiary = Color(0xFF444444);
  
  /// Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF888888);
  static const Color textTertiary = Color(0xFF666666);
  static const Color textQuaternary = Color(0xFFB0B0B0);
  
  /// Error colors
  static const Color errorPrimary = Color(0xFFFF6B6B);
  static const Color errorBg = Color(0xFF2D1B1B);
  
  // ============================
  // TEXT STYLES
  // ============================
  
  /// Header styles
  static const TextStyle headerLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: primaryGreen,
    fontFamily: 'Tektur',
  );
  
  static const TextStyle headerMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    fontFamily: 'Tektur',
  );
  
  static const TextStyle headerSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    fontFamily: 'Tektur',
  );
  
  /// Section headers
  static const TextStyle sectionHeader = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: primaryGreen,
  );
  
  /// Body text styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: textSecondary,
  );
  
  /// Subtitle styles
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    color: textSecondary,
  );
  
  static const TextStyle subtitleSmall = TextStyle(
    fontSize: 14,
    color: textTertiary,
  );
  
  /// Button text styles
  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  
  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );
  
  /// Error text style
  static const TextStyle errorText = TextStyle(
    color: errorPrimary,
    fontSize: 14,
  );
  
  // ============================
  // DECORATIONS
  // ============================
  
  /// Card decoration
  static BoxDecoration cardDecoration({Color? backgroundColor}) {
    return BoxDecoration(
      color: backgroundColor ?? surfacePrimary,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: surfaceSecondary),
    );
  }
  
  /// Input decoration
  static BoxDecoration inputDecoration() {
    return BoxDecoration(
      color: surfacePrimary,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: surfaceSecondary),
    );
  }
  
  /// Error decoration
  static BoxDecoration errorDecoration() {
    return BoxDecoration(
      color: errorBg,
      border: Border.all(color: errorPrimary),
      borderRadius: BorderRadius.circular(8),
    );
  }
  
  // ============================
  // GRADIENTS
  // ============================
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [bgDark, bgPrimary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

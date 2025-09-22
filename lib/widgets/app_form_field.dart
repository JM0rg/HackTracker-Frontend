import 'package:flutter/material.dart';
import '../utils/theme_constants.dart';
import '../utils/ui_helpers.dart';

/// Reusable form field widget with app-specific styling
class AppFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final int? maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? hintText;

  const AppFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      onChanged: onChanged,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: TextStyle(color: ThemeConstants.textSecondary),
        hintStyle: TextStyle(color: ThemeConstants.textTertiary),
        prefixIcon: prefixIcon != null 
            ? Icon(prefixIcon, color: ThemeConstants.textSecondary) 
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: ThemeConstants.surfacePrimary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIHelpers.radiusLarge),
          borderSide: BorderSide(color: ThemeConstants.surfaceSecondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIHelpers.radiusLarge),
          borderSide: BorderSide(color: ThemeConstants.surfaceSecondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIHelpers.radiusLarge),
          borderSide: BorderSide(color: ThemeConstants.primaryGreen),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIHelpers.radiusLarge),
          borderSide: BorderSide(color: ThemeConstants.errorPrimary),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIHelpers.radiusLarge),
          borderSide: BorderSide(color: ThemeConstants.errorPrimary),
        ),
      ),
      validator: validator,
    );
  }
}

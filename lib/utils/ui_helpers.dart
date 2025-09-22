import 'package:flutter/material.dart';

/// Reusable UI components and helper functions
class UIHelpers {
  /// Common padding values used throughout the app
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  /// Border radius values
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 20.0;

  /// Common icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  static const double iconSizeXLarge = 32.0;

  /// Build a standard error message widget
  static Widget buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B1B),
        border: Border.all(color: const Color(0xFFFF6B6B)),
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Color(0xFFFF6B6B), size: iconSizeMedium),
          const SizedBox(width: paddingSmall),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFFF6B6B)),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a standard text form field with dark theme
  static Widget buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    Widget? suffixIcon,
    void Function(String)? onChanged,
    int? maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color(0xFF888888)),
        prefixIcon: prefixIcon != null 
            ? Icon(prefixIcon, color: const Color(0xFF888888)) 
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: Color(0xFF333333)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: Color(0xFF333333)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: Color(0xFF00FF88)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
        ),
      ),
      validator: validator,
    );
  }

  /// Build a standard primary button
  static Widget buildPrimaryButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    double height = 50,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? const Color(0xFF00FF88),
          foregroundColor: foregroundColor ?? Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    foregroundColor ?? Colors.black,
                  ),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  /// Build a standard secondary button
  static Widget buildSecondaryButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF333333),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: iconSizeSmall),
              const SizedBox(width: paddingSmall),
            ],
            Text(text),
          ],
        ),
      ),
    );
  }

  /// Build a standard card container
  static Widget buildCard({
    required Widget child,
    EdgeInsets? padding,
    Color? backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(paddingMedium),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(radiusLarge),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: child,
    );
  }

  /// Build a dropdown button with dark theme
  static Widget buildDropdownButton<T>({
    required T? value,
    required List<T> items,
    required Function(T?) onChanged,
    required String Function(T) itemLabel,
    String? hint,
    Widget Function(T)? itemBuilder,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: paddingSmall, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(radiusSmall),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: hint != null
              ? Text(hint, style: const TextStyle(color: Color(0xFF888888)))
              : null,
          dropdownColor: const Color(0xFF333333),
          style: const TextStyle(color: Colors.white, fontSize: 12),
          items: items.map<DropdownMenuItem<T>>((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: itemBuilder != null
                  ? itemBuilder(item)
                  : Text(itemLabel(item)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  /// Build a standard loading indicator
  static Widget buildLoadingIndicator({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF88)),
          ),
          if (message != null) ...[
            const SizedBox(height: paddingMedium),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Tektur',
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build section header text
  static Widget buildSectionHeader(String text, {Color? color}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: color ?? const Color(0xFF00FF88),
        fontFamily: 'Tektur',
      ),
    );
  }

  /// Build subtitle text
  static Widget buildSubtitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF888888),
      ),
    );
  }

  /// Build info card with icon
  static Widget buildInfoCard({
    required String title,
    required String content,
    IconData icon = Icons.info,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(paddingMedium),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(radiusMedium),
        border: Border.all(color: const Color(0xFF444444)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor ?? const Color(0xFF00FF88), size: iconSizeMedium),
              const SizedBox(width: paddingSmall),
              Text(
                title,
                style: TextStyle(
                  color: iconColor ?? const Color(0xFF00FF88),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: paddingSmall),
          Text(
            content,
            style: const TextStyle(color: Color(0xFF888888)),
          ),
        ],
      ),
    );
  }

  /// Build empty state widget
  static Widget buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: const Color(0xFF888888).withOpacity(0.5),
          ),
          const SizedBox(height: paddingMedium),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF888888),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: paddingLarge),
            action,
          ],
        ],
      ),
    );
  }

  /// Format date/time helper
  static String formatGameDateTime(String? dateTimeUtc) {
    if (dateTimeUtc == null) return 'TBD';
    
    try {
      final dateTime = DateTime.parse(dateTimeUtc);
      final local = dateTime.toLocal();
      return '${local.month}/${local.day} at ${formatTime(local)}';
    } catch (e) {
      return 'TBD';
    }
  }

  /// Format time helper
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// Build password visibility toggle
  static Widget buildPasswordToggle(bool obscureText, VoidCallback onToggle) {
    return IconButton(
      icon: Icon(
        obscureText ? Icons.visibility : Icons.visibility_off,
        color: const Color(0xFF888888),
      ),
      onPressed: onToggle,
    );
  }
}

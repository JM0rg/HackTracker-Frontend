import 'package:flutter/material.dart';
import '../utils/theme_constants.dart';

/// Reusable widget for displaying a stat item
class StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double? fontSize;

  const StatItem({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize ?? 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: ThemeConstants.bodySmall,
          ),
        ],
      ),
    );
  }
}

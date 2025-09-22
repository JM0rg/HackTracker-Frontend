import 'package:flutter/material.dart';
import '../utils/icon_utils.dart';

/// Reusable widget for displaying team icons with color
class TeamIconWidget extends StatelessWidget {
  final String iconCode;
  final String colorCode;
  final double size;

  const TeamIconWidget({
    super.key,
    required this.iconCode,
    required this.colorCode,
    this.size = 20,
  });

  /// Factory constructor with default values
  factory TeamIconWidget.withDefaults({
    String? iconCode,
    String? colorCode,
    double? size,
  }) {
    return TeamIconWidget(
      iconCode: iconCode ?? 'sports_baseball',
      colorCode: colorCode ?? 'neon_green',
      size: size ?? 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      IconUtils.getIconFromCode(iconCode),
      color: IconUtils.getColorFromCode(colorCode),
      size: size,
    );
  }
}

import 'package:flutter/material.dart';
import '../utils/theme_constants.dart';
import '../utils/ui_helpers.dart';

/// Reusable card widget with consistent styling
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final String? title;
  final Widget? trailing;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.onTap,
    this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title!, style: ThemeConstants.sectionHeader),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: UIHelpers.paddingMedium),
        ],
        child,
      ],
    );

    final card = Card(
      color: backgroundColor ?? ThemeConstants.surfacePrimary,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(UIHelpers.paddingMedium),
        child: SizedBox(
          width: double.infinity,
          child: content,
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UIHelpers.radiusLarge),
        child: card,
      );
    }

    return card;
  }
}

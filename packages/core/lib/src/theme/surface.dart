import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// The one "card" look used everywhere instead of ad-hoc
/// `BoxDecoration(border: ...)` blocks: soft shadow + no border on light
/// (Careem/inDrive-style depth), subtle border + no shadow on dark (shadows
/// don't read on dark surfaces — a lighter border does the same job).
BoxDecoration surfaceDecoration(BuildContext context, {double radius = AppRadius.lg, bool tintedBorder = false}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  if (isDark) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Theme.of(context).dividerColor, width: tintedBorder ? 1.3 : 1),
    );
  }
  return BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: const [BoxShadow(color: AppColors.lightShadow, blurRadius: 18, offset: Offset(0, 6))],
  );
}

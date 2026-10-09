import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// The one "card" look used everywhere instead of ad-hoc
/// `BoxDecoration(border: ...)` blocks: a subtle 1px border plus a soft,
/// restrained shadow on light surfaces (never a heavy outline), a subtle
/// border with no shadow on dark surfaces (shadows don't read on dark —
/// a lighter border does the same job).
BoxDecoration surfaceDecoration(BuildContext context, {double radius = AppRadius.md, bool tintedBorder = false}) {
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
    border: Border.all(color: AppColors.lightBorder, width: 1),
    boxShadow: const [BoxShadow(color: AppColors.lightShadow, blurRadius: 10, offset: Offset(0, 3))],
  );
}

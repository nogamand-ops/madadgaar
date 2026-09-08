import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'initials_avatar.dart';
import 'rating_stars.dart';

/// The "Ahmed — 4.9★ — Verified — 1.8km — 6 min ETA" card, used on the
/// matching / best-match-found step and reused (denser) on the live
/// tracking screen. Kept independent of any one model type so it works for
/// both a [HelperCandidate] preview and a full [HelperProfile].
class HelperPreviewCard extends StatelessWidget {
  final String name;
  final double rating;
  final int completedJobs;
  final String vehicleLabel;
  final bool verified;
  final bool highlyRated;
  final double? distanceKm;
  final int? etaMinutes;
  final bool dense;

  const HelperPreviewCard({
    super.key,
    required this.name,
    required this.rating,
    required this.completedJobs,
    required this.vehicleLabel,
    required this.verified,
    this.highlyRated = false,
    this.distanceKm,
    this.etaMinutes,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(dense ? AppSpacing.md : AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          InitialsAvatar(name: name, size: dense ? 44 : 56),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(name, style: AppTextStyles.h3, overflow: TextOverflow.ellipsis)),
                    if (verified) ...[
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(Icons.verified_rounded, size: 16, color: AppColors.primary),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    RatingStars(rating: rating, size: 13),
                    const SizedBox(width: AppSpacing.xs),
                    Text(rating.toStringAsFixed(1), style: AppTextStyles.caption),
                    const SizedBox(width: AppSpacing.sm),
                    Text('· $completedJobs jobs', style: AppTextStyles.caption),
                  ],
                ),
                const SizedBox(height: 2),
                Text(vehicleLabel, style: AppTextStyles.caption),
              ],
            ),
          ),
          if (distanceKm != null || etaMinutes != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (etaMinutes != null)
                  Text('$etaMinutes min', style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
                if (distanceKm != null) Text('${distanceKm!.toStringAsFixed(1)} km', style: AppTextStyles.caption),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

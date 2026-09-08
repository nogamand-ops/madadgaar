import 'package:flutter/material.dart';
import '../models/helper_profile.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'status_badge.dart';

/// Renders a helper's trust signals consistently everywhere a helper is
/// shown: matching preview, tracking screen, profile, admin table.
class TrustBadgeRow extends StatelessWidget {
  final HelperProfile helper;
  final bool compact;

  const TrustBadgeRow({super.key, required this.helper, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final tags = <Widget>[];
    if (helper.isVerified) {
      tags.add(const PillTag(label: '✓ Verified', color: AppColors.primary));
    }
    if (helper.isHighlyRated) {
      tags.add(const PillTag(label: '⭐ Highly Rated', color: AppColors.warning));
    }
    if (!compact) {
      if (helper.hasIdentityVerified) {
        tags.add(const PillTag(label: '✓ Identity Verified', color: AppColors.secondary));
      }
      if (helper.hasVehicleVerified) {
        tags.add(const PillTag(label: '✓ Vehicle Verified', color: AppColors.secondary));
      }
    }
    if (tags.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: AppSpacing.xs, runSpacing: AppSpacing.xs, children: tags);
  }
}

class TrustLevelChip extends StatelessWidget {
  final String level; // 'Trusted' | 'Highly Trusted'
  const TrustLevelChip(this.level, {super.key});

  @override
  Widget build(BuildContext context) {
    final highly = level == 'Highly Trusted';
    return PillTag(
      label: highly ? '🛡️ Highly Trusted' : '🛡️ Trusted',
      color: highly ? AppColors.warning : AppColors.primary,
    );
  }
}

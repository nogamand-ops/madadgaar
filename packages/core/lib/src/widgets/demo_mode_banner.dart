import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Small, persistent, honest banner (spec section 10 / North Star item 10):
/// obvious that this is a demo, but never apologetic or ugly about it.
class DemoModeBanner extends StatelessWidget {
  const DemoModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.12),
        border: const Border(bottom: BorderSide(color: AppColors.secondary, width: 1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.secondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 11.5, color: AppColors.secondary, fontWeight: FontWeight.w600),
                children: const [
                  TextSpan(text: 'DEMO MODE  ', style: TextStyle(fontWeight: FontWeight.w800)),
                  TextSpan(text: 'Payments, verification and live services are simulated for this demonstration.'),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

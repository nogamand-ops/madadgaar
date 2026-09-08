import 'package:flutter/material.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

class ActiveRequestCard extends StatelessWidget {
  final ServiceRequest request;
  final MadadgaarService? service;
  final VoidCallback onTrack;

  const ActiveRequestCard({super.key, required this.request, required this.service, required this.onTrack});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTrack,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🚨', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Active Request', style: AppTextStyles.overline.copyWith(color: AppColors.primary)),
                  const Spacer(),
                  StatusBadge(request.status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(service?.name ?? request.serviceKey, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.xs),
              Text(
                request.status.customerLabel,
                style: AppTextStyles.body.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(label: 'Track Helper', icon: Icons.map_rounded, onPressed: onTrack, expand: false),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

/// A calm, balanced two-column grid — every service gets the same neutral
/// badge treatment (amber is reserved for selection/active states
/// elsewhere), so the five options read as one coherent set instead of a
/// row of competing colors.
class ServiceGrid extends StatelessWidget {
  final List<MadadgaarService> services;
  final void Function(String key) onTap;

  const ServiceGrid({super.key, required this.services, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final visible = services.where((s) => s.key != 'other').toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visible.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, i) {
        final s = visible[i];
        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: InkWell(
            onTap: () => onTap(s.key),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              decoration: surfaceDecoration(context),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
              child: Row(
                children: [
                  ServiceIconBadge(serviceKey: s.key, size: 40),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      s.name,
                      style: AppTextStyles.h3,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

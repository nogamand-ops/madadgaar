import 'package:flutter/material.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

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
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.88,
      ),
      itemBuilder: (context, i) {
        final s = visible[i];
        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            onTap: () => onTap(s.key),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              decoration: surfaceDecoration(context),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xs),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ServiceIconBadge(serviceKey: s.key, size: 42),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    s.name,
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

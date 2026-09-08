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
        childAspectRatio: 0.92,
      ),
      itemBuilder: (context, i) {
        final s = visible[i];
        return Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            onTap: () => onTap(s.key),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(s.icon, style: const TextStyle(fontSize: 26)),
                  const SizedBox(height: AppSpacing.xs),
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

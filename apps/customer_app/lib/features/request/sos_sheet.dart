import 'package:flutter/material.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

/// SOS panel (spec section 21). Madadgaar clearly does NOT claim to be an
/// emergency service itself — it surfaces real official Pakistani emergency
/// numbers and a location-share action, nothing more.
Future<void> showSosSheet(BuildContext context, {required String address}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => _SosSheet(address: address),
  );
}

class _SosSheet extends StatelessWidget {
  final String address;
  const _SosSheet({required this.address});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.sos_rounded, color: AppColors.danger, size: 26),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(child: Text('Emergency options', style: AppTextStyles.h2)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Madadgaar is a roadside-assistance marketplace, not an emergency service. '
              'For a life-threatening emergency, contact official services directly.',
              style: AppTextStyles.caption.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SosTile(icon: Icons.local_police_rounded, label: 'Police', value: '15'),
            _SosTile(icon: Icons.emergency_rounded, label: 'Rescue 1122', value: '1122'),
            _SosTile(icon: Icons.local_fire_department_rounded, label: 'Edhi Ambulance', value: '115'),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Demo Mode: your location ($address) would be shared with your emergency contacts.')),
                );
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.share_location_rounded),
              label: const Text('Share my location with emergency contact'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SosTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SosTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(backgroundColor: AppColors.danger.withValues(alpha: 0.14), child: Icon(icon, color: AppColors.danger, size: 20)),
      title: Text(label, style: AppTextStyles.bodyStrong),
      trailing: Text(value, style: AppTextStyles.h3),
    );
  }
}

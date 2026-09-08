import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

import '../home/helper_home_providers.dart';

class HelperProfileScreen extends ConsumerWidget {
  const HelperProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(helperProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Row(
                children: [
                  InitialsAvatar(name: profile.name, size: 56),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.name, style: AppTextStyles.h2),
                        Text(profile.phone, style: AppTextStyles.body.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              TrustBadgeRow(helper: profile),
              if (profile.trustLevel != null) ...[
                const SizedBox(height: AppSpacing.sm),
                TrustLevelChip(profile.trustLevel!),
              ],
              const SizedBox(height: AppSpacing.xl),
              _Section(children: [
                _Row(label: 'Verification status', value: profile.verificationStatus.label),
                _Row(label: 'Rating', value: '${profile.rating.toStringAsFixed(1)} ★'),
                _Row(label: 'Completed jobs', value: '${profile.completedJobs}'),
                _Row(label: 'Vehicle', value: '${profile.vehicleType.emoji} ${profile.vehicleLabel}'),
                _Row(label: 'Member since', value: profile.memberSince),
              ]),
              const SizedBox(height: AppSpacing.lg),
              _Section(children: [
                ListTile(leading: const Icon(Icons.list_alt_rounded), title: const Text('Services offered'), subtitle: Text(profile.servicesOffered.join(', '))),
              ]),
              const SizedBox(height: AppSpacing.lg),
              _Section(children: [
                ListTile(leading: const Icon(Icons.help_outline_rounded), title: const Text('Help & Support'), onTap: () {}),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
                  title: const Text('Log out', style: TextStyle(color: AppColors.danger)),
                  onTap: () => ref.read(authControllerProvider.notifier).logout(),
                ),
              ]),
            ],
          );
        },
        loading: () => const LoadingView(),
        error: (e, __) => ErrorStateView(title: 'Could not load profile', message: '$e', onRetry: () => ref.invalidate(helperProfileProvider)),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final List<Widget> children;
  const _Section({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(children: children),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
          Text(value, style: AppTextStyles.bodyStrong),
        ],
      ),
    );
  }
}

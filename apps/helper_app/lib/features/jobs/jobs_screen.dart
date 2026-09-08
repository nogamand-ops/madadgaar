import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

final _myJobsProvider = FutureProvider.autoDispose<List<ServiceRequest>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(madadgaarApiProvider).listRequests(helperId: user.id);
});

final _servicesProvider = FutureProvider.autoDispose((ref) => ref.watch(madadgaarApiProvider).services());

class JobsScreen extends ConsumerWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(_myJobsProvider);
    final servicesAsync = ref.watch(_servicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your jobs')),
      body: jobsAsync.when(
        data: (jobs) {
          if (jobs.isEmpty) {
            return const EmptyStateView(icon: Icons.work_outline_rounded, title: 'No jobs yet', message: 'Accepted requests will show up here.');
          }
          final services = servicesAsync.value ?? const [];
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_myJobsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: jobs.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, i) {
                final job = jobs[i];
                final service = services.where((s) => s.key == job.serviceKey).firstOrNull;
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(service?.icon ?? '🛠️', style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: Text(service?.name ?? job.serviceKey, style: AppTextStyles.h3)),
                        StatusBadge(job.status, forHelper: true),
                      ]),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(relativeTime(job.createdAt), style: AppTextStyles.caption.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                          if (job.status == RequestStatus.completed) MoneyText(job.pricing.revenue.helperEarnings, style: AppTextStyles.bodyStrong, color: AppColors.primary),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
        loading: () => const LoadingView(),
        error: (e, __) => ErrorStateView(title: 'Could not load jobs', message: '$e', onRetry: () => ref.invalidate(_myJobsProvider)),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

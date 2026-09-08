import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

import '../home/home_providers.dart';
import '../request/location_confirm_screen.dart';
import '../request/request_flow_controller.dart';
import '../request/searching_screen.dart';

class RequestHistoryScreen extends ConsumerWidget {
  const RequestHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(myRequestHistoryProvider);
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your requests')),
      body: historyAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const EmptyStateView(
              icon: Icons.receipt_long_rounded,
              title: 'No requests yet',
              message: 'When you request help, it will show up here.',
            );
          }
          final services = servicesAsync.value ?? const [];
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myRequestHistoryProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, i) {
                final r = requests[i];
                final service = services.where((s) => s.key == r.serviceKey).firstOrNull;
                return _RequestTile(
                  request: r,
                  serviceName: service?.name ?? r.serviceKey,
                  serviceIcon: service?.icon ?? '🛠️',
                  onTap: () {
                    if (r.status.isActive) {
                      if (r.status == RequestStatus.searching || r.status == RequestStatus.requested) {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => SearchingScreen(requestId: r.id)));
                      } else {
                        context.push('/track/${r.id}');
                      }
                    }
                  },
                  onRequestAgain: r.status == RequestStatus.completed
                      ? () {
                          ref.read(requestFlowProvider.notifier).reset();
                          ref.read(requestFlowProvider.notifier).setService(r.serviceKey);
                          ref.read(requestFlowProvider.notifier).setDetails(r.details);
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LocationConfirmScreen()));
                        }
                      : null,
                );
              },
            ),
          );
        },
        loading: () => const LoadingView(),
        error: (e, __) => ErrorStateView(title: 'Could not load requests', message: '$e', onRetry: () => ref.invalidate(myRequestHistoryProvider)),
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  final ServiceRequest request;
  final String serviceName;
  final String serviceIcon;
  final VoidCallback onTap;
  final VoidCallback? onRequestAgain;

  const _RequestTile({
    required this.request,
    required this.serviceName,
    required this.serviceIcon,
    required this.onTap,
    this.onRequestAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(serviceIcon, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(serviceName, style: AppTextStyles.h3)),
                  StatusBadge(request.status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(relativeTime(request.createdAt), style: AppTextStyles.caption.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                  MoneyText(request.pricing.breakdown.total, style: AppTextStyles.bodyStrong),
                ],
              ),
              if (onRequestAgain != null) ...[
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(onPressed: onRequestAgain, child: const Text('Request again')),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

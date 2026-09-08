import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

import '../request/problem_picker_screen.dart';
import '../request/request_flow_nav.dart';
import '../request/searching_screen.dart';
import 'active_request_controller.dart';
import 'home_providers.dart';
import 'widgets/active_request_card.dart';
import 'widgets/service_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openTrack(BuildContext context, ServiceRequest request) {
    if (request.status == RequestStatus.searching || request.status == RequestStatus.requested) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => SearchingScreen(requestId: request.id)));
    } else {
      context.push('/track/${request.id}');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(customerProfileProvider);
    final servicesAsync = ref.watch(servicesProvider);
    final activeRequestAsync = ref.watch(myActiveRequestProvider);
    final helpersAsync = ref.watch(nearbyHelpersProvider('islamabad'));

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(customerProfileProvider);
            ref.invalidate(nearbyHelpersProvider);
            await ref.read(myActiveRequestProvider.notifier).refresh();
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DemoModeBanner(),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Assalam-o-Alaikum${user != null ? ', ${user.name.split(' ').first}' : ''} 👋',
                                  style: AppTextStyles.h2),
                              const SizedBox(height: 2),
                              Text(
                                'How can we help you today?',
                                style: AppTextStyles.body.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => context.push('/support'),
                          icon: const Icon(Icons.help_outline_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    profileAsync.when(
                      data: (profile) {
                        final loc = profile?.savedLocations.firstOrNull;
                        return Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 16, color: AppColors.primary),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                loc?.label ?? 'Islamabad',
                                style: AppTextStyles.caption.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const SizedBox(height: 16),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    activeRequestAsync.when(
                      data: (request) {
                        if (request == null) {
                          return EmergencyButton(
                            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProblemPickerScreen())),
                          );
                        }
                        return servicesAsync.maybeWhen(
                          data: (services) => ActiveRequestCard(
                            request: request,
                            service: services.where((s) => s.key == request.serviceKey).firstOrNull,
                            onTrack: () => _openTrack(context, request),
                          ),
                          orElse: () => ActiveRequestCard(request: request, service: null, onTrack: () => _openTrack(context, request)),
                        );
                      },
                      loading: () => const SizedBox(height: 72, child: LoadingView()),
                      error: (_, __) => EmergencyButton(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProblemPickerScreen())),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    const SectionHeader(title: 'Or choose a service'),
                    servicesAsync.when(
                      data: (services) => ServiceGrid(services: services, onTap: (key) => enterServiceFlow(context, ref, key)),
                      loading: () => const Padding(padding: EdgeInsets.all(AppSpacing.xl), child: LoadingView()),
                      error: (e, __) => Text('Could not load services: $e'),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    SectionHeader(
                      title: 'Trusted helpers near you',
                      actionLabel: 'See all',
                      onAction: () {},
                    ),
                    helpersAsync.when(
                      data: (helpers) => helpers.isEmpty
                          ? Text('No verified helpers online right now.', style: AppTextStyles.body)
                          : Column(
                              children: helpers
                                  .take(3)
                                  .map((h) => Padding(
                                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                        child: HelperPreviewCard(
                                          name: h.name,
                                          rating: h.rating,
                                          completedJobs: h.completedJobs,
                                          vehicleLabel: h.vehicleLabel,
                                          verified: h.isVerified,
                                          highlyRated: h.isHighlyRated,
                                          dense: true,
                                        ),
                                      ))
                                  .toList(),
                            ),
                      loading: () => const Padding(padding: EdgeInsets.all(AppSpacing.xl), child: LoadingView()),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

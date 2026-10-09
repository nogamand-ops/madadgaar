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

  void _startRequest(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProblemPickerScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(customerProfileProvider);
    final servicesAsync = ref.watch(servicesProvider);
    final activeRequestAsync = ref.watch(myActiveRequestProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(customerProfileProvider);
            await ref.read(myActiveRequestProvider.notifier).refresh();
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DemoModeBanner(),

              // ---- Compact header: brand mark + name + notifications ----
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(color: AppColors.charcoal, borderRadius: BorderRadius.circular(9)),
                      alignment: Alignment.center,
                      child: const Text('M', style: TextStyle(color: AppColors.amber, fontWeight: FontWeight.w800, fontSize: 15)),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Text('Madadgaar', style: AppTextStyles.h3),
                    const Spacer(),
                    IconButton(
                      onPressed: () => context.push('/support'),
                      icon: const Icon(Icons.notifications_none_rounded),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Assalam-o-Alaikum${user != null ? ', ${user.name.split(' ').first}' : ''} 👋',
                      style: AppTextStyles.body.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ---- Location selector ----
                    profileAsync.when(
                      data: (profile) {
                        final loc = profile?.savedLocations.firstOrNull;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                          decoration: surfaceDecoration(context),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 18, color: AppColors.charcoal),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  loc?.label ?? 'Islamabad',
                                  style: AppTextStyles.bodyStrong,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text('Change', style: AppTextStyles.label.copyWith(color: AppColors.charcoal)),
                            ],
                          ),
                        );
                      },
                      loading: () => const SizedBox(height: 48),
                      error: (_, __) => const SizedBox.shrink(),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // ---- Active request, or the main "request assistance" hero ----
                    activeRequestAsync.when(
                      data: (request) {
                        if (request != null) {
                          return servicesAsync.maybeWhen(
                            data: (services) => ActiveRequestCard(
                              request: request,
                              service: services.where((s) => s.key == request.serviceKey).firstOrNull,
                              onTrack: () => _openTrack(context, request),
                            ),
                            orElse: () => ActiveRequestCard(request: request, service: null, onTrack: () => _openTrack(context, request)),
                          );
                        }
                        return _AssistanceHero(onRequest: () => _startRequest(context));
                      },
                      loading: () => const SizedBox(height: 160, child: LoadingView()),
                      error: (_, __) => _AssistanceHero(onRequest: () => _startRequest(context)),
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                    const Text('What do you need?', style: AppTextStyles.h2),
                    const SizedBox(height: AppSpacing.md),
                    servicesAsync.when(
                      data: (services) => ServiceGrid(services: services, onTap: (key) => enterServiceFlow(context, ref, key)),
                      loading: () => const Padding(padding: EdgeInsets.all(AppSpacing.xl), child: LoadingView()),
                      error: (e, __) => Text('Could not load services: $e'),
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

/// "Car trouble? Get the help you need, wherever you are." — the main
/// assistance section. One deliberate amber action, no competing elements.
class _AssistanceHero extends StatelessWidget {
  final VoidCallback onRequest;
  const _AssistanceHero({required this.onRequest});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Car trouble?', style: AppTextStyles.display),
        const SizedBox(height: 4),
        Text(
          'Get the help you need, wherever you are.',
          style: AppTextStyles.description.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(label: 'Request assistance', icon: Icons.build_rounded, onPressed: onRequest),
      ],
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

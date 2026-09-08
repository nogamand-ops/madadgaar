import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

import 'helper_home_providers.dart';
import 'widgets/helper_active_job_view.dart';
import 'widgets/incoming_offer_view.dart';

class HelperHomeScreen extends ConsumerWidget {
  const HelperHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offer = ref.watch(incomingOfferProvider);
    final profileAsync = ref.watch(helperProfileProvider);
    final activeJobAsync = ref.watch(myActiveJobProvider);
    final earningsAsync = ref.watch(helperEarningsProvider);

    if (offer != null) {
      return IncomingOfferView(offer: offer);
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(helperProfileProvider);
            ref.invalidate(helperEarningsProvider);
            await ref.read(myActiveJobProvider.notifier).refresh();
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
                    profileAsync.when(
                      data: (profile) => profile == null
                          ? const SizedBox.shrink()
                          : _HelperHeader(profile: profile),
                      loading: () => const LoadingView(),
                      error: (e, __) => Text('$e'),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    earningsAsync.when(
                      data: (earnings) => earnings == null
                          ? const SizedBox.shrink()
                          : Row(
                              children: [
                                Expanded(child: _StatTile(label: "Today's earnings", value: formatPkr(earnings.today))),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(child: _StatTile(label: 'Completed jobs', value: '${earnings.completedJobs}')),
                              ],
                            ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    activeJobAsync.when(
                      data: (job) => job != null
                          ? HelperActiveJobView(request: job)
                          : profileAsync.value?.isVerified == true
                              ? const _WaitingForRequests()
                              : const _VerificationNotice(),
                      loading: () => const LoadingView(),
                      error: (e, __) => Text('$e'),
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

class _HelperHeader extends ConsumerWidget {
  final HelperProfile profile;
  const _HelperHeader({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = profile.availability == 'online';
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
          Row(
            children: [
              InitialsAvatar(name: profile.name, size: 48),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name, style: AppTextStyles.h3),
                    Row(children: [
                      RatingStars(rating: profile.rating, size: 13),
                      const SizedBox(width: AppSpacing.xs),
                      Text('${profile.rating.toStringAsFixed(1)} · ${profile.completedJobs} jobs', style: AppTextStyles.caption),
                    ]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TrustBadgeRow(helper: profile, compact: true),
          if (profile.isVerified) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(isOnline ? 'You are online' : 'You are offline', style: AppTextStyles.bodyStrong),
                ),
                Switch(
                  value: isOnline,
                  activeColor: AppColors.primary,
                  onChanged: (value) async {
                    await ref.read(madadgaarApiProvider).updateHelper(profile.id, {'availability': value ? 'online' : 'offline'});
                    ref.invalidate(helperProfileProvider);
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
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
          Text(value, style: AppTextStyles.h2),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
        ],
      ),
    );
  }
}

class _WaitingForRequests extends StatelessWidget {
  const _WaitingForRequests();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Column(
        children: [
          const Icon(Icons.radar_rounded, size: 48, color: AppColors.primary),
          const SizedBox(height: AppSpacing.lg),
          Text('Waiting for requests nearby…', style: AppTextStyles.h3, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Go online to start receiving nearby assistance requests.',
            style: AppTextStyles.body.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _VerificationNotice extends StatelessWidget {
  const _VerificationNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.hourglass_top_rounded, color: AppColors.warning),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Text(
              'Your account is not verified yet, so you cannot go online. We will notify you once your application is reviewed.',
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

import '../helper_home_providers.dart';

final _servicesProvider = FutureProvider.autoDispose((ref) => ref.watch(madadgaarApiProvider).services());

class IncomingOfferView extends ConsumerWidget {
  final IncomingOffer offer;
  const IncomingOfferView({super.key, required this.offer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = offer.request;
    final servicesAsync = ref.watch(_servicesProvider);
    final service = servicesAsync.value?.where((s) => s.key == request.serviceKey).firstOrNull;

    return Material(
      color: AppColors.darkBg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
              Text('NEW REQUEST', style: AppTextStyles.overline.copyWith(color: AppColors.primary)),
              const SizedBox(height: AppSpacing.sm),
              Text(service?.name ?? request.serviceKey, style: AppTextStyles.display, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xl),
              _CountdownRing(secondsLeft: offer.secondsLeft, total: 15),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(request.pickupLocation.address ?? 'Pickup location', style: AppTextStyles.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(Icons.social_distance_rounded, size: 18, color: AppColors.secondary),
                        const SizedBox(width: AppSpacing.xs),
                        Text('${request.distanceKm.toStringAsFixed(1)} km away', style: AppTextStyles.body),
                      ],
                    ),
                    const Divider(height: AppSpacing.xxl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('You earn', style: AppTextStyles.h3),
                        MoneyText(request.pricing.revenue.helperEarnings, style: AppTextStyles.price, color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ref.read(incomingOfferProvider.notifier).decline(),
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(label: 'Accept', icon: Icons.check_rounded, onPressed: () => ref.read(incomingOfferProvider.notifier).accept()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountdownRing extends StatelessWidget {
  final int secondsLeft;
  final int total;
  const _CountdownRing({required this.secondsLeft, required this.total});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: CircularProgressIndicator(
              value: secondsLeft / total,
              strokeWidth: 5,
              color: AppColors.primary,
              backgroundColor: AppColors.darkBorder,
            ),
          ),
          Text('$secondsLeft', style: AppTextStyles.h1),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

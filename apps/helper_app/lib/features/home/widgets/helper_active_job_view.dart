import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:madadgaar_core/madadgaar_core.dart';

final _customerProvider = FutureProvider.family.autoDispose<AppUser, String>((ref, id) => ref.watch(madadgaarApiProvider).getUser(id));

const _nextStatus = {
  RequestStatus.helperOnTheWay: (label: "I've Arrived", next: 'ARRIVED'),
  RequestStatus.arrived: (label: 'Start Service', next: 'SERVICE_STARTED'),
  RequestStatus.serviceStarted: (label: 'Complete Job', next: 'COMPLETED'),
};

class HelperActiveJobView extends ConsumerStatefulWidget {
  final ServiceRequest request;
  const HelperActiveJobView({super.key, required this.request});

  @override
  ConsumerState<HelperActiveJobView> createState() => _HelperActiveJobViewState();
}

class _HelperActiveJobViewState extends ConsumerState<HelperActiveJobView> {
  bool _updating = false;

  Future<void> _advance(String next) async {
    setState(() => _updating = true);
    try {
      await ref.read(madadgaarApiProvider).updateRequestStatus(widget.request.id, next);
      if (next == 'COMPLETED' && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job completed — earnings updated.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update: $e')));
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final customerAsync = ref.watch(_customerProvider(request.customerId));
    final pickup = ll.LatLng(request.pickupLocation.lat, request.pickupLocation.lng);
    final action = _nextStatus[request.status];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [Text('Current Job', style: AppTextStyles.overline.copyWith(color: AppColors.primary)), const Spacer(), StatusBadge(request.status, forHelper: true)]),
        const SizedBox(height: AppSpacing.md),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: SizedBox(
            height: 180,
            child: FlutterMap(
              options: MapOptions(initialCenter: pickup, initialZoom: 14.5, interactionOptions: const InteractionOptions(flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag)),
              children: [
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.madadgaar.helper_app'),
                MarkerLayer(markers: [
                  Marker(point: pickup, width: 40, height: 40, child: const Icon(Icons.location_pin, color: AppColors.danger, size: 40)),
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        customerAsync.when(
          data: (customer) => Row(
            children: [
              InitialsAvatar(name: customer.name, size: 44),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.name, style: AppTextStyles.h3),
                    Text(request.pickupLocation.address ?? '', style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              MoneyText(request.pricing.revenue.helperEarnings, style: AppTextStyles.bodyStrong, color: AppColors.primary),
            ],
          ),
          loading: () => const LoadingView(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.call_rounded, size: 18), label: const Text('Call'))),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push('/chat/${request.id}'),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: const Text('Chat'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (action != null) PrimaryButton(label: action.label, onPressed: () => _advance(action.next), loading: _updating),
      ],
    );
  }
}

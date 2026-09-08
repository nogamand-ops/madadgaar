import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:madadgaar_core/madadgaar_core.dart';

import 'call_screen.dart';
import 'cancel_sheet.dart';
import 'payment_screen.dart';
import 'sos_sheet.dart';

final _helperProvider = FutureProvider.family.autoDispose<HelperProfile?, String>((ref, helperId) {
  return ref.watch(madadgaarApiProvider).getHelper(helperId);
});

const _timeline = [
  RequestStatus.helperOnTheWay,
  RequestStatus.arrived,
  RequestStatus.serviceStarted,
  RequestStatus.completed,
];

class TrackingScreen extends ConsumerStatefulWidget {
  final String requestId;
  const TrackingScreen({super.key, required this.requestId});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  bool _navigatedToPayment = false;

  @override
  Widget build(BuildContext context) {
    final live = ref.watch(requestLiveProvider(widget.requestId));
    final request = live.request;

    ref.listen(requestLiveProvider(widget.requestId), (previous, next) {
      final status = next.request?.status;
      if (status == RequestStatus.completed && !_navigatedToPayment) {
        _navigatedToPayment = true;
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => PaymentScreen(request: next.request!)));
      }
      if (status == RequestStatus.cancelled && previous?.request?.status != RequestStatus.cancelled) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This request was cancelled.')));
        context.go('/home');
      }
    });

    if (request == null) {
      return const Scaffold(body: LoadingView(label: 'Loading your request…'));
    }

    final helperAsync = request.helperId != null ? ref.watch(_helperProvider(request.helperId!)) : null;
    final helper = helperAsync?.value;

    return Scaffold(
      appBar: AppBar(
        title: StatusBadge(request.status),
        actions: [
          IconButton(
            tooltip: 'SOS',
            icon: const Icon(Icons.sos_rounded, color: AppColors.danger),
            onPressed: () => showSosSheet(context, address: request.pickupLocation.address ?? 'your location'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(flex: 5, child: _TrackingMap(request: request, helperLocation: live.helperLocation)),
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, -3))],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StatusTimeline(current: request.status),
                    const SizedBox(height: AppSpacing.lg),
                    if (helper != null)
                      HelperPreviewCard(
                        name: helper.name,
                        rating: helper.rating,
                        completedJobs: helper.completedJobs,
                        vehicleLabel: helper.vehicleLabel,
                        verified: helper.isVerified,
                        highlyRated: helper.isHighlyRated,
                        distanceKm: live.helperDistanceKm ?? request.distanceKm,
                        etaMinutes: live.helperEtaMinutes,
                      )
                    else
                      const LoadingView(),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: helper == null
                                ? null
                                : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CallScreen(helperName: helper.name))),
                            icon: const Icon(Icons.call_rounded, size: 18),
                            label: const Text('Call'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/chat/${widget.requestId}'),
                            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                            label: const Text('Chat'),
                          ),
                        ),
                      ],
                    ),
                    if (request.status.isActive && request.status != RequestStatus.serviceStarted) ...[
                      const SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: () => showCancelSheet(
                          context,
                          ref,
                          requestId: widget.requestId,
                          feeMayApply: request.status != RequestStatus.searching,
                          cancellationFeeFlat: 100,
                        ),
                        child: const Text('Cancel request', style: TextStyle(color: AppColors.danger)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final RequestStatus current;
  const _StatusTimeline({required this.current});

  @override
  Widget build(BuildContext context) {
    final currentIndex = _timeline.indexOf(current);
    return Row(
      children: [
        for (var i = 0; i < _timeline.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i <= currentIndex ? AppColors.primary : Theme.of(context).dividerColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _timeline[i].helperLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: i <= currentIndex ? AppColors.primary : Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (i != _timeline.length - 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Container(width: 16, height: 2, color: i < currentIndex ? AppColors.primary : Theme.of(context).dividerColor),
            ),
        ],
      ],
    );
  }
}

class _TrackingMap extends StatefulWidget {
  final ServiceRequest request;
  final GeoPoint? helperLocation;
  const _TrackingMap({required this.request, required this.helperLocation});

  @override
  State<_TrackingMap> createState() => _TrackingMapState();
}

class _TrackingMapState extends State<_TrackingMap> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1900));
  ll.LatLng? _from;
  ll.LatLng? _to;
  final _mapController = MapController();
  bool _fitted = false;

  @override
  void didUpdateWidget(covariant _TrackingMap old) {
    super.didUpdateWidget(old);
    final loc = widget.helperLocation;
    if (loc != null) {
      final target = ll.LatLng(loc.lat, loc.lng);
      if (_to == null || target != _to) {
        _from = _currentHelperPoint() ?? target;
        _to = target;
        _controller
          ..reset()
          ..forward();
      }
    }
  }

  ll.LatLng? _currentHelperPoint() {
    if (_from == null || _to == null) return widget.helperLocation != null ? ll.LatLng(widget.helperLocation!.lat, widget.helperLocation!.lng) : null;
    final t = _controller.value;
    return ll.LatLng(_from!.latitude + (_to!.latitude - _from!.latitude) * t, _from!.longitude + (_to!.longitude - _from!.longitude) * t);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pickup = ll.LatLng(widget.request.pickupLocation.lat, widget.request.pickupLocation.lng);
    final helperPoint = widget.helperLocation != null ? ll.LatLng(widget.helperLocation!.lat, widget.helperLocation!.lng) : null;

    if (!_fitted && helperPoint != null) {
      _fitted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.fitCamera(CameraFit.coordinates(coordinates: [pickup, helperPoint], padding: const EdgeInsets.all(60)));
      });
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: pickup, initialZoom: 14),
      children: [
        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.madadgaar.customer_app'),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final animatedHelper = _currentHelperPoint();
            return MarkerLayer(markers: [
              Marker(
                point: pickup,
                width: 40,
                height: 40,
                child: const Icon(Icons.location_pin, size: 40, color: AppColors.danger),
              ),
              if (animatedHelper != null)
                Marker(
                  point: animatedHelper,
                  width: 40,
                  height: 40,
                  child: Container(
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.two_wheeler_rounded, color: Colors.white, size: 20),
                  ),
                ),
            ]);
          },
        ),
      ],
    );
  }
}

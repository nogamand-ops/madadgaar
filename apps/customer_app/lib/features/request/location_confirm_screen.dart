import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:madadgaar_core/madadgaar_core.dart';

import '../home/home_providers.dart';
import 'geocoding_service.dart';
import 'price_confirm_screen.dart';
import 'request_flow_controller.dart';

const _islamabadFallback = ll.LatLng(33.6844, 73.0479);

class LocationConfirmScreen extends ConsumerStatefulWidget {
  const LocationConfirmScreen({super.key});

  @override
  ConsumerState<LocationConfirmScreen> createState() => _LocationConfirmScreenState();
}

class _LocationConfirmScreenState extends ConsumerState<LocationConfirmScreen> {
  final _mapController = MapController();
  final _searchController = TextEditingController();
  final _geocoding = GeocodingService();
  Timer? _debounce;

  ll.LatLng _selected = _islamabadFallback;
  String? _address;
  List<PlaceResult> _results = [];
  bool _locating = false;
  bool _resolvingAddress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initFromProfile());
  }

  Future<void> _initFromProfile() async {
    final profile = await ref.read(customerProfileProvider.future);
    final loc = profile?.savedLocations.firstOrNull;
    if (loc != null && mounted) {
      _setSelected(ll.LatLng(loc.lat, loc.lng), address: loc.label);
      _mapController.move(_selected, 15);
    } else {
      _resolveAddress(_selected);
    }
  }

  void _setSelected(ll.LatLng point, {String? address}) {
    setState(() {
      _selected = point;
      _address = address;
      _results = [];
    });
    if (address == null) _resolveAddress(point);
  }

  Future<void> _resolveAddress(ll.LatLng point) async {
    setState(() => _resolvingAddress = true);
    final label = await _geocoding.reverse(point.latitude, point.longitude);
    if (!mounted) return;
    setState(() {
      _address = label ?? '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
      _resolvingAddress = false;
    });
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied — pick a point on the map instead.')),
          );
        }
        return;
      }
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are off — pick a point on the map instead.')),
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition().timeout(const Duration(seconds: 8));
      final point = ll.LatLng(pos.latitude, pos.longitude);
      _mapController.move(point, 15);
      _setSelected(point);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get your GPS location right now — pick a point on the map instead.')),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      final results = await _geocoding.search(query);
      if (mounted) setState(() => _results = results);
    });
  }

  void _confirm() {
    ref.read(requestFlowProvider.notifier).setLocation(lat: _selected.latitude, lng: _selected.longitude, address: _address);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PriceConfirmScreen()));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm your location')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selected,
              initialZoom: 14,
              onTap: (_, point) => _setSelected(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.madadgaar.customer_app',
              ),
              MarkerLayer(markers: [
                Marker(
                  point: _selected,
                  width: 44,
                  height: 44,
                  child: const Icon(Icons.location_pin, size: 44, color: AppColors.danger),
                ),
              ]),
            ],
          ),
          Positioned(
            top: AppSpacing.md,
            left: AppSpacing.md,
            right: AppSpacing.md,
            child: Column(
              children: [
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Search area, road or landmark',
                      prefixIcon: Icon(Icons.search_rounded),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (_results.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final r = _results[i];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.place_outlined, size: 18),
                          title: Text(r.label, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.body),
                          onTap: () {
                            final point = ll.LatLng(r.lat, r.lng);
                            _mapController.move(point, 16);
                            _setSelected(point, address: r.label);
                            _searchController.clear();
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            right: AppSpacing.lg,
            bottom: 190,
            child: FloatingActionButton.small(
              heroTag: 'gps',
              onPressed: _locating ? null : _useCurrentLocation,
              child: _locating
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location_rounded),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, -4))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _resolvingAddress
                            ? const Text('Locating address…', style: AppTextStyles.body)
                            : Text(_address ?? '', style: AppTextStyles.bodyStrong, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(label: 'Confirm this location', onPressed: _confirm),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

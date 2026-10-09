import 'package:flutter/material.dart';

/// Real icon + accent color per service, replacing raw emoji everywhere in
/// the UI. Each service gets its own tint (the way Uber/inDrive/Careem tint
/// each ride category) so the service grid reads as designed, not as a flat
/// list. The backend's `icon` (emoji) field stays as admin-facing metadata —
/// this is what the apps actually render.
class ServiceVisual {
  final IconData icon;
  final Color color;
  const ServiceVisual(this.icon, this.color);
}

const Map<String, ServiceVisual> serviceVisuals = {
  'fuel': ServiceVisual(Icons.local_gas_station_rounded, Color(0xFFF59E0B)),
  'battery': ServiceVisual(Icons.battery_charging_full_rounded, Color(0xFF10B981)),
  'tire': ServiceVisual(Icons.tire_repair_rounded, Color(0xFF6366F1)),
  'mechanic': ServiceVisual(Icons.build_rounded, Color(0xFF38BDF8)),
  'towing': ServiceVisual(Icons.local_shipping_rounded, Color(0xFFF97316)),
  'other': ServiceVisual(Icons.help_outline_rounded, Color(0xFF94A3B8)),
};

ServiceVisual visualFor(String serviceKey) => serviceVisuals[serviceKey] ?? serviceVisuals['other']!;

/// A tinted, rounded icon badge — the single building block that replaces
/// every bare emoji in the product.
class ServiceIconBadge extends StatelessWidget {
  final String serviceKey;
  final double size;
  const ServiceIconBadge({super.key, required this.serviceKey, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final visual = visualFor(serviceKey);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [visual.color.withValues(alpha: 0.22), visual.color.withValues(alpha: 0.12)],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(visual.icon, color: visual.color, size: size * 0.52),
    );
  }
}

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Real icon per service, replacing raw emoji everywhere in the UI. Every
/// service shares the same neutral badge treatment by default — amber is
/// reserved for the *selected* state, per the design system, so the five
/// service options read as one calm set rather than a rainbow competing
/// for attention.
const Map<String, IconData> serviceIcons = {
  'fuel': Icons.local_gas_station_rounded,
  'battery': Icons.battery_charging_full_rounded,
  'tire': Icons.tire_repair_rounded,
  'mechanic': Icons.build_rounded,
  'towing': Icons.local_shipping_rounded,
  'other': Icons.help_outline_rounded,
};

IconData iconFor(String serviceKey) => serviceIcons[serviceKey] ?? serviceIcons['other']!;

/// A rounded icon badge — the single building block that replaces every
/// bare emoji in the product. Neutral by default; pass [selected] to switch
/// to the amber "this one's active" treatment.
class ServiceIconBadge extends StatelessWidget {
  final String serviceKey;
  final double size;
  final bool selected;
  const ServiceIconBadge({super.key, required this.serviceKey, this.size = 44, this.selected = false});

  @override
  Widget build(BuildContext context) {
    final icon = iconFor(serviceKey);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        color: selected ? AppColors.amber : AppColors.lightCardAlt,
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: selected ? AppColors.charcoalDeep : AppColors.charcoal, size: size * 0.5),
    );
  }
}

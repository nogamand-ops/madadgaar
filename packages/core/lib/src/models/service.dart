class MadadgaarService {
  final String key;
  final String name;
  final String icon;
  final String description;
  final bool active;

  /// Admin-configurable quick-pick "what's wrong?" options shown before
  /// location/price for this service (empty for fuel, which has its own
  /// type+quantity step, and for "other").
  final List<String> problemOptions;

  const MadadgaarService({
    required this.key,
    required this.name,
    required this.icon,
    required this.description,
    required this.active,
    this.problemOptions = const [],
  });

  factory MadadgaarService.fromJson(Map<String, dynamic> json) => MadadgaarService(
        key: json['key'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
        description: json['description'] as String? ?? '',
        active: json['active'] as bool? ?? true,
        problemOptions: List<String>.from(json['problemOptions'] as List? ?? const []),
      );
}

class CityOperatingHours {
  final String open;
  final String close;
  const CityOperatingHours({required this.open, required this.close});

  factory CityOperatingHours.fromJson(Map<String, dynamic> json) =>
      CityOperatingHours(open: json['open'] as String, close: json['close'] as String);
}

class City {
  final String id;
  final String name;
  final bool enabled;
  final double centerLat;
  final double centerLng;
  final double serviceRadiusKm;
  final CityOperatingHours operatingHours;

  const City({
    required this.id,
    required this.name,
    required this.enabled,
    required this.centerLat,
    required this.centerLng,
    required this.serviceRadiusKm,
    required this.operatingHours,
  });

  factory City.fromJson(Map<String, dynamic> json) => City(
        id: json['id'] as String,
        name: json['name'] as String,
        enabled: json['enabled'] as bool,
        centerLat: (json['center']['lat'] as num).toDouble(),
        centerLng: (json['center']['lng'] as num).toDouble(),
        serviceRadiusKm: (json['serviceRadiusKm'] as num).toDouble(),
        operatingHours: CityOperatingHours.fromJson(json['operatingHours'] as Map<String, dynamic>),
      );
}

class GeoPoint {
  final double lat;
  final double lng;

  const GeoPoint({required this.lat, required this.lng});

  factory GeoPoint.fromJson(Map<String, dynamic> json) => GeoPoint(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

class SavedLocation {
  final String label;
  final double lat;
  final double lng;

  const SavedLocation({required this.label, required this.lat, required this.lng});

  factory SavedLocation.fromJson(Map<String, dynamic> json) => SavedLocation(
        label: json['label'] as String? ?? '',
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {'label': label, 'lat': lat, 'lng': lng};
}

class PickupLocation {
  final double lat;
  final double lng;
  final String? address;

  const PickupLocation({required this.lat, required this.lng, this.address});

  factory PickupLocation.fromJson(Map<String, dynamic> json) => PickupLocation(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        address: json['address'] as String?,
      );

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng, if (address != null) 'address': address};
}

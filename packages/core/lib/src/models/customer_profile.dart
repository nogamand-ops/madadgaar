import 'geo_point.dart';

class CustomerProfile {
  final String userId;
  final List<SavedLocation> savedLocations;
  final String? defaultVehicleId;

  const CustomerProfile({
    required this.userId,
    required this.savedLocations,
    this.defaultVehicleId,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) => CustomerProfile(
        userId: json['userId'] as String,
        savedLocations: (json['savedLocations'] as List? ?? [])
            .map((e) => SavedLocation.fromJson(e as Map<String, dynamic>))
            .toList(),
        defaultVehicleId: json['defaultVehicleId'] as String?,
      );
}

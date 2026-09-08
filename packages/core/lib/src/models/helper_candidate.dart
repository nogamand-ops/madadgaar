/// Public-safe preview of a helper being offered a request — what the
/// customer sees during "Finding a Madadgaar nearby…" / "Best match found".
class HelperCandidate {
  final String helperId;
  final String name;
  final double rating;
  final int completedJobs;
  final String vehicleType;
  final String? vehicleMake;
  final String? vehicleModel;
  final List<String> badges;
  final bool verified;
  final String? photoUrl;
  final double distanceKm;
  final int etaMinutes;

  const HelperCandidate({
    required this.helperId,
    required this.name,
    required this.rating,
    required this.completedJobs,
    required this.vehicleType,
    required this.badges,
    required this.verified,
    required this.distanceKm,
    required this.etaMinutes,
    this.vehicleMake,
    this.vehicleModel,
    this.photoUrl,
  });

  factory HelperCandidate.fromJson(Map<String, dynamic> json) => HelperCandidate(
        helperId: json['helperId'] as String,
        name: json['name'] as String,
        rating: (json['rating'] as num).toDouble(),
        completedJobs: (json['completedJobs'] as num).toInt(),
        vehicleType: json['vehicleType'] as String,
        vehicleMake: json['vehicleMake'] as String?,
        vehicleModel: json['vehicleModel'] as String?,
        badges: List<String>.from(json['badges'] as List? ?? []),
        verified: json['verified'] as bool? ?? false,
        photoUrl: json['photoUrl'] as String?,
        distanceKm: (json['distanceKm'] as num).toDouble(),
        etaMinutes: (json['etaMinutes'] as num).toInt(),
      );
}

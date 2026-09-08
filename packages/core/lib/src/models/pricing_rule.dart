class FuelPrices {
  final double petrol;
  final double diesel;
  const FuelPrices({required this.petrol, required this.diesel});

  factory FuelPrices.fromJson(Map<String, dynamic>? json) => FuelPrices(
        petrol: (json?['petrol'] as num?)?.toDouble() ?? 0,
        diesel: (json?['diesel'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {'petrol': petrol, 'diesel': diesel};
}

/// Admin-configurable pricing for one city + service combination.
/// Nothing here is hardcoded in any app UI — this is always fetched.
class PricingRule {
  final String cityId;
  final String serviceKey;
  final int baseServiceFee;
  final int perKmFee;
  final int freeKm;
  final int minFare;
  final int nightSurchargeAmount;
  final int nightStartHour;
  final int nightEndHour;
  final int cancellationFeeFlat;
  final double platformCommissionPct;
  final FuelPrices? fuelPricePerLitre;

  const PricingRule({
    required this.cityId,
    required this.serviceKey,
    required this.baseServiceFee,
    required this.perKmFee,
    required this.freeKm,
    required this.minFare,
    required this.nightSurchargeAmount,
    required this.nightStartHour,
    required this.nightEndHour,
    required this.cancellationFeeFlat,
    required this.platformCommissionPct,
    this.fuelPricePerLitre,
  });

  factory PricingRule.fromJson(Map<String, dynamic> json) => PricingRule(
        cityId: json['cityId'] as String,
        serviceKey: json['serviceKey'] as String,
        baseServiceFee: (json['baseServiceFee'] as num).toInt(),
        perKmFee: (json['perKmFee'] as num).toInt(),
        freeKm: (json['freeKm'] as num).toInt(),
        minFare: (json['minFare'] as num?)?.toInt() ?? 0,
        nightSurchargeAmount: (json['nightSurchargeAmount'] as num).toInt(),
        nightStartHour: (json['nightStartHour'] as num).toInt(),
        nightEndHour: (json['nightEndHour'] as num).toInt(),
        cancellationFeeFlat: (json['cancellationFeeFlat'] as num).toInt(),
        platformCommissionPct: (json['platformCommissionPct'] as num).toDouble(),
        fuelPricePerLitre: json['fuelPricePerLitre'] != null ? FuelPrices.fromJson(json['fuelPricePerLitre']) : null,
      );

  Map<String, dynamic> toJson() => {
        'baseServiceFee': baseServiceFee,
        'perKmFee': perKmFee,
        'freeKm': freeKm,
        'minFare': minFare,
        'nightSurchargeAmount': nightSurchargeAmount,
        'nightStartHour': nightStartHour,
        'nightEndHour': nightEndHour,
        'cancellationFeeFlat': cancellationFeeFlat,
        'platformCommissionPct': platformCommissionPct,
        if (fuelPricePerLitre != null) 'fuelPricePerLitre': fuelPricePerLitre!.toJson(),
      };
}

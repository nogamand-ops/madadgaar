/// Every line item the customer is charged. Nothing is hidden — this is
/// rendered verbatim on the price-confirmation and payment screens.
class PriceBreakdown {
  final int fuelCost;
  final int assistanceFee;
  final int distanceFee;
  final int nightSurcharge;
  final int discount;
  final int total;

  const PriceBreakdown({
    required this.fuelCost,
    required this.assistanceFee,
    required this.distanceFee,
    required this.nightSurcharge,
    required this.discount,
    required this.total,
  });

  factory PriceBreakdown.fromJson(Map<String, dynamic> json) => PriceBreakdown(
        fuelCost: (json['fuelCost'] as num?)?.toInt() ?? 0,
        assistanceFee: (json['assistanceFee'] as num).toInt(),
        distanceFee: (json['distanceFee'] as num).toInt(),
        nightSurcharge: (json['nightSurcharge'] as num).toInt(),
        discount: (json['discount'] as num?)?.toInt() ?? 0,
        total: (json['total'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'fuelCost': fuelCost,
        'assistanceFee': assistanceFee,
        'distanceFee': distanceFee,
        'nightSurcharge': nightSurcharge,
        'discount': discount,
        'total': total,
      };
}

/// Business-side revenue split — shown to helpers (their earnings) and
/// admins (commission), never rendered on the customer screen.
class RevenueSplit {
  final int serviceRevenue;
  final int platformCommission;
  final int helperEarnings;
  final int madadgaarRevenue;

  const RevenueSplit({
    required this.serviceRevenue,
    required this.platformCommission,
    required this.helperEarnings,
    required this.madadgaarRevenue,
  });

  factory RevenueSplit.fromJson(Map<String, dynamic> json) => RevenueSplit(
        serviceRevenue: (json['serviceRevenue'] as num).toInt(),
        platformCommission: (json['platformCommission'] as num).toInt(),
        helperEarnings: (json['helperEarnings'] as num).toInt(),
        madadgaarRevenue: (json['madadgaarRevenue'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'serviceRevenue': serviceRevenue,
        'platformCommission': platformCommission,
        'helperEarnings': helperEarnings,
        'madadgaarRevenue': madadgaarRevenue,
      };
}

class PriceEstimate {
  final double distanceKm;
  final String serviceKey;
  final bool isNight;
  final PriceBreakdown breakdown;
  final RevenueSplit revenue;

  const PriceEstimate({
    required this.distanceKm,
    required this.serviceKey,
    required this.isNight,
    required this.breakdown,
    required this.revenue,
  });

  factory PriceEstimate.fromJson(Map<String, dynamic> json) => PriceEstimate(
        distanceKm: (json['distanceKm'] as num).toDouble(),
        serviceKey: json['serviceKey'] as String,
        isNight: json['isNight'] as bool,
        breakdown: PriceBreakdown.fromJson(json['breakdown'] as Map<String, dynamic>),
        revenue: RevenueSplit.fromJson(json['revenue'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'distanceKm': distanceKm,
        'serviceKey': serviceKey,
        'isNight': isNight,
        'breakdown': breakdown.toJson(),
        'revenue': revenue.toJson(),
      };
}

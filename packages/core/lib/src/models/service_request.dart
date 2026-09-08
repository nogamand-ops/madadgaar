import 'geo_point.dart';
import 'price_estimate.dart';

enum RequestStatus {
  requested,
  searching,
  accepted,
  helperOnTheWay,
  arrived,
  serviceStarted,
  completed,
  cancelled,
}

const _statusWire = {
  RequestStatus.requested: 'REQUESTED',
  RequestStatus.searching: 'SEARCHING',
  RequestStatus.accepted: 'ACCEPTED',
  RequestStatus.helperOnTheWay: 'HELPER_ON_THE_WAY',
  RequestStatus.arrived: 'ARRIVED',
  RequestStatus.serviceStarted: 'SERVICE_STARTED',
  RequestStatus.completed: 'COMPLETED',
  RequestStatus.cancelled: 'CANCELLED',
};

RequestStatus requestStatusFromWire(String value) =>
    _statusWire.entries.firstWhere((e) => e.value == value, orElse: () => const MapEntry(RequestStatus.requested, '')).key;

extension RequestStatusWire on RequestStatus {
  String get wire => _statusWire[this]!;

  bool get isActive => this != RequestStatus.completed && this != RequestStatus.cancelled;

  String get customerLabel => switch (this) {
        RequestStatus.requested => 'Sending your request…',
        RequestStatus.searching => 'Finding a Madadgaar nearby…',
        RequestStatus.accepted => 'Madadgaar found',
        RequestStatus.helperOnTheWay => 'Your Madadgaar is on the way',
        RequestStatus.arrived => 'Your Madadgaar has arrived',
        RequestStatus.serviceStarted => 'Service in progress',
        RequestStatus.completed => 'Completed',
        RequestStatus.cancelled => 'Cancelled',
      };

  String get helperLabel => switch (this) {
        RequestStatus.requested => 'New request',
        RequestStatus.searching => 'New request',
        RequestStatus.accepted => 'Heading over',
        RequestStatus.helperOnTheWay => 'On the way',
        RequestStatus.arrived => 'Arrived',
        RequestStatus.serviceStarted => 'Service started',
        RequestStatus.completed => 'Completed',
        RequestStatus.cancelled => 'Cancelled',
      };
}

class MatchingInfo {
  final int radiusRoundIndex;
  final List<String> offeredHelperIds;
  final List<String> declinedHelperIds;
  final String? currentOfferHelperId;

  const MatchingInfo({
    required this.radiusRoundIndex,
    required this.offeredHelperIds,
    required this.declinedHelperIds,
    this.currentOfferHelperId,
  });

  factory MatchingInfo.fromJson(Map<String, dynamic> json) => MatchingInfo(
        radiusRoundIndex: (json['radiusRoundIndex'] as num?)?.toInt() ?? 0,
        offeredHelperIds: List<String>.from(json['offeredHelperIds'] as List? ?? []),
        declinedHelperIds: List<String>.from(json['declinedHelperIds'] as List? ?? []),
        currentOfferHelperId: json['currentOfferHelperId'] as String?,
      );
}

class RequestPricing {
  final PriceBreakdown breakdown;
  final RevenueSplit revenue;
  final bool isNight;

  const RequestPricing({required this.breakdown, required this.revenue, required this.isNight});

  factory RequestPricing.fromJson(Map<String, dynamic> json) => RequestPricing(
        breakdown: PriceBreakdown.fromJson(json['breakdown'] as Map<String, dynamic>),
        revenue: RevenueSplit.fromJson(json['revenue'] as Map<String, dynamic>),
        isNight: json['isNight'] as bool? ?? false,
      );
}

class ServiceRequest {
  final String id;
  final String customerId;
  final String? helperId;
  final String serviceKey;
  final Map<String, dynamic> details;
  final String cityId;
  final PickupLocation pickupLocation;
  final RequestStatus status;
  final RequestPricing pricing;
  final double distanceKm;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? arrivedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancelReason;
  final String? cancelledBy;
  final int? cancellationFeeCharged;
  final MatchingInfo matching;

  const ServiceRequest({
    required this.id,
    required this.customerId,
    required this.serviceKey,
    required this.details,
    required this.cityId,
    required this.pickupLocation,
    required this.status,
    required this.pricing,
    required this.distanceKm,
    required this.createdAt,
    required this.matching,
    this.helperId,
    this.acceptedAt,
    this.arrivedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancelReason,
    this.cancelledBy,
    this.cancellationFeeCharged,
  });

  static DateTime? _dt(dynamic v) => v == null ? null : DateTime.parse(v as String);

  factory ServiceRequest.fromJson(Map<String, dynamic> json) => ServiceRequest(
        id: json['id'] as String,
        customerId: json['customerId'] as String,
        helperId: json['helperId'] as String?,
        serviceKey: json['serviceKey'] as String,
        details: Map<String, dynamic>.from(json['details'] as Map? ?? {}),
        cityId: json['cityId'] as String,
        pickupLocation: PickupLocation.fromJson(json['pickupLocation'] as Map<String, dynamic>),
        status: requestStatusFromWire(json['status'] as String),
        pricing: RequestPricing.fromJson(json['pricing'] as Map<String, dynamic>),
        distanceKm: (json['distanceKm'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        acceptedAt: _dt(json['acceptedAt']),
        arrivedAt: _dt(json['arrivedAt']),
        startedAt: _dt(json['startedAt']),
        completedAt: _dt(json['completedAt']),
        cancelledAt: _dt(json['cancelledAt']),
        cancelReason: json['cancelReason'] as String?,
        cancelledBy: json['cancelledBy'] as String?,
        cancellationFeeCharged: (json['cancellationFeeCharged'] as num?)?.toInt(),
        matching: MatchingInfo.fromJson(json['matching'] as Map<String, dynamic>? ?? const {}),
      );
}

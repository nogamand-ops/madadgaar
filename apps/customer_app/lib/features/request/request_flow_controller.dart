import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

/// The in-progress "I need help" wizard: What's wrong? -> details -> location
/// -> price -> confirm. Lives outside go_router entirely so pushed wizard
/// screens don't need to pass state through route params.
class RequestDraft {
  final String? serviceKey;
  final Map<String, dynamic> details;
  final double? lat;
  final double? lng;
  final String? address;
  final String cityId;
  final PriceEstimate? estimate;
  final bool estimating;
  final String? estimateError;

  const RequestDraft({
    this.serviceKey,
    this.details = const {},
    this.lat,
    this.lng,
    this.address,
    this.cityId = 'islamabad',
    this.estimate,
    this.estimating = false,
    this.estimateError,
  });

  bool get hasLocation => lat != null && lng != null;

  RequestDraft copyWith({
    String? serviceKey,
    Map<String, dynamic>? details,
    double? lat,
    double? lng,
    String? address,
    String? cityId,
    PriceEstimate? estimate,
    bool? estimating,
    String? estimateError,
    bool clearEstimate = false,
  }) {
    return RequestDraft(
      serviceKey: serviceKey ?? this.serviceKey,
      details: details ?? this.details,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
      cityId: cityId ?? this.cityId,
      estimate: clearEstimate ? null : (estimate ?? this.estimate),
      estimating: estimating ?? this.estimating,
      estimateError: estimateError,
    );
  }
}

class RequestFlowController extends StateNotifier<RequestDraft> {
  final Ref ref;
  RequestFlowController(this.ref) : super(const RequestDraft());

  void reset() => state = const RequestDraft();

  void setService(String key) => state = RequestDraft(serviceKey: key, cityId: state.cityId, lat: state.lat, lng: state.lng, address: state.address);

  void setDetails(Map<String, dynamic> details) => state = state.copyWith(details: details, clearEstimate: true);

  void setLocation({required double lat, required double lng, String? address}) =>
      state = state.copyWith(lat: lat, lng: lng, address: address, clearEstimate: true);

  Future<void> fetchEstimate() async {
    if (state.serviceKey == null || !state.hasLocation) return;
    state = state.copyWith(estimating: true, estimateError: null);
    try {
      final api = ref.read(madadgaarApiProvider);
      final estimate = await api.estimatePrice(
        cityId: state.cityId,
        serviceKey: state.serviceKey!,
        details: state.details,
        lat: state.lat!,
        lng: state.lng!,
      );
      state = state.copyWith(estimate: estimate, estimating: false);
    } catch (e) {
      state = state.copyWith(estimating: false, estimateError: e.toString());
    }
  }

  Future<ServiceRequest> submit() async {
    final api = ref.read(madadgaarApiProvider);
    return api.createRequest(
      serviceKey: state.serviceKey!,
      details: state.details,
      lat: state.lat!,
      lng: state.lng!,
      address: state.address,
      cityId: state.cityId,
      clientRequestId: 'client_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

final requestFlowProvider = StateNotifierProvider<RequestFlowController, RequestDraft>((ref) => RequestFlowController(ref));

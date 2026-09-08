import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/providers.dart';
import '../api/realtime_client.dart';
import '../models/models.dart';

/// Everything the UI needs to render one request live: the request itself,
/// the candidate helper preview while searching, and the helper's live
/// position while en route. Shared by customer_app and helper_app so both
/// sides of one request update from the same WebSocket broadcasts.
class RequestLiveState {
  final ServiceRequest? request;
  final HelperCandidate? candidate;
  final GeoPoint? helperLocation;
  final double? helperDistanceKm;
  final int? helperEtaMinutes;
  final bool noHelpersAvailable;
  final bool loading;
  final String? error;

  const RequestLiveState({
    this.request,
    this.candidate,
    this.helperLocation,
    this.helperDistanceKm,
    this.helperEtaMinutes,
    this.noHelpersAvailable = false,
    this.loading = true,
    this.error,
  });

  RequestLiveState copyWith({
    ServiceRequest? request,
    HelperCandidate? candidate,
    GeoPoint? helperLocation,
    double? helperDistanceKm,
    int? helperEtaMinutes,
    bool? noHelpersAvailable,
    bool? loading,
    String? error,
  }) {
    return RequestLiveState(
      request: request ?? this.request,
      candidate: candidate ?? this.candidate,
      helperLocation: helperLocation ?? this.helperLocation,
      helperDistanceKm: helperDistanceKm ?? this.helperDistanceKm,
      helperEtaMinutes: helperEtaMinutes ?? this.helperEtaMinutes,
      noHelpersAvailable: noHelpersAvailable ?? this.noHelpersAvailable,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class RequestLiveController extends StateNotifier<RequestLiveState> {
  final Ref ref;
  final String requestId;
  StreamSubscription<RealtimeEvent>? _sub;

  RequestLiveController(this.ref, this.requestId) : super(const RequestLiveState()) {
    _load();
    _sub = ref.read(realtimeClientProvider).events.listen(_onEvent);
  }

  Future<void> _load() async {
    try {
      final req = await ref.read(madadgaarApiProvider).getRequest(requestId);
      state = state.copyWith(request: req, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> refresh() => _load();

  void _onEvent(RealtimeEvent event) {
    final payload = event.payload;
    if (payload is! Map) return;
    final p = Map<String, dynamic>.from(payload);

    switch (event.type) {
      case 'request.created':
      case 'request.status_changed':
        if (p['id'] == requestId) {
          state = state.copyWith(request: ServiceRequest.fromJson(p), noHelpersAvailable: false);
        }
        break;
      case 'request.candidate_offered':
        if (p['requestId'] == requestId) {
          state = state.copyWith(candidate: HelperCandidate.fromJson(p), noHelpersAvailable: false);
        }
        break;
      case 'request.no_helpers_available':
        if (p['requestId'] == requestId) {
          state = state.copyWith(noHelpersAvailable: true);
        }
        break;
      case 'helper.location_update':
        if (p['requestId'] == requestId) {
          state = state.copyWith(
            helperLocation: GeoPoint.fromJson(p['location'] as Map<String, dynamic>),
            helperDistanceKm: (p['distanceKm'] as num).toDouble(),
            helperEtaMinutes: (p['etaMinutes'] as num).toInt(),
          );
        }
        break;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final requestLiveProvider = StateNotifierProvider.family<RequestLiveController, RequestLiveState, String>(
  (ref, requestId) => RequestLiveController(ref, requestId),
);

/// Live chat messages for one request, appended to as `chat.message` events
/// arrive over the same WebSocket connection.
class ChatController extends StateNotifier<List<ChatMessage>> {
  final Ref ref;
  final String requestId;
  StreamSubscription<RealtimeEvent>? _sub;

  ChatController(this.ref, this.requestId) : super(const []) {
    _load();
    _sub = ref.read(realtimeClientProvider).events.listen((event) {
      if (event.type != 'chat.message') return;
      final p = Map<String, dynamic>.from(event.payload as Map);
      if (p['requestId'] != requestId) return;
      state = [...state, ChatMessage.fromJson(p)];
    });
  }

  Future<void> _load() async {
    final list = await ref.read(madadgaarApiProvider).messages(requestId);
    state = list;
  }

  Future<void> send(String text, {bool isQuickMessage = false}) async {
    await ref.read(madadgaarApiProvider).sendMessage(requestId, text, isQuickMessage: isQuickMessage);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final chatControllerProvider = StateNotifierProvider.family<ChatController, List<ChatMessage>, String>(
  (ref, requestId) => ChatController(ref, requestId),
);

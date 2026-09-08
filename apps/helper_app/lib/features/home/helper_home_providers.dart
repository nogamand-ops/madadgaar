import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

final helperProfileProvider = FutureProvider.autoDispose<HelperProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  try {
    return await ref.watch(madadgaarApiProvider).getHelper(user.id);
  } catch (_) {
    return null;
  }
});

final helperEarningsProvider = FutureProvider.autoDispose<HelperEarnings?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(madadgaarApiProvider).helperEarnings(user.id);
});

/// A request offered specifically to this helper, with a client-side
/// countdown mirroring the server's offer-expiry window.
class IncomingOffer {
  final ServiceRequest request;
  final int secondsLeft;
  const IncomingOffer({required this.request, required this.secondsLeft});
  IncomingOffer copyWith({int? secondsLeft}) => IncomingOffer(request: request, secondsLeft: secondsLeft ?? this.secondsLeft);
}

class IncomingOfferController extends StateNotifier<IncomingOffer?> {
  final Ref ref;
  StreamSubscription? _sub;
  Timer? _ticker;
  static const _offerSeconds = 15;

  IncomingOfferController(this.ref) : super(null) {
    _sub = ref.read(realtimeClientProvider).events.listen(_onEvent);
  }

  Future<void> _onEvent(RealtimeEvent event) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    if (event.type == 'request.candidate_offered') {
      final p = Map<String, dynamic>.from(event.payload as Map);
      if (p['helperId'] != user.id) return;
      try {
        final request = await ref.read(madadgaarApiProvider).getRequest(p['requestId'] as String);
        _startCountdown(request);
      } catch (_) {}
    }

    if (event.type == 'request.status_changed') {
      final p = Map<String, dynamic>.from(event.payload as Map);
      if (state != null && p['id'] == state!.request.id) {
        _clear();
      }
    }
  }

  void _startCountdown(ServiceRequest request) {
    _ticker?.cancel();
    state = IncomingOffer(request: request, secondsLeft: _offerSeconds);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state;
      if (current == null) return;
      if (current.secondsLeft <= 1) {
        _clear();
      } else {
        state = current.copyWith(secondsLeft: current.secondsLeft - 1);
      }
    });
  }

  void _clear() {
    _ticker?.cancel();
    state = null;
  }

  Future<void> accept() async {
    final requestId = state?.request.id;
    if (requestId == null) return;
    _clear();
    await ref.read(madadgaarApiProvider).acceptRequest(requestId);
  }

  Future<void> decline() async {
    final requestId = state?.request.id;
    if (requestId == null) return;
    _clear();
    await ref.read(madadgaarApiProvider).declineRequest(requestId);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _ticker?.cancel();
    super.dispose();
  }
}

final incomingOfferProvider = StateNotifierProvider<IncomingOfferController, IncomingOffer?>((ref) => IncomingOfferController(ref));

/// The helper's single active job (accepted-but-not-yet-completed request).
class MyActiveJobController extends StateNotifier<AsyncValue<ServiceRequest?>> {
  final Ref ref;
  StreamSubscription? _sub;

  MyActiveJobController(this.ref) : super(const AsyncValue.loading()) {
    _load();
    _sub = ref.read(realtimeClientProvider).events.listen(_onEvent);
  }

  Future<void> _load() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = const AsyncValue.data(null);
      return;
    }
    try {
      final list = await ref.read(madadgaarApiProvider).listRequests(helperId: user.id, status: 'active');
      state = AsyncValue.data(list.isNotEmpty ? list.first : null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void _onEvent(RealtimeEvent event) {
    final user = ref.read(currentUserProvider);
    if (user == null || event.type != 'request.status_changed') return;
    final p = Map<String, dynamic>.from(event.payload as Map);
    if (p['helperId'] != user.id) return;
    final req = ServiceRequest.fromJson(p);
    state = AsyncValue.data(req.status.isActive ? req : null);
  }

  Future<void> refresh() => _load();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final myActiveJobProvider = StateNotifierProvider<MyActiveJobController, AsyncValue<ServiceRequest?>>((ref) => MyActiveJobController(ref));

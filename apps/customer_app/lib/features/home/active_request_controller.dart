import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

/// Watches for the customer's single active request so Home can show the
/// persistent "🚨 Active Request" card (spec section 9) without the user
/// having to navigate anywhere.
class MyActiveRequestController extends StateNotifier<AsyncValue<ServiceRequest?>> {
  final Ref ref;
  StreamSubscription? _sub;

  MyActiveRequestController(this.ref) : super(const AsyncValue.loading()) {
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
      final list = await ref.read(madadgaarApiProvider).listRequests(customerId: user.id, status: 'active');
      state = AsyncValue.data(list.isNotEmpty ? list.first : null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void _onEvent(RealtimeEvent event) {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    if (event.type != 'request.created' && event.type != 'request.status_changed') return;
    final p = Map<String, dynamic>.from(event.payload as Map);
    if (p['customerId'] != user.id) return;
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

final myActiveRequestProvider = StateNotifierProvider<MyActiveRequestController, AsyncValue<ServiceRequest?>>(
  (ref) => MyActiveRequestController(ref),
);

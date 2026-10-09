import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

final customerProfileProvider = FutureProvider.autoDispose<CustomerProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(madadgaarApiProvider).customerProfile(user.id);
});

final citiesProvider = FutureProvider.autoDispose<List<City>>((ref) => ref.watch(madadgaarApiProvider).cities());

final servicesProvider = FutureProvider.autoDispose<List<MadadgaarService>>((ref) => ref.watch(madadgaarApiProvider).services());

final myVehiclesProvider = FutureProvider.autoDispose<List<Vehicle>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(madadgaarApiProvider).vehicles(user.id);
});

final myRequestHistoryProvider = FutureProvider.autoDispose<List<ServiceRequest>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(madadgaarApiProvider).listRequests(customerId: user.id);
});

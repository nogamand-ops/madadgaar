import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import 'api_client.dart';
import 'app_config.dart';
import 'madadgaar_api.dart';
import 'realtime_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(baseUrl: AppConfig.apiBaseUrl));

final madadgaarApiProvider = Provider<MadadgaarApi>((ref) => MadadgaarApi(ref.watch(apiClientProvider)));

final realtimeClientProvider = Provider<RealtimeClient>((ref) {
  final client = RealtimeClient(AppConfig.wsUrl);
  client.connect();
  ref.onDispose(client.dispose);
  return client;
});

final realtimeEventsProvider = StreamProvider<RealtimeEvent>((ref) {
  return ref.watch(realtimeClientProvider).events;
});

class AuthSession {
  final String token;
  final AppUser user;
  const AuthSession({required this.token, required this.user});
}

const _kTokenKey = 'madadgaar_token';
const _kUserKey = 'madadgaar_user_json';

/// Holds the logged-in user (or null) and persists the session locally so a
/// refresh / app restart doesn't force a re-login during the demo.
class AuthController extends StateNotifier<AsyncValue<AuthSession?>> {
  final Ref ref;
  AuthController(this.ref) : super(const AsyncValue.loading()) {
    _restore();
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_kTokenKey);
      final userJson = prefs.getString(_kUserKey);
      if (token != null && userJson != null) {
        ref.read(apiClientProvider).setToken(token);
        state = AsyncValue.data(AuthSession(token: token, user: AppUser.fromJson(jsonDecode(userJson))));
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (_) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> setSession(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokenKey, session.token);
    await prefs.setString(_kUserKey, jsonEncode(session.user.toJson()));
    state = AsyncValue.data(session);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    await prefs.remove(_kUserKey);
    ref.read(apiClientProvider).setToken(null);
    state = const AsyncValue.data(null);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<AuthSession?>>(
  (ref) => AuthController(ref),
);

final currentUserProvider = Provider<AppUser?>((ref) => ref.watch(authControllerProvider).value?.user);

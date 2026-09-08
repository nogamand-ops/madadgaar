import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/otp_screen.dart';
import '../features/legal/legal_screen.dart';
import '../features/request/chat_screen.dart';
import '../features/request/rating_screen.dart';
import '../features/request/tracking_screen.dart';
import '../features/support/support_screen.dart';
import 'app_shell.dart';

final customerRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final loggedIn = authState.value != null;
      final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/otp';
      if (authState.isLoading) return null;
      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/otp',
        builder: (context, state) => OtpScreen(phone: (state.extra as Map?)?['phone'] as String? ?? ''),
      ),
      GoRoute(path: '/home', builder: (context, state) => const AppShell()),
      GoRoute(
        path: '/track/:requestId',
        builder: (context, state) => TrackingScreen(requestId: state.pathParameters['requestId']!),
      ),
      GoRoute(
        path: '/chat/:requestId',
        builder: (context, state) => ChatScreen(requestId: state.pathParameters['requestId']!),
      ),
      GoRoute(
        path: '/rate/:requestId',
        builder: (context, state) => RatingScreen(requestId: state.pathParameters['requestId']!),
      ),
      GoRoute(path: '/support', builder: (context, state) => const SupportScreen()),
      GoRoute(
        path: '/legal/:doc',
        builder: (context, state) => LegalScreen(doc: state.pathParameters['doc']!),
      ),
    ],
  );
});

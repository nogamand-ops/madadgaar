import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/otp_screen.dart';
import '../features/job/chat_screen.dart';
import '../features/registration/registration_screen.dart';
import 'app_shell.dart';

final helperRouterProvider = Provider<GoRouter>((ref) {
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
      GoRoute(path: '/register', builder: (context, state) => const RegistrationScreen()),
      GoRoute(path: '/home', builder: (context, state) => const AppShell()),
      GoRoute(
        path: '/chat/:requestId',
        builder: (context, state) => ChatScreen(requestId: state.pathParameters['requestId']!),
      ),
    ],
  );
});

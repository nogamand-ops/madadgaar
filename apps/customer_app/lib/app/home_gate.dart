import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

import 'app_shell.dart';
import 'helper_app_shell.dart';

/// One app, one `/home` route — which shell renders depends on who's
/// actually logged in, not on which card they tapped on the mode picker.
class HomeGate extends ConsumerWidget {
  const HomeGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user?.role == UserRole.helper) return const HelperAppShell();
    return const AppShell();
  }
}

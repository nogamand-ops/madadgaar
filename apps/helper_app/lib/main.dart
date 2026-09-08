import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

import 'app/router.dart';

void main() {
  runApp(const ProviderScope(child: MadadgaarHelperApp()));
}

class MadadgaarHelperApp extends ConsumerWidget {
  const MadadgaarHelperApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(helperRouterProvider);
    return MaterialApp.router(
      title: 'Madadgaar Helper',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}

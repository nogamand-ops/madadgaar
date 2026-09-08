import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

import 'app/router.dart';

void main() {
  runApp(const ProviderScope(child: MadadgaarCustomerApp()));
}

class MadadgaarCustomerApp extends ConsumerWidget {
  const MadadgaarCustomerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(customerRouterProvider);
    return MaterialApp.router(
      title: 'Madadgaar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}

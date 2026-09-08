import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/earnings/earnings_screen.dart';
import '../features/home/helper_home_screen.dart';
import '../features/jobs/jobs_screen.dart';
import '../features/profile/helper_profile_screen.dart';

final helperTabIndexProvider = StateProvider<int>((ref) => 0);

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(helperTabIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          HelperHomeScreen(),
          JobsScreen(),
          EarningsScreen(),
          HelperProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => ref.read(helperTabIndexProvider.notifier).state = i,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline_rounded), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Earnings'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

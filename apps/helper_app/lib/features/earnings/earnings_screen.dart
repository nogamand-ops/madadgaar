import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

import '../home/helper_home_providers.dart';

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  bool _withdrawing = false;

  Future<void> _withdraw(int amount) async {
    final user = ref.read(currentUserProvider);
    if (user == null || amount <= 0) return;
    setState(() => _withdrawing = true);
    try {
      await ref.read(madadgaarApiProvider).withdrawEarnings(user.id, amount);
      ref.invalidate(helperEarningsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Demo Mode: ${formatPkr(amount)} withdrawal simulated.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not withdraw: $e')));
    } finally {
      if (mounted) setState(() => _withdrawing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final earningsAsync = ref.watch(helperEarningsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: earningsAsync.when(
        data: (earnings) {
          if (earnings == null) return const SizedBox.shrink();
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(helperEarningsProvider),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Row(
                  children: [
                    Expanded(child: _EarningsTile(label: "Today", value: earnings.today)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _EarningsTile(label: 'This week', value: earnings.week)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _EarningsTile(label: 'Total earned', value: earnings.total, large: true),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Available balance', style: AppTextStyles.body.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                      const SizedBox(height: 4),
                      MoneyText(earnings.availableBalance, style: AppTextStyles.display),
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryButton(
                        label: 'Withdraw',
                        loading: _withdrawing,
                        onPressed: earnings.availableBalance > 0 ? () => _withdraw(earnings.availableBalance) : null,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Withdrawals are simulated in Demo Mode.',
                        style: AppTextStyles.caption.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _EarningsTile(label: 'Completed jobs', value: null, count: earnings.completedJobs),
              ],
            ),
          );
        },
        loading: () => const LoadingView(),
        error: (e, __) => ErrorStateView(title: 'Could not load earnings', message: '$e', onRetry: () => ref.invalidate(helperEarningsProvider)),
      ),
    );
  }
}

class _EarningsTile extends StatelessWidget {
  final String label;
  final int? value;
  final int? count;
  final bool large;
  const _EarningsTile({required this.label, this.value, this.count, this.large = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (value != null) MoneyText(value!, style: large ? AppTextStyles.display : AppTextStyles.h2),
          if (count != null) Text('$count', style: AppTextStyles.h2),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
        ],
      ),
    );
  }
}

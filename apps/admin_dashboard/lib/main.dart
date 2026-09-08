import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

void main() {
  runApp(const ProviderScope(child: MadadgaarAdminApp()));
}

class MadadgaarAdminApp extends StatelessWidget {
  const MadadgaarAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Madadgaar Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: const _Root(),
    );
  }
}

class _Root extends ConsumerWidget {
  const _Root();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    return auth.when(
      data: (session) => session != null ? const DashboardScreen() : const AdminLoginScreen(),
      loading: () => const Scaffold(body: LoadingView()),
      error: (_, __) => const AdminLoginScreen(),
    );
  }
}

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ref.read(madadgaarApiProvider).verifyOtp(phone: '+923000000000', otp: '1234');
      await ref.read(authControllerProvider.notifier).setSession(AuthSession(token: result.token, user: result.user));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.md)),
                      alignment: Alignment.center,
                      child: const Text('M', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Text('Madadgaar Admin', style: AppTextStyles.h1),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                if (_error != null) Padding(padding: const EdgeInsets.only(bottom: AppSpacing.md), child: Text(_error!, style: const TextStyle(color: AppColors.danger))),
                PrimaryButton(label: 'Continue as Admin (Demo)', onPressed: _login, loading: _loading),
                const SizedBox(height: AppSpacing.sm),
                const DemoModeBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final _dashboardProvider = FutureProvider.autoDispose((ref) => ref.watch(madadgaarApiProvider).adminDashboard());
final _analyticsProvider = FutureProvider.autoDispose((ref) => ref.watch(madadgaarApiProvider).adminAnalytics(period: 'today'));
final _activeRequestsProvider = FutureProvider.autoDispose((ref) => ref.watch(madadgaarApiProvider).adminRequests(status: 'active'));
final _helpersProvider = FutureProvider.autoDispose((ref) => ref.watch(madadgaarApiProvider).listHelpers());
final _servicesProvider = FutureProvider.autoDispose((ref) => ref.watch(madadgaarApiProvider).services());

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(_dashboardProvider);
    final analytics = ref.watch(_analyticsProvider);
    final activeRequests = ref.watch(_activeRequestsProvider);
    final helpers = ref.watch(_helpersProvider);
    final services = ref.watch(_servicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Madadgaar Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(_dashboardProvider);
              ref.invalidate(_analyticsProvider);
              ref.invalidate(_activeRequestsProvider);
              ref.invalidate(_helpersProvider);
            },
          ),
          IconButton(icon: const Icon(Icons.logout_rounded), onPressed: () => ref.read(authControllerProvider.notifier).logout()),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DemoModeBanner(),
              const SizedBox(height: AppSpacing.xl),
              Text('Live Overview', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.md),
              dashboard.when(
                data: (d) => _CardGrid(cards: [
                  _StatCardData('Active Requests', '${d.activeRequests}', Icons.bolt_rounded, AppColors.secondary),
                  _StatCardData('Online Helpers', '${d.onlineHelpers}', Icons.person_pin_circle_rounded, AppColors.primary),
                  _StatCardData("Today's Orders", '${d.todaysOrders}', Icons.receipt_long_rounded, AppColors.secondary),
                  _StatCardData("Today's Revenue", formatPkr(d.todaysRevenue), Icons.payments_rounded, AppColors.primary),
                  _StatCardData('Commission', formatPkr(d.todaysCommission), Icons.percent_rounded, AppColors.warning),
                  _StatCardData('Completed (all time)', '${d.completedJobsAllTime}', Icons.check_circle_rounded, AppColors.primary),
                  _StatCardData('Cancellation Rate', '${d.cancellationRatePct}%', Icons.cancel_rounded, AppColors.danger),
                ]),
                loading: () => const LoadingView(),
                error: (e, __) => Text('$e', style: const TextStyle(color: AppColors.danger)),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Row(children: [
                Text('Business Metrics (Today)', style: AppTextStyles.h2),
                const SizedBox(width: AppSpacing.sm),
                const PillTag(label: 'DEMO DATA', color: AppColors.warning),
              ]),
              const SizedBox(height: AppSpacing.md),
              analytics.when(
                data: (a) => _CardGrid(cards: [
                  _StatCardData('Orders', '${a.orders}', Icons.shopping_bag_rounded, AppColors.secondary),
                  _StatCardData('GMV', formatPkr(a.gmv), Icons.trending_up_rounded, AppColors.primary),
                  _StatCardData('Madadgaar Revenue', formatPkr(a.madadgaarRevenue), Icons.account_balance_wallet_rounded, AppColors.primary),
                  _StatCardData('Helper Payouts', formatPkr(a.helperPayouts), Icons.payments_rounded, AppColors.secondary),
                  _StatCardData('Avg Order Value', formatPkr(a.averageOrderValue), Icons.receipt_rounded, AppColors.secondary),
                  _StatCardData('Avg Response Time', '${a.averageResponseTimeMin} min', Icons.timer_rounded, AppColors.secondary),
                  _StatCardData('Completion Rate', '${a.completionRatePct}%', Icons.task_alt_rounded, AppColors.primary),
                  _StatCardData('Take Rate', '${a.takeRatePct}%', Icons.pie_chart_rounded, AppColors.warning),
                ]),
                loading: () => const LoadingView(),
                error: (e, __) => Text('$e', style: const TextStyle(color: AppColors.danger)),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('Active Requests', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.md),
              activeRequests.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const EmptyStateView(icon: Icons.bolt_rounded, title: 'No active requests', message: 'New requests will show up here live.');
                  }
                  final svc = services.value ?? const [];
                  return Column(
                    children: list
                        .map((r) => Container(
                              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                border: Border.all(color: Theme.of(context).dividerColor),
                              ),
                              child: Row(children: [
                                Text(svc.where((s) => s.key == r.serviceKey).map((s) => s.icon).firstOrNull ?? '🛠️', style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(r.serviceKey, style: AppTextStyles.bodyStrong),
                                      Text(r.pickupLocation.address ?? '', style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                MoneyText(r.pricing.breakdown.total, style: AppTextStyles.bodyStrong),
                                const SizedBox(width: AppSpacing.md),
                                StatusBadge(r.status),
                              ]),
                            ))
                        .toList(),
                  );
                },
                loading: () => const LoadingView(),
                error: (e, __) => Text('$e', style: const TextStyle(color: AppColors.danger)),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('Helpers', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.md),
              helpers.when(
                data: (list) => Column(
                  children: list
                      .map((h) => Container(
                            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(color: Theme.of(context).dividerColor),
                            ),
                            child: Row(children: [
                              InitialsAvatar(name: h.name, size: 36),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(h.name, style: AppTextStyles.bodyStrong),
                                    Text('${h.city} · ${h.rating.toStringAsFixed(1)}★ · ${h.completedJobs} jobs', style: AppTextStyles.caption),
                                  ],
                                ),
                              ),
                              PillTag(
                                label: h.verificationStatus.label,
                                color: h.isVerified ? AppColors.primary : (h.verificationStatus == VerificationStatus.pending ? AppColors.warning : AppColors.danger),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: h.isOnline ? AppColors.primary : Colors.grey)),
                            ]),
                          ))
                      .toList(),
                ),
                loading: () => const LoadingView(),
                error: (e, __) => Text('$e', style: const TextStyle(color: AppColors.danger)),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCardData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  _StatCardData(this.label, this.value, this.icon, this.color);
}

class _CardGrid extends StatelessWidget {
  final List<_StatCardData> cards;
  const _CardGrid({required this.cards});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final cols = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 560 ? 3 : 2);
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cards.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, mainAxisSpacing: AppSpacing.md, crossAxisSpacing: AppSpacing.md, childAspectRatio: 1.6),
        itemBuilder: (context, i) {
          final c = cards[i];
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
                Icon(c.icon, color: c.color, size: 20),
                const Spacer(),
                Text(c.value, style: AppTextStyles.h2, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(c.label, style: AppTextStyles.caption.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
              ],
            ),
          );
        },
      );
    });
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

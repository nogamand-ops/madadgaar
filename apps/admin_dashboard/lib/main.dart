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
      theme: AppTheme.light(),
      darkTheme: AppTheme.light(),
      themeMode: ThemeMode.light,
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
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: AppColors.charcoal, borderRadius: BorderRadius.circular(AppRadius.sm)),
                      alignment: Alignment.center,
                      child: const Text('M', style: TextStyle(color: AppColors.amber, fontSize: 22, fontWeight: FontWeight.w800)),
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
final _allRequestsProvider = FutureProvider.autoDispose((ref) => ref.watch(madadgaarApiProvider).adminRequests());
final _helpersProvider = FutureProvider.autoDispose((ref) => ref.watch(madadgaarApiProvider).listHelpers());
final _servicesProvider = FutureProvider.autoDispose((ref) => ref.watch(madadgaarApiProvider).services());

final _navIndexProvider = StateProvider<int>((ref) => 0);

const _navItems = [
  (icon: Icons.space_dashboard_outlined, selectedIcon: Icons.space_dashboard_rounded, label: 'Dashboard'),
  (icon: Icons.receipt_long_outlined, selectedIcon: Icons.receipt_long_rounded, label: 'Requests'),
  (icon: Icons.groups_outlined, selectedIcon: Icons.groups_rounded, label: 'Helpers'),
  (icon: Icons.build_outlined, selectedIcon: Icons.build_rounded, label: 'Services'),
];

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _refreshAll(WidgetRef ref) {
    ref.invalidate(_dashboardProvider);
    ref.invalidate(_analyticsProvider);
    ref.invalidate(_activeRequestsProvider);
    ref.invalidate(_allRequestsProvider);
    ref.invalidate(_helpersProvider);
    ref.invalidate(_servicesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navIndex = ref.watch(_navIndexProvider);
    final compact = MediaQuery.sizeOf(context).width < 900;
    final gutter = compact ? AppSpacing.lg : AppSpacing.xxl;

    Widget sidebar({required bool inDrawer}) => _Sidebar(
          selectedIndex: navIndex,
          width: inDrawer ? double.infinity : 232,
          onSelect: (i) {
            ref.read(_navIndexProvider.notifier).state = i;
            if (inDrawer) Navigator.of(context).pop();
          },
          onLogout: () => ref.read(authControllerProvider.notifier).logout(),
        );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DemoModeBanner(),
        Padding(
          padding: EdgeInsets.fromLTRB(compact ? AppSpacing.sm : gutter, AppSpacing.xl, gutter, 0),
          child: Row(
            children: [
              if (compact)
                Builder(
                  builder: (context) => IconButton(
                    tooltip: 'Menu',
                    icon: const Icon(Icons.menu_rounded),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              Expanded(
                child: Text(
                  _navItems[navIndex].label,
                  style: compact ? AppTextStyles.h1 : AppTextStyles.display,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => _refreshAll(ref),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(gutter),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: switch (navIndex) {
                0 => const _OverviewTab(),
                1 => const _RequestsTab(),
                2 => const _HelpersTab(),
                _ => const _ServicesTab(),
              },
            ),
          ),
        ),
      ],
    );

    if (compact) {
      return Scaffold(
        drawer: Drawer(
          width: 260,
          backgroundColor: AppColors.charcoalDeep,
          shape: const RoundedRectangleBorder(),
          child: SafeArea(child: sidebar(inDrawer: true)),
        ),
        body: SafeArea(child: content),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          sidebar(inDrawer: false),
          Expanded(child: content),
        ],
      ),
    );
  }
}

/// Fixed charcoal sidebar — the deliberate "dark surface" element that
/// structures the admin tool, distinct from the light content area.
class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final double width;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;

  const _Sidebar({required this.selectedIndex, required this.width, required this.onSelect, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: AppColors.charcoalDeep,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: AppColors.amber, borderRadius: BorderRadius.circular(AppRadius.sm)),
                  alignment: Alignment.center,
                  child: const Text('M', style: TextStyle(color: AppColors.charcoalDeep, fontWeight: FontWeight.w800, fontSize: 16)),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text('Madadgaar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          for (var i = 0; i < _navItems.length; i++) ...[
            _SidebarItem(
              icon: selectedIndex == i ? _navItems[i].selectedIcon : _navItems[i].icon,
              label: _navItems[i].label,
              selected: selectedIndex == i,
              onTap: () => onSelect(i),
            ),
            const SizedBox(height: 2),
          ],
          const Spacer(),
          const Divider(color: Color(0xFF3F3F46), height: 1),
          const SizedBox(height: AppSpacing.sm),
          _SidebarItem(icon: Icons.logout_rounded, label: 'Log out', selected: false, onTap: onLogout),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          child: Row(
            children: [
              Icon(icon, size: 20, color: selected ? AppColors.amber : const Color(0xFFA1A1AA)),
              const SizedBox(width: AppSpacing.md),
              Text(label, style: TextStyle(color: selected ? Colors.white : const Color(0xFFA1A1AA), fontWeight: selected ? FontWeight.w600 : FontWeight.w500, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(_dashboardProvider);
    final analytics = ref.watch(_analyticsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Live overview', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.md),
        dashboard.when(
          data: (d) => _CardGrid(cards: [
            _StatCardData('Active Requests', '${d.activeRequests}', Icons.bolt_rounded, AppColors.secondary),
            _StatCardData('Online Helpers', '${d.onlineHelpers}', Icons.person_pin_circle_rounded, AppColors.success),
            _StatCardData("Today's Orders", '${d.todaysOrders}', Icons.receipt_long_rounded, AppColors.secondary),
            _StatCardData("Today's Revenue", formatPkr(d.todaysRevenue), Icons.payments_rounded, AppColors.success),
            _StatCardData('Commission', formatPkr(d.todaysCommission), Icons.percent_rounded, AppColors.amberText),
            _StatCardData('Completed (all time)', '${d.completedJobsAllTime}', Icons.check_circle_rounded, AppColors.success),
            _StatCardData('Cancellation Rate', '${d.cancellationRatePct}%', Icons.cancel_rounded, AppColors.danger),
          ]),
          loading: () => const Padding(padding: EdgeInsets.all(AppSpacing.xl), child: LoadingView()),
          error: (e, __) => Text('$e', style: const TextStyle(color: AppColors.danger)),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Business metrics (today)', style: AppTextStyles.h2),
            const PillTag(label: 'DEMO DATA', color: AppColors.amberText),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        analytics.when(
          data: (a) => _CardGrid(cards: [
            _StatCardData('Orders', '${a.orders}', Icons.shopping_bag_rounded, AppColors.secondary),
            _StatCardData('GMV', formatPkr(a.gmv), Icons.trending_up_rounded, AppColors.success),
            _StatCardData('Madadgaar Revenue', formatPkr(a.madadgaarRevenue), Icons.account_balance_wallet_rounded, AppColors.success),
            _StatCardData('Helper Payouts', formatPkr(a.helperPayouts), Icons.payments_rounded, AppColors.secondary),
            _StatCardData('Avg Order Value', formatPkr(a.averageOrderValue), Icons.receipt_rounded, AppColors.secondary),
            _StatCardData('Avg Response Time', '${a.averageResponseTimeMin} min', Icons.timer_rounded, AppColors.secondary),
            _StatCardData('Completion Rate', '${a.completionRatePct}%', Icons.task_alt_rounded, AppColors.success),
            _StatCardData('Take Rate', '${a.takeRatePct}%', Icons.pie_chart_rounded, AppColors.amberText),
          ]),
          loading: () => const Padding(padding: EdgeInsets.all(AppSpacing.xl), child: LoadingView()),
          error: (e, __) => Text('$e', style: const TextStyle(color: AppColors.danger)),
        ),
      ],
    );
  }
}

class _RequestsTab extends ConsumerWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(_allRequestsProvider);
    return requests.when(
      data: (list) {
        if (list.isEmpty) {
          return const EmptyStateView(icon: Icons.receipt_long_rounded, title: 'No requests yet', message: 'Requests will show up here as customers create them.');
        }
        return _Table(
          columns: const ['Request', 'Service', 'Location', 'Status', 'Price', 'Created'],
          flexes: const [2, 2, 3, 2, 2, 2],
          rows: list
              .map((r) => [
                    Text('#${r.id.substring(r.id.length - 6)}', style: AppTextStyles.bodyStrong),
                    Row(children: [ServiceIconBadge(serviceKey: r.serviceKey, size: 26), const SizedBox(width: AppSpacing.sm), Flexible(child: Text(r.serviceKey, overflow: TextOverflow.ellipsis))]),
                    Text(r.pickupLocation.address ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis),
                    StatusBadge(r.status),
                    MoneyText(r.pricing.breakdown.total, style: AppTextStyles.bodyStrong),
                    Text(relativeTime(r.createdAt), style: AppTextStyles.caption.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                  ])
              .toList(),
        );
      },
      loading: () => const Padding(padding: EdgeInsets.all(AppSpacing.xl), child: LoadingView()),
      error: (e, __) => Text('$e', style: const TextStyle(color: AppColors.danger)),
    );
  }
}

class _HelpersTab extends ConsumerWidget {
  const _HelpersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final helpers = ref.watch(_helpersProvider);
    return helpers.when(
      data: (list) {
        if (list.isEmpty) {
          return const EmptyStateView(icon: Icons.groups_rounded, title: 'No helpers yet', message: 'Registered helpers will show up here.');
        }
        return _Table(
          columns: const ['Helper', 'City', 'Rating', 'Jobs', 'Verification', 'Online'],
          flexes: const [3, 2, 2, 2, 2, 1],
          rows: list
              .map((h) => [
                    Row(children: [
                      InitialsAvatar(name: h.name, size: 28),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(child: Text(h.name, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodyStrong)),
                    ]),
                    Text(h.city),
                    Text(h.completedJobs > 0 ? '★ ${h.rating.toStringAsFixed(1)}' : '—'),
                    Text('${h.completedJobs}'),
                    PillTag(
                      label: h.verificationStatus.label,
                      color: h.isVerified
                          ? AppColors.success
                          : (h.verificationStatus == VerificationStatus.pending ? AppColors.amberText : AppColors.danger),
                    ),
                    Container(width: 9, height: 9, decoration: BoxDecoration(shape: BoxShape.circle, color: h.isOnline ? AppColors.success : const Color(0xFFD4D4D8))),
                  ])
              .toList(),
        );
      },
      loading: () => const Padding(padding: EdgeInsets.all(AppSpacing.xl), child: LoadingView()),
      error: (e, __) => Text('$e', style: const TextStyle(color: AppColors.danger)),
    );
  }
}

/// Lets admin edit the quick-pick "what's wrong?" options customers see
/// per service (service_details_screen.dart in the customer app fetches
/// these live) — no app release needed to tune them.
class _ServicesTab extends ConsumerWidget {
  const _ServicesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(_servicesProvider);
    return servicesAsync.when(
      data: (list) {
        final editable = list.where((s) => s.key != 'fuel' && s.key != 'other').toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Service problem options', style: AppTextStyles.h2),
            const SizedBox(height: 4),
            Text(
              'These are the quick-pick options customers see on the "What\'s wrong?" screen for each service. '
              'Fuel (its own type/quantity step) and "Other" aren\'t editable here.',
              style: AppTextStyles.description.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
            ),
            const SizedBox(height: AppSpacing.xl),
            for (final service in editable)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: _ServiceEditorCard(service: service),
              ),
          ],
        );
      },
      loading: () => const Padding(padding: EdgeInsets.all(AppSpacing.xl), child: LoadingView()),
      error: (e, __) => Text('$e', style: const TextStyle(color: AppColors.danger)),
    );
  }
}

class _ServiceEditorCard extends ConsumerStatefulWidget {
  final MadadgaarService service;
  const _ServiceEditorCard({required this.service});

  @override
  ConsumerState<_ServiceEditorCard> createState() => _ServiceEditorCardState();
}

class _ServiceEditorCardState extends ConsumerState<_ServiceEditorCard> {
  late List<String> _options = List.of(widget.service.problemOptions);
  final _newOptionController = TextEditingController();
  bool _saving = false;

  Future<void> _save(List<String> next) async {
    final previous = _options;
    setState(() {
      _options = next;
      _saving = true;
    });
    try {
      await ref.read(madadgaarApiProvider).updateService(widget.service.key, problemOptions: next);
    } catch (e) {
      if (mounted) {
        setState(() => _options = previous);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addOption() {
    final text = _newOptionController.text.trim();
    if (text.isEmpty || _options.contains(text)) return;
    _newOptionController.clear();
    _save([..._options, text]);
  }

  void _removeOption(String option) => _save(_options.where((o) => o != option).toList());

  @override
  void dispose() {
    _newOptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: surfaceDecoration(context),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ServiceIconBadge(serviceKey: widget.service.key, size: 36),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(widget.service.name, style: AppTextStyles.h3)),
              if (_saving) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _options.isEmpty
              ? Text('No quick-pick options yet — add one below.',
                  style: AppTextStyles.caption.copyWith(color: Theme.of(context).textTheme.bodySmall?.color))
              : Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _options.map((o) => Chip(label: Text(o), onDeleted: () => _removeOption(o))).toList(),
                ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newOptionController,
                  decoration: const InputDecoration(hintText: 'Add an option…', isDense: true),
                  onSubmitted: (_) => _addOption(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filled(onPressed: _addOption, icon: const Icon(Icons.add_rounded)),
            ],
          ),
        ],
      ),
    );
  }
}

/// A simple, responsive "table" — a header row plus aligned data rows. Not
/// a DataTable (which doesn't reflow well); columns are just flexed Rows,
/// which handles narrow admin windows more gracefully.
class _Table extends StatelessWidget {
  final List<String> columns;
  final List<int> flexes;
  final List<List<Widget>> rows;

  const _Table({required this.columns, required this.flexes, required this.rows});

  static const _minWidth = 720.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final table = _buildTable(context);
      if (constraints.maxWidth >= _minWidth) return table;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: _minWidth, child: table),
      );
    });
  }

  Widget _buildTable(BuildContext context) {
    return Container(
      decoration: surfaceDecoration(context),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.lightCardAlt,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
            ),
            child: Row(
              children: [
                for (var i = 0; i < columns.length; i++)
                  Expanded(flex: flexes[i], child: Text(columns[i], style: AppTextStyles.label.copyWith(color: AppColors.lightTextSecondary))),
              ],
            ),
          ),
          for (var r = 0; r < rows.length; r++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.lightBorder, width: r == 0 ? 0 : 1))),
              child: Row(
                children: [
                  for (var i = 0; i < rows[r].length; i++)
                    Expanded(flex: flexes[i], child: Align(alignment: Alignment.centerLeft, child: rows[r][i])),
                ],
              ),
            ),
        ],
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
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: cols == 2 ? 1.45 : 1.7,
        ),
        itemBuilder: (context, i) {
          final c = cards[i];
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: surfaceDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(c.icon, color: c.color, size: 20),
                const Spacer(),
                Text(c.value, style: AppTextStyles.h2, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  c.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

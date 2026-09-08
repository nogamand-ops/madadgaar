import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            children: [
              InitialsAvatar(name: user?.name ?? '?', size: 56),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? '', style: AppTextStyles.h2),
                    Text(user?.phone ?? '', style: AppTextStyles.body.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          _EarnCard(onTap: () => _showEarnInfo(context)),
          const SizedBox(height: AppSpacing.xl),
          _SectionCard(children: [
            _ProfileTile(icon: Icons.payments_outlined, label: 'Payment methods', onTap: () => _showPaymentMethods(context)),
            _ProfileTile(
              icon: Icons.language_rounded,
              label: 'Language',
              trailing: Text(locale == AppLocale.en ? 'English' : 'اردو', style: AppTextStyles.caption),
              onTap: () => ref.read(localeProvider.notifier).state = locale == AppLocale.en ? AppLocale.ur : AppLocale.en,
            ),
            _ProfileTile(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () {}),
          ]),
          const SizedBox(height: AppSpacing.lg),
          _SectionCard(children: [
            _ProfileTile(icon: Icons.help_outline_rounded, label: 'Help & Support', onTap: () => context.push('/support')),
            _ProfileTile(icon: Icons.description_outlined, label: 'Terms of Service', onTap: () => context.push('/legal/terms')),
            _ProfileTile(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', onTap: () => context.push('/legal/privacy')),
            _ProfileTile(icon: Icons.local_gas_station_outlined, label: 'Fuel Delivery Policy', onTap: () => context.push('/legal/fuel')),
            _ProfileTile(icon: Icons.shield_outlined, label: 'Safety Guidelines', onTap: () => context.push('/legal/safety')),
          ]),
          const SizedBox(height: AppSpacing.lg),
          _SectionCard(children: [
            _ProfileTile(
              icon: Icons.logout_rounded,
              label: 'Log out',
              danger: true,
              onTap: () => ref.read(authControllerProvider.notifier).logout(),
            ),
          ]),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text('Madadgaar hai na.', style: AppTextStyles.caption.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  void _showEarnInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Earn with Madadgaar'),
        content: const Text(
          'Have a bike or car and some free time? Become a verified Madadgaar and earn '
          'by helping stranded drivers nearby.\n\nDownload the Madadgaar Helper app to apply '
          '— registration takes a few minutes and your application is reviewed before you go live.',
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Got it'))],
      ),
    );
  }

  void _showPaymentMethods(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment methods', style: AppTextStyles.h2),
            SizedBox(height: AppSpacing.md),
            ListTile(leading: Icon(Icons.payments_rounded), title: Text('Cash on Delivery'), contentPadding: EdgeInsets.zero),
            ListTile(leading: Icon(Icons.account_balance_wallet_rounded), title: Text('Easypaisa'), contentPadding: EdgeInsets.zero),
            ListTile(leading: Icon(Icons.account_balance_wallet_rounded), title: Text('JazzCash'), contentPadding: EdgeInsets.zero),
            SizedBox(height: AppSpacing.sm),
            DemoModeBanner(),
          ],
        ),
      ),
    );
  }
}

class _EarnCard extends StatelessWidget {
  final VoidCallback onTap;
  const _EarnCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.secondary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Text('💼', style: TextStyle(fontSize: 28)),
              const SizedBox(width: AppSpacing.lg),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Earn with Madadgaar', style: AppTextStyles.h3),
                    Text('Become a verified helper and start earning', style: AppTextStyles.caption),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final bool danger;
  final VoidCallback onTap;

  const _ProfileTile({required this.icon, required this.label, required this.onTap, this.trailing, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : null;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: AppTextStyles.body.copyWith(color: color)),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, size: 18),
      onTap: onTap,
    );
  }
}

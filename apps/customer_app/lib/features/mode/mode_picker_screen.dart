import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

/// The front door: one app, two ways in. Whoever is already a registered
/// user on a phone number lands back in their real role regardless of which
/// card they tap here — this screen only decides what a *new* sign-up
/// becomes.
class ModePickerScreen extends StatelessWidget {
  const ModePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: AppColors.charcoal, borderRadius: BorderRadius.circular(AppRadius.sm)),
                    alignment: Alignment.center,
                    child: const Text('M', style: TextStyle(color: AppColors.amber, fontSize: 24, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Expanded(child: Text('Madadgaar', style: AppTextStyles.h1)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Help, when you need it.',
                style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
              ),
              const Spacer(flex: 2),
              Text('How would you like to continue?', style: AppTextStyles.h2, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xxl),
              _ModeCard(
                icon: Icons.build_rounded,
                title: 'I need help',
                subtitle: 'Request roadside assistance nearby',
                onTap: () => context.push('/login', extra: {'role': 'customer'}),
              ),
              const SizedBox(height: AppSpacing.md),
              _ModeCard(
                icon: Icons.work_outline_rounded,
                title: 'I want to help & earn',
                subtitle: 'Become a verified Madadgaar',
                onTap: () => context.push('/login', extra: {'role': 'helper'}),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModeCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: surfaceDecoration(context, radius: AppRadius.lg),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.sm), color: AppColors.lightCardAlt),
                alignment: Alignment.center,
                child: Icon(icon, color: AppColors.charcoal, size: 22),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h3),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.caption.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Theme.of(context).textTheme.bodySmall?.color),
            ],
          ),
        ),
      ),
    );
  }
}

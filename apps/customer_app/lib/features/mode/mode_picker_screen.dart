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
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.md)),
                    alignment: Alignment.center,
                    child: const Text('M', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  const Expanded(child: Text('Madadgaar', style: AppTextStyles.display)),
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
                emoji: '🚨',
                title: 'I need help',
                subtitle: 'Request roadside assistance nearby',
                color: AppColors.primary,
                onTap: () => context.push('/login', extra: {'role': 'customer'}),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ModeCard(
                emoji: '💼',
                title: 'I want to help & earn',
                subtitle: 'Become a verified Madadgaar',
                color: AppColors.secondary,
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
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({required this.emoji, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            color: Theme.of(context).colorScheme.surface,
            boxShadow: Theme.of(context).brightness == Brightness.light
                ? [const BoxShadow(color: AppColors.lightShadow, blurRadius: 20, offset: Offset(0, 8))]
                : null,
            border: Theme.of(context).brightness == Brightness.dark ? Border.all(color: Theme.of(context).dividerColor) : null,
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  gradient: LinearGradient(colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0.1)]),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
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

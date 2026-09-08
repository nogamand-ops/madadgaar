import 'package:flutter/material.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _Tile(icon: Icons.menu_book_rounded, title: 'Help Center', subtitle: 'Browse frequently asked questions', onTap: () {}),
          _Tile(icon: Icons.chat_bubble_outline_rounded, title: 'Contact Support', subtitle: 'support@madadgaar.pk · 0800-00000 (demo)', onTap: () {}),
          _Tile(icon: Icons.report_problem_outlined, title: 'Report a Problem', subtitle: 'Tell us what went wrong with a past request', onTap: () {}),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.sos_rounded, color: AppColors.danger),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'For a life-threatening emergency, contact Police (15), Rescue 1122, or Edhi (115) directly — not Madadgaar.',
                    style: AppTextStyles.body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _Tile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.bodyStrong),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        onTap: onTap,
      ),
    );
  }
}

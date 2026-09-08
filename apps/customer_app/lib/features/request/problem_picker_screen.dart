import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

import 'request_flow_nav.dart';

const _problems = [
  (key: 'fuel', emoji: '⛽', label: "I'm out of fuel"),
  (key: 'battery', emoji: '🔋', label: 'My battery is dead'),
  (key: 'tire', emoji: '🛞', label: 'I have a flat tire'),
  (key: 'mechanic', emoji: '🔧', label: 'I need a mechanic'),
  (key: 'towing', emoji: '🚚', label: 'I need towing'),
  (key: 'other', emoji: '❓', label: 'Other problem'),
];

class ProblemPickerScreen extends ConsumerWidget {
  const ProblemPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("What's wrong?")),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: _problems.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, i) {
          final p = _problems[i];
          return _ProblemTile(
            emoji: p.emoji,
            label: p.label,
            onTap: () => enterServiceFlow(context, ref, p.key),
          );
        },
      ),
    );
  }
}

class _ProblemTile extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  const _ProblemTile({required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: Text(label, style: AppTextStyles.h3)),
              Icon(Icons.chevron_right_rounded, color: Theme.of(context).textTheme.bodySmall?.color),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

import 'request_flow_nav.dart';

const _problems = [
  (key: 'fuel', label: "I'm out of fuel"),
  (key: 'battery', label: 'My battery is dead'),
  (key: 'tire', label: 'I have a flat tire'),
  (key: 'mechanic', label: 'I need a mechanic'),
  (key: 'towing', label: 'I need towing'),
  (key: 'other', label: 'Other problem'),
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
            serviceKey: p.key,
            label: p.label,
            onTap: () => enterServiceFlow(context, ref, p.key),
          );
        },
      ),
    );
  }
}

class _ProblemTile extends StatelessWidget {
  final String serviceKey;
  final String label;
  final VoidCallback onTap;
  const _ProblemTile({required this.serviceKey, required this.label, required this.onTap});

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
          decoration: surfaceDecoration(context),
          child: Row(
            children: [
              ServiceIconBadge(serviceKey: serviceKey, size: 46),
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

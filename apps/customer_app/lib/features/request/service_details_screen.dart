import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

import '../home/home_providers.dart';
import 'location_confirm_screen.dart';
import 'request_flow_controller.dart';

/// Quick-pick common issues per service, so most customers don't have to
/// type anything — tap one (or write your own) and continue. This is the
/// step that was missing for every service except fuel: before, tapping
/// "Minor Mechanical Assistance" went straight to price with no chance to
/// say what's actually wrong.
const _quickOptions = {
  'battery': ["Car won't start", 'Battery completely dead', 'Need a jump start only'],
  'tire': ['Flat tire', 'Tire burst', 'Need spare fitted', 'Slow puncture'],
  'mechanic': ["Engine won't start", 'Strange noise', 'Warning light on', 'Overheating'],
  'towing': ['Accident', 'Breakdown, will not start', 'Stuck (mud/ditch)', 'Needs a flatbed'],
  'other': <String>[],
};

class ServiceDetailsScreen extends ConsumerStatefulWidget {
  final String serviceKey;
  const ServiceDetailsScreen({super.key, required this.serviceKey});

  @override
  ConsumerState<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends ConsumerState<ServiceDetailsScreen> {
  final _controller = TextEditingController();
  String? _selectedQuickOption;

  void _pickQuick(String option) {
    setState(() {
      _selectedQuickOption = option;
      _controller.text = option;
    });
  }

  @override
  Widget build(BuildContext context) {
    final options = _quickOptions[widget.serviceKey] ?? const [];
    final services = ref.watch(servicesProvider).value ?? const [];
    final serviceName = services.where((s) => s.key == widget.serviceKey).map((s) => s.name).firstOrNull ?? 'Request';

    return Scaffold(
      appBar: AppBar(title: Text(serviceName)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("What's wrong?", style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tell your Madadgaar a bit more so they arrive prepared.',
              style: AppTextStyles.description.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (options.isNotEmpty) ...[
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: options
                    .map((o) => ChoiceChip(
                          label: Text(o),
                          selected: _selectedQuickOption == o,
                          onSelected: (_) => _pickQuick(o),
                        ))
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            TextField(
              controller: _controller,
              maxLines: 3,
              onChanged: (_) => setState(() => _selectedQuickOption = null),
              decoration: const InputDecoration(hintText: 'Describe the problem (optional)'),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Continue',
              onPressed: () {
                ref.read(requestFlowProvider.notifier).setDetails({'description': _controller.text.trim()});
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LocationConfirmScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

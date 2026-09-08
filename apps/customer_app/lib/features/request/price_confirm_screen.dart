import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

import 'request_flow_controller.dart';
import 'searching_screen.dart';

class PriceConfirmScreen extends ConsumerStatefulWidget {
  const PriceConfirmScreen({super.key});

  @override
  ConsumerState<PriceConfirmScreen> createState() => _PriceConfirmScreenState();
}

class _PriceConfirmScreenState extends ConsumerState<PriceConfirmScreen> {
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(requestFlowProvider.notifier).fetchEstimate());
  }

  Future<void> _confirm() async {
    setState(() => _submitting = true);
    try {
      final request = await ref.read(requestFlowProvider.notifier).submit();
      ref.read(requestFlowProvider.notifier).reset();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => SearchingScreen(requestId: request.id)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not send your request: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(requestFlowProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm & request')),
      body: draft.estimating
          ? const LoadingView(label: 'Calculating your price…')
          : draft.estimateError != null
              ? ErrorStateView(
                  title: 'Could not get a price',
                  message: draft.estimateError!,
                  onRetry: () => ref.read(requestFlowProvider.notifier).fetchEstimate(),
                )
              : draft.estimate == null
                  ? const SizedBox.shrink()
                  : SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                border: Border.all(color: Theme.of(context).dividerColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_rounded, size: 18, color: AppColors.primary),
                                      const SizedBox(width: AppSpacing.xs),
                                      Expanded(
                                        child: Text(draft.address ?? 'Selected location',
                                            style: AppTextStyles.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                                      ),
                                    ],
                                  ),
                                  if (draft.estimate!.isNight) ...[
                                    const SizedBox(height: AppSpacing.sm),
                                    const PillTag(label: '🌙 Night surcharge applies', color: AppColors.warning),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                border: Border.all(color: Theme.of(context).dividerColor),
                              ),
                              child: PriceBreakdownView(breakdown: draft.estimate!.breakdown),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Prices are estimates set by Madadgaar and may vary slightly with distance.',
                              style: AppTextStyles.caption.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
                            ),
                            const Spacer(),
                            PrimaryButton(label: 'Request Help', icon: Icons.check_circle_rounded, onPressed: _confirm, loading: _submitting),
                          ],
                        ),
                      ),
                    ),
    );
  }
}

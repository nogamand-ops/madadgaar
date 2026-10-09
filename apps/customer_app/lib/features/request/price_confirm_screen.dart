import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

import '../home/active_request_controller.dart';
import 'request_flow_controller.dart';
import 'searching_screen.dart';
import 'tracking_screen.dart';

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
    } on ApiException catch (e) {
      if (!mounted) return;
      // 409 means the customer already has an active request (e.g. a double tap, or they
      // backgrounded the app mid-flow and came back) — send them to it instead of showing a
      // raw server error with no way forward.
      if (e.statusCode == 409) {
        await _goToExistingActiveRequest();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not send your request: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _goToExistingActiveRequest() async {
    await ref.read(myActiveRequestProvider.notifier).refresh();
    final existing = ref.read(myActiveRequestProvider).value;
    if (!mounted) return;
    if (existing == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You already have a request in progress.')));
      return;
    }
    ref.read(requestFlowProvider.notifier).reset();
    final isSearching = existing.status == RequestStatus.searching || existing.status == RequestStatus.requested;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => isSearching ? SearchingScreen(requestId: existing.id) : TrackingScreen(requestId: existing.id),
      ),
      (route) => route.isFirst,
    );
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
                              decoration: surfaceDecoration(context),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_rounded, size: 18, color: AppColors.charcoal),
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
                              decoration: surfaceDecoration(context),
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

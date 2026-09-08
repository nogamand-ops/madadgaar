import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

const _reasons = [
  'Found another solution',
  'Wrong location',
  'Too expensive',
  'Helper taking too long',
  'Emergency resolved',
  'Other',
];

/// Cancellation flow (spec section 20): the reason is always captured, and
/// if a fee could apply the sheet says so explicitly before the user
/// confirms — no fee is ever charged silently.
Future<bool> showCancelSheet(
  BuildContext context,
  WidgetRef ref, {
  required String requestId,
  required bool feeMayApply,
  required int cancellationFeeFlat,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => _CancelSheet(requestId: requestId, feeMayApply: feeMayApply, cancellationFeeFlat: cancellationFeeFlat),
  );
  return result ?? false;
}

class _CancelSheet extends ConsumerStatefulWidget {
  final String requestId;
  final bool feeMayApply;
  final int cancellationFeeFlat;
  const _CancelSheet({required this.requestId, required this.feeMayApply, required this.cancellationFeeFlat});

  @override
  ConsumerState<_CancelSheet> createState() => _CancelSheetState();
}

class _CancelSheetState extends ConsumerState<_CancelSheet> {
  String _reason = _reasons.first;
  bool _submitting = false;

  Future<void> _confirm() async {
    setState(() => _submitting = true);
    try {
      await ref.read(madadgaarApiProvider).cancelRequest(widget.requestId, cancelledBy: 'customer', reason: _reason);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not cancel: $e')));
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Cancel this request?', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.md),
            ..._reasons.map((r) => RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: r,
                  groupValue: _reason,
                  onChanged: (v) => setState(() => _reason = v!),
                  title: Text(r, style: AppTextStyles.body),
                  activeColor: AppColors.primary,
                )),
            if (widget.feeMayApply) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  'Your Madadgaar is already on the way — a cancellation fee of ${formatPkr(widget.cancellationFeeFlat)} may apply.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting ? null : () => Navigator.of(context).pop(false),
                    child: const Text('Keep request'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: PrimaryButton(label: 'Cancel request', color: AppColors.danger, onPressed: _confirm, loading: _submitting),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

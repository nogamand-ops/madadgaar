import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

class RatingScreen extends ConsumerStatefulWidget {
  final String requestId;
  const RatingScreen({super.key, required this.requestId});

  @override
  ConsumerState<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends ConsumerState<RatingScreen> {
  int _stars = 5;
  final _reviewController = TextEditingController();
  bool _submitting = false;

  Future<void> _submit(ServiceRequest request) async {
    setState(() => _submitting = true);
    try {
      await ref.read(madadgaarApiProvider).submitRating(
            widget.requestId,
            toUserId: request.helperId!,
            stars: _stars,
            review: _reviewController.text.trim(),
          );
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not submit rating: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final live = ref.watch(requestLiveProvider(widget.requestId));
    final request = live.request;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: request == null
              ? const LoadingView()
              : Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    children: [
                      const Spacer(),
                      const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 64),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Request completed', style: AppTextStyles.h1, textAlign: TextAlign.center),
                      const SizedBox(height: AppSpacing.sm),
                      Text('Rate your Madadgaar', style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                      const SizedBox(height: AppSpacing.xxl),
                      RatingStarsInput(value: _stars, onChanged: (v) => setState(() => _stars = v)),
                      const SizedBox(height: AppSpacing.xl),
                      TextField(
                        controller: _reviewController,
                        maxLines: 3,
                        decoration: const InputDecoration(hintText: 'Leave a review (optional)'),
                      ),
                      const Spacer(),
                      PrimaryButton(label: 'Submit', onPressed: () => _submit(request), loading: _submitting),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(onPressed: () => context.go('/home'), child: const Text('Skip')),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

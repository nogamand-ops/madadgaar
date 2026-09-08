import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

import 'tracking_screen.dart';

const _searchingStages = [
  'Finding a Madadgaar nearby…',
  'Checking nearby helpers…',
  'Matching you with the best Madadgaar…',
];

class SearchingScreen extends ConsumerStatefulWidget {
  final String requestId;
  const SearchingScreen({super.key, required this.requestId});

  @override
  ConsumerState<SearchingScreen> createState() => _SearchingScreenState();
}

class _SearchingScreenState extends ConsumerState<SearchingScreen> {
  int _stage = 0;
  Timer? _stageTimer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _stageTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted && _stage < _searchingStages.length - 1) setState(() => _stage++);
    });
  }

  @override
  void dispose() {
    _stageTimer?.cancel();
    super.dispose();
  }

  Future<void> _cancel() async {
    try {
      await ref.read(madadgaarApiProvider).cancelRequest(widget.requestId, cancelledBy: 'customer', reason: 'Emergency resolved');
    } catch (_) {}
    if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  Future<void> _retry() async {
    try {
      await ref.read(madadgaarApiProvider).retrySearch(widget.requestId);
      setState(() => _stage = 0);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final live = ref.watch(requestLiveProvider(widget.requestId));

    ref.listen(requestLiveProvider(widget.requestId), (previous, next) {
      final status = next.request?.status;
      if (!_navigated && status != null && status != RequestStatus.searching && status != RequestStatus.requested && status.isActive) {
        _navigated = true;
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => TrackingScreen(requestId: widget.requestId)));
      }
    });

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: live.noHelpersAvailable
                ? ErrorStateView(
                    title: 'No Madadgaars available nearby right now',
                    message: 'Try again in a moment, or contact support if this keeps happening.',
                    onRetry: _retry,
                    onContactSupport: () => Navigator.of(context).pop(),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _PulsingRadar(),
                      const SizedBox(height: AppSpacing.xxxl),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _searchingStages[_stage],
                          key: ValueKey(_stage),
                          style: AppTextStyles.h2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      if (live.candidate != null) ...[
                        const Text('Best match found', style: AppTextStyles.bodyStrong, textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.md),
                        HelperPreviewCard(
                          name: live.candidate!.name,
                          rating: live.candidate!.rating,
                          completedJobs: live.candidate!.completedJobs,
                          vehicleLabel: [live.candidate!.vehicleMake, live.candidate!.vehicleModel].where((e) => e != null).join(' '),
                          verified: live.candidate!.verified,
                          distanceKm: live.candidate!.distanceKm,
                          etaMinutes: live.candidate!.etaMinutes,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Waiting for ${live.candidate!.name.split(' ').first} to accept…',
                          style: AppTextStyles.caption.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xxxl),
                      TextButton(onPressed: _cancel, child: const Text('Cancel request')),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _PulsingRadar extends StatefulWidget {
  const _PulsingRadar();

  @override
  State<_PulsingRadar> createState() => _PulsingRadarState();
}

class _PulsingRadarState extends State<_PulsingRadar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              for (final delay in [0.0, 0.33, 0.66])
                _ring((_controller.value + delay) % 1.0),
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 30),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _ring(double t) {
    return Opacity(
      opacity: (1 - t).clamp(0, 1),
      child: Container(
        width: 64 + t * 76,
        height: 64 + t * 76,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 2)),
      ),
    );
  }
}

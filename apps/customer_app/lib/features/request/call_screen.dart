import 'dart:async';
import 'package:flutter/material.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

/// Simulated call UI (spec section 18): production would route through a
/// masked/secure calling provider — for the demo this is an honest,
/// clearly-labelled UI-only abstraction, never a real phone call.
class CallScreen extends StatefulWidget {
  final String helperName;
  const CallScreen({super.key, required this.helperName});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _seconds++));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _clock => '${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: [
              const Spacer(),
              InitialsAvatar(name: widget.helperName, size: 96),
              const SizedBox(height: AppSpacing.xl),
              Text(widget.helperName, style: AppTextStyles.h1.copyWith(color: Colors.white)),
              const SizedBox(height: AppSpacing.sm),
              Text('Simulated call · $_clock', style: AppTextStyles.body.copyWith(color: AppColors.darkTextSecondary)),
              const SizedBox(height: AppSpacing.sm),
              const PillTag(label: 'DEMO MODE — no real call is placed', color: AppColors.secondary),
              const Spacer(),
              FloatingActionButton.large(
                heroTag: 'end-call',
                backgroundColor: AppColors.danger,
                onPressed: () => Navigator.of(context).pop(),
                child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

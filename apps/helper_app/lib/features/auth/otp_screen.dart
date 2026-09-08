import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController(text: '1234');
  final _nameController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _verify() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(madadgaarApiProvider);
      final result = await api.verifyOtp(
        phone: widget.phone,
        otp: _otpController.text.trim(),
        role: 'helper',
        name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      );
      await ref.read(authControllerProvider.notifier).setSession(AuthSession(token: result.token, user: result.user));

      bool hasProfile = true;
      try {
        await api.getHelper(result.user.id);
      } catch (_) {
        hasProfile = false;
      }
      if (!mounted) return;
      context.go(hasProfile ? '/home' : '/register');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.xl),
            Text('Verify your number', style: AppTextStyles.h1),
            const SizedBox(height: AppSpacing.sm),
            Text('Enter the code we sent to ${widget.phone}', style: AppTextStyles.body.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
            const SizedBox(height: AppSpacing.xxl),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: AppTextStyles.display,
              maxLength: 4,
              decoration: InputDecoration(counterText: '', errorText: _error, hintText: '••••'),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('First time as a Madadgaar helper? What should we call you?', style: AppTextStyles.bodyStrong),
            const SizedBox(height: AppSpacing.sm),
            TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'Full name')),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(label: 'Verify & Continue', onPressed: _verify, loading: _loading),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _controller = TextEditingController(text: '3331234567');
  bool _loading = false;
  String? _error;

  Future<void> _continue() async {
    final phone = normalizePkPhone(_controller.text);
    if (!pkPhoneRegExp.hasMatch(phone)) {
      setState(() => _error = 'Enter a valid Pakistani mobile number.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final otp = await ref.read(madadgaarApiProvider).requestOtp(phone);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Demo Mode: your verification code is $otp')));
      context.push('/otp', extra: {'phone': phone});
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 3),
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.md)),
                    alignment: Alignment.center,
                    child: const Text('M', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  const Expanded(child: Text('Madadgaar\nfor Helpers', style: AppTextStyles.h1)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Earn by helping people nearby.', style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
              const Spacer(flex: 2),
              Text('Enter your mobile number', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.phone,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Center(widthFactor: 1, child: Text('🇵🇰 +92', style: AppTextStyles.bodyLarge)),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0),
                  hintText: '333 1234567',
                  errorText: _error,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(label: 'Continue', onPressed: _continue, loading: _loading),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

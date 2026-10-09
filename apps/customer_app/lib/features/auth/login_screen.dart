import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String role; // 'customer' | 'helper'
  const LoginScreen({super.key, required this.role});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final _controller = TextEditingController(text: widget.role == 'helper' ? '3331234567' : '3001234567');
  bool _loading = false;
  String? _error;

  bool get _isHelper => widget.role == 'helper';

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
      final api = ref.read(madadgaarApiProvider);
      final otp = await api.requestOtp(phone);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Demo Mode: your verification code is $otp')),
      );
      context.push('/otp', extra: {'phone': phone, 'role': widget.role});
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    alignment: Alignment.center,
                    child: const Text('M', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Text(_isHelper ? 'Madadgaar\nfor Helpers' : 'Madadgaar', style: AppTextStyles.display),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _isHelper ? 'Earn by helping people nearby.' : 'Help, when you need it.',
                style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
              ),
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
                  hintText: '300 1234567',
                  errorText: _error,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(label: 'Continue', onPressed: _continue, loading: _loading),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'By continuing you agree to Madadgaar\'s Terms of Service and Privacy Policy.',
                style: AppTextStyles.caption.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

import 'rating_screen.dart';

const _methods = [
  (value: 'cod', label: 'Cash on Delivery', icon: Icons.payments_rounded, sublabel: 'Pay the helper in cash'),
  (value: 'easypaisa', label: 'Easypaisa', icon: Icons.account_balance_wallet_rounded, sublabel: 'Simulated in Demo Mode'),
  (value: 'jazzcash', label: 'JazzCash', icon: Icons.account_balance_wallet_rounded, sublabel: 'Simulated in Demo Mode'),
];

class PaymentScreen extends ConsumerStatefulWidget {
  final ServiceRequest request;
  const PaymentScreen({super.key, required this.request});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _method = 'jazzcash';
  bool _paying = false;

  Future<void> _pay() async {
    setState(() => _paying = true);
    try {
      await ref.read(madadgaarApiProvider).pay(widget.request.id, _method);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => RatingScreen(requestId: widget.request.id)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Payment'), automaticallyImplyLeading: false),
        body: SafeArea(
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
                  child: PriceBreakdownView(breakdown: widget.request.pricing.breakdown),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Choose payment method', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.md),
                ..._methods.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _MethodTile(
                        icon: m.icon,
                        label: m.label,
                        sublabel: m.sublabel,
                        selected: _method == m.value,
                        onTap: () => setState(() => _method = m.value),
                      ),
                    )),
                const SizedBox(height: AppSpacing.sm),
                const DemoModeBanner(),
                const Spacer(),
                PrimaryButton(
                  label: _method == 'cod' ? 'Confirm Cash on Delivery' : 'Pay ${formatPkr(widget.request.pricing.breakdown.total)}',
                  onPressed: _pay,
                  loading: _paying,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;
  const _MethodTile({required this.icon, required this.label, required this.sublabel, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.12) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: selected ? AppColors.primary : Theme.of(context).dividerColor, width: selected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.primary : Theme.of(context).textTheme.bodySmall?.color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.bodyStrong),
                  Text(sublabel, style: AppTextStyles.caption.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                ],
              ),
            ),
            Radio<bool>(value: true, groupValue: selected ? true : null, onChanged: (_) => onTap(), activeColor: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

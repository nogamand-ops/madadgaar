import 'package:flutter/material.dart';
import '../models/price_estimate.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'money_text.dart';

/// The transparent price breakdown shown before every request is confirmed,
/// and again on the payment screen. Every line item the customer is charged
/// is always visible here — nothing is ever bundled or hidden (spec: "Do
/// not hide fees. Always show the customer exactly what they are paying
/// for.").
class PriceBreakdownView extends StatelessWidget {
  final PriceBreakdown breakdown;
  final String? fuelLabel;

  const PriceBreakdownView({super.key, required this.breakdown, this.fuelLabel});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      if (breakdown.fuelCost > 0) _Row(fuelLabel ?? 'Fuel cost', breakdown.fuelCost),
      _Row('Assistance fee', breakdown.assistanceFee),
      if (breakdown.distanceFee > 0) _Row('Distance fee', breakdown.distanceFee),
      _Row('Night surcharge', breakdown.nightSurcharge),
      if (breakdown.discount > 0) _Row('Discount', -breakdown.discount, isDiscount: true),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...rows,
        const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.sm), child: Divider(height: 1)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total', style: AppTextStyles.h3),
            MoneyText(breakdown.total, style: AppTextStyles.price),
          ],
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final int amount;
  final bool isDiscount;
  const _Row(this.label, this.amount, {this.isDiscount = false});

  @override
  Widget build(BuildContext context) {
    final color = isDiscount ? Colors.greenAccent : Theme.of(context).textTheme.bodyMedium?.color;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
          MoneyText(amount, style: AppTextStyles.bodyStrong, color: color),
        ],
      ),
    );
  }
}

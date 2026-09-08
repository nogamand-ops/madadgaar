import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _pkrFormat = NumberFormat.decimalPattern('en_PK');

/// Formats an integer PKR amount as "Rs. 1,570" — used everywhere money is
/// shown so formatting never drifts between screens.
String formatPkr(num amount) => 'Rs. ${_pkrFormat.format(amount.round())}';

class MoneyText extends StatelessWidget {
  final num amount;
  final TextStyle? style;
  final Color? color;

  const MoneyText(this.amount, {super.key, this.style, this.color});

  @override
  Widget build(BuildContext context) {
    final base = style ?? Theme.of(context).textTheme.bodyLarge;
    return Text(formatPkr(amount), style: base?.copyWith(color: color ?? base.color));
  }
}

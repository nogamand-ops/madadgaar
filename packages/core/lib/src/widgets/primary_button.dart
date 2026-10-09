import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final Color? color;
  final bool expand;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.color,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    // Default button is amber with dark charcoal text/spinner (readable);
    // an explicit override color (e.g. a destructive action) gets a white
    // spinner/foreground instead.
    final spinnerColor = color != null ? Colors.white : AppColors.charcoalDeep;

    final child = loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4, valueColor: AlwaysStoppedAnimation(spinnerColor)),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 19), const SizedBox(width: AppSpacing.sm)],
              Text(label),
            ],
          );

    final button = ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: color != null ? ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white) : null,
      child: child,
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// An SOS / emergency action — reserved for genuine SOS contexts (the SOS
/// sheet, a cancel-active-job confirmation), never the home screen's
/// default call to action. Red is used deliberately and only here.
class EmergencyButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const EmergencyButton({super.key, required this.onPressed, this.label = 'SOS'});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.danger,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.md)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sos_rounded, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

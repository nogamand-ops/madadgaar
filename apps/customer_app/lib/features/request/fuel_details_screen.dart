import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

import 'location_confirm_screen.dart';
import 'request_flow_controller.dart';

const _quantities = [2, 5, 10];

class FuelDetailsScreen extends ConsumerStatefulWidget {
  const FuelDetailsScreen({super.key});

  @override
  ConsumerState<FuelDetailsScreen> createState() => _FuelDetailsScreenState();
}

class _FuelDetailsScreenState extends ConsumerState<FuelDetailsScreen> {
  String _fuelType = 'petrol';
  int _quantity = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fuel Delivery')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Fuel type', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: _FuelTypeCard(label: 'Petrol', icon: Icons.local_gas_station_rounded, selected: _fuelType == 'petrol', onTap: () => setState(() => _fuelType = 'petrol'))),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _FuelTypeCard(label: 'Diesel', icon: Icons.water_drop_rounded, selected: _fuelType == 'diesel', onTap: () => setState(() => _fuelType = 'diesel'))),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('Quantity', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: _quantities
                  .map((q) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.md),
                          child: _QuantityChip(litres: q, selected: _quantity == q, onTap: () => setState(() => _quantity = q)),
                        ),
                      ))
                  .toList(),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Continue',
              onPressed: () {
                ref.read(requestFlowProvider.notifier).setDetails({'fuelType': _fuelType, 'quantityLitres': _quantity});
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LocationConfirmScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FuelTypeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _FuelTypeCard({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        decoration: BoxDecoration(
          color: selected ? AppColors.amber.withValues(alpha: 0.12) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: selected ? AppColors.amber : Theme.of(context).dividerColor, width: selected ? 1.6 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 26, color: selected ? AppColors.charcoal : Theme.of(context).textTheme.bodySmall?.color),
            const SizedBox(height: AppSpacing.sm),
            Text(label, style: AppTextStyles.bodyStrong),
          ],
        ),
      ),
    );
  }
}

class _QuantityChip extends StatelessWidget {
  final int litres;
  final bool selected;
  final VoidCallback onTap;
  const _QuantityChip({required this.litres, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.amber : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: selected ? AppColors.amber : Theme.of(context).dividerColor),
        ),
        child: Text(
          '$litres L',
          style: AppTextStyles.bodyStrong.copyWith(color: selected ? AppColors.charcoalDeep : null),
        ),
      ),
    );
  }
}

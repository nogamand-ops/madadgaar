import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

Future<void> showAddVehicleSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _AddVehicleSheet(),
  );
}

class _AddVehicleSheet extends ConsumerStatefulWidget {
  const _AddVehicleSheet();

  @override
  ConsumerState<_AddVehicleSheet> createState() => _AddVehicleSheetState();
}

class _AddVehicleSheetState extends ConsumerState<_AddVehicleSheet> {
  VehicleType _type = VehicleType.car;
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _saving = false;

  Future<void> _save() async {
    final user = ref.read(currentUserProvider);
    if (user == null || _makeController.text.trim().isEmpty || _modelController.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      await ref.read(madadgaarApiProvider).addVehicle(
            user.id,
            Vehicle(
              id: '',
              customerId: user.id,
              type: _type,
              make: _makeController.text.trim(),
              model: _modelController.text.trim(),
              fuelType: 'petrol',
              nickname: _nicknameController.text.trim().isEmpty ? null : _nicknameController.text.trim(),
            ),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not add vehicle: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(AppRadius.xl)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add a vehicle', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                children: VehicleType.values
                    .map((t) => ChoiceChip(
                          label: Text('${t.emoji} ${t.label}'),
                          selected: _type == t,
                          onSelected: (_) => setState(() => _type = t),
                        ))
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(controller: _makeController, decoration: const InputDecoration(hintText: 'Make (e.g. Honda)')),
              const SizedBox(height: AppSpacing.md),
              TextField(controller: _modelController, decoration: const InputDecoration(hintText: 'Model (e.g. Civic)')),
              const SizedBox(height: AppSpacing.md),
              TextField(controller: _nicknameController, decoration: const InputDecoration(hintText: 'Nickname (optional), e.g. "My Honda Civic"')),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(label: 'Save vehicle', onPressed: _save, loading: _saving),
            ],
          ),
        ),
      ),
    );
  }
}

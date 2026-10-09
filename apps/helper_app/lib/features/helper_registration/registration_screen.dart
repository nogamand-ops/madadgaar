import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

final _citiesProvider = FutureProvider.autoDispose((ref) => ref.watch(madadgaarApiProvider).cities());
final _servicesProvider = FutureProvider.autoDispose((ref) => ref.watch(madadgaarApiProvider).services());

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _regController = TextEditingController();
  final _experienceController = TextEditingController(text: '1');
  final _emergencyController = TextEditingController();

  String? _cityId;
  VehicleType _vehicleType = VehicleType.motorcycle;
  final Set<String> _services = {};
  bool _submitting = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController.text = user?.name ?? '';
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty || _cityId == null || _services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in your name, city and at least one service.')));
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(madadgaarApiProvider).registerHelper({
        'name': _nameController.text.trim(),
        'city': _cityId,
        'vehicleType': _vehicleType.name,
        'vehicleMake': _makeController.text.trim(),
        'vehicleModel': _modelController.text.trim(),
        'vehicleReg': _regController.text.trim(),
        'servicesOffered': _services.toList(),
        'experienceYears': int.tryParse(_experienceController.text) ?? 0,
        'emergencyContact': _emergencyController.text.trim().isEmpty ? null : normalizePkPhone(_emergencyController.text),
      });
      if (mounted) setState(() => _submitted = true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not submit: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.hourglass_top_rounded, size: 64, color: AppColors.warning),
                const SizedBox(height: AppSpacing.lg),
                Text('Application submitted', style: AppTextStyles.h1, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your application is under review. This usually means an identity and vehicle check '
                  'before you can go online and receive requests.',
                  style: AppTextStyles.body.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                PrimaryButton(label: 'Continue', onPressed: () => context.go('/home')),
              ],
            ),
          ),
        ),
      );
    }

    final citiesAsync = ref.watch(_citiesProvider);
    final servicesAsync = ref.watch(_servicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Become a Madadgaar')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Full name', style: AppTextStyles.bodyStrong),
          const SizedBox(height: AppSpacing.sm),
          TextField(controller: _nameController),
          const SizedBox(height: AppSpacing.lg),
          Text('City', style: AppTextStyles.bodyStrong),
          const SizedBox(height: AppSpacing.sm),
          citiesAsync.when(
            data: (cities) => Wrap(
              spacing: AppSpacing.sm,
              children: cities
                  .where((c) => c.enabled)
                  .map((c) => ChoiceChip(label: Text(c.name), selected: _cityId == c.id, onSelected: (_) => setState(() => _cityId = c.id)))
                  .toList(),
            ),
            loading: () => const LoadingView(),
            error: (e, __) => Text('$e'),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Vehicle', style: AppTextStyles.bodyStrong),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: VehicleType.values
                .map((t) => ChoiceChip(label: Text('${t.emoji} ${t.label}'), selected: _vehicleType == t, onSelected: (_) => setState(() => _vehicleType = t)))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            Expanded(child: TextField(controller: _makeController, decoration: const InputDecoration(hintText: 'Make (e.g. Honda)'))),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: TextField(controller: _modelController, decoration: const InputDecoration(hintText: 'Model (e.g. CD 70)'))),
          ]),
          const SizedBox(height: AppSpacing.md),
          TextField(controller: _regController, decoration: const InputDecoration(hintText: 'Vehicle registration number')),
          const SizedBox(height: AppSpacing.lg),
          Text('Services you provide', style: AppTextStyles.bodyStrong),
          const SizedBox(height: AppSpacing.sm),
          servicesAsync.when(
            data: (services) => Wrap(
              spacing: AppSpacing.sm,
              children: services
                  .where((s) => s.key != 'other')
                  .map((s) => FilterChip(
                        label: Text('${s.icon} ${s.name}'),
                        selected: _services.contains(s.key),
                        onSelected: (sel) => setState(() => sel ? _services.add(s.key) : _services.remove(s.key)),
                      ))
                  .toList(),
            ),
            loading: () => const LoadingView(),
            error: (e, __) => Text('$e'),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _experienceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Years of experience'),
              ),
            ),
          ]),
          const SizedBox(height: AppSpacing.md),
          TextField(controller: _emergencyController, decoration: const InputDecoration(hintText: 'Emergency contact number')),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'For the MVP, identity/vehicle verification is simulated. No documents are collected or shown in this demo.',
            style: AppTextStyles.caption.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(label: 'Submit application', onPressed: _submit, loading: _submitting),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

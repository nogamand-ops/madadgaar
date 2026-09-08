import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

import '../home/home_providers.dart';
import 'add_vehicle_sheet.dart';

class VehiclesScreen extends ConsumerWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(myVehiclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your vehicles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () async {
              await showAddVehicleSheet(context, ref);
              ref.invalidate(myVehiclesProvider);
            },
          ),
        ],
      ),
      body: vehiclesAsync.when(
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return EmptyStateView(
              icon: Icons.directions_car_rounded,
              title: 'No vehicles yet',
              message: 'Add a vehicle to speed up future requests.',
              actionLabel: 'Add vehicle',
              onAction: () async {
                await showAddVehicleSheet(context, ref);
                ref.invalidate(myVehiclesProvider);
              },
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: vehicles.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, i) {
              final v = vehicles[i];
              return Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    Text(v.type.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v.displayName, style: AppTextStyles.h3),
                          Text('${v.type.label} · ${v.make} ${v.model}',
                              style: AppTextStyles.caption.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () async {
                        final user = ref.read(currentUserProvider);
                        if (user == null) return;
                        await ref.read(madadgaarApiProvider).removeVehicle(user.id, v.id);
                        ref.invalidate(myVehiclesProvider);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const LoadingView(),
        error: (e, __) => ErrorStateView(title: 'Could not load vehicles', message: '$e', onRetry: () => ref.invalidate(myVehiclesProvider)),
      ),
    );
  }
}

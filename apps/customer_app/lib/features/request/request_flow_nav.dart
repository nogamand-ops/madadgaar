import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'fuel_details_screen.dart';
import 'location_confirm_screen.dart';
import 'request_flow_controller.dart';

/// Both entry points ("🚨 I NEED HELP" -> "What's wrong?" and tapping a
/// service card directly) converge here, so the wizard only exists once.
void enterServiceFlow(BuildContext context, WidgetRef ref, String serviceKey) {
  ref.read(requestFlowProvider.notifier).setService(serviceKey);
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => serviceKey == 'fuel' ? const FuelDetailsScreen() : const LocationConfirmScreen(),
    ),
  );
}

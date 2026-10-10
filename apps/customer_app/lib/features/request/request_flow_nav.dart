import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'fuel_details_screen.dart';
import 'request_flow_controller.dart';
import 'service_details_screen.dart';

/// Both entry points ("🚨 I NEED HELP" -> "What's wrong?" and tapping a
/// service card directly) converge here, so the wizard only exists once.
/// Every service asks what's actually wrong before location/price — fuel
/// gets its own bespoke type+quantity step; everything else gets a quick-
/// pick + optional free-text description.
/// The request flow mixes Navigator.push routes with go_router pages, and
/// `go('/home')` alone leaves the pushed routes on screen when /home is
/// already the base page — so pop everything first.
void returnHome(BuildContext context) {
  final router = GoRouter.of(context);
  Navigator.of(context).popUntil((route) => route.isFirst);
  router.go('/home');
}

void enterServiceFlow(BuildContext context, WidgetRef ref, String serviceKey) {
  ref.read(requestFlowProvider.notifier).setService(serviceKey);
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => serviceKey == 'fuel' ? const FuelDetailsScreen() : ServiceDetailsScreen(serviceKey: serviceKey),
    ),
  );
}

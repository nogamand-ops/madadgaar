import 'package:flutter/material.dart';

/// Madadgaar's brand palette: charcoal + amber. Warm white is the default
/// surface everywhere (customer, helper, and admin) — charcoal is reserved
/// for brand marks, strong text, and deliberately "dark surface" elements
/// (the admin sidebar, a dramatic full-screen moment), never as the app's
/// default background. Amber is the one accent, used deliberately for
/// primary actions, selected states, and active highlights — not as a
/// wash over the whole UI. Red is reserved for SOS and destructive actions
/// only; it is never the home screen's primary action color.
class AppColors {
  AppColors._();

  // ---- Brand ----
  static const Color charcoal = Color(0xFF27272A);
  static const Color charcoalDeep = Color(0xFF18181B);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberLight = Color(0xFFFBBF24);

  // `primary` is the one accent used for buttons/selection throughout the
  // app — kept as an alias so existing call sites read naturally.
  static const Color primary = amber;
  static const Color primaryDark = Color(0xFFD97E06);
  static const Color secondary = Color(0xFF2563EB); // Information blue

  /// Amber as TEXT/ICON color on a light surface fails contrast (~2.4:1) —
  /// use this darker variant (~4.6:1) wherever amber needs to be read as
  /// text or a small icon rather than a filled background.
  static const Color amberText = Color(0xFFB45309);

  static const Color danger = Color(0xFFDC2626); // SOS / destructive only
  static const Color warning = amber;
  static const Color success = Color(0xFF15803D); // Darkened for AA text contrast on white
  static const Color info = Color(0xFF2563EB);

  // ---- Light surface (the default everywhere) ----
  static const Color lightBg = Color(0xFFFAFAF9);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardAlt = Color(0xFFF4F4F5);
  static const Color lightBorder = Color(0xFFE4E4E7);
  static const Color lightTextPrimary = Color(0xFF18181B);
  static const Color lightTextSecondary = Color(0xFF71717A);
  static const Color lightTextMuted = Color(0xFFA1A1AA);
  static const Color lightShadow = Color(0x14000000);

  // ---- Dark surface (used sparingly: admin sidebar, a dramatic
  // full-screen moment like the helper's incoming-job alert — never the
  // app's default background) ----
  static const Color darkBg = charcoalDeep;
  static const Color darkCard = charcoal;
  static const Color darkCardAlt = Color(0xFF3F3F46);
  static const Color darkBorder = Color(0xFF3F3F46);
  static const Color darkTextPrimary = Color(0xFFFAFAF9);
  static const Color darkTextSecondary = Color(0xFFA1A1AA);
  static const Color darkTextMuted = Color(0xFF71717A);

  /// One color per ServiceRequest status, used consistently across the app.
  static const Map<String, Color> statusColors = {
    'REQUESTED': secondary,
    'SEARCHING': secondary,
    'ACCEPTED': amber,
    'HELPER_ON_THE_WAY': amber,
    'ARRIVED': secondary,
    'SERVICE_STARTED': amber,
    'COMPLETED': success,
    'CANCELLED': danger,
  };
}

import 'package:flutter/material.dart';

/// Type scale shared by every Madadgaar screen. Named by role (screen
/// title, section heading, card title, body, label, price, metric, button)
/// rather than by raw size, so screens stay consistent even as copy
/// changes. Font family is Inter, applied once via [AppTheme] — these
/// stay plain `const TextStyle`s (no family set here) so they inherit it
/// from the ambient theme, the same way the rest of Material text does.
class AppTextStyles {
  AppTextStyles._();

  /// Hero/display copy — used sparingly (a handful of screens at most).
  static const TextStyle display = TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.4);

  /// Screen title (app bar / top-of-screen heading).
  static const TextStyle h1 = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.3);

  /// Section heading ("Or choose a service", "Trusted helpers near you").
  static const TextStyle h2 = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.25, letterSpacing: -0.2);

  /// Card title (a service name, a helper's name, a request's service type).
  static const TextStyle h3 = TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, height: 1.3);

  static const TextStyle bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.45);

  static const TextStyle body = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.45);

  static const TextStyle bodyStrong = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4);

  /// Supporting/description copy — one notch quieter than `body`.
  static const TextStyle description = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, height: 1.45);

  /// Small labels (field labels, status chips, nav labels).
  static const TextStyle label = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.3);

  static const TextStyle caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.3);

  static const TextStyle overline = TextStyle(fontSize: 11, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: 0.7);

  static const TextStyle button = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: 0.1);

  /// Prices — tabular figures so amounts align in lists/breakdowns.
  static const TextStyle price = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.3,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// ETA / distance / stat-tile numbers — smaller than price but still
  /// weighted to be scanned at a glance.
  static const TextStyle metric = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}

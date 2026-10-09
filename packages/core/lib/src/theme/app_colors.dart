import 'package:flutter/material.dart';

/// Madadgaar's brand palette. Dark is the primary, default look (a premium
/// emergency-service / Pakistani fintech feel); light is a fully supported
/// second surface, not an afterthought.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF10B981); // Emerald
  static const Color primaryDark = Color(0xFF0B8F63);
  static const Color secondary = Color(0xFF38BDF8); // Cyan

  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = primary;
  static const Color info = secondary;

  // ---- Dark surface ----
  static const Color darkBg = Color(0xFF07111A);
  static const Color darkCard = Color(0xFF111827);
  static const Color darkCardAlt = Color(0xFF17202E);
  static const Color darkBorder = Color(0xFF223042);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // ---- Light surface (the primary look for customer-facing apps — a
  // warm-neutral, slightly green-tinted white, closer to Careem/inDrive's
  // rider-app feel than a generic grey admin tool) ----
  static const Color lightBg = Color(0xFFF7FAF8);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardAlt = Color(0xFFF0F5F2);
  static const Color lightBorder = Color(0xFFE7EEEA);
  static const Color lightTextPrimary = Color(0xFF0B1512);
  static const Color lightTextSecondary = Color(0xFF52635C);
  static const Color lightTextMuted = Color(0xFF8A9A93);
  static const Color lightShadow = Color(0x14143D2B);

  /// One color per ServiceRequest status, used consistently across all 3 apps.
  static const Map<String, Color> statusColors = {
    'REQUESTED': secondary,
    'SEARCHING': secondary,
    'ACCEPTED': primary,
    'HELPER_ON_THE_WAY': primary,
    'ARRIVED': Color(0xFF22D3EE),
    'SERVICE_STARTED': Color(0xFFA78BFA),
    'COMPLETED': primary,
    'CANCELLED': danger,
  };
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// No stock/fake photos anywhere in the product — every person (customer,
/// helper, admin) is represented by a deterministic initials avatar instead.
class InitialsAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? background;

  const InitialsAvatar({super.key, required this.name, this.size = 44, this.background});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  Color get _color {
    const palette = [AppColors.primary, AppColors.secondary, Color(0xFFA78BFA), Color(0xFFF59E0B), Color(0xFFEC4899)];
    final hash = name.codeUnits.fold<int>(0, (a, b) => a + b);
    return background ?? palette[hash % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: _color.withValues(alpha: 0.22),
      child: Text(
        _initials,
        style: TextStyle(color: _color, fontWeight: FontWeight.w800, fontSize: size * 0.36),
      ),
    );
  }
}

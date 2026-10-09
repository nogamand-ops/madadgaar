import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Central theme factory. Every screen calls [AppTheme.light] (the default,
/// everywhere) or [AppTheme.dark] (reserved for deliberate dark surfaces —
/// never the app's default background) instead of building its own
/// ThemeData, so the whole product stays visually consistent.
class AppTheme {
  AppTheme._();

  static final String _interFamily = GoogleFonts.inter().fontFamily!;

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        bg: AppColors.darkBg,
        card: AppColors.darkCard,
        border: AppColors.darkBorder,
        textPrimary: AppColors.darkTextPrimary,
        textSecondary: AppColors.darkTextSecondary,
      );

  static ThemeData light() => _build(
        brightness: Brightness.light,
        bg: AppColors.lightBg,
        card: AppColors.lightCard,
        border: AppColors.lightBorder,
        textPrimary: AppColors.lightTextPrimary,
        textSecondary: AppColors.lightTextSecondary,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color card,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final isLight = brightness == Brightness.light;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.amber,
      onPrimary: AppColors.charcoalDeep,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: card,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      fontFamily: _interFamily,
      textTheme: TextTheme(
        displayMedium: AppTextStyles.display.copyWith(color: textPrimary),
        headlineMedium: AppTextStyles.h1.copyWith(color: textPrimary),
        headlineSmall: AppTextStyles.h2.copyWith(color: textPrimary),
        titleMedium: AppTextStyles.h3.copyWith(color: textPrimary),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: textPrimary),
        bodyMedium: AppTextStyles.body.copyWith(color: textPrimary),
        bodySmall: AppTextStyles.caption.copyWith(color: textSecondary),
        labelLarge: AppTextStyles.button.copyWith(color: textPrimary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h2.copyWith(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: isLight ? 1 : 0,
        shadowColor: AppColors.lightShadow,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: isLight ? BorderSide(color: border, width: 1) : BorderSide(color: border, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amber,
          foregroundColor: AppColors.charcoalDeep,
          disabledBackgroundColor: AppColors.amber.withValues(alpha: 0.35),
          disabledForegroundColor: AppColors.charcoalDeep.withValues(alpha: 0.5),
          textStyle: AppTextStyles.button,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: border, width: 1.3),
          textStyle: AppTextStyles.button,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.charcoal,
          textStyle: AppTextStyles.button,
          minimumSize: const Size(0, 44),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? AppColors.lightCardAlt : card,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.amber, width: 1.6),
        ),
        hintStyle: AppTextStyles.body.copyWith(color: textSecondary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: AppColors.charcoal,
        unselectedItemColor: textSecondary,
        selectedIconTheme: const IconThemeData(color: AppColors.amber),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: isLight ? 3 : 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.charcoalDeep,
        contentTextStyle: AppTextStyles.body.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        behavior: SnackBarBehavior.floating,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: card,
        side: BorderSide(color: border),
        labelStyle: AppTextStyles.bodyStrong.copyWith(color: textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
      ),
      extensions: [
        AppSurfaceColors(
          border: border,
          cardAlt: isLight ? AppColors.lightCardAlt : AppColors.darkCardAlt,
          textSecondary: textSecondary,
          textMuted: isLight ? AppColors.lightTextMuted : AppColors.darkTextMuted,
        ),
      ],
    );
  }
}

/// Extra tokens ThemeData doesn't have a slot for, exposed via
/// `Theme.of(context).extension<AppSurfaceColors>()`.
class AppSurfaceColors extends ThemeExtension<AppSurfaceColors> {
  final Color border;
  final Color cardAlt;
  final Color textSecondary;
  final Color textMuted;

  const AppSurfaceColors({
    required this.border,
    required this.cardAlt,
    required this.textSecondary,
    required this.textMuted,
  });

  @override
  AppSurfaceColors copyWith({Color? border, Color? cardAlt, Color? textSecondary, Color? textMuted}) {
    return AppSurfaceColors(
      border: border ?? this.border,
      cardAlt: cardAlt ?? this.cardAlt,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
    );
  }

  @override
  ThemeExtension<AppSurfaceColors> lerp(ThemeExtension<AppSurfaceColors>? other, double t) {
    if (other is! AppSurfaceColors) return this;
    return AppSurfaceColors(
      border: Color.lerp(border, other.border, t)!,
      cardAlt: Color.lerp(cardAlt, other.cardAlt, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
    );
  }
}

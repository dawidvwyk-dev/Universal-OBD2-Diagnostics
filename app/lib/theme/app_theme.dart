import 'package:material_ui/material_ui.dart';

/// Workshop dark theme: black/charcoal surfaces, electric blue accent,
/// green/yellow/red status colours.
class AppColors {
  static const background = Color(0xFF0B0D10);
  static const surface = Color(0xFF15181D);
  static const surfaceHigh = Color(0xFF1E2228);
  static const outline = Color(0xFF2C323A);
  static const accent = Color(0xFF1E9BFF);
  static const ok = Color(0xFF2ECC71);
  static const warning = Color(0xFFF5C518);
  static const critical = Color(0xFFFF4D4F);
  static const textPrimary = Color(0xFFE8ECF1);
  static const textSecondary = Color(0xFF9AA4B2);
  static const simulated = Color(0xFFB06BFF);
}

ThemeData buildTheme() {
  final scheme = const ColorScheme.dark(
    primary: AppColors.accent,
    onPrimary: Colors.white,
    secondary: AppColors.accent,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    error: AppColors.critical,
    outline: AppColors.outline,
  ).copyWith(surfaceContainerHighest: AppColors.surfaceHigh);
  final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: Brightness.dark);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: AppColors.outline),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: Color(0x331E9BFF),
      selectedIconTheme: IconThemeData(color: AppColors.accent),
      selectedLabelTextStyle: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
      unselectedLabelTextStyle: TextStyle(color: AppColors.textSecondary),
      unselectedIconTheme: IconThemeData(color: AppColors.textSecondary),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceHigh,
      border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.outline)),
    ),
    dividerColor: AppColors.outline,
    textTheme: base.textTheme.apply(bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary),
  );
}

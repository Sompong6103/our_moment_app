import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized theme configuration for the Our Moment app.
class AppTheme {
  const AppTheme._();

  static ThemeData get light => ThemeData(
    fontFamily: 'Manrope',
    useMaterial3: true,
    colorSchemeSeed: AppColors.primary,
    scaffoldBackgroundColor: AppColors.scaffoldBackground,
    navigationBarTheme: const NavigationBarThemeData(
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
    ),
  );
}

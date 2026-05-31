import 'package:flutter/material.dart';

import 'app_styles.dart';

class AppTheme {
  const AppTheme._();

  static const Color _lightSeedColor = Color(0xFF00639A);
  static const Color _darkSeedColor = Color(0xFF7CCBFF);

  static ThemeData light([ColorScheme? dynamicColorScheme]) {
    return _buildTheme(
      dynamicColorScheme ??
          ColorScheme.fromSeed(
            seedColor: _lightSeedColor,
            brightness: Brightness.light,
          ),
    );
  }

  static ThemeData dark([ColorScheme? dynamicColorScheme]) {
    return _buildTheme(
      dynamicColorScheme ??
          ColorScheme.fromSeed(
            seedColor: _darkSeedColor,
            brightness: Brightness.dark,
          ),
    );
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppStyles.inputRadius),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: outlineBorder,
        enabledBorder: outlineBorder,
        focusedBorder: outlineBorder.copyWith(
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: AppStyles.focusedBorderWidth,
          ),
        ),
        errorBorder: outlineBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: outlineBorder.copyWith(
          borderSide: BorderSide(
            color: colorScheme.error,
            width: AppStyles.focusedBorderWidth,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: AppStyles.buttonMinimumSize,
          padding: AppStyles.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.buttonRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: AppStyles.buttonMinimumSize,
          padding: AppStyles.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.buttonRadius),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.buttonRadius),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'app_styles.dart';

/// Centraliza a criação dos temas claro e escuro do aplicativo.
class AppTheme {
  const AppTheme._();

  static const Color _lightSeedColor = Color(0xFF00639A);
  static const Color _darkSeedColor = Color(0xFF7CCBFF);

  /// Gera o tema claro usando cores dinâmicas quando disponíveis.
  static ThemeData light([ColorScheme? dynamicColorScheme]) {
    return _buildTheme(
      dynamicColorScheme ??
          ColorScheme.fromSeed(
            seedColor: _lightSeedColor,
            brightness: Brightness.light,
          ),
    );
  }

  /// Gera o tema escuro usando cores dinâmicas quando disponíveis.
  static ThemeData dark([ColorScheme? dynamicColorScheme]) {
    return _buildTheme(
      dynamicColorScheme ??
          ColorScheme.fromSeed(
            seedColor: _darkSeedColor,
            brightness: Brightness.dark,
          ),
    );
  }

  /// Aplica a identidade visual compartilhada a partir do ColorScheme.
  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
    );
    final textTheme = baseTheme.textTheme.copyWith(
      headlineMedium: baseTheme.textTheme.headlineMedium?.copyWith(
        fontSize: AppStyles.headerSize,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTheme.textTheme.titleMedium?.copyWith(
        fontSize: AppStyles.subtitleSize,
      ),
      titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
        fontSize: AppStyles.titleSize,
        fontWeight: FontWeight.w600,
      ),
    );
    final outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppStyles.inputRadius),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );

    return baseTheme.copyWith(
      textTheme: textTheme,
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
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.cardRadius),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: AppStyles.cardPadding,
        titleTextStyle: textTheme.titleLarge,
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
part 'package:tajalwaqaracademy/core/constants/app_colors.dart';

// An enumeration to define the available theme types in a type-safe way.
// This prevents errors from using simple strings or integers.
enum AppThemeType {
  light,
  dark,
  reading, // A dedicated theme for the reading screen
}

/// The main class responsible for providing theme data.

class AppThemes {
  static const String _cairoFontFamily = 'Cairo';

  /// Returns the appropriate `ThemeData` based on the given `AppThemeType`.
  static ThemeData getTheme(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
        return _buildThemeData(_lightColorScheme, AppColors.lightCream);
      case AppThemeType.dark:
        return _buildThemeData(_darkColorScheme, AppColors.darkBackground);
      case AppThemeType.reading:
        return _buildThemeData(
          _readingColorScheme,
          AppColors.readingBackground,
        );
    }
  }

  /// Returns the `ThemeMode` corresponding to an `AppThemeType`.
  /// This is useful for the `MaterialApp.themeMode` property.
  static ThemeMode getThemeMode(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
      case AppThemeType.reading:
        return ThemeMode.light;
      case AppThemeType.dark:
        return ThemeMode.dark;
    }
  }

  // Color schemes are defined privately to keep the main `getTheme` method clean.

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.accent,
    onPrimary: AppColors.lightCream,
    secondary: AppColors.mediumDark,
    onSecondary: AppColors.lightCream,
    background: AppColors.lightCream,
    onBackground: AppColors.mediumDark,
    surface: AppColors.lightCream,
    onSurface: AppColors.darkBackground,
    error: AppColors.error,
    onError: AppColors.lightCream,
    primaryContainer: AppColors.darkBackground70,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.accent,
    onPrimary: AppColors.darkBackground,
    secondary: AppColors.lightCream,
    onSecondary: AppColors.darkBackground,
    error: AppColors.error,
    onError: AppColors.lightCream,
    background: AppColors.darkBackground,
    onBackground: AppColors.lightCream,
    surface: AppColors.mediumDark,
    onSurface: AppColors.lightCream,
    primaryContainer: AppColors.accent12,
  );

  static const ColorScheme _readingColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.mediumDark, // Darker primary for focus
    onPrimary: AppColors.lightCream,
    secondary: AppColors.accent,
    onSecondary: AppColors.lightCream,
    error: AppColors.error,
    onError: AppColors.lightCream,
    background: AppColors.readingBackground,
    onBackground: AppColors.readingOnBackground,
    surface: Colors.white,
    onSurface: AppColors.readingOnBackground,
    primaryContainer: AppColors.darkBackground70,
  );

  /// A private helper method to build a `ThemeData` object from a color scheme.
  /// This ensures consistency across all themes by defining common properties once.
  static ThemeData _buildThemeData(
    ColorScheme colorScheme,
    Color scaffoldBackgroundColor,
  ) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: _cairoFontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      tabBarTheme: TabBarThemeData(
        dividerColor: Colors.black12,
        indicatorColor: AppColors.accent,
        labelStyle: TextStyle(
          fontSize: 14,
          fontFamily: _cairoFontFamily,
          fontWeight: FontWeight.bold,
          color: colorScheme.secondary,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 13,
          fontFamily: _cairoFontFamily,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      // Define other shared theme properties here to avoid repetition.
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.brightness == Brightness.dark
            ? AppColors.mediumDark
            : scaffoldBackgroundColor,
        foregroundColor: colorScheme.onBackground,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: _cairoFontFamily,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground,
        ),
        iconTheme: IconThemeData(color: colorScheme.onBackground),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCream.withOpacity(0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),

      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground.withOpacity(0.87),
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground.withOpacity(0.87),
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground.withOpacity(0.87),
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground.withOpacity(0.87),
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          color: colorScheme.onBackground.withOpacity(0.70),
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          color: colorScheme.surface.withOpacity(0.70),
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground.withOpacity(0.70),
        ),
        bodyMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: colorScheme.surface.withOpacity(0.70),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: colorScheme.onBackground.withOpacity(0.70),
        ),
        labelLarge: TextStyle(
          // For buttons
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground.withOpacity(0.70),
        ),
        labelMedium: TextStyle(
          // For buttons
          fontSize: 10,
          color: colorScheme.surface.withOpacity(0.70),
        ),
        labelSmall: TextStyle(
          // For buttons
          fontSize: 8,
          color: colorScheme.surface.withOpacity(0.87),
        ),
      ),
    );
  }
}

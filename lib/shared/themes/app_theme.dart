import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/core/constants/app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightCream,
    fontFamily: GoogleFonts.cairo().fontFamily,

    primaryColor: AppColors.accent,
    colorScheme: ColorScheme(
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
    ),
    appBarTheme: AppBarTheme(
      foregroundColor: AppColors.darkBackground,
      elevation: 0,
      titleTextStyle: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.darkBackground,
      ),
      iconTheme: IconThemeData(color: AppColors.lightCream),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.lightCream,
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
      titleLarge: GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.darkBackground,
      ),
      bodyLarge: GoogleFonts.cairo(fontSize: 16, color: AppColors.mediumDark),
      titleSmall: GoogleFonts.cairo(fontSize: 14, color: Colors.black54),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    fontFamily: GoogleFonts.cairo().fontFamily,
    primaryColor: AppColors.accent,

    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.accent,
      onPrimary: AppColors.darkBackground,
      secondary: AppColors.lightCream,
      onSecondary: Colors.black,
      background: AppColors.darkBackground,
      onBackground: AppColors.lightCream,
      surface: AppColors.mediumDark,
      onSurface: AppColors.lightCream,
      error: AppColors.error,
      onError: AppColors.lightCream,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.mediumDark54,
      foregroundColor: AppColors.lightCream,
      elevation: 0,
      titleTextStyle: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.lightCream,
      ),
      iconTheme: IconThemeData(color: AppColors.lightCream),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.lightCream,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.mediumDark38,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    textTheme: TextTheme(
      titleLarge: GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.lightCream,
      ),
      bodyLarge: GoogleFonts.cairo(
        fontSize: 16,
        color: AppColors.lightCream.withOpacity(0.87),
      ),
      titleSmall: GoogleFonts.cairo(
        fontSize: 14,
        color: AppColors.lightCream54,
      ),
    ),
  );
}

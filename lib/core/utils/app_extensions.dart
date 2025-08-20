// lib/core/utils/app_extensions.dart

import 'package:flutter/material.dart';

/// Extension methods for [BuildContext] to provide convenient access to
/// media query information and common UI-related functionalities.
extension BuildContextHelpers on BuildContext {
  /// Returns the screen's size.
  Size get screenSize => MediaQuery.of(this).size;

  /// Returns the screen's width.
  double get screenWidth => screenSize.width;

  /// Returns the screen's height.
  double get screenHeight => screenSize.height;

  /// A shorthand for accessing the current theme's data.
  ThemeData get theme => Theme.of(this);

  /// A shorthand for accessing the current color scheme.
  ColorScheme get colorScheme => theme.colorScheme;
  
  /// A shorthand for accessing the current text theme.
  TextTheme get textTheme => theme.textTheme;

  /// Returns a value based on the current orientation (portrait or landscape).
  ///
  /// Example: `context.responsiveValue(portrait: 12.0, landscape: 24.0)`
  T responsiveValue<T>({required T portrait, required T landscape}) {
    final orientation = MediaQuery.of(this).orientation;
    return orientation == Orientation.portrait ? portrait : landscape;
  }
}

/// Extension methods for [String] to add utility functions.
extension StringHelpers on String {
  /// Converts Arabic-Indic numerals (٠١٢٣٤٥٦٧٨٩) in a string to Western Arabic numerals (0123456789).
  String toWesternArabicNumerals() {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    const english = '0123456789';
    String input = this;
    for (int i = 0; i < arabic.length; i++) {
      input = input.replaceAll(arabic[i], english[i]);
    }
    return input;
  }
  
  /// Converts Western Arabic numerals (0123456789) in a string to Arabic-Indic numerals (٠١٢٣٤٥٦٧٨٩).
  String toArabicNumerals() {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    const english = '0123456789';
    String input = this;
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }
}

/// Extension methods for nullable [String] to provide safe operations.
extension NullableStringHelpers on String? {
  /// Returns `true` if the string is either null or empty.
  bool get isNullOrEmpty {
    return this == null || this!.isEmpty;
  }
  
  /// Returns `true` if the string is not null and not empty.
  bool get isNotNullOrEmpty {
    return this != null && this!.isNotEmpty;
  }
}
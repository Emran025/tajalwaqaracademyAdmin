import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

/// A centralized configuration class for the application's localization setup.
///
/// This class encapsulates all the necessary delegates and supported locales,
/// providing a single, clean source of truth for the `MaterialApp` widget.
/// This approach keeps the main application widget tidy and separates localization
/// concerns into a dedicated file.
final class L10nConfig {
  /// Private constructor to prevent instantiation of this utility class.
  L10nConfig._();

  /// The list of localization delegates required by the application.
  ///
  /// This includes the auto-generated [AppLocalizations.delegate] for app-specific
  /// strings, as well as the global delegates for Material and Cupertino widgets.
  static const List<LocalizationsDelegate<dynamic>> delegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  /// The list of locales that the application supports.
  ///
  /// The first locale in this list is typically considered the default.
  static const List<Locale> supportedLocales = [
    Locale('ar'), // Arabic
    // Add other supported locales here in the future, e.g., Locale('en'),
  ];
  
  /// A convenience getter for the default locale of the app.
  static Locale get defaultLocale => supportedLocales.first;
}
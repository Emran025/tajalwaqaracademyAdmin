// path: lib/features/settings/domain/entities/settings_entity.dart

import 'package:equatable/equatable.dart';

import '../../../../shared/themes/app_theme.dart'; // Assuming path to your AppThemeType enum

/// Represents the consolidated, user-configurable settings for the application.
///
/// This domain entity serves as a single, immutable source of truth for all
/// preferences managed within the settings feature. It is designed to be
/// fetched once and passed to the presentation layer, which then uses this
/// data to render the state of various UI controls like switches and theme selectors.
class SettingsEntity extends Equatable {
  /// Defines the current visual theme of the application (e.g., light, dark).
  /// This property directly maps to the choice made in the `ThemeSwitcherWidget`.
  final AppThemeType themeType;

  /// The master control for enabling or disabling all push notifications.
  /// This corresponds to the "تفعيل الإشعارات" switch in the UI.
  final bool notificationsEnabled;

  /// The user's consent to participate in anonymous data collection for
  /// application improvement. This corresponds to the "تحليل البيانات" switch.
  final bool analyticsEnabled;

  /// Creates an instance of the settings configuration.
  ///
  /// All properties are required to ensure a complete and valid state.
  const SettingsEntity({
    required this.themeType,
    required this.notificationsEnabled,
    required this.analyticsEnabled,
  });

  /// A default 'factory' constructor for creating a sensible initial state.
  /// This is useful for initializing the app on the very first run before
  /// any settings have been saved.
  factory SettingsEntity.initial() {
    return const SettingsEntity(
      themeType: AppThemeType.light, // Or your preferred system default
      notificationsEnabled: true,
      analyticsEnabled: false,
    );
  }

  @override
  List<Object> get props => [themeType, notificationsEnabled, analyticsEnabled];
}

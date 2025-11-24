// path: lib/features/settings/presentation/bloc/settings_event.dart
part of 'settings_bloc.dart';

/// The abstract base class for all events related to the settings feature.
@immutable
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

/// Dispatched to initialize the settings screen, fetching all initial,
/// non-profile related settings like theme and preferences.
class LoadInitialSettings extends SettingsEvent {}

/// Dispatched to fetch the user's profile data, including personal details
/// and active sessions. This is a separate event to allow for independent loading.
class LoadUserProfile extends SettingsEvent {}

/// Dispatched when the user selects a new application theme.
class ThemeChanged extends SettingsEvent {
  final AppThemeType newTheme;
  const ThemeChanged(this.newTheme);
  @override
  List<Object> get props => [newTheme];
}

/// Dispatched when the user toggles the notifications preference.
class NotificationsPreferenceChanged extends SettingsEvent {
  final bool isEnabled;
  const NotificationsPreferenceChanged(this.isEnabled);
  @override
  List<Object> get props => [isEnabled];
}

/// Dispatched when the user toggles the analytics consent.
class AnalyticsPreferenceChanged extends SettingsEvent {
  final bool isEnabled;
  const AnalyticsPreferenceChanged(this.isEnabled);
  @override
  List<Object> get props => [isEnabled];
}

/// Dispatched when the user submits an update for their profile information.
/// It carries the new user data to be persisted.
class UpdateProfileRequested extends SettingsEvent {
  /// The complete user profile entity with the updated information.
  final UserProfileEntity userProfile;

  const UpdateProfileRequested(this.userProfile);

  @override
  List<Object> get props => [userProfile];
}





/// in the repository layer.
class LoadPrivacyPolicy extends SettingsEvent {}

/// Fired to request a data export.
class SettingsExportDataRequested extends SettingsEvent {
  final ExportConfig config;

  const SettingsExportDataRequested(this.config);

  @override
  List<Object> get props => [config];
}

/// Fired to request a data import.
class SettingsImportDataRequested extends SettingsEvent {
  final String filePath;
  final ImportConfig config;

  const SettingsImportDataRequested(this.filePath, this.config);

  @override
  List<Object> get props => [filePath, config];
}

/// Fired to reset the import/export status.
class SettingsImportExportResetStatus extends SettingsEvent {}

/// Fired to fetch the frequently asked questions.
class FetchFaqs extends SettingsEvent {}

/// Fired when the user submits a new support ticket.
class SubmitSupportTicket extends SettingsEvent {
  final String subject;
  final String body;

  const SubmitSupportTicket({required this.subject, required this.body});

  @override
  List<Object> get props => [subject, body];
}

/// Fired to fetch the terms of use.
class LoadTermsOfUse extends SettingsEvent {}

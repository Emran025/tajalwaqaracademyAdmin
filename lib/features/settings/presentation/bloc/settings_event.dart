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




/// NEW: Dispatched to fetch the latest privacy policy document.
///
/// This event triggers the "remote-first, cache-fallback" logic defined
/// in the repository layer.
class LoadPrivacyPolicy extends SettingsEvent {}


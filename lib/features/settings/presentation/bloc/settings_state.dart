part of 'settings_bloc.dart';

/// Represents the status of a specific, discrete section of the UI,
/// such as the user profile or privacy policy block.
enum SectionStatus { initial, loading, success, failure }

/// Represents the status of a one-time action, like saving a form,
/// used to trigger transient UI feedback like a SnackBar.
enum ActionStatus { initial, loading, success, failure }

/// The abstract base class for all states emitted by the [SettingsBloc].
@immutable
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

/// The initial state before any data has been loaded.
/// The UI should display a global loading indicator.
class SettingsInitial extends SettingsState {}

/// The primary state representing a successfully loaded settings screen.
///
/// This state is a composite model, holding all the data required by the UI.
/// It tracks the status of different data sections independently to allow for
/// a more granular and responsive user experience.
class SettingsLoadSuccess extends SettingsState {
  /// The core application preferences.
  final SettingsEntity settings;

  /// The user's profile data. It's nullable as it might be loading
  /// or fail to load independently of the core settings.
  final UserProfileEntity? userProfile;

  /// The loading status of the user profile section.
  final SectionStatus profileStatus;

  /// The latest privacy policy document. It is nullable to handle
  /// independent loading and potential failures.
  final PrivacyPolicyEntity? privacyPolicy; // NEW

  /// The loading status of the privacy policy section.
  final SectionStatus policyStatus; // NEW

  /// The status of a one-time user action (e.g., updating the profile).
  final ActionStatus actionStatus;

  /// Holds a failure object if a section or action fails, providing
  /// specific error details to the UI.
  final Failure? error;

  const SettingsLoadSuccess({
    required this.settings,
    this.userProfile,
    this.profileStatus = SectionStatus.initial,
    this.privacyPolicy, // NEW
    this.policyStatus = SectionStatus.initial, // NEW
    this.actionStatus = ActionStatus.initial,
    this.error,
  });

  /// Creates a new instance of [SettingsLoadSuccess] with updated values.
  /// This is the cornerstone of immutable state management in BLoC.
  SettingsLoadSuccess copyWith({
    SettingsEntity? settings,
    UserProfileEntity? userProfile,
    SectionStatus? profileStatus,
    PrivacyPolicyEntity? privacyPolicy, // NEW
    SectionStatus? policyStatus, // NEW
    ActionStatus? actionStatus,
    Failure? error,
    bool clearError = false, // Flag to explicitly clear the error
  }) {
    return SettingsLoadSuccess(
      settings: settings ?? this.settings,
      userProfile: userProfile ?? this.userProfile,
      profileStatus: profileStatus ?? this.profileStatus,
      privacyPolicy: privacyPolicy ?? this.privacyPolicy, // NEW
      policyStatus: policyStatus ?? this.policyStatus, // NEW
      actionStatus: actionStatus ?? this.actionStatus,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    settings,
    userProfile,
    profileStatus,
    privacyPolicy, // NEW
    policyStatus, // NEW
    actionStatus,
    error,
  ];
}

/// A state representing a catastrophic failure to load the initial,
/// essential settings. The UI should show a full-screen error.
class SettingsLoadFailure extends SettingsState {
  final Failure failure;
  const SettingsLoadFailure(this.failure);

  @override
  List<Object> get props => [failure];
}

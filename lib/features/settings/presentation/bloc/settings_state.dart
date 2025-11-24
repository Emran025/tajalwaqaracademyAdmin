part of 'settings_bloc.dart';


/// Represents the status of a specific, discrete section of the UI,
/// such as the user profile or privacy policy block.
enum SectionStatus { initial, loading, success, failure }

/// Represents the status of a one-time action, like saving a form,
/// used to trigger transient UI feedback like a SnackBar.
enum ActionStatus { initial, loading, success, failure }

/// The status of a data export operation.
enum DataExportStatus { initial, loading, success, failure }

/// The status of a data import operation.
enum DataImportStatus { initial, parsing, validating, importing, success, failure }

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

  final List<FaqEntity> faqs;
  final bool hasReachedMaxFaqs;
  final SectionStatus faqsStatus;

  final TermsOfUseEntity? termsOfUse;
  final SectionStatus termsOfUseStatus;

  /// The status of a one-time user action (e.g., updating the profile).
  final ActionStatus actionStatus;

  /// Holds a failure object if a section or action fails, providing
  /// specific error details to the UI.
  final Failure? error;

  final DataExportStatus exportStatus;
  final DataImportStatus importStatus;
  final String? exportFilePath;
  final ImportSummary? importSummary;

  const SettingsLoadSuccess({
    required this.settings,
    this.userProfile,
    this.profileStatus = SectionStatus.initial,
    this.privacyPolicy, // NEW
    this.policyStatus = SectionStatus.initial, // NEW
    this.faqs = const [],
    this.hasReachedMaxFaqs = false,
    this.faqsStatus = SectionStatus.initial,
    this.termsOfUse,
    this.termsOfUseStatus = SectionStatus.initial,
    this.actionStatus = ActionStatus.initial,
    this.error,
    this.exportStatus = DataExportStatus.initial,
    this.importStatus = DataImportStatus.initial,
    this.exportFilePath,
    this.importSummary,
  });

  /// Creates a new instance of [SettingsLoadSuccess] with updated values.
  /// This is the cornerstone of immutable state management in BLoC.
  SettingsLoadSuccess copyWith({
    SettingsEntity? settings,
    UserProfileEntity? userProfile,
    SectionStatus? profileStatus,
    PrivacyPolicyEntity? privacyPolicy, // NEW
    SectionStatus? policyStatus, // NEW
    List<FaqEntity>? faqs,
    bool? hasReachedMaxFaqs,
    SectionStatus? faqsStatus,
    TermsOfUseEntity? termsOfUse,
    SectionStatus? termsOfUseStatus,
    ActionStatus? actionStatus,
    Failure? error,
    bool clearError = false, // Flag to explicitly clear the error
    DataExportStatus? exportStatus,
    DataImportStatus? importStatus,
    String? exportFilePath,
    ImportSummary? importSummary,
  }) {
    return SettingsLoadSuccess(
      settings: settings ?? this.settings,
      userProfile: userProfile ?? this.userProfile,
      profileStatus: profileStatus ?? this.profileStatus,
      privacyPolicy: privacyPolicy ?? this.privacyPolicy, // NEW
      policyStatus: policyStatus ?? this.policyStatus, // NEW
      faqs: faqs ?? this.faqs,
      hasReachedMaxFaqs: hasReachedMaxFaqs ?? this.hasReachedMaxFaqs,
      faqsStatus: faqsStatus ?? this.faqsStatus,
      termsOfUse: termsOfUse ?? this.termsOfUse,
      termsOfUseStatus: termsOfUseStatus ?? this.termsOfUseStatus,
      actionStatus: actionStatus ?? this.actionStatus,
      error: clearError ? null : error ?? this.error,
      exportStatus: exportStatus ?? this.exportStatus,
      importStatus: importStatus ?? this.importStatus,
      exportFilePath: exportFilePath ?? this.exportFilePath,
      importSummary: importSummary ?? this.importSummary,
    );
  }

  @override
  List<Object?> get props => [
    settings,
    userProfile,
    profileStatus,
    privacyPolicy, // NEW
    policyStatus, // NEW
    faqs,
    hasReachedMaxFaqs,
    faqsStatus,
    termsOfUse,
    termsOfUseStatus,
    actionStatus,
    error,
        exportStatus,
        importStatus,
        exportFilePath,
        importSummary,
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

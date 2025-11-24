// path: lib/features/settings/domain/repositories/settings_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/themes/app_theme.dart';
import '../entities/privacy_policy_entity.dart';
import '../entities/settings_entity.dart';
import '../entities/export_config.dart';
import '../entities/import_config.dart';
import '../entities/faq_entity.dart';
import '../entities/import_summary.dart';
import '../entities/support_ticket_entity.dart';
import '../entities/terms_of_use_entity.dart';
import '../entities/user_profile_entity.dart';

/// Defines the contract for managing all data related to the settings and
/// user profile features.
///
/// This abstract class serves as the boundary between the domain layer and the
/// data layer. It ensures that the domain logic is completely decoupled from the
/// data sources (e.g., local cache, remote API). The use cases in the domain
/// layer will depend on this contract, not on its concrete implementation.
abstract class SettingsRepository {
  /// Retrieves the consolidated user preferences.
  ///
  /// Returns a [SettingsEntity] containing theme, notification, and analytics
  /// preferences.
  Future<Either<Failure, SettingsEntity>> getSettings();

  /// Persists the user's chosen application theme.
  ///
  /// - [themeType]: The new theme to be saved.
  /// Returns a [Future] completing to [void] on success.
  Future<Either<Failure, void>> saveTheme(AppThemeType themeType);

  /// Persists the user's preference for enabling or disabling notifications.
  ///
  /// - [isEnabled]: The new preference state.
  Future<Either<Failure, void>> setNotificationsPreference(bool isEnabled);

  /// Persists the user's consent for analytics data collection.
  ///
  /// - [isEnabled]: The new consent state.
  Future<Either<Failure, void>> setAnalyticsPreference(bool isEnabled);

  /// Retrieves the detailed user profile from the data source.
  ///
  /// This includes user identity information and a list of active sessions.
  /// Returns a [UserProfileEntity] on success.
  Future<Either<Failure, UserProfileEntity>> getUserProfile();

  /// Submits updated user profile data for persistence.
  ///
  /// - [profile]: The [UserProfileEntity] containing the updated information.
  /// Returns a [Future] completing to [void] on success.
  Future<Either<Failure, void>> updateUserProfile(UserProfileEntity profile);
    
  /// Fetches the latest privacy policy, using a remote-first with cache-fallback strategy.
  Future<Either<Failure, PrivacyPolicyEntity>> getLatestPolicy();

  /// Exports application data based on the provided configuration.
  ///
  /// - [config]: The [ExportConfig] specifying what to export and how.
  /// Returns a [Future] completing to the file path of the exported data.
  Future<Either<Failure, String>> exportData({required ExportConfig config});

  /// Imports application data from a file.
  ///
  /// - [filePath]: The path to the file to be imported.
  /// - [config]: The [ImportConfig] specifying how to handle the import.
  /// Returns a [Future] completing to an [ImportSummary].
  Future<Either<Failure, ImportSummary>> importData(
      {required String filePath, required ImportConfig config});

  /// Fetches the frequently asked questions.
  Future<Either<Failure, List<FaqEntity>>> getFaqs(int page);

  /// Submits a new support ticket.
  Future<Either<Failure, void>> submitSupportTicket(SupportTicketEntity ticket);

  /// Fetches the terms of use.
  Future<Either<Failure, TermsOfUseEntity>> getTermsOfUse();
}
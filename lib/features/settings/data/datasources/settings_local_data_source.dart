// path: lib/features/settings/data/datasources/settings_local_data_source.dart



import '../../../../core/error/exceptions.dart';
import '../../../../shared/themes/app_theme.dart';
import '../models/privacy_policy_model.dart';
import '../models/settings_model.dart'; // We use a Model here for data transfer



/// Defines the contract for accessing settings data from local storage.
///
/// This abstraction ensures the repository is decoupled from the specific
/// implementation details of the cache (e.g., SharedPreferences, Hive).
abstract class SettingsLocalDataSource {
  /// Retrieves the cached [SettingsModel].
  ///
  /// Throws a [CacheException] if no settings data can be retrieved.
  Future<SettingsModel> getSettings();

  /// Persists the chosen [AppThemeType].
  Future<void> saveTheme(AppThemeType themeType);

  /// Persists the notification preference.
  Future<void> setNotificationsPreference(bool isEnabled);

  /// Persists the analytics preference.
  Future<void> setAnalyticsPreference(bool isEnabled);
    /// Fetches the most recent privacy policy from the local cache.
  ///
  /// The "most recent" policy is determined by its version string in descending order.
  ///
  /// Throws a [CacheException] if no policy is found or if a database
  /// error occurs.
  Future<PrivacyPolicyModel> getLatestPolicy();

  /// Saves a given [PrivacyPolicyModel] to the local cache.
  ///
  /// This method performs an "upsert" operation:
  /// - If a policy with the same version already exists, it will be updated.
  /// - If no policy with that version exists, a new one will be inserted.
  ///
  /// Throws a [CacheException] if the data fails to be saved.
  Future<void> savePolicy(PrivacyPolicyModel policy);
}


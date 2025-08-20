// path: lib/features/settings/data/datasources/settings_local_data_source.dart

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tajalwaqaracademy/core/error/exceptions.dart';
import 'package:tajalwaqaracademy/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';

import '../../../../core/database/app_database.dart';
import '../models/privacy_policy_model.dart';
import '../models/settings_model.dart';

/// The concrete implementation of [SettingsLocalDataSource] using [SharedPreferences].
///
/// This class directly interacts with the device's local storage to manage
/// application settings. It is responsible for serialization/deserialization
/// and handling any platform-specific caching errors.

const String _kThemeKey = 'APP_THEME';
const String _kNotificationsKey = 'NOTIFICATIONS_ENABLED';
const String _kAnalyticsKey = 'ANALYTICS_ENABLED';

const String _kPrivacyPolicyTable = 'privacy_policy';

@LazySingleton(as: SettingsLocalDataSource)
class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences _sharedPreferences;
  final AppDatabase _appDatabase;
  SettingsLocalDataSourceImpl({
    required SharedPreferences sharedPreferences,
    required AppDatabase appDatabase,
  }) : _sharedPreferences = sharedPreferences,
       _appDatabase = appDatabase;

  @override
  Future<SettingsModel> getSettings() async {
    try {
      // Retrieve raw values, providing sensible defaults if keys don't exist.
      final themeName =
          _sharedPreferences.getString(_kThemeKey) ?? AppThemeType.light.name;
      final notificationsEnabled =
          _sharedPreferences.getBool(_kNotificationsKey) ?? true;
      final analyticsEnabled =
          _sharedPreferences.getBool(_kAnalyticsKey) ?? false;

      // Find the corresponding enum value from the saved theme name.
      final themeType = AppThemeType.values.firstWhere(
        (e) => e.name == themeName,
        orElse: () => AppThemeType.light, // Fallback for corrupted data
      );

      // Construct and return the data model.
      return SettingsModel(
        themeType: themeType,
        notificationsEnabled: notificationsEnabled,
        analyticsEnabled: analyticsEnabled,
      );
    } catch (e) {
      // This generic catch handles any unexpected error during retrieval.
      throw CacheException(message: 'Failed to retrieve settings from cache.');
    }
  }

  @override
  Future<void> saveTheme(AppThemeType themeType) async {
    try {
      // Store the enum's name as a string, a reliable serialization method.
      await _sharedPreferences.setString(_kThemeKey, themeType.name);
    } catch (e) {
      throw CacheException(message: 'Failed to save theme preference.');
    }
  }

  @override
  Future<void> setAnalyticsPreference(bool isEnabled) async {
    try {
      await _sharedPreferences.setBool(_kAnalyticsKey, isEnabled);
    } catch (e) {
      throw CacheException(message: 'Failed to save analytics preference.');
    }
  }

  @override
  Future<void> setNotificationsPreference(bool isEnabled) async {
    try {
      await _sharedPreferences.setBool(_kNotificationsKey, isEnabled);
    } catch (e) {
      throw CacheException(message: 'Failed to save notifications preference.');
    }
  }

  /// This class directly interacts with the [AppDatabase] to perform raw SQL
  /// queries for fetching and storing privacy policy documents. It is responsible
  //  for handling database errors and converting them into application-specific
  //  [CacheException]s.

  /// Requires an [AppDatabase] instance, which will be provided by the
  /// dependency injection framework.

  @override
  Future<PrivacyPolicyModel> getLatestPolicy() async {
    try {
      final db = await _appDatabase.database;
      final List<Map<String, dynamic>> result = await db.query(
        _kPrivacyPolicyTable,
        orderBy: 'version DESC', // Sorts versions like "2025.08.10" correctly
        limit: 1,
      );

      if (result.isNotEmpty) {
        // A policy was found, hydrate the model from the database map.
        return PrivacyPolicyModel.fromDbMap(result.first);
      } else {
        // No policy has been cached yet. This is a valid but exceptional case.
        throw CacheException(
          message: 'No privacy policy found in local cache.',
        );
      }
    } catch (e) {
      // Catch specific sqflite errors or any other exception and wrap it.
      throw CacheException(
        message: 'Failed to retrieve privacy policy from database.',
      );
    }
  }

  @override
  Future<void> savePolicy(PrivacyPolicyModel policy) async {
    try {
      final db = await _appDatabase.database;
      await db.insert(
        _kPrivacyPolicyTable,
        policy.toDbMap(), // Use the model's conversion method
        conflictAlgorithm:
            ConflictAlgorithm.replace, // Handles insert vs. update
      );
    } catch (e) {
      throw CacheException(
        message: 'Failed to save privacy policy to database.',
      );
    }
  }
}

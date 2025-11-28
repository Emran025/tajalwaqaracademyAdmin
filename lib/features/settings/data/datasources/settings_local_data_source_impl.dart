// lib/features/settings/data/datasources/settings_local_data_source_impl.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tajalwaqaracademy/core/database/app_database.dart';
import 'package:tajalwaqaracademy/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:tajalwaqaracademy/features/settings/data/models/settings_model.dart';
import 'package:tajalwaqaracademy/features/settings/data/models/user_profile_model.dart';
import 'package:tajalwaqaracademy/features/settings/domain/entities/export_config.dart';
import 'package:tajalwaqaracademy/features/settings/domain/entities/import_summary.dart';

const String _kSettingsKeyPrefix = 'settings_';
const String _kThemeKey = 'theme';
const String _kNotificationsKey = 'notifications';
const String _kAnalyticsKey = 'analytics';

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences _sharedPreferences;
  final AppDatabase _appDatabase;

  SettingsLocalDataSourceImpl({
    required SharedPreferences sharedPreferences,
    required AppDatabase appDatabase,
  })  : _sharedPreferences = sharedPreferences,
        _appDatabase = appDatabase;

  String _userKey(int userId, String key) => '$_kSettingsKeyPrefix${userId}_$key';

  @override
  Future<SettingsModel> getSettings(int userId) async {
    final theme =
        _sharedPreferences.getString(_userKey(userId, _kThemeKey)) ?? 'system';
    final notifications =
        _sharedPreferences.getBool(_userKey(userId, _kNotificationsKey)) ??
            true;
    final analytics =
        _sharedPreferences.getBool(_userKey(userId, _kAnalyticsKey)) ?? true;
    return SettingsModel(
      theme: theme,
      notificationsEnabled: notifications,
      analyticsEnabled: analytics,
    );
  }

  @override
  Future<void> saveTheme(int userId, String theme) async {
    await _sharedPreferences.setString(_userKey(userId, _kThemeKey), theme);
  }

  @override
  Future<void> setNotificationsPreference(int userId, bool isEnabled) async {
    await _sharedPreferences.setBool(
        _userKey(userId, _kNotificationsKey), isEnabled);
  }

  @override
  Future<void> setAnalyticsPreference(int userId, bool isEnabled) async {
    await _sharedPreferences.setBool(
        _userKey(userId, _kAnalyticsKey), isEnabled);
  }

  @override
  Future<UserProfileModel> getUserProfile(int userId) async {
    final db = await _appDatabase.database;
    final maps = await db.query(
      'users',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    if (maps.isNotEmpty) {
      return UserProfileModel.fromMap(maps.first);
    } else {
      throw Exception('User not found');
    }
  }

  @override
  Future<void> updateUserProfile(
      int userId, UserProfileModel userProfile) async {
    final db = await _appDatabase.database;
    await db.update(
      'users',
      userProfile.toMap(),
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  @override
  Future<String> exportData(int userId, ExportConfig config) async {
    // This is a complex operation that requires querying the database
    // for all the user's data and serializing it to JSON.
    // For now, we'll return an empty JSON object as a placeholder.
    return Future.value('{}');
  }

  @override
  Future<ImportSummary> importData(int userId, String json) async {
    // This is a complex operation that requires parsing the JSON,
    // validating the data, and inserting it into the database.
    // For now, we'll return a summary with zero counts as a placeholder.
    return Future.value(const ImportSummary(
      students: 0,
      halaqas: 0,
      teachers: 0,
      trackingRecords: 0,
    ));
  }
}

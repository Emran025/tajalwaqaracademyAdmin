// lib/features/settings/data/datasources/settings_local_data_source.dart

import 'package:tajalwaqaracademy/features/settings/data/models/settings_model.dart';
import 'package:tajalwaqaracademy/features/settings/data/models/user_profile_model.dart';
import 'package:tajalwaqaracademy/features/settings/domain/entities/export_config.dart';
import 'package:tajalwaqaracademy/features/settings/domain/entities/import_summary.dart';

abstract class SettingsLocalDataSource {
  Future<SettingsModel> getSettings(int userId);
  Future<void> saveTheme(int userId, String theme);
  Future<void> setNotificationsPreference(int userId, bool isEnabled);
  Future<void> setAnalyticsPreference(int userId, bool isEnabled);
  Future<UserProfileModel> getUserProfile(int userId);
  Future<void> updateUserProfile(int userId, UserProfileModel userProfile);
  Future<ImportSummary> importData(int userId, String json);
  Future<String> exportData(int userId, ExportConfig config);
}

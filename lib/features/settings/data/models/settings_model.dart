// path: lib/features/settings/data/models/settings_model.dart

import '../../../../shared/themes/app_theme.dart';
import '../../domain/entities/settings_entity.dart';

/// Represents the settings data as it is structured and transferred within
/// the data layer.
///
/// This class extends [SettingsEntity] to inherit its properties and behavior,
/// acting as a concrete data transfer object (DTO). This inheritance avoids
/// boilerplate code for mapping between the model and the entity, as the model
/// *is-a* valid entity.
///
/// In a more complex scenario where the data source structure differs from the
/// domain entity (e.g., different field names in a JSON response), this model
/// would not extend the entity. Instead, it would have its own distinct fields
/// and a `toEntity()` method to perform the mapping. For this application's
/// local storage, direct extension is the most efficient and clean approach.
class SettingsModel extends SettingsEntity {
  /// Creates a [SettingsModel] instance.
  ///
  /// The constructor calls `super` to initialize the properties defined in
  /// the base [SettingsEntity].
  const SettingsModel({
    required super.themeType,
    required super.notificationsEnabled,
    required super.analyticsEnabled,
  });

  /// factory constructor to create a [SettingsModel] from a JSON map.
  /// This is useful when data is fetched from a local cache or remote API.
  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      themeType: AppThemeType.values[json['themeType'] as int],
      notificationsEnabled: json['notificationsEnabled'] as bool,
      analyticsEnabled: json['analyticsEnabled'] as bool,
    );
  }

  /// Converts this model to a JSON map.
  /// This is useful when saving data to a local cache or sending it to a remote API.
  Map<String, dynamic> toJson() {
    return {
      'themeType': themeType.index,
      'notificationsEnabled': notificationsEnabled,
      'analyticsEnabled': analyticsEnabled,
    };
  }

  /// A factory constructor to create a [SettingsModel] from a Db Map.
  /// This is useful when data is fetched from a local database.
  factory SettingsModel.fromDb(Map<String, dynamic> dbMap) {
    return SettingsModel(
      themeType: AppThemeType.values[dbMap['themeType'] as int],
      notificationsEnabled: dbMap['notificationsEnabled'] as bool,
      analyticsEnabled: dbMap['analyticsEnabled'] as bool,
    );
  }

  /// Converts this model to a Db Map.
  /// This is useful when saving data to a local database.
  Map<String, dynamic> toMap() {
    return {
      'themeType': themeType.index,
      'notificationsEnabled': notificationsEnabled,
      'analyticsEnabled': analyticsEnabled,
    };
  }

  /// A factory constructor to create a [SettingsModel] from a [SettingsEntity].
  ///
  /// This is useful when data flows from the domain layer back to the data layer.
  factory SettingsModel.fromEntity(SettingsEntity entity) {
    return SettingsModel(
      themeType: entity.themeType,
      notificationsEnabled: entity.notificationsEnabled,
      analyticsEnabled: entity.analyticsEnabled,
    );
  }

  /// Converts this model to a [SettingsEntity].
  /// This is useful when passing data to the domain layer.
  SettingsEntity toEntity() {
    return SettingsEntity(
      themeType: themeType,
      notificationsEnabled: notificationsEnabled,
      analyticsEnabled: analyticsEnabled,
    );
  }
}

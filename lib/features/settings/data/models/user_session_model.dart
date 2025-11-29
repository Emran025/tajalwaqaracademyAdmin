// path: lib/features/settings/data/models/user_session_model.dart

import '../../../auth/data/models/device_info_model.dart';
import '../../domain/entities/user_session_entity.dart';

/// Represents a single user session as structured for API communication.
///
/// This class extends [UserSessionModel] to act as a DTO (Data Transfer Object),
/// responsible for parsing JSON data from the API into a domain-compatible object.
class UserSessionModel {
  /// A unique identifier for the session, essential for targeted actions
  /// like remote sign-out.
  final String id;

  /// A flag indicating if this session corresponds to the device currently
  /// being used. This is a critical UX element to prevent a user from
  /// accidentally logging themselves out.
  final bool isCurrentDevice;

  /// The timestamp of the last authenticated activity for this session.
  /// Used to help the user identify old or suspicious sessions.
  final DateTime lastAccessedAt;

  /// The detailed hardware and software snapshot of the device associated
  /// with this session.
  final DeviceInfoModel deviceInfo;
  const UserSessionModel({
    required this.id,
    required this.isCurrentDevice,
    required this.lastAccessedAt,
    required this.deviceInfo,
  });

  /// Creates a [UserSessionModel] instance from a JSON map.
  ///
  /// This factory is responsible for correctly parsing the raw data from the API,
  /// including converting the date string into a [DateTime] object and constructing
  /// the nested [DeviceInfoModel].
  factory UserSessionModel.fromJson(Map<String, dynamic> json) {
    // A nested function to parse device info, keeping the main factory clean.
    DeviceInfoModel parseDeviceInfo(Map<String, dynamic> deviceJson) {
      return DeviceInfoModel(
        deviceId: deviceJson['device_id'] ?? 'Unknown',
        deviceModel: deviceJson['device_model'] ?? 'Unknown',
        manufacturer: deviceJson['manufacturer'] ?? 'Unknown',
        osVersion: deviceJson['os_version'] ?? 'Unknown',
        appVersion: deviceJson['app_version'] ?? 'Unknown',
        timezone: deviceJson['timezone'] ?? 'UTC',
        locale: deviceJson['locale'] ?? 'en_US',
        pushNotificationToken: deviceJson['push_notification_token'] ?? '',
      );
    }

    return UserSessionModel(
      id: json['id'],
      isCurrentDevice: json['is_current_device'],
      // Safely parse the timestamp string into a DateTime object.
      lastAccessedAt: DateTime.parse(json['last_accessed_at']),
      // The API is expected to provide a nested 'device_info' object.
      deviceInfo: parseDeviceInfo(json['device_info']),
    );
  }

  /// Converts this model to a JSON map for API communication.
  /// This is useful when sending data back to the server.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_current_device': isCurrentDevice,
      'last_accessed_at': lastAccessedAt.toIso8601String(),
      'device_info': deviceInfo.toJson(),
    };
  }

  /// factory constructor to create a [UserSessionModel] from a Db Map.
  /// This is useful when data is fetched from a local database.
  factory UserSessionModel.fromDb(Map<String, dynamic> dbMap) {
    return UserSessionModel(
      id: dbMap['id'] as String,
      isCurrentDevice: dbMap['is_current_device'] == 1,
      lastAccessedAt: DateTime.parse(dbMap['last_accessed_at'] as String),
      deviceInfo: DeviceInfoModel.fromJson(
        dbMap['device_info'] as Map<String, dynamic>,
      ),
    );
  }

  /// Converts this model to a Db Map.
  /// This is useful when saving data to a local database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'is_current_device': isCurrentDevice ? 1 : 0,
      'last_accessed_at': lastAccessedAt.toIso8601String(),
      'device_info': deviceInfo.toJson(),
    };
  }

  /// A factory constructor to create a [UserSessionModel] from a [UserSessionEntity].
  /// This is useful when data flows from the domain layer back to the data layer.
  factory UserSessionModel.fromEntity(UserSessionEntity entity) {
    return UserSessionModel(
      id: entity.id,
      isCurrentDevice: entity.isCurrentDevice,
      lastAccessedAt: entity.lastAccessedAt,
      deviceInfo: DeviceInfoModel.fromEntity(entity.deviceInfo),
    );
  }

  /// Converts this model to a [UserSessionEntity].
  /// This is useful when data flows from the data layer to the domain layer.
  UserSessionEntity toEntity() {
    return UserSessionEntity(
      id: id,
      isCurrentDevice: isCurrentDevice,
      lastAccessedAt: lastAccessedAt,
      deviceInfo: deviceInfo.toEntity(),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:tajalwaqaracademy/features/auth/domain/entities/device_info_entity.dart';

/// A data model representing a snapshot of the device's context.
///
/// This immutable class is responsible for serializing device metadata into a
/// JSON format suitable for API requests. It is created from a [DeviceInfoEntity]
/// and serves as a reusable component for any API call that requires device context.
@immutable
final class DeviceInfoModel {
  final String deviceId;
  final String deviceModel;
  final String manufacturer;
  final String osVersion;
  final String appVersion;
  final String timezone;
  final String locale;
  final String pushNotificationToken;

  const DeviceInfoModel({
    required this.deviceId,
    required this.deviceModel,
    required this.manufacturer,
    required this.osVersion,
    required this.appVersion,
    required this.timezone,
    required this.locale,
    required this.pushNotificationToken,
  });

  /// Creates a [DeviceInfoModel] from a domain [DeviceInfoEntity].
  factory DeviceInfoModel.fromEntity(DeviceInfoEntity entity) {
    return DeviceInfoModel(
      deviceId: entity.deviceId,
      deviceModel: entity.deviceModel,
      manufacturer: entity.manufacturer,
      osVersion: entity.osVersion,
      appVersion: entity.appVersion,
      timezone: entity.timezone,
      locale: entity.locale,
      pushNotificationToken: entity.pushNotificationToken,
    );
  }

  /// Converts this model into a JSON map.
  /// The key names are aligned with the API specification.
  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'model': deviceModel,
      'manufacturer': manufacturer,
      'os_version': osVersion,
      'app_version': appVersion,
      'timezone': timezone,
      'locale': locale,
      'fcm_token': pushNotificationToken,
    };
  }
}

// Map<String, dynamic> 


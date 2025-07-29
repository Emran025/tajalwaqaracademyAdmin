import 'package:flutter/foundation.dart';

/// Represents a snapshot of the device's state and application metadata.
///
/// This is a pure, immutable domain entity implementing value equality.
@immutable
final class DeviceInfoEntity {
  final String deviceId;
  final String deviceModel;
  final String manufacturer;
  final String osVersion;
  final String appVersion;
  final String timezone;
  final String locale;
  final String pushNotificationToken;

  const DeviceInfoEntity({
    required this.deviceId,
    required this.deviceModel,
    required this.manufacturer,
    required this.osVersion,
    required this.appVersion,
    required this.timezone,
    required this.locale,
    required this.pushNotificationToken,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeviceInfoEntity &&
        other.deviceId == deviceId &&
        other.deviceModel == deviceModel &&
        other.manufacturer == manufacturer &&
        other.osVersion == osVersion &&
        other.appVersion == appVersion &&
        other.timezone == timezone &&
        other.locale == locale &&
        other.pushNotificationToken == pushNotificationToken;
  }

  @override
  int get hashCode {
    // Using a cascading XOR (^) is a simple and effective way to combine hash codes.
    return deviceId.hashCode ^
        deviceModel.hashCode ^
        manufacturer.hashCode ^
        osVersion.hashCode ^
        appVersion.hashCode ^
        timezone.hashCode ^
        locale.hashCode ^
        pushNotificationToken.hashCode;
  }
}
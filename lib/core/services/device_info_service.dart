import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tajalwaqaracademy/features/auth/domain/entities/device_info_entity.dart';
import 'push_notification_service.dart'; // Import the new abstraction

/// An abstract contract for a service that provides device and application metadata.
///
/// This abstraction decouples the application from the specific packages used to
/// gather device information, enhancing testability and maintainability.
abstract interface class DeviceInfoService {
  /// Asynchronously gathers comprehensive device and application information.
  Future<DeviceInfoEntity> getDeviceInfo();
}

/// The concrete implementation of [DeviceInfoService].
///
/// This class orchestrates the collection of device and app metadata from
/// various sources. It depends on abstractions for its dependencies (like -
/// [PushNotificationService]) to remain decoupled and testable.
@LazySingleton(as: DeviceInfoService)
final class DeviceInfoServiceImpl implements DeviceInfoService {
  final DeviceInfoPlugin _deviceInfoPlugin;
  final PushNotificationService _pushNotificationService;

  DeviceInfoServiceImpl({
    required DeviceInfoPlugin deviceInfoPlugin,
    required PushNotificationService pushNotificationService,
  }) : _deviceInfoPlugin = deviceInfoPlugin,
       _pushNotificationService = pushNotificationService;

  @override
  Future<DeviceInfoEntity> getDeviceInfo() async {
    // Gather all independent pieces of information concurrently for optimal performance.
    final results = await Future.wait([
      PackageInfo.fromPlatform(),
      FlutterTimezone.getLocalTimezone(),
      _pushNotificationService.getPushToken(),
      _deviceInfoPlugin.deviceInfo,
    ]);

    // Safely cast the results.
    final packageInfo = results[0] as PackageInfo;
    final timeZone = results[1] as String;
    final pushToken = results[2] as String;
    final baseDeviceInfo = results[3];

    // Platform-specific parsing.
    final String deviceId;
    final String deviceModel;
    final String osVersion;
    final String manufacturer;

    if (baseDeviceInfo is AndroidDeviceInfo) {
      deviceId = baseDeviceInfo.id;
      deviceModel = baseDeviceInfo.model;
      osVersion =
          'Android ${baseDeviceInfo.version.release} (SDK ${baseDeviceInfo.version.sdkInt})';
      manufacturer = baseDeviceInfo.manufacturer;
    } else if (baseDeviceInfo is IosDeviceInfo) {
      deviceId = baseDeviceInfo.identifierForVendor ?? 'unknown_ios_id';
      deviceModel = baseDeviceInfo.model;
      osVersion = 'iOS ${baseDeviceInfo.systemVersion}';
      manufacturer = 'Apple';
    } else {
      // Fallback for other platforms (web, desktop).
      deviceId = 'unknown_platform_id';
      deviceModel = 'unknown_platform_model';
      osVersion = Platform.operatingSystemVersion;
      manufacturer = 'unknown_platform_manufacturer';
    }

    // Construct the final, immutable entity.
    return DeviceInfoEntity(
      deviceId: deviceId,
      deviceModel: deviceModel,
      manufacturer: manufacturer,
      osVersion: osVersion,
      appVersion: '${packageInfo.version}+${packageInfo.buildNumber}',
      timezone: timeZone,
      locale: Platform.localeName,
      pushNotificationToken: pushToken,
    );
  }
}

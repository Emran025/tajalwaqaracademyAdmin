import 'package:tajalwaqaracademy/features/auth/data/models/device_info_model.dart';
import 'package:tajalwaqaracademy/features/auth/domain/entities/device_info_entity.dart';
import 'package:tajalwaqaracademy/features/auth/domain/entities/login_credentials_entity.dart';

/// The data model for a complete logIn request payload.
///
/// This class follows the **Composition over Inheritance** principle. It holds the
/// user's credentials and encapsulates the device context within a separate
/// [DeviceInfoModel]. This creates a clean, modular, and reusable structure.
///
/// Its primary responsibility is to serialize the final, structured JSON payload
/// that the authentication endpoint expects.

final class LogInRequestModel {
  /// The user's credentials for authentication.
  final String logIn;
  final String password;

  /// The encapsulated device context information.
  final DeviceInfoModel deviceInfo;

  const LogInRequestModel({
    required this.logIn,
    required this.password,
    required this.deviceInfo,
  });

  /// A factory constructor to build the request model from domain entities.
  ///
  /// This is the bridge that converts pure business objects from the domain layer
  /// into a structured data model ready for the data layer.
  factory LogInRequestModel.fromEntities({
    required LogInCredentialsEntity credentials,
    required DeviceInfoEntity deviceInfo,
  }) {
    return LogInRequestModel(
      logIn: credentials.logIn,
      password: credentials.password,
      // The DeviceInfoEntity is converted to a DeviceInfoModel here.
      deviceInfo: DeviceInfoModel.fromEntity(deviceInfo),
    );
  }

  /// Converts this model into the final JSON map for the API request body.
  ///
  /// This method composes the final payload, nesting the device information
  /// under a `device_info` key as per the API's expected structure.
  Map<String, dynamic> toJson() {
    return {
      'login': logIn,
      'password': password,
      // The nested structure is created here.
      'device_info': deviceInfo.toJson(),
    };
  }
}

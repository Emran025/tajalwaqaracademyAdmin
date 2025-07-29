// data/models/user_model.dart

import 'package:flutter/foundation.dart';
import 'package:tajalwaqaracademy/features/auth/data/models/user_model.dart';
import 'package:tajalwaqaracademy/features/auth/domain/entities/auth_response_entity.dart';

/// The data model for a successful authentication response from the API.
///
/// This class encapsulates all the data returned upon a successful login,
/// including the user's profile and the necessary session tokens. It is an
/// immutable object responsible for parsing the raw JSON and converting it
/// into a domain-layer [AuthResponseEntity].
@immutable
final class AuthResponseModel {
  /// The authenticated user's profile data.
  final UserModel user;

  /// The short-lived token for authenticating subsequent API requests.
  final String accessToken;

  /// The long-lived token used to obtain a new access token when the
  /// current one expires.
  final String refreshToken;

  const AuthResponseModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  /// A factory constructor for creating a new [AuthResponseModel] instance from a map.
  /// This is the primary entry point for parsing the login API response.
  /// 
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      // لاحظ أن أسماء الأعمدة في قاعدة البيانات المحلية تختلف (camelCase)
      
      user:  UserModel.fromJson(json['user']),
            accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
    );
  }

  /// دالة لتحويل UserModel إلى Map لتخزينه في قاعدة البيانات المحلية
  factory AuthResponseModel.fromDbMap(Map<String, dynamic> map) {
    // Check for the presence of the nested 'user' object.
    final userJson = map['user'] as Map<String, dynamic>?;
    if (userJson == null) {
      throw const FormatException("The 'user' object is missing in the auth response.");
    }
    
    return AuthResponseModel(
      // Delegate user parsing to the UserModel.
      user: UserModel.fromJson(userJson),
      accessToken: map['access_token'] as String? ?? '',
      refreshToken: map['refresh_token'] as String? ?? '',
    );
  }
  Map<String, dynamic> toDbMap() {
    return {'access_token': accessToken,'refreshToken':refreshToken , 'user': user.toJson()};
  }
  Map<String, dynamic> toJson() {
    return {'access_token': accessToken,'refreshToken':refreshToken , 'user': user.toJson()};
  }

  

  /// Converts this data model into a domain [AuthResponseEntity].
  ///
  /// This method serves as the boundary between the data and domain layers,
  /// transforming the data-centric model into a pure business object.
  AuthResponseEntity toEntity() {
    return AuthResponseEntity(
      // Delegate user model-to-entity conversion.
      user: user.toUserEntity(),
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}

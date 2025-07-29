// data/models/user_model.dart

import 'package:flutter/foundation.dart';
import 'package:tajalwaqaracademy/features/auth/domain/entities/user_entity.dart';

/// Represents the successful result of an authentication operation in the domain layer.
///
/// This is a pure, immutable business object that aggregates the authenticated
/// user's profile ([UserEntity]) and the necessary session tokens. It provides
/// the domain and presentation layers with all the necessary information to
/// proceed after a successful login.
///
/// It implements value equality manually.
@immutable
final class AuthResponseEntity {
  /// The authenticated user's profile data.
  final UserEntity user;

  /// The short-lived token for authenticating subsequent API requests.
  final String accessToken;

  /// The long-lived token used to obtain a new access token.
  final String refreshToken;

  const AuthResponseEntity({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthResponseEntity &&
        other.user == user &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken;
  }

  @override
  int get hashCode => user.hashCode ^ accessToken.hashCode ^ refreshToken.hashCode;
}

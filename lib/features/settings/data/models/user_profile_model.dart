// path: lib/features/settings/data/models/user_profile_model.dart

import 'package:tajalwaqaracademy/features/settings/domain/entities/user_profile_entity.dart';

import '../../../../core/models/user_role.dart';
import '../../../auth/data/models/user_model.dart';
import 'user_session_model.dart';

/// Represents the user profile data as it is structured for API communication.
///
/// This class extends [UserProfileModel] to inherit its structure and acts as
/// a Data Transfer Object (DTO). Its primary responsibilities are:
/// 1.  Deserializing JSON data from the API into a valid domain object.
/// 2.  Serializing the user's data into a JSON format suitable for update requests.
class UserProfileModel {
  /// The core, static identity of the user, reused from the authentication domain.
  /// This promotes the DRY (Don't Repeat Yourself) principle.
  final UserModel user;

  /// A list of all currently active login sessions for this user account.
  /// The list is ordered, typically with the most recent session first.
  final List<UserSessionModel> activeSessions;

  const UserProfileModel({required this.user, required this.activeSessions});

  /// Creates a [UserProfileModel] from a JSON map received from the API.
  ///
  /// This factory orchestrates the parsing of the entire profile response,
  /// delegating the parsing of nested objects (`user`, `active_sessions`)
  /// to their respective models. This adheres to the Single Responsibility Principle.
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      // The 'user' object is parsed using the existing UserModel from the Auth feature.
      user: UserModel.fromJson(json['user'], UserRole.teacher),
      // The 'active_sessions' list is parsed by mapping each JSON object
      // to a UserSessionModel.
      activeSessions: (json['active_sessions'] as List)
          .map((sessionJson) => UserSessionModel.fromJson(sessionJson))
          .toList(),
    );
  }

  
    /// A factory constructor to create a [UserSessionModel] from a [UserSessionEntity].
  /// This is useful when data flows from the domain layer back to the data layer.
  factory UserProfileModel.fromEntity(UserProfileEntity entity) {
    return UserProfileModel(
      user: UserModel(id: entity.user.id, name: entity.user.name, email: entity.user.email, phone: entity.user.phone, role: entity.user.role),
      activeSessions: entity.activeSessions.map((toElement)=> UserSessionModel.fromEntity(toElement)).toList(),

    );
  }

  /// Converts this model into a domain entity for use in the application.
  ///
  /// This method is the bridge that converts the data model into a domain object,
  UserProfileEntity toEntity() {
    return UserProfileEntity(
      user: user.toUserEntity(),
      activeSessions: activeSessions
          .map((toElement) => toElement.toEntity())
          .toList(),
    );
  }
  

  /// Converts the user's editable data to a JSON map for sending to the API.
  ///
  /// **Design Decision:** This method intentionally serializes *only* the `user`
  /// object. A client application should not be responsible for, or have the
  /// authority to, modify the list of active sessions. This is a security and
  /// design best practice. The `user` object is cast to `UserModel` to access
  /// its `toJson` method.
  Map<String, dynamic> toJson() {
    return {'user': (user).toJson()};
  }
}




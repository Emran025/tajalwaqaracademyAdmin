


import '../../../../core/api/end_ponits.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.token,
    required super.roleId,
    required super.status,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: json['token'],
      roleId: json['role_id'],
      status: json['status'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
    );
  }

  /// بيانات من الـ SQLite: camelCase
  factory UserModel.fromDbMap(Map<String, dynamic> map) {
    return UserModel(
      token: map['token'] as String,
      roleId: map['roleId'] as int,
      status: map['status'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    ApiKey.token: token,
    ApiKey.roleId: roleId,
    ApiKey.status: status,
    ApiKey.firstName: firstName,
    ApiKey.lastName: lastName,
    ApiKey.email: email,
    ApiKey.phone: phone,
  };
  UserEntity toUserEntity() {
    return UserEntity(token: token, roleId: roleId, status: status, firstName: firstName, lastName: lastName, email: email, phone: phone)
  ;}
}



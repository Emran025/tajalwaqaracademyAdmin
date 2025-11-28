// lib/features/auth/data/models/device_account_model.dart
import 'package.tajalwaqaracademy/features/auth/domain/entities/device_account_entity.dart';

class DeviceAccountModel extends DeviceAccountEntity {
  const DeviceAccountModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatar,
    required super.lastLogin,
  });

  factory DeviceAccountModel.fromEntity(DeviceAccountEntity entity) {
    return DeviceAccountModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      avatar: entity.avatar,
      lastLogin: entity.lastLogin,
    );
  }

  factory DeviceAccountModel.fromDbMap(Map<String, dynamic> map) {
    return DeviceAccountModel(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      avatar: map['avatar'] as String?,
      lastLogin: DateTime.fromMillisecondsSinceEpoch(map['lastLogin'] as int),
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'lastLogin': lastLogin.millisecondsSinceEpoch,
    };
  }
}

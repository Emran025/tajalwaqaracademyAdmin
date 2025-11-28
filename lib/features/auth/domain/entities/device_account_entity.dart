// lib/features/auth/domain/entities/device_account_entity.dart
import 'package:equatable/equatable.dart';

class DeviceAccountEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final DateTime lastLogin;

  const DeviceAccountEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.lastLogin,
  });

  @override
  List<Object?> get props => [id, name, email, avatar, lastLogin];
}

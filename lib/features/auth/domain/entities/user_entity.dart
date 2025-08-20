import '../../../../core/models/user_role.dart';

class UserEntity {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? avatar;
  final UserRole role;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatar,
  });
}

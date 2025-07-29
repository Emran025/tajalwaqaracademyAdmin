class UserEntity {
  final String token;
  final int roleId;
  final String status;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  const UserEntity({
    required this.token,
    required this.roleId,
    required this.status,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });
}


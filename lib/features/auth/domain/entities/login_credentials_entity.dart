/// Represents the essential credentials a user provides for authentication.
///
/// This is a pure domain entity that encapsulates the data directly provided
/// by the user for a login attempt. It is intentionally kept separate from
/// device information or other contextual data, adhering to the Single
/// Responsibility Principle.
///
final class LoginCredentialsEntity {
  /// The user's email address.
  /// In some systems, this could also be a username.
  final String email;

  /// The user's phone  Number.
  /// In some systems, this could also be a username.
  final String phone;

  /// The user's password.
  /// This should always be handled securely and never logged or stored in plaintext.
  final String password;

  const LoginCredentialsEntity({
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LoginCredentialsEntity &&
        other.email == email &&
        other.phone == phone &&
        other.password == password;
  }

  @override
  int get hashCode => email.hashCode ^ phone.hashCode ^ password.hashCode;
}

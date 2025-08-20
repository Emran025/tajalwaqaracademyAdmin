/// Represents the essential credentials a user provides for authentication.
///
/// This is a pure domain entity that encapsulates the data directly provided
/// by the user for a logIn attempt. It is intentionally kept separate from
/// device information or other contextual data, adhering to the Single
/// Responsibility Principle.
///
final class LogInCredentialsEntity {
  /// The user's email address.
  /// In some systems, this could also be a username.
  final String logIn;

  /// The user's password.
  /// This should always be handled securely and never logged or stored in plaintext.
  final String password;

  const LogInCredentialsEntity({required this.logIn, required this.password});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LogInCredentialsEntity && other.password == password;
  }

  @override
  int get hashCode => logIn.hashCode ^ password.hashCode;
}

part of 'auth_bloc.dart';

abstract class AuthEvent {}

class LogInRequested extends AuthEvent {
  final String logIn;
  final String password;

  LogInRequested({required this.logIn, required this.password});
}

class ForgetPasswordRequested extends AuthEvent {
  final String email;

  ForgetPasswordRequested({required this.email});
}

class AppStarted extends AuthEvent {}

/// Triggered when the user wants to view all saved accounts (e.g., opening the "Switch Account" modal).
class GetAllUsersRequested extends AuthEvent {}

class LogOutRequested extends AuthEvent {
  final String message;
  final bool deleteCredentials;

  LogOutRequested({required this.message, required this.deleteCredentials});
}
/// Triggered when the user taps on a specific account in the list to switch to it.
class SwitchUserRequested extends AuthEvent {
  final String userId;

  SwitchUserRequested({required this.userId});
}
class ChangePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });
}

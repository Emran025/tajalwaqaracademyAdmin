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

class LogOutRequested extends AuthEvent {
  final String message;

  LogOutRequested({required this.message});
}


class ChangePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });
}
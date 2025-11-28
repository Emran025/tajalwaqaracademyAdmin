// lib/features/auth/presentation/bloc/auth_event.dart
part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {}

class LoggedIn extends AuthEvent {
  final UserEntity user;

  const LoggedIn({required this.user});

  @override
  List<Object> get props => [user];
}

class LoggedOut extends AuthEvent {
  final int userId;

  const LoggedOut({required this.userId});

  @override
  List<Object> get props => [userId];
}

class LogInRequested extends AuthEvent {
  final String email;
  final String password;

  const LogInRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class ForgetPasswordRequested extends AuthEvent {
  final String email;

  const ForgetPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class ChangePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequested(
      {required this.currentPassword, required this.newPassword});

  @override
  List<Object> get props => [currentPassword, newPassword];
}

class GetDeviceAccounts extends AuthEvent {}

class LogInWithDeviceAccount extends AuthEvent {
  final int userId;

  const LogInWithDeviceAccount({required this.userId});

  @override
  List<Object> get props => [userId];
}

class RemoveDeviceAccount extends AuthEvent {
  final int userId;

  const RemoveDeviceAccount({required this.userId});

  @override
  List<Object> get props => [userId];
}

abstract class AuthEvent {}



class LoginRequested extends AuthEvent {

  final String login;
  final String password;

  LoginRequested({
    required this.login,
    required this.password,
  });
}
class ForgetPasswordRequested extends AuthEvent {

  final String email;

  ForgetPasswordRequested({
    required this.email
  });
}

class AppStarted extends AuthEvent {
}
class LogoutRequested extends AuthEvent {

  final String message;

  LogoutRequested({
    required this.message,
  });
}


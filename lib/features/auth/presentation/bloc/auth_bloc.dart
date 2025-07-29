import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/login_credentials_entity.dart';
import '../../domain/usecases/forget_password_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/check_login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUC;
  final CheckLoginUseCase checkLoginUC;
  final LogoutUseCase logoutUC;
  final ForgetPasswordUseCase forgetPasswordUC;

  AuthBloc(this.loginUC, this.checkLoginUC, this.logoutUC, this.forgetPasswordUC)
    : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(LoginLoading());
      final user = await loginUC(credentials:  LoginCredentialsEntity(email: event.login ,phone: event.login , password: event.password  ) );
      user.fold(
        (message) => emit(LoginFailure(message: message)),
        (userModle) => emit(LoginSuccess(userEntity: userModle)),
      );
    });
    on<ForgetPasswordRequested>((event, emit) async {
      emit(ForgetPasswordLoading());
      final user = await forgetPasswordUC(email: event.email);
      user.fold(
        (message) => emit(ForgetPasswordFailure(message: message)),
        (successEntity) => emit(ForgetPasswordSuccess(successEntity: successEntity)),
      );
    });

    on<AppStarted>((_, emit) async {
      emit(AuthLoading());
      final loggedIn = await checkLoginUC();
      emit(loggedIn ? AuthSuccess(auth: loggedIn) : AuthFailure());
    });

    // 3) حدث تسجيل الخروج
    on<LogoutRequested>((_, emit) async {
      emit(AuthLoading());
      await logoutUC(); // دالة تمسح user table أو توكن
      emit(AuthFailure());
    });
  }
}

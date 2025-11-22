import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/entities/success_entity.dart';
import '../../../../core/error/failures.dart';
// import '../../domain/entities/login_credentials_entity.dart';
import '../../domain/entities/login_credentials_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/forget_password_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/check_login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

part 'auth_state.dart';
part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LogInUseCase logInUC;
  final CheckLogInUseCase checkLogInUC;
  final LogOutUseCase logOutUC;
  final ForgetPasswordUseCase forgetPasswordUC;

  final ChangePasswordUseCase changePasswordUC;

  AuthBloc(
    this.logInUC,
    this.checkLogInUC,
    this.logOutUC,
    this.forgetPasswordUC,
    this.changePasswordUC,
  ) : super(AuthState()) {
    on<LogInRequested>(_onLogIn);

    on<ForgetPasswordRequested>(_onForgetPassword);

    on<AppStarted>(_appStarted);

    on<LogOutRequested>(_logOut);
    on<ChangePasswordRequested>(_onChangePassword);
  }
  void _appStarted(AppStarted event, Emitter<AuthState> emit) async {
    final loggedIn = await checkLogInUC();
    loggedIn.fold(
      (message) => emit(
        state.copyWith(
          authStatus: AuthStatus.unauthenticated,
          failure: ServerFailure(message: message.message),
          getUserFailure: ServerFailure(message: message.message),
        ),
      ),
      (userEntity) => emit(
        state.copyWith(
          authStatus: AuthStatus.authenticated,
          status: LogInStatus.success,
          user: userEntity,
          selectedUser: userEntity,
        ),
      ),
    );
  }

  void _onLogIn(LogInRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: LogInStatus.initial));
    final user = await logInUC(
      credentials: LogInCredentialsEntity(
        logIn: event.logIn,
        password: event.password,
      ),
    );
    user.fold(
      (message) => emit(
        state.copyWith(
          status: LogInStatus.failure,
          failure: ServerFailure(message: message.message),
          getUserFailure: ServerFailure(message: message.message),
        ),
      ),
      (userEntity) => emit(
        state.copyWith(
          status: LogInStatus.success,
          user: userEntity,
          selectedUser: userEntity,
          getUserStatus: GetUserStatus.success,
          authStatus: AuthStatus.authenticated,
        ),
      ),
    );
  }

  void _onForgetPassword(
    ForgetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(forgetPasswordStatus: ForgetPasswordStatus.initial));
    final user = await forgetPasswordUC(email: event.email);
    user.fold(
      (message) => emit(
        state.copyWith(
          forgetPasswordStatus: ForgetPasswordStatus.failure,
          failure: ServerFailure(message: message.message),
        ),
      ),
      (successEntity) => emit(
        state.copyWith(
          forgetPasswordStatus: ForgetPasswordStatus.success,
          successEntity: successEntity,
        ),
      ),
    );
  }

  void _onChangePassword(
    ChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(changePasswordStatus: ChangePasswordStatus.submitting));

    final result = await changePasswordUC(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          changePasswordStatus: ChangePasswordStatus.failure,
          changePasswordFailure: failure,
        ),
      ),
      (successEntity) => emit(
        state.copyWith(
          changePasswordStatus: ChangePasswordStatus.success,
          successEntity: successEntity,
        ),
      ),
    );
  }

  void _logOut(LogOutRequested event, Emitter<AuthState> emit) async {
    final logOutRequested = await logOutUC();
    logOutRequested.fold(
      (message) {
        if (message.message.contains('Token is invalid') ||
            message.message.contains('already revoked')) {
          emit(
            state.copyWith(
              authStatus: AuthStatus.unauthenticated,
              logOutFailure: null,
            ),
          );
        } else {
          emit(
            state.copyWith(
              logOutFailure: ServerFailure(message: message.message),
            ),
          );
        }
      },
      (successEntity) {
        emit(
          state.copyWith(
            authStatus: AuthStatus.unauthenticated,
            logOutFailure: null,
          ),
        );
      },
    );
  }
}

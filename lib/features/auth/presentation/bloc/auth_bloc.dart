// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tajalwaqaracademy/core/usecases/usecase.dart';
import 'package:tajalwaqaracademy/features/auth/domain/entities/device_account_entity.dart';
import 'package:tajalwaqaracademy/features/auth/domain/entities/login_credentials_entity.dart';
import 'package:tajalwaqaracademy/features/auth/domain/entities/user_entity.dart';
import 'package:tajalwaqaracademy/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:tajalwaqaracademy/features/auth/domain/usecases/check_login_usecase.dart';
import 'package:tajalwaqaracademy/features/auth/domain/usecases/forget_password_usecase.dart';
import 'package:tajalwaqaracademy/features/auth/domain/usecases/get_device_accounts_usecase.dart';
import 'package:tajalwaqaracademy/features/auth/domain/usecases/login_usecase.dart';
import 'package:tajalwaqaracademy/features/auth/domain/usecases/login_with_device_account_usecase.dart';
import 'package:tajalwaqaracademy/features/auth/domain/usecases/logout_usecase.dart';
import 'package:tajalwaqaracademy/features/auth/domain/usecases/remove_device_account_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LogInUseCase _logInUseCase;
  final CheckLogInUseCase _checkLogInUseCase;
  final LogOutUseCase _logOutUseCase;
  final ForgetPasswordUseCase _forgetPasswordUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final GetDeviceAccountsUseCase _getDeviceAccountsUseCase;
  final LogInWithDeviceAccountUseCase _logInWithDeviceAccountUseCase;
  final RemoveDeviceAccountUseCase _removeDeviceAccountUseCase;

  AuthBloc(
    this._logInUseCase,
    this._checkLogInUseCase,
    this._logOutUseCase,
    this._forgetPasswordUseCase,
    this._changePasswordUseCase,
    this._getDeviceAccountsUseCase,
    this._logInWithDeviceAccountUseCase,
    this._removeDeviceAccountUseCase,
  ) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<LoggedOut>(_onLoggedOut);
    on<LogInRequested>(_onLogInRequested);
    on<ForgetPasswordRequested>(_onForgetPasswordRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
    on<GetDeviceAccounts>(_onGetDeviceAccounts);
    on<LogInWithDeviceAccount>(_onLogInWithDeviceAccount);
    on<RemoveDeviceAccount>(_onRemoveDeviceAccount);
  }

  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final isLoggedIn = await _checkLogInUseCase(NoParams());
    if (isLoggedIn) {
      // This part might need to be adjusted based on how the user session is restored.
      // For now, we'll assume that if the user is logged in, we can get their profile.
      // A more robust implementation might involve fetching the user from local storage.
      emit(Authenticated(user: UserEntity.empty()));
    } else {
      add(GetDeviceAccounts());
    }
  }

  void _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) {
    emit(Authenticated(user: event.user));
  }

  void _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    await _logOutUseCase(LogOutParams(userId: event.userId));
    add(GetDeviceAccounts());
  }

  void _onLogInRequested(
      LogInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _logInUseCase(
      LogInParams(
        credentials: LogInCredentialsEntity(
          email: event.email,
          password: event.password,
        ),
      ),
    );
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  void _onForgetPasswordRequested(
      ForgetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _forgetPasswordUseCase(
      ForgetPasswordParams(email: event.email),
    );
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (_) => emit(Unauthenticated()), // Or a success state
    );
  }

  void _onChangePasswordRequested(
      ChangePasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _changePasswordUseCase(
      ChangePasswordParams(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      ),
    );
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (_) => emit(Authenticated(user: UserEntity.empty())), // Or a success state
    );
  }

  void _onGetDeviceAccounts(
      GetDeviceAccounts event, Emitter<AuthState> emit) async {
    final result = await _getDeviceAccountsUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (accounts) => emit(Unauthenticated(deviceAccounts: accounts)),
    );
  }

  void _onLogInWithDeviceAccount(
      LogInWithDeviceAccount event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _logInWithDeviceAccountUseCase(
      LogInWithDeviceAccountParams(userId: event.userId),
    );
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  void _onRemoveDeviceAccount(
      RemoveDeviceAccount event, Emitter<AuthState> emit) async {
    await _removeDeviceAccountUseCase(
        RemoveDeviceAccountParams(userId: event.userId));
    add(GetDeviceAccounts());
  }
}

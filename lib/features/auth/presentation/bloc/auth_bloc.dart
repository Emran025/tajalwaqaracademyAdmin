import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/entities/success_entity.dart';
import '../../../../core/error/failures.dart';
// import '../../domain/entities/login_credentials_entity.dart';
import '../../domain/entities/login_credentials_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/forget_password_usecase.dart';
import '../../domain/usecases/get_all_users_use_case.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/check_login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/switch_user_usecase.dart';

part 'auth_state.dart';
part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LogInUseCase logInUC;
  final CheckLogInUseCase checkLogInUC;
  final LogOutUseCase logOutUC;
  final ForgetPasswordUseCase forgetPasswordUC;

  final ChangePasswordUseCase changePasswordUC;
// Dependency Injection
  final GetAllUsersUseCase getAllUsersUC;
final SwitchUserUseCase switchUserUC;

  AuthBloc(
    this.logInUC,
    this.checkLogInUC,
    this.logOutUC,
    this.forgetPasswordUC,
    this.changePasswordUC,
    this.switchUserUC, // Add this
    this.getAllUsersUC,
  ) : super(AuthState()) {
    on<LogInRequested>(_onLogIn);

    on<ForgetPasswordRequested>(_onForgetPassword);

    on<AppStarted>(_appStarted);

    on<LogOutRequested>(_logOut);
    on<ChangePasswordRequested>(_onChangePassword);
    on<GetAllUsersRequested>(_onGetAllUsers);
    on<SwitchUserRequested>(_onSwitchUser); // Register handler

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

  /// Handles the request to fetch all locally cached users.
  /// 
  /// Emits [GetUserStatus.loading] initially, followed by either:
  /// - [GetUserStatus.success] with the list of users.
  /// - [GetUserStatus.failure] with the error details.
  void _onGetAllUsers(
    GetAllUsersRequested event,
    Emitter<AuthState> emit,
  ) async {
    // 1. Indicate that the list is being loaded.
    emit(state.copyWith(usersListStatus: GetUserStatus.loading));

    // 2. Execute the UseCase to fetch data from the local repository.
    final result = await getAllUsersUC();

    // 3. Handle the result (Either Failure or List<UserEntity>).
    result.fold(
      (failure) => emit(
        state.copyWith(
          usersListStatus: GetUserStatus.failure,
          usersListFailure: failure,
        ),
      ),
      (usersList) => emit(
        state.copyWith(
          usersListStatus: GetUserStatus.success,
          usersList: usersList,
        ),
      ),
    );
  }

  void _logOut(LogOutRequested event, Emitter<AuthState> emit) async {
    final logOutRequested = await logOutUC(deleteCredentials : event.deleteCredentials);
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

  /// Handles the user switching process.
  /// 
  /// When successful, it updates the [AuthState.user] to the new user
  /// and ensures [AuthState.authStatus] is authenticated.
  void _onSwitchUser(
    SwitchUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Optionally emit a loading state if you want to show a spinner during the switch
    // emit(state.copyWith(status: LogInStatus.loading)); 

    final result = await switchUserUC(userId: event.userId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          // You can use a specific failure field or the general one
          failure: failure,
          // If switching fails, we remain in the current state
        ),
      ),
      (newUserEntity) => emit(
        state.copyWith(
          // Update the current active user
          user: newUserEntity,
          selectedUser: newUserEntity,
          // Ensure the app knows we are authenticated
          authStatus: AuthStatus.authenticated,
          status: LogInStatus.success,
        ),
      ),
    );
  }
}

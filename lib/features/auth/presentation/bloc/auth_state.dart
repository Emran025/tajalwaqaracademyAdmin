part of 'auth_bloc.dart';

// Let's simplify the status enum for clarity
enum AuthStatus {
  initializing, // The initial state, while we are checking for a token.
  authenticated, // The user is logged in.
  unauthenticated, // The user is logged out or it's their first time.
}

// في auth_state.dart
enum ChangePasswordStatus { initial, submitting, success, failure }

enum LogInStatus { initial, loading, success, failure }

enum GetUserStatus { initial, loading, success, failure }

enum ForgetPasswordStatus { initial, submitting, success, failure }

final class AuthState extends Equatable {
  final AuthStatus authStatus;

  final LogInStatus status;
  final UserEntity? user;
  final Failure? failure;

  // --- Details State Properties (New) ---
  final GetUserStatus getUserStatus;
  final UserEntity? selectedUser;
  final Failure? getUserFailure;

  // --- Operation State (New) ---
  final Failure? logOutFailure;

  // --- Operation State (New) ---
  final ForgetPasswordStatus forgetPasswordStatus;
  final SuccessEntity? successEntity;
  final Failure? forgetPasswordFailure;
  //  AuthState
  final ChangePasswordStatus changePasswordStatus;
  final Failure? changePasswordFailure;

  /// The list of all users currently cached on the device.
  /// Used for the "Switch Account" feature.
  final List<UserEntity> usersList;

  /// The status of the operation to retrieve [usersList].
  final GetUserStatus usersListStatus;

  /// Holds the failure details if retrieving the [usersList] fails.
  final Failure? usersListFailure;
  const AuthState({
    this.authStatus = AuthStatus.initializing,
    this.status = LogInStatus.initial,
    this.user,
    this.failure,

    // New
    this.getUserStatus = GetUserStatus.initial,
    this.selectedUser,
    this.getUserFailure,

    // New
    this.logOutFailure,

    // New
    this.forgetPasswordStatus = ForgetPasswordStatus.initial,
    this.successEntity,
    this.forgetPasswordFailure,
    // New
    this.changePasswordStatus = ChangePasswordStatus.initial,
    this.changePasswordFailure,

    // Initialize new fields
    this.usersList = const [],
    this.usersListStatus = GetUserStatus.initial,
    this.usersListFailure,
  });

  AuthState copyWith({
    LogInStatus? status,
    AuthStatus? authStatus,
    UserEntity? user,
    Failure? failure,

    // New
    GetUserStatus? getUserStatus,
    UserEntity? selectedUser,
    Failure? getUserFailure,

    // New
    Failure? logOutFailure,

    // New
    ForgetPasswordStatus? forgetPasswordStatus,
    SuccessEntity? successEntity,
    Failure? forgetPasswordFailure,

    // New
    ChangePasswordStatus? changePasswordStatus,
    Failure? changePasswordFailure,
    // Add new parameters
    List<UserEntity>? usersList,
    GetUserStatus? usersListStatus,
    Failure? usersListFailure,
  }) {
    return AuthState(
      authStatus: authStatus ?? this.authStatus,
      status: status ?? this.status,
      user: user ?? this.user,
      failure: failure ?? this.failure,
      // New
      getUserStatus: getUserStatus ?? this.getUserStatus,
      selectedUser: selectedUser ?? this.selectedUser,
      getUserFailure: getUserFailure ?? this.getUserFailure,

      // New
      logOutFailure: logOutFailure ?? this.logOutFailure,

      // New
      forgetPasswordStatus: forgetPasswordStatus ?? this.forgetPasswordStatus,
      successEntity: successEntity ?? this.successEntity,
      forgetPasswordFailure:
          forgetPasswordFailure ?? this.forgetPasswordFailure,
      changePasswordStatus: changePasswordStatus ?? this.changePasswordStatus,
      changePasswordFailure:
          changePasswordFailure ?? this.changePasswordFailure,
      // Assign new fields
      usersList: usersList ?? this.usersList,
      usersListStatus: usersListStatus ?? this.usersListStatus,
      usersListFailure: usersListFailure ?? this.usersListFailure,
    );
  }

  @override
  List<Object?> get props => [
    authStatus,
    status,
    user,
    failure,
    getUserStatus,
    selectedUser,
    getUserFailure,
    logOutFailure,
    forgetPasswordStatus,
    successEntity,
    forgetPasswordFailure,

    changePasswordStatus,
    changePasswordFailure,

    usersList,
    usersListStatus,
    usersListFailure,
  ];
}

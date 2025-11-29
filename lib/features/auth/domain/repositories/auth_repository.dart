import 'package:dartz/dartz.dart';
import '../../../../core/entities/success_entity.dart';
import '../../../../core/error/failures.dart';
import '../entities/login_credentials_entity.dart';
import '../entities/user_entity.dart';
// features/auth/domain/repositories/auth_repository.dart

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> logIn({
    required LogInCredentialsEntity credentials,
  });

  Future<Either<Failure, SuccessEntity>> forgetPassword({
    required String email,
  });

  Future<Either<Failure, UserEntity>> getUserProfile();

  Future<Either<Failure, SuccessEntity>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<String> isLoggedIn();
  Future<Either<Failure, SuccessEntity>> logOut({
    required bool deleteCredentials,
  });

  /// Retrieves a list of all locally cached users.
  Future<Either<Failure, List<UserEntity>>> getAllUsers();

  /// Switches the active session to the user identified by [userId].
  ///
  /// Returns the [UserEntity] of the newly selected user upon success.
  Future<Either<Failure, UserEntity>> switchUser({required String userId});
}

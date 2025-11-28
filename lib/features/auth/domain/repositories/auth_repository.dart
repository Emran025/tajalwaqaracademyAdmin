// features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:tajalwaqaracademy/features/auth/domain/entities/device_account_entity.dart';
import '../../../../core/entities/success_entity.dart';
import '../../../../core/error/failures.dart';
import '../entities/login_credentials_entity.dart';
import '../entities/user_entity.dart';

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

  Future<bool> isLoggedIn();

  Future<Either<Failure, SuccessEntity>> logOut(int userId);

  /// --- Multi-User Management ---

  Future<Either<Failure, List<DeviceAccountEntity>>> getDeviceAccounts();

  Future<Either<Failure, SuccessEntity>> removeDeviceAccount(int userId);

  Future<Either<Failure, UserEntity>> logInWithDeviceAccount(int userId);
}

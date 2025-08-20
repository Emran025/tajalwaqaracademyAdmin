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

  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String phoneNumber,
    required String whatsappNumber,
    required String name,
    required String gender,
    required String birthDate,
    required String birthContery,
    required String birthStates,
    required String birthCity,
    required String profileImagePath,
    required String role,
    required String token,
    required String currentAddress,
  });

  Future<Either<Failure, SuccessEntity>> forgetPassword({
    required String email,
  });

  Future<Either<Failure, UserEntity>> getUserProfile();

  Future<bool> isLoggedIn();
  Future<Either<Failure, SuccessEntity>> logOut();
}

// lib/features/auth/data/repositories_impl/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:tajalwaqaracademy/core/error/exceptions.dart';
import 'package.dart';
import 'package:tajalwaqaracademy/core/error/failures.dart';
import 'package:tajalwaqaracademy/core/network/network_info.dart';
import 'package:tajalwaqaracademy/core/services/device_info_service.dart';
import 'package:tajalwaqaracademy/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:tajalwaqaracademy/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:tajalwaqaracademy/features/auth/data/models/auth_response_model.dart';
import 'package:tajalwaqaracademy/features/auth/data/models/device_account_model.dart';
import 'package:tajalwaqaracademy/features/auth/data/models/login_request_model.dart';
import 'package:tajalwaqaracademy/features/auth/domain/entities/auth_response_entity.dart';
import 'package:tajalwaqaracademy/features/auth/domain/entities/device_account_entity.dart';
import 'package:tajalwaqaracademy/features/auth/domain/entities/login_credentials_entity.dart';
import 'package:tajalwaqaracademy/features/auth/domain/entities/user_entity.dart';
import 'package:tajalwaqaracademy/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/entities/success_entity.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final DeviceInfoService deviceInfoService;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.deviceInfoService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> logIn({
    required LogInCredentialsEntity credentials,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final deviceInfo = await deviceInfoService.getDeviceInfo();
        final loginRequest = LoginRequestModel.fromEntity(
          credentials,
          deviceInfo,
        );
        final authResponse = await remoteDataSource.logIn(loginRequest);
        await _handleSuccessfulLogin(authResponse);
        return Right(authResponse.user);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, SuccessEntity>> forgetPassword({
    required String email,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.forgetPassword(email);
        return Right(SuccessEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserProfile() async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.getUserProfile();
        await localDataSource.cacheUser(user);
        return Right(user);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final user = await localDataSource.getUser();
        if (user != null) {
          return Right(user);
        } else {
          return const Left(CacheFailure());
        }
      } on CacheException {
        return const Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, SuccessEntity>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.changePassword(currentPassword, newPassword);
        return Right(SuccessEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(OfflineFailure());
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await localDataSource.isLoggedIn();
  }

  @override
  Future<Either<Failure, SuccessEntity>> logOut(int userId) async {
    try {
      await localDataSource.clear(userId);
      return Right(SuccessEntity());
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<DeviceAccountEntity>>> getDeviceAccounts() async {
    try {
      final accounts = await localDataSource.getDeviceAccounts();
      return Right(accounts);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, SuccessEntity>> removeDeviceAccount(
      int userId) async {
    try {
      await localDataSource.removeDeviceAccount(userId);
      return Right(SuccessEntity());
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> logInWithDeviceAccount(
      int userId) async {
    if (await networkInfo.isConnected) {
      try {
        final accessToken = await localDataSource.getAccessToken(userId);
        if (accessToken != null) {
          // Assuming the remote data source has a method to log in with a token.
          // If not, you might need to fetch the user profile or perform another action.
          final authResponse =
              await remoteDataSource.logInWithToken(accessToken);
          await _handleSuccessfulLogin(authResponse);
          return Right(authResponse.user);
        } else {
          return const Left(CacheFailure(message: 'Access token not found.'));
        }
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(OfflineFailure());
    }
  }

  Future<void> _handleSuccessfulLogin(AuthResponseModel authResponse) async {
    await localDataSource.cacheAuthTokens(
      userId: authResponse.user.id,
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    );
    await localDataSource.cacheUser(authResponse.user);
    final deviceAccount = DeviceAccountModel(
      id: authResponse.user.id,
      name: authResponse.user.name,
      email: authResponse.user.email,
      avatar: authResponse.user.avatar,
      lastLogin: DateTime.now(),
    );
    await localDataSource.saveDeviceAccount(deviceAccount);
  }
}

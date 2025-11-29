// features/auth/data/repositories_impl/auth_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../../../core/entities/success_entity.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_request_model.dart';
import '../models/user_model.dart';

import 'package:injectable/injectable.dart';

import 'package:tajalwaqaracademy/core/network/network_info.dart';
import 'package:tajalwaqaracademy/core/services/device_info_service.dart';
import 'package:tajalwaqaracademy/features/auth/domain/entities/login_credentials_entity.dart';

/// Orchestrates calls to [AuthRemoteDataSource], catches any
/// [ServerException], and exposes a clean [Either]<String, T> API.
/// Coordinates remote + local sources, and exposes
/// a clean Either<String,T> API for network calls,
/// plus async getters for cached data.

/// The concrete implementation of the [AuthRepository] contract.
///
/// This repository orchestrates the authentication flow by coordinating between
/// remote and local data sources, handling network status, and managing data
/// transformations and error handling.
@LazySingleton(as: AuthRepository)
final class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource
  _localDataSource; // For caching tokens and user data
  final DeviceInfoService _deviceInfoService;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required DeviceInfoService deviceInfoService,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _deviceInfoService = deviceInfoService,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, UserEntity>> logIn({
    required LogInCredentialsEntity credentials,
  }) async {
    // This is the "wrapper" function that handles exceptions and network state.
    // It takes a function `body` which contains the core logic.
    return await _executeAuthOperation(() async {
      // 1. Gather all necessary device information.
      final deviceInfo = await _deviceInfoService.getDeviceInfo();

      // 2. Create the complete request model from the domain entities.
      final logInRequestModel = LogInRequestModel.fromEntities(
        credentials: credentials,
        deviceInfo: deviceInfo,
      );

      // 3. Execute the remote call.
      final authResponseModel = await _remoteDataSource.logIn(
        requestModel: logInRequestModel,
      );

      // 4. Perform side effects: Cache the tokens and user data upon successful logIn.
      await _localDataSource.cacheUser(authResponseModel.user);

      await _localDataSource.cacheAuthTokens(
        accessToken: authResponseModel.accessToken,
        refreshToken: authResponseModel.refreshToken,
      );

      // 5. Convert the result model back to a domain entity to return success.
      return authResponseModel.user.toUserEntity();
    });
  }

  /// A high-order function to wrap repository calls.
  ///
  /// It centralizes boilerplate logic such as network checking and exception-to-failure
  /// translation, keeping the primary repository methods clean and focused on their
  /// specific logic.
  ///
  /// - [body]: A function that contains the core data-fetching and processing logic.
  Future<Either<Failure, T>> _executeAuthOperation<T>(
    Future<T> Function() body,
  ) async {
    // A. Pre-execution check: Fail fast if there is no internet connection.
    // if (!await _networkInfo.isConnected) {
    //   return Left( 'No internet connection available.');
    // }

    try {
      // B. Execute the main logic.
      final result = await body();
      return Right(result);
    } on ServerException catch (e) {
      return Left(DataFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, SuccessEntity>> forgetPassword({
    required String email,
  }) async {
    final either = await _executeAuthOperation(
      () => _remoteDataSource.forgetPassword(email: email),
    );
    either.fold((failure) => null, (user) => null);

    return either.map((successModel) {
      final successEntity = successModel.toEntity();

      return successEntity;
    });
  }

  @override
  Future<Either<Failure, SuccessEntity>> logOut({
    required bool deleteCredentials,
  }) async {
    // LogOut is primarily a local operation. It clears all session data.
    // We don't need the _executeApiCall wrapper unless the API requires
    // an explicit "invalidate token" call. For now, we assume it's local.
    try {
      if (deleteCredentials) {
        final either = await _executeAuthOperation(
          () => _remoteDataSource.logOut(),
        );
        either.fold((failure) => null, (user) => null);
        // We call the `clear` method to remove all authentication data,
        // including tokens and the cached user profile.
        await _localDataSource.clear();
        return either.map((successModel) {
          final successEntity = successModel.toEntity();

          return successEntity;
        });
      } else {
        try {
          return Right(SuccessEntity());
        } on CacheException catch (e) {
          // If clearing the cache fails, we return a CacheFailure.
          return Left(CacheFailure(message: e.message));
        }
      }
    } on CacheException catch (e) {
      // If clearing the cache fails, we return a CacheFailure.
      return Left(CacheFailure(message: e.message));
    }
  }

  /// Returns the most recently cached user, or throws [CacheException]
  /// if no user is cached.
  /// - Returns: The cached [UserModel] if available.
  @override
  Future<Either<Failure, UserEntity>> getUserProfile() async {
    bool isLoggedin = await isLoggedIn();
    if (!isLoggedin) {
      return Left(CacheFailure(message: 'Failed to get User Profile.'));
    }
    final user = await _localDataSource.getUser();
    if (user == null) {
      throw CacheException(message: 'Failed to get User Profile.');
    }
    return Right(user.toUserEntity());
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getAllUsers() async {
    try {
      // 1. Fetch user models from the local data source.
      // Ensure your AuthLocalDataSource has the 'getAllCachedUsers' method.
      final userModels = await _localDataSource.getAllCachedUsers();

      // 2. Map the models to domain entities.
      final userEntities = userModels
          .map((userModel) => userModel.toUserEntity())
          .toList();

      return Right(userEntities);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to load users list: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, SuccessEntity>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _executeAuthOperation(() async {
      final successModel = await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return successModel.toEntity();
    });
  }
@override
  Future<Either<Failure, UserEntity>> switchUser({required String userId}) async {
    try {
      // 1. Update the 'Current User' pointer in local storage.
      // Ensure AuthLocalDataSource has the 'switchUser' method.
      await _localDataSource.switchUser(userId);

      // 2. Retrieve the full profile of the newly selected user.
      final userModel = await _localDataSource.getUser();
      
      if (userModel == null) {
        return Left(CacheFailure(message: 'User switched, but profile data is missing.'));
      }

      // 3. Return the new user entity so the UI can update immediately.
      return Right(userModel.toUserEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to switch user: ${e.toString()}'));
    }
  }
  /// Checks if the user is logged in by verifying if a user exists in the cache.
  /// This method is used to determine if the user has an active session.
  /// - Returns: `true` if the user is logged in, `false` otherwise.
  @override
  Future<bool> isLoggedIn() => _localDataSource.isLoggedIn();
}

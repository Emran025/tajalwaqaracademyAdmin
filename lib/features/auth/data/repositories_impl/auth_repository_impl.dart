// features/auth/data/repositories_impl/auth_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../../../core/entities/success_entity.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

import 'package:injectable/injectable.dart';


import 'package:tajalwaqaracademy/core/network/network_info.dart';
import 'package:tajalwaqaracademy/core/services/device_info_service.dart';
import 'package:tajalwaqaracademy/features/auth/data/models/login_request_model.dart';
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
  final AuthLocalDataSource _localDataSource; // For caching tokens and user data
  final DeviceInfoService _deviceInfoService;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required DeviceInfoService deviceInfoService,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _deviceInfoService = deviceInfoService,
        _networkInfo = networkInfo;

  @override
  Future<Either<String, UserEntity>> login( { required
    LoginCredentialsEntity credentials }
  ) async {
    // This is the "wrapper" function that handles exceptions and network state.
    // It takes a function `body` which contains the core logic.
    return await _executeAuthOperation(() async {
      // 1. Gather all necessary device information.
      final deviceInfo = await _deviceInfoService.getDeviceInfo();

      // 2. Create the complete request model from the domain entities.
      final loginRequestModel = LoginRequestModel.fromEntities(
        credentials: credentials,
        deviceInfo: deviceInfo,
      );

      // 3. Execute the remote call.
      final authResponseModel = await _remoteDataSource.login( requestModel :loginRequestModel);

      // 4. Perform side effects: Cache the tokens and user data upon successful login.
      await _localDataSource.cacheAuthTokens(
        accessToken: authResponseModel.accessToken,
        refreshToken: authResponseModel.refreshToken,
      );
      await _localDataSource.cacheUser(authResponseModel.user);

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
  Future<Either<String, T>> _executeAuthOperation<T>(
    Future<T> Function() body,
  ) async {
    // A. Pre-execution check: Fail fast if there is no internet connection.
    if (!await _networkInfo.isConnected) {
      return Left( 'No internet connection available.');
    }

    try {
      // B. Execute the main logic.
      final result = await body();
      return Right(result);
     
      
      
    } on ServerException catch (e) {
      return Left(e.errorModel.message);
    }
  }



    @override
  Future<Either<String, UserEntity>> signUp({
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
  }) async {
    final either = await _executeAuthOperation(
      () => _remoteDataSource.signUp(
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        whatsappNumber: whatsappNumber,
        name: name,
        gender: gender,
        birthDate: birthDate,
        birthContery: birthContery,
        birthStates: birthStates,
        birthCity: birthCity,
        profileImagePath: profileImagePath,
        role: role,
        token: token,
        currentAddress: currentAddress,
      ),
    );
    either.fold((failure) => null, (user) => _localDataSource.cacheUser(user));
    return either.map((userModel) {
      final userEntity = userModel.toUserEntity();
      _localDataSource.cacheUser(userModel);
      return userEntity;
    });
  }

  @override
  Future<Either<String, SuccessEntity>> forgetPassword({
    required String email,
  }) async {
    final either = await _executeAuthOperation(() => _remoteDataSource.forgetPassword(email: email));
    either.fold((failure) => null, (user) => null);

    return either.map((successModel) {
      final successEntity = successModel.toEntity();

      return successEntity;
    });
  }

  /// Returns the most recently cached user, or throws [CacheException]
  /// if no user is cached.
  /// - Returns: The cached [UserModel] if available.
  @override
  Future<UserModel> getUserProfile() async {
    final user = await _localDataSource.getUser();
    if (user == null) {
      throw CacheException(message: 'Failed to get User Profile.');
    }
    return user;
  }


  /// Checks if the user is logged in by verifying if a user exists in the cache.
  /// This method is used to determine if the user has an active session.
  /// - Returns: `true` if the user is logged in, `false` otherwise.
  @override
  Future<bool> isLoggedIn() {
    // The session is considered active if the user key exists.

    return _localDataSource.isLoggedIn();
  }

  @override

  @override
  Future<Either<String, Unit>> logout() async {
    // Logout is primarily a local operation. It clears all session data.
    // We don't need the _executeApiCall wrapper unless the API requires
    // an explicit "invalidate token" call. For now, we assume it's local.
    try {
      // We call the `clear` method to remove all authentication data,
      // including tokens and the cached user profile.
      await _localDataSource.clear();
      
      // 'unit' is a special value from dartz representing a void success.
      return const Right(unit);
    } on CacheException catch (e) {
      // If clearing the cache fails, we return a CacheFailure.
      return Left( e.message);
    }
  }

}
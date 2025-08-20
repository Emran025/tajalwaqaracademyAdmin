// path: lib/features/settings/data/repositories/settings_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../shared/themes/app_theme.dart';
import '../../domain/entities/privacy_policy_entity.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';
import '../datasources/settings_remote_data_source.dart';

/// The concrete implementation of the [SettingsRepository] contract.
///
/// This class orchestrates data operations by delegating tasks to specific
/// data sources. It is responsible for:
/// 1.  Deciding whether to fetch data from a local or remote source.
/// 2.  Checking for network connectivity before making remote calls.
/// 3.  Catching exceptions from the data sources and converting them into
///     domain-layer-friendly [Failure] objects.
/// 4.  (If needed) Converting data models from the data layer into domain entities.
@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;
  final SettingsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  /// Constructs a [SettingsRepositoryImpl].
  ///
  /// It requires abstractions of its data sources and network info,
  /// adhering to Dependency Injection principles.
  SettingsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  // --- LOCAL DATA OPERATIONS ---

  @override
  Future<Either<Failure, SettingsEntity>> getSettings() async {
    try {
      final settings = await localDataSource.getSettings();
      return Right(settings);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveTheme(AppThemeType themeType) async {
    try {
      await localDataSource.saveTheme(themeType);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> setAnalyticsPreference(bool isEnabled) async {
    try {
      await localDataSource.setAnalyticsPreference(isEnabled);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> setNotificationsPreference(
    bool isEnabled,
  ) async {
    try {
      await localDataSource.setNotificationsPreference(isEnabled);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  // --- REMOTE DATA OPERATIONS ---

  @override
  Future<Either<Failure, UserProfileEntity>> getUserProfile() async {
    return await _getRemoteData<UserProfileEntity>(
      () => remoteDataSource.getUserProfile().then((model) => model.toEntity()),
    );
  }

  @override
  Future<Either<Failure, void>> updateUserProfile(
    UserProfileEntity profile,
  ) async {
    return await _getRemoteData<void>(
      () => remoteDataSource.updateUserProfile(profile),
    );
  }

  /// Fetches the latest privacy policy using a "remote-first with cache-fallback" strategy.
  ///
  /// This method first attempts to retrieve the policy from the remote server to ensure
  /// the user has the most up-to-date version. If the remote call is successful,
  /// it updates the local cache in the background. If the remote call fails
  /// (e.g., due to a server error or lack of internet), it gracefully falls back
  /// to loading the policy from the local cache.
  @override
  Future<Either<Failure, PrivacyPolicyEntity>> getLatestPolicy() async {
    if (await networkInfo.isConnected) {
      try {
        // 1. Attempt to fetch from the remote data source.
        final remotePolicyModel = await remoteDataSource.getLatestPolicy();

        // 2. If successful, save the fresh data to the local cache.
        //    This is a "fire and forget" operation; we don't await it, and we
        //    catch potential errors to prevent them from crashing the main flow.
        localDataSource.savePolicy(remotePolicyModel).catchError((_) {
          // Optional: Log this error to a monitoring service.
          // For now, we fail silently as the user has already received the data.
        });

        // 3. Map the data model to a domain entity and return success.
        return Right(remotePolicyModel.toEntity());
      } on ServerException catch (e) {
        // 4. A server error occurred. Fall back to the local cache.
        return _getPolicyFromLocalCache(
          fallbackFailure: ServerFailure(
            message: e.message,
            statusCode: e.statusCode,
          ),
        );
      }
    } else {
      // 5. No internet connection. Go directly to the local cache.
      return _getPolicyFromLocalCache(
        fallbackFailure: NetworkFailure(
          message: 'No internet connection detected.',
        ),
      );
    }
  }

  /// Private helper to fetch the policy from the local cache and handle errors.
  ///
  /// This reduces code duplication for the cache-access logic.
  /// It takes a [fallbackFailure] to return if the cache is also empty,
  /// ensuring the original error context (Network or Server) is preserved.
  Future<Either<Failure, PrivacyPolicyEntity>> _getPolicyFromLocalCache({
    required Failure fallbackFailure,
  }) async {
    try {
      final localPolicyModel = await localDataSource.getLatestPolicy();
      return Right(localPolicyModel.toEntity());
    } on CacheException {
      // The cache is also empty. Return the original failure that led us here.
      return Left(fallbackFailure);
    }
  }

  /// A generic helper method to handle all remote data calls.
  ///
  /// This private utility encapsulates the boilerplate logic of checking network
  /// connectivity and handling `ServerException`s, making the public methods
  /// cleaner and more readable (DRY principle).
  Future<Either<Failure, T>> _getRemoteData<T>(
    Future<T> Function() call,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await call();
        return Right(result);
      } on ServerException catch (e) {
        return Left(
          ServerFailure(message: e.message, statusCode: e.statusCode),
        );
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection detected.'));
    }
  }
}

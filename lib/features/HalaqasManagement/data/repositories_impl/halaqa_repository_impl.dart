import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/models/active_status.dart';
import '../../../../core/models/report_frequency.dart';
import '../../domain/entities/halaqa_entity.dart';
import '../../domain/entities/halaqa_list_item_entity.dart';
import '../../domain/repositories/halaqa_repository.dart';
import '../datasources/halaqa_local_data_source.dart';
import '../models/halaqa_model.dart';
import '../services/halaqa_sync_service.dart';

@LazySingleton(as: HalaqaRepository)
final class HalaqaRepositoryImpl implements HalaqaRepository {
  final HalaqaLocalDataSource _localDataSource;
  final HalaqaSyncService _syncService;
  // NetworkInfo is not needed here anymore as SyncService handles it.

  HalaqaRepositoryImpl({
    required HalaqaLocalDataSource localDataSource,
    required HalaqaSyncService syncService,
  }) : _localDataSource = localDataSource,
       _syncService = syncService;

  @override
  Stream<Either<Failure, List<HalaqaListItemEntity>>> getHalaqas({
    bool forceRefresh = true,
  }) {
    print('Fetching halaqas with forceRefresh: $forceRefresh');

    // 1. If a refresh is forced, trigger the sync immediately.
    //    Otherwise, the sync might be triggered by other mechanisms (e.g., background job).
    if (forceRefresh) {
      _syncService.performSync();
    }

    // 2. Immediately return a stream connected to the local database.
    return _localDataSource
        .watchAllHalaqas()
        .map((halaqaModels) {
          final entities = halaqaModels
              .map((model) => model.toListItemEntity())
              .toList();
          return Right<Failure, List<HalaqaListItemEntity>>(entities);
        })
        .handleError(
          (error) => Left<Failure, List<HalaqaListItemEntity>>(
            CacheFailure(message: error.toString()),
          ),
        );
  }

  @override
  Future<Either<Failure, Unit>> fetchMoreHalaqas({required int page}) async {
    try {
      // For "load more", we explicitly trigger the sync service for the next page.
      await _syncService.performSync(initialPage: page);
      return const Right(unit);
    } catch (e) {
      return Left(NetworkFailure(message: 'Failed to load more halaqas.'));
    }
  }
  @override

  @override
  Future<Either<Failure, List<HalaqaListItemEntity>>> getHalaqasByStudentCriteria({
    ActiveStatus? studentStatus,
    DateTime? trackDate,
    Frequency? frequencyCode,
   }) async {
    // This method would typically fetch from the local data source first,
    // then potentially trigger a targeted remote fetch if needed.
    try {
      final model = await _localDataSource.getHalaqasByStudentCriteria(
        studentStatus: studentStatus,
        trackDate: trackDate,
        frequencyCode: frequencyCode,
      );

      return Right(
        model.map((toElement) => toElement.toListItemEntity()).toList(),
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, HalaqaDetailEntity>> upsertHalaqa(
    HalaqaDetailEntity halaqa,
  ) async {
    try {
      // 1. Convert the domain entity to a data model.
      final model = HalaqaModel.fromEntity(halaqa);

      // 2. Immediately save to the local DB for instant UI feedback.
      await _localDataSource.upsertHalaqa(model);

      // 3. Queue the operation for the next sync cycle.
      await _localDataSource.queueSyncOperation(
        uuid: halaqa.id,
        operation: 'upsert',
        payload: model.toDbMap(),
      );

      // 4. Trigger a sync attempt in the background.
      _syncService.performSync();

      // 5. Return the updated entity.
      return Right(halaqa);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteHalaqa(String halaqaId) async {
    try {
      // 1. Perform a soft delete locally for instant UI update.
      await _localDataSource.deleteHalaqa(halaqaId);

      // 2. Queue the delete operation for the sync engine.
      await _localDataSource.queueSyncOperation(
        uuid: halaqaId,
        operation: 'delete',
      );

      // 3. Trigger a background sync.
      _syncService.performSync();

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, HalaqaDetailEntity>> getHalaqaById(
    String halaqaId,
  ) async {
    // This method would typically fetch from the local data source first,
    // then potentially trigger a targeted remote fetch if needed.
    try {
      final model = await _localDataSource.getHalaqaById(halaqaId);
      return Right(model.toDetailEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  /// Returns [Right(unit)] on success, or a [Left(Failure)] on error.
  @override
  Future<Either<Failure, Unit>> setHalaqaStatus({
    required String halaqaId,
    required ActiveStatus newStatus,
  }) async {
    return const Right(unit);
  }
}

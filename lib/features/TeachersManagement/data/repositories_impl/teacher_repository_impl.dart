import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/models/active_status.dart';
import '../../domain/entities/teacher_entity.dart';
import '../../domain/entities/teacher_list_item_entity.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../datasources/teacher_local_data_source.dart';
import '../models/teacher_model.dart';
import '../services/teacher_sync_service.dart';

@LazySingleton(as: TeacherRepository)
final class TeacherRepositoryImpl implements TeacherRepository {
  final TeacherLocalDataSource _localDataSource;
  final TeacherSyncService _syncService;
  // NetworkInfo is not needed here anymore as SyncService handles it.

  TeacherRepositoryImpl({
    required TeacherLocalDataSource localDataSource,
    required TeacherSyncService syncService,
  }) : _localDataSource = localDataSource,
       _syncService = syncService;

  @override
  Stream<Either<Failure, List<TeacherListItemEntity>>> getTeachers({
    bool forceRefresh = true,
  }) {
    print('Fetching teachers with forceRefresh: $forceRefresh');

    // 1. If a refresh is forced, trigger the sync immediately.
    //    Otherwise, the sync might be triggered by other mechanisms (e.g., background job).
    if (forceRefresh) {
      _syncService.performSync();
    }

    // 2. Immediately return a stream connected to the local database.
    return _localDataSource
        .watchAllTeachers()
        .map((teacherModels) {
          final entities = teacherModels
              .map((model) => model.toListItemEntity())
              .toList();

          return Right<Failure, List<TeacherListItemEntity>>(entities);
        })
        .handleError(
          (error) => Left<Failure, List<TeacherListItemEntity>>(
            CacheFailure(message: error.toString()),
          ),
        );
  }

  @override
  Future<Either<Failure, Unit>> fetchMoreTeachers({required int page}) async {
    try {
      // For "load more", we explicitly trigger the sync service for the next page.
      await _syncService.performSync(initialPage: page);
      return const Right(unit);
    } catch (e) {
      return Left(NetworkFailure(message: 'Failed to load more teachers.'));
    }
  }

  @override
  Future<Either<Failure, TeacherDetailEntity>> upsertTeacher(
    TeacherDetailEntity teacher,
  ) async {
    try {
      // 1. Convert the domain entity to a data model.
      final model = TeacherModel.fromEntity(teacher);

      // 2. Immediately save to the local DB for instant UI feedback.
      await _localDataSource.upsertTeacher(model);

      // 3. Queue the operation for the next sync cycle.
      await _localDataSource.queueSyncOperation(
        uuid: teacher.id,
        operation: 'upsert',
        payload: model.toDbMap(),
      );

      // 4. Trigger a sync attempt in the background.
      _syncService.performSync();

      // 5. Return the updated entity.
      return Right(teacher);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTeacher(String teacherId) async {
    try {
      // 1. Perform a soft delete locally for instant UI update.
      await _localDataSource.deleteTeacher(teacherId);

      // 2. Queue the delete operation for the sync engine.
      await _localDataSource.queueSyncOperation(
        uuid: teacherId,
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
  Future<Either<Failure, TeacherDetailEntity>> getTeacherById(
    String teacherId,
  ) async {
    // This method would typically fetch from the local data source first,
    // then potentially trigger a targeted remote fetch if needed.
    try {
      final model = await _localDataSource.getTeacherById(teacherId);

      return Right(model.toDetailEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  /// Returns [Right(unit)] on success, or a [Left(Failure)] on error.
  @override
  Future<Either<Failure, Unit>> setTeacherStatus({
    required String teacherId,
    required ActiveStatus newStatus,
  }) async {
    return const Right(unit);
  }
}

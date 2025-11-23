import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/models/report_frequency.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/entities/student_info_entity.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/models/active_status.dart';
import '../../domain/entities/follow_up_plan_entity.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/student_list_item_entity.dart';
import '../../domain/entities/tracking_entity.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_local_data_source.dart';
import '../datasources/student_remote_data_source.dart';
import '../models/follow_up_plan_model.dart';
import '../models/student_model.dart';
import '../models/tracking_model.dart';
import '../services/student_sync_service.dart';

@LazySingleton(as: StudentRepository)
final class StudentRepositoryImpl implements StudentRepository {
  final StudentLocalDataSource _localDataSource;
  final StudentSyncService _syncService;
  // NetworkInfo is not needed here anymore as SyncService handles it.

  StudentRepositoryImpl({
    required StudentLocalDataSource localDataSource,
    required StudentRemoteDataSource remoteDataSource,
    required StudentSyncService syncService,
  }) : _localDataSource = localDataSource,
       _syncService = syncService;

  @override
  Stream<Either<Failure, List<StudentListItemEntity>>> getStudents({
    bool forceRefresh = true,
  }) {
    // 1. If a refresh is forced, trigger the sync immediately.
    //    Otherwise, the sync might be triggered by other mechanisms (e.g., background job).
    if (forceRefresh) {
      _syncService.performSync();
    }

    // 2. Immediately return a stream connected to the local database.
    return _localDataSource
        .watchAllStudents()
        .map((studentModels) {
          final entities = studentModels
              .map((model) => model.toListItemEntity())
              .toList();
          return Right<Failure, List<StudentListItemEntity>>(entities);
        })
        .handleError(
          (error) => Left<Failure, List<StudentListItemEntity>>(
            CacheFailure(message: error.toString()),
          ),
        );
  }

  @override
  Future<Either<Failure, Unit>> fetchMoreStudents({required int page}) async {
    try {
      // For "load more", we explicitly trigger the sync service for the next page.
      await _syncService.performSync(initialPage: page);
      return const Right(unit);
    } catch (e) {
      return Left(NetworkFailure(message: 'Failed to load more students.'));
    }
  }

  @override
  Future<Either<Failure, StudentDetailEntity>> upsertStudent(
    StudentDetailEntity student,
  ) async {
    try {
      // 1. Convert the domain entity to a data model.
      final model = StudentModel.fromEntity(student);

      // 2. Immediately save to the local DB for instant UI feedback.
      await _localDataSource.upsertStudent(model);

      // 3. Queue the operation for the next sync cycle.
      await _localDataSource.queueSyncOperation(
        uuid: student.id,
        operation: 'upsert',
        payload: model.toMap(),
      );

      // 4. Trigger a sync attempt in the background.
      _syncService.performSync();

      // 5. Return the updated entity.
      return Right(student);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteStudent(String studentId) async {
    try {
      // 1. Perform a soft delete locally for instant UI update.
      await _localDataSource.deleteStudent(studentId);

      // 2. Queue the delete operation for the sync engine.
      await _localDataSource.queueSyncOperation(
        uuid: studentId,
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
  Future<Either<Failure, StudentInfoEntity>> getStudentById(
    String studentId,
  ) async {
    // This method would typically fetch from the local data source first,
    // then potentially trigger a targeted remote fetch if needed.
    try {
      final model = await _localDataSource.getStudentInfoById(studentId);
      return Right(model.toStudentInfoEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<StudentListItemEntity>>> getFilteredStudents({
    ActiveStatus? status,
    int? halaqaId,
    DateTime? trackDate,
    Frequency? frequencyCode,
  }) async {
    // This method would typically fetch from the local data source first,
    // then potentially trigger a targeted remote fetch if needed.
    try {
      final model = await _localDataSource.getFilteredStudents(
        status: status,
        halaqaId: halaqaId,
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
  Future<Either<Failure, FollowUpPlanEntity>> getFollowUpPlan(
    String studentId,
  ) async {
    try {
      final FollowUpPlanModel planModel = await _localDataSource
          .getFollowUpPlan(studentId);
      return Right(planModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<TrackingEntity>>> getFollowUpTrackings(
    String studentId,
  ) async {
    try {
      await _syncService.performTrackingsSync(studentId: studentId);
      final List<TrackingModel> trackingModels = await _localDataSource
          .getFollowUpTrackings(studentId);
      final trackingEntities = trackingModels
          .map((model) => model.toEntity())
          .toList();
      return Right(trackingEntities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }


  /// Returns [Right(unit)] on success, or a [Left(Failure)] on error.
  @override
  Future<Either<Failure, Unit>> setStudentStatus({
    required String studentId,
    required ActiveStatus newStatus,
  }) async {
    return const Right(unit);
  }
}

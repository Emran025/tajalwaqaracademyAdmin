import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/active_status.dart';
import '../entities/teacher_entity.dart';
import '../entities/teacher_list_item_entity.dart';

/// Defines the abstract contract for the teacher data repository.
///
/// This interface is the single gateway for the domain layer to interact with
/// all teacher-related data, abstracting away the complexities of data sources,
/// caching, and synchronization.
abstract interface class TeacherRepository {
  /// Returns a stream of the teacher list, suitable for a reactive UI.
  ///
  /// This method implements a "Stale-While-Revalidate" pattern. It immediately
  /// returns a stream of the locally cached data and simultaneously triggers a
  /// background sync to fetch the latest data from the remote server.
  ///
  /// Any updates from the sync will be automatically pushed to the local database,
  /// which in turn will cause this stream to emit a new, updated list.
  ///
  /// - [forceRefresh]: When true, it forces a background sync even if one was
  ///   recently completed. Useful for "pull-to-refresh" actions.
  ///
  /// Returns a [Stream] that emits `Either<Failure, List<TeacherListItemEntity>>`.
  Stream<Either<Failure, List<TeacherListItemEntity>>> getTeachers({
    bool forceRefresh = true,
  });

  /// Fetches the next page of teachers from the remote API to append to the local cache.
  ///
  /// This is used for "load more" or infinite scrolling functionality. The UI will
  /// update automatically via the stream returned by `getTeachers`.
  ///
  /// - [page]: The next page number to fetch.
  Future<Either<Failure, Unit>> fetchMoreTeachers({required int page});

  /// Returns [Either<Failure, TeacherDetailEntity>]:
  /// - Right(TeacherDetailEntity) on success.
  /// - Left(Failure) if the teacher is not found or another error occurs.
  Future<Either<Failure, TeacherDetailEntity>> getTeacherById(String teacherId);

  /// Creates a new teacher or updates an existing one.
  ///
  /// Returns [Either<Failure, TeacherDetailEntity>]:
  /// - Right(TeacherDetailEntity) on success, returning the created/updated teacher.
  /// - Left(Failure) on error.
  Future<Either<Failure, TeacherDetailEntity>> upsertTeacher(
    TeacherDetailEntity teacher,
  );

  /// Deletes a teacher by their ID.
  ///
  /// Returns [Either<Failure, Unit>]:
  /// - Right(unit) on successful deletion. `unit` is a void-like type from dartz.
  /// - Left(Failure) on error.
  Future<Either<Failure, Unit>> deleteTeacher(String teacherId);

  /// Returns [Right(unit)] on success, or a [Left(Failure)] on error.
  Future<Either<Failure, Unit>>  setTeacherStatus({
    required String teacherId,
    required ActiveStatus newStatus,
  });
}

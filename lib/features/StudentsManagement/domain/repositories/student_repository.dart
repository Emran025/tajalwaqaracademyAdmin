import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/active_status.dart';
import '../../../../core/models/report_frequency.dart';
import '../entities/follow_up_plan_entity.dart';
import '../entities/student_entity.dart';
import '../entities/student_info_entity.dart';
import '../entities/student_list_item_entity.dart';
import '../entities/tracking_entity.dart';

/// Defines the abstract contract for the student data repository.
///
/// This interface is the single gateway for the domain layer to interact with
/// all student-related data, abstracting away the complexities of data sources,
/// caching, and synchronization.
abstract interface class StudentRepository {
  /// Returns a stream of the student list, suitable for a reactive UI.
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
  /// Returns a [Stream] that emits `Either<Failure, List<StudentListItemEntity>>`.
  Stream<Either<Failure, List<StudentListItemEntity>>> getStudents({
    bool forceRefresh = true,
  });

  /// Fetches the next page of students from the remote API to append to the local cache.
  ///
  /// This is used for "load more" or infinite scrolling functionality. The UI will
  /// update automatically via the stream returned by `getStudents`.
  ///
  /// - [page]: The next page number to fetch.
  Future<Either<Failure, Unit>> fetchMoreStudents({required int page});

  /// Returns [Either<Failure, StudentDetailEntity>]:
  /// - Right(StudentDetailEntity) on success.
  /// - Left(Failure) if the student is not found or another error occurs.
  Future<Either<Failure, StudentInfoEntity>> getStudentById(String studentId);

  /// Creates a new student or updates an existing one.
  ///
  /// Returns [Either<Failure, StudentDetailEntity>]:
  /// - Right(StudentDetailEntity) on success, returning the created/updated student.
  /// - Left(Failure) on error.
  Future<Either<Failure, StudentDetailEntity>> upsertStudent(
    StudentDetailEntity student,
  );

  /// Deletes a student by their ID.
  ///
  /// Returns [Either<Failure, Unit>]:
  /// - Right(unit) on successful deletion. `unit` is a void-like type from dartz.
  /// - Left(Failure) on error.
  Future<Either<Failure, Unit>> deleteStudent(String studentId);

  /// Returns [Right(unit)] on success, or a [Left(Failure)] on error.
  Future<Either<Failure, Unit>> setStudentStatus({
    required String studentId,
    required ActiveStatus newStatus,
  });

  Future<Either<Failure, FollowUpPlanEntity>> getFollowUpPlan(String studentId);
  Future<Either<Failure, List<TrackingEntity>>> getFollowUpTrackings(
    String studentId,
  );

  Future<Either<Failure, List<StudentListItemEntity>>> getFilteredStudents({
    ActiveStatus? status,
    int? halaqaId,
    DateTime? trackDate,
    Frequency? frequencyCode,
  });

}

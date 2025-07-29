

import '../../domain/entities/paginated_teachers_result.dart';
import '../models/teacher_model.dart';
import '../models/teacher_sync_response_model.dart';

/// Defines the abstract contract for the remote data source of teachers.
/// This interface specifies the methods for fetching and manipulating teacher
/// data from the remote API. All methods must return data layer models (e.g.,
/// [TeacherModel]) and are expected to throw a [ServerException] upon API failure.

/// Defines the abstract contract for the remote data source of teachers.
///
/// This interface specifies all methods for interacting with the teacher-related
/// endpoints of the remote API. It is designed to support a robust, two-way
/// synchronization mechanism.
abstract interface class TeacherRemoteDataSource {

    /// Fetches a paginated list of teachers from the remote API.
  ///
  /// - [page]: The page number to fetch.
  ///
  /// Returns a [PaginatedTeachersResult] containing a list of [TeacherModel]
  /// and pagination information.
  Future<PaginatedTeachersResult> getTeachers({required int page});

  /// Fetches a single page of delta updates from the server.
  ///
  /// - [since]: A Unix timestamp (milliseconds) of the last successful sync.
  /// - [page]: The page number to fetch.
  ///
  /// Returns a [TeacherSyncResponseModel] containing a batch of updated/deleted
  /// records, pagination info, and a new server timestamp.
  Future<TeacherSyncResponseModel> getUpdatedTeachers({
    required int since,
    required int page, // <<< المعلمة الجديدة
  });

  /// Pushes a create or update operation for a single teacher to the server.
  ///
  /// This is the core method for the "push" stage of synchronization.
  /// - [teacherData]: A map containing the full data of the teacher to be created or updated.
  ///
  /// Returns the final, server-confirmed [TeacherModel].
  Future<TeacherModel> upsertTeacher(Map<String, dynamic> teacherData);

  // You can add other methods like:
  // Future<TeacherModel> updateTeacher({required String id, required Map<String, dynamic> teacherData});
  // Future<void> deleteTeacher({required String id});
  /// Deletes a teacher by their ID via the remote API.
  /// - [teacherId]: The ID of the teacher to delete.
  /// Returns a [Future] that completes when the deletion is successful.
  Future<void> deleteTeacher(String teacherId); 
}
import '../../domain/entities/paginated_students_result.dart';
import '../models/student_model.dart';
import '../models/student_sync_response_model.dart';
import '../models/tracking_model.dart';

/// Defines the abstract contract for the remote data source of students.
///
/// This interface specifies the methods for fetching and manipulating student
/// data from the remote API. All methods must return data layer models (e.g.,
/// [StudentModel]) and are expected to throw a [ServerException] upon API failure.

/// Defines the abstract contract for the remote data source of students.
///
/// This interface specifies all methods for interacting with the student-related
/// endpoints of the remote API. It is designed to support a robust, two-way
/// synchronization mechanism.
abstract interface class StudentRemoteDataSource {
  /// Fetches a paginated list of students from the remote API.
  ///
  /// - [page]: The page number to fetch.
  ///
  /// Returns a [PaginatedStudentsResult] containing a list of [StudentModel]
  /// and pagination information.
  Future<PaginatedStudentsResult> getStudents({required int page});

  /// Fetches a single page of delta updates from the server.
  ///
  /// - [since]: A Unix timestamp (milliseconds) of the last successful sync.
  /// - [page]: The page number to fetch.
  ///
  /// Returns a [StudentSyncResponseModel] containing a batch of updated/deleted
  /// records, pagination info, and a new server timestamp.
  Future<StudentSyncResponseModel> getUpdatedStudents({
    required int since,
    required int page,
  });


  /// Fetches a single student by their unique identifier (UUID).
  /// - [studentData]: A map containing the student's UUID and other identifying information.
  /// Returns the [StudentModel] for the specified student.
  Future<StudentModel> getStudent(String studentData);

  /// Pushes a create or update operation for a single student to the server.
  ///
  /// This is the core method for the "push" stage of synchronization.
  /// - [studentData]: A map containing the full data of the student to be created or updated.
  ///
  /// Returns the final, server-confirmed [StudentModel].
  Future<StudentModel> upsertStudent(Map<String, dynamic> studentData);

  // You can add other methods like:
  // Future<StudentModel> updateStudent({required String id, required Map<String, dynamic> studentData});
  // Future<void> deleteStudent({required String id});
  /// Deletes a student by their ID via the remote API.
  /// - [studentId]: The ID of the student to delete.
  /// Returns a [Future] that completes when the deletion is successful.
  Future<void> deleteStudent(String studentId);
  Future<List<TrackingModel>> getFollowUpTrackings(String studentId);
}

import 'package:tajalwaqaracademy/features/StudentsManagement/data/models/sync_queue_model.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/data/models/student_model.dart';

/// Defines the abstract contract for the local data source of students.
///
/// This interface specifies all methods required for managing student data and
/// their synchronization state within the local SQLite database. It operates
/// exclusively with data layer models.
abstract interface class StudentLocalDataSource {
  /// Returns a stream of all cached, non-deleted students.
  /// The UI layer will listen to this stream to get live updates.
  /// This method is used to notify the UI of changes in the students table.
  /// The stream emits a new list of [StudentModel] whenever the database changes.
  /// This is useful for real-time updates in the UI.
  /// The stream should be closed when the data source is disposed.
  /// This method is used to watch all students in the local database.

  Stream<List<StudentModel>> watchAllStudents();

  /// Intelligently applies a batch of remote changes (updates and deletes)
  /// to the local database within a single transaction.
  Future<void> applySyncBatch({
    required List<StudentModel> updatedStudents,
    required List<StudentModel> deletedStudents,
  });

  /// Queues a local change (create, update, delete) for later synchronization.
  Future<void> queueSyncOperation({
    required String uuid,
    required String operation,
    Map<String, dynamic>? payload,
  });

  /// Retrieves all pending operations from the sync queue.
  Future<List<SyncQueueModel>> getPendingSyncOperations();

  /// Retrieves the timestamp of the most recently modified record.
  /// This is used for delta synchronization.
  Future<int> getLastSyncTimestampFor();
  Future<void> updateLastSyncTimestampFor(int timestamp);

  /// Marks a specific sync operation as completed in the queue.
  Future<void> markOperationAsCompleted(int operationId);

  /// Deletes a completed operation from the sync queue by its ID.
  Future<void> deleteCompletedOperation(int operationId);

  // You would also have methods to mark operations as 'in_progress' or 'failed'.

  /// Creates a new student or updates an existing one in the local database.
  ///
  /// The implementation should use a conflict resolution algorithm like
  /// `ConflictAlgorithm.replace` to handle both insertion and update
  /// (upsert) in a single operation.
  /// Throws a [CacheException] if the upsert operation fails.
  Future<void> upsertStudent(StudentModel student);
  // You would also have methods to mark operations as 'in_progress' or 'failed'.

  /// Creates a new student or updates an existing one in the local database.
  ///
  /// The implementation should use a conflict resolution algorithm like
  /// `ConflictAlgorithm.replace` to handle both insertion and update
  /// (upsert) in a single operation.
  /// Throws a [CacheException] if the upsert operation fails.
  Future<void> upsertStudentPlan(StudentModel student);

  /// Performs a "soft delete" on a student record in the local database.
  ///
  /// Instead of physically removing the record, this method should mark the
  /// student as deleted (e.g., by setting an `isDeleted` flag to true).
  /// Throws a [CacheException] if the update operation fails.
  Future<void> deleteStudent(String studentId);

  /// Fetches a single student by their ID from the local database.
  /// Returns a [StudentModel] if found, or throws a [CacheException] if not.
  /// This method is used to retrieve a specific student's details.
  /// @param studentId The unique identifier of the student.
  /// @returns A [StudentModel] representing the student.
  Future<StudentModel> getStudentById(String studentId);
}

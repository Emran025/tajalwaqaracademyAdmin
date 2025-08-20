
import '../../../../core/models/sync_queue_model.dart';
import '../models/teacher_model.dart';

/// Defines the abstract contract for the local data source of teachers.
///
/// This interface specifies all methods required for managing teacher data and
/// their synchronization state within the local SQLite database. It operates
/// exclusively with data layer models.
abstract interface class TeacherLocalDataSource {
  /// Returns a stream of all cached, non-deleted teachers.
  /// The UI layer will listen to this stream to get live updates.
  /// This method is used to notify the UI of changes in the teachers table.
  /// The stream emits a new list of [TeacherModel] whenever the database changes.
  /// This is useful for real-time updates in the UI.
  /// The stream should be closed when the data source is disposed.
  /// This method is used to watch all teachers in the local database.

  Stream<List<TeacherModel>> watchAllTeachers();

  /// Intelligently applies a batch of remote changes (updates and deletes)
  /// to the local database within a single transaction.
  Future<void> applySyncBatch({
    required List<TeacherModel> updatedTeachers,
    required List<TeacherModel> deletedTeachers,
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

  /// Creates a new teacher or updates an existing one in the local database.
  ///
  /// The implementation should use a conflict resolution algorithm like
  /// `ConflictAlgorithm.replace` to handle both insertion and update
  /// (upsert) in a single operation.
  /// Throws a [CacheException] if the upsert operation fails.
  Future<void> upsertTeacher(TeacherModel teacher);

  /// Performs a "soft delete" on a teacher record in the local database.
  ///
  /// Instead of physically removing the record, this method should mark the
  /// teacher as deleted (e.g., by setting an `isDeleted` flag to true).
  /// Throws a [CacheException] if the update operation fails.
  Future<void> deleteTeacher(String teacherId);


  /// Fetches a single teacher by their ID from the local database.
  /// Returns a [TeacherModel] if found, or throws a [CacheException] if not.
  /// This method is used to retrieve a specific teacher's details.
  /// @param teacherId The unique identifier of the teacher.
  /// @returns A [TeacherModel] representing the teacher.
  Future<TeacherModel> getTeacherById(String teacherId);
}

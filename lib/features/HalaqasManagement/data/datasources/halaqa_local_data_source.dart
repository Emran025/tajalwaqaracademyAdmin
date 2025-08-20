import '../../../../core/models/active_status.dart';
import '../../../../core/models/report_frequency.dart';
import '../../../../core/models/sync_queue_model.dart';
import '../models/halaqa_model.dart';

/// Defines the abstract contract for the local data source of halaqas.
///
/// This interface specifies all methods required for managing halaqa data and
/// their synchronization state within the local SQLite database. It operates
/// exclusively with data layer models.
abstract interface class HalaqaLocalDataSource {
  /// Returns a stream of all cached, non-deleted halaqas.
  /// The UI layer will listen to this stream to get live updates.
  /// This method is used to notify the UI of changes in the halaqas table.
  /// The stream emits a new list of [HalaqaModel] whenever the database changes.
  /// This is useful for real-time updates in the UI.
  /// The stream should be closed when the data source is disposed.
  /// This method is used to watch all halaqas in the local database.

  Stream<List<HalaqaModel>> watchAllHalaqas();

  /// Intelligently applies a batch of remote changes (updates and deletes)
  /// to the local database within a single transaction.
  Future<void> applySyncBatch({
    required List<HalaqaModel> updatedHalaqas,
    required List<HalaqaModel> deletedHalaqas,
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

  /// Creates a new halaqa or updates an existing one in the local database.
  ///
  /// The implementation should use a conflict resolution algorithm like
  /// `ConflictAlgorithm.replace` to handle both insertion and update
  /// (upsert) in a single operation.
  /// Throws a [CacheException] if the upsert operation fails.
  Future<void> upsertHalaqa(HalaqaModel halaqa);

  /// Performs a "soft delete" on a halaqa record in the local database.
  ///
  /// Instead of physically removing the record, this method should mark the
  /// halaqa as deleted (e.g., by setting an `isDeleted` flag to true).
  /// Throws a [CacheException] if the update operation fails.
  Future<void> deleteHalaqa(String halaqaId);

  /// Fetches a single halaqa by their ID from the local database.
  /// Returns a [HalaqaModel] if found, or throws a [CacheException] if not.
  /// This method is used to retrieve a specific halaqa's details.
  /// @param halaqaId The unique identifier of the halaqa.
  /// @returns A [HalaqaModel] representing the halaqa.
  Future<HalaqaModel> getHalaqaById(String halaqaId);

  Future<List<HalaqaModel>> getHalaqasByStudentCriteria({

    ActiveStatus? studentStatus,
    DateTime? trackDate,
    Frequency? frequencyCode,
  });

}

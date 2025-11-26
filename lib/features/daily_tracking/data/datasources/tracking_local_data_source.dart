import 'package:tajalwaqaracademy/core/models/sync_queue_model.dart';
import 'package:tajalwaqaracademy/core/models/tracking_type.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/data/models/tracking_detail_model.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/bar_chart_datas.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/entities/chart_filter.dart';

import '../models/mistake_model.dart';

/// Abstract contract for the local data source for interactive tracking operations.
///
/// This defines the capabilities of the data source, separating the "what" from the "how".
/// The repository layer will depend on this contract, not the concrete implementation.
abstract class TrackingLocalDataSource {
  // =========================================================================
  //                             Core Public Methods
  // =========================================================================

  /// Fetches or creates today's DRAFT tracking details for a given enrollment ID.
  ///
  /// - If a draft record for today exists, it's fetched along with its details and mistakes.
  /// - If not, a new draft record is created. The starting point (`fromTrackingUnitId`)
  ///   is intelligently determined from the student's last completed session.
  ///
  /// Returns a map where the key is the `TrackingType` and the value is the
  /// fully assembled `TrackingDetailModel` (including mistakes).
  Future<Map<TrackingType, TrackingDetailModel>>
  getOrCreateTodayDraftTrackingDetails({required int enrollmentId});

  /// Persists the current state of a list of tracking details to the database.
  ///
  /// This is intended for autosaving the "draft" session. It performs a transactional
  /// update, ensuring data integrity. It updates the detail record (e.g., score, comment),
  /// overwrites the associated mistakes with the latest list, and queues the
  /// operation for future synchronization.
  Future<void> saveDraftTrackingDetails(List<TrackingDetailModel> details);

  /// Finalizes the current draft tracking record.
  ///
  /// This operation updates the parent `daily_tracking` record's status from 'draft'
  /// to 'completed', saves the final teacher notes, and queues the operation for
  /// future synchronization.
  Future<void> finalizeDailyTracking({
    required int trackingId,
    required String finalNotes,
    required int behaviorScore,
  });

  // =========================================================================
  //                      All Mistake Methods
  // =========================================================================

  // ... other methods


  Future<List<MistakeModel>> getAllMistakes({
    required int enrollmentId,
    TrackingType? type, // <-- NOW OPTIONAL
    int? fromPage,
    int? toPage,
  });

  Future<List<BarChartDatas>> getErrorAnalysisChartData({
    required int enrollmentId,
    required ChartFilter filter,
  });



  // =========================================================================
  //                       Synchronization Methods
  // =========================================================================

  /// Fetches all pending sync operations for tracking entities from the local queue.
  ///
  /// Returns a list of [SyncQueueModel] objects, ordered by creation time.
  Future<List<SyncQueueModel>> getPendingSyncOperations();

  /// Deletes a sync operation from the queue once it has been successfully
  /// processed by the server.
  Future<void> deleteCompletedOperation(int operationId);

  /// Retrieves the last successful server sync timestamp for the tracking entity type.
  ///
  /// Returns a Unix timestamp in milliseconds, or 0 if no sync has occurred.
  Future<int> getLastSyncTimestamp();

  /// Updates the last successful server sync timestamp for the tracking entity type.
  ///
  /// This should be called after a successful sync operation with the server,
  /// using the timestamp provided by the server.
  Future<void> updateLastSyncTimestamp(int timestamp);
}

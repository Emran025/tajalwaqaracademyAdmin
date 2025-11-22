import '../../../../core/models/user_role.dart';
import '../models/count_delta.dart';
import '../models/student_summaray_record.dart';
import '../models/student_summary_delta.dart';

/// Defines the abstract contract for the local data source of students.
///
/// This interface specifies all methods required for managing student data and
/// their synchronization state within the local SQLite database. It operates
/// exclusively with data layer models.
abstract interface class SupervisorLocalDataSource {
  Future<List<Record>> getAllEntitysWithTimestamps(UserRole entityType);

  Future<List<DateTime>> getStartEndTimes(UserRole entityType);

  Future<void> insertDailySummary(SummaryDelta summary);
  Future<void> insertCount(CountDelta count);
  Future<List<SummaryDelta>> getAllDailySummaries(UserRole entityType);
  Future<CountsDelta> getCounts();
  Future<int> getEntitesCount(UserRole entityType);
  Future<List<SummaryDelta>> getDailySummariesInDateRange(
    DateTime startDate,
    DateTime endDate,
    UserRole entityType,
  );

  /// Retrieves the timestamp of the most recently modified record.
  /// This is used for delta synchronization.
  Future<int> getLastSyncTimestampFor(String entityType);
  Future<void> updateLastSyncTimestampFor(String entityType, int timestamp);
}

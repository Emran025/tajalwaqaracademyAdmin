import 'package:injectable/injectable.dart';

import '../../../../core/network/network_info.dart';
import '../datasources/student_local_data_source.dart';
import '../datasources/student_remote_data_source.dart';
import 'student_sync_service.dart';

/// The concrete implementation of the [StudentSyncService].
///
/// This class contains the core logic for the two-way, delta-based synchronization
/// for student data, including handling paginated responses from the server.
@LazySingleton(as: StudentSyncService)
final class StudentSyncServiceImpl implements StudentSyncService {
  final StudentRemoteDataSource _remoteDataSource;
  final StudentLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  bool _isSyncing = false;

  StudentSyncServiceImpl({
    required StudentRemoteDataSource remoteDataSource,
    required StudentLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

  /// Defines the duration for which cached data is considered "fresh".
  /// A background sync will not be triggered if the last sync was within this duration.
  static const _staleThreshold = Duration(minutes: 5);

  @override
  Future<void> performSync({int initialPage = 1}) async {
    // if (_isSyncing || !await _networkInfo.isConnected) {
    if (_isSyncing) {
      print('[SyncService] Sync skipped: already in progress or offline.');
      return;
    }

    _isSyncing = true;
    print('[SyncService] Starting two-way sync for students...');
    try {
      await _pushLocalChanges();
      await _pullRemoteChanges(initialPage: initialPage);
      print('[SyncService] Sync completed successfully.');
    } catch (e) {
      print('[SyncService] Sync process failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _pushLocalChanges() async {
    final pendingOps = await _localDataSource.getPendingSyncOperations();
    if (pendingOps.isEmpty) {
      return;
    }

    print('[SyncService-Push] Found ${pendingOps.length} operations to push.');
    for (final op in pendingOps) {
      try {
        if (op.operationType == 'upsert') {
          final serverModel = await _remoteDataSource.upsertStudent(
            op.decodedPayload!,
          );
          await _localDataSource.upsertStudent(serverModel);
        } else if (op.operationType == 'delete') {
          await _remoteDataSource.deleteStudent(op.entityUuid);
        }
        await _localDataSource.deleteCompletedOperation(op.id);
      } catch (e) {
        print('[SyncService-Push] Failed to push op ${op.id}. Aborting.');
        rethrow;
      }
    }
  }

  Future<void> _pullRemoteChanges({required int initialPage}) async {
    // 1. Get the timestamp of the last successful sync.
    final lastSyncTimestamp = await _localDataSource.getLastSyncTimestampFor();
    final lastSyncTime = DateTime.fromMillisecondsSinceEpoch(lastSyncTimestamp);

    // 2. Check if the time elapsed since the last sync is within our threshold.
    final isFresh = DateTime.now().difference(lastSyncTime) < _staleThreshold;
    // 3. If data is fresh OR if we are offline, do nothing.
    if (isFresh) {
      if (isFresh) {
        print(
          '[Repository] Data is fresh (synced within the last 5 minutes). Skipping network refresh.',
        );
      } else {
        print('[Repository] Offline. Skipping network refresh.');
      }
      return;
    }

    print(
      '[SyncService-Pull] Pulling changes since timestamp: $lastSyncTimestamp',
    );

    int currentPage = initialPage;
    bool hasMorePages = true;
    int? finalSyncTimestamp;

    while (hasMorePages) {
      print('[SyncService-Pull] Fetching page $currentPage...');
      final syncResult = await _remoteDataSource.getUpdatedStudents(
        since: lastSyncTimestamp,
        page: currentPage,
      );

      if (syncResult.updated.isNotEmpty || syncResult.deleted.isNotEmpty) {
        await _localDataSource.applySyncBatch(
          updatedStudents: syncResult.updated,
          deletedStudents: syncResult.deleted,
        );
      }

      hasMorePages = syncResult.paginationInfo.hasMorePages;
      if (hasMorePages) {
        currentPage++;
      }
      finalSyncTimestamp = syncResult.newSyncTimestamp;
    }

    if (finalSyncTimestamp != null) {
      await _localDataSource.updateLastSyncTimestampFor(finalSyncTimestamp);
      print(
        '[SyncService-Pull] Finished. New sync timestamp is $finalSyncTimestamp.',
      );
    }
  }
}

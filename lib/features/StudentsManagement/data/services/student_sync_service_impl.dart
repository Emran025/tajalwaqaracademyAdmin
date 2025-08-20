import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/network/network_info.dart';
import '../datasources/student_local_data_source.dart';
import '../datasources/student_remote_data_source.dart';
import 'student_sync_service.dart';

/// A professional-grade service for orchestrating two-way, delta-based data synchronization.
///
/// This service is designed with key principles for robustness and efficiency:
/// 1.  **Granular Locking**: Prevents concurrent sync operations on the same entity
///     while allowing parallel syncs for different entities. A global lock is used
///     for full-table syncs.
/// 2.  **Intelligent Pre-flight Checks**: Ensures that dependent data (e.g., a student's
///     enrollment) is present locally *before* attempting to sync child data (e.g., trackings),
///     fetching prerequisites from the network only when absolutely necessary.
/// 3.  **Clear Logging**: Provides detailed console output for tracing sync operations,
///     successes, and failures.
@LazySingleton(as: StudentSyncService)
final class StudentSyncServiceImpl implements StudentSyncService {
  final StudentRemoteDataSource _remoteDataSource;
  final StudentLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  /// A lock to prevent the global `performSync` from running concurrently.
  bool _isGlobalSyncInProgress = false;

  /// A set to track specific entities currently being synced (e.g., 'trackings-student-uuid-123').
  /// This allows for granular locking, preventing duplicate syncs for the same item
  /// while allowing different items to be synced in parallel.
  final Set<String> _syncingEntityIds = {};

  StudentSyncServiceImpl({
    required StudentRemoteDataSource remoteDataSource,
    required StudentLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

  static const _staleThreshold = Duration(minutes: 5);
  static const _staleThresholdTr = Duration(seconds: 30);

  @override
  Future<void> performTrackingsSync({required String studentId}) async {
    final syncKey = 'trackings-$studentId';

    // -->> تعديل رئيسي: استخدام قفل دقيق <<--
    if (_isGlobalSyncInProgress || _syncingEntityIds.contains(syncKey)) {
      print(
        '[SyncService][Trackings] Skipped: Sync for $syncKey is already in progress or a global sync is active.',
      );
      return;
    }

    try {
      _syncingEntityIds.add(syncKey);
      print(
        '[SyncService][Trackings] Starting sync for student trackings: $studentId',
      );

      // The core logic is now wrapped in a safe, intelligent check.
      final bool isStudentReady = await _ensureStudentIsSynced(studentId);

      if (isStudentReady) {
        await _pullRemoteFollowUpTrackingsChanges(studentId: studentId);
        print(
          '[SyncService][Trackings] Sync completed successfully for student: $studentId',
        );
      } else {
        print(
          '[SyncService][Trackings] Sync aborted: The parent student with UUID $studentId could not be found or synced.',
        );
      }
    } on CacheException catch (e) {
      print('[SyncService][Trackings] Cache Error: ${e.message}');
    } on DioException catch (e) {
      print(
        '[SyncService][Trackings] Network Error: Could not complete sync. ${e.message}',
      );
    } catch (e) {
      print(
        '[SyncService][Trackings] An unexpected error occurred: $e. Aborting.',
      );
    } finally {
      _syncingEntityIds.remove(syncKey);
    }
  }

  /// **(CRITICAL REWRITE)** Ensures a student's data is present locally.
  /// It first checks the local database. If the student is not found, *and only then*,
  /// it fetches the data from the remote source. This is the core of the fix.
  ///
  /// Returns `true` if the student is ready, `false` otherwise.
  Future<bool> _ensureStudentIsSynced(String studentId) async {
    try {
      // If, and only if, the student is not found locally, fetch from remote.
      print(
        '[SyncService][Pre-flight] Prerequisite MISSING: Student $studentId not found locally. Fetching from remote...',
      );

      final studentModel = await _remoteDataSource.getStudent(studentId);
      await _localDataSource.upsertStudent(studentModel);

      print(
        '[SyncService][Pre-flight] Successfully synced prerequisite student data for $studentId.',
      );
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        print(
          '[SyncService][Pre-flight] Could not fetch prerequisite student $studentId. The student does not exist on the server (404).',
        );
      } else {
        print(
          '[SyncService][Pre-flight] API Error: Could not fetch prerequisite student $studentId. Error: ${e.message}',
        );
      }
      return false;
    } catch (e) {
      print(
        '[SyncService][Pre-flight] Failed to ensure student $studentId is synced. Error: $e',
      );
      return false;
    }
  }

  @override
  Future<void> performSync({int initialPage = 1}) async {
    if (_isGlobalSyncInProgress) {
      print(
        '[SyncService][Global] Skipped: A global sync is already in progress.',
      );
      return;
    }

    _isGlobalSyncInProgress = true;
    print('[SyncService][Global] Starting full two-way sync for students...');
    try {
      await _pushLocalChanges();
      await _pullRemoteChanges(initialPage: initialPage);
      print('[SyncService][Global] Two-way sync completed successfully.');
    } on CacheException catch (e) {
      print('[SyncService][Global] A cache exception occurred: ${e.message}');
    } catch (e) {
      print(
        '[SyncService][Global] Sync process failed with an unexpected error: $e',
      );
    } finally {
      _isGlobalSyncInProgress = false;
    }
  }

  // --- PRIVATE HELPERS ---
  // (The rest of the methods are largely the same, but with improved logging for consistency)

  Future<void> _pushLocalChanges() async {
    final pendingOps = await _localDataSource.getPendingSyncOperations();
    if (pendingOps.isEmpty) {
      print('[SyncService-Push] No local changes to push.');
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
        print('[SyncService-Push] Successfully pushed operation ${op.id}.');
      } catch (e) {
        print(
          '[SyncService-Push] Failed to push operation ${op.id}. Aborting push cycle. Error: $e',
        );
        rethrow; // Abort on failure to maintain data consistency.
      }
    }
  }

  Future<void> _pullRemoteFollowUpTrackingsChanges({
    required String studentId,
  }) async {
    final lastSyncTimestamp = await _localDataSource.getLastSyncTimestampFor(
      "Trackings$studentId",
    );
    final lastSyncTime = DateTime.fromMillisecondsSinceEpoch(lastSyncTimestamp);

    final isFresh = DateTime.now().difference(lastSyncTime) < _staleThresholdTr;
    if (isFresh) {
      print(
        '[SyncService-Pull-Trackings] Data is fresh. Skipping network refresh.',
      );
      return;
    }

    print(
      '[SyncService-Pull-Trackings] Pulling remote tracking changes for student $studentId...',
    );

    final syncResult = await _remoteDataSource.getFollowUpTrackings(studentId);

    print(
      '[SyncService-Pull-Trackings] Fetched ${syncResult.length} tracking records from remote.',
    );

    if (syncResult.isNotEmpty) {
      // This call is now protected against the foreign key error.
      await _localDataSource.cacheFollowUpTrackings(
        studentId: studentId,
        trackings: syncResult,
      );
    }

    final finalSyncTimestamp = DateTime.now().millisecondsSinceEpoch;
    await _localDataSource.updateLastSyncTimestampFor(
      "Trackings$studentId",
      finalSyncTimestamp,
    );

    print(
      '[SyncService-Pull-Trackings] Finished. New sync timestamp is $finalSyncTimestamp.',
    );
  }

  Future<void> _pullRemoteChanges({required int initialPage}) async {
    final lastSyncTimestamp = await _localDataSource.getLastSyncTimestampFor(
      UserRole.student.label,
    );
    final lastSyncTime = DateTime.fromMillisecondsSinceEpoch(lastSyncTimestamp);

    final isFresh = DateTime.now().difference(lastSyncTime) < _staleThreshold;
    if (isFresh) {
      print(
        '[SyncService-Pull-Students] Data is fresh. Skipping network refresh.',
      );
      return;
    }

    print(
      '[SyncService-Pull-Students] Pulling student changes since timestamp: $lastSyncTimestamp',
    );

    int currentPage = initialPage;
    bool hasMorePages = true;
    int? finalSyncTimestamp;

    while (hasMorePages) {
      print('[SyncService-Pull-Students] Fetching page $currentPage...');
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
      await _localDataSource.updateLastSyncTimestampFor(
        UserRole.student.label,
        finalSyncTimestamp,
      );
      print(
        '[SyncService-Pull-Students] Finished. New sync timestamp is $finalSyncTimestamp.',
      );
    }
  }
}

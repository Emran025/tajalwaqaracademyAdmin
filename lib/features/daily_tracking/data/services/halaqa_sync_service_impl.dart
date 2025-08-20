import 'dart:async';
import 'package:injectable/injectable.dart';

// Core
import 'package:tajalwaqaracademy/core/error/exceptions.dart';
import 'package:tajalwaqaracademy/core/network/network_info.dart';

// Data Sources
import '../datasources/tracking_local_data_source.dart';
import '../datasources/tracking_remote_data_source.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/data/datasources/student_local_data_source.dart'; // To get full tracking data

// Models
import 'package:tajalwaqaracademy/features/StudentsManagement/data/models/tracking_model.dart';
import '../models/tracking_sync_payload_model.dart';
import 'tracking_sync_service.dart';

// The Contract

@LazySingleton(as: TrackingSyncService)
final class TrackingSyncServiceImpl implements TrackingSyncService {
  final TrackingRemoteDataSource _remoteDataSource;
  final TrackingLocalDataSource _localDataSource;
  final StudentLocalDataSource _studentLocalDataSource; // To fetch full tracking data
  final NetworkInfo _networkInfo;

  bool _isSyncInProgress = false;

  TrackingSyncServiceImpl({
    required TrackingRemoteDataSource remoteDataSource,
    required TrackingLocalDataSource localDataSource,
    required StudentLocalDataSource studentLocalDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _studentLocalDataSource = studentLocalDataSource,
        _networkInfo = networkInfo;

  @override
  Future<void> performSync() async {
    if (_isSyncInProgress) {
      print('[SyncService][Tracking] Skipped: Sync is already in progress.');
      return;
    }
    
    if (!await _networkInfo.isConnected) {
      print('[SyncService][Tracking] Skipped: No internet connection.');
      return;
    }

    _isSyncInProgress = true;
    print('[SyncService][Tracking] Starting push-sync for local tracking changes...');

    try {
      await _pushLocalChanges();
      print('[SyncService][Tracking] Push-sync completed successfully.');
    } on CacheException catch (e) {
      print('[SyncService][Tracking] A cache exception occurred: ${e.message}');
    } on ServerException catch (e) {
      print('[SyncService][Tracking] A server exception occurred: ${e.message}');
    } catch (e) {
      print('[SyncService][Tracking] Sync process failed with an unexpected error: $e');
    } finally {
      _isSyncInProgress = false;
    }
  }

  /// Gathers all pending tracking operations, constructs a payload, pushes it,
  /// and clears the successfully processed operations from the local queue.
  Future<void> _pushLocalChanges() async {
    final pendingOps = await _localDataSource.getPendingSyncOperations();
    if (pendingOps.isEmpty) {
      print('[SyncService-Push][Tracking] No local tracking changes to push.');
      return;
    }

    print('[SyncService-Push][Tracking] Found ${pendingOps.length} tracking records to push.');

    // Step 1: Fetch the full TrackingModel data for each pending operation's UUID.
    // This is the most complex part. We need to map the tracking UUID back to the student.
    final List<TrackingModel> trackingsToPush = await _studentLocalDataSource.getFollowUpTrackingsByUuids(
        uuids: pendingOps.map((op) => op.entityUuid).toList(),
    );
    
    if (trackingsToPush.isEmpty) {
        print('[SyncService-Push][Tracking] Found pending operations, but could not resolve them to local tracking records. Aborting.');
        return;
    }

    // Step 2: Construct the payload for the remote data source.
    final payload = TrackingSyncPayloadModel(updated: trackingsToPush);

    // Step 3: Push the data to the server.
    print('[SyncService-Push][Tracking] Pushing ${payload.updated.length} records to the server...');
    final response = await _remoteDataSource.pushTrackingUpdates(payload);
    print('[SyncService-Push][Tracking] Server responded with message: "${response.message}"');

    // Step 4: After a successful push, clear the *processed* operations from the queue.
    // The server response tells us which UUIDs were successfully processed.
    if (response.processedUuids.isNotEmpty) {
      // Find the local operation IDs that correspond to the successfully processed UUIDs.
      final opsToDelete = pendingOps.where((op) => response.processedUuids.contains(op.entityUuid));
      
      print('[SyncService-Push][Tracking] Clearing ${opsToDelete.length} completed operations from the local queue.');
      for (final op in opsToDelete) {
        await _localDataSource.deleteCompletedOperation(op.id);
      }
    }
  }
}
import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tajalwaqaracademy/core/error/exceptions.dart';
import 'package:tajalwaqaracademy/core/models/user_role.dart';
import '../../../../core/models/active_status.dart';
import '../../../../core/models/report_frequency.dart';
import '../../../../core/models/sync_queue_model.dart';
import '../models/halaqa_model.dart';
import 'halaqa_local_data_source.dart';

/// The name of the table that stores user data, including halaqas.

/// The concrete implementation of [HalaqaLocalDataSource] using SQLite.
///
/// This class handles all direct database interactions for halaqa data,
/// such as querying, inserting, updating, and deleting records. It operates
/// exclusively with [HalaqaModel] objects.

/// Table and column name constants to prevent typos.
const String _kHalqasTable = 'halqas';
const String _kPendingOperationsTable = 'pending_operations';
const String _kSyncMetadataTable = 'sync_metadata';
const String _kFrequenciesTable = 'frequencies';
const String _kDailyTrackingTable = 'daily_tracking';
const String _kHalqaStudentsTable = 'halqa_students';
const String _kFollowUpPlansTable = 'follow_up_plans';

@LazySingleton(as: HalaqaLocalDataSource)
final class HalaqaLocalDataSourceImpl implements HalaqaLocalDataSource {
  final Database _db;

  /// A broadcast StreamController that acts as a simple notification bus.
  /// When data in the halaqas table changes (e.g., after a sync), we add an
  /// event to this controller to trigger all active listeners to re-fetch.
  final _dbChangeNotifier = StreamController<void>.broadcast();

  HalaqaLocalDataSourceImpl({required Database database}) : _db = database;

  // =========================================================================
  //                             Data Access Methods
  // =========================================================================

  /// Fetches the current list of halaqas from the database.
  /// This is a private helper to avoid code duplication.
  /// It returns a list of [HalaqaModel] objects.
  /// Throws a [CacheException] if the database query fails.
  Future<List<HalaqaModel>> _fetchCachedHalaqas() async {
    try {
      final maps = await _db.query(
        _kHalqasTable,
        where: 'roleId = ? AND isDeleted = ?',
        whereArgs: [UserRole.halaqa.id, 0],
        orderBy: 'name ASC',
      );
      print(maps);
      return maps.map((map) => HalaqaModel.fromDbMap(map)).toList();
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to fetch halaqas from cache: ${e.toString()}',
      );
    }
  }

  @override
  Stream<List<HalaqaModel>> watchAllHalaqas() {
    late StreamController<List<HalaqaModel>> controller;
    StreamSubscription? dbChangeSubscription;

    // This function is called when the stream is first listened to.
    void startListen() {
      // 1. Immediately fetch the current data and emit it.
      _fetchCachedHalaqas()
          .then((halaqas) => controller.add(halaqas))
          .catchError((e) => controller.addError(e));

      // 2. Listen for future database change notifications.
      dbChangeSubscription = _dbChangeNotifier.stream.listen((_) {
        // When a change occurs, re-fetch the data and emit it.
        _fetchCachedHalaqas()
            .then((halaqas) => controller.add(halaqas))
            .catchError((e) => controller.addError(e));
      });
    }

    // This function is called when the listener cancels their subscription.
    void stopListen() {
      dbChangeSubscription?.cancel();
    }

    controller = StreamController<List<HalaqaModel>>(
      onListen: startListen,
      onCancel: stopListen,
    );

    return controller.stream;
  }

  // =========================================================================
  //                             Synchronization Methods
  // =========================================================================

  @override
  Future<void> applySyncBatch({
    required List<HalaqaModel> updatedHalaqas,
    required List<HalaqaModel> deletedHalaqas,
  }) async {
    try {
      // Execute all database modifications within a single atomic transaction
      // to ensure data consistency. If any part fails, all changes are rolled back.
      await _db.transaction((txn) async {
        final batch = txn.batch();

        // --- Handle Upserts ---
        // Insert new records or replace existing ones with fresh data.
        for (final halaqa in updatedHalaqas) {
          batch.insert(
            _kHalqasTable,
            halaqa.toDbMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        // --- Handle Soft Deletes ---
        // Mark records as deleted based on the sync response.
        for (final halaqa in deletedHalaqas) {
          batch.update(
            _kHalqasTable,
            {
              'isDeleted': 1,
              'lastModified': DateTime.now().millisecondsSinceEpoch,
            },
            where: 'roleId = ? AND uuid = ?',
            whereArgs: [UserRole.halaqa.id, halaqa.id],
          );
        }
        // Commit all operations in the batch at once.
        await batch.commit(noResult: true);
      });

      // After the transaction is successfully committed, notify all listeners
      // that the data has changed, triggering a UI refresh.
      _dbChangeNotifier.add(null);
    } on DatabaseException catch (e) {
      // If the transaction fails, wrap the low-level error in a domain-specific exception.
      throw CacheException(
        message: 'Failed to apply sync batch: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> queueSyncOperation({
    required String uuid,
    required String operation,
    Map<String, dynamic>? payload,
  }) async {
    try {
      await _db.insert(_kPendingOperationsTable, {
        'entity_uuid': uuid,
        'entity_type': UserRole.halaqa.label,
        'operation_type': operation,
        'payload': payload != null ? json.encode(payload) : null,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to queue sync operation: ${e.toString()}',
      );
    }
  }

  @override
  Future<int> getLastSyncTimestampFor() async {
    final result = await _db.query(
      _kSyncMetadataTable,
      columns: ['last_server_sync_timestamp'],
      where: 'entity_type = ?',
      whereArgs: [UserRole.halaqa.label],
    );
    if (result.isNotEmpty) {
      return result.first['last_server_sync_timestamp'] as int;
    }
    return 0;
  }

  @override
  Future<void> updateLastSyncTimestampFor(int timestamp) async {
    await _db.insert(_kSyncMetadataTable, {
      'entity_type': UserRole.halaqa.label,
      'last_server_sync_timestamp': timestamp,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> markOperationAsCompleted(int operationId) async {
    // Implementation to DELETE from _kSyncQueueTable where id = operationId...
    throw UnimplementedError();
  }

  @override
  Future<void> upsertHalaqa(HalaqaModel halaqa) async {
    try {
      await _db.insert(
        _kHalqasTable,
        halaqa.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to save halaqa (${halaqa.id}): ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteHalaqa(String halaqaId) async {
    try {
      // Perform a "soft delete" by marking the record as deleted.
      final rowsAffected = await _db.update(
        _kHalqasTable,
        {'isDeleted': 1, 'lastModified': DateTime.now().millisecondsSinceEpoch},
        where: 'uuid = ?',
        whereArgs: [halaqaId],
      );

      if (rowsAffected == 0) {
        // This is not necessarily an error, but could indicate a sync issue.
        // For robustness, we don't throw an exception here unless required.
        print(
          'Warning: Attempted to delete a non-existent halaqa with ID: $halaqaId',
        );
      }
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to delete halaqa ($halaqaId): ${e.toString()}',
      );
    }
  }

  @override
  Future<List<SyncQueueModel>> getPendingSyncOperations() async {
    try {
      final maps = await _db.query(
        _kPendingOperationsTable,
        where: 'entity_type = ? AND status = ?',
        whereArgs: [UserRole.halaqa.label, 'pending'],
        orderBy: 'created_at ASC',
      );
      return maps.map(SyncQueueModel.fromDbMap).toList();
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to get pending operations: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteCompletedOperation(int operationId) async {
    try {
      await _db.delete(
        _kPendingOperationsTable,
        where: 'id = ?',
        whereArgs: [operationId],
      );
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to delete completed operation: ${e.toString()}',
      );
    }
  }

  /// Fetches a single halaqa by their ID from the local database.
  /// Returns a [HalaqaModel] if found, or throws a [CacheException] if   not.
  @override
  Future<HalaqaModel> getHalaqaById(String halaqaId) async {
    try {
      final maps = await _db.query(
        _kHalqasTable,
        where: 'uuid = ? AND roleId = ? AND isDeleted = ?',
        whereArgs: [halaqaId, UserRole.halaqa.id, 0],
      );

      if (maps.isEmpty) {
        throw CacheException(message: 'Halaqa not found with ID: $halaqaId');
      }

      return HalaqaModel.fromDbMap(maps.first);
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to fetch halaqa by ID ($halaqaId): ${e.toString()}',
      );
    }
  }

  // =========================================================================
  //                       NEW: Filtered Query Methods
  // =========================================================================

  @override
  Future<List<HalaqaModel>> getHalaqasByStudentCriteria({

    ActiveStatus? studentStatus,
    DateTime? trackDate,
    Frequency? frequencyCode,
  }) async {
    final query = StringBuffer('SELECT DISTINCT H.* FROM $_kHalqasTable H');

    // هذه الروابط إلزامية لربط الحلقات بالطلاب
    final joins = <String>{
      'JOIN $_kHalqaStudentsTable HS ON H.id = HS.halqaId',
      'JOIN $_kHalqasTable U ON HS.studentId = U.id',
    };

    final whereClauses = <String>[
      'H.isDeleted = 0',
      'U.roleId = ?',
      'U.isDeleted = 0',
    ];
    final whereArgs = <Object?>[UserRole.student.id];

    if (studentStatus != null) {
      whereClauses.add('U.status = ?');
      whereArgs.add(studentStatus.label);
    }

    if (trackDate != null) {
      joins.add('JOIN $_kDailyTrackingTable DT ON HS.id = DT.enrollmentId');

      final formattedDate =
          "${trackDate.year.toString().padLeft(4, '0')}-${trackDate.month.toString().padLeft(2, '0')}-${trackDate.day.toString().padLeft(2, '0')}";
      whereClauses.add('DT.trackDate = ?');
      whereArgs.add(formattedDate);
    }

    if (frequencyCode != null) {
      if (trackDate == null) {
        throw ArgumentError(
          'يجب توفير trackDate عند التصفية باستخدام frequencyCode.',
        );
      }

      joins.add('JOIN $_kFollowUpPlansTable FP ON HS.id = FP.enrollmentId');
      joins.add('JOIN $_kFrequenciesTable F ON FP.frequency = F.id');

      whereClauses.add('F.code = ?');
      whereArgs.add(frequencyCode.id);

      final formattedDate =
          "${trackDate.year.toString().padLeft(4, '0')}-${trackDate.month.toString().padLeft(2, '0')}-${trackDate.day.toString().padLeft(2, '0')}";
      whereClauses.add(
        "CAST(ROUND(JULIANDAY(?) - JULIANDAY(FP.createdAt)) AS INTEGER) % F.daysCount = 0",
      );
      whereArgs.add(formattedDate);
    }

    query.write(' ${joins.join(' ')}');
    query.write(' WHERE ${whereClauses.join(' AND ')}');
    query.write(' ORDER BY H.name ASC');

    try {
      final maps = await _db.rawQuery(query.toString(), whereArgs);
      return maps.map((map) => HalaqaModel.fromDbMap(map)).toList();
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to fetch filtered halaqas from cache: ${e.toString()}',
      );
    }
  }
}

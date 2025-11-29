import 'dart:async';
import 'dart:convert';

import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/models/user_role.dart';
import '../../../../core/models/sync_queue_model.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/teacher_model.dart';
import 'teacher_local_data_source.dart';

/// The name of the table that stores user data, including teachers.

/// The concrete implementation of [TeacherLocalDataSource] using SQLite.
///
/// This class handles all direct database interactions for teacher data,
/// such as querying, inserting, updating, and deleting records. It operates
/// exclusively with [TeacherModel] objects.

/// Table and column name constants to prevent typos.
const String _kUsersTable = 'users';
const String _kPendingOperationsTable = 'pending_operations';
const String _kSyncMetadataTable = 'sync_metadata';

@LazySingleton(as: TeacherLocalDataSource)
final class TeacherLocalDataSourceImpl implements TeacherLocalDataSource {
  final Database _db;
  final AuthLocalDataSource _authLocalDataSource;

  /// A broadcast StreamController that acts as a simple notification bus.
  /// When data in the teachers table changes (e.g., after a sync), we add an
  /// event to this controller to trigger all active listeners to re-fetch.
  final _dbChangeNotifier = StreamController<void>.broadcast();

  TeacherLocalDataSourceImpl(
      {required Database database,
      required AuthLocalDataSource authLocalDataSource})
      : _db = database,
        _authLocalDataSource = authLocalDataSource;

  // =========================================================================
  //                             Data Access Methods
  // =========================================================================

  /// Fetches the current list of teachers from the database.
  /// This is a private helper to avoid code duplication.
  /// It returns a list of [TeacherModel] objects.
  /// Throws a [CacheException] if the database query fails.
  Future<List<TeacherModel>> _fetchCachedTeachers() async {
    final user = await _authLocalDataSource.getCachedUser();
    final tenantId = user.id;
    try {
      final maps = await _db.query(
        _kUsersTable,
        where: 'roleId = ? AND isDeleted = ? AND tenant_id = ?',
        whereArgs: [UserRole.teacher.id, 0, tenantId],
        orderBy: 'name ASC',
      );
      // print(maps);
      return maps.map((map) => TeacherModel.fromMap(map)).toList();
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to fetch teachers from cache: ${e.toString()}',
      );
    } catch (e) {
      throw CacheException(
        message: 'Failed to fetch teachers from cache: ${e.toString()}',
      );
    }
  }

  @override
  Stream<List<TeacherModel>> watchAllTeachers() {
    late StreamController<List<TeacherModel>> controller;
    StreamSubscription? dbChangeSubscription;

    // This function is called when the stream is first listened to.
    void startListen() {
      // 1. Immediately fetch the current data and emit it.
      _fetchCachedTeachers()
          .then((teachers) => controller.add(teachers))
          .catchError((e) => controller.addError(e));

      // 2. Listen for future database change notifications.
      dbChangeSubscription = _dbChangeNotifier.stream.listen((_) {
        // When a change occurs, re-fetch the data and emit it.
        _fetchCachedTeachers()
            .then((teachers) => controller.add(teachers))
            .catchError((e) => controller.addError(e));
      });
    }

    // This function is called when the listener cancels their subscription.
    void stopListen() {
      dbChangeSubscription?.cancel();
    }

    controller = StreamController<List<TeacherModel>>(
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
    required List<TeacherModel> updatedTeachers,
    required List<TeacherModel> deletedTeachers,
  }) async {
    final user = await _authLocalDataSource.getCachedUser();
    final tenantId = user.id;
    try {
      // Execute all database modifications within a single atomic transaction
      // to ensure data consistency. If any part fails, all changes are rolled back.
      await _db.transaction((txn) async {
        final batch = txn.batch();

        // --- Handle Upserts ---
        // Insert new records or replace existing ones with fresh data.
        for (final teacher in updatedTeachers) {
          final teacherMap = teacher.toMap();
          teacherMap['tenant_id'] = tenantId;
          batch.insert(
            _kUsersTable,
            teacherMap,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        // --- Handle Soft Deletes ---
        // Mark records as deleted based on the sync response.
        for (final teacher in deletedTeachers) {
          batch.update(
            _kUsersTable,
            {
              'isDeleted': 1,
              'lastModified': DateTime.now().millisecondsSinceEpoch,
            },
            where: 'roleId = ? AND uuid = ? AND tenant_id = ?',
            whereArgs: [UserRole.teacher.id, teacher.id, tenantId],
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
    final user = await _authLocalDataSource.getCachedUser();
    final tenantId = user.id;
    try {
      await _db.insert(_kPendingOperationsTable, {
        'entity_uuid': uuid,
        'entity_type': UserRole.teacher.label,
        'operation_type': operation,
        'payload': payload != null ? json.encode(payload) : null,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'tenant_id': tenantId,
      });
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to queue sync operation: ${e.toString()}',
      );
    }
  }

  @override
  Future<int> getLastSyncTimestampFor() async {
    final user = await _authLocalDataSource.getCachedUser();
    final tenantId = user.id;
    final result = await _db.query(
      _kSyncMetadataTable,
      columns: ['last_server_sync_timestamp'],
      where: 'entity_type = ? AND tenant_id = ?',
      whereArgs: [UserRole.teacher.label, tenantId],
    );
    if (result.isNotEmpty) {
      return result.first['last_server_sync_timestamp'] as int;
    }
    return 0;
  }

  @override
  Future<void> updateLastSyncTimestampFor(int timestamp) async {
    final user = await _authLocalDataSource.getCachedUser();
    final tenantId = user.id;
    await _db.insert(
        _kSyncMetadataTable,
        {
          'entity_type': UserRole.teacher.label,
          'last_server_sync_timestamp': timestamp,
          'tenant_id': tenantId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> markOperationAsCompleted(int operationId) async {
    // Implementation to DELETE from _kSyncQueueTable where id = operationId...
    throw UnimplementedError();
  }

  @override
  Future<void> upsertTeacher(TeacherModel teacher) async {
    final user = await _authLocalDataSource.getCachedUser();
    final tenantId = user.id;
    try {
      final teacherMap = teacher.toMap();
      teacherMap['tenant_id'] = tenantId;
      await _db.insert(
        _kUsersTable,
        teacherMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to save teacher (${teacher.id}): ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteTeacher(String teacherId) async {
    final user = await _authLocalDataSource.getCachedUser();
    final tenantId = user.id;
    try {
      // Perform a "soft delete" by marking the record as deleted.
      final rowsAffected = await _db.update(
        _kUsersTable,
        {'isDeleted': 1, 'lastModified': DateTime.now().millisecondsSinceEpoch},
        where: 'uuid = ? AND tenant_id = ?',
        whereArgs: [teacherId, tenantId],
      );

      if (rowsAffected == 0) {
        // This is not necessarily an error, but could indicate a sync issue.
        // For robustness, we don't throw an exception here unless required.
        print(
          'Warning: Attempted to delete a non-existent teacher with ID: $teacherId',
        );
      }
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to delete teacher ($teacherId): ${e.toString()}',
      );
    }
  }

  @override
  Future<List<SyncQueueModel>> getPendingSyncOperations() async {
    final user = await _authLocalDataSource.getCachedUser();
    final tenantId = user.id;
    try {
      final maps = await _db.query(
        _kPendingOperationsTable,
        where: 'entity_type = ? AND status = ? AND tenant_id = ?',
        whereArgs: [UserRole.teacher.label, 'pending', tenantId],
        orderBy: 'created_at ASC',
      );
      return maps.map(SyncQueueModel.fromMap).toList();
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to get pending operations: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteCompletedOperation(int operationId) async {
    final user = await _authLocalDataSource.getCachedUser();
    final tenantId = user.id;
    try {
      await _db.delete(
        _kPendingOperationsTable,
        where: 'id = ? AND tenant_id = ?',
        whereArgs: [operationId, tenantId],
      );
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to delete completed operation: ${e.toString()}',
      );
    }
  }

  /// Fetches a single teacher by their ID from the local database.
  /// Returns a [TeacherModel] if found, or throws a [CacheException] if   not.
  @override
  Future<TeacherModel> getTeacherById(String teacherId) async {
    final user = await _authLocalDataSource.getCachedUser();
    final tenantId = user.id;
    try {
      final maps = await _db.query(
        _kUsersTable,
        where: 'uuid = ? AND roleId = ? AND isDeleted = ? AND tenant_id = ?',
        whereArgs: [teacherId, UserRole.teacher.id, 0, tenantId],
      );

      if (maps.isEmpty) {
        throw CacheException(message: 'Teacher not found with ID: $teacherId');
      }

      return TeacherModel.fromMap(maps.first);
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to fetch teacher by ID ($teacherId): ${e.toString()}',
      );
    }
  }
}

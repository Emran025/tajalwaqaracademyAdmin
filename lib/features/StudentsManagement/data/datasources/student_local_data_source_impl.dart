import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tajalwaqaracademy/core/errors/exceptions.dart';
import 'package:tajalwaqaracademy/core/models/user_role.dart';
import '../models/student_model.dart';
import '../models/sync_queue_model.dart';
import 'student_local_data_source.dart';

/// The name of the table that stores user data, including students.

/// The concrete implementation of [StudentLocalDataSource] using SQLite.
///
/// This class handles all direct database interactions for student data,
/// such as querying, inserting, updating, and deleting records. It operates
/// exclusively with [StudentModel] objects.

/// Table and column name constants to prevent typos.
const String _kUsersTable = 'users';
const String _kPendingOperationsTable = 'pending_operations';
const String _kSyncMetadataTable = 'sync_metadata';

@LazySingleton(as: StudentLocalDataSource)
final class StudentLocalDataSourceImpl implements StudentLocalDataSource {
  final Database _db;

  /// A broadcast StreamController that acts as a simple notification bus.
  /// When data in the students table changes (e.g., after a sync), we add an
  /// event to this controller to trigger all active listeners to re-fetch.
  final _dbChangeNotifier = StreamController<void>.broadcast();

  StudentLocalDataSourceImpl({required Database database}) : _db = database;

  // =========================================================================
  //                             Data Access Methods
  // =========================================================================

  /// Fetches the current list of students from the database.
  /// This is a private helper to avoid code duplication.
  /// It returns a list of [StudentModel] objects.
  /// Throws a [CacheException] if the database query fails.
  Future<List<StudentModel>> _fetchCachedStudents() async {
    try {
      final maps = await _db.query(
        _kUsersTable,
        where: 'roleId = ? AND isDeleted = ?',
        whereArgs: [UserRole.student.id, 0],
        orderBy: 'name ASC',
      );
      print(maps);
      return maps.map((map) => StudentModel.fromDbMap(map)).toList();
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to fetch students from cache: ${e.toString()}',
      );
    }
  }

  @override
  Stream<List<StudentModel>> watchAllStudents() {
    late StreamController<List<StudentModel>> controller;
    StreamSubscription? dbChangeSubscription;

    // This function is called when the stream is first listened to.
    void startListen() {
      // 1. Immediately fetch the current data and emit it.
      _fetchCachedStudents()
          .then((students) => controller.add(students))
          .catchError((e) => controller.addError(e));

      // 2. Listen for future database change notifications.
      dbChangeSubscription = _dbChangeNotifier.stream.listen((_) {
        // When a change occurs, re-fetch the data and emit it.
        _fetchCachedStudents()
            .then((students) => controller.add(students))
            .catchError((e) => controller.addError(e));
      });
    }

    // This function is called when the listener cancels their subscription.
    void stopListen() {
      dbChangeSubscription?.cancel();
    }

    controller = StreamController<List<StudentModel>>(
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
    required List<StudentModel> updatedStudents,
    required List<StudentModel> deletedStudents,
  }) async {
    try {
      // Execute all database modifications within a single atomic transaction
      // to ensure data consistency. If any part fails, all changes are rolled back.
      await _db.transaction((txn) async {
        final batch = txn.batch();

        // --- Handle Upserts ---
        // Insert new records or replace existing ones with fresh data.
        for (final student in updatedStudents) {
          batch.insert(
            _kUsersTable,
            student.toDbMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        // --- Handle Soft Deletes ---
        // Mark records as deleted based on the sync response.
        for (final student in deletedStudents) {
          batch.update(
            _kUsersTable,
            {
              'isDeleted': 1,
              'lastModified': DateTime.now().millisecondsSinceEpoch,
            },
            where: 'roleId = ? AND uuid = ?',
            whereArgs: [UserRole.student.id, student.id],
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
        'entity_type': UserRole.student.label,
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
      whereArgs: [UserRole.student.label],
    );
    if (result.isNotEmpty) {
      return result.first['last_server_sync_timestamp'] as int;
    }
    return 0;
  }

  @override
  Future<void> updateLastSyncTimestampFor(int timestamp) async {
    await _db.insert(_kSyncMetadataTable, {
      'entity_type': UserRole.student.label,
      'last_server_sync_timestamp': timestamp,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> markOperationAsCompleted(int operationId) async {
    // Implementation to DELETE from _kSyncQueueTable where id = operationId...
    throw UnimplementedError();
  }

  @override
  Future<void> upsertStudent(StudentModel student) async {
    try {
      await _db.insert(
        _kUsersTable,
        student.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to save student (${student.id}): ${e.toString()}',
      );
    }
  }
  @override
  Future<void> upsertStudentPlan(StudentModel student) async {
    try {
      await _db.insert(
        _kUsersTable,
        student.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to save student (${student.id}): ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteStudent(String studentId) async {
    try {
      // Perform a "soft delete" by marking the record as deleted.
      final rowsAffected = await _db.update(
        _kUsersTable,
        {'isDeleted': 1, 'lastModified': DateTime.now().millisecondsSinceEpoch},
        where: 'uuid = ?',
        whereArgs: [studentId],
      );

      if (rowsAffected == 0) {
        // This is not necessarily an error, but could indicate a sync issue.
        // For robustness, we don't throw an exception here unless required.
        print(
          'Warning: Attempted to delete a non-existent student with ID: $studentId',
        );
      }
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to delete student ($studentId): ${e.toString()}',
      );
    }
  }

  @override
  Future<List<SyncQueueModel>> getPendingSyncOperations() async {
    try {
      final maps = await _db.query(
        _kPendingOperationsTable,
        where: 'entity_type = ? AND status = ?',
        whereArgs: [UserRole.student.label, 'pending'],
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

  /// Fetches a single student by their ID from the local database.
  /// Returns a [StudentModel] if found, or throws a [CacheException] if   not.
  @override
  Future<StudentModel> getStudentById(String studentId) async {
    try {
      final maps = await _db.query(
        _kUsersTable,
        where: 'uuid = ? AND roleId = ? AND isDeleted = ?',
        whereArgs: [studentId, UserRole.student.id, 0],
      );

      if (maps.isEmpty) {
        throw CacheException(message: 'Student not found with ID: $studentId');
      }

      return StudentModel.fromDbMap(maps.first);
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to fetch student by ID ($studentId): ${e.toString()}',
      );
    }
  }
}

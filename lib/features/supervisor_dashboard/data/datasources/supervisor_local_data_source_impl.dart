import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

import 'package:tajalwaqaracademy/core/models/user_role.dart';
import 'package:tajalwaqaracademy/features/auth/data/datasources/auth_local_data_source.dart';

import '../models/count_delta.dart';
import '../models/student_summaray_record.dart';
import '../models/student_summary_delta.dart';
import 'supervisor_local_data_source.dart';

/// The name of the table that stores user data, including students.

/// The concrete implementation of [SupervisorLocalDataSource] using SQLite.
///
/// This class handles all direct database interactions for student data,
/// such as querying, inserting, updating, and deleting records. It operates
/// exclusively with [SupervisorModel] objects.

/// Table and column name constants to prevent typos.
const String _kUsersTable = 'users';
const String _kHalqasTable = 'halqas';

const String _kEntityDailySummary = 'entity_daily_summary';
const String _kSyncMetadataTable = 'sync_metadata';
const String _kEntityCount = 'entity_count';

@LazySingleton(as: SupervisorLocalDataSource)
final class SupervisorLocalDataSourceImpl implements SupervisorLocalDataSource {
  final Database _db;
  final AuthLocalDataSource _authLocalDataSource;

  SupervisorLocalDataSourceImpl(
      {required Database database,
      required AuthLocalDataSource authLocalDataSource})
      : _db = database,
        _authLocalDataSource = authLocalDataSource;

  @override
  Future<List<Record>> getAllEntitysWithTimestamps(UserRole entityType) async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    final String table;
    final String whereCondation;
    if (entityType == UserRole.halaqa) {
      table = _kHalqasTable;
      whereCondation = "WHERE tenant_id = ?";
    } else {
      whereCondation = "WHERE roleId = ? AND tenant_id = ?";
      table = _kUsersTable;
    }
    final result = await _db.rawQuery('''
      SELECT
        id,
        createdAt,
        lastModified,
        isDeleted
      FROM $table
      $whereCondation
      ORDER BY createdAt
    ''', (entityType == UserRole.halaqa) ? [tenantId] : [entityType.id, tenantId]);

    return result.map((map) => Record.fromMap(map)).toList();
  }

  @override
  Future<List<DateTime>> getStartEndTimes(UserRole entityType) async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    final String table;
    final String whereCondation;
    if (entityType == UserRole.halaqa) {
      table = _kHalqasTable;
      whereCondation = "WHERE tenant_id = ?";
    } else {
      whereCondation = "WHERE roleId = ? AND tenant_id = ?";
      table = _kUsersTable;
    }
    final result = await _db.rawQuery('''
      SELECT
        min(createdAt) as startTime,
        max(lastModified) as endTime
      FROM $table
      $whereCondation
    ''', (entityType == UserRole.halaqa) ? [tenantId] : [entityType.id, tenantId]);

    if (result.isEmpty ||
        result.first['startTime'] == null ||
        result.first['endTime'] == null) {
      return [];
    }

    final row = result.first;
    return [
      DateTime.parse(row['startTime'] as String),
      DateTime.parse(row['endTime'] as String),
    ];
  }

  @override
  Future<void> insertDailySummary(SummaryDelta summary) async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    final summaryMap = summary.toMap();
    summaryMap['tenant_id'] = tenantId;
    await _db.insert(
      _kEntityDailySummary,
      summaryMap,
      conflictAlgorithm: ConflictAlgorithm.replace, // هذا السطر المهم
    );
  }

  @override
  Future<List<SummaryDelta>> getAllDailySummaries(UserRole entityType) async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    final List<Map<String, dynamic>> maps = await _db.query(
      _kEntityDailySummary,
      orderBy: 'date DESC',
      where: 'entity_type = ? AND tenant_id = ?',
      whereArgs: [entityType.id, tenantId],
    );

    return maps.map((map) => SummaryDelta.fromMap(map)).toList();
  }

  @override
  Future<int> getEntitesCount(UserRole entityType) async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    final String table;
    final List<dynamic> whereArgs = [0, tenantId]; // isDeleted = 0

    String whereCondition = "WHERE isDeleted = ? AND tenant_id = ?";

    if (entityType == UserRole.halaqa) {
      table = _kHalqasTable;
    } else {
      whereCondition += " AND roleId = ?";
      table = _kUsersTable;
      whereArgs.add(entityType.id);
    }

    final result = await _db.rawQuery('''
    SELECT COUNT(*) as count
    FROM $table
    $whereCondition
    ''', whereArgs);

    if (result.isEmpty || result.first['count'] == null) {
      return 0;
    }

    final row = result.first;
    final count = row['count'];
    return count is int ? count : int.parse(count.toString());
  }

  Future<CountDelta> _getCount(UserRole entityType) async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    final List<Map<String, dynamic>> maps = await _db.query(
      _kEntityCount,
      orderBy: 'date DESC',
      where: 'entity_type = ? AND tenant_id = ?',
      whereArgs: [entityType.id, tenantId],
    );
    print("$entityType result : ========================$maps");

    if (maps.isEmpty) {
      // defoult value
      return CountDelta(entityType: entityType, count: 0, date: DateTime.now());
    }

    return CountDelta.fromMap(maps.first);
  }

  @override
  Future<CountsDelta> getCounts() async {
    return CountsDelta(
      studentCount: await _getCount(UserRole.student),
      teacherCount: await _getCount(UserRole.teacher),
      halaqaCount: await _getCount(UserRole.halaqa),
    );
  }

  // final studentCount = await _getCount(UserRole.student);
  // print("==========${studentCount.count}==========");
  // final teacherCount = await _getCount(UserRole.teacher);
  // print("==========${teacherCount.count}==========");
  // final halaqaCount = await _getCount(UserRole.halaqa);
  // print("==========${halaqaCount.count}==========");
  // return CountsDelta(
  //   studentCount: studentCount,
  //   halaqaCount: halaqaCount,
  //   teacherCount: teacherCount,
  // );
  @override
  Future<void> insertCount(CountDelta count) async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    final countMap = count.toMap();
    countMap['tenant_id'] = tenantId;
    await _db.insert(
      _kEntityCount,
      countMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print("entityType : ========================${count.entityType}");
    print("count : ========================${count.count}");
    print("date : ========================${count.date}");
    print("toMap : ========================${count.toMap()}");
  }

  @override
  Future<List<SummaryDelta>> getDailySummariesInDateRange(
    DateTime startDate,
    DateTime endDate,
    UserRole entityType,
  ) async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    final List<Map<String, dynamic>> maps = await _db.query(
      _kEntityDailySummary,
      where: 'date BETWEEN ? AND ? AND entity_type = ? AND tenant_id = ?',
      whereArgs: [
        startDate.toIso8601String().split('T').first,
        endDate.toIso8601String().split('T').first,
        entityType.id,
        tenantId,
      ],
      orderBy: 'date ASC',
    );

    return maps.map((map) => SummaryDelta.fromMap(map)).toList();
  }

  ///
  @override
  Future<int> getLastSyncTimestampFor(String entityType) async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    final result = await _db.query(
      _kSyncMetadataTable,
      columns: ['last_server_sync_timestamp'],
      where: 'entity_type = ? AND tenant_id = ?',
      whereArgs: [entityType, tenantId],
    );

    if (result.isNotEmpty) {
      final timestamp = result.first['last_server_sync_timestamp'];

      // Handle both string and int formats
      if (timestamp is int) {
        return timestamp;
      } else if (timestamp is String) {
        return int.tryParse(timestamp) ?? 0;
      }
    }
    return 0;
  }

  @override
  Future<void> updateLastSyncTimestampFor(
    String entityType,
    int timestamp,
  ) async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    await _db.insert(
        _kSyncMetadataTable,
        {
          'entity_type': entityType,
          'last_server_sync_timestamp': timestamp, // Store as int
          'tenant_id': tenantId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}


// I/flutter (24601): {login: amran@naser.com, password: amran$$$025, device_info: {device_id: AE3A.240806.043, model: sdk_gphone64_x86_64, manufacturer: Google, os_version: Android 15 (SDK 35), app_version: 1.0.0+1, timezone: Asia/Riyadh, locale: en_US, fcm_token: dummy_push_token_for_development_env}}
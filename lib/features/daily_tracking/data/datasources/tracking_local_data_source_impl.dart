import 'dart:convert';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tajalwaqaracademy/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:uuid/uuid.dart';

// Core imports
import 'package:tajalwaqaracademy/core/database/app_database.dart';
import 'package:tajalwaqaracademy/core/error/exceptions.dart';
import 'package:tajalwaqaracademy/core/models/sync_queue_model.dart';
import 'package:tajalwaqaracademy/core/models/tracking_type.dart';

// Models
import 'package:tajalwaqaracademy/features/StudentsManagement/data/models/tracking_detail_model.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/data/models/mistake_model.dart';

// The contract it implements
import 'package:tajalwaqaracademy/features/daily_tracking/data/datasources/quran_local_data_source.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/bar_chart_datas.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/chart_data_point.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/entities/chart_filter.dart';
import '../../domain/entities/stop_point.dart';
import 'tracking_local_data_source.dart';
import 'package:tajalwaqaracademy/core/models/mistake_type.dart';

// Models

// Table and column name constants for consistency.
const String _kDailyTrackingTable = 'daily_tracking';
const String _kDailyTrackingDetailTable = 'daily_tracking_detail';
const String _kMistakesTable = 'mistakes';
const String _kPendingOperationsTable = 'pending_operations';
const String _kSyncMetadataTable = 'sync_metadata';
const String _kTrackingEntityType = 'tracking';

/// The concrete implementation of [TrackingLocalDataSource].
///
/// This class handles all direct database interactions for the interactive
/// recitation tracking feature. It manages "draft" sessions, saves progress,
/// finalizes reports, and queues operations for synchronization, all while
/// maintaining data integrity through transactions and robust error handling.
@LazySingleton(as: TrackingLocalDataSource)
final class TrackingLocalDataSourceImpl implements TrackingLocalDataSource {
  final AppDatabase _appDb;
  final QuranLocalDataSource _quranDataSource;
  final AuthLocalDataSource _authLocalDataSource;

  TrackingLocalDataSourceImpl(
      this._appDb, this._quranDataSource, this._authLocalDataSource);

  // =========================================================================
  //                             Core Public Methods
  // =========================================================================

  @override
  Future<Map<TrackingType, TrackingDetailModel>>
      getOrCreateTodayDraftTrackingDetails({required int enrollmentId}) async {
    final db = await _appDb.database;
    final user = await _authLocalDataSource.getCachedUser();
    final tenantId = user.id;
    try {
      final trackingRecord = await _findOrCreateParentDraftTracking(
        db,
        enrollmentId,
        tenantId,
      );
      final trackingId = trackingRecord['id'] as int;

      var detailMaps = await db.query(
        _kDailyTrackingDetailTable,
        where: 'trackingId = ?',
        whereArgs: [trackingId],
      );
      if (detailMaps.length < 3) {
        final lastUnitsMap =
            await _getLastCompletedUnitIds(db, enrollmentId, tenantId);
        await _createMissingDetails(db, trackingId, tenantId,
            startUnits: lastUnitsMap);
        detailMaps = await db.query(
          _kDailyTrackingDetailTable,
          where: 'trackingId = ?',
          whereArgs: [trackingId],
        );
      }

      final List<TrackingDetailModel> fullDetails =
          await _fetchDetailsWithMistakes(db, detailMaps);
      return {for (var detail in fullDetails) detail.trackingTypeId: detail};
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to get/create tracking details: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> saveDraftTrackingDetails(
    List<TrackingDetailModel> details,
  ) async {
    if (details.isEmpty) return;
    final db = await _appDb.database;
    final user = await _authLocalDataSource.getCachedUser();
    final tenantId = user.id;
    try {
      await db.transaction((txn) async {
        final batch = txn.batch();
        for (final detail in details) {
          batch.update(
            _kDailyTrackingDetailTable,
            detail.toDbMap(detail.trackingId),
            where: 'id = ?',
            whereArgs: [detail.id],
          );
          batch.delete(
            _kMistakesTable,
            where: 'trackingDetailId = ?',
            whereArgs: [detail.id],
          );
          for (final mistake in detail.mistakes) {
            final mistakeMap = mistake.toDbMap(detail.id);
            mistakeMap['tenant_id'] = tenantId;
            batch.insert(_kMistakesTable, mistakeMap);
          }
        }
        await batch.commit(noResult: true);
        final parentTrackingUuid = await _getParentTrackingUuid(
          txn,
          details.first.trackingId,
        );
        await _queueSyncOperation(
            dbExecutor: txn,
            uuid: parentTrackingUuid,
            operation: 'update',
            tenantId: tenantId);
      });
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to save draft tracking progress: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> finalizeDailyTracking({
    required int trackingId,
    required String finalNotes,
    required int behaviorScore,
  }) async {
    final db = await _appDb.database;
    final user = await _authLocalDataSource.getCachedUser();
    final tenantId = user.id;
    try {
      await db.transaction((txn) async {
        // 1. Retrieve the current record data (Draft) to find the date and student

        final currentRecord = await txn.query(
          _kDailyTrackingTable,
          columns: ['enrollmentId', 'trackDate', 'uuid'],
          where: 'id = ?',
          whereArgs: [trackingId],
        );

        if (currentRecord.isEmpty) {
          throw CacheException(message: 'Tracking record not found');
        }

        final enrollmentId = currentRecord.first['enrollmentId'] as int;
        final trackDate = currentRecord.first['trackDate'] as String;
        final currentUuid = currentRecord.first['uuid'] as String;

        // 2. Search for a completed record for the same student on the same day
        final oldCompletedRecord = await txn.query(
          _kDailyTrackingTable,
          where:
              'enrollmentId = ? AND trackDate = ? AND status = ? AND id != ? AND tenant_id = ?',
          whereArgs: [
            enrollmentId,
            trackDate,
            'completed',
            trackingId,
            tenantId
          ],
        );

        if (oldCompletedRecord.isNotEmpty) {
          // =============================================================
          // Merger Scenario: A previous record is complete; the current one will be merged into it.
          // ==========================================================

          final oldRecordId = oldCompletedRecord.first['id'] as int;
          final oldRecordUuid = oldCompletedRecord.first['uuid'] as String;

          // A. Update the old record header with the new data
          await txn.update(
            _kDailyTrackingTable,
            {
              'note': finalNotes,
              'behaviorNote': behaviorScore,
              'lastModified': DateTime.now().millisecondsSinceEpoch,
            },
            where: 'id = ?',
            whereArgs: [oldRecordId],
          );

          // B. Retrieve the details of the two records (old and new) to merge them
          final oldDetails = await txn.query(
            _kDailyTrackingDetailTable,
            where: 'trackingId = ?',
            whereArgs: [oldRecordId],
          );
          final newDetails = await txn.query(
            _kDailyTrackingDetailTable,
            where: 'trackingId = ?',
            whereArgs: [trackingId],
          );

          // C. Combining details for each type (save, review, narrate)
          for (var newDetail in newDetails) {
            final typeId = newDetail['typeId'];
            // Search for the corresponding detail in the old record
            final matchingOldDetail = oldDetails.firstWhereOrNull(
              (d) => d['typeId'] == typeId,
            );

            if (matchingOldDetail != null) {
              // There is an old detail: We are updating
              // Rule: From (old), To (new)
              // But only if there is a new progress in the new record
              if (newDetail['toTrackingUnitId'] != null) {
                await txn.update(
                  _kDailyTrackingDetailTable,
                  {
                    'toTrackingUnitId': newDetail['toTrackingUnitId'],
                    'actualAmount': newDetail['actualAmount'],
                    'score': newDetail['score'],
                    'gap': newDetail['gap'],
                    'comment':
                        newDetail['comment'], // أو دمج التعليقين إذا أردت
                    'lastModified': DateTime.now().millisecondsSinceEpoch,
                  },
                  where: 'id = ?',
                  whereArgs: [matchingOldDetail['id']],
                );
              }

              // D. Transferring Mistakes from the New Detail to the Old Detail
              // We update the trackingDetailId in the Mistakes table to point to the old one.
              await txn.update(
                _kMistakesTable,
                {'trackingDetailId': matchingOldDetail['id']},
                where: 'trackingDetailId = ?',
                whereArgs: [newDetail['id']],
              );
            }
          }

          // e. The new record (Draft) will be completely deleted because it has been merged.
          // (Since Cascade deletion is enabled in the table, the Draft details will be deleted automatically.)
          // (We have already moved the errors to the old record, so there is no need to worry.)
          await txn.delete(
            _kDailyTrackingTable,
            where: 'id = ?',
            whereArgs: [trackingId],
          );

          // And. Adding the synchronization process to the old record (because it is the one that remained and was modified)
          await _queueSyncOperation(
              dbExecutor: txn,
              uuid: oldRecordUuid, // We use the old record UUID
              operation: 'update',
              tenantId: tenantId);
        } else {
          // =============================================================
          // Normal scenario: No previous record, current converted to Completed
          // ==========================================================

          await txn.update(
            _kDailyTrackingTable,
            {
              'status': 'completed',
              'note': finalNotes,
              'behaviorNote': behaviorScore,
              'lastModified': DateTime.now().millisecondsSinceEpoch,
            },
            where: 'id = ?',
            whereArgs: [trackingId],
          );

          await txn.update(
            _kDailyTrackingDetailTable,
            {'status': 'completed'},
            where: '''
                trackingId = ? 
                AND fromTrackingUnitId IS NOT NULL 
                AND toTrackingUnitId IS NOT NULL 
                AND fromTrackingUnitId != toTrackingUnitId
            ''',
            whereArgs: [trackingId],
          );

          await _queueSyncOperation(
              dbExecutor: txn,
              uuid: currentUuid,
              operation: 'update',
              tenantId: tenantId);
        }
      });
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to finalize daily tracking: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<MistakeModel>> getAllMistakes({
    required int enrollmentId,
    TrackingType? type,
    int? fromPage,
    int? toPage,
  }) async {
    final db = await _appDb.database;
    final user = await _authLocalDataSource.getCachedUser();
    final tenantId = user.id;
    try {
      String baseQuery = '''
      SELECT m.*
      FROM $_kMistakesTable AS m
      INNER JOIN $_kDailyTrackingDetailTable AS tdt ON m.trackingDetailId = tdt.id
      INNER JOIN $_kDailyTrackingTable AS dt ON tdt.trackingId = dt.id
      INNER JOIN quran AS q ON m.ayahId_quran = q.id 
      WHERE dt.enrollmentId = ? AND dt.tenant_id = ?
        -- AND tdt.status = 'completed'
    ''';

      List<dynamic> arguments = [enrollmentId, tenantId];

      // ================== DYNAMIC TYPE FILTERING ==================
      if (type != null) {
        baseQuery += ' AND tdt.typeId = ?';
        arguments.add(type.id);
      }
      // ==========================================================

      if (fromPage != null) {
        baseQuery += ' AND q.page >= ?';
        arguments.add(fromPage);
      }

      if (toPage != null) {
        baseQuery += ' AND q.page <= ?';
        arguments.add(toPage);
      }

      // Add ordering to make the result predictable and easy to group
      baseQuery += ' ORDER BY tdt.typeId, dt.trackDate DESC';

      final List<Map<String, dynamic>> results = await db.rawQuery(
        baseQuery,
        arguments,
      );
      return results.map((map) => MistakeModel.fromDbMap(map)).toList();
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to fetch all mistakes: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<BarChartDatas>> getErrorAnalysisChartData({
    required int enrollmentId,
    required ChartFilter filter,
  }) async {
    final db = await _appDb.database;
    final user = await _authLocalDataSource.getCachedUser();
    final tenantId = user.id;
    try {
      if (filter.dimension == FilterDimension.time) {
        return _fetchDataByTime(db, enrollmentId, tenantId, filter);
      } else {
        return _fetchDataByQuantity(db, enrollmentId, tenantId, filter);
      }
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to fetch error analysis data: ${e.toString()}',
      );
    }
  }

  Future<List<BarChartDatas>> _fetchDataByTime(
    Database db,
    int enrollmentId,
    String tenantId,
    ChartFilter filter,
  ) async {
    String dateFormat;
    bool isQuarter = filter.timePeriod == 'quarter';

    if (isQuarter) {
      dateFormat = '%Y-%m'; // Fetch by month, then group by quarter in Dart
    } else {
      switch (filter.timePeriod) {
        case 'year':
          dateFormat = '%Y';
          break;
        case 'week':
          dateFormat = '%Y-%W';
          break;
        default:
          dateFormat = '%Y-%m';
      }
    }

    final query =
        '''
      SELECT
        m.mistakeTypeId,
        COUNT(m.id) as mistakeCount,
        STRFTIME('$dateFormat', dt.trackDate) as period
      FROM $_kMistakesTable AS m
      JOIN $_kDailyTrackingDetailTable AS dtd ON m.trackingDetailId = dtd.id
      JOIN $_kDailyTrackingTable AS dt ON dtd.trackingId = dt.id
      WHERE dt.enrollmentId = ? AND dtd.typeId = ? AND dt.tenant_id = ?
      GROUP BY period, m.mistakeTypeId
      ORDER BY period ASC;
    ''';

    final trackingType = TrackingType.values.firstWhere(
      (e) => e.toString().endsWith(filter.trackingType),
    );
    final results =
        await db.rawQuery(query, [enrollmentId, trackingType.id, tenantId]);
    if (results.isEmpty) return [];

    if (isQuarter) {
      return _groupMonthsIntoQuarters(results);
    }

    // Group by period (for non-quarter filters)
    final groupedByPeriod = groupBy<Map<String, dynamic>, String>(
      results,
      (row) => row['period'],
    );

    final List<BarChartDatas> chartDataList = [];
    for (final period in groupedByPeriod.keys) {
      final periodMistakes = groupedByPeriod[period]!;
      final dataPoints = _calculateDataPoints(periodMistakes);

      DateTime? periodDate;
      if (filter.timePeriod == 'year') {
        periodDate = DateTime.tryParse('$period-01-01');
      } else if (filter.timePeriod == 'week') {
        final parts = period.split('-');
        final year = int.parse(parts[0]);
        final week = int.parse(parts[1]);
        // This is an approximation: the first day of the week.
        periodDate = DateTime(year, 1, 1).add(Duration(days: (week - 1) * 7));
      } else {
        periodDate = DateTime.tryParse('$period-01');
      }

      chartDataList.add(
        BarChartDatas(
          data: dataPoints,
          xAxisLabel: ' أنواع الأخطاء',
          yAxisLabel: 'العدد',
          periodDate: periodDate,
        ),
      );
    }
    return chartDataList;
  }

  List<BarChartDatas> _groupMonthsIntoQuarters(
    List<Map<String, dynamic>> monthlyResults,
  ) {
    final groupedByQuarter = groupBy<Map<String, dynamic>, String>(
      monthlyResults,
      (row) {
        final yearMonth = (row['period'] as String).split('-');
        final month = int.parse(yearMonth[1]);
        final quarter = (month - 1) ~/ 3 + 1;
        return '${yearMonth[0]}-Q$quarter';
      },
    );

    final List<BarChartDatas> chartDataList = [];
    for (final quarter in groupedByQuarter.keys) {
      final quarterMistakes = groupedByQuarter[quarter]!;
      final dataPoints = _calculateDataPoints(quarterMistakes);

      final year = int.parse(quarter.split('-Q')[0]);
      final quarterNum = int.parse(quarter.split('-Q')[1]);
      final month = (quarterNum - 1) * 3 + 1;
      final periodDate = DateTime(year, month, 1);

      chartDataList.add(
        BarChartDatas(
          data: dataPoints,
          xAxisLabel: 'أنواع الأخطاء',
          yAxisLabel: 'العدد',
          periodDate: periodDate,
        ),
      );
    }
    return chartDataList;
  }

  List<ChartDataPoint> _calculateDataPoints(
    List<Map<String, dynamic>> mistakes,
  ) {
    return MistakeType.values.where((e) => e != MistakeType.none).map((
      mistakeType,
    ) {
      final count = mistakes
          .where((r) => r['mistakeTypeId'] == mistakeType.id)
          .fold<int>(0, (sum, r) => sum + (r['mistakeCount'] as int));
      return ChartDataPoint(
        label: mistakeType.labelAr,
        value: count.toDouble(),
      );
    }).toList();
  }

  Future<List<BarChartDatas>> _fetchDataByQuantity(
    Database db,
    int enrollmentId,
    String tenantId,
    ChartFilter filter,
  ) async {
    final trackingType = TrackingType.values.firstWhere(
      (e) => e.toString().endsWith(filter.trackingType),
    );
    final allMistakesQuery = '''
      SELECT m.mistakeTypeId, m.ayahId_quran
      FROM $_kMistakesTable AS m
      JOIN $_kDailyTrackingDetailTable AS dtd ON m.trackingDetailId = dtd.id
      JOIN $_kDailyTrackingTable AS dt ON dtd.trackingId = dt.id
      WHERE dt.enrollmentId = ? AND dtd.typeId = ? AND dt.tenant_id = ?;
    ''';
    final mistakeResults = await db.rawQuery(
        allMistakesQuery, [enrollmentId, trackingType.id, tenantId]);
    if (mistakeResults.isEmpty) return [];

    // 2. Get Ayah details from Quran DB
    final ayahIds = mistakeResults
        .map((r) => r['ayahId_quran'] as int)
        .toSet()
        .toList();
    final ayahs = await _quranDataSource.getMistakesAyahs(ayahIds);
    final ayahMap = {for (var ayah in ayahs) ayah.number: ayah};

    // 3. Group mistakes by the quantitative unit
    String Function(int) getGroupingKey;
    switch (filter.quantityUnit) {
      case 'juz':
        getGroupingKey = (ayahId) => ayahMap[ayahId]?.juz.toString() ?? '0';
        break;
      case 'hizb':
        getGroupingKey = (ayahId) => (ayahMap[ayahId]?.juz ?? 0 / 2).toString();
        break;
      case 'page':
      default:
        getGroupingKey = (ayahId) => ayahMap[ayahId]?.page.toString() ?? '0';
        break;
    }

    final groupedMistakes = groupBy<Map<String, dynamic>, String>(
      mistakeResults,
      (row) => getGroupingKey(row['ayahId_quran']),
    );

    final List<BarChartDatas> chartDataList = [];
    final sortedKeys = groupedMistakes.keys.toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    for (final key in sortedKeys) {
      final groupMistakes = groupedMistakes[key]!;
      final dataPoints = MistakeType.values
          .where((e) => e != MistakeType.none)
          .map((mistakeType) {
            final count = groupMistakes
                .where((r) => r['mistakeTypeId'] == mistakeType.id)
                .length;
            return ChartDataPoint(
              label: mistakeType.labelAr,
              value: count.toDouble(),
            );
          })
          .toList();

      chartDataList.add(
        BarChartDatas(
          data: dataPoints,
          xAxisLabel: 'أنواع الأخطاء',
          yAxisLabel: 'العدد',
          periodLabel: _getFormattedPeriodLabel(filter.quantityUnit, key),
        ),
      );
    }

    return chartDataList;
  }

  String _getFormattedPeriodLabel(String quantityUnit, String key) {
    switch (quantityUnit) {
      case 'juz':
        return 'الجزء $key';
      case 'hizb':
        return 'الحزب $key';
      case 'page':
        return 'صفحة $key';
      default:
        return 'الفترة $key';
    }
  }

  // =========================================================================
  //                       Synchronization Methods
  // =========================================================================

  @override
  Future<List<SyncQueueModel>> getPendingSyncOperations() async {
    final db = await _appDb.database;
    final user = await _authLocalDataSource.getCachedUser();
    final tenantId = user.id;
    try {
      final maps = await db.query(
        _kPendingOperationsTable,
        where: 'entity_type = ? AND status = ? AND tenant_id = ?',
        whereArgs: [_kTrackingEntityType, 'pending', tenantId],
        orderBy: 'created_at ASC',
      );
      return maps.map(SyncQueueModel.fromMap).toList();
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to get pending tracking operations: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteCompletedOperation(int operationId) async {
    final db = await _appDb.database;
    try {
      await db.delete(
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

  @override
  Future<int> getLastSyncTimestamp() async {
    final db = await _appDb.database;
    final user = await _authLocalDataSource.getCachedUser();
    final tenantId = user.id;
    try {
      final result = await db.query(
        _kSyncMetadataTable,
        columns: ['last_server_sync_timestamp'],
        where: 'entity_type = ? AND tenant_id = ?',
        whereArgs: [_kTrackingEntityType, tenantId],
      );
      return result.isNotEmpty
          ? result.first['last_server_sync_timestamp'] as int? ?? 0
          : 0;
    } on DatabaseException catch (e) {
      throw CacheException(
        message:
            'Failed to get last sync timestamp for tracking: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateLastSyncTimestamp(int timestamp) async {
    final db = await _appDb.database;
    final user = await _authLocalDataSource.getCachedUser();
    final tenantId = user.id;
    try {
      await db.insert(
          _kSyncMetadataTable,
          {
            'entity_type': _kTrackingEntityType,
            'last_server_sync_timestamp': timestamp,
            'tenant_id': tenantId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    } on DatabaseException catch (e) {
      throw CacheException(
        message:
            'Failed to update last sync timestamp for tracking: ${e.toString()}',
      );
    }
  }

  // =========================================================================
  //                             Private Helper Methods
  // =========================================================================

  /// Finds the most recent draft tracking record for a student, or creates a new one for today if none exists.
  Future<Map<String, dynamic>> _findOrCreateParentDraftTracking(
    Database db,
    int enrollmentId,
    String tenantId,
  ) async {
    final lastDraft = await db.query(
      _kDailyTrackingTable,
      where: 'enrollmentId = ? AND status = ? AND tenant_id = ?',
      whereArgs: [enrollmentId, 'draft', tenantId],
      orderBy: 'trackDate DESC',
      limit: 1,
    );
    if (lastDraft.isNotEmpty) {
      return lastDraft.first;
    }

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final newRecord = {
      'uuid': const Uuid().v4(),
      'enrollmentId': enrollmentId,
      'trackDate': today,
      'status': 'draft',
      'lastModified': DateTime.now().millisecondsSinceEpoch,
      'tenant_id': tenantId,
    };
    final newId = await db.insert(_kDailyTrackingTable, newRecord);
    return (await db.query(
      _kDailyTrackingTable,
      where: 'id = ?',
      whereArgs: [newId],
    )).first;
  }

  /// Creates default detail rows for a new parent tracking record, intelligently setting the start point for each.
  Future<void> _createMissingDetails(
    Database db,
    int trackingId,
    String tenantId, {
    required Map<TrackingType, StopPoint> startUnits,
  }) async {
    final batch = db.batch();
    for (final type in TrackingType.values) {
      final startPoint = startUnits[type] ?? StopPoint();
      final startUnitId = startPoint.unitIndex;
      final startUnitGap = startPoint.gap;
      batch.insert(_kDailyTrackingDetailTable, {
        'uuid': const Uuid().v4(),
        'trackingId': trackingId,
        'typeId': type.id,
        'status': 'draft',
        'fromTrackingUnitId': startUnitId,
        'toTrackingUnitId': startUnitId,
        'gap': startUnitGap,
        'lastModified': DateTime.now().millisecondsSinceEpoch,
        'tenant_id': tenantId,
      });
    }
    await batch.commit(noResult: true);
  }

  /// Retrieves a map of the last `toTrackingUnitId` for each tracking type individually from the student's past COMPLETED sessions.
  Future<Map<TrackingType, StopPoint>> _getLastCompletedUnitIds(
    Database db,
    int enrollmentId,
    String tenantId,
  ) async {
    final List<Map<String, dynamic>> results = await db.rawQuery(
      '''
      SELECT tdt.typeId, tdt.toTrackingUnitId, gap
      FROM $_kDailyTrackingDetailTable AS tdt
      INNER JOIN (
          SELECT tdt_inner.typeId, MAX(dt_inner.trackDate) AS max_date
          FROM $_kDailyTrackingDetailTable AS tdt_inner
          INNER JOIN $_kDailyTrackingTable AS dt_inner ON tdt_inner.trackingId = dt_inner.id
          WHERE dt_inner.enrollmentId = ? AND tdt_inner.status = 'completed' AND tdt_inner.toTrackingUnitId IS NOT NULL AND dt_inner.tenant_id = ?
          GROUP BY tdt_inner.typeId
      ) AS max_dates ON tdt.typeId = max_dates.typeId
      INNER JOIN $_kDailyTrackingTable AS dt ON tdt.trackingId = dt.id AND dt.trackDate = max_dates.max_date
      WHERE dt.enrollmentId = ? AND dt.tenant_id = ? -- AND tdt.status = 'completed'
    ''',
      [enrollmentId, tenantId, enrollmentId, tenantId],
    );

    if (results.isEmpty) return {};
    return {
      for (var row in results)
        TrackingType.fromId(row['typeId'] as int): StopPoint(
          unitIndex: row['toTrackingUnitId'] as int,
          gap: row['gap'] as double,
        ),
    };
  }

  /// Assembles fully formed `TrackingDetailModel` objects by fetching and attaching their child `MistakeModel`s.
  Future<List<TrackingDetailModel>> _fetchDetailsWithMistakes(
    DatabaseExecutor db,
    List<Map<String, dynamic>> detailMaps,
  ) async {
    if (detailMaps.isEmpty) return [];
    final detailIds = detailMaps.map((d) => d['id'] as int).toList();
    final mistakesByDetailId =
        await _fetchGroupedByForeignKey<int, MistakeModel>(
          dbExecutor: db,
          tableName: _kMistakesTable,
          foreignKeyColumn: 'trackingDetailId',
          foreignKeys: detailIds,
          fromMap: MistakeModel.fromDbMap,
        );
    return detailMaps.map((detailMap) {
      final detailId = detailMap['id'] as int;
      final mistakes = mistakesByDetailId[detailId] ?? [];
      return TrackingDetailModel.fromDbMap(detailMap, mistakes);
    }).toList();
  }

  /// (Internal Helper) Queues a sync operation within an existing transaction.
  Future<void> _queueSyncOperation(
      {required DatabaseExecutor dbExecutor,
      required String uuid,
      required String operation,
      required String tenantId,
      Map<String, dynamic>? payload}) async {
    await dbExecutor.insert(_kPendingOperationsTable, {
      'entity_uuid': uuid,
      'entity_type': _kTrackingEntityType,
      'operation_type': operation,
      'payload': payload != null ? json.encode(payload) : null,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'status': 'pending',
      'tenant_id': tenantId
    });
  }

  /// Helper to get the UUID of a parent tracking record from its local ID.
  /// Throws a [CacheException] if the ID is not found, as this indicates a critical logic error.
  Future<String> _getParentTrackingUuid(
    DatabaseExecutor db,
    int trackingId,
  ) async {
    final result = await db.query(
      _kDailyTrackingTable,
      columns: ['uuid'],
      where: 'id = ?',
      whereArgs: [trackingId],
    );
    if (result.isNotEmpty) {
      return result.first['uuid'] as String;
    }
    throw CacheException(
      message:
          'Consistency Error: Could not find parent tracking record for id $trackingId',
    );
  }

  /// Generic helper to fetch and group child records efficiently.
  Future<Map<K, List<T>>> _fetchGroupedByForeignKey<K, T>({
    required DatabaseExecutor dbExecutor,
    required String tableName,
    required String foreignKeyColumn,
    required List<K> foreignKeys,
    required T Function(Map<String, dynamic> map) fromMap,
  }) async {
    if (foreignKeys.isEmpty) return {};
    final maps = await dbExecutor.query(
      tableName,
      where:
          '$foreignKeyColumn IN (${List.filled(foreignKeys.length, '?').join(',')})',
      whereArgs: foreignKeys,
    );
    final groupedRawMaps = groupBy<Map<String, dynamic>, K>(
      maps,
      (map) => map[foreignKeyColumn] as K,
    );
    return groupedRawMaps.map(
      (key, value) => MapEntry(key, value.map(fromMap).toList()),
    );
  }
}

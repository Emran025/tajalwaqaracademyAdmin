import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
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
  static const int _kDefaultStartUnitId =
      1; // Represents the start of the Quran.

  TrackingLocalDataSourceImpl(this._appDb, this._quranDataSource);

  // =========================================================================
  //                             Core Public Methods
  // =========================================================================

  @override
  Future<Map<TrackingType, TrackingDetailModel>>
  getOrCreateTodayDraftTrackingDetails({required int enrollmentId}) async {
    final db = await _appDb.database;
    try {
      final trackingRecord = await _findOrCreateParentDraftTracking(
        db,
        enrollmentId,
      );
      final trackingId = trackingRecord['id'] as int;

      var detailMaps = await db.query(
        _kDailyTrackingDetailTable,
        where: 'trackingId = ?',
        whereArgs: [trackingId],
      );
      if (detailMaps.length < 3) {
        final lastUnitIdsMap = await _getLastCompletedUnitIds(db, enrollmentId);
        await _createMissingDetails(
          db,
          trackingId,
          startUnitIds: lastUnitIdsMap,
        );
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
            batch.insert(_kMistakesTable, mistake.toDbMap(detail.id));
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
        );
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
    try {
      await db.transaction((txn) async {
        final parentTrackingUuid = await _getParentTrackingUuid(
          txn,
          trackingId,
        );
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
          where:
              'trackingId = ? AND fromTrackingUnitId IS NOT NULL AND toTrackingUnitId IS NOT NULL AND fromTrackingUnitId != toTrackingUnitId',
          whereArgs: [trackingId],
        );
        await _queueSyncOperation(
          dbExecutor: txn,
          uuid: parentTrackingUuid,
          operation: 'update',
        );
      });
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to finalize daily tracking: ${e.toString()}',
      );
    }
  }
  // In TrackingLocalDataSourceImpl
  // In TrackingLocalDataSourceImpl

  @override
  Future<List<MistakeModel>> getAllMistakes({
    required int enrollmentId,
    TrackingType? type,
    int? fromPage,
    int? toPage,
  }) async {
    final db = await _appDb.database;
    try {
      String baseQuery = '''
      SELECT m.*
      FROM mistakes AS m
      INNER JOIN daily_tracking_detail AS tdt ON m.trackingDetailId = tdt.id
      INNER JOIN daily_tracking AS dt ON tdt.trackingId = dt.id
      INNER JOIN quran AS q ON m.ayahId_quran = q.id 
      WHERE dt.enrollmentId = ? 
        -- AND tdt.status = 'completed'
    ''';

      List<dynamic> arguments = [enrollmentId];

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
  Future<List<BarChartDatas>> getErrorAnalysisChartData(
      {required int enrollmentId, required ChartFilter filter}) async {
    final db = await _appDb.database;
    try {
      if (filter.dimension == FilterDimension.time) {
        return _fetchDataByTime(db, enrollmentId, filter);
      } else {
        return _fetchDataByQuantity(db, enrollmentId, filter);
      }
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to fetch error analysis data: ${e.toString()}',
      );
    }
  }

  Future<List<BarChartDatas>> _fetchDataByTime(
      Database db, int enrollmentId, ChartFilter filter) async {
    String dateFormat;
    bool isQuarter = filter.timePeriod == 'quarter';

    if (isQuarter) {
      dateFormat =
          '%Y-%m'; // Fetch by month, then group by quarter in Dart
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

    final query = '''
      SELECT
        m.mistakeTypeId,
        COUNT(m.id) as mistakeCount,
        STRFTIME('$dateFormat', dt.trackDate) as period
      FROM $_kMistakesTable AS m
      JOIN $_kDailyTrackingDetailTable AS dtd ON m.trackingDetailId = dtd.id
      JOIN $_kDailyTrackingTable AS dt ON dtd.trackingId = dt.id
      WHERE dt.enrollmentId = ? AND dtd.typeId = ?
      GROUP BY period, m.mistakeTypeId
      ORDER BY period ASC;
    ''';

    final trackingType = TrackingType.values
        .firstWhere((e) => e.toString().endsWith(filter.trackingType));
    final results =
        await db.rawQuery(query, [enrollmentId, trackingType.id]);
    if (results.isEmpty) return [];

    if (isQuarter) {
      return _groupMonthsIntoQuarters(results);
    }

    // Group by period (for non-quarter filters)
    final groupedByPeriod =
        groupBy<Map<String, dynamic>, String>(results, (row) => row['period']);

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
      List<Map<String, dynamic>> monthlyResults) {
    final groupedByQuarter =
        groupBy<Map<String, dynamic>, String>(monthlyResults, (row) {
      final yearMonth = (row['period'] as String).split('-');
      final month = int.parse(yearMonth[1]);
      final quarter = (month - 1) ~/ 3 + 1;
      return '${yearMonth[0]}-Q$quarter';
    });

    final List<BarChartDatas> chartDataList = [];
    for (final quarter in groupedByQuarter.keys) {
      final quarterMistakes = groupedByQuarter[quarter]!;
      final dataPoints = _calculateDataPoints(quarterMistakes);

      final year = int.parse(quarter.split('-Q')[0]);
      final quarterNum = int.parse(quarter.split('-Q')[1]);
      final month = (quarterNum - 1) * 3 + 1;
      final periodDate = DateTime(year, month, 1);

      chartDataList.add(BarChartDatas(
        data: dataPoints,
        xAxisLabel: 'أنواع الأخطاء',
        yAxisLabel: 'العدد',
        periodDate: periodDate,
      ));
    }
    return chartDataList;
  }

  List<ChartDataPoint> _calculateDataPoints(
      List<Map<String, dynamic>> mistakes) {
    return MistakeType.values
        .where((e) => e != MistakeType.none)
        .map((mistakeType) {
      final count = mistakes
          .where((r) => r['mistakeTypeId'] == mistakeType.id)
          .fold<int>(0, (sum, r) => sum + (r['mistakeCount'] as int));
      return ChartDataPoint(
          label: mistakeType.labelAr, value: count.toDouble());
    }).toList();
  }

  Future<List<BarChartDatas>> _fetchDataByQuantity(
      Database db, int enrollmentId, ChartFilter filter) async {
    final trackingType = TrackingType.values
        .firstWhere((e) => e.toString().endsWith(filter.trackingType));
    final allMistakesQuery = '''
      SELECT m.mistakeTypeId, m.ayahId_quran
      FROM $_kMistakesTable AS m
      JOIN $_kDailyTrackingDetailTable AS dtd ON m.trackingDetailId = dtd.id
      JOIN $_kDailyTrackingTable AS dt ON dtd.trackingId = dt.id
      WHERE dt.enrollmentId = ? AND dtd.typeId = ?;
    ''';
    final mistakeResults =
        await db.rawQuery(allMistakesQuery, [enrollmentId, trackingType.id]);
    if (mistakeResults.isEmpty) return [];

    // 2. Get Ayah details from Quran DB
    final ayahIds =
        mistakeResults.map((r) => r['ayahId_quran'] as int).toSet().toList();
    final ayahs = await _quranDataSource.getMistakesAyahs(ayahIds);
    final ayahMap = {for (var ayah in ayahs) ayah.number: ayah};

    // 3. Group mistakes by the quantitative unit
    String Function(int) getGroupingKey;
    switch (filter.quantityUnit) {
      case 'juz':
        getGroupingKey = (ayahId) => ayahMap[ayahId]?.juz.toString() ?? '0';
        break;
      case 'hizb':
        getGroupingKey = (ayahId) => ayahMap[ayahId]?.hizb.toString() ?? '0';
        break;
      case 'page':
      default:
        getGroupingKey = (ayahId) => ayahMap[ayahId]?.pageNum.toString() ?? '0';
        break;
    }

    final groupedMistakes = groupBy<Map<String, dynamic>, String>(
        mistakeResults, (row) => getGroupingKey(row['ayahId_quran']));

    final List<BarChartDatas> chartDataList = [];
    final sortedKeys = groupedMistakes.keys.toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    for (final key in sortedKeys) {
       final groupMistakes = groupedMistakes[key]!;
       final dataPoints = MistakeType.values
          .where((e) => e != MistakeType.none)
          .map((mistakeType) {
        final count = groupMistakes.where((r) => r['mistakeTypeId'] == mistakeType.id).length;
        return ChartDataPoint(
            label: mistakeType.labelAr, value: count.toDouble());
      }).toList();

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
    try {
      final maps = await db.query(
        _kPendingOperationsTable,
        where: 'entity_type = ? AND status = ?',
        whereArgs: [_kTrackingEntityType, 'pending'],
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
    try {
      final result = await db.query(
        _kSyncMetadataTable,
        columns: ['last_server_sync_timestamp'],
        where: 'entity_type = ?',
        whereArgs: [_kTrackingEntityType],
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
    try {
      await db.insert(_kSyncMetadataTable, {
        'entity_type': _kTrackingEntityType,
        'last_server_sync_timestamp': timestamp,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
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
  ) async {
    final lastDraft = await db.query(
      _kDailyTrackingTable,
      where: 'enrollmentId = ? AND status = ?',
      whereArgs: [enrollmentId, 'draft'],
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
    int trackingId, {
    required Map<TrackingType, int> startUnitIds,
  }) async {
    final batch = db.batch();
    for (final type in TrackingType.values) {
      final startUnitId = startUnitIds[type] ?? _kDefaultStartUnitId;
      batch.insert(_kDailyTrackingDetailTable, {
        'uuid': const Uuid().v4(),
        'trackingId': trackingId,
        'typeId': type.id,
        'status': 'draft',
        'fromTrackingUnitId': startUnitId,
        'toTrackingUnitId': startUnitId,
        'lastModified': DateTime.now().millisecondsSinceEpoch,
      });
    }
    await batch.commit(noResult: true);
  }

  /// Retrieves a map of the last `toTrackingUnitId` for each tracking type individually from the student's past COMPLETED sessions.
  Future<Map<TrackingType, int>> _getLastCompletedUnitIds(
    Database db,
    int enrollmentId,
  ) async {
    final List<Map<String, dynamic>> results = await db.rawQuery(
      '''
      SELECT tdt.typeId, tdt.toTrackingUnitId
      FROM daily_tracking_detail AS tdt
      INNER JOIN (
          SELECT tdt_inner.typeId, MAX(dt_inner.trackDate) AS max_date
          FROM daily_tracking_detail AS tdt_inner
          INNER JOIN daily_tracking AS dt_inner ON tdt_inner.trackingId = dt_inner.id
          WHERE dt_inner.enrollmentId = ? AND tdt_inner.status = 'completed' AND tdt_inner.toTrackingUnitId IS NOT NULL
          GROUP BY tdt_inner.typeId
      ) AS max_dates ON tdt.typeId = max_dates.typeId
      INNER JOIN daily_tracking AS dt ON tdt.trackingId = dt.id AND dt.trackDate = max_dates.max_date
      WHERE dt.enrollmentId = ? -- AND tdt.status = 'completed'
    ''',
      [enrollmentId, enrollmentId],
    );

    if (results.isEmpty) return {};
    return {
      for (var row in results)
        TrackingType.fromId(row['typeId'] as int):
            row['toTrackingUnitId'] as int,
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
  Future<void> _queueSyncOperation({
    required DatabaseExecutor dbExecutor,
    required String uuid,
    required String operation,
    Map<String, dynamic>? payload,
  }) async {
    await dbExecutor.insert(_kPendingOperationsTable, {
      'entity_uuid': uuid,
      'entity_type': _kTrackingEntityType,
      'operation_type': operation,
      'payload': payload != null ? json.encode(payload) : null,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'status': 'pending',
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

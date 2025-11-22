import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/models/user_role.dart';

import '../../../../core/error/exceptions.dart';
import '../datasources/supervisor_local_data_source.dart';
import '../models/count_delta.dart';
import '../models/student_summaray_record.dart';
import '../models/student_summary_delta.dart';
import 'timeline_builder.dart';

@injectable
@LazySingleton(as: TimelineBuilder)
final class TimelineBuilderImpl implements TimelineBuilder {
  final SupervisorLocalDataSource _localDataSource;
  static const _staleThreshold = Duration(seconds: 30);
  final timeline = "Timeline";
  final count = "count";

  TimelineBuilderImpl({required SupervisorLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  @override
  Future<void> buildAccurateTimeline(UserRole entityType) async {
    try {
      final lastSyncTimestamp = await _localDataSource.getLastSyncTimestampFor(
        "${entityType.label}$timeline",
      );
      final lastSyncTime = DateTime.fromMillisecondsSinceEpoch(
        lastSyncTimestamp,
      );

      if (DateTime.now().difference(lastSyncTime) < _staleThreshold) {
        return;
      }

      final allStudents = await _localDataSource.getAllEntitysWithTimestamps(
        entityType,
      );

      if (allStudents.isEmpty) return;

      DateTime startDate;
      DateTime endDate;

      final startEndDate = await _localDataSource.getStartEndTimes(entityType);
      if (startEndDate.length < 2) {
        final studentDates = allStudents.map((s) => s.createdAt).toList()
          ..addAll(
            allStudents.where((s) => s.isDeleted).map((s) => s.lastModified),
          );

        studentDates.sort();
        startDate = studentDates.first;
        endDate = studentDates.last;
      } else {
        startDate = startEndDate.first;
        endDate = startEndDate.last;
      }

      final criticalDates = _extractCriticalDates(
        allStudents,
        startDate,
        endDate,
      );
      final timelinePoints = _buildTimelinePoints(
        entityType,
        allStudents,
        criticalDates,
      );

      for (final element in timelinePoints) {
        await _localDataSource.insertDailySummary(element);
      }
      final finalSyncTimestamp = DateTime.now().millisecondsSinceEpoch;

      _localDataSource.updateLastSyncTimestampFor(
        "${entityType.label}$timeline",
        finalSyncTimestamp,
      );
    } catch (e) {
      throw CacheException(
        message: 'Failed to build timeline: ${e.toString()}',
      );
    }
  }

  Set<DateTime> _extractCriticalDates(
    List<Record> students,
    DateTime start,
    DateTime end,
  ) {
    final dates = <DateTime>{};

    for (final student in students) {
      // تاريخ الإضافة
      if (_isDateInRange(student.createdAt, start, end)) {
        dates.add(
          DateTime(
            student.createdAt.year,
            student.createdAt.month,
            student.createdAt.day,
          ),
        );
      }

      // تاريخ الحذف
      if (student.isDeleted &&
          _isDateInRange(student.lastModified, start, end)) {
        dates.add(
          DateTime(
            student.lastModified.year,
            student.lastModified.month,
            student.lastModified.day,
          ),
        );
      }
    }

    dates.add(DateTime(start.year, start.month, start.day));
    dates.add(DateTime(end.year, end.month, end.day));

    return dates;
  }

  List<SummaryDelta> _buildTimelinePoints(
    UserRole entityType,
    List<Record> students,
    Set<DateTime> criticalDates,
  ) {
    final sortedDates = criticalDates.toList()..sort();
    final timelinePoints = <SummaryDelta>[];
    int currentCount = 0;

    for (final currentDate in sortedDates) {
      // حساب الإضافات والحذوفات لهذا التاريخ بالتحديد
      final dailyAdditions = students
          .where(
            (s) =>
                s.createdAt.year == currentDate.year &&
                s.createdAt.month == currentDate.month &&
                s.createdAt.day == currentDate.day,
          )
          .length;

      final dailyDeletions = students
          .where(
            (s) =>
                s.isDeleted &&
                s.lastModified.year == currentDate.year &&
                s.lastModified.month == currentDate.month &&
                s.lastModified.day == currentDate.day,
          )
          .length;

      // تحديث العدد الحالي
      currentCount = currentCount + dailyAdditions - dailyDeletions;

      timelinePoints.add(
        SummaryDelta(
          date: currentDate,
          entityType: entityType,
          activeCount: currentCount,
          additions: dailyAdditions,
          deletions: dailyDeletions,
        ),
      );
    }

    return timelinePoints;
  }

  bool _isDateInRange(DateTime date, DateTime start, DateTime end) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);

    return normalizedDate.isAfter(normalizedStart) ||
        normalizedDate.isAtSameMomentAs(normalizedStart) ||
        normalizedDate.isBefore(normalizedEnd) ||
        normalizedDate.isAtSameMomentAs(normalizedEnd);
  }

  @override
  Future<void> buildAccurateCounts() async {
    final lastSyncCount = await _localDataSource.getLastSyncTimestampFor(count);
    final lastSyncTime = DateTime.fromMillisecondsSinceEpoch(lastSyncCount);
    if (DateTime.now().difference(lastSyncTime) < _staleThreshold) {
      return;
    }
    UserRole role;
    final DateTime date = DateTime.now();

    //===============================================
    role = UserRole.student;
    final studentEntity = await _localDataSource.getEntitesCount(role);
    await _localDataSource.insertCount(
      CountDelta(count: studentEntity, date: date, entityType: role),
    );

    print("studentEntity : $studentEntity--------------------------");

    role = UserRole.teacher;
    final teacherEntity = await _localDataSource.getEntitesCount(role);
    await _localDataSource.insertCount(
      CountDelta(count: teacherEntity, date: date, entityType: role),
    );
    print("teacherEntity : $teacherEntity--------------------------");

    role = UserRole.halaqa;
    final halaqaEntity = await _localDataSource.getEntitesCount(role);
    await _localDataSource.insertCount(
      CountDelta(count: halaqaEntity, date: date, entityType: role),
    );
    print("halaqaEntity : $halaqaEntity--------------------------");

    //===============================================
    final finalSyncTimestamp = DateTime.now().millisecondsSinceEpoch;
    _localDataSource.updateLastSyncTimestampFor(count, finalSyncTimestamp);
  }
}

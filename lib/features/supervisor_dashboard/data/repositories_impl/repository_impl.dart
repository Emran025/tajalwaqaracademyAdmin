// repository/student_timeline_repository_impl.dart

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/entities/counts_delta_entity.dart';

import '../../../../core/models/user_role.dart';
import '../../domain/entities/chart_filter_entity.dart';
import '../../domain/entities/timeline_entity.dart';
import '../../domain/repositories/repository.dart';
import '../datasources/supervisor_local_data_source.dart';
import '../service/timeline_builder_impl.dart';

@LazySingleton(as: SupervisorTimelineRepository)
class SupervisorTimelineRepositoryImpl implements SupervisorTimelineRepository {
  final SupervisorLocalDataSource localDataSource;
  final TimelineBuilderImpl timelineBuilder;

  SupervisorTimelineRepositoryImpl({
    required this.localDataSource,
    required this.timelineBuilder,
  });

  @override
  Future<List<TimelineEntity>> getTimeline(ChartFilterEntity filter) async {
    await timelineBuilder.buildAccurateTimeline(filter.entityType);

    final summaries = await localDataSource.getDailySummariesInDateRange(
      filter.startDate,
      filter.endDate,
      filter.entityType,
    );

    return summaries
        .map((delta) => TimelineEntity.fromSummaryDelta(delta))
        .toList();
  }

  // Add this to your repository method
  @override
  Future<DateTimeRange> getAvailableDateRange(UserRole entityType) async {
    final times = await localDataSource.getStartEndTimes(entityType);
    print('Raw times from database: $times'); // Debug log

    if (times.length < 2) {
      final now = DateTime.now();
      final fallback = DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      );
      print('Using fallback date range: $fallback');
      return fallback;
    }

    final start = times[0];
    final end = times[1];
    print('Database date range - start: $start, end: $end');

    if (start.isAfter(end)) {
      print('WARNING: Date range was invalid, swapping dates');
      return DateTimeRange(start: end, end: start);
    }

    return DateTimeRange(start: start, end: end);
  }

  @override
  Future<CountsDeltaEntity> getEntitiesCounts() async {
    await timelineBuilder.buildAccurateCounts();
    final counts = await localDataSource.getCounts();
    print("----------------------${counts.studentCount.count}");
    print("----------------------${counts.teacherCount.count}");
    print("----------------------${counts.halaqaCount.count}");
    return counts.toEntity();
  }
  // @override
  // Future<DateTimeRange> getAvailableDateRange() async {
  //   final times = await localDataSource.getStartEndTimes();
  //   if (times.length < 2) {
  //     final now = DateTime.now();
  //     // Ensure start is always before end
  //     return DateTimeRange(
  //       start: now.subtract(const Duration(days: 30)),
  //       end: now
  //     );
  //   }

  //   // Validate that start is before end
  //   final start = times[0];
  //   final end = times[1];

  //   if (start.isAfter(end)) {
  //     // Swap dates if they're in wrong order
  //     return DateTimeRange(start: end, end: start);
  //   }

  //   return DateTimeRange(start: start, end: end);
  // }
}

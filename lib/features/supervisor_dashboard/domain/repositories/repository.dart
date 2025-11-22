// repository/student_timeline_repository.dart

import 'package:flutter/material.dart';
import '../../../../core/models/user_role.dart';
import '../entities/chart_filter_entity.dart';
import '../entities/counts_delta_entity.dart';
import '../entities/timeline_entity.dart';

abstract class SupervisorTimelineRepository {
  Future<CountsDeltaEntity> getEntitiesCounts();
  Future<List<TimelineEntity>> getTimeline(ChartFilterEntity filter);
  Future<DateTimeRange> getAvailableDateRange(UserRole entityType);
}

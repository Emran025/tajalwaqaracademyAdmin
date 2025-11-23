// repository/student_timeline_repository.dart

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/user_role.dart';
import '../../../StudentsManagement/domain/entities/paginated_applicants_result.dart';
import '../entities/chart_filter_entity.dart';
import '../entities/counts_delta_entity.dart';
import '../entities/timeline_entity.dart';

abstract class SupervisorRepository {
  Future<CountsDeltaEntity> getEntitiesCounts();
  Future<List<TimelineEntity>> getTimeline(ChartFilterEntity filter);
  Future<DateTimeRange> getAvailableDateRange(UserRole entityType);
  Future<Either<Failure, PaginatedApplicantsResult>> getApplicants({
    int page = 1,
    required UserRole entityType,
  });
}

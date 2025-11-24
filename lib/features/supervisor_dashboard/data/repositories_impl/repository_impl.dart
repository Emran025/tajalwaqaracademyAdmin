// repository/student_timeline_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/entities/counts_delta_entity.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/user_role.dart';
import '../../../StudentsManagement/domain/entities/paginated_applicants_result.dart';
import '../../domain/entities/applicant_profile_entity.dart';
import '../../domain/entities/chart_filter_entity.dart';
import '../../domain/entities/timeline_entity.dart';
import '../../domain/repositories/repository.dart';
import '../datasources/supervisor_remote_data_source.dart';
import '../datasources/supervisor_local_data_source.dart';
import '../service/timeline_builder_impl.dart';

@LazySingleton(as: SupervisorRepository)
class SupervisorRepositoryImpl implements SupervisorRepository {
  final SupervisorLocalDataSource localDataSource;
  final SupervisorRemoteDataSource remoteDataSource;
  final TimelineBuilderImpl timelineBuilder;

  SupervisorRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
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
    return counts.toEntity();
  }

  @override
  Future<Either<Failure, PaginatedApplicantsResult>> getApplicants({
    int page = 1,
    required UserRole entityType,
  }) async {
    try {
      final result = await remoteDataSource.getApplicants(
        page: page,
        entityType: entityType,
      );

      final entities = result.data
          .map((element) => element.toEntity())
          .toList();

      return Right(
        PaginatedApplicantsResult(
          applicants: entities,
          pagination: result.pagination.toEntity(),
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ApplicantProfileEntity>> getApplicantProfile(
      int applicantId) async {
    try {
      final result = await remoteDataSource.getApplicantProfile(applicantId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> approveApplicant(int applicantId) async {
    try {
      await remoteDataSource.approveApplicant(applicantId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

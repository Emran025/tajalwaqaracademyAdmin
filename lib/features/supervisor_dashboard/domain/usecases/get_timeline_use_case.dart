// repository/student_timeline_repository.dart

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/chart_filter_entity.dart';
import '../entities/timeline_entity.dart';
import '../repositories/repository.dart';

import '../../../../core/error/failures.dart';

@lazySingleton
class GetTimelineUseCase {
  final SupervisorRepository repository;

  GetTimelineUseCase({required this.repository});

  Future<Either<Failure, List<TimelineEntity>>> call(
    ChartFilterEntity filter,
  ) async {
    try {
      final timeline = await repository.getTimeline(filter);
      return Right(timeline);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}

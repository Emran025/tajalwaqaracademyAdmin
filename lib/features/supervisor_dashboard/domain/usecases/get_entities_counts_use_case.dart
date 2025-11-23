// repository/get_entities_counts_use_case.dart

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/counts_delta_entity.dart';
import '../repositories/repository.dart';

@lazySingleton
class GetEntitiesCountsUseCase {
  final SupervisorRepository repository;

  GetEntitiesCountsUseCase({required this.repository});

  Future<Either<Failure, CountsDeltaEntity>> call() async {
    try {
      final counts = await repository.getEntitiesCounts();
      return Right(counts);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}

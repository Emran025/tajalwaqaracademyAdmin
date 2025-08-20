// lib/features/halaqas/domain/usecases/upsert_halaqa.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/halaqa_entity.dart';
import '../repositories/halaqa_repository.dart';
import 'usecase.dart';

@lazySingleton
class UpsertHalaqa extends UseCase<HalaqaDetailEntity, HalaqaDetailEntity> {
  final HalaqaRepository repository;

  UpsertHalaqa(this.repository);

  @override
  Future<Either<Failure, HalaqaDetailEntity>> call(
    HalaqaDetailEntity halaqa,
  ) async {
    return await repository.upsertHalaqa(halaqa);
  }
}

// lib/features/halaqas/domain/usecases/get_halaqa_by_id.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/halaqa_entity.dart';
import '../repositories/halaqa_repository.dart';
import 'usecase.dart';

@lazySingleton
class GetHalaqaById extends UseCase<HalaqaDetailEntity, String> {
  final HalaqaRepository repository;

  GetHalaqaById(this.repository);

  @override
  Future<Either<Failure, HalaqaDetailEntity>> call(String halaqaId) async {
    return await repository.getHalaqaById(halaqaId);
  }
}

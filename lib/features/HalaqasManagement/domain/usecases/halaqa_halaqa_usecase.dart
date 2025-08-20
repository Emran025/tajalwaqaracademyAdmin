// lib/features/halaqas/domain/usecases/delete_halaqa.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/error/failures.dart';
import 'usecase.dart';

import '../repositories/halaqa_repository.dart';

@lazySingleton
class DeleteHalaqaUseCase extends UseCase<Unit, String> {
  final HalaqaRepository repository;

  DeleteHalaqaUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String halaqaId) async {
    return await repository.deleteHalaqa(halaqaId);
  }
}

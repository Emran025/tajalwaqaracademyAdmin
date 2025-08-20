// lib/features/halaqas/domain/usecases/delete_halaqa.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/error/failures.dart';
import 'usecase.dart';

import '../repositories/halaqa_repository.dart';

@lazySingleton
class FetchMoreHalaqasUseCase extends UseCase<Unit, int> {
  final HalaqaRepository repository;

  FetchMoreHalaqasUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(int page) async {
    return await repository.fetchMoreHalaqas(page: page);
  }
}

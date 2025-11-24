import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/terms_of_use_entity.dart';
import '../repositories/settings_repository.dart';

@lazySingleton
class GetTermsOfUseUseCase implements UseCase<TermsOfUseEntity, NoParams> {
  final SettingsRepository repository;

  GetTermsOfUseUseCase(this.repository);

  @override
  Future<Either<Failure, TermsOfUseEntity>> call(NoParams params) async {
    return await repository.getTermsOfUse();
  }
}

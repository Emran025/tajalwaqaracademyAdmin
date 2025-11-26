import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/repository.dart';

@injectable
class RejectApplicantUseCase {
  final SupervisorRepository repository;

  RejectApplicantUseCase(this.repository);

  Future<Either<Failure, Unit>> call(int applicantId, String reason) async {
    return await repository.rejectApplicant(applicantId, reason);
  }
}

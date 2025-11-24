import 'package:dartz/dartz.dart';
import 'package:tajalwaqaracademy/core/error/failures.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/repositories/repository.dart';
import 'package:injectable/injectable.dart';
@injectable
class ApproveApplicantUseCase {
  final SupervisorRepository repository;

  ApproveApplicantUseCase(this.repository);

  Future<Either<Failure, Unit>> call(int applicantId) async {
    return await repository.approveApplicant(applicantId);
  }
}

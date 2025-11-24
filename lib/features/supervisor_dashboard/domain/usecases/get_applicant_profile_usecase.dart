import 'package:dartz/dartz.dart';
import 'package:tajalwaqaracademy/core/error/failures.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/entities/applicant_profile_entity.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/repositories/repository.dart';

class GetApplicantProfileUseCase {
  final SupervisorRepository repository;

  GetApplicantProfileUseCase(this.repository);

  Future<Either<Failure, ApplicantProfileEntity>> call(int applicantId) async {
    return await repository.getApplicantProfile(applicantId);
  }
}
